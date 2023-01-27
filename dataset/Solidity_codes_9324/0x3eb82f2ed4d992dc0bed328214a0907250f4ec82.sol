
pragma solidity 0.8.3;

contract Ownable {

    address internal _owner;

    event OwnershipTransferred(address previousOwner, address newOwner);

    constructor (address addr) {
        require(addr != address(0), "non-zero address required");
        require(addr != address(1), "ecrecover address not allowed");
        _owner = addr;
        emit OwnershipTransferred(address(0), addr);
    }

    modifier onlyOwner() {

        require(isOwner(msg.sender), "Only owner requirement");
        _;
    }

    function transferOwnership (address addr) public onlyOwner {
        require(addr != address(0), "non-zero address required");
        emit OwnershipTransferred(_owner, addr);
        _owner = addr;
    }

    function destroy(address payable addr) public virtual onlyOwner {

        require(addr != address(0), "non-zero address required");
        require(addr != address(1), "ecrecover address not allowed");
        selfdestruct(addr);
    }

    function owner() public view returns (address) {

        return _owner;
    }

    function isOwner(address addr) public view returns (bool) {

        return addr == _owner;
    }
}

interface IERC20 {

    function transfer(address to, uint256 value) external returns (bool);


    function transferFrom(address from, address to, uint256 value) external returns (bool);


    function approve(address spender, uint256 value) external returns (bool);


    function totalSupply() external view returns (uint256);


    function decimals() external view returns (uint8);

    function name() external view returns (string memory);

    function symbol() external view returns (string memory);


    function balanceOf(address addr) external view returns (uint256);


    function allowance(address owner, address spender) external view returns (uint256);


    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}

contract ERC20 is IERC20 {

    string private _name;
    string private _symbol;
    uint8 private _decimals;
    uint256 internal _totalSupply;

    mapping(address => uint256) internal _balances;

    mapping(address => mapping(address => uint256)) private _allowances;

    constructor (string memory tokenName, string memory tokenSymbol, uint8 tokenDecimals, uint256 initialSupply) {
        _name = tokenName;
        _symbol = tokenSymbol;
        _decimals = tokenDecimals;
        _totalSupply = initialSupply;
    }

    function executeErc20Transfer (address from, address to, uint256 value) private returns (bool) {
        require(to != address(0), "non-zero address required");
        require(from != address(0), "non-zero sender required");
        require(value > 0, "Amount cannot be zero");
        require(_balances[from] >= value, "Amount exceeds sender balance");

        _balances[from] = _balances[from] - value;
        _balances[to] = _balances[to] + value;

        emit Transfer(from, to, value);

        return true;
    }

    function approveSpender(address ownerAddr, address spender, uint256 value) private returns (bool) {

        require(spender != address(0), "non-zero spender required");
        require(ownerAddr != address(0), "non-zero owner required");

        _allowances[ownerAddr][spender] = value;

        emit Approval(ownerAddr, spender, value);

        return true;
    }

    function transfer(address to, uint256 value) public override returns (bool) {

        require (executeErc20Transfer(msg.sender, to, value), "Failed to execute ERC20 transfer");
        return true;
    }

    function transferFrom(address from, address to, uint256 value) public override returns (bool) {

        require (executeErc20Transfer(from, to, value), "Failed to execute transferFrom");

        uint256 currentAllowance = _allowances[from][msg.sender];
        require(currentAllowance >= value, "Amount exceeds allowance");

        require(approveSpender(from, msg.sender, currentAllowance - value), "ERC20: Approval failed");

        return true;
    }

    function approve(address spender, uint256 value) public override returns (bool) {

        require(approveSpender(msg.sender, spender, value), "ERC20: Approval failed");
        return true;
    }

    function totalSupply() public view override returns (uint256) {

        return _totalSupply;
    }

    function name() public view override returns (string memory) {

        return _name;
    }

    function symbol() public view override returns (string memory) {

        return _symbol;
    }

    function decimals() public view override returns (uint8) {

        return _decimals;
    }

    function balanceOf(address addr) public view override returns (uint256) {

        return _balances[addr];
    }

    function allowance(address owner, address spender) public view override returns (uint256) {

        return _allowances[owner][spender];
    }
}

