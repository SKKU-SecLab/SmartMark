
pragma solidity ^0.5.0;

contract SignatureVerifier {

    function isSigned(address _address, bytes32 messageHash, uint8 v, bytes32 r, bytes32 s) public pure returns (bool) {

        return _isSigned(_address, messageHash, v, r, s) || _isSignedPrefixed(_address, messageHash, v, r, s);
    }

    function _isSigned(address _address, bytes32 messageHash, uint8 v, bytes32 r, bytes32 s)
        internal pure returns (bool)
    {

        return ecrecover(messageHash, v, r, s) == _address;
    }

    function _isSignedPrefixed(address _address, bytes32 messageHash, uint8 v, bytes32 r, bytes32 s)
        internal pure returns (bool)
    {

        bytes memory prefix = "\x19Ethereum Signed Message:\n32";
        return _isSigned(_address, keccak256(abi.encodePacked(prefix, messageHash)), v, r, s);
    }
}

library AddressSet {

    struct Set {
        address[] members;
        mapping(address => uint) memberIndices;
    }

    function insert(Set storage self, address other) internal {

        if (!contains(self, other)) {
            self.memberIndices[other] = self.members.push(other);
        }
    }

    function remove(Set storage self, address other) internal {

        if (contains(self, other)) {
            self.members[self.memberIndices[other] - 1] = self.members[length(self) - 1];
            self.memberIndices[self.members[self.memberIndices[other] - 1]] = self.memberIndices[other];
            delete self.memberIndices[other];
            self.members.pop();
        }
    }

    function contains(Set storage self, address other) internal view returns (bool) {

        return ( // solium-disable-line operator-whitespace
            self.memberIndices[other] > 0 && 
            self.members.length >= self.memberIndices[other] && 
            self.members[self.memberIndices[other] - 1] == other
        );
    }

    function length(Set storage self) internal view returns (uint) {

        return self.members.length;
    }
}

