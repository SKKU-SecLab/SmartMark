

pragma solidity ^0.5.9;


library StringUtil {

    function toHash(string memory _s) internal pure returns (bytes32) {

        return keccak256(abi.encode(_s));
    }

    function isEmpty(string memory _s) internal pure returns (bool) {

        return bytes(_s).length == 0;
    }
}


pragma solidity >=0.5.0;


contract AccountCreator {

    using StringUtil for string;

    enum RequestStatus {
        Nonexistent,
        Requested,
        Confirmed,
        Failed,
        Refunded
    }

    struct AccountRequest {
        string hederaPublicKey;
        address payable requestor;
        uint256 paid;
        RequestStatus status;
    }

    mapping(bytes32 => AccountRequest) private requests;
    address public accountCreator;
    uint256 private fee;

    constructor(
        address creator, 
        uint256 accountCreationFee
    ) public {
        accountCreator = creator;
        fee = accountCreationFee;
    }

    function getAccountCreator() public view returns (address) {

        return accountCreator;
    }

    function getAccountCreationFee() external view returns (uint256) {

        return fee;
    }

    function setAccountCreationFee(uint256 feeInWei) external returns (bool) {

        require(
            msg.sender == accountCreator,
            "Only the account creator can call this function"
        );
        fee = feeInWei;
        return true;
    }

    function _createAccount(
        string memory operationId,
        string memory hederaPublicKey
    ) internal returns (bool) {

        bytes32 operationIdHash = operationId.toHash();
        AccountRequest storage request = requests[operationIdHash];

        require(!hederaPublicKey.isEmpty(), "Hedera Public Key cannot be empty");
        require(request.paid == 0, "A request with this id already exists");

        request.requestor = msg.sender;
        request.hederaPublicKey = hederaPublicKey;
        request.status = RequestStatus.Requested;
        request.paid = msg.value;

        emit CreateAccountRequest(
            operationId,
            msg.sender,
            hederaPublicKey
        );

        return true;
    }

    function createAccount(
        string calldata operationId, 
        string calldata hederaPublicKey
    ) external payable returns (bool) {

        require(
            msg.value == fee, 
            "Incorrect fee amount, call getAccountCreationFee"
        );

        address(uint160(accountCreator)).transfer(msg.value);

        return _createAccount(
            operationId,
            hederaPublicKey
        );
    }

    event CreateAccountRequest(
        string operationId, 
        address requestor, 
        string hederaPublicKey
    );
    
    function createAccountSuccess(
        string calldata operationId, 
        string calldata hederaAccountId
    ) external returns (bool) {

        require(
            msg.sender == accountCreator,
            "Only the account creator can call this function"
        );

        bytes32 operationIdHash = operationId.toHash();
        AccountRequest storage request = requests[operationIdHash];
        
        require(
            request.status == RequestStatus.Requested, 
            "Account Request must have status Requested to be set to status Confirmed"
        );
        
        request.status = RequestStatus.Confirmed;

        emit CreateAccountSuccess(
            operationId,
            request.requestor,
            request.hederaPublicKey,
            hederaAccountId
        );

        return true;
    }

    event CreateAccountSuccess(
        string operationId, 
        address requestor, 
        string hederaPublicKey, 
        string hederaAccountId
    );

    function createAccountFail(
        string calldata operationId, 
        string calldata reason
    ) external returns (bool) {

        require(
            msg.sender == accountCreator,
            "Only the account creator can call this function"
        );

        bytes32 operationIdHash = operationId.toHash();
        AccountRequest storage request = requests[operationIdHash];
        
        require(
            request.status == RequestStatus.Requested, 
            "Account Request must have status Requested to be set to status Failed"
        );
        
        request.status = RequestStatus.Failed;

        emit CreateAccountFail(
            operationId,
            request.requestor,
            request.hederaPublicKey,
            request.paid,
            reason
        );

        return true;
    }
    
    event CreateAccountFail(
        string operationId,
        address requestor,
        string hederaPublicKey,
        uint256 amount,
        string reason
    );

    function createAccountRefund(
        string calldata operationId
    ) external returns (bool) {

        require(
            msg.sender == accountCreator,
            "Only the account creator can call this function"
        );

        bytes32 operationIdHash = operationId.toHash();
        AccountRequest storage request = requests[operationIdHash];

        require(
            request.status == RequestStatus.Failed,
            "Account Request must have status Failed to be refunded"
        );

        request.status = RequestStatus.Refunded;

        emit CreateAccountRefund(operationId, request.requestor, request.paid);
        return true;
    }

    event CreateAccountRefund(
        string id, 
        address requestor, 
        uint256 refundAmountWei
    );
}


