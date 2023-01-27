pragma solidity ^0.8.0;

interface IController {

    function isRelayer(address) external view returns (bool);


    function isTrustedPair(address) external view returns (bool);



    function router() external view returns (address);

}// MIT

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
}// MIT

pragma solidity ^0.8.0;


interface IERC20Metadata is IERC20 {

    function name() external view returns (string memory);


    function symbol() external view returns (string memory);


    function decimals() external view returns (uint8);

}pragma solidity ^0.8.0;


interface IGToken is IERC20 {

    function _wrap(uint256 amount, address user) external;


    function _unwrap(uint256 amount, address user) external;


    function asset() external view returns (IERC20Metadata);

}pragma solidity >=0.5.0;

interface IUniswapV2Factory {

    event PairCreated(address indexed token0, address indexed token1, address pair, uint);

    function feeTo() external view returns (address);

    function feeToSetter() external view returns (address);


    function getPair(address tokenA, address tokenB) external view returns (address pair);

    function allPairs(uint) external view returns (address pair);

    function allPairsLength() external view returns (uint);


    function createPair(address tokenA, address tokenB) external returns (address pair);


    function setFeeTo(address) external;

    function setFeeToSetter(address) external;

}pragma solidity >=0.6.2;

interface IUniswapV2Router01 {

    function factory() external pure returns (address);

    function WETH() external pure returns (address);


    function addLiquidity(
        address tokenA,
        address tokenB,
        uint amountADesired,
        uint amountBDesired,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB, uint liquidity);

    function addLiquidityETH(
        address token,
        uint amountTokenDesired,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external payable returns (uint amountToken, uint amountETH, uint liquidity);

    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB);

    function removeLiquidityETH(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external returns (uint amountToken, uint amountETH);

    function removeLiquidityWithPermit(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountA, uint amountB);

    function removeLiquidityETHWithPermit(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountToken, uint amountETH);

    function swapExactTokensForTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);

    function swapTokensForExactTokens(
        uint amountOut,
        uint amountInMax,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);

    function swapExactETHForTokens(uint amountOutMin, address[] calldata path, address to, uint deadline)
        external
        payable
        returns (uint[] memory amounts);

    function swapTokensForExactETH(uint amountOut, uint amountInMax, address[] calldata path, address to, uint deadline)
        external
        returns (uint[] memory amounts);

    function swapExactTokensForETH(uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline)
        external
        returns (uint[] memory amounts);

    function swapETHForExactTokens(uint amountOut, address[] calldata path, address to, uint deadline)
        external
        payable
        returns (uint[] memory amounts);


    function quote(uint amountA, uint reserveA, uint reserveB) external pure returns (uint amountB);

    function getAmountOut(uint amountIn, uint reserveIn, uint reserveOut) external pure returns (uint amountOut);

    function getAmountIn(uint amountOut, uint reserveIn, uint reserveOut) external pure returns (uint amountIn);

    function getAmountsOut(uint amountIn, address[] calldata path) external view returns (uint[] memory amounts);

    function getAmountsIn(uint amountOut, address[] calldata path) external view returns (uint[] memory amounts);

}pragma solidity >=0.6.2;


interface IUniswapV2Router02 is IUniswapV2Router01 {

