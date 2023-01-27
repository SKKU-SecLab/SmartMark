
pragma solidity ^0.6.2;


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

interface Vesting {
  
    function withdrawVested(address account, uint256 vestIdx) external returns (uint256 withdrawnAmount);
    function accountVestList(address account, uint256 vestIdx) external view returns (uint256 amount, 
	                                                                             uint256 vestPeriodInSeconds,
	                                                                             uint256 creationTimestamp, 
	                                                                             uint256 withdrawnAmount);																				 
    function getVestWithdrawableAmount(address account, uint256 vestIdx) external view returns (uint256 withdrawableAmount);

}

interface IStakingRewards {
    function balanceOf(address account) external view returns (uint256);

    function earned(address account) external view returns (uint256);

    function exit() external;

    function getReward() external;

    function getRewardForDuration() external view returns (uint256);

    function lastTimeRewardApplicable() external view returns (uint256);

    function lastUpdateTime() external view returns (uint256);

    function notifyRewardAmount(uint256 reward) external;

    function periodFinish() external view returns (uint256);

    function rewardPerToken() external view returns (uint256);

    function rewardPerTokenStored() external view returns (uint256);

    function rewardRate() external view returns (uint256);

    function rewards(address) external view returns (uint256);

    function rewardsDistribution() external view returns (address);

    function rewardsDuration() external view returns (uint256);

    function rewardsToken() external view returns (address);

    function stake(uint256 amount) external;

    function stakeWithPermit(
        uint256 amount,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external;

    function stakingToken() external view returns (address);

    function totalSupply() external view returns (uint256);

    function userRewardPerTokenPaid(address) external view returns (uint256);

    function withdraw(uint256 amount) external;
}

interface IStakingRewardsFactory {
    function deploy(address stakingToken, uint256 rewardAmount) external;

    function isOwner() external view returns (bool);

    function notifyRewardAmount(address stakingToken) external;

    function notifyRewardAmounts() external;

    function owner() external view returns (address);

    function renounceOwnership() external;

    function rewardsToken() external view returns (address);

    function stakingRewardsGenesis() external view returns (uint256);

    function stakingRewardsInfoByStakingToken(address)
        external
        view
        returns (address stakingRewards, uint256 rewardAmount);

    function stakingTokens(uint256) external view returns (address);

    function transferOwnership(address newOwner) external;
}

interface IMasterchef {
    function BONUS_MULTIPLIER() external view returns (uint256);

    function add(
        uint256 _allocPoint,
        address _lpToken,
        bool _withUpdate
    ) external;

    function bonusEndBlock() external view returns (uint256);

    function deposit(uint256 _pid, uint256 _amount) external;

    function dev(address _devaddr) external;

    function devFundDivRate() external view returns (uint256);

    function devaddr() external view returns (address);

    function emergencyWithdraw(uint256 _pid) external;

    function getMultiplier(uint256 _from, uint256 _to)
        external
        view
        returns (uint256);

    function massUpdatePools() external;

    function owner() external view returns (address);

    function pendingMM(uint256 _pid, address _user)
        external
        view
        returns (uint256);

    function mm() external view returns (address);

    function mmPerBlock() external view returns (uint256);

    function poolInfo(uint256)
        external
        view
        returns (
            address lpToken,
            uint256 allocPoint,
            uint256 lastRewardBlock,
            uint256 accMMPerShare
        );

    function poolLength() external view returns (uint256);

    function renounceOwnership() external;

    function set(
        uint256 _pid,
        uint256 _allocPoint,
        bool _withUpdate
    ) external;

    function setBonusEndBlock(uint256 _bonusEndBlock) external;

    function setDevFundDivRate(uint256 _devFundDivRate) external;

    function setMMPerBlock(uint256 _mmPerBlock) external;

    function startBlock() external view returns (uint256);

    function totalAllocPoint() external view returns (uint256);

    function transferOwnership(address newOwner) external;

    function updatePool(uint256 _pid) external;

    function userInfo(uint256, address)
        external
        view
        returns (uint256 amount, uint256 rewardDebt);

    function withdraw(uint256 _pid, uint256 _amount) external;

