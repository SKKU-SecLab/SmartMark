
pragma solidity 0.4.24;



pragma solidity 0.4.24;


contract Restricted {


    mapping (address => mapping (bytes32 => bool)) public permissions;

    event PermissionGranted(address indexed agent, bytes32 grantedPermission);
    event PermissionRevoked(address indexed agent, bytes32 revokedPermission);

    modifier restrict(bytes32 requiredPermission) {

        require(permissions[msg.sender][requiredPermission], "msg.sender must have permission");
        _;
    }

    constructor(address permissionGranterContract) public {
        require(permissionGranterContract != address(0), "permissionGranterContract must be set");
        permissions[permissionGranterContract]["PermissionGranter"] = true;
        emit PermissionGranted(permissionGranterContract, "PermissionGranter");
    }

    function grantPermission(address agent, bytes32 requiredPermission) public {

        require(permissions[msg.sender]["PermissionGranter"],
            "msg.sender must have PermissionGranter permission");
        permissions[agent][requiredPermission] = true;
        emit PermissionGranted(agent, requiredPermission);
    }

    function grantMultiplePermissions(address agent, bytes32[] requiredPermissions) public {

        require(permissions[msg.sender]["PermissionGranter"],
            "msg.sender must have PermissionGranter permission");
        uint256 length = requiredPermissions.length;
        for (uint256 i = 0; i < length; i++) {
            grantPermission(agent, requiredPermissions[i]);
        }
    }

    function revokePermission(address agent, bytes32 requiredPermission) public {

        require(permissions[msg.sender]["PermissionGranter"],
            "msg.sender must have PermissionGranter permission");
        permissions[agent][requiredPermission] = false;
        emit PermissionRevoked(agent, requiredPermission);
    }

    function revokeMultiplePermissions(address agent, bytes32[] requiredPermissions) public {

        uint256 length = requiredPermissions.length;
        for (uint256 i = 0; i < length; i++) {
            revokePermission(agent, requiredPermissions[i]);
        }
    }

}


pragma solidity 0.4.24;


library SafeMath {

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {

        uint256 c = a * b;
        require(a == 0 || c / a == b, "mul overflow");
        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b > 0, "div by 0"); // Solidity automatically throws for div by 0 but require to emit reason
        uint256 c = a / b;
        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b <= a, "sub underflow");
        return a - b;
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {

        uint256 c = a + b;
        require(c >= a, "add overflow");
        return c;
    }

    function roundedDiv(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b > 0, "div by 0"); // Solidity automatically throws for div by 0 but require to emit reason
        uint256 halfB = (b % 2 == 0) ? (b / 2) : (b / 2 + 1);
        return (a % b >= halfB) ? (a / b + 1) : (a / b);
    }

    function ceilDiv(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b > 0, "div by 0"); // Solidity automatically throws for div by 0 but require to emit reason
        return (a % b != 0) ? (a / b + 1) : (a / b);
    }

    function min(uint256 a, uint256 b) internal pure returns (uint256) {

        return a < b ? a : b;
    }

    function max(uint256 a, uint256 b) internal pure returns (uint256) {

        return a < b ? b : a;
    }    
}


pragma solidity 0.4.24;


interface TransferFeeInterface {

    function calculateTransferFee(address from, address to, uint amount) external view returns (uint256 fee);

}


pragma solidity 0.4.24;


interface ERC20Interface {

    event Approval(address indexed _owner, address indexed _spender, uint _value);
    event Transfer(address indexed from, address indexed to, uint amount);

    function transfer(address to, uint value) external returns (bool); // solhint-disable-line no-simple-event-func-name

    function transferFrom(address from, address to, uint value) external returns (bool);

    function approve(address spender, uint value) external returns (bool);

    function balanceOf(address who) external view returns (uint);

    function allowance(address _owner, address _spender) external view returns (uint remaining);


}


pragma solidity 0.4.24;


interface TokenReceiver {

    function transferNotification(address from, uint256 amount, uint data) external;

}


pragma solidity 0.4.24;







contract AugmintTokenInterface is Restricted, ERC20Interface {

    using SafeMath for uint256;

    string public name;
    string public symbol;
    bytes32 public peggedSymbol;
    uint8 public decimals;

    uint public totalSupply;
    mapping(address => uint256) public balances; // Balances for each account
    mapping(address => mapping (address => uint256)) public allowed; // allowances added with approve()

    TransferFeeInterface public feeAccount;
    mapping(bytes32 => bool) public delegatedTxHashesUsed; // record txHashes used by delegatedTransfer

    event TransferFeesChanged(uint transferFeePt, uint transferFeeMin, uint transferFeeMax);
    event Transfer(address indexed from, address indexed to, uint amount);
    event AugmintTransfer(address indexed from, address indexed to, uint amount, string narrative, uint fee);
    event TokenIssued(uint amount);
    event TokenBurned(uint amount);
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);

    function transfer(address to, uint value) external returns (bool); // solhint-disable-line no-simple-event-func-name

    function transferFrom(address from, address to, uint value) external returns (bool);

    function approve(address spender, uint value) external returns (bool);


    function delegatedTransfer(address from, address to, uint amount, string narrative,
                                    uint maxExecutorFeeInToken, /* client provided max fee for executing the tx */
                                    bytes32 nonce, /* random nonce generated by client */
                                    bytes signature,
                                    uint requestedExecutorFeeInToken /* the executor can decide to request lower fee */
                                ) external;


    function delegatedTransferAndNotify(address from, TokenReceiver target, uint amount, uint data,
                                    uint maxExecutorFeeInToken, /* client provided max fee for executing the tx */
                                    bytes32 nonce, /* random nonce generated by client */
                                    bytes signature,
                                    uint requestedExecutorFeeInToken /* the executor can decide to request lower fee */
                                ) external;


    function increaseApproval(address spender, uint addedValue) external;

    function decreaseApproval(address spender, uint subtractedValue) external;


    function issueTo(address to, uint amount) external; // restrict it to "MonetarySupervisor" in impl.;

    function burn(uint amount) external;


    function transferAndNotify(TokenReceiver target, uint amount, uint data) external;


    function transferWithNarrative(address to, uint256 amount, string narrative) external;

    function transferFromWithNarrative(address from, address to, uint256 amount, string narrative) external;


    function setName(string _name) external;

    function setSymbol(string _symbol) external;


    function allowance(address owner, address spender) external view returns (uint256 remaining);


    function balanceOf(address who) external view returns (uint);



}



