pragma solidity 0.4.24;


contract ExecutionTarget {

    uint256 public counter;

    function execute() public {

        counter += 1;
        emit Executed(counter);
    }

    function setCounter(uint256 x) public {

        counter = x;
    }

    event Executed(uint256 x);
}/*
 *    MIT
 */

pragma solidity ^0.4.24;


library UnstructuredStorage {

    function getStorageBool(bytes32 position) internal view returns (bool data) {

        assembly { data := sload(position) }
    }

    function getStorageAddress(bytes32 position) internal view returns (address data) {

        assembly { data := sload(position) }
    }

    function getStorageBytes32(bytes32 position) internal view returns (bytes32 data) {

        assembly { data := sload(position) }
    }

    function getStorageUint256(bytes32 position) internal view returns (uint256 data) {

        assembly { data := sload(position) }
    }

    function setStorageBool(bytes32 position, bool data) internal {

        assembly { sstore(position, data) }
    }

    function setStorageAddress(bytes32 position, address data) internal {

        assembly { sstore(position, data) }
    }

    function setStorageBytes32(bytes32 position, bytes32 data) internal {

        assembly { sstore(position, data) }
    }

    function setStorageUint256(bytes32 position, uint256 data) internal {

        assembly { sstore(position, data) }
    }
}/*
 *    MIT
 */

pragma solidity ^0.4.24;


interface IACL {

    function initialize(address permissionsCreator) external;


    function hasPermission(address who, address where, bytes32 what, bytes how) public view returns (bool);

}/*
 *    MIT
 */

pragma solidity ^0.4.24;


interface IVaultRecoverable {

    event RecoverToVault(address indexed vault, address indexed token, uint256 amount);

    function transferToVault(address token) external;


    function allowRecoverability(address token) external view returns (bool);

    function getRecoveryVault() external view returns (address);

}/*
 *    MIT
 */

pragma solidity ^0.4.24;



interface IKernelEvents {

    event SetApp(bytes32 indexed namespace, bytes32 indexed appId, address app);
}


contract IKernel is IKernelEvents, IVaultRecoverable {

    function acl() public view returns (IACL);

    function hasPermission(address who, address where, bytes32 what, bytes how) public view returns (bool);


    function setApp(bytes32 namespace, bytes32 appId, address app) public;

    function getApp(bytes32 namespace, bytes32 appId) public view returns (address);

}/*
 *    MIT
 */

pragma solidity ^0.4.24;



contract AppStorage {

    using UnstructuredStorage for bytes32;

    bytes32 internal constant KERNEL_POSITION = 0x4172f0f7d2289153072b0a6ca36959e0cbe2efc3afe50fc81636caa96338137b;
    bytes32 internal constant APP_ID_POSITION = 0xd625496217aa6a3453eecb9c3489dc5a53e6c67b444329ea2b2cbc9ff547639b;

    function kernel() public view returns (IKernel) {

        return IKernel(KERNEL_POSITION.getStorageAddress());
    }

    function appId() public view returns (bytes32) {

        return APP_ID_POSITION.getStorageBytes32();
    }

    function setKernel(IKernel _kernel) internal {

        KERNEL_POSITION.setStorageAddress(address(_kernel));
    }

    function setAppId(bytes32 _appId) internal {

        APP_ID_POSITION.setStorageBytes32(_appId);
    }
}/*
 *    MIT
 */

pragma solidity ^0.4.24;


contract ACLSyntaxSugar {

    function arr() internal pure returns (uint256[]) {

        return new uint256[](0);
    }

    function arr(bytes32 _a) internal pure returns (uint256[] r) {

        return arr(uint256(_a));
    }

    function arr(bytes32 _a, bytes32 _b) internal pure returns (uint256[] r) {

        return arr(uint256(_a), uint256(_b));
    }

    function arr(address _a) internal pure returns (uint256[] r) {

        return arr(uint256(_a));
    }

    function arr(address _a, address _b) internal pure returns (uint256[] r) {

        return arr(uint256(_a), uint256(_b));
    }

    function arr(address _a, uint256 _b, uint256 _c) internal pure returns (uint256[] r) {

        return arr(uint256(_a), _b, _c);
    }

    function arr(address _a, uint256 _b, uint256 _c, uint256 _d) internal pure returns (uint256[] r) {

        return arr(uint256(_a), _b, _c, _d);
    }

    function arr(address _a, uint256 _b) internal pure returns (uint256[] r) {

        return arr(uint256(_a), uint256(_b));
    }

    function arr(address _a, address _b, uint256 _c, uint256 _d, uint256 _e) internal pure returns (uint256[] r) {

        return arr(uint256(_a), uint256(_b), _c, _d, _e);
    }

    function arr(address _a, address _b, address _c) internal pure returns (uint256[] r) {

        return arr(uint256(_a), uint256(_b), uint256(_c));
    }

    function arr(address _a, address _b, uint256 _c) internal pure returns (uint256[] r) {

        return arr(uint256(_a), uint256(_b), uint256(_c));
    }

    function arr(uint256 _a) internal pure returns (uint256[] r) {

        r = new uint256[](1);
        r[0] = _a;
    }

    function arr(uint256 _a, uint256 _b) internal pure returns (uint256[] r) {

        r = new uint256[](2);
        r[0] = _a;
        r[1] = _b;
    }

    function arr(uint256 _a, uint256 _b, uint256 _c) internal pure returns (uint256[] r) {

        r = new uint256[](3);
        r[0] = _a;
        r[1] = _b;
        r[2] = _c;
    }

    function arr(uint256 _a, uint256 _b, uint256 _c, uint256 _d) internal pure returns (uint256[] r) {

        r = new uint256[](4);
        r[0] = _a;
        r[1] = _b;
        r[2] = _c;
        r[3] = _d;
    }

    function arr(uint256 _a, uint256 _b, uint256 _c, uint256 _d, uint256 _e) internal pure returns (uint256[] r) {

        r = new uint256[](5);
        r[0] = _a;
        r[1] = _b;
        r[2] = _c;
        r[3] = _d;
        r[4] = _e;
    }
}


contract ACLHelpers {

    function decodeParamOp(uint256 _x) internal pure returns (uint8 b) {

        return uint8(_x >> (8 * 30));
    }

    function decodeParamId(uint256 _x) internal pure returns (uint8 b) {

        return uint8(_x >> (8 * 31));
    }

    function decodeParamsList(uint256 _x) internal pure returns (uint32 a, uint32 b, uint32 c) {

        a = uint32(_x);
        b = uint32(_x >> (8 * 4));
        c = uint32(_x >> (8 * 8));
    }
}pragma solidity ^0.4.24;


library Uint256Helpers {

    uint256 private constant MAX_UINT64 = uint64(-1);

    string private constant ERROR_NUMBER_TOO_BIG = "UINT64_NUMBER_TOO_BIG";

    function toUint64(uint256 a) internal pure returns (uint64) {

        require(a <= MAX_UINT64, ERROR_NUMBER_TOO_BIG);
        return uint64(a);
    }
}/*
 *    MIT
 */

pragma solidity ^0.4.24;



contract TimeHelpers {

    using Uint256Helpers for uint256;

    function getBlockNumber() internal view returns (uint256) {

        return block.number;
    }

    function getBlockNumber64() internal view returns (uint64) {

        return getBlockNumber().toUint64();
    }

    function getTimestamp() internal view returns (uint256) {

        return block.timestamp; // solium-disable-line security/no-block-members
    }

    function getTimestamp64() internal view returns (uint64) {

        return getTimestamp().toUint64();
    }
}/*
 *    MIT
 */

pragma solidity ^0.4.24;



contract Initializable is TimeHelpers {

    using UnstructuredStorage for bytes32;

    bytes32 internal constant INITIALIZATION_BLOCK_POSITION = 0xebb05b386a8d34882b8711d156f463690983dc47815980fb82aeeff1aa43579e;

    string private constant ERROR_ALREADY_INITIALIZED = "INIT_ALREADY_INITIALIZED";
    string private constant ERROR_NOT_INITIALIZED = "INIT_NOT_INITIALIZED";

    modifier onlyInit {

        require(getInitializationBlock() == 0, ERROR_ALREADY_INITIALIZED);
        _;
    }

    modifier isInitialized {

        require(hasInitialized(), ERROR_NOT_INITIALIZED);
        _;
    }

    function getInitializationBlock() public view returns (uint256) {

        return INITIALIZATION_BLOCK_POSITION.getStorageUint256();
    }

    function hasInitialized() public view returns (bool) {

        uint256 initializationBlock = getInitializationBlock();
        return initializationBlock != 0 && getBlockNumber() >= initializationBlock;
    }

    function initialized() internal onlyInit {

        INITIALIZATION_BLOCK_POSITION.setStorageUint256(getBlockNumber());
    }

    function initializedAt(uint256 _blockNumber) internal onlyInit {

        INITIALIZATION_BLOCK_POSITION.setStorageUint256(_blockNumber);
    }
}/*
 *    MIT
 */

pragma solidity ^0.4.24;



contract Petrifiable is Initializable {

    uint256 internal constant PETRIFIED_BLOCK = uint256(-1);

    function isPetrified() public view returns (bool) {

        return getInitializationBlock() == PETRIFIED_BLOCK;
    }

    function petrify() internal onlyInit {

        initializedAt(PETRIFIED_BLOCK);
    }
}/*
 *    MIT
 */

pragma solidity ^0.4.24;



contract Autopetrified is Petrifiable {

    constructor() public {
        petrify();
    }
}pragma solidity ^0.4.24;


library ConversionHelpers {

    string private constant ERROR_IMPROPER_LENGTH = "CONVERSION_IMPROPER_LENGTH";

    function dangerouslyCastUintArrayToBytes(uint256[] memory _input) internal pure returns (bytes memory output) {

        uint256 byteLength = _input.length * 32;
        assembly {
            output := _input
            mstore(output, byteLength)
        }
    }

    function dangerouslyCastBytesToUintArray(bytes memory _input) internal pure returns (uint256[] memory output) {

        uint256 intsLength = _input.length / 32;
        require(_input.length == intsLength * 32, ERROR_IMPROPER_LENGTH);

        assembly {
            output := _input
            mstore(output, intsLength)
        }
    }
}/*
 *    MIT
 */

pragma solidity ^0.4.24;



contract ReentrancyGuard {

    using UnstructuredStorage for bytes32;

    bytes32 private constant REENTRANCY_MUTEX_POSITION = 0xe855346402235fdd185c890e68d2c4ecad599b88587635ee285bce2fda58dacb;

    string private constant ERROR_REENTRANT = "REENTRANCY_REENTRANT_CALL";

    modifier nonReentrant() {

        require(!REENTRANCY_MUTEX_POSITION.getStorageBool(), ERROR_REENTRANT);

        REENTRANCY_MUTEX_POSITION.setStorageBool(true);

        _;

        REENTRANCY_MUTEX_POSITION.setStorageBool(false);
    }
}// See https://github.com/OpenZeppelin/openzeppelin-solidity/blob/a9f910d34f0ab33a1ae5e714f69f9596a02b4d91/contracts/token/ERC20/ERC20.sol

pragma solidity ^0.4.24;


contract ERC20 {

    function totalSupply() public view returns (uint256);


    function balanceOf(address _who) public view returns (uint256);


    function allowance(address _owner, address _spender)
        public view returns (uint256);


    function transfer(address _to, uint256 _value) public returns (bool);


    function approve(address _spender, uint256 _value)
        public returns (bool);


    function transferFrom(address _from, address _to, uint256 _value)
        public returns (bool);


    event Transfer(
        address indexed from,
        address indexed to,
        uint256 value
    );

    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
}/*
 *    MIT
 */

pragma solidity ^0.4.24;


contract EtherTokenConstant {

    address internal constant ETH = address(0);
}/*
 *    MIT
 */

pragma solidity ^0.4.24;


contract IsContract {

    function isContract(address _target) internal view returns (bool) {

        if (_target == address(0)) {
            return false;
        }

        uint256 size;
        assembly { size := extcodesize(_target) }
        return size > 0;
    }
}// Inspired by AdEx (https://github.com/AdExNetwork/adex-protocol-eth/blob/b9df617829661a7518ee10f4cb6c4108659dd6d5/contracts/libs/SafeERC20.sol)

pragma solidity ^0.4.24;



library SafeERC20 {

    bytes4 private constant TRANSFER_SELECTOR = 0xa9059cbb;

    string private constant ERROR_TOKEN_BALANCE_REVERTED = "SAFE_ERC_20_BALANCE_REVERTED";
    string private constant ERROR_TOKEN_ALLOWANCE_REVERTED = "SAFE_ERC_20_ALLOWANCE_REVERTED";

    function invokeAndCheckSuccess(address _addr, bytes memory _calldata)
        private
        returns (bool)
    {

        bool ret;
        assembly {
            let ptr := mload(0x40)    // free memory pointer

            let success := call(
                gas,                  // forward all gas
                _addr,                // address
                0,                    // no value
                add(_calldata, 0x20), // calldata start
                mload(_calldata),     // calldata length
                ptr,                  // write output over free memory
                0x20                  // uint256 return
            )

            if gt(success, 0) {
                switch returndatasize

                case 0 {
                    ret := 1
                }

                case 0x20 {
                    ret := eq(mload(ptr), 1)
                }

                default { }
            }
        }
        return ret;
    }

    function staticInvoke(address _addr, bytes memory _calldata)
        private
        view
        returns (bool, uint256)
    {

        bool success;
        uint256 ret;
        assembly {
            let ptr := mload(0x40)    // free memory pointer

            success := staticcall(
                gas,                  // forward all gas
                _addr,                // address
                add(_calldata, 0x20), // calldata start
                mload(_calldata),     // calldata length
                ptr,                  // write output over free memory
                0x20                  // uint256 return
            )

            if gt(success, 0) {
                ret := mload(ptr)
            }
        }
        return (success, ret);
    }

    function safeTransfer(ERC20 _token, address _to, uint256 _amount) internal returns (bool) {

        bytes memory transferCallData = abi.encodeWithSelector(
            TRANSFER_SELECTOR,
            _to,
            _amount
        );
        return invokeAndCheckSuccess(_token, transferCallData);
    }

    function safeTransferFrom(ERC20 _token, address _from, address _to, uint256 _amount) internal returns (bool) {

        bytes memory transferFromCallData = abi.encodeWithSelector(
            _token.transferFrom.selector,
            _from,
            _to,
            _amount
        );
        return invokeAndCheckSuccess(_token, transferFromCallData);
    }

    function safeApprove(ERC20 _token, address _spender, uint256 _amount) internal returns (bool) {

        bytes memory approveCallData = abi.encodeWithSelector(
            _token.approve.selector,
            _spender,
            _amount
        );
        return invokeAndCheckSuccess(_token, approveCallData);
    }

    function staticBalanceOf(ERC20 _token, address _owner) internal view returns (uint256) {

        bytes memory balanceOfCallData = abi.encodeWithSelector(
            _token.balanceOf.selector,
            _owner
        );

        (bool success, uint256 tokenBalance) = staticInvoke(_token, balanceOfCallData);
        require(success, ERROR_TOKEN_BALANCE_REVERTED);

        return tokenBalance;
    }

    function staticAllowance(ERC20 _token, address _owner, address _spender) internal view returns (uint256) {

        bytes memory allowanceCallData = abi.encodeWithSelector(
            _token.allowance.selector,
            _owner,
            _spender
        );

        (bool success, uint256 allowance) = staticInvoke(_token, allowanceCallData);
        require(success, ERROR_TOKEN_ALLOWANCE_REVERTED);

        return allowance;
    }

    function staticTotalSupply(ERC20 _token) internal view returns (uint256) {

        bytes memory totalSupplyCallData = abi.encodeWithSelector(_token.totalSupply.selector);

        (bool success, uint256 totalSupply) = staticInvoke(_token, totalSupplyCallData);
        require(success, ERROR_TOKEN_ALLOWANCE_REVERTED);

        return totalSupply;
    }
}/*
 *    MIT
 */

pragma solidity ^0.4.24;



contract VaultRecoverable is IVaultRecoverable, EtherTokenConstant, IsContract {

    using SafeERC20 for ERC20;

    string private constant ERROR_DISALLOWED = "RECOVER_DISALLOWED";
    string private constant ERROR_VAULT_NOT_CONTRACT = "RECOVER_VAULT_NOT_CONTRACT";
    string private constant ERROR_TOKEN_TRANSFER_FAILED = "RECOVER_TOKEN_TRANSFER_FAILED";

    function transferToVault(address _token) external {

        require(allowRecoverability(_token), ERROR_DISALLOWED);
        address vault = getRecoveryVault();
        require(isContract(vault), ERROR_VAULT_NOT_CONTRACT);

        uint256 balance;
        if (_token == ETH) {
            balance = address(this).balance;
            vault.transfer(balance);
        } else {
            ERC20 token = ERC20(_token);
            balance = token.staticBalanceOf(this);
            require(token.safeTransfer(vault, balance), ERROR_TOKEN_TRANSFER_FAILED);
        }

        emit RecoverToVault(vault, _token, balance);
    }

    function allowRecoverability(address token) public view returns (bool) {

        return true;
    }

    function getRecoveryVault() public view returns (address);

}/*
 *    MIT
 */

