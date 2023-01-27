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
}pragma solidity ^0.6.0;

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
}pragma solidity ^0.6.0;

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
}pragma solidity ^0.6.2;

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
}pragma solidity ^0.6.0;


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
}pragma solidity ^0.6.0;

interface IERC165 {

    function supportsInterface(bytes4 interfaceId) external view returns (bool);

}pragma solidity ^0.6.0;

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
}pragma solidity ^0.6.0;

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
}pragma solidity ^0.6.0;

library SignedSafeMath {

    int256 constant private _INT256_MIN = -2**255;

    function mul(int256 a, int256 b) internal pure returns (int256) {

        if (a == 0) {
            return 0;
        }

        require(!(a == -1 && b == _INT256_MIN), "SignedSafeMath: multiplication overflow");

        int256 c = a * b;
        require(c / a == b, "SignedSafeMath: multiplication overflow");

        return c;
    }

    function div(int256 a, int256 b) internal pure returns (int256) {

        require(b != 0, "SignedSafeMath: division by zero");
        require(!(b == -1 && a == _INT256_MIN), "SignedSafeMath: division overflow");

        int256 c = a / b;

        return c;
    }

    function sub(int256 a, int256 b) internal pure returns (int256) {

        int256 c = a - b;
        require((b >= 0 && c <= a) || (b < 0 && c > a), "SignedSafeMath: subtraction overflow");

        return c;
    }

    function add(int256 a, int256 b) internal pure returns (int256) {

        int256 c = a + b;
        require((b >= 0 && c >= a) || (b < 0 && c < a), "SignedSafeMath: addition overflow");

        return c;
    }
}pragma solidity ^0.6.0;

interface IERC20 {

    function totalSupply() external view returns (uint256);


    function balanceOf(address account) external view returns (uint256);


    function transfer(address recipient, uint256 amount) external returns (bool);


    function allowance(address owner, address spender) external view returns (uint256);


    function approve(address spender, uint256 amount) external returns (bool);


    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);


    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}pragma solidity ^0.6.2;


interface IERC721 is IERC165 {

    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);
    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);
    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);

    function balanceOf(address owner) external view returns (uint256 balance);


    function ownerOf(uint256 tokenId) external view returns (address owner);


    function safeTransferFrom(address from, address to, uint256 tokenId) external;

    function transferFrom(address from, address to, uint256 tokenId) external;

    function approve(address to, uint256 tokenId) external;

    function getApproved(uint256 tokenId) external view returns (address operator);


    function setApprovalForAll(address operator, bool _approved) external;

    function isApprovedForAll(address owner, address operator) external view returns (bool);



    function safeTransferFrom(address from, address to, uint256 tokenId, bytes calldata data) external;

}pragma solidity ^0.6.0;


contract PausableUpgradeSafe is Initializable, ContextUpgradeSafe {

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
}pragma solidity ^0.6.0;

contract ReentrancyGuardUpgradeSafe is Initializable {

    bool private _notEntered;


    function __ReentrancyGuard_init() internal initializer {

        __ReentrancyGuard_init_unchained();
    }

    function __ReentrancyGuard_init_unchained() internal initializer {



        _notEntered = true;

    }


    modifier nonReentrant() {

        require(_notEntered, "ReentrancyGuard: reentrant call");

        _notEntered = false;

        _;

        _notEntered = true;
    }

    uint256[49] private __gap;
}// MIT

pragma solidity >=0.6.0 <0.8.0;

interface IERC20Permit {

    function permit(address owner, address spender, uint256 value, uint256 deadline, uint8 v, bytes32 r, bytes32 s) external;


    function nonces(address owner) external view returns (uint256);


    function DOMAIN_SEPARATOR() external view returns (bytes32);

}// AGPL-3.0-only
pragma solidity 0.6.12;
pragma experimental ABIEncoderV2;



