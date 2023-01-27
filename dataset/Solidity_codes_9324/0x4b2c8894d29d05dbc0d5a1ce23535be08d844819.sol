
pragma solidity ^0.8.0;

interface IAccessControl {

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

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}// MIT

pragma solidity ^0.8.0;

library Strings {

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


abstract contract AccessControl is Context, IAccessControl, ERC165 {
    struct RoleData {
        mapping(address => bool) members;
        bytes32 adminRole;
    }

    mapping(bytes32 => RoleData) private _roles;

    bytes32 public constant DEFAULT_ADMIN_ROLE = 0x00;

    modifier onlyRole(bytes32 role) {
        _checkRole(role);
        _;
    }

    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IAccessControl).interfaceId || super.supportsInterface(interfaceId);
    }

    function hasRole(bytes32 role, address account) public view virtual override returns (bool) {
        return _roles[role].members[account];
    }

    function _checkRole(bytes32 role) internal view virtual {
        _checkRole(role, _msgSender());
    }

    function _checkRole(bytes32 role, address account) internal view virtual {
        if (!hasRole(role, account)) {
            revert(
                string(
                    abi.encodePacked(
                        "AccessControl: account ",
                        Strings.toHexString(uint160(account), 20),
                        " is missing role ",
                        Strings.toHexString(uint256(role), 32)
                    )
                )
            );
        }
    }

    function getRoleAdmin(bytes32 role) public view virtual override returns (bytes32) {
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
}// MIT

pragma solidity ^0.8.0;

interface IERC721Receiver {

    function onERC721Received(
        address operator,
        address from,
        uint256 tokenId,
        bytes calldata data
    ) external returns (bytes4);

}// MIT

pragma solidity ^0.8.0;


