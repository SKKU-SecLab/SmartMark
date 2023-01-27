pragma solidity >=0.7.0 <0.9.0;

contract Enum {

    enum Operation {Call, DelegateCall}
}// MIT

pragma solidity ^0.8.0;

interface IERC165 {

    function supportsInterface(bytes4 interfaceId) external view returns (bool);

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

}// MIT

pragma solidity ^0.8.0;

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


}pragma solidity 0.8.7;

interface IGnosisSafe {


    enum Operation {Call, DelegateCall}

    function execTransactionFromModule(
        address to,
        uint256 value,
        bytes calldata data,
        Operation operation
    ) external returns (bool success);


    function getOwners() external view returns (address[] memory);


    function isOwner(address owner) external view returns (bool);


    function getThreshold() external returns (uint256);


    function getModulesPaginated(address start, uint256 pageSize)
        external 
        view
        returns (address[] memory array, address next);


    function isModuleEnabled(address module) external view returns (bool);


    function setGuard(address guard) external;

}pragma solidity 0.8.7;

interface IGnosisSafeProxyFactory {

    function createProxy(address singleton, bytes memory data)
        external
        returns (address);

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
}