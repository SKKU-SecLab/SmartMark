pragma solidity ^0.7.0;

interface OwnableInterface {

  function owner()
    external
    returns (
      address
    );


  function transferOwnership(
    address recipient
  )
    external;


  function acceptOwnership()
    external;

}// MIT
pragma solidity ^0.7.0;


contract ConfirmedOwnerWithProposal is OwnableInterface {


  address private s_owner;
  address private s_pendingOwner;

  event OwnershipTransferRequested(
    address indexed from,
    address indexed to
  );
  event OwnershipTransferred(
    address indexed from,
    address indexed to
  );

  constructor(
    address owner,
    address pendingOwner
  ) {
    require(owner != address(0), "Cannot set owner to zero");

    s_owner = owner;
    if (pendingOwner != address(0)) {
      _transferOwnership(pendingOwner);
    }
  }

  function transferOwnership(
    address to
  )
    public
    override
    onlyOwner()
  {

    _transferOwnership(to);
  }

  function acceptOwnership()
    external
    override
  {

    require(msg.sender == s_pendingOwner, "Must be proposed owner");

    address oldOwner = s_owner;
    s_owner = msg.sender;
    s_pendingOwner = address(0);

    emit OwnershipTransferred(oldOwner, msg.sender);
  }

  function owner()
    public
    view
    override
    returns (
      address
    )
  {

    return s_owner;
  }

  function _transferOwnership(
    address to
  )
    private
  {

    require(to != msg.sender, "Cannot transfer to self");

    s_pendingOwner = to;

    emit OwnershipTransferRequested(s_owner, to);
  }

  function _validateOwnership()
    internal
    view
  {

    require(msg.sender == s_owner, "Only callable by owner");
  }

  modifier onlyOwner() {

    _validateOwnership();
    _;
  }

}// MIT
pragma solidity ^0.7.0;


contract ConfirmedOwner is ConfirmedOwnerWithProposal {


  constructor(
    address newOwner
  )
    ConfirmedOwnerWithProposal(
      newOwner,
      address(0)
    )
  {
  }

}// MIT
pragma solidity ^0.7.0;

interface AccessControllerInterface {

  function hasAccess(address user, bytes calldata data) external view returns (bool);

}// MIT
pragma solidity 0.7.6;


interface AccessControlledInterface {

  event AccessControllerSet(
    address indexed accessController,
    address indexed sender
  );

  function setAccessController(
    AccessControllerInterface _accessController
  )
    external;


  function getAccessController()
    external
    view
    returns (
      AccessControllerInterface
    );

}// MIT
pragma solidity 0.7.6;


contract AccessControlled is AccessControlledInterface, ConfirmedOwner(msg.sender) {

  AccessControllerInterface internal s_accessController;

  function setAccessController(
    AccessControllerInterface _accessController
  )
    public
    override
    onlyOwner()
  {

    require(address(_accessController) != address(s_accessController), "Access controller is already set");
    s_accessController = _accessController;
    emit AccessControllerSet(address(_accessController), msg.sender);
  }

  function getAccessController()
    public
    view
    override
    returns (
      AccessControllerInterface
    )
  {

    return s_accessController;
  }
}// MIT
pragma solidity ^0.7.0;

interface AggregatorInterface {

  function latestAnswer()
    external
    view
    returns (
      int256
    );

  
  function latestTimestamp()
    external
    view
    returns (
      uint256
    );


  function latestRound()
    external
    view
    returns (
      uint256
    );


  function getAnswer(
    uint256 roundId
  )
    external
    view
    returns (
      int256
    );


  function getTimestamp(
    uint256 roundId
  )
    external
    view
    returns (
      uint256
    );


  event AnswerUpdated(
    int256 indexed current,
    uint256 indexed roundId,
    uint256 updatedAt
  );

  event NewRound(
    uint256 indexed roundId,
    address indexed startedBy,
    uint256 startedAt
  );
}// MIT
pragma solidity ^0.7.0;

interface AggregatorV3Interface {


  function decimals()
    external
    view
    returns (
      uint8
    );


  function description()
    external
    view
    returns (
      string memory
    );


  function version()
    external
    view
    returns (
      uint256
    );


  function getRoundData(
    uint80 _roundId
  )
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


}// MIT
pragma solidity ^0.7.0;


interface AggregatorV2V3Interface is AggregatorInterface, AggregatorV3Interface
{

}// MIT
pragma solidity 0.7.6;
pragma abicoder v2; // solhint-disable compiler-version


interface FeedRegistryInterface {

  struct Phase {
    uint16 phaseId;
    uint80 startingAggregatorRoundId;
    uint80 endingAggregatorRoundId;
  }

  event FeedProposed(
    address indexed asset,
    address indexed denomination,
    address indexed proposedAggregator,
    address currentAggregator,
    address sender
  );
  event FeedConfirmed(
    address indexed asset,
    address indexed denomination,
    address indexed latestAggregator,
    address previousAggregator,
    uint16 nextPhaseId,
    address sender
  );


