
pragma solidity >=0.5.0 <0.7.0;


contract SelfAuthorized {

    modifier authorized() {

        require(msg.sender == address(this), "Method can only be called from this contract");
        _;
    }
}

contract MasterCopy is SelfAuthorized {


    event ChangedMasterCopy(address masterCopy);

    address private masterCopy;

    function changeMasterCopy(address _masterCopy)
        public
        authorized
    {

        require(_masterCopy != address(0), "Invalid master copy address provided");
        masterCopy = _masterCopy;
        emit ChangedMasterCopy(_masterCopy);
    }
}

contract Enum {

    enum Operation {
        Call,
        DelegateCall
    }
}

contract Executor {


    function execute(address to, uint256 value, bytes memory data, Enum.Operation operation, uint256 txGas)
        internal
        returns (bool success)
    {

        if (operation == Enum.Operation.Call)
            success = executeCall(to, value, data, txGas);
        else if (operation == Enum.Operation.DelegateCall)
            success = executeDelegateCall(to, data, txGas);
        else
            success = false;
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

contract ModuleManager is SelfAuthorized, Executor {


    event EnabledModule(Module module);
    event DisabledModule(Module module);
    event ExecutionFromModuleSuccess(address indexed module);
    event ExecutionFromModuleFailure(address indexed module);

    address internal constant SENTINEL_MODULES = address(0x1);

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
        if (success) emit ExecutionFromModuleSuccess(msg.sender);
        else emit ExecutionFromModuleFailure(msg.sender);
    }

    function execTransactionFromModuleReturnData(address to, uint256 value, bytes memory data, Enum.Operation operation)
        public
        returns (bool success, bytes memory returnData)
    {

        success = execTransactionFromModule(to, value, data, operation);
        assembly {
            let ptr := mload(0x40)
            mstore(0x40, add(ptr, add(returndatasize(), 0x20)))
            mstore(ptr, returndatasize())
            returndatacopy(add(ptr, 0x20), 0, returndatasize())
            returnData := ptr
        }
    }

    function getModules()
        public
        view
        returns (address[] memory)
    {

        (address[] memory array,) = getModulesPaginated(SENTINEL_MODULES, 10);
        return array;
    }

    function getModulesPaginated(address start, uint256 pageSize)
        public
        view
        returns (address[] memory array, address next)
    {

        array = new address[](pageSize);

        uint256 moduleCount = 0;
        address currentModule = modules[start];
        while(currentModule != address(0x0) && currentModule != SENTINEL_MODULES && moduleCount < pageSize) {
            array[moduleCount] = currentModule;
            currentModule = modules[currentModule];
            moduleCount++;
        }
        next = currentModule;
        assembly {
            mstore(array, moduleCount)
        }
    }
}

contract OwnerManager is SelfAuthorized {


    event AddedOwner(address owner);
    event RemovedOwner(address owner);
    event ChangedThreshold(uint256 threshold);

    address internal constant SENTINEL_OWNERS = address(0x1);

    mapping(address => address) internal owners;
    uint256 ownerCount;
    uint256 internal threshold;

    function setupOwners(address[] memory _owners, uint256 _threshold)
        internal
    {

        require(threshold == 0, "Owners have already been setup");
        require(_threshold <= _owners.length, "Threshold cannot exceed owner count");
        require(_threshold >= 1, "Threshold needs to be greater than 0");
        address currentOwner = SENTINEL_OWNERS;
        for (uint256 i = 0; i < _owners.length; i++) {
            address owner = _owners[i];
            require(owner != address(0) && owner != SENTINEL_OWNERS, "Invalid owner address provided");
            require(owners[owner] == address(0), "Duplicate owner address provided");
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

        require(owner != address(0) && owner != SENTINEL_OWNERS, "Invalid owner address provided");
        require(owners[owner] == address(0), "Address is already an owner");
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
        require(owner != address(0) && owner != SENTINEL_OWNERS, "Invalid owner address provided");
        require(owners[prevOwner] == owner, "Invalid prevOwner, owner pair provided");
        owners[prevOwner] = owners[owner];
        owners[owner] = address(0);
        ownerCount--;
        emit RemovedOwner(owner);
        if (threshold != _threshold)
            changeThreshold(_threshold);
    }

    function swapOwner(address prevOwner, address oldOwner, address newOwner)
        public
        authorized
    {

        require(newOwner != address(0) && newOwner != SENTINEL_OWNERS, "Invalid owner address provided");
        require(owners[newOwner] == address(0), "Address is already an owner");
        require(oldOwner != address(0) && oldOwner != SENTINEL_OWNERS, "Invalid owner address provided");
        require(owners[prevOwner] == oldOwner, "Invalid prevOwner, owner pair provided");
        owners[newOwner] = owners[oldOwner];
        owners[prevOwner] = newOwner;
        owners[oldOwner] = address(0);
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

        return owner != SENTINEL_OWNERS && owners[owner] != address(0);
    }

    function getOwners()
        public
        view
        returns (address[] memory)
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

contract VestingModule is Module {

    using SafeMath for uint256;

    string public constant NAME = "Vesting Module";
    string public constant VERSION = "0.1.0";

    mapping (address => Vest) public vests;

    struct Vest {
        uint256 startDate;
        uint256 interval;
        uint256 amount;
        address to;

        uint256 numVestSent;
    }

    event VestAdded(address token, uint256 startDate, uint256 interval, uint256 amount, address to, uint256 timestamp);
    event TransferVested(address token, uint256 amount, uint256 numVest, uint256 timestamp);

    function setup(
        address[] memory tokens,
        uint256[] memory startDates,
        uint256[] memory intervals,
        uint256[] memory amounts,
        address[] memory tos
    )
        public
    {

        setManager();
        for (uint256 i = 0; i < tokens.length; i++) {
            setVest(tokens[i], startDates[i], intervals[i], amounts[i], tos[i]);
        }
    }

    function setVest(address token, uint256 startDate, uint256 interval, uint256 amount, address to)
        public
        authorized
    {

        uint256 blocktime = block.timestamp;
        require(startDate >= blocktime, "Start date shouldn't be earlier than now");
        require(interval > 0, "Vest interval mustn't be zero");
        require(amount > 0, "Vest amount mustn't be zero");
        require(to != address(0), "Invalid to address");

        vests[token] = Vest({
            startDate: startDate,
            interval: interval,
            amount: amount,
            to: to,
            numVestSent: 0
        });

        emit VestAdded(token, startDate, interval, amount, to, blocktime);
    }

    function removeVest(address token)
        public
        authorized
    {

        require(vests[token].amount > 0, "Vest not exsit");
        delete vests[token];
    }

    function hasVest(address token) public view returns(bool) {

        return (vests[token].amount > 0);
    }

    function unlockedVest(address token)
        public
        view
        returns(uint256)
    {

        require(hasVest(token), "Vest plan not found");
        uint256 timeNow = block.timestamp;
        Vest memory vest = vests[token];
        if (timeNow < vest.startDate) {
            return 0;
        }
        uint256 dt = timeNow - vest.startDate;
        return 1 + dt / vest.interval;  // the first round happens right after it starts
    }

    function availableVest(address token)
        public
        view
        returns(uint256 numVests)
    {

        require(hasVest(token), "Vest plan doesn't exist");
        uint256 sent = vests[token].numVestSent;
        uint256 unlocked = unlockedVest(token);
        return unlocked - sent;
    }

    function getBalance(address token) public view returns(uint256) {

        if (token == address(0)) {
            return address(manager).balance;
        } else {
            return IERC20(token).balanceOf(address(manager));
        }
    }

    function execute(address token)
        public
    {

        require(hasVest(token), "Vest plan not found");
        uint256 numAvailable = availableVest(token);
        Vest memory vest = vests[token];
        address to = vest.to;
        uint256 availableToSend = numAvailable * vest.amount;
        uint256 balance = getBalance(token);
        uint256 amount = Math.min(balance, availableToSend);
        require(amount > 0, "No available vest");

        emit TransferVested(token, amount, numAvailable, block.timestamp);
        vests[token].numVestSent += numAvailable;
        if (token == address(0)) {
            require(manager.execTransactionFromModule(to, amount, "", Enum.Operation.Call), "Could not execute ether transfer");
        } else {
            bytes memory data = abi.encodeWithSignature("transfer(address,uint256)", to, amount);
            require(manager.execTransactionFromModule(token, 0, data, Enum.Operation.Call), "Could not execute token transfer");
        }
    }
}