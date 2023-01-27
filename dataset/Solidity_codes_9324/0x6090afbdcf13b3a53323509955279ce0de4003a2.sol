
pragma solidity 0.6.8;

contract Initializable {

    mapping (string => uint256) public initBlocks;

    event Initialized(string indexed key);

    modifier onlyInit(string memory key) {

        require(initBlocks[key] == 0, "initializable: already initialized");
        initBlocks[key] = block.number;
        _;
        emit Initialized(key);
    }
}/*
 *    MIT
 */

pragma solidity ^0.6.8;

interface IACLOracle {

    function willPerform(bytes4 role, address who, bytes calldata data) external returns (bool allowed);

}/*
 *    MIT
 */

pragma solidity ^0.6.8;
pragma experimental ABIEncoderV2;



library ACLData {

    enum BulkOp { Grant, Revoke, Freeze }

    struct BulkItem {
        BulkOp op;
        bytes4 role;
        address who;
    }
}

contract ACL is Initializable {

    bytes4 public constant ROOT_ROLE =
        this.grant.selector
        ^ this.revoke.selector
        ^ this.freeze.selector
        ^ this.bulk.selector
    ;

    address internal constant ANY_ADDR = address(-1);

    address internal constant UNSET_ROLE = address(0);
    address internal constant FREEZE_FLAG = address(1); // Also used as "who"
    address internal constant ALLOW_FLAG = address(2);

    mapping (bytes4 => mapping (address => address)) public roles;

    event Granted(bytes4 indexed role, address indexed actor, address indexed who, IACLOracle oracle);
    event Revoked(bytes4 indexed role, address indexed actor, address indexed who);
    event Frozen(bytes4 indexed role, address indexed actor);

    modifier auth(bytes4 _role) {

        require(willPerform(_role, msg.sender, msg.data), "acl: auth");
        _;
    }

    modifier initACL(address _initialRoot) {

        if (initBlocks["acl"] == 0) {
            _initializeACL(_initialRoot);
        } else {
            require(roles[ROOT_ROLE][_initialRoot] == ALLOW_FLAG, "acl: initial root misaligned");
        }
        _;
    }

    constructor(address _initialRoot) public initACL(_initialRoot) { }

    function grant(bytes4 _role, address _who) external auth(ROOT_ROLE) {

        _grant(_role, _who);
    }

    function grantWithOracle(bytes4 _role, address _who, IACLOracle _oracle) external auth(ROOT_ROLE) {

        _grantWithOracle(_role, _who, _oracle);
    }

    function revoke(bytes4 _role, address _who) external auth(ROOT_ROLE) {

        _revoke(_role, _who);
    }

    function freeze(bytes4 _role) external auth(ROOT_ROLE) {

        _freeze(_role);
    }

    function bulk(ACLData.BulkItem[] calldata items) external auth(ROOT_ROLE) {

        for (uint256 i = 0; i < items.length; i++) {
            ACLData.BulkItem memory item = items[i];

            if (item.op == ACLData.BulkOp.Grant) _grant(item.role, item.who);
            else if (item.op == ACLData.BulkOp.Revoke) _revoke(item.role, item.who);
            else if (item.op == ACLData.BulkOp.Freeze) _freeze(item.role);
        }
    }

    function willPerform(bytes4 _role, address _who, bytes memory _data) internal returns (bool) {

        return _checkRole(_role, _who, _data) || _checkRole(_role, ANY_ADDR, _data);
    }

    function isFrozen(bytes4 _role) public view returns (bool) {

        return roles[_role][FREEZE_FLAG] == FREEZE_FLAG;
    }

    function _initializeACL(address _initialRoot) internal onlyInit("acl") {

        _grant(ROOT_ROLE, _initialRoot);
    }

    function _grant(bytes4 _role, address _who) internal {

        _grantWithOracle(_role, _who, IACLOracle(ALLOW_FLAG));
    }

    function _grantWithOracle(bytes4 _role, address _who, IACLOracle _oracle) internal {

        require(!isFrozen(_role), "acl: frozen");
        require(_who != FREEZE_FLAG, "acl: bad freeze");

        roles[_role][_who] = address(_oracle);
        emit Granted(_role, msg.sender, _who, _oracle);
    }

    function _revoke(bytes4 _role, address _who) internal {

        require(!isFrozen(_role), "acl: frozen");

        roles[_role][_who] = UNSET_ROLE;
        emit Revoked(_role, msg.sender, _who);
    }

    function _freeze(bytes4 _role) internal {

        require(!isFrozen(_role), "acl: frozen");

        roles[_role][FREEZE_FLAG] = FREEZE_FLAG;
        emit Frozen(_role, msg.sender);
    }

    function _checkRole(bytes4 _role, address _who, bytes memory _data) internal returns (bool) {

        address accessFlagOrAclOracle = roles[_role][_who];
        if (accessFlagOrAclOracle != UNSET_ROLE) {
            if (accessFlagOrAclOracle == ALLOW_FLAG) return true;

            try IACLOracle(accessFlagOrAclOracle).willPerform(_role, _who, _data) returns (bool allowed) {
                if (allowed) return true;
            } catch { }
        }

        return false;
    }
}/*
 *    MIT
 */

