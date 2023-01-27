

pragma solidity 0.4.24;


interface ILido {

    function stop() external;


    function resume() external;


    event Stopped();
    event Resumed();


    function setFee(uint16 _feeBasisPoints) external;


    function setFeeDistribution(
        uint16 _treasuryFeeBasisPoints,
        uint16 _insuranceFeeBasisPoints,
        uint16 _operatorsFeeBasisPoints)
        external;


    function getFee() external view returns (uint16 feeBasisPoints);


    function getFeeDistribution() external view returns (uint16 treasuryFeeBasisPoints, uint16 insuranceFeeBasisPoints,
                                                         uint16 operatorsFeeBasisPoints);


    event FeeSet(uint16 feeBasisPoints);

    event FeeDistributionSet(uint16 treasuryFeeBasisPoints, uint16 insuranceFeeBasisPoints, uint16 operatorsFeeBasisPoints);


    function setWithdrawalCredentials(bytes32 _withdrawalCredentials) external;


    function getWithdrawalCredentials() external view returns (bytes);



    event WithdrawalCredentialsSet(bytes32 withdrawalCredentials);


    function pushBeacon(uint256 _epoch, uint256 _eth2balance) external;




    function submit(address _referral) external payable returns (uint256 StETH);


    event Submitted(address indexed sender, uint256 amount, address referral);

    event Unbuffered(uint256 amount);

    function withdraw(uint256 _amount, bytes32 _pubkeyHash) external;


    event Withdrawal(address indexed sender, uint256 tokenAmount, uint256 sentFromBuffer,
                     bytes32 indexed pubkeyHash, uint256 etherAmount);



    function getTotalPooledEther() external view returns (uint256);


    function getBufferedEther() external view returns (uint256);


    function getBeaconStat() external view returns (uint256 depositedValidators, uint256 beaconValidators, uint256 beaconBalance);

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
}// SPDX-FileCopyrightText: 2020 Lido <[email protected]>


pragma solidity 0.4.24;


interface ILidoOracle {

    function addOracleMember(address _member) external;


    function removeOracleMember(address _member) external;


    function getOracleMembers() external view returns (address[]);


    function setQuorum(uint256 _quorum) external;


    function getQuorum() external view returns (uint256);


    event MemberAdded(address member);
    event MemberRemoved(address member);
    event QuorumChanged(uint256 quorum);

    function reportBeacon(uint256 _epochId, uint128 _beaconBalance, uint128 _beaconValidators) external;

}// SPDX-FileCopyrightText: 2020 Lido <[email protected]>


pragma solidity 0.4.24;



library Algorithm {

    using SafeMath for uint256;

    function mode(uint256[] data) internal pure returns (bool, uint256) {


        assert(0 != data.length);

        uint256[] memory dataValues = new uint256[](data.length);
        uint256[] memory dataValuesCounts = new uint256[](data.length);

        dataValues[0] = data[0];
        dataValuesCounts[0] = 1;
        uint256 dataValuesLength = 1;

        uint256 i = 0;
        uint256 j = 0;
        bool complete;
        for (i = 1; i < data.length; i++) {
            complete = true;
            for (j = 0; j < dataValuesLength; j++) {
                if (data[i] == dataValues[j]) {
                    dataValuesCounts[j]++;
                    complete = false;
                    break;
                }
            }
            if (complete) {
                dataValues[dataValuesLength] = data[i];
                dataValuesCounts[dataValuesLength]++;
                dataValuesLength++;
            }
        }

        uint256 mostFrequentValueIndex = 0;
        for (i = 1; i < dataValuesLength; i++) {
            if (dataValuesCounts[i] > dataValuesCounts[mostFrequentValueIndex])
                mostFrequentValueIndex = i;
        }

        for (i = 0; i < dataValuesLength; i++) {
            if ((i != mostFrequentValueIndex) && (dataValuesCounts[i] == dataValuesCounts[mostFrequentValueIndex]))
                return (false, 0);
        }

        return (true, dataValues[mostFrequentValueIndex]);
    }
}// SPDX-FileCopyrightText: 2020 Lido <[email protected]>


pragma solidity 0.4.24;


