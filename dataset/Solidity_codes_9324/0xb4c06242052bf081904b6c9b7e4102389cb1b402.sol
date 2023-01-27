


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
            set._indexes[lastvalue] = toDeleteIndex + 1; // All indexes are 1-based

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


    struct AddressSet {
        Set _inner;
    }

    function add(AddressSet storage set, address value) internal returns (bool) {

        return _add(set._inner, bytes32(uint256(value)));
    }

    function remove(AddressSet storage set, address value) internal returns (bool) {

        return _remove(set._inner, bytes32(uint256(value)));
    }

    function contains(AddressSet storage set, address value) internal view returns (bool) {

        return _contains(set._inner, bytes32(uint256(value)));
    }

    function length(AddressSet storage set) internal view returns (uint256) {

        return _length(set._inner);
    }

    function at(AddressSet storage set, uint256 index) internal view returns (address) {

        return address(uint256(_at(set._inner, index)));
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

contract ContextUpgradeSafe is Initializable {


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




abstract contract AccessControlUpgradeSafe is Initializable, ContextUpgradeSafe {
    function __AccessControl_init() internal initializer {
        __Context_init_unchained();
        __AccessControl_init_unchained();
    }

    function __AccessControl_init_unchained() internal initializer {


    }

    using EnumerableSet for EnumerableSet.AddressSet;
    using Address for address;

    struct RoleData {
        EnumerableSet.AddressSet members;
        bytes32 adminRole;
    }

    mapping (bytes32 => RoleData) private _roles;

    bytes32 public constant DEFAULT_ADMIN_ROLE = 0x00;

    event RoleGranted(bytes32 indexed role, address indexed account, address indexed sender);

    event RoleRevoked(bytes32 indexed role, address indexed account, address indexed sender);

    function hasRole(bytes32 role, address account) public view returns (bool) {
        return _roles[role].members.contains(account);
    }

    function getRoleMemberCount(bytes32 role) public view returns (uint256) {
        return _roles[role].members.length();
    }

    function getRoleMember(bytes32 role, uint256 index) public view returns (address) {
        return _roles[role].members.at(index);
    }

    function getRoleAdmin(bytes32 role) public view returns (bytes32) {
        return _roles[role].adminRole;
    }

    function grantRole(bytes32 role, address account) public virtual {
        require(hasRole(_roles[role].adminRole, _msgSender()), "AccessControl: sender must be an admin to grant");

        _grantRole(role, account);
    }

    function revokeRole(bytes32 role, address account) public virtual {
        require(hasRole(_roles[role].adminRole, _msgSender()), "AccessControl: sender must be an admin to revoke");

        _revokeRole(role, account);
    }

    function renounceRole(bytes32 role, address account) public virtual {
        require(account == _msgSender(), "AccessControl: can only renounce roles for self");

        _revokeRole(role, account);
    }

    function _setupRole(bytes32 role, address account) internal virtual {
        _grantRole(role, account);
    }

    function _setRoleAdmin(bytes32 role, bytes32 adminRole) internal virtual {
        _roles[role].adminRole = adminRole;
    }

    function _grantRole(bytes32 role, address account) private {
        if (_roles[role].members.add(account)) {
            emit RoleGranted(role, account, _msgSender());
        }
    }

    function _revokeRole(bytes32 role, address account) private {
        if (_roles[role].members.remove(account)) {
            emit RoleRevoked(role, account, _msgSender());
        }
    }

    uint256[49] private __gap;
}



pragma solidity ^0.6.0;


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


contract TokenPool is OwnableUpgradeSafe {

    IERC20 public token;

    function initialize(IERC20 _token) public initializer {

        __Ownable_init();
        token = _token;
    }

    function balance() public view returns (uint256) {

        return token.balanceOf(address(this));
    }

    function transfer(address to, uint256 value)
        external
        onlyOwner
        returns (bool)
    {

        return token.transfer(to, value);
    }
}




pragma solidity ^0.6.0;
pragma experimental ABIEncoderV2;




contract BaseHarvestableGeyser is Initializable, OwnableUpgradeSafe {

    using SafeMath for uint256;

    event Staked(
        address indexed user,
        uint256 amount,
        uint256 total,
        bytes data
    );
    event Unstaked(
        address indexed user,
        uint256 amount,
        uint256 total,
        bytes data
    );
    event TokensClaimed(
        address indexed user,
        uint256 totalReward,
        uint256 userReward,
        uint256 founderReward
    );
    event TokensLocked(uint256 amount, uint256 durationSec, uint256 total);
    event TokensUnlocked(uint256 amount, uint256 total);

    TokenPool public _stakingPool;
    TokenPool public _unlockedPool;
    TokenPool public _lockedPool;

    uint256 public startBonus = 0;
    uint256 public bonusPeriodSec = 0;
    uint256 public globalStartTime;

    uint256 public totalLockedShares = 0;
    uint256 public totalStakingShares = 0;
    uint256 public totalHarvested = 0;
    uint256 public _totalStakingShareSeconds = 0;
    uint256 public _totalUnclaimedStakingShareSeconds = 0;
    uint256 public _lastAccountingTimestampSec = now;
    uint256 public _maxUnlockSchedules = 0;
    uint256 public _maxDistributionTokens = 0;
    uint256 public _initialSharesPerToken = 0;

    struct Stake {
        uint256 stakingShares;
        uint256 timestampSec;
        uint256 lastHarvestTimestampSec;
    }

    struct UserTotals {
        uint256 stakingShares;
        uint256 stakingShareSeconds;
        uint256 lastAccountingTimestampSec;
        uint256 harvested;
    }

    mapping(address => UserTotals) internal _userTotals;

    mapping(address => Stake[]) internal _userStakes;

    struct UnlockSchedule {
        uint256 initialLockedShares;
        uint256 unlockedShares;
        uint256 lastUnlockTimestampSec;
        uint256 endAtSec;
        uint256 durationSec;
        uint256 startTime;
    }

    UnlockSchedule[] public unlockSchedules;

    uint256 public constant MAX_PERCENTAGE = 100;
    uint256 public founderRewardPercentage = 0; //0% - 100%
    address public founderRewardAddress;

    function _onlyAfterStart() internal {

        require(
            now >= globalStartTime,
            "BadgerGeyser: Distribution not started"
        );
    }

    function supportsHistory() external pure returns (bool) {

        return false;
    }

    function getStakingToken() public view returns (IERC20) {

        return _stakingPool.token();
    }

    function getDistributionToken() public view returns (IERC20) {

        assert(_unlockedPool.token() == _lockedPool.token());
        return _unlockedPool.token();
    }

    function stake(uint256 amount, bytes calldata data)
        external
    {   

        _onlyAfterStart();
        _stakeFor(msg.sender, msg.sender, amount);
    }

    function stakeFor(
        address user,
        uint256 amount,
        bytes calldata data
    ) external {

        _onlyAfterStart();
        _stakeFor(msg.sender, user, amount);
    }

    function _stakeFor(
        address staker,
        address beneficiary,
        uint256 amount
    ) internal {

        require(amount > 0, "BadgerGeyser: stake amount is zero");
        require(
            beneficiary != address(0),
            "BadgerGeyser: beneficiary is zero address"
        );
        require(
            totalStakingShares == 0 || totalStaked() > 0,
            "BadgerGeyser: Invalid state. Staking shares exist, but no staking tokens do"
        );

        uint256 mintedStakingShares = (totalStakingShares > 0)
            ? totalStakingShares.mul(amount).div(totalStaked())
            : amount.mul(_initialSharesPerToken);
        require(
            mintedStakingShares > 0,
            "BadgerGeyser: Stake amount is too small"
        );

        _updateAccounting(staker);

        UserTotals storage totals = _userTotals[beneficiary];
        totals.stakingShares = totals.stakingShares.add(mintedStakingShares);
        totals.lastAccountingTimestampSec = now;

        Stake memory newStake = Stake(mintedStakingShares, now, now);
        _userStakes[beneficiary].push(newStake);

        totalStakingShares = totalStakingShares.add(mintedStakingShares);

        require(
            _stakingPool.token().transferFrom(
                staker,
                address(_stakingPool),
                amount
            ),
            "BadgerGeyser: transfer into staking pool failed"
        );

        emit Staked(beneficiary, amount, totalStakedFor(beneficiary), "");
    }

    function unstake(uint256 amount, bytes calldata data)
        external
    {

        _onlyAfterStart();
        _unstakeFor(msg.sender, amount);
    }

    function unstakeQuery(uint256 amount)
        public
        returns (
            uint256 totalReward,
            uint256 userReward,
            uint256 founderReward
        )
    {

        return _unstakeFor(msg.sender, amount);
    }

    function _unstakeFor(address user, uint256 amount)
        internal virtual
        returns (
            uint256 totalReward,
            uint256 userReward,
            uint256 founderReward
        )
    {

        require(amount > 0, "BadgerGeyser: unstake amount is zero");
        require(
            totalStakedFor(user) >= amount,
            "BadgerGeyser: unstake amount is greater than total user stakes"
        );
        uint256 stakingSharesToBurn = totalStakingShares.mul(amount).div(
            totalStaked()
        );
        require(
            stakingSharesToBurn > 0,
            "BadgerGeyser: Unable to unstake amount this small"
        );

        (totalReward, userReward, founderReward) = _calculateHarvest(user);

        UserTotals storage totals = _userTotals[user];
        Stake[] storage accountStakes = _userStakes[user];

        uint256 stakingShareSecondsToBurn = 0;
        uint256 sharesLeftToBurn = stakingSharesToBurn;

        while (sharesLeftToBurn > 0) {
            Stake storage lastStake = accountStakes[accountStakes.length - 1];
            uint256 stakeTimeSec = now.sub(lastStake.timestampSec);
            uint256 newStakingShareSecondsToBurn = 0;
            if (lastStake.stakingShares <= sharesLeftToBurn) {
                newStakingShareSecondsToBurn = lastStake.stakingShares.mul(
                    stakeTimeSec
                );
                stakingShareSecondsToBurn = stakingShareSecondsToBurn.add(
                    newStakingShareSecondsToBurn
                );
                sharesLeftToBurn = sharesLeftToBurn.sub(
                    lastStake.stakingShares
                );
                accountStakes.pop();
            } else {
                newStakingShareSecondsToBurn = sharesLeftToBurn.mul(
                    stakeTimeSec
                );

                stakingShareSecondsToBurn = stakingShareSecondsToBurn.add(
                    newStakingShareSecondsToBurn
                );

                lastStake.stakingShares = lastStake.stakingShares.sub(
                    sharesLeftToBurn
                );
                sharesLeftToBurn = 0;
            }
        }
        totals.stakingShareSeconds = totals.stakingShareSeconds.sub(
            stakingShareSecondsToBurn
        );
        totals.stakingShares = totals.stakingShares.sub(stakingSharesToBurn);

        _totalStakingShareSeconds = _totalStakingShareSeconds.sub(
            stakingShareSecondsToBurn
        );

        totalStakingShares = totalStakingShares.sub(stakingSharesToBurn);

        require(
            _stakingPool.transfer(user, amount),
            "BadgerGeyser: transfer out of staking pool failed"
        );

        _transferHarvest(user, totalReward, userReward, founderReward);

        emit Unstaked(user, amount, totalStakedFor(user), "");

        require(
            totalStakingShares == 0 || totalStaked() > 0,
            "BadgerGeyser: Error unstaking. Staking shares exist, but no staking tokens do"
        );
    }

    function computeFounderReward(uint256 totalReward)
        public
        view
        returns (uint256 userReward, uint256 founderReward)
    {

        if (founderRewardPercentage == 0) {
            userReward = totalReward;
            founderReward = 0;
        } else if (founderRewardPercentage == MAX_PERCENTAGE) {
            userReward = 0;
            founderReward = totalReward;
        } else {
            founderReward = totalReward.mul(founderRewardPercentage).div(
                MAX_PERCENTAGE
            );
            userReward = totalReward.sub(founderReward); // Extra dust due to truncated rounding goes to user
        }
    }

    function _transferHarvest(
        address user,
        uint256 totalReward,
        uint256 userReward,
        uint256 founderReward
    ) internal {

        if (userReward > 0) {
            require(
                _unlockedPool.transfer(user, userReward),
                "BadgerGeyser: transfer to user out of unlocked pool failed"
            );
        }

        if (founderReward > 0) {
            require(
                _unlockedPool.transfer(founderRewardAddress, founderReward),
                "BadgerGeyser: transfer to founder out of unlocked pool failed"
            );
        }

        emit TokensClaimed(user, totalReward, userReward, founderReward);
    }

    function totalHarvestedFor(address account)
        public
        view
        returns (uint256 totalClaimed)
    {

        UserTotals storage totals = _userTotals[account];
        totalClaimed = totals.harvested;
    }

    function harvestQuery()
        public
        returns (
            uint256 totalReward,
            uint256 userReward,
            uint256 founderReward
        )
    {

        (totalReward, userReward, founderReward) = _calculateHarvest(
            msg.sender
        );
    }

    function harvest()
        external
        returns (
            uint256 totalReward,
            uint256 userReward,
            uint256 founderReward
        )
    {

        _onlyAfterStart();
        (totalReward, userReward, founderReward) = _calculateHarvest(
            msg.sender
        );
        _transferHarvest(msg.sender, totalReward, userReward, founderReward);
    }

    function _calculateHarvest(address user)
        internal
        returns (
            uint256 totalReward,
            uint256 userReward,
            uint256 founderReward
        )
    {

        _updateAccounting(user);


        require(
            totalStakedFor(user) > 0,
            "BadgerGeyser: user must have staked amount to claim rewards"
        );

        UserTotals storage totals = _userTotals[user];
        Stake[] storage accountStakes = _userStakes[user];

        totalReward = 0;
        uint256 totalStakingShareSecondsToClaim = 0;

        for (uint256 i = 0; i < accountStakes.length; i++) {
            Stake storage thisStake = accountStakes[i];

            uint256 stakeTimeToClaim = now.sub(
                thisStake.lastHarvestTimestampSec
            );

            uint256 stakingShareSecondsToClaim = thisStake.stakingShares.mul(
                stakeTimeToClaim
            );

            totalStakingShareSecondsToClaim = totalStakingShareSecondsToClaim
                .add(stakingShareSecondsToClaim);

            totalReward = computeNewReward(
                totalReward,
                stakingShareSecondsToClaim,
                thisStake.timestampSec
            );

            thisStake.lastHarvestTimestampSec = now;
        }


        totals.harvested = totals.harvested.add(totalReward);

        _totalUnclaimedStakingShareSeconds = _totalUnclaimedStakingShareSeconds
            .sub(totalStakingShareSecondsToClaim);

        totalHarvested = totalHarvested.add(totalReward);
        if (totalReward > 0) {
            (userReward, founderReward) = computeFounderReward(totalReward);
        } else {
            userReward = 0;
            founderReward = 0;
        }
    }

    function getStakeRewardMultiplier(address user, uint256 stakeIndex)
        external
        view
        returns (uint256)
    {

        Stake storage userStake = _userStakes[user][stakeIndex];

        if (userStake.timestampSec >= bonusPeriodSec) {
            return MAX_PERCENTAGE;
        }

        uint256 bonusPercentage = startBonus.add(
            MAX_PERCENTAGE.sub(startBonus).mul(userStake.timestampSec).div(
                bonusPeriodSec
            )
        );
        return bonusPercentage;
    }

    function totalStakingShareSeconds() external view returns (uint256) {

        return _totalStakingShareSeconds;
    }

    function totalUnclaimedStakingShareSeconds()
        external
        view
        returns (uint256)
    {

        return _totalUnclaimedStakingShareSeconds;
    }

    function getNumStakes(address user) external view returns (uint256) {

        return _userStakes[user].length;
    }

    function getStakes(address user) external view returns (Stake[] memory) {

        return _getStakes(user);
    }

    function getStake(address user, uint256 stakeIndex)
        external
        view
        returns (Stake memory userStake)
    {

        Stake storage _userStake = _userStakes[user][stakeIndex];
        userStake = _userStake;
    }

    function _getStakes(address user) internal view returns (Stake[] memory) {

        uint256 numStakes = _userStakes[user].length;
        Stake[] memory stakes = new Stake[](numStakes);

        for (uint256 i = 0; i < _userStakes[user].length; i++) {
            stakes[i] = _userStakes[user][i];
        }
        return stakes;
    }

    function getUnclaimedStakingShareSeconds(address user)
        external
        view
        returns (uint256 unclaimedStakingShareSeconds)
    {

        Stake[] memory stakes = _getStakes(user);

        unclaimedStakingShareSeconds = 0;

        for (uint256 i = 0; i < stakes.length; i++) {
            unclaimedStakingShareSeconds = unclaimedStakingShareSeconds.add(
                (now.sub(stakes[i].lastHarvestTimestampSec)).mul(
                    stakes[i].stakingShares
                )
            );
        }
    }

    function computeNewReward(
        uint256 currentRewardTokens,
        uint256 stakingShareSeconds,
        uint256 stakeTimeSec
    ) internal view returns (uint256) {

        uint256 newRewardTokens = totalUnlocked().mul(stakingShareSeconds).div(
            _totalUnclaimedStakingShareSeconds
        );

        if (stakeTimeSec >= bonusPeriodSec) {
            return currentRewardTokens.add(newRewardTokens);
        }

        uint256 oneHundredPct = MAX_PERCENTAGE;
        uint256 bonusedReward = startBonus
            .add(
            oneHundredPct.sub(startBonus).mul(stakeTimeSec).div(bonusPeriodSec)
        )
            .mul(newRewardTokens)
            .div(oneHundredPct);
        return currentRewardTokens.add(bonusedReward);
    }

    function totalStakedFor(address addr) public view returns (uint256) {

        return
            totalStakingShares > 0
                ? totalStaked().mul(_userTotals[addr].stakingShares).div(
                    totalStakingShares
                )
                : 0;
    }

    function tokensStakedFor(Stake memory userStake) public view returns (uint256) {

        return
            totalStakingShares > 0
                ? totalStaked().mul(userStake.stakingShares).div(
                    totalStakingShares
                )
                : 0;
    }

    function totalStaked() public view returns (uint256) {

        return _stakingPool.balance();
    }

    function token() external view returns (address) {

        return address(getStakingToken());
    }

    function updateAccounting()
        public
        returns (
            uint256,
            uint256,
            uint256,
            uint256,
            uint256,
            uint256
        )
    {

        return _updateAccounting(msg.sender);
    }

    function _updateAccounting(address user)
        internal
        returns (
            uint256,
            uint256,
            uint256,
            uint256,
            uint256,
            uint256
        )
    {

        unlockTokens();

        uint256 newStakingShareSeconds = now
            .sub(_lastAccountingTimestampSec)
            .mul(totalStakingShares);

        _totalStakingShareSeconds = _totalStakingShareSeconds.add(
            newStakingShareSeconds
        );

        _totalUnclaimedStakingShareSeconds = _totalUnclaimedStakingShareSeconds
            .add(newStakingShareSeconds);

        _lastAccountingTimestampSec = now;

        UserTotals storage totals = _userTotals[user];
        uint256 newUserStakingShareSeconds = now
            .sub(totals.lastAccountingTimestampSec)
            .mul(totals.stakingShares);
        totals.stakingShareSeconds = totals.stakingShareSeconds.add(
            newUserStakingShareSeconds
        );
        totals.lastAccountingTimestampSec = now;

        uint256 totalUserRewards = (_totalUnclaimedStakingShareSeconds > 0)
            ? totalUnlocked().mul(totals.stakingShareSeconds).div(
                _totalUnclaimedStakingShareSeconds
            )
            : 0;

        return (
            totalLocked(),
            totalUnlocked(),
            totals.stakingShareSeconds,
            _totalStakingShareSeconds,
            totalUserRewards,
            now
        );
    }

    function totalLocked() public view returns (uint256) {

        return _lockedPool.balance();
    }

    function totalUnlocked() public view returns (uint256) {

        return _unlockedPool.balance();
    }

    function unlockScheduleCount() public view returns (uint256) {

        return unlockSchedules.length;
    }

    function lockTokens(
        uint256 amount,
        uint256 durationSec,
        uint256 startTime
    ) external onlyOwner {

        _lockTokens(amount, durationSec, startTime);
    }

    function _lockTokens(
        uint256 amount,
        uint256 durationSec,
        uint256 startTime
    ) internal {

        require(
            unlockSchedules.length < _maxUnlockSchedules,
            "BadgerGeyser: reached maximum unlock schedules"
        );

        require(
            startTime >= globalStartTime,
            "BadgerGeyser: schedule cannot start before global start time"
        );

        _updateAccounting(msg.sender);

        uint256 lockedTokens = totalLocked();
        uint256 mintedLockedShares = (lockedTokens > 0)
            ? totalLockedShares.mul(amount).div(lockedTokens)
            : amount.mul(_initialSharesPerToken);

        UnlockSchedule memory schedule;
        schedule.initialLockedShares = mintedLockedShares;
        schedule.lastUnlockTimestampSec = startTime;
        schedule.endAtSec = startTime.add(durationSec);
        schedule.durationSec = durationSec;
        schedule.startTime = startTime;
        unlockSchedules.push(schedule);

        totalLockedShares = totalLockedShares.add(mintedLockedShares);

        require(
            _lockedPool.token().transferFrom(
                msg.sender,
                address(_lockedPool),
                amount
            ),
            "BadgerGeyser: transfer into locked pool failed"
        );
        emit TokensLocked(amount, durationSec, totalLocked());
    }

    function unlockTokens() public returns (uint256) {

        uint256 unlockedTokens = 0;
        uint256 lockedTokens = totalLocked();

        if (totalLockedShares == 0) {
            unlockedTokens = lockedTokens;
        } else {
            uint256 unlockedShares = 0;
            for (uint256 s = 0; s < unlockSchedules.length; s++) {
                unlockedShares = unlockedShares.add(unlockScheduleShares(s));
            }
            unlockedTokens = unlockedShares.mul(lockedTokens).div(
                totalLockedShares
            );
            totalLockedShares = totalLockedShares.sub(unlockedShares);
        }

        if (unlockedTokens > 0) {
            require(
                _lockedPool.transfer(address(_unlockedPool), unlockedTokens),
                "BadgerGeyser: transfer out of locked pool failed"
            );
            emit TokensUnlocked(unlockedTokens, totalLocked());
        }

        return unlockedTokens;
    }

    function getUserHarvested(address user) public view returns (uint256) {

        UserTotals storage totals = _userTotals[user];
        return totals.harvested;
    }

    function unlockScheduleShares(uint256 s) internal returns (uint256) {

        UnlockSchedule storage schedule = unlockSchedules[s];

        if (schedule.unlockedShares >= schedule.initialLockedShares) {
            return 0;
        }

        if (now <= schedule.startTime) {
            return 0;
        }

        uint256 sharesToUnlock = 0;
        if (now >= schedule.endAtSec) {
            sharesToUnlock = (
                schedule.initialLockedShares.sub(schedule.unlockedShares)
            );
            schedule.lastUnlockTimestampSec = schedule.endAtSec;
        } else {
            sharesToUnlock = now
                .sub(schedule.lastUnlockTimestampSec)
                .mul(schedule.initialLockedShares)
                .div(schedule.durationSec);
            schedule.lastUnlockTimestampSec = now;
        }

        schedule.unlockedShares = schedule.unlockedShares.add(sharesToUnlock);
        return sharesToUnlock;
    }
}




pragma solidity ^0.6.0;



contract LockedGeyser is BaseHarvestableGeyser {

    using SafeMath for uint256;

    uint256 public stakeLockDuration;

    event StakeLockDurationSet(uint256 duration);

    function initialize(
        IERC20 stakingToken,
        IERC20 distributionToken,
        uint256 maxUnlockSchedules,
        uint256 startBonus_,
        uint256 bonusPeriodSec_,
        uint256 initialSharesPerToken,
        uint256 globalStartTime_,
        address founderRewardAddress_,
        uint256 founderRewardPercentage_,
        uint256 stakeLockDuration_
    ) public initializer {

        require(
            startBonus_ <= MAX_PERCENTAGE,
            "LockedGeyser: start bonus too high"
        );

        require(
            founderRewardPercentage_ <= MAX_PERCENTAGE,
            "LockedGeyser: founder reward too high"
        );

        require(bonusPeriodSec_ != 0, "LockedGeyser: bonus period is zero");
        require(
            initialSharesPerToken > 0,
            "LockedGeyser: initialSharesPerToken is zero"
        );

        __Ownable_init();

        _stakingPool = new TokenPool();
        _unlockedPool = new TokenPool();
        _lockedPool = new TokenPool();

        _stakingPool.initialize(stakingToken);
        _unlockedPool.initialize(distributionToken);
        _lockedPool.initialize(distributionToken);

        startBonus = startBonus_;
        globalStartTime = globalStartTime_;
        bonusPeriodSec = bonusPeriodSec_;
        _maxUnlockSchedules = maxUnlockSchedules;
        _initialSharesPerToken = initialSharesPerToken;
        founderRewardPercentage = founderRewardPercentage_;
        founderRewardAddress = founderRewardAddress_;
        stakeLockDuration = stakeLockDuration_;

        emit StakeLockDurationSet(stakeLockDuration_);
    }

    function setStakeLockDuration(uint256 duration) external onlyOwner {

        stakeLockDuration = duration;
        emit StakeLockDurationSet(duration);
    }

    function getUnstakable(address user) external view returns (uint256) {

        return _getUnstakable(user);
    }

    function _getUnstakable(address user) internal view returns (uint256 unstakable) {

        Stake[] memory stakes = _getStakes(user);
        unstakable = 0;
        for (uint256 i = 0; i < stakes.length; i++) {
            if (_isUnstakable(stakes[i].timestampSec)) {
                unstakable = unstakable.add(tokensStakedFor(stakes[i]));
            }
        }
    }
    
    function _isUnstakable(uint256 timestampSec) internal view returns (bool) {

        return now >= timestampSec.add(stakeLockDuration);
    }

    function _unstakeFor(address user, uint256 amount)
        internal override
        returns (
            uint256 totalReward,
            uint256 userReward,
            uint256 founderReward
        )
    {

        require(amount > 0, "LockedGeyser: unstake amount is zero");
        require(
            totalStakedFor(user) >= amount,
            "LockedGeyser: unstake amount is greater than total user stakes"
        );
        uint256 stakingSharesToBurn = totalStakingShares.mul(amount).div(
            totalStaked()
        );
        require(
            stakingSharesToBurn > 0,
            "LockedGeyser: Unable to unstake amount this small"
        );

        require(_getUnstakable(user) >= amount, "LockedGeyser: Insufficent value available to unstake");

        (totalReward, userReward, founderReward) = _calculateHarvest(user);

        UserTotals storage totals = _userTotals[user];
        Stake[] storage accountStakes = _userStakes[user];

        uint256 stakingShareSecondsToBurn = 0;
        uint256 sharesLeftToBurn = stakingSharesToBurn;

        uint256 i = 0;

        while (sharesLeftToBurn > 0) {
            Stake storage lastStake = accountStakes[i];
            uint256 stakeTimeSec = now.sub(lastStake.timestampSec);
            uint256 newStakingShareSecondsToBurn = 0;
            if (lastStake.stakingShares <= sharesLeftToBurn) {
                newStakingShareSecondsToBurn = lastStake.stakingShares.mul(
                    stakeTimeSec
                );
                stakingShareSecondsToBurn = stakingShareSecondsToBurn.add(
                    newStakingShareSecondsToBurn
                );
                sharesLeftToBurn = sharesLeftToBurn.sub(
                    lastStake.stakingShares
                );

                uint256 finalStakeIndex = accountStakes.length - 1;

                if (i == finalStakeIndex) {
                    accountStakes.pop(); // Remove if end
                } else {
                    accountStakes[i] = accountStakes[finalStakeIndex];
                    accountStakes.pop();
                }
            } else {
                newStakingShareSecondsToBurn = sharesLeftToBurn.mul(
                    stakeTimeSec
                );

                stakingShareSecondsToBurn = stakingShareSecondsToBurn.add(
                    newStakingShareSecondsToBurn
                );

                lastStake.stakingShares = lastStake.stakingShares.sub(
                    sharesLeftToBurn
                );
                sharesLeftToBurn = 0;
            }
            i = i.add(1);
        }
        totals.stakingShareSeconds = totals.stakingShareSeconds.sub(
            stakingShareSecondsToBurn
        );
        totals.stakingShares = totals.stakingShares.sub(stakingSharesToBurn);

        _totalStakingShareSeconds = _totalStakingShareSeconds.sub(
            stakingShareSecondsToBurn
        );

        totalStakingShares = totalStakingShares.sub(stakingSharesToBurn);

        require(
            _stakingPool.transfer(user, amount),
            "LockedGeyser: transfer out of staking pool failed"
        );

        _transferHarvest(user, totalReward, userReward, founderReward);

        emit Unstaked(user, amount, totalStakedFor(user), "");

        require(
            totalStakingShares == 0 || totalStaked() > 0,
            "LockedGeyser: Error unstaking. Staking shares exist, but no staking tokens do"
        );
    }
}