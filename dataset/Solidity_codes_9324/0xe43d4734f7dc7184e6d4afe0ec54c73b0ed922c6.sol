

pragma solidity ^0.5.0;

contract Context {

    constructor () internal { }

    function _msgSender() internal view returns (address payable) {

        return msg.sender;
    }

    function _msgData() internal view returns (bytes memory) {

        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}


pragma solidity ^0.5.0;

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


pragma solidity ^0.5.0;

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


pragma solidity ^0.5.0;




contract ERC20 is Context, IERC20 {

    using SafeMath for uint256;

    mapping (address => uint256) private _balances;

    mapping (address => mapping (address => uint256)) private _allowances;

    uint256 private _totalSupply;

    function totalSupply() public view returns (uint256) {

        return _totalSupply;
    }

    function balanceOf(address account) public view returns (uint256) {

        return _balances[account];
    }

    function transfer(address recipient, uint256 amount) public returns (bool) {

        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function allowance(address owner, address spender) public view returns (uint256) {

        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public returns (bool) {

        _approve(_msgSender(), spender, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) public returns (bool) {

        _transfer(sender, recipient, amount);
        _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount, "ERC20: transfer amount exceeds allowance"));
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public returns (bool) {

        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].add(addedValue));
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public returns (bool) {

        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].sub(subtractedValue, "ERC20: decreased allowance below zero"));
        return true;
    }

    function _transfer(address sender, address recipient, uint256 amount) internal {

        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        _balances[sender] = _balances[sender].sub(amount, "ERC20: transfer amount exceeds balance");
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
    }

    function _mint(address account, uint256 amount) internal {

        require(account != address(0), "ERC20: mint to the zero address");

        _totalSupply = _totalSupply.add(amount);
        _balances[account] = _balances[account].add(amount);
        emit Transfer(address(0), account, amount);
    }

    function _burn(address account, uint256 amount) internal {

        require(account != address(0), "ERC20: burn from the zero address");

        _balances[account] = _balances[account].sub(amount, "ERC20: burn amount exceeds balance");
        _totalSupply = _totalSupply.sub(amount);
        emit Transfer(account, address(0), amount);
    }

    function _approve(address owner, address spender, uint256 amount) internal {

        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _burnFrom(address account, uint256 amount) internal {

        _burn(account, amount);
        _approve(account, _msgSender(), _allowances[account][_msgSender()].sub(amount, "ERC20: burn amount exceeds allowance"));
    }
}


pragma solidity ^0.5.0;

library Roles {

    struct Role {
        mapping (address => bool) bearer;
    }

    function add(Role storage role, address account) internal {

        require(!has(role, account), "Roles: account already has role");
        role.bearer[account] = true;
    }

    function remove(Role storage role, address account) internal {

        require(has(role, account), "Roles: account does not have role");
        role.bearer[account] = false;
    }

    function has(Role storage role, address account) internal view returns (bool) {

        require(account != address(0), "Roles: account is the zero address");
        return role.bearer[account];
    }
}


pragma solidity ^0.5.0;



contract MinterRole is Context {

    using Roles for Roles.Role;

    event MinterAdded(address indexed account);
    event MinterRemoved(address indexed account);

    Roles.Role private _minters;

    constructor () internal {
        _addMinter(_msgSender());
    }

    modifier onlyMinter() {

        require(isMinter(_msgSender()), "MinterRole: caller does not have the Minter role");
        _;
    }

    function isMinter(address account) public view returns (bool) {

        return _minters.has(account);
    }

    function addMinter(address account) public onlyMinter {

        _addMinter(account);
    }

    function renounceMinter() public {

        _removeMinter(_msgSender());
    }

    function _addMinter(address account) internal {

        _minters.add(account);
        emit MinterAdded(account);
    }

    function _removeMinter(address account) internal {

        _minters.remove(account);
        emit MinterRemoved(account);
    }
}


pragma solidity ^0.5.0;



contract ERC20Mintable is ERC20, MinterRole {

    function mint(address account, uint256 amount) public onlyMinter returns (bool) {

        _mint(account, amount);
        return true;
    }
}


pragma solidity 0.5.17;


library Decimals {

	using SafeMath for uint256;
	uint120 private constant basisValue = 1000000000000000000;

	function outOf(uint256 _a, uint256 _b)
		internal
		pure
		returns (uint256 result)
	{

		if (_a == 0) {
			return 0;
		}
		uint256 a = _a.mul(basisValue);
		if (a < _b) {
			return 0;
		}
		return (a.div(_b));
	}

	function mulBasis(uint256 _a) internal pure returns (uint256) {

		return _a.mul(basisValue);
	}

	function divBasis(uint256 _a) internal pure returns (uint256) {

		return _a.div(basisValue);
	}
}


pragma solidity 0.5.17;

contract IGroup {

	function isGroup(address _addr) public view returns (bool);


	function addGroup(address _addr) external;


	function getGroupKey(address _addr) internal pure returns (bytes32) {

		return keccak256(abi.encodePacked("_group", _addr));
	}
}


pragma solidity 0.5.17;


contract AddressValidator {

	string constant errorMessage = "this is illegal address";

	function validateIllegalAddress(address _addr) external pure {

		require(_addr != address(0), errorMessage);
	}

	function validateGroup(address _addr, address _groupAddr) external view {

		require(IGroup(_groupAddr).isGroup(_addr), errorMessage);
	}

	function validateGroups(
		address _addr,
		address _groupAddr1,
		address _groupAddr2
	) external view {

		if (IGroup(_groupAddr1).isGroup(_addr)) {
			return;
		}
		require(IGroup(_groupAddr2).isGroup(_addr), errorMessage);
	}

	function validateAddress(address _addr, address _target) external pure {

		require(_addr == _target, errorMessage);
	}

	function validateAddresses(
		address _addr,
		address _target1,
		address _target2
	) external pure {

		if (_addr == _target1) {
			return;
		}
		require(_addr == _target2, errorMessage);
	}

	function validate3Addresses(
		address _addr,
		address _target1,
		address _target2,
		address _target3
	) external pure {

		if (_addr == _target1) {
			return;
		}
		if (_addr == _target2) {
			return;
		}
		require(_addr == _target3, errorMessage);
	}
}


pragma solidity 0.5.17;



contract UsingValidator {

	AddressValidator private _validator;

	constructor() public {
		_validator = new AddressValidator();
	}

	function addressValidator() internal view returns (AddressValidator) {

		return _validator;
	}
}


pragma solidity 0.5.17;

contract IProperty {

	function author() external view returns (address);


	function withdraw(address _sender, uint256 _value) external;

}


pragma solidity 0.5.17;

contract Killable {

	address payable public _owner;

	constructor() internal {
		_owner = msg.sender;
	}

	function kill() public {

		require(msg.sender == _owner, "only owner method");
		selfdestruct(_owner);
	}
}


pragma solidity ^0.5.0;

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

        require(isOwner(), "Ownable: caller is not the owner");
        _;
    }

    function isOwner() public view returns (bool) {

        return _msgSender() == _owner;
    }

    function renounceOwnership() public onlyOwner {

        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    function transferOwnership(address newOwner) public onlyOwner {

        _transferOwnership(newOwner);
    }

    function _transferOwnership(address newOwner) internal {

        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}


pragma solidity 0.5.17;




contract AddressConfig is Ownable, UsingValidator, Killable {

	address public token = 0x98626E2C9231f03504273d55f397409deFD4a093;
	address public allocator;
	address public allocatorStorage;
	address public withdraw;
	address public withdrawStorage;
	address public marketFactory;
	address public marketGroup;
	address public propertyFactory;
	address public propertyGroup;
	address public metricsGroup;
	address public metricsFactory;
	address public policy;
	address public policyFactory;
	address public policySet;
	address public policyGroup;
	address public lockup;
	address public lockupStorage;
	address public voteTimes;
	address public voteTimesStorage;
	address public voteCounter;
	address public voteCounterStorage;

	function setAllocator(address _addr) external onlyOwner {

		allocator = _addr;
	}

	function setAllocatorStorage(address _addr) external onlyOwner {

		allocatorStorage = _addr;
	}

	function setWithdraw(address _addr) external onlyOwner {

		withdraw = _addr;
	}

	function setWithdrawStorage(address _addr) external onlyOwner {

		withdrawStorage = _addr;
	}

	function setMarketFactory(address _addr) external onlyOwner {

		marketFactory = _addr;
	}

	function setMarketGroup(address _addr) external onlyOwner {

		marketGroup = _addr;
	}

	function setPropertyFactory(address _addr) external onlyOwner {

		propertyFactory = _addr;
	}

	function setPropertyGroup(address _addr) external onlyOwner {

		propertyGroup = _addr;
	}

	function setMetricsFactory(address _addr) external onlyOwner {

		metricsFactory = _addr;
	}

	function setMetricsGroup(address _addr) external onlyOwner {

		metricsGroup = _addr;
	}

	function setPolicyFactory(address _addr) external onlyOwner {

		policyFactory = _addr;
	}

	function setPolicyGroup(address _addr) external onlyOwner {

		policyGroup = _addr;
	}

	function setPolicySet(address _addr) external onlyOwner {

		policySet = _addr;
	}

	function setPolicy(address _addr) external {

		addressValidator().validateAddress(msg.sender, policyFactory);
		policy = _addr;
	}

	function setToken(address _addr) external onlyOwner {

		token = _addr;
	}

	function setLockup(address _addr) external onlyOwner {

		lockup = _addr;
	}

	function setLockupStorage(address _addr) external onlyOwner {

		lockupStorage = _addr;
	}

	function setVoteTimes(address _addr) external onlyOwner {

		voteTimes = _addr;
	}

	function setVoteTimesStorage(address _addr) external onlyOwner {

		voteTimesStorage = _addr;
	}

	function setVoteCounter(address _addr) external onlyOwner {

		voteCounter = _addr;
	}

	function setVoteCounterStorage(address _addr) external onlyOwner {

		voteCounterStorage = _addr;
	}
}


pragma solidity 0.5.17;


contract UsingConfig {

	AddressConfig private _config;

	constructor(address _addressConfig) public {
		_config = AddressConfig(_addressConfig);
	}

	function config() internal view returns (AddressConfig) {

		return _config;
	}

	function configAddress() external view returns (address) {

		return address(_config);
	}
}


pragma solidity 0.5.17;

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


pragma solidity 0.5.17;



contract UsingStorage is Ownable {

	address private _storage;

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

	function getStorageAddress() external view hasStorage returns (address) {

		return _storage;
	}

	function createStorage() external onlyOwner {

		require(_storage == address(0), "storage is set");
		EternalStorage tmp = new EternalStorage();
		_storage = address(tmp);
	}

	function setStorage(address _storageAddress) external onlyOwner {

		_storage = _storageAddress;
	}

	function changeOwner(address newOwner) external onlyOwner {

		EternalStorage(_storage).changeOwner(newOwner);
	}
}


pragma solidity 0.5.17;



contract LockupStorage is UsingStorage {

	using SafeMath for uint256;

	uint256 public constant basis = 100000000000000000000000000000000;

	function setStorageAllValue(uint256 _value) internal {

		bytes32 key = getStorageAllValueKey();
		eternalStorage().setUint(key, _value);
	}

	function getStorageAllValue() public view returns (uint256) {

		bytes32 key = getStorageAllValueKey();
		return eternalStorage().getUint(key);
	}

	function getStorageAllValueKey() private pure returns (bytes32) {

		return keccak256(abi.encodePacked("_allValue"));
	}

	function setStorageValue(
		address _property,
		address _sender,
		uint256 _value
	) internal {

		bytes32 key = getStorageValueKey(_property, _sender);
		eternalStorage().setUint(key, _value);
	}

	function getStorageValue(address _property, address _sender)
		public
		view
		returns (uint256)
	{

		bytes32 key = getStorageValueKey(_property, _sender);
		return eternalStorage().getUint(key);
	}

	function getStorageValueKey(address _property, address _sender)
		private
		pure
		returns (bytes32)
	{

		return keccak256(abi.encodePacked("_value", _property, _sender));
	}

	function setStoragePropertyValue(address _property, uint256 _value)
		internal
	{

		bytes32 key = getStoragePropertyValueKey(_property);
		eternalStorage().setUint(key, _value);
	}

	function getStoragePropertyValue(address _property)
		public
		view
		returns (uint256)
	{

		bytes32 key = getStoragePropertyValueKey(_property);
		return eternalStorage().getUint(key);
	}

	function getStoragePropertyValueKey(address _property)
		private
		pure
		returns (bytes32)
	{

		return keccak256(abi.encodePacked("_propertyValue", _property));
	}

	function setStorageWithdrawalStatus(
		address _property,
		address _from,
		uint256 _value
	) internal {

		bytes32 key = getStorageWithdrawalStatusKey(_property, _from);
		eternalStorage().setUint(key, _value);
	}

	function getStorageWithdrawalStatus(address _property, address _from)
		public
		view
		returns (uint256)
	{

		bytes32 key = getStorageWithdrawalStatusKey(_property, _from);
		return eternalStorage().getUint(key);
	}

	function getStorageWithdrawalStatusKey(address _property, address _sender)
		private
		pure
		returns (bytes32)
	{

		return
			keccak256(
				abi.encodePacked("_withdrawalStatus", _property, _sender)
			);
	}

	function setStorageInterestPrice(address _property, uint256 _value)
		internal
	{

		eternalStorage().setUint(getStorageInterestPriceKey(_property), _value);
	}

	function getStorageInterestPrice(address _property)
		public
		view
		returns (uint256)
	{

		return eternalStorage().getUint(getStorageInterestPriceKey(_property));
	}

	function getStorageInterestPriceKey(address _property)
		private
		pure
		returns (bytes32)
	{

		return keccak256(abi.encodePacked("_interestTotals", _property));
	}

	function setStorageLastInterestPrice(
		address _property,
		address _user,
		uint256 _value
	) internal {

		eternalStorage().setUint(
			getStorageLastInterestPriceKey(_property, _user),
			_value
		);
	}

	function getStorageLastInterestPrice(address _property, address _user)
		public
		view
		returns (uint256)
	{

		return
			eternalStorage().getUint(
				getStorageLastInterestPriceKey(_property, _user)
			);
	}

	function getStorageLastInterestPriceKey(address _property, address _user)
		private
		pure
		returns (bytes32)
	{

		return
			keccak256(
				abi.encodePacked("_lastLastInterestPrice", _property, _user)
			);
	}

	function setStorageLastSameRewardsAmountAndBlock(
		uint256 _amount,
		uint256 _block
	) internal {

		uint256 record = _amount.mul(basis).add(_block);
		eternalStorage().setUint(
			getStorageLastSameRewardsAmountAndBlockKey(),
			record
		);
	}

	function getStorageLastSameRewardsAmountAndBlock()
		public
		view
		returns (uint256 _amount, uint256 _block)
	{

		uint256 record = eternalStorage().getUint(
			getStorageLastSameRewardsAmountAndBlockKey()
		);
		uint256 amount = record.div(basis);
		uint256 blockNumber = record.sub(amount.mul(basis));
		return (amount, blockNumber);
	}

	function getStorageLastSameRewardsAmountAndBlockKey()
		private
		pure
		returns (bytes32)
	{

		return keccak256(abi.encodePacked("_LastSameRewardsAmountAndBlock"));
	}

	function setStorageCumulativeGlobalRewards(uint256 _value) internal {

		eternalStorage().setUint(
			getStorageCumulativeGlobalRewardsKey(),
			_value
		);
	}

	function getStorageCumulativeGlobalRewards() public view returns (uint256) {

		return eternalStorage().getUint(getStorageCumulativeGlobalRewardsKey());
	}

	function getStorageCumulativeGlobalRewardsKey()
		private
		pure
		returns (bytes32)
	{

		return keccak256(abi.encodePacked("_cumulativeGlobalRewards"));
	}

	function setStorageLastCumulativeGlobalReward(
		address _property,
		address _user,
		uint256 _value
	) internal {

		eternalStorage().setUint(
			getStorageLastCumulativeGlobalRewardKey(_property, _user),
			_value
		);
	}

	function getStorageLastCumulativeGlobalReward(
		address _property,
		address _user
	) public view returns (uint256) {

		return
			eternalStorage().getUint(
				getStorageLastCumulativeGlobalRewardKey(_property, _user)
			);
	}

	function getStorageLastCumulativeGlobalRewardKey(
		address _property,
		address _user
	) private pure returns (bytes32) {

		return
			keccak256(
				abi.encodePacked(
					"_LastCumulativeGlobalReward",
					_property,
					_user
				)
			);
	}

	function setStorageLastCumulativePropertyInterest(
		address _property,
		address _user,
		uint256 _value
	) internal {

		eternalStorage().setUint(
			getStorageLastCumulativePropertyInterestKey(_property, _user),
			_value
		);
	}

	function getStorageLastCumulativePropertyInterest(
		address _property,
		address _user
	) public view returns (uint256) {

		return
			eternalStorage().getUint(
				getStorageLastCumulativePropertyInterestKey(_property, _user)
			);
	}

	function getStorageLastCumulativePropertyInterestKey(
		address _property,
		address _user
	) private pure returns (bytes32) {

		return
			keccak256(
				abi.encodePacked(
					"_lastCumulativePropertyInterest",
					_property,
					_user
				)
			);
	}

	function setStorageCumulativeLockedUpUnitAndBlock(
		address _addr,
		uint256 _unit,
		uint256 _block
	) internal {

		uint256 record = _unit.mul(basis).add(_block);
		eternalStorage().setUint(
			getStorageCumulativeLockedUpUnitAndBlockKey(_addr),
			record
		);
	}

	function getStorageCumulativeLockedUpUnitAndBlock(address _addr)
		public
		view
		returns (uint256 _unit, uint256 _block)
	{

		uint256 record = eternalStorage().getUint(
			getStorageCumulativeLockedUpUnitAndBlockKey(_addr)
		);
		uint256 unit = record.div(basis);
		uint256 blockNumber = record.sub(unit.mul(basis));
		return (unit, blockNumber);
	}

	function getStorageCumulativeLockedUpUnitAndBlockKey(address _addr)
		private
		pure
		returns (bytes32)
	{

		return
			keccak256(
				abi.encodePacked("_cumulativeLockedUpUnitAndBlock", _addr)
			);
	}

	function setStorageCumulativeLockedUpValue(address _addr, uint256 _value)
		internal
	{

		eternalStorage().setUint(
			getStorageCumulativeLockedUpValueKey(_addr),
			_value
		);
	}

	function getStorageCumulativeLockedUpValue(address _addr)
		public
		view
		returns (uint256)
	{

		return
			eternalStorage().getUint(
				getStorageCumulativeLockedUpValueKey(_addr)
			);
	}

	function getStorageCumulativeLockedUpValueKey(address _addr)
		private
		pure
		returns (bytes32)
	{

		return keccak256(abi.encodePacked("_cumulativeLockedUpValue", _addr));
	}

	function setStoragePendingInterestWithdrawal(
		address _property,
		address _user,
		uint256 _value
	) internal {

		eternalStorage().setUint(
			getStoragePendingInterestWithdrawalKey(_property, _user),
			_value
		);
	}

	function getStoragePendingInterestWithdrawal(
		address _property,
		address _user
	) public view returns (uint256) {

		return
			eternalStorage().getUint(
				getStoragePendingInterestWithdrawalKey(_property, _user)
			);
	}

	function getStoragePendingInterestWithdrawalKey(
		address _property,
		address _user
	) private pure returns (bytes32) {

		return
			keccak256(
				abi.encodePacked("_pendingInterestWithdrawal", _property, _user)
			);
	}

	function setStorageDIP4GenesisBlock(uint256 _block) internal {

		eternalStorage().setUint(getStorageDIP4GenesisBlockKey(), _block);
	}

	function getStorageDIP4GenesisBlock() public view returns (uint256) {

		return eternalStorage().getUint(getStorageDIP4GenesisBlockKey());
	}

	function getStorageDIP4GenesisBlockKey() private pure returns (bytes32) {

		return keccak256(abi.encodePacked("_dip4GenesisBlock"));
	}

	function setStorageLastCumulativeLockedUpAndBlock(
		address _property,
		address _user,
		uint256 _cLocked,
		uint256 _block
	) internal {

		uint256 record = _cLocked.mul(basis).add(_block);
		eternalStorage().setUint(
			getStorageLastCumulativeLockedUpAndBlockKey(_property, _user),
			record
		);
	}

	function getStorageLastCumulativeLockedUpAndBlock(
		address _property,
		address _user
	) public view returns (uint256 _cLocked, uint256 _block) {

		uint256 record = eternalStorage().getUint(
			getStorageLastCumulativeLockedUpAndBlockKey(_property, _user)
		);
		uint256 cLocked = record.div(basis);
		uint256 blockNumber = record.sub(cLocked.mul(basis));

		return (cLocked, blockNumber);
	}

	function getStorageLastCumulativeLockedUpAndBlockKey(
		address _property,
		address _user
	) private pure returns (bytes32) {

		return
			keccak256(
				abi.encodePacked(
					"_lastCumulativeLockedUpAndBlock",
					_property,
					_user
				)
			);
	}

	function setStorageLastStakedInterestPrice(
		address _property,
		address _user,
		uint256 _value
	) internal {

		eternalStorage().setUint(
			getStorageLastStakedInterestPriceKey(_property, _user),
			_value
		);
	}

	function getStorageLastStakedInterestPrice(address _property, address _user)
		public
		view
		returns (uint256)
	{

		return
			eternalStorage().getUint(
				getStorageLastStakedInterestPriceKey(_property, _user)
			);
	}

	function getStorageLastStakedInterestPriceKey(
		address _property,
		address _user
	) private pure returns (bytes32) {

		return
			keccak256(
				abi.encodePacked("_lastStakedInterestPrice", _property, _user)
			);
	}

	function setStorageLastStakesChangedCumulativeReward(uint256 _value)
		internal
	{

		eternalStorage().setUint(
			getStorageLastStakesChangedCumulativeRewardKey(),
			_value
		);
	}

	function getStorageLastStakesChangedCumulativeReward()
		public
		view
		returns (uint256)
	{

		return
			eternalStorage().getUint(
				getStorageLastStakesChangedCumulativeRewardKey()
			);
	}

	function getStorageLastStakesChangedCumulativeRewardKey()
		private
		pure
		returns (bytes32)
	{

		return
			keccak256(abi.encodePacked("_lastStakesChangedCumulativeReward"));
	}

	function setStorageLastCumulativeHoldersRewardPrice(uint256 _holders)
		internal
	{

		eternalStorage().setUint(
			getStorageLastCumulativeHoldersRewardPriceKey(),
			_holders
		);
	}

	function getStorageLastCumulativeHoldersRewardPrice()
		public
		view
		returns (uint256)
	{

		return
			eternalStorage().getUint(
				getStorageLastCumulativeHoldersRewardPriceKey()
			);
	}

	function getStorageLastCumulativeHoldersRewardPriceKey()
		private
		pure
		returns (bytes32)
	{

		return keccak256(abi.encodePacked("0lastCumulativeHoldersRewardPrice"));
	}

	function setStorageLastCumulativeInterestPrice(uint256 _interest) internal {

		eternalStorage().setUint(
			getStorageLastCumulativeInterestPriceKey(),
			_interest
		);
	}

	function getStorageLastCumulativeInterestPrice()
		public
		view
		returns (uint256)
	{

		return
			eternalStorage().getUint(
				getStorageLastCumulativeInterestPriceKey()
			);
	}

	function getStorageLastCumulativeInterestPriceKey()
		private
		pure
		returns (bytes32)
	{

		return keccak256(abi.encodePacked("0lastCumulativeInterestPrice"));
	}

	function setStorageLastCumulativeHoldersRewardAmountPerProperty(
		address _property,
		uint256 _value
	) internal {

		eternalStorage().setUint(
			getStorageLastCumulativeHoldersRewardAmountPerPropertyKey(
				_property
			),
			_value
		);
	}

	function getStorageLastCumulativeHoldersRewardAmountPerProperty(
		address _property
	) public view returns (uint256) {

		return
			eternalStorage().getUint(
				getStorageLastCumulativeHoldersRewardAmountPerPropertyKey(
					_property
				)
			);
	}

	function getStorageLastCumulativeHoldersRewardAmountPerPropertyKey(
		address _property
	) private pure returns (bytes32) {

		return
			keccak256(
				abi.encodePacked(
					"0lastCumulativeHoldersRewardAmountPerProperty",
					_property
				)
			);
	}

	function setStorageLastCumulativeHoldersRewardPricePerProperty(
		address _property,
		uint256 _price
	) internal {

		eternalStorage().setUint(
			getStorageLastCumulativeHoldersRewardPricePerPropertyKey(_property),
			_price
		);
	}

	function getStorageLastCumulativeHoldersRewardPricePerProperty(
		address _property
	) public view returns (uint256) {

		return
			eternalStorage().getUint(
				getStorageLastCumulativeHoldersRewardPricePerPropertyKey(
					_property
				)
			);
	}

	function getStorageLastCumulativeHoldersRewardPricePerPropertyKey(
		address _property
	) private pure returns (bytes32) {

		return
			keccak256(
				abi.encodePacked(
					"0lastCumulativeHoldersRewardPricePerProperty",
					_property
				)
			);
	}
}


pragma solidity 0.5.17;

contract IPolicy {

	function rewards(uint256 _lockups, uint256 _assets)
		external
		view
		returns (uint256);


	function holdersShare(uint256 _amount, uint256 _lockups)
		external
		view
		returns (uint256);


	function assetValue(uint256 _value, uint256 _lockups)
		external
		view
		returns (uint256);


	function authenticationFee(uint256 _assets, uint256 _propertyAssets)
		external
		view
		returns (uint256);


	function marketApproval(uint256 _agree, uint256 _opposite)
		external
		view
		returns (bool);


	function policyApproval(uint256 _agree, uint256 _opposite)
		external
		view
		returns (bool);


	function marketVotingBlocks() external view returns (uint256);


	function policyVotingBlocks() external view returns (uint256);


	function abstentionPenalty(uint256 _count) external view returns (uint256);


	function lockUpBlocks() external view returns (uint256);

}


pragma solidity 0.5.17;

contract IAllocator {

	function calculateMaxRewardsPerBlock() public view returns (uint256);


	function beforeBalanceChange(
		address _property,
		address _from,
		address _to
	) external;

}


pragma solidity 0.5.17;

contract ILegacyLockup {

	function lockup(
		address _from,
		address _property,
		uint256 _value
	) external;


	function update() public;


	function cancel(address _property) external;


	function withdraw(address _property) external;


	function difference(address _property, uint256 _lastReward)
		public
		view
		returns (
			uint256 _reward,
			uint256 _holdersAmount,
			uint256 _holdersPrice,
			uint256 _interestAmount,
			uint256 _interestPrice
		);


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
	)
		public
		view
		returns (
			uint256
		);


	function withdrawInterest(address _property) external;

}