library ECRecovery {


  function recover(bytes32 hash, bytes sig)
    internal
    pure
    returns (address)
  {

    bytes32 r;
    bytes32 s;
    uint8 v;

    if (sig.length != 65) {
      return (address(0));
    }

    assembly {
      r := mload(add(sig, 32))
      s := mload(add(sig, 64))
      v := byte(0, mload(add(sig, 96)))
    }

    if (v < 27) {
      v += 27;
    }

    if (v != 27 && v != 28) {
      return (address(0));
    } else {
      return ecrecover(hash, v, r, s);
    }
  }

  function toEthSignedMessageHash(bytes32 hash)
    internal
    pure
    returns (bytes32)
  {

    return keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", hash));
  }
}


pragma solidity 0.4.24;






contract AugmintToken is AugmintTokenInterface {


    event FeeAccountChanged(TransferFeeInterface newFeeAccount);

    constructor(address permissionGranterContract, string _name, string _symbol, bytes32 _peggedSymbol, uint8 _decimals, TransferFeeInterface _feeAccount)
    public Restricted(permissionGranterContract) {
        require(_feeAccount != address(0), "feeAccount must be set");
        require(bytes(_name).length > 0, "name must be set");
        require(bytes(_symbol).length > 0, "symbol must be set");

        name = _name;
        symbol = _symbol;
        peggedSymbol = _peggedSymbol;
        decimals = _decimals;

        feeAccount = _feeAccount;

    }

    function transfer(address to, uint256 amount) external returns (bool) {

        _transfer(msg.sender, to, amount, "");
        return true;
    }

    function delegatedTransfer(address from, address to, uint amount, string narrative,
                                     uint maxExecutorFeeInToken, /* client provided max fee for executing the tx */
                                     bytes32 nonce, /* random nonce generated by client */
                                     bytes signature,
                                     uint requestedExecutorFeeInToken /* the executor can decide to request lower fee */
                                     )
    external {

        bytes32 txHash = keccak256(abi.encodePacked(this, from, to, amount, narrative, maxExecutorFeeInToken, nonce));

        _checkHashAndTransferExecutorFee(txHash, signature, from, maxExecutorFeeInToken, requestedExecutorFeeInToken);

        _transfer(from, to, amount, narrative);
    }

    function approve(address _spender, uint256 amount) external returns (bool) {

        require(_spender != 0x0, "spender must be set");
        allowed[msg.sender][_spender] = amount;
        emit Approval(msg.sender, _spender, amount);
        return true;
    }

    function increaseApproval(address _spender, uint _addedValue) external {

        require(_spender != 0x0, "spender must be set");
        mapping (address => uint256) allowances = allowed[msg.sender];
        uint newValue = allowances[_spender].add(_addedValue);
        allowances[_spender] = newValue;
        emit Approval(msg.sender, _spender, newValue);
    }

    function decreaseApproval(address _spender, uint _subtractedValue) external {

        require(_spender != 0x0, "spender must be set");
        uint oldValue = allowed[msg.sender][_spender];
        if (_subtractedValue > oldValue) {
            allowed[msg.sender][_spender] = 0;
        } else {
            allowed[msg.sender][_spender] = oldValue.sub(_subtractedValue);
        }
        emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
    }

    function transferFrom(address from, address to, uint256 amount) external returns (bool) {

        _transferFrom(from, to, amount, "");
        return true;
    }

    function issueTo(address to, uint amount) external restrict("MonetarySupervisor") {

        balances[to] = balances[to].add(amount);
        totalSupply = totalSupply.add(amount);
        emit Transfer(0x0, to, amount);
        emit AugmintTransfer(0x0, to, amount, "", 0);
    }

    function burn(uint amount) external {

        require(balances[msg.sender] >= amount, "balance must be >= amount");
        balances[msg.sender] = balances[msg.sender].sub(amount);
        totalSupply = totalSupply.sub(amount);
        emit Transfer(msg.sender, 0x0, amount);
        emit AugmintTransfer(msg.sender, 0x0, amount, "", 0);
    }

    function setFeeAccount(TransferFeeInterface newFeeAccount) external restrict("StabilityBoard") {

        feeAccount = newFeeAccount;
        emit FeeAccountChanged(newFeeAccount);
    }

    function transferAndNotify(TokenReceiver target, uint amount, uint data) external {

        _transfer(msg.sender, target, amount, "");

        target.transferNotification(msg.sender, amount, data);
    }

    function delegatedTransferAndNotify(address from, TokenReceiver target, uint amount, uint data,
                                     uint maxExecutorFeeInToken, /* client provided max fee for executing the tx */
                                     bytes32 nonce, /* random nonce generated by client */
                                     bytes signature,
                                     uint requestedExecutorFeeInToken /* the executor can decide to request lower fee */
                                     )
    external {

        bytes32 txHash = keccak256(abi.encodePacked(this, from, target, amount, data, maxExecutorFeeInToken, nonce));

        _checkHashAndTransferExecutorFee(txHash, signature, from, maxExecutorFeeInToken, requestedExecutorFeeInToken);

        _transfer(from, target, amount, "");
        target.transferNotification(from, amount, data);
    }


    function transferWithNarrative(address to, uint256 amount, string narrative) external {

        _transfer(msg.sender, to, amount, narrative);
    }

    function transferFromWithNarrative(address from, address to, uint256 amount, string narrative) external {

        _transferFrom(from, to, amount, narrative);
    }

    function setName(string _name) external restrict("StabilityBoard") {

        name = _name;
    }

    function setSymbol(string _symbol) external restrict("StabilityBoard") {

        symbol = _symbol;
    }

    function balanceOf(address _owner) external view returns (uint256 balance) {

        return balances[_owner];
    }

    function allowance(address _owner, address _spender) external view returns (uint256 remaining) {

        return allowed[_owner][_spender];
    }

    function _checkHashAndTransferExecutorFee(bytes32 txHash, bytes signature, address signer,
                                                uint maxExecutorFeeInToken, uint requestedExecutorFeeInToken) private {

        require(requestedExecutorFeeInToken <= maxExecutorFeeInToken, "requestedExecutorFee must be <= maxExecutorFee");
        require(!delegatedTxHashesUsed[txHash], "txHash already used");
        delegatedTxHashesUsed[txHash] = true;

        address recovered = ECRecovery.recover(ECRecovery.toEthSignedMessageHash(txHash), signature);
        require(recovered == signer, "invalid signature");

        _transfer(signer, msg.sender, requestedExecutorFeeInToken, "Delegated transfer fee", 0);
    }

    function _transferFrom(address from, address to, uint256 amount, string narrative) private {

        uint fee = feeAccount.calculateTransferFee(from, to, amount);
        uint amountWithFee = amount.add(fee);

        require(balances[from] >= amountWithFee, "balance must be >= amount + fee");
        require(allowed[from][msg.sender] >= amountWithFee, "allowance must be >= amount + fee");

        _transfer(from, to, amount, narrative, fee);

        allowed[from][msg.sender] = allowed[from][msg.sender].sub(amountWithFee);
    }

    function _transfer(address from, address to, uint transferAmount, string narrative) private {

        uint fee = feeAccount.calculateTransferFee(from, to, transferAmount);
        _transfer(from, to, transferAmount, narrative, fee);
    }

    function _transfer(address from, address to, uint transferAmount, string narrative, uint fee) private {

        require(to != 0x0, "to must be set");
        uint amountWithFee = transferAmount.add(fee);
        require(balances[from] >= amountWithFee, "balance must be >= amount + transfer fee");

        balances[from] = balances[from].sub(amountWithFee);
        balances[to] = balances[to].add(transferAmount);

        emit Transfer(from, to, transferAmount);

        if (fee > 0) {
            balances[feeAccount] = balances[feeAccount].add(fee);
            emit Transfer(from, feeAccount, fee);
        }

        emit AugmintTransfer(from, to, transferAmount, narrative, fee);
    }
}


