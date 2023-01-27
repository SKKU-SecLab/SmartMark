
pragma solidity ^0.8.0;

interface AggregatorValidatorInterface {

  function validate(
    uint256 previousRoundId,
    int256 previousAnswer,
    uint256 currentRoundId,
    int256 currentAnswer
  )
    external
    returns (
      bool
    );

}

contract ConfirmedOwner {


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

  constructor(address newOwner) {
    s_owner = newOwner;
  }

  function transferOwnership(
    address to
  )
    external
    onlyOwner()
  {

    require(to != msg.sender, "Cannot transfer to self");

    s_pendingOwner = to;

    emit OwnershipTransferRequested(s_owner, to);
  }

  function acceptOwnership()
    external
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
    returns (
      address
    )
  {

    return s_owner;
  }

  modifier onlyOwner() {

    require(msg.sender == s_owner, "Only callable by owner");
    _;
  }

}

contract ValidatorProxy is AggregatorValidatorInterface, ConfirmedOwner {


  struct ProxyConfiguration {
    address target;
    bool hasNewProposal;
  }

  ProxyConfiguration private s_currentAggregator;
  address private s_proposedAggregator;

  ProxyConfiguration private s_currentValidator;
  address private s_proposedValidator;

  event AggregatorProposed(
    address indexed aggregator
  );
  event AggregatorUpgraded(
    address indexed previous,
    address indexed current
  );
  event ValidatorProposed(
    address indexed validator
  );
  event ValidatorUpgraded(
    address indexed previous,
    address indexed current
  );
  event ProposedAggregatorValidateCall(
    address indexed proposed,
    uint256 previousRoundId,
    int256 previousAnswer,
    uint256 currentRoundId,
    int256 currentAnswer
  );

  constructor(
    address aggregator,
    address validator
  )
    ConfirmedOwner(msg.sender)
  {
    s_currentAggregator.target = aggregator;
    s_currentValidator.target = validator;
  }

  function validate(
    uint256 previousRoundId,
    int256 previousAnswer,
    uint256 currentRoundId,
    int256 currentAnswer
  )
    external
    override
    returns (
      bool
    )
  {

    address currentAggregator = s_currentAggregator.target;
    address proposedAggregator = s_proposedAggregator;
    require(msg.sender == currentAggregator || msg.sender == proposedAggregator, "Not a configured aggregator");
    if (msg.sender == proposedAggregator) {
      emit ProposedAggregatorValidateCall(
        proposedAggregator,
        previousRoundId,
        previousAnswer,
        currentRoundId,
        currentAnswer
      );
      return true;
    }

    ProxyConfiguration memory currentValidator = s_currentValidator;
    require(s_currentValidator.target != address(0), "No validator set");
    AggregatorValidatorInterface(currentValidator.target).validate(
      previousRoundId,
      previousAnswer,
      currentRoundId,
      currentAnswer
    );
    if (currentValidator.hasNewProposal) {
      AggregatorValidatorInterface(s_proposedValidator).validate(
        previousRoundId,
        previousAnswer,
        currentRoundId,
        currentAnswer
      );
    }
    return true;
  }


  function proposeNewAggregator(
    address proposed
  )
    external
    onlyOwner()
  {

    s_proposedAggregator = proposed;
    s_currentAggregator.hasNewProposal = (proposed != address(0));
    emit AggregatorProposed(proposed);
  }

  function upgradeAggregator()
    external
    onlyOwner()
  {

    ProxyConfiguration memory current = s_currentAggregator;
    address previous = current.target;
    address proposed = s_proposedAggregator;

    require(current.hasNewProposal == true, "No proposal");
    current.target = proposed;
    current.hasNewProposal = false;

    s_currentAggregator = current;
    s_proposedAggregator = address(0);

    emit AggregatorUpgraded(previous, proposed);
  }

  function getAggregators()
    external
    view
    returns(
      address current,
      bool hasProposal,
      address proposed
    )
  {

    current = s_currentAggregator.target;
    hasProposal = s_currentAggregator.hasNewProposal;
    proposed = s_proposedAggregator;
  }


  function proposeNewValidator(
    address proposed
  )
    external
    onlyOwner()
  {

    s_proposedValidator = proposed;
    s_currentValidator.hasNewProposal = (proposed != address(0));
    emit ValidatorProposed(proposed);
  }

  function upgradeValidator()
    external
    onlyOwner()
  {

    ProxyConfiguration memory current = s_currentValidator;
    address previous = current.target;
    address proposed = s_proposedValidator;

    require(current.hasNewProposal == true, "No proposal");
    current.target = proposed;
    current.hasNewProposal = false;

    s_currentValidator = current;
    s_proposedValidator = address(0);

    emit ValidatorUpgraded(previous, proposed);
  }

  function getValidators()
    external
    view
    returns(
      address current,
      bool hasProposal,
      address proposed
    )
  {

    current = s_currentValidator.target;
    hasProposal = s_currentValidator.hasNewProposal;
    proposed = s_proposedValidator;
  }

}