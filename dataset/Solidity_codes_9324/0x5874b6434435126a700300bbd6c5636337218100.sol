
pragma solidity ^0.8.0;

interface IERC20 {

    function totalSupply() external view returns (uint256);


    function balanceOf(address account) external view returns (uint256);


    function transfer(address recipient, uint256 amount) external returns (bool);


    function allowance(address owner, address spender) external view returns (uint256);


    function approve(address spender, uint256 amount) external returns (bool);


    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);


    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}// MIT
pragma solidity ^0.8.0;




contract MultisigWallet  {



    event WithDrawal(address indexed _token, address indexed _to, uint256 _amount);

    event Confirmation(address indexed sender, uint256 indexed transactionId);
    event Revocation(address indexed sender, uint256 indexed transactionId);
    event Submission(uint256 indexed transactionId);
    event Execution(uint256 indexed transactionId);
    event ExecutionFailure(uint256 indexed transactionId);
    event Deposit(address indexed sender, uint256 value);
    event OwnerAddition(address indexed owner);
    event OwnerRemoval(address indexed owner);
    event RequirementChange(uint256 required);
    event RequestLock(address indexed sender);
    event RequestUnlock(address indexed sender);
    event ExecuteUnlock(address indexed sender);

    uint256 constant public MAX_OWNER_COUNT = 50;
    uint256 constant public UNLOCK_TIME = 365 days;

    mapping (uint256 => Transaction) public transactions;
    mapping (uint256 => mapping (address => bool)) public confirmations;
    mapping (address => bool) public isOwner;
    address[] public owners;
    uint256 public required;
    uint256 public transactionCount;

    uint256 public unlockTimeStart;
    bool public isUnlocking;

    struct Transaction {
        string description;
        address destination;
        uint256 value;
        bytes data;
        bool executed;
        uint256 timestamp;
    }

    modifier onlyWallet() {

        require(msg.sender == address(this), "Only wallet");
        _;
    }

    modifier ownerDoesNotExist(address owner) {

        require(!isOwner[owner], "Owner exists");
        _;
    }

    modifier ownerExists(address owner) {

        require(isOwner[owner], "Owner does not exists");
        _;
    }

    modifier transactionExists(uint256 transactionId) {

        require(transactions[transactionId].destination != address(0), "Tx doesn't exist");
        _;
    }

    modifier confirmed(uint256 transactionId, address owner) {

        require(confirmations[transactionId][owner], "not confirmed");
        _;
    }

    modifier notConfirmed(uint256 transactionId, address owner) {

        require(!confirmations[transactionId][owner], "is already confirmed");
        _;
    }

    modifier notExecuted(uint256 transactionId) {

        require(!transactions[transactionId].executed, "tx already executed");
        _;
    }

    modifier notNull(address _address) {

        require(_address != address(0), "address is null");
        _;
    }

    modifier validRequirement(uint256 ownerCount, uint256 _required) {

        require(ownerCount <= MAX_OWNER_COUNT && _required <= ownerCount && _required != 0 && ownerCount != 0, "invalid requirement");
        _;
    }

    fallback() virtual external payable {
        if (msg.value > 0)
            emit Deposit(msg.sender, msg.value);
    }

    receive() virtual external payable {
        if (msg.value > 0)
            emit Deposit(msg.sender, msg.value);
    }


    constructor(address[] memory _owners, uint256 _required) validRequirement(_owners.length, _required) {
        for (uint256 i = 0; i < _owners.length; i++) {
            require(!isOwner[_owners[i]] && _owners[i] != address(0), "is already owner");
            isOwner[_owners[i]] = true;
        }
        owners = _owners;
        required = _required;
    }

    function addOwner(address owner)  virtual public
        onlyWallet
        ownerDoesNotExist(owner)
        notNull(owner)
        validRequirement(owners.length + 1, required)
    {

        isOwner[owner] = true;
        owners.push(owner);
        emit OwnerAddition(owner);
    }

    function removeOwner(address owner) virtual public onlyWallet ownerExists(owner) {

        isOwner[owner] = false;
        int256 ownerIndex = _indexOf(owners, owner);
        owners[uint256(ownerIndex)] = owners[owners.length - 1];
        owners.pop();

        if (required > owners.length)
            changeRequirement(owners.length);
        emit OwnerRemoval(owner);
    }

    function replaceOwner(address owner, address newOwner) virtual public onlyWallet ownerExists(owner) ownerDoesNotExist(newOwner) {

        for(uint256 i = 0; i < owners.length; i++) {
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

    function changeRequirement(uint256 _required) virtual public onlyWallet validRequirement(owners.length, _required) {

        required = _required;
        emit RequirementChange(_required);
    }

    function submitTransaction(address destination, uint256 value, bytes memory data, string memory description) virtual public ownerExists(msg.sender)
    returns (uint256 transactionId) {

        transactionId = addTransaction(destination, value, data, description);
        confirmTransaction(transactionId);
    }

    function confirmTransaction(uint256 transactionId) virtual public
        ownerExists(msg.sender)
        transactionExists(transactionId)
        notConfirmed(transactionId, msg.sender)
    {

        confirmations[transactionId][msg.sender] = true;
        emit Confirmation(msg.sender, transactionId);
        executeTransaction(transactionId);
    }

    function revokeConfirmation(uint256 transactionId) virtual public
        ownerExists(msg.sender)
        confirmed(transactionId, msg.sender)
        notExecuted(transactionId)
    {

        confirmations[transactionId][msg.sender] = false;
        emit Revocation(msg.sender, transactionId);
    }

    function executeTransaction(uint256 transactionId) virtual public
        ownerExists(msg.sender)
        confirmed(transactionId, msg.sender)
        notExecuted(transactionId)
    {

        if (isConfirmed(transactionId)) {
            Transaction storage txn = transactions[transactionId];
            txn.executed = true;
            if (external_call(txn.destination, txn.value, txn.data.length, txn.data))
                emit Execution(transactionId);
            else {
                emit ExecutionFailure(transactionId);
                txn.executed = false;
            }
        }
    }

    function external_call(address destination, uint256 value, uint256 dataLength, bytes memory data) virtual internal returns (bool) {

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

    function isConfirmed(uint256 transactionId) virtual public view returns (bool) {

        uint256 count = 0;
        for (uint256 i = 0; i < owners.length; i++) {
            if (confirmations[transactionId][owners[i]])
                count += 1;
            if (count == required)
                return true;
        }
        return false;
    }

    function addTransaction(address destination, uint256 value, bytes memory data, string memory description) virtual internal
     notNull(destination) returns (uint256 transactionId) {

        transactionId = transactionCount;
        transactions[transactionId] = Transaction({
            description: description,
            destination: destination,
            value: value,
            data: data,
            executed: false,
            timestamp: block.timestamp
        });
        transactionCount += 1;
        emit Submission(transactionId);
    }

    function getConfirmationCount(uint256 transactionId) virtual public view returns (uint256 count) {

        for (uint256 i = 0; i < owners.length; i++) {
            if (confirmations[transactionId][owners[i]])  count += 1;
        }
    }

    function getTransactionCount(bool pending, bool executed) virtual public view returns (uint256 count) {

        for (uint256 i = 0; i < transactionCount; i++) {
            if ( pending && !transactions[i].executed || executed && transactions[i].executed)
                count += 1;
        }
    }

    function getConfirmations(uint256 transactionId) virtual public view returns (address[] memory _confirmations) {

        address[] memory confirmationsTemp = new address[](owners.length);
        uint256 count = 0;
        uint256 i;
        for (i = 0; i < owners.length; i++) {
            if (confirmations[transactionId][owners[i]]) {
                confirmationsTemp[count] = owners[i];
                count += 1;
            }
        }
        _confirmations = new address[](count);
        for (i = 0; i < count; i++) {
            _confirmations[i] = confirmationsTemp[i];
        }
    }

    function getTransactionIds(uint256 from, uint256 to, bool pending, bool executed) virtual public view returns (uint256[] memory _transactionIds) {

        uint256[] memory transactionIdsTemp = new uint256[](transactionCount);
        uint256 count = 0;
        uint256 i;
        for (i = 0; i < transactionCount; i++)
            if (   pending && !transactions[i].executed || executed && transactions[i].executed) {
                transactionIdsTemp[count] = i;
                count += 1;
            }
        _transactionIds = new uint256[](to - from);
        for (i = from; i < to; i++){
            _transactionIds[i - from] = transactionIdsTemp[i];
        }
    }

    function _indexOf(address[] memory array, address _address) private pure returns (int256) {

        for(uint256 i = 0; i < array.length; i++) {
            if(array[i] == _address) return int256(i);
        }
        return int8(-1);
    } 

    function getOwners() virtual public view returns (address[] memory) {

        return owners;
    }

    function getTransaction(uint256 transactionId) virtual public view returns (Transaction memory) {

        return transactions[transactionId];
    }

    function withdraw(address _token, address _to, uint256 _amount) public onlyWallet {

        require(_token != address(0), "Token address cannot be 0");
        require(_to != address(0), "recipient address cannot be 0");
        require(_amount > 0, "amount cannot be 0");

        IERC20(_token).transfer(_to, _amount);
        emit WithDrawal(_token, _to, _amount);
    }

    function withdrawETH(address payable _to, uint256 _amount) public onlyWallet {

        _to.transfer(_amount);
    }

    function requestUnlock() public ownerExists(msg.sender) {

        require(!isUnlocking, "Already requested");
        unlockTimeStart = block.timestamp;
        isUnlocking = true;
        emit RequestUnlock(msg.sender);
    }

    function requestLock() public ownerExists(msg.sender) {

        require(isUnlocking, "Not Unlocking");
        unlockTimeStart = 0;
        isUnlocking = false;
        emit RequestLock(msg.sender);
    }

    function executeUnlock() public ownerExists(msg.sender) {

        require(isUnlocking, "Not Unlocking");
        require(unlockTimeStart + UNLOCK_TIME < block.timestamp, "Time still not passed");
        unlockTimeStart = 0;
        isUnlocking = false;
        required = 1;
        emit ExecuteUnlock(msg.sender);
        emit RequirementChange(1);
    }


}