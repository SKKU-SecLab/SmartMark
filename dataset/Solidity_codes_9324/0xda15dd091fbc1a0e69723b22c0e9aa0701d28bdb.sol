
pragma solidity ^0.4.23;

library SafeMath {


  function mul(uint256 a, uint256 b) internal pure returns (uint256) {

    if (a == 0) {
      return 0;
    }

    uint256 c = a * b;
    require(c / a == b);

    return c;
  }

  function div(uint256 a, uint256 b) internal pure returns (uint256) {

    require(b > 0); // Solidity only automatically asserts when dividing by 0
    uint256 c = a / b;

    return c;
  }

  function sub(uint256 a, uint256 b) internal pure returns (uint256) {

    require(b <= a);
    uint256 c = a - b;

    return c;
  }

  function add(uint256 a, uint256 b) internal pure returns (uint256) {

    uint256 c = a + b;
    require(c >= a);

    return c;
  }

  function mod(uint256 a, uint256 b) internal pure returns (uint256) {

    require(b != 0);
    return a % b;
  }
}

contract MultiEthSender {

    using SafeMath for uint256;
    address public owner;

    event Send(uint256 _amount, address indexed _receiver);

    modifier onlyOwner () {

        if (msg.sender == owner) _;
    }

    constructor () public {
        owner = msg.sender;
    }

    function multiSendEth(uint256 amount, address[] list) public payable onlyOwner returns (bool) {

        uint256 balance = address(this).balance;
        uint256 total = amount.mul(uint256(list.length));
        if (total > balance) {
            return false;
        }
        for (uint i = 0; i < list.length; i++) {
            list[i].transfer(amount);
            bytes32 _id = 0x5ce4017cdf5be6a02f39ba5d91777cf13a304b9e024d038bca26189d148feeb9;
            log2(
                bytes32(amount),
                _id,
                bytes32(list[i])
            );
        }
        return true;
    }

    function () public payable {}
}