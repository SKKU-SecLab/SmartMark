


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

interface ISubscriptions {

    event SubscriptionChanged(uint256 indexed vcId, address owner, string name, uint256 genRefTime, string tier, uint256 rate, uint256 expiresAt, bool isCertified, string deploymentSubset);
    event Payment(uint256 indexed vcId, address by, uint256 amount, string tier, uint256 rate);
    event VcConfigRecordChanged(uint256 indexed vcId, string key, string value);
    event VcCreated(uint256 indexed vcId);
    event VcOwnerChanged(uint256 indexed vcId, address previousOwner, address newOwner);


    function createVC(string calldata name, string calldata tier, uint256 rate, uint256 amount, address owner, bool isCertified, string calldata deploymentSubset) external returns (uint vcId, uint genRefTime);


    function extendSubscription(uint256 vcId, uint256 amount, string calldata tier, uint256 rate, address payer) external;


    function setVcConfigRecord(uint256 vcId, string calldata key, string calldata value) external /* onlyVcOwner */;


    function getVcConfigRecord(uint256 vcId, string calldata key) external view returns (string memory);


    function setVcOwner(uint256 vcId, address owner) external /* onlyVcOwner */;


    function getVcData(uint256 vcId) external view returns (
        string memory name,
        string memory tier,
        uint256 rate,
        uint expiresAt,
        uint256 genRefTime,
        address owner,
        string memory deploymentSubset,
        bool isCertified
    );



    event SubscriberAdded(address subscriber);
    event SubscriberRemoved(address subscriber);
    event GenesisRefTimeDelayChanged(uint256 newGenesisRefTimeDelay);
    event MinimumInitialVcPaymentChanged(uint256 newMinimumInitialVcPayment);

    function addSubscriber(address addr) external /* onlyFunctionalManager */;


    function removeSubscriber(address addr) external /* onlyFunctionalManager */;


    function setGenesisRefTimeDelay(uint256 newGenesisRefTimeDelay) external /* onlyFunctionalManager */;


    function getGenesisRefTimeDelay() external view returns (uint256);


    function setMinimumInitialVcPayment(uint256 newMinimumInitialVcPayment) external /* onlyFunctionalManager */;


    function getMinimumInitialVcPayment() external view returns (uint256);


    function getSettings() external view returns(
        uint genesisRefTimeDelay,
        uint256 minimumInitialVcPayment
    );


    function importSubscription(uint vcId, ISubscriptions previousSubscriptionsContract) external /* onlyInitializationAdmin */;


}


pragma solidity 0.6.12;

interface IProtocol {

    event ProtocolVersionChanged(string deploymentSubset, uint256 currentVersion, uint256 nextVersion, uint256 fromTimestamp);


    function deploymentSubsetExists(string calldata deploymentSubset) external view returns (bool);


    function getProtocolVersion(string calldata deploymentSubset) external view returns (uint256 currentVersion);



    function createDeploymentSubset(string calldata deploymentSubset, uint256 initialProtocolVersion) external /* onlyFunctionalManager */;



