

pragma solidity >=0.4.24 <0.7.0;


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

    address self = address(this);
    uint256 cs;
    assembly { cs := extcodesize(self) }
    return cs == 0;
  }

  uint256[50] private ______gap;
}


pragma solidity ^0.6.0;


contract ContextUpgradeSafe is Initializable {


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
}


pragma solidity ^0.6.0;


contract OwnableUpgradeSafe is Initializable, ContextUpgradeSafe {

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


    function owner() public view returns (address) {

        return _owner;
    }

    modifier onlyOwner() {

        require(_owner == _msgSender(), "Ownable: caller is not the owner");
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
}


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
}


pragma solidity ^0.6.0;

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


pragma solidity ^0.6.0;
pragma experimental ABIEncoderV2;









contract YieldFarming is OwnableUpgradeSafe {

    using SafeMath for uint256;
    

    IERC20 public sqrl;
    address public sqrlAddress;

    
    struct Plan {
        address sourceToken;
        uint256 tokenMultiplier; // actual multipler = tokenMultiplier / tokenMultiplierDivisor
        uint256 tokenMultiplierDivisor; // actual multipler = tokenMultiplier / tokenMultiplierDivisor
        uint256 multiplierCyclePeriod; // in seconds
        uint256 multiplierMaxCycle; // maximum number of times
        uint256 minimumTokensRequired;
        address planAuthor;
        bool planEnabled;
    }

    Plan[] public plans;

    struct UserInfo {
        uint256 _amount;
        address _tokenType;
        uint256 _timestamp;
    }

    uint256 lastRewardBalance;

    mapping (address => mapping(uint256 => UserInfo)) public userInfo;
    

    event ChangeByAddPlan(address planAuthor, uint256 planId);

    event ChangeByUpdatePlan(address planAuthor, uint256 planId);

    event StakeEvent(address indexed user, uint256 planId, uint256 amount);
    
    event UnstakeEvent(address indexed user, uint256 planId, uint256 amount);

    event UnstakeRewardEvent(address indexed user, uint256 planId, uint256 rewardAmount);

    event EmergencyWithdrawal(address user, uint256 amount);

    event OverallRewardBalanceEvent(uint256 rewardBalance);

    event RewardBalanceNow(uint256 rewardBalance);
    

    function initialize(address _sqrlAddress, uint256 _lastRewardBalance) public initializer {

        OwnableUpgradeSafe.__Ownable_init();
        sqrl = IERC20(_sqrlAddress);
        sqrlAddress = _sqrlAddress;
        lastRewardBalance = _lastRewardBalance;
    }


    function addPlan(address _sourceToken, uint256 _tokenMultiplier, uint256 _tokenMultiplierDivisor, uint256 _multiplierCyclePeriod, uint256 _multiplierMaxCycle, uint256 _minimumTokensRequired, bool _planEnabled) public onlyOwner returns(Plan[] memory) {

        Plan storage _newPlan = plans.push();
        _newPlan.sourceToken = _sourceToken;
        _newPlan.tokenMultiplier = _tokenMultiplier;
        _newPlan.tokenMultiplierDivisor = _tokenMultiplierDivisor;
        _newPlan.multiplierCyclePeriod = _multiplierCyclePeriod;
        _newPlan.multiplierMaxCycle = _multiplierMaxCycle;
        _newPlan.minimumTokensRequired = _minimumTokensRequired;
        _newPlan.planAuthor = msg.sender;
        _newPlan.planEnabled = _planEnabled;

        emit ChangeByAddPlan(msg.sender, plans.length - 1);
        return plans;
    }

    function storageDisablePlan(uint256 _planId, Plan[] storage plansArray, bool _planEnableDisable) internal {

        plansArray[_planId].planEnabled = _planEnableDisable;
    }

    function switchPlan(uint256 _planId) public onlyOwner returns(Plan[] memory) {

        
        bool _planEnableDisable;

        if (plans[_planId].planEnabled == true){
            _planEnableDisable = false;
        }else{
            _planEnableDisable = true;
        }

        storageDisablePlan(_planId, plans, _planEnableDisable);

        emit ChangeByUpdatePlan(msg.sender, _planId);

        return plans;
    }

    function getPlans() public view returns(Plan[] memory) {

        return plans;
    }

    function stake(uint256 _planId, uint256 _stakeAmount) public {


        address _tokenType = plans[_planId].sourceToken;

        require(IERC20(_tokenType).balanceOf(msg.sender) > 0, "Insufficient token balance.");
        require(_stakeAmount <= IERC20(_tokenType).balanceOf(msg.sender), "You cannot stake more than what you own.");
        require(plans[_planId].planEnabled, "This reward plan is disabled.");
        require(userInfo[msg.sender][_planId]._amount == 0, "You have already staked in this reward plan.");
        require(plans[_planId].minimumTokensRequired <= IERC20(_tokenType).balanceOf(msg.sender), "You do not have sufficient balance to stake.");
        require(plans[_planId].minimumTokensRequired <= _stakeAmount, "You are not allowed to stake below the minimum token amount required to participate in this reward plan.");

        IERC20(_tokenType).transferFrom(msg.sender, address(this), _stakeAmount);
        UserInfo storage user = userInfo[msg.sender][_planId];
        user._amount = _stakeAmount;
        user._tokenType = _tokenType;
        user._timestamp = now;
        

        emit StakeEvent(msg.sender, _planId, _stakeAmount);
    }

    function unstake(uint256 _planId) public {


        require(userInfo[msg.sender][_planId]._amount > 0, "You have not yet staked for this plan.");

        uint256 _rewardAmount = calculateReward(_planId, userInfo[msg.sender][_planId]._amount, userInfo[msg.sender][_planId]._timestamp);
        uint _stakedAmount = userInfo[msg.sender][_planId]._amount;

        if(plans[_planId].sourceToken == sqrlAddress){
            sqrl.transfer(msg.sender, _rewardAmount.add(_stakedAmount));
            lastRewardBalance = lastRewardBalance.sub(_rewardAmount);
        }
        else{
            sqrl.transfer(msg.sender, _rewardAmount);
            lastRewardBalance = lastRewardBalance.sub(_rewardAmount);

            IERC20(plans[_planId].sourceToken).transfer(msg.sender, _stakedAmount); 
        }

        userInfo[msg.sender][_planId]._amount = 0;
        userInfo[msg.sender][_planId]._tokenType = 0x0000000000000000000000000000000000000000;        
        userInfo[msg.sender][_planId]._timestamp = 0;

        emit UnstakeEvent(msg.sender, _planId, _stakedAmount);
        emit UnstakeRewardEvent(msg.sender, _planId, _rewardAmount);

        emit OverallRewardBalanceEvent(lastRewardBalance);
    }

    function safeUnstakingTransfer(uint256 _intendedRewardAmount) internal view returns (uint256) {


        uint256 _sqrlBalance = lastRewardBalance;

        if(_intendedRewardAmount > _sqrlBalance){
            return _sqrlBalance;
        }else{
            return _intendedRewardAmount;
        }

    }

    function calculateReward(uint256 _planId, uint256 _stakeAmount, uint256 _stakedTime) internal view returns (uint256 ){


        uint256 _TimeDifference = now.sub(_stakedTime);
        uint256 _FinalCycle;
        
        if(_TimeDifference.div(plans[_planId].multiplierCyclePeriod) < plans[_planId].multiplierMaxCycle){
            _FinalCycle = _TimeDifference.div(plans[_planId].multiplierCyclePeriod);
        }else{
            _FinalCycle = plans[_planId].multiplierMaxCycle;
        }

        uint256 _intendedRewardAmount = _stakeAmount;

        for(uint i=0; i<_FinalCycle; i++){
            _intendedRewardAmount = _intendedRewardAmount.mul(plans[_planId].tokenMultiplier).div(plans[_planId].tokenMultiplierDivisor);
        }
        _intendedRewardAmount = _intendedRewardAmount.sub(_stakeAmount);

        return safeUnstakingTransfer(_intendedRewardAmount);
    }

    function getUserReward(uint256 _planId) public view returns (uint256) {

        uint256 _rewardAmount = calculateReward(_planId, userInfo[msg.sender][_planId]._amount, userInfo[msg.sender][_planId]._timestamp);

        return _rewardAmount;
    }

    function getUserStake(uint256 _planId) public view returns (uint256) {


        return userInfo[msg.sender][_planId]._amount;
    }

    function getLastRewardBalance() public view returns (uint256) {


        return lastRewardBalance;
    }

    function emergencyWithdrawal() public onlyOwner {

        
        uint256 sqrlBalance = lastRewardBalance;

        sqrl.transfer(msg.sender, sqrlBalance);

        lastRewardBalance = 0;

        emit EmergencyWithdrawal(msg.sender, sqrlBalance);
        emit RewardBalanceNow(lastRewardBalance);
    }

    function addToRewardBalance(uint256 _additionalRewardAmount) public onlyOwner {


        lastRewardBalance = lastRewardBalance + _additionalRewardAmount;

        emit RewardBalanceNow(lastRewardBalance);
    }
}