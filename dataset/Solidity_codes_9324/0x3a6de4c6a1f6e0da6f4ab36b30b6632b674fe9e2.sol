
pragma solidity ^0.5.0;



contract SelfAuthorized {

    modifier authorized() {

        require(msg.sender == address(this), "Method can only be called from this contract");
        _;
    }
}


contract MasterCopy is SelfAuthorized {

    address masterCopy;

    function changeMasterCopy(address _masterCopy)
        public
        authorized
    {

        require(_masterCopy != address(0), "Invalid master copy address provided");
        masterCopy = _masterCopy;
    }
}


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

    function execute(address to, uint256 value, bytes memory data, Enum.Operation operation, uint256 txGas)
        internal
        returns (bool success)
    {

        if (operation == Enum.Operation.Call)
            success = executeCall(to, value, data, txGas);
        else if (operation == Enum.Operation.DelegateCall)
            success = executeDelegateCall(to, data, txGas);
        else {
            address newContract = executeCreate(data);
            success = newContract != address(0);
            emit ContractCreation(newContract);
        }
    }

    function executeCall(address to, uint256 value, bytes memory data, uint256 txGas)
        internal
        returns (bool success)
    {

        assembly {
            success := call(txGas, to, value, add(data, 0x20), mload(data), 0, 0)
        }
    }

    function executeDelegateCall(address to, bytes memory data, uint256 txGas)
        internal
        returns (bool success)
    {

        assembly {
            success := delegatecall(txGas, to, add(data, 0x20), mload(data), 0, 0)
        }
    }

    function executeCreate(bytes memory data)
        internal
        returns (address newContract)
    {

        assembly {
            newContract := create(0, add(data, 0x20), mload(data))
        }
    }
}


contract ModuleManager is SelfAuthorized, Executor {


    event EnabledModule(Module module);
    event DisabledModule(Module module);

    address public constant SENTINEL_MODULES = address(0x1);

    mapping (address => address) internal modules;
    
    function setupModules(address to, bytes memory data)
        internal
    {

        require(modules[SENTINEL_MODULES] == address(0), "Modules have already been initialized");
        modules[SENTINEL_MODULES] = SENTINEL_MODULES;
        if (to != address(0))
            require(executeDelegateCall(to, data, gasleft()), "Could not finish initialization");
    }

    function enableModule(Module module)
        public
        authorized
    {

        require(address(module) != address(0) && address(module) != SENTINEL_MODULES, "Invalid module address provided");
        require(modules[address(module)] == address(0), "Module has already been added");
        modules[address(module)] = modules[SENTINEL_MODULES];
        modules[SENTINEL_MODULES] = address(module);
        emit EnabledModule(module);
    }

    function disableModule(Module prevModule, Module module)
        public
        authorized
    {

        require(address(module) != address(0) && address(module) != SENTINEL_MODULES, "Invalid module address provided");
        require(modules[address(prevModule)] == address(module), "Invalid prevModule, module pair provided");
        modules[address(prevModule)] = modules[address(module)];
        modules[address(module)] = address(0);
        emit DisabledModule(module);
    }

    function execTransactionFromModule(address to, uint256 value, bytes memory data, Enum.Operation operation)
        public
        returns (bool success)
    {

        require(msg.sender != SENTINEL_MODULES && modules[msg.sender] != address(0), "Method can only be called from an enabled module");
        success = execute(to, value, data, operation, gasleft());
    }

    function getModules()
        public
        view
        returns (address[] memory)
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


contract Module is MasterCopy {


    ModuleManager public manager;

    modifier authorized() {

        require(msg.sender == address(manager), "Method can only be called from manager");
        _;
    }

    function setManager()
        internal
    {

        require(address(manager) == address(0), "Manager has already been set");
        manager = ModuleManager(msg.sender);
    }
}


contract CreateAndAddModules {


    function enableModule(Module module)
    public
    {

        revert();
    }

    function createAndAddModules(address proxyFactory, bytes memory data)
    public
    {

        uint256 length = data.length;
        Module module;
        uint256 i = 0;
        while (i < length) {
            assembly {
                let createBytesLength := mload(add(0x20, add(data, i)))
                let createBytes := add(0x40, add(data, i))

                let output := mload(0x40)
                if eq(delegatecall(gas, proxyFactory, createBytes, createBytesLength, output, 0x20), 0) {revert(0, 0)}
                module := and(mload(output), 0xffffffffffffffffffffffffffffffffffffffff)

                i := add(i, add(0x20, mul(div(add(createBytesLength, 0x1f), 0x20), 0x20)))
            }
            this.enableModule(module);
        }
    }
    function createNoFactory(address proxy, bytes memory data)
    public
    {


        require(proxy != address(0), "createAndAddModules::createNoFactory INVALID_DATA: PROXY_ADDRESS");

        if (data.length > 0) {
            assembly {
                if eq(call(gas, proxy, 0, add(data, 0x20), mload(data), 0, 0), 0) {}
            }
        }

        Module module = Module(proxy);
        this.enableModule(module);

    }
}