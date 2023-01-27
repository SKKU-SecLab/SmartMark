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
}pragma solidity ^0.5.0;

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
}// MPL-2.0
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

}pragma solidity 0.5.17;


contract UsingConfig {

	address private _config;

	constructor(address _addressConfig) public {
		_config = _addressConfig;
	}

	function config() internal view returns (IAddressConfig) {

		return IAddressConfig(_config);
	}

	function configAddress() external view returns (address) {

		return _config;
	}
}pragma solidity ^0.5.0;

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
}// MPL-2.0
pragma solidity >=0.5.17;

interface IProperty {

	function author() external view returns (address);


	function changeAuthor(address _nextAuthor) external;


	function changeName(string calldata _name) external;


	function changeSymbol(string calldata _symbol) external;


	function withdraw(address _sender, uint256 _value) external;

}// MPL-2.0
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


	function toDisable() external;

}// MPL-2.0
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

}// MPL-2.0
pragma solidity >=0.5.17;

interface IPolicy {

	function rewards(uint256 _lockups, uint256 _assets)
		external
		view
		returns (uint256);


	function holdersShare(uint256 _amount, uint256 _lockups)
		external
		view
		returns (uint256);


	function authenticationFee(uint256 _assets, uint256 _propertyAssets)
		external
		view
		returns (uint256);


	function marketVotingBlocks() external view returns (uint256);


	function policyVotingBlocks() external view returns (uint256);


	function shareOfTreasury(uint256 _supply) external view returns (uint256);


	function treasury() external view returns (address);


	function capSetter() external view returns (address);

}// MPL-2.0
pragma solidity >=0.5.17;

interface IMetrics {

	function market() external view returns (address);


	function property() external view returns (address);

}// MPL-2.0
pragma solidity >=0.5.17;

interface IMetricsFactory {

	function create(address _property) external returns (address);


	function destroy(address _metrics) external;

}// MPL-2.0
pragma solidity >=0.5.17;

interface IMetricsGroup {

	function addGroup(address _addr) external;


	function removeGroup(address _addr) external;


	function isGroup(address _addr) external view returns (bool);


	function totalIssuedMetrics() external view returns (uint256);


	function hasAssets(address _property) external view returns (bool);


	function getMetricsCountPerProperty(address _property)
		external
		view
		returns (uint256);


	function totalAuthenticatedProperties() external view returns (uint256);

}// MPL-2.0
pragma solidity >=0.5.17;

interface ILockup {

	function depositToProperty(address _property, uint256 _amount)
		external
		returns (uint256);


	function depositToPosition(uint256 _tokenId, uint256 _amount)
		external
		returns (bool);


	function lockup(
		address _from,
		address _property,
		uint256 _value
	) external;


	function update() external;


	function withdraw(address _property, uint256 _amount) external;


	function withdrawByPosition(uint256 _tokenId, uint256 _amount)
		external
		returns (bool);


	function calculateCumulativeRewardPrices()
		external
		view
		returns (
			uint256 _reward,
			uint256 _holders,
			uint256 _interest,
			uint256 _holdersCap
		);


	function calculateRewardAmount(address _property)
		external
		view
		returns (uint256, uint256);


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


	function calculateWithdrawableInterestAmountByPosition(uint256 _tokenId)
		external
		view
		returns (uint256);


	function cap() external view returns (uint256);


	function updateCap(uint256 _cap) external;


	function devMinter() external view returns (address);


	function sTokensManager() external view returns (address);


	function migrateToSTokens(address _property) external returns (uint256);

}// MPL-2.0
pragma solidity >=0.5.17;

interface IDev {

	function deposit(address _to, uint256 _amount) external returns (bool);


	function depositFrom(
		address _from,
		address _to,
		uint256 _amount
	) external returns (bool);


	function fee(address _from, uint256 _amount) external returns (bool);

}pragma solidity 0.5.17;


