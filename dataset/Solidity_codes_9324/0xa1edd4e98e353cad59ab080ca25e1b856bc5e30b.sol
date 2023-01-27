



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




pragma solidity >=0.6.0 <0.8.0;

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


pragma solidity >=0.6.2;

interface IUniswapV2Router01 {

    function factory() external pure returns (address);

    function WETH() external pure returns (address);


    function addLiquidity(
        address tokenA,
        address tokenB,
        uint amountADesired,
        uint amountBDesired,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB, uint liquidity);

    function addLiquidityETH(
        address token,
        uint amountTokenDesired,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external payable returns (uint amountToken, uint amountETH, uint liquidity);

    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB);

    function removeLiquidityETH(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external returns (uint amountToken, uint amountETH);

    function removeLiquidityWithPermit(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountA, uint amountB);

    function removeLiquidityETHWithPermit(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountToken, uint amountETH);

    function swapExactTokensForTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);

    function swapTokensForExactTokens(
        uint amountOut,
        uint amountInMax,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);

    function swapExactETHForTokens(uint amountOutMin, address[] calldata path, address to, uint deadline)
        external
        payable
        returns (uint[] memory amounts);

    function swapTokensForExactETH(uint amountOut, uint amountInMax, address[] calldata path, address to, uint deadline)
        external
        returns (uint[] memory amounts);

    function swapExactTokensForETH(uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline)
        external
        returns (uint[] memory amounts);

    function swapETHForExactTokens(uint amountOut, address[] calldata path, address to, uint deadline)
        external
        payable
        returns (uint[] memory amounts);


    function quote(uint amountA, uint reserveA, uint reserveB) external pure returns (uint amountB);

    function getAmountOut(uint amountIn, uint reserveIn, uint reserveOut) external pure returns (uint amountOut);

    function getAmountIn(uint amountOut, uint reserveIn, uint reserveOut) external pure returns (uint amountIn);

    function getAmountsOut(uint amountIn, address[] calldata path) external view returns (uint[] memory amounts);

    function getAmountsIn(uint amountOut, address[] calldata path) external view returns (uint[] memory amounts);

}


pragma solidity >=0.6.2;


interface IUniswapV2Router02 is IUniswapV2Router01 {

