


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

interface IStakingRewards {


    event DelegatorStakingRewardsAssigned(address indexed delegator, uint256 amount, uint256 totalAwarded, address guardian, uint256 delegatorRewardsPerToken, uint256 delegatorRewardsPerTokenDelta);
    event GuardianStakingRewardsAssigned(address indexed guardian, uint256 amount, uint256 totalAwarded, uint256 delegatorRewardsPerToken, uint256 delegatorRewardsPerTokenDelta, uint256 stakingRewardsPerWeight, uint256 stakingRewardsPerWeightDelta);
    event StakingRewardsClaimed(address indexed addr, uint256 claimedDelegatorRewards, uint256 claimedGuardianRewards, uint256 totalClaimedDelegatorRewards, uint256 totalClaimedGuardianRewards);
    event StakingRewardsAllocated(uint256 allocatedRewards, uint256 stakingRewardsPerWeight);
    event GuardianDelegatorsStakingRewardsPercentMilleUpdated(address indexed guardian, uint256 delegatorsStakingRewardsPercentMille);


    function getStakingRewardsBalance(address addr) external view returns (uint256 delegatorStakingRewardsBalance, uint256 guardianStakingRewardsBalance);


    function claimStakingRewards(address addr) external;


    function getStakingRewardsState() external view returns (
        uint96 stakingRewardsPerWeight,
        uint96 unclaimedStakingRewards
    );


    function getGuardianStakingRewardsData(address guardian) external view returns (
        uint256 balance,
        uint256 claimed,
        uint256 delegatorRewardsPerToken,
        uint256 delegatorRewardsPerTokenDelta,
        uint256 lastStakingRewardsPerWeight,
        uint256 stakingRewardsPerWeightDelta
    );


    function getDelegatorStakingRewardsData(address delegator) external view returns (
        uint256 balance,
        uint256 claimed,
        address guardian,
        uint256 lastDelegatorRewardsPerToken,
        uint256 delegatorRewardsPerTokenDelta
    );


    function estimateFutureRewards(address addr, uint256 duration) external view returns (
        uint256 estimatedDelegatorStakingRewards,
        uint256 estimatedGuardianStakingRewards
    );


    function setGuardianDelegatorsStakingRewardsPercentMille(uint32 delegatorRewardsPercentMille) external;


    function getGuardianDelegatorsStakingRewardsPercentMille(address guardian) external view returns (uint256 delegatorRewardsRatioPercentMille);


    function getStakingRewardsWalletAllocatedTokens() external view returns (uint256 allocated);


    function getCurrentStakingRewardsRatePercentMille() external view returns (uint256 annualRate);


    function committeeMembershipWillChange(address guardian, uint256 weight, uint256 totalCommitteeWeight, bool inCommittee, bool inCommitteeAfter) external /* onlyCommitteeContract */;


    function delegationWillChange(address guardian, uint256 guardianDelegatedStake, address delegator, uint256 delegatorStake, address nextGuardian, uint256 nextGuardianDelegatedStake) external /* onlyDelegationsContract */;



    event AnnualStakingRewardsRateChanged(uint256 annualRateInPercentMille, uint256 annualCap);
    event DefaultDelegatorsStakingRewardsChanged(uint32 defaultDelegatorsStakingRewardsPercentMille);
    event MaxDelegatorsStakingRewardsChanged(uint32 maxDelegatorsStakingRewardsPercentMille);
    event RewardDistributionActivated(uint256 startTime);
    event RewardDistributionDeactivated();
    event StakingRewardsBalanceMigrated(address indexed addr, uint256 guardianStakingRewards, uint256 delegatorStakingRewards, address toRewardsContract);
    event StakingRewardsBalanceMigrationAccepted(address from, address indexed addr, uint256 guardianStakingRewards, uint256 delegatorStakingRewards);
    event EmergencyWithdrawal(address addr, address token);

    function activateRewardDistribution(uint startTime) external /* onlyInitializationAdmin */;


    function deactivateRewardDistribution() external /* onlyMigrationManager */;

    
    function setDefaultDelegatorsStakingRewardsPercentMille(uint32 defaultDelegatorsStakingRewardsPercentMille) external /* onlyFunctionalManager */;


    function getDefaultDelegatorsStakingRewardsPercentMille() external view returns (uint32);