pragma solidity ^0.5.0;

interface IPayoutable {

    enum PayoutStatusCode {
        Nonexistent,
        Ordered,
        InProcess,
        FundsInSuspense,
        Executed,
        Rejected,
        Cancelled
    }

    function orderPayout(string calldata operationId, uint256 value, string calldata instructions) external returns (bool);

    function orderPayoutFrom(
        string calldata operationId,
        address walletToBePaidOut,
        uint256 value,
        string calldata instructions
    ) external returns (bool);

    function cancelPayout(string calldata operationId) external returns (bool);

    function processPayout(string calldata operationId) external returns (bool);

    function putFundsInSuspenseInPayout(string calldata operationId) external returns (bool);

    function executePayout(string calldata operationId) external returns (bool);

    function rejectPayout(string calldata operationId, string calldata reason) external returns (bool);

    function retrievePayoutData(string calldata operationId) external view returns (
        address walletToDebit,
        uint256 value,
        string memory instructions,
        PayoutStatusCode status
    );


    function authorizePayoutOperator(address operator) external returns (bool);

    function revokePayoutOperator(address operator) external returns (bool);

    function isPayoutOperatorFor(address operator, address from) external view returns (bool);


    event PayoutOrdered(address indexed orderer, string operationId, address indexed walletToDebit, uint256 value, string instructions);
    event PayoutInProcess(address indexed orderer, string operationId);
    event PayoutFundsInSuspense(address indexed orderer, string operationId);
    event PayoutExecuted(address indexed orderer, string operationId);
    event PayoutRejected(address indexed orderer, string operationId, string reason);
    event PayoutCancelled(address indexed orderer, string operationId);
    event AuthorizedPayoutOperator(address indexed operator, address indexed account);
    event RevokedPayoutOperator(address indexed operator, address indexed account);
}


pragma solidity ^0.5.0;

