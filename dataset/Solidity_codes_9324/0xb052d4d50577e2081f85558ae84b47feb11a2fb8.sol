
pragma solidity >=0.5.4 <0.6.0;

interface tokenRecipient { function receiveApproval(address _from, uint256 _value, address _token, bytes calldata _extraData) external; }



library SafeMath {


	function mul(uint256 a, uint256 b) internal pure returns (uint256 c) {

		if (a == 0) {
			return 0;
		}

		c = a * b;
		assert(c / a == b);
		return c;
	}

	function div(uint256 a, uint256 b) internal pure returns (uint256) {

		return a / b;
	}

	function sub(uint256 a, uint256 b) internal pure returns (uint256) {

		assert(b <= a);
		return a - b;
	}

	function add(uint256 a, uint256 b) internal pure returns (uint256 c) {

		c = a + b;
		assert(c >= a);
		return c;
	}
}


interface INameTAOPosition {

	function senderIsAdvocate(address _sender, address _id) external view returns (bool);

	function senderIsListener(address _sender, address _id) external view returns (bool);

	function senderIsSpeaker(address _sender, address _id) external view returns (bool);

	function senderIsPosition(address _sender, address _id) external view returns (bool);

	function getAdvocate(address _id) external view returns (address);

	function nameIsAdvocate(address _nameId, address _id) external view returns (bool);

	function nameIsPosition(address _nameId, address _id) external view returns (bool);

	function initialize(address _id, address _advocateId, address _listenerId, address _speakerId) external returns (bool);

	function determinePosition(address _sender, address _id) external view returns (uint256);

}


interface IAOIonLot {

	function createPrimordialLot(address _account, uint256 _primordialAmount, uint256 _multiplier, uint256 _networkBonusAmount) external returns (bytes32);


	function createWeightedMultiplierLot(address _account, uint256 _amount, uint256 _weightedMultiplier) external returns (bytes32);


	function lotById(bytes32 _lotId) external view returns (bytes32, address, uint256, uint256);


	function totalLotsByAddress(address _lotOwner) external view returns (uint256);


	function createBurnLot(address _account, uint256 _amount, uint256 _multiplierAfterBurn) external returns (bool);


	function createConvertLot(address _account, uint256 _amount, uint256 _multiplierAfterConversion) external returns (bool);

}













contract TokenERC20 {

	string public name;
	string public symbol;
	uint8 public decimals = 18;
	uint256 public totalSupply;

	mapping (address => uint256) public balanceOf;
	mapping (address => mapping (address => uint256)) public allowance;

	event Transfer(address indexed from, address indexed to, uint256 value);

	event Approval(address indexed _owner, address indexed _spender, uint256 _value);

	event Burn(address indexed from, uint256 value);

	constructor (uint256 initialSupply, string memory tokenName, string memory tokenSymbol) public {
		totalSupply = initialSupply * 10 ** uint256(decimals);  // Update total supply with the decimal amount
		balanceOf[msg.sender] = totalSupply;                // Give the creator all initial tokens
		name = tokenName;                                   // Set the name for display purposes
		symbol = tokenSymbol;                               // Set the symbol for display purposes
	}

	function _transfer(address _from, address _to, uint _value) internal {

		require(_to != address(0));
		require(balanceOf[_from] >= _value);
		require(balanceOf[_to] + _value > balanceOf[_to]);
		uint previousBalances = balanceOf[_from] + balanceOf[_to];
		balanceOf[_from] -= _value;
		balanceOf[_to] += _value;
		emit Transfer(_from, _to, _value);
		assert(balanceOf[_from] + balanceOf[_to] == previousBalances);
	}

	function transfer(address _to, uint256 _value) public returns (bool success) {

		_transfer(msg.sender, _to, _value);
		return true;
	}

	function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {

		require(_value <= allowance[_from][msg.sender]);     // Check allowance
		allowance[_from][msg.sender] -= _value;
		_transfer(_from, _to, _value);
		return true;
	}

	function approve(address _spender, uint256 _value) public returns (bool success) {

		allowance[msg.sender][_spender] = _value;
		emit Approval(msg.sender, _spender, _value);
		return true;
	}

	function approveAndCall(address _spender, uint256 _value, bytes memory _extraData) public returns (bool success) {

		tokenRecipient spender = tokenRecipient(_spender);
		if (approve(_spender, _value)) {
			spender.receiveApproval(msg.sender, _value, address(this), _extraData);
			return true;
		}
	}

	function burn(uint256 _value) public returns (bool success) {

		require(balanceOf[msg.sender] >= _value);   // Check if the sender has enough
		balanceOf[msg.sender] -= _value;            // Subtract from the sender
		totalSupply -= _value;                      // Updates totalSupply
		emit Burn(msg.sender, _value);
		return true;
	}

	function burnFrom(address _from, uint256 _value) public returns (bool success) {

		require(balanceOf[_from] >= _value);                // Check if the targeted balance is enough
		require(_value <= allowance[_from][msg.sender]);    // Check allowance
		balanceOf[_from] -= _value;                         // Subtract from the targeted balance
		allowance[_from][msg.sender] -= _value;             // Subtract from the sender's allowance
		totalSupply -= _value;                              // Update totalSupply
		emit Burn(_from, _value);
		return true;
	}
}


