
pragma solidity >=0.6.0 <0.8.0;

library SafeMathUpgradeable {

    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        uint256 c = a + b;
        if (c < a) return (false, 0);
        return (true, c);
    }

    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        if (b > a) return (false, 0);
        return (true, a - b);
    }

    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        if (a == 0) return (true, 0);
        uint256 c = a * b;
        if (c / a != b) return (false, 0);
        return (true, c);
    }

    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        if (b == 0) return (false, 0);
        return (true, a / b);
    }

    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        if (b == 0) return (false, 0);
        return (true, a % b);
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {

        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");
        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b <= a, "SafeMath: subtraction overflow");
        return a - b;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {

        if (a == 0) return 0;
        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");
        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b > 0, "SafeMath: division by zero");
        return a / b;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b > 0, "SafeMath: modulo by zero");
        return a % b;
    }

    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        require(b <= a, errorMessage);
        return a - b;
    }

    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        require(b > 0, errorMessage);
        return a / b;
    }

    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        require(b > 0, errorMessage);
        return a % b;
    }
}// MIT

pragma solidity >=0.6.0 <0.8.0;

library MathUpgradeable {

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

pragma solidity >=0.6.0 <0.8.0;

library EnumerableSetUpgradeable {


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

pragma solidity >=0.6.2 <0.8.0;

library AddressUpgradeable {

    function isContract(address account) internal view returns (bool) {


        uint256 size;
        assembly { size := extcodesize(account) }
        return size > 0;
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

        return functionCallWithValue(target, data, 0, errorMessage);
    }

    function functionCallWithValue(address target, bytes memory data, uint256 value) internal returns (bytes memory) {

        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    function functionCallWithValue(address target, bytes memory data, uint256 value, string memory errorMessage) internal returns (bytes memory) {

        require(address(this).balance >= value, "Address: insufficient balance for call");
        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{ value: value }(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {

        return functionStaticCall(target, data, "Address: low-level static call failed");
    }

    function functionStaticCall(address target, bytes memory data, string memory errorMessage) internal view returns (bytes memory) {

        require(isContract(target), "Address: static call to non-contract");

        (bool success, bytes memory returndata) = target.staticcall(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function _verifyCallResult(bool success, bytes memory returndata, string memory errorMessage) private pure returns(bytes memory) {

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

pragma solidity >=0.4.24 <0.8.0;


abstract contract Initializable {

    bool private _initialized;

    bool private _initializing;

    modifier initializer() {
        require(_initializing || _isConstructor() || !_initialized, "Initializable: contract is already initialized");

        bool isTopLevelCall = !_initializing;
        if (isTopLevelCall) {
            _initializing = true;
            _initialized = true;
        }

        _;

        if (isTopLevelCall) {
            _initializing = false;
        }
    }

    function _isConstructor() private view returns (bool) {
        return !AddressUpgradeable.isContract(address(this));
    }
}// MIT

pragma solidity >=0.6.0 <0.8.0;

abstract contract ContextUpgradeable is Initializable {
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
}// MIT

pragma solidity >=0.6.0 <0.8.0;


abstract contract AccessControlUpgradeable is Initializable, ContextUpgradeable {
    function __AccessControl_init() internal initializer {
        __Context_init_unchained();
        __AccessControl_init_unchained();
    }

    function __AccessControl_init_unchained() internal initializer {
    }
    using EnumerableSetUpgradeable for EnumerableSetUpgradeable.AddressSet;
    using AddressUpgradeable for address;

    struct RoleData {
        EnumerableSetUpgradeable.AddressSet members;
        bytes32 adminRole;
    }

    mapping (bytes32 => RoleData) private _roles;

    bytes32 public constant DEFAULT_ADMIN_ROLE = 0x00;

    event RoleAdminChanged(bytes32 indexed role, bytes32 indexed previousAdminRole, bytes32 indexed newAdminRole);

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
        emit RoleAdminChanged(role, _roles[role].adminRole, adminRole);
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
}// MIT

pragma solidity >=0.6.0 <0.8.0;

interface IERC20Upgradeable {

    function totalSupply() external view returns (uint256);


    function balanceOf(address account) external view returns (uint256);


    function transfer(address recipient, uint256 amount) external returns (bool);


    function allowance(address owner, address spender) external view returns (uint256);


    function approve(address spender, uint256 amount) external returns (bool);


    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);


    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}// MIT

pragma solidity >=0.6.0 <0.8.0;


library SafeERC20Upgradeable {

    using SafeMathUpgradeable for uint256;
    using AddressUpgradeable for address;

    function safeTransfer(IERC20Upgradeable token, address to, uint256 value) internal {

        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(IERC20Upgradeable token, address from, address to, uint256 value) internal {

        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    function safeApprove(IERC20Upgradeable token, address spender, uint256 value) internal {

        require((value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(IERC20Upgradeable token, address spender, uint256 value) internal {

        uint256 newAllowance = token.allowance(address(this), spender).add(value);
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(IERC20Upgradeable token, address spender, uint256 value) internal {

        uint256 newAllowance = token.allowance(address(this), spender).sub(value, "SafeERC20: decreased allowance below zero");
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function _callOptionalReturn(IERC20Upgradeable token, bytes memory data) private {


        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) { // Return data is optional
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}// MIT

pragma solidity ^0.6.0;

interface IToken {

    function mint(address to, uint256 amount) external;


    function burn(address from, uint256 amount) external;

}// MIT

pragma solidity ^0.6.0;

interface IAuction {

    function callIncomeDailyTokensTrigger(uint256 amount) external;


    function callIncomeWeeklyTokensTrigger(uint256 amount) external;


    function addReservesToAuction(uint256 daysInFuture, uint256 amount) external returns(uint256);

}// MIT

pragma solidity ^0.6.0;

interface IStaking {

    function externalStake(
        uint256 amount,
        uint256 stakingDays,
        address staker
    ) external;


    function updateTokenPricePerShare(
        address payable bidderAddress,
        address payable originAddress,
        address tokenAddress,
        uint256 amountBought
    ) external payable;


    function addDivToken(address tokenAddress) external;

}// MIT

pragma solidity ^0.6.0;

interface IStakingV1 {

    function sessionDataOf(address, uint256)
        external view returns (uint256, uint256, uint256, uint256, uint256);


    function sessionsOf_(address)
        external view returns (uint256[] memory);

}// MIT

pragma solidity >=0.4.25 <0.7.0;



contract Staking is IStaking, Initializable, AccessControlUpgradeable {

    using SafeERC20Upgradeable for IERC20Upgradeable;
    using SafeMathUpgradeable for uint256;
    using EnumerableSetUpgradeable for EnumerableSetUpgradeable.AddressSet;

    event Stake(
        address indexed account,
        uint256 indexed sessionId,
        uint256 amount,
        uint256 start,
        uint256 end,
        uint256 shares
    );

    event MaxShareUpgrade(
        address indexed account,
        uint256 indexed sessionId,
        uint256 amount,
        uint256 newAmount,
        uint256 shares,
        uint256 newShares,
        uint256 start,
        uint256 end
    );

    event Unstake(
        address indexed account,
        uint256 indexed sessionId,
        uint256 amount,
        uint256 start,
        uint256 end,
        uint256 shares
    );

    event MakePayout(
        uint256 indexed value,
        uint256 indexed sharesTotalSupply,
        uint256 indexed time
    );

    event DailyBurn(
        uint256 indexed value,
        uint256 indexed totalSupply,
        uint256 indexed time
    );

    event AccountRegistered(
        address indexed account,
        uint256 indexed totalShares
    );

    event WithdrawLiquidDiv(
        address indexed account,
        address indexed tokenAddress,
        uint256 indexed interest
    );

    struct Payout {
        uint256 payout;
        uint256 sharesTotalSupply;
    }

    struct Session {
        uint256 amount;
        uint256 start;
        uint256 end;
        uint256 shares;
        uint256 firstPayout;
        uint256 lastPayout;
        bool withdrawn;
        uint256 payout;
    }

    struct Addresses {
        address mainToken;
        address auction;
        address subBalances;
    }

    struct BPDPool {
        uint96[5] pool;
        uint96[5] shares;
    }
    struct BPDPool128 {
        uint128[5] pool;
        uint128[5] shares;
    }

    Addresses public addresses;
    IStakingV1 public stakingV1;

    bytes32 public constant MIGRATOR_ROLE = keccak256('MIGRATOR_ROLE');
    bytes32 public constant EXTERNAL_STAKER_ROLE =
        keccak256('EXTERNAL_STAKER_ROLE');
    bytes32 public constant MANAGER_ROLE = keccak256('MANAGER_ROLE');

    uint256 public shareRate; //shareRate used to calculate the number of shares
    uint256 public sharesTotalSupply; //total shares supply
    uint256 public nextPayoutCall; //used to calculate when the daily makePayout() should run
    uint256 public stepTimestamp; // 24h * 60 * 60
    uint256 public startContract; //time the contract started
    uint256 public globalPayout;
    uint256 public globalPayin;
    uint256 public lastSessionId; //the ID of the last stake
    uint256 public lastSessionIdV1; //the ID of the last stake from layer 1 staking contract

    mapping(address => mapping(uint256 => Session)) public sessionDataOf;
    mapping(address => uint256[]) public sessionsOf;
    Payout[] public payouts;

    bool public init_;

    uint256 public basePeriod; //350 days, time of the first BPD
    uint256 public totalStakedAmount; //total amount of staked AXN

    bool private maxShareEventActive; //true if maxShare upgrade is enabled

    uint16 private maxShareMaxDays; //maximum number of days a stake length can be in order to qualify for maxShare upgrade
    uint256 private shareRateScalingFactor; //scaling factor, default 1 to be used on the shareRate calculation

    uint256 internal totalVcaRegisteredShares; //total number of shares from accounts that registered for the VCA

    mapping(address => uint256) internal tokenPricePerShare; //price per share for every token that is going to be offered as divident through the VCA
    EnumerableSetUpgradeable.AddressSet internal divTokens; //list of dividends tokens

    mapping(address => bool) internal isVcaRegistered;
    mapping(address => uint256) internal totalSharesOf;
    mapping(address => mapping(address => uint256)) internal deductBalances;

    bool internal paused;

    BPDPool bpd;
    BPDPool128 bpd128;

    modifier onlyManager() {

        require(hasRole(MANAGER_ROLE, _msgSender()), 'Caller is not a manager');
        _;
    }

    modifier onlyMigrator() {

        require(
            hasRole(MIGRATOR_ROLE, _msgSender()),
            'Caller is not a migrator'
        );
        _;
    }

    modifier onlyExternalStaker() {

        require(
            hasRole(EXTERNAL_STAKER_ROLE, _msgSender()),
            'Caller is not a external staker'
        );
        _;
    }

    modifier pausable() {

        require(
            paused == false || hasRole(MIGRATOR_ROLE, _msgSender()),
            'Contract is paused'
        );
        _;
    }

    function initialize(address _manager, address _migrator)
        public
        initializer
    {

        _setupRole(MANAGER_ROLE, _manager);
        _setupRole(MIGRATOR_ROLE, _migrator);
        init_ = false;
    }

    function sessionsOf_(address account)
        external
        view
        returns (uint256[] memory)
    {

        return sessionsOf[account];
    }

    function stake(uint256 amount, uint256 stakingDays) external pausable {

        require(stakingDays != 0, 'Staking: Staking days < 1');
        require(stakingDays <= 5555, 'Staking: Staking days > 5555');

        stakeInternal(amount, stakingDays, msg.sender);
        IToken(addresses.mainToken).burn(msg.sender, amount);
    }

    function externalStake(
        uint256 amount,
        uint256 stakingDays,
        address staker
    ) external override onlyExternalStaker pausable {

        require(stakingDays != 0, 'Staking: Staking days < 1');
        require(stakingDays <= 5555, 'Staking: Staking days > 5555');

        stakeInternal(amount, stakingDays, staker);
    }

    function stakeInternal(
        uint256 amount,
        uint256 stakingDays,
        address staker
    ) internal {

        if (now >= nextPayoutCall) makePayout();

        if (isVcaRegistered[staker] == false)
            setTotalSharesOfAccountInternal(staker);

        uint256 start = now;
        uint256 end = now.add(stakingDays.mul(stepTimestamp));

        lastSessionId = lastSessionId.add(1);

        stakeInternalCommon(
            lastSessionId,
            amount,
            start,
            end,
            stakingDays,
            payouts.length,
            staker
        );
    }

    function _initPayout(address to, uint256 amount) internal {

        IToken(addresses.mainToken).mint(to, amount);
    }

    function calculateStakingInterest(
        uint256 firstPayout,
        uint256 lastPayout,
        uint256 shares
    ) public view returns (uint256) {

        uint256 stakingInterest;
        uint256 lastIndex = MathUpgradeable.min(payouts.length, lastPayout);

        for (uint256 i = firstPayout; i < lastIndex; i++) {
            uint256 payout =
                payouts[i].payout.mul(shares).div(payouts[i].sharesTotalSupply);

            stakingInterest = stakingInterest.add(payout);
        }

        return stakingInterest;
    }

    function unstake(uint256 sessionId) external pausable {

        Session storage session = sessionDataOf[msg.sender][sessionId];

        require(
            session.shares != 0 && session.withdrawn == false,
            'Staking: Stake withdrawn or not set'
        );

        uint256 actualEnd = now;
        uint256 amountOut = unstakeInternal(session, sessionId, actualEnd);

        _initPayout(msg.sender, amountOut);
    }

    function unstakeV1(uint256 sessionId) external pausable {

        require(sessionId <= lastSessionIdV1, 'Staking: Invalid sessionId');

        Session storage session = sessionDataOf[msg.sender][sessionId];

        require(
            session.shares == 0 && session.withdrawn == false,
            'Staking: Stake withdrawn'
        );

        (
            uint256 amount,
            uint256 start,
            uint256 end,
            uint256 shares,
            uint256 firstPayout
        ) = stakingV1.sessionDataOf(msg.sender, sessionId);

        require(shares != 0, 'Staking: Stake withdrawn or not set');

        uint256 stakingDays = (end - start) / stepTimestamp;
        uint256 lastPayout = stakingDays + firstPayout;

        uint256 actualEnd = now;
        uint256 amountOut =
            unstakeV1Internal(
                sessionId,
                amount,
                start,
                end,
                actualEnd,
                shares,
                firstPayout,
                lastPayout
            );

        _initPayout(msg.sender, amountOut);
    }

    function getAmountOutAndPenalty(
        uint256 amount,
        uint256 start,
        uint256 end,
        uint256 stakingInterest
    ) public view returns (uint256, uint256) {

        uint256 stakingSeconds = end.sub(start);
        uint256 stakingDays = stakingSeconds.div(stepTimestamp);
        uint256 secondsStaked = now.sub(start);
        uint256 daysStaked = secondsStaked.div(stepTimestamp);
        uint256 amountAndInterest = amount.add(stakingInterest);

        if (stakingDays > daysStaked) {
            uint256 payOutAmount =
                amountAndInterest.mul(secondsStaked).div(stakingSeconds);

            uint256 earlyUnstakePenalty = amountAndInterest.sub(payOutAmount);

            return (payOutAmount, earlyUnstakePenalty);
        } else if (daysStaked < stakingDays.add(14)) {
            return (amountAndInterest, 0);
        } else if (daysStaked < stakingDays.add(714)) {
            return (amountAndInterest, 0);




        } else {
            return (0, amountAndInterest);
        }
    }

    function makePayout() public {

        require(now >= nextPayoutCall, 'Staking: Wrong payout time');

        uint256 payout = _getPayout();

        payouts.push(
            Payout({payout: payout, sharesTotalSupply: sharesTotalSupply})
        );

        nextPayoutCall = nextPayoutCall.add(stepTimestamp);

        updateShareRate(payout);

        emit MakePayout(payout, sharesTotalSupply, now);
    }

    function _getPayout() internal returns (uint256) {

        uint256 amountTokenInDay =
            IERC20Upgradeable(addresses.mainToken).balanceOf(address(this));
        IERC20Upgradeable(addresses.mainToken).transfer(
            0x000000000000000000000000000000000000dEaD,
            amountTokenInDay
        ); // Send to dead address
        uint256 balanceOfDead =
            IERC20Upgradeable(addresses.mainToken).balanceOf(
                0x000000000000000000000000000000000000dEaD
            );

        uint256 currentTokenTotalSupply =
            (IERC20Upgradeable(addresses.mainToken).totalSupply());

        uint256 inflation =
            uint256(8)
                .mul(
                currentTokenTotalSupply.sub(balanceOfDead).add(
                    totalStakedAmount
                )
            )
                .div(36500);

        emit DailyBurn(amountTokenInDay, currentTokenTotalSupply, now);
        return inflation;
    }

    function _getStakersSharesAmount(
        uint256 amount,
        uint256 start,
        uint256 end
    ) internal view returns (uint256) {

        uint256 stakingDays = (end.sub(start)).div(stepTimestamp);
        uint256 numerator = amount.mul(uint256(1819).add(stakingDays));
        uint256 denominator = uint256(1820).mul(shareRate);

        return (numerator).mul(1e18).div(denominator);
    }

    function _getShareRate(
        uint256 amount,
        uint256 shares,
        uint256 start,
        uint256 end,
        uint256 stakingInterest
    ) internal view returns (uint256) {

        uint256 stakingDays = (end.sub(start)).div(stepTimestamp);

        uint256 numerator =
            (amount.add(stakingInterest)).mul(uint256(1819).add(stakingDays));

        uint256 denominator = uint256(1820).mul(shares);

        return (numerator).mul(1e18).div(denominator);
    }

    function restake(
        uint256 sessionId,
        uint256 stakingDays,
        uint256 topup
    ) external pausable {

        require(stakingDays != 0, 'Staking: Staking days < 1');
        require(stakingDays <= 5555, 'Staking: Staking days > 5555');

        Session storage session = sessionDataOf[msg.sender][sessionId];

        require(
            session.shares != 0 && session.withdrawn == false,
            'Staking: Stake withdrawn/invalid'
        );

        uint256 actualEnd = now;

        require(session.end <= actualEnd, 'Staking: Stake not mature');

        uint256 amountOut = unstakeInternal(session, sessionId, actualEnd);

        if (topup != 0) {
            IToken(addresses.mainToken).burn(msg.sender, topup);
            amountOut = amountOut.add(topup);
        }

        stakeInternal(amountOut, stakingDays, msg.sender);
    }

    function restakeV1(
        uint256 sessionId,
        uint256 stakingDays,
        uint256 topup
    ) external pausable {

        require(sessionId <= lastSessionIdV1, 'Staking: Invalid sessionId');
        require(stakingDays != 0, 'Staking: Staking days < 1');
        require(stakingDays <= 5555, 'Staking: Staking days > 5555');

        Session storage session = sessionDataOf[msg.sender][sessionId];

        require(
            session.shares == 0 && session.withdrawn == false,
            'Staking: Stake withdrawn'
        );

        (
            uint256 amount,
            uint256 start,
            uint256 end,
            uint256 shares,
            uint256 firstPayout
        ) = stakingV1.sessionDataOf(msg.sender, sessionId);

        require(shares != 0, 'Staking: Stake withdrawn');

        uint256 actualEnd = now;

        require(end <= actualEnd, 'Staking: Stake not mature');

        uint256 sessionStakingDays = (end - start) / stepTimestamp;
        uint256 lastPayout = sessionStakingDays + firstPayout;

        uint256 amountOut =
            unstakeV1Internal(
                sessionId,
                amount,
                start,
                end,
                actualEnd,
                shares,
                firstPayout,
                lastPayout
            );

        if (topup != 0) {
            IToken(addresses.mainToken).burn(msg.sender, topup);
            amountOut = amountOut.add(topup);
        }

        stakeInternal(amountOut, stakingDays, msg.sender);
    }

    function unstakeInternal(
        Session storage session,
        uint256 sessionId,
        uint256 actualEnd
    ) internal returns (uint256) {

        uint256 amountOut =
            unstakeInternalCommon(
                sessionId,
                session.amount,
                session.start,
                session.end,
                actualEnd,
                session.shares,
                session.firstPayout,
                session.lastPayout
            );

        session.end = actualEnd;
        session.withdrawn = true;
        session.payout = amountOut;

        return amountOut;
    }

    function unstakeV1Internal(
        uint256 sessionId,
        uint256 amount,
        uint256 start,
        uint256 end,
        uint256 actualEnd,
        uint256 shares,
        uint256 firstPayout,
        uint256 lastPayout
    ) internal returns (uint256) {

        uint256 amountOut =
            unstakeInternalCommon(
                sessionId,
                amount,
                start,
                end,
                actualEnd,
                shares,
                firstPayout,
                lastPayout
            );

        sessionDataOf[msg.sender][sessionId] = Session({
            amount: amount,
            start: start,
            end: actualEnd,
            shares: shares,
            firstPayout: firstPayout,
            lastPayout: lastPayout,
            withdrawn: true,
            payout: amountOut
        });

        sessionsOf[msg.sender].push(sessionId);

        return amountOut;
    }

    function unstakeInternalCommon(
        uint256 sessionId,
        uint256 amount,
        uint256 start,
        uint256 end,
        uint256 actualEnd,
        uint256 shares,
        uint256 firstPayout,
        uint256 lastPayout
    ) internal returns (uint256) {

        if (now >= nextPayoutCall) makePayout();
        if (isVcaRegistered[msg.sender] == false)
            setTotalSharesOfAccountInternal(msg.sender);

        uint256 stakingInterest =
            calculateStakingInterest(firstPayout, lastPayout, shares);

        sharesTotalSupply = sharesTotalSupply.sub(shares);
        totalStakedAmount = totalStakedAmount.sub(amount);
        totalVcaRegisteredShares = totalVcaRegisteredShares.sub(shares);

        uint256 oldTotalSharesOf = totalSharesOf[msg.sender];
        totalSharesOf[msg.sender] = totalSharesOf[msg.sender].sub(shares);

        rebalance(msg.sender, oldTotalSharesOf);

        (uint256 amountOut, uint256 penalty) =
            getAmountOutAndPenalty(amount, start, end, stakingInterest);

        uint256 stakingDays = (actualEnd - start) / stepTimestamp;
        if (stakingDays >= basePeriod) {
            uint256 bpdAmount =
                calcBPD(start, actualEnd < end ? actualEnd : end, shares);
            amountOut = amountOut.add(bpdAmount);
        }


        emit Unstake(
            msg.sender,
            sessionId,
            amountOut,
            start,
            actualEnd,
            shares
        );

        return amountOut;
    }

    function stakeInternalCommon(
        uint256 sessionId,
        uint256 amount,
        uint256 start,
        uint256 end,
        uint256 stakingDays,
        uint256 firstPayout,
        address staker
    ) internal {

        uint256 shares = _getStakersSharesAmount(amount, start, end);

        sharesTotalSupply = sharesTotalSupply.add(shares);
        totalStakedAmount = totalStakedAmount.add(amount);
        totalVcaRegisteredShares = totalVcaRegisteredShares.add(shares);

        uint256 oldTotalSharesOf = totalSharesOf[staker];
        totalSharesOf[staker] = totalSharesOf[staker].add(shares);

        rebalance(staker, oldTotalSharesOf);

        sessionDataOf[staker][sessionId] = Session({
            amount: amount,
            start: start,
            end: end,
            shares: shares,
            firstPayout: firstPayout,
            lastPayout: firstPayout + stakingDays,
            withdrawn: false,
            payout: 0
        });

        sessionsOf[staker].push(sessionId);

        addBPDShares(shares, start, end);

        emit Stake(staker, sessionId, amount, start, end, shares);
    }

    function withdrawDivToken(address tokenAddress) external pausable {

        withdrawDivTokenInternal(tokenAddress, totalSharesOf[msg.sender]);
    }

    function withdrawDivTokenInternal(
        address tokenAddress,
        uint256 _totalSharesOf
    ) internal {

        uint256 tokenInterestEarned =
            getTokenInterestEarnedInternal(
                msg.sender,
                tokenAddress,
                _totalSharesOf
            );

        deductBalances[msg.sender][tokenAddress] = totalSharesOf[msg.sender]
            .mul(tokenPricePerShare[tokenAddress]);

        if (
            tokenAddress != address(0xFFfFfFffFFfffFFfFFfFFFFFffFFFffffFfFFFfF)
        ) {
            IERC20Upgradeable(tokenAddress).transfer(
                msg.sender,
                tokenInterestEarned
            );
        } else {
            msg.sender.transfer(tokenInterestEarned);
        }

        emit WithdrawLiquidDiv(msg.sender, tokenAddress, tokenInterestEarned);
    }

    function getTokenInterestEarned(
        address accountAddress,
        address tokenAddress
    ) external view returns (uint256) {

        return
            getTokenInterestEarnedInternal(
                accountAddress,
                tokenAddress,
                totalSharesOf[accountAddress]
            );
    }

    function getTokenInterestEarnedInternal(
        address accountAddress,
        address tokenAddress,
        uint256 _totalSharesOf
    ) internal view returns (uint256) {

        return
            _totalSharesOf
                .mul(tokenPricePerShare[tokenAddress])
                .sub(deductBalances[accountAddress][tokenAddress])
                .div(10**36); //we divide since we multiplied the price by 10**36 for precision
    }

    function rebalance(address staker, uint256 oldTotalSharesOf) internal {

        for (uint8 i = 0; i < divTokens.length(); i++) {
            uint256 tokenInterestEarned =
                oldTotalSharesOf.mul(tokenPricePerShare[divTokens.at(i)]).sub(
                    deductBalances[staker][divTokens.at(i)]
                );

            if (
                totalSharesOf[staker].mul(tokenPricePerShare[divTokens.at(i)]) <
                tokenInterestEarned
            ) {
                withdrawDivTokenInternal(divTokens.at(i), oldTotalSharesOf);
            } else {
                deductBalances[staker][divTokens.at(i)] = totalSharesOf[staker]
                    .mul(tokenPricePerShare[divTokens.at(i)])
                    .sub(tokenInterestEarned);
            }
        }
    }

    function setTotalSharesOfAccountInternal(address account)
        internal
        pausable
    {

        require(
            isVcaRegistered[account] == false ||
                hasRole(MIGRATOR_ROLE, msg.sender),
            'STAKING: Account already registered.'
        );

        uint256 totalShares;
        uint256[] storage sessionsOfAccount = sessionsOf[account];

        for (uint256 i = 0; i < sessionsOfAccount.length; i++) {
            if (sessionDataOf[account][sessionsOfAccount[i]].withdrawn)
                continue;

            totalShares = totalShares.add( //sum total shares
                sessionDataOf[account][sessionsOfAccount[i]].shares
            );
        }

        uint256[] memory v1SessionsOfAccount = stakingV1.sessionsOf_(account);

        for (uint256 i = 0; i < v1SessionsOfAccount.length; i++) {
            if (sessionDataOf[account][v1SessionsOfAccount[i]].shares != 0)
                continue;

            if (v1SessionsOfAccount[i] > lastSessionIdV1) continue; //make sure we only take layer 1 stakes in consideration

            (
                uint256 amount,
                uint256 start,
                uint256 end,
                uint256 shares,
                uint256 firstPayout
            ) = stakingV1.sessionDataOf(account, v1SessionsOfAccount[i]);

            (amount);
            (start);
            (end);
            (firstPayout);

            if (shares == 0) continue;

            totalShares = totalShares.add(shares); //calclate total shares
        }

        isVcaRegistered[account] = true; //confirm the registration was completed

        if (totalShares != 0) {
            totalSharesOf[account] = totalShares;
            totalVcaRegisteredShares = totalVcaRegisteredShares.add( //update the global total number of VCA registered shares
                totalShares
            );

            for (uint256 i = 0; i < divTokens.length(); i++) {
                deductBalances[account][divTokens.at(i)] = totalShares.mul(
                    tokenPricePerShare[divTokens.at(i)]
                );
            }
        }

        emit AccountRegistered(account, totalShares);
    }

    function setTotalSharesOfAccount(address _address) external {

        setTotalSharesOfAccountInternal(_address);
    }

    function updateTokenPricePerShare(
        address payable bidderAddress,
        address payable originAddress,
        address tokenAddress,
        uint256 amountBought
    ) external payable override onlyExternalStaker {

        if (tokenAddress != addresses.mainToken) {
            tokenPricePerShare[tokenAddress] = tokenPricePerShare[tokenAddress]
                .add(amountBought.mul(10**36).div(totalVcaRegisteredShares)); //increase the token price per share with the amount bought divided by the total Vca registered shares
        }
    }

    function addDivToken(address tokenAddress)
        external
        override
        onlyExternalStaker
    {

        if (
            !divTokens.contains(tokenAddress) &&
            tokenAddress != addresses.mainToken
        ) {
            divTokens.add(tokenAddress);
        }
    }

    function updateShareRate(uint256 _payout) internal {

        uint256 currentTokenTotalSupply =
            IERC20Upgradeable(addresses.mainToken).totalSupply();

        uint256 growthFactor =
            _payout.mul(1e18).div(
                currentTokenTotalSupply + totalStakedAmount + 1 //we calculate the total AXN supply as circulating + staked
            );

        if (shareRateScalingFactor == 0) {
            shareRateScalingFactor = 1;
        }

        shareRate = shareRate
            .mul(1e18 + shareRateScalingFactor.mul(growthFactor)) //1e18 used for precision.
            .div(1e18);
    }

    function setShareRateScalingFactor(uint256 _scalingFactor)
        external
        onlyManager
    {

        shareRateScalingFactor = _scalingFactor;
    }

    function maxShare(uint256 sessionId) external pausable {

        Session storage session = sessionDataOf[msg.sender][sessionId];

        require(
            session.shares != 0 && session.withdrawn == false,
            'STAKING: Stake withdrawn or not set'
        );

        (
            uint256 newStart,
            uint256 newEnd,
            uint256 newAmount,
            uint256 newShares
        ) =
            maxShareUpgrade(
                session.firstPayout,
                session.lastPayout,
                session.shares,
                session.amount
            );

        addBPDMaxShares(
            session.shares,
            session.start,
            session.end,
            newShares,
            newStart,
            newEnd
        );

        maxShareInternal(
            sessionId,
            session.shares,
            newShares,
            session.amount,
            newAmount,
            newStart,
            newEnd
        );

        sessionDataOf[msg.sender][sessionId].amount = newAmount;
        sessionDataOf[msg.sender][sessionId].end = newEnd;
        sessionDataOf[msg.sender][sessionId].start = newStart;
        sessionDataOf[msg.sender][sessionId].shares = newShares;
        sessionDataOf[msg.sender][sessionId].firstPayout = payouts.length;
        sessionDataOf[msg.sender][sessionId].lastPayout = payouts.length + 5555;
    }

    function maxShareV1(uint256 sessionId) external pausable {

        require(sessionId <= lastSessionIdV1, 'STAKING: Invalid sessionId');

        Session storage session = sessionDataOf[msg.sender][sessionId];

        require(
            session.shares == 0 && session.withdrawn == false,
            'STAKING: Stake withdrawn'
        );

        (
            uint256 amount,
            uint256 start,
            uint256 end,
            uint256 shares,
            uint256 firstPayout
        ) = stakingV1.sessionDataOf(msg.sender, sessionId);

        require(shares != 0, 'STAKING: Stake withdrawn v1');

        uint256 stakingDays = (end - start) / stepTimestamp;
        uint256 lastPayout = stakingDays + firstPayout;

        (
            uint256 newStart,
            uint256 newEnd,
            uint256 newAmount,
            uint256 newShares
        ) = maxShareUpgrade(firstPayout, lastPayout, shares, amount);

        addBPDMaxShares(shares, start, end, newShares, newStart, newEnd);

        maxShareInternal(
            sessionId,
            shares,
            newShares,
            amount,
            newAmount,
            newStart,
            newEnd
        );

        sessionDataOf[msg.sender][sessionId] = Session({
            amount: newAmount,
            start: newStart,
            end: newEnd,
            shares: newShares,
            firstPayout: payouts.length,
            lastPayout: payouts.length + 5555,
            withdrawn: false,
            payout: 0
        });

        sessionsOf[msg.sender].push(sessionId);
    }

    function maxShareUpgrade(
        uint256 firstPayout,
        uint256 lastPayout,
        uint256 shares,
        uint256 amount
    )
        internal
        view
        returns (
            uint256,
            uint256,
            uint256,
            uint256
        )
    {

        require(
            maxShareEventActive == true,
            'STAKING: Max Share event is not active'
        );
        require(
            lastPayout - firstPayout <= maxShareMaxDays,
            'STAKING: Max Share Upgrade - Stake must be less then max share max days'
        );

        uint256 stakingInterest =
            calculateStakingInterest(firstPayout, lastPayout, shares);

        uint256 newStart = now;
        uint256 newEnd = newStart + (stepTimestamp * 5555);
        uint256 newAmount = stakingInterest + amount;
        uint256 newShares =
            _getStakersSharesAmount(newAmount, newStart, newEnd);

        require(
            newShares > shares,
            'STAKING: New shares are not greater then previous shares'
        );

        return (newStart, newEnd, newAmount, newShares);
    }

    function maxShareInternal(
        uint256 sessionId,
        uint256 oldShares,
        uint256 newShares,
        uint256 oldAmount,
        uint256 newAmount,
        uint256 newStart,
        uint256 newEnd
    ) internal {

        if (now >= nextPayoutCall) makePayout();
        if (isVcaRegistered[msg.sender] == false)
            setTotalSharesOfAccountInternal(msg.sender);

        sharesTotalSupply = sharesTotalSupply.add(newShares - oldShares);
        totalStakedAmount = totalStakedAmount.add(newAmount - oldAmount);
        totalVcaRegisteredShares = totalVcaRegisteredShares.add(
            newShares - oldShares
        );

        uint256 oldTotalSharesOf = totalSharesOf[msg.sender];
        totalSharesOf[msg.sender] = totalSharesOf[msg.sender].add(
            newShares - oldShares
        );

        rebalance(msg.sender, oldTotalSharesOf);

        emit MaxShareUpgrade(
            msg.sender,
            sessionId,
            oldAmount,
            newAmount,
            oldShares,
            newShares,
            newStart,
            newEnd
        );
    }

    function calculateStepsFromStart() public view returns (uint256) {

        return now.sub(startContract).div(stepTimestamp);
    }

    function setMaxShareEventActive(bool _active) external onlyManager {

        maxShareEventActive = _active;
    }

    function getMaxShareEventActive() external view returns (bool) {

        return maxShareEventActive;
    }

    function setMaxShareMaxDays(uint16 _maxShareMaxDays) external onlyManager {

        maxShareMaxDays = _maxShareMaxDays;
    }

    function setTotalVcaRegisteredShares(uint256 _shares)
        external
        onlyMigrator
    {

        totalVcaRegisteredShares = _shares;
    }

    function setPaused(bool _paused) external {

        require(
            hasRole(MIGRATOR_ROLE, msg.sender) ||
                hasRole(MANAGER_ROLE, msg.sender),
            'STAKING: User must be manager or migrator'
        );
        paused = _paused;
    }

    function getPaused() external view returns (bool) {

        return paused;
    }

    function getMaxShareMaxDays() external view returns (uint16) {

        return maxShareMaxDays;
    }

    function setupRole(bytes32 role, address account) external onlyManager {

        _setupRole(role, account);
    }

    function getDivTokens() external view returns (address[] memory) {

        address[] memory divTokenAddresses = new address[](divTokens.length());

        for (uint8 i = 0; i < divTokens.length(); i++) {
            divTokenAddresses[i] = divTokens.at(i);
        }

        return divTokenAddresses;
    }

    function getTotalSharesOf(address account) external view returns (uint256) {

        return totalSharesOf[account];
    }

    function getTotalVcaRegisteredShares() external view returns (uint256) {

        return totalVcaRegisteredShares;
    }

    function getIsVCARegistered(address staker) external view returns (bool) {

        return isVcaRegistered[staker];
    }

    function setBPDPools(
        uint128[5] calldata poolAmount,
        uint128[5] calldata poolShares
    ) external onlyMigrator {

        for (uint8 i = 0; i < poolAmount.length; i++) {
            bpd128.pool[i] = poolAmount[i];
            bpd128.shares[i] = poolShares[i];
        }
    }

    function findBPDEligible(uint256 starttime, uint256 endtime)
        external
        view
        returns (uint16[2] memory)
    {

        return findBPDs(starttime, endtime);
    }

    function findBPDs(uint256 starttime, uint256 endtime)
        internal
        view
        returns (uint16[2] memory)
    {

        uint16[2] memory bpdInterval;
        uint256 denom = stepTimestamp.mul(350);
        bpdInterval[0] = uint16(
            MathUpgradeable.min(5, starttime.sub(startContract).div(denom))
        ); // (starttime - t0) // 350
        uint256 bpdEnd =
            uint256(bpdInterval[0]) + endtime.sub(starttime).div(denom);
        bpdInterval[1] = uint16(MathUpgradeable.min(bpdEnd, 5)); // bpd_first + nx350

        return bpdInterval;
    }

    function addBPDMaxShares(
        uint256 oldShares,
        uint256 oldStart,
        uint256 oldEnd,
        uint256 newShares,
        uint256 newStart,
        uint256 newEnd
    ) internal {

        uint16[2] memory oldBpdInterval = findBPDs(oldStart, oldEnd);
        uint16[2] memory newBpdInterval = findBPDs(newStart, newEnd);
        for (uint16 i = oldBpdInterval[0]; i < newBpdInterval[1]; i++) {
            uint256 shares = newShares;
            if (oldBpdInterval[1] > i) {
                shares = shares.sub(oldShares);
            }
            bpd128.shares[i] += uint128(shares); // we only do integer shares, no decimals
        }
    }

    function addBPDShares(
        uint256 shares,
        uint256 starttime,
        uint256 endtime
    ) internal {

        uint16[2] memory bpdInterval = findBPDs(starttime, endtime);
        for (uint16 i = bpdInterval[0]; i < bpdInterval[1]; i++) {
            bpd128.shares[i] += uint128(shares); // we only do integer shares, no decimals
        }
    }

    function calcBPDOnWithdraw(uint256 shares, uint16[2] memory bpdInterval)
        internal
        view
        returns (uint256)
    {

        uint256 bpdAmount;
        uint256 shares1e18 = shares.mul(1e18);
        for (uint16 i = bpdInterval[0]; i < bpdInterval[1]; i++) {
            bpdAmount += shares1e18.div(bpd128.shares[i]).mul(bpd128.pool[i]);
        }

        return bpdAmount.div(1e18);
    }

    function calcBPD(
        uint256 start,
        uint256 end,
        uint256 shares
    ) public view returns (uint256) {

        uint16[2] memory bpdInterval = findBPDs(start, end);
        return calcBPDOnWithdraw(shares, bpdInterval);
    }

    function getBPD()
        external
        view
        returns (uint128[5] memory, uint128[5] memory)
    {

        return (bpd128.pool, bpd128.shares);
    }

    function getDeductBalances(address account, address token)
        external
        view
        returns (uint256)
    {

        return deductBalances[account][token];
    }

    function getTokenPricePerShare(address token)
        external
        view
        returns (uint256)
    {

        return tokenPricePerShare[token];
    }

    function recover(
        address recoverFor,
        address tokenToRecover,
        uint256 amount
    ) external onlyMigrator {

        IERC20Upgradeable(tokenToRecover).transfer(recoverFor, amount);
    }

    function safeRecover(
        address recoverFor,
        address tokenToRecover,
        uint256 amount
    ) external onlyMigrator {

        IERC20Upgradeable(tokenToRecover).safeTransfer(recoverFor, amount);
    }
}