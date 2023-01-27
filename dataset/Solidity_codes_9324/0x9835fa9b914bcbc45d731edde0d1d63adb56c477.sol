
pragma solidity ^0.7.0;

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

pragma solidity ^0.7.0;

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

pragma solidity ^0.7.0;

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

pragma solidity ^0.7.0;


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

pragma solidity ^0.7.0;

interface IERC165Upgradeable {

    function supportsInterface(bytes4 interfaceId) external view returns (bool);

}// MIT

pragma solidity ^0.7.0;


interface IERC1155ReceiverUpgradeable is IERC165Upgradeable {


    function onERC1155Received(
        address operator,
        address from,
        uint256 id,
        uint256 value,
        bytes calldata data
    )
        external
        returns(bytes4);


    function onERC1155BatchReceived(
        address operator,
        address from,
        uint256[] calldata ids,
        uint256[] calldata values,
        bytes calldata data
    )
        external
        returns(bytes4);

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

pragma solidity ^0.7.0;


abstract contract ERC165Upgradeable is Initializable, IERC165Upgradeable {
    bytes4 private constant _INTERFACE_ID_ERC165 = 0x01ffc9a7;

    mapping(bytes4 => bool) private _supportedInterfaces;

    function __ERC165_init() internal initializer {
        __ERC165_init_unchained();
    }

    function __ERC165_init_unchained() internal initializer {
        _registerInterface(_INTERFACE_ID_ERC165);
    }

    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return _supportedInterfaces[interfaceId];
    }

    function _registerInterface(bytes4 interfaceId) internal virtual {
        require(interfaceId != 0xffffffff, "ERC165: invalid interface id");
        _supportedInterfaces[interfaceId] = true;
    }
    uint256[49] private __gap;
}// MIT

pragma solidity ^0.7.0;


abstract contract ERC1155ReceiverUpgradeable is Initializable, ERC165Upgradeable, IERC1155ReceiverUpgradeable {
    function __ERC1155Receiver_init() internal initializer {
        __ERC165_init_unchained();
        __ERC1155Receiver_init_unchained();
    }

    function __ERC1155Receiver_init_unchained() internal initializer {
        _registerInterface(
            ERC1155ReceiverUpgradeable(address(0)).onERC1155Received.selector ^
            ERC1155ReceiverUpgradeable(address(0)).onERC1155BatchReceived.selector
        );
    }
    uint256[50] private __gap;
}// MIT

pragma solidity ^0.7.0;


contract ERC1155HolderUpgradeable is Initializable, ERC1155ReceiverUpgradeable {

    function __ERC1155Holder_init() internal initializer {

        __ERC165_init_unchained();
        __ERC1155Receiver_init_unchained();
        __ERC1155Holder_init_unchained();
    }

    function __ERC1155Holder_init_unchained() internal initializer {

    }
    function onERC1155Received(address, address, uint256, uint256, bytes memory) public virtual override returns (bytes4) {

        return this.onERC1155Received.selector;
    }

    function onERC1155BatchReceived(address, address, uint256[] memory, uint256[] memory, bytes memory) public virtual override returns (bytes4) {

        return this.onERC1155BatchReceived.selector;
    }
    uint256[50] private __gap;
}// MIT

pragma solidity ^0.7.0;

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

pragma solidity ^0.7.0;


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

pragma solidity ^0.7.0;

abstract contract ReentrancyGuardUpgradeable is Initializable {

    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    function __ReentrancyGuard_init() internal initializer {
        __ReentrancyGuard_init_unchained();
    }

    function __ReentrancyGuard_init_unchained() internal initializer {
        _status = _NOT_ENTERED;
    }

    modifier nonReentrant() {
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        _status = _ENTERED;

        _;

        _status = _NOT_ENTERED;
    }
    uint256[49] private __gap;
}// MIT

pragma solidity ^0.7.0;

interface IERC165 {

    function supportsInterface(bytes4 interfaceId) external view returns (bool);

}// MIT

pragma solidity ^0.7.0;


interface IERC1155Receiver is IERC165 {


    function onERC1155Received(
        address operator,
        address from,
        uint256 id,
        uint256 value,
        bytes calldata data
    )
        external
        returns(bytes4);


    function onERC1155BatchReceived(
        address operator,
        address from,
        uint256[] calldata ids,
        uint256[] calldata values,
        bytes calldata data
    )
        external
        returns(bytes4);

}//GPL-3.0-only
pragma solidity ^0.7.0;


