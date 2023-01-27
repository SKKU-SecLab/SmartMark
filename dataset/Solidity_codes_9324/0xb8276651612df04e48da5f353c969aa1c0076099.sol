pragma solidity ^0.6.2;

abstract contract IRelayRecipient {

    function isTrustedForwarder(address forwarder) public virtual view returns(bool);

    function _msgSender() internal virtual view returns (address payable);

    function _msgData() internal virtual view returns (bytes memory);

    function versionRecipient() external virtual view returns (string memory);
}// SPDX-License-Identifier:MIT
pragma solidity ^0.6.2;


abstract contract BaseRelayRecipient is IRelayRecipient {

    address public trustedForwarder;

    function isTrustedForwarder(address forwarder) public override view returns(bool) {
        return forwarder == trustedForwarder;
    }

    function _msgSender() internal override virtual view returns (address payable ret) {
        if (msg.data.length >= 24 && isTrustedForwarder(msg.sender)) {
            assembly {
                ret := shr(96,calldataload(sub(calldatasize(),20)))
            }
        } else {
            return msg.sender;
        }
    }

    function _msgData() internal override virtual view returns (bytes memory ret) {
        if (msg.data.length >= 24 && isTrustedForwarder(msg.sender)) {
            assembly {
                let ptr := mload(0x40)
                let size := sub(calldatasize(),20)
                mstore(ptr, 0x20)
                mstore(add(ptr,32), size)
                calldatacopy(add(ptr,64), 0, size)
                return(ptr, add(size,64))
            }
        } else {
            return msg.data;
        }
    }
}pragma solidity >=0.4.24 <0.7.0;


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
}// SPDX-Licence-Identifier: MIT

pragma solidity 0.6.12;

interface IBorrower {

