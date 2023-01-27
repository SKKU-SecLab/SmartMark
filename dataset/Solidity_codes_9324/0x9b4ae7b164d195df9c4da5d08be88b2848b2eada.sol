
pragma solidity ^0.8.13;


interface ManagerLike {

    function cdpCan(
        address owner,
        uint256 cdpId,
        address allowedAddr
    ) external view returns (uint256);


    function vat() external view returns (address);


    function ilks(uint256) external view returns (bytes32);


    function owns(uint256) external view returns (address);


    function urns(uint256) external view returns (address);


    function cdpAllow(
        uint256 cdp,
        address usr,
        uint256 ok
    ) external;


    function frob(
        uint256,
        int256,
        int256
    ) external;


    function flux(
        uint256,
        address,
        uint256
    ) external;


    function move(
        uint256,
        address,
        uint256
    ) external;


    function exit(
        address,
        uint256,
        address,
        uint256
    ) external;

}

interface ICommand {

    function isTriggerDataValid(uint256 _cdpId, bytes memory triggerData)
        external
        view
        returns (bool);


    function isExecutionCorrect(uint256 cdpId, bytes memory triggerData)
        external
        view
        returns (bool);


    function isExecutionLegal(uint256 cdpId, bytes memory triggerData) external view returns (bool);


    function execute(
        bytes calldata executionData,
        uint256 cdpId,
        bytes memory triggerData
    ) external;

}

interface BotLike {

    function addRecord(
        uint256 cdpId,
        uint256 triggerType,
        uint256 replacedTriggerId,
        bytes memory triggerData
    ) external;


    function removeRecord(
        uint256 cdpId,
        uint256 triggerId
    ) external;


    function execute(
        bytes calldata executionData,
        uint256 cdpId,
        bytes calldata triggerData,
        address commandAddress,
        uint256 triggerId,
        uint256 daiCoverage
    ) external;

}

contract ServiceRegistry {

    uint256 public constant MAX_DELAY = 30 days;

    mapping(bytes32 => uint256) public lastExecuted;
    mapping(bytes32 => address) private namedService;
    address public owner;
    uint256 public requiredDelay;

    modifier validateInput(uint256 len) {

        require(msg.data.length == len, "registry/illegal-padding");
        _;
    }

    modifier delayedExecution() {

        bytes32 operationHash = keccak256(msg.data);
        uint256 reqDelay = requiredDelay;

        if (lastExecuted[operationHash] == 0 && reqDelay > 0) {
            lastExecuted[operationHash] = block.timestamp;
            emit ChangeScheduled(operationHash, block.timestamp + reqDelay, msg.data);
        } else {
            require(
                block.timestamp - reqDelay > lastExecuted[operationHash],
                "registry/delay-too-small"
            );
            emit ChangeApplied(operationHash, block.timestamp, msg.data);
            _;
            lastExecuted[operationHash] = 0;
        }
    }

    modifier onlyOwner() {

        require(msg.sender == owner, "registry/only-owner");
        _;
    }

    constructor(uint256 initialDelay) {
        require(initialDelay <= MAX_DELAY, "registry/invalid-delay");
        requiredDelay = initialDelay;
        owner = msg.sender;
    }

    function transferOwnership(address newOwner)
        external
        onlyOwner
        validateInput(36)
        delayedExecution
    {

        owner = newOwner;
    }

    function changeRequiredDelay(uint256 newDelay)
        external
        onlyOwner
        validateInput(36)
        delayedExecution
    {

        require(newDelay <= MAX_DELAY, "registry/invalid-delay");
        requiredDelay = newDelay;
    }

    function getServiceNameHash(string memory name) external pure returns (bytes32) {

        return keccak256(abi.encodePacked(name));
    }

    function addNamedService(bytes32 serviceNameHash, address serviceAddress)
        external
        onlyOwner
        validateInput(68)
        delayedExecution
    {

        require(namedService[serviceNameHash] == address(0), "registry/service-override");
        namedService[serviceNameHash] = serviceAddress;
    }

    function updateNamedService(bytes32 serviceNameHash, address serviceAddress)
        external
        onlyOwner
        validateInput(68)
        delayedExecution
    {

        require(namedService[serviceNameHash] != address(0), "registry/service-does-not-exist");
        namedService[serviceNameHash] = serviceAddress;
    }

    function removeNamedService(bytes32 serviceNameHash) external onlyOwner validateInput(36) {

        require(namedService[serviceNameHash] != address(0), "registry/service-does-not-exist");
        namedService[serviceNameHash] = address(0);
        emit NamedServiceRemoved(serviceNameHash);
    }

    function getRegisteredService(string memory serviceName) external view returns (address) {

        return namedService[keccak256(abi.encodePacked(serviceName))];
    }

    function getServiceAddress(bytes32 serviceNameHash) external view returns (address) {

        return namedService[serviceNameHash];
    }

    function clearScheduledExecution(bytes32 scheduledExecution)
        external
        onlyOwner
        validateInput(36)
    {

        require(lastExecuted[scheduledExecution] > 0, "registry/execution-not-scheduled");
        lastExecuted[scheduledExecution] = 0;
        emit ChangeCancelled(scheduledExecution);
    }

    event ChangeScheduled(bytes32 dataHash, uint256 scheduledFor, bytes data);
    event ChangeApplied(bytes32 dataHash, uint256 appliedAt, bytes data);
    event ChangeCancelled(bytes32 dataHash);
    event NamedServiceRemoved(bytes32 nameHash);
}


