
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


contract ScalarEventData {


    uint8 public constant SHORT = 0;
    uint8 public constant LONG = 1;
    uint24 public constant OUTCOME_RANGE = 1000000;

    int public lowerBound;
    int public upperBound;
}

contract ScalarEventProxy is Proxy, EventData, ScalarEventData {


    constructor(
        address proxied,
        address outcomeTokenMasterCopy,
        ERC20 _collateralToken,
        Oracle _oracle,
        int _lowerBound,
        int _upperBound
    )
        Proxy(proxied)
        public
    {
        require(address(_collateralToken) != 0 && address(_oracle) != 0);
        collateralToken = _collateralToken;
        oracle = _oracle;
        for (uint8 i = 0; i < 2; i++) {
            OutcomeToken outcomeToken = OutcomeToken(new OutcomeTokenProxy(outcomeTokenMasterCopy));
            outcomeTokens.push(outcomeToken);
            emit OutcomeTokenCreation(outcomeToken, i);
        }

        require(_upperBound > _lowerBound);
        lowerBound = _lowerBound;
        upperBound = _upperBound;
    }
}

contract ScalarEvent is Proxied, Event, ScalarEventData {

    using SafeMath for *;

    function redeemWinnings()
        public
        returns (uint winnings)
    {

        require(isOutcomeSet);
        uint24 convertedWinningOutcome;
        if (outcome < lowerBound)
            convertedWinningOutcome = 0;
        else if (outcome > upperBound)
            convertedWinningOutcome = OUTCOME_RANGE;
        else
            convertedWinningOutcome = uint24(OUTCOME_RANGE * (outcome - lowerBound) / (upperBound - lowerBound));
        uint factorShort = OUTCOME_RANGE - convertedWinningOutcome;
        uint factorLong = OUTCOME_RANGE - factorShort;
        uint shortOutcomeTokenCount = outcomeTokens[SHORT].balanceOf(msg.sender);
        uint longOutcomeTokenCount = outcomeTokens[LONG].balanceOf(msg.sender);
        winnings = shortOutcomeTokenCount.mul(factorShort).add(longOutcomeTokenCount.mul(factorLong)) / OUTCOME_RANGE;
        outcomeTokens[SHORT].revoke(msg.sender, shortOutcomeTokenCount);
        outcomeTokens[LONG].revoke(msg.sender, longOutcomeTokenCount);
        require(collateralToken.transfer(msg.sender, winnings));
        emit WinningsRedemption(msg.sender, winnings);
    }

    function getEventHash()
        public
        view
        returns (bytes32)
    {

        return keccak256(abi.encodePacked(collateralToken, oracle, lowerBound, upperBound));
    }
}