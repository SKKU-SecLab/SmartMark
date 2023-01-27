
pragma solidity ^0.7.0;

abstract contract Initializable {
	bool private _initialized;

	bool private _initializing;

	modifier initializer() {
		require(
			_initializing || !_initialized,
			"Initializable: contract is already initialized"
		);

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
}// MIT

pragma solidity ^0.7.0;

abstract contract ContextUpgradeable is Initializable {
	function __Context_init() internal initializer {
		__Context_init_unchained();
	}

	function __Context_init_unchained() internal initializer {}

	function _msgSender() internal view virtual returns (address) {
		return msg.sender;
	}

	function _msgData() internal view virtual returns (bytes calldata) {
		this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
		return msg.data;
	}

	uint256[50] private __gap;
}// MIT

pragma solidity ^0.7.0;


abstract contract OwnableUpgradeable is Initializable, ContextUpgradeable {
	address private _owner;

	event OwnershipTransferred(
		address indexed previousOwner,
		address indexed newOwner
	);

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
		require(
			newOwner != address(0),
			"Ownable: new owner is the zero address"
		);
		emit OwnershipTransferred(_owner, newOwner);
		_owner = newOwner;
	}

	uint256[49] private __gap;
}pragma solidity =0.7.6;
pragma experimental ABIEncoderV2;


interface ILegacyRegistry {

	struct Creator {
		address token;
		string name;
		string symbol;
		uint8 decimals;
		uint256 totalSupply;
		address proposer;
		address vestingBeneficiary;
		uint8 initialPercentage;
		uint256 vestingPeriodInWeeks;
		bool approved;
	}

	function rolodex(bytes32) external view returns (Creator memory);


	function getIndexSymbol(string memory _symbol)
		external
		view
		returns (bytes32);

}// UNLICENSED
pragma solidity =0.7.6;


