

pragma solidity ^0.4.24;

library SafeMath {


	function mul(uint256 a, uint256 b) internal pure returns (uint256) {

		if (a == 0) {
			return 0;
		}

		uint256 c = a * b;
		require(c / a == b);

		return c;
	}

	function div(uint256 a, uint256 b) internal pure returns (uint256) {

		require(b > 0); // Solidity only automatically asserts when dividing by 0
		uint256 c = a / b;

		return c;
	}

	function sub(uint256 a, uint256 b) internal pure returns (uint256) {

		require(b <= a);
		uint256 c = a - b;

		return c;
	}

	function add(uint256 a, uint256 b) internal pure returns (uint256) {

		uint256 c = a + b;
		require(c >= a);

		return c;
	}

	function mod(uint256 a, uint256 b) internal pure returns (uint256) {

		require(b != 0);
		return a % b;
	}
}

contract ERC20 {

	using SafeMath for uint256;

	mapping (address => uint256) private _balances;

	mapping (address => mapping (address => uint256)) private _allowed;

	uint256 private _totalSupply;
	
	string private _name;
    string private _symbol;
    uint8 private _decimals;

	event Transfer(
		address indexed from,
		address indexed to,
		uint256 value
	);

	event Approval(
		address indexed owner,
		address indexed spender,
		uint256 value
	);

	constructor (string memory name, string memory symbol, uint8 decimals) public {
        _name = name;
        _symbol = symbol;
        _decimals = decimals;
    }

    function name() public view returns (string memory) {

        return _name;
    }

    function symbol() public view returns (string memory) {

        return _symbol;
    }

    function decimals() public view returns (uint8) {

        return _decimals;
    }

	function totalSupply() public view returns (uint256) {

		return _totalSupply;
	}

	function balanceOf(address owner) public view returns (uint256) {

		return _balances[owner];
	}

	function allowance(
			address owner,
			address spender
			)
		public
		view
		returns (uint256)
		{

			return _allowed[owner][spender];
		}

	function transfer(address to, uint256 value) public returns (bool) {

		_transfer(msg.sender, to, value);
		return true;
	}

	function approve(address spender, uint256 value) public returns (bool) {

		require(spender != address(0));

	_allowed[msg.sender][spender] = value;
	emit Approval(msg.sender, spender, value);
	return true;
}

function transferFrom(
		address from,
		address to,
		uint256 value
		)
	public
returns (bool)
{

	require(value <= _allowed[from][msg.sender]);

_allowed[from][msg.sender] = _allowed[from][msg.sender].sub(value);
_transfer(from, to, value);
return true;
  }

  function increaseAllowance(
	  address spender,
	  uint256 addedValue
  )
  public
  returns (bool)
  {

	  require(spender != address(0));

	  _allowed[msg.sender][spender] = (
		  _allowed[msg.sender][spender].add(addedValue));
		  emit Approval(msg.sender, spender, _allowed[msg.sender][spender]);
		  return true;
  }

  function decreaseAllowance(
	  address spender,
	  uint256 subtractedValue
  )
  public
  returns (bool)
  {

	  require(spender != address(0));

	  _allowed[msg.sender][spender] = (
		  _allowed[msg.sender][spender].sub(subtractedValue));
		  emit Approval(msg.sender, spender, _allowed[msg.sender][spender]);
		  return true;
  }

  function _transfer(address from, address to, uint256 value) internal {

	  require(value <= _balances[from]);
	  require(to != address(0));

	  _balances[from] = _balances[from].sub(value);
	  _balances[to] = _balances[to].add(value);
	  emit Transfer(from, to, value);
  }

  function _mint(address account, uint256 value) internal {

	  require(account != address(0));
	  _totalSupply = _totalSupply.add(value);
	  _balances[account] = _balances[account].add(value);
	  emit Transfer(address(0), account, value);
  }

  function _burn(address account, uint256 value) internal {

	  require(account != address(0));
	  require(value <= _balances[account]);

	  _totalSupply = _totalSupply.sub(value);
	  _balances[account] = _balances[account].sub(value);
	  emit Transfer(account, address(0), value);
  }

  function _burnFrom(address account, uint256 value) internal {

	  require(value <= _allowed[account][msg.sender]);

	  _allowed[account][msg.sender] = _allowed[account][msg.sender].sub(
		  value);
		  _burn(account, value);
  }
}


