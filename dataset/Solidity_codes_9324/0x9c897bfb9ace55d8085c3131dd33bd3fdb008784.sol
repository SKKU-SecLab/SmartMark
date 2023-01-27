pragma solidity 0.8.7;

library DataTypes {

    struct ReserveData {
        bool isActive;
        uint128 liquidityIndex;
        uint128 variableBorrowIndex;
        uint128 currentLiquidityRate;
        uint128 currentVariableBorrowRate;
        uint40 lastUpdateTimestamp;
        address kTokenAddress;
        address variableDebtTokenAddress;
        address interestRateStrategyAddress;
        uint16 factor;
        uint8 decimals;
        uint8 id;
    }
}// MIT

pragma solidity ^0.8.0;

interface IAccessControlUpgradeable {

    event RoleAdminChanged(bytes32 indexed role, bytes32 indexed previousAdminRole, bytes32 indexed newAdminRole);

    event RoleGranted(bytes32 indexed role, address indexed account, address indexed sender);

    event RoleRevoked(bytes32 indexed role, address indexed account, address indexed sender);

    function hasRole(bytes32 role, address account) external view returns (bool);


    function getRoleAdmin(bytes32 role) external view returns (bytes32);


    function grantRole(bytes32 role, address account) external;


    function revokeRole(bytes32 role, address account) external;


    function renounceRole(bytes32 role, address account) external;

}// MIT

pragma solidity ^0.8.0;


interface IAccessControlEnumerableUpgradeable is IAccessControlUpgradeable {

    function getRoleMember(bytes32 role, uint256 index) external view returns (address);


    function getRoleMemberCount(bytes32 role) external view returns (uint256);

}// MIT

pragma solidity ^0.8.0;

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


abstract contract Initializable {
    bool private _initialized;

    bool private _initializing;

    modifier initializer() {
        require(_initializing ? _isConstructor() : !_initialized, "Initializable: contract is already initialized");

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

    modifier onlyInitializing() {
        require(_initializing, "Initializable: contract is not initializing");
        _;
    }

    function _isConstructor() private view returns (bool) {
        return !AddressUpgradeable.isContract(address(this));
    }
}// MIT

pragma solidity ^0.8.0;

abstract contract ContextUpgradeable is Initializable {
    function __Context_init() internal onlyInitializing {
        __Context_init_unchained();
    }

    function __Context_init_unchained() internal onlyInitializing {
    }
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
    uint256[50] private __gap;
}// MIT

pragma solidity ^0.8.0;

library StringsUpgradeable {

    bytes16 private constant _HEX_SYMBOLS = "0123456789abcdef";

    function toString(uint256 value) internal pure returns (string memory) {


        if (value == 0) {
            return "0";
        }
        uint256 temp = value;
        uint256 digits;
        while (temp != 0) {
            digits++;
            temp /= 10;
        }
        bytes memory buffer = new bytes(digits);
        while (value != 0) {
            digits -= 1;
            buffer[digits] = bytes1(uint8(48 + uint256(value % 10)));
            value /= 10;
        }
        return string(buffer);
    }

    function toHexString(uint256 value) internal pure returns (string memory) {

        if (value == 0) {
            return "0x00";
        }
        uint256 temp = value;
        uint256 length = 0;
        while (temp != 0) {
            length++;
            temp >>= 8;
        }
        return toHexString(value, length);
    }

    function toHexString(uint256 value, uint256 length) internal pure returns (string memory) {

        bytes memory buffer = new bytes(2 * length + 2);
        buffer[0] = "0";
        buffer[1] = "x";
        for (uint256 i = 2 * length + 1; i > 1; --i) {
            buffer[i] = _HEX_SYMBOLS[value & 0xf];
            value >>= 4;
        }
        require(value == 0, "Strings: hex length insufficient");
        return string(buffer);
    }
}// MIT

pragma solidity ^0.8.0;

interface IERC165Upgradeable {

    function supportsInterface(bytes4 interfaceId) external view returns (bool);

}// MIT

pragma solidity ^0.8.0;


abstract contract ERC165Upgradeable is Initializable, IERC165Upgradeable {
    function __ERC165_init() internal onlyInitializing {
        __ERC165_init_unchained();
    }

    function __ERC165_init_unchained() internal onlyInitializing {
    }
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IERC165Upgradeable).interfaceId;
    }
    uint256[50] private __gap;
}// MIT

pragma solidity ^0.8.0;


