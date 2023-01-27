pragma solidity ^0.6.10;

contract OnlyDeployer {

    address deployer;

    constructor () public {
        deployer = msg.sender;
    }

    modifier onlyDeployer () {

        require(msg.sender == deployer, "Method is preserved for the deployer");
        _;
    }
}

contract OnlyOnce {

    mapping (string => bool) onlyOnceData;

    modifier onlyOnce (string memory id) {

        require(!onlyOnceData[id], "Can only be executed once");
        _;
        onlyOnceData[id] = true;
    }
}// MIT

pragma solidity ^0.6.0;

contract ReentrancyGuard {

    bool private _notEntered;

    constructor () internal {
        _notEntered = true;
    }

    modifier nonReentrant() {

        require(_notEntered, "ReentrancyGuard: reentrant call");

        _notEntered = false;

        _;

        _notEntered = true;
    }
}// MIT

pragma solidity ^0.6.0;

interface IERC1820Implementer {

    function canImplementInterfaceForAddress(bytes32 interfaceHash, address account) external view returns (bytes32);

}// MIT

pragma solidity ^0.6.0;


contract ERC1820Implementer is IERC1820Implementer {

    bytes32 constant private _ERC1820_ACCEPT_MAGIC = keccak256(abi.encodePacked("ERC1820_ACCEPT_MAGIC"));

    mapping(bytes32 => mapping(address => bool)) private _supportedInterfaces;

    function canImplementInterfaceForAddress(bytes32 interfaceHash, address account) public view override returns (bytes32) {

        return _supportedInterfaces[interfaceHash][account] ? _ERC1820_ACCEPT_MAGIC : bytes32(0x00);
    }

    function _registerInterfaceForAddress(bytes32 interfaceHash, address account) internal virtual {

        _supportedInterfaces[interfaceHash][account] = true;
    }
}// MIT

pragma solidity ^0.6.0;

interface IERC1820Registry {

    function setManager(address account, address newManager) external;


    function getManager(address account) external view returns (address);


    function setInterfaceImplementer(address account, bytes32 interfaceHash, address implementer) external;


    function getInterfaceImplementer(address account, bytes32 interfaceHash) external view returns (address);


    function interfaceHash(string calldata interfaceName) external pure returns (bytes32);


    function updateERC165Cache(address account, bytes4 interfaceId) external;


    function implementsERC165Interface(address account, bytes4 interfaceId) external view returns (bool);


    function implementsERC165InterfaceNoCache(address account, bytes4 interfaceId) external view returns (bool);


    event InterfaceImplementerSet(address indexed account, bytes32 indexed interfaceHash, address indexed implementer);

    event ManagerChanged(address indexed account, address indexed newManager);
}// MIT

pragma solidity ^0.6.0;

interface IERC777Recipient {

    function tokensReceived(
        address operator,
        address from,
        address to,
        uint256 amount,
        bytes calldata userData,
        bytes calldata operatorData
    ) external;

}// MIT

pragma solidity ^0.6.0;

interface IERC777Sender {

    function tokensToSend(
        address operator,
        address from,
        address to,
        uint256 amount,
        bytes calldata userData,
        bytes calldata operatorData
    ) external;

}// MIT

pragma solidity ^0.6.0;

interface IERC777 {

    function name() external view returns (string memory);


    function symbol() external view returns (string memory);


    function granularity() external view returns (uint256);


    function totalSupply() external view returns (uint256);


    function balanceOf(address owner) external view returns (uint256);


    function send(address recipient, uint256 amount, bytes calldata data) external;


    function burn(uint256 amount, bytes calldata data) external;


    function isOperatorFor(address operator, address tokenHolder) external view returns (bool);


    function authorizeOperator(address operator) external;


    function revokeOperator(address operator) external;


    function defaultOperators() external view returns (address[] memory);


    function operatorSend(
        address sender,
        address recipient,
        uint256 amount,
        bytes calldata data,
        bytes calldata operatorData
    ) external;


    function operatorBurn(
        address account,
        uint256 amount,
        bytes calldata data,
        bytes calldata operatorData
    ) external;


    event Sent(
        address indexed operator,
        address indexed from,
        address indexed to,
        uint256 amount,
        bytes data,
        bytes operatorData
    );

    event Minted(address indexed operator, address indexed to, uint256 amount, bytes data, bytes operatorData);

    event Burned(address indexed operator, address indexed from, uint256 amount, bytes data, bytes operatorData);

    event AuthorizedOperator(address indexed operator, address indexed tokenHolder);

    event RevokedOperator(address indexed operator, address indexed tokenHolder);
}// MIT

pragma solidity ^0.6.0;

interface IERC20 {

    function totalSupply() external view returns (uint256);


    function balanceOf(address account) external view returns (uint256);


    function transfer(address recipient, uint256 amount) external returns (bool);


    function allowance(address owner, address spender) external view returns (uint256);


    function approve(address spender, uint256 amount) external returns (bool);


    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);


    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}// MIT

