
pragma solidity >=0.6.2 <0.8.0;

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

pragma solidity >=0.6.0 <0.8.0;

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

pragma solidity >=0.6.0 <0.8.0;

abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}// MIT

pragma solidity >=0.6.0 <0.8.0;

abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor () internal {
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
}// MIT

pragma solidity >=0.6.0 <0.8.0;

library SafeMath {

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

pragma solidity >=0.6.0 <0.8.0;

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

pragma solidity >=0.6.2 <0.8.0;

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

pragma solidity >=0.6.0 <0.8.0;

interface IBeacon {

    function implementation() external view returns (address);

}// MIT

pragma solidity >=0.6.0 <0.8.0;


contract BeaconProxy is Proxy {

    bytes32 private constant _BEACON_SLOT = 0xa3f0ad74e5423aebfd80d3ef4346578335a9a72aeaee59ff6cb3582b35133d50;

    constructor(address beacon, bytes memory data) public payable {
        assert(_BEACON_SLOT == bytes32(uint256(keccak256("eip1967.proxy.beacon")) - 1));
        _setBeacon(beacon, data);
    }

    function _beacon() internal view virtual returns (address beacon) {

        bytes32 slot = _BEACON_SLOT;
        assembly {
            beacon := sload(slot)
        }
    }

    function _implementation() internal view virtual override returns (address) {

        return IBeacon(_beacon()).implementation();
    }

    function _setBeacon(address beacon, bytes memory data) internal virtual {

        require(
            Address.isContract(beacon),
            "BeaconProxy: beacon is not a contract"
        );
        require(
            Address.isContract(IBeacon(beacon).implementation()),
            "BeaconProxy: beacon implementation is not a contract"
        );
        bytes32 slot = _BEACON_SLOT;

        assembly {
            sstore(slot, beacon)
        }

        if (data.length > 0) {
            Address.functionDelegateCall(_implementation(), data, "BeaconProxy: function call failed");
        }
    }
}// MIT

pragma solidity >=0.6.0 <0.8.0;


contract UpgradeableProxy is Proxy {

    constructor(address _logic, bytes memory _data) public payable {
        assert(_IMPLEMENTATION_SLOT == bytes32(uint256(keccak256("eip1967.proxy.implementation")) - 1));
        _setImplementation(_logic);
        if(_data.length > 0) {
            Address.functionDelegateCall(_logic, _data);
        }
    }

    event Upgraded(address indexed implementation);

    bytes32 private constant _IMPLEMENTATION_SLOT = 0x360894a13ba1a3210667c828492db98dca3e2076cc3735a920a3ca505d382bbc;

    function _implementation() internal view virtual override returns (address impl) {

        bytes32 slot = _IMPLEMENTATION_SLOT;
        assembly {
            impl := sload(slot)
        }
    }

    function _upgradeTo(address newImplementation) internal virtual {

        _setImplementation(newImplementation);
        emit Upgraded(newImplementation);
    }

    function _setImplementation(address newImplementation) private {

        require(Address.isContract(newImplementation), "UpgradeableProxy: new implementation is not a contract");

        bytes32 slot = _IMPLEMENTATION_SLOT;

        assembly {
            sstore(slot, newImplementation)
        }
    }
}// MIT

pragma solidity >=0.6.0 <0.8.0;


contract TransparentUpgradeableProxy is UpgradeableProxy {

    constructor(address _logic, address admin_, bytes memory _data) public payable UpgradeableProxy(_logic, _data) {
        assert(_ADMIN_SLOT == bytes32(uint256(keccak256("eip1967.proxy.admin")) - 1));
        _setAdmin(admin_);
    }

    event AdminChanged(address previousAdmin, address newAdmin);

    bytes32 private constant _ADMIN_SLOT = 0xb53127684a568b3173ae13b9f8a6016e243e63b6e8ee1178d6a717850b5d6103;

    modifier ifAdmin() {

        if (msg.sender == _admin()) {
            _;
        } else {
            _fallback();
        }
    }

    function admin() external ifAdmin returns (address admin_) {

        admin_ = _admin();
    }

    function implementation() external ifAdmin returns (address implementation_) {

        implementation_ = _implementation();
    }

    function changeAdmin(address newAdmin) external virtual ifAdmin {

        require(newAdmin != address(0), "TransparentUpgradeableProxy: new admin is the zero address");
        emit AdminChanged(_admin(), newAdmin);
        _setAdmin(newAdmin);
    }

    function upgradeTo(address newImplementation) external virtual ifAdmin {

        _upgradeTo(newImplementation);
    }

    function upgradeToAndCall(address newImplementation, bytes calldata data) external payable virtual ifAdmin {

        _upgradeTo(newImplementation);
        Address.functionDelegateCall(newImplementation, data);
    }

    function _admin() internal view virtual returns (address adm) {

        bytes32 slot = _ADMIN_SLOT;
        assembly {
            adm := sload(slot)
        }
    }

    function _setAdmin(address newAdmin) private {

        bytes32 slot = _ADMIN_SLOT;

        assembly {
            sstore(slot, newAdmin)
        }
    }

    function _beforeFallback() internal virtual override {

        require(msg.sender != _admin(), "TransparentUpgradeableProxy: admin cannot fallback to proxy target");
        super._beforeFallback();
    }
}// MIT

pragma solidity >=0.6.0 <0.8.0;


contract ProxyAdmin is Ownable {


    function getProxyImplementation(TransparentUpgradeableProxy proxy) public view virtual returns (address) {

        (bool success, bytes memory returndata) = address(proxy).staticcall(hex"5c60da1b");
        require(success);
        return abi.decode(returndata, (address));
    }

    function getProxyAdmin(TransparentUpgradeableProxy proxy) public view virtual returns (address) {

        (bool success, bytes memory returndata) = address(proxy).staticcall(hex"f851a440");
        require(success);
        return abi.decode(returndata, (address));
    }

    function changeProxyAdmin(TransparentUpgradeableProxy proxy, address newAdmin) public virtual onlyOwner {

        proxy.changeAdmin(newAdmin);
    }

    function upgrade(TransparentUpgradeableProxy proxy, address implementation) public virtual onlyOwner {

        proxy.upgradeTo(implementation);
    }

    function upgradeAndCall(TransparentUpgradeableProxy proxy, address implementation, bytes memory data) public payable virtual onlyOwner {

        proxy.upgradeToAndCall{value: msg.value}(implementation, data);
    }
}// MIT

pragma solidity >=0.6.0 <0.8.0;


contract UpgradeableBeacon is IBeacon, Ownable {

    address private _implementation;

    event Upgraded(address indexed implementation);

    constructor(address implementation_) public {
        _setImplementation(implementation_);
    }

    function implementation() public view virtual override returns (address) {

        return _implementation;
    }

    function upgradeTo(address newImplementation) public virtual onlyOwner {

        _setImplementation(newImplementation);
        emit Upgraded(newImplementation);
    }

    function _setImplementation(address newImplementation) private {

        require(Address.isContract(newImplementation), "UpgradeableBeacon: implementation is not a contract");
        _implementation = newImplementation;
    }
}// MIT

pragma solidity >=0.6.0 <0.8.0;

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

pragma solidity >=0.6.0 <0.8.0;


abstract contract Pausable is Context {
    event Paused(address account);

    event Unpaused(address account);

    bool private _paused;

    constructor () internal {
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
}// Apache-2.0


pragma solidity ^0.6.11;

library Value {

    uint8 internal constant INT_TYPECODE = 0;
    uint8 internal constant CODE_POINT_TYPECODE = 1;
    uint8 internal constant HASH_PRE_IMAGE_TYPECODE = 2;
    uint8 internal constant TUPLE_TYPECODE = 3;
    uint8 internal constant BUFFER_TYPECODE = TUPLE_TYPECODE + 9;
    uint8 internal constant VALUE_TYPE_COUNT = TUPLE_TYPECODE + 10;

    uint8 internal constant HASH_ONLY = 100;

    struct CodePoint {
        uint8 opcode;
        bytes32 nextCodePoint;
        Data[] immediate;
    }

    struct Data {
        uint256 intVal;
        CodePoint cpVal;
        Data[] tupleVal;
        bytes32 bufferHash;
        uint8 typeCode;
        uint256 size;
    }

    function tupleTypeCode() internal pure returns (uint8) {

        return TUPLE_TYPECODE;
    }

    function tuplePreImageTypeCode() internal pure returns (uint8) {

        return HASH_PRE_IMAGE_TYPECODE;
    }

    function intTypeCode() internal pure returns (uint8) {

        return INT_TYPECODE;
    }

    function bufferTypeCode() internal pure returns (uint8) {

        return BUFFER_TYPECODE;
    }

    function codePointTypeCode() internal pure returns (uint8) {

        return CODE_POINT_TYPECODE;
    }

    function valueTypeCode() internal pure returns (uint8) {

        return VALUE_TYPE_COUNT;
    }

    function hashOnlyTypeCode() internal pure returns (uint8) {

        return HASH_ONLY;
    }

    function isValidTupleSize(uint256 size) internal pure returns (bool) {

        return size <= 8;
    }

    function typeCodeVal(Data memory val) internal pure returns (Data memory) {

        if (val.typeCode == 2) {
            return newInt(TUPLE_TYPECODE);
        }
        return newInt(val.typeCode);
    }

    function valLength(Data memory val) internal pure returns (uint8) {

        if (val.typeCode == TUPLE_TYPECODE) {
            return uint8(val.tupleVal.length);
        } else {
            return 1;
        }
    }

    function isInt(Data memory val) internal pure returns (bool) {

        return val.typeCode == INT_TYPECODE;
    }

    function isInt64(Data memory val) internal pure returns (bool) {

        return val.typeCode == INT_TYPECODE && val.intVal < (1 << 64);
    }

    function isCodePoint(Data memory val) internal pure returns (bool) {

        return val.typeCode == CODE_POINT_TYPECODE;
    }

    function isTuple(Data memory val) internal pure returns (bool) {

        return val.typeCode == TUPLE_TYPECODE;
    }

    function isBuffer(Data memory val) internal pure returns (bool) {

        return val.typeCode == BUFFER_TYPECODE;
    }

    function newEmptyTuple() internal pure returns (Data memory) {

        return newTuple(new Data[](0));
    }

    function newBoolean(bool val) internal pure returns (Data memory) {

        if (val) {
            return newInt(1);
        } else {
            return newInt(0);
        }
    }

    function newInt(uint256 _val) internal pure returns (Data memory) {

        return
            Data(_val, CodePoint(0, 0, new Data[](0)), new Data[](0), 0, INT_TYPECODE, uint256(1));
    }

    function newHashedValue(bytes32 valueHash, uint256 valueSize)
        internal
        pure
        returns (Data memory)
    {

        return
            Data(
                uint256(valueHash),
                CodePoint(0, 0, new Data[](0)),
                new Data[](0),
                0,
                HASH_ONLY,
                valueSize
            );
    }

    function newTuple(Data[] memory _val) internal pure returns (Data memory) {

        require(isValidTupleSize(_val.length), "Tuple must have valid size");
        uint256 size = 1;

        for (uint256 i = 0; i < _val.length; i++) {
            size += _val[i].size;
        }

        return Data(0, CodePoint(0, 0, new Data[](0)), _val, 0, TUPLE_TYPECODE, size);
    }

    function newTuplePreImage(bytes32 preImageHash, uint256 size)
        internal
        pure
        returns (Data memory)
    {

        return
            Data(
                uint256(preImageHash),
                CodePoint(0, 0, new Data[](0)),
                new Data[](0),
                0,
                HASH_PRE_IMAGE_TYPECODE,
                size
            );
    }

    function newCodePoint(uint8 opCode, bytes32 nextHash) internal pure returns (Data memory) {

        return newCodePoint(CodePoint(opCode, nextHash, new Data[](0)));
    }

    function newCodePoint(
        uint8 opCode,
        bytes32 nextHash,
        Data memory immediate
    ) internal pure returns (Data memory) {

        Data[] memory imm = new Data[](1);
        imm[0] = immediate;
        return newCodePoint(CodePoint(opCode, nextHash, imm));
    }

    function newCodePoint(CodePoint memory _val) private pure returns (Data memory) {

        return Data(0, _val, new Data[](0), 0, CODE_POINT_TYPECODE, uint256(1));
    }

    function newBuffer(bytes32 bufHash) internal pure returns (Data memory) {

        return
            Data(
                uint256(0),
                CodePoint(0, 0, new Data[](0)),
                new Data[](0),
                bufHash,
                BUFFER_TYPECODE,
                uint256(1)
            );
    }
}// Apache-2.0


pragma solidity ^0.6.11;


library Hashing {

    using Hashing for Value.Data;
    using Value for Value.CodePoint;

    function keccak1(bytes32 b) internal pure returns (bytes32) {

        return keccak256(abi.encodePacked(b));
    }

    function keccak2(bytes32 a, bytes32 b) internal pure returns (bytes32) {

        return keccak256(abi.encodePacked(a, b));
    }

    function bytes32FromArray(
        bytes memory arr,
        uint256 offset,
        uint256 arrLength
    ) internal pure returns (uint256) {

        uint256 res = 0;
        for (uint256 i = 0; i < 32; i++) {
            res = res << 8;
            bytes1 b = arrLength > offset + i ? arr[offset + i] : bytes1(0);
            res = res | uint256(uint8(b));
        }
        return res;
    }

    function merkleRoot(
        bytes memory data,
        uint256 rawDataLength,
        uint256 startOffset,
        uint256 dataLength,
        bool pack
    ) internal pure returns (bytes32, bool) {

        if (dataLength <= 32) {
            if (startOffset >= rawDataLength) {
                return (keccak1(bytes32(0)), true);
            }
            bytes32 res = keccak1(bytes32(bytes32FromArray(data, startOffset, rawDataLength)));
            return (res, res == keccak1(bytes32(0)));
        }
        (bytes32 h2, bool zero2) =
            merkleRoot(data, rawDataLength, startOffset + dataLength / 2, dataLength / 2, false);
        if (zero2 && pack) {
            return merkleRoot(data, rawDataLength, startOffset, dataLength / 2, pack);
        }
        (bytes32 h1, bool zero1) =
            merkleRoot(data, rawDataLength, startOffset, dataLength / 2, false);
        return (keccak2(h1, h2), zero1 && zero2);
    }

    function roundUpToPow2(uint256 len) internal pure returns (uint256) {

        if (len <= 1) return 1;
        else return 2 * roundUpToPow2((len + 1) / 2);
    }

    function bytesToBufferHash(
        bytes memory buf,
        uint256 startOffset,
        uint256 length
    ) internal pure returns (bytes32) {

        (bytes32 mhash, ) =
            merkleRoot(buf, startOffset + length, startOffset, roundUpToPow2(length), true);
        return keccak2(bytes32(uint256(123)), mhash);
    }

    function hashInt(uint256 val) internal pure returns (bytes32) {

        return keccak256(abi.encodePacked(val));
    }

    function hashCodePoint(Value.CodePoint memory cp) internal pure returns (bytes32) {

        assert(cp.immediate.length < 2);
        if (cp.immediate.length == 0) {
            return
                keccak256(abi.encodePacked(Value.codePointTypeCode(), cp.opcode, cp.nextCodePoint));
        }
        return
            keccak256(
                abi.encodePacked(
                    Value.codePointTypeCode(),
                    cp.opcode,
                    cp.immediate[0].hash(),
                    cp.nextCodePoint
                )
            );
    }

    function hashTuplePreImage(bytes32 innerHash, uint256 valueSize)
        internal
        pure
        returns (bytes32)
    {

        return keccak256(abi.encodePacked(uint8(Value.tupleTypeCode()), innerHash, valueSize));
    }

    function hash(Value.Data memory val) internal pure returns (bytes32) {

        if (val.typeCode == Value.intTypeCode()) {
            return hashInt(val.intVal);
        } else if (val.typeCode == Value.codePointTypeCode()) {
            return hashCodePoint(val.cpVal);
        } else if (val.typeCode == Value.tuplePreImageTypeCode()) {
            return hashTuplePreImage(bytes32(val.intVal), val.size);
        } else if (val.typeCode == Value.tupleTypeCode()) {
            Value.Data memory preImage = getTuplePreImage(val.tupleVal);
            return preImage.hash();
        } else if (val.typeCode == Value.hashOnlyTypeCode()) {
            return bytes32(val.intVal);
        } else if (val.typeCode == Value.bufferTypeCode()) {
            return keccak256(abi.encodePacked(uint256(123), val.bufferHash));
        } else {
            require(false, "Invalid type code");
        }
    }

    function getTuplePreImage(Value.Data[] memory vals) internal pure returns (Value.Data memory) {

        require(vals.length <= 8, "Invalid tuple length");
        bytes32[] memory hashes = new bytes32[](vals.length);
        uint256 hashCount = hashes.length;
        uint256 size = 1;
        for (uint256 i = 0; i < hashCount; i++) {
            hashes[i] = vals[i].hash();
            size += vals[i].size;
        }
        bytes32 firstHash = keccak256(abi.encodePacked(uint8(hashes.length), hashes));
        return Value.newTuplePreImage(firstHash, size);
    }
}// Apache-2.0


pragma solidity ^0.6.11;

interface IBridge {

    event MessageDelivered(
        uint256 indexed messageIndex,
        bytes32 indexed beforeInboxAcc,
        address inbox,
        uint8 kind,
        address sender,
        bytes32 messageDataHash
    );

    function deliverMessageToInbox(
        uint8 kind,
        address sender,
        bytes32 messageDataHash
    ) external payable returns (uint256);


    function executeCall(
        address destAddr,
        uint256 amount,
        bytes calldata data
    ) external returns (bool success, bytes memory returnData);


    function setInbox(address inbox, bool enabled) external;


    function setOutbox(address inbox, bool enabled) external;



    function activeOutbox() external view returns (address);


    function allowedInboxes(address inbox) external view returns (bool);


    function allowedOutboxes(address outbox) external view returns (bool);


    function inboxAccs(uint256 index) external view returns (bytes32);


    function messageCount() external view returns (uint256);

}// Apache-2.0


pragma solidity ^0.6.11;

interface ISequencerInbox {

    event SequencerBatchDelivered(
        uint256 indexed firstMessageNum,
        bytes32 indexed beforeAcc,
        uint256 newMessageCount,
        bytes32 afterAcc,
        bytes transactions,
        uint256[] lengths,
        uint256[] sectionsMetadata,
        uint256 seqBatchIndex,
        address sequencer
    );

    event SequencerBatchDeliveredFromOrigin(
        uint256 indexed firstMessageNum,
        bytes32 indexed beforeAcc,
        uint256 newMessageCount,
        bytes32 afterAcc,
        uint256 seqBatchIndex
    );

    event DelayedInboxForced(
        uint256 indexed firstMessageNum,
        bytes32 indexed beforeAcc,
        uint256 newMessageCount,
        uint256 totalDelayedMessagesRead,
        bytes32[2] afterAccAndDelayed,
        uint256 seqBatchIndex
    );

    event SequencerAddressUpdated(address newAddress);

    function setSequencer(address newSequencer) external;


    function messageCount() external view returns (uint256);


    function maxDelayBlocks() external view returns (uint256);


    function maxDelaySeconds() external view returns (uint256);


    function inboxAccs(uint256 index) external view returns (bytes32);


    function proveBatchContainsSequenceNumber(bytes calldata proof, uint256 inboxCount)
        external
        view
        returns (uint256, bytes32);

}// Apache-2.0


pragma solidity ^0.6.11;


interface IOneStepProof {

    function executeStep(
        address[2] calldata bridges,
        uint256 initialMessagesRead,
        bytes32[2] calldata accs,
        bytes calldata proof,
        bytes calldata bproof
    )
        external
        view
        returns (
            uint64 gas,
            uint256 afterMessagesRead,
            bytes32[4] memory fields
        );


    function executeStepDebug(
        address[2] calldata bridges,
        uint256 initialMessagesRead,
        bytes32[2] calldata accs,
        bytes calldata proof,
        bytes calldata bproof
    ) external view returns (string memory startMachine, string memory afterMachine);

}// MIT


pragma solidity ^0.6.11;

library BytesLib {

    function toAddress(bytes memory _bytes, uint256 _start) internal pure returns (address) {

        require(_bytes.length >= (_start + 20), "Read out of bounds");
        address tempAddress;

        assembly {
            tempAddress := div(mload(add(add(_bytes, 0x20), _start)), 0x1000000000000000000000000)
        }

        return tempAddress;
    }

    function toUint8(bytes memory _bytes, uint256 _start) internal pure returns (uint8) {

        require(_bytes.length >= (_start + 1), "Read out of bounds");
        uint8 tempUint;

        assembly {
            tempUint := mload(add(add(_bytes, 0x1), _start))
        }

        return tempUint;
    }

    function toUint(bytes memory _bytes, uint256 _start) internal pure returns (uint256) {

        require(_bytes.length >= (_start + 32), "Read out of bounds");
        uint256 tempUint;

        assembly {
            tempUint := mload(add(add(_bytes, 0x20), _start))
        }

        return tempUint;
    }

    function toBytes32(bytes memory _bytes, uint256 _start) internal pure returns (bytes32) {

        require(_bytes.length >= (_start + 32), "Read out of bounds");
        bytes32 tempBytes32;

        assembly {
            tempBytes32 := mload(add(add(_bytes, 0x20), _start))
        }

        return tempBytes32;
    }
}

pragma solidity ^0.6.11;



library Marshaling {

    using BytesLib for bytes;
    using Value for Value.Data;

    function deserializeMessage(bytes memory data, uint256 startOffset)
        internal
        pure
        returns (
            bool,
            uint256,
            address,
            uint8,
            bytes memory
        )
    {

        require(data.length >= startOffset && data.length - startOffset >= 8, "too short");
        uint256 size = 0;
        for (uint256 i = 0; i < 8; i++) {
            size *= 256;
            size += uint8(data[startOffset + 7 - i]);
        }
        (, uint256 sender) = deserializeInt(data, startOffset + 8);
        (, uint256 kind) = deserializeInt(data, startOffset + 8 + 32);
        bytes memory res = new bytes(size - 64);
        for (uint256 i = 0; i < size - 64; i++) {
            res[i] = data[startOffset + 8 + 64 + i];
        }
        return (true, startOffset + 8 + size, address(uint160(sender)), uint8(kind), res);
    }

    function deserializeRawMessage(bytes memory data, uint256 startOffset)
        internal
        pure
        returns (
            bool,
            uint256,
            bytes memory
        )
    {

        require(data.length >= startOffset && data.length - startOffset >= 8, "too short");
        uint256 size = 0;
        for (uint256 i = 0; i < 8; i++) {
            size *= 256;
            size += uint8(data[startOffset + 7 - i]);
        }
        bytes memory res = new bytes(size);
        for (uint256 i = 0; i < size; i++) {
            res[i] = data[startOffset + 8 + i];
        }
        return (true, startOffset + 8 + size, res);
    }

    function deserializeHashPreImage(bytes memory data, uint256 startOffset)
        internal
        pure
        returns (uint256 offset, Value.Data memory value)
    {

        require(data.length >= startOffset && data.length - startOffset >= 64, "too short");
        bytes32 hashData;
        uint256 size;
        (offset, hashData) = extractBytes32(data, startOffset);
        (offset, size) = deserializeInt(data, offset);
        return (offset, Value.newTuplePreImage(hashData, size));
    }

    function deserializeInt(bytes memory data, uint256 startOffset)
        internal
        pure
        returns (
            uint256, // offset
            uint256 // val
        )
    {

        require(data.length >= startOffset && data.length - startOffset >= 32, "too short");
        return (startOffset + 32, data.toUint(startOffset));
    }

    function deserializeBytes32(bytes memory data, uint256 startOffset)
        internal
        pure
        returns (
            uint256, // offset
            bytes32 // val
        )
    {

        require(data.length >= startOffset && data.length - startOffset >= 32, "too short");
        return (startOffset + 32, data.toBytes32(startOffset));
    }

    function deserializeCodePoint(bytes memory data, uint256 startOffset)
        internal
        pure
        returns (
            uint256, // offset
            Value.Data memory // val
        )
    {

        uint256 offset = startOffset;
        uint8 immediateType;
        uint8 opCode;
        Value.Data memory immediate;
        bytes32 nextHash;

        (offset, immediateType) = extractUint8(data, offset);
        (offset, opCode) = extractUint8(data, offset);
        if (immediateType == 1) {
            (offset, immediate) = deserialize(data, offset);
        }
        (offset, nextHash) = extractBytes32(data, offset);
        if (immediateType == 1) {
            return (offset, Value.newCodePoint(opCode, nextHash, immediate));
        }
        return (offset, Value.newCodePoint(opCode, nextHash));
    }

    function deserializeTuple(
        uint8 memberCount,
        bytes memory data,
        uint256 startOffset
    )
        internal
        pure
        returns (
            uint256, // offset
            Value.Data[] memory // val
        )
    {

        uint256 offset = startOffset;
        Value.Data[] memory members = new Value.Data[](memberCount);
        for (uint8 i = 0; i < memberCount; i++) {
            (offset, members[i]) = deserialize(data, offset);
        }
        return (offset, members);
    }

    function deserialize(bytes memory data, uint256 startOffset)
        internal
        pure
        returns (
            uint256, // offset
            Value.Data memory // val
        )
    {

        require(startOffset < data.length, "invalid offset");
        (uint256 offset, uint8 valType) = extractUint8(data, startOffset);
        if (valType == Value.intTypeCode()) {
            uint256 intVal;
            (offset, intVal) = deserializeInt(data, offset);
            return (offset, Value.newInt(intVal));
        } else if (valType == Value.codePointTypeCode()) {
            return deserializeCodePoint(data, offset);
        } else if (valType == Value.bufferTypeCode()) {
            bytes32 hashVal;
            (offset, hashVal) = deserializeBytes32(data, offset);
            return (offset, Value.newBuffer(hashVal));
        } else if (valType == Value.tuplePreImageTypeCode()) {
            return deserializeHashPreImage(data, offset);
        } else if (valType >= Value.tupleTypeCode() && valType < Value.valueTypeCode()) {
            uint8 tupLength = uint8(valType - Value.tupleTypeCode());
            Value.Data[] memory tupleVal;
            (offset, tupleVal) = deserializeTuple(tupLength, data, offset);
            return (offset, Value.newTuple(tupleVal));
        }
        require(false, "invalid typecode");
    }

    function extractUint8(bytes memory data, uint256 startOffset)
        private
        pure
        returns (
            uint256, // offset
            uint8 // val
        )
    {

        return (startOffset + 1, uint8(data[startOffset]));
    }

    function extractBytes32(bytes memory data, uint256 startOffset)
        private
        pure
        returns (
            uint256, // offset
            bytes32 // val
        )
    {

        return (startOffset + 32, data.toBytes32(startOffset));
    }
}// Apache-2.0


pragma solidity ^0.6.11;

interface IMessageProvider {

    event InboxMessageDelivered(uint256 indexed messageNum, bytes data);

    event InboxMessageDeliveredFromOrigin(uint256 indexed messageNum);
}// Apache-2.0


pragma solidity ^0.6.11;


interface IInbox is IMessageProvider {

    function sendL2Message(bytes calldata messageData) external returns (uint256);


    function sendUnsignedTransaction(
        uint256 maxGas,
        uint256 gasPriceBid,
        uint256 nonce,
        address destAddr,
        uint256 amount,
        bytes calldata data
    ) external returns (uint256);


    function sendContractTransaction(
        uint256 maxGas,
        uint256 gasPriceBid,
        address destAddr,
        uint256 amount,
        bytes calldata data
    ) external returns (uint256);


    function sendL1FundedUnsignedTransaction(
        uint256 maxGas,
        uint256 gasPriceBid,
        uint256 nonce,
        address destAddr,
        bytes calldata data
    ) external payable returns (uint256);


    function sendL1FundedContractTransaction(
        uint256 maxGas,
        uint256 gasPriceBid,
        address destAddr,
        bytes calldata data
    ) external payable returns (uint256);


    function createRetryableTicket(
        address destAddr,
        uint256 arbTxCallValue,
        uint256 maxSubmissionCost,
        address submissionRefundAddress,
        address valueRefundAddress,
        uint256 maxGas,
        uint256 gasPriceBid,
        bytes calldata data
    ) external payable returns (uint256);


    function depositEth(uint256 maxSubmissionCost) external payable returns (uint256);


    function bridge() external view returns (IBridge);

}// Apache-2.0


pragma solidity ^0.6.11;

library Messages {

    function messageHash(
        uint8 kind,
        address sender,
        uint256 blockNumber,
        uint256 timestamp,
        uint256 inboxSeqNum,
        uint256 gasPriceL1,
        bytes32 messageDataHash
    ) internal pure returns (bytes32) {

        return
            keccak256(
                abi.encodePacked(
                    kind,
                    sender,
                    blockNumber,
                    timestamp,
                    inboxSeqNum,
                    gasPriceL1,
                    messageDataHash
                )
            );
    }

    function addMessageToInbox(bytes32 inbox, bytes32 message) internal pure returns (bytes32) {

        return keccak256(abi.encodePacked(inbox, message));
    }
}// Apache-2.0


pragma solidity ^0.6.11;

interface ICloneable {

    function isMaster() external view returns (bool);

}// Apache-2.0


pragma solidity ^0.6.11;


contract Cloneable is ICloneable {

    string private constant NOT_CLONE = "NOT_CLONE";

    bool private isMasterCopy;

    constructor() public {
        isMasterCopy = true;
    }

    function isMaster() external view override returns (bool) {

        return isMasterCopy;
    }

    function safeSelfDestruct(address payable dest) internal {

        require(!isMasterCopy, NOT_CLONE);
        selfdestruct(dest);
    }
}// Apache-2.0


pragma solidity ^0.6.11;

abstract contract WhitelistConsumer {
    address public whitelist;

    event WhitelistSourceUpdated(address newSource);

    modifier onlyWhitelisted {
        if (whitelist != address(0)) {
            require(Whitelist(whitelist).isAllowed(msg.sender), "NOT_WHITELISTED");
        }
        _;
    }

    function updateWhitelistSource(address newSource) external {
        require(msg.sender == whitelist, "NOT_FROM_LIST");
        whitelist = newSource;
        emit WhitelistSourceUpdated(newSource);
    }
}

contract Whitelist {

    address public owner;
    mapping(address => bool) public isAllowed;

    event OwnerUpdated(address newOwner);
    event WhitelistUpgraded(address newWhitelist, address[] targets);

    constructor() public {
        owner = msg.sender;
    }

    modifier onlyOwner {

        require(msg.sender == owner, "ONLY_OWNER");
        _;
    }

    function setOwner(address newOwner) external onlyOwner {

        owner = newOwner;
        emit OwnerUpdated(newOwner);
    }

    function setWhitelist(address[] memory user, bool[] memory val) external onlyOwner {

        require(user.length == val.length, "INVALID_INPUT");

        for (uint256 i = 0; i < user.length; i++) {
            isAllowed[user[i]] = val[i];
        }
    }

    function triggerConsumers(address newWhitelist, address[] memory targets) external onlyOwner {

        for (uint256 i = 0; i < targets.length; i++) {
            WhitelistConsumer(targets[i]).updateWhitelistSource(newWhitelist);
        }
        emit WhitelistUpgraded(newWhitelist, targets);
    }
}// Apache-2.0


pragma solidity ^0.6.11;



contract Inbox is IInbox, WhitelistConsumer, Cloneable {

    uint8 internal constant ETH_TRANSFER = 0;
    uint8 internal constant L2_MSG = 3;
    uint8 internal constant L1MessageType_L2FundedByL1 = 7;
    uint8 internal constant L1MessageType_submitRetryableTx = 9;

    uint8 internal constant L2MessageType_unsignedEOATx = 0;
    uint8 internal constant L2MessageType_unsignedContractTx = 1;

    IBridge public override bridge;

    function initialize(IBridge _bridge, address _whitelist) external {

        require(address(bridge) == address(0), "ALREADY_INIT");
        bridge = _bridge;
        WhitelistConsumer.whitelist = _whitelist;
    }

    function sendL2MessageFromOrigin(bytes calldata messageData)
        external
        onlyWhitelisted
        returns (uint256)
    {

        require(msg.sender == tx.origin, "origin only");
        uint256 msgNum = deliverToBridge(L2_MSG, msg.sender, keccak256(messageData));
        emit InboxMessageDeliveredFromOrigin(msgNum);
        return msgNum;
    }

    function sendL2Message(bytes calldata messageData)
        external
        override
        onlyWhitelisted
        returns (uint256)
    {

        uint256 msgNum = deliverToBridge(L2_MSG, msg.sender, keccak256(messageData));
        emit InboxMessageDelivered(msgNum, messageData);
        return msgNum;
    }

    function sendL1FundedUnsignedTransaction(
        uint256 maxGas,
        uint256 gasPriceBid,
        uint256 nonce,
        address destAddr,
        bytes calldata data
    ) external payable virtual override onlyWhitelisted returns (uint256) {

        return
            _deliverMessage(
                L1MessageType_L2FundedByL1,
                msg.sender,
                abi.encodePacked(
                    L2MessageType_unsignedEOATx,
                    maxGas,
                    gasPriceBid,
                    nonce,
                    uint256(uint160(bytes20(destAddr))),
                    msg.value,
                    data
                )
            );
    }

    function sendL1FundedContractTransaction(
        uint256 maxGas,
        uint256 gasPriceBid,
        address destAddr,
        bytes calldata data
    ) external payable virtual override onlyWhitelisted returns (uint256) {

        return
            _deliverMessage(
                L1MessageType_L2FundedByL1,
                msg.sender,
                abi.encodePacked(
                    L2MessageType_unsignedContractTx,
                    maxGas,
                    gasPriceBid,
                    uint256(uint160(bytes20(destAddr))),
                    msg.value,
                    data
                )
            );
    }

    function sendUnsignedTransaction(
        uint256 maxGas,
        uint256 gasPriceBid,
        uint256 nonce,
        address destAddr,
        uint256 amount,
        bytes calldata data
    ) external virtual override onlyWhitelisted returns (uint256) {

        return
            _deliverMessage(
                L2_MSG,
                msg.sender,
                abi.encodePacked(
                    L2MessageType_unsignedEOATx,
                    maxGas,
                    gasPriceBid,
                    nonce,
                    uint256(uint160(bytes20(destAddr))),
                    amount,
                    data
                )
            );
    }

    function sendContractTransaction(
        uint256 maxGas,
        uint256 gasPriceBid,
        address destAddr,
        uint256 amount,
        bytes calldata data
    ) external virtual override onlyWhitelisted returns (uint256) {

        return
            _deliverMessage(
                L2_MSG,
                msg.sender,
                abi.encodePacked(
                    L2MessageType_unsignedContractTx,
                    maxGas,
                    gasPriceBid,
                    uint256(uint160(bytes20(destAddr))),
                    amount,
                    data
                )
            );
    }

    function depositEth(uint256 maxSubmissionCost)
        external
        payable
        virtual
        override
        onlyWhitelisted
        returns (uint256)
    {

        return
            this.createRetryableTicket{ value: msg.value }(
                msg.sender,
                0,
                maxSubmissionCost,
                msg.sender,
                msg.sender,
                0,
                0,
                ""
            );
    }

    function createRetryableTicket(
        address destAddr,
        uint256 l2CallValue,
        uint256 maxSubmissionCost,
        address excessFeeRefundAddress,
        address callValueRefundAddress,
        uint256 maxGas,
        uint256 gasPriceBid,
        bytes calldata data
    ) external payable virtual override onlyWhitelisted returns (uint256) {

        return
            _deliverMessage(
                L1MessageType_submitRetryableTx,
                msg.sender,
                abi.encodePacked(
                    uint256(uint160(bytes20(destAddr))),
                    l2CallValue,
                    msg.value,
                    maxSubmissionCost,
                    uint256(uint160(bytes20(excessFeeRefundAddress))),
                    uint256(uint160(bytes20(callValueRefundAddress))),
                    maxGas,
                    gasPriceBid,
                    data.length,
                    data
                )
            );
    }

    function _deliverMessage(
        uint8 _kind,
        address _sender,
        bytes memory _messageData
    ) internal returns (uint256) {

        uint256 msgNum = deliverToBridge(_kind, _sender, keccak256(_messageData));
        emit InboxMessageDelivered(msgNum, _messageData);
        return msgNum;
    }

    function deliverToBridge(
        uint8 kind,
        address sender,
        bytes32 messageDataHash
    ) internal returns (uint256) {

        return bridge.deliverMessageToInbox{ value: msg.value }(kind, sender, messageDataHash);
    }
}// Apache-2.0


pragma solidity ^0.6.11;


contract OutboxEntry is Cloneable {

    address outbox;
    bytes32 public root;
    uint256 public numRemaining;
    mapping(bytes32 => bool) public spentOutput;

    function initialize(bytes32 _root, uint256 _numInBatch) external {

        require(outbox == address(0), "ALREADY_INIT");
        require(root == 0, "ALREADY_INIT");
        require(_root != 0, "BAD_ROOT");
        outbox = msg.sender;
        root = _root;
        numRemaining = _numInBatch;
    }

    function spendOutput(bytes32 _root, bytes32 _id) external returns (uint256) {

        require(msg.sender == outbox, "NOT_FROM_OUTBOX");
        require(!spentOutput[_id], "ALREADY_SPENT");
        require(_root == root, "BAD_ROOT");

        spentOutput[_id] = true;
        numRemaining--;

        return numRemaining;
    }

    function destroy() external {

        require(msg.sender == outbox, "NOT_FROM_OUTBOX");
        safeSelfDestruct(msg.sender);
    }
}// Apache-2.0


pragma solidity ^0.6.11;

interface IOutbox {

    event OutboxEntryCreated(
        uint256 indexed batchNum,
        uint256 outboxIndex,
        bytes32 outputRoot,
        uint256 numInBatch
    );
    event OutBoxTransactionExecuted(
        address indexed destAddr,
        address indexed l2Sender,
        uint256 indexed outboxIndex,
        uint256 transactionIndex
    );

    function l2ToL1Sender() external view returns (address);


    function l2ToL1Block() external view returns (uint256);


    function l2ToL1EthBlock() external view returns (uint256);


    function l2ToL1Timestamp() external view returns (uint256);


    function processOutgoingMessages(bytes calldata sendsData, uint256[] calldata sendLengths)
        external;

}// Apache-2.0


pragma solidity ^0.6.11;

library MerkleLib {

    function generateRoot(bytes32[] memory _hashes) internal pure returns (bytes32) {

        bytes32[] memory prevLayer = _hashes;
        while (prevLayer.length > 1) {
            bytes32[] memory nextLayer = new bytes32[]((prevLayer.length + 1) / 2);
            for (uint256 i = 0; i < nextLayer.length; i++) {
                if (2 * i + 1 < prevLayer.length) {
                    nextLayer[i] = keccak256(
                        abi.encodePacked(prevLayer[2 * i], prevLayer[2 * i + 1])
                    );
                } else {
                    nextLayer[i] = prevLayer[2 * i];
                }
            }
            prevLayer = nextLayer;
        }
        return prevLayer[0];
    }

    function calculateRoot(
        bytes32[] memory nodes,
        uint256 route,
        bytes32 item
    ) internal pure returns (bytes32) {

        uint256 proofItems = nodes.length;
        require(proofItems <= 256);
        bytes32 h = item;
        for (uint256 i = 0; i < proofItems; i++) {
            if (route % 2 == 0) {
                h = keccak256(abi.encodePacked(nodes[i], h));
            } else {
                h = keccak256(abi.encodePacked(h, nodes[i]));
            }
            route /= 2;
        }
        return h;
    }
}// Apache-2.0


pragma solidity ^0.6.11;





contract Outbox is IOutbox, Cloneable {

    using BytesLib for bytes;

    bytes1 internal constant MSG_ROOT = 0;

    uint8 internal constant SendType_sendTxToL1 = 3;

    address public rollup;
    IBridge public bridge;

    UpgradeableBeacon public beacon;
    OutboxEntry[] public outboxes;

    address internal _sender;
    uint128 internal _l2Block;
    uint128 internal _l1Block;
    uint128 internal _timestamp;

    function initialize(address _rollup, IBridge _bridge) external {

        require(rollup == address(0), "ALREADY_INIT");
        rollup = _rollup;
        bridge = _bridge;

        address outboxEntryTemplate = address(new OutboxEntry());
        beacon = new UpgradeableBeacon(outboxEntryTemplate);
        beacon.transferOwnership(_rollup);
    }

    function l2ToL1Sender() external view override returns (address) {

        return _sender;
    }

    function l2ToL1Block() external view override returns (uint256) {

        return uint256(_l2Block);
    }

    function l2ToL1EthBlock() external view override returns (uint256) {

        return uint256(_l1Block);
    }

    function l2ToL1Timestamp() external view override returns (uint256) {

        return uint256(_timestamp);
    }

    function processOutgoingMessages(bytes calldata sendsData, uint256[] calldata sendLengths)
        external
        override
    {

        require(msg.sender == rollup, "ONLY_ROLLUP");
        uint256 messageCount = sendLengths.length;
        uint256 offset = 0;
        for (uint256 i = 0; i < messageCount; i++) {
            handleOutgoingMessage(bytes(sendsData[offset:offset + sendLengths[i]]));
            offset += sendLengths[i];
        }
    }

    function handleOutgoingMessage(bytes memory data) private {

        if (data[0] == MSG_ROOT) {
            require(data.length == 97, "BAD_LENGTH");
            uint256 batchNum = data.toUint(1);
            uint256 numInBatch = data.toUint(33);
            bytes32 outputRoot = data.toBytes32(65);

            address clone = address(new BeaconProxy(address(beacon), ""));
            OutboxEntry(clone).initialize(outputRoot, numInBatch);
            uint256 outboxIndex = outboxes.length;
            outboxes.push(OutboxEntry(clone));
            emit OutboxEntryCreated(batchNum, outboxIndex, outputRoot, numInBatch);
        }
    }

    function executeTransaction(
        uint256 outboxIndex,
        bytes32[] calldata proof,
        uint256 index,
        address l2Sender,
        address destAddr,
        uint256 l2Block,
        uint256 l1Block,
        uint256 l2Timestamp,
        uint256 amount,
        bytes calldata calldataForL1
    ) external virtual {

        bytes32 userTx =
            calculateItemHash(
                l2Sender,
                destAddr,
                l2Block,
                l1Block,
                l2Timestamp,
                amount,
                calldataForL1
            );

        spendOutput(outboxIndex, proof, index, userTx);
        emit OutBoxTransactionExecuted(destAddr, l2Sender, outboxIndex, index);

        address currentSender = _sender;
        uint128 currentL2Block = _l2Block;
        uint128 currentL1Block = _l1Block;
        uint128 currentTimestamp = _timestamp;

        _sender = l2Sender;
        _l2Block = uint128(l2Block);
        _l1Block = uint128(l1Block);
        _timestamp = uint128(l2Timestamp);

        executeBridgeCall(destAddr, amount, calldataForL1);

        _sender = currentSender;
        _l2Block = currentL2Block;
        _l1Block = currentL1Block;
        _timestamp = currentTimestamp;
    }

    function spendOutput(
        uint256 outboxIndex,
        bytes32[] memory proof,
        uint256 path,
        bytes32 item
    ) internal {

        require(proof.length <= 256, "PROOF_TOO_LONG");
        require(path < 2**proof.length, "PATH_NOT_MINIMAL");

        bytes32 calcRoot = calculateMerkleRoot(proof, path, item);
        OutboxEntry outbox = outboxes[outboxIndex];
        require(address(outbox) != address(0), "NO_OUTBOX");

        bytes32 uniqueKey = keccak256(abi.encodePacked(path, proof.length));
        uint256 numRemaining = outbox.spendOutput(calcRoot, uniqueKey);

        if (numRemaining == 0) {
            outbox.destroy();
            outboxes[outboxIndex] = OutboxEntry(address(0));
        }
    }

    function executeBridgeCall(
        address destAddr,
        uint256 amount,
        bytes memory data
    ) internal {

        (bool success, bytes memory returndata) = bridge.executeCall(destAddr, amount, data);
        if (!success) {
            if (returndata.length > 0) {
                assembly {
                    let returndata_size := mload(returndata)
                    revert(add(32, returndata), returndata_size)
                }
            } else {
                revert("BRIDGE_CALL_FAILED");
            }
        }
    }

    function calculateItemHash(
        address l2Sender,
        address destAddr,
        uint256 l2Block,
        uint256 l1Block,
        uint256 l2Timestamp,
        uint256 amount,
        bytes calldata calldataForL1
    ) public pure returns (bytes32) {

        return
            keccak256(
                abi.encodePacked(
                    SendType_sendTxToL1,
                    uint256(uint160(bytes20(l2Sender))),
                    uint256(uint160(bytes20(destAddr))),
                    l2Block,
                    l1Block,
                    l2Timestamp,
                    amount,
                    calldataForL1
                )
            );
    }

    function calculateMerkleRoot(
        bytes32[] memory proof,
        uint256 path,
        bytes32 item
    ) public pure returns (bytes32) {

        return MerkleLib.calculateRoot(proof, path, keccak256(abi.encodePacked(item)));
    }

    function outboxesLength() public view returns (uint256) {

        return outboxes.length;
    }
}// Apache-2.0


pragma solidity ^0.6.11;



contract Bridge is OwnableUpgradeable, IBridge {

    using Address for address;
    struct InOutInfo {
        uint256 index;
        bool allowed;
    }

    mapping(address => InOutInfo) private allowedInboxesMap;
    mapping(address => InOutInfo) private allowedOutboxesMap;

    address[] public allowedInboxList;
    address[] public allowedOutboxList;

    address public override activeOutbox;
    bytes32[] public override inboxAccs;

    function initialize() external initializer {

        __Ownable_init();
    }

    function allowedInboxes(address inbox) external view override returns (bool) {

        return allowedInboxesMap[inbox].allowed;
    }

    function allowedOutboxes(address outbox) external view override returns (bool) {

        return allowedOutboxesMap[outbox].allowed;
    }

    function deliverMessageToInbox(
        uint8 kind,
        address sender,
        bytes32 messageDataHash
    ) external payable override returns (uint256) {

        require(allowedInboxesMap[msg.sender].allowed, "NOT_FROM_INBOX");
        uint256 count = inboxAccs.length;
        bytes32 messageHash =
            Messages.messageHash(
                kind,
                sender,
                block.number,
                block.timestamp, // solhint-disable-line not-rely-on-time
                count,
                tx.gasprice,
                messageDataHash
            );
        bytes32 prevAcc = 0;
        if (count > 0) {
            prevAcc = inboxAccs[count - 1];
        }
        inboxAccs.push(Messages.addMessageToInbox(prevAcc, messageHash));
        emit MessageDelivered(count, prevAcc, msg.sender, kind, sender, messageDataHash);
        return count;
    }

    function executeCall(
        address destAddr,
        uint256 amount,
        bytes calldata data
    ) external override returns (bool success, bytes memory returnData) {

        require(allowedOutboxesMap[msg.sender].allowed, "NOT_FROM_OUTBOX");
        if (data.length > 0) require(destAddr.isContract(), "NO_CODE_AT_DEST");
        address currentOutbox = activeOutbox;
        activeOutbox = msg.sender;
        (success, returnData) = destAddr.call{ value: amount }(data);
        activeOutbox = currentOutbox;
    }

    function setInbox(address inbox, bool enabled) external override onlyOwner {

        InOutInfo storage info = allowedInboxesMap[inbox];
        bool alreadyEnabled = info.allowed;
        if ((alreadyEnabled && enabled) || (!alreadyEnabled && !enabled)) {
            return;
        }
        if (enabled) {
            allowedInboxesMap[inbox] = InOutInfo(allowedInboxList.length, true);
            allowedInboxList.push(inbox);
        } else {
            allowedInboxList[info.index] = allowedInboxList[allowedInboxList.length - 1];
            allowedInboxesMap[allowedInboxList[info.index]].index = info.index;
            allowedInboxList.pop();
            delete allowedInboxesMap[inbox];
        }
    }

    function setOutbox(address outbox, bool enabled) external override onlyOwner {

        InOutInfo storage info = allowedOutboxesMap[outbox];
        bool alreadyEnabled = info.allowed;
        if ((alreadyEnabled && enabled) || (!alreadyEnabled && !enabled)) {
            return;
        }
        if (enabled) {
            allowedOutboxesMap[outbox] = InOutInfo(allowedOutboxList.length, true);
            allowedOutboxList.push(outbox);
        } else {
            allowedOutboxList[info.index] = allowedOutboxList[allowedOutboxList.length - 1];
            allowedOutboxesMap[allowedOutboxList[info.index]].index = info.index;
            allowedOutboxList.pop();
            delete allowedOutboxesMap[outbox];
        }
    }

    function messageCount() external view override returns (uint256) {

        return inboxAccs.length;
    }
}// Apache-2.0


pragma solidity ^0.6.11;

interface INode {

    function initialize(
        address _rollup,
        bytes32 _stateHash,
        bytes32 _challengeHash,
        bytes32 _confirmData,
        uint256 _prev,
        uint256 _deadlineBlock
    ) external;


    function destroy() external;


    function addStaker(address staker) external returns (uint256);


    function removeStaker(address staker) external;


    function childCreated(uint256) external;


    function resetChildren() external;


    function newChildConfirmDeadline(uint256 deadline) external;


    function stateHash() external view returns (bytes32);


    function challengeHash() external view returns (bytes32);


    function confirmData() external view returns (bytes32);


    function prev() external view returns (uint256);


    function deadlineBlock() external view returns (uint256);


    function noChildConfirmedBeforeBlock() external view returns (uint256);


    function stakerCount() external view returns (uint256);


    function stakers(address staker) external view returns (bool);


    function firstChildBlock() external view returns (uint256);


    function latestChildNumber() external view returns (uint256);


    function requirePastDeadline() external view;


    function requirePastChildConfirmDeadline() external view;

}// Apache-2.0


pragma solidity ^0.6.11;


interface IRollupCore {

    function _stakerMap(address stakerAddress)
        external
        view
        returns (
            uint256,
            uint256,
            uint256,
            address,
            bool
        );


    function getNode(uint256 nodeNum) external view returns (INode);


    function getStakerAddress(uint256 stakerNum) external view returns (address);


    function isStaked(address staker) external view returns (bool);


    function latestStakedNode(address staker) external view returns (uint256);


    function currentChallenge(address staker) external view returns (address);


    function amountStaked(address staker) external view returns (uint256);


    function zombieAddress(uint256 zombieNum) external view returns (address);


    function zombieLatestStakedNode(uint256 zombieNum) external view returns (uint256);


    function zombieCount() external view returns (uint256);


    function isZombie(address staker) external view returns (bool);


    function withdrawableFunds(address owner) external view returns (uint256);


    function firstUnresolvedNode() external view returns (uint256);


    function latestConfirmed() external view returns (uint256);


    function latestNodeCreated() external view returns (uint256);


    function lastStakeBlock() external view returns (uint256);


    function stakerCount() external view returns (uint256);


    function getNodeHash(uint256 index) external view returns (bytes32);

}// Apache-2.0


pragma solidity ^0.6.11;


library ChallengeLib {

    using SafeMath for uint256;

    function firstSegmentSize(uint256 totalCount, uint256 bisectionCount)
        internal
        pure
        returns (uint256)
    {

        return totalCount / bisectionCount + (totalCount % bisectionCount);
    }

    function otherSegmentSize(uint256 totalCount, uint256 bisectionCount)
        internal
        pure
        returns (uint256)
    {

        return totalCount / bisectionCount;
    }

    function bisectionChunkHash(
        uint256 _segmentStart,
        uint256 _segmentLength,
        bytes32 _startHash,
        bytes32 _endHash
    ) internal pure returns (bytes32) {

        return keccak256(abi.encodePacked(_segmentStart, _segmentLength, _startHash, _endHash));
    }

    function inboxDeltaHash(bytes32 _inboxAcc, bytes32 _deltaAcc) internal pure returns (bytes32) {

        return keccak256(abi.encodePacked(_inboxAcc, _deltaAcc));
    }

    function assertionHash(uint256 _arbGasUsed, bytes32 _restHash) internal pure returns (bytes32) {

        return keccak256(abi.encodePacked(_arbGasUsed, _restHash));
    }

    function assertionRestHash(
        uint256 _totalMessagesRead,
        bytes32 _machineState,
        bytes32 _sendAcc,
        uint256 _sendCount,
        bytes32 _logAcc,
        uint256 _logCount
    ) internal pure returns (bytes32) {

        return
            keccak256(
                abi.encodePacked(
                    _totalMessagesRead,
                    _machineState,
                    _sendAcc,
                    _sendCount,
                    _logAcc,
                    _logCount
                )
            );
    }

    function updatedBisectionRoot(
        bytes32[] memory _chainHashes,
        uint256 _challengedSegmentStart,
        uint256 _challengedSegmentLength
    ) internal pure returns (bytes32) {

        uint256 bisectionCount = _chainHashes.length - 1;
        bytes32[] memory hashes = new bytes32[](bisectionCount);
        uint256 chunkSize = ChallengeLib.firstSegmentSize(_challengedSegmentLength, bisectionCount);
        uint256 segmentStart = _challengedSegmentStart;
        hashes[0] = ChallengeLib.bisectionChunkHash(
            segmentStart,
            chunkSize,
            _chainHashes[0],
            _chainHashes[1]
        );
        segmentStart = segmentStart.add(chunkSize);
        chunkSize = ChallengeLib.otherSegmentSize(_challengedSegmentLength, bisectionCount);
        for (uint256 i = 1; i < bisectionCount; i++) {
            hashes[i] = ChallengeLib.bisectionChunkHash(
                segmentStart,
                chunkSize,
                _chainHashes[i],
                _chainHashes[i + 1]
            );
            segmentStart = segmentStart.add(chunkSize);
        }
        return MerkleLib.generateRoot(hashes);
    }

    function verifySegmentProof(
        bytes32 challengeState,
        bytes32 item,
        bytes32[] calldata _merkleNodes,
        uint256 _merkleRoute
    ) internal pure returns (bool) {

        return challengeState == MerkleLib.calculateRoot(_merkleNodes, _merkleRoute, item);
    }
}// Apache-2.0


pragma solidity ^0.6.11;


library RollupLib {

    struct Config {
        bytes32 machineHash;
        uint256 confirmPeriodBlocks;
        uint256 extraChallengeTimeBlocks;
        uint256 arbGasSpeedLimitPerBlock;
        uint256 baseStake;
        address stakeToken;
        address owner;
        address sequencer;
        uint256 sequencerDelayBlocks;
        uint256 sequencerDelaySeconds;
        bytes extraConfig;
    }

    struct ExecutionState {
        uint256 gasUsed;
        bytes32 machineHash;
        uint256 inboxCount;
        uint256 sendCount;
        uint256 logCount;
        bytes32 sendAcc;
        bytes32 logAcc;
        uint256 proposedBlock;
        uint256 inboxMaxCount;
    }

    function stateHash(ExecutionState memory execState) internal pure returns (bytes32) {

        return
            keccak256(
                abi.encodePacked(
                    execState.gasUsed,
                    execState.machineHash,
                    execState.inboxCount,
                    execState.sendCount,
                    execState.logCount,
                    execState.sendAcc,
                    execState.logAcc,
                    execState.proposedBlock,
                    execState.inboxMaxCount
                )
            );
    }

    struct Assertion {
        ExecutionState beforeState;
        ExecutionState afterState;
    }

    function decodeExecutionState(
        bytes32[3] memory bytes32Fields,
        uint256[4] memory intFields,
        uint256 proposedBlock,
        uint256 inboxMaxCount
    ) internal pure returns (ExecutionState memory) {

        return
            ExecutionState(
                intFields[0],
                bytes32Fields[0],
                intFields[1],
                intFields[2],
                intFields[3],
                bytes32Fields[1],
                bytes32Fields[2],
                proposedBlock,
                inboxMaxCount
            );
    }

    function decodeAssertion(
        bytes32[3][2] memory bytes32Fields,
        uint256[4][2] memory intFields,
        uint256 beforeProposedBlock,
        uint256 beforeInboxMaxCount,
        uint256 inboxMaxCount
    ) internal view returns (Assertion memory) {

        return
            Assertion(
                decodeExecutionState(
                    bytes32Fields[0],
                    intFields[0],
                    beforeProposedBlock,
                    beforeInboxMaxCount
                ),
                decodeExecutionState(bytes32Fields[1], intFields[1], block.number, inboxMaxCount)
            );
    }

    function executionStateChallengeHash(ExecutionState memory state)
        internal
        pure
        returns (bytes32)
    {

        return
            ChallengeLib.assertionHash(
                state.gasUsed,
                ChallengeLib.assertionRestHash(
                    state.inboxCount,
                    state.machineHash,
                    state.sendAcc,
                    state.sendCount,
                    state.logAcc,
                    state.logCount
                )
            );
    }

    function executionHash(Assertion memory assertion) internal pure returns (bytes32) {

        return
            ChallengeLib.bisectionChunkHash(
                assertion.beforeState.gasUsed,
                assertion.afterState.gasUsed - assertion.beforeState.gasUsed,
                RollupLib.executionStateChallengeHash(assertion.beforeState),
                RollupLib.executionStateChallengeHash(assertion.afterState)
            );
    }

    function challengeRoot(
        Assertion memory assertion,
        bytes32 assertionExecHash,
        uint256 blockProposed
    ) internal pure returns (bytes32) {

        return challengeRootHash(assertionExecHash, blockProposed, assertion.afterState.inboxCount);
    }

    function challengeRootHash(
        bytes32 execution,
        uint256 proposedTime,
        uint256 maxMessageCount
    ) internal pure returns (bytes32) {

        return keccak256(abi.encodePacked(execution, proposedTime, maxMessageCount));
    }

    function confirmHash(Assertion memory assertion) internal pure returns (bytes32) {

        return
            confirmHash(
                assertion.beforeState.sendAcc,
                assertion.afterState.sendAcc,
                assertion.afterState.logAcc,
                assertion.afterState.sendCount,
                assertion.afterState.logCount
            );
    }

    function confirmHash(
        bytes32 beforeSendAcc,
        bytes32 afterSendAcc,
        bytes32 afterLogAcc,
        uint256 afterSendCount,
        uint256 afterLogCount
    ) internal pure returns (bytes32) {

        return
            keccak256(
                abi.encodePacked(
                    beforeSendAcc,
                    afterSendAcc,
                    afterSendCount,
                    afterLogAcc,
                    afterLogCount
                )
            );
    }

    function feedAccumulator(
        bytes memory messageData,
        uint256[] memory messageLengths,
        bytes32 beforeAcc
    ) internal pure returns (bytes32) {

        uint256 offset = 0;
        uint256 messageCount = messageLengths.length;
        uint256 dataLength = messageData.length;
        bytes32 messageAcc = beforeAcc;
        for (uint256 i = 0; i < messageCount; i++) {
            uint256 messageLength = messageLengths[i];
            require(offset + messageLength <= dataLength, "DATA_OVERRUN");
            bytes32 messageHash;
            assembly {
                messageHash := keccak256(add(messageData, add(offset, 32)), messageLength)
            }
            messageAcc = keccak256(abi.encodePacked(messageAcc, messageHash));
            offset += messageLength;
        }
        require(offset == dataLength, "DATA_LENGTH");
        return messageAcc;
    }

    function nodeHash(
        bool hasSibling,
        bytes32 lastHash,
        bytes32 assertionExecHash,
        bytes32 inboxAcc
    ) internal pure returns (bytes32) {

        uint8 hasSiblingInt = hasSibling ? 1 : 0;
        return keccak256(abi.encodePacked(hasSiblingInt, lastHash, assertionExecHash, inboxAcc));
    }

    function nodeAccumulator(bytes32 prevAcc, bytes32 newNodeHash) internal pure returns (bytes32) {

        return keccak256(abi.encodePacked(prevAcc, newNodeHash));
    }
}// Apache-2.0


pragma solidity ^0.6.11;



contract RollupCore is IRollupCore {

    using SafeMath for uint256;

    struct Zombie {
        address stakerAddress;
        uint256 latestStakedNode;
    }

    struct Staker {
        uint256 index;
        uint256 latestStakedNode;
        uint256 amountStaked;
        address currentChallenge;
        bool isStaked;
    }

    uint256 private _latestConfirmed;
    uint256 private _firstUnresolvedNode;
    uint256 private _latestNodeCreated;
    uint256 private _lastStakeBlock;
    mapping(uint256 => INode) private _nodes;
    mapping(uint256 => bytes32) private _nodeHashes;

    address payable[] private _stakerList;
    mapping(address => Staker) public override _stakerMap;

    Zombie[] private _zombies;

    mapping(address => uint256) private _withdrawableFunds;

    function getNode(uint256 nodeNum) public view override returns (INode) {

        return _nodes[nodeNum];
    }

    function getStakerAddress(uint256 stakerNum) public view override returns (address) {

        return _stakerList[stakerNum];
    }

    function isStaked(address staker) public view override returns (bool) {

        return _stakerMap[staker].isStaked;
    }

    function latestStakedNode(address staker) public view override returns (uint256) {

        return _stakerMap[staker].latestStakedNode;
    }

    function currentChallenge(address staker) public view override returns (address) {

        return _stakerMap[staker].currentChallenge;
    }

    function amountStaked(address staker) public view override returns (uint256) {

        return _stakerMap[staker].amountStaked;
    }

    function zombieAddress(uint256 zombieNum) public view override returns (address) {

        return _zombies[zombieNum].stakerAddress;
    }

    function zombieLatestStakedNode(uint256 zombieNum) public view override returns (uint256) {

        return _zombies[zombieNum].latestStakedNode;
    }

    function zombieCount() public view override returns (uint256) {

        return _zombies.length;
    }

    function isZombie(address staker) public view override returns (bool) {

        for (uint256 i = 0; i < _zombies.length; i++) {
            if (staker == _zombies[i].stakerAddress) {
                return true;
            }
        }
        return false;
    }

    function withdrawableFunds(address owner) public view override returns (uint256) {

        return _withdrawableFunds[owner];
    }

    function firstUnresolvedNode() public view override returns (uint256) {

        return _firstUnresolvedNode;
    }

    function latestConfirmed() public view override returns (uint256) {

        return _latestConfirmed;
    }

    function latestNodeCreated() public view override returns (uint256) {

        return _latestNodeCreated;
    }

    function lastStakeBlock() public view override returns (uint256) {

        return _lastStakeBlock;
    }

    function stakerCount() public view override returns (uint256) {

        return _stakerList.length;
    }

    function initializeCore(INode initialNode) internal {

        _nodes[0] = initialNode;
        _firstUnresolvedNode = 1;
    }

    function nodeCreated(INode node, bytes32 nodeHash) internal {

        _latestNodeCreated++;
        _nodes[_latestNodeCreated] = node;
        _nodeHashes[_latestNodeCreated] = nodeHash;
    }

    function getNodeHash(uint256 index) public view override returns (bytes32) {

        return _nodeHashes[index];
    }

    function resetNodeHash(uint256 index) internal {

        _nodeHashes[index] = 0;
    }

    function updateLatestNodeCreated(uint256 newLatestNodeCreated) internal {

        _latestNodeCreated = newLatestNodeCreated;
    }

    function rejectNextNode() internal {

        destroyNode(_firstUnresolvedNode);
        _firstUnresolvedNode++;
    }

    function confirmNextNode() internal {

        destroyNode(_latestConfirmed);
        _latestConfirmed = _firstUnresolvedNode;
        _firstUnresolvedNode++;
    }

    function confirmLatestNode() internal {

        destroyNode(_latestConfirmed);
        uint256 latestNode = _latestNodeCreated;
        _latestConfirmed = latestNode;
        _firstUnresolvedNode = latestNode + 1;
    }

    function createNewStake(address payable stakerAddress, uint256 depositAmount) internal {

        uint256 stakerIndex = _stakerList.length;
        _stakerList.push(stakerAddress);
        _stakerMap[stakerAddress] = Staker(
            stakerIndex,
            _latestConfirmed,
            depositAmount,
            address(0),
            true
        );
        _lastStakeBlock = block.number;
    }

    function inChallenge(address stakerAddress1, address stakerAddress2)
        internal
        view
        returns (address)
    {

        Staker storage staker1 = _stakerMap[stakerAddress1];
        Staker storage staker2 = _stakerMap[stakerAddress2];
        address challenge = staker1.currentChallenge;
        require(challenge == staker2.currentChallenge, "IN_CHAL");
        require(challenge != address(0), "NO_CHAL");
        return challenge;
    }

    function clearChallenge(address stakerAddress) internal {

        Staker storage staker = _stakerMap[stakerAddress];
        staker.currentChallenge = address(0);
    }

    function challengeStarted(
        address staker1,
        address staker2,
        address challenge
    ) internal {

        _stakerMap[staker1].currentChallenge = challenge;
        _stakerMap[staker2].currentChallenge = challenge;
    }

    function increaseStakeBy(address stakerAddress, uint256 amountAdded) internal {

        Staker storage staker = _stakerMap[stakerAddress];
        staker.amountStaked = staker.amountStaked.add(amountAdded);
    }

    function reduceStakeTo(address stakerAddress, uint256 target) internal returns (uint256) {

        Staker storage staker = _stakerMap[stakerAddress];
        uint256 current = staker.amountStaked;
        require(target <= current, "TOO_LITTLE_STAKE");
        uint256 amountWithdrawn = current.sub(target);
        staker.amountStaked = target;
        _withdrawableFunds[stakerAddress] = _withdrawableFunds[stakerAddress].add(amountWithdrawn);
        return amountWithdrawn;
    }

    function turnIntoZombie(address stakerAddress) internal {

        Staker storage staker = _stakerMap[stakerAddress];
        _zombies.push(Zombie(stakerAddress, staker.latestStakedNode));
        deleteStaker(stakerAddress);
    }

    function zombieUpdateLatestStakedNode(uint256 zombieNum, uint256 latest) internal {

        _zombies[zombieNum].latestStakedNode = latest;
    }

    function removeZombie(uint256 zombieNum) internal {

        _zombies[zombieNum] = _zombies[_zombies.length - 1];
        _zombies.pop();
    }

    function withdrawStaker(address stakerAddress) internal {

        Staker storage staker = _stakerMap[stakerAddress];
        _withdrawableFunds[stakerAddress] = _withdrawableFunds[stakerAddress].add(
            staker.amountStaked
        );
        deleteStaker(stakerAddress);
    }

    function stakeOnNode(
        address stakerAddress,
        uint256 nodeNum,
        uint256 confirmPeriodBlocks
    ) internal {

        Staker storage staker = _stakerMap[stakerAddress];
        INode node = _nodes[nodeNum];
        uint256 newStakerCount = node.addStaker(stakerAddress);
        staker.latestStakedNode = nodeNum;
        if (newStakerCount == 1) {
            INode parent = _nodes[node.prev()];
            parent.newChildConfirmDeadline(block.number.add(confirmPeriodBlocks));
        }
    }

    function withdrawFunds(address owner) internal returns (uint256) {

        uint256 amount = _withdrawableFunds[owner];
        _withdrawableFunds[owner] = 0;
        return amount;
    }

    function increaseWithdrawableFunds(address owner, uint256 amount) internal {

        _withdrawableFunds[owner] = _withdrawableFunds[owner].add(amount);
    }

    function deleteStaker(address stakerAddress) private {

        Staker storage staker = _stakerMap[stakerAddress];
        uint256 stakerIndex = staker.index;
        _stakerList[stakerIndex] = _stakerList[_stakerList.length - 1];
        _stakerMap[_stakerList[stakerIndex]].index = stakerIndex;
        _stakerList.pop();
        delete _stakerMap[stakerAddress];
    }

    function destroyNode(uint256 nodeNum) internal {

        _nodes[nodeNum].destroy();
        _nodes[nodeNum] = INode(0);
    }

    function max(uint256 a, uint256 b) internal pure returns (uint256) {

        return a > b ? a : b;
    }
}// Apache-2.0


pragma solidity ^0.6.11;


interface IRollupUser {

    function initialize(address _stakeToken) external;


    function completeChallenge(address winningStaker, address losingStaker) external;


    function returnOldDeposit(address stakerAddress) external;


    function requireUnresolved(uint256 nodeNum) external view;


    function requireUnresolvedExists() external view;


    function countStakedZombies(INode node) external view returns (uint256);

}

interface IRollupAdmin {

    function setOutbox(IOutbox _outbox) external;


    function removeOldOutbox(address _outbox) external;


    function setInbox(address _inbox, bool _enabled) external;


    function pause() external;


    function resume() external;


    function setFacets(address newAdminFacet, address newUserFacet) external;


    function setValidator(address[] memory _validator, bool[] memory _val) external;


    function setOwner(address newOwner) external;


    function setMinimumAssertionPeriod(uint256 newPeriod) external;


    function setConfirmPeriodBlocks(uint256 newConfirmPeriod) external;


    function setExtraChallengeTimeBlocks(uint256 newExtraTimeBlocks) external;


    function setArbGasSpeedLimitPerBlock(uint256 newArbGasSpeedLimitPerBlock) external;


    function setBaseStake(uint256 newBaseStake) external;


    function setStakeToken(address newStakeToken) external;


    function setSequencerInboxMaxDelayBlocks(uint256 newSequencerInboxMaxDelayBlocks) external;


    function setSequencerInboxMaxDelaySeconds(uint256 newSequencerInboxMaxDelaySeconds) external;


    function setChallengeExecutionBisectionDegree(uint256 newChallengeExecutionBisectionDegree)
        external;


    function updateWhitelistConsumers(
        address whitelist,
        address newWhitelist,
        address[] memory targets
    ) external;


    function setWhitelistEntries(
        address whitelist,
        address[] memory user,
        bool[] memory val
    ) external;


    function setSequencer(address newSequencer) external;


    function upgradeBeacon(address beacon, address newImplementation) external;

}// Apache-2.0


pragma solidity ^0.6.11;



contract RollupEventBridge is IMessageProvider, Cloneable {

    uint8 internal constant INITIALIZATION_MSG_TYPE = 4;
    uint8 internal constant ROLLUP_PROTOCOL_EVENT_TYPE = 8;

    uint8 internal constant CREATE_NODE_EVENT = 0;
    uint8 internal constant CONFIRM_NODE_EVENT = 1;
    uint8 internal constant REJECT_NODE_EVENT = 2;
    uint8 internal constant STAKE_CREATED_EVENT = 3;
    uint8 internal constant CLAIM_NODE_EVENT = 4;

    IBridge bridge;
    address rollup;

    modifier onlyRollup {

        require(msg.sender == rollup, "ONLY_ROLLUP");
        _;
    }

    function initialize(address _bridge, address _rollup) external {

        require(rollup == address(0), "ALREADY_INIT");
        bridge = IBridge(_bridge);
        rollup = _rollup;
    }

    function rollupInitialized(
        uint256 confirmPeriodBlocks,
        uint256 arbGasSpeedLimitPerBlock,
        uint256 baseStake,
        address stakeToken,
        address owner,
        bytes calldata extraConfig
    ) external onlyRollup {

        bytes memory initMsg =
            abi.encodePacked(
                confirmPeriodBlocks,
                arbGasSpeedLimitPerBlock / 100, // convert avm gas to arbgas
                uint256(0),
                baseStake,
                uint256(uint160(bytes20(stakeToken))),
                uint256(uint160(bytes20(owner))),
                extraConfig
            );
        uint256 num =
            bridge.deliverMessageToInbox(INITIALIZATION_MSG_TYPE, msg.sender, keccak256(initMsg));
        emit InboxMessageDelivered(num, initMsg);
    }

    function nodeCreated(
        uint256 nodeNum,
        uint256 prev,
        uint256 deadline,
        address asserter
    ) external onlyRollup {

        deliverToBridge(
            abi.encodePacked(
                CREATE_NODE_EVENT,
                nodeNum,
                prev,
                block.number,
                deadline,
                uint256(uint160(bytes20(asserter)))
            )
        );
    }

    function nodeConfirmed(uint256 nodeNum) external onlyRollup {

        deliverToBridge(abi.encodePacked(CONFIRM_NODE_EVENT, nodeNum));
    }

    function nodeRejected(uint256 nodeNum) external onlyRollup {

        deliverToBridge(abi.encodePacked(REJECT_NODE_EVENT, nodeNum));
    }

    function stakeCreated(address staker, uint256 nodeNum) external onlyRollup {

        deliverToBridge(
            abi.encodePacked(
                STAKE_CREATED_EVENT,
                uint256(uint160(bytes20(staker))),
                nodeNum,
                block.number
            )
        );
    }

    function claimNode(uint256 nodeNum, address staker) external onlyRollup {

        Rollup r = Rollup(payable(rollup));
        INode node = r.getNode(nodeNum);
        require(node.stakers(staker), "NOT_STAKED");
        IRollupUser(address(r)).requireUnresolved(nodeNum);

        deliverToBridge(
            abi.encodePacked(CLAIM_NODE_EVENT, nodeNum, uint256(uint160(bytes20(staker))))
        );
    }

    function deliverToBridge(bytes memory message) private {

        emit InboxMessageDelivered(
            bridge.deliverMessageToInbox(
                ROLLUP_PROTOCOL_EVENT_TYPE,
                msg.sender,
                keccak256(message)
            ),
            message
        );
    }
}// Apache-2.0


pragma solidity ^0.6.11;

interface INodeFactory {

    function createNode(
        bytes32 _stateHash,
        bytes32 _challengeHash,
        bytes32 _confirmData,
        uint256 _prev,
        uint256 _deadlineBlock
    ) external returns (address);

}// Apache-2.0


pragma solidity ^0.6.11;


interface IChallenge {

    function initializeChallenge(
        IOneStepProof[] calldata _executors,
        address _resultReceiver,
        bytes32 _executionHash,
        uint256 _maxMessageCount,
        address _asserter,
        address _challenger,
        uint256 _asserterTimeLeft,
        uint256 _challengerTimeLeft,
        ISequencerInbox _sequencerBridge,
        IBridge _delayedBridge
    ) external;


    function currentResponderTimeLeft() external view returns (uint256);


    function lastMoveBlock() external view returns (uint256);


    function timeout() external;


    function asserter() external view returns (address);


    function challenger() external view returns (address);


    function clearChallenge() external;

}// Apache-2.0


pragma solidity ^0.6.11;


interface IChallengeFactory {

    function createChallenge(
        address _resultReceiver,
        bytes32 _executionHash,
        uint256 _maxMessageCount,
        address _asserter,
        address _challenger,
        uint256 _asserterTimeLeft,
        uint256 _challengerTimeLeft,
        ISequencerInbox _sequencerBridge,
        IBridge _delayedBridge
    ) external returns (address);

}// Apache-2.0


pragma solidity ^0.6.11;




abstract contract RollupBase is Cloneable, RollupCore, Pausable {
    uint256 public confirmPeriodBlocks;
    uint256 public extraChallengeTimeBlocks;
    uint256 public arbGasSpeedLimitPerBlock;
    uint256 public baseStake;

    IBridge public delayedBridge;
    ISequencerInbox public sequencerBridge;
    IOutbox public outbox;
    RollupEventBridge public rollupEventBridge;
    IChallengeFactory public challengeFactory;
    INodeFactory public nodeFactory;
    address public owner;
    address public stakeToken;
    uint256 public minimumAssertionPeriod;

    uint256 public sequencerInboxMaxDelayBlocks;
    uint256 public sequencerInboxMaxDelaySeconds;
    uint256 public challengeExecutionBisectionDegree;

    address[] internal facets;

    mapping(address => bool) isValidator;

    event RollupCreated(bytes32 machineHash);

    event NodeCreated(
        uint256 indexed nodeNum,
        bytes32 indexed parentNodeHash,
        bytes32 nodeHash,
        bytes32 executionHash,
        uint256 inboxMaxCount,
        uint256 afterInboxBatchEndCount,
        bytes32 afterInboxBatchAcc,
        bytes32[3][2] assertionBytes32Fields,
        uint256[4][2] assertionIntFields
    );

    event NodeConfirmed(
        uint256 indexed nodeNum,
        bytes32 afterSendAcc,
        uint256 afterSendCount,
        bytes32 afterLogAcc,
        uint256 afterLogCount
    );

    event NodeRejected(uint256 indexed nodeNum);

    event RollupChallengeStarted(
        address indexed challengeContract,
        address asserter,
        address challenger,
        uint256 challengedNode
    );

    event StakerReassigned(address indexed staker, uint256 newNode);
    event NodesDestroyed(uint256 indexed startNode, uint256 indexed endNode);
    event OwnerFunctionCalled(uint256 indexed id);
}

contract Rollup is RollupBase {

    function initialize(
        bytes32 _machineHash,
        uint256[4] calldata _rollupParams,
        address _stakeToken,
        address _owner,
        bytes calldata _extraConfig,
        address[6] calldata connectedContracts,
        address[2] calldata _facets,
        uint256[2] calldata sequencerInboxParams
    ) public {

        require(confirmPeriodBlocks == 0, "ALREADY_INIT");
        require(_rollupParams[0] != 0, "BAD_CONF_PERIOD");

        delayedBridge = IBridge(connectedContracts[0]);
        sequencerBridge = ISequencerInbox(connectedContracts[1]);
        outbox = IOutbox(connectedContracts[2]);
        delayedBridge.setOutbox(connectedContracts[2], true);
        rollupEventBridge = RollupEventBridge(connectedContracts[3]);
        delayedBridge.setInbox(connectedContracts[3], true);

        rollupEventBridge.rollupInitialized(
            _rollupParams[0],
            _rollupParams[2],
            _rollupParams[3],
            _stakeToken,
            _owner,
            _extraConfig
        );

        challengeFactory = IChallengeFactory(connectedContracts[4]);
        nodeFactory = INodeFactory(connectedContracts[5]);

        INode node = createInitialNode(_machineHash);
        initializeCore(node);

        confirmPeriodBlocks = _rollupParams[0];
        extraChallengeTimeBlocks = _rollupParams[1];
        arbGasSpeedLimitPerBlock = _rollupParams[2];
        baseStake = _rollupParams[3];
        owner = _owner;
        minimumAssertionPeriod = 75;
        challengeExecutionBisectionDegree = 400;

        sequencerInboxMaxDelayBlocks = sequencerInboxParams[0];
        sequencerInboxMaxDelaySeconds = sequencerInboxParams[1];

        facets = _facets;

        (bool success, ) =
            _facets[1].delegatecall(
                abi.encodeWithSelector(IRollupUser.initialize.selector, _stakeToken)
            );
        require(success, "FAIL_INIT_FACET");

        emit RollupCreated(_machineHash);
    }

    function createInitialNode(bytes32 _machineHash) private returns (INode) {

        bytes32 state =
            RollupLib.stateHash(
                RollupLib.ExecutionState(
                    0, // total gas used
                    _machineHash,
                    0, // inbox count
                    0, // send count
                    0, // log count
                    0, // send acc
                    0, // log acc
                    block.number, // block proposed
                    1 // Initialization message already in inbox
                )
            );
        return
            INode(
                nodeFactory.createNode(
                    state,
                    0, // challenge hash (not challengeable)
                    0, // confirm data
                    0, // prev node
                    block.number // deadline block (not challengeable)
                )
            );
    }


    function getFacets() public view returns (address, address) {

        return (getAdminFacet(), getUserFacet());
    }

    function getAdminFacet() public view returns (address) {

        return facets[0];
    }

    function getUserFacet() public view returns (address) {

        return facets[1];
    }

    fallback() external payable {
        _fallback();
    }

    receive() external payable {
        _fallback();
    }

    function _fallback() internal virtual {

        require(msg.data.length >= 4, "NO_FUNC_SIG");
        address rollupOwner = owner;
        address target =
            rollupOwner != address(0) && rollupOwner == msg.sender
                ? getAdminFacet()
                : getUserFacet();
        _delegate(target);
    }

    function _delegate(address implementation) internal virtual {

        assembly {
            calldatacopy(0, 0, calldatasize())

            let result := delegatecall(gas(), implementation, 0, calldatasize(), 0, 0)

            returndatacopy(0, 0, returndatasize())

            switch result
                case 0 {
                    revert(0, returndatasize())
                }
                default {
                    return(0, returndatasize())
                }
        }
    }
}// Apache-2.0


pragma solidity ^0.6.11;



contract SequencerInbox is ISequencerInbox, Cloneable {

    uint8 internal constant L2_MSG = 3;
    uint8 internal constant END_OF_BLOCK = 6;

    bytes32[] public override inboxAccs;
    uint256 public override messageCount;

    uint256 totalDelayedMessagesRead;

    IBridge public delayedInbox;
    address public sequencer;
    address public rollup;

    function initialize(
        IBridge _delayedInbox,
        address _sequencer,
        address _rollup
    ) external {

        require(address(delayedInbox) == address(0), "ALREADY_INIT");
        delayedInbox = _delayedInbox;
        sequencer = _sequencer;
        rollup = _rollup;
    }

    function setSequencer(address newSequencer) external override {

        require(msg.sender == rollup, "ONLY_ROLLUP");
        sequencer = newSequencer;
        emit SequencerAddressUpdated(newSequencer);
    }

    function maxDelayBlocks() public view override returns (uint256) {

        return RollupBase(rollup).sequencerInboxMaxDelayBlocks();
    }

    function maxDelaySeconds() public view override returns (uint256) {

        return RollupBase(rollup).sequencerInboxMaxDelaySeconds();
    }

    function getLastDelayedAcc() internal view returns (bytes32) {

        bytes32 acc = 0;
        if (totalDelayedMessagesRead > 0) {
            acc = delayedInbox.inboxAccs(totalDelayedMessagesRead - 1);
        }
        return acc;
    }

    function forceInclusion(
        uint256 _totalDelayedMessagesRead,
        uint8 kind,
        uint256[2] calldata l1BlockAndTimestamp,
        uint256 inboxSeqNum,
        uint256 gasPriceL1,
        address sender,
        bytes32 messageDataHash,
        bytes32 delayedAcc
    ) external {

        require(_totalDelayedMessagesRead > totalDelayedMessagesRead, "DELAYED_BACKWARDS");
        {
            bytes32 messageHash =
                Messages.messageHash(
                    kind,
                    sender,
                    l1BlockAndTimestamp[0],
                    l1BlockAndTimestamp[1],
                    inboxSeqNum,
                    gasPriceL1,
                    messageDataHash
                );
            require(l1BlockAndTimestamp[0] + maxDelayBlocks() < block.number, "MAX_DELAY_BLOCKS");
            require(l1BlockAndTimestamp[1] + maxDelaySeconds() < block.timestamp, "MAX_DELAY_TIME");

            bytes32 prevDelayedAcc = 0;
            if (_totalDelayedMessagesRead > 1) {
                prevDelayedAcc = delayedInbox.inboxAccs(_totalDelayedMessagesRead - 2);
            }
            require(
                delayedInbox.inboxAccs(_totalDelayedMessagesRead - 1) ==
                    Messages.addMessageToInbox(prevDelayedAcc, messageHash),
                "DELAYED_ACCUMULATOR"
            );
        }

        uint256 startNum = messageCount;
        bytes32 beforeAcc = 0;
        if (inboxAccs.length > 0) {
            beforeAcc = inboxAccs[inboxAccs.length - 1];
        }

        (bytes32 acc, uint256 count) =
            includeDelayedMessages(
                beforeAcc,
                startNum,
                _totalDelayedMessagesRead,
                block.number,
                block.timestamp,
                delayedAcc
            );
        inboxAccs.push(acc);
        messageCount = count;
        emit DelayedInboxForced(
            startNum,
            beforeAcc,
            count,
            _totalDelayedMessagesRead,
            [acc, delayedAcc],
            inboxAccs.length - 1
        );
    }

    function addSequencerL2BatchFromOrigin(
        bytes calldata transactions,
        uint256[] calldata lengths,
        uint256[] calldata sectionsMetadata,
        bytes32 afterAcc
    ) external {

        require(msg.sender == tx.origin, "origin only");
        uint256 startNum = messageCount;
        bytes32 beforeAcc =
            addSequencerL2BatchImpl(transactions, lengths, sectionsMetadata, afterAcc);
        emit SequencerBatchDeliveredFromOrigin(
            startNum,
            beforeAcc,
            messageCount,
            afterAcc,
            inboxAccs.length - 1
        );
    }

    function addSequencerL2Batch(
        bytes calldata transactions,
        uint256[] calldata lengths,
        uint256[] calldata sectionsMetadata,
        bytes32 afterAcc
    ) external {

        uint256 startNum = messageCount;
        bytes32 beforeAcc =
            addSequencerL2BatchImpl(transactions, lengths, sectionsMetadata, afterAcc);
        emit SequencerBatchDelivered(
            startNum,
            beforeAcc,
            messageCount,
            afterAcc,
            transactions,
            lengths,
            sectionsMetadata,
            inboxAccs.length - 1,
            msg.sender
        );
    }

    function addSequencerL2BatchImpl(
        bytes memory transactions,
        uint256[] calldata lengths,
        uint256[] calldata sectionsMetadata,
        bytes32 afterAcc
    ) private returns (bytes32 beforeAcc) {

        require(msg.sender == sequencer, "ONLY_SEQUENCER");

        if (inboxAccs.length > 0) {
            beforeAcc = inboxAccs[inboxAccs.length - 1];
        }

        uint256 runningCount = messageCount;
        bytes32 runningAcc = beforeAcc;
        uint256 processedItems = 0;
        uint256 dataOffset;
        assembly {
            dataOffset := add(transactions, 32)
        }
        for (uint256 i = 0; i + 5 <= sectionsMetadata.length; i += 5) {
            {
                uint256 l1BlockNumber = sectionsMetadata[i + 1];
                require(l1BlockNumber + maxDelayBlocks() >= block.number, "BLOCK_TOO_OLD");
                require(l1BlockNumber <= block.number, "BLOCK_TOO_NEW");
            }
            {
                uint256 l1Timestamp = sectionsMetadata[i + 2];
                require(l1Timestamp + maxDelaySeconds() >= block.timestamp, "TIME_TOO_OLD");
                require(l1Timestamp <= block.timestamp, "TIME_TOO_NEW");
            }

            {
                bytes32 prefixHash =
                    keccak256(
                        abi.encodePacked(
                            msg.sender,
                            sectionsMetadata[i + 1],
                            sectionsMetadata[i + 2]
                        )
                    );
                uint256 numItems = sectionsMetadata[i];
                (runningAcc, runningCount, dataOffset) = calcL2Batch(
                    dataOffset,
                    lengths,
                    processedItems,
                    numItems, // num items
                    prefixHash,
                    runningCount,
                    runningAcc
                );
                processedItems += numItems; // num items
            }

            uint256 newTotalDelayedMessagesRead = sectionsMetadata[i + 3];
            require(newTotalDelayedMessagesRead >= totalDelayedMessagesRead, "DELAYED_BACKWARDS");
            require(newTotalDelayedMessagesRead >= 1, "MUST_DELAYED_INIT");
            require(
                totalDelayedMessagesRead >= 1 || sectionsMetadata[i] == 0,
                "MUST_DELAYED_INIT_START"
            );
            if (newTotalDelayedMessagesRead > totalDelayedMessagesRead) {
                (runningAcc, runningCount) = includeDelayedMessages(
                    runningAcc,
                    runningCount,
                    newTotalDelayedMessagesRead,
                    sectionsMetadata[i + 1], // block number
                    sectionsMetadata[i + 2], // timestamp
                    bytes32(sectionsMetadata[i + 4]) // delayed accumulator
                );
            }
        }

        uint256 startOffset;
        assembly {
            startOffset := add(transactions, 32)
        }
        require(dataOffset >= startOffset, "OFFSET_OVERFLOW");
        require(dataOffset <= startOffset + transactions.length, "TRANSACTIONS_OVERRUN");

        require(runningCount > messageCount, "EMPTY_BATCH");
        inboxAccs.push(runningAcc);
        messageCount = runningCount;

        require(runningAcc == afterAcc, "AFTER_ACC");
    }

    function calcL2Batch(
        uint256 beforeOffset,
        uint256[] calldata lengths,
        uint256 lengthsOffset,
        uint256 itemCount,
        bytes32 prefixHash,
        uint256 beforeCount,
        bytes32 beforeAcc
    )
        private
        pure
        returns (
            bytes32 acc,
            uint256 count,
            uint256 offset
        )
    {

        offset = beforeOffset;
        count = beforeCount;
        acc = beforeAcc;
        itemCount += lengthsOffset;
        for (uint256 i = lengthsOffset; i < itemCount; i++) {
            uint256 length = lengths[i];
            bytes32 messageDataHash;
            assembly {
                messageDataHash := keccak256(offset, length)
            }
            acc = keccak256(abi.encodePacked(acc, count, prefixHash, messageDataHash));
            offset += length;
            count++;
        }
        return (acc, count, offset);
    }

    function includeDelayedMessages(
        bytes32 acc,
        uint256 count,
        uint256 _totalDelayedMessagesRead,
        uint256 l1BlockNumber,
        uint256 timestamp,
        bytes32 delayedAcc
    ) private returns (bytes32, uint256) {

        require(_totalDelayedMessagesRead <= delayedInbox.messageCount(), "DELAYED_TOO_FAR");
        require(delayedAcc == delayedInbox.inboxAccs(_totalDelayedMessagesRead - 1), "DELAYED_ACC");
        acc = keccak256(
            abi.encodePacked(
                "Delayed messages:",
                acc,
                count,
                totalDelayedMessagesRead,
                _totalDelayedMessagesRead,
                delayedAcc
            )
        );
        count += _totalDelayedMessagesRead - totalDelayedMessagesRead;
        bytes memory emptyBytes;
        acc = keccak256(
            abi.encodePacked(
                acc,
                count,
                keccak256(abi.encodePacked(address(0), l1BlockNumber, timestamp)),
                keccak256(emptyBytes)
            )
        );
        count++;
        totalDelayedMessagesRead = _totalDelayedMessagesRead;
        return (acc, count);
    }

    function proveSeqBatchMsgCount(
        bytes calldata proof,
        uint256 offset,
        bytes32 acc
    ) internal pure returns (uint256, uint256) {

        uint256 endCount;

        bytes32 buildingAcc;
        uint256 seqNum;
        bytes32 messageHeaderHash;
        bytes32 messageDataHash;
        (offset, buildingAcc) = Marshaling.deserializeBytes32(proof, offset);
        (offset, seqNum) = Marshaling.deserializeInt(proof, offset);
        (offset, messageHeaderHash) = Marshaling.deserializeBytes32(proof, offset);
        (offset, messageDataHash) = Marshaling.deserializeBytes32(proof, offset);
        buildingAcc = keccak256(
            abi.encodePacked(buildingAcc, seqNum, messageHeaderHash, messageDataHash)
        );
        endCount = seqNum + 1;
        require(buildingAcc == acc, "BATCH_ACC");

        return (offset, endCount);
    }

    function proveBatchContainsSequenceNumber(bytes calldata proof, uint256 inboxCount)
        external
        view
        override
        returns (uint256, bytes32)
    {

        if (inboxCount == 0) {
            return (0, 0);
        }

        (uint256 offset, uint256 seqBatchNum) = Marshaling.deserializeInt(proof, 0);
        uint256 lastBatchCount = 0;
        if (seqBatchNum > 0) {
            (offset, lastBatchCount) = proveSeqBatchMsgCount(
                proof,
                offset,
                inboxAccs[seqBatchNum - 1]
            );
            lastBatchCount++;
        }

        bytes32 seqBatchAcc = inboxAccs[seqBatchNum];
        uint256 thisBatchCount;
        (offset, thisBatchCount) = proveSeqBatchMsgCount(proof, offset, seqBatchAcc);

        require(inboxCount > lastBatchCount, "BATCH_START");
        require(inboxCount <= thisBatchCount, "BATCH_END");

        return (thisBatchCount, seqBatchAcc);
    }
}// Apache-2.0


pragma solidity ^0.6.11;



contract BridgeCreator is Ownable {

    Bridge public delayedBridgeTemplate;
    SequencerInbox public sequencerInboxTemplate;
    Inbox public inboxTemplate;
    RollupEventBridge public rollupEventBridgeTemplate;
    Outbox public outboxTemplate;

    event TemplatesUpdated();

    constructor() public Ownable() {
        delayedBridgeTemplate = new Bridge();
        sequencerInboxTemplate = new SequencerInbox();
        inboxTemplate = new Inbox();
        rollupEventBridgeTemplate = new RollupEventBridge();
        outboxTemplate = new Outbox();
    }

    function updateTemplates(
        address _delayedBridgeTemplate,
        address _sequencerInboxTemplate,
        address _inboxTemplate,
        address _rollupEventBridgeTemplate,
        address _outboxTemplate
    ) external onlyOwner {

        delayedBridgeTemplate = Bridge(_delayedBridgeTemplate);
        sequencerInboxTemplate = SequencerInbox(_sequencerInboxTemplate);
        inboxTemplate = Inbox(_inboxTemplate);
        rollupEventBridgeTemplate = RollupEventBridge(_rollupEventBridgeTemplate);
        outboxTemplate = Outbox(_outboxTemplate);

        emit TemplatesUpdated();
    }

    struct CreateBridgeFrame {
        ProxyAdmin admin;
        Bridge delayedBridge;
        SequencerInbox sequencerInbox;
        Inbox inbox;
        RollupEventBridge rollupEventBridge;
        Outbox outbox;
        Whitelist whitelist;
    }

    function createBridge(
        address adminProxy,
        address rollup,
        address sequencer
    )
        external
        returns (
            Bridge,
            SequencerInbox,
            Inbox,
            RollupEventBridge,
            Outbox
        )
    {

        CreateBridgeFrame memory frame;
        {
            frame.delayedBridge = Bridge(
                address(
                    new TransparentUpgradeableProxy(address(delayedBridgeTemplate), adminProxy, "")
                )
            );
            frame.sequencerInbox = SequencerInbox(
                address(
                    new TransparentUpgradeableProxy(address(sequencerInboxTemplate), adminProxy, "")
                )
            );
            frame.inbox = Inbox(
                address(new TransparentUpgradeableProxy(address(inboxTemplate), adminProxy, ""))
            );
            frame.rollupEventBridge = RollupEventBridge(
                address(
                    new TransparentUpgradeableProxy(
                        address(rollupEventBridgeTemplate),
                        adminProxy,
                        ""
                    )
                )
            );
            frame.outbox = Outbox(
                address(new TransparentUpgradeableProxy(address(outboxTemplate), adminProxy, ""))
            );
            frame.whitelist = new Whitelist();
        }

        frame.delayedBridge.initialize();
        frame.sequencerInbox.initialize(IBridge(frame.delayedBridge), sequencer, rollup);
        frame.inbox.initialize(IBridge(frame.delayedBridge), address(frame.whitelist));
        frame.rollupEventBridge.initialize(address(frame.delayedBridge), rollup);
        frame.outbox.initialize(rollup, IBridge(frame.delayedBridge));

        frame.delayedBridge.setInbox(address(frame.inbox), true);
        frame.delayedBridge.transferOwnership(rollup);

        frame.whitelist.setOwner(rollup);

        return (
            frame.delayedBridge,
            frame.sequencerInbox,
            frame.inbox,
            frame.rollupEventBridge,
            frame.outbox
        );
    }
}// Apache-2.0

pragma solidity ^0.6.11;


abstract contract AbsRollupUserFacet is RollupBase, IRollupUser {
    function initialize(address _stakeToken) public virtual override;

    uint8 internal constant MAX_SEND_COUNT = 100;

    modifier onlyValidator {
        require(isValidator[msg.sender], "NOT_VALIDATOR");
        _;
    }

    function rejectNextNode(address stakerAddress) external onlyValidator whenNotPaused {
        requireUnresolvedExists();
        uint256 latest = latestConfirmed();
        uint256 firstUnresolved = firstUnresolvedNode();
        INode node = getNode(firstUnresolved);
        if (node.prev() == latest) {
            require(isStaked(stakerAddress), "NOT_STAKED");
            requireUnresolved(latestStakedNode(stakerAddress));
            require(!node.stakers(stakerAddress), "STAKED_ON_TARGET");

            node.requirePastDeadline();

            getNode(latest).requirePastChildConfirmDeadline();

            removeOldZombies(0);

            require(node.stakerCount() == countStakedZombies(node), "HAS_STAKERS");
        }
        rejectNextNode();
        rollupEventBridge.nodeRejected(firstUnresolved);

        emit NodeRejected(firstUnresolved);
    }

    function confirmNextNode(
        bytes32 beforeSendAcc,
        bytes calldata sendsData,
        uint256[] calldata sendLengths,
        uint256 afterSendCount,
        bytes32 afterLogAcc,
        uint256 afterLogCount
    ) external onlyValidator whenNotPaused {
        requireUnresolvedExists();

        require(stakerCount() > 0, "NO_STAKERS");

        uint256 firstUnresolved = firstUnresolvedNode();
        INode node = getNode(firstUnresolved);

        node.requirePastDeadline();

        require(node.prev() == latestConfirmed(), "INVALID_PREV");

        getNode(latestConfirmed()).requirePastChildConfirmDeadline();

        removeOldZombies(0);

        require(
            node.stakerCount() == stakerCount().add(countStakedZombies(node)),
            "NOT_ALL_STAKED"
        );

        bytes32 afterSendAcc = RollupLib.feedAccumulator(sendsData, sendLengths, beforeSendAcc);
        require(
            node.confirmData() ==
                RollupLib.confirmHash(
                    beforeSendAcc,
                    afterSendAcc,
                    afterLogAcc,
                    afterSendCount,
                    afterLogCount
                ),
            "CONFIRM_DATA"
        );

        outbox.processOutgoingMessages(sendsData, sendLengths);

        confirmNextNode();

        rollupEventBridge.nodeConfirmed(firstUnresolved);

        emit NodeConfirmed(
            firstUnresolved,
            afterSendAcc,
            afterSendCount,
            afterLogAcc,
            afterLogCount
        );
    }

    function _newStake(uint256 depositAmount) internal onlyValidator whenNotPaused {
        require(!isStaked(msg.sender), "ALREADY_STAKED");
        require(!isZombie(msg.sender), "STAKER_IS_ZOMBIE");
        require(depositAmount >= currentRequiredStake(), "NOT_ENOUGH_STAKE");

        createNewStake(msg.sender, depositAmount);

        rollupEventBridge.stakeCreated(msg.sender, latestConfirmed());
    }

    function stakeOnExistingNode(uint256 nodeNum, bytes32 nodeHash)
        external
        onlyValidator
        whenNotPaused
    {
        require(isStaked(msg.sender), "NOT_STAKED");

        require(getNodeHash(nodeNum) == nodeHash, "NODE_REORG");
        require(nodeNum >= firstUnresolvedNode() && nodeNum <= latestNodeCreated());
        INode node = getNode(nodeNum);
        require(latestStakedNode(msg.sender) == node.prev(), "NOT_STAKED_PREV");
        stakeOnNode(msg.sender, nodeNum, confirmPeriodBlocks);
    }

    struct StakeOnNewNodeFrame {
        uint256 sequencerBatchEnd;
        bytes32 sequencerBatchAcc;
        uint256 currentInboxSize;
        INode node;
        bytes32 executionHash;
        INode prevNode;
    }

    function stakeOnNewNode(
        bytes32 expectedNodeHash,
        bytes32[3][2] calldata assertionBytes32Fields,
        uint256[4][2] calldata assertionIntFields,
        uint256 beforeProposedBlock,
        uint256 beforeInboxMaxCount,
        bytes calldata sequencerBatchProof
    ) external onlyValidator whenNotPaused {
        require(isStaked(msg.sender), "NOT_STAKED");

        uint256 prevNodeNum = latestStakedNode(msg.sender);
        StakeOnNewNodeFrame memory frame;
        {
            INode prevNode = getNode(prevNodeNum);
            uint256 currentInboxSize = sequencerBridge.messageCount();

            RollupLib.Assertion memory assertion =
                RollupLib.decodeAssertion(
                    assertionBytes32Fields,
                    assertionIntFields,
                    beforeProposedBlock,
                    beforeInboxMaxCount,
                    currentInboxSize
                );

            uint256 sequencerBatchEnd;
            bytes32 sequencerBatchAcc;
            uint256 deadlineBlock;
            {
                require(
                    RollupLib.stateHash(assertion.beforeState) == prevNode.stateHash(),
                    "PREV_STATE_HASH"
                );

                (sequencerBatchEnd, sequencerBatchAcc) = sequencerBridge
                    .proveBatchContainsSequenceNumber(
                    sequencerBatchProof,
                    assertion.afterState.inboxCount
                );

                uint256 timeSinceLastNode = block.number.sub(assertion.beforeState.proposedBlock);
                require(timeSinceLastNode >= minimumAssertionPeriod, "TIME_DELTA");

                uint256 gasUsed = assertion.afterState.gasUsed.sub(assertion.beforeState.gasUsed);
                require(
                    assertion.afterState.inboxCount >= assertion.beforeState.inboxMaxCount ||
                        gasUsed >= timeSinceLastNode.mul(arbGasSpeedLimitPerBlock) ||
                        assertion.afterState.sendCount.sub(assertion.beforeState.sendCount) ==
                        MAX_SEND_COUNT,
                    "TOO_SMALL"
                );

                require(
                    gasUsed <= timeSinceLastNode.mul(arbGasSpeedLimitPerBlock).mul(4),
                    "TOO_LARGE"
                );

                {
                    uint256 checkTime =
                        gasUsed.add(arbGasSpeedLimitPerBlock.sub(1)).div(arbGasSpeedLimitPerBlock);
                    deadlineBlock = max(
                        block.number.add(confirmPeriodBlocks),
                        prevNode.deadlineBlock()
                    )
                        .add(checkTime);
                    uint256 olderSibling = prevNode.latestChildNumber();
                    if (olderSibling != 0) {
                        deadlineBlock = max(deadlineBlock, getNode(olderSibling).deadlineBlock());
                    }
                }
                require(assertion.afterState.inboxCount <= currentInboxSize, "INBOX_PAST_END");
            }

            bytes32 nodeHash;
            {
                bytes32 lastHash;
                bool hasSibling = prevNode.latestChildNumber() > 0;
                if (hasSibling) {
                    lastHash = getNodeHash(prevNode.latestChildNumber());
                } else {
                    lastHash = getNodeHash(prevNodeNum);
                }

                (nodeHash, frame) = createNewNode(
                    assertion,
                    deadlineBlock,
                    sequencerBatchEnd,
                    sequencerBatchAcc,
                    prevNodeNum,
                    lastHash,
                    hasSibling
                );
            }
            require(nodeHash == expectedNodeHash, "UNEXPECTED_NODE_HASH");
            stakeOnNode(msg.sender, latestNodeCreated(), confirmPeriodBlocks);
        }

        emit NodeCreated(
            latestNodeCreated(),
            getNodeHash(prevNodeNum),
            expectedNodeHash,
            frame.executionHash,
            frame.currentInboxSize,
            frame.sequencerBatchEnd,
            frame.sequencerBatchAcc,
            assertionBytes32Fields,
            assertionIntFields
        );
    }

    function createNewNode(
        RollupLib.Assertion memory assertion,
        uint256 deadlineBlock,
        uint256 sequencerBatchEnd,
        bytes32 sequencerBatchAcc,
        uint256 prevNode,
        bytes32 prevHash,
        bool hasSibling
    ) internal returns (bytes32, StakeOnNewNodeFrame memory) {
        StakeOnNewNodeFrame memory frame;
        frame.currentInboxSize = sequencerBridge.messageCount();
        frame.prevNode = getNode(prevNode);
        {
            uint256 nodeNum = latestNodeCreated() + 1;
            frame.executionHash = RollupLib.executionHash(assertion);

            frame.sequencerBatchEnd = sequencerBatchEnd;
            frame.sequencerBatchAcc = sequencerBatchAcc;

            rollupEventBridge.nodeCreated(nodeNum, prevNode, deadlineBlock, msg.sender);

            frame.node = INode(
                nodeFactory.createNode(
                    RollupLib.stateHash(assertion.afterState),
                    RollupLib.challengeRoot(assertion, frame.executionHash, block.number),
                    RollupLib.confirmHash(assertion),
                    prevNode,
                    deadlineBlock
                )
            );
        }

        bytes32 nodeHash =
            RollupLib.nodeHash(hasSibling, prevHash, frame.executionHash, frame.sequencerBatchAcc);

        nodeCreated(frame.node, nodeHash);
        frame.prevNode.childCreated(latestNodeCreated());

        return (nodeHash, frame);
    }

    function returnOldDeposit(address stakerAddress) external override onlyValidator whenNotPaused {
        require(latestStakedNode(stakerAddress) <= latestConfirmed(), "TOO_RECENT");
        requireUnchallengedStaker(stakerAddress);
        withdrawStaker(stakerAddress);
    }

    function _addToDeposit(address stakerAddress, uint256 depositAmount)
        internal
        onlyValidator
        whenNotPaused
    {
        requireUnchallengedStaker(stakerAddress);
        increaseStakeBy(stakerAddress, depositAmount);
    }

    function reduceDeposit(uint256 target) external onlyValidator whenNotPaused {
        requireUnchallengedStaker(msg.sender);
        uint256 currentRequired = currentRequiredStake();
        if (target < currentRequired) {
            target = currentRequired;
        }
        reduceStakeTo(msg.sender, target);
    }

    function createChallenge(
        address payable[2] calldata stakers,
        uint256[2] calldata nodeNums,
        bytes32[2] calldata executionHashes,
        uint256[2] calldata proposedTimes,
        uint256[2] calldata maxMessageCounts
    ) external onlyValidator whenNotPaused {
        require(nodeNums[0] < nodeNums[1], "WRONG_ORDER");
        require(nodeNums[1] <= latestNodeCreated(), "NOT_PROPOSED");
        require(latestConfirmed() < nodeNums[0], "ALREADY_CONFIRMED");

        INode node1 = getNode(nodeNums[0]);
        INode node2 = getNode(nodeNums[1]);

        require(node1.prev() == node2.prev(), "DIFF_PREV");

        requireUnchallengedStaker(stakers[0]);
        requireUnchallengedStaker(stakers[1]);

        require(node1.stakers(stakers[0]), "STAKER1_NOT_STAKED");
        require(node2.stakers(stakers[1]), "STAKER2_NOT_STAKED");

        require(
            node1.challengeHash() ==
                RollupLib.challengeRootHash(
                    executionHashes[0],
                    proposedTimes[0],
                    maxMessageCounts[0]
                ),
            "CHAL_HASH1"
        );

        require(
            node2.challengeHash() ==
                RollupLib.challengeRootHash(
                    executionHashes[1],
                    proposedTimes[1],
                    maxMessageCounts[1]
                ),
            "CHAL_HASH2"
        );

        uint256 commonEndTime =
            node1.deadlineBlock().sub(proposedTimes[0]).add(extraChallengeTimeBlocks).add(
                getNode(node1.prev()).firstChildBlock()
            );
        if (commonEndTime < proposedTimes[1]) {
            completeChallengeImpl(stakers[0], stakers[1]);
            return;
        }
        address challengeAddress =
            challengeFactory.createChallenge(
                address(this),
                executionHashes[0],
                maxMessageCounts[0],
                stakers[0],
                stakers[1],
                commonEndTime.sub(proposedTimes[0]),
                commonEndTime.sub(proposedTimes[1]),
                sequencerBridge,
                delayedBridge
            );

        challengeStarted(stakers[0], stakers[1], challengeAddress);

        emit RollupChallengeStarted(challengeAddress, stakers[0], stakers[1], nodeNums[0]);
    }

    function completeChallenge(address winningStaker, address losingStaker)
        external
        override
        whenNotPaused
    {
        require(msg.sender == inChallenge(winningStaker, losingStaker), "WRONG_SENDER");

        completeChallengeImpl(winningStaker, losingStaker);
    }

    function completeChallengeImpl(address winningStaker, address losingStaker) private {
        uint256 remainingLoserStake = amountStaked(losingStaker);
        uint256 winnerStake = amountStaked(winningStaker);
        if (remainingLoserStake > winnerStake) {
            remainingLoserStake = remainingLoserStake.sub(reduceStakeTo(losingStaker, winnerStake));
        }

        uint256 amountWon = remainingLoserStake / 2;
        increaseStakeBy(winningStaker, amountWon);
        remainingLoserStake = remainingLoserStake.sub(amountWon);
        clearChallenge(winningStaker);

        increaseWithdrawableFunds(owner, remainingLoserStake);
        turnIntoZombie(losingStaker);
    }

    function removeZombie(uint256 zombieNum, uint256 maxNodes)
        external
        onlyValidator
        whenNotPaused
    {
        require(zombieNum <= zombieCount(), "NO_SUCH_ZOMBIE");
        address zombieStakerAddress = zombieAddress(zombieNum);
        uint256 latestStakedNode = zombieLatestStakedNode(zombieNum);
        uint256 nodesRemoved = 0;
        uint256 firstUnresolved = firstUnresolvedNode();
        while (latestStakedNode >= firstUnresolved && nodesRemoved < maxNodes) {
            INode node = getNode(latestStakedNode);
            node.removeStaker(zombieStakerAddress);
            latestStakedNode = node.prev();
            nodesRemoved++;
        }
        if (latestStakedNode < firstUnresolved) {
            removeZombie(zombieNum);
        } else {
            zombieUpdateLatestStakedNode(zombieNum, latestStakedNode);
        }
    }

    function removeOldZombies(uint256 startIndex) public {
        uint256 currentZombieCount = zombieCount();
        uint256 firstUnresolved = firstUnresolvedNode();
        for (uint256 i = startIndex; i < currentZombieCount; i++) {
            while (zombieLatestStakedNode(i) < firstUnresolved) {
                removeZombie(i);
                currentZombieCount--;
                if (i >= currentZombieCount) {
                    return;
                }
            }
        }
    }

    function currentRequiredStake(
        uint256 _blockNumber,
        uint256 _firstUnresolvedNodeNum,
        uint256 _latestNodeCreated
    ) internal view returns (uint256) {
        if (_firstUnresolvedNodeNum - 1 == _latestNodeCreated) {
            return baseStake;
        }
        uint256 firstUnresolvedDeadline = getNode(_firstUnresolvedNodeNum).deadlineBlock();
        if (_blockNumber < firstUnresolvedDeadline) {
            return baseStake;
        }
        uint24[10] memory numerators =
            [1, 122971, 128977, 80017, 207329, 114243, 314252, 129988, 224562, 162163];
        uint24[10] memory denominators =
            [1, 114736, 112281, 64994, 157126, 80782, 207329, 80017, 128977, 86901];
        uint256 firstUnresolvedAge = _blockNumber.sub(firstUnresolvedDeadline);
        uint256 periodsPassed = firstUnresolvedAge.mul(10).div(confirmPeriodBlocks);
        if (periodsPassed.div(10) >= 255) {
            return type(uint256).max;
        }
        uint256 baseMultiplier = 2**periodsPassed.div(10);
        uint256 withNumerator = baseMultiplier * numerators[periodsPassed % 10];
        if (withNumerator / baseMultiplier != numerators[periodsPassed % 10]) {
            return type(uint256).max;
        }
        uint256 multiplier = withNumerator.div(denominators[periodsPassed % 10]);
        if (multiplier == 0) {
            multiplier = 1;
        }
        uint256 fullStake = baseStake * multiplier;
        if (fullStake / baseStake != multiplier) {
            return type(uint256).max;
        }
        return fullStake;
    }

    function requiredStake(
        uint256 blockNumber,
        uint256 firstUnresolvedNodeNum,
        uint256 latestNodeCreated
    ) public view returns (uint256) {
        return currentRequiredStake(blockNumber, firstUnresolvedNodeNum, latestNodeCreated);
    }

    function currentRequiredStake() public view returns (uint256) {
        uint256 firstUnresolvedNodeNum = firstUnresolvedNode();

        return currentRequiredStake(block.number, firstUnresolvedNodeNum, latestNodeCreated());
    }

    function countStakedZombies(INode node) public view override returns (uint256) {
        uint256 currentZombieCount = zombieCount();
        uint256 stakedZombieCount = 0;
        for (uint256 i = 0; i < currentZombieCount; i++) {
            if (node.stakers(zombieAddress(i))) {
                stakedZombieCount++;
            }
        }
        return stakedZombieCount;
    }

    function requireUnresolvedExists() public view override {
        uint256 firstUnresolved = firstUnresolvedNode();
        require(
            firstUnresolved > latestConfirmed() && firstUnresolved <= latestNodeCreated(),
            "NO_UNRESOLVED"
        );
    }

    function requireUnresolved(uint256 nodeNum) public view override {
        require(nodeNum >= firstUnresolvedNode(), "ALREADY_DECIDED");
        require(nodeNum <= latestNodeCreated(), "DOESNT_EXIST");
    }

    function requireUnchallengedStaker(address stakerAddress) private view {
        require(isStaked(stakerAddress), "NOT_STAKED");
        require(currentChallenge(stakerAddress) == address(0), "IN_CHAL");
    }

    function withdrawStakerFunds(address payable destination) external virtual returns (uint256);
}

contract RollupUserFacet is AbsRollupUserFacet {

    function initialize(address _stakeToken) public override {

        require(_stakeToken == address(0), "NO_TOKEN_ALLOWED");
    }

    function newStake() external payable onlyValidator whenNotPaused {

        _newStake(msg.value);
    }

    function addToDeposit(address stakerAddress) external payable onlyValidator whenNotPaused {

        _addToDeposit(stakerAddress, msg.value);
    }

    function withdrawStakerFunds(address payable destination)
        external
        override
        onlyValidator
        whenNotPaused
        returns (uint256)
    {

        uint256 amount = withdrawFunds(msg.sender);
        destination.transfer(amount);
        return amount;
    }
}

contract ERC20RollupUserFacet is AbsRollupUserFacet {

    function initialize(address _stakeToken) public override {

        require(_stakeToken != address(0), "NEED_STAKE_TOKEN");
        require(stakeToken == address(0), "ALREADY_INIT");
        stakeToken = _stakeToken;
    }

    function newStake(uint256 tokenAmount) external onlyValidator whenNotPaused {

        _newStake(tokenAmount);
        require(
            IERC20(stakeToken).transferFrom(msg.sender, address(this), tokenAmount),
            "TRANSFER_FAIL"
        );
    }

    function addToDeposit(address stakerAddress, uint256 tokenAmount)
        external
        onlyValidator
        whenNotPaused
    {

        _addToDeposit(stakerAddress, tokenAmount);
        require(
            IERC20(stakeToken).transferFrom(msg.sender, address(this), tokenAmount),
            "TRANSFER_FAIL"
        );
    }

    function withdrawStakerFunds(address payable destination)
        external
        override
        onlyValidator
        whenNotPaused
        returns (uint256)
    {

        uint256 amount = withdrawFunds(msg.sender);
        require(IERC20(stakeToken).transfer(destination, amount), "TRANSFER_FAILED");
        return amount;
    }
}// Apache-2.0

pragma solidity ^0.6.11;



contract RollupAdminFacet is RollupBase, IRollupAdmin {


    function setOutbox(IOutbox _outbox) external override {

        outbox = _outbox;
        delayedBridge.setOutbox(address(_outbox), true);
        emit OwnerFunctionCalled(0);
    }

    function removeOldOutbox(address _outbox) external override {

        require(_outbox != address(outbox), "CUR_OUTBOX");
        delayedBridge.setOutbox(_outbox, false);
        emit OwnerFunctionCalled(1);
    }

    function setInbox(address _inbox, bool _enabled) external override {

        delayedBridge.setInbox(address(_inbox), _enabled);
        emit OwnerFunctionCalled(2);
    }

    function pause() external override {

        _pause();
        emit OwnerFunctionCalled(3);
    }

    function resume() external override {

        _unpause();
        emit OwnerFunctionCalled(4);
    }

    function setFacets(address newAdminFacet, address newUserFacet) external override {

        facets[0] = newAdminFacet;
        facets[1] = newUserFacet;
        emit OwnerFunctionCalled(5);
    }

    function setValidator(address[] memory _validator, bool[] memory _val) external override {

        require(_validator.length == _val.length, "WRONG_LENGTH");

        for (uint256 i = 0; i < _validator.length; i++) {
            isValidator[_validator[i]] = _val[i];
        }
        emit OwnerFunctionCalled(6);
    }

    function setOwner(address newOwner) external override {

        owner = newOwner;
        emit OwnerFunctionCalled(7);
    }

    function setMinimumAssertionPeriod(uint256 newPeriod) external override {

        minimumAssertionPeriod = newPeriod;
        emit OwnerFunctionCalled(8);
    }

    function setConfirmPeriodBlocks(uint256 newConfirmPeriod) external override {

        confirmPeriodBlocks = newConfirmPeriod;
        emit OwnerFunctionCalled(9);
    }

    function setExtraChallengeTimeBlocks(uint256 newExtraTimeBlocks) external override {

        extraChallengeTimeBlocks = newExtraTimeBlocks;
        emit OwnerFunctionCalled(10);
    }

    function setArbGasSpeedLimitPerBlock(uint256 newArbGasSpeedLimitPerBlock) external override {

        arbGasSpeedLimitPerBlock = newArbGasSpeedLimitPerBlock;
        emit OwnerFunctionCalled(11);
    }

    function setBaseStake(uint256 newBaseStake) external override {

        baseStake = newBaseStake;
        emit OwnerFunctionCalled(12);
    }

    function setStakeToken(address newStakeToken) external override {

        stakeToken = newStakeToken;
        emit OwnerFunctionCalled(13);
    }

    function setSequencerInboxMaxDelayBlocks(uint256 newSequencerInboxMaxDelayBlocks)
        external
        override
    {

        sequencerInboxMaxDelayBlocks = newSequencerInboxMaxDelayBlocks;
        emit OwnerFunctionCalled(14);
    }

    function setSequencerInboxMaxDelaySeconds(uint256 newSequencerInboxMaxDelaySeconds)
        external
        override
    {

        sequencerInboxMaxDelaySeconds = newSequencerInboxMaxDelaySeconds;
        emit OwnerFunctionCalled(15);
    }

    function setChallengeExecutionBisectionDegree(uint256 newChallengeExecutionBisectionDegree)
        external
        override
    {

        challengeExecutionBisectionDegree = newChallengeExecutionBisectionDegree;
        emit OwnerFunctionCalled(16);
    }

    function updateWhitelistConsumers(
        address whitelist,
        address newWhitelist,
        address[] memory targets
    ) external override {

        Whitelist(whitelist).triggerConsumers(newWhitelist, targets);
        emit OwnerFunctionCalled(17);
    }

    function setWhitelistEntries(
        address whitelist,
        address[] memory user,
        bool[] memory val
    ) external override {

        require(user.length == val.length, "INVALID_INPUT");
        Whitelist(whitelist).setWhitelist(user, val);
        emit OwnerFunctionCalled(18);
    }

    function setSequencer(address newSequencer) external override {

        ISequencerInbox(sequencerBridge).setSequencer(newSequencer);
        emit OwnerFunctionCalled(19);
    }

    function upgradeBeacon(address beacon, address newImplementation) external override {

        UpgradeableBeacon(beacon).upgradeTo(newImplementation);
        emit OwnerFunctionCalled(20);
    }

}// Apache-2.0


pragma solidity ^0.6.11;





contract RollupCreator is Ownable {

    event RollupCreated(address indexed rollupAddress, address inboxAddress, address adminProxy);
    event TemplatesUpdated();

    BridgeCreator public bridgeCreator;
    ICloneable public rollupTemplate;
    address public challengeFactory;
    address public nodeFactory;
    address public rollupAdminFacet;
    address public rollupUserFacet;

    constructor() public Ownable() {}

    function setTemplates(
        BridgeCreator _bridgeCreator,
        ICloneable _rollupTemplate,
        address _challengeFactory,
        address _nodeFactory,
        address _rollupAdminFacet,
        address _rollupUserFacet
    ) external onlyOwner {

        bridgeCreator = _bridgeCreator;
        rollupTemplate = _rollupTemplate;
        challengeFactory = _challengeFactory;
        nodeFactory = _nodeFactory;
        rollupAdminFacet = _rollupAdminFacet;
        rollupUserFacet = _rollupUserFacet;
        emit TemplatesUpdated();
    }

    function createRollup(
        bytes32 _machineHash,
        uint256 _confirmPeriodBlocks,
        uint256 _extraChallengeTimeBlocks,
        uint256 _arbGasSpeedLimitPerBlock,
        uint256 _baseStake,
        address _stakeToken,
        address _owner,
        address _sequencer,
        uint256 _sequencerDelayBlocks,
        uint256 _sequencerDelaySeconds,
        bytes calldata _extraConfig
    ) external returns (address) {

        return
            createRollup(
                RollupLib.Config(
                    _machineHash,
                    _confirmPeriodBlocks,
                    _extraChallengeTimeBlocks,
                    _arbGasSpeedLimitPerBlock,
                    _baseStake,
                    _stakeToken,
                    _owner,
                    _sequencer,
                    _sequencerDelayBlocks,
                    _sequencerDelaySeconds,
                    _extraConfig
                )
            );
    }

    struct CreateRollupFrame {
        ProxyAdmin admin;
        Bridge delayedBridge;
        SequencerInbox sequencerInbox;
        Inbox inbox;
        RollupEventBridge rollupEventBridge;
        Outbox outbox;
        address rollup;
    }

    function createRollup(RollupLib.Config memory config) private returns (address) {

        CreateRollupFrame memory frame;
        frame.admin = new ProxyAdmin();
        frame.rollup = address(
            new TransparentUpgradeableProxy(address(rollupTemplate), address(frame.admin), "")
        );

        (
            frame.delayedBridge,
            frame.sequencerInbox,
            frame.inbox,
            frame.rollupEventBridge,
            frame.outbox
        ) = bridgeCreator.createBridge(address(frame.admin), frame.rollup, config.sequencer);

        frame.admin.transferOwnership(config.owner);
        Rollup(payable(frame.rollup)).initialize(
            config.machineHash,
            [
                config.confirmPeriodBlocks,
                config.extraChallengeTimeBlocks,
                config.arbGasSpeedLimitPerBlock,
                config.baseStake
            ],
            config.stakeToken,
            config.owner,
            config.extraConfig,
            [
                address(frame.delayedBridge),
                address(frame.sequencerInbox),
                address(frame.outbox),
                address(frame.rollupEventBridge),
                challengeFactory,
                nodeFactory
            ],
            [rollupAdminFacet, rollupUserFacet],
            [config.sequencerDelayBlocks, config.sequencerDelaySeconds]
        );

        emit RollupCreated(frame.rollup, address(frame.inbox), address(frame.admin));
        return frame.rollup;
    }
}