


pragma solidity ^0.6.0;
pragma experimental ABIEncoderV2;

library SafeMathUpgradeable {

    function add(uint256 a, uint256 b) internal pure returns (uint256) {

        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {

        return sub(a, b, "SafeMath: subtraction overflow");
    }

    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {

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

    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {

        require(b > 0, errorMessage);
        uint256 c = a / b;

        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {

        return mod(a, b, "SafeMath: modulo by zero");
    }

    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {

        require(b != 0, errorMessage);
        return a % b;
    }
}



interface IERC20Upgradeable {

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
}



library AddressUpgradeable {

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

        return _functionCallWithValue(target, data, 0, errorMessage);
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
        return _functionCallWithValue(target, data, value, errorMessage);
    }

    function _functionCallWithValue(
        address target,
        bytes memory data,
        uint256 weiValue,
        string memory errorMessage
    ) private returns (bytes memory) {

        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{value: weiValue}(data);
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




library SafeERC20Upgradeable {

    using SafeMathUpgradeable for uint256;
    using AddressUpgradeable for address;

    function safeTransfer(
        IERC20Upgradeable token,
        address to,
        uint256 value
    ) internal {

        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(
        IERC20Upgradeable token,
        address from,
        address to,
        uint256 value
    ) internal {

        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    function safeApprove(
        IERC20Upgradeable token,
        address spender,
        uint256 value
    ) internal {

        require((value == 0) || (token.allowance(address(this), spender) == 0), "SafeERC20: approve from non-zero to non-zero allowance");
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(
        IERC20Upgradeable token,
        address spender,
        uint256 value
    ) internal {

        uint256 newAllowance = token.allowance(address(this), spender).add(value);
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(
        IERC20Upgradeable token,
        address spender,
        uint256 value
    ) internal {

        uint256 newAllowance = token.allowance(address(this), spender).sub(value, "SafeERC20: decreased allowance below zero");
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function _callOptionalReturn(IERC20Upgradeable token, bytes memory data) private {


        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) {
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}



library EnumerableSetUpgradeable {


    struct Set {
        bytes32[] _values;
        mapping(bytes32 => uint256) _indexes;
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

        if (valueIndex != 0) {

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
        address self = address(this);
        uint256 cs;
        assembly {
            cs := extcodesize(self)
        }
        return cs == 0;
    }
}



abstract contract ContextUpgradeable is Initializable {
    function __Context_init() internal initializer {
        __Context_init_unchained();
    }

    function __Context_init_unchained() internal initializer {}

    function _msgSender() internal virtual view returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal virtual view returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }

    uint256[50] private __gap;
}




abstract contract AccessControlUpgradeable is Initializable, ContextUpgradeable {
    function __AccessControl_init() internal initializer {
        __Context_init_unchained();
        __AccessControl_init_unchained();
    }

    function __AccessControl_init_unchained() internal initializer {}

    using EnumerableSetUpgradeable for EnumerableSetUpgradeable.AddressSet;
    using AddressUpgradeable for address;

    struct RoleData {
        EnumerableSetUpgradeable.AddressSet members;
        bytes32 adminRole;
    }

    mapping(bytes32 => RoleData) private _roles;

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
}


// pragma experimental ABIEncoderV2;



contract BadgerGeyser is Initializable, AccessControlUpgradeable {

    using SafeERC20Upgradeable for IERC20Upgradeable;
    using SafeMathUpgradeable for uint256;
    using EnumerableSetUpgradeable for EnumerableSetUpgradeable.AddressSet;

    struct UnlockSchedule {
        uint256 initialLocked;
        uint256 endAtSec;
        uint256 durationSec;
        uint256 startTime;
    }

    uint256 public globalStartTime;

    uint256 public constant MAX_PERCENTAGE = 100;
    bytes32 public constant TOKEN_LOCKER_ROLE = keccak256("TOKEN_LOCKER_ROLE");

    uint256 public totalStaked;

    IERC20Upgradeable internal _stakingToken;
    EnumerableSetUpgradeable.AddressSet distributionTokens;

    mapping(address => uint256) internal _userTotals;
    mapping(address => UnlockSchedule[]) public unlockSchedules;

    event Staked(address indexed user, uint256 amount, uint256 total, uint256 indexed timestamp, uint256 indexed blockNumber, bytes data);
    event Unstaked(address indexed user, uint256 amount, uint256 total, uint256 indexed timestamp, uint256 indexed blockNumber, bytes data);
    event UnlockScheduleSet(address token, uint256 index, uint256 initialLocked, uint256 durationSec, uint256 startTime, uint256 endTime);
    event TokensLocked(
        address indexed token,
        uint256 amount,
        uint256 durationSec,
        uint256 startTime,
        uint256 endTime,
        uint256 indexed timestamp,
        bytes data
    );

    function initialize(
        IERC20Upgradeable stakingToken_,
        address initialDistributionToken_,
        uint256 globalStartTime_,
        address initialAdmin_,
        address initialTokenLocker_
    ) public initializer {

        __AccessControl_init();

        _setupRole(DEFAULT_ADMIN_ROLE, initialAdmin_);
        _setupRole(TOKEN_LOCKER_ROLE, initialTokenLocker_);

        _stakingToken = stakingToken_;
        distributionTokens.add(initialDistributionToken_);

        globalStartTime = globalStartTime_;
    }


    function _onlyAfterStart() internal {

        require(now >= globalStartTime, "BadgerGeyser: Distribution not started");
    }

    function _onlyAdmin() internal {

        require(hasRole(DEFAULT_ADMIN_ROLE, msg.sender), "onlyAdmin");
    }

    function _onlyTokenLocker() internal {

        require(hasRole(TOKEN_LOCKER_ROLE, msg.sender), "onlyTokenLocker");
    }


    function supportsHistory() external pure returns (bool) {

        return false;
    }

    function getStakingToken() public view returns (IERC20Upgradeable) {

        return _stakingToken;
    }

    function getDistributionTokens() public view returns (address[] memory) {

        uint256 numTokens = distributionTokens.length();
        address[] memory tokens = new address[](numTokens);

        for (uint256 i = 0; i < numTokens; i++) {
            tokens[i] = distributionTokens.at(i);
        }

        return tokens;
    }

    function getNumDistributionTokens() public view returns (uint256) {

        return distributionTokens.length();
    }

    function totalStakedFor(address addr) public view returns (uint256) {

        return _userTotals[addr];
    }

    function unlockScheduleCount(address token) public view returns (uint256) {

        return unlockSchedules[token].length;
    }

    function getUnlockSchedulesFor(address token) public view returns (UnlockSchedule[] memory) {

        return unlockSchedules[token];
    }


    function stake(uint256 amount, bytes calldata data) external {

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

    function unstake(uint256 amount, bytes calldata data) external {

        _onlyAfterStart();
        _unstakeFor(msg.sender, amount);
    }


    function addDistributionToken(address token) external {

        _onlyAdmin();
        distributionTokens.add(token);
    }

    function modifyTokenLock(
        address token,
        uint256 index,
        uint256 amount,
        uint256 durationSec,
        uint256 startTime
    ) external {

        _onlyTokenLocker();
        require(startTime >= globalStartTime, "BadgerGeyser: Schedule cannot start before global start time");
        require(distributionTokens.contains(token), "BadgerGeyser: Token not approved by admin");

        _modifyTokenLock(token, index, amount, durationSec, startTime);
    }


    function signalTokenLock(
        address token,
        uint256 amount,
        uint256 durationSec,
        uint256 startTime
    ) external {

        _onlyTokenLocker();
        require(startTime >= globalStartTime, "BadgerGeyser: Schedule cannot start before global start time");
        require(distributionTokens.contains(token), "BadgerGeyser: Token not approved by admin");

        _signalTokenLock(token, amount, durationSec, startTime);
    }


    function _stakeFor(
        address staker,
        address beneficiary,
        uint256 amount
    ) internal {

        require(amount > 0, "BadgerGeyser: stake amount is zero");
        require(beneficiary != address(0), "BadgerGeyser: beneficiary is zero address");

        _userTotals[beneficiary] = _userTotals[beneficiary].add(amount);

        totalStaked = totalStaked.add(amount);

        _stakingToken.safeTransferFrom(staker, address(this), amount);

        emit Staked(beneficiary, amount, totalStakedFor(beneficiary), now, block.number, "");
    }

    function _unstakeFor(address user, uint256 amount) internal {

        require(amount > 0, "BadgerGeyser: unstake amount is zero");
        require(totalStakedFor(user) >= amount, "BadgerGeyser: unstake amount is greater than total user stakes");

        _userTotals[user] = _userTotals[user].sub(amount);

        totalStaked = totalStaked.sub(amount);

        _stakingToken.safeTransfer(user, amount);

        emit Unstaked(user, amount, totalStakedFor(user), now, block.number, "");
    }

    function _signalTokenLock(
        address token,
        uint256 amount,
        uint256 durationSec,
        uint256 startTime
    ) internal {

        UnlockSchedule memory schedule;
        schedule.initialLocked = amount;
        schedule.endAtSec = startTime.add(durationSec);
        schedule.durationSec = durationSec;
        schedule.startTime = startTime;
        unlockSchedules[token].push(schedule);

        emit TokensLocked(token, amount, durationSec, startTime, schedule.endAtSec, now, "");
        emit UnlockScheduleSet(token, unlockSchedules[token].length, amount, durationSec, startTime, schedule.endAtSec);
    }

    function _modifyTokenLock(
        address token,
        uint256 index,
        uint256 amount,
        uint256 durationSec,
        uint256 startTime
    ) internal {

        UnlockSchedule storage schedule = unlockSchedules[token][index];

        schedule.initialLocked = amount;
        schedule.endAtSec = startTime.add(durationSec);
        schedule.durationSec = durationSec;
        schedule.startTime = startTime;

        emit UnlockScheduleSet(token, index, amount, durationSec, startTime, startTime.add(durationSec));
    }
}