  function decimals(
    address base,
    address quote
  )
    external
    view
    returns (
      uint8
    );


  function description(
    address base,
    address quote
  )
    external
    view
    returns (
      string memory
    );


  function version(
    address base,
    address quote
  )
    external
    view
    returns (
      uint256
    );


  function latestRoundData(
    address base,
    address quote
  )
    external
    view
    returns (
      uint80 roundId,
      int256 answer,
      uint256 startedAt,
      uint256 updatedAt,
      uint80 answeredInRound
    );


  function getRoundData(
    address base,
    address quote,
    uint80 _roundId
  )
    external
    view
    returns (
      uint80 roundId,
      int256 answer,
      uint256 startedAt,
      uint256 updatedAt,
      uint80 answeredInRound
    );



  function latestAnswer(
    address base,
    address quote
  )
    external
    view
    returns (
      int256 answer
    );


  function latestTimestamp(
    address base,
    address quote
  )
    external
    view
    returns (
      uint256 timestamp
    );


  function latestRound(
    address base,
    address quote
  )
    external
    view
    returns (
      uint256 roundId
    );


  function getAnswer(
    address base,
    address quote,
    uint256 roundId
  )
    external
    view
    returns (
      int256 answer
    );


  function getTimestamp(
    address base,
    address quote,
    uint256 roundId
  )
    external
    view
    returns (
      uint256 timestamp
    );



  function getFeed(
    address base,
    address quote
  )
    external
    view
    returns (
      AggregatorV2V3Interface aggregator
    );


  function getPhaseFeed(
    address base,
    address quote,
    uint16 phaseId
  )
    external
    view
    returns (
      AggregatorV2V3Interface aggregator
    );


  function isFeedEnabled(
    address aggregator
  )
    external
    view
    returns (
      bool
    );


  function getPhase(
    address base,
    address quote,
    uint16 phaseId
  )
    external
    view
    returns (
      Phase memory phase
    );



  function getRoundFeed(
    address base,
    address quote,
    uint80 roundId
  )
    external
    view
    returns (
      AggregatorV2V3Interface aggregator
    );


  function getPhaseRange(
    address base,
    address quote,
    uint16 phaseId
  )
    external
    view
    returns (
      uint80 startingRoundId,
      uint80 endingRoundId
    );


  function getPreviousRoundId(
    address base,
    address quote,
    uint80 roundId
  ) external
    view
    returns (
      uint80 previousRoundId
    );


  function getNextRoundId(
    address base,
    address quote,
    uint80 roundId
  ) external
    view
    returns (
      uint80 nextRoundId
    );



  function proposeFeed(
    address base,
    address quote,
    address aggregator
  ) external;


  function confirmFeed(
    address base,
    address quote,
    address aggregator
  ) external;



  function getProposedFeed(
    address base,
    address quote
  )
    external
    view
    returns (
      AggregatorV2V3Interface proposedAggregator
    );


  function proposedGetRoundData(
    address base,
    address quote,
    uint80 roundId
  )
    external
    view
    returns (
      uint80 id,
      int256 answer,
      uint256 startedAt,
      uint256 updatedAt,
      uint80 answeredInRound
    );


  function proposedLatestRoundData(
    address base,
    address quote
  )
    external
    view
    returns (
      uint80 id,
      int256 answer,
      uint256 startedAt,
      uint256 updatedAt,
      uint80 answeredInRound
    );


  function getCurrentPhaseId(
    address base,
    address quote
  )
    external
    view
    returns (
      uint16 currentPhaseId
    );

}// MIT
pragma solidity ^0.7.0;

interface TypeAndVersionInterface{

  function typeAndVersion()
    external
    pure
    returns (
      string memory
    );

}// MIT

pragma solidity 0.7.6;


