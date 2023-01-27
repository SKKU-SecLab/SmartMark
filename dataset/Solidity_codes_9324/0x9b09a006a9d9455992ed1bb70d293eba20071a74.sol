



pragma solidity ^0.8.0;



abstract contract Initializable {
    bool private _initialized;

    bool private _initializing;

    modifier initializer() {
        require(_initializing || !_initialized, "Initializable: contract is already initialized");

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
}







abstract contract ContextUpgradeable is Initializable {
    function __Context_init() internal initializer {
        __Context_init_unchained();
    }

    function __Context_init_unchained() internal initializer {
    }
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
    uint256[50] private __gap;
}







interface Avatar {

	function nativeToken() external view returns (address);


	function nativeReputation() external view returns (address);


	function owner() external view returns (address);

}

interface Controller {

	event RegisterScheme(address indexed _sender, address indexed _scheme);
	event UnregisterScheme(address indexed _sender, address indexed _scheme);

	function genericCall(
		address _contract,
		bytes calldata _data,
		address _avatar,
		uint256 _value
	) external returns (bool, bytes memory);


	function avatar() external view returns (address);


	function unregisterScheme(address _scheme, address _avatar)
		external
		returns (bool);


	function unregisterSelf(address _avatar) external returns (bool);


	function registerScheme(
		address _scheme,
		bytes32 _paramsHash,
		bytes4 _permissions,
		address _avatar
	) external returns (bool);


	function isSchemeRegistered(address _scheme, address _avatar)
		external
		view
		returns (bool);


	function getSchemePermissions(address _scheme, address _avatar)
		external
		view
		returns (bytes4);


	function addGlobalConstraint(
		address _constraint,
		bytes32 _paramHash,
		address _avatar
	) external returns (bool);


	function mintTokens(
		uint256 _amount,
		address _beneficiary,
		address _avatar
	) external returns (bool);


	function externalTokenTransfer(
		address _token,
		address _recipient,
		uint256 _amount,
		address _avatar
	) external returns (bool);


	function sendEther(
		uint256 _amountInWei,
		address payable _to,
		address _avatar
	) external returns (bool);

}

interface GlobalConstraintInterface {

	enum CallPhase {
		Pre,
		Post,
		PreAndPost
	}

	function pre(
		address _scheme,
		bytes32 _params,
		bytes32 _method
	) external returns (bool);


	function when() external returns (CallPhase);

}

interface ReputationInterface {

	function balanceOf(address _user) external view returns (uint256);


	function balanceOfAt(address _user, uint256 _blockNumber)
		external
		view
		returns (uint256);


	function getVotes(address _user) external view returns (uint256);


	function getVotesAt(
		address _user,
		bool _global,
		uint256 _blockNumber
	) external view returns (uint256);


	function totalSupply() external view returns (uint256);


	function totalSupplyAt(uint256 _blockNumber)
		external
		view
		returns (uint256);


	function delegateOf(address _user) external returns (address);

}

interface SchemeRegistrar {

	function proposeScheme(
		Avatar _avatar,
		address _scheme,
		bytes32 _parametersHash,
		bytes4 _permissions,
		string memory _descriptionHash
	) external returns (bytes32);


	event NewSchemeProposal(
		address indexed _avatar,
		bytes32 indexed _proposalId,
		address indexed _intVoteInterface,
		address _scheme,
		bytes32 _parametersHash,
		bytes4 _permissions,
		string _descriptionHash
	);
}

interface IntVoteInterface {

	event NewProposal(
		bytes32 indexed _proposalId,
		address indexed _organization,
		uint256 _numOfChoices,
		address _proposer,
		bytes32 _paramsHash
	);

	event ExecuteProposal(
		bytes32 indexed _proposalId,
		address indexed _organization,
		uint256 _decision,
		uint256 _totalReputation
	);

	event VoteProposal(
		bytes32 indexed _proposalId,
		address indexed _organization,
		address indexed _voter,
		uint256 _vote,
		uint256 _reputation
	);

	event CancelProposal(
		bytes32 indexed _proposalId,
		address indexed _organization
	);
	event CancelVoting(
		bytes32 indexed _proposalId,
		address indexed _organization,
		address indexed _voter
	);

	function propose(
		uint256 _numOfChoices,
		bytes32 _proposalParameters,
		address _proposer,
		address _organization
	) external returns (bytes32);


	function vote(
		bytes32 _proposalId,
		uint256 _vote,
		uint256 _rep,
		address _voter
	) external returns (bool);


	function cancelVote(bytes32 _proposalId) external;


	function getNumberOfChoices(bytes32 _proposalId)
		external
		view
		returns (uint256);


	function isVotable(bytes32 _proposalId) external view returns (bool);


	function voteStatus(bytes32 _proposalId, uint256 _choice)
		external
		view
		returns (uint256);


	function isAbstainAllow() external pure returns (bool);


	function getAllowedRangeOfChoices()
		external
		pure
		returns (uint256 min, uint256 max);

}







interface IBeaconUpgradeable {

    function implementation() external view returns (address);

}







library AddressUpgradeable {

    function isContract(address account) internal view returns (bool) {


        uint256 size;
        assembly {
            size := extcodesize(account)
        }
        return size > 0;
    }

    function sendValue(address payable recipient, uint256 amount) internal {

        require(address(this).balance >= amount, "Address: insufficient balance");

        (bool success, ) = recipient.call{value: amount}("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    function functionCall(address target, bytes memory data) internal returns (bytes memory) {

        return functionCall(target, data, "Address: low-level call failed");
    }

    function functionCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {

        return functionCallWithValue(target, data, 0, errorMessage);
    }

    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value
    ) internal returns (bytes memory) {

        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value,
        string memory errorMessage
    ) internal returns (bytes memory) {

        require(address(this).balance >= value, "Address: insufficient balance for call");
        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{value: value}(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {

        return functionStaticCall(target, data, "Address: low-level static call failed");
    }

    function functionStaticCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal view returns (bytes memory) {

        require(isContract(target), "Address: static call to non-contract");

        (bool success, bytes memory returndata) = target.staticcall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    function verifyCallResult(
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) internal pure returns (bytes memory) {

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







library StorageSlotUpgradeable {

    struct AddressSlot {
        address value;
    }

    struct BooleanSlot {
        bool value;
    }

    struct Bytes32Slot {
        bytes32 value;
    }

    struct Uint256Slot {
        uint256 value;
    }

    function getAddressSlot(bytes32 slot) internal pure returns (AddressSlot storage r) {

        assembly {
            r.slot := slot
        }
    }

    function getBooleanSlot(bytes32 slot) internal pure returns (BooleanSlot storage r) {

        assembly {
            r.slot := slot
        }
    }

    function getBytes32Slot(bytes32 slot) internal pure returns (Bytes32Slot storage r) {

        assembly {
            r.slot := slot
        }
    }

    function getUint256Slot(bytes32 slot) internal pure returns (Uint256Slot storage r) {

        assembly {
            r.slot := slot
        }
    }
}










abstract contract ERC1967UpgradeUpgradeable is Initializable {
    function __ERC1967Upgrade_init() internal initializer {
        __ERC1967Upgrade_init_unchained();
    }

    function __ERC1967Upgrade_init_unchained() internal initializer {
    }
    bytes32 private constant _ROLLBACK_SLOT = 0x4910fdfa16fed3260ed0e7147f7cc6da11a60208b5b9406d12a635614ffd9143;

    bytes32 internal constant _IMPLEMENTATION_SLOT = 0x360894a13ba1a3210667c828492db98dca3e2076cc3735a920a3ca505d382bbc;

    event Upgraded(address indexed implementation);

    function _getImplementation() internal view returns (address) {
        return StorageSlotUpgradeable.getAddressSlot(_IMPLEMENTATION_SLOT).value;
    }

    function _setImplementation(address newImplementation) private {
        require(AddressUpgradeable.isContract(newImplementation), "ERC1967: new implementation is not a contract");
        StorageSlotUpgradeable.getAddressSlot(_IMPLEMENTATION_SLOT).value = newImplementation;
    }

    function _upgradeTo(address newImplementation) internal {
        _setImplementation(newImplementation);
        emit Upgraded(newImplementation);
    }

    function _upgradeToAndCall(
        address newImplementation,
        bytes memory data,
        bool forceCall
    ) internal {
        _upgradeTo(newImplementation);
        if (data.length > 0 || forceCall) {
            _functionDelegateCall(newImplementation, data);
        }
    }

    function _upgradeToAndCallSecure(
        address newImplementation,
        bytes memory data,
        bool forceCall
    ) internal {
        address oldImplementation = _getImplementation();

        _setImplementation(newImplementation);
        if (data.length > 0 || forceCall) {
            _functionDelegateCall(newImplementation, data);
        }

        StorageSlotUpgradeable.BooleanSlot storage rollbackTesting = StorageSlotUpgradeable.getBooleanSlot(_ROLLBACK_SLOT);
        if (!rollbackTesting.value) {
            rollbackTesting.value = true;
            _functionDelegateCall(
                newImplementation,
                abi.encodeWithSignature("upgradeTo(address)", oldImplementation)
            );
            rollbackTesting.value = false;
            require(oldImplementation == _getImplementation(), "ERC1967Upgrade: upgrade breaks further upgrades");
            _upgradeTo(newImplementation);
        }
    }

    bytes32 internal constant _ADMIN_SLOT = 0xb53127684a568b3173ae13b9f8a6016e243e63b6e8ee1178d6a717850b5d6103;

    event AdminChanged(address previousAdmin, address newAdmin);

    function _getAdmin() internal view returns (address) {
        return StorageSlotUpgradeable.getAddressSlot(_ADMIN_SLOT).value;
    }

    function _setAdmin(address newAdmin) private {
        require(newAdmin != address(0), "ERC1967: new admin is the zero address");
        StorageSlotUpgradeable.getAddressSlot(_ADMIN_SLOT).value = newAdmin;
    }

    function _changeAdmin(address newAdmin) internal {
        emit AdminChanged(_getAdmin(), newAdmin);
        _setAdmin(newAdmin);
    }

    bytes32 internal constant _BEACON_SLOT = 0xa3f0ad74e5423aebfd80d3ef4346578335a9a72aeaee59ff6cb3582b35133d50;

    event BeaconUpgraded(address indexed beacon);

    function _getBeacon() internal view returns (address) {
        return StorageSlotUpgradeable.getAddressSlot(_BEACON_SLOT).value;
    }

    function _setBeacon(address newBeacon) private {
        require(AddressUpgradeable.isContract(newBeacon), "ERC1967: new beacon is not a contract");
        require(
            AddressUpgradeable.isContract(IBeaconUpgradeable(newBeacon).implementation()),
            "ERC1967: beacon implementation is not a contract"
        );
        StorageSlotUpgradeable.getAddressSlot(_BEACON_SLOT).value = newBeacon;
    }

    function _upgradeBeaconToAndCall(
        address newBeacon,
        bytes memory data,
        bool forceCall
    ) internal {
        _setBeacon(newBeacon);
        emit BeaconUpgraded(newBeacon);
        if (data.length > 0 || forceCall) {
            _functionDelegateCall(IBeaconUpgradeable(newBeacon).implementation(), data);
        }
    }

    function _functionDelegateCall(address target, bytes memory data) private returns (bytes memory) {
        require(AddressUpgradeable.isContract(target), "Address: delegate call to non-contract");

        (bool success, bytes memory returndata) = target.delegatecall(data);
        return AddressUpgradeable.verifyCallResult(success, returndata, "Address: low-level delegate call failed");
    }
    uint256[50] private __gap;
}








abstract contract UUPSUpgradeable is Initializable, ERC1967UpgradeUpgradeable {
    function __UUPSUpgradeable_init() internal initializer {
        __ERC1967Upgrade_init_unchained();
        __UUPSUpgradeable_init_unchained();
    }

    function __UUPSUpgradeable_init_unchained() internal initializer {
    }
    address private immutable __self = address(this);

    modifier onlyProxy() {
        require(address(this) != __self, "Function must be called through delegatecall");
        require(_getImplementation() == __self, "Function must be called through active proxy");
        _;
    }

    function upgradeTo(address newImplementation) external virtual onlyProxy {
        _authorizeUpgrade(newImplementation);
        _upgradeToAndCallSecure(newImplementation, new bytes(0), false);
    }

    function upgradeToAndCall(address newImplementation, bytes memory data) external payable virtual onlyProxy {
        _authorizeUpgrade(newImplementation);
        _upgradeToAndCallSecure(newImplementation, data, true);
    }

    function _authorizeUpgrade(address newImplementation) internal virtual;
    uint256[50] private __gap;
}






library DataTypes {

	struct ReserveData {
		ReserveConfigurationMap configuration;
		uint128 liquidityIndex;
		uint128 variableBorrowIndex;
		uint128 currentLiquidityRate;
		uint128 currentVariableBorrowRate;
		uint128 currentStableBorrowRate;
		uint40 lastUpdateTimestamp;
		address aTokenAddress;
		address stableDebtTokenAddress;
		address variableDebtTokenAddress;
		address interestRateStrategyAddress;
		uint8 id;
	}

	struct ReserveConfigurationMap {
		uint256 data;
	}
	enum InterestRateMode { NONE, STABLE, VARIABLE }
}







pragma experimental ABIEncoderV2;

interface ERC20 {

	function balanceOf(address addr) external view returns (uint256);


	function transfer(address to, uint256 amount) external returns (bool);


	function approve(address spender, uint256 amount) external returns (bool);


	function decimals() external view returns (uint8);


	function mint(address to, uint256 mintAmount) external returns (uint256);


	function totalSupply() external view returns (uint256);


	function allowance(address owner, address spender)
		external
		view
		returns (uint256);


	function transferFrom(
		address sender,
		address recipient,
		uint256 amount
	) external returns (bool);


	function name() external view returns (string memory);


	function symbol() external view returns (string memory);


	event Transfer(address indexed from, address indexed to, uint256 amount);
	event Transfer(
		address indexed from,
		address indexed to,
		uint256 amount,
		bytes data
	);
}

interface cERC20 is ERC20 {

	function mint(uint256 mintAmount) external returns (uint256);


	function redeemUnderlying(uint256 mintAmount) external returns (uint256);


	function redeem(uint256 mintAmount) external returns (uint256);


	function exchangeRateCurrent() external returns (uint256);


	function exchangeRateStored() external view returns (uint256);


	function underlying() external returns (address);

}

interface IGoodDollar is ERC20 {

	function getFees(uint256 value) external view returns (uint256, bool);


	function burn(uint256 amount) external;


	function burnFrom(address account, uint256 amount) external;


	function renounceMinter() external;


	function addMinter(address minter) external;


	function isMinter(address minter) external view returns (bool);


	function transferAndCall(
		address to,
		uint256 value,
		bytes calldata data
	) external returns (bool);


	function formula() external view returns (address);

}

interface IERC2917 is ERC20 {

	event InterestRatePerBlockChanged(uint256 oldValue, uint256 newValue);

	event ProductivityIncreased(address indexed user, uint256 value);

	event ProductivityDecreased(address indexed user, uint256 value);

	function interestsPerBlock() external view returns (uint256);


	function changeInterestRatePerBlock(uint256 value) external returns (bool);


	function getProductivity(address user)
		external
		view
		returns (uint256, uint256);


	function increaseProductivity(address user, uint256 value)
		external
		returns (bool);


	function decreaseProductivity(address user, uint256 value)
		external
		returns (bool);


	function take() external view returns (uint256);


	function takeWithBlock() external view returns (uint256, uint256);


	function mint() external returns (uint256);

}

interface Staking {

	struct Staker {
		uint256 stakedDAI;
		uint256 lastStake;
	}

	function stakeDAI(uint256 amount) external;


	function withdrawStake() external;


	function stakers(address staker) external view returns (Staker memory);

}

interface Uniswap {

	function swapExactETHForTokens(
		uint256 amountOutMin,
		address[] calldata path,
		address to,
		uint256 deadline
	) external payable returns (uint256[] memory amounts);


	function swapExactTokensForETH(
		uint256 amountIn,
		uint256 amountOutMin,
		address[] calldata path,
		address to,
		uint256 deadline
	) external returns (uint256[] memory amounts);


	function swapExactTokensForTokens(
		uint256 amountIn,
		uint256 amountOutMin,
		address[] calldata path,
		address to,
		uint256 deadline
	) external returns (uint256[] memory amounts);


	function WETH() external pure returns (address);


	function factory() external pure returns (address);


	function quote(
		uint256 amountA,
		uint256 reserveA,
		uint256 reserveB
	) external pure returns (uint256 amountB);


	function getAmountIn(
		uint256 amountOut,
		uint256 reserveIn,
		uint256 reserveOut
	) external pure returns (uint256 amountIn);


	function getAmountOut(
		uint256 amountI,
		uint256 reserveIn,
		uint256 reserveOut
	) external pure returns (uint256 amountOut);


	function getAmountsOut(uint256 amountIn, address[] memory path)
		external
		pure
		returns (uint256[] memory amounts);

}

interface UniswapFactory {

	function getPair(address tokenA, address tokenB)
		external
		view
		returns (address);

}

interface UniswapPair {

	function getReserves()
		external
		view
		returns (
			uint112 reserve0,
			uint112 reserve1,
			uint32 blockTimestampLast
		);


	function kLast() external view returns (uint256);


	function token0() external view returns (address);


	function token1() external view returns (address);


	function totalSupply() external view returns (uint256);


	function balanceOf(address owner) external view returns (uint256);

}

interface Reserve {

	function buy(
		address _buyWith,
		uint256 _tokenAmount,
		uint256 _minReturn
	) external returns (uint256);

}

interface IIdentity {

	function isWhitelisted(address user) external view returns (bool);


	function addWhitelistedWithDID(address account, string memory did) external;


	function removeWhitelisted(address account) external;


	function addIdentityAdmin(address account) external returns (bool);


	function setAvatar(address _avatar) external;


	function isIdentityAdmin(address account) external view returns (bool);


	function owner() external view returns (address);


	event WhitelistedAdded(address user);
}

interface IUBIScheme {

	function currentDay() external view returns (uint256);


	function periodStart() external view returns (uint256);


	function hasClaimed(address claimer) external view returns (bool);

}

interface IFirstClaimPool {

	function awardUser(address user) external returns (uint256);


	function claimAmount() external view returns (uint256);

}

interface ProxyAdmin {

	function getProxyImplementation(address proxy)
		external
		view
		returns (address);


	function getProxyAdmin(address proxy) external view returns (address);


	function upgrade(address proxy, address implementation) external;


	function owner() external view returns (address);


	function transferOwnership(address newOwner) external;

}

interface AggregatorV3Interface {

	function decimals() external view returns (uint8);


	function description() external view returns (string memory);


	function version() external view returns (uint256);


	function getRoundData(uint80 _roundId)
		external
		view
		returns (
			uint80 roundId,
			int256 answer,
			uint256 startedAt,
			uint256 updatedAt,
			uint80 answeredInRound
		);


	function latestAnswer() external view returns (int256);

}

interface ILendingPool {

	function deposit(
		address asset,
		uint256 amount,
		address onBehalfOf,
		uint16 referralCode
	) external;


	function withdraw(
		address asset,
		uint256 amount,
		address to
	) external returns (uint256);


	function getReserveData(address asset)
		external
		view
		returns (DataTypes.ReserveData memory);

}

interface IDonationStaking {

	function stakeDonations() external payable;

}

interface INameService {

	function getAddress(string memory _name) external view returns (address);

}

interface IAaveIncentivesController {

	function claimRewards(
		address[] calldata assets,
		uint256 amount,
		address to
	) external returns (uint256);


	function getRewardsBalance(address[] calldata assets, address user)
		external
		view
		returns (uint256);

}

interface IGoodStaking {

	function collectUBIInterest(address recipient)
		external
		returns (
			uint256,
			uint256,
			uint256
		);


	function iToken() external view returns (address);


	function currentGains(
		bool _returnTokenBalanceInUSD,
		bool _returnTokenGainsInUSD
	)
		external
		view
		returns (
			uint256,
			uint256,
			uint256,
			uint256,
			uint256
		);


	function getRewardEarned(address user) external view returns (uint256);


	function getGasCostForInterestTransfer() external view returns (uint256);


	function rewardsMinted(
		address user,
		uint256 rewardsPerBlock,
		uint256 blockStart,
		uint256 blockEnd
	) external returns (uint256);

}

interface IHasRouter {

	function getRouter() external view returns (Uniswap);

}

interface IAdminWallet {

	function addAdmins(address payable[] memory _admins) external;


	function removeAdmins(address[] memory _admins) external;


	function owner() external view returns (address);


	function transferOwnership(address _owner) external;

}









contract DAOContract {

	Controller public dao;

	address public avatar;

	INameService public nameService;

	function _onlyAvatar() internal view {

		require(
			address(dao.avatar()) == msg.sender,
			"only avatar can call this method"
		);
	}

	function setDAO(INameService _ns) internal {

		nameService = _ns;
		updateAvatar();
	}

	function updateAvatar() public {

		dao = Controller(nameService.getAddress("CONTROLLER"));
		avatar = dao.avatar();
	}

	function nativeToken() public view returns (IGoodDollar) {

		return IGoodDollar(nameService.getAddress("GOODDOLLAR"));
	}

	uint256[50] private gap;
}









contract DAOUpgradeableContract is Initializable, UUPSUpgradeable, DAOContract {

	function _authorizeUpgrade(address) internal virtual override {

		_onlyAvatar();
	}
}







contract CompoundVotingMachine is ContextUpgradeable, DAOUpgradeableContract {

	string public constant name = "GoodDAO Voting Machine";

	uint64 public foundationGuardianRelease;

	uint256 public votingPeriod;

	uint256 public quoromPercentage;

	function quorumVotes() public view returns (uint256) {

		return (rep.totalSupply() * quoromPercentage) / 1000000;
	} //3%

	uint256 public proposalPercentage;

	function proposalThreshold(uint256 blockNumber)
		public
		view
		returns (uint256)
	{

		return (rep.totalSupplyAt(blockNumber) * proposalPercentage) / 1000000; //0.25%
	}

	uint256 public proposalMaxOperations; //10

	uint256 public votingDelay; //1 block

	uint256 public queuePeriod; // 2 days

	uint256 public fastQueuePeriod; //1 days/8 = 3hours

	uint256 public gameChangerPeriod; //1 day

	uint256 public gracePeriod; // 3days

	ReputationInterface public rep;

	address public guardian;

	uint256 public proposalCount;

	struct Proposal {
		uint256 id;
		address proposer;
		uint256 eta;
		address[] targets;
		uint256[] values;
		string[] signatures;
		bytes[] calldatas;
		uint256 startBlock;
		uint256 endBlock;
		uint256 forVotes;
		uint256 againstVotes;
		bool canceled;
		bool executed;
		mapping(address => Receipt) receipts;
		uint256 quoromRequired;
		uint256 forBlockchain;
	}

	struct Receipt {
		bool hasVoted;
		bool support;
		uint256 votes;
	}

	enum ProposalState {
		Pending,
		Active,
		ActiveTimelock, // passed quorom, time lock of 2 days activated, still open for voting
		Canceled,
		Defeated,
		Succeeded,
		Expired,
		Executed
	}

	mapping(uint256 => Proposal) public proposals;

	mapping(address => uint256) public latestProposalIds;

	bytes32 public constant DOMAIN_TYPEHASH =
		keccak256(
			"EIP712Domain(string name,uint256 chainId,address verifyingContract)"
		);

	bytes32 public constant BALLOT_TYPEHASH =
		keccak256("Ballot(uint256 proposalId,bool support)");

	event ProposalCreated(
		uint256 id,
		address proposer,
		address[] targets,
		uint256[] values,
		string[] signatures,
		bytes[] calldatas,
		uint256 startBlock,
		uint256 endBlock,
		string description
	);

	event ProposalSucceeded(
		uint256 id,
		address proposer,
		address[] targets,
		uint256[] values,
		string[] signatures,
		bytes[] calldatas,
		uint256 startBlock,
		uint256 endBlock,
		uint256 forBlockchain,
		uint256 eta,
		uint256 forVotes,
		uint256 againstVotes
	);

	event ProposalBridge(uint256 id, uint256 indexed forBlockchain);

	event VoteCast(
		address voter,
		uint256 proposalId,
		bool support,
		uint256 votes
	);

	event ProposalCanceled(uint256 id);

	event ProposalQueued(uint256 id, uint256 eta);

	event ProposalExecuted(uint256 id);

	event ProposalExecutionResult(
		uint256 id,
		uint256 index,
		bool ok,
		bytes result
	);

	event GuardianSet(address newGuardian);

	event ParametersSet(uint256[9] params);

	function initialize(
		INameService ns_, // the DAO avatar
		uint256 votingPeriodBlocks_, //number of blocks a proposal is open for voting before expiring
		address guardian_
	) public initializer {

		foundationGuardianRelease = 1672531200; //01/01/2023
		setDAO(ns_);
		rep = ReputationInterface(ns_.getAddress("REPUTATION"));
		uint256[9] memory params = [
			votingPeriodBlocks_,
			30000, //3% quorum
			2500, //0.25% proposing threshold
			10, //max operations
			1, //voting delay blocks
			2 days, //queue period
			1 days / 8, //fast queue period
			1 days, //game change period
			3 days //grace period
		];
		_setVotingParameters(params);
		guardian = guardian_;
	}

	function fixGuardian(address _guardian) public {

		if (guardian == address(0x4659176E962763e7C8A4eF965ecfD0fdf9f52057)) {
			guardian = _guardian;
		}
	}

	function setVotingParameters(uint256[9] calldata _newParams) external {

		_onlyAvatar();
		_setVotingParameters(_newParams);
	}

	function _setVotingParameters(uint256[9] memory _newParams) internal {

		require(
			(quoromPercentage == 0 || _newParams[1] <= quoromPercentage * 2) &&
				_newParams[1] < 1000000,
			"percentage should not double"
		);
		require(
			(proposalPercentage == 0 || _newParams[2] <= proposalPercentage * 2) &&
				_newParams[2] < 1000000,
			"percentage should not double"
		);
		votingPeriod = _newParams[0] > 0 ? _newParams[0] : votingPeriod;
		quoromPercentage = _newParams[1] > 0 ? _newParams[1] : quoromPercentage;
		proposalPercentage = _newParams[2] > 0 ? _newParams[2] : proposalPercentage;
		proposalMaxOperations = _newParams[3] > 0
			? _newParams[3]
			: proposalMaxOperations;
		votingDelay = _newParams[4] > 0 ? _newParams[4] : votingDelay;
		queuePeriod = _newParams[5] > 0 ? _newParams[5] : queuePeriod;
		fastQueuePeriod = _newParams[6] > 0 ? _newParams[6] : fastQueuePeriod;
		gameChangerPeriod = _newParams[7] > 0 ? _newParams[7] : gameChangerPeriod;
		gracePeriod = _newParams[8] > 0 ? _newParams[8] : gracePeriod;

		emit ParametersSet(_newParams);
	}

	function propose(
		address[] memory targets,
		uint256[] memory values,
		string[] memory signatures,
		bytes[] memory calldatas,
		string memory description
	) public returns (uint256) {

		return
			propose(
				targets,
				values,
				signatures,
				calldatas,
				description,
				getChainId()
			);
	}

	function propose(
		address[] memory targets,
		uint256[] memory values,
		string[] memory signatures,
		bytes[] memory calldatas,
		string memory description,
		uint256 forBlockchain
	) public returns (uint256) {

		require(
			rep.getVotesAt(_msgSender(), true, block.number - 1) >
				proposalThreshold(block.number - 1),
			"CompoundVotingMachine::propose: proposer votes below proposal threshold"
		);
		require(
			targets.length == values.length &&
				targets.length == signatures.length &&
				targets.length == calldatas.length,
			"CompoundVotingMachine::propose: proposal function information arity mismatch"
		);
		require(
			targets.length != 0,
			"CompoundVotingMachine::propose: must provide actions"
		);
		require(
			targets.length <= proposalMaxOperations,
			"CompoundVotingMachine::propose: too many actions"
		);

		uint256 latestProposalId = latestProposalIds[_msgSender()];

		if (latestProposalId != 0) {
			ProposalState proposersLatestProposalState = state(latestProposalId);
			require(
				proposersLatestProposalState != ProposalState.Active &&
					proposersLatestProposalState != ProposalState.ActiveTimelock,
				"CompoundVotingMachine::propose: one live proposal per proposer, found an already active proposal"
			);
			require(
				proposersLatestProposalState != ProposalState.Pending,
				"CompoundVotingMachine::propose: one live proposal per proposer, found an already pending proposal"
			);
		}

		uint256 startBlock = block.number + votingDelay;
		uint256 endBlock = startBlock + votingPeriod;

		proposalCount++;
		Proposal storage newProposal = proposals[proposalCount];
		newProposal.id = proposalCount;
		newProposal.proposer = _msgSender();
		newProposal.eta = 0;
		newProposal.targets = targets;
		newProposal.values = values;
		newProposal.signatures = signatures;
		newProposal.calldatas = calldatas;
		newProposal.startBlock = startBlock;
		newProposal.endBlock = endBlock;
		newProposal.forVotes = 0;
		newProposal.againstVotes = 0;
		newProposal.canceled = false;
		newProposal.executed = false;
		newProposal.quoromRequired = quorumVotes();
		newProposal.forBlockchain = forBlockchain;
		latestProposalIds[newProposal.proposer] = newProposal.id;

		emit ProposalCreated(
			newProposal.id,
			_msgSender(),
			targets,
			values,
			signatures,
			calldatas,
			startBlock,
			endBlock,
			description
		);

		if (getChainId() != forBlockchain) {
			emit ProposalBridge(proposalCount, forBlockchain);
		}

		return newProposal.id;
	}

	function _updateETA(Proposal storage proposal, bool hasVoteChanged) internal {

		if (proposal.forVotes > rep.totalSupplyAt(proposal.startBlock) / 2) {
			proposal.eta = block.timestamp + fastQueuePeriod;
		}
		else if (proposal.eta == 0) {
			proposal.eta = block.timestamp + queuePeriod;
		}
		else if (hasVoteChanged) {
			uint256 timeLeft = proposal.eta - block.timestamp;
			proposal.eta += timeLeft > gameChangerPeriod
				? 0
				: gameChangerPeriod - timeLeft;
		} else {
			return;
		}
		emit ProposalQueued(proposal.id, proposal.eta);
	}

	function execute(uint256 proposalId) public payable {

		require(
			state(proposalId) == ProposalState.Succeeded,
			"CompoundVotingMachine::execute: proposal can only be executed if it is succeeded"
		);

		require(
			proposals[proposalId].forBlockchain == getChainId(),
			"CompoundVotingMachine::execute: proposal for wrong blockchain"
		);

		proposals[proposalId].executed = true;
		address[] memory _targets = proposals[proposalId].targets;
		uint256[] memory _values = proposals[proposalId].values;
		string[] memory _signatures = proposals[proposalId].signatures;
		bytes[] memory _calldatas = proposals[proposalId].calldatas;

		for (uint256 i = 0; i < _targets.length; i++) {
			(bool ok, bytes memory result) = _executeTransaction(
				_targets[i],
				_values[i],
				_signatures[i],
				_calldatas[i]
			);
			emit ProposalExecutionResult(proposalId, i, ok, result);
		}
		emit ProposalExecuted(proposalId);
	}

	function _executeTransaction(
		address target,
		uint256 value,
		string memory signature,
		bytes memory data
	) internal returns (bool, bytes memory) {

		bytes memory callData;

		if (bytes(signature).length == 0) {
			callData = data;
		} else {
			callData = abi.encodePacked(bytes4(keccak256(bytes(signature))), data);
		}

		bool ok;
		bytes memory result;

		if (target == address(dao)) {
			(ok, result) = target.call{ value: value }(callData);
		} else {
			if (value > 0) payable(address(avatar)).transfer(value); //make sure avatar have the funds to pay
			(ok, result) = dao.genericCall(target, callData, address(avatar), value);
		}
		require(
			ok,
			"CompoundVotingMachine::executeTransaction: Transaction execution reverted."
		);

		return (ok, result);
	}

	function cancel(uint256 proposalId) public {

		ProposalState pState = state(proposalId);
		require(
			pState != ProposalState.Executed,
			"CompoundVotingMachine::cancel: cannot cancel executed proposal"
		);

		Proposal storage proposal = proposals[proposalId];
		require(
			_msgSender() == guardian ||
				rep.getVotesAt(proposal.proposer, true, block.number - 1) <
				proposalThreshold(proposal.startBlock),
			"CompoundVotingMachine::cancel: proposer above threshold"
		);

		proposal.canceled = true;

		emit ProposalCanceled(proposalId);
	}

	function getActions(uint256 proposalId)
		public
		view
		returns (
			address[] memory targets,
			uint256[] memory values,
			string[] memory signatures,
			bytes[] memory calldatas
		)
	{

		Proposal storage p = proposals[proposalId];
		return (p.targets, p.values, p.signatures, p.calldatas);
	}

	function getReceipt(uint256 proposalId, address voter)
		public
		view
		returns (Receipt memory)
	{

		return proposals[proposalId].receipts[voter];
	}

	function state(uint256 proposalId) public view returns (ProposalState) {

		require(
			proposalCount >= proposalId && proposalId > 0,
			"CompoundVotingMachine::state: invalid proposal id"
		);

		Proposal storage proposal = proposals[proposalId];

		if (proposal.canceled) {
			return ProposalState.Canceled;
		} else if (block.number <= proposal.startBlock) {
			return ProposalState.Pending;
		} else if (proposal.executed) {
			return ProposalState.Executed;
		} else if (
			proposal.eta > 0 && block.timestamp < proposal.eta //passed quorum but not executed yet, in time lock
		) {
			return ProposalState.ActiveTimelock;
		} else if (
			proposal.eta == 0 && block.number <= proposal.endBlock
		) {
			return ProposalState.Active;
		} else if (
			proposal.forVotes <= proposal.againstVotes ||
			proposal.forVotes < proposal.quoromRequired
		) {
			return ProposalState.Defeated;
		} else if (
			proposal.eta > 0 && block.timestamp >= proposal.eta + gracePeriod
		) {
			return ProposalState.Expired;
		} else {
			return ProposalState.Succeeded;
		}
	}

	function castVote(uint256 proposalId, bool support) public {

		Proposal storage proposal = proposals[proposalId];
		uint256 votes = rep.getVotesAt(_msgSender(), true, proposal.startBlock);
		return _castVote(_msgSender(), proposal, support, votes);
	}

	struct VoteSig {
		bool support;
		uint8 v;
		bytes32 r;
		bytes32 s;
	}







	function castVoteBySig(
		uint256 proposalId,
		bool support,
		uint8 v,
		bytes32 r,
		bytes32 s
	) public {

		bytes32 domainSeparator = keccak256(
			abi.encode(
				DOMAIN_TYPEHASH,
				keccak256(bytes(name)),
				getChainId(),
				address(this)
			)
		);
		bytes32 structHash = keccak256(
			abi.encode(BALLOT_TYPEHASH, proposalId, support)
		);
		bytes32 digest = keccak256(
			abi.encodePacked("\x19\x01", domainSeparator, structHash)
		);
		address signatory = ecrecover(digest, v, r, s);
		require(
			signatory != address(0),
			"CompoundVotingMachine::castVoteBySig: invalid signature"
		);

		Proposal storage proposal = proposals[proposalId];
		uint256 votes = rep.getVotesAt(signatory, true, proposal.startBlock);
		return _castVote(signatory, proposal, support, votes);
	}

	function _castVote(
		address voter,
		Proposal storage proposal,
		bool support,
		uint256 votes
	) internal {

		uint256 proposalId = proposal.id;
		require(
			state(proposalId) == ProposalState.Active ||
				state(proposalId) == ProposalState.ActiveTimelock,
			"CompoundVotingMachine::_castVote: voting is closed"
		);

		Receipt storage receipt = proposal.receipts[voter];
		require(
			receipt.hasVoted == false,
			"CompoundVotingMachine::_castVote: voter already voted"
		);

		bool hasChanged = proposal.forVotes > proposal.againstVotes;
		if (support) {
			proposal.forVotes += votes;
		} else {
			proposal.againstVotes += votes;
		}

		hasChanged = hasChanged != (proposal.forVotes > proposal.againstVotes);
		receipt.hasVoted = true;
		receipt.support = support;
		receipt.votes = votes;

		if (
			proposal.forVotes >= proposal.quoromRequired ||
			proposal.againstVotes >= proposal.quoromRequired
		) _updateETA(proposal, hasChanged);
		emit VoteCast(voter, proposalId, support, votes);
	}

	function getChainId() public view returns (uint256) {

		uint256 chainId;
		assembly {
			chainId := chainid()
		}
		return chainId;
	}

	function renounceGuardian() public {

		require(_msgSender() == guardian, "CompoundVotingMachine: not guardian");
		guardian = address(0);
		foundationGuardianRelease = 0;
		emit GuardianSet(guardian);
	}

	function setGuardian(address _guardian) public {

		require(
			_msgSender() == address(avatar) || _msgSender() == guardian,
			"CompoundVotingMachine: not avatar or guardian"
		);

		require(
			_msgSender() == guardian || block.timestamp > foundationGuardianRelease,
			"CompoundVotingMachine: foundation expiration not reached"
		);

		guardian = _guardian;
		emit GuardianSet(guardian);
	}

	function emitSucceeded(uint256 _proposalId) public {

		require(
			state(_proposalId) == ProposalState.Succeeded,
			"CompoundVotingMachine: not Succeeded"
		);
		Proposal storage proposal = proposals[_proposalId];
		if (proposal.forBlockchain != getChainId()) {
			proposal.executed = true;
		}

		emit ProposalSucceeded(
			_proposalId,
			proposal.proposer,
			proposal.targets,
			proposal.values,
			proposal.signatures,
			proposal.calldatas,
			proposal.startBlock,
			proposal.endBlock,
			proposal.forBlockchain,
			proposal.eta,
			proposal.forVotes,
			proposal.againstVotes
		);
	}
}