abstract contract AccessControlUpgradeable is Initializable, ContextUpgradeable, IAccessControlUpgradeable, ERC165Upgradeable {
    function __AccessControl_init() internal onlyInitializing {
        __Context_init_unchained();
        __ERC165_init_unchained();
        __AccessControl_init_unchained();
    }

    function __AccessControl_init_unchained() internal onlyInitializing {
    }
    struct RoleData {
        mapping(address => bool) members;
        bytes32 adminRole;
    }

    mapping(bytes32 => RoleData) private _roles;

    bytes32 public constant DEFAULT_ADMIN_ROLE = 0x00;

    modifier onlyRole(bytes32 role) {
        _checkRole(role, _msgSender());
        _;
    }

    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IAccessControlUpgradeable).interfaceId || super.supportsInterface(interfaceId);
    }

    function hasRole(bytes32 role, address account) public view override returns (bool) {
        return _roles[role].members[account];
    }

    function _checkRole(bytes32 role, address account) internal view {
        if (!hasRole(role, account)) {
            revert(
                string(
                    abi.encodePacked(
                        "AccessControl: account ",
                        StringsUpgradeable.toHexString(uint160(account), 20),
                        " is missing role ",
                        StringsUpgradeable.toHexString(uint256(role), 32)
                    )
                )
            );
        }
    }

    function getRoleAdmin(bytes32 role) public view override returns (bytes32) {
        return _roles[role].adminRole;
    }

    function grantRole(bytes32 role, address account) public virtual override onlyRole(getRoleAdmin(role)) {
        _grantRole(role, account);
    }

    function revokeRole(bytes32 role, address account) public virtual override onlyRole(getRoleAdmin(role)) {
        _revokeRole(role, account);
    }

    function renounceRole(bytes32 role, address account) public virtual override {
        require(account == _msgSender(), "AccessControl: can only renounce roles for self");

        _revokeRole(role, account);
    }

    function _setupRole(bytes32 role, address account) internal virtual {
        _grantRole(role, account);
    }

    function _setRoleAdmin(bytes32 role, bytes32 adminRole) internal virtual {
        bytes32 previousAdminRole = getRoleAdmin(role);
        _roles[role].adminRole = adminRole;
        emit RoleAdminChanged(role, previousAdminRole, adminRole);
    }

    function _grantRole(bytes32 role, address account) internal virtual {
        if (!hasRole(role, account)) {
            _roles[role].members[account] = true;
            emit RoleGranted(role, account, _msgSender());
        }
    }

    function _revokeRole(bytes32 role, address account) internal virtual {
        if (hasRole(role, account)) {
            _roles[role].members[account] = false;
            emit RoleRevoked(role, account, _msgSender());
        }
    }
    uint256[49] private __gap;
}// MIT

pragma solidity ^0.8.0;

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

            if (lastIndex != toDeleteIndex) {
                bytes32 lastvalue = set._values[lastIndex];

                set._values[toDeleteIndex] = lastvalue;
                set._indexes[lastvalue] = valueIndex; // Replace lastvalue's index to valueIndex
            }

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

        return set._values[index];
    }

    function _values(Set storage set) private view returns (bytes32[] memory) {

        return set._values;
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

    function values(Bytes32Set storage set) internal view returns (bytes32[] memory) {

        return _values(set._inner);
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

    function values(AddressSet storage set) internal view returns (address[] memory) {

        bytes32[] memory store = _values(set._inner);
        address[] memory result;

        assembly {
            result := store
        }

        return result;
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

    function values(UintSet storage set) internal view returns (uint256[] memory) {

        bytes32[] memory store = _values(set._inner);
        uint256[] memory result;

        assembly {
            result := store
        }

        return result;
    }
}// MIT

pragma solidity ^0.8.0;


abstract contract AccessControlEnumerableUpgradeable is Initializable, IAccessControlEnumerableUpgradeable, AccessControlUpgradeable {
    function __AccessControlEnumerable_init() internal onlyInitializing {
        __Context_init_unchained();
        __ERC165_init_unchained();
        __AccessControl_init_unchained();
        __AccessControlEnumerable_init_unchained();
    }

    function __AccessControlEnumerable_init_unchained() internal onlyInitializing {
    }
    using EnumerableSetUpgradeable for EnumerableSetUpgradeable.AddressSet;

    mapping(bytes32 => EnumerableSetUpgradeable.AddressSet) private _roleMembers;

    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IAccessControlEnumerableUpgradeable).interfaceId || super.supportsInterface(interfaceId);
    }

    function getRoleMember(bytes32 role, uint256 index) public view override returns (address) {
        return _roleMembers[role].at(index);
    }

    function getRoleMemberCount(bytes32 role) public view override returns (uint256) {
        return _roleMembers[role].length();
    }

    function _grantRole(bytes32 role, address account) internal virtual override {
        super._grantRole(role, account);
        _roleMembers[role].add(account);
    }

    function _revokeRole(bytes32 role, address account) internal virtual override {
        super._revokeRole(role, account);
        _roleMembers[role].remove(account);
    }
    uint256[49] private __gap;
}// MIT

pragma solidity ^0.8.0;


