
pragma solidity ^0.4.23;


contract Ownable {

  address public owner;


  event OwnershipRenounced(address indexed previousOwner);
  event OwnershipTransferred(
    address indexed previousOwner,
    address indexed newOwner
  );


  constructor() public {
    owner = msg.sender;
  }

  modifier onlyOwner() {

    require(msg.sender == owner);
    _;
  }

  function renounceOwnership() public onlyOwner {

    emit OwnershipRenounced(owner);
    owner = address(0);
  }

  function transferOwnership(address _newOwner) public onlyOwner {

    _transferOwnership(_newOwner);
  }

  function _transferOwnership(address _newOwner) internal {

    require(_newOwner != address(0));
    emit OwnershipTransferred(owner, _newOwner);
    owner = _newOwner;
  }
}

contract BBODServiceRegistry is Ownable {


  mapping(uint => address) public registry;

    constructor(address _owner) {
        owner = _owner;
    }

  function setServiceRegistryEntry (uint key, address entry) external onlyOwner {
    registry[key] = entry;
  }
}

contract CustodyStorage {


  BBODServiceRegistry public bbodServiceRegistry;

  mapping(address => bool) public custodiesMap;

  uint public custodyCounter = 0;

  address[] public custodiesArray;

  event CustodyRemoved(address indexed custody);

  constructor(address _serviceRegistryAddress) public {
    bbodServiceRegistry = BBODServiceRegistry(_serviceRegistryAddress);
  }

  modifier onlyManager() {

    require(msg.sender == bbodServiceRegistry.registry(1));
    _;
  }

  function addCustody(address _custody) external onlyManager {

    custodiesMap[_custody] = true;
    custodiesArray.push(_custody);
    custodyCounter++;
  }

  function removeCustody(address _custodyAddress, uint _arrayIndex) external onlyManager {

    require(custodiesArray[_arrayIndex] == _custodyAddress);

    if (_arrayIndex == custodyCounter - 1) {
      custodiesMap[_custodyAddress] = false;
      emit CustodyRemoved(_custodyAddress);
      custodyCounter--;
      return;
    }

    custodiesMap[_custodyAddress] = false;
    custodiesArray[_arrayIndex] = custodiesArray[custodyCounter - 1];
    custodyCounter--;

    emit CustodyRemoved(_custodyAddress);
  }
}