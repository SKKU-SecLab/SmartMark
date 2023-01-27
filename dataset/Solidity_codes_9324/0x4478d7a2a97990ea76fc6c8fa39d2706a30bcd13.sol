
pragma solidity ^0.8.0;

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

pragma solidity ^0.8.0;


interface IERC20Metadata is IERC20 {

    function name() external view returns (string memory);


    function symbol() external view returns (string memory);


    function decimals() external view returns (uint8);

}// MIT

pragma solidity ^0.8.0;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}// MIT

pragma solidity ^0.8.0;


contract ERC20 is Context, IERC20, IERC20Metadata {

    mapping (address => uint256) private _balances;

    mapping (address => mapping (address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;

    constructor (string memory name_, string memory symbol_) {
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

    function transfer(address recipient, uint256 amount) public virtual override returns (bool) {

        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function allowance(address owner, address spender) public view virtual override returns (uint256) {

        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public virtual override returns (bool) {

        _approve(_msgSender(), spender, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) public virtual override returns (bool) {

        _transfer(sender, recipient, amount);

        uint256 currentAllowance = _allowances[sender][_msgSender()];
        require(currentAllowance >= amount, "ERC20: transfer amount exceeds allowance");
        _approve(sender, _msgSender(), currentAllowance - amount);

        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {

        _approve(_msgSender(), spender, _allowances[_msgSender()][spender] + addedValue);
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {

        uint256 currentAllowance = _allowances[_msgSender()][spender];
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
        _approve(_msgSender(), spender, currentAllowance - subtractedValue);

        return true;
    }

    function _transfer(address sender, address recipient, uint256 amount) internal virtual {

        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(sender, recipient, amount);

        uint256 senderBalance = _balances[sender];
        require(senderBalance >= amount, "ERC20: transfer amount exceeds balance");
        _balances[sender] = senderBalance - amount;
        _balances[recipient] += amount;

        emit Transfer(sender, recipient, amount);
    }

    function _mint(address account, uint256 amount) internal virtual {

        require(account != address(0), "ERC20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply += amount;
        _balances[account] += amount;
        emit Transfer(address(0), account, amount);
    }

    function _burn(address account, uint256 amount) internal virtual {

        require(account != address(0), "ERC20: burn from the zero address");

        _beforeTokenTransfer(account, address(0), amount);

        uint256 accountBalance = _balances[account];
        require(accountBalance >= amount, "ERC20: burn amount exceeds balance");
        _balances[account] = accountBalance - amount;
        _totalSupply -= amount;

        emit Transfer(account, address(0), amount);
    }

    function _approve(address owner, address spender, uint256 amount) internal virtual {

        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _beforeTokenTransfer(address from, address to, uint256 amount) internal virtual { }

}// MIT

pragma solidity ^0.8.0;

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

pragma solidity ^0.8.0;


library SafeERC20 {
    using Address for address;

    function safeTransfer(IERC20 token, address to, uint256 value) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(IERC20 token, address from, address to, uint256 value) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    function safeApprove(IERC20 token, address spender, uint256 value) internal {
        require((value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(IERC20 token, address spender, uint256 value) internal {
        uint256 newAllowance = token.allowance(address(this), spender) + value;
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(IERC20 token, address spender, uint256 value) internal {
        unchecked {
            uint256 oldAllowance = token.allowance(address(this), spender);
            require(oldAllowance >= value, "SafeERC20: decreased allowance below zero");
            uint256 newAllowance = oldAllowance - value;
            _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
        }
    }

    function _callOptionalReturn(IERC20 token, bytes memory data) private {

        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) { // Return data is optional
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}// MIT

pragma solidity ^0.8.0;


library SafeMath {
    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            uint256 c = a + b;
            if (c < a) return (false, 0);
            return (true, c);
        }
    }

    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b > a) return (false, 0);
            return (true, a - b);
        }
    }

    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (a == 0) return (true, 0);
            uint256 c = a * b;
            if (c / a != b) return (false, 0);
            return (true, c);
        }
    }

    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a / b);
        }
    }

    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a % b);
        }
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        return a + b;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return a - b;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        return a * b;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return a / b;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return a % b;
    }

    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        unchecked {
            require(b <= a, errorMessage);
            return a - b;
        }
    }

    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a / b;
        }
    }

    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a % b;
        }
    }
}// MIT

