


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


pragma solidity 0.6.12;

interface IElections {

	
	event StakeChanged(address indexed addr, uint256 selfDelegatedStake, uint256 delegatedStake, uint256 effectiveStake);
	event GuardianStatusUpdated(address indexed guardian, bool readyToSync, bool readyForCommittee);

	event GuardianVotedUnready(address indexed guardian);
	event VoteUnreadyCasted(address indexed voter, address indexed subject, uint256 expiration);
	event GuardianVotedOut(address indexed guardian);
	event VoteOutCasted(address indexed voter, address indexed subject);


	function readyToSync() external;


	function readyForCommittee() external;


	function canJoinCommittee(address guardian) external view returns (bool);


	function getEffectiveStake(address guardian) external view returns (uint effectiveStake);


	function getCommittee() external view returns (address[] memory committee, uint256[] memory weights, address[] memory orbsAddrs, bool[] memory certification, bytes4[] memory ips);



	function voteUnready(address subject, uint voteExpiration) external;


	function getVoteUnreadyVote(address voter, address subject) external view returns (bool valid, uint256 expiration);


	function getVoteUnreadyStatus(address subject) external view returns (
		address[] memory committee,
		uint256[] memory weights,
		bool[] memory certification,
		bool[] memory votes,
		bool subjectInCommittee,
		bool subjectInCertifiedCommittee
	);



	function voteOut(address subject) external;


	function getVoteOutVote(address voter) external view returns (address);


	function getVoteOutStatus(address subject) external view returns (bool votedOut, uint votedStake, uint totalDelegatedStake);



	function delegatedStakeChange(address delegate, uint256 selfDelegatedStake, uint256 delegatedStake, uint256 totalDelegatedStake) external /* onlyDelegationsContract onlyWhenActive */;


	function guardianUnregistered(address guardian) external /* onlyGuardiansRegistrationContract */;


	function guardianCertificationChanged(address guardian, bool isCertified) external /* onlyCertificationContract */;




	event VoteUnreadyTimeoutSecondsChanged(uint32 newValue, uint32 oldValue);
	event VoteOutPercentMilleThresholdChanged(uint32 newValue, uint32 oldValue);
	event VoteUnreadyPercentMilleThresholdChanged(uint32 newValue, uint32 oldValue);
	event MinSelfStakePercentMilleChanged(uint32 newValue, uint32 oldValue);

	function setMinSelfStakePercentMille(uint32 minSelfStakePercentMille) external /* onlyFunctionalManager */;


	function getMinSelfStakePercentMille() external view returns (uint32);


	function setVoteOutPercentMilleThreshold(uint32 voteOutPercentMilleThreshold) external /* onlyFunctionalManager */;


	function getVoteOutPercentMilleThreshold() external view returns (uint32);


	function setVoteUnreadyPercentMilleThreshold(uint32 voteUnreadyPercentMilleThreshold) external /* onlyFunctionalManager */;


	function getVoteUnreadyPercentMilleThreshold() external view returns (uint32);


	function getSettings() external view returns (
		uint32 minSelfStakePercentMille,
		uint32 voteUnreadyPercentMilleThreshold,
		uint32 voteOutPercentMilleThreshold
	);


	function initReadyForCommittee(address[] calldata guardians) external /* onlyInitializationAdmin */;


}


pragma solidity 0.6.12;

interface IDelegations /* is IStakeChangeNotifier */ {


	event DelegatedStakeChanged(address indexed addr, uint256 selfDelegatedStake, uint256 delegatedStake, address indexed delegator, uint256 delegatorContributedStake);

	event Delegated(address indexed from, address indexed to);


	function delegate(address to) external /* onlyWhenActive */;


	function refreshStake(address addr) external /* onlyWhenActive */;


	function refreshStakeBatch(address[] calldata addrs) external /* onlyWhenActive */;


	function getDelegation(address addr) external view returns (address);


	function getDelegationInfo(address addr) external view returns (address delegation, uint256 delegatorStake);

	
	function getDelegatedStake(address addr) external view returns (uint256);


	function getTotalDelegatedStake() external view returns (uint256) ;