contract FeedRegistry is FeedRegistryInterface, TypeAndVersionInterface, AccessControlled {

  uint256 constant private PHASE_OFFSET = 64;
  uint256 constant private PHASE_SIZE = 16;
  uint256 constant private MAX_ID = 2**(PHASE_OFFSET+PHASE_SIZE) - 1;

  mapping(address => bool) private s_isAggregatorEnabled;
  mapping(address => mapping(address => AggregatorV2V3Interface)) private s_proposedAggregators;
  mapping(address => mapping(address => uint16)) private s_currentPhaseId;
  mapping(address => mapping(address => mapping(uint16 => AggregatorV2V3Interface))) private s_phaseAggregators;
  mapping(address => mapping(address => mapping(uint16 => Phase))) private s_phases;

  function typeAndVersion()
    external
    override
    pure
    virtual
    returns (
      string memory
    )
  {

    return "FeedRegistry 1.0.0";
  }

  function decimals(
    address base,
    address quote
  )
    external
    view
    override
    returns (
      uint8
    )
  {

    AggregatorV2V3Interface aggregator = _getFeed(base, quote);
    require(address(aggregator) != address(0), "Feed not found");
    return aggregator.decimals();
  }

  function description(
    address base,
    address quote
  )
    external
    view
    override
    returns (
      string memory
    )
  {

    AggregatorV2V3Interface aggregator = _getFeed(base, quote);
    require(address(aggregator) != address(0), "Feed not found");
    return aggregator.description();
  }

  function version(
    address base,
    address quote
  )
    external
    view
    override
    returns (
      uint256
    )
  {

    AggregatorV2V3Interface aggregator = _getFeed(base, quote);
    require(address(aggregator) != address(0), "Feed not found");
    return aggregator.version();
  }

  function latestRoundData(
    address base,
    address quote
  )
    external
    view
    override
    checkPairAccess()
    returns (
      uint80 roundId,
      int256 answer,
      uint256 startedAt,
      uint256 updatedAt,
      uint80 answeredInRound
    )
  {

    uint16 currentPhaseId = s_currentPhaseId[base][quote];
    AggregatorV2V3Interface aggregator = _getFeed(base, quote);
    require(address(aggregator) != address(0), "Feed not found");
    (
      roundId,
      answer,
      startedAt,
      updatedAt,
      answeredInRound
    ) = aggregator.latestRoundData();
    return _addPhaseIds(roundId, answer, startedAt, updatedAt, answeredInRound, currentPhaseId);
  }

  function getRoundData(
    address base,
    address quote,
    uint80 _roundId
  )
    external
    view
    override
    checkPairAccess()
    returns (
      uint80 roundId,
      int256 answer,
      uint256 startedAt,
      uint256 updatedAt,
      uint80 answeredInRound
    )
  {

    (uint16 phaseId, uint64 aggregatorRoundId) = _parseIds(_roundId);
    AggregatorV2V3Interface aggregator = _getPhaseFeed(base, quote, phaseId);
    require(address(aggregator) != address(0), "Feed not found");
    (
      roundId,
      answer,
      startedAt,
      updatedAt,
      answeredInRound
    ) = aggregator.getRoundData(aggregatorRoundId);
    return _addPhaseIds(roundId, answer, startedAt, updatedAt, answeredInRound, phaseId);
  }


  function latestAnswer(
    address base,
    address quote
  )
    external
    view
    override
    checkPairAccess()
    returns (
      int256 answer
    )
  {

    AggregatorV2V3Interface aggregator = _getFeed(base, quote);
    require(address(aggregator) != address(0), "Feed not found");
    return aggregator.latestAnswer();
  }

  function latestTimestamp(
    address base,
    address quote
  )
    external
    view
    override
    checkPairAccess()
    returns (
      uint256 timestamp
    )
  {

    AggregatorV2V3Interface aggregator = _getFeed(base, quote);
    require(address(aggregator) != address(0), "Feed not found");
    return aggregator.latestTimestamp();
  }

  function latestRound(
    address base,
    address quote
  )
    external
    view
    override
    checkPairAccess()
    returns (
      uint256 roundId
    )
  {

    uint16 currentPhaseId = s_currentPhaseId[base][quote];
    AggregatorV2V3Interface aggregator = _getFeed(base, quote);
    require(address(aggregator) != address(0), "Feed not found");
    return _addPhase(currentPhaseId, uint64(aggregator.latestRound()));
  }

  function getAnswer(
    address base,
    address quote,
    uint256 roundId
  )
    external
    view
    override
    checkPairAccess()
    returns (
      int256 answer
    )
  {

    if (roundId > MAX_ID) return 0;
    (uint16 phaseId, uint64 aggregatorRoundId) = _parseIds(roundId);
    AggregatorV2V3Interface aggregator = _getPhaseFeed(base, quote, phaseId);
    if (address(aggregator) == address(0)) return 0;
    return aggregator.getAnswer(aggregatorRoundId);
  }

  function getTimestamp(
    address base,
    address quote,
    uint256 roundId
  )
    external
    view
    override
    checkPairAccess()
    returns (
      uint256 timestamp
    )
  {

    if (roundId > MAX_ID) return 0;
    (uint16 phaseId, uint64 aggregatorRoundId) = _parseIds(roundId);
    AggregatorV2V3Interface aggregator = _getPhaseFeed(base, quote, phaseId);
    if (address(aggregator) == address(0)) return 0;
    return aggregator.getTimestamp(aggregatorRoundId);
  }


  function getFeed(
    address base,
    address quote
  )
    external
    view
    override
    returns (
      AggregatorV2V3Interface aggregator
    )
  {

    aggregator = _getFeed(base, quote);
    require(address(aggregator) != address(0), "Feed not found");
  }

  function getPhaseFeed(
    address base,
    address quote,
    uint16 phaseId
  )
    external
    view
    override
    returns (
      AggregatorV2V3Interface aggregator
    )
  {

    aggregator = _getPhaseFeed(base, quote, phaseId);
    require(address(aggregator) != address(0), "Feed not found for phase");
  }

  function isFeedEnabled(
    address aggregator
  )
    external
    view
    override
    returns (
      bool
    )
  {

    return s_isAggregatorEnabled[aggregator];
  }

  function getPhase(
    address base,
    address quote,
    uint16 phaseId
  )
    external
    view
    override
    returns (
      Phase memory phase
    )
  {

    phase = _getPhase(base, quote, phaseId);
    require(_phaseExists(phase), "Phase does not exist");
  }

  function getRoundFeed(
    address base,
    address quote,
    uint80 roundId
  )
    external
    view
    override
    returns (
      AggregatorV2V3Interface aggregator
    )
  {

    uint16 phaseId = _getPhaseIdByRoundId(base, quote, roundId);
    aggregator = _getPhaseFeed(base, quote, phaseId);
    require(address(aggregator) != address(0), "Feed not found for round");
  }

  function getPhaseRange(
    address base,
    address quote,
    uint16 phaseId
  )
    external
    view
    override
    returns (
      uint80 startingRoundId,
      uint80 endingRoundId
    )
  {

    Phase memory phase = _getPhase(base, quote, phaseId);
    require(_phaseExists(phase), "Phase does not exist");

    uint16 currentPhaseId = s_currentPhaseId[base][quote];
    if (phaseId == currentPhaseId) return _getLatestRoundRange(base, quote, currentPhaseId);
    return _getPhaseRange(base, quote, phaseId);
  }

  function getPreviousRoundId(
    address base,
    address quote,
    uint80 roundId
  ) external
    view
    override
    returns (
      uint80 previousRoundId
    )
  {

    uint16 phaseId = _getPhaseIdByRoundId(base, quote, roundId);
    return _getPreviousRoundId(base, quote, phaseId, roundId);
  }

  function getNextRoundId(
    address base,
    address quote,
    uint80 roundId
  ) external
    view
    override
    returns (
      uint80 nextRoundId
    )
  {

    uint16 phaseId = _getPhaseIdByRoundId(base, quote, roundId);
    return _getNextRoundId(base, quote, phaseId, roundId);
  }

  function proposeFeed(
    address base,
    address quote,
    address aggregator
  )
    external
    override
    onlyOwner()
  {

    AggregatorV2V3Interface currentPhaseAggregator = _getFeed(base, quote);
    require(aggregator != address(currentPhaseAggregator), "Cannot propose current aggregator");
    address proposedAggregator = address(_getProposedFeed(base, quote));
    if (proposedAggregator != aggregator) {
      s_proposedAggregators[base][quote] = AggregatorV2V3Interface(aggregator);
      emit FeedProposed(base, quote, aggregator, address(currentPhaseAggregator), msg.sender);
    }
  }

  function confirmFeed(
    address base,
    address quote,
    address aggregator
  )
    external
    override
    onlyOwner()
  {

    (uint16 nextPhaseId, address previousAggregator) = _setFeed(base, quote, aggregator);
    delete s_proposedAggregators[base][quote];
    s_isAggregatorEnabled[aggregator] = true;
    s_isAggregatorEnabled[previousAggregator] = false;
    emit FeedConfirmed(base, quote, aggregator, previousAggregator, nextPhaseId, msg.sender);
  }

  function getProposedFeed(
    address base,
    address quote
  )
    external
    view
    override
    returns (
      AggregatorV2V3Interface proposedAggregator
    )
  {

    return _getProposedFeed(base, quote);
  }

  function proposedGetRoundData(
    address base,
    address quote,
    uint80 roundId
  )
    external
    view
    virtual
    override
    hasProposal(base, quote)
    returns (
      uint80 id,
      int256 answer,
      uint256 startedAt,
      uint256 updatedAt,
      uint80 answeredInRound
    )
  {

    return s_proposedAggregators[base][quote].getRoundData(roundId);
  }

  function proposedLatestRoundData(
    address base,
    address quote
  )
    external
    view
    virtual
    override
    hasProposal(base, quote)
    returns (
      uint80 id,
      int256 answer,
      uint256 startedAt,
      uint256 updatedAt,
      uint80 answeredInRound
    )
  {

    return s_proposedAggregators[base][quote].latestRoundData();
  }

  function getCurrentPhaseId(
    address base,
    address quote
  )
    external
    view
    override
    returns (
      uint16 currentPhaseId
    )
  {

    return s_currentPhaseId[base][quote];
  }

  function _addPhase(
    uint16 phase,
    uint64 roundId
  )
    internal
    pure
    returns (
      uint80
    )
  {

    return uint80(uint256(phase) << PHASE_OFFSET | roundId);
  }

  function _parseIds(
    uint256 roundId
  )
    internal
    pure
    returns (
      uint16,
      uint64
    )
  {

    uint16 phaseId = uint16(roundId >> PHASE_OFFSET);
    uint64 aggregatorRoundId = uint64(roundId);

    return (phaseId, aggregatorRoundId);
  }

  function _addPhaseIds(
      uint80 roundId,
      int256 answer,
      uint256 startedAt,
      uint256 updatedAt,
      uint80 answeredInRound,
      uint16 phaseId
  )
    internal
    pure
    returns (
      uint80,
      int256,
      uint256,
      uint256,
      uint80
    )
  {

    return (
      _addPhase(phaseId, uint64(roundId)),
      answer,
      startedAt,
      updatedAt,
      _addPhase(phaseId, uint64(answeredInRound))
    );
  }

  function _getPhase(
    address base,
    address quote,
    uint16 phaseId
  )
    internal
    view
    returns (
      Phase memory phase
    )
  {

    return s_phases[base][quote][phaseId];
  }

  function _phaseExists(
    Phase memory phase
  )
    internal
    pure
    returns (
      bool
    )
  {

    return phase.phaseId > 0;
  }

  function _getProposedFeed(
    address base,
    address quote
  )
    internal
    view
    returns (
      AggregatorV2V3Interface proposedAggregator
    )
  {

    return s_proposedAggregators[base][quote];
  }

  function _getPhaseFeed(
    address base,
    address quote,
    uint16 phaseId
  )
    internal
    view
    returns (
      AggregatorV2V3Interface aggregator
    )
  {

    return s_phaseAggregators[base][quote][phaseId];
  }

  function _getFeed(
    address base,
    address quote
  )
    internal
    view
    returns (
      AggregatorV2V3Interface aggregator
    )
  {

    uint16 currentPhaseId = s_currentPhaseId[base][quote];
    return _getPhaseFeed(base, quote, currentPhaseId);
  }

  function _setFeed(
    address base,
    address quote,
    address newAggregator
  )
    internal
    returns (
      uint16 nextPhaseId,
      address previousAggregator
    )
  {

    require(newAggregator == address(s_proposedAggregators[base][quote]), "Invalid proposed aggregator");
    AggregatorV2V3Interface currentAggregator = _getFeed(base, quote);
    uint80 previousAggregatorEndingRoundId = _getLatestAggregatorRoundId(currentAggregator);
    uint16 currentPhaseId = s_currentPhaseId[base][quote];
    s_phases[base][quote][currentPhaseId].endingAggregatorRoundId = previousAggregatorEndingRoundId;

    nextPhaseId = currentPhaseId + 1;
    s_currentPhaseId[base][quote] = nextPhaseId;
    s_phaseAggregators[base][quote][nextPhaseId] = AggregatorV2V3Interface(newAggregator);
    uint80 startingRoundId = _getLatestAggregatorRoundId(AggregatorV2V3Interface(newAggregator));
    s_phases[base][quote][nextPhaseId] = Phase(nextPhaseId, startingRoundId, 0);

    return (nextPhaseId, address(currentAggregator));
  }

  function _getPreviousRoundId(
    address base,
    address quote,
    uint16 phaseId,
    uint80 roundId
  )
    internal
    view
    returns (
      uint80
    )
  {

    for (uint16 pid = phaseId; pid > 0; pid--) {
      AggregatorV2V3Interface phaseAggregator = _getPhaseFeed(base, quote, pid);
      (uint80 startingRoundId, uint80 endingRoundId) = _getPhaseRange(base, quote, pid);
      if (address(phaseAggregator) == address(0)) continue;
      if (roundId <= startingRoundId) continue;
      if (roundId > startingRoundId && roundId <= endingRoundId) return roundId - 1;
      if (roundId > endingRoundId) return endingRoundId;
    }
    return 0; // Round not found
  }

  function _getNextRoundId(
    address base,
    address quote,
    uint16 phaseId,
    uint80 roundId
  )
    internal
    view
    returns (
      uint80
    )
  {

    uint16 currentPhaseId = s_currentPhaseId[base][quote];
    for (uint16 pid = phaseId; pid <= currentPhaseId; pid++) {
      AggregatorV2V3Interface phaseAggregator = _getPhaseFeed(base, quote, pid);
      (uint80 startingRoundId, uint80 endingRoundId) =
        (pid == currentPhaseId) ? _getLatestRoundRange(base, quote, pid) : _getPhaseRange(base, quote, pid);
      if (address(phaseAggregator) == address(0)) continue;
      if (roundId >= endingRoundId) continue;
      if (roundId >= startingRoundId && roundId < endingRoundId) return roundId + 1;
      if (roundId < startingRoundId) return startingRoundId;
    }
    return 0; // Round not found
  }

  function _getPhaseRange(
    address base,
    address quote,
    uint16 phaseId
  )
    internal
    view
    returns (
      uint80 startingRoundId,
      uint80 endingRoundId
    )
  {

    Phase memory phase = _getPhase(base, quote, phaseId);
    return (
      _getStartingRoundId(phaseId, phase),
      _getEndingRoundId(phaseId, phase)
    );
  }

  function _getLatestRoundRange(
    address base,
    address quote,
    uint16 currentPhaseId
  )
    internal
    view
    returns (
      uint80 startingRoundId,
      uint80 endingRoundId
    )
  {

    Phase memory phase = s_phases[base][quote][currentPhaseId];
    return (
      _getStartingRoundId(currentPhaseId, phase),
      _getLatestRoundId(base, quote, currentPhaseId)
    );
  }

  function _getStartingRoundId(
    uint16 phaseId,
    Phase memory phase
  )
    internal
    pure
    returns (
      uint80 startingRoundId
    )
  {

    return _addPhase(phaseId, uint64(phase.startingAggregatorRoundId));
  }

  function _getEndingRoundId(
    uint16 phaseId,
    Phase memory phase
  )
    internal
    pure
    returns (
      uint80 startingRoundId
    )
  {

    return _addPhase(phaseId, uint64(phase.endingAggregatorRoundId));
  }

  function _getLatestRoundId(
    address base,
    address quote,
    uint16 phaseId
  )
    internal
    view
    returns (
      uint80 startingRoundId
    )
  {

    AggregatorV2V3Interface currentPhaseAggregator = _getFeed(base, quote);
    uint80 latestAggregatorRoundId = _getLatestAggregatorRoundId(currentPhaseAggregator);
    return _addPhase(phaseId, uint64(latestAggregatorRoundId));
  }

  function _getLatestAggregatorRoundId(
    AggregatorV2V3Interface aggregator
  )
    internal
    view
    returns (
      uint80 roundId
    )
  {

    if (address(aggregator) == address(0)) return uint80(0);
    return uint80(aggregator.latestRound());
  }

  function _getPhaseIdByRoundId(
    address base,
    address quote,
    uint80 roundId
  )
    internal
    view
    returns (
      uint16 phaseId
    )
  {

    uint16 currentPhaseId = s_currentPhaseId[base][quote];
    (uint80 startingCurrentRoundId, uint80 endingCurrentRoundId) = _getLatestRoundRange(base, quote, currentPhaseId);
    if (roundId >= startingCurrentRoundId && roundId <= endingCurrentRoundId) return currentPhaseId;

    require(currentPhaseId > 0, "Invalid phase");
    for (uint16 pid = currentPhaseId - 1; pid > 0; pid--) {
      AggregatorV2V3Interface phaseAggregator = s_phaseAggregators[base][quote][pid];
      if (address(phaseAggregator) == address(0)) continue;
      (uint80 startingRoundId, uint80 endingRoundId) = _getPhaseRange(base, quote, pid);
      if (roundId >= startingRoundId && roundId <= endingRoundId) return pid;
      if (roundId > endingRoundId) break;
    }
    return 0;
  }

  modifier checkPairAccess() {

    require(address(s_accessController) == address(0) || s_accessController.hasAccess(msg.sender, msg.data), "No access");
    _;
  }

  modifier hasProposal(
    address base,
    address quote
  ) {

    require(address(s_proposedAggregators[base][quote]) != address(0), "No proposed aggregator present");
    _;
  }
}// MIT
pragma solidity ^0.7.0;


