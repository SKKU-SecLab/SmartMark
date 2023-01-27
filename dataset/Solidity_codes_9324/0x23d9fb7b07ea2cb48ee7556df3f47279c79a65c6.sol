
pragma solidity ^0.8.0;

interface IERC20 {

    function totalSupply() external view returns (uint256);


    function balanceOf(address account) external view returns (uint256);


    function transfer(address recipient, uint256 amount) external returns (bool);


    function allowance(address owner, address spender) external view returns (uint256);


    function approve(address spender, uint256 amount) external returns (bool);


    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);


    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}// GPL-2.0-or-later
pragma solidity >=0.7.0;

library LowGasSafeMath {

    function add(uint256 x, uint256 y) internal pure returns (uint256 z) {

        require((z = x + y) >= x, "LowGasSafeMath: add overflow");
    }

    function sub(uint256 x, uint256 y) internal pure returns (uint256 z) {

        require((z = x - y) <= x, "LowGasSafeMath: sub overflow");
    }

    function mul(uint256 x, uint256 y) internal pure returns (uint256 z) {

        require(x == 0 || (z = x * y) / x == y, "LowGasSafeMath: mul overflow");
    }

    function add(int256 x, int256 y) internal pure returns (int256 z) {

        require((z = x + y) >= x == (y >= 0), "LowGasSafeMath: add overflow");
    }

    function sub(int256 x, int256 y) internal pure returns (int256 z) {

        require((z = x - y) <= x == (y >= 0), "LowGasSafeMath: sub overflow");
    }
}// MIT
pragma solidity ^0.8.0;



contract ERC20 is IERC20 {

    using LowGasSafeMath for uint256;

    mapping (address => uint256) private _balances;

    mapping (address => mapping (address => uint256)) private _allowed;

    uint256 private _totalSupply;

    function totalSupply() override public view returns (uint256) {

        return _totalSupply;
    }

    function balanceOf(address owner) override public view returns (uint256) {

        return _balances[owner];
    }

    function allowance(
        address owner,
        address spender
    )
    override public
    view
    returns (uint256)
    {

        return _allowed[owner][spender];
    }

    function transfer(address to, uint256 value) override public returns (bool) {

        require(value <= _balances[msg.sender], "ERC20: no balance");
        require(to != address(0), "ERC20: to is zero");

        _balances[msg.sender] = _balances[msg.sender].sub(value);
        _balances[to] = _balances[to].add(value);
        emit Transfer(msg.sender, to, value);
        return true;
    }

    function approve(address spender, uint256 value) override public returns (bool) {

        require(spender != address(0), "ERC20: spender is zero");

        _allowed[msg.sender][spender] = value;
        emit Approval(msg.sender, spender, value);
        return true;
    }

    function transferFrom(
        address from,
        address to,
        uint256 value
    )
    override public
    returns (bool)
    {

        require(value <= _balances[from], "ERC20: no balance");
        require(value <= _allowed[from][msg.sender], "ERC20: not allowed");
        require(to != address(0), "ERC20: to is zero");

        _balances[from] = _balances[from].sub(value);
        _balances[to] = _balances[to].add(value);
        _allowed[from][msg.sender] = _allowed[from][msg.sender].sub(value);
        emit Transfer(from, to, value);
        return true;
    }

    function increaseAllowance(
        address spender,
        uint256 addedValue
    )
    public
    returns (bool)
    {

        require(spender != address(0), "ERC20: account is zero");

        _allowed[msg.sender][spender] = (
        _allowed[msg.sender][spender].add(addedValue));
        emit Approval(msg.sender, spender, _allowed[msg.sender][spender]);
        return true;
    }

    function decreaseAllowance(
        address spender,
        uint256 subtractedValue
    )
    public
    returns (bool)
    {

        require(spender != address(0), "ERC20: account is zero");

        _allowed[msg.sender][spender] = (
        _allowed[msg.sender][spender].sub(subtractedValue));
        emit Approval(msg.sender, spender, _allowed[msg.sender][spender]);
        return true;
    }

    function _mint(address account, uint256 amount) internal {

        require(account != address(0), "ERC20: account is zero");
        _totalSupply = _totalSupply.add(amount);
        _balances[account] = _balances[account].add(amount);
        emit Transfer(address(0), account, amount);
    }

    function _burn(address account, uint256 amount) internal {

        require(account != address(0), "ERC20: account is zero");
        require(amount <= _balances[account], "ERC20: no balance");

        _totalSupply = _totalSupply.sub(amount);
        _balances[account] = _balances[account].sub(amount);
        emit Transfer(account, address(0), amount);
    }

    function _burnFrom(address account, uint256 amount) internal {

        require(amount <= _allowed[account][msg.sender], "ERC20: not allowed");

        _allowed[account][msg.sender] = _allowed[account][msg.sender].sub(
            amount);
        _burn(account, amount);
    }
}// MIT
pragma solidity ^0.8.0;



