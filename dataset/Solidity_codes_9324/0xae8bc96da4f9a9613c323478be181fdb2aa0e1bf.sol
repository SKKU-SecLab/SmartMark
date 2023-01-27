
pragma solidity 0.5.16;


interface IBasicToken {

    function decimals() external view returns (uint8);

}

contract IERC20WithCheckpointing {

    function balanceOf(address _owner) public view returns (uint256);

    function balanceOfAt(address _owner, uint256 _blockNumber) public view returns (uint256);


    function totalSupply() public view returns (uint256);

    function totalSupplyAt(uint256 _blockNumber) public view returns (uint256);

}

contract IIncentivisedVotingLockup is IERC20WithCheckpointing {


    function getLastUserPoint(address _addr) external view returns(int128 bias, int128 slope, uint256 ts);

    function createLock(uint256 _value, uint256 _unlockTime) external;

    function withdraw() external;

    function increaseLockAmount(uint256 _value) external;

    function increaseLockLength(uint256 _unlockTime) external;

    function eject(address _user) external;

    function expireContract() external;


    function claimReward() public;

    function earned(address _account) public view returns (uint256);

}

contract ReentrancyGuard {

    bool private _notEntered;

    constructor () internal {
        _notEntered = true;
    }

    modifier nonReentrant() {

        require(_notEntered, "ReentrancyGuard: reentrant call");

        _notEntered = false;

        _;

        _notEntered = true;
    }
}

contract ModuleKeys {


    bytes32 internal constant KEY_GOVERNANCE = 0x9409903de1e6fd852dfc61c9dacb48196c48535b60e25abf92acc92dd689078d;
    bytes32 internal constant KEY_STAKING = 0x1df41cd916959d1163dc8f0671a666ea8a3e434c13e40faef527133b5d167034;
    bytes32 internal constant KEY_PROXY_ADMIN = 0x96ed0203eb7e975a4cbcaa23951943fa35c5d8288117d50c12b3d48b0fab48d1;

    bytes32 internal constant KEY_ORACLE_HUB = 0x8ae3a082c61a7379e2280f3356a5131507d9829d222d853bfa7c9fe1200dd040;
    bytes32 internal constant KEY_MANAGER = 0x6d439300980e333f0256d64be2c9f67e86f4493ce25f82498d6db7f4be3d9e6f;
    bytes32 internal constant KEY_RECOLLATERALISER = 0x39e3ed1fc335ce346a8cbe3e64dd525cf22b37f1e2104a755e761c3c1eb4734f;
    bytes32 internal constant KEY_META_TOKEN = 0xea7469b14936af748ee93c53b2fe510b9928edbdccac3963321efca7eb1a57a2;
    bytes32 internal constant KEY_SAVINGS_MANAGER = 0x12fe936c77a1e196473c4314f3bed8eeac1d757b319abb85bdda70df35511bf1;
}

interface INexus {

    function governor() external view returns (address);

    function getModule(bytes32 key) external view returns (address);


    function proposeModule(bytes32 _key, address _addr) external;

    function cancelProposedModule(bytes32 _key) external;

    function acceptProposedModule(bytes32 _key) external;

    function acceptProposedModules(bytes32[] calldata _keys) external;


    function requestLockModule(bytes32 _key) external;

    function cancelLockModule(bytes32 _key) external;

    function lockModule(bytes32 _key) external;

}