contract Context {

    constructor () internal { }

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

interface IHoldable {

    enum HoldStatusCode {
        Nonexistent,
        Ordered,
        Executed,
        ExecutedAndKeptOpen,
        ReleasedByNotary,
        ReleasedByPayee,
        ReleasedOnExpiration
    }

    function hold(
        string calldata operationId,
        address to,
        address notary,
        uint256 value,
        uint256 timeToExpiration
    ) external returns (bool);

    function holdFrom(
        string calldata operationId,
        address from,
        address to,
        address notary,
        uint256 value,
        uint256 timeToExpiration
    ) external returns (bool);

    function releaseHold(string calldata operationId) external returns (bool);

    function executeHold(string calldata operationId, uint256 value) external returns (bool);

    function executeHoldAndKeepOpen(string calldata operationId, uint256 value) external returns (bool);

    function renewHold(string calldata operationId, uint256 timeToExpiration) external returns (bool);

    function retrieveHoldData(string calldata operationId) external view returns (
        address from,
        address to,
        address notary,
        uint256 value,
        uint256 expiration,
        HoldStatusCode status
    );


    function balanceOnHold(address account) external view returns (uint256);

    function netBalanceOf(address account) external view returns (uint256);

    function totalSupplyOnHold() external view returns (uint256);


    function authorizeHoldOperator(address operator) external returns (bool);

    function revokeHoldOperator(address operator) external returns (bool);

    function isHoldOperatorFor(address operator, address from) external view returns (bool);


    event HoldCreated(
        address indexed holdIssuer,
        string  operationId,
        address from,
        address to,
        address indexed notary,
        uint256 value,
        uint256 expiration
    );
    event HoldExecuted(address indexed holdIssuer, string operationId, address indexed notary, uint256 heldValue, uint256 transferredValue);
    event HoldExecutedAndKeptOpen(address indexed holdIssuer, string operationId, address indexed notary, uint256 heldValue,
    uint256 transferredValue);
    event HoldReleased(address indexed holdIssuer, string operationId, HoldStatusCode status);
    event HoldRenewed(address indexed holdIssuer, string operationId, uint256 oldExpiration, uint256 newExpiration);
    event AuthorizedHoldOperator(address indexed operator, address indexed account);
    event RevokedHoldOperator(address indexed operator, address indexed account);
}


pragma solidity ^0.5.0;





contract Holdable is IHoldable, ERC20 {


    using SafeMath for uint256;
    using StringUtil for string;

    struct Hold {
        address issuer;
        address origin;
        address target;
        address notary;
        uint256 expiration;
        uint256 value;
        HoldStatusCode status;
    }

    mapping(bytes32 => Hold) internal holds;
    mapping(address => uint256) private heldBalance;
    mapping(address => mapping(address => bool)) private operators;

    uint256 private _totalHeldBalance;

    function hold(
        string memory operationId,
        address to,
        address notary,
        uint256 value,
        uint256 timeToExpiration
    ) public returns (bool)
    {

        require(to != address(0), "Payee address must not be zero address");

        emit HoldCreated(
            msg.sender,
            operationId,
            msg.sender,
            to,
            notary,
            value,
            timeToExpiration
        );

        return _hold(
            operationId,
            msg.sender,
            msg.sender,
            to,
            notary,
            value,
            timeToExpiration
        );
    }

    function holdFrom(
        string memory operationId,
        address from,
        address to,
        address notary,
        uint256 value,
        uint256 timeToExpiration
    ) public returns (bool)
    {

        require(to != address(0), "Payee address must not be zero address");
        require(from != address(0), "Payer address must not be zero address");
        require(operators[from][msg.sender], "This operator is not authorized");

        emit HoldCreated(
            msg.sender,
            operationId,
            from,
            to,
            notary,
            value,
            timeToExpiration
        );

        return _hold(
            operationId,
            msg.sender,
            from,
            to,
            notary,
            value,
            timeToExpiration
        );
    }

    function releaseHold(string memory operationId) public returns (bool) {

        Hold storage releasableHold = holds[operationId.toHash()];

        require(releasableHold.status == HoldStatusCode.Ordered || releasableHold.status == HoldStatusCode.ExecutedAndKeptOpen,"A hold can only be released in status Ordered or ExecutedAndKeptOpen");
        require(
            _isExpired(releasableHold.expiration) ||
            (msg.sender == releasableHold.notary) ||
            (msg.sender == releasableHold.target),
            "A not expired hold can only be released by the notary or the payee"
        );

        _releaseHold(operationId);

        emit HoldReleased(releasableHold.issuer, operationId, releasableHold.status);

        return true;
    }

    function executeHold(string memory operationId, uint256 value) public returns (bool) { 

        return _executeHold(operationId, value, false);
    }

    function executeHoldAndKeepOpen(string memory operationId, uint256 value) public returns (bool) {

        return _executeHold(operationId, value, true);
    }


    function _executeHold(string memory operationId, uint256 value, bool keepOpenIfHoldHasBalance) internal returns (bool) {


        Hold storage executableHold = holds[operationId.toHash()];

        require(executableHold.status == HoldStatusCode.Ordered || executableHold.status == HoldStatusCode.ExecutedAndKeptOpen,"A hold can only be executed in status Ordered or ExecutedAndKeptOpen");
        require(value != 0, "Value must be greater than zero");
        require(executableHold.notary == msg.sender, "The hold can only be executed by the notary");
        require(!_isExpired(executableHold.expiration), "The hold has already expired");
        require(value <= executableHold.value, "The value should be equal or less than the held amount");


        if (keepOpenIfHoldHasBalance && ((executableHold.value - value) > 0)) {
            _decreaseHeldBalance(operationId, value);
            _setHoldToExecutedAndKeptOpen(operationId, value); 
        }else {
            _decreaseHeldBalance(operationId, executableHold.value);
            _setHoldToExecuted(operationId, value);
        }
        
  
        

        _transfer(executableHold.origin, executableHold.target, value);

        return true;
    }


    function renewHold(string memory operationId, uint256 timeToExpiration) public returns (bool) {

        Hold storage renewableHold = holds[operationId.toHash()];

        require(renewableHold.status == HoldStatusCode.Ordered, "A hold can only be renewed in status Ordered");
        require(!_isExpired(renewableHold.expiration), "An expired hold can not be renewed");
        require(
            renewableHold.origin == msg.sender || renewableHold.issuer == msg.sender,
            "The hold can only be renewed by the issuer or the payer"
        );

        uint256 oldExpiration = renewableHold.expiration;

        if (timeToExpiration == 0) {
            renewableHold.expiration = 0;
        } else {
            renewableHold.expiration = now.add(timeToExpiration);
        }

        emit HoldRenewed(
            renewableHold.issuer,
            operationId,
            oldExpiration,
            renewableHold.expiration
        );

        return true;
    }

    function retrieveHoldData(string memory operationId) public view returns (
        address from,
        address to,
        address notary,
        uint256 value,
        uint256 expiration,
        HoldStatusCode status)
    {

        Hold storage retrievedHold = holds[operationId.toHash()];
        return (
            retrievedHold.origin,
            retrievedHold.target,
            retrievedHold.notary,
            retrievedHold.value,
            retrievedHold.expiration,
            retrievedHold.status
        );
    }

    function balanceOnHold(address account) public view returns (uint256) {

        return heldBalance[account];
    }

    function netBalanceOf(address account) public view returns (uint256) {

        return super.balanceOf(account);
    }

    function totalSupplyOnHold() public view returns (uint256) {

        return _totalHeldBalance;
    }

    function isHoldOperatorFor(address operator, address from) public view returns (bool) {

        return operators[from][operator];
    }

    function authorizeHoldOperator(address operator) public returns (bool) {

        require (operators[msg.sender][operator] == false, "The operator is already authorized");

        operators[msg.sender][operator] = true;
        emit AuthorizedHoldOperator(operator, msg.sender);
        return true;
    }

    function revokeHoldOperator(address operator) public returns (bool) {

        require (operators[msg.sender][operator] == true, "The operator is already not authorized");

        operators[msg.sender][operator] = false;
        emit RevokedHoldOperator(operator, msg.sender);
        return true;
    }

    function balanceOf(address account) public view returns (uint256) {

        return super.balanceOf(account).sub(heldBalance[account]);
    }

    function transfer(address _to, uint256 _value) public returns (bool) {

        require(balanceOf(msg.sender) >= _value, "Not enough available balance");
        return super.transfer(_to, _value);
    }

    function transferFrom(address _from, address _to, uint256 _value) public returns (bool) {

        require(balanceOf(_from) >= _value, "Not enough available balance");
        return super.transferFrom(_from, _to, _value);
    }

    function _isExpired(uint256 expiration) internal view returns (bool) {

        return expiration != 0 && (now >= expiration);
    }

    function _hold(
        string memory operationId,
        address issuer,
        address from,
        address to,
        address notary,
        uint256 value,
        uint256 timeToExpiration
    ) internal returns (bool)
    {

        Hold storage newHold = holds[operationId.toHash()];

        require(!operationId.isEmpty(), "Operation ID must not be empty");
        require(value != 0, "Value must be greater than zero");
        require(newHold.value == 0, "This operationId already exists");
        require(notary != address(0), "Notary address must not be zero address");
        require(value <= balanceOf(from), "Amount of the hold can't be greater than the balance of the origin");

        newHold.issuer = issuer;
        newHold.origin = from;
        newHold.target = to;
        newHold.notary = notary;
        newHold.value = value;
        newHold.status = HoldStatusCode.Ordered;

        if (timeToExpiration != 0) {
            newHold.expiration = now.add(timeToExpiration);
        }

        heldBalance[from] = heldBalance[from].add(value);
        _totalHeldBalance = _totalHeldBalance.add(value);

        return true;
    }

    function _releaseHold(string memory operationId) internal returns (bool) {

        Hold storage releasableHold = holds[operationId.toHash()];

        if (_isExpired(releasableHold.expiration)) {
            releasableHold.status = HoldStatusCode.ReleasedOnExpiration;
        } else {
            if (releasableHold.notary == msg.sender) {
                releasableHold.status = HoldStatusCode.ReleasedByNotary;
            } else {
                releasableHold.status = HoldStatusCode.ReleasedByPayee;
            }
        }

        heldBalance[releasableHold.origin] = heldBalance[releasableHold.origin].sub(releasableHold.value);
        _totalHeldBalance = _totalHeldBalance.sub(releasableHold.value);

        return true;
    }

    function _setHoldToExecuted(string memory operationId, uint256 value) internal {

        Hold storage executableHold = holds[operationId.toHash()];
        executableHold.status = HoldStatusCode.Executed;

        emit HoldExecuted(
            executableHold.issuer, 
            operationId,
            executableHold.notary,
            executableHold.value,
            value
        );
    }

    function _setHoldToExecutedAndKeptOpen(string memory operationId, uint256 value) internal {

        Hold storage executableHold = holds[operationId.toHash()];
        executableHold.status = HoldStatusCode.ExecutedAndKeptOpen;
        executableHold.value = executableHold.value.sub(value);

        emit HoldExecutedAndKeptOpen(
            executableHold.issuer,
            operationId,
            executableHold.notary,
            executableHold.value,
            value
            );
    }

    function _decreaseHeldBalance(string memory operationId, uint256 value) internal {

        Hold storage executableHold = holds[operationId.toHash()];
        heldBalance[executableHold.origin] = heldBalance[executableHold.origin].sub(value);
        _totalHeldBalance = _totalHeldBalance.sub(value);
    }
}


pragma solidity >=0.5.0;



contract Payoutable is IPayoutable, Holdable {


    struct OrderedPayout {
        string instructions;
        PayoutStatusCode status;
    }

    mapping(bytes32 => OrderedPayout) private orderedPayouts;
    mapping(address => mapping(address => bool)) private payoutOperators;
    address public payoutAgent;
    address public suspenseAccount;

    constructor(address _suspenseAccount) public {
        require(_suspenseAccount != address(0), "Suspense account must not be the zero address");
        suspenseAccount = _suspenseAccount;

        payoutAgent = _suspenseAccount;
    }

    function orderPayout(string calldata operationId, uint256 value, string calldata instructions) external returns (bool) {

        _orderPayout(
            msg.sender,
            operationId,
            msg.sender,
            value,
            instructions
        );

        emit PayoutOrdered(
            msg.sender,
            operationId,
            msg.sender,
            value,
            instructions
        );

        return true;
    }

    function orderPayoutFrom(
        string calldata operationId,
        address walletToBePaidOut,
        uint256 value,
        string calldata instructions
    ) external returns (bool)
    {

        require(walletToBePaidOut != address(0), "walletToBePaidOut address must not be zero address");
        require(payoutOperators[walletToBePaidOut][msg.sender], "This operator is not authorized");

        emit PayoutOrdered(
            msg.sender,
            operationId,
            walletToBePaidOut,
            value,
            instructions
        );

        return _orderPayout(
            msg.sender,
            operationId,
            walletToBePaidOut,
            value,
            instructions
        );
    }

    function cancelPayout(string calldata operationId) external returns (bool) {

        bytes32 operationIdHash = operationId.toHash();

        OrderedPayout storage cancelablePayout = orderedPayouts[operationIdHash];
        Hold storage cancelableHold = holds[operationIdHash];

        require(cancelablePayout.status == PayoutStatusCode.Ordered, "A payout can only be cancelled in status Ordered");
        require(
            msg.sender == cancelableHold.issuer || msg.sender == cancelableHold.origin,
            "A payout can only be cancelled by the orderer or the walletToBePaidOut"
        );

        _releaseHold(operationId);

        cancelablePayout.status = PayoutStatusCode.Cancelled;

        emit PayoutCancelled(
            cancelableHold.issuer,
            operationId
        );

        return true;
    }

    function processPayout(string calldata operationId) external returns (bool) {

        revert("Function not supported in this implementation");
    }

    function putFundsInSuspenseInPayout(string calldata operationId) external returns (bool) {

        revert("Function not supported in this implementation");
    }

    event PayoutFundsReady(string operationId, uint256 amount, string instructions);
    function transferPayoutToSuspenseAccount(string calldata operationId) external returns (bool) {

        bytes32 operationIdHash = operationId.toHash();

        OrderedPayout storage inSuspensePayout = orderedPayouts[operationIdHash];

        require(inSuspensePayout.status == PayoutStatusCode.Ordered, "A payout can only be set to FundsInSuspense from status Ordered");
        require(msg.sender == payoutAgent, "A payout can only be set to in suspense by the payout agent");

        Hold storage inSuspenseHold = holds[operationIdHash];

        super._transfer(inSuspenseHold.origin, inSuspenseHold.target, inSuspenseHold.value);
        super._setHoldToExecuted(operationId, inSuspenseHold.value);

        inSuspensePayout.status = PayoutStatusCode.FundsInSuspense;

        emit PayoutFundsInSuspense(
            inSuspenseHold.issuer,
            operationId
        );

        emit PayoutFundsReady(
            operationId,
            inSuspenseHold.value,
            inSuspensePayout.instructions
        );

        return true;
    }

    event PayoutFundsReturned(string operationId);
    function returnPayoutFromSuspenseAccount(string calldata operationId) external returns (bool) {

        bytes32 operationIdHash = operationId.toHash();

        OrderedPayout storage inSuspensePayout = orderedPayouts[operationIdHash];

        require(inSuspensePayout.status == PayoutStatusCode.FundsInSuspense, "A payout can only be set back to Ordered from status FundsInSuspense");
        require(msg.sender == payoutAgent, "A payout can only be set back to Ordered by the payout agent");

        Hold storage inSuspenseHold = holds[operationIdHash];

        super._transfer(inSuspenseHold.target, inSuspenseHold.origin, inSuspenseHold.value);

        inSuspensePayout.status = PayoutStatusCode.Ordered;

        emit PayoutFundsReturned(
            operationId
        );

        return true;
    }

    function executePayout(string calldata operationId) external returns (bool) {

        bytes32 operationIdHash = operationId.toHash();

        OrderedPayout storage executedPayout = orderedPayouts[operationIdHash];

        require(executedPayout.status == PayoutStatusCode.FundsInSuspense, "A payout can only be executed from status FundsInSuspense");
        require(msg.sender == payoutAgent, "A payout can only be executed by the payout agent");

        Hold storage executedHold = holds[operationIdHash];

        _releaseHold(operationId);

        _burn(executedHold.target, executedHold.value);

        executedPayout.status = PayoutStatusCode.Executed;

        emit PayoutExecuted(
            executedHold.issuer,
            operationId
        );

        return true;
    }

    function rejectPayout(string calldata operationId, string calldata reason) external returns (bool) {

        bytes32 operationIdHash = operationId.toHash();

        OrderedPayout storage rejectedPayout = orderedPayouts[operationIdHash];

        require(rejectedPayout.status == PayoutStatusCode.Ordered, "A payout can only be rejected from status Ordered");
        require(msg.sender == payoutAgent, "A payout can only be rejected by the payout agent");

        Hold storage rejectedHold = holds[operationIdHash];

        _releaseHold(operationId);

        rejectedPayout.status = PayoutStatusCode.Rejected;

        emit PayoutRejected(
            rejectedHold.issuer,
            operationId,
            reason
        );

        return true;
    }

    function retrievePayoutData(string calldata operationId) external view returns (
        address walletToDebit,
        uint256 value,
        string memory instructions,
        PayoutStatusCode status
    )
    {

        bytes32 operationIdHash = operationId.toHash();

        OrderedPayout storage retrievedPayout = orderedPayouts[operationIdHash];
        Hold storage retrievedHold = holds[operationIdHash];

        return (
            retrievedHold.origin,
            retrievedHold.value,
            retrievedPayout.instructions,
            retrievedPayout.status
        );
    }

    function isPayoutOperatorFor(address operator, address from) external view returns (bool) {

        return payoutOperators[from][operator];
    }

    function authorizePayoutOperator(address operator) external returns (bool) {

        require(payoutOperators[msg.sender][operator] == false, "The operator is already authorized");

        payoutOperators[msg.sender][operator] = true;
        emit AuthorizedPayoutOperator(operator, msg.sender);
        return true;
    }

    function revokePayoutOperator(address operator) external returns (bool) {

        require(payoutOperators[msg.sender][operator], "The operator is already not authorized");

        payoutOperators[msg.sender][operator] = false;
        emit RevokedPayoutOperator(operator, msg.sender);
        return true;
    }

    function _orderPayout(
        address orderer,
        string memory operationId,
        address walletToBePaidOut,
        uint256 value,
        string memory instructions
    ) internal returns (bool)
    {

        OrderedPayout storage newPayout = orderedPayouts[operationId.toHash()];

        require(!instructions.isEmpty(), "Instructions must not be empty");

        newPayout.instructions = instructions;
        newPayout.status = PayoutStatusCode.Ordered;

        return _hold(
            operationId,
            orderer,
            walletToBePaidOut,
            suspenseAccount,
            payoutAgent,
            value,
            0
        );
    }
}


pragma solidity >=0.5.0;



contract wHBAR is Payoutable, AccountCreator {

    string _name;
    string _symbol;
    uint8 _decimals;

    address _owner;

    uint256 _accountCreateFee;
    
    constructor(
        string memory __name,
        string memory __symbol,
        uint8 __decimals,
        address __customOwner

    )
    public
    Payoutable(__customOwner) 
    AccountCreator(__customOwner, 50000000000000) 
    { // AccountCreator ERC20 Holdable SafeMath, 50k gwei hedera account creation fee
        _name = __name;
        _symbol = __symbol;
        _decimals = __decimals;
        _owner = __customOwner;
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

    function owner() public view returns (address) {

        return _owner;
    }

    function mint(address to, uint256 amount) public returns (bool) {

        require(_msgSender() == _owner, "unauthorized");
        super._mint(to, amount);
        return true;
    }
}