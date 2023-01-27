


pragma solidity ^0.6.0;

abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}




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




pragma solidity ^0.6.2;

library Address {

    function isContract(address account) internal view returns (bool) {

        bytes32 codehash;
        bytes32 accountHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;
        assembly { codehash := extcodehash(account) }
        return (codehash != accountHash && codehash != 0x0);
    }

    function sendValue(address payable recipient, uint256 amount) internal {

        require(address(this).balance >= amount, "Address: insufficient balance");

        (bool success, ) = recipient.call{ value: amount }("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    function functionCall(address target, bytes memory data) internal returns (bytes memory) {

      return functionCall(target, data, "Address: low-level call failed");
    }

    function functionCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {

        return _functionCallWithValue(target, data, 0, errorMessage);
    }

    function functionCallWithValue(address target, bytes memory data, uint256 value) internal returns (bytes memory) {

        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    function functionCallWithValue(address target, bytes memory data, uint256 value, string memory errorMessage) internal returns (bytes memory) {

        require(address(this).balance >= value, "Address: insufficient balance for call");
        return _functionCallWithValue(target, data, value, errorMessage);
    }

    function _functionCallWithValue(address target, bytes memory data, uint256 weiValue, string memory errorMessage) private returns (bytes memory) {

        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{ value: weiValue }(data);
        if (success) {
            return returndata;
        } else {
            if (returndata.length > 0) {

                assembly {
                    let returndata_size := mload(returndata)
                    revert(add(32, returndata), returndata_size)
                }
            } else {
                revert(errorMessage);
            }
        }
    }
}




pragma solidity ^0.6.0;





contract ERC20 is Context, IERC20 {

    using SafeMath for uint256;
    using Address for address;

    mapping (address => uint256) private _balances;

    mapping (address => mapping (address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;
    uint8 private _decimals;

    constructor (string memory name, string memory symbol) public {
        _name = name;
        _symbol = symbol;
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




pragma solidity ^0.6.0;

contract ReentrancyGuard {

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




pragma solidity 0.6.12;


contract Pausable is Context {
    event Paused(address account);
    event Shutdown(address account);
    event Unpaused(address account);
    event Open(address account);

    bool public paused;
    bool public stopEverything;

    modifier whenNotPaused() {
        require(!paused, "Pausable: paused");
        _;
    }
    modifier whenPaused() {
        require(paused, "Pausable: not paused");
        _;
    }

    modifier whenNotShutdown() {
        require(!stopEverything, "Pausable: shutdown");
        _;
    }

    modifier whenShutdown() {
        require(stopEverything, "Pausable: not shutdown");
        _;
    }

    function _pause() internal virtual whenNotPaused {
        paused = true;
        emit Paused(_msgSender());
    }

    function _unpause() internal virtual whenPaused whenNotShutdown {
        paused = false;
        emit Unpaused(_msgSender());
    }

    function _shutdown() internal virtual whenNotShutdown {
        stopEverything = true;
        paused = true;
        emit Shutdown(_msgSender());
    }

    function _open() internal virtual whenShutdown {
        stopEverything = false;
        emit Open(_msgSender());
    }
}




pragma solidity 0.6.12;




abstract contract PoolShareToken is ERC20, ReentrancyGuard, Pausable {
    IERC20 public token;
    uint256 internal constant MAX_UINT_VALUE = uint256(-1);

    event Deposit(address indexed owner, uint256 shares, uint256 amount);
    event Withdraw(address indexed owner, uint256 shares, uint256 amount);

    constructor(
        string memory name,
        string memory symbol,
        address _token
    ) public ERC20(name, symbol) {
        token = IERC20(_token);
    }

    function deposit(uint256 amount) external virtual nonReentrant whenNotPaused {
        _deposit(amount);
    }

    function withdraw(uint256 shares) external virtual nonReentrant whenNotShutdown {
        _withdraw(shares);
    }

    function withdrawByFeeCollector(uint256 shares) external virtual nonReentrant whenNotShutdown {
        require(shares != 0, "Withdraw must be greater than 0");
        require(_msgSender() == _getFeeCollector(), "Not a fee collector.");
        uint256 amount = convertFrom18(shares.mul(convertTo18(totalValue())).div(totalSupply()));
        _beforeBurning(amount);
        _burn(_msgSender(), shares);
        _afterBurning(amount);
        emit Withdraw(_msgSender(), shares, amount);
    }

    function getPricePerShare() external view returns (uint256) {
        return totalValue().mul(1e18).div(totalSupply());
    }

    function convertTo18(uint256 amount) public virtual pure returns (uint256) {
        return amount;
    }

    function convertFrom18(uint256 amount) public virtual pure returns (uint256) {
        return amount;
    }

    function tokensHere() public virtual view returns (uint256) {
        return token.balanceOf(address(this));
    }

    function totalValue() public virtual view returns (uint256) {
        return tokensHere();
    }

    function _beforeBurning(uint256 amount) internal virtual {}

    function _afterBurning(uint256 amount) internal virtual {}

    function _beforeMinting(uint256 amount) internal virtual {}

    function _afterMinting(uint256 amount) internal virtual {}

    function _getFee() internal virtual view returns (uint256) {}

    function _getFeeCollector() internal virtual view returns (address) {}

    function _calculateShares(uint256 amount) internal returns (uint256) {
        require(amount != 0, "Deposit must be greater than 0");

        uint256 _totalSupply = totalSupply();
        uint256 _totalValue = convertTo18(totalValue()).sub(msg.value);
        uint256 shares = (_totalSupply == 0 || _totalValue == 0)
            ? amount
            : amount.mul(_totalSupply).div(_totalValue);
        return shares;
    }

    function _deposit(uint256 amount) internal whenNotPaused {
        uint256 shares = _calculateShares(convertTo18(amount));
        _beforeMinting(amount);
        _mint(_msgSender(), shares);
        _afterMinting(amount);
        emit Deposit(_msgSender(), shares, amount);
    }

    function _handleFee(uint256 shares) internal returns (uint256 _sharesAfterFee) {
        if (_getFee() != 0) {
            uint256 _fee = shares.mul(_getFee()).div(1e18);
            _sharesAfterFee = shares.sub(_fee);
            _transfer(_msgSender(), _getFeeCollector(), _fee);
        } else {
            _sharesAfterFee = shares;
        }
    }

    function _withdraw(uint256 shares) internal whenNotShutdown {
        require(shares != 0, "Withdraw must be greater than 0");
        uint256 sharesAfterFee = _handleFee(shares);
        uint256 amount = convertFrom18(
            sharesAfterFee.mul(convertTo18(totalValue())).div(totalSupply())
        );
        _beforeBurning(amount);
        _burn(_msgSender(), sharesAfterFee);
        _afterBurning(amount);
        emit Withdraw(_msgSender(), shares, amount);
    }
}




pragma solidity 0.6.12;



contract Ownable is Context {
    address internal _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor() internal {
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

contract Owned is Ownable {
    address private _newOwner;

    function transferOwnership(address newOwner) public override onlyOwner {
        require(newOwner != address(0), "New owner is the zero address");
        _newOwner = newOwner;
    }

    function acceptOwnership() public {
        require(msg.sender == _newOwner, "Caller is not the new owner");
        emit OwnershipTransferred(_owner, _newOwner);
        _owner = _newOwner;
        _newOwner = address(0);
    }
}




pragma solidity 0.6.12;

interface ICollateralManager {
    function addGemJoin(address[] calldata gemJoins) external;

    function borrow(uint256 vaultNum, uint256 amount) external;

    function debtToken() external view returns (address);

    function depositCollateral(uint256 vaultNum, uint256 amount) external;

    function getVaultBalance(uint256 vaultNum) external view returns (uint256 collateralLocked);

    function getVaultDebt(uint256 vaultNum) external view returns (uint256 daiDebt);

    function getVaultInfo(uint256 vaultNum)
        external
        view
        returns (
            uint256 collateralLocked,
            uint256 daiDebt,
            uint256 collateralUsdRate,
            uint256 collateralRatio,
            uint256 minimumDebt
        );

    function isEmpty(uint256 vaultNum) external view returns (bool);

    function payback(uint256 vaultNum, uint256 amount) external;

    function registerVault(uint256 vaultNum, bytes32 collateralType) external;

    function vaultOwner(uint256 vaultNum) external returns (address owner);

    function whatWouldWithdrawDo(uint256 vaultNum, uint256 amount)
        external
        view
        returns (
            uint256 collateralLocked,
            uint256 daiDebt,
            uint256 collateralUsdRate,
            uint256 collateralRatio,
            uint256 minimumDebt
        );

    function withdrawCollateral(uint256 vaultNum, uint256 amount) external;
}




pragma solidity 0.6.12;


interface IVPool is IERC20 {
    function approveToken(address spender) external;

    function totalValue() external view returns (uint256);

    function sweepErc20(address erc20) external;

    function deposit() external payable;

    function deregisterCollateralManager(address cm) external;

    function deposit(uint256 amount) external;

    function registerCollateralManager(address cm) external;

    function resetApproval(address spender) external;

    function token() external view returns (address);

    function withdraw(uint256 amount) external;

    function withdrawETH(uint256 shares) external;
}




pragma solidity 0.6.12;





contract Controller is Owned {
    using SafeMath for uint256;
    mapping(address => uint256) public fee;
    mapping(address => uint256) public rebalanceFriction;
    mapping(address => address) public poolStrategy;
    mapping(address => address) public poolCollateralManager;
    mapping(address => address) public feeCollector;
    mapping(address => uint256) public highWater;
    mapping(address => uint256) public lowWater;
    mapping(address => bool) public isPool;
    address[] public pools;
    mapping(address => address) public collateralToken;
    address public builderVault;
    uint256 public builderFee = 5e16;
    uint256 internal constant WAT = 10**16;
    address public constant AAVE_ADDRESSES_PROVIDER = 0x24a42fD28C976A61Df5D00D0599C34c4f90748c8;
    address public uniswapRouter = 0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D;
    address public mcdManager = 0x5ef30b9986345249bc32d8928B7ee64DE9435E39;
    address public mcdDaiJoin = 0x9759A6Ac90977b93B58547b4A71c78317f391A28;
    address public mcdSpot = 0x65C79fcB50Ca1594B025960e539eD7A9a6D434A3;
    address public mcdJug = 0x19c0976f590D67707E62397C87829d896Dc0f1F1;

    function addPool(address _pool) external onlyOwner {
        require(_pool != address(0), "invalid-pool");
        IERC20 pool = IERC20(_pool);
        require(pool.totalSupply() == 0, "Zero supply required");
        require(!isPool[_pool], "already approved");
        isPool[_pool] = true;
        collateralToken[_pool] = IVPool(_pool).token();
        pools.push(_pool);
    }

    function removePool(uint256 _index) external onlyOwner {
        IERC20 pool = IERC20(pools[_index]);
        require(pool.totalSupply() == 0, "Zero supply required");
        isPool[pools[_index]] = false;
        if (_index < pools.length - 1) {
            pools[_index] = pools[pools.length - 1];
        }
        pools.pop();
    }

    function updateBalancingFactor(
        address _pool,
        uint256 _highWater,
        uint256 _lowWater
    ) public onlyOwner {
        require(isPool[_pool], "Pool not approved");
        require(_lowWater != 0, "Value is zero");
        require(_highWater > _lowWater, "highWater is smaller than lowWater");
        highWater[_pool] = _highWater.mul(WAT);
        lowWater[_pool] = _lowWater.mul(WAT);
    }

    function updateFee(address _pool, uint256 _newFee) external onlyOwner {
        require(isPool[_pool], "Pool not approved");
        require(_newFee <= 1e18, "fee limit reached");
        require(fee[_pool] != _newFee, "same-pool-fee");
        require(feeCollector[_pool] != address(0), "FeeCollector not set");
        fee[_pool] = _newFee;
    }

    function updateFeeCollector(address _pool, address _collector) external onlyOwner {
        require(isPool[_pool], "Pool not approved");
        require(_collector != address(0), "invalid-collector");
        require(feeCollector[_pool] != _collector, "same-collector");
        feeCollector[_pool] = _collector;
    }

    function updateRebalanceFriction(address _pool, uint256 _f) external onlyOwner {
        require(isPool[_pool], "Pool not approved");
        require(rebalanceFriction[_pool] != _f, "same-friction");
        rebalanceFriction[_pool] = _f;
    }

    function updateBuilderTreasure(address _builder) external onlyOwner {
        builderVault = _builder;
    }

    function updateBuilderFee(uint256 _builderFee) external onlyOwner {
        require(builderFee != _builderFee, "same-builderFee");
        require(_builderFee <= 1e18, "builder-fee-above-100%");
        builderFee = _builderFee;
    }

    function updateMCDAddress(
        address _mcdManager,
        address _mcdDaiJoin,
        address _mcdSpot,
        address _mcdJug
    ) external onlyOwner {
        mcdManager = _mcdManager;
        mcdDaiJoin = _mcdDaiJoin;
        mcdSpot = _mcdSpot;
        mcdJug = _mcdJug;
    }

    function updateMCDGemJoin(address _cm, address[] calldata gemJoins) external onlyOwner {
        ICollateralManager(_cm).addGemJoin(gemJoins);
    }

    function updatePoolCM(address _pool, address _newCM) external onlyOwner {
        require(isPool[_pool], "Pool not approved");
        require(_newCM != address(0), "invalid-cm-address");
        address cm = poolCollateralManager[_pool];
        require(cm != _newCM, "same-cm");

        IVPool vpool = IVPool(_pool);
        if (cm != address(0)) {
            vpool.resetApproval(cm);
            vpool.deregisterCollateralManager(cm);
        }
        poolCollateralManager[_pool] = _newCM;
        vpool.registerCollateralManager(_newCM);
        vpool.approveToken(_newCM);
    }

    function updatePoolStrategy(address _pool, address _newStrategy) external onlyOwner {
        require(isPool[_pool], "Pool not approved");
        require(_newStrategy != address(0), "invalid-strategy-address");
        address strategy = poolStrategy[_pool];
        require(strategy != _newStrategy, "same-pool-strategy");

        IVPool vpool = IVPool(_pool);
        if (strategy != address(0)) {
            vpool.resetApproval(strategy);
        }
        poolStrategy[_pool] = _newStrategy;
        vpool.approveToken(_newStrategy);
    }

    function updateUniswapRouter(address _uniswapRouter) external onlyOwner {
        uniswapRouter = _uniswapRouter;
    }

    function aaveProvider() external pure returns (address) {
        return AAVE_ADDRESSES_PROVIDER;
    }

    function getPoolCount() external view returns (uint256) {
        return pools.length;
    }

    function getPools() external view returns (address[] memory) {
        return pools;
    }
}




pragma solidity 0.6.12;

interface StrategyManager {
    function balanceOf(address pool) external view returns (uint256);

    function isEmpty() external view returns (bool);

    function isUnderwater(uint256 vaultNum) external view returns (bool);

    function paybackDebt(uint256 vaultNum, uint256 amount) external;

    function rebalanceCollateral(uint256 vaulNum) external;

    function rebalanceEarned(uint256 vaultNum) external;

    function token() external view returns (address);
}




pragma solidity 0.6.12;

interface IUniswapV2Router01 {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);

    function swapExactTokensForTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapTokensForExactTokens(
        uint256 amountOut,
        uint256 amountInMax,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapExactETHForTokens(
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable returns (uint256[] memory amounts);

    function swapTokensForExactETH(
        uint256 amountOut,
        uint256 amountInMax,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapExactTokensForETH(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapETHForExactTokens(
        uint256 amountOut,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable returns (uint256[] memory amounts);

    function quote(
        uint256 amountA,
        uint256 reserveA,
        uint256 reserveB
    ) external pure returns (uint256 amountB);

    function getAmountOut(
        uint256 amountIn,
        uint256 reserveIn,
        uint256 reserveOut
    ) external pure returns (uint256 amountOut);

    function getAmountIn(
        uint256 amountOut,
        uint256 reserveIn,
        uint256 reserveOut
    ) external pure returns (uint256 amountIn);

    function getAmountsOut(uint256 amountIn, address[] calldata path)
        external
        view
        returns (uint256[] memory amounts);

    function getAmountsIn(uint256 amountOut, address[] calldata path)
        external
        view
        returns (uint256[] memory amounts);
}




pragma solidity 0.6.12;


interface IUniswapV2Router02 is IUniswapV2Router01 {
    
    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;

    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable;

    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;
}




pragma solidity 0.6.12;







interface ManagerInterface {
    function vat() external view returns (address);

    function open(bytes32, address) external returns (uint256);

    function cdpAllow(
        uint256,
        address,
        uint256
    ) external;
}

interface VatInterface {
    function hope(address) external;

    function nope(address) external;
}

abstract contract VTokenBase is PoolShareToken, Owned {
    uint256 public vaultNum;
    bytes32 public immutable collateralType;
    uint256 internal constant WAT = 10**16;
    address internal constant WETH = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;
    Controller public controller;

    constructor(
        string memory name,
        string memory symbol,
        bytes32 _collateralType,
        address _token,
        address _controller
    ) public PoolShareToken(name, symbol, _token) {
        require(_controller != address(0), "Controller address is zero");
        collateralType = _collateralType;
        controller = Controller(_controller);
        vaultNum = createVault(_collateralType);
    }

    function approveToken(address spender) external virtual {
        if (spender == controller.poolStrategy(address(this))) {
            IERC20(token).approve(spender, MAX_UINT_VALUE);
            IERC20(StrategyManager(spender).token()).approve(spender, MAX_UINT_VALUE);
        } else if (spender == controller.poolCollateralManager(address(this))) {
            IERC20(token).approve(spender, MAX_UINT_VALUE);
            IERC20(ICollateralManager(spender).debtToken()).approve(spender, MAX_UINT_VALUE);
        }
    }

    function deposit(uint256 amount) external override nonReentrant whenNotPaused {
        require(_msgSender() == owner() || totalSupply() < 4e18, "Test limit reached");
        _deposit(amount);
    }

    function resetApproval(address spender) external virtual {
        require(_msgSender() == address(controller), "Not a controller");
        if (spender == controller.poolStrategy(address(this))) {
            IERC20(token).approve(spender, 0);
            IERC20(StrategyManager(spender).token()).approve(spender, 0);
        } else if (spender == controller.poolCollateralManager(address(this))) {
            IERC20(token).approve(spender, 0);
            IERC20(ICollateralManager(spender).debtToken()).approve(spender, 0);
        }
    }

    function pause() external onlyOwner {
        _pause();
    }

    function unpause() external onlyOwner {
        _unpause();
    }

    function shutdown() external onlyOwner {
        _shutdown();
    }

    function open() external onlyOwner {
        _open();
    }

    function deregisterCollateralManager(address _cm) external {
        require(_msgSender() == address(controller), "Not a controller");
        ManagerInterface manager = ManagerInterface(controller.mcdManager());
        VatInterface(manager.vat()).nope(_cm);
        manager.cdpAllow(vaultNum, _cm, 0);
    }

    function registerCollateralManager(address _cm) external {
        require(_msgSender() == address(controller), "Not a controller");
        ManagerInterface manager = ManagerInterface(controller.mcdManager());
        VatInterface(manager.vat()).hope(_cm);
        manager.cdpAllow(vaultNum, _cm, 1);

        ICollateralManager(_cm).registerVault(vaultNum, collateralType);
    }

    function withdrawAll() external onlyOwner {
        StrategyManager sm = StrategyManager(controller.poolStrategy(address(this)));
        ICollateralManager cm = ICollateralManager(controller.poolCollateralManager(address(this)));
        sm.rebalanceEarned(vaultNum);
        uint256 earnBalance = sm.balanceOf(address(this));
        sm.paybackDebt(vaultNum, earnBalance);
        require(poolDebt() == 0, "Debt should be 0");
        cm.withdrawCollateral(vaultNum, tokenLocked());
    }

    function rebalance() external {
        require(
            !stopEverything || (_msgSender() == owner()),
            "Contract has shutdown and is only callable by owner"
        );
        StrategyManager sm = StrategyManager(controller.poolStrategy(address(this)));
        ICollateralManager cm = ICollateralManager(controller.poolCollateralManager(address(this)));
        sm.rebalanceEarned(vaultNum);
        _depositCollateral(cm);
        sm.rebalanceCollateral(vaultNum);
    }

    function rebalanceCollateral() external {
        require(
            !stopEverything || (_msgSender() == owner()),
            "Contract has shutdown and is only callable by owner"
        );
        ICollateralManager cm = ICollateralManager(controller.poolCollateralManager(address(this)));
        StrategyManager sm = StrategyManager(controller.poolStrategy(address(this)));
        _depositCollateral(cm);
        sm.rebalanceCollateral(vaultNum);
    }

    function rebalanceEarned() external {
        require(
            !stopEverything || (_msgSender() == owner()),
            "Contract has shutdown and is only callable by owner"
        );
        StrategyManager sm = StrategyManager(controller.poolStrategy(address(this)));
        sm.rebalanceEarned(vaultNum);
    }

    function resurface() external {
        require(
            !stopEverything || (_msgSender() == owner()),
            "Contract has shutdown and is only callable by owner"
        );
        ICollateralManager cm = ICollateralManager(controller.poolCollateralManager(address(this)));
        address debtToken = cm.debtToken();
        StrategyManager sm = StrategyManager(controller.poolStrategy(address(this)));
        uint256 earnBalance = sm.balanceOf(address(this));
        uint256 debt = cm.getVaultDebt(vaultNum);
        require(debt > earnBalance, "Pool is above water");
        uint256 shortAmount = debt.sub(earnBalance);

        IUniswapV2Router02 uniswapRouter = IUniswapV2Router02(controller.uniswapRouter());
        address[] memory path;
        if (address(token) == WETH) {
            path = new address[](2);
            path[0] = address(token);
            path[1] = debtToken;
        } else {
            path = new address[](3);
            path[0] = address(token);
            path[1] = WETH;
            path[2] = debtToken;
        }
        uint256 tokenNeeded = uniswapRouter.getAmountsIn(shortAmount, path)[0];

        uint256 balanceHere = tokensHere();
        if (balanceHere < tokenNeeded) {
            cm.withdrawCollateral(vaultNum, tokenNeeded.sub(balanceHere));
        }

        token.approve(address(uniswapRouter), tokenNeeded);
        uniswapRouter.swapExactTokensForTokens(tokenNeeded, 1, path, address(this), now + 30);
        uint256 debtTokenBalance = IERC20(debtToken).balanceOf(address(this));
        cm.payback(vaultNum, debtTokenBalance);
    }

    function isUnderwater() external view returns (bool) {
        StrategyManager sm = StrategyManager(controller.poolStrategy(address(this)));
        return sm.isUnderwater(vaultNum);
    }

    function tokenLocked() public view returns (uint256) {
        ICollateralManager cm = ICollateralManager(controller.poolCollateralManager(address(this)));
        return convertFrom18(cm.getVaultBalance(vaultNum));
    }

    function poolDebt() public view returns (uint256) {
        ICollateralManager cm = ICollateralManager(controller.poolCollateralManager(address(this)));
        return cm.getVaultDebt(vaultNum);
    }

    function totalValue() public override view returns (uint256) {
        return tokenLocked().add(tokensHere());
    }

    function _getFee() internal override view returns (uint256) {
        return controller.fee(address(this));
    }

    function _getFeeCollector() internal override view returns (address) {
        return controller.feeCollector(address(this));
    }

    function _depositCollateral(ICollateralManager cm) internal {
        uint256 balance = tokensHere();
        if (balance != 0) {
            cm.depositCollateral(vaultNum, balance);
        }
    }

    function _withdrawCollateral(uint256 amount) internal {
        ICollateralManager cm = ICollateralManager(controller.poolCollateralManager(address(this)));
        StrategyManager sm = StrategyManager(controller.poolStrategy(address(this)));
        require(!sm.isUnderwater(vaultNum), "Pool is underwater");

        uint256 balanceHere = tokensHere();
        if (balanceHere < amount) {
            uint256 amountNeeded = amount.sub(balanceHere);
            (
                uint256 collateralLocked,
                uint256 debt,
                uint256 collateralUsdRate,
                uint256 collateralRatio,
                uint256 minimumDebt
            ) = cm.whatWouldWithdrawDo(vaultNum, amountNeeded);
            if (debt != 0 && collateralRatio < controller.lowWater(address(this))) {
                uint256 maxDebt = collateralLocked.mul(collateralUsdRate).div(
                    controller.highWater(address(this))
                );
                if (maxDebt < minimumDebt) {
                    sm.paybackDebt(vaultNum, debt);
                } else if (maxDebt < debt) {
                    sm.paybackDebt(vaultNum, debt.sub(maxDebt));
                }
            }
            cm.withdrawCollateral(vaultNum, amountNeeded);
        }
    }

    function createVault(bytes32 _collateralType) internal returns (uint256 vaultId) {
        ManagerInterface manager = ManagerInterface(controller.mcdManager());
        vaultId = manager.open(_collateralType, address(this));
        manager.cdpAllow(vaultId, address(this), 1);
    }

    function _sweepErc20(address from) internal {
        ICollateralManager cm = ICollateralManager(controller.poolCollateralManager(address(this)));
        StrategyManager sm = StrategyManager(controller.poolStrategy(address(this)));
        require(
            from != address(token) &&
                from != address(this) &&
                from != cm.debtToken() &&
                from != sm.token(),
            "Not allowed to sweep"
        );
        IUniswapV2Router02 uniswapRouter = IUniswapV2Router02(controller.uniswapRouter());
        IERC20 fromToken = IERC20(from);
        uint256 amt = fromToken.balanceOf(address(this));
        fromToken.approve(address(uniswapRouter), amt);
        address[] memory path;
        if (address(token) == WETH) {
            path = new address[](2);
            path[0] = from;
            path[1] = address(token);
        } else {
            path = new address[](3);
            path[0] = from;
            path[1] = WETH;
            path[2] = address(token);
        }
        uniswapRouter.swapExactTokensForTokens(amt, 1, path, address(this), now + 30);
    }
}




pragma solidity 0.6.12;

interface TokenLike {
    function approve(address, uint256) external;

    function balanceOf(address) external view returns (uint256);

    function transfer(address, uint256) external;

    function transferFrom(
        address,
        address,
        uint256
    ) external;

    function deposit() external payable;

    function withdraw(uint256) external;
}




pragma solidity 0.6.12;



contract VETH is VTokenBase {
    TokenLike public weth;
    bool internal lockEth;

    constructor(address _controller)
        public
        VTokenBase(
            "VETH Pool",
            "VETH",
            "ETH-A",
            0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2,
            _controller
        )
    {
        weth = TokenLike(0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2);
    }

    receive() external payable {
        if (!lockEth) {
            deposit();
        }
    }

    function withdrawETH(uint256 shares) external whenNotShutdown nonReentrant {
        require(shares != 0, "Withdraw must be greater than 0");
        uint256 sharesAfterFee = _handleFee(shares);
        uint256 amount = sharesAfterFee.mul(totalValue()).div(totalSupply());
        _burn(_msgSender(), sharesAfterFee);

        _withdrawCollateral(amount);

        lockEth = true;
        weth.withdraw(amount);
        lockEth = false;
        _msgSender().transfer(amount);

        emit Withdraw(_msgSender(), shares, amount);
    }

    function sweepErc20(address erc20) external {
        _sweepErc20(erc20);
    }

    function deposit() public payable whenNotPaused nonReentrant {
        weth.deposit{value: msg.value}();
        uint256 shares = _calculateShares(msg.value);
        _mint(_msgSender(), shares);
    }

    function _afterBurning(uint256 amount) internal override {
        _withdrawCollateral(amount);
        weth.transfer(_msgSender(), amount);
    }

    function _beforeMinting(uint256 amount) internal override {
        weth.transferFrom(_msgSender(), address(this), amount);
    }
}