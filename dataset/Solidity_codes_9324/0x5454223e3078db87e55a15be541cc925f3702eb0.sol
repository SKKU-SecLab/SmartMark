
pragma solidity 0.6.12;

interface IContractRegistry {


	event ContractAddressUpdated(string contractName, address addr, bool managedContract);
	event ManagerChanged(string role, address newManager);
	event ContractRegistryUpdated(address newContractRegistry);


	function setContract(string calldata contractName, address addr, bool managedContract) external /* onlyAdmin */;


	function getContract(string calldata contractName) external view returns (address);


	function getManagedContracts() external view returns (address[] memory);


	function setManager(string calldata role, address manager) external /* onlyAdmin */;


	function getManager(string calldata role) external view returns (address);


	function lockContracts() external /* onlyAdmin */;


	function unlockContracts() external /* onlyAdmin */;


	function setNewContractRegistry(IContractRegistry newRegistry) external /* onlyAdmin */;


	function getPreviousContractRegistry() external view returns (address);


}

pragma solidity 0.6.12;

interface ILockable {


    event Locked();
    event Unlocked();

    function lock() external /* onlyLockOwner */;

    function unlock() external /* onlyLockOwner */;

    function isLocked() view external returns (bool);


}

pragma solidity 0.6.12;


interface IContractRegistryListener {


    function refreshContracts() external;


    function setContractRegistry(IContractRegistry newRegistry) external;


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

}// UNLICENSED

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

	function getManagedContracts() external override view returns (address[] memory) {

		return managedContractAddresses;
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
			IContractRegistryListener(managedContractAddresses[i]).setContractRegistry(newRegistry);
			IContractRegistryListener(managedContractAddresses[i]).refreshContracts();
		}
		emit ContractRegistryUpdated(address(newRegistry));
	}

	function getPreviousContractRegistry() external override view returns (address) {

		return previousContractRegistry;
	}


	function notifyOnContractsChange() private {

		for (uint i = 0; i < managedContractAddresses.length; i++) {
			IContractRegistryListener(managedContractAddresses[i]).refreshContracts();
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