pragma solidity ^0.8.0;

library Math {
    function max(uint256 a, uint256 b) internal pure returns (uint256) {
        return a >= b ? a : b;
    }

    function min(uint256 a, uint256 b) internal pure returns (uint256) {
        return a < b ? a : b;
    }

    function average(uint256 a, uint256 b) internal pure returns (uint256) {
        return (a / 2) + (b / 2) + ((a % 2 + b % 2) / 2);
    }
}// MIT

pragma solidity ^0.8.0;

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
            set._indexes[lastvalue] = valueIndex; // Replace lastvalue's index to valueIndex

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
}pragma solidity >=0.5.17 <0.8.4;

interface IStrategy {

    function protocol() external view returns (uint256);

    function want() external view returns (address);

    function name() external view returns (string memory);
    function apy() external view returns (uint256);
    function updateApy(uint256 _apy) external;
    function vault() external view returns (address);


    function withdraw(uint256 _amount) external returns (uint256);

    function calAPY() external returns (uint256);

    function estimatedTotalAssets() external view returns (uint256);

    function migrate(address _newStrategy) external;

    function getInvestVaultAssets() external view returns (uint256);

    function withdrawToVault(uint256 correspondingShares, uint256 totalShares) external returns  (uint256 value, uint256 partialClaimValue, uint256 claimValue) ;

    function withdrawOneToken() external returns  (uint256 value, uint256 partialClaimValue, uint256 claimValue);



    function cutOffPosition(uint256 _debtOutstanding) external returns (uint256);

    function invest() external;
}pragma solidity ^0.8.0;


contract RankedList {

    event ObjectCreated(uint256 id, uint256 rank, address data);
    event ObjectsLinked(uint256 prev, uint256 next);
    event ObjectRemoved(uint256 id);
    event NewHead(uint256 id);
    event NewTail(uint256 id);

    struct Object{
        uint256 id;
        uint256 next;
        uint256 prev;
        uint256 rank;
        address data;
    }

    uint256 public head;
    uint256 public tail;
    uint256 public idCounter;
    mapping (uint256 => Object) public objects;

    constructor() public {
        head = 0;
        tail = 0;
        idCounter = 1;
    }

    function get(uint256 _id)
    public
    virtual
    view
    returns (uint256, uint256, uint256, uint256, address)
    {
        Object memory object = objects[_id];
        return (object.id, object.next, object.prev, object.rank, object.data);
    }

    function findRank(uint256 _rank)
    public
    virtual
    view
    returns (uint256)
    {
        Object memory object = objects[head];
        while (object.rank > _rank) {
            object = objects[object.next];
        }
        return object.id;
    }

    function insert(uint256 _rank, address _data)
    public
    virtual
    {
        uint256 nextId = findRank(_rank);
        if (nextId == 0) {
            _addTail(_rank, _data);
        }
        else {
            _insertBefore(nextId, _rank, _data);
        }
    }

    function remove(uint256 _id)
    public
    virtual
    {
        Object memory removeObject = objects[_id];
        if (head == _id && tail == _id) {
            _setHead(0);
            _setTail(0);
        }
        else if (head == _id) {
            _setHead(removeObject.next);
            objects[removeObject.next].prev = 0;
        }
        else if (tail == _id) {
            _setTail(removeObject.prev);
            objects[removeObject.prev].next = 0;
        }
        else {
            _link(removeObject.prev, removeObject.next);
        }
        delete objects[removeObject.id];
        emit ObjectRemoved(_id);
    }

    function _addHead(uint256 _rank, address _data)
    internal
    {
        uint256 objectId = _createObject(_rank, _data);
        _link(objectId, head);
        _setHead(objectId);
        if (tail == 0) _setTail(objectId);
    }

    function _addTail(uint256 _rank, address _data)
    internal
    {
        if (head == 0) {
            _addHead(_rank, _data);
        }
        else {
            uint256 objectId = _createObject(_rank, _data);
            _link(tail, objectId);
            _setTail(objectId);
        }
    }

    function _insertAfter(uint256 _prevId, uint256 _rank, address _data)
    internal
    {
        if (_prevId == tail) {
            _addTail(_rank, _data);
        }
        else {
            Object memory prevObject = objects[_prevId];
            Object memory nextObject = objects[prevObject.next];
            uint256 newObjectId = _createObject(_rank, _data);
            _link(newObjectId, nextObject.id);
            _link(prevObject.id, newObjectId);
        }
    }

    function _insertBefore(uint256 _nextId, uint256 _rank, address _data)
    internal
    {
        if (_nextId == head) {
            _addHead(_rank, _data);
        }
        else {
            _insertAfter(objects[_nextId].prev, _rank, _data);
        }
    }

    function _setHead(uint256 _id)
    internal
    {
        head = _id;
        emit NewHead(_id);
    }

    function _setTail(uint256 _id)
    internal
    {
        tail = _id;
        emit NewTail(_id);
    }

    function _createObject(uint256 _rank, address _data)
    internal
    returns (uint256)
    {
        uint256 newId = idCounter;
        idCounter += 1;
        Object memory object = Object(
            newId,
            0,
            0,
            _rank,
            _data
        );
        objects[object.id] = object;
        emit ObjectCreated(
            object.id,
            object.rank,
            object.data
        );
        return object.id;
    }

    function _link(uint256 _prevId, uint256 _nextId)
    internal
    {
        if (_prevId != 0 && _nextId != 0) {
            objects[_prevId].next = _nextId;
            objects[_nextId].prev = _prevId;
            emit ObjectsLinked(_prevId, _nextId);
        }
    }
}// MIT
pragma solidity ^0.8.0;


