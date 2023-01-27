
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

	function sub(uint256 a, uint256 b, string memory errorMessage)
		internal
		pure
		returns (uint256)
	{

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

	function div(uint256 a, uint256 b, string memory errorMessage)
		internal
		pure
		returns (uint256)
	{

		require(b > 0, errorMessage);
		uint256 c = a / b;

		return c;
	}

	function mod(uint256 a, uint256 b) internal pure returns (uint256) {

		return mod(a, b, "SafeMath: modulo by zero");
	}

	function mod(uint256 a, uint256 b, string memory errorMessage)
		internal
		pure
		returns (uint256)
	{

		require(b != 0, errorMessage);
		return a % b;
	}
}


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


	function transferFrom(address sender, address recipient, uint256 amount)
		external
		returns (bool);


	event Transfer(address indexed from, address indexed to, uint256 value);

	event Approval(
		address indexed owner,
		address indexed spender,
		uint256 value
	);
}


library SafeERC20 {

	using SafeMath for uint256;

	function safeTransfer(IERC20 token, address to, uint256 value) internal {

		callOptionalReturn(
			token,
			abi.encodeWithSelector(token.transfer.selector, to, value)
		);
	}

	function safeTransferFrom(
		IERC20 token,
		address from,
		address to,
		uint256 value
	) internal {

		callOptionalReturn(
			token,
			abi.encodeWithSelector(token.transferFrom.selector, from, to, value)
		);
	}

	function safeApprove(IERC20 token, address spender, uint256 value)
		internal
	{

		require(
			(value == 0) || (token.allowance(address(this), spender) == 0),
			"SafeERC20: approve from non-zero to non-zero allowance"
		);
		callOptionalReturn(
			token,
			abi.encodeWithSelector(token.approve.selector, spender, value)
		);
	}

	function safeIncreaseAllowance(IERC20 token, address spender, uint256 value)
		internal
	{

		uint256 newAllowance = token.allowance(address(this), spender).add(
			value
		);
		callOptionalReturn(
			token,
			abi.encodeWithSelector(
				token.approve.selector,
				spender,
				newAllowance
			)
		);
	}

	function safeDecreaseAllowance(IERC20 token, address spender, uint256 value)
		internal
	{

		uint256 newAllowance = token.allowance(address(this), spender).sub(
			value
		);
		callOptionalReturn(
			token,
			abi.encodeWithSelector(
				token.approve.selector,
				spender,
				newAllowance
			)
		);
	}

	function callOptionalReturn(IERC20 token, bytes memory data) private {



		(bool success, bytes memory returndata) = address(token).call(data);
		require(success, "SafeERC20: low-level call failed");

		if (returndata.length > 0) {
			require(
				abi.decode(returndata, (bool)),
				"SafeERC20: ERC20 operation did not succeed"
			);
		}
	}
}


library Roles {

	struct Role {
		mapping(address => bool) bearer;
	}

	function add(Role storage _role, address _account) internal {

		require(!has(_role, _account), "Roles: account already has role");
		_role.bearer[_account] = true;
	}

	function remove(Role storage _role, address _account) internal {

		require(has(_role, _account), "Roles: account does not have role");
		_role.bearer[_account] = false;
	}

	function has(Role storage _role, address _account)
		internal
		view
		returns (bool)
	{

		require(_account != address(0), "Roles: account is the zero address");
		return _role.bearer[_account];
	}
}


