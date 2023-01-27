
pragma solidity >0.4.13 >=0.4.23 >=0.5.12 >=0.5.0 <0.6.0 >=0.5.10 <0.6.0 >=0.5.12 <0.6.0;


interface IERC20 {

    function decimals() external view returns (uint8);


    function totalSupply() external view returns (uint256);


    function balanceOf(address account) external view returns (uint256);


    function transfer(address recipient, uint256 amount) external returns (bool);


    function mint(address account, uint256 amount) external;


    function allowance(address owner, address spender) external view returns (uint256);


    function approve(address spender, uint256 amount) external returns (bool);


    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);


    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}



contract ReentrancyGuard {


    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor() internal {
        _status = _NOT_ENTERED;
    }

    modifier nonReentrant() {

        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        _status = _ENTERED;

        _;

        _status = _NOT_ENTERED;
    }
}



interface IAdapter {

    function calc(
        address gem,
        uint256 acc,
        uint256 factor
    ) external view returns (uint256);

}

interface IGemForRewardChecker {

    function check(address gem) external view returns (bool);

}





contract LibNote {

    event LogNote(
        bytes4 indexed sig,
        address indexed usr,
        bytes32 indexed arg1,
        bytes32 indexed arg2,
        bytes data
    ) anonymous;

    modifier note {

        _;
        assembly {
            let mark := msize() // end of memory ensures zero
            mstore(0x40, add(mark, 288)) // update free memory pointer
            mstore(mark, 0x20) // bytes type data offset
            mstore(add(mark, 0x20), 224) // bytes size (padded)
            calldatacopy(add(mark, 0x40), 0, 224) // bytes payload
            log4(
                mark,
                288, // calldata
                shl(224, shr(224, calldataload(0))), // msg.sig
                caller(), // msg.sender
                calldataload(4), // arg1
                calldataload(36) // arg2
            )
        }
    }
}

