

pragma solidity ^0.6.0;



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



abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}




contract Ownable is Context {

    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor () internal {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    function owner() public view returns (address) {

        return _owner;
    }

    modifier onlyOwner() {

        require(_owner == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {

        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {

        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}






contract DerivativeFinanceTokenV0 is Ownable {

    using SafeMath for uint256;

    uint256 public totalSupply;
    mapping (address => uint256) public balanceOf;
    mapping (address => mapping (address => uint256)) public  allowance;
    bytes32 public  symbol = "DFT";
    uint256 public  decimals = 8;
    bytes32 public  name = "Derivative Finance Token";
    address public  foodbank;

    constructor(address chef, address _foodbank) Ownable() public {
        totalSupply = 1000000*10^8;
        balanceOf[chef] = 1000000*10^8;
        foodbank = _foodbank;
    }

    event Approval(address indexed owner, address indexed spender, uint256 amount);
    event Transfer(address indexed from, address indexed to, uint256 amount);
    event Burn(uint256 amount);
    
    function approve(address spender) external returns (bool) {

        return approve(spender, uint256(-1));
    }

    function approve(address spender, uint256 amount) public returns (bool) {

        allowance[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }

    function transfer(address to, uint256 amount) external returns (bool) {

        return transferFrom(msg.sender, to, amount);
    } 

    function transferFrom(address sender, address recipient, uint256 amount) public returns (bool) {

        
        if (sender != msg.sender && allowance[sender][msg.sender] != uint256(-1)) {
            require(allowance[sender][msg.sender] >= amount, "token-insufficient-approval");
            allowance[sender][msg.sender] = allowance[sender][msg.sender].sub(amount);
        }

        require(balanceOf[sender] >= amount, "token-insufficient-balance");
        balanceOf[sender] = balanceOf[sender].sub(amount);
        uint256 one = amount / 100;
        uint256 half = one / 2;
        uint256 fAmount = amount.sub(one);
        balanceOf[recipient] = balanceOf[recipient].add(fAmount);
        balanceOf[foodbank] = balanceOf[foodbank].add(half);
        burn(half);
        emit Transfer(sender, recipient, amount);
        return true;
    }

    function burn(uint256 amount) internal {

        totalSupply = totalSupply.sub(amount);
        emit Burn(amount);
    }

    function setFoodbank(address _foodbank) public onlyOwner {

        foodbank = _foodbank;
    }
}