
pragma solidity 0.6.6;

interface IDeFiatPoints {

    function viewDiscountOf(address _address) external view returns (uint256);

    function viewEligibilityOf(address _address) external view returns (uint256 tranche);

    function discountPointsNeeded(uint256 _tranche) external view returns (uint256 pointsNeeded);

    function viewTxThreshold() external view returns (uint256);

    function viewRedirection(address _address) external view returns (bool);


    function overrideLoyaltyPoints(address _address, uint256 _points) external;

    function addPoints(address _address, uint256 _txSize, uint256 _points) external;

    function burn(uint256 _amount) external;

}// MIT

pragma solidity 0.6.6;

interface IAnyStake {

    function addReward(uint256 amount) external;

    function claim(uint256 pid) external;

    function deposit(uint256 pid, uint256 amount) external;

    function withdraw(uint256 pid, uint256 amount) external;

}// MIT


pragma solidity 0.6.6;

interface IAnyStakeMigrator {

    function migrateTo(address user, address token, uint256 amount) external;

}// MIT

pragma solidity 0.6.6;

interface IAnyStakeVault {

    function buyDeFiatWithTokens(address token, uint256 amount) external;

    function buyPointsWithTokens(address token, uint256 amount) external;


    function calculateRewards() external;

    function distributeRewards(address recipient, uint256 amount) external;

    function getTokenPrice(address token, address lpToken) external view returns (uint256);

}// MIT

pragma solidity >=0.6.0 <0.8.0;

interface IERC20 {

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);

    function totalSupply() external view returns (uint256);


    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount) external returns (bool);

    function allowance(address owner, address spender) external view returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);


    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}// MIT

pragma solidity 0.6.6;

abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}// MIT

pragma solidity >=0.6.0 <0.8.0;


abstract contract Ownable is Context {
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
}// MIT

pragma solidity 0.6.6;


abstract contract DeFiatUtils is Ownable {
    event TokenSweep(address indexed user, address indexed token, uint256 amount);

    function sweep(address token) public virtual onlyOwner {
        uint256 amount = IERC20(token).balanceOf(address(this));
        require(amount > 0, "Sweep: No token balance");

        IERC20(token).transfer(msg.sender, amount); // use of the ERC20 traditional transfer

        if (address(this).balance > 0) {
            payable(msg.sender).transfer(address(this).balance);
        }

        emit TokenSweep(msg.sender, token, amount);
    }

    function kill() external onlyOwner {
        selfdestruct(payable(msg.sender));
    }
}// MIT

pragma solidity 0.6.6;

interface IDeFiatGov {

    function mastermind() external view returns (address);

    function viewActorLevelOf(address _address) external view returns (uint256);

    function viewFeeDestination() external view returns (address);

    function viewTxThreshold() external view returns (uint256);

    function viewBurnRate() external view returns (uint256);

    function viewFeeRate() external view returns (uint256);

}// MIT

pragma solidity 0.6.6;


abstract contract DeFiatGovernedUtils is DeFiatUtils {
    event GovernanceUpdated(address indexed user, address governance);

    address public governance;

    modifier onlyMastermind {
        require(
            msg.sender == IDeFiatGov(governance).mastermind() || msg.sender == owner(),
            "Gov: Only Mastermind"
        );
        _;
    }

    modifier onlyGovernor {
        require(
            IDeFiatGov(governance).viewActorLevelOf(msg.sender) >= 2 || msg.sender == owner(),
            "Gov: Only Governors"
        );
        _;
    }

    modifier onlyPartner {
        require(
            IDeFiatGov(governance).viewActorLevelOf(msg.sender) >= 1 || msg.sender == owner(),
            "Gov: Only Partners"
        );
        _;
    }

    function _setGovernance(address _governance) internal {
        require(_governance != governance, "SetGovernance: No governance change");

        governance = _governance;
        emit GovernanceUpdated(msg.sender, governance);
    }

    function setGovernance(address _governance) external onlyGovernor {
        _setGovernance(_governance);
    }
}// MIT

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
}// MIT

pragma solidity ^0.6.2;

