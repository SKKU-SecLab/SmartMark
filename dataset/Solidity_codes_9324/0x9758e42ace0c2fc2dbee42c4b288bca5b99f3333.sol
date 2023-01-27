
pragma solidity ^0.4.25;

interface IERC20 {

    function totalSupply() external view returns (uint256);

    function balanceOf(address who) external view returns (uint256);

    function allowance(address owner, address spender) external view returns (uint256);


    function transfer(address to, uint256 value) external returns (bool);

    function approve(address spender, uint256 value) external returns (bool);

    function transferFrom(address from, address to, uint256 value) external returns (bool);


    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

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

        require(b > 0);
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

contract Ownable {

    address public owner;


    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);


    constructor() public {
        owner = msg.sender;
    }


    modifier onlyOwner() {

        require(msg.sender == owner);
        _;
    }


    function transferOwnership(address newOwner) onlyOwner public {

        require(newOwner != address(0));
        emit OwnershipTransferred(owner, newOwner);
        owner = newOwner;
    }

}

contract FNXDistribution is Ownable {


    IERC20 public token;
    
    uint internal decimal = 18;

    constructor () public { }

    function setup(address _token) public onlyOwner {

        require(_token != address(0));
        token = IERC20(_token);
    }
    
    function bulkApprovedTransfer(address[] _users, uint256[] _value) public onlyOwner returns (bool) {

        require(token.balanceOf(address(this)) > 0);

        for (uint i = 0; i < _users.length; i++) {
            token.transferFrom(msg.sender, _users[i], _value[i]);
        }
    }    
    
    function bulkTransfer(address[] _users, uint256[] _value) public onlyOwner returns (bool) {

        require(token.balanceOf(address(this)) > 0);

        for (uint i = 0; i < _users.length; i++) {
            token.transfer(_users[i], _value[i]);
        }
    }

    function tokenWithdrawal() public onlyOwner returns (bool) {

        return token.transfer(owner, contractTokenBalance());
    }

    function contractTokenBalance() view public returns (uint) {

        return token.balanceOf(address(this));
    }

}