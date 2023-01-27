
pragma solidity 0.5.11;

contract MultiSendETH {

  using SafeMath for uint256;

  function multiSendEth(address payable[] memory addresses, uint256[] memory amounts) public payable {

    require(getTotal(addresses,amounts) <= msg.value, "invalid amount");
    for(uint i = 0; i < addresses.length; i++) {
        require(addresses[i] != address(0x0), "invalid address");
        addresses[i].transfer(amounts[i]);
    }
    msg.sender.transfer(address(this).balance);
  }
  
   function getTotal(address payable[] memory addresses, uint256[] memory amounts)  public pure returns (uint256) {

    require(addresses.length == amounts.length, "list missmatch input");
    uint256 total;
    for(uint i = 0; i < amounts.length; i++) {
      total = total.add(amounts[i]);
    }
    return total;
  }
    
}


library SafeMath {

    function add(uint256 a, uint256 b) internal pure returns (uint256) {

        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {

        return sub(a, b, "SafeMath: subtraction overflow");
    }

    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        require(b <= a, errorMessage);
        uint256 c = a - b;

        return c;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {

        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {

        return div(a, b, "SafeMath: division by zero");
    }

    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        require(b > 0, errorMessage);
        uint256 c = a / b;

        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {

        return mod(a, b, "SafeMath: modulo by zero");
    }

    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        require(b != 0, errorMessage);
        return a % b;
    }
}