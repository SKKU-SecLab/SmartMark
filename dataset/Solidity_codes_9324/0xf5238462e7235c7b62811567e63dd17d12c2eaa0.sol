
pragma solidity 0.5.16;

contract Ownable {

    address private _owner;
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    constructor () internal {
        _owner = msg.sender;
        emit OwnershipTransferred(address(0), _owner);
    }
    function owner() public view returns (address) {

        return _owner;
    }
    modifier onlyOwner() {

        require(isOwner(), "Ownable: caller is not the owner");
        _;
    }
    function isOwner() public view returns (bool) {

        return msg.sender == _owner;
    }
    function renounceOwnership() public onlyOwner {

        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }
    function transferOwnership(address newOwner) public onlyOwner {

        _transferOwnership(newOwner);
    }
    function _transferOwnership(address newOwner) internal {

        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}
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
library SafeMath {

    function add(uint256 a, uint256 b) internal pure returns (uint256) {

        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");
        return c;
    }
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b <= a, "SafeMath: subtraction overflow");
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

        require(b > 0, "SafeMath: division by zero");
        uint256 c = a / b;
        return c;
    }
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b != 0, "SafeMath: modulo by zero");
        return a % b;
    }
}
contract LockedGoldOracle is Ownable {

  using SafeMath for uint256;
  uint256 private _lockedGold;
  address private _cacheContract;
  event LockEvent(uint256 amount);
  event UnlockEvent(uint256 amount);
  function setCacheContract(address cacheContract) external onlyOwner {

    _cacheContract = cacheContract;
  }
  function lockAmount(uint256 amountGrams) external onlyOwner {

    _lockedGold = _lockedGold.add(amountGrams);
    emit LockEvent(amountGrams);
  }
  function unlockAmount(uint256 amountGrams) external onlyOwner {

    _lockedGold = _lockedGold.sub(amountGrams);
    require(_lockedGold >= CacheGold(_cacheContract).totalCirculation());
    emit UnlockEvent(amountGrams);
  }
  function lockedGold() external view returns(uint256) {

    return _lockedGold;
  }
  function cacheContract() external view returns(address) {

    return _cacheContract;
  }
}
contract CacheGold is IERC20, Ownable {

  using SafeMath for uint256;
  string public constant name = "CACHE Gold";
  string public constant symbol = "CGT";
  uint8 public constant decimals = 8;
  uint256 private constant TOKEN = 10 ** uint256(decimals);
  uint256 private constant DAY = 86400;
  uint256 private constant YEAR = 365;
  uint256 private constant MAX_TRANSFER_FEE_BASIS_POINTS = 10;
  uint256 private constant BASIS_POINTS_MULTIPLIER = 10000;
  uint256 private constant STORAGE_FEE_DENOMINATOR = 40000000000;
  uint256 private constant INACTIVE_FEE_DENOMINATOR = 20000000000;
  uint256 private constant MIN_BALANCE_FOR_FEES = 146000;
  uint256 private _transferFeeBasisPoints = 10;
  uint256 public constant SUPPLY_CAP = 8133525786 * TOKEN;
  uint256 public constant INACTIVE_THRESHOLD_DAYS = 1095;
  mapping (address => uint256) private _balances;
  mapping (address => mapping (address => uint256)) private _allowances;
  mapping (address => uint256) private _timeStorageFeePaid;
  mapping (address => uint256) private _timeLastActivity;
  mapping (address => uint256) private _inactiveFeePaid;
  mapping (address => uint256) private _inactiveFeePerYear;
  mapping (address => bool) private _transferFeeExempt;
  mapping (address => bool) private _storageFeeExempt;
  mapping (address => uint256) private _storageFeeGracePeriod;
  uint256 private _totalSupply;
  address private _feeAddress;
  address private _backedTreasury;
  address private _unbackedTreasury;
  address private _oracle;
  address private _redeemAddress;
  address private _feeEnforcer;
  uint256 private _storageFeeGracePeriodDays = 0;
  event AddBackedGold(uint256 amount);
  event RemoveGold(uint256 amount);
  event AccountInactive(address indexed account, uint256 feePerYear);
  event AccountReActive(address indexed account);
  constructor(address unbackedTreasury,
              address backedTreasury,
              address feeAddress,
              address redeemAddress,
              address oracle) public {
    _unbackedTreasury = unbackedTreasury;
    _backedTreasury = backedTreasury;
    _feeAddress = feeAddress;
    _redeemAddress = redeemAddress;
    _feeEnforcer = owner();
    _oracle = oracle;
    setFeeExempt(_feeAddress);
    setFeeExempt(_redeemAddress);
    setFeeExempt(_backedTreasury);
    setFeeExempt(_unbackedTreasury);
    setFeeExempt(owner());
  }
  modifier onlyEnforcer() {

    require(msg.sender == _feeEnforcer);
    _;
  }
  function transfer(address to, uint256 value) external returns (bool) {

    _updateActivity(msg.sender);
    if (_shouldMarkInactive(to)) {
      _setInactive(to);
    }
    _transfer(msg.sender, to, value);
    return true;
  }
  function approve(address spender, uint256 value) external returns (bool) {

    _updateActivity(msg.sender);
    _approve(msg.sender, spender, value);
    return true;
  }
  function transferFrom(address from, address to, uint256 value) external returns (bool) {

    _updateActivity(msg.sender);
    _transfer(from, to, value);
    _approve(from, msg.sender, _allowances[from][msg.sender].sub(value));
    return true;
  }
  function increaseAllowance(address spender, uint256 addedValue) external returns (bool) {

    _updateActivity(msg.sender);
    _approve(msg.sender, spender, _allowances[msg.sender][spender].add(addedValue));
    return true;
  }
  function decreaseAllowance(address spender, uint256 subtractedValue) external returns (bool) {

    _updateActivity(msg.sender);
    _approve(msg.sender, spender, _allowances[msg.sender][spender].sub(subtractedValue));
    return true;
  }
  function addBackedTokens(uint256 value) external onlyOwner returns (bool)
  {

    uint256 unbackedBalance = _balances[_unbackedTreasury];
    uint256 lockedGrams =  LockedGoldOracle(_oracle).lockedGold();
    require(lockedGrams >= totalCirculation().add(value),
            "Insufficent grams locked in LockedGoldOracle to complete operation");
    if (value <= unbackedBalance) {
      _transfer(_unbackedTreasury, _backedTreasury, value);
    } else {
      if (unbackedBalance > 0) {
        _transfer(_unbackedTreasury, _backedTreasury, unbackedBalance);
      }
      _mint(value.sub(unbackedBalance));
    }
    emit AddBackedGold(value);
    return true;
  }
  function payStorageFee() external returns (bool) {

    _updateActivity(msg.sender);
    _payStorageFee(msg.sender);
    return true;
  }
  function setAccountInactive(address account) external onlyEnforcer returns (bool) {

    require(_shouldMarkInactive(account), "Account not eligible to be marked inactive");
    _setInactive(account);
  }
  function forcePayFees(address account) external onlyEnforcer returns(bool) {

    require(account != address(0));
    require(_balances[account] > 0,
            "Account has no balance, cannot force paying fees");
    if (isInactive(account)) {
      uint256 paid = _payInactiveFee(account);
      require(paid > 0);
    } else if (_shouldMarkInactive(account)) {
      _setInactive(account);
    } else {
      require(daysSincePaidStorageFee(account) >= YEAR,
              "Account has paid storage fees more recently than 365 days");
      uint256 paid = _payStorageFee(account);
      require(paid > 0, "No appreciable storage fees due, will refund gas");
    }
  }
  function setFeeEnforcer(address enforcer) external onlyOwner returns(bool) {

    require(enforcer != address(0));
    _feeEnforcer = enforcer;
    setFeeExempt(_feeEnforcer);
    return true;
  }
  function setFeeAddress(address newFeeAddress) external onlyOwner returns(bool) {

    require(newFeeAddress != address(0));
    require(newFeeAddress != _unbackedTreasury,
            "Cannot set fee address to unbacked treasury");
    _feeAddress = newFeeAddress;
    setFeeExempt(_feeAddress);
    return true;
  }
  function setRedeemAddress(address newRedeemAddress) external onlyOwner returns(bool) {

    require(newRedeemAddress != address(0));
    require(newRedeemAddress != _unbackedTreasury,
            "Cannot set redeem address to unbacked treasury");
    _redeemAddress = newRedeemAddress;
    setFeeExempt(_redeemAddress);
    return true;
  }
  function setBackedAddress(address newBackedAddress) external onlyOwner returns(bool) {

    require(newBackedAddress != address(0));
    require(newBackedAddress != _unbackedTreasury,
            "Cannot set backed address to unbacked treasury");
    _backedTreasury = newBackedAddress;
    setFeeExempt(_backedTreasury);
    return true;
  }
  function setUnbackedAddress(address newUnbackedAddress) external onlyOwner returns(bool) {

    require(newUnbackedAddress != address(0));
    require(newUnbackedAddress != _backedTreasury,
            "Cannot set unbacked treasury to backed treasury");
    require(newUnbackedAddress != _feeAddress,
            "Cannot set unbacked treasury to fee address ");
    require(newUnbackedAddress != _redeemAddress,
            "Cannot set unbacked treasury to fee address ");
    _unbackedTreasury = newUnbackedAddress;
    setFeeExempt(_unbackedTreasury);
    return true;
  }
  function setOracleAddress(address oracleAddress) external onlyOwner returns(bool) {

    require(oracleAddress != address(0));
    _oracle = oracleAddress;
    return true;
  }
  function setStorageFeeGracePeriodDays(uint256 daysGracePeriod) external onlyOwner {

    _storageFeeGracePeriodDays = daysGracePeriod;
  }
  function setTransferFeeExempt(address account) external onlyOwner {

    _transferFeeExempt[account] = true;
  }
  function setStorageFeeExempt(address account) external onlyOwner {

    _storageFeeExempt[account] = true;
  }
  function unsetFeeExempt(address account) external onlyOwner {

    _transferFeeExempt[account] = false;
    _storageFeeExempt[account] = false;
  }
  function setTransferFeeBasisPoints(uint256 fee) external onlyOwner {

    require(fee <= MAX_TRANSFER_FEE_BASIS_POINTS,
            "Transfer fee basis points must be an integer between 0 and 10");
    _transferFeeBasisPoints = fee;
  }
  function balanceOf(address owner) external view returns (uint256) {

    return calcSendAllBalance(owner);
  }
  function balanceOfNoFees(address owner) external view returns (uint256) {

    return _balances[owner];
  }
  function totalSupply() external view returns (uint256) {

    return _totalSupply;
  }
  function allowance(address owner, address spender) external view returns (uint256) {

    return _allowances[owner][spender];
  }
  function feeEnforcer() external view returns(address) {

    return _feeEnforcer;
  }
  function feeAddress() external view returns(address) {

    return _feeAddress;
  }
  function redeemAddress() external view returns(address) {

    return _redeemAddress;
  }
  function backedTreasury() external view returns(address) {

    return _backedTreasury;
  }
  function unbackedTreasury() external view returns(address) {

    return _unbackedTreasury;
  }
  function oracleAddress() external view returns(address) {

    return _oracle;
  }
  function storageFeeGracePeriodDays() external view returns(uint256) {

    return _storageFeeGracePeriodDays;
  }
  function transferFeeBasisPoints() external view returns(uint256) {

    return _transferFeeBasisPoints;
  }
  function simulateTransfer(address from, address to, uint256 value) external view returns (uint256[5] memory) {

    return _simulateTransfer(from, to, value);
  }
  function setFeeExempt(address account) public onlyOwner {

    _transferFeeExempt[account] = true;
    _storageFeeExempt[account] = true;
  }
  function isStorageFeeExempt(address account) public view returns(bool) {

    return _storageFeeExempt[account];
  }
  function isTransferFeeExempt(address account) public view returns(bool) {

    return _transferFeeExempt[account];
  }
  function isAllFeeExempt(address account) public view returns(bool) {

    return _transferFeeExempt[account] && _storageFeeExempt[account];
  }
  function isInactive(address account) public view returns(bool) {

    return _inactiveFeePerYear[account] > 0;
  }
  function totalCirculation() public view returns (uint256) {

    return _totalSupply.sub(_balances[_unbackedTreasury]);
  }
  function daysSincePaidStorageFee(address account) public view returns(uint256) {

    if (isInactive(account) || _timeStorageFeePaid[account] == 0) {
      return 0;
    }
    return block.timestamp.sub(_timeStorageFeePaid[account]).div(DAY);
  }
  function daysSinceActivity(address account) public view returns(uint256) {

    if (_timeLastActivity[account] == 0) {
      return 0;
    }
    return block.timestamp.sub(_timeLastActivity[account]).div(DAY);
  }
  function calcOwedFees(address account) public view returns(uint256) {

    return calcStorageFee(account).add(calcInactiveFee(account));
  }
  function calcStorageFee(address account) public view returns(uint256) {

    uint256 balance = _balances[account];
    if (isInactive(account) || isStorageFeeExempt(account) || balance == 0) {
      return 0;
    }
    uint256 daysSinceStoragePaid = daysSincePaidStorageFee(account);
    uint256 daysInactive = daysSinceActivity(account);
    uint256 gracePeriod = _storageFeeGracePeriod[account];
    if (gracePeriod > 0) {
      if (daysSinceStoragePaid > gracePeriod) {
        daysSinceStoragePaid = daysSinceStoragePaid.sub(gracePeriod);
      } else {
        daysSinceStoragePaid = 0;
      }
    }
    if (daysSinceStoragePaid == 0) {
      return 0;
    }
    if (daysInactive >= INACTIVE_THRESHOLD_DAYS) {
      daysSinceStoragePaid = daysSinceStoragePaid.sub(daysInactive.sub(INACTIVE_THRESHOLD_DAYS));
    }
    return storageFee(balance, daysSinceStoragePaid);
  }
  function calcInactiveFee(address account) public view returns(uint256) {

    uint256 balance = _balances[account];
    uint256 daysInactive = daysSinceActivity(account);
    if (isInactive(account)) {
      return _calcInactiveFee(balance,
                          daysInactive,
                          _inactiveFeePerYear[account],
                          _inactiveFeePaid[account]);
    } else if (_shouldMarkInactive(account)) {
      uint256 snapshotBalance = balance.sub(calcStorageFee(account));
      return _calcInactiveFee(snapshotBalance,                          // current balance
                              daysInactive,                             // number of days inactive
                              _calcInactiveFeePerYear(snapshotBalance), // the inactive fee per year based on balance
                              0);                                       // fees paid already
    }
    return 0;
  }
  function calcSendAllBalance(address account) public view returns (uint256) {

    require(account != address(0));
    uint256 balanceAfterStorage = _balances[account].sub(calcOwedFees(account));
    if (_transferFeeBasisPoints == 0 || isTransferFeeExempt(account)) {
      return balanceAfterStorage;
    }
    if (balanceAfterStorage <= 1) {
      return 0;
    }
    uint256 divisor = TOKEN.add(_transferFeeBasisPoints.mul(BASIS_POINTS_MULTIPLIER));
    uint256 sendAllAmount = balanceAfterStorage.mul(TOKEN).div(divisor).add(1);
    uint256 transFee = sendAllAmount.mul(_transferFeeBasisPoints).div(BASIS_POINTS_MULTIPLIER);
    if (sendAllAmount.add(transFee) > balanceAfterStorage) {
      return sendAllAmount.sub(1);
    }
    return sendAllAmount;
  }
  function calcTransferFee(address account, uint256 value) public view returns(uint256) {

    if (isTransferFeeExempt(account)) {
      return 0;
    }
    return value.mul(_transferFeeBasisPoints).div(BASIS_POINTS_MULTIPLIER);
  }
  function storageFee(uint256 balance, uint256 daysSinceStoragePaid) public pure returns(uint256) {

    uint256 fee = balance.mul(TOKEN).mul(daysSinceStoragePaid).div(YEAR).div(STORAGE_FEE_DENOMINATOR);
    if (fee > balance) {
      return balance;
    }
    return fee;
  }
  function _approve(address owner, address spender, uint256 value) internal {

    require(spender != address(0));
    require(owner != address(0));
    _allowances[owner][spender] = value;
    emit Approval(owner, spender, value);
  }
  function _transfer(address from, address to, uint256 value) internal {

    _transferRestrictions(to, from);
    uint256 storageFeeFrom = calcStorageFee(from);
    uint256 storageFeeTo = 0;
    uint256 allFeeFrom = storageFeeFrom;
    uint256 balanceFromBefore = _balances[from];
    uint256 balanceToBefore = _balances[to];
    if (from != to) {
      allFeeFrom = allFeeFrom.add(calcTransferFee(from, value));
      storageFeeTo = calcStorageFee(to);
      _balances[from] = balanceFromBefore.sub(value).sub(allFeeFrom);
      _balances[to] = balanceToBefore.add(value).sub(storageFeeTo);
      _balances[_feeAddress] = _balances[_feeAddress].add(allFeeFrom).add(storageFeeTo);
    } else {
      _balances[from] = balanceFromBefore.sub(storageFeeFrom);
      _balances[_feeAddress] = _balances[_feeAddress].add(storageFeeFrom);
    }
    emit Transfer(from, to, value);
    if (allFeeFrom > 0) {
      emit Transfer(from, _feeAddress, allFeeFrom);
      if (storageFeeFrom > 0) {
        _timeStorageFeePaid[from] = block.timestamp;
        _endGracePeriod(from);
      }
    }
    if (_timeStorageFeePaid[to] == 0) {
      _storageFeeGracePeriod[to] = _storageFeeGracePeriodDays;
      _timeLastActivity[to] = block.timestamp;
      _timeStorageFeePaid[to] = block.timestamp;
    }
    if (storageFeeTo > 0) {
      emit Transfer(to, _feeAddress, storageFeeTo);
      _timeStorageFeePaid[to] = block.timestamp;
      _endGracePeriod(to);
    } else if (balanceToBefore < MIN_BALANCE_FOR_FEES) {
      _timeStorageFeePaid[to] = block.timestamp;
    }
    if (to == _unbackedTreasury) {
      emit RemoveGold(value);
    }
  }
  function _mint(uint256 value) internal returns(bool) {

    require(_totalSupply.add(value) <= SUPPLY_CAP, "Call would exceed supply cap");
    require(_balances[_unbackedTreasury] == 0, "The unbacked treasury balance is not 0");
    _totalSupply = _totalSupply.add(value);
    _balances[_backedTreasury] = _balances[_backedTreasury].add(value);
    emit Transfer(address(0), _backedTreasury, value);
    return true;
  }
  function _payStorageFee(address account) internal returns(uint256) {

    uint256 storeFee = calcStorageFee(account);
    if (storeFee == 0) {
      return 0;
    }
    _balances[account] = _balances[account].sub(storeFee);
    _balances[_feeAddress] = _balances[_feeAddress].add(storeFee);
    emit Transfer(account, _feeAddress, storeFee);
    _timeStorageFeePaid[account] = block.timestamp;
    _endGracePeriod(account);
    return storeFee;
  }
  function _payInactiveFee(address account) internal returns(uint256) {

    uint256 fee = _calcInactiveFee(
        _balances[account],
        daysSinceActivity(account),
        _inactiveFeePerYear[account],
        _inactiveFeePaid[account]);
    if (fee == 0) {
      return 0;
    }
    _balances[account] = _balances[account].sub(fee);
    _balances[_feeAddress] = _balances[_feeAddress].add(fee);
    _inactiveFeePaid[account] = _inactiveFeePaid[account].add(fee);
    emit Transfer(account, _feeAddress, fee);
    return fee;
  }
  function _shouldMarkInactive(address account) internal view returns(bool) {

    if (account != address(0) &&
        _balances[account] > 0 &&
        daysSinceActivity(account) >= INACTIVE_THRESHOLD_DAYS &&
        !isInactive(account) &&
        !isAllFeeExempt(account) &&
        _balances[account].sub(calcStorageFee(account)) > 0) {
      return true;
    }
    return false;
  }
  function _setInactive(address account) internal {

    uint256 storeFee = calcStorageFee(account);
    uint256 snapshotBalance = _balances[account].sub(storeFee);
    assert(snapshotBalance > 0);
    _inactiveFeePerYear[account] = _calcInactiveFeePerYear(snapshotBalance);
    emit AccountInactive(account, _inactiveFeePerYear[account]);
    uint256 inactiveFees = _calcInactiveFee(snapshotBalance,
                                            daysSinceActivity(account),
                                            _inactiveFeePerYear[account],
                                            0);
    uint256 fees = storeFee.add(inactiveFees);
    _balances[account] = _balances[account].sub(fees);
    _balances[_feeAddress] = _balances[_feeAddress].add(fees);
    _inactiveFeePaid[account] = _inactiveFeePaid[account].add(inactiveFees);
    emit Transfer(account, _feeAddress, fees);
    if (storeFee > 0) {
      _timeStorageFeePaid[account] = block.timestamp;
      _endGracePeriod(account);
    }
  }
  function _updateActivity(address account) internal {

    if (_shouldMarkInactive(account)) {
      _setInactive(account);
    }
    if (isInactive(account)) {
      _payInactiveFee(account);
      _inactiveFeePerYear[account] = 0;
      _timeStorageFeePaid[account] = block.timestamp;
      emit AccountReActive(account);
    }
    _timeLastActivity[account] = block.timestamp;
  }
  function _endGracePeriod(address account) internal {

    if (_storageFeeGracePeriod[account] > 0) {
      _storageFeeGracePeriod[account] = 0;
    }
  }
  function _transferRestrictions(address to, address from) internal view {

    require(from != address(0));
    require(to != address(0));
    require(to != address(this), "Cannot transfer tokens to the contract");
    if (from == _unbackedTreasury) {
      require(to == _backedTreasury,
              "Unbacked treasury can only transfer to backed treasury");
    }
    if (from == _redeemAddress) {
      require((to == _unbackedTreasury) || (to == _backedTreasury),
              "Redeem address can only transfer to treasury");
    }
    if (to == _unbackedTreasury) {
      require((from == _backedTreasury) || (from == _redeemAddress),
              "Unbacked treasury can only receive from redeem address and backed treasury");
    }
    if (to == _backedTreasury) {
      require((from == _unbackedTreasury) || (from == _redeemAddress),
              "Only unbacked treasury and redeem address can transfer to backed treasury");
    }
  }
  function _simulateTransfer(address from, address to, uint256 value) internal view returns (uint256[5] memory) {

    uint256[5] memory ret;
    ret[0] = calcOwedFees(from);
    ret[1] = 0;
    ret[2] = 0;
    if (from != to) {
      ret[1] = calcOwedFees(to);
      ret[2] = calcTransferFee(from, value);
      ret[3] = _balances[from].sub(value).sub(ret[0]).sub(ret[2]);
      ret[4] = _balances[to].add(value).sub(ret[1]);
    } else {
      ret[3] = _balances[from].sub(ret[0]);
      ret[4] = ret[3];
    }
    return ret;
  }
  function _calcInactiveFeePerYear(uint256 snapshotBalance) internal pure returns(uint256) {

    uint256 inactiveFeePerYear = snapshotBalance.mul(TOKEN).div(INACTIVE_FEE_DENOMINATOR);
    if (inactiveFeePerYear < TOKEN) {
      return TOKEN;
    }
    return inactiveFeePerYear;
  }
  function _calcInactiveFee(uint256 balance,
                        uint256 daysInactive,
                        uint256 feePerYear,
                        uint256 paidAlready) internal pure returns(uint256) {

    uint256 daysDue = daysInactive.sub(INACTIVE_THRESHOLD_DAYS);
    uint256 totalDue = feePerYear.mul(TOKEN).mul(daysDue).div(YEAR).div(TOKEN).sub(paidAlready);
    if (totalDue > balance || balance.sub(totalDue) <= 200) {
      return balance;
    }
    return totalDue;
  }
}