contract Mintable is ERC20, Ownable {

    uint256 public maxSupply;

    mapping (address => bool) internal _authorizedMinters;

    mapping (address => bool) internal _authorizedBurners;

    event OnMinterGranted(address addr);

    event OnMinterRevoked(address addr);

    event OnBurnerGranted(address addr);

    event OnBurnerRevoked(address addr);

    event OnMaxSupplyChanged(uint256 prevValue, uint256 newValue);

    constructor (address newOwner, string memory tokenName, string memory tokenSymbol, uint8 tokenDecimals, uint256 initialSupply)
    ERC20(tokenName, tokenSymbol, tokenDecimals, initialSupply)
    Ownable(newOwner) { // solhint-disable-line no-empty-blocks
    }

    modifier onlyMinter() {

        require(_authorizedMinters[msg.sender], "Unauthorized minter");
        _;
    }

    modifier onlyBurner() {

        require(_authorizedBurners[msg.sender], "Unauthorized burner");
        _;
    }

    function grantMinter (address addr) public onlyOwner {
        require(!_authorizedMinters[addr], "Address authorized already");
        _authorizedMinters[addr] = true;
        emit OnMinterGranted(addr);
    }

    function revokeMinter (address addr) public onlyOwner {
        require(_authorizedMinters[addr], "Address was never authorized");
        _authorizedMinters[addr] = false;
        emit OnMinterRevoked(addr);
    }

    function grantBurner (address addr) public onlyOwner {
        require(!_authorizedBurners[addr], "Address authorized already");
        _authorizedBurners[addr] = true;
        emit OnBurnerGranted(addr);
    }

    function revokeBurner (address addr) public onlyOwner {
        require(_authorizedBurners[addr], "Address was never authorized");
        _authorizedBurners[addr] = false;
        emit OnBurnerRevoked(addr);
    }

    function changeMaxSupply (uint256 newValue) public onlyOwner {
        require(newValue == 0 || newValue > _totalSupply, "Invalid max supply");
        emit OnMaxSupplyChanged(maxSupply, newValue);
        maxSupply = newValue;
    }

    function mint (address addr, uint256 amount) public onlyMinter {
        require(addr != address(0) && addr != address(this), "Invalid address");
        require(amount > 0, "Invalid amount");
        require(canMint(amount), "Max token supply exceeded");

        _totalSupply += amount;
        _balances[addr] += amount;
        emit Transfer(address(0), addr, amount);
    }

    function burn (address addr, uint256 amount) public onlyBurner {
        require(addr != address(0) && addr != address(this), "Invalid address");
        require(amount > 0, "Invalid amount");
        require(_totalSupply > 0, "No token supply");

        uint256 accountBalance = _balances[addr];
        require(accountBalance >= amount, "Burn amount exceeds balance");

        _balances[addr] = accountBalance - amount;
        _totalSupply -= amount;
        emit Transfer(addr, address(0), amount);
    }

    function canMint (uint256 amount) public view returns (bool) {
        return (maxSupply == 0) || (_totalSupply + amount <= maxSupply);
    }
}

contract Controllable is Ownable {

    address internal _controllerAddress;

    constructor (address ownerAddr, address controllerAddr) Ownable (ownerAddr) {
        require(controllerAddr != address(0), "Controller address required");
        require(controllerAddr != ownerAddr, "Owner cannot be the Controller");
        _controllerAddress = controllerAddr;
    }

    modifier onlyController() {

        require(msg.sender == _controllerAddress, "Unauthorized controller");
        _;
    }

    modifier onlyOwnerOrController() {

        require(msg.sender == _controllerAddress || msg.sender == _owner, "Only owner or controller");
        _;
    }

    function setController (address controllerAddr) public onlyOwner {
        require(controllerAddr != address(0), "Controller address required");
        require(controllerAddr != _owner, "Owner cannot be the Controller");
        require(controllerAddr != _controllerAddress, "Controller already set");

        _controllerAddress = controllerAddr;
    }

    function getControllerAddress () public view returns (address) {
        return _controllerAddress;
    }
}


contract ReceiptToken is Mintable {

    constructor (address newOwner, uint256 initialMaxSupply) Mintable(newOwner, "Fractal Protocol Vault Token", "USDF", 6, 0) {
        maxSupply = initialMaxSupply;
    }
}


library Utils {

    function isContract (address addr) internal view returns (bool) {
        bytes32 eoaHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;

        bytes32 codeHash;

        assembly { codeHash := extcodehash(addr) }

        return (codeHash != eoaHash && codeHash != 0x0);
    }
}