pragma solidity 0.5.17;


contract IMetricsGroup is IGroup {

	function removeGroup(address _addr) external;


	function totalIssuedMetrics() external view returns (uint256);


	function getMetricsCountPerProperty(address _property)
		public
		view
		returns (uint256);


	function hasAssets(address _property) public view returns (bool);

}


pragma solidity 0.5.17;













contract LegacyLockup is
	ILegacyLockup,
	UsingConfig,
	UsingValidator,
	LockupStorage
{

	using SafeMath for uint256;
	using Decimals for uint256;
	event Lockedup(address _from, address _property, uint256 _value);

	constructor(address _config) public UsingConfig(_config) {}

	function lockup(
		address _from,
		address _property,
		uint256 _value
	) external {

		addressValidator().validateAddress(msg.sender, config().token());

		require(_value != 0, "illegal lockup value");

		require(
			IMetricsGroup(config().metricsGroup()).hasAssets(_property),
			"unable to stake to unauthenticated property"
		);

		bool isWaiting = getStorageWithdrawalStatus(_property, _from) != 0;
		require(isWaiting == false, "lockup is already canceled");

		updatePendingInterestWithdrawal(_property, _from);

		(, , , uint256 interest, ) = difference(_property, 0);
		updateStatesAtLockup(_property, _from, interest);

		updateValues(true, _from, _property, _value);
		emit Lockedup(_from, _property, _value);
	}

	function cancel(address _property) external {

		addressValidator().validateGroup(_property, config().propertyGroup());

		require(hasValue(_property, msg.sender), "dev token is not locked");

		bool isWaiting = getStorageWithdrawalStatus(_property, msg.sender) != 0;
		require(isWaiting == false, "lockup is already canceled");

		uint256 blockNumber = IPolicy(config().policy()).lockUpBlocks();
		blockNumber = blockNumber.add(block.number);
		setStorageWithdrawalStatus(_property, msg.sender, blockNumber);
	}

	function withdraw(address _property) external {

		addressValidator().validateGroup(_property, config().propertyGroup());

		require(possible(_property, msg.sender), "waiting for release");

		uint256 lockedUpValue = getStorageValue(_property, msg.sender);
		require(lockedUpValue != 0, "dev token is not locked");

		updatePendingInterestWithdrawal(_property, msg.sender);

		IProperty(_property).withdraw(msg.sender, lockedUpValue);

		updateValues(false, msg.sender, _property, lockedUpValue);

		setStorageValue(_property, msg.sender, 0);

		setStorageWithdrawalStatus(_property, msg.sender, 0);
	}

	function getCumulativeLockedUpUnitAndBlock(address _property)
		private
		view
		returns (uint256 _unit, uint256 _block)
	{

		(
			uint256 unit,
			uint256 lastBlock
		) = getStorageCumulativeLockedUpUnitAndBlock(_property);
		if (lastBlock > 0) {
			return (unit, lastBlock);
		}

		unit = _property == address(0)
			? getStorageAllValue()
			: getStoragePropertyValue(_property);

		lastBlock = getStorageDIP4GenesisBlock();
		return (unit, lastBlock);
	}

	function getCumulativeLockedUp(address _property)
		public
		view
		returns (
			uint256 _value,
			uint256 _unit,
			uint256 _block
		)
	{

		(uint256 unit, uint256 lastBlock) = getCumulativeLockedUpUnitAndBlock(
			_property
		);

		uint256 lastValue = getStorageCumulativeLockedUpValue(_property);

		return (
			lastValue.add(unit.mul(block.number.sub(lastBlock))),
			unit,
			lastBlock
		);
	}

	function getCumulativeLockedUpAll()
		public
		view
		returns (
			uint256 _value,
			uint256 _unit,
			uint256 _block
		)
	{

		return getCumulativeLockedUp(address(0));
	}

	function updateCumulativeLockedUp(
		bool _addition,
		address _property,
		uint256 _unit
	) private {

		address zero = address(0);

		(uint256 lastValue, uint256 lastUnit, ) = getCumulativeLockedUp(
			_property
		);

		(uint256 lastValueAll, uint256 lastUnitAll, ) = getCumulativeLockedUp(
			zero
		);

		setStorageCumulativeLockedUpValue(
			_property,
			_addition ? lastValue.add(_unit) : lastValue.sub(_unit)
		);

		setStorageCumulativeLockedUpValue(
			zero,
			_addition ? lastValueAll.add(_unit) : lastValueAll.sub(_unit)
		);

		setStorageCumulativeLockedUpUnitAndBlock(
			_property,
			_addition ? lastUnit.add(_unit) : lastUnit.sub(_unit),
			block.number
		);

		setStorageCumulativeLockedUpUnitAndBlock(
			zero,
			_addition ? lastUnitAll.add(_unit) : lastUnitAll.sub(_unit),
			block.number
		);
	}

	function update() public {

		(uint256 _nextRewards, uint256 _amount) = dry();

		setStorageCumulativeGlobalRewards(_nextRewards);
		setStorageLastSameRewardsAmountAndBlock(_amount, block.number);
	}

	function updateStatesAtLockup(
		address _property,
		address _user,
		uint256 _interest
	) private {

		(uint256 _reward, ) = dry();

		if (isSingle(_property, _user)) {
			setStorageLastCumulativeGlobalReward(_property, _user, _reward);
		}
		setStorageLastCumulativePropertyInterest(_property, _user, _interest);
		(uint256 cLocked, , ) = getCumulativeLockedUp(_property);
		setStorageLastCumulativeLockedUpAndBlock(
			_property,
			_user,
			cLocked,
			block.number
		);
	}

	function getLastCumulativeLockedUpAndBlock(address _property, address _user)
		private
		view
		returns (uint256 _cLocked, uint256 _block)
	{

		(
			uint256 cLocked,
			uint256 blockNumber
		) = getStorageLastCumulativeLockedUpAndBlock(_property, _user);

		if (blockNumber == 0) {
			blockNumber = getStorageDIP4GenesisBlock();
		}
		return (cLocked, blockNumber);
	}

	function dry()
		private
		view
		returns (uint256 _nextRewards, uint256 _amount)
	{

		uint256 rewardsAmount = IAllocator(config().allocator())
			.calculateMaxRewardsPerBlock();

		(
			uint256 lastAmount,
			uint256 lastBlock
		) = getStorageLastSameRewardsAmountAndBlock();

		uint256 lastMaxRewards = lastAmount == rewardsAmount
			? rewardsAmount
			: lastAmount;

		uint256 blocks = lastBlock > 0 ? block.number.sub(lastBlock) : 0;

		uint256 additionalRewards = lastMaxRewards.mul(blocks);
		uint256 nextRewards = getStorageCumulativeGlobalRewards().add(
			additionalRewards
		);

		return (nextRewards, rewardsAmount);
	}

	function difference(address _property, uint256 _lastReward)
		public
		view
		returns (
			uint256 _reward,
			uint256 _holdersAmount,
			uint256 _holdersPrice,
			uint256 _interestAmount,
			uint256 _interestPrice
		)
	{

		(uint256 rewards, ) = dry();

		(uint256 valuePerProperty, , ) = getCumulativeLockedUp(_property);
		(uint256 valueAll, , ) = getCumulativeLockedUpAll();

		uint256 propertyRewards = rewards.sub(_lastReward).mul(
			valuePerProperty.mulBasis().outOf(valueAll)
		);

		uint256 lockedUpPerProperty = getStoragePropertyValue(_property);
		uint256 totalSupply = ERC20Mintable(_property).totalSupply();
		uint256 holders = IPolicy(config().policy()).holdersShare(
			propertyRewards,
			lockedUpPerProperty
		);

		uint256 interest = propertyRewards.sub(holders);

		return (
			rewards,
			holders,
			holders.div(totalSupply),
			interest,
			lockedUpPerProperty > 0 ? interest.div(lockedUpPerProperty) : 0
		);
	}

	function _calculateInterestAmount(address _property, address _user)
		private
		view
		returns (uint256)
	{

		(
			uint256 cLockProperty,
			uint256 unit,
			uint256 lastBlock
		) = getCumulativeLockedUp(_property);

		(
			uint256 lastCLocked,
			uint256 lastBlockUser
		) = getLastCumulativeLockedUpAndBlock(_property, _user);

		uint256 lockedUpPerAccount = getStorageValue(_property, _user);

		uint256 lastInterest = getStorageLastCumulativePropertyInterest(
			_property,
			_user
		);

		uint256 cLockUser = lockedUpPerAccount.mul(
			block.number.sub(lastBlockUser)
		);

		bool isOnly = unit == lockedUpPerAccount && lastBlock <= lastBlockUser;

		if (isSingle(_property, _user)) {
			(, , , , uint256 interestPrice) = difference(
				_property,
				getStorageLastCumulativeGlobalReward(_property, _user)
			);

			uint256 result = interestPrice
				.mul(lockedUpPerAccount)
				.divBasis()
				.divBasis();
			return result;

		} else if (isOnly) {
			(, , , uint256 interest, ) = difference(_property, 0);

			uint256 result = interest >= lastInterest
				? interest.sub(lastInterest).divBasis().divBasis()
				: 0;
			return result;
		}


		(, , , uint256 interest, ) = difference(_property, 0);

		uint256 share = cLockUser.outOf(cLockProperty.sub(lastCLocked));

		uint256 result = interest >= lastInterest
			? interest
				.sub(lastInterest)
				.mul(share)
				.divBasis()
				.divBasis()
				.divBasis()
			: 0;
		return result;
	}

	function _calculateWithdrawableInterestAmount(
		address _property,
		address _user
	) private view returns (uint256) {

		if (
			IMetricsGroup(config().metricsGroup()).hasAssets(_property) == false
		) {
			return 0;
		}

		uint256 pending = getStoragePendingInterestWithdrawal(_property, _user);

		uint256 legacy = __legacyWithdrawableInterestAmount(_property, _user);

		uint256 amount = _calculateInterestAmount(_property, _user);

		uint256 withdrawableAmount = amount
			.add(pending) // solium-disable-next-line indentation
			.add(legacy);
		return withdrawableAmount;
	}

	function calculateWithdrawableInterestAmount(
		address _property,
		address _user
	) public view returns (uint256) {

		uint256 amount = _calculateWithdrawableInterestAmount(_property, _user);
		return amount;
	}

	function withdrawInterest(address _property) external {

		addressValidator().validateGroup(_property, config().propertyGroup());

		uint256 value = _calculateWithdrawableInterestAmount(
			_property,
			msg.sender
		);

		(, , , uint256 interest, ) = difference(_property, 0);

		require(value > 0, "your interest amount is 0");

		setStoragePendingInterestWithdrawal(_property, msg.sender, 0);

		ERC20Mintable erc20 = ERC20Mintable(config().token());

		updateStatesAtLockup(_property, msg.sender, interest);
		__updateLegacyWithdrawableInterestAmount(_property, msg.sender);

		require(erc20.mint(msg.sender, value), "dev mint failed");

		update();
	}

	function updateValues(
		bool _addition,
		address _account,
		address _property,
		uint256 _value
	) private {

		if (_addition) {
			updateCumulativeLockedUp(true, _property, _value);

			addAllValue(_value);

			addPropertyValue(_property, _value);

			addValue(_property, _account, _value);

		} else {
			updateCumulativeLockedUp(false, _property, _value);

			subAllValue(_value);

			subPropertyValue(_property, _value);
		}

		update();
	}

	function getAllValue() external view returns (uint256) {

		return getStorageAllValue();
	}

	function addAllValue(uint256 _value) private {

		uint256 value = getStorageAllValue();
		value = value.add(_value);
		setStorageAllValue(value);
	}

	function subAllValue(uint256 _value) private {

		uint256 value = getStorageAllValue();
		value = value.sub(_value);
		setStorageAllValue(value);
	}

	function getValue(address _property, address _sender)
		external
		view
		returns (uint256)
	{

		return getStorageValue(_property, _sender);
	}

	function addValue(
		address _property,
		address _sender,
		uint256 _value
	) private {

		uint256 value = getStorageValue(_property, _sender);
		value = value.add(_value);
		setStorageValue(_property, _sender, value);
	}

	function hasValue(address _property, address _sender)
		private
		view
		returns (bool)
	{

		uint256 value = getStorageValue(_property, _sender);
		return value != 0;
	}

	function isSingle(address _property, address _user)
		private
		view
		returns (bool)
	{

		uint256 perAccount = getStorageValue(_property, _user);
		(uint256 cLockProperty, uint256 unitProperty, ) = getCumulativeLockedUp(
			_property
		);
		(uint256 cLockTotal, , ) = getCumulativeLockedUpAll();
		return perAccount == unitProperty && cLockProperty == cLockTotal;
	}

	function getPropertyValue(address _property)
		external
		view
		returns (uint256)
	{

		return getStoragePropertyValue(_property);
	}

	function addPropertyValue(address _property, uint256 _value) private {

		uint256 value = getStoragePropertyValue(_property);
		value = value.add(_value);
		setStoragePropertyValue(_property, value);
	}

	function subPropertyValue(address _property, uint256 _value) private {

		uint256 value = getStoragePropertyValue(_property);
		uint256 nextValue = value.sub(_value);
		setStoragePropertyValue(_property, nextValue);
	}

	function updatePendingInterestWithdrawal(address _property, address _user)
		private
	{

		uint256 withdrawableAmount = _calculateWithdrawableInterestAmount(
			_property,
			_user
		);

		setStoragePendingInterestWithdrawal(
			_property,
			_user,
			withdrawableAmount
		);

		__updateLegacyWithdrawableInterestAmount(_property, _user);
	}

	function possible(address _property, address _from)
		private
		view
		returns (bool)
	{

		uint256 blockNumber = getStorageWithdrawalStatus(_property, _from);
		if (blockNumber == 0) {
			return false;
		}
		if (blockNumber <= block.number) {
			return true;
		} else {
			if (IPolicy(config().policy()).lockUpBlocks() == 1) {
				return true;
			}
		}
		return false;
	}

	function __legacyWithdrawableInterestAmount(
		address _property,
		address _user
	) private view returns (uint256) {

		uint256 _last = getStorageLastInterestPrice(_property, _user);
		uint256 price = getStorageInterestPrice(_property);
		uint256 priceGap = price.sub(_last);
		uint256 lockedUpValue = getStorageValue(_property, _user);
		uint256 value = priceGap.mul(lockedUpValue);
		return value.divBasis();
	}

	function __updateLegacyWithdrawableInterestAmount(
		address _property,
		address _user
	) private {

		uint256 interestPrice = getStorageInterestPrice(_property);
		if (getStorageLastInterestPrice(_property, _user) != interestPrice) {
			setStorageLastInterestPrice(_property, _user, interestPrice);
		}
	}

	function setDIP4GenesisBlock(uint256 _block) external onlyOwner {

		require(getStorageDIP4GenesisBlock() == 0, "already set the value");

		setStorageDIP4GenesisBlock(_block);
	}
}


