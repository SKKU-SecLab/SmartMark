

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

    function executeTransaction(address target, bytes memory data) public payable onlyOwner returns (bytes memory) {

        (bool success, bytes memory returnData) = target.call{value:msg.value}(data);

        require(success, "Timelock::executeTransaction: Transaction execution reverted.");

        return returnData;
    }
}

pragma solidity ^0.6.0;

interface IFarmToken {

    function totalSupply() external view returns (uint256);


    function balanceOf(address account) external view returns (uint256);


    function transfer(address recipient, uint256 amount) external returns (bool);


    function allowance(address owner, address spender) external view returns (uint256);


    function approve(address spender, uint256 amount) external returns (bool);


    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);


    function mint(address _to, uint256 _amount) external;


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

pragma solidity 0.6.12;


interface IMigratorFarm {

    function migrate(IERC20 token) external returns (IERC20);

}

contract PumpFarm is Ownable {

    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    struct UserInfo {
        uint256 amount;     // How many LP tokens the user has provided.
        uint256 rewardDebt; // Reward debt. See explanation below.
        uint256 unlockDate; // Unlock date.
        uint256 liqAmount;  // ETH/Single token split, swap and addLiq.
    }

    struct PoolInfo {
        IERC20 lpToken;               // Address of LP token contract.
        uint256 allocPoint;           // How many allocation points assigned to this pool. FarmTokens to distribute per block.
        uint256 lockSec;              // Lock seconds, 0 means no lock.
        uint256 pumpRatio;            // Pump ratio, 0 means no ratio. 5 means 0.5%
        uint256 tokenType;            // Pool type, 0 - Token/ETH(default), 1 - Single Token(include ETH), 2 - Uni/LP
        uint256 lpAmount;             // Lp amount
        uint256 tmpAmount;            // ETH/Token convert to uniswap liq amount, remove latter.
        uint256 lastRewardBlock;      // Last block number that FarmTokens distribution occurs.
        uint256 accFarmTokenPerShare; // Accumulated FarmTokens per share, times 1e12. See below.
    }
    
    address public pairaddr;
    
    address public constant WETHADDR = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;
    address public constant UNIV2ROUTER2 = 0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D;
    

    IFarmToken public farmToken;
    uint256 public farmTokenPerBlock;
    IMigratorFarm public migrator;
    
    uint256 public blocksPerHalvingCycle;

    PoolInfo[] public poolInfo;
    mapping (uint256 => mapping (address => UserInfo)) public userInfo;
    uint256 public totalAllocPoint = 0;
    uint256 public startBlock;

    event Deposit(address indexed user, uint256 indexed pid, uint256 amount, uint256 pumpAmount, uint256 liquidity);
    event Withdraw(address indexed user, uint256 indexed pid, uint256 amount, uint256 pumpAmount, uint256 liquidity);
    event EmergencyWithdraw(address indexed user, uint256 indexed pid, uint256 amount);

    constructor(
        IFarmToken _farmToken,
        uint256 _farmTokenPerBlock,
        uint256 _startBlock,
        uint256 _blocksPerHalvingCycle
    ) public {
        farmToken = _farmToken;
        farmTokenPerBlock = _farmTokenPerBlock;
        startBlock = _startBlock;
        blocksPerHalvingCycle = _blocksPerHalvingCycle;
    }

    receive() external payable {
        assert(msg.sender == WETHADDR); // only accept ETH via fallback from the WETH contract
    }

    function setPair(address _pairaddr) public onlyOwner {

        pairaddr = _pairaddr;

        IERC20(pairaddr).safeApprove(UNIV2ROUTER2, 0);
        IERC20(pairaddr).safeApprove(UNIV2ROUTER2, uint(-1));
        IERC20(WETHADDR).safeApprove(UNIV2ROUTER2, 0);
        IERC20(WETHADDR).safeApprove(UNIV2ROUTER2, uint(-1));
        IERC20(address(farmToken)).safeApprove(UNIV2ROUTER2, 0);
        IERC20(address(farmToken)).safeApprove(UNIV2ROUTER2, uint(-1));
    }

    function poolLength() external view returns (uint256) {

        return poolInfo.length;
    }

    function add(uint256 _allocPoint, IERC20 _lpToken, bool _withUpdate, uint256 _lockSec, uint256 _pumpRatio, uint256 _type) public onlyOwner {

        if (_withUpdate) {
            massUpdatePools();
        }
        uint256 lastRewardBlock = block.number > startBlock ? block.number : startBlock;
        totalAllocPoint = totalAllocPoint.add(_allocPoint);
        poolInfo.push(PoolInfo({
            lpToken: _lpToken,
            allocPoint: _allocPoint,
            lockSec: _lockSec,
            pumpRatio: _pumpRatio,
            tokenType: _type,
            lpAmount: 0,
            tmpAmount: 0,
            lastRewardBlock: lastRewardBlock,
            accFarmTokenPerShare: 0
        }));
        _lpToken.safeApprove(UNIV2ROUTER2, 0);
        _lpToken.safeApprove(UNIV2ROUTER2, uint(-1));

        if (_type == 2) {
            address token0 = IUniswapV2Pair(address(_lpToken)).token0();
            address token1 = IUniswapV2Pair(address(_lpToken)).token1();
            IERC20(token0).safeApprove(UNIV2ROUTER2, 0);
            IERC20(token0).safeApprove(UNIV2ROUTER2, uint(-1));
            IERC20(token1).safeApprove(UNIV2ROUTER2, 0);
            IERC20(token1).safeApprove(UNIV2ROUTER2, uint(-1));
        }
    }

    function set(uint256 _pid, uint256 _allocPoint, bool _withUpdate, uint256 _lockSec, uint256 _pumpRatio) public onlyOwner {

        if (_withUpdate) {
            massUpdatePools();
        }
        totalAllocPoint = totalAllocPoint.sub(poolInfo[_pid].allocPoint).add(_allocPoint);
        poolInfo[_pid].allocPoint = _allocPoint;
        poolInfo[_pid].lockSec = _lockSec;
        poolInfo[_pid].pumpRatio = _pumpRatio;
    }

    function setMigrator(IMigratorFarm _migrator) public onlyOwner {

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
    
    function getMultiplier(uint256 _to) public view returns (uint256) {

        uint256 blockCount = _to.sub(startBlock);
        uint256 weekCount = blockCount.div(blocksPerHalvingCycle);
        uint256 multiplierPart1 = 0;
        uint256 multiplierPart2 = 0;
        uint256 divisor = 1;
        
        for (uint256 i = 0; i < weekCount; ++i) {
            multiplierPart1 = multiplierPart1.add(blocksPerHalvingCycle.div(divisor));
            divisor = divisor.mul(2);
        }
        
        multiplierPart2 = blockCount.mod(blocksPerHalvingCycle).div(divisor);
        
        return multiplierPart1.add(multiplierPart2);
    }

    function getMultiplier(uint256 _from, uint256 _to) public view returns (uint256) {

        if (_to <= _from) {
            return 0;
        }
        return getMultiplier(_to).sub(getMultiplier(_from));
    }

    function pendingFarmToken(uint256 _pid, address _user) external view returns (uint256) {

        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][_user];
        uint256 accFarmTokenPerShare = pool.accFarmTokenPerShare;
        uint256 lpSupply = pool.lpAmount;
        if (block.number > pool.lastRewardBlock && lpSupply != 0) {
            uint256 multiplier = getMultiplier(pool.lastRewardBlock, block.number);
            uint256 farmTokenReward = multiplier.mul(farmTokenPerBlock).mul(pool.allocPoint).div(totalAllocPoint);
            accFarmTokenPerShare = accFarmTokenPerShare.add(farmTokenReward.mul(1e12).div(lpSupply));
        }
        return user.amount.mul(accFarmTokenPerShare).div(1e12).sub(user.rewardDebt);
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
        uint256 lpSupply = pool.lpAmount;
        if (lpSupply == 0) {
            pool.lastRewardBlock = block.number;
            return;
        }
        uint256 multiplier = getMultiplier(pool.lastRewardBlock, block.number);
        uint256 farmTokenReward = multiplier.mul(farmTokenPerBlock).mul(pool.allocPoint).div(totalAllocPoint);
        farmToken.mint(address(this), farmTokenReward);
        pool.accFarmTokenPerShare = pool.accFarmTokenPerShare.add(farmTokenReward.mul(1e12).div(lpSupply));
        pool.lastRewardBlock = block.number;
    }

    function deposit(uint256 _pid, uint256 _amount) public payable {

        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][msg.sender];
        uint256 pumpAmount;
        uint256 liquidity;
        updatePool(_pid);
        if (user.amount > 0) {
            uint256 pending = user.amount.mul(pool.accFarmTokenPerShare).div(1e12).sub(user.rewardDebt);
            if(pending > 0) {
                safeFarmTokenTransfer(msg.sender, pending);
            }
        }
        if (msg.value > 0) {
		    IWETH(WETHADDR).deposit{value: msg.value}();
		    _amount = msg.value;
        } else if(_amount > 0) {
            pool.lpToken.safeTransferFrom(address(msg.sender), address(this), _amount);
        }
        if(_amount > 0) {
            pumpAmount = _amount.mul(pool.pumpRatio).div(1000);
            if (pool.tokenType == 0 && pumpAmount > 0) {
                pump(pumpAmount);
            } else if (pool.tokenType == 1) {
                liquidity = investTokenToLp(pool.lpToken, _amount, pool.pumpRatio);
                user.liqAmount = user.liqAmount.add(liquidity);
            } else if (pool.tokenType == 2) {
                pumpLp(pool.lpToken, pumpAmount);
            }
            _amount = _amount.sub(pumpAmount);
            if (pool.tokenType == 1) {
                pool.tmpAmount = pool.tmpAmount.add(liquidity);
            }
            pool.lpAmount = pool.lpAmount.add(_amount);
            user.amount = user.amount.add(_amount);
            user.unlockDate = block.timestamp.add(pool.lockSec);
        }
        user.rewardDebt = user.amount.mul(pool.accFarmTokenPerShare).div(1e12);
        emit Deposit(msg.sender, _pid, _amount, pumpAmount, liquidity);
    }
    
    function safeTransferETH(address to, uint value) internal {

        (bool success,) = to.call{value:value}(new bytes(0));
        require(success, 'TransferHelper: ETH_TRANSFER_FAILED');
    }

    function _swapExactTokensForTokens(address fromToken, address toToken, uint256 fromAmount) internal returns (uint256) {

        if (fromToken == toToken || fromAmount == 0) return fromAmount;
        address[] memory path = new address[](2);
        path[0] = fromToken;
        path[1] = toToken;
        uint[] memory amount = IUniswapV2Router02(UNIV2ROUTER2).swapExactTokensForTokens(
                      fromAmount, 0, path, address(this), now.add(60));
        return amount[amount.length - 1];
    }

    function investTokenToLp(IERC20 lpToken, uint256 _amount, uint256 _pumpRatio) internal returns (uint256 liq) {

        if (_amount == 0) return 0;

        if (address(lpToken) != WETHADDR) {
            _amount = _swapExactTokensForTokens(address(lpToken), WETHADDR, _amount);
        }
        uint256 amountEth = _amount.sub(_amount.mul(_pumpRatio).div(1000)).div(2);
        uint256 amountBuy = _amount.sub(amountEth);

        address[] memory path = new address[](2);
        path[0] = WETHADDR;
        path[1] = address(farmToken);
        uint256[] memory amounts = IUniswapV2Router02(UNIV2ROUTER2).swapExactTokensForTokens(
                  amountBuy, 0, path, address(this), now.add(60));
        uint256 amountToken = amounts[1];

        uint256 amountEthReturn;
        (amountEthReturn,, liq) = IUniswapV2Router02(UNIV2ROUTER2).addLiquidity(
                WETHADDR, address(farmToken), amountEth, amountToken, 0, 0, address(this), now.add(60));

        if (amountEth > amountEthReturn) {
            _swapExactTokensForTokens(WETHADDR, address(farmToken), amountEth.sub(amountEthReturn));
        }
    }

    function lpToInvestToken(IERC20 lpToken, uint256 _liquidity, uint256 _pumpRatio) internal returns (uint256 amountInvest){

        if (_liquidity == 0) return 0;
        (uint256 amountToken, uint256 amountEth) = IUniswapV2Router02(UNIV2ROUTER2).removeLiquidity(
            address(farmToken), WETHADDR, _liquidity, 0, 0, address(this), now.add(60));

        uint256 pumpAmount = amountToken.mul(_pumpRatio).mul(2).div(1000);
        amountEth = amountEth.add(_swapExactTokensForTokens(address(farmToken), WETHADDR, amountToken.sub(pumpAmount)));

        if (address(lpToken) == WETHADDR) {
            amountInvest = amountEth;
        } else {
            address[] memory path = new address[](2);
            path[0] = WETHADDR;
            path[1] = address(lpToken);
            uint256[] memory amounts = IUniswapV2Router02(UNIV2ROUTER2).swapExactTokensForTokens(
                  amountEth, 0, path, address(this), now.add(60));
            amountInvest = amounts[1];
        }
    }

    function _pumpLp(address token0, address token1, uint256 _amount) internal {

        if (_amount == 0) return;
        (uint256 amount0, uint256 amount1) = IUniswapV2Router02(UNIV2ROUTER2).removeLiquidity(
            token0, token1, _amount, 0, 0, address(this), now.add(60));
        amount0 = _swapExactTokensForTokens(token0, WETHADDR, amount0);
        amount1 = _swapExactTokensForTokens(token1, WETHADDR, amount1);
        _swapExactTokensForTokens(WETHADDR, address(farmToken), amount0.add(amount1));
    }

    function pump(uint256 _amount) internal {

        if (_amount == 0) return;
        (,uint256 amountEth) = IUniswapV2Router02(UNIV2ROUTER2).removeLiquidity(
            address(farmToken), WETHADDR, _amount, 0, 0, address(this), now.add(60));
        _swapExactTokensForTokens(WETHADDR, address(farmToken), amountEth);
    }

    function pumpLp(IERC20 _lpToken, uint256 _amount) internal {

        address token0 = IUniswapV2Pair(address(_lpToken)).token0();
        address token1 = IUniswapV2Pair(address(_lpToken)).token1();
        return _pumpLp(token0, token1, _amount);
    }
    
    function getWithdrawableBalance(uint256 _pid, address _user) public view returns (uint256) {

      UserInfo storage user = userInfo[_pid][_user];
      
      if (user.unlockDate > block.timestamp) {
          return 0;
      }
      
      return user.amount;
    }

    function withdraw(uint256 _pid, uint256 _amount) public {

        uint256 withdrawable = getWithdrawableBalance(_pid, msg.sender);
        require(_amount <= withdrawable, 'Your attempting to withdraw more than you have available');
        
        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][msg.sender];
        require(user.amount >= _amount, "withdraw: not good");
        updatePool(_pid);
        uint256 pending = user.amount.mul(pool.accFarmTokenPerShare).div(1e12).sub(user.rewardDebt);
        if(pending > 0) {
            safeFarmTokenTransfer(msg.sender, pending);
        }
        uint256 pumpAmount;
        uint256 liquidity;
        if(_amount > 0) {
            pumpAmount = _amount.mul(pool.pumpRatio).div(1000);
            user.amount = user.amount.sub(_amount);
            pool.lpAmount = pool.lpAmount.sub(_amount);
            if (pool.tokenType == 0 && pumpAmount > 0) {
                pump(pumpAmount);
                _amount = _amount.sub(pumpAmount);
            } else if (pool.tokenType == 1) {
                liquidity = user.liqAmount.mul(_amount).div(user.amount.add(_amount));
                _amount = lpToInvestToken(pool.lpToken, liquidity, pool.pumpRatio);
                user.liqAmount = user.liqAmount.sub(liquidity);
            } else if (pool.tokenType == 2) {
                pumpLp(pool.lpToken, pumpAmount);
                _amount = _amount.sub(pumpAmount);
            }
            if (pool.tokenType == 1) {
                pool.tmpAmount = pool.tmpAmount.sub(liquidity);
            }
            if (address(pool.lpToken) == WETHADDR) {
                IWETH(WETHADDR).withdraw(_amount);
                safeTransferETH(address(msg.sender), _amount);
            } else {
            pool.lpToken.safeTransfer(address(msg.sender), _amount);
            }
        }
        user.rewardDebt = user.amount.mul(pool.accFarmTokenPerShare).div(1e12);
        emit Withdraw(msg.sender, _pid, _amount, pumpAmount, liquidity);
    }

    function safeFarmTokenTransfer(address _to, uint256 _amount) internal {

        uint256 farmTokenBal = farmToken.balanceOf(address(this));
        if (_amount > farmTokenBal) {
            farmToken.transfer(_to, farmTokenBal);
        } else {
            farmToken.transfer(_to, _amount);
        }
    }
}