interface IERC20 {

    function totalSupply() external view returns (uint256);


    function balanceOf(address account) external view returns (uint256);


    function transfer(address to, uint256 amount) external returns (bool);


    function allowance(address owner, address spender) external view returns (uint256);


    function approve(address spender, uint256 amount) external returns (bool);


    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);


    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}

contract DSMath {

    function add(uint256 x, uint256 y) internal pure returns (uint256 z) {

        require((z = x + y) >= x, "");
    }

    function sub(uint256 x, uint256 y) internal pure returns (uint256 z) {

        require((z = x - y) <= x, "");
    }

    function mul(uint256 x, uint256 y) internal pure returns (uint256 z) {

        require(y == 0 || (z = x * y) / y == x, "");
    }

    function div(uint256 x, uint256 y) internal pure returns (uint256 z) {

        return x / y;
    }

    function min(uint256 x, uint256 y) internal pure returns (uint256 z) {

        return x <= y ? x : y;
    }

    function max(uint256 x, uint256 y) internal pure returns (uint256 z) {

        return x >= y ? x : y;
    }

    function imin(int256 x, int256 y) internal pure returns (int256 z) {

        return x <= y ? x : y;
    }

    function imax(int256 x, int256 y) internal pure returns (int256 z) {

        return x >= y ? x : y;
    }

    uint256 internal constant WAD = 10**18;
    uint256 internal constant RAY = 10**27;

    function wmul(uint256 x, uint256 y) internal pure returns (uint256 z) {

        z = add(mul(x, y), WAD / 2) / WAD;
    }

    function rmul(uint256 x, uint256 y) internal pure returns (uint256 z) {

        z = add(mul(x, y), RAY / 2) / RAY;
    }

    function wdiv(uint256 x, uint256 y) internal pure returns (uint256 z) {

        z = add(mul(x, WAD), y / 2) / y;
    }

    function rdiv(uint256 x, uint256 y) internal pure returns (uint256 z) {

        z = add(mul(x, RAY), y / 2) / y;
    }

    function rpow(uint256 x, uint256 n) internal pure returns (uint256 z) {

        z = n % 2 != 0 ? x : RAY;

        for (n /= 2; n != 0; n /= 2) {
            x = rmul(x, x);

            if (n % 2 != 0) {
                z = rmul(z, x);
            }
        }
    }
}

abstract contract IVat {
    struct Urn {
        uint256 ink; // Locked Collateral  [wad]
        uint256 art; // Normalised Debt    [wad]
    }

    struct Ilk {
        uint256 Art; // Total Normalised Debt     [wad]
        uint256 rate; // Accumulated Rates         [ray]
        uint256 spot; // Price with Safety Margin  [ray]
        uint256 line; // Debt Ceiling              [rad]
        uint256 dust; // Urn Debt Floor            [rad]
    }

    mapping(bytes32 => mapping(address => Urn)) public urns;
    mapping(bytes32 => Ilk) public ilks;
    mapping(bytes32 => mapping(address => uint256)) public gem; // [wad]

    function can(address, address) public view virtual returns (uint256);

    function dai(address) public view virtual returns (uint256);

    function frob(
        bytes32,
        address,
        address,
        address,
        int256,
        int256
    ) public virtual;

    function hope(address) public virtual;

    function move(
        address,
        address,
        uint256
    ) public virtual;

    function fork(
        bytes32,
        address,
        address,
        int256,
        int256
    ) public virtual;
}

abstract contract IGem {
    function dec() public virtual returns (uint256);

    function gem() public virtual returns (IGem);

    function join(address, uint256) public payable virtual;

    function exit(address, uint256) public virtual;

    function approve(address, uint256) public virtual;

    function transfer(address, uint256) public virtual returns (bool);

    function transferFrom(
        address,
        address,
        uint256
    ) public virtual returns (bool);

    function deposit() public payable virtual;

    function withdraw(uint256) public virtual;

    function allowance(address, address) public virtual returns (uint256);
}

abstract contract IJoin {
    bytes32 public ilk;

    function dec() public view virtual returns (uint256);

    function gem() public view virtual returns (IGem);

    function join(address, uint256) public payable virtual;

    function exit(address, uint256) public virtual;
}

abstract contract IDaiJoin {
    function vat() public virtual returns (IVat);

    function dai() public virtual returns (IGem);

    function join(address, uint256) public payable virtual;

    function exit(address, uint256) public virtual;
}

abstract contract IJug {
    struct Ilk {
        uint256 duty;
        uint256 rho;
    }

    mapping(bytes32 => Ilk) public ilks;

    function drip(bytes32) public virtual returns (uint256);
}

