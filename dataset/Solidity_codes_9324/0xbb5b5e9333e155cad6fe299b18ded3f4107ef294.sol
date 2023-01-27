

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

library Math {

    function max(uint256 a, uint256 b) internal pure returns (uint256) {

        return a >= b ? a : b;
    }

    function min(uint256 a, uint256 b) internal pure returns (uint256) {

        return a < b ? a : b;
    }

    function average(uint256 a, uint256 b) internal pure returns (uint256) {

        return (a / 2) + (b / 2) + ((a % 2 + b % 2) / 2);
    }
}


pragma solidity 0.5.16;

interface ICommitteeListener {

    function committeeChanged(address[] calldata addrs, uint256[] calldata stakes) external;

}


pragma solidity 0.5.16;

interface IContractRegistry {


	event ContractAddressUpdated(string contractName, address addr);

	function set(string calldata contractName, address addr) external /* onlyGovernor */;


	function get(string calldata contractName) external view returns (address);

}


pragma solidity 0.5.16;

interface IStakeChangeNotifier {

    function stakeChange(address _stakeOwner, uint256 _amount, bool _sign, uint256 _updatedStake) external;


    function stakeChangeBatch(address[] calldata _stakeOwners, uint256[] calldata _amounts, bool[] calldata _signs,
        uint256[] calldata _updatedStakes) external;


    function stakeMigration(address _stakeOwner, uint256 _amount) external;

}


pragma solidity 0.5.16;



interface IElections /* is IStakeChangeNotifier */ {

	event GuardianVotedUnready(address guardian);
	event GuardianVotedOut(address guardian);

	event VoteUnreadyCasted(address voter, address subject);
	event VoteOutCasted(address voter, address subject);
	event StakeChanged(address addr, uint256 selfStake, uint256 delegated_stake, uint256 effective_stake);

	event GuardianStatusUpdated(address addr, bool readyToSync, bool readyForCommittee);

	event VoteUnreadyTimeoutSecondsChanged(uint32 newValue, uint32 oldValue);
	event MinSelfStakePercentMilleChanged(uint32 newValue, uint32 oldValue);
	event VoteOutPercentageThresholdChanged(uint8 newValue, uint8 oldValue);
	event VoteUnreadyPercentageThresholdChanged(uint8 newValue, uint8 oldValue);


	function voteUnready(address subject_addr) external;


	function voteOut(address subjectAddr) external;


	function readyToSync() external;


	function readyForCommittee() external;



	function delegatedStakeChange(address addr, uint256 selfStake, uint256 delegatedStake, uint256 totalDelegatedStake) external /* onlyDelegationContract */;


	function guardianRegistered(address addr) external /* onlyGuardiansRegistrationContract */;


	function guardianUnregistered(address addr) external /* onlyGuardiansRegistrationContract */;


	function guardianCertificationChanged(address addr, bool isCertified) external /* onlyCertificationContract */;



	function setContractRegistry(IContractRegistry _contractRegistry) external /* onlyMigrationOwner */;


	function setVoteUnreadyTimeoutSeconds(uint32 voteUnreadyTimeoutSeconds) external /* onlyFunctionalOwner onlyWhenActive */;

	function setMinSelfStakePercentMille(uint32 minSelfStakePercentMille) external /* onlyFunctionalOwner onlyWhenActive */;

	function setVoteOutPercentageThreshold(uint8 voteUnreadyPercentageThreshold) external /* onlyFunctionalOwner onlyWhenActive */;

	function setVoteUnreadyPercentageThreshold(uint8 voteUnreadyPercentageThreshold) external /* onlyFunctionalOwner onlyWhenActive */;

	function getSettings() external view returns (
		uint32 voteUnreadyTimeoutSeconds,
		uint32 minSelfStakePercentMille,
		uint8 voteUnreadyPercentageThreshold,
		uint8 voteOutPercentageThreshold
	);

}


pragma solidity 0.5.16;


interface IGuardiansRegistration {

	event GuardianRegistered(address addr);
	event GuardianDataUpdated(address addr, bytes4 ip, address orbsAddr, string name, string website, string contact);
	event GuardianUnregistered(address addr);
	event GuardianMetadataChanged(address addr, string key, string newValue, string oldValue);


