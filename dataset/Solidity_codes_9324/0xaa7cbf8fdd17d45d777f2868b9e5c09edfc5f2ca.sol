


pragma solidity >=0.6.0 <0.8.0;

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

pragma solidity ^0.7.5;


contract EtherFund {

    using SafeMath for uint256;
    
    address public owner; // Fund owner - can use transferFrom
    
    mapping(address => uint256) public balanceOf; 
    
    event Deposit(address founder, uint256 amount);
    event Withdraw(address funder, uint256 amount);
    
    constructor ()  {
        owner = msg.sender;
    }
    
    receive () external payable {
        _deposit(msg.sender, msg.value);
    }
    
    function deposit() external payable {

        _deposit(msg.sender, msg.value);
    }
    
    function withdraw(uint256 _amount) external returns (bool success) {

        balanceOf[msg.sender] = balanceOf[msg.sender].sub(_amount, "Withdraw amount exceeds balance!");
        payable(address(msg.sender)).transfer(_amount);
        emit Withdraw(msg.sender, _amount);
        return true;
    }
    
    function transfer(address _recipient, uint256 _amount) external returns (bool success) {

        _transfer(msg.sender, _recipient, _amount);
        return true;
    } 
    
    function transferFrom(address _sender, address _recipient, uint256 _amount) external {

        require(msg.sender == owner, "Only fund owner can do this!");
        _transfer(_sender, _recipient, _amount);
    }
    
    function _deposit(address _funder, uint256 _amount) internal {

        balanceOf[_funder] = balanceOf[_funder].add(_amount);
        emit Deposit(_funder, _amount);
    }
    

    function _transfer(address _sender, address _recipient, uint256 _amount) internal  {

        require(_sender != address(0), "Transfer from the zero address");
        require(_recipient != address(0), "Transfer to the zero address");

        balanceOf[_sender] = balanceOf[_sender].sub(_amount, "Transfer amount exceeds balance");
        balanceOf[_recipient] = balanceOf[_recipient].add(_amount);
    }
    
    function getFundBalance() public view returns (uint256 fund) {

        return address(this).balance;
    }
       
    
}