	event DelegationsImported(address[] from, address indexed to);

	event DelegationInitialized(address indexed from, address indexed to);

	function importDelegations(address[] calldata from, address to) external /* onlyMigrationManager onlyDuringDelegationImport */;


	function initDelegation(address from, address to) external /* onlyInitializationAdmin */;

}


pragma solidity 0.6.12;

interface IGuardiansRegistration {

	event GuardianRegistered(address indexed guardian);
	event GuardianUnregistered(address indexed guardian);
	event GuardianDataUpdated(address indexed guardian, bool isRegistered, bytes4 ip, address orbsAddr, string name, string website, uint256 registrationTime);
	event GuardianMetadataChanged(address indexed guardian, string key, string newValue, string oldValue);


	function registerGuardian(bytes4 ip, address orbsAddr, string calldata name, string calldata website) external;


	function updateGuardian(bytes4 ip, address orbsAddr, string calldata name, string calldata website) external;


	function updateGuardianIp(bytes4 ip) external /* onlyWhenActive */;


    function setMetadata(string calldata key, string calldata value) external;


    function getMetadata(address guardian, string calldata key) external view returns (string memory);


	function unregisterGuardian() external;


	function getGuardianData(address guardian) external view returns (bytes4 ip, address orbsAddr, string memory name, string memory website, uint registrationTime, uint lastUpdateTime);


	function getGuardiansOrbsAddress(address[] calldata guardianAddrs) external view returns (address[] memory orbsAddrs);


	function getGuardianIp(address guardian) external view returns (bytes4 ip);


	function getGuardianIps(address[] calldata guardianAddrs) external view returns (bytes4[] memory ips);


	function isRegistered(address guardian) external view returns (bool);


	function getGuardianAddresses(address[] calldata orbsAddrs) external view returns (address[] memory guardianAddrs);


	function resolveGuardianAddress(address guardianOrOrbsAddress) external view returns (address guardianAddress);



	function migrateGuardians(address[] calldata guardiansToMigrate, IGuardiansRegistration previousContract) external /* onlyInitializationAdmin */;


}


pragma solidity 0.6.12;

interface ICommittee {

	event CommitteeChange(address indexed addr, uint256 weight, bool certification, bool inCommittee);
	event CommitteeSnapshot(address[] addrs, uint256[] weights, bool[] certification);



	function memberWeightChange(address addr, uint256 weight) external /* onlyElectionsContract onlyWhenActive */;


	function memberCertificationChange(address addr, bool isCertified) external /* onlyElectionsContract onlyWhenActive */;


	function removeMember(address addr) external returns (bool memberRemoved, uint removedMemberWeight, bool removedMemberCertified)/* onlyElectionContract */;


	function addMember(address addr, uint256 weight, bool isCertified) external returns (bool memberAdded)  /* onlyElectionsContract */;


	function checkAddMember(address addr, uint256 weight) external view returns (bool wouldAddMember);


	function getCommittee() external view returns (address[] memory addrs, uint256[] memory weights, bool[] memory certification);


	function getCommitteeStats() external view returns (uint generalCommitteeSize, uint certifiedCommitteeSize, uint totalWeight);


	function getMemberInfo(address addr) external view returns (bool inCommittee, uint weight, bool isCertified, uint totalCommitteeWeight);


	function emitCommitteeSnapshot() external;



	event MaxCommitteeSizeChanged(uint8 newValue, uint8 oldValue);

	function setMaxCommitteeSize(uint8 _maxCommitteeSize) external /* onlyFunctionalManager */;


	function getMaxCommitteeSize() external view returns (uint8);

	
	function importMembers(ICommittee previousCommitteeContract) external /* onlyInitializationAdmin */;

}


pragma solidity 0.6.12;

interface ICertification /* is Ownable */ {

	event GuardianCertificationUpdate(address indexed guardian, bool isCertified);


	function isGuardianCertified(address guardian) external view returns (bool isCertified);


	function setGuardianCertification(address guardian, bool isCertified) external /* onlyCertificationManager */ ;

}


pragma solidity 0.6.12;