library FixedPoint {

    using SafeMath for uint256;
    using SignedSafeMath for int256;

    uint256 private constant FP_SCALING_FACTOR = 10**18;

    struct Unsigned {
        uint256 rawValue;
    }

    function fromUnscaledUint(uint256 a) internal pure returns (Unsigned memory) {

        return Unsigned(a.mul(FP_SCALING_FACTOR));
    }

    function isEqual(Unsigned memory a, uint256 b) internal pure returns (bool) {

        return a.rawValue == fromUnscaledUint(b).rawValue;
    }

    function isEqual(Unsigned memory a, Unsigned memory b) internal pure returns (bool) {

        return a.rawValue == b.rawValue;
    }

    function isGreaterThan(Unsigned memory a, Unsigned memory b) internal pure returns (bool) {

        return a.rawValue > b.rawValue;
    }

    function isGreaterThan(Unsigned memory a, uint256 b) internal pure returns (bool) {

        return a.rawValue > fromUnscaledUint(b).rawValue;
    }

    function isGreaterThan(uint256 a, Unsigned memory b) internal pure returns (bool) {

        return fromUnscaledUint(a).rawValue > b.rawValue;
    }

    function isGreaterThanOrEqual(Unsigned memory a, Unsigned memory b) internal pure returns (bool) {

        return a.rawValue >= b.rawValue;
    }

    function isGreaterThanOrEqual(Unsigned memory a, uint256 b) internal pure returns (bool) {

        return a.rawValue >= fromUnscaledUint(b).rawValue;
    }

    function isGreaterThanOrEqual(uint256 a, Unsigned memory b) internal pure returns (bool) {

        return fromUnscaledUint(a).rawValue >= b.rawValue;
    }

    function isLessThan(Unsigned memory a, Unsigned memory b) internal pure returns (bool) {

        return a.rawValue < b.rawValue;
    }

    function isLessThan(Unsigned memory a, uint256 b) internal pure returns (bool) {

        return a.rawValue < fromUnscaledUint(b).rawValue;
    }

    function isLessThan(uint256 a, Unsigned memory b) internal pure returns (bool) {

        return fromUnscaledUint(a).rawValue < b.rawValue;
    }

    function isLessThanOrEqual(Unsigned memory a, Unsigned memory b) internal pure returns (bool) {

        return a.rawValue <= b.rawValue;
    }

    function isLessThanOrEqual(Unsigned memory a, uint256 b) internal pure returns (bool) {

        return a.rawValue <= fromUnscaledUint(b).rawValue;
    }

    function isLessThanOrEqual(uint256 a, Unsigned memory b) internal pure returns (bool) {

        return fromUnscaledUint(a).rawValue <= b.rawValue;
    }

    function min(Unsigned memory a, Unsigned memory b) internal pure returns (Unsigned memory) {

        return a.rawValue < b.rawValue ? a : b;
    }

    function max(Unsigned memory a, Unsigned memory b) internal pure returns (Unsigned memory) {

        return a.rawValue > b.rawValue ? a : b;
    }

    function add(Unsigned memory a, Unsigned memory b) internal pure returns (Unsigned memory) {

        return Unsigned(a.rawValue.add(b.rawValue));
    }

    function add(Unsigned memory a, uint256 b) internal pure returns (Unsigned memory) {

        return add(a, fromUnscaledUint(b));
    }

    function sub(Unsigned memory a, Unsigned memory b) internal pure returns (Unsigned memory) {

        return Unsigned(a.rawValue.sub(b.rawValue));
    }

    function sub(Unsigned memory a, uint256 b) internal pure returns (Unsigned memory) {

        return sub(a, fromUnscaledUint(b));
    }

    function sub(uint256 a, Unsigned memory b) internal pure returns (Unsigned memory) {

        return sub(fromUnscaledUint(a), b);
    }

    function mul(Unsigned memory a, Unsigned memory b) internal pure returns (Unsigned memory) {

        return Unsigned(a.rawValue.mul(b.rawValue) / FP_SCALING_FACTOR);
    }

    function mul(Unsigned memory a, uint256 b) internal pure returns (Unsigned memory) {

        return Unsigned(a.rawValue.mul(b));
    }

    function mulCeil(Unsigned memory a, Unsigned memory b) internal pure returns (Unsigned memory) {

        uint256 mulRaw = a.rawValue.mul(b.rawValue);
        uint256 mulFloor = mulRaw / FP_SCALING_FACTOR;
        uint256 mod = mulRaw.mod(FP_SCALING_FACTOR);
        if (mod != 0) {
            return Unsigned(mulFloor.add(1));
        } else {
            return Unsigned(mulFloor);
        }
    }

    function mulCeil(Unsigned memory a, uint256 b) internal pure returns (Unsigned memory) {

        return Unsigned(a.rawValue.mul(b));
    }

    function div(Unsigned memory a, Unsigned memory b) internal pure returns (Unsigned memory) {

        return Unsigned(a.rawValue.mul(FP_SCALING_FACTOR).div(b.rawValue));
    }

    function div(Unsigned memory a, uint256 b) internal pure returns (Unsigned memory) {

        return Unsigned(a.rawValue.div(b));
    }

    function div(uint256 a, Unsigned memory b) internal pure returns (Unsigned memory) {

        return div(fromUnscaledUint(a), b);
    }

    function divCeil(Unsigned memory a, Unsigned memory b) internal pure returns (Unsigned memory) {

        uint256 aScaled = a.rawValue.mul(FP_SCALING_FACTOR);
        uint256 divFloor = aScaled.div(b.rawValue);
        uint256 mod = aScaled.mod(b.rawValue);
        if (mod != 0) {
            return Unsigned(divFloor.add(1));
        } else {
            return Unsigned(divFloor);
        }
    }

    function divCeil(Unsigned memory a, uint256 b) internal pure returns (Unsigned memory) {

        return divCeil(a, fromUnscaledUint(b));
    }

    function pow(Unsigned memory a, uint256 b) internal pure returns (Unsigned memory output) {

        output = fromUnscaledUint(1);
        for (uint256 i = 0; i < b; i = i.add(1)) {
            output = mul(output, a);
        }
    }

    int256 private constant SFP_SCALING_FACTOR = 10**18;

    struct Signed {
        int256 rawValue;
    }

    function fromSigned(Signed memory a) internal pure returns (Unsigned memory) {

        require(a.rawValue >= 0, "Negative value provided");
        return Unsigned(uint256(a.rawValue));
    }

    function fromUnsigned(Unsigned memory a) internal pure returns (Signed memory) {

        require(a.rawValue <= uint256(type(int256).max), "Unsigned too large");
        return Signed(int256(a.rawValue));
    }

    function fromUnscaledInt(int256 a) internal pure returns (Signed memory) {

        return Signed(a.mul(SFP_SCALING_FACTOR));
    }

    function isEqual(Signed memory a, int256 b) internal pure returns (bool) {

        return a.rawValue == fromUnscaledInt(b).rawValue;
    }

    function isEqual(Signed memory a, Signed memory b) internal pure returns (bool) {

        return a.rawValue == b.rawValue;
    }

    function isGreaterThan(Signed memory a, Signed memory b) internal pure returns (bool) {

        return a.rawValue > b.rawValue;
    }

    function isGreaterThan(Signed memory a, int256 b) internal pure returns (bool) {

        return a.rawValue > fromUnscaledInt(b).rawValue;
    }

    function isGreaterThan(int256 a, Signed memory b) internal pure returns (bool) {

        return fromUnscaledInt(a).rawValue > b.rawValue;
    }

    function isGreaterThanOrEqual(Signed memory a, Signed memory b) internal pure returns (bool) {

        return a.rawValue >= b.rawValue;
    }

    function isGreaterThanOrEqual(Signed memory a, int256 b) internal pure returns (bool) {

        return a.rawValue >= fromUnscaledInt(b).rawValue;
    }

    function isGreaterThanOrEqual(int256 a, Signed memory b) internal pure returns (bool) {

        return fromUnscaledInt(a).rawValue >= b.rawValue;
    }

    function isLessThan(Signed memory a, Signed memory b) internal pure returns (bool) {

        return a.rawValue < b.rawValue;
    }

    function isLessThan(Signed memory a, int256 b) internal pure returns (bool) {

        return a.rawValue < fromUnscaledInt(b).rawValue;
    }

    function isLessThan(int256 a, Signed memory b) internal pure returns (bool) {

        return fromUnscaledInt(a).rawValue < b.rawValue;
    }

    function isLessThanOrEqual(Signed memory a, Signed memory b) internal pure returns (bool) {

        return a.rawValue <= b.rawValue;
    }

    function isLessThanOrEqual(Signed memory a, int256 b) internal pure returns (bool) {

        return a.rawValue <= fromUnscaledInt(b).rawValue;
    }

    function isLessThanOrEqual(int256 a, Signed memory b) internal pure returns (bool) {

        return fromUnscaledInt(a).rawValue <= b.rawValue;
    }

    function min(Signed memory a, Signed memory b) internal pure returns (Signed memory) {

        return a.rawValue < b.rawValue ? a : b;
    }

    function max(Signed memory a, Signed memory b) internal pure returns (Signed memory) {

        return a.rawValue > b.rawValue ? a : b;
    }

    function add(Signed memory a, Signed memory b) internal pure returns (Signed memory) {

        return Signed(a.rawValue.add(b.rawValue));
    }

    function add(Signed memory a, int256 b) internal pure returns (Signed memory) {

        return add(a, fromUnscaledInt(b));
    }

    function sub(Signed memory a, Signed memory b) internal pure returns (Signed memory) {

        return Signed(a.rawValue.sub(b.rawValue));
    }

    function sub(Signed memory a, int256 b) internal pure returns (Signed memory) {

        return sub(a, fromUnscaledInt(b));
    }

    function sub(int256 a, Signed memory b) internal pure returns (Signed memory) {

        return sub(fromUnscaledInt(a), b);
    }

    function mul(Signed memory a, Signed memory b) internal pure returns (Signed memory) {

        return Signed(a.rawValue.mul(b.rawValue) / SFP_SCALING_FACTOR);
    }

    function mul(Signed memory a, int256 b) internal pure returns (Signed memory) {

        return Signed(a.rawValue.mul(b));
    }

    function mulAwayFromZero(Signed memory a, Signed memory b) internal pure returns (Signed memory) {

        int256 mulRaw = a.rawValue.mul(b.rawValue);
        int256 mulTowardsZero = mulRaw / SFP_SCALING_FACTOR;
        int256 mod = mulRaw % SFP_SCALING_FACTOR;
        if (mod != 0) {
            bool isResultPositive = isLessThan(a, 0) == isLessThan(b, 0);
            int256 valueToAdd = isResultPositive ? int256(1) : int256(-1);
            return Signed(mulTowardsZero.add(valueToAdd));
        } else {
            return Signed(mulTowardsZero);
        }
    }

    function mulAwayFromZero(Signed memory a, int256 b) internal pure returns (Signed memory) {

        return Signed(a.rawValue.mul(b));
    }

    function div(Signed memory a, Signed memory b) internal pure returns (Signed memory) {

        return Signed(a.rawValue.mul(SFP_SCALING_FACTOR).div(b.rawValue));
    }

    function div(Signed memory a, int256 b) internal pure returns (Signed memory) {

        return Signed(a.rawValue.div(b));
    }

    function div(int256 a, Signed memory b) internal pure returns (Signed memory) {

        return div(fromUnscaledInt(a), b);
    }

    function divAwayFromZero(Signed memory a, Signed memory b) internal pure returns (Signed memory) {

        int256 aScaled = a.rawValue.mul(SFP_SCALING_FACTOR);
        int256 divTowardsZero = aScaled.div(b.rawValue);
        int256 mod = aScaled % b.rawValue;
        if (mod != 0) {
            bool isResultPositive = isLessThan(a, 0) == isLessThan(b, 0);
            int256 valueToAdd = isResultPositive ? int256(1) : int256(-1);
            return Signed(divTowardsZero.add(valueToAdd));
        } else {
            return Signed(divTowardsZero);
        }
    }

    function divAwayFromZero(Signed memory a, int256 b) internal pure returns (Signed memory) {

        return divAwayFromZero(a, fromUnscaledInt(b));
    }

    function pow(Signed memory a, uint256 b) internal pure returns (Signed memory output) {

        output = fromUnscaledInt(1);
        for (uint256 i = 0; i < b; i = i.add(1)) {
            output = mul(output, a);
        }
    }
}// MIT

pragma solidity 0.6.12;



interface IERC20withDec is IERC20 {

  function decimals() external view returns (uint8);

}// MIT
pragma solidity 0.6.12;


interface ICUSDCContract is IERC20withDec {


  function mint(uint256 mintAmount) external returns (uint256);


  function redeem(uint256 redeemTokens) external returns (uint256);


  function redeemUnderlying(uint256 redeemAmount) external returns (uint256);


  function borrow(uint256 borrowAmount) external returns (uint256);


  function repayBorrow(uint256 repayAmount) external returns (uint256);


  function repayBorrowBehalf(address borrower, uint256 repayAmount) external returns (uint256);


  function liquidateBorrow(
    address borrower,
    uint256 repayAmount,
    address cTokenCollateral
  ) external returns (uint256);


  function getAccountSnapshot(address account)
    external
    view
    returns (
      uint256,
      uint256,
      uint256,
      uint256
    );


  function balanceOfUnderlying(address owner) external returns (uint256);


  function exchangeRateCurrent() external returns (uint256);



  function _addReserves(uint256 addAmount) external returns (uint256);

}// MIT

pragma solidity 0.6.12;

abstract contract ICreditDesk {
  uint256 public totalWritedowns;
  uint256 public totalLoansOutstanding;

  function setUnderwriterGovernanceLimit(address underwriterAddress, uint256 limit) external virtual;

  function drawdown(address creditLineAddress, uint256 amount) external virtual;

  function pay(address creditLineAddress, uint256 amount) external virtual;

  function assessCreditLine(address creditLineAddress) external virtual;

  function applyPayment(address creditLineAddress, uint256 amount) external virtual;

  function getNextPaymentAmount(address creditLineAddress, uint256 asOfBLock) external view virtual returns (uint256);
}// MIT

pragma solidity 0.6.12;

interface ICreditLine {

  function borrower() external view returns (address);


  function limit() external view returns (uint256);


  function interestApr() external view returns (uint256);


  function paymentPeriodInDays() external view returns (uint256);


  function termInDays() external view returns (uint256);


  function lateFeeApr() external view returns (uint256);


  function balance() external view returns (uint256);


  function interestOwed() external view returns (uint256);


  function principalOwed() external view returns (uint256);


  function termEndTime() external view returns (uint256);


  function nextDueTime() external view returns (uint256);


  function interestAccruedAsOf() external view returns (uint256);


