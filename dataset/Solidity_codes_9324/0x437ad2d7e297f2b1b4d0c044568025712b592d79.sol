
pragma solidity ^0.4.23;


contract Ownable {

  address public owner;


  event OwnershipRenounced(address indexed previousOwner);
  event OwnershipTransferred(
    address indexed previousOwner,
    address indexed newOwner
  );


  constructor() public {
    owner = msg.sender;
  }

  modifier onlyOwner() {

    require(msg.sender == owner);
    _;
  }

  function renounceOwnership() public onlyOwner {

    emit OwnershipRenounced(owner);
    owner = address(0);
  }

  function transferOwnership(address _newOwner) public onlyOwner {

    _transferOwnership(_newOwner);
  }

  function _transferOwnership(address _newOwner) internal {

    require(_newOwner != address(0));
    emit OwnershipTransferred(owner, _newOwner);
    owner = _newOwner;
  }
}








library SafeMath {


  function mul(uint256 a, uint256 b) internal pure returns (uint256 c) {

    if (a == 0) {
      return 0;
    }

    c = a * b;
    assert(c / a == b);
    return c;
  }

  function div(uint256 a, uint256 b) internal pure returns (uint256) {

    return a / b;
  }

  function sub(uint256 a, uint256 b) internal pure returns (uint256) {

    assert(b <= a);
    return a - b;
  }

  function add(uint256 a, uint256 b) internal pure returns (uint256 c) {

    c = a + b;
    assert(c >= a);
    return c;
  }
}



contract ExchangeOracle is Ownable {


    using SafeMath for uint256;

    uint256 public rate;
    uint256 public lastRate;
    uint256 public rateMultiplier = 1000;
    uint256 public usdMultiplier = 100;
    address public admin;

    event RateChanged(uint256 _oldRate, uint256 _newRate);
    event RateMultiplierChanged(uint256 _oldRateMultiplier, uint256 _newRateMultiplier);
    event USDMultiplierChanged(uint256 _oldUSDMultiplier, uint256 _newUSDMultiplier);
    event AdminChanged(address _oldAdmin, address _newAdmin);

    constructor(address _initialAdmin, uint256 _initialRate) public {
        require(_initialAdmin != address(0), "Invalid initial admin address");
        require(_initialRate > 0, "Invalid initial rate value");

        admin = _initialAdmin;
        rate = _initialRate;
        lastRate = _initialRate;
    }

    modifier onlyAdmin() {

        require(msg.sender == admin, "Not allowed to execute");
        _;
    }

    function setRate(uint256 _newRate) public onlyAdmin {

        require(_newRate > 0, "Invalid rate value");

        lastRate = rate;
        rate = _newRate;

        emit RateChanged(lastRate, _newRate);
    }

    function setRateMultiplier(uint256 _newRateMultiplier) public onlyAdmin {

        require(_newRateMultiplier > 0, "Invalid rate multiplier value");

        uint256 oldRateMultiplier = rateMultiplier;
        rateMultiplier = _newRateMultiplier;

        emit RateMultiplierChanged(oldRateMultiplier, _newRateMultiplier);
    }

    function setUSDMultiplier(uint256 _newUSDMultiplier) public onlyAdmin {

        require(_newUSDMultiplier > 0, "Invalid USD multiplier value");

        uint256 oldUSDMultiplier = usdMultiplier;
        usdMultiplier = _newUSDMultiplier;

        emit USDMultiplierChanged(oldUSDMultiplier, _newUSDMultiplier);
    }

    function setAdmin(address _newAdmin) public onlyOwner {

        require(_newAdmin != address(0), "Invalid admin address");

        address oldAdmin = admin;
        admin = _newAdmin;

        emit AdminChanged(oldAdmin, _newAdmin);
    }

}


contract TokenExchangeOracle is ExchangeOracle {


    constructor(address _admin, uint256 _initialRate) ExchangeOracle(_admin, _initialRate) public {}

    function convertUSDToTokens(uint256 _usdAmount) public view returns (uint256) {

        return usdToTokens(_usdAmount, rate);
    }

    function convertUSDToTokensByLastRate(uint256 _usdAmount) public view returns (uint256) {

        return usdToTokens(_usdAmount, lastRate);
    }

    function usdToTokens(uint256 _usdAmount, uint256 _rate) internal view returns (uint256) {

        require(_usdAmount > 0, "Invalid USD amount");

        uint256 tokens = _usdAmount.mul(rateMultiplier);
        tokens = tokens.mul(1 ether);
        tokens = tokens.div(usdMultiplier);
        tokens = tokens.div(_rate);

        return tokens;
    }

    function convertTokensToUSD(uint256 _tokens) public view returns (uint256) {

        return tokensToUSD(_tokens, rate);
    }

    function convertTokensToUSDByLastRate(uint256 _tokens) public view returns (uint256) {

        return tokensToUSD(_tokens, lastRate);
    }

    function tokensToUSD(uint256 _tokens, uint256 _rate) internal view returns (uint256) {

        require(_tokens > 0, "Invalid token amount");

        uint256 usdAmount = _tokens.mul(_rate);
        usdAmount = usdAmount.mul(usdMultiplier);
        usdAmount = usdAmount.div(rateMultiplier);
        usdAmount = usdAmount.div(1 ether);

        return usdAmount;
    }

}