    function setProtocolVersion(string calldata deploymentSubset, uint256 nextVersion, uint256 fromTimestamp) external /* onlyFunctionalManager */;

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







contract Subscriptions is ISubscriptions, ManagedContract {

    using SafeMath for uint256;

    struct VirtualChain {
        string name;
        string tier;
        uint256 rate;
        uint expiresAt;
        uint256 genRefTime;
        address owner;
        string deploymentSubset;
        bool isCertified;
    }

    mapping(uint => mapping(string => string)) configRecords;
    mapping(address => bool) public authorizedSubscribers;
    mapping(uint => VirtualChain) virtualChains;

    uint public nextVcId;

    struct Settings {
        uint genesisRefTimeDelay;
        uint256 minimumInitialVcPayment;
    }
    Settings settings;

    IERC20 public erc20;

    constructor (IContractRegistry _contractRegistry, address _registryAdmin, IERC20 _erc20, uint256 _genesisRefTimeDelay, uint256 _minimumInitialVcPayment, uint[] memory vcIds, uint256 initialNextVcId, ISubscriptions previousSubscriptionsContract) ManagedContract(_contractRegistry, _registryAdmin) public {
        require(address(_erc20) != address(0), "erc20 must not be 0");

        erc20 = _erc20;
        nextVcId = initialNextVcId;

        setGenesisRefTimeDelay(_genesisRefTimeDelay);
        setMinimumInitialVcPayment(_minimumInitialVcPayment);

        for (uint i = 0; i < vcIds.length; i++) {
        }
    }

    modifier onlySubscriber {

        require(authorizedSubscribers[msg.sender], "sender must be an authorized subscriber");

        _;
    }


    function createVC(string calldata name, string calldata tier, uint256 rate, uint256 amount, address owner, bool isCertified, string calldata deploymentSubset) external override onlySubscriber onlyWhenActive returns (uint vcId, uint genRefTime) {

        require(owner != address(0), "vc owner cannot be the zero address");
        require(protocolContract.deploymentSubsetExists(deploymentSubset) == true, "No such deployment subset");
        require(amount >= settings.minimumInitialVcPayment, "initial VC payment must be at least minimumInitialVcPayment");

        vcId = nextVcId++;
        genRefTime = now + settings.genesisRefTimeDelay;
        VirtualChain memory vc = VirtualChain({
            name: name,
            expiresAt: block.timestamp,
            genRefTime: genRefTime,
            owner: owner,
            tier: tier,
            rate: rate,
            deploymentSubset: deploymentSubset,
            isCertified: isCertified
            });
        virtualChains[vcId] = vc;

        emit VcCreated(vcId);

        _extendSubscription(vcId, amount, tier, rate, owner);
    }

    function extendSubscription(uint256 vcId, uint256 amount, string calldata tier, uint256 rate, address payer) external override onlySubscriber onlyWhenActive {

        _extendSubscription(vcId, amount, tier, rate, payer);
    }

    function setVcConfigRecord(uint256 vcId, string calldata key, string calldata value) external override onlyWhenActive {

        require(msg.sender == virtualChains[vcId].owner, "only vc owner can set a vc config record");
        configRecords[vcId][key] = value;
        emit VcConfigRecordChanged(vcId, key, value);
    }

    function getVcConfigRecord(uint256 vcId, string calldata key) external override view returns (string memory) {

        return configRecords[vcId][key];
    }

    function setVcOwner(uint256 vcId, address owner) external override onlyWhenActive {

        require(msg.sender == virtualChains[vcId].owner, "only the vc owner can transfer ownership");
        require(owner != address(0), "cannot transfer ownership to the zero address");

        virtualChains[vcId].owner = owner;
        emit VcOwnerChanged(vcId, msg.sender, owner);
    }

    function getVcData(uint256 vcId) external override view returns (
        string memory name,
        string memory tier,
        uint256 rate,
        uint expiresAt,
        uint256 genRefTime,
        address owner,
        string memory deploymentSubset,
        bool isCertified
    ) {

        VirtualChain memory vc = virtualChains[vcId];
        name = vc.name;
        tier = vc.tier;
        rate = vc.rate;
        expiresAt = vc.expiresAt;
        genRefTime = vc.genRefTime;
        owner = vc.owner;
        deploymentSubset = vc.deploymentSubset;
        isCertified = vc.isCertified;
    }


    function addSubscriber(address addr) external override onlyFunctionalManager {

        authorizedSubscribers[addr] = true;
        emit SubscriberAdded(addr);
    }

    function removeSubscriber(address addr) external override onlyFunctionalManager {

        require(authorizedSubscribers[addr], "given add is not an authorized subscriber");

        authorizedSubscribers[addr] = false;
        emit SubscriberRemoved(addr);
    }

    function setGenesisRefTimeDelay(uint256 newGenesisRefTimeDelay) public override onlyFunctionalManager {

        settings.genesisRefTimeDelay = newGenesisRefTimeDelay;
        emit GenesisRefTimeDelayChanged(newGenesisRefTimeDelay);
    }

    function getGenesisRefTimeDelay() external override view returns (uint) {

        return settings.genesisRefTimeDelay;
    }

    function setMinimumInitialVcPayment(uint256 newMinimumInitialVcPayment) public override onlyFunctionalManager {

        settings.minimumInitialVcPayment = newMinimumInitialVcPayment;
        emit MinimumInitialVcPaymentChanged(newMinimumInitialVcPayment);
    }

    function getMinimumInitialVcPayment() external override view returns (uint) {

        return settings.minimumInitialVcPayment;
    }

    function getSettings() external override view returns(
        uint genesisRefTimeDelay,
        uint256 minimumInitialVcPayment
    ) {

        Settings memory _settings = settings;
        genesisRefTimeDelay = _settings.genesisRefTimeDelay;
        minimumInitialVcPayment = _settings.minimumInitialVcPayment;
    }

    function importSubscription(uint vcId, ISubscriptions previousSubscriptionsContract) public override onlyInitializationAdmin {

        require(virtualChains[vcId].owner == address(0), "the vcId already exists");

        (string memory name,
        string memory tier,
        uint256 rate,
        uint expiresAt,
        uint256 genRefTime,
        address owner,
        string memory deploymentSubset,
        bool isCertified) = previousSubscriptionsContract.getVcData(vcId);

        virtualChains[vcId] = VirtualChain({
            name: name,
            tier: tier,
            rate: rate,
            expiresAt: expiresAt,
            genRefTime: genRefTime,
            owner: owner,
            deploymentSubset: deploymentSubset,
            isCertified: isCertified
            });

        if (vcId >= nextVcId) {
            nextVcId = vcId + 1;
        }

        emit SubscriptionChanged(vcId, owner, name, genRefTime, tier, rate, expiresAt, isCertified, deploymentSubset);
    }


    function _extendSubscription(uint256 vcId, uint256 amount, string memory tier, uint256 rate, address payer) private {

        VirtualChain memory vc = virtualChains[vcId];
        require(vc.genRefTime != 0, "vc does not exist");
        require(keccak256(bytes(tier)) == keccak256(bytes(virtualChains[vcId].tier)), "given tier must match the VC tier");

        IFeesWallet feesWallet = vc.isCertified ? certifiedFeesWallet : generalFeesWallet;
        require(erc20.transferFrom(msg.sender, address(this), amount), "failed to transfer subscription fees from subscriber to subscriptions");
        require(erc20.approve(address(feesWallet), amount), "failed to approve rewards to acquire subscription fees");

        uint fromTimestamp = vc.expiresAt > now ? vc.expiresAt : now;
        feesWallet.fillFeeBuckets(amount, rate, fromTimestamp);

        vc.expiresAt = fromTimestamp.add(amount.mul(30 days).div(rate));
        vc.rate = rate;

        virtualChains[vcId].expiresAt = vc.expiresAt;
        virtualChains[vcId].rate = vc.rate;

        emit SubscriptionChanged(vcId, vc.owner, vc.name, vc.genRefTime, vc.tier, vc.rate, vc.expiresAt, vc.isCertified, vc.deploymentSubset);
        emit Payment(vcId, payer, amount, vc.tier, vc.rate);
    }


    IFeesWallet generalFeesWallet;
    IFeesWallet certifiedFeesWallet;
    IProtocol protocolContract;

    function refreshContracts() external override {

        generalFeesWallet = IFeesWallet(getGeneralFeesWallet());
        certifiedFeesWallet = IFeesWallet(getCertifiedFeesWallet());
        protocolContract = IProtocol(getProtocolContract());
    }
}


pragma solidity 0.6.12;







contract ContractRegistry is IContractRegistry, Initializable, WithClaimableRegistryManagement {


	address previousContractRegistry;
	mapping(string => address) contracts;
	address[] managedContractAddresses;
	mapping(string => address) managers;

	constructor(address _previousContractRegistry, address registryAdmin) public {
		previousContractRegistry = _previousContractRegistry;
		_transferRegistryManagement(registryAdmin);
	}

	modifier onlyAdmin {

		require(msg.sender == registryAdmin() || msg.sender == initializationAdmin(), "sender is not an admin (registryAdmin or initializationAdmin when initialization in progress)");

		_;
	}

	modifier onlyAdminOrMigrationManager {

		require(msg.sender == registryAdmin() || msg.sender == initializationAdmin() || msg.sender == managers["migrationManager"], "sender is not an admin (registryAdmin or initializationAdmin when initialization in progress) and not the migration manager");

		_;
	}


	function setContract(string calldata contractName, address addr, bool managedContract) external override onlyAdminOrMigrationManager {

		require(!managedContract || addr != address(0), "managed contract may not have address(0)");
		removeManagedContract(contracts[contractName]);
		contracts[contractName] = addr;
		if (managedContract) {
			addManagedContract(addr);
		}
		emit ContractAddressUpdated(contractName, addr, managedContract);
		notifyOnContractsChange();
	}

	function getContract(string calldata contractName) external override view returns (address) {

		return contracts[contractName];
	}

	function getManagedContracts() external override view returns (address[] memory) {

		return managedContractAddresses;
	}

	function lockContracts() external override onlyAdminOrMigrationManager {

		for (uint i = 0; i < managedContractAddresses.length; i++) {
			ILockable(managedContractAddresses[i]).lock();
		}
	}

	function unlockContracts() external override onlyAdminOrMigrationManager {

		for (uint i = 0; i < managedContractAddresses.length; i++) {
			ILockable(managedContractAddresses[i]).unlock();
		}
	}

	function setManager(string calldata role, address manager) external override onlyAdmin {

		managers[role] = manager;
		emit ManagerChanged(role, manager);
	}

	function getManager(string calldata role) external override view returns (address) {

		return managers[role];
	}

	function setNewContractRegistry(IContractRegistry newRegistry) external override onlyAdmin {

		for (uint i = 0; i < managedContractAddresses.length; i++) {
			IContractRegistryAccessor(managedContractAddresses[i]).setContractRegistry(newRegistry);
			IManagedContract(managedContractAddresses[i]).refreshContracts();
		}
		emit ContractRegistryUpdated(address(newRegistry));
	}

	function getPreviousContractRegistry() external override view returns (address) {

		return previousContractRegistry;
	}


	function notifyOnContractsChange() private {

		for (uint i = 0; i < managedContractAddresses.length; i++) {
			IManagedContract(managedContractAddresses[i]).refreshContracts();
		}
	}

	function addManagedContract(address addr) private {

		managedContractAddresses.push(addr);
	}

	function removeManagedContract(address addr) private {

		uint length = managedContractAddresses.length;
		for (uint i = 0; i < length; i++) {
			if (managedContractAddresses[i] == addr) {
				if (i != length - 1) {
					managedContractAddresses[i] = managedContractAddresses[length-1];
				}
				managedContractAddresses.pop();
				length--;
			}
		}
	}

}


pragma solidity 0.6.12;





contract MonthlySubscriptionPlan is ContractRegistryAccessor {


    string public tier;
    uint256 public monthlyRate;

    IERC20 public erc20;

    constructor(IContractRegistry _contractRegistry, address _registryAdmin, IERC20 _erc20, string memory _tier, uint256 _monthlyRate) ContractRegistryAccessor(_contractRegistry, _registryAdmin) public {
        require(bytes(_tier).length > 0, "must specify a valid tier label");

        tier = _tier;
        erc20 = _erc20;
        monthlyRate = _monthlyRate;
    }


    function createVC(string calldata name, uint256 amount, bool isCertified, string calldata deploymentSubset) external {

        require(amount > 0, "must include funds");

        ISubscriptions subs = ISubscriptions(getSubscriptionsContract());
        require(erc20.transferFrom(msg.sender, address(this), amount), "failed to transfer subscription fees");
        require(erc20.approve(address(subs), amount), "failed to transfer subscription fees");
        subs.createVC(name, tier, monthlyRate, amount, msg.sender, isCertified, deploymentSubset);
    }

    function extendSubscription(uint256 vcId, uint256 amount) external {

        require(amount > 0, "must include funds");

        ISubscriptions subs = ISubscriptions(getSubscriptionsContract());
        require(erc20.transferFrom(msg.sender, address(this), amount), "failed to transfer subscription fees from vc payer to subscriber");
        require(erc20.approve(address(subs), amount), "failed to approve subscription fees to subscriptions by subscriber");
        subs.extendSubscription(vcId, amount, tier, monthlyRate, msg.sender);
    }

}