library Address {

    function isContract(address account) internal view returns (bool) {


        uint256 size;
        assembly { size := extcodesize(account) }
        return size > 0;
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

        return functionCallWithValue(target, data, 0, errorMessage);
    }

    function functionCallWithValue(address target, bytes memory data, uint256 value) internal returns (bytes memory) {

        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    function functionCallWithValue(address target, bytes memory data, uint256 value, string memory errorMessage) internal returns (bytes memory) {

        require(address(this).balance >= value, "Address: insufficient balance for call");
        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{ value: value }(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {

        return functionStaticCall(target, data, "Address: low-level static call failed");
    }

    function functionStaticCall(address target, bytes memory data, string memory errorMessage) internal view returns (bytes memory) {

        require(isContract(target), "Address: static call to non-contract");

        (bool success, bytes memory returndata) = target.staticcall(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {

        return functionDelegateCall(target, data, "Address: low-level delegate call failed");
    }

    function functionDelegateCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {

        require(isContract(target), "Address: delegate call to non-contract");

        (bool success, bytes memory returndata) = target.delegatecall(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function _verifyCallResult(bool success, bytes memory returndata, string memory errorMessage) private pure returns(bytes memory) {

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
}// MIT

pragma solidity >=0.6.0 <0.8.0;


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
}// MIT

pragma solidity >=0.5.0;

interface IUniswapV2Factory {

    event PairCreated(address indexed token0, address indexed token1, address pair, uint);

    function feeTo() external view returns (address);

    function feeToSetter() external view returns (address);


    function getPair(address tokenA, address tokenB) external view returns (address pair);

    function allPairs(uint) external view returns (address pair);

    function allPairsLength() external view returns (uint);


    function createPair(address tokenA, address tokenB) external returns (address pair);


    function setFeeTo(address) external;

    function setFeeToSetter(address) external;

}// MIT

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

}// MIT

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

}// MIT

pragma solidity 0.6.6;


abstract contract AnyStakeUtils is DeFiatGovernedUtils {
    using SafeERC20 for IERC20;

    event PointsUpdated(address indexed user, address points);
    event TokenUpdated(address indexed user, address token);
    event UniswapUpdated(address indexed user, address router, address weth, address factory);
  
    address public router;
    address public factory;
    address public weth;
    address public DeFiatToken;
    address public DeFiatPoints;
    address public DeFiatTokenLp;
    address public DeFiatPointsLp;

    mapping (address => bool) internal _blacklistedAdminWithdraw;

    constructor(address _router, address _gov, address _points, address _token) public {
        _setGovernance(_gov);

        router = _router;
        DeFiatPoints = _points;
        DeFiatToken = _token;
         
        weth = IUniswapV2Router02(router).WETH();
        factory = IUniswapV2Router02(router).factory();
        DeFiatTokenLp = IUniswapV2Factory(factory).getPair(_token, weth);
        DeFiatPointsLp = IUniswapV2Factory(factory).getPair(_points, weth);
    }

    function sweep(address _token) public override onlyOwner {
        require(!_blacklistedAdminWithdraw[_token], "Sweep: Cannot withdraw blacklisted token");

        DeFiatUtils.sweep(_token);
    }

    function isBlacklistedAdminWithdraw(address _token)
        external
        view
        returns (bool)
    {
        return _blacklistedAdminWithdraw[_token];
    }

    function safeTokenTransfer(address user, address token, uint256 amount) internal {
        if (amount == 0) {
            return;
        }

        uint256 tokenBalance = IERC20(token).balanceOf(address(this));
        if (amount > tokenBalance) {
            IERC20(token).safeTransfer(user, tokenBalance);
        } else {
            IERC20(token).safeTransfer(user, amount);
        }
    }

    function setToken(address _token) external onlyGovernor {
        require(_token != DeFiatToken, "SetToken: No token change");
        require(_token != address(0), "SetToken: Must set token value");

        DeFiatToken = _token;
        DeFiatTokenLp = IUniswapV2Factory(factory).getPair(_token, weth);
        emit TokenUpdated(msg.sender, DeFiatToken);
    }

    function setPoints(address _points) external onlyGovernor {
        require(_points != DeFiatPoints, "SetPoints: No points change");
        require(_points != address(0), "SetPoints: Must set points value");

        DeFiatPoints = _points;
        DeFiatPointsLp = IUniswapV2Factory(factory).getPair(_points, weth);
        emit PointsUpdated(msg.sender, DeFiatPoints);
    }

    function setUniswap(address _router) external onlyGovernor {
        require(_router != router, "SetUniswap: No uniswap change");
        require(_router != address(0), "SetUniswap: Must set uniswap value");

        router = _router;
        weth = IUniswapV2Router02(router).WETH();
        factory = IUniswapV2Router02(router).factory();
        emit UniswapUpdated(msg.sender, router, weth, factory);
    }
}// MIT

pragma solidity 0.6.6;


contract AnyStake is IAnyStake, AnyStakeUtils {

    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    event Initialized(address indexed user, address vault);
    event Claim(address indexed user, uint256 indexed pid, uint256 amount);
    event Deposit(address indexed user, uint256 indexed pid, uint256 amount);
    event Withdraw(address indexed user, uint256 indexed pid, uint256 amount);
    event Migrate(address indexed user, uint256 indexed pid, uint256 amount);
    event EmergencyWithdraw(address indexed user, uint256 indexed pid, uint256 amount);
    event PoolAdded(address indexed user, uint256 indexed pid, address indexed stakedToken, address lpToken, uint256 allocPoints);
    event MigratorUpdated(address indexed user, address migrator);
    event VaultUpdated(address indexed user, address vault);
    event PoolAllocPointsUpdated(address indexed user, uint256 indexed pid, uint256 allocPoints);
    event PoolVipAmountUpdated(address indexed user, uint256 indexed pid, uint256 vipAmount);
    event PoolStakingFeeUpdated(address indexed user, uint256 indexed pid, uint256 stakingFee);
    event PointStipendUpdated(address indexed user, uint256 stipend);

    struct UserInfo {
        uint256 amount; // How many tokens the user has provided.
        uint256 rewardDebt; // Token rewards paid out to user
        uint256 lastRewardBlock; // last pool interaction
    }

    struct PoolInfo {
        address stakedToken; // Address of staked token contract.
        address lpToken; // uniswap LP token corresponding to the trading pair needed for price calculation
        uint256 totalStaked; // total tokens staked
        uint256 allocPoint; // How many allocation points assigned to this pool. DFTs to distribute per block. (ETH = 2.3M blocks per year)
        uint256 rewardsPerShare; // Accumulated DFTs per share, times 1e18. See below.
        uint256 lastRewardBlock; // last pool update
        uint256 vipAmount; // amount of DFT tokens that must be staked to access the pool
        uint256 stakingFee; // the % withdrawal fee charged. base 1000, 50 = 5%
    }

    address public migrator; // contract where we may migrate too
    address public vault; // where rewards are stored for distribution
    bool public initialized;

    PoolInfo[] public poolInfo; // array of AnyStake pools
    mapping(uint256 => mapping(address => UserInfo)) public userInfo; // mapping of (pid => (userAddress => userInfo))
    mapping(address => uint256) public pids; // quick mapping for pool ids (staked_token => pid)

    uint256 public lastRewardBlock; // last block the pool was updated
    uint256 public pendingRewards; // pending DFT rewards awaiting anyone to be distro'd to pools
    uint256 public pointStipend; // amount of DFTP awarded per deposit
    uint256 public totalAllocPoint; // Total allocation points. Must be the sum of all allocation points in all pools.
    uint256 public totalBlockDelta; // Total blocks since last update
    uint256 public totalEligiblePools; // Amount of pools eligible for rewards

    modifier NoReentrant(uint256 pid, address user) {

        require(
            block.number > userInfo[pid][user].lastRewardBlock,
            "AnyStake: Must wait 1 block"
        );
        _;
    }

    modifier onlyVault() {

        require(msg.sender == vault, "AnyStake: Only Vault allowed");
        _;
    }

    modifier activated() {

        require(initialized, "AnyStake: Not initialized yet");
        _;
    }

    constructor(address _router, address _gov, address _points, address _token) 
        public 
        AnyStakeUtils(_router, _gov, _points, _token)
    {
        pointStipend = 1e18;
    }
    
    function initialize(address _vault) public onlyGovernor {

        require(_vault != address(0), "Initalize: Must pass in Vault");
        require(!initialized, "Initialize: AnyStake already initialized");

        vault = _vault;
        initialized = true;
        emit Initialized(msg.sender, _vault);
    }

    function addReward(uint256 amount) external override onlyVault {

        if (amount == 0) {
            return;
        }

        pendingRewards = pendingRewards.add(amount);
    }

    function updatePool(uint256 pid) external {

        _updatePool(pid);
    }

    function _updatePool(uint256 _pid) internal {

        PoolInfo storage pool = poolInfo[_pid];
        if (pool.totalStaked == 0 || pool.lastRewardBlock >= block.number || pool.allocPoint == 0) {
            return;
        }

        if (lastRewardBlock < block.number) {
            totalBlockDelta = totalBlockDelta.add(block.number.sub(lastRewardBlock).mul(totalEligiblePools));
            lastRewardBlock = block.number;
        }

        IAnyStakeVault(vault).calculateRewards();        

        uint256 poolBlockDelta = block.number.sub(pool.lastRewardBlock);
        uint256 poolRewards = pendingRewards
            .mul(poolBlockDelta)
            .div(totalBlockDelta)
            .mul(pool.allocPoint)
            .div(totalAllocPoint);
        
        totalBlockDelta = poolBlockDelta > totalBlockDelta ? 0 : totalBlockDelta.sub(poolBlockDelta);
        pendingRewards = poolRewards > pendingRewards ? 0 : pendingRewards.sub(poolRewards);
        
        pool.rewardsPerShare = pool.rewardsPerShare.add(poolRewards.mul(1e18).div(pool.totalStaked));
        pool.lastRewardBlock = block.number;
    }

    function claim(uint256 pid) external override NoReentrant(pid, msg.sender) {

        _updatePool(pid);
        _claim(pid, msg.sender);
    }

    function _claim(uint256 _pid, address _user) internal {

        UserInfo storage user = userInfo[_pid][_user];

        uint256 rewards = pending(_pid, _user);
        if (rewards == 0) {
            return;
        }

        user.rewardDebt = user.amount.mul(poolInfo[_pid].rewardsPerShare).div(1e18);
        user.lastRewardBlock = block.number;

        IAnyStakeVault(vault).distributeRewards(_user, rewards);
        emit Claim(_user, _pid, rewards);
    }

    function deposit(uint256 pid, uint256 amount) external override NoReentrant(pid, msg.sender) {

        _deposit(msg.sender, pid, amount);
    }

    function _deposit(address _user, uint256 _pid, uint256 _amount) internal {

        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][_user];
        
        require(_amount > 0, "Deposit: Cannot deposit zero tokens");
        require(pool.allocPoint > 0, "Deposit: Pool is not active");
        require(pool.vipAmount <= userInfo[0][_user].amount, "Deposit: VIP Only");

        if (pool.totalStaked == 0) {
            totalEligiblePools = totalEligiblePools.add(1);
            pool.lastRewardBlock = block.number; // reset reward block

            if (lastRewardBlock == 0) {
                lastRewardBlock = block.number;
            }
        }

        _updatePool(_pid);
        _claim(_pid, _user);

        uint256 amount = IERC20(pool.stakedToken).balanceOf(address(this));
        IERC20(pool.stakedToken).safeTransferFrom(_user, address(this), _amount);
        amount = IERC20(pool.stakedToken).balanceOf(address(this)).sub(amount);

        pool.totalStaked = pool.totalStaked.add(amount);
        user.amount = user.amount.add(amount);
        user.rewardDebt = user.amount.mul(pool.rewardsPerShare).div(1e18);
        
        IDeFiatPoints(DeFiatPoints).addPoints(_user, IDeFiatPoints(DeFiatPoints).viewTxThreshold(), pointStipend);

        emit Deposit(_user, _pid, amount);
    }

    function withdraw(uint256 pid, uint256 amount) external override NoReentrant(pid, msg.sender) {

        _withdraw(msg.sender, pid, amount);
    }
    
    function _withdraw(
        address _user,
        uint256 _pid,
        uint256 _amount
    ) internal {

        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][_user];

        require(_amount > 0, "Withdraw: amount must be greater than zero");
        require(user.amount >= _amount, "Withdraw: user amount insufficient");
        require(pool.vipAmount <= userInfo[0][_user].amount, "Withdraw: VIP Only");
        
        _updatePool(_pid);
        _claim(_pid, _user);

        pool.totalStaked = pool.totalStaked.sub(_amount);
        user.amount = user.amount.sub(_amount);
        user.rewardDebt = user.amount.mul(pool.rewardsPerShare).div(1e18);

        if (pool.totalStaked == 0 && pool.allocPoint > 0) {
            totalEligiblePools = totalEligiblePools.sub(1);
        }

        uint256 stakingFeeAmount = _amount.mul(pool.stakingFee).div(1000);
        uint256 remainingUserAmount = _amount.sub(stakingFeeAmount);

        if(stakingFeeAmount > 0){
            uint256 balance = IERC20(pool.stakedToken).balanceOf(vault);
            safeTokenTransfer(vault, pool.stakedToken, stakingFeeAmount);
            balance = IERC20(pool.stakedToken).balanceOf(vault);
            IAnyStakeVault(vault).buyDeFiatWithTokens(pool.stakedToken, balance);
        }

        safeTokenTransfer(_user, pool.stakedToken, remainingUserAmount);        
        emit Withdraw(_user, _pid, remainingUserAmount);
    }

    function migrate(uint256 pid) external NoReentrant(pid, msg.sender) {

        _migrate(msg.sender, pid);
    }

    function _migrate(address _user, uint256 _pid) internal {

        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][_user];
        uint256 balance = user.amount;

        require(migrator != address(0), "Migrate: No migrator set");
        require(balance > 0, "Migrate: No tokens to migrate");
        require(pool.allocPoint == 0, "Migrate: Pool is still active");

        _claim(_pid, _user);

        IERC20(pool.stakedToken).safeApprove(migrator, balance);
        IAnyStakeMigrator(migrator).migrateTo(_user, pool.stakedToken, balance);
        emit Migrate(_user, _pid, balance);
    }

    function emergencyWithdraw(uint256 pid) external NoReentrant(pid, msg.sender) {

        PoolInfo storage pool = poolInfo[pid];
        UserInfo storage user = userInfo[pid][msg.sender];

        require(user.amount > 0, "EmergencyWithdraw: user amount insufficient");

        uint256 stakingFeeAmount = user.amount.mul(pool.stakingFee).div(1000);
        uint256 remainingUserAmount = user.amount.sub(stakingFeeAmount);
        pool.totalStaked = pool.totalStaked.sub(user.amount);
        user.amount = 0;
        user.rewardDebt = 0;
        user.lastRewardBlock = block.number;

        if (pool.totalStaked == 0) {
            totalEligiblePools = totalEligiblePools.sub(1);
        }

        safeTokenTransfer(vault, pool.stakedToken, stakingFeeAmount);
        safeTokenTransfer(msg.sender, pool.stakedToken, remainingUserAmount);
        emit EmergencyWithdraw(msg.sender, pid, remainingUserAmount);
    }

    function getPrice(uint256 pid) external view returns (uint256) {

        address token = poolInfo[pid].stakedToken;
        address lpToken = poolInfo[pid].lpToken;

        return IAnyStakeVault(vault).getTokenPrice(token, lpToken);
    }

    function pending(uint256 _pid, address _user)
        public
        view
        returns (uint256)
    {

        PoolInfo memory pool = poolInfo[_pid];
        UserInfo memory user = userInfo[_pid][_user];

        return user.amount.mul(pool.rewardsPerShare).div(1e18).sub(user.rewardDebt);
    }

    function poolLength() external view returns (uint256) {

        return poolInfo.length; // number of pools (pids)
    }

    function addPoolBatch(
        address[] calldata tokens,
        address[] calldata lpTokens,
        uint256[] calldata allocPoints,
        uint256[] calldata vipAmounts,
        uint256[] calldata stakingFees
    ) external onlyGovernor {

        for (uint i = 0; i < tokens.length; i++) {
            _addPool(tokens[i], lpTokens[i], allocPoints[i], vipAmounts[i], stakingFees[i]);
        }
    }

    function addPool(
        address token,
        address lpToken, 
        uint256 allocPoint,
        uint256 vipAmount,
        uint256 stakingFee
    ) external onlyGovernor {

        _addPool(token, lpToken, allocPoint, vipAmount, stakingFee);
    }

    function _addPool(
        address stakedToken,
        address lpToken,
        uint256 allocPoint,
        uint256 vipAmount,
        uint256 stakingFee
    ) internal {

        require(pids[stakedToken] == 0, "AddPool: Token pool already added");

        pids[stakedToken] = poolInfo.length;
        _blacklistedAdminWithdraw[stakedToken] = true; // stakedToken now non-withrawable by admins
        totalAllocPoint = totalAllocPoint.add(allocPoint);

        poolInfo.push(
            PoolInfo({
                stakedToken: stakedToken,
                lpToken: lpToken,
                allocPoint: allocPoint,
                lastRewardBlock: block.number,
                totalStaked: 0,
                rewardsPerShare: 0,
                vipAmount: vipAmount,
                stakingFee: stakingFee
            })
        );

        emit PoolAdded(msg.sender, pids[stakedToken], stakedToken, lpToken, allocPoint);
    }

    function setMigrator(address _migrator) external onlyGovernor {

        require(_migrator != address(0), "SetMigrator: No migrator change");

        migrator = _migrator;
        emit MigratorUpdated(msg.sender, _migrator);
    }

    function setVault(address _vault) external onlyGovernor {

        require(_vault != address(0), "SetVault: No migrator change");

        vault = _vault;
        emit VaultUpdated(msg.sender, vault);
    }

    function setPoolAllocPoints(uint256 _pid, uint256 _allocPoint) external onlyGovernor {

        require(poolInfo[_pid].allocPoint != _allocPoint, "SetAllocPoints: No points change");

        if (_allocPoint == 0) {
            totalEligiblePools = totalEligiblePools.sub(1);
        }

        totalAllocPoint = totalAllocPoint.sub(poolInfo[_pid].allocPoint).add(_allocPoint);
        poolInfo[_pid].allocPoint = _allocPoint;
        emit PoolAllocPointsUpdated(msg.sender, _pid, _allocPoint);
    }

    function setPoolVipAmount(uint256 _pid, uint256 _vipAmount) external onlyGovernor {

        require(poolInfo[_pid].vipAmount != _vipAmount, "SetVipAmount: No amount change");

        poolInfo[_pid].vipAmount = _vipAmount;
        emit PoolVipAmountUpdated(msg.sender, _pid, _vipAmount);
    }

    function setPoolChargeFee(uint256 _pid, uint256 _stakingFee) external onlyGovernor {

        require(poolInfo[_pid].stakingFee != _stakingFee, "SetStakingFee: No fee change");

        poolInfo[_pid].stakingFee = _stakingFee;
        emit PoolStakingFeeUpdated(msg.sender, _pid, _stakingFee);
    }

    function setPointStipend(uint256 _pointStipend) external onlyGovernor {

        require(_pointStipend != pointStipend, "SetStipend: No stipend change");

        pointStipend = _pointStipend;
        emit PointStipendUpdated(msg.sender, pointStipend);
    }
}// MIT

pragma solidity 0.6.6;


contract AnyStakeV2 is IAnyStakeMigrator, IAnyStake, AnyStakeUtils {

    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    event Initialized(address indexed user, address vault);
    event Claim(address indexed user, uint256 indexed pid, uint256 amount);
    event ClaimAll(address indexed user, uint256 amount);
    event Deposit(address indexed user, uint256 indexed pid, uint256 amount);
    event Withdraw(address indexed user, uint256 indexed pid, uint256 amount);
    event Migrate(address indexed user, uint256 indexed pid, uint256 amount);
    event EmergencyWithdraw(address indexed user, uint256 indexed pid, uint256 amount);
    event PoolAdded(address indexed user, uint256 indexed pid, address indexed stakedToken, address lpToken, uint256 allocPoints);
    event MigratorUpdated(address indexed user, address migrator);
    event VaultUpdated(address indexed user, address vault);
    event PoolAllocPointsUpdated(address indexed user, uint256 indexed pid, uint256 allocPoints);
    event PoolVipAmountUpdated(address indexed user, uint256 indexed pid, uint256 vipAmount);
    event PoolStakingFeeUpdated(address indexed user, uint256 indexed pid, uint256 stakingFee);
    event PointStipendUpdated(address indexed user, uint256 stipend);

    struct UserInfo {
        uint256 amount; // How many tokens the user has provided.
        uint256 rewardDebt; // Token rewards paid out to user
        uint256 lastRewardBlock; // last pool interaction
    }

    struct PoolInfo {
        address stakedToken; // Address of staked token contract.
        address lpToken; // uniswap LP token corresponding to the trading pair needed for price calculation
        uint256 totalStaked; // total tokens staked
        uint256 allocPoint; // How many allocation points assigned to this pool. DFTs to distribute per block. (ETH = 2.3M blocks per year)
        uint256 rewardsPerShare; // Accumulated DFTs per share, times 1e18. See below.
        uint256 lastRewardBlock; // last pool update
        uint256 vipAmount; // amount of DFT tokens that must be staked to access the pool
        uint256 stakingFee; // the % withdrawal fee charged. base 1000, 50 = 5%
        uint256 rewardDebt; // rewards paid out to the pool
    }

    address public anystake; // AnyStake V1 contract
    address public migrator; // contract where we may migrate too
    address public vault; // where rewards are stored for distribution

    PoolInfo[] public poolInfo; // array of AnyStake pools
    mapping(uint256 => mapping(address => UserInfo)) public userInfo; // mapping of (pid => (userAddress => userInfo))
    mapping(address => uint256) public pids; // quick mapping for pool ids (staked_token => pid)

    uint256 public pointStipend; // amount of DFTP awarded per deposit
    uint256 public rewardsPerAllocPoint; // rewards per pool allocPoint, times 1e18 to maintain precision
    uint256 public totalAllocPoint; // Total allocation points. Must be the sum of all allocation points in all pools.

    modifier NoReentrant(uint256 pid, address user) {

        require(
            block.number > userInfo[pid][user].lastRewardBlock,
            "AnyStake: Must wait 1 block"
        );
        _;
    }

    modifier onlyAnyStake {

        require(msg.sender == anystake, "AnyStake: Only previous AnyStake allowed");
        _;
    }

    modifier onlyVault() {

        require(msg.sender == vault, "AnyStake: Only Vault allowed");
        _;
    }

    constructor(address _anystake, address _router, address _gov, address _points, address _token) 
        public 
        AnyStakeUtils(_router, _gov, _points, _token)
    {
        anystake = _anystake;
        pointStipend = 1e18;
    }

    function addReward(uint256 amount) external override onlyVault {

        if (amount == 0) {
            return;
        }

        rewardsPerAllocPoint = rewardsPerAllocPoint.add(amount.mul(1e18).div(totalAllocPoint));
    }

    function updatePool(uint256 pid) external {

        _updatePool(pid);
    }

    function _updatePool(uint256 _pid) internal {

        PoolInfo storage pool = poolInfo[_pid];

        if (pool.totalStaked == 0 || pool.lastRewardBlock >= block.number || pool.allocPoint == 0) {
            return;
        }

        IAnyStakeVault(vault).calculateRewards();     

        uint256 poolRewards = pendingPool(_pid);
        
        if (poolRewards > 0) {
            pool.rewardsPerShare = pool.rewardsPerShare.add(poolRewards.mul(1e18).div(pool.totalStaked));
            pool.rewardDebt = pool.rewardDebt.add(poolRewards);
        }
        
        pool.lastRewardBlock = block.number;
    }

    function massUpdatePools() public {

        uint256 length = poolInfo.length;
        for (uint256 pid = 0; pid < length; pid++) {
            _updatePool(pid);
        }
    }

    function claim(uint256 pid) external override NoReentrant(pid, msg.sender) {

        PoolInfo storage pool = poolInfo[pid];
        UserInfo storage user = userInfo[pid][msg.sender];

        _updatePool(pid);
        _claim(pid, msg.sender);

        user.rewardDebt = user.amount.mul(pool.rewardsPerShare).div(1e18);
        user.lastRewardBlock = block.number;
    }

    function _claim(uint256 _pid, address _user) internal {

        uint256 rewards = pending(_pid, _user);
        if (rewards == 0) {
            return;
        }

        IAnyStakeVault(vault).distributeRewards(_user, rewards);
        emit Claim(_user, _pid, rewards);
    }

    function claimAll() external {

        uint256 totalClaimable;
        uint256 length = poolInfo.length;
        for (uint256 pid = 0; pid < length; pid++) {
            PoolInfo storage pool = poolInfo[pid];
            UserInfo storage user = userInfo[pid][msg.sender];
            if (user.lastRewardBlock < block.number && user.amount > 0) {
                _updatePool(pid);
                uint256 rewards = pending(pid, msg.sender);
                if (rewards > 0) {
                    totalClaimable = totalClaimable.add(rewards);
                    user.rewardDebt = user.amount.mul(pool.rewardsPerShare).div(1e18);
                    user.lastRewardBlock = block.number;
                    emit Claim(msg.sender, pid, rewards);
                }
            }
        }

        if (totalClaimable > 0) {
            IAnyStakeVault(vault).distributeRewards(msg.sender, totalClaimable);
            emit ClaimAll(msg.sender, totalClaimable);
        }
    }

    function deposit(uint256 pid, uint256 amount) external override NoReentrant(pid, msg.sender) {

        _deposit(msg.sender, pid, amount);
    }

    function _deposit(address _user, uint256 _pid, uint256 _amount) internal {

        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][_user];
        
        require(_amount > 0, "Deposit: Cannot deposit zero tokens");
        require(pool.allocPoint > 0, "Deposit: Pool is not active");
        require(pool.vipAmount <= userInfo[0][_user].amount, "Deposit: VIP Only");

        _updatePool(_pid);
        _claim(_pid, _user);

        uint256 amountBefore = IERC20(pool.stakedToken).balanceOf(address(this));
        IERC20(pool.stakedToken).safeTransferFrom(_user, address(this), _amount);
        uint256 amountAfter = IERC20(pool.stakedToken).balanceOf(address(this));
        uint256 amount = amountAfter.sub(amountBefore);

        pool.totalStaked = pool.totalStaked.add(amount);
        user.amount = user.amount.add(amount);
        user.rewardDebt = user.amount.mul(pool.rewardsPerShare).div(1e18);
        user.lastRewardBlock = block.number;
        
        IDeFiatPoints(DeFiatPoints).addPoints(_user, IDeFiatPoints(DeFiatPoints).viewTxThreshold(), pointStipend);

        emit Deposit(_user, _pid, amount);
    }

    function withdraw(uint256 pid, uint256 amount) external override NoReentrant(pid, msg.sender) {

        _withdraw(msg.sender, pid, amount);
    }
    
    function _withdraw(
        address _user,
        uint256 _pid,
        uint256 _amount
    ) internal {

        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][_user];

        require(_amount > 0, "Withdraw: amount must be greater than zero");
        require(user.amount >= _amount, "Withdraw: user amount insufficient");
        require(pool.vipAmount <= userInfo[0][_user].amount, "Withdraw: VIP Only");
        
        _updatePool(_pid);
        _claim(_pid, _user);

        pool.totalStaked = pool.totalStaked.sub(_amount);
        user.amount = user.amount.sub(_amount);
        user.rewardDebt = user.amount.mul(pool.rewardsPerShare).div(1e18);
        user.lastRewardBlock = block.number;

        uint256 stakingFeeAmount = _amount.mul(pool.stakingFee).div(1000);
        uint256 remainingUserAmount = _amount.sub(stakingFeeAmount);

        if(stakingFeeAmount > 0){
            uint256 balanceBefore = IERC20(pool.stakedToken).balanceOf(vault);
            safeTokenTransfer(vault, pool.stakedToken, stakingFeeAmount);
            uint256 balanceAfter = IERC20(pool.stakedToken).balanceOf(vault);
            uint256 balance = balanceAfter.sub(balanceBefore);
            IAnyStakeVault(vault).buyDeFiatWithTokens(pool.stakedToken, balance);
        }

        safeTokenTransfer(_user, pool.stakedToken, remainingUserAmount);        
        emit Withdraw(_user, _pid, remainingUserAmount);
    }

    function migrate(uint256 pid) external NoReentrant(pid, msg.sender) {

        _migrate(msg.sender, pid);
    }

    function _migrate(address _user, uint256 _pid) internal {

        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][_user];
        uint256 balance = user.amount;

        require(migrator != address(0), "Migrate: No migrator set");
        require(balance > 0, "Migrate: No tokens to migrate");
        require(pool.allocPoint == 0, "Migrate: Pool is still active");

        _claim(_pid, _user);

        pool.totalStaked = pool.totalStaked.sub(balance);
        user.amount = 0;
        user.rewardDebt = 0;
        user.lastRewardBlock = block.number;

        IERC20(pool.stakedToken).safeApprove(migrator, balance);
        IAnyStakeMigrator(migrator).migrateTo(_user, pool.stakedToken, balance);
        emit Migrate(_user, _pid, balance);
    }

    function migrateTo(address _user, address _token, uint256 _amount) 
        external
        override
        onlyAnyStake
    {

        uint256 pid = pids[_token];
        PoolInfo storage pool = poolInfo[pid];
        UserInfo storage user = userInfo[pid][_user];

        _claim(pid, _user);

        uint256 balanceBefore = IERC20(_token).balanceOf(address(this));
        IERC20(_token).transferFrom(anystake, address(this), _amount);
        uint256 balanceAfter = IERC20(_token).balanceOf(address(this));
        uint256 userDeposit = balanceAfter.sub(balanceBefore);

        pool.totalStaked = pool.totalStaked.add(userDeposit);
        user.amount = user.amount.add(userDeposit);
        user.rewardDebt = user.amount.mul(pool.rewardsPerShare).div(1e18);
        user.lastRewardBlock = block.number;

        IDeFiatPoints(DeFiatPoints).addPoints(_user, IDeFiatPoints(DeFiatPoints).viewTxThreshold(), pointStipend);
    }

    function emergencyWithdraw(uint256 pid) external NoReentrant(pid, msg.sender) {

        PoolInfo storage pool = poolInfo[pid];
        UserInfo storage user = userInfo[pid][msg.sender];
        require(user.amount > 0, "EmergencyWithdraw: user amount insufficient");

        uint256 stakingFeeAmount = user.amount.mul(pool.stakingFee).div(1000);
        uint256 remainingUserAmount = user.amount.sub(stakingFeeAmount);

        pool.totalStaked = pool.totalStaked.sub(user.amount);
        user.amount = 0;
        user.rewardDebt = 0;
        user.lastRewardBlock = block.number;

        safeTokenTransfer(vault, pool.stakedToken, stakingFeeAmount);
        safeTokenTransfer(msg.sender, pool.stakedToken, remainingUserAmount);
        emit EmergencyWithdraw(msg.sender, pid, remainingUserAmount);
    }

    function getPrice(uint256 pid) external view returns (uint256) {

        address token = poolInfo[pid].stakedToken;
        address lpToken = poolInfo[pid].lpToken;

        return IAnyStakeVault(vault).getTokenPrice(token, lpToken);
    }

    function pending(uint256 _pid, address _user)
        public
        view
        returns (uint256)
    {

        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][_user];

        return user.amount.mul(pool.rewardsPerShare).div(1e18).sub(user.rewardDebt);
    }

    function pendingPool(uint256 _pid)
        public
        view
        returns (uint256)
    {

        PoolInfo storage pool = poolInfo[_pid];
        return rewardsPerAllocPoint.mul(pool.allocPoint).div(1e18).sub(pool.rewardDebt);
    }

    function poolLength() external view returns (uint256) {

        return poolInfo.length; // number of pools (pids)
    }

    function addPoolBatch(
        address[] calldata tokens,
        address[] calldata lpTokens,
        uint256[] calldata allocPoints,
        uint256[] calldata vipAmounts,
        uint256[] calldata stakingFees
    ) external onlyGovernor {

        massUpdatePools();

        for (uint i = 0; i < tokens.length; i++) {
            _addPool(tokens[i], lpTokens[i], allocPoints[i], vipAmounts[i], stakingFees[i]);
        }
    }

    function addPool(
        address token,
        address lpToken, 
        uint256 allocPoint,
        uint256 vipAmount,
        uint256 stakingFee
    ) external onlyGovernor {

        massUpdatePools();
        _addPool(token, lpToken, allocPoint, vipAmount, stakingFee);
    }

    function _addPool(
        address stakedToken,
        address lpToken,
        uint256 allocPoint,
        uint256 vipAmount,
        uint256 stakingFee
    ) internal {

        require(pids[stakedToken] == 0, "AddPool: Token pool already added");

        pids[stakedToken] = poolInfo.length;
        _blacklistedAdminWithdraw[stakedToken] = true;
        totalAllocPoint = totalAllocPoint.add(allocPoint);
        uint256 rewardDebt = rewardsPerAllocPoint.mul(allocPoint).div(1e18);

        poolInfo.push(
            PoolInfo({
                stakedToken: stakedToken,
                lpToken: lpToken,
                allocPoint: allocPoint,
                lastRewardBlock: block.number,
                totalStaked: 0,
                rewardsPerShare: 0,
                vipAmount: vipAmount,
                stakingFee: stakingFee,
                rewardDebt: rewardDebt
            })
        );

        emit PoolAdded(msg.sender, pids[stakedToken], stakedToken, lpToken, allocPoint);
    }

    function setMigrator(address _migrator) external onlyGovernor {

        require(_migrator != address(0), "SetMigrator: No migrator change");

        migrator = _migrator;
        emit MigratorUpdated(msg.sender, _migrator);
    }

    function setVault(address _vault) external onlyGovernor {

        require(_vault != address(0), "SetVault: No migrator change");

        vault = _vault;
        emit VaultUpdated(msg.sender, vault);
    }

    function setPoolAllocPoints(uint256[] calldata _pids, uint256[] calldata _allocPoints) external onlyGovernor {

        massUpdatePools();

        for (uint256 i = 0; i < _pids.length; i++) {
            _setPoolAllocPoints(_pids[i], _allocPoints[i]);
        }
    }

    function _setPoolAllocPoints(uint256 _pid, uint256 _allocPoint) internal {

        PoolInfo storage pool = poolInfo[_pid];
        require(pool.allocPoint != _allocPoint, "SetAllocPoints: No points change");

        totalAllocPoint = totalAllocPoint.sub(pool.allocPoint).add(_allocPoint);
        pool.allocPoint = _allocPoint;
        emit PoolAllocPointsUpdated(msg.sender, _pid, _allocPoint);
    }

    function setPoolVipAmount(uint256[] calldata _pids, uint256[] calldata _vipAmounts) external onlyGovernor {

        for (uint256 i = 0; i < _pids.length; i++) {
            _setPoolVipAmount(_pids[i], _vipAmounts[i]);
        }
    }

    function _setPoolVipAmount(uint256 _pid, uint256 _vipAmount) internal {

        require(poolInfo[_pid].vipAmount != _vipAmount, "SetVipAmount: No amount change");

        poolInfo[_pid].vipAmount = _vipAmount;
        emit PoolVipAmountUpdated(msg.sender, _pid, _vipAmount);
    }

    function setPoolStakingFee(uint256[] calldata _pids, uint256[] calldata _stakingFees) external onlyGovernor {

        for (uint256 i = 0; i < _pids.length; i++) {
            _setPoolStakingFee(_pids[i], _stakingFees[i]);
        }
    }

    function _setPoolStakingFee(uint256 _pid, uint256 _stakingFee) internal {

        require(_stakingFee != poolInfo[_pid].stakingFee, "SetStakingFee: No fee change");
        require(_stakingFee <= 1000, "SetFee: Fee cannot exceed 100%");

        poolInfo[_pid].stakingFee = _stakingFee;
        emit PoolStakingFeeUpdated(msg.sender, _pid, _stakingFee);
    }

    function setPointStipend(uint256 _pointStipend) external onlyGovernor {

        require(_pointStipend != pointStipend, "SetStipend: No stipend change");

        pointStipend = _pointStipend;
        emit PointStipendUpdated(msg.sender, pointStipend);
    }
}