interface IXTokenWrapper is IERC1155Receiver {

    function tokenToXToken(address _token) external view returns (address);


    function xTokenToToken(address _xToken) external view returns (address);


    function wrap(address _token, uint256 _amount) external payable returns (bool);


    function unwrap(address _xToken, uint256 _amount) external returns (bool);

}//GPL-3.0-only
pragma solidity ^0.7.0;

interface IBPool {

    function isPublicSwap() external view returns (bool);


    function isFinalized() external view returns (bool);


    function isBound(address t) external view returns (bool);


    function getNumTokens() external view returns (uint256);


    function getCurrentTokens() external view returns (address[] memory tokens);


    function getFinalTokens() external view returns (address[] memory tokens);


    function getDenormalizedWeight(address token) external view returns (uint256);


    function getTotalDenormalizedWeight() external view returns (uint256);


    function getNormalizedWeight(address token) external view returns (uint256);


    function getBalance(address token) external view returns (uint256);


    function getSwapFee() external view returns (uint256);


    function getController() external view returns (address);


    function setSwapFee(uint256 swapFee) external;


    function setController(address manager) external;


    function setPublicSwap(bool public_) external;


    function finalize() external;


    function bind(
        address token,
        uint256 balance,
        uint256 denorm
    ) external;


    function rebind(
        address token,
        uint256 balance,
        uint256 denorm
    ) external;


    function unbind(address token) external;


    function gulp(address token) external;


    function getSpotPrice(address tokenIn, address tokenOut) external view returns (uint256 spotPrice);


    function getSpotPriceSansFee(address tokenIn, address tokenOut) external view returns (uint256 spotPrice);


    function joinPool(uint256 poolAmountOut, uint256[] calldata maxAmountsIn) external;


    function exitPool(uint256 poolAmountIn, uint256[] calldata minAmountsOut) external;


    function swapExactAmountIn(
        address tokenIn,
        uint256 tokenAmountIn,
        address tokenOut,
        uint256 minAmountOut,
        uint256 maxPrice
    ) external returns (uint256 tokenAmountOut, uint256 spotPriceAfter);


    function swapExactAmountOut(
        address tokenIn,
        uint256 maxAmountIn,
        address tokenOut,
        uint256 tokenAmountOut,
        uint256 maxPrice
    ) external returns (uint256 tokenAmountIn, uint256 spotPriceAfter);


    function joinswapExternAmountIn(
        address tokenIn,
        uint256 tokenAmountIn,
        uint256 minPoolAmountOut
    ) external returns (uint256 poolAmountOut);


    function joinswapPoolAmountOut(
        address tokenIn,
        uint256 poolAmountOut,
        uint256 maxAmountIn
    ) external returns (uint256 tokenAmountIn);


    function exitswapPoolAmountIn(
        address tokenOut,
        uint256 poolAmountIn,
        uint256 minAmountOut
    ) external returns (uint256 tokenAmountOut);


    function exitswapExternAmountOut(
        address tokenOut,
        uint256 tokenAmountOut,
        uint256 maxPoolAmountIn
    ) external returns (uint256 poolAmountIn);


    function totalSupply() external view returns (uint256);


    function balanceOf(address whom) external view returns (uint256);


    function allowance(address src, address dst) external view returns (uint256);


    function approve(address dst, uint256 amt) external returns (bool);


    function transfer(address dst, uint256 amt) external returns (bool);


    function transferFrom(
        address src,
        address dst,
        uint256 amt
    ) external returns (bool);


    function calcSpotPrice(
        uint256 tokenBalanceIn,
        uint256 tokenWeightIn,
        uint256 tokenBalanceOut,
        uint256 tokenWeightOut,
        uint256 swapFee
    ) external pure returns (uint256 spotPrice);


    function calcOutGivenIn(
        uint256 tokenBalanceIn,
        uint256 tokenWeightIn,
        uint256 tokenBalanceOut,
        uint256 tokenWeightOut,
        uint256 tokenAmountIn,
        uint256 swapFee
    ) external pure returns (uint256 tokenAmountOut);


    function calcInGivenOut(
        uint256 tokenBalanceIn,
        uint256 tokenWeightIn,
        uint256 tokenBalanceOut,
        uint256 tokenWeightOut,
        uint256 tokenAmountOut,
        uint256 swapFee
    ) external pure returns (uint256 tokenAmountIn);


