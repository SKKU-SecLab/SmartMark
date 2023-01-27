
pragma solidity 0.4.24;


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


contract PoaProxyCommon {


  address public poaTokenMaster;

  address public poaCrowdsaleMaster;

  address public registry;




  function getContractAddress(string _name)
    public
    view
    returns (address _contractAddress)
  {

    bytes4 _signature = bytes4(keccak256("getContractAddress32(bytes32)"));
    bytes32 _name32 = keccak256(abi.encodePacked(_name));

    assembly {
      let _registry := sload(registry_slot) // load registry address from storage
      let _pointer := mload(0x40)          // Set _pointer to free memory pointer
      mstore(_pointer, _signature)         // Store _signature at _pointer
      mstore(add(_pointer, 0x04), _name32) // Store _name32 at _pointer offset by 4 bytes for pre-existing _signature

      let result := staticcall(
        gas,       // g = gas: whatever was passed already
        _registry, // a = address: address in storage
        _pointer,  // in = mem in  mem[in..(in+insize): set to free memory pointer
        0x24,      // insize = mem insize  mem[in..(in+insize): size of signature (bytes4) + bytes32 = 0x24
        _pointer,  // out = mem out  mem[out..(out+outsize): output assigned to this storage address
        0x20       // outsize = mem outsize  mem[out..(out+outsize): output should be 32byte slot (address size = 0x14 <  slot size 0x20)
      )

      if iszero(result) {
        revert(0, 0)
      }

      _contractAddress := mload(_pointer) // Assign result to return value
      mstore(0x40, add(_pointer, 0x24))   // Advance free memory pointer by largest _pointer size
    }
  }

}


library SafeMathPower {

  uint internal constant RAY = 10 ** 27;

  function add(uint x, uint y) private pure returns (uint z) {

    require((z = x + y) >= x);
  }

  function mul(uint x, uint y) private pure returns (uint z) {

    require(y == 0 || (z = x * y) / y == x);
  }

  function rmul(uint x, uint y) private pure returns (uint z) {

    z = add(mul(x, y), RAY / 2) / RAY;
  }

  function rpow(uint x, uint n) internal pure returns (uint z) {

    z = n % 2 != 0 ? x : RAY;

    for (n /= 2; n != 0; n /= 2) {
      x = rmul(x, x);

      if (n % 2 != 0) {
        z = rmul(z, x);
      }
    }
  }
}


interface IWhitelist {

  function whitelisted(address _address)
    external
    returns (bool);

}


