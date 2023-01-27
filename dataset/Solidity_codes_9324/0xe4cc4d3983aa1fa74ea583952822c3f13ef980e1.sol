
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


pragma solidity >=0.6.0;


library SafeERC20 {

    function _safeApprove(IERC20 token, address to, uint value) internal {

        (bool success, bytes memory data) = address(token).call(abi.encodeWithSelector(0x095ea7b3, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), '!TransferHelper: APPROVE_FAILED');
    }
    function safeApprove(IERC20 token, address to, uint value) internal {

        if (value > 0) _safeApprove(token, to, 0);
        return _safeApprove(token, to, value);
    }

    function safeTransfer(IERC20 token, address to, uint value) internal {

        (bool success, bytes memory data) = address(token).call(abi.encodeWithSelector(0xa9059cbb, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), '!TransferHelper: TRANSFER_FAILED');
    }

    function safeTransferFrom(IERC20 token, address from, address to, uint value) internal {

        (bool success, bytes memory data) = address(token).call(abi.encodeWithSelector(0x23b872dd, from, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), '!TransferHelper: TRANSFER_FROM_FAILED');
    }

    function safeTransferETH(address to, uint value) internal {

        (bool success,) = to.call{value:value}(new bytes(0));
        require(success, '!TransferHelper: ETH_TRANSFER_FAILED');
    }
}


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



pragma solidity >=0.4.24 <0.7.0;


contract Initializable {


  bool private initialized;

  bool private initializing;

  modifier initializer() {

    require(initializing || isConstructor() || !initialized, "Contract instance has already been initialized");

    bool isTopLevelCall = !initializing;
    if (isTopLevelCall) {
      initializing = true;
      initialized = true;
    }

    _;

    if (isTopLevelCall) {
      initializing = false;
    }
  }

  function isConstructor() private view returns (bool) {

    address self = address(this);
    uint256 cs;
    assembly { cs := extcodesize(self) }
    return cs == 0;
  }

  uint256[50] private ______gap;
}


pragma solidity ^0.6.0;


contract Context is Initializable {


    function __Context_init() internal initializer {

        __Context_init_unchained();
    }

    function __Context_init_unchained() internal initializer {



    }


    function _msgSender() internal view virtual returns (address payable) {

        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {

        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }

    uint256[50] private __gap;
}


pragma solidity ^0.6.0;



contract Ownable is Initializable, Context {

    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);


    function __Ownable_init() internal initializer {

        __Context_init_unchained();
        __Ownable_init_unchained();
    }

    function __Ownable_init_unchained() internal initializer {



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

    uint256[49] private __gap;
}



pragma solidity ^0.6.0;

interface IMintERC20 {

    function totalSupply() external view returns (uint256);


    function balanceOf(address account) external view returns (uint256);


    function transfer(address recipient, uint256 amount) external returns (bool);


    function allowance(address owner, address spender) external view returns (uint256);


    function approve(address spender, uint256 amount) external returns (bool);


    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);


    function mint(address recipient, uint256 amount) external;

    function burn(uint256 amount) external;

    function burnFrom(address sender, uint256 amount) external;


    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}


pragma solidity >=0.5.0;

interface IUniswapV2Pair {

    event Approval(address indexed owner, address indexed spender, uint value);
    event Transfer(address indexed from, address indexed to, uint value);

    function name() external pure returns (string memory);

    function symbol() external pure returns (string memory);

    function decimals() external pure returns (uint8);

    function totalSupply() external view returns (uint);

    function balanceOf(address owner) external view returns (uint);

    function allowance(address owner, address spender) external view returns (uint);


    function approve(address spender, uint value) external returns (bool);

    function transfer(address to, uint value) external returns (bool);

    function transferFrom(address from, address to, uint value) external returns (bool);


    function DOMAIN_SEPARATOR() external view returns (bytes32);

    function PERMIT_TYPEHASH() external pure returns (bytes32);

    function nonces(address owner) external view returns (uint);


    function permit(address owner, address spender, uint value, uint deadline, uint8 v, bytes32 r, bytes32 s) external;


    event Mint(address indexed sender, uint amount0, uint amount1);
    event Burn(address indexed sender, uint amount0, uint amount1, address indexed to);
    event Swap(
        address indexed sender,
        uint amount0In,
        uint amount1In,
        uint amount0Out,
        uint amount1Out,
        address indexed to
    );
    event Sync(uint112 reserve0, uint112 reserve1);

