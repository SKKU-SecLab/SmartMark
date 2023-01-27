




pragma solidity ^0.5.4;

contract Proxy {


    address implementation;

    event Received(uint indexed value, address indexed sender, bytes data);

    constructor(address _implementation) public {
        implementation = _implementation;
    }

    function() external payable {

        if (msg.data.length == 0 && msg.value > 0) {
            emit Received(msg.value, msg.sender, msg.data);
        } else {
            assembly {
                let target := sload(0)
                calldatacopy(0, 0, calldatasize())
                let result := delegatecall(gas, target, 0, calldatasize(), 0, 0)
                returndatacopy(0, 0, returndatasize())
                switch result
                case 0 {revert(0, returndatasize())}
                default {return (0, returndatasize())}
            }
        }
    }
}

contract BaseWallet {

    function init(address _owner, address[] calldata _modules) external;

    function authoriseModule(address _module, bool _value) external;

    function enableStaticCall(address _module, bytes4 _method) external;

    function setOwner(address _newOwner) external;

    function invoke(address _target, uint _value, bytes calldata _data) external returns (bytes memory _result);

    function() external payable;
}

contract Owned {


    address public owner;

    event OwnerChanged(address indexed _newOwner);

    modifier onlyOwner {

        require(msg.sender == owner, "Must be owner");
        _;
    }

    constructor() public {
        owner = msg.sender;
    }

    function changeOwner(address _newOwner) external onlyOwner {

        require(_newOwner != address(0), "Address must not be null");
        owner = _newOwner;
        emit OwnerChanged(_newOwner);
    }
}

contract Managed is Owned {


    mapping (address => bool) public managers;

    modifier onlyManager {

        require(managers[msg.sender] == true, "M: Must be manager");
        _;
    }

    event ManagerAdded(address indexed _manager);
    event ManagerRevoked(address indexed _manager);

    function addManager(address _manager) external onlyOwner {

        require(_manager != address(0), "M: Address must not be null");
        if (managers[_manager] == false) {
            managers[_manager] = true;
            emit ManagerAdded(_manager);
        }
    }

    function revokeManager(address _manager) external onlyOwner {

        require(managers[_manager] == true, "M: Target must be an existing manager");
        delete managers[_manager];
        emit ManagerRevoked(_manager);
    }
}

interface IENSManager {

    event RootnodeOwnerChange(bytes32 indexed _rootnode, address indexed _newOwner);
    event ENSResolverChanged(address addr);
    event Registered(address indexed _owner, string _ens);
    event Unregistered(string _ens);

    function changeRootnodeOwner(address _newOwner) external;

    function register(string calldata _label, address _owner) external;

    function isAvailable(bytes32 _subnode) external view returns(bool);

    function getENSReverseRegistrar() external view returns (address);

    function ensResolver() external view returns (address);

}

contract ModuleRegistry {

    function registerModule(address _module, bytes32 _name) external;

    function deregisterModule(address _module) external;

    function registerUpgrader(address _upgrader, bytes32 _name) external;

    function deregisterUpgrader(address _upgrader) external;

    function moduleInfo(address _module) external view returns (bytes32);

    function upgraderInfo(address _upgrader) external view returns (bytes32);

    function isRegisteredModule(address _module) external view returns (bool);

    function isRegisteredModule(address[] calldata _modules) external view returns (bool);

    function isRegisteredUpgrader(address _upgrader) external view returns (bool);

}

interface IGuardianStorage{

    function addGuardian(BaseWallet _wallet, address _guardian) external;

    function revokeGuardian(BaseWallet _wallet, address _guardian) external;

    function isGuardian(BaseWallet _wallet, address _guardian) external view returns (bool);

}

