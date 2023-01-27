


pragma solidity ^0.8.0;

abstract contract Proxy {
    function _delegate(address implementation) internal virtual {
        assembly {
            calldatacopy(0, 0, calldatasize())

            let result := delegatecall(gas(), implementation, 0, calldatasize(), 0, 0)

            returndatacopy(0, 0, returndatasize())

            switch result
            case 0 {
                revert(0, returndatasize())
            }
            default {
                return(0, returndatasize())
            }
        }
    }

    function _implementation() internal view virtual returns (address);

    function _fallback() internal virtual {
        _beforeFallback();
        _delegate(_implementation());
    }

    fallback() external payable virtual {
        _fallback();
    }

    receive() external payable virtual {
        _fallback();
    }

    function _beforeFallback() internal virtual {}
}



pragma solidity ^0.8.0;

interface IBeacon {

    function implementation() external view returns (address);

}



pragma solidity ^0.8.0;

library Address {

    function isContract(address account) internal view returns (bool) {


        uint256 size;
        assembly {
            size := extcodesize(account)
        }
        return size > 0;
    }

    function sendValue(address payable recipient, uint256 amount) internal {

        require(address(this).balance >= amount, "Address: insufficient balance");

        (bool success, ) = recipient.call{value: amount}("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    function functionCall(address target, bytes memory data) internal returns (bytes memory) {

        return functionCall(target, data, "Address: low-level call failed");
    }

    function functionCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {

        return functionCallWithValue(target, data, 0, errorMessage);
    }

    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value
    ) internal returns (bytes memory) {

        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value,
        string memory errorMessage
    ) internal returns (bytes memory) {

        require(address(this).balance >= value, "Address: insufficient balance for call");
        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{value: value}(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {

        return functionStaticCall(target, data, "Address: low-level static call failed");
    }

    function functionStaticCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal view returns (bytes memory) {

        require(isContract(target), "Address: static call to non-contract");

        (bool success, bytes memory returndata) = target.staticcall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {

        return functionDelegateCall(target, data, "Address: low-level delegate call failed");
    }

    function functionDelegateCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {

        require(isContract(target), "Address: delegate call to non-contract");

        (bool success, bytes memory returndata) = target.delegatecall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    function verifyCallResult(
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) internal pure returns (bytes memory) {

        if (success) {
            return returndata;
        } else {
            if (returndata.length > 0) {

                assembly {
                    let returndata_size := mload(returndata)
                    revert(add(32, returndata), returndata_size)
                }
            } else {
                revert(errorMessage);
            }
        }
    }
}



pragma solidity ^0.8.0;

library StorageSlot {

    struct AddressSlot {
        address value;
    }

    struct BooleanSlot {
        bool value;
    }

    struct Bytes32Slot {
        bytes32 value;
    }

    struct Uint256Slot {
        uint256 value;
    }

    function getAddressSlot(bytes32 slot) internal pure returns (AddressSlot storage r) {

        assembly {
            r.slot := slot
        }
    }

    function getBooleanSlot(bytes32 slot) internal pure returns (BooleanSlot storage r) {

        assembly {
            r.slot := slot
        }
    }

    function getBytes32Slot(bytes32 slot) internal pure returns (Bytes32Slot storage r) {

        assembly {
            r.slot := slot
        }
    }

    function getUint256Slot(bytes32 slot) internal pure returns (Uint256Slot storage r) {

        assembly {
            r.slot := slot
        }
    }
}



pragma solidity ^0.8.2;




abstract contract ERC1967Upgrade {
    bytes32 private constant _ROLLBACK_SLOT = 0x4910fdfa16fed3260ed0e7147f7cc6da11a60208b5b9406d12a635614ffd9143;

    bytes32 internal constant _IMPLEMENTATION_SLOT = 0x360894a13ba1a3210667c828492db98dca3e2076cc3735a920a3ca505d382bbc;

    event Upgraded(address indexed implementation);

    function _getImplementation() internal view returns (address) {
        return StorageSlot.getAddressSlot(_IMPLEMENTATION_SLOT).value;
    }

    function _setImplementation(address newImplementation) private {
        require(Address.isContract(newImplementation), "ERC1967: new implementation is not a contract");
        StorageSlot.getAddressSlot(_IMPLEMENTATION_SLOT).value = newImplementation;
    }

    function _upgradeTo(address newImplementation) internal {
        _setImplementation(newImplementation);
        emit Upgraded(newImplementation);
    }

    function _upgradeToAndCall(
        address newImplementation,
        bytes memory data,
        bool forceCall
    ) internal {
        _upgradeTo(newImplementation);
        if (data.length > 0 || forceCall) {
            Address.functionDelegateCall(newImplementation, data);
        }
    }

    function _upgradeToAndCallSecure(
        address newImplementation,
        bytes memory data,
        bool forceCall
    ) internal {
        address oldImplementation = _getImplementation();

        _setImplementation(newImplementation);
        if (data.length > 0 || forceCall) {
            Address.functionDelegateCall(newImplementation, data);
        }

        StorageSlot.BooleanSlot storage rollbackTesting = StorageSlot.getBooleanSlot(_ROLLBACK_SLOT);
        if (!rollbackTesting.value) {
            rollbackTesting.value = true;
            Address.functionDelegateCall(
                newImplementation,
                abi.encodeWithSignature("upgradeTo(address)", oldImplementation)
            );
            rollbackTesting.value = false;
            require(oldImplementation == _getImplementation(), "ERC1967Upgrade: upgrade breaks further upgrades");
            _upgradeTo(newImplementation);
        }
    }

    bytes32 internal constant _ADMIN_SLOT = 0xb53127684a568b3173ae13b9f8a6016e243e63b6e8ee1178d6a717850b5d6103;

    event AdminChanged(address previousAdmin, address newAdmin);

    function _getAdmin() internal view returns (address) {
        return StorageSlot.getAddressSlot(_ADMIN_SLOT).value;
    }

    function _setAdmin(address newAdmin) private {
        require(newAdmin != address(0), "ERC1967: new admin is the zero address");
        StorageSlot.getAddressSlot(_ADMIN_SLOT).value = newAdmin;
    }

    function _changeAdmin(address newAdmin) internal {
        emit AdminChanged(_getAdmin(), newAdmin);
        _setAdmin(newAdmin);
    }

    bytes32 internal constant _BEACON_SLOT = 0xa3f0ad74e5423aebfd80d3ef4346578335a9a72aeaee59ff6cb3582b35133d50;

    event BeaconUpgraded(address indexed beacon);

    function _getBeacon() internal view returns (address) {
        return StorageSlot.getAddressSlot(_BEACON_SLOT).value;
    }

    function _setBeacon(address newBeacon) private {
        require(Address.isContract(newBeacon), "ERC1967: new beacon is not a contract");
        require(
            Address.isContract(IBeacon(newBeacon).implementation()),
            "ERC1967: beacon implementation is not a contract"
        );
        StorageSlot.getAddressSlot(_BEACON_SLOT).value = newBeacon;
    }

    function _upgradeBeaconToAndCall(
        address newBeacon,
        bytes memory data,
        bool forceCall
    ) internal {
        _setBeacon(newBeacon);
        emit BeaconUpgraded(newBeacon);
        if (data.length > 0 || forceCall) {
            Address.functionDelegateCall(IBeacon(newBeacon).implementation(), data);
        }
    }
}



pragma solidity ^0.8.0;



contract ERC1967Proxy is Proxy, ERC1967Upgrade {

    constructor(address _logic, bytes memory _data) payable {
        assert(_IMPLEMENTATION_SLOT == bytes32(uint256(keccak256("eip1967.proxy.implementation")) - 1));
        _upgradeToAndCall(_logic, _data, false);
    }

    function _implementation() internal view virtual override returns (address impl) {

        return ERC1967Upgrade._getImplementation();
    }
}



pragma solidity ^0.8.0;


contract TransparentUpgradeableProxy is ERC1967Proxy {

    constructor(
        address _logic,
        address admin_,
        bytes memory _data
    ) payable ERC1967Proxy(_logic, _data) {
        assert(_ADMIN_SLOT == bytes32(uint256(keccak256("eip1967.proxy.admin")) - 1));
        _changeAdmin(admin_);
    }

    modifier ifAdmin() {

        if (msg.sender == _getAdmin()) {
            _;
        } else {
            _fallback();
        }
    }

    function admin() external ifAdmin returns (address admin_) {

        admin_ = _getAdmin();
    }

    function implementation() external ifAdmin returns (address implementation_) {

        implementation_ = _implementation();
    }

    function changeAdmin(address newAdmin) external virtual ifAdmin {

        _changeAdmin(newAdmin);
    }

    function upgradeTo(address newImplementation) external ifAdmin {

        _upgradeToAndCall(newImplementation, bytes(""), false);
    }

    function upgradeToAndCall(address newImplementation, bytes calldata data) external payable ifAdmin {

        _upgradeToAndCall(newImplementation, data, true);
    }

    function _admin() internal view virtual returns (address) {

        return _getAdmin();
    }

    function _beforeFallback() internal virtual override {

        require(msg.sender != _getAdmin(), "TransparentUpgradeableProxy: admin cannot fallback to proxy target");
        super._beforeFallback();
    }
}



pragma solidity ^0.8.0;

contract ERC721TokenReceiver {

    function onERC721Received(
        address,
        address,
        uint256,
        bytes memory
    ) external pure returns (bytes4) {

        return ERC721TokenReceiver.onERC721Received.selector;
    }
}



pragma solidity ^0.8.0;


contract MultiSigWallet {


    event Confirmation(address indexed sender, uint indexed transactionId);
    event Revocation(address indexed sender, uint indexed transactionId);
    event Submission(uint indexed transactionId);
    event Execution(uint indexed transactionId);
    event ExecutionFailure(uint indexed transactionId);
    event Deposit(address indexed sender, uint value);
    event OwnerAddition(address indexed owner);
    event OwnerRemoval(address indexed owner);
    event RequirementChange(uint required);

    uint constant public MAX_OWNER_COUNT = 50;

    mapping(uint => Transaction) public transactions;
    mapping(uint => mapping(address => bool)) public confirmations;
    mapping(address => bool) public isOwner;
    address[] public owners;
    uint public required;
    uint public transactionCount;

    struct Transaction {
        address destination;
        uint value;
        bytes data;
        bool executed;
    }

    modifier onlyWallet() {

        require(msg.sender == address(this));
        _;
    }

    modifier ownerDoesNotExist(address owner) {

        require(!isOwner[owner]);
        _;
    }

    modifier ownerExists(address owner) {

        require(isOwner[owner]);
        _;
    }

    modifier transactionExists(uint transactionId) {

        require(transactions[transactionId].destination != (address)(0));
        _;
    }

    modifier confirmed(uint transactionId, address owner) {

        require(confirmations[transactionId][owner]);
        _;
    }

    modifier notConfirmed(uint transactionId, address owner) {

        require(!confirmations[transactionId][owner]);
        _;
    }

    modifier notExecuted(uint transactionId) {

        require(!transactions[transactionId].executed);
        _;
    }

    modifier notNull(address _address) {

        require(_address != (address)(0));
        _;
    }

    modifier validRequirement(uint ownerCount, uint _required) {

        require(ownerCount <= MAX_OWNER_COUNT
        && _required <= ownerCount
        && _required != 0
        && ownerCount != 0);
        _;
    }
    fallback() external payable
    {
        if (msg.value > 0)
            emit  Deposit(msg.sender, msg.value);
    }

    receive() external payable
    {
        if (msg.value > 0)
            emit Deposit(msg.sender, msg.value);
    }

    constructor(address[] memory _owners, uint _required)
    {
        required = 0;

        if (_owners.length > 0 || _required > 0){
            initialize(_owners, _required);
        }
    }

    function initialize(address[] memory _owners, uint _required) internal
     validRequirement(_owners.length, _required)
    {

        require(required == 0, "MS00");
        for (uint i = 0; i < _owners.length; i++) {
            require(!isOwner[_owners[i]] && _owners[i] != (address)(0));
            isOwner[_owners[i]] = true;
        }
        owners = _owners;
        required = _required;
    }

    function addOwner(address owner)
    public virtual 
    onlyWallet
    ownerDoesNotExist(owner)
    notNull(owner)
    validRequirement(owners.length + 1, required)
    {

        isOwner[owner] = true;
        owners.push(owner);
        emit OwnerAddition(owner);
    }

    function removeOwner(address owner)
    public virtual 
    onlyWallet
    ownerExists(owner)
    {

        require (owners.length > 1, "owners.length must larger than 1");
        isOwner[owner] = false;
        for (uint i = 0; i < owners.length; i++)
            if (owners[i] == owner) {
                owners[i] = owners[owners.length - 1];
                owners.pop();
                break;
            }

        if (required > owners.length)
            changeRequirement(owners.length);
        emit OwnerRemoval(owner);
    }

    function replaceOwner(address owner, address newOwner)
    public virtual 
    onlyWallet
    ownerExists(owner)
    ownerDoesNotExist(newOwner)
    {

        for (uint i = 0; i < owners.length; i++)
            if (owners[i] == owner) {
                owners[i] = newOwner;
                break;
            }
        isOwner[owner] = false;
        isOwner[newOwner] = true;
        emit OwnerRemoval(owner);
        emit OwnerAddition(newOwner);
    }

    function changeRequirement(uint _required)
    public virtual 
    onlyWallet
    validRequirement(owners.length, _required)
    {

        required = _required;
        emit RequirementChange(_required);
    }

    function submitTransaction(address destination, uint value, bytes memory data)
    public
    returns (uint transactionId)
    {

        transactionId = addTransaction(destination, value, data);
        confirmTransaction(transactionId);
    }

    function confirmTransaction(uint transactionId)
    public payable
    ownerExists(msg.sender)
    transactionExists(transactionId)
    notConfirmed(transactionId, msg.sender)
    {

        confirmations[transactionId][msg.sender] = true;
        emit Confirmation(msg.sender, transactionId);
        executeTransaction(transactionId);
    }

    function revokeConfirmation(uint transactionId)
    public
    ownerExists(msg.sender)
    confirmed(transactionId, msg.sender)
    notExecuted(transactionId)
    {

        confirmations[transactionId][msg.sender] = false;
        emit  Revocation(msg.sender, transactionId);
    }

    function executeTransaction(uint transactionId)
    public payable virtual 
    ownerExists(msg.sender)
    confirmed(transactionId, msg.sender)
    notExecuted(transactionId)
    {

        if (isConfirmed(transactionId)) {
            Transaction storage txn = transactions[transactionId];
            txn.executed = true;
            if (external_call(txn.destination, txn.value, txn.data.length, txn.data))
                emit  Execution(transactionId);
            else {
                emit  ExecutionFailure(transactionId);
                txn.executed = false;
            }
        }
    }

    function external_call(address destination, uint value, uint dataLength, bytes memory data) internal returns (bool) {

        bool result;
        uint __gas = gasleft() - 34710;
        assembly {
            let x := mload(0x40)   // "Allocate" memory for output (0x40 is where "free memory" pointer is stored by convention)
            let d := add(data, 32) // First 32 bytes are the padded length of data, so exclude that
            result := call(
            __gas,
            destination,
            value,
            d,
            dataLength, // Size of the input (in bytes) - this is what fixes the padding problem
            x,
            0                  // Output is ignored, therefore the output size is zero
            )
        }
        return result;
    }

    function isConfirmed(uint transactionId)
    public
    view
    returns (bool confirmedResult)
    {

        confirmedResult=false;
        uint count = 0;
        for (uint i = 0; i < owners.length; i++) {
            if (confirmations[transactionId][owners[i]])
                count += 1;
            if (count == required){
                confirmedResult=true;
                return confirmedResult;
            }
        }
    }

    function addTransaction(address destination, uint value, bytes memory data)
    internal
    notNull(destination)
    returns (uint transactionId)
    {

        transactionId = transactionCount;
        transactions[transactionId] = Transaction({
            destination : destination,
            value : value,
            data : data,
            executed : false
            });
        transactionCount += 1;
        emit Submission(transactionId);
    }

    function getConfirmationCount(uint transactionId)
    public
    view
    returns (uint count)
    {

        for (uint i = 0; i < owners.length; i++)
            if (confirmations[transactionId][owners[i]])
                count += 1;
    }

    function getTransactionCount(bool pending, bool executed)
    public
    view
    returns (uint count)
    {

        for (uint i = 0; i < transactionCount; i++)
            if (pending && !transactions[i].executed
            || executed && transactions[i].executed)
                count += 1;
    }

    function getOwners()
    public
    view
    returns (address[] memory)
    {

        return owners;
    }

    function getConfirmations(uint transactionId)
    public
    view
    returns (address[] memory _confirmations)
    {

        address[] memory confirmationsTemp = new address[](owners.length);
        uint count = 0;
        uint i;
        for (i = 0; i < owners.length; i++)
            if (confirmations[transactionId][owners[i]]) {
                confirmationsTemp[count] = owners[i];
                count += 1;
            }
        _confirmations = new address[](count);
        for (i = 0; i < count; i++)
            _confirmations[i] = confirmationsTemp[i];
    }

    function getTransactionIds(uint from, uint to, bool pending, bool executed)
    public
    view
    returns (uint[] memory _transactionIds)
    {

        uint[] memory transactionIdsTemp = new uint[](transactionCount);
        uint count = 0;
        uint i;
        for (i = 0; i < transactionCount; i++)
            if (pending && !transactions[i].executed
            || executed && transactions[i].executed)
            {
                transactionIdsTemp[count] = i;
                count += 1;
            }
        _transactionIds = new uint[](to - from);
        for (i = from; i < to; i++)
            _transactionIds[i - from] = transactionIdsTemp[i];
    }
}



pragma solidity ^0.8.0;


contract MultiSigWalletWithPermit is MultiSigWallet {

    mapping(bytes4 => bool) internal supportedInterfaces;
    bool internal ownersImmutable = true;
    bool internal initialized = false;

    modifier notImmutable() {

        require(!ownersImmutable, "MS01");
        _;
    }

    function addOwner(address owner) public override notImmutable {

        super.addOwner(owner);
    }

    function removeOwner(address owner) public override notImmutable {

        super.removeOwner(owner);
    }

    function replaceOwner(address owner, address newOwner)
        public
        override
        notImmutable
    {

        super.replaceOwner(owner, newOwner);
    }

    function changeRequirement(uint256 _required) public override notImmutable {

        super.changeRequirement(_required);
    }

    function supportsInterface(bytes4 interfaceID)
        external
        view
        returns (bool)
    {

        return supportedInterfaces[interfaceID];
    }

    function setSupportsInterface(bytes4 interfaceID, bool support)
        external
        onlyWallet
    {

        supportedInterfaces[interfaceID] = support;
    }

    constructor(
        address[] memory _owners,
        uint256 _required,
        bool _immutable
    ) MultiSigWallet(_owners, _required) {
        if (_required > 0) {
            initialized = true;

            setup0(_immutable);
        }
    }

    function setup(
        address[] memory _owners,
        uint256 _required,
        bool _immutable
    ) public {

        require(!initialized, "MS02");
        initialized = true;
        super.initialize(_owners, _required);
        setup0(_immutable);
    }

    function setup0(bool _immutable) private {

        ownersImmutable = _immutable;
        supportedInterfaces[0x01ffc9a7] = true;

        uint256 chainId;
        assembly {
            chainId := chainid()
        }
        DOMAIN_SEPARATOR = keccak256(
            abi.encode(
                0x8b73c3c69bb8fe3d512ecc4cf759cc79239f7b179b0ffacaa9a75d522b39400f,
                0x911a814036e00323c4ca54d47b0a363338990ca044824eba7a28205763e6115a,
                0xc89efdaa54c0f20c7adf612882df0950f5a951637e0307cdcb4c672f298b8bc6,
                chainId,
                address(this)
            )
        );
    }

    bytes32 public DOMAIN_SEPARATOR;
    bytes32 public constant PERMIT_TYPEHASH =
        0x8d14977a529be0cde9be2de41261d56c536e10c2bfb3f797a663ac4f3676d2fe;

    function executeTxWithPermits(
        address destination,
        uint256 value,
        bytes memory data,
        uint256 nonce,
        bytes32[] memory rs,
        bytes32[] memory ss,
        uint8[] memory vs
    ) public returns (uint256 newTransactionId) {

        require(isOwner[msg.sender], "MS90");
        require(rs.length == ss.length, "MS91");
        require(rs.length == vs.length, "MS92");
        require(nonce == transactionCount, "MS93");
        require(rs.length + 1 == required, "MS94");
        require(destination != address(0), "MS95");

        newTransactionId = addTransaction(destination, value, data);
        confirmations[newTransactionId][msg.sender] = true;

        bytes32 digest = keccak256(
            abi.encodePacked(
                "\x19\x01",
                DOMAIN_SEPARATOR,
                keccak256(
                    abi.encode(
                        PERMIT_TYPEHASH,
                        msg.sender,
                        destination,
                        value,
                        keccak256(data),
                        nonce
                    )
                )
            )
        );

        for (uint8 i = 0; i < rs.length; ++i) {
            address owner = ecrecover(digest, vs[i], rs[i], ss[i]);
            require(owner != address(0), "MS03");
            require(isOwner[owner], "MS04");

            confirmations[newTransactionId][owner] = true;
        }

        if (isConfirmed(newTransactionId)) {
            executeTransactionInner(destination, value, data, newTransactionId);
        } else {
            revert("MS06");
        }
    }

    function executeTransactionInner(
        address destination,
        uint256 value,
        bytes memory data,
        uint256 transactionId
    ) private {

        require(address(this).balance >= value, "MS07");

        (bool success, bytes memory returndata) = destination.call{
            value: value
        }(data);

        if (success) {
            transactions[transactionId].executed = true;
            emit Execution(transactionId);
        } else {
            if (returndata.length > 0) {
                assembly {
                    let returndata_size := mload(returndata)
                    revert(add(32, returndata), returndata_size)
                }
            } else {
                revert("MS08");
            }
        }
    }
}



pragma solidity ^0.8.0;

contract ERC1155TokenReceiver {

    function onERC1155Received(
        address,
        address,
        uint256,
        uint256,
        bytes calldata
    ) external pure returns (bytes4) {

        return ERC1155TokenReceiver.onERC1155Received.selector;
    }

    function onERC1155BatchReceived(
        address,
        address,
        uint256[] calldata,
        uint256[] calldata,
        bytes calldata
    ) external pure returns (bytes4) {

        return ERC1155TokenReceiver.onERC1155BatchReceived.selector;
    }
}



pragma solidity ^0.8.0;




contract MultiSigV1 is
    MultiSigWalletWithPermit,
    ERC721TokenReceiver,
    ERC1155TokenReceiver
{

    constructor(address[] memory _owners, uint256 _required,
        bool _immutable)
        MultiSigWalletWithPermit(_owners, _required, _immutable)
    {}

    function eipFeatures() public pure returns (uint256[3] memory fs) {

        fs = [uint256(165), uint256(721), uint256(1155)];
    }

    function version() public pure returns (uint256) {

        return 1;
    }
}



pragma solidity ^0.8.0;



contract UpgradeableMultiSignWalletFactory {

    event UpgradeableMultiSignWalletDeployed(
        address indexed admin,
        address indexed proxy,
        address indexed impl
    );

    function create(
        address[] memory _owners,
        uint256 _required,
        bool _immutable,
        address _impl
    ) public returns (address wallet) {

        MultiSigWalletWithPermit proxyAdmin = new MultiSigWalletWithPermit{
            salt: keccak256(
                abi.encodePacked(_owners, _required, msg.sender, _immutable)
            )
        }(_owners, _required, true);

        bytes32 newsalt = keccak256(
            abi.encodePacked(_owners, _required, msg.sender)
        );

        TransparentUpgradeableProxy proxy = new TransparentUpgradeableProxy{
            salt: newsalt
        }(_impl, address(proxyAdmin), "");

        setup(_owners, _required, _immutable, address(proxy));

        wallet = address(proxy);

        emit UpgradeableMultiSignWalletDeployed(
            address(proxyAdmin),
            address(proxy),
            _impl
        );
    }

    function setup(
        address[] memory _owners,
        uint256 _required,
        bool _immutable,
        address proxy
    ) internal {

        MultiSigWalletWithPermit walletImpl = (
            MultiSigWalletWithPermit(payable(proxy))
        );
        walletImpl.setup(_owners, _required, _immutable);
    }
}