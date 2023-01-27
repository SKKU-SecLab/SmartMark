
pragma solidity ^0.8.0;

library Clones {

    function clone(address implementation) internal returns (address instance) {

        assembly {
            let ptr := mload(0x40)
            mstore(ptr, 0x3d602d80600a3d3981f3363d3d373d3d3d363d73000000000000000000000000)
            mstore(add(ptr, 0x14), shl(0x60, implementation))
            mstore(add(ptr, 0x28), 0x5af43d82803e903d91602b57fd5bf30000000000000000000000000000000000)
            instance := create(0, ptr, 0x37)
        }
        require(instance != address(0), "ERC1167: create failed");
    }

    function cloneDeterministic(address implementation, bytes32 salt) internal returns (address instance) {

        assembly {
            let ptr := mload(0x40)
            mstore(ptr, 0x3d602d80600a3d3981f3363d3d373d3d3d363d73000000000000000000000000)
            mstore(add(ptr, 0x14), shl(0x60, implementation))
            mstore(add(ptr, 0x28), 0x5af43d82803e903d91602b57fd5bf30000000000000000000000000000000000)
            instance := create2(0, ptr, 0x37, salt)
        }
        require(instance != address(0), "ERC1167: create2 failed");
    }

    function predictDeterministicAddress(
        address implementation,
        bytes32 salt,
        address deployer
    ) internal pure returns (address predicted) {

        assembly {
            let ptr := mload(0x40)
            mstore(ptr, 0x3d602d80600a3d3981f3363d3d373d3d3d363d73000000000000000000000000)
            mstore(add(ptr, 0x14), shl(0x60, implementation))
            mstore(add(ptr, 0x28), 0x5af43d82803e903d91602b57fd5bf3ff00000000000000000000000000000000)
            mstore(add(ptr, 0x38), shl(0x60, deployer))
            mstore(add(ptr, 0x4c), salt)
            mstore(add(ptr, 0x6c), keccak256(ptr, 0x37))
            predicted := keccak256(add(ptr, 0x37), 0x55)
        }
    }

    function predictDeterministicAddress(address implementation, bytes32 salt)
        internal
        view
        returns (address predicted)
    {

        return predictDeterministicAddress(implementation, salt, address(this));
    }
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


abstract contract OwnableUpgradeable is Initializable {
    address private _owner;

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    function __Ownable_init(address newOwner) internal initializer {
        _transferOwnership(newOwner);
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(owner() == msg.sender, "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(
            newOwner != address(0),
            "Ownable: new owner is the zero address"
        );
        _transferOwnership(newOwner);
    }

    function _transferOwnership(address newOwner) private {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }

    uint256[49] private __gap;
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
    function __ERC165_init() internal initializer {
        __ERC165_init_unchained();
    }

    function __ERC165_init_unchained() internal initializer {
    }
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IERC165Upgradeable).interfaceId;
    }
    uint256[50] private __gap;
}// MIT

pragma solidity ^0.8.0;


