
pragma solidity 0.4.24;
library Uint256Helpers {

    uint256 private constant MAX_UINT64 = uint64(-1);

    string private constant ERROR_NUMBER_TOO_BIG = "UINT64_NUMBER_TOO_BIG";

    function toUint64(uint256 a) internal pure returns (uint64) {

        require(a <= MAX_UINT64, ERROR_NUMBER_TOO_BIG);
        return uint64(a);
    }
}

pragma solidity ^0.4.24;


interface IACL {

    function initialize(address permissionsCreator) external;


    function hasPermission(address who, address where, bytes32 what, bytes how) public view returns (bool);

}

pragma solidity ^0.4.24;


interface IVaultRecoverable {

    function transferToVault(address token) external;


    function allowRecoverability(address token) external view returns (bool);

    function getRecoveryVault() external view returns (address);

}

pragma solidity ^0.4.24;




contract IKernel is IVaultRecoverable {

    event SetApp(bytes32 indexed namespace, bytes32 indexed appId, address app);

    function acl() public view returns (IACL);

    function hasPermission(address who, address where, bytes32 what, bytes how) public view returns (bool);


    function setApp(bytes32 namespace, bytes32 appId, address app) public;

    function getApp(bytes32 namespace, bytes32 appId) public view returns (address);

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
contract KernelStorage {

    mapping (bytes32 => mapping (bytes32 => address)) public apps;
    bytes32 public recoveryVaultAppId;
}

pragma solidity ^0.4.24;


contract ACLSyntaxSugar {

    function arr() internal pure returns (uint256[]) {}


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


contract ERCProxy {

    uint256 internal constant FORWARDING = 1;
    uint256 internal constant UPGRADEABLE = 2;

    function proxyType() public pure returns (uint256 proxyTypeId);

    function implementation() public view returns (address codeAddr);

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






contract VaultRecoverable is IVaultRecoverable, EtherTokenConstant, IsContract {

    string private constant ERROR_DISALLOWED = "RECOVER_DISALLOWED";
    string private constant ERROR_VAULT_NOT_CONTRACT = "RECOVER_VAULT_NOT_CONTRACT";

    function transferToVault(address _token) external {

        require(allowRecoverability(_token), ERROR_DISALLOWED);
        address vault = getRecoveryVault();
        require(isContract(vault), ERROR_VAULT_NOT_CONTRACT);

        if (_token == ETH) {
            vault.transfer(address(this).balance);
        } else {
            uint256 amount = ERC20(_token).balanceOf(this);
            ERC20(_token).transfer(vault, amount);
        }
    }

    function allowRecoverability(address token) public view returns (bool) {

        return true;
    }

    function getRecoveryVault() public view returns (address);

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
}
contract DepositableStorage {

    using UnstructuredStorage for bytes32;

    bytes32 internal constant DEPOSITABLE_POSITION = 0x665fd576fbbe6f247aff98f5c94a561e3f71ec2d3c988d56f12d342396c50cea;

    function isDepositable() public view returns (bool) {

        return DEPOSITABLE_POSITION.getStorageBool();
    }

    function setDepositable(bool _depositable) internal {

        DEPOSITABLE_POSITION.setStorageBool(_depositable);
    }
}
contract DepositableDelegateProxy is DepositableStorage, DelegateProxy {

    event ProxyDeposit(address sender, uint256 value);

    function () external payable {
        if (gasleft() < FWD_GAS_LIMIT) {
            require(msg.value > 0 && msg.data.length == 0);
            require(isDepositable());
            emit ProxyDeposit(msg.sender, msg.value);
        } else { // all calls except for send or transfer
            address target = implementation();
            delegatedFwd(target, msg.data);
        }
    }
}
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
}
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
}
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
}
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
}
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

    modifier auth(bytes32 _role, uint256[] memory params) {

        bytes memory how;
        uint256 byteLength = params.length * 32;
        assembly {
            how := params
            mstore(how, byteLength)
        }

        require(hasPermission(msg.sender, address(this), _role, how), ERROR_AUTH_FAILED);
        _;
    }
}
contract KernelProxy is KernelStorage, KernelAppIds, KernelNamespaceConstants, IsContract, DepositableDelegateProxy {

    constructor(IKernel _kernelImpl) public {
        require(isContract(address(_kernelImpl)));
        apps[KERNEL_CORE_NAMESPACE][KERNEL_CORE_APP_ID] = _kernelImpl;
    }

    function proxyType() public pure returns (uint256 proxyTypeId) {

        return UPGRADEABLE;
    }

    function implementation() public view returns (address) {

        return apps[KERNEL_CORE_NAMESPACE][KERNEL_CORE_APP_ID];
    }
}

pragma solidity ^0.4.24;



contract Autopetrified is Petrifiable {

    constructor() public {
        petrify();
    }
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







contract EVMScriptRunner is AppStorage, Initializable, EVMScriptRegistryConstants, KernelNamespaceConstants {

    string private constant ERROR_EXECUTOR_UNAVAILABLE = "EVMRUN_EXECUTOR_UNAVAILABLE";
    string private constant ERROR_EXECUTION_REVERTED = "EVMRUN_EXECUTION_REVERTED";
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
        require(address(executor).delegatecall(data), ERROR_EXECUTION_REVERTED);

        bytes memory output = returnedDataDecoded();

        emit ScriptResult(address(executor), _script, _input, output);

        return output;
    }

    function returnedDataDecoded() internal pure returns (bytes ret) {

        assembly {
            let size := returndatasize
            switch size
            case 0 {}
            default {
                ret := mload(0x40) // free mem ptr get
                mstore(0x40, add(ret, add(size, 0x20))) // free mem ptr set
                returndatacopy(ret, 0x20, sub(size, 0x20)) // copy return data
            }
        }
        return ret;
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







contract AragonApp is AppStorage, Autopetrified, VaultRecoverable, EVMScriptRunner, ACLSyntaxSugar {

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

        bytes memory how;
        uint256 byteLength = _params.length * 32;
        assembly {
            how := _params
            mstore(how, byteLength)
        }
        return linkedKernel.hasPermission(_sender, address(this), _role, how);
    }

    function getRecoveryVault() public view returns (address) {

        return kernel().getRecoveryVault(); // if kernel is not set, it will revert
    }
}

pragma solidity ^0.4.24;


interface IACLOracle {

    function canPerform(address who, address where, bytes32 what, uint256[] how) external view returns (bool);

}
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

    uint256 internal constant ORACLE_CHECK_GAS = 30000;

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

        uint256[] memory how;
        uint256 intsLength = _how.length / 32;
        assembly {
            how := _how
            mstore(how, intsLength)
        }

        return hasPermission(_who, _where, _what, how);
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
        uint256 oracleCheckGas = ORACLE_CHECK_GAS;

        bool ok;
        assembly {
            ok := staticcall(oracleCheckGas, _oracleAddr, add(checkCalldata, 0x20), mload(checkCalldata), 0, 0)
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
contract EVMScriptRegistry is IEVMScriptRegistry, EVMScriptRegistryConstants, AragonApp {

    using ScriptHelpers for bytes;

    bytes32 public constant REGISTRY_ADD_EXECUTOR_ROLE = 0xc4e90f38eea8c4212a009ca7b8947943ba4d4a58d19b683417f65291d1cd9ed2;
    bytes32 public constant REGISTRY_MANAGER_ROLE = 0xf7a450ef335e1892cb42c8ca72e7242359d7711924b75db5717410da3f614aa3;

    string private constant ERROR_INEXISTENT_EXECUTOR = "EVMREG_INEXISTENT_EXECUTOR";
    string private constant ERROR_EXECUTOR_ENABLED = "EVMREG_EXECUTOR_ENABLED";
    string private constant ERROR_EXECUTOR_DISABLED = "EVMREG_EXECUTOR_DISABLED";

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

        uint256 id = _script.getSpecId();

        ExecutorEntry storage entry = executors[id];
        return entry.enabled ? entry.executor : IEVMScriptExecutor(0);
    }
}

pragma solidity ^0.4.24;




contract BaseEVMScriptExecutor is IEVMScriptExecutor, Autopetrified {

    uint256 internal constant SCRIPT_START_LOCATION = 4;
}




contract CallsScript is BaseEVMScriptExecutor {

    using ScriptHelpers for bytes;

    bytes32 internal constant EXECUTOR_TYPE = 0x2dc858a00f3e417be1394b87c07158e989ec681ce8cc68a9093680ac1a870302;

    string private constant ERROR_BLACKLISTED_CALL = "EVMCALLS_BLACKLISTED_CALL";
    string private constant ERROR_INVALID_LENGTH = "EVMCALLS_INVALID_LENGTH";
    string private constant ERROR_CALL_REVERTED = "EVMCALLS_CALL_REVERTED";

    event LogScriptCall(address indexed sender, address indexed src, address indexed dst);

    function execScript(bytes _script, bytes, address[] _blacklist) external isInitialized returns (bytes) {

        uint256 location = SCRIPT_START_LOCATION; // first 32 bits are spec id
        while (location < _script.length) {
            address contractAddress = _script.addressAt(location);
            for (uint i = 0; i < _blacklist.length; i++) {
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
                success := call(sub(gas, 5000), contractAddress, 0, calldataStart, calldataLength, 0, 0)
            }

            require(success, ERROR_CALL_REVERTED);
        }
    }

    function executorType() external pure returns (bytes32) {

        return EXECUTOR_TYPE;
    }
}
contract EVMScriptRegistryFactory is AppProxyFactory, EVMScriptRegistryConstants {

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
}
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
}


