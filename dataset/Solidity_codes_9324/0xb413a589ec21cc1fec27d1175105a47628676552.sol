

pragma solidity ^0.6.0;

contract Context {

    constructor () internal { }

    function _msgSender() internal view virtual returns (address payable) {

        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {

        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}



pragma solidity ^0.6.0;

contract Ownable is Context {

    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor () internal {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    function owner() public view returns (address) {

        return _owner;
    }

    modifier onlyOwner() {

        require(_owner == _msgSender(), "Ownable: caller is not the owner");
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
}



pragma solidity ^0.6.0;

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


    struct AddressSet {
        Set _inner;
    }

    function add(AddressSet storage set, address value) internal returns (bool) {

        return _add(set._inner, bytes32(uint256(value)));
    }

    function remove(AddressSet storage set, address value) internal returns (bool) {

        return _remove(set._inner, bytes32(uint256(value)));
    }

    function contains(AddressSet storage set, address value) internal view returns (bool) {

        return _contains(set._inner, bytes32(uint256(value)));
    }

    function length(AddressSet storage set) internal view returns (uint256) {

        return _length(set._inner);
    }

    function at(AddressSet storage set, uint256 index) internal view returns (address) {

        return address(uint256(_at(set._inner, index)));
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
}



pragma solidity ^0.6.2;

library Address {

    function isContract(address account) internal view returns (bool) {

        bytes32 codehash;
        bytes32 accountHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;
        assembly { codehash := extcodehash(account) }
        return (codehash != accountHash && codehash != 0x0);
    }

    function sendValue(address payable recipient, uint256 amount) internal {

        require(address(this).balance >= amount, "Address: insufficient balance");

        (bool success, ) = recipient.call{ value: amount }("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }
}



pragma solidity ^0.6.0;



abstract contract AccessControl is Context {
    using EnumerableSet for EnumerableSet.AddressSet;
    using Address for address;

    struct RoleData {
        EnumerableSet.AddressSet members;
        bytes32 adminRole;
    }

    mapping (bytes32 => RoleData) private _roles;

    bytes32 public constant DEFAULT_ADMIN_ROLE = 0x00;

    event RoleGranted(bytes32 indexed role, address indexed account, address indexed sender);

    event RoleRevoked(bytes32 indexed role, address indexed account, address indexed sender);

    function hasRole(bytes32 role, address account) public view returns (bool) {
        return _roles[role].members.contains(account);
    }

    function getRoleMemberCount(bytes32 role) public view returns (uint256) {
        return _roles[role].members.length();
    }

    function getRoleMember(bytes32 role, uint256 index) public view returns (address) {
        return _roles[role].members.at(index);
    }

    function getRoleAdmin(bytes32 role) public view returns (bytes32) {
        return _roles[role].adminRole;
    }

    function grantRole(bytes32 role, address account) public virtual {
        require(hasRole(_roles[role].adminRole, _msgSender()), "AccessControl: sender must be an admin to grant");

        _grantRole(role, account);
    }

    function revokeRole(bytes32 role, address account) public virtual {
        require(hasRole(_roles[role].adminRole, _msgSender()), "AccessControl: sender must be an admin to revoke");

        _revokeRole(role, account);
    }

    function renounceRole(bytes32 role, address account) public virtual {
        require(account == _msgSender(), "AccessControl: can only renounce roles for self");

        _revokeRole(role, account);
    }

    function _setupRole(bytes32 role, address account) internal virtual {
        _grantRole(role, account);
    }

    function _setRoleAdmin(bytes32 role, bytes32 adminRole) internal virtual {
        _roles[role].adminRole = adminRole;
    }

    function _grantRole(bytes32 role, address account) private {
        if (_roles[role].members.add(account)) {
            emit RoleGranted(role, account, _msgSender());
        }
    }

    function _revokeRole(bytes32 role, address account) private {
        if (_roles[role].members.remove(account)) {
            emit RoleRevoked(role, account, _msgSender());
        }
    }
}



pragma solidity ^0.6.0;

interface IERC777 {

    function name() external view returns (string memory);


    function symbol() external view returns (string memory);


    function granularity() external view returns (uint256);


    function totalSupply() external view returns (uint256);


    function balanceOf(address owner) external view returns (uint256);


    function send(address recipient, uint256 amount, bytes calldata data) external;


    function burn(uint256 amount, bytes calldata data) external;


    function isOperatorFor(address operator, address tokenHolder) external view returns (bool);


    function authorizeOperator(address operator) external;


    function revokeOperator(address operator) external;


    function defaultOperators() external view returns (address[] memory);


    function operatorSend(
        address sender,
        address recipient,
        uint256 amount,
        bytes calldata data,
        bytes calldata operatorData
    ) external;


    function operatorBurn(
        address account,
        uint256 amount,
        bytes calldata data,
        bytes calldata operatorData
    ) external;


    event Sent(
        address indexed operator,
        address indexed from,
        address indexed to,
        uint256 amount,
        bytes data,
        bytes operatorData
    );

    event Minted(address indexed operator, address indexed to, uint256 amount, bytes data, bytes operatorData);

    event Burned(address indexed operator, address indexed from, uint256 amount, bytes data, bytes operatorData);

    event AuthorizedOperator(address indexed operator, address indexed tokenHolder);

    event RevokedOperator(address indexed operator, address indexed tokenHolder);
}



pragma solidity ^0.6.0;

interface IERC777Recipient {

    function tokensReceived(
        address operator,
        address from,
        address to,
        uint256 amount,
        bytes calldata userData,
        bytes calldata operatorData
    ) external;

}



pragma solidity ^0.6.0;

interface IERC777Sender {

    function tokensToSend(
        address operator,
        address from,
        address to,
        uint256 amount,
        bytes calldata userData,
        bytes calldata operatorData
    ) external;

}



pragma solidity ^0.6.0;

interface IERC20 {

    function totalSupply() external view returns (uint256);


    function balanceOf(address account) external view returns (uint256);


    function transfer(address recipient, uint256 amount) external returns (bool);


    function allowance(address owner, address spender) external view returns (uint256);


    function approve(address spender, uint256 amount) external returns (bool);


    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);


    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}



pragma solidity ^0.6.0;

library SafeMath {

    function add(uint256 a, uint256 b) internal pure returns (uint256) {

        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {

        return sub(a, b, "SafeMath: subtraction overflow");
    }

    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        require(b <= a, errorMessage);
        uint256 c = a - b;

        return c;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {

        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {

        return div(a, b, "SafeMath: division by zero");
    }

    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        require(b > 0, errorMessage);
        uint256 c = a / b;

        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {

        return mod(a, b, "SafeMath: modulo by zero");
    }

    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        require(b != 0, errorMessage);
        return a % b;
    }
}



pragma solidity ^0.6.0;

interface IERC1820Registry {

    function setManager(address account, address newManager) external;


    function getManager(address account) external view returns (address);


    function setInterfaceImplementer(address account, bytes32 interfaceHash, address implementer) external;


    function getInterfaceImplementer(address account, bytes32 interfaceHash) external view returns (address);


    function interfaceHash(string calldata interfaceName) external pure returns (bytes32);


    function updateERC165Cache(address account, bytes4 interfaceId) external;


    function implementsERC165Interface(address account, bytes4 interfaceId) external view returns (bool);


    function implementsERC165InterfaceNoCache(address account, bytes4 interfaceId) external view returns (bool);


    event InterfaceImplementerSet(address indexed account, bytes32 indexed interfaceHash, address indexed implementer);

    event ManagerChanged(address indexed account, address indexed newManager);
}



pragma solidity >=0.6.0 <0.8.0;








contract ERC777 is Context, IERC777, IERC20 {

    using SafeMath for uint256;
    using Address for address;

    IERC1820Registry constant internal _ERC1820_REGISTRY = IERC1820Registry(0x1820a4B7618BdE71Dce8cdc73aAB6C95905faD24);

    mapping(address => uint256) private _balances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;


    bytes32 constant private _TOKENS_SENDER_INTERFACE_HASH =
        0x29ddb589b1fb5fc7cf394961c1adf5f8c6454761adf795e67fe149f658abe895;

    bytes32 constant private _TOKENS_RECIPIENT_INTERFACE_HASH =
        0xb281fc8c12954d22544db45de3159a39272895b169a852b314f9cc762e44c53b;

    address[] private _defaultOperatorsArray;

    mapping(address => bool) private _defaultOperators;

    mapping(address => mapping(address => bool)) private _operators;
    mapping(address => mapping(address => bool)) private _revokedDefaultOperators;

    mapping (address => mapping (address => uint256)) private _allowances;

    constructor(
        string memory name_,
        string memory symbol_,
        address[] memory defaultOperators_
    )
        public
    {
        _name = name_;
        _symbol = symbol_;

        _defaultOperatorsArray = defaultOperators_;
        for (uint256 i = 0; i < _defaultOperatorsArray.length; i++) {
            _defaultOperators[_defaultOperatorsArray[i]] = true;
        }

        _ERC1820_REGISTRY.setInterfaceImplementer(address(this), keccak256("ERC777Token"), address(this));
        _ERC1820_REGISTRY.setInterfaceImplementer(address(this), keccak256("ERC20Token"), address(this));
    }

    function name() public view override returns (string memory) {

        return _name;
    }

    function symbol() public view override returns (string memory) {

        return _symbol;
    }

    function decimals() public pure returns (uint8) {

        return 18;
    }

    function granularity() public view override returns (uint256) {

        return 1;
    }

    function totalSupply() public view override(IERC20, IERC777) returns (uint256) {

        return _totalSupply;
    }

    function balanceOf(address tokenHolder) public view override(IERC20, IERC777) returns (uint256) {

        return _balances[tokenHolder];
    }

    function send(address recipient, uint256 amount, bytes memory data) public virtual override  {

        _send(_msgSender(), recipient, amount, data, "", true);
    }

    function transfer(address recipient, uint256 amount) public virtual override returns (bool) {

        require(recipient != address(0), "ERC777: transfer to the zero address");

        address from = _msgSender();

        _callTokensToSend(from, from, recipient, amount, "", "");

        _move(from, from, recipient, amount, "", "");

        _callTokensReceived(from, from, recipient, amount, "", "", false);

        return true;
    }

    function burn(uint256 amount, bytes memory data) public virtual override  {

        _burn(_msgSender(), amount, data, "");
    }

    function isOperatorFor(address operator, address tokenHolder) public view override returns (bool) {

        return operator == tokenHolder ||
            (_defaultOperators[operator] && !_revokedDefaultOperators[tokenHolder][operator]) ||
            _operators[tokenHolder][operator];
    }

    function authorizeOperator(address operator) public virtual override  {

        require(_msgSender() != operator, "ERC777: authorizing self as operator");

        if (_defaultOperators[operator]) {
            delete _revokedDefaultOperators[_msgSender()][operator];
        } else {
            _operators[_msgSender()][operator] = true;
        }

        emit AuthorizedOperator(operator, _msgSender());
    }

    function revokeOperator(address operator) public virtual override  {

        require(operator != _msgSender(), "ERC777: revoking self as operator");

        if (_defaultOperators[operator]) {
            _revokedDefaultOperators[_msgSender()][operator] = true;
        } else {
            delete _operators[_msgSender()][operator];
        }

        emit RevokedOperator(operator, _msgSender());
    }

    function defaultOperators() public view override returns (address[] memory) {

        return _defaultOperatorsArray;
    }

    function operatorSend(
        address sender,
        address recipient,
        uint256 amount,
        bytes memory data,
        bytes memory operatorData
    )
        public
        virtual
        override
    {

        require(isOperatorFor(_msgSender(), sender), "ERC777: caller is not an operator for holder");
        _send(sender, recipient, amount, data, operatorData, true);
    }

    function operatorBurn(address account, uint256 amount, bytes memory data, bytes memory operatorData) public virtual override {

        require(isOperatorFor(_msgSender(), account), "ERC777: caller is not an operator for holder");
        _burn(account, amount, data, operatorData);
    }

    function allowance(address holder, address spender) public view override returns (uint256) {

        return _allowances[holder][spender];
    }

    function approve(address spender, uint256 value) public virtual override returns (bool) {

        address holder = _msgSender();
        _approve(holder, spender, value);
        return true;
    }

    function transferFrom(address holder, address recipient, uint256 amount) public virtual override returns (bool) {

        require(recipient != address(0), "ERC777: transfer to the zero address");
        require(holder != address(0), "ERC777: transfer from the zero address");

        address spender = _msgSender();

        _callTokensToSend(spender, holder, recipient, amount, "", "");

        _move(spender, holder, recipient, amount, "", "");
        _approve(holder, spender, _allowances[holder][spender].sub(amount, "ERC777: transfer amount exceeds allowance"));

        _callTokensReceived(spender, holder, recipient, amount, "", "", false);

        return true;
    }

    function _mint(
        address account,
        uint256 amount,
        bytes memory userData,
        bytes memory operatorData
    )
        internal
        virtual
    {

        require(account != address(0), "ERC777: mint to the zero address");

        address operator = _msgSender();

        _beforeTokenTransfer(operator, address(0), account, amount);

        _totalSupply = _totalSupply.add(amount);
        _balances[account] = _balances[account].add(amount);

        _callTokensReceived(operator, address(0), account, amount, userData, operatorData, true);

        emit Minted(operator, account, amount, userData, operatorData);
        emit Transfer(address(0), account, amount);
    }

    function _send(
        address from,
        address to,
        uint256 amount,
        bytes memory userData,
        bytes memory operatorData,
        bool requireReceptionAck
    )
        internal
        virtual
    {

        require(from != address(0), "ERC777: send from the zero address");
        require(to != address(0), "ERC777: send to the zero address");

        address operator = _msgSender();

        _callTokensToSend(operator, from, to, amount, userData, operatorData);

        _move(operator, from, to, amount, userData, operatorData);

        _callTokensReceived(operator, from, to, amount, userData, operatorData, requireReceptionAck);
    }

    function _burn(
        address from,
        uint256 amount,
        bytes memory data,
        bytes memory operatorData
    )
        internal
        virtual
    {

        require(from != address(0), "ERC777: burn from the zero address");

        address operator = _msgSender();

        _callTokensToSend(operator, from, address(0), amount, data, operatorData);

        _beforeTokenTransfer(operator, from, address(0), amount);

        _balances[from] = _balances[from].sub(amount, "ERC777: burn amount exceeds balance");
        _totalSupply = _totalSupply.sub(amount);

        emit Burned(operator, from, amount, data, operatorData);
        emit Transfer(from, address(0), amount);
    }

    function _move(
        address operator,
        address from,
        address to,
        uint256 amount,
        bytes memory userData,
        bytes memory operatorData
    )
        private
    {

        _beforeTokenTransfer(operator, from, to, amount);

        _balances[from] = _balances[from].sub(amount, "ERC777: transfer amount exceeds balance");
        _balances[to] = _balances[to].add(amount);

        emit Sent(operator, from, to, amount, userData, operatorData);
        emit Transfer(from, to, amount);
    }

    function _approve(address holder, address spender, uint256 value) internal {

        require(holder != address(0), "ERC777: approve from the zero address");
        require(spender != address(0), "ERC777: approve to the zero address");

        _allowances[holder][spender] = value;
        emit Approval(holder, spender, value);
    }

    function _callTokensToSend(
        address operator,
        address from,
        address to,
        uint256 amount,
        bytes memory userData,
        bytes memory operatorData
    )
        private
    {

        address implementer = _ERC1820_REGISTRY.getInterfaceImplementer(from, _TOKENS_SENDER_INTERFACE_HASH);
        if (implementer != address(0)) {
            IERC777Sender(implementer).tokensToSend(operator, from, to, amount, userData, operatorData);
        }
    }

    function _callTokensReceived(
        address operator,
        address from,
        address to,
        uint256 amount,
        bytes memory userData,
        bytes memory operatorData,
        bool requireReceptionAck
    )
        private
    {

        address implementer = _ERC1820_REGISTRY.getInterfaceImplementer(to, _TOKENS_RECIPIENT_INTERFACE_HASH);
        if (implementer != address(0)) {
            IERC777Recipient(implementer).tokensReceived(operator, from, to, amount, userData, operatorData);
        } else if (requireReceptionAck) {
            require(!to.isContract(), "ERC777: token recipient contract has no implementer for ERC777TokensRecipient");
        }
    }

    function _beforeTokenTransfer(address operator, address from, address to, uint256 amount) internal virtual { }

}



pragma solidity ^0.6.0;


abstract contract ERC777Snapshot is ERC777 {

    using SafeMath for uint256;

    struct Snapshot {
        uint128 fromBlock;
        uint128 value;
    }

    mapping (address => Snapshot[]) public accountSnapshots;

    Snapshot[] public totalSupplySnapshots;

    function balanceOfAt(address _owner, uint128 _blockNumber) external view returns (uint256) {
        return _valueAt(accountSnapshots[_owner], _blockNumber);
    }

    function totalSupplyAt(uint128 _blockNumber) external view returns(uint256) {
        return _valueAt(totalSupplySnapshots, _blockNumber);
    }

    function _beforeTokenTransfer(address operator, address from, address to, uint256 amount) internal virtual override {
        if (from == address(0)) {
            updateValueAtNow(accountSnapshots[to], balanceOf(to).add(amount));
            updateValueAtNow(totalSupplySnapshots, totalSupply().add(amount));
        } else if (to == address(0)) {
            updateValueAtNow(accountSnapshots[from], balanceOf(from).sub(amount));
            updateValueAtNow(totalSupplySnapshots, totalSupply().sub(amount));
        } else if (from != to) {
            updateValueAtNow(accountSnapshots[from], balanceOf(from).sub(amount));
            updateValueAtNow(accountSnapshots[to], balanceOf(to).add(amount));
        }
    }

    function _valueAt(
        Snapshot[] storage snapshots,
        uint128 _block
    ) view internal returns (uint256) {
        uint256 lenSnapshots = snapshots.length;
        if (lenSnapshots == 0) return 0;

        if (_block >= snapshots[lenSnapshots - 1].fromBlock) {
            return snapshots[lenSnapshots - 1].value;
        }
        if (_block < snapshots[0].fromBlock) {
            return 0;
        }

        uint256 min = 0;
        uint256 max = lenSnapshots - 1;
        while (max > min) {
            uint256 mid = (max + min + 1) / 2;

            uint256 midSnapshotFrom = snapshots[mid].fromBlock;
            if (midSnapshotFrom == _block) {
                return snapshots[mid].value;
            } else if (midSnapshotFrom < _block) {
                min = mid;
            } else {
                max = mid - 1;
            }
        }

        return snapshots[min].value;
    }

    function updateValueAtNow(Snapshot[] storage snapshots, uint256 _value) internal {
        require(_value <= uint128(-1), "casting overflow");
        uint256 lenSnapshots = snapshots.length;

        if (
            (lenSnapshots == 0) ||
            (snapshots[lenSnapshots - 1].fromBlock < block.number)
        ) {
            snapshots.push(
                Snapshot(
                    uint128(block.number),
                    uint128(_value)
                )
            );
        } else {
            snapshots[lenSnapshots - 1].value = uint128(_value);
        }
    }
}



pragma solidity ^0.6.0;



contract HoprToken is AccessControl, ERC777Snapshot {
    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");

    constructor() public ERC777("HOPR Token", "HOPR", new address[](0)) {
        _setupRole(DEFAULT_ADMIN_ROLE, msg.sender);
    }

    function mint(
        address account,
        uint256 amount,
        bytes memory userData,
        bytes memory operatorData
    ) public {
        require(hasRole(MINTER_ROLE, msg.sender), "HoprToken: caller does not have minter role");
        _mint(account, amount, userData, operatorData);
    }
}



pragma solidity ^0.6.0;


contract HoprDistributor is Ownable {
    struct Schedule {
        uint128[] durations;
        uint128[] percents;
    }

    struct Allocation {
        uint128 amount;
        uint128 claimed;
        uint128 lastClaim;
        bool revoked; // account can no longer claim
    }

    uint128 public constant MULTIPLIER = 10 ** 6;

    uint128 public totalMinted = 0;
    uint128 public totalToBeMinted = 0;

    uint128 public startTime;
    HoprToken public token;
    uint128 public maxMintAmount;

    mapping(string => Schedule) internal schedules;

    mapping(address => mapping(string => Allocation)) public allocations;

    event ScheduleAdded(uint128[] durations, uint128[] percents, string name);
    event AllocationAdded(address indexed account, uint128 amount, string scheduleName);
    event Claimed(address indexed account, uint128 amount, string scheduleName);

    constructor(HoprToken _token, uint128 _startTime, uint128 _maxMintAmount) public {
        startTime = _startTime;
        token = _token;
        maxMintAmount = _maxMintAmount;
    }

    function getSchedule(string calldata name) external view returns (uint128[] memory, uint128[] memory) {
        return (
            schedules[name].durations,
            schedules[name].percents
        );
    }

    function updateStartTime(uint128 _startTime) external onlyOwner {
        require(startTime > _currentBlockTimestamp(), "Previous start time must not be reached");
        startTime = _startTime;
    }

    function revokeAccount(
        address account,
        string calldata scheduleName
    ) external onlyOwner {
        Allocation storage allocation = allocations[account][scheduleName];
        require(allocation.amount != 0, "Allocation must exist");
        require(!allocation.revoked, "Allocation must not be already revoked");

        allocation.revoked = true;
        totalToBeMinted = _subUint128(totalToBeMinted, _subUint128(allocation.amount, allocation.claimed));
    }

    function addSchedule(
        uint128[] calldata durations,
        uint128[] calldata percents,
        string calldata name
    ) external onlyOwner {
        require(schedules[name].durations.length == 0, "Schedule must not exist");
        require(durations.length == percents.length, "Durations and percents must have equal length");

        uint128 lastDuration = 0;
        uint128 totalPercent = 0;

        for (uint256 i = 0; i < durations.length; i++) {
            require(lastDuration < durations[i], "Durations must be added in ascending order");
            lastDuration = durations[i];

            require(percents[i] <= MULTIPLIER, "Percent provided must be smaller or equal to MULTIPLIER");
            totalPercent = _addUint128(totalPercent, percents[i]);
        }

        require(totalPercent == MULTIPLIER, "Percents must sum to MULTIPLIER amount");

        schedules[name] = Schedule(durations, percents);

        emit ScheduleAdded(durations, percents, name);
    }

    function addAllocations(
        address[] calldata accounts,
        uint128[] calldata amounts,
        string calldata scheduleName
    ) external onlyOwner {
        require(schedules[scheduleName].durations.length != 0, "Schedule must exist");
        require(accounts.length == amounts.length, "Accounts and amounts must have equal length");

        uint128 _totalToBeMinted = totalToBeMinted;

        for (uint256 i = 0; i < accounts.length; i++) {
            require(allocations[accounts[i]][scheduleName].amount == 0, "Allocation must not exist");
            allocations[accounts[i]][scheduleName].amount = amounts[i];
            _totalToBeMinted = _addUint128(_totalToBeMinted, amounts[i]);
            assert(_totalToBeMinted <= maxMintAmount);

            emit AllocationAdded(accounts[i], amounts[i], scheduleName);
        }

        totalToBeMinted = _totalToBeMinted;
    }

    function claim(string calldata scheduleName) external {
        return _claim(msg.sender, scheduleName);
    }

    function claimFor(address account, string calldata scheduleName) external {
        return _claim(account, scheduleName);
    }

    function getClaimable(address account, string calldata scheduleName) external view returns (uint128) {
        return _getClaimable(schedules[scheduleName], allocations[account][scheduleName]);
    }

    function _claim(address account, string memory scheduleName) internal {
        Allocation storage allocation = allocations[account][scheduleName];
        require(allocation.amount > 0, "There is nothing to claim");
        require(!allocation.revoked, "Account is revoked");

        Schedule storage schedule = schedules[scheduleName];

        uint128 claimable = _getClaimable(schedule, allocation);
        assert(claimable <= allocation.amount);

        uint128 newClaimed = _addUint128(allocation.claimed, claimable);
        assert(newClaimed <= allocation.amount);

        uint128 newTotalMinted = _addUint128(totalMinted, claimable);
        assert(newTotalMinted <= maxMintAmount);

        totalMinted = newTotalMinted;
        allocation.claimed = newClaimed;
        allocation.lastClaim = _currentBlockTimestamp();

        token.mint(account, claimable, "", "");

        emit Claimed(account, claimable, scheduleName);
    }

    function _getClaimable(
        Schedule storage schedule,
        Allocation storage allocation
    ) internal view returns (uint128) {
        if (_addUint128(startTime, schedule.durations[0]) > _currentBlockTimestamp()) {
            return 0;
        }

        if (_addUint128(startTime, schedule.durations[schedule.durations.length - 1]) < _currentBlockTimestamp()) {
            return _subUint128(allocation.amount, allocation.claimed);
        }

        uint128 claimable = 0;

        for (uint256 i = 0; i < schedule.durations.length; i++) {
            uint128 scheduleDeadline = _addUint128(startTime, schedule.durations[i]);

            if (scheduleDeadline > _currentBlockTimestamp()) break;
            if (allocation.lastClaim >= scheduleDeadline) continue;

            claimable = _addUint128(claimable, _divUint128(_mulUint128(allocation.amount, schedule.percents[i]), MULTIPLIER));
        }

        return claimable;
    }

    function _currentBlockTimestamp() internal view returns (uint128) {
        return uint128(block.timestamp);
    }

    function _addUint128(uint128 a, uint128 b) internal pure returns (uint128) {
        uint128 c = a + b;
        require(c >= a, "uint128 addition overflow");

        return c;
    }

    function _subUint128(uint128 a, uint128 b) internal pure returns (uint128) {
        require(b <= a, "uint128 subtraction overflow");
        uint128 c = a - b;

        return c;
    }

    function _mulUint128(uint128 a, uint128 b) internal pure returns (uint128) {
        if (a == 0) {
            return 0;
        }

        uint128 c = a * b;
        require(c / a == b, "uint128 multiplication overflow");

        return c;
    }

    function _divUint128(uint128 a, uint128 b) internal pure returns (uint128) {
        require(b > 0, "uint128 division by zero");
        uint128 c = a / b;

        return c;
    }
}