contract Market is UsingConfig, IMarket {

	using SafeMath for uint256;
	bool public enabled;
	address public behavior;
	uint256 public votingEndBlockNumber;
	uint256 public issuedMetrics;
	mapping(bytes32 => bool) private idMap;
	mapping(address => bytes32) private idHashMetricsMap;

	constructor(address _config, address _behavior)
		public
		UsingConfig(_config)
	{
		require(
			msg.sender == config().marketFactory(),
			"this is illegal address"
		);

		behavior = _behavior;

		enabled = false;

		uint256 marketVotingBlocks = IPolicy(config().policy())
			.marketVotingBlocks();
		votingEndBlockNumber = block.number.add(marketVotingBlocks);
	}

	function propertyValidation(address _prop) private view {

		require(
			msg.sender == IProperty(_prop).author(),
			"this is illegal address"
		);
		require(enabled, "market is not enabled");
	}

	modifier onlyPropertyAuthor(address _prop) {

		propertyValidation(_prop);
		_;
	}

	modifier onlyLinkedPropertyAuthor(address _metrics) {

		address _prop = IMetrics(_metrics).property();
		propertyValidation(_prop);
		_;
	}

	function toEnable() external {

		require(msg.sender == config().marketFactory(), "illegal accesss");
		require(isDuringVotingPeriod(), "deadline is over");
		enabled = true;
	}

	function toDisable() external {

		require(msg.sender == config().marketFactory(), "illegal accesss");
		enabled = false;
	}

	function authenticate(
		address _prop,
		string memory _args1,
		string memory _args2,
		string memory _args3,
		string memory _args4,
		string memory _args5
	) public onlyPropertyAuthor(_prop) returns (bool) {

		return
			_authenticate(
				_prop,
				msg.sender,
				_args1,
				_args2,
				_args3,
				_args4,
				_args5
			);
	}

	function authenticateFromPropertyFactory(
		address _prop,
		address _author,
		string calldata _args1,
		string calldata _args2,
		string calldata _args3,
		string calldata _args4,
		string calldata _args5
	) external returns (bool) {

		require(
			msg.sender == config().propertyFactory(),
			"this is illegal address"
		);

		require(enabled, "market is not enabled");

		return
			_authenticate(
				_prop,
				_author,
				_args1,
				_args2,
				_args3,
				_args4,
				_args5
			);
	}

	function _authenticate(
		address _prop,
		address _author,
		string memory _args1,
		string memory _args2,
		string memory _args3,
		string memory _args4,
		string memory _args5
	) private returns (bool) {

		require(bytes(_args1).length > 0, "id is required");

		return
			IMarketBehavior(behavior).authenticate(
				_prop,
				_args1,
				_args2,
				_args3,
				_args4,
				_args5,
				address(this),
				_author
			);
	}

	function getAuthenticationFee(address _property)
		private
		view
		returns (uint256)
	{

		uint256 tokenValue = ILockup(config().lockup()).getPropertyValue(
			_property
		);
		IPolicy policy = IPolicy(config().policy());
		IMetricsGroup metricsGroup = IMetricsGroup(config().metricsGroup());
		return
			policy.authenticationFee(
				metricsGroup.totalIssuedMetrics(),
				tokenValue
			);
	}

	function authenticatedCallback(address _property, bytes32 _idHash)
		external
		returns (address)
	{

		require(msg.sender == behavior, "this is illegal address");
		require(enabled, "market is not enabled");

		require(idMap[_idHash] == false, "id is duplicated");
		idMap[_idHash] = true;

		address sender = IProperty(_property).author();

		IMetricsFactory metricsFactory = IMetricsFactory(
			config().metricsFactory()
		);
		address metrics = metricsFactory.create(_property);
		idHashMetricsMap[metrics] = _idHash;

		uint256 authenticationFee = getAuthenticationFee(_property);
		require(
			IDev(config().token()).fee(sender, authenticationFee),
			"dev fee failed"
		);

		issuedMetrics = issuedMetrics.add(1);
		return metrics;
	}

	function deauthenticate(address _metrics)
		external
		onlyLinkedPropertyAuthor(_metrics)
	{

		bytes32 idHash = idHashMetricsMap[_metrics];
		require(idMap[idHash], "not authenticated");

		idMap[idHash] = false;
		idHashMetricsMap[_metrics] = bytes32(0);

		IMetricsFactory metricsFactory = IMetricsFactory(
			config().metricsFactory()
		);
		metricsFactory.destroy(_metrics);

		issuedMetrics = issuedMetrics.sub(1);
	}

	function schema() external view returns (string memory) {

		return IMarketBehavior(behavior).schema();
	}

	function isDuringVotingPeriod() private view returns (bool) {

		return block.number < votingEndBlockNumber;
	}
}// MPL-2.0
pragma solidity >=0.5.17;

interface IMarketFactory {

	function create(address _addr) external returns (address);


	function enable(address _addr) external;


	function disable(address _addr) external;

}// MPL-2.0
pragma solidity >=0.5.17;

interface IMarketGroup {

	function addGroup(address _addr) external;


	function deleteGroup(address _addr) external;


	function isGroup(address _addr) external view returns (bool);


	function getCount() external view returns (uint256);

}pragma solidity 0.5.17;


contract MarketFactory is Ownable, IMarketFactory, UsingConfig {

	event Create(address indexed _from, address _market);

	constructor(address _config) public UsingConfig(_config) {}

	function create(address _addr) external returns (address) {

		require(_addr != address(0), "this is illegal address");

		Market market = new Market(address(config()), _addr);

		address marketAddr = address(market);
		IMarketGroup marketGroup = IMarketGroup(config().marketGroup());
		marketGroup.addGroup(marketAddr);

		if (marketGroup.getCount() == 1) {
			market.toEnable();
		}

		emit Create(msg.sender, marketAddr);
		return marketAddr;
	}

	function enable(address _addr) external onlyOwner {

		IMarketGroup marketGroup = IMarketGroup(config().marketGroup());
		require(marketGroup.isGroup(_addr), "illegal address");

		IMarket market = IMarket(_addr);
		require(market.enabled() == false, "already enabled");

		market.toEnable();
	}

	function disable(address _addr) external onlyOwner {

		IMarketGroup marketGroup = IMarketGroup(config().marketGroup());
		require(marketGroup.isGroup(_addr), "illegal address");

		IMarket market = IMarket(_addr);
		require(market.enabled() == true, "already disabled");

		market.toDisable();
		marketGroup.deleteGroup(_addr);
	}
}