pragma solidity ^0.6.8;

abstract contract ERC165 {
    bytes4 internal constant ERC165_INTERFACE_ID = bytes4(0x01ffc9a7);

    function supportsInterface(bytes4 _interfaceId) virtual public view returns (bool) {

        return _interfaceId == ERC165_INTERFACE_ID;
    }
}/*
 *    MIT
 */

pragma solidity ^0.6.8;


contract AdaptiveERC165 is ERC165 {

    mapping (bytes4 => bool) internal standardSupported;
    mapping (bytes4 => bytes32) internal callbackMagicNumbers;

    bytes32 internal constant UNREGISTERED_CALLBACK = bytes32(0);

    event RegisteredStandard(bytes4 interfaceId);
    event RegisteredCallback(bytes4 sig, bytes4 magicNumber);
    event ReceivedCallback(bytes4 indexed sig, bytes data);

    function supportsInterface(bytes4 _interfaceId) override virtual public view returns (bool) {

        return standardSupported[_interfaceId] || super.supportsInterface(_interfaceId);
    }

    function _handleCallback(bytes4 _sig, bytes memory _data) internal {

        bytes32 magicNumber = callbackMagicNumbers[_sig];
        require(magicNumber != UNREGISTERED_CALLBACK, "adap-erc165: unknown callback");

        emit ReceivedCallback(_sig, _data);

        assembly {
            mstore(0x00, magicNumber)
            return(0x00, 0x20)
        }
    }

    function _registerStandardAndCallback(bytes4 _interfaceId, bytes4 _callbackSig, bytes4 _magicNumber) internal {

        _registerStandard(_interfaceId);
        _registerCallback(_callbackSig, _magicNumber);
    }

    function _registerStandard(bytes4 _interfaceId) internal {

        standardSupported[_interfaceId] = true;
        emit RegisteredStandard(_interfaceId);
    }

    function _registerCallback(bytes4 _callbackSig, bytes4 _magicNumber) internal {

        callbackMagicNumbers[_callbackSig] = _magicNumber;
        emit RegisteredCallback(_callbackSig, _magicNumber);
    }
}/*
 *    MIT
 */

pragma solidity ^0.6.8;

library AddressUtils {

    
    function toPayable(address addr) internal pure returns (address payable) {

        return address(bytes20(addr));
    }

    function isContract(address addr) internal view returns (bool result) {

        assembly {
            result := iszero(iszero(extcodesize(addr)))
        }
    }
}/*
 *    MIT
 */

pragma solidity ^0.6.8;

library BitmapLib {

    bytes32 constant internal empty = bytes32(0);

    function flip(bytes32 map, uint8 index) internal pure returns (bytes32) {

        return bytes32(uint256(map) ^ uint256(1) << index);
    }

    function get(bytes32 map, uint8 index) internal pure returns (bool) {

        return (uint256(map) >> index & 1) == 1;
    }
}/*
 *    MIT
 */

pragma solidity ^0.6.8;

interface ERC20 {

    function name() external view returns (string memory);


    function symbol() external view returns (string memory);


    function decimals() external view returns (uint8);



    function totalSupply() external view returns (uint256);


    function balanceOf(address _who) external view returns (uint256);


    function allowance(address _owner, address _spender) external view returns (uint256);


    function transfer(address _to, uint256 _value) external returns (bool);


    function approve(address _spender, uint256 _value) external returns (bool);