    function removeLiquidityETHSupportingFeeOnTransferTokens(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external returns (uint amountETH);

    function removeLiquidityETHWithPermitSupportingFeeOnTransferTokens(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountETH);


    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;

    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external payable;

    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;

}




pragma solidity ^ 0.6.6;




contract QPool {

    using SafeMath for uint256;

    address public creator;
    string public poolName;
    address[] private tokens;
    uint[] private amounts;
    address private uniswapFactoryAddress = 0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D;
    IUniswapV2Router02 public uniswapRouter;

    event TradeCompleted(uint256[] acquired);
    event DepositProcessed(uint256 amount);
    event WithdrawalProcessed(uint256 amount);

    constructor(
        string memory _poolName,
        address[] memory _tokens,
        uint[] memory _amounts,
        address _creator
    ) public {
        uint _total = 0;
        for (uint i = 0; i < _amounts.length; i++) {
            _total += _amounts[i];
        }
        require(_total == 100);
        creator = _creator;
        poolName = _poolName;
        tokens = _tokens;
        amounts = _amounts;
        uniswapRouter = IUniswapV2Router02(uniswapFactoryAddress);
    }

    fallback() external payable {
        require(msg.sender == creator);
        require(msg.data.length == 0);
        processDeposit();
    }

    receive() external payable {
        require(msg.sender == creator);
        require(msg.data.length == 0);
        processDeposit();
    }

    function close() external {

        require(msg.sender == creator);
        withdrawEth(100);
        selfdestruct(msg.sender);
    }

    function processDeposit() public payable {

        require(msg.sender == creator);
        require(msg.value > 10000000000000000, "Minimum deposit amount is 0.01 ETH");
        address[] memory _path = new address[](2);
        _path[0] = uniswapRouter.WETH();
        for (uint256 i = 0; i < tokens.length; i++) {
            uint256 time = now + 15 + i;
            _path[1] = tokens[i];
            uint256 _amountEth = msg.value.mul(amounts[i]).div(100);
            uint256[] memory _expected = uniswapRouter.getAmountsOut(_amountEth, _path);
            uint256[] memory _output = uniswapRouter.swapExactETHForTokens.value(_expected[0])(_expected[1], _path, address(this), time);
            emit TradeCompleted(_output);
        }
        emit DepositProcessed(msg.value);
    }

    function withdrawEth(uint256 _percent) public {

        require(msg.sender == creator, "Only the creator can withdraw ETH.");
        require(_percent > 0 && _percent <= 100, "Percent must be between 0 and 100.");
        address[] memory _path = new address[](2);
        uint256 total = 0;
        for (uint i = 0; i < tokens.length; i++) {
            IERC20 _token = IERC20(tokens[i]);
            uint256 _addressBalance = _token.balanceOf(address(this));
            uint256 _amountOut = _addressBalance.mul(_percent).div(100);
            require(_amountOut > 0, "Amount out is 0.");
            require(_token.approve(address(uniswapRouter), _amountOut), "Approval failed");
            _path[0] = tokens[i];
            _path[1] = uniswapRouter.WETH();
            uint256[] memory _expected = uniswapRouter.getAmountsOut(_amountOut, _path);
            require(_expected[1] > 1000000, "Amount is too small to transfer");
            uint256 _time = now + 15 + i;
            uint256[] memory _output = uniswapRouter.swapExactTokensForETH(_expected[0], _expected[1], _path, creator, _time);
            total += _output[1];
            emit TradeCompleted(_output);
        }
        emit WithdrawalProcessed(total);
    }

    function totalValue() public view returns (uint256) {

        uint256 _totalValue = 0;
        address[] memory _path = new address[](2);
        for (uint i = 0; i < tokens.length && i <= 5; i++) {
            IERC20 _token = IERC20(tokens[i]);
            uint256 _totalBalance = _token.balanceOf(address(this));
            if (_totalBalance == 0) return 0;
            _path[0] = tokens[i];
            _path[1] = uniswapRouter.WETH();
            uint256[] memory _ethValue = uniswapRouter.getAmountsOut(_totalBalance, _path);
            _totalValue += _ethValue[1];
        }
        return _totalValue;
    }
    
    function withdrawTokens() public {

        require(msg.sender == creator, "Only the creator can withdraw tokens");
        for (uint i = 0; i < tokens.length; i++) {
            IERC20 _token = IERC20(tokens[i]);
            uint256 _tokenBalance = _token.balanceOf(address(this));
            _token.transfer(creator, _tokenBalance);
        }
    }

    function getTokens() public view returns (address[] memory) {

        return tokens;
    }

    function getAmounts() public view returns (uint[] memory) {

        return amounts;
    }

    function isPublic() public pure returns (bool _isPublic) {

        return false;
    }

}




pragma solidity >=0.6.0 <0.8.0;

abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}




pragma solidity >=0.6.0 <0.8.0;




