
pragma solidity ^0.4.24;

contract Enum {

    enum Operation {
        Call,
        DelegateCall,
        Create
    }
}

contract EtherPaymentFallback {


    function ()
        external
        payable
    {

    }
}

contract Executor is EtherPaymentFallback {


    event ContractCreation(address newContract);

    function execute(address to, uint256 value, bytes data, Enum.Operation operation, uint256 txGas)
        internal
        returns (bool success)
    {

        if (operation == Enum.Operation.Call)
            success = executeCall(to, value, data, txGas);
        else if (operation == Enum.Operation.DelegateCall)
            success = executeDelegateCall(to, data, txGas);
        else {
            address newContract = executeCreate(data);
            success = newContract != 0;
            emit ContractCreation(newContract);
        }
    }

    function executeCall(address to, uint256 value, bytes data, uint256 txGas)
        internal
        returns (bool success)
    {

        assembly {
            success := call(txGas, to, value, add(data, 0x20), mload(data), 0, 0)
        }
    }

    function executeDelegateCall(address to, bytes data, uint256 txGas)
        internal
        returns (bool success)
    {

        assembly {
            success := delegatecall(txGas, to, add(data, 0x20), mload(data), 0, 0)
        }
    }

    function executeCreate(bytes data)
        internal
        returns (address newContract)
    {

        assembly {
            newContract := create(0, add(data, 0x20), mload(data))
        }
    }
}

contract SelfAuthorized {

    modifier authorized() {

        require(msg.sender == address(this), "Method can only be called from this contract");
        _;
    }
}

contract ModuleManager is SelfAuthorized, Executor {


    event EnabledModule(Module module);
    event DisabledModule(Module module);

    address public constant SENTINEL_MODULES = address(0x1);

    mapping (address => address) internal modules;
    
    function setupModules(address to, bytes data)
        internal
    {

        require(modules[SENTINEL_MODULES] == 0, "Modules have already been initialized");
        modules[SENTINEL_MODULES] = SENTINEL_MODULES;
        if (to != 0)
            require(executeDelegateCall(to, data, gasleft()), "Could not finish initialization");
    }

    function enableModule(Module module)
        public
        authorized
    {

        require(address(module) != 0 && address(module) != SENTINEL_MODULES, "Invalid module address provided");
        require(modules[module] == 0, "Module has already been added");
        modules[module] = modules[SENTINEL_MODULES];
        modules[SENTINEL_MODULES] = module;
        emit EnabledModule(module);
    }

    function disableModule(Module prevModule, Module module)
        public
        authorized
    {

        require(address(module) != 0 && address(module) != SENTINEL_MODULES, "Invalid module address provided");
        require(modules[prevModule] == address(module), "Invalid prevModule, module pair provided");
        modules[prevModule] = modules[module];
        modules[module] = 0;
        emit DisabledModule(module);
    }

    function execTransactionFromModule(address to, uint256 value, bytes data, Enum.Operation operation)
        public
        returns (bool success)
    {

        require(modules[msg.sender] != 0, "Method can only be called from an enabled module");
        success = execute(to, value, data, operation, gasleft());
    }

    function getModules()
        public
        view
        returns (address[])
    {

        uint256 moduleCount = 0;
        address currentModule = modules[SENTINEL_MODULES];
        while(currentModule != SENTINEL_MODULES) {
            currentModule = modules[currentModule];
            moduleCount ++;
        }
        address[] memory array = new address[](moduleCount);

        moduleCount = 0;
        currentModule = modules[SENTINEL_MODULES];
        while(currentModule != SENTINEL_MODULES) {
            array[moduleCount] = currentModule;
            currentModule = modules[currentModule];
            moduleCount ++;
        }
        return array;
    }
}