    function transferFrom(address _from, address _to, uint256 _value) external returns (bool);


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



pragma solidity ^0.6.8;



library SafeERC20 {

    using AddressUtils for address;

    function invokeAndCheckSuccess(address _addr, bytes memory _calldata)
        private
        returns (bool ret)
    {

        if (!_addr.isContract()) {
            return false;
        }

        assembly {
            let ptr := mload(0x40)    // free memory pointer

            let success := call(
                gas(),                // forward all
                _addr,                // address
                0,                    // no value
                add(_calldata, 0x20), // calldata start
                mload(_calldata),     // calldata length
                ptr,                  // write output over free memory
                0x20                  // uint256 return
            )

            if gt(success, 0) {
                switch returndatasize()

                case 0 {
                    ret := 1
                }

                case 0x20 {
                    ret := iszero(iszero(mload(ptr)))
                }

                default { }
            }
        }
    }

    function safeTransfer(ERC20 _token, address _to, uint256 _amount) internal returns (bool) {

        bytes memory transferCallData = abi.encodeWithSelector(
            _token.transfer.selector,
            _to,
            _amount
        );
        return invokeAndCheckSuccess(address(_token), transferCallData);
    }

    function safeTransferFrom(ERC20 _token, address _from, address _to, uint256 _amount) internal returns (bool) {

        bytes memory transferFromCallData = abi.encodeWithSelector(
            _token.transferFrom.selector,
            _from,
            _to,
            _amount
        );
        return invokeAndCheckSuccess(address(_token), transferFromCallData);
    }

    function safeApprove(ERC20 _token, address _spender, uint256 _amount) internal returns (bool) {

        bytes memory approveCallData = abi.encodeWithSelector(
            _token.approve.selector,
            _spender,
            _amount
        );
        return invokeAndCheckSuccess(address(_token), approveCallData);
    }
}/*
 *    MIT
 */


pragma solidity ^0.6.8;

library ERC1167ProxyFactory {

    function clone(address _implementation) internal returns (address cloneAddr) {

        bytes memory createData = generateCreateData(_implementation);

        assembly {
            cloneAddr := create(0, add(createData, 0x20), 55)
        }

        require(cloneAddr != address(0), "proxy-factory: bad create");
    }

    function clone(address _implementation, bytes memory _initData) internal returns (address cloneAddr) {

        cloneAddr = clone(_implementation);
        (bool ok, bytes memory ret) = cloneAddr.call(_initData);

        require(ok, _getRevertMsg(ret));
    }

    function clone2(address _implementation, bytes32 _salt) internal returns (address cloneAddr) {

        bytes memory createData = generateCreateData(_implementation);

        assembly {
            cloneAddr := create2(0, add(createData, 0x20), 55, _salt)
        }

        require(cloneAddr != address(0), "proxy-factory: bad create2");
    }

    function clone2(address _implementation, bytes32 _salt, bytes memory _initData) internal returns (address cloneAddr) {

        cloneAddr = clone2(_implementation, _salt);
        (bool ok, bytes memory ret) = cloneAddr.call(_initData);

        require(ok, _getRevertMsg(ret));
    }

    function generateCreateData(address _implementation) internal pure returns (bytes memory) {

        return abi.encodePacked(
            bytes10(0x3d602d80600a3d3981f3),
            bytes10(0x363d3d373d3d3d363d73),
            _implementation,
            bytes15(0x5af43d82803e903d91602b57fd5bf3)
        );
    }

    function _getRevertMsg(bytes memory _returnData) internal pure returns (string memory) {

        if (_returnData.length < 68) return '';

        assembly {
            _returnData := add(_returnData, 0x04) // Slice the sighash.
        }
        return abi.decode(_returnData, (string)); // All that remains is the revert string
    }
}/*
 *    MIT
 */

pragma solidity ^0.6.8;


library ERC3000Data {

    struct Container {
        Payload payload;
        Config config;
    }

    struct Payload {
        uint256 nonce;
        uint256 executionTime;
        address submitter;
        IERC3000Executor executor;
        Action[] actions;
        bytes32 allowFailuresMap;
        bytes proof;
    }

    struct Action {
        address to;
        uint256 value;
        bytes data;
    }

    struct Config {
        uint256 executionDelay; // how many seconds to wait before being able to call `execute`.
        Collateral scheduleDeposit; // fees for scheduling
        Collateral challengeDeposit; // fees for challenging
        address resolver;  // resolver that will rule the disputes
        bytes rules; // rules of how DAO should be managed
        uint256 maxCalldataSize; // max calldatasize for the schedule
    }

    struct Collateral {
        address token;
        uint256 amount;
    }

    function containerHash(bytes32 payloadHash, bytes32 configHash) internal view returns (bytes32) {

        uint chainId;
        assembly {
            chainId := chainid()
        }

        return keccak256(abi.encodePacked("erc3k-v1", address(this), chainId, payloadHash, configHash));
    }

    function hash(Container memory container) internal view returns (bytes32) {

        return containerHash(hash(container.payload), hash(container.config));
    }

    function hash(Payload memory payload) internal pure returns (bytes32) {

        return keccak256(
            abi.encode(
                payload.nonce,
                payload.executionTime,
                payload.submitter,
                payload.executor,
                keccak256(abi.encode(payload.actions)),
                payload.allowFailuresMap,
                keccak256(payload.proof)
            )
        );
    }

    function hash(Config memory config) internal pure returns (bytes32) {

        return keccak256(abi.encode(config));
    }
}/*
 *    MIT
 */

pragma solidity ^0.6.8;


abstract contract IERC3000Executor {
    bytes4 internal constant ERC3000_EXEC_INTERFACE_ID = this.exec.selector;

    function exec(ERC3000Data.Action[] memory actions, bytes32 allowFailuresMap, bytes32 memo) virtual public returns (bytes32 failureMap, bytes[] memory execResults);
    event Executed(address indexed actor, ERC3000Data.Action[] actions, bytes32 memo, bytes32 failureMap, bytes[] execResults);
}/*
 *    MIT
 */

pragma solidity ^0.6.8;


abstract contract IERC3000 {
    function schedule(ERC3000Data.Container memory container) virtual public returns (bytes32 containerHash);
    event Scheduled(bytes32 indexed containerHash, ERC3000Data.Payload payload);

    function execute(ERC3000Data.Container memory container) virtual public returns (bytes32 failureMap, bytes[] memory execResults);
    event Executed(bytes32 indexed containerHash, address indexed actor);

    function challenge(ERC3000Data.Container memory container, bytes memory reason) virtual public returns (uint256 resolverId);
    event Challenged(bytes32 indexed containerHash, address indexed actor, bytes reason, uint256 resolverId, ERC3000Data.Collateral collateral);

    function resolve(ERC3000Data.Container memory container, uint256 resolverId) virtual public returns (bytes32 failureMap, bytes[] memory execResults);
    event Resolved(bytes32 indexed containerHash, address indexed actor, bool approved);

    function veto(ERC3000Data.Container memory container, bytes memory reason) virtual public;
    event Vetoed(bytes32 indexed containerHash, address indexed actor, bytes reason);

    function configure(ERC3000Data.Config memory config) virtual public returns (bytes32 configHash);
    event Configured(bytes32 indexed configHash, address indexed actor, ERC3000Data.Config config);
}/*
 *    MIT
 */

pragma solidity ^0.6.8;

abstract contract ERC1271 {
    bytes4 constant internal MAGICVALUE = 0x1626ba7e;

    function isValidSignature(bytes32 _hash, bytes memory _signature) virtual public view returns (bytes4 magicValue);
}/*
 *    GPL-3.0
 */

pragma solidity 0.6.8;




contract Govern is IERC3000Executor, AdaptiveERC165, ERC1271, ACL {

    using BitmapLib for bytes32;
    using AddressUtils for address;
    using SafeERC20 for ERC20;

    string private constant ERROR_DEPOSIT_AMOUNT_ZERO = "GOVERN_DEPOSIT_AMOUNT_ZERO";
    string private constant ERROR_ETH_DEPOSIT_AMOUNT_MISMATCH = "GOVERN_ETH_DEPOSIT_AMOUNT_MISMATCH";
    string private constant ERROR_TOKEN_NOT_CONTRACT = "GOVERN_TOKEN_NOT_CONTRACT";
    string private constant ERROR_TOKEN_DEPOSIT_FAILED = "GOVERN_TOKEN_DEPOSIT_FAILED";
    string private constant ERROR_TOO_MANY_ACTIONS = "GOVERN_TOO_MANY_ACTIONS";
    string private constant ERROR_ACTION_CALL_FAILED = "GOVERN_ACTION_CALL_FAILED";
    string private constant ERROR_TOKEN_WITHDRAW_FAILED = "GOVERN_TOKEN_WITHDRAW_FAILED";
    string private constant ERROR_ETH_WITHDRAW_FAILED = "GOVERN_ETH_WITHDRAW_FAILED";

    bytes4 internal constant EXEC_ROLE = this.exec.selector;
    bytes4 internal constant WITHDRAW_ROLE = this.withdraw.selector;

    bytes4 internal constant REGISTER_STANDARD_ROLE = this.registerStandardAndCallback.selector;
    bytes4 internal constant SET_SIGNATURE_VALIDATOR_ROLE = this.setSignatureValidator.selector;
    uint256 internal constant MAX_ACTIONS = 256;

    ERC1271 signatureValidator;

    event ETHDeposited(address sender, uint256 amount);

    event Deposited(address indexed sender, address indexed token, uint256 amount, string _reference);
    event Withdrawn(address indexed token, address indexed to, address from, uint256 amount, string _reference);

    constructor(address _initialExecutor) ACL(address(this)) public {
        initialize(_initialExecutor);
    }

    function initialize(address _initialExecutor) public initACL(address(this)) onlyInit("govern") {

        _grant(EXEC_ROLE, address(_initialExecutor));
        _grant(WITHDRAW_ROLE, address(this));

        _freeze(WITHDRAW_ROLE);

        _grant(REGISTER_STANDARD_ROLE, address(this));
        _grant(SET_SIGNATURE_VALIDATOR_ROLE, address(this));

        _registerStandard(ERC3000_EXEC_INTERFACE_ID);
        _registerStandard(type(ERC1271).interfaceId);
    }

    receive () external payable {
        emit ETHDeposited(msg.sender, msg.value);
    }

    fallback () external {
        _handleCallback(msg.sig, msg.data); // WARN: does a low-level return, any code below would be unreacheable
    }

    function deposit(address _token, uint256 _amount, string calldata _reference) external payable {

        require(_amount > 0, ERROR_DEPOSIT_AMOUNT_ZERO);

        if (_token == address(0)) {
            require(msg.value == _amount, ERROR_ETH_DEPOSIT_AMOUNT_MISMATCH);
        } else {
            require(_token.isContract(), ERROR_TOKEN_NOT_CONTRACT);
            require(ERC20(_token).safeTransferFrom(msg.sender, address(this), _amount), ERROR_TOKEN_DEPOSIT_FAILED);
        }
        emit Deposited(msg.sender, _token, _amount, _reference);
    }

    function withdraw(address _token, address _from, address _to, uint256 _amount, string memory _reference) public auth(WITHDRAW_ROLE) {

        if (_token == address(0)) {
            (bool ok, ) = _to.call{value: _amount}("");
            require(ok, ERROR_ETH_WITHDRAW_FAILED);
        } else {
            require(ERC20(_token).safeTransfer(_to, _amount), ERROR_TOKEN_WITHDRAW_FAILED);
        }
        emit Withdrawn(_token, _to, _from, _amount, _reference);
    }

    function exec(ERC3000Data.Action[] memory actions, bytes32 allowFailuresMap, bytes32 memo) override public auth(EXEC_ROLE) returns (bytes32, bytes[] memory) {

        require(actions.length <= MAX_ACTIONS, ERROR_TOO_MANY_ACTIONS); // need to limit since we use 256-bit bitmaps

        bytes[] memory execResults = new bytes[](actions.length);
        bytes32 failureMap = BitmapLib.empty; // start with an empty bitmap

        for (uint256 i = 0; i < actions.length; i++) {
            (bool ok, bytes memory ret) = actions[i].to.call{value: actions[i].value}(actions[i].data);
            require(ok || allowFailuresMap.get(uint8(i)), ERROR_ACTION_CALL_FAILED);
            failureMap = ok ? failureMap : failureMap.flip(uint8(i));
            execResults[i] = ret;
        }

        emit Executed(msg.sender, actions, memo, failureMap, execResults);

        return (failureMap, execResults);
    }

    function registerStandardAndCallback(bytes4 _interfaceId, bytes4 _callbackSig, bytes4 _magicNumber) external auth(REGISTER_STANDARD_ROLE) {

        _registerStandardAndCallback(_interfaceId, _callbackSig, _magicNumber);
    }

    function setSignatureValidator(ERC1271 _signatureValidator) external auth(SET_SIGNATURE_VALIDATOR_ROLE) {

        signatureValidator = _signatureValidator;
    }

    function isValidSignature(bytes32 _hash, bytes memory _signature) override public view returns (bytes4) {

        if (address(signatureValidator) == address(0)) return bytes4(0); // invalid magic number
        return signatureValidator.isValidSignature(_hash, _signature); // forward call to set validation contract
    }
}/*
 *    GPL-3.0
 */

pragma solidity 0.6.8;


contract GovernFactory {

    using ERC1167ProxyFactory for address;
    using AddressUtils for address;
    
    address public base;

    constructor() public {
        setupBase();
    }

    function newGovern(IERC3000 _initialExecutor, bytes32 _salt) public returns (Govern govern) {

        if (_salt != bytes32(0)) {
            return Govern(base.clone2(_salt, abi.encodeWithSelector(govern.initialize.selector, _initialExecutor)).toPayable());
        } else {
            return new Govern(address(_initialExecutor));
        }
    }

    function setupBase() private {

        base = address(new Govern(address(2)));
    }
}