contract McdUtils is DSMath {

    address public immutable serviceRegistry;
    IERC20 private immutable DAI;
    address private immutable daiJoin;
    address public immutable jug;

    constructor(
        address _serviceRegistry,
        IERC20 _dai,
        address _daiJoin,
        address _jug
    ) {
        serviceRegistry = _serviceRegistry;
        DAI = _dai;
        daiJoin = _daiJoin;
        jug = _jug;
    }

    function toInt256(uint256 x) internal pure returns (int256 y) {

        y = int256(x);
        require(y >= 0, "int256-overflow");
    }

    function _getDrawDart(
        address vat,
        address urn,
        bytes32 ilk,
        uint256 wad
    ) internal returns (int256 dart) {

        uint256 rate = IJug(jug).drip(ilk);

        uint256 dai = IVat(vat).dai(urn);

        if (dai < mul(wad, RAY)) {
            dart = toInt256(sub(mul(wad, RAY), dai) / rate);
            dart = mul(uint256(dart), rate) < mul(wad, RAY) ? dart + 1 : dart;
        }
    }

    function drawDebt(
        uint256 borrowedDai,
        uint256 cdpId,
        ManagerLike manager,
        address sendTo
    ) external {

        address urn = manager.urns(cdpId);
        address vat = manager.vat();

        manager.frob(cdpId, 0, _getDrawDart(vat, urn, manager.ilks(cdpId), borrowedDai));
        manager.move(cdpId, address(this), mul(borrowedDai, RAY));

        if (IVat(vat).can(address(this), daiJoin) == 0) {
            IVat(vat).hope(daiJoin);
        }

        IJoin(daiJoin).exit(sendTo, borrowedDai);
    }
}