contract TAO {

	using SafeMath for uint256;

	address public vaultAddress;
	string public name;				// the name for this TAO
	address public originId;		// the ID of the Name that created this TAO. If Name, it's the eth address

	string public datHash;
	string public database;
	string public keyValue;
	bytes32 public contentId;

	uint8 public typeId;

	constructor (string memory _name,
		address _originId,
		string memory _datHash,
		string memory _database,
		string memory _keyValue,
		bytes32 _contentId,
		address _vaultAddress
	) public {
		name = _name;
		originId = _originId;
		datHash = _datHash;
		database = _database;
		keyValue = _keyValue;
		contentId = _contentId;

		typeId = 0;

		vaultAddress = _vaultAddress;
	}

	modifier onlyVault {

		require (msg.sender == vaultAddress);
		_;
	}

	function () external payable {
	}

	function transferEth(address payable _recipient, uint256 _amount) public onlyVault returns (bool) {

		_recipient.transfer(_amount);
		return true;
	}

	function transferERC20(address _erc20TokenAddress, address _recipient, uint256 _amount) public onlyVault returns (bool) {

		TokenERC20 _erc20 = TokenERC20(_erc20TokenAddress);
		_erc20.transfer(_recipient, _amount);
		return true;
	}
}




contract Name is TAO {

	constructor (string memory _name, address _originId, string memory _datHash, string memory _database, string memory _keyValue, bytes32 _contentId, address _vaultAddress)
		TAO (_name, _originId, _datHash, _database, _keyValue, _contentId, _vaultAddress) public {
		typeId = 1;
	}
}