contract Registry is Initializable, OwnableUpgradeable {

	struct Creator {
		address token;
		string name;
		string symbol;
		uint256 totalSupply;
		uint256 vestingPeriodInDays;
		address proposer;
		address vestingBeneficiary;
		uint8 initialPlatformPercentage;
		uint8 decimals;
		uint8 initialPercentage;
		bool approved;
	}

	struct CreatorReferral {
		address referral;
		uint8 referralPercentage;
	}

	mapping(bytes32 => Creator) public rolodex;
	mapping(bytes32 => CreatorReferral) public creatorReferral;
	mapping(string => bytes32) nameToIndex;
	mapping(string => bytes32) symbolToIndex;

	address legacyRegistry;

	event LogProposalSubmit(
		string name,
		string symbol,
		address proposer,
		bytes32 indexed hashIndex
	);

	event LogProposalReferralSubmit(
		address referral,
		uint8 referralPercentage,
		bytes32 indexed hashIndex
	);

	event LogProposalImported(
		string name,
		string symbol,
		address proposer,
		bytes32 indexed hashIndex
	);
	event LogProposalApprove(string name, address indexed tokenAddress);

	function initialize() public initializer {

		__Ownable_init();
	}

	function submitProposal(
		string memory _name,
		string memory _symbol,
		uint8 _decimals,
		uint256 _totalSupply,
		uint8 _initialPercentage,
		uint256 _vestingPeriodInDays,
		address _vestingBeneficiary,
		address _proposer,
		uint8 _initialPlatformPercentage
	) public onlyOwner returns (bytes32 hashIndex) {

		nameDoesNotExist(_name);
		symbolDoesNotExist(_symbol);
		hashIndex = keccak256(abi.encodePacked(_name, _symbol, _proposer));
		rolodex[hashIndex] = Creator({
			token: address(0),
			name: _name,
			symbol: _symbol,
			decimals: _decimals,
			totalSupply: _totalSupply,
			proposer: _proposer,
			vestingBeneficiary: _vestingBeneficiary,
			initialPercentage: _initialPercentage,
			vestingPeriodInDays: _vestingPeriodInDays,
			approved: false,
			initialPlatformPercentage: _initialPlatformPercentage
		});

		emit LogProposalSubmit(_name, _symbol, msg.sender, hashIndex);
	}

	function submitProposalReferral(
		bytes32 _hashIndex,
		address _referral,
		uint8 _referralPercentage
	) public onlyOwner {

		creatorReferral[_hashIndex] = CreatorReferral({
			referral: _referral,
			referralPercentage: _referralPercentage
		});
		emit LogProposalReferralSubmit(
			_referral,
			_referralPercentage,
			_hashIndex
		);
	}

	function approveProposal(bytes32 _hashIndex, address _token)
		external
		onlyOwner
		returns (bool)
	{

		Creator memory c = rolodex[_hashIndex];
		nameDoesNotExist(c.name);
		symbolDoesNotExist(c.symbol);
		rolodex[_hashIndex].token = _token;
		rolodex[_hashIndex].approved = true;
		nameToIndex[c.name] = _hashIndex;
		symbolToIndex[c.symbol] = _hashIndex;
		emit LogProposalApprove(c.name, _token);
		return true;
	}


	function getIndexByName(string memory _name) public view returns (bytes32) {

		return nameToIndex[_name];
	}

	function getIndexBySymbol(string memory _symbol)
		public
		view
		returns (bytes32)
	{

		return symbolToIndex[_symbol];
	}

	function getCreatorByIndex(bytes32 _hashIndex)
		external
		view
		returns (Creator memory)
	{

		return rolodex[_hashIndex];
	}

	function getCreatorReferralByIndex(bytes32 _hashIndex)
		external
		view
		returns (CreatorReferral memory)
	{

		return creatorReferral[_hashIndex];
	}

	function getCreatorByName(string memory _name)
		external
		view
		returns (Creator memory)
	{

		bytes32 _hashIndex = nameToIndex[_name];
		return rolodex[_hashIndex];
	}

	function getCreatorBySymbol(string memory _symbol)
		external
		view
		returns (Creator memory)
	{

		bytes32 _hashIndex = symbolToIndex[_symbol];
		return rolodex[_hashIndex];
	}


	function nameDoesNotExist(string memory _name) internal view {

		require(nameToIndex[_name] == 0x0, "Name already exists");
	}

	function symbolDoesNotExist(string memory _name) internal view {

		require(symbolToIndex[_name] == 0x0, "Symbol already exists");
	}

	function importByIndex(bytes32 _hashIndex, address _oldRegistry)
		external
		onlyOwner
	{

		Registry old = Registry(_oldRegistry);
		Creator memory proposal = old.getCreatorByIndex(_hashIndex);
		nameDoesNotExist(proposal.name);
		symbolDoesNotExist(proposal.symbol);

		rolodex[_hashIndex] = proposal;
		if (proposal.approved) {
			nameToIndex[proposal.name] = _hashIndex;
			symbolToIndex[proposal.symbol] = _hashIndex;
		}
		emit LogProposalImported(
			proposal.name,
			proposal.symbol,
			proposal.proposer,
			_hashIndex
		);
	}


	function setLegacyRegistryAddress(address _legacyRegistry)
		external
		onlyOwner
	{

		legacyRegistry = _legacyRegistry;
	}

	function legacyProposalsByIndex(bytes32 hashIndex)
		external
		view
		returns (Creator memory)
	{

		ILegacyRegistry legacy = ILegacyRegistry(legacyRegistry);
		ILegacyRegistry.Creator memory legacyCreator =
			legacy.rolodex(hashIndex);
		Creator memory creator =
			Creator({
				token: legacyCreator.token,
				name: legacyCreator.name,
				symbol: legacyCreator.symbol,
				decimals: legacyCreator.decimals,
				totalSupply: legacyCreator.totalSupply,
				proposer: legacyCreator.proposer,
				vestingBeneficiary: legacyCreator.vestingBeneficiary,
				initialPercentage: legacyCreator.initialPercentage,
				vestingPeriodInDays: legacyCreator.vestingPeriodInWeeks * 7,
				approved: legacyCreator.approved,
				initialPlatformPercentage: 0
			});

		return creator;
	}

	function legacyProposals(string memory _name)
		external
		view
		returns (Creator memory)
	{

		ILegacyRegistry legacy = ILegacyRegistry(legacyRegistry);
		bytes32 hashIndex = legacy.getIndexSymbol(_name);
		return this.legacyProposalsByIndex(hashIndex);
	}
}