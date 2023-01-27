



pragma solidity ^0.5.16;


contract Owned {

    address public owner;
    address public nominatedOwner;

    constructor(address _owner) public {
        require(_owner != address(0), "Owner address cannot be 0");
        owner = _owner;
        emit OwnerChanged(address(0), _owner);
    }

    function nominateNewOwner(address _owner) external onlyOwner {

        nominatedOwner = _owner;
        emit OwnerNominated(_owner);
    }

    function acceptOwnership() external {

        require(msg.sender == nominatedOwner, "You must be nominated before you can accept ownership");
        emit OwnerChanged(owner, nominatedOwner);
        owner = nominatedOwner;
        nominatedOwner = address(0);
    }

    modifier onlyOwner {

        _onlyOwner();
        _;
    }

    function _onlyOwner() private view {

        require(msg.sender == owner, "Only the contract owner may perform this action");
    }

    event OwnerNominated(address newOwner);
    event OwnerChanged(address oldOwner, address newOwner);
}


interface IAddressResolver {

    function getAddress(bytes32 name) external view returns (address);


    function getPynth(bytes32 key) external view returns (address);


    function requireAndGetAddress(bytes32 name, string calldata reason) external view returns (address);

}


interface IPynth {

    function currencyKey() external view returns (bytes32);


    function transferablePynths(address account) external view returns (uint);


    function transferAndSettle(address to, uint value) external returns (bool);


    function transferFromAndSettle(
        address from,
        address to,
        uint value
    ) external returns (bool);


    function burn(address account, uint amount) external;


    function issue(address account, uint amount) external;

}


interface IIssuer {

    function anyPynthOrPERIRateIsInvalid() external view returns (bool anyRateInvalid);


    function availableCurrencyKeys() external view returns (bytes32[] memory);


    function availablePynthCount() external view returns (uint);


    function availablePynths(uint index) external view returns (IPynth);


    function canBurnPynths(address account) external view returns (bool);


    function collateral(address account) external view returns (uint);


    function collateralisationRatio(address issuer) external view returns (uint);


    function collateralisationRatioAndAnyRatesInvalid(address _issuer)
        external
        view
        returns (uint cratio, bool anyRateIsInvalid);


    function debtBalanceOf(address issuer, bytes32 currencyKey) external view returns (uint debtBalance);


    function issuanceRatio() external view returns (uint);


    function lastIssueEvent(address account) external view returns (uint);


    function maxIssuablePynths(address issuer) external view returns (uint maxIssuable);


    function minimumStakeTime() external view returns (uint);


    function remainingIssuablePynths(address issuer)
        external
        view
        returns (
            uint maxIssuable,
            uint alreadyIssued,
            uint totalSystemDebt
        );


    function pynths(bytes32 currencyKey) external view returns (IPynth);


    function getPynths(bytes32[] calldata currencyKeys) external view returns (IPynth[] memory);


    function pynthsByAddress(address pynthAddress) external view returns (bytes32);


    function totalIssuedPynths(bytes32 currencyKey, bool excludeEtherCollateral) external view returns (uint);


    function transferablePynthetixAndAnyRateIsInvalid(address account, uint balance)
        external
        view
        returns (uint transferable, bool anyRateIsInvalid);


    function issuePynths(address from, uint amount) external;


    function issuePynthsOnBehalf(
        address issueFor,
        address from,
        uint amount
    ) external;


    function issueMaxPynths(address from) external;


    function issueMaxPynthsOnBehalf(address issueFor, address from) external;


    function burnPynths(address from, uint amount) external;


    function burnPynthsOnBehalf(
        address burnForAddress,
        address from,
        uint amount
    ) external;


    function burnPynthsToTarget(address from) external;


    function burnPynthsToTargetOnBehalf(address burnForAddress, address from) external;


    function liquidateDelinquentAccount(
        address account,
        uint susdAmount,
        address liquidator
    ) external returns (uint totalRedeemed, uint amountToLiquidate);

}



