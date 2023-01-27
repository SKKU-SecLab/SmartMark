
pragma solidity ^0.4.21;


library SafeMath {


  function mul(uint256 a, uint256 b) internal pure returns (uint256 c) {

    if (a == 0) {
      return 0;
    }
    c = a * b;
    assert(c / a == b);
    return c;
  }

  function div(uint256 a, uint256 b) internal pure returns (uint256) {

    return a / b;
  }

  function sub(uint256 a, uint256 b) internal pure returns (uint256) {

    assert(b <= a);
    return a - b;
  }

  function add(uint256 a, uint256 b) internal pure returns (uint256 c) {

    c = a + b;
    assert(c >= a);
    return c;
  }
}


contract Ownable {

  address public owner;


  event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);


  function Ownable() public {

    owner = msg.sender;
  }

  modifier onlyOwner() {

    require(msg.sender == owner);
    _;
  }

  function transferOwnership(address newOwner) public onlyOwner {

    require(newOwner != address(0));
    emit OwnershipTransferred(owner, newOwner);
    owner = newOwner;
  }

}


contract MultiSend is Ownable {

  using SafeMath for uint;

  event Send(address _addr, uint _amount);
  event Fail(address _addr, uint _amount);

  function multiSend(address[] _addrs, uint _amount) external payable {

    require(_amount > 0);

    uint _totalToSend = _amount.mul(_addrs.length);
    require(msg.value >= _totalToSend);

    uint _totalSent = 0;
    for (uint256 i = 0; i < _addrs.length; i++) {
      require(_addrs[i] != address(0));
      if (_addrs[i].send(_amount)) {
        _totalSent = _totalSent.add(_amount);
      } else {
        emit Fail(_addrs[i], _amount);
      }
    }

    if (msg.value > _totalSent) {
      msg.sender.transfer(msg.value.sub(_totalSent));
    }
  }

  function splitSend(address[] _addrs) external payable {

    require(msg.value > 0);

    uint _amount = msg.value.div(_addrs.length);
    uint _totalSent = 0;
    for (uint256 i = 0; i < _addrs.length; i++) {
      require(_addrs[i] != address(0));
      if (_addrs[i].send(_amount)) {
        _totalSent = _totalSent.add(_amount);
      } else {
        emit Fail(_addrs[i], _amount);
      }
    }

    if (_totalSent != _amount.mul(_addrs.length)) {
      msg.sender.transfer(msg.value.sub(_totalSent));
    }
  }

  function ownerWithdraw() public onlyOwner {

    owner.transfer(address(this).balance);
  }
}