contract ERC20 is Context, IERC20 {

    using SafeMath for uint256;

    mapping (address => uint256) private _balances;

    mapping (address => mapping (address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;
    uint8 private _decimals;

    constructor (string memory name_, string memory symbol_) public {
        _name = name_;
        _symbol = symbol_;
        _decimals = 18;
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

    function transferFrom(address sender, address recipient, uint256 amount) public virtual override returns (bool) {

        _transfer(sender, recipient, amount);
        _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount, "ERC20: transfer amount exceeds allowance"));
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {

        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].add(addedValue));
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {

        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].sub(subtractedValue, "ERC20: decreased allowance below zero"));
        return true;
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




pragma solidity >=0.6.0 <0.8.0;



abstract contract ERC20Burnable is Context, ERC20 {
    using SafeMath for uint256;

    function burn(uint256 amount) public virtual {
        _burn(_msgSender(), amount);
    }

    function burnFrom(address account, uint256 amount) public virtual {
        uint256 decreasedAllowance = allowance(account, _msgSender()).sub(amount, "ERC20: burn amount exceeds allowance");

        _approve(account, _msgSender(), decreasedAllowance);
        _burn(account, amount);
    }
}




pragma solidity >=0.6.0 <0.8.0;

abstract contract ReentrancyGuard {

    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor () internal {
        _status = _NOT_ENTERED;
    }

    modifier nonReentrant() {
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        _status = _ENTERED;

        _;

        _status = _NOT_ENTERED;
    }
}




pragma solidity ^ 0.6.6;





contract QPoolPublic is ERC20, ERC20Burnable, ReentrancyGuard {
    using SafeMath for uint256;

    string public poolName;
    address[] private tokens;
    uint256[] private amounts;
    address public creator;
    address private uniswapFactoryAddress = 0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D;
    IUniswapV2Router02 public uniswapRouter;
    
    address[] private depositors;
    mapping(address => uint) private deposits;
    
    event TradeCompleted(uint256[] acquired);
    event DepositProcessed(uint256 amount);
    event WithdrawalProcessed(uint256 amount);
    
    constructor (
        string memory _poolName,
        address[] memory _tokens,
        uint256[] memory _amounts,
        address _creator
        ) ERC20 ("QPoolDepositToken", "QPDT") public {
            uint256 _total = 0;
            require(tokens.length <= 5 && tokens.length == amounts.length);
            for (uint256 i = 0; i < _amounts.length && i <= 5; i++) {
                _total += _amounts[i];
            }
            require(_total == 100);
            poolName = _poolName;
            tokens = _tokens;
            amounts = _amounts;
            creator = _creator;
            uniswapRouter = IUniswapV2Router02(uniswapFactoryAddress);
        }
    
    fallback() external payable nonReentrant {
        require(msg.data.length == 0);
        processDeposit();
    }

    receive() external payable nonReentrant {
        require(msg.data.length == 0);
        processDeposit();
    }

    function processDeposit() public payable nonReentrant {
        uint256 _newIssuance = calculateShare();
        if (deposits[msg.sender] == 0) addDepositor(msg.sender);
        deposits[msg.sender] = deposits[msg.sender].add(msg.value);
        require(makeExchange());
        _mint(msg.sender, _newIssuance);
        emit DepositProcessed(msg.value);
    }

    function makeExchange() private returns (bool) {
        address[] memory _path = new address[](2);
        for (uint256 i = 0; i < tokens.length && i<= 5; i++) {
            _path[0] = uniswapRouter.WETH();
            _path[1] = tokens[i];
            uint256 _time = now + 15 + i;
            uint256 _amountEth = msg.value.mul(amounts[i]).div(100);
            uint256[] memory _expected = uniswapRouter.getAmountsOut(_amountEth, _path);
            uint256[] memory _output = uniswapRouter.swapExactETHForTokens.value(_expected[0])(_expected[1], _path, address(this), _time);
            emit TradeCompleted(_output);
        }
        return true;
    }

    function totalValue() public view returns (uint256) {
        uint256 _totalValue = 0;
        address[] memory _path = new address[](2);
        for (uint i = 0; i < tokens.length && i <= 5; i++) {
            ERC20 _token = ERC20(tokens[i]);
            uint256 _totalBalance = _token.balanceOf(address(this));
            if (_totalBalance == 0) return 0;
            _path[0] = tokens[i];
            _path[1] = uniswapRouter.WETH();
            uint256[] memory _ethValue = uniswapRouter.getAmountsOut(_totalBalance, _path);
            _totalValue += _ethValue[1];
        }
        return _totalValue;
    }

    function calculateShare() private view returns (uint256) {
        if (totalSupply() == 0) {
            return 1000000000000000000000;
        } else {
            uint256 _totalValue = totalValue();
            uint256 _tmp = 100;
            uint256 _poolShare = _tmp.mul(msg.value).div(_totalValue);
            uint256 _mintAmount = totalSupply().mul(_poolShare).div(100);
            return _mintAmount;
        }
    }
    
    function withdrawEth(uint256 _percent) public nonReentrant {
        require(_percent > 0);
        uint256 _userShare = balanceOf(msg.sender);
        uint256 _burnAmount = _userShare.mul(_percent).div(100);
        uint256 _tmp = 100;
        uint256 _poolShare = _tmp.mul(_userShare).div(totalSupply());
        require(balanceOf(msg.sender) >= _burnAmount);
        require(approve(address(this), _burnAmount));
        _burn(msg.sender, _burnAmount);
        deposits[msg.sender] = deposits[msg.sender].sub((deposits[msg.sender]).mul(_percent).div(100));
        if (deposits[msg.sender] == 0) removeDepositor(msg.sender);
        (bool success, uint256 total) = sellTokens(_poolShare, _percent);
        require(success);
        emit WithdrawalProcessed(total);
    }

    function sellTokens(uint256 _poolShare, uint256 _percent) private returns (bool, uint256) {
        uint256 total = 0;
        address[] memory _path = new address[](2);
        for (uint256 i = 0; i < tokens.length && i <= 5; i++) {
            ERC20 _token = ERC20(tokens[i]);
            uint256 _addressBalance = _token.balanceOf(address(this));
            uint256 _amountOut = _addressBalance.mul(_poolShare).mul(_percent).div(10000);
            require(_amountOut > 0);
            require(_token.approve(address(uniswapRouter), _amountOut));
            _path[0] = tokens[i];
            _path[1] = uniswapRouter.WETH();
            uint256[] memory _expected = uniswapRouter.getAmountsOut(_amountOut, _path);
            require(_expected[1] > 1000000);
            uint256 _time = now + 15 + i;
            uint256[] memory _output = uniswapRouter.swapExactTokensForETH(_expected[0], _expected[1], _path, msg.sender, _time);
            total += _output[1];
            emit TradeCompleted(_output);
        }
        return (true, total);
    }

    function withdrawTokens() public nonReentrant {
        uint256 _userShare = balanceOf(msg.sender);
        uint256 _poolShare = _userShare.div(totalSupply()).mul(100);
        _burn(msg.sender, _userShare);
        removeDepositor(msg.sender);
        for (uint256 i = 0; i < tokens.length; i++) {
            ERC20 _token = ERC20(tokens[i]);
            uint256 _addressBalance = _token.balanceOf(address(this));
            uint256 _amountOut = _addressBalance.mul(_poolShare).div(100);
            require(_token.approve(msg.sender, _amountOut));
            require(_token.transfer(msg.sender, _amountOut));
        }
    }
    
    function isDepositor(address _address) public view returns (bool, uint256) {
        for (uint256 i = 0; i < depositors.length; i++) {
            if (_address == depositors[i]) return (true, i);
        }
        return (false, 0);
    }
        
    function totalDeposits() public view returns (uint256) {
        uint256 _totalDeposits = 0;
        for (uint256 i = 0; i < depositors.length; i++) {
            _totalDeposits = _totalDeposits.add(deposits[depositors[i]]);
        }
        return _totalDeposits;
    }
    
    function addDepositor(address _depositor) private {
        (bool _isDepositor, ) = isDepositor(_depositor);
        if(!_isDepositor) depositors.push(_depositor);
    }
    
    function removeDepositor(address _depositor) private {
        (bool _isDepositor, uint256 i) = isDepositor(_depositor);
        if (_isDepositor) {
            depositors[i] = depositors[depositors.length - 1];
            depositors.pop();
        }
    }

    function getTokens() public view returns (address[] memory) {
        return tokens;
    }

    function getAmounts() public view returns (uint[] memory) {
        return amounts;
    }

    function isPublic() public pure returns (bool _isPublic) {
        return true;
    }
}




pragma solidity ^ 0.6.6;



contract QPoolFactory {
    address[] private privatePools;
    address[] private publicPools;
    mapping(address => bool) private isPool;

    event PoolCreated(QPool pool);
    event PublicPoolCreated(QPoolPublic pool);

    function getPrivatePools() public view returns (address[] memory) {
        return privatePools;
    }

    function getPublicPools() public view returns (address[] memory) {
        return publicPools;
    }

    function checkPool(address _poolAddress) public view returns (bool) {
        return isPool[_poolAddress];
    }

    function newPool(string memory _name, address[] memory _tokens, uint[] memory _amounts)
    public returns (address) {
        QPool pool = new QPool(_name, _tokens, _amounts, msg.sender);
        emit PoolCreated(pool);
        privatePools.push(address(pool));
        isPool[address(pool)] = true;
        return address(pool);
    }

    function newPublicPool(string memory _name, address[] memory _tokens, uint[] memory _amounts)
    public returns (address) {
        QPoolPublic pool = new QPoolPublic(_name, _tokens, _amounts, msg.sender);
        emit PublicPoolCreated(pool);
        publicPools.push(address(pool));
        isPool[address(pool)] = true;
    }
}



pragma solidity >=0.4.22 <0.8.0;

contract Migrations {
  address public owner = msg.sender;
  uint public last_completed_migration;

  modifier restricted() {
    require(
      msg.sender == owner,
      "This function is restricted to the contract's owner"
    );
    _;
  }

  function setCompleted(uint completed) public restricted {
    last_completed_migration = completed;
  }
}