contract Ownable {

	address private _owner;

	event OwnershipTransferred(
		address indexed previousOwner,
		address indexed newOwner
	);

	constructor() internal {
		_owner = msg.sender;
		emit OwnershipTransferred(address(0), _owner);
	}

	function owner() public view returns (address) {

		return _owner;
	}

	modifier onlyOwner() {

		require(isOwner(), "Ownable: caller is not the owner");
		_;
	}

	function isOwner() public view returns (bool) {

		return msg.sender == _owner;
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


contract Operator is Ownable {

	using Roles for Roles.Role;

	Roles.Role private _operators;

	address[] private _operatorsListed;

	mapping(address => uint256) _operatorIndexs;

	event OperatorAdded(address indexed account);
	event OperatorRemoved(address indexed account);

	modifier onlyOperator() {

		require(
			isOperator(msg.sender),
			"caller does not have the Operator role"
		);
		_;
	}

	constructor() public {
		_addOperator(msg.sender);
	}

	function getAllOperators() public view returns(address[] memory operators) {

		operators = new address[](_operatorsListed.length);
		uint256 counter = 0;
		for (uint256 i = 0; i < _operatorsListed.length; i++) {
			if (isOperator(_operatorsListed[i])) {
				operators[counter] = _operatorsListed[i];
				counter++;
			}
		}
	  return operators;
	}

	function isOperator(address _account) public view returns (bool) {

		return _operators.has(_account);
	}

	function addOperator(address _account) public onlyOwner {

		_addOperator(_account);
	}

	function batchAddOperators(address[] memory _accounts) public onlyOwner {

		uint256 arrayLength = _accounts.length;
		for (uint256 i = 0; i < arrayLength; i++) {
			_addOperator(_accounts[i]);
		}
	}

	function removeOperator(address _account) public onlyOwner {

		_removeOperator(_account);
	}

	function batchRemoveOperators(address[] memory _accounts)
		public
		onlyOwner
	{

		uint256 arrayLength = _accounts.length;
		for (uint256 i = 0; i < arrayLength; i++) {
			_removeOperator(_accounts[i]);
		}
	}

	function renounceOperator() public {

		_removeOperator(msg.sender);
	}

	function _addOperator(address _account) internal {

		_operators.add(_account);
		if (_operatorIndexs[_account] == 0) {
		  _operatorsListed.push(_account);
		  _operatorIndexs[_account] = _operatorsListed.length;
		}
		emit OperatorAdded(_account);
	}

	function _removeOperator(address _account) internal {

		_operators.remove(_account);
		emit OperatorRemoved(_account);
	}
}


contract Pausable is Ownable {

	event Paused(address account);

	event Unpaused(address account);

	bool private _paused;

	constructor() internal {
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

	function pause() public onlyOwner whenNotPaused {

		_paused = true;
		emit Paused(msg.sender);
	}

	function unpause() public onlyOwner whenPaused {

		_paused = false;
		emit Unpaused(msg.sender);
	}
}


interface IAdvanceCrowdsale {

  function updatePurchasingState(address beneficiary, uint256 tokenAmount) external returns(bool);

}



contract TimeLockFactory is Operator, Pausable {

	using SafeMath for uint256;
	using SafeERC20 for IERC20;

	IERC20 private _token;

	uint256 private _globalReleaseTime;

	address[] private _lockupBeneficiaries;

	uint256[] private _bundleIdentifies;

	LockupPhase[] private _lockupPhases;

	bool private _finalized;

	string public constant version = "1.0";

	uint256 public constant TOTAL_PERCENTAGE = 1000; // mean 10x percent 1000 = 100%

	struct LockupPhase {
		uint256 id;
		uint256 percentage;
		uint256 extraTime;
		uint256 unlockedCount;
		bool hasWithdrawal;
	}

	struct LockupBundle {
		uint256 id;
		address beneficiary;
		uint256 amount;
		mapping(uint256 => bool) isPhaseWithdrawns;
	}

	mapping(address => uint256[]) private _lockupIdsOfBeneficiary;

	mapping(uint256 => LockupBundle) private _lockupBundles;

	mapping(uint256 => uint256) private _phaseIndexs;

	mapping(string => uint256) private _processedTxids;

	event TokenLocked(address _beneficiary, uint256 _amount);

	event TimeLockFactoryFinalized();

	modifier whenNotFinalized() {

		require(!_finalized, "TimeLockFactory: finalized");
		_;
	}

	constructor(IERC20 token) public {
		_token = token;
	}

	function token() public view returns (IERC20) {

		return _token;
	}

	function globalReleaseTime() public view returns (uint256) {

		return _globalReleaseTime;
	}

	function finalized() public view returns (bool) {

		return _finalized;
	}

	function getTotalBeneficiaries() public view returns (uint256) {

		return _lockupBeneficiaries.length;
	}

	function getTotalBundleIdentifies() public view returns (uint256) {

		return _bundleIdentifies.length;
	}

	function getTotalBundleIdentifiesOf(address _beneficiary) public view returns (uint256) {

		return _lockupIdsOfBeneficiary[_beneficiary].length;
	}

	function paginationBeneficiaries(uint256 _startIndex, uint256 _endIndex, bool _revert) public view returns (address[] memory) {

		uint256 startIndex = _startIndex;
		uint256 endIndex = _endIndex;
		if (startIndex >= _lockupBeneficiaries.length) {
			return new address[](0);
		}
		if (endIndex > _lockupBeneficiaries.length) {
			endIndex = _lockupBeneficiaries.length;
		}
		address[] memory beneficiaries = new address[](endIndex.sub(startIndex));
		if (_revert) {
			for (uint256 i = endIndex; i > startIndex; i--) {
				beneficiaries[endIndex.sub(i)] = _lockupBeneficiaries[i.sub(1)];
			}
			return beneficiaries;
		}
		for (uint256 i = startIndex; i < endIndex; i++) {
			beneficiaries[i.sub(startIndex)] = _lockupBeneficiaries[i];
		}
		return beneficiaries;
	}

	function paginationBundleIdentifies(uint256 _startIndex, uint256 _endIndex, bool _revert) public view returns (uint256[] memory) {

		uint256 startIndex = _startIndex;
		uint256 endIndex = _endIndex;
		if (startIndex >= _bundleIdentifies.length) {
			return new uint256[](0);
		}
		if (endIndex > _bundleIdentifies.length) {
			endIndex = _bundleIdentifies.length;
		}

		uint256[] memory identifies = new uint256[](endIndex.sub(startIndex));
		if (_revert) {
			for (uint256 i = endIndex; i > startIndex; i--) {
				identifies[endIndex.sub(i)] = _bundleIdentifies[i.sub(1)];
			}
			return identifies;
		}
		for (uint256 i = startIndex; i < endIndex; i++) {
			identifies[i.sub(startIndex)] = _bundleIdentifies[i];
		}
		return identifies;
	}

	function paginationBundleIdentifiesOf(address _beneficiary, uint256 _startIndex, uint256 _endIndex, bool _revert) public view returns (uint256[] memory) {

		uint256 startIndex = _startIndex;
		uint256 endIndex = _endIndex;
		if (startIndex >= _lockupIdsOfBeneficiary[_beneficiary].length) {
			return new uint256[](0);
		}
		if (endIndex >= _lockupIdsOfBeneficiary[_beneficiary].length) {
			endIndex = _lockupIdsOfBeneficiary[_beneficiary].length;
		}
		uint256[] memory identifies = new uint256[](endIndex.sub(startIndex));
		if (_revert) {
			for (uint256 i = endIndex; i > startIndex; i--) {
				identifies[endIndex.sub(i)] = _lockupIdsOfBeneficiary[_beneficiary][i.sub(1)];
			}
			return identifies;
		}
		for (uint256 i = startIndex; i < endIndex; i++) {
			identifies[i.sub(startIndex)] = _lockupIdsOfBeneficiary[_beneficiary][i];
		}
		return identifies;
	}

	function getBundleDetailById(uint256 _id) public view returns (uint256 id, address beneficiary, uint256 amount, uint256[] memory phaseIdentifies, bool[] memory isPhaseWithdrawns) {

		LockupBundle storage bundle = _lockupBundles[_id];
		id = bundle.id;
		beneficiary = bundle.beneficiary;
		amount = bundle.amount;
		phaseIdentifies = new uint256[](_lockupPhases.length);
		isPhaseWithdrawns = new bool[](_lockupPhases.length);
		for (uint256 i = 0; i < _lockupPhases.length; i++) {
			phaseIdentifies[i] = _lockupPhases[i].id;
			isPhaseWithdrawns[i] = bundle.isPhaseWithdrawns[_lockupPhases[i].id];
		}
	}

	function getLockupPhases() public view returns (uint256[] memory ids, uint256[] memory percentages, uint256[] memory extraTimes, bool[] memory hasWithdrawals, bool[] memory canWithdrawals) {

		ids = new uint256[](_lockupPhases.length);
		percentages = new uint256[](_lockupPhases.length);
		extraTimes = new uint256[](_lockupPhases.length);
		hasWithdrawals = new bool[](_lockupPhases.length);
		canWithdrawals = new bool[](_lockupPhases.length);

		for (uint256 i = 0; i < _lockupPhases.length; i++) {
			LockupPhase memory phase = _lockupPhases[i];
			ids[i] = phase.id;
			percentages[i] = phase.percentage;
			extraTimes[i] = phase.extraTime;
			hasWithdrawals[i] = phase.hasWithdrawal;
			canWithdrawals[i] = checkPhaseCanWithdrawal(phase.id);
		}
	}

	function getLockupPhaseDetail(uint256 _id) public view returns (uint256 id, uint256 percentage, uint256 extraTime, bool hasWithdrawal, bool canWithdrawal) {

		if (_phaseIndexs[_id] > 0) {
			LockupPhase memory phase = _lockupPhases[_phaseIndexs[_id].sub(1)];
			id = phase.id;
			percentage = phase.percentage;
			extraTime = phase.extraTime;
			hasWithdrawal = phase.hasWithdrawal;
			canWithdrawal = checkPhaseCanWithdrawal(_id);
		}
	}

	function checkPhaseCanWithdrawal(uint256 _id) public view returns (bool) {

		if (_phaseIndexs[_id] == 0) {
			return false;
		}
		LockupPhase memory phase = _lockupPhases[_phaseIndexs[_id].sub(1)];
		return !phase.hasWithdrawal && _globalReleaseTime.add(phase.extraTime) <= block.timestamp;
	}

	function checkPhaseHasWithdrawal(uint256 _id) internal view returns (bool) {

		if (_phaseIndexs[_id] == 0) {
			return false;
		}
		LockupPhase memory phase = _lockupPhases[_phaseIndexs[_id].sub(1)];
		return phase.hasWithdrawal;
	}

	function hasProcessedTxid(string memory _txid) public view returns (bool) {

		return _processedTxids[_txid] != 0;
	}


	function setLockupPhases(uint256[] memory _ids, uint256[] memory _percentages, uint256[] memory _extraTimes) public whenNotPaused whenNotFinalized {

		require(isOwner() || isOperator(msg.sender), "TimeLockFactory: caller is not the owner or operator");
		require(_ids.length == _percentages.length && _ids.length == _extraTimes.length, "TimeLockFactory:: Cannot match inputs");
		_preValidateLockupPhases(_percentages);
		for (uint256 i = 0; i < _ids.length; i++) {
			if (!checkPhaseHasWithdrawal(_ids[i])) {
				_setLockupPhase(_ids[i], _percentages[i], _extraTimes[i]);
			}
		}
	}

	function _setLockupPhase(uint256 _id, uint256 _percentage, uint256 _extraTime) internal {

		require(_id > 0, "TimeLockFactory: Phase ID is zero");
		require(_percentage > 0, "TimeLockFactory: Percentage is zero");
		require(_extraTime > 0, "TimeLockFactory: ExtraTime is zero");

		LockupPhase memory phase = LockupPhase(_id, _percentage, _extraTime, 0, false);
		_lockupPhases.push(phase);
		_phaseIndexs[_id] = _lockupPhases.length;
	}

	function _preValidateLockupPhases(uint256[] memory _percentages) internal {

		uint256 totalPercentage = 0;
		for (uint256 i = 0; i < _percentages.length; i++) {
			totalPercentage = totalPercentage.add(_percentages[i]);
		}
		require(totalPercentage == TOTAL_PERCENTAGE, "TimeLockFactory: Total percentage is not valid");
		LockupPhase[] memory _tempPhases = new LockupPhase[](_lockupPhases.length);
		for (uint256 i = 0; i < _lockupPhases.length; i++) {
			_tempPhases[i] = _lockupPhases[i];
		}
		_lockupPhases.length = 0;
		for (uint256 i = 0; i < _tempPhases.length; i++) {
			if (_tempPhases[i].hasWithdrawal) {
				_lockupPhases.push(_tempPhases[i]);
				_phaseIndexs[_tempPhases[i].id] = _lockupPhases.length;
			} else {
				_phaseIndexs[_tempPhases[i].id] = 0;
			}
		}
	}



	function lock(uint256 _id, address _beneficiary, uint256 _amount, address _saleAddress) public whenNotPaused whenNotFinalized {

		require(isOwner() || isOperator(msg.sender), "TimeLockFactory: caller is not the owner or operator");
		_lock(_id, _beneficiary, _amount, _saleAddress);
	}

	function lock(uint256 _id, address _beneficiary, uint256 _amount, address _saleAddress, string memory _txid) public whenNotPaused whenNotFinalized {

		require(isOwner() || isOperator(msg.sender), "TimeLockFactory: caller is not the owner or operator");
		require(_processedTxids[_txid] == 0, "TimeLockFactory: Txid is processed or empty");
		_lock(_id, _beneficiary, _amount, _saleAddress);
		_processedTxids[_txid] = _id;
	}

	function _lock(uint256 _id, address _beneficiary, uint256 _amount, address _saleAddress) internal {

		_preValidateLockup(_id, _beneficiary, _amount);

		_processLockup(_id, _beneficiary, _amount);

		emit TokenLocked(_beneficiary, _amount);

		_postUnlockIfAvailable(_id, _beneficiary, _amount, _saleAddress);
	}

	function hasEnoughTokenBeforeLockup(uint256 _amount) public view returns (bool hasEnough, uint256 requiredAmount) {

		uint256 unlockedPercentage = 0;
		for (uint256 i = 0; i < _lockupPhases.length; i++) {
			LockupPhase memory phase = _lockupPhases[i];
			if (phase.hasWithdrawal) {
				unlockedPercentage = unlockedPercentage.add(phase.percentage);
			}
		}

		uint256 unlockedAmount = _amount.mul(unlockedPercentage).div(TOTAL_PERCENTAGE);
		if (_token.balanceOf(address(this)) >= unlockedAmount) {
			return (true, 0);
		}
		return (false, unlockedAmount);
	}

	function _preValidateLockup(uint256 _id, address _beneficiary, uint256 _amount) internal view {

		require(_id > 0, "TimeLockFactory: Bundle ID is zero");
		require(_beneficiary != address(0), "TimeLockFactory: Beneficiary is zero address");
		require(_amount > 0, "TimeLockFactory: Amount is zero");

		LockupBundle memory _existedBundle = _lockupBundles[_id];
		require(_existedBundle.id == 0, "TimeLockFactory: Bundle ID has already existed");
		(bool hasEnough, ) = hasEnoughTokenBeforeLockup(_amount);
		require(hasEnough, "TimeLockFactory: Balance not enough");
	}

	function _processLockup(uint256 _id, address _beneficiary, uint256 _amount) internal {

		LockupBundle memory bundle = LockupBundle(_id, _beneficiary, _amount);
		_lockupBundles[_id] = bundle;
		if (_lockupIdsOfBeneficiary[_beneficiary].length == 0) {
			_lockupBeneficiaries.push(_beneficiary);
		}
		_bundleIdentifies.push(_id);
		_lockupIdsOfBeneficiary[_beneficiary].push(_id);
	}

	function _postUnlockIfAvailable(uint256 _id, address _beneficiary, uint256 _amount, address _saleAddress) internal {

		IAdvanceCrowdsale(_saleAddress).updatePurchasingState(_beneficiary, _amount);

		uint256 unlockedPercentage = 0;
		for (uint256 i = 0; i < _lockupPhases.length; i++) {
			LockupPhase memory phase = _lockupPhases[i];
			if (phase.hasWithdrawal) {
				unlockedPercentage = unlockedPercentage.add(phase.percentage);
				_lockupBundles[_id].isPhaseWithdrawns[phase.id] = true;
			} else {
				_lockupBundles[_id].isPhaseWithdrawns[phase.id] = false;
			}
		}

		uint256 unlockedAmount = _amount.mul(unlockedPercentage).div(TOTAL_PERCENTAGE);
		if (unlockedAmount > 0) {
			_token.safeTransfer(_beneficiary, unlockedAmount);
		}
	}

	function unlocks(uint256 _phaseId, uint256 _limit) public whenNotPaused whenNotFinalized {

		require(isOwner() || isOperator(msg.sender), "TimeLockFactory: caller is not the owner or operator");
		require(_phaseId > 0, "TimeLockFactory: Phase ID is zero");
		require(_limit > 0, "TimeLockFactory: Must set maximum bundles per unlock");
		require(_phaseIndexs[_phaseId] > 0, "TimeLockFactory: Phase ID not existed");

		_preUnlockPhase(_phaseId, _limit);

		_processUnlocks(_phaseId, _limit);
	}

	function hasEnoughTokenBeforeUnlock(uint256 _phaseId, uint256 _limit) public view returns (bool hasEnough, uint256 requiredAmount) {

		if (_phaseIndexs[_phaseId] == 0) {
			return (false, 0);
		}

		uint256 totalUnlockAmount = 0;
		uint256 _limitCounter = 0;
		LockupPhase storage phase = _lockupPhases[_phaseIndexs[_phaseId].sub(1)];
		for (uint256 i = phase.unlockedCount; i < _bundleIdentifies.length; i++) {
			LockupBundle storage bundle = _lockupBundles[_bundleIdentifies[i]];
			if (bundle.isPhaseWithdrawns[_phaseId]) {
				continue;
			}
			uint256 unlockAmount = bundle.amount.mul(phase.percentage).div(TOTAL_PERCENTAGE);
			totalUnlockAmount = totalUnlockAmount.add(unlockAmount);
			_limitCounter = _limitCounter.add(1);
			if (_limitCounter == _limit) {
				break;
			}
		}

		if (_token.balanceOf(address(this)) >= totalUnlockAmount) {
			return (true, 0);
		}
		return (false, totalUnlockAmount);
	}

	function _preUnlockPhase(uint256 _phaseId, uint256 _limit) internal view {

		LockupPhase storage phase = _lockupPhases[_phaseIndexs[_phaseId].sub(1)];
		require(phase.id > 0, "TimeLockFactory: Phase does not exist");
		require(!phase.hasWithdrawal, "TimeLockFactory: Phase was unlocked");
		require(_globalReleaseTime.add(phase.extraTime) <= block.timestamp, "TimeLockFactory: Phase is locking");
		(bool hasEnough, ) = hasEnoughTokenBeforeUnlock(_phaseId, _limit);
		require(hasEnough, "TimeLockFactory: Balance not enough");
	}

	function _processUnlocks(uint256 _phaseId, uint256 _limit) internal {

		uint256 _limitCounter = 0;
		LockupPhase storage phase = _lockupPhases[_phaseIndexs[_phaseId].sub(1)];
		for (uint256 i = phase.unlockedCount; i < _bundleIdentifies.length; i++) {
			LockupBundle storage bundle = _lockupBundles[_bundleIdentifies[i]];
			if (bundle.isPhaseWithdrawns[_phaseId]) {
				continue;
			}
			uint256 unlockAmount = bundle.amount.mul(phase.percentage).div(TOTAL_PERCENTAGE);
			_token.safeTransfer(bundle.beneficiary, unlockAmount);
			bundle.isPhaseWithdrawns[_phaseId] = true;
			phase.unlockedCount = phase.unlockedCount.add(1);
			_limitCounter = _limitCounter.add(1);
			if (_limitCounter == _limit) {
				break;
			}
		}
		if (phase.unlockedCount >= _bundleIdentifies.length) {
			phase.hasWithdrawal = true;
		}
	}


	function setGlobalReleaseTime(uint256 _globalTime) public onlyOwner whenNotFinalized {

		_globalReleaseTime = _globalTime;
	}

	function withdrawal(uint256 _amount) public onlyOwner whenNotFinalized {

		require(_amount > 0, "TimeLockFactory: Amount is 0");
		require(_token.balanceOf(address(this)) >= _amount, "TimeLockFactory: Balance not enough");
		_token.safeTransfer(msg.sender, _amount);
	}

	function finalize() public onlyOwner whenNotFinalized {

		_finalized = true;
		_finalization();
		emit TimeLockFactoryFinalized();
	}

	function _finalization() internal {

		uint256 amount = _token.balanceOf(address(this));
		if (amount != 0) {
			_token.safeTransfer(msg.sender, amount);
		}
	}
}