pragma solidity ^0.4.24;


interface IEVMScriptExecutor {

    function execScript(bytes script, bytes input, address[] blacklist) external returns (bytes);

    function executorType() external pure returns (bytes32);

}/*
 *    MIT
 */

pragma solidity ^0.4.24;



contract EVMScriptRegistryConstants {

    bytes32 internal constant EVMSCRIPT_REGISTRY_APP_ID = 0xddbcfd564f642ab5627cf68b9b7d374fb4f8a36e941a75d89c87998cef03bd61;
}


interface IEVMScriptRegistry {

    function addScriptExecutor(IEVMScriptExecutor executor) external returns (uint id);

    function disableScriptExecutor(uint256 executorId) external;


    function getScriptExecutor(bytes script) public view returns (IEVMScriptExecutor);

}/*
 *    MIT
 */

pragma solidity ^0.4.24;


contract KernelAppIds {

    bytes32 internal constant KERNEL_CORE_APP_ID = 0x3b4bf6bf3ad5000ecf0f989d5befde585c6860fea3e574a4fab4c49d1c177d9c;
    bytes32 internal constant KERNEL_DEFAULT_ACL_APP_ID = 0xe3262375f45a6e2026b7e7b18c2b807434f2508fe1a2a3dfb493c7df8f4aad6a;
    bytes32 internal constant KERNEL_DEFAULT_VAULT_APP_ID = 0x7e852e0fcfce6551c13800f1e7476f982525c2b5277ba14b24339c68416336d1;
}


contract KernelNamespaceConstants {

    bytes32 internal constant KERNEL_CORE_NAMESPACE = 0xc681a85306374a5ab27f0bbc385296a54bcd314a1948b6cf61c4ea1bc44bb9f8;
    bytes32 internal constant KERNEL_APP_BASES_NAMESPACE = 0xf1f3eb40f5bc1ad1344716ced8b8a0431d840b5783aea1fd01786bc26f35ac0f;
    bytes32 internal constant KERNEL_APP_ADDR_NAMESPACE = 0xd6f028ca0e8edb4a8c9757ca4fdccab25fa1e0317da1188108f7d2dee14902fb;
}/*
 *    MIT
 */

pragma solidity ^0.4.24;




contract EVMScriptRunner is AppStorage, Initializable, EVMScriptRegistryConstants, KernelNamespaceConstants {

    string private constant ERROR_EXECUTOR_UNAVAILABLE = "EVMRUN_EXECUTOR_UNAVAILABLE";
    string private constant ERROR_PROTECTED_STATE_MODIFIED = "EVMRUN_PROTECTED_STATE_MODIFIED";


    event ScriptResult(address indexed executor, bytes script, bytes input, bytes returnData);

    function getEVMScriptExecutor(bytes _script) public view returns (IEVMScriptExecutor) {

        return IEVMScriptExecutor(getEVMScriptRegistry().getScriptExecutor(_script));
    }

    function getEVMScriptRegistry() public view returns (IEVMScriptRegistry) {

        address registryAddr = kernel().getApp(KERNEL_APP_ADDR_NAMESPACE, EVMSCRIPT_REGISTRY_APP_ID);
        return IEVMScriptRegistry(registryAddr);
    }

    function runScript(bytes _script, bytes _input, address[] _blacklist)
        internal
        isInitialized
        protectState
        returns (bytes)
    {

        IEVMScriptExecutor executor = getEVMScriptExecutor(_script);
        require(address(executor) != address(0), ERROR_EXECUTOR_UNAVAILABLE);

        bytes4 sig = executor.execScript.selector;
        bytes memory data = abi.encodeWithSelector(sig, _script, _input, _blacklist);

        bytes memory output;
        assembly {
            let success := delegatecall(
                gas,                // forward all gas
                executor,           // address
                add(data, 0x20),    // calldata start
                mload(data),        // calldata length
                0,                  // don't write output (we'll handle this ourselves)
                0                   // don't write output
            )

            output := mload(0x40) // free mem ptr get

            switch success
            case 0 {
                returndatacopy(output, 0, returndatasize)
                revert(output, returndatasize)
            }
            default {
                switch gt(returndatasize, 0x3f)
                case 0 {
                    mstore(output, 0x08c379a000000000000000000000000000000000000000000000000000000000)         // error identifier
                    mstore(add(output, 0x04), 0x0000000000000000000000000000000000000000000000000000000000000020) // starting offset
                    mstore(add(output, 0x24), 0x000000000000000000000000000000000000000000000000000000000000001e) // reason length
                    mstore(add(output, 0x44), 0x45564d52554e5f4558454355544f525f494e56414c49445f52455455524e0000) // reason

                    revert(output, 100) // 100 = 4 + 3 * 32 (error identifier + 3 words for the ABI encoded error)
                }
                default {
                    let copysize := sub(returndatasize, 0x20)
                    returndatacopy(output, 0x20, copysize)

                    mstore(0x40, add(output, copysize)) // free mem ptr set
                }
            }
        }

        emit ScriptResult(address(executor), _script, _input, output);

        return output;
    }

    modifier protectState {

        address preKernel = address(kernel());
        bytes32 preAppId = appId();
        _; // exec
        require(address(kernel()) == preKernel, ERROR_PROTECTED_STATE_MODIFIED);
        require(appId() == preAppId, ERROR_PROTECTED_STATE_MODIFIED);
    }
}/*
 *    MIT
 */

pragma solidity ^0.4.24;



contract AragonApp is AppStorage, Autopetrified, VaultRecoverable, ReentrancyGuard, EVMScriptRunner, ACLSyntaxSugar {

    string private constant ERROR_AUTH_FAILED = "APP_AUTH_FAILED";

    modifier auth(bytes32 _role) {

        require(canPerform(msg.sender, _role, new uint256[](0)), ERROR_AUTH_FAILED);
        _;
    }

    modifier authP(bytes32 _role, uint256[] _params) {

        require(canPerform(msg.sender, _role, _params), ERROR_AUTH_FAILED);
        _;
    }

    function canPerform(address _sender, bytes32 _role, uint256[] _params) public view returns (bool) {

        if (!hasInitialized()) {
            return false;
        }

        IKernel linkedKernel = kernel();
        if (address(linkedKernel) == address(0)) {
            return false;
        }

        return linkedKernel.hasPermission(
            _sender,
            address(this),
            _role,
            ConversionHelpers.dangerouslyCastUintArrayToBytes(_params)
        );
    }

    function getRecoveryVault() public view returns (address) {

        return kernel().getRecoveryVault(); // if kernel is not set, it will revert
    }
}/*
 *    MIT
 */

pragma solidity ^0.4.24;


interface IACLOracle {

    function canPerform(address who, address where, bytes32 what, uint256[] how) external view returns (bool);

}pragma solidity 0.4.24;



contract ACL is IACL, TimeHelpers, AragonApp, ACLHelpers {

    bytes32 public constant CREATE_PERMISSIONS_ROLE = 0x0b719b33c83b8e5d300c521cb8b54ae9bd933996a14bef8c2f4e0285d2d2400a;

    enum Op { NONE, EQ, NEQ, GT, LT, GTE, LTE, RET, NOT, AND, OR, XOR, IF_ELSE } // op types

    struct Param {
        uint8 id;
        uint8 op;
        uint240 value; // even though value is an uint240 it can store addresses
    }

    uint8 internal constant BLOCK_NUMBER_PARAM_ID = 200;
    uint8 internal constant TIMESTAMP_PARAM_ID    = 201;
    uint8 internal constant ORACLE_PARAM_ID       = 203;
    uint8 internal constant LOGIC_OP_PARAM_ID     = 204;
    uint8 internal constant PARAM_VALUE_PARAM_ID  = 205;

    bytes32 public constant EMPTY_PARAM_HASH = 0x290decd9548b62a8d60345a988386fc84ba6bc95484008f6362f93160ef3e563;
    bytes32 public constant NO_PERMISSION = bytes32(0);
    address public constant ANY_ENTITY = address(-1);
    address public constant BURN_ENTITY = address(1); // address(0) is already used as "no permission manager"

    string private constant ERROR_AUTH_INIT_KERNEL = "ACL_AUTH_INIT_KERNEL";
    string private constant ERROR_AUTH_NO_MANAGER = "ACL_AUTH_NO_MANAGER";
    string private constant ERROR_EXISTENT_MANAGER = "ACL_EXISTENT_MANAGER";

    mapping (bytes32 => bytes32) internal permissions; // permissions hash => params hash
    mapping (bytes32 => Param[]) internal permissionParams; // params hash => params

    mapping (bytes32 => address) internal permissionManager;

    event SetPermission(address indexed entity, address indexed app, bytes32 indexed role, bool allowed);
    event SetPermissionParams(address indexed entity, address indexed app, bytes32 indexed role, bytes32 paramsHash);
    event ChangePermissionManager(address indexed app, bytes32 indexed role, address indexed manager);

    modifier onlyPermissionManager(address _app, bytes32 _role) {

        require(msg.sender == getPermissionManager(_app, _role), ERROR_AUTH_NO_MANAGER);
        _;
    }

    modifier noPermissionManager(address _app, bytes32 _role) {

        require(getPermissionManager(_app, _role) == address(0), ERROR_EXISTENT_MANAGER);
        _;
    }

    function initialize(address _permissionsCreator) public onlyInit {

        initialized();
        require(msg.sender == address(kernel()), ERROR_AUTH_INIT_KERNEL);

        _createPermission(_permissionsCreator, this, CREATE_PERMISSIONS_ROLE, _permissionsCreator);
    }

    function createPermission(address _entity, address _app, bytes32 _role, address _manager)
        external
        auth(CREATE_PERMISSIONS_ROLE)
        noPermissionManager(_app, _role)
    {

        _createPermission(_entity, _app, _role, _manager);
    }

    function grantPermission(address _entity, address _app, bytes32 _role)
        external
    {

        grantPermissionP(_entity, _app, _role, new uint256[](0));
    }

    function grantPermissionP(address _entity, address _app, bytes32 _role, uint256[] _params)
        public
        onlyPermissionManager(_app, _role)
    {

        bytes32 paramsHash = _params.length > 0 ? _saveParams(_params) : EMPTY_PARAM_HASH;
        _setPermission(_entity, _app, _role, paramsHash);
    }

    function revokePermission(address _entity, address _app, bytes32 _role)
        external
        onlyPermissionManager(_app, _role)
    {

        _setPermission(_entity, _app, _role, NO_PERMISSION);
    }

    function setPermissionManager(address _newManager, address _app, bytes32 _role)
        external
        onlyPermissionManager(_app, _role)
    {

        _setPermissionManager(_newManager, _app, _role);
    }

    function removePermissionManager(address _app, bytes32 _role)
        external
        onlyPermissionManager(_app, _role)
    {

        _setPermissionManager(address(0), _app, _role);
    }

    function createBurnedPermission(address _app, bytes32 _role)
        external
        auth(CREATE_PERMISSIONS_ROLE)
        noPermissionManager(_app, _role)
    {

        _setPermissionManager(BURN_ENTITY, _app, _role);
    }

    function burnPermissionManager(address _app, bytes32 _role)
        external
        onlyPermissionManager(_app, _role)
    {

        _setPermissionManager(BURN_ENTITY, _app, _role);
    }

    function getPermissionParamsLength(address _entity, address _app, bytes32 _role) external view returns (uint) {

        return permissionParams[permissions[permissionHash(_entity, _app, _role)]].length;
    }

    function getPermissionParam(address _entity, address _app, bytes32 _role, uint _index)
        external
        view
        returns (uint8, uint8, uint240)
    {

        Param storage param = permissionParams[permissions[permissionHash(_entity, _app, _role)]][_index];
        return (param.id, param.op, param.value);
    }

    function getPermissionManager(address _app, bytes32 _role) public view returns (address) {

        return permissionManager[roleHash(_app, _role)];
    }

    function hasPermission(address _who, address _where, bytes32 _what, bytes memory _how) public view returns (bool) {

        return hasPermission(_who, _where, _what, ConversionHelpers.dangerouslyCastBytesToUintArray(_how));
    }

    function hasPermission(address _who, address _where, bytes32 _what, uint256[] memory _how) public view returns (bool) {

        bytes32 whoParams = permissions[permissionHash(_who, _where, _what)];
        if (whoParams != NO_PERMISSION && evalParams(whoParams, _who, _where, _what, _how)) {
            return true;
        }

        bytes32 anyParams = permissions[permissionHash(ANY_ENTITY, _where, _what)];
        if (anyParams != NO_PERMISSION && evalParams(anyParams, ANY_ENTITY, _where, _what, _how)) {
            return true;
        }

        return false;
    }

    function hasPermission(address _who, address _where, bytes32 _what) public view returns (bool) {

        uint256[] memory empty = new uint256[](0);
        return hasPermission(_who, _where, _what, empty);
    }

    function evalParams(
        bytes32 _paramsHash,
        address _who,
        address _where,
        bytes32 _what,
        uint256[] _how
    ) public view returns (bool)
    {

        if (_paramsHash == EMPTY_PARAM_HASH) {
            return true;
        }

        return _evalParam(_paramsHash, 0, _who, _where, _what, _how);
    }

    function _createPermission(address _entity, address _app, bytes32 _role, address _manager) internal {

        _setPermission(_entity, _app, _role, EMPTY_PARAM_HASH);
        _setPermissionManager(_manager, _app, _role);
    }

    function _setPermission(address _entity, address _app, bytes32 _role, bytes32 _paramsHash) internal {

        permissions[permissionHash(_entity, _app, _role)] = _paramsHash;
        bool entityHasPermission = _paramsHash != NO_PERMISSION;
        bool permissionHasParams = entityHasPermission && _paramsHash != EMPTY_PARAM_HASH;

        emit SetPermission(_entity, _app, _role, entityHasPermission);
        if (permissionHasParams) {
            emit SetPermissionParams(_entity, _app, _role, _paramsHash);
        }
    }

    function _saveParams(uint256[] _encodedParams) internal returns (bytes32) {

        bytes32 paramHash = keccak256(abi.encodePacked(_encodedParams));
        Param[] storage params = permissionParams[paramHash];

        if (params.length == 0) { // params not saved before
            for (uint256 i = 0; i < _encodedParams.length; i++) {
                uint256 encodedParam = _encodedParams[i];
                Param memory param = Param(decodeParamId(encodedParam), decodeParamOp(encodedParam), uint240(encodedParam));
                params.push(param);
            }
        }

        return paramHash;
    }

    function _evalParam(
        bytes32 _paramsHash,
        uint32 _paramId,
        address _who,
        address _where,
        bytes32 _what,
        uint256[] _how
    ) internal view returns (bool)
    {

        if (_paramId >= permissionParams[_paramsHash].length) {
            return false; // out of bounds
        }

        Param memory param = permissionParams[_paramsHash][_paramId];

        if (param.id == LOGIC_OP_PARAM_ID) {
            return _evalLogic(param, _paramsHash, _who, _where, _what, _how);
        }

        uint256 value;
        uint256 comparedTo = uint256(param.value);

        if (param.id == ORACLE_PARAM_ID) {
            value = checkOracle(IACLOracle(param.value), _who, _where, _what, _how) ? 1 : 0;
            comparedTo = 1;
        } else if (param.id == BLOCK_NUMBER_PARAM_ID) {
            value = getBlockNumber();
        } else if (param.id == TIMESTAMP_PARAM_ID) {
            value = getTimestamp();
        } else if (param.id == PARAM_VALUE_PARAM_ID) {
            value = uint256(param.value);
        } else {
            if (param.id >= _how.length) {
                return false;
            }
            value = uint256(uint240(_how[param.id])); // force lost precision
        }

        if (Op(param.op) == Op.RET) {
            return uint256(value) > 0;
        }

        return compare(value, Op(param.op), comparedTo);
    }

    function _evalLogic(Param _param, bytes32 _paramsHash, address _who, address _where, bytes32 _what, uint256[] _how)
        internal
        view
        returns (bool)
    {

        if (Op(_param.op) == Op.IF_ELSE) {
            uint32 conditionParam;
            uint32 successParam;
            uint32 failureParam;

            (conditionParam, successParam, failureParam) = decodeParamsList(uint256(_param.value));
            bool result = _evalParam(_paramsHash, conditionParam, _who, _where, _what, _how);

            return _evalParam(_paramsHash, result ? successParam : failureParam, _who, _where, _what, _how);
        }

        uint32 param1;
        uint32 param2;

        (param1, param2,) = decodeParamsList(uint256(_param.value));
        bool r1 = _evalParam(_paramsHash, param1, _who, _where, _what, _how);

        if (Op(_param.op) == Op.NOT) {
            return !r1;
        }

        if (r1 && Op(_param.op) == Op.OR) {
            return true;
        }

        if (!r1 && Op(_param.op) == Op.AND) {
            return false;
        }

        bool r2 = _evalParam(_paramsHash, param2, _who, _where, _what, _how);

        if (Op(_param.op) == Op.XOR) {
            return r1 != r2;
        }

        return r2; // both or and and depend on result of r2 after checks
    }

    function compare(uint256 _a, Op _op, uint256 _b) internal pure returns (bool) {

        if (_op == Op.EQ)  return _a == _b;                              // solium-disable-line lbrace
        if (_op == Op.NEQ) return _a != _b;                              // solium-disable-line lbrace
        if (_op == Op.GT)  return _a > _b;                               // solium-disable-line lbrace
        if (_op == Op.LT)  return _a < _b;                               // solium-disable-line lbrace
        if (_op == Op.GTE) return _a >= _b;                              // solium-disable-line lbrace
        if (_op == Op.LTE) return _a <= _b;                              // solium-disable-line lbrace
        return false;
    }

    function checkOracle(IACLOracle _oracleAddr, address _who, address _where, bytes32 _what, uint256[] _how) internal view returns (bool) {

        bytes4 sig = _oracleAddr.canPerform.selector;

        bytes memory checkCalldata = abi.encodeWithSelector(sig, _who, _where, _what, _how);

        bool ok;
        assembly {
            ok := staticcall(gas, _oracleAddr, add(checkCalldata, 0x20), mload(checkCalldata), 0, 0)
        }

        if (!ok) {
            return false;
        }

        uint256 size;
        assembly { size := returndatasize }
        if (size != 32) {
            return false;
        }

        bool result;
        assembly {
            let ptr := mload(0x40)       // get next free memory ptr
            returndatacopy(ptr, 0, size) // copy return from above `staticcall`
            result := mload(ptr)         // read data at ptr and set it to result
            mstore(ptr, 0)               // set pointer memory to 0 so it still is the next free ptr
        }

        return result;
    }

    function _setPermissionManager(address _newManager, address _app, bytes32 _role) internal {

        permissionManager[roleHash(_app, _role)] = _newManager;
        emit ChangePermissionManager(_app, _role, _newManager);
    }

    function roleHash(address _where, bytes32 _what) internal pure returns (bytes32) {

        return keccak256(abi.encodePacked("ROLE", _where, _what));
    }

    function permissionHash(address _who, address _where, bytes32 _what) internal pure returns (bytes32) {

        return keccak256(abi.encodePacked("PERMISSION", _who, _where, _what));
    }
}pragma solidity 0.4.24;


