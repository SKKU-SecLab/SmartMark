
pragma solidity ^0.8.0;

interface IERC165 {

    function supportsInterface(bytes4 interfaceId) external view returns (bool);

}// MIT

pragma solidity ^0.8.0;


abstract contract ERC165 is IERC165 {
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IERC165).interfaceId;
    }
}// MIT
pragma solidity 0.8.6;

enum JBBallotState {
  Active,
  Approved,
  Failed
}// MIT
pragma solidity 0.8.6;


struct JBFundingCycle {
  uint256 number;
  uint256 configuration;
  uint256 basedOn;
  uint256 start;
  uint256 duration;
  uint256 weight;
  uint256 discountRate;
  IJBFundingCycleBallot ballot;
  uint256 metadata;
}// MIT
pragma solidity 0.8.6;


struct JBFundingCycleData {
  uint256 duration;
  uint256 weight;
  uint256 discountRate;
  IJBFundingCycleBallot ballot;
}// MIT
pragma solidity 0.8.6;


interface IJBFundingCycleStore {

  event Configure(
    uint256 indexed configuration,
    uint256 indexed projectId,
    JBFundingCycleData data,
    uint256 metadata,
    uint256 mustStartAtOrAfter,
    address caller
  );

  event Init(uint256 indexed configuration, uint256 indexed projectId, uint256 indexed basedOn);

  function latestConfigurationOf(uint256 _projectId) external view returns (uint256);


  function get(uint256 _projectId, uint256 _configuration)
    external
    view
    returns (JBFundingCycle memory);


  function latestConfiguredOf(uint256 _projectId)
    external
    view
    returns (JBFundingCycle memory fundingCycle, JBBallotState ballotState);


  function queuedOf(uint256 _projectId) external view returns (JBFundingCycle memory fundingCycle);


  function currentOf(uint256 _projectId) external view returns (JBFundingCycle memory fundingCycle);


  function currentBallotStateOf(uint256 _projectId) external view returns (JBBallotState);


  function configureFor(
    uint256 _projectId,
    JBFundingCycleData calldata _data,
    uint256 _metadata,
    uint256 _mustStartAtOrAfter
  ) external returns (JBFundingCycle memory fundingCycle);

}// MIT
pragma solidity 0.8.6;


interface IJBFundingCycleBallot is IERC165 {

  function duration() external view returns (uint256);


  function stateOf(
    uint256 _projectId,
    uint256 _configuration,
    uint256 _start
  ) external view returns (JBBallotState);

}// MIT
pragma solidity 0.8.6;


interface IJBReconfigurationBufferBallot is IJBFundingCycleBallot {

  event Finalize(
    uint256 indexed projectId,
    uint256 indexed configuration,
    JBBallotState indexed ballotState,
    address caller
  );

  function finalState(uint256 _projectId, uint256 _configuration)
    external
    view
    returns (JBBallotState);


  function fundingCycleStore() external view returns (IJBFundingCycleStore);


  function finalize(uint256 _projectId, uint256 _configured) external returns (JBBallotState);

}// MIT
pragma solidity 0.8.6;


contract JBReconfigurationBufferBallot is IJBReconfigurationBufferBallot, ERC165 {


  uint256 public immutable override duration;

  IJBFundingCycleStore public immutable override fundingCycleStore;


  mapping(uint256 => mapping(uint256 => JBBallotState)) public override finalState;


  function stateOf(
    uint256 _projectId,
    uint256 _configured,
    uint256 _start
  ) public view override returns (JBBallotState) {

    if (finalState[_projectId][_configured] != JBBallotState.Active)
      return finalState[_projectId][_configured];

    if (block.timestamp < _configured + duration)
      return (block.timestamp >= _start) ? JBBallotState.Failed : JBBallotState.Active;

    return JBBallotState.Approved;
  }

  function supportsInterface(bytes4 _interfaceId)
    public
    view
    virtual
    override(ERC165, IERC165)
    returns (bool)
  {

    return
      _interfaceId == type(IJBReconfigurationBufferBallot).interfaceId ||
      _interfaceId == type(IJBFundingCycleBallot).interfaceId ||
      super.supportsInterface(_interfaceId);
  }


  constructor(uint256 _duration, IJBFundingCycleStore _fundingCycleStore) {
    duration = _duration;
    fundingCycleStore = _fundingCycleStore;
  }


  function finalize(uint256 _projectId, uint256 _configured)
    external
    override
    returns (JBBallotState ballotState)
  {

    JBFundingCycle memory _fundingCycle = fundingCycleStore.get(_projectId, _configured);

    ballotState = finalState[_projectId][_configured];

    if (ballotState == JBBallotState.Active) {
      ballotState = stateOf(_projectId, _configured, _fundingCycle.start);
      if (ballotState != JBBallotState.Active) {
        finalState[_projectId][_configured] = ballotState;

        emit Finalize(_projectId, _configured, ballotState, msg.sender);
      }
    }
  }
}