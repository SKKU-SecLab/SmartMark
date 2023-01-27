

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

interface IContractRegistry {


	event ContractAddressUpdated(string contractName, address addr);

	function set(string calldata contractName, address addr) external /* onlyGovernor */;


	function get(string calldata contractName) external view returns (address);

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

interface IProtocol {

    event ProtocolVersionChanged(string deploymentSubset, uint256 currentVersion, uint256 nextVersion, uint256 fromTimestamp);


    function deploymentSubsetExists(string calldata deploymentSubset) external view returns (bool);


    function getProtocolVersion(string calldata deploymentSubset) external view returns (uint256);



    function createDeploymentSubset(string calldata deploymentSubset, uint256 initialProtocolVersion) external /* onlyFunctionalOwner */;


    function setProtocolVersion(string calldata deploymentSubset, uint256 nextVersion, uint256 fromTimestamp) external /* onlyFunctionalOwner */;

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


pragma solidity 0.5.16;



interface ICertification /* is Ownable */ {

	event GuardianCertificationUpdate(address guardian, bool isCertified);


	function isGuardianCertified(address addr) external view returns (bool isCertified);


	function setGuardianCertification(address addr, bool isCertified) external /* Owner only */ ;



	function setContractRegistry(IContractRegistry _contractRegistry) external /* onlyMigrationOwner */;


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










contract ERC20AccessorWithTokenGranularity {


    uint constant TOKEN_GRANULARITY = 1000000000000000;

    function toUint48Granularity(uint256 v) internal pure returns (uint48) {

        return uint48(v / TOKEN_GRANULARITY);
    }

    function toUint256Granularity(uint48 v) internal pure returns (uint256) {

        return uint256(v) * TOKEN_GRANULARITY;
    }

    function transferFrom(IERC20 erc20, address sender, address recipient, uint48 amount) internal returns (bool) {

        return erc20.transferFrom(sender, recipient, toUint256Granularity(amount));
    }

    function transfer(IERC20 erc20, address recipient, uint48 amount) internal returns (bool) {

        return erc20.transfer(recipient, toUint256Granularity(amount));
    }

    function approve(IERC20 erc20, address spender, uint48 amount) internal returns (bool) {

        return erc20.approve(spender, toUint256Granularity(amount));
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










contract Rewards is IRewards, ContractRegistryAccessor, ERC20AccessorWithTokenGranularity, WithClaimableFunctionalOwnership, Lockable {

    using SafeMath for uint256;
    using SafeMath for uint48;

    struct Settings {
        uint48 generalCommitteeAnnualBootstrap;
        uint48 certificationCommitteeAnnualBootstrap;
        uint48 annualRateInPercentMille;
        uint48 annualCap;
        uint32 maxDelegatorsStakingRewardsPercentMille;
    }
    Settings settings;

    struct PoolsAndTotalBalances {
        uint48 bootstrapPool;
        uint48 stakingPool;
        uint48 bootstrapRewardsTotalBalance;
        uint48 feesTotalBalance;
        uint48 stakingRewardsTotalBalance;
    }
    PoolsAndTotalBalances poolsAndTotalBalances;

    struct Balance {
        uint48 bootstrapRewards;
        uint48 fees;
        uint48 stakingRewards;
    }
    mapping(address => Balance) balances;

    uint256 constant feeBucketTimePeriod = 30 days;
    mapping(uint256 => uint256) generalFeePoolBuckets;
    mapping(uint256 => uint256) certifiedFeePoolBuckets;

    IERC20 bootstrapToken;
    IERC20 erc20;
    uint256 lastAssignedAt;

    modifier onlyCommitteeContract() {

        require(msg.sender == address(getCommitteeContract()), "caller is not the committee contract");

        _;
    }

    constructor(IERC20 _erc20, IERC20 _bootstrapToken) public {
        require(address(_bootstrapToken) != address(0), "bootstrapToken must not be 0");
        require(address(_erc20) != address(0), "erc20 must not be 0");

        erc20 = _erc20;
        bootstrapToken = _bootstrapToken;

        lastAssignedAt = now;
    }


    function setGeneralCommitteeAnnualBootstrap(uint256 annual_amount) external onlyFunctionalOwner onlyWhenActive {

        settings.generalCommitteeAnnualBootstrap = toUint48Granularity(annual_amount);
    }

    function setCertificationCommitteeAnnualBootstrap(uint256 annual_amount) external onlyFunctionalOwner onlyWhenActive {

        settings.certificationCommitteeAnnualBootstrap = toUint48Granularity(annual_amount);
    }

    function setMaxDelegatorsStakingRewardsPercentMille(uint32 maxDelegatorsStakingRewardsPercentMille) external onlyFunctionalOwner onlyWhenActive {

        require(maxDelegatorsStakingRewardsPercentMille <= 100000, "maxDelegatorsStakingRewardsPercentMille must not be larger than 100000");
        settings.maxDelegatorsStakingRewardsPercentMille = maxDelegatorsStakingRewardsPercentMille;
        emit MaxDelegatorsStakingRewardsChanged(maxDelegatorsStakingRewardsPercentMille);
    }

    function topUpBootstrapPool(uint256 amount) external onlyWhenActive {

        uint48 _amount48 = toUint48Granularity(amount);
        uint48 bootstrapPool = poolsAndTotalBalances.bootstrapPool + _amount48;
        poolsAndTotalBalances.bootstrapPool = bootstrapPool;

        IERC20 _bootstrapToken = bootstrapToken;
        require(transferFrom(_bootstrapToken, msg.sender, address(this), _amount48), "Rewards::topUpFixedPool - insufficient allowance");

        IProtocolWallet wallet = getBootstrapRewardsWallet();
        require(_bootstrapToken.approve(address(wallet), amount), "Rewards::topUpBootstrapPool - approve failed");
        wallet.topUp(amount);

        emit BootstrapAddedToPool(amount, toUint256Granularity(bootstrapPool));
    }

    function getBootstrapBalance(address addr) external view returns (uint256) {

        return toUint256Granularity(balances[addr].bootstrapRewards);
    }

    function assignRewards() public onlyWhenActive {

        (address[] memory committee, uint256[] memory weights, bool[] memory certification) = getCommitteeContract().getCommittee();
        _assignRewardsToCommittee(committee, weights, certification);
    }

    function assignRewardsToCommittee(address[] calldata committee, uint256[] calldata committeeWeights, bool[] calldata certification) external onlyCommitteeContract onlyWhenActive {

        _assignRewardsToCommittee(committee, committeeWeights, certification);
    }

    struct Totals {
        uint48 bootstrapRewardsTotalBalance;
        uint48 feesTotalBalance;
        uint48 stakingRewardsTotalBalance;
    }

    function _assignRewardsToCommittee(address[] memory committee, uint256[] memory committeeWeights, bool[] memory certification) private {

        Settings memory _settings = settings;

        (uint256 generalGuardianBootstrap, uint256 certifiedGuardianBootstrap) = collectBootstrapRewards(_settings);
        (uint256 generalGuardianFee, uint256 certifiedGuardianFee) = collectFees(committee, certification);
        (uint256[] memory stakingRewards) = collectStakingRewards(committee, committeeWeights, _settings);

        PoolsAndTotalBalances memory totals = poolsAndTotalBalances;

        Totals memory origTotals = Totals({
            bootstrapRewardsTotalBalance: totals.bootstrapRewardsTotalBalance,
            feesTotalBalance: totals.feesTotalBalance,
            stakingRewardsTotalBalance: totals.stakingRewardsTotalBalance
        });

        Balance memory balance;
        for (uint i = 0; i < committee.length; i++) {
            balance = balances[committee[i]];

            balance.bootstrapRewards += toUint48Granularity(certification[i] ? certifiedGuardianBootstrap : generalGuardianBootstrap);
            balance.fees += toUint48Granularity(certification[i] ? certifiedGuardianFee : generalGuardianFee);
            balance.stakingRewards += toUint48Granularity(stakingRewards[i]);

            totals.bootstrapRewardsTotalBalance += toUint48Granularity(certification[i] ? certifiedGuardianBootstrap : generalGuardianBootstrap);
            totals.feesTotalBalance += toUint48Granularity(certification[i] ? certifiedGuardianFee : generalGuardianFee);
            totals.stakingRewardsTotalBalance += toUint48Granularity(stakingRewards[i]);

            balances[committee[i]] = balance;
        }

        getStakingRewardsWallet().withdraw(toUint256Granularity(uint48(totals.stakingRewardsTotalBalance.sub(origTotals.stakingRewardsTotalBalance))));
        getBootstrapRewardsWallet().withdraw(toUint256Granularity(uint48(totals.bootstrapRewardsTotalBalance.sub(origTotals.bootstrapRewardsTotalBalance))));

        poolsAndTotalBalances = totals;
        lastAssignedAt = now;

        emit StakingRewardsAssigned(committee, stakingRewards);
        emit BootstrapRewardsAssigned(generalGuardianBootstrap, certifiedGuardianBootstrap);
        emit FeesAssigned(generalGuardianFee, certifiedGuardianFee);
    }

    function collectBootstrapRewards(Settings memory _settings) private view returns (uint256 generalGuardianBootstrap, uint256 certifiedGuardianBootstrap){

        uint256 duration = now.sub(lastAssignedAt);
        generalGuardianBootstrap = toUint256Granularity(uint48(_settings.generalCommitteeAnnualBootstrap.mul(duration).div(365 days)));
        certifiedGuardianBootstrap = generalGuardianBootstrap + toUint256Granularity(uint48(_settings.certificationCommitteeAnnualBootstrap.mul(duration).div(365 days)));
    }

    function withdrawBootstrapFunds() external onlyWhenActive {

        uint48 amount = balances[msg.sender].bootstrapRewards;

        PoolsAndTotalBalances memory _poolsAndTotalBalances = poolsAndTotalBalances;

        require(amount <= _poolsAndTotalBalances.bootstrapPool, "not enough balance in the bootstrap pool for this withdrawal");
        balances[msg.sender].bootstrapRewards = 0;
        _poolsAndTotalBalances.bootstrapRewardsTotalBalance = uint48(_poolsAndTotalBalances.bootstrapRewardsTotalBalance.sub(amount));
        _poolsAndTotalBalances.bootstrapPool = uint48(_poolsAndTotalBalances.bootstrapPool.sub(amount));
        poolsAndTotalBalances = _poolsAndTotalBalances;

        emit BootstrapRewardsWithdrawn(msg.sender, toUint256Granularity(amount));
        require(transfer(bootstrapToken, msg.sender, amount), "Rewards::withdrawBootstrapFunds - insufficient funds");
    }


    function setAnnualStakingRewardsRate(uint256 annual_rate_in_percent_mille, uint256 annual_cap) external onlyFunctionalOwner onlyWhenActive {

        Settings memory _settings = settings;
        _settings.annualRateInPercentMille = uint48(annual_rate_in_percent_mille);
        _settings.annualCap = toUint48Granularity(annual_cap);
        settings = _settings;
    }

    function topUpStakingRewardsPool(uint256 amount) external onlyWhenActive {

        uint48 amount48 = toUint48Granularity(amount);
        uint48 total48 = poolsAndTotalBalances.stakingPool + amount48;
        poolsAndTotalBalances.stakingPool = total48;

        IERC20 _erc20 = erc20;
        require(_erc20.transferFrom(msg.sender, address(this), amount), "Rewards::topUpProRataPool - insufficient allowance");

        IProtocolWallet wallet = getStakingRewardsWallet();
        require(_erc20.approve(address(wallet), amount), "Rewards::topUpProRataPool - approve failed");
        wallet.topUp(amount);

        emit StakingRewardsAddedToPool(amount, toUint256Granularity(total48));
    }

    function getStakingRewardBalance(address addr) external view returns (uint256) {

        return toUint256Granularity(balances[addr].stakingRewards);
    }

    function getLastRewardAssignmentTime() external view returns (uint256) {

        return lastAssignedAt;
    }

    function collectStakingRewards(address[] memory committee, uint256[] memory weights, Settings memory _settings) private view returns (uint256[] memory assignedRewards) {

        assignedRewards = new uint256[](committee.length);

        uint256 totalWeight = 0;
        for (uint i = 0; i < committee.length; i++) {
            totalWeight = totalWeight.add(weights[i]);
        }

        if (totalWeight > 0) { // TODO - handle the case of totalStake == 0. consider also an empty committee. consider returning a boolean saying if the amount was successfully distributed or not and handle on caller side.
            uint256 duration = now.sub(lastAssignedAt);

            uint annualRateInPercentMille = Math.min(uint(_settings.annualRateInPercentMille), toUint256Granularity(_settings.annualCap).mul(100000).div(totalWeight));
            uint48 curAmount;
            for (uint i = 0; i < committee.length; i++) {
                curAmount = toUint48Granularity(weights[i].mul(annualRateInPercentMille).mul(duration).div(36500000 days));
                assignedRewards[i] = toUint256Granularity(curAmount);
            }
        }
    }

    struct DistributorBatchState {
        uint256 fromBlock;
        uint256 toBlock;
        uint256 nextTxIndex;
        uint split;
    }
    mapping (address => DistributorBatchState) distributorBatchState;

    function isDelegatorRewardsBelowThreshold(uint256 delegatorRewards, uint256 totalRewards) private view returns (bool) {

        return delegatorRewards.mul(100000) <= uint(settings.maxDelegatorsStakingRewardsPercentMille).mul(totalRewards.add(toUint256Granularity(1))); // +1 is added to account for rounding errors
    }

    struct VistributeOrbsTokenStakingRewardsVars {
        bool firstTxBySender;
        address guardianAddr;
        uint256 delegatorsAmount;
    }
    function distributeOrbsTokenStakingRewards(uint256 totalAmount, uint256 fromBlock, uint256 toBlock, uint split, uint txIndex, address[] calldata to, uint256[] calldata amounts) external onlyWhenActive {

        require(to.length > 0, "list must containt at least one recipient");
        require(to.length == amounts.length, "expected to and amounts to be of same length");
        uint48 totalAmount_uint48 = toUint48Granularity(totalAmount);
        require(totalAmount == toUint256Granularity(totalAmount_uint48), "totalAmount must divide by 1e15");

        VistributeOrbsTokenStakingRewardsVars memory vars;

        vars.guardianAddr = getGuardiansRegistrationContract().resolveGuardianAddress(msg.sender);

        for (uint i = 0; i < to.length; i++) {
            if (to[i] != vars.guardianAddr) {
                vars.delegatorsAmount = vars.delegatorsAmount.add(amounts[i]);
            }
        }
        require(isDelegatorRewardsBelowThreshold(vars.delegatorsAmount, totalAmount), "Total delegators reward (to[1:n]) must be less then maxDelegatorsStakingRewardsPercentMille of total amount");

        DistributorBatchState memory ds = distributorBatchState[vars.guardianAddr];
        vars.firstTxBySender = ds.nextTxIndex == 0;

        require(!vars.firstTxBySender || fromBlock == 0, "on the first batch fromBlock must be 0");

        if (vars.firstTxBySender || fromBlock == ds.toBlock + 1) { // New distribution batch
            require(txIndex == 0, "txIndex must be 0 for the first transaction of a new distribution batch");
            require(toBlock < block.number, "toBlock must be in the past");
            require(toBlock >= fromBlock, "toBlock must be at least fromBlock");
            ds.fromBlock = fromBlock;
            ds.toBlock = toBlock;
            ds.split = split;
            ds.nextTxIndex = 1;
            distributorBatchState[vars.guardianAddr] = ds;
        } else {
            require(txIndex == ds.nextTxIndex, "txIndex mismatch");
            require(toBlock == ds.toBlock, "toBlock mismatch");
            require(fromBlock == ds.fromBlock, "fromBlock mismatch");
            require(split == ds.split, "split mismatch");
            distributorBatchState[vars.guardianAddr].nextTxIndex = txIndex + 1;
        }

        require(totalAmount_uint48 <= balances[vars.guardianAddr].stakingRewards, "not enough member balance for this distribution");

        PoolsAndTotalBalances memory _poolsAndTotalBalances = poolsAndTotalBalances;

        require(totalAmount_uint48 <= _poolsAndTotalBalances.stakingPool, "not enough balance in the staking pool for this distribution");

        _poolsAndTotalBalances.stakingPool = uint48(_poolsAndTotalBalances.stakingPool.sub(totalAmount_uint48));
        balances[vars.guardianAddr].stakingRewards = uint48(balances[vars.guardianAddr].stakingRewards.sub(totalAmount_uint48));
        _poolsAndTotalBalances.stakingRewardsTotalBalance = uint48(_poolsAndTotalBalances.stakingRewardsTotalBalance.sub(totalAmount_uint48));

        poolsAndTotalBalances = _poolsAndTotalBalances;

        IStakingContract stakingContract = getStakingContract();

        approve(erc20, address(stakingContract), totalAmount_uint48);
        stakingContract.distributeRewards(totalAmount, to, amounts); // TODO should we rely on staking contract to verify total amount?

        getDelegationsContract().refreshStakeNotification(vars.guardianAddr);

        emit StakingRewardsDistributed(vars.guardianAddr, fromBlock, toBlock, split, txIndex, to, amounts);
    }


    function getFeeBalance(address addr) external view returns (uint256) {

        return toUint256Granularity(balances[addr].fees);
    }

    uint constant MAX_FEE_BUCKET_ITERATIONS = 24;

    function collectFees(address[] memory committee, bool[] memory certification) private returns (uint256 generalGuardianFee, uint256 certifiedGuardianFee) {


        uint _lastAssignedAt = lastAssignedAt;
        uint bucketsPayed = 0;
        uint generalFeePoolAmount = 0;
        uint certificationFeePoolAmount = 0;
        while (bucketsPayed < MAX_FEE_BUCKET_ITERATIONS && _lastAssignedAt < now) {
            uint256 bucketStart = _bucketTime(_lastAssignedAt);
            uint256 bucketEnd = bucketStart.add(feeBucketTimePeriod);
            uint256 payUntil = Math.min(bucketEnd, now);
            uint256 bucketDuration = payUntil.sub(_lastAssignedAt);
            uint256 remainingBucketTime = bucketEnd.sub(_lastAssignedAt);

            uint256 bucketTotal = generalFeePoolBuckets[bucketStart];
            uint256 amount = bucketTotal * bucketDuration / remainingBucketTime;
            generalFeePoolAmount += amount;
            bucketTotal = bucketTotal.sub(amount);
            generalFeePoolBuckets[bucketStart] = bucketTotal;
            emit FeesWithdrawnFromBucket(bucketStart, amount, bucketTotal, false);

            bucketTotal = certifiedFeePoolBuckets[bucketStart];
            amount = bucketTotal * bucketDuration / remainingBucketTime;
            certificationFeePoolAmount += amount;
            bucketTotal = bucketTotal.sub(amount);
            certifiedFeePoolBuckets[bucketStart] = bucketTotal;
            emit FeesWithdrawnFromBucket(bucketStart, amount, bucketTotal, true);

            _lastAssignedAt = payUntil;

            assert(_lastAssignedAt <= bucketEnd);
            if (_lastAssignedAt == bucketEnd) {
                delete generalFeePoolBuckets[bucketStart];
                delete certifiedFeePoolBuckets[bucketStart];
            }

            bucketsPayed++;
        }

        generalGuardianFee = divideFees(committee, certification, generalFeePoolAmount, false);
        certifiedGuardianFee = generalGuardianFee + divideFees(committee, certification, certificationFeePoolAmount, true);
    }

    function divideFees(address[] memory committee, bool[] memory certification, uint256 amount, bool isCertified) private returns (uint256 guardianFee) {

        uint n = committee.length;
        if (isCertified)  {
            n = 0;
            for (uint i = 0; i < committee.length; i++) {
                if (certification[i]) n++;
            }
        }
        if (n > 0) {
            guardianFee = toUint256Granularity(toUint48Granularity(amount.div(n)));
        }

        uint256 remainder = amount.sub(guardianFee.mul(n));
        if (remainder > 0) {
            fillFeeBucket(_bucketTime(now), remainder, isCertified);
        }
    }

    function fillGeneralFeeBuckets(uint256 amount, uint256 monthlyRate, uint256 fromTimestamp) external onlyWhenActive {

        fillFeeBuckets(amount, monthlyRate, fromTimestamp, false);
    }

    function fillCertificationFeeBuckets(uint256 amount, uint256 monthlyRate, uint256 fromTimestamp) external onlyWhenActive {

        fillFeeBuckets(amount, monthlyRate, fromTimestamp, true);
    }

    function fillFeeBucket(uint256 bucketId, uint256 amount, bool isCertified) private {

        uint256 total;
        if (isCertified) {
            total = certifiedFeePoolBuckets[bucketId].add(amount);
            certifiedFeePoolBuckets[bucketId] = total;
        } else {
            total = generalFeePoolBuckets[bucketId].add(amount);
            generalFeePoolBuckets[bucketId] = total;
        }

        emit FeesAddedToBucket(bucketId, amount, total, isCertified);
    }

    function fillFeeBuckets(uint256 amount, uint256 monthlyRate, uint256 fromTimestamp, bool isCertified) private {

        assignRewards(); // to handle rate change in the middle of a bucket time period (TBD - this is nice to have, consider removing)

        uint256 bucket = _bucketTime(fromTimestamp);
        uint256 _amount = amount;

        uint256 bucketAmount = Math.min(amount, monthlyRate.mul(feeBucketTimePeriod - fromTimestamp % feeBucketTimePeriod).div(feeBucketTimePeriod));
        fillFeeBucket(bucket, bucketAmount, isCertified);
        _amount = _amount.sub(bucketAmount);

        while (_amount > 0) {
            bucket = bucket.add(feeBucketTimePeriod);
            bucketAmount = Math.min(monthlyRate, _amount);
            fillFeeBucket(bucket, bucketAmount, isCertified);
            _amount = _amount.sub(bucketAmount);
        }

        assert(_amount == 0);

        require(erc20.transferFrom(msg.sender, address(this), amount), "failed to transfer subscription fees from subscriptions to rewards");
    }

    function withdrawFeeFunds() external onlyWhenActive {

        uint48 amount = balances[msg.sender].fees;
        balances[msg.sender].fees = 0;
        poolsAndTotalBalances.feesTotalBalance = uint48(poolsAndTotalBalances.feesTotalBalance.sub(amount));
        emit FeesWithdrawn(msg.sender, toUint256Granularity(amount));
        require(transfer(erc20, msg.sender, amount), "Rewards::claimExternalTokenRewards - insufficient funds");
    }

    function getTotalBalances() external view returns (uint256 feesTotalBalance, uint256 stakingRewardsTotalBalance, uint256 bootstrapRewardsTotalBalance) {

        PoolsAndTotalBalances memory totals = poolsAndTotalBalances;
        return (toUint256Granularity(totals.feesTotalBalance), toUint256Granularity(totals.stakingRewardsTotalBalance), toUint256Granularity(totals.bootstrapRewardsTotalBalance));
    }

    function _bucketTime(uint256 time) private pure returns (uint256) {

        return time - time % feeBucketTimePeriod;
    }

    function emergencyWithdraw() external onlyMigrationOwner {

        emit EmergencyWithdrawal(msg.sender);
        require(erc20.transfer(msg.sender, erc20.balanceOf(address(this))), "Rewards::emergencyWithdraw - transfer failed (fee token)");
        require(bootstrapToken.transfer(msg.sender, bootstrapToken.balanceOf(address(this))), "Rewards::emergencyWithdraw - transfer failed (bootstrap token)");
    }

}