contract AutomationBot {

    struct TriggerRecord {
        bytes32 triggerHash;
        uint256 cdpId;
    }

    string private constant CDP_MANAGER_KEY = "CDP_MANAGER";
    string private constant AUTOMATION_BOT_KEY = "AUTOMATION_BOT";
    string private constant AUTOMATION_EXECUTOR_KEY = "AUTOMATION_EXECUTOR";
    string private constant MCD_UTILS_KEY = "MCD_UTILS";

    mapping(uint256 => TriggerRecord) public activeTriggers;

    uint256 public triggersCounter = 0;

    ServiceRegistry public immutable serviceRegistry;
    address public immutable self;

    constructor(ServiceRegistry _serviceRegistry) {
        serviceRegistry = _serviceRegistry;
        self = address(this);
    }

    modifier auth(address caller) {

        require(
            serviceRegistry.getRegisteredService(AUTOMATION_EXECUTOR_KEY) == caller,
            "bot/not-executor"
        );
        _;
    }

    modifier onlyDelegate() {

        require(address(this) != self, "bot/only-delegate");
        _;
    }

    function validatePermissions(
        uint256 cdpId,
        address operator,
        ManagerLike manager
    ) private view {

        require(isCdpOwner(cdpId, operator, manager), "bot/no-permissions");
    }

    function isCdpAllowed(
        uint256 cdpId,
        address operator,
        ManagerLike manager
    ) public view returns (bool) {

        address cdpOwner = manager.owns(cdpId);
        return (manager.cdpCan(cdpOwner, cdpId, operator) == 1) || (operator == cdpOwner);
    }

    function isCdpOwner(
        uint256 cdpId,
        address operator,
        ManagerLike manager
    ) private view returns (bool) {

        return (operator == manager.owns(cdpId));
    }

    function getCommandAddress(uint256 triggerType) public view returns (address) {

        bytes32 commandHash = keccak256(abi.encode("Command", triggerType));

        address commandAddress = serviceRegistry.getServiceAddress(commandHash);

        return commandAddress;
    }

    function getTriggersHash(
        uint256 cdpId,
        bytes memory triggerData,
        address commandAddress
    ) private view returns (bytes32) {

        bytes32 triggersHash = keccak256(
            abi.encodePacked(cdpId, triggerData, serviceRegistry, commandAddress)
        );

        return triggersHash;
    }

    function checkTriggersExistenceAndCorrectness(
        uint256 cdpId,
        uint256 triggerId,
        address commandAddress,
        bytes memory triggerData
    ) private view {

        bytes32 triggersHash = activeTriggers[triggerId].triggerHash;

        require(
            triggersHash != bytes32(0) &&
                triggersHash == getTriggersHash(cdpId, triggerData, commandAddress),
            "bot/invalid-trigger"
        );
    }

    function checkTriggersExistenceAndCorrectness(uint256 cdpId, uint256 triggerId) private view {

        require(activeTriggers[triggerId].cdpId == cdpId, "bot/invalid-trigger");
    }

    function addRecord(
        uint256 cdpId,
        uint256 triggerType,
        uint256 replacedTriggerId,
        bytes memory triggerData
    ) external {

        ManagerLike manager = ManagerLike(serviceRegistry.getRegisteredService(CDP_MANAGER_KEY));
        address commandAddress = getCommandAddress(triggerType);

        require(
            ICommand(commandAddress).isTriggerDataValid(cdpId, triggerData),
            "bot/invalid-trigger-data"
        );

        require(isCdpAllowed(cdpId, msg.sender, manager), "bot/no-permissions");

        triggersCounter = triggersCounter + 1;
        activeTriggers[triggersCounter] = TriggerRecord(
            getTriggersHash(cdpId, triggerData, commandAddress),
            cdpId
        );

        if (replacedTriggerId != 0) {
            require(
                activeTriggers[replacedTriggerId].cdpId == cdpId,
                "bot/trigger-removal-illegal"
            );
            activeTriggers[replacedTriggerId] = TriggerRecord(0, 0);
            emit TriggerRemoved(cdpId, replacedTriggerId);
        }
        emit TriggerAdded(triggersCounter, commandAddress, cdpId, triggerData);
    }

    function removeRecord(
        uint256 cdpId,
        uint256 triggerId
    ) external {

        address managerAddress = serviceRegistry.getRegisteredService(CDP_MANAGER_KEY);

        require(isCdpAllowed(cdpId, msg.sender, ManagerLike(managerAddress)), "bot/no-permissions");

        checkTriggersExistenceAndCorrectness(cdpId, triggerId);

        activeTriggers[triggerId] = TriggerRecord(0, 0);
        emit TriggerRemoved(cdpId, triggerId);
    }

    function addTrigger(
        uint256 cdpId,
        uint256 triggerType,
        uint256 replacedTriggerId,
        bytes memory triggerData
    ) external onlyDelegate {

        ManagerLike manager = ManagerLike(serviceRegistry.getRegisteredService(CDP_MANAGER_KEY));

        address automationBot = serviceRegistry.getRegisteredService(AUTOMATION_BOT_KEY);
        BotLike(automationBot).addRecord(cdpId, triggerType, replacedTriggerId, triggerData);
        if (!isCdpAllowed(cdpId, automationBot, manager)) {
            manager.cdpAllow(cdpId, automationBot, 1);
            emit ApprovalGranted(cdpId, automationBot);
        }
    }


    function removeTrigger(
        uint256 cdpId,
        uint256 triggerId,
        bool removeAllowance
    ) external onlyDelegate {

        address managerAddress = serviceRegistry.getRegisteredService(CDP_MANAGER_KEY);
        ManagerLike manager = ManagerLike(managerAddress);

        address automationBot = serviceRegistry.getRegisteredService(AUTOMATION_BOT_KEY);

        BotLike(automationBot).removeRecord(cdpId, triggerId);

        if (removeAllowance) {
            manager.cdpAllow(cdpId, automationBot, 0);
            emit ApprovalRemoved(cdpId, automationBot);
        }

        emit TriggerRemoved(cdpId, triggerId);
    }

    function removeApproval(ServiceRegistry _serviceRegistry, uint256 cdpId) external onlyDelegate {

        address approvedEntity = changeApprovalStatus(_serviceRegistry, cdpId, 0);
        emit ApprovalRemoved(cdpId, approvedEntity);
    }

    function grantApproval(ServiceRegistry _serviceRegistry, uint256 cdpId) external onlyDelegate {

        address approvedEntity = changeApprovalStatus(_serviceRegistry, cdpId, 1);
        emit ApprovalGranted(cdpId, approvedEntity);
    }

    function changeApprovalStatus(
        ServiceRegistry _serviceRegistry,
        uint256 cdpId,
        uint256 status
    ) private returns (address) {

        address managerAddress = _serviceRegistry.getRegisteredService(CDP_MANAGER_KEY);
        ManagerLike manager = ManagerLike(managerAddress);
        address automationBot = _serviceRegistry.getRegisteredService(AUTOMATION_BOT_KEY);
        require(
            isCdpAllowed(cdpId, automationBot, manager) != (status == 1),
            "bot/approval-unchanged"
        );
        validatePermissions(cdpId, address(this), manager);
        manager.cdpAllow(cdpId, automationBot, status);
        return automationBot;
    }

    function drawDaiFromVault(
        uint256 cdpId,
        ManagerLike manager,
        uint256 daiCoverage
    ) internal {

        address utilsAddress = serviceRegistry.getRegisteredService(MCD_UTILS_KEY);

        McdUtils utils = McdUtils(utilsAddress);
        manager.cdpAllow(cdpId, utilsAddress, 1);
        utils.drawDebt(daiCoverage, cdpId, manager, msg.sender);
        manager.cdpAllow(cdpId, utilsAddress, 0);
    }

    function execute(
        bytes calldata executionData,
        uint256 cdpId,
        bytes calldata triggerData,
        address commandAddress,
        uint256 triggerId,
        uint256 daiCoverage
    ) external auth(msg.sender) {

        checkTriggersExistenceAndCorrectness(cdpId, triggerId, commandAddress, triggerData);
        ManagerLike manager = ManagerLike(serviceRegistry.getRegisteredService(CDP_MANAGER_KEY));
        drawDaiFromVault(cdpId, manager, daiCoverage);

        ICommand command = ICommand(commandAddress);
        require(command.isExecutionLegal(cdpId, triggerData), "bot/trigger-execution-illegal");

        manager.cdpAllow(cdpId, commandAddress, 1);
        command.execute(executionData, cdpId, triggerData);
        activeTriggers[triggerId] = TriggerRecord(0, 0);
        manager.cdpAllow(cdpId, commandAddress, 0);

        require(command.isExecutionCorrect(cdpId, triggerData), "bot/trigger-execution-wrong");

        emit TriggerExecuted(triggerId, cdpId, executionData);
    }

    event ApprovalRemoved(uint256 indexed cdpId, address approvedEntity);

    event ApprovalGranted(uint256 indexed cdpId, address approvedEntity);

    event TriggerRemoved(uint256 indexed cdpId, uint256 indexed triggerId);

    event TriggerAdded(
        uint256 indexed triggerId,
        address indexed commandAddress,
        uint256 indexed cdpId,
        bytes triggerData
    );

    event TriggerExecuted(uint256 indexed triggerId, uint256 indexed cdpId, bytes executionData);
}