library DateUtils {

    uint256 internal constant SECONDS_PER_DAY = 24 * 60 * 60;

    uint256 internal constant SECONDS_PER_HOUR = 60 * 60;

    uint256 internal constant SECONDS_PER_MINUTE = 60;

    int256 internal constant OFFSET19700101 = 2440588;

    function getYear (uint256 timestamp) internal pure returns (uint256 year) {
        (year,,) = _daysToDate(timestamp / SECONDS_PER_DAY);
    }

    function timestampFromDateTime(uint256 year, uint256 month, uint256 day, uint256 hour, uint256 minute, uint256 second) internal pure returns (uint256 timestamp) {

        timestamp = _daysFromDate(year, month, day) * SECONDS_PER_DAY + hour * SECONDS_PER_HOUR + minute * SECONDS_PER_MINUTE + second;
    }

    function diffDays (uint256 fromTimestamp, uint256 toTimestamp) internal pure returns (uint256) {
        require(fromTimestamp <= toTimestamp, "Invalid order for timestamps");
        return (toTimestamp - fromTimestamp) / SECONDS_PER_DAY;
    }

    function _daysToDate (uint256 _days) internal pure returns (uint256 year, uint256 month, uint256 day) {
        int256 __days = int256(_days);

        int256 x = __days + 68569 + OFFSET19700101;
        int256 n = 4 * x / 146097;
        x = x - (146097 * n + 3) / 4;
        int256 _year = 4000 * (x + 1) / 1461001;
        x = x - 1461 * _year / 4 + 31;
        int256 _month = 80 * x / 2447;
        int256 _day = x - 2447 * _month / 80;
        x = _month / 11;
        _month = _month + 2 - 12 * x;
        _year = 100 * (n - 49) + _year + x;

        year = uint256(_year);
        month = uint256(_month);
        day = uint256(_day);
    }

    function _daysFromDate (uint256 year, uint256 month, uint256 day) internal pure returns (uint256 _days) {
        require(year >= 1970, "Error");
        int _year = int(year);
        int _month = int(month);
        int _day = int(day);

        int __days = _day
          - 32075
          + 1461 * (_year + 4800 + (_month - 14) / 12) / 4
          + 367 * (_month - 2 - (_month - 14) / 12 * 12) / 12
          - 3 * ((_year + 4900 + (_month - 14) / 12) / 100) / 4
          - OFFSET19700101;

        _days = uint256(__days);
    }
}

interface IDeployable {

    function deployCapital (uint256 deploymentAmount, bytes32 foreignNetwork) external;
    function claim (uint256 dailyInterestAmount) external;
}