library BitOps {

    function getBit(uint256 _mask, uint256 _bitIndex) internal pure returns (bool) {

        require(_bitIndex < 256);
        return 0 != (_mask & (1 << _bitIndex));
    }

    function setBit(uint256 _mask, uint256 _bitIndex, bool bit) internal pure returns (uint256) {

        require(_bitIndex < 256);
        if (bit) {
            return _mask | (1 << _bitIndex);
        } else {
            return _mask & (~(1 << _bitIndex));
        }
    }

    function popcnt(uint256 _mask) internal pure returns (uint256) {

        uint256 result = 0;
        uint256 tmp_mask = _mask;
        for (uint256 i = 0; i < 256; ++i) {
            if (1 == tmp_mask & 1) {
                result++;
            }
            tmp_mask >>= 1;
        }

        assert(0 == tmp_mask);
        return result;
    }
}// SPDX-FileCopyrightText: 2020 Lido <[email protected]>


pragma solidity 0.4.24;





contract LidoOracle is ILidoOracle, AragonApp {

    using SafeMath for uint256;
    using SafeMath64 for uint64;
    using BitOps for uint256;

    struct BeaconSpec {
        uint64 epochsPerFrame;
        uint64 slotsPerEpoch;
        uint64 secondsPerSlot;
        uint64 genesisTime;
    }

    struct Report {
        uint128 beaconBalance;
        uint128 beaconValidators;
    }

    struct EpochData {
        uint256 reportsBitMask;
        mapping (uint256 => Report) reports;
    }

    bytes32 constant public MANAGE_MEMBERS = keccak256("MANAGE_MEMBERS");
    bytes32 constant public MANAGE_QUORUM = keccak256("MANAGE_QUORUM");
    bytes32 constant public SET_BEACON_SPEC = keccak256("SET_BEACON_SPEC");

    uint256 public constant MAX_MEMBERS = 256;

    uint256 internal constant MEMBER_NOT_FOUND = uint256(-1);

    address[] private members;
    bytes32 internal constant QUORUM_POSITION = keccak256("lido.LidoOracle.quorum");

    bytes32 internal constant LIDO_POSITION = keccak256("lido.LidoOracle.lido");

    bytes32 internal constant BEACON_SPEC_POSITION = keccak256("lido.LidoOracle.beaconSpec");

    bytes32 internal constant MIN_REPORTABLE_EPOCH_ID_POSITION = keccak256("lido.LidoOracle.minReportableEpochId");
    bytes32 internal constant LAST_REPORTED_EPOCH_ID_POSITION = keccak256("lido.LidoOracle.lastReportedEpochId");
    mapping(uint256 => EpochData) private gatheredEpochData;

    event Completed(
        uint256 epochId,
        uint128 beaconBalance,
        uint128 beaconValidators
    );

    function initialize(
        address _lido,
        uint64 _epochsPerFrame,
        uint64 _slotsPerEpoch,
        uint64 _secondsPerSlot,
        uint64 _genesisTime
    )
        public onlyInit
    {

        assert(1 == ((1 << (MAX_MEMBERS - 1)) >> (MAX_MEMBERS - 1)));  // static assert

        require(_epochsPerFrame > 0, "BAD_EPOCHS_PER_FRAME");
        require(_slotsPerEpoch > 0, "BAD_SLOTS_PER_EPOCH");
        require(_secondsPerSlot > 0, "BAD_SECONDS_PER_SLOT");
        require(_genesisTime > 0, "BAD_GENESIS_TIME");

        LIDO_POSITION.setStorageAddress(_lido);

        _setBeaconSpec(
            _epochsPerFrame,
            _slotsPerEpoch,
            _secondsPerSlot,
            _genesisTime
        );

        initialized();
    }

    function addOracleMember(address _member) external auth(MANAGE_MEMBERS) {

        require(members.length < MAX_MEMBERS, "TOO_MANY_MEMBERS");
        require(address(0) != _member, "BAD_ARGUMENT");
        require(MEMBER_NOT_FOUND == _getMemberId(_member), "MEMBER_EXISTS");

        members.push(_member);

        if (1 == members.length) {
            QUORUM_POSITION.setStorageUint256(1);
        }

        emit MemberAdded(_member);
        _assertInvariants();
    }

    function removeOracleMember(address _member) external auth(MANAGE_MEMBERS) {

        require(members.length > getQuorum(), "QUORUM_WONT_BE_MADE");

        uint256 index = _getMemberId(_member);
        require(index != MEMBER_NOT_FOUND, "MEMBER_NOT_FOUND");

        uint256 lastReportedEpochId = (
            LAST_REPORTED_EPOCH_ID_POSITION.getStorageUint256()
        );

        MIN_REPORTABLE_EPOCH_ID_POSITION.setStorageUint256(lastReportedEpochId);
        uint256 last = members.length.sub(1);

        uint256 bitMask = gatheredEpochData[lastReportedEpochId].reportsBitMask;
        if (index != last) {
            members[index] = members[last];
            bitMask = bitMask.setBit(index, bitMask.getBit(last));
        }
        bitMask = bitMask.setBit(last, false);
        gatheredEpochData[lastReportedEpochId].reportsBitMask = bitMask;

        members.length--;

        emit MemberRemoved(_member);
        _assertInvariants();
    }

    function setQuorum(uint256 _quorum) external auth(MANAGE_QUORUM) {

        require(members.length >= _quorum && 0 != _quorum, "QUORUM_WONT_BE_MADE");

        QUORUM_POSITION.setStorageUint256(_quorum);
        emit QuorumChanged(_quorum);

        uint256 minReportableEpochId = (
            MIN_REPORTABLE_EPOCH_ID_POSITION.getStorageUint256()
        );
        uint256 lastReportedEpochId = (
            LAST_REPORTED_EPOCH_ID_POSITION.getStorageUint256()
        );

        assert(lastReportedEpochId <= getCurrentEpochId());

        if (lastReportedEpochId > minReportableEpochId) {
            minReportableEpochId = lastReportedEpochId;
            _tryPush(lastReportedEpochId);
        }

        _assertInvariants();
    }

    function reportBeacon(uint256 _epochId, uint128 _beaconBalance, uint128 _beaconValidators) external {

        (uint256 startEpoch, uint256 endEpoch) = getCurrentReportableEpochs();
        require(_epochId >= startEpoch, "EPOCH_IS_TOO_OLD");
        require(_epochId <= endEpoch, "EPOCH_HAS_NOT_YET_BEGUN");

        address member = msg.sender;
        uint256 index = _getMemberId(member);
        require(index != MEMBER_NOT_FOUND, "MEMBER_NOT_FOUND");

        uint256 bitMask = gatheredEpochData[_epochId].reportsBitMask;
        require(!bitMask.getBit(index), "ALREADY_SUBMITTED");

        LAST_REPORTED_EPOCH_ID_POSITION.setStorageUint256(_epochId);

        gatheredEpochData[_epochId].reportsBitMask = bitMask.setBit(index, true);

        Report memory currentReport = Report(_beaconBalance, _beaconValidators);
        gatheredEpochData[_epochId].reports[index] = currentReport;

        _tryPush(_epochId);
    }

    function getCurrentFrame()
        external view
        returns (
            uint256 frameEpochId,
            uint256 frameStartTime,
            uint256 frameEndTime
        )
    {

        BeaconSpec memory beaconSpec = _getBeaconSpec();
        uint64 genesisTime = beaconSpec.genesisTime;
        uint64 epochsPerFrame = beaconSpec.epochsPerFrame;
        uint64 secondsPerEpoch = beaconSpec.secondsPerSlot.mul(beaconSpec.slotsPerEpoch);

        frameEpochId = getCurrentEpochId().div(epochsPerFrame).mul(epochsPerFrame);
        frameStartTime = frameEpochId.mul(secondsPerEpoch).add(genesisTime);

        uint256 nextFrameEpochId = frameEpochId.div(epochsPerFrame).add(1).mul(epochsPerFrame);
        frameEndTime = nextFrameEpochId.mul(secondsPerEpoch).add(genesisTime).sub(1);
    }

    function getOracleMembers() external view returns (address[]) {

        return members;
    }

    function getLido() public view returns (ILido) {

        return ILido(LIDO_POSITION.getStorageAddress());
    }

    function setBeaconSpec(
        uint64 _epochsPerFrame,
        uint64 _slotsPerEpoch,
        uint64 _secondsPerSlot,
        uint64 _genesisTime
    )
        public auth(SET_BEACON_SPEC)
    {

        require(_epochsPerFrame > 0, "BAD_EPOCHS_PER_FRAME");
        require(_slotsPerEpoch > 0, "BAD_SLOTS_PER_EPOCH");
        require(_secondsPerSlot > 0, "BAD_SECONDS_PER_SLOT");
        require(_genesisTime > 0, "BAD_GENESIS_TIME");

        _setBeaconSpec(
            _epochsPerFrame,
            _slotsPerEpoch,
            _secondsPerSlot,
            _genesisTime
        );
    }

    function getBeaconSpec()
        public
        view
        returns (
            uint64 epochsPerFrame,
            uint64 slotsPerEpoch,
            uint64 secondsPerSlot,
            uint64 genesisTime
        )
    {

        BeaconSpec memory beaconSpec = _getBeaconSpec();
        return (
            beaconSpec.epochsPerFrame,
            beaconSpec.slotsPerEpoch,
            beaconSpec.secondsPerSlot,
            beaconSpec.genesisTime
        );
    }

    function getQuorum() public view returns (uint256) {

        return QUORUM_POSITION.getStorageUint256();
    }

    function getCurrentEpochId() public view returns (uint256) {

        BeaconSpec memory beaconSpec = _getBeaconSpec();
        return (
            _getTime()
            .sub(beaconSpec.genesisTime)
            .div(beaconSpec.slotsPerEpoch)
            .div(beaconSpec.secondsPerSlot)
        );
    }

    function getCurrentReportableEpochs()
        public view
        returns (
            uint256 minReportableEpochId,
            uint256 maxReportableEpochId
        )
    {

        minReportableEpochId = (
            MIN_REPORTABLE_EPOCH_ID_POSITION.getStorageUint256()
        );
        return (minReportableEpochId, getCurrentEpochId());
    }

    function _setBeaconSpec(
        uint64 _epochsPerFrame,
        uint64 _slotsPerEpoch,
        uint64 _secondsPerSlot,
        uint64 _genesisTime
    )
        internal
    {

        uint256 data = (
            uint256(_epochsPerFrame) << 192 |
            uint256(_slotsPerEpoch) << 128 |
            uint256(_secondsPerSlot) << 64 |
            uint256(_genesisTime)
        );
        BEACON_SPEC_POSITION.setStorageUint256(data);
    }

    function _getBeaconSpec()
        internal
        view
        returns (BeaconSpec memory beaconSpec)
    {

        uint256 data = BEACON_SPEC_POSITION.getStorageUint256();
        beaconSpec.epochsPerFrame = uint64(data >> 192);
        beaconSpec.slotsPerEpoch = uint64(data >> 128);
        beaconSpec.secondsPerSlot = uint64(data >> 64);
        beaconSpec.genesisTime = uint64(data);
        return beaconSpec;
    }

    function _getQuorumReport(uint256 _epochId) internal view returns (bool isQuorum, Report memory modeReport) {

        uint256 mask = gatheredEpochData[_epochId].reportsBitMask;
        uint256 popcnt = mask.popcnt();
        if (popcnt < getQuorum())
            return (false, Report({beaconBalance: 0, beaconValidators: 0}));

        assert(0 != popcnt && popcnt <= members.length);

        uint256[] memory data = new uint256[](popcnt);
        uint256 i = 0;
        uint256 membersLength = members.length;
        for (uint256 index = 0; index < membersLength; ++index) {
            if (mask.getBit(index)) {
                data[i++] = reportToUint256(gatheredEpochData[_epochId].reports[index]);
            }
        }

        assert(i == data.length);

        (bool isUnimodal, uint256 mode) = Algorithm.mode(data);
        if (!isUnimodal)
            return (false, Report({beaconBalance: 0, beaconValidators: 0}));

        modeReport = uint256ToReport(mode);

        return (true, modeReport);
    }

    function _tryPush(uint256 _epochId) internal {

        (bool isQuorum, Report memory modeReport) = _getQuorumReport(_epochId);
        if (!isQuorum)
            return;

        BeaconSpec memory beaconSpec = _getBeaconSpec();
        MIN_REPORTABLE_EPOCH_ID_POSITION.setStorageUint256(
            _epochId
            .div(beaconSpec.epochsPerFrame)
            .add(1)
            .mul(beaconSpec.epochsPerFrame)
        );

        emit Completed(_epochId, modeReport.beaconBalance, modeReport.beaconValidators);

        ILido lido = getLido();
        if (address(0) != address(lido))
            lido.pushBeacon(modeReport.beaconValidators, modeReport.beaconBalance);
    }

    function reportToUint256(Report _report) internal pure returns (uint256) {

        return uint256(_report.beaconBalance) << 128 | uint256(_report.beaconValidators);
    }

    function uint256ToReport(uint256 _report) internal pure returns (Report) {

        Report memory report;
        report.beaconBalance = uint128(_report >> 128);
        report.beaconValidators = uint128(_report);
        return report;
    }

    function _getMemberId(address _member) internal view returns (uint256) {

        uint256 length = members.length;
        for (uint256 i = 0; i < length; ++i) {
            if (members[i] == _member) {
                return i;
            }
        }
        return MEMBER_NOT_FOUND;
    }

    function _getTime() internal view returns (uint256) {

        return block.timestamp;
    }

    function _assertInvariants() private view {

        uint256 quorum = getQuorum();
        assert(quorum != 0 && members.length >= quorum);
        assert(members.length <= MAX_MEMBERS);
    }
}