  function lastFullPaymentTime() external view returns (uint256);

}// MIT

pragma solidity 0.6.12;


interface IFidu is IERC20withDec {

  function mintTo(address to, uint256 amount) external;


  function burnFrom(address to, uint256 amount) external;


  function renounceRole(bytes32 role, address account) external;

}// MIT

pragma solidity 0.6.12;

interface IGoldfinchConfig {

  function getNumber(uint256 index) external returns (uint256);


  function getAddress(uint256 index) external returns (address);


  function setAddress(uint256 index, address newAddress) external returns (address);


  function setNumber(uint256 index, uint256 newNumber) external returns (uint256);

}// MIT

pragma solidity 0.6.12;

interface IGoldfinchFactory {

  function createCreditLine() external returns (address);


  function createBorrower(address owner) external returns (address);


  function createPool(
    address _borrower,
    uint256 _juniorFeePercent,
    uint256 _limit,
    uint256 _interestApr,
    uint256 _paymentPeriodInDays,
    uint256 _termInDays,
    uint256 _lateFeeApr
  ) external returns (address);


  function createMigratedPool(
    address _borrower,
    uint256 _juniorFeePercent,
    uint256 _limit,
    uint256 _interestApr,
    uint256 _paymentPeriodInDays,
    uint256 _termInDays,
    uint256 _lateFeeApr
  ) external returns (address);


  function updateGoldfinchConfig() external;

}// MIT

pragma solidity 0.6.12;


abstract contract IV2CreditLine is ICreditLine {
  function principal() external view virtual returns (uint256);

  function totalInterestAccrued() external view virtual returns (uint256);

  function termStartTime() external view virtual returns (uint256);

  function setLimit(uint256 newAmount) external virtual;

  function setBalance(uint256 newBalance) external virtual;

  function setPrincipal(uint256 _principal) external virtual;

  function setTotalInterestAccrued(uint256 _interestAccrued) external virtual;

  function drawdown(uint256 amount) external virtual;

  function assess()
    external
    virtual
    returns (
      uint256,
      uint256,
      uint256
    );

  function initialize(
    address _config,
    address owner,
    address _borrower,
    uint256 _limit,
    uint256 _interestApr,
    uint256 _paymentPeriodInDays,
    uint256 _termInDays,
    uint256 _lateFeeApr
  ) public virtual;

  function setTermEndTime(uint256 newTermEndTime) external virtual;

  function setNextDueTime(uint256 newNextDueTime) external virtual;

  function setInterestOwed(uint256 newInterestOwed) external virtual;

  function setPrincipalOwed(uint256 newPrincipalOwed) external virtual;

  function setInterestAccruedAsOf(uint256 newInterestAccruedAsOf) external virtual;

  function setWritedownAmount(uint256 newWritedownAmount) external virtual;

  function setLastFullPaymentTime(uint256 newLastFullPaymentTime) external virtual;

  function setLateFeeApr(uint256 newLateFeeApr) external virtual;

  function updateGoldfinchConfig() external virtual;
}// MIT

pragma solidity 0.6.12;

abstract contract IV1CreditLine {
  address public borrower;
  address public underwriter;
  uint256 public limit;
  uint256 public interestApr;
  uint256 public paymentPeriodInDays;
  uint256 public termInDays;
  uint256 public lateFeeApr;

  uint256 public balance;
  uint256 public interestOwed;
  uint256 public principalOwed;
  uint256 public termEndBlock;
  uint256 public nextDueBlock;
  uint256 public interestAccruedAsOfBlock;
  uint256 public writedownAmount;
  uint256 public lastFullPaymentBlock;

  function setLimit(uint256 newAmount) external virtual;

  function setBalance(uint256 newBalance) external virtual;
}// MIT

pragma solidity 0.6.12;


abstract contract ITranchedPool {
  IV2CreditLine public creditLine;
  uint256 public createdAt;

  enum Tranches {Reserved, Senior, Junior}

  struct TrancheInfo {
    uint256 id;
    uint256 principalDeposited;
    uint256 principalSharePrice;
    uint256 interestSharePrice;
    uint256 lockedUntil;
  }

  function initialize(
    address _config,
    address _borrower,
    uint256 _juniorFeePercent,
    uint256 _limit,
    uint256 _interestApr,
    uint256 _paymentPeriodInDays,
    uint256 _termInDays,
    uint256 _lateFeeApr
  ) public virtual;

  function getTranche(uint256 tranche) external view virtual returns (TrancheInfo memory);

  function pay(uint256 amount) external virtual;

  function lockJuniorCapital() external virtual;

  function lockPool() external virtual;

  function drawdown(uint256 amount) external virtual;

  function deposit(uint256 tranche, uint256 amount) external virtual returns (uint256 tokenId);

  function assess() external virtual;

  function depositWithPermit(
    uint256 tranche,
    uint256 amount,
    uint256 deadline,
    uint8 v,
    bytes32 r,
    bytes32 s
  ) external virtual returns (uint256 tokenId);

  function availableToWithdraw(uint256 tokenId)
    external
    view
    virtual
    returns (uint256 interestRedeemable, uint256 principalRedeemable);

  function withdraw(uint256 tokenId, uint256 amount)
    external
    virtual
    returns (uint256 interestWithdrawn, uint256 principalWithdrawn);

  function withdrawMax(uint256 tokenId)
    external
    virtual
    returns (uint256 interestWithdrawn, uint256 principalWithdrawn);

  function withdrawMultiple(uint256[] calldata tokenIds, uint256[] calldata amounts) external virtual;
}// MIT

pragma solidity 0.6.12;


abstract contract IMigratedTranchedPool is ITranchedPool {
  function migrateCreditLineToV2(
    IV1CreditLine clToMigrate,
    uint256 termEndTime,
    uint256 nextDueTime,
    uint256 interestAccruedAsOf,
    uint256 lastFullPaymentTime,
    uint256 totalInterestPaid
  ) external virtual returns (IV2CreditLine);
}// MIT

pragma solidity 0.6.12;

abstract contract IPool {
  uint256 public sharePrice;

  function deposit(uint256 amount) external virtual;

  function withdraw(uint256 usdcAmount) external virtual;

  function withdrawInFidu(uint256 fiduAmount) external virtual;

  function collectInterestAndPrincipal(
    address from,
    uint256 interest,
    uint256 principal
  ) public virtual;

  function transferFrom(
    address from,
    address to,
    uint256 amount
  ) public virtual returns (bool);

  function drawdown(address to, uint256 amount) public virtual returns (bool);

  function sweepToCompound() public virtual;

  function sweepFromCompound() public virtual;

  function distributeLosses(address creditlineAddress, int256 writedownDelta) external virtual;

  function assets() public view virtual returns (uint256);
}// MIT

pragma solidity 0.6.12;


interface IPoolTokens is IERC721 {

  event TokenMinted(
    address indexed owner,
    address indexed pool,
    uint256 indexed tokenId,
    uint256 amount,
    uint256 tranche
  );

  event TokenRedeemed(
    address indexed owner,
    address indexed pool,
    uint256 indexed tokenId,
    uint256 principalRedeemed,
    uint256 interestRedeemed,
    uint256 tranche
  );
  event TokenBurned(address indexed owner, address indexed pool, uint256 indexed tokenId);

  struct TokenInfo {
    address pool;
    uint256 tranche;
    uint256 principalAmount;
    uint256 principalRedeemed;
    uint256 interestRedeemed;
  }

  struct MintParams {
    uint256 principalAmount;
    uint256 tranche;
  }

  function mint(MintParams calldata params, address to) external returns (uint256);


  function redeem(
    uint256 tokenId,
    uint256 principalRedeemed,
    uint256 interestRedeemed
  ) external;


  function burn(uint256 tokenId) external;


  function onPoolCreated(address newPool) external;


  function getTokenInfo(uint256 tokenId) external view returns (TokenInfo memory);


  function validPool(address sender) external view returns (bool);


  function isApprovedOrOwner(address spender, uint256 tokenId) external view returns (bool);

}// MIT

pragma solidity 0.6.12;


abstract contract ISeniorPool {
  uint256 public sharePrice;
  uint256 public totalLoansOutstanding;
  uint256 public totalWritedowns;

  function deposit(uint256 amount) external virtual returns (uint256 depositShares);

  function depositWithPermit(
    uint256 amount,
    uint256 deadline,
    uint8 v,
    bytes32 r,
    bytes32 s
  ) external virtual returns (uint256 depositShares);

  function withdraw(uint256 usdcAmount) external virtual returns (uint256 amount);

  function withdrawInFidu(uint256 fiduAmount) external virtual returns (uint256 amount);

  function sweepToCompound() public virtual;

  function sweepFromCompound() public virtual;

  function invest(ITranchedPool pool) public virtual;

  function estimateInvestment(ITranchedPool pool) public view virtual returns (uint256);

  function investJunior(ITranchedPool pool, uint256 amount) public virtual;

  function redeem(uint256 tokenId) public virtual;

  function writedown(uint256 tokenId) public virtual;

  function calculateWritedown(uint256 tokenId) public view virtual returns (uint256 writedownAmount);

  function assets() public view virtual returns (uint256);

  function getNumShares(uint256 amount) public view virtual returns (uint256);
}// MIT

pragma solidity 0.6.12;


