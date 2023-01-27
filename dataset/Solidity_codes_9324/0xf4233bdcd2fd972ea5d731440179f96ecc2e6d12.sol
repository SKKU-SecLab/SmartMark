
pragma solidity ^0.4.24;

contract ERC20Basic {

  function totalSupply() public view returns (uint256);

  function balanceOf(address _who) public view returns (uint256);

  function transfer(address _to, uint256 _value) public returns (bool);

  event Transfer(address indexed from, address indexed to, uint256 value);
}

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

contract ERC223Receiver {

  function tokenFallback(address _sender, uint _value, bytes _data) external returns (bool ok);

}

contract GetExpertPayment is ERC223Receiver, Ownable {


  address public tokenContract;
  uint256[][] public payments;

  event TokenFallback(uint256 userId, uint256 value);

  constructor(address _tokenContract) public Ownable() {
    tokenContract = _tokenContract;
  }

  function tokenFallback(address _sender, uint256 _value, bytes _extraData) external returns (bool ok) {

    require(msg.sender == tokenContract);
    uint256 userId = convertData(_extraData);
    payments.push([userId, _value]);
    emit TokenFallback(userId, _value);
    return true;
  }

  function convertData(bytes _data) internal pure returns (uint256) {

    uint256 payloadSize;
    uint256 payload;
    assembly {
      payloadSize := mload(_data)
      payload := mload(add(_data, 0x20))
    }
    payload = payload >> 8*(32 - payloadSize);
    return payload;
  }

  function getPaymentsLength() public constant returns (uint256) {

    return payments.length;
  }

   function getPayment(uint256 i) public constant returns (uint256[]) {

     return payments[i];
   }

  function withdrawal() public onlyOwner returns (bool) {

    ERC20Basic token = ERC20Basic(tokenContract);
    uint256 balance = token.balanceOf(this);
    token.transfer(msg.sender, balance);
    return true;
  }
}