pragma solidity 0.4.24;




contract SystemAccount is Restricted {

    event WithdrawFromSystemAccount(address tokenAddress, address to, uint tokenAmount, uint weiAmount,
                                    string narrative);

    constructor(address permissionGranterContract)
    public Restricted(permissionGranterContract) {} // solhint-disable-line no-empty-blocks

    function withdraw(AugmintToken tokenAddress, address to, uint tokenAmount, uint weiAmount, string narrative)
    external restrict("StabilityBoard") {

        tokenAddress.transferWithNarrative(to, tokenAmount, narrative);
        if (weiAmount > 0) {
            to.transfer(weiAmount);
        }
        emit WithdrawFromSystemAccount(tokenAddress, to, tokenAmount, weiAmount, narrative);
    }
}



pragma solidity 0.4.24;




contract AugmintReserves is Restricted {


    event ReserveMigration(address to, uint weiAmount);

    constructor(address permissionGranterContract)
    public Restricted(permissionGranterContract) {} // solhint-disable-line no-empty-blocks

    function () external payable { // solhint-disable-line no-empty-blocks
    }

    function burn(AugmintTokenInterface augmintToken, uint amount)
    external restrict("MonetarySupervisor") {

        augmintToken.burn(amount);
    }

    function migrate(address to, uint weiAmount)
    external restrict("StabilityBoard") {

        if (weiAmount > 0) {
            to.transfer(weiAmount);
        }
        emit ReserveMigration(to, weiAmount);
    }
}



pragma solidity 0.4.24;




contract InterestEarnedAccount is SystemAccount {


    constructor(address permissionGranterContract) public SystemAccount(permissionGranterContract) {} // solhint-disable-line no-empty-blocks

    function transferInterest(AugmintTokenInterface augmintToken, address locker, uint interestAmount)
    external restrict("MonetarySupervisor") {

        augmintToken.transfer(locker, interestAmount);
    }

}



pragma solidity 0.4.24;








