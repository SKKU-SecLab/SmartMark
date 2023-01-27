
pragma solidity ^0.8.0;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}// MIT

pragma solidity ^0.8.0;


abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor() {
        _transferOwnership(_msgSender());
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }

    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}// MIT

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
}// MIT

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
}// MIT

pragma solidity ^0.8.0;

library Address {

    function isContract(address account) internal view returns (bool) {


        uint256 size;
        assembly {
            size := extcodesize(account)
        }
        return size > 0;
    }

    function sendValue(address payable recipient, uint256 amount) internal {

        require(address(this).balance >= amount, "Address: insufficient balance");

        (bool success, ) = recipient.call{value: amount}("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    function functionCall(address target, bytes memory data) internal returns (bytes memory) {

        return functionCall(target, data, "Address: low-level call failed");
    }

    function functionCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {

        return functionCallWithValue(target, data, 0, errorMessage);
    }

    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value
    ) internal returns (bytes memory) {

        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value,
        string memory errorMessage
    ) internal returns (bytes memory) {

        require(address(this).balance >= value, "Address: insufficient balance for call");
        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{value: value}(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {

        return functionStaticCall(target, data, "Address: low-level static call failed");
    }

    function functionStaticCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal view returns (bytes memory) {

        require(isContract(target), "Address: static call to non-contract");

        (bool success, bytes memory returndata) = target.staticcall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {

        return functionDelegateCall(target, data, "Address: low-level delegate call failed");
    }

    function functionDelegateCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {

        require(isContract(target), "Address: delegate call to non-contract");

        (bool success, bytes memory returndata) = target.delegatecall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    function verifyCallResult(
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) internal pure returns (bytes memory) {

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

pragma solidity ^0.8.0;


library SafeERC20 {

    using Address for address;

    function safeTransfer(
        IERC20 token,
        address to,
        uint256 value
    ) internal {

        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(
        IERC20 token,
        address from,
        address to,
        uint256 value
    ) internal {

        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    function safeApprove(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {

        require(
            (value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {

        uint256 newAllowance = token.allowance(address(this), spender) + value;
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {

        unchecked {
            uint256 oldAllowance = token.allowance(address(this), spender);
            require(oldAllowance >= value, "SafeERC20: decreased allowance below zero");
            uint256 newAllowance = oldAllowance - value;
            _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
        }
    }

    function _callOptionalReturn(IERC20 token, bytes memory data) private {


        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) {
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}// MIT

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
}// MIT

pragma solidity ^0.8.0;

interface IUniRouter01 {

    function factory() external pure returns (address);


    function WETH() external pure returns (address);


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


    function removeLiquidityETH(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountToken, uint256 amountETH);


    function removeLiquidityWithPermit(
        address tokenA,
        address tokenB,
        uint256 liquidity,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline,
        bool approveMax,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external returns (uint256 amountA, uint256 amountB);


    function removeLiquidityETHWithPermit(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline,
        bool approveMax,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external returns (uint256 amountToken, uint256 amountETH);


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

}// MIT

pragma solidity ^0.8.0;


interface IUniRouter02 is IUniRouter01 {

    function removeLiquidityETHSupportingFeeOnTransferTokens(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountETH);


    function removeLiquidityETHWithPermitSupportingFeeOnTransferTokens(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline,
        bool approveMax,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external returns (uint256 amountETH);


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

}// MIT

pragma solidity >=0.5.0;

interface IWETH {

    function deposit() external payable;

    function transfer(address to, uint value) external returns (bool);

    function withdraw(uint) external;

}// MIT
pragma solidity ^0.8.0;



contract BrewlabsFarm is Ownable, ReentrancyGuard {

    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    struct UserInfo {
        uint256 amount;         // How many LP tokens the user has provided.
        uint256 rewardDebt;     // Reward debt. See explanation below.
        uint256 reflectionDebt;     // Reflection debt. See explanation below.
    }

    struct PoolInfo {
        IERC20 lpToken;           // Address of LP token contract.
        uint256 allocPoint;       // How many allocation points assigned to this pool. brewss to distribute per block.
        uint256 duration;
        uint256 startBlock;
        uint256 bonusEndBlock;
        uint256 lastRewardBlock;  // Last block number that brewss distribution occurs.
        uint256 accTokenPerShare;   // Accumulated brewss per share, times 1e12. See below.
        uint256 accReflectionPerShare;   // Accumulated brewss per share, times 1e12. See below.
        uint256 lastReflectionPerPoint;
        uint16 depositFee;      // Deposit fee in basis points
        uint16 withdrawFee;      // Deposit fee in basis points
    }

    struct SwapSetting {
        IERC20 lpToken;
        address swapRouter;
        address[] earnedToToken0;
        address[] earnedToToken1;
        address[] reflectionToToken0;
        address[] reflectionToToken1;
        bool enabled;
    }

    IERC20 public brews;
    address public reflectionToken;
    uint256 public accReflectionPerPoint;
    bool public hasDividend;

    uint256 public rewardPerBlock;
    uint256 public constant BONUS_MULTIPLIER = 1;
    address public feeAddress;
    address public buyBackWallet = 0xE1f1dd010BBC2860F81c8F90Ea4E38dB949BB16F;
    uint256 public performanceFee = 0.00089 ether;

    PoolInfo[] public poolInfo;
    SwapSetting[] public swapSettings;
    uint256[] public totalStaked;

    mapping(uint256 => mapping(address => UserInfo)) public userInfo;
    uint256 public totalAllocPoint = 0;
    uint256 public startBlock;

    uint256 private totalEarned;
    uint256 private totalRewardStaked;
    uint256 private totalReflectionStaked;
    uint256 private totalReflections;
    uint256 private reflectionDebt;

    event Deposit(address indexed user, uint256 indexed pid, uint256 amount);
    event Withdraw(address indexed user, uint256 indexed pid, uint256 amount);
    event EmergencyWithdraw(address indexed user, uint256 indexed pid, uint256 amount);
    event SetFeeAddress(address indexed user, address indexed newAddress);
    event SetBuyBackWallet(address indexed user, address newAddress);
    event SetPerformanceFee(uint256 fee);
    event UpdateEmissionRate(address indexed user, uint256 rewardPerBlock);

    constructor(IERC20 _brews, address _reflectionToken, uint256 _rewardPerBlock, bool _hasDividend) {
        brews = _brews;
        reflectionToken = _reflectionToken;
        rewardPerBlock = _rewardPerBlock;
        hasDividend = _hasDividend;

        feeAddress = msg.sender;
        startBlock = block.number.add(30 * 6426); // after 30 days
    }

    mapping(IERC20 => bool) public poolExistence;
    modifier nonDuplicated(IERC20 _lpToken) {

        require(poolExistence[_lpToken] == false, "nonDuplicated: duplicated");
        _;
    }

    function poolLength() external view returns (uint256) {

        return poolInfo.length;
    }

    function add(uint256 _allocPoint, IERC20 _lpToken, uint16 _depositFee, uint16 _withdrawFee, uint256 _duration, bool _withUpdate) external onlyOwner nonDuplicated(_lpToken) {

        require(_depositFee <= 10000, "add: invalid deposit fee basis points");
        require(_withdrawFee <= 10000, "add: invalid withdraw fee basis points");

        if (_withUpdate) {
            massUpdatePools();
        }
        
        uint256 lastRewardBlock = block.number > startBlock ? block.number : startBlock;
        totalAllocPoint = totalAllocPoint.add(_allocPoint);
        poolExistence[_lpToken] = true;
        poolInfo.push(PoolInfo({
            lpToken : _lpToken,
            allocPoint : _allocPoint,
            duration: _duration,
            startBlock: lastRewardBlock,
            bonusEndBlock: lastRewardBlock.add(_duration.mul(6426)),
            lastRewardBlock : lastRewardBlock,
            accTokenPerShare : 0,
            accReflectionPerShare : 0,
            lastReflectionPerPoint: 0,
            depositFee : _depositFee,
            withdrawFee: _withdrawFee
        }));

        swapSettings.push();
        swapSettings[swapSettings.length - 1].lpToken = _lpToken;

        totalStaked.push(0);
    }

    function set(uint256 _pid, uint256 _allocPoint, uint16 _depositFee, uint16 _withdrawFee, uint256 _duration, bool _withUpdate) external onlyOwner {

        require(_depositFee <= 10000, "set: invalid deposit fee basis points");
        require(_withdrawFee <= 10000, "set: invalid deposit fee basis points");
        if(poolInfo[_pid].bonusEndBlock > block.number) {
            require(poolInfo[_pid].startBlock.add(_duration.mul(6426)) > block.number, "set: invalid duration");
        }

        if (_withUpdate) {
            massUpdatePools();
        }
        
        totalAllocPoint = totalAllocPoint.sub(poolInfo[_pid].allocPoint).add(_allocPoint);

        poolInfo[_pid].allocPoint = _allocPoint;
        poolInfo[_pid].depositFee = _depositFee;
        poolInfo[_pid].withdrawFee = _withdrawFee;
        poolInfo[_pid].duration = _duration;

        if(poolInfo[_pid].bonusEndBlock < block.number) {
            if (!_withUpdate) updatePool(_pid);
            
            poolInfo[_pid].startBlock = block.number;
            poolInfo[_pid].bonusEndBlock = block.number.add(_duration.mul(6426));
        } else {
            poolInfo[_pid].bonusEndBlock = poolInfo[_pid].startBlock.add(_duration.mul(6426));
        }
    }

    function setSwapSetting(
        uint256 _pid, 
        address _uniRouter, 
        address[] memory _earnedToToken0, 
        address[] memory _earnedToToken1, 
        address[] memory _reflectionToToken0, 
        address[] memory _reflectionToToken1, 
        bool _enabled
    ) external onlyOwner {

        SwapSetting storage swapSetting = swapSettings[_pid];

        swapSetting.enabled = _enabled;
        swapSetting.swapRouter = _uniRouter;
        swapSetting.earnedToToken0 = _earnedToToken0;
        swapSetting.earnedToToken1 = _earnedToToken1;
        swapSetting.reflectionToToken0 = _reflectionToToken0;
        swapSetting.reflectionToToken1 = _reflectionToToken1;
    }

    function getMultiplier(uint256 _from, uint256 _to, uint256 _endBlock) public pure returns (uint256) {

        if(_from > _endBlock) return 0;
        if(_to > _endBlock) {
            return _endBlock.sub(_from).mul(BONUS_MULTIPLIER);    
        }

        return _to.sub(_from).mul(BONUS_MULTIPLIER);
    }

    function pendingRewards(uint256 _pid, address _user) external view returns (uint256) {

        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][_user];

        uint256 accTokenPerShare = pool.accTokenPerShare;
        uint256 lpSupply = pool.lpToken.balanceOf(address(this));
        if (block.number > pool.lastRewardBlock && lpSupply != 0) {
            uint256 multiplier = getMultiplier(pool.lastRewardBlock, block.number, pool.bonusEndBlock);
            uint256 brewsReward = multiplier.mul(rewardPerBlock).mul(pool.allocPoint).div(totalAllocPoint);
            accTokenPerShare = accTokenPerShare.add(brewsReward.mul(1e12).div(lpSupply));
        }
        return user.amount.mul(accTokenPerShare).div(1e12).sub(user.rewardDebt);
    }

    function pendingReflections(uint256 _pid, address _user) external view returns (uint256) {

        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][_user];

        uint256 accReflectionPerShare = pool.accReflectionPerShare;
        uint256 lpSupply = pool.lpToken.balanceOf(address(this));
        if(reflectionToken == address(pool.lpToken)) lpSupply = totalReflectionStaked;
        if (block.number > pool.lastRewardBlock && lpSupply != 0 && hasDividend) {
            uint256 reflectionAmt = availableDividendTokens();
            if(reflectionAmt > totalReflections) {
                reflectionAmt = reflectionAmt.sub(totalReflections);
            } else reflectionAmt = 0;
            
            uint256 _accReflectionPerPoint = accReflectionPerPoint.add(reflectionAmt.mul(1e12).div(totalAllocPoint));
            
            accReflectionPerShare = pool.accReflectionPerShare.add(
                pool.allocPoint.mul(_accReflectionPerPoint.sub(pool.lastReflectionPerPoint)).div(lpSupply)
            );
        }
        return user.amount.mul(accReflectionPerShare).div(1e12).sub(user.reflectionDebt);
    } 

    function massUpdatePools() public {

        uint256 length = poolInfo.length;
        for (uint256 pid = 0; pid < length; pid++) {
            updatePool(pid);
        }
    }

    function updatePool(uint256 _pid) public {

        PoolInfo storage pool = poolInfo[_pid];
        if (block.number <= pool.lastRewardBlock) {
            return;
        }
        uint256 lpSupply = pool.lpToken.balanceOf(address(this));
        if(reflectionToken == address(pool.lpToken)) lpSupply = totalReflectionStaked;
        if (lpSupply == 0 || pool.allocPoint == 0) {
            pool.lastRewardBlock = block.number;
            return;
        }

        uint256 multiplier = getMultiplier(pool.lastRewardBlock, block.number, pool.bonusEndBlock);
        uint256 brewsReward = multiplier.mul(rewardPerBlock).mul(pool.allocPoint).div(totalAllocPoint);
        pool.accTokenPerShare = pool.accTokenPerShare.add(brewsReward.mul(1e12).div(lpSupply));

        if(hasDividend) {
            uint256 reflectionAmt = availableDividendTokens();
            if(reflectionAmt > totalReflections) {
                reflectionAmt = reflectionAmt.sub(totalReflections);
            } else reflectionAmt = 0;

            accReflectionPerPoint = accReflectionPerPoint.add(reflectionAmt.mul(1e12).div(totalAllocPoint));
            pool.accReflectionPerShare = pool.accReflectionPerShare.add(
                pool.allocPoint.mul(accReflectionPerPoint.sub(pool.lastReflectionPerPoint)).div(lpSupply)
            );
            pool.lastReflectionPerPoint = accReflectionPerPoint;

            totalReflections = totalReflections.add(reflectionAmt);
        }

        pool.lastRewardBlock = block.number;
    }

    function deposit(uint256 _pid, uint256 _amount) external payable nonReentrant {

        _transferPerformanceFee();

        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][msg.sender];

        if(pool.bonusEndBlock < block.number) {
            massUpdatePools();

            totalAllocPoint = totalAllocPoint.sub(pool.allocPoint);
            pool.allocPoint = 0;
        } else {
            updatePool(_pid);
        }

        if (user.amount > 0) {
            uint256 pending = user.amount.mul(pool.accTokenPerShare).div(1e12).sub(user.rewardDebt);
            if (pending > 0) {
                require(availableRewardTokens() >= pending, "Insufficient reward tokens");
                safeTokenTransfer(msg.sender, pending);

                if(totalEarned > pending) {
                    totalEarned = totalEarned.sub(pending);
                } else {
                    totalEarned = 0;
                }
            }

            uint256 pendingReflection = user.amount.mul(pool.accReflectionPerShare).div(1e12).sub(user.reflectionDebt);
            pendingReflection = _estimateDividendAmount(pendingReflection);
            if (pendingReflection > 0 && hasDividend) {
                if(address(reflectionToken) == address(0x0)) {
                    payable(msg.sender).transfer(pendingReflection);
                } else {
                    IERC20(reflectionToken).safeTransfer(msg.sender, pendingReflection);
                }
                totalReflections = totalReflections.sub(pendingReflection);
            }
        }
        if (_amount > 0) {
            uint256 beforeAmt = pool.lpToken.balanceOf(address(this));
            pool.lpToken.safeTransferFrom(address(msg.sender), address(this), _amount);
            uint256 afterAmt = pool.lpToken.balanceOf(address(this));
            uint256 amount = afterAmt.sub(beforeAmt);

            if (pool.depositFee > 0) {
                uint256 depositFee = amount.mul(pool.depositFee).div(10000);
                pool.lpToken.safeTransfer(feeAddress, depositFee);
                user.amount = user.amount.add(amount).sub(depositFee);
            } else {
                user.amount = user.amount.add(amount);
            }

            _calculateTotalStaked(_pid, pool.lpToken, amount, true);
        }

        user.rewardDebt = user.amount.mul(pool.accTokenPerShare).div(1e12);
        user.reflectionDebt = user.amount.mul(pool.accReflectionPerShare).div(1e12);

        emit Deposit(msg.sender, _pid, _amount);
    }
    
    function withdraw(uint256 _pid, uint256 _amount) external payable nonReentrant {

        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][msg.sender];
        require(user.amount >= _amount, "withdraw: not good");
        require(_amount > 0, "Amount should be greator than 0");

        _transferPerformanceFee();

        if(pool.bonusEndBlock < block.number) {
            massUpdatePools();
            
            totalAllocPoint = totalAllocPoint.sub(pool.allocPoint);
            pool.allocPoint = 0;
        } else {
            updatePool(_pid);
        }

        uint256 pending = user.amount.mul(pool.accTokenPerShare).div(1e12).sub(user.rewardDebt);
        if (pending > 0) {
            require(availableRewardTokens() >= pending, "Insufficient reward tokens");
            safeTokenTransfer(msg.sender, pending);

            if(totalEarned > pending) {
                totalEarned = totalEarned.sub(pending);
            } else {
                totalEarned = 0;
            }
        }
        
        uint256 pendingReflection = user.amount.mul(pool.accReflectionPerShare).div(1e12).sub(user.reflectionDebt);
        pendingReflection = _estimateDividendAmount(pendingReflection);
        if (pendingReflection > 0 && hasDividend) {
            if(address(reflectionToken) == address(0x0)) {
                payable(msg.sender).transfer(pendingReflection);
            } else {
                IERC20(reflectionToken).safeTransfer(msg.sender, pendingReflection);
            }
            totalReflections = totalReflections.sub(pendingReflection);
        }

        if (_amount > 0) {
            user.amount = user.amount.sub(_amount);
            if (pool.withdrawFee > 0) {
                uint256 withdrawFee = _amount.mul(pool.withdrawFee).div(10000);
                pool.lpToken.safeTransfer(feeAddress, withdrawFee);
                pool.lpToken.safeTransfer(address(msg.sender), _amount.sub(withdrawFee));
            } else {
                pool.lpToken.safeTransfer(address(msg.sender), _amount);
            }

            _calculateTotalStaked(_pid, pool.lpToken, _amount, false);
        }
        user.rewardDebt = user.amount.mul(pool.accTokenPerShare).div(1e12);
        user.reflectionDebt = user.amount.mul(pool.accReflectionPerShare).div(1e12);

        emit Withdraw(msg.sender, _pid, _amount);
    }

    function claimReward(uint256 _pid) external payable nonReentrant {

        PoolInfo memory pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][msg.sender];
        if(user.amount < 0) return;

        updatePool(_pid);
        _transferPerformanceFee();

        uint256 pending = user.amount.mul(pool.accTokenPerShare).div(1e12).sub(user.rewardDebt);
        if (pending > 0) {
            require(availableRewardTokens() >= pending, "Insufficient reward tokens");
            safeTokenTransfer(msg.sender, pending);

            if(totalEarned > pending) {
                totalEarned = totalEarned.sub(pending);
            } else {
                totalEarned = 0;
            }
        }
        user.rewardDebt = user.amount.mul(pool.accTokenPerShare).div(1e12);
    }

    function compoundReward(uint256 _pid) external payable nonReentrant {

        PoolInfo memory pool = poolInfo[_pid];
        SwapSetting memory swapSetting = swapSettings[_pid];
        UserInfo storage user = userInfo[_pid][msg.sender];
        if(user.amount < 0) return;
        if(!swapSetting.enabled) return;

        updatePool(_pid);
        _transferPerformanceFee();

        uint256 pending = user.amount.mul(pool.accTokenPerShare).div(1e12).sub(user.rewardDebt);
        if (pending > 0) {
            require(availableRewardTokens() >= pending, "Insufficient reward tokens");
            if(totalEarned > pending) {
                totalEarned = totalEarned.sub(pending);
            } else {
                totalEarned = 0;
            }
        }

        if(address(brews) != address(pool.lpToken)) {
            uint256 tokenAmt = pending / 2;
            uint256 tokenAmt0 = tokenAmt;
            address token0 = address(brews);
            if(swapSetting.earnedToToken0.length > 0) {
                token0 = swapSetting.earnedToToken0[swapSetting.earnedToToken0.length - 1];
                tokenAmt0 = _safeSwap(swapSetting.swapRouter, tokenAmt, swapSetting.earnedToToken0, address(this));
            }
            uint256 tokenAmt1 = tokenAmt;
            address token1 = address(brews);
            if(swapSetting.earnedToToken1.length > 0) {
                token0 = swapSetting.earnedToToken1[swapSetting.earnedToToken1.length - 1];
                tokenAmt1 = _safeSwap(swapSetting.swapRouter, tokenAmt, swapSetting.earnedToToken1, address(this));
            }

            uint256 beforeAmt = pool.lpToken.balanceOf(address(this));
            _addLiquidity(swapSetting.swapRouter, token0, token1, tokenAmt0, tokenAmt1, address(this));
            uint256 afterAmt = pool.lpToken.balanceOf(address(this));

            pending = afterAmt - beforeAmt;
        }

        user.amount = user.amount + pending;
        user.rewardDebt = user.amount.mul(pool.accTokenPerShare).div(1e12);
        user.reflectionDebt = user.reflectionDebt + pending * pool.accReflectionPerShare / 1e12;
        
        _calculateTotalStaked(_pid, pool.lpToken, pending, true);
        emit Deposit(msg.sender, _pid, pending);
    }

    function claimDividend(uint256 _pid) external payable nonReentrant {

        PoolInfo memory pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][msg.sender];
        if(user.amount < 0) return;
        if(!hasDividend) return;
        
        updatePool(_pid);
        _transferPerformanceFee();

        uint256 pendingReflection = user.amount.mul(pool.accReflectionPerShare).div(1e12).sub(user.reflectionDebt);
        pendingReflection = _estimateDividendAmount(pendingReflection);
        if (pendingReflection > 0) {
            if(address(reflectionToken) == address(0x0)) {
                payable(msg.sender).transfer(pendingReflection);
            } else {
                IERC20(reflectionToken).safeTransfer(msg.sender, pendingReflection);
            }
            totalReflections = totalReflections.sub(pendingReflection);
        }

        user.reflectionDebt = user.amount.mul(pool.accReflectionPerShare).div(1e12);
    }

    function compoundDividend(uint256 _pid) external payable nonReentrant {

        PoolInfo memory pool = poolInfo[_pid];
        SwapSetting memory swapSetting = swapSettings[_pid];
        UserInfo storage user = userInfo[_pid][msg.sender];
        if(user.amount < 0) return;
        if(!hasDividend) return;
        
        updatePool(_pid);
        _transferPerformanceFee();

        uint256 pending = user.amount.mul(pool.accReflectionPerShare).div(1e12).sub(user.reflectionDebt);
        pending = _estimateDividendAmount(pending);
        if (pending > 0) {
            totalReflections = totalReflections.sub(pending);
        }

        if(reflectionToken != address(pool.lpToken)) {
            if(reflectionToken == address(0x0)) {
                address wethAddress = IUniRouter02(swapSetting.swapRouter).WETH();
                IWETH(wethAddress).deposit{ value: pending }();
            }

            uint256 tokenAmt = pending / 2;
            uint256 tokenAmt0 = tokenAmt;
            address token0 = reflectionToken;
            if(swapSetting.reflectionToToken0.length > 0) {
                token0 = swapSetting.reflectionToToken0[swapSetting.reflectionToToken0.length - 1];
                tokenAmt0 = _safeSwap(swapSetting.swapRouter, tokenAmt, swapSetting.reflectionToToken0, address(this));
            }
            uint256 tokenAmt1 = tokenAmt;
            address token1 = reflectionToken;
            if(swapSetting.reflectionToToken1.length > 0) {
                token0 = swapSetting.reflectionToToken1[swapSetting.reflectionToToken1.length - 1];
                tokenAmt1 = _safeSwap(swapSetting.swapRouter, tokenAmt, swapSetting.reflectionToToken1, address(this));
            }

            uint256 beforeAmt = pool.lpToken.balanceOf(address(this));
            _addLiquidity(swapSetting.swapRouter, token0, token1, tokenAmt0, tokenAmt1, address(this));
            uint256 afterAmt = pool.lpToken.balanceOf(address(this));

            pending = afterAmt - beforeAmt;
        }

        user.amount = user.amount + pending;
        user.rewardDebt = user.rewardDebt + pending.mul(pool.accTokenPerShare).div(1e12);
        user.reflectionDebt = user.amount.mul(pool.accReflectionPerShare).div(1e12);

        _calculateTotalStaked(_pid, pool.lpToken, pending, true);        
        emit Deposit(msg.sender, _pid, pending);
    }

    function emergencyWithdraw(uint256 _pid) external nonReentrant {

        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][msg.sender];
        uint256 amount = user.amount;
        user.amount = 0;
        user.rewardDebt = 0;
        pool.lpToken.safeTransfer(address(msg.sender), amount);

        _calculateTotalStaked(_pid, pool.lpToken, amount, false);
        
        emit EmergencyWithdraw(msg.sender, _pid, amount);
    }

    function _transferPerformanceFee() internal {

        require(msg.value >= performanceFee, 'should pay small gas');

        payable(buyBackWallet).transfer(performanceFee);
        if(msg.value > performanceFee) {
            payable(msg.sender).transfer(msg.value - performanceFee);
        }
    }

    function _calculateTotalStaked(uint256 _pid, IERC20 _lpToken, uint256 _amount, bool _deposit) internal {

        if(_deposit) {
            totalStaked[_pid] = totalStaked[_pid].add(_amount);
            if(address(_lpToken) == address(brews)) {
                totalRewardStaked = totalRewardStaked + _amount;
            }
            if(address(_lpToken) == reflectionToken) {
                totalReflectionStaked = totalReflectionStaked + _amount;
            }
        } else {
            totalStaked[_pid] = totalStaked[_pid] - _amount;
            if(address(_lpToken) == address(brews)) {
                if(totalRewardStaked < _amount) totalRewardStaked = _amount;
                totalRewardStaked = totalRewardStaked - _amount;
            }
            if(address(_lpToken) == reflectionToken) {
                if(totalReflectionStaked < _amount) totalReflectionStaked = _amount;
                totalReflectionStaked = totalReflectionStaked - _amount;
            }
        }        
    }

    function _estimateDividendAmount(uint256 amount) internal view returns(uint256) {

        uint256 dTokenBal = availableDividendTokens();
        if(amount > totalReflections) amount = totalReflections;
        if(amount > dTokenBal) amount = dTokenBal;
        return amount;
    }

    function availableRewardTokens() public view returns (uint256) {

        if(address(brews) == reflectionToken) return totalEarned;

        uint256 _amount = brews.balanceOf(address(this));
        return _amount - totalRewardStaked;
    }

    function availableDividendTokens() public view returns (uint256) {

        if(address(reflectionToken) == address(0x0)) {
            return address(this).balance;
        }

        uint256 _amount = IERC20(reflectionToken).balanceOf(address(this));
        return _amount - totalReflectionStaked;
    }    

    function safeTokenTransfer(address _to, uint256 _amount) internal {

        uint256 brewsBal = brews.balanceOf(address(this));
        bool transferSuccess = false;
        if (_amount > brewsBal) {
            transferSuccess = brews.transfer(_to, brewsBal);
        } else {
            transferSuccess = brews.transfer(_to, _amount);
        }
        require(transferSuccess, "safeTokenTransfer: transfer failed");
    }

    function setFeeAddress(address _feeAddress) external onlyOwner {

        feeAddress = _feeAddress;
        emit SetFeeAddress(msg.sender, _feeAddress);
    }

    function setPerformanceFee(uint256 _fee) external {

        require(msg.sender == buyBackWallet, "setPerformanceFee: FORBIDDEN");

        performanceFee = _fee;
        emit SetPerformanceFee(_fee);
    }
    
    function setBuyBackWallet(address _addr) external {

        require(msg.sender == buyBackWallet, "setBuyBackWallet: FORBIDDEN");
        buyBackWallet = _addr;
        emit SetBuyBackWallet(msg.sender, _addr);
    }

    function updateEmissionRate(uint256 _rewardPerBlock) external onlyOwner {

        massUpdatePools();
        rewardPerBlock = _rewardPerBlock;
        emit UpdateEmissionRate(msg.sender, _rewardPerBlock);
    }

    function updateStartBlock(uint256 _startBlock) external onlyOwner {

        require(startBlock > block.number, "farm is running now");
        require(_startBlock > block.number, "should be greater than current block");

        startBlock = _startBlock;
        for(uint pid = 0; pid < poolInfo.length; pid++) {
            poolInfo[pid].startBlock = startBlock;
            poolInfo[pid].lastRewardBlock = startBlock;
            poolInfo[pid].bonusEndBlock = startBlock.add(poolInfo[pid].duration.mul(6426));
        }
    }

    function depositRewards(uint _amount) external nonReentrant {

        require(_amount > 0);

        uint256 beforeAmt = brews.balanceOf(address(this));
        brews.safeTransferFrom(msg.sender, address(this), _amount);
        uint256 afterAmt = brews.balanceOf(address(this));

        totalEarned = totalEarned.add(afterAmt).sub(beforeAmt);
    }

    function emergencyWithdrawRewards(uint256 _amount) external onlyOwner {

        if(_amount == 0) {
            uint256 amount = brews.balanceOf(address(this));
            safeTokenTransfer(msg.sender, amount);
        } else {
            safeTokenTransfer(msg.sender, _amount);
        }
    }

    function emergencyWithdrawReflections() external onlyOwner {

        if(address(reflectionToken) == address(0x0)) {
            uint256 amount = address(this).balance;
            payable(address(this)).transfer(amount);
        } else {
            uint256 amount = IERC20(reflectionToken).balanceOf(address(this));
            IERC20(reflectionToken).transfer(msg.sender, amount);
        }
    }

    function recoverWrongToken(address _token) external onlyOwner {

        require(_token != address(brews) && _token != reflectionToken, "cannot recover reward token or reflection token");
        require(poolExistence[IERC20(_token)] == false, "token is using on pool");

        if(_token == address(0x0)) {
            uint256 amount = address(this).balance;
            payable(address(this)).transfer(amount);
        } else {
            uint256 amount = IERC20(_token).balanceOf(address(this));
            if(amount > 0) {
                IERC20(_token).transfer(msg.sender, amount);
            }
        }
    }

    function _safeSwap(
        address _uniRouter,
        uint256 _amountIn,
        address[] memory _path,
        address _to
    ) internal returns (uint256) {

        uint256 beforeAmt = IERC20(_path[_path.length - 1]).balanceOf(address(this));
        IERC20(_path[0]).safeApprove(_uniRouter, _amountIn);
        IUniRouter02(_uniRouter).swapExactTokensForTokensSupportingFeeOnTransferTokens(
            _amountIn,
            0,
            _path,
            _to,
            block.timestamp + 600
        );
        uint256 afterAmt = IERC20(_path[_path.length - 1]).balanceOf(address(this));
        return afterAmt - beforeAmt;
    }

    function _addLiquidity(
        address _uniRouter,
        address _token0,
        address _token1,
        uint256 _tokenAmt0,
        uint256 _tokenAmt1,
        address _to
    ) internal returns(uint256 amountA, uint256 amountB, uint256 liquidity) {

        IERC20(_token0).safeIncreaseAllowance(_uniRouter, _tokenAmt0);
        IERC20(_token1).safeIncreaseAllowance(_uniRouter, _tokenAmt1);

        (amountA, amountB, liquidity) = IUniRouter02(_uniRouter).addLiquidity(
            _token0,
            _token1,
            _tokenAmt0,
            _tokenAmt1,
            0,
            0,
            _to,
            block.timestamp + 600
        );

        IERC20(_token0).safeApprove(_uniRouter, uint256(0));
        IERC20(_token1).safeApprove(_uniRouter, uint256(0));
    }
    receive() external payable {}
}