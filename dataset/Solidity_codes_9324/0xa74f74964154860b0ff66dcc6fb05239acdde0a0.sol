pragma solidity 0.7.5;

contract OwnedwManager {

    address public owner;
    address public manager;

    address public nominatedOwner;

    constructor(address _owner, address _manager) {
        require(_owner != address(0), "Owner address cannot be 0");
        owner = _owner;
        manager = _manager;
        emit OwnerChanged(address(0), _owner);
        emit ManagerChanged(_manager);
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

    modifier onlyManager {

        _onlyManager();
        _;
    }
    
    function _onlyOwner() private view {

        require(msg.sender == owner, "Only the contract owner may perform this action");
    }

    function _onlyManager() private view {

        require(msg.sender == manager, "Only the contract owner may perform this action");
    }

    function setManager(address _manager) external onlyOwner {

        manager = _manager;
        emit ManagerChanged(_manager);
    }

    event OwnerNominated(address newOwner);
    event OwnerChanged(address oldOwner, address newOwner);
    event ManagerChanged(address newManager);
}// AGPL-3.0-or-later
pragma solidity 0.7.5;
     
       
   abstract contract MixinResolver {
    AddressResolver public resolver;   
  
    mapping(bytes32 => address) private addressCache;

    constructor(address _resolver)  {
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
 

    function resolverAddressesRequired() public view virtual returns (bytes32[] memory addresses) {}

    function rebuildCache() public {
        bytes32[] memory requiredAddresses = resolverAddressesRequired();
        for (uint i = 0; i < requiredAddresses.length; i++) {
            bytes32 name = requiredAddresses[i];
            address destination =
                resolver.requireAndGetAddress(name, string(abi.encodePacked("Resolver missing target: ", name)));
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
}// AGPL-3.0-or-later
pragma solidity 0.7.5;

interface IAddressResolver {

    function getAddress(bytes32 name) external view returns (address);


    function getSynth(bytes32 key) external view returns (address);


    function requireAndGetAddress(bytes32 name, string calldata reason) external view returns (address);

}// AGPL-3.0-or-later
pragma solidity 0.7.5;

 
interface IMixinResolver_ {

    function rebuildCache() external;

}  

contract AddressResolver is   OwnedwManager, IAddressResolver {     

    mapping(bytes32 => address) public repository;

    constructor(address _owner) OwnedwManager(_owner, _owner)  {}
 

    function importAddresses(bytes32[] calldata names, address[] calldata destinations) external onlyOwner {

        require(names.length == destinations.length, "Input lengths must match");

        for (uint i = 0; i < names.length; i++) {
            bytes32 name = names[i];
            address destination = destinations[i];
            repository[name] = destination;
            emit AddressImported(name, destination);
        }
    }


    function rebuildCaches(address[] calldata destinations) external {

        for (uint i = 0; i < destinations.length; i++) {
            IMixinResolver_(destinations[i]).rebuildCache();
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

    function getAddress(bytes32 name) external override view returns (address) {

        return repository[name];
    }

    function requireAndGetAddress(bytes32 name, string calldata reason) external override view returns (address) {

        address _foundAddress = repository[name];
        require(_foundAddress != address(0), reason);
        return _foundAddress;
    }

    function getSynth(bytes32 key) external override view returns (address) {

    }


    event AddressImported(bytes32 name, address destination);
}