library SafeMathUpgradeable {

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
pragma solidity 0.8.7;


contract CreditSystem is AccessControlEnumerableUpgradeable {

    using SafeMathUpgradeable for uint256;
    using EnumerableSetUpgradeable for EnumerableSetUpgradeable.AddressSet;

    bytes32 public constant ROLE_CREDIT_MANAGER =
        keccak256("ROLE_CREDIT_MANAGER");

    uint8 public constant G2G_MASK = 0x0E;
    uint8 public constant CCAL_MASK = 0x0D;
    uint8 constant IS_G2G_START_BIT_POSITION = 0;
    uint8 constant IS_CCAL_START_BIT_POSITION = 1;

    struct CreditInfo {
        uint256 g2gCreditLine;
        uint256 ccalCreditLine;
        uint8 flag;
    }

    mapping(address => CreditInfo) whiteList;
    EnumerableSetUpgradeable.AddressSet private g2gWhiteSet;
    EnumerableSetUpgradeable.AddressSet private ccalWhiteSet;

    event SetG2GCreditLine(address user, uint256 amount);

    event SetCCALCreditLine(address user, uint256 amount);

    event SetG2GActive(address user, bool active);

    event SetCCALActive(address user, bool active);

    event RemoveG2GCredit(address user);

    event RemoveCCALCredit(address user);

    modifier onlyCreditManager() {

        require(
            hasRole(ROLE_CREDIT_MANAGER, _msgSender()),
            "only the manager has permission to perform this operation."
        );
        _;
    }

    function initialize() public initializer {

        __AccessControlEnumerable_init();
        _grantRole(DEFAULT_ADMIN_ROLE, _msgSender());
    }

    function setG2GCreditLine(address user, uint256 amount)
        public
        onlyCreditManager
    {

        whiteList[user].g2gCreditLine = amount;
        setG2GActive(user, amount > 0);

        emit SetG2GCreditLine(user, amount);
    }

    function setG2GActive(address user, bool active) public onlyCreditManager {

        setG2GFlag(user, active);
        if (active) {
            uint256 userG2GCreditLine = getG2GCreditLine(user);
            userG2GCreditLine > 0 ? g2gWhiteSet.add(user) : g2gWhiteSet.remove(user);
        } else {
            g2gWhiteSet.remove(user);
        }

        emit SetG2GActive(user, active);
    }

    function setG2GFlag(address user, bool active) private {

        uint8 flag = whiteList[user].flag;
        flag =
            (flag & G2G_MASK) |
            (uint8(active ? 1 : 0) << IS_G2G_START_BIT_POSITION);
        whiteList[user].flag = flag;
    }

    function setCCALCreditLine(address user, uint256 amount)
        public
        onlyCreditManager
    {

        whiteList[user].ccalCreditLine = amount;
        setCCALActive(user, amount > 0);

        emit SetCCALCreditLine(user, amount);
    }

    function setCCALActive(address user, bool active) public onlyCreditManager {

        setCCALFlag(user, active);
        if (active) {
            uint256 userCCALCreditLine = getCCALCreditLine(user);
            userCCALCreditLine > 0 ? ccalWhiteSet.add(user) : ccalWhiteSet.remove(user);
        } else {
            ccalWhiteSet.remove(user);
        }

        emit SetCCALActive(user, active);
    }

    function setCCALFlag(address user, bool active) private {

        uint8 flag = whiteList[user].flag;
        flag =
            (flag & CCAL_MASK) |
            (uint8(active ? 1 : 0) << IS_CCAL_START_BIT_POSITION);
        whiteList[user].flag = flag;
    }

    function removeG2GCredit(address user) public onlyCreditManager {

        whiteList[user].g2gCreditLine = 0;
        setG2GActive(user, false);

        emit RemoveG2GCredit(user);
    }

    function removeCCALCredit(address user) public onlyCreditManager {

        whiteList[user].ccalCreditLine = 0;
        setCCALActive(user, false);

        emit RemoveCCALCredit(user);
    }


    function getG2GCreditLine(address user) public view returns (uint256) {

        CreditInfo memory credit = whiteList[user];
        return credit.g2gCreditLine;
    }

    function getCCALCreditLine(address user) public view returns (uint256) {

        CreditInfo memory credit = whiteList[user];
        return credit.ccalCreditLine;
    }

    function getG2GWhiteList() public view returns (address[] memory) {

        return g2gWhiteSet.values();
    }

    function getCCALWhiteList() public view returns (address[] memory) {

        return ccalWhiteSet.values();
    }

    function getState(address user) public view returns (bool, bool) {

        uint8 activeFlag = whiteList[user].flag;
        return (
            activeFlag & ~G2G_MASK != 0,
            activeFlag & ~CCAL_MASK != 0
        );
    }
}// MIT
pragma solidity 0.8.7;

library KyokoMath {

    uint256 internal constant WAD = 1e18;
    uint256 internal constant halfWAD = WAD / 2;

    uint256 internal constant RAY = 1e27;
    uint256 internal constant halfRAY = RAY / 2;

    uint256 internal constant WAD_RAY_RATIO = 1e9;

  function ray() internal pure returns (uint256) {

    return RAY;
  }


  function wad() internal pure returns (uint256) {

    return WAD;
  }

  function halfRay() internal pure returns (uint256) {

    return halfRAY;
  }

  function halfWad() internal pure returns (uint256) {

    return halfWAD;
  }

  function wadMul(uint256 a, uint256 b) internal pure returns (uint256) {

    if (a == 0 || b == 0) {
      return 0;
    }

    require(a <= (type(uint256).max - halfWAD) / b, "MATH_MULTIPLICATION_OVERFLOW");

    return (a * b + halfWAD) / WAD;
  }

  function wadDiv(uint256 a, uint256 b) internal pure returns (uint256) {

    require(b != 0, "MATH_DIVISION_BY_ZERO");
    uint256 halfB = b / 2;

    require(a <= (type(uint256).max - halfB) / WAD, "MATH_MULTIPLICATION_OVERFLOW");

    return (a * WAD + halfB) / b;
  }

  function rayMul(uint256 a, uint256 b) internal pure returns (uint256) {

    if (a == 0 || b == 0) {
      return 0;
    }

    require(a <= (type(uint256).max - halfRAY) / b, "MATH_MULTIPLICATION_OVERFLOW");

    return (a * b + halfRAY) / RAY;
  }

  function rayDiv(uint256 a, uint256 b) internal pure returns (uint256) {

    require(b != 0, "MATH_DIVISION_BY_ZERO");
    uint256 halfB = b / 2;

    require(a <= (type(uint256).max - halfB) / RAY, "MATH_MULTIPLICATION_OVERFLOW");

    return (a * RAY + halfB) / b;
  }

  function rayToWad(uint256 a) internal pure returns (uint256) {

    uint256 halfRatio = WAD_RAY_RATIO / 2;
    uint256 result = halfRatio + a;
    require(result >= halfRatio, "MATH_ADDITION_OVERFLOW");

    return result / WAD_RAY_RATIO;
  }

  function wadToRay(uint256 a) internal pure returns (uint256) {

    uint256 result = a * WAD_RAY_RATIO;
    require(result / WAD_RAY_RATIO == a, "MATH_MULTIPLICATION_OVERFLOW");
    return result;
  }
}// MIT
pragma solidity 0.8.7;

library PercentageMath {

    uint256 constant PERCENTAGE_FACTOR = 1e4; //percentage plus two decimals
    uint256 constant HALF_PERCENT = PERCENTAGE_FACTOR / 2;

    function percentMul(uint256 value, uint256 percentage) internal pure returns (uint256) {

        if (value == 0 || percentage == 0) {
            return 0;
        }

        require(
            value <= (type(uint256).max - HALF_PERCENT) / percentage,
            "MATH_MULTIPLICATION_OVERFLOW"
        );

        return (value * percentage + HALF_PERCENT) / PERCENTAGE_FACTOR;
    }

    function percentDiv(uint256 value, uint256 percentage) internal pure returns (uint256) {

        require(percentage != 0, "MATH_DIVISION_BY_ZERO");
        uint256 halfPercentage = percentage / 2;

        require(
            value <= (type(uint256).max - halfPercentage) / PERCENTAGE_FACTOR,
            "MATH_MULTIPLICATION_OVERFLOW"
        );

        return (value * PERCENTAGE_FACTOR + halfPercentage) / percentage;
    }
}// MIT
pragma solidity 0.8.7;

interface IScaledBalanceToken {

  function scaledBalanceOf(address user) external view returns (uint256);


  function getScaledUserBalanceAndSupply(address user) external view returns (uint256, uint256);


  function scaledTotalSupply() external view returns (uint256);

}// MIT
pragma solidity 0.8.7;


interface ILendingPool {

    event Deposit(
        address indexed reserve,
        address user,
        address indexed onBehalfOf,
        uint256 amount
    );

    event Withdraw(
        address indexed reserve,
        address indexed user,
        address indexed to,
        uint256 amount
    );

    event Borrow(
        address indexed reserve,
        address user,
        address indexed onBehalfOf,
        uint256 amount,
        uint256 borrowRate
    );

    event Repay(
        address indexed reserve,
        address indexed user,
        address indexed repayer,
        uint256 amount
    );

    event InitReserve(
        address asset,
        address kTokenAddress,
        address variableDebtAddress,
        address interestRateStrategyAddress,
        uint8 reserveDecimals,
        uint16 reserveFactor
    );

    event Paused();

    event Unpaused();

    event ReserveDataUpdated(
        address indexed reserve,
        uint256 liquidityRate,
        uint256 variableBorrowRate,
        uint256 liquidityIndex,
        uint256 variableBorrowIndex
    );

    event ReserveFactorChanged(address indexed asset, uint256 factor);

    event ReserveActiveChanged(address indexed asset, bool active);

    event CreditStrategyChanged(address creditContract);

    function deposit(
        address asset,
        uint256 amount,
        address onBehalfOf
    ) external;


    function withdraw(
        address asset,
        uint256 amount,
        address to
    ) external returns (uint256);


    function borrow(
        address asset,
        uint256 amount,
        address onBehalfOf
    ) external;


    function repay(
        address asset,
        uint256 amount,
        address onBehalfOf
    ) external returns (uint256);


    function getUserAccountData(address user)
        external
        view
        returns (uint256 totalDebtInWEI, uint256 availableBorrowsInWEI);


    function initReserve(
        address reserve,
        address kTokenAddress,
        address variableDebtAddress,
        address interestRateStrategyAddress,
        uint8 reserveDecimals,
        uint16 reserveFactor
    ) external;


    function setReserveInterestRateStrategyAddress(
        address reserve,
        address rateStrategyAddress
    ) external;


    function getReserveNormalizedIncome(address asset)
        external
        view
        returns (uint256);


    function getReserveNormalizedVariableDebt(address asset)
        external
        view
        returns (uint256);


    function getReserveData(address asset)
        external
        view
        returns (DataTypes.ReserveData memory);


    function getReservesList() external view returns (address[] memory);


    function setPause(bool val) external;


    function paused() external view returns (bool);


    function getActive(address asset) external view returns (bool);


    function setCreditStrategy(address creditContract) external;


    function getCreditStrategy() external view returns (address);

}// MIT
pragma solidity 0.8.7;


interface IInitializableDebtToken {

  event Initialized(
    address indexed underlyingAsset,
    address indexed pool,
    uint8 debtTokenDecimals,
    string debtTokenName,
    string debtTokenSymbol,
    bytes params
  );

  function initialize(
    ILendingPool pool,
    address underlyingAsset,
    uint8 debtTokenDecimals,
    string memory debtTokenName,
    string memory debtTokenSymbol,
    bytes calldata params
  ) external;

}// MIT
pragma solidity 0.8.7;

interface IVariableDebtToken is IScaledBalanceToken, IInitializableDebtToken {

  event Mint(address indexed from, address indexed onBehalfOf, uint256 value, uint256 index);

  function mint(
    address user,
    address onBehalfOf,
    uint256 amount,
    uint256 index
  ) external returns (bool);


  event Burn(address indexed user, uint256 amount, uint256 index);

  function burn(
    address user,
    uint256 amount,
    uint256 index
  ) external;

}// MIT
pragma solidity 0.8.7;

interface IReserveInterestRateStrategy {

    function baseVariableBorrowRate() external view returns (uint256);


    function getMaxVariableBorrowRate() external view returns (uint256);


    function calculateInterestRates(
        uint256 availableLiquidity,
        uint256 totalVariableDebt,
        uint256 reserveFactor
    )
        external
        view
        returns (
            uint256,
            uint256
        );


    function calculateInterestRates(
        address reserve,
        address kToken,
        uint256 liquidityAdded,
        uint256 liquidityTaken,
        uint256 totalVariableDebt,
        uint256 reserveFactor
    )
        external
        view
        returns (
            uint256 liquidityRate,
            uint256 variableBorrowRate
        );

}// MIT
pragma solidity 0.8.7;


library MathUtils {

    using SafeMathUpgradeable for uint256;
    using KyokoMath for uint256;

    uint256 internal constant SECONDS_PER_YEAR = 365 days;

    function calculateLinearInterest(uint256 rate, uint40 lastUpdateTimestamp) 
        internal
        view
        returns (uint256)
    {

        uint256 timeDifference = block.timestamp.sub(uint256(lastUpdateTimestamp));

        return (rate.mul(timeDifference) / SECONDS_PER_YEAR).add(KyokoMath.ray());
    }

    function calculateCompoundedInterest(
        uint256 rate,
        uint40 lastUpdateTimestamp,
        uint256 currentTimestamp
    ) internal pure returns (uint256) {

        uint256 exp = currentTimestamp.sub(uint256(lastUpdateTimestamp));

        if (exp == 0) {
            return KyokoMath.ray();
        }

        uint256 expMinusOne = exp - 1;

        uint256 expMinusTwo = exp > 2 ? exp - 2 : 0;

        uint256 ratePerSecond = rate / SECONDS_PER_YEAR;

        uint256 basePowerTwo = ratePerSecond.rayMul(ratePerSecond);
        uint256 basePowerThree = basePowerTwo.rayMul(ratePerSecond);

        uint256 secondTerm = exp.mul(expMinusOne).mul(basePowerTwo) / 2;
        uint256 thirdTerm = exp.mul(expMinusOne).mul(expMinusTwo).mul(basePowerThree) / 6;

        return KyokoMath.ray().add(ratePerSecond.mul(exp)).add(secondTerm).add(thirdTerm);
    }

    function calculateCompoundedInterest(uint256 rate, uint40 lastUpdateTimestamp)
        internal
        view
        returns (uint256)
    {

        return calculateCompoundedInterest(rate, lastUpdateTimestamp, block.timestamp);
    }
}// MIT

pragma solidity ^0.8.0;

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
}// MIT