	function registerGuardian(bytes4 ip, address orbsAddr, string calldata name, string calldata website, string calldata contact) external;


	function updateGuardian(bytes4 ip, address orbsAddr, string calldata name, string calldata website, string calldata contact) external;


	function updateGuardianIp(bytes4 ip) external /* onlyWhenActive */;


    function setMetadata(string calldata key, string calldata value) external;


    function getMetadata(address addr, string calldata key) external view returns (string memory);


	function unregisterGuardian() external;


	function getGuardianData(address addr) external view returns (bytes4 ip, address orbsAddr, string memory name, string memory website, string memory contact, uint registration_time, uint last_update_time);


	function getGuardiansOrbsAddress(address[] calldata addrs) external view returns (address[] memory orbsAddrs);


	function getGuardianIp(address addr) external view returns (bytes4 ip);


	function getGuardianIps(address[] calldata addr) external view returns (bytes4[] memory ips);



	function isRegistered(address addr) external view returns (bool);



	function getOrbsAddresses(address[] calldata ethereumAddrs) external view returns (address[] memory orbsAddr);


	function getEthereumAddresses(address[] calldata orbsAddrs) external view returns (address[] memory ethereumAddr);


	function resolveGuardianAddress(address ethereumOrOrbsAddress) external view returns (address mainAddress);


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


pragma solidity 0.5.16;


interface IMigratableStakingContract {

    function getToken() external view returns (IERC20);


    function acceptMigration(address _stakeOwner, uint256 _amount) external;


    event AcceptedMigration(address indexed stakeOwner, uint256 amount, uint256 totalStakedAmount);
}


pragma solidity 0.5.16;


interface IStakingContract {

    function stake(uint256 _amount) external;


    function unstake(uint256 _amount) external;


    function withdraw() external;


    function restake() external;


    function distributeRewards(uint256 _totalAmount, address[] calldata _stakeOwners, uint256[] calldata _amounts) external;


    function getStakeBalanceOf(address _stakeOwner) external view returns (uint256);


    function getTotalStakedTokens() external view returns (uint256);


    function getUnstakeStatus(address _stakeOwner) external view returns (uint256 cooldownAmount,
        uint256 cooldownEndTime);


    function migrateStakedTokens(IMigratableStakingContract _newStakingContract, uint256 _amount) external;


    event Staked(address indexed stakeOwner, uint256 amount, uint256 totalStakedAmount);
    event Unstaked(address indexed stakeOwner, uint256 amount, uint256 totalStakedAmount);
    event Withdrew(address indexed stakeOwner, uint256 amount, uint256 totalStakedAmount);
    event Restaked(address indexed stakeOwner, uint256 amount, uint256 totalStakedAmount);
    event MigratedStake(address indexed stakeOwner, uint256 amount, uint256 totalStakedAmount);
}


pragma solidity 0.5.16;


interface ICommittee {

	event GuardianCommitteeChange(address addr, uint256 weight, bool certification, bool inCommittee);
	event CommitteeSnapshot(address[] addrs, uint256[] weights, bool[] certification);



	function memberWeightChange(address addr, uint256 weight) external returns (bool committeeChanged) /* onlyElectionContract */;


	function memberCertificationChange(address addr, bool isCertified) external returns (bool committeeChanged) /* onlyElectionsContract */;


	function removeMember(address addr) external returns (bool committeeChanged) /* onlyElectionContract */;


	function addMember(address addr, uint256 weight, bool isCertified) external returns (bool committeeChanged) /* onlyElectionsContract */;


	function getCommittee() external view returns (address[] memory addrs, uint256[] memory weights, bool[] memory certification);



	function setMaxTimeBetweenRewardAssignments(uint32 maxTimeBetweenRewardAssignments) external /* onlyFunctionalOwner onlyWhenActive */;

	function setMaxCommittee(uint8 maxCommitteeSize) external /* onlyFunctionalOwner onlyWhenActive */;


	event MaxTimeBetweenRewardAssignmentsChanged(uint32 newValue, uint32 oldValue);
	event MaxCommitteeSizeChanged(uint8 newValue, uint8 oldValue);