  function initialize(address owner, address _config) external;

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



contract CreditLine is BaseUpgradeablePausable, ICreditLine {

  uint256 public constant SECONDS_PER_DAY = 60 * 60 * 24;

  address public override borrower;
  uint256 public override limit;
  uint256 public override interestApr;
  uint256 public override paymentPeriodInDays;
  uint256 public override termInDays;
  uint256 public override lateFeeApr;

  uint256 public override balance;
  uint256 public override interestOwed;
  uint256 public override principalOwed;
  uint256 public override termEndTime;
  uint256 public override nextDueTime;
  uint256 public override interestAccruedAsOf;
  uint256 public override lastFullPaymentTime;
  uint256 public totalInterestAccrued;

  GoldfinchConfig public config;
  using ConfigHelper for GoldfinchConfig;

  function initialize(
    address _config,
    address owner,
    address _borrower,
    uint256 _limit,
    uint256 _interestApr,
    uint256 _paymentPeriodInDays,
    uint256 _termInDays,
    uint256 _lateFeeApr
  ) public initializer {

    require(_config != address(0) && owner != address(0) && _borrower != address(0), "Zero address passed in");
    __BaseUpgradeablePausable__init(owner);
    config = GoldfinchConfig(_config);
    borrower = _borrower;
    limit = _limit;
    interestApr = _interestApr;
    paymentPeriodInDays = _paymentPeriodInDays;
    termInDays = _termInDays;
    lateFeeApr = _lateFeeApr;
    interestAccruedAsOf = block.timestamp;

    bool success = config.getUSDC().approve(owner, uint256(-1));
    require(success, "Failed to approve USDC");
  }

  function drawdown(uint256 amount) external onlyAdmin {

    require(amount.add(balance) <= limit, "Cannot drawdown more than the limit");
    uint256 timestamp = currentTime();

    if (balance == 0) {
      setInterestAccruedAsOf(timestamp);
      setLastFullPaymentTime(timestamp);
      setTotalInterestAccrued(0);
      setTermEndTime(timestamp.add(SECONDS_PER_DAY.mul(termInDays)));
    }

    (uint256 _interestOwed, uint256 _principalOwed) = updateAndGetInterestAndPrincipalOwedAsOf(timestamp);
    balance = balance.add(amount);

    updateCreditLineAccounting(balance, _interestOwed, _principalOwed);
    require(!isLate(timestamp), "Cannot drawdown when payments are past due");
  }

  function updateGoldfinchConfig() external onlyAdmin {

    config = GoldfinchConfig(config.configAddress());
  }

  function setLateFeeApr(uint256 newLateFeeApr) external onlyAdmin {

    lateFeeApr = newLateFeeApr;
  }

  function setLimit(uint256 newAmount) external onlyAdmin {

    limit = newAmount;
  }

  function termStartTime() external view returns (uint256) {

    return termEndTime.sub(SECONDS_PER_DAY.mul(termInDays));
  }

  function setTermEndTime(uint256 newTermEndTime) public onlyAdmin {

    termEndTime = newTermEndTime;
  }

  function setNextDueTime(uint256 newNextDueTime) public onlyAdmin {

    nextDueTime = newNextDueTime;
  }

  function setBalance(uint256 newBalance) public onlyAdmin {

    balance = newBalance;
  }

  function setTotalInterestAccrued(uint256 _totalInterestAccrued) public onlyAdmin {

    totalInterestAccrued = _totalInterestAccrued;
  }

  function setInterestOwed(uint256 newInterestOwed) public onlyAdmin {

    interestOwed = newInterestOwed;
  }

  function setPrincipalOwed(uint256 newPrincipalOwed) public onlyAdmin {

    principalOwed = newPrincipalOwed;
  }

  function setInterestAccruedAsOf(uint256 newInterestAccruedAsOf) public onlyAdmin {

    interestAccruedAsOf = newInterestAccruedAsOf;
  }

  function setLastFullPaymentTime(uint256 newLastFullPaymentTime) public onlyAdmin {

    lastFullPaymentTime = newLastFullPaymentTime;
  }

  function assess()
    public
    onlyAdmin
    returns (
      uint256,
      uint256,
      uint256
    )
  {

    require(balance > 0, "Must have balance to assess credit line");

    if (currentTime() < nextDueTime && !isLate(currentTime())) {
      return (0, 0, 0);
    }
    uint256 timeToAssess = calculateNextDueTime();
    setNextDueTime(timeToAssess);

    if (timeToAssess > currentTime()) {
      uint256 secondsPerPeriod = paymentPeriodInDays.mul(SECONDS_PER_DAY);
      timeToAssess = timeToAssess.sub(secondsPerPeriod);
    }
    return handlePayment(getUSDCBalance(address(this)), timeToAssess);
  }

  function calculateNextDueTime() internal view returns (uint256) {

    uint256 newNextDueTime = nextDueTime;
    uint256 secondsPerPeriod = paymentPeriodInDays.mul(SECONDS_PER_DAY);
    uint256 curTimestamp = currentTime();
    if (newNextDueTime == 0 && balance > 0) {
      return curTimestamp.add(secondsPerPeriod);
    }

    if (balance > 0 && curTimestamp >= newNextDueTime) {
      uint256 secondsToAdvance = (curTimestamp.sub(newNextDueTime).div(secondsPerPeriod)).add(1).mul(secondsPerPeriod);
      newNextDueTime = newNextDueTime.add(secondsToAdvance);
      return Math.min(newNextDueTime, termEndTime);
    }

    if (balance == 0 && newNextDueTime != 0) {
      return 0;
    }
    if (balance > 0 && curTimestamp < newNextDueTime) {
      return newNextDueTime;
    }
    revert("Error: could not calculate next due time.");
  }

  function currentTime() internal view virtual returns (uint256) {

    return block.timestamp;
  }

  function isLate(uint256 timestamp) internal view returns (bool) {

    uint256 secondsElapsedSinceFullPayment = timestamp.sub(lastFullPaymentTime);
    return secondsElapsedSinceFullPayment > paymentPeriodInDays.mul(SECONDS_PER_DAY);
  }

  function handlePayment(uint256 paymentAmount, uint256 timestamp)
    internal
    returns (
      uint256,
      uint256,
      uint256
    )
  {

    (uint256 newInterestOwed, uint256 newPrincipalOwed) = updateAndGetInterestAndPrincipalOwedAsOf(timestamp);

    Accountant.PaymentAllocation memory pa = Accountant.allocatePayment(
      paymentAmount,
      balance,
      newInterestOwed,
      newPrincipalOwed
    );

    uint256 newBalance = balance.sub(pa.principalPayment);
    newBalance = newBalance.sub(pa.additionalBalancePayment);
    uint256 totalPrincipalPayment = balance.sub(newBalance);
    uint256 paymentRemaining = paymentAmount.sub(pa.interestPayment).sub(totalPrincipalPayment);

    updateCreditLineAccounting(
      newBalance,
      newInterestOwed.sub(pa.interestPayment),
      newPrincipalOwed.sub(pa.principalPayment)
    );

    assert(paymentRemaining.add(pa.interestPayment).add(totalPrincipalPayment) == paymentAmount);

    return (paymentRemaining, pa.interestPayment, totalPrincipalPayment);
  }

  function updateAndGetInterestAndPrincipalOwedAsOf(uint256 timestamp) internal returns (uint256, uint256) {

    (uint256 interestAccrued, uint256 principalAccrued) = Accountant.calculateInterestAndPrincipalAccrued(
      this,
      timestamp,
      config.getLatenessGracePeriodInDays()
    );
    if (interestAccrued > 0) {
      setInterestAccruedAsOf(timestamp);
      totalInterestAccrued = totalInterestAccrued.add(interestAccrued);
    }
    return (interestOwed.add(interestAccrued), principalOwed.add(principalAccrued));
  }

  function updateCreditLineAccounting(
    uint256 newBalance,
    uint256 newInterestOwed,
    uint256 newPrincipalOwed
  ) internal nonReentrant {

    setBalance(newBalance);
    setInterestOwed(newInterestOwed);
    setPrincipalOwed(newPrincipalOwed);

    uint256 _nextDueTime = nextDueTime;
    if (newInterestOwed == 0 && _nextDueTime != 0) {
      uint256 mostRecentLastDueTime;
      if (currentTime() < _nextDueTime) {
        uint256 secondsPerPeriod = paymentPeriodInDays.mul(SECONDS_PER_DAY);
        mostRecentLastDueTime = _nextDueTime.sub(secondsPerPeriod);
      } else {
        mostRecentLastDueTime = _nextDueTime;
      }
      setLastFullPaymentTime(mostRecentLastDueTime);
    }

    setNextDueTime(calculateNextDueTime());
  }

  function getUSDCBalance(address _address) internal view returns (uint256) {

    return config.getUSDC().balanceOf(_address);
  }
}// MIT

pragma solidity 0.6.12;



library Accountant {

  using SafeMath for uint256;
  using FixedPoint for FixedPoint.Signed;
  using FixedPoint for FixedPoint.Unsigned;
  using FixedPoint for int256;
  using FixedPoint for uint256;

  uint256 public constant FP_SCALING_FACTOR = 10**18;
  uint256 public constant INTEREST_DECIMALS = 1e18;
  uint256 public constant SECONDS_PER_DAY = 60 * 60 * 24;
  uint256 public constant SECONDS_PER_YEAR = (SECONDS_PER_DAY * 365);

  struct PaymentAllocation {
    uint256 interestPayment;
    uint256 principalPayment;
    uint256 additionalBalancePayment;
  }

  function calculateInterestAndPrincipalAccrued(
    CreditLine cl,
    uint256 timestamp,
    uint256 lateFeeGracePeriod
  ) public view returns (uint256, uint256) {

    uint256 balance = cl.balance(); // gas optimization
    uint256 interestAccrued = calculateInterestAccrued(cl, balance, timestamp, lateFeeGracePeriod);
    uint256 principalAccrued = calculatePrincipalAccrued(cl, balance, timestamp);
    return (interestAccrued, principalAccrued);
  }

  function calculateInterestAndPrincipalAccruedOverPeriod(
    CreditLine cl,
    uint256 balance,
    uint256 startTime,
    uint256 endTime,
    uint256 lateFeeGracePeriod
  ) public view returns (uint256, uint256) {

    uint256 interestAccrued = calculateInterestAccruedOverPeriod(cl, balance, startTime, endTime, lateFeeGracePeriod);
    uint256 principalAccrued = calculatePrincipalAccrued(cl, balance, endTime);
    return (interestAccrued, principalAccrued);
  }

  function calculatePrincipalAccrued(
    ICreditLine cl,
    uint256 balance,
    uint256 timestamp
  ) public view returns (uint256) {

    uint256 termEndTime = cl.termEndTime();
    if (cl.interestAccruedAsOf() >= termEndTime) {
      return 0;
    }
    if (timestamp >= termEndTime) {
      return balance;
    } else {
      return 0;
    }
  }

  function calculateWritedownFor(
    ICreditLine cl,
    uint256 timestamp,
    uint256 gracePeriodInDays,
    uint256 maxDaysLate
  ) public view returns (uint256, uint256) {

    return calculateWritedownForPrincipal(cl, cl.balance(), timestamp, gracePeriodInDays, maxDaysLate);
  }

  function calculateWritedownForPrincipal(
    ICreditLine cl,
    uint256 principal,
    uint256 timestamp,
    uint256 gracePeriodInDays,
    uint256 maxDaysLate
  ) public view returns (uint256, uint256) {

    FixedPoint.Unsigned memory amountOwedPerDay = calculateAmountOwedForOneDay(cl);
    if (amountOwedPerDay.isEqual(0)) {
      return (0, 0);
    }
    FixedPoint.Unsigned memory fpGracePeriod = FixedPoint.fromUnscaledUint(gracePeriodInDays);
    FixedPoint.Unsigned memory daysLate;

    uint256 totalOwed = cl.interestOwed().add(cl.principalOwed());
    daysLate = FixedPoint.fromUnscaledUint(totalOwed).div(amountOwedPerDay);
    if (timestamp > cl.termEndTime()) {
      uint256 secondsLate = timestamp.sub(cl.termEndTime());
      daysLate = daysLate.add(FixedPoint.fromUnscaledUint(secondsLate).div(SECONDS_PER_DAY));
    }

    FixedPoint.Unsigned memory maxLate = FixedPoint.fromUnscaledUint(maxDaysLate);
    FixedPoint.Unsigned memory writedownPercent;
    if (daysLate.isLessThanOrEqual(fpGracePeriod)) {
      writedownPercent = FixedPoint.fromUnscaledUint(0);
    } else {
      writedownPercent = FixedPoint.min(FixedPoint.fromUnscaledUint(1), (daysLate.sub(fpGracePeriod)).div(maxLate));
    }

    FixedPoint.Unsigned memory writedownAmount = writedownPercent.mul(principal).div(FP_SCALING_FACTOR);
    uint256 unscaledWritedownPercent = writedownPercent.mul(100).div(FP_SCALING_FACTOR).rawValue;
    return (unscaledWritedownPercent, writedownAmount.rawValue);
  }

  function calculateAmountOwedForOneDay(ICreditLine cl) public view returns (FixedPoint.Unsigned memory interestOwed) {

    uint256 totalInterestPerYear = cl.balance().mul(cl.interestApr()).div(INTEREST_DECIMALS);
    interestOwed = FixedPoint.fromUnscaledUint(totalInterestPerYear).div(365);
    return interestOwed;
  }

  function calculateInterestAccrued(
    CreditLine cl,
    uint256 balance,
    uint256 timestamp,
    uint256 lateFeeGracePeriodInDays
  ) public view returns (uint256) {

    uint256 startTime = Math.min(timestamp, cl.interestAccruedAsOf());
    return calculateInterestAccruedOverPeriod(cl, balance, startTime, timestamp, lateFeeGracePeriodInDays);
  }

  function calculateInterestAccruedOverPeriod(
    CreditLine cl,
    uint256 balance,
    uint256 startTime,
    uint256 endTime,
    uint256 lateFeeGracePeriodInDays
  ) public view returns (uint256 interestOwed) {

    uint256 secondsElapsed = endTime.sub(startTime);
    uint256 totalInterestPerYear = balance.mul(cl.interestApr()).div(INTEREST_DECIMALS);
    interestOwed = totalInterestPerYear.mul(secondsElapsed).div(SECONDS_PER_YEAR);

    if (lateFeeApplicable(cl, endTime, lateFeeGracePeriodInDays)) {
      uint256 lateFeeInterestPerYear = balance.mul(cl.lateFeeApr()).div(INTEREST_DECIMALS);
      uint256 additionalLateFeeInterest = lateFeeInterestPerYear.mul(secondsElapsed).div(SECONDS_PER_YEAR);
      interestOwed = interestOwed.add(additionalLateFeeInterest);
    }

    return interestOwed;
  }

  function lateFeeApplicable(
    CreditLine cl,
    uint256 timestamp,
    uint256 gracePeriodInDays
  ) public view returns (bool) {

    uint256 secondsLate = timestamp.sub(cl.lastFullPaymentTime());
    return cl.lateFeeApr() > 0 && secondsLate > gracePeriodInDays.mul(SECONDS_PER_DAY);
  }

  function allocatePayment(
    uint256 paymentAmount,
    uint256 balance,
    uint256 interestOwed,
    uint256 principalOwed
  ) public pure returns (PaymentAllocation memory) {

    uint256 paymentRemaining = paymentAmount;
    uint256 interestPayment = Math.min(interestOwed, paymentRemaining);
    paymentRemaining = paymentRemaining.sub(interestPayment);

    uint256 principalPayment = Math.min(principalOwed, paymentRemaining);
    paymentRemaining = paymentRemaining.sub(principalPayment);

    uint256 balanceRemaining = balance.sub(principalPayment);
    uint256 additionalBalancePayment = Math.min(paymentRemaining, balanceRemaining);

    return
      PaymentAllocation({
        interestPayment: interestPayment,
        principalPayment: principalPayment,
        additionalBalancePayment: additionalBalancePayment
      });
  }
}// MIT

pragma solidity 0.6.12;



contract Borrower is BaseUpgradeablePausable, BaseRelayRecipient, IBorrower {

  using SafeMath for uint256;

  GoldfinchConfig public config;
  using ConfigHelper for GoldfinchConfig;

  address private constant USDT_ADDRESS = address(0xdAC17F958D2ee523a2206206994597C13D831ec7);
  address private constant BUSD_ADDRESS = address(0x4Fabb145d64652a948d72533023f6E7A623C7C53);
  address private constant GUSD_ADDRESS = address(0x056Fd409E1d7A124BD7017459dFEa2F387b6d5Cd);
  address private constant DAI_ADDRESS = address(0x6B175474E89094C44Da98b954EedeAC495271d0F);

  function initialize(address owner, address _config) external override initializer {

    require(owner != address(0) && _config != address(0), "Owner and config addresses cannot be empty");
    __BaseUpgradeablePausable__init(owner);
    config = GoldfinchConfig(_config);

    trustedForwarder = config.trustedForwarderAddress();

    address oneInch = config.oneInchAddress();
    IERC20withDec usdc = config.getUSDC();
    usdc.approve(oneInch, uint256(-1));
    bytes memory data = abi.encodeWithSignature("approve(address,uint256)", oneInch, uint256(-1));
    invoke(USDT_ADDRESS, data);
    invoke(BUSD_ADDRESS, data);
    invoke(GUSD_ADDRESS, data);
    invoke(DAI_ADDRESS, data);
  }

  function lockJuniorCapital(address poolAddress) external onlyAdmin {

    ITranchedPool(poolAddress).lockJuniorCapital();
  }

  function lockPool(address poolAddress) external onlyAdmin {

    ITranchedPool(poolAddress).lockPool();
  }

  function drawdown(
    address poolAddress,
    uint256 amount,
    address addressToSendTo
  ) external onlyAdmin {

    ITranchedPool(poolAddress).drawdown(amount);

    if (addressToSendTo == address(0) || addressToSendTo == address(this)) {
      addressToSendTo = _msgSender();
    }

    transferERC20(config.usdcAddress(), addressToSendTo, amount);
  }

  function drawdownWithSwapOnOneInch(
    address poolAddress,
    uint256 amount,
    address addressToSendTo,
    address toToken,
    uint256 minTargetAmount,
    uint256[] calldata exchangeDistribution
  ) public onlyAdmin {

    ITranchedPool(poolAddress).drawdown(amount);

    swapOnOneInch(config.usdcAddress(), toToken, amount, minTargetAmount, exchangeDistribution);

    if (addressToSendTo == address(0) || addressToSendTo == address(this)) {
      addressToSendTo = _msgSender();
    }

    bytes memory _data = abi.encodeWithSignature("balanceOf(address)", address(this));
    uint256 receivedAmount = toUint256(invoke(toToken, _data));
    transferERC20(toToken, addressToSendTo, receivedAmount);
  }

  function transferERC20(
    address token,
    address to,
    uint256 amount
  ) public onlyAdmin {

    bytes memory _data = abi.encodeWithSignature("transfer(address,uint256)", to, amount);
    invoke(token, _data);
  }

  function pay(address poolAddress, uint256 amount) external onlyAdmin {

    IERC20withDec usdc = config.getUSDC();
    bool success = usdc.transferFrom(_msgSender(), address(this), amount);
    require(success, "Failed to transfer USDC");
    _transferAndPay(usdc, poolAddress, amount);
  }

  function payMultiple(address[] calldata pools, uint256[] calldata amounts) external onlyAdmin {

    require(pools.length == amounts.length, "Pools and amounts must be the same length");

    uint256 totalAmount;
    for (uint256 i = 0; i < amounts.length; i++) {
      totalAmount = totalAmount.add(amounts[i]);
    }

    IERC20withDec usdc = config.getUSDC();
    bool success = usdc.transferFrom(_msgSender(), address(this), totalAmount);
    require(success, "Failed to transfer USDC");

    for (uint256 i = 0; i < amounts.length; i++) {
      _transferAndPay(usdc, pools[i], amounts[i]);
    }
  }

  function payInFull(address poolAddress, uint256 amount) external onlyAdmin {

    IERC20withDec usdc = config.getUSDC();
    bool success = usdc.transferFrom(_msgSender(), address(this), amount);
    require(success, "Failed to transfer USDC");

    _transferAndPay(usdc, poolAddress, amount);
    require(ITranchedPool(poolAddress).creditLine().balance() == 0, "Failed to fully pay off creditline");
  }

  function payWithSwapOnOneInch(
    address poolAddress,
    uint256 originAmount,
    address fromToken,
    uint256 minTargetAmount,
    uint256[] calldata exchangeDistribution
  ) external onlyAdmin {

    transferFrom(fromToken, _msgSender(), address(this), originAmount);
    IERC20withDec usdc = config.getUSDC();
    swapOnOneInch(fromToken, address(usdc), originAmount, minTargetAmount, exchangeDistribution);
    uint256 usdcBalance = usdc.balanceOf(address(this));
    _transferAndPay(usdc, poolAddress, usdcBalance);
  }

  function payMultipleWithSwapOnOneInch(
    address[] calldata pools,
    uint256[] calldata minAmounts,
    uint256 originAmount,
    address fromToken,
    uint256[] calldata exchangeDistribution
  ) external onlyAdmin {

    require(pools.length == minAmounts.length, "Pools and amounts must be the same length");

    uint256 totalMinAmount = 0;
    for (uint256 i = 0; i < minAmounts.length; i++) {
      totalMinAmount = totalMinAmount.add(minAmounts[i]);
    }

    transferFrom(fromToken, _msgSender(), address(this), originAmount);

    IERC20withDec usdc = config.getUSDC();
    swapOnOneInch(fromToken, address(usdc), originAmount, totalMinAmount, exchangeDistribution);

    for (uint256 i = 0; i < minAmounts.length; i++) {
      _transferAndPay(usdc, pools[i], minAmounts[i]);
    }

    uint256 remainingUSDC = usdc.balanceOf(address(this));
    if (remainingUSDC > 0) {
      _transferAndPay(usdc, pools[0], remainingUSDC);
    }
  }

  function _transferAndPay(
    IERC20withDec usdc,
    address poolAddress,
    uint256 amount
  ) internal {

    ITranchedPool pool = ITranchedPool(poolAddress);
    bool success = usdc.transfer(address(pool.creditLine()), amount);
    require(success, "USDC Transfer to creditline failed");
    pool.assess();
  }

  function transferFrom(
    address erc20,
    address sender,
    address recipient,
    uint256 amount
  ) internal {

    bytes memory _data;
    _data = abi.encodeWithSignature("transferFrom(address,address,uint256)", sender, recipient, amount);
    invoke(address(erc20), _data);
  }

  function swapOnOneInch(
    address fromToken,
    address toToken,
    uint256 originAmount,
    uint256 minTargetAmount,
    uint256[] calldata exchangeDistribution
  ) internal {

    bytes memory _data = abi.encodeWithSignature(
      "swap(address,address,uint256,uint256,uint256[],uint256)",
      fromToken,
      toToken,
      originAmount,
      minTargetAmount,
      exchangeDistribution,
      0
    );
    invoke(config.oneInchAddress(), _data);
  }

  function invoke(address _target, bytes memory _data) internal returns (bytes memory) {


    bool success;
    bytes memory _res;
    (success, _res) = _target.call(_data);
    if (!success && _res.length > 0) {
      assembly {
        returndatacopy(0, 0, returndatasize())
        revert(0, returndatasize())
      }
    } else if (!success) {
      revert("VM: wallet invoke reverted");
    }
    return _res;
  }

  function toUint256(bytes memory _bytes) internal pure returns (uint256 value) {

    assembly {
      value := mload(add(_bytes, 0x20))
    }
  }

  function _msgSender() internal view override(ContextUpgradeSafe, BaseRelayRecipient) returns (address payable) {

    return BaseRelayRecipient._msgSender();
  }

  function _msgData() internal view override(ContextUpgradeSafe, BaseRelayRecipient) returns (bytes memory ret) {

    return BaseRelayRecipient._msgData();
  }

  function versionRecipient() external view override returns (string memory) {

    return "2.0.0";
  }
}