
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
}// MIT

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
}// MIT

pragma solidity ^0.6.2;

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

        return _functionCallWithValue(target, data, 0, errorMessage);
    }

    function functionCallWithValue(address target, bytes memory data, uint256 value) internal returns (bytes memory) {

        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    function functionCallWithValue(address target, bytes memory data, uint256 value, string memory errorMessage) internal returns (bytes memory) {

        require(address(this).balance >= value, "Address: insufficient balance for call");
        return _functionCallWithValue(target, data, value, errorMessage);
    }

    function _functionCallWithValue(address target, bytes memory data, uint256 weiValue, string memory errorMessage) private returns (bytes memory) {

        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{ value: weiValue }(data);
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

pragma solidity ^0.6.0;


library SafeERC20 {

    using SafeMath for uint256;
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

        uint256 newAllowance = token.allowance(address(this), spender).add(value);
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(IERC20 token, address spender, uint256 value) internal {

        uint256 newAllowance = token.allowance(address(this), spender).sub(value, "SafeERC20: decreased allowance below zero");
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function _callOptionalReturn(IERC20 token, bytes memory data) private {


        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) { // Return data is optional
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}// MIT

pragma solidity ^0.6.0;

abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}// MIT

pragma solidity ^0.6.0;


contract ERC20 is Context, IERC20 {

    using SafeMath for uint256;
    using Address for address;

    mapping (address => uint256) private _balances;

    mapping (address => mapping (address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;
    uint8 private _decimals;

    constructor (string memory name, string memory symbol) public {
        _name = name;
        _symbol = symbol;
        _decimals = 18;
    }

    function name() public view returns (string memory) {

        return _name;
    }

    function symbol() public view returns (string memory) {

        return _symbol;
    }

    function decimals() public view returns (uint8) {

        return _decimals;
    }

    function totalSupply() public view override returns (uint256) {

        return _totalSupply;
    }

    function balanceOf(address account) public view override returns (uint256) {

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
        _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount, "ERC20: transfer amount exceeds allowance"));
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {

        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].add(addedValue));
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {

        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].sub(subtractedValue, "ERC20: decreased allowance below zero"));
        return true;
    }

    function _transfer(address sender, address recipient, uint256 amount) internal virtual {

        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(sender, recipient, amount);

        _balances[sender] = _balances[sender].sub(amount, "ERC20: transfer amount exceeds balance");
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
    }

    function _mint(address account, uint256 amount) internal virtual {

        require(account != address(0), "ERC20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply = _totalSupply.add(amount);
        _balances[account] = _balances[account].add(amount);
        emit Transfer(address(0), account, amount);
    }

    function _burn(address account, uint256 amount) internal virtual {

        require(account != address(0), "ERC20: burn from the zero address");

        _beforeTokenTransfer(account, address(0), amount);

        _balances[account] = _balances[account].sub(amount, "ERC20: burn amount exceeds balance");
        _totalSupply = _totalSupply.sub(amount);
        emit Transfer(account, address(0), amount);
    }

    function _approve(address owner, address spender, uint256 amount) internal virtual {

        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _setupDecimals(uint8 decimals_) internal {

        _decimals = decimals_;
    }

    function _beforeTokenTransfer(address from, address to, uint256 amount) internal virtual { }

}// MIT

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
}// MIT

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

    event RoleAdminChanged(bytes32 indexed role, bytes32 indexed previousAdminRole, bytes32 indexed newAdminRole);

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
        emit RoleAdminChanged(role, _roles[role].adminRole, adminRole);
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
}// MIT

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
}// MIT

pragma solidity ^0.6.0;


