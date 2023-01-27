


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

library SafeMath96 {

    function add(uint96 a, uint256 b) internal pure returns (uint96) {

        require(uint256(uint96(b)) == b, "SafeMath: addition overflow");
        uint96 c = a + uint96(b);
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    function sub(uint96 a, uint256 b) internal pure returns (uint96) {

        require(uint256(uint96(b)) == b, "SafeMath: subtraction overflow");
        return sub(a, uint96(b), "SafeMath: subtraction overflow");
    }

    function sub(uint96 a, uint96 b, string memory errorMessage) internal pure returns (uint96) {

        require(b <= a, errorMessage);
        uint96 c = a - b;

        return c;
    }

}


pragma solidity ^0.6.0;

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


pragma solidity ^0.6.0;

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


interface IProtocolWallet {

    event FundsAddedToPool(uint256 added, uint256 total);


    function getBalance() external view returns (uint256 balance);


    function topUp(uint256 amount) external;


    function withdraw(uint256 amount) external; /* onlyClient */




    event ClientSet(address client);
    event MaxAnnualRateSet(uint256 maxAnnualRate);
    event EmergencyWithdrawal(address addr, address token);
    event OutstandingTokensReset(uint256 startTime);

    function setMaxAnnualRate(uint256 _annualRate) external; /* onlyMigrationOwner */


    function getMaxAnnualRate() external view returns (uint256);


    function resetOutstandingTokens(uint256 startTime) external; /* onlyMigrationOwner */


    function emergencyWithdraw(address erc20) external; /* onlyMigrationOwner */


    function setClient(address _client) external; /* onlyFunctionalOwner */


}


pragma solidity 0.6.12;

interface IMigratableFeesWallet {


    function acceptBucketMigration(uint256 bucketStartTime, uint256 amount) external;

}


pragma solidity 0.6.12;


interface IFeesWallet {


    event FeesWithdrawnFromBucket(uint256 bucketId, uint256 withdrawn, uint256 total);
    event FeesAddedToBucket(uint256 bucketId, uint256 added, uint256 total);


    function fillFeeBuckets(uint256 amount, uint256 monthlyRate, uint256 fromTimestamp) external;


    function collectFees() external returns (uint256 collectedFees) /* onlyRewardsContract */;


    function getOutstandingFees(uint256 currentTime) external view returns (uint256 outstandingFees);



    event EmergencyWithdrawal(address addr, address token);

    function migrateBucket(IMigratableFeesWallet destination, uint256 bucketStartTime) external /* onlyMigrationManager */;


    function acceptBucketMigration(uint256 bucketStartTime, uint256 amount) external;


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










contract FeesAndBootstrapRewards is IFeesAndBootstrapRewards, ManagedContract {

    using SafeMath for uint256;
    using SafeMath96 for uint96;

    uint256 constant PERCENT_MILLIE_BASE = 100000;
    uint256 constant TOKEN_BASE = 1e18;

    struct Settings {
        uint96 generalCommitteeAnnualBootstrap;
        uint96 certifiedCommitteeAnnualBootstrap;
        bool rewardAllocationActive;
    }
    Settings settings;

    IERC20 public bootstrapToken;
    IERC20 public feesToken;

    struct FeesAndBootstrapState {
        uint96 certifiedFeesPerMember;
        uint96 generalFeesPerMember;
        uint96 certifiedBootstrapPerMember;
        uint96 generalBootstrapPerMember;
        uint32 lastAssigned;
    }
    FeesAndBootstrapState public feesAndBootstrapState;

    struct FeesAndBootstrap {
        uint96 feeBalance;
        uint96 bootstrapBalance;
        uint96 lastFeesPerMember;
        uint96 lastBootstrapPerMember;
        uint96 withdrawnFees;
        uint96 withdrawnBootstrap;
    }
    mapping(address => FeesAndBootstrap) public feesAndBootstrap;

    constructor(
        IContractRegistry _contractRegistry,
        address _registryAdmin,
        IERC20 _feesToken,
        IERC20 _bootstrapToken,
        uint generalCommitteeAnnualBootstrap,
        uint certifiedCommitteeAnnualBootstrap
    ) ManagedContract(_contractRegistry, _registryAdmin) public {
        require(address(_bootstrapToken) != address(0), "bootstrapToken must not be 0");
        require(address(_feesToken) != address(0), "feeToken must not be 0");

        _setGeneralCommitteeAnnualBootstrap(generalCommitteeAnnualBootstrap);
        _setCertifiedCommitteeAnnualBootstrap(certifiedCommitteeAnnualBootstrap);

        feesToken = _feesToken;
        bootstrapToken = _bootstrapToken;
    }

    modifier onlyCommitteeContract() {

        require(msg.sender == address(committeeContract), "caller is not the elections contract");

        _;
    }


    function committeeMembershipWillChange(address guardian, bool inCommittee, bool isCertified, bool nextCertification, uint generalCommitteeSize, uint certifiedCommitteeSize) external override onlyWhenActive onlyCommitteeContract {

        _updateGuardianFeesAndBootstrap(guardian, inCommittee, isCertified, nextCertification, generalCommitteeSize, certifiedCommitteeSize);
    }

    function getFeesAndBootstrapBalance(address guardian) external override view returns (uint256 feeBalance, uint256 bootstrapBalance) {

        (FeesAndBootstrap memory guardianFeesAndBootstrap,) = getGuardianFeesAndBootstrap(guardian, block.timestamp);
        return (guardianFeesAndBootstrap.feeBalance, guardianFeesAndBootstrap.bootstrapBalance);
    }

    function estimateFutureFeesAndBootstrapRewards(address guardian, uint256 duration) external override view returns (uint256 estimatedFees, uint256 estimatedBootstrapRewards) {

        (FeesAndBootstrap memory guardianFeesAndBootstrapNow,) = getGuardianFeesAndBootstrap(guardian, block.timestamp);
        (FeesAndBootstrap memory guardianFeesAndBootstrapFuture,) = getGuardianFeesAndBootstrap(guardian, block.timestamp.add(duration));
        estimatedFees = guardianFeesAndBootstrapFuture.feeBalance.sub(guardianFeesAndBootstrapNow.feeBalance);
        estimatedBootstrapRewards = guardianFeesAndBootstrapFuture.bootstrapBalance.sub(guardianFeesAndBootstrapNow.bootstrapBalance);
    }

    function withdrawFees(address guardian) external override onlyWhenActive {

        updateGuardianFeesAndBootstrap(guardian);

        uint256 amount = feesAndBootstrap[guardian].feeBalance;
        feesAndBootstrap[guardian].feeBalance = 0;
        uint96 withdrawnFees = feesAndBootstrap[guardian].withdrawnFees.add(amount);
        feesAndBootstrap[guardian].withdrawnFees = withdrawnFees;

        emit FeesWithdrawn(guardian, amount, withdrawnFees);
        require(feesToken.transfer(guardian, amount), "Rewards::withdrawFees - insufficient funds");
    }

    function withdrawBootstrapFunds(address guardian) external override onlyWhenActive {

        updateGuardianFeesAndBootstrap(guardian);
        uint256 amount = feesAndBootstrap[guardian].bootstrapBalance;
        feesAndBootstrap[guardian].bootstrapBalance = 0;
        uint96 withdrawnBootstrap = feesAndBootstrap[guardian].withdrawnBootstrap.add(amount);
        feesAndBootstrap[guardian].withdrawnBootstrap = withdrawnBootstrap;
        emit BootstrapRewardsWithdrawn(guardian, amount, withdrawnBootstrap);

        require(bootstrapToken.transfer(guardian, amount), "Rewards::withdrawBootstrapFunds - insufficient funds");
    }

    function getFeesAndBootstrapState() external override view returns (
        uint256 certifiedFeesPerMember,
        uint256 generalFeesPerMember,
        uint256 certifiedBootstrapPerMember,
        uint256 generalBootstrapPerMember,
        uint256 lastAssigned
    ) {

        (uint generalCommitteeSize, uint certifiedCommitteeSize, ) = committeeContract.getCommitteeStats();
        (FeesAndBootstrapState memory _feesAndBootstrapState,,) = _getFeesAndBootstrapState(generalCommitteeSize, certifiedCommitteeSize, generalFeesWallet.getOutstandingFees(block.timestamp), certifiedFeesWallet.getOutstandingFees(block.timestamp), block.timestamp, settings);
        certifiedFeesPerMember = _feesAndBootstrapState.certifiedFeesPerMember;
        generalFeesPerMember = _feesAndBootstrapState.generalFeesPerMember;
        certifiedBootstrapPerMember = _feesAndBootstrapState.certifiedBootstrapPerMember;
        generalBootstrapPerMember = _feesAndBootstrapState.generalBootstrapPerMember;
        lastAssigned = _feesAndBootstrapState.lastAssigned;
    }

    function getFeesAndBootstrapData(address guardian) external override view returns (
        uint256 feeBalance,
        uint256 lastFeesPerMember,
        uint256 bootstrapBalance,
        uint256 lastBootstrapPerMember,
        uint256 withdrawnFees,
        uint256 withdrawnBootstrap,
        bool certified
    ) {

        FeesAndBootstrap memory guardianFeesAndBootstrap;
        (guardianFeesAndBootstrap, certified) = getGuardianFeesAndBootstrap(guardian, block.timestamp);
        return (
            guardianFeesAndBootstrap.feeBalance,
            guardianFeesAndBootstrap.lastFeesPerMember,
            guardianFeesAndBootstrap.bootstrapBalance,
            guardianFeesAndBootstrap.lastBootstrapPerMember,
            guardianFeesAndBootstrap.withdrawnFees,
            guardianFeesAndBootstrap.withdrawnBootstrap,
            certified
        );
    }


    function activateRewardDistribution(uint startTime) external override onlyMigrationManager {

        require(!settings.rewardAllocationActive, "reward distribution is already activated");

        feesAndBootstrapState.lastAssigned = uint32(startTime);
        settings.rewardAllocationActive = true;

        emit RewardDistributionActivated(startTime);
    }

    function deactivateRewardDistribution() external override onlyMigrationManager {

        require(settings.rewardAllocationActive, "reward distribution is already deactivated");

        updateFeesAndBootstrapState();

        settings.rewardAllocationActive = false;

        emit RewardDistributionDeactivated();
    }

    function isRewardAllocationActive() external override view returns (bool) {

        return settings.rewardAllocationActive;
    }

    function setGeneralCommitteeAnnualBootstrap(uint256 annualAmount) external override onlyFunctionalManager {

        updateFeesAndBootstrapState();
        _setGeneralCommitteeAnnualBootstrap(annualAmount);
    }

    function getGeneralCommitteeAnnualBootstrap() external override view returns (uint256) {

        return settings.generalCommitteeAnnualBootstrap;
    }

    function setCertifiedCommitteeAnnualBootstrap(uint256 annualAmount) external override onlyFunctionalManager {

        updateFeesAndBootstrapState();
        _setCertifiedCommitteeAnnualBootstrap(annualAmount);
    }

    function getCertifiedCommitteeAnnualBootstrap() external override view returns (uint256) {

        return settings.certifiedCommitteeAnnualBootstrap;
    }

    function migrateRewardsBalance(address[] calldata guardians) external override {

        require(!settings.rewardAllocationActive, "Reward distribution must be deactivated for migration");

        IFeesAndBootstrapRewards currentRewardsContract = IFeesAndBootstrapRewards(getFeesAndBootstrapRewardsContract());
        require(address(currentRewardsContract) != address(this), "New rewards contract is not set");

        uint256 totalFees = 0;
        uint256 totalBootstrap = 0;
        uint256[] memory fees = new uint256[](guardians.length);
        uint256[] memory bootstrap = new uint256[](guardians.length);

        for (uint i = 0; i < guardians.length; i++) {
            updateGuardianFeesAndBootstrap(guardians[i]);

            FeesAndBootstrap memory guardianFeesAndBootstrap = feesAndBootstrap[guardians[i]];
            fees[i] = guardianFeesAndBootstrap.feeBalance;
            totalFees = totalFees.add(fees[i]);
            bootstrap[i] = guardianFeesAndBootstrap.bootstrapBalance;
            totalBootstrap = totalBootstrap.add(bootstrap[i]);

            guardianFeesAndBootstrap.feeBalance = 0;
            guardianFeesAndBootstrap.bootstrapBalance = 0;
            feesAndBootstrap[guardians[i]] = guardianFeesAndBootstrap;
        }

        require(feesToken.approve(address(currentRewardsContract), totalFees), "migrateRewardsBalance: approve failed");
        require(bootstrapToken.approve(address(currentRewardsContract), totalBootstrap), "migrateRewardsBalance: approve failed");
        currentRewardsContract.acceptRewardsBalanceMigration(guardians, fees, totalFees, bootstrap, totalBootstrap);

        for (uint i = 0; i < guardians.length; i++) {
            emit FeesAndBootstrapRewardsBalanceMigrated(guardians[i], fees[i], bootstrap[i], address(currentRewardsContract));
        }
    }

    function acceptRewardsBalanceMigration(address[] memory guardians, uint256[] memory fees, uint256 totalFees, uint256[] memory bootstrap, uint256 totalBootstrap) external override {

        uint256 _totalFees = 0;
        uint256 _totalBootstrap = 0;

        for (uint i = 0; i < guardians.length; i++) {
            _totalFees = _totalFees.add(fees[i]);
            _totalBootstrap = _totalBootstrap.add(bootstrap[i]);
        }

        require(totalFees == _totalFees, "totalFees does not match fees sum");
        require(totalBootstrap == _totalBootstrap, "totalBootstrap does not match bootstrap sum");

        if (totalFees > 0) {
            require(feesToken.transferFrom(msg.sender, address(this), totalFees), "acceptRewardBalanceMigration: transfer failed");
        }
        if (totalBootstrap > 0) {
            require(bootstrapToken.transferFrom(msg.sender, address(this), totalBootstrap), "acceptRewardBalanceMigration: transfer failed");
        }

        FeesAndBootstrap memory guardianFeesAndBootstrap;
        for (uint i = 0; i < guardians.length; i++) {
            guardianFeesAndBootstrap = feesAndBootstrap[guardians[i]];
            guardianFeesAndBootstrap.feeBalance = guardianFeesAndBootstrap.feeBalance.add(fees[i]);
            guardianFeesAndBootstrap.bootstrapBalance = guardianFeesAndBootstrap.bootstrapBalance.add(bootstrap[i]);
            feesAndBootstrap[guardians[i]] = guardianFeesAndBootstrap;

            emit FeesAndBootstrapRewardsBalanceMigrationAccepted(msg.sender, guardians[i], fees[i], bootstrap[i]);
        }
    }

    function emergencyWithdraw(address erc20) external override onlyMigrationManager {

        IERC20 _token = IERC20(erc20);
        emit EmergencyWithdrawal(msg.sender, address(_token));
        require(_token.transfer(msg.sender, _token.balanceOf(address(this))), "Rewards::emergencyWithdraw - transfer failed");
    }

    function getSettings() external override view returns (
        uint generalCommitteeAnnualBootstrap,
        uint certifiedCommitteeAnnualBootstrap,
        bool rewardAllocationActive
    ) {

        Settings memory _settings = settings;
        generalCommitteeAnnualBootstrap = _settings.generalCommitteeAnnualBootstrap;
        certifiedCommitteeAnnualBootstrap = _settings.certifiedCommitteeAnnualBootstrap;
        rewardAllocationActive = _settings.rewardAllocationActive;
    }



    function _getFeesAndBootstrapState(uint generalCommitteeSize, uint certifiedCommitteeSize, uint256 collectedGeneralFees, uint256 collectedCertifiedFees, uint256 currentTime, Settings memory _settings) private view returns (FeesAndBootstrapState memory _feesAndBootstrapState, uint256 allocatedGeneralBootstrap, uint256 allocatedCertifiedBootstrap) {

        _feesAndBootstrapState = feesAndBootstrapState;

        if (_settings.rewardAllocationActive) {
            uint256 generalFeesDelta = generalCommitteeSize == 0 ? 0 : collectedGeneralFees.div(generalCommitteeSize);
            uint256 certifiedFeesDelta = certifiedCommitteeSize == 0 ? 0 : generalFeesDelta.add(collectedCertifiedFees.div(certifiedCommitteeSize));

            _feesAndBootstrapState.generalFeesPerMember = _feesAndBootstrapState.generalFeesPerMember.add(generalFeesDelta);
            _feesAndBootstrapState.certifiedFeesPerMember = _feesAndBootstrapState.certifiedFeesPerMember.add(certifiedFeesDelta);

            uint duration = currentTime.sub(_feesAndBootstrapState.lastAssigned);
            uint256 generalBootstrapDelta = uint256(_settings.generalCommitteeAnnualBootstrap).mul(duration).div(365 days);
            uint256 certifiedBootstrapDelta = generalBootstrapDelta.add(uint256(_settings.certifiedCommitteeAnnualBootstrap).mul(duration).div(365 days));

            _feesAndBootstrapState.generalBootstrapPerMember = _feesAndBootstrapState.generalBootstrapPerMember.add(generalBootstrapDelta);
            _feesAndBootstrapState.certifiedBootstrapPerMember = _feesAndBootstrapState.certifiedBootstrapPerMember.add(certifiedBootstrapDelta);
            _feesAndBootstrapState.lastAssigned = uint32(currentTime);

            allocatedGeneralBootstrap = generalBootstrapDelta.mul(generalCommitteeSize);
            allocatedCertifiedBootstrap = certifiedBootstrapDelta.mul(certifiedCommitteeSize);
        }
    }

    function _updateFeesAndBootstrapState(uint generalCommitteeSize, uint certifiedCommitteeSize) private returns (FeesAndBootstrapState memory _feesAndBootstrapState) {

        Settings memory _settings = settings;
        if (!_settings.rewardAllocationActive) {
            return feesAndBootstrapState;
        }

        uint256 collectedGeneralFees = generalFeesWallet.collectFees();
        uint256 collectedCertifiedFees = certifiedFeesWallet.collectFees();
        uint256 allocatedGeneralBootstrap;
        uint256 allocatedCertifiedBootstrap;

        (_feesAndBootstrapState, allocatedGeneralBootstrap, allocatedCertifiedBootstrap) = _getFeesAndBootstrapState(generalCommitteeSize, certifiedCommitteeSize, collectedGeneralFees, collectedCertifiedFees, block.timestamp, _settings);
        bootstrapRewardsWallet.withdraw(allocatedGeneralBootstrap.add(allocatedCertifiedBootstrap));

        feesAndBootstrapState = _feesAndBootstrapState;

        emit FeesAllocated(collectedGeneralFees, _feesAndBootstrapState.generalFeesPerMember, collectedCertifiedFees, _feesAndBootstrapState.certifiedFeesPerMember);
        emit BootstrapRewardsAllocated(allocatedGeneralBootstrap, _feesAndBootstrapState.generalBootstrapPerMember, allocatedCertifiedBootstrap, _feesAndBootstrapState.certifiedBootstrapPerMember);
    }

    function updateFeesAndBootstrapState() private returns (FeesAndBootstrapState memory _feesAndBootstrapState) {

        (uint generalCommitteeSize, uint certifiedCommitteeSize, ) = committeeContract.getCommitteeStats();
        return _updateFeesAndBootstrapState(generalCommitteeSize, certifiedCommitteeSize);
    }


    function _getGuardianFeesAndBootstrap(address guardian, bool inCommittee, bool isCertified, bool nextCertification, FeesAndBootstrapState memory _feesAndBootstrapState) private view returns (FeesAndBootstrap memory guardianFeesAndBootstrap, uint256 addedBootstrapAmount, uint256 addedFeesAmount) {

        guardianFeesAndBootstrap = feesAndBootstrap[guardian];

        if (inCommittee) {
            addedBootstrapAmount = (isCertified ? _feesAndBootstrapState.certifiedBootstrapPerMember : _feesAndBootstrapState.generalBootstrapPerMember).sub(guardianFeesAndBootstrap.lastBootstrapPerMember);
            guardianFeesAndBootstrap.bootstrapBalance = guardianFeesAndBootstrap.bootstrapBalance.add(addedBootstrapAmount);

            addedFeesAmount = (isCertified ? _feesAndBootstrapState.certifiedFeesPerMember : _feesAndBootstrapState.generalFeesPerMember).sub(guardianFeesAndBootstrap.lastFeesPerMember);
            guardianFeesAndBootstrap.feeBalance = guardianFeesAndBootstrap.feeBalance.add(addedFeesAmount);
        }

        guardianFeesAndBootstrap.lastBootstrapPerMember = nextCertification ?  _feesAndBootstrapState.certifiedBootstrapPerMember : _feesAndBootstrapState.generalBootstrapPerMember;
        guardianFeesAndBootstrap.lastFeesPerMember = nextCertification ?  _feesAndBootstrapState.certifiedFeesPerMember : _feesAndBootstrapState.generalFeesPerMember;
    }

    function _updateGuardianFeesAndBootstrap(address guardian, bool inCommittee, bool isCertified, bool nextCertification, uint generalCommitteeSize, uint certifiedCommitteeSize) private {

        uint256 addedBootstrapAmount;
        uint256 addedFeesAmount;

        FeesAndBootstrapState memory _feesAndBootstrapState = _updateFeesAndBootstrapState(generalCommitteeSize, certifiedCommitteeSize);
        FeesAndBootstrap memory guardianFeesAndBootstrap;
        (guardianFeesAndBootstrap, addedBootstrapAmount, addedFeesAmount) = _getGuardianFeesAndBootstrap(guardian, inCommittee, isCertified, nextCertification, _feesAndBootstrapState);
        feesAndBootstrap[guardian] = guardianFeesAndBootstrap;

        emit BootstrapRewardsAssigned(guardian, addedBootstrapAmount, guardianFeesAndBootstrap.withdrawnBootstrap.add(guardianFeesAndBootstrap.bootstrapBalance), isCertified, guardianFeesAndBootstrap.lastBootstrapPerMember);
        emit FeesAssigned(guardian, addedFeesAmount, guardianFeesAndBootstrap.withdrawnFees.add(guardianFeesAndBootstrap.feeBalance), isCertified, guardianFeesAndBootstrap.lastFeesPerMember);
    }

    function getGuardianFeesAndBootstrap(address guardian, uint256 currentTime) private view returns (FeesAndBootstrap memory guardianFeesAndBootstrap, bool certified) {

        ICommittee _committeeContract = committeeContract;
        (uint generalCommitteeSize, uint certifiedCommitteeSize, ) = _committeeContract.getCommitteeStats();
        (FeesAndBootstrapState memory _feesAndBootstrapState,,) = _getFeesAndBootstrapState(generalCommitteeSize, certifiedCommitteeSize, generalFeesWallet.getOutstandingFees(currentTime), certifiedFeesWallet.getOutstandingFees(currentTime), currentTime, settings);
        bool inCommittee;
        (inCommittee, , certified,) = _committeeContract.getMemberInfo(guardian);
        (guardianFeesAndBootstrap, ,) = _getGuardianFeesAndBootstrap(guardian, inCommittee, certified, certified, _feesAndBootstrapState);
    }

    function updateGuardianFeesAndBootstrap(address guardian) private {

        ICommittee _committeeContract = committeeContract;
        (uint generalCommitteeSize, uint certifiedCommitteeSize, ) = _committeeContract.getCommitteeStats();
        (bool inCommittee, , bool isCertified,) = _committeeContract.getMemberInfo(guardian);
        _updateGuardianFeesAndBootstrap(guardian, inCommittee, isCertified, isCertified, generalCommitteeSize, certifiedCommitteeSize);
    }


    function _setGeneralCommitteeAnnualBootstrap(uint256 annualAmount) private {

        require(uint256(uint96(annualAmount)) == annualAmount, "annualAmount must fit in uint96");

        settings.generalCommitteeAnnualBootstrap = uint96(annualAmount);
        emit GeneralCommitteeAnnualBootstrapChanged(annualAmount);
    }

    function _setCertifiedCommitteeAnnualBootstrap(uint256 annualAmount) private {

        require(uint256(uint96(annualAmount)) == annualAmount, "annualAmount must fit in uint96");

        settings.certifiedCommitteeAnnualBootstrap = uint96(annualAmount);
        emit CertifiedCommitteeAnnualBootstrapChanged(annualAmount);
    }


    ICommittee committeeContract;
    IFeesWallet generalFeesWallet;
    IFeesWallet certifiedFeesWallet;
    IProtocolWallet bootstrapRewardsWallet;

    function refreshContracts() external override {

        committeeContract = ICommittee(getCommitteeContract());
        generalFeesWallet = IFeesWallet(getGeneralFeesWallet());
        certifiedFeesWallet = IFeesWallet(getCertifiedFeesWallet());
        bootstrapRewardsWallet = IProtocolWallet(getBootstrapRewardsWallet());
    }
}