contract OwnerManager is SelfAuthorized {


    event AddedOwner(address owner);
    event RemovedOwner(address owner);
    event ChangedThreshold(uint256 threshold);

    address public constant SENTINEL_OWNERS = address(0x1);

    mapping(address => address) internal owners;
    uint256 ownerCount;
    uint256 internal threshold;

    function setupOwners(address[] _owners, uint256 _threshold)
        internal
    {

        require(threshold == 0, "Owners have already been setup");
        require(_threshold <= _owners.length, "Threshold cannot exceed owner count");
        require(_threshold >= 1, "Threshold needs to be greater than 0");
        address currentOwner = SENTINEL_OWNERS;
        for (uint256 i = 0; i < _owners.length; i++) {
            address owner = _owners[i];
            require(owner != 0 && owner != SENTINEL_OWNERS, "Invalid owner address provided");
            require(owners[owner] == 0, "Duplicate owner address provided");
            owners[currentOwner] = owner;
            currentOwner = owner;
        }
        owners[currentOwner] = SENTINEL_OWNERS;
        ownerCount = _owners.length;
        threshold = _threshold;
    }

    function addOwnerWithThreshold(address owner, uint256 _threshold)
        public
        authorized
    {

        require(owner != 0 && owner != SENTINEL_OWNERS, "Invalid owner address provided");
        require(owners[owner] == 0, "Address is already an owner");
        owners[owner] = owners[SENTINEL_OWNERS];
        owners[SENTINEL_OWNERS] = owner;
        ownerCount++;
        emit AddedOwner(owner);
        if (threshold != _threshold)
            changeThreshold(_threshold);
    }

    function removeOwner(address prevOwner, address owner, uint256 _threshold)
        public
        authorized
    {

        require(ownerCount - 1 >= _threshold, "New owner count needs to be larger than new threshold");
        require(owner != 0 && owner != SENTINEL_OWNERS, "Invalid owner address provided");
        require(owners[prevOwner] == owner, "Invalid prevOwner, owner pair provided");
        owners[prevOwner] = owners[owner];
        owners[owner] = 0;
        ownerCount--;
        emit RemovedOwner(owner);
        if (threshold != _threshold)
            changeThreshold(_threshold);
    }

    function swapOwner(address prevOwner, address oldOwner, address newOwner)
        public
        authorized
    {

        require(newOwner != 0 && newOwner != SENTINEL_OWNERS, "Invalid owner address provided");
        require(owners[newOwner] == 0, "Address is already an owner");
        require(oldOwner != 0 && oldOwner != SENTINEL_OWNERS, "Invalid owner address provided");
        require(owners[prevOwner] == oldOwner, "Invalid prevOwner, owner pair provided");
        owners[newOwner] = owners[oldOwner];
        owners[prevOwner] = newOwner;
        owners[oldOwner] = 0;
        emit RemovedOwner(oldOwner);
        emit AddedOwner(newOwner);
    }

    function changeThreshold(uint256 _threshold)
        public
        authorized
    {

        require(_threshold <= ownerCount, "Threshold cannot exceed owner count");
        require(_threshold >= 1, "Threshold needs to be greater than 0");
        threshold = _threshold;
        emit ChangedThreshold(threshold);
    }

    function getThreshold()
        public
        view
        returns (uint256)
    {

        return threshold;
    }

    function isOwner(address owner)
        public
        view
        returns (bool)
    {

        return owners[owner] != 0;
    }

    function getOwners()
        public
        view
        returns (address[])
    {

        address[] memory array = new address[](ownerCount);

        uint256 index = 0;
        address currentOwner = owners[SENTINEL_OWNERS];
        while(currentOwner != SENTINEL_OWNERS) {
            array[index] = currentOwner;
            currentOwner = owners[currentOwner];
            index ++;
        }
        return array;
    }
}

contract MasterCopy is SelfAuthorized {

    address masterCopy;

    function changeMasterCopy(address _masterCopy)
        public
        authorized
    {

        require(_masterCopy != 0, "Invalid master copy address provided");
        masterCopy = _masterCopy;
    }
}

contract Module is MasterCopy {


    ModuleManager public manager;

    modifier authorized() {

        require(msg.sender == address(manager), "Method can only be called from manager");
        _;
    }

    function setManager()
        internal
    {

        require(address(manager) == 0, "Manager has already been set");
        manager = ModuleManager(msg.sender);
    }
}

contract SocialRecoveryModule is Module {


    string public constant NAME = "Social Recovery Module";
    string public constant VERSION = "0.0.2";

    uint256 public threshold;
    address[] public friends;

    mapping (address => bool) public isFriend;
    mapping (bytes32 => bool) public isExecuted;
    mapping (bytes32 => mapping (address => bool)) public isConfirmed;

    modifier onlyFriend() {

        require(isFriend[msg.sender], "Method can only be called by a friend");
        _;
    }

    function setup(address[] _friends, uint256 _threshold)
        public
    {

        require(_threshold <= _friends.length, "Threshold cannot exceed friends count");
        require(_threshold >= 2, "At least 2 friends required");
        setManager();
        for (uint256 i = 0; i < _friends.length; i++) {
            address friend = _friends[i];
            require(friend != 0, "Invalid friend address provided");
            require(!isFriend[friend], "Duplicate friend address provided");
            isFriend[friend] = true;
        }
        friends = _friends;
        threshold = _threshold;
    }

    function confirmTransaction(bytes32 dataHash)
        public
        onlyFriend
    {

        require(!isExecuted[dataHash], "Recovery already executed");
        isConfirmed[dataHash][msg.sender] = true;
    }

    function recoverAccess(address prevOwner, address oldOwner, address newOwner)
        public
        onlyFriend
    {

        bytes memory data = abi.encodeWithSignature("swapOwner(address,address,address)", prevOwner, oldOwner, newOwner);
        bytes32 dataHash = getDataHash(data);
        require(!isExecuted[dataHash], "Recovery already executed");
        require(isConfirmedByRequiredFriends(dataHash), "Recovery has not enough confirmations");
        isExecuted[dataHash] = true;
        require(manager.execTransactionFromModule(address(manager), 0, data, Enum.Operation.Call), "Could not execute recovery");
    }

    function isConfirmedByRequiredFriends(bytes32 dataHash)
        public
        view
        returns (bool)
    {

        uint256 confirmationCount;
        for (uint256 i = 0; i < friends.length; i++) {
            if (isConfirmed[dataHash][friends[i]])
                confirmationCount++;
            if (confirmationCount == threshold)
                return true;
        }
        return false;
    }

    function getDataHash(bytes data)
        public
        pure
        returns (bytes32)
    {

        return keccak256(data);
    }
}