contract Pausable is Context {
    event Paused(address account);

    event Unpaused(address account);

    bool private _paused;

    constructor () internal {
        _paused = false;
    }

    function paused() public view returns (bool) {
        return _paused;
    }

    modifier whenNotPaused() {
        require(!_paused, "Pausable: paused");
        _;
    }

    modifier whenPaused() {
        require(_paused, "Pausable: not paused");
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

pragma solidity ^0.6.0;


library SafeCast {

    function toUint128(uint256 value) internal pure returns (uint128) {
        require(value < 2**128, "SafeCast: value doesn\'t fit in 128 bits");
        return uint128(value);
    }

    function toUint64(uint256 value) internal pure returns (uint64) {
        require(value < 2**64, "SafeCast: value doesn\'t fit in 64 bits");
        return uint64(value);
    }

    function toUint32(uint256 value) internal pure returns (uint32) {
        require(value < 2**32, "SafeCast: value doesn\'t fit in 32 bits");
        return uint32(value);
    }

    function toUint16(uint256 value) internal pure returns (uint16) {
        require(value < 2**16, "SafeCast: value doesn\'t fit in 16 bits");
        return uint16(value);
    }

    function toUint8(uint256 value) internal pure returns (uint8) {
        require(value < 2**8, "SafeCast: value doesn\'t fit in 8 bits");
        return uint8(value);
    }

    function toUint256(int256 value) internal pure returns (uint256) {
        require(value >= 0, "SafeCast: value must be positive");
        return uint256(value);
    }

    function toInt128(int256 value) internal pure returns (int128) {
        require(value >= -2**127 && value < 2**127, "SafeCast: value doesn\'t fit in 128 bits");
        return int128(value);
    }

    function toInt64(int256 value) internal pure returns (int64) {
        require(value >= -2**63 && value < 2**63, "SafeCast: value doesn\'t fit in 64 bits");
        return int64(value);
    }

    function toInt32(int256 value) internal pure returns (int32) {
        require(value >= -2**31 && value < 2**31, "SafeCast: value doesn\'t fit in 32 bits");
        return int32(value);
    }

    function toInt16(int256 value) internal pure returns (int16) {
        require(value >= -2**15 && value < 2**15, "SafeCast: value doesn\'t fit in 16 bits");
        return int16(value);
    }

    function toInt8(int256 value) internal pure returns (int8) {
        require(value >= -2**7 && value < 2**7, "SafeCast: value doesn\'t fit in 8 bits");
        return int8(value);
    }

    function toInt256(uint256 value) internal pure returns (int256) {
        require(value < 2**255, "SafeCast: value doesn't fit in an int256");
        return int256(value);
    }
}// MIT

pragma solidity ^0.6.0;

contract ReentrancyGuard {

    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor () internal {
        _status = _NOT_ENTERED;
    }

    modifier nonReentrant() {
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        _status = _ENTERED;

        _;

        _status = _NOT_ENTERED;
    }
}// GPL-3.0
pragma solidity 0.6.12;




contract JoysToken is ERC20("JoysToken", "JOYS"), Ownable {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;


    mapping (address => address) internal _delegates;

    struct Checkpoint {
        uint32 fromBlock;
        uint256 votes;
    }

    mapping (address => mapping (uint32 => Checkpoint)) public checkpoints;

    mapping (address => uint32) public numCheckpoints;

    bytes32 public constant DOMAIN_TYPEHASH = keccak256("EIP712Domain(string name,uint256 chainId,address verifyingContract)");

    bytes32 public constant DELEGATION_TYPEHASH = keccak256("Delegation(address delegatee,uint256 nonce,uint256 expiry)");

    mapping (address => uint) public nonces;

    event DelegateChanged(address indexed delegator, address indexed fromDelegate, address indexed toDelegate);

    event DelegateVotesChanged(address indexed delegate, uint previousBalance, uint newBalance);

    constructor() public {
        uint256 totalSupply = 300000000 * 1e18;
        _mint(_msgSender(), totalSupply);
    }

    function burn(uint256 _amount) public onlyOwner {
        _burn(_msgSender(), _amount);
    }

    function _beforeTokenTransfer(address from, address to, uint256 amount) internal override {
        _moveDelegates(_delegates[from], _delegates[to], amount);
    }

    function delegates(address delegator)
        external
        view
        returns (address)
    {
        return _delegates[delegator];
    }

    function delegate(address delegatee) external {
        return _delegate(msg.sender, delegatee);
    }

    function delegateBySig(
        address delegatee,
        uint nonce,
        uint expiry,
        uint8 v,
        bytes32 r,
        bytes32 s
    )
        external
    {
        bytes32 domainSeparator = keccak256(
            abi.encode(
                DOMAIN_TYPEHASH,
                keccak256(bytes(name())),
                getChainId(),
                address(this)
            )
        );

        bytes32 structHash = keccak256(
            abi.encode(
                DELEGATION_TYPEHASH,
                delegatee,
                nonce,
                expiry
            )
        );

        bytes32 digest = keccak256(
            abi.encodePacked(
                "\x19\x01",
                domainSeparator,
                structHash
            )
        );

        address signatory = ecrecover(digest, v, r, s);
        require(signatory != address(0), "JOYS::delegateBySig: invalid signature");
        require(nonce == nonces[signatory]++, "JOYS::delegateBySig: invalid nonce");
        require(now <= expiry, "JOYS::delegateBySig: signature expired");
        return _delegate(signatory, delegatee);
    }

    function getCurrentVotes(address account)
        external
        view
        returns (uint256)
    {
        uint32 nCheckpoints = numCheckpoints[account];
        return nCheckpoints > 0 ? checkpoints[account][nCheckpoints - 1].votes : 0;
    }

    function getPriorVotes(address account, uint blockNumber)
        external
        view
        returns (uint256)
    {
        require(blockNumber < block.number, "JOYS::getPriorVotes: not yet determined");

        uint32 nCheckpoints = numCheckpoints[account];
        if (nCheckpoints == 0) {
            return 0;
        }

        if (checkpoints[account][nCheckpoints - 1].fromBlock <= blockNumber) {
            return checkpoints[account][nCheckpoints - 1].votes;
        }

        if (checkpoints[account][0].fromBlock > blockNumber) {
            return 0;
        }

        uint32 lower = 0;
        uint32 upper = nCheckpoints - 1;
        while (upper > lower) {
            uint32 center = upper - (upper - lower) / 2; // ceil, avoiding overflow
            Checkpoint memory cp = checkpoints[account][center];
            if (cp.fromBlock == blockNumber) {
                return cp.votes;
            } else if (cp.fromBlock < blockNumber) {
                lower = center;
            } else {
                upper = center - 1;
            }
        }
        return checkpoints[account][lower].votes;
    }

    function _delegate(address delegator, address delegatee)
        internal
    {
        address currentDelegate = _delegates[delegator];
        uint256 delegatorBalance = balanceOf(delegator); // balance of underlying JOYS (not scaled);
        _delegates[delegator] = delegatee;

        emit DelegateChanged(delegator, currentDelegate, delegatee);

        _moveDelegates(currentDelegate, delegatee, delegatorBalance);
    }

    function _moveDelegates(address srcRep, address dstRep, uint256 amount) internal {
        if (srcRep != dstRep && amount > 0) {
            if (srcRep != address(0)) {
                uint32 srcRepNum = numCheckpoints[srcRep];
                uint256 srcRepOld = srcRepNum > 0 ? checkpoints[srcRep][srcRepNum - 1].votes : 0;
                uint256 srcRepNew = srcRepOld.sub(amount);
                _writeCheckpoint(srcRep, srcRepNum, srcRepOld, srcRepNew);
            }

            if (dstRep != address(0)) {
                uint32 dstRepNum = numCheckpoints[dstRep];
                uint256 dstRepOld = dstRepNum > 0 ? checkpoints[dstRep][dstRepNum - 1].votes : 0;
                uint256 dstRepNew = dstRepOld.add(amount);
                _writeCheckpoint(dstRep, dstRepNum, dstRepOld, dstRepNew);
            }
        }
    }

    function _writeCheckpoint(
        address delegatee,
        uint32 nCheckpoints,
        uint256 oldVotes,
        uint256 newVotes
    )
        internal
    {
        uint32 blockNumber = safe32(block.number, "JOYS::_writeCheckpoint: block number exceeds 32 bits");

        if (nCheckpoints > 0 && checkpoints[delegatee][nCheckpoints - 1].fromBlock == blockNumber) {
            checkpoints[delegatee][nCheckpoints - 1].votes = newVotes;
        } else {
            checkpoints[delegatee][nCheckpoints] = Checkpoint(blockNumber, newVotes);
            numCheckpoints[delegatee] = nCheckpoints + 1;
        }

        emit DelegateVotesChanged(delegatee, oldVotes, newVotes);
    }

    function safe32(uint n, string memory errorMessage) internal pure returns (uint32) {
        require(n < 2**32, errorMessage);
        return uint32(n);
    }

    function getChainId() internal pure returns (uint) {
        uint256 chainId;
        assembly { chainId := chainid() }
        return chainId;
    }
}// MIT

pragma solidity ^0.6.0;


library Counters {
    using SafeMath for uint256;

    struct Counter {
        uint256 _value; // default: 0
    }

    function current(Counter storage counter) internal view returns (uint256) {
        return counter._value;
    }

    function increment(Counter storage counter) internal {
        counter._value += 1;
    }

    function decrement(Counter storage counter) internal {
        counter._value = counter._value.sub(1);
    }
}// MIT

pragma solidity ^0.6.0;

interface IERC165 {
    function supportsInterface(bytes4 interfaceId) external view returns (bool);
}// MIT

pragma solidity ^0.6.2;


interface IERC721 is IERC165 {
    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);

    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);

    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);

    function balanceOf(address owner) external view returns (uint256 balance);

    function ownerOf(uint256 tokenId) external view returns (address owner);

    function safeTransferFrom(address from, address to, uint256 tokenId) external;

    function transferFrom(address from, address to, uint256 tokenId) external;

    function approve(address to, uint256 tokenId) external;

    function getApproved(uint256 tokenId) external view returns (address operator);

    function setApprovalForAll(address operator, bool _approved) external;

    function isApprovedForAll(address owner, address operator) external view returns (bool);

    function safeTransferFrom(address from, address to, uint256 tokenId, bytes calldata data) external;
}// MIT

pragma solidity ^0.6.2;


interface IERC721Metadata is IERC721 {

    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function tokenURI(uint256 tokenId) external view returns (string memory);
}// MIT

pragma solidity ^0.6.2;


interface IERC721Enumerable is IERC721 {

    function totalSupply() external view returns (uint256);

    function tokenOfOwnerByIndex(address owner, uint256 index) external view returns (uint256 tokenId);

    function tokenByIndex(uint256 index) external view returns (uint256);
}// MIT

pragma solidity ^0.6.0;

interface IERC721Receiver {
    function onERC721Received(address operator, address from, uint256 tokenId, bytes calldata data)
    external returns (bytes4);
}// MIT

pragma solidity ^0.6.0;


contract ERC165 is IERC165 {
    bytes4 private constant _INTERFACE_ID_ERC165 = 0x01ffc9a7;

    mapping(bytes4 => bool) private _supportedInterfaces;

    constructor () internal {
        _registerInterface(_INTERFACE_ID_ERC165);
    }

    function supportsInterface(bytes4 interfaceId) public view override returns (bool) {
        return _supportedInterfaces[interfaceId];
    }

    function _registerInterface(bytes4 interfaceId) internal virtual {
        require(interfaceId != 0xffffffff, "ERC165: invalid interface id");
        _supportedInterfaces[interfaceId] = true;
    }
}// MIT

pragma solidity ^0.6.0;