interface IManagedContract /* is ILockable, IContractRegistryAccessor, Initializable */ {


    function refreshContracts() external;


}


pragma solidity 0.6.12;

interface IContractRegistry {


	event ContractAddressUpdated(string contractName, address addr, bool managedContract);
	event ManagerChanged(string role, address newManager);
	event ContractRegistryUpdated(address newContractRegistry);


	function setContract(string calldata contractName, address addr, bool managedContract) external /* onlyAdminOrMigrationManager */;


	function getContract(string calldata contractName) external view returns (address);


	function getManagedContracts() external view returns (address[] memory);


	function lockContracts() external /* onlyAdminOrMigrationManager */;


	function unlockContracts() external /* onlyAdminOrMigrationManager */;

	
	function setManager(string calldata role, address manager) external /* onlyAdmin */;


	function getManager(string calldata role) external view returns (address);


	function setNewContractRegistry(IContractRegistry newRegistry) external /* onlyAdmin */;


	function getPreviousContractRegistry() external view returns (address);

}


pragma solidity 0.6.12;


interface IContractRegistryAccessor {


    function setContractRegistry(IContractRegistry newRegistry) external /* onlyAdmin */;


    function getContractRegistry() external view returns (IContractRegistry contractRegistry);


    function setRegistryAdmin(address _registryAdmin) external /* onlyInitializationAdmin */;


}


pragma solidity ^0.6.0;

abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}


pragma solidity 0.6.12;


contract WithClaimableRegistryManagement is Context {

    address private _registryAdmin;
    address private _pendingRegistryAdmin;

    event RegistryManagementTransferred(address indexed previousRegistryAdmin, address indexed newRegistryAdmin);

    constructor () internal {
        address msgSender = _msgSender();
        _registryAdmin = msgSender;
        emit RegistryManagementTransferred(address(0), msgSender);
    }

    function registryAdmin() public view returns (address) {

        return _registryAdmin;
    }

    modifier onlyRegistryAdmin() {

        require(isRegistryAdmin(), "WithClaimableRegistryManagement: caller is not the registryAdmin");
        _;
    }

    function isRegistryAdmin() public view returns (bool) {

        return _msgSender() == _registryAdmin;
    }

    function renounceRegistryManagement() public onlyRegistryAdmin {

        emit RegistryManagementTransferred(_registryAdmin, address(0));
        _registryAdmin = address(0);
    }

    function _transferRegistryManagement(address newRegistryAdmin) internal {

        require(newRegistryAdmin != address(0), "RegistryAdmin: new registryAdmin is the zero address");
        emit RegistryManagementTransferred(_registryAdmin, newRegistryAdmin);
        _registryAdmin = newRegistryAdmin;
    }

    modifier onlyPendingRegistryAdmin() {

        require(msg.sender == _pendingRegistryAdmin, "Caller is not the pending registryAdmin");
        _;
    }
    function transferRegistryManagement(address newRegistryAdmin) public onlyRegistryAdmin {

        _pendingRegistryAdmin = newRegistryAdmin;
    }

    function claimRegistryManagement() external onlyPendingRegistryAdmin {

        _transferRegistryManagement(_pendingRegistryAdmin);
        _pendingRegistryAdmin = address(0);
    }

    function pendingRegistryAdmin() public view returns (address) {

       return _pendingRegistryAdmin;  
    }
}


pragma solidity 0.6.12;

contract Initializable {


    address private _initializationAdmin;

    event InitializationComplete();

    constructor() public{
        _initializationAdmin = msg.sender;
    }

    modifier onlyInitializationAdmin() {

        require(msg.sender == initializationAdmin(), "sender is not the initialization admin");

        _;
    }


    function initializationAdmin() public view returns (address) {

        return _initializationAdmin;
    }

    function initializationComplete() external onlyInitializationAdmin {

        _initializationAdmin = address(0);
        emit InitializationComplete();
    }

    function isInitializationComplete() public view returns (bool) {

        return _initializationAdmin == address(0);
    }

}


pragma solidity 0.6.12;





