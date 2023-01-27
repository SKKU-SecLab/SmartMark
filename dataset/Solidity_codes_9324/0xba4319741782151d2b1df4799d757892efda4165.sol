pragma solidity ^0.8.0;

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

}// MIT
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

}// MIT
pragma solidity ^0.8.0;

abstract contract TypeAndVersionInterface{
  function typeAndVersion()
    external
    pure
    virtual
    returns (
      string memory
    );
}// MIT
pragma solidity ^0.8.0;


contract ValidatorProxy is AggregatorValidatorInterface, TypeAndVersionInterface, ConfirmedOwner {


  struct AggregatorConfiguration {
    address target;
    bool hasNewProposal;
  }

  struct ValidatorConfiguration {
    AggregatorValidatorInterface target;
    bool hasNewProposal;
  }

  AggregatorConfiguration private s_currentAggregator;
  address private s_proposedAggregator;

  ValidatorConfiguration private s_currentValidator;
  AggregatorValidatorInterface private s_proposedValidator;

  event AggregatorProposed(
    address indexed aggregator
  );
  event AggregatorUpgraded(
    address indexed previous,
    address indexed current
  );
  event ValidatorProposed(
    AggregatorValidatorInterface indexed validator
  );
  event ValidatorUpgraded(
    AggregatorValidatorInterface indexed previous,
    AggregatorValidatorInterface indexed current
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
    AggregatorValidatorInterface validator
  )
    ConfirmedOwner(msg.sender)
  {
    s_currentAggregator = AggregatorConfiguration({
      target: aggregator,
      hasNewProposal: false
    });
    s_currentValidator = ValidatorConfiguration({
      target: validator,
      hasNewProposal: false
    });
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
    if (msg.sender != currentAggregator) {
      address proposedAggregator = s_proposedAggregator;
      require(msg.sender == proposedAggregator, "Not a configured aggregator");
      emit ProposedAggregatorValidateCall(
        proposedAggregator,
        previousRoundId,
        previousAnswer,
        currentRoundId,
        currentAnswer
      );
      return true;
    }

    ValidatorConfiguration memory currentValidator = s_currentValidator;
    address currentValidatorAddress = address(currentValidator.target);
    require(currentValidatorAddress != address(0), "No validator set");
    currentValidatorAddress.call(
      abi.encodeWithSelector(
        AggregatorValidatorInterface.validate.selector,
        previousRoundId,
        previousAnswer,
        currentRoundId,
        currentAnswer
      )
    );
    if (currentValidator.hasNewProposal) {
      address(s_proposedValidator).call(
        abi.encodeWithSelector(
          AggregatorValidatorInterface.validate.selector,
          previousRoundId,
          previousAnswer,
          currentRoundId,
          currentAnswer
        )
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

    require(s_proposedAggregator != proposed && s_currentAggregator.target != proposed, "Invalid proposal");
    s_proposedAggregator = proposed;
    s_currentAggregator.hasNewProposal = (proposed != address(0));
    emit AggregatorProposed(proposed);
  }

  function upgradeAggregator()
    external
    onlyOwner()
  {

    AggregatorConfiguration memory current = s_currentAggregator;
    address previous = current.target;
    address proposed = s_proposedAggregator;

    require(current.hasNewProposal, "No proposal");
    s_currentAggregator = AggregatorConfiguration({
      target: proposed,
      hasNewProposal: false
    });
    delete s_proposedAggregator;

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
    AggregatorValidatorInterface proposed
  )
    external
    onlyOwner()
  {

    require(s_proposedValidator != proposed && s_currentValidator.target != proposed, "Invalid proposal");
    s_proposedValidator = proposed;
    s_currentValidator.hasNewProposal = (address(proposed) != address(0));
    emit ValidatorProposed(proposed);
  }

  function upgradeValidator()
    external
    onlyOwner()
  {

    ValidatorConfiguration memory current = s_currentValidator;
    AggregatorValidatorInterface previous = current.target;
    AggregatorValidatorInterface proposed = s_proposedValidator;

    require(current.hasNewProposal, "No proposal");
    s_currentValidator = ValidatorConfiguration({
      target: proposed,
      hasNewProposal: false
    });
    delete s_proposedValidator;

    emit ValidatorUpgraded(previous, proposed);
  }

  function getValidators()
    external
    view
    returns(
      AggregatorValidatorInterface current,
      bool hasProposal,
      AggregatorValidatorInterface proposed
    )
  {

    current = s_currentValidator.target;
    hasProposal = s_currentValidator.hasNewProposal;
    proposed = s_proposedValidator;
  }

  function typeAndVersion()
    external
    pure
    virtual
    override
    returns (
      string memory
    )
  {

    return "ValidatorProxy 1.0.0";
  }

}// MIT
pragma solidity ^0.8.0;


contract MockAggregatorValidator is AggregatorValidatorInterface {

  
  uint8 immutable id;

  constructor(uint8 id_) {
    id = id_;
  }

  event ValidateCalled(
    uint8 id,
    uint256 previousRoundId,
    int256 previousAnswer,
    uint256 currentRoundId,
    int256 currentAnswer
  );
  
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

    emit ValidateCalled(id, previousRoundId, previousAnswer, currentRoundId, currentAnswer);
    return true;
  }

}