library AOLibrary {

	using SafeMath for uint256;

	uint256 constant private _MULTIPLIER_DIVISOR = 10 ** 6; // 1000000 = 1
	uint256 constant private _PERCENTAGE_DIVISOR = 10 ** 6; // 100% = 1000000

	function isTAO(address _taoId) public view returns (bool) {

		return (_taoId != address(0) && bytes(TAO(address(uint160(_taoId))).name()).length > 0 && TAO(address(uint160(_taoId))).originId() != address(0) && TAO(address(uint160(_taoId))).typeId() == 0);
	}

	function isName(address _nameId) public view returns (bool) {

		return (_nameId != address(0) && bytes(TAO(address(uint160(_nameId))).name()).length > 0 && Name(address(uint160(_nameId))).originId() != address(0) && Name(address(uint160(_nameId))).typeId() == 1);
	}

	function isValidERC20TokenAddress(address _tokenAddress) public view returns (bool) {

		if (_tokenAddress == address(0)) {
			return false;
		}
		TokenERC20 _erc20 = TokenERC20(_tokenAddress);
		return (_erc20.totalSupply() >= 0 && bytes(_erc20.name()).length > 0 && bytes(_erc20.symbol()).length > 0);
	}

	function isTheAO(address _sender, address _theAO, address _nameTAOPositionAddress) public view returns (bool) {

		return (_sender == _theAO ||
			(
				(isTAO(_theAO) || isName(_theAO)) &&
				_nameTAOPositionAddress != address(0) &&
				INameTAOPosition(_nameTAOPositionAddress).senderIsAdvocate(_sender, _theAO)
			)
		);
	}

	function PERCENTAGE_DIVISOR() public pure returns (uint256) {

		return _PERCENTAGE_DIVISOR;
	}

	function MULTIPLIER_DIVISOR() public pure returns (uint256) {

		return _MULTIPLIER_DIVISOR;
	}

	function deployTAO(string memory _name,
		address _originId,
		string memory _datHash,
		string memory _database,
		string memory _keyValue,
		bytes32 _contentId,
		address _nameTAOVaultAddress
		) public returns (TAO _tao) {

		_tao = new TAO(_name, _originId, _datHash, _database, _keyValue, _contentId, _nameTAOVaultAddress);
	}

	function deployName(string memory _name,
		address _originId,
		string memory _datHash,
		string memory _database,
		string memory _keyValue,
		bytes32 _contentId,
		address _nameTAOVaultAddress
		) public returns (Name _myName) {

		_myName = new Name(_name, _originId, _datHash, _database, _keyValue, _contentId, _nameTAOVaultAddress);
	}

	function calculateWeightedMultiplier(uint256 _currentWeightedMultiplier, uint256 _currentPrimordialBalance, uint256 _additionalWeightedMultiplier, uint256 _additionalPrimordialAmount) public pure returns (uint256) {

		if (_currentWeightedMultiplier > 0) {
			uint256 _totalWeightedIons = (_currentWeightedMultiplier.mul(_currentPrimordialBalance)).add(_additionalWeightedMultiplier.mul(_additionalPrimordialAmount));
			uint256 _totalIons = _currentPrimordialBalance.add(_additionalPrimordialAmount);
			return _totalWeightedIons.div(_totalIons);
		} else {
			return _additionalWeightedMultiplier;
		}
	}

	function calculatePrimordialMultiplier(uint256 _purchaseAmount, uint256 _totalPrimordialMintable, uint256 _totalPrimordialMinted, uint256 _startingMultiplier, uint256 _endingMultiplier) public pure returns (uint256) {

		if (_purchaseAmount > 0 && _purchaseAmount <= _totalPrimordialMintable.sub(_totalPrimordialMinted)) {
			uint256 temp = _totalPrimordialMinted.add(_purchaseAmount.div(2));

			uint256 multiplier = (_MULTIPLIER_DIVISOR.sub(_MULTIPLIER_DIVISOR.mul(temp).div(_totalPrimordialMintable))).mul(_startingMultiplier.sub(_endingMultiplier));
			return multiplier.div(_MULTIPLIER_DIVISOR);
		} else {
			return 0;
		}
	}

	function calculateNetworkBonusPercentage(uint256 _purchaseAmount, uint256 _totalPrimordialMintable, uint256 _totalPrimordialMinted, uint256 _startingMultiplier, uint256 _endingMultiplier) public pure returns (uint256) {

		if (_purchaseAmount > 0 && _purchaseAmount <= _totalPrimordialMintable.sub(_totalPrimordialMinted)) {
			uint256 temp = _totalPrimordialMinted.add(_purchaseAmount.div(2));

			uint256 bonusPercentage = (_PERCENTAGE_DIVISOR.sub(_PERCENTAGE_DIVISOR.mul(temp).div(_totalPrimordialMintable))).mul(_startingMultiplier.sub(_endingMultiplier)).div(_PERCENTAGE_DIVISOR);
			return bonusPercentage;
		} else {
			return 0;
		}
	}

	function calculateNetworkBonusAmount(uint256 _purchaseAmount, uint256 _totalPrimordialMintable, uint256 _totalPrimordialMinted, uint256 _startingMultiplier, uint256 _endingMultiplier) public pure returns (uint256) {

		uint256 bonusPercentage = calculateNetworkBonusPercentage(_purchaseAmount, _totalPrimordialMintable, _totalPrimordialMinted, _startingMultiplier, _endingMultiplier);
		uint256 networkBonus = bonusPercentage.mul(_purchaseAmount).div(_PERCENTAGE_DIVISOR);
		return networkBonus;
	}

	function calculateMaximumBurnAmount(uint256 _primordialBalance, uint256 _currentWeightedMultiplier, uint256 _maximumMultiplier) public pure returns (uint256) {

		return (_maximumMultiplier.mul(_primordialBalance).sub(_primordialBalance.mul(_currentWeightedMultiplier))).div(_maximumMultiplier);
	}

	function calculateMultiplierAfterBurn(uint256 _primordialBalance, uint256 _currentWeightedMultiplier, uint256 _amountToBurn) public pure returns (uint256) {

		return _primordialBalance.mul(_currentWeightedMultiplier).div(_primordialBalance.sub(_amountToBurn));
	}

	function calculateMultiplierAfterConversion(uint256 _primordialBalance, uint256 _currentWeightedMultiplier, uint256 _amountToConvert) public pure returns (uint256) {

		return _primordialBalance.mul(_currentWeightedMultiplier).div(_primordialBalance.add(_amountToConvert));
	}

	function numDigits(uint256 number) public pure returns (uint8) {

		uint8 digits = 0;
		while(number != 0) {
			number = number.div(10);
			digits++;
		}
		return digits;
	}
}



