
pragma solidity 0.4.24;


contract ERC20Basic {

  function totalSupply() public view returns (uint256);

  function balanceOf(address who) public view returns (uint256);

  function transfer(address to, uint256 value) public returns (bool);

  event Transfer(address indexed from, address indexed to, uint256 value);
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

  function isFiatInvestor(
    address _buyer
  )
    internal
    view
    returns (bool)
  {

    return fundedFiatAmountPerUserInTokens[_buyer] != 0;
  }

  function isWhitelisted(
    address _address
  )
    public
    view
    returns (bool _isWhitelisted)
  {

    bytes4 _signature = bytes4(keccak256("whitelisted(address)"));
    address _whitelistContract = getContractAddress("Whitelist");

    assembly {
      let _pointer := mload(0x40)  // Set _pointer to free memory pointer
      mstore(_pointer, _signature) // Store _signature at _pointer
      mstore(add(_pointer, 0x04), _address) // Store _address at _pointer. Offset by 4 bytes for previously stored _signature

      let result := staticcall(
        gas,                // g = gas: whatever was passed already
        _whitelistContract, // a = address: _whitelist address assigned from getContractAddress()
        _pointer,           // in = mem in  mem[in..(in+insize): set to _pointer pointer
        0x24,               // insize = mem insize  mem[in..(in+insize): size of signature (bytes4) + bytes32 = 0x24
        _pointer,           // out = mem out  mem[out..(out+outsize): output assigned to this storage address
        0x20                // outsize = mem outsize  mem[out..(out+outsize): output should be 32byte slot (bool size = 0x01 < slot size 0x20)
      )

      if iszero(result) {
        revert(0, 0)
      }

      _isWhitelisted := mload(_pointer) // Assign result to returned value
      mstore(0x40, add(_pointer, 0x24)) // Advance free memory pointer by largest _pointer size
    }
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


contract PoaToken is PoaCommon {

  uint256 public constant tokenVersion = 1;


  bytes32 private name32;
  bytes32 private symbol32;
  uint8 public constant decimals = 18;
  uint256 public totalPerTokenPayout;
  address public owner;
  mapping(address => uint256) public claimedPerTokenPayouts;
  mapping(address => uint256) public spentBalances;
  mapping(address => uint256) public receivedBalances;
  mapping(address => mapping (address => uint256)) internal allowed;



  event Pause();
  event Unpause();
  event OwnershipTransferred(
    address indexed previousOwner,
    address indexed newOwner
  );
  event Approval(
    address indexed owner,
    address indexed spender,
    uint256 value
  );
  event Transfer(
    address indexed from,
    address indexed to,
    uint256 value
  );



  modifier onlyOwner() {

    owner = getContractAddress("PoaManager");
    require(msg.sender == owner);
    _;
  }

  modifier whenNotPaused() {

    require(!paused);
    _;
  }

  modifier whenPaused() {

    require(paused);
    _;
  }

  modifier eitherCustodianOrOwner() {

    owner = getContractAddress("PoaManager");
    require(
      msg.sender == custodian ||
      msg.sender == owner
    );
    _;
  }

  modifier eitherIssuerOrCustodian() {

    require(
      msg.sender == issuer ||
      msg.sender == custodian
    );
    _;
  }

  modifier isTransferWhitelisted(
    address _address
  )
  {

    require(isWhitelisted(_address));
    _;
  }


  function initializeToken(
    bytes32 _name32, // bytes32 of name string
    bytes32 _symbol32, // bytes32 of symbol string
    address _issuer,
    address _custodian,
    address _registry,
    uint256 _totalSupply // token total supply
  )
    external
    returns (bool)
  {

    require(!tokenInitialized);

    setName(_name32);
    setSymbol(_symbol32);
    setIssuerAddress(_issuer);
    setCustodianAddress(_custodian);
    setTotalSupply(_totalSupply);

    owner = getContractAddress("PoaManager");
    registry = _registry;

    paused = true;
    tokenInitialized = true;

    return true;
  }


  function updateName(bytes32 _newName32)
    external
    onlyIssuer
    atStage(Stages.Preview)
  {

    setName(_newName32);
  }

  function updateSymbol(bytes32 _newSymbol32)
    external
    onlyIssuer
    atStage(Stages.Preview)
  {

    setSymbol(_newSymbol32);
  }

  function updateIssuerAddress(address _newIssuer)
    external
    onlyIssuer
    atStage(Stages.Preview)
  {

    setIssuerAddress(_newIssuer);
  }

  function updateTotalSupply(uint256 _newTotalSupply)
    external
    onlyIssuer
    atStage(Stages.Preview)
  {

    setTotalSupply(_newTotalSupply);
  }



  function setName(bytes32 _newName32)
    internal
  {

    require(_newName32 != bytes32(0));
    require(_newName32 != name32);

    name32 = _newName32;
  }

  function setSymbol(bytes32 _newSymbol32)
    internal
  {

    require(_newSymbol32 != bytes32(0));
    require(_newSymbol32 != symbol32);

    symbol32 = _newSymbol32;
  }

  function setIssuerAddress(address _newIssuer)
    internal
  {

    require(_newIssuer != address(0));
    require(_newIssuer != issuer);

    issuer = _newIssuer;
  }

  function setCustodianAddress(address _newCustodian)
    internal
  {

    require(_newCustodian != address(0));
    require(_newCustodian != custodian);

    custodian = _newCustodian;
  }

  function setTotalSupply(uint256 _newTotalSupply)
    internal
  {

    require(_newTotalSupply >= 1e18);
    require(fundingGoalInCents < _newTotalSupply);
    require(_newTotalSupply != totalSupply_);

    totalSupply_ = _newTotalSupply;
  }



  function changeCustodianAddress(address _newCustodian)
    external
    onlyCustodian
    returns (bool)
  {

    getContractAddress("PoaLogger").call(
      abi.encodeWithSignature(
        "logCustodianChanged(address,address)",
        custodian,
        _newCustodian
      )
    );

    setCustodianAddress(_newCustodian);

    return true;
  }

  function startPreFunding()
    external
    onlyIssuer
    atStage(Stages.Preview)
    returns (bool)
  {

    require(startTimeForFundingPeriod > block.timestamp);

    enterStage(Stages.PreFunding);

    return true;
  }

  function terminate()
    external
    eitherCustodianOrOwner
    atStage(Stages.Active)
    returns (bool)
  {

    enterStage(Stages.Terminated);
    paused = true;
    getContractAddress("PoaLogger").call(
      abi.encodeWithSignature("logTerminated()")
    );

    return true;
  }



  function pause()
    public
    onlyOwner
    whenNotPaused
  {

    paused = true;
    emit Pause();
  }

  function unpause()
    public
    onlyOwner
    whenPaused
    atStage(Stages.Active)
  {

    paused = false;
    emit Unpause();
  }



  function name()
    external
    view
    returns (string)
  {

    return to32LengthString(name32);
  }

  function symbol()
    external
    view
    returns (string)
  {

    return to32LengthString(symbol32);
  }

  function totalSupply()
    public
    view
    returns (uint256)
  {

    return totalSupply_;
  }



  function currentPayout(
    address _address,
    bool _includeUnclaimed
  )
    public
    view
    returns (uint256)
  {

    uint256 _totalPerTokenUnclaimedConverted = totalPerTokenPayout == 0
      ? 0
      : balanceOf(_address)
      .mul(totalPerTokenPayout.sub(claimedPerTokenPayouts[_address]))
      .div(1e18);

    return _includeUnclaimed
      ? _totalPerTokenUnclaimedConverted.add(unclaimedPayoutTotals[_address])
      : _totalPerTokenUnclaimedConverted;
  }

  function settleUnclaimedPerTokenPayouts(
    address _from,
    address _to
  )
    internal
    returns (bool)
  {

    unclaimedPayoutTotals[_from] = unclaimedPayoutTotals[_from]
      .add(currentPayout(_from, false));
    claimedPerTokenPayouts[_from] = totalPerTokenPayout;
    unclaimedPayoutTotals[_to] = unclaimedPayoutTotals[_to]
      .add(currentPayout(_to, false));
    claimedPerTokenPayouts[_to] = totalPerTokenPayout;

    return true;
  }

  function payout()
    external
    payable
    eitherIssuerOrCustodian
    atEitherStage(Stages.Active, Stages.Terminated)
    returns (bool)
  {

    uint256 _fee = calculateFee(msg.value);
    require(_fee > 0);
    uint256 _payoutAmount = msg.value.sub(_fee);
    totalPerTokenPayout = totalPerTokenPayout
      .add(_payoutAmount
        .mul(1e18)
        .div(totalSupply_)
      );

    uint256 _delta = (_payoutAmount.mul(1e18) % totalSupply_).div(1e18);
    payFee(_fee.add(_delta));
    getContractAddress("PoaLogger").call(
      abi.encodeWithSignature(
        "logPayout(uint256)",
        _payoutAmount.sub(_delta)
      )
    );

    return true;
  }

  function claim()
    external
    atEitherStage(Stages.Active, Stages.Terminated)
    returns (uint256)
  {

    uint256 _payoutAmount = currentPayout(msg.sender, true);
    require(_payoutAmount > 0);
    claimedPerTokenPayouts[msg.sender] = totalPerTokenPayout;
    unclaimedPayoutTotals[msg.sender] = 0;
    msg.sender.transfer(_payoutAmount);
    getContractAddress("PoaLogger").call(
      abi.encodeWithSignature(
        "logClaim(address,uint256)",
        msg.sender,
        _payoutAmount
      )
    );

    return _payoutAmount;
  }

  function updateProofOfCustody(bytes32[2] _ipfsHash)
    external
    onlyCustodian
    validIpfsHash(_ipfsHash)
    returns (bool)
  {

    require(
      stage == Stages.Active || stage == Stages.FundingSuccessful || stage == Stages.Terminated
    );
    proofOfCustody32_ = _ipfsHash;
    getContractAddress("PoaLogger").call(
      abi.encodeWithSignature(
        "logProofOfCustodyUpdated()",
        _ipfsHash
      )
    );

    return true;
  }



  function startingBalance(address _address)
    internal
    view
    returns (uint256)
  {

    if (stage < Stages.Active) {
      return 0;
    }

    return isFiatInvestor(_address)
      ? fundedFiatAmountPerUserInTokens[_address]
      : fundedEthAmountPerUserInWei[_address]
      .mul(totalSupply_.sub(fundedFiatAmountInTokens))
      .div(fundedEthAmountInWei);
  }

  function balanceOf(address _address)
    public
    view
    returns (uint256)
  {

    return startingBalance(_address)
      .add(receivedBalances[_address])
      .sub(spentBalances[_address]);
  }

  function transfer(
    address _to,
    uint256 _value
  )
    public
    whenNotPaused
    isTransferWhitelisted(_to)
    isTransferWhitelisted(msg.sender)
    returns (bool)
  {

    settleUnclaimedPerTokenPayouts(msg.sender, _to);

    require(_to != address(0));
    require(_value <= balanceOf(msg.sender));
    spentBalances[msg.sender] = spentBalances[msg.sender].add(_value);
    receivedBalances[_to] = receivedBalances[_to].add(_value);
    emit Transfer(msg.sender, _to, _value);

    return true;
  }

  function transferFrom(
    address _from,
    address _to,
    uint256 _value
  )
    public
    whenNotPaused
    isTransferWhitelisted(_to)
    isTransferWhitelisted(_from)
    returns (bool)
  {

    settleUnclaimedPerTokenPayouts(_from, _to);

    require(_to != address(0));
    require(_value <= balanceOf(_from));
    require(_value <= allowed[_from][msg.sender]);
    spentBalances[_from] = spentBalances[_from].add(_value);
    receivedBalances[_to] = receivedBalances[_to].add(_value);
    allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);
    emit Transfer(_from, _to, _value);

    return true;
  }

  function approve(
    address _spender,
    uint256 _value
  )
    public
    whenNotPaused
    returns (bool)
  {

    allowed[msg.sender][_spender] = _value;
    emit Approval(msg.sender, _spender, _value);

    return true;
  }

  function increaseApproval(
    address _spender,
    uint _addedValue
  )
    public
    whenNotPaused
    returns (bool success)
  {

    allowed[msg.sender][_spender] = (
      allowed[msg.sender][_spender].add(_addedValue));
    emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);

    return true;
  }

  function decreaseApproval(
    address _spender,
    uint _subtractedValue
  )
    public
    whenNotPaused
    returns (bool success)
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


  function()
    external
    payable
  {
    assembly {
      let _poaCrowdsaleMaster := sload(poaCrowdsaleMaster_slot)
      calldatacopy(
        0x0, // t = mem position to
        0x0, // f = mem position from
        calldatasize // s = size bytes
      )

      let result := delegatecall(
        gas, // g = gas
        _poaCrowdsaleMaster, // a = address
        0x0, // in = mem in  mem[in..(in+insize)
        calldatasize, // insize = mem insize  mem[in..(in+insize)
        0x0, // out = mem out  mem[out..(out+outsize)
        0 // outsize = mem outsize  mem[out..(out+outsize)
      )

      if iszero(result) {
        revert(0, 0)
      }

      returndatacopy(
        0x0, // t = mem position to
        0x0,  // f = mem position from
        returndatasize // s = size bytes
      )

      return(
        0x0,
        returndatasize
      )
    }
  }
}