interface ITokenController {

    function proxyPayment(address _owner) external payable returns(bool);


    function onTransfer(address _from, address _to, uint _amount) external returns(bool);


    function onApprove(address _owner, address _spender, uint _amount) external returns(bool);

}



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
}
interface IPublicResolver {

    function supportsInterface(bytes4 interfaceID) constant returns (bool);

    function addr(bytes32 node) constant returns (address ret);

    function setAddr(bytes32 node, address addr);

    function hash(bytes32 node) constant returns (bytes32 ret);

    function setHash(bytes32 node, bytes32 hash);

}
interface IFIFSResolvingRegistrar {

    function register(bytes32 _subnode, address _owner) external;

    function registerWithResolver(bytes32 _subnode, address _owner, IPublicResolver _resolver) public;

}

pragma solidity ^0.4.24;


interface IForwarder {

    function isForwarder() external pure returns (bool);


    function canForward(address sender, bytes evmCallScript) public view returns (bool);


    function forward(bytes evmCallScript) public;

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
}

pragma solidity 0.4.24;







contract Voting is IForwarder, AragonApp {

    using SafeMath for uint256;
    using SafeMath64 for uint64;

    bytes32 public constant CREATE_VOTES_ROLE = keccak256("CREATE_VOTES_ROLE");
    bytes32 public constant MODIFY_SUPPORT_ROLE = keccak256("MODIFY_SUPPORT_ROLE");
    bytes32 public constant MODIFY_QUORUM_ROLE = keccak256("MODIFY_QUORUM_ROLE");

    uint64 public constant PCT_BASE = 10 ** 18; // 0% = 0; 1% = 10^16; 100% = 10^18

    string private constant ERROR_NO_VOTE = "VOTING_NO_VOTE";
    string private constant ERROR_INIT_PCTS = "VOTING_INIT_PCTS";
    string private constant ERROR_CHANGE_SUPPORT_PCTS = "VOTING_CHANGE_SUPPORT_PCTS";
    string private constant ERROR_CHANGE_QUORUM_PCTS = "VOTING_CHANGE_QUORUM_PCTS";
    string private constant ERROR_INIT_SUPPORT_TOO_BIG = "VOTING_INIT_SUPPORT_TOO_BIG";
    string private constant ERROR_CHANGE_SUPPORT_TOO_BIG = "VOTING_CHANGE_SUPP_TOO_BIG";
    string private constant ERROR_CAN_NOT_VOTE = "VOTING_CAN_NOT_VOTE";
    string private constant ERROR_CAN_NOT_EXECUTE = "VOTING_CAN_NOT_EXECUTE";
    string private constant ERROR_CAN_NOT_FORWARD = "VOTING_CAN_NOT_FORWARD";
    string private constant ERROR_NO_VOTING_POWER = "VOTING_NO_VOTING_POWER";

    enum VoterState { Absent, Yea, Nay }

    struct Vote {
        bool executed;
        uint64 startDate;
        uint64 snapshotBlock;
        uint64 supportRequiredPct;
        uint64 minAcceptQuorumPct;
        uint256 yea;
        uint256 nay;
        uint256 votingPower;
        bytes executionScript;
        mapping (address => VoterState) voters;
    }

    MiniMeToken public token;
    uint64 public supportRequiredPct;
    uint64 public minAcceptQuorumPct;
    uint64 public voteTime;

    mapping (uint256 => Vote) internal votes;
    uint256 public votesLength;

    event StartVote(uint256 indexed voteId, address indexed creator, string metadata);
    event CastVote(uint256 indexed voteId, address indexed voter, bool supports, uint256 stake);
    event ExecuteVote(uint256 indexed voteId);
    event ChangeSupportRequired(uint64 supportRequiredPct);
    event ChangeMinQuorum(uint64 minAcceptQuorumPct);

    modifier voteExists(uint256 _voteId) {

        require(_voteId < votesLength, ERROR_NO_VOTE);
        _;
    }

    function initialize(
        MiniMeToken _token,
        uint64 _supportRequiredPct,
        uint64 _minAcceptQuorumPct,
        uint64 _voteTime
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
        voteTime = _voteTime;
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

    function newVote(bytes _executionScript, string _metadata) external auth(CREATE_VOTES_ROLE) returns (uint256 voteId) {

        return _newVote(_executionScript, _metadata, true, true);
    }

    function newVote(bytes _executionScript, string _metadata, bool _castVote, bool _executesIfDecided)
        external
        auth(CREATE_VOTES_ROLE)
        returns (uint256 voteId)
    {

        return _newVote(_executionScript, _metadata, _castVote, _executesIfDecided);
    }

    function vote(uint256 _voteId, bool _supports, bool _executesIfDecided) external voteExists(_voteId) {

        require(canVote(_voteId, msg.sender), ERROR_CAN_NOT_VOTE);
        _vote(_voteId, _supports, msg.sender, _executesIfDecided);
    }

    function executeVote(uint256 _voteId) external voteExists(_voteId) {

        require(canExecute(_voteId), ERROR_CAN_NOT_EXECUTE);
        _executeVote(_voteId);
    }

    function isForwarder() public pure returns (bool) {

        return true;
    }

    function forward(bytes _evmScript) public {

        require(canForward(msg.sender, _evmScript), ERROR_CAN_NOT_FORWARD);
        _newVote(_evmScript, "", true, true);
    }

    function canForward(address _sender, bytes) public view returns (bool) {

        return canPerform(_sender, CREATE_VOTES_ROLE, arr());
    }

    function canVote(uint256 _voteId, address _voter) public view voteExists(_voteId) returns (bool) {

        Vote storage vote_ = votes[_voteId];

        return _isVoteOpen(vote_) && token.balanceOfAt(_voter, vote_.snapshotBlock) > 0;
    }

    function canExecute(uint256 _voteId) public view voteExists(_voteId) returns (bool) {

        Vote storage vote_ = votes[_voteId];

        if (vote_.executed) {
            return false;
        }

        if (_isValuePct(vote_.yea, vote_.votingPower, vote_.supportRequiredPct)) {
            return true;
        }

        uint256 totalVotes = vote_.yea.add(vote_.nay);

        if (_isVoteOpen(vote_)) {
            return false;
        }
        if (!_isValuePct(vote_.yea, totalVotes, vote_.supportRequiredPct)) {
            return false;
        }
        if (!_isValuePct(vote_.yea, vote_.votingPower, vote_.minAcceptQuorumPct)) {
            return false;
        }

        return true;
    }

    function getVote(uint256 _voteId)
        public
        view
        voteExists(_voteId)
        returns (
            bool open,
            bool executed,
            uint64 startDate,
            uint64 snapshotBlock,
            uint64 supportRequired,
            uint64 minAcceptQuorum,
            uint256 yea,
            uint256 nay,
            uint256 votingPower,
            bytes script
        )
    {

        Vote storage vote_ = votes[_voteId];

        open = _isVoteOpen(vote_);
        executed = vote_.executed;
        startDate = vote_.startDate;
        snapshotBlock = vote_.snapshotBlock;
        supportRequired = vote_.supportRequiredPct;
        minAcceptQuorum = vote_.minAcceptQuorumPct;
        yea = vote_.yea;
        nay = vote_.nay;
        votingPower = vote_.votingPower;
        script = vote_.executionScript;
    }

    function getVoterState(uint256 _voteId, address _voter) public view voteExists(_voteId) returns (VoterState) {

        return votes[_voteId].voters[_voter];
    }

    function _newVote(bytes _executionScript, string _metadata, bool _castVote, bool _executesIfDecided)
        internal
        returns (uint256 voteId)
    {

        uint256 votingPower = token.totalSupplyAt(vote_.snapshotBlock);
        require(votingPower > 0, ERROR_NO_VOTING_POWER);

        voteId = votesLength++;
        Vote storage vote_ = votes[voteId];
        vote_.startDate = getTimestamp64();
        vote_.snapshotBlock = getBlockNumber64() - 1; // avoid double voting in this very block
        vote_.supportRequiredPct = supportRequiredPct;
        vote_.minAcceptQuorumPct = minAcceptQuorumPct;
        vote_.votingPower = votingPower;
        vote_.executionScript = _executionScript;

        emit StartVote(voteId, msg.sender, _metadata);

        if (_castVote && canVote(voteId, msg.sender)) {
            _vote(voteId, true, msg.sender, _executesIfDecided);
        }
    }

    function _vote(
        uint256 _voteId,
        bool _supports,
        address _voter,
        bool _executesIfDecided
    ) internal
    {

        Vote storage vote_ = votes[_voteId];

        uint256 voterStake = token.balanceOfAt(_voter, vote_.snapshotBlock);
        VoterState state = vote_.voters[_voter];

        if (state == VoterState.Yea) {
            vote_.yea = vote_.yea.sub(voterStake);
        } else if (state == VoterState.Nay) {
            vote_.nay = vote_.nay.sub(voterStake);
        }

        if (_supports) {
            vote_.yea = vote_.yea.add(voterStake);
        } else {
            vote_.nay = vote_.nay.add(voterStake);
        }

        vote_.voters[_voter] = _supports ? VoterState.Yea : VoterState.Nay;

        emit CastVote(_voteId, _voter, _supports, voterStake);

        if (_executesIfDecided && canExecute(_voteId)) {
            _executeVote(_voteId);
        }
    }

    function _executeVote(uint256 _voteId) internal {

        Vote storage vote_ = votes[_voteId];

        vote_.executed = true;

        bytes memory input = new bytes(0); // TODO: Consider input for voting scripts
        runScript(vote_.executionScript, input, new address[](0));

        emit ExecuteVote(_voteId);
    }

    function _isVoteOpen(Vote storage vote_) internal view returns (bool) {

        return getTimestamp64() < vote_.startDate.add(voteTime) && !vote_.executed;
    }

    function _isValuePct(uint256 _value, uint256 _total, uint256 _pct) internal pure returns (bool) {

        if (_total == 0) {
            return false;
        }

        uint256 computedPct = _value.mul(PCT_BASE) / _total;
        return computedPct > _pct;
    }
}
contract Vault is EtherTokenConstant, AragonApp, DepositableStorage {

    bytes32 public constant TRANSFER_ROLE = keccak256("TRANSFER_ROLE");

    string private constant ERROR_DATA_NON_ZERO = "VAULT_DATA_NON_ZERO";
    string private constant ERROR_NOT_DEPOSITABLE = "VAULT_NOT_DEPOSITABLE";
    string private constant ERROR_DEPOSIT_VALUE_ZERO = "VAULT_DEPOSIT_VALUE_ZERO";
    string private constant ERROR_TRANSFER_VALUE_ZERO = "VAULT_TRANSFER_VALUE_ZERO";
    string private constant ERROR_SEND_REVERTED = "VAULT_SEND_REVERTED";
    string private constant ERROR_VALUE_MISMATCH = "VAULT_VALUE_MISMATCH";
    string private constant ERROR_TOKEN_TRANSFER_FROM_REVERTED = "VAULT_TOKEN_TRANSFER_FROM_REVERT";
    string private constant ERROR_TOKEN_TRANSFER_REVERTED = "VAULT_TOKEN_TRANSFER_REVERTED";

    event Transfer(address indexed token, address indexed to, uint256 amount);
    event Deposit(address indexed token, address indexed sender, uint256 amount);

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
            require(ERC20(_token).transfer(_to, _value), ERROR_TOKEN_TRANSFER_REVERTED);
        }

        emit Transfer(_token, _to, _value);
    }

    function balance(address _token) public view returns (uint256) {

        if (_token == ETH) {
            return address(this).balance;
        } else {
            return ERC20(_token).balanceOf(this);
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
            require(ERC20(_token).transferFrom(msg.sender, this, _value), ERROR_TOKEN_TRANSFER_FROM_REVERTED);
        }

        emit Deposit(_token, msg.sender, _value);
    }
}