contract Module is ModuleKeys {


    INexus public nexus;

    constructor(address _nexus) internal {
        require(_nexus != address(0), "Nexus is zero address");
        nexus = INexus(_nexus);
    }

    modifier onlyGovernor() {

        require(msg.sender == _governor(), "Only governor can execute");
        _;
    }

    modifier onlyGovernance() {

        require(
            msg.sender == _governor() || msg.sender == _governance(),
            "Only governance can execute"
        );
        _;
    }

    modifier onlyProxyAdmin() {

        require(
            msg.sender == _proxyAdmin(), "Only ProxyAdmin can execute"
        );
        _;
    }

    modifier onlyManager() {

        require(msg.sender == _manager(), "Only manager can execute");
        _;
    }

    function _governor() internal view returns (address) {

        return nexus.governor();
    }

    function _governance() internal view returns (address) {

        return nexus.getModule(KEY_GOVERNANCE);
    }

    function _staking() internal view returns (address) {

        return nexus.getModule(KEY_STAKING);
    }

    function _proxyAdmin() internal view returns (address) {

        return nexus.getModule(KEY_PROXY_ADMIN);
    }

    function _metaToken() internal view returns (address) {

        return nexus.getModule(KEY_META_TOKEN);
    }

    function _oracleHub() internal view returns (address) {

        return nexus.getModule(KEY_ORACLE_HUB);
    }

    function _manager() internal view returns (address) {

        return nexus.getModule(KEY_MANAGER);
    }

    function _savingsManager() internal view returns (address) {

        return nexus.getModule(KEY_SAVINGS_MANAGER);
    }

    function _recollateraliser() internal view returns (address) {

        return nexus.getModule(KEY_RECOLLATERALISER);
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

interface IRewardsDistributionRecipient {

    function notifyRewardAmount(uint256 reward) external;

    function getRewardToken() external view returns (IERC20);

}

contract RewardsDistributionRecipient is IRewardsDistributionRecipient, Module {


    function notifyRewardAmount(uint256 reward) external;

    function getRewardToken() external view returns (IERC20);


    address public rewardsDistributor;

    constructor(address _nexus, address _rewardsDistributor)
        internal
        Module(_nexus)
    {
        rewardsDistributor = _rewardsDistributor;
    }

    modifier onlyRewardsDistributor() {

        require(msg.sender == rewardsDistributor, "Caller is not reward distributor");
        _;
    }

    function setRewardsDistribution(address _rewardsDistributor)
        external
        onlyGovernor
    {

        rewardsDistributor = _rewardsDistributor;
    }
}


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

library Address {

    function isContract(address account) internal view returns (bool) {

        bytes32 codehash;
        bytes32 accountHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;
        assembly { codehash := extcodehash(account) }
        return (codehash != accountHash && codehash != 0x0);
    }

    function toPayable(address account) internal pure returns (address payable) {

        return address(uint160(account));
    }

    function sendValue(address payable recipient, uint256 amount) internal {

        require(address(this).balance >= amount, "Address: insufficient balance");

        (bool success, ) = recipient.call.value(amount)("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }
}

library SafeERC20 {

    using SafeMath for uint256;
    using Address for address;

    function safeTransfer(IERC20 token, address to, uint256 value) internal {

        callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(IERC20 token, address from, address to, uint256 value) internal {

        callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    function safeApprove(IERC20 token, address spender, uint256 value) internal {

        require((value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(IERC20 token, address spender, uint256 value) internal {

        uint256 newAllowance = token.allowance(address(this), spender).add(value);
        callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(IERC20 token, address spender, uint256 value) internal {

        uint256 newAllowance = token.allowance(address(this), spender).sub(value, "SafeERC20: decreased allowance below zero");
        callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function callOptionalReturn(IERC20 token, bytes memory data) private {


        require(address(token).isContract(), "SafeERC20: call to non-contract");

        (bool success, bytes memory returndata) = address(token).call(data);
        require(success, "SafeERC20: low-level call failed");

        if (returndata.length > 0) { // Return data is optional
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}

library SignedSafeMath128 {

    int128 constant private _INT128_MIN = -2**127;

    function mul(int128 a, int128 b) internal pure returns (int128) {

        if (a == 0) {
            return 0;
        }

        require(!(a == -1 && b == _INT128_MIN), "SignedSafeMath: multiplication overflow");

        int128 c = a * b;
        require(c / a == b, "SignedSafeMath: multiplication overflow");

        return c;
    }

    function div(int128 a, int128 b) internal pure returns (int128) {

        require(b != 0, "SignedSafeMath: division by zero");
        require(!(b == -1 && a == _INT128_MIN), "SignedSafeMath: division overflow");

        int128 c = a / b;

        return c;
    }

    function sub(int128 a, int128 b) internal pure returns (int128) {

        int128 c = a - b;
        require((b >= 0 && c <= a) || (b < 0 && c > a), "SignedSafeMath: subtraction overflow");

        return c;
    }

    function add(int128 a, int128 b) internal pure returns (int128) {

        int128 c = a + b;
        require((b >= 0 && c >= a) || (b < 0 && c < a), "SignedSafeMath: addition overflow");

        return c;
    }
}

library StableMath {


    using SafeMath for uint256;

    uint256 private constant FULL_SCALE = 1e18;

    uint256 private constant RATIO_SCALE = 1e8;

    function getFullScale() internal pure returns (uint256) {

        return FULL_SCALE;
    }

    function getRatioScale() internal pure returns (uint256) {

        return RATIO_SCALE;
    }

    function scaleInteger(uint256 x)
        internal
        pure
        returns (uint256)
    {

        return x.mul(FULL_SCALE);
    }


    function mulTruncate(uint256 x, uint256 y)
        internal
        pure
        returns (uint256)
    {

        return mulTruncateScale(x, y, FULL_SCALE);
    }

    function mulTruncateScale(uint256 x, uint256 y, uint256 scale)
        internal
        pure
        returns (uint256)
    {

        uint256 z = x.mul(y);
        return z.div(scale);
    }

    function mulTruncateCeil(uint256 x, uint256 y)
        internal
        pure
        returns (uint256)
    {

        uint256 scaled = x.mul(y);
        uint256 ceil = scaled.add(FULL_SCALE.sub(1));
        return ceil.div(FULL_SCALE);
    }

    function divPrecisely(uint256 x, uint256 y)
        internal
        pure
        returns (uint256)
    {

        uint256 z = x.mul(FULL_SCALE);
        return z.div(y);
    }



    function mulRatioTruncate(uint256 x, uint256 ratio)
        internal
        pure
        returns (uint256 c)
    {

        return mulTruncateScale(x, ratio, RATIO_SCALE);
    }

    function mulRatioTruncateCeil(uint256 x, uint256 ratio)
        internal
        pure
        returns (uint256)
    {

        uint256 scaled = x.mul(ratio);
        uint256 ceil = scaled.add(RATIO_SCALE.sub(1));
        return ceil.div(RATIO_SCALE);
    }


    function divRatioPrecisely(uint256 x, uint256 ratio)
        internal
        pure
        returns (uint256 c)
    {

        uint256 y = x.mul(RATIO_SCALE);
        return y.div(ratio);
    }


    function min(uint256 x, uint256 y)
        internal
        pure
        returns (uint256)
    {

        return x > y ? y : x;
    }

    function max(uint256 x, uint256 y)
        internal
        pure
        returns (uint256)
    {

        return x > y ? x : y;
    }

    function clamp(uint256 x, uint256 upperBound)
        internal
        pure
        returns (uint256)
    {

        return x > upperBound ? upperBound : x;
    }
}

library Root {


    using SafeMath for uint256;

    function sqrt(uint x) internal pure returns (uint y) {

        uint z = (x.add(1)).div(2);
        y = x;
        while (z < y) {
            y = z;
            z = (x.div(z).add(z)).div(2);
        }
    }
}

contract IncentivisedVotingLockup is
    IIncentivisedVotingLockup,
    ReentrancyGuard,
    RewardsDistributionRecipient
{

    using StableMath for uint256;
    using SafeMath for uint256;
    using SignedSafeMath128 for int128;
    using SafeERC20 for IERC20;

    event Deposit(address indexed provider, uint256 value, uint256 locktime, LockAction indexed action, uint256 ts);
    event Withdraw(address indexed provider, uint256 value, uint256 ts);
    event Ejected(address indexed ejected, address ejector, uint256 ts);
    event Expired();
    event RewardAdded(uint256 reward);
    event RewardPaid(address indexed user, uint256 reward);

    IERC20 public stakingToken;
    uint256 private constant WEEK = 7 days;
    uint256 public constant MAXTIME = 365 days;
    uint256 public END;
    bool public expired = false;

    uint256 public globalEpoch;
    Point[] public pointHistory;
    mapping(address => Point[]) public userPointHistory;
    mapping(address => uint256) public userPointEpoch;
    mapping(uint256 => int128) public slopeChanges;
    mapping(address => LockedBalance) public locked;

    string public name;
    string public symbol;
    uint256 public decimals = 18;

    uint256 public periodFinish = 0;
    uint256 public rewardRate = 0;

    uint256 public totalStaticWeight = 0;
    uint256 public lastUpdateTime = 0;
    uint256 public rewardPerTokenStored = 0;

    mapping(address => uint256) public userRewardPerTokenPaid;
    mapping(address => uint256) public rewards;
    mapping(address => uint256) public rewardsPaid;

    struct Point {
        int128 bias;
        int128 slope;
        uint256 ts;
        uint256 blk;
    }

    struct LockedBalance {
        int128 amount;
        uint256 end;
    }

    enum LockAction {
        CREATE_LOCK,
        INCREASE_LOCK_AMOUNT,
        INCREASE_LOCK_TIME
    }

    constructor(
        address _stakingToken,
        string memory _name,
        string memory _symbol,
        address _nexus,
        address _rewardsDistributor
    )
        public
        RewardsDistributionRecipient(_nexus, _rewardsDistributor)
    {
        stakingToken = IERC20(_stakingToken);
        Point memory init = Point({ bias: int128(0), slope: int128(0), ts: block.timestamp, blk: block.number});
        pointHistory.push(init);

        decimals = IBasicToken(_stakingToken).decimals();
        require(decimals <= 18, "Cannot have more than 18 decimals");

        name = _name;
        symbol = _symbol;

        END = block.timestamp.add(MAXTIME);
    }

    modifier contractNotExpired(){

        require(!expired, "Contract is expired");
        _;
    }

    modifier lockupIsOver(address _addr) {

        LockedBalance memory userLock = locked[_addr];
        require(userLock.amount > 0 && block.timestamp >= userLock.end, "Users lock didn't expire");
        require(staticBalanceOf(_addr) > 0, "User must have existing bias");
        _;
    }


    function getLastUserPoint(address _addr)
        external
        view
        returns(
            int128 bias,
            int128 slope,
            uint256 ts
        )
    {

        uint256 uepoch = userPointEpoch[_addr];
        if(uepoch == 0){
            return (0, 0, 0);
        }
        Point memory point = userPointHistory[_addr][uepoch];
        return (point.bias, point.slope, point.ts);
    }


    function _checkpoint(
        address _addr,
        LockedBalance memory _oldLocked,
        LockedBalance memory _newLocked
    )
        internal
    {

        Point memory userOldPoint;
        Point memory userNewPoint;
        int128 oldSlopeDelta = 0;
        int128 newSlopeDelta = 0;
        uint256 epoch = globalEpoch;

        if(_addr != address(0)){
            if(_oldLocked.end > block.timestamp && _oldLocked.amount > 0){
                userOldPoint.slope = _oldLocked.amount.div(int128(MAXTIME));
                userOldPoint.bias = userOldPoint.slope.mul(int128(_oldLocked.end.sub(block.timestamp)));
            }
            if(_newLocked.end > block.timestamp && _newLocked.amount > 0){
                userNewPoint.slope = _newLocked.amount.div(int128(MAXTIME));
                userNewPoint.bias = userNewPoint.slope.mul(int128(_newLocked.end.sub(block.timestamp)));
            }

            uint256 uEpoch = userPointEpoch[_addr];
            if(uEpoch == 0){
                userPointHistory[_addr].push(userOldPoint);
            }
            uint256 newStatic = _staticBalance(userNewPoint.slope, block.timestamp, _newLocked.end);
            uint256 additiveStaticWeight = totalStaticWeight.add(newStatic);
            if(uEpoch > 0){
                uint256 oldStatic = _staticBalance(userPointHistory[_addr][uEpoch].slope, userPointHistory[_addr][uEpoch].ts, _oldLocked.end);
                additiveStaticWeight = additiveStaticWeight.sub(oldStatic);
            }
            totalStaticWeight = additiveStaticWeight;

            userPointEpoch[_addr] = uEpoch.add(1);
            userNewPoint.ts = block.timestamp;
            userNewPoint.blk = block.number;
            userPointHistory[_addr].push(userNewPoint);


            oldSlopeDelta = slopeChanges[_oldLocked.end];
            if(_newLocked.end != 0){
                if (_newLocked.end == _oldLocked.end) {
                    newSlopeDelta = oldSlopeDelta;
                } else {
                    newSlopeDelta = slopeChanges[_newLocked.end];
                }
            }
        }

        Point memory lastPoint = Point({bias: 0, slope: 0, ts: block.timestamp, blk: block.number});
        if(epoch > 0){
            lastPoint = pointHistory[epoch];
        }
        uint256 lastCheckpoint = lastPoint.ts;

        Point memory initialLastPoint = Point({bias: 0, slope: 0, ts: lastPoint.ts, blk: lastPoint.blk});
        uint256 blockSlope = 0; // dblock/dt
        if(block.timestamp > lastPoint.ts){
            blockSlope = StableMath.scaleInteger(block.number.sub(lastPoint.blk)).div(block.timestamp.sub(lastPoint.ts));
        }

        uint256 iterativeTime = _floorToWeek(lastCheckpoint);
        for (uint256 i = 0; i < 255; i++){
            iterativeTime = iterativeTime.add(WEEK);
            int128 dSlope = 0;
            if(iterativeTime > block.timestamp){
                iterativeTime = block.timestamp;
            } else {
                dSlope = slopeChanges[iterativeTime];
            }
            int128 biasDelta = lastPoint.slope.mul(int128(iterativeTime.sub(lastCheckpoint)));
            lastPoint.bias = lastPoint.bias.sub(biasDelta);
            lastPoint.slope = lastPoint.slope.add(dSlope);
            if(lastPoint.bias < 0){
                lastPoint.bias = 0;
            }
            if(lastPoint.slope < 0){
                lastPoint.slope = 0;
            }
            lastCheckpoint = iterativeTime;
            lastPoint.ts = iterativeTime;
            lastPoint.blk = initialLastPoint.blk.add(blockSlope.mulTruncate(iterativeTime.sub(initialLastPoint.ts)));

            epoch = epoch.add(1);
            if(iterativeTime == block.timestamp) {
                lastPoint.blk = block.number;
                break;
            } else {
                pointHistory.push(lastPoint);
            }
        }

        globalEpoch = epoch;

        if(_addr != address(0)){
            lastPoint.slope = lastPoint.slope.add(userNewPoint.slope.sub(userOldPoint.slope));
            lastPoint.bias = lastPoint.bias.add(userNewPoint.bias.sub(userOldPoint.bias));
            if(lastPoint.slope < 0) {
                lastPoint.slope = 0;
            }
            if(lastPoint.bias < 0){
                lastPoint.bias = 0;
            }
        }

        pointHistory.push(lastPoint);

        if(_addr != address(0)){
            if(_oldLocked.end > block.timestamp){
                oldSlopeDelta = oldSlopeDelta.add(userOldPoint.slope);
                if(_newLocked.end == _oldLocked.end) {
                    oldSlopeDelta = oldSlopeDelta.sub(userNewPoint.slope);  // It was a new deposit, not extension
                }
                slopeChanges[_oldLocked.end] = oldSlopeDelta;
            }
            if(_newLocked.end > block.timestamp) {
                if(_newLocked.end > _oldLocked.end){
                    newSlopeDelta = newSlopeDelta.sub(userNewPoint.slope);  // old slope disappeared at this point
                    slopeChanges[_newLocked.end] = newSlopeDelta;
                }
            }
        }
    }

    function _depositFor(
        address _addr,
        uint256 _value,
        uint256 _unlockTime,
        LockedBalance memory _oldLocked,
        LockAction _action
    )
        internal
    {

        LockedBalance memory newLocked = LockedBalance({amount: _oldLocked.amount, end: _oldLocked.end});

        newLocked.amount = newLocked.amount.add(int128(_value));
        if(_unlockTime != 0){
            newLocked.end = _unlockTime;
        }
        locked[_addr] = newLocked;

        _checkpoint(_addr, _oldLocked, newLocked);

        if(_value != 0) {
            stakingToken.safeTransferFrom(_addr, address(this), _value);
        }

        emit Deposit(_addr, _value, newLocked.end, _action, block.timestamp);
    }

    function checkpoint() external {

        LockedBalance memory empty;
        _checkpoint(address(0), empty, empty);
    }

    function createLock(uint256 _value, uint256 _unlockTime)
        external
        nonReentrant
        contractNotExpired
        updateReward(msg.sender)
    {

        uint256 unlock_time = _floorToWeek(_unlockTime);  // Locktime is rounded down to weeks
        LockedBalance memory locked_ = LockedBalance({amount: locked[msg.sender].amount, end: locked[msg.sender].end});

        require(_value > 0, "Must stake non zero amount");
        require(locked_.amount == 0, "Withdraw old tokens first");

        require(unlock_time > block.timestamp, "Can only lock until time in the future");
        require(unlock_time <= END, "Voting lock can be 1 year max (until recol)");

        _depositFor(msg.sender, _value, unlock_time, locked_, LockAction.CREATE_LOCK);
    }

    function increaseLockAmount(uint256 _value)
        external
        nonReentrant
        contractNotExpired
        updateReward(msg.sender)
    {

        LockedBalance memory locked_ = LockedBalance({amount: locked[msg.sender].amount, end: locked[msg.sender].end});

        require(_value > 0, "Must stake non zero amount");
        require(locked_.amount > 0, "No existing lock found");
        require(locked_.end > block.timestamp, "Cannot add to expired lock. Withdraw");

        _depositFor(msg.sender, _value, 0, locked_, LockAction.INCREASE_LOCK_AMOUNT);
    }

    function increaseLockLength(uint256 _unlockTime)
        external
        nonReentrant
        contractNotExpired
        updateReward(msg.sender)
    {

        LockedBalance memory locked_ = LockedBalance({amount: locked[msg.sender].amount, end: locked[msg.sender].end});
        uint256 unlock_time = _floorToWeek(_unlockTime);  // Locktime is rounded down to weeks

        require(locked_.amount > 0, "Nothing is locked");
        require(locked_.end > block.timestamp, "Lock expired");
        require(unlock_time > locked_.end, "Can only increase lock WEEK");
        require(unlock_time <= END, "Voting lock can be 1 year max (until recol)");

        _depositFor(msg.sender, 0, unlock_time, locked_, LockAction.INCREASE_LOCK_TIME);
    }

    function withdraw()
        external
    {

        _withdraw(msg.sender);
    }

    function _withdraw(address _addr)
        internal
        nonReentrant
        updateReward(_addr)
    {

        LockedBalance memory oldLock = LockedBalance({ end: locked[_addr].end, amount: locked[_addr].amount });
        require(block.timestamp >= oldLock.end || expired, "The lock didn't expire");
        require(oldLock.amount > 0, "Must have something to withdraw");

        uint256 value = uint256(oldLock.amount);

        LockedBalance memory currentLock = LockedBalance({end: 0, amount: 0});
        locked[_addr] = currentLock;

        if(!expired){
            _checkpoint(_addr, oldLock, currentLock);
        }

        stakingToken.safeTransfer(_addr, value);

        emit Withdraw(_addr, value, block.timestamp);
    }

    function exit()
        external
    {

        _withdraw(msg.sender);
        claimReward();
    }

    function eject(address _addr)
        external
        contractNotExpired
        lockupIsOver(_addr)
    {

        _withdraw(_addr);

        emit Ejected(_addr, tx.origin, block.timestamp);
    }

    function expireContract()
        external
        onlyGovernor
        contractNotExpired
        updateReward(address(0))
    {

        require(block.timestamp > periodFinish, "Period must be over");

        expired = true;

        emit Expired();
    }





    function _floorToWeek(uint256 _t)
        internal
        pure
        returns(uint256)
    {

        return _t.div(WEEK).mul(WEEK);
    }

    function _findBlockEpoch(uint256 _block, uint256 _maxEpoch)
        internal
        view
        returns(uint256)
    {

        uint256 min = 0;
        uint256 max = _maxEpoch;
        for(uint256 i = 0; i < 128; i++){
            if (min >= max)
                break;
            uint256 mid = (min.add(max).add(1)).div(2);
            if (pointHistory[mid].blk <= _block){
                min = mid;
            } else {
                max = mid.sub(1);
            }
        }
        return min;
    }

    function _findUserBlockEpoch(address _addr, uint256 _block)
        internal
        view
        returns(uint256)
    {

        uint256 min = 0;
        uint256 max = userPointEpoch[_addr];
        for(uint256 i = 0; i < 128; i++) {
            if(min >= max){
                break;
            }
            uint256 mid = (min.add(max).add(1)).div(2);
            if(userPointHistory[_addr][mid].blk <= _block){
                min = mid;
            } else {
                max = mid.sub(1);
            }
        }
        return min;
    }

    function balanceOf(address _owner)
        public
        view
        returns (uint256)
    {

        uint256 epoch = userPointEpoch[_owner];
        if(epoch == 0){
            return 0;
        }
        Point memory lastPoint = userPointHistory[_owner][epoch];
        lastPoint.bias = lastPoint.bias.sub(lastPoint.slope.mul(int128(block.timestamp.sub(lastPoint.ts))));
        if(lastPoint.bias < 0) {
            lastPoint.bias = 0;
        }
        return uint256(lastPoint.bias);
    }

    function balanceOfAt(address _owner, uint256 _blockNumber)
        public
        view
        returns (uint256)
    {

        require(_blockNumber <= block.number, "Must pass block number in the past");

        uint256 userEpoch = _findUserBlockEpoch(_owner, _blockNumber);
        if(userEpoch == 0){
            return 0;
        }
        Point memory upoint = userPointHistory[_owner][userEpoch];

        uint256 maxEpoch = globalEpoch;
        uint256 epoch = _findBlockEpoch(_blockNumber, maxEpoch);
        Point memory point0 = pointHistory[epoch];

        uint256 dBlock = 0;
        uint256 dTime = 0;
        if(epoch < maxEpoch){
            Point memory point1 = pointHistory[epoch.add(1)];
            dBlock = point1.blk.sub(point0.blk);
            dTime = point1.ts.sub(point0.ts);
        } else {
            dBlock = block.number.sub(point0.blk);
            dTime = block.timestamp.sub(point0.ts);
        }
        uint256 blockTime = point0.ts;
        if(dBlock != 0) {
            blockTime = blockTime.add(dTime.mul(_blockNumber.sub(point0.blk)).div(dBlock));
        }
        upoint.bias = upoint.bias.sub(upoint.slope.mul(int128(blockTime.sub(upoint.ts))));
        if(upoint.bias >= 0){
            return uint256(upoint.bias);
        } else {
            return 0;
        }
    }

    function _supplyAt(Point memory _point, uint256 _t)
        internal
        view
        returns (uint256)
    {

        Point memory lastPoint = _point;
        uint256 iterativeTime = _floorToWeek(lastPoint.ts);
        for(uint256 i = 0; i < 255; i++){
            iterativeTime = iterativeTime.add(WEEK);
            int128 dSlope = 0;
            if(iterativeTime > _t){
                iterativeTime = _t;
            }
            else {
                dSlope = slopeChanges[iterativeTime];
            }

            lastPoint.bias = lastPoint.bias.sub(lastPoint.slope.mul(int128(iterativeTime.sub(lastPoint.ts))));
            if(iterativeTime == _t){
                break;
            }
            lastPoint.slope = lastPoint.slope.add(dSlope);
            lastPoint.ts = iterativeTime;
        }

        if (lastPoint.bias < 0){
            lastPoint.bias = 0;
        }
        return uint256(lastPoint.bias);
    }

    function totalSupply()
        public
        view
        returns (uint256)
    {

        uint256 epoch_ = globalEpoch;
        Point memory lastPoint = pointHistory[epoch_];
        return _supplyAt(lastPoint, block.timestamp);
    }

    function totalSupplyAt(uint256 _blockNumber)
        public
        view
        returns (uint256)
    {

        require(_blockNumber <= block.number, "Must pass block number in the past");

        uint256 epoch = globalEpoch;
        uint256 targetEpoch = _findBlockEpoch(_blockNumber, epoch);

        Point memory point = pointHistory[targetEpoch];

        if(point.blk > _blockNumber){
            return 0;
        }

        uint256 dTime = 0;
        if(targetEpoch < epoch){
            Point memory pointNext = pointHistory[targetEpoch.add(1)];
            if(point.blk != pointNext.blk) {
                dTime = (_blockNumber.sub(point.blk)).mul(pointNext.ts.sub(point.ts)).div(pointNext.blk.sub(point.blk));
            }
        } else if (point.blk != block.number){
            dTime = (_blockNumber.sub(point.blk)).mul(block.timestamp.sub(point.ts)).div(block.number.sub(point.blk));
        }

        return _supplyAt(point, point.ts.add(dTime));
    }



    modifier updateReward(address _account) {

        uint256 newRewardPerToken = rewardPerToken();
        if(newRewardPerToken > 0) {
            rewardPerTokenStored = newRewardPerToken;
            lastUpdateTime = lastTimeRewardApplicable();
            if (_account != address(0)) {
                rewards[_account] = earned(_account);
                userRewardPerTokenPaid[_account] = newRewardPerToken;
            }
        }
        _;
    }

    function claimReward()
        public
        updateReward(msg.sender)
    {

        uint256 reward = rewards[msg.sender];
        if (reward > 0) {
            rewards[msg.sender] = 0;
            stakingToken.safeTransfer(msg.sender, reward);
            rewardsPaid[msg.sender] = rewardsPaid[msg.sender].add(reward);
            emit RewardPaid(msg.sender, reward);
        }
    }



    function staticBalanceOf(address _addr)
        public
        view
        returns (uint256)
    {

        uint256 uepoch = userPointEpoch[_addr];
        if(uepoch == 0 || userPointHistory[_addr][uepoch].bias == 0){
            return 0;
        }
        return _staticBalance(userPointHistory[_addr][uepoch].slope, userPointHistory[_addr][uepoch].ts, locked[_addr].end);
    }

    function _staticBalance(int128 _slope, uint256 _startTime, uint256 _endTime)
        internal
        pure
        returns (uint256)
    {

        if(_startTime > _endTime) return 0;
        uint256 lockupLength = _endTime.sub(_startTime);
        uint256 s = uint256(_slope.mul(10000)).mul(Root.sqrt(lockupLength));
        return s;
    }

    function getRewardToken()
        external
        view
        returns (IERC20)
    {

        return stakingToken;
    }

    function getDuration()
        external
        pure
        returns (uint256)
    {

        return WEEK;
    }

    function lastTimeRewardApplicable()
        public
        view
        returns (uint256)
    {

        return StableMath.min(block.timestamp, periodFinish);
    }

    function rewardPerToken()
        public
        view
        returns (uint256)
    {

        uint256 totalStatic = totalStaticWeight;
        if (totalStatic == 0) {
            return rewardPerTokenStored;
        }
        uint256 rewardUnitsToDistribute = rewardRate.mul(lastTimeRewardApplicable().sub(lastUpdateTime));
        uint256 unitsToDistributePerToken = rewardUnitsToDistribute.divPrecisely(totalStatic);
        return rewardPerTokenStored.add(unitsToDistributePerToken);
    }

    function earned(address _addr)
        public
        view
        returns (uint256)
    {

        uint256 userRewardDelta = rewardPerToken().sub(userRewardPerTokenPaid[_addr]);
        uint256 userNewReward = staticBalanceOf(_addr).mulTruncate(userRewardDelta);
        return rewards[_addr].add(userNewReward);
    }



    function notifyRewardAmount(uint256 _reward)
        external
        onlyRewardsDistributor
        contractNotExpired
        updateReward(address(0))
    {

        uint256 currentTime = block.timestamp;
        if (currentTime >= periodFinish) {
            rewardRate = _reward.div(WEEK);
        }
        else {
            uint256 remaining = periodFinish.sub(currentTime);
            uint256 leftover = remaining.mul(rewardRate);
            rewardRate = _reward.add(leftover).div(WEEK);
        }

        lastUpdateTime = currentTime;
        periodFinish = currentTime.add(WEEK);

        emit RewardAdded(_reward);
    }
}