contract KernelStorage {

    mapping (bytes32 => mapping (bytes32 => address)) public apps;
    bytes32 public recoveryVaultAppId;
}/*
 *    MIT
 */

pragma solidity ^0.4.24;


contract ERCProxy {

    uint256 internal constant FORWARDING = 1;
    uint256 internal constant UPGRADEABLE = 2;

    function proxyType() public pure returns (uint256 proxyTypeId);

    function implementation() public view returns (address codeAddr);

}pragma solidity 0.4.24;



contract DelegateProxy is ERCProxy, IsContract {

    uint256 internal constant FWD_GAS_LIMIT = 10000;

    function delegatedFwd(address _dst, bytes _calldata) internal {

        require(isContract(_dst));
        uint256 fwdGasLimit = FWD_GAS_LIMIT;

        assembly {
            let result := delegatecall(sub(gas, fwdGasLimit), _dst, add(_calldata, 0x20), mload(_calldata), 0, 0)
            let size := returndatasize
            let ptr := mload(0x40)
            returndatacopy(ptr, 0, size)

            switch result case 0 { revert(ptr, size) }
            default { return(ptr, size) }
        }
    }
}pragma solidity 0.4.24;



contract DepositableStorage {

    using UnstructuredStorage for bytes32;

    bytes32 internal constant DEPOSITABLE_POSITION = 0x665fd576fbbe6f247aff98f5c94a561e3f71ec2d3c988d56f12d342396c50cea;

    function isDepositable() public view returns (bool) {

        return DEPOSITABLE_POSITION.getStorageBool();
    }

    function setDepositable(bool _depositable) internal {

        DEPOSITABLE_POSITION.setStorageBool(_depositable);
    }
}pragma solidity 0.4.24;



contract DepositableDelegateProxy is DepositableStorage, DelegateProxy {

    event ProxyDeposit(address sender, uint256 value);

    function () external payable {
        uint256 forwardGasThreshold = FWD_GAS_LIMIT;
        bytes32 isDepositablePosition = DEPOSITABLE_POSITION;

        assembly {
            if lt(gas, forwardGasThreshold) {
                if and(and(sload(isDepositablePosition), iszero(calldatasize)), gt(callvalue, 0)) {

                    let logData := mload(0x40) // free memory pointer
                    mstore(logData, caller) // add 'msg.sender' to the log data (first event param)
                    mstore(add(logData, 0x20), callvalue) // add 'msg.value' to the log data (second event param)

                    log1(logData, 0x40, 0x15eeaa57c7bd188c1388020bcadc2c436ec60d647d36ef5b9eb3c742217ddee1)

                    stop() // Stop. Exits execution context
                }

                revert(0, 0)
            }
        }

        address target = implementation();
        delegatedFwd(target, msg.data);
    }
}pragma solidity 0.4.24;



contract AppProxyBase is AppStorage, DepositableDelegateProxy, KernelNamespaceConstants {

    constructor(IKernel _kernel, bytes32 _appId, bytes _initializePayload) public {
        setKernel(_kernel);
        setAppId(_appId);

        address appCode = getAppBase(_appId);

        if (_initializePayload.length > 0) {
            require(isContract(appCode));
            require(appCode.delegatecall(_initializePayload));
        }
    }

    function getAppBase(bytes32 _appId) internal view returns (address) {

        return kernel().getApp(KERNEL_APP_BASES_NAMESPACE, _appId);
    }
}pragma solidity 0.4.24;



contract AppProxyUpgradeable is AppProxyBase {

    constructor(IKernel _kernel, bytes32 _appId, bytes _initializePayload)
        AppProxyBase(_kernel, _appId, _initializePayload)
        public // solium-disable-line visibility-first
    {
    }

    function implementation() public view returns (address) {

        return getAppBase(appId());
    }

    function proxyType() public pure returns (uint256 proxyTypeId) {

        return UPGRADEABLE;
    }
}pragma solidity 0.4.24;



contract AppProxyPinned is IsContract, AppProxyBase {

    using UnstructuredStorage for bytes32;

    bytes32 internal constant PINNED_CODE_POSITION = 0xdee64df20d65e53d7f51cb6ab6d921a0a6a638a91e942e1d8d02df28e31c038e;

    constructor(IKernel _kernel, bytes32 _appId, bytes _initializePayload)
        AppProxyBase(_kernel, _appId, _initializePayload)
        public // solium-disable-line visibility-first
    {
        setPinnedCode(getAppBase(_appId));
        require(isContract(pinnedCode()));
    }

    function implementation() public view returns (address) {

        return pinnedCode();
    }

    function proxyType() public pure returns (uint256 proxyTypeId) {

        return FORWARDING;
    }

    function setPinnedCode(address _pinnedCode) internal {

        PINNED_CODE_POSITION.setStorageAddress(_pinnedCode);
    }

    function pinnedCode() internal view returns (address) {

        return PINNED_CODE_POSITION.getStorageAddress();
    }
}pragma solidity 0.4.24;



contract AppProxyFactory {

    event NewAppProxy(address proxy, bool isUpgradeable, bytes32 appId);

    function newAppProxy(IKernel _kernel, bytes32 _appId) public returns (AppProxyUpgradeable) {

        return newAppProxy(_kernel, _appId, new bytes(0));
    }

    function newAppProxy(IKernel _kernel, bytes32 _appId, bytes _initializePayload) public returns (AppProxyUpgradeable) {

        AppProxyUpgradeable proxy = new AppProxyUpgradeable(_kernel, _appId, _initializePayload);
        emit NewAppProxy(address(proxy), true, _appId);
        return proxy;
    }

    function newAppProxyPinned(IKernel _kernel, bytes32 _appId) public returns (AppProxyPinned) {

        return newAppProxyPinned(_kernel, _appId, new bytes(0));
    }

    function newAppProxyPinned(IKernel _kernel, bytes32 _appId, bytes _initializePayload) public returns (AppProxyPinned) {

        AppProxyPinned proxy = new AppProxyPinned(_kernel, _appId, _initializePayload);
        emit NewAppProxy(address(proxy), false, _appId);
        return proxy;
    }
}pragma solidity 0.4.24;



contract Kernel is IKernel, KernelStorage, KernelAppIds, KernelNamespaceConstants, Petrifiable, IsContract, VaultRecoverable, AppProxyFactory, ACLSyntaxSugar {

    bytes32 public constant APP_MANAGER_ROLE = 0xb6d92708f3d4817afc106147d969e229ced5c46e65e0a5002a0d391287762bd0;

    string private constant ERROR_APP_NOT_CONTRACT = "KERNEL_APP_NOT_CONTRACT";
    string private constant ERROR_INVALID_APP_CHANGE = "KERNEL_INVALID_APP_CHANGE";
    string private constant ERROR_AUTH_FAILED = "KERNEL_AUTH_FAILED";

    constructor(bool _shouldPetrify) public {
        if (_shouldPetrify) {
            petrify();
        }
    }

    function initialize(IACL _baseAcl, address _permissionsCreator) public onlyInit {

        initialized();

        _setApp(KERNEL_APP_BASES_NAMESPACE, KERNEL_DEFAULT_ACL_APP_ID, _baseAcl);

        IACL acl = IACL(newAppProxy(this, KERNEL_DEFAULT_ACL_APP_ID));
        acl.initialize(_permissionsCreator);
        _setApp(KERNEL_APP_ADDR_NAMESPACE, KERNEL_DEFAULT_ACL_APP_ID, acl);

        recoveryVaultAppId = KERNEL_DEFAULT_VAULT_APP_ID;
    }

    function newAppInstance(bytes32 _appId, address _appBase)
        public
        auth(APP_MANAGER_ROLE, arr(KERNEL_APP_BASES_NAMESPACE, _appId))
        returns (ERCProxy appProxy)
    {

        return newAppInstance(_appId, _appBase, new bytes(0), false);
    }

    function newAppInstance(bytes32 _appId, address _appBase, bytes _initializePayload, bool _setDefault)
        public
        auth(APP_MANAGER_ROLE, arr(KERNEL_APP_BASES_NAMESPACE, _appId))
        returns (ERCProxy appProxy)
    {

        _setAppIfNew(KERNEL_APP_BASES_NAMESPACE, _appId, _appBase);
        appProxy = newAppProxy(this, _appId, _initializePayload);
        if (_setDefault) {
            setApp(KERNEL_APP_ADDR_NAMESPACE, _appId, appProxy);
        }
    }

    function newPinnedAppInstance(bytes32 _appId, address _appBase)
        public
        auth(APP_MANAGER_ROLE, arr(KERNEL_APP_BASES_NAMESPACE, _appId))
        returns (ERCProxy appProxy)
    {

        return newPinnedAppInstance(_appId, _appBase, new bytes(0), false);
    }

    function newPinnedAppInstance(bytes32 _appId, address _appBase, bytes _initializePayload, bool _setDefault)
        public
        auth(APP_MANAGER_ROLE, arr(KERNEL_APP_BASES_NAMESPACE, _appId))
        returns (ERCProxy appProxy)
    {

        _setAppIfNew(KERNEL_APP_BASES_NAMESPACE, _appId, _appBase);
        appProxy = newAppProxyPinned(this, _appId, _initializePayload);
        if (_setDefault) {
            setApp(KERNEL_APP_ADDR_NAMESPACE, _appId, appProxy);
        }
    }

    function setApp(bytes32 _namespace, bytes32 _appId, address _app)
        public
        auth(APP_MANAGER_ROLE, arr(_namespace, _appId))
    {

        _setApp(_namespace, _appId, _app);
    }

    function setRecoveryVaultAppId(bytes32 _recoveryVaultAppId)
        public
        auth(APP_MANAGER_ROLE, arr(KERNEL_APP_ADDR_NAMESPACE, _recoveryVaultAppId))
    {

        recoveryVaultAppId = _recoveryVaultAppId;
    }

    function CORE_NAMESPACE() external pure returns (bytes32) { return KERNEL_CORE_NAMESPACE; }

    function APP_BASES_NAMESPACE() external pure returns (bytes32) { return KERNEL_APP_BASES_NAMESPACE; }

    function APP_ADDR_NAMESPACE() external pure returns (bytes32) { return KERNEL_APP_ADDR_NAMESPACE; }

    function KERNEL_APP_ID() external pure returns (bytes32) { return KERNEL_CORE_APP_ID; }

    function DEFAULT_ACL_APP_ID() external pure returns (bytes32) { return KERNEL_DEFAULT_ACL_APP_ID; }


    function getApp(bytes32 _namespace, bytes32 _appId) public view returns (address) {

        return apps[_namespace][_appId];
    }

    function getRecoveryVault() public view returns (address) {

        return apps[KERNEL_APP_ADDR_NAMESPACE][recoveryVaultAppId];
    }

    function acl() public view returns (IACL) {

        return IACL(getApp(KERNEL_APP_ADDR_NAMESPACE, KERNEL_DEFAULT_ACL_APP_ID));
    }

    function hasPermission(address _who, address _where, bytes32 _what, bytes _how) public view returns (bool) {

        IACL defaultAcl = acl();
        return address(defaultAcl) != address(0) && // Poor man's initialization check (saves gas)
            defaultAcl.hasPermission(_who, _where, _what, _how);
    }

    function _setApp(bytes32 _namespace, bytes32 _appId, address _app) internal {

        require(isContract(_app), ERROR_APP_NOT_CONTRACT);
        apps[_namespace][_appId] = _app;
        emit SetApp(_namespace, _appId, _app);
    }

    function _setAppIfNew(bytes32 _namespace, bytes32 _appId, address _app) internal {

        address app = getApp(_namespace, _appId);
        if (app != address(0)) {
            require(app == _app, ERROR_INVALID_APP_CHANGE);
        } else {
            _setApp(_namespace, _appId, _app);
        }
    }

    modifier auth(bytes32 _role, uint256[] memory _params) {

        require(
            hasPermission(msg.sender, address(this), _role, ConversionHelpers.dangerouslyCastUintArrayToBytes(_params)),
            ERROR_AUTH_FAILED
        );
        _;
    }
}pragma solidity 0.4.24;



contract KernelProxy is IKernelEvents, KernelStorage, KernelAppIds, KernelNamespaceConstants, IsContract, DepositableDelegateProxy {

    constructor(IKernel _kernelImpl) public {
        require(isContract(address(_kernelImpl)));
        apps[KERNEL_CORE_NAMESPACE][KERNEL_CORE_APP_ID] = _kernelImpl;

        emit SetApp(KERNEL_CORE_NAMESPACE, KERNEL_CORE_APP_ID, _kernelImpl);
    }

    function proxyType() public pure returns (uint256 proxyTypeId) {

        return UPGRADEABLE;
    }

    function implementation() public view returns (address) {

        return apps[KERNEL_CORE_NAMESPACE][KERNEL_CORE_APP_ID];
    }
}/*
 *    MIT
 */

pragma solidity ^0.4.24;


library ScriptHelpers {

    function getSpecId(bytes _script) internal pure returns (uint32) {

        return uint32At(_script, 0);
    }

    function uint256At(bytes _data, uint256 _location) internal pure returns (uint256 result) {

        assembly {
            result := mload(add(_data, add(0x20, _location)))
        }
    }

    function addressAt(bytes _data, uint256 _location) internal pure returns (address result) {

        uint256 word = uint256At(_data, _location);

        assembly {
            result := div(and(word, 0xffffffffffffffffffffffffffffffffffffffff000000000000000000000000),
            0x1000000000000000000000000)
        }
    }

    function uint32At(bytes _data, uint256 _location) internal pure returns (uint32 result) {

        uint256 word = uint256At(_data, _location);

        assembly {
            result := div(and(word, 0xffffffff00000000000000000000000000000000000000000000000000000000),
            0x100000000000000000000000000000000000000000000000000000000)
        }
    }

    function locationOf(bytes _data, uint256 _location) internal pure returns (uint256 result) {

        assembly {
            result := add(_data, add(0x20, _location))
        }
    }

    function toBytes(bytes4 _sig) internal pure returns (bytes) {

        bytes memory payload = new bytes(4);
        assembly { mstore(add(payload, 0x20), _sig) }
        return payload;
    }
}pragma solidity 0.4.24;