contract IdentityRegistry is SignatureVerifier {

    using AddressSet for AddressSet.Set;



    struct Identity {
        address recoveryAddress;
        AddressSet.Set associatedAddresses;
        AddressSet.Set providers;
        AddressSet.Set resolvers;
    }

    mapping (uint => Identity) private identityDirectory;
    mapping (address => uint) private associatedAddressDirectory;

    uint public nextEIN = 1;
    uint public maxAssociatedAddresses = 50;



    uint public signatureTimeout = 1 days;

    modifier ensureSignatureTimeValid(uint timestamp) {

        require(
            block.timestamp >= timestamp && block.timestamp < timestamp + signatureTimeout, "Timestamp is not valid."
        );
        _;
    }



    struct RecoveryAddressChange {
        uint timestamp;
        address oldRecoveryAddress;
    }

    mapping (uint => RecoveryAddressChange) private recoveryAddressChangeLogs;



    struct Recovery {
        uint timestamp;
        bytes32 hashedOldAssociatedAddresses;
    }

    mapping (uint => Recovery) private recoveryLogs;



    uint public recoveryTimeout = 2 weeks;

    function canChangeRecoveryAddress(uint ein) private view returns (bool) {

        return block.timestamp > recoveryAddressChangeLogs[ein].timestamp + recoveryTimeout;
    }

    function canRecover(uint ein) private view returns (bool) {

        return block.timestamp > recoveryLogs[ein].timestamp + recoveryTimeout;
    }



    function identityExists(uint ein) public view returns (bool) {

        return ein < nextEIN && ein > 0;
    }

    modifier _identityExists(uint ein) {

        require(identityExists(ein), "The identity does not exist.");
        _;
    }

    function hasIdentity(address _address) public view returns (bool) {

        return identityExists(associatedAddressDirectory[_address]);
    }

    modifier _hasIdentity(address _address, bool check) {

        require(
            hasIdentity(_address) == check,
            check ?
                "The passed address does not have an identity but should." :
                "The passed address has an identity but should not."
        );
        _;
    }

    function getEIN(address _address) public view _hasIdentity(_address, true) returns (uint ein) {

        return associatedAddressDirectory[_address];
    }

    function isAssociatedAddressFor(uint ein, address _address) public view returns (bool) {

        return identityDirectory[ein].associatedAddresses.contains(_address);
    }

    function isProviderFor(uint ein, address provider) public view returns (bool) {

        return identityDirectory[ein].providers.contains(provider);
    }

    modifier _isProviderFor(uint ein) {

        require(isProviderFor(ein, msg.sender), "The identity has not set the passed provider.");
        _;
    }

    function isResolverFor(uint ein, address resolver) public view returns (bool) {

        return identityDirectory[ein].resolvers.contains(resolver);
    }

    function getIdentity(uint ein) public view _identityExists(ein)
        returns (
            address recoveryAddress,
            address[] memory associatedAddresses, address[] memory providers, address[] memory resolvers
        )
    {

        Identity storage _identity = identityDirectory[ein];

        return (
            _identity.recoveryAddress,
            _identity.associatedAddresses.members,
            _identity.providers.members,
            _identity.resolvers.members
        );
    }



    function createIdentity(address recoveryAddress, address[] memory providers, address[] memory resolvers)
        public returns (uint ein)
    {

        return createIdentity(recoveryAddress, msg.sender, providers, resolvers, false);
    }

    function createIdentityDelegated(
        address recoveryAddress, address associatedAddress, address[] memory providers, address[] memory resolvers,
        uint8 v, bytes32 r, bytes32 s, uint timestamp
    )
        public ensureSignatureTimeValid(timestamp) returns (uint ein)
    {

        require(
            isSigned(
                associatedAddress,
                keccak256(
                    abi.encodePacked(
                        byte(0x19), byte(0), address(this),
                        "I authorize the creation of an Identity on my behalf.",
                        recoveryAddress, associatedAddress, providers, resolvers, timestamp
                    )
                ),
                v, r, s
            ),
            "Permission denied."
        );

        return createIdentity(recoveryAddress, associatedAddress, providers, resolvers, true);
    }

    function createIdentity(
        address recoveryAddress,
        address associatedAddress, address[] memory providers, address[] memory resolvers, bool delegated
    )
        private _hasIdentity(associatedAddress, false) returns (uint)
    {

        uint ein = nextEIN++;
        Identity storage _identity = identityDirectory[ein];

        _identity.recoveryAddress = recoveryAddress;
        addAssociatedAddress(ein, associatedAddress);
        addProviders(ein, providers, delegated);
        addResolvers(ein, resolvers, delegated);

        emit IdentityCreated(msg.sender, ein, recoveryAddress, associatedAddress, providers, resolvers, delegated);

        return ein;
    }


    function addAssociatedAddress(
        address approvingAddress, address addressToAdd, uint8 v, bytes32 r, bytes32 s, uint timestamp
    )
        public ensureSignatureTimeValid(timestamp)
    {

        bool fromApprovingAddress = msg.sender == approvingAddress;
        require(
            fromApprovingAddress || msg.sender == addressToAdd, "One or both of the passed addresses are malformed."
        );

        uint ein = getEIN(approvingAddress);

        require(
            isSigned(
                fromApprovingAddress ? addressToAdd : approvingAddress,
                keccak256(
                    abi.encodePacked(
                        byte(0x19), byte(0), address(this),
                        fromApprovingAddress ?
                            "I authorize being added to this Identity." :
                            "I authorize adding this address to my Identity.",
                        ein, addressToAdd, timestamp
                    )
                ),
                v, r, s
            ),
            "Permission denied."
        );

        addAssociatedAddress(ein, addressToAdd);

        emit AssociatedAddressAdded(msg.sender, ein, approvingAddress, addressToAdd, false);
    }

    function addAssociatedAddressDelegated(
        address approvingAddress, address addressToAdd,
        uint8[2] memory v, bytes32[2] memory r, bytes32[2] memory s, uint[2] memory timestamp
    )
        public ensureSignatureTimeValid(timestamp[0]) ensureSignatureTimeValid(timestamp[1])
    {

        uint ein = getEIN(approvingAddress);

        require(
            isSigned(
                approvingAddress,
                keccak256(
                    abi.encodePacked(
                        byte(0x19), byte(0), address(this),
                        "I authorize adding this address to my Identity.",
                        ein, addressToAdd, timestamp[0]
                    )
                ),
                v[0], r[0], s[0]
            ),
            "Permission denied from approving address."
        );
        require(
            isSigned(
                addressToAdd,
                keccak256(
                    abi.encodePacked(
                        byte(0x19), byte(0), address(this),
                        "I authorize being added to this Identity.",
                        ein, addressToAdd, timestamp[1]
                    )
                ),
                v[1], r[1], s[1]
            ),
            "Permission denied from address to add."
        );

        addAssociatedAddress(ein, addressToAdd);

        emit AssociatedAddressAdded(msg.sender, ein, approvingAddress, addressToAdd, true);
    }

    function addAssociatedAddress(uint ein, address addressToAdd) private _hasIdentity(addressToAdd, false) {

        require(
            identityDirectory[ein].associatedAddresses.length() < maxAssociatedAddresses, "Too many addresses."
        );

        identityDirectory[ein].associatedAddresses.insert(addressToAdd);
        associatedAddressDirectory[addressToAdd] = ein;
    }

    function removeAssociatedAddress() public {

        uint ein = getEIN(msg.sender);

        removeAssociatedAddress(ein, msg.sender);

        emit AssociatedAddressRemoved(msg.sender, ein, msg.sender, false);
    }

    function removeAssociatedAddressDelegated(address addressToRemove, uint8 v, bytes32 r, bytes32 s, uint timestamp)
        public ensureSignatureTimeValid(timestamp)
    {

        uint ein = getEIN(addressToRemove);

        require(
            isSigned(
                addressToRemove,
                keccak256(
                    abi.encodePacked(
                        byte(0x19), byte(0), address(this),
                        "I authorize removing this address from my Identity.",
                        ein, addressToRemove, timestamp
                    )
                ),
                v, r, s
            ),
            "Permission denied."
        );

        removeAssociatedAddress(ein, addressToRemove);

        emit AssociatedAddressRemoved(msg.sender, ein, addressToRemove, true);
    }

    function removeAssociatedAddress(uint ein, address addressToRemove) private {

        identityDirectory[ein].associatedAddresses.remove(addressToRemove);
        delete associatedAddressDirectory[addressToRemove];
    }


    function addProviders(address[] memory providers) public {

        addProviders(getEIN(msg.sender), providers, false);
    }

    function addProvidersFor(uint ein, address[] memory providers) public _isProviderFor(ein) {

        addProviders(ein, providers, true);
    }

    function addProviders(uint ein, address[] memory providers, bool delegated) private {

        Identity storage _identity = identityDirectory[ein];
        for (uint i; i < providers.length; i++) {
            _identity.providers.insert(providers[i]);
            emit ProviderAdded(msg.sender, ein, providers[i], delegated);
        }
    }

    function removeProviders(address[] memory providers) public {

        removeProviders(getEIN(msg.sender), providers, false);
    }

    function removeProvidersFor(uint ein, address[] memory providers) public _isProviderFor(ein) {

        removeProviders(ein, providers, true);
    }

    function removeProviders(uint ein, address[] memory providers, bool delegated) private {

        Identity storage _identity = identityDirectory[ein];
        for (uint i; i < providers.length; i++) {
            _identity.providers.remove(providers[i]);
            emit ProviderRemoved(msg.sender, ein, providers[i], delegated);
        }
    }

    function addResolvers(address[] memory resolvers) public {

        addResolvers(getEIN(msg.sender), resolvers, false);
    }

    function addResolversFor(uint ein, address[] memory resolvers) public _isProviderFor(ein) {

        addResolvers(ein, resolvers, true);
    }

    function addResolvers(uint ein, address[] memory resolvers, bool delegated) private {

        Identity storage _identity = identityDirectory[ein];
        for (uint i; i < resolvers.length; i++) {
            _identity.resolvers.insert(resolvers[i]);
            emit ResolverAdded(msg.sender, ein, resolvers[i], delegated);
        }
    }

    function removeResolvers(address[] memory resolvers) public {

        removeResolvers(getEIN(msg.sender), resolvers, true);
    }

    function removeResolversFor(uint ein, address[] memory resolvers) public _isProviderFor(ein) {

        removeResolvers(ein, resolvers, true);
    }

    function removeResolvers(uint ein, address[] memory resolvers, bool delegated) private {

        Identity storage _identity = identityDirectory[ein];
        for (uint i; i < resolvers.length; i++) {
            _identity.resolvers.remove(resolvers[i]);
            emit ResolverRemoved(msg.sender, ein, resolvers[i], delegated);
        }
    }



    function triggerRecoveryAddressChange(address newRecoveryAddress) public {

        triggerRecoveryAddressChange(getEIN(msg.sender), newRecoveryAddress, false);
    }

    function triggerRecoveryAddressChangeFor(uint ein, address newRecoveryAddress) public _isProviderFor(ein) {

        triggerRecoveryAddressChange(ein, newRecoveryAddress, true);
    }

    function triggerRecoveryAddressChange(uint ein, address newRecoveryAddress, bool delegated) private {

        Identity storage _identity = identityDirectory[ein];

        require(canChangeRecoveryAddress(ein), "Cannot trigger a change in recovery address yet.");

        recoveryAddressChangeLogs[ein] = RecoveryAddressChange(block.timestamp, _identity.recoveryAddress);

        emit RecoveryAddressChangeTriggered(msg.sender, ein, _identity.recoveryAddress, newRecoveryAddress, delegated);

        _identity.recoveryAddress = newRecoveryAddress;
    }

    function triggerRecovery(uint ein, address newAssociatedAddress, uint8 v, bytes32 r, bytes32 s, uint timestamp)
        public _identityExists(ein) _hasIdentity(newAssociatedAddress, false) ensureSignatureTimeValid(timestamp)
    {

        require(canRecover(ein), "Cannot trigger recovery yet.");
        Identity storage _identity = identityDirectory[ein];

        if (canChangeRecoveryAddress(ein)) {
            require(
                msg.sender == _identity.recoveryAddress, "Only the current recovery address can trigger recovery."
            );
        } else {
            require(
                msg.sender == recoveryAddressChangeLogs[ein].oldRecoveryAddress,
                "Only the recently removed recovery address can trigger recovery."
            );
        }

        require(
            isSigned(
                newAssociatedAddress,
                keccak256(
                    abi.encodePacked(
                        byte(0x19), byte(0), address(this),
                        "I authorize being added to this Identity via recovery.",
                        ein, newAssociatedAddress, timestamp
                    )
                ),
                v, r, s
            ),
            "Permission denied."
        );

        recoveryLogs[ein] = Recovery(
            block.timestamp, // solium-disable-line security/no-block-members
            keccak256(abi.encodePacked(_identity.associatedAddresses.members))
        );

        emit RecoveryTriggered(msg.sender, ein, _identity.associatedAddresses.members, newAssociatedAddress);

        resetIdentityData(_identity, msg.sender, false);
        addAssociatedAddress(ein, newAssociatedAddress);
    }

    function triggerDestruction(uint ein, address[] memory firstChunk, address[] memory lastChunk, bool resetResolvers)
        public _identityExists(ein)
    {

        require(!canRecover(ein), "Recovery has not recently been triggered.");
        Identity storage _identity = identityDirectory[ein];

        address payable[1] memory middleChunk = [msg.sender];
        require(
            keccak256(
                abi.encodePacked(firstChunk, middleChunk, lastChunk)
            ) == recoveryLogs[ein].hashedOldAssociatedAddresses,
            "Cannot destroy an EIN from an address that was not recently removed from said EIN via recovery."
        );

        emit IdentityDestroyed(msg.sender, ein, _identity.recoveryAddress, resetResolvers);

        resetIdentityData(_identity, address(0), resetResolvers);
    }

    function resetIdentityData(Identity storage identity, address newRecoveryAddress, bool resetResolvers) private {

        for (uint i; i < identity.associatedAddresses.members.length; i++) {
            delete associatedAddressDirectory[identity.associatedAddresses.members[i]];
        }
        delete identity.associatedAddresses;
        delete identity.providers;
        if (resetResolvers) delete identity.resolvers;
        identity.recoveryAddress = newRecoveryAddress;
    }



    event IdentityCreated(
        address indexed initiator, uint indexed ein,
        address recoveryAddress, address associatedAddress, address[] providers, address[] resolvers, bool delegated
    );
    event AssociatedAddressAdded(
        address indexed initiator, uint indexed ein, address approvingAddress, address addedAddress, bool delegated
    );
    event AssociatedAddressRemoved(address indexed initiator, uint indexed ein, address removedAddress, bool delegated);
    event ProviderAdded(address indexed initiator, uint indexed ein, address provider, bool delegated);
    event ProviderRemoved(address indexed initiator, uint indexed ein, address provider, bool delegated);
    event ResolverAdded(address indexed initiator, uint indexed ein, address resolvers, bool delegated);
    event ResolverRemoved(address indexed initiator, uint indexed ein, address resolvers, bool delegated);
    event RecoveryAddressChangeTriggered(
        address indexed initiator, uint indexed ein,
        address oldRecoveryAddress, address newRecoveryAddress, bool delegated
    );
    event RecoveryTriggered(
        address indexed initiator, uint indexed ein, address[] oldAssociatedAddresses, address newAssociatedAddress
    );
    event IdentityDestroyed(address indexed initiator, uint indexed ein, address recoveryAddress, bool resolversReset);
}