	function setContractRegistry(IContractRegistry _contractRegistry) external /* onlyMigrationOwner */;



	function getCommitteeInfo() external view returns (address[] memory addrs, uint256[] memory weights, address[] memory orbsAddrs, bool[] memory certification, bytes4[] memory ips);


	function getSettings() external view returns (uint32 maxTimeBetweenRewardAssignments, uint8 maxCommitteeSize);

}


pragma solidity 0.5.16;



interface ICertification /* is Ownable */ {

	event GuardianCertificationUpdate(address guardian, bool isCertified);


	function isGuardianCertified(address addr) external view returns (bool isCertified);


	function setGuardianCertification(address addr, bool isCertified) external /* Owner only */ ;



	function setContractRegistry(IContractRegistry _contractRegistry) external /* onlyMigrationOwner */;


}


pragma solidity 0.5.16;

interface IProtocol {

    event ProtocolVersionChanged(string deploymentSubset, uint256 currentVersion, uint256 nextVersion, uint256 fromTimestamp);


    function deploymentSubsetExists(string calldata deploymentSubset) external view returns (bool);


    function getProtocolVersion(string calldata deploymentSubset) external view returns (uint256);



    function createDeploymentSubset(string calldata deploymentSubset, uint256 initialProtocolVersion) external /* onlyFunctionalOwner */;


    function setProtocolVersion(string calldata deploymentSubset, uint256 nextVersion, uint256 fromTimestamp) external /* onlyFunctionalOwner */;

}


pragma solidity 0.5.16;


interface ISubscriptions {

    event SubscriptionChanged(uint256 vcid, uint256 genRefTime, uint256 expiresAt, string tier, string deploymentSubset);
    event Payment(uint256 vcid, address by, uint256 amount, string tier, uint256 rate);
    event VcConfigRecordChanged(uint256 vcid, string key, string value);
    event SubscriberAdded(address subscriber);
    event VcCreated(uint256 vcid, address owner); // TODO what about isCertified, deploymentSubset?
    event VcOwnerChanged(uint256 vcid, address previousOwner, address newOwner);


    function createVC(string calldata tier, uint256 rate, uint256 amount, address owner, bool isCertified, string calldata deploymentSubset) external returns (uint, uint);


    function extendSubscription(uint256 vcid, uint256 amount, address payer) external;


    function setVcConfigRecord(uint256 vcid, string calldata key, string calldata value) external /* onlyVcOwner */;


    function getVcConfigRecord(uint256 vcid, string calldata key) external view returns (string memory);


    function setVcOwner(uint256 vcid, address owner) external /* onlyVcOwner */;


    function getGenesisRefTimeDelay() external view returns (uint256);



    function addSubscriber(address addr) external /* onlyFunctionalOwner */;


    function setGenesisRefTimeDelay(uint256 newGenesisRefTimeDelay) external /* onlyFunctionalOwner */;


    function setContractRegistry(IContractRegistry _contractRegistry) external /* onlyMigrationOwner */;


}


pragma solidity 0.5.16;


interface IDelegations /* is IStakeChangeNotifier */ {

	event DelegatedStakeChanged(address indexed addr, uint256 selfDelegatedStake, uint256 delegatedStake, address[] delegators, uint256[] delegatorTotalStakes);

	event Delegated(address indexed from, address indexed to);


	function delegate(address to) external /* onlyWhenActive */;


	function refreshStakeNotification(address addr) external /* onlyWhenActive */;



	function setContractRegistry(IContractRegistry _contractRegistry) external /* onlyMigrationOwner */;


	function importDelegations(address[] calldata from, address[] calldata to, bool notifyElections) external /* onlyMigrationOwner onlyDuringDelegationImport */;

	function finalizeDelegationImport() external /* onlyMigrationOwner onlyDuringDelegationImport */;


	event DelegationsImported(address[] from, address[] to, bool notifiedElections);
	event DelegationImportFinalized();


	function getDelegatedStakes(address addr) external view returns (uint256);

	function getSelfDelegatedStake(address addr) external view returns (uint256);

	function getDelegation(address addr) external view returns (address);

	function getTotalDelegatedStake() external view returns (uint256) ;



}


pragma solidity 0.5.16;



interface IRewards {


    function assignRewards() external;

