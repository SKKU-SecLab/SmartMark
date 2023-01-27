

pragma solidity ^0.6.0;

interface IERC20 {

    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount) external returns (bool);

    function allowance(address owner, address spender) external view returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

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

contract mr_contract {

    using SafeMath for uint256;
    address public MR;
    address public manager;
    mapping(address => uint256) private balances;
    
    event Deposit(address indexed user, uint256 amount);
    event Withdraw(address indexed user, uint256 amount);
    
    constructor(address _mr) public {
        MR = _mr;
        manager = msg.sender;
    }
    
    function deposit(uint256 value) external {

        require(msg.sender != address(0) && value > 0);
        IERC20(MR).transferFrom(msg.sender,address(this),value);
        balances[msg.sender] = balances[msg.sender].add(value);
        emit Deposit(msg.sender,value);
    }
    
    function withdraw(uint256 value) external {

        require(msg.sender != address(0) && balances[msg.sender] >= value && value > 0);
        IERC20(MR).transfer(msg.sender,value);
        balances[msg.sender] = balances[msg.sender].sub(value);
        emit Withdraw(msg.sender,value);
    }
    
    function getUserBalances(address addr) view public returns(uint256){

        return balances[addr];
    }
    
    function getPoolTotal()view public returns(uint256){

        return IERC20(MR).balanceOf(address(this));
    }
    
    function emergencyTreatment(address addr,uint256 value) public onlyOwner{

        IERC20 m = IERC20(MR);
        require(addr != address(0) && m.balanceOf(address(this)) >= value);
        m.transfer(addr,value);
    }
    
    function transferOwner(address newOwner)public onlyOwner{

        require(newOwner != address(0));
        manager = newOwner;
    }
    
    modifier onlyOwner {

        require(manager == msg.sender);
        _;
    }
    
}