pragma solidity ^0.8.0;


interface IERC20MetadataUpgradeable is IERC20Upgradeable {

    function name() external view returns (string memory);


    function symbol() external view returns (string memory);


    function decimals() external view returns (uint8);

}// MIT

pragma solidity ^0.8.0;


contract ERC20Upgradeable is Initializable, ContextUpgradeable, IERC20Upgradeable, IERC20MetadataUpgradeable {

    mapping(address => uint256) private _balances;

    mapping(address => mapping(address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;

    function __ERC20_init(string memory name_, string memory symbol_) internal onlyInitializing {

        __Context_init_unchained();
        __ERC20_init_unchained(name_, symbol_);
    }

    function __ERC20_init_unchained(string memory name_, string memory symbol_) internal onlyInitializing {

        _name = name_;
        _symbol = symbol_;
    }

    function name() public view virtual override returns (string memory) {

        return _name;
    }

    function symbol() public view virtual override returns (string memory) {

        return _symbol;
    }

    function decimals() public view virtual override returns (uint8) {

        return 18;
    }

    function totalSupply() public view virtual override returns (uint256) {

        return _totalSupply;
    }

    function balanceOf(address account) public view virtual override returns (uint256) {

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

        uint256 currentAllowance = _allowances[sender][_msgSender()];
        require(currentAllowance >= amount, "ERC20: transfer amount exceeds allowance");
        unchecked {
            _approve(sender, _msgSender(), currentAllowance - amount);
        }

        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {

        _approve(_msgSender(), spender, _allowances[_msgSender()][spender] + addedValue);
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {

        uint256 currentAllowance = _allowances[_msgSender()][spender];
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
        unchecked {
            _approve(_msgSender(), spender, currentAllowance - subtractedValue);
        }

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

        uint256 senderBalance = _balances[sender];
        require(senderBalance >= amount, "ERC20: transfer amount exceeds balance");
        unchecked {
            _balances[sender] = senderBalance - amount;
        }
        _balances[recipient] += amount;

        emit Transfer(sender, recipient, amount);

        _afterTokenTransfer(sender, recipient, amount);
    }

    function _mint(address account, uint256 amount) internal virtual {

        require(account != address(0), "ERC20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply += amount;
        _balances[account] += amount;
        emit Transfer(address(0), account, amount);

        _afterTokenTransfer(address(0), account, amount);
    }

    function _burn(address account, uint256 amount) internal virtual {

        require(account != address(0), "ERC20: burn from the zero address");

        _beforeTokenTransfer(account, address(0), amount);

        uint256 accountBalance = _balances[account];
        require(accountBalance >= amount, "ERC20: burn amount exceeds balance");
        unchecked {
            _balances[account] = accountBalance - amount;
        }
        _totalSupply -= amount;

        emit Transfer(account, address(0), amount);

        _afterTokenTransfer(account, address(0), amount);
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

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}


    function _afterTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}

    uint256[45] private __gap;
}// MIT
pragma solidity 0.8.7;


interface IInitializableKToken {

    event Initialized(
        address indexed underlyingAsset,
        address indexed pool,
        address treasury,
        uint8 kTokenDecimals,
        string kTokenName,
        string kTokenSymbol,
        bytes params
    );

    function initialize(
        ILendingPool pool,
        address treasury,
        address underlyingAsset,
        uint8 kTokenDecimals,
        string calldata kTokenName,
        string calldata kTokenSymbol,
        bytes calldata params
    ) external;

}// MIT
pragma solidity 0.8.7;


interface IKToken is IERC20Upgradeable, IScaledBalanceToken, IInitializableKToken {

	
    event Mint(address indexed from, uint256 value, uint256 index);

    function mint(
        address user,
        uint256 amount,
        uint256 index
    ) external returns (bool);


    event Burn(address indexed from, address indexed target, uint256 value, uint256 index);

    event BalanceTransfer(address indexed from, address indexed to, uint256 value, uint256 index);

    function burn(
        address user,
        address receiverOfUnderlying,
        uint256 amount,
        uint256 index
    ) external;


    function mintToTreasury(uint256 amount, uint256 index) external;


    function transferUnderlyingTo(address user, uint256 amount) external returns (uint256);


    function handleRepayment(address user, uint256 amount) external;


    function UNDERLYING_ASSET_ADDRESS() external view returns (address);

}// MIT
pragma solidity 0.8.7;


library ReserveLogic {

    using SafeMathUpgradeable for uint256;
	using KyokoMath for uint256;
    using PercentageMath for uint256;

    event ReserveDataUpdated(
        address indexed asset,
        uint256 liquidityRate,
        uint256 variableBorrowRate,
        uint256 liquidityIndex,
        uint256 variableBorrowIndex
    );

    uint256 constant MAX_VALID_RESERVE_FACTOR = 65535;

    using ReserveLogic for DataTypes.ReserveData;

    function init(
        DataTypes.ReserveData storage reserve, 
        address kTokenAddress,
        address variableDebtTokenAddress,
        address interestRateStrategyAddress
    ) external {

        require(reserve.kTokenAddress == address(0), "the reserve already initialized");

        reserve.isActive = true;
        reserve.liquidityIndex = uint128(KyokoMath.ray());
        reserve.variableBorrowIndex = uint128(KyokoMath.ray());
        reserve.kTokenAddress = kTokenAddress;
        reserve.variableDebtTokenAddress = variableDebtTokenAddress;
        reserve.interestRateStrategyAddress = interestRateStrategyAddress;
    }

    function updateState(DataTypes.ReserveData storage reserve) internal {

        uint256 scaledVariableDebt =
            IVariableDebtToken(reserve.variableDebtTokenAddress).scaledTotalSupply();
        uint256 previousVariableBorrowIndex = reserve.variableBorrowIndex;
        uint256 previousLiquidityIndex = reserve.liquidityIndex;
        uint40 lastUpdatedTimestamp = reserve.lastUpdateTimestamp;

        (uint256 newLiquidityIndex, uint256 newVariableBorrowIndex) =
            _updateIndexes(
                reserve,
                scaledVariableDebt,
                previousLiquidityIndex,
                previousVariableBorrowIndex,
                lastUpdatedTimestamp
            );

        _mintToTreasury(
            reserve,
            scaledVariableDebt,
            previousVariableBorrowIndex,
            newLiquidityIndex,
            newVariableBorrowIndex
        );
    }

    function _updateIndexes(
        DataTypes.ReserveData storage reserve,
        uint256 scaledVariableDebt,
        uint256 liquidityIndex,
        uint256 variableBorrowIndex,
        uint40 timestamp
    ) internal returns (uint256, uint256) {

        uint256 currentLiquidityRate = reserve.currentLiquidityRate;

        uint256 newLiquidityIndex = liquidityIndex;
        uint256 newVariableBorrowIndex = variableBorrowIndex;

        if (currentLiquidityRate > 0) {
            uint256 cumulatedLiquidityInterest =
                MathUtils.calculateLinearInterest(currentLiquidityRate, timestamp);
            newLiquidityIndex = cumulatedLiquidityInterest.rayMul(liquidityIndex);
            require(newLiquidityIndex <= type(uint128).max, "RL_LIQUIDITY_INDEX_OVERFLOW");

            reserve.liquidityIndex = uint128(newLiquidityIndex);

            if (scaledVariableDebt != 0) {
                uint256 cumulatedVariableBorrowInterest =
                    MathUtils.calculateCompoundedInterest(reserve.currentVariableBorrowRate, timestamp);
                newVariableBorrowIndex = cumulatedVariableBorrowInterest.rayMul(variableBorrowIndex);
                require(
                    newVariableBorrowIndex <= type(uint128).max,
                    "RL_VARIABLE_BORROW_INDEX_OVERFLOW"
                );
                reserve.variableBorrowIndex = uint128(newVariableBorrowIndex);
            }
        }

        reserve.lastUpdateTimestamp = uint40(block.timestamp);
        return (newLiquidityIndex, newVariableBorrowIndex);
    }

    struct MintToTreasuryLocalVars {
        uint256 currentVariableDebt;
        uint256 previousVariableDebt;
        uint256 totalDebtAccrued;
        uint256 amountToMint;
        uint16 reserveFactor;
        uint40 stableSupplyUpdatedTimestamp;
    }

    function _mintToTreasury(
        DataTypes.ReserveData storage reserve,
        uint256 scaledVariableDebt,
        uint256 previousVariableBorrowIndex,
        uint256 newLiquidityIndex,
        uint256 newVariableBorrowIndex
    ) internal {

        MintToTreasuryLocalVars memory vars;

        vars.reserveFactor = getReserveFactor(reserve);

        if (vars.reserveFactor == 0) {
            return;
        }

        vars.previousVariableDebt = scaledVariableDebt.rayMul(previousVariableBorrowIndex);

        vars.currentVariableDebt = scaledVariableDebt.rayMul(newVariableBorrowIndex);

        vars.totalDebtAccrued = vars
            .currentVariableDebt
            .sub(vars.previousVariableDebt);

        vars.amountToMint = vars.totalDebtAccrued.percentMul(vars.reserveFactor);

        if (vars.amountToMint != 0) {
            IKToken(reserve.kTokenAddress).mintToTreasury(vars.amountToMint, newLiquidityIndex);
        }
    }

    struct UpdateInterestRatesLocalVars {
        uint256 availableLiquidity;
        uint256 newLiquidityRate;
        uint256 newVariableRate;
        uint256 totalVariableDebt;
    }

    function updateInterestRates(
        DataTypes.ReserveData storage reserve,
        address reserveAddress,
        address kTokenAddress,
        uint256 liquidityAdded,
        uint256 liquidityTaken
    ) internal {

        UpdateInterestRatesLocalVars memory vars;



        vars.totalVariableDebt = IVariableDebtToken(reserve.variableDebtTokenAddress)
            .scaledTotalSupply()
            .rayMul(reserve.variableBorrowIndex);

        (
            vars.newLiquidityRate,
            vars.newVariableRate
        ) = IReserveInterestRateStrategy(reserve.interestRateStrategyAddress).calculateInterestRates(
            reserveAddress,
            kTokenAddress,
            liquidityAdded,
            liquidityTaken,
            vars.totalVariableDebt,
            getReserveFactor(reserve)
        );

        require(vars.newLiquidityRate <= type(uint128).max, "RL_LIQUIDITY_RATE_OVERFLOW");
        require(vars.newVariableRate <= type(uint128).max, "RL_VARIABLE_BORROW_RATE_OVERFLOW");

        reserve.currentLiquidityRate = uint128(vars.newLiquidityRate);
        reserve.currentVariableBorrowRate = uint128(vars.newVariableRate);

        emit ReserveDataUpdated(
            reserveAddress,
            vars.newLiquidityRate,
            vars.newVariableRate,
            reserve.liquidityIndex,
            reserve.variableBorrowIndex
        );
    }

    function getNormalizedDebt(DataTypes.ReserveData storage reserve)
        internal
        view
        returns (uint256)
    {

        uint40 timestamp = reserve.lastUpdateTimestamp;

        if (timestamp == uint40(block.timestamp)) {
            return reserve.variableBorrowIndex;
        }

        uint256 cumulated =
            MathUtils.calculateCompoundedInterest(reserve.currentVariableBorrowRate, timestamp).rayMul(
                reserve.variableBorrowIndex
            );

        return cumulated;
    }

    function getNormalizedIncome(DataTypes.ReserveData storage reserve)
        internal
        view
        returns (uint256)
    {

        uint40 timestamp = reserve.lastUpdateTimestamp;

        if (timestamp == uint40(block.timestamp)) {
        return reserve.liquidityIndex;
        }

        uint256 cumulated =
            MathUtils.calculateLinearInterest(reserve.currentLiquidityRate, timestamp).rayMul(
                reserve.liquidityIndex
            );

        return cumulated;
    }

    function setActive(DataTypes.ReserveData storage self, bool active) internal {

        self.isActive = active;
    }

    function getActive(DataTypes.ReserveData storage self) internal view returns (bool) {

        return self.isActive;
    }
    
    function setReserveFactor(DataTypes.ReserveData storage self, uint16 reserveFactor)
        internal 
    {

        require(reserveFactor <= MAX_VALID_RESERVE_FACTOR, "RC_INVALID_RESERVE_FACTOR");
        self.factor = reserveFactor;
    }

    function getReserveFactor(DataTypes.ReserveData storage self)
        internal
        view
        returns (uint16)
    {

        return self.factor;
    }

    function getDecimal(DataTypes.ReserveData storage self)
        internal
        view
        returns (uint8)
    {

        return self.decimals;
    }
}// MIT
pragma solidity 0.8.7;


library GenericLogic {

    using ReserveLogic for DataTypes.ReserveData;
    using SafeMathUpgradeable for uint256;
    using KyokoMath for uint256;
    using PercentageMath for uint256;

    struct CalculateUserAccountDataVars {
        uint256 decimals;
        uint256 tokenUnit;
        uint256 compoundedBorrowBalance;
        uint256 totalDebtInWEI;
        uint256 i;
        address currentReserveAddress;
    }

    function calculateUserAccountData(
        address user,
        mapping(address => DataTypes.ReserveData) storage reservesData,
        mapping(uint256 => address) storage reserves,
        uint256 reservesCount
    )
        internal
        view
        returns (uint256)
    {

        CalculateUserAccountDataVars memory vars;
        for (vars.i = 0; vars.i < reservesCount; vars.i++) {

            vars.currentReserveAddress = reserves[vars.i];
            DataTypes.ReserveData storage currentReserve = reservesData[vars.currentReserveAddress];

            vars.decimals = currentReserve.getDecimal();
            uint256 decimals_ = 1 ether;
            vars.tokenUnit = uint256(decimals_).div(10**vars.decimals);

            uint256 currentReserveBorrows = IERC20Upgradeable(currentReserve.variableDebtTokenAddress).balanceOf(user);
            if (currentReserveBorrows > 0) {
                vars.totalDebtInWEI = vars.totalDebtInWEI.add(
                    uint256(1).mul(currentReserveBorrows).mul(vars.tokenUnit)
                );
            }
        }
        return vars.totalDebtInWEI;
    }
}// MIT
pragma solidity 0.8.7;


library ValidationLogic {

    using ReserveLogic for DataTypes.ReserveData;
    using SafeMathUpgradeable for uint256;
    using KyokoMath for uint256;
    using PercentageMath for uint256;

    uint256 public constant REBALANCE_UP_LIQUIDITY_RATE_THRESHOLD = 4000;
    uint256 public constant REBALANCE_UP_USAGE_RATIO_THRESHOLD = 0.95 * 1e27; //usage ratio of 95%

    function validateDeposit(DataTypes.ReserveData storage reserve, uint256 amount) external view {

        bool isActive = reserve.getActive();
        require(amount != 0, "VL_INVALID_AMOUNT");
        require(isActive, "VL_NO_ACTIVE_RESERVE");
    }

    function validateWithdraw(
        address reserveAddress,
        uint256 amount,
        uint256 userBalance,
        mapping(address => DataTypes.ReserveData) storage reservesData
    ) external view {

        require(amount != 0, "VL_INVALID_AMOUNT");
        require(amount <= userBalance, "VL_NOT_ENOUGH_AVAILABLE_USER_BALANCE");

        bool isActive = reservesData[reserveAddress].getActive();
        require(isActive, "VL_NO_ACTIVE_RESERVE");
    }

    struct ValidateBorrowLocalVars {
        uint256 userBorrowBalance;
        uint256 availableLiquidity;
        bool isActive;
    }


    function validateBorrow(
        uint256 availableBorrowsInWEI,
        DataTypes.ReserveData storage reserve,
        uint256 amount
    ) external view {

        ValidateBorrowLocalVars memory vars;
        require(availableBorrowsInWEI > 0, "available credit line not enough");
        uint256 decimals_ = 1 ether;
        uint256 borrowsAmountInWEI = amount.div(10**reserve.decimals).mul(uint256(decimals_));
        require(borrowsAmountInWEI <= availableBorrowsInWEI, "borrows exceed credit line");
        
        vars.isActive = reserve.getActive();

        require(vars.isActive, "VL_NO_ACTIVE_RESERVE");
        require(amount > 0, "VL_INVALID_AMOUNT");
    }

    function validateRepay(
        DataTypes.ReserveData storage reserve,
        uint256 amountSent,
        address onBehalfOf,
        uint256 variableDebt
    ) external view {

        bool isActive = reserve.getActive();

        require(isActive, "VL_NO_ACTIVE_RESERVE");

        require(amountSent > 0, "VL_INVALID_AMOUNT");

        require(variableDebt > 0, "VL_NO_DEBT_OF_SELECTED_TYPE");

        require(
            amountSent != type(uint256).max || msg.sender == onBehalfOf,
            "VL_NO_EXPLICIT_AMOUNT_TO_REPAY_ON_BEHALF"
        );
    }
}