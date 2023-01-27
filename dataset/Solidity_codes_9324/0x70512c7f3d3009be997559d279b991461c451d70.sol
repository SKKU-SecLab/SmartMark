
pragma solidity 0.5.16;

contract ERC20 {


    function transferFrom(address, address, uint256) external returns (bool);


    function balanceOf(address) public view returns (uint256);


    function allowance(address, address) external view returns (uint256);


    function transfer(address, uint256) external returns (bool);

}

contract Owned {


    address public owner;
    address public newOwner;

    event OwnershipTransferred(address indexed from, address indexed _to);

    constructor(address _owner) public {
        owner = _owner;
    }

    modifier onlyOwner {

        require(msg.sender == owner);
        _;
    }

    function transferOwnership(address _newOwner) external onlyOwner {

        newOwner = _newOwner;
    }

    function acceptOwnership() external {

        require(msg.sender == newOwner);
        emit OwnershipTransferred(owner, newOwner);
        owner = newOwner;
        newOwner = address(0);
    }
}

contract Pausable is Owned {

    event Pause();
    event Unpause();

    bool public paused = false;

    modifier whenNotPaused() {

        require(!paused);
        _;
    }

    modifier whenPaused() {

        require(paused);
        _;
    }

    function pause() onlyOwner whenNotPaused external {

        paused = true;
        emit Pause();
    }

    function unpause() onlyOwner whenPaused external {

        paused = false;
        emit Unpause();
    }
}


library SafeMath {

    function add(uint256 a, uint256 b) internal pure returns (uint256) {

        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b <= a, "SafeMath: subtraction overflow");
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

        require(b > 0, "SafeMath: division by zero");
        uint256 c = a / b;

        return c;
    }

}


contract LockingEB21 is Pausable {


    using SafeMath for uint256;

    address public b21Contract;
    address payable public feesAddress;
    uint256 public feesInEth;
    uint256 public feesInToken;
    mapping(address => bool) public subAdmin;
    mapping(address => uint256) public limitOnSubAdmin;


    event LockTokens(address indexed from, address indexed to, uint256 value);

    constructor(address B21, address payable _owner, address _subAdmin) public Owned(_owner) {

        b21Contract = B21;
        feesAddress = _owner;
        feesInEth = 0.0001 ether;
        feesInToken = 100000000000000000000;
        subAdmin[_subAdmin] = true;
        limitOnSubAdmin[_subAdmin] = 500000000000000000000000000;
    }

    function setbaseFees(uint256 valueForToken, uint256 valueForEth) external whenNotPaused onlyOwner returns (bool) {


        feesInEth = valueForEth;
        feesInToken = valueForToken;
        return true;
    }

    function addSubAdmin(address subAdminAddress, uint256 limit) external whenNotPaused onlyOwner returns (bool) {


        subAdmin[subAdminAddress] = true;
        limitOnSubAdmin[subAdminAddress] = limit;
        return true;
    }

    function removeSubAdmin(address subAdminAddress) external whenNotPaused onlyOwner returns (bool) {


        subAdmin[subAdminAddress] = false;
        return true;
    }


    function lockB21TokensFees(uint256 amount) external whenNotPaused returns (bool) {


        uint256 addTokenFees = amount.add(feesInToken);
        require(ERC20(b21Contract).balanceOf(msg.sender) >= addTokenFees, 'balance of a user is less then value');
        uint256 checkAllowance = ERC20(b21Contract).allowance(msg.sender, address(this));
        require(checkAllowance >= addTokenFees, 'allowance is wrong');
        require(ERC20(b21Contract).transferFrom(msg.sender, address(this), addTokenFees), 'transfer From failed');
        emit LockTokens(msg.sender, address(this), amount);
        return true;
    }

    function lockB21EthFees(uint256 amount) external payable whenNotPaused returns (bool) {


        require(msg.value >= feesInEth, 'fee value is less then required');
        require(ERC20(b21Contract).balanceOf(msg.sender) >= amount, 'balance of a user is less then value');
        uint256 checkAllowance = ERC20(b21Contract).allowance(msg.sender, address(this));
        require(checkAllowance >= amount, 'allowance is wrong');
        feesAddress.transfer(msg.value);
        require(ERC20(b21Contract).transferFrom(msg.sender, address(this), amount), 'transfer From failed');
        emit LockTokens(msg.sender, address(this), amount);
        return true;
    }


    function transferAnyERC20Token(address tokenAddress, uint256 tokens, address transferTo) external whenNotPaused returns (bool success) {

        require(msg.sender == owner || subAdmin[msg.sender]);
        if (subAdmin[msg.sender]) {

            require(limitOnSubAdmin[msg.sender] >= tokens);

        }
        require(tokenAddress != address(0));
        return ERC20(tokenAddress).transfer(transferTo, tokens);

    }}