library IterableMap {

    using EnumerableSet for EnumerableSet.AddressSet;

    struct Map {
        EnumerableSet.AddressSet _keys;

        mapping (address => uint256) _values;
    }

    function _set(Map storage map, address key, uint256 value) private returns (bool) {
        map._values[key] = value;
        return map._keys.add(key);
    }

    function _plus(Map storage map, address key, uint256 value) private {
        map._values[key] += value;
        map._keys.add(key);
    }

    function _minus(Map storage map, address key, uint256 value) private {
        map._values[key] -= value;
        map._keys.add(key);
    }

    function _remove(Map storage map, address key) private returns (bool) {
        delete map._values[key];
        return map._keys.remove(key);
    }

    function _contains(Map storage map, address key) private view returns (bool) {
        return map._keys.contains(key);
    }

    function _length(Map storage map) private view returns (uint256) {
        return map._keys.length();
    }

    function _at(Map storage map, uint256 index) private view returns (address, uint256) {
        address key = map._keys.at(index);
        return (key, map._values[key]);
    }

    function _get(Map storage map, address key) private view returns (uint256) {
        uint256 value = map._values[key];
        return value;
    }
    
    struct AddressToUintMap {
        Map _inner;
    }

    function set(AddressToUintMap storage map, address key, uint256 value) internal returns (bool) {
        return _set(map._inner, key, value);
    }

    function plus(AddressToUintMap storage map, address key, uint256 value) internal {
        return _plus(map._inner, key, value);
    }

    function minus(AddressToUintMap storage map, address key, uint256 value) internal {
        return _minus(map._inner, key, value);
    }

    function remove(AddressToUintMap storage map, address key) internal returns (bool) {
        return _remove(map._inner, key);
    }

    function contains(AddressToUintMap storage map, address key) internal view returns (bool) {
        return _contains(map._inner, key);
    }

    function length(AddressToUintMap storage map) internal view returns (uint256) {
        return _length(map._inner);
    }

    function at(AddressToUintMap storage map, uint256 index) internal view returns (address, uint256) {
        return _at(map._inner, index);
    }

    function get(AddressToUintMap storage map, address key) internal view returns (uint256) {
        return _get(map._inner, key);
    }
}// MIT
pragma solidity ^0.8.0;