contract ContractRegistryAccessor is IContractRegistryAccessor, WithClaimableRegistryManagement, Initializable {


    IContractRegistry private contractRegistry;

    constructor(IContractRegistry _contractRegistry, address _registryAdmin) public {
        require(address(_contractRegistry) != address(0), "_contractRegistry cannot be 0");
        setContractRegistry(_contractRegistry);
        _transferRegistryManagement(_registryAdmin);
    }

    modifier onlyAdmin {

        require(isAdmin(), "sender is not an admin (registryManger or initializationAdmin)");

        _;
    }

    modifier onlyMigrationManager {

        require(isMigrationManager(), "sender is not the migration manager");

        _;
    }

    modifier onlyFunctionalManager {

        require(isFunctionalManager(), "sender is not the functional manager");

        _;
    }

    function isAdmin() internal view returns (bool) {

        return msg.sender == address(contractRegistry) || msg.sender == registryAdmin() || msg.sender == initializationAdmin();
    }

    function isManager(string memory role) internal view returns (bool) {

        IContractRegistry _contractRegistry = contractRegistry;
        return isAdmin() || _contractRegistry != IContractRegistry(0) && contractRegistry.getManager(role) == msg.sender;
    }

    function isMigrationManager() internal view returns (bool) {

        return isManager('migrationManager');
    }

    function isFunctionalManager() internal view returns (bool) {

        return isManager('functionalManager');
    }


    function getProtocolContract() internal view returns (address) {

        return contractRegistry.getContract("protocol");
    }

    function getStakingRewardsContract() internal view returns (address) {

        return contractRegistry.getContract("stakingRewards");
    }

    function getFeesAndBootstrapRewardsContract() internal view returns (address) {

        return contractRegistry.getContract("feesAndBootstrapRewards");
    }

    function getCommitteeContract() internal view returns (address) {

        return contractRegistry.getContract("committee");
    }

    function getElectionsContract() internal view returns (address) {

        return contractRegistry.getContract("elections");
    }

    function getDelegationsContract() internal view returns (address) {

        return contractRegistry.getContract("delegations");
    }

    function getGuardiansRegistrationContract() internal view returns (address) {

        return contractRegistry.getContract("guardiansRegistration");
    }

    function getCertificationContract() internal view returns (address) {

        return contractRegistry.getContract("certification");
    }

    function getStakingContract() internal view returns (address) {

        return contractRegistry.getContract("staking");
    }

    function getSubscriptionsContract() internal view returns (address) {

        return contractRegistry.getContract("subscriptions");
    }

    function getStakingRewardsWallet() internal view returns (address) {

        return contractRegistry.getContract("stakingRewardsWallet");
    }

    function getBootstrapRewardsWallet() internal view returns (address) {

        return contractRegistry.getContract("bootstrapRewardsWallet");
    }

    function getGeneralFeesWallet() internal view returns (address) {

        return contractRegistry.getContract("generalFeesWallet");
    }

    function getCertifiedFeesWallet() internal view returns (address) {

        return contractRegistry.getContract("certifiedFeesWallet");
    }

    function getStakingContractHandler() internal view returns (address) {

        return contractRegistry.getContract("stakingContractHandler");
    }


    event ContractRegistryAddressUpdated(address addr);

    function setContractRegistry(IContractRegistry newContractRegistry) public override onlyAdmin {

        require(newContractRegistry.getPreviousContractRegistry() == address(contractRegistry), "new contract registry must provide the previous contract registry");
        contractRegistry = newContractRegistry;
        emit ContractRegistryAddressUpdated(address(newContractRegistry));
    }

    function getContractRegistry() public override view returns (IContractRegistry) {

        return contractRegistry;
    }

    function setRegistryAdmin(address _registryAdmin) external override onlyInitializationAdmin {

        _transferRegistryManagement(_registryAdmin);
    }

}


pragma solidity 0.6.12;

interface ILockable {


    event Locked();
    event Unlocked();

    function lock() external /* onlyMigrationManager */;


    function unlock() external /* onlyMigrationManager */;


    function isLocked() view external returns (bool);


}


pragma solidity 0.6.12;