contract TheAO {

	address public theAO;
	address public nameTAOPositionAddress;

	mapping (address => bool) public whitelist;

	constructor() public {
		theAO = msg.sender;
	}

	modifier inWhitelist() {

		require (whitelist[msg.sender] == true);
		_;
	}

	function transferOwnership(address _theAO) public {

		require (msg.sender == theAO);
		require (_theAO != address(0));
		theAO = _theAO;
	}

	function setWhitelist(address _account, bool _whitelist) public {

		require (msg.sender == theAO);
		require (_account != address(0));
		whitelist[_account] = _whitelist;
	}
}



contract AOIonLot is TheAO {

	using SafeMath for uint256;

	address public aoIonAddress;

	uint256 public totalLots;
	uint256 public totalBurnLots;
	uint256 public totalConvertLots;

	struct Lot {
		bytes32 lotId;
		uint256 multiplier;	// This value is in 10^6, so 1000000 = 1
		address lotOwner;
		uint256 amount;
	}

	struct BurnLot {
		bytes32 burnLotId;
		address lotOwner;
		uint256 amount;
	}

	struct ConvertLot {
		bytes32 convertLotId;
		address lotOwner;
		uint256 amount;
	}

	mapping (bytes32 => Lot) internal lots;

	mapping (bytes32 => BurnLot) internal burnLots;

	mapping (bytes32 => ConvertLot) internal convertLots;

	mapping (address => bytes32[]) internal ownedLots;

	mapping (address => bytes32[]) internal ownedBurnLots;

	mapping (address => bytes32[]) internal ownedConvertLots;

	event LotCreation(address indexed lotOwner, bytes32 indexed lotId, uint256 multiplier, uint256 primordialAmount, uint256 networkBonusAmount);

	event BurnLotCreation(address indexed lotOwner, bytes32 indexed burnLotId, uint256 burnAmount, uint256 multiplierAfterBurn);

	event ConvertLotCreation(address indexed lotOwner, bytes32 indexed convertLotId, uint256 convertAmount, uint256 multiplierAfterConversion);

	constructor(address _aoIonAddress, address _nameTAOPositionAddress) public {
		setAOIonAddress(_aoIonAddress);
		setNameTAOPositionAddress(_nameTAOPositionAddress);
	}

	modifier onlyTheAO {

		require (AOLibrary.isTheAO(msg.sender, theAO, nameTAOPositionAddress));
		_;
	}

	modifier onlyAOIon {

		require (msg.sender == aoIonAddress);
		_;
	}

	function transferOwnership(address _theAO) public onlyTheAO {

		require (_theAO != address(0));
		theAO = _theAO;
	}

	function setWhitelist(address _account, bool _whitelist) public onlyTheAO {

		require (_account != address(0));
		whitelist[_account] = _whitelist;
	}

	function setAOIonAddress(address _aoIonAddress) public onlyTheAO {

		require (_aoIonAddress != address(0));
		aoIonAddress = _aoIonAddress;
	}

	function setNameTAOPositionAddress(address _nameTAOPositionAddress) public onlyTheAO {

		require (_nameTAOPositionAddress != address(0));
		nameTAOPositionAddress = _nameTAOPositionAddress;
	}

	function createPrimordialLot(address _account, uint256 _primordialAmount, uint256 _multiplier, uint256 _networkBonusAmount) external onlyAOIon returns (bytes32) {

		return _createWeightedMultiplierLot(_account, _primordialAmount, _multiplier, _networkBonusAmount);
	}

	function createWeightedMultiplierLot(address _account, uint256 _amount, uint256 _weightedMultiplier) external onlyAOIon returns (bytes32) {

		require (_account != address(0));
		require (_amount > 0);
		return _createWeightedMultiplierLot(_account, _amount, _weightedMultiplier, 0);
	}

	function lotById(bytes32 _lotId) external view returns (bytes32, address, uint256, uint256) {

		Lot memory _lot = lots[_lotId];
		return (_lot.lotId, _lot.lotOwner, _lot.multiplier, _lot.amount);
	}

	function lotIdsByAddress(address _lotOwner) public view returns (bytes32[] memory) {

		return ownedLots[_lotOwner];
	}

	function totalLotsByAddress(address _lotOwner) external view returns (uint256) {

		return ownedLots[_lotOwner].length;
	}

	function lotOfOwnerByIndex(address _lotOwner, uint256 _index) public view returns (bytes32, address, uint256, uint256) {

		require (_index < ownedLots[_lotOwner].length);
		Lot memory _lot = lots[ownedLots[_lotOwner][_index]];
		return (_lot.lotId, _lot.lotOwner, _lot.multiplier, _lot.amount);
	}

	function createBurnLot(address _account, uint256 _amount, uint256 _multiplierAfterBurn) external onlyAOIon returns (bool) {

		totalBurnLots++;

		bytes32 burnLotId = keccak256(abi.encodePacked(this, _account, totalBurnLots));

		require (burnLots[burnLotId].lotOwner == address(0));

		BurnLot storage burnLot = burnLots[burnLotId];
		burnLot.burnLotId = burnLotId;
		burnLot.lotOwner = _account;
		burnLot.amount = _amount;
		ownedBurnLots[_account].push(burnLotId);
		emit BurnLotCreation(burnLot.lotOwner, burnLot.burnLotId, burnLot.amount, _multiplierAfterBurn);
		return true;
	}

	function burnLotIdsByAddress(address _lotOwner) public view returns (bytes32[] memory) {

		return ownedBurnLots[_lotOwner];
	}

	function totalBurnLotsByAddress(address _lotOwner) public view returns (uint256) {

		return ownedBurnLots[_lotOwner].length;
	}

	function burnLotById(bytes32 _burnLotId) public view returns (bytes32, address, uint256) {

		BurnLot memory _burnLot = burnLots[_burnLotId];
		return (_burnLot.burnLotId, _burnLot.lotOwner, _burnLot.amount);
	}

	function createConvertLot(address _account, uint256 _amount, uint256 _multiplierAfterConversion) external onlyAOIon returns (bool) {

		totalConvertLots++;

		bytes32 convertLotId = keccak256(abi.encodePacked(this, _account, totalConvertLots));

		require (convertLots[convertLotId].lotOwner == address(0));

		ConvertLot storage convertLot = convertLots[convertLotId];
		convertLot.convertLotId = convertLotId;
		convertLot.lotOwner = _account;
		convertLot.amount = _amount;
		ownedConvertLots[_account].push(convertLotId);
		emit ConvertLotCreation(convertLot.lotOwner, convertLot.convertLotId, convertLot.amount, _multiplierAfterConversion);
		return true;
	}

	function convertLotIdsByAddress(address _lotOwner) public view returns (bytes32[] memory) {

		return ownedConvertLots[_lotOwner];
	}

	function totalConvertLotsByAddress(address _lotOwner) public view returns (uint256) {

		return ownedConvertLots[_lotOwner].length;
	}

	function convertLotById(bytes32 _convertLotId) public view returns (bytes32, address, uint256) {

		ConvertLot memory _convertLot = convertLots[_convertLotId];
		return (_convertLot.convertLotId, _convertLot.lotOwner, _convertLot.amount);
	}

	function _createWeightedMultiplierLot(address _account, uint256 _amount, uint256 _weightedMultiplier, uint256 _networkBonusAmount) internal returns (bytes32) {

		totalLots++;

		bytes32 lotId = keccak256(abi.encodePacked(address(this), _account, totalLots));

		require (lots[lotId].lotOwner == address(0));

		Lot storage lot = lots[lotId];
		lot.lotId = lotId;
		lot.multiplier = _weightedMultiplier;
		lot.lotOwner = _account;
		lot.amount = _amount;
		ownedLots[_account].push(lotId);

		emit LotCreation(lot.lotOwner, lot.lotId, lot.multiplier, lot.amount, _networkBonusAmount);
		return lotId;
	}
}