contract EVMScriptRegistry is IEVMScriptRegistry, EVMScriptRegistryConstants, AragonApp {

    using ScriptHelpers for bytes;

    bytes32 public constant REGISTRY_ADD_EXECUTOR_ROLE = 0xc4e90f38eea8c4212a009ca7b8947943ba4d4a58d19b683417f65291d1cd9ed2;
    bytes32 public constant REGISTRY_MANAGER_ROLE = 0xf7a450ef335e1892cb42c8ca72e7242359d7711924b75db5717410da3f614aa3;

    uint256 internal constant SCRIPT_START_LOCATION = 4;

    string private constant ERROR_INEXISTENT_EXECUTOR = "EVMREG_INEXISTENT_EXECUTOR";
    string private constant ERROR_EXECUTOR_ENABLED = "EVMREG_EXECUTOR_ENABLED";
    string private constant ERROR_EXECUTOR_DISABLED = "EVMREG_EXECUTOR_DISABLED";
    string private constant ERROR_SCRIPT_LENGTH_TOO_SHORT = "EVMREG_SCRIPT_LENGTH_TOO_SHORT";

    struct ExecutorEntry {
        IEVMScriptExecutor executor;
        bool enabled;
    }

    uint256 private executorsNextIndex;
    mapping (uint256 => ExecutorEntry) public executors;

    event EnableExecutor(uint256 indexed executorId, address indexed executorAddress);
    event DisableExecutor(uint256 indexed executorId, address indexed executorAddress);

    modifier executorExists(uint256 _executorId) {

        require(_executorId > 0 && _executorId < executorsNextIndex, ERROR_INEXISTENT_EXECUTOR);
        _;
    }

    function initialize() public onlyInit {

        initialized();
        executorsNextIndex = 1;
    }

    function addScriptExecutor(IEVMScriptExecutor _executor) external auth(REGISTRY_ADD_EXECUTOR_ROLE) returns (uint256 id) {

        uint256 executorId = executorsNextIndex++;
        executors[executorId] = ExecutorEntry(_executor, true);
        emit EnableExecutor(executorId, _executor);
        return executorId;
    }

    function disableScriptExecutor(uint256 _executorId)
        external
        authP(REGISTRY_MANAGER_ROLE, arr(_executorId))
    {

        ExecutorEntry storage executorEntry = executors[_executorId];
        require(executorEntry.enabled, ERROR_EXECUTOR_DISABLED);
        executorEntry.enabled = false;
        emit DisableExecutor(_executorId, executorEntry.executor);
    }

    function enableScriptExecutor(uint256 _executorId)
        external
        authP(REGISTRY_MANAGER_ROLE, arr(_executorId))
        executorExists(_executorId)
    {

        ExecutorEntry storage executorEntry = executors[_executorId];
        require(!executorEntry.enabled, ERROR_EXECUTOR_ENABLED);
        executorEntry.enabled = true;
        emit EnableExecutor(_executorId, executorEntry.executor);
    }

    function getScriptExecutor(bytes _script) public view returns (IEVMScriptExecutor) {

        require(_script.length >= SCRIPT_START_LOCATION, ERROR_SCRIPT_LENGTH_TOO_SHORT);
        uint256 id = _script.getSpecId();

        ExecutorEntry storage entry = executors[id];
        return entry.enabled ? entry.executor : IEVMScriptExecutor(0);
    }
}/*
 *    MIT
 */

pragma solidity ^0.4.24;



contract BaseEVMScriptExecutor is IEVMScriptExecutor, Autopetrified {

    uint256 internal constant SCRIPT_START_LOCATION = 4;
}pragma solidity 0.4.24;




contract CallsScript is BaseEVMScriptExecutor {

    using ScriptHelpers for bytes;

    bytes32 internal constant EXECUTOR_TYPE = 0x2dc858a00f3e417be1394b87c07158e989ec681ce8cc68a9093680ac1a870302;

    string private constant ERROR_BLACKLISTED_CALL = "EVMCALLS_BLACKLISTED_CALL";
    string private constant ERROR_INVALID_LENGTH = "EVMCALLS_INVALID_LENGTH";


    event LogScriptCall(address indexed sender, address indexed src, address indexed dst);

    function execScript(bytes _script, bytes, address[] _blacklist) external isInitialized returns (bytes) {

        uint256 location = SCRIPT_START_LOCATION; // first 32 bits are spec id
        while (location < _script.length) {
            require(_script.length - location >= 0x18, ERROR_INVALID_LENGTH);

            address contractAddress = _script.addressAt(location);
            for (uint256 i = 0; i < _blacklist.length; i++) {
                require(contractAddress != _blacklist[i], ERROR_BLACKLISTED_CALL);
            }

            emit LogScriptCall(msg.sender, address(this), contractAddress);

            uint256 calldataLength = uint256(_script.uint32At(location + 0x14));
            uint256 startOffset = location + 0x14 + 0x04;
            uint256 calldataStart = _script.locationOf(startOffset);

            location = startOffset + calldataLength;
            require(location <= _script.length, ERROR_INVALID_LENGTH);

            bool success;
            assembly {
                success := call(
                    sub(gas, 5000),       // forward gas left - 5000
                    contractAddress,      // address
                    0,                    // no value
                    calldataStart,        // calldata start
                    calldataLength,       // calldata length
                    0,                    // don't write output
                    0                     // don't write output
                )

                switch success
                case 0 {
                    let ptr := mload(0x40)

                    switch returndatasize
                    case 0 {
                        mstore(ptr, 0x08c379a000000000000000000000000000000000000000000000000000000000)         // error identifier
                        mstore(add(ptr, 0x04), 0x0000000000000000000000000000000000000000000000000000000000000020) // starting offset
                        mstore(add(ptr, 0x24), 0x0000000000000000000000000000000000000000000000000000000000000016) // reason length
                        mstore(add(ptr, 0x44), 0x45564d43414c4c535f43414c4c5f524556455254454400000000000000000000) // reason

                        revert(ptr, 100) // 100 = 4 + 3 * 32 (error identifier + 3 words for the ABI encoded error)
                    }
                    default {
                        returndatacopy(ptr, 0, returndatasize)
                        revert(ptr, returndatasize)
                    }
                }
                default { }
            }
        }
    }

    function executorType() external pure returns (bytes32) {

        return EXECUTOR_TYPE;
    }
}pragma solidity 0.4.24;





contract EVMScriptRegistryFactory is EVMScriptRegistryConstants {

    EVMScriptRegistry public baseReg;
    IEVMScriptExecutor public baseCallScript;

    constructor() public {
        baseReg = new EVMScriptRegistry();
        baseCallScript = IEVMScriptExecutor(new CallsScript());
    }

    function newEVMScriptRegistry(Kernel _dao) public returns (EVMScriptRegistry reg) {

        bytes memory initPayload = abi.encodeWithSelector(reg.initialize.selector);
        reg = EVMScriptRegistry(_dao.newPinnedAppInstance(EVMSCRIPT_REGISTRY_APP_ID, baseReg, initPayload, true));

        ACL acl = ACL(_dao.acl());

        acl.createPermission(this, reg, reg.REGISTRY_ADD_EXECUTOR_ROLE(), this);

        reg.addScriptExecutor(baseCallScript);     // spec 1 = CallsScript

        acl.revokePermission(this, reg, reg.REGISTRY_ADD_EXECUTOR_ROLE());
        acl.removePermissionManager(reg, reg.REGISTRY_ADD_EXECUTOR_ROLE());

        return reg;
    }
}pragma solidity 0.4.24;





contract DAOFactory {

    IKernel public baseKernel;
    IACL public baseACL;
    EVMScriptRegistryFactory public regFactory;

    event DeployDAO(address dao);
    event DeployEVMScriptRegistry(address reg);

    constructor(IKernel _baseKernel, IACL _baseACL, EVMScriptRegistryFactory _regFactory) public {
        if (address(_regFactory) != address(0)) {
            regFactory = _regFactory;
        }

        baseKernel = _baseKernel;
        baseACL = _baseACL;
    }

    function newDAO(address _root) public returns (Kernel) {

        Kernel dao = Kernel(new KernelProxy(baseKernel));

        if (address(regFactory) == address(0)) {
            dao.initialize(baseACL, _root);
        } else {
            dao.initialize(baseACL, this);

            ACL acl = ACL(dao.acl());
            bytes32 permRole = acl.CREATE_PERMISSIONS_ROLE();
            bytes32 appManagerRole = dao.APP_MANAGER_ROLE();

            acl.grantPermission(regFactory, acl, permRole);

            acl.createPermission(regFactory, dao, appManagerRole, this);

            EVMScriptRegistry reg = regFactory.newEVMScriptRegistry(dao);
            emit DeployEVMScriptRegistry(address(reg));

            acl.revokePermission(regFactory, dao, appManagerRole);
            acl.removePermissionManager(dao, appManagerRole);

            acl.revokePermission(regFactory, acl, permRole);
            acl.revokePermission(this, acl, permRole);
            acl.grantPermission(_root, acl, permRole);
            acl.setPermissionManager(_root, acl, permRole);
        }

        emit DeployDAO(address(dao));

        return dao;
    }
}// See https://github.com/ensdomains/ens/blob/7e377df83f/contracts/AbstractENS.sol

pragma solidity ^0.4.15;


interface AbstractENS {

    function owner(bytes32 _node) public constant returns (address);

    function resolver(bytes32 _node) public constant returns (address);

    function ttl(bytes32 _node) public constant returns (uint64);

    function setOwner(bytes32 _node, address _owner) public;

    function setSubnodeOwner(bytes32 _node, bytes32 label, address _owner) public;

    function setResolver(bytes32 _node, address _resolver) public;

    function setTTL(bytes32 _node, uint64 _ttl) public;


    event NewOwner(bytes32 indexed _node, bytes32 indexed _label, address _owner);

    event Transfer(bytes32 indexed _node, address _owner);

    event NewResolver(bytes32 indexed _node, address _resolver);

    event NewTTL(bytes32 indexed _node, uint64 _ttl);
}// See https://github.com/ensdomains/ens/blob/7e377df83f/contracts/PublicResolver.sol

pragma solidity ^0.4.0;


contract PublicResolver {

    bytes4 constant INTERFACE_META_ID = 0x01ffc9a7;
    bytes4 constant ADDR_INTERFACE_ID = 0x3b3b57de;
    bytes4 constant CONTENT_INTERFACE_ID = 0xd8389dc5;
    bytes4 constant NAME_INTERFACE_ID = 0x691f3431;
    bytes4 constant ABI_INTERFACE_ID = 0x2203ab56;
    bytes4 constant PUBKEY_INTERFACE_ID = 0xc8690233;
    bytes4 constant TEXT_INTERFACE_ID = 0x59d1d43c;

    event AddrChanged(bytes32 indexed node, address a);
    event ContentChanged(bytes32 indexed node, bytes32 hash);
    event NameChanged(bytes32 indexed node, string name);
    event ABIChanged(bytes32 indexed node, uint256 indexed contentType);
    event PubkeyChanged(bytes32 indexed node, bytes32 x, bytes32 y);
    event TextChanged(bytes32 indexed node, string indexed indexedKey, string key);

    struct PublicKey {
        bytes32 x;
        bytes32 y;
    }

    struct Record {
        address addr;
        bytes32 content;
        string name;
        PublicKey pubkey;
        mapping(string=>string) text;
        mapping(uint256=>bytes) abis;
    }

    AbstractENS ens;
    mapping(bytes32=>Record) records;

    modifier only_owner(bytes32 node) {

        if (ens.owner(node) != msg.sender) throw;
        _;
    }

    function PublicResolver(AbstractENS ensAddr) public {

        ens = ensAddr;
    }

    function supportsInterface(bytes4 interfaceID) public pure returns (bool) {

        return interfaceID == ADDR_INTERFACE_ID ||
               interfaceID == CONTENT_INTERFACE_ID ||
               interfaceID == NAME_INTERFACE_ID ||
               interfaceID == ABI_INTERFACE_ID ||
               interfaceID == PUBKEY_INTERFACE_ID ||
               interfaceID == TEXT_INTERFACE_ID ||
               interfaceID == INTERFACE_META_ID;
    }

    function addr(bytes32 node) public constant returns (address ret) {

        ret = records[node].addr;
    }

    function setAddr(bytes32 node, address addr) only_owner(node) public {

        records[node].addr = addr;
        AddrChanged(node, addr);
    }

    function content(bytes32 node) public constant returns (bytes32 ret) {

        ret = records[node].content;
    }

    function setContent(bytes32 node, bytes32 hash) only_owner(node) public {

        records[node].content = hash;
        ContentChanged(node, hash);
    }

    function name(bytes32 node) public constant returns (string ret) {

        ret = records[node].name;
    }

    function setName(bytes32 node, string name) only_owner(node) public {

        records[node].name = name;
        NameChanged(node, name);
    }

    function ABI(bytes32 node, uint256 contentTypes) public constant returns (uint256 contentType, bytes data) {

        var record = records[node];
        for(contentType = 1; contentType <= contentTypes; contentType <<= 1) {
            if ((contentType & contentTypes) != 0 && record.abis[contentType].length > 0) {
                data = record.abis[contentType];
                return;
            }
        }
        contentType = 0;
    }

    function setABI(bytes32 node, uint256 contentType, bytes data) only_owner(node) public {

        if (((contentType - 1) & contentType) != 0) throw;

        records[node].abis[contentType] = data;
        ABIChanged(node, contentType);
    }

    function pubkey(bytes32 node) public constant returns (bytes32 x, bytes32 y) {

        return (records[node].pubkey.x, records[node].pubkey.y);
    }

    function setPubkey(bytes32 node, bytes32 x, bytes32 y) only_owner(node) public {

        records[node].pubkey = PublicKey(x, y);
        PubkeyChanged(node, x, y);
    }

    function text(bytes32 node, string key) public constant returns (string ret) {

        ret = records[node].text[key];
    }

    function setText(bytes32 node, string key, string value) only_owner(node) public {

        records[node].text[key] = value;
        TextChanged(node, key, key);
    }
}/*
 *    MIT
 */

pragma solidity ^0.4.24;


contract ENSConstants {

    bytes32 internal constant ENS_ROOT = bytes32(0);
    bytes32 internal constant ETH_TLD_LABEL = 0x4f5b812789fc606be1b3b16908db13fc7a9adf7ca72641f84d75b47069d3d7f0;
    bytes32 internal constant ETH_TLD_NODE = 0x93cdeb708b7545dc668eb9280176169d1c33cfd8ed6f04690a0bcc88a93fc4ae;
    bytes32 internal constant PUBLIC_RESOLVER_LABEL = 0x329539a1d23af1810c48a07fe7fc66a3b34fbc8b37e9b3cdb97bb88ceab7e4bf;
    bytes32 internal constant PUBLIC_RESOLVER_NODE = 0xfdd5d5de6dd63db72bbc2d487944ba13bf775b50a80805fe6fcaba9b0fba88f5;
}pragma solidity 0.4.24;