    function assignRewardsToCommittee(address[] calldata generalCommittee, uint256[] calldata generalCommitteeWeights, bool[] calldata certification) external /* onlyCommitteeContract */;



    event StakingRewardsDistributed(address indexed distributer, uint256 fromBlock, uint256 toBlock, uint split, uint txIndex, address[] to, uint256[] amounts);
    event StakingRewardsAssigned(address[] assignees, uint256[] amounts); // todo balance?
    event StakingRewardsAddedToPool(uint256 added, uint256 total);
    event MaxDelegatorsStakingRewardsChanged(uint32 maxDelegatorsStakingRewardsPercentMille);

    function getStakingRewardBalance(address addr) external view returns (uint256 balance);


    function distributeOrbsTokenStakingRewards(uint256 totalAmount, uint256 fromBlock, uint256 toBlock, uint split, uint txIndex, address[] calldata to, uint256[] calldata amounts) external;


    function topUpStakingRewardsPool(uint256 amount) external;



    function setAnnualStakingRewardsRate(uint256 annual_rate_in_percent_mille, uint256 annual_cap) external /* onlyFunctionalOwner */;




    event FeesAssigned(uint256 generalGuardianAmount, uint256 certifiedGuardianAmount);
    event FeesWithdrawn(address guardian, uint256 amount);
    event FeesWithdrawnFromBucket(uint256 bucketId, uint256 withdrawn, uint256 total, bool isCertified);
    event FeesAddedToBucket(uint256 bucketId, uint256 added, uint256 total, bool isCertified);


    function getFeeBalance(address addr) external view returns (uint256 balance);


    function withdrawFeeFunds() external;


    function fillCertificationFeeBuckets(uint256 amount, uint256 monthlyRate, uint256 fromTimestamp) external;


    function fillGeneralFeeBuckets(uint256 amount, uint256 monthlyRate, uint256 fromTimestamp) external;


    function getTotalBalances() external view returns (uint256 feesTotalBalance, uint256 stakingRewardsTotalBalance, uint256 bootstrapRewardsTotalBalance);



    event BootstrapRewardsAssigned(uint256 generalGuardianAmount, uint256 certifiedGuardianAmount);
    event BootstrapAddedToPool(uint256 added, uint256 total);
    event BootstrapRewardsWithdrawn(address guardian, uint256 amount);


    function getBootstrapBalance(address addr) external view returns (uint256 balance);


    function withdrawBootstrapFunds() external;


    function getLastRewardAssignmentTime() external view returns (uint256 time);


    function topUpBootstrapPool(uint256 amount) external;



    function setGeneralCommitteeAnnualBootstrap(uint256 annual_amount) external /* onlyFunctionalOwner */;


    function setCertificationCommitteeAnnualBootstrap(uint256 annual_amount) external /* onlyFunctionalOwner */;


    event EmergencyWithdrawal(address addr);

    function emergencyWithdraw() external /* onlyMigrationManager */;



    function setContractRegistry(IContractRegistry _contractRegistry) external /* onlyMigrationOwner */;



}


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


pragma solidity 0.5.16;


contract WithClaimableMigrationOwnership is Context{

    address private _migrationOwner;
    address pendingMigrationOwner;

    event MigrationOwnershipTransferred(address indexed previousMigrationOwner, address indexed newMigrationOwner);

    constructor () internal {
        address msgSender = _msgSender();
        _migrationOwner = msgSender;
        emit MigrationOwnershipTransferred(address(0), msgSender);
    }

    function migrationOwner() public view returns (address) {

        return _migrationOwner;
    }

    modifier onlyMigrationOwner() {

        require(isMigrationOwner(), "WithClaimableMigrationOwnership: caller is not the migrationOwner");
        _;
    }

    function isMigrationOwner() public view returns (bool) {

        return _msgSender() == _migrationOwner;
    }

    function renounceMigrationOwnership() public onlyMigrationOwner {

        emit MigrationOwnershipTransferred(_migrationOwner, address(0));
        _migrationOwner = address(0);
    }

    function _transferMigrationOwnership(address newMigrationOwner) internal {

        require(newMigrationOwner != address(0), "MigrationOwner: new migrationOwner is the zero address");
        emit MigrationOwnershipTransferred(_migrationOwner, newMigrationOwner);
        _migrationOwner = newMigrationOwner;
    }

    modifier onlyPendingMigrationOwner() {

        require(msg.sender == pendingMigrationOwner, "Caller is not the pending migrationOwner");
        _;
    }
    function transferMigrationOwnership(address newMigrationOwner) public onlyMigrationOwner {

        pendingMigrationOwner = newMigrationOwner;
    }
    function claimMigrationOwnership() external onlyPendingMigrationOwner {

        _transferMigrationOwnership(pendingMigrationOwner);
        pendingMigrationOwner = address(0);
    }
}


pragma solidity 0.5.16;



contract Lockable is WithClaimableMigrationOwnership {


    bool public locked;

    event Locked();
    event Unlocked();

    function lock() external onlyMigrationOwner {

        locked = true;
        emit Locked();
    }

    function unlock() external onlyMigrationOwner {

        locked = false;
        emit Unlocked();
    }

    modifier onlyWhenActive() {

        require(!locked, "contract is locked for this operation");

        _;
    }
}


pragma solidity 0.5.16;



pragma solidity 0.5.16;

interface IProtocolWallet {