    function removeLiquidityETHSupportingFeeOnTransferTokens(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external returns (uint amountETH);

    function removeLiquidityETHWithPermitSupportingFeeOnTransferTokens(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountETH);


    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;

    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external payable;

    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;

}// MIT

pragma solidity ^0.8.0;

abstract contract Initializable {

    bool private _initialized;

    bool private _initializing;

    modifier initializer() {
        require(_initializing || !_initialized, "Initializable: contract is already initialized");

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
}// MIT

pragma solidity ^0.8.0;

abstract contract ContextUpgradeable is Initializable {
    function __Context_init() internal initializer {
        __Context_init_unchained();
    }

    function __Context_init_unchained() internal initializer {
    }
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
    uint256[50] private __gap;
}// MIT

pragma solidity ^0.8.0;

abstract contract OwnableUpgradeable is Initializable, ContextUpgradeable {
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
    uint256[49] private __gap;
}// MIT

pragma solidity ^0.8.0;

library Address {

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

    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {

        return functionDelegateCall(target, data, "Address: low-level delegate call failed");
    }

    function functionDelegateCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {

        require(isContract(target), "Address: delegate call to non-contract");

        (bool success, bytes memory returndata) = target.delegatecall(data);
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

pragma solidity ^0.8.0;


library SafeERC20 {

    using Address for address;

    function safeTransfer(IERC20 token, address to, uint256 value) internal {

        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(IERC20 token, address from, address to, uint256 value) internal {

        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    function safeApprove(IERC20 token, address spender, uint256 value) internal {

        require((value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(IERC20 token, address spender, uint256 value) internal {

        uint256 newAllowance = token.allowance(address(this), spender) + value;
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(IERC20 token, address spender, uint256 value) internal {

        unchecked {
            uint256 oldAllowance = token.allowance(address(this), spender);
            require(oldAllowance >= value, "SafeERC20: decreased allowance below zero");
            uint256 newAllowance = oldAllowance - value;
            _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
        }
    }

    function _callOptionalReturn(IERC20 token, bytes memory data) private {


        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) { // Return data is optional
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}// MIT

pragma solidity ^0.8.0;

library ECDSA {

    function recover(bytes32 hash, bytes memory signature) internal pure returns (address) {

        bytes32 r;
        bytes32 s;
        uint8 v;

        if (signature.length == 65) {
            assembly {
                r := mload(add(signature, 0x20))
                s := mload(add(signature, 0x40))
                v := byte(0, mload(add(signature, 0x60)))
            }
        } else if (signature.length == 64) {
            assembly {
                let vs := mload(add(signature, 0x40))
                r := mload(add(signature, 0x20))
                s := and(vs, 0x7fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff)
                v := add(shr(255, vs), 27)
            }
        } else {
            revert("ECDSA: invalid signature length");
        }

        return recover(hash, v, r, s);
    }

    function recover(bytes32 hash, uint8 v, bytes32 r, bytes32 s) internal pure returns (address) {

        require(uint256(s) <= 0x7FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF5D576E7357A4501DDFE92F46681B20A0, "ECDSA: invalid signature 's' value");
        require(v == 27 || v == 28, "ECDSA: invalid signature 'v' value");

        address signer = ecrecover(hash, v, r, s);
        require(signer != address(0), "ECDSA: invalid signature");

        return signer;
    }

    function toEthSignedMessageHash(bytes32 hash) internal pure returns (bytes32) {

        return keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", hash));
    }

    function toTypedDataHash(bytes32 domainSeparator, bytes32 structHash) internal pure returns (bytes32) {

        return keccak256(abi.encodePacked("\x19\x01", domainSeparator, structHash));
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

library Strings {

    bytes16 private constant alphabet = "0123456789abcdef";

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
            buffer[i] = alphabet[value & 0xf];
            value >>= 4;
        }
        require(value == 0, "Strings: hex length insufficient");
        return string(buffer);
    }

}// MIT

pragma solidity ^0.8.0;

interface IERC165 {

    function supportsInterface(bytes4 interfaceId) external view returns (bool);

}// MIT

pragma solidity ^0.8.0;


abstract contract ERC165 is IERC165 {
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IERC165).interfaceId;
    }
}// MIT

pragma solidity ^0.8.0;


interface IAccessControl {

    function hasRole(bytes32 role, address account) external view returns (bool);

    function getRoleAdmin(bytes32 role) external view returns (bytes32);

    function grantRole(bytes32 role, address account) external;

    function revokeRole(bytes32 role, address account) external;

    function renounceRole(bytes32 role, address account) external;

}

abstract contract AccessControl is Context, IAccessControl, ERC165 {
    struct RoleData {
        mapping (address => bool) members;
        bytes32 adminRole;
    }

    mapping (bytes32 => RoleData) private _roles;

    bytes32 public constant DEFAULT_ADMIN_ROLE = 0x00;

    event RoleAdminChanged(bytes32 indexed role, bytes32 indexed previousAdminRole, bytes32 indexed newAdminRole);

    event RoleGranted(bytes32 indexed role, address indexed account, address indexed sender);

    event RoleRevoked(bytes32 indexed role, address indexed account, address indexed sender);

    modifier onlyRole(bytes32 role) {
        _checkRole(role, _msgSender());
        _;
    }

    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IAccessControl).interfaceId
            || super.supportsInterface(interfaceId);
    }

    function hasRole(bytes32 role, address account) public view override returns (bool) {
        return _roles[role].members[account];
    }

    function _checkRole(bytes32 role, address account) internal view {
        if(!hasRole(role, account)) {
            revert(string(abi.encodePacked(
                "AccessControl: account ",
                Strings.toHexString(uint160(account), 20),
                " is missing role ",
                Strings.toHexString(uint256(role), 32)
            )));
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
        emit RoleAdminChanged(role, getRoleAdmin(role), adminRole);
        _roles[role].adminRole = adminRole;
    }

    function _grantRole(bytes32 role, address account) private {
        if (!hasRole(role, account)) {
            _roles[role].members[account] = true;
            emit RoleGranted(role, account, _msgSender());
        }
    }

    function _revokeRole(bytes32 role, address account) private {
        if (hasRole(role, account)) {
            _roles[role].members[account] = false;
            emit RoleRevoked(role, account, _msgSender());
        }
    }
}// MIT

pragma solidity ^0.8.0;


contract TimelockController is AccessControl {

    bytes32 public constant TIMELOCK_ADMIN_ROLE = keccak256("TIMELOCK_ADMIN_ROLE");
    bytes32 public constant PROPOSER_ROLE = keccak256("PROPOSER_ROLE");
    bytes32 public constant EXECUTOR_ROLE = keccak256("EXECUTOR_ROLE");
    uint256 internal constant _DONE_TIMESTAMP = uint256(1);

    mapping(bytes32 => uint256) private _timestamps;
    uint256 private _minDelay;

    event CallScheduled(bytes32 indexed id, uint256 indexed index, address target, uint256 value, bytes data, bytes32 predecessor, uint256 delay);

    event CallExecuted(bytes32 indexed id, uint256 indexed index, address target, uint256 value, bytes data);

    event Cancelled(bytes32 indexed id);

    event MinDelayChange(uint256 oldDuration, uint256 newDuration);

    constructor(uint256 minDelay, address[] memory proposers, address[] memory executors) {
        _setRoleAdmin(TIMELOCK_ADMIN_ROLE, TIMELOCK_ADMIN_ROLE);
        _setRoleAdmin(PROPOSER_ROLE, TIMELOCK_ADMIN_ROLE);
        _setRoleAdmin(EXECUTOR_ROLE, TIMELOCK_ADMIN_ROLE);

        _setupRole(TIMELOCK_ADMIN_ROLE, _msgSender());
        _setupRole(TIMELOCK_ADMIN_ROLE, address(this));

        for (uint256 i = 0; i < proposers.length; ++i) {
            _setupRole(PROPOSER_ROLE, proposers[i]);
        }

        for (uint256 i = 0; i < executors.length; ++i) {
            _setupRole(EXECUTOR_ROLE, executors[i]);
        }

        _minDelay = minDelay;
        emit MinDelayChange(0, minDelay);
    }

    modifier onlyRoleOrOpenRole(bytes32 role) {

        if (!hasRole(role, address(0))) {
            _checkRole(role, _msgSender());
        }
        _;
    }

    receive() external payable {}

    function isOperation(bytes32 id) public view virtual returns (bool pending) {

        return getTimestamp(id) > 0;
    }

    function isOperationPending(bytes32 id) public view virtual returns (bool pending) {

        return getTimestamp(id) > _DONE_TIMESTAMP;
    }

    function isOperationReady(bytes32 id) public view virtual returns (bool ready) {

        uint256 timestamp = getTimestamp(id);
        return timestamp > _DONE_TIMESTAMP && timestamp <= block.timestamp;
    }

    function isOperationDone(bytes32 id) public view virtual returns (bool done) {

        return getTimestamp(id) == _DONE_TIMESTAMP;
    }

    function getTimestamp(bytes32 id) public view virtual returns (uint256 timestamp) {

        return _timestamps[id];
    }

    function getMinDelay() public view virtual returns (uint256 duration) {

        return _minDelay;
    }

    function hashOperation(address target, uint256 value, bytes calldata data, bytes32 predecessor, bytes32 salt) public pure virtual returns (bytes32 hash) {

        return keccak256(abi.encode(target, value, data, predecessor, salt));
    }

    function hashOperationBatch(address[] calldata targets, uint256[] calldata values, bytes[] calldata datas, bytes32 predecessor, bytes32 salt) public pure virtual returns (bytes32 hash) {

        return keccak256(abi.encode(targets, values, datas, predecessor, salt));
    }

    function schedule(address target, uint256 value, bytes calldata data, bytes32 predecessor, bytes32 salt, uint256 delay) public virtual onlyRole(PROPOSER_ROLE) {

        bytes32 id = hashOperation(target, value, data, predecessor, salt);
        _schedule(id, delay);
        emit CallScheduled(id, 0, target, value, data, predecessor, delay);
    }

    function scheduleBatch(address[] calldata targets, uint256[] calldata values, bytes[] calldata datas, bytes32 predecessor, bytes32 salt, uint256 delay) public virtual onlyRole(PROPOSER_ROLE) {

        require(targets.length == values.length, "TimelockController: length mismatch");
        require(targets.length == datas.length, "TimelockController: length mismatch");

        bytes32 id = hashOperationBatch(targets, values, datas, predecessor, salt);
        _schedule(id, delay);
        for (uint256 i = 0; i < targets.length; ++i) {
            emit CallScheduled(id, i, targets[i], values[i], datas[i], predecessor, delay);
        }
    }

    function _schedule(bytes32 id, uint256 delay) private {

        require(!isOperation(id), "TimelockController: operation already scheduled");
        require(delay >= getMinDelay(), "TimelockController: insufficient delay");
        _timestamps[id] = block.timestamp + delay;
    }

    function cancel(bytes32 id) public virtual onlyRole(PROPOSER_ROLE) {

        require(isOperationPending(id), "TimelockController: operation cannot be cancelled");
        delete _timestamps[id];

        emit Cancelled(id);
    }

    function execute(address target, uint256 value, bytes calldata data, bytes32 predecessor, bytes32 salt) public payable virtual onlyRoleOrOpenRole(EXECUTOR_ROLE) {

        bytes32 id = hashOperation(target, value, data, predecessor, salt);
        _beforeCall(predecessor);
        _call(id, 0, target, value, data);
        _afterCall(id);
    }

    function executeBatch(address[] calldata targets, uint256[] calldata values, bytes[] calldata datas, bytes32 predecessor, bytes32 salt) public payable virtual onlyRoleOrOpenRole(EXECUTOR_ROLE) {

        require(targets.length == values.length, "TimelockController: length mismatch");
        require(targets.length == datas.length, "TimelockController: length mismatch");

        bytes32 id = hashOperationBatch(targets, values, datas, predecessor, salt);
        _beforeCall(predecessor);
        for (uint256 i = 0; i < targets.length; ++i) {
            _call(id, i, targets[i], values[i], datas[i]);
        }
        _afterCall(id);
    }

    function _beforeCall(bytes32 predecessor) private view {

        require(predecessor == bytes32(0) || isOperationDone(predecessor), "TimelockController: missing dependency");
    }

    function _afterCall(bytes32 id) private {

        require(isOperationReady(id), "TimelockController: operation is not ready");
        _timestamps[id] = _DONE_TIMESTAMP;
    }

    function _call(bytes32 id, uint256 index, address target, uint256 value, bytes calldata data) private {

        (bool success,) = target.call{value: value}(data);
        require(success, "TimelockController: underlying transaction reverted");

        emit CallExecuted(id, index, target, value, data);
    }

    function updateDelay(uint256 newDelay) external virtual {

        require(msg.sender == address(this), "TimelockController: caller must be timelock");
        emit MinDelayChange(_minDelay, newDelay);
        _minDelay = newDelay;
    }
}// MIT

pragma solidity ^0.8.0;

abstract contract Proxy {
    function _delegate(address implementation) internal virtual {
        assembly {
            calldatacopy(0, 0, calldatasize())

            let result := delegatecall(gas(), implementation, 0, calldatasize(), 0, 0)

            returndatacopy(0, 0, returndatasize())

            switch result
            case 0 { revert(0, returndatasize()) }
            default { return(0, returndatasize()) }
        }
    }

    function _implementation() internal view virtual returns (address);

    function _fallback() internal virtual {
        _beforeFallback();
        _delegate(_implementation());
    }

    fallback () external payable virtual {
        _fallback();
    }

    receive () external payable virtual {
        _fallback();
    }

    function _beforeFallback() internal virtual {
    }
}// MIT

pragma solidity ^0.8.0;

interface IBeacon {

    function implementation() external view returns (address);

}// MIT

pragma solidity ^0.8.0;

library StorageSlot {

    struct AddressSlot {
        address value;
    }

    struct BooleanSlot {
        bool value;
    }

    struct Bytes32Slot {
        bytes32 value;
    }

    struct Uint256Slot {
        uint256 value;
    }

    function getAddressSlot(bytes32 slot) internal pure returns (AddressSlot storage r) {

        assembly {
            r.slot := slot
        }
    }

    function getBooleanSlot(bytes32 slot) internal pure returns (BooleanSlot storage r) {

        assembly {
            r.slot := slot
        }
    }

    function getBytes32Slot(bytes32 slot) internal pure returns (Bytes32Slot storage r) {

        assembly {
            r.slot := slot
        }
    }

    function getUint256Slot(bytes32 slot) internal pure returns (Uint256Slot storage r) {

        assembly {
            r.slot := slot
        }
    }
}// MIT

pragma solidity ^0.8.2;


abstract contract ERC1967Upgrade {
    bytes32 private constant _ROLLBACK_SLOT = 0x4910fdfa16fed3260ed0e7147f7cc6da11a60208b5b9406d12a635614ffd9143;

    bytes32 internal constant _IMPLEMENTATION_SLOT = 0x360894a13ba1a3210667c828492db98dca3e2076cc3735a920a3ca505d382bbc;

    event Upgraded(address indexed implementation);

    function _getImplementation() internal view returns (address) {
        return StorageSlot.getAddressSlot(_IMPLEMENTATION_SLOT).value;
    }

    function _setImplementation(address newImplementation) private {
        require(Address.isContract(newImplementation), "ERC1967: new implementation is not a contract");
        StorageSlot.getAddressSlot(_IMPLEMENTATION_SLOT).value = newImplementation;
    }

    function _upgradeTo(address newImplementation) internal {
        _setImplementation(newImplementation);
        emit Upgraded(newImplementation);
    }

    function _upgradeToAndCall(address newImplementation, bytes memory data, bool forceCall) internal {
        _setImplementation(newImplementation);
        emit Upgraded(newImplementation);
        if (data.length > 0 || forceCall) {
            Address.functionDelegateCall(newImplementation, data);
        }
    }

    function _upgradeToAndCallSecure(address newImplementation, bytes memory data, bool forceCall) internal {
        address oldImplementation = _getImplementation();

        _setImplementation(newImplementation);
        if (data.length > 0 || forceCall) {
            Address.functionDelegateCall(newImplementation, data);
        }

        StorageSlot.BooleanSlot storage rollbackTesting = StorageSlot.getBooleanSlot(_ROLLBACK_SLOT);
        if (!rollbackTesting.value) {
            rollbackTesting.value = true;
            Address.functionDelegateCall(
                newImplementation,
                abi.encodeWithSignature(
                    "upgradeTo(address)",
                    oldImplementation
                )
            );
            rollbackTesting.value = false;
            require(oldImplementation == _getImplementation(), "ERC1967Upgrade: upgrade breaks further upgrades");
            _setImplementation(newImplementation);
            emit Upgraded(newImplementation);
        }
    }

    function _upgradeBeaconToAndCall(address newBeacon, bytes memory data, bool forceCall) internal {
        _setBeacon(newBeacon);
        emit BeaconUpgraded(newBeacon);
        if (data.length > 0 || forceCall) {
            Address.functionDelegateCall(IBeacon(newBeacon).implementation(), data);
        }
    }

    bytes32 internal constant _ADMIN_SLOT = 0xb53127684a568b3173ae13b9f8a6016e243e63b6e8ee1178d6a717850b5d6103;

    event AdminChanged(address previousAdmin, address newAdmin);

    function _getAdmin() internal view returns (address) {
        return StorageSlot.getAddressSlot(_ADMIN_SLOT).value;
    }

    function _setAdmin(address newAdmin) private {
        require(newAdmin != address(0), "ERC1967: new admin is the zero address");
        StorageSlot.getAddressSlot(_ADMIN_SLOT).value = newAdmin;
    }

    function _changeAdmin(address newAdmin) internal {
        emit AdminChanged(_getAdmin(), newAdmin);
        _setAdmin(newAdmin);
    }

    bytes32 internal constant _BEACON_SLOT = 0xa3f0ad74e5423aebfd80d3ef4346578335a9a72aeaee59ff6cb3582b35133d50;

    event BeaconUpgraded(address indexed beacon);

    function _getBeacon() internal view returns (address) {
        return StorageSlot.getAddressSlot(_BEACON_SLOT).value;
    }

    function _setBeacon(address newBeacon) private {
        require(
            Address.isContract(newBeacon),
            "ERC1967: new beacon is not a contract"
        );
        require(
            Address.isContract(IBeacon(newBeacon).implementation()),
            "ERC1967: beacon implementation is not a contract"
        );
        StorageSlot.getAddressSlot(_BEACON_SLOT).value = newBeacon;
    }
}// MIT

pragma solidity ^0.8.0;


contract ERC1967Proxy is Proxy, ERC1967Upgrade {

    constructor(address _logic, bytes memory _data) payable {
        assert(_IMPLEMENTATION_SLOT == bytes32(uint256(keccak256("eip1967.proxy.implementation")) - 1));
        _upgradeToAndCall(_logic, _data, false);
    }

    function _implementation() internal view virtual override returns (address impl) {

        return ERC1967Upgrade._getImplementation();
    }
}// MIT

pragma solidity ^0.8.0;


contract TransparentUpgradeableProxy is ERC1967Proxy {

    constructor(address _logic, address admin_, bytes memory _data) payable ERC1967Proxy(_logic, _data) {
        assert(_ADMIN_SLOT == bytes32(uint256(keccak256("eip1967.proxy.admin")) - 1));
        _changeAdmin(admin_);
    }

    modifier ifAdmin() {

        if (msg.sender == _getAdmin()) {
            _;
        } else {
            _fallback();
        }
    }

    function admin() external ifAdmin returns (address admin_) {

        admin_ = _getAdmin();
    }

    function implementation() external ifAdmin returns (address implementation_) {

        implementation_ = _implementation();
    }

    function changeAdmin(address newAdmin) external virtual ifAdmin {

        _changeAdmin(newAdmin);
    }

    function upgradeTo(address newImplementation) external ifAdmin {

        _upgradeToAndCall(newImplementation, bytes(""), false);
    }

    function upgradeToAndCall(address newImplementation, bytes calldata data) external payable ifAdmin {

        _upgradeToAndCall(newImplementation, data, true);
    }

    function _admin() internal view virtual returns (address) {

        return _getAdmin();
    }

    function _beforeFallback() internal virtual override {

        require(msg.sender != _getAdmin(), "TransparentUpgradeableProxy: admin cannot fallback to proxy target");
        super._beforeFallback();
    }
}pragma solidity >=0.5.0;

interface IUniswapV2Pair {

    event Approval(address indexed owner, address indexed spender, uint value);
    event Transfer(address indexed from, address indexed to, uint value);

    function name() external pure returns (string memory);

    function symbol() external pure returns (string memory);

    function decimals() external pure returns (uint8);

    function totalSupply() external view returns (uint);

    function balanceOf(address owner) external view returns (uint);

    function allowance(address owner, address spender) external view returns (uint);


    function approve(address spender, uint value) external returns (bool);

    function transfer(address to, uint value) external returns (bool);

    function transferFrom(address from, address to, uint value) external returns (bool);


    function DOMAIN_SEPARATOR() external view returns (bytes32);

    function PERMIT_TYPEHASH() external pure returns (bytes32);

    function nonces(address owner) external view returns (uint);


    function permit(address owner, address spender, uint value, uint deadline, uint8 v, bytes32 r, bytes32 s) external;


    event Mint(address indexed sender, uint amount0, uint amount1);
    event Burn(address indexed sender, uint amount0, uint amount1, address indexed to);
    event Swap(
        address indexed sender,
        uint amount0In,
        uint amount1In,
        uint amount0Out,
        uint amount1Out,
        address indexed to
    );
    event Sync(uint112 reserve0, uint112 reserve1);

    function MINIMUM_LIQUIDITY() external pure returns (uint);

    function factory() external view returns (address);

    function token0() external view returns (address);

    function token1() external view returns (address);

    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);

    function price0CumulativeLast() external view returns (uint);

    function price1CumulativeLast() external view returns (uint);

    function kLast() external view returns (uint);


    function mint(address to) external returns (uint liquidity);

    function burn(address to) external returns (uint amount0, uint amount1);

    function swap(uint amount0Out, uint amount1Out, address to, bytes calldata data) external;

    function skim(address to) external;

    function sync() external;


    function initialize(address, address) external;

}pragma solidity >=0.5.0;

interface IUniswapV2ERC20 {

    event Approval(address indexed owner, address indexed spender, uint value);
    event Transfer(address indexed from, address indexed to, uint value);

    function name() external pure returns (string memory);

    function symbol() external pure returns (string memory);

    function decimals() external pure returns (uint8);

    function totalSupply() external view returns (uint);

    function balanceOf(address owner) external view returns (uint);

    function allowance(address owner, address spender) external view returns (uint);


    function approve(address spender, uint value) external returns (bool);

    function transfer(address to, uint value) external returns (bool);

    function transferFrom(address from, address to, uint value) external returns (bool);


    function DOMAIN_SEPARATOR() external view returns (bytes32);

    function PERMIT_TYPEHASH() external pure returns (bytes32);

    function nonces(address owner) external view returns (uint);


    function permit(address owner, address spender, uint value, uint deadline, uint8 v, bytes32 r, bytes32 s) external;

}// MIT
pragma solidity ^0.8.0;


contract Controller is IController, OwnableUpgradeable {

    using SafeERC20 for IERC20Metadata;
    using ECDSA for bytes32;



    IUniswapV2Router02 Router;
    IUniswapV2Factory Factory;

    mapping(address => bool) public relayers;

    mapping(address => bool) public trustedPair;

    mapping(address => uint256) public nonces;

    address gasFeeHolder;


    bytes32 public constant INIT_CODE_HASH = hex"96e8ac4277198ff8b6f785478aa9a39f403cb768dd02cbee326c3e7da348845f"; // does not take up storage


    bytes32 public constant ADDLIQUIDITY_TYPEHASH = 0x4d214baa73121bf1fd881822ff725e82a5194849fe9f33fa2cf93d3a8bcc1528;
    bytes32 public constant SWAP_TYPEHASH = 0x7f9ea4937fd3ee4bc72c788ef9ed621218765f5b35f26092eec44a8aac0b8c5b;

    struct SIGNATURE_TYPE {
        uint8 v;
        bytes32 r;
        bytes32 s;
    }

    struct ADDLIQUIDITY_TYPE {
        address tokenA;
        address tokenB;
        uint256 amountADesired;
        uint256 amountBDesired;
        uint256 amountAMin;
        uint256 amountBMin;
        address user;
        uint256 deadline;
        uint256 feeAmount;
        address feeToken;
    }

    struct SWAP_TYPE {
        uint256 amount0;
        uint256 amount1;
        address[] path;
        address user;
        uint256 deadline;
        uint256 feeAmount;
        address feeToken;
    }

    struct REMOVELIQUIDITY_TYPE {
        address tokenA;
        address tokenB;
        uint256 liquidity;
        uint256 amountAMin;
        uint256 amountBMin;
        address user;
        uint256 deadline;
        bool approveMax;
    }

    event RelayerAssignment(address indexed _relayer, bool _assignment);
    event PairTrusted(address indexed _pair, bool _status);
    event Config(address indexed _factory, address indexed _router);
    event RouterReverted(address indexed _user, uint256 _fee);
    event RouterSucceeded(address indexed _user, uint256 _fee);
    event GasFeeHolderConfigured(address indexed _gasFeeHolder);


    function verifySignature(
        bytes32 digest,
        address signer,
        SIGNATURE_TYPE memory sig
    ) public pure returns (bool) {

        address verifier = digest.recover(sig.v, sig.r, sig.s);
        return (signer == verifier) && (signer != address(0));
    }

    function _getChainId() private view returns (uint256) {

        uint256 chainId;
        assembly {
            chainId := chainid()
        }
        return chainId;
    }

    function _getDomainSeparator() private view returns (bytes32) {

        uint256 chainId = _getChainId();
        return
            keccak256(
                abi.encode(
                    keccak256("EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)"),
                    keccak256(bytes("GToken")),
                    keccak256(bytes("1")),
                    chainId,
                    address(this)
                )
            );
    }

    function _receivePayment(
        address _user,
        IGToken _token,
        uint256 _amount
    ) private {

        require(gasFeeHolder != address(0), "GTokenController: gasFeeHolder not configured!");
        _token.transferFrom(_user, gasFeeHolder, _amount);
    }

    function initialize(
        address _relayer,
        address _router,
        address _factory
    ) public initializer() {

        relayers[_relayer] = true;
        Router = IUniswapV2Router02(_router);
        Factory = IUniswapV2Factory(_factory);
        __Ownable_init();
    }

    function setRelayer(address _relayer, bool _assignment) public onlyOwner() {

        relayers[_relayer] = _assignment;
        emit RelayerAssignment(_relayer, _assignment);
    }

    function isRelayer(address _relayer) external view override returns (bool) {

        return relayers[_relayer];
    }

    modifier relayerOnly() {

        require(relayers[msg.sender], "GTOKENController: !relayer");
        _;
    }

    function isTrustedPair(address pair) public view override returns (bool) {

        return trustedPair[pair];
    }

    function addTrustedPair(address pair) public onlyOwner() {

        trustedPair[pair] = true;
        emit PairTrusted(pair, true);
    }

    function removeTrustedPair(address pair) public onlyOwner() {

        trustedPair[pair] = false;
        emit PairTrusted(pair, false);
    }

    function setGasFeeHolder(address _gasFeeHolder) public onlyOwner() {

        gasFeeHolder = _gasFeeHolder;
        emit GasFeeHolderConfigured(_gasFeeHolder);
    }

    function addLiquidity(ADDLIQUIDITY_TYPE memory al, SIGNATURE_TYPE memory signature) public relayerOnly() {

        {
            require(
                isTrustedPair(pairFor(address(Factory), al.tokenA, al.tokenB)),
                "GTokenController: Not a trusted pair!"
            );
            require(al.deadline >= block.timestamp, "GTOKENController: signature expired!");
            bytes32 message = keccak256(
                abi.encodePacked(
                    "\x19\x01",
                    _getDomainSeparator(),
                    keccak256(
                        abi.encode(
                            ADDLIQUIDITY_TYPEHASH,
                            al.tokenA,
                            al.tokenB,
                            al.amountADesired,
                            al.amountBDesired,
                            al.amountAMin,
                            al.amountBMin,
                            al.user,
                            nonces[al.user]++,
                            al.deadline,
                            al.feeAmount,
                            al.feeToken
                        )
                    )
                )
            );
            require(verifySignature(message, al.user, signature), "GTOKENController: Invalid signature!");
        }

        bool feeIsTokenA = address(IGToken(al.tokenA)) == al.feeToken;
        IGToken token = feeIsTokenA ? IGToken(al.tokenA) : IGToken(al.tokenB);
        if (feeIsTokenA) {
            _wrapTokens(al.tokenA, al.user, al.amountADesired + al.feeAmount);
            _wrapTokens(al.tokenB, al.user, al.amountBDesired);
        } else {
            _wrapTokens(al.tokenA, al.user, al.amountADesired);
            _wrapTokens(al.tokenB, al.user, al.amountBDesired + al.feeAmount);
        }

        {
            _receivePayment(al.user, token, al.feeAmount);
        }

        {

            IGToken(al.tokenA).transferFrom(al.user, address(this), al.amountADesired);
            IGToken(al.tokenB).transferFrom(al.user, address(this), al.amountBDesired);

            try
                Router.addLiquidity(
                    al.tokenA,
                    al.tokenB,
                    al.amountADesired,
                    al.amountBDesired,
                    al.amountAMin,
                    al.amountBMin,
                    al.user,
                    al.deadline
                )
            returns (uint256 amountA, uint256 amountB, uint256) {
                uint256 diffA = al.amountADesired - (amountA);
                uint256 diffB = al.amountBDesired - (amountB);

                if (diffA > 0) {
                    IGToken(al.tokenA).transferFrom(address(this), al.user, diffA);
                    _unwrapTokens(al.tokenA, al.user, diffA);
                }

                if (diffB > 0) {
                    IGToken(al.tokenB).transferFrom(address(this), al.user, diffB);
                    _unwrapTokens(al.tokenB, al.user, diffB);
                }
                emit RouterSucceeded(al.user, al.feeAmount);
            } catch {
                IGToken(al.tokenA).transferFrom(al.user, address(this), al.amountADesired);
                IGToken(al.tokenB).transferFrom(al.user, address(this), al.amountBDesired);

                _unwrapTokens(al.tokenA, al.user, al.amountADesired);
                _unwrapTokens(al.tokenA, al.user, al.amountBDesired);

                emit RouterReverted(al.user, al.feeAmount);
            }
        }
    }

    function swapExactTokensForTokens(SWAP_TYPE memory swap, SIGNATURE_TYPE memory signature) public relayerOnly() {

        uint256 end = swap.path.length - 1;
        for (uint256 i = 1; i <= end; i++) {
            require(
                isTrustedPair(pairFor(address(Factory), swap.path[i - 1], swap.path[i])),
                "GTokenController: Not a trusted pair!"
            );
        }

        {
            require(swap.deadline >= block.timestamp, "GTOKENController: signature expired!");

            bytes32 message = keccak256(
                abi.encodePacked(
                    "\x19\x01",
                    _getDomainSeparator(),
                    keccak256(
                        abi.encode(
                            SWAP_TYPEHASH,
                            swap.amount0,
                            swap.amount1,
                            keccak256(abi.encodePacked(swap.path)),
                            swap.user,
                            nonces[swap.user]++,
                            swap.deadline,
                            swap.feeAmount,
                            swap.feeToken
                        )
                    )
                )
            );
            require(verifySignature(message, swap.user, signature), "GTOKENController: Invalid signature!");
        }

        _wrapTokens(swap.path[0], swap.user, swap.amount0 + swap.feeAmount);

        {
            _receivePayment(swap.user, IGToken(swap.path[0]), swap.feeAmount);
        }

        IGToken(swap.path[0]).transferFrom(swap.user, address(this), swap.amount0);

        try Router.swapExactTokensForTokens(swap.amount0, swap.amount1, swap.path, swap.user, swap.deadline) returns (
            uint256[] memory amounts
        ) {
            _unwrapTokens(swap.path[end], swap.user, amounts[end]);
            emit RouterSucceeded(swap.user, swap.feeAmount);
        } catch {
            IGToken(swap.path[0]).transferFrom(address(this), swap.user, swap.amount0);
            _unwrapTokens(swap.path[0], swap.user, swap.amount0);
            emit RouterReverted(swap.user, swap.feeAmount);
        }
    }

    function swapTokensForExactTokens(SWAP_TYPE memory swap, SIGNATURE_TYPE memory signature) public relayerOnly() {

        uint256 end = swap.path.length - 1;
        for (uint256 i = 1; i <= end; i++) {
            require(
                isTrustedPair(pairFor(address(Factory), swap.path[i - 1], swap.path[i])),
                "GTokenController: Not a trusted pair!"
            );
        }

        {
            require(swap.deadline >= block.timestamp, "GTOKENController: signature expired!");

            bytes32 message = keccak256(
                abi.encodePacked(
                    "\x19\x01",
                    _getDomainSeparator(),
                    keccak256(
                        abi.encode(
                            SWAP_TYPEHASH,
                            swap.amount0,
                            swap.amount1,
                            keccak256(abi.encodePacked(swap.path)),
                            swap.user,
                            nonces[swap.user]++,
                            swap.deadline,
                            swap.feeAmount,
                            swap.feeToken
                        )
                    )
                )
            );
            require(verifySignature(message, swap.user, signature), "GTOKENController: Invalid signature!");
        }

        _wrapTokens(swap.path[0], swap.user, swap.amount1 + swap.feeAmount);

        {
            _receivePayment(swap.user, IGToken(swap.path[0]), swap.feeAmount);
        }

        IGToken(swap.path[0]).transferFrom(swap.user, address(this), swap.amount1);

        try Router.swapTokensForExactTokens(swap.amount0, swap.amount1, swap.path, swap.user, swap.deadline) returns (
            uint256[] memory amounts
        ) {
            uint256 diff = swap.amount1 - amounts[0];
            if (diff > 0) {
                IGToken(swap.path[0]).transferFrom(address(this), swap.user, diff);
                _unwrapTokens(swap.path[0], swap.user, diff);
            }

            _unwrapTokens(swap.path[end], swap.user, amounts[end]);
            emit RouterSucceeded(swap.user, swap.feeAmount);
        } catch {
            IGToken(swap.path[0]).transferFrom(address(this), swap.user, swap.amount1);
            _unwrapTokens(swap.path[0], swap.user, swap.amount1);
            emit RouterReverted(swap.user, swap.feeAmount);
        }
    }

    function _wrapTokens(
        address _gtoken,
        address _user,
        uint256 _amount
    ) private {

        IGToken(_gtoken)._wrap(_amount, _user);
    }

    function _unwrapTokens(
        address _gtoken,
        address _user,
        uint256 _amount
    ) private {

        IGToken(_gtoken)._unwrap(_amount, _user);
    }

    function config(address _factory, address _router) public onlyOwner() {

        Factory = IUniswapV2Factory(_factory);
        Router = IUniswapV2Router02(_router);
        emit Config(_factory, _router);
    }

    function router() external view override returns (address) {

        return address(Router);
    }

    function removeLiquidityWithPermit(REMOVELIQUIDITY_TYPE memory rl, SIGNATURE_TYPE memory sig) public {

        address pair = pairFor(address(Factory), rl.tokenA, rl.tokenB);
        require(isTrustedPair(pair), "GTokenController: Not a trusted pair!");
        uint256 value = rl.liquidity;
        IUniswapV2Pair(pair).permit(msg.sender, address(this), value, rl.deadline, sig.v, sig.r, sig.s);

        (bool success, bytes memory result) = address(Router).delegatecall(
            abi.encodeWithSelector(
                bytes4(Router.removeLiquidity.selector),
                rl.tokenA,
                rl.tokenB,
                rl.liquidity,
                rl.amountAMin,
                rl.amountBMin,
                rl.user,
                rl.deadline
            )
        );

        require(success, string(result));

        (uint256 amountA, uint256 amountB) = abi.decode(result, (uint256, uint256));

        _unwrapTokens(rl.tokenA, rl.user, amountA);
        _unwrapTokens(rl.tokenB, rl.user, amountB);
    }


    function sortTokens(address tokenA, address tokenB) internal pure returns (address token0, address token1) {

        require(tokenA != tokenB, "GTokenController: IDENTICAL_ADDRESSES");
        (token0, token1) = tokenA < tokenB ? (tokenA, tokenB) : (tokenB, tokenA);
        require(token0 != address(0), "GTokenController: ZERO_ADDRESS");
    }

    function pairFor(
        address factory,
        address tokenA,
        address tokenB
    ) internal pure returns (address pair) {

        (address token0, address token1) = sortTokens(tokenA, tokenB);
        pair = address(
            uint160(
                uint256(
                    keccak256(
                        abi.encodePacked(
                            bytes1(0xff),
                            factory,
                            keccak256(abi.encodePacked(token0, token1)),
                            INIT_CODE_HASH
                        )
                    )
                )
            )
        );
    }
}