contract ENSSubdomainRegistrar is AragonApp, ENSConstants {

    bytes32 public constant CREATE_NAME_ROLE = 0xf86bc2abe0919ab91ef714b2bec7c148d94f61fdb069b91a6cfe9ecdee1799ba;
    bytes32 public constant DELETE_NAME_ROLE = 0x03d74c8724218ad4a99859bcb2d846d39999449fd18013dd8d69096627e68622;
    bytes32 public constant POINT_ROOTNODE_ROLE = 0x9ecd0e7bddb2e241c41b595a436c4ea4fd33c9fa0caa8056acf084fc3aa3bfbe;

    string private constant ERROR_NO_NODE_OWNERSHIP = "ENSSUB_NO_NODE_OWNERSHIP";
    string private constant ERROR_NAME_EXISTS = "ENSSUB_NAME_EXISTS";
    string private constant ERROR_NAME_DOESNT_EXIST = "ENSSUB_DOESNT_EXIST";

    AbstractENS public ens;
    bytes32 public rootNode;

    event NewName(bytes32 indexed node, bytes32 indexed label);
    event DeleteName(bytes32 indexed node, bytes32 indexed label);

    function initialize(AbstractENS _ens, bytes32 _rootNode) public onlyInit {

        initialized();

        require(_ens.owner(_rootNode) == address(this), ERROR_NO_NODE_OWNERSHIP);

        ens = _ens;
        rootNode = _rootNode;
    }

    function createName(bytes32 _label, address _owner) external auth(CREATE_NAME_ROLE) returns (bytes32 node) {

        return _createName(_label, _owner);
    }

    function createNameAndPoint(bytes32 _label, address _target) external auth(CREATE_NAME_ROLE) returns (bytes32 node) {

        node = _createName(_label, this);
        _pointToResolverAndResolve(node, _target);
    }

    function deleteName(bytes32 _label) external auth(DELETE_NAME_ROLE) {

        bytes32 node = getNodeForLabel(_label);

        address currentOwner = ens.owner(node);

        require(currentOwner != address(0), ERROR_NAME_DOESNT_EXIST); // fail if deleting unset name

        if (currentOwner != address(this)) { // needs to reclaim ownership so it can set resolver
            ens.setSubnodeOwner(rootNode, _label, this);
        }

        ens.setResolver(node, address(0)); // remove resolver so it ends resolving
        ens.setOwner(node, address(0));

        emit DeleteName(node, _label);
    }

    function pointRootNode(address _target) external auth(POINT_ROOTNODE_ROLE) {

        _pointToResolverAndResolve(rootNode, _target);
    }

    function _createName(bytes32 _label, address _owner) internal returns (bytes32 node) {

        node = getNodeForLabel(_label);
        require(ens.owner(node) == address(0), ERROR_NAME_EXISTS); // avoid name reset

        ens.setSubnodeOwner(rootNode, _label, _owner);

        emit NewName(node, _label);

        return node;
    }

    function _pointToResolverAndResolve(bytes32 _node, address _target) internal {

        address publicResolver = getAddr(PUBLIC_RESOLVER_NODE);
        ens.setResolver(_node, publicResolver);

        PublicResolver(publicResolver).setAddr(_node, _target);
    }

    function getAddr(bytes32 node) internal view returns (address) {

        address resolver = ens.resolver(node);
        return PublicResolver(resolver).addr(node);
    }

    function getNodeForLabel(bytes32 _label) internal view returns (bytes32) {

        return keccak256(abi.encodePacked(rootNode, _label));
    }
}pragma solidity 0.4.24;



contract Repo is AragonApp {

    bytes32 public constant CREATE_VERSION_ROLE = 0x1f56cfecd3595a2e6cc1a7e6cb0b20df84cdbd92eff2fee554e70e4e45a9a7d8;

    string private constant ERROR_INVALID_BUMP = "REPO_INVALID_BUMP";
    string private constant ERROR_INVALID_VERSION = "REPO_INVALID_VERSION";
    string private constant ERROR_INEXISTENT_VERSION = "REPO_INEXISTENT_VERSION";

    struct Version {
        uint16[3] semanticVersion;
        address contractAddress;
        bytes contentURI;
    }

    uint256 internal versionsNextIndex;
    mapping (uint256 => Version) internal versions;
    mapping (bytes32 => uint256) internal versionIdForSemantic;
    mapping (address => uint256) internal latestVersionIdForContract;

    event NewVersion(uint256 versionId, uint16[3] semanticVersion);

    function initialize() public onlyInit {

        initialized();
        versionsNextIndex = 1;
    }

    function newVersion(
        uint16[3] _newSemanticVersion,
        address _contractAddress,
        bytes _contentURI
    ) public auth(CREATE_VERSION_ROLE)
    {

        address contractAddress = _contractAddress;
        uint256 lastVersionIndex = versionsNextIndex - 1;

        uint16[3] memory lastSematicVersion;

        if (lastVersionIndex > 0) {
            Version storage lastVersion = versions[lastVersionIndex];
            lastSematicVersion = lastVersion.semanticVersion;

            if (contractAddress == address(0)) {
                contractAddress = lastVersion.contractAddress;
            }
            require(
                lastVersion.contractAddress == contractAddress || _newSemanticVersion[0] > lastVersion.semanticVersion[0],
                ERROR_INVALID_VERSION
            );
        }

        require(isValidBump(lastSematicVersion, _newSemanticVersion), ERROR_INVALID_BUMP);

        uint256 versionId = versionsNextIndex++;
        versions[versionId] = Version(_newSemanticVersion, contractAddress, _contentURI);
        versionIdForSemantic[semanticVersionHash(_newSemanticVersion)] = versionId;
        latestVersionIdForContract[contractAddress] = versionId;

        emit NewVersion(versionId, _newSemanticVersion);
    }

    function getLatest() public view returns (uint16[3] semanticVersion, address contractAddress, bytes contentURI) {

        return getByVersionId(versionsNextIndex - 1);
    }

    function getLatestForContractAddress(address _contractAddress)
        public
        view
        returns (uint16[3] semanticVersion, address contractAddress, bytes contentURI)
    {

        return getByVersionId(latestVersionIdForContract[_contractAddress]);
    }

    function getBySemanticVersion(uint16[3] _semanticVersion)
        public
        view
        returns (uint16[3] semanticVersion, address contractAddress, bytes contentURI)
    {

        return getByVersionId(versionIdForSemantic[semanticVersionHash(_semanticVersion)]);
    }

    function getByVersionId(uint _versionId) public view returns (uint16[3] semanticVersion, address contractAddress, bytes contentURI) {

        require(_versionId > 0 && _versionId < versionsNextIndex, ERROR_INEXISTENT_VERSION);
        Version storage version = versions[_versionId];
        return (version.semanticVersion, version.contractAddress, version.contentURI);
    }

    function getVersionsCount() public view returns (uint256) {

        return versionsNextIndex - 1;
    }

    function isValidBump(uint16[3] _oldVersion, uint16[3] _newVersion) public pure returns (bool) {

        bool hasBumped;
        uint i = 0;
        while (i < 3) {
            if (hasBumped) {
                if (_newVersion[i] != 0) {
                    return false;
                }
            } else if (_newVersion[i] != _oldVersion[i]) {
                if (_oldVersion[i] > _newVersion[i] || _newVersion[i] - _oldVersion[i] != 1) {
                    return false;
                }
                hasBumped = true;
            }
            i++;
        }
        return hasBumped;
    }

    function semanticVersionHash(uint16[3] version) internal pure returns (bytes32) {

        return keccak256(abi.encodePacked(version[0], version[1], version[2]));
    }
}pragma solidity 0.4.24;



contract APMInternalAppNames {

    string internal constant APM_APP_NAME = "apm-registry";
    string internal constant REPO_APP_NAME = "apm-repo";
    string internal constant ENS_SUB_APP_NAME = "apm-enssub";
}


contract APMRegistry is AragonApp, AppProxyFactory, APMInternalAppNames {

    bytes32 public constant CREATE_REPO_ROLE = 0x2a9494d64846c9fdbf0158785aa330d8bc9caf45af27fa0e8898eb4d55adcea6;

    string private constant ERROR_INIT_PERMISSIONS = "APMREG_INIT_PERMISSIONS";
    string private constant ERROR_EMPTY_NAME = "APMREG_EMPTY_NAME";

    AbstractENS public ens;
    ENSSubdomainRegistrar public registrar;

    event NewRepo(bytes32 id, string name, address repo);

    function initialize(ENSSubdomainRegistrar _registrar) public onlyInit {

        initialized();

        registrar = _registrar;
        ens = registrar.ens();

        registrar.pointRootNode(this);

        ACL acl = ACL(kernel().acl());
        require(acl.hasPermission(this, registrar, registrar.CREATE_NAME_ROLE()), ERROR_INIT_PERMISSIONS);
        require(acl.hasPermission(this, acl, acl.CREATE_PERMISSIONS_ROLE()), ERROR_INIT_PERMISSIONS);
    }

    function newRepo(string _name, address _dev) public auth(CREATE_REPO_ROLE) returns (Repo) {

        return _newRepo(_name, _dev);
    }

    function newRepoWithVersion(
        string _name,
        address _dev,
        uint16[3] _initialSemanticVersion,
        address _contractAddress,
        bytes _contentURI
    ) public auth(CREATE_REPO_ROLE) returns (Repo)
    {

        Repo repo = _newRepo(_name, this); // need to have permissions to create version
        repo.newVersion(_initialSemanticVersion, _contractAddress, _contentURI);

        ACL acl = ACL(kernel().acl());
        acl.revokePermission(this, repo, repo.CREATE_VERSION_ROLE());
        acl.grantPermission(_dev, repo, repo.CREATE_VERSION_ROLE());
        acl.setPermissionManager(_dev, repo, repo.CREATE_VERSION_ROLE());
        return repo;
    }

    function _newRepo(string _name, address _dev) internal returns (Repo) {

        require(bytes(_name).length > 0, ERROR_EMPTY_NAME);

        Repo repo = newClonedRepo();

        ACL(kernel().acl()).createPermission(_dev, repo, repo.CREATE_VERSION_ROLE(), _dev);

        bytes32 node = registrar.createNameAndPoint(keccak256(abi.encodePacked(_name)), repo);

        emit NewRepo(node, _name, repo);

        return repo;
    }

    function newClonedRepo() internal returns (Repo repo) {

        repo = Repo(newAppProxy(kernel(), repoAppId()));
        repo.initialize();
    }

    function repoAppId() internal view returns (bytes32) {

        return keccak256(abi.encodePacked(registrar.rootNode(), keccak256(abi.encodePacked(REPO_APP_NAME))));
    }
}// See https://github.com/ensdomains/ens/blob/7e377df83f/contracts/ENS.sol

pragma solidity ^0.4.0;



contract ENS is AbstractENS {

    struct Record {
        address owner;
        address resolver;
        uint64 ttl;
    }

    mapping(bytes32=>Record) records;

    modifier only_owner(bytes32 node) {

        if (records[node].owner != msg.sender) throw;
        _;
    }

    function ENS() public {

        records[0].owner = msg.sender;
    }

    function owner(bytes32 node) public constant returns (address) {

        return records[node].owner;
    }

    function resolver(bytes32 node) public constant returns (address) {

        return records[node].resolver;
    }

    function ttl(bytes32 node) public constant returns (uint64) {

        return records[node].ttl;
    }

    function setOwner(bytes32 node, address owner) only_owner(node) public {

        Transfer(node, owner);
        records[node].owner = owner;
    }

    function setSubnodeOwner(bytes32 node, bytes32 label, address owner) only_owner(node) public {

        var subnode = keccak256(node, label);
        NewOwner(node, label, owner);
        records[subnode].owner = owner;
    }

    function setResolver(bytes32 node, address resolver) only_owner(node) public {

        NewResolver(node, resolver);
        records[node].resolver = resolver;
    }

    function setTTL(bytes32 node, uint64 ttl) only_owner(node) public {

        NewTTL(node, ttl);
        records[node].ttl = ttl;
    }
}pragma solidity 0.4.24;



contract ENSFactory is ENSConstants {

    event DeployENS(address ens);

    function newENS(address _owner) public returns (ENS) {

        ENS ens = new ENS();

        ens.setSubnodeOwner(ENS_ROOT, ETH_TLD_LABEL, this);

        PublicResolver resolver = new PublicResolver(ens);
        ens.setSubnodeOwner(ETH_TLD_NODE, PUBLIC_RESOLVER_LABEL, this);
        ens.setResolver(PUBLIC_RESOLVER_NODE, resolver);
        resolver.setAddr(PUBLIC_RESOLVER_NODE, resolver);

        ens.setOwner(ETH_TLD_NODE, _owner);
        ens.setOwner(ENS_ROOT, _owner);

        emit DeployENS(ens);

        return ens;
    }
}pragma solidity 0.4.24;





contract APMRegistryFactory is APMInternalAppNames {

    DAOFactory public daoFactory;
    APMRegistry public registryBase;
    Repo public repoBase;
    ENSSubdomainRegistrar public ensSubdomainRegistrarBase;
    ENS public ens;

    event DeployAPM(bytes32 indexed node, address apm);

    constructor(
        DAOFactory _daoFactory,
        APMRegistry _registryBase,
        Repo _repoBase,
        ENSSubdomainRegistrar _ensSubBase,
        ENS _ens,
        ENSFactory _ensFactory
    ) public // DAO initialized without evmscript run support
    {
        daoFactory = _daoFactory;
        registryBase = _registryBase;
        repoBase = _repoBase;
        ensSubdomainRegistrarBase = _ensSubBase;

        ens = _ens != address(0) ? _ens : _ensFactory.newENS(this);
    }

    function newAPM(bytes32 _tld, bytes32 _label, address _root) public returns (APMRegistry) {

        bytes32 node = keccak256(abi.encodePacked(_tld, _label));

        if (ens.owner(node) != address(this)) {
            require(ens.owner(_tld) == address(this));
            ens.setSubnodeOwner(_tld, _label, this);
        }

        Kernel dao = daoFactory.newDAO(this);
        ACL acl = ACL(dao.acl());

        acl.createPermission(this, dao, dao.APP_MANAGER_ROLE(), this);

        bytes memory noInit = new bytes(0);
        ENSSubdomainRegistrar ensSub = ENSSubdomainRegistrar(
            dao.newAppInstance(
                keccak256(abi.encodePacked(node, keccak256(abi.encodePacked(ENS_SUB_APP_NAME)))),
                ensSubdomainRegistrarBase,
                noInit,
                false
            )
        );
        APMRegistry apm = APMRegistry(
            dao.newAppInstance(
                keccak256(abi.encodePacked(node, keccak256(abi.encodePacked(APM_APP_NAME)))),
                registryBase,
                noInit,
                false
            )
        );

        bytes32 repoAppId = keccak256(abi.encodePacked(node, keccak256(abi.encodePacked(REPO_APP_NAME))));
        dao.setApp(dao.APP_BASES_NAMESPACE(), repoAppId, repoBase);

        emit DeployAPM(node, apm);

        acl.createPermission(apm, ensSub, ensSub.CREATE_NAME_ROLE(), _root);
        acl.createPermission(apm, ensSub, ensSub.POINT_ROOTNODE_ROLE(), _root);

        bytes32 permRole = acl.CREATE_PERMISSIONS_ROLE();

        acl.grantPermission(apm, acl, permRole);

        ens.setOwner(node, ensSub);
        ensSub.initialize(ens, node);
        apm.initialize(ensSub);

        uint16[3] memory firstVersion;
        firstVersion[0] = 1;

        acl.createPermission(this, apm, apm.CREATE_REPO_ROLE(), this);

        apm.newRepoWithVersion(APM_APP_NAME, _root, firstVersion, registryBase, b("ipfs:apm"));
        apm.newRepoWithVersion(ENS_SUB_APP_NAME, _root, firstVersion, ensSubdomainRegistrarBase, b("ipfs:enssub"));
        apm.newRepoWithVersion(REPO_APP_NAME, _root, firstVersion, repoBase, b("ipfs:repo"));

        configureAPMPermissions(acl, apm, _root);

        acl.setPermissionManager(_root, dao, dao.APP_MANAGER_ROLE());
        acl.revokePermission(this, acl, permRole);
        acl.grantPermission(_root, acl, permRole);
        acl.setPermissionManager(_root, acl, permRole);

        return apm;
    }

    function b(string memory x) internal pure returns (bytes memory y) {

        y = bytes(x);
    }

    function configureAPMPermissions(ACL _acl, APMRegistry _apm, address _root) internal {

        _acl.grantPermission(_root, _apm, _apm.CREATE_REPO_ROLE());
        _acl.setPermissionManager(_root, _apm, _apm.CREATE_REPO_ROLE());
    }
}// See https://github.com/OpenZeppelin/openzeppelin-solidity/blob/d51e38758e1d985661534534d5c61e27bece5042/contracts/math/SafeMath.sol
// Adapted to use pragma ^0.4.24 and satisfy our linter rules

pragma solidity ^0.4.24;


library SafeMath {

    string private constant ERROR_ADD_OVERFLOW = "MATH_ADD_OVERFLOW";
    string private constant ERROR_SUB_UNDERFLOW = "MATH_SUB_UNDERFLOW";
    string private constant ERROR_MUL_OVERFLOW = "MATH_MUL_OVERFLOW";
    string private constant ERROR_DIV_ZERO = "MATH_DIV_ZERO";

    function mul(uint256 _a, uint256 _b) internal pure returns (uint256) {

        if (_a == 0) {
            return 0;
        }

        uint256 c = _a * _b;
        require(c / _a == _b, ERROR_MUL_OVERFLOW);

        return c;
    }

    function div(uint256 _a, uint256 _b) internal pure returns (uint256) {

        require(_b > 0, ERROR_DIV_ZERO); // Solidity only automatically asserts when dividing by 0
        uint256 c = _a / _b;

        return c;
    }

    function sub(uint256 _a, uint256 _b) internal pure returns (uint256) {

        require(_b <= _a, ERROR_SUB_UNDERFLOW);
        uint256 c = _a - _b;

        return c;
    }

    function add(uint256 _a, uint256 _b) internal pure returns (uint256) {

        uint256 c = _a + _b;
        require(c >= _a, ERROR_ADD_OVERFLOW);

        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b != 0, ERROR_DIV_ZERO);
        return a % b;
    }
}// Modified from https://github.com/OpenZeppelin/openzeppelin-solidity/blob/a9f910d34f0ab33a1ae5e714f69f9596a02b4d91/contracts/token/ERC20/StandardToken.sol