    function calcPoolOutGivenSingleIn(
        uint256 tokenBalanceIn,
        uint256 tokenWeightIn,
        uint256 poolSupply,
        uint256 totalWeight,
        uint256 tokenAmountIn,
        uint256 swapFee
    ) external pure returns (uint256 poolAmountOut);


    function calcSingleInGivenPoolOut(
        uint256 tokenBalanceIn,
        uint256 tokenWeightIn,
        uint256 poolSupply,
        uint256 totalWeight,
        uint256 poolAmountOut,
        uint256 swapFee
    ) external pure returns (uint256 tokenAmountIn);


    function calcSingleOutGivenPoolIn(
        uint256 tokenBalanceOut,
        uint256 tokenWeightOut,
        uint256 poolSupply,
        uint256 totalWeight,
        uint256 poolAmountIn,
        uint256 swapFee
    ) external pure returns (uint256 tokenAmountOut);


    function calcPoolInGivenSingleOut(
        uint256 tokenBalanceOut,
        uint256 tokenWeightOut,
        uint256 poolSupply,
        uint256 totalWeight,
        uint256 tokenAmountOut,
        uint256 swapFee
    ) external pure returns (uint256 poolAmountIn);

}//GPL-3.0-only
pragma solidity ^0.7.0;


interface IBFactory {

    event LOG_NEW_POOL(address indexed caller, address indexed pool);

    function isBPool(address b) external view returns (bool);


    function newBPool() external returns (IBPool);


    function setExchProxy(address exchProxy) external;


    function setOperationsRegistry(address operationsRegistry) external;


    function setPermissionManager(address permissionManager) external;


    function setAuthorization(address _authorization) external;

}//GPL-3.0-only
pragma solidity ^0.7.0;


interface IBRegistry {

    function getBestPoolsWithLimit(
        address,
        address,
        uint256
    ) external view returns (address[] memory);


    function addPoolPair(
        address,
        address,
        address
    ) external returns (uint256);


    function sortPools(address[] calldata, uint256) external;

}//GPL-3.0-only
pragma solidity ^0.7.0;

interface IXTokenFactory {

    function deployXToken(
        address,
        string memory,
        string memory,
        uint8,
        string memory,
        address,
        address
    ) external returns (address);

}// MIT

pragma solidity ^0.7.0;

interface IERC20 {

    function totalSupply() external view returns (uint256);


    function balanceOf(address account) external view returns (uint256);


    function transfer(address recipient, uint256 amount) external returns (bool);


    function allowance(address owner, address spender) external view returns (uint256);


    function approve(address spender, uint256 amount) external returns (bool);


    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);


    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}//GPL-3.0-only
pragma solidity ^0.7.0;


interface IXToken is IERC20 {

    function pause() external;


    function unpause() external;


    function setAuthorization(address authorization_) external;


    function setOperationsRegistry(address operationsRegistry_) external;


    function setKya(string memory kya_) external;


    function mint(address account, uint256 amount) external;


    function burnFrom(address account, uint256 amount) external;


    function grantRole(bytes32 role, address account) external;

}// GPL-3.0-or-later
pragma solidity ^0.7.0;