contract PoaCommon is PoaProxyCommon {

  using SafeMath for uint256;
  using SafeMathPower for uint256;

  uint256 public constant feeRateInPermille = 5; // read: 0.5%

  enum Stages {
    Preview,           // 0
    PreFunding,        // 1
    FiatFunding,       // 2
    EthFunding,        // 3
    FundingSuccessful, // 4
    FundingCancelled,  // 5
    TimedOut,          // 6
    Active,            // 7
    Terminated         // 8
  }


  Stages public stage;

  address public issuer;

  address public custodian;

  bytes32[2] internal proofOfCustody32_;

  uint256 internal totalSupply_;

  uint256 public fundedFiatAmountInTokens;

  mapping(address => uint256) public fundedFiatAmountPerUserInTokens;

  uint256 public fundedEthAmountInWei;

  mapping(address => uint256) public fundedEthAmountPerUserInWei;

  mapping(address => uint256) public unclaimedPayoutTotals;

  bool public paused;

  bool public tokenInitialized;

  bool public isActivationFeePaid;




  bool public crowdsaleInitialized;

  uint256 public startTimeForFundingPeriod;

  uint256 public durationForFiatFundingPeriod;

  uint256 public durationForEthFundingPeriod;

  uint256 public durationForActivationPeriod;

  bytes32 public fiatCurrency32;

  uint256 public fundingGoalInCents;

  uint256 public fundedFiatAmountInCents;

  address public whitelist;



  modifier onlyCustodian() {

    require(msg.sender == custodian);
    _;
  }

  modifier onlyIssuer() {

    require(msg.sender == issuer);
    _;
  }

  modifier atStage(Stages _stage) {

    require(stage == _stage);
    _;
  }

  modifier atEitherStage(Stages _stage, Stages _orStage) {

    require(stage == _stage || stage == _orStage);
    _;
  }

  modifier atMaxStage(Stages _stage) {

    require(stage <= _stage);
    _;
  }

  modifier validIpfsHash(bytes32[2] _ipfsHash) {

    bytes memory _ipfsHashBytes = bytes(to64LengthString(_ipfsHash));
    require(_ipfsHashBytes.length == 46);
    require(_ipfsHashBytes[0] == 0x51);
    require(_ipfsHashBytes[1] == 0x6D);
    require(keccak256(abi.encodePacked(_ipfsHashBytes)) != keccak256(abi.encodePacked(proofOfCustody())));
    _;
  }




  function proofOfCustody()
    public
    view
    returns (string)
  {

    return to64LengthString(proofOfCustody32_);
  }




  function enterStage(
    Stages _stage
  )
    internal
  {

    stage = _stage;
    getContractAddress("PoaLogger").call(
      abi.encodeWithSignature("logStage(uint256)", uint256(_stage))
    );
  }




  function calculateFee(
    uint256 _value
  )
    public
    pure
    returns (uint256)
  {

    return feeRateInPermille.mul(_value).div(1000);
  }

  function payFee(
    uint256 _value
  )
    internal
    returns (bool)
  {

    require(
      getContractAddress("FeeManager")
        .call.value(_value)(abi.encodeWithSignature("payFee()"))
    );
  }

  function isEthInvestor(
    address _buyer
  )
    internal
    view
    returns (bool)
  {

    return fundedEthAmountPerUserInWei[_buyer] > 0;
  }

  function isFiatInvestor(
    address _buyer
  )
    internal
    view
    returns (bool)
  {

    return fundedFiatAmountPerUserInTokens[_buyer] > 0;
  }

  function isWhitelisted(
    address _address
  )
    public
    view
    returns (bool)
  {

    return IWhitelist(whitelist).whitelisted(_address);
  }

  function to32LengthString(
    bytes32 _data
  )
    internal
    pure
    returns (string)
  {

    bytes memory _bytesString = new bytes(32);

    assembly {
      mstore(add(_bytesString, 0x20), _data)
    }

    for (uint256 _bytesCounter = 0; _bytesCounter < 32; _bytesCounter++) {
      if (_bytesString[_bytesCounter] == 0x00) {
        break;
      }
    }

    assembly {
      mstore(_bytesString, _bytesCounter)
    }

    return string(_bytesString);
  }

  function to64LengthString(
    bytes32[2] _data
  )
    internal
    pure
    returns (string)
  {

    bytes memory _bytesString = new bytes(64);

    assembly {
      mstore(add(_bytesString, 0x20), mload(_data))
      mstore(add(_bytesString, 0x40), mload(add(_data, 0x20)))
    }

    for (uint256 _bytesCounter = 0; _bytesCounter < 64; _bytesCounter++) {
      if (_bytesString[_bytesCounter] == 0x00) {
        break;
      }
    }

    assembly {
      mstore(_bytesString, _bytesCounter)
    }

    return string (_bytesString);
  }

}



