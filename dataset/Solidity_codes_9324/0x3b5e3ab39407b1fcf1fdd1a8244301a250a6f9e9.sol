
pragma solidity 0.6.6;


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

interface AggregatorInterface {

  function latestAnswer() external view returns (int256);

  function latestTimestamp() external view returns (uint256);

  function latestRound() external view returns (uint256);

  function getAnswer(uint256 roundId) external view returns (int256);

  function getTimestamp(uint256 roundId) external view returns (uint256);


  event AnswerUpdated(int256 indexed current, uint256 indexed roundId, uint256 timestamp);
  event NewRound(uint256 indexed roundId, address indexed startedBy, uint256 startedAt);
}

interface AggregatorV3Interface {


  function decimals() external view returns (uint8);

  function description() external view returns (string memory);

  function version() external view returns (uint256);


  function getRoundData(uint80 _roundId)
    external
    view
    returns (
      uint80 roundId,
      int256 answer,
      uint256 startedAt,
      uint256 updatedAt,
      uint80 answeredInRound
    );

  function latestRoundData()
    external
    view
    returns (
      uint80 roundId,
      int256 answer,
      uint256 startedAt,
      uint256 updatedAt,
      uint80 answeredInRound
    );


  event NewRound(
    uint256 indexed roundId,
    address indexed startedBy,
    uint256 startedAt
  );
  event AnswerUpdated(
    int256 indexed current,
    uint256 indexed roundId,
    uint256 updatedAt
  );

}

contract AggregatorProxy is AggregatorInterface, AggregatorV3Interface, Owned {


  struct Phase {
    uint16 id;
    AggregatorV3Interface aggregator;
  }
  Phase private currentPhase;
  AggregatorV3Interface public proposedAggregator;
  mapping(uint16 => AggregatorV3Interface) public phaseAggregators;

  uint256 constant private PHASE_OFFSET = 64;
  string constant private V3_NO_DATA_ERROR = "No data present";
  bytes32 constant private EXPECTED_V3_ERROR = keccak256(bytes(V3_NO_DATA_ERROR));

  constructor(address _aggregator) public Owned() {
    setAggregator(_aggregator);
  }

  function latestAnswer()
    public
    view
    virtual
    override
    returns (int256 answer)
  {

    ( , answer, , , ) = tryLatestRoundData();
  }

  function latestTimestamp()
    public
    view
    virtual
    override
    returns (uint256 updatedAt)
  {

    ( , , , updatedAt, ) = tryLatestRoundData();
  }

  function getAnswer(uint256 _roundId)
    public
    view
    virtual
    override
    returns (int256 answer)
  {

    ( , answer, , , ) = tryGetRoundData(_roundId);
  }

  function getTimestamp(uint256 _roundId)
    public
    view
    virtual
    override
    returns (uint256 updatedAt)
  {

    ( , , , updatedAt, ) = tryGetRoundData(_roundId);
  }

  function latestRound()
    public
    view
    virtual
    override
    returns (uint256 roundId)
  {

    ( roundId, , , , ) = tryLatestRoundData();
  }

  function getRoundData(uint80 _roundId)
    public
    view
    virtual
    override
    returns (
      uint80 roundId,
      int256 answer,
      uint256 startedAt,
      uint256 updatedAt,
      uint80 answeredInRound
    )
  {

    (uint16 phaseId, uint64 aggregatorRoundId) = parseIds(_roundId);

    (
      uint80 roundId,
      int256 answer,
      uint256 startedAt,
      uint256 updatedAt,
      uint80 ansIn
    ) = phaseAggregators[phaseId].getRoundData(aggregatorRoundId);

    return addPhaseIds(roundId, answer, startedAt, updatedAt, ansIn, phaseId);
  }

  function latestRoundData()
    public
    view
    virtual
    override
    returns (
      uint80 roundId,
      int256 answer,
      uint256 startedAt,
      uint256 updatedAt,
      uint80 answeredInRound
    )
  {

    Phase memory current = currentPhase; // cache storage reads

    (
      uint80 roundId,
      int256 answer,
      uint256 startedAt,
      uint256 updatedAt,
      uint80 ansIn
    ) = current.aggregator.latestRoundData();

    return addPhaseIds(roundId, answer, startedAt, updatedAt, ansIn, current.id);
  }

  function proposedGetRoundData(uint80 _roundId)
    public
    view
    virtual
    hasProposal()
    returns (
      uint80 roundId,
      int256 answer,
      uint256 startedAt,
      uint256 updatedAt,
      uint80 answeredInRound
    )
  {

    return proposedAggregator.getRoundData(_roundId);
  }

  function proposedLatestRoundData()
    public
    view
    virtual
    hasProposal()
    returns (
      uint80 roundId,
      int256 answer,
      uint256 startedAt,
      uint256 updatedAt,
      uint80 answeredInRound
    )
  {

    return proposedAggregator.latestRoundData();
  }

  function aggregator()
    external
    view
    returns (address)
  {

    return address(currentPhase.aggregator);
  }

  function phaseId()
    external
    view
    returns (uint16)
  {

    return currentPhase.id;
  }

  function decimals()
    external
    view
    override
    returns (uint8)
  {

    return currentPhase.aggregator.decimals();
  }

  function version()
    external
    view
    override
    returns (uint256)
  {

    return currentPhase.aggregator.version();
  }

  function description()
    external
    view
    override
    returns (string memory)
  {

    return currentPhase.aggregator.description();
  }

  function proposeAggregator(address _aggregator)
    external
    onlyOwner()
  {

    proposedAggregator = AggregatorV3Interface(_aggregator);
  }

  function confirmAggregator(address _aggregator)
    external
    onlyOwner()
  {

    require(_aggregator == address(proposedAggregator), "Invalid proposed aggregator");
    delete proposedAggregator;
    setAggregator(_aggregator);
  }



  function setAggregator(address _aggregator)
    internal
  {

    uint16 id = currentPhase.id + 1;
    currentPhase = Phase(id, AggregatorV3Interface(_aggregator));
    phaseAggregators[id] = AggregatorV3Interface(_aggregator);
  }

  function addPhase(
    uint16 _phase,
    uint64 _originalId
  )
    internal
    view
    returns (uint80)
  {

    return uint80(uint256(_phase) << PHASE_OFFSET | _originalId);
  }

  function parseIds(
    uint256 _roundId
  )
    internal
    view
    returns (uint16, uint64)
  {

    uint16 phaseId = uint16(_roundId >> PHASE_OFFSET);
    uint64 aggregatorRoundId = uint64(_roundId);

    return (phaseId, aggregatorRoundId);
  }

  function tryLatestRoundData()
    internal
    view
    returns (uint80, int256, uint256, uint256, uint80)
  {

    Phase memory current = currentPhase; // cache storage reads

    try current.aggregator.latestRoundData() returns (
      uint80 roundId,
      int256 answer,
      uint256 startedAt,
      uint256 updatedAt,
      uint80 ansIn
    ) {
      return addPhaseIds(roundId, answer, startedAt, updatedAt, ansIn, current.id);
    } catch Error(string memory reason) {
      return handleExpectedV3Error(reason);
    }
  }

  function tryGetRoundData(
    uint256 _roundId
  )
    internal
    view
    returns (uint80, int256, uint256, uint256, uint80)
  {

    (uint16 phaseId, uint64 aggregatorRoundId) = parseIds(_roundId);
    AggregatorV3Interface aggregator = phaseAggregators[phaseId];

    try aggregator.getRoundData(uint80(aggregatorRoundId)) returns (
      uint80 roundId,
      int256 answer,
      uint256 startedAt,
      uint256 updatedAt,
      uint80 ansIn
    ) {
      return addPhaseIds(roundId, answer, startedAt, updatedAt, ansIn, phaseId);
    } catch Error(string memory reason) {
      return handleExpectedV3Error(reason);
    }
  }

  function handleExpectedV3Error(
    string memory reason
  )
    internal
    view
    returns (uint80, int256, uint256, uint256, uint80)
  {

    require(keccak256(bytes(reason)) == EXPECTED_V3_ERROR, reason);

    return (0, 0, 0, 0, 0);
  }

  function addPhaseIds(
      uint80 roundId,
      int256 answer,
      uint256 startedAt,
      uint256 updatedAt,
      uint80 answeredInRound,
      uint16 phaseId
  )
    internal
    view
    returns (uint80, int256, uint256, uint256, uint80)
  {

    return (
      addPhase(phaseId, uint64(roundId)),
      answer,
      startedAt,
      updatedAt,
      addPhase(phaseId, uint64(answeredInRound))
    );
  }


  modifier hasProposal() {

    require(address(proposedAggregator) != address(0), "No proposed aggregator present");
    _;
  }

}

