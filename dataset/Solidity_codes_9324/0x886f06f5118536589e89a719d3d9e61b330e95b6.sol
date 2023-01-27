


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
}



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
}



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
}



pragma solidity >=0.6.0 <0.8.0;




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
}



pragma solidity >=0.6.0 <0.8.0;

abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}



pragma solidity >=0.6.0 <0.8.0;




contract ERC20 is Context, IERC20 {

    using SafeMath for uint256;

    mapping (address => uint256) private _balances;

    mapping (address => mapping (address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;
    uint8 private _decimals;

    constructor (string memory name_, string memory symbol_) public {
        _name = name_;
        _symbol = symbol_;
        _decimals = 18;
    }

    function name() public view virtual returns (string memory) {

        return _name;
    }

    function symbol() public view virtual returns (string memory) {

        return _symbol;
    }

    function decimals() public view virtual returns (uint8) {

        return _decimals;
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

    function _setupDecimals(uint8 decimals_) internal virtual {

        _decimals = decimals_;
    }

    function _beforeTokenTransfer(address from, address to, uint256 amount) internal virtual { }

}



pragma solidity >=0.6.0 <0.8.0;



abstract contract ERC20Burnable is Context, ERC20 {
    using SafeMath for uint256;

    function burn(uint256 amount) public virtual {
        _burn(_msgSender(), amount);
    }

    function burnFrom(address account, uint256 amount) public virtual {
        uint256 decreasedAllowance = allowance(account, _msgSender()).sub(amount, "ERC20: burn amount exceeds allowance");

        _approve(account, _msgSender(), decreasedAllowance);
        _burn(account, amount);
    }
}


pragma solidity >=0.5.17;

interface IMarket {
	function authenticate(
		address _prop,
		string calldata _args1,
		string calldata _args2,
		string calldata _args3,
		string calldata _args4,
		string calldata _args5
	) external returns (bool);

	function authenticateFromPropertyFactory(
		address _prop,
		address _author,
		string calldata _args1,
		string calldata _args2,
		string calldata _args3,
		string calldata _args4,
		string calldata _args5
	) external returns (bool);

	function authenticatedCallback(address _property, bytes32 _idHash)
		external
		returns (address);

	function deauthenticate(address _metrics) external;

	function schema() external view returns (string memory);

	function behavior() external view returns (address);

	function issuedMetrics() external view returns (uint256);

	function enabled() external view returns (bool);

	function votingEndBlockNumber() external view returns (uint256);

	function toEnable() external;
}


pragma solidity >=0.5.17;

interface IMarketBehavior {
	function authenticate(
		address _prop,
		string calldata _args1,
		string calldata _args2,
		string calldata _args3,
		string calldata _args4,
		string calldata _args5,
		address market,
		address account
	) external returns (bool);

	function schema() external view returns (string memory);

	function getId(address _metrics) external view returns (string memory);

	function getMetrics(string calldata _id) external view returns (address);
}


pragma solidity >=0.5.17;

interface IProperty {
	function author() external view returns (address);

	function changeAuthor(address _nextAuthor) external;

	function withdraw(address _sender, uint256 _value) external;
}


pragma solidity >=0.5.17;

interface IAddressConfig {
	function token() external view returns (address);

	function allocator() external view returns (address);

	function allocatorStorage() external view returns (address);

	function withdraw() external view returns (address);

	function withdrawStorage() external view returns (address);

	function marketFactory() external view returns (address);

	function marketGroup() external view returns (address);

	function propertyFactory() external view returns (address);

	function propertyGroup() external view returns (address);

	function metricsGroup() external view returns (address);

	function metricsFactory() external view returns (address);

	function policy() external view returns (address);

	function policyFactory() external view returns (address);

	function policySet() external view returns (address);

	function policyGroup() external view returns (address);

	function lockup() external view returns (address);

	function lockupStorage() external view returns (address);

	function voteTimes() external view returns (address);

	function voteTimesStorage() external view returns (address);

	function voteCounter() external view returns (address);

	function voteCounterStorage() external view returns (address);

	function setAllocator(address _addr) external;

	function setAllocatorStorage(address _addr) external;

	function setWithdraw(address _addr) external;

	function setWithdrawStorage(address _addr) external;

	function setMarketFactory(address _addr) external;

	function setMarketGroup(address _addr) external;

	function setPropertyFactory(address _addr) external;

	function setPropertyGroup(address _addr) external;

	function setMetricsFactory(address _addr) external;

	function setMetricsGroup(address _addr) external;

	function setPolicyFactory(address _addr) external;

	function setPolicyGroup(address _addr) external;

	function setPolicySet(address _addr) external;

	function setPolicy(address _addr) external;

	function setToken(address _addr) external;

	function setLockup(address _addr) external;

	function setLockupStorage(address _addr) external;

	function setVoteTimes(address _addr) external;

	function setVoteTimesStorage(address _addr) external;

	function setVoteCounter(address _addr) external;

	function setVoteCounterStorage(address _addr) external;
}


pragma solidity >=0.5.17;

interface IDev {
	function deposit(address _to, uint256 _amount) external returns (bool);

	function depositFrom(
		address _from,
		address _to,
		uint256 _amount
	) external returns (bool);

	function fee(address _from, uint256 _amount) external returns (bool);
}


pragma solidity >=0.5.17;

interface ILockup {
	function lockup(
		address _from,
		address _property,
		uint256 _value
	) external;

	function update() external;

	function withdraw(address _property, uint256 _amount) external;

	function calculateCumulativeRewardPrices()
		external
		view
		returns (
			uint256 _reward,
			uint256 _holders,
			uint256 _interest
		);

	function calculateCumulativeHoldersRewardAmount(address _property)
		external
		view
		returns (uint256);

	function getPropertyValue(address _property)
		external
		view
		returns (uint256);

	function getAllValue() external view returns (uint256);

	function getValue(address _property, address _sender)
		external
		view
		returns (uint256);

	function calculateWithdrawableInterestAmount(
		address _property,
		address _user
	) external view returns (uint256);
}



pragma solidity >=0.6.0 <0.8.0;

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
}




pragma solidity >=0.6.0 <0.8.0;




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
}


pragma solidity >=0.7.6;

interface IAdmin {
	function addAdmin(address admin) external;

	function deleteAdmin(address admin) external;

	function isAdmin(address account) external view returns (bool);
}



pragma solidity >=0.7.6;



abstract contract Admin is AccessControl, IAdmin {
	constructor() {
		_setupRole(DEFAULT_ADMIN_ROLE, _msgSender());
	}

	modifier onlyAdmin() {
		require(hasRole(DEFAULT_ADMIN_ROLE, _msgSender()), "admin only.");
		_;
	}

	function addAdmin(address admin) external virtual override onlyAdmin {
		grantRole(DEFAULT_ADMIN_ROLE, admin);
	}

	function deleteAdmin(address admin) external virtual override onlyAdmin {
		revokeRole(DEFAULT_ADMIN_ROLE, admin);
	}

	function isAdmin(address account) external view override returns (bool) {
		return hasRole(DEFAULT_ADMIN_ROLE, account);
	}
}



pragma solidity >=0.7.6;

contract EternalStorage {
	address private currentOwner = msg.sender;

	mapping(bytes32 => uint256) private uIntStorage;
	mapping(bytes32 => string) private stringStorage;
	mapping(bytes32 => address) private addressStorage;
	mapping(bytes32 => bytes32) private bytesStorage;
	mapping(bytes32 => bool) private boolStorage;
	mapping(bytes32 => int256) private intStorage;

	modifier onlyCurrentOwner() {
		require(msg.sender == currentOwner, "not current owner");
		_;
	}

	function changeOwner(address _newOwner) external {
		require(msg.sender == currentOwner, "not current owner");
		currentOwner = _newOwner;
	}


	function getUint(bytes32 _key) external view returns (uint256) {
		return uIntStorage[_key];
	}

	function getString(bytes32 _key) external view returns (string memory) {
		return stringStorage[_key];
	}

	function getAddress(bytes32 _key) external view returns (address) {
		return addressStorage[_key];
	}

	function getBytes(bytes32 _key) external view returns (bytes32) {
		return bytesStorage[_key];
	}

	function getBool(bytes32 _key) external view returns (bool) {
		return boolStorage[_key];
	}

	function getInt(bytes32 _key) external view returns (int256) {
		return intStorage[_key];
	}


	function setUint(bytes32 _key, uint256 _value) external onlyCurrentOwner {
		uIntStorage[_key] = _value;
	}

	function setString(bytes32 _key, string calldata _value)
		external
		onlyCurrentOwner
	{
		stringStorage[_key] = _value;
	}

	function setAddress(bytes32 _key, address _value)
		external
		onlyCurrentOwner
	{
		addressStorage[_key] = _value;
	}

	function setBytes(bytes32 _key, bytes32 _value) external onlyCurrentOwner {
		bytesStorage[_key] = _value;
	}

	function setBool(bytes32 _key, bool _value) external onlyCurrentOwner {
		boolStorage[_key] = _value;
	}

	function setInt(bytes32 _key, int256 _value) external onlyCurrentOwner {
		intStorage[_key] = _value;
	}


	function deleteUint(bytes32 _key) external onlyCurrentOwner {
		delete uIntStorage[_key];
	}

	function deleteString(bytes32 _key) external onlyCurrentOwner {
		delete stringStorage[_key];
	}

	function deleteAddress(bytes32 _key) external onlyCurrentOwner {
		delete addressStorage[_key];
	}

	function deleteBytes(bytes32 _key) external onlyCurrentOwner {
		delete bytesStorage[_key];
	}

	function deleteBool(bytes32 _key) external onlyCurrentOwner {
		delete boolStorage[_key];
	}

	function deleteInt(bytes32 _key) external onlyCurrentOwner {
		delete intStorage[_key];
	}
}


pragma solidity >=0.7.6;

interface IUsingStorage {
	function isStorageOwner(address account) external view returns (bool);

	function addStorageOwner(address _storageOwner) external;

	function deleteStorageOwner(address _storageOwner) external;

	function getStorageAddress() external view returns (address);

	function createStorage() external;

	function setStorage(address _storageAddress) external;

	function changeOwner(address newOwner) external;
}



pragma solidity >=0.7.6;




contract UsingStorage is Admin, IUsingStorage {
	address private _storage;
	bytes32 public constant STORAGE_OWNER_ROLE =
		keccak256("STORAGE_OWNER_ROLE");

	constructor() {
		_setRoleAdmin(STORAGE_OWNER_ROLE, DEFAULT_ADMIN_ROLE);
		grantRole(STORAGE_OWNER_ROLE, _msgSender());
	}

	modifier onlyStoargeOwner() {
		require(
			hasRole(STORAGE_OWNER_ROLE, _msgSender()),
			"storage owner only."
		);
		_;
	}

	function isStorageOwner(address account)
		external
		view
		override
		returns (bool)
	{
		return hasRole(STORAGE_OWNER_ROLE, account);
	}

	function addStorageOwner(address _storageOwner)
		external
		override
		onlyAdmin
	{
		grantRole(STORAGE_OWNER_ROLE, _storageOwner);
	}

	function deleteStorageOwner(address _storageOwner)
		external
		override
		onlyAdmin
	{
		revokeRole(STORAGE_OWNER_ROLE, _storageOwner);
	}

	modifier hasStorage() {
		require(_storage != address(0), "storage is not set");
		_;
	}

	function eternalStorage()
		internal
		view
		hasStorage
		returns (EternalStorage)
	{
		return EternalStorage(_storage);
	}

	function getStorageAddress()
		external
		view
		override
		hasStorage
		returns (address)
	{
		return _storage;
	}

	function createStorage() external override onlyStoargeOwner {
		require(_storage == address(0), "storage is set");
		EternalStorage tmp = new EternalStorage();
		_storage = address(tmp);
	}

	function setStorage(address _storageAddress)
		external
		override
		onlyStoargeOwner
	{
		_storage = _storageAddress;
	}

	function changeOwner(address newOwner) external override onlyStoargeOwner {
		EternalStorage(_storage).changeOwner(newOwner);
	}
}



pragma solidity 0.7.6;



contract GitHubMarketIncubatorStorage is UsingStorage {
	function setStartPrice(string memory _githubRepository, uint256 _price)
		internal
	{
		eternalStorage().setUint(getStartPriceKey(_githubRepository), _price);
	}

	function getStartPrice(string memory _githubRepository)
		public
		view
		returns (uint256)
	{
		return eternalStorage().getUint(getStartPriceKey(_githubRepository));
	}

	function getStartPriceKey(string memory _githubRepository)
		private
		pure
		returns (bytes32)
	{
		return keccak256(abi.encodePacked("_startPrice", _githubRepository));
	}

	function setStaking(string memory _githubRepository, uint256 _staking)
		internal
	{
		eternalStorage().setUint(getStakingKey(_githubRepository), _staking);
	}

	function getStaking(string memory _githubRepository)
		public
		view
		returns (uint256)
	{
		return eternalStorage().getUint(getStakingKey(_githubRepository));
	}

	function getStakingKey(string memory _githubRepository)
		private
		pure
		returns (bytes32)
	{
		return keccak256(abi.encodePacked("_staking", _githubRepository));
	}

	function setRewardLimit(
		string memory _githubRepository,
		uint256 _rewardLimit
	) internal {
		eternalStorage().setUint(
			getRewardLimitKey(_githubRepository),
			_rewardLimit
		);
	}

	function getRewardLimit(string memory _githubRepository)
		public
		view
		returns (uint256)
	{
		return eternalStorage().getUint(getRewardLimitKey(_githubRepository));
	}

	function getRewardLimitKey(string memory _githubRepository)
		private
		pure
		returns (bytes32)
	{
		return keccak256(abi.encodePacked(_githubRepository, "_rewardLimit"));
	}

	function setRewardLowerLimit(
		string memory _githubRepository,
		uint256 _rewardLowerLimit
	) internal {
		eternalStorage().setUint(
			getRewardLowerLimitKey(_githubRepository),
			_rewardLowerLimit
		);
	}

	function getRewardLowerLimit(string memory _githubRepository)
		public
		view
		returns (uint256)
	{
		return
			eternalStorage().getUint(getRewardLowerLimitKey(_githubRepository));
	}

	function getRewardLowerLimitKey(string memory _githubRepository)
		private
		pure
		returns (bytes32)
	{
		return
			keccak256(abi.encodePacked(_githubRepository, "_rewardLowerLimit"));
	}

	function setPropertyAddress(
		string memory _githubRepository,
		address _property
	) internal {
		eternalStorage().setAddress(
			getPropertyAddressKey(_githubRepository),
			_property
		);
	}

	function getPropertyAddress(string memory _githubRepository)
		public
		view
		returns (address)
	{
		return
			eternalStorage().getAddress(
				getPropertyAddressKey(_githubRepository)
			);
	}

	function getPropertyAddressKey(string memory _githubRepository)
		private
		pure
		returns (bytes32)
	{
		return
			keccak256(abi.encodePacked("_propertyAddress", _githubRepository));
	}

	function setAccountAddress(address _property, address _account) internal {
		eternalStorage().setAddress(getAccountAddressKey(_property), _account);
	}

	function getAccountAddress(address _property)
		public
		view
		returns (address)
	{
		return eternalStorage().getAddress(getAccountAddressKey(_property));
	}

	function getAccountAddressKey(address _property)
		private
		pure
		returns (bytes32)
	{
		return keccak256(abi.encodePacked("_accountAddress", _property));
	}

	function setMarketAddress(address _market) internal {
		eternalStorage().setAddress(getMarketAddressKey(), _market);
	}

	function getMarketAddress() public view returns (address) {
		return eternalStorage().getAddress(getMarketAddressKey());
	}

	function getMarketAddressKey() private pure returns (bytes32) {
		return keccak256(abi.encodePacked("_marketAddress"));
	}

	function setAddressConfigAddress(address _addressConfig) internal {
		eternalStorage().setAddress(
			getAddressConfigAddressKey(),
			_addressConfig
		);
	}

	function getAddressConfigAddress() public view returns (address) {
		return eternalStorage().getAddress(getAddressConfigAddressKey());
	}

	function getAddressConfigAddressKey() private pure returns (bytes32) {
		return keccak256(abi.encodePacked("_addressConfig"));
	}

	function setPublicSignature(
		string memory _githubRepository,
		string memory _publicSignature
	) internal {
		eternalStorage().setString(
			getPublicSignatureKey(_githubRepository),
			_publicSignature
		);
	}

	function getPublicSignature(string memory _githubRepository)
		public
		view
		returns (string memory)
	{
		return
			eternalStorage().getString(
				getPublicSignatureKey(_githubRepository)
			);
	}

	function getPublicSignatureKey(string memory _githubRepository)
		private
		pure
		returns (bytes32)
	{
		return
			keccak256(abi.encodePacked("_publicSignature", _githubRepository));
	}

	function setCallbackKickerAddress(address _callbackKicker) internal {
		eternalStorage().setAddress(
			getCallbackKickerAddressKey(),
			_callbackKicker
		);
	}

	function getCallbackKickerAddress() public view returns (address) {
		return eternalStorage().getAddress(getCallbackKickerAddressKey());
	}

	function getCallbackKickerAddressKey() private pure returns (bytes32) {
		return keccak256(abi.encodePacked("_callbackKicker"));
	}
}



pragma solidity 0.7.6;













contract GitHubMarketIncubator is GitHubMarketIncubatorStorage {
	using SafeMath for uint256;
	using SafeERC20 for IERC20;

	event Authenticate(
		address indexed _sender,
		address _market,
		address _property,
		string _githubRepository,
		string _publicSignature
	);

	event Finish(
		address indexed _property,
		uint256 _status,
		string _githubRepository,
		uint256 _reword,
		address _account,
		uint256 _staking,
		string _errorMessage
	);

	event Twitter(
		string _githubRepository,
		string _twitterId,
		string _twitterPublicSignature,
		string _githubPublicSignature
	);

	bytes32 public constant OPERATOR_ROLE = keccak256("OPERATOR_ROLE");

	constructor() {
		_setRoleAdmin(OPERATOR_ROLE, DEFAULT_ADMIN_ROLE);
		grantRole(OPERATOR_ROLE, _msgSender());
	}

	modifier onlyOperator {
		require(isOperator(_msgSender()), "operator only.");
		_;
	}

	function isOperator(address account) public view returns (bool) {
		return hasRole(OPERATOR_ROLE, account);
	}

	function addOperator(address _operator) external onlyAdmin {
		grantRole(OPERATOR_ROLE, _operator);
	}

	function deleteOperator(address _operator) external onlyAdmin {
		revokeRole(OPERATOR_ROLE, _operator);
	}

	function start(
		address _property,
		string memory _githubRepository,
		uint256 _staking,
		uint256 _rewardLimit,
		uint256 _rewardLowerLimit
	) external onlyOperator {
		require(_staking != 0, "staking is 0.");
		require(_rewardLimit != 0, "reword limit is 0.");
		require(
			_rewardLowerLimit <= _rewardLimit,
			"limit is less than lower limit."
		);

		uint256 lastPrice = getLastPrice();
		setPropertyAddress(_githubRepository, _property);
		setStartPrice(_githubRepository, lastPrice);
		setStaking(_githubRepository, _staking);
		setRewardLimit(_githubRepository, _rewardLimit);
		setRewardLowerLimit(_githubRepository, _rewardLowerLimit);
	}

	function clearAccountAddress(address _property) external onlyOperator {
		setAccountAddress(_property, address(0));
	}

	function authenticate(
		string memory _githubRepository,
		string memory _publicSignature
	) external {
		address property = getPropertyAddress(_githubRepository);
		require(property != address(0), "illegal user.");
		address account = getAccountAddress(property);
		if (account != address(0)) {
			require(account == _msgSender(), "authentication processed.");
		}
		address market = getMarketAddress();
		bool result =
			IMarket(market).authenticate(
				property,
				_githubRepository,
				_publicSignature,
				"",
				"",
				""
			);
		require(result, "failed to authenticate.");
		setAccountAddress(property, _msgSender());
		setPublicSignature(_githubRepository, _publicSignature);
		emit Authenticate(
			_msgSender(),
			market,
			property,
			_githubRepository,
			_publicSignature
		);
	}

	function intermediateProcess(
		string memory _githubRepository,
		address _metrics,
		string memory _twitterId,
		string memory _twitterPublicSignature
	) external {
		address property = getPropertyAddress(_githubRepository);
		require(property != address(0), "illegal repository.");
		address account = getAccountAddress(property);
		require(account != address(0), "no authenticate yet.");
		require(account == msg.sender, "illegal user.");

		address marketBehavior = IMarket(getMarketAddress()).behavior();
		string memory id = IMarketBehavior(marketBehavior).getId(_metrics);
		require(
			keccak256(abi.encodePacked(id)) ==
				keccak256(abi.encodePacked(_githubRepository)),
			"illegal metrics."
		);
		string memory githubPublicSignatur =
			getPublicSignature(_githubRepository);
		emit Twitter(
			_githubRepository,
			_twitterId,
			_twitterPublicSignature,
			githubPublicSignatur
		);
	}

	function finish(
		string memory _githubRepository,
		uint256 _status,
		string memory _errorMessage
	) external {
		require(msg.sender == getCallbackKickerAddress(), "illegal access.");
		address property = getPropertyAddress(_githubRepository);
		address account = getAccountAddress(property);
		uint256 reword = getReword(_githubRepository);
		require(reword != 0, "reword is 0.");
		uint256 staking = getStaking(_githubRepository);

		if (_status != 0) {
			emit Finish(
				property,
				_status,
				_githubRepository,
				reword,
				account,
				staking,
				_errorMessage
			);
			return;
		}
		address devToken = IAddressConfig(getAddressConfigAddress()).token();
		IERC20 dev = IERC20(devToken);
		dev.safeTransfer(account, reword);

		IProperty(property).changeAuthor(account);
		IERC20 propertyInstance = IERC20(property);
		uint256 balance = propertyInstance.balanceOf(address(this));
		propertyInstance.safeTransfer(account, balance);

		IDev(devToken).deposit(property, staking);
		setStaking(_githubRepository, 0);

		emit Finish(
			property,
			_status,
			_githubRepository,
			reword,
			account,
			staking,
			_errorMessage
		);
	}

	function withdrawLockup(address _property, uint256 _amount)
		external
		onlyOperator
	{
		IAddressConfig addressConfig =
			IAddressConfig(getAddressConfigAddress());
		address lockupAddress = addressConfig.lockup();
		ILockup lockup = ILockup(lockupAddress);
		uint256 tmp =
			lockup.calculateWithdrawableInterestAmount(
				_property,
				address(this)
			);
		lockup.withdraw(_property, _amount);
		ERC20Burnable dev = ERC20Burnable(addressConfig.token());
		dev.burn(tmp);
	}

	function rescue(address _to, uint256 _amount) external onlyAdmin {
		IERC20 dev = IERC20(IAddressConfig(getAddressConfigAddress()).token());
		dev.safeTransfer(_to, _amount);
	}

	function getReword(string memory _githubRepository)
		public
		view
		returns (uint256)
	{
		uint256 latestPrice = getLastPrice();
		uint256 startPrice = getStartPrice(_githubRepository);
		uint256 reword =
			latestPrice.sub(startPrice).mul(getStaking(_githubRepository));
		uint256 rewordLimit = getRewardLimit(_githubRepository);
		if (reword <= rewordLimit) {
			return reword;
		}
		uint256 over = reword.sub(rewordLimit);
		uint256 rewordLowerLimit = getRewardLowerLimit(_githubRepository);
		if (rewordLimit < over) {
			return rewordLowerLimit;
		}
		uint256 tmp = rewordLimit.sub(over);
		return tmp <= rewordLowerLimit ? rewordLowerLimit : tmp;
	}

	function getLastPrice() private view returns (uint256) {
		address lockup = IAddressConfig(getAddressConfigAddress()).lockup();
		(, , uint256 latestPrice) =
			ILockup(lockup).calculateCumulativeRewardPrices();
		return latestPrice;
	}

	function setMarket(address _market) external onlyAdmin {
		require(_market != address(0), "address is 0.");
		setMarketAddress(_market);
	}

	function setAddressConfig(address _addressConfig) external onlyAdmin {
		require(_addressConfig != address(0), "address is 0.");
		setAddressConfigAddress(_addressConfig);
	}

	function setCallbackKicker(address _callbackKicker) external onlyAdmin {
		require(_callbackKicker != address(0), "address is 0.");
		setCallbackKickerAddress(_callbackKicker);
	}
}