pragma solidity 0.4.24;









contract TokenManager is ITokenController, IForwarder, AragonApp {

    using SafeMath for uint256;
    using Uint256Helpers for uint256;

    bytes32 public constant MINT_ROLE = keccak256("MINT_ROLE");
    bytes32 public constant ISSUE_ROLE = keccak256("ISSUE_ROLE");
    bytes32 public constant ASSIGN_ROLE = keccak256("ASSIGN_ROLE");
    bytes32 public constant REVOKE_VESTINGS_ROLE = keccak256("REVOKE_VESTINGS_ROLE");
    bytes32 public constant BURN_ROLE = keccak256("BURN_ROLE");

    uint256 public constant MAX_VESTINGS_PER_ADDRESS = 50;

    string private constant ERROR_NO_VESTING = "TM_NO_VESTING";
    string private constant ERROR_TOKEN_CONTROLLER = "TM_TOKEN_CONTROLLER";
    string private constant ERROR_MINT_BALANCE_INCREASE_NOT_ALLOWED = "TM_MINT_BAL_INC_NOT_ALLOWED";
    string private constant ERROR_ASSIGN_BALANCE_INCREASE_NOT_ALLOWED = "TM_ASSIGN_BAL_INC_NOT_ALLOWED";
    string private constant ERROR_TOO_MANY_VESTINGS = "TM_TOO_MANY_VESTINGS";
    string private constant ERROR_WRONG_CLIFF_DATE = "TM_WRONG_CLIFF_DATE";
    string private constant ERROR_VESTING_NOT_REVOKABLE = "TM_VESTING_NOT_REVOKABLE";
    string private constant ERROR_REVOKE_TRANSFER_FROM_REVERTED = "TM_REVOKE_TRANSFER_FROM_REVERTED";
    string private constant ERROR_ASSIGN_TRANSFER_FROM_REVERTED = "TM_ASSIGN_TRANSFER_FROM_REVERTED";
    string private constant ERROR_CAN_NOT_FORWARD = "TM_CAN_NOT_FORWARD";
    string private constant ERROR_ON_TRANSFER_WRONG_SENDER = "TM_TRANSFER_WRONG_SENDER";
    string private constant ERROR_PROXY_PAYMENT_WRONG_SENDER = "TM_PROXY_PAYMENT_WRONG_SENDER";

    struct TokenVesting {
        uint256 amount;
        uint64 start;
        uint64 cliff;
        uint64 vesting;
        bool revokable;
    }

    MiniMeToken public token;
    uint256 public maxAccountTokens;

    mapping (address => mapping (uint256 => TokenVesting)) internal vestings;
    mapping (address => uint256) public vestingsLengths;
    mapping (address => bool) public everHeld;

    event NewVesting(address indexed receiver, uint256 vestingId, uint256 amount);
    event RevokeVesting(address indexed receiver, uint256 vestingId, uint256 nonVestedAmount);

    modifier vestingExists(address _holder, uint256 _vestingId) {

        require(_vestingId < vestingsLengths[_holder], ERROR_NO_VESTING);
        _;
    }

    function initialize(
        MiniMeToken _token,
        bool _transferable,
        uint256 _maxAccountTokens
    )
        external
        onlyInit
    {

        initialized();

        require(_token.controller() == address(this), ERROR_TOKEN_CONTROLLER);

        token = _token;
        maxAccountTokens = _maxAccountTokens == 0 ? uint256(-1) : _maxAccountTokens;

        if (token.transfersEnabled() != _transferable) {
            token.enableTransfers(_transferable);
        }
    }

    function mint(address _receiver, uint256 _amount) external authP(MINT_ROLE, arr(_receiver, _amount)) {

        require(_isBalanceIncreaseAllowed(_receiver, _amount), ERROR_MINT_BALANCE_INCREASE_NOT_ALLOWED);
        _mint(_receiver, _amount);
    }

    function issue(uint256 _amount) external authP(ISSUE_ROLE, arr(_amount)) {

        _mint(address(this), _amount);
    }

    function assign(address _receiver, uint256 _amount) external authP(ASSIGN_ROLE, arr(_receiver, _amount)) {

        _assign(_receiver, _amount);
    }

    function burn(address _holder, uint256 _amount) external authP(BURN_ROLE, arr(_holder, _amount)) {

        token.destroyTokens(_holder, _amount);
    }

    function assignVested(
        address _receiver,
        uint256 _amount,
        uint64 _start,
        uint64 _cliff,
        uint64 _vested,
        bool _revokable
    )
        external
        authP(ASSIGN_ROLE, arr(_receiver, _amount))
        returns (uint256)
    {

        require(vestingsLengths[_receiver] < MAX_VESTINGS_PER_ADDRESS, ERROR_TOO_MANY_VESTINGS);

        require(_start <= _cliff && _cliff <= _vested, ERROR_WRONG_CLIFF_DATE);

        uint256 vestingId = vestingsLengths[_receiver]++;
        vestings[_receiver][vestingId] = TokenVesting(
            _amount,
            _start,
            _cliff,
            _vested,
            _revokable
        );

        _assign(_receiver, _amount);

        emit NewVesting(_receiver, vestingId, _amount);

        return vestingId;
    }

    function revokeVesting(address _holder, uint256 _vestingId)
        external
        authP(REVOKE_VESTINGS_ROLE, arr(_holder))
        vestingExists(_holder, _vestingId)
    {

        TokenVesting storage v = vestings[_holder][_vestingId];
        require(v.revokable, ERROR_VESTING_NOT_REVOKABLE);

        uint256 nonVested = _calculateNonVestedTokens(
            v.amount,
            getTimestamp64(),
            v.start,
            v.cliff,
            v.vesting
        );

        delete vestings[_holder][_vestingId];

        require(token.transferFrom(_holder, address(this), nonVested), ERROR_REVOKE_TRANSFER_FROM_REVERTED);

        emit RevokeVesting(_holder, _vestingId, nonVested);
    }

    function forward(bytes _evmScript) public {

        require(canForward(msg.sender, _evmScript), ERROR_CAN_NOT_FORWARD);
        bytes memory input = new bytes(0); // TODO: Consider input for this

        address[] memory blacklist = new address[](1);
        blacklist[0] = address(token);

        runScript(_evmScript, input, blacklist);
    }

    function isForwarder() public pure returns (bool) {

        return true;
    }

    function canForward(address _sender, bytes) public view returns (bool) {

        return hasInitialized() && token.balanceOf(_sender) > 0;
    }

    function getVesting(
        address _recipient,
        uint256 _vestingId
    )
        public
        view
        vestingExists(_recipient, _vestingId)
        returns (
            uint256 amount,
            uint64 start,
            uint64 cliff,
            uint64 vesting,
            bool revokable
        )
    {

        TokenVesting storage tokenVesting = vestings[_recipient][_vestingId];
        amount = tokenVesting.amount;
        start = tokenVesting.start;
        cliff = tokenVesting.cliff;
        vesting = tokenVesting.vesting;
        revokable = tokenVesting.revokable;
    }

    function onTransfer(address _from, address _to, uint _amount) public isInitialized returns (bool) {

        require(msg.sender == address(token), ERROR_ON_TRANSFER_WRONG_SENDER);

        bool includesTokenManager = _from == address(this) || _to == address(this);

        if (!includesTokenManager) {
            bool toCanReceive = _isBalanceIncreaseAllowed(_to, _amount);
            if (!toCanReceive || transferableBalance(_from, now) < _amount) {
                return false;
            }
        }

        return true;
    }

    function proxyPayment(address) public payable returns (bool) {

        require(msg.sender == address(token), ERROR_PROXY_PAYMENT_WRONG_SENDER);
        return false;
    }

    function onApprove(address, address, uint) public returns (bool) {

        return true;
    }

    function _isBalanceIncreaseAllowed(address _receiver, uint _inc) internal view returns (bool) {

        return token.balanceOf(_receiver).add(_inc) <= maxAccountTokens;
    }

    function spendableBalanceOf(address _holder) public view returns (uint256) {

        return transferableBalance(_holder, now);
    }

    function transferableBalance(address _holder, uint256 _time) public view returns (uint256) {

        uint256 vestingsCount = vestingsLengths[_holder];
        uint256 totalNonTransferable = 0;

        for (uint256 i = 0; i < vestingsCount; i++) {
            TokenVesting storage v = vestings[_holder][i];
            uint nonTransferable = _calculateNonVestedTokens(
                v.amount,
                _time.toUint64(),
                v.start,
                v.cliff,
                v.vesting
            );
            totalNonTransferable = totalNonTransferable.add(nonTransferable);
        }

        return token.balanceOf(_holder).sub(totalNonTransferable);
    }

    function allowRecoverability(address _token) public view returns (bool) {

        return _token != address(token);
    }

    function _calculateNonVestedTokens(
        uint256 tokens,
        uint256 time,
        uint256 start,
        uint256 cliff,
        uint256 vested
    )
        private
        pure
        returns (uint256)
    {

        if (time >= vested) {
            return 0;
        }
        if (time < cliff) {
            return tokens;
        }


        uint256 vestedTokens = tokens.mul(time.sub(start)) / vested.sub(start);

        return tokens.sub(vestedTokens);
    }

    function _assign(address _receiver, uint256 _amount) internal {

        require(_isBalanceIncreaseAllowed(_receiver, _amount), ERROR_ASSIGN_BALANCE_INCREASE_NOT_ALLOWED);
        require(token.transferFrom(this, _receiver, _amount), ERROR_ASSIGN_TRANSFER_FROM_REVERTED);
    }

    function _mint(address _receiver, uint256 _amount) internal {

        token.generateTokens(_receiver, _amount); // minime.generateTokens() never returns false
    }
}