contract Auth is LibNote {

    mapping(address => uint256) public wards;
    address public deployer;

    function rely(address usr) external note auth {

        wards[usr] = 1;
    }

    function deny(address usr) external note auth {

        wards[usr] = 0;
    }

    modifier auth {

        require(wards[msg.sender] == 1 || deployer == msg.sender, "Auth/not-authorized");
        _;
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

    function min(uint x, uint y) internal pure returns (uint z) {

        return x <= y ? x : y;
    }
}





library Address {

    function isContract(address account) internal view returns (bool) {


        bytes32 codehash;
        bytes32 accountHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;
        assembly { codehash := extcodehash(account) }
        return (codehash != 0x0 && codehash != accountHash);
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








library Math {

    function max(uint256 a, uint256 b) internal pure returns (uint256) {

        return a >= b ? a : b;
    }

    function min(uint256 a, uint256 b) internal pure returns (uint256) {

        return a < b ? a : b;
    }

    function average(uint256 a, uint256 b) internal pure returns (uint256) {

        return (a / 2) + (b / 2) + (((a % 2) + (b % 2)) / 2);
    }
}


contract Context {

    constructor() internal {}


    function _msgSender() internal view returns (address payable) {

        return msg.sender;
    }

    function _msgData() internal view returns (bytes memory) {

        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}


contract Ownable is Context {

    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor() internal {
        _owner = _msgSender();
        emit OwnershipTransferred(address(0), _owner);
    }

    function owner() public view returns (address) {

        return _owner;
    }

    modifier onlyOwner() {

        require(isOwner(), "Ownable: caller is not the owner");
        _;
    }

    function isOwner() public view returns (bool) {

        return _msgSender() == _owner;
    }

    function renounceOwnership() public onlyOwner {

        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    function transferOwnership(address newOwner) public onlyOwner {

        _transferOwnership(newOwner);
    }

    function _transferOwnership(address newOwner) internal {

        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

contract Initializable {

    bool private initialized;

    bool private initializing;

    modifier initializer() {

        require(
            initializing || isConstructor() || !initialized,
            "Contract instance has already been initialized"
        );

        bool wasInitializing = initializing;
        initializing = true;
        initialized = true;

        _;

        initializing = wasInitializing;
    }

    function isConstructor() private view returns (bool) {

        uint256 cs;
        assembly {
            cs := extcodesize(address)
        }
        return cs == 0;
    }

    uint256[50] private ______gap;
}

contract LPTokenWrapper is Initializable {

    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    struct PairDesc {
        address gem;
        address adapter;
        address staker;
        uint256 factor;
        bytes32 name;
    }

    mapping(address => PairDesc) public pairDescs;

    address[] private registeredGems;

    uint256 public decimals = 18;

    uint256 public prec = 1e18;

    mapping(address => uint256) private _totalSupply;

    mapping(address => mapping(address => uint256)) private _amounts;
    mapping(address => mapping(address => uint256)) private _balances;

    IGemForRewardChecker public gemForRewardChecker;

    function checkGem(address gem) internal view returns (bool) {

        return gemForRewardChecker.check(gem);
    }

    function registerGem(address gem) internal {

        for (uint256 i = 0; i < registeredGems.length; i++) {
            if (registeredGems[i] == gem) {
                return;
            }
        }
        registeredGems.push(gem);
    }

    function totalSupply() public view returns (uint256) {

        uint256 res = 0;
        for (uint256 i = 0; i < registeredGems.length; i++) {
            res = res.add(_totalSupply[registeredGems[i]]);
        }
        return res.div(prec);
    }

    function balanceOf(address account) public view returns (uint256) {

        uint256 res = 0;
        for (uint256 i = 0; i < registeredGems.length; i++) {
            res = res.add(_balances[registeredGems[i]][account]);
        }
        return res.div(prec);
    }

    function calcCheckValue(uint256 amount, address gem) public view returns (uint256) {

        require(amount > 0);
        PairDesc storage desc = pairDescs[gem];
        require(desc.adapter != address(0x0));
        assert(desc.gem == gem);
        uint256 r = IAdapter(desc.adapter).calc(gem, amount, desc.factor);
        require(r > 0);
        return r;
    }

    function stakeLp(
        uint256 amount,
        address gem,
        address usr
    ) internal {

        uint256 value = calcCheckValue(amount, gem).mul(prec);

        _balances[gem][usr] = _balances[gem][usr].add(value);
        _amounts[gem][usr] = _amounts[gem][usr].add(amount);
        _totalSupply[gem] = _totalSupply[gem].add(value);
    }

    function withdrawLp(
        uint256 amount,
        address gem,
        address usr
    ) internal {

        uint256 value = amount.mul(_balances[gem][usr]).div(_amounts[gem][usr]);

        _balances[gem][usr] = _balances[gem][usr].sub(value);
        _amounts[gem][usr] = _amounts[gem][usr].sub(amount);
        _totalSupply[gem] = _totalSupply[gem].sub(value);
    }
}



interface IRewarder {

    function stake(
        address account,
        uint256 amount,
        address gem
    ) external;


    function withdraw(
        address account,
        uint256 amount,
        address gem
    ) external;

}

contract StakingRewardsDecayHolder {

    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    IRewarder public rewarder;

    uint256 public withdrawErrorCount;

    mapping(address => mapping(address => uint256)) public amounts;

    event withdrawError(uint256 amount, address gem);

    constructor(address _rewarder) public {
        rewarder = IRewarder(_rewarder);
    }

    function stake(uint256 amount, address gem) public {

        require(amount > 0, "Cannot stake 0");

        rewarder.stake(msg.sender, amount, gem);

        amounts[gem][msg.sender] = amounts[gem][msg.sender].add(amount);
        IERC20(gem).safeTransferFrom(msg.sender, address(this), amount);
    }

    function withdraw(uint256 amount, address gem) public {

        require(amount > 0, "Cannot withdraw 0");

        (bool success, ) =
            address(rewarder).call(
                abi.encodeWithSelector(rewarder.withdraw.selector, msg.sender, amount, gem)
            );
        if (!success) {
            emit withdrawError(amount, gem);
            withdrawErrorCount++;
        }

        amounts[gem][msg.sender] = amounts[gem][msg.sender].sub(amount);
        IERC20(gem).safeTransfer(msg.sender, amount);
    }
}




contract StakingRewardsDecay is LPTokenWrapper, Auth, ReentrancyGuard {

    address public gov;
    address public aggregator;
    uint256 public totalRewards = 0;

    struct EpochData {
        mapping(address => uint256) userRewardPerTokenPaid;
        mapping(address => uint256) rewards;
        uint256 initreward;
        uint256 duration;
        uint256 starttime;
        uint256 periodFinish;
        uint256 rewardRate;
        uint256 lastUpdateTime;
        uint256 rewardPerTokenStored;
        uint256 lastTotalSupply;
        bool closed;
    }

    uint256 public EPOCHCOUNT = 0;
    uint256 public epochInited = 0;
    EpochData[] public epochs;

    mapping(bytes32 => address) public pairNameToGem;

    mapping(address => uint256) public lastClaimedEpoch;
    mapping(address => uint256) public yetNotClaimedOldEpochRewards;
    uint256 public currentEpoch;

    StakingRewardsDecayHolder public holder;

    event RewardAdded(uint256 reward, uint256 epoch, uint256 duration, uint256 starttime);
    event StopRewarding();
    event Staked(address indexed user, address indexed gem, uint256 amount);
    event Withdrawn(address indexed user, address indexed gem, uint256 amount);
    event RewardTakeStock(address indexed user, uint256 reward, uint256 epoch);
    event RewardPaid(address indexed user, uint256 reward);

    constructor() public {
        deployer = msg.sender;
    }

    function initialize(address _gov, uint256 epochCount) public initializer {

        require(deployer == msg.sender);

        gov = _gov;
        require(gov != address(0));
        require(epochCount > 0);

        EPOCHCOUNT = epochCount;
        EpochData memory data;
        for (uint256 i = 0; i < epochCount; i++) {
            epochs.push(data);
        }

        holder = new StakingRewardsDecayHolder(address(this));
    }

    function setupAggregator(address _aggregator) public {

        require(deployer == msg.sender);
        require(_aggregator != address(0));
        require(aggregator == address(0)); //only one set allowed

        aggregator = _aggregator;
    }

    function getStartTime() public view returns (uint256) {

        return epochs[0].starttime;
    }

    modifier checkStart() {

        require(block.timestamp >= getStartTime(), "not start");
        require(epochInited == EPOCHCOUNT, "not all epochs was inited");
        _;
    }

    function initRewardAmount(
        uint256 reward,
        uint256 starttime,
        uint256 duration,
        uint256 idx
    ) public {

        require(deployer == msg.sender);
        require(epochInited == 0, "not allowed after approve");
        initEpoch(reward, starttime, duration, idx);
    }

    function setupGemForRewardChecker(address a) public {

        require(deployer == msg.sender);
        gemForRewardChecker = IGemForRewardChecker(a);
    }

    function initEpoch(
        uint256 reward,
        uint256 starttime,
        uint256 duration,
        uint256 idx
    ) internal {

        require(idx < EPOCHCOUNT, "idx < EPOCHCOUNT");
        require(duration > 0, "duration > 0");
        require(starttime >= block.timestamp, "starttime > block.timestamp");

        EpochData storage epoch = epochs[idx];

        epoch.rewardPerTokenStored = 0;
        epoch.starttime = starttime;
        epoch.duration = duration;
        epoch.rewardRate = reward.div(duration);
        require(epoch.rewardRate > 0, "zero rewardRate");

        epoch.initreward = reward;
        epoch.lastUpdateTime = starttime;
        epoch.periodFinish = starttime.add(duration);

        emit RewardAdded(reward, idx, duration, starttime);
    }

    function initAllEpochs(
        uint256[] memory rewards,
        uint256 starttime,
        uint256 duration
    ) public {

        require(deployer == msg.sender);
        require(epochInited == 0, "not allowed after approve");

        require(duration > 0);
        require(starttime > 0);

        assert(rewards.length == EPOCHCOUNT);

        uint256 time = starttime;

        for (uint256 i = 0; i < EPOCHCOUNT; i++) {
            initEpoch(rewards[i], time, duration, i);
            time = time.add(duration);
        }
    }

    function getEpochRewardRate(uint256 epochIdx) public view returns (uint256) {

        return epochs[epochIdx].rewardRate;
    }

    function getEpochStartTime(uint256 epochIdx) public view returns (uint256) {

        return epochs[epochIdx].starttime;
    }

    function getEpochFinishTime(uint256 epochIdx) public view returns (uint256) {

        return epochs[epochIdx].periodFinish;
    }

    function getTotalRewards() public view returns (uint256 result) {

        require(epochInited == EPOCHCOUNT, "not inited");

        result = 0;

        for (uint256 i = 0; i < EPOCHCOUNT; i++) {
            result = result.add(epochs[i].initreward);
        }
    }

    function getTotalRewardTime() public view returns (uint256 result) {

        require(epochInited == EPOCHCOUNT, "not inited");

        result = 0;

        for (uint256 i = 0; i < EPOCHCOUNT; i++) {
            result = result.add(epochs[i].duration);
        }
    }

    function approveEpochsConsistency() public {

        require(deployer == msg.sender);
        require(epochInited == 0, "double call not allowed");

        uint256 totalReward = epochs[0].initreward;
        require(getStartTime() > 0);

        for (uint256 i = 1; i < EPOCHCOUNT; i++) {
            EpochData storage epoch = epochs[i];
            require(epoch.starttime > 0);
            require(epoch.starttime == epochs[i - 1].periodFinish);
            totalReward = totalReward.add(epoch.initreward);
        }

        require(IERC20(gov).balanceOf(address(this)) >= totalReward, "GOV balance not enought");

        epochInited = EPOCHCOUNT;
    }

    function resetDeployer() public {

        require(deployer == msg.sender);
        require(epochInited == EPOCHCOUNT);
        deployer = address(0);
    }

    function calcCurrentEpoch() public view returns (uint256 res) {

        res = 0;
        for (
            uint256 i = currentEpoch;
            i < EPOCHCOUNT && epochs[i].starttime <= block.timestamp;
            i++
        ) {
            res = i;
        }
    }

    modifier updateCurrentEpoch() {

        currentEpoch = calcCurrentEpoch();

        uint256 supply = totalSupply();
        epochs[currentEpoch].lastTotalSupply = supply;

        for (int256 i = int256(currentEpoch) - 1; i >= 0; i--) {
            EpochData storage epoch = epochs[uint256(i)];
            if (epoch.closed) {
                break;
            }

            epoch.lastTotalSupply = supply;
            epoch.closed = true;
        }

        _;
    }

    function registerPairDesc(
        address gem,
        address adapter,
        uint256 factor,
        bytes32 name
    ) public auth nonReentrant {

        require(gem != address(0x0), "gem is null");
        require(adapter != address(0x0), "adapter is null");

        require(checkGem(gem), "bad gem");

        require(pairNameToGem[name] == address(0) || pairNameToGem[name] == gem, "duplicate name");

        if (pairDescs[gem].name != "") {
            delete pairNameToGem[pairDescs[gem].name];
        }

        registerGem(gem);

        pairDescs[gem] = PairDesc({
            gem: gem,
            adapter: adapter,
            factor: factor,
            staker: address(0),
            name: name
        });

        pairNameToGem[name] = gem;
    }

    function getPairInfo(bytes32 name, address account)
        public
        view
        returns (
            address gem,
            uint256 avail,
            uint256 locked,
            uint256 lockedValue,
            uint256 availValue
        )
    {

        gem = pairNameToGem[name];
        if (gem == address(0)) {
            return (address(0), 0, 0, 0, 0);
        }

        PairDesc storage desc = pairDescs[gem];
        locked = holder.amounts(gem, account);
        lockedValue = IAdapter(desc.adapter).calc(gem, locked, desc.factor);
        avail = IERC20(gem).balanceOf(account);
        availValue = IAdapter(desc.adapter).calc(gem, avail, desc.factor);
    }

    function getPrice(bytes32 name) public view returns (uint256) {

        address gem = pairNameToGem[name];
        if (gem == address(0)) {
            return 0;
        }

        PairDesc storage desc = pairDescs[gem];
        return IAdapter(desc.adapter).calc(gem, 1, desc.factor);
    }

    function getRewardPerHour() public view returns (uint256) {

        EpochData storage epoch = epochs[calcCurrentEpoch()];
        return epoch.rewardRate * 3600;
    }

    function lastTimeRewardApplicable(EpochData storage epoch) internal view returns (uint256) {

        assert(block.timestamp >= epoch.starttime);
        return Math.min(block.timestamp, epoch.periodFinish);
    }

    function rewardPerToken(EpochData storage epoch, uint256 lastTotalSupply)
        internal
        view
        returns (uint256)
    {

        if (lastTotalSupply == 0) {
            return epoch.rewardPerTokenStored;
        }
        return
            epoch.rewardPerTokenStored.add(
                lastTimeRewardApplicable(epoch)
                    .sub(epoch.lastUpdateTime)
                    .mul(epoch.rewardRate)
                    .mul(1e18 * (10**decimals))
                    .div(lastTotalSupply)
            );
    }

    function earnedEpoch(
        address account,
        EpochData storage epoch,
        uint256 lastTotalSupply
    ) internal view returns (uint256) {

        return
            balanceOf(account)
                .mul(
                rewardPerToken(epoch, lastTotalSupply).sub(epoch.userRewardPerTokenPaid[account])
            )
                .div(1e18 * (10**decimals))
                .add(epoch.rewards[account]);
    }

    function earned(address account) public view returns (uint256 acc) {

        uint256 currentSupply = totalSupply();
        int256 lastClaimedEpochIdx = int256(lastClaimedEpoch[account]);

        for (int256 i = int256(calcCurrentEpoch()); i >= lastClaimedEpochIdx; i--) {
            EpochData storage epoch = epochs[uint256(i)];

            uint256 epochTotalSupply = currentSupply;
            if (epoch.closed) {
                epochTotalSupply = epoch.lastTotalSupply;
            }
            acc = acc.add(earnedEpoch(account, epoch, epochTotalSupply));
        }

        acc = acc.add(yetNotClaimedOldEpochRewards[account]);
    }

    function getRewardEpoch(address account, EpochData storage epoch) internal returns (uint256) {

        uint256 reward = earnedEpoch(account, epoch, epoch.lastTotalSupply);
        if (reward > 0) {
            epoch.rewards[account] = 0;
            return reward;
        }
        return 0;
    }

    function takeStockReward(address account) internal returns (uint256 acc) {

        for (uint256 i = lastClaimedEpoch[account]; i <= currentEpoch; i++) {
            uint256 reward = getRewardEpoch(account, epochs[i]);
            acc = acc.add(reward);
            emit RewardTakeStock(account, reward, i);
        }
        lastClaimedEpoch[account] = currentEpoch;
    }

    function gatherOldEpochReward(address account) internal {

        if (currentEpoch == 0) {
            return;
        }

        uint256 acc = takeStockReward(account);
        yetNotClaimedOldEpochRewards[account] = yetNotClaimedOldEpochRewards[account].add(acc);
    }

    function stakeEpoch(
        uint256 amount,
        address gem,
        address usr,
        EpochData storage epoch
    ) internal updateReward(usr, epoch) {

        gatherOldEpochReward(usr);
        stakeLp(amount, gem, usr);
        emit Staked(usr, gem, amount);
    }

    function stake(
        address account,
        uint256 amount,
        address gem
    ) public nonReentrant checkStart updateCurrentEpoch {

        require(address(holder) == msg.sender);
        assert(amount > 0);
        stakeEpoch(amount, gem, account, epochs[currentEpoch]);
    }

    function withdrawEpoch(
        uint256 amount,
        address gem,
        address usr,
        EpochData storage epoch
    ) internal updateReward(usr, epoch) {

        gatherOldEpochReward(usr);
        withdrawLp(amount, gem, usr);
        emit Withdrawn(usr, gem, amount);
    }

    function withdraw(
        address account,
        uint256 amount,
        address gem
    ) public nonReentrant checkStart updateCurrentEpoch {

        require(address(holder) == msg.sender);
        assert(amount > 0);
        withdrawEpoch(amount, gem, account, epochs[currentEpoch]);
    }

    function getRewardCore(address account)
        internal
        checkStart
        updateCurrentEpoch
        updateReward(account, epochs[currentEpoch])
        returns (uint256 acc)
    {

        acc = takeStockReward(account);

        acc = acc.add(yetNotClaimedOldEpochRewards[account]);
        yetNotClaimedOldEpochRewards[account] = 0;

        if (acc > 0) {
            totalRewards = totalRewards.add(acc);
            IERC20(gov).safeTransfer(account, acc);
            emit RewardPaid(account, acc);
        }
    }

    function getReward() public nonReentrant returns (uint256) {

        return getRewardCore(msg.sender);
    }

    function getRewardEx(address account) public nonReentrant returns (uint256) {

        require(aggregator == msg.sender);
        return getRewardCore(account);
    }

    modifier updateReward(address account, EpochData storage epoch) {

        assert(account != address(0));

        epoch.rewardPerTokenStored = rewardPerToken(epoch, epoch.lastTotalSupply);
        epoch.lastUpdateTime = lastTimeRewardApplicable(epoch);
        epoch.rewards[account] = earnedEpoch(account, epoch, epoch.lastTotalSupply);
        epoch.userRewardPerTokenPaid[account] = epoch.rewardPerTokenStored;
        _;
    }
}

contract RewardDecayAggregator {

    using SafeMath for uint256;

    StakingRewardsDecay[2] public rewarders;

    constructor(address rewarder0, address rewarder1) public {
        rewarders[0] = StakingRewardsDecay(rewarder0);
        rewarders[1] = StakingRewardsDecay(rewarder1);
    }

    function claimReward() public {

        for (uint256 i = 0; i < rewarders.length; i++) {
            rewarders[i].getRewardEx(msg.sender);
        }
    }

    function earned() public view returns (uint256 res) {

        for (uint256 i = 0; i < rewarders.length; i++) {
            res = res.add(rewarders[i].earned(msg.sender));
        }
    }
}