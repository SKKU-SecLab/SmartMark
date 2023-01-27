

pragma solidity ^0.4.24;


contract DemocraticLuck {

  
  using SafeMath for uint256;
  
  event event_buyShare(address indexed _addr, uint256 indexed _indexNo, uint256 _num);
  event event_buyTicket(address indexed _addr, uint256 indexed _indexNo, uint256 _num);
  event event_shareholderVote(address indexed _addr, uint256 indexed _indexNo, uint256 _vote);  
  event event_endRound(uint256 indexed _indexNo, address indexed _addr, uint256 _prize);
  
  address private Owner; 
  uint256 private rdSharePrice = 1 ether;  //share's price
  uint256 private rdTicketPrice = 0.01 ether; //luck ticket's price
  uint256 private rdIndexNo = 0; //game round's index No  counter
  uint256 private userIDCnt = 0;  //user's id counter
  uint256 private rdStateActive = 1;  //game round's active state 
  uint256 private rdStateEnd = 2;   //game round's end state
  uint256 private rdTicketTime = 48 hours; //countdown time since a ticket was been bought
  uint256 private rdVoteTime = 24 hours; //vote time since countdown time over
  uint256 private serviceFee = 5; //system charge service fee rate
  uint256 private refererFee = 5; //referer user's prize percent 5%
  uint256 private sharePotRate = 70; //share price's percent into jackpot   
  uint256 private shrPrizeRate = 20; //share price's percent to distribute to current shares
  uint256 private shrLastBuyerRate = 10; //share price's percent to last share buyer
  uint256 private ticketPotRate = 50; //ticket price's percent to distribute to current shares
  uint256 private serviceFeeCnt; //owner service fee count
   
  struct userAcc{  
        uint256 purse; //user's purse
        uint256 refCode; //user's unique referrer code
        uint256 frefCode; //user from referrer code 
  }
  
  struct rdShareholder{
        uint256 cost;  //shareholder cost to buy share
        uint256 shareNum;  //shareholder's shares amount  
        uint256 shrAvgBonus;  //shareholder's shares average value to calculate bonus from later shares  
        uint256 shrTckAvgBonus;  //shareholder's shares average value to calculate bonus from tickets sale  
        uint256 vote; //shareholder's vote to coutinue or end game round
        uint256 lastShrVoteTime; //shareholder's last vote time       
  }  
  
  struct rdTckBuyer{ 
        uint256 cost;   //ticket buyer cost to buy ticket
        uint256 ticketNum; //ticket's amount
        uint256 tckAvgBonus; //ticket buyer's average value to calculate bonus from later tickets
  }
  
  struct rdInfo{ 
        uint256 state;   //round's state: 1,active 2,end
        uint256 sharePot;    //all share's capital pot
        uint256 shrJackpot;    //round's jackpot
        uint256 shareholderNum; //shareholders amount        
        uint256 shareNum;  //shares amount
        uint256 shrAvgBonus;  //round's shares average value to calculate bonus from later shares
        uint256 shrTckAvgBonus; //round's shares average value to calculate bonus from tickets sale
        uint256 ticketPot; //luck ticket sales amount 
        uint256 tckBuyerNum; //luck ticket buyers amount      
        uint256 ticketNum; //luck ticket's saled amount 
        uint256 tckAvgBonus; //round's ticket buyer's average value to calculate bonus from later tickets
        uint256 lastTckBuyTime; //time of last ticket was been bought 
        uint256 lastShrVoteTime;  //last time of shareholders vote
        uint256 shrVotesEnd;   //count of votes to end    
        address lastShareBuyer; //who bought the last share 
        address lastTckBuyer; //who bought the last luck ticket
   }

 
  mapping(uint256 => address) private userIDAddr; //user'id => user's account
  mapping(address => userAcc) private userAccs;  //user's account => user's account information
  mapping(address => uint256[]) private userUnWithdrawRound; //round list that user didn't withdraw yet  
  mapping(uint256 => mapping(address => rdShareholder)) private rdShareholders;  //round's index No => shareholder's account =>  shareholder's information  
  mapping(uint256 => rdInfo) private rdInfos;  //round's index No => round's information
  mapping(uint256 => mapping(address => rdTckBuyer)) private rdTckBuyers;  //round's index No => luck ticket buyer's account => ticket buyer's information  
 
  

  modifier onlyOwner()
  {

    require(Owner == msg.sender);
    _;
  }   
  
  modifier isPerson()
  {        

    address addr = msg.sender;
    uint256 size;
    
    assembly {size := extcodesize(addr)}
    require(size == 0);

    require(tx.origin == msg.sender);
    _;
  }
  
  constructor()
  public
  {
    Owner = msg.sender;   
    startNewRound();
  }
  
  function transferOwnership(address _owner)
  onlyOwner()
  public 
  { 

    Owner = _owner;
  }  
  
  function owner()
  public 
  view 
  returns (address _addr) 
  {

    return Owner;
  } 
  
  function startNewRound()
  internal
  {      

    rdIndexNo++;
    rdInfo memory rdInf = rdInfo(rdStateActive, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, address(0), address(0));
    rdInfos[rdIndexNo] = rdInf;
  } 
 
  function userRegister(uint256 _frefCode)
  isPerson() 
  public 
  {  

    require(msg.sender != address(0));
    require(!checkUserExist(msg.sender)); 
    
    addNewUser(msg.sender, _frefCode);        
  }    

  function addNewUser(address _addr, uint256 _frefCode)  
  internal 
  {  

    if(getAddrOfRefCode(_frefCode) == address(0))
          _frefCode = 0;          
    
    userIDCnt++;       
    userAcc memory uAcc = userAcc(0, userIDCnt, _frefCode);
    userAccs[_addr] = uAcc;      
    userIDAddr[userIDCnt] = _addr;                
  }    

  function addRdShareholder(uint256 _indexNo, address _addr)
  internal 
  {

    rdShareholder memory rdPly = rdShareholder(0, 0, 0, 0, 0, 0);
    rdShareholders[_indexNo][_addr] = rdPly;    
    rdInfos[_indexNo].shareholderNum++;
    if(!checkUserInUnWithdrawRd(_indexNo, _addr))
      userUnWithdrawRound[_addr].push(_indexNo);
  }  

  function addRdTicketBuyer(uint256 _indexNo, address _addr)
  internal 
  {

    rdTckBuyer memory rdPly = rdTckBuyer(0, 0, 0);
    rdTckBuyers[_indexNo][_addr] = rdPly;    
    rdInfos[_indexNo].tckBuyerNum++;
    if(!checkUserInUnWithdrawRd(_indexNo, _addr))
      userUnWithdrawRound[_addr].push(_indexNo);
  }  
  
  function buyShare(uint256 _indexNo, uint256 _frefCode)
  isPerson() 
  public 
  payable 
  {

    require(msg.sender != address(0)); 
    require(checkRdActive(_indexNo));    
    require(msg.value.sub(rdSharePrice) >= 0);
    
    uint256 _num = msg.value.div(rdSharePrice);
    uint256 cost = rdSharePrice.mul(_num);   

    if(!checkUserExist(msg.sender))
      addNewUser(msg.sender, _frefCode); 

    if(!checkShareholderInRd(_indexNo, msg.sender))
      addRdShareholder(_indexNo, msg.sender); 

    addRoundShare(_indexNo, msg.sender, cost, _num); 
    calcServiceFee(cost);   

    if(msg.value.sub(cost) > 0)
       userAccs[msg.sender].purse += msg.value.sub(cost);
    
    emit event_buyShare(msg.sender, _indexNo, _num);
  }  

  function addRoundShare(uint256 _indexNo, address _addr, uint256 _cost, uint256 _num)
  internal 
  {    

    rdInfos[_indexNo].lastShareBuyer = _addr;       
    rdInfos[_indexNo].shareNum += _num;
    rdInfos[_indexNo].sharePot = rdInfos[_indexNo].sharePot + _cost; 
    rdInfos[_indexNo].shrJackpot = rdInfos[_indexNo].shrJackpot + (_cost * sharePotRate / 100); 
    rdInfos[_indexNo].shrAvgBonus = rdInfos[_indexNo].shrAvgBonus + (_cost * shrPrizeRate / 100) / rdInfos[_indexNo].shareNum;
       
    rdShareholders[_indexNo][_addr].cost += _cost;         
    rdShareholders[_indexNo][_addr].shareNum += _num;  
    rdShareholders[_indexNo][_addr].shrAvgBonus = (rdInfos[_indexNo].shrAvgBonus * rdShareholders[_indexNo][_addr].shareNum - (rdInfos[_indexNo].shrAvgBonus - (_cost * shrPrizeRate / 100) / rdInfos[_indexNo].shareNum - rdShareholders[_indexNo][_addr].shrAvgBonus) * (rdShareholders[_indexNo][_addr].shareNum - _num) - (_cost * shrPrizeRate / 100) * rdShareholders[_indexNo][_addr].shareNum / rdInfos[_indexNo].shareNum) / rdShareholders[_indexNo][_addr].shareNum;     
    rdShareholders[_indexNo][_addr].shrTckAvgBonus = (rdInfos[_indexNo].shrTckAvgBonus * rdShareholders[_indexNo][_addr].shareNum - (rdInfos[_indexNo].shrTckAvgBonus - rdShareholders[_indexNo][_addr].shrTckAvgBonus) * (rdShareholders[_indexNo][_addr].shareNum - _num)) / rdShareholders[_indexNo][_addr].shareNum;       
  } 

  function buyTicket(uint256 _indexNo, uint256 _frefCode)
  isPerson() 
  public 
  payable 
  { 

    require(msg.sender != address(0)); 
    require(checkRdActive(_indexNo));   
    require(rdInfos[_indexNo].shrJackpot > 0); 
    require(msg.value.sub(rdTicketPrice) >= 0);
    
    uint256 _num = msg.value.div(rdTicketPrice);
    uint256 cost = rdTicketPrice.mul(_num);

    if(!checkUserExist(msg.sender))
      addNewUser(msg.sender, _frefCode); 
    if(!checkTicketBuyerInRd(_indexNo, msg.sender))
      addRdTicketBuyer(_indexNo, msg.sender); 

    addRoundTicket(_indexNo, msg.sender, cost, _num);    
    calcServiceFee(cost); 

    if(msg.value.sub(cost) > 0)
       userAccs[msg.sender].purse += msg.value.sub(cost);

    emit event_buyTicket(msg.sender, _indexNo, _num);
  } 

  function addRoundTicket(uint256 _indexNo, address _addr, uint256 _cost, uint256 _num)
  internal 
  { 

    rdInfos[_indexNo].lastTckBuyTime = now;
    rdInfos[_indexNo].lastTckBuyer = _addr; 
    rdInfos[_indexNo].ticketNum += _num;
    rdInfos[_indexNo].ticketPot = rdInfos[_indexNo].ticketPot + _cost;        
    rdInfos[_indexNo].shrTckAvgBonus = rdInfos[_indexNo].shrTckAvgBonus + (_cost * ticketPotRate / 100) / rdInfos[_indexNo].shareNum; 
    rdInfos[_indexNo].tckAvgBonus = rdInfos[_indexNo].tckAvgBonus + (_cost * (100 - ticketPotRate) / 100) / rdInfos[_indexNo].ticketNum;     

    rdTckBuyers[_indexNo][_addr].cost += _cost;
    rdTckBuyers[_indexNo][_addr].ticketNum += _num;
    rdTckBuyers[_indexNo][_addr].tckAvgBonus = (rdInfos[_indexNo].tckAvgBonus * rdTckBuyers[_indexNo][_addr].ticketNum - (rdInfos[_indexNo].tckAvgBonus - (_cost * (100 - ticketPotRate) / 100) / rdInfos[_indexNo].ticketNum - rdTckBuyers[_indexNo][_addr].tckAvgBonus) * (rdTckBuyers[_indexNo][_addr].ticketNum - _num) - (_cost * (100 - ticketPotRate) / 100) * rdTckBuyers[_indexNo][_addr].ticketNum / rdInfos[_indexNo].ticketNum) / rdTckBuyers[_indexNo][_addr].ticketNum;   
  }  
  
  function getUserCount()
  public 
  view 
  returns(uint256 _num) 
  {    

    return userIDCnt;    
  }
  
  function getUserInfo(address _addr)
  public 
  view 
  returns(uint256, uint256, uint256) 
  {   

    require(_addr != address(0));
    require(checkUserExist(_addr));
      
    uint256 prize = 0;  

    for(uint256 i = 0; i < userUnWithdrawRound[_addr].length; i++)
    {
      uint256 indexNo = userUnWithdrawRound[_addr][i];
       
      if(rdInfos[indexNo].state == rdStateEnd)      
        prize += calcRdPlayerPrize(indexNo, _addr); 
    }

    prize = userAccs[_addr].purse + prize * (100 - serviceFee) / 100; 

    return (prize, userAccs[_addr].refCode, userAccs[_addr].frefCode);    
  }

  function userWithdraw()
  isPerson() 
  public 
  {          

    require(msg.sender != address(0));
    require(checkUserExist(msg.sender));
    
    address addr = msg.sender;
    uint256 prize = 0;
    uint256 unEndRd = 0;

    for(uint256 i = 0; i < userUnWithdrawRound[addr].length; i++)
    {
      uint256 indexNo = userUnWithdrawRound[addr][i];
       
      if(rdInfos[indexNo].state == rdStateEnd)      
        prize += calcRdPlayerPrize(indexNo, addr); 
      else
        unEndRd = indexNo;
    }
    
    require(prize > 0); 
    userUnWithdrawRound[addr].length = 0;   
    if(unEndRd > 0)
      userUnWithdrawRound[addr].push(unEndRd);    
    prize = prize * (100 - serviceFee) / 100;

    if(userAccs[addr].frefCode != 0)
    {
      address frefAddr = getAddrOfRefCode(userAccs[addr].frefCode);
      if(frefAddr != address(0))
      {
          uint256 refPrize = (prize * refererFee) / 100;
          userAccs[frefAddr].purse += refPrize;
          prize -= refPrize;
      }    
    }          

    prize += userAccs[addr].purse;
    userAccs[addr].purse = 0;
    addr.transfer(prize);            
  }   
  
  function calcRdPlayerPrize(uint256 _indexNo, address _addr)
  internal 
  view 
  returns(uint256 _prize)
  { 

    uint256 prize = 0;
    
    if(rdShareholders[_indexNo][_addr].shareNum > 0)    
      prize += calcShrPrize(_indexNo, _addr); 
     
    if(rdTckBuyers[_indexNo][_addr].ticketNum > 0)
      prize += calcTckPrize(_indexNo, _addr);

    return prize;
  }

  function calcShrPrize(uint256 _indexNo, address _addr)
  internal 
  view 
  returns(uint256 _prize)
  { 

    uint256 prize = 0;

    prize += (rdInfos[_indexNo].shrAvgBonus - rdShareholders[_indexNo][_addr].shrAvgBonus) * rdShareholders[_indexNo][_addr].shareNum;
    prize += (rdInfos[_indexNo].shrTckAvgBonus - rdShareholders[_indexNo][_addr].shrTckAvgBonus) * rdShareholders[_indexNo][_addr].shareNum;  
    
    if(rdInfos[_indexNo].lastShareBuyer == _addr) 
      prize += (rdInfos[_indexNo].sharePot * shrLastBuyerRate) / 100;  
       
    return prize;
  }

  function calcTckPrize(uint256 _indexNo, address _addr)
  internal 
  view 
  returns(uint256 _prize)
  { 

    uint256 prize = 0;
   
    prize += (rdInfos[_indexNo].tckAvgBonus - rdTckBuyers[_indexNo][_addr].tckAvgBonus) * rdTckBuyers[_indexNo][_addr].ticketNum; 
    
    if(rdInfos[_indexNo].lastTckBuyer == _addr) 
      prize += rdInfos[_indexNo].shrJackpot;  
    
    return prize;
  }  
 
  function getRoundActive()
  public 
  view 
  returns(uint256 _rdIndexNo) 
  {   

     return rdIndexNo; 
  }
      
  function getRdInfo(uint256 _indexNo)  
  public 
  view 
  returns(uint256[] _rdIn, address[] _addrs)
  {    

    require(checkRdExist(_indexNo));
    
    uint256[] memory rdIn = new uint256[](16);    
    address[] memory addrs = new address[](2);    
    
    rdIn[0] = rdSharePrice;    
    rdIn[1] = rdTicketPrice;
    rdIn[2] = rdInfos[_indexNo].state;
    rdIn[3] = rdInfos[_indexNo].sharePot;
    rdIn[4] = rdInfos[_indexNo].shrJackpot;
    rdIn[5] = rdInfos[_indexNo].shareholderNum;
    rdIn[6] = rdInfos[_indexNo].shareNum;     
    rdIn[7] = rdInfos[_indexNo].shrAvgBonus; 
    rdIn[8] = rdInfos[_indexNo].shrTckAvgBonus;    
    rdIn[9] = rdInfos[_indexNo].ticketPot; 
    rdIn[10] = rdInfos[_indexNo].tckBuyerNum;
    rdIn[11] = rdInfos[_indexNo].ticketNum; 
    rdIn[12] = rdInfos[_indexNo].tckAvgBonus;
    rdIn[13] = rdInfos[_indexNo].lastTckBuyTime;
    rdIn[14] = rdInfos[_indexNo].lastShrVoteTime;
    rdIn[15] = rdInfos[_indexNo].shrVotesEnd;   

    addrs[0] =  rdInfos[_indexNo].lastShareBuyer;
    addrs[1] =  rdInfos[_indexNo].lastTckBuyer; 
  
    return (rdIn,  addrs);  
  }
  
 
  function getRdTimeState(uint256 _indexNo)  
  public 
  view 
  returns(uint256 _timeState, uint256 _timeLeft) 
  {  

    require(checkRdActive(_indexNo));
    
    uint256 nowTime = now;
    uint256 timeState = 0;
    uint256 timeLeft = 0;        
    
    uint256 timeStart = getRdLastCntDownStart(_indexNo, nowTime); 
    
    if(timeStart > 0)
    { 
      if(nowTime < (timeStart + rdTicketTime))
      {
        timeState = 1;
        timeLeft = (timeStart + rdTicketTime) - nowTime;
      }      
      else
      {
        timeState = 2;
        timeLeft = (timeStart + rdTicketTime + rdVoteTime) - nowTime; 
      }
      
    }   
  
    return (timeState, timeLeft);  
  }

  function getRdLastCntDownStart(uint256 _indexNo, uint256 _nowTime)  
  internal 
  view 
  returns(uint256 _timeStart) 
  {  

    require(checkRdActive(_indexNo));
   
    uint256 timeStart = 0;   
    
    if(rdInfos[_indexNo].lastTckBuyTime > 0)
    { 
      uint256 timeSpan = _nowTime - rdInfos[_indexNo].lastTckBuyTime;
      uint256 num = timeSpan / (rdTicketTime + rdVoteTime);
      timeStart = rdInfos[_indexNo].lastTckBuyTime + num * (rdTicketTime + rdVoteTime);
    }   
  
    return timeStart;  
  }
 
  function getRdPlayerInfo(uint256 _indexNo, address _addr)
  public 
  view 
  returns(uint256[] _rdPly1, uint256[] _rdPly2) 
  { 

    require(checkShareholderInRd(_indexNo, _addr) || checkTicketBuyerInRd(_indexNo, _addr));
    
    uint256[] memory rdPly1 = new uint256[](6);
    uint256[] memory rdPly2 = new uint256[](3);

    if(checkShareholderInRd(_indexNo, _addr))
    {
      rdPly1[0] = rdShareholders[_indexNo][_addr].cost;    
      rdPly1[1] = rdShareholders[_indexNo][_addr].shareNum; 
      rdPly1[2] = rdShareholders[_indexNo][_addr].shrAvgBonus;
      rdPly1[3] = rdShareholders[_indexNo][_addr].shrTckAvgBonus;  
      rdPly1[4] = calcShrPrize(_indexNo, _addr);  
      rdPly1[5] = 0;  

      if(checkRdInVoteState(_indexNo))         
        rdPly1[5] = getRdshareholderVoteVal(_indexNo, _addr, now);
    }
    
    if(checkTicketBuyerInRd(_indexNo, _addr))
    {
      rdPly2[0] = rdTckBuyers[_indexNo][_addr].cost;
      rdPly2[1] = rdTckBuyers[_indexNo][_addr].ticketNum;
      rdPly2[2] = calcTckPrize(_indexNo, _addr);   
    }

    return (rdPly1, rdPly2);  
  }  
  
  function shareholderVote(uint256 _indexNo, uint256 _vote)
  isPerson()
  public 
  { 

    require(checkRdInVoteState(_indexNo));
    require(checkShareholderInRd(_indexNo, msg.sender));    
    require(_vote == 0 || _vote == 1);
    
    address addr = msg.sender;
    uint256 nowTime = now;
    uint256 timeStart = getRdLastCntDownStart(_indexNo, nowTime); 

    if(rdInfos[_indexNo].lastShrVoteTime < (timeStart + rdTicketTime))
    {   
        rdShareholders[_indexNo][addr].vote = 0;        
        rdInfos[_indexNo].shrVotesEnd = 0;
    } 

    if(rdShareholders[_indexNo][addr].lastShrVoteTime > (timeStart + rdTicketTime))
    {
      if(_vote == 1 && _vote != rdShareholders[_indexNo][addr].vote)
        rdInfos[_indexNo].shrVotesEnd += rdShareholders[_indexNo][addr].shareNum;
      else if(_vote == 0 && _vote != rdShareholders[_indexNo][addr].vote)
        rdInfos[_indexNo].shrVotesEnd -= rdShareholders[_indexNo][addr].shareNum;
    }
    else if(_vote == 1)
        rdInfos[_indexNo].shrVotesEnd += rdShareholders[_indexNo][addr].shareNum;      
    
    rdShareholders[_indexNo][addr].vote = _vote;
    rdShareholders[_indexNo][addr].lastShrVoteTime = nowTime;
    rdInfos[_indexNo].lastShrVoteTime = nowTime;
    emit event_shareholderVote(addr, _indexNo, _vote); 

    if((rdInfos[_indexNo].shrVotesEnd * 2) > rdInfos[_indexNo].shareNum)
       endRound(_indexNo);      
  }   
 
  function getRdVotesCount(uint256 _indexNo)
  public 
  view 
  returns(uint256 _votesEnd, uint256 _voteAll)
  { 

    require(checkRdInVoteState(_indexNo));

    uint256 nowTime = now;
    uint256 shrVotesEnd = 0;    
    uint256 timeStart = getRdLastCntDownStart(_indexNo, nowTime);
    
    if(timeStart > 0 && rdInfos[_indexNo].lastShrVoteTime > (timeStart + rdTicketTime))   
      shrVotesEnd = rdInfos[_indexNo].shrVotesEnd;    
          
    return (shrVotesEnd, rdInfos[_indexNo].shareNum);
  } 

  function endRound(uint256 _indexNo)
  internal 
  {   

    rdInfos[_indexNo].state = rdStateEnd;

    owner().transfer(serviceFeeCnt);   
    serviceFeeCnt = 0; 

    emit event_endRound(_indexNo, rdInfos[_indexNo].lastTckBuyer, rdInfos[_indexNo].shrJackpot);

    startNewRound();   
  }  
  
  function getAddrOfRefCode(uint256 _refCode) 
  internal 
  view 
  returns(address _addr) 
  {  

    if(userIDAddr[_refCode] != address(0))
      return userIDAddr[_refCode];
    return address(0);
  } 

  function checkUserExist(address _addr)
  internal 
  view 
  returns(bool _result) 
  {

    if(userAccs[_addr].refCode != 0)
      return true;
    return false;
  }
  
  function checkRdExist(uint256 _indexNo) 
  internal 
  view 
  returns(bool _result) 
  {

    if(rdInfos[_indexNo].state > 0)
      return true;
    return false;
  }
  
  function checkRdActive(uint256 _indexNo) 
  internal 
  view 
  returns(bool _result) 
  {

    require(checkRdExist(_indexNo));
    
    if(rdInfos[_indexNo].state == rdStateActive)
        return true;
    return false;
  }
 
  function checkRdInVoteState(uint256 _indexNo)
  internal 
  view 
  returns(bool _result) 
  {

    require(checkRdActive(_indexNo));

    uint256 timeState = 0;
  
    (timeState,) = getRdTimeState(_indexNo);
    if(timeState == 2)
        return true;

    return false;
  }
  
  function checkShareholderInRd(uint256 _indexNo, address _addr) 
  public 
  view 
  returns(bool _result) 
  {

    require(checkRdExist(_indexNo));

    if(rdShareholders[_indexNo][_addr].shareNum > 0)
      return true;
    return false;
  }

  function checkTicketBuyerInRd(uint256 _indexNo, address _addr) 
  public 
  view 
  returns(bool _result) 
  {

    require(checkRdExist(_indexNo));

    if(rdTckBuyers[_indexNo][_addr].ticketNum > 0)
      return true;
    return false;
  }
  
  function checkUserInUnWithdrawRd(uint256 _indexNo, address _addr) 
  internal 
  view 
  returns(bool _result) 
  {

    require(checkUserExist(_addr));
    require(checkRdExist(_indexNo));
    
    for(uint256 i = 0; i < userUnWithdrawRound[_addr].length; i++)
    {
      if(userUnWithdrawRound[_addr][i] == _indexNo)
        return true;
    }

    return false;
  }

  function getRdshareholderVoteVal(uint256 _indexNo, address _addr, uint256 _nowTime) 
  internal 
  view 
  returns(uint256 _result) 
  {

    uint256 timeStart = getRdLastCntDownStart(_indexNo, _nowTime);
    if(rdShareholders[_indexNo][_addr].vote == 1 && rdShareholders[_indexNo][_addr].lastShrVoteTime > (timeStart + rdTicketTime))                  
      return 1;

    return 0;
  }

  function calcServiceFee(uint256 _cost) 
  internal
  {    

    serviceFeeCnt += (_cost * serviceFee) / 100;
    if(serviceFeeCnt >= 1 ether)
    { 
      owner().transfer(serviceFeeCnt);   
      serviceFeeCnt = 0; 
    }  
  }  
  

}


library SafeMath {

  function mul(uint256 a, uint256 b) 
  internal 
  pure 
  returns(uint256) 
  {

    if(a == 0) {
      return 0;
    }
    uint256 c = a * b;
    assert(c / a == b);
    return c;
  }

  function div(uint256 a, uint256 b) 
  internal 
  pure 
  returns(uint256) 
  {    

    uint256 c = a / b;    
    return c;
  }

  function sub(uint256 a, uint256 b) 
  internal 
  pure 
  returns(uint256) 
  {

    assert(b <= a);
    return a - b;
  }

  function add(uint256 a, uint256 b) 
  internal 
  pure 
  returns(uint256) 
  {

    uint256 c = a + b;
    assert(c >= a);
    return c;
  }
}