abstract contract ISeniorPoolStrategy {
  function invest(ISeniorPool seniorPool, ITranchedPool pool) public view virtual returns (uint256 amount);

  function estimateInvestment(ISeniorPool seniorPool, ITranchedPool pool) public view virtual returns (uint256);
}// MIT

pragma solidity 0.6.12;


abstract contract SafeERC20Transfer {
  function safeERC20Transfer(
    IERC20 erc20,
    address to,
    uint256 amount,
    string memory message
  ) internal {
    require(to != address(0), "Can't send to zero address");
    bool success = erc20.transfer(to, amount);
    require(success, message);
  }

  function safeERC20Transfer(
    IERC20 erc20,
    address to,
    uint256 amount
  ) internal {
    safeERC20Transfer(erc20, to, amount, "Failed to transfer ERC20");
  }

  function safeERC20TransferFrom(
    IERC20 erc20,
    address from,
    address to,
    uint256 amount,
    string memory message
  ) internal {
    require(to != address(0), "Can't send to zero address");
    bool success = erc20.transferFrom(from, to, amount);
    require(success, message);
  }

  function safeERC20TransferFrom(
    IERC20 erc20,
    address from,
    address to,
    uint256 amount
  ) internal {
    string memory message = "Failed to transfer ERC20";
    safeERC20TransferFrom(erc20, from, to, amount, message);
  }

  function safeERC20Approve(
    IERC20 erc20,
    address spender,
    uint256 allowance,
    string memory message
  ) internal {
    bool success = erc20.approve(spender, allowance);
    require(success, message);
  }

  function safeERC20Approve(
    IERC20 erc20,
    address spender,
    uint256 allowance
  ) internal {
    string memory message = "Failed to approve ERC20";
    safeERC20Approve(erc20, spender, allowance, message);
  }
}// MIT
pragma solidity 0.6.12;



contract PauserPausable is AccessControlUpgradeSafe, PausableUpgradeSafe {

  bytes32 public constant PAUSER_ROLE = keccak256("PAUSER_ROLE");

  function __PauserPausable__init() public initializer {

    __Pausable_init_unchained();
  }


  function pause() public onlyPauserRole {

    _pause();
  }

  function unpause() public onlyPauserRole {

    _unpause();
  }

  modifier onlyPauserRole() {

    require(hasRole(PAUSER_ROLE, _msgSender()), "Must have pauser role to perform this action");
    _;
  }
}// MIT

pragma solidity 0.6.12;



contract BaseUpgradeablePausable is
  Initializable,
  AccessControlUpgradeSafe,
  PauserPausable,
  ReentrancyGuardUpgradeSafe
{

  bytes32 public constant OWNER_ROLE = keccak256("OWNER_ROLE");
  using SafeMath for uint256;
  uint256[50] private __gap1;
  uint256[50] private __gap2;
  uint256[50] private __gap3;
  uint256[50] private __gap4;

  function __BaseUpgradeablePausable__init(address owner) public initializer {

    require(owner != address(0), "Owner cannot be the zero address");
    __AccessControl_init_unchained();
    __Pausable_init_unchained();
    __ReentrancyGuard_init_unchained();

    _setupRole(OWNER_ROLE, owner);
    _setupRole(PAUSER_ROLE, owner);

    _setRoleAdmin(PAUSER_ROLE, OWNER_ROLE);
    _setRoleAdmin(OWNER_ROLE, OWNER_ROLE);
  }

  function isAdmin() public view returns (bool) {

    return hasRole(OWNER_ROLE, _msgSender());
  }

  modifier onlyAdmin() {

    require(isAdmin(), "Must have admin role to perform this action");
    _;
  }
}// MIT

pragma solidity 0.6.12;


library ConfigOptions {

  enum Numbers {
    TransactionLimit,
    TotalFundsLimit,
    MaxUnderwriterLimit,
    ReserveDenominator,
    WithdrawFeeDenominator,
    LatenessGracePeriodInDays,
    LatenessMaxDays,
    DrawdownPeriodInSeconds,
    TransferRestrictionPeriodInDays,
    LeverageRatio
  }
  enum Addresses {
    Pool,
    CreditLineImplementation,
    GoldfinchFactory,
    CreditDesk,
    Fidu,
    USDC,
    TreasuryReserve,
    ProtocolAdmin,
    OneInch,
    TrustedForwarder,
    CUSDCContract,
    GoldfinchConfig,
    PoolTokens,
    TranchedPoolImplementation,
    SeniorPool,
    SeniorPoolStrategy,
    MigratedTranchedPoolImplementation,
    BorrowerImplementation
  }

  function getNumberName(uint256 number) public pure returns (string memory) {

    Numbers numberName = Numbers(number);
    if (Numbers.TransactionLimit == numberName) {
      return "TransactionLimit";
    }
    if (Numbers.TotalFundsLimit == numberName) {
      return "TotalFundsLimit";
    }
    if (Numbers.MaxUnderwriterLimit == numberName) {
      return "MaxUnderwriterLimit";
    }
    if (Numbers.ReserveDenominator == numberName) {
      return "ReserveDenominator";
    }
    if (Numbers.WithdrawFeeDenominator == numberName) {
      return "WithdrawFeeDenominator";
    }
    if (Numbers.LatenessGracePeriodInDays == numberName) {
      return "LatenessGracePeriodInDays";
    }
    if (Numbers.LatenessMaxDays == numberName) {
      return "LatenessMaxDays";
    }
    if (Numbers.DrawdownPeriodInSeconds == numberName) {
      return "DrawdownPeriodInSeconds";
    }
    if (Numbers.TransferRestrictionPeriodInDays == numberName) {
      return "TransferRestrictionPeriodInDays";
    }
    if (Numbers.LeverageRatio == numberName) {
      return "LeverageRatio";
    }
    revert("Unknown value passed to getNumberName");
  }

  function getAddressName(uint256 addressKey) public pure returns (string memory) {

    Addresses addressName = Addresses(addressKey);
    if (Addresses.Pool == addressName) {
      return "Pool";
    }
    if (Addresses.CreditLineImplementation == addressName) {
      return "CreditLineImplementation";
    }
    if (Addresses.GoldfinchFactory == addressName) {
      return "GoldfinchFactory";
    }
    if (Addresses.CreditDesk == addressName) {
      return "CreditDesk";
    }
    if (Addresses.Fidu == addressName) {
      return "Fidu";
    }
    if (Addresses.USDC == addressName) {
      return "USDC";
    }
    if (Addresses.TreasuryReserve == addressName) {
      return "TreasuryReserve";
    }
    if (Addresses.ProtocolAdmin == addressName) {
      return "ProtocolAdmin";
    }
    if (Addresses.OneInch == addressName) {
      return "OneInch";
    }
    if (Addresses.TrustedForwarder == addressName) {
      return "TrustedForwarder";
    }
    if (Addresses.CUSDCContract == addressName) {
      return "CUSDCContract";
    }
    if (Addresses.PoolTokens == addressName) {
      return "PoolTokens";
    }
    if (Addresses.TranchedPoolImplementation == addressName) {
      return "TranchedPoolImplementation";
    }
    if (Addresses.SeniorPool == addressName) {
      return "SeniorPool";
    }
    if (Addresses.SeniorPoolStrategy == addressName) {
      return "SeniorPoolStrategy";
    }
    if (Addresses.MigratedTranchedPoolImplementation == addressName) {
      return "MigratedTranchedPoolImplementation";
    }
    if (Addresses.BorrowerImplementation == addressName) {
      return "BorrowerImplementation";
    }
    revert("Unknown value passed to getAddressName");
  }
}// MIT

pragma solidity 0.6.12;