contract MockConsumer {

  FeedRegistryInterface private s_FeedRegistry;

  constructor(
    FeedRegistryInterface FeedRegistry
  ) {
    s_FeedRegistry = FeedRegistry;
  }

  function getFeedRegistry()
    public
    view
    returns (
      FeedRegistryInterface
    )
  {

    return s_FeedRegistry;
  }

  function read(
    address base,
    address quote
  )
    public
    view
    returns (
      int256
    )
  {

    return s_FeedRegistry.latestAnswer(base, quote);
  }
}// MIT
pragma solidity ^0.7.0;


interface AggregatorProxyInterface is AggregatorV2V3Interface {

  
	function phaseAggregators(
    uint16 phaseId
  )
    external
    view
    returns (
      address
    );


	function phaseId()
    external
    view
    returns (
      uint16
    );


	function proposedAggregator()
    external
    view
    returns (
      address
    );


	function proposedGetRoundData(
    uint80 roundId
  )
    external
    view
    returns (
      uint80 id,
      int256 answer,
      uint256 startedAt,
      uint256 updatedAt,
      uint80 answeredInRound
    );


	function proposedLatestRoundData()
    external
    view
    returns (
      uint80 id,
      int256 answer,
      uint256 startedAt,
      uint256 updatedAt,
      uint80 answeredInRound
    );


