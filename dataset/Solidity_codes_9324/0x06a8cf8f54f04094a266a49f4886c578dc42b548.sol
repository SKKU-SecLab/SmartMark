


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
}



pragma solidity ^0.4.24;


interface IACL {

    function initialize(address permissionsCreator) external;


    function hasPermission(address who, address where, bytes32 what, bytes how) public view returns (bool);

}



pragma solidity ^0.4.24;


interface IVaultRecoverable {

    event RecoverToVault(address indexed vault, address indexed token, uint256 amount);

    function transferToVault(address token) external;


    function allowRecoverability(address token) external view returns (bool);

    function getRecoveryVault() external view returns (address);

}



pragma solidity ^0.4.24;




interface IKernelEvents {

    event SetApp(bytes32 indexed namespace, bytes32 indexed appId, address app);
}


contract IKernel is IKernelEvents, IVaultRecoverable {

    function acl() public view returns (IACL);

    function hasPermission(address who, address where, bytes32 what, bytes how) public view returns (bool);


    function setApp(bytes32 namespace, bytes32 appId, address app) public;

    function getApp(bytes32 namespace, bytes32 appId) public view returns (address);

}



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
}



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
}


pragma solidity ^0.4.24;


library Uint256Helpers {

    uint256 private constant MAX_UINT64 = uint64(-1);

    string private constant ERROR_NUMBER_TOO_BIG = "UINT64_NUMBER_TOO_BIG";

    function toUint64(uint256 a) internal pure returns (uint64) {

        require(a <= MAX_UINT64, ERROR_NUMBER_TOO_BIG);
        return uint64(a);
    }
}



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
}



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
}



pragma solidity ^0.4.24;



contract Petrifiable is Initializable {

    uint256 internal constant PETRIFIED_BLOCK = uint256(-1);

    function isPetrified() public view returns (bool) {

        return getInitializationBlock() == PETRIFIED_BLOCK;
    }

    function petrify() internal onlyInit {

        initializedAt(PETRIFIED_BLOCK);
    }
}



pragma solidity ^0.4.24;



contract Autopetrified is Petrifiable {

    constructor() public {
        petrify();
    }
}


pragma solidity ^0.4.24;


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
}



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
}



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
}



pragma solidity ^0.4.24;


contract EtherTokenConstant {

    address internal constant ETH = address(0);
}



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
}



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
}



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

}



pragma solidity ^0.4.24;


interface IEVMScriptExecutor {

    function execScript(bytes script, bytes input, address[] blacklist) external returns (bytes);

    function executorType() external pure returns (bytes32);

}



pragma solidity ^0.4.24;



contract EVMScriptRegistryConstants {

    bytes32 internal constant EVMSCRIPT_REGISTRY_APP_ID = 0xddbcfd564f642ab5627cf68b9b7d374fb4f8a36e941a75d89c87998cef03bd61;
}


interface IEVMScriptRegistry {

    function addScriptExecutor(IEVMScriptExecutor executor) external returns (uint id);

    function disableScriptExecutor(uint256 executorId) external;


    function getScriptExecutor(bytes script) public view returns (IEVMScriptExecutor);

}



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
}



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
}



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
}



pragma solidity ^0.4.24;


interface IForwarder {

    function isForwarder() external pure returns (bool);


    function canForward(address sender, bytes evmCallScript) public view returns (bool);


    function forward(bytes evmCallScript) public;

}



pragma solidity ^0.4.24;


interface IForwarderFee {

    function forwardFee() external view returns (address, uint256);

}


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
}



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
}


pragma solidity ^0.4.24;