    function notifyBuybackReward(uint256 _amount) external;
}

abstract contract StrategyBase {
    using SafeERC20 for IERC20;
    using Address for address;
    using SafeMath for uint256;

    uint256 public performanceFee = 30000;
    uint256 public constant performanceMax = 100000;

    uint256 public treasuryFee = 140;
    uint256 public constant treasuryMax = 100000;

    uint256 public devFundFee = 60;
    uint256 public constant devFundMax = 100000;

    bool public buybackEnabled = true;
    address public mmToken = 0xa283aA7CfBB27EF0cfBcb2493dD9F4330E0fd304;
    address public masterChef = 0xf8873a6080e8dbF41ADa900498DE0951074af577;
	
    address public want;
    address public constant weth = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;

    address public constant usdcBuyback = 0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48;
    address public constant usdtBuyback = 0xdAC17F958D2ee523a2206206994597C13D831ec7;
    address public constant wbtcBuyback = 0x2260FAC5E5542a773Aa44fBCfeDf7C193bc2C599;
    address public constant renbtcBuyback = 0xEB4C2781e4ebA804CE9a9803C67d0893436bB27D;
    address public constant mirBuyback = 0x09a3EcAFa817268f77BE1283176B946C4ff2E608;
    address public constant ustBuyback = 0xa47c8bf37f92aBed4A126BDA807A7b7498661acD;

    address public governance;
    address public controller;
    address public strategist;
    address public timelock;

    address public univ2Router2 = 0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D;

    constructor(
        address _want,
        address _governance,
        address _strategist,
        address _controller,
        address _timelock
    ) public {
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
        require(
            msg.sender == tx.origin ||
                msg.sender == governance ||
                msg.sender == strategist
        );
        _;
    }


    function balanceOfWant() public view returns (uint256) {
        return IERC20(want).balanceOf(address(this));
    }

    function balanceOfPool() public virtual view returns (uint256);

    function balanceOf() public view returns (uint256) {
        return balanceOfWant().add(balanceOfPool());
    }

    function getName() external virtual pure returns (string memory);


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

    function setTimelock(address _timelock) external {
        require(msg.sender == timelock, "!timelock");
        timelock = _timelock;
    }

    function setController(address _controller) external {
        require(msg.sender == timelock, "!timelock");
        controller = _controller;
    }

    function setMmToken(address _mmToken) external {
        require(msg.sender == governance, "!governance");
        mmToken = _mmToken;
    }

    function setBuybackEnabled(bool _buybackEnabled) external {
        require(msg.sender == governance, "!governance");
        buybackEnabled = _buybackEnabled;
    }

    function setMasterChef(address _masterChef) external {
        require(msg.sender == governance, "!governance");
        masterChef = _masterChef;
    }

    function deposit() public virtual;

    function withdraw(IERC20 _asset) external returns (uint256 balance) {
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

        if (buybackEnabled == true) {            
            (address _buybackPrinciple, uint256 _buybackAmount) = _convertWantToBuyback(_feeDev.add(_feeTreasury));
            buybackAndNotify(_buybackPrinciple, _buybackAmount);			
        } else {
            IERC20(want).safeTransfer(IController(controller).devfund(), _feeDev);
            IERC20(want).safeTransfer(IController(controller).treasury(), _feeTreasury);
        }        

        address _vault = IController(controller).vaults(address(want));
        require(_vault != address(0), "!vault"); // additional protection so we don't burn the funds

        IERC20(want).safeTransfer(_vault, _amount.sub(_feeDev).sub(_feeTreasury));
    }
	
    function buybackAndNotify(address _buybackPrinciple, uint256 _buybackAmount) internal {
        if (buybackEnabled == true) {
            _swapUniswap(_buybackPrinciple, mmToken, _buybackAmount);
            uint256 _mmBought = IERC20(mmToken).balanceOf(address(this));
            IERC20(mmToken).safeTransfer(masterChef, _mmBought);
            IMasterchef(masterChef).notifyBuybackReward(_mmBought);
        }
    }

    function withdrawAll() external returns (uint256 balance) {
        require(msg.sender == controller, "!controller");
        _withdrawAll();

        balance = IERC20(want).balanceOf(address(this));

        address _vault = IController(controller).vaults(address(want));
        require(_vault != address(0), "!vault"); // additional protection so we don't burn the funds
        IERC20(want).safeTransfer(_vault, balance);
    }

    function _withdrawAll() internal {
        _withdrawSome(balanceOfPool());
    }

    function _withdrawSome(uint256 _amount) internal virtual returns (uint256);	
	
    function _convertWantToBuyback(uint256 _lpAmount) internal virtual returns (address, uint256);

    function harvest() public virtual;


    function execute(address _target, bytes memory _data)
        public
        payable
        returns (bytes memory response)
    {
        require(msg.sender == timelock, "!timelock");
        require(_target != address(0), "!target");

        assembly {
            let succeeded := delegatecall(
                sub(gas(), 5000),
                _target,
                add(_data, 0x20),
                mload(_data),
                0,
                0
            )
            let size := returndatasize()

            response := mload(0x40)
            mstore(
                0x40,
                add(response, and(add(add(size, 0x20), 0x1f), not(0x1f)))
            )
            mstore(response, size)
            returndatacopy(add(response, 0x20), 0, size)

            switch iszero(succeeded)
                case 1 {
                    revert(add(response, 0x20), size)
                }
        }
    }

    function _swapUniswap(
        address _from,
        address _to,
        uint256 _amount
    ) internal {
        require(_to != address(0));

        IERC20(_from).safeApprove(univ2Router2, 0);
        IERC20(_from).safeApprove(univ2Router2, _amount);

        address[] memory path;

        if (_to == mmToken && buybackEnabled == true) {
            if (_from == usdcBuyback){
                path = new address[](2);
                path[0] = _from;
                path[1] = _to;			   
            }else if(_from == renbtcBuyback || _from == wbtcBuyback){
                path = new address[](4);
                path[0] = _from;
                path[1] = weth;
                path[2] = usdcBuyback;
                path[3] = _to;
            }else if(_from == ustBuyback){
                path = new address[](4);
                path[0] = _from;
                path[1] = usdtBuyback;
                path[2] = usdcBuyback;
                path[3] = _to;
            }else{
                path = new address[](3);
                path[0] = _from;
                path[1] = usdcBuyback;
                path[2] = _to;
            }
        } else{		
            if (_from == weth || _to == weth || _to == ustBuyback) {
                path = new address[](2);
                path[0] = _from;
                path[1] = _to;
            } else if (_from == mirBuyback) {
                path = new address[](3);
                path[0] = _from;
                path[1] = ustBuyback;
                path[2] = _to;
            } else {
                path = new address[](3);
                path[0] = _from;
                path[1] = weth;
                path[2] = _to;
            }		
        }

        UniswapRouterV2(univ2Router2).swapExactTokensForTokens(
            _amount,
            0,
            path,
            address(this),
            now.add(60)
        );
    }
}

interface DInterest {
  