contract ActionManager is
    Initializable,
    AccessControlUpgradeable,
    ERC1155HolderUpgradeable,
    ReentrancyGuardUpgradeable
{

    using SafeERC20Upgradeable for IERC20Upgradeable;

    address public bFactoryAddress;

    address public bRegistryAddress;

    address public xTokenFactoryAddress;

    address public xTokenWrapperAddress;

    address public authorizationProxyAddress;

    address public defaultPriceFeedAddress;

    address public xTokenAdminAddress;

    string public constant xSPT = "xSPT";

    uint256 public constant maxSwapFee = (3 * 1e18) / 100;

    event BFactorySet(address indexed _bFactoryAddress);

    event BRegistrySet(address indexed _bRegistryAddress);

    event XTokenFactorySet(address indexed _xTokenFactoryAddress);

    event XTokenWrapperSet(address indexed _xTokenWrapperAddress);

    event AuthorizationProxySet(address indexed _authorizationProxyAddress);

    event DefaultPriceFeedSet(address indexed _priceFeedAddress);

    event XTokenAdminSet(address indexed _xTokenAdminAddress);

    event PoolCreationSuccess(
        address indexed _msgSender,
        address indexed poolAndTokenAddress,
        address indexed poolXTokenAddress
    );

    modifier onlyAdmin() {

        require(hasRole(DEFAULT_ADMIN_ROLE, _msgSender()), "Caller is not admin");
        _;
    }

    function initialize(
        address _bFactoryAddress,
        address _bRegistryAddress,
        address _xTokenFactoryAddress,
        address _xTokenWrapperAddress,
        address _authorizationProxyAddress
    ) public initializer {

        _setupRole(DEFAULT_ADMIN_ROLE, _msgSender());
        _setBFactoryAddress(_bFactoryAddress);
        _setBRegistryAddress(_bRegistryAddress);
        _setXTokenFactoryAddress(_xTokenFactoryAddress);
        _setXTokenWrapperAddress(_xTokenWrapperAddress);
        _setAuthorizationProxyAddress(_authorizationProxyAddress);
    }

    function grantAdminRole(address newAdmin) external onlyAdmin {

        grantRole(DEFAULT_ADMIN_ROLE, newAdmin);
    }

    function setBFactory(address _bFactoryAddress) external onlyAdmin {

        _setBFactoryAddress(_bFactoryAddress);
    }

    function setBRegistry(address _bRegistryAddress) external onlyAdmin {

        _setBRegistryAddress(_bRegistryAddress);
    }

    function setXTokenFactory(address _xTokenFactoryAddress) external onlyAdmin {

        _setXTokenFactoryAddress(_xTokenFactoryAddress);
    }

    function setXTokenWrapper(address _xTokenWrapperAddress) external onlyAdmin {

        _setXTokenWrapperAddress(_xTokenWrapperAddress);
    }

    function setAuthorizationProxy(address _authorizationProxyAddress) external onlyAdmin {

        _setAuthorizationProxyAddress(_authorizationProxyAddress);
    }

    function setDefaultPriceFeed(address _priceFeedAddress) external onlyAdmin {

        require(_priceFeedAddress != address(0), "_priceFeedAddress is zero address");
        emit DefaultPriceFeedSet(_priceFeedAddress);
        defaultPriceFeedAddress = _priceFeedAddress;
    }

    function setXTokenAdmin(address _xTokenAdminAddress) external onlyAdmin {

        require(_xTokenAdminAddress != address(0), "_xTokenAdminAddress is zero address");
        emit XTokenAdminSet(_xTokenAdminAddress);
        xTokenAdminAddress = _xTokenAdminAddress;
    }

    function _setBFactoryAddress(address _bFactoryAddress) internal {

        require(_bFactoryAddress != address(0), "_bFactoryAddress is zero address");
        emit BFactorySet(_bFactoryAddress);
        bFactoryAddress = _bFactoryAddress;
    }

    function _setBRegistryAddress(address _bRegistryAddress) internal {

        require(_bRegistryAddress != address(0), "_bRegistryAddress is zero address");
        emit BRegistrySet(_bRegistryAddress);
        bRegistryAddress = _bRegistryAddress;
    }

    function _setXTokenFactoryAddress(address _xTokenFactoryAddress) internal {

        require(_xTokenFactoryAddress != address(0), "_xTokenFactoryAddress is zero address");
        emit XTokenFactorySet(_xTokenFactoryAddress);
        xTokenFactoryAddress = _xTokenFactoryAddress;
    }

    function _setXTokenWrapperAddress(address _xTokenWrapperAddress) internal {

        require(_xTokenWrapperAddress != address(0), "_xTokenWrapperAddress is zero address");
        emit XTokenWrapperSet(_xTokenWrapperAddress);
        xTokenWrapperAddress = _xTokenWrapperAddress;
    }

    function _setAuthorizationProxyAddress(address _authorizationProxyAddress) internal {

        require(_authorizationProxyAddress != address(0), "_authorizationProxyAddress is zero address");
        emit AuthorizationProxySet(_authorizationProxyAddress);
        authorizationProxyAddress = _authorizationProxyAddress;
    }

    function _tokenTransfer(
        address[] memory _tokens,
        address _from,
        address _to,
        uint256[] memory _amounts
    ) private returns (bool) {

        for (uint256 i = 0; i < _tokens.length; i++) {
            IERC20Upgradeable(_tokens[i]).safeTransferFrom(_from, _to, _amounts[i]);
        }
        return true;
    }

    function _approveTokenTransfer(
        address[] memory _tokens,
        address _spender,
        uint256[] memory _amounts
    ) private returns (bool) {

        bool returnedValue = false;
        for (uint256 i = 0; i < _tokens.length; i++) {
            returnedValue = IERC20Upgradeable(_tokens[i]).approve(_spender, _amounts[i]);
            require(returnedValue, "Approve failed");
        }
        return true;
    }

    function _wrapToken(address[] memory _tokenAddresses, uint256[] memory _amounts) private returns (bool) {

        bool returnedValue = false;
        IXTokenWrapper xTokenWrapperContract = IXTokenWrapper(xTokenWrapperAddress);
        for (uint256 i = 0; i < _tokenAddresses.length; i++) {
            returnedValue = xTokenWrapperContract.wrap(_tokenAddresses[i], _amounts[i]);
            require(returnedValue, "Wrap failed");
        }
        return true;
    }

    function _createNewPool() private returns (IBPool) {

        IBFactory bFactoryContract = IBFactory(bFactoryAddress);
        IBPool poolAndTokenContract = bFactoryContract.newBPool();

        bool txOk = poolAndTokenContract.getController() == address(this);
        require(txOk, "pool creation failed");
        return poolAndTokenContract;
    }

    function _getXTokenAddress(address _tokenAddress) private view returns (address) {

        IXTokenWrapper xTokenWrapperContract = IXTokenWrapper(xTokenWrapperAddress);
        address xTokenAddress = xTokenWrapperContract.tokenToXToken(_tokenAddress);
        return xTokenAddress;
    }

    function _buildXTokenArray(address[] memory _tokenAddresses) private view returns (address[] memory) {

        uint256 length = _tokenAddresses.length;
        address[] memory xTokensAddresses = new address[](length);

        for (uint256 i = 0; i < length; i++) {
            xTokensAddresses[i] = _getXTokenAddress(_tokenAddresses[i]);
        }

        require(xTokensAddresses.length == _tokenAddresses.length, "Invalid xTokenArray generated");
        return xTokensAddresses;
    }

    function _bindXTokensToPool(
        address[] memory _xTokenAddresses,
        uint256[] memory _amounts,
        uint256[] memory _xTokensWeight,
        IBPool poolAndTokenContract
    ) private returns (bool) {

        for (uint256 i = 0; i < _xTokenAddresses.length; i++) {
            poolAndTokenContract.bind(_xTokenAddresses[i], _amounts[i], _xTokensWeight[i]);
        }
        return true;
    }

    function _addPoolPair(address _poolAndTokenAddress, address[] memory _xTokenAddresses) private returns (bool) {

        IBRegistry bRegistryContract = IBRegistry(bRegistryAddress);

        for (uint256 i = 0; i < _xTokenAddresses.length - 1; i++) {
            for (uint256 j = i + 1; j < _xTokenAddresses.length; j++) {
                bRegistryContract.addPoolPair(_poolAndTokenAddress, _xTokenAddresses[i], _xTokenAddresses[j]);
            }
        }
        return true;
    }

    function _sortPools(address[] memory _xTokenAddresses) private returns (bool) {

        IBRegistry bRegistryContract = IBRegistry(bRegistryAddress);
        for (uint256 i = 0; i < _xTokenAddresses.length; i++) {
            bRegistryContract.sortPools(_xTokenAddresses, 10);
        }
        return true;
    }

    function _deployXPoolToken(
        address _poolContractAddress,
        address _priceFeed,
        string memory _poolName
    ) private returns (address) {

        IXTokenFactory xTokenFactoryContract = IXTokenFactory(xTokenFactoryAddress);
        address poolXTokenAddress =
            xTokenFactoryContract.deployXToken(
                _poolContractAddress,
                _poolName,
                xSPT,
                18,
                xSPT,
                authorizationProxyAddress,
                _priceFeed
            );

        IXToken xTokenContract = IXToken(poolXTokenAddress);
        bytes32 defaultAdminRole = 0x00;
        xTokenContract.grantRole(defaultAdminRole, xTokenAdminAddress);
        return poolXTokenAddress;
    }

    function _checkSwapFee(uint256 _swapFee) private pure {

        require(_swapFee > 0, "SwapFee is ZERO");

        require(_swapFee <= maxSwapFee, "SwapFee higher than bRegistry maxSwapFee");
    }

    function _checkArrays(
        address[] memory _tokenAddresses,
        uint256[] memory _amounts,
        uint256[] memory _xTokensWeight
    ) private pure {

        for (uint256 i = 0; i < _tokenAddresses.length; i++) {
            require(_tokenAddresses[i] != address(0), "Invalid tokenAddresses array");
            require(_amounts[i] > 0, "Invalid amounts array");
            require(_xTokensWeight[i] > 0, "Invalid xTokensWeight array");
        }
    }

    function _convertToArrayOfOneAddress(address _tokenAddress) private pure returns (address[] memory) {

        address[] memory tokenAddressArr = new address[](1);
        tokenAddressArr[0] = _tokenAddress;
        return tokenAddressArr;
    }

    function _convertToArrayOfOneUint(uint256 _amount) private pure returns (uint256[] memory) {

        uint256[] memory amountArr = new uint256[](1);
        amountArr[0] = _amount;
        return amountArr;
    }

    function standardPoolCreation(
        address[] memory tokenAddresses,
        uint256[] memory amounts,
        uint256 swapFee,
        uint256[] memory xTokensWeight,
        string memory poolName
    ) external nonReentrant returns (bool) {

        require(tokenAddresses.length == amounts.length, "Different tknAddress-amounts length");
        require(tokenAddresses.length == xTokensWeight.length, "Different tknAddress-xtknWeight length");
        require(bytes(poolName).length > 3, "Invalid PoolName provided"); // 3 chars pool name ?
        require(defaultPriceFeedAddress != address(0), "defaultPriceFeedAddress is NOT SET");
        require(xTokenAdminAddress != address(0), "xTokenAdminAddress is NOT SET");

        _checkSwapFee(swapFee);
        _checkArrays(tokenAddresses, amounts, xTokensWeight);

        bool txOk = false;

        txOk = _tokenTransfer(tokenAddresses, _msgSender(), address(this), amounts);
        require(txOk, "Transfer 01 - failed");

        _approveTokenTransfer(tokenAddresses, xTokenWrapperAddress, amounts);

        _wrapToken(tokenAddresses, amounts);

        IBPool poolAndTokenContract = _createNewPool();
        poolAndTokenContract.setSwapFee(swapFee);
        address poolAndTokenAddress = address(poolAndTokenContract);

        address[] memory xTokenAddresses = _buildXTokenArray(tokenAddresses);

        _approveTokenTransfer(xTokenAddresses, poolAndTokenAddress, amounts);

        txOk = _bindXTokensToPool(xTokenAddresses, amounts, xTokensWeight, poolAndTokenContract);
        require(txOk, "bind tkns failed");

        poolAndTokenContract.finalize();

        txOk = _addPoolPair(poolAndTokenAddress, xTokenAddresses);
        require(txOk, "addPoolPair failed");

        txOk = _sortPools(xTokenAddresses);
        require(txOk, "sortPools failed");

        address poolXTokenAddress = _deployXPoolToken(poolAndTokenAddress, defaultPriceFeedAddress, poolName);
        require(txOk, "deployXPoolToken failed");

        address[] memory poolAndTokenAddressArr = _convertToArrayOfOneAddress(poolAndTokenAddress);
        address[] memory poolXTokenAddressArr = _convertToArrayOfOneAddress(poolXTokenAddress);

        uint256 balanceToken = poolAndTokenContract.balanceOf(address(this));
        uint256[] memory balancePoolTokenArr = _convertToArrayOfOneUint(balanceToken);

        _approveTokenTransfer(poolAndTokenAddressArr, xTokenWrapperAddress, balancePoolTokenArr);
        _wrapToken(poolAndTokenAddressArr, balancePoolTokenArr);

        balanceToken = IERC20Upgradeable(poolXTokenAddress).balanceOf(address(this));
        uint256[] memory balanceXPoolTokenArr = _convertToArrayOfOneUint(balanceToken);

        _approveTokenTransfer(poolXTokenAddressArr, address(this), balanceXPoolTokenArr);

        txOk = _tokenTransfer(poolXTokenAddressArr, address(this), _msgSender(), balanceXPoolTokenArr);
        require(txOk, "Transfer 02 - failed");

        emit PoolCreationSuccess(_msgSender(), poolAndTokenAddress, poolXTokenAddress);

        return true;
    }
}