abstract contract AccessControlUpgradeable is Initializable, ContextUpgradeable, IAccessControlUpgradeable, ERC165Upgradeable {
    function __AccessControl_init() internal initializer {
        __Context_init_unchained();
        __ERC165_init_unchained();
        __AccessControl_init_unchained();
    }

    function __AccessControl_init_unchained() internal initializer {
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


contract TimelockControllerUpgradeable is Initializable, AccessControlUpgradeable {

    bytes32 public constant TIMELOCK_ADMIN_ROLE = keccak256("TIMELOCK_ADMIN_ROLE");
    bytes32 public constant PROPOSER_ROLE = keccak256("PROPOSER_ROLE");
    bytes32 public constant EXECUTOR_ROLE = keccak256("EXECUTOR_ROLE");
    uint256 internal constant _DONE_TIMESTAMP = uint256(1);

    mapping(bytes32 => uint256) private _timestamps;
    uint256 private _minDelay;

    event CallScheduled(
        bytes32 indexed id,
        uint256 indexed index,
        address target,
        uint256 value,
        bytes data,
        bytes32 predecessor,
        uint256 delay
    );

    event CallExecuted(bytes32 indexed id, uint256 indexed index, address target, uint256 value, bytes data);

    event Cancelled(bytes32 indexed id);

    event MinDelayChange(uint256 oldDuration, uint256 newDuration);

    function __TimelockController_init(
        uint256 minDelay,
        address[] memory proposers,
        address[] memory executors
    ) internal initializer {

        __Context_init_unchained();
        __ERC165_init_unchained();
        __AccessControl_init_unchained();
        __TimelockController_init_unchained(minDelay, proposers, executors);
    }

    function __TimelockController_init_unchained(
        uint256 minDelay,
        address[] memory proposers,
        address[] memory executors
    ) internal initializer {

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

    function hashOperation(
        address target,
        uint256 value,
        bytes calldata data,
        bytes32 predecessor,
        bytes32 salt
    ) public pure virtual returns (bytes32 hash) {

        return keccak256(abi.encode(target, value, data, predecessor, salt));
    }

    function hashOperationBatch(
        address[] calldata targets,
        uint256[] calldata values,
        bytes[] calldata datas,
        bytes32 predecessor,
        bytes32 salt
    ) public pure virtual returns (bytes32 hash) {

        return keccak256(abi.encode(targets, values, datas, predecessor, salt));
    }

    function schedule(
        address target,
        uint256 value,
        bytes calldata data,
        bytes32 predecessor,
        bytes32 salt,
        uint256 delay
    ) public virtual onlyRole(PROPOSER_ROLE) {

        bytes32 id = hashOperation(target, value, data, predecessor, salt);
        _schedule(id, delay);
        emit CallScheduled(id, 0, target, value, data, predecessor, delay);
    }

    function scheduleBatch(
        address[] calldata targets,
        uint256[] calldata values,
        bytes[] calldata datas,
        bytes32 predecessor,
        bytes32 salt,
        uint256 delay
    ) public virtual onlyRole(PROPOSER_ROLE) {

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

    function execute(
        address target,
        uint256 value,
        bytes calldata data,
        bytes32 predecessor,
        bytes32 salt
    ) public payable virtual onlyRoleOrOpenRole(EXECUTOR_ROLE) {

        bytes32 id = hashOperation(target, value, data, predecessor, salt);
        _beforeCall(id, predecessor);
        _call(id, 0, target, value, data);
        _afterCall(id);
    }

    function executeBatch(
        address[] calldata targets,
        uint256[] calldata values,
        bytes[] calldata datas,
        bytes32 predecessor,
        bytes32 salt
    ) public payable virtual onlyRoleOrOpenRole(EXECUTOR_ROLE) {

        require(targets.length == values.length, "TimelockController: length mismatch");
        require(targets.length == datas.length, "TimelockController: length mismatch");

        bytes32 id = hashOperationBatch(targets, values, datas, predecessor, salt);
        _beforeCall(id, predecessor);
        for (uint256 i = 0; i < targets.length; ++i) {
            _call(id, i, targets[i], values[i], datas[i]);
        }
        _afterCall(id);
    }

    function _beforeCall(bytes32 id, bytes32 predecessor) private view {

        require(isOperationReady(id), "TimelockController: operation is not ready");
        require(predecessor == bytes32(0) || isOperationDone(predecessor), "TimelockController: missing dependency");
    }

    function _afterCall(bytes32 id) private {

        require(isOperationReady(id), "TimelockController: operation is not ready");
        _timestamps[id] = _DONE_TIMESTAMP;
    }

    function _call(
        bytes32 id,
        uint256 index,
        address target,
        uint256 value,
        bytes calldata data
    ) private {

        (bool success, ) = target.call{value: value}(data);
        require(success, "TimelockController: underlying transaction reverted");

        emit CallExecuted(id, index, target, value, data);
    }

    function updateDelay(uint256 newDelay) external virtual {

        require(msg.sender == address(this), "TimelockController: caller must be timelock");
        emit MinDelayChange(_minDelay, newDelay);
        _minDelay = newDelay;
    }
    uint256[48] private __gap;
}// GPL-3.0

pragma solidity ^0.8.0;

contract Timelock is TimelockControllerUpgradeable {

    function initialize(
        uint256 minDelay,
        address[] memory proposers,
        address[] memory executors
    ) public initializer {

        __TimelockController_init(minDelay, proposers, executors);
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


library SafeERC20Upgradeable {

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

        require(
            (value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(
        IERC20Upgradeable token,
        address spender,
        uint256 value
    ) internal {

        uint256 newAllowance = token.allowance(address(this), spender) + value;
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(
        IERC20Upgradeable token,
        address spender,
        uint256 value
    ) internal {

        unchecked {
            uint256 oldAllowance = token.allowance(address(this), spender);
            require(oldAllowance >= value, "SafeERC20: decreased allowance below zero");
            uint256 newAllowance = oldAllowance - value;
            _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
        }
    }

    function _callOptionalReturn(IERC20Upgradeable token, bytes memory data) private {


        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) {
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}// MIT

pragma solidity ^0.8.0;


interface IERC1155Upgradeable is IERC165Upgradeable {

    event TransferSingle(address indexed operator, address indexed from, address indexed to, uint256 id, uint256 value);

    event TransferBatch(
        address indexed operator,
        address indexed from,
        address indexed to,
        uint256[] ids,
        uint256[] values
    );

    event ApprovalForAll(address indexed account, address indexed operator, bool approved);

    event URI(string value, uint256 indexed id);

    function balanceOf(address account, uint256 id) external view returns (uint256);


    function balanceOfBatch(address[] calldata accounts, uint256[] calldata ids)
        external
        view
        returns (uint256[] memory);


    function setApprovalForAll(address operator, bool approved) external;


    function isApprovedForAll(address account, address operator) external view returns (bool);


    function safeTransferFrom(
        address from,
        address to,
        uint256 id,
        uint256 amount,
        bytes calldata data
    ) external;


    function safeBatchTransferFrom(
        address from,
        address to,
        uint256[] calldata ids,
        uint256[] calldata amounts,
        bytes calldata data
    ) external;

}// MIT

pragma solidity ^0.8.0;


interface IERC1155ReceiverUpgradeable is IERC165Upgradeable {

    function onERC1155Received(
        address operator,
        address from,
        uint256 id,
        uint256 value,
        bytes calldata data
    ) external returns (bytes4);


    function onERC1155BatchReceived(
        address operator,
        address from,
        uint256[] calldata ids,
        uint256[] calldata values,
        bytes calldata data
    ) external returns (bytes4);

}// MIT

pragma solidity ^0.8.0;


interface IERC1155MetadataURIUpgradeable is IERC1155Upgradeable {

    function uri(uint256 id) external view returns (string memory);

}// MIT

pragma solidity ^0.8.0;


contract ERC1155Upgradeable is Initializable, ContextUpgradeable, ERC165Upgradeable, IERC1155Upgradeable, IERC1155MetadataURIUpgradeable {

    using AddressUpgradeable for address;

    mapping(uint256 => mapping(address => uint256)) private _balances;

    mapping(address => mapping(address => bool)) private _operatorApprovals;

    string private _uri;

    function __ERC1155_init(string memory uri_) internal initializer {

        __Context_init_unchained();
        __ERC165_init_unchained();
        __ERC1155_init_unchained(uri_);
    }

    function __ERC1155_init_unchained(string memory uri_) internal initializer {

        _setURI(uri_);
    }

    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC165Upgradeable, IERC165Upgradeable) returns (bool) {

        return
            interfaceId == type(IERC1155Upgradeable).interfaceId ||
            interfaceId == type(IERC1155MetadataURIUpgradeable).interfaceId ||
            super.supportsInterface(interfaceId);
    }

    function uri(uint256) public view virtual override returns (string memory) {

        return _uri;
    }

    function balanceOf(address account, uint256 id) public view virtual override returns (uint256) {

        require(account != address(0), "ERC1155: balance query for the zero address");
        return _balances[id][account];
    }

    function balanceOfBatch(address[] memory accounts, uint256[] memory ids)
        public
        view
        virtual
        override
        returns (uint256[] memory)
    {

        require(accounts.length == ids.length, "ERC1155: accounts and ids length mismatch");

        uint256[] memory batchBalances = new uint256[](accounts.length);

        for (uint256 i = 0; i < accounts.length; ++i) {
            batchBalances[i] = balanceOf(accounts[i], ids[i]);
        }

        return batchBalances;
    }

    function setApprovalForAll(address operator, bool approved) public virtual override {

        _setApprovalForAll(_msgSender(), operator, approved);
    }

    function isApprovedForAll(address account, address operator) public view virtual override returns (bool) {

        return _operatorApprovals[account][operator];
    }

    function safeTransferFrom(
        address from,
        address to,
        uint256 id,
        uint256 amount,
        bytes memory data
    ) public virtual override {

        require(
            from == _msgSender() || isApprovedForAll(from, _msgSender()),
            "ERC1155: caller is not owner nor approved"
        );
        _safeTransferFrom(from, to, id, amount, data);
    }

    function safeBatchTransferFrom(
        address from,
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    ) public virtual override {

        require(
            from == _msgSender() || isApprovedForAll(from, _msgSender()),
            "ERC1155: transfer caller is not owner nor approved"
        );
        _safeBatchTransferFrom(from, to, ids, amounts, data);
    }

    function _safeTransferFrom(
        address from,
        address to,
        uint256 id,
        uint256 amount,
        bytes memory data
    ) internal virtual {

        require(to != address(0), "ERC1155: transfer to the zero address");

        address operator = _msgSender();

        _beforeTokenTransfer(operator, from, to, _asSingletonArray(id), _asSingletonArray(amount), data);

        uint256 fromBalance = _balances[id][from];
        require(fromBalance >= amount, "ERC1155: insufficient balance for transfer");
        unchecked {
            _balances[id][from] = fromBalance - amount;
        }
        _balances[id][to] += amount;

        emit TransferSingle(operator, from, to, id, amount);

        _doSafeTransferAcceptanceCheck(operator, from, to, id, amount, data);
    }

    function _safeBatchTransferFrom(
        address from,
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    ) internal virtual {

        require(ids.length == amounts.length, "ERC1155: ids and amounts length mismatch");
        require(to != address(0), "ERC1155: transfer to the zero address");

        address operator = _msgSender();

        _beforeTokenTransfer(operator, from, to, ids, amounts, data);

        for (uint256 i = 0; i < ids.length; ++i) {
            uint256 id = ids[i];
            uint256 amount = amounts[i];

            uint256 fromBalance = _balances[id][from];
            require(fromBalance >= amount, "ERC1155: insufficient balance for transfer");
            unchecked {
                _balances[id][from] = fromBalance - amount;
            }
            _balances[id][to] += amount;
        }

        emit TransferBatch(operator, from, to, ids, amounts);

        _doSafeBatchTransferAcceptanceCheck(operator, from, to, ids, amounts, data);
    }

    function _setURI(string memory newuri) internal virtual {

        _uri = newuri;
    }

    function _mint(
        address to,
        uint256 id,
        uint256 amount,
        bytes memory data
    ) internal virtual {

        require(to != address(0), "ERC1155: mint to the zero address");

        address operator = _msgSender();

        _beforeTokenTransfer(operator, address(0), to, _asSingletonArray(id), _asSingletonArray(amount), data);

        _balances[id][to] += amount;
        emit TransferSingle(operator, address(0), to, id, amount);

        _doSafeTransferAcceptanceCheck(operator, address(0), to, id, amount, data);
    }

    function _mintBatch(
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    ) internal virtual {

        require(to != address(0), "ERC1155: mint to the zero address");
        require(ids.length == amounts.length, "ERC1155: ids and amounts length mismatch");

        address operator = _msgSender();

        _beforeTokenTransfer(operator, address(0), to, ids, amounts, data);

        for (uint256 i = 0; i < ids.length; i++) {
            _balances[ids[i]][to] += amounts[i];
        }

        emit TransferBatch(operator, address(0), to, ids, amounts);

        _doSafeBatchTransferAcceptanceCheck(operator, address(0), to, ids, amounts, data);
    }

    function _burn(
        address from,
        uint256 id,
        uint256 amount
    ) internal virtual {

        require(from != address(0), "ERC1155: burn from the zero address");

        address operator = _msgSender();

        _beforeTokenTransfer(operator, from, address(0), _asSingletonArray(id), _asSingletonArray(amount), "");

        uint256 fromBalance = _balances[id][from];
        require(fromBalance >= amount, "ERC1155: burn amount exceeds balance");
        unchecked {
            _balances[id][from] = fromBalance - amount;
        }

        emit TransferSingle(operator, from, address(0), id, amount);
    }

    function _burnBatch(
        address from,
        uint256[] memory ids,
        uint256[] memory amounts
    ) internal virtual {

        require(from != address(0), "ERC1155: burn from the zero address");
        require(ids.length == amounts.length, "ERC1155: ids and amounts length mismatch");

        address operator = _msgSender();

        _beforeTokenTransfer(operator, from, address(0), ids, amounts, "");

        for (uint256 i = 0; i < ids.length; i++) {
            uint256 id = ids[i];
            uint256 amount = amounts[i];

            uint256 fromBalance = _balances[id][from];
            require(fromBalance >= amount, "ERC1155: burn amount exceeds balance");
            unchecked {
                _balances[id][from] = fromBalance - amount;
            }
        }

        emit TransferBatch(operator, from, address(0), ids, amounts);
    }

    function _setApprovalForAll(
        address owner,
        address operator,
        bool approved
    ) internal virtual {

        require(owner != operator, "ERC1155: setting approval status for self");
        _operatorApprovals[owner][operator] = approved;
        emit ApprovalForAll(owner, operator, approved);
    }

    function _beforeTokenTransfer(
        address operator,
        address from,
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    ) internal virtual {}


    function _doSafeTransferAcceptanceCheck(
        address operator,
        address from,
        address to,
        uint256 id,
        uint256 amount,
        bytes memory data
    ) private {

        if (to.isContract()) {
            try IERC1155ReceiverUpgradeable(to).onERC1155Received(operator, from, id, amount, data) returns (bytes4 response) {
                if (response != IERC1155ReceiverUpgradeable.onERC1155Received.selector) {
                    revert("ERC1155: ERC1155Receiver rejected tokens");
                }
            } catch Error(string memory reason) {
                revert(reason);
            } catch {
                revert("ERC1155: transfer to non ERC1155Receiver implementer");
            }
        }
    }

    function _doSafeBatchTransferAcceptanceCheck(
        address operator,
        address from,
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    ) private {

        if (to.isContract()) {
            try IERC1155ReceiverUpgradeable(to).onERC1155BatchReceived(operator, from, ids, amounts, data) returns (
                bytes4 response
            ) {
                if (response != IERC1155ReceiverUpgradeable.onERC1155BatchReceived.selector) {
                    revert("ERC1155: ERC1155Receiver rejected tokens");
                }
            } catch Error(string memory reason) {
                revert(reason);
            } catch {
                revert("ERC1155: transfer to non ERC1155Receiver implementer");
            }
        }
    }

    function _asSingletonArray(uint256 element) private pure returns (uint256[] memory) {

        uint256[] memory array = new uint256[](1);
        array[0] = element;

        return array;
    }
    uint256[47] private __gap;
}// MIT

pragma solidity ^0.8.0;


abstract contract ERC1155BurnableUpgradeable is Initializable, ERC1155Upgradeable {
    function __ERC1155Burnable_init() internal initializer {
        __Context_init_unchained();
        __ERC165_init_unchained();
        __ERC1155Burnable_init_unchained();
    }

    function __ERC1155Burnable_init_unchained() internal initializer {
    }
    function burn(
        address account,
        uint256 id,
        uint256 value
    ) public virtual {
        require(
            account == _msgSender() || isApprovedForAll(account, _msgSender()),
            "ERC1155: caller is not owner nor approved"
        );

        _burn(account, id, value);
    }

    function burnBatch(
        address account,
        uint256[] memory ids,
        uint256[] memory values
    ) public virtual {
        require(
            account == _msgSender() || isApprovedForAll(account, _msgSender()),
            "ERC1155: caller is not owner nor approved"
        );

        _burnBatch(account, ids, values);
    }
    uint256[50] private __gap;
}// MIT

pragma solidity ^0.8.0;

library CountersUpgradeable {

    struct Counter {
        uint256 _value; // default: 0
    }

    function current(Counter storage counter) internal view returns (uint256) {

        return counter._value;
    }

    function increment(Counter storage counter) internal {

        unchecked {
            counter._value += 1;
        }
    }

    function decrement(Counter storage counter) internal {

        uint256 value = counter._value;
        require(value > 0, "Counter: decrement overflow");
        unchecked {
            counter._value = value - 1;
        }
    }

    function reset(Counter storage counter) internal {

        counter._value = 0;
    }
}//  MIT
pragma solidity 0.8.6;

interface IAnalyticMath {

    function pow(
        uint256 a,
        uint256 b,
        uint256 c,
        uint256 d
    ) external view returns (uint256, uint256);


    function caculateIntPowerSum(uint256 power, uint256 n)
        external
        pure
        returns (uint256);

}// MIT

pragma solidity 0.8.6;


contract Curve is
    Initializable,
    OwnableUpgradeable,
    ERC1155BurnableUpgradeable
{

    using CountersUpgradeable for CountersUpgradeable.Counter;
    using SafeERC20Upgradeable for IERC20Upgradeable;

    IAnalyticMath public constant ANALYTICMATH =
        IAnalyticMath(0x6F1bB529BEd91cD7f75b14d68933AeC9d71eb723); // Mathmatical method for calculating power function

    string public name; // Contract name
    string public symbol; // Contract symbol
    string public baseUri;

    CountersUpgradeable.Counter private tokenIdTracker;

    uint256 public totalSupply; // total supply of erc1155 tokens

    IERC20Upgradeable public erc20; // collateral token on bonding curve
    uint256 public m; // slope of bonding curve
    uint256 public n; // numerator of exponent in curve power function
    uint256 public d; // denominator of exponent in curve power function
    uint256 public intPower; // when n/d is integer
    uint256 public virtualBalance; // vitual balance for setting a reasonable initial price

    mapping(uint256 => uint256) public decPowerCache; // cache of power function calculation result when exponent is decimal，n => cost
    uint256 public reserve; // reserve of collateral tokens stored in bonding curve AMM pool

    address payable public platform; // thePass platform's commission account
    uint256 public platformRate; // thePass platform's commission rate in pph

    address payable public receivingAddress; // receivingAddress's commission account
    uint256 public creatorRate; // receivingAddress's commission rate in pph

    event Minted(
        uint256 indexed tokenId,
        uint256 indexed cost,
        uint256 indexed reserveAfterMint,
        uint256 balance,
        uint256 platformProfit,
        uint256 creatorProfit
    );
    event Burned(
        address indexed account,
        uint256 indexed tokenId,
        uint256 balance,
        uint256 returnAmount,
        uint256 reserveAfterBurn
    );
    event BatchBurned(
        address indexed account,
        uint256[] tokenIds,
        uint256[] balances,
        uint256 returnAmount,
        uint256 reserveAfterBurn
    );
    event Withdraw(address indexed to, uint256 amount);

    function initialize(
        string[] memory infos, //[0]: _name,[1]: _symbol,[2]: _baseUri
        address[] memory addrs, //[0] _platform, [1]: _receivingAddress, [2]: _erc20 [3]: _timelock
        uint256[] memory parms //[0]_platformRate, [1]: _creatorRate, [2]: _initMintPrice, [3]: _m, [4]: _n, [5]: _d
    ) public virtual initializer {

        __Ownable_init(addrs[3]);
        __ERC1155_init(infos[2]);
        __ERC1155Burnable_init();

        tokenIdTracker = CountersUpgradeable.Counter({_value: 1});

        _setBasicInfo(infos[0], infos[1], infos[2], addrs[2]);
        _setFeeParameters(
            payable(addrs[0]),
            parms[0],
            payable(addrs[1]),
            parms[1]
        );
        _setCurveParms(parms[2], parms[3], parms[4], parms[5]);
    }

    function _setFeeParameters(
        address payable _platform,
        uint256 _platformRate,
        address payable _receivingAddress,
        uint256 _createRate
    ) internal {

        require(_platform != address(0), "Curve: platform address is zero");
        require(
            _receivingAddress != address(0),
            "Curve: receivingAddress address is zero"
        );

        platform = _platform;
        platformRate = _platformRate;
        receivingAddress = _receivingAddress;
        creatorRate = _createRate;
    }

    function changeBeneficiary(address payable _newAddress) public onlyOwner {

        require(_newAddress != address(0), "Curve: new address is zero");

        receivingAddress = _newAddress;
    }

    function mint(
        uint256 _balance,
        uint256 _amount,
        uint256 _maxPriceFirstPASS
    ) public returns (uint256) {

        require(address(erc20) != address(0), "Curve: erc20 address is null.");
        uint256 firstPrice = caculateCurrentCostToMint(1);
        require(
            _maxPriceFirstPASS >= firstPrice,
            "Curve: price exceeds slippage tolerance."
        );

        return _mint(_balance, _amount, false);
    }

    function mint(uint256 _balance, uint256 _amount) public returns (uint256) {

        require(address(erc20) != address(0), "Curve: erc20 address is null.");
        return _mint(_balance, _amount, false);
    }

    function burn(
        address _account,
        uint256 _tokenId,
        uint256 _balance
    ) public override {

        require(address(erc20) != address(0), "Curve: erc20 address is null.");

        super._burn(_account, _tokenId, _balance);

        uint256 burnReturn = getCurrentReturnToBurn(_balance);
        totalSupply -= _balance;
        reserve = reserve - burnReturn;

        erc20.safeTransfer(_account, burnReturn);

        emit Burned(_account, _tokenId, _balance, burnReturn, reserve);
    }

    function burnBatch(
        address _account,
        uint256[] memory _tokenIds,
        uint256[] memory _balances
    ) public override {

        require(address(erc20) != address(0), "Curve: erc20 address is null.");

        super._burnBatch(_account, _tokenIds, _balances);

        uint256 totalBalance;
        for (uint256 i = 0; i < _balances.length; i++) {
            totalBalance += _balances[i];
            totalSupply -= _balances[i];
        }

        uint256 burnReturn = getCurrentReturnToBurn(totalBalance);
        reserve = reserve - burnReturn;
        erc20.safeTransfer(_account, burnReturn);

        emit BatchBurned(_account, _tokenIds, _balances, burnReturn, reserve);
    }

    function mintEth(uint256 _balance, uint256 _maxPriceFirstPASS)
        public
        payable
        returns (uint256)
    {

        require(
            address(erc20) == address(0),
            "Curve: erc20 address is NOT null."
        );
        uint256 firstPrice = caculateCurrentCostToMint(1);
        require(
            _maxPriceFirstPASS >= firstPrice,
            "Curve: price exceeds slippage tolerance."
        );

        return _mint(_balance, msg.value, true);
    }

    function mintEth(uint256 _balance) public payable returns (uint256) {

        require(
            address(erc20) == address(0),
            "Curve: erc20 address is NOT null."
        );

        return _mint(_balance, msg.value, true);
    }

    function burnEth(
        address _account,
        uint256 _tokenId,
        uint256 _balance
    ) public {

        require(
            address(erc20) == address(0),
            "Curve: erc20 address is NOT null."
        );
        super._burn(_account, _tokenId, _balance);

        uint256 burnReturn = getCurrentReturnToBurn(_balance);

        totalSupply -= _balance;

        reserve = reserve - burnReturn;
        payable(_account).transfer(burnReturn);

        emit Burned(_account, _tokenId, _balance, burnReturn, reserve);
    }

    function burnBatchETH(
        address _account,
        uint256[] memory _tokenIds,
        uint256[] memory _balances
    ) public {

        require(address(erc20) == address(0), "Curve: erc20 address is null.");
        super._burnBatch(_account, _tokenIds, _balances);

        uint256 totalBalance;
        for (uint256 i = 0; i < _balances.length; i++) {
            totalBalance += _balances[i];
            totalSupply -= _balances[i];
        }

        uint256 burnReturn = getCurrentReturnToBurn(totalBalance);

        reserve = reserve - burnReturn;
        payable(_account).transfer(burnReturn);

        emit BatchBurned(_account, _tokenIds, _balances, burnReturn, reserve);
    }

    function uri(uint256 _tokenId)
        public
        view
        override
        returns (string memory)
    {

        return string(abi.encodePacked(baseUri, toString(_tokenId)));
    }

    function getCurrentSupply() public view returns (uint256) {

        return totalSupply;
    }

    function _mint(
        uint256 _balance,
        uint256 _amount,
        bool bETH
    ) private returns (uint256 tokenId) {

        uint256 mintCost = caculateCurrentCostToMint(_balance);
        require(_amount >= mintCost, "Curve: not enough token sent");

        address account = _msgSender();

        uint256 platformProfit = (mintCost * platformRate) / 100;
        uint256 creatorProfit = (mintCost * creatorRate) / 100;

        tokenId = tokenIdTracker.current(); // accumulate the token id
        tokenIdTracker.increment(); // automate token id increment

        totalSupply += _balance;
        _mint(account, tokenId, _balance, "");

        uint256 reserveCut = mintCost - platformProfit - creatorProfit;
        reserve = reserve + reserveCut;

        if (bETH) {
            if (_amount - (mintCost) > 0) {
                payable(account).transfer(_amount - (mintCost));
            }
            if (platformRate > 0) {
                platform.transfer(platformProfit);
            }
        } else {
            erc20.safeTransferFrom(account, address(this), mintCost);
            if (platformRate > 0) {
                erc20.safeTransfer(platform, platformProfit);
            }
        }

        emit Minted(
            tokenId,
            mintCost,
            reserve,
            _balance,
            platformProfit,
            creatorProfit
        );

        return tokenId; // returns tokenId in case its useful to check it
    }

    function _getEthBalance() internal view returns (uint256) {

        return address(this).balance;
    }

    function _getErc20Balance() internal view returns (uint256) {

        return IERC20Upgradeable(erc20).balanceOf(address(this));
    }

    function caculateCurrentCostToMint(uint256 _balance)
        internal
        returns (uint256)
    {

        uint256 curStartX = getCurrentSupply() + 1;
        uint256 totalCost;
        if (intPower > 0) {
            if (intPower <= 10) {
                uint256 intervalSum = caculateIntervalSum(
                    intPower,
                    curStartX,
                    curStartX + _balance - 1
                );
                totalCost = m * intervalSum + (virtualBalance * _balance);
            } else {
                for (uint256 i = curStartX; i < curStartX + _balance; i++) {
                    totalCost =
                        totalCost +
                        (m * (i**intPower) + (virtualBalance));
                }
            }
        } else {
            for (uint256 i = curStartX; i < curStartX + _balance; i++) {
                if (decPowerCache[i] == 0) {
                    (uint256 p, uint256 q) = ANALYTICMATH.pow(i, 1, n, d);
                    uint256 cost = virtualBalance + ((m * p) / q);
                    totalCost = totalCost + cost;
                    decPowerCache[i] = cost;
                } else {
                    totalCost = totalCost + decPowerCache[i];
                }
            }
        }
        return totalCost;
    }

    function getCurrentCostToMint(uint256 _balance)
        public
        view
        returns (uint256)
    {

        uint256 curStartX = getCurrentSupply() + 1;
        uint256 totalCost;
        if (intPower > 0) {
            if (intPower <= 10) {
                uint256 intervalSum = caculateIntervalSum(
                    intPower,
                    curStartX,
                    curStartX + _balance - 1
                );
                totalCost = m * (intervalSum) + (virtualBalance * _balance);
            } else {
                for (uint256 i = curStartX; i < curStartX + _balance; i++) {
                    totalCost =
                        totalCost +
                        (m * (i**intPower) + (virtualBalance));
                }
            }
        } else {
            for (uint256 i = curStartX; i < curStartX + _balance; i++) {
                (uint256 p, uint256 q) = ANALYTICMATH.pow(i, 1, n, d);
                uint256 cost = virtualBalance + ((m * p) / q);
                totalCost = totalCost + (cost);
            }
        }
        return totalCost;
    }

    function getCurrentReturnToBurn(uint256 _balance)
        public
        view
        returns (uint256)
    {

        uint256 curEndX = getCurrentSupply();
        _balance = _balance > curEndX ? curEndX : _balance;

        uint256 totalReturn;
        if (intPower > 0) {
            if (intPower <= 10) {
                uint256 intervalSum = caculateIntervalSum(
                    intPower,
                    curEndX - _balance + 1,
                    curEndX
                );
                totalReturn = m * intervalSum + (virtualBalance * (_balance));
            } else {
                for (uint256 i = curEndX; i > curEndX - _balance; i--) {
                    totalReturn =
                        totalReturn +
                        (m * (i**intPower) + (virtualBalance));
                }
            }
        } else {
            for (uint256 i = curEndX; i > curEndX - _balance; i--) {
                totalReturn = totalReturn + decPowerCache[i];
            }
        }
        totalReturn = (totalReturn * (100 - platformRate - creatorRate)) / 100;
        return totalReturn;
    }

    function caculateIntervalSum(
        uint256 _power,
        uint256 _startX,
        uint256 _endX
    ) public pure returns (uint256) {

        return
            ANALYTICMATH.caculateIntPowerSum(_power, _endX) -
            ANALYTICMATH.caculateIntPowerSum(_power, _startX - 1);
    }

    function withdraw() public {

        if (address(erc20) == address(0)) {
            receivingAddress.transfer(_getEthBalance() - reserve); // withdraw eth to beneficiary account
            emit Withdraw(receivingAddress, _getEthBalance() - reserve);
        } else {
            erc20.safeTransfer(receivingAddress, _getErc20Balance() - reserve); // withdraw erc20 tokens to beneficiary account
            emit Withdraw(receivingAddress, _getErc20Balance() - reserve);
        }
    }

    function _setBasicInfo(
        string memory _name,
        string memory _symbol,
        string memory _baseUri,
        address _erc20
    ) internal {

        name = _name;
        symbol = _symbol;
        baseUri = _baseUri;
        erc20 = IERC20Upgradeable(_erc20);
    }

    function _setCurveParms(
        uint256 _initMintPrice,
        uint256 _m,
        uint256 _n,
        uint256 _d
    ) internal {

        m = _m;
        n = _n;
        if ((_n / _d) * _d == _n) {
            intPower = _n / _d;
        } else {
            d = _d;
        }

        virtualBalance = _initMintPrice - _m;
        reserve = 0;
    }

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
}// MIT

pragma solidity 0.8.6;


contract CurveFactory is OwnableUpgradeable {

    address public immutable CURVE_IMPL;
    address public immutable TIMELOCK_IMPL;

    address payable public platform; // platform commision account
    uint256 public platformRate; // % of total minting cost as platform commission
    uint256 public totalRateLimit;

    event CurveCreated(
        address indexed owner,
        address indexed curveAddr,
        uint256 initMintPrice,
        uint256 m,
        uint256 n,
        uint256 d
    );
    event SetPlatformParms(
        address payable _platform,
        uint256 _platformRate,
        uint256 _totalRateLimit
    );

    constructor(
        address payable _platform,
        uint256 _platformRate,
        uint256 _totalRateLimit,
        address _timelock
    ) {
        __Ownable_init(_timelock);
        _setPlatformParms(_platform, _platformRate, _totalRateLimit);
        CURVE_IMPL = address(new Curve());
        TIMELOCK_IMPL = address(new Timelock());
    }

    function setPlatformParms(
        address payable _platform,
        uint256 _platformRate,
        uint256 _totalRateLimit
    ) public onlyOwner {

        _setPlatformParms(_platform, _platformRate, _totalRateLimit);
    }

    function _setPlatformParms(
        address payable _platform,
        uint256 _platformRate,
        uint256 _totalRateLimit
    ) internal {

        require(_platform != address(0), "Curve: platform address is zero.");
        require(
            _totalRateLimit <= 100 && _totalRateLimit >= _platformRate,
            "Curve: wrong rate"
        );

        platform = _platform;
        platformRate = _platformRate;
        totalRateLimit = _totalRateLimit;

        emit SetPlatformParms(_platform, _platformRate, _totalRateLimit);
    }

    function createCurve(
        string memory _name,
        string memory _symbol,
        address payable _receivingAddress,
        uint256 _creatorRate,
        uint256 _initMintPrice,
        address _erc20,
        uint256 _m,
        uint256 _n,
        uint256 _d,
        string memory _baseUri,
        address _timelock
    ) public {

        require(
            _creatorRate <= totalRateLimit - platformRate,
            "Curve: receivingAddress's commission rate is too high."
        );

        string[] memory infos = new string[](3);
        infos[0] = _name;
        infos[1] = _symbol;
        infos[2] = _baseUri;

        address[] memory addrs = new address[](4);
        addrs[0] = platform;
        addrs[1] = _receivingAddress;
        addrs[2] = _erc20;
        addrs[3] = _timelock == address(0) ? cloneTimelock() : _timelock;

        uint256[] memory parms = new uint256[](6);
        parms[0] = platformRate;
        parms[1] = _creatorRate;
        parms[2] = _initMintPrice;
        parms[3] = _m;
        parms[4] = _n;
        parms[5] = _d;

        address clone = Clones.clone(CURVE_IMPL);
        Curve(clone).initialize(infos, addrs, parms);
        emit CurveCreated(msg.sender, clone, _initMintPrice, _m, _n, _d);
    }

    function cloneTimelock() private returns (address payable newTimelock) {

        newTimelock = payable(Clones.clone(TIMELOCK_IMPL));

        uint256 minDelay = 2 days;
        address[] memory proposers = new address[](1);
        address[] memory executors = new address[](1);
        proposers[0] = msg.sender;
        executors[0] = address(0);

        Timelock(newTimelock).initialize(minDelay, proposers, executors);
        (minDelay, proposers, executors);

        return newTimelock;
    }
}