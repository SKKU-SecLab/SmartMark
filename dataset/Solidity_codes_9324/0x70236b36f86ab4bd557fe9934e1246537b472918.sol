
pragma solidity ^0.8.0;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}// MIT

pragma solidity ^0.8.0;


abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor() {
        _transferOwnership(_msgSender());
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }

    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}// MIT

pragma solidity ^0.8.0;

abstract contract ReentrancyGuard {

    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor() {
        _status = _NOT_ENTERED;
    }

    modifier nonReentrant() {
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        _status = _ENTERED;

        _;

        _status = _NOT_ENTERED;
    }
}// MIT
pragma solidity 0.8.6;

interface IGovernanceToken {

   function delegate(address delegatee) external;


   function delegates(address delegator) external returns (address);


   function transfer(address dst, uint256 rawAmount) external returns (bool);


   function transferFrom(
      address src,
      address dst,
      uint256 rawAmount
   ) external returns (bool);


   function balanceOf(address src) external returns (uint256);


   function decimals() external returns (uint8);

}// MIT
pragma solidity 0.8.6;



contract Delegator is Ownable {


   address public immutable token;

   mapping(address => uint256) public stakerBalance;


   constructor(address delegatee_, address token_) {
      require(
         delegatee_ != address(0) && token_ != address(0),
         "Address can't be 0"
      );
      require(IGovernanceToken(token_).decimals() == 18, "Decimals must be 18");
      token = token_;
      IGovernanceToken(token_).delegate(delegatee_);
   }


   function stake(address staker_, uint256 amount_) external onlyOwner {

      stakerBalance[staker_] += amount_;
   }

   function removeStake(address staker_, uint256 amount_) external onlyOwner {

      stakerBalance[staker_] -= amount_;
      require(
         IGovernanceToken(token).transfer(staker_, amount_),
         "Transfer failed"
      );
   }


   function delegatee() external returns (address) {

      return IGovernanceToken(token).delegates(address(this));
   }
}// MIT
pragma solidity 0.8.6;