contract GoldfinchConfig is BaseUpgradeablePausable {

  bytes32 public constant GO_LISTER_ROLE = keccak256("GO_LISTER_ROLE");

  mapping(uint256 => address) public addresses;
  mapping(uint256 => uint256) public numbers;
  mapping(address => bool) public goList;

  event AddressUpdated(address owner, uint256 index, address oldValue, address newValue);
  event NumberUpdated(address owner, uint256 index, uint256 oldValue, uint256 newValue);

  event GoListed(address indexed member);
  event NoListed(address indexed member);

  bool public valuesInitialized;

  function initialize(address owner) public initializer {

    require(owner != address(0), "Owner address cannot be empty");

    __BaseUpgradeablePausable__init(owner);

    _setupRole(GO_LISTER_ROLE, owner);

    _setRoleAdmin(GO_LISTER_ROLE, OWNER_ROLE);
  }

  function setAddress(uint256 addressIndex, address newAddress) public onlyAdmin {

    require(addresses[addressIndex] == address(0), "Address has already been initialized");

    emit AddressUpdated(msg.sender, addressIndex, addresses[addressIndex], newAddress);
    addresses[addressIndex] = newAddress;
  }

  function setNumber(uint256 index, uint256 newNumber) public onlyAdmin {

    emit NumberUpdated(msg.sender, index, numbers[index], newNumber);
    numbers[index] = newNumber;
  }

  function setTreasuryReserve(address newTreasuryReserve) public onlyAdmin {

    uint256 key = uint256(ConfigOptions.Addresses.TreasuryReserve);
    emit AddressUpdated(msg.sender, key, addresses[key], newTreasuryReserve);
    addresses[key] = newTreasuryReserve;
  }

  function setSeniorPoolStrategy(address newStrategy) public onlyAdmin {

    uint256 key = uint256(ConfigOptions.Addresses.SeniorPoolStrategy);
    emit AddressUpdated(msg.sender, key, addresses[key], newStrategy);
    addresses[key] = newStrategy;
  }

  function setCreditLineImplementation(address newAddress) public onlyAdmin {

    uint256 key = uint256(ConfigOptions.Addresses.CreditLineImplementation);
    emit AddressUpdated(msg.sender, key, addresses[key], newAddress);
    addresses[key] = newAddress;
  }

  function setBorrowerImplementation(address newAddress) public onlyAdmin {

    uint256 key = uint256(ConfigOptions.Addresses.BorrowerImplementation);
    emit AddressUpdated(msg.sender, key, addresses[key], newAddress);
    addresses[key] = newAddress;
  }

  function setGoldfinchConfig(address newAddress) public onlyAdmin {

    uint256 key = uint256(ConfigOptions.Addresses.GoldfinchConfig);
    emit AddressUpdated(msg.sender, key, addresses[key], newAddress);
    addresses[key] = newAddress;
  }

  function initializeFromOtherConfig(address _initialConfig) public onlyAdmin {

    require(!valuesInitialized, "Already initialized values");
    IGoldfinchConfig initialConfig = IGoldfinchConfig(_initialConfig);
    for (uint256 i = 0; i < 10; i++) {
      setNumber(i, initialConfig.getNumber(i));
    }

    for (uint256 i = 0; i < 11; i++) {
      if (getAddress(i) == address(0)) {
        setAddress(i, initialConfig.getAddress(i));
      }
    }
    valuesInitialized = true;
  }

  function addToGoList(address _member) public onlyGoListerRole {

    goList[_member] = true;
    emit GoListed(_member);
  }

  function removeFromGoList(address _member) public onlyGoListerRole {

    goList[_member] = false;
    emit NoListed(_member);
  }

  function bulkAddToGoList(address[] calldata _members) external onlyGoListerRole {

    for (uint256 i = 0; i < _members.length; i++) {
      addToGoList(_members[i]);
    }
  }

  function bulkRemoveFromGoList(address[] calldata _members) external onlyGoListerRole {

    for (uint256 i = 0; i < _members.length; i++) {
      removeFromGoList(_members[i]);
    }
  }

  function getAddress(uint256 index) public view returns (address) {

    return addresses[index];
  }

  function getNumber(uint256 index) public view returns (uint256) {

    return numbers[index];
  }

  modifier onlyGoListerRole() {

    require(hasRole(GO_LISTER_ROLE, _msgSender()), "Must have go-lister role to perform this action");
    _;
  }
}// MIT

pragma solidity 0.6.12;



library ConfigHelper {

  function getPool(GoldfinchConfig config) internal view returns (IPool) {

    return IPool(poolAddress(config));
  }

  function getSeniorPool(GoldfinchConfig config) internal view returns (ISeniorPool) {

    return ISeniorPool(seniorPoolAddress(config));
  }

  function getSeniorPoolStrategy(GoldfinchConfig config) internal view returns (ISeniorPoolStrategy) {

    return ISeniorPoolStrategy(seniorPoolStrategyAddress(config));
  }

  function getUSDC(GoldfinchConfig config) internal view returns (IERC20withDec) {

    return IERC20withDec(usdcAddress(config));
  }

  function getCreditDesk(GoldfinchConfig config) internal view returns (ICreditDesk) {

    return ICreditDesk(creditDeskAddress(config));
  }

  function getFidu(GoldfinchConfig config) internal view returns (IFidu) {

    return IFidu(fiduAddress(config));
  }

  function getCUSDCContract(GoldfinchConfig config) internal view returns (ICUSDCContract) {

    return ICUSDCContract(cusdcContractAddress(config));
  }

  function getPoolTokens(GoldfinchConfig config) internal view returns (IPoolTokens) {

    return IPoolTokens(poolTokensAddress(config));
  }

  function getGoldfinchFactory(GoldfinchConfig config) internal view returns (IGoldfinchFactory) {

    return IGoldfinchFactory(goldfinchFactoryAddress(config));
  }

  function oneInchAddress(GoldfinchConfig config) internal view returns (address) {

    return config.getAddress(uint256(ConfigOptions.Addresses.OneInch));
  }

  function creditLineImplementationAddress(GoldfinchConfig config) internal view returns (address) {

    return config.getAddress(uint256(ConfigOptions.Addresses.CreditLineImplementation));
  }

  function trustedForwarderAddress(GoldfinchConfig config) internal view returns (address) {

    return config.getAddress(uint256(ConfigOptions.Addresses.TrustedForwarder));
  }

  function configAddress(GoldfinchConfig config) internal view returns (address) {

    return config.getAddress(uint256(ConfigOptions.Addresses.GoldfinchConfig));
  }

  function poolAddress(GoldfinchConfig config) internal view returns (address) {

    return config.getAddress(uint256(ConfigOptions.Addresses.Pool));
  }

  function poolTokensAddress(GoldfinchConfig config) internal view returns (address) {

    return config.getAddress(uint256(ConfigOptions.Addresses.PoolTokens));
  }

  function seniorPoolAddress(GoldfinchConfig config) internal view returns (address) {

    return config.getAddress(uint256(ConfigOptions.Addresses.SeniorPool));
  }

  function seniorPoolStrategyAddress(GoldfinchConfig config) internal view returns (address) {

    return config.getAddress(uint256(ConfigOptions.Addresses.SeniorPoolStrategy));
  }

  function creditDeskAddress(GoldfinchConfig config) internal view returns (address) {

    return config.getAddress(uint256(ConfigOptions.Addresses.CreditDesk));
  }

  function goldfinchFactoryAddress(GoldfinchConfig config) internal view returns (address) {

    return config.getAddress(uint256(ConfigOptions.Addresses.GoldfinchFactory));
  }

  function fiduAddress(GoldfinchConfig config) internal view returns (address) {

    return config.getAddress(uint256(ConfigOptions.Addresses.Fidu));
  }

  function cusdcContractAddress(GoldfinchConfig config) internal view returns (address) {

    return config.getAddress(uint256(ConfigOptions.Addresses.CUSDCContract));
  }

  function usdcAddress(GoldfinchConfig config) internal view returns (address) {

    return config.getAddress(uint256(ConfigOptions.Addresses.USDC));
  }

  function tranchedPoolAddress(GoldfinchConfig config) internal view returns (address) {

    return config.getAddress(uint256(ConfigOptions.Addresses.TranchedPoolImplementation));
  }

  function migratedTranchedPoolAddress(GoldfinchConfig config) internal view returns (address) {

    return config.getAddress(uint256(ConfigOptions.Addresses.MigratedTranchedPoolImplementation));
  }

  function reserveAddress(GoldfinchConfig config) internal view returns (address) {

    return config.getAddress(uint256(ConfigOptions.Addresses.TreasuryReserve));
  }

  function protocolAdminAddress(GoldfinchConfig config) internal view returns (address) {

    return config.getAddress(uint256(ConfigOptions.Addresses.ProtocolAdmin));
  }

  function borrowerImplementationAddress(GoldfinchConfig config) internal view returns (address) {

    return config.getAddress(uint256(ConfigOptions.Addresses.BorrowerImplementation));
  }

  function getReserveDenominator(GoldfinchConfig config) internal view returns (uint256) {

    return config.getNumber(uint256(ConfigOptions.Numbers.ReserveDenominator));
  }

  function getWithdrawFeeDenominator(GoldfinchConfig config) internal view returns (uint256) {

    return config.getNumber(uint256(ConfigOptions.Numbers.WithdrawFeeDenominator));
  }

  function getLatenessGracePeriodInDays(GoldfinchConfig config) internal view returns (uint256) {

    return config.getNumber(uint256(ConfigOptions.Numbers.LatenessGracePeriodInDays));
  }

  function getLatenessMaxDays(GoldfinchConfig config) internal view returns (uint256) {

    return config.getNumber(uint256(ConfigOptions.Numbers.LatenessMaxDays));
  }

  function getDrawdownPeriodInSeconds(GoldfinchConfig config) internal view returns (uint256) {

    return config.getNumber(uint256(ConfigOptions.Numbers.DrawdownPeriodInSeconds));
  }

  function getTransferRestrictionPeriodInDays(GoldfinchConfig config) internal view returns (uint256) {

    return config.getNumber(uint256(ConfigOptions.Numbers.TransferRestrictionPeriodInDays));
  }

  function getLeverageRatio(GoldfinchConfig config) internal view returns (uint256) {

    return config.getNumber(uint256(ConfigOptions.Numbers.LeverageRatio));
  }
}// MIT

pragma solidity 0.6.12;