    function fundMultiple(uint256 toDepositID) external;
    function fundingListLength() external view returns (uint256 fundingListLength); 
    function getFunding(uint256 fundingID) external view returns (uint256 fromDepositID, 
	                                                              uint256 toDepositID, 
	                                                              uint256 recordedFundedDepositAmount, 
	                                                              uint256 recordedMoneyMarketIncomeIndex, 
	                                                              uint256 creationTimestamp);
    function depositsLength() external view returns (uint256 depositsLength); 
    function deposit(uint256 amount, uint256 maturationTimestamp) external;  
    function withdraw(uint256 depositID, uint256 fundingID) external;
    function earlyWithdraw(uint256 depositID, uint256 fundingID) external;
    function getDeposit(uint256 depositID) external view returns (uint256 amount, 
	                                                              uint256 maturationTimestamp, 
	                                                              uint256 interestOwed, 
	                                                              uint256 initialMoneyMarketIncomeIndex, 
	                                                              bool active, 
	                                                              bool finalSurplusIsNegative, 
	                                                              uint256 finalSurplusAmount, 
	                                                              uint256 mintMPHAmount, 
	                                                              uint256 depositTimestamp);

}

interface IERC721Receiver {
	
    function onERC721Received(address operator, address from, uint256 tokenId, bytes calldata data) external returns (bytes4);
}

abstract contract Strategy88MphBase is StrategyBase, IERC721Receiver {
    address public vesting = 0x8943eb8F104bCf826910e7d2f4D59edfe018e0e7;
    address public mphMinter = 0x03577A2151A10675a9689190fE5D331Ee7ff2517;
    address public mphToken = 0x8888801aF4d980682e47f1A9036e589479e835C5;
    uint256 public keepMphMax = 10000;
    uint256 public depositLockTime = (604800 * 2) + 3600;// 14 days plus one hour

    address public asset;
    address public dinterest;
    uint256 public minDeposit;
    uint256 public maxDeposit;
    uint256 public keepMph;
	
    uint256 public maxDepositsInOneTx = 20;	
    uint256[20] public deposits;
    mapping(uint256 => uint256) public fundings;
    uint256 public startVestingIdx = 0;
    uint256 public activeVestingNum = 0;

    mapping(address => bool) public keepers;

    bytes4 private constant _ERC721_RECEIVED = 0x150b7a02;
	
    event depositInto88Mph(uint256 amount, uint256 depositId, uint256 matureTimestamp);
    event fundingDepositIn88Mph(uint256 depositId, uint256 fundingId);
    event withdrawFrom88Mph(uint256 depositId, uint256 fundingId);
    event claimVestedMph(uint256 vestingIdx, uint256 claimAmount);

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
		
        asset = _asset;
        dinterest = _dinterest;		    
        minDeposit = _minDeposit;   
        maxDeposit = _maxDeposit;
        keepMph = _keepMph;
		
        IERC20(want).approve(dinterest, uint256(-1));
        IERC20(mphToken).approve(mphMinter, uint256(-1));
    }