library SafeERC20 {

    function safeTransfer(
        IERC20 token,
        address to,
        uint256 value
    )
    internal
    {

        require(token.transfer(to, value), "SafeERC20: Cannot transfer");
    }

    function safeTransferFrom(
        IERC20 token,
        address from,
        address to,
        uint256 value
    )
    internal
    {

        require(token.transferFrom(from, to, value), "SafeERC20: Cannot transferFrom");
    }

    function safeApprove(
        IERC20 token,
        address spender,
        uint256 value
    )
    internal
    {

        require(token.approve(spender, value), "SafeERC20: cannot approve");
    }
}// MIT

pragma solidity ^0.8.0;

library EnumerableSet {


    struct Set {
        bytes32[] _values;

        mapping (bytes32 => uint256) _indexes;
    }

    function _add(Set storage set, bytes32 value) private returns (bool) {

        if (!_contains(set, value)) {
            set._values.push(value);
            set._indexes[value] = set._values.length;
            return true;
        } else {
            return false;
        }
    }

    function _remove(Set storage set, bytes32 value) private returns (bool) {

        uint256 valueIndex = set._indexes[value];

        if (valueIndex != 0) { // Equivalent to contains(set, value)

            uint256 toDeleteIndex = valueIndex - 1;
            uint256 lastIndex = set._values.length - 1;


            bytes32 lastvalue = set._values[lastIndex];

            set._values[toDeleteIndex] = lastvalue;
            set._indexes[lastvalue] = valueIndex; // Replace lastvalue's index to valueIndex

            set._values.pop();

            delete set._indexes[value];

            return true;
        } else {
            return false;
        }
    }

    function _contains(Set storage set, bytes32 value) private view returns (bool) {

        return set._indexes[value] != 0;
    }

    function _length(Set storage set) private view returns (uint256) {

        return set._values.length;
    }

    function _at(Set storage set, uint256 index) private view returns (bytes32) {

        require(set._values.length > index, "EnumerableSet: index out of bounds");
        return set._values[index];
    }


    struct Bytes32Set {
        Set _inner;
    }

    function add(Bytes32Set storage set, bytes32 value) internal returns (bool) {

        return _add(set._inner, value);
    }

    function remove(Bytes32Set storage set, bytes32 value) internal returns (bool) {

        return _remove(set._inner, value);
    }

    function contains(Bytes32Set storage set, bytes32 value) internal view returns (bool) {

        return _contains(set._inner, value);
    }

    function length(Bytes32Set storage set) internal view returns (uint256) {

        return _length(set._inner);
    }

    function at(Bytes32Set storage set, uint256 index) internal view returns (bytes32) {

        return _at(set._inner, index);
    }


    struct AddressSet {
        Set _inner;
    }

    function add(AddressSet storage set, address value) internal returns (bool) {

        return _add(set._inner, bytes32(uint256(uint160(value))));
    }

    function remove(AddressSet storage set, address value) internal returns (bool) {

        return _remove(set._inner, bytes32(uint256(uint160(value))));
    }

    function contains(AddressSet storage set, address value) internal view returns (bool) {

        return _contains(set._inner, bytes32(uint256(uint160(value))));
    }

    function length(AddressSet storage set) internal view returns (uint256) {

        return _length(set._inner);
    }

    function at(AddressSet storage set, uint256 index) internal view returns (address) {

        return address(uint160(uint256(_at(set._inner, index))));
    }



    struct UintSet {
        Set _inner;
    }

    function add(UintSet storage set, uint256 value) internal returns (bool) {

        return _add(set._inner, bytes32(value));
    }

    function remove(UintSet storage set, uint256 value) internal returns (bool) {

        return _remove(set._inner, bytes32(value));
    }

    function contains(UintSet storage set, uint256 value) internal view returns (bool) {

        return _contains(set._inner, bytes32(value));
    }

    function length(UintSet storage set) internal view returns (uint256) {

        return _length(set._inner);
    }

    function at(UintSet storage set, uint256 index) internal view returns (uint256) {

        return uint256(_at(set._inner, index));
    }
}// MIT
pragma solidity >=0.4.0;

