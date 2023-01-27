
pragma solidity ^0.6.0;

library SafeMath {

    
    function mul(uint256 a, uint256 b) internal pure returns (uint256){

        if (a == 0) {
            return 0;
        }
        uint256 c = a * b;
        require(c / a == b,"Calculation error");
        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256){

        require(b > 0,"Calculation error");
        uint256 c = a / b;
        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256){

        require(b <= a,"Calculation error");
        uint256 c = a - b;
        return c;
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256){

        uint256 c = a + b;
        require(c >= a,"Calculation error");
        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256){

        require(b != 0,"Calculation error");
        return a % b;
    }
}

abstract contract ILPToken {
    function balanceOf(address) public virtual returns (uint256);
    function transfer(address, uint256) public virtual returns (bool);
    function transferFrom(address, address, uint256) public virtual returns (bool);
    function approve(address , uint256) public virtual returns (bool);
 }

abstract contract IToken {
    function balanceOf(address) public virtual returns (uint256);
    function transfer(address, uint256) public virtual returns (bool);
    function transferFrom(address, address, uint256) public virtual returns (bool);
    function approve(address , uint256) public virtual returns (bool);
 }

contract CLIQWETHLPStaking {

    
  using SafeMath for uint256;

  address private _owner;                                           // variable for Owner of the Contract.
  uint256 private _withdrawTime;                                    // variable to manage withdraw time for Token
  uint256 constant public PERIOD_SILVER            = 90;             // variable constant for time period managemnt
  uint256 constant public PERIOD_GOLD              = 180;            // variable constant for time period managemnt
  uint256 constant public PERIOD_PLATINUM          = 270;            // variable constant for time period managemnt
  uint256 constant public WITHDRAW_TIME_SILVER     = 45 * 1 days;    // variable constant to manage withdraw time lock up 
  uint256 constant public WITHDRAW_TIME_GOLD       = 90 * 1 days;    // variable constant to manage withdraw time lock up
  uint256 constant public WITHDRAW_TIME_PLATINUM   = 135 * 1 days;   // variable constant to manage withdraw time lock up
  uint256 public TOKEN_REWARD_PERCENT_SILVER       = 21788328;       // variable constant to manage token reward percentage for silver
  uint256 public TOKEN_REWARD_PERCENT_GOLD         = 67332005;       // variable constant to manage token reward percentage for gold
  uint256 public TOKEN_REWARD_PERCENT_PLATINUM     = 178233538;      // variable constant to manage token reward percentage for platinum
  uint256 public TOKEN_PENALTY_PERCENT_SILVER      = 10894164;       // variable constant to manage token penalty percentage for silver
  uint256 public TOKEN_PENALTY_PERCENT_GOLD        = 23566201;       // variable constant to manage token penalty percentage for gold
  uint256 public TOKEN_PENALTY_PERCENT_PLATINUM    = 44558384;       // variable constant to manage token penalty percentage for platinum
  
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
  
  ILPToken ilptoken;
  IToken itoken;
    
  function setContractAddresses(address lpTokenContractAddress, address tokenContractAddress) external onlyOwner returns(bool){

    ilptoken = ILPToken(lpTokenContractAddress);
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
  
  function setManager(uint256 tokenStakingCount, uint256 tokenTotalDays, address tokenStakingAddress, uint256 tokenStakingStartTime,
   uint256 tokenStakingEndTime, uint256 usertokens) external onlyOwner returns(bool){

    _tokenStakingCount = tokenStakingCount;
    _tokenTotalDays[_tokenStakingCount] = tokenTotalDays;
    _tokenStakingAddress[_tokenStakingCount] = tokenStakingAddress;
    _tokenStakingId[tokenStakingAddress].push(_tokenStakingCount);
    _tokenStakingEndTime[_tokenStakingCount] = tokenStakingEndTime;
    _tokenStakingStartTime[_tokenStakingCount] = tokenStakingStartTime;
    _usersTokens[_tokenStakingCount] = usertokens;
    _TokenTransactionstatus[_tokenStakingCount] = false;
    totalStakedToken = totalStakedToken.add(usertokens);
    totalTokenStakesInContract = totalTokenStakesInContract.add(usertokens);
    return true;
  }
  
  function setRewardPercent(uint256 silver, uint256 gold, uint256 platinum) external onlyOwner returns(bool){

    require(silver != 0 && gold != 0 && platinum !=0,"Invalid Reward Value or Zero value, Please Try Again!!!");
     TOKEN_REWARD_PERCENT_SILVER = silver;
     TOKEN_REWARD_PERCENT_GOLD = gold;
     TOKEN_REWARD_PERCENT_PLATINUM = platinum;
     return true;
  }
  
  function setPenaltyPercent(uint256 silver, uint256 gold, uint256 platinum) external onlyOwner returns(bool){

    require(silver != 0 && gold != 0 && platinum !=0,"Invalid Penalty Value or Zero value, Please Try Again!!!");
     TOKEN_PENALTY_PERCENT_SILVER = silver;
     TOKEN_PENALTY_PERCENT_GOLD = gold;
     TOKEN_PENALTY_PERCENT_PLATINUM = platinum;
     return true;
  }
  
  function withdrawLPToken(uint256 amount) external onlyOwner returns(bool){

      ilptoken.transfer(msg.sender,amount);
      return true;
  } 

  function withdrawToken(uint256 amount) external onlyOwner returns(bool){

      itoken.transfer(msg.sender,amount);
      return true;
  } 
  
  function withdrawETH() external onlyOwner returns(bool){

      msg.sender.transfer(address(this).balance);
      return true;
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
  
  modifier tokenStakeCheck(uint256 tokens, uint256 timePeriod){

    require(tokens > 0, "Invalid Token Amount, Please Try Again!!! ");
    require(timePeriod == PERIOD_SILVER || timePeriod == PERIOD_GOLD || timePeriod == PERIOD_PLATINUM, "Enter the Valid Time Period and Try Again !!!");
    _;
  }
  

  function stakeToken(uint256 tokens, uint256 time) public tokenStakeCheck(tokens, time) returns(bool){

    require(tokenPaused == false, "Staking is Paused, Please try after staking get unpaused!!!");
    _tokentime = now + (time * 1 days);
    _tokenStakingCount = _tokenStakingCount + 1;
    _tokenTotalDays[_tokenStakingCount] = time;
    _tokenStakingAddress[_tokenStakingCount] = msg.sender;
    _tokenStakingId[msg.sender].push(_tokenStakingCount);
    _tokenStakingEndTime[_tokenStakingCount] = _tokentime;
    _tokenStakingStartTime[_tokenStakingCount] = now;
    _usersTokens[_tokenStakingCount] = tokens;
    _TokenTransactionstatus[_tokenStakingCount] = false;
    totalStakedToken = totalStakedToken.add(tokens);
    totalTokenStakesInContract = totalTokenStakesInContract.add(tokens);
    ilptoken.transferFrom(msg.sender, address(this), tokens);
    return true;
  }

  function getTokenStakingCount() public view returns(uint256){

    return _tokenStakingCount;
  }
  
  function getTotalStakedToken() public view returns(uint256){

    return totalStakedToken;
  }
  
  function getTokenRewardDetailsByStakingId(uint256 id) public view returns(uint256){

    if(_tokenTotalDays[id] == PERIOD_SILVER) {
        return (_usersTokens[id]*TOKEN_REWARD_PERCENT_SILVER/100000000);
    } else if(_tokenTotalDays[id] == PERIOD_GOLD) {
               return (_usersTokens[id]*TOKEN_REWARD_PERCENT_GOLD/100000000);
      } else if(_tokenTotalDays[id] == PERIOD_PLATINUM) { 
                 return (_usersTokens[id]*TOKEN_REWARD_PERCENT_PLATINUM/100000000);
        } else{
              return 0;
          }
  }

  function getTokenPenaltyDetailByStakingId(uint256 id) public view returns(uint256){

    if(_tokenStakingEndTime[id] > now){
        if(_tokenTotalDays[id]==PERIOD_SILVER){
            return (_usersTokens[id]*TOKEN_PENALTY_PERCENT_SILVER/100000000);
        } else if(_tokenTotalDays[id] == PERIOD_GOLD) {
              return (_usersTokens[id]*TOKEN_PENALTY_PERCENT_GOLD/100000000);
          } else if(_tokenTotalDays[id] == PERIOD_PLATINUM) { 
                return (_usersTokens[id]*TOKEN_PENALTY_PERCENT_PLATINUM/100000000);
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
    if(_tokenTotalDays[stakingId] == PERIOD_SILVER){
          require(now >= _tokenStakingStartTime[stakingId] + WITHDRAW_TIME_SILVER, "Unable to Withdraw Staked token before 45 days of staking start time, Please Try Again Later!!!");
          _TokenTransactionstatus[stakingId] = true;
          if(now >= _tokenStakingEndTime[stakingId]){
              _finalTokenStakeWithdraw[stakingId] = _usersTokens[stakingId].add(getTokenRewardDetailsByStakingId(stakingId));
              ilptoken.transfer(msg.sender,_usersTokens[stakingId]);
              itoken.transfer(msg.sender,getTokenRewardDetailsByStakingId(stakingId));
              totalTokenStakesInContract = totalTokenStakesInContract.sub(_usersTokens[stakingId]);
              _ownerTokenAllowance = _ownerTokenAllowance.sub(getTokenRewardDetailsByStakingId(stakingId));
          } else {
              _finalTokenStakeWithdraw[stakingId] = _usersTokens[stakingId].add(getTokenPenaltyDetailByStakingId(stakingId));
              ilptoken.transfer(msg.sender,_usersTokens[stakingId]);
              itoken.transfer(msg.sender,getTokenPenaltyDetailByStakingId(stakingId));
              totalTokenStakesInContract = totalTokenStakesInContract.sub(_usersTokens[stakingId]);
              _ownerTokenAllowance = _ownerTokenAllowance.sub(getTokenPenaltyDetailByStakingId(stakingId));
            }
    } else if(_tokenTotalDays[stakingId] == PERIOD_GOLD){
          require(now >= _tokenStakingStartTime[stakingId] + WITHDRAW_TIME_GOLD, "Unable to Withdraw Staked token before 90 days of staking start time, Please Try Again Later!!!");
          _TokenTransactionstatus[stakingId] = true;
          if(now >= _tokenStakingEndTime[stakingId]){
              _finalTokenStakeWithdraw[stakingId] = _usersTokens[stakingId].add(getTokenRewardDetailsByStakingId(stakingId));
              ilptoken.transfer(msg.sender,_usersTokens[stakingId]);
              itoken.transfer(msg.sender,getTokenRewardDetailsByStakingId(stakingId));
              totalTokenStakesInContract = totalTokenStakesInContract.sub(_usersTokens[stakingId]);
              _ownerTokenAllowance = _ownerTokenAllowance.sub(getTokenRewardDetailsByStakingId(stakingId));
          } else {
              _finalTokenStakeWithdraw[stakingId] = _usersTokens[stakingId].add(getTokenPenaltyDetailByStakingId(stakingId));
              ilptoken.transfer(msg.sender,_usersTokens[stakingId]);
              itoken.transfer(msg.sender,getTokenPenaltyDetailByStakingId(stakingId));
              totalTokenStakesInContract = totalTokenStakesInContract.sub(_usersTokens[stakingId]);
              _ownerTokenAllowance = _ownerTokenAllowance.sub(getTokenPenaltyDetailByStakingId(stakingId));
            }
    } else if(_tokenTotalDays[stakingId] == PERIOD_PLATINUM){
          require(now >= _tokenStakingStartTime[stakingId] + WITHDRAW_TIME_PLATINUM, "Unable to Withdraw Staked token before 135 days of staking start time, Please Try Again Later!!!");
          _TokenTransactionstatus[stakingId] = true;
          if(now >= _tokenStakingEndTime[stakingId]){
              _finalTokenStakeWithdraw[stakingId] = _usersTokens[stakingId].add(getTokenRewardDetailsByStakingId(stakingId));
              ilptoken.transfer(msg.sender,_usersTokens[stakingId]);
              itoken.transfer(msg.sender,getTokenRewardDetailsByStakingId(stakingId));
              totalTokenStakesInContract = totalTokenStakesInContract.sub(_usersTokens[stakingId]);
              _ownerTokenAllowance = _ownerTokenAllowance.sub(getTokenRewardDetailsByStakingId(stakingId));
          } else {
              _finalTokenStakeWithdraw[stakingId] = _usersTokens[stakingId].add(getTokenPenaltyDetailByStakingId(stakingId));
              ilptoken.transfer(msg.sender,_usersTokens[stakingId]);
              itoken.transfer(msg.sender,getTokenPenaltyDetailByStakingId(stakingId));
              totalTokenStakesInContract = totalTokenStakesInContract.sub(_usersTokens[stakingId]);
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
  
  function getTokenStakingIdByAddress(address add) external view returns(uint256[] memory){

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