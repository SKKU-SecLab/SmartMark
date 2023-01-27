
pragma solidity ^0.5.0;

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









contract ERC20Detailed is IERC20 {

    string private _name;
    string private _symbol;
    uint8 private _decimals;

    constructor (string memory name, string memory symbol, uint8 decimals) public {
        _name = name;
        _symbol = symbol;
        _decimals = decimals;
    }

    function name() public view returns (string memory) {

        return _name;
    }

    function symbol() public view returns (string memory) {

        return _symbol;
    }

    function decimals() public view returns (uint8) {

        return _decimals;
    }
}





contract Context {

    constructor () internal { }

    function _msgSender() internal view returns (address payable) {

        return msg.sender;
    }

    function _msgData() internal view returns (bytes memory) {

        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
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


contract ERC20 is Context, IERC20 {

    using SafeMath for uint256;

    mapping (address => uint256) private _balances;

    mapping (address => mapping (address => uint256)) private _allowances;

    uint256 private _totalSupply;

    function totalSupply() public view returns (uint256) {

        return _totalSupply;
    }

    function balanceOf(address account) public view returns (uint256) {

        return _balances[account];
    }

    function transfer(address recipient, uint256 amount) public returns (bool) {

        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function allowance(address owner, address spender) public view returns (uint256) {

        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public returns (bool) {

        _approve(_msgSender(), spender, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) public returns (bool) {

        _transfer(sender, recipient, amount);
        _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount, "ERC20: transfer amount exceeds allowance"));
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public returns (bool) {

        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].add(addedValue));
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public returns (bool) {

        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].sub(subtractedValue, "ERC20: decreased allowance below zero"));
        return true;
    }

    function _transfer(address sender, address recipient, uint256 amount) internal {

        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        _balances[sender] = _balances[sender].sub(amount, "ERC20: transfer amount exceeds balance");
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
    }

    function _mint(address account, uint256 amount) internal {

        require(account != address(0), "ERC20: mint to the zero address");

        _totalSupply = _totalSupply.add(amount);
        _balances[account] = _balances[account].add(amount);
        emit Transfer(address(0), account, amount);
    }

    function _burn(address account, uint256 amount) internal {

        require(account != address(0), "ERC20: burn from the zero address");

        _balances[account] = _balances[account].sub(amount, "ERC20: burn amount exceeds balance");
        _totalSupply = _totalSupply.sub(amount);
        emit Transfer(account, address(0), amount);
    }

    function _approve(address owner, address spender, uint256 amount) internal {

        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _burnFrom(address account, uint256 amount) internal {

        _burn(account, amount);
        _approve(account, _msgSender(), _allowances[account][_msgSender()].sub(amount, "ERC20: burn amount exceeds allowance"));
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

        require(isOwner(), "Ownable: caller is not the owner");
        _;
    }

    function isOwner() public view returns (bool) {

        return _msgSender() == _owner;
    }

    function renounceOwnership() public onlyOwner {

        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    function transferOwnership(address newOwner) public onlyOwner {

        _transferOwnership(newOwner);
    }

    function _transferOwnership(address newOwner) internal {

        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}


contract KiiAToken is ERC20, ERC20Detailed, Ownable {


    uint256 private tokenSaleRatio        = 50;
    uint256 private foundersRatio         = 10;
    uint256 private marketingRatio        = 40;
    uint256 private foundersplit          = 20; 

    constructor(
        string  memory _name, 
        string  memory _symbol, 
        uint8   _decimals,
        address _founder1,
        address _founder2,
        address _founder3,
        address _founder4,
        address _founder5,
        address _marketing,
        address _publicsale,
        uint256 _initialSupply
        )
        ERC20Detailed(_name, _symbol, _decimals)
        public
    {
        uint256 tempInitialSupply = _initialSupply * (10 ** uint256(_decimals));

        uint256 publicSupply = tempInitialSupply.mul(tokenSaleRatio).div(100);
        uint256 marketingSupply = tempInitialSupply.mul(marketingRatio).div(100);
        uint256 tempfounderSupply   = tempInitialSupply.mul(foundersRatio).div(100);
        uint256 founderSupply   = tempfounderSupply.mul(foundersplit).div(100);

        _mint(_publicsale, publicSupply);
        _mint(_marketing, marketingSupply);
        _mint(_founder1, founderSupply);
        _mint(_founder2, founderSupply);
        _mint(_founder3, founderSupply);
        _mint(_founder4, founderSupply);
        _mint(_founder5, founderSupply);

    }

}

contract KiiABulkTransfer{


    address public owner;
    KiiAToken public kiiaToken;

    constructor(KiiAToken _kiiaToken,address ownerAddr) public {
        kiiaToken = _kiiaToken;
        owner = ownerAddr;
    }

    function addEth() public payable {

        require(msg.sender == owner, "caller must be the owner");
    }

    function bulksendEther(address payable[] memory _to, uint256[] memory _values) public payable{

        ethSendDifferentValue(_to, _values);
    }

    function ethSendDifferentValue(address payable[] memory _to, uint[] memory _value) internal {

        require(msg.sender == owner, "caller must be the owner");
        uint remainingValue = msg.value;
        require(_to.length == _value.length);
        require(_to.length <= 255);
        for (uint8 i = 0; i < _to.length; i++) {
            remainingValue = remainingValue - _value[i];
            require(_to[i].send(_value[i]));
        }
    }

    function bulksendToken(address[] memory _to, uint256[] memory _values) public  {

        require(msg.sender == owner, "caller must be the owner");
        require(_to.length == _values.length);
        require(_to.length <= 255);
        for (uint256 i = 0; i < _to.length; i++) {
           kiiaToken.transfer(_to[i], _values[i]);
        }
    }

    function withdrawToken(uint256 _amount) public {

        require(msg.sender == owner, "caller must be the owner");
        require(_amount>0,"Withdrawal amout cannot be 0");
        kiiaToken.transfer(msg.sender, _amount);
     }

    function withdrawEth(uint256 _amount) public {

        require(msg.sender == owner, "caller must be the owner");
        require(_amount>0,"Withdrawal amout cannot be 0");
        require(_amount <= getBalance(), "Cannot withdraw greater than available balance");
        msg.sender.transfer(_amount); 
     }

    function getBalance() public view returns (uint256) {

         return address(this).balance;
    }

}