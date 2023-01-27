


pragma solidity ^0.7.4;

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


pragma solidity ^0.7.4;

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


pragma solidity ^0.7.4;

contract ERC20 is IERC20 {

    using SafeMath for uint256;

    mapping (address => uint256) private _balances;

    mapping (address => mapping (address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;
    uint8 private _decimals;
    
    address private _owner;
    bool private _locked = false;
    bool private _lockFixed = false;
    address private _saleContract = address(0);

    constructor (string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
        _decimals = 18;
        _owner = msg.sender;  //added by CryptoTask
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

    function totalSupply() public view override returns (uint256) {

        return _totalSupply;
    }

    function balanceOf(address account) public view override returns (uint256) {

        return _balances[account];
    }

    function transfer(address recipient, uint256 amount) public virtual override returns (bool) {

        require(!_locked || msg.sender == _saleContract, "Transfers locked"); //added by CryptoTask
        _transfer(msg.sender, recipient, amount);
        return true;
    }

    function allowance(address owner, address spender) public view virtual override returns (uint256) {

        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public virtual override returns (bool) {

        _approve(msg.sender, spender, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) public virtual override returns (bool) {

        require(!_locked, "Transfers locked");  //added by CryptoTask
        _transfer(sender, recipient, amount);
        _approve(sender, msg.sender, _allowances[sender][msg.sender].sub(amount, "ERC20: transfer amount exceeds allowance"));
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {

        _approve(msg.sender, spender, _allowances[msg.sender][spender].add(addedValue));
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {

        _approve(msg.sender, spender, _allowances[msg.sender][spender].sub(subtractedValue, "ERC20: decreased allowance below zero"));
        return true;
    }
    
    
    function setSaleContract(address saleContract) public {

        require(msg.sender == _owner && _saleContract == address(0), "Caller must be owner and _saleContract yet unset");
        _saleContract = saleContract;
    }
    
    function lockTransfers() public {

        require(msg.sender == _owner && !_lockFixed, "Caller must be owner and _lockFixed false");
        _locked = true;
    }
    
    function unlockTransfers() public {

        require(msg.sender == _owner && !_lockFixed, "Caller must be owner and _lockFixed false");
        _locked = false;
    }
    
    function unlockTransfersPermanent() public {

        require(msg.sender == _owner && !_lockFixed, "Caller must be owner and _lockFixed false");
        _locked = false;
        _lockFixed = true;
    }
    

    function _transfer(address sender, address recipient, uint256 amount) internal virtual {

        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(sender, recipient, amount);

        _balances[sender] = _balances[sender].sub(amount, "ERC20: transfer amount exceeds balance");
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
    }

    function _mint(address account, uint256 amount) internal virtual {

        require(account != address(0), "ERC20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply = _totalSupply.add(amount);
        _balances[account] = _balances[account].add(amount);
        emit Transfer(address(0), account, amount);
    }

    function _burn(address account, uint256 amount) internal virtual {

        require(account != address(0), "ERC20: burn from the zero address");

        _beforeTokenTransfer(account, address(0), amount);

        _balances[account] = _balances[account].sub(amount, "ERC20: burn amount exceeds balance");
        _totalSupply = _totalSupply.sub(amount);
        emit Transfer(account, address(0), amount);
    }

    function _approve(address owner, address spender, uint256 amount) internal virtual {

        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _setupDecimals(uint8 decimals_) internal {

        _decimals = decimals_;
    }

    function _beforeTokenTransfer(address from, address to, uint256 amount) internal virtual { }

}


pragma solidity ^0.7.4;

contract CTASK is ERC20 {
  
    constructor(
        address initialAccount,
        uint256 initialBalance
    ) ERC20("CTASK Token", "CTASK") {
        _mint(initialAccount, initialBalance);
    }
}


pragma solidity ^0.7.4;

contract CtaskSale {
    using SafeMath for uint256;

    address private _owner;
    CTASK public _token;
    
    address payable public _vault1;
    address payable public _vault2;
    address payable public _vault3;
    address payable public _vault4;
    
    uint8 public _stage = 0;
    uint256 public _maxAmount = 7 * (1 ether);
    uint256 public _swapRatio1 = 1700;
    uint256 public _swapRatio2 = 1444;
    uint256 public _cap1 = 250 * (1 ether);
    uint256 public _cap2 = 450 * (1 ether);
    uint256 public _amountRaisedTier1 = 0;
    uint256 public _amountRaisedTier2 = 0;
    uint256 public _amountRaised = 0;
    
    uint256 public _tier1StartTime = 0;
    uint256 public _tier1EndTime = 0;
    uint256 public _tier2StartTime = 0;
    uint256 public _tier2EndTime = 0;
    
    mapping(address => uint256) public _amounts;
    
    constructor (address tokenAddress, address vault1, address vault2, address vault3, address vault4) {
        _owner = msg.sender;
        _token = CTASK(tokenAddress);
        
        _vault1 = payable(vault1);
        _vault2 = payable(vault2);
        _vault3 = payable(vault3);
        _vault4 = payable(vault4);
    }
    
    receive() external payable {
        require(msg.value + _amounts[msg.sender] <= _maxAmount && ((_stage == 1  && _amountRaisedTier1 + msg.value <= _cap1) || (_stage == 3  && _amountRaisedTier2 + msg.value <= _cap2)),
            "Msg value needs to be not more than 7 ETH and current tier opened and unfilled");
        
        if(_stage == 1) {
            _amountRaisedTier1 += msg.value;
            _amountRaised += msg.value;
            _amounts[msg.sender] += msg.value;
            _token.transfer(msg.sender, msg.value * _swapRatio1);
        } else if (_stage == 3) {
            _amountRaisedTier2 += msg.value;
            _amountRaised += msg.value;
            _amounts[msg.sender] += msg.value;
            _token.transfer(msg.sender, msg.value * _swapRatio2);
        } else {
            revert();
        }
    }
    
    function changeSwapRatio1(uint256 newSwapRatio) public {
        require(msg.sender == _owner && _stage == 0, "Msg sender needs to be the owner and current stage 0");
        _swapRatio1 = newSwapRatio;
    }
    
    function changeSwapRatio2(uint256 newSwapRatio) public {
        require(msg.sender == _owner && (_stage == 0 || _stage == 2), "Msg sender needs to be the owner and current stage 0 or 2");
        _swapRatio2 = newSwapRatio;
    }
    
    function openTier1() public {
        require(msg.sender == _owner && _stage == 0, "Msg sender needs to be the owner and current stage 0");
        _stage = 1;
    }
    
    function closeTier1() public {
        require(msg.sender == _owner && _stage == 1, "Msg sender needs to be the owner and current stage 1");
        _stage = 2;
    }
    
    function openTier2() public {
        require(msg.sender == _owner && _stage == 2, "Msg sender needs to be the owner and current stage 2");
        _stage = 3;
    }
    
    function closeTier2() public {
        require(msg.sender == _owner && _stage == 3, "Msg sender needs to be the owner and current stage 3");
        
        _stage = 4;
        
        _vault1.transfer(_amountRaised.mul(3)/10);
        _vault2.transfer(_amountRaised.mul(3)/10);
        _vault3.transfer(_amountRaised.mul(3)/10);
        _vault4.transfer(_amountRaised/10);
    }
    
    function setTier1StartTime(uint256 newTime) public {
        require(msg.sender == _owner, "Msg sender needs to be the owner");
        _tier1StartTime = newTime;
    }
    
    function setTier1EndTime(uint256 newTime) public {
        require(msg.sender == _owner, "Msg sender needs to be the owner");
        _tier1EndTime = newTime;
    }
    
    function setTier2StartTime(uint256 newTime) public {
        require(msg.sender == _owner, "Msg sender needs to be the owner");
        _tier2StartTime = newTime;
    }
    
    function setTier2EndTime(uint256 newTime) public {
        require(msg.sender == _owner, "Msg sender needs to be the owner");
        _tier2EndTime = newTime;
    }
    
}