contract Vault is ERC20 {
    using SafeERC20 for ERC20;
    using Address for address;
    using SafeMath for uint256;
    using EnumerableSet for EnumerableSet.AddressSet;
    using IterableMap for IterableMap.AddressToUintMap;

    struct StrategyState {
        uint256 totalAssets;//当前总资产
        uint256 totalDebt;//投入未返还成本
    }

    struct ProtocolState {
        uint256 lastReportTime;//计算时间
        uint256 totalAssets;//当前总资产
    }

    struct StrategyApy {
        address strategyAddress;//策略地址
        uint256 apy;//策略APY
    }

    uint256 constant MAX_BPS = 10000;

    IterableMap.AddressToUintMap private userWithdrawMap;

    IterableMap.AddressToUintMap private userDepositMap;

    EnumerableSet.AddressSet private strategySet;

    mapping(address => StrategyState) public strategyStates;
    mapping(uint256 => ProtocolState) public protocolStates;

    mapping(address => uint256) public userDebts;

    mapping (address => bool) public greyList;

    ERC20 public token;
    uint8 public myDecimals;

    uint256 public underlyingUnit;

    uint256 public precisionFactor;
    address public rewards;
    address public governance;
    address public management;
    address public keeper;
    uint256 public profitManagementFee;
    uint256 public maxPercentPerStrategy;
    uint256 public maxPercentPerProtocol;
    uint256 public maxPercentInvestVault;

    uint256 public maxExchangeRateDeltaThreshold = 200;

    uint256 public minWorkDelay;
    uint256 public lastWorkTime;

    uint256 public pricePerShare;

    uint256 public lastPricePerShare;

    uint256 public apy = 0;

    bool public emergencyShutdown;

    uint256 public todayDepositAmounts;
    uint256 public todayWithdrawShares;

    uint256 public strategyTotalAssetsValue;

    modifier onlyGovernance(){
        require(msg.sender == governance || msg.sender == management, "The caller must be management or governance");
        _;
    }

    modifier onlyKeeper() {
        require(msg.sender == keeper || msg.sender == management || msg.sender == governance, 'only keeper');
        _;
    }

    modifier defense() {
        require((msg.sender == tx.origin) || !greyList[msg.sender], "This smart contract has been grey listed");
        _;
    }

    constructor(address _token, address _management, address _keeper, address _rewards) ERC20(
        string(abi.encodePacked("PIGGY_", ERC20(_token).name())),
        string(abi.encodePacked("p", ERC20(_token).symbol()))
    ) {
        governance = msg.sender;
        management = _management;
        keeper = _keeper;

        token = ERC20(_token);

        myDecimals = token.decimals();
        require(myDecimals < 256);

        if (myDecimals < 18) {
            precisionFactor = 10 ** (18 - myDecimals);
        } else {
            precisionFactor = 1;
        }
        underlyingUnit = 10 ** myDecimals;
        require(_rewards != address(0), 'rewards: ZERO_ADDRESS');
        rewards = _rewards;

        pricePerShare=underlyingUnit;

        profitManagementFee = 2500;
        maxPercentPerStrategy = 2000;
        maxPercentPerProtocol = 3000;
        maxPercentInvestVault = 2000;

        minWorkDelay = 0;
    }

    function decimals() public view virtual override returns (uint8) {
        return myDecimals;
    }

    function setGovernance(address _governance) onlyGovernance external {
        governance = _governance;
    }

    function setManagement(address _management) onlyGovernance external {
        management = _management;
    }

    function setRewards(address _rewards) onlyGovernance external {
        rewards = _rewards;
    }

    function setProfitManagementFee(uint256 _profitManagementFee) onlyGovernance external {
        require(_profitManagementFee <= MAX_BPS);
        profitManagementFee = _profitManagementFee;
    }

    function setMaxPercentPerStrategy(uint256 _maxPercentPerStrategy) onlyGovernance external {
        require(_maxPercentPerStrategy <= MAX_BPS);
        maxPercentPerStrategy = _maxPercentPerStrategy;
    }

    function setMaxPercentPerProtocole(uint256 _maxPercentPerProtocol) onlyGovernance external {
        require(_maxPercentPerProtocol <= MAX_BPS);
        maxPercentPerProtocol = _maxPercentPerProtocol;
    }

    function setMaxPercentInvestVault(uint256 _maxPercentInvestVault) onlyGovernance external {
        require(_maxPercentInvestVault <= MAX_BPS);
        maxPercentInvestVault = _maxPercentInvestVault;
    }

    function setMinWorkDelay(uint256 _delay) external onlyGovernance {
        minWorkDelay = _delay;
    }

    function setMaxExchangeRateDeltaThreshold(uint256 _threshold) public onlyGovernance {
        require(_threshold <= MAX_BPS);
        maxExchangeRateDeltaThreshold = _threshold;
    }

    function setEmergencyShutdown(bool active) onlyGovernance external {
        emergencyShutdown = active;
    }

    function setKeeper(address keeperAddress) onlyGovernance external {
        keeper = keeperAddress;
    }

    function addToGreyList(address _target) public onlyGovernance {
        greyList[_target] = true;
    }

    function removeFromGreyList(address _target) public onlyGovernance {
        greyList[_target] = false;
    }

    function totalAssets() public view returns (uint256) {
        return token.balanceOf(address(this)) + strategyTotalAssetsValue;
    }


    function strategies() external view returns (address[] memory) {
        address[] memory strategyArray = new address[](strategySet.length());
        for (uint256 i = 0; i < strategySet.length(); i++)
        {
            strategyArray[i] = strategySet.at(i);
        }
        return strategyArray;
    }

    function strategyState(address strategyAddress) external view returns (StrategyState memory) {
        return strategyStates[strategyAddress];
    }

    function setApys(StrategyApy[] memory strategyApys) external onlyKeeper {
        for (uint i = 0; i < strategyApys.length; i++) {
            StrategyApy memory strategyApy = strategyApys[i];
            if (strategySet.contains(strategyApy.strategyAddress) && strategyStates[strategyApy.strategyAddress].totalAssets <= 0) {
                IStrategy(strategyApy.strategyAddress).updateApy(strategyApy.apy);
            }
        }
    }

    function _issueSharesForAmount(address to, uint256 amount) internal returns (uint256) {
        uint256 shares = 0;
        if (totalSupply() == 0) {
            shares = amount;
        } else {
            require(pricePerShare != 0);
            shares = amount.mul(underlyingUnit).div(pricePerShare);
        }
        _mint(to, shares);
        return shares;
    }

    function _beforeTokenTransfer(address from, address to, uint256 amount) internal virtual override
    {


        super._beforeTokenTransfer(from, to, amount);
        if(from != address(0) && to!= address(0)){
            uint256 transferDebt = userDebts[from].mul(balanceOf(from)).div(amount);

            if(transferDebt>userDebts[from]){
                transferDebt = userDebts[from];
            }
            userDebts[from] -= transferDebt;
            userDebts[to] += transferDebt;


        }
    }

    function deposit(uint256 _amount) external defense {
        require(_amount > 0, "amount should more than 0");
        require(emergencyShutdown == false, "vault has been emergency shutdown");
        userDepositMap.plus(msg.sender, _amount);
        todayDepositAmounts += _amount;
        token.safeTransferFrom(msg.sender, address(this), _amount);

    }

    function _shareValue(uint256 shares) internal view returns (uint256) {
        if (totalSupply() == 0) {
            return shares;
        }
        return shares.mul(pricePerShare).div(underlyingUnit);
    }

    function withdraw(uint256 shares) external {
        require(shares > 0, "amount should more than 0");
        require(emergencyShutdown == false, "vault has been emergency shutdown");
        require(shares <= balanceOf(msg.sender), "can not withdraw more than user total");
        userWithdrawMap.plus(msg.sender, shares);
        todayWithdrawShares += shares;
        require(userWithdrawMap.get(msg.sender) <= balanceOf(msg.sender));
    }

    function inQueueDeposit(address userAddress) public view returns (uint256) {
        return userDepositMap.get(userAddress);
    }

    function userDebt(address userAddress) public view returns (uint256) {
        return userDebts[userAddress];
    }

    function inQueueWithdraw(address userAddress) public view returns (uint256) {
        return userWithdrawMap.get(userAddress);
    }


    function addStrategy(address strategy) onlyGovernance external {
        require(emergencyShutdown == false, "vault has been emergency shutdown");
        require(strategy != address(0), "strategy address can't be 0");
        require(strategySet.contains(strategy) == false, "strategy already exists");
        require(IStrategy(strategy).vault() == address(this), "strategy's vault error");
        require(IStrategy(strategy).want() == address(token), "strategy's token doesn't match");

        strategySet.add(strategy);
        strategyStates[strategy] = StrategyState({
        totalAssets : 0,
        totalDebt : 0
        });
    }

    function removeStrategy(address strategy) onlyGovernance external {
        require(strategySet.contains(strategy) == true, "strategy not exists");

        strategySet.remove(strategy);

        uint256 strategyTotalAssets = strategyStates[strategy].totalAssets;
        strategyTotalAssetsValue -= strategyTotalAssets;
        protocolStates[IStrategy(strategy).protocol()].totalAssets -= strategyTotalAssets;
        strategyStates[strategy].totalAssets = 0;

        (uint256 value, uint256 partialClaimValue, uint256 claimValue) = IStrategy(strategy).withdrawToVault(1, 1);
        uint256 strategyActualTotal = value + claimValue;
        if (strategyStates[strategy].totalDebt <= strategyActualTotal) {
            strategyStates[strategy].totalDebt = 0;
        } else {
            strategyStates[strategy].totalDebt -= strategyActualTotal;
        }
    }

    function migrateStrategy(address oldVersion, address newVersion) onlyGovernance external {
        require(newVersion != address(0), "strategy address can't be 0");
        require(strategySet.contains(oldVersion) == true, "strategy will be migrate doesn't exists");
        require(strategySet.contains(newVersion) == false, "new strategy already exists");

        StrategyState memory strategy = strategyStates[oldVersion];
        strategyStates[oldVersion].totalAssets = 0;
        strategyStates[oldVersion].totalDebt = 0;

        protocolStates[IStrategy(oldVersion).protocol()].totalAssets -= strategy.totalAssets;

        strategyStates[newVersion] = StrategyState({
        totalAssets : strategy.totalAssets,
        totalDebt : strategy.totalDebt
        });

        protocolStates[IStrategy(newVersion).protocol()].totalAssets += strategy.totalAssets;

        IStrategy(oldVersion).migrate(newVersion);

        strategySet.add(newVersion);
        strategySet.remove(oldVersion);

    }

    function _calDebt(address strategy,uint256 vaultAssetsLimit,uint256 protocolDebtLimit) internal view returns (uint256 debt) {
        uint256 strategyTotalAssets = strategyStates[strategy].totalAssets;



        uint256 invest_vault_assets_limit = IStrategy(strategy).getInvestVaultAssets().mul(maxPercentInvestVault).div(MAX_BPS);



        uint256 protocol_debt = protocolStates[IStrategy(strategy).protocol()].totalAssets;

        uint256 strategy_protocol_limit = protocolDebtLimit;
        if (protocol_debt > protocolDebtLimit) {
            uint256 shouldProtocolReturn = protocol_debt - protocolDebtLimit;

            uint256 other_strategy_debt = protocol_debt - strategyTotalAssets;

            if (shouldProtocolReturn > other_strategy_debt) {
                strategy_protocol_limit = strategyTotalAssets - (shouldProtocolReturn - other_strategy_debt);

            }
        }
        uint256 strategy_limit = Math.min(strategy_protocol_limit, Math.min(vaultAssetsLimit, invest_vault_assets_limit));

        if (strategy_limit > strategyTotalAssets) {
            return 0;
        } else {
            return (strategyTotalAssets - strategy_limit);
        }
    }

    function _calCredit(address strategy,uint256 vaultAssetsLimit,uint256 protocolDebtLimit) internal view returns (uint256 credit) {


        uint256 strategyTotalAssets = strategyStates[strategy].totalAssets;



        if (strategyTotalAssets >= vaultAssetsLimit) {
            return 0;
        }

        uint256 invest_vault_assets_limit = IStrategy(strategy).getInvestVaultAssets().mul(maxPercentInvestVault).div(MAX_BPS);


        if (strategyTotalAssets >= invest_vault_assets_limit) {
            return 0;
        }


        uint256 protocol_debt = protocolStates[IStrategy(strategy).protocol()].totalAssets;

        if (protocol_debt >= protocolDebtLimit) {
            return 0;
        }
        uint256 strategy_limit = Math.min((protocolDebtLimit - protocol_debt), Math.min((vaultAssetsLimit - strategyTotalAssets), (invest_vault_assets_limit - strategyTotalAssets)));

        return strategy_limit;
    }

    function doHardWork() onlyKeeper external {
        require(emergencyShutdown == false, "vault has been emergency shutdown");
        uint256 now = block.timestamp;
        require(now.sub(lastWorkTime) >= minWorkDelay, "Should not trigger if not waited long enough since previous doHardWork");

        uint256 strategyWithdrawForUserValue = 0;
        uint256 newStrategyTotalAssetsValue = 0;
        RankedList sortedStrategies = new RankedList();
        uint256 reportTime = block.timestamp;


        uint256 userWithdrawBalanceTotal = totalSupply() == 0 ? 0 : (token.balanceOf(address(this)) - todayDepositAmounts).mul(todayWithdrawShares).div(totalSupply());

        for (uint256 i = 0; i < strategySet.length(); i++)
        {
            address strategy = strategySet.at(i);
            IStrategy strategyInstant = IStrategy(strategy);

            uint256 strategyWithdrawValue;
            uint256 value;
            uint256 partialClaimValue;
            uint256 claimValue;
            if (todayWithdrawShares > 0) {
                (value, partialClaimValue, claimValue) = strategyInstant.withdrawToVault(todayWithdrawShares, totalSupply());

            } else {
                (value, partialClaimValue, claimValue) = strategyInstant.withdrawToVault(1, 100);

            }

            strategyWithdrawValue = value + claimValue;

            strategyWithdrawForUserValue += (value + partialClaimValue);

            uint strategyAssets = strategyInstant.estimatedTotalAssets();

            strategyStates[strategy].totalAssets = strategyAssets;

            if (strategyWithdrawValue > strategyStates[strategy].totalDebt) {
                strategyStates[strategy].totalDebt = 0;
            } else {
                strategyStates[strategy].totalDebt -= strategyWithdrawValue;
            }

            uint256 protocol = strategyInstant.protocol();
            if (protocolStates[protocol].lastReportTime == reportTime) {
                protocolStates[protocol].totalAssets += strategyAssets;
            } else {
                protocolStates[protocol].lastReportTime = reportTime;
                protocolStates[protocol].totalAssets = strategyAssets;
            }


            newStrategyTotalAssetsValue += strategyAssets;

            sortedStrategies.insert(uint256(strategyInstant.apy()), strategy);
        }
        strategyTotalAssetsValue = newStrategyTotalAssetsValue;
        lastPricePerShare = pricePerShare;
        pricePerShare = totalSupply() == 0 ? underlyingUnit : (totalAssets() - todayDepositAmounts).mul(underlyingUnit).div(totalSupply());


        if(pricePerShare>lastPricePerShare){
            apy = (pricePerShare-lastPricePerShare).mul(31536000).mul(1e4).div(now-lastWorkTime).div(lastPricePerShare);
        }else{
            apy=0;
        }


        uint256 userWithdrawTotal = strategyWithdrawForUserValue + userWithdrawBalanceTotal;

        uint256 totalProfitFee = 0;
        for (uint256 i = 0; i < userWithdrawMap.length();) {
            (address userAddress, uint256 userShares) = userWithdrawMap.at(i);

            uint256 userCost= userDebts[userAddress].mul(userShares).div(balanceOf(userAddress));

            uint256 toUserAll = userWithdrawTotal.mul(userShares).div(todayWithdrawShares);

            if (toUserAll > userCost) {
                uint256 profitFee = ((toUserAll - userCost).mul(profitManagementFee).div(MAX_BPS));

                totalProfitFee += profitFee;
                toUserAll -= profitFee;
                userDebts[userAddress] -= userCost;
            } else {

                userDebts[userAddress] -= toUserAll;
            }
            _burn(userAddress, userShares);
            if(balanceOf(userAddress)==0){
                userDebts[userAddress]=0;
            }

            token.safeTransfer(userAddress, toUserAll);
            userWithdrawMap.remove(userAddress);
        }
        if (totalProfitFee > 0) {

            token.safeTransfer(rewards, totalProfitFee);
        }
        todayWithdrawShares = 0;


        for (uint256 i = 0; i < userDepositMap.length();) {
            (address userAddress, uint256 amount) = userDepositMap.at(i);
            userDebts[userAddress] += amount;
            uint shares = _issueSharesForAmount(userAddress, amount);

            userDepositMap.remove(userAddress);
        }
        todayDepositAmounts = 0;


        uint256 vaultTotalAssets = totalAssets();

        uint256 vaultAssetsLimit = vaultTotalAssets.mul(maxPercentPerStrategy).div(MAX_BPS);
        uint256 protocolDebtLimit = vaultTotalAssets.mul(maxPercentPerProtocol).div(MAX_BPS);
        uint256 strategyPosition = 0;
        uint256 nextId = sortedStrategies.head();
        while (nextId != 0) {
            (uint256 id, uint256 next, uint256 prev, uint256 rank, address strategy) = sortedStrategies.get(nextId);

            uint256 debt = _calDebt(strategy,vaultAssetsLimit,protocolDebtLimit);

            if (debt > 0) {
                uint256 debtReturn = IStrategy(strategy).cutOffPosition(debt);
                strategyStates[strategy].totalAssets -= debt;
                if (debtReturn > strategyStates[strategy].totalDebt) {
                    strategyStates[strategy].totalDebt = 0;
                } else {
                    strategyStates[strategy].totalDebt -= debtReturn;
                }

                protocolStates[IStrategy(strategy).protocol()].totalAssets -= debt;
                strategyTotalAssetsValue -= debt;

            }
            nextId = next;
            strategyPosition++;
        }


        strategyPosition = 0;
        nextId = sortedStrategies.head();
        while (nextId != 0) {
            uint256 vault_balance = token.balanceOf(address(this));

            if (vault_balance <= 0) {

                break;
            }

            (uint256 id, uint256 next, uint256 prev, uint256 rank, address strategy) = sortedStrategies.get(nextId);

            uint256 calCredit = _calCredit(strategy,vaultAssetsLimit,protocolDebtLimit);
            if (calCredit > 0) {
                uint256 credit = Math.min(calCredit, token.balanceOf(address(this)));

                if (credit > 0) {
                    strategyStates[strategy].totalAssets += credit;
                    strategyStates[strategy].totalDebt += credit;
                    protocolStates[IStrategy(strategy).protocol()].totalAssets += credit;
                    token.safeTransfer(strategy, credit);
                    strategyTotalAssetsValue += credit;



                    IStrategy(strategy).invest();
                }
            }

            nextId = next;
            strategyPosition++;
        }

        lastWorkTime = now;
    }

    function sweep(address _token) onlyGovernance external {
        require(_token != address(token));
        uint256 value = token.balanceOf(address(this));
        token.safeTransferFrom(address(this), msg.sender, value);
    }

}