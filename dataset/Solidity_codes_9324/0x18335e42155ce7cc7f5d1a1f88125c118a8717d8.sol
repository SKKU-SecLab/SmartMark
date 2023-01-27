
pragma solidity ^0.4.23;


interface ContractManagerInterface {

  event ContractAdded(address indexed _address, string _contractName);

  event ContractRemoved(string _contractName);

  event ContractUpdated(address indexed _oldAddress, address indexed _newAddress, string _contractName);

  event AuthorizationChanged(address indexed _address, bool _authorized, string _contractName);

  function authorize(string _contractName, address _accessor) external view returns (bool);


  function addContract(string _contractName, address _address) external;


  function getContract(string _contractName) external view returns (address _contractAddress);


  function removeContract(string _contractName) external;


  function updateContract(string _contractName, address _newAddress) external;


  function setAuthorizedContract(string _contractName, address _authorizedAddress, bool _authorized) external;

}


interface MemberManagerInterface {

  event MemberAdded(address indexed member);

  event MemberRemoved(address indexed member);

  event TokensBought(address indexed member, uint256 tokensBought, uint256 tokens);

  function removeMember(address _member) external;


  function addAmountBoughtAsMember(address _member, uint256 _amountBought) external;

}


library SafeMath {


  function mul(uint256 a, uint256 b) internal pure returns (uint256) {

    if (a == 0) {
      return 0;
    }
    uint256 c = a * b;
    assert(c / a == b);
    return c;
  }

  function div(uint256 a, uint256 b) internal pure returns (uint256) {

    uint256 c = a / b;
    return c;
  }

  function sub(uint256 a, uint256 b) internal pure returns (uint256) {

    assert(b <= a);
    return a - b;
  }

  function add(uint256 a, uint256 b) internal pure returns (uint256) {

    uint256 c = a + b;
    assert(c >= a);
    return c;
  }
}


contract MemberManager is MemberManagerInterface {

  using SafeMath for uint256;
  
  mapping(address => bool) public members;
  mapping(address => uint256) public bought;
  address[] public memberKeys;

  string public contractName;
  ContractManagerInterface internal contractManager;

  event MemberAdded(address indexed member);

  event MemberRemoved(address indexed member);

  event TokensBought(address indexed member, uint256 tokensBought, uint256 tokens);

  constructor(string _contractName, address _contractManager) public {
    contractName = _contractName;
    contractManager = ContractManagerInterface(_contractManager);
  }

  function _addMember(address _member) internal {

    require(contractManager.authorize(contractName, msg.sender));

    members[_member] = true;
    memberKeys.push(_member);

    emit MemberAdded(_member);
  }

  function removeMember(address _member) external {

    require(contractManager.authorize(contractName, msg.sender));
    require(members[_member] == true);

    delete members[_member];

    for (uint256 i = 0; i < memberKeys.length; i++) {
      if (memberKeys[i] == _member) {
        delete memberKeys[i];
        break;
      }
    }

    emit MemberRemoved(_member);
  }

  function addAmountBoughtAsMember(address _member, uint256 _amountBought) external {

    require(contractManager.authorize(contractName, msg.sender));
    require(_amountBought != 0);

    if(!members[_member]) {
      _addMember(_member);
    }

    bought[_member] = bought[_member].add(_amountBought);

    emit TokensBought(_member, _amountBought, bought[_member]);
  }
}