
pragma solidity >=0.6.0 <0.8.0;

abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}// MIT

pragma solidity >=0.6.0 <0.8.0;

abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor () internal {
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
}// MIT

pragma solidity >=0.6.0 <0.8.0;

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

pragma solidity >=0.6.0 <0.8.0;

library SafeMath {

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
pragma solidity 0.6.12;


abstract contract TokenVestingInterface {
    event VestingScheduleCreated(
        address indexed vestingLocation,
        uint32 cliffDuration, uint32 duration, uint32 interval,
        bool isRevocable);

    event VestingTokensGranted(
        address indexed beneficiary,
        uint256 vestingAmount,
        uint32 startDay,
        address vestingLocation);

    event VestingTokensClaimed(
        address indexed beneficiary,
        uint256 amount);

    event GrantRevoked(address indexed grantHolder);

    struct vestingSchedule {
        bool isRevocable;           /* true if the vesting option is revocable (a gift), false if irrevocable (purchased) */
        uint32 cliffDuration;       /* Duration of the cliff, with respect to the grant start day, in days. */
        uint32 duration;            /* Duration of the vesting schedule, with respect to the grant start day, in days. */
        uint32 interval;            /* Duration in days of the vesting interval. */
    }

    struct tokenGrant {
        bool isActive;              /* true if this vesting entry is active and in-effect entry. */
        bool wasRevoked;            /* true if this vesting schedule was revoked. */
        uint32 startDay;            /* Start day of the grant, in days since the UNIX epoch (start of day). */
        uint256 amount;             /* Total number of tokens that vest. */
        address vestingLocation;    /* Address of wallet that is holding the vesting schedule. */
        uint256 claimedAmount;      /* Out of vested amount, the amount that has been already transferred to beneficiary */
    }

    function token() public virtual view returns (IERC20);

    function kill(address payable beneficiary) external virtual;

    function withdrawTokens(address beneficiary, uint256 amount) external virtual;



    function claimVestingTokens(address beneficiary) external virtual;

    function claimVestingTokensForAll() external virtual;



    function setVestingSchedule(
        address vestingLocation,
        uint32 cliffDuration, uint32 duration, uint32 interval, bool isRevocable) external virtual;



    function addGrant(
        address beneficiary,
        uint256 vestingAmount,
        uint32 startDay,
        uint32 duration,
        uint32 cliffDuration,
        uint32 interval,
        bool isRevocable
    ) public virtual;

    function addGrantWithScheduleAt(
        address beneficiary,
        uint256 vestingAmount,
        uint32 startDay,
        address vestingLocation
    ) external virtual;

    function addGrantFromToday(
        address beneficiary,
        uint256 vestingAmount,
        uint32 duration,
        uint32 cliffDuration,
        uint32 interval,
        bool isRevocable
    ) external virtual;



    function today() public virtual view returns (uint32 dayNumber);

    function getGrantInfo(address grantHolder, uint32 onDayOrToday)
    external virtual view returns (
        uint256 amountVested,
        uint256 amountNotVested,
        uint256 amountOfGrant,
        uint256 amountAvailable,
        uint256 amountClaimed,
        uint32 vestStartDay,
        bool isActive,
        bool wasRevoked
    );

    function getScheduleAtInfo(address vestingLocation)
    public virtual view returns (
        bool isRevocable,
        uint32 vestDuration,
        uint32 cliffDuration,
        uint32 vestIntervalDays
    );

    function getScheduleInfo(address grantHolder)
    external virtual view returns (
        bool isRevocable,
        uint32 vestDuration,
        uint32 cliffDuration,
        uint32 vestIntervalDays
    );



    function revokeGrant(address grantHolder) external virtual;
}// MIT
pragma solidity 0.6.12;


contract TokenVesting is TokenVestingInterface, Context, Ownable {

  using SafeMath for uint256;

  uint32 private constant _THOUSAND_YEARS_DAYS = 365243; /* See https://www.timeanddate.com/date/durationresult.html?m1=1&d1=1&y1=2000&m2=1&d2=1&y2=3000 */
  uint32 private constant _TEN_YEARS_DAYS = _THOUSAND_YEARS_DAYS / 100; /* Includes leap years (though it doesn't really matter) */
  uint32 private constant _SECONDS_PER_DAY = 24 * 60 * 60; /* 86400 seconds in a day */
  uint32 private constant _JAN_1_2000_SECONDS = 946684800; /* Saturday, January 1, 2000 0:00:00 (GMT) (see https://www.epochconverter.com/) */
  uint32 private constant _JAN_1_2000_DAYS =
    _JAN_1_2000_SECONDS / _SECONDS_PER_DAY;
  uint32 private constant _JAN_1_3000_DAYS =
    _JAN_1_2000_DAYS + _THOUSAND_YEARS_DAYS;

  modifier onlyOwnerOrSelf(address account) {

    require(
      _msgSender() == owner() || _msgSender() == account,
      "onlyOwnerOrSelf"
    );
    _;
  }

  mapping(address => vestingSchedule) private _vestingSchedules;
  mapping(address => tokenGrant) private _tokenGrants;
  address[] private _allBeneficiaries;
  IERC20 private _token;

  constructor(IERC20 token_) public {
    require(address(token_) != address(0), "token must be non-zero address");
    _token = token_;
  }

  function token() public view override returns (IERC20) {

    return _token;
  }

  function kill(address payable beneficiary) external override onlyOwner {

    _withdrawTokens(beneficiary, token().balanceOf(address(this)));
    selfdestruct(beneficiary);
  }

  function withdrawTokens(address beneficiary, uint256 amount)
    external
    override
    onlyOwner
  {

    _withdrawTokens(beneficiary, amount);
  }

  function _withdrawTokens(address beneficiary, uint256 amount) internal {

    require(amount > 0, "amount must be > 0");
    require(
      amount <= token().balanceOf(address(this)),
      "amount must be <= current balance"
    );

    require(token().transfer(beneficiary, amount));
  }


  function claimVestingTokens(address beneficiary)
    external
    override
    onlyOwnerOrSelf(beneficiary)
  {

    _claimVestingTokens(beneficiary);
  }

  function claimVestingTokensForAll() external override onlyOwner {

    for (uint256 i = 0; i < _allBeneficiaries.length; i++) {
      _claimVestingTokens(_allBeneficiaries[i]);
    }
  }

  function _claimVestingTokens(address beneficiary) internal {

    uint256 amount = _getAvailableAmount(beneficiary, 0);
    if (amount > 0) {
      _deliverTokens(beneficiary, amount);
      _tokenGrants[beneficiary].claimedAmount = _tokenGrants[beneficiary]
        .claimedAmount
        .add(amount);
      emit VestingTokensClaimed(beneficiary, amount);
    }
  }

  function _deliverTokens(address beneficiary, uint256 amount) internal {

    require(amount > 0, "amount must be > 0");
    require(
      amount <= token().balanceOf(address(this)),
      "amount must be <= current balance"
    );
    require(
      _tokenGrants[beneficiary].claimedAmount.add(amount) <=
        _tokenGrants[beneficiary].amount,
      "new claimed amount must be <= total grant amount"
    );

    require(token().transfer(beneficiary, amount));
  }


  function setVestingSchedule(
    address vestingLocation,
    uint32 cliffDuration,
    uint32 duration,
    uint32 interval,
    bool isRevocable
  ) external override onlyOwner {

    _setVestingSchedule(
      vestingLocation,
      cliffDuration,
      duration,
      interval,
      isRevocable
    );
  }

  function _setVestingSchedule(
    address vestingLocation,
    uint32 cliffDuration,
    uint32 duration,
    uint32 interval,
    bool isRevocable
  ) internal {

    require(
      duration > 0 &&
        duration <= _TEN_YEARS_DAYS &&
        cliffDuration < duration &&
        interval >= 1,
      "invalid vesting schedule"
    );

    require(
      duration % interval == 0 && cliffDuration % interval == 0,
      "invalid cliff/duration for interval"
    );

    _vestingSchedules[vestingLocation] = vestingSchedule(
      isRevocable,
      cliffDuration,
      duration,
      interval
    );

    emit VestingScheduleCreated(
      vestingLocation,
      cliffDuration,
      duration,
      interval,
      isRevocable
    );
  }


  function _addGrant(
    address beneficiary,
    uint256 vestingAmount,
    uint32 startDay,
    address vestingLocation
  ) internal {

    require(!_tokenGrants[beneficiary].isActive, "grant already exists");

    require(
      vestingAmount > 0 &&
        startDay >= _JAN_1_2000_DAYS &&
        startDay < _JAN_1_3000_DAYS,
      "invalid vesting params"
    );

    _tokenGrants[beneficiary] = tokenGrant(
      true, // isActive
      false, // wasRevoked
      startDay,
      vestingAmount,
      vestingLocation, // The wallet address where the vesting schedule is kept.
      0 // claimedAmount
    );
    _allBeneficiaries.push(beneficiary);

    emit VestingTokensGranted(
      beneficiary,
      vestingAmount,
      startDay,
      vestingLocation
    );
  }

  function addGrant(
    address beneficiary,
    uint256 vestingAmount,
    uint32 startDay,
    uint32 duration,
    uint32 cliffDuration,
    uint32 interval,
    bool isRevocable
  ) public override onlyOwner {

    require(!_tokenGrants[beneficiary].isActive, "grant already exists");

    _setVestingSchedule(
      beneficiary,
      cliffDuration,
      duration,
      interval,
      isRevocable
    );

    _addGrant(beneficiary, vestingAmount, startDay, beneficiary);
  }

  function addGrantWithScheduleAt(
    address beneficiary,
    uint256 vestingAmount,
    uint32 startDay,
    address vestingLocation
  ) external override onlyOwner {

    _addGrant(beneficiary, vestingAmount, startDay, vestingLocation);
  }

  function addGrantFromToday(
    address beneficiary,
    uint256 vestingAmount,
    uint32 duration,
    uint32 cliffDuration,
    uint32 interval,
    bool isRevocable
  ) external override onlyOwner {

    addGrant(
      beneficiary,
      vestingAmount,
      today(),
      duration,
      cliffDuration,
      interval,
      isRevocable
    );
  }

  function today() public view virtual override returns (uint32 dayNumber) {

    return uint32(block.timestamp / _SECONDS_PER_DAY);
  }

  function _effectiveDay(uint32 onDayOrToday)
    internal
    view
    returns (uint32 dayNumber)
  {

    return onDayOrToday == 0 ? today() : onDayOrToday;
  }

  function _getNotVestedAmount(address grantHolder, uint32 onDayOrToday)
    internal
    view
    returns (uint256 amountNotVested)
  {

    tokenGrant storage grant = _tokenGrants[grantHolder];
    vestingSchedule storage vesting = _vestingSchedules[grant.vestingLocation];
    uint32 onDay = _effectiveDay(onDayOrToday);

    if (!grant.isActive || onDay < grant.startDay + vesting.cliffDuration) {
      return grant.amount;
    }
    else if (onDay >= grant.startDay + vesting.duration) {
      return uint256(0);
    }
    else {
      uint32 daysVested = onDay - grant.startDay;
      uint32 effectiveDaysVested = (daysVested / vesting.interval) *
        vesting.interval;

      uint256 vested = grant.amount.mul(effectiveDaysVested).div(
        vesting.duration
      );
      uint256 result = grant.amount.sub(vested);
      require(result <= grant.amount && vested <= grant.amount);

      return result;
    }
  }

  function _getAvailableAmount(address grantHolder, uint32 onDay)
    internal
    view
    returns (uint256 amountAvailable)
  {

    tokenGrant storage grant = _tokenGrants[grantHolder];
    return
      _getAvailableAmountImpl(grant, _getNotVestedAmount(grantHolder, onDay));
  }

  function _getAvailableAmountImpl(
    tokenGrant storage grant,
    uint256 notVastedOnDay
  ) internal view returns (uint256 amountAvailable) {

    uint256 vested = grant.amount.sub(notVastedOnDay);
    if (vested < grant.claimedAmount) {
      require(vested == 0 && grant.wasRevoked);
      return 0;
    }

    uint256 result = vested.sub(grant.claimedAmount);
    require(
      result <= grant.amount &&
        grant.claimedAmount.add(result) <= grant.amount &&
        result <= vested &&
        vested <= grant.amount
    );

    return result;
  }

  function getGrantInfo(address grantHolder, uint32 onDayOrToday)
    external
    view
    override
    onlyOwnerOrSelf(grantHolder)
    returns (
      uint256 amountVested,
      uint256 amountNotVested,
      uint256 amountOfGrant,
      uint256 amountAvailable,
      uint256 amountClaimed,
      uint32 vestStartDay,
      bool isActive,
      bool wasRevoked
    )
  {

    tokenGrant storage grant = _tokenGrants[grantHolder];
    uint256 notVestedAmount = _getNotVestedAmount(grantHolder, onDayOrToday);

    return (
      grant.amount.sub(notVestedAmount),
      notVestedAmount,
      grant.amount,
      _getAvailableAmountImpl(grant, notVestedAmount),
      grant.claimedAmount,
      grant.startDay,
      grant.isActive,
      grant.wasRevoked
    );
  }

  function getScheduleAtInfo(address vestingLocation)
    public
    view
    override
    onlyOwnerOrSelf(vestingLocation)
    returns (
      bool isRevocable,
      uint32 vestDuration,
      uint32 cliffDuration,
      uint32 vestIntervalDays
    )
  {

    vestingSchedule storage vesting = _vestingSchedules[vestingLocation];

    return (
      vesting.isRevocable,
      vesting.duration,
      vesting.cliffDuration,
      vesting.interval
    );
  }

  function getScheduleInfo(address grantHolder)
    external
    view
    override
    onlyOwnerOrSelf(grantHolder)
    returns (
      bool isRevocable,
      uint32 vestDuration,
      uint32 cliffDuration,
      uint32 vestIntervalDays
    )
  {

    tokenGrant storage grant = _tokenGrants[grantHolder];
    return getScheduleAtInfo(grant.vestingLocation);
  }


  function revokeGrant(address grantHolder) external override onlyOwner {

    tokenGrant storage grant = _tokenGrants[grantHolder];
    vestingSchedule storage vesting = _vestingSchedules[grant.vestingLocation];

    require(grant.isActive, "no active grant");
    require(vesting.isRevocable, "irrevocable");

    _tokenGrants[grantHolder].wasRevoked = true;
    _tokenGrants[grantHolder].isActive = false;

    emit GrantRevoked(grantHolder);
  }
}