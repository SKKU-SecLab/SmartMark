
pragma solidity =0.8.9;


interface ITimeLock {

    function delay() external view returns (uint);


    function queuedTransactions(bytes32 hash) external view returns (bool);


    function queueTransaction(
        address target,
        uint value,
        string calldata signature,
        bytes calldata data,
        uint eta
    ) external returns (bytes32);


    function cancelTransaction(
        address target,
        uint value,
        string calldata signature,
        bytes calldata data,
        uint eta
    ) external;


    function executeTransaction(
        address target,
        uint value,
        string calldata signature,
        bytes calldata data,
        uint eta
    ) external payable returns (bytes memory);

}



contract TimeLock is ITimeLock {

    event NewAdmin(address indexed newAdmin);
    event NewPendingAdmin(address indexed newPendingAdmin);
    event NewDelay(uint newDelay);
    event QueueTransaction(
        bytes32 indexed txHash,
        address indexed target,
        uint value,
        string signature,
        bytes data,
        uint eta
    );
    event ExecuteTransaction(
        bytes32 indexed txHash,
        address indexed target,
        uint value,
        string signature,
        bytes data,
        uint eta
    );
    event CancelTransaction(
        bytes32 indexed txHash,
        address indexed target,
        uint value,
        string signature,
        bytes data,
        uint eta
    );

    uint private constant MIN_DELAY = 2 days;
    uint private constant MAX_DELAY = 30 days;
    uint private constant GRACE_PERIOD = 14 days;

    address public admin;
    address public pendingAdmin;

    uint public delay;
    mapping(bytes32 => bool) public queuedTransactions;

    constructor(uint _delay) {
        require(_delay >= MIN_DELAY, "delay < min");
        require(_delay <= MAX_DELAY, "delay > max");
        admin = msg.sender;
        delay = _delay;
    }

    receive() external payable {}

    modifier onlyTimeLock() {

        require(msg.sender == address(this), "not time lock");
        _;
    }

    modifier onlyAdmin() {

        require(msg.sender == admin, "not admin");
        _;
    }

    function setPendingAdmin(address _pendingAdmin) external onlyAdmin {

        pendingAdmin = _pendingAdmin;
        emit NewPendingAdmin(_pendingAdmin);
    }

    function acceptAdmin() external {

        require(msg.sender == pendingAdmin, "not pending admin");
        admin = msg.sender;
        pendingAdmin = address(0);
        emit NewAdmin(admin);
    }

    function setDelay(uint _delay) external onlyTimeLock {

        require(_delay >= MIN_DELAY, "delay < min");
        require(_delay <= MAX_DELAY, "delay > max");
        delay = _delay;
        emit NewDelay(_delay);
    }

    function _getTxHash(
        address target,
        uint value,
        string calldata signature,
        bytes calldata data,
        uint eta
    ) private pure returns (bytes32) {

        return keccak256(abi.encode(target, value, signature, data, eta));
    }

    function getTxHash(
        address target,
        uint value,
        string calldata signature,
        bytes calldata data,
        uint eta
    ) external pure returns (bytes32) {

        return _getTxHash(target, value, signature, data, eta);
    }

    function queueTransaction(
        address target,
        uint value,
        string calldata signature,
        bytes calldata data,
        uint eta
    ) external onlyAdmin returns (bytes32 txHash) {

        require(eta >= block.timestamp + delay, "eta < now + delay");

        txHash = _getTxHash(target, value, signature, data, eta);
        require(!queuedTransactions[txHash], "queued");
        queuedTransactions[txHash] = true;

        emit QueueTransaction(txHash, target, value, signature, data, eta);
    }

    function cancelTransaction(
        address target,
        uint value,
        string calldata signature,
        bytes calldata data,
        uint eta
    ) external onlyAdmin {

        bytes32 txHash = _getTxHash(target, value, signature, data, eta);
        require(queuedTransactions[txHash], "not queued");
        queuedTransactions[txHash] = false;
        emit CancelTransaction(txHash, target, value, signature, data, eta);
    }

    function executeTransaction(
        address target,
        uint value,
        string calldata signature,
        bytes calldata data,
        uint eta
    ) external payable onlyAdmin returns (bytes memory) {

        bytes32 txHash = _getTxHash(target, value, signature, data, eta);

        require(queuedTransactions[txHash], "not queued");
        require(block.timestamp >= eta, "timestamp < eta");
        require(
            block.timestamp <= eta + GRACE_PERIOD,
            "timestamp > grace period"
        );

        queuedTransactions[txHash] = false;

        bytes memory callData;

        if (bytes(signature).length == 0) {
            callData = data;
        } else {
            callData = abi.encodePacked(
                bytes4(keccak256(bytes(signature))),
                data
            );
        }

        (bool success, bytes memory returnData) = target.call{value: value}(
            callData
        );
        require(success, "tx reverted");

        emit ExecuteTransaction(txHash, target, value, signature, data, eta);

        return returnData;
    }
}