library EnumerableMap {

    struct MapEntry {
        bytes32 _key;
        bytes32 _value;
    }

    struct Map {
        MapEntry[] _entries;

        mapping (bytes32 => uint256) _indexes;
    }

    function _set(Map storage map, bytes32 key, bytes32 value) private returns (bool) {
        uint256 keyIndex = map._indexes[key];

        if (keyIndex == 0) { // Equivalent to !contains(map, key)
            map._entries.push(MapEntry({ _key: key, _value: value }));
            map._indexes[key] = map._entries.length;
            return true;
        } else {
            map._entries[keyIndex - 1]._value = value;
            return false;
        }
    }

    function _remove(Map storage map, bytes32 key) private returns (bool) {
        uint256 keyIndex = map._indexes[key];

        if (keyIndex != 0) { // Equivalent to contains(map, key)

            uint256 toDeleteIndex = keyIndex - 1;
            uint256 lastIndex = map._entries.length - 1;


            MapEntry storage lastEntry = map._entries[lastIndex];

            map._entries[toDeleteIndex] = lastEntry;
            map._indexes[lastEntry._key] = toDeleteIndex + 1; // All indexes are 1-based

            map._entries.pop();

            delete map._indexes[key];

            return true;
        } else {
            return false;
        }
    }

    function _contains(Map storage map, bytes32 key) private view returns (bool) {
        return map._indexes[key] != 0;
    }

    function _length(Map storage map) private view returns (uint256) {
        return map._entries.length;
    }

    function _at(Map storage map, uint256 index) private view returns (bytes32, bytes32) {
        require(map._entries.length > index, "EnumerableMap: index out of bounds");

        MapEntry storage entry = map._entries[index];
        return (entry._key, entry._value);
    }

    function _get(Map storage map, bytes32 key) private view returns (bytes32) {
        return _get(map, key, "EnumerableMap: nonexistent key");
    }

    function _get(Map storage map, bytes32 key, string memory errorMessage) private view returns (bytes32) {
        uint256 keyIndex = map._indexes[key];
        require(keyIndex != 0, errorMessage); // Equivalent to contains(map, key)
        return map._entries[keyIndex - 1]._value; // All indexes are 1-based
    }


    struct UintToAddressMap {
        Map _inner;
    }

    function set(UintToAddressMap storage map, uint256 key, address value) internal returns (bool) {
        return _set(map._inner, bytes32(key), bytes32(uint256(value)));
    }

    function remove(UintToAddressMap storage map, uint256 key) internal returns (bool) {
        return _remove(map._inner, bytes32(key));
    }

    function contains(UintToAddressMap storage map, uint256 key) internal view returns (bool) {
        return _contains(map._inner, bytes32(key));
    }

    function length(UintToAddressMap storage map) internal view returns (uint256) {
        return _length(map._inner);
    }

    function at(UintToAddressMap storage map, uint256 index) internal view returns (uint256, address) {
        (bytes32 key, bytes32 value) = _at(map._inner, index);
        return (uint256(key), address(uint256(value)));
    }

    function get(UintToAddressMap storage map, uint256 key) internal view returns (address) {
        return address(uint256(_get(map._inner, bytes32(key))));
    }

    function get(UintToAddressMap storage map, uint256 key, string memory errorMessage) internal view returns (address) {
        return address(uint256(_get(map._inner, bytes32(key), errorMessage)));
    }
}// MIT

pragma solidity ^0.6.0;

library Strings {
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
        uint256 index = digits - 1;
        temp = value;
        while (temp != 0) {
            buffer[index--] = byte(uint8(48 + temp % 10));
            temp /= 10;
        }
        return string(buffer);
    }
}// MIT

pragma solidity ^0.6.0;


contract ERC721 is Context, ERC165, IERC721, IERC721Metadata, IERC721Enumerable {
    using SafeMath for uint256;
    using Address for address;
    using EnumerableSet for EnumerableSet.UintSet;
    using EnumerableMap for EnumerableMap.UintToAddressMap;
    using Strings for uint256;

    bytes4 private constant _ERC721_RECEIVED = 0x150b7a02;

    mapping (address => EnumerableSet.UintSet) private _holderTokens;

    EnumerableMap.UintToAddressMap private _tokenOwners;

    mapping (uint256 => address) private _tokenApprovals;

    mapping (address => mapping (address => bool)) private _operatorApprovals;

    string private _name;

    string private _symbol;

    mapping (uint256 => string) private _tokenURIs;

    string private _baseURI;

    bytes4 private constant _INTERFACE_ID_ERC721 = 0x80ac58cd;

    bytes4 private constant _INTERFACE_ID_ERC721_METADATA = 0x5b5e139f;

    bytes4 private constant _INTERFACE_ID_ERC721_ENUMERABLE = 0x780e9d63;

    constructor (string memory name, string memory symbol) public {
        _name = name;
        _symbol = symbol;

        _registerInterface(_INTERFACE_ID_ERC721);
        _registerInterface(_INTERFACE_ID_ERC721_METADATA);
        _registerInterface(_INTERFACE_ID_ERC721_ENUMERABLE);
    }

    function balanceOf(address owner) public view override returns (uint256) {
        require(owner != address(0), "ERC721: balance query for the zero address");

        return _holderTokens[owner].length();
    }

    function ownerOf(uint256 tokenId) public view override returns (address) {
        return _tokenOwners.get(tokenId, "ERC721: owner query for nonexistent token");
    }

    function name() public view override returns (string memory) {
        return _name;
    }

    function symbol() public view override returns (string memory) {
        return _symbol;
    }

    function tokenURI(uint256 tokenId) public view override returns (string memory) {
        require(_exists(tokenId), "ERC721Metadata: URI query for nonexistent token");

        string memory _tokenURI = _tokenURIs[tokenId];

        if (bytes(_baseURI).length == 0) {
            return _tokenURI;
        }
        if (bytes(_tokenURI).length > 0) {
            return string(abi.encodePacked(_baseURI, _tokenURI));
        }
        return string(abi.encodePacked(_baseURI, tokenId.toString()));
    }

    function baseURI() public view returns (string memory) {
        return _baseURI;
    }

    function tokenOfOwnerByIndex(address owner, uint256 index) public view override returns (uint256) {
        return _holderTokens[owner].at(index);
    }

    function totalSupply() public view override returns (uint256) {
        return _tokenOwners.length();
    }

    function tokenByIndex(uint256 index) public view override returns (uint256) {
        (uint256 tokenId, ) = _tokenOwners.at(index);
        return tokenId;
    }

    function approve(address to, uint256 tokenId) public virtual override {
        address owner = ownerOf(tokenId);
        require(to != owner, "ERC721: approval to current owner");

        require(_msgSender() == owner || isApprovedForAll(owner, _msgSender()),
            "ERC721: approve caller is not owner nor approved for all"
        );

        _approve(to, tokenId);
    }

    function getApproved(uint256 tokenId) public view override returns (address) {
        require(_exists(tokenId), "ERC721: approved query for nonexistent token");

        return _tokenApprovals[tokenId];
    }

    function setApprovalForAll(address operator, bool approved) public virtual override {
        require(operator != _msgSender(), "ERC721: approve to caller");

        _operatorApprovals[_msgSender()][operator] = approved;
        emit ApprovalForAll(_msgSender(), operator, approved);
    }

    function isApprovedForAll(address owner, address operator) public view override returns (bool) {
        return _operatorApprovals[owner][operator];
    }

    function transferFrom(address from, address to, uint256 tokenId) public virtual override {
        require(_isApprovedOrOwner(_msgSender(), tokenId), "ERC721: transfer caller is not owner nor approved");

        _transfer(from, to, tokenId);
    }

    function safeTransferFrom(address from, address to, uint256 tokenId) public virtual override {
        safeTransferFrom(from, to, tokenId, "");
    }

    function safeTransferFrom(address from, address to, uint256 tokenId, bytes memory _data) public virtual override {
        require(_isApprovedOrOwner(_msgSender(), tokenId), "ERC721: transfer caller is not owner nor approved");
        _safeTransfer(from, to, tokenId, _data);
    }

    function _safeTransfer(address from, address to, uint256 tokenId, bytes memory _data) internal virtual {
        _transfer(from, to, tokenId);
        require(_checkOnERC721Received(from, to, tokenId, _data), "ERC721: transfer to non ERC721Receiver implementer");
    }

    function _exists(uint256 tokenId) internal view returns (bool) {
        return _tokenOwners.contains(tokenId);
    }

    function _isApprovedOrOwner(address spender, uint256 tokenId) internal view returns (bool) {
        require(_exists(tokenId), "ERC721: operator query for nonexistent token");
        address owner = ownerOf(tokenId);
        return (spender == owner || getApproved(tokenId) == spender || isApprovedForAll(owner, spender));
    }

    function _safeMint(address to, uint256 tokenId) internal virtual {
        _safeMint(to, tokenId, "");
    }

    function _safeMint(address to, uint256 tokenId, bytes memory _data) internal virtual {
        _mint(to, tokenId);
        require(_checkOnERC721Received(address(0), to, tokenId, _data), "ERC721: transfer to non ERC721Receiver implementer");
    }

    function _mint(address to, uint256 tokenId) internal virtual {
        require(to != address(0), "ERC721: mint to the zero address");
        require(!_exists(tokenId), "ERC721: token already minted");

        _beforeTokenTransfer(address(0), to, tokenId);

        _holderTokens[to].add(tokenId);

        _tokenOwners.set(tokenId, to);

        emit Transfer(address(0), to, tokenId);
    }

    function _burn(uint256 tokenId) internal virtual {
        address owner = ownerOf(tokenId);

        _beforeTokenTransfer(owner, address(0), tokenId);

        _approve(address(0), tokenId);

        if (bytes(_tokenURIs[tokenId]).length != 0) {
            delete _tokenURIs[tokenId];
        }

        _holderTokens[owner].remove(tokenId);

        _tokenOwners.remove(tokenId);

        emit Transfer(owner, address(0), tokenId);
    }

    function _transfer(address from, address to, uint256 tokenId) internal virtual {
        require(ownerOf(tokenId) == from, "ERC721: transfer of token that is not own");
        require(to != address(0), "ERC721: transfer to the zero address");

        _beforeTokenTransfer(from, to, tokenId);

        _approve(address(0), tokenId);

        _holderTokens[from].remove(tokenId);
        _holderTokens[to].add(tokenId);

        _tokenOwners.set(tokenId, to);

        emit Transfer(from, to, tokenId);
    }

    function _setTokenURI(uint256 tokenId, string memory _tokenURI) internal virtual {
        require(_exists(tokenId), "ERC721Metadata: URI set of nonexistent token");
        _tokenURIs[tokenId] = _tokenURI;
    }

    function _setBaseURI(string memory baseURI_) internal virtual {
        _baseURI = baseURI_;
    }

    function _checkOnERC721Received(address from, address to, uint256 tokenId, bytes memory _data)
        private returns (bool)
    {
        if (!to.isContract()) {
            return true;
        }
        bytes memory returndata = to.functionCall(abi.encodeWithSelector(
            IERC721Receiver(to).onERC721Received.selector,
            _msgSender(),
            from,
            tokenId,
            _data
        ), "ERC721: transfer to non ERC721Receiver implementer");
        bytes4 retval = abi.decode(returndata, (bytes4));
        return (retval == _ERC721_RECEIVED);
    }

    function _approve(address to, uint256 tokenId) private {
        _tokenApprovals[tokenId] = to;
        emit Approval(ownerOf(tokenId), to, tokenId);
    }

    function _beforeTokenTransfer(address from, address to, uint256 tokenId) internal virtual { }
}// MIT

