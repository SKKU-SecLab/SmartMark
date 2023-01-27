

pragma solidity ^0.5.0;

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

contract Context {

	constructor() internal {}


	function _msgSender() internal view returns (address payable) {

		return msg.sender;
	}

	function _msgData() internal view returns (bytes memory) {

		this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
		return msg.data;
	}
}


pragma solidity ^0.5.0;

contract Ownable is Context {

	address private _owner;

	event OwnershipTransferred(
		address indexed previousOwner,
		address indexed newOwner
	);

	constructor() internal {
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

		require(
			newOwner != address(0),
			"Ownable: new owner is the zero address"
		);
		emit OwnershipTransferred(_owner, newOwner);
		_owner = newOwner;
	}
}


pragma solidity ^0.5.0;

contract IGroup {

	function isGroup(address _addr) public view returns (bool);


	function addGroup(address _addr) external;


	function getGroupKey(address _addr) internal pure returns (bytes32) {

		return keccak256(abi.encodePacked("_group", _addr));
	}
}


pragma solidity ^0.5.0;

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


pragma solidity ^0.5.0;


contract UsingValidator {

	AddressValidator private _validator;

	constructor() public {
		_validator = new AddressValidator();
	}

	function addressValidator() internal view returns (AddressValidator) {

		return _validator;
	}
}


pragma solidity ^0.5.0;

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


pragma solidity ^0.5.0;

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

	function sub(
		uint256 a,
		uint256 b,
		string memory errorMessage
	) internal pure returns (uint256) {

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

	function div(
		uint256 a,
		uint256 b,
		string memory errorMessage
	) internal pure returns (uint256) {

		require(b > 0, errorMessage);
		uint256 c = a / b;

		return c;
	}

	function mod(uint256 a, uint256 b) internal pure returns (uint256) {

		return mod(a, b, "SafeMath: modulo by zero");
	}

	function mod(
		uint256 a,
		uint256 b,
		string memory errorMessage
	) internal pure returns (uint256) {

		require(b != 0, errorMessage);
		return a % b;
	}
}


pragma solidity ^0.5.0;

interface IERC20 {

	function totalSupply() external view returns (uint256);


	function balanceOf(address account) external view returns (uint256);


	function transfer(address recipient, uint256 amount)
		external
		returns (bool);


	function allowance(address owner, address spender)
		external
		view
		returns (uint256);


	function approve(address spender, uint256 amount) external returns (bool);


	function transferFrom(
		address sender,
		address recipient,
		uint256 amount
	) external returns (bool);


	event Transfer(address indexed from, address indexed to, uint256 value);

	event Approval(
		address indexed owner,
		address indexed spender,
		uint256 value
	);
}


pragma solidity ^0.5.0;

contract ERC20 is Context, IERC20 {

	using SafeMath for uint256;

	mapping(address => uint256) private _balances;

	mapping(address => mapping(address => uint256)) private _allowances;

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

	function allowance(address owner, address spender)
		public
		view
		returns (uint256)
	{

		return _allowances[owner][spender];
	}

	function approve(address spender, uint256 amount) public returns (bool) {

		_approve(_msgSender(), spender, amount);
		return true;
	}

	function transferFrom(
		address sender,
		address recipient,
		uint256 amount
	) public returns (bool) {

		_transfer(sender, recipient, amount);
		_approve(
			sender,
			_msgSender(),
			_allowances[sender][_msgSender()].sub(
				amount,
				"ERC20: transfer amount exceeds allowance"
			)
		);
		return true;
	}

	function increaseAllowance(address spender, uint256 addedValue)
		public
		returns (bool)
	{

		_approve(
			_msgSender(),
			spender,
			_allowances[_msgSender()][spender].add(addedValue)
		);
		return true;
	}

	function decreaseAllowance(address spender, uint256 subtractedValue)
		public
		returns (bool)
	{

		_approve(
			_msgSender(),
			spender,
			_allowances[_msgSender()][spender].sub(
				subtractedValue,
				"ERC20: decreased allowance below zero"
			)
		);
		return true;
	}

	function _transfer(
		address sender,
		address recipient,
		uint256 amount
	) internal {

		require(sender != address(0), "ERC20: transfer from the zero address");
		require(recipient != address(0), "ERC20: transfer to the zero address");

		_balances[sender] = _balances[sender].sub(
			amount,
			"ERC20: transfer amount exceeds balance"
		);
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

		_balances[account] = _balances[account].sub(
			amount,
			"ERC20: burn amount exceeds balance"
		);
		_totalSupply = _totalSupply.sub(amount);
		emit Transfer(account, address(0), amount);
	}

	function _approve(
		address owner,
		address spender,
		uint256 amount
	) internal {

		require(owner != address(0), "ERC20: approve from the zero address");
		require(spender != address(0), "ERC20: approve to the zero address");

		_allowances[owner][spender] = amount;
		emit Approval(owner, spender, amount);
	}

	function _burnFrom(address account, uint256 amount) internal {

		_burn(account, amount);
		_approve(
			account,
			_msgSender(),
			_allowances[account][_msgSender()].sub(
				amount,
				"ERC20: burn amount exceeds allowance"
			)
		);
	}
}


