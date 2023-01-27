pragma solidity 0.6.12;

contract MultiSigLibEIP712 {


    string public constant EIP712_DOMAIN_NAME = "MultiSig";
    string public constant EIP712_DOMAIN_VERSION = "v1";

    bytes32 public EIP712_DOMAIN_SEPARATOR;

    bytes32 public constant SUBMIT_TRANSACTION_TYPE_HASH = 0x2c78e27c3bb2592e67e8d37ad1a95bfccd188e77557c22593b1af0b920a08295;

    bytes32 public constant CONFIRM_TRANSACTION_TYPE_HASH = 0x3e96bdc38d4133bc81813a187b2d41bc74332643ce7dbe82c7d94ead8366a65f;

    constructor() public {
        EIP712_DOMAIN_SEPARATOR = keccak256(
            abi.encode(
                keccak256('EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)'),
                keccak256(bytes(EIP712_DOMAIN_NAME)),
                keccak256(bytes(EIP712_DOMAIN_VERSION)),
                getChainID(),
                address(this)
            )
        );
    }

    function getChainID() internal pure returns (uint) {

        uint chainId;
        assembly {
            chainId := chainid()
        }
        return chainId;
    }
}/**
 *Submitted for verification at Etherscan.io on 2019-05-13
*/


pragma solidity 0.6.12;
pragma experimental ABIEncoderV2;

library LibBytes {


    function readBytes32(
        bytes memory b,
        uint256 index
    )
        internal
        pure
        returns (bytes32 result)
    {

        require(
        b.length >= index + 32,
        "LibBytes#readBytes32 greater or equal to 32 length required"
        );

        index += 32;

        assembly {
        result := mload(add(b, index))
        }
        return result;
    }
}



