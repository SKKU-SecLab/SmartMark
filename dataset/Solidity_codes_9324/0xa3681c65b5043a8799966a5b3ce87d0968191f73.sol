
pragma solidity ^0.4.24;


contract ERC20Basic {

  function totalSupply() public view returns (uint256);

  function balanceOf(address who) public view returns (uint256);

  function transfer(address to, uint256 value) public returns (bool);

  event Transfer(address indexed from, address indexed to, uint256 value);
}


contract ERC20 is ERC20Basic {

  function allowance(address owner, address spender)
    public view returns (uint256);


  function transferFrom(address from, address to, uint256 value)
    public returns (bool);


  function approve(address spender, uint256 value) public returns (bool);

  event Approval(
    address indexed owner,
    address indexed spender,
    uint256 value
  );
}



library SafeMath {

  int256 constant INT256_MIN = int256((uint256(1) << 255));

  function mul(uint256 a, uint256 b) internal pure returns (uint256 c) {

    if (a == 0) {
      return 0;
    }

    c = a * b;
    assert(c / a == b);
    return c;
  }

  function mul(int256 a, int256 b) internal pure returns (int256 c) {

    if (a == 0) {
      return 0;
    }
    c = a * b;
    assert((a != -1 || b != INT256_MIN) && c / a == b);
  }

  function div(uint256 a, uint256 b) internal pure returns (uint256) {

    return a / b;
  }

  function div(int256 a, int256 b) internal pure returns (int256) {

    assert(a != INT256_MIN || b != -1);
    return a / b;
  }

  function sub(uint256 a, uint256 b) internal pure returns (uint256) {

    assert(b <= a);
    return a - b;
  }

  function sub(int256 a, int256 b) internal pure returns (int256 c) {

    c = a - b;
    assert((b >= 0 && c <= a) || (b < 0 && c > a));
  }

  function add(uint256 a, uint256 b) internal pure returns (uint256 c) {

    c = a + b;
    assert(c >= a);
    return c;
  }

  function add(int256 a, int256 b) internal pure returns (int256 c) {

    c = a + b;
    assert((b >= 0 && c >= a) || (b < 0 && c < a));
  }
}


contract BasicToken is ERC20Basic {

  using SafeMath for uint256;

  mapping(address => uint256) balances;

  uint256 totalSupply_;

  function totalSupply() public view returns (uint256) {

    return totalSupply_;
  }

  function transfer(address _to, uint256 _value) public returns (bool) {

    require(_to != address(0));
    require(_value <= balances[msg.sender]);

    balances[msg.sender] = balances[msg.sender].sub(_value);
    balances[_to] = balances[_to].add(_value);
    emit Transfer(msg.sender, _to, _value);
    return true;
  }

  function balanceOf(address _owner) public view returns (uint256) {

    return balances[_owner];
  }

}


contract StandardToken is ERC20, BasicToken {


  mapping (address => mapping (address => uint256)) internal allowed;


  function transferFrom(
    address _from,
    address _to,
    uint256 _value
  )
    public
    returns (bool)
  {

    require(_to != address(0));
    require(_value <= balances[_from]);
    require(_value <= allowed[_from][msg.sender]);

    balances[_from] = balances[_from].sub(_value);
    balances[_to] = balances[_to].add(_value);
    allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);
    emit Transfer(_from, _to, _value);
    return true;
  }

  function approve(address _spender, uint256 _value) public returns (bool) {

    allowed[msg.sender][_spender] = _value;
    emit Approval(msg.sender, _spender, _value);
    return true;
  }

  function allowance(
    address _owner,
    address _spender
   )
    public
    view
    returns (uint256)
  {

    return allowed[_owner][_spender];
  }

  function increaseApproval(
    address _spender,
    uint256 _addedValue
  )
    public
    returns (bool)
  {

    allowed[msg.sender][_spender] = (
      allowed[msg.sender][_spender].add(_addedValue));
    emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
    return true;
  }

  function decreaseApproval(
    address _spender,
    uint256 _subtractedValue
  )
    public
    returns (bool)
  {

    uint256 oldValue = allowed[msg.sender][_spender];
    if (_subtractedValue > oldValue) {
      allowed[msg.sender][_spender] = 0;
    } else {
      allowed[msg.sender][_spender] = oldValue.sub(_subtractedValue);
    }
    emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
    return true;
  }

}

contract Proxied {

    address public masterCopy;
}

contract Proxy is Proxied {

    constructor(address _masterCopy)
        public
    {
        require(_masterCopy != 0);
        masterCopy = _masterCopy;
    }

    function ()
        external
        payable
    {
        address _masterCopy = masterCopy;
        assembly {
            calldatacopy(0, 0, calldatasize())
            let success := delegatecall(not(0), _masterCopy, 0, calldatasize(), 0, 0)
            returndatacopy(0, 0, returndatasize())
            switch success
            case 0 { revert(0, returndatasize()) }
            default { return(0, returndatasize()) }
        }
    }
}