    modifier onlyKeepers {
        require(
            keepers[msg.sender] ||
                msg.sender == address(this) ||
                msg.sender == strategist ||
                msg.sender == governance,
            "!keepers"
        );
        _;
    }
	
    modifier onlyGovernanceAndStrategist {
        require(msg.sender == governance || msg.sender == strategist, "!governance");
        _;
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
            uint256 depositId = deposits[i];
            if (depositId <= 0){
                break;
            }
            (uint256 amount,,uint256 interestOwed,,,,,,) = DInterest(dinterest).getDeposit(depositId);
            totalDeposit = totalDeposit.add(amount).add(interestOwed);		
        }
        return totalDeposit;
    }
    
    function vestWithdrawable() external view onlyWithActiveDeposit returns (uint256) {
        uint256 withdrawableAmount = 0;
        for (uint i = 0;i < activeVestingNum;i++){
            withdrawableAmount = withdrawableAmount.add(Vesting(vesting).getVestWithdrawableAmount(address(this), startVestingIdx.add(i)));
        }
        return withdrawableAmount;
    }

    function _convertWantToBuyback(uint256 _lpAmount) internal virtual override returns (address, uint256);

 
    function updateDepositFundings(uint256[] calldata _depositFundings) external onlyGovernanceAndStrategist {
	    require(_depositFundings.length >= 2, '!invalidLength');
        for (uint i = 0; i < _depositFundings.length; i = i + 2) {
            uint256 depositId = _depositFundings[i];
            uint256 fundingId = _depositFundings[i + 1];
            if (depositId > 0 && fundingId > 0){
                fundings[depositId] = fundingId;
                emit fundingDepositIn88Mph(depositId, fundingId);
            }
        }
    }		
 
    function syncStartVestingIdxAndActiveVestingNum(uint256 _startVestingIdx, uint256 _activeVestingNum) external onlyGovernanceAndStrategist {
        startVestingIdx = _startVestingIdx;
        activeVestingNum = _activeVestingNum;
    }	
 
    function setDepositLockTime(uint256 _depositLockTime) external onlyGovernanceAndStrategist {
        depositLockTime = _depositLockTime;
    }
 
    function setMinDeposit(uint256 _minDeposit) external onlyGovernanceAndStrategist {
        minDeposit = _minDeposit;
    }	
 
    function setMaxDeposit(uint256 _maxDeposit) external onlyGovernanceAndStrategist {
        maxDeposit = _maxDeposit;
    }	
	
    function setKeepMph(uint256 _keepMph) external onlyGovernanceAndStrategist {
        keepMph = _keepMph;
    }	

    function addKeeper(address _keeper) external onlyGovernanceAndStrategist {
        keepers[_keeper] = true;
    }

    function removeKeeper(address _keeper) external onlyGovernanceAndStrategist {
        keepers[_keeper] = false;
    }
	
    
    function onERC721Received(address operator, address from, uint256 tokenId, bytes memory data) public override returns(bytes4) {
        return _ERC721_RECEIVED;
    }
    
    function _depositOne(uint256 _want, uint256 matureTimestamp, uint idx) internal {
        DInterest(dinterest).deposit(_want, matureTimestamp);
        deposits[idx] = DInterest(dinterest).depositsLength();
        fundings[deposits[idx]] = 0;
        emit depositInto88Mph(_want, deposits[idx], matureTimestamp);
    }
    
    function _withdrawOne(uint256 depositId, uint idx, bool earlyWithdraw) internal {
        uint256 fundingId = fundings[depositId];
        delete fundings[depositId];
        delete deposits[idx];
        if (earlyWithdraw){
            DInterest(dinterest).earlyWithdraw(depositId, fundingId);
        } else{
            DInterest(dinterest).withdraw(depositId, fundingId);
        }
        emit withdrawFrom88Mph(depositId, fundingId);
    }
    
    function _withdrawAllDeposits(bool earlyWithdraw) internal onlyWithActiveDeposit {               
        for (uint i = 0; i < maxDepositsInOneTx; i++) {
            uint256 depositId = deposits[i];
            if (depositId <= 0){
                break;
            }
            _withdrawOne(depositId, i, earlyWithdraw);
        }
    }
    	
    function earlyWithdrawAll() external onlyGovernanceAndStrategist onlyWithActiveDeposit {               
        _withdrawAllDeposits(true);
    } 
		
    function deposit() public override onlyWithoutActiveDeposit {
        uint256 _want = IERC20(want).balanceOf(address(this));
        require(_want >= minDeposit, '!lessThanMinDeposit');
		
        startVestingIdx = startVestingIdx + activeVestingNum;
        uint256 matureTimestamp = block.timestamp.add(depositLockTime);
        
        uint256 depositInMax = _want.div(maxDeposit);
        activeVestingNum = depositInMax;
        for (uint i = 0; i < depositInMax; i++){
            _depositOne(maxDeposit, matureTimestamp, i);			     
        }
			
        uint256 residue = _want.sub(depositInMax.mul(maxDeposit));
        if (residue >= minDeposit){	
            activeVestingNum = activeVestingNum.add(1);
            _depositOne(residue, matureTimestamp, depositInMax);
        }
        
        _want = IERC20(want).balanceOf(address(this));
        if (_want > 0){
            address _vault = IController(controller).vaults(address(want));
            require(_vault != address(0), "!vault"); // additional protection so we don't burn the funds
            IERC20(want).safeTransfer(_vault, _want);
        }
    }

    function _withdrawSome(uint256 _amount) internal override onlyWithActiveDeposit returns (uint256) {
        _withdrawAllDeposits(false);
        return _amount;
    }
    
}

contract Strategy88MphUNIV1 is Strategy88MphBase {
    address public uni_asset = 0x1f9840a85d5aF5bf1D1762F925BDADdC4201F984;
    address public uni_dinterest = 0x19E10132841616CE4790920d5f94B8571F9b9341;
    uint256 public uni_min_deposit = 51000000000000000000;
    uint256 public uni_max_deposit = 49999000000000000000000;
    uint256 public uni_keep_mph = 3001;

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
	

    	
	
    function harvest() public override onlyBenevolent {
        uint256 claimedAmount = 0;
        for (uint i = 0;i < activeVestingNum;i++){
            uint256 vid = startVestingIdx.add(i);
            uint256 _mphAward = Vesting(vesting).withdrawVested(address(this), vid);
            claimedAmount = claimedAmount.add(_mphAward);
            emit claimVestedMph(vid, _mphAward);
        }
		
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