contract Vault is Controllable {

    uint256 private constant USDF_DECIMAL_MULTIPLIER = uint256(10) ** uint256(6);

    struct Record {
        uint8 apr;
        uint256 tokenPrice;
        uint256 totalDeposited;
        uint256 dailyInterest;
    }

    uint256 public startOfYearTimestamp;

    uint256 public currentPeriod;

    uint256 public minDepositAmount;

    uint256 public flatFeePercent;

    uint256 immutable private _decimalsMultiplier;

    uint256 immutable private _decimalsMultiplierOfReceiptToken;

    uint8 public investmentPercent = 90;

    uint8 private _reentrancyMutexForDeposits;

    uint8 private _reentrancyMutexForWithdrawals;

    address public yieldReserveAddress;

    address public feesAddress;

    IERC20 public immutable tokenInterface;

    ReceiptToken private immutable _receiptToken;

    mapping (uint256 => Record) private _records;

    event OnVaultDeposit (address tokenAddress, address fromAddress, uint256 depositAmount, uint256 receiptTokensAmount);

    event OnVaultWithdrawal (address tokenAddress, address toAddress, uint256 erc20Amount, uint256 receiptTokensAmount, uint256 fee);

    constructor (
        address ownerAddr, 
        address controllerAddr, 
        ReceiptToken receiptTokenInterface, 
        IERC20 eip20Interface, 
        uint8 initialApr, 
        uint256 initialTokenPrice, 
        uint256 initialMinDepositAmount,
        uint256 flatFeePerc,
        address feesAddr) 
    Controllable (ownerAddr, controllerAddr) {
        require(initialMinDepositAmount > 0, "Invalid min deposit amount");
        require(feesAddr != address(0), "Invalid address for fees");

        tokenInterface = eip20Interface;
        _receiptToken = receiptTokenInterface;
        minDepositAmount = initialMinDepositAmount;
        _decimalsMultiplier = uint256(10) ** uint256(eip20Interface.decimals());
        _decimalsMultiplierOfReceiptToken = uint256(10) ** uint256(receiptTokenInterface.decimals());

        uint256 currentTimestamp = block.timestamp; // solhint-disable-line not-rely-on-time

        uint256 currentYear = DateUtils.getYear(currentTimestamp);

        startOfYearTimestamp = DateUtils.timestampFromDateTime(currentYear, 1, 1, 0, 0, 0);

        currentPeriod = DateUtils.diffDays(startOfYearTimestamp, currentTimestamp);
        
        _records[currentPeriod] = Record(initialApr, initialTokenPrice, 0, 0);

        flatFeePercent = flatFeePerc;
        feesAddress = feesAddr;
    }

    modifier ifNotReentrantDeposit() {

        require(_reentrancyMutexForDeposits == 0, "Reentrant deposit rejected");
        _;
    }

    modifier ifNotReentrantWithdrawal() {

        require(_reentrancyMutexForWithdrawals == 0, "Reentrant withdrawal rejected");
        _;
    }

    function setYieldReserveAddress (address addr) public onlyOwnerOrController {
        require(addr != address(0) && addr != address(this), "Invalid address");
        require(Utils.isContract(addr), "The address must be a contract");

        yieldReserveAddress = addr;
    }

    function setMinDepositAmount (uint256 minAmount) public onlyOwnerOrController {
        require(minAmount > 0, "Invalid minimum deposit amount");

        minDepositAmount = minAmount;
    }

    function setFlatWithdrawalFee (uint256 newFeeWithMultiplier) public onlyOwnerOrController {
        flatFeePercent = newFeeWithMultiplier;
    }

    function setFeeAddress (address addr) public onlyOwnerOrController {
        require(addr != address(0) && addr != feesAddress, "Invalid address for fees");
        feesAddress = addr;
    }

    function deposit (uint256 depositAmount) public ifNotReentrantDeposit {
        require(depositAmount >= minDepositAmount, "Minimum deposit amount not met");

        _reentrancyMutexForDeposits = 1;

        compute();

        address senderAddr = msg.sender;

        require(tokenInterface.balanceOf(senderAddr) >= depositAmount, "Insufficient funds");

        require(tokenInterface.allowance(senderAddr, address(this)) >= depositAmount, "Insufficient allowance");

        uint256 numberOfReceiptTokens = depositAmount * _decimalsMultiplierOfReceiptToken / _records[currentPeriod].tokenPrice;

        require(_receiptToken.canMint(numberOfReceiptTokens), "Token supply limit exceeded");

        _records[currentPeriod].totalDeposited += depositAmount;

        uint256 balanceBeforeTransfer = tokenInterface.balanceOf(address(this));

        require(tokenInterface.transferFrom(senderAddr, address(this), depositAmount), "Token transfer failed");

        uint256 newBalance = tokenInterface.balanceOf(address(this));

        require(newBalance >= balanceBeforeTransfer + depositAmount, "Balance verification failed");

        _receiptToken.mint(senderAddr, numberOfReceiptTokens);

        emit OnVaultDeposit(address(tokenInterface), senderAddr, depositAmount, numberOfReceiptTokens);

        _reentrancyMutexForDeposits = 0;
    }

    function withdraw (uint256 receiptTokenAmount) public ifNotReentrantWithdrawal {
        require(receiptTokenAmount > 0, "Invalid withdrawal amount");

        _reentrancyMutexForWithdrawals = 1;

        address senderAddr = msg.sender;

        compute();

        require(_receiptToken.balanceOf(senderAddr) >= receiptTokenAmount, "Insufficient balance of tokens");

        uint256 withdrawalAmount = toErc20Amount(receiptTokenAmount);
        require(withdrawalAmount <= _records[currentPeriod].totalDeposited, "Invalid withdrawal amount");

        uint256 maxWithdrawalAmount = getMaxWithdrawalAmount();
        require(withdrawalAmount <= maxWithdrawalAmount, "Max withdrawal amount exceeded");

        uint256 currentBalance = tokenInterface.balanceOf(address(this));
        require(currentBalance > withdrawalAmount, "Insufficient funds in the buffer");

        uint256 feeAmount = (flatFeePercent > 0) ? withdrawalAmount * flatFeePercent / uint256(100) / _decimalsMultiplier : 0;
        require(feeAmount < withdrawalAmount, "Invalid fee");

        uint256 withdrawalAmountAfterFees = withdrawalAmount - feeAmount;

        _records[currentPeriod].totalDeposited -= withdrawalAmount;

        _receiptToken.burn(senderAddr, receiptTokenAmount);

        require(tokenInterface.transfer(senderAddr, withdrawalAmountAfterFees), "Token transfer failed");

        if (feeAmount > 0) {
            require(tokenInterface.transfer(feesAddress, feeAmount), "Fee transfer failed");
        }

        emit OnVaultWithdrawal(address(tokenInterface), senderAddr, withdrawalAmount, receiptTokenAmount, feeAmount);

        _reentrancyMutexForWithdrawals = 0; // solhint-disable-line reentrancy
    }

    function emergencyWithdraw (address destinationAddr) public onlyOwner ifNotReentrantWithdrawal {
        require(destinationAddr != address(0) && destinationAddr != address(this), "Invalid address");

        _reentrancyMutexForWithdrawals = 1;

        uint256 currentBalance = tokenInterface.balanceOf(address(this));
        require(currentBalance > 0, "The vault has no funds");

        require(tokenInterface.transfer(destinationAddr, currentBalance), "Token transfer failed");

        _reentrancyMutexForWithdrawals = 0; // solhint-disable-line reentrancy
    }

    function changeApr (uint8 newApr) public onlyOwner {
        require(newApr > 0, "Invalid APR");

        compute();
        _records[currentPeriod].apr = newApr;
    }

    function setTokenPrice (uint256 newTokenPrice) public onlyOwner {
        require(newTokenPrice > 0, "Invalid token price");

        compute();
        _records[currentPeriod].tokenPrice = newTokenPrice;
    }

    function setInvestmentPercent (uint8 newPercent) public onlyOwnerOrController {
        require(newPercent > 0 && newPercent < 100, "Invalid investment percent");
        investmentPercent = newPercent;
    }

    function compute () public {
        uint256 currentTimestamp = block.timestamp; // solhint-disable-line not-rely-on-time

        uint256 newPeriod = DateUtils.diffDays(startOfYearTimestamp, currentTimestamp);
        if (newPeriod <= currentPeriod) return;

        uint256 x = 0;

        for (uint256 i = currentPeriod + 1; i <= newPeriod; i++) {
            x++;
            _records[i].apr = _records[i - 1].apr;
            _records[i].totalDeposited = _records[i - 1].totalDeposited;

            uint256 diff = uint256(_records[i - 1].apr) * USDF_DECIMAL_MULTIPLIER * uint256(100) / uint256(365);
            _records[i].tokenPrice = _records[i - 1].tokenPrice + (diff / uint256(10000));
            _records[i].dailyInterest = _records[i - 1].totalDeposited * uint256(_records[i - 1].apr) / uint256(365) / uint256(100);
            if (x >= 30) break;
        }

        currentPeriod += x;
    }

    function lockCapital () public onlyOwnerOrController {
        compute();

        uint256 maxDeployableAmount = getDeployableCapital();
        require(maxDeployableAmount > 0, "Invalid deployable capital");

        require(tokenInterface.transfer(yieldReserveAddress, maxDeployableAmount), "Transfer failed");
    }

    function claimDailyInterest () public onlyOwnerOrController {
        compute();

        uint256 dailyInterestAmount = getDailyInterest();

        uint256 balanceBefore = tokenInterface.balanceOf(address(this));

        IDeployable(yieldReserveAddress).claim(dailyInterestAmount);

        uint256 balanceAfter = tokenInterface.balanceOf(address(this));

        require(balanceAfter >= balanceBefore + dailyInterestAmount, "Balance verification failed");
    }

    function getPeriodOfCurrentEpoch () public view returns (uint256) {
        return DateUtils.diffDays(startOfYearTimestamp, block.timestamp); // solhint-disable-line not-rely-on-time
    }

    function getSnapshot (uint256 i) public view returns (uint8 apr, uint256 tokenPrice, uint256 totalDeposited, uint256 dailyInterest) {
        apr = _records[i].apr;
        tokenPrice = _records[i].tokenPrice;
        totalDeposited = _records[i].totalDeposited;
        dailyInterest = _records[i].dailyInterest;
    }

    function getTotalDeposited () public view returns (uint256) {
        return _records[currentPeriod].totalDeposited;
    }

    function getDailyInterest () public view returns (uint256) {
        return _records[currentPeriod].dailyInterest;
    }

    function getTokenPrice () public view returns (uint256) {
        return _records[currentPeriod].tokenPrice;
    }

    function getMaxWithdrawalAmount () public view returns (uint256) {
        return tokenInterface.balanceOf(address(this)) * (uint256(100) - uint256(investmentPercent)) / uint256(100);
    }

    function getDeployableCapital () public view returns (uint256) {
        return tokenInterface.balanceOf(address(this)) * uint256(investmentPercent) / uint256(100);
    }

    function toErc20Amount (uint256 receiptTokenAmount) public view returns (uint256) {
        return receiptTokenAmount * _records[currentPeriod].tokenPrice / _decimalsMultiplierOfReceiptToken;
    }
}