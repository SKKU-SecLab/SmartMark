
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



interface IToken {

    function totalSupply() external view returns (uint256);


    function decimals() external view returns (uint8);


    function symbol() external view returns (string memory);


    function name() external view returns (string memory);

}

contract BrewlabsLockup is Ownable, ReentrancyGuard {

    using SafeERC20 for IERC20;

    bool public isInitialized;
    uint256 public duration = 365; // 365 days

    bool public hasUserLimit;
    uint256 public poolLimitPerUser;


    uint256 public startBlock;
    uint256 public bonusEndBlock;


    uint256 public slippageFactor = 800; // 20% default slippage tolerance
    uint256 public constant slippageFactorUL = 995;

    address public uniRouterAddress;
    address[] public reflectionToStakedPath;
    address[] public earnedToStakedPath;

    address public walletA;
    address public buyBackWallet = 0xE1f1dd010BBC2860F81c8F90Ea4E38dB949BB16F;
    uint256 public performanceFee = 0.00089 ether;

    uint256 public PRECISION_FACTOR;
    uint256 public PRECISION_FACTOR_REFLECTION;

    IERC20 public stakingToken;
    IERC20 public earnedToken;
    address public dividendToken;

    uint256 public accDividendPerShare;
    uint256 public totalStaked;

    uint256 private totalEarned;
    uint256 private totalReflections;
    uint256 private reflections;

    uint256 private paidRewards;
    uint256 private shouldTotalPaid;

    struct Lockup {
        uint8 stakeType;
        uint256 duration;
        uint256 depositFee;
        uint256 withdrawFee;
        uint256 rate;
        uint256 accTokenPerShare;
        uint256 lastRewardBlock;
        uint256 totalStaked;
    }

    struct UserInfo {
        uint256 amount; // How many staked tokens the user has provided
        uint256 locked;
        uint256 available;
    }

    struct Stake {
        uint8   stakeType;
        uint256 amount;     // amount to stake
        uint256 duration;   // the lockup duration of the stake
        uint256 end;        // when does the staking period end
        uint256 rewardDebt; // Reward debt
        uint256 reflectionDebt; // Reflection debt
    }
    uint256 constant MAX_STAKES = 256;

    Lockup[] public lockups;
    mapping(address => Stake[]) public userStakes;
    mapping(address => UserInfo) public userStaked;

    event Deposit(address indexed user, uint256 stakeType, uint256 amount);
    event Withdraw(address indexed user, uint256 stakeType, uint256 amount);
    event EmergencyWithdraw(address indexed user, uint256 amount);
    event AdminTokenRecovered(address tokenRecovered, uint256 amount);

    event NewStartAndEndBlocks(uint256 startBlock, uint256 endBlock);
    event LockupUpdated(uint8 _type, uint256 _duration, uint256 _fee0, uint256 _fee1, uint256 _rate);
    event RewardsStop(uint256 blockNumber);
    event EndBlockUpdated(uint256 blockNumber);
    event UpdatePoolLimit(uint256 poolLimitPerUser, bool hasLimit);

    event ServiceInfoUpadted(address _addr, uint256 _fee);
    event DurationUpdated(uint256 _duration);

    event SetSettings(
        uint256 _slippageFactor,
        address _uniRouter,
        address[] _path0,
        address[] _path1,
        address _walletA
    );

    constructor() {}

    function initialize(
        IERC20 _stakingToken,
        IERC20 _earnedToken,
        address _dividendToken,
        address _uniRouter,
        address[] memory _earnedToStakedPath,
        address[] memory _reflectionToStakedPath
    ) external onlyOwner {

        require(!isInitialized, "Already initialized");

        isInitialized = true;

        stakingToken = _stakingToken;
        earnedToken = _earnedToken;
        dividendToken = _dividendToken;

        walletA = msg.sender;

        uint256 decimalsRewardToken = uint256(IToken(address(earnedToken)).decimals());
        require(decimalsRewardToken < 30, "Must be inferior to 30");
        PRECISION_FACTOR = uint256(10**(40 - decimalsRewardToken));

        uint256 decimalsdividendToken = 18;
        if(address(dividendToken) != address(0x0)) {
            decimalsdividendToken = uint256(IToken(address(dividendToken)).decimals());
            require(decimalsdividendToken < 30, "Must be inferior to 30");
        }
        PRECISION_FACTOR_REFLECTION = uint256(10**(40 - decimalsRewardToken));

        uniRouterAddress = _uniRouter;
        earnedToStakedPath = _earnedToStakedPath;
        reflectionToStakedPath = _reflectionToStakedPath;
    }

    function deposit(uint256 _amount, uint8 _stakeType) external payable nonReentrant {

        require(startBlock > 0 && startBlock < block.number, "Staking hasn't started yet");
        require(_amount > 0, "Amount should be greator than 0");
        require(_stakeType < lockups.length, "Invalid stake type");

        _transferPerformanceFee();
        _updatePool(_stakeType);

        UserInfo storage user = userStaked[msg.sender];
        Stake[] storage stakes = userStakes[msg.sender];
        Lockup storage lockup = lockups[_stakeType];

        uint256 pending = 0;
        uint256 pendingReflection = 0;
        for(uint256 j = 0; j < stakes.length; j++) {
            Stake storage stake = stakes[j];
            if(stake.stakeType != _stakeType) continue;
            if(stake.amount == 0) continue;

            pendingReflection = pendingReflection + (
                stake.amount * accDividendPerShare / PRECISION_FACTOR_REFLECTION - stake.reflectionDebt
            );

            uint256 _pending = stake.amount * lockup.accTokenPerShare / PRECISION_FACTOR - stake.rewardDebt;
            pending = pending + _pending;

            stake.rewardDebt = stake.amount * lockup.accTokenPerShare / PRECISION_FACTOR;
            stake.reflectionDebt = stake.amount * accDividendPerShare / PRECISION_FACTOR_REFLECTION;
        }

        if (pending > 0) {
            require(availableRewardTokens() >= pending, "Insufficient reward tokens");
            earnedToken.safeTransfer(address(msg.sender), pending);
            
            if(totalEarned > pending) {
                totalEarned = totalEarned - pending;
            } else {
                totalEarned = 0;
            }
            paidRewards = paidRewards + pending;
        }

        pendingReflection = estimateDividendAmount(pendingReflection);
        if (pendingReflection > 0) {
            if(address(dividendToken) == address(0x0)) {
                payable(msg.sender).transfer(pendingReflection);
            } else {
                IERC20(dividendToken).safeTransfer(address(msg.sender), pendingReflection);
            }
            totalReflections = totalReflections - pendingReflection;
        }

        uint256 beforeAmount = stakingToken.balanceOf(address(this));
        stakingToken.safeTransferFrom(address(msg.sender), address(this), _amount);
        uint256 afterAmount = stakingToken.balanceOf(address(this));        
        uint256 realAmount = afterAmount - beforeAmount;

        if (hasUserLimit) {
            require(
                realAmount + user.amount <= poolLimitPerUser,
                "User amount above limit"
            );
        }
        if (lockup.depositFee > 0) {
            uint256 fee = realAmount * lockup.depositFee / 10000;
            if (fee > 0) {
                stakingToken.safeTransfer(walletA, fee);
                realAmount = realAmount - fee;
            }
        }
        
        _addStake(_stakeType, msg.sender, lockup.duration, realAmount);

        user.amount = user.amount + realAmount;
        lockup.totalStaked = lockup.totalStaked + realAmount;
        totalStaked = totalStaked + realAmount;

        emit Deposit(msg.sender, _stakeType, realAmount);
    }

    function _addStake(uint8 _stakeType, address _account, uint256 _duration, uint256 _amount) internal {

        Stake[] storage stakes = userStakes[_account];

        uint256 end = block.timestamp + _duration * 1 days;
        uint256 i = stakes.length;
        require(i < MAX_STAKES, "Max stakes");

        stakes.push(); // grow the array
        while (i != 0 && stakes[i - 1].end > end) {
            stakes[i] = stakes[i - 1];
            i -= 1;
        }
        
        Lockup storage lockup = lockups[_stakeType];

        Stake storage newStake = stakes[i];
        newStake.stakeType = _stakeType;
        newStake.duration = _duration;
        newStake.end = end;
        newStake.amount = _amount;
        newStake.rewardDebt = newStake.amount * lockup.accTokenPerShare / PRECISION_FACTOR;
        newStake.reflectionDebt = newStake.amount * accDividendPerShare / PRECISION_FACTOR_REFLECTION;
    }

    function withdraw(uint256 _amount, uint8 _stakeType) external payable nonReentrant {

        require(_amount > 0, "Amount should be greator than 0");
        require(_stakeType < lockups.length, "Invalid stake type");

        _transferPerformanceFee();
        _updatePool(_stakeType);

        UserInfo storage user = userStaked[msg.sender];
        Stake[] storage stakes = userStakes[msg.sender];
        Lockup storage lockup = lockups[_stakeType];
        
        uint256 pending = 0;
        uint256 pendingReflection = 0;
        uint256 remained = _amount;
        for(uint256 j = 0; j < stakes.length; j++) {
            Stake storage stake = stakes[j];
            if(stake.stakeType != _stakeType) continue;
            if(stake.amount == 0) continue;
            if(remained == 0) break;

            uint256 _pending = stake.amount * lockup.accTokenPerShare / PRECISION_FACTOR - stake.rewardDebt;
            pendingReflection = pendingReflection + (
                stake.amount * accDividendPerShare / PRECISION_FACTOR_REFLECTION - stake.reflectionDebt
            );

            pending = pending + _pending;
            if(stake.end < block.timestamp) {
                if(stake.amount > remained) {
                    stake.amount = stake.amount - remained;
                    remained = 0;
                } else {
                    remained = remained - stake.amount;
                    stake.amount = 0;
                }
            }

            stake.rewardDebt = stake.amount * lockup.accTokenPerShare / PRECISION_FACTOR;
            stake.reflectionDebt = stake.amount * accDividendPerShare / PRECISION_FACTOR_REFLECTION;
        }

        if (pending > 0) {
            require(availableRewardTokens() >= pending, "Insufficient reward tokens");
            earnedToken.safeTransfer(address(msg.sender), pending);
            
            if(totalEarned > pending) {
                totalEarned = totalEarned - pending;
            } else {
                totalEarned = 0;
            }
            paidRewards = paidRewards + pending;
        }

        if (pendingReflection > 0) {
            pendingReflection = estimateDividendAmount(pendingReflection);
            if(address(dividendToken) == address(0x0)) {
                payable(msg.sender).transfer(pendingReflection);
            } else {
                IERC20(dividendToken).safeTransfer(address(msg.sender), pendingReflection);
            }
            totalReflections = totalReflections - pendingReflection;
        }

        uint256 realAmount = _amount - remained;
        user.amount = user.amount - realAmount;
        lockup.totalStaked = lockup.totalStaked - realAmount;
        totalStaked = totalStaked - realAmount;

        if(realAmount > 0) {
            if (lockup.withdrawFee > 0) {
                uint256 fee = realAmount * lockup.withdrawFee / 10000;
                stakingToken.safeTransfer(walletA, fee);
                realAmount = realAmount - fee;
            }

            stakingToken.safeTransfer(address(msg.sender), realAmount);
        }

        emit Withdraw(msg.sender, _stakeType, realAmount);
    }

    function claimReward(uint8 _stakeType) external payable nonReentrant {

        if(_stakeType >= lockups.length) return;
        if(startBlock == 0) return;

        _transferPerformanceFee();
        _updatePool(_stakeType);

        Stake[] storage stakes = userStakes[msg.sender];
        Lockup storage lockup = lockups[_stakeType];

        uint256 pending = 0;
        for(uint256 j = 0; j < stakes.length; j++) {
            Stake storage stake = stakes[j];
            if(stake.stakeType != _stakeType) continue;
            if(stake.amount == 0) continue;

            uint256 _pending = stake.amount * lockup.accTokenPerShare / PRECISION_FACTOR - stake.rewardDebt;
            pending = pending + _pending;

            stake.rewardDebt = stake.amount * lockup.accTokenPerShare / PRECISION_FACTOR;
        }

        if (pending > 0) {
            require(availableRewardTokens() >= pending, "Insufficient reward tokens");
            earnedToken.safeTransfer(address(msg.sender), pending);
            
            if(totalEarned > pending) {
                totalEarned = totalEarned - pending;
            } else {
                totalEarned = 0;
            }
            paidRewards = paidRewards + pending;
        }
    }

    function claimDividend(uint8 _stakeType) external payable nonReentrant {

        if(_stakeType >= lockups.length) return;
        if(startBlock == 0) return;

        _transferPerformanceFee();
        _updatePool(_stakeType);

        Stake[] storage stakes = userStakes[msg.sender];

        uint256 pendingReflection = 0;
        for(uint256 j = 0; j < stakes.length; j++) {
            Stake storage stake = stakes[j];
            if(stake.stakeType != _stakeType) continue;
            if(stake.amount == 0) continue;

            pendingReflection = pendingReflection + (
                stake.amount * accDividendPerShare / PRECISION_FACTOR_REFLECTION - stake.reflectionDebt
            );

            stake.reflectionDebt = stake.amount * accDividendPerShare / PRECISION_FACTOR_REFLECTION;
        }

        pendingReflection = estimateDividendAmount(pendingReflection);
        if (pendingReflection > 0) {
            if(address(dividendToken) == address(0x0)) {
                payable(msg.sender).transfer(pendingReflection);
            } else {
                IERC20(dividendToken).safeTransfer(address(msg.sender), pendingReflection);
            }
            totalReflections = totalReflections - pendingReflection;
        }
    }

    function compoundReward(uint8 _stakeType) external payable nonReentrant {

        if(_stakeType >= lockups.length) return;
        if(startBlock == 0) return;

        _transferPerformanceFee();
        _updatePool(_stakeType);

        UserInfo storage user = userStaked[msg.sender];
        Stake[] storage stakes = userStakes[msg.sender];
        Lockup storage lockup = lockups[_stakeType];

        uint256 pending = 0;
        uint256 compounded = 0;
        for(uint256 j = 0; j < stakes.length; j++) {
            Stake storage stake = stakes[j];
            if(stake.stakeType != _stakeType) continue;
            if(stake.amount == 0) continue;

            uint256 _pending = stake.amount * lockup.accTokenPerShare / PRECISION_FACTOR - stake.rewardDebt;
            pending = pending + _pending;

            if(address(stakingToken) != address(earnedToken) && _pending > 0) {
                uint256 _beforeAmount = stakingToken.balanceOf(address(this));
                _safeSwap(_pending, earnedToStakedPath, address(this));
                uint256 _afterAmount = stakingToken.balanceOf(address(this));
                _pending = _afterAmount - _beforeAmount;
            }
            compounded = compounded + _pending;

            stake.amount = stake.amount + _pending;
            stake.rewardDebt = stake.amount * lockup.accTokenPerShare / PRECISION_FACTOR;
            stake.reflectionDebt = stake.reflectionDebt + _pending * accDividendPerShare / PRECISION_FACTOR_REFLECTION;
        }

        if (pending > 0) {
            require(availableRewardTokens() >= pending, "Insufficient reward tokens");
            
            if(totalEarned > pending) {
                totalEarned = totalEarned - pending;
            } else {
                totalEarned = 0;
            }
            paidRewards = paidRewards + pending;

            user.amount = user.amount + compounded;
            lockup.totalStaked = lockup.totalStaked + compounded;
            totalStaked = totalStaked + compounded;

            emit Deposit(msg.sender, _stakeType, compounded);
        }
    }

    function compoundDividend(uint8 _stakeType) external payable nonReentrant {

        if(_stakeType >= lockups.length) return;
        if(startBlock == 0) return;

        _transferPerformanceFee();
        _updatePool(_stakeType);

        UserInfo storage user = userStaked[msg.sender];
        Stake[] storage stakes = userStakes[msg.sender];
        Lockup storage lockup = lockups[_stakeType];

        uint256 compounded = 0;
        for(uint256 j = 0; j < stakes.length; j++) {
            Stake storage stake = stakes[j];
            if(stake.stakeType != _stakeType) continue;
            if(stake.amount == 0) continue;

            uint256 _pending = stake.amount * accDividendPerShare / PRECISION_FACTOR_REFLECTION - stake.reflectionDebt;
            _pending = estimateDividendAmount(_pending);

            totalReflections = totalReflections - _pending;
            if(address(stakingToken) != address(dividendToken) && _pending > 0) {
                if(address(dividendToken) == address(0x0)) {
                    address wethAddress = IUniRouter02(uniRouterAddress).WETH();
                    IWETH(wethAddress).deposit{ value: _pending }();
                }

                uint256 _beforeAmount = stakingToken.balanceOf(address(this));
                _safeSwap(_pending, reflectionToStakedPath, address(this));
                uint256 _afterAmount = stakingToken.balanceOf(address(this));

                _pending = _afterAmount - _beforeAmount;
            }
            
            compounded = compounded + _pending;
            stake.amount = stake.amount + _pending;
            stake.rewardDebt = stake.rewardDebt + _pending * lockup.accTokenPerShare / PRECISION_FACTOR;
            stake.reflectionDebt = stake.amount * accDividendPerShare / PRECISION_FACTOR_REFLECTION;
        }

        if (compounded > 0) {
            user.amount = user.amount + compounded;
            lockup.totalStaked = lockup.totalStaked + compounded;
            totalStaked = totalStaked + compounded;

            emit Deposit(msg.sender, _stakeType, compounded);
        }
    }

    function _transferPerformanceFee() internal {

        require(msg.value >= performanceFee, 'should pay small gas to compound or harvest');

        payable(buyBackWallet).transfer(performanceFee);
        if(msg.value > performanceFee) {
            payable(msg.sender).transfer(msg.value - performanceFee);
        }
    }

    function emergencyWithdraw(uint8 _stakeType) external nonReentrant {

        if(_stakeType >= lockups.length) return;

        UserInfo storage user = userStaked[msg.sender];
        Stake[] storage stakes = userStakes[msg.sender];
        Lockup storage lockup = lockups[_stakeType];

        uint256 amountToTransfer = 0;
        for(uint256 j = 0; j < stakes.length; j++) {
            Stake storage stake = stakes[j];
            if(stake.stakeType != _stakeType) continue;
            if(stake.amount == 0) continue;

            amountToTransfer = amountToTransfer + stake.amount;

            stake.amount = 0;
            stake.rewardDebt = 0;
            stake.reflectionDebt = 0;
        }

        if (amountToTransfer > 0) {
            stakingToken.safeTransfer(address(msg.sender), amountToTransfer);

            user.amount = user.amount - amountToTransfer;
            lockup.totalStaked = lockup.totalStaked - amountToTransfer;
            totalStaked = totalStaked - amountToTransfer;
        }

        emit EmergencyWithdraw(msg.sender, amountToTransfer);
    }

    function rewardPerBlock(uint8 _stakeType) external view returns (uint256) {

        if(_stakeType >= lockups.length) return 0;

        return lockups[_stakeType].rate;
    }

    function availableRewardTokens() public view returns (uint256) {

        if(address(earnedToken) == address(dividendToken)) return totalEarned;

        uint256 _amount = earnedToken.balanceOf(address(this));
        if (address(earnedToken) == address(stakingToken)) {
            if (_amount < totalStaked) return 0;
            return _amount - totalStaked;
        }

        return _amount;
    }

    function availableDividendTokens() public view returns (uint256) {

        if(address(dividendToken) == address(0x0)) {
            return address(this).balance;
        }

        uint256 _amount = IERC20(dividendToken).balanceOf(address(this));
        
        if(address(dividendToken) == address(earnedToken)) {
            if(_amount < totalEarned) return 0;
            _amount = _amount - totalEarned;
        }

        if(address(dividendToken) == address(stakingToken)) {
            if(_amount < totalStaked) return 0;
            _amount = _amount - totalStaked;
        }

        return _amount;
    }

    function insufficientRewards() external view returns (uint256) {

        uint256 adjustedShouldTotalPaid = shouldTotalPaid;
        uint256 remainRewards = availableRewardTokens() + paidRewards;

        for(uint i = 0; i < lockups.length; i++) {
            if(startBlock == 0) {
                adjustedShouldTotalPaid = adjustedShouldTotalPaid + lockups[i].rate * duration * 28800;
            } else {
                uint256 remainBlocks = _getMultiplier(lockups[i].lastRewardBlock, bonusEndBlock);
                adjustedShouldTotalPaid = adjustedShouldTotalPaid + lockups[i].rate * remainBlocks;
            }
        }

        if(remainRewards >= adjustedShouldTotalPaid) return 0;

        return adjustedShouldTotalPaid - remainRewards;
    }

    function userInfo(uint8 _stakeType, address _account) external view returns (uint256 amount, uint256 available, uint256 locked) {

        Stake[] memory stakes = userStakes[_account];
        
        for(uint256 i = 0; i < stakes.length; i++) {
            Stake memory stake = stakes[i];

            if(stake.stakeType != _stakeType) continue;
            if(stake.amount == 0) continue;
            
            amount = amount + stake.amount;
            if(block.timestamp > stake.end) {
                available = available + stake.amount;
            } else {
                locked = locked + stake.amount;
            }
        }
    }

    function pendingReward(address _account, uint8 _stakeType) external view returns (uint256) {

        if(_stakeType >= lockups.length || startBlock == 0) return 0;

        Stake[] memory stakes = userStakes[_account];
        Lockup memory lockup = lockups[_stakeType];

        if(lockup.totalStaked == 0) return 0;
        
        uint256 adjustedTokenPerShare = lockup.accTokenPerShare;
        if (block.number > lockup.lastRewardBlock && lockup.totalStaked != 0 && lockup.lastRewardBlock > 0) {
            uint256 multiplier = _getMultiplier(lockup.lastRewardBlock, block.number);
            uint256 reward = multiplier * lockup.rate;

            adjustedTokenPerShare = lockup.accTokenPerShare + reward * PRECISION_FACTOR / lockup.totalStaked;
        }

        uint256 pending = 0;
        for(uint256 i = 0; i < stakes.length; i++) {
            Stake memory stake = stakes[i];
            if(stake.stakeType != _stakeType) continue;
            if(stake.amount == 0) continue;

            pending = pending + (
                    stake.amount * adjustedTokenPerShare / PRECISION_FACTOR - stake.rewardDebt
                );
        }
        return pending;
    }

    function pendingDividends(address _account, uint8 _stakeType) external view returns (uint256) {

        if(_stakeType >= lockups.length) return 0;
        if(startBlock == 0 || totalStaked == 0) return 0;

        Stake[] memory stakes = userStakes[_account];
        
        uint256 reflectionAmount = availableDividendTokens();
        if(reflectionAmount < totalReflections) {
            reflectionAmount = totalReflections;
        }

        uint256 sTokenBal = totalStaked;
        uint256 eTokenBal = availableRewardTokens();
        if(address(stakingToken) == address(earnedToken)) {
            sTokenBal = sTokenBal + eTokenBal;
        }

        uint256 adjustedReflectionPerShare = accDividendPerShare + ( 
            (reflectionAmount - totalReflections) * PRECISION_FACTOR_REFLECTION / sTokenBal
        );
        
        uint256 pendingReflection = 0;
        for(uint256 i = 0; i < stakes.length; i++) {
            Stake memory stake = stakes[i];
            if(stake.stakeType != _stakeType) continue;
            if(stake.amount == 0) continue;

            pendingReflection = pendingReflection + (
                stake.amount * adjustedReflectionPerShare / PRECISION_FACTOR_REFLECTION - stake.reflectionDebt
            );
        }
        return pendingReflection;
    }

    function harvest() external onlyOwner {

        _updatePool(0);

        reflections = estimateDividendAmount(reflections);
        if(reflections > 0) {
            if(address(dividendToken) == address(0x0)) {
                payable(walletA).transfer(reflections);
            } else {
                IERC20(dividendToken).safeTransfer(walletA, reflections);
            }

            totalReflections = totalReflections - reflections;
            reflections = 0;
        }
    }

    function depositRewards(uint _amount) external onlyOwner nonReentrant {

        require(_amount > 0, "invalid amount");

        uint256 beforeAmt = earnedToken.balanceOf(address(this));
        earnedToken.safeTransferFrom(msg.sender, address(this), _amount);
        uint256 afterAmt = earnedToken.balanceOf(address(this));

        totalEarned = totalEarned + afterAmt - beforeAmt;
    }

    function increaseEmissionRate(uint8 _stakeType, uint256 _amount) external onlyOwner {

        require(startBlock > 0, "pool is not started");
        require(bonusEndBlock > block.number, "pool was already finished");
        require(_amount > 0, "invalid amount");
        
        _updatePool(_stakeType);

        uint256 beforeAmt = earnedToken.balanceOf(address(this));
        earnedToken.safeTransferFrom(msg.sender, address(this), _amount);
        uint256 afterAmt = earnedToken.balanceOf(address(this));

        totalEarned = totalEarned + afterAmt - beforeAmt;

        uint256 remainRewards = availableRewardTokens() + paidRewards;
        uint256 adjustedShouldTotalPaid = shouldTotalPaid;
        for(uint i = 0; i < lockups.length; i++) {
            if(i == _stakeType) continue;

            if(startBlock == 0) {
                adjustedShouldTotalPaid = adjustedShouldTotalPaid + lockups[i].rate * duration * 28800;
            } else {
                uint256 remainBlocks = _getMultiplier(lockups[i].lastRewardBlock, bonusEndBlock);
                adjustedShouldTotalPaid = adjustedShouldTotalPaid + lockups[i].rate * remainBlocks;
            }
        }

        if(remainRewards > shouldTotalPaid) {
            remainRewards = remainRewards - adjustedShouldTotalPaid;

            uint256 remainBlocks = bonusEndBlock - block.number;
            lockups[_stakeType].rate = remainRewards / remainBlocks;
            emit LockupUpdated(_stakeType, lockups[_stakeType].duration, lockups[_stakeType].depositFee, lockups[_stakeType].withdrawFee, lockups[_stakeType].rate);
        }
    }

    function emergencyRewardWithdraw(uint256 _amount) external onlyOwner {

        require( block.number > bonusEndBlock, "Pool is running");
        require(availableRewardTokens() >= _amount, "Insufficient reward tokens");

        earnedToken.safeTransfer(address(msg.sender), _amount);        
        if (totalEarned > 0) {
            if (_amount > totalEarned) {
                totalEarned = 0;
            } else {
                totalEarned = totalEarned - _amount;
            }
        }
    }

    function recoverWrongTokens(address _tokenAddress, uint256 _tokenAmount) external onlyOwner {

        require(
            _tokenAddress != address(earnedToken),
            "Cannot be reward token"
        );

        if(_tokenAddress == address(stakingToken)) {
            uint256 tokenBal = stakingToken.balanceOf(address(this));
            require(_tokenAmount <= tokenBal - totalStaked, "Insufficient balance");
        }

        if(_tokenAddress == address(0x0)) {
            payable(msg.sender).transfer(_tokenAmount);
        } else {
            IERC20(_tokenAddress).safeTransfer(address(msg.sender), _tokenAmount);
        }

        emit AdminTokenRecovered(_tokenAddress, _tokenAmount);
    }

    function startReward() external onlyOwner {

        require(startBlock == 0, "Pool was already started");

        startBlock = block.number + 100;
        bonusEndBlock = startBlock + duration * 6426;
        for(uint256 i = 0; i < lockups.length; i++) {
            lockups[i].lastRewardBlock = startBlock;
        }
        
        emit NewStartAndEndBlocks(startBlock, bonusEndBlock);
    }

    function stopReward() external onlyOwner {

        for(uint8 i = 0; i < lockups.length; i++) {
            _updatePool(i);
        }

        uint256 remainRewards = availableRewardTokens() + paidRewards;
        if(remainRewards > shouldTotalPaid) {
            remainRewards = remainRewards - shouldTotalPaid;
            earnedToken.transfer(msg.sender, remainRewards);

            if(totalEarned > remainRewards) {
                totalEarned = totalEarned - remainRewards;
            } else {
                totalEarned = 0;
            }
        }

        bonusEndBlock = block.number;
        emit RewardsStop(bonusEndBlock);
    }

    function updateEndBlock(uint256 _endBlock) external onlyOwner {

        require(startBlock > 0, "Pool is not started");
        require(bonusEndBlock > block.number, "Pool was already finished");
        require(_endBlock > block.number && _endBlock > startBlock, "Invalid end block");
        bonusEndBlock = _endBlock;
        emit EndBlockUpdated(_endBlock);
    }

    function updatePoolLimitPerUser( bool _hasUserLimit, uint256 _poolLimitPerUser) external onlyOwner {

        if (_hasUserLimit) {
            require(
                _poolLimitPerUser > poolLimitPerUser,
                "New limit must be higher"
            );
            poolLimitPerUser = _poolLimitPerUser;
        } else {
            poolLimitPerUser = 0;
        }
        hasUserLimit = _hasUserLimit;

        emit UpdatePoolLimit(poolLimitPerUser, _hasUserLimit);
    }

    function updateLockup(uint8 _stakeType, uint256 _duration, uint256 _depositFee, uint256 _withdrawFee, uint256 _rate) external onlyOwner {

        require(_stakeType < lockups.length, "Lockup Not found");
        require(_depositFee < 2000, "Invalid deposit fee");
        require(_withdrawFee < 2000, "Invalid withdraw fee");

        _updatePool(_stakeType);

        Lockup storage _lockup = lockups[_stakeType];
        _lockup.duration = _duration;
        _lockup.depositFee = _depositFee;
        _lockup.withdrawFee = _withdrawFee;
        _lockup.rate = _rate;
        
        emit LockupUpdated(_stakeType, _duration, _depositFee, _withdrawFee, _rate);
    }

    function addLockup(uint256 _duration, uint256 _depositFee, uint256 _withdrawFee, uint256 _rate) external onlyOwner {

        require(_depositFee < 2000, "Invalid deposit fee");
        require(_withdrawFee < 2000, "Invalid withdraw fee");
        
        lockups.push();
        
        Lockup storage _lockup = lockups[lockups.length - 1];
        _lockup.duration = _duration;
        _lockup.depositFee = _depositFee;
        _lockup.withdrawFee = _withdrawFee;
        _lockup.rate = _rate;
        _lockup.lastRewardBlock = block.number;

        emit LockupUpdated(uint8(lockups.length - 1), _duration, _depositFee, _withdrawFee, _rate);
    }

    function setServiceInfo(address _addr, uint256 _fee) external {

        require(msg.sender == buyBackWallet, "setServiceInfo: FORBIDDEN");
        require(_addr != address(0x0), "Invalid address");
        require(_fee < 0.05 ether, "fee cannot exceed 0.05 ether");

        buyBackWallet = _addr;
        performanceFee = _fee;

        emit ServiceInfoUpadted(_addr, _fee);
    }
    
    function setDuration(uint256 _duration) external onlyOwner {

        require(startBlock == 0, "Pool was already started");
        require(_duration >= 30, "lower limit reached");

        duration = _duration;
        emit DurationUpdated(_duration);
    }

    function setSettings(
        uint256 _slippageFactor, 
        address _uniRouter, 
        address[] memory _earnedToStakedPath, 
        address[] memory _reflectionToStakedPath,
        address _feeAddr
    ) external onlyOwner {

        require(_slippageFactor <= slippageFactorUL, "_slippageFactor too high");
        require(_feeAddr != address(0x0), "Invalid Address");

        slippageFactor = _slippageFactor;
        uniRouterAddress = _uniRouter;
        reflectionToStakedPath = _reflectionToStakedPath;
        earnedToStakedPath = _earnedToStakedPath;
        walletA = _feeAddr;

        emit SetSettings(_slippageFactor, _uniRouter, _earnedToStakedPath, _reflectionToStakedPath, _feeAddr);
    }


    function _updatePool(uint8 _stakeType) internal {

        if(totalStaked > 0) {
            uint256 reflectionAmount = availableDividendTokens();
            if(reflectionAmount < totalReflections) {
                reflectionAmount = totalReflections;
            }

            uint256 sTokenBal = totalStaked;
            uint256 eTokenBal = availableRewardTokens();
            if(address(stakingToken) == address(earnedToken)) {
                sTokenBal = sTokenBal + eTokenBal;
            }

            accDividendPerShare = accDividendPerShare + (
                (reflectionAmount - totalReflections) * PRECISION_FACTOR_REFLECTION / sTokenBal
            );

            if(address(stakingToken) == address(earnedToken)) {
                reflections = reflections + (reflectionAmount - totalReflections) * eTokenBal / sTokenBal;
            }
            totalReflections = reflectionAmount;
        }

        Lockup storage lockup = lockups[_stakeType];
        if (block.number <= lockup.lastRewardBlock || lockup.lastRewardBlock == 0) return;

        if (lockup.totalStaked == 0) {
            lockup.lastRewardBlock = block.number;
            return;
        }

        uint256 multiplier = _getMultiplier(lockup.lastRewardBlock, block.number);
        uint256 _reward = multiplier * lockup.rate;
        lockup.accTokenPerShare = lockup.accTokenPerShare + (
            _reward * PRECISION_FACTOR / lockup.totalStaked
        );
        lockup.lastRewardBlock = block.number;
        shouldTotalPaid = shouldTotalPaid + _reward;
    }

    function estimateDividendAmount(uint256 amount) internal view returns(uint256) {

        uint256 dTokenBal = availableDividendTokens();
        if(amount > totalReflections) amount = totalReflections;
        if(amount > dTokenBal) amount = dTokenBal;
        return amount;
    }

    function _getMultiplier(uint256 _from, uint256 _to)
        internal
        view
        returns (uint256)
    {

        if (_to <= bonusEndBlock) {
            return _to - _from;
        } else if (_from >= bonusEndBlock) {
            return 0;
        } else {
            return bonusEndBlock - _from;
        }
    }

    function _safeSwap(
        uint256 _amountIn,
        address[] memory _path,
        address _to
    ) internal {

        uint256[] memory amounts = IUniRouter02(uniRouterAddress).getAmountsOut(_amountIn, _path);
        uint256 amountOut = amounts[amounts.length - 1];

        IERC20(_path[0]).safeApprove(uniRouterAddress, _amountIn);
        IUniRouter02(uniRouterAddress).swapExactTokensForTokensSupportingFeeOnTransferTokens(
            _amountIn,
            amountOut * slippageFactor / 1000,
            _path,
            _to,
            block.timestamp + 600
        );
    }

    receive() external payable {}
}