contract MonetarySupervisor is Restricted, TokenReceiver { // solhint-disable-line no-empty-blocks

    using SafeMath for uint256;

    uint public constant PERCENT_100 = 1000000;

    AugmintTokenInterface public augmintToken;
    InterestEarnedAccount public interestEarnedAccount;
    AugmintReserves public augmintReserves;

    uint public issuedByStabilityBoard; // token issued by Stability Board
    uint public burnedByStabilityBoard; // token burned by Stability Board

    uint public totalLoanAmount; // total amount of all loans without interest, in token
    uint public totalLockedAmount; // total amount of all locks without premium, in token

    struct LtdParams {
        uint  lockDifferenceLimit; /* only allow a new lock if Loan To Deposit ratio would stay above
                                            (1 - lockDifferenceLimit) with new lock. Stored as parts per million */
        uint  loanDifferenceLimit; /* only allow a new loan if Loan To Deposit ratio would stay above
                                            (1 + loanDifferenceLimit) with new loan. Stored as parts per million */
        uint  allowedDifferenceAmount;
    }

    LtdParams public ltdParams;

    mapping(address => bool) public acceptedLegacyAugmintTokens;

    event LtdParamsChanged(uint lockDifferenceLimit, uint loanDifferenceLimit, uint allowedDifferenceAmount);

    event AcceptedLegacyAugmintTokenChanged(address augmintTokenAddress, bool newAcceptedState);

    event LegacyTokenConverted(address oldTokenAddress, address account, uint amount);

    event KPIsAdjusted(uint totalLoanAmountAdjustment, uint totalLockedAmountAdjustment);

    event SystemContractsChanged(InterestEarnedAccount newInterestEarnedAccount, AugmintReserves newAugmintReserves);

    constructor(address permissionGranterContract, AugmintTokenInterface _augmintToken,
        AugmintReserves _augmintReserves, InterestEarnedAccount _interestEarnedAccount,
        uint lockDifferenceLimit, uint loanDifferenceLimit, uint allowedDifferenceAmount)
    public Restricted(permissionGranterContract) {
        augmintToken = _augmintToken;
        augmintReserves = _augmintReserves;
        interestEarnedAccount = _interestEarnedAccount;

        ltdParams = LtdParams(lockDifferenceLimit, loanDifferenceLimit, allowedDifferenceAmount);
    }

    function issueToReserve(uint amount) external restrict("StabilityBoard") {

        issuedByStabilityBoard = issuedByStabilityBoard.add(amount);
        augmintToken.issueTo(augmintReserves, amount);
    }

    function burnFromReserve(uint amount) external restrict("StabilityBoard") {

        burnedByStabilityBoard = burnedByStabilityBoard.add(amount);
        augmintReserves.burn(augmintToken, amount);
    }

    function requestInterest(uint amountToLock, uint interestAmount) external {

        require(permissions[msg.sender]["Locker"], "msg.sender must have Locker permission");
        require(amountToLock <= getMaxLockAmountAllowedByLtd(), "amountToLock must be <= maxLockAmountAllowedByLtd");

        totalLockedAmount = totalLockedAmount.add(amountToLock);
        require(augmintToken.balanceOf(address(interestEarnedAccount)) >= interestAmount,
            "interestEarnedAccount balance must be >= interestAmount");
        interestEarnedAccount.transferInterest(augmintToken, msg.sender, interestAmount); // transfer interest to Locker
    }

    function releaseFundsNotification(uint lockedAmount) external {

        require(permissions[msg.sender]["Locker"], "msg.sender must have Locker permission");
        totalLockedAmount = totalLockedAmount.sub(lockedAmount);
    }

    function issueLoan(address borrower, uint loanAmount) external {

        require(permissions[msg.sender]["LoanManager"],
            "msg.sender must have LoanManager permission");
        require(loanAmount <= getMaxLoanAmountAllowedByLtd(), "loanAmount must be <= maxLoanAmountAllowedByLtd");
        totalLoanAmount = totalLoanAmount.add(loanAmount);
        augmintToken.issueTo(borrower, loanAmount);
    }

    function loanRepaymentNotification(uint loanAmount) external {

        require(permissions[msg.sender]["LoanManager"],
            "msg.sender must have LoanManager permission");
        totalLoanAmount = totalLoanAmount.sub(loanAmount);
    }

    function loanCollectionNotification(uint totalLoanAmountCollected) external {

        require(permissions[msg.sender]["LoanManager"],
            "msg.sender must have LoanManager permission");
        totalLoanAmount = totalLoanAmount.sub(totalLoanAmountCollected);
    }

    function setAcceptedLegacyAugmintToken(address legacyAugmintTokenAddress, bool newAcceptedState)
    external restrict("StabilityBoard") {

        acceptedLegacyAugmintTokens[legacyAugmintTokenAddress] = newAcceptedState;
        emit AcceptedLegacyAugmintTokenChanged(legacyAugmintTokenAddress, newAcceptedState);
    }

    function setLtdParams(uint lockDifferenceLimit, uint loanDifferenceLimit, uint allowedDifferenceAmount)
    external restrict("StabilityBoard") {

        ltdParams = LtdParams(lockDifferenceLimit, loanDifferenceLimit, allowedDifferenceAmount);
        emit LtdParamsChanged(lockDifferenceLimit, loanDifferenceLimit, allowedDifferenceAmount);
    }

    function adjustKPIs(uint totalLoanAmountAdjustment, uint totalLockedAmountAdjustment)
    external restrict("StabilityBoard") {

        totalLoanAmount = totalLoanAmount.add(totalLoanAmountAdjustment);
        totalLockedAmount = totalLockedAmount.add(totalLockedAmountAdjustment);
        emit KPIsAdjusted(totalLoanAmountAdjustment, totalLockedAmountAdjustment);
    }

    function setSystemContracts(InterestEarnedAccount newInterestEarnedAccount, AugmintReserves newAugmintReserves)
    external restrict("StabilityBoard") {

        interestEarnedAccount = newInterestEarnedAccount;
        augmintReserves = newAugmintReserves;
        emit SystemContractsChanged(newInterestEarnedAccount, newAugmintReserves);
    }

    function transferNotification(address from, uint amount, uint /* data, not used */ ) external {

        AugmintTokenInterface legacyToken = AugmintTokenInterface(msg.sender);
        require(acceptedLegacyAugmintTokens[legacyToken], "msg.sender must be allowed in acceptedLegacyAugmintTokens");

        legacyToken.burn(amount);
        augmintToken.issueTo(from, amount);
        emit LegacyTokenConverted(msg.sender, from, amount);
    }

    function getMaxLockAmount(uint minLockAmount, uint interestPt) external view returns (uint maxLock) {

        uint allowedByEarning = augmintToken.balanceOf(address(interestEarnedAccount)).mul(PERCENT_100).div(interestPt);
        uint allowedByLtd = getMaxLockAmountAllowedByLtd();
        maxLock = allowedByEarning < allowedByLtd ? allowedByEarning : allowedByLtd;
        maxLock = maxLock < minLockAmount ? 0 : maxLock;
    }

    function getMaxLoanAmount(uint minLoanAmount) external view returns (uint maxLoan) {

        uint allowedByLtd = getMaxLoanAmountAllowedByLtd();
        maxLoan = allowedByLtd < minLoanAmount ? 0 : allowedByLtd;
    }

    function getMaxLockAmountAllowedByLtd() public view returns(uint maxLockByLtd) {

        uint allowedByLtdDifferencePt = totalLoanAmount.mul(PERCENT_100).div(PERCENT_100
                                            .sub(ltdParams.lockDifferenceLimit));
        allowedByLtdDifferencePt = totalLockedAmount >= allowedByLtdDifferencePt ?
                                        0 : allowedByLtdDifferencePt.sub(totalLockedAmount);

        uint allowedByLtdDifferenceAmount =
            totalLockedAmount >= totalLoanAmount.add(ltdParams.allowedDifferenceAmount) ?
                0 : totalLoanAmount.add(ltdParams.allowedDifferenceAmount).sub(totalLockedAmount);

        maxLockByLtd = allowedByLtdDifferencePt > allowedByLtdDifferenceAmount ?
                                        allowedByLtdDifferencePt : allowedByLtdDifferenceAmount;
    }

    function getMaxLoanAmountAllowedByLtd() public view returns(uint maxLoanByLtd) {

        uint allowedByLtdDifferencePt = totalLockedAmount.mul(ltdParams.loanDifferenceLimit.add(PERCENT_100))
                                            .div(PERCENT_100);
        allowedByLtdDifferencePt = totalLoanAmount >= allowedByLtdDifferencePt ?
                                        0 : allowedByLtdDifferencePt.sub(totalLoanAmount);

        uint allowedByLtdDifferenceAmount =
            totalLoanAmount >= totalLockedAmount.add(ltdParams.allowedDifferenceAmount) ?
                0 : totalLockedAmount.add(ltdParams.allowedDifferenceAmount).sub(totalLoanAmount);

        maxLoanByLtd = allowedByLtdDifferencePt > allowedByLtdDifferenceAmount ?
                                        allowedByLtdDifferencePt : allowedByLtdDifferenceAmount;
    }
}


pragma solidity 0.4.24;




contract Rates is Restricted {

    using SafeMath for uint256;

    struct RateInfo {
        uint rate; // how much 1 WEI worth 1 unit , i.e. symbol/ETH rate
        uint lastUpdated;
    }

    mapping(bytes32 => RateInfo) public rates;

    event RateChanged(bytes32 symbol, uint newRate);

    constructor(address permissionGranterContract) public Restricted(permissionGranterContract) {} // solhint-disable-line no-empty-blocks

    function setRate(bytes32 symbol, uint newRate) external restrict("RatesFeeder") {

        rates[symbol] = RateInfo(newRate, now);
        emit RateChanged(symbol, newRate);
    }

    function setMultipleRates(bytes32[] symbols, uint[] newRates) external restrict("RatesFeeder") {

        require(symbols.length == newRates.length, "symobls and newRates lengths must be equal");
        for (uint256 i = 0; i < symbols.length; i++) {
            rates[symbols[i]] = RateInfo(newRates[i], now);
            emit RateChanged(symbols[i], newRates[i]);
        }
    }

    function convertFromWei(bytes32 bSymbol, uint weiValue) external view returns(uint value) {

        require(rates[bSymbol].rate > 0, "rates[bSymbol] must be > 0");
        return weiValue.mul(rates[bSymbol].rate).roundedDiv(1000000000000000000);
    }

    function convertToWei(bytes32 bSymbol, uint value) external view returns(uint weiValue) {

        require(rates[bSymbol].rate > 0, "rates[bSymbol] must be > 0");
        return value.mul(1000000000000000000).roundedDiv(rates[bSymbol].rate);
    }

}


