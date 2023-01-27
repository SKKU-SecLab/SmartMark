


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


interface IMigratableStakingContract {

    function getToken() external view returns (IERC20);


    function acceptMigration(address _stakeOwner, uint256 _amount) external;


    event AcceptedMigration(address indexed stakeOwner, uint256 amount, uint256 totalStakedAmount);
}


pragma solidity 0.6.12;


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











contract StakingRewards is IStakingRewards, ManagedContract {

    using SafeMath for uint256;
    using SafeMath96 for uint96;

    uint256 constant PERCENT_MILLIE_BASE = 100000;
    uint256 constant TOKEN_BASE = 1e18;

    struct Settings {
        uint96 annualCap;
        uint32 annualRateInPercentMille;
        uint32 defaultDelegatorsStakingRewardsPercentMille;
        uint32 maxDelegatorsStakingRewardsPercentMille;
        bool rewardAllocationActive;
    }
    Settings settings;

    IERC20 public token;

    struct StakingRewardsState {
        uint96 stakingRewardsPerWeight;
        uint96 unclaimedStakingRewards;
        uint32 lastAssigned;
    }
    StakingRewardsState public stakingRewardsState;

    uint256 public stakingRewardsContractBalance;

    struct GuardianStakingRewards {
        uint96 delegatorRewardsPerToken;
        uint96 lastStakingRewardsPerWeight;
        uint96 balance;
        uint96 claimed;
    }
    mapping(address => GuardianStakingRewards) public guardiansStakingRewards;

    struct GuardianRewardSettings {
        uint32 delegatorsStakingRewardsPercentMille;
        bool overrideDefault;
    }
    mapping(address => GuardianRewardSettings) public guardiansRewardSettings;

    struct DelegatorStakingRewards {
        uint96 balance;
        uint96 lastDelegatorRewardsPerToken;
        uint96 claimed;
    }
    mapping(address => DelegatorStakingRewards) public delegatorsStakingRewards;

    constructor(
        IContractRegistry _contractRegistry,
        address _registryAdmin,
        IERC20 _token,
        uint32 annualRateInPercentMille,
        uint96 annualCap,
        uint32 defaultDelegatorsStakingRewardsPercentMille,
        uint32 maxDelegatorsStakingRewardsPercentMille,
        IStakingRewards previousRewardsContract,
        address[] memory guardiansToMigrate
    ) ManagedContract(_contractRegistry, _registryAdmin) public {
        require(address(_token) != address(0), "token must not be 0");

        _setAnnualStakingRewardsRate(annualRateInPercentMille, annualCap);
        setMaxDelegatorsStakingRewardsPercentMille(maxDelegatorsStakingRewardsPercentMille);
        setDefaultDelegatorsStakingRewardsPercentMille(defaultDelegatorsStakingRewardsPercentMille);

        token = _token;

        if (address(previousRewardsContract) != address(0)) {
            migrateGuardiansSettings(previousRewardsContract, guardiansToMigrate);
        }
    }

    modifier onlyCommitteeContract() {

        require(msg.sender == address(committeeContract), "caller is not the elections contract");

        _;
    }

    modifier onlyDelegationsContract() {

        require(msg.sender == address(delegationsContract), "caller is not the delegations contract");

        _;
    }


    function getStakingRewardsBalance(address addr) external override view returns (uint256 delegatorStakingRewardsBalance, uint256 guardianStakingRewardsBalance) {

        (DelegatorStakingRewards memory delegatorStakingRewards,,) = getDelegatorStakingRewards(addr, block.timestamp);
        (GuardianStakingRewards memory guardianStakingRewards,,) = getGuardianStakingRewards(addr, block.timestamp);
        return (delegatorStakingRewards.balance, guardianStakingRewards.balance);
    }

    function claimStakingRewards(address addr) external override onlyWhenActive {

        (uint256 guardianRewards, uint256 delegatorRewards) = claimStakingRewardsLocally(addr);
        uint256 total = delegatorRewards.add(guardianRewards);
        if (total == 0) {
            return;
        }

        uint96 claimedGuardianRewards = guardiansStakingRewards[addr].claimed.add(guardianRewards);
        guardiansStakingRewards[addr].claimed = claimedGuardianRewards;
        uint96 claimedDelegatorRewards = delegatorsStakingRewards[addr].claimed.add(delegatorRewards);
        delegatorsStakingRewards[addr].claimed = claimedDelegatorRewards;

        require(token.approve(address(stakingContract), total), "claimStakingRewards: approve failed");

        address[] memory addrs = new address[](1);
        addrs[0] = addr;
        uint256[] memory amounts = new uint256[](1);
        amounts[0] = total;
        stakingContract.distributeRewards(total, addrs, amounts);

        emit StakingRewardsClaimed(addr, delegatorRewards, guardianRewards, claimedDelegatorRewards, claimedGuardianRewards);
    }

    function getStakingRewardsState() public override view returns (
        uint96 stakingRewardsPerWeight,
        uint96 unclaimedStakingRewards
    ) {

        (, , uint totalCommitteeWeight) = committeeContract.getCommitteeStats();
        (StakingRewardsState memory _stakingRewardsState,) = _getStakingRewardsState(totalCommitteeWeight, block.timestamp, settings);
        stakingRewardsPerWeight = _stakingRewardsState.stakingRewardsPerWeight;
        unclaimedStakingRewards = _stakingRewardsState.unclaimedStakingRewards;
    }

    function getGuardianStakingRewardsData(address guardian) external override view returns (
        uint256 balance,
        uint256 claimed,
        uint256 delegatorRewardsPerToken,
        uint256 delegatorRewardsPerTokenDelta,
        uint256 lastStakingRewardsPerWeight,
        uint256 stakingRewardsPerWeightDelta
    ) {

        (GuardianStakingRewards memory rewards, uint256 _stakingRewardsPerWeightDelta, uint256 _delegatorRewardsPerTokenDelta) = getGuardianStakingRewards(guardian, block.timestamp);
        return (rewards.balance, rewards.claimed, rewards.delegatorRewardsPerToken, _delegatorRewardsPerTokenDelta, rewards.lastStakingRewardsPerWeight, _stakingRewardsPerWeightDelta);
    }

    function getDelegatorStakingRewardsData(address delegator) external override view returns (
        uint256 balance,
        uint256 claimed,
        address guardian,
        uint256 lastDelegatorRewardsPerToken,
        uint256 delegatorRewardsPerTokenDelta
    ) {

        (DelegatorStakingRewards memory rewards, address _guardian, uint256 _delegatorRewardsPerTokenDelta) = getDelegatorStakingRewards(delegator, block.timestamp);
        return (rewards.balance, rewards.claimed, _guardian, rewards.lastDelegatorRewardsPerToken, _delegatorRewardsPerTokenDelta);
    }

    function estimateFutureRewards(address addr, uint256 duration) external override view returns (uint256 estimatedDelegatorStakingRewards, uint256 estimatedGuardianStakingRewards) {

        (GuardianStakingRewards memory guardianRewardsNow,,) = getGuardianStakingRewards(addr, block.timestamp);
        (DelegatorStakingRewards memory delegatorRewardsNow,,) = getDelegatorStakingRewards(addr, block.timestamp);
        (GuardianStakingRewards memory guardianRewardsFuture,,) = getGuardianStakingRewards(addr, block.timestamp.add(duration));
        (DelegatorStakingRewards memory delegatorRewardsFuture,,) = getDelegatorStakingRewards(addr, block.timestamp.add(duration));

        estimatedDelegatorStakingRewards = delegatorRewardsFuture.balance.sub(delegatorRewardsNow.balance);
        estimatedGuardianStakingRewards = guardianRewardsFuture.balance.sub(guardianRewardsNow.balance);
    }

    function setGuardianDelegatorsStakingRewardsPercentMille(uint32 delegatorRewardsPercentMille) external override onlyWhenActive {

        require(delegatorRewardsPercentMille <= PERCENT_MILLIE_BASE, "delegatorRewardsPercentMille must be 100000 at most");
        require(delegatorRewardsPercentMille <= settings.maxDelegatorsStakingRewardsPercentMille, "delegatorRewardsPercentMille must not be larger than maxDelegatorsStakingRewardsPercentMille");
        updateDelegatorStakingRewards(msg.sender);
        _setGuardianDelegatorsStakingRewardsPercentMille(msg.sender, delegatorRewardsPercentMille);
    }

    function getGuardianDelegatorsStakingRewardsPercentMille(address guardian) external override view returns (uint256 delegatorRewardsRatioPercentMille) {

        return _getGuardianDelegatorsStakingRewardsPercentMille(guardian, settings);
    }

    function getStakingRewardsWalletAllocatedTokens() external override view returns (uint256 allocated) {

        (, uint96 unclaimedStakingRewards) = getStakingRewardsState();
        return uint256(unclaimedStakingRewards).sub(stakingRewardsContractBalance);
    }

    function getCurrentStakingRewardsRatePercentMille() external override view returns (uint256 annualRate) {

        (, , uint totalCommitteeWeight) = committeeContract.getCommitteeStats();
        annualRate = _getAnnualRewardPerWeight(totalCommitteeWeight, settings).mul(PERCENT_MILLIE_BASE).div(TOKEN_BASE);
    }

    function committeeMembershipWillChange(address guardian, uint256 weight, uint256 totalCommitteeWeight, bool inCommittee, bool inCommitteeAfter) external override onlyWhenActive onlyCommitteeContract {

        uint256 delegatedStake = delegationsContract.getDelegatedStake(guardian);

        Settings memory _settings = settings;
        StakingRewardsState memory _stakingRewardsState = _updateStakingRewardsState(totalCommitteeWeight, _settings);
        _updateGuardianStakingRewards(guardian, inCommittee, inCommitteeAfter, weight, delegatedStake, _stakingRewardsState, _settings);
    }

    function delegationWillChange(address guardian, uint256 guardianDelegatedStake, address delegator, uint256 delegatorStake, address nextGuardian, uint256 nextGuardianDelegatedStake) external override onlyWhenActive onlyDelegationsContract {

        Settings memory _settings = settings;
        (bool inCommittee, uint256 weight, , uint256 totalCommitteeWeight) = committeeContract.getMemberInfo(guardian);

        StakingRewardsState memory _stakingRewardsState = _updateStakingRewardsState(totalCommitteeWeight, _settings);
        GuardianStakingRewards memory guardianStakingRewards = _updateGuardianStakingRewards(guardian, inCommittee, inCommittee, weight, guardianDelegatedStake, _stakingRewardsState, _settings);
        _updateDelegatorStakingRewards(delegator, delegatorStake, guardian, guardianStakingRewards);

        if (nextGuardian != guardian) {
            (inCommittee, weight, , totalCommitteeWeight) = committeeContract.getMemberInfo(nextGuardian);
            GuardianStakingRewards memory nextGuardianStakingRewards = _updateGuardianStakingRewards(nextGuardian, inCommittee, inCommittee, weight, nextGuardianDelegatedStake, _stakingRewardsState, _settings);
            delegatorsStakingRewards[delegator].lastDelegatorRewardsPerToken = nextGuardianStakingRewards.delegatorRewardsPerToken;
        }
    }


    function activateRewardDistribution(uint startTime) external override onlyMigrationManager {

        require(!settings.rewardAllocationActive, "reward distribution is already activated");

        stakingRewardsState.lastAssigned = uint32(startTime);
        settings.rewardAllocationActive = true;

        emit RewardDistributionActivated(startTime);
    }

    function deactivateRewardDistribution() external override onlyMigrationManager {

        require(settings.rewardAllocationActive, "reward distribution is already deactivated");

        StakingRewardsState memory _stakingRewardsState = updateStakingRewardsState();

        settings.rewardAllocationActive = false;

        withdrawRewardsWalletAllocatedTokens(_stakingRewardsState);

        emit RewardDistributionDeactivated();
    }

    function setDefaultDelegatorsStakingRewardsPercentMille(uint32 defaultDelegatorsStakingRewardsPercentMille) public override onlyFunctionalManager {

        require(defaultDelegatorsStakingRewardsPercentMille <= PERCENT_MILLIE_BASE, "defaultDelegatorsStakingRewardsPercentMille must not be larger than 100000");
        require(defaultDelegatorsStakingRewardsPercentMille <= settings.maxDelegatorsStakingRewardsPercentMille, "defaultDelegatorsStakingRewardsPercentMille must not be larger than maxDelegatorsStakingRewardsPercentMille");
        settings.defaultDelegatorsStakingRewardsPercentMille = defaultDelegatorsStakingRewardsPercentMille;
        emit DefaultDelegatorsStakingRewardsChanged(defaultDelegatorsStakingRewardsPercentMille);
    }

    function getDefaultDelegatorsStakingRewardsPercentMille() public override view returns (uint32) {

        return settings.defaultDelegatorsStakingRewardsPercentMille;
    }

    function setMaxDelegatorsStakingRewardsPercentMille(uint32 maxDelegatorsStakingRewardsPercentMille) public override onlyFunctionalManager {

        require(maxDelegatorsStakingRewardsPercentMille <= PERCENT_MILLIE_BASE, "maxDelegatorsStakingRewardsPercentMille must not be larger than 100000");
        settings.maxDelegatorsStakingRewardsPercentMille = maxDelegatorsStakingRewardsPercentMille;
        emit MaxDelegatorsStakingRewardsChanged(maxDelegatorsStakingRewardsPercentMille);
    }

    function getMaxDelegatorsStakingRewardsPercentMille() public override view returns (uint32) {

        return settings.maxDelegatorsStakingRewardsPercentMille;
    }

    function setAnnualStakingRewardsRate(uint32 annualRateInPercentMille, uint96 annualCap) external override onlyFunctionalManager {

        updateStakingRewardsState();
        return _setAnnualStakingRewardsRate(annualRateInPercentMille, annualCap);
    }

    function getAnnualStakingRewardsRatePercentMille() external override view returns (uint32) {

        return settings.annualRateInPercentMille;
    }

    function getAnnualStakingRewardsCap() external override view returns (uint256) {

        return settings.annualCap;
    }

    function isRewardAllocationActive() external override view returns (bool) {

        return settings.rewardAllocationActive;
    }

    function getSettings() external override view returns (
        uint annualStakingRewardsCap,
        uint32 annualStakingRewardsRatePercentMille,
        uint32 defaultDelegatorsStakingRewardsPercentMille,
        uint32 maxDelegatorsStakingRewardsPercentMille,
        bool rewardAllocationActive
    ) {

        Settings memory _settings = settings;
        annualStakingRewardsCap = _settings.annualCap;
        annualStakingRewardsRatePercentMille = _settings.annualRateInPercentMille;
        defaultDelegatorsStakingRewardsPercentMille = _settings.defaultDelegatorsStakingRewardsPercentMille;
        maxDelegatorsStakingRewardsPercentMille = _settings.maxDelegatorsStakingRewardsPercentMille;
        rewardAllocationActive = _settings.rewardAllocationActive;
    }

    function migrateRewardsBalance(address[] calldata addrs) external override {

        require(!settings.rewardAllocationActive, "Reward distribution must be deactivated for migration");

        IStakingRewards currentRewardsContract = IStakingRewards(getStakingRewardsContract());
        require(address(currentRewardsContract) != address(this), "New rewards contract is not set");

        uint256 totalAmount = 0;
        uint256[] memory guardianRewards = new uint256[](addrs.length);
        uint256[] memory delegatorRewards = new uint256[](addrs.length);
        for (uint i = 0; i < addrs.length; i++) {
            (guardianRewards[i], delegatorRewards[i]) = claimStakingRewardsLocally(addrs[i]);
            totalAmount = totalAmount.add(guardianRewards[i]).add(delegatorRewards[i]);
        }

        require(token.approve(address(currentRewardsContract), totalAmount), "migrateRewardsBalance: approve failed");
        currentRewardsContract.acceptRewardsBalanceMigration(addrs, guardianRewards, delegatorRewards, totalAmount);

        for (uint i = 0; i < addrs.length; i++) {
            emit StakingRewardsBalanceMigrated(addrs[i], guardianRewards[i], delegatorRewards[i], address(currentRewardsContract));
        }
    }

    function acceptRewardsBalanceMigration(address[] calldata addrs, uint256[] calldata migratedGuardianStakingRewards, uint256[] calldata migratedDelegatorStakingRewards, uint256 totalAmount) external override {

        uint256 _totalAmount = 0;

        for (uint i = 0; i < addrs.length; i++) {
            _totalAmount = _totalAmount.add(migratedGuardianStakingRewards[i]).add(migratedDelegatorStakingRewards[i]);
        }

        require(totalAmount == _totalAmount, "totalAmount does not match sum of rewards");

        if (totalAmount > 0) {
            require(token.transferFrom(msg.sender, address(this), totalAmount), "acceptRewardBalanceMigration: transfer failed");
        }

        for (uint i = 0; i < addrs.length; i++) {
            guardiansStakingRewards[addrs[i]].balance = guardiansStakingRewards[addrs[i]].balance.add(migratedGuardianStakingRewards[i]);
            delegatorsStakingRewards[addrs[i]].balance = delegatorsStakingRewards[addrs[i]].balance.add(migratedDelegatorStakingRewards[i]);
            emit StakingRewardsBalanceMigrationAccepted(msg.sender, addrs[i], migratedGuardianStakingRewards[i], migratedDelegatorStakingRewards[i]);
        }

        stakingRewardsContractBalance = stakingRewardsContractBalance.add(totalAmount);
        stakingRewardsState.unclaimedStakingRewards = stakingRewardsState.unclaimedStakingRewards.add(totalAmount);
    }

    function emergencyWithdraw(address erc20) external override onlyMigrationManager {

        IERC20 _token = IERC20(erc20);
        emit EmergencyWithdrawal(msg.sender, address(_token));
        require(_token.transfer(msg.sender, _token.balanceOf(address(this))), "StakingRewards::emergencyWithdraw - transfer failed");
    }



    function _getAnnualRewardPerWeight(uint256 totalCommitteeWeight, Settings memory _settings) private pure returns (uint256) {

        return totalCommitteeWeight == 0 ? 0 : Math.min(uint256(_settings.annualRateInPercentMille).mul(TOKEN_BASE).div(PERCENT_MILLIE_BASE), uint256(_settings.annualCap).mul(TOKEN_BASE).div(totalCommitteeWeight));
    }

    function calcStakingRewardPerWeightDelta(uint256 totalCommitteeWeight, uint duration, Settings memory _settings) private pure returns (uint256 stakingRewardsPerWeightDelta) {

        stakingRewardsPerWeightDelta = 0;

        if (totalCommitteeWeight > 0) {
            uint annualRewardPerWeight = _getAnnualRewardPerWeight(totalCommitteeWeight, _settings);
            stakingRewardsPerWeightDelta = annualRewardPerWeight.mul(duration).div(365 days);
        }
    }

    function _getStakingRewardsState(uint256 totalCommitteeWeight, uint256 currentTime, Settings memory _settings) private view returns (StakingRewardsState memory _stakingRewardsState, uint256 allocatedRewards) {

        _stakingRewardsState = stakingRewardsState;
        if (_settings.rewardAllocationActive) {
            uint delta = calcStakingRewardPerWeightDelta(totalCommitteeWeight, currentTime.sub(stakingRewardsState.lastAssigned), _settings);
            _stakingRewardsState.stakingRewardsPerWeight = stakingRewardsState.stakingRewardsPerWeight.add(delta);
            _stakingRewardsState.lastAssigned = uint32(currentTime);
            allocatedRewards = delta.mul(totalCommitteeWeight).div(TOKEN_BASE);
            _stakingRewardsState.unclaimedStakingRewards = _stakingRewardsState.unclaimedStakingRewards.add(allocatedRewards);
        }
    }

    function _updateStakingRewardsState(uint256 totalCommitteeWeight, Settings memory _settings) private returns (StakingRewardsState memory _stakingRewardsState) {

        if (!_settings.rewardAllocationActive) {
            return stakingRewardsState;
        }

        uint allocatedRewards;
        (_stakingRewardsState, allocatedRewards) = _getStakingRewardsState(totalCommitteeWeight, block.timestamp, _settings);
        stakingRewardsState = _stakingRewardsState;
        emit StakingRewardsAllocated(allocatedRewards, _stakingRewardsState.stakingRewardsPerWeight);
    }

    function updateStakingRewardsState() private returns (StakingRewardsState memory _stakingRewardsState) {

        (, , uint totalCommitteeWeight) = committeeContract.getCommitteeStats();
        return _updateStakingRewardsState(totalCommitteeWeight, settings);
    }


    function _getGuardianStakingRewards(address guardian, bool inCommittee, bool inCommitteeAfter, uint256 guardianWeight, uint256 guardianDelegatedStake, StakingRewardsState memory _stakingRewardsState, Settings memory _settings) private view returns (GuardianStakingRewards memory guardianStakingRewards, uint256 rewardsAdded, uint256 stakingRewardsPerWeightDelta, uint256 delegatorRewardsPerTokenDelta) {

        guardianStakingRewards = guardiansStakingRewards[guardian];

        if (inCommittee) {
            stakingRewardsPerWeightDelta = uint256(_stakingRewardsState.stakingRewardsPerWeight).sub(guardianStakingRewards.lastStakingRewardsPerWeight);
            uint256 totalRewards = stakingRewardsPerWeightDelta.mul(guardianWeight);

            uint256 delegatorRewardsRatioPercentMille = _getGuardianDelegatorsStakingRewardsPercentMille(guardian, _settings);

            delegatorRewardsPerTokenDelta = guardianDelegatedStake == 0 ? 0 : totalRewards
            .div(guardianDelegatedStake)
            .mul(delegatorRewardsRatioPercentMille)
            .div(PERCENT_MILLIE_BASE);

            uint256 guardianCutPercentMille = PERCENT_MILLIE_BASE.sub(delegatorRewardsRatioPercentMille);

            rewardsAdded = totalRewards
            .mul(guardianCutPercentMille)
            .div(PERCENT_MILLIE_BASE)
            .div(TOKEN_BASE);

            guardianStakingRewards.delegatorRewardsPerToken = guardianStakingRewards.delegatorRewardsPerToken.add(delegatorRewardsPerTokenDelta);
            guardianStakingRewards.balance = guardianStakingRewards.balance.add(rewardsAdded);
        }

        guardianStakingRewards.lastStakingRewardsPerWeight = inCommitteeAfter ? _stakingRewardsState.stakingRewardsPerWeight : 0;
    }

    function getGuardianStakingRewards(address guardian, uint256 currentTime) private view returns (GuardianStakingRewards memory guardianStakingRewards, uint256 stakingRewardsPerWeightDelta, uint256 delegatorRewardsPerTokenDelta) {

        Settings memory _settings = settings;

        (bool inCommittee, uint256 guardianWeight, ,uint256 totalCommitteeWeight) = committeeContract.getMemberInfo(guardian);
        uint256 guardianDelegatedStake = delegationsContract.getDelegatedStake(guardian);

        (StakingRewardsState memory _stakingRewardsState,) = _getStakingRewardsState(totalCommitteeWeight, currentTime, _settings);
        (guardianStakingRewards,,stakingRewardsPerWeightDelta,delegatorRewardsPerTokenDelta) = _getGuardianStakingRewards(guardian, inCommittee, inCommittee, guardianWeight, guardianDelegatedStake, _stakingRewardsState, _settings);
    }

    function _updateGuardianStakingRewards(address guardian, bool inCommittee, bool inCommitteeAfter, uint256 guardianWeight, uint256 guardianDelegatedStake, StakingRewardsState memory _stakingRewardsState, Settings memory _settings) private returns (GuardianStakingRewards memory guardianStakingRewards) {

        uint256 guardianStakingRewardsAdded;
        uint256 stakingRewardsPerWeightDelta;
        uint256 delegatorRewardsPerTokenDelta;
        (guardianStakingRewards, guardianStakingRewardsAdded, stakingRewardsPerWeightDelta, delegatorRewardsPerTokenDelta) = _getGuardianStakingRewards(guardian, inCommittee, inCommitteeAfter, guardianWeight, guardianDelegatedStake, _stakingRewardsState, _settings);
        guardiansStakingRewards[guardian] = guardianStakingRewards;
        emit GuardianStakingRewardsAssigned(guardian, guardianStakingRewardsAdded, guardianStakingRewards.claimed.add(guardianStakingRewards.balance), guardianStakingRewards.delegatorRewardsPerToken, delegatorRewardsPerTokenDelta, _stakingRewardsState.stakingRewardsPerWeight, stakingRewardsPerWeightDelta);
    }

    function updateGuardianStakingRewards(address guardian, StakingRewardsState memory _stakingRewardsState, Settings memory _settings) private returns (GuardianStakingRewards memory guardianStakingRewards) {

        (bool inCommittee, uint256 guardianWeight,,) = committeeContract.getMemberInfo(guardian);
        return _updateGuardianStakingRewards(guardian, inCommittee, inCommittee, guardianWeight, delegationsContract.getDelegatedStake(guardian), _stakingRewardsState, _settings);
    }


    function _getDelegatorStakingRewards(address delegator, uint256 delegatorStake, GuardianStakingRewards memory guardianStakingRewards) private view returns (DelegatorStakingRewards memory delegatorStakingRewards, uint256 delegatorRewardsAdded, uint256 delegatorRewardsPerTokenDelta) {

        delegatorStakingRewards = delegatorsStakingRewards[delegator];

        delegatorRewardsPerTokenDelta = uint256(guardianStakingRewards.delegatorRewardsPerToken)
        .sub(delegatorStakingRewards.lastDelegatorRewardsPerToken);
        delegatorRewardsAdded = delegatorRewardsPerTokenDelta
        .mul(delegatorStake)
        .div(TOKEN_BASE);

        delegatorStakingRewards.balance = delegatorStakingRewards.balance.add(delegatorRewardsAdded);
        delegatorStakingRewards.lastDelegatorRewardsPerToken = guardianStakingRewards.delegatorRewardsPerToken;
    }

    function getDelegatorStakingRewards(address delegator, uint256 currentTime) private view returns (DelegatorStakingRewards memory delegatorStakingRewards, address guardian, uint256 delegatorStakingRewardsPerTokenDelta) {

        uint256 delegatorStake;
        (guardian, delegatorStake) = delegationsContract.getDelegationInfo(delegator);
        (GuardianStakingRewards memory guardianStakingRewards,,) = getGuardianStakingRewards(guardian, currentTime);

        (delegatorStakingRewards,,delegatorStakingRewardsPerTokenDelta) = _getDelegatorStakingRewards(delegator, delegatorStake, guardianStakingRewards);
    }

    function _updateDelegatorStakingRewards(address delegator, uint256 delegatorStake, address guardian, GuardianStakingRewards memory guardianStakingRewards) private {

        uint256 delegatorStakingRewardsAdded;
        uint256 delegatorRewardsPerTokenDelta;
        DelegatorStakingRewards memory delegatorStakingRewards;
        (delegatorStakingRewards, delegatorStakingRewardsAdded, delegatorRewardsPerTokenDelta) = _getDelegatorStakingRewards(delegator, delegatorStake, guardianStakingRewards);
        delegatorsStakingRewards[delegator] = delegatorStakingRewards;

        emit DelegatorStakingRewardsAssigned(delegator, delegatorStakingRewardsAdded, delegatorStakingRewards.claimed.add(delegatorStakingRewards.balance), guardian, guardianStakingRewards.delegatorRewardsPerToken, delegatorRewardsPerTokenDelta);
    }

    function updateDelegatorStakingRewards(address delegator) private {

        Settings memory _settings = settings;

        (, , uint totalCommitteeWeight) = committeeContract.getCommitteeStats();
        StakingRewardsState memory _stakingRewardsState = _updateStakingRewardsState(totalCommitteeWeight, _settings);

        (address guardian, uint delegatorStake) = delegationsContract.getDelegationInfo(delegator);
        GuardianStakingRewards memory guardianRewards = updateGuardianStakingRewards(guardian, _stakingRewardsState, _settings);

        _updateDelegatorStakingRewards(delegator, delegatorStake, guardian, guardianRewards);
    }


    function _getGuardianDelegatorsStakingRewardsPercentMille(address guardian, Settings memory _settings) private view returns (uint256 delegatorRewardsRatioPercentMille) {

        GuardianRewardSettings memory guardianSettings = guardiansRewardSettings[guardian];
        delegatorRewardsRatioPercentMille =  guardianSettings.overrideDefault ? guardianSettings.delegatorsStakingRewardsPercentMille : _settings.defaultDelegatorsStakingRewardsPercentMille;
        return Math.min(delegatorRewardsRatioPercentMille, _settings.maxDelegatorsStakingRewardsPercentMille);
    }

    function migrateGuardiansSettings(IStakingRewards previousRewardsContract, address[] memory guardiansToMigrate) private {

        for (uint i = 0; i < guardiansToMigrate.length; i++) {
            _setGuardianDelegatorsStakingRewardsPercentMille(guardiansToMigrate[i], uint32(previousRewardsContract.getGuardianDelegatorsStakingRewardsPercentMille(guardiansToMigrate[i])));
        }
    }


    function _setAnnualStakingRewardsRate(uint32 annualRateInPercentMille, uint96 annualCap) private {

        Settings memory _settings = settings;
        _settings.annualRateInPercentMille = annualRateInPercentMille;
        _settings.annualCap = annualCap;
        settings = _settings;

        emit AnnualStakingRewardsRateChanged(annualRateInPercentMille, annualCap);
    }

    function _setGuardianDelegatorsStakingRewardsPercentMille(address guardian, uint32 delegatorRewardsPercentMille) private {

        guardiansRewardSettings[guardian] = GuardianRewardSettings({
            overrideDefault: true,
            delegatorsStakingRewardsPercentMille: delegatorRewardsPercentMille
            });

        emit GuardianDelegatorsStakingRewardsPercentMilleUpdated(guardian, delegatorRewardsPercentMille);
    }

    function claimStakingRewardsLocally(address addr) private returns (uint256 guardianRewards, uint256 delegatorRewards) {

        updateDelegatorStakingRewards(addr);

        guardianRewards = guardiansStakingRewards[addr].balance;
        guardiansStakingRewards[addr].balance = 0;

        delegatorRewards = delegatorsStakingRewards[addr].balance;
        delegatorsStakingRewards[addr].balance = 0;

        uint256 total = delegatorRewards.add(guardianRewards);

        StakingRewardsState memory _stakingRewardsState = stakingRewardsState;

        uint256 _stakingRewardsContractBalance = stakingRewardsContractBalance;
        if (total > _stakingRewardsContractBalance) {
            _stakingRewardsContractBalance = withdrawRewardsWalletAllocatedTokens(_stakingRewardsState);
        }

        stakingRewardsContractBalance = _stakingRewardsContractBalance.sub(total);
        stakingRewardsState.unclaimedStakingRewards = _stakingRewardsState.unclaimedStakingRewards.sub(total);
    }

    function withdrawRewardsWalletAllocatedTokens(StakingRewardsState memory _stakingRewardsState) private returns (uint256 _stakingRewardsContractBalance){

        _stakingRewardsContractBalance = stakingRewardsContractBalance;
        uint256 allocated = _stakingRewardsState.unclaimedStakingRewards.sub(_stakingRewardsContractBalance);
        stakingRewardsWallet.withdraw(allocated);
        _stakingRewardsContractBalance = _stakingRewardsContractBalance.add(allocated);
        stakingRewardsContractBalance = _stakingRewardsContractBalance;
    }


    ICommittee committeeContract;
    IDelegations delegationsContract;
    IProtocolWallet stakingRewardsWallet;
    IStakingContract stakingContract;

    function refreshContracts() external override {

        committeeContract = ICommittee(getCommitteeContract());
        delegationsContract = IDelegations(getDelegationsContract());
        stakingRewardsWallet = IProtocolWallet(getStakingRewardsWallet());
        stakingContract = IStakingContract(getStakingContract());
    }
}