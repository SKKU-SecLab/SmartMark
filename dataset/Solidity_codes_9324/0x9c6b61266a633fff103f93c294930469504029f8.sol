
pragma solidity >=0.6.0 <0.7.0;

interface IERC20 {

    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount) external returns (bool);

    function allowance(address owner, address spender) external view returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

}

contract GHTMultiSigWallet {


    IERC20 public GHT;
    address private _owner;
    mapping(address => uint8) private _owners;

    uint constant MIN_SIGNATURES = 2;
    uint private _transactionIdx;

    struct Transaction {
		address payable from;
		address payable to;
		uint amount;
		uint8 signatureCount;
		mapping (address => uint8) signatures;
		uint8 typeOfTransaction; // 0 = ETH, 1 = GHT
    }

    mapping (uint => Transaction) private _transactions;
    uint[] private _pendingETHTransactions;
    uint[] private _pendingGHTTransactions;

    modifier isOwner() {

        require(msg.sender == _owner);
        _;
    }

    modifier validOwner() {

        require(msg.sender == _owner || _owners[msg.sender] == 1);
        _;
    }

    event DepositFunds(address from, uint256 amount);
    event ETHTransactionCreated(address from, address to, uint amount, uint transactionId);
    event ETHTransactionCompleted(address from, address to, uint amount, uint transactionId);
    event ETHTransactionSigned(address by, uint transactionId);
    
    event GHTTransactionCreated(address from, address to, uint amount, uint transactionId);
    event GHTTransactionCompleted(address from, address to, uint amount, uint transactionId);
    event GHTTransactionSigned(address by, uint transactionId);

    constructor(address GHTtoken)
        public {
        GHT = IERC20(GHTtoken);
        _owner = msg.sender;
    }

    function addOwner(address owner)
        isOwner
        public {

        _owners[owner] = 1;
    }

    function removeOwner(address owner)
        isOwner
        public {

        _owners[owner] = 0;
    }

    receive ()
        external 
        payable {
        emit DepositFunds(msg.sender, msg.value);
    }

    function withdraw(uint amount)
        public {

        transferETHTo(msg.sender, amount);
    }

    function transferETHTo(address payable to, uint amount)
        validOwner
        public {

        require(address(this).balance >= amount);
        uint transactionId = _transactionIdx++;

        Transaction memory transaction;
        transaction.from = msg.sender;
        transaction.to = to;
        transaction.amount = amount;
        transaction.signatureCount = 0;
        transaction.typeOfTransaction = 0;

        _transactions[transactionId] = transaction;
        _pendingETHTransactions.push(transactionId);

        emit ETHTransactionCreated(msg.sender, to, amount, transactionId);
    }

    function getETHPendingTransactions()
		view
		validOwner
		public
		returns (uint[] memory) {

		return _pendingETHTransactions;
    }

    function signETHTransaction(uint transactionId)
		validOwner
		public {


		Transaction storage transaction = _transactions[transactionId];

		require(address(0) != transaction.from);
		require(msg.sender != transaction.from);
		require(transaction.signatures[msg.sender] != 1);
		require(transaction.typeOfTransaction == 0);

		transaction.signatures[msg.sender] = 1;
		transaction.signatureCount++;

		emit ETHTransactionSigned(msg.sender, transactionId);

		if (transaction.signatureCount >= MIN_SIGNATURES) {
			require(address(this).balance >= transaction.amount);
			transaction.to.transfer(transaction.amount);
			emit ETHTransactionCompleted(transaction.from, transaction.to, transaction.amount, transactionId);
			deleteETHTransaction(transactionId);
		}
    }

    function deleteETHTransaction(uint transactionId)
		validOwner
		public {

		uint8 replace = 0;
		for(uint i = 0; i < _pendingETHTransactions.length; i++) {
			if (1 == replace) {
				_pendingETHTransactions[i-1] = _pendingETHTransactions[i];
			} else if (transactionId == _pendingETHTransactions[i]) {
				replace = 1;
			}
		}
		_pendingETHTransactions.pop();
    }

    function walletBalance()
		view
		public
		returns (uint) {

		return address(this).balance;
    }
    
    
    function transferGHTTo(address payable to, uint amount)
        validOwner
        public {

        require(GHT.balanceOf(address(this)) >= amount);
        uint transactionId = _transactionIdx++;

        Transaction memory transaction;
        transaction.from = msg.sender;
        transaction.to = to;
        transaction.amount = amount;
        transaction.signatureCount = 0;
        transaction.typeOfTransaction = 1;

        _transactions[transactionId] = transaction;
        _pendingGHTTransactions.push(transactionId);

        emit GHTTransactionCreated(msg.sender, to, amount, transactionId);
    }

    function getGHTPendingTransactions()
		view
		validOwner
		public
		returns (uint[] memory) {

		return _pendingGHTTransactions;
    }

    function signGHTTransaction(uint transactionId)
		validOwner
		public {


		Transaction storage transaction = _transactions[transactionId];

		require(address(0) != transaction.from);
		require(msg.sender != transaction.from);
		require(transaction.signatures[msg.sender] != 1);
		require(transaction.typeOfTransaction == 1);

		transaction.signatures[msg.sender] = 1;
		transaction.signatureCount++;

		emit GHTTransactionSigned(msg.sender, transactionId);

		if (transaction.signatureCount >= MIN_SIGNATURES) {
			require(GHT.balanceOf(address(this)) >= transaction.amount);
			GHT.transfer(transaction.to, transaction.amount);
			emit GHTTransactionCompleted(transaction.from, transaction.to, transaction.amount, transactionId);
			deleteGHTTransaction(transactionId);
		}
    }

    function deleteGHTTransaction(uint transactionId)
		validOwner
		public {

		uint8 replace = 0;
		for(uint i = 0; i < _pendingGHTTransactions.length; i++) {
			if (1 == replace) {
				_pendingGHTTransactions[i-1] = _pendingGHTTransactions[i];
			} else if (transactionId == _pendingGHTTransactions[i]) {
				replace = 1;
			}
		}
		_pendingGHTTransactions.pop();
    }
    
    function getTxByIdx(uint transactionId)
		public 
		view 
		returns (
		address, 
		address,
		uint,
		uint8,
		uint8) {

		Transaction storage transaction = _transactions[transactionId];

		return (
			transaction.from, 
			transaction.to, 
			transaction.amount, 
			transaction.signatureCount, 
			transaction.typeOfTransaction);
	}
}