    function setMaxDelegatorsStakingRewardsPercentMille(uint32 maxDelegatorsStakingRewardsPercentMille) external /* onlyFunctionalManager */;


    function getMaxDelegatorsStakingRewardsPercentMille() external view returns (uint32);


    function setAnnualStakingRewardsRate(uint32 annualRateInPercentMille, uint96 annualCap) external /* onlyFunctionalManager */;


    function getAnnualStakingRewardsRatePercentMille() external view returns (uint32);


    function getAnnualStakingRewardsCap() external view returns (uint256);


    function isRewardAllocationActive() external view returns (bool);


    function getSettings() external view returns (
        uint annualStakingRewardsCap,
        uint32 annualStakingRewardsRatePercentMille,
        uint32 defaultDelegatorsStakingRewardsPercentMille,
        uint32 maxDelegatorsStakingRewardsPercentMille,
        bool rewardAllocationActive
    );


    function migrateRewardsBalance(address[] calldata addrs) external;


    function acceptRewardsBalanceMigration(address[] calldata addrs, uint256[] calldata migratedGuardianStakingRewards, uint256[] calldata migratedDelegatorStakingRewards, uint256 totalAmount) external;


    function emergencyWithdraw(address erc20) external /* onlyMigrationManager */;

}


pragma solidity 0.6.12;

interface IFeesAndBootstrapRewards {

    event FeesAllocated(uint256 allocatedGeneralFees, uint256 generalFeesPerMember, uint256 allocatedCertifiedFees, uint256 certifiedFeesPerMember);
    event FeesAssigned(address indexed guardian, uint256 amount, uint256 totalAwarded, bool certification, uint256 feesPerMember);
    event FeesWithdrawn(address indexed guardian, uint256 amount, uint256 totalWithdrawn);
    event BootstrapRewardsAllocated(uint256 allocatedGeneralBootstrapRewards, uint256 generalBootstrapRewardsPerMember, uint256 allocatedCertifiedBootstrapRewards, uint256 certifiedBootstrapRewardsPerMember);
    event BootstrapRewardsAssigned(address indexed guardian, uint256 amount, uint256 totalAwarded, bool certification, uint256 bootstrapPerMember);
    event BootstrapRewardsWithdrawn(address indexed guardian, uint256 amount, uint256 totalWithdrawn);


    function committeeMembershipWillChange(address guardian, bool inCommittee, bool isCertified, bool nextCertification, uint generalCommitteeSize, uint certifiedCommitteeSize) external /* onlyCommitteeContract */;


    function getFeesAndBootstrapBalance(address guardian) external view returns (
        uint256 feeBalance,
        uint256 bootstrapBalance
    );


    function estimateFutureFeesAndBootstrapRewards(address guardian, uint256 duration) external view returns (
        uint256 estimatedFees,
        uint256 estimatedBootstrapRewards
    );


    function withdrawFees(address guardian) external;


    function withdrawBootstrapFunds(address guardian) external;


    function getFeesAndBootstrapState() external view returns (
        uint256 certifiedFeesPerMember,
        uint256 generalFeesPerMember,
        uint256 certifiedBootstrapPerMember,
        uint256 generalBootstrapPerMember,
        uint256 lastAssigned
    );


    function getFeesAndBootstrapData(address guardian) external view returns (
        uint256 feeBalance,
        uint256 lastFeesPerMember,
        uint256 bootstrapBalance,
        uint256 lastBootstrapPerMember,
        uint256 withdrawnFees,
        uint256 withdrawnBootstrap,
        bool certified
    );



    event GeneralCommitteeAnnualBootstrapChanged(uint256 generalCommitteeAnnualBootstrap);
    event CertifiedCommitteeAnnualBootstrapChanged(uint256 certifiedCommitteeAnnualBootstrap);
    event RewardDistributionActivated(uint256 startTime);
    event RewardDistributionDeactivated();
    event FeesAndBootstrapRewardsBalanceMigrated(address indexed guardian, uint256 fees, uint256 bootstrapRewards, address toRewardsContract);
    event FeesAndBootstrapRewardsBalanceMigrationAccepted(address from, address indexed guardian, uint256 fees, uint256 bootstrapRewards);
    event EmergencyWithdrawal(address addr, address token);

    function activateRewardDistribution(uint startTime) external /* onlyInitializationAdmin */;

    
    function deactivateRewardDistribution() external /* onlyMigrationManager */;