contract Lockable is ILockable, ContractRegistryAccessor {


    bool public locked;

    constructor(IContractRegistry _contractRegistry, address _registryAdmin) ContractRegistryAccessor(_contractRegistry, _registryAdmin) public {}

    function lock() external override onlyMigrationManager {

        locked = true;
        emit Locked();
    }

    function unlock() external override onlyMigrationManager {

        locked = false;
        emit Unlocked();
    }

    function isLocked() external override view returns (bool) {

        return locked;
    }

    modifier onlyWhenActive() {

        require(!locked, "contract is locked for this operation");

        _;
    }
}


pragma solidity 0.6.12;



contract ManagedContract is IManagedContract, Lockable {


    constructor(IContractRegistry _contractRegistry, address _registryAdmin) Lockable(_contractRegistry, _registryAdmin) public {}

    function refreshContracts() virtual override external {}


}


pragma solidity 0.6.12;








contract Elections is IElections, ManagedContract {

	using SafeMath for uint256;

	uint32 constant PERCENT_MILLIE_BASE = 100000;

	mapping(address => mapping(address => uint256)) voteUnreadyVotes; // by => to => expiration
	mapping(address => uint256) public votersStake;
	mapping(address => address) voteOutVotes; // by => to
	mapping(address => uint256) accumulatedStakesForVoteOut; // addr => total stake
	mapping(address => bool) votedOutGuardians;

	struct Settings {
		uint32 minSelfStakePercentMille;
		uint32 voteUnreadyPercentMilleThreshold;
		uint32 voteOutPercentMilleThreshold;
	}
	Settings settings;

	constructor(IContractRegistry _contractRegistry, address _registryAdmin, uint32 minSelfStakePercentMille, uint32 voteUnreadyPercentMilleThreshold, uint32 voteOutPercentMilleThreshold) ManagedContract(_contractRegistry, _registryAdmin) public {
		setMinSelfStakePercentMille(minSelfStakePercentMille);
		setVoteOutPercentMilleThreshold(voteOutPercentMilleThreshold);
		setVoteUnreadyPercentMilleThreshold(voteUnreadyPercentMilleThreshold);
	}

	modifier onlyDelegationsContract() {

		require(msg.sender == address(delegationsContract), "caller is not the delegations contract");

		_;
	}

	modifier onlyGuardiansRegistrationContract() {

		require(msg.sender == address(guardianRegistrationContract), "caller is not the guardian registrations contract");

		_;
	}

	modifier onlyCertificationContract() {

		require(msg.sender == address(certificationContract), "caller is not the certification contract");

		_;
	}


	function readyToSync() external override onlyWhenActive {

		address guardian = guardianRegistrationContract.resolveGuardianAddress(msg.sender); // this validates registration
		require(!isVotedOut(guardian), "caller is voted-out");

		emit GuardianStatusUpdated(guardian, true, false);

		committeeContract.removeMember(guardian);
	}

	function readyForCommittee() external override onlyWhenActive {

		_readyForCommittee(msg.sender);
	}

	function canJoinCommittee(address guardian) external view override returns (bool) {

		guardian = guardianRegistrationContract.resolveGuardianAddress(guardian); // this validates registration

		if (isVotedOut(guardian)) {
			return false;
		}

		uint256 effectiveStake = getGuardianEffectiveStake(guardian, settings);
		return committeeContract.checkAddMember(guardian, effectiveStake);
	}

	function getEffectiveStake(address guardian) external override view returns (uint effectiveStake) {

		return getGuardianEffectiveStake(guardian, settings);
	}

	function getCommittee() external override view returns (address[] memory committee, uint256[] memory weights, address[] memory orbsAddrs, bool[] memory certification, bytes4[] memory ips) {

		IGuardiansRegistration _guardianRegistrationContract = guardianRegistrationContract;
		(committee, weights, certification) = committeeContract.getCommittee();
		orbsAddrs = _guardianRegistrationContract.getGuardiansOrbsAddress(committee);
		ips = _guardianRegistrationContract.getGuardianIps(committee);
	}


	function voteUnready(address subject, uint voteExpiration) external override onlyWhenActive {

		require(voteExpiration >= block.timestamp, "vote expiration time must not be in the past");

		address voter = guardianRegistrationContract.resolveGuardianAddress(msg.sender);
		voteUnreadyVotes[voter][subject] = voteExpiration;
		emit VoteUnreadyCasted(voter, subject, voteExpiration);

		(address[] memory generalCommittee, uint256[] memory generalWeights, bool[] memory certification) = committeeContract.getCommittee();

		bool votedUnready = isCommitteeVoteUnreadyThresholdReached(generalCommittee, generalWeights, certification, subject);
		if (votedUnready) {
			clearCommitteeUnreadyVotes(generalCommittee, subject);
			emit GuardianVotedUnready(subject);

			emit GuardianStatusUpdated(subject, false, false);
			committeeContract.removeMember(subject);
		}
	}

	function getVoteUnreadyVote(address voter, address subject) public override view returns (bool valid, uint256 expiration) {

		expiration = voteUnreadyVotes[voter][subject];
		valid = expiration != 0 && block.timestamp < expiration;
	}

	function getVoteUnreadyStatus(address subject) external override view returns (address[] memory committee, uint256[] memory weights, bool[] memory certification, bool[] memory votes, bool subjectInCommittee, bool subjectInCertifiedCommittee) {

		(committee, weights, certification) = committeeContract.getCommittee();

		votes = new bool[](committee.length);
		for (uint i = 0; i < committee.length; i++) {
			address memberAddr = committee[i];
			if (block.timestamp < voteUnreadyVotes[memberAddr][subject]) {
				votes[i] = true;
			}

			if (memberAddr == subject) {
				subjectInCommittee = true;
				subjectInCertifiedCommittee = certification[i];
			}
		}
	}


	function voteOut(address subject) external override onlyWhenActive {

		Settings memory _settings = settings;

		address voter = msg.sender;
		address prevSubject = voteOutVotes[voter];

		voteOutVotes[voter] = subject;
		emit VoteOutCasted(voter, subject);

		uint256 voterStake = delegationsContract.getDelegatedStake(voter);

		if (prevSubject == address(0)) {
			votersStake[voter] = voterStake;
		}

		if (subject == address(0)) {
			delete votersStake[voter];
		}

		uint totalStake = delegationsContract.getTotalDelegatedStake();

		if (prevSubject != address(0) && prevSubject != subject) {
			applyVoteOutVotesFor(prevSubject, 0, voterStake, totalStake, _settings);
		}

		if (subject != address(0)) {
			uint voteStakeAdded = prevSubject != subject ? voterStake : 0;
			applyVoteOutVotesFor(subject, voteStakeAdded, 0, totalStake, _settings); // recheck also if not new
		}
	}

	function getVoteOutVote(address voter) external override view returns (address) {

		return voteOutVotes[voter];
	}

	function getVoteOutStatus(address subject) external override view returns (bool votedOut, uint votedStake, uint totalDelegatedStake) {

		votedOut = isVotedOut(subject);
		votedStake = accumulatedStakesForVoteOut[subject];
		totalDelegatedStake = delegationsContract.getTotalDelegatedStake();
	}


	function delegatedStakeChange(address delegate, uint256 selfDelegatedStake, uint256 delegatedStake, uint256 totalDelegatedStake) external override onlyDelegationsContract onlyWhenActive {

		Settings memory _settings = settings;

		uint effectiveStake = calcEffectiveStake(selfDelegatedStake, delegatedStake, _settings);
		emit StakeChanged(delegate, selfDelegatedStake, delegatedStake, effectiveStake);

		committeeContract.memberWeightChange(delegate, effectiveStake);

		applyStakesToVoteOutBy(delegate, delegatedStake, totalDelegatedStake, _settings);
	}

	function guardianUnregistered(address guardian) external override onlyGuardiansRegistrationContract onlyWhenActive {

		emit GuardianStatusUpdated(guardian, false, false);
		committeeContract.removeMember(guardian);
	}

	function guardianCertificationChanged(address guardian, bool isCertified) external override onlyCertificationContract onlyWhenActive {

		committeeContract.memberCertificationChange(guardian, isCertified);
	}


	function setMinSelfStakePercentMille(uint32 minSelfStakePercentMille) public override onlyFunctionalManager {

		require(minSelfStakePercentMille <= PERCENT_MILLIE_BASE, "minSelfStakePercentMille must be 100000 at most");
		emit MinSelfStakePercentMilleChanged(minSelfStakePercentMille, settings.minSelfStakePercentMille);
		settings.minSelfStakePercentMille = minSelfStakePercentMille;
	}

	function getMinSelfStakePercentMille() external override view returns (uint32) {

		return settings.minSelfStakePercentMille;
	}

	function setVoteOutPercentMilleThreshold(uint32 voteOutPercentMilleThreshold) public override onlyFunctionalManager {

		require(voteOutPercentMilleThreshold <= PERCENT_MILLIE_BASE, "voteOutPercentMilleThreshold must not be larger than 100000");
		emit VoteOutPercentMilleThresholdChanged(voteOutPercentMilleThreshold, settings.voteOutPercentMilleThreshold);
		settings.voteOutPercentMilleThreshold = voteOutPercentMilleThreshold;
	}

	function getVoteOutPercentMilleThreshold() external override view returns (uint32) {

		return settings.voteOutPercentMilleThreshold;
	}

	function setVoteUnreadyPercentMilleThreshold(uint32 voteUnreadyPercentMilleThreshold) public override onlyFunctionalManager {

		require(voteUnreadyPercentMilleThreshold <= PERCENT_MILLIE_BASE, "voteUnreadyPercentMilleThreshold must not be larger than 100000");
		emit VoteUnreadyPercentMilleThresholdChanged(voteUnreadyPercentMilleThreshold, settings.voteUnreadyPercentMilleThreshold);
		settings.voteUnreadyPercentMilleThreshold = voteUnreadyPercentMilleThreshold;
	}

	function getVoteUnreadyPercentMilleThreshold() external override view returns (uint32) {

		return settings.voteUnreadyPercentMilleThreshold;
	}

	function getSettings() external override view returns (
		uint32 minSelfStakePercentMille,
		uint32 voteUnreadyPercentMilleThreshold,
		uint32 voteOutPercentMilleThreshold
	) {

		Settings memory _settings = settings;
		minSelfStakePercentMille = _settings.minSelfStakePercentMille;
		voteUnreadyPercentMilleThreshold = _settings.voteUnreadyPercentMilleThreshold;
		voteOutPercentMilleThreshold = _settings.voteOutPercentMilleThreshold;
	}

	function initReadyForCommittee(address[] calldata guardians) external override onlyInitializationAdmin {

		for (uint i = 0; i < guardians.length; i++) {
			_readyForCommittee(guardians[i]);
		}
	}



	function _readyForCommittee(address guardian) private {

		guardian = guardianRegistrationContract.resolveGuardianAddress(guardian); // this validates registration
		require(!isVotedOut(guardian), "caller is voted-out");

		emit GuardianStatusUpdated(guardian, true, true);

		uint256 effectiveStake = getGuardianEffectiveStake(guardian, settings);
		committeeContract.addMember(guardian, effectiveStake, certificationContract.isGuardianCertified(guardian));
	}

	function calcEffectiveStake(uint256 selfStake, uint256 delegatedStake, Settings memory _settings) private pure returns (uint256) {

		if (selfStake.mul(PERCENT_MILLIE_BASE) >= delegatedStake.mul(_settings.minSelfStakePercentMille)) {
			return delegatedStake;
		}
		return selfStake.mul(PERCENT_MILLIE_BASE).div(_settings.minSelfStakePercentMille); // never overflows or divides by zero
	}

	function getGuardianEffectiveStake(address guardian, Settings memory _settings) private view returns (uint256 effectiveStake) {

		IDelegations _delegationsContract = delegationsContract;
		(,uint256 selfStake) = _delegationsContract.getDelegationInfo(guardian);
		uint256 delegatedStake = _delegationsContract.getDelegatedStake(guardian);
		return calcEffectiveStake(selfStake, delegatedStake, _settings);
	}


	function isCommitteeVoteUnreadyThresholdReached(address[] memory committee, uint256[] memory weights, bool[] memory certification, address subject) private returns (bool) {

		Settings memory _settings = settings;

		uint256 totalCommitteeStake = 0;
		uint256 totalVoteUnreadyStake = 0;
		uint256 totalCertifiedStake = 0;
		uint256 totalCertifiedVoteUnreadyStake = 0;

		address member;
		uint256 memberStake;
		bool isSubjectCertified;
		for (uint i = 0; i < committee.length; i++) {
			member = committee[i];
			memberStake = weights[i];

			if (member == subject && certification[i]) {
				isSubjectCertified = true;
			}

			totalCommitteeStake = totalCommitteeStake.add(memberStake);
			if (certification[i]) {
				totalCertifiedStake = totalCertifiedStake.add(memberStake);
			}

			(bool valid, uint256 expiration) = getVoteUnreadyVote(member, subject);
			if (valid) {
				totalVoteUnreadyStake = totalVoteUnreadyStake.add(memberStake);
				if (certification[i]) {
					totalCertifiedVoteUnreadyStake = totalCertifiedVoteUnreadyStake.add(memberStake);
				}
			} else if (expiration != 0) {
				delete voteUnreadyVotes[member][subject];
			}
		}

		return (
			totalCommitteeStake > 0 &&
			totalVoteUnreadyStake.mul(PERCENT_MILLIE_BASE) >= uint256(_settings.voteUnreadyPercentMilleThreshold).mul(totalCommitteeStake)
		) || (
			isSubjectCertified &&
			totalCertifiedStake > 0 &&
			totalCertifiedVoteUnreadyStake.mul(PERCENT_MILLIE_BASE) >= uint256(_settings.voteUnreadyPercentMilleThreshold).mul(totalCertifiedStake)
		);
	}

	function clearCommitteeUnreadyVotes(address[] memory committee, address subject) private {

		for (uint i = 0; i < committee.length; i++) {
			voteUnreadyVotes[committee[i]][subject] = 0; // clear vote-outs
		}
	}


	function applyStakesToVoteOutBy(address voter, uint256 currentVoterStake, uint256 totalDelegatedStake, Settings memory _settings) private {

		address subject = voteOutVotes[voter];
		if (subject == address(0)) return;

		uint256 prevVoterStake = votersStake[voter];
		votersStake[voter] = currentVoterStake;

		applyVoteOutVotesFor(subject, currentVoterStake, prevVoterStake, totalDelegatedStake, _settings);
	}

    function applyVoteOutVotesFor(address subject, uint256 voteOutStakeAdded, uint256 voteOutStakeRemoved, uint256 totalDelegatedStake, Settings memory _settings) private {

		if (isVotedOut(subject)) {
			return;
		}

		uint256 accumulated = accumulatedStakesForVoteOut[subject].
			sub(voteOutStakeRemoved).
			add(voteOutStakeAdded);

		bool shouldBeVotedOut = totalDelegatedStake > 0 && accumulated.mul(PERCENT_MILLIE_BASE) >= uint256(_settings.voteOutPercentMilleThreshold).mul(totalDelegatedStake);
		if (shouldBeVotedOut) {
			votedOutGuardians[subject] = true;
			emit GuardianVotedOut(subject);

			emit GuardianStatusUpdated(subject, false, false);
			committeeContract.removeMember(subject);
		}

		accumulatedStakesForVoteOut[subject] = accumulated;
	}

	function isVotedOut(address guardian) private view returns (bool) {

		return votedOutGuardians[guardian];
	}


	ICommittee committeeContract;
	IDelegations delegationsContract;
	IGuardiansRegistration guardianRegistrationContract;
	ICertification certificationContract;

	function refreshContracts() external override {

		committeeContract = ICommittee(getCommitteeContract());
		delegationsContract = IDelegations(getDelegationsContract());
		guardianRegistrationContract = IGuardiansRegistration(getGuardiansRegistrationContract());
		certificationContract = ICertification(getCertificationContract());
	}

}