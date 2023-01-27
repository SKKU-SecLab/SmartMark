



pragma solidity ^0.8.0;


library SafeMath {

    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        unchecked {
            uint256 c = a + b;
            if (c < a) return (false, 0);
            return (true, c);
        }
    }

    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        unchecked {
            if (b > a) return (false, 0);
            return (true, a - b);
        }
    }

    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        unchecked {
            if (a == 0) return (true, 0);
            uint256 c = a * b;
            if (c / a != b) return (false, 0);
            return (true, c);
        }
    }

    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        unchecked {
            if (b == 0) return (false, 0);
            return (true, a / b);
        }
    }

    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        unchecked {
            if (b == 0) return (false, 0);
            return (true, a % b);
        }
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {

        return a + b;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {

        return a - b;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {

        return a * b;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {

        return a / b;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {

        return a % b;
    }

    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {

        unchecked {
            require(b <= a, errorMessage);
            return a - b;
        }
    }

    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {

        unchecked {
            require(b > 0, errorMessage);
            return a / b;
        }
    }

    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {

        unchecked {
            require(b > 0, errorMessage);
            return a % b;
        }
    }
}




pragma solidity ^0.8.0;

abstract contract ReentrancyGuard {

    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor() {
        _status = _NOT_ENTERED;
    }

    modifier nonReentrant() {
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        _status = _ENTERED;

        _;

        _status = _NOT_ENTERED;
    }
}




pragma solidity ^0.8.0;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}




pragma solidity ^0.8.0;

interface IERC20 {

    function totalSupply() external view returns (uint256);


    function balanceOf(address account) external view returns (uint256);


    function transfer(address recipient, uint256 amount) external returns (bool);


    function allowance(address owner, address spender) external view returns (uint256);


    function approve(address spender, uint256 amount) external returns (bool);


    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);


    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}




pragma solidity ^0.8.0;


interface IERC20Metadata is IERC20 {

    function name() external view returns (string memory);


    function symbol() external view returns (string memory);


    function decimals() external view returns (uint8);

}




pragma solidity ^0.8.0;




contract ERC20 is Context, IERC20, IERC20Metadata {

    mapping(address => uint256) private _balances;

    mapping(address => mapping(address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;

    constructor(string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
    }

    function name() public view virtual override returns (string memory) {

        return _name;
    }

    function symbol() public view virtual override returns (string memory) {

        return _symbol;
    }

    function decimals() public view virtual override returns (uint8) {

        return 18;
    }

    function totalSupply() public view virtual override returns (uint256) {

        return _totalSupply;
    }

    function balanceOf(address account) public view virtual override returns (uint256) {

        return _balances[account];
    }

    function transfer(address recipient, uint256 amount) public virtual override returns (bool) {

        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function allowance(address owner, address spender) public view virtual override returns (uint256) {

        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public virtual override returns (bool) {

        _approve(_msgSender(), spender, amount);
        return true;
    }

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public virtual override returns (bool) {

        _transfer(sender, recipient, amount);

        uint256 currentAllowance = _allowances[sender][_msgSender()];
        require(currentAllowance >= amount, "ERC20: transfer amount exceeds allowance");
        unchecked {
            _approve(sender, _msgSender(), currentAllowance - amount);
        }

        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {

        _approve(_msgSender(), spender, _allowances[_msgSender()][spender] + addedValue);
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {

        uint256 currentAllowance = _allowances[_msgSender()][spender];
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
        unchecked {
            _approve(_msgSender(), spender, currentAllowance - subtractedValue);
        }

        return true;
    }

    function _transfer(
        address sender,
        address recipient,
        uint256 amount
    ) internal virtual {

        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(sender, recipient, amount);

        uint256 senderBalance = _balances[sender];
        require(senderBalance >= amount, "ERC20: transfer amount exceeds balance");
        unchecked {
            _balances[sender] = senderBalance - amount;
        }
        _balances[recipient] += amount;

        emit Transfer(sender, recipient, amount);

        _afterTokenTransfer(sender, recipient, amount);
    }

    function _mint(address account, uint256 amount) internal virtual {

        require(account != address(0), "ERC20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply += amount;
        _balances[account] += amount;
        emit Transfer(address(0), account, amount);

        _afterTokenTransfer(address(0), account, amount);
    }

    function _burn(address account, uint256 amount) internal virtual {

        require(account != address(0), "ERC20: burn from the zero address");

        _beforeTokenTransfer(account, address(0), amount);

        uint256 accountBalance = _balances[account];
        require(accountBalance >= amount, "ERC20: burn amount exceeds balance");
        unchecked {
            _balances[account] = accountBalance - amount;
        }
        _totalSupply -= amount;

        emit Transfer(account, address(0), amount);

        _afterTokenTransfer(account, address(0), amount);
    }

    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {

        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}


    function _afterTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}

}




pragma solidity >=0.7.0 <0.9.0;






contract JPEGVaultICO is ReentrancyGuard {
    using SafeMath for uint256;
    
    bool public isFinalized;
    uint256 public minDeposit;
    uint256 public maxDeposit;
    uint256 public fundingTarget;
    uint public openingTime;
    uint public closingTime;
    uint private constant _1ether = 1000000000000000000;
   
    mapping(address => uint256) public balances;
    mapping(address => bool) public tokenClaimed;


    ERC20 private _token;

    address payable private _wallet;

    uint256 private _rate;

    uint256 private _weiRaised;

    event TokensPurchased(address indexed purchaser, address indexed beneficiary, uint256 value, uint256 amount);
    event TokenClaimed(address indexed beneficiary, uint256 amount);
    event JPEGVaultICOExtended(uint256 closingTime, uint256 newClosingTime);

    address private _admin;
    
    constructor(uint256 rate, address payable wallet, address admin, address tokenAddress, uint256 _minDeposit, uint256 _maxDeposit, uint256 _target) {
        require(rate > 0, "Crowdsale: rate is 0");
        require(wallet != address(0), "JPEGVaultICO: wallet is the zero address");
        require(admin != address(0), "JPEGVaultICO: admin is the zero address");
        require(tokenAddress != address(0), "JPEGVaultICO: token is the zero address");
        require(_maxDeposit > _minDeposit, "Maximum deposit allowed is not greater than the minimum desposit.");
        require(_target > 0, "Invalid Funding target set.");
        
        _rate = rate;
        _wallet = wallet;
        _token = ERC20(tokenAddress);
        _admin = admin;
        maxDeposit = _maxDeposit;
        minDeposit = _minDeposit;
        fundingTarget = _target;
    }
    
    modifier onlyWhileOpen() {
        require(isOpen(), "Sales is not currently on!");
        _;
    }
    
     modifier onlyAdmin() {
        require(msg.sender == _admin, "Unauthorized sender");
        _;
    }
    
    receive() external payable {
        buyTokens(msg.sender);
    }

    function buyTokens(address beneficiary) public nonReentrant payable onlyWhileOpen {
        uint256 weiAmount = msg.value;
        _preValidatePurchase(beneficiary, weiAmount);

        uint256 tokens = _getTokenAmount(weiAmount);

        _weiRaised = _weiRaised.add(weiAmount);

        _forwardFunds();
        
        emit TokensPurchased(msg.sender, beneficiary, weiAmount, tokens);

    }
    
    function withdrawTokens(address beneficiary) public nonReentrant {
        require(hasClosed(), "JPEGVaultICO: not closed");
        
        uint256 amount = balances[beneficiary];
        require(amount > 0, "JPEGVaultICO: beneficiary is not due any tokens");
        
        require(tokenClaimed[beneficiary] == false, "Token already claimed!!!");
        
        uint256 tokenAmount = _getTokenAmount(balances[beneficiary]);
        
        tokenClaimed[beneficiary] = true;
        
        balances[beneficiary] = 0;
        
        _deliverTokens(beneficiary, tokenAmount);
        
        emit TokenClaimed(beneficiary, tokenAmount);
    }

    function _preValidatePurchase(address beneficiary, uint256 weiAmount) internal {
        require(beneficiary != address(0), "beneficiary is the zero address");
        require(weiAmount != 0, "weiAmount is 0");
        require(weiAmount >= minDeposit && weiAmount <= maxDeposit, "Amount should be within 0.05 eth and 1 eth");
        require(weiRaised().add(weiAmount) <= fundingTarget, "Crowdsale goal reached");
        
        uint256 _existingbalance = balances[beneficiary];
        uint256 _newBalance = _existingbalance.add(weiAmount);
        require(_newBalance <= maxDeposit, "Maximum deposit exceeded!!!");
        
        balances[beneficiary] = _newBalance;
    }
    
     function startIco( uint256 _openingTime) external onlyAdmin {
        require(_openingTime >= block.timestamp, "JPEGVaultICO: opening time is before current block timestamp");
        require(openingTime == 0 || hasClosed(), "You can't restart ICO in the middle of sales period");
        openingTime = _openingTime;
        closingTime = openingTime + 1 weeks;
     }

    function _deliverTokens(address beneficiary, uint256 tokenAmount) internal {
        require(_token.transfer(beneficiary, tokenAmount));
    }
    
    function _getTokenAmount(uint256 weiAmount) internal view returns (uint256) {
        uint256 total = weiAmount.mul(_rate);
        return total;
    }
    
    function _forwardFunds() internal {
        _wallet.transfer(msg.value);
    }
    function extendTime(uint256 newClosingTime) external onlyAdmin {
        require(!hasClosed(), "JPEGVaultICO: already closed");
        require(newClosingTime > closingTime, "JPEGVaultICO: new closing time is before current closing time");

        emit JPEGVaultICOExtended(closingTime, newClosingTime);
        closingTime = newClosingTime;
    }
    
    function balanceOf(address _owner) public view returns(uint256) {
        return balances[_owner];
    }
    
    function getToken() public view returns (ERC20) {
        return _token;
    }

    function getWallet() public view returns (address payable) {
        return _wallet;
    }

    function getRate() public view returns (uint256) {
        return _rate;
    }

    function weiRaised() public view returns (uint256) {
        return _weiRaised;
    }
    
    function targetReached() public view returns(bool) {
        return weiRaised() == fundingTarget;
    }

    
    function isOpen() public view returns(bool) {
        return block.timestamp > openingTime && block.timestamp < closingTime;
    }
    
    function hasClosed() public view returns(bool) {
        return block.timestamp > closingTime;
    }

}