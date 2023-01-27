
pragma solidity >=0.6.2 <0.8.0;

library AddressUpgradeable {

    function isContract(address account) internal view returns (bool) {


        uint256 size;
        assembly { size := extcodesize(account) }
        return size > 0;
    }

    function sendValue(address payable recipient, uint256 amount) internal {

        require(address(this).balance >= amount, "Address: insufficient balance");

        (bool success, ) = recipient.call{ value: amount }("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    function functionCall(address target, bytes memory data) internal returns (bytes memory) {

      return functionCall(target, data, "Address: low-level call failed");
    }

    function functionCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {

        return functionCallWithValue(target, data, 0, errorMessage);
    }

    function functionCallWithValue(address target, bytes memory data, uint256 value) internal returns (bytes memory) {

        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    function functionCallWithValue(address target, bytes memory data, uint256 value, string memory errorMessage) internal returns (bytes memory) {

        require(address(this).balance >= value, "Address: insufficient balance for call");
        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{ value: value }(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {

        return functionStaticCall(target, data, "Address: low-level static call failed");
    }

    function functionStaticCall(address target, bytes memory data, string memory errorMessage) internal view returns (bytes memory) {

        require(isContract(target), "Address: static call to non-contract");

        (bool success, bytes memory returndata) = target.staticcall(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function _verifyCallResult(bool success, bytes memory returndata, string memory errorMessage) private pure returns(bytes memory) {

        if (success) {
            return returndata;
        } else {
            if (returndata.length > 0) {

                assembly {
                    let returndata_size := mload(returndata)
                    revert(add(32, returndata), returndata_size)
                }
            } else {
                revert(errorMessage);
            }
        }
    }
}// MIT

pragma solidity >=0.4.24 <0.8.0;


abstract contract Initializable {

    bool private _initialized;

    bool private _initializing;

    modifier initializer() {
        require(_initializing || _isConstructor() || !_initialized, "Initializable: contract is already initialized");

        bool isTopLevelCall = !_initializing;
        if (isTopLevelCall) {
            _initializing = true;
            _initialized = true;
        }

        _;

        if (isTopLevelCall) {
            _initializing = false;
        }
    }

    function _isConstructor() private view returns (bool) {
        return !AddressUpgradeable.isContract(address(this));
    }
}// MIT

pragma solidity >=0.6.0 <0.8.0;

abstract contract ContextUpgradeable is Initializable {
    function __Context_init() internal initializer {
        __Context_init_unchained();
    }

    function __Context_init_unchained() internal initializer {
    }
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
    uint256[50] private __gap;
}// MIT

pragma solidity >=0.6.0 <0.8.0;

interface IERC20Upgradeable {

    function totalSupply() external view returns (uint256);


    function balanceOf(address account) external view returns (uint256);


    function transfer(address recipient, uint256 amount) external returns (bool);


    function allowance(address owner, address spender) external view returns (uint256);


    function approve(address spender, uint256 amount) external returns (bool);


    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);


    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}// MIT

pragma solidity >=0.6.0 <0.8.0;

library SafeMathUpgradeable {

    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        uint256 c = a + b;
        if (c < a) return (false, 0);
        return (true, c);
    }

    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        if (b > a) return (false, 0);
        return (true, a - b);
    }

    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        if (a == 0) return (true, 0);
        uint256 c = a * b;
        if (c / a != b) return (false, 0);
        return (true, c);
    }

    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        if (b == 0) return (false, 0);
        return (true, a / b);
    }

    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        if (b == 0) return (false, 0);
        return (true, a % b);
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {

        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");
        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b <= a, "SafeMath: subtraction overflow");
        return a - b;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {

        if (a == 0) return 0;
        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");
        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b > 0, "SafeMath: division by zero");
        return a / b;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b > 0, "SafeMath: modulo by zero");
        return a % b;
    }

    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        require(b <= a, errorMessage);
        return a - b;
    }

    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        require(b > 0, errorMessage);
        return a / b;
    }

    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        require(b > 0, errorMessage);
        return a % b;
    }
}// MIT

pragma solidity >=0.6.0 <0.8.0;