contract OutcomeTokenProxy is Proxy {


    mapping(address => uint256) balances;
    uint256 totalSupply_;
    mapping (address => mapping (address => uint256)) internal allowed;

    address internal eventContract;

    constructor(address proxied)
        public
        Proxy(proxied)
    {
        eventContract = msg.sender;
    }
}

contract OutcomeToken is Proxied, StandardToken {

    using SafeMath for *;

    event Issuance(address indexed owner, uint amount);
    event Revocation(address indexed owner, uint amount);

    address public eventContract;

    modifier isEventContract () {

        require(msg.sender == eventContract);
        _;
    }

    function issue(address _for, uint outcomeTokenCount)
        public
        isEventContract
    {

        balances[_for] = balances[_for].add(outcomeTokenCount);
        totalSupply_ = totalSupply_.add(outcomeTokenCount);
        emit Issuance(_for, outcomeTokenCount);
    }

    function revoke(address _for, uint outcomeTokenCount)
        public
        isEventContract
    {

        balances[_for] = balances[_for].sub(outcomeTokenCount);
        totalSupply_ = totalSupply_.sub(outcomeTokenCount);
        emit Revocation(_for, outcomeTokenCount);
    }
}

contract Oracle {


    function isOutcomeSet() public view returns (bool);

    function getOutcome() public view returns (int);

}


contract EventData {


    event OutcomeTokenCreation(OutcomeToken outcomeToken, uint8 index);
    event OutcomeTokenSetIssuance(address indexed buyer, uint collateralTokenCount);
    event OutcomeTokenSetRevocation(address indexed seller, uint outcomeTokenCount);
    event OutcomeAssignment(int outcome);
    event WinningsRedemption(address indexed receiver, uint winnings);

    ERC20 public collateralToken;
    Oracle public oracle;
    bool public isOutcomeSet;
    int public outcome;
    OutcomeToken[] public outcomeTokens;
}

contract Event is EventData {


    function buyAllOutcomes(uint collateralTokenCount)
        public
    {

        require(collateralToken.transferFrom(msg.sender, this, collateralTokenCount));
        for (uint8 i = 0; i < outcomeTokens.length; i++)
            outcomeTokens[i].issue(msg.sender, collateralTokenCount);
        emit OutcomeTokenSetIssuance(msg.sender, collateralTokenCount);
    }

    function sellAllOutcomes(uint outcomeTokenCount)
        public
    {

        for (uint8 i = 0; i < outcomeTokens.length; i++)
            outcomeTokens[i].revoke(msg.sender, outcomeTokenCount);
        require(collateralToken.transfer(msg.sender, outcomeTokenCount));
        emit OutcomeTokenSetRevocation(msg.sender, outcomeTokenCount);
    }

    function setOutcome()
        public
    {

        require(!isOutcomeSet && oracle.isOutcomeSet());
        outcome = oracle.getOutcome();
        isOutcomeSet = true;
        emit OutcomeAssignment(outcome);
    }

    function getOutcomeCount()
        public
        view
        returns (uint8)
    {

        return uint8(outcomeTokens.length);
    }

    function getOutcomeTokens()
        public
        view
        returns (OutcomeToken[])
    {

        return outcomeTokens;
    }

    function getOutcomeTokenDistribution(address owner)
        public
        view
        returns (uint[] outcomeTokenDistribution)
    {

        outcomeTokenDistribution = new uint[](outcomeTokens.length);
        for (uint8 i = 0; i < outcomeTokenDistribution.length; i++)
            outcomeTokenDistribution[i] = outcomeTokens[i].balanceOf(owner);
    }

    function getEventHash() public view returns (bytes32);


    function redeemWinnings() public returns (uint);

}


contract MarketMaker {


    function calcCost(Market market, uint8 outcomeTokenIndex, uint outcomeTokenCount) public view returns (uint);

    function calcProfit(Market market, uint8 outcomeTokenIndex, uint outcomeTokenCount) public view returns (uint);

    function calcNetCost(Market market, int[] outcomeTokenAmounts) public view returns (int);

    function calcMarginalPrice(Market market, uint8 outcomeTokenIndex) public view returns (uint);

}