interface IERC1155Receiver is IERC165 {

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


contract TimelockController is AccessControl, IERC721Receiver, IERC1155Receiver {

    bytes32 public constant TIMELOCK_ADMIN_ROLE = keccak256("TIMELOCK_ADMIN_ROLE");
    bytes32 public constant PROPOSER_ROLE = keccak256("PROPOSER_ROLE");
    bytes32 public constant EXECUTOR_ROLE = keccak256("EXECUTOR_ROLE");
    bytes32 public constant CANCELLER_ROLE = keccak256("CANCELLER_ROLE");
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

    constructor(
        uint256 minDelay,
        address[] memory proposers,
        address[] memory executors
    ) {
        _setRoleAdmin(TIMELOCK_ADMIN_ROLE, TIMELOCK_ADMIN_ROLE);
        _setRoleAdmin(PROPOSER_ROLE, TIMELOCK_ADMIN_ROLE);
        _setRoleAdmin(EXECUTOR_ROLE, TIMELOCK_ADMIN_ROLE);
        _setRoleAdmin(CANCELLER_ROLE, TIMELOCK_ADMIN_ROLE);

        _setupRole(TIMELOCK_ADMIN_ROLE, _msgSender());
        _setupRole(TIMELOCK_ADMIN_ROLE, address(this));

        for (uint256 i = 0; i < proposers.length; ++i) {
            _setupRole(PROPOSER_ROLE, proposers[i]);
            _setupRole(CANCELLER_ROLE, proposers[i]);
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

    function supportsInterface(bytes4 interfaceId) public view virtual override(IERC165, AccessControl) returns (bool) {

        return interfaceId == type(IERC1155Receiver).interfaceId || super.supportsInterface(interfaceId);
    }

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
        bytes[] calldata payloads,
        bytes32 predecessor,
        bytes32 salt
    ) public pure virtual returns (bytes32 hash) {

        return keccak256(abi.encode(targets, values, payloads, predecessor, salt));
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
        bytes[] calldata payloads,
        bytes32 predecessor,
        bytes32 salt,
        uint256 delay
    ) public virtual onlyRole(PROPOSER_ROLE) {

        require(targets.length == values.length, "TimelockController: length mismatch");
        require(targets.length == payloads.length, "TimelockController: length mismatch");

        bytes32 id = hashOperationBatch(targets, values, payloads, predecessor, salt);
        _schedule(id, delay);
        for (uint256 i = 0; i < targets.length; ++i) {
            emit CallScheduled(id, i, targets[i], values[i], payloads[i], predecessor, delay);
        }
    }

    function _schedule(bytes32 id, uint256 delay) private {

        require(!isOperation(id), "TimelockController: operation already scheduled");
        require(delay >= getMinDelay(), "TimelockController: insufficient delay");
        _timestamps[id] = block.timestamp + delay;
    }

    function cancel(bytes32 id) public virtual onlyRole(CANCELLER_ROLE) {

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
        bytes[] calldata payloads,
        bytes32 predecessor,
        bytes32 salt
    ) public payable virtual onlyRoleOrOpenRole(EXECUTOR_ROLE) {

        require(targets.length == values.length, "TimelockController: length mismatch");
        require(targets.length == payloads.length, "TimelockController: length mismatch");

        bytes32 id = hashOperationBatch(targets, values, payloads, predecessor, salt);
        _beforeCall(id, predecessor);
        for (uint256 i = 0; i < targets.length; ++i) {
            _call(id, i, targets[i], values[i], payloads[i]);
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

    function onERC721Received(
        address,
        address,
        uint256,
        bytes memory
    ) public virtual override returns (bytes4) {

        return this.onERC721Received.selector;
    }

    function onERC1155Received(
        address,
        address,
        uint256,
        uint256,
        bytes memory
    ) public virtual override returns (bytes4) {

        return this.onERC1155Received.selector;
    }

    function onERC1155BatchReceived(
        address,
        address,
        uint256[] memory,
        uint256[] memory,
        bytes memory
    ) public virtual override returns (bytes4) {

        return this.onERC1155BatchReceived.selector;
    }
}// MIT

pragma solidity ^0.8.0;


abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor() {
        _transferOwnership(_msgSender());
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }

    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}pragma solidity 0.8.7;

interface IControllerBase {

    function beforeTokenTransfer(
        address operator,
        address from,
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    ) external;


    function updatePodState(
        uint256 _podId,
        address _podAdmin,
        address _safeAddress
    ) external;

}pragma solidity 0.8.7;


interface IControllerV1 is IControllerBase {

    function updatePodEnsRegistrar(address _podEnsRegistrar) external;


    function createPod(
        address[] memory _members,
        uint256 threshold,
        address _admin,
        bytes32 _label,
        string memory _ensString,
        uint256 expectedPodId,
        string memory _imageUrl
    ) external;


    function createPodWithSafe(
        address _admin,
        address _safe,
        bytes32 _label,
        string memory _ensString,
        uint256 expectedPodId,
        string memory _imageUrl
    ) external;


    function setPodModuleLock(uint256 _podId, bool _isLocked) external;


    function setPodTransferLock(uint256 _podId, bool _isTransferLocked) external;


    function updatePodAdmin(uint256 _podId, address _newAdmin) external;


    function migratePodController(
        uint256 _podId,
        address _newController,
        address _prevModule
    ) external;

}// MIT

pragma solidity ^0.8.0;


interface IERC1155 is IERC165 {

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

}pragma solidity 0.8.7;


interface IMemberToken is IERC1155 {

    function totalSupply(uint256 id) external view returns (uint256);


    function exists(uint256 id) external view returns (bool);


    function getNextAvailablePodId() external view returns (uint256);


    function migrateMemberController(uint256 _podId, address _newController)
        external;


    function mint(
        address _account,
        uint256 _id,
        bytes memory data
    ) external;


    function mintSingleBatch(
        address[] memory _accounts,
        uint256 _id,
        bytes memory data
    ) external;


    function createPod(address[] memory _accounts, bytes memory data) external returns (uint256);

}pragma solidity 0.8.7;


interface IControllerRegistry{


    function isRegistered(address _controller) external view returns (bool);


}// MIT

pragma solidity ^0.8.1;

library Address {

    function isContract(address account) internal view returns (bool) {


        return account.code.length > 0;
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

    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {

        return functionDelegateCall(target, data, "Address: low-level delegate call failed");
    }

    function functionDelegateCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {

        require(isContract(target), "Address: delegate call to non-contract");

        (bool success, bytes memory returndata) = target.delegatecall(data);
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
}// GPL-3.0-or-later
pragma solidity ^0.8.0;

interface IGnosisSafe {

    enum Operation {
        Call,
        DelegateCall
    }

    function execTransactionFromModule(
        address to,
        uint256 value,
        bytes calldata data,
        Operation operation
    ) external returns (bool success);


    function execTransaction(
        address to,
        uint256 value,
        bytes calldata data,
        Operation operation,
        uint256 safeTxGas,
        uint256 baseGas,
        uint256 gasPrice,
        address gasToken,
        address payable refundReceiver,
        bytes memory signatures
    ) external payable returns (bool success);


    function approveHash(bytes32 hashToApprove) external;


    function encodeTransactionData(
        address to,
        uint256 value,
        bytes calldata data,
        Operation operation,
        uint256 safeTxGas,
        uint256 baseGas,
        uint256 gasPrice,
        address gasToken,
        address refundReceiver,
        uint256 _nonce
    ) external view returns (bytes memory);


    function getOwners() external view returns (address[] memory);


    function isOwner(address owner) external view returns (bool);


    function getThreshold() external view returns (uint256);


    function getModulesPaginated(address start, uint256 pageSize)
        external
        view
        returns (address[] memory array, address next);


    function isModuleEnabled(address module) external view returns (bool);

}pragma solidity 0.8.7;

interface IGnosisSafeProxyFactory {

    function createProxy(address singleton, bytes memory data)
        external
        returns (address);

}// LGPL-3.0-only
pragma solidity >=0.7.0 <0.9.0;

contract Enum {

    enum Operation {Call, DelegateCall}
}// LGPL-3.0-only
pragma solidity >=0.7.0 <0.9.0;


interface IGuard {

    function checkTransaction(
        address to,
        uint256 value,
        bytes memory data,
        Enum.Operation operation,
        uint256 safeTxGas,
        uint256 baseGas,
        uint256 gasPrice,
        address gasToken,
        address payable refundReceiver,
        bytes memory signatures,
        address msgSender
    ) external;


    function checkAfterExecution(bytes32 txHash, bool success) external;

}// LGPL-3.0-only
pragma solidity >=0.7.0 <0.9.0;


abstract contract BaseGuard is IERC165 {
    function supportsInterface(bytes4 interfaceId)
        external
        pure
        override
        returns (bool)
    {
        return
            interfaceId == type(IGuard).interfaceId || // 0xe6d7a83a
            interfaceId == type(IERC165).interfaceId; // 0x01ffc9a7
    }

    function checkTransaction(
        address to,
        uint256 value,
        bytes memory data,
        Enum.Operation operation,
        uint256 safeTxGas,
        uint256 baseGas,
        uint256 gasPrice,
        address gasToken,
        address payable refundReceiver,
        bytes memory signatures,
        address msgSender
    ) external virtual;

    function checkAfterExecution(bytes32 txHash, bool success) external virtual;
}pragma solidity 0.8.7;


contract SafeTeller is BaseGuard {

    using Address for address;

    address public immutable proxyFactoryAddress;

    address public immutable gnosisMasterAddress;
    address public immutable fallbackHandlerAddress;

    string public constant FUNCTION_SIG_SETUP =
        "setup(address[],uint256,address,bytes,address,address,uint256,address)";
    string public constant FUNCTION_SIG_EXEC =
        "execTransaction(address,uint256,bytes,uint8,uint256,uint256,uint256,address,address,bytes)";

    string public constant FUNCTION_SIG_ENABLE = "delegateSetup(address)";

    bytes4 public constant ENCODED_SIG_ENABLE_MOD =
        bytes4(keccak256("enableModule(address)"));
    bytes4 public constant ENCODED_SIG_DISABLE_MOD =
        bytes4(keccak256("disableModule(address,address)"));
    bytes4 public constant ENCODED_SIG_SET_GUARD =
        bytes4(keccak256("setGuard(address)"));

    address internal constant SENTINEL = address(0x1);

    mapping(address => bool) public areModulesLocked;

    constructor(
        address _proxyFactoryAddress,
        address _gnosisMasterAddress,
        address _fallbackHanderAddress
    ) {
        proxyFactoryAddress = _proxyFactoryAddress;
        gnosisMasterAddress = _gnosisMasterAddress;
        fallbackHandlerAddress = _fallbackHanderAddress;
    }

    function migrateSafeTeller(
        address _safe,
        address _newSafeTeller,
        address _prevModule
    ) internal {

        bytes memory enableData = abi.encodeWithSignature(
            "enableModule(address)",
            _newSafeTeller
        );

        bool enableSuccess = IGnosisSafe(_safe).execTransactionFromModule(
            _safe,
            0,
            enableData,
            IGnosisSafe.Operation.Call
        );
        require(enableSuccess, "Migration failed on enable");

        (address[] memory moduleBuffer, ) = IGnosisSafe(_safe)
            .getModulesPaginated(_prevModule, 1);
        require(moduleBuffer[0] == address(this), "incorrect prevModule");

        bytes memory disableData = abi.encodeWithSignature(
            "disableModule(address,address)",
            _prevModule,
            address(this)
        );

        bool disableSuccess = IGnosisSafe(_safe).execTransactionFromModule(
            _safe,
            0,
            disableData,
            IGnosisSafe.Operation.Call
        );
        require(disableSuccess, "Migration failed on disable");
    }

    function setSafeTellerAsGuard(address _safe) internal {

        bytes memory transferData = abi.encodeWithSignature(
            "setGuard(address)",
            address(this)
        );

        bool guardSuccess = IGnosisSafe(_safe).execTransactionFromModule(
            _safe,
            0,
            transferData,
            IGnosisSafe.Operation.Call
        );
        require(guardSuccess, "Could not enable guard");
    }

    function getSafeMembers(address safe)
        public
        view
        returns (address[] memory)
    {

        return IGnosisSafe(safe).getOwners();
    }

    function isSafeModuleEnabled(address safe) public view returns (bool) {

        return IGnosisSafe(safe).isModuleEnabled(address(this));
    }

    function isSafeMember(address safe, address member)
        public
        view
        returns (bool)
    {

        return IGnosisSafe(safe).isOwner(member);
    }

    function createSafe(address[] memory _owners, uint256 _threshold)
        internal
        returns (address safeAddress)
    {

        bytes memory data = abi.encodeWithSignature(
            FUNCTION_SIG_ENABLE,
            address(this)
        );

        bytes memory setupData = abi.encodeWithSignature(
            FUNCTION_SIG_SETUP,
            _owners,
            _threshold,
            this,
            data,
            fallbackHandlerAddress,
            address(0),
            uint256(0),
            address(0)
        );

        try
            IGnosisSafeProxyFactory(proxyFactoryAddress).createProxy(
                gnosisMasterAddress,
                setupData
            )
        returns (address newSafeAddress) {
            setSafeTellerAsGuard(newSafeAddress);

            return newSafeAddress;
        } catch (bytes memory) {
            revert("Create Proxy With Data Failed");
        }
    }

    function onMint(address to, address safe) internal {

        uint256 threshold = IGnosisSafe(safe).getThreshold();

        bytes memory data = abi.encodeWithSignature(
            "addOwnerWithThreshold(address,uint256)",
            to,
            threshold
        );

        bool success = IGnosisSafe(safe).execTransactionFromModule(
            safe,
            0,
            data,
            IGnosisSafe.Operation.Call
        );

        require(success, "Module Transaction Failed");
    }

    function onBurn(address from, address safe) internal {

        uint256 threshold = IGnosisSafe(safe).getThreshold();
        address[] memory owners = IGnosisSafe(safe).getOwners();

        address prevFrom = address(0);
        for (uint256 i = 0; i < owners.length; i++) {
            if (owners[i] == from) {
                if (i == 0) {
                    prevFrom = SENTINEL;
                } else {
                    prevFrom = owners[i - 1];
                }
            }
        }
        if (owners.length - 1 < threshold) threshold -= 1;
        bytes memory data = abi.encodeWithSignature(
            "removeOwner(address,address,uint256)",
            prevFrom,
            from,
            threshold
        );

        bool success = IGnosisSafe(safe).execTransactionFromModule(
            safe,
            0,
            data,
            IGnosisSafe.Operation.Call
        );
        require(success, "Module Transaction Failed");
    }

    function onTransfer(
        address from,
        address to,
        address safe
    ) internal {

        address[] memory owners = IGnosisSafe(safe).getOwners();

        address prevFrom;
        for (uint256 i = 0; i < owners.length; i++) {
            if (owners[i] == from) {
                if (i == 0) {
                    prevFrom = SENTINEL;
                } else {
                    prevFrom = owners[i - 1];
                }
            }
        }

        bytes memory data = abi.encodeWithSignature(
            "swapOwner(address,address,address)",
            prevFrom,
            from,
            to
        );

        bool success = IGnosisSafe(safe).execTransactionFromModule(
            safe,
            0,
            data,
            IGnosisSafe.Operation.Call
        );
        require(success, "Module Transaction Failed");
    }

    function setupSafeReverseResolver(
        address safe,
        address reverseRegistrar,
        string memory _ensString
    ) internal {

        bytes memory data = abi.encodeWithSignature(
            "setName(string)",
            _ensString
        );

        bool success = IGnosisSafe(safe).execTransactionFromModule(
            reverseRegistrar,
            0,
            data,
            IGnosisSafe.Operation.Call
        );
        require(success, "Module Transaction Failed");
    }

    function setModuleLock(address safe, bool isLocked) internal {

        areModulesLocked[safe] = isLocked;
    }

    function checkTransaction(
        address to,
        uint256 value,
        bytes memory data,
        Enum.Operation operation,
        uint256 safeTxGas,
        uint256 baseGas,
        uint256 gasPrice,
        address gasToken,
        address payable refundReceiver,
        bytes memory signatures,
        address msgSender
    ) external view override {

        address safe = msg.sender;
        if (!areModulesLocked[safe]) return;
        if (data.length >= 4) {
            require(
                bytes4(data) != ENCODED_SIG_ENABLE_MOD,
                "Cannot Enable Modules"
            );
            require(
                bytes4(data) != ENCODED_SIG_DISABLE_MOD,
                "Cannot Disable Modules"
            );
            require(
                bytes4(data) != ENCODED_SIG_SET_GUARD,
                "Cannot Change Guard"
            );
        }
    }

    function checkAfterExecution(bytes32, bool) external view override {}


    function enableModule(address module) external {

        require(module == address(0));
    }

    function delegateSetup(address _context) external {

        this.enableModule(_context);
    }
}pragma solidity 0.8.7;

interface IPodEnsRegistrar {

    function getRootNode() external view returns (bytes32);


    function registerPod(
        bytes32 label,
        address podSafe,
        address podCreator
    ) external returns (address);


    function register(bytes32 label, address owner) external;


    function setText(
        bytes32 node,
        string calldata key,
        string calldata value
    ) external;


    function addressToNode(address input) external returns (bytes32);


    function getEnsNode(bytes32 label) external view returns (bytes32);

}pragma solidity 0.8.7;



contract ControllerV1 is IControllerV1, SafeTeller, Ownable {

    event CreatePod(uint256 podId, address safe, address admin, string ensName);
    event UpdatePodAdmin(uint256 podId, address admin);

    IMemberToken public immutable memberToken;
    IControllerRegistry public immutable controllerRegistry;
    IPodEnsRegistrar public podEnsRegistrar;

    string public constant VERSION = "1.2.0";

    mapping(address => uint256) public safeToPodId;
    mapping(uint256 => address) public podIdToSafe;
    mapping(uint256 => address) public podAdmin;
    mapping(uint256 => bool) public isTransferLocked;

    uint8 internal constant CREATE_EVENT = 0x01;

    constructor(
        address _memberToken,
        address _controllerRegistry,
        address _proxyFactoryAddress,
        address _gnosisMasterAddress,
        address _podEnsRegistrar,
        address _fallbackHandlerAddress
    )
        SafeTeller(
            _proxyFactoryAddress,
            _gnosisMasterAddress,
            _fallbackHandlerAddress
        )
    {
        require(_memberToken != address(0), "Invalid address");
        require(_controllerRegistry != address(0), "Invalid address");
        require(_proxyFactoryAddress != address(0), "Invalid address");
        require(_gnosisMasterAddress != address(0), "Invalid address");
        require(_podEnsRegistrar != address(0), "Invalid address");
        require(_fallbackHandlerAddress != address(0), "Invalid address");

        memberToken = IMemberToken(_memberToken);
        controllerRegistry = IControllerRegistry(_controllerRegistry);
        podEnsRegistrar = IPodEnsRegistrar(_podEnsRegistrar);
    }

    function updatePodEnsRegistrar(address _podEnsRegistrar)
        external
        override
        onlyOwner
    {

        require(_podEnsRegistrar != address(0), "Invalid address");
        podEnsRegistrar = IPodEnsRegistrar(_podEnsRegistrar);
    }

    function createPod(
        address[] memory _members,
        uint256 threshold,
        address _admin,
        bytes32 _label,
        string memory _ensString,
        uint256 expectedPodId,
        string memory _imageUrl
    ) external override {

        address safe = createSafe(_members, threshold);

        _createPod(
            _members,
            safe,
            _admin,
            _label,
            _ensString,
            expectedPodId,
            _imageUrl
        );
    }

    function createPodWithSafe(
        address _admin,
        address _safe,
        bytes32 _label,
        string memory _ensString,
        uint256 expectedPodId,
        string memory _imageUrl
    ) external override {

        require(_safe != address(0), "invalid safe address");
        require(safeToPodId[_safe] == 0, "safe already in use");
        require(isSafeModuleEnabled(_safe), "safe module must be enabled");
        require(
            isSafeMember(_safe, msg.sender) || msg.sender == _safe,
            "caller must be safe or member"
        );

        address[] memory members = getSafeMembers(_safe);

        _createPod(
            members,
            _safe,
            _admin,
            _label,
            _ensString,
            expectedPodId,
            _imageUrl
        );
    }

    function _createPod(
        address[] memory _members,
        address _safe,
        address _admin,
        bytes32 _label,
        string memory _ensString,
        uint256 expectedPodId,
        string memory _imageUrl
    ) private {

        bytes memory data = new bytes(1);
        data[0] = bytes1(uint8(CREATE_EVENT));

        uint256 podId = memberToken.createPod(_members, data);
        require(podId == expectedPodId, "pod id didn't match, try again");

        emit CreatePod(podId, _safe, _admin, _ensString);
        emit UpdatePodAdmin(podId, _admin);

        if (_admin != address(0)) {
            setModuleLock(_safe, true);
            podAdmin[podId] = _admin;
        }
        podIdToSafe[podId] = _safe;
        safeToPodId[_safe] = podId;

        address reverseRegistrar = podEnsRegistrar.registerPod(
            _label,
            _safe,
            msg.sender
        );
        setupSafeReverseResolver(_safe, reverseRegistrar, _ensString);

        bytes32 node = podEnsRegistrar.getEnsNode(_label);
        podEnsRegistrar.setText(node, "avatar", _imageUrl);
        podEnsRegistrar.setText(node, "podId", Strings.toString(podId));
    }

    function setPodModuleLock(uint256 _podId, bool _isLocked)
        external
        override
    {

        require(
            msg.sender == podAdmin[_podId],
            "Must be admin to set module lock"
        );
        setModuleLock(podIdToSafe[_podId], _isLocked);
    }

    function updatePodAdmin(uint256 _podId, address _newAdmin)
        external
        override
    {

        address admin = podAdmin[_podId];
        address safe = podIdToSafe[_podId];

        require(safe != address(0), "Pod doesn't exist");

        if (admin == address(0)) {
            require(msg.sender == safe, "Only safe can add new admin");
        } else {
            require(msg.sender == admin, "Only admin can update admin");
        }
        setModuleLock(safe, _newAdmin != address(0));

        podAdmin[_podId] = _newAdmin;

        emit UpdatePodAdmin(_podId, _newAdmin);
    }

    function setPodTransferLock(uint256 _podId, bool _isTransferLocked)
        external
        override
    {

        address admin = podAdmin[_podId];
        address safe = podIdToSafe[_podId];

        if (admin == address(0)) {
            require(msg.sender == safe, "Only safe can set transfer lock");
        } else {
            require(
                msg.sender == admin || msg.sender == safe,
                "Only admin or safe can set transfer lock"
            );
        }

        isTransferLocked[_podId] = _isTransferLocked;
    }

    function migratePodController(
        uint256 _podId,
        address _newController,
        address _prevModule
    ) external override {

        require(_newController != address(0), "Invalid address");
        require(
            controllerRegistry.isRegistered(_newController),
            "Controller not registered"
        );

        address admin = podAdmin[_podId];
        address safe = podIdToSafe[_podId];

        require(
            msg.sender == admin || msg.sender == safe,
            "User not authorized"
        );

        IControllerBase newController = IControllerBase(_newController);

        podAdmin[_podId] = address(0);
        podIdToSafe[_podId] = address(0);
        safeToPodId[safe] = 0;
        memberToken.migrateMemberController(_podId, _newController);
        migrateSafeTeller(safe, _newController, _prevModule);
        newController.updatePodState(_podId, admin, safe);
    }

    function updatePodState(
        uint256 _podId,
        address _podAdmin,
        address _safeAddress
    ) external override {

        require(_safeAddress != address(0), "Invalid address");
        require(
            controllerRegistry.isRegistered(msg.sender),
            "Controller not registered"
        );
        require(
            podAdmin[_podId] == address(0) &&
                podIdToSafe[_podId] == address(0) &&
                safeToPodId[_safeAddress] == 0,
            "Pod already exists"
        );
        if (_podAdmin != address(0)) {
            podAdmin[_podId] = _podAdmin;
            setModuleLock(_safeAddress, true);
        }
        podIdToSafe[_podId] = _safeAddress;
        safeToPodId[_safeAddress] = _podId;

        setSafeTellerAsGuard(_safeAddress);

        emit UpdatePodAdmin(_podId, _podAdmin);
    }

    function beforeTokenTransfer(
        address operator,
        address from,
        address to,
        uint256[] memory ids,
        uint256[] memory,
        bytes memory data
    ) external override {

        require(msg.sender == address(memberToken), "Not Authorized");

        if (operator == address(this) && uint8(data[0]) == CREATE_EVENT) return;

        for (uint256 i = 0; i < ids.length; i += 1) {
            uint256 podId = ids[i];
            address safe = podIdToSafe[podId];
            address admin = podAdmin[podId];

            if (from == address(0)) {

                require(
                    operator == safe ||
                        operator == admin ||
                        operator == address(this),
                    "No Rules Set"
                );

                onMint(to, safe);
            } else if (to == address(0)) {

                require(
                    operator == safe ||
                        operator == admin ||
                        operator == address(this),
                    "No Rules Set"
                );

                onBurn(from, safe);
            } else {
                require(
                    isTransferLocked[podId] == false,
                    "Pod Is Transfer Locked"
                );
                onTransfer(from, to, safe);
            }
        }
    }
}// MIT

pragma solidity ^0.8.0;


interface IERC1155MetadataURI is IERC1155 {

    function uri(uint256 id) external view returns (string memory);

}// MIT

pragma solidity ^0.8.0;


contract ERC1155 is Context, ERC165, IERC1155, IERC1155MetadataURI {

    using Address for address;

    mapping(uint256 => mapping(address => uint256)) private _balances;

    mapping(address => mapping(address => bool)) private _operatorApprovals;

    string private _uri;

    constructor(string memory uri_) {
        _setURI(uri_);
    }

    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC165, IERC165) returns (bool) {

        return
            interfaceId == type(IERC1155).interfaceId ||
            interfaceId == type(IERC1155MetadataURI).interfaceId ||
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
        uint256[] memory ids = _asSingletonArray(id);
        uint256[] memory amounts = _asSingletonArray(amount);

        _beforeTokenTransfer(operator, from, to, ids, amounts, data);

        uint256 fromBalance = _balances[id][from];
        require(fromBalance >= amount, "ERC1155: insufficient balance for transfer");
        unchecked {
            _balances[id][from] = fromBalance - amount;
        }
        _balances[id][to] += amount;

        emit TransferSingle(operator, from, to, id, amount);

        _afterTokenTransfer(operator, from, to, ids, amounts, data);

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

        _afterTokenTransfer(operator, from, to, ids, amounts, data);

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
        uint256[] memory ids = _asSingletonArray(id);
        uint256[] memory amounts = _asSingletonArray(amount);

        _beforeTokenTransfer(operator, address(0), to, ids, amounts, data);

        _balances[id][to] += amount;
        emit TransferSingle(operator, address(0), to, id, amount);

        _afterTokenTransfer(operator, address(0), to, ids, amounts, data);

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

        _afterTokenTransfer(operator, address(0), to, ids, amounts, data);

        _doSafeBatchTransferAcceptanceCheck(operator, address(0), to, ids, amounts, data);
    }

    function _burn(
        address from,
        uint256 id,
        uint256 amount
    ) internal virtual {

        require(from != address(0), "ERC1155: burn from the zero address");

        address operator = _msgSender();
        uint256[] memory ids = _asSingletonArray(id);
        uint256[] memory amounts = _asSingletonArray(amount);

        _beforeTokenTransfer(operator, from, address(0), ids, amounts, "");

        uint256 fromBalance = _balances[id][from];
        require(fromBalance >= amount, "ERC1155: burn amount exceeds balance");
        unchecked {
            _balances[id][from] = fromBalance - amount;
        }

        emit TransferSingle(operator, from, address(0), id, amount);

        _afterTokenTransfer(operator, from, address(0), ids, amounts, "");
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

        _afterTokenTransfer(operator, from, address(0), ids, amounts, "");
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


    function _afterTokenTransfer(
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
            try IERC1155Receiver(to).onERC1155Received(operator, from, id, amount, data) returns (bytes4 response) {
                if (response != IERC1155Receiver.onERC1155Received.selector) {
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
            try IERC1155Receiver(to).onERC1155BatchReceived(operator, from, ids, amounts, data) returns (
                bytes4 response
            ) {
                if (response != IERC1155Receiver.onERC1155BatchReceived.selector) {
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
}// MIT

pragma solidity ^0.8.0;


abstract contract ERC1155Supply is ERC1155 {
    mapping(uint256 => uint256) private _totalSupply;

    function totalSupply(uint256 id) public view virtual returns (uint256) {
        return _totalSupply[id];
    }

    function exists(uint256 id) public view virtual returns (bool) {
        return ERC1155Supply.totalSupply(id) > 0;
    }

    function _beforeTokenTransfer(
        address operator,
        address from,
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    ) internal virtual override {
        super._beforeTokenTransfer(operator, from, to, ids, amounts, data);

        if (from == address(0)) {
            for (uint256 i = 0; i < ids.length; ++i) {
                _totalSupply[ids[i]] += amounts[i];
            }
        }

        if (to == address(0)) {
            for (uint256 i = 0; i < ids.length; ++i) {
                uint256 id = ids[i];
                uint256 amount = amounts[i];
                uint256 supply = _totalSupply[id];
                require(supply >= amount, "ERC1155: burn amount exceeds totalSupply");
                unchecked {
                    _totalSupply[id] = supply - amount;
                }
            }
        }
    }
}pragma solidity 0.8.7;



contract MemberToken is ERC1155Supply, Ownable {

    using Address for address;

    IControllerRegistry public controllerRegistry;

    mapping(uint256 => address) public memberController;

    uint256 public nextAvailablePodId = 0;
    string public _contractURI =
        "https://orcaprotocol-nft.vercel.app/assets/contract-metadata";

    event MigrateMemberController(uint256 podId, address newController);

    constructor(address _controllerRegistry, string memory uri) ERC1155(uri) {
        require(_controllerRegistry != address(0), "Invalid address");
        controllerRegistry = IControllerRegistry(_controllerRegistry);
    }

    function contractURI() public view returns (string memory) {

        return _contractURI;
    }

    function setContractURI(string memory newContractURI) public onlyOwner {

        _contractURI = newContractURI;
    }

    function migrateMemberController(uint256 _podId, address _newController)
        external
    {

        require(_newController != address(0), "Invalid address");
        require(
            msg.sender == memberController[_podId],
            "Invalid migrate controller"
        );
        require(
            controllerRegistry.isRegistered(_newController),
            "Controller not registered"
        );

        memberController[_podId] = _newController;
        emit MigrateMemberController(_podId, _newController);
    }

    function getNextAvailablePodId() external view returns (uint256) {

        return nextAvailablePodId;
    }

    function setUri(string memory uri) external onlyOwner {

        _setURI(uri);
    }

    function mint(
        address _account,
        uint256 _id,
        bytes memory data
    ) external {

        _mint(_account, _id, 1, data);
    }

    function mintSingleBatch(
        address[] memory _accounts,
        uint256 _id,
        bytes memory data
    ) public {

        for (uint256 index = 0; index < _accounts.length; index += 1) {
            _mint(_accounts[index], _id, 1, data);
        }
    }

    function burnSingleBatch(address[] memory _accounts, uint256 _id) public {

        for (uint256 index = 0; index < _accounts.length; index += 1) {
            _burn(_accounts[index], _id, 1);
        }
    }

    function createPod(address[] memory _accounts, bytes memory data)
        external
        returns (uint256)
    {

        uint256 id = nextAvailablePodId;
        nextAvailablePodId += 1;

        require(
            controllerRegistry.isRegistered(msg.sender),
            "Controller not registered"
        );

        memberController[id] = msg.sender;

        if (_accounts.length != 0) {
            mintSingleBatch(_accounts, id, data);
        }

        return id;
    }

    function burn(address _account, uint256 _id) external {

        _burn(_account, _id, 1);
    }

    function _beforeTokenTransfer(
        address operator,
        address from,
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    ) internal override {

        address controller = memberController[ids[0]];
        require(controller != address(0), "Pod doesn't exist");

        for (uint256 i = 0; i < ids.length; i += 1) {
            if (to != address(0)) {
                require(balanceOf(to, ids[i]) == 0, "User is already member");
            }
            require(
                memberController[ids[i]] == controller,
                "Ids have different controllers"
            );
        }

        IControllerBase(controller).beforeTokenTransfer(
            operator,
            from,
            to,
            ids,
            amounts,
            data
        );
    }
}// GPL-3.0-or-later
pragma solidity ^0.8.0;


interface IPodFactory {

    struct PodConfig {
        address[] members;
        uint256 threshold;
        bytes32 label;
        string ensString;
        string imageUrl;
        address admin;
        uint256 minDelay;
    }

    event CreatePod(uint256 indexed podId, address indexed safeAddress, address indexed timelock);
    event CreateTimelock(address indexed timelock);
    event UpdatePodController(address indexed oldController, address indexed newController);

    event UpdateDefaultPodController(address indexed oldController, address indexed newController);

    function deployCouncilPod(PodConfig calldata _config)
        external
        returns (
            uint256,
            address,
            address
        );


    function defaultPodController() external view returns (ControllerV1);


    function getMemberToken() external view returns (MemberToken);


    function getPodSafeAddresses() external view returns (address[] memory);


    function getNumberOfPods() external view returns (uint256);


    function getPodController(uint256 podId) external view returns (ControllerV1);


    function getPodSafe(uint256 podId) external view returns (address);


    function getPodTimelock(uint256 podId) external view returns (address);


    function getNumMembers(uint256 podId) external view returns (uint256);


    function getPodMembers(uint256 podId) external view returns (address[] memory);


    function getPodThreshold(uint256 podId) external view returns (uint256);


    function getIsMembershipTransferLocked(uint256 podId) external view returns (bool);


    function getNextPodId() external view returns (uint256);


    function getPodAdmin(uint256 podId) external view returns (address);


    function createOptimisticPod(PodConfig calldata _config)
        external
        returns (
            uint256,
            address,
            address
        );


    function updateDefaultPodController(address _newDefaultController) external;

}// GPL-3.0-or-later
pragma solidity ^0.8.4;

library TribeRoles {


    bytes32 internal constant GOVERNOR = keccak256("GOVERN_ROLE");

    bytes32 internal constant GUARDIAN = keccak256("GUARDIAN_ROLE");

    bytes32 internal constant PCV_CONTROLLER = keccak256("PCV_CONTROLLER_ROLE");

    bytes32 internal constant MINTER = keccak256("MINTER_ROLE");

    bytes32 internal constant ROLE_ADMIN = keccak256("ROLE_ADMIN");


    bytes32 internal constant POD_ADMIN = keccak256("POD_ADMIN");

    bytes32 internal constant POD_VETO_ADMIN = keccak256("POD_VETO_ADMIN");

    bytes32 internal constant PARAMETER_ADMIN = keccak256("PARAMETER_ADMIN");

    bytes32 internal constant ORACLE_ADMIN = keccak256("ORACLE_ADMIN_ROLE");

    bytes32 internal constant TRIBAL_CHIEF_ADMIN = keccak256("TRIBAL_CHIEF_ADMIN_ROLE");

    bytes32 internal constant PCV_GUARDIAN_ADMIN = keccak256("PCV_GUARDIAN_ADMIN_ROLE");

    bytes32 internal constant MINOR_ROLE_ADMIN = keccak256("MINOR_ROLE_ADMIN");

    bytes32 internal constant FUSE_ADMIN = keccak256("FUSE_ADMIN");

    bytes32 internal constant VETO_ADMIN = keccak256("VETO_ADMIN");

    bytes32 internal constant MINTER_ADMIN = keccak256("MINTER_ADMIN");

    bytes32 internal constant OPTIMISTIC_ADMIN = keccak256("OPTIMISTIC_ADMIN");

    bytes32 internal constant METAGOVERNANCE_VOTE_ADMIN = keccak256("METAGOVERNANCE_VOTE_ADMIN");

    bytes32 internal constant METAGOVERNANCE_TOKEN_STAKING = keccak256("METAGOVERNANCE_TOKEN_STAKING");

    bytes32 internal constant METAGOVERNANCE_GAUGE_ADMIN = keccak256("METAGOVERNANCE_GAUGE_ADMIN");

    bytes32 internal constant POD_METADATA_REGISTER_ROLE = keccak256("POD_METADATA_REGISTER_ROLE");

    bytes32 internal constant LBP_SWAP_ROLE = keccak256("SWAP_ADMIN_ROLE");

    bytes32 internal constant VOTIUM_ROLE = keccak256("VOTIUM_ADMIN_ROLE");

    bytes32 internal constant ADD_MINTER_ROLE = keccak256("ADD_MINTER_ROLE");

    bytes32 internal constant MINOR_PARAM_ROLE = keccak256("MINOR_PARAM_ROLE");

    bytes32 internal constant PSM_ADMIN_ROLE = keccak256("PSM_ADMIN_ROLE");
}// GPL-3.0-or-later
pragma solidity ^0.8.4;

interface IPermissionsRead {


    function isBurner(address _address) external view returns (bool);


    function isMinter(address _address) external view returns (bool);


    function isGovernor(address _address) external view returns (bool);


    function isGuardian(address _address) external view returns (bool);


    function isPCVController(address _address) external view returns (bool);

}// GPL-3.0-or-later
pragma solidity ^0.8.4;


interface IPermissions is IAccessControl, IPermissionsRead {


    function createRole(bytes32 role, bytes32 adminRole) external;


    function grantMinter(address minter) external;


    function grantBurner(address burner) external;


    function grantPCVController(address pcvController) external;


    function grantGovernor(address governor) external;


    function grantGuardian(address guardian) external;


    function revokeMinter(address minter) external;


    function revokeBurner(address burner) external;


    function revokePCVController(address pcvController) external;


    function revokeGovernor(address governor) external;


    function revokeGuardian(address guardian) external;



    function revokeOverride(bytes32 role, address account) external;



    function GUARDIAN_ROLE() external view returns (bytes32);


    function GOVERN_ROLE() external view returns (bytes32);


    function BURNER_ROLE() external view returns (bytes32);


    function MINTER_ROLE() external view returns (bytes32);


    function PCV_CONTROLLER_ROLE() external view returns (bytes32);

}// MIT

pragma solidity ^0.8.0;

interface IERC20 {

    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);

    function totalSupply() external view returns (uint256);


    function balanceOf(address account) external view returns (uint256);


    function transfer(address to, uint256 amount) external returns (bool);


    function allowance(address owner, address spender) external view returns (uint256);


    function approve(address spender, uint256 amount) external returns (bool);


    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);

}// GPL-3.0-or-later
pragma solidity ^0.8.4;


interface IFei is IERC20 {


    event Minting(address indexed _to, address indexed _minter, uint256 _amount);

    event Burning(address indexed _to, address indexed _burner, uint256 _amount);

    event IncentiveContractUpdate(address indexed _incentivized, address indexed _incentiveContract);


    function burn(uint256 amount) external;


    function permit(
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external;



    function burnFrom(address account, uint256 amount) external;



    function mint(address account, uint256 amount) external;



    function setIncentiveContract(address account, address incentive) external;



    function incentiveContract(address account) external view returns (address);

}// GPL-3.0-or-later
pragma solidity ^0.8.4;


interface ICore is IPermissions {


    event FeiUpdate(address indexed _fei);
    event TribeUpdate(address indexed _tribe);
    event GenesisGroupUpdate(address indexed _genesisGroup);
    event TribeAllocation(address indexed _to, uint256 _amount);
    event GenesisPeriodComplete(uint256 _timestamp);


    function init() external;



    function setFei(address token) external;


    function setTribe(address token) external;


    function allocateTribe(address to, uint256 amount) external;



    function fei() external view returns (IFei);


    function tribe() external view returns (IERC20);

}// GPL-3.0-or-later
pragma solidity ^0.8.4;


interface ICoreRef {


    event CoreUpdate(address indexed oldCore, address indexed newCore);

    event ContractAdminRoleUpdate(bytes32 indexed oldContractAdminRole, bytes32 indexed newContractAdminRole);


    function setContractAdminRole(bytes32 newContractAdminRole) external;



    function pause() external;


    function unpause() external;



    function core() external view returns (ICore);


    function fei() external view returns (IFei);


    function tribe() external view returns (IERC20);


    function feiBalance() external view returns (uint256);


    function tribeBalance() external view returns (uint256);


    function CONTRACT_ADMIN_ROLE() external view returns (bytes32);


    function isContractAdmin(address admin) external view returns (bool);

}// MIT

pragma solidity ^0.8.0;


abstract contract Pausable is Context {
    event Paused(address account);

    event Unpaused(address account);

    bool private _paused;

    constructor() {
        _paused = false;
    }

    function paused() public view virtual returns (bool) {
        return _paused;
    }

    modifier whenNotPaused() {
        require(!paused(), "Pausable: paused");
        _;
    }

    modifier whenPaused() {
        require(paused(), "Pausable: not paused");
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
}// GPL-3.0-or-later
pragma solidity ^0.8.4;


abstract contract CoreRef is ICoreRef, Pausable {
    ICore private immutable _core;
    IFei private immutable _fei;
    IERC20 private immutable _tribe;

    bytes32 public override CONTRACT_ADMIN_ROLE;

    constructor(address coreAddress) {
        _core = ICore(coreAddress);

        _fei = ICore(coreAddress).fei();
        _tribe = ICore(coreAddress).tribe();

        _setContractAdminRole(ICore(coreAddress).GOVERN_ROLE());
    }

    function _initialize(address) internal {} // no-op for backward compatibility

    modifier ifMinterSelf() {
        if (_core.isMinter(address(this))) {
            _;
        }
    }

    modifier onlyMinter() {
        require(_core.isMinter(msg.sender), "CoreRef: Caller is not a minter");
        _;
    }

    modifier onlyBurner() {
        require(_core.isBurner(msg.sender), "CoreRef: Caller is not a burner");
        _;
    }

    modifier onlyPCVController() {
        require(_core.isPCVController(msg.sender), "CoreRef: Caller is not a PCV controller");
        _;
    }

    modifier onlyGovernorOrAdmin() {
        require(
            _core.isGovernor(msg.sender) || isContractAdmin(msg.sender),
            "CoreRef: Caller is not a governor or contract admin"
        );
        _;
    }

    modifier onlyGovernor() {
        require(_core.isGovernor(msg.sender), "CoreRef: Caller is not a governor");
        _;
    }

    modifier onlyGuardianOrGovernor() {
        require(
            _core.isGovernor(msg.sender) || _core.isGuardian(msg.sender),
            "CoreRef: Caller is not a guardian or governor"
        );
        _;
    }

    modifier isGovernorOrGuardianOrAdmin() {
        require(
            _core.isGovernor(msg.sender) || _core.isGuardian(msg.sender) || isContractAdmin(msg.sender),
            "CoreRef: Caller is not governor or guardian or admin"
        );
        _;
    }

    modifier onlyTribeRole(bytes32 role) {
        require(_core.hasRole(role, msg.sender), "UNAUTHORIZED");
        _;
    }

    modifier hasAnyOfTwoRoles(bytes32 role1, bytes32 role2) {
        require(_core.hasRole(role1, msg.sender) || _core.hasRole(role2, msg.sender), "UNAUTHORIZED");
        _;
    }

    modifier hasAnyOfThreeRoles(
        bytes32 role1,
        bytes32 role2,
        bytes32 role3
    ) {
        require(
            _core.hasRole(role1, msg.sender) || _core.hasRole(role2, msg.sender) || _core.hasRole(role3, msg.sender),
            "UNAUTHORIZED"
        );
        _;
    }

    modifier hasAnyOfFourRoles(
        bytes32 role1,
        bytes32 role2,
        bytes32 role3,
        bytes32 role4
    ) {
        require(
            _core.hasRole(role1, msg.sender) ||
                _core.hasRole(role2, msg.sender) ||
                _core.hasRole(role3, msg.sender) ||
                _core.hasRole(role4, msg.sender),
            "UNAUTHORIZED"
        );
        _;
    }

    modifier hasAnyOfFiveRoles(
        bytes32 role1,
        bytes32 role2,
        bytes32 role3,
        bytes32 role4,
        bytes32 role5
    ) {
        require(
            _core.hasRole(role1, msg.sender) ||
                _core.hasRole(role2, msg.sender) ||
                _core.hasRole(role3, msg.sender) ||
                _core.hasRole(role4, msg.sender) ||
                _core.hasRole(role5, msg.sender),
            "UNAUTHORIZED"
        );
        _;
    }

    modifier hasAnyOfSixRoles(
        bytes32 role1,
        bytes32 role2,
        bytes32 role3,
        bytes32 role4,
        bytes32 role5,
        bytes32 role6
    ) {
        require(
            _core.hasRole(role1, msg.sender) ||
                _core.hasRole(role2, msg.sender) ||
                _core.hasRole(role3, msg.sender) ||
                _core.hasRole(role4, msg.sender) ||
                _core.hasRole(role5, msg.sender) ||
                _core.hasRole(role6, msg.sender),
            "UNAUTHORIZED"
        );
        _;
    }

    modifier onlyFei() {
        require(msg.sender == address(_fei), "CoreRef: Caller is not FEI");
        _;
    }

    function setContractAdminRole(bytes32 newContractAdminRole) external override onlyGovernor {
        _setContractAdminRole(newContractAdminRole);
    }

    function isContractAdmin(address _admin) public view override returns (bool) {
        return _core.hasRole(CONTRACT_ADMIN_ROLE, _admin);
    }

    function pause() public override onlyGuardianOrGovernor {
        _pause();
    }

    function unpause() public override onlyGuardianOrGovernor {
        _unpause();
    }

    function core() public view override returns (ICore) {
        return _core;
    }

    function fei() public view override returns (IFei) {
        return _fei;
    }

    function tribe() public view override returns (IERC20) {
        return _tribe;
    }

    function feiBalance() public view override returns (uint256) {
        return _fei.balanceOf(address(this));
    }

    function tribeBalance() public view override returns (uint256) {
        return _tribe.balanceOf(address(this));
    }

    function _burnFeiHeld() internal {
        _fei.burn(feiBalance());
    }

    function _mintFei(address to, uint256 amount) internal virtual {
        if (amount != 0) {
            _fei.mint(to, amount);
        }
    }

    function _setContractAdminRole(bytes32 newContractAdminRole) internal {
        bytes32 oldContractAdminRole = CONTRACT_ADMIN_ROLE;
        CONTRACT_ADMIN_ROLE = newContractAdminRole;
        emit ContractAdminRoleUpdate(oldContractAdminRole, newContractAdminRole);
    }
}// MIT

pragma solidity ^0.8.2;


abstract contract Initializable {
    uint8 private _initialized;

    bool private _initializing;

    event Initialized(uint8 version);

    modifier initializer() {
        bool isTopLevelCall = _setInitializedVersion(1);
        if (isTopLevelCall) {
            _initializing = true;
        }
        _;
        if (isTopLevelCall) {
            _initializing = false;
            emit Initialized(1);
        }
    }

    modifier reinitializer(uint8 version) {
        bool isTopLevelCall = _setInitializedVersion(version);
        if (isTopLevelCall) {
            _initializing = true;
        }
        _;
        if (isTopLevelCall) {
            _initializing = false;
            emit Initialized(version);
        }
    }

    modifier onlyInitializing() {
        require(_initializing, "Initializable: contract is not initializing");
        _;
    }

    function _disableInitializers() internal virtual {
        _setInitializedVersion(type(uint8).max);
    }

    function _setInitializedVersion(uint8 version) private returns (bool) {
        if (_initializing) {
            require(
                version == 1 && !Address.isContract(address(this)),
                "Initializable: contract is already initialized"
            );
            return false;
        } else {
            require(_initialized < version, "Initializable: contract is already initialized");
            _initialized = version;
            return true;
        }
    }
}// MIT

pragma solidity ^0.8.0;


interface IAccessControlEnumerable is IAccessControl {

    function getRoleMember(bytes32 role, uint256 index) external view returns (address);


    function getRoleMemberCount(bytes32 role) external view returns (uint256);

}// MIT

pragma solidity ^0.8.0;

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

            if (lastIndex != toDeleteIndex) {
                bytes32 lastValue = set._values[lastIndex];

                set._values[toDeleteIndex] = lastValue;
                set._indexes[lastValue] = valueIndex; // Replace lastValue's index to valueIndex
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


abstract contract AccessControlEnumerable is IAccessControlEnumerable, AccessControl {
    using EnumerableSet for EnumerableSet.AddressSet;

    mapping(bytes32 => EnumerableSet.AddressSet) private _roleMembers;

    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IAccessControlEnumerable).interfaceId || super.supportsInterface(interfaceId);
    }

    function getRoleMember(bytes32 role, uint256 index) public view virtual override returns (address) {
        return _roleMembers[role].at(index);
    }

    function getRoleMemberCount(bytes32 role) public view virtual override returns (uint256) {
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
}// GPL-3.0-or-later
pragma solidity ^0.8.4;


contract Permissions is IPermissions, AccessControlEnumerable {

    bytes32 public constant override BURNER_ROLE = keccak256("BURNER_ROLE");
    bytes32 public constant override MINTER_ROLE = keccak256("MINTER_ROLE");
    bytes32 public constant override PCV_CONTROLLER_ROLE = keccak256("PCV_CONTROLLER_ROLE");
    bytes32 public constant override GOVERN_ROLE = keccak256("GOVERN_ROLE");
    bytes32 public constant override GUARDIAN_ROLE = keccak256("GUARDIAN_ROLE");

    constructor() {
        _setupGovernor(address(this));

        _setRoleAdmin(MINTER_ROLE, GOVERN_ROLE);
        _setRoleAdmin(BURNER_ROLE, GOVERN_ROLE);
        _setRoleAdmin(PCV_CONTROLLER_ROLE, GOVERN_ROLE);
        _setRoleAdmin(GOVERN_ROLE, GOVERN_ROLE);
        _setRoleAdmin(GUARDIAN_ROLE, GOVERN_ROLE);
    }

    modifier onlyGovernor() {

        require(isGovernor(msg.sender), "Permissions: Caller is not a governor");
        _;
    }

    modifier onlyGuardian() {

        require(isGuardian(msg.sender), "Permissions: Caller is not a guardian");
        _;
    }

    function createRole(bytes32 role, bytes32 adminRole) external override onlyGovernor {

        _setRoleAdmin(role, adminRole);
    }

    function grantMinter(address minter) external override onlyGovernor {

        grantRole(MINTER_ROLE, minter);
    }

    function grantBurner(address burner) external override onlyGovernor {

        grantRole(BURNER_ROLE, burner);
    }

    function grantPCVController(address pcvController) external override onlyGovernor {

        grantRole(PCV_CONTROLLER_ROLE, pcvController);
    }

    function grantGovernor(address governor) external override onlyGovernor {

        grantRole(GOVERN_ROLE, governor);
    }

    function grantGuardian(address guardian) external override onlyGovernor {

        grantRole(GUARDIAN_ROLE, guardian);
    }

    function revokeMinter(address minter) external override onlyGovernor {

        revokeRole(MINTER_ROLE, minter);
    }

    function revokeBurner(address burner) external override onlyGovernor {

        revokeRole(BURNER_ROLE, burner);
    }

    function revokePCVController(address pcvController) external override onlyGovernor {

        revokeRole(PCV_CONTROLLER_ROLE, pcvController);
    }

    function revokeGovernor(address governor) external override onlyGovernor {

        revokeRole(GOVERN_ROLE, governor);
    }

    function revokeGuardian(address guardian) external override onlyGovernor {

        revokeRole(GUARDIAN_ROLE, guardian);
    }

    function revokeOverride(bytes32 role, address account) external override onlyGuardian {

        require(role != GOVERN_ROLE, "Permissions: Guardian cannot revoke governor");

        this.revokeRole(role, account);
    }

    function isMinter(address _address) external view override returns (bool) {

        return hasRole(MINTER_ROLE, _address);
    }

    function isBurner(address _address) external view override returns (bool) {

        return hasRole(BURNER_ROLE, _address);
    }

    function isPCVController(address _address) external view override returns (bool) {

        return hasRole(PCV_CONTROLLER_ROLE, _address);
    }

    function isGovernor(address _address) public view virtual override returns (bool) {

        return hasRole(GOVERN_ROLE, _address);
    }

    function isGuardian(address _address) public view override returns (bool) {

        return hasRole(GUARDIAN_ROLE, _address);
    }

    function _setupGovernor(address governor) internal {

        _setupRole(GOVERN_ROLE, governor);
    }
}// MIT

pragma solidity ^0.8.0;


interface IERC20Metadata is IERC20 {

    function name() external view returns (string memory);


    function symbol() external view returns (string memory);


    function decimals() external view returns (uint8);

}// MIT

pragma solidity ^0.8.0;


contract ERC20 is Context, IERC20, IERC20Metadata {

    mapping(address => uint256) private _balances;

    mapping(address => mapping(address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;

    constructor(string memory name_, string memory symbol_) {
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

    function transfer(address to, uint256 amount) public virtual override returns (bool) {

        address owner = _msgSender();
        _transfer(owner, to, amount);
        return true;
    }

    function allowance(address owner, address spender) public view virtual override returns (uint256) {

        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public virtual override returns (bool) {

        address owner = _msgSender();
        _approve(owner, spender, amount);
        return true;
    }

    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) public virtual override returns (bool) {

        address spender = _msgSender();
        _spendAllowance(from, spender, amount);
        _transfer(from, to, amount);
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {

        address owner = _msgSender();
        _approve(owner, spender, allowance(owner, spender) + addedValue);
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {

        address owner = _msgSender();
        uint256 currentAllowance = allowance(owner, spender);
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
        unchecked {
            _approve(owner, spender, currentAllowance - subtractedValue);
        }

        return true;
    }

    function _transfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {

        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(from, to, amount);

        uint256 fromBalance = _balances[from];
        require(fromBalance >= amount, "ERC20: transfer amount exceeds balance");
        unchecked {
            _balances[from] = fromBalance - amount;
        }
        _balances[to] += amount;

        emit Transfer(from, to, amount);

        _afterTokenTransfer(from, to, amount);
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

    function _spendAllowance(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {

        uint256 currentAllowance = allowance(owner, spender);
        if (currentAllowance != type(uint256).max) {
            require(currentAllowance >= amount, "ERC20: insufficient allowance");
            unchecked {
                _approve(owner, spender, currentAllowance - amount);
            }
        }
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

}// MIT

pragma solidity ^0.8.0;


abstract contract ERC20Burnable is Context, ERC20 {
    function burn(uint256 amount) public virtual {
        _burn(_msgSender(), amount);
    }

    function burnFrom(address account, uint256 amount) public virtual {
        _spendAllowance(account, _msgSender(), amount);
        _burn(account, amount);
    }
}// GPL-3.0-or-later
pragma solidity ^0.8.4;

interface IIncentive {

    function incentivize(
        address sender,
        address receiver,
        address operator,
        uint256 amount
    ) external;
}// GPL-3.0-or-later
pragma solidity ^0.8.4;


contract Fei is IFei, ERC20Burnable, CoreRef {
    mapping(address => address) public override incentiveContract;

    bytes32 public DOMAIN_SEPARATOR;
    bytes32 public constant PERMIT_TYPEHASH = 0x6e71edae12b1b97f4d1f60370fef10105fa2faae0126114a169c64845d6126c9;
    mapping(address => uint256) public nonces;

    constructor(address core) ERC20("Fei USD", "FEI") CoreRef(core) {
        uint256 chainId;
        assembly {
            chainId := chainid()
        }
        DOMAIN_SEPARATOR = keccak256(
            abi.encode(
                keccak256("EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)"),
                keccak256(bytes(name())),
                keccak256(bytes("1")),
                chainId,
                address(this)
            )
        );
    }

    function setIncentiveContract(address account, address incentive) external override onlyGovernor {
        incentiveContract[account] = incentive;
        emit IncentiveContractUpdate(account, incentive);
    }

    function mint(address account, uint256 amount) external override onlyMinter whenNotPaused {
        _mint(account, amount);
        emit Minting(account, msg.sender, amount);
    }

    function burn(uint256 amount) public override(IFei, ERC20Burnable) {
        super.burn(amount);
        emit Burning(msg.sender, msg.sender, amount);
    }

    function burnFrom(address account, uint256 amount) public override(IFei, ERC20Burnable) onlyBurner whenNotPaused {
        _burn(account, amount);
        emit Burning(account, msg.sender, amount);
    }

    function _transfer(
        address sender,
        address recipient,
        uint256 amount
    ) internal override {
        super._transfer(sender, recipient, amount);
        _checkAndApplyIncentives(sender, recipient, amount);
    }

    function _checkAndApplyIncentives(
        address sender,
        address recipient,
        uint256 amount
    ) internal {
        address senderIncentive = incentiveContract[sender];
        if (senderIncentive != address(0)) {
            IIncentive(senderIncentive).incentivize(sender, recipient, msg.sender, amount);
        }

        address recipientIncentive = incentiveContract[recipient];
        if (recipientIncentive != address(0)) {
            IIncentive(recipientIncentive).incentivize(sender, recipient, msg.sender, amount);
        }

        address operatorIncentive = incentiveContract[msg.sender];
        if (msg.sender != sender && msg.sender != recipient && operatorIncentive != address(0)) {
            IIncentive(operatorIncentive).incentivize(sender, recipient, msg.sender, amount);
        }

        address allIncentive = incentiveContract[address(0)];
        if (allIncentive != address(0)) {
            IIncentive(allIncentive).incentivize(sender, recipient, msg.sender, amount);
        }
    }

    function permit(
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external override {
        require(deadline >= block.timestamp, "Fei: EXPIRED");
        bytes32 digest = keccak256(
            abi.encodePacked(
                "\x19\x01",
                DOMAIN_SEPARATOR,
                keccak256(abi.encode(PERMIT_TYPEHASH, owner, spender, value, nonces[owner]++, deadline))
            )
        );
        address recoveredAddress = ecrecover(digest, v, r, s);
        require(recoveredAddress != address(0) && recoveredAddress == owner, "Fei: INVALID_SIGNATURE");
        _approve(owner, spender, value);
    }
}// GPL-3.0-or-later
pragma solidity ^0.8.4;


contract Tribe {
    string public constant name = "Tribe";

    string public constant symbol = "TRIBE";

    uint8 public constant decimals = 18;

    uint256 public totalSupply = 1_000_000_000e18; // 1 billion Tribe

    address public minter;

    mapping(address => mapping(address => uint96)) internal allowances;

    mapping(address => uint96) internal balances;

    mapping(address => address) public delegates;

    struct Checkpoint {
        uint32 fromBlock;
        uint96 votes;
    }

    mapping(address => mapping(uint32 => Checkpoint)) public checkpoints;

    mapping(address => uint32) public numCheckpoints;

    bytes32 public constant DOMAIN_TYPEHASH =
        keccak256("EIP712Domain(string name,uint256 chainId,address verifyingContract)");

    bytes32 public constant DELEGATION_TYPEHASH =
        keccak256("Delegation(address delegatee,uint256 nonce,uint256 expiry)");

    bytes32 public constant PERMIT_TYPEHASH =
        keccak256("Permit(address owner,address spender,uint256 value,uint256 nonce,uint256 deadline)");

    mapping(address => uint256) public nonces;

    event MinterChanged(address minter, address newMinter);

    event DelegateChanged(address indexed delegator, address indexed fromDelegate, address indexed toDelegate);

    event DelegateVotesChanged(address indexed delegate, uint256 previousBalance, uint256 newBalance);

    event Transfer(address indexed from, address indexed to, uint256 amount);

    event Approval(address indexed owner, address indexed spender, uint256 amount);

    constructor(address account, address minter_) {
        balances[account] = uint96(totalSupply);
        emit Transfer(address(0), account, totalSupply);
        minter = minter_;
        emit MinterChanged(address(0), minter);
    }

    function setMinter(address minter_) external {
        require(msg.sender == minter, "Tribe: only the minter can change the minter address");
        emit MinterChanged(minter, minter_);
        minter = minter_;
    }

    function mint(address dst, uint256 rawAmount) external {
        require(msg.sender == minter, "Tribe: only the minter can mint");
        require(dst != address(0), "Tribe: cannot transfer to the zero address");

        uint96 amount = safe96(rawAmount, "Tribe: amount exceeds 96 bits");
        uint96 safeSupply = safe96(totalSupply, "Tribe: totalSupply exceeds 96 bits");
        totalSupply = add96(safeSupply, amount, "Tribe: totalSupply exceeds 96 bits");

        balances[dst] = add96(balances[dst], amount, "Tribe: transfer amount overflows");
        emit Transfer(address(0), dst, amount);

        _moveDelegates(address(0), delegates[dst], amount);
    }

    function allowance(address account, address spender) external view returns (uint256) {
        return allowances[account][spender];
    }

    function approve(address spender, uint256 rawAmount) external returns (bool) {
        uint96 amount;
        if (rawAmount == type(uint256).max) {
            amount = type(uint96).max;
        } else {
            amount = safe96(rawAmount, "Tribe: amount exceeds 96 bits");
        }

        allowances[msg.sender][spender] = amount;

        emit Approval(msg.sender, spender, amount);
        return true;
    }

    function permit(
        address owner,
        address spender,
        uint256 rawAmount,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external {
        uint96 amount;
        if (rawAmount == type(uint256).max) {
            amount = type(uint96).max;
        } else {
            amount = safe96(rawAmount, "Tribe: amount exceeds 96 bits");
        }

        bytes32 domainSeparator = keccak256(
            abi.encode(DOMAIN_TYPEHASH, keccak256(bytes(name)), getChainId(), address(this))
        );
        bytes32 structHash = keccak256(
            abi.encode(PERMIT_TYPEHASH, owner, spender, rawAmount, nonces[owner]++, deadline)
        );
        bytes32 digest = keccak256(abi.encodePacked("\x19\x01", domainSeparator, structHash));
        address signatory = ecrecover(digest, v, r, s);
        require(signatory != address(0), "Tribe: invalid signature");
        require(signatory == owner, "Tribe: unauthorized");
        require(block.timestamp <= deadline, "Tribe: signature expired");

        allowances[owner][spender] = amount;

        emit Approval(owner, spender, amount);
    }

    function balanceOf(address account) external view returns (uint256) {
        return balances[account];
    }

    function transfer(address dst, uint256 rawAmount) external returns (bool) {
        uint96 amount = safe96(rawAmount, "Tribe: amount exceeds 96 bits");
        _transferTokens(msg.sender, dst, amount);
        return true;
    }

    function transferFrom(
        address src,
        address dst,
        uint256 rawAmount
    ) external returns (bool) {
        address spender = msg.sender;
        uint96 spenderAllowance = allowances[src][spender];
        uint96 amount = safe96(rawAmount, "Tribe: amount exceeds 96 bits");

        if (spender != src && spenderAllowance != type(uint96).max) {
            uint96 newAllowance = sub96(spenderAllowance, amount, "Tribe: transfer amount exceeds spender allowance");
            allowances[src][spender] = newAllowance;

            emit Approval(src, spender, newAllowance);
        }

        _transferTokens(src, dst, amount);
        return true;
    }

    function delegate(address delegatee) public {
        return _delegate(msg.sender, delegatee);
    }

    function delegateBySig(
        address delegatee,
        uint256 nonce,
        uint256 expiry,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) public {
        bytes32 domainSeparator = keccak256(
            abi.encode(DOMAIN_TYPEHASH, keccak256(bytes(name)), getChainId(), address(this))
        );
        bytes32 structHash = keccak256(abi.encode(DELEGATION_TYPEHASH, delegatee, nonce, expiry));
        bytes32 digest = keccak256(abi.encodePacked("\x19\x01", domainSeparator, structHash));
        address signatory = ecrecover(digest, v, r, s);
        require(signatory != address(0), "Tribe: invalid signature");
        require(nonce == nonces[signatory]++, "Tribe: invalid nonce");
        require(block.timestamp <= expiry, "Tribe: signature expired");
        return _delegate(signatory, delegatee);
    }

    function getCurrentVotes(address account) external view returns (uint96) {
        uint32 nCheckpoints = numCheckpoints[account];
        return nCheckpoints > 0 ? checkpoints[account][nCheckpoints - 1].votes : 0;
    }

    function getPriorVotes(address account, uint256 blockNumber) public view returns (uint96) {
        require(blockNumber < block.number, "Tribe: not yet determined");

        uint32 nCheckpoints = numCheckpoints[account];
        if (nCheckpoints == 0) {
            return 0;
        }

        if (checkpoints[account][nCheckpoints - 1].fromBlock <= blockNumber) {
            return checkpoints[account][nCheckpoints - 1].votes;
        }

        if (checkpoints[account][0].fromBlock > blockNumber) {
            return 0;
        }

        uint32 lower = 0;
        uint32 upper = nCheckpoints - 1;
        while (upper > lower) {
            uint32 center = upper - (upper - lower) / 2; // ceil, avoiding overflow
            Checkpoint memory cp = checkpoints[account][center];
            if (cp.fromBlock == blockNumber) {
                return cp.votes;
            } else if (cp.fromBlock < blockNumber) {
                lower = center;
            } else {
                upper = center - 1;
            }
        }
        return checkpoints[account][lower].votes;
    }

    function _delegate(address delegator, address delegatee) internal {
        address currentDelegate = delegates[delegator];
        uint96 delegatorBalance = balances[delegator];
        delegates[delegator] = delegatee;

        emit DelegateChanged(delegator, currentDelegate, delegatee);

        _moveDelegates(currentDelegate, delegatee, delegatorBalance);
    }

    function _transferTokens(
        address src,
        address dst,
        uint96 amount
    ) internal {
        require(src != address(0), "Tribe: cannot transfer from the zero address");
        require(dst != address(0), "Tribe: cannot transfer to the zero address");

        balances[src] = sub96(balances[src], amount, "Tribe: transfer amount exceeds balance");
        balances[dst] = add96(balances[dst], amount, "Tribe: transfer amount overflows");
        emit Transfer(src, dst, amount);

        _moveDelegates(delegates[src], delegates[dst], amount);
    }

    function _moveDelegates(
        address srcRep,
        address dstRep,
        uint96 amount
    ) internal {
        if (srcRep != dstRep && amount > 0) {
            if (srcRep != address(0)) {
                uint32 srcRepNum = numCheckpoints[srcRep];
                uint96 srcRepOld = srcRepNum > 0 ? checkpoints[srcRep][srcRepNum - 1].votes : 0;
                uint96 srcRepNew = sub96(srcRepOld, amount, "Tribe: vote amount underflows");
                _writeCheckpoint(srcRep, srcRepNum, srcRepOld, srcRepNew);
            }

            if (dstRep != address(0)) {
                uint32 dstRepNum = numCheckpoints[dstRep];
                uint96 dstRepOld = dstRepNum > 0 ? checkpoints[dstRep][dstRepNum - 1].votes : 0;
                uint96 dstRepNew = add96(dstRepOld, amount, "Tribe: vote amount overflows");
                _writeCheckpoint(dstRep, dstRepNum, dstRepOld, dstRepNew);
            }
        }
    }

    function _writeCheckpoint(
        address delegatee,
        uint32 nCheckpoints,
        uint96 oldVotes,
        uint96 newVotes
    ) internal {
        uint32 blockNumber = safe32(block.number, "Tribe: block number exceeds 32 bits");

        if (nCheckpoints > 0 && checkpoints[delegatee][nCheckpoints - 1].fromBlock == blockNumber) {
            checkpoints[delegatee][nCheckpoints - 1].votes = newVotes;
        } else {
            checkpoints[delegatee][nCheckpoints] = Checkpoint(blockNumber, newVotes);
            numCheckpoints[delegatee] = nCheckpoints + 1;
        }

        emit DelegateVotesChanged(delegatee, oldVotes, newVotes);
    }

    function safe32(uint256 n, string memory errorMessage) internal pure returns (uint32) {
        require(n < 2**32, errorMessage);
        return uint32(n);
    }

    function safe96(uint256 n, string memory errorMessage) internal pure returns (uint96) {
        require(n < 2**96, errorMessage);
        return uint96(n);
    }

    function add96(
        uint96 a,
        uint96 b,
        string memory errorMessage
    ) internal pure returns (uint96) {
        uint96 c = a + b;
        require(c >= a, errorMessage);
        return c;
    }

    function sub96(
        uint96 a,
        uint96 b,
        string memory errorMessage
    ) internal pure returns (uint96) {
        require(b <= a, errorMessage);
        return a - b;
    }

    function getChainId() internal view returns (uint256) {
        uint256 chainId;
        assembly {
            chainId := chainid()
        }
        return chainId;
    }
}// GPL-3.0-or-later
pragma solidity ^0.8.4;


contract Core is ICore, Permissions, Initializable {
    IFei public override fei;

    IERC20 public override tribe;

    function init() external override initializer {
        _setupGovernor(msg.sender);

        Fei _fei = new Fei(address(this));
        _setFei(address(_fei));

        Tribe _tribe = new Tribe(address(this), msg.sender);
        _setTribe(address(_tribe));
    }

    function setFei(address token) external override onlyGovernor {
        _setFei(token);
    }

    function setTribe(address token) external override onlyGovernor {
        _setTribe(token);
    }

    function allocateTribe(address to, uint256 amount) external override onlyGovernor {
        IERC20 _tribe = tribe;
        require(_tribe.balanceOf(address(this)) >= amount, "Core: Not enough Tribe");

        _tribe.transfer(to, amount);

        emit TribeAllocation(to, amount);
    }

    function _setFei(address token) internal {
        fei = IFei(token);
        emit FeiUpdate(token);
    }

    function _setTribe(address token) internal {
        tribe = IERC20(token);
        emit TribeUpdate(token);
    }
}// GPL-3.0-or-later
pragma solidity ^0.8.0;

interface IPodAdminGateway {
    event AddPodMember(uint256 indexed podId, address member);
    event RemovePodMember(uint256 indexed podId, address member);
    event UpdatePodAdmin(uint256 indexed podId, address oldPodAdmin, address newPodAdmin);
    event PodMembershipTransferLock(uint256 indexed podId, bool lock);

    event VetoTimelock(uint256 indexed podId, address indexed timelock, bytes32 proposalId);

    function getSpecificPodAdminRole(uint256 _podId) external pure returns (bytes32);

    function getSpecificPodGuardianRole(uint256 _podId) external pure returns (bytes32);

    function addPodMember(uint256 _podId, address _member) external;

    function batchAddPodMember(uint256 _podId, address[] calldata _members) external;

    function removePodMember(uint256 _podId, address _member) external;

    function batchRemovePodMember(uint256 _podId, address[] calldata _members) external;

    function lockMembershipTransfers(uint256 _podId) external;

    function unlockMembershipTransfers(uint256 _podId) external;

    function veto(uint256 _podId, bytes32 proposalId) external;
}// GPL-3.0-or-later
pragma solidity ^0.8.0;


contract PodAdminGateway is CoreRef, IPodAdminGateway {
    MemberToken private immutable memberToken;

    IPodFactory public immutable podFactory;

    constructor(
        address _core,
        address _memberToken,
        address _podFactory
    ) CoreRef(_core) {
        memberToken = MemberToken(_memberToken);
        podFactory = IPodFactory(_podFactory);
    }

    function getSpecificPodAdminRole(uint256 _podId) public pure override returns (bytes32) {
        return keccak256(abi.encode(_podId, "_ORCA_POD", "_ADMIN"));
    }

    function getSpecificPodGuardianRole(uint256 _podId) public pure override returns (bytes32) {
        return keccak256(abi.encode(_podId, "_ORCA_POD", "_GUARDIAN"));
    }


    function addPodMember(uint256 _podId, address _member)
        external
        override
        hasAnyOfThreeRoles(TribeRoles.GOVERNOR, TribeRoles.POD_ADMIN, getSpecificPodAdminRole(_podId))
    {
        _addMemberToPod(_podId, _member);
    }

    function _addMemberToPod(uint256 _podId, address _member) internal {
        emit AddPodMember(_podId, _member);
        memberToken.mint(_member, _podId, bytes(""));
    }

    function batchAddPodMember(uint256 _podId, address[] calldata _members)
        external
        override
        hasAnyOfThreeRoles(TribeRoles.GOVERNOR, TribeRoles.POD_ADMIN, getSpecificPodAdminRole(_podId))
    {
        uint256 numMembers = _members.length;
        for (uint256 i = 0; i < numMembers; ) {
            _addMemberToPod(_podId, _members[i]);
            unchecked {
                i += 1;
            }
        }
    }

    function removePodMember(uint256 _podId, address _member)
        external
        override
        hasAnyOfFiveRoles(
            TribeRoles.GOVERNOR,
            TribeRoles.POD_ADMIN,
            TribeRoles.GUARDIAN,
            getSpecificPodGuardianRole(_podId),
            getSpecificPodAdminRole(_podId)
        )
    {
        _removePodMember(_podId, _member);
    }

    function _removePodMember(uint256 _podId, address _member) internal {
        emit RemovePodMember(_podId, _member);
        memberToken.burn(_member, _podId);
    }

    function batchRemovePodMember(uint256 _podId, address[] calldata _members)
        external
        override
        hasAnyOfFiveRoles(
            TribeRoles.GOVERNOR,
            TribeRoles.POD_ADMIN,
            TribeRoles.GUARDIAN,
            getSpecificPodGuardianRole(_podId),
            getSpecificPodAdminRole(_podId)
        )
    {
        uint256 numMembers = _members.length;
        for (uint256 i = 0; i < numMembers; ) {
            _removePodMember(_podId, _members[i]);

            unchecked {
                i += 1;
            }
        }
    }

    function lockMembershipTransfers(uint256 _podId)
        external
        override
        hasAnyOfThreeRoles(TribeRoles.GOVERNOR, TribeRoles.POD_ADMIN, getSpecificPodAdminRole(_podId))
    {
        _setMembershipTransferLock(_podId, true);
    }

    function unlockMembershipTransfers(uint256 _podId)
        external
        override
        hasAnyOfThreeRoles(TribeRoles.GOVERNOR, TribeRoles.POD_ADMIN, getSpecificPodAdminRole(_podId))
    {
        _setMembershipTransferLock(_podId, false);
    }

    function _setMembershipTransferLock(uint256 _podId, bool _lock) internal {
        ControllerV1 podController = ControllerV1(memberToken.memberController(_podId));
        podController.setPodTransferLock(_podId, _lock);
        emit PodMembershipTransferLock(_podId, _lock);
    }

    function transferAdmin(uint256 _podId, address _newAdmin)
        external
        hasAnyOfThreeRoles(TribeRoles.GOVERNOR, TribeRoles.POD_ADMIN, getSpecificPodAdminRole(_podId))
    {
        ControllerV1 podController = ControllerV1(memberToken.memberController(_podId));
        address oldPodAdmin = podController.podAdmin(_podId);

        podController.updatePodAdmin(_podId, _newAdmin);
        emit UpdatePodAdmin(_podId, oldPodAdmin, _newAdmin);
    }


    function veto(uint256 _podId, bytes32 _proposalId)
        external
        override
        hasAnyOfSixRoles(
            TribeRoles.GOVERNOR,
            TribeRoles.POD_VETO_ADMIN,
            TribeRoles.GUARDIAN,
            TribeRoles.POD_ADMIN,
            getSpecificPodGuardianRole(_podId),
            getSpecificPodAdminRole(_podId)
        )
    {
        address _podTimelock = podFactory.getPodTimelock(_podId);
        emit VetoTimelock(_podId, _podTimelock, _proposalId);
        TimelockController(payable(_podTimelock)).cancel(_proposalId);
    }
}// GPL-3.0-or-later
pragma solidity ^0.8.4;

interface ITimelock {
    function becomeAdmin() external;

    function hasRole(bytes32 role, address account) external view returns (bool);

    function execute(
        address target,
        uint256 value,
        bytes calldata data,
        bytes32 predecessor,
        bytes32 salt
    ) external payable;
}// GPL-3.0-or-later
pragma solidity ^0.8.0;


contract PodExecutor is CoreRef {
    event ExecuteTransaction(address timelock, bytes32 dataHash);

    constructor(address _core) CoreRef(_core) {}

    function execute(
        address timelock,
        address target,
        uint256 value,
        bytes calldata data,
        bytes32 predecessor,
        bytes32 salt
    ) public payable whenNotPaused {
        bytes32 dataPayloadHash = keccak256(data);
        ITimelock(timelock).execute(target, value, data, predecessor, salt);
        emit ExecuteTransaction(timelock, dataPayloadHash);
    }

    function executeBatch(
        address[] memory timelock,
        address[] memory target,
        uint256[] memory value,
        bytes[] calldata data,
        bytes32[] memory predecessor,
        bytes32[] memory salt
    ) external payable whenNotPaused {
        for (uint256 i = 0; i < timelock.length; i += 1) {
            execute(timelock[i], target[i], value[i], data[i], predecessor[i], salt[i]);
        }
    }
}// GPL-3.0-or-later
pragma solidity ^0.8.0;



contract PodFactory is CoreRef, IPodFactory {
    MemberToken public immutable memberToken;

    PodExecutor public immutable podExecutor;

    ControllerV1 public override defaultPodController;

    mapping(uint256 => address) public override getPodTimelock;

    mapping(address => uint256) public getPodId;

    address[] private podSafeAddresses;

    bool public tribalCouncilDeployed;

    uint256 public constant MIN_TIMELOCK_DELAY = 1 days;

    constructor(
        address _core,
        address _memberToken,
        address _defaultPodController,
        address _podExecutor
    ) CoreRef(_core) {
        podExecutor = PodExecutor(_podExecutor);
        defaultPodController = ControllerV1(_defaultPodController);
        memberToken = MemberToken(_memberToken);
    }


    function getNumberOfPods() external view override returns (uint256) {
        return podSafeAddresses.length;
    }

    function getPodSafeAddresses() external view override returns (address[] memory) {
        return podSafeAddresses;
    }

    function getMemberToken() external view override returns (MemberToken) {
        return memberToken;
    }

    function getPodController(uint256 podId) external view override returns (ControllerV1) {
        return ControllerV1(memberToken.memberController(podId));
    }

    function getPodSafe(uint256 podId) public view override returns (address) {
        ControllerV1 podController = ControllerV1(memberToken.memberController(podId));
        return podController.podIdToSafe(podId);
    }

    function getNumMembers(uint256 podId) external view override returns (uint256) {
        address safe = getPodSafe(podId);
        address[] memory members = IGnosisSafe(safe).getOwners();
        return uint256(members.length);
    }

    function getPodMembers(uint256 podId) public view override returns (address[] memory) {
        ControllerV1 podController = ControllerV1(memberToken.memberController(podId));
        address safeAddress = podController.podIdToSafe(podId);
        return IGnosisSafe(safeAddress).getOwners();
    }

    function getPodThreshold(uint256 podId) external view override returns (uint256) {
        address safe = getPodSafe(podId);
        uint256 threshold = uint256(IGnosisSafe(safe).getThreshold());
        return threshold;
    }

    function getNextPodId() external view override returns (uint256) {
        return memberToken.getNextAvailablePodId();
    }

    function getPodAdmin(uint256 podId) external view override returns (address) {
        ControllerV1 podController = ControllerV1(memberToken.memberController(podId));
        return podController.podAdmin(podId);
    }

    function getIsMembershipTransferLocked(uint256 podId) external view override returns (bool) {
        ControllerV1 podController = ControllerV1(memberToken.memberController(podId));
        return podController.isTransferLocked(podId);
    }


    function deployCouncilPod(PodConfig calldata _config)
        external
        override
        returns (
            uint256,
            address,
            address
        )
    {
        require(!tribalCouncilDeployed, "Genesis pod already deployed");
        tribalCouncilDeployed = true;
        return _createOptimisticPod(_config);
    }

    function createOptimisticPod(PodConfig calldata _config)
        public
        override
        hasAnyOfTwoRoles(TribeRoles.GOVERNOR, TribeRoles.POD_ADMIN)
        returns (
            uint256,
            address,
            address
        )
    {
        (uint256 podId, address timelock, address safe) = _createOptimisticPod(_config);

        PodAdminGateway(_config.admin).lockMembershipTransfers(podId);
        return (podId, timelock, safe);
    }

    function updateDefaultPodController(address _newDefaultController)
        external
        override
        hasAnyOfTwoRoles(TribeRoles.GOVERNOR, TribeRoles.POD_ADMIN)
    {
        emit UpdateDefaultPodController(address(defaultPodController), _newDefaultController);
        defaultPodController = ControllerV1(_newDefaultController);
    }


    function _createOptimisticPod(PodConfig calldata _config)
        internal
        returns (
            uint256,
            address,
            address
        )
    {
        uint256 podId = memberToken.getNextAvailablePodId();

        address safeAddress = _createPod(
            _config.members,
            _config.threshold,
            _config.label,
            _config.ensString,
            _config.imageUrl,
            _config.admin,
            podId
        );

        address timelock;
        if (_config.minDelay != 0) {
            require(_config.minDelay >= MIN_TIMELOCK_DELAY, "Min delay too small");
            timelock = address(_createTimelock(safeAddress, _config.minDelay, address(podExecutor), _config.admin));
            getPodTimelock[podId] = timelock;
            getPodId[timelock] = podId;
        }

        podSafeAddresses.push(safeAddress);
        emit CreatePod(podId, safeAddress, timelock);
        return (podId, timelock, safeAddress);
    }

    function _createPod(
        address[] calldata _members,
        uint256 _threshold,
        bytes32 _label,
        string calldata _ensString,
        string calldata _imageUrl,
        address _admin,
        uint256 podId
    ) internal returns (address) {
        defaultPodController.createPod(_members, _threshold, _admin, _label, _ensString, podId, _imageUrl);
        return defaultPodController.podIdToSafe(podId);
    }

    function _createTimelock(
        address safeAddress,
        uint256 minDelay,
        address publicExecutor,
        address podAdmin
    ) internal returns (address) {
        address[] memory proposers = new address[](2);
        proposers[0] = safeAddress;
        proposers[1] = podAdmin;

        address[] memory executors = new address[](2);
        executors[0] = safeAddress;
        executors[1] = publicExecutor;

        TimelockController timelock = new TimelockController(minDelay, proposers, executors);

        timelock.revokeRole(timelock.PROPOSER_ROLE(), podAdmin);

        timelock.revokeRole(timelock.TIMELOCK_ADMIN_ROLE(), address(this));

        emit CreateTimelock(address(timelock));
        return address(timelock);
    }
}