contract PoaCrowdsale is PoaCommon {


  uint256 public constant crowdsaleVersion = 1;

  uint256 public constant precisionOfPercentCalc = 18;

  event Unpause();


  modifier checkTimeout() {

    uint256 fundingDeadline = startTimeForFundingPeriod
      .add(durationForFiatFundingPeriod)
      .add(durationForEthFundingPeriod);
    uint256 activationDeadline = fundingDeadline.add(durationForActivationPeriod);

    if (
      (stage <= Stages.EthFunding && block.timestamp >= fundingDeadline) ||
      (stage == Stages.FundingSuccessful && block.timestamp >= activationDeadline)
    ) {
      enterStage(Stages.TimedOut);
    }

    _;
  }

  modifier isAddressWhitelisted(address _address) {

    require(isWhitelisted(_address));
    _;
  }


  function initializeCrowdsale(
    bytes32 _fiatCurrency32,
    uint256 _startTimeForFundingPeriod,
    uint256 _durationForFiatFundingPeriod,
    uint256 _durationForEthFundingPeriod,
    uint256 _durationForActivationPeriod,
    uint256 _fundingGoalInCents
  )
    external
    returns (bool)
  {

    require(tokenInitialized);
    require(!crowdsaleInitialized);

    setFiatCurrency(_fiatCurrency32);
    setStartTimeForFundingPeriod(_startTimeForFundingPeriod);
    setDurationForActivationPeriod(_durationForActivationPeriod);
    setFundingGoalInCents(_fundingGoalInCents);

    require(_durationForFiatFundingPeriod + _durationForEthFundingPeriod > 0);
    if (_durationForFiatFundingPeriod > 0) {
      setDurationForFiatFundingPeriod(_durationForFiatFundingPeriod);
    }
    if (_durationForEthFundingPeriod > 0) {
      setDurationForEthFundingPeriod(_durationForEthFundingPeriod);
    }

    crowdsaleInitialized = true;

    return true;
  }


  function updateFiatCurrency(bytes32 _newFiatCurrency32)
    external
    onlyIssuer
    atStage(Stages.Preview)
  {

    setFiatCurrency(_newFiatCurrency32);
  }

  function updateFundingGoalInCents(uint256 _newFundingGoalInCents)
    external
    onlyIssuer
    atStage(Stages.Preview)
  {

    setFundingGoalInCents(_newFundingGoalInCents);
  }

  function updateStartTimeForFundingPeriod(uint256 _newStartTimeForFundingPeriod)
    external
    onlyIssuer
    atStage(Stages.Preview)
  {

    setStartTimeForFundingPeriod(_newStartTimeForFundingPeriod);
  }

  function updateDurationForFiatFundingPeriod(uint256 _newDurationForFiatFundingPeriod)
    external
    onlyIssuer
    atStage(Stages.Preview)
  {

    setDurationForFiatFundingPeriod(_newDurationForFiatFundingPeriod);
  }

  function updateDurationForEthFundingPeriod(uint256 _newDurationForEthFundingPeriod)
    external
    onlyIssuer
    atStage(Stages.Preview)
  {

    setDurationForEthFundingPeriod(_newDurationForEthFundingPeriod);
  }

  function updateDurationForActivationPeriod(uint256 _newDurationForActivationPeriod)
    external
    onlyIssuer
    atStage(Stages.Preview)
  {

    setDurationForActivationPeriod(_newDurationForActivationPeriod);
  }



  function setFiatCurrency(bytes32 _newFiatCurrency32)
    internal
  {

    require(_newFiatCurrency32 != bytes32(0));
    require(_newFiatCurrency32 != fiatCurrency32);

    fiatCurrency32 = _newFiatCurrency32;

    require(getFiatRate() > 0);
  }

  function setFundingGoalInCents(uint256 _newFundingGoalInCents)
    internal
  {

    require(_newFundingGoalInCents < totalSupply_);
    require(_newFundingGoalInCents != fundingGoalInCents);
    require(_newFundingGoalInCents > 0);

    fundingGoalInCents = _newFundingGoalInCents;
  }

  function setStartTimeForFundingPeriod(uint256 _newStartTimeForFundingPeriod)
    internal
  {

    require(_newStartTimeForFundingPeriod > block.timestamp);
    require(_newStartTimeForFundingPeriod != startTimeForFundingPeriod);

    startTimeForFundingPeriod = _newStartTimeForFundingPeriod;
  }

  function setDurationForFiatFundingPeriod(uint256 _newDurationForFiatFundingPeriod)
    internal
  {

    require(
      _newDurationForFiatFundingPeriod >= (3 days) ||
      (
        _newDurationForFiatFundingPeriod == 0 &&
        durationForEthFundingPeriod != 0
      )
    );
    require(_newDurationForFiatFundingPeriod != durationForFiatFundingPeriod);

    durationForFiatFundingPeriod = _newDurationForFiatFundingPeriod;
  }

  function setDurationForEthFundingPeriod(uint256 _newDurationForEthFundingPeriod)
    internal
  {

    require(
      _newDurationForEthFundingPeriod >= (1 days) ||
      (
        _newDurationForEthFundingPeriod == 0 &&
        durationForFiatFundingPeriod != 0
      )
    );
    require(_newDurationForEthFundingPeriod != durationForEthFundingPeriod);

    durationForEthFundingPeriod = _newDurationForEthFundingPeriod;
  }

  function setDurationForActivationPeriod(uint256 _newDurationForActivationPeriod)
    internal
  {

    require(_newDurationForActivationPeriod >= (1 weeks));
    require(_newDurationForActivationPeriod != durationForActivationPeriod);

    durationForActivationPeriod = _newDurationForActivationPeriod;
  }



  function startFiatSale()
    external
    atStage(Stages.PreFunding)
    returns (bool)
  {

    uint256 _startTimeForFundingPeriod = startTimeForFundingPeriod;
    uint256 _durationForFiatFundingPeriod = durationForFiatFundingPeriod;

    require(_durationForFiatFundingPeriod > 0);

    require(_startTimeForFundingPeriod <= block.timestamp);

    require(block.timestamp < _startTimeForFundingPeriod + _durationForFiatFundingPeriod);

    enterStage(Stages.FiatFunding);

    return true;
  }

  function startEthSale()
    external
    atEitherStage(Stages.PreFunding, Stages.FiatFunding)
    returns (bool)
  {

    uint256 _startTimeForEthFundingPeriod = startTimeForFundingPeriod + durationForFiatFundingPeriod;
    uint256 _durationForEthFundingPeriod = durationForEthFundingPeriod;

    require(_durationForEthFundingPeriod > 0);

    require(_startTimeForEthFundingPeriod <= block.timestamp);

    require(block.timestamp < _startTimeForEthFundingPeriod + _durationForEthFundingPeriod);

    enterStage(Stages.EthFunding);

    return true;
  }

  function calculateTokenAmountForAmountInCents(uint256 _amountInCents)
    public
    view
    returns (uint256)
  {

    uint256 _percentOfFundingGoal = percent(
      _amountInCents,
      fundingGoalInCents,
      precisionOfPercentCalc
    );

    return totalSupply_
      .mul(_percentOfFundingGoal)
      .div(10 ** precisionOfPercentCalc);
  }

  function buyWithFiat(
    address _fiatInvestor,
    uint256 _amountInCents
  )
    external
    atStage(Stages.FiatFunding)
    isAddressWhitelisted(_fiatInvestor)
    onlyCustodian
    returns (bool)
  {

    require(_amountInCents > 0);

    fundedFiatAmountInCents = fundedFiatAmountInCents.add(_amountInCents);

    require(fundedFiatAmountInCents <= fundingGoalInCents);

    uint256 _tokenAmount = calculateTokenAmountForAmountInCents(_amountInCents);
    fundedFiatAmountInTokens = fundedFiatAmountInTokens.add(_tokenAmount);

    fundedFiatAmountPerUserInTokens[_fiatInvestor] = fundedFiatAmountPerUserInTokens[_fiatInvestor]
      .add(_tokenAmount);

    if (fundedFiatAmountInCents == fundingGoalInCents) {
      enterStage(Stages.FundingSuccessful);
    }

    return true;
  }

  function removeFiat(
    address _fiatInvestor,
    uint256 _amountInCents
  )
    external
    atStage(Stages.FiatFunding)
    onlyCustodian
    returns (bool)
  {

    require(_amountInCents > 0);

    uint256 _tokenAmount = calculateTokenAmountForAmountInCents(_amountInCents);

    fundedFiatAmountInCents = fundedFiatAmountInCents.sub(_amountInCents);
    fundedFiatAmountInTokens = fundedFiatAmountInTokens.sub(_tokenAmount);

    fundedFiatAmountPerUserInTokens[_fiatInvestor] = fundedFiatAmountPerUserInTokens[_fiatInvestor].sub(_tokenAmount);

    return true;
  }

  function buyWithEth()
    external
    payable
    checkTimeout
    atStage(Stages.EthFunding)
    isAddressWhitelisted(msg.sender)
    returns (bool)
  {

    require(!isFiatInvestor(msg.sender));

    if (isFundingGoalReached(0)) {
      enterStage(Stages.FundingSuccessful);

      if (msg.value > 0) {
        msg.sender.transfer(msg.value);
      }

      return false;
    }

    (uint256 _fundAmount, uint256 _refundAmount) = calculateFundingAmount(msg.value);
    if (isFundingGoalReached(msg.value)) {
      enterStage(Stages.FundingSuccessful);

      if (_refundAmount > 0) {
        msg.sender.transfer(_refundAmount);
      }
    }

    fundedEthAmountPerUserInWei[msg.sender] = fundedEthAmountPerUserInWei[msg.sender]
      .add(_fundAmount);
    fundedEthAmountInWei = fundedEthAmountInWei.add(_fundAmount);

    getContractAddress("PoaLogger").call(
      abi.encodeWithSignature("logBuy(address,uint256)", msg.sender, _fundAmount)
    );

    return true;
  }

  function calculateFundingAmount(uint256 _fullAmount)
    internal
    view
    returns (uint256, uint256)
  {

    if (isFundingGoalReached(_fullAmount)) {
      uint256 _refundAmount = fiatCentsToWei(fundedFiatAmountInCents)
        .add(fundedEthAmountInWei)
        .add(_fullAmount)
        .sub(fiatCentsToWei(fundingGoalInCents));

      return (_fullAmount.sub(_refundAmount), _refundAmount);
    }

    return (_fullAmount, 0);
  }

  function isFundingGoalReached(uint256 _withWeiAmount)
    public
    view
    returns (bool)
  {

    return fundingGoalInCents <=
      weiToFiatCents(
        fundedEthAmountInWei.add(_withWeiAmount)
      ).add(fundedFiatAmountInCents).add(1);
  }

  function calculateTotalFee()
    public
    view
    atStage(Stages.FundingSuccessful)
    returns (uint256)
  {

    uint256 _fundedFiatAmountInWei = fiatCentsToWei(fundedFiatAmountInCents);
    uint256 _fiatFee = calculateFee(_fundedFiatAmountInWei);
    uint256 _ethFee = calculateFee(fundedEthAmountInWei);

    return _fiatFee.add(_ethFee);
  }

  function payActivationFee()
    public
    payable
    atStage(Stages.FundingSuccessful)
    returns (bool)
  {

    require(isActivationFeePaid == false);

    uint256 paidAmountToCalculatedFeeRatio = percent(msg.value, calculateTotalFee(), precisionOfPercentCalc);

    require(paidAmountToCalculatedFeeRatio > 1e18 - 5e15);
    require(paidAmountToCalculatedFeeRatio < 1e18 + 5e15);

    payFee(msg.value);

    isActivationFeePaid = true;

    return true;
  }

  function activate()
    external
    checkTimeout
    onlyCustodian
    atStage(Stages.FundingSuccessful)
    returns (bool)
  {

    require(isActivationFeePaid);

    require(bytes(proofOfCustody()).length != 0);

    enterStage(Stages.Active);

    unclaimedPayoutTotals[issuer] = unclaimedPayoutTotals[issuer]
      .add(address(this).balance);

    paused = false;
    emit Unpause();

    return true;
  }

  function manualCheckForTimeout()
    external
    atMaxStage(Stages.FundingSuccessful)
    checkTimeout
    returns (bool)
  {

    if (stage != Stages.TimedOut) {
      revert();
    }

    return true;
  }

  function manualCheckForFundingSuccessful()
    public
    atStage(Stages.EthFunding)
    returns (bool)
  {

    if (isFundingGoalReached(0)) {
      enterStage(Stages.FundingSuccessful);
      return true;
    }

    return false;
  }

  function reclaim()
    external
    checkTimeout
    atStage(Stages.TimedOut)
    returns (bool)
  {

    require(!isFiatInvestor(msg.sender));
    totalSupply_ = 0;
    uint256 _refundAmount = fundedEthAmountPerUserInWei[msg.sender];
    fundedEthAmountPerUserInWei[msg.sender] = 0;
    require(_refundAmount > 0);
    fundedEthAmountInWei = fundedEthAmountInWei.sub(_refundAmount);
    msg.sender.transfer(_refundAmount);
    getContractAddress("PoaLogger").call(
      abi.encodeWithSignature(
        "logReClaim(address,uint256)",
        msg.sender,
        _refundAmount
      )
    );

    return true;
  }

  function cancelFunding()
    external
    onlyCustodian
    atMaxStage(Stages.FiatFunding)
    returns (bool)
  {

    enterStage(Stages.FundingCancelled);

    return true;
  }



  function percent(
    uint256 _numerator,
    uint256 _denominator,
    uint256 _precision
  )
    public
    pure
    returns (uint256)
  {

    uint256 _safeNumerator = _numerator.mul(uint256(10e27).rpow(_precision.add(1)));
    uint256 _quotient = _safeNumerator.div(_denominator).add(5).div(10e27);
    return (_quotient);
  }

  function getFiatRate()
    public
    view
    returns (uint256 _fiatRate)
  {

    bytes4 _sig = bytes4(keccak256("getRate32(bytes32)"));
    address _exchangeRates = getContractAddress("ExchangeRates");
    bytes32 _fiatCurrency = keccak256(abi.encodePacked(fiatCurrency()));

    assembly {
      let _call := mload(0x40) // set _call to free memory pointer
      mstore(_call, _sig) // store _sig at _call pointer
      mstore(add(_call, 0x04), _fiatCurrency) // store _fiatCurrency at _call offset by 4 bytes for pre-existing _sig

      let success := staticcall(
        gas,             // g = gas: whatever was passed already
        _exchangeRates,  // a = address: address from getContractAddress
        _call,           // in = mem in  mem[in..(in+insize): set to free memory pointer
        0x24,            // insize = mem insize  mem[in..(in+insize): size of sig (bytes4) + bytes32 = 0x24
        _call,           // out = mem out  mem[out..(out+outsize): output assigned to this storage address
        0x20             // outsize = mem outsize  mem[out..(out+outsize): output should be 32byte slot (uint256 size = 0x20 = slot size 0x20)
      )

      if iszero(success) {
        revert(0, 0)
      }

      _fiatRate := mload(_call) // assign result to return value
      mstore(0x40, add(_call, 0x24)) // advance free memory pointer by largest _call size
    }
  }

  function weiToFiatCents(uint256 _wei)
    public
    view
    returns (uint256)
  {

    return _wei.mul(getFiatRate()).div(1e18);
  }

  function fiatCentsToWei(uint256 _cents)
    public
    view
    returns (uint256)
  {

    return _cents.mul(1e18).div(getFiatRate());
  }

  function fundedEthAmountInCents()
    external
    view
    returns (uint256)
  {

    return weiToFiatCents(fundedEthAmountInWei);
  }

  function fundingGoalInWei()
    external
    view
    returns (uint256)
  {

    return fiatCentsToWei(fundingGoalInCents);
  }



  function fiatCurrency()
    public
    view
    returns (string)
  {

    return to32LengthString(fiatCurrency32);
  }

}