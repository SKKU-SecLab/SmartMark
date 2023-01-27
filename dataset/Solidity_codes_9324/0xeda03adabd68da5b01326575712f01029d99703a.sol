


pragma solidity 0.6.12;

interface IProtocol {

    event ProtocolVersionChanged(string deploymentSubset, uint256 currentVersion, uint256 nextVersion, uint256 fromTimestamp);


    function deploymentSubsetExists(string calldata deploymentSubset) external view returns (bool);


    function getProtocolVersion(string calldata deploymentSubset) external view returns (uint256 currentVersion);



    function createDeploymentSubset(string calldata deploymentSubset, uint256 initialProtocolVersion) external /* onlyFunctionalManager */;



    function setProtocolVersion(string calldata deploymentSubset, uint256 nextVersion, uint256 fromTimestamp) external /* onlyFunctionalManager */;

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



contract Protocol is IProtocol, ManagedContract {


    struct DeploymentSubset {
        bool exists;
        uint256 nextVersion;
        uint fromTimestamp;
        uint256 currentVersion;
    }

    mapping(string => DeploymentSubset) public deploymentSubsets;

    constructor(IContractRegistry _contractRegistry, address _registryAdmin) ManagedContract(_contractRegistry, _registryAdmin) public {}


    function deploymentSubsetExists(string calldata deploymentSubset) external override view returns (bool) {

        return deploymentSubsets[deploymentSubset].exists;
    }

    function getProtocolVersion(string calldata deploymentSubset) external override view returns (uint256 currentVersion) {

        (, currentVersion) = checkPrevUpgrades(deploymentSubset);
    }

    function createDeploymentSubset(string calldata deploymentSubset, uint256 initialProtocolVersion) external override onlyFunctionalManager {

        require(!deploymentSubsets[deploymentSubset].exists, "deployment subset already exists");

        deploymentSubsets[deploymentSubset].currentVersion = initialProtocolVersion;
        deploymentSubsets[deploymentSubset].nextVersion = initialProtocolVersion;
        deploymentSubsets[deploymentSubset].fromTimestamp = now;
        deploymentSubsets[deploymentSubset].exists = true;

        emit ProtocolVersionChanged(deploymentSubset, initialProtocolVersion, initialProtocolVersion, now);
    }

    function setProtocolVersion(string calldata deploymentSubset, uint256 nextVersion, uint256 fromTimestamp) external override onlyFunctionalManager {

        require(deploymentSubsets[deploymentSubset].exists, "deployment subset does not exist");
        require(fromTimestamp > now, "a protocol update can only be scheduled for the future");

        (bool prevUpgradeExecuted, uint256 currentVersion) = checkPrevUpgrades(deploymentSubset);

        require(nextVersion >= currentVersion, "protocol version must be greater or equal to current version");

        deploymentSubsets[deploymentSubset].nextVersion = nextVersion;
        deploymentSubsets[deploymentSubset].fromTimestamp = fromTimestamp;
        if (prevUpgradeExecuted) {
            deploymentSubsets[deploymentSubset].currentVersion = currentVersion;
        }

        emit ProtocolVersionChanged(deploymentSubset, currentVersion, nextVersion, fromTimestamp);
    }


    function checkPrevUpgrades(string memory deploymentSubset) private view returns (bool prevUpgradeExecuted, uint256 currentVersion) {

        prevUpgradeExecuted = deploymentSubsets[deploymentSubset].fromTimestamp <= now;
        currentVersion = prevUpgradeExecuted ? deploymentSubsets[deploymentSubset].nextVersion :
                                               deploymentSubsets[deploymentSubset].currentVersion;
    }


    function refreshContracts() external override {}

}