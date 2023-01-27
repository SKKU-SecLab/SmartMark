

pragma solidity >=0.4.24;


interface ICash {

    function claimDividends(address account) external returns (uint256);


    function transfer(address to, uint256 value) external returns(bool);

    function transferFrom(address from, address to, uint256 value) external returns(bool);

    function balanceOf(address who) external view returns(uint256);

    function allowance(address owner_, address spender) external view returns(uint256);

    function approve(address spender, uint256 value) external returns (bool);

    function increaseAllowance(address spender, uint256 addedValue) external returns (bool);

    function decreaseAllowance(address spender, uint256 subtractedValue) external returns (bool);

    function totalSupply() external view returns (uint256);

    function rebase(uint256 epoch, int256 supplyDelta) external returns (uint256);

    function redeemedShare(address account) external view returns (uint256);

}


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


pragma solidity >=0.4.24 <0.6.0;


contract Initializable {


  bool private initialized;

  bool private initializing;

  modifier initializer() {

    require(initializing || isConstructor() || !initialized, "Contract instance has already been initialized");

    bool isTopLevelCall = !initializing;
    if (isTopLevelCall) {
      initializing = true;
      initialized = true;
    }

    _;

    if (isTopLevelCall) {
      initializing = false;
    }
  }

  function isConstructor() private view returns (bool) {

    uint256 cs;
    assembly { cs := extcodesize(address) }
    return cs == 0;
  }

  uint256[50] private ______gap;
}


pragma solidity ^0.4.24;


contract Ownable is Initializable {

  address private _owner;


  event OwnershipRenounced(address indexed previousOwner);
  event OwnershipTransferred(
    address indexed previousOwner,
    address indexed newOwner
  );


  function initialize(address sender) public initializer {

    _owner = sender;
  }

  function owner() public view returns(address) {

    return _owner;
  }

  modifier onlyOwner() {

    require(isOwner());
    _;
  }

  function isOwner() public view returns(bool) {

    return msg.sender == _owner;
  }

  function renounceOwnership() public onlyOwner {

    emit OwnershipRenounced(_owner);
    _owner = address(0);
  }

  function transferOwnership(address newOwner) public onlyOwner {

    _transferOwnership(newOwner);
  }

  function _transferOwnership(address newOwner) internal {

    require(newOwner != address(0));
    emit OwnershipTransferred(_owner, newOwner);
    _owner = newOwner;
  }

  uint256[50] private ______gap;
}


pragma solidity ^0.4.24;


contract ReentrancyGuard is Initializable {


  uint256 private _guardCounter;

  function initialize() public initializer {

    _guardCounter = 1;
  }

  modifier nonReentrant() {

    _guardCounter += 1;
    uint256 localCounter = _guardCounter;
    _;
    require(localCounter == _guardCounter);
  }

  uint256[50] private ______gap;
}



pragma solidity >=0.4.24;


library SafeMathInt {

    int256 private constant MIN_INT256 = int256(1) << 255;
    int256 private constant MAX_INT256 = ~(int256(1) << 255);

    function mul(int256 a, int256 b)
        internal
        pure
        returns (int256)
    {

        int256 c = a * b;

        require(c != MIN_INT256 || (a & MIN_INT256) != (b & MIN_INT256));
        require((b == 0) || (c / b == a));
        return c;
    }

    function div(int256 a, int256 b)
        internal
        pure
        returns (int256)
    {

        require(b != -1 || a != MIN_INT256);

        return a / b;
    }

    function sub(int256 a, int256 b)
        internal
        pure
        returns (int256)
    {

        int256 c = a - b;
        require((b >= 0 && c <= a) || (b < 0 && c > a));
        return c;
    }

    function add(int256 a, int256 b)
        internal
        pure
        returns (int256)
    {

        int256 c = a + b;
        require((b >= 0 && c >= a) || (b < 0 && c < a));
        return c;
    }

    function abs(int256 a)
        internal
        pure
        returns (int256)
    {

        require(a != MIN_INT256);
        return a < 0 ? -a : a;
    }
}


pragma solidity >=0.4.24;