pragma solidity 0.4.24;



contract TokenMock {

    using SafeMath for uint256;
    mapping (address => uint256) private balances;
    mapping (address => mapping (address => uint256)) private allowed;
    uint256 private totalSupply_;
    bool private allowTransfer_;

    event Approval(address indexed owner, address indexed spender, uint256 value);
    event Transfer(address indexed from, address indexed to, uint256 value);

    constructor(address initialAccount, uint256 initialBalance) public {
        balances[initialAccount] = initialBalance;
        totalSupply_ = initialBalance;
        allowTransfer_ = true;
    }

    function totalSupply() public view returns (uint256) { return totalSupply_; }


    function balanceOf(address _owner) public view returns (uint256) {

        return balances[_owner];
    }

    function allowance(address _owner, address _spender) public view returns (uint256) {

        return allowed[_owner][_spender];
    }

    function setAllowTransfer(bool _allowTransfer) public {

        allowTransfer_ = _allowTransfer;
    }

    function transfer(address _to, uint256 _value) public returns (bool) {

        require(allowTransfer_);
        require(_value <= balances[msg.sender]);
        require(_to != address(0));

        balances[msg.sender] = balances[msg.sender].sub(_value);
        balances[_to] = balances[_to].add(_value);
        emit Transfer(msg.sender, _to, _value);
        return true;
    }

    function approve(address _spender, uint256 _value) public returns (bool) {

        require(allowed[msg.sender][_spender] == 0);

        allowed[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        return true;
    }

    function transferFrom(address _from, address _to, uint256 _value) public returns (bool) {

        require(allowTransfer_);
        require(_value <= balances[_from]);
        require(_value <= allowed[_from][msg.sender]);
        require(_to != address(0));

        balances[_from] = balances[_from].sub(_value);
        balances[_to] = balances[_to].add(_value);
        allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);
        emit Transfer(_from, _to, _value);
        return true;
    }
}pragma solidity 0.4.24;



contract Imports {

}pragma solidity ^0.4.24;



contract StandardToken {

    using SafeMath for uint256;

    mapping(address => uint256) internal balances;

    mapping(address => mapping(address => uint256)) internal allowed;

    uint256 internal supply;
    string public name;
    string public symbol;
    uint8 public decimals;

    constructor(
        string _name,
        string _symbol,
        uint8 _decimals,
        uint256 _totalSupply
    ) public {
        supply = _totalSupply; // Update total supply
        name = _name; // Set the id for reference
        symbol = _symbol;
        decimals = _decimals;
        balances[msg.sender] = _totalSupply;
        emit Transfer(address(0), msg.sender, _totalSupply); // Transfer event indicating token creation
    }

    function allowance(address _owner, address _spender)
        public
        view
        returns (uint256)
    {

        return allowed[_owner][_spender];
    }

    function transfer(address _to, uint256 _value) public returns (bool) {

        require(_value <= balances[msg.sender]);
        require(_to != address(0));
        balances[msg.sender] = balances[msg.sender].sub(_value);
        balances[_to] = balances[_to].add(_value);
        emit Transfer(msg.sender, _to, _value);
        return true;
    }

    function approve(address _spender, uint256 _value) public returns (bool) {

        allowed[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        return true;
    }

    function transferFrom(
        address _from,
        address _to,
        uint256 _value
    ) public returns (bool) {

        require(_value <= balances[_from]);
        require(_value <= allowed[_from][msg.sender]);
        require(_to != address(0));
        balances[_from] = balances[_from].sub(_value);
        balances[_to] = balances[_to].add(_value);
        allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);
        emit Transfer(_from, _to, _value);
        return true;
    }

    function increaseApproval(address _spender, uint256 _addedValue)
        public
        returns (bool)
    {

        allowed[msg.sender][_spender] = (
            allowed[msg.sender][_spender].add(_addedValue)
        );
        emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
        return true;
    }

    function decreaseApproval(address _spender, uint256 _subtractedValue)
        public
        returns (bool)
    {

        uint256 oldValue = allowed[msg.sender][_spender];
        if (_subtractedValue >= oldValue) {
            allowed[msg.sender][_spender] = 0;
        } else {
            allowed[msg.sender][_spender] = oldValue.sub(_subtractedValue);
        }
        emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
        return true;
    }

    function totalSupply() public view returns (uint256) {

        return supply;
    }

    function balanceOf(address _owner) public view returns (uint256) {

        return balances[_owner];
    }

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
}/*
 *    MIT
 */

pragma solidity ^0.4.24;


interface IForwarder {

    function isForwarder() external pure returns (bool);


    function canForward(address sender, bytes evmCallScript) public view returns (bool);


    function forward(bytes evmCallScript) public;

}// See https://github.com/OpenZeppelin/openzeppelin-solidity/blob/d51e38758e1d985661534534d5c61e27bece5042/contracts/math/SafeMath.sol
// Adapted for uint64, pragma ^0.4.24, and satisfying our linter rules

pragma solidity ^0.4.24;


library SafeMath64 {

    string private constant ERROR_ADD_OVERFLOW = "MATH64_ADD_OVERFLOW";
    string private constant ERROR_SUB_UNDERFLOW = "MATH64_SUB_UNDERFLOW";
    string private constant ERROR_MUL_OVERFLOW = "MATH64_MUL_OVERFLOW";
    string private constant ERROR_DIV_ZERO = "MATH64_DIV_ZERO";

    function mul(uint64 _a, uint64 _b) internal pure returns (uint64) {

        uint256 c = uint256(_a) * uint256(_b);
        require(c < 0x010000000000000000, ERROR_MUL_OVERFLOW); // 2**64 (less gas this way)

        return uint64(c);
    }

    function div(uint64 _a, uint64 _b) internal pure returns (uint64) {

        require(_b > 0, ERROR_DIV_ZERO); // Solidity only automatically asserts when dividing by 0
        uint64 c = _a / _b;

        return c;
    }

    function sub(uint64 _a, uint64 _b) internal pure returns (uint64) {

        require(_b <= _a, ERROR_SUB_UNDERFLOW);
        uint64 c = _a - _b;

        return c;
    }

    function add(uint64 _a, uint64 _b) internal pure returns (uint64) {

        uint64 c = _a + _b;
        require(c >= _a, ERROR_ADD_OVERFLOW);

        return c;
    }

    function mod(uint64 a, uint64 b) internal pure returns (uint64) {

        require(b != 0, ERROR_DIV_ZERO);
        return a % b;
    }
}pragma solidity ^0.4.24;



interface ITokenController {

    function proxyPayment(address _owner) external payable returns(bool);


    function onTransfer(address _from, address _to, uint _amount) external returns(bool);


    function onApprove(address _owner, address _spender, uint _amount) external returns(bool);

}pragma solidity ^0.4.24;




contract Controlled {

    modifier onlyController {

        require(msg.sender == controller);
        _;
    }

    address public controller;

    function Controlled()  public { controller = msg.sender;}


    function changeController(address _newController) onlyController  public {

        controller = _newController;
    }
}

contract ApproveAndCallFallBack {

    function receiveApproval(
        address from,
        uint256 _amount,
        address _token,
        bytes _data
    ) public;

}

contract MiniMeToken is Controlled {


    string public name;                //The Token's name: e.g. DigixDAO Tokens
    uint8 public decimals;             //Number of decimals of the smallest unit
    string public symbol;              //An identifier: e.g. REP
    string public version = "MMT_0.1"; //An arbitrary versioning scheme


    struct Checkpoint {

        uint128 fromBlock;

        uint128 value;
    }

    MiniMeToken public parentToken;

    uint public parentSnapShotBlock;

    uint public creationBlock;

    mapping (address => Checkpoint[]) balances;

    mapping (address => mapping (address => uint256)) allowed;

    Checkpoint[] totalSupplyHistory;

    bool public transfersEnabled;

    MiniMeTokenFactory public tokenFactory;


    function MiniMeToken(
        MiniMeTokenFactory _tokenFactory,
        MiniMeToken _parentToken,
        uint _parentSnapShotBlock,
        string _tokenName,
        uint8 _decimalUnits,
        string _tokenSymbol,
        bool _transfersEnabled
    )  public
    {

        tokenFactory = _tokenFactory;
        name = _tokenName;                                 // Set the name
        decimals = _decimalUnits;                          // Set the decimals
        symbol = _tokenSymbol;                             // Set the symbol
        parentToken = _parentToken;
        parentSnapShotBlock = _parentSnapShotBlock;
        transfersEnabled = _transfersEnabled;
        creationBlock = block.number;
    }



    function transfer(address _to, uint256 _amount) public returns (bool success) {

        require(transfersEnabled);
        return doTransfer(msg.sender, _to, _amount);
    }

    function transferFrom(address _from, address _to, uint256 _amount) public returns (bool success) {


        if (msg.sender != controller) {
            require(transfersEnabled);

            if (allowed[_from][msg.sender] < _amount)
                return false;
            allowed[_from][msg.sender] -= _amount;
        }
        return doTransfer(_from, _to, _amount);
    }

    function doTransfer(address _from, address _to, uint _amount) internal returns(bool) {

        if (_amount == 0) {
            return true;
        }
        require(parentSnapShotBlock < block.number);
        require((_to != 0) && (_to != address(this)));
        var previousBalanceFrom = balanceOfAt(_from, block.number);
        if (previousBalanceFrom < _amount) {
            return false;
        }
        if (isContract(controller)) {
            require(ITokenController(controller).onTransfer(_from, _to, _amount) == true);
        }
        updateValueAtNow(balances[_from], previousBalanceFrom - _amount);
        var previousBalanceTo = balanceOfAt(_to, block.number);
        require(previousBalanceTo + _amount >= previousBalanceTo); // Check for overflow
        updateValueAtNow(balances[_to], previousBalanceTo + _amount);
        Transfer(_from, _to, _amount);
        return true;
    }

    function balanceOf(address _owner) public constant returns (uint256 balance) {

        return balanceOfAt(_owner, block.number);
    }

    function approve(address _spender, uint256 _amount) public returns (bool success) {

        require(transfersEnabled);

        require((_amount == 0) || (allowed[msg.sender][_spender] == 0));

        if (isContract(controller)) {
            require(ITokenController(controller).onApprove(msg.sender, _spender, _amount) == true);
        }

        allowed[msg.sender][_spender] = _amount;
        Approval(msg.sender, _spender, _amount);
        return true;
    }

    function allowance(address _owner, address _spender) public constant returns (uint256 remaining) {

        return allowed[_owner][_spender];
    }

    function approveAndCall(ApproveAndCallFallBack _spender, uint256 _amount, bytes _extraData) public returns (bool success) {

        require(approve(_spender, _amount));

        _spender.receiveApproval(
            msg.sender,
            _amount,
            this,
            _extraData
        );

        return true;
    }

    function totalSupply() public constant returns (uint) {

        return totalSupplyAt(block.number);
    }



    function balanceOfAt(address _owner, uint _blockNumber) public constant returns (uint) {


        if ((balances[_owner].length == 0) || (balances[_owner][0].fromBlock > _blockNumber)) {
            if (address(parentToken) != 0) {
                return parentToken.balanceOfAt(_owner, min(_blockNumber, parentSnapShotBlock));
            } else {
                return 0;
            }

        } else {
            return getValueAt(balances[_owner], _blockNumber);
        }
    }

    function totalSupplyAt(uint _blockNumber) public constant returns(uint) {


        if ((totalSupplyHistory.length == 0) || (totalSupplyHistory[0].fromBlock > _blockNumber)) {
            if (address(parentToken) != 0) {
                return parentToken.totalSupplyAt(min(_blockNumber, parentSnapShotBlock));
            } else {
                return 0;
            }

        } else {
            return getValueAt(totalSupplyHistory, _blockNumber);
        }
    }


    function createCloneToken(
        string _cloneTokenName,
        uint8 _cloneDecimalUnits,
        string _cloneTokenSymbol,
        uint _snapshotBlock,
        bool _transfersEnabled
    ) public returns(MiniMeToken)
    {

        uint256 snapshot = _snapshotBlock == 0 ? block.number - 1 : _snapshotBlock;

        MiniMeToken cloneToken = tokenFactory.createCloneToken(
            this,
            snapshot,
            _cloneTokenName,
            _cloneDecimalUnits,
            _cloneTokenSymbol,
            _transfersEnabled
        );

        cloneToken.changeController(msg.sender);

        NewCloneToken(address(cloneToken), snapshot);
        return cloneToken;
    }


    function generateTokens(address _owner, uint _amount) onlyController public returns (bool) {

        uint curTotalSupply = totalSupply();
        require(curTotalSupply + _amount >= curTotalSupply); // Check for overflow
        uint previousBalanceTo = balanceOf(_owner);
        require(previousBalanceTo + _amount >= previousBalanceTo); // Check for overflow
        updateValueAtNow(totalSupplyHistory, curTotalSupply + _amount);
        updateValueAtNow(balances[_owner], previousBalanceTo + _amount);
        Transfer(0, _owner, _amount);
        return true;
    }


    function destroyTokens(address _owner, uint _amount) onlyController public returns (bool) {

        uint curTotalSupply = totalSupply();
        require(curTotalSupply >= _amount);
        uint previousBalanceFrom = balanceOf(_owner);
        require(previousBalanceFrom >= _amount);
        updateValueAtNow(totalSupplyHistory, curTotalSupply - _amount);
        updateValueAtNow(balances[_owner], previousBalanceFrom - _amount);
        Transfer(_owner, 0, _amount);
        return true;
    }



    function enableTransfers(bool _transfersEnabled) onlyController public {

        transfersEnabled = _transfersEnabled;
    }


    function getValueAt(Checkpoint[] storage checkpoints, uint _block) constant internal returns (uint) {

        if (checkpoints.length == 0)
            return 0;

        if (_block >= checkpoints[checkpoints.length-1].fromBlock)
            return checkpoints[checkpoints.length-1].value;
        if (_block < checkpoints[0].fromBlock)
            return 0;

        uint min = 0;
        uint max = checkpoints.length-1;
        while (max > min) {
            uint mid = (max + min + 1) / 2;
            if (checkpoints[mid].fromBlock<=_block) {
                min = mid;
            } else {
                max = mid-1;
            }
        }
        return checkpoints[min].value;
    }

    function updateValueAtNow(Checkpoint[] storage checkpoints, uint _value) internal {

        if ((checkpoints.length == 0) || (checkpoints[checkpoints.length - 1].fromBlock < block.number)) {
            Checkpoint storage newCheckPoint = checkpoints[checkpoints.length++];
            newCheckPoint.fromBlock = uint128(block.number);
            newCheckPoint.value = uint128(_value);
        } else {
            Checkpoint storage oldCheckPoint = checkpoints[checkpoints.length - 1];
            oldCheckPoint.value = uint128(_value);
        }
    }

    function isContract(address _addr) constant internal returns(bool) {

        uint size;
        if (_addr == 0)
            return false;

        assembly {
            size := extcodesize(_addr)
        }

        return size>0;
    }

    function min(uint a, uint b) pure internal returns (uint) {

        return a < b ? a : b;
    }

    function () external payable {
        require(isContract(controller));
        require(ITokenController(controller).proxyPayment.value(msg.value)(msg.sender) == true);
    }


    function claimTokens(address _token) onlyController public {

        if (_token == 0x0) {
            controller.transfer(this.balance);
            return;
        }

        MiniMeToken token = MiniMeToken(_token);
        uint balance = token.balanceOf(this);
        token.transfer(controller, balance);
        ClaimedTokens(_token, controller, balance);
    }

    event ClaimedTokens(address indexed _token, address indexed _controller, uint _amount);
    event Transfer(address indexed _from, address indexed _to, uint256 _amount);
    event NewCloneToken(address indexed _cloneToken, uint _snapshotBlock);
    event Approval(
        address indexed _owner,
        address indexed _spender,
        uint256 _amount
        );

}



contract MiniMeTokenFactory {


    function createCloneToken(
        MiniMeToken _parentToken,
        uint _snapshotBlock,
        string _tokenName,
        uint8 _decimalUnits,
        string _tokenSymbol,
        bool _transfersEnabled
    ) public returns (MiniMeToken)
    {

        MiniMeToken newToken = new MiniMeToken(
            this,
            _parentToken,
            _snapshotBlock,
            _tokenName,
            _decimalUnits,
            _tokenSymbol,
            _transfersEnabled
        );

        newToken.changeController(msg.sender);
        return newToken;
    }
}/*
 * SPDX-License-Identitifer:    GPL-3.0-or-later
 */

pragma solidity 0.4.24;