pragma solidity ^0.6.0;


abstract contract ERC721Burnable is Context, ERC721 {
    function burn(uint256 tokenId) public virtual {
        require(_isApprovedOrOwner(_msgSender(), tokenId), "ERC721Burnable: caller is not owner nor approved");
        _burn(tokenId);
    }
}// MIT

pragma solidity ^0.6.0;


abstract contract ERC721Pausable is ERC721, Pausable {
    function _beforeTokenTransfer(address from, address to, uint256 tokenId) internal virtual override {
        super._beforeTokenTransfer(from, to, tokenId);

        require(!paused(), "ERC721Pausable: token transfer while paused");
    }
}// MIT

pragma solidity ^0.6.0;


contract ERC721PresetMinterPauserAutoId is Context, AccessControl, ERC721Burnable, ERC721Pausable {
    using Counters for Counters.Counter;

    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");
    bytes32 public constant PAUSER_ROLE = keccak256("PAUSER_ROLE");

    Counters.Counter private _tokenIdTracker;

    constructor(string memory name, string memory symbol, string memory baseURI) public ERC721(name, symbol) {
        _setupRole(DEFAULT_ADMIN_ROLE, _msgSender());

        _setupRole(MINTER_ROLE, _msgSender());
        _setupRole(PAUSER_ROLE, _msgSender());

        _setBaseURI(baseURI);
    }

    function mint(address to) public virtual {
        require(hasRole(MINTER_ROLE, _msgSender()), "ERC721PresetMinterPauserAutoId: must have minter role to mint");

        _mint(to, _tokenIdTracker.current());
        _tokenIdTracker.increment();
    }

    function pause() public virtual {
        require(hasRole(PAUSER_ROLE, _msgSender()), "ERC721PresetMinterPauserAutoId: must have pauser role to pause");
        _pause();
    }

    function unpause() public virtual {
        require(hasRole(PAUSER_ROLE, _msgSender()), "ERC721PresetMinterPauserAutoId: must have pauser role to unpause");
        _unpause();
    }

    function _beforeTokenTransfer(address from, address to, uint256 tokenId) internal virtual override(ERC721, ERC721Pausable) {
        super._beforeTokenTransfer(from, to, tokenId);
    }
}// GPL-3.0
pragma solidity 0.6.12;


contract JoysNFT is ERC721PresetMinterPauserAutoId, Ownable {
    using SafeMath for uint256;
    using Address for address;
    using Counters for Counters.Counter;

    struct Meta {
        uint32 level;

        uint32 sVal;

        uint32 iVal;

        uint32 aVal;
    }

    mapping (uint256 => Meta) public metaSet;

    Counters.Counter private tokenIdTracker;

    constructor (string memory name, string memory symbol) public
    ERC721PresetMinterPauserAutoId(name, symbol, "") {
    }

    function setBaseURI(string memory _baseURI) onlyOwner public {
        _setBaseURI(_baseURI);
    }

    function setRoleAdmin(bytes32 role, bytes32 adminRole) onlyOwner public {
        _setRoleAdmin(role, adminRole);
    }

    function mint(address _to, uint32 _level, uint32 _sVal, uint32 _iVal, uint32 _aVal) public {
        require(hasRole(MINTER_ROLE, _msgSender()), "JoysNFT: must have minter role to mint");

        _mint(_to, tokenIdTracker.current());
        metaSet[tokenIdTracker.current()] = Meta(_level, _sVal, _iVal, _aVal);
        tokenIdTracker.increment();
    }

    function mint(address /*_to*/) public onlyOwner override(ERC721PresetMinterPauserAutoId) {
        require(false, "JoysNFT: not supported");
    }

    function info(uint256 tokenId) public view returns (uint32, uint32, uint32, uint32) {
        require(_exists(tokenId), "JoysNFT: URI query for nonexistent token");

        Meta storage m = metaSet[tokenId];
        return (m.level, m.sVal, m.iVal, m.aVal);
    }
}