contract TimeLock is AragonApp, IForwarder, IForwarderFee {


    using SafeERC20 for ERC20;
    using SafeMath for uint256;
    using ScriptHelpers for bytes;

    bytes32 internal constant CALLS_SCRIPT_EXECUTOR_TYPE = 0x2dc858a00f3e417be1394b87c07158e989ec681ce8cc68a9093680ac1a870302;

    bytes32 public constant CHANGE_DURATION_ROLE = keccak256("CHANGE_DURATION_ROLE");
    bytes32 public constant CHANGE_AMOUNT_ROLE = keccak256("CHANGE_AMOUNT_ROLE");
    bytes32 public constant CHANGE_SPAM_PENALTY_ROLE = keccak256("CHANGE_SPAM_PENALTY_ROLE");
    bytes32 public constant LOCK_TOKENS_ROLE = keccak256("LOCK_TOKENS_ROLE");

    string private constant ERROR_NOT_CONTRACT = "TIME_LOCK_NOT_CONTRACT";
    string private constant ERROR_TOO_MANY_WITHDRAW_LOCKS = "TIME_LOCK_TOO_MANY_WITHDRAW_LOCKS";
    string private constant ERROR_CAN_NOT_FORWARD = "TIME_LOCK_CAN_NOT_FORWARD";
    string private constant ERROR_TRANSFER_REVERTED = "TIME_LOCK_TRANSFER_REVERTED";
    string private constant ERROR_USE_CALLS_SCRIPT_EXECUTOR = "TIME_LOCK_USE_CALLS_SCRIPT_EXECUTOR";
    string private constant ERROR_SCRIPT_INCORRECT_LENGTH = "TIME_LOCK_SCRIPT_INCORRECT_LENGTH";

    struct WithdrawLock {
        uint256 unlockTime;
        uint256 lockAmount;
    }

    ERC20 public token;
    uint256 public lockDuration;
    uint256 public lockAmount;

    uint256 public spamPenaltyFactor;
    uint256 public constant PCT_BASE = 10 ** 18; // 0% = 0; 1% = 10^16; 100% = 10^18

    mapping(address => WithdrawLock[]) public addressesWithdrawLocks;
    address[] scriptRunnerBlacklist;

    event ChangeLockDuration(uint256 newLockDuration);
    event ChangeLockAmount(uint256 newLockAmount);
    event ChangeSpamPenaltyFactor(uint256 newSpamPenaltyFactor);
    event NewLock(address lockAddress, uint256 unlockTime, uint256 lockAmount);
    event Withdrawal(address withdrawalAddress ,uint256 withdrawalLockCount);

    function initialize(address _token, uint256 _lockDuration, uint256 _lockAmount, uint256 _spamPenaltyFactor) external onlyInit {

        require(isContract(_token), ERROR_NOT_CONTRACT);

        token = ERC20(_token);
        lockDuration = _lockDuration;
        lockAmount = _lockAmount;
        spamPenaltyFactor = _spamPenaltyFactor;

        scriptRunnerBlacklist.push(address(this));
        scriptRunnerBlacklist.push(address(token));

        initialized();
    }

    function changeLockDuration(uint256 _lockDuration) external auth(CHANGE_DURATION_ROLE) {

        lockDuration = _lockDuration;
        emit ChangeLockDuration(lockDuration);
    }

    function changeLockAmount(uint256 _lockAmount) external auth(CHANGE_AMOUNT_ROLE) {

        lockAmount = _lockAmount;
        emit ChangeLockAmount(lockAmount);
    }

    function changeSpamPenaltyFactor(uint256 _spamPenaltyFactor) external auth(CHANGE_SPAM_PENALTY_ROLE) {

        spamPenaltyFactor = _spamPenaltyFactor;
        emit ChangeSpamPenaltyFactor(_spamPenaltyFactor);
    }

    function withdrawAllTokens() external {

        WithdrawLock[] storage addressWithdrawLocks = addressesWithdrawLocks[msg.sender];
        _withdrawTokens(addressWithdrawLocks.length);
    }

    function withdrawTokens(uint256 _numberWithdrawLocks) external {

        _withdrawTokens(_numberWithdrawLocks);
    }

    function forwardFee() external view returns (address, uint256) {

        (uint256 _spamPenaltyAmount, ) = getSpamPenalty(msg.sender);

        uint256 totalLockAmountRequired = lockAmount.add(_spamPenaltyAmount);

        return (address(token), totalLockAmountRequired);
    }

    function isForwarder() external pure returns (bool) {

        return true;
    }

    function canForward(address _sender, bytes) public view returns (bool) {

        return canPerform(_sender, LOCK_TOKENS_ROLE, arr(_sender));
    }

    function forward(bytes _evmCallScript) public {

        require(canForward(msg.sender, _evmCallScript), ERROR_CAN_NOT_FORWARD);
        _ensureOnlyOneScript(_evmCallScript);

        WithdrawLock[] storage addressWithdrawLocks = addressesWithdrawLocks[msg.sender];
        (uint256 spamPenaltyAmount, uint256 spamPenaltyDuration) = getSpamPenalty(msg.sender);

        uint256 totalAmount = lockAmount.add(spamPenaltyAmount);
        uint256 totalDuration = lockDuration.add(spamPenaltyDuration);
        uint256 unlockTime = getTimestamp().add(totalDuration);

        addressWithdrawLocks.push(WithdrawLock(unlockTime, totalAmount));
        require(token.safeTransferFrom(msg.sender, address(this), totalAmount), ERROR_TRANSFER_REVERTED);

        emit NewLock(msg.sender, unlockTime, totalAmount);
        runScript(_evmCallScript, new bytes(0), scriptRunnerBlacklist);
    }

    function getWithdrawLocksCount(address _lockAddress) public view returns (uint256) {

        return addressesWithdrawLocks[_lockAddress].length;
    }

    function getSpamPenalty(address _sender) public view returns (uint256, uint256) {

        WithdrawLock[] memory addressWithdrawLocks = addressesWithdrawLocks[_sender];

        uint256 activeLocks = 0;
        for (uint256 withdrawLockIndex = 0; withdrawLockIndex < addressWithdrawLocks.length; withdrawLockIndex++) {
            if (getTimestamp() < addressWithdrawLocks[withdrawLockIndex].unlockTime) {
                activeLocks += 1;
            }
        }

        uint256 totalAmount = lockAmount.mul(activeLocks).mul(spamPenaltyFactor).div(PCT_BASE);
        uint256 totalDuration = lockDuration.mul(activeLocks).mul(spamPenaltyFactor).div(PCT_BASE);

        return (totalAmount, totalDuration);
    }

    function _withdrawTokens(uint256 _numberWithdrawLocks) internal {

        WithdrawLock[] storage addressWithdrawLocks = addressesWithdrawLocks[msg.sender];
        require(_numberWithdrawLocks <= addressWithdrawLocks.length, ERROR_TOO_MANY_WITHDRAW_LOCKS);

        uint256 amountOwed = 0;
        uint256 withdrawLockCount = 0;
        uint256 addressWithdrawLocksLength = addressWithdrawLocks.length;

        for (uint256 i = _numberWithdrawLocks; i > 0; i--) {

            uint256 withdrawLockIndex = i - 1;
            WithdrawLock memory withdrawLock = addressWithdrawLocks[withdrawLockIndex];

            if (getTimestamp() > withdrawLock.unlockTime) {
                amountOwed = amountOwed.add(withdrawLock.lockAmount);
                withdrawLockCount += 1;
                delete addressWithdrawLocks[withdrawLockIndex];
            }
        }

        uint256 newAddressWithdrawLocksLength = addressWithdrawLocksLength - withdrawLockCount;
        for (uint256 shiftIndex = 0; shiftIndex < newAddressWithdrawLocksLength; shiftIndex++) {
            addressWithdrawLocks[shiftIndex] = addressWithdrawLocks[shiftIndex + withdrawLockCount];
            delete addressWithdrawLocks[shiftIndex + withdrawLockCount];
        }

        addressWithdrawLocks.length = newAddressWithdrawLocksLength;

        token.transfer(msg.sender, amountOwed);

        emit Withdrawal(msg.sender, withdrawLockCount);
    }

    function _ensureOnlyOneScript(bytes _evmScript) internal {

        uint256 specIdLength = 0x4;
        uint256 addressLength = 0x14;
        uint256 dataSizeLength = 0x4;
        uint256 dataSizeLocation = 0x18;

        IEVMScriptExecutor scriptExecutor = getEVMScriptExecutor(_evmScript);
        require(scriptExecutor.executorType() == CALLS_SCRIPT_EXECUTOR_TYPE, ERROR_USE_CALLS_SCRIPT_EXECUTOR);

        uint256 calldataLength = uint256(_evmScript.uint32At(dataSizeLocation));
        uint256 scriptExpectedLength = specIdLength + addressLength + dataSizeLength + calldataLength;
        require(scriptExpectedLength == _evmScript.length, ERROR_SCRIPT_INCORRECT_LENGTH);
    }

    function allowRecoverability(address token) public view returns (bool) {

        return false;
    }
}