contract WrappedZynecoin is ERC20 {

    event Confirmation(address indexed sender, uint indexed transactionId);
    event Revocation(address indexed sender, uint indexed transactionId);
    event Submission(uint indexed transactionId);
    event Execution(uint indexed transactionId);
    event ExecutionFailure(uint indexed transactionId);
    event OwnerAddition(address indexed owner);
    event OwnerRemoval(address indexed owner);
    event RequirementChange(uint required);
    event TokenBurn(uint256 indexed burnID, address indexed burner, uint256 value, bytes data);

    uint constant public MAX_OWNER_COUNT = 50;
    uint public WITHDRAW_FEE = 0;
    
    mapping (uint => Transaction) public transactions;
    mapping (uint => mapping (address => bool)) public confirmations;
    mapping (address => bool) public isOwner;
    address[] public owners;
    address public issuer;
    uint public required;
    uint public transactionCount;
    TokenBurnData[] public burnList;

    mapping(uint256 => bytes32) public idHashMapping;

    struct TokenBurnData {
        uint256 value;
        address burner;
        bytes data;
    }
    
    struct Transaction {
        address destination;
        uint value;
        bytes data; //data is used in transactions altering owner list
        bool executed;
    }

    modifier onlyWallet() {

        require(msg.sender == address(this));
        _;
    }

    modifier ownerDoesNotExist(address owner) {

        require(!isOwner[owner]);
        _;
    }

    modifier ownerExists(address owner) {

        require(isOwner[owner]);
        _;
    }

    modifier transactionExists(uint transactionId) {

        require(transactions[transactionId].destination != 0);
        _;
    }

    modifier confirmed(uint transactionId, address owner) {

        require(confirmations[transactionId][owner]);
        _;
    }

    modifier notConfirmed(uint transactionId, address owner) {

        require(!confirmations[transactionId][owner]);
        _;
    }

    modifier notExecuted(uint transactionId) {

        require(!transactions[transactionId].executed);
        _;
    }

    modifier notNull(address _address) {

        require(_address != 0);
        _;
    }

    modifier validRequirement(uint ownerCount, uint _required) {

        require(ownerCount <= MAX_OWNER_COUNT
        && _required <= ownerCount
        && _required != 0
        && ownerCount != 0);
        _;
    }
    
    modifier onlyIssuer() {

        require(msg.sender == issuer);
        _;
    }
    
    constructor (address[] _owners,
                 uint _required, string memory _name,
                 string memory _symbol, uint8 _decimals,
                 uint256 cap,
                 uint256 withdrawFee
                ) ERC20(_name, _symbol, _decimals) public validRequirement(_owners.length, _required) {
        _mint(msg.sender, cap);
        issuer = msg.sender;
        WITHDRAW_FEE = withdrawFee;
        for (uint i=0; i<_owners.length; i++) {
            require(!isOwner[_owners[i]] && _owners[i] != 0);
            isOwner[_owners[i]] = true;
        }
        owners = _owners;
        required = _required;
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

    function removeOwner(address owner)
    public
    onlyWallet
    ownerExists(owner)
    {

        isOwner[owner] = false;
        for (uint i=0; i<owners.length - 1; i++)
            if (owners[i] == owner) {
                owners[i] = owners[owners.length - 1];
                break;
            }
        owners.length -= 1;
        if (required > owners.length)
            changeRequirement(owners.length);
        emit OwnerRemoval(owner);
    }

    function replaceOwner(address owner, address newOwner)
    public
    onlyWallet
    ownerExists(owner)
    ownerDoesNotExist(newOwner)
    {

        for (uint i=0; i<owners.length; i++)
            if (owners[i] == owner) {
                owners[i] = newOwner;
                break;
            }
        isOwner[owner] = false;
        isOwner[newOwner] = true;
        emit OwnerRemoval(owner);
        emit OwnerAddition(newOwner);
    }

    function changeRequirement(uint _required)
    public
    onlyWallet
    validRequirement(owners.length, _required)
    {

        required = _required;
        emit RequirementChange(_required);
    }

    function submitTransaction(address destination, uint value, bytes data, bytes32 txHash) 
    public
    returns (uint transactionId)
    {

        transactionId = addTransaction(destination, value, data, txHash);
        confirmTransaction(transactionId);
    }
    

    function confirmTransaction(uint transactionId)
    public
    ownerExists(msg.sender)
    transactionExists(transactionId)
    notConfirmed(transactionId, msg.sender)
    {

        confirmations[transactionId][msg.sender] = true;
        emit Confirmation(msg.sender, transactionId);
        executeTransaction(transactionId);
    }

    function revokeConfirmation(uint transactionId)
    public
    ownerExists(msg.sender)
    confirmed(transactionId, msg.sender)
    notExecuted(transactionId)
    {

        confirmations[transactionId][msg.sender] = false;
        emit Revocation(msg.sender, transactionId);
    }

    function burn(uint value, bytes data)
    public
    {

        require(value > WITHDRAW_FEE);
        super._burn(msg.sender, value);
        
        if (WITHDRAW_FEE > 0) {
            super._mint(issuer, WITHDRAW_FEE);
        }
        uint256 burnValue = value.sub(WITHDRAW_FEE);
        burnList.push(TokenBurnData({
            value: burnValue,
            burner: msg.sender,
            data: data 
        }));
        emit TokenBurn(burnList.length - 1, msg.sender, burnValue, data);

    }

    function executeTransaction(uint transactionId)
    public
    ownerExists(msg.sender)
    confirmed(transactionId, msg.sender)
    notExecuted(transactionId)
    {

        if (isConfirmed(transactionId)) {
            Transaction storage txn = transactions[transactionId];
            txn.executed = true;

            if (txn.data.length == 0) {
                txn.value = txn.value;
                super._mint(txn.destination, txn.value);
                emit Execution(transactionId);
            } else {
                if (txn.destination.call.value(txn.value)(txn.data))
                    emit Execution(transactionId);
                else {
                    emit ExecutionFailure(transactionId);
                    txn.executed = false;
                }
            }
        }
    }

    function isConfirmed(uint transactionId)
    public
    constant
    returns (bool)
    {

        uint count = 0;
        for (uint i=0; i<owners.length; i++) {
            if (confirmations[transactionId][owners[i]])
                count += 1;
            if (count == required)
                return true;
        }
    }

    function addTransaction(address destination, uint value, bytes data, bytes32 txHash)
    internal
    notNull(destination)
    returns (uint transactionId)
    {

        transactionId = transactionCount;
        transactions[transactionId] = Transaction({
            destination: destination,
            value: value,
            data: data,
            executed: false
        });
        transactionCount += 1;
        idHashMapping[transactionId] = txHash;
        emit Submission(transactionId);
    }

    function getConfirmationCount(uint transactionId)
    public
    constant
    returns (uint count)
    {

        for (uint i=0; i<owners.length; i++)
            if (confirmations[transactionId][owners[i]])
                count += 1;
    }

    function getTransactionCount(bool pending, bool executed)
    public
    constant
    returns (uint count)
    {

        for (uint i=0; i<transactionCount; i++)
            if (   pending && !transactions[i].executed
            || executed && transactions[i].executed)
                count += 1;
    }

    function getOwners()
    public
    constant
    returns (address[])
    {

        return owners;
    }

    function getConfirmations(uint transactionId)
    public
    constant
    returns (address[] _confirmations)
    {

        address[] memory confirmationsTemp = new address[](owners.length);
        uint count = 0;
        uint i;
        for (i=0; i<owners.length; i++)
            if (confirmations[transactionId][owners[i]]) {
                confirmationsTemp[count] = owners[i];
                count += 1;
            }
        _confirmations = new address[](count);
        for (i=0; i<count; i++)
            _confirmations[i] = confirmationsTemp[i];
    }

    function getTransactionIds(uint from, uint to, bool pending, bool executed)
    public
    constant
    returns (uint[] _transactionIds)
    {

        uint end = to > transactionCount? transactionCount: to;
        uint[] memory transactionIdsTemp = new uint[](end - from);
        uint count = 0;
        uint i;
        for (i = from; i < to; i++) {
            if ((pending && !transactions[i].executed)
                || (executed && transactions[i].executed))
            {
                transactionIdsTemp[count] = i;
                count += 1;
            }
        }
        _transactionIds = new uint[](count);
        for (i = 0; i < count; i++)
            _transactionIds[i] = transactionIdsTemp[i];
    }
    
    function getBurnCount() public view returns (uint256) {

        return burnList.length;
    }

    function getBurn(uint burnId) public view returns (address _burner, uint256 _value, bytes _data) {

        _burner = burnList[burnId].burner;
        _value = burnList[burnId].value;
        _data = burnList[burnId].data;
    }
    
    function transferIssuer(address newIssuer) 
    public
    onlyIssuer
    notNull(newIssuer)
    {

        issuer = newIssuer;
    }

    function setWithdrawFee(uint256 withdrawFee) public onlyIssuer {

        WITHDRAW_FEE = withdrawFee;
    }

}