pragma solidity 0.4.24;







contract LoanManager is Restricted, TokenReceiver {

    using SafeMath for uint256;

    enum LoanState { Open, Repaid, Defaulted, Collected } // NB: Defaulted state is not stored, only getters calculate

    struct LoanProduct {
        uint minDisbursedAmount; // 0: with decimals set in AugmintToken.decimals
        uint32 term;            // 1
        uint32 discountRate;    // 2: discountRate in parts per million , ie. 10,000 = 1%
        uint32 collateralRatio; // 3: loan token amount / colleteral pegged ccy value
        uint32 defaultingFeePt; // 4: % of collateral in parts per million , ie. 50,000 = 5%
        bool isActive;          // 5
    }

    struct LoanData {
        uint collateralAmount; // 0
        uint repaymentAmount; // 1
        address borrower; // 2
        uint32 productId; // 3
        LoanState state; // 4
        uint40 maturity; // 5
    }

    LoanProduct[] public products;

    LoanData[] public loans;
    mapping(address => uint[]) public accountLoans;  // owner account address =>  array of loan Ids

    Rates public rates; // instance of ETH/pegged currency rate provider contract
    AugmintTokenInterface public augmintToken; // instance of token contract
    MonetarySupervisor public monetarySupervisor;

    event NewLoan(uint32 productId, uint loanId, address indexed borrower, uint collateralAmount, uint loanAmount,
        uint repaymentAmount, uint40 maturity);

    event LoanProductActiveStateChanged(uint32 productId, bool newState);

    event LoanProductAdded(uint32 productId);

    event LoanRepayed(uint loanId, address borrower);

    event LoanCollected(uint loanId, address indexed borrower, uint collectedCollateral,
        uint releasedCollateral, uint defaultingFee);

    event SystemContractsChanged(Rates newRatesContract, MonetarySupervisor newMonetarySupervisor);

    constructor(address permissionGranterContract, AugmintTokenInterface _augmintToken,
                    MonetarySupervisor _monetarySupervisor, Rates _rates)
    public Restricted(permissionGranterContract) {
        augmintToken = _augmintToken;
        monetarySupervisor = _monetarySupervisor;
        rates = _rates;
    }

    function addLoanProduct(uint32 term, uint32 discountRate, uint32 collateralRatio, uint minDisbursedAmount,
                                uint32 defaultingFeePt, bool isActive)
    external restrict("StabilityBoard") {


        uint _newProductId = products.push(
            LoanProduct(minDisbursedAmount, term, discountRate, collateralRatio, defaultingFeePt, isActive)
        ) - 1;

        uint32 newProductId = uint32(_newProductId);
        require(newProductId == _newProductId, "productId overflow");

        emit LoanProductAdded(newProductId);
    }

    function setLoanProductActiveState(uint32 productId, bool newState)
    external restrict ("StabilityBoard") {

        require(productId < products.length, "invalid productId"); // next line would revert but require to emit reason
        products[productId].isActive = newState;
        emit LoanProductActiveStateChanged(productId, newState);
    }

    function newEthBackedLoan(uint32 productId) external payable {

        require(productId < products.length, "invalid productId"); // next line would revert but require to emit reason
        LoanProduct storage product = products[productId];
        require(product.isActive, "product must be in active state"); // valid product


        uint tokenValue = rates.convertFromWei(augmintToken.peggedSymbol(), msg.value);
        uint repaymentAmount = tokenValue.mul(product.collateralRatio).div(1000000);

        uint loanAmount;
        (loanAmount, ) = calculateLoanValues(product, repaymentAmount);

        require(loanAmount >= product.minDisbursedAmount, "loanAmount must be >= minDisbursedAmount");

        uint expiration = now.add(product.term);
        uint40 maturity = uint40(expiration);
        require(maturity == expiration, "maturity overflow");

        uint loanId = loans.push(LoanData(msg.value, repaymentAmount, msg.sender,
                                            productId, LoanState.Open, maturity)) - 1;

        accountLoans[msg.sender].push(loanId);

        monetarySupervisor.issueLoan(msg.sender, loanAmount);

        emit NewLoan(productId, loanId, msg.sender, msg.value, loanAmount, repaymentAmount, maturity);
    }

    function transferNotification(address, uint repaymentAmount, uint loanId) external {

        require(msg.sender == address(augmintToken), "msg.sender must be augmintToken");

        _repayLoan(loanId, repaymentAmount);
    }

    function collect(uint[] loanIds) external {

        uint totalLoanAmountCollected;
        uint totalCollateralToCollect;
        uint totalDefaultingFee;
        for (uint i = 0; i < loanIds.length; i++) {
            require(loanIds[i] < loans.length, "invalid loanId"); // next line would revert but require to emit reason
            LoanData storage loan = loans[loanIds[i]];
            require(loan.state == LoanState.Open, "loan state must be Open");
            require(now >= loan.maturity, "current time must be later than maturity");
            LoanProduct storage product = products[loan.productId];

            uint loanAmount;
            (loanAmount, ) = calculateLoanValues(product, loan.repaymentAmount);

            totalLoanAmountCollected = totalLoanAmountCollected.add(loanAmount);

            loan.state = LoanState.Collected;

            uint defaultingFeeInToken = loan.repaymentAmount.mul(product.defaultingFeePt).div(1000000);
            uint defaultingFee = rates.convertToWei(augmintToken.peggedSymbol(), defaultingFeeInToken);
            uint targetCollection = rates.convertToWei(augmintToken.peggedSymbol(),
                    loan.repaymentAmount).add(defaultingFee);

            uint releasedCollateral;
            if (targetCollection < loan.collateralAmount) {
                releasedCollateral = loan.collateralAmount.sub(targetCollection);
                loan.borrower.transfer(releasedCollateral);
            }
            uint collateralToCollect = loan.collateralAmount.sub(releasedCollateral);
            if (defaultingFee >= collateralToCollect) {
                defaultingFee = collateralToCollect;
                collateralToCollect = 0;
            } else {
                collateralToCollect = collateralToCollect.sub(defaultingFee);
            }
            totalDefaultingFee = totalDefaultingFee.add(defaultingFee);

            totalCollateralToCollect = totalCollateralToCollect.add(collateralToCollect);

            emit LoanCollected(loanIds[i], loan.borrower, collateralToCollect.add(defaultingFee),
                    releasedCollateral, defaultingFee);
        }

        if (totalCollateralToCollect > 0) {
            address(monetarySupervisor.augmintReserves()).transfer(totalCollateralToCollect);
        }

        if (totalDefaultingFee > 0) {
            address(augmintToken.feeAccount()).transfer(totalDefaultingFee);
        }

        monetarySupervisor.loanCollectionNotification(totalLoanAmountCollected);// update KPIs

    }

    function setSystemContracts(Rates newRatesContract, MonetarySupervisor newMonetarySupervisor)
    external restrict("StabilityBoard") {

        rates = newRatesContract;
        monetarySupervisor = newMonetarySupervisor;
        emit SystemContractsChanged(newRatesContract, newMonetarySupervisor);
    }

    function getProductCount() external view returns (uint) {

        return products.length;
    }

    function getProducts(uint offset, uint16 chunkSize)
    external view returns (uint[8][]) {

        uint limit = SafeMath.min(offset.add(chunkSize), products.length);
        uint[8][] memory response = new uint[8][](limit.sub(offset));

        for (uint i = offset; i < limit; i++) {
            LoanProduct storage product = products[i];
            response[i - offset] = [i, product.minDisbursedAmount, product.term, product.discountRate,
                    product.collateralRatio, product.defaultingFeePt,
                    monetarySupervisor.getMaxLoanAmount(product.minDisbursedAmount), product.isActive ? 1 : 0 ];
        }
        return response;
    }

    function getLoanCount() external view returns (uint) {

        return loans.length;
    }

    function getLoans(uint offset, uint16 chunkSize)
    external view returns (uint[10][]) {

        uint limit = SafeMath.min(offset.add(chunkSize), loans.length);
        uint[10][] memory response = new uint[10][](limit.sub(offset));

        for (uint i = offset; i < limit; i++) {
            response[i - offset] = getLoanTuple(i);
        }
        return response;
    }

    function getLoanCountForAddress(address borrower) external view returns (uint) {

        return accountLoans[borrower].length;
    }

    function getLoansForAddress(address borrower, uint offset, uint16 chunkSize)
    external view returns (uint[10][]) {

        uint[] storage loansForAddress = accountLoans[borrower];
        uint limit = SafeMath.min(offset.add(chunkSize), loansForAddress.length);
        uint[10][] memory response = new uint[10][](limit.sub(offset));

        for (uint i = offset; i < limit; i++) {
            response[i - offset] = getLoanTuple(loansForAddress[i]);
        }
        return response;
    }

    function getLoanTuple(uint loanId) public view returns (uint[10] result) {

        require(loanId < loans.length, "invalid loanId"); // next line would revert but require to emit reason
        LoanData storage loan = loans[loanId];
        LoanProduct storage product = products[loan.productId];

        uint loanAmount;
        uint interestAmount;
        (loanAmount, interestAmount) = calculateLoanValues(product, loan.repaymentAmount);
        uint disbursementTime = loan.maturity - product.term;

        LoanState loanState =
                loan.state == LoanState.Open && now >= loan.maturity ? LoanState.Defaulted : loan.state;

        result = [loanId, loan.collateralAmount, loan.repaymentAmount, uint(loan.borrower),
                loan.productId, uint(loanState), loan.maturity, disbursementTime, loanAmount, interestAmount];
    }

    function calculateLoanValues(LoanProduct storage product, uint repaymentAmount)
    internal view returns (uint loanAmount, uint interestAmount) {

        loanAmount = repaymentAmount.mul(product.discountRate).div(1000000);
        interestAmount = loanAmount > repaymentAmount ? 0 : repaymentAmount.sub(loanAmount);
    }

    function _repayLoan(uint loanId, uint repaymentAmount) internal {

        require(loanId < loans.length, "invalid loanId"); // next line would revert but require to emit reason
        LoanData storage loan = loans[loanId];
        require(loan.state == LoanState.Open, "loan state must be Open");
        require(repaymentAmount == loan.repaymentAmount, "repaymentAmount must be equal to tokens sent");
        require(now <= loan.maturity, "current time must be earlier than maturity");

        LoanProduct storage product = products[loan.productId];
        uint loanAmount;
        uint interestAmount;
        (loanAmount, interestAmount) = calculateLoanValues(product, loan.repaymentAmount);

        loans[loanId].state = LoanState.Repaid;

        if (interestAmount > 0) {
            augmintToken.transfer(monetarySupervisor.interestEarnedAccount(), interestAmount);
            augmintToken.burn(loanAmount);
        } else {
            augmintToken.burn(repaymentAmount);
        }

        monetarySupervisor.loanRepaymentNotification(loanAmount); // update KPIs

        loan.borrower.transfer(loan.collateralAmount); // send back ETH collateral

        emit LoanRepayed(loanId, loan.borrower);
    }
}



