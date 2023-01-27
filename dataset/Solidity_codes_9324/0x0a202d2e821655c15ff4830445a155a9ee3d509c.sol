
pragma solidity 0.6.2;
contract Owned {


  address payable public owner;
  address private pendingOwner;

  event OwnershipTransferRequested(
    address indexed from,
    address indexed to
  );
  event OwnershipTransferred(
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

    emit OwnershipTransferred(oldOwner, msg.sender);
  }

  modifier onlyOwner() {

    require(msg.sender == owner, "Only callable by owner");
    _;
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
interface HistoricAggregatorInterface {

  function latestAnswer() external returns (int256);

  function latestTimestamp() external returns (uint256);

  function latestRound() external returns (uint256);

  function getAnswer(uint256 roundId) external returns (int256);

  function getTimestamp(uint256 roundId) external returns (uint256);


  event AnswerUpdated(int256 indexed current, uint256 indexed roundId, uint256 timestamp);
  event NewRound(uint256 indexed roundId, address indexed startedBy, uint256 startedAt);
}
interface AggregatorInterface is HistoricAggregatorInterface {

  function decimals() external returns (uint8);

  function getRoundData(uint256 _roundId)
    external
    returns (
      uint256 roundId,
      int256 answer,
      uint256 startedAt,
      uint256 updatedAt,
      uint256 answeredInRound
    );

  function latestRoundData()
    external
    returns (
      uint256 roundId,
      int256 answer,
      uint256 startedAt,
      uint256 updatedAt,
      uint256 answeredInRound
    );

}
contract AggregatorProxy is AggregatorInterface, Owned {


  AggregatorInterface public aggregator;

  constructor(address _aggregator) public Owned() {
    setAggregator(_aggregator);
  }

  function latestAnswer()
    external
    virtual
    override
    returns (int256)
  {

    return _latestAnswer();
  }

  function latestTimestamp()
    external
    virtual
    override
    returns (uint256)
  {

    return _latestTimestamp();
  }

  function getAnswer(uint256 _roundId)
    external
    virtual
    override
    returns (int256)
  {

    return _getAnswer(_roundId);
  }

  function getTimestamp(uint256 _roundId)
    external
    virtual
    override
    returns (uint256)
  {

    return _getTimestamp(_roundId);
  }

  function latestRound()
    external
    virtual
    override
    returns (uint256)
  {

    return _latestRound();
  }

  function getRoundData(uint256 _roundId)
    external
    virtual
    override
    returns (
      uint256 roundId,
      int256 answer,
      uint256 startedAt,
      uint256 updatedAt,
      uint256 answeredInRound
    )
  {

    return _getRoundData(_roundId);
  }

  function latestRoundData()
    external
    virtual
    override
    returns (
      uint256 roundId,
      int256 answer,
      uint256 startedAt,
      uint256 updatedAt,
      uint256 answeredInRound
    )
  {

    return _latestRoundData();
  }

  function decimals()
    external
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
    returns (int256)
  {

    return aggregator.latestAnswer();
  }

  function _latestTimestamp()
    internal
    returns (uint256)
  {

    return aggregator.latestTimestamp();
  }

  function _getAnswer(uint256 _roundId)
    internal
    returns (int256)
  {

    return aggregator.getAnswer(_roundId);
  }

  function _getTimestamp(uint256 _roundId)
    internal
    returns (uint256)
  {

    return aggregator.getTimestamp(_roundId);
  }

  function _latestRound()
    internal
    returns (uint256)
  {

    return aggregator.latestRound();
  }

  function _getRoundData(uint256 _roundId)
    internal
    returns (
      uint256 roundId,
      int256 answer,
      uint256 startedAt,
      uint256 updatedAt,
      uint256 answeredInRound
    )
  {

    return aggregator.getRoundData(_roundId);
  }

  function _latestRoundData()
    internal
    returns (
      uint256 roundId,
      int256 answer,
      uint256 startedAt,
      uint256 updatedAt,
      uint256 answeredInRound
    )
  {

    return aggregator.latestRoundData();
  }
}
contract WhitelistedAggregatorProxy is AggregatorProxy, Whitelisted {


  constructor(address _aggregator) public AggregatorProxy(_aggregator) {
  }

  function latestAnswer()
    external
    override
    isWhitelisted()
    returns (int256)
  {

    return _latestAnswer();
  }

  function latestTimestamp()
    external
    override
    isWhitelisted()
    returns (uint256)
  {

    return _latestTimestamp();
  }

  function getAnswer(uint256 _roundId)
    external
    override
    isWhitelisted()
    returns (int256)
  {

    return _getAnswer(_roundId);
  }

  function getTimestamp(uint256 _roundId)
    external
    override
    isWhitelisted()
    returns (uint256)
  {

    return _getTimestamp(_roundId);
  }

  function latestRound()
    external
    override
    isWhitelisted()
    returns (uint256)
  {

    return _latestRound();
  }

  function getRoundData(uint256 _roundId)
    external
    isWhitelisted()
    override
    returns (
      uint256 roundId,
      int256 answer,
      uint256 startedAt,
      uint256 updatedAt,
      uint256 answeredInRound
    )
  {

    return _getRoundData(_roundId);
  }

  function latestRoundData()
    external
    isWhitelisted()
    override
    returns (
      uint256 roundId,
      int256 answer,
      uint256 startedAt,
      uint256 updatedAt,
      uint256 answeredInRound
    )
  {

    return _latestRoundData();
  }

}