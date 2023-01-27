
pragma solidity ^0.5.0;

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

contract CrowdSale {

  address public owner;
  function getOwner() public view returns(address) {

    return owner;
  }
}

contract CrowdsaleToken {

    using SafeMath for uint256;
    string public constant name = 'Rocketclock';
    string public constant symbol = 'RCLK';
    address payable owner;
    address payable contractaddress;
    uint256 public constant totalSupply = 1000;

    mapping (address => uint256) public balanceOf;

    event Transfer(address payable indexed from, address payable indexed to, uint256 value);

    modifier onlyOwner() {

        if (msg.sender != owner) {
            revert();
        }
        _;
    }

    constructor() public{
        contractaddress = address(this);
        owner = msg.sender;
        balanceOf[owner] = totalSupply;

    }

    function _transfer(address payable _from, address payable _to, uint256 _value) internal {

        require (_to != address(0x0));                      // Prevent transfer to 0x0 address. Use burn() instead
        require (balanceOf[_from] > _value);                // Check if the sender has enough
        require (balanceOf[_to].add(_value) > balanceOf[_to]); // Check for overflows
        balanceOf[_from] = balanceOf[_from].sub(_value);    // Subtract from the sender
        balanceOf[_to] = balanceOf[_to].add(_value);        // Add the same to the recipient
        emit Transfer(_from, _to, _value);
    }

    function transfer(address payable _to, uint256 _value) public returns (bool success) {


        _transfer(msg.sender, _to, _value);
        return true;

    }

    function crownfundTokenBalanceToOwner(address payable _from) public onlyOwner returns (bool success) {

      CrowdSale c = CrowdSale(_from);
      address crowdsaleOwner = c.getOwner();
      if (crowdsaleOwner == owner ) {
        uint256 _value = balanceOf[_from];
        balanceOf[_from] = 0;
        balanceOf[owner] = balanceOf[owner].add(_value);
        emit Transfer(_from, owner, _value);
        return true;
      }
      else{
        return false;
      }

    }

    function () external payable onlyOwner{}


    function getBalance(address addr) public view returns(uint256) {

      return balanceOf[addr];
    }

    function getEtherBalance() public view returns(uint256) {

      return address(this).balance;
    }

    function getOwner() public view returns(address) {

      return owner;
    }

}