contract DandelionVoting is IForwarder, IACLOracle, AragonApp {

    using SafeMath for uint256;
    using SafeMath64 for uint64;

    bytes32 public constant CREATE_VOTES_ROLE = keccak256("CREATE_VOTES_ROLE");
    bytes32 public constant MODIFY_SUPPORT_ROLE = keccak256("MODIFY_SUPPORT_ROLE");
    bytes32 public constant MODIFY_QUORUM_ROLE = keccak256("MODIFY_QUORUM_ROLE");
    bytes32 public constant MODIFY_BUFFER_BLOCKS_ROLE = keccak256("MODIFY_BUFFER_BLOCKS_ROLE");
    bytes32 public constant MODIFY_EXECUTION_DELAY_ROLE = keccak256("MODIFY_EXECUTION_DELAY_ROLE");

    uint64 public constant PCT_BASE = 10 ** 18; // 0% = 0; 1% = 10^16; 100% = 10^18
    uint8 private constant EXECUTION_PERIOD_FALLBACK_DIVISOR = 2;

    string private constant ERROR_VOTE_ID_ZERO = "DANDELION_VOTING_VOTE_ID_ZERO";
    string private constant ERROR_NO_VOTE = "DANDELION_VOTING_NO_VOTE";
    string private constant ERROR_INIT_PCTS = "DANDELION_VOTING_INIT_PCTS";
    string private constant ERROR_CHANGE_SUPPORT_PCTS = "DANDELION_VOTING_CHANGE_SUPPORT_PCTS";
    string private constant ERROR_CHANGE_QUORUM_PCTS = "DANDELION_VOTING_CHANGE_QUORUM_PCTS";
    string private constant ERROR_INIT_SUPPORT_TOO_BIG = "DANDELION_VOTING_INIT_SUPPORT_TOO_BIG";
    string private constant ERROR_CHANGE_SUPPORT_TOO_BIG = "DANDELION_VOTING_CHANGE_SUPP_TOO_BIG";
    string private constant ERROR_CAN_NOT_VOTE = "DANDELION_VOTING_CAN_NOT_VOTE";
    string private constant ERROR_CAN_NOT_EXECUTE = "DANDELION_VOTING_CAN_NOT_EXECUTE";
    string private constant ERROR_CAN_NOT_FORWARD = "DANDELION_VOTING_CAN_NOT_FORWARD";
    string private constant ERROR_ORACLE_SENDER_MISSING = "DANDELION_VOTING_ORACLE_SENDER_MISSING";
    string private constant ERROR_ORACLE_SENDER_TOO_BIG = "DANDELION_VOTING_ORACLE_SENDER_TOO_BIG";
    string private constant ERROR_ORACLE_SENDER_ZERO = "DANDELION_VOTING_ORACLE_SENDER_ZERO";

    enum VoterState { Absent, Yea, Nay }

    struct Vote {
        bool executed;
        uint64 startBlock;
        uint64 executionBlock;
        uint64 snapshotBlock;
        uint64 supportRequiredPct;
        uint64 minAcceptQuorumPct;
        uint256 yea;
        uint256 nay;
        bytes executionScript;
        mapping (address => VoterState) voters;
    }

    MiniMeToken public token;
    uint64 public supportRequiredPct;
    uint64 public minAcceptQuorumPct;
    uint64 public durationBlocks;
    uint64 public bufferBlocks;
    uint64 public executionDelayBlocks;

    mapping (uint256 => Vote) internal votes;
    uint256 public votesLength;
    mapping (address => uint256) public latestYeaVoteId;

    event StartVote(uint256 indexed voteId, address indexed creator, string metadata);
    event CastVote(uint256 indexed voteId, address indexed voter, bool supports, uint256 stake);
    event ExecuteVote(uint256 indexed voteId);
    event ChangeSupportRequired(uint64 supportRequiredPct);
    event ChangeMinQuorum(uint64 minAcceptQuorumPct);
    event ChangeBufferBlocks(uint64 bufferBlocks);
    event ChangeExecutionDelayBlocks(uint64 executionDelayBlocks);

    modifier voteExists(uint256 _voteId) {

        require(_voteId != 0, ERROR_VOTE_ID_ZERO);
        require(_voteId <= votesLength, ERROR_NO_VOTE);
        _;
    }

    function initialize(
        MiniMeToken _token,
        uint64 _supportRequiredPct,
        uint64 _minAcceptQuorumPct,
        uint64 _durationBlocks,
        uint64 _bufferBlocks,
        uint64 _executionDelayBlocks
    )
        external
        onlyInit
    {

        initialized();

        require(_minAcceptQuorumPct <= _supportRequiredPct, ERROR_INIT_PCTS);
        require(_supportRequiredPct < PCT_BASE, ERROR_INIT_SUPPORT_TOO_BIG);

        token = _token;
        supportRequiredPct = _supportRequiredPct;
        minAcceptQuorumPct = _minAcceptQuorumPct;
        durationBlocks = _durationBlocks;
        bufferBlocks = _bufferBlocks;
        executionDelayBlocks = _executionDelayBlocks;
    }

    function changeSupportRequiredPct(uint64 _supportRequiredPct)
        external
        authP(MODIFY_SUPPORT_ROLE, arr(uint256(_supportRequiredPct), uint256(supportRequiredPct)))
    {

        require(minAcceptQuorumPct <= _supportRequiredPct, ERROR_CHANGE_SUPPORT_PCTS);
        require(_supportRequiredPct < PCT_BASE, ERROR_CHANGE_SUPPORT_TOO_BIG);
        supportRequiredPct = _supportRequiredPct;

        emit ChangeSupportRequired(_supportRequiredPct);
    }

    function changeMinAcceptQuorumPct(uint64 _minAcceptQuorumPct)
        external
        authP(MODIFY_QUORUM_ROLE, arr(uint256(_minAcceptQuorumPct), uint256(minAcceptQuorumPct)))
    {

        require(_minAcceptQuorumPct <= supportRequiredPct, ERROR_CHANGE_QUORUM_PCTS);
        minAcceptQuorumPct = _minAcceptQuorumPct;

        emit ChangeMinQuorum(_minAcceptQuorumPct);
    }

    function changeBufferBlocks(uint64 _bufferBlocks) external auth(MODIFY_BUFFER_BLOCKS_ROLE) {

        bufferBlocks = _bufferBlocks;
        emit ChangeBufferBlocks(_bufferBlocks);
    }

    function changeExecutionDelayBlocks(uint64 _executionDelayBlocks) external auth(MODIFY_EXECUTION_DELAY_ROLE) {

        executionDelayBlocks = _executionDelayBlocks;
        emit ChangeExecutionDelayBlocks(_executionDelayBlocks);
    }

    function newVote(bytes _executionScript, string _metadata, bool _castVote)
        external
        auth(CREATE_VOTES_ROLE)
        returns (uint256 voteId)
    {

        return _newVote(_executionScript, _metadata, _castVote);
    }

    function vote(uint256 _voteId, bool _supports) external voteExists(_voteId) {

        require(_canVote(_voteId, msg.sender), ERROR_CAN_NOT_VOTE);
        _vote(_voteId, _supports, msg.sender);
    }

    function executeVote(uint256 _voteId) external {

        require(_canExecute(_voteId), ERROR_CAN_NOT_EXECUTE);

        Vote storage vote_ = votes[_voteId];

        vote_.executed = true;

        bytes memory input = new bytes(0); // TODO: Consider input for voting scripts
        runScript(vote_.executionScript, input, new address[](0));

        emit ExecuteVote(_voteId);
    }


    function isForwarder() external pure returns (bool) {

        return true;
    }

    function forward(bytes _evmScript) public {

        require(canForward(msg.sender, _evmScript), ERROR_CAN_NOT_FORWARD);
        _newVote(_evmScript, "", true);
    }

    function canForward(address _sender, bytes) public view returns (bool) {

        return canPerform(_sender, CREATE_VOTES_ROLE, arr());
    }


    function canPerform(address, address, bytes32, uint256[] _how) external view returns (bool) {

        if (votesLength == 0) {
            return true;
        }

        require(_how.length > 0, ERROR_ORACLE_SENDER_MISSING);
        require(_how[0] < 2**160, ERROR_ORACLE_SENDER_TOO_BIG);
        require(_how[0] != 0, ERROR_ORACLE_SENDER_ZERO);

        address sender = address(_how[0]);
        uint256 senderLatestYeaVoteId = latestYeaVoteId[sender];
        Vote storage senderLatestYeaVote_ = votes[senderLatestYeaVoteId];
        uint64 blockNumber = getBlockNumber64();

        bool senderLatestYeaVoteFailed = !_votePassed(senderLatestYeaVote_);
        bool senderLatestYeaVoteExecutionBlockPassed = blockNumber >= senderLatestYeaVote_.executionBlock;

        uint64 fallbackPeriodLength = bufferBlocks / EXECUTION_PERIOD_FALLBACK_DIVISOR;
        bool senderLatestYeaVoteFallbackPeriodPassed = blockNumber > senderLatestYeaVote_.executionBlock.add(fallbackPeriodLength);

        return senderLatestYeaVoteFailed && senderLatestYeaVoteExecutionBlockPassed || senderLatestYeaVote_.executed || senderLatestYeaVoteFallbackPeriodPassed;
    }


    function canExecute(uint256 _voteId) public view returns (bool) {

        return _canExecute(_voteId);
    }

    function canVote(uint256 _voteId, address _voter) public view voteExists(_voteId) returns (bool) {

        return _canVote(_voteId, _voter);
    }

    function getVote(uint256 _voteId)
        public
        view
        voteExists(_voteId)
        returns (
            bool open,
            bool executed,
            uint64 startBlock,
            uint64 executionBlock,
            uint64 snapshotBlock,
            uint64 supportRequired,
            uint64 minAcceptQuorum,
            uint256 votingPower,
            uint256 yea,
            uint256 nay,
            bytes script
        )
    {

        Vote storage vote_ = votes[_voteId];

        open = _isVoteOpen(vote_);
        executed = vote_.executed;
        startBlock = vote_.startBlock;
        executionBlock = vote_.executionBlock;
        snapshotBlock = vote_.snapshotBlock;
        votingPower = token.totalSupplyAt(vote_.snapshotBlock);
        supportRequired = vote_.supportRequiredPct;
        minAcceptQuorum = vote_.minAcceptQuorumPct;
        yea = vote_.yea;
        nay = vote_.nay;
        script = vote_.executionScript;
    }

    function getVoterState(uint256 _voteId, address _voter) public view voteExists(_voteId) returns (VoterState) {

        return votes[_voteId].voters[_voter];
    }


    function _newVote(bytes _executionScript, string _metadata, bool _castVote) internal returns (uint256 voteId) {

        voteId = ++votesLength; // Increment votesLength before assigning to votedId. The first voteId is 1.

        uint64 previousVoteStartBlock = votes[voteId - 1].startBlock;
        uint64 earliestStartBlock = previousVoteStartBlock == 0 ? 0 : previousVoteStartBlock.add(bufferBlocks);
        uint64 startBlock = earliestStartBlock < getBlockNumber64() ? getBlockNumber64() : earliestStartBlock;

        uint64 executionBlock = startBlock.add(durationBlocks).add(executionDelayBlocks);

        Vote storage vote_ = votes[voteId];
        vote_.startBlock = startBlock;
        vote_.executionBlock = executionBlock;
        vote_.snapshotBlock = startBlock - 1; // avoid double voting in this very block
        vote_.supportRequiredPct = supportRequiredPct;
        vote_.minAcceptQuorumPct = minAcceptQuorumPct;
        vote_.executionScript = _executionScript;

        emit StartVote(voteId, msg.sender, _metadata);

        if (_castVote && _canVote(voteId, msg.sender)) {
            _vote(voteId, true, msg.sender);
        }
    }

    function _vote(uint256 _voteId, bool _supports, address _voter) internal {

        Vote storage vote_ = votes[_voteId];

        uint256 voterStake = _voterStake(vote_, _voter);

        if (_supports) {
            vote_.yea = vote_.yea.add(voterStake);
            if (latestYeaVoteId[_voter] < _voteId) {
                latestYeaVoteId[_voter] = _voteId;
            }
        } else {
            vote_.nay = vote_.nay.add(voterStake);
        }

        vote_.voters[_voter] = _supports ? VoterState.Yea : VoterState.Nay;

        emit CastVote(_voteId, _voter, _supports, voterStake);
    }

    function _canExecute(uint256 _voteId) internal view voteExists(_voteId) returns (bool) {

        Vote storage vote_ = votes[_voteId];

        if (vote_.executed) {
            return false;
        }

        if (getBlockNumber64() < vote_.executionBlock) {
            return false;
        }

        return _votePassed(vote_);
    }

    function _votePassed(Vote storage vote_) internal view returns (bool) {

        uint256 totalVotes = vote_.yea.add(vote_.nay);
        uint256 votingPowerAtSnapshot = token.totalSupplyAt(vote_.snapshotBlock);

        bool hasSupportRequired = _isValuePct(vote_.yea, totalVotes, vote_.supportRequiredPct);
        bool hasMinQuorum = _isValuePct(vote_.yea, votingPowerAtSnapshot, vote_.minAcceptQuorumPct);

        return hasSupportRequired && hasMinQuorum;
    }

    function _canVote(uint256 _voteId, address _voter) internal view returns (bool) {

        Vote storage vote_ = votes[_voteId];

        uint256 voterStake = _voterStake(vote_, _voter);
        bool hasNotVoted = vote_.voters[_voter] == VoterState.Absent;

        return _isVoteOpen(vote_) && voterStake > 0 && hasNotVoted;
    }

    function _voterStake(Vote storage vote_, address _voter) internal view returns (uint256) {

        uint256 balanceAtSnapshot = token.balanceOfAt(_voter, vote_.snapshotBlock);
        uint256 currentBalance = token.balanceOf(_voter);

        return balanceAtSnapshot < currentBalance ? balanceAtSnapshot : currentBalance;
    }

    function _isVoteOpen(Vote storage vote_) internal view returns (bool) {

        uint256 votingPowerAtSnapshot = token.totalSupplyAt(vote_.snapshotBlock);
        uint64 blockNumber = getBlockNumber64();
        return votingPowerAtSnapshot > 0 && blockNumber >= vote_.startBlock && blockNumber < vote_.startBlock.add(durationBlocks);
    }

    function _isValuePct(uint256 _value, uint256 _total, uint256 _pct) internal pure returns (bool) {

        if (_total == 0) {
            return false;
        }

        uint256 computedPct = _value.mul(PCT_BASE) / _total;
        return computedPct > _pct;
    }
}pragma solidity 0.4.24;



contract VotingMock is DandelionVoting {

    function newVoteExt(
        bytes _executionScript,
        string _metadata,
        bool _castVote
    ) external returns (uint256) {

        return _newVote(_executionScript, _metadata, _castVote);
    }
}pragma solidity 0.4.24;



contract Vault is EtherTokenConstant, AragonApp, DepositableStorage {

    using SafeERC20 for ERC20;

    bytes32 public constant TRANSFER_ROLE = keccak256("TRANSFER_ROLE");

    string private constant ERROR_DATA_NON_ZERO = "VAULT_DATA_NON_ZERO";
    string private constant ERROR_NOT_DEPOSITABLE = "VAULT_NOT_DEPOSITABLE";
    string private constant ERROR_DEPOSIT_VALUE_ZERO = "VAULT_DEPOSIT_VALUE_ZERO";
    string private constant ERROR_TRANSFER_VALUE_ZERO = "VAULT_TRANSFER_VALUE_ZERO";
    string private constant ERROR_SEND_REVERTED = "VAULT_SEND_REVERTED";
    string private constant ERROR_VALUE_MISMATCH = "VAULT_VALUE_MISMATCH";
    string private constant ERROR_TOKEN_TRANSFER_FROM_REVERTED = "VAULT_TOKEN_TRANSFER_FROM_REVERT";
    string private constant ERROR_TOKEN_TRANSFER_REVERTED = "VAULT_TOKEN_TRANSFER_REVERTED";

    event VaultTransfer(address indexed token, address indexed to, uint256 amount);
    event VaultDeposit(address indexed token, address indexed sender, uint256 amount);

    function () external payable isInitialized {
        require(msg.data.length == 0, ERROR_DATA_NON_ZERO);
        _deposit(ETH, msg.value);
    }

    function initialize() external onlyInit {

        initialized();
        setDepositable(true);
    }

    function deposit(address _token, uint256 _value) external payable isInitialized {

        _deposit(_token, _value);
    }

    function transfer(address _token, address _to, uint256 _value)
        external
        authP(TRANSFER_ROLE, arr(_token, _to, _value))
    {

        require(_value > 0, ERROR_TRANSFER_VALUE_ZERO);

        if (_token == ETH) {
            require(_to.send(_value), ERROR_SEND_REVERTED);
        } else {
            require(ERC20(_token).safeTransfer(_to, _value), ERROR_TOKEN_TRANSFER_REVERTED);
        }

        emit VaultTransfer(_token, _to, _value);
    }

    function balance(address _token) public view returns (uint256) {

        if (_token == ETH) {
            return address(this).balance;
        } else {
            return ERC20(_token).staticBalanceOf(address(this));
        }
    }

    function allowRecoverability(address) public view returns (bool) {

        return false;
    }

    function _deposit(address _token, uint256 _value) internal {

        require(isDepositable(), ERROR_NOT_DEPOSITABLE);
        require(_value > 0, ERROR_DEPOSIT_VALUE_ZERO);

        if (_token == ETH) {
            require(msg.value == _value, ERROR_VALUE_MISMATCH);
        } else {
            require(
                ERC20(_token).safeTransferFrom(msg.sender, address(this), _value),
                ERROR_TOKEN_TRANSFER_FROM_REVERTED
            );
        }

        emit VaultDeposit(_token, msg.sender, _value);
    }
}pragma solidity ^0.4.24;
pragma experimental ABIEncoderV2;