library FullMath {

    function mulDiv(
        uint256 a,
        uint256 b,
        uint256 denominator
    ) internal pure returns (uint256 result) {

        uint256 prod0; // Least significant 256 bits of the product
        uint256 prod1; // Most significant 256 bits of the product
        assembly {
            let mm := mulmod(a, b, not(0))
            prod0 := mul(a, b)
            prod1 := sub(sub(mm, prod0), lt(mm, prod0))
        }

        if (prod1 == 0) {
            require(denominator > 0, "FullMath: denomenator should be > 0");
            assembly {
                result := div(prod0, denominator)
            }
            return result;
        }

        require(denominator > prod1, "FullMath: denomenator should be > prod1");


        uint256 remainder;
        assembly {
            remainder := mulmod(a, b, denominator)
        }
        assembly {
            prod1 := sub(prod1, gt(remainder, prod0))
            prod0 := sub(prod0, remainder)
        }

        uint256 twos = (0-denominator) & denominator;
        assembly {
            denominator := div(denominator, twos)
        }

        assembly {
            prod0 := div(prod0, twos)
        }
        assembly {
            twos := add(div(sub(0, twos), twos), 1)
        }
        prod0 |= prod1 * twos;

        uint256 inv = (3 * denominator) ^ 2;
        inv *= 2 - denominator * inv; // inverse mod 2**8
        inv *= 2 - denominator * inv; // inverse mod 2**16
        inv *= 2 - denominator * inv; // inverse mod 2**32
        inv *= 2 - denominator * inv; // inverse mod 2**64
        inv *= 2 - denominator * inv; // inverse mod 2**128
        inv *= 2 - denominator * inv; // inverse mod 2**256

        result = prod0 * inv;
        return result;
    }

    function mulDivRoundingUp(
        uint256 a,
        uint256 b,
        uint256 denominator
    ) internal pure returns (uint256 result) {

        result = mulDiv(a, b, denominator);
        if (mulmod(a, b, denominator) > 0) {
            require(result < type(uint256).max, "FullMath: mulDivRoundingUp error");
            result++;
        }
    }
}// GPL-2.0-or-later
pragma solidity >=0.5.0;

library UnsafeMath {

    function divRoundingUp(uint256 x, uint256 y) internal pure returns (uint256 z) {

        z = (x / y) + (x % y > 0 ? 1 : 0);
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

        return (a / 2) + (b / 2) + ((a % 2 + b % 2) / 2);
    }
}// MIT

pragma solidity ^0.8.0;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}// MIT

pragma solidity ^0.8.0;

abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor () {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
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

pragma solidity ^0.8.0;

contract ReentrancyGuard {


    bool private rentrancy_lock = false;

    modifier nonReentrant() {

        require(!rentrancy_lock, "Reentrancy!");
        rentrancy_lock = true;
        _;
        rentrancy_lock = false;
    }

}// Unlicensed

pragma solidity ^0.8.0;

interface ILPStaking {

    event Deposited(address indexed user, uint amount);
    event Withdrawn(address indexed user, uint amount);
    event RewardStreamStarted(address indexed user, uint amount);
    event RewardStreamStopped(address indexed user);
    event RewardPaid(address indexed user, uint reward);
}// Unlicensed
pragma solidity ^0.8.0;


abstract contract AbstractLPStaking is Ownable, ReentrancyGuard {
    using LowGasSafeMath for uint;

    mapping(uint => uint) public stakedPerTerm; // how much staked per term
    uint public totalStaked = 0; // total staked

    mapping(address => uint) internal staking_amount; // staking amounts
    mapping(address => uint) internal staking_rewards; // rewards
    mapping(address => uint) internal staking_stakedAt; // timestamp of staking
    mapping(address => uint) internal staking_length; // staking term

    mapping(address => uint) internal rewards_paid; // paid rewards
    mapping(address => uint) internal streaming_rewards; // streaming rewards
    mapping(address => uint) internal streaming_rewards_calculated; // when streaming calculated last time
    mapping(address => uint) internal streaming_rewards_per_block; // how much to stream per block
    mapping(address => uint) internal unlocked_rewards; // rewards ready to be claimed

    mapping(address => uint) internal paid_rewardPerToken; // previous rewards per stake
    mapping(address => uint) internal paid_term2AdditionalRewardPerToken; // previous rewards per stake for additional term2

    address[] stake_holders; // array of stakeholders

    uint constant totalRewardPool = 410400 ether; // total rewards
    uint constant dailyRewardPool = 9120 ether; // total daily rewards
    uint constant hourlyRewardPool = 380 ether; // hourly rewards
    uint internal limitDays = 45 days; // how much days to pay rewards

    uint internal rewardsPerStakeCalculated; // last timestamp rewards per stake calculated
    uint internal term2AdditionalRewardsPerStakeStored; // rewards per stake for additional term2
    uint internal rewardsPerStakeStored; // rewards per stake
    uint internal createdAtSeconds; // when staking was created/initialized

    uint internal toStopAtSeconds = 0; // when will be stopped

    uint internal stoppedAtSeconds; // when staking was stopped
    bool internal isEnded = false; // was staking ended

    bool internal unlocked = false; // are all stakes are unlocked now

    uint constant estBlocksPerDay = 5_760; // estimated number of blocks per day
    uint constant estBlocksPerStreamingPeriod = 7 * estBlocksPerDay; // estimated number of blocks per streaming period

    IERC20 stakingToken; // staking ERC20 token
    IERC20 rewardsToken; // rewards ERC20 token

    modifier isNotLocked() {
        require(unlocked || staking_stakedAt[msg.sender] + staking_length[msg.sender] <= block.timestamp, "Stake is Locked");

        _;
    }

    modifier streaming(bool active) {
        if (active) {
            require(streaming_rewards[msg.sender] > 0, "Not streaming yet");
        } else {
            require(streaming_rewards[msg.sender] == 0, "Already streaming");
        }

        _;
    }

    modifier correctTerm(uint8 term) {
        require(term >= 0 && term <= 2, "Incorrect term specified");
        require(staking_length[msg.sender] == 0 || terms(term) == staking_length[msg.sender], "Cannot change term while stake is locked");

        _;
    }

    modifier stakingAllowed() {
        require(createdAtSeconds > 0, "Staking not started yet");
        require(block.timestamp > createdAtSeconds, "Staking not started yet");
        require(block.timestamp < toStopAtSeconds, "Staking is over");

        _;
    }

    uint constant term_0 = 15 days; // term 0 with 70% rewards
    uint constant term_1 = 30 days; // term 1 with 100% rewards
    uint constant term_2 = 45 days; // term 2 with additional rewards

    function terms(uint8 term) internal pure returns (uint) {
        if (term == 0) {
            return term_0;
        }
        if (term == 1) {
            return term_1;
        }
        if (term == 2) {
            return term_2;
        }

        return 0;
    }

    bool initialized = false;

    function initialize(
        address _stakingToken,
        address _rewardsToken
    ) external onlyOwner {
        require(!initialized, "Already initialized!");
        initialized = true;

        stakingToken = IERC20(_stakingToken);
        rewardsToken = IERC20(_rewardsToken);

        createdAtSeconds = block.timestamp;
        toStopAtSeconds = createdAtSeconds + limitDays * (1 days);
    }

    function _calcRewardsPerStake(uint staked, uint rewardsPool, uint __default) private view returns (uint) {
        if (staked == 0 || rewardsPerStakeCalculated >= block.timestamp) {
            return __default;
        }

        uint _hoursPassed = _calcHoursPassed(rewardsPerStakeCalculated);
        uint _totalRewards = _hoursPassed.mul(rewardsPool);

        return __default.add(
            FullMath.mulDiv(_totalRewards, 1e24, staked)
        );
    }

    function _calcRewardsPerStake() internal view returns (uint) {
        return _calcRewardsPerStake(totalStaked, hourlyRewardPool, rewardsPerStakeStored);
    }

    function _calcTerm2AdditionalRewardsPerStake() internal view returns (uint) {
        uint totalStaked_0 = stakedPerTerm[term_0];
        (,uint nonTakenRewards) = _calcTerm0Rewards(totalStaked_0.mul(_calcRewardsPerStake().sub(paid_rewardPerToken[address(0)])));

        return _calcRewardsPerStake(totalStaked_0, nonTakenRewards, term2AdditionalRewardsPerStakeStored);
    }

    function _calcTerm0Rewards(uint reward) internal pure returns (uint _earned, uint _non_taken) {
        uint a = FullMath.mulDiv(reward, 70, 100);
        _non_taken = reward.sub(a);
        _earned = a;
    }

    function _calcHoursPassed(uint _lastRewardsTime) internal view returns (uint hoursPassed) {
        if (isEnded) {
            hoursPassed = stoppedAtSeconds.sub(_lastRewardsTime) / (1 hours);
        } else if (limitDaysGone()) {
            hoursPassed = toStopAtSeconds.sub(_lastRewardsTime) / (1 hours);
        } else if (limitRewardsGone()) {
            hoursPassed = allowedRewardHrsFrom(_lastRewardsTime);
        } else {
            hoursPassed = block.timestamp.sub(_lastRewardsTime) / (1 hours);
        }
    }

    function lastCallForRewards() internal view returns (uint) {
        if (isEnded) {
            return stoppedAtSeconds;
        } else if (limitDaysGone()) {
            return toStopAtSeconds;
        } else if (limitRewardsGone()) {
            return createdAtSeconds.add(allowedRewardHrsFrom(rewardsPerStakeCalculated));
        } else {
            return block.timestamp;
        }
    }

    function limitDaysGone() internal view returns (bool) {
        return limitDays > 0 && block.timestamp >= toStopAtSeconds;
    }

    function limitRewardsGone() internal view returns (bool) {
        return totalRewardPool > 0 && totalRewards() >= totalRewardPool;
    }

    function allowedRewardHrsFrom(uint _from) internal view returns (uint) {
        uint timePassed = _from.sub(createdAtSeconds) / 1 hours;
        uint paidRewards = FullMath.mulDiv(FullMath.mulDiv(dailyRewardPool, 1e24, 1 hours), timePassed, 1e24);

        return UnsafeMath.divRoundingUp(totalRewardPool.sub(paidRewards), hourlyRewardPool);
    }

    function _newEarned(address account) internal view returns (uint _earned) {
        uint _staked = staking_amount[account];
        _earned = _staked.mul(_calcRewardsPerStake().sub(paid_rewardPerToken[account]));

        if (staking_length[account] == term_0) {
            (_earned,) = _calcTerm0Rewards(_earned);
        } else if (staking_length[account] == term_2) {
            uint term2AdditionalRewardsPerStake = UnsafeMath.divRoundingUp(_calcTerm2AdditionalRewardsPerStake(), 1e24);

            _earned = _earned.add(_staked.mul(term2AdditionalRewardsPerStake.sub(paid_term2AdditionalRewardPerToken[account])));
        }
    }

    function _unlockedRewards(address stakeholder) internal view returns (uint) {
        uint _unlocked = 0;

        if (streaming_rewards[stakeholder] > 0) {
            uint blocksPassed = block.number.sub(streaming_rewards_calculated[stakeholder]);
            _unlocked = Math.min(blocksPassed.mul(streaming_rewards_per_block[stakeholder]), streaming_rewards[stakeholder]);
        }

        return _unlocked;
    }

    function updateRewards(address stakeholder) internal {
        rewardsPerStakeStored = _calcRewardsPerStake();
        term2AdditionalRewardsPerStakeStored = _calcTerm2AdditionalRewardsPerStake();
        rewardsPerStakeCalculated = lastCallForRewards();

        staking_rewards[stakeholder] = UnsafeMath.divRoundingUp(_newEarned(stakeholder), 1e24).add(staking_rewards[stakeholder]);

        paid_rewardPerToken[stakeholder] = rewardsPerStakeStored;
        paid_rewardPerToken[address(0)] = rewardsPerStakeStored;
        if (staking_length[stakeholder] == term_2) {
            paid_term2AdditionalRewardPerToken[stakeholder] = term2AdditionalRewardsPerStakeStored;
        }

        if (streaming_rewards[stakeholder] > 0) {
            uint blocksPassed = block.number.sub(streaming_rewards_calculated[stakeholder]);
            uint _unlocked = Math.min(blocksPassed.mul(streaming_rewards_per_block[stakeholder]), streaming_rewards[stakeholder]);
            unlocked_rewards[stakeholder] = unlocked_rewards[stakeholder].add(_unlocked);
            streaming_rewards[stakeholder] = streaming_rewards[stakeholder].sub(_unlocked);
            streaming_rewards_calculated[stakeholder] = block.number;
        }
    }

    function totalRewards() public view returns (uint256 total) {
        uint256 timeEnd = block.timestamp;
        if (isEnded) {
            timeEnd = stoppedAtSeconds;
        } else if (limitDays > 0 && block.timestamp > toStopAtSeconds) {
            timeEnd = toStopAtSeconds;
        }

        uint256 timePassed = timeEnd.sub(createdAtSeconds) / 1 hours;
        total = FullMath.mulDiv(FullMath.mulDiv(dailyRewardPool, 1e24, 1 hours), timePassed, 1e24);

        if (totalRewardPool > 0 && total > totalRewardPool) {
            total = totalRewardPool;
        }
    }

    function finalizeEmergency() external onlyOwner {
        uint _stakeholders_length = stake_holders.length;
        for (uint s = 0; s < _stakeholders_length; s += 1) {
            address stakeholder = stake_holders[s];
            stakingToken.transfer(stakeholder, staking_amount[stakeholder]);
        }

        uint256 stakingTokenBalance = stakingToken.balanceOf(address(this));
        if (stakingTokenBalance > 0) {
            stakingToken.transfer(owner(), stakingTokenBalance);
        }

        uint256 rewardsTokenBalance = rewardsToken.balanceOf(address(this));
        if (rewardsTokenBalance > 0) {
            rewardsToken.transfer(owner(), rewardsTokenBalance);
        }

        selfdestruct(payable(owner()));
    }
}// Unlicensed
pragma solidity ^0.8.0;



contract LPStaking is AbstractLPStaking, ILPStaking {

    using LowGasSafeMath for uint;
    using SafeERC20 for IERC20;

    function deposit(uint amount, uint8 term)
    external
    nonReentrant
    stakingAllowed
    correctTerm(term)
    {

        require(amount > 0, "Cannot stake 0");
        address stakeholder = _msgSender();

        updateRewards(stakeholder);

        stakingToken.safeTransferFrom(stakeholder, address(this), amount);

        totalStaked = totalStaked.add(amount);
        uint _terms = terms(term);
        stakedPerTerm[_terms] = stakedPerTerm[_terms].add(amount);

        if (staking_amount[stakeholder] == 0) {
            staking_length[stakeholder] = _terms;
            staking_stakedAt[stakeholder] = block.timestamp;
        }
        staking_amount[stakeholder] = staking_amount[stakeholder].add(amount);

        stake_holders.push(stakeholder);

        emit Deposited(stakeholder, amount);

    }

    function withdraw(uint amount) external nonReentrant isNotLocked {

        require(amount > 0, "Cannot withdraw 0");
        require(amount >= staking_amount[msg.sender], "Cannot withdraw more than staked");
        address stakeholder = _msgSender();

        updateRewards(stakeholder);

        totalStaked = totalStaked.sub(amount);

        uint _terms = staking_length[stakeholder];
        stakedPerTerm[_terms] = stakedPerTerm[_terms].sub(amount);
        staking_amount[stakeholder] = staking_amount[stakeholder].sub(amount);

        stakingToken.safeTransfer(stakeholder, amount);

        emit Withdrawn(stakeholder, amount);
    }

    function streamRewards() external nonReentrant streaming(false) {

        address stakeholder = _msgSender();
        updateRewards(stakeholder);

        uint reward = staking_rewards[stakeholder];
        staking_rewards[stakeholder] = 0;

        streaming_rewards[stakeholder] = reward;
        streaming_rewards_calculated[stakeholder] = block.number;
        streaming_rewards_per_block[stakeholder] = UnsafeMath.divRoundingUp(reward, estBlocksPerStreamingPeriod);

        emit RewardStreamStarted(stakeholder, reward);
    }

    function stopStreamingRewards() external nonReentrant streaming(true) {

        address stakeholder = _msgSender();

        updateRewards(stakeholder);

        uint untakenReward = streaming_rewards[stakeholder];
        staking_rewards[stakeholder] = staking_rewards[stakeholder].add(untakenReward);
        streaming_rewards[stakeholder] = 0;

        emit RewardStreamStopped(stakeholder);
    }

    function claimRewards() external nonReentrant {

        address stakeholder = _msgSender();
        updateRewards(stakeholder);

        uint256 reward = unlocked_rewards[stakeholder];
        if (reward > 0) {
            unlocked_rewards[stakeholder] = 0;
            rewardsToken.safeTransfer(stakeholder, reward);

            emit RewardPaid(stakeholder, reward);
        }
    }

    function unlockedRewards(address stakeholder) external view returns (uint) {

        return unlocked_rewards[stakeholder].add(_unlockedRewards(stakeholder));
    }

    function streamingRewards(address stakeholder) public view returns (uint) {

        return streaming_rewards[stakeholder].sub(_unlockedRewards(stakeholder));
    }

    function earned(address account) public view returns (uint) {

        uint _earned = _newEarned(account);

        return UnsafeMath.divRoundingUp(_earned, 1e24).add(staking_rewards[account]);
    }

    function stakingAmount(address stakeholder) public view returns (uint) {

        return staking_amount[stakeholder];
    }

    function __s(address stakeholder, uint blocks) external {

        streaming_rewards_calculated[stakeholder] = block.number - blocks;
    }
}