	function aggregator()
    external
    view
    returns (
      address
    );

}// MIT
pragma solidity ^0.7.0;


contract AggregatorProxy is AggregatorProxyInterface, ConfirmedOwner {


  struct Phase {
    uint16 id;
    AggregatorProxyInterface aggregator;
  }
  AggregatorProxyInterface private s_proposedAggregator;
  mapping(uint16 => AggregatorProxyInterface) private s_phaseAggregators;
  Phase private s_currentPhase;
  
  uint256 constant private PHASE_OFFSET = 64;
  uint256 constant private PHASE_SIZE = 16;
  uint256 constant private MAX_ID = 2**(PHASE_OFFSET+PHASE_SIZE) - 1;

  event AggregatorProposed(
    address indexed current,
    address indexed proposed
  );
  event AggregatorConfirmed(
    address indexed previous,
    address indexed latest
  );

  constructor(
    address aggregatorAddress
  )
    ConfirmedOwner(msg.sender)
  {
    setAggregator(aggregatorAddress);
  }

  function latestAnswer()
    public
    view
    virtual
    override
    returns (
      int256 answer
    )
  {

    return s_currentPhase.aggregator.latestAnswer();
  }

  function latestTimestamp()
    public
    view
    virtual
    override
    returns (
      uint256 updatedAt
    )
  {

    return s_currentPhase.aggregator.latestTimestamp();
  }

  function getAnswer(
    uint256 roundId
  )
    public
    view
    virtual
    override
    returns (
      int256 answer
    )
  {

    if (roundId > MAX_ID) return 0;

    (uint16 phaseId, uint64 aggregatorRoundId) = parseIds(roundId);
    AggregatorProxyInterface aggregator = s_phaseAggregators[phaseId];
    if (address(aggregator) == address(0)) return 0;

    return aggregator.getAnswer(aggregatorRoundId);
  }

  function getTimestamp(
    uint256 roundId
  )
    public
    view
    virtual
    override
    returns (
      uint256 updatedAt
    )
  {

    if (roundId > MAX_ID) return 0;

    (uint16 phaseId, uint64 aggregatorRoundId) = parseIds(roundId);
    AggregatorProxyInterface aggregator = s_phaseAggregators[phaseId];
    if (address(aggregator) == address(0)) return 0;

    return aggregator.getTimestamp(aggregatorRoundId);
  }

  function latestRound()
    public
    view
    virtual
    override
    returns (
      uint256 roundId
    )
  {

    Phase memory phase = s_currentPhase; // cache storage reads
    return addPhase(phase.id, uint64(phase.aggregator.latestRound()));
  }

  function getRoundData(
    uint80 roundId
  )
    public
    view
    virtual
    override
    returns (
      uint80 id,
      int256 answer,
      uint256 startedAt,
      uint256 updatedAt,
      uint80 answeredInRound
    )
  {

    (uint16 phaseId, uint64 aggregatorRoundId) = parseIds(roundId);

    (
      id,
      answer,
      startedAt,
      updatedAt,
      answeredInRound
    ) = s_phaseAggregators[phaseId].getRoundData(aggregatorRoundId);

    return addPhaseIds(id, answer, startedAt, updatedAt, answeredInRound, phaseId);
  }

  function latestRoundData()
    public
    view
    virtual
    override
    returns (
      uint80 id,
      int256 answer,
      uint256 startedAt,
      uint256 updatedAt,
      uint80 answeredInRound
    )
  {

    Phase memory current = s_currentPhase; // cache storage reads

    (
      id,
      answer,
      startedAt,
      updatedAt,
      answeredInRound
    ) = current.aggregator.latestRoundData();

    return addPhaseIds(id, answer, startedAt, updatedAt, answeredInRound, current.id);
  }

  function proposedGetRoundData(
    uint80 roundId
  )
    external
    view
    virtual
    override
    hasProposal()
    returns (
      uint80 id,
      int256 answer,
      uint256 startedAt,
      uint256 updatedAt,
      uint80 answeredInRound
    )
  {

    return s_proposedAggregator.getRoundData(roundId);
  }

  function proposedLatestRoundData()
    external
    view
    virtual
    override
    hasProposal()
    returns (
      uint80 id,
      int256 answer,
      uint256 startedAt,
      uint256 updatedAt,
      uint80 answeredInRound
    )
  {

    return s_proposedAggregator.latestRoundData();
  }

  function aggregator()
    external
    view
    override
    returns (
      address
    )
  {

    return address(s_currentPhase.aggregator);
  }

  function phaseId()
    external
    view
    override
    returns (
      uint16
    )
  {

    return s_currentPhase.id;
  }

  function decimals()
    external
    view
    override
    returns (
      uint8
    )
  {

    return s_currentPhase.aggregator.decimals();
  }

  function version()
    external
    view
    override
    returns (
      uint256
    )
  {

    return s_currentPhase.aggregator.version();
  }

  function description()
    external
    view
    override
    returns (
      string memory
    )
  {

    return s_currentPhase.aggregator.description();
  }

  function proposedAggregator()
    external
    view
    override
    returns (
      address
    )
  {

    return address(s_proposedAggregator);
  }

  function phaseAggregators(
    uint16 phaseId
  )
    external
    view
    override
    returns (
      address
    )
  {

    return address(s_phaseAggregators[phaseId]);
  }

  function proposeAggregator(
    address aggregatorAddress
  )
    external
    onlyOwner()
  {

    s_proposedAggregator = AggregatorProxyInterface(aggregatorAddress);
    emit AggregatorProposed(address(s_currentPhase.aggregator), aggregatorAddress);
  }

  function confirmAggregator(
    address aggregatorAddress
  )
    external
    onlyOwner()
  {

    require(aggregatorAddress == address(s_proposedAggregator), "Invalid proposed aggregator");
    address previousAggregator = address(s_currentPhase.aggregator);
    delete s_proposedAggregator;
    setAggregator(aggregatorAddress);
    emit AggregatorConfirmed(previousAggregator, aggregatorAddress);
  }



  function setAggregator(
    address aggregatorAddress
  )
    internal
  {

    uint16 id = s_currentPhase.id + 1;
    s_currentPhase = Phase(id, AggregatorProxyInterface(aggregatorAddress));
    s_phaseAggregators[id] = AggregatorProxyInterface(aggregatorAddress);
  }

  function addPhase(
    uint16 phase,
    uint64 originalId
  )
    internal
    pure
    returns (
      uint80
    )
  {

    return uint80(uint256(phase) << PHASE_OFFSET | originalId);
  }

  function parseIds(
    uint256 roundId
  )
    internal
    pure
    returns (
      uint16,
      uint64
    )
  {

    uint16 phaseId = uint16(roundId >> PHASE_OFFSET);
    uint64 aggregatorRoundId = uint64(roundId);

    return (phaseId, aggregatorRoundId);
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
    pure
    returns (
      uint80,
      int256,
      uint256,
      uint256,
      uint80
    )
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

    require(address(s_proposedAggregator) != address(0), "No proposed aggregator present");
    _;
  }

}// MIT
pragma solidity 0.7.6;