library Address {

    function isContract(address account) internal view returns (bool) {


        return account.code.length > 0;
    }

    function sendValue(address payable recipient, uint256 amount) internal {

        require(address(this).balance >= amount, "Address: insufficient balance");

        (bool success, ) = recipient.call{value: amount}("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    function functionCall(address target, bytes memory data) internal returns (bytes memory) {

        return functionCall(target, data, "Address: low-level call failed");
    }

    function functionCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {

        return functionCallWithValue(target, data, 0, errorMessage);
    }

    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value
    ) internal returns (bytes memory) {

        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value,
        string memory errorMessage
    ) internal returns (bytes memory) {

        require(address(this).balance >= value, "Address: insufficient balance for call");
        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{value: value}(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {

        return functionStaticCall(target, data, "Address: low-level static call failed");
    }

    function functionStaticCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal view returns (bytes memory) {

        require(isContract(target), "Address: static call to non-contract");

        (bool success, bytes memory returndata) = target.staticcall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {

        return functionDelegateCall(target, data, "Address: low-level delegate call failed");
    }

    function functionDelegateCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {

        require(isContract(target), "Address: delegate call to non-contract");

        (bool success, bytes memory returndata) = target.delegatecall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    function verifyCallResult(
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) internal pure returns (bytes memory) {

        if (success) {
            return returndata;
        } else {
            if (returndata.length > 0) {

                assembly {
                    let returndata_size := mload(returndata)
                    revert(add(32, returndata), returndata_size)
                }
            } else {
                revert(errorMessage);
            }
        }
    }
}




library SafeERC20 {

    using Address for address;

    function safeTransfer(
        IERC20 token,
        address to,
        uint256 value
    ) internal {

        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(
        IERC20 token,
        address from,
        address to,
        uint256 value
    ) internal {

        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    function safeApprove(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {

        require(
            (value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {

        uint256 newAllowance = token.allowance(address(this), spender) + value;
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {

        unchecked {
            uint256 oldAllowance = token.allowance(address(this), spender);
            require(oldAllowance >= value, "SafeERC20: decreased allowance below zero");
            uint256 newAllowance = oldAllowance - value;
            _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
        }
    }

    function _callOptionalReturn(IERC20 token, bytes memory data) private {


        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) {
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}

interface IWETH {

    function withdraw(uint256 wad) external;

}

interface IExchange {

    function swapTokenForDai(
        address asset,
        uint256 amount,
        uint256 receiveAtLeast,
        address callee,
        bytes calldata withData
    ) external;


    function swapDaiForToken(
        address asset,
        uint256 amount,
        uint256 receiveAtLeast,
        address callee,
        bytes calldata withData
    ) external;

}

contract AutomationExecutor {

    using SafeERC20 for IERC20;

    BotLike public immutable bot;
    IERC20 public immutable dai;
    IWETH public immutable weth;

    address public exchange;
    address public owner;

    mapping(address => bool) public callers;

    constructor(
        BotLike _bot,
        IERC20 _dai,
        IWETH _weth,
        address _exchange
    ) {
        bot = _bot;
        weth = _weth;
        dai = _dai;
        exchange = _exchange;
        owner = msg.sender;
        callers[owner] = true;
    }

    modifier onlyOwner() {

        require(msg.sender == owner, "executor/only-owner");
        _;
    }

    modifier auth(address caller) {

        require(callers[caller], "executor/not-authorized");
        _;
    }

    function transferOwnership(address newOwner) external onlyOwner {

        require(newOwner != address(0), "executor/invalid-new-owner");
        owner = newOwner;
    }

    function setExchange(address newExchange) external onlyOwner {

        require(newExchange != address(0), "executor/invalid-new-exchange");
        exchange = newExchange;
    }

    function addCaller(address caller) external onlyOwner {

        callers[caller] = true;
    }

    function removeCaller(address caller) external onlyOwner {

        require(caller != msg.sender, "executor/cannot-remove-owner");
        callers[caller] = false;
    }

    function execute(
        bytes calldata executionData,
        uint256 cdpId,
        bytes calldata triggerData,
        address commandAddress,
        uint256 triggerId,
        uint256 daiCoverage,
        uint256 minerBribe,
        int256 gasRefund
    ) external auth(msg.sender) {

        uint256 initialGasAvailable = gasleft();
        bot.execute(executionData, cdpId, triggerData, commandAddress, triggerId, daiCoverage);

        if (minerBribe > 0) {
            block.coinbase.transfer(minerBribe);
        }
        uint256 finalGasAvailable = gasleft();
        uint256 etherUsed = tx.gasprice *
            uint256(int256(initialGasAvailable - finalGasAvailable) - gasRefund);

        if (address(this).balance > etherUsed) {
            payable(msg.sender).transfer(etherUsed);
        } else {
            payable(msg.sender).transfer(address(this).balance);
        }
    }

    function swap(
        address otherAsset,
        bool toDai,
        uint256 amount,
        uint256 receiveAtLeast,
        address callee,
        bytes calldata withData
    ) external auth(msg.sender) {

        IERC20 fromToken = toDai ? IERC20(otherAsset) : dai;
        require(
            amount > 0 && amount <= fromToken.balanceOf(address(this)),
            "executor/invalid-amount"
        );

        uint256 allowance = fromToken.allowance(address(this), exchange);

        if (amount > allowance) {
            fromToken.safeIncreaseAllowance(exchange, type(uint256).max - allowance);
        }

        if (toDai) {
            IExchange(exchange).swapTokenForDai(
                otherAsset,
                amount,
                receiveAtLeast,
                callee,
                withData
            );
        } else {
            IExchange(exchange).swapDaiForToken(
                otherAsset,
                amount,
                receiveAtLeast,
                callee,
                withData
            );
        }
    }

    function withdraw(address asset, uint256 amount) external onlyOwner {

        if (asset == address(0)) {
            require(amount <= address(this).balance, "executor/invalid-amount");
            (bool sent, ) = payable(owner).call{ value: amount }("");
            require(sent, "executor/withdrawal-failed");
        } else {
            IERC20(asset).safeTransfer(owner, amount);
        }
    }

    function unwrapWETH(uint256 amount) external onlyOwner {

        weth.withdraw(amount);
    }

    receive() external payable {}
}

interface MPALike {

    struct CdpData {
        address gemJoin;
        address payable fundsReceiver;
        uint256 cdpId;
        bytes32 ilk;
        uint256 requiredDebt;
        uint256 borrowCollateral;
        uint256 withdrawCollateral;
        uint256 withdrawDai;
        uint256 depositDai;
        uint256 depositCollateral;
        bool skipFL;
        string methodName;
    }

    struct AddressRegistry {
        address jug;
        address manager;
        address multiplyProxyActions;
        address lender;
        address exchange;
    }

    struct ExchangeData {
        address fromTokenAddress;
        address toTokenAddress;
        uint256 fromTokenAmount;
        uint256 toTokenAmount;
        uint256 minToTokenAmount;
        address exchangeAddress;
        bytes _exchangeCalldata;
    }

    function closeVaultExitCollateral(
        ExchangeData calldata exchangeData,
        CdpData memory cdpData,
        AddressRegistry calldata addressRegistry
    ) external;


    function closeVaultExitDai(
        ExchangeData calldata exchangeData,
        CdpData memory cdpData,
        AddressRegistry calldata addressRegistry
    ) external;

}

interface IPipInterface {

    function read() external returns (bytes32);

}

interface SpotterLike {

    function ilks(bytes32) external view returns (IPipInterface pip, uint256 mat);


    function par() external view returns (uint256);

}

interface VatLike {

    function urns(bytes32, address) external view returns (uint256 ink, uint256 art);


    function ilks(bytes32)
        external
        view
        returns (
            uint256 art, // Total Normalised Debt      [wad]
            uint256 rate, // Accumulated Rates         [ray]
            uint256 spot, // Price with Safety Margin  [ray]
            uint256 line, // Debt Ceiling              [rad]
            uint256 dust // Urn Debt Floor             [rad]
        );


    function gem(bytes32, address) external view returns (uint256); // [wad]


    function can(address, address) external view returns (uint256);


    function dai(address) external view returns (uint256);


    function frob(
        bytes32,
        address,
        address,
        address,
        int256,
        int256
    ) external;


    function hope(address) external;


    function move(
        address,
        address,
        uint256
    ) external;


    function fork(
        bytes32,
        address,
        address,
        int256,
        int256
    ) external;

}

interface OsmMomLike {

    function osms(bytes32) external view returns (address);

}

interface OsmLike {

    function peep() external view returns (bytes32, bool);


    function bud(address) external view returns (uint256);


    function kiss(address a) external;

}

contract McdView is DSMath {

    ManagerLike public manager;
    VatLike public vat;
    SpotterLike public spotter;
    OsmMomLike public osmMom;
    address public owner;
    mapping(address => bool) public whitelisted;

    constructor(
        address _vat,
        address _manager,
        address _spotter,
        address _mom,
        address _owner
    ) {
        manager = ManagerLike(_manager);
        vat = VatLike(_vat);
        spotter = SpotterLike(_spotter);
        osmMom = OsmMomLike(_mom);
        owner = _owner;
    }

    function approve(address _allowedReader, bool isApproved) external {

        require(msg.sender == owner, "mcd-view/not-authorised");
        whitelisted[_allowedReader] = isApproved;
    }

    function getVaultInfo(uint256 vaultId) public view returns (uint256, uint256) {

        address urn = manager.urns(vaultId);
        bytes32 ilk = manager.ilks(vaultId);

        (uint256 collateral, uint256 debt) = vat.urns(ilk, urn);
        (, uint256 rate, , , ) = vat.ilks(ilk);

        return (collateral, rmul(debt, rate));
    }

    function getPrice(bytes32 ilk) public view returns (uint256) {

        (, uint256 mat) = spotter.ilks(ilk);
        (, , uint256 spot, , ) = vat.ilks(ilk);

        return div(rmul(rmul(spot, spotter.par()), mat), 10**9);
    }

    function getNextPrice(bytes32 ilk) public view returns (uint256) {

        require(whitelisted[msg.sender], "mcd-view/not-whitelisted");
        OsmLike osm = OsmLike(osmMom.osms(ilk));
        (bytes32 val, bool status) = osm.peep();
        require(status, "mcd-view/osm-price-error");
        return uint256(val);
    }

    function getRatio(uint256 vaultId, bool useNextPrice) public view returns (uint256) {

        bytes32 ilk = manager.ilks(vaultId);
        uint256 price = useNextPrice ? getNextPrice(ilk) : getPrice(ilk);
        (uint256 collateral, uint256 debt) = getVaultInfo(vaultId);
        if (debt == 0) return 0;
        return wdiv(wmul(collateral, price), debt);
    }
}

contract CloseCommand is ICommand {

    address public immutable serviceRegistry;
    string private constant CDP_MANAGER_KEY = "CDP_MANAGER";
    string private constant MCD_VIEW_KEY = "MCD_VIEW";
    string private constant MPA_KEY = "MULTIPLY_PROXY_ACTIONS";

    constructor(address _serviceRegistry) {
        serviceRegistry = _serviceRegistry;
    }

    function isExecutionCorrect(uint256 cdpId, bytes memory) external view override returns (bool) {

        address viewAddress = ServiceRegistry(serviceRegistry).getRegisteredService(MCD_VIEW_KEY);
        McdView viewerContract = McdView(viewAddress);
        (uint256 collateral, uint256 debt) = viewerContract.getVaultInfo(cdpId);
        return !(collateral > 0 || debt > 0);
    }

    function isExecutionLegal(uint256 _cdpId, bytes memory triggerData)
        external
        view
        override
        returns (bool)
    {

        (, , uint256 slLevel) = abi.decode(triggerData, (uint256, uint16, uint256));

        address managerAddress = ServiceRegistry(serviceRegistry).getRegisteredService(
            CDP_MANAGER_KEY
        );
        ManagerLike manager = ManagerLike(managerAddress);
        if (manager.owns(_cdpId) == address(0)) {
            return false;
        }
        address viewAddress = ServiceRegistry(serviceRegistry).getRegisteredService(MCD_VIEW_KEY);
        uint256 collRatio = McdView(viewAddress).getRatio(_cdpId, true);
        bool vaultNotEmpty = collRatio != 0; // MCD_VIEW contract returns 0 (instead of infinity) as a collateralisation ratio of empty vault
        return vaultNotEmpty && collRatio <= slLevel * 10**16;
    }

    function execute(
        bytes calldata executionData,
        uint256,
        bytes memory triggerData
    ) external override {

        (, uint16 triggerType, ) = abi.decode(triggerData, (uint256, uint16, uint256));

        address mpaAddress = ServiceRegistry(serviceRegistry).getRegisteredService(MPA_KEY);

        bytes4 prefix = abi.decode(executionData, (bytes4));
        bytes4 expectedSelector;

        if (triggerType == 1) {
            expectedSelector = MPALike.closeVaultExitCollateral.selector;
        } else if (triggerType == 2) {
            expectedSelector = MPALike.closeVaultExitDai.selector;
        } else revert("unsupported-triggerType");

        require(prefix == expectedSelector, "wrong-payload");
        (bool status, ) = mpaAddress.delegatecall(executionData);

        require(status, "execution failed");
    }

    function isTriggerDataValid(uint256 _cdpId, bytes memory triggerData)
        external
        pure
        override
        returns (bool)
    {

        (uint256 cdpId, uint16 triggerType, uint256 slLevel) = abi.decode(
            triggerData,
            (uint256, uint16, uint256)
        );
        return slLevel > 100 && _cdpId == cdpId && (triggerType == 1 || triggerType == 2);
    }
}

contract DummyCommand is ICommand {

    address public serviceRegistry;
    bool public initialCheckReturn;
    bool public finalCheckReturn;
    bool public revertsInExecute;
    bool public validTriggerData;

    constructor(
        address _serviceRegistry,
        bool _initialCheckReturn,
        bool _finalCheckReturn,
        bool _revertsInExecute,
        bool _validTriggerData
    ) {
        serviceRegistry = _serviceRegistry;
        initialCheckReturn = _initialCheckReturn;
        finalCheckReturn = _finalCheckReturn;
        revertsInExecute = _revertsInExecute;
        validTriggerData = _validTriggerData;
    }

    function changeValidTriggerDataFlag(bool _validTriggerData) external {

        validTriggerData = _validTriggerData;
    }

    function changeFlags(
        bool _initialCheckReturn,
        bool _finalCheckReturn,
        bool _revertsInExecute
    ) external {

        initialCheckReturn = _initialCheckReturn;
        finalCheckReturn = _finalCheckReturn;
        revertsInExecute = _revertsInExecute;
    }

    function isTriggerDataValid(uint256, bytes memory) external view override returns (bool) {

        return validTriggerData;
    }

    function isExecutionCorrect(
        uint256, // cdpId
        bytes memory // triggerData
    ) external view override returns (bool) {

        return finalCheckReturn;
    }

    function isExecutionLegal(
        uint256, // cdpId
        bytes memory // triggerData
    ) external view override returns (bool) {

        return initialCheckReturn;
    }

    function execute(
        bytes calldata,
        uint256,
        bytes memory
    ) external view override {

        require(!revertsInExecute, "command failed");
    }
}



interface IERC20Metadata is IERC20 {

    function name() external view returns (string memory);


    function symbol() external view returns (string memory);


    function decimals() external view returns (uint8);

}

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}



contract ERC20 is Context, IERC20, IERC20Metadata {

    mapping(address => uint256) private _balances;

    mapping(address => mapping(address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;

    constructor(string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
    }

    function name() public view virtual override returns (string memory) {

        return _name;
    }

    function symbol() public view virtual override returns (string memory) {

        return _symbol;
    }

    function decimals() public view virtual override returns (uint8) {

        return 18;
    }

    function totalSupply() public view virtual override returns (uint256) {

        return _totalSupply;
    }

    function balanceOf(address account) public view virtual override returns (uint256) {

        return _balances[account];
    }

    function transfer(address to, uint256 amount) public virtual override returns (bool) {

        address owner = _msgSender();
        _transfer(owner, to, amount);
        return true;
    }

    function allowance(address owner, address spender) public view virtual override returns (uint256) {

        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public virtual override returns (bool) {

        address owner = _msgSender();
        _approve(owner, spender, amount);
        return true;
    }

    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) public virtual override returns (bool) {

        address spender = _msgSender();
        _spendAllowance(from, spender, amount);
        _transfer(from, to, amount);
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {

        address owner = _msgSender();
        _approve(owner, spender, _allowances[owner][spender] + addedValue);
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {

        address owner = _msgSender();
        uint256 currentAllowance = _allowances[owner][spender];
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
        unchecked {
            _approve(owner, spender, currentAllowance - subtractedValue);
        }

        return true;
    }

    function _transfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {

        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(from, to, amount);

        uint256 fromBalance = _balances[from];
        require(fromBalance >= amount, "ERC20: transfer amount exceeds balance");
        unchecked {
            _balances[from] = fromBalance - amount;
        }
        _balances[to] += amount;

        emit Transfer(from, to, amount);

        _afterTokenTransfer(from, to, amount);
    }

    function _mint(address account, uint256 amount) internal virtual {

        require(account != address(0), "ERC20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply += amount;
        _balances[account] += amount;
        emit Transfer(address(0), account, amount);

        _afterTokenTransfer(address(0), account, amount);
    }

    function _burn(address account, uint256 amount) internal virtual {

        require(account != address(0), "ERC20: burn from the zero address");

        _beforeTokenTransfer(account, address(0), amount);

        uint256 accountBalance = _balances[account];
        require(accountBalance >= amount, "ERC20: burn amount exceeds balance");
        unchecked {
            _balances[account] = accountBalance - amount;
        }
        _totalSupply -= amount;

        emit Transfer(account, address(0), amount);

        _afterTokenTransfer(account, address(0), amount);
    }

    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {

        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _spendAllowance(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {

        uint256 currentAllowance = allowance(owner, spender);
        if (currentAllowance != type(uint256).max) {
            require(currentAllowance >= amount, "ERC20: insufficient allowance");
            unchecked {
                _approve(owner, spender, currentAllowance - amount);
            }
        }
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}


    function _afterTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}

}

contract TestERC20 is ERC20 {
    constructor(
        string memory name_,
        string memory symbol_,
        uint256 amount_
    ) ERC20(name_, symbol_) {
        _mint(msg.sender, amount_);
    }
}

contract TestExchange is IExchange {
    using SafeERC20 for IERC20;

    IERC20 public immutable DAI;

    constructor(IERC20 _dai) {
        DAI = _dai;
    }

    function swapTokenForDai(
        address asset,
        uint256 amount,
        uint256 receiveAtLeast,
        address,
        bytes calldata
    ) external override {
        require(
            IERC20(asset).transferFrom(msg.sender, address(this), amount),
            "exchange/asset-from-failed"
        );
        require(DAI.transfer(msg.sender, receiveAtLeast), "exchange/dai-to-failed");
    }

    function swapDaiForToken(
        address asset,
        uint256 amount,
        uint256 receiveAtLeast,
        address,
        bytes calldata
    ) external override {
        require(DAI.transferFrom(msg.sender, address(this), amount), "exchange/dai-from-failed");
        require(IERC20(asset).transfer(msg.sender, receiveAtLeast), "exchange/asset-to-failed");
    }
}


interface DsProxyLike {
    function owner() external view returns (address);

    function setOwner(address owner_) external;

    function execute(address target, bytes memory data) external payable returns (bytes32 response);
}

contract TestWETH {
    string public name = "Wrapped Ether";
    string public symbol = "WETH";
    uint8 public decimals = 18;

    event Approval(address indexed src, address indexed guy, uint256 wad);
    event Transfer(address indexed src, address indexed dst, uint256 wad);
    event Deposit(address indexed dst, uint256 wad);
    event Withdrawal(address indexed src, uint256 wad);

    mapping(address => uint256) public balanceOf;
    mapping(address => mapping(address => uint256)) public allowance;

    receive() external payable {
        deposit();
    }

    function deposit() public payable {
        balanceOf[msg.sender] += msg.value;
        emit Deposit(msg.sender, msg.value);
    }

    function withdraw(uint256 wad) public {
        require(balanceOf[msg.sender] >= wad);
        balanceOf[msg.sender] -= wad;
        payable(msg.sender).transfer(wad);
        emit Withdrawal(msg.sender, wad);
    }

    function totalSupply() public view returns (uint256) {
        return address(this).balance;
    }

    function approve(address guy, uint256 wad) public returns (bool) {
        allowance[msg.sender][guy] = wad;
        emit Approval(msg.sender, guy, wad);
        return true;
    }

    function transfer(address dst, uint256 wad) public returns (bool) {
        return transferFrom(msg.sender, dst, wad);
    }

    function transferFrom(
        address src,
        address dst,
        uint256 wad
    ) public returns (bool) {
        require(balanceOf[src] >= wad);

        if (src != msg.sender && allowance[src][msg.sender] != type(uint256).max) {
            require(allowance[src][msg.sender] >= wad);
            allowance[src][msg.sender] -= wad;
        }

        balanceOf[src] -= wad;
        balanceOf[dst] += wad;

        emit Transfer(src, dst, wad);

        return true;
    }
}