contract stakingUSDx is Ownable, ReentrancyGuard {

    using SafeMath for uint256;
    using SafeMathInt for int256;

    ICash public Dollars;

    struct Stake {
        uint256 lastDollarPoints;   // variable to keep track of pending payouts
        uint256 stakingSeconds;     // when user started staking
        uint256 stakingAmount;      // how much user deposited in USDx
        uint256 unstakingSeconds;   // when user starts to unstake
        uint256 stakingStatus;      // 0 = unstaked, 1 = staked, 2 = commit to unstake
    }

    address timelock;
    uint256 public totalStaked;                                 // value that tracks the total amount of USDx staked
    uint256 public totalDollarPoints;                           // variable for keeping track of payouts
    uint256 public stakingMinimumSeconds;                       // minimum amount of allocated staking time per user
    mapping (address => Stake) public userStake;
    uint256 public coolDownPeriodSeconds;                       // how long it takes for a user to get paid their money back
    uint256 public constant POINT_MULTIPLIER = 10 ** 18;
    uint256 public totalCommitted;                              // value that tracks the total amount of USDx committed to unstake

    modifier validRecipient(address to) {

        require(to != address(0x0));
        require(to != address(this));
        _;
    }

    function initialize(address owner_, address dollar_, address timelock_) public initializer {

        Ownable.initialize(owner_);
        ReentrancyGuard.initialize();
        Dollars = ICash(dollar_);

        timelock = timelock_;
        stakingMinimumSeconds = 432000;                         // 432000 seconds = 5 days
        coolDownPeriodSeconds = 432000;                         // 5 days for getting out principal
    }

    function changeStakingMinimumSeconds(uint256 seconds_) external {

        require(msg.sender == timelock || msg.sender == address(0x89a359A3D37C3A857E62cDE9715900441b47acEC), "unauthorized");
        stakingMinimumSeconds = seconds_;
    }

    function changeCoolDownSeconds(uint256 seconds_) external {

        require(msg.sender == timelock || msg.sender == address(0x89a359A3D37C3A857E62cDE9715900441b47acEC), "unauthorized");
        coolDownPeriodSeconds = seconds_;
    }

    function addRebaseFunds(uint256 newUsdAmount) external {

        require(msg.sender == address(Dollars), "unauthorized");
        totalDollarPoints += newUsdAmount.mul(POINT_MULTIPLIER).div(totalStaked);
    }

    function stake(uint256 amount) external updateAccount(msg.sender) {

        require(userStake[msg.sender].stakingStatus != 2, "cannot stake while committed");
        require(amount != 0, "invalid stake amount");
        require(amount <= Dollars.balanceOf(msg.sender), "insufficient balance");
        require(Dollars.transferFrom(msg.sender, address(this), amount), "staking failed");

        userStake[msg.sender].stakingSeconds = now;
        userStake[msg.sender].stakingAmount += amount;
        totalStaked += amount;
        userStake[msg.sender].stakingStatus = 1;
    }

    function commitUnstake() external updateAccount(msg.sender) {

        require(userStake[msg.sender].stakingSeconds + stakingMinimumSeconds < now, "minimum time unmet");
        require(userStake[msg.sender].stakingStatus == 1, "user must be staked first");

        userStake[msg.sender].stakingStatus = 2;
        userStake[msg.sender].unstakingSeconds = now;
        totalStaked -= userStake[msg.sender].stakingAmount; // remove staked from pool for rewards
        totalCommitted += userStake[msg.sender].stakingAmount;
    }

    function unstake() external updateAccount(msg.sender) {

        require(userStake[msg.sender].stakingStatus == 2, "user must commit to unstaking first");
        require(userStake[msg.sender].unstakingSeconds + coolDownPeriodSeconds < now, "minimum time unmet");

        userStake[msg.sender].stakingStatus = 0;
        require(Dollars.transfer(msg.sender, userStake[msg.sender].stakingAmount), "unstaking failed");
        totalCommitted -= userStake[msg.sender].stakingAmount;

        userStake[msg.sender].stakingAmount = 0;
    }

    function pendingReward(address user_) validRecipient(user_) public view returns (uint256) {

        if (totalDollarPoints > userStake[user_].lastDollarPoints && userStake[user_].stakingStatus == 1) {
            uint256 newDividendPoints = totalDollarPoints.sub(userStake[user_].lastDollarPoints);
            uint256 owedDollars = (userStake[user_].stakingAmount).mul(newDividendPoints).div(POINT_MULTIPLIER);

            return owedDollars > Dollars.balanceOf(address(this)) ? Dollars.balanceOf(address(this)).div(2) : owedDollars;
        } else {
            return 0;
        }
    }

    function claimReward(address user_) validRecipient(user_) public {

        uint256 reward = pendingReward(user_);
        if (reward > 0) require(Dollars.transfer(user_, reward), "claiming reward failed");

        userStake[user_].lastDollarPoints = totalDollarPoints;
    }
 
    modifier updateAccount(address account) {

        Dollars.claimDividends(account);
        claimReward(account);
        _;
    }
}