contract ERC20Upgradeable is Initializable, ContextUpgradeable, IERC20Upgradeable {

    using SafeMathUpgradeable for uint256;

    mapping (address => uint256) private _balances;

    mapping (address => mapping (address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;
    uint8 private _decimals;

    function __ERC20_init(string memory name_, string memory symbol_) internal initializer {

        __Context_init_unchained();
        __ERC20_init_unchained(name_, symbol_);
    }

    function __ERC20_init_unchained(string memory name_, string memory symbol_) internal initializer {

        _name = name_;
        _symbol = symbol_;
        _decimals = 18;
    }

    function name() public view virtual returns (string memory) {

        return _name;
    }

    function symbol() public view virtual returns (string memory) {

        return _symbol;
    }

    function decimals() public view virtual returns (uint8) {

        return _decimals;
    }

    function totalSupply() public view virtual override returns (uint256) {

        return _totalSupply;
    }

    function balanceOf(address account) public view virtual override returns (uint256) {

        return _balances[account];
    }

    function transfer(address recipient, uint256 amount) public virtual override returns (bool) {

        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function allowance(address owner, address spender) public view virtual override returns (uint256) {

        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public virtual override returns (bool) {

        _approve(_msgSender(), spender, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) public virtual override returns (bool) {

        _transfer(sender, recipient, amount);
        _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount, "ERC20: transfer amount exceeds allowance"));
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {

        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].add(addedValue));
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {

        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].sub(subtractedValue, "ERC20: decreased allowance below zero"));
        return true;
    }

    function _transfer(address sender, address recipient, uint256 amount) internal virtual {

        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(sender, recipient, amount);

        _balances[sender] = _balances[sender].sub(amount, "ERC20: transfer amount exceeds balance");
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
    }

    function _mint(address account, uint256 amount) internal virtual {

        require(account != address(0), "ERC20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply = _totalSupply.add(amount);
        _balances[account] = _balances[account].add(amount);
        emit Transfer(address(0), account, amount);
    }

    function _burn(address account, uint256 amount) internal virtual {

        require(account != address(0), "ERC20: burn from the zero address");

        _beforeTokenTransfer(account, address(0), amount);

        _balances[account] = _balances[account].sub(amount, "ERC20: burn amount exceeds balance");
        _totalSupply = _totalSupply.sub(amount);
        emit Transfer(account, address(0), amount);
    }

    function _approve(address owner, address spender, uint256 amount) internal virtual {

        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _setupDecimals(uint8 decimals_) internal virtual {

        _decimals = decimals_;
    }

    function _beforeTokenTransfer(address from, address to, uint256 amount) internal virtual { }

    uint256[44] private __gap;
}// MIT

pragma solidity >=0.6.0 <0.8.0;

abstract contract OwnableUpgradeable is Initializable, ContextUpgradeable {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    function __Ownable_init() internal initializer {
        __Context_init_unchained();
        __Ownable_init_unchained();
    }

    function __Ownable_init_unchained() internal initializer {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
    uint256[49] private __gap;
}// MIT

pragma solidity >=0.6.0 <0.8.0;


abstract contract PausableUpgradeable is Initializable, ContextUpgradeable {
    event Paused(address account);

    event Unpaused(address account);

    bool private _paused;

    function __Pausable_init() internal initializer {
        __Context_init_unchained();
        __Pausable_init_unchained();
    }

    function __Pausable_init_unchained() internal initializer {
        _paused = false;
    }

    function paused() public view virtual returns (bool) {
        return _paused;
    }

    modifier whenNotPaused() {
        require(!paused(), "Pausable: paused");
        _;
    }

    modifier whenPaused() {
        require(paused(), "Pausable: not paused");
        _;
    }

    function _pause() internal virtual whenNotPaused {
        _paused = true;
        emit Paused(_msgSender());
    }

    function _unpause() internal virtual whenPaused {
        _paused = false;
        emit Unpaused(_msgSender());
    }
    uint256[49] private __gap;
}// MIT

pragma solidity >=0.6.0 <0.8.0;


abstract contract ERC20PausableUpgradeable is Initializable, ERC20Upgradeable, PausableUpgradeable {
    function __ERC20Pausable_init() internal initializer {
        __Context_init_unchained();
        __Pausable_init_unchained();
        __ERC20Pausable_init_unchained();
    }

    function __ERC20Pausable_init_unchained() internal initializer {
    }
    function _beforeTokenTransfer(address from, address to, uint256 amount) internal virtual override {
        super._beforeTokenTransfer(from, to, amount);

        require(!paused(), "ERC20Pausable: token transfer while paused");
    }
    uint256[50] private __gap;
}pragma solidity >=0.6.0 <0.8.0;

interface ILiquiditySyncer {

  function syncLiquiditySupply(address pool) external;

}

interface ILocker {

  function lockOrGetPenalty(address source, address dest)
    external
    returns (bool, uint256);

}

interface ILockerUser {

  function locker() external view returns (ILocker);

}pragma solidity 0.6.2;


contract PlaycentTokenV1 is
  Initializable,
  OwnableUpgradeable,
  ERC20PausableUpgradeable,
  ILockerUser
{

  using SafeMathUpgradeable for uint256;

  string public releaseSHA;

  struct VestType {
    uint8 indexId;
    uint8 lockPeriod;
    uint8 vestingDuration;
    uint8 tgePercent;
    uint8 monthlyPercent;
    uint256 totalTokenAllocation;
  }

  struct VestAllocation {
    uint8 vestIndexID;
    uint256 totalTokensAllocated;
    uint256 totalTGETokens;
    uint256 monthlyTokens;
    uint8 vestingDuration;
    uint8 lockPeriod;
    uint256 totalVestTokensClaimed;
    bool isVesting;
    bool isTgeTokensClaimed;
  }

  mapping(uint256 => VestType) internal vestTypes;
  mapping(address => mapping(uint8 => VestAllocation))
    public walletToVestAllocations;

  ILocker public override locker;

  function initialize(address _PublicSaleAddress, address _exchangeLiquidityAddress, string memory _hash)
    public
    initializer
  {

    __Ownable_init();
    __ERC20_init("Playcent", "PCNT");
    __ERC20Pausable_init();
    _mint(owner(), 55200000 ether);
    _mint(_PublicSaleAddress, 2400000 ether);
    _mint(_exchangeLiquidityAddress, 2400000 ether);

    releaseSHA = _hash;

    vestTypes[0] = VestType(0, 12, 32, 0, 5, 9000000 ether); // Team
    vestTypes[1] = VestType(1, 3, 13, 0, 10, 4800000 ether); // Operations
    vestTypes[2] = VestType(2, 3, 13, 0, 10, 4800000 ether); // Marketing/Partners
    vestTypes[3] = VestType(3, 1, 11, 0, 10, 2400000 ether); // Advisors
    vestTypes[4] = VestType(4, 1, 6, 0, 20, 4800000 ether); //Staking/Early Incentive Rewards
    vestTypes[5] = VestType(5, 3, 28, 0, 4, 9000000 ether); //Play Mining
    vestTypes[6] = VestType(6, 6, 31, 0, 4, 4200000 ether); //Reserve
    vestTypes[7] = VestType(7, 1, 7, 10, 15, 5700000 ether); // Seed Sale
    vestTypes[8] = VestType(8, 1, 5, 15, 20, 5400000 ether); // Private Sale 1
    vestTypes[9] = VestType(9, 1, 4, 20, 20, 5100000 ether); // Private Sale 2
  }

  modifier onlyValidVestingBenifciary(
    address _userAddresses,
    uint8 _vestingIndex
  ) {

    require(_userAddresses != address(0), "Invalid Address");
    require(
      !walletToVestAllocations[_userAddresses][_vestingIndex].isVesting,
      "User Vesting Details Already Added to this Category"
    );
    _;
  }

  modifier checkVestingStatus(address _userAddresses, uint8 _vestingIndex) {

    require(
      walletToVestAllocations[_userAddresses][_vestingIndex].isVesting,
      "User NOT added to the provided vesting Index"
    );
    _;
  }

  modifier onlyValidVestingIndex(uint8 _vestingIndex) {

    require(_vestingIndex >= 0 && _vestingIndex <= 9, "Invalid Vesting Index");
    _;
  }

  modifier onlyAfterTGE() {

    require(
      getCurrentTime() > getTGETime(),
      "Token Generation Event Not Started Yet"
    );
    _;
  }

  function setLocker(address _locker) external onlyOwner() {

    locker = ILocker(_locker);
  }


  function _transfer(
    address sender,
    address recipient,
    uint256 amount
  ) internal virtual override {

    if (address(locker) != address(0)) {
      locker.lockOrGetPenalty(sender, recipient);
    }
    return super._transfer(sender, recipient, amount);
  }

  function getCurrentTime() internal view returns (uint256) {

    return block.timestamp;
  }

  function daysInSeconds() internal pure returns (uint256) {

    return 86400;
  }

  function monthInSeconds() internal pure returns (uint256) {

    return 2592000;
  }

  function getTGETime() public pure returns (uint256) {

    return 1615055400; // March 6, 2021 @ 6:30:00 pm
  }

  function percentage(uint256 _totalAmount, uint256 _rate)
    internal
    pure
    returns (uint256)
  {

    return _totalAmount.mul(_rate).div(100);
  }

  function pauseContract() external onlyOwner {

    _pause();
  }

  function unPauseContract() external onlyOwner {

    _unpause();
  }


  function addVestingDetails(
    address[] calldata _userAddresses,
    uint256[] calldata _vestingAmounts,
    uint8 _vestingType
  ) external onlyOwner onlyValidVestingIndex(_vestingType) returns (bool) {

    require(
      _userAddresses.length == _vestingAmounts.length,
      "Unequal arrays passed"
    );

    VestType memory vestData = vestTypes[_vestingType];
    uint256 arrayLength = _userAddresses.length;

    uint256 providedVestAmount;

    for (uint256 i = 0; i < arrayLength; i++) {
      uint8 vestIndexID = _vestingType;
      address userAddress = _userAddresses[i];
      uint256 totalAllocation = _vestingAmounts[i];
      uint8 lockPeriod = vestData.lockPeriod;
      uint8 vestingDuration = vestData.vestingDuration;
      uint256 tgeAmount = percentage(totalAllocation, vestData.tgePercent);
      uint256 monthlyAmount =
        percentage(totalAllocation, vestData.monthlyPercent);
      providedVestAmount += _vestingAmounts[i];

      addUserVestingDetails(
        userAddress,
        vestIndexID,
        totalAllocation,
        lockPeriod,
        vestingDuration,
        tgeAmount,
        monthlyAmount
      );
    }
    uint256 ownerBalance = balanceOf(owner());
    require(
      ownerBalance >= providedVestAmount,
      "Owner does't have required token balance"
    );
    _transfer(owner(), address(this), providedVestAmount);
    return true;
  }


  function addUserVestingDetails(
    address _userAddresses,
    uint8 _vestingIndex,
    uint256 _totalAllocation,
    uint8 _lockPeriod,
    uint8 _vestingDuration,
    uint256 _tgeAmount,
    uint256 _monthlyAmount
  ) internal onlyValidVestingBenifciary(_userAddresses, _vestingIndex) {

    VestAllocation memory userVestingData =
      VestAllocation(
        _vestingIndex,
        _totalAllocation,
        _tgeAmount,
        _monthlyAmount,
        _vestingDuration,
        _lockPeriod,
        0,
        true,
        false
      );
    walletToVestAllocations[_userAddresses][_vestingIndex] = userVestingData;
  }

  function totalTokensClaimed(address _userAddresses, uint8 _vestingIndex)
    public
    view
    returns (uint256)
  {

    uint256 totalClaimedTokens;
    VestAllocation memory vestData =
      walletToVestAllocations[_userAddresses][_vestingIndex];

    totalClaimedTokens = totalClaimedTokens.add(
      vestData.totalVestTokensClaimed
    );

    if (vestData.isTgeTokensClaimed) {
      totalClaimedTokens = totalClaimedTokens.add(vestData.totalTGETokens);
    }

    return totalClaimedTokens;
  }


  function calculateClaimableVestTokens(
    address _userAddresses,
    uint8 _vestingIndex
  )
    public
    view
    checkVestingStatus(_userAddresses, _vestingIndex)
    returns (uint256)
  {

    VestAllocation memory vestData =
      walletToVestAllocations[_userAddresses][_vestingIndex];

    uint256 actualClaimableAmount;
    uint256 tokensAfterElapsedMonths;
    uint256 vestStartTime = getTGETime();
    uint256 currentTime = getCurrentTime();
    uint256 timeElapsed = currentTime.sub(vestStartTime);

    uint256 totalMonthsElapsed = timeElapsed.div(monthInSeconds());
    uint256 totalDaysElapsed = timeElapsed.div(daysInSeconds());
    uint256 partialDaysElapsed = totalDaysElapsed.mod(30);

    if (partialDaysElapsed > 0 && totalMonthsElapsed > 0) {
      totalMonthsElapsed += 1;
    }

    require(
      totalMonthsElapsed > vestData.lockPeriod,
      "Vesting Cliff Not Crossed Yet"
    );

    if (totalMonthsElapsed > vestData.vestingDuration) {
      uint256 _totalTokensClaimed =
        totalTokensClaimed(_userAddresses, _vestingIndex);
      actualClaimableAmount = vestData.totalTokensAllocated.sub(
        _totalTokensClaimed
      );
    } else {
      uint256 actualMonthElapsed = totalMonthsElapsed.sub(vestData.lockPeriod);
      require(actualMonthElapsed > 0, "Number of months elapsed is ZERO");
      if (vestData.vestIndexID == 9) {
        uint256[4] memory monthsToRates;
        monthsToRates[1] = 20;
        monthsToRates[2] = 50;
        monthsToRates[3] = 80;
        tokensAfterElapsedMonths = percentage(
          vestData.totalTokensAllocated,
          monthsToRates[actualMonthElapsed]
        );
      } else {
        tokensAfterElapsedMonths = vestData.monthlyTokens.mul(
          actualMonthElapsed
        );
      }
      require(
        tokensAfterElapsedMonths > vestData.totalVestTokensClaimed,
        "No Claimable Tokens at this Time"
      );
      actualClaimableAmount = tokensAfterElapsedMonths.sub(
        vestData.totalVestTokensClaimed
      );
    }
    return actualClaimableAmount;
  }

  function _sendTokens(address _beneficiary, uint256 _amountOfTokens)
    private
    returns (bool)
  {

    _transfer(address(this), _beneficiary, _amountOfTokens);
    return true;
  }

  function claimTGETokens(address _userAddresses, uint8 _vestingIndex)
    public
    onlyAfterTGE
    whenNotPaused
    checkVestingStatus(_userAddresses, _vestingIndex)
    returns (bool)
  {

    VestAllocation memory vestData =
      walletToVestAllocations[_userAddresses][_vestingIndex];

    require(
      vestData.vestIndexID >= 7 && vestData.vestIndexID <= 9,
      "Vesting Category doesn't belong to SALE VEsting"
    );
    require(
      vestData.isTgeTokensClaimed == false,
      "TGE Tokens Have already been claimed for Given Address"
    );

    uint256 tokensToTransfer = vestData.totalTGETokens;

    uint256 contractTokenBalance = balanceOf(address(this));
    require(
      contractTokenBalance >= tokensToTransfer,
      "Not Enough Token Balance in Contract"
    );

    vestData.isTgeTokensClaimed = true;
    walletToVestAllocations[_userAddresses][_vestingIndex] = vestData;
    _sendTokens(_userAddresses, tokensToTransfer);
  }

  function claimVestTokens(
    address _userAddresses,
    uint8 _vestingIndex,
    uint256 _tokenAmount
  )
    public
    onlyAfterTGE
    whenNotPaused
    checkVestingStatus(_userAddresses, _vestingIndex)
    returns (bool)
  {

    VestAllocation memory vestData =
      walletToVestAllocations[_userAddresses][_vestingIndex];

    uint256 _totalTokensClaimed =
      totalTokensClaimed(_userAddresses, _vestingIndex);
    uint256 tokensToTransfer =
      calculateClaimableVestTokens(_userAddresses, _vestingIndex);

    require(
      tokensToTransfer > 0,
      "No tokens to transfer at this point of time"
    );
    require(
      _tokenAmount <= tokensToTransfer,
      "Cannot Claim more than Monthly Vest Amount"
    );
    uint256 contractTokenBalance = balanceOf(address(this));
    require(
      contractTokenBalance >= _tokenAmount,
      "Not Enough Token Balance in Contract"
    );
    require(
      _totalTokensClaimed.add(_tokenAmount) <= vestData.totalTokensAllocated,
      "Cannot Claim more than Allocated"
    );

    vestData.totalVestTokensClaimed += _tokenAmount;
    if (
      _totalTokensClaimed.add(_tokenAmount) == vestData.totalTokensAllocated
    ) {
      vestData.isVesting = false;
    }
    walletToVestAllocations[_userAddresses][_vestingIndex] = vestData;
    _sendTokens(_userAddresses, _tokenAmount);
  }

}