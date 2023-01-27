
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

pragma solidity ^0.7.0;


abstract contract Pausable is Context {
    event Paused(address account);

    event Unpaused(address account);

    bool private _paused;

    constructor () {
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
}// MIT
pragma solidity 0.7.6;


abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    constructor() {
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

    function _transferOwnership(address newOwner) internal virtual onlyOwner {
        require(
            newOwner != address(0),
            "Ownable: new owner is the zero address"
        );
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

abstract contract TransferOwnable is Ownable {
    function transferOwnership(address newOwner) public virtual onlyOwner {
        _transferOwnership(newOwner);
    }
}// MIT

pragma solidity ^0.7.0;

library EnumerableSet {


    struct Set {
        bytes32[] _values;

        mapping (bytes32 => uint256) _indexes;
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

        if (valueIndex != 0) { // Equivalent to contains(set, value)

            uint256 toDeleteIndex = valueIndex - 1;
            uint256 lastIndex = set._values.length - 1;


            bytes32 lastvalue = set._values[lastIndex];

            set._values[toDeleteIndex] = lastvalue;
            set._indexes[lastvalue] = toDeleteIndex + 1; // All indexes are 1-based

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

        require(set._values.length > index, "EnumerableSet: index out of bounds");
        return set._values[index];
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
}// LGPL-3.0-only
pragma solidity 0.7.6;

contract Enum {

    enum Operation {
        Call,
        DelegateCall
    }
}

interface GnosisSafe {

    function execTransactionFromModule(
        address to,
        uint256 value,
        bytes memory data,
        Enum.Operation operation
    ) external returns (bool success);

}// LGPL-3.0-only
pragma solidity 0.7.6;
pragma abicoder v2;


contract CoboSafeModule is Ownable {

    using EnumerableSet for EnumerableSet.Bytes32Set;
    using EnumerableSet for EnumerableSet.AddressSet;

    string public constant NAME = "Cobo Safe Module";
    string public constant VERSION = "0.2.2";


    bytes32 public constant ROLE_HARVESTER =
        0x6861727665737465727300000000000000000000000000000000000000000000;

    event DelegateAdded(address indexed delegate, address indexed sender);

    event DelegateRemoved(address indexed delegate, address indexed sender);

    event RoleAdded(bytes32 indexed role, address indexed sender);

    event RoleGranted(
        bytes32 indexed role,
        address indexed delegate,
        address indexed sender
    );

    event RoleRevoked(
        bytes32 indexed role,
        address indexed delegate,
        address indexed sender
    );

    event ExecTransaction(
        address indexed to,
        uint256 value,
        Enum.Operation operation,
        bytes data,
        address indexed sender
    );

    event AssocContractFuncs(
        bytes32 indexed role,
        address indexed _contract,
        string[] funcList,
        address indexed sender
    );

    event DissocContractFuncs(
        bytes32 indexed role,
        address indexed _contract,
        string[] funcList,
        address indexed sender
    );

    EnumerableSet.AddressSet delegateSet;

    mapping(address => EnumerableSet.Bytes32Set) delegateToRoles;

    EnumerableSet.Bytes32Set roleSet;

    EnumerableSet.AddressSet contractSet;

    mapping(address => EnumerableSet.Bytes32Set) contractToFuncs;

    mapping(address => mapping(bytes32 => EnumerableSet.Bytes32Set)) funcToRoles;

    modifier onlyDelegate() {

        require(isDelegate(_msgSender()), "must be delegate");
        _;
    }

    modifier roleDefined(bytes32 role) {

        require(roleSet.contains(role), "unrecognized role");
        _;
    }

    constructor(address payable _safe) {
        require(_safe != address(0), "invalid safe address");

        addRole(ROLE_HARVESTER);

        _transferOwnership(_safe);
    }

    function isDelegate(address delegate) public view returns (bool) {

        return delegateSet.contains(delegate);
    }

    function grantRole(bytes32 role, address delegate)
        external
        onlyOwner
        roleDefined(role)
    {

        require(!_hasRole(role, delegate), "role already granted");

        delegateToRoles[delegate].add(role);

        if (delegateSet.add(delegate)) {
            emit DelegateAdded(delegate, _msgSender());
        }

        emit RoleGranted(role, delegate, _msgSender());
    }

    function revokeRole(bytes32 role, address delegate)
        external
        onlyOwner
        roleDefined(role)
    {

        require(_hasRole(role, delegate), "role has not been granted");

        delegateToRoles[delegate].remove(role);

        emit RoleRevoked(role, delegate, _msgSender());

        if (delegateToRoles[delegate].length() == 0) {
            delegateSet.remove(delegate);
            emit DelegateRemoved(delegate, _msgSender());
        }
    }

    function hasRole(bytes32 role, address delegate)
        external
        view
        roleDefined(role)
        returns (bool)
    {

        return _hasRole(role, delegate);
    }

    function _hasRole(bytes32 role, address delegate)
        internal
        view
        returns (bool)
    {

        return delegateToRoles[delegate].contains(role);
    }

    function addRole(bytes32 role) public onlyOwner {

        require(!roleSet.contains(role), "role exists");

        roleSet.add(role);

        emit RoleAdded(role, _msgSender());
    }

    function execTransaction(address to, bytes calldata data)
        external
        onlyDelegate
    {

        _execTransaction(to, data);
    }

    function batchExecTransactions(
        address[] calldata toList,
        bytes[] calldata dataList
    ) external onlyDelegate {

        require(
            toList.length > 0 && toList.length == dataList.length,
            "invalid inputs"
        );

        for (uint256 i = 0; i < toList.length; i++) {
            _execTransaction(toList[i], dataList[i]);
        }
    }

    function _execTransaction(address to, bytes memory data) internal {

        bytes4 selector;
        assembly {
            selector := mload(add(data, 0x20))
        }

        require(
            _hasPermission(_msgSender(), to, selector),
            "permission denied"
        );

        require(
            GnosisSafe(payable(owner())).execTransactionFromModule(
                to,
                0,
                data,
                Enum.Operation.Call
            ),
            "failed in execution in safe"
        );

        emit ExecTransaction(to, 0, Enum.Operation.Call, data, _msgSender());
    }

    function _hasPermission(
        address delegate,
        address to,
        bytes4 selector
    ) internal view returns (bool) {

        bytes32[] memory roles = getRolesByDelegate(delegate);
        EnumerableSet.Bytes32Set storage funcRoles = funcToRoles[to][selector];
        for (uint256 index = 0; index < roles.length; index++) {
            if (funcRoles.contains(roles[index])) {
                return true;
            }
        }
        return false;
    }

    function hasPermission(
        address delegate,
        address to,
        bytes4 selector
    ) external view returns (bool) {

        if (!isDelegate(delegate)) {
            return false;
        }

        return _hasPermission(delegate, to, selector);
    }

    function assocRoleWithContractFuncs(
        bytes32 role,
        address _contract,
        string[] calldata funcList
    ) external onlyOwner roleDefined(role) {

        require(funcList.length > 0, "empty funcList");

        for (uint256 index = 0; index < funcList.length; index++) {
            bytes4 funcSelector = bytes4(keccak256(bytes(funcList[index])));
            bytes32 funcSelector32 = bytes32(funcSelector);
            funcToRoles[_contract][funcSelector32].add(role);
            contractToFuncs[_contract].add(funcSelector32);
        }

        contractSet.add(_contract);

        emit AssocContractFuncs(role, _contract, funcList, _msgSender());
    }

    function dissocRoleFromContractFuncs(
        bytes32 role,
        address _contract,
        string[] calldata funcList
    ) external onlyOwner roleDefined(role) {

        require(funcList.length > 0, "empty funcList");

        for (uint256 index = 0; index < funcList.length; index++) {
            bytes4 funcSelector = bytes4(keccak256(bytes(funcList[index])));
            bytes32 funcSelector32 = bytes32(funcSelector);
            funcToRoles[_contract][funcSelector32].remove(role);

            if (funcToRoles[_contract][funcSelector32].length() <= 0) {
                contractToFuncs[_contract].remove(funcSelector32);
            }
        }

        if (contractToFuncs[_contract].length() <= 0) {
            contractSet.remove(_contract);
        }

        emit DissocContractFuncs(role, _contract, funcList, _msgSender());
    }

    function getAllDelegates() public view returns (address[] memory) {

        bytes32[] memory store = delegateSet._inner._values;
        address[] memory result;
        assembly {
            result := store
        }
        return result;
    }

    function getRolesByDelegate(address delegate)
        public
        view
        returns (bytes32[] memory)
    {

        return delegateToRoles[delegate]._inner._values;
    }

    function getAllRoles() external view returns (bytes32[] memory) {

        return roleSet._inner._values;
    }

    function getAllContracts() public view returns (address[] memory) {

        bytes32[] memory store = contractSet._inner._values;
        address[] memory result;
        assembly {
            result := store
        }
        return result;
    }

    function getFuncsByContract(address _contract)
        public
        view
        returns (bytes4[] memory)
    {

        bytes32[] memory store = contractToFuncs[_contract]._inner._values;
        bytes4[] memory result;
        assembly {
            result := store
        }
        return result;
    }

    function getRolesByContractFunction(address _contract, bytes4 funcSelector)
        public
        view
        returns (bytes32[] memory)
    {

        return funcToRoles[_contract][funcSelector]._inner._values;
    }
}// LGPL-3.0-only
pragma solidity 0.7.6;



contract CoboSafeFactory is TransferOwnable, Pausable {

    string public constant NAME = "Cobo Safe Factory";
    string public constant VERSION = "0.2.2";

    address[] public modules;
    mapping(address => address) public safeToModule;

    event NewModule(
        address indexed safe,
        address indexed module,
        address indexed sender
    );

    function modulesSize() public view returns (uint256) {

        return modules.length;
    }

    function createModule(address _safe)
        external
        whenNotPaused
        returns (address _module)
    {

        require(safeToModule[_safe] == address(0), "Module already created");
        bytes memory bytecode = type(CoboSafeModule).creationCode;
        bytes memory creationCode = abi.encodePacked(
            bytecode,
            abi.encode(_safe)
        );
        uint256 moduleIndex = modulesSize();
        bytes32 salt = keccak256(abi.encodePacked(address(this), moduleIndex));

        assembly {
            _module := create2(
                0,
                add(creationCode, 32),
                mload(creationCode),
                salt
            )
        }
        require(_module != address(0), "Failed to create module");
        modules.push(_module);
        safeToModule[_safe] = _module;

        emit NewModule(_safe, _module, _msgSender());
    }

    function setPaused(bool paused) external onlyOwner {

        if (paused) _pause();
        else _unpause();
    }
}