contract MultiSig is MultiSigLibEIP712 {

    using LibBytes for bytes;


    event Deposit(address indexed depositer, uint256 amount);
    event Confirmation(address indexed sender, uint256 indexed transactionId);
    event Revocation(address indexed sender, uint256 indexed transactionId);
    event Submission(uint256 indexed transactionId);
    event Execution(uint256 indexed transactionId);
    event ExecutionFailure(uint256 indexed transactionId);
    event OwnerAddition(address indexed owner);
    event OwnerRemoval(address indexed owner);
    event RequirementChange(uint256 required);


    uint256 constant public MAX_OWNER_COUNT = 50;
    address constant ADDRESS_ZERO = address(0x0);


    mapping (uint256 => Transaction) public transactions;
    mapping (uint256 => mapping (address => bool)) public confirmations;
    mapping (address => bool) public isOwner;
    address[] public owners;
    uint256 public required;
    uint256 public transactionCount;


    struct Transaction {
        address destination;
        uint256 value;
        bytes data;
        bool executed;
    }


    modifier onlyWallet() {

        require(msg.sender == address(this));
        _;
    }

    modifier ownerDoesNotExist(
        address owner
    ) {

        require(!isOwner[owner]);
        _;
    }

    modifier ownerExists(
        address owner
    ) {

        require(isOwner[owner]);
        _;
    }

    modifier transactionExists(
        uint256 transactionId
    ) {

        require(transactions[transactionId].destination != ADDRESS_ZERO);
        _;
    }

    modifier confirmed(
        uint256 transactionId,
        address owner
    ) {

        require(confirmations[transactionId][owner]);
        _;
    }

    modifier notConfirmed(
        uint256 transactionId,
        address owner
    ) {

        require(!confirmations[transactionId][owner]);
        _;
    }

    modifier notExecuted(
        uint256 transactionId
    ) {

        require(!transactions[transactionId].executed);
        _;
    }

    modifier notNull(
        address _address
    ) {

        require(_address != ADDRESS_ZERO);
        _;
    }

    modifier validRequirement(
        uint256 ownerCount,
        uint256 _required
    ) {

        require(
            ownerCount <= MAX_OWNER_COUNT
            && _required <= ownerCount
            && _required != 0
            && ownerCount != 0
        );
        _;
    }

    receive() external payable {
        emit Deposit(msg.sender, msg.value);
    }


    constructor(
        address[] memory _owners,
        uint256 _required
    )
        public
        validRequirement(_owners.length, _required)
        MultiSigLibEIP712()
    {
        for (uint256 i = 0; i < _owners.length; i++) {
            require(!isOwner[_owners[i]] && _owners[i] != ADDRESS_ZERO);
            isOwner[_owners[i]] = true;
        }
        owners = _owners;
        required = _required;
    }


    function addOwner(
        address owner
    )
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

    function removeOwner(
        address owner
    )
        public
        onlyWallet
        ownerExists(owner)
    {

        isOwner[owner] = false;
        for (uint256 i = 0; i < owners.length - 1; i++) {
            if (owners[i] == owner) {
                owners[i] = owners[owners.length - 1];
                break;
            }
        }
        delete owners[owners.length - 1];
        if (required > owners.length) {
            changeRequirement(owners.length);
        }
        emit OwnerRemoval(owner);
    }

    function replaceOwner(
        address owner,
        address newOwner
    )
        public
        onlyWallet
        ownerExists(owner)
        ownerDoesNotExist(newOwner)
        notNull(newOwner)
    {

        for (uint256 i = 0; i < owners.length; i++) {
            if (owners[i] == owner) {
                owners[i] = newOwner;
                break;
            }
        }
        isOwner[owner] = false;
        isOwner[newOwner] = true;
        emit OwnerRemoval(owner);
        emit OwnerAddition(newOwner);
    }

    function changeRequirement(
        uint256 _required
    )
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
    )
        public
        returns (uint256)
    {

        uint256 transactionId = addTransaction(destination, value, data);
        confirmTransaction(transactionId);
        return transactionId;
    }

    function submitTransaction(
        address signer,
        uint256 transactionId,
        address destination,
        uint256 value,
        bytes memory data,
        bytes memory sig
    )
        public
        ownerExists(signer)
        returns (uint256)
    {

        bytes32 EIP712SignDigest = keccak256(
            abi.encodePacked(
                bytes1(0x19),
                bytes1(0x01),
                EIP712_DOMAIN_SEPARATOR,
                keccak256(
                    abi.encode(
                        SUBMIT_TRANSACTION_TYPE_HASH,
                        transactionId,
                        destination,
                        value,
                        data
                    )
                )
            )
        );
        validateSignature(signer, EIP712SignDigest, sig);

        uint256 _transactionId = addTransaction(destination, value, data);

        require(transactionId == _transactionId);

        confirmTransactionBySigner(signer, transactionId);
        return transactionId;
    }

    function confirmTransactionBySigner(
        address signer,
        uint256 transactionId
    )
        internal
        transactionExists(transactionId)
        notConfirmed(transactionId, signer)
    {

        confirmations[transactionId][signer] = true;
        emit Confirmation(signer, transactionId);

        executeTransactionBySigner(signer, transactionId);
    }

    function executeTransactionBySigner(
        address signer,
        uint256 transactionId
    )
        internal
        notExecuted(transactionId)
    {

        if (isConfirmed(transactionId)) {
            Transaction storage txn = transactions[transactionId];
            txn.executed = true;
            if (externalCall(
                txn.destination,
                txn.value,
                txn.data.length,
                txn.data)
            ) {
                emit Execution(transactionId);
            } else {
                emit ExecutionFailure(transactionId);
                txn.executed = false;
            }
        }
    }

    function confirmTransaction(
        uint256 transactionId
    )
        public
        virtual
        ownerExists(msg.sender)
        transactionExists(transactionId)
        notConfirmed(transactionId, msg.sender)
    {

        confirmations[transactionId][msg.sender] = true;
        emit Confirmation(msg.sender, transactionId);
        executeTransaction(transactionId);
    }

    function confirmTransaction(
        address signer,
        uint256 transactionId,
        bytes memory sig
    )
        public
        virtual
        ownerExists(signer)
        transactionExists(transactionId)
        notConfirmed(transactionId, signer)
    {

        bytes32 EIP712SignDigest = keccak256(
            abi.encodePacked(
                bytes1(0x19),
                bytes1(0x01),
                EIP712_DOMAIN_SEPARATOR,
                keccak256(
                    abi.encode(
                        CONFIRM_TRANSACTION_TYPE_HASH,
                        transactionId
                    )
                )
            )
        );
        validateSignature(signer, EIP712SignDigest, sig);

        confirmations[transactionId][signer] = true;
        emit Confirmation(signer, transactionId);
        executeTransactionBySigner(signer, transactionId);
    }

    function revokeConfirmation(
        uint256 transactionId
    )
        public
        ownerExists(msg.sender)
        confirmed(transactionId, msg.sender)
        notExecuted(transactionId)
    {

        confirmations[transactionId][msg.sender] = false;
        emit Revocation(msg.sender, transactionId);
    }

    function executeTransaction(
        uint256 transactionId
    )
        public
        virtual
        ownerExists(msg.sender)
        confirmed(transactionId, msg.sender)
        notExecuted(transactionId)
    {

        if (isConfirmed(transactionId)) {
            Transaction storage txn = transactions[transactionId];
            txn.executed = true;
            if (externalCall(
                txn.destination,
                txn.value,
                txn.data.length,
                txn.data)
            ) {
                emit Execution(transactionId);
            } else {
                emit ExecutionFailure(transactionId);
                txn.executed = false;
            }
        }
    }


    function isConfirmed(
        uint256 transactionId
    )
        public
        view
        returns (bool)
    {

        uint256 count = 0;
        for (uint256 i = 0; i < owners.length; i++) {
            if (confirmations[transactionId][owners[i]]) {
                count += 1;
            }
            if (count == required) {
                return true;
            }
        }
    }

    function getConfirmationCount(
        uint256 transactionId
    )
        public
        view
        returns (uint256)
    {

        uint256 count = 0;
        for (uint256 i = 0; i < owners.length; i++) {
            if (confirmations[transactionId][owners[i]]) {
                count += 1;
            }
        }
        return count;
    }

    function getTransactionCount(
        bool pending,
        bool executed
    )
        public
        view
        returns (uint256)
    {

        uint256 count = 0;
        for (uint256 i = 0; i < transactionCount; i++) {
            if (
                pending && !transactions[i].executed
                || executed && transactions[i].executed
            ) {
                count += 1;
            }
        }
        return count;
    }

    function getOwners()
        public
        view
        returns (address[] memory)
    {

        return owners;
    }

    function getConfirmations(
        uint256 transactionId
    )
        public
        view
        returns (address[] memory)
    {

        address[] memory confirmationsTemp = new address[](owners.length);
        uint256 count = 0;
        uint256 i;
        for (i = 0; i < owners.length; i++) {
            if (confirmations[transactionId][owners[i]]) {
                confirmationsTemp[count] = owners[i];
                count += 1;
            }
        }
        address[] memory _confirmations = new address[](count);
        for (i = 0; i < count; i++) {
            _confirmations[i] = confirmationsTemp[i];
        }
        return _confirmations;
    }

    function getTransactionIds(
        uint256 from,
        uint256 to,
        bool pending,
        bool executed
    )
        public
        view
        returns (uint256[] memory)
    {

        uint256[] memory transactionIdsTemp = new uint256[](transactionCount);
        uint256 count = 0;
        uint256 i;
        for (i = 0; i < transactionCount; i++) {
            if (
                pending && !transactions[i].executed
                || executed && transactions[i].executed
            ) {
                transactionIdsTemp[count] = i;
                count += 1;
            }
        }
        uint256[] memory _transactionIds = new uint256[](to - from);
        for (i = from; i < to; i++) {
            _transactionIds[i - from] = transactionIdsTemp[i];
        }
        return _transactionIds;
    }


    function validateSignature(
        address signer,
        bytes32 digest,
        bytes memory sig
    )
        internal
    {

        require(sig.length == 65);
        uint8 v = uint8(sig[64]);
        bytes32 r = sig.readBytes32(0);
        bytes32 s = sig.readBytes32(32);
        address recovered = ecrecover(digest, v, r, s);
        require(signer == recovered);
    }

    function externalCall(
        address destination,
        uint256 value,
        uint256 dataLength,
        bytes memory data
    )
        internal
        returns (bool)
    {

        bool result;
        assembly {
            let x := mload(0x40)   // "Allocate" memory for output (0x40 is where "free memory" pointer is stored by convention)
            let d := add(data, 32) // First 32 bytes are the padded length of data, so exclude that
            result := call(
                sub(gas(), 34710),   // 34710 is the value that solidity is currently emitting
                destination,
                value,
                d,
                dataLength,        // Size of the input (in bytes) - this is what fixes the padding problem
                x,
                0                  // Output is ignored, therefore the output size is zero
            )
        }
        return result;
    }

    function addTransaction(
        address destination,
        uint256 value,
        bytes memory data
    )
        internal
        notNull(destination)
        returns (uint256)
    {

        uint256 transactionId = transactionCount;
        transactions[transactionId] = Transaction({
            destination: destination,
            value: value,
            data: data,
            executed: false
        });
        transactionCount += 1;
        emit Submission(transactionId);
        return transactionId;
    }
}