contract TranchedPool is BaseUpgradeablePausable, ITranchedPool, SafeERC20Transfer {

  GoldfinchConfig public config;
  using ConfigHelper for GoldfinchConfig;
  using FixedPoint for FixedPoint.Unsigned;
  using FixedPoint for uint256;

  bytes32 public constant LOCKER_ROLE = keccak256("LOCKER_ROLE");
  uint256 public constant FP_SCALING_FACTOR = 1e18;
  uint256 public constant SECONDS_PER_DAY = 60 * 60 * 24;
  uint256 public constant ONE_HUNDRED = 100; // Need this because we cannot call .div on a literal 100
  uint256 public juniorFeePercent;
  bool public drawdownsPaused;

  TrancheInfo internal seniorTranche;
  TrancheInfo internal juniorTranche;

  event DepositMade(address indexed owner, uint256 indexed tranche, uint256 indexed tokenId, uint256 amount);
  event WithdrawalMade(
    address indexed owner,
    uint256 indexed tranche,
    uint256 indexed tokenId,
    uint256 interestWithdrawn,
    uint256 principalWithdrawn
  );

  event PaymentApplied(
    address indexed payer,
    address indexed pool,
    uint256 interestAmount,
    uint256 principalAmount,
    uint256 remainingAmount,
    uint256 reserveAmount
  );
  event SharePriceUpdated(
    address indexed pool,
    uint256 indexed tranche,
    uint256 principalSharePrice,
    int256 principalDelta,
    uint256 interestSharePrice,
    int256 interestDelta
  );
  event ReserveFundsCollected(address indexed from, uint256 amount);
  event CreditLineMigrated(address indexed oldCreditLine, address indexed newCreditLine);
  event DrawdownMade(address indexed borrower, uint256 amount);
  event DrawdownsPaused(address indexed pool);
  event DrawdownsUnpaused(address indexed pool);
  event EmergencyShutdown(address indexed pool);

  function initialize(
    address _config,
    address _borrower,
    uint256 _juniorFeePercent,
    uint256 _limit,
    uint256 _interestApr,
    uint256 _paymentPeriodInDays,
    uint256 _termInDays,
    uint256 _lateFeeApr
  ) public override initializer {

    require(
      address(_config) != address(0) && address(_borrower) != address(0),
      "Config and borrower addresses cannot be empty"
    );

    config = GoldfinchConfig(_config);
    address owner = config.protocolAdminAddress();
    require(owner != address(0), "Owner address cannot be empty");
    __BaseUpgradeablePausable__init(owner);
    seniorTranche = TrancheInfo({
      id: uint256(ITranchedPool.Tranches.Senior),
      principalSharePrice: usdcToSharePrice(1, 1),
      interestSharePrice: 0,
      principalDeposited: 0,
      lockedUntil: 0
    });
    juniorTranche = TrancheInfo({
      id: uint256(ITranchedPool.Tranches.Junior),
      principalSharePrice: usdcToSharePrice(1, 1),
      interestSharePrice: 0,
      principalDeposited: 0,
      lockedUntil: 0
    });
    createAndSetCreditLine(_borrower, _limit, _interestApr, _paymentPeriodInDays, _termInDays, _lateFeeApr);

    createdAt = block.timestamp;
    juniorFeePercent = _juniorFeePercent;

    _setupRole(LOCKER_ROLE, _borrower);
    _setupRole(LOCKER_ROLE, owner);
    _setRoleAdmin(LOCKER_ROLE, OWNER_ROLE);

    bool success = config.getUSDC().approve(address(this), uint256(-1));
    require(success, "Failed to approve USDC");
  }

  function deposit(uint256 tranche, uint256 amount)
    public
    override
    nonReentrant
    whenNotPaused
    returns (uint256 tokenId)
  {

    TrancheInfo storage trancheInfo = getTrancheInfo(tranche);
    require(trancheInfo.lockedUntil == 0, "Tranche has been locked");

    trancheInfo.principalDeposited = trancheInfo.principalDeposited.add(amount);
    IPoolTokens.MintParams memory params = IPoolTokens.MintParams({tranche: tranche, principalAmount: amount});
    tokenId = config.getPoolTokens().mint(params, msg.sender);
    safeERC20TransferFrom(config.getUSDC(), msg.sender, address(this), amount);
    emit DepositMade(msg.sender, tranche, tokenId, amount);
    return tokenId;
  }

  function depositWithPermit(
    uint256 tranche,
    uint256 amount,
    uint256 deadline,
    uint8 v,
    bytes32 r,
    bytes32 s
  ) public override returns (uint256 tokenId) {

    IERC20Permit(config.usdcAddress()).permit(msg.sender, address(this), amount, deadline, v, r, s);
    return deposit(tranche, amount);
  }

  function withdraw(uint256 tokenId, uint256 amount)
    public
    override
    onlyTokenHolder(tokenId)
    nonReentrant
    whenNotPaused
    returns (uint256 interestWithdrawn, uint256 principalWithdrawn)
  {

    IPoolTokens.TokenInfo memory tokenInfo = config.getPoolTokens().getTokenInfo(tokenId);
    TrancheInfo storage trancheInfo = getTrancheInfo(tokenInfo.tranche);

    return _withdraw(trancheInfo, tokenInfo, tokenId, amount);
  }

  function withdrawMultiple(uint256[] calldata tokenIds, uint256[] calldata amounts) public override {

    require(tokenIds.length == amounts.length, "TokensIds and Amounts must be the same length");

    for (uint256 i = 0; i < amounts.length; i++) {
      withdraw(tokenIds[i], amounts[i]);
    }
  }

  function withdrawMax(uint256 tokenId)
    external
    override
    onlyTokenHolder(tokenId)
    nonReentrant
    whenNotPaused
    returns (uint256 interestWithdrawn, uint256 principalWithdrawn)
  {

    IPoolTokens.TokenInfo memory tokenInfo = config.getPoolTokens().getTokenInfo(tokenId);
    TrancheInfo storage trancheInfo = getTrancheInfo(tokenInfo.tranche);

    (uint256 interestRedeemable, uint256 principalRedeemable) = redeemableInterestAndPrincipal(trancheInfo, tokenInfo);

    uint256 amount = interestRedeemable.add(principalRedeemable);

    return _withdraw(trancheInfo, tokenInfo, tokenId, amount);
  }

  function drawdown(uint256 amount) external override onlyLocker whenNotPaused {

    require(!drawdownsPaused, "Drawdowns are currently paused");
    if (!locked()) {
      _lockPool();
    }

    creditLine.drawdown(amount);

    uint256 amountRemaining = totalDeposited().sub(creditLine.balance());
    uint256 oldJuniorPrincipalSharePrice = juniorTranche.principalSharePrice;
    uint256 oldSeniorPrincipalSharePrice = seniorTranche.principalSharePrice;
    juniorTranche.principalSharePrice = calculateExpectedSharePrice(amountRemaining, juniorTranche);
    seniorTranche.principalSharePrice = calculateExpectedSharePrice(amountRemaining, seniorTranche);

    address borrower = creditLine.borrower();
    safeERC20TransferFrom(config.getUSDC(), address(this), borrower, amount);
    emit DrawdownMade(borrower, amount);
    emit SharePriceUpdated(
      address(this),
      juniorTranche.id,
      juniorTranche.principalSharePrice,
      int256(oldJuniorPrincipalSharePrice.sub(juniorTranche.principalSharePrice)) * -1,
      juniorTranche.interestSharePrice,
      0
    );
    emit SharePriceUpdated(
      address(this),
      seniorTranche.id,
      seniorTranche.principalSharePrice,
      int256(oldSeniorPrincipalSharePrice.sub(seniorTranche.principalSharePrice)) * -1,
      seniorTranche.interestSharePrice,
      0
    );
  }

  function lockJuniorCapital() external override onlyLocker whenNotPaused {

    _lockJuniorCapital();
  }

  function lockPool() external override onlyLocker whenNotPaused {

    _lockPool();
  }

  function assess() external override whenNotPaused {

    _assess();
  }

  function pay(uint256 amount) external override whenNotPaused {

    require(amount > 0, "Must pay more than zero");

    collectPayment(amount);
    _assess();
  }

  function updateGoldfinchConfig() external onlyAdmin {

    config = GoldfinchConfig(config.configAddress());
    creditLine.updateGoldfinchConfig();
  }

  function emergencyShutdown() public onlyAdmin {

    if (!paused()) {
      pause();
    }

    IERC20withDec usdc = config.getUSDC();
    address reserveAddress = config.reserveAddress();
    uint256 poolBalance = usdc.balanceOf(address(this));
    if (poolBalance > 0) {
      safeERC20Transfer(usdc, reserveAddress, poolBalance);
    }

    uint256 clBalance = usdc.balanceOf(address(creditLine));
    if (clBalance > 0) {
      safeERC20TransferFrom(usdc, address(creditLine), reserveAddress, clBalance);
    }
    emit EmergencyShutdown(address(this));
  }

  function pauseDrawdowns() public onlyAdmin {

    drawdownsPaused = true;
    emit DrawdownsPaused(address(this));
  }

  function unpauseDrawdowns() public onlyAdmin {

    drawdownsPaused = false;
    emit DrawdownsUnpaused(address(this));
  }

  function migrateCreditLine(
    address _borrower,
    uint256 _limit,
    uint256 _interestApr,
    uint256 _paymentPeriodInDays,
    uint256 _termInDays,
    uint256 _lateFeeApr
  ) public onlyAdmin {

    require(_borrower != address(0), "Borrower must not be empty");
    require(_paymentPeriodInDays != 0, "Payment period must not be empty");
    require(_termInDays != 0, "Term must not be empty");

    address originalClAddr = address(creditLine);
    IV2CreditLine originalCl = IV2CreditLine(originalClAddr);

    createAndSetCreditLine(_borrower, _limit, _interestApr, _paymentPeriodInDays, _termInDays, _lateFeeApr);

    IV2CreditLine newCl = creditLine;
    address newClAddr = address(newCl);

    emit CreditLineMigrated(originalClAddr, newClAddr);

    newCl.setBalance(originalCl.balance());
    newCl.setInterestOwed(originalCl.interestOwed());
    newCl.setPrincipalOwed(originalCl.principalOwed());
    newCl.setTermEndTime(originalCl.termEndTime());
    newCl.setNextDueTime(originalCl.nextDueTime());
    newCl.setInterestAccruedAsOf(originalCl.interestAccruedAsOf());
    newCl.setLastFullPaymentTime(originalCl.lastFullPaymentTime());
    newCl.setTotalInterestAccrued(originalCl.totalInterestAccrued());

    uint256 clBalance = config.getUSDC().balanceOf(originalClAddr);
    if (clBalance > 0) {
      safeERC20TransferFrom(config.getUSDC(), originalClAddr, newClAddr, clBalance);
    }

    originalCl.setBalance(0);
    originalCl.setLimit(0);
  }

  function migrateAndSetNewCreditLine(address newCl) public onlyAdmin {

    require(newCl != address(0), "Creditline cannot be empty");
    address originalClAddr = address(creditLine);
    uint256 clBalance = config.getUSDC().balanceOf(originalClAddr);
    if (clBalance > 0) {
      safeERC20TransferFrom(config.getUSDC(), originalClAddr, newCl, clBalance);
    }

    creditLine.setBalance(0);
    creditLine.setLimit(0);

    creditLine = IV2CreditLine(newCl);
    creditLine.limit();

    emit CreditLineMigrated(originalClAddr, address(creditLine));
  }

  function limit() public view returns (uint256) {

    return creditLine.limit();
  }

  function borrower() public view returns (address) {

    return creditLine.borrower();
  }

  function interestApr() public view returns (uint256) {

    return creditLine.interestApr();
  }

  function paymentPeriodInDays() public view returns (uint256) {

    return creditLine.paymentPeriodInDays();
  }

  function termInDays() public view returns (uint256) {

    return creditLine.termInDays();
  }

  function lateFeeApr() public view returns (uint256) {

    return creditLine.lateFeeApr();
  }

  function getTranche(uint256 tranche) public view override returns (TrancheInfo memory) {

    return getTrancheInfo(tranche);
  }

  function usdcToSharePrice(uint256 amount, uint256 totalShares) public pure returns (uint256) {

    return totalShares == 0 ? 0 : amount.mul(FP_SCALING_FACTOR).div(totalShares);
  }

  function sharePriceToUsdc(uint256 sharePrice, uint256 totalShares) public pure returns (uint256) {

    return sharePrice.mul(totalShares).div(FP_SCALING_FACTOR);
  }

  function availableToWithdraw(uint256 tokenId)
    public
    view
    override
    returns (uint256 interestRedeemable, uint256 principalRedeemable)
  {

    IPoolTokens.TokenInfo memory tokenInfo = config.getPoolTokens().getTokenInfo(tokenId);
    TrancheInfo storage trancheInfo = getTrancheInfo(tokenInfo.tranche);

    if (currentTime() > trancheInfo.lockedUntil) {
      return redeemableInterestAndPrincipal(trancheInfo, tokenInfo);
    } else {
      return (0, 0);
    }
  }


  function _withdraw(
    TrancheInfo storage trancheInfo,
    IPoolTokens.TokenInfo memory tokenInfo,
    uint256 tokenId,
    uint256 amount
  ) internal returns (uint256 interestWithdrawn, uint256 principalWithdrawn) {

    (uint256 interestRedeemable, uint256 principalRedeemable) = redeemableInterestAndPrincipal(trancheInfo, tokenInfo);
    uint256 netRedeemable = interestRedeemable.add(principalRedeemable);

    require(amount <= netRedeemable, "Invalid redeem amount");
    require(currentTime() > trancheInfo.lockedUntil, "Tranche is locked");

    if (trancheInfo.lockedUntil == 0) {
      trancheInfo.principalDeposited = trancheInfo.principalDeposited.sub(amount);
    }

    uint256 interestToRedeem = Math.min(interestRedeemable, amount);
    uint256 principalToRedeem = Math.min(principalRedeemable, amount.sub(interestToRedeem));

    config.getPoolTokens().redeem(tokenId, principalToRedeem, interestToRedeem);
    safeERC20TransferFrom(config.getUSDC(), address(this), msg.sender, principalToRedeem.add(interestToRedeem));

    emit WithdrawalMade(msg.sender, tokenInfo.tranche, tokenId, interestToRedeem, principalToRedeem);

    return (interestToRedeem, principalToRedeem);
  }

  function redeemableInterestAndPrincipal(TrancheInfo storage trancheInfo, IPoolTokens.TokenInfo memory tokenInfo)
    internal
    view
    returns (uint256 interestRedeemable, uint256 principalRedeemable)
  {

    uint256 maxPrincipalRedeemable = sharePriceToUsdc(trancheInfo.principalSharePrice, tokenInfo.principalAmount);
    uint256 maxInterestRedeemable = sharePriceToUsdc(trancheInfo.interestSharePrice, tokenInfo.principalAmount);

    interestRedeemable = maxInterestRedeemable.sub(tokenInfo.interestRedeemed);
    principalRedeemable = maxPrincipalRedeemable.sub(tokenInfo.principalRedeemed);

    return (interestRedeemable, principalRedeemable);
  }

  function _lockJuniorCapital() internal {

    require(!locked(), "Pool already locked");
    require(juniorTranche.lockedUntil == 0, "Junior tranche already locked");

    juniorTranche.lockedUntil = currentTime().add(config.getDrawdownPeriodInSeconds());
  }

  function _lockPool() internal {

    require(juniorTranche.lockedUntil > 0, "Junior tranche must be locked first");

    creditLine.setLimit(Math.min(totalDeposited(), creditLine.limit()));

    uint256 lockPeriod = config.getDrawdownPeriodInSeconds();
    seniorTranche.lockedUntil = currentTime().add(lockPeriod);
    juniorTranche.lockedUntil = currentTime().add(lockPeriod);
  }

  function collectInterestAndPrincipal(
    address from,
    uint256 interest,
    uint256 principal
  ) internal returns (uint256 totalReserveAmount) {

    safeERC20TransferFrom(config.getUSDC(), from, address(this), principal.add(interest), "Failed to collect payment");

    (uint256 interestAccrued, uint256 principalAccrued) = getTotalInterestAndPrincipal();
    uint256 reserveFeePercent = ONE_HUNDRED.div(config.getReserveDenominator()); // Convert the denonminator to percent

    uint256 interestRemaining = interest;
    uint256 principalRemaining = principal;

    uint256 expectedInterestSharePrice = calculateExpectedSharePrice(interestAccrued, seniorTranche);
    uint256 expectedPrincipalSharePrice = calculateExpectedSharePrice(principalAccrued, seniorTranche);

    uint256 desiredNetInterestSharePrice = scaleByFraction(
      expectedInterestSharePrice,
      ONE_HUNDRED.sub(juniorFeePercent.add(reserveFeePercent)),
      ONE_HUNDRED
    );
    uint256 reserveDeduction = scaleByFraction(interestRemaining, reserveFeePercent, ONE_HUNDRED);
    totalReserveAmount = totalReserveAmount.add(reserveDeduction); // protocol fee
    interestRemaining = interestRemaining.sub(reserveDeduction);

    (interestRemaining, principalRemaining) = applyToTrancheBySharePrice(
      interestRemaining,
      principalRemaining,
      desiredNetInterestSharePrice,
      expectedPrincipalSharePrice,
      seniorTranche
    );

    expectedInterestSharePrice = juniorTranche.interestSharePrice.add(
      usdcToSharePrice(interestRemaining, juniorTranche.principalDeposited)
    );
    expectedPrincipalSharePrice = calculateExpectedSharePrice(principalAccrued, juniorTranche);
    (interestRemaining, principalRemaining) = applyToTrancheBySharePrice(
      interestRemaining,
      principalRemaining,
      expectedInterestSharePrice,
      expectedPrincipalSharePrice,
      juniorTranche
    );

    interestRemaining = interestRemaining.add(principalRemaining);
    reserveDeduction = scaleByFraction(principalRemaining, reserveFeePercent, ONE_HUNDRED);
    totalReserveAmount = totalReserveAmount.add(reserveDeduction);
    interestRemaining = interestRemaining.sub(reserveDeduction);
    principalRemaining = 0;

    (interestRemaining, principalRemaining) = applyToTrancheByAmount(
      interestRemaining.add(principalRemaining),
      0,
      interestRemaining.add(principalRemaining),
      0,
      juniorTranche
    );

    sendToReserve(totalReserveAmount);

    return totalReserveAmount;
  }

  function getTotalInterestAndPrincipal() internal view returns (uint256 interestAccrued, uint256 principalAccrued) {

    interestAccrued = creditLine.totalInterestAccrued();
    principalAccrued = creditLine.principalOwed();
    principalAccrued = principalAccrued.add(totalDeposited().sub(creditLine.balance()));
    return (interestAccrued, principalAccrued);
  }

  function calculateExpectedSharePrice(uint256 amount, TrancheInfo memory tranche) internal view returns (uint256) {

    uint256 sharePrice = usdcToSharePrice(amount, tranche.principalDeposited);
    return scaleByPercentOwnership(sharePrice, tranche);
  }

  function locked() internal view returns (bool) {

    return seniorTranche.lockedUntil > 0;
  }

  function createAndSetCreditLine(
    address _borrower,
    uint256 _limit,
    uint256 _interestApr,
    uint256 _paymentPeriodInDays,
    uint256 _termInDays,
    uint256 _lateFeeApr
  ) internal {

    address _creditLine = config.getGoldfinchFactory().createCreditLine();
    creditLine = IV2CreditLine(_creditLine);
    creditLine.initialize(
      address(config),
      address(this), // Set self as the owner
      _borrower,
      _limit,
      _interestApr,
      _paymentPeriodInDays,
      _termInDays,
      _lateFeeApr
    );
  }

  function getTrancheInfo(uint256 tranche) internal view returns (TrancheInfo storage) {

    require(
      tranche == uint256(ITranchedPool.Tranches.Senior) || tranche == uint256(ITranchedPool.Tranches.Junior),
      "Unsupported tranche"
    );
    TrancheInfo storage trancheInfo = tranche == uint256(ITranchedPool.Tranches.Senior) ? seniorTranche : juniorTranche;
    return trancheInfo;
  }

  function scaleByPercentOwnership(uint256 amount, TrancheInfo memory tranche) internal view returns (uint256) {

    uint256 totalDeposited = juniorTranche.principalDeposited.add(seniorTranche.principalDeposited);
    return scaleByFraction(amount, tranche.principalDeposited, totalDeposited);
  }

  function scaleByFraction(
    uint256 amount,
    uint256 fraction,
    uint256 total
  ) internal pure returns (uint256) {

    FixedPoint.Unsigned memory totalAsFixedPoint = FixedPoint.fromUnscaledUint(total);
    FixedPoint.Unsigned memory fractionAsFixedPoint = FixedPoint.fromUnscaledUint(fraction);
    return fractionAsFixedPoint.div(totalAsFixedPoint).mul(amount).div(FP_SCALING_FACTOR).rawValue;
  }

  function totalDeposited() internal view returns (uint256) {

    return juniorTranche.principalDeposited.add(seniorTranche.principalDeposited);
  }

  function currentTime() internal view virtual returns (uint256) {

    return block.timestamp;
  }

  function applyToTrancheBySharePrice(
    uint256 interestRemaining,
    uint256 principalRemaining,
    uint256 desiredInterestSharePrice,
    uint256 desiredPrincipalSharePrice,
    TrancheInfo storage tranche
  ) internal returns (uint256, uint256) {

    uint256 totalShares = tranche.principalDeposited;

    uint256 principalSharePrice = tranche.principalSharePrice;
    if (desiredPrincipalSharePrice < principalSharePrice) {
      desiredPrincipalSharePrice = principalSharePrice;
    }
    uint256 interestSharePrice = tranche.interestSharePrice;
    if (desiredInterestSharePrice < interestSharePrice) {
      desiredInterestSharePrice = interestSharePrice;
    }
    uint256 interestSharePriceDifference = desiredInterestSharePrice.sub(interestSharePrice);
    uint256 desiredInterestAmount = sharePriceToUsdc(interestSharePriceDifference, totalShares);
    uint256 principalSharePriceDifference = desiredPrincipalSharePrice.sub(principalSharePrice);
    uint256 desiredPrincipalAmount = sharePriceToUsdc(principalSharePriceDifference, totalShares);

    (interestRemaining, principalRemaining) = applyToTrancheByAmount(
      interestRemaining,
      principalRemaining,
      desiredInterestAmount,
      desiredPrincipalAmount,
      tranche
    );
    return (interestRemaining, principalRemaining);
  }

  function applyToTrancheByAmount(
    uint256 interestRemaining,
    uint256 principalRemaining,
    uint256 desiredInterestAmount,
    uint256 desiredPrincipalAmount,
    TrancheInfo storage tranche
  ) internal returns (uint256, uint256) {

    uint256 totalShares = tranche.principalDeposited;
    uint256 newSharePrice;

    (interestRemaining, newSharePrice) = applyToSharePrice(
      interestRemaining,
      tranche.interestSharePrice,
      desiredInterestAmount,
      totalShares
    );
    uint256 oldInterestSharePrice = tranche.interestSharePrice;
    tranche.interestSharePrice = newSharePrice;

    (principalRemaining, newSharePrice) = applyToSharePrice(
      principalRemaining,
      tranche.principalSharePrice,
      desiredPrincipalAmount,
      totalShares
    );
    uint256 oldPrincipalSharePrice = tranche.principalSharePrice;
    tranche.principalSharePrice = newSharePrice;
    emit SharePriceUpdated(
      address(this),
      tranche.id,
      tranche.principalSharePrice,
      int256(tranche.principalSharePrice.sub(oldPrincipalSharePrice)),
      tranche.interestSharePrice,
      int256(tranche.interestSharePrice.sub(oldInterestSharePrice))
    );
    return (interestRemaining, principalRemaining);
  }

  function applyToSharePrice(
    uint256 amountRemaining,
    uint256 currentSharePrice,
    uint256 desiredAmount,
    uint256 totalShares
  ) internal pure returns (uint256, uint256) {

    if (amountRemaining == 0 || desiredAmount == 0) {
      return (amountRemaining, currentSharePrice);
    }
    if (amountRemaining < desiredAmount) {
      desiredAmount = amountRemaining;
    }
    uint256 sharePriceDifference = usdcToSharePrice(desiredAmount, totalShares);
    return (amountRemaining.sub(desiredAmount), currentSharePrice.add(sharePriceDifference));
  }

  function sendToReserve(uint256 amount) internal {

    emit ReserveFundsCollected(address(this), amount);
    safeERC20TransferFrom(
      config.getUSDC(),
      address(this),
      config.reserveAddress(),
      amount,
      "Failed to send to reserve"
    );
  }

  function collectPayment(uint256 amount) internal {

    safeERC20TransferFrom(config.getUSDC(), msg.sender, address(creditLine), amount, "Failed to collect payment");
  }

  function _assess() internal {

    (uint256 paymentRemaining, uint256 interestPayment, uint256 principalPayment) = creditLine.assess();
    if (interestPayment > 0 || principalPayment > 0) {
      uint256 reserveAmount = collectInterestAndPrincipal(
        address(creditLine),
        interestPayment,
        principalPayment.add(paymentRemaining)
      );
      emit PaymentApplied(
        creditLine.borrower(),
        address(this),
        interestPayment,
        principalPayment,
        paymentRemaining,
        reserveAmount
      );
    }
  }

  modifier onlyLocker() {

    require(hasRole(LOCKER_ROLE, msg.sender), "Must have locker role to perform this action");
    _;
  }

  modifier onlyTokenHolder(uint256 tokenId) {

    require(
      config.getPoolTokens().isApprovedOrOwner(msg.sender, tokenId),
      "Only the token owner is allowed to call this function"
    );
    _;
  }
}// MIT

