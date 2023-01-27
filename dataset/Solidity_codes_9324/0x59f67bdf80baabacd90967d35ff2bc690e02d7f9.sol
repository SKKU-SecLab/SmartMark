
pragma solidity ^0.4.24;



library SafeMath {


  function mul(uint256 a, uint256 b) internal pure returns (uint256) {

    if (a == 0) {
      return 0;
    }
    uint256 c = a * b;
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

  function add(uint256 a, uint256 b) internal pure returns (uint256) {

    uint256 c = a + b;
    assert(c >= a);
    return c;
  }

  function getFractionalAmount(uint256 _amount, uint256 _percentage)
  internal
  pure
  returns (uint256) {

    return div(mul(_amount, _percentage), 100);
  }

}


interface DBInterface {


  function setContractManager(address _contractManager)
  external;



    function setAddress(bytes32 _key, address _value)
    external;


    function setUint(bytes32 _key, uint _value)
    external;


    function setString(bytes32 _key, string _value)
    external;


    function setBytes(bytes32 _key, bytes _value)
    external;


    function setBytes32(bytes32 _key, bytes32 _value)
    external;


    function setBool(bytes32 _key, bool _value)
    external;


    function setInt(bytes32 _key, int _value)
    external;




    function deleteAddress(bytes32 _key)
    external;


    function deleteUint(bytes32 _key)
    external;


    function deleteString(bytes32 _key)
    external;


    function deleteBytes(bytes32 _key)
    external;


    function deleteBytes32(bytes32 _key)
    external;


    function deleteBool(bytes32 _key)
    external;


    function deleteInt(bytes32 _key)
    external;



    function uintStorage(bytes32 _key)
    external
    view
    returns (uint);


    function stringStorage(bytes32 _key)
    external
    view
    returns (string);


    function addressStorage(bytes32 _key)
    external
    view
    returns (address);


    function bytesStorage(bytes32 _key)
    external
    view
    returns (bytes);


    function bytes32Storage(bytes32 _key)
    external
    view
    returns (bytes32);


    function boolStorage(bytes32 _key)
    external
    view
    returns (bool);


    function intStorage(bytes32 _key)
    external
    view
    returns (bool);

}


contract Events {

  DBInterface public database;

  constructor(address _database) public{
    database = DBInterface(_database);
  }

  function message(string _message)
  external
  onlyApprovedContract {

      emit LogEvent(_message, keccak256(abi.encodePacked(_message)), tx.origin);
  }

  function transaction(string _message, address _from, address _to, uint _amount, address _token)
  external
  onlyApprovedContract {

      emit LogTransaction(_message, keccak256(abi.encodePacked(_message)), _from, _to, _amount, _token, tx.origin);
  }

  function registration(string _message, address _account)
  external
  onlyApprovedContract {

      emit LogAddress(_message, keccak256(abi.encodePacked(_message)), _account, tx.origin);
  }

  function contractChange(string _message, address _account, string _name)
  external
  onlyApprovedContract {

      emit LogContractChange(_message, keccak256(abi.encodePacked(_message)), _account, _name, tx.origin);
  }

  function asset(string _message, string _uri, address _assetAddress, address _manager)
  external
  onlyApprovedContract {

      emit LogAsset(_message, keccak256(abi.encodePacked(_message)), _uri, keccak256(abi.encodePacked(_uri)), _assetAddress, _manager, tx.origin);
  }

  function escrow(string _message, address _assetAddress, bytes32 _escrowID, address _manager, uint _amount)
  external
  onlyApprovedContract {

      emit LogEscrow(_message, keccak256(abi.encodePacked(_message)), _assetAddress, _escrowID, _manager, _amount, tx.origin);
  }

  function order(string _message, bytes32 _orderID, uint _amount, uint _price)
  external
  onlyApprovedContract {

      emit LogOrder(_message, keccak256(abi.encodePacked(_message)), _orderID, _amount, _price, tx.origin);
  }

  function exchange(string _message, bytes32 _orderID, address _assetAddress, address _account)
  external
  onlyApprovedContract {

      emit LogExchange(_message, keccak256(abi.encodePacked(_message)), _orderID, _assetAddress, _account, tx.origin);
  }

  function operator(string _message, bytes32 _id, string _name, string _ipfs, address _account)
  external
  onlyApprovedContract {

      emit LogOperator(_message, keccak256(abi.encodePacked(_message)), _id, _name, _ipfs, _account, tx.origin);
  }

  function consensus(string _message, bytes32 _executionID, bytes32 _votesID, uint _votes, uint _tokens, uint _quorum)
  external
  onlyApprovedContract {

    emit LogConsensus(_message, keccak256(abi.encodePacked(_message)), _executionID, _votesID, _votes, _tokens, _quorum, tx.origin);
  }

  event LogEvent(string message, bytes32 indexed messageID, address indexed origin);
  event LogTransaction(string message, bytes32 indexed messageID, address indexed from, address indexed to, uint amount, address token, address origin); //amount and token will be empty on some events
  event LogAddress(string message, bytes32 indexed messageID, address indexed account, address indexed origin);
  event LogContractChange(string message, bytes32 indexed messageID, address indexed account, string name, address indexed origin);
  event LogAsset(string message, bytes32 indexed messageID, string uri, bytes32 indexed assetID, address asset, address manager, address indexed origin);
  event LogEscrow(string message, bytes32 indexed messageID, address asset, bytes32  escrowID, address indexed manager, uint amount, address indexed origin);
  event LogOrder(string message, bytes32 indexed messageID, bytes32 indexed orderID, uint amount, uint price, address indexed origin);
  event LogExchange(string message, bytes32 indexed messageID, bytes32 orderID, address indexed asset, address account, address indexed origin);
  event LogOperator(string message, bytes32 indexed messageID, bytes32 id, string name, string ipfs, address indexed account, address indexed origin);
  event LogConsensus(string message, bytes32 indexed messageID, bytes32 executionID, bytes32 votesID, uint votes, uint tokens, uint quorum, address indexed origin);


  modifier onlyApprovedContract() {

      require(database.boolStorage(keccak256(abi.encodePacked("contract", msg.sender))));
      _;
  }

}


interface PullPayment {


	function withdraw()	external returns(bool);


}


contract StandardDistribution{

  using SafeMath for uint;


  uint public supply;
  mapping (address => uint) internal balances;

  string public tokenURI;                 // A reference to a URI containing further token information


  uint constant scalingFactor = 1e32;
  uint public assetIncome;
  uint public valuePerToken;

  mapping (address => uint) public claimableIncome;
  mapping (address => uint) public previousValuePerToken;


  function withdraw()
  public
  updateclaimableIncome(msg.sender)
  returns (uint _amount) {

      _amount = claimableIncome[msg.sender].div(scalingFactor);
      delete claimableIncome[msg.sender];
      msg.sender.transfer(_amount);
      emit LogIncomeCollected(now, msg.sender, _amount);
  }
  function issueDividends()
  payable
  public {

      valuePerToken = valuePerToken.add(msg.value.mul(scalingFactor).div(supply));
      assetIncome = assetIncome.add(msg.value);
      emit LogIncomeReceived(msg.sender, msg.value);
  }

  function ()
    payable
    public {
      valuePerToken = valuePerToken.add(msg.value.mul(scalingFactor).div(supply));
      assetIncome = assetIncome.add(msg.value);
      emit LogIncomeReceived(msg.sender, msg.value);
  }


  function getTokenValue(address _user)
  public
  view
  returns (uint) {

      uint valuePerTokenDifference = valuePerToken.sub(previousValuePerToken[_user]);
      return valuePerTokenDifference.mul(balances[_user]);
  }

  function getUnclaimedAmount(address _user)
  public
  view
  returns (uint) {

      return (getTokenValue(_user).add(claimableIncome[_user]).div(scalingFactor));
  }

  function totalSupply() public view returns (uint256) {

    return supply;
  }

  function balanceOf(address _owner) public view returns (uint256) {

    return balances[_owner];
  }


  modifier updateclaimableIncome(address _user) {

      claimableIncome[_user] = claimableIncome[_user].add(getTokenValue(_user));
      previousValuePerToken[_user] = valuePerToken;
      _;
  }



  event LogIncomeReceived(address indexed _sender, uint _paymentAmount);
  event LogIncomeCollected(uint _block, address _address, uint _amount);

}


contract FixedDistribution is StandardDistribution {

  using SafeMath for uint;

  constructor(string _tokenURI, address[] _tokenHolders, uint[] _amount)
  public {
    require(_tokenHolders.length < 200 && _tokenHolders.length == _amount.length);
    uint _totalSupply;
    tokenURI = _tokenURI;
    for (uint8 i = 0; i < _tokenHolders.length; i++) {
      _totalSupply = _totalSupply.add(_amount[i]);
      balances[_tokenHolders[i]] = balances[_tokenHolders[i]].add(_amount[i]);
    }
    supply = _totalSupply;
  }
}


interface MinterInterface {

  function cloneToken(string _uri, address _erc20Address) external returns (address asset);


  function mintAssetTokens(address _assetAddress, address _receiver, uint256 _amount) external returns (bool);


  function changeTokenController(address _assetAddress, address _newController) external returns (bool);

}





contract AssetGenerator {

  using SafeMath for uint256;

  DBInterface private database;
  Events private events;
  MinterInterface private minter;


  constructor(address _database, address _events)
  public{
      database = DBInterface(_database);
      events = Events(_events);
      minter = MinterInterface(database.addressStorage(keccak256(abi.encodePacked("contract", "Minter"))));
  }


  function createAsset(string _tokenURI, address[] _tokenHolders, uint[] _amount)
  external
  returns (bool) {

    require (_tokenHolders.length == _amount.length && _tokenHolders.length <= 100);
    FixedDistribution assetInstance = new FixedDistribution(_tokenURI, _tokenHolders, _amount);
    database.setAddress(keccak256(abi.encodePacked("asset.manager", address(assetInstance))), msg.sender);
    events.asset('Asset created', _tokenURI, address(assetInstance), msg.sender);
    return true;
  }

  function createTradeableAsset(string _tokenURI, address[] _tokenHolders, uint[] _amount)
  external
  returns (bool) {

    require (_tokenHolders.length == _amount.length && _tokenHolders.length <= uint8(100));
    address assetAddress = minter.cloneToken(_tokenURI, address(0));
    for (uint8 i = 0; i < _tokenHolders.length; i++) {
      minter.mintAssetTokens(assetAddress, _tokenHolders[i], _amount[i]);
    }
    database.setAddress(keccak256(abi.encodePacked("asset.manager", assetAddress)), msg.sender);
    events.asset('Asset created', _tokenURI, assetAddress, msg.sender);
    return true;
  }

  function destroy()
  onlyOwner
  external {

    events.transaction('AssetGenerator destroyed', address(this), msg.sender, address(this).balance, address(0));
    selfdestruct(msg.sender);
  }


  modifier onlyOwner {

    require(database.boolStorage(keccak256(abi.encodePacked("owner", msg.sender))), "Not owner");
    _;
  }
}