contract JoysHero is JoysNFT {
    constructor() public JoysNFT("JoysHero NFT", "JoysHero") {
    }
}

contract JoysWeapon is JoysNFT {
    constructor() public JoysNFT("JoysWeapon NFT", "JoysWeapon") {
    }
}// GPL-3.0
pragma solidity 0.6.12;



contract JoysLotteryMeta is Ownable {

    event LotteryMetaAdd(address indexed to, uint32 level,
        uint32 strengthMin, uint32 strengthMax,
        uint32 intelligenceMin, uint32 intelligenceMax,
        uint32 agilityMin, uint32 agilityMax,
        uint256 weight);

    event LotteryMetaUpdate(address indexed to, uint32 level,
        uint32 strengthMin, uint32 strengthMax,
        uint32 intelligenceMin, uint32 intelligenceMax,
        uint32 agilityMin, uint32 agilityMax,
        uint256 weight);

    struct MetaInfo {
        uint32 level;

        uint32 sMin;
        uint32 sMax;

        uint32 iMin;
        uint32 iMax;

        uint32 aMin;
        uint32 aMax;

        uint256 weight;
    }
    MetaInfo[] public metaInfo;
    mapping(uint32 => bool) public metaLevel;

    function addMeta (
        uint32 _level,
        uint32 _sMin,
        uint32 _sMax,
        uint32 _iMin,
        uint32 _iMax,
        uint32 _aMin,
        uint32 _aMax,
        uint256 _weight)
    onlyOwner public {
        require(_level > 0, "JoysLotteryMeta: The level starts at 1.");

        if (metaLevel[_level]) {
            return;
        }

        if(metaInfo.length > 0) {
            require(_level > metaInfo[metaInfo.length - 1].level, "JoysLotteryMeta: new level must bigger than old");
            require(_level == metaInfo[metaInfo.length - 1].level + 1, "JoysLotteryMeta: new level must bigger.");
        }

        metaInfo.push(MetaInfo({
            level: _level,
            sMin: _sMin,
            sMax: _sMax,
            iMin: _iMin,
            iMax: _iMax,
            aMin: _aMin,
            aMax: _aMax,
            weight: _weight
            }));
        metaLevel[_level] = true;

        emit LotteryMetaAdd(_msgSender(), _level, _sMin, _sMax, _iMin, _iMax, _aMin, _aMax, _weight);
    }

    function updateMeta (uint32 _level,
        uint32 _sMin,
        uint32 _sMax,
        uint32 _iMin,
        uint32 _iMax,
        uint32 _aMin,
        uint32 _aMax,
        uint256 _weight)
    onlyOwner public {
        require(_level > 0 && _level <= length(), "JoysLotteryMeta: invalid index.");

        for (uint32 idx = 0; idx < metaInfo.length; ++idx) {
            if (metaInfo[idx].level == _level) {
                metaInfo[idx] = MetaInfo({
                    level: _level,
                    sMin: _sMin,
                    sMax: _sMax,
                    iMin: _iMin,
                    iMax: _iMax,
                    aMin: _aMin,
                    aMax: _aMax,
                    weight: _weight
                    });
                break;
            }
        }

        emit LotteryMetaUpdate(_msgSender(), _level, _sMin, _sMax, _iMin, _iMax, _aMin, _aMax, _weight);
    }

    function length() public view returns (uint32) {
        return uint32(metaInfo.length);
    }

    function meta(uint256 _idx) public view returns (uint32, uint32, uint32, uint32, uint32, uint32, uint32, uint256){
        require(_idx < length(), "JoysLotteryMeta: invalid index.");
        MetaInfo storage m = metaInfo[_idx];
        return (m.level, m.sMin, m.sMax, m.iMin, m.iMax, m.aMin, m.aMax, m.weight);
    }
}

contract JoysHeroLotteryMeta is JoysLotteryMeta {
    constructor() public {
        addMeta(1, 500, 800, 400, 600, 500, 800, 10000);
        addMeta(2, 1500, 1800, 1000, 1200, 1500, 1800, 5000);
        addMeta(3, 4000, 6000, 4000, 6000, 2500, 3500, 2000);
        addMeta(4, 7000, 9000, 9000, 10000, 6000, 7000, 500);
        addMeta(5, 10000, 11000, 10000, 12000, 9000, 10000, 100);
        addMeta(6, 18000, 20000, 18000, 20000, 16000, 18000, 5);
    }
}

contract JoysWeaponLotteryMeta is JoysLotteryMeta {
    constructor() public {
        addMeta(1, 500, 700, 600, 800, 600, 800, 10000);
        addMeta(2, 1800, 2000, 1600, 1800, 2000, 2200, 4000);
        addMeta(3, 3000, 4000, 2500, 3500, 3000, 4000, 2000);
        addMeta(4, 6000, 8000, 8000, 9000, 6000, 7000, 500);
        addMeta(5, 16000, 18000, 16000, 18000, 18000, 20000, 0);
        addMeta(6, 18000, 20000, 16000, 18000, 16000, 18000, 0);
    }
}/**
Copyright 2019 PoolTogether LLC

This file is part of PoolTogether.

PoolTogether is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation under version 3 of the License.

PoolTogether is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with PoolTogether.  If not, see <https://www.gnu.org/licenses/>.
*/
pragma solidity 0.6.12;

library UniformRandomNumber {
  function uniform(uint256 _entropy, uint256 _upperBound) internal pure returns (uint256) {
    require(_upperBound > 0, "UniformRand/min-bound");
    uint256 min = -_upperBound % _upperBound;
    uint256 random = _entropy;
    while (true) {
      if (random >= min) {
        break;
      }
      random = uint256(keccak256(abi.encodePacked(random)));
    }
    return random % _upperBound;
  }
}// GPL-3.0
pragma solidity 0.6.12;




