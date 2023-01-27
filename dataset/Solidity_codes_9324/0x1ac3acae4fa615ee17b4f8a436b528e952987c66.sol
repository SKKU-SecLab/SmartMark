
pragma solidity ^0.8.0;

library Strings {

    function toString(uint256 value) internal pure returns (string memory) {


        if (value == 0) {
            return "0";
        }
        uint256 temp = value;
        uint256 digits;
        while (temp != 0) {
            digits++;
            temp /= 10;
        }
        bytes memory buffer = new bytes(digits);
        uint256 index = digits - 1;
        temp = value;
        while (temp != 0) {
            buffer[index--] = bytes1(uint8(48 + (temp % 10)));
            temp /= 10;
        }
        return string(buffer);
    }
}

contract TimeLockMultiSigWallet {

    using Strings for uint256;

    event Confirmation(address indexed sender, uint256 indexed transactionId);
    event Revocation(address indexed sender, uint256 indexed transactionId);
    event Submission(uint256 indexed transactionId);
    event Execution(uint256 indexed transactionId);
    event ExecutionFailure(uint256 indexed transactionId);
    event Deposit(address indexed sender, uint256 value);
    event OwnerAddition(address indexed owner);
    event OwnerRemoval(address indexed owner);
    event RequirementChange(uint256 required);
    event NewDelay(uint256 delay);

    uint256 public constant VERSION = 20210812;
    uint256 public constant MINIMUM_DELAY = 1;
    uint256 public constant MAXIMUM_DELAY = 15 days;
    uint256 public delay; // delay time

    uint256 public constant MAX_OWNER_COUNT = 50;

    mapping(uint256 => Transaction) public transactions;
    mapping(uint256 => mapping(address => bool)) public confirmations;
    mapping(address => bool) public isOwner;
    address[] public owners;
    uint256 public required;
    uint256 public transactionCount;

    struct Transaction {
        address destination;
        uint256 value;
        bytes data;
        bool executed;
        uint256 submitTime;
    }

    modifier onlyWallet() {

        require(msg.sender == address(this), "msg.sender != address(this)");
        _;
    }

    modifier ownerDoesNotExist(address owner) {

        require(!isOwner[owner], "is already owner");
        _;
    }

    modifier ownerExists(address owner) {

        require(isOwner[owner], "is not owner");
        _;
    }

    modifier transactionExists(uint256 transactionId) {

        require(
            transactions[transactionId].destination != address(0),
            "transactionId is not exists"
        );
        _;
    }

    modifier confirmed(uint256 transactionId, address owner) {

        require(confirmations[transactionId][owner], "is not confirmed");
        _;
    }

    modifier notConfirmed(uint256 transactionId, address owner) {

        require(!confirmations[transactionId][owner], "already confirmed");
        _;
    }

    modifier notExecuted(uint256 transactionId) {

        require(!transactions[transactionId].executed, "already executed");
        _;
    }

    modifier notNull(address _address) {

        require(_address != address(0), "_address == address(0)");
        _;
    }

    modifier validRequirement(uint256 ownerCount, uint256 _required) {

        require(
            ownerCount <= MAX_OWNER_COUNT &&
                _required <= ownerCount &&
                _required != 0 &&
                ownerCount != 0,
            "error: validRequirement()"
        );
        _;
    }

    fallback() external {}

    receive() external payable {
        if (msg.value > 0) emit Deposit(msg.sender, msg.value);
    }

    constructor(
        address[] memory _owners,
        uint256 _required,
        uint256 _delay
    ) validRequirement(_owners.length, _required) {
        require(_delay >= MINIMUM_DELAY, "Delay must exceed minimum delay.");
        require(
            _delay <= MAXIMUM_DELAY,
            "Delay must not exceed maximum delay."
        );

        for (uint256 i = 0; i < _owners.length; i++) {
            require(!isOwner[_owners[i]] && _owners[i] != address(0));
            isOwner[_owners[i]] = true;
        }
        owners = _owners;
        required = _required;
        delay = _delay;
    }

    function addOwner(address owner)
        public
        onlyWallet
        ownerDoesNotExist(owner)
        notNull(owner)
        validRequirement(owners.length + 1, required)
    {

        isOwner[owner] = true;
        owners.push(owner);
        emit OwnerAddition(owner);
    }

    function removeOwner(address owner) public onlyWallet ownerExists(owner) {

        isOwner[owner] = false;
        for (uint256 i = 0; i < owners.length - 1; i++)
            if (owners[i] == owner) {
                owners[i] = owners[owners.length - 1];
                break;
            }
        if (required > (owners.length - 1))
            changeRequirement(owners.length - 1);
        emit OwnerRemoval(owner);
    }

    function replaceOwner(address owner, address newOwner)
        public
        onlyWallet
        ownerExists(owner)
        ownerDoesNotExist(newOwner)
    {

        for (uint256 i = 0; i < owners.length; i++)
            if (owners[i] == owner) {
                owners[i] = newOwner;
                break;
            }
        isOwner[owner] = false;
        isOwner[newOwner] = true;
        emit OwnerRemoval(owner);
        emit OwnerAddition(newOwner);
    }

    function changeRequirement(uint256 _required)
        public
        onlyWallet
        validRequirement(owners.length, _required)
    {

        required = _required;
        emit RequirementChange(_required);
    }

    function submitTransaction(
        address destination,
        uint256 value,
        bytes memory data
    ) public returns (uint256 transactionId) {

        transactionId = addTransaction(destination, value, data);
        confirmTransaction(transactionId);
    }

    function batchConfirmTransaction(uint256[] memory transactionIdArray)
        public
    {

        for (uint256 i = 0; i < transactionIdArray.length; i++) {
            confirmTransaction(transactionIdArray[i]);
        }
    }

    function confirmTransaction(uint256 transactionId)
        public
        ownerExists(msg.sender)
        transactionExists(transactionId)
        notConfirmed(transactionId, msg.sender)
    {

        confirmations[transactionId][msg.sender] = true;
        emit Confirmation(msg.sender, transactionId);
    }

    function revokeConfirmation(uint256 transactionId)
        public
        ownerExists(msg.sender)
        confirmed(transactionId, msg.sender)
        notExecuted(transactionId)
    {

        confirmations[transactionId][msg.sender] = false;
        emit Revocation(msg.sender, transactionId);
    }

    function batchExecuteTransaction(uint256[] memory transactionIdArray)
        public
    {

        for (uint256 i = 0; i < transactionIdArray.length; i++) {
            executeTransaction(transactionIdArray[i]);
        }
    }

    function executeTransaction(uint256 transactionId)
        public
        ownerExists(msg.sender)
        confirmed(transactionId, msg.sender)
        notExecuted(transactionId)
    {

        require(
            getBlockTimestamp() >=
                transactions[transactionId].submitTime + delay,
            "The time is not up, the command cannot be executed temporarily!"
        );
        require(
            getBlockTimestamp() <=
                transactions[transactionId].submitTime + MAXIMUM_DELAY,
            "The maximum execution time has been exceeded, unable to execute!"
        );

        if (isConfirmed(transactionId)) {
            Transaction storage txn = transactions[transactionId];
            txn.executed = true;
            (bool success, ) = txn.destination.call{value: txn.value}(txn.data);
            if (success) emit Execution(transactionId);
            else {
                revert(
                    string(
                        abi.encodePacked(
                            "The transactionId ",
                            transactionId.toString(),
                            " failed."
                        )
                    )
                );
            }
        }
    }

    function isConfirmed(uint256 transactionId) public view returns (bool) {

        uint256 count = 0;
        for (uint256 i = 0; i < owners.length; i++) {
            if (confirmations[transactionId][owners[i]]) count += 1;
            if (count == required) return true;
        }
        return false;
    }

    function addTransaction(
        address destination,
        uint256 value,
        bytes memory data
    ) internal notNull(destination) returns (uint256 transactionId) {

        transactionId = transactionCount;
        transactions[transactionId] = Transaction({
            destination: destination,
            value: value,
            data: data,
            executed: false,
            submitTime: block.timestamp
        });
        transactionCount += 1;
        emit Submission(transactionId);
    }

    function getConfirmationCount(uint256 transactionId)
        public
        view
        returns (uint256 count)
    {

        count = 0;
        for (uint256 i = 0; i < owners.length; i++)
            if (confirmations[transactionId][owners[i]]) count += 1;
    }

    function getTransactionCount(bool pending, bool executed)
        public
        view
        returns (uint256 count)
    {

        count = 0;
        for (uint256 i = 0; i < transactionCount; i++)
            if (
                (pending && !transactions[i].executed) ||
                (executed && transactions[i].executed)
            ) count += 1;
    }

    function getOwners() public view returns (address[] memory) {

        return owners;
    }

    function getConfirmations(uint256 transactionId)
        public
        view
        returns (address[] memory _confirmations)
    {

        address[] memory confirmationsTemp = new address[](owners.length);
        uint256 count = 0;
        uint256 i;
        for (i = 0; i < owners.length; i++)
            if (confirmations[transactionId][owners[i]]) {
                confirmationsTemp[count] = owners[i];
                count += 1;
            }
        _confirmations = new address[](count);
        for (i = 0; i < count; i++) _confirmations[i] = confirmationsTemp[i];
    }

    function getTransactionIds(
        uint256 from,
        uint256 to,
        bool pending,
        bool executed
    ) public view returns (uint256[] memory _transactionIds) {

        uint256[] memory transactionIdsTemp = new uint256[](transactionCount);
        uint256 count = 0;
        uint256 i;
        for (i = 0; i < transactionCount; i++)
            if (
                (pending && !transactions[i].executed) ||
                (executed && transactions[i].executed)
            ) {
                transactionIdsTemp[count] = i;
                count += 1;
            }
        _transactionIds = new uint256[](to - from);
        for (i = from; i < to; i++)
            _transactionIds[i - from] = transactionIdsTemp[i];
    }

    function getBlockTimestamp() internal view returns (uint256) {

        return block.timestamp;
    }

    function setDelay(uint256 _delay) public onlyWallet {

        require(_delay >= MINIMUM_DELAY, "Delay must exceed minimum delay.");
        require(
            _delay <= MAXIMUM_DELAY,
            "Delay must not exceed maximum delay."
        );

        delay = _delay;

        emit NewDelay(delay);
    }

    function onERC721Received(
        address operator,
        address from,
        uint256 tokenId,
        bytes calldata data
    ) external returns (bytes4) {

        bytes4 received = 0x150b7a02;
        return received;
    }
}