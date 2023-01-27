
pragma solidity ^0.4.24;

library SafeMath {

    
    function mul(uint256 a, uint256 b) internal pure returns (uint256){

        if (a == 0) {
            return 0;
        }
        uint256 c = a * b;
        require(c / a == b,"Calculation error in multiplication");
        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256){

        require(b > 0,"Calculation error in division");
        uint256 c = a / b;
        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256){

        require(b <= a,"Calculation error in subtraction");
        uint256 c = a - b;
        return c;
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256){

        uint256 c = a + b;
        require(c >= a,"Calculation error in addition");
        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256){

        require(b != 0,"Calculation error");
        return a % b;
    }
}

contract IToken {

    function totalSupply() public pure returns (uint256);

    function balanceOf(address) public pure returns (uint256);

    function allowance(address, address) public pure returns (uint256);

    function transfer(address, uint256) public pure returns (bool);

    function transferFrom(address, address, uint256) public pure returns (bool);

    function approve(address, uint256) public pure returns (bool);

 }

contract CoretoStaking {

    
  using SafeMath for uint256;
  address private _owner;                                                      // variable for Owner of the Contract.
  uint256 private _withdrawTime;                                               // variable to manage withdraw time for token
  uint256 constant public PERIOD_SERENITY                     = 90;            // variable constant for time period management for serenity pool
  uint256 constant public PERIOD_EQUILIBRIUM                  = 180;           // variable constant for time period management for equilibrium pool
  uint256 constant public PERIOD_TRANQUILLITY                 = 270;           // variable constant for time period management for tranquillity pool
  uint256 constant public WITHDRAW_TIME_SERENITY              = 45 * 1 days;   // variable constant to manage withdraw time lock up for serenity
  uint256 constant public WITHDRAW_TIME_EQUILIBRIUM           = 90 * 1 days;   // variable constant to manage withdraw time lock up for equilibrium
  uint256 constant public WITHDRAW_TIME_TRANQUILLITY          = 135 * 1 days;  // variable constant to manage withdraw time lock up for tranquillity
  uint256 constant public TOKEN_REWARD_PERCENT_SERENITY       = 3555807;       // variable constant to manage token reward percentage for serenity
  uint256 constant public TOKEN_REWARD_PERCENT_EQUILIBRIUM    = 10905365;      // variable constant to manage token reward percentage for equilibrium
  uint256 constant public TOKEN_REWARD_PERCENT_TRANQUILLITY   = 26010053;      // variable constant to manage token reward percentage for tranquillity
  uint256 constant public TOKEN_PENALTY_PERCENT_SERENITY      = 2411368;       // variable constant to manage token penalty percentage for serenity
  uint256 constant public TOKEN_PENALTY_PERCENT_EQUILIBRIUM   = 7238052;       // variable constant to manage token penalty percentage for equilibrium
  uint256 constant public TOKEN_PENALTY_PERCENT_TRANQUILLITY  = 14692434;      // variable constant to manage token penalty percentage for tranquillity
  uint256 constant public TOKEN_POOL_CAP              = 25000000*(10**18);     // variable constant to store maximaum pool cap value
  
  event Paused();
  event Unpaused();
  

   function getowner() public view returns (address) {

     return _owner;
   }

   modifier onlyOwner() {

     require(isOwner(),"You are not authenticate to make this transfer");
     _;
   }

   function isOwner() internal view returns (bool) {

      return msg.sender == _owner;
   }

   function transferOwnership(address newOwner) public onlyOwner returns (bool){

      _owner = newOwner;
      return true;
   }
   
  
  constructor() public {
     _owner = msg.sender;
  }
  
  IToken itoken;
    
  function setContractAddress(address tokenContractAddress) external onlyOwner returns(bool){

    itoken = IToken(tokenContractAddress);
    return true;
  }
  
  
  function addTokenReward(uint256 token) external onlyOwner returns(bool){

    _ownerTokenAllowance = _ownerTokenAllowance.add(token);
    itoken.transferFrom(msg.sender, address(this), token);
    return true;
  }
  
  function withdrawAddedTokenReward(uint256 token) external onlyOwner returns(bool){

    require(token < _ownerTokenAllowance,"Value is not feasible, Please Try Again!!!");
    _ownerTokenAllowance = _ownerTokenAllowance.sub(token);
    itoken.transfer(msg.sender, token);
    return true;
  }
  
  function getTokenReward() public view returns(uint256){

    return _ownerTokenAllowance;
  }
  
  function pauseTokenStaking() public onlyOwner {

    tokenPaused = true;
    emit Paused();
  }

  function unpauseTokenStaking() public onlyOwner {

    tokenPaused = false;
    emit Unpaused();
  }

  
  mapping (uint256 => address) private _tokenStakingAddress;
  
  mapping (address => uint256[]) private _tokenStakingId;

  mapping (uint256 => uint256) private _tokenStakingStartTime;
  
  mapping (uint256 => uint256) private _tokenStakingEndTime;

  mapping (uint256 => uint256) private _usersTokens;
  
  mapping (uint256 => bool) private _TokenTransactionstatus;    
  
  mapping(uint256=>uint256) private _finalTokenStakeWithdraw;
  
  mapping(uint256=>uint256) private _tokenTotalDays;
  
  uint256 private _tokenStakingCount = 0;
  
  uint256 private _ownerTokenAllowance = 0;

  uint256 private _tokentime;
  
  bool public tokenPaused = false;
  
  uint256 public totalStakedToken = 0;
  
  uint256 public totalTokenStakesInContract = 0;
  
  uint256 public totalStakedTokenInSerenityPool = 0;
  
  uint256 public totalStakedTokenInEquilibriumPool = 0;
  
  uint256 public totalStakedTokenInTranquillityPool = 0;
  
  modifier tokenStakeCheck(uint256 tokens, uint256 timePeriod){

    require(tokens > 0, "Invalid Token Amount, Please Try Again!!! ");
    require(timePeriod == PERIOD_SERENITY || timePeriod == PERIOD_EQUILIBRIUM || timePeriod == PERIOD_TRANQUILLITY, "Enter the Valid Time Period and Try Again !!!");
    _;
  }
  

  function stakeToken(uint256 tokens, uint256 time) public tokenStakeCheck(tokens, time) returns(bool){

    require(tokenPaused == false, "Staking is Paused, Please try after staking get unpaused!!!");
    if(time == PERIOD_SERENITY){
        require(totalStakedTokenInSerenityPool.add(tokens) <= TOKEN_POOL_CAP, "Serenity Pool Limit Reached");
        _tokentime = now + (time * 1 days);
        _tokenStakingCount = _tokenStakingCount +1;
        _tokenTotalDays[_tokenStakingCount] = time;
        _tokenStakingAddress[_tokenStakingCount] = msg.sender;
        _tokenStakingId[msg.sender].push(_tokenStakingCount);
        _tokenStakingEndTime[_tokenStakingCount] = _tokentime;
        _tokenStakingStartTime[_tokenStakingCount] = now;
        _usersTokens[_tokenStakingCount] = tokens;
        _TokenTransactionstatus[_tokenStakingCount] = false;
        totalStakedToken = totalStakedToken.add(tokens);
        totalTokenStakesInContract = totalTokenStakesInContract.add(tokens);
        totalStakedTokenInSerenityPool = totalStakedTokenInSerenityPool.add(tokens);
        itoken.transferFrom(msg.sender, address(this), tokens);
    } else if (time == PERIOD_EQUILIBRIUM) {
        require(totalStakedTokenInEquilibriumPool.add(tokens) <= TOKEN_POOL_CAP, "Equilibrium Pool Limit Reached");
        _tokentime = now + (time * 1 days);
        _tokenStakingCount = _tokenStakingCount +1;
        _tokenTotalDays[_tokenStakingCount] = time;
        _tokenStakingAddress[_tokenStakingCount] = msg.sender;
        _tokenStakingId[msg.sender].push(_tokenStakingCount);
        _tokenStakingEndTime[_tokenStakingCount] = _tokentime;
        _tokenStakingStartTime[_tokenStakingCount] = now;
        _usersTokens[_tokenStakingCount] = tokens;
        _TokenTransactionstatus[_tokenStakingCount] = false;
        totalStakedToken = totalStakedToken.add(tokens);
        totalTokenStakesInContract = totalTokenStakesInContract.add(tokens);
        totalStakedTokenInEquilibriumPool = totalStakedTokenInEquilibriumPool.add(tokens);
        itoken.transferFrom(msg.sender, address(this), tokens);
    } else if(time == PERIOD_TRANQUILLITY) {
        require(totalStakedTokenInTranquillityPool.add(tokens) <= TOKEN_POOL_CAP, "Tranquillity Pool Limit Reached");
        _tokentime = now + (time * 1 days);
        _tokenStakingCount = _tokenStakingCount +1;
        _tokenTotalDays[_tokenStakingCount] = time;
        _tokenStakingAddress[_tokenStakingCount] = msg.sender;
        _tokenStakingId[msg.sender].push(_tokenStakingCount);
        _tokenStakingEndTime[_tokenStakingCount] = _tokentime;
        _tokenStakingStartTime[_tokenStakingCount] = now;
        _usersTokens[_tokenStakingCount] = tokens;
        _TokenTransactionstatus[_tokenStakingCount] = false;
        totalStakedToken = totalStakedToken.add(tokens);
        totalTokenStakesInContract = totalTokenStakesInContract.add(tokens);
        totalStakedTokenInTranquillityPool = totalStakedTokenInTranquillityPool.add(tokens);
        itoken.transferFrom(msg.sender, address(this), tokens);
    } else {
        return false;
      }
    return true;
  }

  function getTokenStakingCount() public view returns(uint256){

    return _tokenStakingCount;
  }
  
  function getTotalStakedToken() public view returns(uint256){

    return totalStakedToken;
  }
  
  function getTokenRewardDetailsByStakingId(uint256 id) public view returns(uint256){

    if(_tokenTotalDays[id] == PERIOD_SERENITY) {
        return (_usersTokens[id]*TOKEN_REWARD_PERCENT_SERENITY/100000000);
    } else if(_tokenTotalDays[id] == PERIOD_EQUILIBRIUM) {
               return (_usersTokens[id]*TOKEN_REWARD_PERCENT_EQUILIBRIUM/100000000);
      } else if(_tokenTotalDays[id] == PERIOD_TRANQUILLITY) { 
                 return (_usersTokens[id]*TOKEN_REWARD_PERCENT_TRANQUILLITY/100000000);
        } else{
              return 0;
          }
  }

  function getTokenPenaltyDetailByStakingId(uint256 id) public view returns(uint256){

    if(_tokenStakingEndTime[id] > now){
        if(_tokenTotalDays[id]==PERIOD_SERENITY){
            return (_usersTokens[id]*TOKEN_PENALTY_PERCENT_SERENITY/100000000);
        } else if(_tokenTotalDays[id] == PERIOD_EQUILIBRIUM) {
              return (_usersTokens[id]*TOKEN_PENALTY_PERCENT_EQUILIBRIUM/100000000);
          } else if(_tokenTotalDays[id] == PERIOD_TRANQUILLITY) { 
                return (_usersTokens[id]*TOKEN_PENALTY_PERCENT_TRANQUILLITY/100000000);
            } else {
                return 0;
              }
    } else{
       return 0;
     }
  }
 
  function withdrawStakedTokens(uint256 stakingId) public returns(bool) {

    require(_tokenStakingAddress[stakingId] == msg.sender,"No staked token found on this address and ID");
    require(_TokenTransactionstatus[stakingId] != true,"Either tokens are already withdrawn or blocked by admin");
    if(_tokenTotalDays[stakingId] == PERIOD_SERENITY){
          require(now >= _tokenStakingStartTime[stakingId] + WITHDRAW_TIME_SERENITY, "Unable to Withdraw Staked token before 45 days of staking start time, Please Try Again Later!!!");
          _TokenTransactionstatus[stakingId] = true;
          if(now >= _tokenStakingEndTime[stakingId]){
              _finalTokenStakeWithdraw[stakingId] = _usersTokens[stakingId].add(getTokenRewardDetailsByStakingId(stakingId));
              itoken.transfer(msg.sender,_finalTokenStakeWithdraw[stakingId]);
              totalTokenStakesInContract = totalTokenStakesInContract.sub(_usersTokens[stakingId]);
              totalStakedTokenInSerenityPool = totalStakedTokenInSerenityPool.sub(_usersTokens[stakingId]);
              _ownerTokenAllowance = _ownerTokenAllowance.sub(getTokenRewardDetailsByStakingId(stakingId));
          } else {
              _finalTokenStakeWithdraw[stakingId] = _usersTokens[stakingId].add(getTokenPenaltyDetailByStakingId(stakingId));
              itoken.transfer(msg.sender,_finalTokenStakeWithdraw[stakingId]);
              totalTokenStakesInContract = totalTokenStakesInContract.sub(_usersTokens[stakingId]);
              totalStakedTokenInSerenityPool = totalStakedTokenInSerenityPool.sub(_usersTokens[stakingId]);
              _ownerTokenAllowance = _ownerTokenAllowance.sub(getTokenPenaltyDetailByStakingId(stakingId));
            }
    } else if(_tokenTotalDays[stakingId] == PERIOD_EQUILIBRIUM){
          require(now >= _tokenStakingStartTime[stakingId] + WITHDRAW_TIME_EQUILIBRIUM, "Unable to Withdraw Staked token before 90 days of staking start time, Please Try Again Later!!!");
          _TokenTransactionstatus[stakingId] = true;
          if(now >= _tokenStakingEndTime[stakingId]){
              _finalTokenStakeWithdraw[stakingId] = _usersTokens[stakingId].add(getTokenRewardDetailsByStakingId(stakingId));
              itoken.transfer(msg.sender,_finalTokenStakeWithdraw[stakingId]);
              totalTokenStakesInContract = totalTokenStakesInContract.sub(_usersTokens[stakingId]);
              totalStakedTokenInEquilibriumPool = totalStakedTokenInEquilibriumPool.sub(_usersTokens[stakingId]);
              _ownerTokenAllowance = _ownerTokenAllowance.sub(getTokenRewardDetailsByStakingId(stakingId));
          } else {
              _finalTokenStakeWithdraw[stakingId] = _usersTokens[stakingId].add(getTokenPenaltyDetailByStakingId(stakingId));
              itoken.transfer(msg.sender,_finalTokenStakeWithdraw[stakingId]);
              totalTokenStakesInContract = totalTokenStakesInContract.sub(_usersTokens[stakingId]);
              totalStakedTokenInEquilibriumPool = totalStakedTokenInEquilibriumPool.sub(_usersTokens[stakingId]);
              _ownerTokenAllowance = _ownerTokenAllowance.sub(getTokenPenaltyDetailByStakingId(stakingId));
            }
    } else if(_tokenTotalDays[stakingId] == PERIOD_TRANQUILLITY){
          require(now >= _tokenStakingStartTime[stakingId] + WITHDRAW_TIME_TRANQUILLITY, "Unable to Withdraw Staked token before 135 days of staking start time, Please Try Again Later!!!");
          _TokenTransactionstatus[stakingId] = true;
          if(now >= _tokenStakingEndTime[stakingId]){
              _finalTokenStakeWithdraw[stakingId] = _usersTokens[stakingId].add(getTokenRewardDetailsByStakingId(stakingId));
              itoken.transfer(msg.sender,_finalTokenStakeWithdraw[stakingId]);
              totalTokenStakesInContract = totalTokenStakesInContract.sub(_usersTokens[stakingId]);
              totalStakedTokenInTranquillityPool = totalStakedTokenInTranquillityPool.sub(_usersTokens[stakingId]);
              _ownerTokenAllowance = _ownerTokenAllowance.sub(getTokenRewardDetailsByStakingId(stakingId));
          } else {
              _finalTokenStakeWithdraw[stakingId] = _usersTokens[stakingId].add(getTokenPenaltyDetailByStakingId(stakingId));
              itoken.transfer(msg.sender,_finalTokenStakeWithdraw[stakingId]);
              totalTokenStakesInContract = totalTokenStakesInContract.sub(_usersTokens[stakingId]);
              totalStakedTokenInTranquillityPool = totalStakedTokenInTranquillityPool.sub(_usersTokens[stakingId]);
              _ownerTokenAllowance = _ownerTokenAllowance.sub(getTokenPenaltyDetailByStakingId(stakingId));
            }
    } else {
        return false;
      }
    return true;
  }
  
  function getFinalTokenStakeWithdraw(uint256 id) public view returns(uint256){

    return _finalTokenStakeWithdraw[id];
  }
  
  function getTotalTokenStakesInContract() public view returns(uint256){

      return totalTokenStakesInContract;
  }
  

  function getTokenStakingAddressById(uint256 id) external view returns (address){

    require(id <= _tokenStakingCount,"Unable to reterive data on specified id, Please try again!!");
    return _tokenStakingAddress[id];
  }
  
  function getTokenStakingIdByAddress(address add) external view returns(uint256[]){

    require(add != address(0),"Invalid Address, Pleae Try Again!!!");
    return _tokenStakingId[add];
  }
  
  function getTokenStakingStartTimeById(uint256 id) external view returns(uint256){

    require(id <= _tokenStakingCount,"Unable to reterive data on specified id, Please try again!!");
    return _tokenStakingStartTime[id];
  }
  
  function getTokenStakingEndTimeById(uint256 id) external view returns(uint256){

    require(id <= _tokenStakingCount,"Unable to reterive data on specified id, Please try again!!");
    return _tokenStakingEndTime[id];
  }
  
  function getTokenStakingTotalDaysById(uint256 id) external view returns(uint256){

    require(id <= _tokenStakingCount,"Unable to reterive data on specified id, Please try again!!");
    return _tokenTotalDays[id];
  }

  function getStakingTokenById(uint256 id) external view returns(uint256){

    require(id <= _tokenStakingCount,"Unable to reterive data on specified id, Please try again!!");
    return _usersTokens[id];
  }

  function getTokenLockStatus(uint256 id) external view returns(bool){

    require(id <= _tokenStakingCount,"Unable to reterive data on specified id, Please try again!!");
    return _TokenTransactionstatus[id];
  }

}