pragma solidity ^0.5.0;

contract ERC20Detailed is IERC20 {

	string private _name;
	string private _symbol;
	uint8 private _decimals;

	constructor(
		string memory name,
		string memory symbol,
		uint8 decimals
	) public {
		_name = name;
		_symbol = symbol;
		_decimals = decimals;
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
}


pragma solidity ^0.5.0;

contract IAllocator {

	function calculateMaxRewardsPerBlock() public view returns (uint256);


	function beforeBalanceChange(
		address _property,
		address _from,
		address _to
	) external;

}


pragma solidity ^0.5.0;

contract IProperty {

	function author() external view returns (address);


	function withdraw(address _sender, uint256 _value) external;

}


pragma solidity ^0.5.0;


contract Property is
	ERC20,
	ERC20Detailed,
	UsingConfig,
	UsingValidator,
	IProperty
{

	using SafeMath for uint256;
	uint8 private constant _property_decimals = 18;
	uint256 private constant _supply = 10000000000000000000000000;
	address public author;

	constructor(
		address _config,
		address _own,
		string memory _name,
		string memory _symbol
	)
		public
		UsingConfig(_config)
		ERC20Detailed(_name, _symbol, _property_decimals)
	{
		addressValidator().validateAddress(
			msg.sender,
			config().propertyFactory()
		);

		author = _own;
		_mint(author, _supply);
	}

	function transfer(address _to, uint256 _value) public returns (bool) {

		addressValidator().validateIllegalAddress(_to);
		require(_value != 0, "illegal transfer value");

		IAllocator(config().allocator()).beforeBalanceChange(
			address(this),
			msg.sender,
			_to
		);
		_transfer(msg.sender, _to, _value);
		return true;
	}

	function transferFrom(
		address _from,
		address _to,
		uint256 _value
	) public returns (bool) {

		addressValidator().validateIllegalAddress(_from);
		addressValidator().validateIllegalAddress(_to);
		require(_value != 0, "illegal transfer value");

		IAllocator(config().allocator()).beforeBalanceChange(
			address(this),
			_from,
			_to
		);
		_transfer(_from, _to, _value);
		uint256 allowanceAmount = allowance(_from, msg.sender);
		_approve(
			_from,
			msg.sender,
			allowanceAmount.sub(
				_value,
				"ERC20: transfer amount exceeds allowance"
			)
		);
		return true;
	}

	function withdraw(address _sender, uint256 _value) external {

		addressValidator().validateAddress(msg.sender, config().lockup());

		ERC20 devToken = ERC20(config().token());
		devToken.transfer(_sender, _value);
	}
}


pragma solidity ^0.5.0;

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


pragma solidity ^0.5.0;

contract UsingStorage is Ownable {

	address private _storage;

	modifier hasStorage() {

		require(_storage != address(0), "storage is not setted");
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

		require(_storage == address(0), "storage is setted");
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


pragma solidity ^0.5.0;

contract PropertyGroup is UsingConfig, UsingStorage, UsingValidator, IGroup {

	constructor(address _config) public UsingConfig(_config) {}

	function addGroup(address _addr) external {

		addressValidator().validateAddress(
			msg.sender,
			config().propertyFactory()
		);

		require(isGroup(_addr) == false, "already enabled");
		eternalStorage().setBool(getGroupKey(_addr), true);
	}

	function isGroup(address _addr) public view returns (bool) {

		return eternalStorage().getBool(getGroupKey(_addr));
	}
}


pragma solidity ^0.5.0;

contract IPropertyFactory {

	function create(
		string calldata _name,
		string calldata _symbol,
		address _author
	)
		external
		returns (
			address
		);

}


pragma solidity ^0.5.0;

contract PropertyFactory is UsingConfig, IPropertyFactory {

	event Create(address indexed _from, address _property);

	constructor(address _config) public UsingConfig(_config) {}

	function create(
		string calldata _name,
		string calldata _symbol,
		address _author
	) external returns (address) {

		validatePropertyName(_name);
		validatePropertySymbol(_symbol);

		Property property = new Property(
			address(config()),
			_author,
			_name,
			_symbol
		);
		IGroup(config().propertyGroup()).addGroup(address(property));
		emit Create(msg.sender, address(property));
		return address(property);
	}

	function validatePropertyName(string memory _name) private pure {

		uint256 len = bytes(_name).length;
		require(
			len >= 3,
			"name must be at least 3 and no more than 10 characters"
		);
		require(
			len <= 10,
			"name must be at least 3 and no more than 10 characters"
		);
	}

	function validatePropertySymbol(string memory _symbol) private pure {

		uint256 len = bytes(_symbol).length;
		require(
			len >= 3,
			"symbol must be at least 3 and no more than 10 characters"
		);
		require(
			len <= 10,
			"symbol must be at least 3 and no more than 10 characters"
		);
	}
}