contract DelegatorFactory is Ownable, ReentrancyGuard {


   address public immutable stakingToken;

   address public immutable rewardsToken;

   uint256 public waitTime;

   uint256 public periodFinish = 0;
   uint256 public rewardRate = 0;

   uint256 public rewardsDuration = 186 days;

   uint256 public lastUpdateTime;

   uint256 public rewardPerTokenStored;

   mapping(address => uint256) public userRewardPerTokenPaid;

   mapping(address => uint256) public rewards;

   mapping(address => address) public delegatorToDelegatee;

   mapping(address => address) public delegateeToDelegator;

   mapping(address => bool) public delegators;

   mapping(address => mapping(address => uint256)) public stakerWaitTime;

   uint256 private _totalSupply;

   mapping(address => uint256) private _balances;


   event DelegatorCreated(address indexed delegator, address indexed delegatee);

   event Staked(
      address indexed delegator,
      address indexed delegatee,
      uint256 amount
   );

   event Withdrawn(
      address indexed delegator,
      address indexed delegatee,
      uint256 amount
   );

   event WaitTimeUpdated(uint256 waitTime);

   event RewardAdded(uint256 reward);

   event RewardPaid(address indexed user, uint256 reward);

   event RewardsDurationUpdated(uint256 newDuration);


   constructor(
      address stakingToken_,
      address rewardsToken_,
      uint256 waitTime_,
      address timelock_
   ) {
      require(
         stakingToken_ != address(0) &&
            rewardsToken_ != address(0) &&
            timelock_ != address(0),
         "Address can't be 0"
      );
      require(
         IGovernanceToken(stakingToken_).decimals() == 18 &&
            IGovernanceToken(rewardsToken_).decimals() == 18,
         "Decimals must be 18"
      );
      stakingToken = stakingToken_;
      rewardsToken = rewardsToken_;
      waitTime = waitTime_;
      transferOwnership(timelock_);
   }


   function updateReward(address account_) private {

      rewardPerTokenStored = rewardPerToken();
      lastUpdateTime = lastTimeRewardApplicable();

      if (account_ != address(0)) {
         rewards[account_] = currentEarned(account_);
         userRewardPerTokenPaid[account_] = rewardPerTokenStored;
      }
   }

   function notifyRewardAmount(uint256 reward_) external onlyOwner {

      updateReward(address(0));
      if (block.timestamp >= periodFinish) {
         rewardRate = reward_ / rewardsDuration;
      } else {
         uint256 remaining = periodFinish - block.timestamp;
         uint256 leftover = remaining * rewardRate;
         rewardRate = (reward_ + leftover) / rewardsDuration;
      }

      lastUpdateTime = block.timestamp;
      periodFinish = block.timestamp + rewardsDuration;

      uint256 balance = IGovernanceToken(rewardsToken).balanceOf(address(this));
      require(
         rewardRate <= balance / rewardsDuration,
         "Provided reward too high"
      );
      emit RewardAdded(reward_);
   }

   function setRewardsDuration(uint256 rewardsDuration_) external onlyOwner {

      require(
         block.timestamp > periodFinish,
         "Previous rewards period must be complete before changing the duration for the new period"
      );
      rewardsDuration = rewardsDuration_;
      emit RewardsDurationUpdated(rewardsDuration);
   }

   function getReward() external nonReentrant {

      updateReward(msg.sender);
      uint256 reward = rewards[msg.sender];
      if (reward > 0) {
         rewards[msg.sender] = 0;
         require(
            IGovernanceToken(rewardsToken).transfer(msg.sender, reward),
            "Transfer Failed"
         );
         emit RewardPaid(msg.sender, reward);
      }
   }

   function createDelegator(address delegatee_) external {

      require(delegatee_ != address(0), "Delegatee can't be 0");
      require(
         delegateeToDelegator[delegatee_] == address(0),
         "Delegator already created"
      );
      Delegator delegator = new Delegator(delegatee_, stakingToken);
      delegateeToDelegator[delegatee_] = address(delegator);
      delegatorToDelegatee[address(delegator)] = delegatee_;
      delegators[address(delegator)] = true;
      emit DelegatorCreated(address(delegator), delegatee_);
   }

   function stake(address delegator_, uint256 amount_) external nonReentrant {

      require(delegators[delegator_], "Not a valid delegator");
      require(amount_ > 0, "Amount must be greater than 0");
      updateReward(msg.sender);
      _totalSupply = _totalSupply + amount_;
      _balances[msg.sender] = _balances[msg.sender] + amount_;
      Delegator d = Delegator(delegator_);
      d.stake(msg.sender, amount_);
      stakerWaitTime[msg.sender][delegator_] = block.timestamp + waitTime;
      require(
         IGovernanceToken(stakingToken).transferFrom(
            msg.sender,
            delegator_,
            amount_
         ),
         "Transfer Failed"
      );
      emit Staked(delegator_, msg.sender, amount_);
   }

   function withdraw(address delegator_, uint256 amount_)
      external
      nonReentrant
   {

      require(delegators[delegator_], "Not a valid delegator");
      require(amount_ > 0, "Amount must be greater than 0");
      require(
         block.timestamp >= stakerWaitTime[msg.sender][delegator_],
         "Need to wait the minimum staking period"
      );
      updateReward(msg.sender);
      _totalSupply = _totalSupply - amount_;
      _balances[msg.sender] = _balances[msg.sender] - amount_;
      Delegator d = Delegator(delegator_);
      d.removeStake(msg.sender, amount_);
      emit Withdrawn(delegator_, msg.sender, amount_);
   }

   function updateWaitTime(uint256 waitTime_) external onlyOwner {

      waitTime = waitTime_;
      emit WaitTimeUpdated(waitTime_);
   }


   function currentEarned(address account_) private view returns (uint256) {

      return
         (_balances[account_] *
            (rewardPerTokenStored - userRewardPerTokenPaid[account_])) /
         1e18 +
         rewards[account_];
   }

   function totalSupply() external view returns (uint256) {

      return _totalSupply;
   }

   function balanceOf(address account_) external view returns (uint256) {

      return _balances[account_];
   }

   function getRewardForDuration() external view returns (uint256) {

      return rewardRate * rewardsDuration;
   }

   function lastTimeRewardApplicable() public view returns (uint256) {

      return min(block.timestamp, periodFinish);
   }

   function rewardPerToken() public view returns (uint256) {

      if (_totalSupply == 0) {
         return rewardPerTokenStored;
      }

      return
         rewardPerTokenStored +
         ((lastTimeRewardApplicable() - lastUpdateTime) * rewardRate * 1e18) /
         _totalSupply;
   }

   function earned(address account_) public view returns (uint256) {

      return
         (_balances[account_] *
            (rewardPerToken() - userRewardPerTokenPaid[account_])) /
         1e18 +
         rewards[account_];
   }

   function min(uint256 a_, uint256 b_) public pure returns (uint256) {

      return a_ < b_ ? a_ : b_;
   }
}