pragma solidity 0.6.12;


contract MigratedTranchedPool is TranchedPool, IMigratedTranchedPool {

  bool public migrated;

  function migrateCreditLineToV2(
    IV1CreditLine clToMigrate,
    uint256 termEndTime,
    uint256 nextDueTime,
    uint256 interestAccruedAsOf,
    uint256 lastFullPaymentTime,
    uint256 totalInterestPaid
  ) external override returns (IV2CreditLine) {

    require(msg.sender == config.creditDeskAddress(), "Only credit desk can call this");
    require(!migrated, "Already migrated");

    IV2CreditLine newCl = creditLine;
    newCl.setBalance(clToMigrate.balance());
    newCl.setInterestOwed(clToMigrate.interestOwed());
    newCl.setPrincipalOwed(clToMigrate.principalOwed());
    newCl.setTermEndTime(termEndTime);
    newCl.setNextDueTime(nextDueTime);
    newCl.setInterestAccruedAsOf(interestAccruedAsOf);
    newCl.setLastFullPaymentTime(lastFullPaymentTime);
    newCl.setTotalInterestAccrued(totalInterestPaid.add(clToMigrate.interestOwed()));

    migrateDeposits(clToMigrate, totalInterestPaid);

    migrated = true;

    return newCl;
  }

  function migrateDeposits(IV1CreditLine clToMigrate, uint256 totalInterestPaid) internal {

    require(!locked(), "Pool has been locked");
    uint256 tranche = uint256(ITranchedPool.Tranches.Junior);
    TrancheInfo storage trancheInfo = getTrancheInfo(tranche);
    require(trancheInfo.lockedUntil == 0, "Tranche has been locked");
    trancheInfo.principalDeposited = clToMigrate.limit();
    IPoolTokens.MintParams memory params = IPoolTokens.MintParams({
      tranche: tranche,
      principalAmount: trancheInfo.principalDeposited
    });
    IPoolTokens poolTokens = config.getPoolTokens();

    uint256 tokenId = poolTokens.mint(params, config.seniorPoolAddress());
    uint256 balancePaid = creditLine.limit().sub(creditLine.balance());

    _lockJuniorCapital();
    _lockPool();

    juniorTranche.lockedUntil = block.timestamp - 1;
    poolTokens.redeem(tokenId, balancePaid, totalInterestPaid);

    juniorTranche.principalSharePrice = 0;
    seniorTranche.principalSharePrice = 0;

    applyToTrancheByAmount(totalInterestPaid, balancePaid, totalInterestPaid, balancePaid, juniorTranche);
  }
}