pragma solidity 0.4.24;







contract Locker is Restricted, TokenReceiver {


    using SafeMath for uint256;

    event NewLockProduct(uint32 indexed lockProductId, uint32 perTermInterest, uint32 durationInSecs,
                    uint32 minimumLockAmount, bool isActive);

    event LockProductActiveChange(uint32 indexed lockProductId, bool newActiveState);

    event NewLock(address indexed lockOwner, uint lockId, uint amountLocked, uint interestEarned,
                    uint40 lockedUntil, uint32 perTermInterest, uint32 durationInSecs);

    event LockReleased(address indexed lockOwner, uint lockId);

    event MonetarySupervisorChanged(MonetarySupervisor newMonetarySupervisor);

    struct LockProduct {
        uint32 perTermInterest;
        uint32 durationInSecs;
        uint32 minimumLockAmount;
        bool isActive;
    }

    struct Lock {
        uint amountLocked;
        address owner;
        uint32 productId;
        uint40 lockedUntil;
        bool isActive;
    }

    AugmintTokenInterface public augmintToken;
    MonetarySupervisor public monetarySupervisor;

    LockProduct[] public lockProducts;

    Lock[] public locks;

    mapping(address => uint[]) public accountLocks;

    constructor(address permissionGranterContract, AugmintTokenInterface _augmintToken,
                    MonetarySupervisor _monetarySupervisor)
    public Restricted(permissionGranterContract) {
        augmintToken = _augmintToken;
        monetarySupervisor = _monetarySupervisor;

    }

    function addLockProduct(uint32 perTermInterest, uint32 durationInSecs, uint32 minimumLockAmount, bool isActive)
    external restrict("StabilityBoard") {

        uint _newLockProductId = lockProducts.push(
                                    LockProduct(perTermInterest, durationInSecs, minimumLockAmount, isActive)) - 1;
        uint32 newLockProductId = uint32(_newLockProductId);
        require(newLockProductId == _newLockProductId, "lockProduct overflow");
        emit NewLockProduct(newLockProductId, perTermInterest, durationInSecs, minimumLockAmount, isActive);
    }

    function setLockProductActiveState(uint32 lockProductId, bool isActive) external restrict("StabilityBoard") {

        require(lockProductId < lockProducts.length, "invalid lockProductId");

        lockProducts[lockProductId].isActive = isActive;
        emit LockProductActiveChange(lockProductId, isActive);
    }

    function transferNotification(address from, uint256 amountToLock, uint _lockProductId) external {

        require(msg.sender == address(augmintToken), "msg.sender must be augmintToken");
        require(_lockProductId < lockProducts.length, "invalid lockProductId");
        uint32 lockProductId = uint32(_lockProductId);
        _createLock(lockProductId, from, amountToLock);
    }

    function releaseFunds(uint lockId) external {

        require(lockId < locks.length, "invalid lockId");
        Lock storage lock = locks[lockId];
        LockProduct storage lockProduct = lockProducts[lock.productId];

        require(lock.isActive, "lock must be in active state");
        require(now >= lock.lockedUntil, "current time must be later than lockedUntil");

        lock.isActive = false;

        uint interestEarned = calculateInterest(lockProduct.perTermInterest, lock.amountLocked);

        monetarySupervisor.releaseFundsNotification(lock.amountLocked); // to maintain totalLockAmount
        augmintToken.transferWithNarrative(lock.owner, lock.amountLocked.add(interestEarned),
                                                                                "Funds released from lock");

        emit LockReleased(lock.owner, lockId);
    }

    function setMonetarySupervisor(MonetarySupervisor newMonetarySupervisor) external restrict("StabilityBoard") {

        monetarySupervisor = newMonetarySupervisor;
        emit MonetarySupervisorChanged(newMonetarySupervisor);
    }

    function getLockProductCount() external view returns (uint) {

        return lockProducts.length;
    }

    function getLockProducts(uint offset, uint16 chunkSize)
    external view returns (uint[5][]) {

        uint limit = SafeMath.min(offset.add(chunkSize), lockProducts.length);
        uint[5][] memory response = new uint[5][](limit.sub(offset));

        for (uint i = offset; i < limit; i++) {
            LockProduct storage lockProduct = lockProducts[i];
            response[i - offset] = [lockProduct.perTermInterest, lockProduct.durationInSecs, lockProduct.minimumLockAmount,
                        monetarySupervisor.getMaxLockAmount(lockProduct.minimumLockAmount, lockProduct.perTermInterest),
                        lockProduct.isActive ? 1 : 0 ];
        }
        return response;
    }

    function getLockCount() external view returns (uint) {

        return locks.length;
    }

    function getLockCountForAddress(address lockOwner) external view returns (uint) {

        return accountLocks[lockOwner].length;
    }

    function getLocks(uint offset, uint16 chunkSize)
    external view returns (uint[8][]) {

        uint limit = SafeMath.min(offset.add(chunkSize), locks.length);
        uint[8][] memory response = new uint[8][](limit.sub(offset));

        for (uint i = offset; i < limit; i++) {
            Lock storage lock = locks[i];
            LockProduct storage lockProduct = lockProducts[lock.productId];
            uint interestEarned = calculateInterest(lockProduct.perTermInterest, lock.amountLocked);

            response[i - offset] = [uint(i), uint(lock.owner), lock.amountLocked, interestEarned, lock.lockedUntil,
                        lockProduct.perTermInterest, lockProduct.durationInSecs, lock.isActive ? 1 : 0];
        }
        return response;
    }

    function getLocksForAddress(address lockOwner, uint offset, uint16 chunkSize)
    external view returns (uint[7][]) {

        uint[] storage locksForAddress = accountLocks[lockOwner];
        uint limit = SafeMath.min(offset.add(chunkSize), locksForAddress.length);
        uint[7][] memory response = new uint[7][](limit.sub(offset));

        for (uint i = offset; i < limit; i++) {
            Lock storage lock = locks[locksForAddress[i]];
            LockProduct storage lockProduct = lockProducts[lock.productId];

            uint interestEarned = calculateInterest(lockProduct.perTermInterest, lock.amountLocked);

            response[i - offset] = [locksForAddress[i], lock.amountLocked, interestEarned, lock.lockedUntil,
                        lockProduct.perTermInterest, lockProduct.durationInSecs, lock.isActive ? 1 : 0 ];
        }
        return response;
    }

    function calculateInterest(uint32 perTermInterest, uint amountToLock) public pure returns (uint interestEarned) {

        interestEarned = amountToLock.mul(perTermInterest).ceilDiv(1000000);
    }

    function _createLock(uint32 lockProductId, address lockOwner, uint amountToLock) internal {

        LockProduct storage lockProduct = lockProducts[lockProductId];
        require(lockProduct.isActive, "lockProduct must be in active state");
        require(amountToLock >= lockProduct.minimumLockAmount, "amountToLock must be >= minimumLockAmount");

        uint interestEarned = calculateInterest(lockProduct.perTermInterest, amountToLock);
        uint expiration = now.add(lockProduct.durationInSecs);
        uint40 lockedUntil = uint40(expiration);
        require(lockedUntil == expiration, "lockedUntil overflow");

        uint lockId = locks.push(Lock(amountToLock, lockOwner, lockProductId, lockedUntil, true)) - 1;
        accountLocks[lockOwner].push(lockId);

        monetarySupervisor.requestInterest(amountToLock, interestEarned); // update KPIs & transfer interest here

        emit NewLock(lockOwner, lockId, amountToLock, interestEarned, lockedUntil, lockProduct.perTermInterest,
                    lockProduct.durationInSecs);
    }
}