contract DelayedMultiSig is
    MultiSig
{


    event ConfirmationTimeSet(uint256 indexed transactionId, uint256 confirmationTime);
    event TimeLockChange(uint32 secondsTimeLocked);


    uint32 public secondsTimeLocked;
    mapping (uint256 => uint256) public confirmationTimes;


    modifier notFullyConfirmed(
        uint256 transactionId
    ) {

        require(
            !isConfirmed(transactionId),
            "TX_FULLY_CONFIRMED"
        );
        _;
    }

    modifier fullyConfirmed(
        uint256 transactionId
    ) {

        require(
            isConfirmed(transactionId),
            "TX_NOT_FULLY_CONFIRMED"
        );
        _;
    }

    modifier pastTimeLock(
        uint256 transactionId
    ) virtual {

        require(
            block.timestamp >= confirmationTimes[transactionId] + secondsTimeLocked,
            "TIME_LOCK_INCOMPLETE"
        );
        _;
    }


    constructor (
        address[] memory _owners,
        uint256 _required,
        uint32 _secondsTimeLocked
    )
        public
        MultiSig(_owners, _required)
    {
        secondsTimeLocked = _secondsTimeLocked;
    }


    function changeTimeLock(
        uint32 _secondsTimeLocked
    )
        public
        onlyWallet
    {

        secondsTimeLocked = _secondsTimeLocked;
        emit TimeLockChange(_secondsTimeLocked);
    }


    function confirmTransaction(
        uint256 transactionId
    )
        public
        override
        ownerExists(msg.sender)
        transactionExists(transactionId)
        notConfirmed(transactionId, msg.sender)
        notFullyConfirmed(transactionId)
    {

        confirmations[transactionId][msg.sender] = true;
        emit Confirmation(msg.sender, transactionId);
        if (isConfirmed(transactionId)) {
            setConfirmationTime(transactionId, block.timestamp);
        }
    }

    function confirmTransaction(
        address signer,
        uint256 transactionId,
        bytes memory sig
    )
        public
        override
        ownerExists(signer)
        transactionExists(transactionId)
        notConfirmed(transactionId, signer)
        notFullyConfirmed(transactionId)
    {

        bytes32 EIP712SignDigest = keccak256(
            abi.encodePacked(
                bytes1(0x19),
                bytes1(0x01),
                EIP712_DOMAIN_SEPARATOR,
                keccak256(
                    abi.encode(
                        CONFIRM_TRANSACTION_TYPE_HASH,
                        transactionId
                    )
                )
            )
        );
        validateSignature(signer, EIP712SignDigest, sig);

        confirmations[transactionId][signer] = true;
        emit Confirmation(signer, transactionId);
        if (isConfirmed(transactionId)) {
            setConfirmationTime(transactionId, block.timestamp);
        }
    }

    function executeTransaction(
        uint256 transactionId
    )
        public
        override
        ownerExists(msg.sender)
        notExecuted(transactionId)
        fullyConfirmed(transactionId)
        pastTimeLock(transactionId)
    {

        Transaction storage txn = transactions[transactionId];
        txn.executed = true;
        bool success = externalCall(
            txn.destination,
            txn.value,
            txn.data.length,
            txn.data
        );
        require(
            success,
            "TX_REVERTED"
        );
        emit Execution(transactionId);
    }

    function executeMultipleTransactions(
        uint256[] memory transactionIds
    )
        public
        ownerExists(msg.sender)
    {

        for (uint256 i = 0; i < transactionIds.length; i++) {
            executeTransaction(transactionIds[i]);
        }
    }


    function setConfirmationTime(
        uint256 transactionId,
        uint256 confirmationTime
    )
        internal
    {

        confirmationTimes[transactionId] = confirmationTime;
        emit ConfirmationTimeSet(transactionId, confirmationTime);
    }
}


