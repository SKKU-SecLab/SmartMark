
pragma solidity ^0.5.16;

library SafeMath {

    function add(uint256 a, uint256 b) internal pure returns (uint256) {

        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b <= a, "SafeMath: subtraction overflow");
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

        require(b > 0, "SafeMath: division by zero");
        uint256 c = a / b;

        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b != 0, "SafeMath: modulo by zero");
        return a % b;
    }
}

contract NamedContract {

    string public name;

    function setContractName(string memory newName) internal {

        name = newName;
    }
}

contract GovernanceTimelockStorage {

    bool internal _initialized;

    uint256 public constant _gracePeriod = 14 days;
    uint256 public constant _minimumDelay = 1 hours;
    uint256 public constant _maximumDelay = 30 days;

    address public _guardian;
    address public _authorizedNewGuardian;
    uint256 public _delay;

    mapping (bytes32 => bool) public _queuedTransactions;
}

contract GovernanceTimelockEvent {

    event Initialize(
        address indexed guardian,
        uint256 indexed delay
    );

    event GuardianshipTransferAuthorization(
        address indexed authorizedAddress
    );

    event GuardianUpdate(
        address indexed oldValue,
        address indexed newValue
    );

    event DelayUpdate(
        uint256 indexed oldValue,
        uint256 indexed newValue
    );

    event TransactionQueue(
        bytes32 indexed txHash,
        address indexed target,
        uint256 value,
        string signature,
        bytes data,
        uint256 eta
    );

    event TransactionCancel(
        bytes32 indexed txHash,
        address indexed target,
        uint256 value,
        string signature,
        bytes data,
        uint256 eta
    );

    event TransactionExecution(
        bytes32 indexed txHash,
        address indexed target,
        uint256 value,
        string signature,
        bytes data,
        uint256 eta
    );
}
contract GovernanceTimelock is NamedContract, GovernanceTimelockStorage, GovernanceTimelockEvent {

    using SafeMath for uint256;

    constructor() public {
        setContractName('Swipe Governance Timelock');
    }

    function initialize(
        address guardian,
        uint256 delay
    ) external {

        require(
            !_initialized,
            "Contract has been already initialized"
        );
        require(
            _minimumDelay <= delay && delay <= _maximumDelay,
            "Invalid delay"
        );

        _guardian = guardian;
        _delay = delay;

        _initialized = true;

        emit Initialize(
            _guardian,
            _delay
        );
    }

    function() external payable { }

    function setDelay(uint256 delay) external {

        require(
            msg.sender == _guardian,
            "Only the guardian can set the delay"
        );

        require(
            _minimumDelay <= delay && delay <= _maximumDelay,
            "Invalid delay"
        );

        uint256 oldValue = _delay;
        _delay = delay;

        emit DelayUpdate(
            oldValue,
            _delay
        );
    }

    function authorizeGuardianshipTransfer(address authorizedAddress) external {

        require(
            msg.sender == _guardian,
            "Only the guardian can authorize a new address to become guardian"
        );

        _authorizedNewGuardian = authorizedAddress;

        emit GuardianshipTransferAuthorization(_authorizedNewGuardian);
    }

    function assumeGuardianship() external {

        require(
            msg.sender == _authorizedNewGuardian,
            "Only the authorized new guardian can accept guardianship"
        );

        address oldValue = _guardian;
        _guardian = _authorizedNewGuardian;
        _authorizedNewGuardian = address(0);

        emit GuardianUpdate(
            oldValue,
            _guardian
        );
    }

    function queueTransaction(
        address target,
        uint256 value,
        string calldata signature,
        bytes calldata data,
        uint256 eta
    ) external returns (bytes32) {

        require(
            msg.sender == _guardian,
            "Only the guardian can queue transaction"
        );

        require(
            eta >= getBlockTimestamp().add(_delay),
            "Estimated execution block must satisfy delay"
        );

        bytes32 txHash = keccak256(abi.encode(target, value, signature, data, eta));
        _queuedTransactions[txHash] = true;

        emit TransactionQueue(
            txHash,
            target,
            value,
            signature,
            data,
            eta
        );

        return txHash;
    }

    function cancelTransaction(
        address target,
        uint256 value,
        string calldata signature,
        bytes calldata data,
        uint256 eta
    ) external {

        require(
            msg.sender == _guardian,
            "Only the guardian can cancel transaction"
        );

        bytes32 txHash = keccak256(abi.encode(target, value, signature, data, eta));
        _queuedTransactions[txHash] = false;

        emit TransactionCancel(
            txHash,
            target,
            value,
            signature,
            data,
            eta
        );
    }

    function executeTransaction(
        address target,
        uint256 value,
        string calldata signature,
        bytes calldata data,
        uint256 eta
    ) external payable returns (bytes memory) {

        require(
            msg.sender == _guardian,
            "Only the guardian can execute transaction"
        );

        bytes32 txHash = keccak256(abi.encode(target, value, signature, data, eta));
        
        require(
            _queuedTransactions[txHash],
            "The transaction hasn't been queued"
        );
        
        require(
            getBlockTimestamp() >= eta,
            "The transaction hasn't surpassed time lock"
        );

        require(
            getBlockTimestamp() <= eta.add(_gracePeriod),
            "The transaction is stale"
        );

        _queuedTransactions[txHash] = false;

        bytes memory callData;

        if (bytes(signature).length == 0) {
            callData = data;
        } else {
            callData = abi.encodePacked(bytes4(keccak256(bytes(signature))), data);
        }

        (bool success, bytes memory returnData) = target.call.value(value)(callData);
        
        require(
            success,
            "The transaction execution reverted"
        );

        emit TransactionExecution(
            txHash,
            target,
            value,
            signature,
            data,
            eta
        );

        return returnData;
    }

    function getBlockTimestamp() internal view returns (uint256) {

        return block.timestamp;
    }
}