    event FundsAddedToPool(uint256 added, uint256 total);
    event ClientSet(address client);
    event MaxAnnualRateSet(uint256 maxAnnualRate);
    event EmergencyWithdrawal(address addr);

    function getToken() external view returns (IERC20);


    function getBalance() external view returns (uint256 balance);


    function topUp(uint256 amount) external;


    function withdraw(uint256 amount) external; /* onlyClient */


    function setMaxAnnualRate(uint256 annual_rate) external; /* onlyMigrationManager */


    function emergencyWithdraw() external; /* onlyMigrationManager */


    function setClient(address client) external; /* onlyFunctionalManager */

}


pragma solidity 0.5.16;













contract ContractRegistryAccessor is WithClaimableMigrationOwnership {


    IContractRegistry contractRegistry;

    event ContractRegistryAddressUpdated(address addr);

    function setContractRegistry(IContractRegistry _contractRegistry) external onlyMigrationOwner {

        contractRegistry = _contractRegistry;
        emit ContractRegistryAddressUpdated(address(_contractRegistry));
    }

    function getProtocolContract() public view returns (IProtocol) {

        return IProtocol(contractRegistry.get("protocol"));
    }

    function getRewardsContract() public view returns (IRewards) {

        return IRewards(contractRegistry.get("rewards"));
    }

    function getCommitteeContract() public view returns (ICommittee) {

        return ICommittee(contractRegistry.get("committee"));
    }

    function getElectionsContract() public view returns (IElections) {

        return IElections(contractRegistry.get("elections"));
    }

    function getDelegationsContract() public view returns (IDelegations) {

        return IDelegations(contractRegistry.get("delegations"));
    }

    function getGuardiansRegistrationContract() public view returns (IGuardiansRegistration) {

        return IGuardiansRegistration(contractRegistry.get("guardiansRegistration"));
    }

    function getCertificationContract() public view returns (ICertification) {

        return ICertification(contractRegistry.get("certification"));
    }

    function getStakingContract() public view returns (IStakingContract) {

        return IStakingContract(contractRegistry.get("staking"));
    }

    function getSubscriptionsContract() public view returns (ISubscriptions) {

        return ISubscriptions(contractRegistry.get("subscriptions"));
    }

    function getStakingRewardsWallet() public view returns (IProtocolWallet) {

        return IProtocolWallet(contractRegistry.get("stakingRewardsWallet"));
    }

    function getBootstrapRewardsWallet() public view returns (IProtocolWallet) {

        return IProtocolWallet(contractRegistry.get("bootstrapRewardsWallet"));
    }

}


pragma solidity 0.5.16;


contract WithClaimableFunctionalOwnership is Context{

    address private _functionalOwner;
    address pendingFunctionalOwner;

    event FunctionalOwnershipTransferred(address indexed previousFunctionalOwner, address indexed newFunctionalOwner);

    constructor () internal {
        address msgSender = _msgSender();
        _functionalOwner = msgSender;
        emit FunctionalOwnershipTransferred(address(0), msgSender);
    }

    function functionalOwner() public view returns (address) {

        return _functionalOwner;
    }

    modifier onlyFunctionalOwner() {

        require(isFunctionalOwner(), "WithClaimableFunctionalOwnership: caller is not the functionalOwner");
        _;
    }

    function isFunctionalOwner() public view returns (bool) {

        return _msgSender() == _functionalOwner;
    }

    function renounceFunctionalOwnership() public onlyFunctionalOwner {

        emit FunctionalOwnershipTransferred(_functionalOwner, address(0));
        _functionalOwner = address(0);
    }

    function _transferFunctionalOwnership(address newFunctionalOwner) internal {

        require(newFunctionalOwner != address(0), "FunctionalOwner: new functionalOwner is the zero address");
        emit FunctionalOwnershipTransferred(_functionalOwner, newFunctionalOwner);
        _functionalOwner = newFunctionalOwner;
    }

    modifier onlyPendingFunctionalOwner() {

        require(msg.sender == pendingFunctionalOwner, "Caller is not the pending functionalOwner");
        _;
    }
    function transferFunctionalOwnership(address newFunctionalOwner) public onlyFunctionalOwner {

        pendingFunctionalOwner = newFunctionalOwner;
    }
    function claimFunctionalOwnership() external onlyPendingFunctionalOwner {

        _transferFunctionalOwnership(pendingFunctionalOwner);
        pendingFunctionalOwner = address(0);
    }
}


pragma solidity 0.5.16;













contract Delegations is IDelegations, IStakeChangeNotifier, ContractRegistryAccessor, WithClaimableFunctionalOwnership, Lockable {

	using SafeMath for uint256;
	using SafeMath for uint128;

	struct StakeOwnerData {
		address delegation;
		bool isSelfStakeInitialized;
	}
	mapping (address => StakeOwnerData) stakeOwnersData;
	mapping (address => uint256) uncappedStakes;

	uint256 totalDelegatedStake;

	modifier onlyStakingContract() {

		require(msg.sender == address(getStakingContract()), "caller is not the staking contract");

		_;
	}

	constructor() public {}

	function getTotalDelegatedStake() external view returns (uint256) {

		return totalDelegatedStake;
	}

	struct DelegateStatus {
		address addr;
		uint256 uncappedStakes;
		bool isSelfDelegating;
		uint256 delegatedStake;
	}

	function getDelegateStatus(address addr) private view returns (DelegateStatus memory status) {

		status.addr = addr;
		status.uncappedStakes = uncappedStakes[addr];
		status.isSelfDelegating = _isSelfDelegating(addr);
		status.delegatedStake = status.isSelfDelegating ? status.uncappedStakes : 0;

		return status;
	}

	function delegateFrom(address from, address to, bool notifyElections) private {

		address prevDelegate = getDelegation(from);

		require(to != address(0), "cannot delegate to a zero address");

		DelegateStatus memory prevDelegateStatusBefore = getDelegateStatus(prevDelegate);
		DelegateStatus memory newDelegateStatusBefore = getDelegateStatus(to);

		stakeOwnersData[from].delegation = to;

		uint256 delegatorStake = getStakingContract().getStakeBalanceOf(from);

		if (stakeOwnersData[from].isSelfStakeInitialized) {
			uncappedStakes[prevDelegate] = prevDelegateStatusBefore.uncappedStakes.sub(delegatorStake);
		} else {
			stakeOwnersData[from].isSelfStakeInitialized = true;
		}
		uncappedStakes[to] = newDelegateStatusBefore.uncappedStakes.add(delegatorStake);

		DelegateStatus memory prevDelegateStatusAfter = getDelegateStatus(prevDelegate);
		DelegateStatus memory newDelegateStatusAfter = getDelegateStatus(to);

		uint256 _totalDelegatedStake = totalDelegatedStake.sub(
			prevDelegateStatusBefore.delegatedStake
		).add(
			prevDelegateStatusAfter.delegatedStake
		).sub(
			newDelegateStatusBefore.delegatedStake
		).add(
			newDelegateStatusAfter.delegatedStake
		);

		totalDelegatedStake = _totalDelegatedStake;

		if (notifyElections) {
			IElections elections = getElectionsContract();
			IStakingContract staking = getStakingContract();

			elections.delegatedStakeChange(
				prevDelegate,
				staking.getStakeBalanceOf(prevDelegate),
				prevDelegateStatusAfter.delegatedStake,
				_totalDelegatedStake
			);

			elections.delegatedStakeChange(
				to,
				staking.getStakeBalanceOf(to),
				newDelegateStatusAfter.delegatedStake,
				_totalDelegatedStake
			);
		}

		emit Delegated(from, to);

		if (delegatorStake != 0 && prevDelegate != to) {
			emitDelegatedStakeChanged(prevDelegate, from, 0);
			emitDelegatedStakeChanged(to, from, delegatorStake);
		}
	}

	function delegate(address to) external onlyWhenActive {

		delegateFrom(msg.sender, to, true);
	}

	bool public delegationImportFinalized;

	modifier onlyDuringDelegationImport {

		require(!delegationImportFinalized, "delegation import was finalized");

		_;
	}

	function importDelegations(address[] calldata from, address[] calldata to, bool notifyElections) external onlyMigrationOwner onlyDuringDelegationImport {

		require(from.length == to.length, "from and to arrays must be of same length");

		for (uint i = 0; i < from.length; i++) {
			_stakeChange(from[i], 0, true, getStakingContract().getStakeBalanceOf(from[i]), notifyElections);
			delegateFrom(from[i], to[i], notifyElections);
		}

		emit DelegationsImported(from, to, notifyElections);
	}

	function finalizeDelegationImport() external onlyMigrationOwner onlyDuringDelegationImport {

		delegationImportFinalized = true;
		emit DelegationImportFinalized();
	}

	function refreshStakeNotification(address addr) external onlyWhenActive {

		_stakeChange(addr, 0, true, getStakingContract().getStakeBalanceOf(addr), true);
	}

	function stakeChange(address _stakeOwner, uint256 _amount, bool _sign, uint256 _updatedStake) external onlyStakingContract onlyWhenActive {

		_stakeChange(_stakeOwner, _amount, _sign, _updatedStake, true);
	}

	function emitDelegatedStakeChanged(address _delegate, address delegator, uint256 delegatorStake) private {

		address[] memory delegators = new address[](1);
		uint256[] memory delegatorTotalStakes = new uint256[](1);

		delegators[0] = delegator;
		delegatorTotalStakes[0] = delegatorStake;

		emit DelegatedStakeChanged(
			_delegate,
			getSelfDelegatedStake(_delegate),
			uncappedStakes[_delegate],
			delegators,
			delegatorTotalStakes
		);
	}

	function emitDelegatedStakeChangedSlice(address commonDelegate, address[] memory delegators, uint256[] memory delegatorsStakes, uint startIdx, uint sliceLen) private {

		address[] memory delegatorsSlice = new address[](sliceLen);
		uint256[] memory delegatorTotalStakesSlice = new uint256[](sliceLen);

		for (uint j = 0; j < sliceLen; j++) {
			delegatorsSlice[j] = delegators[j + startIdx];
			delegatorTotalStakesSlice[j] = delegatorsStakes[j + startIdx];
		}

		emit DelegatedStakeChanged(
			commonDelegate,
			getSelfDelegatedStake(commonDelegate),
			uncappedStakes[commonDelegate],
			delegatorsSlice,
			delegatorTotalStakesSlice
		);
	}

	function stakeChangeBatch(address[] calldata _stakeOwners, uint256[] calldata _amounts, bool[] calldata _signs, uint256[] calldata _updatedStakes) external onlyStakingContract onlyWhenActive {

		uint batchLength = _stakeOwners.length;
		require(batchLength == _amounts.length, "_stakeOwners, _amounts - array length mismatch");
		require(batchLength == _signs.length, "_stakeOwners, _signs - array length mismatch");
		require(batchLength == _updatedStakes.length, "_stakeOwners, _updatedStakes - array length mismatch");

		_processStakeChangeBatch(_stakeOwners, _amounts, _signs, _updatedStakes);
	}

	function getDelegation(address addr) public view returns (address) {

		return getStakeOwnerData(addr).delegation;
	}

	function getStakeOwnerData(address addr) private view returns (StakeOwnerData memory data) {

		data = stakeOwnersData[addr];
		data.delegation = (data.delegation == address(0)) ? addr : data.delegation;
		return data;
	}

	function stakeMigration(address _stakeOwner, uint256 _amount) external onlyStakingContract onlyWhenActive {}


	function _processStakeChangeBatch(address[] memory stakeOwners, uint256[] memory amounts, bool[] memory signs, uint256[] memory updatedStakes) private {

		uint delegateSelfStake;

		uint i = 0;
		while (i < stakeOwners.length) {
			StakeOwnerData memory curStakeOwnerData = getStakeOwnerData(stakeOwners[i]);
			address sequenceDelegate = curStakeOwnerData.delegation;
			uint currentUncappedStake = uncappedStakes[sequenceDelegate];
			uint prevUncappedStake = currentUncappedStake;

			uint sequenceStartIdx = i;
			for (i = sequenceStartIdx; i < stakeOwners.length; i++) { // aggregate sequence stakes changes
				if (i != sequenceStartIdx) curStakeOwnerData = getStakeOwnerData(stakeOwners[i]);
				if (sequenceDelegate != curStakeOwnerData.delegation) break;

				if (!curStakeOwnerData.isSelfStakeInitialized) {
					amounts[i] = updatedStakes[i];
					signs[i] = true;
					stakeOwnersData[stakeOwners[i]].isSelfStakeInitialized = true;
				}

				currentUncappedStake = signs[i] ?
					currentUncappedStake.add(amounts[i]) :
					currentUncappedStake.sub(amounts[i]);
			}

			uncappedStakes[sequenceDelegate] = currentUncappedStake;
			emitDelegatedStakeChangedSlice(sequenceDelegate, stakeOwners, updatedStakes, sequenceStartIdx, i - sequenceStartIdx);
			delegateSelfStake = getStakingContract().getStakeBalanceOf(sequenceDelegate);

			if (_isSelfDelegating(sequenceDelegate)) {
				totalDelegatedStake = totalDelegatedStake.sub(prevUncappedStake).add(currentUncappedStake);
			}
		}
	}

	function _stakeChange(address _stakeOwner, uint256 _amount, bool _sign, uint256 _updatedStake, bool notifyElections) private {

		StakeOwnerData memory stakeOwnerData = getStakeOwnerData(_stakeOwner);

		uint256 prevUncappedStake = uncappedStakes[stakeOwnerData.delegation];

		if (!stakeOwnerData.isSelfStakeInitialized) {
			_amount = _updatedStake;
			_sign = true;
			stakeOwnersData[_stakeOwner].isSelfStakeInitialized = true;
		}

		uint256 newUncappedStake = _sign ? prevUncappedStake.add(_amount) : prevUncappedStake.sub(_amount);

		uncappedStakes[stakeOwnerData.delegation] = newUncappedStake;

		bool isSelfDelegating = _isSelfDelegating(stakeOwnerData.delegation);
		uint256 _totalDelegatedStake = totalDelegatedStake;
		if (isSelfDelegating) {
			_totalDelegatedStake = _sign ? _totalDelegatedStake.add(_amount) : _totalDelegatedStake.sub(_amount);
			totalDelegatedStake = _totalDelegatedStake;
		}

		if (notifyElections) {
			getElectionsContract().delegatedStakeChange(
				stakeOwnerData.delegation,
				getStakingContract().getStakeBalanceOf(stakeOwnerData.delegation),
				isSelfDelegating ? newUncappedStake : 0,
				_totalDelegatedStake
			);
		}

		if (_amount > 0) {
			emitDelegatedStakeChanged(stakeOwnerData.delegation, _stakeOwner, _updatedStake);
		}
	}

	function getDelegatedStakes(address addr) external view returns (uint256) {

		return _isSelfDelegating(addr) ? uncappedStakes[addr] : 0;
	}

	function getSelfDelegatedStake(address addr) public view returns (uint256) {

		return _isSelfDelegating(addr) ? getStakingContract().getStakeBalanceOf(addr) : 0;
	}

	function _isSelfDelegating(address addr) private view returns (bool) {

		return  getDelegation(addr) == addr;
	}
}