contract WalletFactory is Owned, Managed {


    address public moduleRegistry;
    address public walletImplementation;
    address public ensManager;
    address public guardianStorage;


    event ModuleRegistryChanged(address addr);
    event ENSManagerChanged(address addr);
    event GuardianStorageChanged(address addr);
    event WalletCreated(address indexed wallet, address indexed owner, address indexed guardian);


    modifier guardianStorageDefined {

        require(guardianStorage != address(0), "GuardianStorage address not defined");
        _;
    }


    constructor(address _moduleRegistry, address _walletImplementation, address _ensManager) public {
        moduleRegistry = _moduleRegistry;
        walletImplementation = _walletImplementation;
        ensManager = _ensManager;
    }


    function createWallet(
        address _owner,
        address[] calldata _modules,
        string calldata _label
    )
        external
        onlyManager
    {

        _createWallet(_owner, _modules, _label, address(0));
    }

    function createWalletWithGuardian(
        address _owner,
        address[] calldata _modules,
        string calldata _label,
        address _guardian
    )
        external
        onlyManager
        guardianStorageDefined
    {

        require(_guardian != (address(0)), "WF: guardian cannot be null");
        _createWallet(_owner, _modules, _label, _guardian);
    }

    function createCounterfactualWallet(
        address _owner,
        address[] calldata _modules,
        string calldata _label,
        bytes32 _salt
    )
        external
        onlyManager
    {

        _createCounterfactualWallet(_owner, _modules, _label, address(0), _salt);
    }

    function createCounterfactualWalletWithGuardian(
        address _owner,
        address[] calldata _modules,
        string calldata _label,
        address _guardian,
        bytes32 _salt
    )
        external
        onlyManager
        guardianStorageDefined
    {

        require(_guardian != (address(0)), "WF: guardian cannot be null");
        _createCounterfactualWallet(_owner, _modules, _label, _guardian, _salt);
    }

    function getAddressForCounterfactualWallet(
        address _owner,
        address[] calldata _modules,
        bytes32 _salt
    )
        external
        view
        returns (address _wallet)
    {

        _wallet = _getAddressForCounterfactualWallet(_owner, _modules, address(0), _salt);
    }

    function getAddressForCounterfactualWalletWithGuardian(
        address _owner,
        address[] calldata _modules,
        address _guardian,
        bytes32 _salt
    )
        external
        view
        returns (address _wallet)
    {

        require(_guardian != (address(0)), "WF: guardian cannot be null");
        _wallet = _getAddressForCounterfactualWallet(_owner, _modules, _guardian, _salt);
    }

    function changeModuleRegistry(address _moduleRegistry) external onlyOwner {

        require(_moduleRegistry != address(0), "WF: address cannot be null");
        moduleRegistry = _moduleRegistry;
        emit ModuleRegistryChanged(_moduleRegistry);
    }

    function changeENSManager(address _ensManager) external onlyOwner {

        require(_ensManager != address(0), "WF: address cannot be null");
        ensManager = _ensManager;
        emit ENSManagerChanged(_ensManager);
    }

    function changeGuardianStorage(address _guardianStorage) external onlyOwner {

        require(_guardianStorage != address(0), "WF: address cannot be null");
        guardianStorage = _guardianStorage;
        emit GuardianStorageChanged(_guardianStorage);
    }

    function init(BaseWallet _wallet) external pure { // solium-disable-line no-empty-blocks

    }


    function _createWallet(address _owner, address[] memory _modules, string memory _label, address _guardian) internal {

        _validateInputs(_owner, _modules, _label);
        Proxy proxy = new Proxy(walletImplementation);
        address payable wallet = address(proxy);
        _configureWallet(BaseWallet(wallet), _owner, _modules, _label, _guardian);
    }

    function _createCounterfactualWallet(
        address _owner,
        address[] memory _modules,
        string memory _label,
        address _guardian,
        bytes32 _salt
    )
        internal
    {

        _validateInputs(_owner, _modules, _label);
        bytes32 newsalt = _newSalt(_salt, _owner, _modules, _guardian);
        bytes memory code = abi.encodePacked(type(Proxy).creationCode, uint256(walletImplementation));
        address payable wallet;
        assembly {
            wallet := create2(0, add(code, 0x20), mload(code), newsalt)
            if iszero(extcodesize(wallet)) { revert(0, returndatasize) }
        }
        _configureWallet(BaseWallet(wallet), _owner, _modules, _label, _guardian);
    }

    function _configureWallet(
        BaseWallet _wallet,
        address _owner,
        address[] memory _modules,
        string memory _label,
        address _guardian
    )
        internal
    {

        address[] memory extendedModules = new address[](_modules.length + 1);
        extendedModules[0] = address(this);
        for (uint i = 0; i < _modules.length; i++) {
            extendedModules[i + 1] = _modules[i];
        }
        _wallet.init(_owner, extendedModules);
        if (_guardian != address(0)) {
            IGuardianStorage(guardianStorage).addGuardian(_wallet, _guardian);
        }
        _registerWalletENS(address(_wallet), _label);
        _wallet.authoriseModule(address(this), false);
        emit WalletCreated(address(_wallet), _owner, _guardian);
    }

    function _getAddressForCounterfactualWallet(
        address _owner,
        address[] memory _modules,
        address _guardian,
        bytes32 _salt
    )
        internal
        view
        returns (address _wallet)
    {

        bytes32 newsalt = _newSalt(_salt, _owner, _modules, _guardian);
        bytes memory code = abi.encodePacked(type(Proxy).creationCode, uint256(walletImplementation));
        bytes32 hash = keccak256(abi.encodePacked(bytes1(0xff), address(this), newsalt, keccak256(code)));
        _wallet = address(uint160(uint256(hash)));
    }

    function _newSalt(bytes32 _salt, address _owner, address[] memory _modules, address _guardian) internal pure returns (bytes32) {

        if (_guardian == address(0)) {
            return keccak256(abi.encodePacked(_salt, _owner, _modules));
        } else {
            return keccak256(abi.encodePacked(_salt, _owner, _modules, _guardian));
        }
    }

    function _validateInputs(address _owner, address[] memory _modules, string memory _label) internal view {

        require(_owner != address(0), "WF: owner cannot be null");
        require(_modules.length > 0, "WF: cannot assign with less than 1 module");
        require(ModuleRegistry(moduleRegistry).isRegisteredModule(_modules), "WF: one or more modules are not registered");
        bytes memory labelBytes = bytes(_label);
        require(labelBytes.length != 0, "WF: ENS lable must be defined");
    }

    function _registerWalletENS(address payable _wallet, string memory _label) internal {

        address ensResolver = IENSManager(ensManager).ensResolver();
        bytes memory methodData = abi.encodeWithSignature("claimWithResolver(address,address)", ensManager, ensResolver);
        address ensReverseRegistrar = IENSManager(ensManager).getENSReverseRegistrar();
        BaseWallet(_wallet).invoke(ensReverseRegistrar, 0, methodData);
        IENSManager(ensManager).register(_label, _wallet);
    }
}