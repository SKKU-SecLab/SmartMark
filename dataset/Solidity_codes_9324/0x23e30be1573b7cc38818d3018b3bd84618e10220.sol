


pragma solidity =0.6.12;

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
        return _verifyCallResult(success, returndata, errorMessage);
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
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function _verifyCallResult(
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) private pure returns (bytes memory) {

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

interface IERC20 {

    function name() external view returns (string memory);


    function symbol() external view returns (string memory);


    function decimals() external view returns (uint8);


    function totalSupply() external view returns (uint);


    function balanceOf(address owner) external view returns (uint);


    function allowance(address owner, address spender) external view returns (uint);


    function transfer(address to, uint value) external returns (bool);


    function approve(address spender, uint value) external returns (bool);


    function transferFrom(
        address from,
        address to,
        uint value
    ) external returns (bool);


    event Transfer(address indexed from, address indexed to, uint value);

    event Approval(address indexed owner, address indexed spender, uint value);
}

interface LnPrices {

    function getPrice(bytes32 currencyName) external view returns (uint);


    function getPriceAndUpdatedTime(bytes32 currencyName) external view returns (uint price, uint time);


    function isStale(bytes32 currencyName) external view returns (bool);


    function stalePeriod() external view returns (uint);


    function exchange(
        bytes32 sourceName,
        uint sourceAmount,
        bytes32 destName
    ) external view returns (uint);


    function exchangeAndPrices(
        bytes32 sourceName,
        uint sourceAmount,
        bytes32 destName
    )
        external
        view
        returns (
            uint value,
            uint sourcePrice,
            uint destPrice
        );


    function LUSD() external view returns (bytes32);


    function LINA() external view returns (bytes32);

}

abstract contract LnBasePrices is LnPrices {
    bytes32 public constant override LINA = "LINA";
    bytes32 public constant override LUSD = "lUSD";
}

contract LnAdminUpgradeable is Initializable {

    event CandidateChanged(address oldCandidate, address newCandidate);
    event AdminChanged(address oldAdmin, address newAdmin);

    address public admin;
    address public candidate;

    function __LnAdminUpgradeable_init(address _admin) public initializer {

        require(_admin != address(0), "LnAdminUpgradeable: zero address");
        admin = _admin;
        emit AdminChanged(address(0), _admin);
    }

    function setCandidate(address _candidate) external onlyAdmin {

        address old = candidate;
        candidate = _candidate;
        emit CandidateChanged(old, candidate);
    }

    function becomeAdmin() external {

        require(msg.sender == candidate, "LnAdminUpgradeable: only candidate can become admin");
        address old = admin;
        admin = candidate;
        emit AdminChanged(old, admin);
    }

    modifier onlyAdmin {

        require((msg.sender == admin), "LnAdminUpgradeable: only the contract admin can perform this action");
        _;
    }

    uint256[48] private __gap;
}

contract LnRewardLocker is LnAdminUpgradeable {

    using SafeMath for uint256;

    struct RewardData {
        uint64 lockToTime;
        uint256 amount;
    }

    mapping(address => RewardData[]) public userRewards; // RewardData[0] is claimable
    mapping(address => uint256) public balanceOf;
    uint256 public totalNeedToReward;

    uint256 public constant maxRewardArrayLen = 100;

    address feeSysAddr;
    IERC20 public linaToken;

    function __LnRewardLocker_init(address _admin, address linaAddress) public initializer {

        __LnAdminUpgradeable_init(_admin);

        linaToken = IERC20(linaAddress);
    }

    function setLinaAddress(address _token) external onlyAdmin {

        linaToken = IERC20(_token);
    }

    function Init(address _feeSysAddr) external onlyAdmin {

        feeSysAddr = _feeSysAddr;
    }

    modifier onlyFeeSys() {

        require((msg.sender == feeSysAddr), "Only Fee System call");
        _;
    }

    function bulkAppendReward(
        address[] calldata _users,
        uint256[] calldata _amounts,
        uint64 _lockTo
    ) external onlyAdmin {

        require(_users.length == _amounts.length, "Length mismatch");

        for (uint256 ind = 0; ind < _users.length; ind++) {
            address _user = _users[ind];
            uint256 _amount = _amounts[ind];

            if (userRewards[_user].length >= maxRewardArrayLen) {
                Slimming(_user);
            }

            require(userRewards[_user].length <= maxRewardArrayLen, "user array out of");
            if (userRewards[_user].length == 0) {
                RewardData memory data = RewardData({lockToTime: 0, amount: 0});
                userRewards[_user].push(data);
            }

            RewardData memory data = RewardData({lockToTime: _lockTo, amount: _amount});
            userRewards[_user].push(data);

            balanceOf[_user] = balanceOf[_user].add(_amount);
            totalNeedToReward = totalNeedToReward.add(_amount);

            emit AppendReward(_user, _amount, _lockTo);
        }
    }

    function appendReward(
        address _user,
        uint256 _amount,
        uint64 _lockTo
    ) external onlyFeeSys {

        if (userRewards[_user].length >= maxRewardArrayLen) {
            Slimming(_user);
        }

        require(userRewards[_user].length <= maxRewardArrayLen, "user array out of");
        if (userRewards[_user].length == 0) {
            RewardData memory data = RewardData({lockToTime: 0, amount: 0});
            userRewards[_user].push(data);
        }

        RewardData memory data = RewardData({lockToTime: _lockTo, amount: _amount});
        userRewards[_user].push(data);

        balanceOf[_user] = balanceOf[_user].add(_amount);
        totalNeedToReward = totalNeedToReward.add(_amount);

        emit AppendReward(_user, _amount, _lockTo);
    }

    function Slimming(address _user) public {

        require(userRewards[_user].length > 1, "not data to slimming");
        RewardData storage claimable = userRewards[_user][0];
        for (uint256 i = 1; i < userRewards[_user].length; ) {
            if (now >= userRewards[_user][i].lockToTime) {
                claimable.amount = claimable.amount.add(userRewards[_user][i].amount);

                uint256 len = userRewards[_user].length;
                userRewards[_user][i].lockToTime = userRewards[_user][len - 1].lockToTime;
                userRewards[_user][i].amount = userRewards[_user][len - 1].amount;
                userRewards[_user].pop(); // delete last one
            } else {
                i++;
            }
        }
    }

    function ClaimMaxable() public {

        address user = msg.sender;
        Slimming(user);
        _claim(user, userRewards[user][0].amount);
    }

    function _claim(address _user, uint256 _amount) internal {

        userRewards[_user][0].amount = userRewards[_user][0].amount.sub(_amount);

        balanceOf[_user] = balanceOf[_user].sub(_amount);
        totalNeedToReward = totalNeedToReward.sub(_amount);

        linaToken.transfer(_user, _amount);
        emit ClaimLog(_user, _amount);
    }

    function Claim(uint256 _amount) public {

        address user = msg.sender;
        Slimming(user);
        require(_amount <= userRewards[user][0].amount, "Claim amount invalid");
        _claim(user, _amount);
    }

    event AppendReward(address user, uint256 amount, uint64 lockTo);
    event ClaimLog(address user, uint256 amount);

    uint256[45] private __gap;
}

interface IAsset {

    function keyName() external view returns (bytes32);

}

contract LnAdmin {

    address public admin;
    address public candidate;

    constructor(address _admin) public {
        require(_admin != address(0), "admin address cannot be 0");
        admin = _admin;
        emit AdminChanged(address(0), _admin);
    }

    function setCandidate(address _candidate) external onlyAdmin {

        address old = candidate;
        candidate = _candidate;
        emit CandidateChanged(old, candidate);
    }

    function becomeAdmin() external {

        require(msg.sender == candidate, "Only candidate can become admin");
        address old = admin;
        admin = candidate;
        emit AdminChanged(old, admin);
    }

    modifier onlyAdmin {

        require((msg.sender == admin), "Only the contract admin can perform this action");
        _;
    }

    event CandidateChanged(address oldCandidate, address newCandidate);
    event AdminChanged(address oldAdmin, address newAdmin);
}

contract LnConfig is LnAdmin {

    mapping(bytes32 => uint) internal mUintConfig;

    constructor(address _admin) public LnAdmin(_admin) {}

    bytes32 public constant BUILD_RATIO = "BuildRatio"; // percent, base 10e18

    function getUint(bytes32 key) external view returns (uint) {

        return mUintConfig[key];
    }

    function setUint(bytes32 key, uint value) external onlyAdmin {

        mUintConfig[key] = value;
        emit SetUintConfig(key, value);
    }

    function deleteUint(bytes32 key) external onlyAdmin {

        delete mUintConfig[key];
        emit SetUintConfig(key, 0);
    }

    function batchSet(bytes32[] calldata names, uint[] calldata values) external onlyAdmin {

        require(names.length == values.length, "Input lengths must match");

        for (uint i = 0; i < names.length; i++) {
            mUintConfig[names[i]] = values[i];
            emit SetUintConfig(names[i], values[i]);
        }
    }

    event SetUintConfig(bytes32 key, uint value);
}

library SafeDecimalMath {

    using SafeMath for uint;

    uint8 public constant decimals = 18;
    uint8 public constant highPrecisionDecimals = 27;

    uint public constant UNIT = 10**uint(decimals);

    uint public constant PRECISE_UNIT = 10**uint(highPrecisionDecimals);
    uint private constant UNIT_TO_HIGH_PRECISION_CONVERSION_FACTOR = 10**uint(highPrecisionDecimals - decimals);

    function unit() external pure returns (uint) {

        return UNIT;
    }

    function preciseUnit() external pure returns (uint) {

        return PRECISE_UNIT;
    }

    function multiplyDecimal(uint x, uint y) internal pure returns (uint) {

        return x.mul(y) / UNIT;
    }

    function _multiplyDecimalRound(
        uint x,
        uint y,
        uint precisionUnit
    ) private pure returns (uint) {

        uint quotientTimesTen = x.mul(y) / (precisionUnit / 10);

        if (quotientTimesTen % 10 >= 5) {
            quotientTimesTen += 10;
        }

        return quotientTimesTen / 10;
    }

    function multiplyDecimalRoundPrecise(uint x, uint y) internal pure returns (uint) {

        return _multiplyDecimalRound(x, y, PRECISE_UNIT);
    }

    function multiplyDecimalRound(uint x, uint y) internal pure returns (uint) {

        return _multiplyDecimalRound(x, y, UNIT);
    }

    function divideDecimal(uint x, uint y) internal pure returns (uint) {

        return x.mul(UNIT).div(y);
    }

    function _divideDecimalRound(
        uint x,
        uint y,
        uint precisionUnit
    ) private pure returns (uint) {

        uint resultTimesTen = x.mul(precisionUnit * 10).div(y);

        if (resultTimesTen % 10 >= 5) {
            resultTimesTen += 10;
        }

        return resultTimesTen / 10;
    }

    function divideDecimalRound(uint x, uint y) internal pure returns (uint) {

        return _divideDecimalRound(x, y, UNIT);
    }

    function divideDecimalRoundPrecise(uint x, uint y) internal pure returns (uint) {

        return _divideDecimalRound(x, y, PRECISE_UNIT);
    }

    function decimalToPreciseDecimal(uint i) internal pure returns (uint) {

        return i.mul(UNIT_TO_HIGH_PRECISION_CONVERSION_FACTOR);
    }

    function preciseDecimalToDecimal(uint i) internal pure returns (uint) {

        uint quotientTimesTen = i / (UNIT_TO_HIGH_PRECISION_CONVERSION_FACTOR / 10);

        if (quotientTimesTen % 10 >= 5) {
            quotientTimesTen += 10;
        }

        return quotientTimesTen / 10;
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

abstract contract ContextUpgradeable is Initializable {
    function __Context_init() internal initializer {
        __Context_init_unchained();
    }

    function __Context_init_unchained() internal initializer {}

    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }

    uint256[50] private __gap;
}

abstract contract PausableUpgradeable is Initializable, ContextUpgradeable {
    event Paused(address account);

    event Unpaused(address account);

    bool private _paused;

    function __Pausable_init() internal initializer {
        __Context_init_unchained();
        __Pausable_init_unchained();
    }

    function __Pausable_init_unchained() internal initializer {
        _paused = false;
    }

    function paused() public view returns (bool) {
        return _paused;
    }

    modifier whenNotPaused() {
        require(!_paused, "Pausable: paused");
        _;
    }

    modifier whenPaused() {
        require(_paused, "Pausable: not paused");
        _;
    }

    function _pause() internal virtual whenNotPaused {
        _paused = true;
        emit Paused(_msgSender());
    }

    function _unpause() internal virtual whenPaused {
        _paused = false;
        emit Unpaused(_msgSender());
    }

    uint256[49] private __gap;
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
        return _verifyCallResult(success, returndata, errorMessage);
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
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function _verifyCallResult(
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) private pure returns (bytes memory) {

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

contract LnAddressStorage is LnAdmin {

    mapping(bytes32 => address) public mAddrs;

    constructor(address _admin) public LnAdmin(_admin) {}

    function updateAll(bytes32[] calldata names, address[] calldata destinations) external onlyAdmin {

        require(names.length == destinations.length, "Input lengths must match");

        for (uint i = 0; i < names.length; i++) {
            mAddrs[names[i]] = destinations[i];
            emit StorageAddressUpdated(names[i], destinations[i]);
        }
    }

    function update(bytes32 name, address dest) external onlyAdmin {

        require(name != "", "name can not be empty");
        require(dest != address(0), "address cannot be 0");
        mAddrs[name] = dest;
        emit StorageAddressUpdated(name, dest);
    }

    function getAddress(bytes32 name) external view returns (address) {

        return mAddrs[name];
    }

    function getAddressWithRequire(bytes32 name, string calldata reason) external view returns (address) {

        address _foundAddress = mAddrs[name];
        require(_foundAddress != address(0), reason);
        return _foundAddress;
    }

    event StorageAddressUpdated(bytes32 name, address addr);
}

interface LnAddressCache {

    function updateAddressCache(LnAddressStorage _addressStorage) external;


    event CachedAddressUpdated(bytes32 name, address addr);
}

contract testAddressCache is LnAddressCache, LnAdmin {

    address public addr1;
    address public addr2;

    constructor(address _admin) public LnAdmin(_admin) {}

    function updateAddressCache(LnAddressStorage _addressStorage) public override onlyAdmin {

        addr1 = LnAddressStorage(_addressStorage).getAddressWithRequire("a", "");
        addr2 = LnAddressStorage(_addressStorage).getAddressWithRequire("b", "");
        emit CachedAddressUpdated("a", addr1);
        emit CachedAddressUpdated("b", addr2);
    }
}

library EnumerableSet {


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

abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

abstract contract AccessControl is Context {
    using EnumerableSet for EnumerableSet.AddressSet;
    using Address for address;

    struct RoleData {
        EnumerableSet.AddressSet members;
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
}


contract LnAccessControl is AccessControl {

    using Address for address;

    bytes32 public constant ISSUE_ASSET_ROLE = ("ISSUE_ASSET"); //keccak256
    bytes32 public constant BURN_ASSET_ROLE = ("BURN_ASSET");

    bytes32 public constant DEBT_SYSTEM = ("LnDebtSystem");

    constructor(address admin) public {
        _setupRole(DEFAULT_ADMIN_ROLE, admin);
    }

    function IsAdmin(address _address) public view returns (bool) {

        return hasRole(DEFAULT_ADMIN_ROLE, _address);
    }

    function SetAdmin(address _address) public returns (bool) {

        require(IsAdmin(msg.sender), "Only admin");

        _setupRole(DEFAULT_ADMIN_ROLE, _address);
    }

    function SetRoles(
        bytes32 roleType,
        address[] calldata addresses,
        bool[] calldata setTo
    ) external {

        require(IsAdmin(msg.sender), "Only admin");

        _setRoles(roleType, addresses, setTo);
    }

    function _setRoles(
        bytes32 roleType,
        address[] calldata addresses,
        bool[] calldata setTo
    ) private {

        require(addresses.length == setTo.length, "parameter address length not eq");

        for (uint256 i = 0; i < addresses.length; i++) {
            if (setTo[i]) {
                grantRole(roleType, addresses[i]);
            } else {
                revokeRole(roleType, addresses[i]);
            }
        }
    }


    function SetIssueAssetRole(address[] calldata issuer, bool[] calldata setTo) public {

        _setRoles(ISSUE_ASSET_ROLE, issuer, setTo);
    }

    function SetBurnAssetRole(address[] calldata burner, bool[] calldata setTo) public {

        _setRoles(BURN_ASSET_ROLE, burner, setTo);
    }

    function SetDebtSystemRole(address[] calldata _address, bool[] calldata _setTo) public {

        _setRoles(DEBT_SYSTEM, _address, _setTo);
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

contract ERC20Upgradeable is Initializable, ContextUpgradeable, IERC20Upgradeable {

    using SafeMathUpgradeable for uint256;

    mapping(address => uint256) private _balances;

    mapping(address => mapping(address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;
    uint8 private _decimals;

    function __ERC20_init(string memory name_, string memory symbol_) internal initializer {

        __Context_init_unchained();
        __ERC20_init_unchained(name_, symbol_);
    }

    function __ERC20_init_unchained(string memory name_, string memory symbol_) internal initializer {

        _name = name_;
        _symbol = symbol_;
        _decimals = 18;
    }

    function name() public view returns (string memory) {

        return _name;
    }

    function symbol() public view returns (string memory) {

        return _symbol;
    }

    function decimals() public view returns (uint8) {

        return _decimals;
    }

    function totalSupply() public view override returns (uint256) {

        return _totalSupply;
    }

    function balanceOf(address account) public view override returns (uint256) {

        return _balances[account];
    }

    function transfer(address recipient, uint256 amount) public virtual override returns (bool) {

        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function allowance(address owner, address spender) public view virtual override returns (uint256) {

        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public virtual override returns (bool) {

        _approve(_msgSender(), spender, amount);
        return true;
    }

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public virtual override returns (bool) {

        _transfer(sender, recipient, amount);
        _approve(
            sender,
            _msgSender(),
            _allowances[sender][_msgSender()].sub(amount, "ERC20: transfer amount exceeds allowance")
        );
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {

        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].add(addedValue));
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {

        _approve(
            _msgSender(),
            spender,
            _allowances[_msgSender()][spender].sub(subtractedValue, "ERC20: decreased allowance below zero")
        );
        return true;
    }

    function _transfer(
        address sender,
        address recipient,
        uint256 amount
    ) internal virtual {

        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(sender, recipient, amount);

        _balances[sender] = _balances[sender].sub(amount, "ERC20: transfer amount exceeds balance");
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
    }

    function _mint(address account, uint256 amount) internal virtual {

        require(account != address(0), "ERC20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply = _totalSupply.add(amount);
        _balances[account] = _balances[account].add(amount);
        emit Transfer(address(0), account, amount);
    }

    function _burn(address account, uint256 amount) internal virtual {

        require(account != address(0), "ERC20: burn from the zero address");

        _beforeTokenTransfer(account, address(0), amount);

        _balances[account] = _balances[account].sub(amount, "ERC20: burn amount exceeds balance");
        _totalSupply = _totalSupply.sub(amount);
        emit Transfer(account, address(0), amount);
    }

    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {

        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _setupDecimals(uint8 decimals_) internal {

        _decimals = decimals_;
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}


    uint256[44] private __gap;
}

contract LnAssetUpgradeable is ERC20Upgradeable, LnAdminUpgradeable, IAsset, LnAddressCache {

    bytes32 mKeyName;
    LnAccessControl accessCtrl;

    modifier onlyIssueAssetRole(address _address) {

        require(accessCtrl.hasRole(accessCtrl.ISSUE_ASSET_ROLE(), _address), "Need issue access role");
        _;
    }
    modifier onlyBurnAssetRole(address _address) {

        require(accessCtrl.hasRole(accessCtrl.BURN_ASSET_ROLE(), _address), "Need burn access role");
        _;
    }

    function __LnAssetUpgradeable_init(
        bytes32 _key,
        string memory _name,
        string memory _symbol,
        address _admin
    ) public initializer {

        __ERC20_init(_name, _symbol);
        __LnAdminUpgradeable_init(_admin);

        mKeyName = _key;
    }

    function keyName() external view override returns (bytes32) {

        return mKeyName;
    }

    function updateAddressCache(LnAddressStorage _addressStorage) public override onlyAdmin {

        accessCtrl = LnAccessControl(
            _addressStorage.getAddressWithRequire("LnAccessControl", "LnAccessControl address not valid")
        );

        emit CachedAddressUpdated("LnAccessControl", address(accessCtrl));
    }

    function mint(address account, uint256 amount) external onlyIssueAssetRole(msg.sender) {

        _mint(account, amount);
    }

    function burn(address account, uint amount) external onlyBurnAssetRole(msg.sender) {

        _burn(account, amount);
    }

    uint256[48] private __gap;
}

contract LnAssetSystem is LnAddressStorage {

    using SafeMath for uint;
    using SafeDecimalMath for uint;

    IAsset[] public mAssetList; // 合约地址数组
    mapping(address => bytes32) public mAddress2Names; // 地址到名称的映射

    constructor(address _admin) public LnAddressStorage(_admin) {}

    function addAsset(IAsset asset) external onlyAdmin {

        bytes32 name = asset.keyName();

        require(mAddrs[name] == address(0), "Asset already exists");
        require(mAddress2Names[address(asset)] == bytes32(0), "Asset address already exists");

        mAssetList.push(asset);
        mAddrs[name] = address(asset);
        mAddress2Names[address(asset)] = name;

        emit AssetAdded(name, address(asset));
    }

    function removeAsset(bytes32 name) external onlyAdmin {

        address assetToRemove = address(mAddrs[name]);

        require(assetToRemove != address(0), "asset does not exist");

        for (uint i = 0; i < mAssetList.length; i++) {
            if (address(mAssetList[i]) == assetToRemove) {
                delete mAssetList[i];
                mAssetList[i] = mAssetList[mAssetList.length - 1];
                mAssetList.pop();
                break;
            }
        }

        delete mAddress2Names[assetToRemove];
        delete mAddrs[name];

        emit AssetRemoved(name, assetToRemove);
    }

    function assetNumber() external view returns (uint) {

        return mAssetList.length;
    }

    function totalAssetsInUsd() public view returns (uint256 rTotal) {

        require(mAddrs["LnPrices"] != address(0), "LnPrices address cannot access");
        LnPrices priceGetter = LnPrices(mAddrs["LnPrices"]); //getAddress
        for (uint256 i = 0; i < mAssetList.length; i++) {
            uint256 exchangeRate = priceGetter.getPrice(mAssetList[i].keyName());
            rTotal = rTotal.add(LnAssetUpgradeable(address(mAssetList[i])).totalSupply().multiplyDecimal(exchangeRate));
        }
    }

    function getAssetAddresses() external view returns (address[] memory) {

        address[] memory addr = new address[](mAssetList.length);
        for (uint256 i = 0; i < mAssetList.length; i++) {
            addr[i] = address(mAssetList[i]);
        }
        return addr;
    }

    event AssetAdded(bytes32 name, address asset);
    event AssetRemoved(bytes32 name, address asset);
}

contract LnFeeSystem is LnAdminUpgradeable, LnAddressCache {

    using SafeMath for uint256;
    using SafeDecimalMath for uint256;

    address public constant FEE_DUMMY_ADDRESS = address(0x2048);

    struct UserDebtData {
        uint256 PeriodID; // Period id
        uint256 debtProportion;
        uint256 debtFactor; // PRECISE_UNIT
    }

    struct RewardPeriod {
        uint256 id; // Period id
        uint256 startingDebtFactor;
        uint256 startTime;
        uint256 feesToDistribute; // 要分配的费用
        uint256 feesClaimed; // 已领取的费用
        uint256 rewardsToDistribute; // 要分配的奖励
        uint256 rewardsClaimed; // 已领取的奖励
    }

    RewardPeriod public curRewardPeriod;
    RewardPeriod public preRewardPeriod;
    uint256 public OnePeriodSecs;
    uint64 public LockTime;

    mapping(address => uint256) public userLastClaimedId;

    mapping(address => UserDebtData[2]) public userPeriodDebt; // one for current period, one for pre period

    LnDebtSystem public debtSystem;
    LnCollateralSystem public collateralSystem;
    LnRewardLocker public rewardLocker;
    LnAssetSystem mAssets;

    address public exchangeSystemAddress;
    address public rewardDistributer;

    function __LnFeeSystem_init(address _admin) public initializer {

        __LnAdminUpgradeable_init(_admin);

        OnePeriodSecs = 1 weeks;
        LockTime = uint64(52 weeks);
    }

    function Init(address _exchangeSystem, address _rewardDistri) public onlyAdmin {

        exchangeSystemAddress = _exchangeSystem;
        rewardDistributer = _rewardDistri;
    }

    function SetPeriodData(
        int16 index, // 0 current 1 pre
        uint256 id,
        uint256 startingDebtFactor,
        uint256 startTime,
        uint256 feesToDistribute,
        uint256 feesClaimed,
        uint256 rewardsToDistribute,
        uint256 rewardsClaimed
    ) public onlyAdmin {

        RewardPeriod storage toset = index == 0 ? curRewardPeriod : preRewardPeriod;
        toset.id = id;
        toset.startingDebtFactor = startingDebtFactor;
        toset.startTime = startTime;
        toset.feesToDistribute = feesToDistribute;
        toset.feesClaimed = feesClaimed;
        toset.rewardsToDistribute = rewardsToDistribute;
        toset.rewardsClaimed = rewardsClaimed;
    }

    function setExchangeSystemAddress(address _address) public onlyAdmin {

        exchangeSystemAddress = _address;
    }

    modifier onlyExchanger {

        require((msg.sender == exchangeSystemAddress), "Only Exchange System call");
        _;
    }

    modifier onlyDistributer {

        require((msg.sender == rewardDistributer), "Only Reward Distributer call");
        _;
    }

    function addExchangeFee(uint feeUsd) public onlyExchanger {

        curRewardPeriod.feesToDistribute = curRewardPeriod.feesToDistribute.add(feeUsd);
        emit ExchangeFee(feeUsd);
    }

    function addCollateralRewards(uint reward) public onlyDistributer {

        curRewardPeriod.rewardsToDistribute = curRewardPeriod.rewardsToDistribute.add(reward);
        emit RewardCollateral(reward);
    }

    event ExchangeFee(uint feeUsd);
    event RewardCollateral(uint reward);
    event FeesClaimed(address user, uint lUSDAmount, uint linaRewards);

    function updateAddressCache(LnAddressStorage _addressStorage) public override onlyAdmin {

        debtSystem = LnDebtSystem(_addressStorage.getAddressWithRequire("LnDebtSystem", "LnDebtSystem address not valid"));
        address payable collateralAddress =
            payable(_addressStorage.getAddressWithRequire("LnCollateralSystem", "LnCollateralSystem address not valid"));
        collateralSystem = LnCollateralSystem(collateralAddress);
        rewardLocker = LnRewardLocker(
            _addressStorage.getAddressWithRequire("LnRewardLocker", "LnRewardLocker address not valid")
        );
        mAssets = LnAssetSystem(_addressStorage.getAddressWithRequire("LnAssetSystem", "LnAssetSystem address not valid"));

        exchangeSystemAddress = _addressStorage.getAddressWithRequire(
            "LnExchangeSystem",
            "LnExchangeSystem address not valid"
        );

        emit CachedAddressUpdated("LnDebtSystem", address(debtSystem));
        emit CachedAddressUpdated("LnCollateralSystem", address(collateralSystem));
        emit CachedAddressUpdated("LnRewardLocker", address(rewardLocker));
        emit CachedAddressUpdated("LnAssetSystem", address(mAssets));
        emit CachedAddressUpdated("LnExchangeSystem", address(exchangeSystemAddress));
    }

    function switchPeriod() public {

        require(now >= curRewardPeriod.startTime + OnePeriodSecs, "It's not time to switch");

        preRewardPeriod.id = curRewardPeriod.id;
        preRewardPeriod.startingDebtFactor = curRewardPeriod.startingDebtFactor;
        preRewardPeriod.startTime = curRewardPeriod.startTime;
        preRewardPeriod.feesToDistribute = curRewardPeriod.feesToDistribute.add(
            preRewardPeriod.feesToDistribute.sub(preRewardPeriod.feesClaimed)
        );
        preRewardPeriod.feesClaimed = 0;
        preRewardPeriod.rewardsToDistribute = curRewardPeriod.rewardsToDistribute.add(
            preRewardPeriod.rewardsToDistribute.sub(preRewardPeriod.rewardsClaimed)
        );
        preRewardPeriod.rewardsClaimed = 0;

        curRewardPeriod.id = curRewardPeriod.id + 1;
        curRewardPeriod.startingDebtFactor = debtSystem.LastSystemDebtFactor();
        curRewardPeriod.startTime = now;
        curRewardPeriod.feesToDistribute = 0;
        curRewardPeriod.feesClaimed = 0;
        curRewardPeriod.rewardsToDistribute = 0;
        curRewardPeriod.rewardsClaimed = 0;
    }

    function feePeriodDuration() external view returns (uint) {

        return OnePeriodSecs;
    }

    function recentFeePeriods(uint index)
        external
        view
        returns (
            uint256 id,
            uint256 startingDebtFactor,
            uint256 startTime,
            uint256 feesToDistribute,
            uint256 feesClaimed,
            uint256 rewardsToDistribute,
            uint256 rewardsClaimed
        )
    {

        if (index > 1) {
            return (0, 0, 0, 0, 0, 0, 0);
        }
        RewardPeriod memory rewardPd;
        if (index == 0) {
            rewardPd = curRewardPeriod;
        } else {
            rewardPd = preRewardPeriod;
        }
        return (
            rewardPd.id,
            rewardPd.startingDebtFactor,
            rewardPd.startTime,
            rewardPd.feesToDistribute,
            rewardPd.feesClaimed,
            rewardPd.rewardsToDistribute,
            rewardPd.rewardsClaimed
        );
    }

    modifier onlyDebtSystem() {

        require(msg.sender == address(debtSystem), "Only Debt system call");
        _;
    }

    function RecordUserDebt(
        address user,
        uint256 debtProportion,
        uint256 debtFactor
    ) public onlyDebtSystem {

        uint256 curId = curRewardPeriod.id;
        uint256 minPos = 0;
        if (userPeriodDebt[user][0].PeriodID > userPeriodDebt[user][1].PeriodID) {
            minPos = 1;
        }
        uint256 pos = minPos;
        for (uint64 i = 0; i < userPeriodDebt[user].length; i++) {
            if (userPeriodDebt[user][i].PeriodID == curId) {
                pos = i;
                break;
            }
        }
        userPeriodDebt[user][pos].PeriodID = curId;
        userPeriodDebt[user][pos].debtProportion = debtProportion;
        userPeriodDebt[user][pos].debtFactor = debtFactor;
    }

    function isFeesClaimable(address account) public view returns (bool feesClaimable) {

        if (collateralSystem.IsSatisfyTargetRatio(account) == false) {
            return false;
        }

        if (userLastClaimedId[account] == preRewardPeriod.id) {
            return false;
        }

        return true;
    }

    function feesAvailable(address user) public view returns (uint, uint) {

        if (preRewardPeriod.feesToDistribute == 0 && preRewardPeriod.rewardsToDistribute == 0) {
            return (0, 0);
        }
        uint256 debtFactor = 0;
        uint256 debtProportion = 0;
        uint256 pid = 0; //get last period factor
        for (uint64 i = 0; i < userPeriodDebt[user].length; i++) {
            if (userPeriodDebt[user][i].PeriodID < curRewardPeriod.id && userPeriodDebt[user][i].PeriodID > pid) {
                pid = curRewardPeriod.id;
                debtFactor = userPeriodDebt[user][i].debtFactor;
                debtProportion = userPeriodDebt[user][i].debtProportion;
            }
        }

        if (debtProportion == 0) {
            return (0, 0);
        }

        uint256 lastPeriodDebtFactor = curRewardPeriod.startingDebtFactor;
        uint256 userDebtProportion =
            lastPeriodDebtFactor.divideDecimalRoundPrecise(debtFactor).multiplyDecimalRoundPrecise(debtProportion);

        uint256 fee =
            preRewardPeriod
                .feesToDistribute
                .decimalToPreciseDecimal()
                .multiplyDecimalRoundPrecise(userDebtProportion)
                .preciseDecimalToDecimal();

        uint256 reward =
            preRewardPeriod
                .rewardsToDistribute
                .decimalToPreciseDecimal()
                .multiplyDecimalRoundPrecise(userDebtProportion)
                .preciseDecimalToDecimal();
        return (fee, reward);
    }

    function claimFees() external returns (bool) {

        address user = msg.sender;
        require(isFeesClaimable(user), "User is not claimable");

        userLastClaimedId[user] = preRewardPeriod.id;
        (uint256 fee, uint256 reward) = feesAvailable(user);
        require(fee > 0 || reward > 0, "Nothing to claim");

        if (fee > 0) {
            LnAssetUpgradeable lusd =
                LnAssetUpgradeable(mAssets.getAddressWithRequire("lUSD", "get lUSD asset address fail"));
            lusd.burn(FEE_DUMMY_ADDRESS, fee);
            lusd.mint(user, fee);
        }

        if (reward > 0) {
            uint64 totime = uint64(now + LockTime);
            rewardLocker.appendReward(user, reward, totime);
        }
        emit FeesClaimed(user, fee, reward);
        return true;
    }

    uint256[38] private __gap;
}

contract LnFeeSystemTest is LnFeeSystem {

    function __LnFeeSystemTest_init(address _admin) public initializer {

        __LnFeeSystem_init(_admin);

        OnePeriodSecs = 6 hours;
        LockTime = 1 hours;
    }
}

contract LnDebtSystem is LnAdminUpgradeable, LnAddressCache {

    using SafeMath for uint;
    using SafeDecimalMath for uint;
    using Address for address;

    LnAccessControl private accessCtrl;
    LnAssetSystem private assetSys;
    LnFeeSystem public feeSystem;
    struct DebtData {
        uint256 debtProportion;
        uint256 debtFactor; // PRECISE_UNIT
    }
    mapping(address => DebtData) public userDebtState;

    mapping(uint256 => uint256) public lastDebtFactors; // PRECISE_UNIT Note: 能直接记 factor 的记 factor, 不能记的就用index查
    uint256 public debtCurrentIndex; // length of array. this index of array no value
    uint256 public lastCloseAt; // close at array index
    uint256 public lastDeletTo; // delete to array index, lastDeletTo < lastCloseAt
    uint256 public constant MAX_DEL_PER_TIME = 50;


    function __LnDebtSystem_init(address _admin) public initializer {

        __LnAdminUpgradeable_init(_admin);
    }

    event UpdateAddressStorage(address oldAddr, address newAddr);
    event UpdateUserDebtLog(address addr, uint256 debtProportion, uint256 debtFactor);
    event PushDebtLog(uint256 index, uint256 newFactor);

    function updateAddressCache(LnAddressStorage _addressStorage) public override onlyAdmin {

        accessCtrl = LnAccessControl(
            _addressStorage.getAddressWithRequire("LnAccessControl", "LnAccessControl address not valid")
        );
        assetSys = LnAssetSystem(_addressStorage.getAddressWithRequire("LnAssetSystem", "LnAssetSystem address not valid"));
        feeSystem = LnFeeSystem(_addressStorage.getAddressWithRequire("LnFeeSystem", "LnFeeSystem address not valid"));

        emit CachedAddressUpdated("LnAccessControl", address(accessCtrl));
        emit CachedAddressUpdated("LnAssetSystem", address(assetSys));
        emit CachedAddressUpdated("LnFeeSystem", address(feeSystem));
    }

    modifier OnlyDebtSystemRole(address _address) {

        require(accessCtrl.hasRole(accessCtrl.DEBT_SYSTEM(), _address), "Need debt system access role");
        _;
    }

    function SetLastCloseFeePeriodAt(uint256 index) external OnlyDebtSystemRole(msg.sender) {

        require(index >= lastCloseAt, "Close index can not return to pass");
        require(index <= debtCurrentIndex, "Can not close at future index");
        lastCloseAt = index;
    }

    function _pushDebtFactor(uint256 _factor) private {

        if (debtCurrentIndex == 0 || lastDebtFactors[debtCurrentIndex - 1] == 0) {
            lastDebtFactors[debtCurrentIndex] = SafeDecimalMath.preciseUnit();
        } else {
            lastDebtFactors[debtCurrentIndex] = lastDebtFactors[debtCurrentIndex - 1].multiplyDecimalRoundPrecise(_factor);
        }
        emit PushDebtLog(debtCurrentIndex, lastDebtFactors[debtCurrentIndex]);

        debtCurrentIndex = debtCurrentIndex.add(1);

        if (lastDeletTo < lastCloseAt) {
            uint256 delNum = lastCloseAt - lastDeletTo;
            delNum = (delNum > MAX_DEL_PER_TIME) ? MAX_DEL_PER_TIME : delNum; // not delete all in one call, for saving someone fee.
            for (uint256 i = lastDeletTo; i < delNum; i++) {
                delete lastDebtFactors[i];
            }
            lastDeletTo = lastDeletTo.add(delNum);
        }
    }

    function PushDebtFactor(uint256 _factor) external OnlyDebtSystemRole(msg.sender) {

        _pushDebtFactor(_factor);
    }

    function _updateUserDebt(address _user, uint256 _debtProportion) private {

        userDebtState[_user].debtProportion = _debtProportion;
        userDebtState[_user].debtFactor = _lastSystemDebtFactor();
        emit UpdateUserDebtLog(_user, _debtProportion, userDebtState[_user].debtFactor);

        feeSystem.RecordUserDebt(_user, userDebtState[_user].debtProportion, userDebtState[_user].debtFactor);
    }

    function UpdateUserDebt(address _user, uint256 _debtProportion) external OnlyDebtSystemRole(msg.sender) {

        _updateUserDebt(_user, _debtProportion);
    }

    function UpdateDebt(
        address _user,
        uint256 _debtProportion,
        uint256 _factor
    ) external OnlyDebtSystemRole(msg.sender) {

        _pushDebtFactor(_factor);
        _updateUserDebt(_user, _debtProportion);
    }

    function GetUserDebtData(address _user) external view returns (uint256 debtProportion, uint256 debtFactor) {

        debtProportion = userDebtState[_user].debtProportion;
        debtFactor = userDebtState[_user].debtFactor;
    }

    function _lastSystemDebtFactor() private view returns (uint256) {

        if (debtCurrentIndex == 0) {
            return SafeDecimalMath.preciseUnit();
        }
        return lastDebtFactors[debtCurrentIndex - 1];
    }

    function LastSystemDebtFactor() external view returns (uint256) {

        return _lastSystemDebtFactor();
    }

    function GetUserCurrentDebtProportion(address _user) public view returns (uint256) {

        uint256 debtProportion = userDebtState[_user].debtProportion;
        uint256 debtFactor = userDebtState[_user].debtFactor;

        if (debtProportion == 0) {
            return 0;
        }

        uint256 currentUserDebtProportion =
            _lastSystemDebtFactor().divideDecimalRoundPrecise(debtFactor).multiplyDecimalRoundPrecise(debtProportion);
        return currentUserDebtProportion;
    }

    function GetUserDebtBalanceInUsd(address _user) external view returns (uint256, uint256) {

        uint256 totalAssetSupplyInUsd = assetSys.totalAssetsInUsd();

        uint256 debtProportion = userDebtState[_user].debtProportion;
        uint256 debtFactor = userDebtState[_user].debtFactor;

        if (debtProportion == 0) {
            return (0, totalAssetSupplyInUsd);
        }

        uint256 currentUserDebtProportion =
            _lastSystemDebtFactor().divideDecimalRoundPrecise(debtFactor).multiplyDecimalRoundPrecise(debtProportion);
        uint256 userDebtBalance =
            totalAssetSupplyInUsd
                .decimalToPreciseDecimal()
                .multiplyDecimalRoundPrecise(currentUserDebtProportion)
                .preciseDecimalToDecimal();

        return (userDebtBalance, totalAssetSupplyInUsd);
    }

    uint256[42] private __gap;
}

abstract contract Pausable is Context {
    event Paused(address account);

    event Unpaused(address account);

    bool private _paused;

    constructor() internal {
        _paused = false;
    }

    function paused() public view returns (bool) {
        return _paused;
    }

    modifier whenNotPaused() {
        require(!_paused, "Pausable: paused");
        _;
    }

    modifier whenPaused() {
        require(_paused, "Pausable: not paused");
        _;
    }

    function _pause() internal virtual whenNotPaused {
        _paused = true;
        emit Paused(_msgSender());
    }

    function _unpause() internal virtual whenPaused {
        _paused = false;
        emit Unpaused(_msgSender());
    }
}

contract LnBuildBurnSystem is LnAdmin, Pausable, LnAddressCache {

    using SafeMath for uint;
    using SafeDecimalMath for uint;
    using Address for address;

    LnAssetUpgradeable private lUSDToken; // this contract need

    LnDebtSystem private debtSystem;
    LnAssetSystem private assetSys;
    LnPrices private priceGetter;
    LnCollateralSystem private collaterSys;
    LnConfig private mConfig;

    constructor(address admin, address _lUSDTokenAddr) public LnAdmin(admin) {
        lUSDToken = LnAssetUpgradeable(_lUSDTokenAddr);
    }

    function setPaused(bool _paused) external onlyAdmin {

        if (_paused) {
            _pause();
        } else {
            _unpause();
        }
    }

    function updateAddressCache(LnAddressStorage _addressStorage) public override onlyAdmin {

        priceGetter = LnPrices(_addressStorage.getAddressWithRequire("LnPrices", "LnPrices address not valid"));
        debtSystem = LnDebtSystem(_addressStorage.getAddressWithRequire("LnDebtSystem", "LnDebtSystem address not valid"));
        assetSys = LnAssetSystem(_addressStorage.getAddressWithRequire("LnAssetSystem", "LnAssetSystem address not valid"));
        address payable collateralAddress =
            payable(_addressStorage.getAddressWithRequire("LnCollateralSystem", "LnCollateralSystem address not valid"));
        collaterSys = LnCollateralSystem(collateralAddress);
        mConfig = LnConfig(_addressStorage.getAddressWithRequire("LnConfig", "LnConfig address not valid"));

        emit CachedAddressUpdated("LnPrices", address(priceGetter));
        emit CachedAddressUpdated("LnDebtSystem", address(debtSystem));
        emit CachedAddressUpdated("LnAssetSystem", address(assetSys));
        emit CachedAddressUpdated("LnCollateralSystem", address(collaterSys));
        emit CachedAddressUpdated("LnConfig", address(mConfig));
    }

    function SetLusdTokenAddress(address _address) public onlyAdmin {

        emit UpdateLusdToken(address(lUSDToken), _address);
        lUSDToken = LnAssetUpgradeable(_address);
    }

    event UpdateLusdToken(address oldAddr, address newAddr);

    function MaxCanBuildAsset(address user) public view returns (uint256) {

        uint256 buildRatio = mConfig.getUint(mConfig.BUILD_RATIO());
        uint256 maxCanBuild = collaterSys.MaxRedeemableInUsd(user).mul(buildRatio).div(SafeDecimalMath.unit());
        return maxCanBuild;
    }

    function BuildAsset(uint256 amount) public whenNotPaused returns (bool) {

        address user = msg.sender;
        uint256 buildRatio = mConfig.getUint(mConfig.BUILD_RATIO());
        uint256 maxCanBuild = collaterSys.MaxRedeemableInUsd(user).multiplyDecimal(buildRatio);
        require(amount <= maxCanBuild, "Build amount too big, you need more collateral");

        (uint256 oldUserDebtBalance, uint256 totalAssetSupplyInUsd) = debtSystem.GetUserDebtBalanceInUsd(user);

        uint256 newTotalAssetSupply = totalAssetSupplyInUsd.add(amount);
        uint256 buildDebtProportion = amount.divideDecimalRoundPrecise(newTotalAssetSupply); // debtPercentage
        uint oldTotalProportion = SafeDecimalMath.preciseUnit().sub(buildDebtProportion); //

        uint256 newUserDebtProportion = buildDebtProportion;
        if (oldUserDebtBalance > 0) {
            newUserDebtProportion = oldUserDebtBalance.add(amount).divideDecimalRoundPrecise(newTotalAssetSupply);
        }

        debtSystem.UpdateDebt(user, newUserDebtProportion, oldTotalProportion);

        lUSDToken.mint(user, amount);

        return true;
    }

    function BuildMaxAsset() external whenNotPaused {

        address user = msg.sender;
        uint256 max = MaxCanBuildAsset(user);
        BuildAsset(max);
    }

    function _burnAsset(address user, uint256 amount) internal {

        require(amount > 0, "amount need > 0");
        (uint256 oldUserDebtBalance, uint256 totalAssetSupplyInUsd) = debtSystem.GetUserDebtBalanceInUsd(user);
        require(oldUserDebtBalance > 0, "no debt, no burn");
        uint256 burnAmount = oldUserDebtBalance < amount ? oldUserDebtBalance : amount;
        lUSDToken.burn(user, burnAmount);

        uint newTotalDebtIssued = totalAssetSupplyInUsd.sub(burnAmount);

        uint oldTotalProportion = 0;
        if (newTotalDebtIssued > 0) {
            uint debtPercentage = burnAmount.divideDecimalRoundPrecise(newTotalDebtIssued);
            oldTotalProportion = SafeDecimalMath.preciseUnit().add(debtPercentage);
        }

        uint256 newUserDebtProportion = 0;
        if (oldUserDebtBalance > burnAmount) {
            uint newDebt = oldUserDebtBalance.sub(burnAmount);
            newUserDebtProportion = newDebt.divideDecimalRoundPrecise(newTotalDebtIssued);
        }

        debtSystem.UpdateDebt(user, newUserDebtProportion, oldTotalProportion);
    }

    function BurnAsset(uint256 amount) external whenNotPaused returns (bool) {

        address user = msg.sender;
        _burnAsset(user, amount);
        return true;
    }


    function BurnAssetToTarget() external whenNotPaused returns (bool) {

        address user = msg.sender;

        uint256 buildRatio = mConfig.getUint(mConfig.BUILD_RATIO());
        uint256 totalCollateral = collaterSys.GetUserTotalCollateralInUsd(user);
        uint256 maxBuildAssetToTarget = totalCollateral.multiplyDecimal(buildRatio);
        (uint256 debtAsset, ) = debtSystem.GetUserDebtBalanceInUsd(user);
        require(debtAsset > maxBuildAssetToTarget, "You maybe want build to target");

        uint256 needBurn = debtAsset.sub(maxBuildAssetToTarget);
        uint balance = lUSDToken.balanceOf(user); // burn as many as possible
        if (balance < needBurn) {
            needBurn = balance;
        }
        _burnAsset(user, needBurn);
        return true;
    }
}

contract LnCollateralSystem is LnAdminUpgradeable, PausableUpgradeable, LnAddressCache {

    using SafeMath for uint;
    using SafeDecimalMath for uint;
    using AddressUpgradeable for address;

    LnPrices public priceGetter;
    LnDebtSystem public debtSystem;
    LnBuildBurnSystem public buildBurnSystem;
    LnConfig public mConfig;
    LnRewardLocker public mRewardLocker;

    bytes32 public constant Currency_ETH = "ETH";
    bytes32 public constant Currency_LINA = "LINA";

    uint256 public uniqueId; // use log

    struct TokenInfo {
        address tokenAddr;
        uint256 minCollateral; // min collateral amount.
        uint256 totalCollateral;
        bool bClose; // TODO : 为了防止价格波动，另外再加个折扣价?
    }

    mapping(bytes32 => TokenInfo) public tokenInfos;
    bytes32[] public tokenSymbol; // keys of tokenInfos, use to iteration

    struct CollateralData {
        uint256 collateral; // total collateral
    }

    mapping(address => mapping(bytes32 => CollateralData)) public userCollateralData;

    function __LnCollateralSystem_init(address _admin) public initializer {

        __LnAdminUpgradeable_init(_admin);
    }

    function setPaused(bool _paused) external onlyAdmin {

        if (_paused) {
            _pause();
        } else {
            _unpause();
        }
    }

    function updateAddressCache(LnAddressStorage _addressStorage) public override onlyAdmin {

        priceGetter = LnPrices(_addressStorage.getAddressWithRequire("LnPrices", "LnPrices address not valid"));
        debtSystem = LnDebtSystem(_addressStorage.getAddressWithRequire("LnDebtSystem", "LnDebtSystem address not valid"));
        buildBurnSystem = LnBuildBurnSystem(
            _addressStorage.getAddressWithRequire("LnBuildBurnSystem", "LnBuildBurnSystem address not valid")
        );
        mConfig = LnConfig(_addressStorage.getAddressWithRequire("LnConfig", "LnConfig address not valid"));
        mRewardLocker = LnRewardLocker(
            _addressStorage.getAddressWithRequire("LnRewardLocker", "LnRewardLocker address not valid")
        );

        emit CachedAddressUpdated("LnPrices", address(priceGetter));
        emit CachedAddressUpdated("LnDebtSystem", address(debtSystem));
        emit CachedAddressUpdated("LnBuildBurnSystem", address(buildBurnSystem));
        emit CachedAddressUpdated("LnConfig", address(mConfig));
        emit CachedAddressUpdated("LnRewardLocker", address(mRewardLocker));
    }

    function updateTokenInfo(
        bytes32 _currency,
        address _tokenAddr,
        uint256 _minCollateral,
        bool _close
    ) private returns (bool) {

        require(_currency[0] != 0, "symbol cannot empty");
        require(_currency != Currency_ETH, "ETH is used by system");
        require(_tokenAddr != address(0), "token address cannot zero");
        require(_tokenAddr.isContract(), "token address is not a contract");

        if (tokenInfos[_currency].tokenAddr == address(0)) {
            tokenSymbol.push(_currency);
        }

        uint256 totalCollateral = tokenInfos[_currency].totalCollateral;
        tokenInfos[_currency] = TokenInfo({
            tokenAddr: _tokenAddr,
            minCollateral: _minCollateral,
            totalCollateral: totalCollateral,
            bClose: _close
        });
        emit UpdateTokenSetting(_currency, _tokenAddr, _minCollateral, _close);
        return true;
    }


    function UpdateTokenInfo(
        bytes32 _currency,
        address _tokenAddr,
        uint256 _minCollateral,
        bool _close
    ) external onlyAdmin returns (bool) {

        return updateTokenInfo(_currency, _tokenAddr, _minCollateral, _close);
    }

    function UpdateTokenInfos(
        bytes32[] calldata _symbols,
        address[] calldata _tokenAddrs,
        uint256[] calldata _minCollateral,
        bool[] calldata _closes
    ) external onlyAdmin returns (bool) {

        require(_symbols.length == _tokenAddrs.length, "length of array not eq");
        require(_symbols.length == _minCollateral.length, "length of array not eq");
        require(_symbols.length == _closes.length, "length of array not eq");

        for (uint256 i = 0; i < _symbols.length; i++) {
            updateTokenInfo(_symbols[i], _tokenAddrs[i], _minCollateral[i], _closes[i]);
        }

        return true;
    }

    function GetSystemTotalCollateralInUsd() public view returns (uint256 rTotal) {

        for (uint256 i = 0; i < tokenSymbol.length; i++) {
            bytes32 currency = tokenSymbol[i];
            uint256 collateralAmount = tokenInfos[currency].totalCollateral;
            if (Currency_LINA == currency) {
                collateralAmount = collateralAmount.add(mRewardLocker.totalNeedToReward());
            }
            if (collateralAmount > 0) {
                rTotal = rTotal.add(collateralAmount.multiplyDecimal(priceGetter.getPrice(currency)));
            }
        }

        if (address(this).balance > 0) {
            rTotal = rTotal.add(address(this).balance.multiplyDecimal(priceGetter.getPrice(Currency_ETH)));
        }
    }

    function GetUserTotalCollateralInUsd(address _user) public view returns (uint256 rTotal) {

        for (uint256 i = 0; i < tokenSymbol.length; i++) {
            bytes32 currency = tokenSymbol[i];
            uint256 collateralAmount = userCollateralData[_user][currency].collateral;
            if (Currency_LINA == currency) {
                collateralAmount = collateralAmount.add(mRewardLocker.balanceOf(_user));
            }
            if (collateralAmount > 0) {
                rTotal = rTotal.add(collateralAmount.multiplyDecimal(priceGetter.getPrice(currency)));
            }
        }

        if (userCollateralData[_user][Currency_ETH].collateral > 0) {
            rTotal = rTotal.add(
                userCollateralData[_user][Currency_ETH].collateral.multiplyDecimal(priceGetter.getPrice(Currency_ETH))
            );
        }
    }

    function GetUserCollateral(address _user, bytes32 _currency) external view returns (uint256) {

        if (Currency_LINA != _currency) {
            return userCollateralData[_user][_currency].collateral;
        }
        return mRewardLocker.balanceOf(_user).add(userCollateralData[_user][_currency].collateral);
    }

    function GetUserCollaterals(address _user) external view returns (bytes32[] memory, uint256[] memory) {

        bytes32[] memory rCurrency = new bytes32[](tokenSymbol.length + 1);
        uint256[] memory rAmount = new uint256[](tokenSymbol.length + 1);
        uint256 retSize = 0;
        for (uint256 i = 0; i < tokenSymbol.length; i++) {
            bytes32 currency = tokenSymbol[i];
            if (userCollateralData[_user][currency].collateral > 0) {
                rCurrency[retSize] = currency;
                rAmount[retSize] = userCollateralData[_user][currency].collateral;
                retSize++;
            }
        }
        if (userCollateralData[_user][Currency_ETH].collateral > 0) {
            rCurrency[retSize] = Currency_ETH;
            rAmount[retSize] = userCollateralData[_user][Currency_ETH].collateral;
            retSize++;
        }

        return (rCurrency, rAmount);
    }

    function migrateCollateral(
        bytes32 _currency,
        address[] calldata _users,
        uint256[] calldata _amounts
    ) external onlyAdmin returns (bool) {

        require(tokenInfos[_currency].tokenAddr.isContract(), "Invalid token symbol");
        TokenInfo storage tokeninfo = tokenInfos[_currency];
        require(tokeninfo.bClose == false, "This token is closed");
        require(_users.length == _amounts.length, "Length mismatch");

        for (uint256 ind = 0; ind < _amounts.length; ind++) {
            address user = _users[ind];
            uint256 amount = _amounts[ind];

            userCollateralData[user][_currency].collateral = userCollateralData[user][_currency].collateral.add(amount);
            tokeninfo.totalCollateral = tokeninfo.totalCollateral.add(amount);

            emit CollateralLog(user, _currency, amount, userCollateralData[user][_currency].collateral);
        }
    }

    function Collateral(bytes32 _currency, uint256 _amount) external whenNotPaused returns (bool) {

        require(tokenInfos[_currency].tokenAddr.isContract(), "Invalid token symbol");
        TokenInfo storage tokeninfo = tokenInfos[_currency];
        require(_amount > tokeninfo.minCollateral, "Collateral amount too small");
        require(tokeninfo.bClose == false, "This token is closed");

        address user = msg.sender;

        IERC20 erc20 = IERC20(tokenInfos[_currency].tokenAddr);
        require(erc20.balanceOf(user) >= _amount, "insufficient balance");
        require(erc20.allowance(user, address(this)) >= _amount, "insufficient allowance, need approve more amount");

        erc20.transferFrom(user, address(this), _amount);

        userCollateralData[user][_currency].collateral = userCollateralData[user][_currency].collateral.add(_amount);
        tokeninfo.totalCollateral = tokeninfo.totalCollateral.add(_amount);

        emit CollateralLog(user, _currency, _amount, userCollateralData[user][_currency].collateral);
        return true;
    }

    function IsSatisfyTargetRatio(address _user) public view returns (bool) {

        (uint256 debtBalance, ) = debtSystem.GetUserDebtBalanceInUsd(_user);
        if (debtBalance == 0) {
            return true;
        }

        uint256 buildRatio = mConfig.getUint(mConfig.BUILD_RATIO());
        uint256 totalCollateralInUsd = GetUserTotalCollateralInUsd(_user);
        if (totalCollateralInUsd == 0) {
            return false;
        }
        uint256 myratio = debtBalance.divideDecimal(totalCollateralInUsd);
        return myratio <= buildRatio;
    }

    function MaxRedeemableInUsd(address _user) public view returns (uint256) {

        uint256 totalCollateralInUsd = GetUserTotalCollateralInUsd(_user);

        (uint256 debtBalance, ) = debtSystem.GetUserDebtBalanceInUsd(_user);
        if (debtBalance == 0) {
            return totalCollateralInUsd;
        }

        uint256 buildRatio = mConfig.getUint(mConfig.BUILD_RATIO());
        uint256 minCollateral = debtBalance.divideDecimal(buildRatio);
        if (totalCollateralInUsd < minCollateral) {
            return 0;
        }

        return totalCollateralInUsd.sub(minCollateral);
    }

    function MaxRedeemable(address user, bytes32 _currency) public view returns (uint256) {

        uint256 maxRedeemableInUsd = MaxRedeemableInUsd(user);
        uint256 maxRedeem = maxRedeemableInUsd.divideDecimal(priceGetter.getPrice(_currency));
        if (maxRedeem > userCollateralData[user][_currency].collateral) {
            maxRedeem = userCollateralData[user][_currency].collateral;
        }
        if (Currency_LINA != _currency) {
            return maxRedeem;
        }
        uint256 lockedLina = mRewardLocker.balanceOf(user);
        if (maxRedeem <= lockedLina) {
            return 0;
        }
        return maxRedeem.sub(lockedLina);
    }

    function RedeemMax(bytes32 _currency) external whenNotPaused {

        address user = msg.sender;
        uint256 maxRedeem = MaxRedeemable(user, _currency);
        _Redeem(user, _currency, maxRedeem);
    }

    function _Redeem(
        address user,
        bytes32 _currency,
        uint256 _amount
    ) internal {

        require(_amount <= userCollateralData[user][_currency].collateral, "Can not redeem more than collateral");
        require(_amount > 0, "Redeem amount need larger than zero");

        uint256 maxRedeemableInUsd = MaxRedeemableInUsd(user);
        uint256 maxRedeem = maxRedeemableInUsd.divideDecimal(priceGetter.getPrice(_currency));
        require(_amount <= maxRedeem, "Because lower collateral ratio, can not redeem too much");

        userCollateralData[user][_currency].collateral = userCollateralData[user][_currency].collateral.sub(_amount);

        TokenInfo storage tokeninfo = tokenInfos[_currency];
        tokeninfo.totalCollateral = tokeninfo.totalCollateral.sub(_amount);

        IERC20(tokenInfos[_currency].tokenAddr).transfer(user, _amount);

        emit RedeemCollateral(user, _currency, _amount, userCollateralData[user][_currency].collateral);
    }

    function Redeem(bytes32 _currency, uint256 _amount) public whenNotPaused returns (bool) {

        address user = msg.sender;
        _Redeem(user, _currency, _amount);
        return true;
    }

    receive() external payable whenNotPaused {
        address user = msg.sender;
        uint256 ethAmount = msg.value;
        _CollateralEth(user, ethAmount);
    }

    function _CollateralEth(address user, uint256 ethAmount) internal {

        require(ethAmount > 0, "ETH amount need more than zero");

        userCollateralData[user][Currency_ETH].collateral = userCollateralData[user][Currency_ETH].collateral.add(ethAmount);

        emit CollateralLog(user, Currency_ETH, ethAmount, userCollateralData[user][Currency_ETH].collateral);
    }

    function CollateralEth() external payable whenNotPaused returns (bool) {

        address user = msg.sender;
        uint256 ethAmount = msg.value;
        _CollateralEth(user, ethAmount);
        return true;
    }

    function RedeemETH(uint256 _amount) external whenNotPaused returns (bool) {

        address payable user = msg.sender;
        require(_amount <= userCollateralData[user][Currency_ETH].collateral, "Can not redeem more than collateral");
        require(_amount > 0, "Redeem amount need larger than zero");

        uint256 maxRedeemableInUsd = MaxRedeemableInUsd(user);

        uint256 maxRedeem = maxRedeemableInUsd.divideDecimal(priceGetter.getPrice(Currency_ETH));
        require(_amount <= maxRedeem, "Because lower collateral ratio, can not redeem too much");

        userCollateralData[user][Currency_ETH].collateral = userCollateralData[user][Currency_ETH].collateral.sub(_amount);
        user.transfer(_amount);

        emit RedeemCollateral(user, Currency_ETH, _amount, userCollateralData[user][Currency_ETH].collateral);
        return true;
    }

    function withdrawCollateral(bytes32 _currency) public onlyAdmin {

        IERC20 token = IERC20(tokenInfos[_currency].tokenAddr);
        token.transfer(msg.sender, token.balanceOf(address(this)));
    }

    event UpdateTokenSetting(bytes32 symbol, address tokenAddr, uint256 minCollateral, bool close);
    event CollateralLog(address user, bytes32 _currency, uint256 _amount, uint256 _userTotal);
    event RedeemCollateral(address user, bytes32 _currency, uint256 _amount, uint256 _userTotal);

    uint256[41] private __gap;
}