contract ReadProxy is Owned {

    address public target;

    constructor(address _owner) public Owned(_owner) {}

    function setTarget(address _target) external onlyOwner {

        target = _target;
        emit TargetUpdated(target);
    }

    function() external {
        assembly {
            calldatacopy(0, 0, calldatasize)

            let result := staticcall(gas, sload(target_slot), 0, calldatasize, 0, 0)
            returndatacopy(0, 0, returndatasize)

            if iszero(result) {
                revert(0, returndatasize)
            }
            return(0, returndatasize)
        }
    }

    event TargetUpdated(address newTarget);
}






contract MixinResolver {

    AddressResolver public resolver;

    mapping(bytes32 => address) private addressCache;

    constructor(address _resolver) internal {
        resolver = AddressResolver(_resolver);
    }


    function combineArrays(bytes32[] memory first, bytes32[] memory second)
        internal
        pure
        returns (bytes32[] memory combination)
    {

        combination = new bytes32[](first.length + second.length);

        for (uint i = 0; i < first.length; i++) {
            combination[i] = first[i];
        }

        for (uint j = 0; j < second.length; j++) {
            combination[first.length + j] = second[j];
        }
    }


    function resolverAddressesRequired() public view returns (bytes32[] memory addresses) {}


    function rebuildCache() public {

        bytes32[] memory requiredAddresses = resolverAddressesRequired();
        for (uint i = 0; i < requiredAddresses.length; i++) {
            bytes32 name = requiredAddresses[i];
            address destination = resolver.requireAndGetAddress(
                name,
                string(abi.encodePacked("Resolver missing target: ", name))
            );
            addressCache[name] = destination;
            emit CacheUpdated(name, destination);
        }
    }


    function isResolverCached() external view returns (bool) {

        bytes32[] memory requiredAddresses = resolverAddressesRequired();
        for (uint i = 0; i < requiredAddresses.length; i++) {
            bytes32 name = requiredAddresses[i];
            if (resolver.getAddress(name) != addressCache[name] || addressCache[name] == address(0)) {
                return false;
            }
        }

        return true;
    }


    function requireAndGetAddress(bytes32 name) internal view returns (address) {

        address _foundAddress = addressCache[name];
        require(_foundAddress != address(0), string(abi.encodePacked("Missing address: ", name)));
        return _foundAddress;
    }


    event CacheUpdated(bytes32 name, address destination);
}






contract AddressResolver is Owned, IAddressResolver {

    mapping(bytes32 => address) public repository;

    constructor(address _owner) public Owned(_owner) {}


    function importAddresses(bytes32[] calldata names, address[] calldata destinations) external onlyOwner {

        require(names.length == destinations.length, "Input lengths must match");

        for (uint i = 0; i < names.length; i++) {
            bytes32 name = names[i];
            address destination = destinations[i];
            repository[name] = destination;
            emit AddressImported(name, destination);
        }
    }


    function rebuildCaches(MixinResolver[] calldata destinations) external {

        for (uint i = 0; i < destinations.length; i++) {
            destinations[i].rebuildCache();
        }
    }


    function areAddressesImported(bytes32[] calldata names, address[] calldata destinations) external view returns (bool) {

        for (uint i = 0; i < names.length; i++) {
            if (repository[names[i]] != destinations[i]) {
                return false;
            }
        }
        return true;
    }

    function getAddress(bytes32 name) external view returns (address) {

        return repository[name];
    }

    function requireAndGetAddress(bytes32 name, string calldata reason) external view returns (address) {

        address _foundAddress = repository[name];
        require(_foundAddress != address(0), reason);
        return _foundAddress;
    }

    function getPynth(bytes32 key) external view returns (address) {

        IIssuer issuer = IIssuer(repository["Issuer"]);
        require(address(issuer) != address(0), "Cannot find Issuer address");
        return address(issuer.pynths(key));
    }


    event AddressImported(bytes32 name, address destination);
}