pragma solidity 0.4.24;









contract Finance is EtherTokenConstant, IsContract, AragonApp {

    using SafeMath for uint256;
    using SafeMath64 for uint64;

    bytes32 public constant CREATE_PAYMENTS_ROLE = keccak256("CREATE_PAYMENTS_ROLE");
    bytes32 public constant CHANGE_PERIOD_ROLE = keccak256("CHANGE_PERIOD_ROLE");
    bytes32 public constant CHANGE_BUDGETS_ROLE = keccak256("CHANGE_BUDGETS_ROLE");
    bytes32 public constant EXECUTE_PAYMENTS_ROLE = keccak256("EXECUTE_PAYMENTS_ROLE");
    bytes32 public constant MANAGE_PAYMENTS_ROLE = keccak256("MANAGE_PAYMENTS_ROLE");

    uint256 internal constant NO_PAYMENT = 0;
    uint256 internal constant NO_TRANSACTION = 0;
    uint256 internal constant MAX_PAYMENTS_PER_TX = 20;
    uint256 internal constant MAX_UINT = uint256(-1);
    uint64 internal constant MAX_UINT64 = uint64(-1);

    string private constant ERROR_COMPLETE_TRANSITION = "FINANCE_COMPLETE_TRANSITION";
    string private constant ERROR_NO_PAYMENT = "FINANCE_NO_PAYMENT";
    string private constant ERROR_NO_TRANSACTION = "FINANCE_NO_TRANSACTION";
    string private constant ERROR_NO_PERIOD = "FINANCE_NO_PERIOD";
    string private constant ERROR_VAULT_NOT_CONTRACT = "FINANCE_VAULT_NOT_CONTRACT";
    string private constant ERROR_INIT_PERIOD_TOO_SHORT = "FINANCE_INIT_PERIOD_TOO_SHORT";
    string private constant ERROR_SET_PERIOD_TOO_SHORT = "FINANCE_SET_PERIOD_TOO_SHORT";
    string private constant ERROR_NEW_PAYMENT_AMOUNT_ZERO = "FINANCE_NEW_PAYMENT_AMOUNT_ZERO";
    string private constant ERROR_RECOVER_AMOUNT_ZERO = "FINANCE_RECOVER_AMOUNT_ZERO";
    string private constant ERROR_DEPOSIT_AMOUNT_ZERO = "FINANCE_DEPOSIT_AMOUNT_ZERO";
    string private constant ERROR_BUDGET = "FINANCE_BUDGET";
    string private constant ERROR_EXECUTE_PAYMENT_TIME = "FINANCE_EXECUTE_PAYMENT_TIME";
    string private constant ERROR_RECEIVER_EXECUTE_PAYMENT_TIME = "FINANCE_RCVR_EXEC_PAYMENT_TIME";
    string private constant ERROR_PAYMENT_RECEIVER = "FINANCE_PAYMENT_RECEIVER";
    string private constant ERROR_TOKEN_TRANSFER_FROM_REVERTED = "FINANCE_TKN_TRANSFER_FROM_REVERT";
    string private constant ERROR_VALUE_MISMATCH = "FINANCE_VALUE_MISMATCH";
    string private constant ERROR_PAYMENT_INACTIVE = "FINANCE_PAYMENT_INACTIVE";
    string private constant ERROR_REMAINING_BUDGET = "FINANCE_REMAINING_BUDGET";

    struct Payment {
        address token;
        address receiver;
        address createdBy;
        bool inactive;
        uint256 amount;
        uint64 initialPaymentTime;
        uint64 interval;
        uint64 maxRepeats;
        uint64 repeats;
    }

    struct Transaction {
        address token;
        address entity;
        bool isIncoming;
        uint256 amount;
        uint256 paymentId;
        uint64 paymentRepeatNumber;
        uint64 date;
        uint64 periodId;
    }

    struct TokenStatement {
        uint256 expenses;
        uint256 income;
    }

    struct Period {
        uint64 startTime;
        uint64 endTime;
        uint256 firstTransactionId;
        uint256 lastTransactionId;

        mapping (address => TokenStatement) tokenStatement;
    }

    struct Settings {
        uint64 periodDuration;
        mapping (address => uint256) budgets;
        mapping (address => bool) hasBudget;
    }

    Vault public vault;
    Settings internal settings;

    mapping (uint256 => Payment) internal payments;
    uint256 public paymentsNextIndex;

    mapping (uint256 => Transaction) internal transactions;
    uint256 public transactionsNextIndex;

    mapping (uint64 => Period) internal periods;
    uint64 public periodsLength;

    event NewPeriod(uint64 indexed periodId, uint64 periodStarts, uint64 periodEnds);
    event SetBudget(address indexed token, uint256 amount, bool hasBudget);
    event NewPayment(uint256 indexed paymentId, address indexed recipient, uint64 maxRepeats, string reference);
    event NewTransaction(uint256 indexed transactionId, bool incoming, address indexed entity, uint256 amount, string reference);
    event ChangePaymentState(uint256 indexed paymentId, bool inactive);
    event ChangePeriodDuration(uint64 newDuration);
    event PaymentFailure(uint256 paymentId);

    modifier transitionsPeriod {

        bool completeTransition = _tryTransitionAccountingPeriod(getMaxPeriodTransitions());
        require(completeTransition, ERROR_COMPLETE_TRANSITION);
        _;
    }

    modifier paymentExists(uint256 _paymentId) {

        require(_paymentId > 0 && _paymentId < paymentsNextIndex, ERROR_NO_PAYMENT);
        _;
    }

    modifier transactionExists(uint256 _transactionId) {

        require(_transactionId > 0 && _transactionId < transactionsNextIndex, ERROR_NO_TRANSACTION);
        _;
    }

    modifier periodExists(uint64 _periodId) {

        require(_periodId < periodsLength, ERROR_NO_PERIOD);
        _;
    }

    function () external payable isInitialized transitionsPeriod {
        _deposit(
            ETH,
            msg.value,
            "Ether transfer to Finance app",
            msg.sender,
            true
        );
    }

    function initialize(Vault _vault, uint64 _periodDuration) external onlyInit {

        initialized();

        require(isContract(_vault), ERROR_VAULT_NOT_CONTRACT);
        vault = _vault;

        require(_periodDuration >= 1 days, ERROR_INIT_PERIOD_TOO_SHORT);
        settings.periodDuration = _periodDuration;

        payments[0].inactive = true;
        paymentsNextIndex = 1;

        transactionsNextIndex = 1;

        _newPeriod(getTimestamp64());
    }

    function deposit(address _token, uint256 _amount, string _reference) external payable isInitialized transitionsPeriod {

        _deposit(
            _token,
            _amount,
            _reference,
            msg.sender,
            true
        );
    }

    function newPayment(
        address _token,
        address _receiver,
        uint256 _amount,
        uint64 _initialPaymentTime,
        uint64 _interval,
        uint64 _maxRepeats,
        string _reference
    )
        external
        authP(CREATE_PAYMENTS_ROLE, arr(_token, _receiver, _amount, _interval, _maxRepeats))
        transitionsPeriod
        returns (uint256 paymentId)
    {

        require(_amount > 0, ERROR_NEW_PAYMENT_AMOUNT_ZERO);

        if (_initialPaymentTime <= getTimestamp64() && _maxRepeats == 1) {
            _makePaymentTransaction(
                _token,
                _receiver,
                _amount,
                NO_PAYMENT,   // unrelated to any payment id; it isn't created
                0,   // also unrelated to any payment repeats
                _reference
            );
            return;
        }

        require(settings.budgets[_token] >= _amount || !settings.hasBudget[_token], ERROR_BUDGET);

        paymentId = paymentsNextIndex++;
        emit NewPayment(paymentId, _receiver, _maxRepeats, _reference);

        Payment storage payment = payments[paymentId];
        payment.token = _token;
        payment.receiver = _receiver;
        payment.amount = _amount;
        payment.initialPaymentTime = _initialPaymentTime;
        payment.interval = _interval;
        payment.maxRepeats = _maxRepeats;
        payment.createdBy = msg.sender;

        if (nextPaymentTime(paymentId) <= getTimestamp64()) {
            _executePayment(paymentId);
        }
    }

    function setPeriodDuration(uint64 _periodDuration)
        external
        authP(CHANGE_PERIOD_ROLE, arr(uint256(_periodDuration), uint256(settings.periodDuration)))
        transitionsPeriod
    {

        require(_periodDuration >= 1 days, ERROR_SET_PERIOD_TOO_SHORT);
        settings.periodDuration = _periodDuration;
        emit ChangePeriodDuration(_periodDuration);
    }

    function setBudget(
        address _token,
        uint256 _amount
    )
        external
        authP(CHANGE_BUDGETS_ROLE, arr(_token, _amount, settings.budgets[_token], settings.hasBudget[_token] ? 1 : 0))
        transitionsPeriod
    {

        settings.budgets[_token] = _amount;
        if (!settings.hasBudget[_token]) {
            settings.hasBudget[_token] = true;
        }
        emit SetBudget(_token, _amount, true);
    }

    function removeBudget(address _token)
        external
        authP(CHANGE_BUDGETS_ROLE, arr(_token, uint256(0), settings.budgets[_token], settings.hasBudget[_token] ? 1 : 0))
        transitionsPeriod
    {

        settings.budgets[_token] = 0;
        settings.hasBudget[_token] = false;
        emit SetBudget(_token, 0, false);
    }

    function executePayment(uint256 _paymentId)
        external
        authP(EXECUTE_PAYMENTS_ROLE, arr(_paymentId, payments[_paymentId].amount))
        paymentExists(_paymentId)
        transitionsPeriod
    {

        require(nextPaymentTime(_paymentId) <= getTimestamp64(), ERROR_EXECUTE_PAYMENT_TIME);

        _executePayment(_paymentId);
    }

    function receiverExecutePayment(uint256 _paymentId) external isInitialized paymentExists(_paymentId) transitionsPeriod {

        require(nextPaymentTime(_paymentId) <= getTimestamp64(), ERROR_RECEIVER_EXECUTE_PAYMENT_TIME);
        require(payments[_paymentId].receiver == msg.sender, ERROR_PAYMENT_RECEIVER);

        _executePayment(_paymentId);
    }

    function setPaymentStatus(uint256 _paymentId, bool _active)
        external
        authP(MANAGE_PAYMENTS_ROLE, arr(_paymentId, uint256(_active ? 1 : 0)))
        paymentExists(_paymentId)
    {

        payments[_paymentId].inactive = !_active;
        emit ChangePaymentState(_paymentId, _active);
    }

    function recoverToVault(address _token) public isInitialized transitionsPeriod {

        uint256 amount = _token == ETH ? address(this).balance : ERC20(_token).balanceOf(this);
        require(amount > 0, ERROR_RECOVER_AMOUNT_ZERO);

        _deposit(
            _token,
            amount,
            "Recover to Vault",
            this,
            false
        );
    }

    function tryTransitionAccountingPeriod(uint64 _maxTransitions) public isInitialized returns (bool success) {

        return _tryTransitionAccountingPeriod(_maxTransitions);
    }


    function allowRecoverability(address) public view returns (bool) {

        return !hasInitialized();
    }

    function getPayment(uint256 _paymentId)
        public
        view
        paymentExists(_paymentId)
        returns (
            address token,
            address receiver,
            uint256 amount,
            uint64 initialPaymentTime,
            uint64 interval,
            uint64 maxRepeats,
            bool inactive,
            uint64 repeats,
            address createdBy
        )
    {

        Payment storage payment = payments[_paymentId];

        token = payment.token;
        receiver = payment.receiver;
        amount = payment.amount;
        initialPaymentTime = payment.initialPaymentTime;
        interval = payment.interval;
        maxRepeats = payment.maxRepeats;
        repeats = payment.repeats;
        inactive = payment.inactive;
        createdBy = payment.createdBy;
    }

    function getTransaction(uint256 _transactionId)
        public
        view
        transactionExists(_transactionId)
        returns (
            uint64 periodId,
            uint256 amount,
            uint256 paymentId,
            uint64 paymentRepeatNumber,
            address token,
            address entity,
            bool isIncoming,
            uint64 date
        )
    {

        Transaction storage transaction = transactions[_transactionId];

        token = transaction.token;
        entity = transaction.entity;
        isIncoming = transaction.isIncoming;
        date = transaction.date;
        periodId = transaction.periodId;
        amount = transaction.amount;
        paymentId = transaction.paymentId;
        paymentRepeatNumber = transaction.paymentRepeatNumber;
    }

    function getPeriod(uint64 _periodId)
        public
        view
        periodExists(_periodId)
        returns (
            bool isCurrent,
            uint64 startTime,
            uint64 endTime,
            uint256 firstTransactionId,
            uint256 lastTransactionId
        )
    {

        Period storage period = periods[_periodId];

        isCurrent = _currentPeriodId() == _periodId;

        startTime = period.startTime;
        endTime = period.endTime;
        firstTransactionId = period.firstTransactionId;
        lastTransactionId = period.lastTransactionId;
    }

    function getPeriodTokenStatement(uint64 _periodId, address _token)
        public
        view
        periodExists(_periodId)
        returns (uint256 expenses, uint256 income)
    {

        TokenStatement storage tokenStatement = periods[_periodId].tokenStatement[_token];
        expenses = tokenStatement.expenses;
        income = tokenStatement.income;
    }

    function nextPaymentTime(uint256 _paymentId) public view paymentExists(_paymentId) returns (uint64) {

        Payment memory payment = payments[_paymentId];

        if (payment.repeats >= payment.maxRepeats) {
            return MAX_UINT64; // re-executes in some billions of years time... should not need to worry
        }

        uint64 increase = payment.repeats.mul(payment.interval);
        uint64 nextPayment = payment.initialPaymentTime.add(increase);
        return nextPayment;
    }

    function getPeriodDuration() public view returns (uint64) {

        return settings.periodDuration;
    }

    function getBudget(address _token) public view returns (uint256 budget, bool hasBudget) {

        budget = settings.budgets[_token];
        hasBudget = settings.hasBudget[_token];
    }

    function getRemainingBudget(address _token) public view isInitialized returns (uint256) {

        return _getRemainingBudget(_token);
    }

    function currentPeriodId() public view isInitialized returns (uint64) {

        return _currentPeriodId();
    }


    function _deposit(address _token, uint256 _amount, string _reference, address _sender, bool _isExternalDeposit) internal {

        require(_amount > 0, ERROR_DEPOSIT_AMOUNT_ZERO);
        _recordIncomingTransaction(
            _token,
            _sender,
            _amount,
            _reference
        );

        if (_isExternalDeposit) {
            if (_token != ETH) {
                require(ERC20(_token).transferFrom(msg.sender, this, _amount), ERROR_TOKEN_TRANSFER_FROM_REVERTED);
            } else {
                require(msg.value == _amount, ERROR_VALUE_MISMATCH);
            }
        }

        if (_token == ETH) {
            vault.deposit.value(_amount)(ETH, _amount);
        } else {
            ERC20(_token).approve(vault, _amount);
            vault.deposit(_token, _amount);
        }
    }

    function _newPeriod(uint64 _startTime) internal returns (Period storage) {

        uint64 newPeriodId = periodsLength++;

        Period storage period = periods[newPeriodId];
        period.startTime = _startTime;

        uint64 endTime = _startTime + settings.periodDuration - 1;
        if (endTime < _startTime) { // overflowed
            endTime = MAX_UINT64;
        }
        period.endTime = endTime;

        emit NewPeriod(newPeriodId, period.startTime, period.endTime);

        return period;
    }

    function _executePayment(uint256 _paymentId) internal {

        Payment storage payment = payments[_paymentId];
        require(!payment.inactive, ERROR_PAYMENT_INACTIVE);

        uint64 payed = 0;
        while (nextPaymentTime(_paymentId) <= getTimestamp64() && payed < MAX_PAYMENTS_PER_TX) {
            if (!_canMakePayment(payment.token, payment.amount)) {
                emit PaymentFailure(_paymentId);
                return;
            }

            payment.repeats += 1;
            payed += 1;

            _makePaymentTransaction(
                payment.token,
                payment.receiver,
                payment.amount,
                _paymentId,
                payment.repeats,
                ""
            );
        }
    }

    function _makePaymentTransaction(
        address _token,
        address _receiver,
        uint256 _amount,
        uint256 _paymentId,
        uint64 _paymentRepeatNumber,
        string _reference
    )
        internal
    {

        require(_getRemainingBudget(_token) >= _amount, ERROR_REMAINING_BUDGET);
        _recordTransaction(
            false,
            _token,
            _receiver,
            _amount,
            _paymentId,
            _paymentRepeatNumber,
            _reference
        );

        vault.transfer(_token, _receiver, _amount);
    }

    function _recordIncomingTransaction(
        address _token,
        address _sender,
        uint256 _amount,
        string _reference
    )
        internal
    {

        _recordTransaction(
            true, // incoming transaction
            _token,
            _sender,
            _amount,
            NO_PAYMENT, // unrelated to any existing payment
            0, // and no payment repeats
            _reference
        );
    }

    function _recordTransaction(
        bool _incoming,
        address _token,
        address _entity,
        uint256 _amount,
        uint256 _paymentId,
        uint64 _paymentRepeatNumber,
        string _reference
    )
        internal
    {

        uint64 periodId = _currentPeriodId();
        TokenStatement storage tokenStatement = periods[periodId].tokenStatement[_token];
        if (_incoming) {
            tokenStatement.income = tokenStatement.income.add(_amount);
        } else {
            tokenStatement.expenses = tokenStatement.expenses.add(_amount);
        }

        uint256 transactionId = transactionsNextIndex++;
        Transaction storage transaction = transactions[transactionId];
        transaction.token = _token;
        transaction.entity = _entity;
        transaction.isIncoming = _incoming;
        transaction.amount = _amount;
        transaction.paymentId = _paymentId;
        transaction.paymentRepeatNumber = _paymentRepeatNumber;
        transaction.date = getTimestamp64();
        transaction.periodId = periodId;

        Period storage period = periods[periodId];
        if (period.firstTransactionId == NO_TRANSACTION) {
            period.firstTransactionId = transactionId;
        }

        emit NewTransaction(transactionId, _incoming, _entity, _amount, _reference);
    }

    function _tryTransitionAccountingPeriod(uint256 _maxTransitions) internal returns (bool success) {

        Period storage currentPeriod = periods[_currentPeriodId()];
        uint64 timestamp = getTimestamp64();

        while (timestamp > currentPeriod.endTime) {
            if (_maxTransitions == 0) {
                return false;
            }
            _maxTransitions = _maxTransitions.sub(1);

            if (currentPeriod.firstTransactionId != NO_TRANSACTION) {
                currentPeriod.lastTransactionId = transactionsNextIndex.sub(1);
            }

            currentPeriod = _newPeriod(currentPeriod.endTime.add(1));
        }

        return true;
    }

    function _canMakePayment(address _token, uint256 _amount) internal view returns (bool) {

        return _getRemainingBudget(_token) >= _amount && vault.balance(_token) >= _amount;
    }

    function _getRemainingBudget(address _token) internal view returns (uint256) {

        if (!settings.hasBudget[_token]) {
            return MAX_UINT;
        }

        uint256 spent = periods[_currentPeriodId()].tokenStatement[_token].expenses;

        if (spent >= settings.budgets[_token]) {
            return 0;
        }

        return settings.budgets[_token].sub(spent);
    }

    function _currentPeriodId() internal view returns (uint64) {

        return periodsLength - 1;
    }

    function getMaxPeriodTransitions() internal view returns (uint64) { return MAX_UINT64; }

}
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
}
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
}
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
}
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
}
contract KitBase is EVMScriptRegistryConstants {

    ENS public ens;
    DAOFactory public fac;

    event DeployInstance(address dao);
    event InstalledApp(address appProxy, bytes32 appId);

    constructor (DAOFactory _fac, ENS _ens) {
        fac = _fac;
        ens = _ens;
    }

    function latestVersionAppBase(bytes32 appId) public view returns (address base) {

        Repo repo = Repo(PublicResolver(ens.resolver(appId)).addr(appId));
        (,base,) = repo.getLatest();

        return base;
    }

    function cleanupDAOPermissions(Kernel dao, ACL acl, address root) internal {

        cleanupPermission(acl, root, dao, dao.APP_MANAGER_ROLE());

        cleanupPermission(acl, root, acl, acl.CREATE_PERMISSIONS_ROLE());
    }

    function cleanupPermission(ACL acl, address root, address app, bytes32 permission) internal {

        acl.grantPermission(root, app, permission);
        acl.revokePermission(this, app, permission);
        acl.setPermissionManager(root, app, permission);
    }
}
contract BetaKitBase is KitBase, IsContract {

    MiniMeTokenFactory public minimeFac;
    IFIFSResolvingRegistrar public aragonID;
    bytes32[4] public appIds;

    mapping (address => address) tokenCache;

    enum Apps { Finance, TokenManager, Vault, Voting }

    event DeployToken(address token, address indexed cacheOwner);
    event DeployInstance(address dao, address indexed token);

    constructor(
        DAOFactory _fac,
        ENS _ens,
        MiniMeTokenFactory _minimeFac,
        IFIFSResolvingRegistrar _aragonID,
        bytes32[4] _appIds
    )
        KitBase(_fac, _ens)
        public
    {
        require(isContract(address(_fac.regFactory())));

        minimeFac = _minimeFac;
        aragonID = _aragonID;
        appIds = _appIds;
    }

    function createDAO(
        string name,
        MiniMeToken token,
        address[] holders,
        uint256[] stakes,
        uint256 _maxTokens
    )
        internal
        returns (
            Kernel dao,
            ACL acl,
            Finance finance,
            TokenManager tokenManager,
            Vault vault,
            Voting voting
        )
    {

        require(holders.length == stakes.length);

        dao = fac.newDAO(this);

        acl = ACL(dao.acl());

        acl.createPermission(this, dao, dao.APP_MANAGER_ROLE(), this);

        voting = Voting(
            dao.newAppInstance(
                appIds[uint8(Apps.Voting)],
                latestVersionAppBase(appIds[uint8(Apps.Voting)])
            )
        );
        emit InstalledApp(voting, appIds[uint8(Apps.Voting)]);

        vault = Vault(
            dao.newAppInstance(
                appIds[uint8(Apps.Vault)],
                latestVersionAppBase(appIds[uint8(Apps.Vault)]),
                new bytes(0),
                true
            )
        );
        emit InstalledApp(vault, appIds[uint8(Apps.Vault)]);

        finance = Finance(
            dao.newAppInstance(
                appIds[uint8(Apps.Finance)],
                latestVersionAppBase(appIds[uint8(Apps.Finance)])
            )
        );
        emit InstalledApp(finance, appIds[uint8(Apps.Finance)]);

        tokenManager = TokenManager(
            dao.newAppInstance(
                appIds[uint8(Apps.TokenManager)],
                latestVersionAppBase(appIds[uint8(Apps.TokenManager)])
            )
        );
        emit InstalledApp(tokenManager, appIds[uint8(Apps.TokenManager)]);

        token.changeController(tokenManager);

        acl.createPermission(voting, voting, voting.MODIFY_QUORUM_ROLE(), voting);

        acl.createPermission(finance, vault, vault.TRANSFER_ROLE(), voting);
        acl.createPermission(voting, finance, finance.CREATE_PAYMENTS_ROLE(), voting);
        acl.createPermission(voting, finance, finance.EXECUTE_PAYMENTS_ROLE(), voting);
        acl.createPermission(voting, finance, finance.MANAGE_PAYMENTS_ROLE(), voting);
        acl.createPermission(voting, tokenManager, tokenManager.ASSIGN_ROLE(), voting);
        acl.createPermission(voting, tokenManager, tokenManager.REVOKE_VESTINGS_ROLE(), voting);

        vault.initialize();
        finance.initialize(vault, 30 days);
        tokenManager.initialize(token, _maxTokens > 1, _maxTokens);

        acl.createPermission(this, tokenManager, tokenManager.MINT_ROLE(), this);

        for (uint256 i = 0; i < holders.length; i++) {
            tokenManager.mint(holders[i], stakes[i]);
        }

        EVMScriptRegistry reg = EVMScriptRegistry(acl.getEVMScriptRegistry());
        acl.createPermission(voting, reg, reg.REGISTRY_ADD_EXECUTOR_ROLE(), voting);
        acl.createPermission(voting, reg, reg.REGISTRY_MANAGER_ROLE(), voting);

        cleanupPermission(acl, voting, dao, dao.APP_MANAGER_ROLE());
        cleanupPermission(acl, voting, tokenManager, tokenManager.MINT_ROLE());

        registerAragonID(name, dao);
        emit DeployInstance(dao, token);

        return (dao, acl, finance, tokenManager, vault, voting);
    }

    function cacheToken(MiniMeToken token, address owner) internal {

        tokenCache[owner] = token;
        emit DeployToken(token, owner);
    }

    function popTokenCache(address owner) internal returns (MiniMeToken) {

        require(tokenCache[owner] != address(0));
        MiniMeToken token = MiniMeToken(tokenCache[owner]);
        delete tokenCache[owner];

        return token;
    }

    function registerAragonID(string name, address owner) internal {

        aragonID.register(keccak256(abi.encodePacked(name)), owner);
    }
}
contract MultisigKit is BetaKitBase {

    using Uint256Helpers for uint256;

    constructor(
        DAOFactory _fac,
        ENS _ens,
        MiniMeTokenFactory _minimeFac,
        IFIFSResolvingRegistrar _aragonID,
        bytes32[4] _appIds
    )
        BetaKitBase(_fac, _ens, _minimeFac, _aragonID, _appIds) public
    {}

    function newTokenAndInstance(
        string name,
        string symbol,
        address[] signers,
        uint256 neededSignatures
    ) public
    {

        newToken(name, symbol);
        newInstance(name, signers, neededSignatures);
    }

    function newToken(string name, string symbol) public returns (MiniMeToken token) {

        token = minimeFac.createCloneToken(
            MiniMeToken(address(0)),
            0,
            name,
            0,
            symbol,
            true
        );
        cacheToken(token, msg.sender);
    }

    function newInstance(string name, address[] signers, uint256 neededSignatures) public {

        require(signers.length > 0 && neededSignatures > 0);
        require(neededSignatures <= signers.length);

        uint256[] memory stakes = new uint256[](signers.length);

        for (uint256 i = 0; i < signers.length; i++) {
            stakes[i] = 1;
        }

        MiniMeToken token = popTokenCache(msg.sender);
        Kernel dao;
        ACL acl;
        TokenManager tokenManager;
        Voting voting;
        (dao, acl, , tokenManager, , voting) = createDAO(
            name,
            token,
            signers,
            stakes,
            1
        );

        uint256 multisigSupport = neededSignatures * 10 ** 18 / signers.length - 1;
        voting.initialize(
            token,
            multisigSupport.toUint64(),
            multisigSupport.toUint64(),
            1825 days // ~5 years
        );

        acl.createPermission(tokenManager, voting, voting.CREATE_VOTES_ROLE(), voting);

        acl.createPermission(voting, voting, voting.MODIFY_SUPPORT_ROLE(), voting);

        cleanupPermission(acl, voting, acl, acl.CREATE_PERMISSIONS_ROLE());
    }
}