contract PartiallyDelayedMultiSig is
    DelayedMultiSig
{


    event SelectorSet(address destination, bytes4 selector, bool approved);


    bytes4 constant internal BYTES_ZERO = bytes4(0x0);


    mapping (address => mapping (bytes4 => bool)) public instantData;


    modifier pastTimeLock(
        uint256 transactionId
    ) override {

        require(
            block.timestamp >= confirmationTimes[transactionId] + secondsTimeLocked
            || txCanBeExecutedInstantly(transactionId),
            "TIME_LOCK_INCOMPLETE"
        );
        _;
    }


    constructor (
        address[] memory _owners,
        uint256 _required,
        uint32 _secondsTimeLocked,
        address[] memory _noDelayDestinations,
        bytes4[] memory _noDelaySelectors
    )
        public
        DelayedMultiSig(_owners, _required, _secondsTimeLocked)
    {
        require(
            _noDelayDestinations.length == _noDelaySelectors.length,
            "ADDRESS_AND_SELECTOR_MISMATCH"
        );

        for (uint256 i = 0; i < _noDelaySelectors.length; i++) {
            address destination = _noDelayDestinations[i];
            bytes4 selector = _noDelaySelectors[i];
            instantData[destination][selector] = true;
            emit SelectorSet(destination, selector, true);
        }
    }


    function setSelector(
        address destination,
        bytes4 selector,
        bool approved
    )
        public
        onlyWallet
    {

        instantData[destination][selector] = approved;
        emit SelectorSet(destination, selector, approved);
    }


    function txCanBeExecutedInstantly(
        uint256 transactionId
    )
        internal
        view
        returns (bool)
    {

        Transaction memory txn = transactions[transactionId];
        address dest = txn.destination;
        bytes memory data = txn.data;

        if (data.length == 0) {
            return selectorCanBeExecutedInstantly(dest, BYTES_ZERO);
        }

        if (data.length < 4) {
            return false;
        }

        bytes32 rawData;
        assembly {
            rawData := mload(add(data, 32))
        }
        bytes4 selector = bytes4(rawData);

        return selectorCanBeExecutedInstantly(dest, selector);
    }

    function selectorCanBeExecutedInstantly(
        address destination,
        bytes4 selector
    )
        internal
        view
        returns (bool)
    {

        return instantData[destination][selector]
            || instantData[ADDRESS_ZERO][selector];
    }
}