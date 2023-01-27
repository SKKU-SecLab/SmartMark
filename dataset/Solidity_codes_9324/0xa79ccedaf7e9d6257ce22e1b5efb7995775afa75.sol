
pragma solidity =0.6.9;


contract ReentrancyGuard {

    uint256 private _guardCounter;

    constructor () internal {
        _guardCounter = 1;
    }

    modifier nonReentrant() {

        _guardCounter += 1;
        uint256 localCounter = _guardCounter;
        _;
        require(localCounter == _guardCounter, "ReentrancyGuard: reentrant call");
    }
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

}

interface IINSS {

  function mint(address user, uint amount) external;

  function totalSupply() external view returns (uint256);

}

contract INSSMiner is ReentrancyGuard {


  using SafeMath for uint256;

  uint constant DAY = 24 * 60 * 60;
  uint constant ONE = 10 ** 18;
  uint constant PERDIFF = 100000; 
  uint constant PERCENT_250 = 250;
  uint constant PERCENT_100 = 100;
  uint constant LUCKY_1000_AMOUNT = 1000 ether;
  uint constant LUCKY_100_AMOUNT  = 100 ether;

  address private immutable feeTo;

  address private immutable referFrom;

  IINSS private inss;


  uint96 private topPool;    
  uint80 private luckyPool;   // Up to 1.2 million eth
  uint80 private feePool;    

  struct Order {
    uint104 value;
    uint112 withdrawed;
    uint8 level;
    uint32 ts;
  }

  struct Earn {
    uint32  earnTs;
    uint112 luckyBonus;
    uint112 superBonus;
    

    uint96 referBonus;
    uint80 matchBonus;
    uint80 topBonus;
  }

  struct Lucky {
    uint112 inValue;
    uint112 luckyValue;
    uint32 ts;
    address user;
  }
  
  mapping(address => Order) orders;
  mapping(address => Earn) earns;

  mapping(address => address) refers;
  mapping(address => uint) cycles;    

  Lucky lucky;

  uint totalDeposit;   // 

  mapping(address => uint) refereeNums;
  mapping(address => uint) partners;
  mapping(address => uint) referValues;

  mapping(uint => mapping(address => uint)) public dayReferValues;
  mapping(uint => address[]) private topAddrs;

  event NewStaking(address indexed user, address indexed partner, uint256 amount);

  constructor (address feeto, address referfrom) public {
    feeTo = feeto;
    referFrom = referfrom;
  }

  function initINSS(address token) external {

    require(msg.sender == token && address(inss) == address(0), "inss error");
    inss = IINSS(token);
  }

  function getLucky() external view returns (uint112, uint112, uint32, address) {

    return (lucky.inValue, lucky.luckyValue, lucky.ts, lucky.user);
  }

  function getPools() external view returns (uint , uint96, uint80, uint80) {

    return (totalDeposit, topPool, luckyPool, feePool);
  }

  function referInfo() external view returns (uint, uint, uint) {

    return (refereeNums[msg.sender], referValues[msg.sender], partners[msg.sender] );
  }

  function myOrder() external view returns (uint104, uint112, uint8, uint, 
    uint32, uint112, uint112, 
    uint96, uint80, uint80, uint, uint) {

    Order memory order = orders[msg.sender];
    Earn memory earn = earns[msg.sender];

    (uint wdableEarn, uint edays,) = myEarns(msg.sender);

    return (order.value, order.withdrawed, order.level, cycles[msg.sender], 
      earn.earnTs, earn.luckyBonus, earn.superBonus, 
      earn.referBonus, earn.matchBonus, earn.topBonus, wdableEarn, edays);
  }

  function dayTopAddrs(uint day) external view returns (address[] memory) {

    return topAddrs[day];
  }

  function join(address p, uint8 level) external payable nonReentrant {

    address user = msg.sender;
    uint value = msg.value;

    require(user != referFrom, "E/refer error");
    (uint earned, ,) = myEarns(user);
    require(earned == 0, "E/need wd");
    require(orders[user].withdrawed >= (PERCENT_250 * orders[user].value / PERCENT_100) || !liveUser(user) , "E/aleady");
    require(checkValue(user, value), "E/invalid value");
    emit NewStaking(user, p, value);

    mintInss(user, value * (10 + level) / 10);

    totalDeposit += value;
    topPool   += uint96(value / 20);
    luckyPool += uint80(value * 3 / 100);
    feePool   += uint80(value * 5 / 100);

    orders[user] = Order(uint104(value), uint112(0), level, uint32(block.timestamp));
    earns[user] = Earn(uint32(block.timestamp), uint112(0), uint112(0),  uint96(0), uint80(0), uint80(0));

    address refer = refers[user];
    if(refer == address(0)) {
      refer = p;
      if(!liveUser(p)) {
        refer = referFrom;
      } else {
        refereeNums[refer] += 1;
        
        address partnerRefer = refers[refer];
        for(uint layer=2; layer<=10 && partnerRefer != referFrom; layer++) {
          partners[partnerRefer] += 1;  
          partnerRefer = refers[partnerRefer];
        }

      }
      refers[user] = refer;  
    }
    
    awardRefer(refer, 1, value);

    lucky1000(user, value);
  }

  function inssPrice() public view returns  (uint) {

    return ONE - (inss.totalSupply() / ONE * ONE / PERDIFF);
  }

  function mintInss(address user, uint value) internal {

    uint amount = inssAmount(value);
    inss.mint(user, amount);
    inss.mint(feeTo, amount / 20);
  } 

  function inssAmount(uint ethAmount) public view returns  (uint) {

    uint price = inssPrice();
    if(price == 0) {
      return 0;
    }

    uint leftEth = ethAmount; 
    uint inssTotal = 0;

    uint leftInss = ONE - (inss.totalSupply() % ONE);
    uint spendEth;

    while(leftEth > 0) {
      spendEth = leftInss * ONE / price;

      if (leftEth >= spendEth) {
        inssTotal += leftInss;
        leftEth -= spendEth;
        price -= PERDIFF;
        leftInss = ONE;
      } else {
        inssTotal += leftEth.mul(price).div(ONE);
        return inssTotal;
      }
    }
    return inssTotal;
  }


  function openDayTop() external {

    return openTopAward(block.timestamp - DAY);
  }

  function openTopAward(uint timestamp) public nonReentrant {

    require(timestamp < block.timestamp, "ts not valid");
    uint day = getDay(timestamp);
    uint nowDay = getDay(block.timestamp);
    require(nowDay > day, "day not end");
    require(topAddrs[day].length > 0, "aleady opened");

    uint length = topAddrs[day].length;
    uint topAward = topPool/10;
    uint awarded;
    address topUser;
    uint percent;

    for (uint i=0;i < length && i<8; i++) {
      topUser = topAddrs[day][i];
      if(i==0) {
        percent = 40;
      } else if (i == 1) {
        percent = 20;
      } else if (i == 2) {
        percent = 12;
      } else if (i == 3) {
        percent = 8;
      } else if (i >= 4) {
        percent = 5;
      }

      earns[topUser].topBonus += uint80(topAward * percent / PERCENT_100);
      awarded += topAward * percent / PERCENT_100;
    }

    topPool -= uint96(awarded);

    delete topAddrs[day];
  }

  function awardRefer(address refer, uint layer, uint value) internal {

    if(layer == 1) {
      earns[refer].referBonus +=  uint96(value * 7 / PERCENT_100);

      if (referFrom == refer) {
        return;
      }

      referValues[refer] += value;
      superRefer100(refer, value);
      
      uint day = getDay(block.timestamp);
      dayReferValues[day][refer] += value;
      fitTopPos(day, refer);

      if(refers[refer] == referFrom || !liveUser(refers[refer]) || refereeNums[refers[refer]] < 3) {
        awardRefer(referFrom, 2, value);
      } else {
        awardRefer(refers[refer], 2, value);
      }
    } else if (layer == 2) {
      earns[refer].referBonus += uint96(value * 3 / PERCENT_100);
    }
  }

  function liveUser(address user) internal view returns (bool) {

    Order memory order = orders[user];
    if(order.value > 0) {
      Earn memory earn = earns[user];
      uint earnedValue = userEarn(user);

      uint valueTop =  order.value * PERCENT_250 / PERCENT_100;
      if(order.withdrawed + earnedValue < valueTop) {
        uint passDays = (block.timestamp - earn.earnTs) / DAY; 

        if (order.level > 0) {
          passDays = (passDays / (order.level + 1)) * (order.level + 1);
        }

        uint interest = order.value * passDays * (10 + order.level) / 1000;
        
        if(order.withdrawed + earnedValue + interest < valueTop) {
          return true;
        }
      }
    }
  }

  function userEarn(address user) internal view returns (uint) {

    Earn memory earn = earns[user];
    return earn.referBonus + earn.matchBonus + earn.topBonus + earn.luckyBonus;
  } 

  function checkValue(address user, uint value) internal view returns (bool) {

    uint lastValue = orders[user].value;
    if(cycles[user] == 0) {
      if(value >= 0.1 ether && value <= 20 ether) {
        return true;
      }
    } else if (cycles[user] >= 5) {
      if(value >= lastValue) {
        return true;
      }
    } else {
      if(value >= lastValue && value <= (10 * (2 ** (cycles[user] + 1 ))) * 1 ether) {
        return true;
      }
    }
    return false;
  }


  function getDay(uint ts) internal pure returns (uint) {   

    return (ts - 21600) / DAY;   //  6 * 60 * 60    86400
  }

  function lucky1000(address user, uint value) internal {


    uint times = 1 + ((address(this).balance - value) / LUCKY_1000_AMOUNT);
    uint luckyV = times * LUCKY_1000_AMOUNT;

    if(address(this).balance >= luckyV && (address(this).balance - value) < luckyV ) {
      uint112 lv = uint112(luckyPool/2);
      earns[user].luckyBonus += lv;
      luckyPool = luckyPool / 2;
      lucky = Lucky(uint112(value), lv, uint32(block.timestamp), user);
    }
  }

  function superRefer100(address refer, uint value) internal {

    uint times = 1 + ((referValues[refer] - value) / LUCKY_100_AMOUNT);
    uint luckyV = times * LUCKY_100_AMOUNT;
    if(referValues[refer] >= luckyV && (referValues[refer] - value) < luckyV ) {
      earns[refer].superBonus += 3 ether;
    }
  }
  
  function wdFee() external {

    uint fee = feePool;
    feePool = 0;
    payable(feeTo).transfer(fee);
  }

  function wdEarn() external nonReentrant {

    address payable user = msg.sender;

    (uint earn, uint earnDays, bool over) = myEarns(user);
    uint superBonus = earns[user].superBonus;
    if(earn + superBonus == 0) {
      return;
    }

    orders[user].withdrawed += uint112(earn);

    uint32 earnTs = earns[user].earnTs + uint32(earnDays * DAY);

    earns[user] = Earn(earnTs, uint112(0), uint112(0),  uint96(0), uint80(0), uint80(0));
    
    if(over) {
      cycles[user] += 1;
    } 

    user.transfer(earn + superBonus);

    address refer = user;
    for(uint layer=1; layer<=10 && refer != referFrom; layer++) {
      refer = refers[refer];
      matchAward(refer, layer, earn);
    }
  }

  function matchAward(address refer, uint layer, uint value) internal {

    if(layer == 1) {
      earns[refer].matchBonus += uint80(value * 20 / PERCENT_100);
    } else if(refereeNums[refer] >= layer) {
      if(layer == 2) {
        earns[refer].matchBonus += uint80(value * 10 / PERCENT_100);
      } else if(layer == 3 || layer == 4 || layer == 5 ) {
        earns[refer].matchBonus += uint80(value * 7 / PERCENT_100);
      } else if (layer >= 6) {
        earns[refer].matchBonus += uint80(value * 3 / PERCENT_100);
      }
    }
  }


  function myEarns(address user) internal view returns(uint, uint , bool) {

    if(user == referFrom) {
      return (earns[user].referBonus + earns[user].matchBonus, 0 , false);
    }

    Order memory order = orders[user];
    Earn memory earned = earns[user];
    uint earnedValue = userEarn(user);

    uint valueTop = order.value * PERCENT_250 / PERCENT_100;
    if(order.value > 0 && order.withdrawed < valueTop) {
      uint passDays = (block.timestamp - earned.earnTs) / DAY; 

      if (order.level > 0) {
        passDays = (passDays / (order.level + 1)) * (order.level + 1);
      }

      uint yield = order.value * passDays * (10 + order.level) / 1000;
      
      if(order.withdrawed + earnedValue + yield < valueTop) {
        return (earnedValue + yield, passDays, false);
      } else {
        return (valueTop - order.withdrawed, passDays, true);
      }
    }
  }

    function fitTopPos(uint day, address refer) internal {

        uint length = topAddrs[day].length ;
        for (uint i = 0 ; i < length ; i++) {
            if (refer == topAddrs[day][i]) {  // aleady in top8.
                swapLast(day, i, refer);
                return ;
            }
        }

        if (length < 8) {
            topAddrs[day].push(refer);
            swapLast(day, length, refer);
        } else {  // compare the last one.
            if(dayReferValues[day][refer] > dayReferValues[day][topAddrs[day][7]]) {
              topAddrs[day][7] = refer;
              swapLast(day, 7, refer);
            }
        }
    }

    function swapLast(uint  day, uint pos, address refer) internal {

        while (pos >= 1 && dayReferValues[day][refer] > dayReferValues[day][topAddrs[day][pos-1]]  ) {   // big then pre , then swap
            topAddrs[day][pos] = topAddrs[day][pos-1];   // pre move to back
            topAddrs[day][pos-1] = refer;   //  move the curr to pre
            pos -= 1;
        }
    }

}