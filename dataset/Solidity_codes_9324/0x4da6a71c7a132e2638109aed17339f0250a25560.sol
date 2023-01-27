
pragma solidity 0.6.12;

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

library SafeERC20 {
    using SafeMath for uint256;
    using Address for address;

    function safeTransfer(IERC20 token, address to, uint256 value) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(IERC20 token, address from, address to, uint256 value) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    function safeApprove(IERC20 token, address spender, uint256 value) internal {
        require((value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(IERC20 token, address spender, uint256 value) internal {
        uint256 newAllowance = token.allowance(address(this), spender).add(value);
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(IERC20 token, address spender, uint256 value) internal {
        uint256 newAllowance = token.allowance(address(this), spender).sub(value, "SafeERC20: decreased allowance below zero");
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function _callOptionalReturn(IERC20 token, bytes memory data) private {

        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) { // Return data is optional
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}

interface IVault is IERC20 {
    function token() external view returns (address);

    function claimInsurance() external; // NOTE: Only yDelegatedVault implements this

    function getRatio() external view returns (uint256);

    function deposit(uint256) external;

    function withdraw(uint256) external;

    function earn() external;
	
    function balance() external view returns (uint256);
}

interface UniswapRouterV2 {
    function swapExactTokensForTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function addLiquidity(
        address tokenA,
        address tokenB,
        uint256 amountADesired,
        uint256 amountBDesired,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline
    )
        external
        returns (
            uint256 amountA,
            uint256 amountB,
            uint256 liquidity
        );

    function addLiquidityETH(
        address token,
        uint256 amountTokenDesired,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    )
        external
        payable
        returns (
            uint256 amountToken,
            uint256 amountETH,
            uint256 liquidity
        );

    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint256 liquidity,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountA, uint256 amountB);

    function getAmountsOut(uint256 amountIn, address[] calldata path)
        external
        view
        returns (uint256[] memory amounts);

    function getAmountsIn(uint256 amountOut, address[] calldata path)
        external
        view
        returns (uint256[] memory amounts);

    function swapETHForExactTokens(
        uint256 amountOut,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable returns (uint256[] memory amounts);

    function swapExactETHForTokens(
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable returns (uint256[] memory amounts);
}

interface IUniswapV2Pair {
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
    event Transfer(address indexed from, address indexed to, uint256 value);

    function name() external pure returns (string memory);

    function symbol() external pure returns (string memory);

    function decimals() external pure returns (uint8);

    function totalSupply() external view returns (uint256);

    function balanceOf(address owner) external view returns (uint256);

    function allowance(address owner, address spender)
        external
        view
        returns (uint256);

    function approve(address spender, uint256 value) external returns (bool);

    function transfer(address to, uint256 value) external returns (bool);

    function transferFrom(
        address from,
        address to,
        uint256 value
    ) external returns (bool);

    function DOMAIN_SEPARATOR() external view returns (bytes32);

    function PERMIT_TYPEHASH() external pure returns (bytes32);

    function nonces(address owner) external view returns (uint256);

    function permit(
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external;

    event Mint(address indexed sender, uint256 amount0, uint256 amount1);
    event Burn(
        address indexed sender,
        uint256 amount0,
        uint256 amount1,
        address indexed to
    );
    event Swap(
        address indexed sender,
        uint256 amount0In,
        uint256 amount1In,
        uint256 amount0Out,
        uint256 amount1Out,
        address indexed to
    );
    event Sync(uint112 reserve0, uint112 reserve1);

    function MINIMUM_LIQUIDITY() external pure returns (uint256);

    function factory() external view returns (address);

    function token0() external view returns (address);

    function token1() external view returns (address);

    function getReserves()
        external
        view
        returns (
            uint112 reserve0,
            uint112 reserve1,
            uint32 blockTimestampLast
        );

    function price0CumulativeLast() external view returns (uint256);

    function price1CumulativeLast() external view returns (uint256);

    function kLast() external view returns (uint256);

    function mint(address to) external returns (uint256 liquidity);

    function burn(address to)
        external
        returns (uint256 amount0, uint256 amount1);

    function swap(
        uint256 amount0Out,
        uint256 amount1Out,
        address to,
        bytes calldata data
    ) external;

    function skim(address to) external;

    function sync() external;
}

interface IUniswapV2Factory {
    event PairCreated(
        address indexed token0,
        address indexed token1,
        address pair,
        uint256
    );

    function getPair(address tokenA, address tokenB)
        external
        view
        returns (address pair);

    function allPairs(uint256) external view returns (address pair);

    function allPairsLength() external view returns (uint256);

    function feeTo() external view returns (address);

    function feeToSetter() external view returns (address);

    function createPair(address tokenA, address tokenB)
        external
        returns (address pair);
}

interface IController {
    function vaults(address) external view returns (address);

    function rewards() external view returns (address);

    function devfund() external view returns (address);

    function treasury() external view returns (address);

    function balanceOf(address) external view returns (uint256);

    function withdraw(address, uint256) external;

    function earn(address, uint256) external;
}

interface IMasterchef {
    function notifyBuybackReward(uint256 _amount) external;
}

abstract contract StrategyBase {
    using SafeERC20 for IERC20;
    using Address for address;
    using SafeMath for uint256;
    
    mapping(address => bool) public benignCallers;

    uint256 public performanceFee = 30000;
    uint256 public constant performanceMax = 100000;
    
    uint256 public treasuryFee = 0;
    uint256 public constant treasuryMax = 100000;

    uint256 public devFundFee = 0;
    uint256 public constant devFundMax = 100000;

    uint256 public delayBlockRequired = 1000;
    uint256 public lastHarvestBlock;
    uint256 public lastHarvestInWant;

    bool public buybackEnabled = true;
    address public constant mmToken = 0xa283aA7CfBB27EF0cfBcb2493dD9F4330E0fd304;
    address public constant masterChef = 0xf8873a6080e8dbF41ADa900498DE0951074af577;

    address public want;
    address public constant weth = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;

    address public governance;
    address public controller;
    address public strategist;
    address public timelock;

    address public constant univ2Router2 = 0xd9e1cE17f2641f24aE83637ab66a2cca9C378B9F;
    address public constant sushiRouter = 0xd9e1cE17f2641f24aE83637ab66a2cca9C378B9F;

    constructor(address _want, address _governance, address _strategist, address _controller, address _timelock) public {
        require(_want != address(0));
        require(_governance != address(0));
        require(_strategist != address(0));
        require(_controller != address(0));
        require(_timelock != address(0));

        want = _want;
        governance = _governance;
        strategist = _strategist;
        controller = _controller;
        timelock = _timelock;
    }

    modifier onlyBenevolent {
        require(msg.sender == governance || msg.sender == strategist);
        _;
    }
    
    modifier onlyBenignCallers {
        require(msg.sender == governance || msg.sender == strategist || benignCallers[msg.sender]);
        _;
    }

    function balanceOfWant() public view returns (uint256) {
        return IERC20(want).balanceOf(address(this));
    }

    function balanceOfPool() public virtual view returns (uint256);

    function balanceOf() public view returns (uint256) {
        uint256 delayReduction = 0;
        uint256 currentBlock = block.number;
        if (delayBlockRequired > 0 && lastHarvestInWant > 0 && currentBlock.sub(lastHarvestBlock) < delayBlockRequired){
            uint256 diffBlock = lastHarvestBlock.add(delayBlockRequired).sub(currentBlock);
            delayReduction = lastHarvestInWant.mul(diffBlock).mul(1e18).div(delayBlockRequired).div(1e18);
        }
        return balanceOfWant().add(balanceOfPool()).sub(delayReduction);
    }

    function setBenignCallers(address _caller, bool _enabled) external{
        require(msg.sender == governance, "!governance");
        benignCallers[_caller] = _enabled;
    }

    function setDelayBlockRequired(uint256 _delayBlockRequired) external {
        require(msg.sender == governance, "!governance");
        delayBlockRequired = _delayBlockRequired;
    }

    function setDevFundFee(uint256 _devFundFee) external {
        require(msg.sender == timelock, "!timelock");
        devFundFee = _devFundFee;
    }

    function setTreasuryFee(uint256 _treasuryFee) external {
        require(msg.sender == timelock, "!timelock");
        treasuryFee = _treasuryFee;
    }

    function setPerformanceFee(uint256 _performanceFee) external {
        require(msg.sender == timelock, "!timelock");
        performanceFee = _performanceFee;
    }

    function setStrategist(address _strategist) external {
        require(msg.sender == governance, "!governance");
        strategist = _strategist;
    }

    function setGovernance(address _governance) external {
        require(msg.sender == governance, "!governance");
        governance = _governance;
    }

    function setBuybackEnabled(bool _buybackEnabled) external {
        require(msg.sender == governance, "!governance");
        buybackEnabled = _buybackEnabled;
    }
    
    function deposit() public virtual;

    function withdraw(IERC20 _asset) external virtual returns (uint256 balance);
    
    function getName() external virtual pure returns (string memory);
    
    function _withdrawNonWantAsset(IERC20 _asset) internal returns (uint256 balance) {
        require(msg.sender == controller, "!controller");
        require(want != address(_asset), "want");
        balance = _asset.balanceOf(address(this));
        _asset.safeTransfer(controller, balance);
    }

    function withdraw(uint256 _amount) external {
        require(msg.sender == controller, "!controller");
        uint256 _balance = IERC20(want).balanceOf(address(this));
        if (_balance < _amount) {
            _amount = _withdrawSome(_amount.sub(_balance));
            _amount = _amount.add(_balance);
        }
				
        uint256 _feeDev = _amount.mul(devFundFee).div(devFundMax);
        uint256 _feeTreasury = _amount.mul(treasuryFee).div(treasuryMax);

        address _vault = IController(controller).vaults(address(want));

        if (buybackEnabled == true && (_feeDev > 0 || _feeTreasury > 0)) {
            (address _buybackPrinciple, uint256 _buybackAmount) = _convertWantToBuyback(_feeDev.add(_feeTreasury));
            buybackAndNotify(_buybackPrinciple, _buybackAmount);
        }

        IERC20(want).safeTransfer(_vault, _amount.sub(_feeDev).sub(_feeTreasury));
    }
	
    function buybackAndNotify(address _buybackPrinciple, uint256 _buybackAmount) internal {
        if (buybackEnabled == true && _buybackAmount > 0) {
            _swapUniswap(_buybackPrinciple, mmToken, _buybackAmount);
            uint256 _mmBought = IERC20(mmToken).balanceOf(address(this));
            IERC20(mmToken).safeTransfer(masterChef, _mmBought);
            IMasterchef(masterChef).notifyBuybackReward(_mmBought);
        }
    }
    
    bool public emergencyExit;
    function setEmergencyExit(bool _enable) external {
        require(msg.sender == governance, "!governance");
        emergencyExit = _enable;
    }

    function withdrawAll() external returns (uint256 balance) {
        require(msg.sender == controller, "!controller");
        if (!emergencyExit) {
            _withdrawAll();
        }
        balance = IERC20(want).balanceOf(address(this));
        address _vault = IController(controller).vaults(address(want));
        IERC20(want).safeTransfer(_vault, balance);
    }

    function _withdrawAll() internal {
        _withdrawSome(balanceOfPool());
    }

    function _withdrawSome(uint256 _amount) internal virtual returns (uint256);	
	
    function _convertWantToBuyback(uint256 _lpAmount) internal virtual returns (address, uint256);
    
    function harvest() public virtual;
    
    function figureOutPath(address _from, address _to, uint256 _amount) public view returns (bool useSushi, address[] memory swapPath){
        address[] memory path;
        address[] memory sushipath;
        
        path = new address[](2);
        path[0] = _from;
        path[1] = _to;
        
        if (_to == mmToken && buybackEnabled == true) {
            sushipath = new address[](2);
            sushipath[0] = _from;
            sushipath[1] = _to;
        }

        uint256 _sushiOut = sushipath.length > 0? UniswapRouterV2(sushiRouter).getAmountsOut(_amount, sushipath)[sushipath.length - 1] : 0;
        uint256 _uniOut = sushipath.length > 0? UniswapRouterV2(univ2Router2).getAmountsOut(_amount, path)[path.length - 1] : 1;

        bool useSushi = _sushiOut > _uniOut? true : false;		
        address[] memory swapPath = useSushi ? sushipath : path;
		
        return (useSushi, swapPath);
    }
	
    function _swapUniswap(address _from, address _to, uint256 _amount) internal {
        (bool useSushi, address[] memory swapPath) = figureOutPath(_from, _to, _amount);
        address _router = useSushi? sushiRouter : univ2Router2;
        _swapUniswapWithDetailConfig(_from, _to, _amount, 1, swapPath, _router);
        
    }
	
    function _swapUniswapWithDetailConfig(address _from, address _to, uint256 _amount, uint256 _amountOutMin, address[] memory _swapPath, address _router) internal {
        require(IERC20(_from).balanceOf(address(this)) >= _amount, '!notEnoughtAmountIn');
        if (_amount > 0){			
            IERC20(_from).safeApprove(_router, 0);
            IERC20(_from).safeApprove(_router, _amount);
            UniswapRouterV2(_router).swapExactTokensForTokens(_amount, _amountOutMin, _swapPath, address(this), now);
        }
    }
}

interface Vesting02 {
    function withdraw(uint64 vestID) external returns (uint256 withdrawnAmount);
    function getVestWithdrawableAmount(uint64 vestID) external view returns (uint256);
    function depositIDToVestID(address dInterest, uint64 depositId) external view returns (uint64);
}

interface DInterest {
  
    function topupDeposit(uint64 depositID, uint256 depositAmount) external returns (uint256 interestAmount);
    function deposit(uint256 amount, uint64 maturationTimestamp) external returns (uint64 depositID, uint256 interestAmount);  
    function withdraw(uint64 depositID, uint256 virtualTokenAmount, bool early) external returns (uint256 withdrawnStablecoinAmount);
    function getDeposit(uint64 depositID) external view returns (uint256 virtualTokenTotalSupply, uint256 interestRate, uint256 feeRate, uint256 averageRecordedIncomeIndex, uint64 maturationTimestamp, uint64 fundingID);

}

interface IERC721Receiver {
	
    function onERC721Received(address operator, address from, uint256 tokenId, bytes calldata data) external returns (bytes4);
}

abstract contract Strategy88MphBase is StrategyBase, IERC721Receiver {
    address public vesting = 0xA907C7c3D13248F08A3fb52BeB6D1C079507Eb4B;//veMPH
    address public mphMinter = 0x01C2fEe5d6e76ec26162DAAF4e336BEed01F2651;
    address public mphToken = 0x8888801aF4d980682e47f1A9036e589479e835C5;
    uint256 public keepMphMax = 10000;
    uint64 public depositLockTime = (604800 * 2) + 3600;// 14 days plus one hour

    address public asset;
    address public dinterest;
    uint256 public minDeposit;
    uint256 public maxDeposit;
    uint256 public keepMph;
	
    uint256 public constant maxDepositsInOneTx = 1;	
    uint64[] public deposits;
    mapping(uint64 => uint64) public fundings;
    uint64 public currentVestingId;

    bytes4 private constant _ERC721_RECEIVED = 0x150b7a02;
	
    event depositInto88Mph(uint256 amount, uint64 depositId, uint64 vestingId, uint64 matureTimestamp);
    event fundingDepositIn88Mph(uint64 depositId, uint64 fundingId);
    event withdrawFrom88Mph(uint64 depositId, uint64 fundingId, bool earlyWithdraw);
    event claimVestedMph(uint64 depositId, uint64 vestingId, uint256 claimAmount);

    constructor(
        address _asset,
        address _dinterest,
        uint256 _minDeposit,
        uint256 _maxDeposit,
        uint256 _keepMph,
        address _want,
        address _governance,
        address _strategist,
        address _controller,
        address _timelock
    )
        public
        StrategyBase(_want, _governance, _strategist, _controller, _timelock)
    {
        require(_want == _asset, '!mismatchWant');
		
        deposits = new uint64[](maxDepositsInOneTx);
		
        asset = _asset;
        dinterest = _dinterest;		    
        minDeposit = _minDeposit;   
        maxDeposit = _maxDeposit;
        keepMph = _keepMph;
		
        IERC20(want).approve(dinterest, uint256(-1));
        IERC20(mphToken).approve(mphMinter, uint256(-1)); // _keepMph
    }

	
    modifier onlyWithActiveDeposit {
        require(deposits[0] > 0, '!noActiveDeposit');
        _;
    }
	
    modifier onlyWithoutActiveDeposit {
        uint256 firstActive = 0;
        for (uint i = 0; i < maxDepositsInOneTx; i++) {
            uint256 depositId = deposits[i];
            if (depositId > 0){
                firstActive = depositId;             
                break;
            }
        }
        require(firstActive <= 0, '!existActiveDeposits');
        _;
    }

	
    function balanceOfPool() public override view returns (uint256){
        uint256 totalDeposit = 0;        
        for (uint i = 0; i < maxDepositsInOneTx; i++) {
            uint64 depositId = deposits[i];
            if (depositId <= 0){
                break;
            }
            (uint256 virtualTokenTotalSupply,,,,,) = DInterest(dinterest).getDeposit(depositId);
            totalDeposit = totalDeposit.add(virtualTokenTotalSupply);		
        }
        return totalDeposit;
    }
    
    function getHarvestable() public view returns (uint256) {
        if (deposits[0] == 0){
            return 0;
        }
        return Vesting02(vesting).getVestWithdrawableAmount(currentVestingId);
    }
	
    function depositMatureTime() public view returns (uint64){	   
        if (deposits[0] == 0){
            return 0;
        }
        (,,,,uint64 _matureTimestamp,) = DInterest(dinterest).getDeposit(deposits[0]);
        return _matureTimestamp;
    }

    function _convertWantToBuyback(uint256 _lpAmount) internal virtual override returns (address, uint256);

 
    function updateDepositFundings(uint64[] calldata _depositFundings) external onlyBenevolent {
        require(_depositFundings.length >= 2, '!invalidLength');
        for (uint i = 0; i < _depositFundings.length; i = i + 2) {
            uint64 depositId = _depositFundings[i];
            uint64 fundingId = _depositFundings[i + 1];
            if (depositId > 0 && fundingId > 0){
                fundings[depositId] = fundingId;
                emit fundingDepositIn88Mph(depositId, fundingId);
            }
        }
    }		
 
    function syncActiveVestingId() external onlyBenevolent {
        currentVestingId = Vesting02(vesting).depositIDToVestID(dinterest, deposits[0]);
    }	
 
    function setDepositLockTime(uint64 _depositLockTime) external onlyBenevolent {
        depositLockTime = _depositLockTime;
    }
 
    function setMinDeposit(uint256 _minDeposit) external onlyBenevolent {
        minDeposit = _minDeposit;
    }	
 
    function setMaxDeposit(uint256 _maxDeposit) external onlyBenevolent {
        maxDeposit = _maxDeposit;
    }	
	
    function setKeepMph(uint256 _keepMph) external onlyBenevolent {
        keepMph = _keepMph;
    }
	
    
    function onERC721Received(address operator, address from, uint256 tokenId, bytes memory data) public override returns(bytes4) {
        return _ERC721_RECEIVED;
    }
    
    function _depositOne(uint256 _want, uint64 matureTimestamp, uint idx) internal {
        require(idx <= maxDepositsInOneTx - 1, '!invalidDepositCount');
        
        (uint64 _depId, uint256 _interestAmount) = DInterest(dinterest).deposit(_want, matureTimestamp);
        deposits[idx] = _depId;
        
        currentVestingId = Vesting02(vesting).depositIDToVestID(dinterest, deposits[0]);
        require(currentVestingId > 0, '!invalidVestingId');
        fundings[deposits[idx]] = 0;
        
        emit depositInto88Mph(_want, _depId, currentVestingId, matureTimestamp);
    }
    
    function _withdrawOne(uint64 depositId, uint idx, bool earlyWithdraw) internal {
        uint64 fundingId = fundings[depositId];
        delete fundings[depositId];
        delete deposits[idx];
        
        DInterest(dinterest).withdraw(depositId, type(uint256).max, earlyWithdraw);
        emit withdrawFrom88Mph(depositId, fundingId, earlyWithdraw);
    }
    
    function _withdrawAllDeposits(bool earlyWithdraw) internal onlyWithActiveDeposit {               
        for (uint i = 0; i < maxDepositsInOneTx; i++) {
            uint64 depositId = deposits[i];
            if (depositId <= 0){
                break;
            }
            _withdrawOne(depositId, i, earlyWithdraw);
        }
    }
    	
    function earlyWithdrawAll() external onlyBenevolent onlyWithActiveDeposit {               
        _withdrawAllDeposits(true);
    } 
		
    function deposit() public override onlyWithoutActiveDeposit {
        uint256 _want = IERC20(want).balanceOf(address(this));
        require(_want >= minDeposit, '!lessThanMinDeposit');
		
        require(block.timestamp <= type(uint64).max, "blockTimeOVERFLOW");
        uint64 matureTimestamp = uint64(block.timestamp.add(depositLockTime));
        
        uint256 depositInMax = _want >= maxDeposit? _want.div(maxDeposit) : 0;
        if (depositInMax > 0){
            for (uint i = 0; i < depositInMax; i++){
                 _depositOne(maxDeposit, matureTimestamp, i);			     
            }
        }
			
        uint256 residue = _want.sub(depositInMax > 0? depositInMax.mul(maxDeposit) : 0);
        if (residue >= minDeposit){	
            _depositOne(residue, matureTimestamp, maxDepositsInOneTx - 1);
        }
        
        _want = IERC20(want).balanceOf(address(this));
        if (_want > 0){
            address _vault = IController(controller).vaults(address(want));
            require(_vault != address(0), "!vault"); // additional protection so we don't burn the funds
            IERC20(want).safeTransfer(_vault, _want);
        }
    }

    function _withdrawSome(uint256 _amount) internal override returns (uint256) {
        if (deposits[0] == 0) {
            return 0;
        }
        
        uint64 _matureTimestamp = depositMatureTime();
        require(block.timestamp > _matureTimestamp, '!notMatureYet');
        
        _withdrawAllDeposits(false);
        return _amount;
    }
    
    function withdraw(IERC20 _asset) external override returns (uint256 balance) {
        require(address(_asset) != mphToken, '!mphToken');
        balance = _withdrawNonWantAsset(_asset);
    }
    
}

contract Strategy88MphUNIV1 is Strategy88MphBase {
    address public uni_asset = 0x1f9840a85d5aF5bf1D1762F925BDADdC4201F984;
    address public uni_dinterest = 0x5dda04b2BDBBc3FcFb9B60cd9eBFd1b27f1A4fE3;
    uint256 public uni_min_deposit = 2000000000000000000;
    uint256 public uni_max_deposit = type(uint256).max;
    uint256 public uni_keep_mph = 0;

    constructor(address _governance, address _strategist, address _controller, address _timelock) 
        public Strategy88MphBase(
            uni_asset,
            uni_dinterest,
            uni_min_deposit,
            uni_max_deposit,			
            uni_keep_mph,
            uni_asset,
            _governance,
            _strategist,
            _controller,
            _timelock
        )
    {
	   
    }
	

    	
	
    function harvest() public override onlyBenignCallers {
        uint256 claimedAmount = Vesting02(vesting).withdraw(currentVestingId);
        emit claimVestedMph(deposits[0], currentVestingId, claimedAmount);
		
        uint256 _mph = claimedAmount.mul(keepMphMax.sub(keepMph)).div(keepMphMax);
        if (_mph > 0) {
            _swapUniswap(mphToken, weth, _mph);
        }

        uint256 _weth = IERC20(weth).balanceOf(address(this));
        uint256 _buybackAmount = _weth.mul(performanceFee).div(performanceMax);

        if (buybackEnabled == true && _buybackAmount > 0) {
            buybackAndNotify(weth, _buybackAmount);
        } else {
            if (_weth > 0) {
                IERC20(weth).safeTransfer(IController(controller).treasury(), _buybackAmount);
            }
        }

        if (_weth > 0){
            _swapUniswap(weth, uni_asset, _weth.sub(_buybackAmount));
            lastHarvestBlock = block.number;
            lastHarvestInWant = balanceOfWant();
        }
    }
	
    function _convertWantToBuyback(uint256 _lpAmount) internal override returns (address, uint256){
        _swapUniswap(want, weth, _lpAmount);
        uint256 _weth = IERC20(weth).balanceOf(address(this));	
        return (weth, _weth);
    }


    function getName() external override pure returns (string memory) {
        return "Strategy88MphUNIV1";
    }
}