pragma solidity 0.4.24;



contract MultiSig {

    using SafeMath for uint256;

    mapping(address => bool) public isSigner;
    address[] public allSigners; // all signers, even the disabled ones
    uint public activeSignersCount;

    enum ScriptState {New, Approved, Done, Cancelled, Failed}

    struct Script {
        ScriptState state;
        uint signCount;
        mapping(address => bool) signedBy;
        address[] allSigners;
    }

    mapping(address => Script) public scripts;
    address[] public scriptAddresses;

    event SignerAdded(address signer);
    event SignerRemoved(address signer);

    event ScriptSigned(address scriptAddress, address signer);
    event ScriptApproved(address scriptAddress);
    event ScriptCancelled(address scriptAddress);

    event ScriptExecuted(address scriptAddress, bool result);

    constructor() public {
        isSigner[msg.sender] = true;
        allSigners.push(msg.sender);
        activeSignersCount = 1;
        emit SignerAdded(msg.sender);
    }

    function sign(address scriptAddress) public {

        require(isSigner[msg.sender], "sender must be signer");
        Script storage script = scripts[scriptAddress];
        require(script.state == ScriptState.Approved || script.state == ScriptState.New,
                "script state must be New or Approved");
        require(!script.signedBy[msg.sender], "script must not be signed by signer yet");

        if (script.allSigners.length == 0) {
            scriptAddresses.push(scriptAddress);
        }

        script.allSigners.push(msg.sender);
        script.signedBy[msg.sender] = true;
        script.signCount = script.signCount.add(1);

        emit ScriptSigned(scriptAddress, msg.sender);

        if (checkQuorum(script.signCount)) {
            script.state = ScriptState.Approved;
            emit ScriptApproved(scriptAddress);
        }
    }

    function execute(address scriptAddress) public returns (bool result) {

        require(isSigner[msg.sender], "sender must be signer");
        Script storage script = scripts[scriptAddress];
        require(script.state == ScriptState.Approved, "script state must be Approved");

        if (scriptAddress.delegatecall.gas(gasleft() - 23000)
            (abi.encodeWithSignature("execute(address)", scriptAddress))) {
            script.state = ScriptState.Done;
            result = true;
        } else {
            script.state = ScriptState.Failed;
            result = false;
        }
        emit ScriptExecuted(scriptAddress, result);
    }

    function cancelScript(address scriptAddress) public {

        require(msg.sender == address(this), "only callable via MultiSig");
        Script storage script = scripts[scriptAddress];
        require(script.state == ScriptState.Approved || script.state == ScriptState.New,
                "script state must be New or Approved");

        script.state = ScriptState.Cancelled;

        emit ScriptCancelled(scriptAddress);
    }

    function addSigners(address[] signers) public {

        require(msg.sender == address(this), "only callable via MultiSig");
        for (uint i= 0; i < signers.length; i++) {
            if (!isSigner[signers[i]]) {
                require(signers[i] != address(0), "new signer must not be 0x0");
                activeSignersCount++;
                allSigners.push(signers[i]);
                isSigner[signers[i]] = true;
                emit SignerAdded(signers[i]);
            }
        }
    }

    function removeSigners(address[] signers) public {

        require(msg.sender == address(this), "only callable via MultiSig");
        for (uint i= 0; i < signers.length; i++) {
            if (isSigner[signers[i]]) {
                require(activeSignersCount > 1, "must not remove last signer");
                activeSignersCount--;
                isSigner[signers[i]] = false;
                emit SignerRemoved(signers[i]);
            }
        }
    }

    function checkQuorum(uint signersCount) internal view returns(bool isQuorum);


    function getAllSignersCount() view external returns (uint allSignersCount) {

        return allSigners.length;
    }

    function getSigners(uint offset, uint16 chunkSize)
    external view returns(uint[3][]) {

        uint limit = SafeMath.min(offset.add(chunkSize), allSigners.length);
        uint[3][] memory response = new uint[3][](limit.sub(offset));
        for (uint i = offset; i < limit; i++) {
            address signerAddress = allSigners[i];
            response[i - offset] = [i, uint(signerAddress), isSigner[signerAddress] ? 1 : 0];
        }
        return response;
    }

    function getScriptsCount() view external returns (uint scriptsCount) {

        return scriptAddresses.length;
    }

    function getScripts(uint offset, uint16 chunkSize)
    external view returns(uint[4][]) {

        uint limit = SafeMath.min(offset.add(chunkSize), scriptAddresses.length);
        uint[4][] memory response = new uint[4][](limit.sub(offset));
        for (uint i = offset; i < limit; i++) {
            address scriptAddress = scriptAddresses[i];
            response[i - offset] = [i, uint(scriptAddress),
                uint(scripts[scriptAddress].state), scripts[scriptAddress].signCount];
        }
        return response;
    }
}