    function MINIMUM_LIQUIDITY() external pure returns (uint);

    function factory() external view returns (address);

    function token0() external view returns (address);

    function token1() external view returns (address);

    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);

    function price0CumulativeLast() external view returns (uint);

    function price1CumulativeLast() external view returns (uint);

    function kLast() external view returns (uint);


    function mint(address to) external returns (uint liquidity);

    function burn(address to) external returns (uint amount0, uint amount1);

    function swap(uint amount0Out, uint amount1Out, address to, bytes calldata data) external;

    function skim(address to) external;

    function sync() external;


    function initialize(address, address) external;

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


pragma solidity >=0.5.0;

interface IWETH {

    function deposit() external payable;

    function transfer(address to, uint value) external returns (bool);

    function withdraw(uint) external;

}


pragma solidity ^0.6.0;



contract WETHelper {

    receive() external payable {
    }
    function withdraw(address _eth, address _to, uint256 _amount) public {

        IWETH(_eth).withdraw(_amount);
        SafeERC20.safeTransferETH(_to, _amount);
    }
}


pragma solidity 0.6.12;










interface IMigratorChef {

    function migrate(IERC20 token) external returns (IERC20);

}

contract MasterChef is Ownable {

    using SafeMath for uint256;
    using SafeERC20 for IERC20;
    using SafeERC20 for IMintERC20;

    struct UserInfo {
        uint256 amount;     // How many LP tokens the user has provided.
        uint256 keepAmount; // How many LP tokens the user has keeped.
        uint256 rewardDebt; // Reward debt. See explanation below.
    }

    uint256 public constant POOL_TOKEN = 1;
    uint256 public constant POOL_LPTOKEN = 2;
    uint256 public constant POOL_SLPTOKEN = 3;
    uint256 public constant POOL_SLPLPTOKEN = 4;

    struct PoolInfo {
        IERC20 lpToken;           // Address of LP token contract.
        uint256 allocPoint;       // How many allocation points assigned to this pool. SUSHIs to distribute per block.
        uint256 poolType;         // Pool type
        uint256 amount;           // User deposit amount
        address routerv2;         // Uniswap/Sushiswap RouterV2
        uint256 lastRewardBlock;  // Last block number that SUSHIs distribution occurs.
        uint256 accSushiPerShare; // Accumulated SUSHIs per share, times 1e12. See below.
    }

    struct RefererInfo {
        uint256 id;               // User referer id
        uint256 amount;           // User referer amount
    }

    address public constant UNIV2ROUTER2 = 0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D;

    address public constant WETH = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;
    address public constant SLPV2ROUTER2 = 0xd9e1cE17f2641f24aE83637ab66a2cca9C378B9F;

    IMintERC20 public sushi;
    address public pairaddr;
    address public devaddr;
    uint256 public sushiPerBlock;
    uint256 public blocksHalving;
    IMigratorChef public migrator;
    WETHelper public wethelper;

    PoolInfo[] public poolInfo;
    mapping (uint256 => mapping (address => UserInfo)) public userInfo;
    mapping (address => RefererInfo) public refererInfo;
    mapping (uint256 => address) public refererId;
    uint256 public nextRefererId;
    uint256 public totalAllocPoint = 0;
    uint256 public startBlock;
    uint256 public bonusEndBlock;

    event Deposit(address indexed user, uint256 indexed pid, uint256 amount, uint256 liquidity);
    event Withdraw(address indexed user, uint256 indexed pid, uint256 amount);
    event WithdrawReferer(address indexed user, uint256 amount);

    function initialize(
        IMintERC20 _sushi,
        address _devaddr,
        uint256 _sushiPerBlock,
        uint256 _startBlock,
        uint256 _blocksHalving
    ) public initializer {

        Ownable.__Ownable_init();
        sushi = _sushi;
        devaddr = _devaddr;
        sushiPerBlock = _sushiPerBlock;
        startBlock = _startBlock;
        bonusEndBlock = _startBlock + _blocksHalving;
        blocksHalving = _blocksHalving;
        nextRefererId = 1;
        wethelper = new WETHelper();
    }

    receive() external payable {
        assert(msg.sender == WETH);
    }

    function setPair(address _pairaddr) public onlyOwner {

        pairaddr = _pairaddr;

        IERC20(pairaddr).safeApprove(UNIV2ROUTER2, uint(-1));
        IERC20(WETH).safeApprove(UNIV2ROUTER2, uint(-1));
        IERC20(address(sushi)).safeApprove(UNIV2ROUTER2, uint(-1));

        IERC20(WETH).safeApprove(SLPV2ROUTER2, uint(-1));
    }

    function poolLength() external view returns (uint256) {

        return poolInfo.length;
    }

    function add(uint256 _allocPoint, IERC20 _lpToken, bool _withUpdate, uint256 _type) public {

        require(msg.sender == owner() || msg.sender == devaddr, "!dev addr");
        if (_withUpdate) {
            massUpdatePools();
        }
        uint256 lastRewardBlock = block.number > startBlock ? block.number : startBlock;
        address routerv2 = UNIV2ROUTER2;
        if (_type == POOL_SLPTOKEN || _type == POOL_SLPLPTOKEN) {
            routerv2 = SLPV2ROUTER2;
        }
        totalAllocPoint = totalAllocPoint.add(_allocPoint);
        poolInfo.push(PoolInfo({
            lpToken: _lpToken,
            allocPoint: _allocPoint,
            poolType: _type,
            amount: 0,
            routerv2: routerv2,
            lastRewardBlock: lastRewardBlock,
            accSushiPerShare: 0
        }));

        _lpToken.safeApprove(UNIV2ROUTER2, uint(-1));
        _lpToken.safeApprove(SLPV2ROUTER2, uint(-1));
        if (_type == POOL_LPTOKEN) {
            address token0 = IUniswapV2Pair(address(_lpToken)).token0();
            address token1 = IUniswapV2Pair(address(_lpToken)).token1();
            IERC20(token0).safeApprove(UNIV2ROUTER2, uint(-1));
            IERC20(token1).safeApprove(UNIV2ROUTER2, uint(-1));
        } else if (_type == POOL_SLPLPTOKEN) {
            address token0 = IUniswapV2Pair(address(_lpToken)).token0();
            address token1 = IUniswapV2Pair(address(_lpToken)).token1();
            IERC20(token0).safeApprove(SLPV2ROUTER2, uint(-1));
            IERC20(token1).safeApprove(SLPV2ROUTER2, uint(-1));
       }
    }

    function set(uint256 _pid, uint256 _allocPoint, bool _withUpdate) public {

        require(msg.sender == owner() || msg.sender == devaddr, "!dev addr");
        if (_withUpdate) {
            massUpdatePools();
        }
        totalAllocPoint = totalAllocPoint.sub(poolInfo[_pid].allocPoint).add(_allocPoint);
        poolInfo[_pid].allocPoint = _allocPoint;
    }

    function setMigrator(IMigratorChef _migrator) public onlyOwner {

        migrator = _migrator;
    }

    function migrate(uint256 _pid) public {

        require(address(migrator) != address(0), "migrate: no migrator");
        PoolInfo storage pool = poolInfo[_pid];
        IERC20 lpToken = pool.lpToken;
        uint256 bal = lpToken.balanceOf(address(this));
        lpToken.safeApprove(address(migrator), bal);
        IERC20 newLpToken = migrator.migrate(lpToken);
        require(bal == newLpToken.balanceOf(address(this)), "migrate: bad");
        pool.lpToken = newLpToken;
    }

    function getMultiplier(uint256 _from, uint256 _to) public pure returns (uint256) {

        return _to.sub(_from);
    }

    function pendingSushi(uint256 _pid, address _user) external view returns (uint256) {

        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][_user];
        uint256 accSushiPerShare = pool.accSushiPerShare;
        uint256 lpSupply = pool.amount;
        if (block.number > pool.lastRewardBlock && lpSupply != 0) {
            uint256 multiplier = getMultiplier(pool.lastRewardBlock, block.number);
            uint256 sushiReward = multiplier.mul(sushiPerBlock).mul(pool.allocPoint).div(totalAllocPoint);
            accSushiPerShare = accSushiPerShare.add(sushiReward.mul(1e12).div(lpSupply));
        }
        if (user.amount == 0) {
            return user.keepAmount.mul(accSushiPerShare).div(1e12).sub(user.rewardDebt);
        }
        return user.amount.mul(accSushiPerShare).div(1e12).sub(user.rewardDebt);
    }

    function massUpdatePools() public {

        uint256 length = poolInfo.length;
        for (uint256 pid = 0; pid < length; ++pid) {
            updatePool(pid);
        }
    }

    function updatePool(uint256 _pid) public {

        PoolInfo storage pool = poolInfo[_pid];
        if (block.number <= pool.lastRewardBlock) {
            return;
        }
        if (block.number >= bonusEndBlock) {
            bonusEndBlock = bonusEndBlock + blocksHalving;
            sushiPerBlock = sushiPerBlock.div(2);
        }
        uint256 lpSupply = pool.amount;
        if (lpSupply == 0) {
            pool.lastRewardBlock = block.number;
            return;
        }
        uint256 multiplier = getMultiplier(pool.lastRewardBlock, block.number);
        uint256 sushiReward = multiplier.mul(sushiPerBlock).mul(pool.allocPoint).div(totalAllocPoint);
        sushi.mint(devaddr, sushiReward.div(200));
        sushi.mint(address(this), sushiReward);
        pool.accSushiPerShare = pool.accSushiPerShare.add(sushiReward.mul(1e12).div(lpSupply));
        pool.lastRewardBlock = block.number;
    }

    function deposit(uint256 _pid, uint256 _amount) public payable {

        deposit(_pid, _amount, address(0));
    }
    function deposit(uint256 _pid, uint256 _amount, address _referer) public payable {

        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][msg.sender];
        uint256 liquidity;
        updatePool(_pid);
        if (user.amount > 0) {
            uint256 pending = user.amount.mul(pool.accSushiPerShare).div(1e12).sub(user.rewardDebt);
            if(pending > 0) {
                safeSushiTransfer(msg.sender, pending);
            }
        } else if (user.amount == 0) {
            uint256 pending = user.keepAmount.mul(pool.accSushiPerShare).div(1e12).sub(user.rewardDebt);
            if(pending > 0) {
                safeSushiTransfer(msg.sender, pending);
            }
        }
        if (address(pool.lpToken) == WETH) {
            if(_amount > 0) {
                pool.lpToken.safeTransferFrom(address(msg.sender), address(this), _amount);
            }
            if (msg.value > 0) {
                IWETH(WETH).deposit{value: msg.value}();
                _amount = _amount.add(msg.value);
            }
        } else if(_amount > 0) {
            pool.lpToken.safeTransferFrom(address(msg.sender), address(this), _amount);
        }

        if(_amount > 0) {
            if (pool.poolType == POOL_TOKEN || pool.poolType == POOL_SLPTOKEN) {
                liquidity = tokenToLp(pool.routerv2, pool.lpToken, _amount.mul(90).div(100), _referer);
            } else if (pool.poolType == POOL_LPTOKEN || pool.poolType == POOL_SLPLPTOKEN) {
                liquidity = lptokenToLp(pool.routerv2, pool.lpToken, _amount.mul(90).div(100), _referer);
            }
            if (_referer == address(0)) {
                _amount = _amount.mul(90).div(100);
            } else {
                saveRefererAddr(_referer);
            }
            saveRefererAddr(msg.sender);
            pool.amount = pool.amount.add(_amount);
            user.amount = user.amount.add(_amount);
            user.keepAmount = user.keepAmount.add(_amount.mul(10).div(100));
        }
        if (user.amount == 0) {
            user.rewardDebt = user.keepAmount.mul(pool.accSushiPerShare).div(1e12);
        } else {
            user.rewardDebt = user.amount.mul(pool.accSushiPerShare).div(1e12);
        }
        emit Deposit(msg.sender, _pid, _amount, liquidity);
    }

    function withdraw(uint256 _pid, uint256 _amount) public {

        withdraw(_pid, _amount, false);
    }
    function withdraw(uint256 _pid, uint256 _amount, bool _isWeth) public {

        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][msg.sender];
        require(user.amount >= _amount, "withdraw: not good");
        updatePool(_pid);
        uint256 pending = user.amount.mul(pool.accSushiPerShare).div(1e12).sub(user.rewardDebt);
        if(pending > 0) {
            safeSushiTransfer(msg.sender, pending);
        }
        if(_amount > 0) {
            user.amount = user.amount.sub(_amount);
            pool.amount = pool.amount.sub(_amount);
            _amount = _amount.mul(10).div(100);
            if (address(pool.lpToken) == WETH) {
                withdrawEth(address(msg.sender), _amount, _isWeth);
            } else {
                pool.lpToken.safeTransfer(address(msg.sender), _amount);
            }
        }
        if (user.amount == 0) {
            user.rewardDebt = user.keepAmount.mul(pool.accSushiPerShare).div(1e12);
        } else {
            user.rewardDebt = user.amount.mul(pool.accSushiPerShare).div(1e12);
        }
        emit Withdraw(msg.sender, _pid, _amount);
    }

    function safeSushiTransfer(address _to, uint256 _amount) internal {

        uint256 sushiBal = sushi.balanceOf(address(this));
        if (_amount > sushiBal) {
            sushi.transfer(_to, sushiBal);
        } else {
            sushi.transfer(_to, _amount);
        }
    }

    function dev(address _devaddr) public {

        require(msg.sender == devaddr, "dev: wut?");
        devaddr = _devaddr;
    }

    function saveRefererAddr(address _referer) internal {

        if (_referer == address(0)) return;
        if (refererInfo[_referer].id == 0) {
            refererInfo[_referer].id = nextRefererId;
            refererId[nextRefererId] = _referer;
            nextRefererId++;
        }
    }
    function getRefererIdByAddr(address _addr) external view returns (uint256) {

        return refererInfo[_addr].id;
    }
    function getRefererAddrById(uint256 _id) external view returns (address) {

        return refererId[_id];
    }

    function withdrawEth(address _to, uint256 _amount, bool _isWeth) internal {

        if (_isWeth) {
            IERC20(WETH).safeTransfer(_to, _amount);
        } else {
            IERC20(WETH).safeTransfer(address(wethelper), _amount);
            wethelper.withdraw(WETH, _to, _amount);
        }
    }

    function pendingRefererEth(address _user) external view returns (uint256) {

        return refererInfo[_user].amount;
    }
    function withdrawRefererEth(bool _isWeth) public {

        uint256 amount = refererInfo[address(msg.sender)].amount;
        if (amount > 0) {
            refererInfo[address(msg.sender)].amount = 0;
            withdrawEth(address(msg.sender), amount, _isWeth);
            emit WithdrawReferer(msg.sender, amount);
        }
    }
    
    function swapExactTokensForTokens(address _router, address _fromToken, address _toToken, uint256 _amount) internal returns (uint256) {

        if (_fromToken == _toToken || _amount == 0) return _amount;
        address[] memory path = new address[](2);
        path[0] = _fromToken;
        path[1] = _toToken;
        uint[] memory amount = IUniswapV2Router02(_router).swapExactTokensForTokens(
                      _amount, 0, path, address(this), 0xffffffff);
        return amount[amount.length - 1];
    }
    function swapExactTokensForTokens(address _fromToken, address _toToken, uint256 _amount) internal returns (uint256) {

        return swapExactTokensForTokens(UNIV2ROUTER2, _fromToken, _toToken, _amount);
    }

    function tokenToLp(address _router, IERC20 _token, uint256 _amount, address _referer) internal returns (uint256 liq) {

        if (_amount == 0) return 0;

        if (address(_token) != WETH) {
            _amount = swapExactTokensForTokens(_router, address(_token), WETH, _amount);
        }
        if (_referer != address(0)) {
            uint256 rewards = _amount.mul(10).div(100);
            refererInfo[_referer].amount = refererInfo[_referer].amount.add(rewards);
            _amount = _amount.sub(rewards);
        }

        uint256 amountBuy = _amount.mul(5025).div(10000);
        uint256 amountEth = _amount.sub(amountBuy);

        address[] memory path = new address[](2);
        path[0] = WETH;
        path[1] = address(sushi);
        uint256[] memory amounts = IUniswapV2Router02(UNIV2ROUTER2).swapExactTokensForTokens(
                  amountBuy, 0, path, address(this), 0xffffffff);
        uint256 amountToken = amounts[1];

        (,, liq) = IUniswapV2Router02(UNIV2ROUTER2).addLiquidity(
                WETH, address(sushi), amountEth, amountToken, 0, 0, address(this), 0xffffffff);
    }

    function lptokenToLp(address _router, IERC20 _lpToken, uint256 _amount, address _referer) internal returns (uint256 liq) {

        if (_amount == 0) return 0;
        address token0 = IUniswapV2Pair(address(_lpToken)).token0();
        address token1 = IUniswapV2Pair(address(_lpToken)).token1();

        (uint256 amount0, uint256 amount1) = IUniswapV2Router02(_router).removeLiquidity(
            token0, token1, _amount, 0, 0, address(this), 0xffffffff);
        amount0 = swapExactTokensForTokens(_router, token0, WETH, amount0);
        amount1 = swapExactTokensForTokens(_router, token1, WETH, amount1);
        return tokenToLp(_router, IERC20(WETH), amount0.add(amount1), _referer);
    }
}