    function isRewardAllocationActive() external view returns (bool);


    function setGeneralCommitteeAnnualBootstrap(uint256 annualAmount) external /* onlyFunctionalManager */;


    function getGeneralCommitteeAnnualBootstrap() external view returns (uint256);


    function setCertifiedCommitteeAnnualBootstrap(uint256 annualAmount) external /* onlyFunctionalManager */;


    function getCertifiedCommitteeAnnualBootstrap() external view returns (uint256);


    function migrateRewardsBalance(address[] calldata guardians) external;


    function acceptRewardsBalanceMigration(address[] memory guardians, uint256[] memory fees, uint256 totalFees, uint256[] memory bootstrap, uint256 totalBootstrap) external;


    function emergencyWithdraw(address erc20) external; /* onlyMigrationManager */


    function getSettings() external view returns (
        uint generalCommitteeAnnualBootstrap,
        uint certifiedCommitteeAnnualBootstrap,
        bool rewardAllocationActive
    );

}


pragma solidity 0.6.12;






contract Committee is ICommittee, ManagedContract {

	using SafeMath for uint256;
	using SafeMath for uint96;

	uint96 constant CERTIFICATION_MASK = 1 << 95;
	uint96 constant WEIGHT_MASK = ~CERTIFICATION_MASK;

	struct CommitteeMember {
		address addr;
		uint96 weightAndCertifiedBit;
	}
	CommitteeMember[] committee;

	struct MemberStatus {
		uint32 pos;
		bool inCommittee;
	}
	mapping(address => MemberStatus) public membersStatus;

	struct CommitteeStats {
		uint96 totalWeight;
		uint32 generalCommitteeSize;
		uint32 certifiedCommitteeSize;
	}
	CommitteeStats committeeStats;

	uint8 maxCommitteeSize;

	constructor(IContractRegistry _contractRegistry, address _registryAdmin, uint8 _maxCommitteeSize) ManagedContract(_contractRegistry, _registryAdmin) public {
		setMaxCommitteeSize(_maxCommitteeSize);
	}

	modifier onlyElectionsContract() {

		require(msg.sender == electionsContract, "caller is not the elections");

		_;
	}


	function memberWeightChange(address addr, uint256 weight) external override onlyElectionsContract onlyWhenActive {

		MemberStatus memory status = membersStatus[addr];

		if (!status.inCommittee) {
			return;
		}
		CommitteeMember memory member = committee[status.pos];
		(uint prevWeight, bool isCertified) = getWeightCertification(member);

		committeeStats.totalWeight = uint96(committeeStats.totalWeight.sub(prevWeight).add(weight));

		committee[status.pos].weightAndCertifiedBit = packWeightCertification(weight, isCertified);
		emit CommitteeChange(addr, weight, isCertified, true);
	}

	function memberCertificationChange(address addr, bool isCertified) external override onlyElectionsContract onlyWhenActive {

		MemberStatus memory status = membersStatus[addr];

		if (!status.inCommittee) {
			return;
		}
		CommitteeMember memory member = committee[status.pos];
		(uint weight, bool prevCertification) = getWeightCertification(member);

		CommitteeStats memory _committeeStats = committeeStats;

		feesAndBootstrapRewardsContract.committeeMembershipWillChange(addr, true, prevCertification, isCertified, _committeeStats.generalCommitteeSize, _committeeStats.certifiedCommitteeSize);

		committeeStats.certifiedCommitteeSize = _committeeStats.certifiedCommitteeSize - (prevCertification ? 1 : 0) + (isCertified ? 1 : 0);

		committee[status.pos].weightAndCertifiedBit = packWeightCertification(weight, isCertified);
		emit CommitteeChange(addr, weight, isCertified, true);
	}

	function removeMember(address addr) external override onlyElectionsContract onlyWhenActive returns (bool memberRemoved, uint removedMemberWeight, bool removedMemberCertified) {

		MemberStatus memory status = membersStatus[addr];
		if (!status.inCommittee) {
			return (false, 0, false);
		}

		memberRemoved = true;
		(removedMemberWeight, removedMemberCertified) = getWeightCertification(committee[status.pos]);

		committeeStats = removeMemberAtPos(status.pos, true, committeeStats);
	}

	function addMember(address addr, uint256 weight, bool isCertified) external override onlyElectionsContract onlyWhenActive returns (bool memberAdded) {

		return _addMember(addr, weight, isCertified, true);
	}

	function checkAddMember(address addr, uint256 weight) external view override returns (bool wouldAddMember) {

		if (membersStatus[addr].inCommittee) {
			return false;
		}

		(bool qualified, ) = qualifiesToEnterCommittee(addr, weight, maxCommitteeSize);
		return qualified;
	}

	function getCommittee() external override view returns (address[] memory addrs, uint256[] memory weights, bool[] memory certification) {

		return _getCommittee();
	}

	function getCommitteeStats() external override view returns (uint generalCommitteeSize, uint certifiedCommitteeSize, uint totalWeight) {

		CommitteeStats memory _committeeStats = committeeStats;
		return (_committeeStats.generalCommitteeSize, _committeeStats.certifiedCommitteeSize, _committeeStats.totalWeight);
	}

	function getMemberInfo(address addr) external override view returns (bool inCommittee, uint weight, bool isCertified, uint totalCommitteeWeight) {

		MemberStatus memory status = membersStatus[addr];
		inCommittee = status.inCommittee;
		if (inCommittee) {
			(weight, isCertified) = getWeightCertification(committee[status.pos]);
		}
		totalCommitteeWeight = committeeStats.totalWeight;
	}
	
	function emitCommitteeSnapshot() external override {

		(address[] memory addrs, uint256[] memory weights, bool[] memory certification) = _getCommittee();
		for (uint i = 0; i < addrs.length; i++) {
			emit CommitteeChange(addrs[i], weights[i], certification[i], true);
		}
		emit CommitteeSnapshot(addrs, weights, certification);
	}



	function setMaxCommitteeSize(uint8 _maxCommitteeSize) public override onlyFunctionalManager {

		uint8 prevMaxCommitteeSize = maxCommitteeSize;
		maxCommitteeSize = _maxCommitteeSize;

		while (committee.length > _maxCommitteeSize) {
			(, ,uint pos) = _getMinCommitteeMember();
			committeeStats = removeMemberAtPos(pos, true, committeeStats);
		}

		emit MaxCommitteeSizeChanged(_maxCommitteeSize, prevMaxCommitteeSize);
	}

	function getMaxCommitteeSize() external override view returns (uint8) {

		return maxCommitteeSize;
	}

	function importMembers(ICommittee previousCommitteeContract) external override onlyInitializationAdmin {

		(address[] memory addrs, uint256[] memory weights, bool[] memory certification) = previousCommitteeContract.getCommittee();
		for (uint i = 0; i < addrs.length; i++) {
			_addMember(addrs[i], weights[i], certification[i], false);
		}
	}


	function _addMember(address addr, uint256 weight, bool isCertified, bool notifyRewards) private returns (bool memberAdded) {

		MemberStatus memory status = membersStatus[addr];

		if (status.inCommittee) {
			return false;
		}

		(bool qualified, uint entryPos) = qualifiesToEnterCommittee(addr, weight, maxCommitteeSize);
		if (!qualified) {
			return false;
		}

		memberAdded = true;

		CommitteeStats memory _committeeStats = committeeStats;

		if (notifyRewards) {
			stakingRewardsContract.committeeMembershipWillChange(addr, weight, _committeeStats.totalWeight, false, true);
			feesAndBootstrapRewardsContract.committeeMembershipWillChange(addr, false, isCertified, isCertified, _committeeStats.generalCommitteeSize, _committeeStats.certifiedCommitteeSize);
		}

		_committeeStats.generalCommitteeSize++;
		if (isCertified) _committeeStats.certifiedCommitteeSize++;
		_committeeStats.totalWeight = uint96(_committeeStats.totalWeight.add(weight));

		CommitteeMember memory newMember = CommitteeMember({
			addr: addr,
			weightAndCertifiedBit: packWeightCertification(weight, isCertified)
			});

		if (entryPos < committee.length) {
			CommitteeMember memory removed = committee[entryPos];
			unpackWeightCertification(removed.weightAndCertifiedBit);

			_committeeStats = removeMemberAtPos(entryPos, false, _committeeStats);
			committee[entryPos] = newMember;
		} else {
			committee.push(newMember);
		}

		status.inCommittee = true;
		status.pos = uint32(entryPos);
		membersStatus[addr] = status;

		committeeStats = _committeeStats;

		emit CommitteeChange(addr, weight, isCertified, true);
	}

	function packWeightCertification(uint256 weight, bool certification) private pure returns (uint96 weightAndCertified) {

		return uint96(weight) | (certification ? CERTIFICATION_MASK : 0);
	}

	function unpackWeightCertification(uint96 weightAndCertifiedBit) private pure returns (uint256 weight, bool certification) {

		return (uint256(weightAndCertifiedBit & WEIGHT_MASK), weightAndCertifiedBit & CERTIFICATION_MASK != 0);
	}

	function getWeightCertification(CommitteeMember memory member) private pure returns (uint256 weight, bool certification) {

		return unpackWeightCertification(member.weightAndCertifiedBit);
	}

	function _getCommittee() private view returns (address[] memory addrs, uint256[] memory weights, bool[] memory certification) {

		CommitteeMember[] memory _committee = committee;
		addrs = new address[](_committee.length);
		weights = new uint[](_committee.length);
		certification = new bool[](_committee.length);

		for (uint i = 0; i < _committee.length; i++) {
			addrs[i] = _committee[i].addr;
			(weights[i], certification[i]) = getWeightCertification(_committee[i]);
		}
	}

	function _getMinCommitteeMember() private view returns (
		address minMemberAddress,
		uint256 minMemberWeight,
		uint minMemberPos
	){

		CommitteeMember[] memory _committee = committee;
		minMemberPos = uint256(-1);
		minMemberWeight = uint256(-1);
		uint256 memberWeight;
		address memberAddress;
		for (uint i = 0; i < _committee.length; i++) {
			memberAddress = _committee[i].addr;
			(memberWeight,) = getWeightCertification(_committee[i]);
			if (memberWeight < minMemberWeight || memberWeight == minMemberWeight && memberAddress < minMemberAddress) {
				minMemberPos = i;
				minMemberWeight = memberWeight;
				minMemberAddress = memberAddress;
			}
		}
	}


	function qualifiesToEnterCommittee(address addr, uint256 weight, uint8 _maxCommitteeSize) private view returns (bool qualified, uint entryPos) {

		uint committeeLength = committee.length;
		if (committeeLength < _maxCommitteeSize) {
			return (true, committeeLength);
		}

		(address minMemberAddress, uint256 minMemberWeight, uint minMemberPos) = _getMinCommitteeMember();

		if (weight > minMemberWeight || weight == minMemberWeight && addr > minMemberAddress) {
			return (true, minMemberPos);
		}

		return (false, 0);
	}

	function removeMemberAtPos(uint pos, bool clearFromList, CommitteeStats memory _committeeStats) private returns (CommitteeStats memory newCommitteeStats){

		CommitteeMember memory member = committee[pos];

		(uint weight, bool certification) = getWeightCertification(member);

		stakingRewardsContract.committeeMembershipWillChange(member.addr, weight, _committeeStats.totalWeight, true, false);
		feesAndBootstrapRewardsContract.committeeMembershipWillChange(member.addr, true, certification, certification, _committeeStats.generalCommitteeSize, _committeeStats.certifiedCommitteeSize);

		delete membersStatus[member.addr];

		_committeeStats.generalCommitteeSize--;
		if (certification) _committeeStats.certifiedCommitteeSize--;
		_committeeStats.totalWeight = uint96(_committeeStats.totalWeight.sub(weight));

		emit CommitteeChange(member.addr, weight, certification, false);

		if (clearFromList) {
			uint committeeLength = committee.length;
			if (pos < committeeLength - 1) {
				CommitteeMember memory last = committee[committeeLength - 1];
				committee[pos] = last;
				membersStatus[last.addr].pos = uint32(pos);
			}
			committee.pop();
		}

		return _committeeStats;
	}


	address electionsContract;
	IStakingRewards stakingRewardsContract;
	IFeesAndBootstrapRewards feesAndBootstrapRewardsContract;

	function refreshContracts() external override {

		electionsContract = getElectionsContract();
		stakingRewardsContract = IStakingRewards(getStakingRewardsContract());
		feesAndBootstrapRewardsContract = IFeesAndBootstrapRewards(getFeesAndBootstrapRewardsContract());
	}
}