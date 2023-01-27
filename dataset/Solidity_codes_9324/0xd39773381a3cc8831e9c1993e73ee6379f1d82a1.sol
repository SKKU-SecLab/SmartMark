
pragma solidity 0.6.2;

contract Owned {


  address payable public owner;
  address private pendingOwner;

  event OwnershipTransferRequested(
    address indexed from,
    address indexed to
  );
  event OwnershipTransfered(
    address indexed from,
    address indexed to
  );

  constructor() public {
    owner = msg.sender;
  }

  function transferOwnership(address _to)
    external
    onlyOwner()
  {

    pendingOwner = _to;

    emit OwnershipTransferRequested(owner, _to);
  }

  function acceptOwnership()
    external
  {

    require(msg.sender == pendingOwner, "Must be proposed owner");

    address oldOwner = owner;
    owner = msg.sender;
    pendingOwner = address(0);

    emit OwnershipTransfered(oldOwner, msg.sender);
  }

  modifier onlyOwner() {

    require(msg.sender == owner, "Only callable by owner");
    _;
  }

}


interface AggregatorInterface {

  function latestAnswer() external view returns (int256);

  function latestTimestamp() external view returns (uint256);

  function latestRound() external view returns (uint256);

  function getAnswer(uint256 roundId) external view returns (int256);

  function getTimestamp(uint256 roundId) external view returns (uint256);

  function decimals() external view returns (uint8);


  event AnswerUpdated(int256 indexed current, uint256 indexed roundId, uint256 timestamp);
  event NewRound(uint256 indexed roundId, address indexed startedBy, uint256 startedAt);
}







contract AggregatorProxy is AggregatorInterface, Owned {


  AggregatorInterface public aggregator;

  constructor(address _aggregator) public Owned() {
    setAggregator(_aggregator);
  }

  function latestAnswer()
    external
    view
    virtual
    override
    returns (int256)
  {

    return _latestAnswer();
  }

  function latestTimestamp()
    external
    view
    virtual
    override
    returns (uint256)
  {

    return _latestTimestamp();
  }

  function getAnswer(uint256 _roundId)
    external
    view
    virtual
    override
    returns (int256)
  {

    return _getAnswer(_roundId);
  }

  function getTimestamp(uint256 _roundId)
    external
    view
    virtual
    override
    returns (uint256)
  {

    return _getTimestamp(_roundId);
  }

  function latestRound()
    external
    view
    virtual
    override
    returns (uint256)
  {

    return _latestRound();
  }

  function decimals()
    external
    view
    override
    returns (uint8)
  {

    return aggregator.decimals();
  }

  function setAggregator(address _aggregator)
    public
    onlyOwner()
  {

    aggregator = AggregatorInterface(_aggregator);
  }


  function _latestAnswer()
    internal
    view
    returns (int256)
  {

    return aggregator.latestAnswer();
  }

  function _latestTimestamp()
    internal
    view
    returns (uint256)
  {

    return aggregator.latestTimestamp();
  }

  function _getAnswer(uint256 _roundId)
    internal
    view
    returns (int256)
  {

    return aggregator.getAnswer(_roundId);
  }

  function _getTimestamp(uint256 _roundId)
    internal
    view
    returns (uint256)
  {

    return aggregator.getTimestamp(_roundId);
  }

  function _latestRound()
    internal
    view
    returns (uint256)
  {

    return aggregator.latestRound();
  }
}





contract Whitelisted is Owned {


  bool public whitelistEnabled;
  mapping(address => bool) public whitelisted;

  event AddedToWhitelist(address user);
  event RemovedFromWhitelist(address user);
  event WhitelistEnabled();
  event WhitelistDisabled();

  constructor()
    public
  {
    whitelistEnabled = true;
  }

  function addToWhitelist(address _user) external onlyOwner() {

    whitelisted[_user] = true;
    emit AddedToWhitelist(_user);
  }

  function removeFromWhitelist(address _user) external onlyOwner() {

    delete whitelisted[_user];
    emit RemovedFromWhitelist(_user);
  }

  function enableWhitelist()
    external
    onlyOwner()
  {

    whitelistEnabled = true;

    emit WhitelistEnabled();
  }

  function disableWhitelist()
    external
    onlyOwner()
  {

    whitelistEnabled = false;

    emit WhitelistDisabled();
  }

  modifier isWhitelisted() {

    require(whitelisted[msg.sender] || !whitelistEnabled, "Not whitelisted");
    _;
  }
}


contract WhitelistedAggregatorProxy is AggregatorProxy, Whitelisted {


  constructor(address _aggregator) public AggregatorProxy(_aggregator) {
  }

  function latestAnswer()
    external
    view
    override
    isWhitelisted()
    returns (int256)
  {

    return _latestAnswer();
  }

  function latestTimestamp()
    external
    view
    override
    isWhitelisted()
    returns (uint256)
  {

    return _latestTimestamp();
  }

  function getAnswer(uint256 _roundId)
    external
    view
    override
    isWhitelisted()
    returns (int256)
  {

    return _getAnswer(_roundId);
  }

  function getTimestamp(uint256 _roundId)
    external
    view
    override
    isWhitelisted()
    returns (uint256)
  {

    return _getTimestamp(_roundId);
  }

  function latestRound()
    external
    view
    override
    isWhitelisted()
    returns (uint256)
  {

    return _latestRound();
  }
}