contract VotingRewards is AragonApp {

    using SafeERC20 for ERC20;
    using SafeMath for uint256;
    using SafeMath64 for uint64;

    bytes32 public constant CHANGE_EPOCH_DURATION_ROLE = keccak256("CHANGE_EPOCH_DURATION_ROLE");
    bytes32 public constant CHANGE_REWARD_TOKEN_ROLE = keccak256("CHANGE_REWARD_TOKEN_ROLE");
    bytes32 public constant CHANGE_MISSING_VOTES_THRESHOLD_ROLE = keccak256("CHANGE_MISSING_VOTES_THRESHOLD_ROLE");
    bytes32 public constant CHANGE_LOCK_TIME_ROLE = keccak256("CHANGE_LOCK_TIME_ROLE");
    bytes32 public constant OPEN_REWARDS_DISTRIBUTION_ROLE = keccak256("OPEN_REWARDS_DISTRIBUTION_ROLE");
    bytes32 public constant CLOSE_REWARDS_DISTRIBUTION_ROLE = keccak256("CLOSE_REWARDS_DISTRIBUTION_ROLE");
    bytes32 public constant DISTRIBUTE_REWARD_ROLE = keccak256("DISTRIBUTE_REWARD_ROLE");
    bytes32 public constant CHANGE_PERCENTAGE_REWARDS_ROLE = keccak256("CHANGE_PERCENTAGE_REWARDS_ROLE");
    bytes32 public constant CHANGE_VAULT_ROLE = keccak256("CHANGE_VAULT_ROLE");
    bytes32 public constant CHANGE_VOTING_ROLE = keccak256("CHANGE_VOTING_ROLE");

    uint64 public constant PCT_BASE = 10**18; // 0% = 0; 1% = 10^16; 100% = 10^18

    string private constant ERROR_ADDRESS_NOT_CONTRACT = "VOTING_REWARD_ADDRESS_NOT_CONTRACT";
    string private constant ERROR_VOTING_NO_VOTES = "VOTING_REWARD_VOTING_NO_VOTES";
    string private constant ERROR_TOO_MANY_MISSING_VOTES = "VOTING_REWARD_TOO_MANY_MISSING_VOTES";
    string private constant ERROR_EPOCH = "VOTING_REWARD_ERROR_EPOCH";
    string private constant ERROR_PERCENTAGE_REWARD = "VOTING_REWARD_PERCENTAGE_REWARD";
    string private constant ERROR_EPOCH_REWARDS_DISTRIBUTION_NOT_OPENED = "VOTING_REWARD_EPOCH_REWARDS_DISTRIBUTION_NOT_OPENED";
    string private constant ERROR_EPOCH_REWARDS_DISTRIBUTION_ALREADY_OPENED = "VOTING_REWARD_EPOCH_REWARDS_DISTRIBUTION_ALREADY_OPENED";
    string private constant ERROR_WRONG_VALUE = "VOTING_REWARD_WRONG_VALUE";
    string private constant ERROR_NO_REWARDS = "VOTING_REWARD_NO_REWARDS";

    struct Reward {
        uint256 amount;
        uint64 lockBlock;
        uint64 lockTime;
    }

    Vault public baseVault;
    Vault public rewardsVault;
    DandelionVoting public dandelionVoting;

    address public rewardsToken;
    uint256 public percentageRewards;
    uint256 public missingVotesThreshold;

    uint64 public epochDuration;
    uint64 public currentEpoch;
    uint64 public startBlockNumberOfCurrentEpoch;
    uint64 public lockTime;
    uint64 public lastRewardsDistributionBlock;
    uint64 private deployBlock;

    bool public isDistributionOpen;

    mapping(address => uint64) private previousRewardsDistributionBlockNumber;
    mapping(address => Reward[]) public addressUnlockedRewards;
    mapping(address => Reward[]) public addressWithdrawnRewards;

    event BaseVaultChanged(address baseVault);
    event RewardsVaultChanged(address rewardsVault);
    event DandelionVotingChanged(address dandelionVoting);
    event PercentageRewardsChanged(uint256 percentageRewards);
    event RewardDistributed(
        address beneficiary,
        uint256 amount,
        uint64 lockTime
    );
    event RewardCollected(address beneficiary, uint256 amount);
    event EpochDurationChanged(uint64 epochDuration);
    event MissingVoteThresholdChanged(uint256 missingVotesThreshold);
    event LockTimeChanged(uint64 lockTime);
    event RewardsDistributionEpochOpened(uint64 startBlock, uint64 endBlock);
    event RewardsDistributionEpochClosed(uint64 rewardDistributionBlock);
    event RewardsTokenChanged(address rewardsToken);

    function initialize(
        address _baseVault,
        address _rewardsVault,
        address _dandelionVoting,
        address _rewardsToken,
        uint64 _epochDuration,
        uint256 _percentageRewards,
        uint64 _lockTime,
        uint256 _missingVotesThreshold
    ) external onlyInit {

        require(isContract(_baseVault), ERROR_ADDRESS_NOT_CONTRACT);
        require(isContract(_rewardsVault), ERROR_ADDRESS_NOT_CONTRACT);
        require(isContract(_dandelionVoting), ERROR_ADDRESS_NOT_CONTRACT);
        require(isContract(_rewardsToken), ERROR_ADDRESS_NOT_CONTRACT);
        require(_percentageRewards <= PCT_BASE, ERROR_PERCENTAGE_REWARD);

        baseVault = Vault(_baseVault);
        rewardsVault = Vault(_rewardsVault);
        dandelionVoting = DandelionVoting(_dandelionVoting);
        rewardsToken = _rewardsToken;
        epochDuration = _epochDuration;
        percentageRewards = _percentageRewards;
        missingVotesThreshold = _missingVotesThreshold;
        lockTime = _lockTime;

        deployBlock = getBlockNumber64();
        lastRewardsDistributionBlock = getBlockNumber64();
        currentEpoch = 0;

        initialized();
    }

    function openRewardsDistributionForEpoch(uint64 _fromBlock)
        external
        auth(OPEN_REWARDS_DISTRIBUTION_ROLE)
    {

        require(
            !isDistributionOpen,
            ERROR_EPOCH_REWARDS_DISTRIBUTION_ALREADY_OPENED
        );
        require(_fromBlock > lastRewardsDistributionBlock, ERROR_EPOCH);
        require(
            getBlockNumber64() - lastRewardsDistributionBlock > epochDuration,
            ERROR_EPOCH
        );

        startBlockNumberOfCurrentEpoch = _fromBlock;
        isDistributionOpen = true;

        emit RewardsDistributionEpochOpened(
            _fromBlock,
            _fromBlock + epochDuration
        );
    }

    function closeRewardsDistributionForCurrentEpoch()
        external
        auth(CLOSE_REWARDS_DISTRIBUTION_ROLE)
    {

        require(
            isDistributionOpen == true,
            ERROR_EPOCH_REWARDS_DISTRIBUTION_NOT_OPENED
        );
        isDistributionOpen = false;
        currentEpoch = currentEpoch.add(1);
        lastRewardsDistributionBlock = getBlockNumber64();
        emit RewardsDistributionEpochClosed(lastRewardsDistributionBlock);
    }

    function distributeRewardsToMany(address[] _beneficiaries)
        external
        auth(DISTRIBUTE_REWARD_ROLE)
    {

        require(dandelionVoting.votesLength() > 0, ERROR_VOTING_NO_VOTES);
        require(
            isDistributionOpen,
            ERROR_EPOCH_REWARDS_DISTRIBUTION_NOT_OPENED
        );

        for (uint256 i = 0; i < _beneficiaries.length; i++) {
            distributeRewardsTo(_beneficiaries[i]);
        }
    }

    function collectRewardsForMany(address[] _beneficiaries) external {

        for (uint256 i = 0; i < _beneficiaries.length; i++) {
            collectRewardsFor(_beneficiaries[i]);
        }
    }

    function changeEpochDuration(uint64 _epochDuration)
        external
        auth(CHANGE_EPOCH_DURATION_ROLE)
    {

        require(_epochDuration > 0, ERROR_WRONG_VALUE);
        epochDuration = _epochDuration;

        emit EpochDurationChanged(_epochDuration);
    }

    function changeMissingVotesThreshold(uint256 _missingVotesThreshold)
        external
        auth(CHANGE_MISSING_VOTES_THRESHOLD_ROLE)
    {

        missingVotesThreshold = _missingVotesThreshold;
        emit MissingVoteThresholdChanged(_missingVotesThreshold);
    }

    function changeLockTime(uint64 _lockTime)
        external
        auth(CHANGE_LOCK_TIME_ROLE)
    {

        lockTime = _lockTime;

        emit LockTimeChanged(_lockTime);
    }

    function changeBaseVaultContractAddress(address _baseVault)
        external
        auth(CHANGE_VAULT_ROLE)
    {

        require(isContract(_baseVault), ERROR_ADDRESS_NOT_CONTRACT);
        baseVault = Vault(_baseVault);

        emit BaseVaultChanged(_baseVault);
    }

    function changeRewardsVaultContractAddress(address _rewardsVault)
        external
        auth(CHANGE_VAULT_ROLE)
    {

        require(isContract(_rewardsVault), ERROR_ADDRESS_NOT_CONTRACT);
        rewardsVault = Vault(_rewardsVault);

        emit RewardsVaultChanged(_rewardsVault);
    }

    function changeDandelionVotingContractAddress(address _dandelionVoting)
        external
        auth(CHANGE_VOTING_ROLE)
    {

        require(isContract(_dandelionVoting), ERROR_ADDRESS_NOT_CONTRACT);
        dandelionVoting = DandelionVoting(_dandelionVoting);

        emit DandelionVotingChanged(_dandelionVoting);
    }

    function changePercentageReward(uint256 _percentageRewards)
        external
        auth(CHANGE_PERCENTAGE_REWARDS_ROLE)
    {

        require(_percentageRewards <= PCT_BASE, ERROR_PERCENTAGE_REWARD);
        percentageRewards = _percentageRewards;

        emit PercentageRewardsChanged(percentageRewards);
    }

    function changeRewardsTokenContractAddress(address _rewardsToken)
        external
        auth(CHANGE_PERCENTAGE_REWARDS_ROLE)
    {

        require(isContract(_rewardsToken), ERROR_ADDRESS_NOT_CONTRACT);
        rewardsToken = _rewardsToken;

        emit RewardsTokenChanged(rewardsToken);
    }

    function getUnlockedRewardsInfo(address _beneficiary)
        external
        view
        returns (Reward[])
    {

        Reward[] rewards = addressUnlockedRewards[_beneficiary];
        return rewards;
    }

    function getWithdrawnRewardsInfo(address _beneficiary)
        external
        view
        returns (Reward[])
    {

        Reward[] rewards = addressWithdrawnRewards[_beneficiary];
        return rewards;
    }

    function distributeRewardsTo(address _beneficiary)
        public
        auth(DISTRIBUTE_REWARD_ROLE)
    {

        require(
            isDistributionOpen,
            ERROR_EPOCH_REWARDS_DISTRIBUTION_NOT_OPENED
        );

        uint64 lastBlockDistributedReward = 0;
        if (previousRewardsDistributionBlockNumber[_beneficiary] != 0) {
            lastBlockDistributedReward = previousRewardsDistributionBlockNumber[_beneficiary];
        } else {
            lastBlockDistributedReward = deployBlock;
        }

        uint64 claimEnd = startBlockNumberOfCurrentEpoch.add(epochDuration);
        require(claimEnd > lastBlockDistributedReward, ERROR_EPOCH);

        uint256 rewardAmount = _calculateReward(
            _beneficiary,
            startBlockNumberOfCurrentEpoch,
            claimEnd
        );

        uint64 currentBlockNumber = getBlockNumber64();
        previousRewardsDistributionBlockNumber[_beneficiary] = currentBlockNumber;

        uint256 positionWhereInsert = _getEmptyRewardIndexForAddress(
            _beneficiary
        );
        if (
            positionWhereInsert == addressUnlockedRewards[_beneficiary].length
        ) {
            addressUnlockedRewards[_beneficiary].push(
                Reward(rewardAmount, currentBlockNumber, lockTime)
            );
        } else {
            addressUnlockedRewards[_beneficiary][positionWhereInsert] = Reward(
                rewardAmount,
                currentBlockNumber,
                lockTime
            );
        }

        baseVault.transfer(rewardsToken, rewardsVault, rewardAmount);
        emit RewardDistributed(_beneficiary, rewardAmount, lockTime);
    }

    function collectRewardsFor(address _beneficiary) public returns (bool) {

        uint64 currentBlockNumber = getBlockNumber64();
        Reward[] storage rewards = addressUnlockedRewards[_beneficiary];

        require(rewards.length > 0, ERROR_NO_REWARDS);

        uint256 collectedRewards = 0;
        for (uint256 i = 0; i < rewards.length; i++) {
            if (
                currentBlockNumber - rewards[i].lockBlock >
                rewards[i].lockTime &&
                !_isRewardEmpty(rewards[i])
            ) {
                rewardsVault.transfer(
                    rewardsToken,
                    _beneficiary,
                    rewards[i].amount
                );
                collectedRewards = collectedRewards.add(1);

                addressWithdrawnRewards[_beneficiary].push(rewards[i]);
                emit RewardCollected(_beneficiary, rewards[i].amount);

                delete rewards[i];
            }
        }

        require(collectedRewards >= 1, ERROR_NO_REWARDS);
        return true;
    }

    function _calculateReward(
        address _beneficiary,
        uint64 _fromBlock,
        uint64 _toBlock
    ) internal view returns (uint256) {

        uint256 missingVotes = 0;
        uint256 minimumBalance = 0;
        uint256 votesLength = dandelionVoting.votesLength();
        uint64 voteDurationBlocks = dandelionVoting.durationBlocks();
        bool isFirstUserVoteInEpoch = true;

        for (uint256 voteId = votesLength; voteId >= 1; voteId--) {
            uint64 startBlock;
            (, , startBlock, , , , , , , , ) = dandelionVoting.getVote(voteId);

            if (
                startBlock.add(voteDurationBlocks) >= _fromBlock &&
                startBlock.add(voteDurationBlocks) <= _toBlock
            ) {
                if (
                    dandelionVoting.getVoterState(voteId, _beneficiary) ==
                    DandelionVoting.VoterState.Absent
                ) {
                    missingVotes = missingVotes.add(1);
                } else {
                    uint256 votingTokenBalanceAtVote = MiniMeToken(
                        dandelionVoting.token()
                    )
                        .balanceOfAt(_beneficiary, startBlock);

                    if (isFirstUserVoteInEpoch) {
                        isFirstUserVoteInEpoch = false;
                        minimumBalance = votingTokenBalanceAtVote;
                    }

                    if (votingTokenBalanceAtVote < minimumBalance) {
                        minimumBalance = votingTokenBalanceAtVote;
                    }
                }

                require(
                    missingVotes <= missingVotesThreshold,
                    ERROR_TOO_MANY_MISSING_VOTES
                );
            }

            if (startBlock < _fromBlock) break;
        }

        return
            minimumBalance > 0
                ? (minimumBalance).mul(percentageRewards).div(PCT_BASE)
                : minimumBalance;
    }

    function _getEmptyRewardIndexForAddress(address _beneficiary)
        internal
        view
        returns (uint256)
    {

        Reward[] storage rewards = addressUnlockedRewards[_beneficiary];
        uint256 numberOfUnlockedRewards = addressUnlockedRewards[_beneficiary]
            .length;

        for (uint256 i = 0; i < numberOfUnlockedRewards; i++) {
            if (_isRewardEmpty(rewards[i])) {
                return i;
            }
        }

        return numberOfUnlockedRewards;
    }

    function _isRewardEmpty(Reward memory _reward)
        internal
        pure
        returns (bool)
    {

        return
            _reward.amount == 0 &&
            _reward.lockBlock == 0 &&
            _reward.lockTime == 0;
    }
}