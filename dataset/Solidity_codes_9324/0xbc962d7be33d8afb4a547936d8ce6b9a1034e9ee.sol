

pragma solidity ^0.6.6;

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

library Address {

    function isContract(address account) internal view returns (bool) {


        uint256 size;
        assembly { size := extcodesize(account) }
        return size > 0;
    }
}

interface IERC20 {

  function totalSupply() external view returns (uint256);


  function balanceOf(address account) external view returns (uint256);


  function transfer(address recipient, uint256 amount) external returns (bool);


  function allowance(address owner, address spender)
    external
    view
    returns (uint256);


  function approve(address spender, uint256 amount) external returns (bool);


  function transferFrom(
    address sender,
    address recipient,
    uint256 amount
  ) external returns (bool);


  event Transfer(address indexed from, address indexed to, uint256 value);

  event Approval(address indexed owner, address indexed spender, uint256 value);
}

contract Multiplier{

    using SafeMath for uint;
    
    IERC20 private _token;
    
    struct User {
        uint balance;
        uint release;
        address approved;
    }
    
    mapping(address => User) private _users;
    
    uint private constant _MULTIPLIER_CEILING = 2;
    
    event Deposited(address indexed user, uint amount);
    event Withdrawn(address indexed user, uint amount, uint time);
    event NewLockup(address indexed poolstake, address indexed user, uint lockup);
    event ContractApproved(address indexed user, address contractAddress);
    
    constructor(address token) public {
        require(token != address(0), "token must not be the zero address");
        _token = IERC20(token);
    }

    function deposit(uint _amount) external returns(bool) {

        
        require(_amount > 0, "amount must be larger than zero");
        
        require(_token.transferFrom(msg.sender, address(this), _amount), "amount must be approved");
        _users[msg.sender].balance = balance(msg.sender).add(_amount);
        
        emit Deposited(msg.sender, _amount);
        return true;
    }
    
    function approveContract(address _traditional) external returns(bool) {

        
        require(_users[msg.sender].approved != _traditional, "already approved");
        require(Address.isContract(_traditional), "can only approve a contract");
        
        _users[msg.sender].approved = _traditional;
        
        emit ContractApproved(msg.sender, _traditional);
        return true;
    } 
    
    function withdraw(uint _amount) external returns(bool) {

        
        require(now >= _users[msg.sender].release, "must wait for release");
        require(_amount > 0, "amount must be larger than zero");
        require(balance(msg.sender) >= _amount, "must have a sufficient balance");
        
        _users[msg.sender].balance = balance(msg.sender).sub(_amount);
        require(_token.transfer(msg.sender, _amount), "token transfer failed");
        
        emit Withdrawn(msg.sender, _amount, now);
        return true;
    }
    
    function updateLockupPeriod(address _user, uint _lockup) external returns(bool) {

        
        require(Address.isContract(msg.sender), "only a smart contract can call");
        require(_users[_user].approved == msg.sender, "contract is not approved");
        require(now.add(_lockup) > _users[_user].release, "cannot reduce current lockup");
        
        _users[_user].release = now.add(_lockup);
        
        emit NewLockup(msg.sender, _user, _lockup);
        return true;
    }
    
    function getMultiplierCeiling() external pure returns(uint) {

        
        return _MULTIPLIER_CEILING;
    }

    function balance(address _user) public view returns(uint) {

        
        return _users[_user].balance;
    }
    
    function approvedContract(address _user) external view returns(address) {

        
        return _users[_user].approved;
    }
    
    function lockupPeriod(address _user) external view returns(uint) {

        
        uint release = _users[_user].release;
        if (release > now) return (release.sub(now));
        else return 0;
    }
}