pragma solidity ^0.6.0;

contract Context {

    constructor () internal { }

    function _msgSender() internal view virtual returns (address payable) {

        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {

        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}// MIT

pragma solidity ^0.6.2;

library Address {

    function isContract(address account) internal view returns (bool) {

        bytes32 codehash;
        bytes32 accountHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;
        assembly { codehash := extcodehash(account) }
        return (codehash != accountHash && codehash != 0x0);
    }

    function sendValue(address payable recipient, uint256 amount) internal {

        require(address(this).balance >= amount, "Address: insufficient balance");

        (bool success, ) = recipient.call{ value: amount }("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }
}pragma solidity ^0.6.0;


contract Wallet is Context, IERC777Recipient, IERC777Sender, ERC1820Implementer, OnlyDeployer, OnlyOnce  {

    IERC777 tokenContract;
    bool tokenContractSet;

    event ImtyTransaction(address operator, address from, address to, uint256 amount, bytes userData, bytes operatorData);
    event EthTransaction(address from, address to, uint amount);

    IERC1820Registry private _erc1820 = IERC1820Registry(0x1820a4B7618BdE71Dce8cdc73aAB6C95905faD24);

    bytes32 constant private _TOKENS_SENDER_INTERFACE_HASH = keccak256("ERC777TokensSender");
    bytes32 constant private _TOKENS_RECIPIENT_INTERFACE_HASH = keccak256("ERC777TokensRecipient");

    constructor () OnlyDeployer() public {
        _erc1820.setInterfaceImplementer(address(this), _TOKENS_RECIPIENT_INTERFACE_HASH, address(this));
        registerRecipient(address(this));
        registerSender(address(this));
    }
    modifier senderIsImty () {

        require(address(_msgSender()) == address(tokenContract), "Caller is not IMTY token");
        _;
    }

    function senderFor(address account) public {

        _registerInterfaceForAddress(_TOKENS_SENDER_INTERFACE_HASH, account);

        address self = address(this);
        if (account == self) {
            registerSender(self);
        }
    }

    function recipientFor(address account) public {

        _registerInterfaceForAddress(_TOKENS_RECIPIENT_INTERFACE_HASH, account);

        address self = address(this);
        if (account == self) {
            registerRecipient(self);
        }
    }

    function registerRecipient(address recipient) internal {

        _erc1820.setInterfaceImplementer(address(this), _TOKENS_RECIPIENT_INTERFACE_HASH, recipient);
    }

    function registerSender(address sender) public {

        _erc1820.setInterfaceImplementer(address(this), _TOKENS_SENDER_INTERFACE_HASH, sender);
    }

    receive () external payable {
        emit EthTransaction(msg.sender, address(this), msg.value);
    }

    function tokensReceived(
        address operator,
        address from,
        address to,
        uint256 amount,
        bytes calldata userData,
        bytes calldata operatorData
    ) senderIsImty external override(IERC777Recipient) {

        emit ImtyTransaction(operator, from, to, amount, userData, operatorData);
    }

    function tokensToSend(
        address operator,
        address from,
        address to,
        uint256 amount,
        bytes calldata userData,
        bytes calldata operatorData
    ) senderIsImty external override {

        emit ImtyTransaction(operator, from, to, amount, userData, operatorData);
    }

    function setTokenContract (address _tokenAddress) onlyDeployer onlyOnce("setTokenContract") external {
        require(!tokenContractSet, "Current token contract is not null");
        tokenContract = IERC777(_tokenAddress);
        tokenContractSet = true;
    }

    function getImtyBalance () public view returns (uint) {
        return tokenContract.balanceOf(address(this));
    }

    function getEthBalance () public view returns (uint) {
        address payable self = payable(address(this));
        return self.balance;
    }

    function _ethTransfer (address payable to, uint amount) internal {
        Address.sendValue(to, amount);
        emit EthTransaction(address(this), to, amount);
    }

    function _imtyTransfer (address payable to, uint amount) internal {
        tokenContract.send(to, amount, "");
    }

    function crowdsaleAllowance (address _crowdsaleAddress) onlyDeployer onlyOnce("crowdsaleAllowance") external returns (bool) {
        return IERC20(address(tokenContract)).approve(_crowdsaleAddress, 780000000 * (10 ** 18));
    }
}pragma solidity ^0.6.0;


contract SetOperator is Wallet, ReentrancyGuard {

    address signerOne;
    address signerTwo;

    address operator;

    event NewOperatorVote ();
    event AuthorizedOperator (address operator);
    event RevokedOperator (address operator);

    address[] public operators;

    bool public operatorVoteOne;
    bool public operatorVoteTwo;
    address public operatorVoteAddress;

    bool firstOperator = false;

   constructor (address _signerOne, address _signerTwo, address _tokenContract) public {
        signerOne = _signerOne;
        signerTwo = _signerTwo;
        tokenContract = IERC777(_tokenContract);
    }

    function getOperators () external view returns (address[] memory) {
        return operators;
    } //TODO: Check if works

    function setDefaultOperators(address[] memory _defaultOperators) external onlyOnce("assignFirstOperator") onlyDeployer {

        require(firstOperator == false, "Can only be ran once!");

        for (uint i = 0; i < _defaultOperators.length; i++) {
            _authorizeOperator(_defaultOperators[i]);
            emit AuthorizedOperator(_defaultOperators[i]);
        }

        firstOperator = true;
    }

    function revokeOperator (address _operator) isSigner external returns (address[] memory){
        uint i = 0;
        for (;i < operators.length; i++) {
            if (_operator == operators[i]) {
                break;
            }
            if (i == operators.length - 1) {
                revert("Address is not an operator");
            }
        }
        tokenContract.revokeOperator(_operator);
        _removeOperator(i);
        emit RevokedOperator(_operator);

        return operators;
    }

    function _removeOperator (uint index) private {
        if (index >= operators.length) {
             require(false, "index out of bounds");
        }

        for (uint i = index; i < operators.length-1; i++){
            operators[i] = operators[i+1];
        }
        operators.pop();
    }

    function _authorizeOperator (address _operator) private {
        tokenContract.authorizeOperator(_operator);
        operators.push(_operator);

        emit AuthorizedOperator(_operator);
    }

    function createOperatorVote (address _operator) external isSigner {
        operatorVoteAddress = _operator;
        operatorVoteOne = msg.sender == signerOne;
        operatorVoteTwo = msg.sender == signerTwo;

        emit NewOperatorVote();
    }

    function approveOperatorVote () external nonReentrant isSigner {
        if (msg.sender == signerOne) {
            operatorVoteOne = true;
        }
        if (msg.sender == signerTwo) {
            operatorVoteTwo = true;
        }

        if (operatorVoteOne == operatorVoteTwo) {
            _authorizeOperator(operatorVoteAddress);
        }
    }

    modifier isSigner () {

        require(msg.sender == signerOne || msg.sender == signerTwo, "Not allowed");
        _;
    }
} 

contract MultiSigWallet is SetOperator {

    uint public currentPaymentId = 0;

    event UpdatedPayment (uint paymentId);

    enum TxType { Eth, Imty }
    enum TxStatus { Pending, Completed }

    struct Payment {
        TxType txType;
        TxStatus txStatus;
        address payable to;
        uint amount;
        bool approvalOne;
        bool approvalTwo;
        uint creationTime;
        uint completionTime;
    }

    mapping (uint => Payment) payments;

    constructor (address _signerOne, address _signerTwo, address _tokenContract)
                ReentrancyGuard()
                SetOperator(_signerOne, _signerTwo, _tokenContract)
                public {}

    function createPayment (address _to, uint amount, TxType txType) external nonReentrant isSigner returns (uint) {
        address payable to = payable(_to);
        uint id = _createPayment(to, amount, txType);
        
        return id;
    }

    function _createPayment (address payable to, uint amount, TxType txType) private returns (uint) {
        require(amount > 0, "amount is below zero");

        currentPaymentId++;

        payments[currentPaymentId] = Payment({
            to: to,
            amount: amount,
            txType: txType,
            txStatus: TxStatus.Pending,
            creationTime: block.timestamp,
            completionTime: 0,
            approvalOne: msg.sender == signerOne,
            approvalTwo: msg.sender == signerTwo
        });

        emit UpdatedPayment(currentPaymentId);

        return currentPaymentId;
    }

    function approvePayment (uint id) external nonReentrant isSigner {
        Payment storage payment = payments[id];

        if (msg.sender == signerOne) {
            payment.approvalOne = true;
        }
        if (msg.sender == signerTwo) {
            payment.approvalTwo = true;
        }

        emit UpdatedPayment(id);
    }

    function sendPayment (uint id) external nonReentrant isSigner {
        Payment storage payment = payments[id];
        require(payment.txStatus == TxStatus.Pending, "Payment already completed");
        require(payment.approvalOne == true && payment.approvalTwo == true, "Payment has not been approved");

        if (payment.txType == TxType.Eth) {
            _ethTransfer(payment.to, payment.amount);
        }
        if (payment.txType == TxType.Imty) {
            _imtyTransfer(payment.to, payment.amount);
        }

        payment.txStatus = TxStatus.Completed;
        payment.completionTime = block.timestamp;

        emit UpdatedPayment(id);
    }

    function getPayment (uint id) external view returns (
            TxType txType,
            TxStatus txStatus,
            address to,
            uint amount,
            bool approvalOne,
            bool approvalTwo,
            uint creationTime,
            uint completionTime
    ){
        Payment memory payment = payments[id];

        txStatus = payment.txStatus;
        to = payment.to;
        amount = payment.amount;
        approvalOne = payment.approvalOne;
        approvalTwo = payment.approvalTwo;
        creationTime = payment.creationTime;
        completionTime = payment.completionTime;
    }

}