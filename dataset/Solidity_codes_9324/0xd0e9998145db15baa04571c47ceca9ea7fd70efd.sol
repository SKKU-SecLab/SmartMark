
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

library Math {

    function max(uint256 a, uint256 b) internal pure returns (uint256) {

        return a >= b ? a : b;
    }

    function min(uint256 a, uint256 b) internal pure returns (uint256) {

        return a < b ? a : b;
    }

    function average(uint256 a, uint256 b) internal pure returns (uint256) {

        return (a & b) + (a ^ b) / 2;
    }

    function ceilDiv(uint256 a, uint256 b) internal pure returns (uint256) {

        return a / b + (a % b == 0 ? 0 : 1);
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


interface IWrappedNative is IERC20 {

    function deposit() external payable;


    function withdraw(uint256 wad) external;

}

contract SwapRewardsChef is Ownable, ReentrancyGuard {

    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    struct UserInfo {
        uint256 amount;
        uint256 rewardDebt;
    }

    struct PoolInfo {
        IERC20 lpToken; // Address of LP token contract.
        uint256 allocPoint; // How many allocation points assigned to this pool.
        uint256 lastRewardBlock; // Last block number that reward distribution occurs.
        uint256 accRewardPerShare; // Accumulated reward per share, times 1e18. See below.
        uint256 currentDepositAmount; // Current total deposit amount in this pool
    }

    address public wrappedNativeAddress;

    IERC20 public rewardToken;
    uint256 public rewardsPerBlock;

    uint256 public denominationEmitAmount; //Blocks
    uint256 public minimumEmitAmount = 0; //Min Output Per Block
    uint256 public maximumEmitAmount = 1 ether; //Max Output Per Block

    PoolInfo[] public poolInfo;
    mapping(address => UserInfo) public userInfo;
    uint256 public totalAllocPoint = 0;
    uint256 public startBlock;

    uint256 public remainingRewards = 0;

    IUniswapV2Router02 public router;

    address public handler;

    event Harvest(address indexed user, uint256 amount);
    event Deposit(address indexed user, uint256 amount);
    event Withdraw(address indexed user, uint256 amount);
    event EmergencyWithdraw(address indexed user, uint256 amount);
    event UpdateEmissionSettings(
        address indexed user,
        uint256 denomination,
        uint256 minimum,
        uint256 maximum,
        uint256 rewardsPerBlock
    );
    event RescueTokens(
        address indexed user,
        address indexed token,
        uint256 amount
    );
    event RegisterMovedStakers();

    constructor(
        address _stakeToken, // Token staked (e.g eterna)
        address _rewardToken, // Token distributed to the user
        address _router, // router
        uint256 _denominationEmitAmount // How many blocks should the rewards last?
    ) public {
        rewardToken = IERC20(_rewardToken);

        poolInfo.push(
            PoolInfo({
        lpToken : IERC20(_stakeToken),
        allocPoint : 100,
        lastRewardBlock : startBlock,
        accRewardPerShare : 0,
        currentDepositAmount : 0
        })
        );

        router = IUniswapV2Router02(_router);
        wrappedNativeAddress = router.WETH();
        denominationEmitAmount = _denominationEmitAmount;
        totalAllocPoint = 100;
    }

    function getMultiplier(uint256 _from, uint256 _to)
    private
    pure
    returns (uint256)
    {

        return _to.sub(_from);
    }

    function pendingRewards(address _user) external view returns (uint256) {

        PoolInfo storage pool = poolInfo[0];
        UserInfo storage user = userInfo[_user];
        uint256 accRewardPerShare = pool.accRewardPerShare;
        uint256 lpSupply = pool.currentDepositAmount;
        if (block.number > pool.lastRewardBlock && lpSupply != 0) {
            if (remainingRewards > 0) {
                uint256 multiplier = getMultiplier(pool.lastRewardBlock, block.number);
                uint256 totalRewards = multiplier
                .mul(rewardsPerBlock)
                .mul(pool.allocPoint)
                .div(totalAllocPoint);
                totalRewards = Math.min(totalRewards, remainingRewards);
                accRewardPerShare = accRewardPerShare.add(
                    totalRewards.mul(1e18).div(lpSupply)
                );
            }
        }
        return user.amount.mul(accRewardPerShare).div(1e18).sub(user.rewardDebt);
    }

    function updatePool() public {

        PoolInfo storage pool = poolInfo[0];
        if (block.number <= pool.lastRewardBlock) {
            return;
        }
        uint256 lpSupply = pool.currentDepositAmount;
        if (lpSupply == 0 || pool.allocPoint == 0) {
            pool.lastRewardBlock = block.number;
            return;
        }

        if (remainingRewards == 0) {
            pool.lastRewardBlock = block.number;
            return;
        }

        uint256 multiplier = getMultiplier(pool.lastRewardBlock, block.number);
        uint256 totalRewards = multiplier
        .mul(rewardsPerBlock)
        .mul(pool.allocPoint)
        .div(totalAllocPoint);
        totalRewards = Math.min(totalRewards, remainingRewards);
        remainingRewards = remainingRewards.sub(totalRewards);
        pool.accRewardPerShare = pool.accRewardPerShare.add(
            totalRewards.mul(1e18).div(lpSupply)
        );
        pool.lastRewardBlock = block.number;
    }

    function income(uint256 _amount) external nonReentrant {

        updatePool();
        uint256 before = rewardToken.balanceOf(address(this));
        rewardToken.safeTransferFrom(msg.sender, address(this), _amount);
        _amount = rewardToken.balanceOf(address(this)).sub(before);
        remainingRewards = remainingRewards.add(_amount);
        updateEmissionRate();
    }

    function updateEmissionRate() private {

        if (remainingRewards > 0) {
            rewardsPerBlock = remainingRewards.div(denominationEmitAmount);
            rewardsPerBlock = Math.min(maximumEmitAmount, rewardsPerBlock);
            rewardsPerBlock = Math.max(minimumEmitAmount, rewardsPerBlock);
        } else {
            rewardsPerBlock = 0;
        }
    }

    function deposit(uint256 _amount) public nonReentrant {

        require(msg.sender == handler);
        PoolInfo storage pool = poolInfo[0];
        UserInfo storage user = userInfo[msg.sender];
        updatePool();
        if (user.amount > 0) {
            uint256 pending = user.amount.mul(pool.accRewardPerShare).div(1e18).sub(
                user.rewardDebt
            );
            if (pending > 0) {
                safeRewardTransfer(msg.sender, pending, (msg.sender == handler));
                emit Harvest(msg.sender, pending);
            }
        }
        if (_amount > 0) {
            uint256 before = pool.lpToken.balanceOf(address(this));
            pool.lpToken.safeTransferFrom(msg.sender, address(this), _amount);
            _amount = pool.lpToken.balanceOf(address(this)).sub(before);
            user.amount = user.amount.add(_amount);
            pool.currentDepositAmount = pool.currentDepositAmount.add(_amount);
        }
        user.rewardDebt = user.amount.mul(pool.accRewardPerShare).div(1e18);
        emit Deposit(msg.sender, _amount);
    }

    function withdraw(uint256 _amount) public nonReentrant {

        PoolInfo storage pool = poolInfo[0];
        UserInfo storage user = userInfo[msg.sender];
        require(user.amount >= _amount, "withdraw: not good");
        updatePool();
        uint256 pending = user.amount.mul(pool.accRewardPerShare).div(1e18).sub(
            user.rewardDebt
        );
        if (pending > 0) {
            safeRewardTransfer(msg.sender, pending, (msg.sender == handler));
            emit Harvest(msg.sender, pending);
        }
        if (_amount > 0) {
            user.amount = user.amount.sub(_amount);
            pool.currentDepositAmount = pool.currentDepositAmount.sub(_amount);
            pool.lpToken.safeTransfer(msg.sender, _amount);
        }
        user.rewardDebt = user.amount.mul(pool.accRewardPerShare).div(1e18);
        emit Withdraw(msg.sender, _amount);
    }

    function emergencyWithdraw() public nonReentrant {

        PoolInfo storage pool = poolInfo[0];
        UserInfo storage user = userInfo[msg.sender];
        uint256 amount = user.amount;
        user.amount = 0;
        user.rewardDebt = 0;
        pool.currentDepositAmount = pool.currentDepositAmount.sub(amount);
        pool.lpToken.safeTransfer(msg.sender, amount);
        emit EmergencyWithdraw(msg.sender, amount);
    }

    struct Stake {
        address user;
        uint256 amount;
    }

    function registerStakes(Stake[] memory _array, uint256 _sumAmount) external onlyOwner {

        PoolInfo storage pool = poolInfo[0];
        for (uint i = 0; i < _array.length; i++) {
            UserInfo memory user;
            user.amount = user.amount.add(_array[i].amount);
            userInfo[_array[i].user] = user;
        }
        pool.currentDepositAmount = pool.currentDepositAmount.add(_sumAmount);
        emit RegisterMovedStakers();
    }

    function safeRewardTransfer(
        address _to,
        uint256 _amount,
        bool _convert
    ) internal {

        PoolInfo memory pool = poolInfo[0];
        if (address(rewardToken) == wrappedNativeAddress) {
            uint256 balance = rewardToken.balanceOf(address(this));
            uint256 transferAmount = Math.min(balance, _amount);

            if (_convert) {
                rewardToken.transfer(_to, transferAmount);
            } else {
                address[] memory path;
                path[0] = address(rewardToken);
                path[1] = address(pool.lpToken);

                router.swapExactTokensForTokensSupportingFeeOnTransferTokens(
                    transferAmount,
                    0,
                    path,
                    _to,
                    block.timestamp + 60
                );
            }
        } else if (address(rewardToken) == address(pool.lpToken)) {
            uint256 balance = rewardToken.balanceOf(address(this)) >
            pool.currentDepositAmount
            ? rewardToken.balanceOf(address(this)) - pool.currentDepositAmount
            : 0;
            uint256 transferAmount = Math.min(balance, _amount);
            rewardToken.transfer(_to, transferAmount);
        } else {
            uint256 balance = rewardToken.balanceOf(address(this));
            uint256 transferAmount = Math.min(balance, _amount);
            if (_convert) {
                rewardToken.transfer(_to, transferAmount);
                address[] memory path;
                path[0] = address(rewardToken);
                path[1] = wrappedNativeAddress;
                path[2] = address(pool.lpToken);

                router.swapExactTokensForTokensSupportingFeeOnTransferTokens(
                    transferAmount,
                    0,
                    path,
                    _to,
                    block.timestamp + 60
                );
            } else {
                rewardToken.transfer(_to, transferAmount);
            }
        }
    }

    receive() external payable {}

    function safeTransferETH(address to, uint256 value) internal {

        (bool success,) = to.call{value : value}(new bytes(0));
        require(success, "safeTransferETH: ETH_TRANSFER_FAILED");
    }

    function updateEmissionSettings(
        uint256 denomination,
        uint256 minimum,
        uint256 maximum
    ) external onlyOwner {

        updatePool();
        denominationEmitAmount = denomination;
        minimumEmitAmount = minimum;
        maximumEmitAmount = maximum;
        updateEmissionRate();

        emit UpdateEmissionSettings(
            msg.sender,
            denomination,
            minimum,
            maximum,
            rewardsPerBlock
        );
    }

    function rescueToken(address token, address addressForReceive, uint amount)
    external
    onlyOwner
    {

        IERC20(token).safeTransfer(addressForReceive, amount);
        emit RescueTokens(msg.sender, token, amount);
    }

    function updateHandler(address _handler) external onlyOwner {

        handler = _handler;
    }

}