contract WriteAccessController is AccessControllerInterface, ConfirmedOwner(msg.sender) {

  bool private s_checkEnabled = true;
  mapping(address => bool) internal s_globalAccessList;
  mapping(address => mapping(bytes => bool)) internal s_localAccessList;

  event AccessAdded(address user, bytes data, address sender);
  event AccessRemoved(address user, bytes data, address sender);
  event CheckAccessEnabled();
  event CheckAccessDisabled();

  function checkEnabled()
    public
    view
    returns (
      bool
    )
  {

    return s_checkEnabled;
  }

  function hasAccess(
    address user,
    bytes memory data
  )
    public
    view
    virtual
    override
    returns (bool)
  {

    return !s_checkEnabled || s_globalAccessList[user] || s_localAccessList[user][data];
  }

  function addGlobalAccess(
    address user
  )
    external
    onlyOwner()
  {

    _addGlobalAccess(user);
  }

  function addLocalAccess(
    address user,
    bytes memory data
  )
    external
    onlyOwner()
  {

    _addLocalAccess(user, data);
  }

  function removeGlobalAccess(
    address user
  )
    external
    onlyOwner()
  {

    _removeGlobalAccess(user);
  }

  function removeLocalAccess(
    address user,
    bytes memory data
  )
    external
    onlyOwner()
  {

    _removeLocalAccess(user, data);
  }

  function enableAccessCheck()
    external
    onlyOwner()
  {

    _enableAccessCheck();
  }

  function disableAccessCheck()
    external
    onlyOwner()
  {

    _disableAccessCheck();
  }

  modifier checkAccess() {

    if (s_checkEnabled) {
      require(hasAccess(msg.sender, msg.data), "No access");
    }
    _;
  }

  function _enableAccessCheck() internal {

    if (!s_checkEnabled) {
      s_checkEnabled = true;
      emit CheckAccessEnabled();
    }
  }

  function _disableAccessCheck() internal {

    if (s_checkEnabled) {
      s_checkEnabled = false;
      emit CheckAccessDisabled();
    }
  }

  function _addGlobalAccess(address user) internal {

    if (!s_globalAccessList[user]) {
      s_globalAccessList[user] = true;
      emit AccessAdded(user, "", msg.sender);
    }
  }

  function _removeGlobalAccess(address user) internal {

    if (s_globalAccessList[user]) {
      s_globalAccessList[user] = false;
      emit AccessRemoved(user, "", msg.sender);
    }
  }

  function _addLocalAccess(address user, bytes memory data) internal {

    if (!s_localAccessList[user][data]) {
      s_localAccessList[user][data] = true;
      emit AccessAdded(user, data, msg.sender);
    }
  }

  function _removeLocalAccess(address user, bytes memory data) internal {

    if (s_localAccessList[user][data]) {
      s_localAccessList[user][data] = false;
      emit AccessRemoved(user, data, msg.sender);
    }
  }
}// MIT

pragma solidity 0.7.6;

abstract contract EOAContext {
  function _isEOA(address account) internal view virtual returns (bool) {
      return account == tx.origin; // solhint-disable-line avoid-tx-origin
  }
}// MIT
pragma solidity 0.7.6;


contract ReadAccessController is WriteAccessController, EOAContext {

  function hasAccess(
    address account,
    bytes memory data
  )
    public
    view
    virtual
    override
    returns (bool)
  {

    return super.hasAccess(account, data) || _isEOA(account);
  }
}// MIT
pragma solidity 0.7.6;


contract PairReadAccessController is WriteAccessController, EOAContext {

  function hasAccess(
    address account,
    bytes calldata data
  )
    public
    view
    virtual
    override
    returns (bool)
  {

    (
      address base,
      address quote
    ) = abi.decode(data[4:], (address, address));
    bytes memory pairData = abi.encode(base, quote); // Check access to pair (TKN / ETH)
    return super.hasAccess(account, pairData) || _isEOA(account);
  }
}// MIT
pragma solidity ^0.7.0;


contract MockAggregatorProxy is AggregatorProxy {

    constructor(
        address aggregatorAddress
    ) AggregatorProxy(aggregatorAddress) {} // solhint-disable-line
}