pragma solidity 0.4.24;



contract StabilityBoardProxy is MultiSig {


    function checkQuorum(uint signersCount) internal view returns(bool isQuorum) {

        isQuorum = signersCount > activeSignersCount / 2 ;
    }
}



pragma solidity 0.4.24;





contract Main0023_interestRates {


    StabilityBoardProxy public constant STABILITY_BOARD_PROXY = StabilityBoardProxy(0xde36a8773531406dCBefFdfd3C7b89fCed7A9F84);

    LoanManager public constant LOAN_MANAGER = LoanManager(0x1cABc34618ecf2949F0405A86353e7705E01C38b);
    Locker public constant LOCKER = Locker(0x5Cc161482E82f20840A4AAEB582beCBCC4b539D7);
    MonetarySupervisor public constant MONETARY_SUPERVISOR = MonetarySupervisor(0x27484AFe9e6c332fB07F21Fac82d442EBe1D22c3);


    function execute(Main0023_interestRates /* self, not used */) external {

        require(address(this) == address(STABILITY_BOARD_PROXY), "only execute via StabilityBoardProxy");









        disableAllLoanProducts(LOAN_MANAGER);
        LOAN_MANAGER.addLoanProduct(365 days, 985222, 600000, 800, 100000, true); // 1.5% p.a.
        LOAN_MANAGER.addLoanProduct(180 days, 992658, 600000, 800, 100000, true); // 1.5% p.a.
        LOAN_MANAGER.addLoanProduct(90 days, 996315, 600000, 800, 100000, true); // 1.5% p.a.
        LOAN_MANAGER.addLoanProduct(30 days, 998769, 600000, 800, 100000, true); // 1.5% p.a.
        LOAN_MANAGER.addLoanProduct(14 days, 999425, 600000, 800, 100000, true); // 1.5% p.a.
        LOAN_MANAGER.addLoanProduct(7 days, 999713, 600000, 800, 100000, true); // 1.5% p.a.









        disableAllLockProducts(LOCKER);
        LOCKER.addLockProduct(14000, 365 days, 1000, true); // 1.4% p.a.
        LOCKER.addLockProduct(6905, 180 days, 1000, true); // 1.4% p.a.
        LOCKER.addLockProduct(3453, 90 days, 1000, true); // 1.4% p.a.
        LOCKER.addLockProduct(1151, 30 days, 1000, true); // 1.4% p.a.
        LOCKER.addLockProduct(537, 14 days, 1000, true); // 1.4% p.a.
        LOCKER.addLockProduct(269, 7 days, 1000, true); // 1.4% p.a.





        MONETARY_SUPERVISOR.setLtdParams(200000, 200000, 20000000);

    }

    function disableAllLockProducts(Locker target) internal {

        uint32 productCount = uint32(target.getLockProductCount());
        for (uint32 i = 0; i < productCount; i++) {
            uint32 perTermInterest;
            uint32 durationInSecs;
            uint32 minimumLockAmount;
            bool isActive;
            (perTermInterest, durationInSecs, minimumLockAmount, isActive) = target.lockProducts(i);
            if (isActive) {
                target.setLockProductActiveState(i, false);
            }
        }
    }

    function disableAllLoanProducts(LoanManager target) internal {

        uint32 productCount = uint32(target.getProductCount());
        for (uint32 i = 0; i < productCount; i++) {
            uint minDisbursedAmount;
            uint32 term;
            uint32 discountRate;
            uint32 collateralRatio;
            uint32 defaultingFeePt;
            bool isActive;
            (minDisbursedAmount, term, discountRate, collateralRatio, defaultingFeePt, isActive) = target.products(i);
            if (isActive) {
                target.setLoanProductActiveState(i, false);
            }
        }
    }

}