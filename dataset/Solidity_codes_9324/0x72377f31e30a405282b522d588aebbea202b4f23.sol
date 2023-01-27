
pragma solidity 0.8.4;

interface IERC20 {

    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);

    function totalSupply() external view returns (uint);

    function balanceOf(address account) external view returns (uint);

    function transfer(address recipient, uint amount) external returns (bool);

    function transferFrom(address sender, address recipient, uint amount) external returns (bool);

    function allowance(address owner, address spender) external view returns (uint);

    function approve(address spender, uint amount) external returns (bool);


    event Transfer(address indexed from, address indexed to, uint value);
    event Approval(address indexed owner, address indexed spender, uint value);
}

interface IERC677 is IERC20 {

    function transferAndCall(address recipient, uint amount, bytes memory data) external returns (bool success);

    
    event Transfer(address indexed from, address indexed to, uint value, bytes data);
}

interface IERC677Receiver {

    function onTokenTransfer(address sender, uint value, bytes memory data) external;

}

pragma solidity 0.8.4;

library SafeMath {

    function add(uint256 a, uint256 b) internal pure returns (uint256) {

        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");
        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b <= a, "SafeMath: subtraction overflow");
        return a - b;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {

        if (a == 0) return 0;
        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");
        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b > 0, "SafeMath: division by zero");
        return a / b;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b > 0, "SafeMath: modulo by zero");
        return a % b;
    }

    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        require(b <= a, errorMessage);
        return a - b;
    }

    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        require(b > 0, errorMessage);
        return a / b;
    }

    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        require(b > 0, errorMessage);
        return a % b;
    }
}// MIT


pragma solidity 0.8.4;


contract Varen is IERC677 {

    using SafeMath for uint256;
    
    string public constant override name = 'Varen';
    
    string public constant override symbol = 'VRN';
    
    uint8 public constant override decimals = 18;
    
    uint256 public constant override totalSupply = 88888e18;
    
    mapping (address => mapping (address => uint256)) private _allowances;
    
    mapping (address => uint256) private _balances;
    
    address private constant TREASURY = 0xE69A81b96FBF5Cb6CAe95d2cE5323Eff2bA0EAE4;
    
    constructor() {
        _balances[TREASURY] = totalSupply;
        emit Transfer(address(0), TREASURY, totalSupply);
    }
    
    function balanceOf(address account) public view override returns (uint256) {

        return _balances[account];
    }
    
    function allowance(address owner, address spender) public view override returns (uint256) {

        return _allowances[owner][spender];
    }
    
    function transfer(address recipient, uint256 amount) public override returns (bool) {

        _transfer(msg.sender, recipient, amount);
        return true;
    }
    
    
    function transferAndCall(address recipient, uint amount, bytes memory data) public override returns (bool) {

        _transfer(msg.sender, recipient, amount);
        emit Transfer(msg.sender, recipient, amount, data);
        
        if (_isContract(recipient)) {
          IERC677Receiver(recipient).onTokenTransfer(msg.sender, amount, data);
        }
        
        return true;
    }
    
    function transferFrom(address sender, address recipient, uint256 amount) public override returns (bool) {

        _transfer(sender, recipient, amount);
        _approve(sender, msg.sender, _allowances[sender][msg.sender].sub(amount, "amount exceeds allowance"));
        return true;
    }

    function approve(address spender, uint256 amount) public override returns (bool) {

        _approve(msg.sender, spender, amount);
        return true;
    }
    
    function increaseAllowance(address spender, uint256 addedValue) public returns (bool) {

        _approve(msg.sender, spender, _allowances[msg.sender][spender].add(addedValue));
        return true;
    }
    
    function decreaseAllowance(address spender, uint256 subtractedValue) public returns (bool) {

        _approve(msg.sender, spender, _allowances[msg.sender][spender].sub(subtractedValue, "decreased allowance below zero"));
        return true;
    }
    
    function _transfer(address sender, address recipient, uint256 amount) private {

        _balances[sender] = _balances[sender].sub(amount, "amount exceeds balance");
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
    }
    
    function _approve(address owner, address spender, uint256 amount) private {

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _isContract(address addr) private view returns (bool) {

        uint256 length;
        assembly { length := extcodesize(addr) }
        return length > 0;
    }
}