contract MarketData {

    event MarketFunding(uint funding);
    event MarketClosing();
    event FeeWithdrawal(uint fees);
    event OutcomeTokenPurchase(address indexed buyer, uint8 outcomeTokenIndex, uint outcomeTokenCount, uint outcomeTokenCost, uint marketFees);
    event OutcomeTokenSale(address indexed seller, uint8 outcomeTokenIndex, uint outcomeTokenCount, uint outcomeTokenProfit, uint marketFees);
    event OutcomeTokenShortSale(address indexed buyer, uint8 outcomeTokenIndex, uint outcomeTokenCount, uint cost);
    event OutcomeTokenTrade(address indexed transactor, int[] outcomeTokenAmounts, int outcomeTokenNetCost, uint marketFees);

    address public creator;
    uint public createdAtBlock;
    Event public eventContract;
    MarketMaker public marketMaker;
    uint24 public fee;
    uint public funding;
    int[] public netOutcomeTokensSold;
    Stages public stage;

    enum Stages {
        MarketCreated,
        MarketFunded,
        MarketClosed
    }
}

contract Market is MarketData {

    function fund(uint _funding) public;

    function close() public;

    function withdrawFees() public returns (uint);

    function buy(uint8 outcomeTokenIndex, uint outcomeTokenCount, uint maxCost) public returns (uint);

    function sell(uint8 outcomeTokenIndex, uint outcomeTokenCount, uint minProfit) public returns (uint);

    function shortSell(uint8 outcomeTokenIndex, uint outcomeTokenCount, uint minProfit) public returns (uint);

    function trade(int[] outcomeTokenAmounts, int costLimit) public returns (int);

    function calcMarketFee(uint outcomeTokenCost) public view returns (uint);

}


contract StandardMarketData {

    uint24 public constant FEE_RANGE = 1000000; // 100%
}

contract StandardMarketProxy is Proxy, MarketData, StandardMarketData {

    constructor(address proxy, address _creator, Event _eventContract, MarketMaker _marketMaker, uint24 _fee)
        Proxy(proxy)
        public
    {
        require(address(_eventContract) != 0 && address(_marketMaker) != 0 && _fee < FEE_RANGE);
        creator = _creator;
        createdAtBlock = block.number;
        eventContract = _eventContract;
        netOutcomeTokensSold = new int[](eventContract.getOutcomeCount());
        fee = _fee;
        marketMaker = _marketMaker;
        stage = Stages.MarketCreated;
    }
}

