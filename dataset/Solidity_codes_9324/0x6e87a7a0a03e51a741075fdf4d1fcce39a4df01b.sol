pragma solidity ^0.8.0;

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

}//Unlicense
pragma solidity ^0.8.0;

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

}//Unlicense
pragma solidity ^0.8.0;

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

}//Unlicense
pragma solidity ^0.8.0;

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