contract JoysLottery is ReentrancyGuard, Pausable, Ownable {
    using Counters for Counters.Counter;
    using SafeMath for uint256;
    using SafeMath for uint32;
    using Address for address;
    using SafeERC20 for IERC20;
    using SafeCast for uint256;

    uint8 public constant CS_NORMAL = 1;
    uint8 public constant CS_CLAIMED = 2;

    uint16 public constant FREE_HERO_COUNT = 1999;
    uint16 public heroClaimed;

    uint8 public constant CS_HERO_LEVEL = 3;
    uint8 public constant CS_WEAPON_LEVEL = 2;

    uint8 public constant HL_HERO = 99;
    uint8 public constant HL_WEAPON = 99;
    uint8 public hlHero;
    uint8 public hlWeapon;

    mapping (address => uint8) public crowdSalesHero;
    mapping (address => uint8) public crowdSalesWeapon;

    mapping (address => uint8) public freeClaimHero;

    struct InviteClaimInfo {
        uint8 state;
        uint256 joys;
        address addr;
    }
    mapping (address => InviteClaimInfo[]) public inviteClaimHero;

    uint256 public heroClaimFee = 50 * 1e18;
    uint256 public weaponClaimFee = 50 * 1e18;

    JoysToken public joys;                  // address of joys token contract
    JoysNFT public joysHero;                // address of joys hero contract
    JoysNFT public joysWeapon;              // address of joys weapon contract
    JoysLotteryMeta public heroMeta;        // address of joys hero meta contract
    JoysLotteryMeta public weaponMeta;      // address of joys weapon meta contract
    address public nftJackpot;              // jackpot from 50% of draw

    enum Operation {
        crowdSaleClaim,
        inviteClaim,
        freeClaim,
        notFreeDrawHero,
        notFreeDrawWeapon
    }
    enum BoxState {
        Init,
        CanOpen,
        Opened,
        Expired
    }
    struct RequestInfo {
        Operation operation;

        uint32 reqID;

        uint40 blockNumber;

        uint32 a;
        uint32 b;
        uint256 c;

        uint timestamp;

        BoxState state;
    }
    mapping(address => RequestInfo[]) public reqBox;
    Counters.Counter public reqIdTracker;

    uint constant REQ_EXPIRATION_BLOCKS = 250;
    uint constant REQ_DELAY_BLOCKS = 3;

    mapping(uint256 => uint256) public randomNumbers;

    uint256 public lotteryFee = 0.03 * 1e18;
    address payable[] public lotteryRole;

    event ClaimRareHero(address indexed to, uint32 level, uint32 strength, uint32 intelligence, uint32 agility);
    event ClaimRareWeapon(address indexed to, uint32 level, uint32 strength, uint32 intelligence, uint32 agility);
    event ClaimHero(address indexed to, uint32 level, uint32 strength, uint32 intelligence, uint32 agility, uint256 joys);
    event DrawHero(address indexed to, uint32 level, uint32 strength, uint32 intelligence, uint32 agility);
    event DrawWeapon(address indexed to, uint32 level, uint32 strength, uint32 intelligence, uint32 agility);

    constructor(address _joys,
        address _joysHero,
        address _joysWeapon,
        address _heroMeta,
        address _weaponMeta,
        address _jackpot
    ) public {
        joys = JoysToken(_joys);
        joysHero = JoysNFT(_joysHero);
        joysWeapon = JoysNFT(_joysWeapon);
        heroMeta = JoysLotteryMeta(_heroMeta);
        weaponMeta = JoysLotteryMeta(_weaponMeta);

        nftJackpot = _jackpot;
    }

    function lotteryMemberCount() public view returns (uint256) {
        return lotteryRole.length;
    }

    function getRoleMember(uint256 index) public view returns (address payable) {
        require(lotteryMemberCount() > index, "JoysLottery: lottery role index out of bounds");
        return lotteryRole[index];
    }

    function hasRole(address account) private view returns (bool) {
        for(uint256 i = 0; i < lotteryMemberCount(); ++i) {
            if (getRoleMember(i) == account) {
                return true;
            }
        }
        return false;
    }

    function grantLotteryRole(address payable[] memory _account) onlyOwner public {
        for(uint32 idx = 0; idx < _account.length; ++idx) {
            lotteryRole.push(_account[idx]);
        }
    }

    function revokeLotteryRole(address payable account) onlyOwner public {
        for(uint256 i = 0; i < lotteryMemberCount(); ++i) {
            if (getRoleMember(i) == account) {
                address payable last = getRoleMember(lotteryMemberCount() -1);
                lotteryRole[i] = last;
                lotteryRole.pop();
            }
        }
    }

    function setLotteryFee(uint256 _fee) onlyOwner public {
        require(lotteryFee != _fee, "JoysLottery:same fee.");
        lotteryFee = _fee;
    }

    function addCrowdSaleAddress(address[] memory _address, bool _claimWeapon) onlyOwner public{
        bool heroClaim = false;
        bool weaponClaim = false;
        for (uint32 idx = 0; idx < _address.length; ++idx) {
            if (crowdSalesHero[address(_address[idx])] >= CS_NORMAL) {
                continue;
            }
            crowdSalesHero[_address[idx]] = CS_NORMAL;
            heroClaim = true;
        }

        if (!_claimWeapon) {
            require(heroClaim, "JoysLottery: not changed.");
            return;
        }
        for (uint32 idx = 0; idx < _address.length; ++idx) {
            if (crowdSalesWeapon[address(_address[idx])] >= CS_NORMAL) {
                continue;
            }
            crowdSalesWeapon[address(_address[idx])] = CS_NORMAL;
            weaponClaim = true;
        }

        require(heroClaim || weaponClaim, "JoysLottery: not changed.");
    }

    function addInviteClaimAddress(address _inviter, address _user, uint256 _joys) onlyOwner public {
        for(uint32 i = 0; i < inviteClaimHero[_inviter].length; ++i) {
            require(inviteClaimHero[_inviter][i].addr != _user, "JoysLottery: Already add.");
        }

        inviteClaimHero[_inviter].push(InviteClaimInfo({
            state: CS_NORMAL,
            joys: _joys,
            addr: _user
            }));
    }

    function addFreeClaimAddress(address[] memory _address) onlyOwner public {
        for(uint32 i = 0; i < _address.length; ++i) {
            freeClaimHero[_address[i]] = CS_NORMAL;
        }
    }

    function _randN(uint256 _seed, uint256 _min, uint256 _max, uint256 _offset) internal pure returns (uint256) {
        require(_max > _min, "JoysLottery:randN condition");
        return UniformRandomNumber.uniform(_seed + _offset, (_max - _min).div(2)).add(_min);
    }

    function _randLevel(uint256 _seed, uint256 _max) internal pure returns (uint256) {
        return UniformRandomNumber.uniform(_seed, _max);
    }

    function _randRareNFTMeta(address _address, uint32 _requestId,
        uint32 _level, uint32 _sMin, uint32 _sMax, uint32 _iMin, uint32 _iMax, uint32 _aMin, uint32 _aMax)
    internal returns (uint32, uint32, uint32, uint32) {
        uint256 seed = randomNumber(_address, _requestId);
        uint32 strength = _randN(seed, uint256(_sMin), uint256(_sMax), block.timestamp).toUint32();
        uint32 intelligence = _randN(seed, uint256(_iMin), uint256(_iMax), block.gaslimit).toUint32();
        uint32 agility = _randN(seed, uint256(_aMin), uint256(_aMax), block.difficulty).toUint32();
        return (_level, strength, intelligence, agility);
    }

    function _crowdSaleHero(address _address, uint32 _requestId) internal returns (uint32, uint32, uint32, uint32){
        for (uint256 idx = 0; idx < heroMeta.length(); ++idx) {
            uint32 level;
            uint32 sMin;
            uint32 sMax;
            uint32 iMin;
            uint32 iMax;
            uint32 aMin;
            uint32 aMax;
            uint256 weight;
            (level, sMin, sMax, iMin, iMax, aMin, aMax, weight) = heroMeta.meta(idx);
            if (level == CS_HERO_LEVEL) {
                return _randRareNFTMeta(_address, _requestId, level, sMin, sMax, iMin, iMax, aMin, aMax);
            }
        }
        return (0, 0, 0, 0);
    }

    function _crowdSaleWeapon(address _address, uint32 _requestId) internal returns (uint32 , uint32 , uint32 , uint32){
        for (uint256 idx = 0; idx < weaponMeta.length(); ++idx) {
            uint32 level;
            uint32 sMin;
            uint32 sMax;
            uint32 iMin;
            uint32 iMax;
            uint32 aMin;
            uint32 aMax;
            uint256 weight;
            (level, sMin, sMax, iMin, iMax, aMin, aMax, weight) = weaponMeta.meta(idx);
            if (level == CS_WEAPON_LEVEL) {
                return _randRareNFTMeta(_address, _requestId, level, sMin, sMax, iMin, iMax, aMin, aMax);
            }
        }
        return (0, 0, 0, 0);
    }

    function crowdSaleClaim(address _address, uint32 _requestId) private returns (uint32, uint32, uint256) {
        uint32 heroLevel;
        uint32 weaponLevel;
        if (crowdSalesHero[_address] == CS_NORMAL && heroClaimed < FREE_HERO_COUNT) {
            uint32 level;
            uint32 strength;
            uint32 intelligence;
            uint32 agility;
            (level, strength, intelligence, agility) = _crowdSaleHero(_address, _requestId);
            require(level > 0, "JoysLottery: claim hero with error level.");

            joysHero.mint(_address, level, strength, intelligence, agility);
            crowdSalesHero[_address] = CS_CLAIMED;
            heroClaimed++;

            heroLevel = level;
            emit ClaimRareHero(_address, level, strength, intelligence, agility);
        }

        if (crowdSalesWeapon[_address] == CS_NORMAL) {
            uint32 level;
            uint32 strength;
            uint32 intelligence;
            uint32 agility;
            (level, strength, intelligence, agility) = _crowdSaleWeapon(_address, _requestId);
            require(level > 0, "JoysLottery: claim weapon with error level.");

            joysWeapon.mint(_address, level, strength, intelligence, agility);
            crowdSalesWeapon[_address] = CS_CLAIMED;

            weaponLevel = level;
            emit ClaimRareWeapon(_address, level, strength, intelligence, agility);
        }
        return (heroLevel, weaponLevel, 0);
    }

    function inviteClaim(address _address, uint32 _requestId) private returns (uint32, uint32, uint256) {
        require(heroClaimed < FREE_HERO_COUNT, "JoysLottery: No free hero to be claimed");

        bool flag = false;
        uint32 idx = 0;
        for (uint32 i = 0; i < inviteClaimHero[_address].length; ++i) {
            if (inviteClaimHero[_address][i].state == CS_NORMAL) {
                idx = i;
                flag = true;
                break;
            }
        }
        require(flag, "JoysLottery: all claimed");

        uint32 level;
        uint32 strength;
        uint32 intelligence;
        uint32 agility;
        (level, strength, intelligence, agility) = _draw(_address, _requestId, heroMeta);
        joysHero.mint(_address, level, strength, intelligence, agility);

        uint256 token = inviteClaimHero[_address][idx].joys;
        joys.transfer(_address, token);

        inviteClaimHero[_address][idx].state = CS_CLAIMED;
        heroClaimed++;

        emit ClaimHero(_address, level, strength, intelligence, agility, token);

        return (level, 0, token.div(1e18));
    }

    function freeClaim(address _address, uint32 _requestId) private returns (uint32, uint32, uint256) {
        require(heroClaimed < FREE_HERO_COUNT, "JoysLottery: no free hero claimed");
        require(freeClaimHero[_address] == CS_NORMAL, "JoysLottery: have claimed");

        uint32 level;
        uint32 strength;
        uint32 intelligence;
        uint32 agility;
        (level, strength, intelligence, agility) = _draw(_address, _requestId, heroMeta);

        joysHero.mint(_address, level, strength, intelligence, agility);

        freeClaimHero[_address] = CS_CLAIMED;
        heroClaimed++;

        emit ClaimHero(_address, level, strength, intelligence, agility, 0);

        return (level, 0, 0);
    }

    function _weightSlice(JoysLotteryMeta _meta, uint32 _step) private view returns (uint256 _sum) {
        uint32 idx = 0;
        for (uint32 i = _meta.length(); i > 0; i--) {
            idx++;
            uint256 w;
            (, , , , , , , w) = _meta.meta(i-1);
            _sum += w;
            if (idx >= _step) {
                break;
            }
        }
        return _sum;
    }

    function _parseLevel(uint256 _weight, JoysLotteryMeta _meta) private view returns(uint32) {
        uint256[] memory calWeight = new uint256[](_meta.length()+1);
        for(uint32 i = 0; i < _meta.length(); i++) {
            calWeight[i] = _weightSlice(_meta, _meta.length()-i);
        }

        uint32 level;
        for (uint32 i = 0; i < calWeight.length; ++i) {
            uint256 w = calWeight[i];
            level = i;
            if(_weight >= w) {
                if(i == 0) {
                    return 1;
                }
                break;
            }
            if(_weight < w) {
                continue;
            }
        }
        return level;
    }

    function _draw(address _address, uint32 _requestId, JoysLotteryMeta _meta)
    private returns (uint32 level, uint32 strength, uint32 intelligence, uint32 agility) {
        uint256 weight;
        for (uint256 idx = 0; idx < _meta.length(); ++idx) {
            uint256 w;
            ( , , , , , , , w) = _meta.meta(idx);
            weight += w;
        }
        uint256 seed = randomNumber(_address, _requestId);
        level = _parseLevel(_randLevel(seed, weight), _meta);
        require(level > 0, "JoysLottery: with error level.");

        uint32 sMin;
        uint32 sMax;
        uint32 iMin;
        uint32 iMax;
        uint32 aMin;
        uint32 aMax;
        (, sMin, sMax, iMin, iMax, aMin, aMax, ) = _meta.meta(level-1);
        strength = _randN(seed, uint256(sMin), uint256(sMax), block.timestamp).toUint32();
        intelligence = _randN(seed, uint256(iMin), uint256(iMax), block.gaslimit).toUint32();
        agility = _randN(seed, uint256(aMin), uint256(aMax), block.difficulty).toUint32();
    }

    function drawHero(address _address, uint32 _requestId) private returns (uint32, uint32, uint256) {
        uint32 a;
        uint32 b;
        uint32 c;
        uint32 d;
        (a,b,c,d) = _draw(_address, _requestId, heroMeta);
        joysHero.mint(_address, a, b, c, d);

        return (a, 0, 0);
    }

    function drawWeapon(address _address, uint32 _requestId) private returns (uint32, uint32, uint256) {
        uint32 a;
        uint32 b;
        uint32 c;
        uint32 d;
        (a,b,c,d) = _draw(_address, _requestId, weaponMeta);
        joysWeapon.mint(_address, a, b, c, d);

        return (0, b, 0);
    }

    function setFee(uint256 _hero, uint256 _weapon) public onlyOwner {
        require(heroClaimFee != _hero || weaponClaimFee != _weapon, "JoysLottery: no need");
        heroClaimFee = _hero;
        weaponClaimFee = _weapon;
    }

    function transferHeroOwnership(address _newHero) public onlyOwner {
        joysHero.transferOwnership(_newHero);
    }

    function transferWeaponOwnership(address _newWeapon) public onlyOwner {
        joysWeapon.transferOwnership(_newWeapon);
    }

    function mintHero(uint32 _level, uint32 _strength, uint32 _intelligence, uint32 _agility) public onlyOwner {
        require(hlHero < HL_HERO, "JoysLottery: max high level hero.");
        require(_level <= heroMeta.length(), "JoysLottery: wrong level.");
        joysHero.mint(_msgSender(), _level, _strength, _intelligence, _agility);
        hlHero++;
    }

    function mintWeapon(uint32 _level, uint32 _strength, uint32 _intelligence, uint32 _agility) public onlyOwner {
        require(hlWeapon < HL_HERO, "JoysLottery: max high level weapon.");
        require(_level <= weaponMeta.length(), "JoysLottery: wrong level.");
        joysWeapon.mint(_msgSender(), _level, _strength, _intelligence, _agility);
        hlWeapon++;
    }

    function _getNextRequestId() internal view returns (uint32 requestId) {
        uint256 len = reqBox[_msgSender()].length;
        requestId = len <= 0 ? 1 : reqBox[_msgSender()][len - 1].reqID.add(1).toUint32();
    }

    function requestState(address _address, uint32 _requestId) public view returns (BoxState) {
        require(_address != address(0), "JoysLottery: invalid address.");
        require(_requestId > 0, "JoysLottery: zero request id.");

        uint256 len = requestCount(_address);
        require(len > 0, "JoysLottery: have no request.");
        require(_requestId <= len, "JoysLottery: invalid request id.");

        bool flag = false;
        uint256 idx = 0;
        for(uint256 i = len; i > 0; i--) {
            if (reqBox[_address][i-1].reqID == _requestId) {
                flag = true;
                idx = i-1;
                break;
            }
        }
        require(flag, "JoysLottery: don't have the special request id.");

        RequestInfo storage r = reqBox[_address][idx];
        uint40 blockNumber = r.blockNumber;
        if (r.state == BoxState.Init) {
            if(block.number > blockNumber + REQ_DELAY_BLOCKS &&
                block.number <= blockNumber + REQ_EXPIRATION_BLOCKS) {
                return BoxState.CanOpen;
            } else {
                return BoxState.Expired;
            }
        }

        return r.state;
    }

    function _getSeed(address _address, uint32 _requestId) internal virtual view returns (uint256 seed) {
        uint256 len = requestCount(_address);
        bool flag = false;
        uint256 idx = 0;
        for(uint256 i = len; i > 0; i--) {
            if (reqBox[_address][i-1].reqID == _requestId) {
                flag = true;
                idx = i-1;
                break;
            }
        }
        require(flag, "JoysLottery: gen seed error, no request id.");

        RequestInfo storage r = reqBox[_address][idx];
        seed = uint256(blockhash(r.blockNumber + REQ_DELAY_BLOCKS)) + uint256(_address)+ _requestId;
    }

    function _storeResult(address _address, uint32 _requestId, uint256 _result) internal returns (uint256) {
        uint256 key = (uint256(_address) + _requestId);
        if (randomNumbers[key] == 0) {
            randomNumbers[key] = _result;
        }

        return randomNumbers[key];
    }

    function randomNumber(address _address, uint32 _requestId) internal returns (uint256 randomNum) {
        return _storeResult(_address, _requestId, _getSeed(_address, _requestId));
    }

    function getBox(Operation _op) whenNotPaused nonReentrant public payable {
        require(msg.value >= lotteryFee, "JoysLottery: lottery fee limit.");
        require(lotteryMemberCount() > 0, "JoysLottery: no lottery role.");

        uint32 requestId = _getNextRequestId();
        uint40 lockBlock = uint40(block.number);

        if(requestId > 1) {
            uint32 lastRequest = requestId -1;
            BoxState state = requestState(_msgSender(), lastRequest);
            require(state == BoxState.Opened || state == BoxState.Expired, "JoysLottery: invalid request.");
            if(state == BoxState.Expired) {
                for(uint256 i = reqBox[_msgSender()].length; i > 0; i--) {
                    if(reqBox[_msgSender()][i-1].reqID == lastRequest) {
                        reqBox[_msgSender()][i-1].state = BoxState.Expired;
                        break;
                    }
                }
            }
        }

        if(_op == Operation.crowdSaleClaim) {
            require(
                crowdSalesHero[_msgSender()] == CS_NORMAL && heroClaimed < FREE_HERO_COUNT ||
                crowdSalesWeapon[_msgSender()] == CS_NORMAL,
                    "JoysLottery: Have no qualified.");

        } else if (_op == Operation.inviteClaim) {
            require(heroClaimed < FREE_HERO_COUNT, "JoysLottery: No free hero to be claimed");
            bool flag = false;
            uint256 len = inviteClaimHero[_msgSender()].length;
            require(len > 0, "JoysLottery: No invite qualified.");

            uint256 tokens;
            for (uint32 i = 0; i < len; ++i) {
                if (inviteClaimHero[_msgSender()][i].state == CS_NORMAL) {
                    flag = true;
                    tokens = inviteClaimHero[_msgSender()][i].joys;
                    break;
                }
            }
            require(flag, "JoysLottery: all claimed.");
            require(joys.balanceOf(address(this)) >= tokens, "JoysLottery:not enough JOYS to claim.");

        } else if (_op == Operation.freeClaim) {
            require(heroClaimed < FREE_HERO_COUNT, "JoysLottery: no free hero claimed");
            require(freeClaimHero[_msgSender()] == CS_NORMAL, "JoysLottery: have claimed");

        } else if (_op == Operation.notFreeDrawHero) {
            require(joys.balanceOf(_msgSender()) >= heroClaimFee, "JoysLottery: Insufficient joys token.");

            joys.transferFrom(_msgSender(), address(this), heroClaimFee);
            joys.burn(heroClaimFee.div(2));

            joys.transfer(nftJackpot, heroClaimFee.div(2));

        } else if (_op == Operation.notFreeDrawWeapon) {
            require(joys.balanceOf(_msgSender()) >= weaponClaimFee, "JoysLottery: Insufficient joys token.");

            joys.transferFrom(_msgSender(), address(this), weaponClaimFee);
            joys.burn(weaponClaimFee.div(2));

            joys.transfer(nftJackpot, weaponClaimFee.div(2));

        } else {
            require(false, "JoysLottery: invalid operation.");
        }

        reqIdTracker.increment();
        uint256 idx = reqIdTracker.current().mod(lotteryMemberCount());
        _receive(getRoleMember(idx));

        reqBox[_msgSender()].push(RequestInfo({
            operation: _op,
            reqID: requestId,
            blockNumber: lockBlock,
            a:0,
            b:0,
            c:0,
            timestamp: 0,
            state: BoxState.Init
            }));
    }

    function _receive(address payable _address) private {
        _address.transfer(msg.value);
    }

    function openBox(address _address) public {
        require(hasRole(_msgSender()), "JoysLottery: have no privilege.");

        uint256 len = requestCount(_address);
        require(len > 0, "JoysLottery: have no box.");

        uint256 idx = len - 1;
        RequestInfo storage req = reqBox[_address][idx];
        uint32 _requestId = req.reqID;
        require(requestState(_address, _requestId) == BoxState.CanOpen, "JoysLottery: invalid request state.");

        uint32 a;
        uint32 b;
        uint256 c;
        Operation _op = req.operation;
        if(_op == Operation.crowdSaleClaim) {
            (a, b, c) = crowdSaleClaim(_address, _requestId);

        } else if (_op == Operation.inviteClaim) {
            (a, b, c) = inviteClaim(_address, _requestId);

        } else if (_op == Operation.freeClaim) {
            (a, b, c) = freeClaim(_address, _requestId);

        } else if (_op == Operation.notFreeDrawHero) {
            (a, b, c) = drawHero(_address, _requestId);

        } else if (_op == Operation.notFreeDrawWeapon) {
            (a, b, c) = drawWeapon(_address, _requestId);

        } else {
            require(false, "JoysLottery: invalid operation.");

        }

        reqBox[_address][idx].a = a;
        reqBox[_address][idx].b = b;
        reqBox[_address][idx].c = c;
        reqBox[_address][idx].timestamp = block.timestamp;
        reqBox[_address][idx].state = BoxState.Opened;
    }

    function inviteCount(address _address) public view returns (uint256) {
        return inviteClaimHero[_address].length;
    }

    function requestCount(address _address) public view returns (uint256){
        return reqBox[_address].length;
    }

    function setAddress(address _joys,
        address _joysHero,
        address _joysWeapon,
        address _heroMeta,
        address _weaponMeta,
        address _jackpot
    ) public onlyOwner {
        joys = JoysToken(_joys);
        joysHero = JoysHero(_joysHero);
        joysWeapon = JoysWeapon(_joysWeapon);
        heroMeta = JoysLotteryMeta(_heroMeta);
        weaponMeta = JoysLotteryMeta(_weaponMeta);

        nftJackpot = _jackpot;
    }

    function recycleJoysToken(address _address) public onlyOwner {
        require(_address != address(0), "JoysLottery:Invalid address");
        require(joys.balanceOf(address(this)) > 0, "JoysLottery:no JOYS");
        joys.transfer(_address, joys.balanceOf(address(this)));
    }
}