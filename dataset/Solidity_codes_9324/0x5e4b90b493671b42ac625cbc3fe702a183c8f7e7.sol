pragma solidity ^0.5.0;


contract MultiSigWallet {


    event Confirmation(address indexed sender, uint256 indexed transactionId);
    event Revocation(address indexed sender, uint256 indexed transactionId);
    event Submission(uint256 indexed transactionId);
    event Execution(uint256 indexed transactionId);
    event ExecutionFailure(uint256 indexed transactionId);
    event Deposit(address indexed sender, uint256 value);
    event OwnerAddition(address indexed owner);
    event OwnerRemoval(address indexed owner);
    event RequirementChange(uint256 required);

    uint256 constant public MAX_OWNER_COUNT = 50;

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

    function() external payable {
        if (msg.value > 0)
            emit Deposit(msg.sender, msg.value);
    }

    constructor(address[] memory _owners, uint256 _required) public validRequirement(_owners.length, _required) {
        for (uint256 i = 0; i < _owners.length; i++) {
            require(!isOwner[_owners[i]] && _owners[i] != address(0), "is already owner");
            isOwner[_owners[i]] = true;
        }
        owners = _owners;
        required = _required;
    }

    function addOwner(address owner)  public
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
        for (uint256 i = 0; i < owners.length - 1; i++){
            if (owners[i] == owner) {
                owners[i] = owners[owners.length - 1];
                break;
            }
        }
        owners.length -= 1;
        if (required > owners.length)
            changeRequirement(owners.length);
        emit OwnerRemoval(owner);
    }

    function replaceOwner(address owner, address newOwner) public onlyWallet ownerExists(owner) ownerDoesNotExist(newOwner) {

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

    function changeRequirement(uint256 _required) public onlyWallet validRequirement(owners.length, _required) {

        required = _required;
        emit RequirementChange(_required);
    }

    function submitTransaction(address destination, uint256 value, bytes memory data) public returns (uint256 transactionId) {

        transactionId = addTransaction(destination, value, data);
        confirmTransaction(transactionId);
    }

    function confirmTransaction(uint256 transactionId) public
        ownerExists(msg.sender)
        transactionExists(transactionId)
        notConfirmed(transactionId, msg.sender)
    {

        confirmations[transactionId][msg.sender] = true;
        emit Confirmation(msg.sender, transactionId);
        executeTransaction(transactionId);
    }

    function revokeConfirmation(uint256 transactionId) public
        ownerExists(msg.sender)
        confirmed(transactionId, msg.sender)
        notExecuted(transactionId)
    {

        confirmations[transactionId][msg.sender] = false;
        emit Revocation(msg.sender, transactionId);
    }

    function executeTransaction(uint256 transactionId) public
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

    function external_call(address destination, uint256 value, uint256 dataLength, bytes memory data) internal returns (bool) {

        bool result;
        assembly {
            let x := mload(0x40)   // "Allocate" memory for output (0x40 is where "free memory" pointer is stored by convention)
            let d := add(data, 32) // First 32 bytes are the padded length of data, so exclude that
            result := call(
                sub(gas, 34710),   // 34710 is the value that solidity is currently emitting
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

    function isConfirmed(uint256 transactionId) public view returns (bool) {

        uint256 count = 0;
        for (uint256 i = 0; i < owners.length; i++) {
            if (confirmations[transactionId][owners[i]])
                count += 1;
            if (count == required)
                return true;
        }
    }

    function addTransaction(address destination, uint256 value, bytes memory data) internal
     notNull(destination) returns (uint256 transactionId) {

        transactionId = transactionCount;
        transactions[transactionId] = Transaction({
            destination: destination,
            value: value,
            data: data,
            executed: false,
            timestamp: now
        });
        transactionCount += 1;
        emit Submission(transactionId);
    }

    function getConfirmationCount(uint256 transactionId) public view returns (uint256 count) {

        for (uint256 i = 0; i < owners.length; i++) {
            if (confirmations[transactionId][owners[i]])  count += 1;
        }
    }

    function getTransactionCount(bool pending, bool executed) public view returns (uint256 count) {

        for (uint256 i = 0; i < transactionCount; i++) {
            if ( pending && !transactions[i].executed || executed && transactions[i].executed)
                count += 1;
        }
    }

    function getOwners() public view returns (address[] memory) {

        return owners;
    }

    function getConfirmations(uint256 transactionId) public view returns (address[] memory _confirmations) {

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

    function getTransactionIds(uint256 from, uint256 to, bool pending, bool executed) public view returns (uint256[] memory _transactionIds) {

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

    function getTransaction(uint256 transactionId) public view returns (bytes memory, address, bool, uint256) {

        Transaction memory txn = transactions[transactionId];
        return (
            txn.data,
            txn.destination,
            txn.executed,
            txn.timestamp
        );
    }
}
pragma solidity ^0.5.0;

contract Context {

    constructor () internal {

    }

    function _msgSender() internal view returns (address payable) {

        return msg.sender;
    }

    function _msgData() internal view returns (bytes memory) {

        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}
pragma solidity ^0.5.0;

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
pragma solidity ^0.5.0;

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
pragma solidity ^0.5.0;


contract ERC20 is Context, IERC20 {

    using SafeMath for uint256;

    mapping (address => uint256) private _balances;

    mapping (address => mapping (address => uint256)) private _allowances;

    uint256 private _totalSupply;

    function totalSupply() public view returns (uint256) {

        return _totalSupply;
    }

    function balanceOf(address account) public view returns (uint256) {

        return _balances[account];
    }

    function transfer(address recipient, uint256 amount) public returns (bool) {

        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function allowance(address owner, address spender) public view returns (uint256) {

        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public returns (bool) {

        _approve(_msgSender(), spender, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) public returns (bool) {

        _transfer(sender, recipient, amount);
        _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount, "ERC20: transfer amount exceeds allowance"));
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public returns (bool) {

        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].add(addedValue));
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public returns (bool) {

        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].sub(subtractedValue, "ERC20: decreased allowance below zero"));
        return true;
    }

    function _transfer(address sender, address recipient, uint256 amount) internal {

        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        _balances[sender] = _balances[sender].sub(amount, "ERC20: transfer amount exceeds balance");
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
    }

    function _mint(address account, uint256 amount) internal {

        require(account != address(0), "ERC20: mint to the zero address");

        _totalSupply = _totalSupply.add(amount);
        _balances[account] = _balances[account].add(amount);
        emit Transfer(address(0), account, amount);
    }

    function _burn(address account, uint256 amount) internal {

        require(account != address(0), "ERC20: burn from the zero address");

        _balances[account] = _balances[account].sub(amount, "ERC20: burn amount exceeds balance");
        _totalSupply = _totalSupply.sub(amount);
        emit Transfer(account, address(0), amount);
    }

    function _approve(address owner, address spender, uint256 amount) internal {

        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _burnFrom(address account, uint256 amount) internal {

        _burn(account, amount);
        _approve(account, _msgSender(), _allowances[account][_msgSender()].sub(amount, "ERC20: burn amount exceeds allowance"));
    }
}
pragma solidity ^0.5.0;



contract ERC20MultiSigWallet is MultiSigWallet {


    constructor(address[] memory _owners, uint256 _required) public MultiSigWallet(_owners, _required) {

    }

    function withdraw(address _token, address _to, uint256 _amount) public onlyWallet {

        require(_token != address(0), "Token address cannot be 0");
        require(_to != address(0), "recipient address cannot be 0");
        require(_amount > 0, "amount cannot be 0");
        require(ERC20(_token).balanceOf(address(this)) > 0, "Contract does not have any balance");
        require(ERC20(_token).balanceOf(address(this)) > _amount, "Contract does not have such balance");
        ERC20(_token).transfer(_to, _amount);
    }
}pragma solidity ^0.5.0;


contract ERC20MultiSigDeployer {


    mapping (address => address[]) public contractsByUser;

    address[] public contracts;

    function deploy(address[] memory _owners, uint256 _required) public {

        ERC20MultiSigWallet multisigWallet = new ERC20MultiSigWallet(_owners, _required);
        contracts.push(address(multisigWallet));
        for (uint256 i = 0; i < _owners.length; i++) {
            contractsByUser[_owners[i]].push(address(multisigWallet));
        }
    }

    function getContracts(address _user) public view returns(address[] memory) {

        return contractsByUser[_user];
    }

    function getAllContracts() public view returns(address[] memory) {

        return contracts;
    }
}