interface AccessControllerInterface {

  function hasAccess(address user, bytes calldata data) external view returns (bool);

}

contract EACAggregatorProxy is AggregatorProxy {


  AccessControllerInterface public accessController;

  constructor(
    address _aggregator,
    address _accessController
  )
    public
    AggregatorProxy(_aggregator)
  {
    setController(_accessController);
  }

  function setController(address _accessController)
    public
    onlyOwner()
  {

    accessController = AccessControllerInterface(_accessController);
  }

  function latestAnswer()
    public
    view
    override
    checkAccess()
    returns (int256)
  {

    return super.latestAnswer();
  }

  function latestTimestamp()
    public
    view
    override
    checkAccess()
    returns (uint256)
  {

    return super.latestTimestamp();
  }

  function getAnswer(uint256 _roundId)
    public
    view
    override
    checkAccess()
    returns (int256)
  {

    return super.getAnswer(_roundId);
  }

  function getTimestamp(uint256 _roundId)
    public
    view
    override
    checkAccess()
    returns (uint256)
  {

    return super.getTimestamp(_roundId);
  }

  function latestRound()
    public
    view
    override
    checkAccess()
    returns (uint256)
  {

    return super.latestRound();
  }

  function getRoundData(uint80 _roundId)
    public
    view
    checkAccess()
    override
    returns (
      uint80 roundId,
      int256 answer,
      uint256 startedAt,
      uint256 updatedAt,
      uint80 answeredInRound
    )
  {

    return super.getRoundData(_roundId);
  }

  function latestRoundData()
    public
    view
    checkAccess()
    override
    returns (
      uint80 roundId,
      int256 answer,
      uint256 startedAt,
      uint256 updatedAt,
      uint80 answeredInRound
    )
  {

    return super.latestRoundData();
  }

  function proposedGetRoundData(uint80 _roundId)
    public
    view
    checkAccess()
    hasProposal()
    override
    returns (
      uint80 roundId,
      int256 answer,
      uint256 startedAt,
      uint256 updatedAt,
      uint80 answeredInRound
    )
  {

    return super.proposedGetRoundData(_roundId);
  }

  function proposedLatestRoundData()
    public
    view
    checkAccess()
    hasProposal()
    override
    returns (
      uint80 roundId,
      int256 answer,
      uint256 startedAt,
      uint256 updatedAt,
      uint80 answeredInRound
    )
  {

    return super.proposedLatestRoundData();
  }

  modifier checkAccess() {

    AccessControllerInterface ac = accessController;
    require(address(ac) == address(0) || ac.hasAccess(msg.sender, msg.data), "No access");
    _;
  }
}