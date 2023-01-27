

pragma solidity ^ 0.6.0;

interface IERC20 {

    function totalSupply() external view returns(uint256);


function balanceOf(address account) external view returns(uint256);


function transfer(address recipient, uint256 amount) external returns(bool);


function allowance(address owner, address spender) external view returns(uint256);


function approve(address spender, uint256 amount) external returns(bool);


function transferFrom(address sender, address recipient, uint256 amount) external returns(bool);


event Transfer(address indexed from, address indexed to, uint256 value);

event Approval(address indexed owner, address indexed spender, uint256 value);
}


pragma solidity ^ 0.6.0;

library SafeMath {

    function add(uint256 a, uint256 b) internal pure returns(uint256) {

        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns(uint256) {

        return sub(a, b, "SafeMath: subtraction overflow");
    }

    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns(uint256) {

        require(b <= a, errorMessage);
        uint256 c = a - b;

        return c;
    }

    function mul(uint256 a, uint256 b) internal pure returns(uint256) {

        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns(uint256) {

        return div(a, b, "SafeMath: division by zero");
    }

    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns(uint256) {

        require(b > 0, errorMessage);
        uint256 c = a / b;

        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns(uint256) {

        return mod(a, b, "SafeMath: modulo by zero");
    }

    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns(uint256) {

        require(b != 0, errorMessage);
        return a % b;
    }
}


pragma solidity ^ 0.6.2;

library Address {

    function isContract(address account) internal view returns(bool) {

        bytes32 codehash;
        bytes32 accountHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;
        assembly { codehash:= extcodehash(account) }
        return (codehash != accountHash && codehash != 0x0);
    }

    function sendValue(address payable recipient, uint256 amount) internal {

        require(address(this).balance >= amount, "Address: insufficient balance");

        (bool success, ) = recipient.call{ value: amount } ("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }
}


pragma solidity ^ 0.6.0;




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


        require(address(token).isContract(), "SafeERC20: call to non-contract");

        (bool success, bytes memory returndata) = address(token).call(data);
        require(success, "SafeERC20: low-level call failed");

        if (returndata.length > 0) { // Return data is optional
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}


pragma solidity ^ 0.6.0;

library EnumerableSet {


    struct Set {
        bytes32[] _values;

        mapping(bytes32 => uint256) _indexes;
    }

    function _add(Set storage set, bytes32 value) private returns(bool) {

        if (!_contains(set, value)) {
            set._values.push(value);
            set._indexes[value] = set._values.length;
            return true;
        } else {
            return false;
        }
    }

    function _remove(Set storage set, bytes32 value) private returns(bool) {

        uint256 valueIndex = set._indexes[value];

        if (valueIndex != 0) { // Equivalent to contains(set, value)

            uint256 toDeleteIndex = valueIndex - 1;
            uint256 lastIndex = set._values.length - 1;


            bytes32 lastvalue = set._values[lastIndex];

            set._values[toDeleteIndex] = lastvalue;
            set._indexes[lastvalue] = toDeleteIndex + 1; // All indexes are 1-based

            set._values.pop();

            delete set._indexes[value];

            return true;
        } else {
            return false;
        }
    }

    function _contains(Set storage set, bytes32 value) private view returns(bool) {

        return set._indexes[value] != 0;
    }

    function _length(Set storage set) private view returns(uint256) {

        return set._values.length;
    }

    function _at(Set storage set, uint256 index) private view returns(bytes32) {

        require(set._values.length > index, "EnumerableSet: index out of bounds");
        return set._values[index];
    }


    struct AddressSet {
        Set _inner;
    }

    function add(AddressSet storage set, address value) internal returns(bool) {

        return _add(set._inner, bytes32(uint256(value)));
    }

    function remove(AddressSet storage set, address value) internal returns(bool) {

        return _remove(set._inner, bytes32(uint256(value)));
    }

    function contains(AddressSet storage set, address value) internal view returns(bool) {

        return _contains(set._inner, bytes32(uint256(value)));
    }

    function length(AddressSet storage set) internal view returns(uint256) {

        return _length(set._inner);
    }

    function at(AddressSet storage set, uint256 index) internal view returns(address) {

        return address(uint256(_at(set._inner, index)));
    }



    struct UintSet {
        Set _inner;
    }

    function add(UintSet storage set, uint256 value) internal returns(bool) {

        return _add(set._inner, bytes32(value));
    }

    function remove(UintSet storage set, uint256 value) internal returns(bool) {

        return _remove(set._inner, bytes32(value));
    }

    function contains(UintSet storage set, uint256 value) internal view returns(bool) {

        return _contains(set._inner, bytes32(value));
    }

    function length(UintSet storage set) internal view returns(uint256) {

        return _length(set._inner);
    }

    function at(UintSet storage set, uint256 index) internal view returns(uint256) {

        return uint256(_at(set._inner, index));
    }
}


pragma solidity >= 0.4.24 < 0.7.0;


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

    function isConstructor() private view returns(bool) {

        address self = address(this);
        uint256 cs;
        assembly { cs:= extcodesize(self) }
        return cs == 0;
    }

    uint256[50] private ______gap;
}


pragma solidity ^ 0.6.0;


contract ContextUpgradeSafe is Initializable {


    function __Context_init() internal initializer {

        __Context_init_unchained();
    }

    function __Context_init_unchained() internal initializer {



    }


    function _msgSender() internal view virtual returns(address payable) {

        return msg.sender;
    }

    function _msgData() internal view virtual returns(bytes memory) {

        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }

    uint256[50] private __gap;
}


pragma solidity ^ 0.6.0;


contract OwnableUpgradeSafe is Initializable, ContextUpgradeSafe {

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


    function owner() public view returns(address) {

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



pragma solidity 0.6.12;

interface INerdBaseToken {

    function totalSupply() external view returns(uint256);


function balanceOf(address account) external view returns(uint256);


function transfer(address recipient, uint256 amount)
external
returns(bool);


function allowance(address owner, address spender)
external
view
returns(uint256);


function approve(address spender, uint256 amount) external returns(bool);


function transferFrom(
    address sender,
    address recipient,
    uint256 amount
) external returns(bool);


event Transfer(address indexed from, address indexed to, uint256 value);

event Approval(
    address indexed owner,
    address indexed spender,
    uint256 value
);

event Log(string log);
}

interface INerdBaseTokenLGE is INerdBaseToken {

    function getAllocatedLP(address _user) external view returns(uint256);


    function getLpReleaseStart() external view returns(uint256);


    function getTokenUniswapPair() external view returns(address);


    function getTotalLPTokensMinted() external view returns(uint256);


    function getReleasableLPTokensMinted() external view returns(uint256);


    function isLPGenerationCompleted() external view returns(bool);


    function tokenUniswapPair() external view returns(address);


    function getUniswapRouterV2() external view returns(address);


    function getUniswapFactory() external view returns(address);


    function devFundAddress() external view returns(address);


    function transferCheckerAddress() external view returns(address);


    function feeDistributor() external view returns(address);

}



pragma solidity 0.6.12;

interface IFeeApprover {

    function check(
    address sender,
    address recipient,
    uint256 amount
) external returns(bool);


function setFeeMultiplier(uint256 _feeMultiplier) external;


function feePercentX100() external view returns(uint256);


function setTokenUniswapPair(address _tokenUniswapPair) external;


function setNerdTokenAddress(address _nerdTokenAddress) external;


function updateTxState() external;


function calculateAmountsAfterFee(
    address sender,
    address recipient,
    uint256 amount
)
external
returns(uint256 transferToAmount, uint256 transferToFeeBearerAmount);


function setPaused() external;

}


pragma solidity 0.6.12;

interface INoFeeSimple {

    function noFeeList(address) external view returns(bool);

}


pragma solidity 0.6.12;










contract TimeLockNerdPool {

    using SafeMath for uint256;
        using Address for address;

            uint256 public constant NERD_LOCKED_PERIOD_DAYS = 14; //10 weeks,
    uint256 public constant NERD_RELEASE_TRUNK = 1 days; //releasable every week,

    struct UserInfo {
        uint256 amount; // How many  tokens the user currently has.
        uint256 referenceAmount; //this amount is used for computing releasable LP amount
        uint256 rewardDebt; // Reward debt. See explanation below.
        uint256 rewardLocked;
        uint256 releaseTime;

        uint256 depositTime; //See explanation below.
    }

    struct PoolInfo {
        uint256 accNerdPerShare; // Accumulated NERDs per share, times 1e18. See below.
        uint256 lockedPeriod; // liquidity locked period
        bool emergencyWithdrawable;
        uint256 rewardsInThisEpoch;
        uint256 cumulativeRewardsSinceStart;
        uint256 startBlock;
        mapping(uint256 => uint256) epochRewards;
        uint256 epochCalculationStartBlock;
        uint256 totalDeposit;
    }

    PoolInfo public poolInfo;
    mapping(address => UserInfo) public userInfo;

    INerdBaseTokenLGE public nerd = INerdBaseTokenLGE(
        0x32C868F6318D6334B2250F323D914Bc2239E4EeE
    );
    address public nerdAddress;

    function getNerdReleaseStart(address _user) public view returns(uint256) {

        return userInfo[_user].depositTime;
    }

    function getRemainingNerd(address _user) public view returns(uint256) {

        return userInfo[_user].amount;
    }

    function getReferenceAmount(address _user) public view returns(uint256) {

        return userInfo[_user].referenceAmount;
    }

    function computeReleasableNerd(address _addr)
    public
    view
    returns(uint256)
    {

        uint256 nerdReleaseStart = getNerdReleaseStart(_addr);
        if (block.timestamp < nerdReleaseStart) {
            return 0;
        }

        uint256 amountNerd = getReferenceAmount(_addr);
        if (amountNerd == 0) return 0;

        uint256 totalReleasableTilNow = 0;

        if (block.timestamp > nerdReleaseStart.add(poolInfo.lockedPeriod)) {
            totalReleasableTilNow = amountNerd;
        } else {
            uint256 daysTilNow = daysSinceNerdReleaseTilNow(_addr);

            totalReleasableTilNow = daysTilNow
                .mul(NERD_RELEASE_TRUNK)
                .mul(amountNerd)
                .div(poolInfo.lockedPeriod);
        }
        if (totalReleasableTilNow > amountNerd) {
            totalReleasableTilNow = amountNerd;
        }
        uint256 alreadyReleased = amountNerd.sub(getRemainingNerd(_addr));
        if (totalReleasableTilNow > alreadyReleased) {
            return totalReleasableTilNow.sub(alreadyReleased);
        }
        return 0;
    }

    function daysSinceNerdReleaseTilNow(address _addr)
    public
    view
    returns(uint256)
    {

        uint256 nerdReleaseStart = getNerdReleaseStart(_addr);
        if (nerdReleaseStart == 0 || block.timestamp < nerdReleaseStart)
            return 0;
        uint256 timeTillNow = block.timestamp.sub(nerdReleaseStart);
        uint256 daysTilNow = timeTillNow.div(NERD_RELEASE_TRUNK);
        daysTilNow = daysTilNow.add(1);
        return daysTilNow;
    }
}

contract StakingPool is OwnableUpgradeSafe, TimeLockNerdPool {

    using SafeMath for uint256;
        using SafeERC20 for IERC20;

            address public devaddr;
    address public tentativeDevAddress;

    uint256 public pendingRewards;

    uint256 public epoch;

    uint256 public constant REWARD_LOCKED_PERIOD = 28 days;
    uint256 public constant REWARD_RELEASE_PERCENTAGE = 50;
    uint256 public contractStartBlock;

    uint16 DEV_FEE;

    uint256 public pending_DEV_rewards;
    uint256 public nerdBalance;
    uint256 public pendingDeposit;

    function averageFeesPerBlockSinceStart()
    external
    view
    returns(uint256 averagePerBlock)
    {

        averagePerBlock = poolInfo
            .cumulativeRewardsSinceStart
            .add(poolInfo.rewardsInThisEpoch)
            .add(pendingNerdForPool())
            .div(block.number.sub(poolInfo.startBlock));
    }

    function averageFeesPerBlockEpoch()
    external
    view
    returns(uint256 averagePerBlock)
    {

        averagePerBlock = poolInfo
            .rewardsInThisEpoch
            .add(pendingNerdForPool())
            .div(block.number.sub(poolInfo.epochCalculationStartBlock));
    }

    function getEpochReward(uint256 _epoch) public view returns(uint256) {

        return poolInfo.epochRewards[_epoch];
    }

    function nerdDeposit() public view returns(uint256) {

        return poolInfo.totalDeposit.add(pendingDeposit);
    }

    function startNewEpoch() public {

        require(
            poolInfo.epochCalculationStartBlock + 50000 < block.number,
            "New epoch not ready yet"
        ); // About a week
        poolInfo.epochRewards[epoch] = poolInfo.rewardsInThisEpoch;
        poolInfo.cumulativeRewardsSinceStart = poolInfo
            .cumulativeRewardsSinceStart
            .add(poolInfo.rewardsInThisEpoch);
        poolInfo.rewardsInThisEpoch = 0;
        poolInfo.epochCalculationStartBlock = block.number;
        ++epoch;
    }

    event Deposit(address indexed user, uint256 amount);
    event Restake(address indexed user, uint256 amount);
    event Withdraw(address indexed user, uint256 amount);
    event EmergencyWithdraw(address indexed user, uint256 amount);
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );

    function initialize() public initializer {

        OwnableUpgradeSafe.__Ownable_init();
        nerd = INerdBaseTokenLGE(0x32C868F6318D6334B2250F323D914Bc2239E4EeE);
        require(
            INoFeeSimple(nerd.transferCheckerAddress()).noFeeList(
                address(this)
            ),
            "!Staking pool should not have fee"
        );
        poolInfo.lockedPeriod = NERD_LOCKED_PERIOD_DAYS.mul(NERD_RELEASE_TRUNK);
        DEV_FEE = 724;
        devaddr = nerd.devFundAddress();
        tentativeDevAddress = address(0);
        contractStartBlock = block.number;

        poolInfo.emergencyWithdrawable = false;
        poolInfo.accNerdPerShare = 0;
        poolInfo.rewardsInThisEpoch = 0;
        poolInfo.cumulativeRewardsSinceStart = 0;
        poolInfo.startBlock = block.number;
        poolInfo.epochCalculationStartBlock = block.number;
        poolInfo.totalDeposit = 0;
    }

    function isMultipleOfWeek(uint256 _period) public pure returns(bool) {

        uint256 numWeeks = _period.div(NERD_RELEASE_TRUNK);
        return (_period == numWeeks.mul(NERD_RELEASE_TRUNK));
    }

    function getDepositTime(address _addr) public view returns(uint256) {

        return userInfo[_addr].depositTime;
    }

    function setEmergencyWithdrawable(bool _withdrawable) public onlyOwner {

        poolInfo.emergencyWithdrawable = _withdrawable;
    }

    function setDevFee(uint16 _DEV_FEE) public onlyOwner {

        require(_DEV_FEE <= 1000, "Dev fee clamped at 10%");
        DEV_FEE = _DEV_FEE;
    }

    function pendingNerdForPool() public view returns(uint256) {

        uint256 tokenSupply = poolInfo.totalDeposit;

        if (tokenSupply == 0) return 0;

        uint256 nerdRewardWhole = pendingRewards;
        uint256 nerdRewardFee = nerdRewardWhole.mul(DEV_FEE).div(10000);
        return nerdRewardWhole.sub(nerdRewardFee);
    }

    function computeDepositAmount(
        address _sender,
        address _recipient,
        uint256 _amount
    ) internal returns(uint256) {

        (uint256 _receiveAmount, ) = IFeeApprover(nerd.transferCheckerAddress())
            .calculateAmountsAfterFee(_sender, _recipient, _amount);
        return _receiveAmount;
    }

    function pendingNerd(address _user) public view returns(uint256) {

        UserInfo storage user = userInfo[_user];
        uint256 accNerdPerShare = poolInfo.accNerdPerShare;
        uint256 amount = user.amount;

        uint256 tokenSupply = poolInfo.totalDeposit;

        if (tokenSupply == 0) return 0;

        uint256 nerdRewardFee = pendingRewards.mul(DEV_FEE).div(10000);
        uint256 nerdRewardToDistribute = pendingRewards.sub(nerdRewardFee);
        uint256 inc = nerdRewardToDistribute.mul(1e18).div(tokenSupply);
        accNerdPerShare = accNerdPerShare.add(inc);

        return amount.mul(accNerdPerShare).div(1e18).sub(user.rewardDebt);
    }

    function getLockedReward(address _user) public view returns(uint256) {

        return userInfo[_user].rewardLocked;
    }

    function massUpdatePools() public {

        uint256 allRewards = updatePool();
        pendingRewards = pendingRewards.sub(allRewards);
    }

    function updatePendingRewards() public {

        uint256 newRewards = nerd.balanceOf(address(this)).sub(nerdBalance).sub(
            nerdDeposit()
        );

        if (newRewards > 0) {
            nerdBalance = nerd.balanceOf(address(this)).sub(nerdDeposit()); // If there is no change the balance didn't change
            pendingRewards = pendingRewards.add(newRewards);
        }
    }

    function updatePool() internal returns(uint256 nerdRewardWhole) {

        uint256 tokenSupply = poolInfo.totalDeposit;
        if (tokenSupply == 0) {
            return 0;
        }
        nerdRewardWhole = pendingRewards;

        uint256 nerdRewardFee = nerdRewardWhole.mul(DEV_FEE).div(10000);
        uint256 nerdRewardToDistribute = nerdRewardWhole.sub(nerdRewardFee);

        uint256 inc = nerdRewardToDistribute.mul(1e18).div(tokenSupply);
        pending_DEV_rewards = pending_DEV_rewards.add(nerdRewardFee);

        poolInfo.accNerdPerShare = poolInfo.accNerdPerShare.add(inc);
        poolInfo.rewardsInThisEpoch = poolInfo.rewardsInThisEpoch.add(
            nerdRewardToDistribute
        );
    }

    function withdrawNerd() public {

        withdraw(0);
    }

    function claimAndRestake() public {

        UserInfo storage user = userInfo[msg.sender];
        require(user.amount > 0);
        massUpdatePools();

        if (user.releaseTime == 0) {
            user.releaseTime = block.timestamp.add(REWARD_LOCKED_PERIOD);
        }
        uint256 _rewards = 0;
        if (block.timestamp > user.releaseTime) {
            uint256 lockedAmount = user.rewardLocked;
            user.rewardLocked = 0;
            user.releaseTime = block.timestamp.add(REWARD_LOCKED_PERIOD);
            _rewards = _rewards.add(lockedAmount);
        }

        uint256 pending = pendingNerd(msg.sender);
        uint256 paid = pending.mul(REWARD_RELEASE_PERCENTAGE).div(100);
        uint256 _lockedReward = pending.sub(paid);
        if (_lockedReward > 0) {
            user.rewardLocked = user.rewardLocked.add(_lockedReward);
        }

        _rewards = _rewards.add(paid);

        uint256 lockedPeriod = poolInfo.lockedPeriod;
        uint256 tobeReleased = computeReleasableNerd(msg.sender);
        uint256 amountAfterDeposit = user.amount.add(_rewards);
        uint256 diffTime = tobeReleased.mul(lockedPeriod).div(
            amountAfterDeposit
        );
        user.depositTime = block.timestamp.sub(diffTime.div(2));
        user.referenceAmount = amountAfterDeposit;

        user.amount = user.amount.add(_rewards);
        user.rewardDebt = user.amount.mul(poolInfo.accNerdPerShare).div(1e18);
        poolInfo.totalDeposit = poolInfo.totalDeposit.add(_rewards);
        emit Restake(msg.sender, _rewards);
    }

    function deposit(uint256 _originAmount) public {

        UserInfo storage user = userInfo[msg.sender];

        massUpdatePools();

        updateAndPayOutPending(msg.sender);

        pendingDeposit = computeDepositAmount(
            msg.sender,
            address(this),
            _originAmount
        );
        uint256 _actualDepositReceive = pendingDeposit;
        if (_actualDepositReceive > 0) {
            nerd.transferFrom(
                address(msg.sender),
                address(this),
                _originAmount
            );
            pendingDeposit = 0;
            updateDepositTime(msg.sender, _actualDepositReceive);
            user.amount = user.amount.add(_actualDepositReceive);
        }
        user.rewardDebt = user.amount.mul(poolInfo.accNerdPerShare).div(1e18);
        poolInfo.totalDeposit = poolInfo.totalDeposit.add(
            _actualDepositReceive
        );
        emit Deposit(msg.sender, _actualDepositReceive);
    }

    function updateDepositTime(address _addr, uint256 _depositAmount) internal {

        UserInfo storage user = userInfo[_addr];
        if (user.amount == 0) {
            user.depositTime = block.timestamp;
            user.referenceAmount = _depositAmount;
        } else {
            uint256 lockedPeriod = poolInfo.lockedPeriod;
            uint256 tobeReleased = computeReleasableNerd(_addr);
            uint256 amountAfterDeposit = user.amount.add(_depositAmount);
            uint256 diffTime = tobeReleased.mul(lockedPeriod).div(
                amountAfterDeposit
            );
            user.depositTime = block.timestamp.sub(diffTime.div(2));
            user.referenceAmount = amountAfterDeposit;
        }
    }

    function depositFor(address _depositFor, uint256 _originAmount) public {

        UserInfo storage user = userInfo[_depositFor];

        massUpdatePools();

        updateAndPayOutPending(_depositFor); // Update the balances of person that amount is being deposited for

        pendingDeposit = computeDepositAmount(
            msg.sender,
            address(this),
            _originAmount
        );
        uint256 _actualDepositReceive = pendingDeposit;
        if (_actualDepositReceive > 0) {
            nerd.transferFrom(
                address(msg.sender),
                address(this),
                _originAmount
            );
            pendingDeposit = 0;
            updateDepositTime(_depositFor, _actualDepositReceive);
            user.amount = user.amount.add(_actualDepositReceive); // This is depositedFor address
        }

        user.rewardDebt = user.amount.mul(poolInfo.accNerdPerShare).div(1e18); /// This is deposited for address
        poolInfo.totalDeposit = poolInfo.totalDeposit.add(
            _actualDepositReceive
        );
        emit Deposit(_depositFor, _actualDepositReceive);
    }

    function quitPool() public {

        require(
            block.timestamp > getNerdReleaseStart(msg.sender),
            "cannot withdraw all lp tokens before"
        );

        uint256 withdrawnableAmount = computeReleasableNerd(msg.sender);
        withdraw(withdrawnableAmount);
    }

    function withdraw(uint256 _amount) public {

        _withdraw(_amount, msg.sender, msg.sender);
    }

    function _withdraw(
        uint256 _amount,
        address from,
        address to
    ) internal {

        UserInfo storage user = userInfo[from];
        require(computeReleasableNerd(from) >= _amount, "withdraw: not good");

        massUpdatePools();
        updateAndPayOutPending(from); // Update balances of from this is not withdrawal but claiming NERD farmed

        if (_amount > 0) {
            user.amount = user.amount.sub(_amount);
            poolInfo.totalDeposit = poolInfo.totalDeposit.sub(_amount);
            safeNerdTransfer(address(to), _amount);
        }
        user.rewardDebt = user.amount.mul(poolInfo.accNerdPerShare).div(1e18);

        emit Withdraw(to, _amount);
    }

    function updateAndPayOutPending(address from) internal {

        UserInfo storage user = userInfo[from];
        if (user.releaseTime == 0) {
            user.releaseTime = block.timestamp.add(REWARD_LOCKED_PERIOD);
        }
        if (block.timestamp > user.releaseTime) {
            uint256 lockedAmount = user.rewardLocked;
            user.rewardLocked = 0;
            safeNerdTransfer(from, lockedAmount);
            user.releaseTime = block.timestamp.add(REWARD_LOCKED_PERIOD);
        }

        uint256 pending = pendingNerd(from);
        uint256 paid = pending.mul(REWARD_RELEASE_PERCENTAGE).div(100);
        uint256 _lockedReward = pending.sub(paid);
        if (_lockedReward > 0) {
            user.rewardLocked = user.rewardLocked.add(_lockedReward);
        }

        if (paid > 0) {
            safeNerdTransfer(from, paid);
        }
    }

    function emergencyWithdraw() public {

        require(
            poolInfo.emergencyWithdrawable,
            "Withdrawing from this pool is disabled"
        );
        UserInfo storage user = userInfo[msg.sender];
        poolInfo.totalDeposit = poolInfo.totalDeposit.sub(user.amount);
        uint256 withdrawnAmount = user.amount;
        if (withdrawnAmount > nerd.balanceOf(address(this))) {
            withdrawnAmount = nerd.balanceOf(address(this));
        }
        safeNerdTransfer(address(msg.sender), withdrawnAmount);
        emit EmergencyWithdraw(msg.sender, withdrawnAmount);
        user.amount = 0;
        user.rewardDebt = 0;
    }

    function safeNerdTransfer(address _to, uint256 _amount) internal {

        uint256 nerdBal = nerd.balanceOf(address(this));

        if (_amount > nerdBal) {
            nerd.transfer(_to, nerdBal);
            nerdBalance = nerd.balanceOf(address(this)).sub(nerdDeposit());
        } else {
            nerd.transfer(_to, _amount);
            nerdBalance = nerd.balanceOf(address(this)).sub(nerdDeposit());
        }
        transferDevFee();
    }

    function transferDevFee() public {

        if (pending_DEV_rewards == 0) return;

        uint256 nerdBal = nerd.balanceOf(address(this));
        if (pending_DEV_rewards > nerdBal) {
            nerd.transfer(devaddr, nerdBal);
            nerdBalance = nerd.balanceOf(address(this)).sub(nerdDeposit());
        } else {
            nerd.transfer(devaddr, pending_DEV_rewards);
            nerdBalance = nerd.balanceOf(address(this)).sub(nerdDeposit());
        }

        pending_DEV_rewards = 0;
    }

    function setDevFeeReciever(address _devaddr) public onlyOwner {

        require(devaddr == msg.sender, "only dev can change");
        tentativeDevAddress = _devaddr;
    }

    function confirmDevAddress() public {

        require(tentativeDevAddress == msg.sender, "not tentativeDevAddress!");
        devaddr = tentativeDevAddress;
        tentativeDevAddress = address(0);
    }
}