pragma solidity 0.5.17;


contract MigrateLockup is LegacyLockup {

	constructor(address _config) public LegacyLockup(_config) {}

	function __initStakeOnProperty(
		address _property,
		address _user,
		uint256 _cInterestPrice
	) public onlyOwner {

		require(
			getStorageLastStakedInterestPrice(_property, _user) !=
				_cInterestPrice,
			"ALREADY EXISTS"
		);
		setStorageLastStakedInterestPrice(_property, _user, _cInterestPrice);
	}

	function __initLastStakeOnProperty(
		address _property,
		uint256 _cHoldersAmountPerProperty,
		uint256 _cHoldersPrice
	) public onlyOwner {

		require(
			getStorageLastCumulativeHoldersRewardAmountPerProperty(_property) !=
				_cHoldersAmountPerProperty ||
				getStorageLastCumulativeHoldersRewardPricePerProperty(
					_property
				) !=
				_cHoldersPrice,
			"ALREADY EXISTS"
		);
		setStorageLastCumulativeHoldersRewardAmountPerProperty(
			_property,
			_cHoldersAmountPerProperty
		);
		setStorageLastCumulativeHoldersRewardPricePerProperty(
			_property,
			_cHoldersPrice
		);
	}

	function __initLastStake(
		uint256 _cReward,
		uint256 _cInterestPrice,
		uint256 _cHoldersPrice
	) public onlyOwner {

		require(
			getStorageLastStakesChangedCumulativeReward() != _cReward ||
				getStorageLastCumulativeHoldersRewardPrice() !=
				_cHoldersPrice ||
				getStorageLastCumulativeInterestPrice() != _cInterestPrice,
			"ALREADY EXISTS"
		);
		setStorageLastStakesChangedCumulativeReward(_cReward);
		setStorageLastCumulativeHoldersRewardPrice(_cHoldersPrice);
		setStorageLastCumulativeInterestPrice(_cInterestPrice);
	}
}