contract StandardMarket is Proxied, Market, StandardMarketData {

    using SafeMath for *;

    modifier isCreator() {

        require(msg.sender == creator);
        _;
    }

    modifier atStage(Stages _stage) {

        require(stage == _stage);
        _;
    }

    function fund(uint _funding)
        public
        isCreator
        atStage(Stages.MarketCreated)
    {

        require(   eventContract.collateralToken().transferFrom(msg.sender, this, _funding)
                && eventContract.collateralToken().approve(eventContract, _funding));
        eventContract.buyAllOutcomes(_funding);
        funding = _funding;
        stage = Stages.MarketFunded;
        emit MarketFunding(funding);
    }

    function close()
        public
        isCreator
        atStage(Stages.MarketFunded)
    {

        uint8 outcomeCount = eventContract.getOutcomeCount();
        for (uint8 i = 0; i < outcomeCount; i++)
            require(eventContract.outcomeTokens(i).transfer(creator, eventContract.outcomeTokens(i).balanceOf(this)));
        stage = Stages.MarketClosed;
        emit MarketClosing();
    }

    function withdrawFees()
        public
        isCreator
        returns (uint fees)
    {

        fees = eventContract.collateralToken().balanceOf(this);
        require(eventContract.collateralToken().transfer(creator, fees));
        emit FeeWithdrawal(fees);
    }

    function buy(uint8 outcomeTokenIndex, uint outcomeTokenCount, uint maxCost)
        public
        atStage(Stages.MarketFunded)
        returns (uint cost)
    {

        require(int(outcomeTokenCount) >= 0 && int(maxCost) > 0);
        uint8 outcomeCount = eventContract.getOutcomeCount();
        require(outcomeTokenIndex >= 0 && outcomeTokenIndex < outcomeCount);
        int[] memory outcomeTokenAmounts = new int[](outcomeCount);
        outcomeTokenAmounts[outcomeTokenIndex] = int(outcomeTokenCount);
        (int netCost, int outcomeTokenNetCost, uint fees) = tradeImpl(outcomeCount, outcomeTokenAmounts, int(maxCost));
        require(netCost >= 0 && outcomeTokenNetCost >= 0);
        cost = uint(netCost);
        emit OutcomeTokenPurchase(msg.sender, outcomeTokenIndex, outcomeTokenCount, uint(outcomeTokenNetCost), fees);
    }

    function sell(uint8 outcomeTokenIndex, uint outcomeTokenCount, uint minProfit)
        public
        atStage(Stages.MarketFunded)
        returns (uint profit)
    {

        require(-int(outcomeTokenCount) <= 0 && -int(minProfit) < 0);
        uint8 outcomeCount = eventContract.getOutcomeCount();
        require(outcomeTokenIndex >= 0 && outcomeTokenIndex < outcomeCount);
        int[] memory outcomeTokenAmounts = new int[](outcomeCount);
        outcomeTokenAmounts[outcomeTokenIndex] = -int(outcomeTokenCount);
        (int netCost, int outcomeTokenNetCost, uint fees) = tradeImpl(outcomeCount, outcomeTokenAmounts, -int(minProfit));
        require(netCost <= 0 && outcomeTokenNetCost <= 0);
        profit = uint(-netCost);
        emit OutcomeTokenSale(msg.sender, outcomeTokenIndex, outcomeTokenCount, uint(-outcomeTokenNetCost), fees);
    }

    function shortSell(uint8 outcomeTokenIndex, uint outcomeTokenCount, uint minProfit)
        public
        returns (uint cost)
    {

        require(   eventContract.collateralToken().transferFrom(msg.sender, this, outcomeTokenCount)
                && eventContract.collateralToken().approve(eventContract, outcomeTokenCount));
        eventContract.buyAllOutcomes(outcomeTokenCount);
        eventContract.outcomeTokens(outcomeTokenIndex).approve(this, outcomeTokenCount);
        uint profit = this.sell(outcomeTokenIndex, outcomeTokenCount, minProfit);
        cost = outcomeTokenCount - profit;
        uint8 outcomeCount = eventContract.getOutcomeCount();
        for (uint8 i = 0; i < outcomeCount; i++)
            if (i != outcomeTokenIndex)
                require(eventContract.outcomeTokens(i).transfer(msg.sender, outcomeTokenCount));
        require(eventContract.collateralToken().transfer(msg.sender, profit));
        emit OutcomeTokenShortSale(msg.sender, outcomeTokenIndex, outcomeTokenCount, cost);
    }

    function trade(int[] outcomeTokenAmounts, int collateralLimit)
        public
        atStage(Stages.MarketFunded)
        returns (int netCost)
    {

        uint8 outcomeCount = eventContract.getOutcomeCount();
        require(outcomeTokenAmounts.length == outcomeCount);

        int outcomeTokenNetCost;
        uint fees;
        (netCost, outcomeTokenNetCost, fees) = tradeImpl(outcomeCount, outcomeTokenAmounts, collateralLimit);

        emit OutcomeTokenTrade(msg.sender, outcomeTokenAmounts, outcomeTokenNetCost, fees);
    }

    function tradeImpl(uint8 outcomeCount, int[] outcomeTokenAmounts, int collateralLimit)
        private
        returns (int netCost, int outcomeTokenNetCost, uint fees)
    {

        outcomeTokenNetCost = marketMaker.calcNetCost(this, outcomeTokenAmounts);
        if(outcomeTokenNetCost < 0)
            fees = calcMarketFee(uint(-outcomeTokenNetCost));
        else
            fees = calcMarketFee(uint(outcomeTokenNetCost));

        require(int(fees) >= 0);
        netCost = outcomeTokenNetCost.add(int(fees));

        require(
            (collateralLimit != 0 && netCost <= collateralLimit) ||
            collateralLimit == 0
        );

        if(outcomeTokenNetCost > 0) {
            require(
                eventContract.collateralToken().transferFrom(msg.sender, this, uint(netCost)) &&
                eventContract.collateralToken().approve(eventContract, uint(outcomeTokenNetCost))
            );

            eventContract.buyAllOutcomes(uint(outcomeTokenNetCost));
        }

        for (uint8 i = 0; i < outcomeCount; i++) {
            if(outcomeTokenAmounts[i] != 0) {
                if(outcomeTokenAmounts[i] < 0) {
                    require(eventContract.outcomeTokens(i).transferFrom(msg.sender, this, uint(-outcomeTokenAmounts[i])));
                } else {
                    require(eventContract.outcomeTokens(i).transfer(msg.sender, uint(outcomeTokenAmounts[i])));
                }

                netOutcomeTokensSold[i] = netOutcomeTokensSold[i].add(outcomeTokenAmounts[i]);
            }
        }

        if(outcomeTokenNetCost < 0) {
            eventContract.sellAllOutcomes(uint(-outcomeTokenNetCost));
            if(netCost < 0) {
                require(eventContract.collateralToken().transfer(msg.sender, uint(-netCost)));
            }
        }
    }

    function calcMarketFee(uint outcomeTokenCost)
        public
        view
        returns (uint)
    {

        return outcomeTokenCost * fee / FEE_RANGE;
    }
}