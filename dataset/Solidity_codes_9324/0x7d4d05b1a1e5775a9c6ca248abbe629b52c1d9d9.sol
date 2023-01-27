pragma solidity 0.7.6;
pragma abicoder v2;

interface IWithdrawHandler {

  function handleWithdrawal(address staker, uint256 reduceAmount) external;

}// agpl-3.0
pragma solidity 0.7.6;


interface IVotingPowerStrategy is IWithdrawHandler {

  function handleProposalCreation(
    uint256 proposalId,
    uint256 startTime,
    uint256 endTime
  ) external;


  function handleProposalCancellation(uint256 proposalId) external;


  function handleVote(
    address voter,
    uint256 proposalId,
    uint256 choice
  ) external returns (uint256 votingPower);


  function getVotingPower(address voter, uint256 timestamp)
    external
    view
    returns (uint256 votingPower);


  function validateProposalCreation(uint256 startTime, uint256 endTime)
    external
    view
    returns (bool);


  function getMaxVotingPower() external view returns (uint256);

}// agpl-3.0
pragma solidity 0.7.6;


interface IKyberGovernance {

  enum ProposalState {
    Pending,
    Canceled,
    Active,
    Failed,
    Succeeded,
    Queued,
    Expired,
    Executed,
    Finalized
  }
  enum ProposalType {Generic, Binary}

  struct Vote {
    uint32 optionBitMask;
    uint224 votingPower;
  }

  struct ProposalWithoutVote {
    uint256 id;
    ProposalType proposalType;
    address creator;
    IExecutorWithTimelock executor;
    IVotingPowerStrategy strategy;
    address[] targets;
    uint256[] weiValues;
    string[] signatures;
    bytes[] calldatas;
    bool[] withDelegatecalls;
    string[] options;
    uint256[] voteCounts;
    uint256 totalVotes;
    uint256 maxVotingPower;
    uint256 startTime;
    uint256 endTime;
    uint256 executionTime;
    string link;
    bool executed;
    bool canceled;
  }

  struct Proposal {
    ProposalWithoutVote proposalData;
    mapping(address => Vote) votes;
  }

  struct BinaryProposalParams {
    address[] targets;
    uint256[] weiValues;
    string[] signatures;
    bytes[] calldatas;
    bool[] withDelegatecalls;
  }

  event BinaryProposalCreated(
    uint256 proposalId,
    address indexed creator,
    IExecutorWithTimelock indexed executor,
    IVotingPowerStrategy indexed strategy,
    address[] targets,
    uint256[] weiValues,
    string[] signatures,
    bytes[] calldatas,
    bool[] withDelegatecalls,
    uint256 startTime,
    uint256 endTime,
    string link,
    uint256 maxVotingPower
  );

  event GenericProposalCreated(
    uint256 proposalId,
    address indexed creator,
    IExecutorWithTimelock indexed executor,
    IVotingPowerStrategy indexed strategy,
    string[] options,
    uint256 startTime,
    uint256 endTime,
    string link,
    uint256 maxVotingPower
  );

  event ProposalCanceled(uint256 proposalId);

  event ProposalQueued(
    uint256 indexed proposalId,
    uint256 executionTime,
    address indexed initiatorQueueing
  );
  event ProposalExecuted(uint256 proposalId, address indexed initiatorExecution);
  event VoteEmitted(
    uint256 indexed proposalId,
    address indexed voter,
    uint32 indexed voteOptions,
    uint224 votingPower
  );

  event VotingPowerChanged(
    uint256 indexed proposalId,
    address indexed voter,
    uint32 indexed voteOptions,
    uint224 oldVotingPower,
    uint224 newVotingPower
  );

  event DaoOperatorTransferred(address indexed newDaoOperator);

  event ExecutorAuthorized(address indexed executor);

  event ExecutorUnauthorized(address indexed executor);

  event VotingPowerStrategyAuthorized(address indexed strategy);

  event VotingPowerStrategyUnauthorized(address indexed strategy);

  function handleVotingPowerChanged(
    address staker,
    uint256 newVotingPower,
    uint256[] calldata proposalIds
  ) external;


  function createBinaryProposal(
    IExecutorWithTimelock executor,
    IVotingPowerStrategy strategy,
    BinaryProposalParams memory executionParams,
    uint256 startTime,
    uint256 endTime,
    string memory link
  ) external returns (uint256 proposalId);


  function createGenericProposal(
    IExecutorWithTimelock executor,
    IVotingPowerStrategy strategy,
    string[] memory options,
    uint256 startTime,
    uint256 endTime,
    string memory link
  ) external returns (uint256 proposalId);


  function cancel(uint256 proposalId) external;


  function queue(uint256 proposalId) external;


  function execute(uint256 proposalId) external payable;


  function submitVote(uint256 proposalId, uint256 optionBitMask) external;


  function submitVoteBySignature(
    uint256 proposalId,
    uint256 choice,
    uint8 v,
    bytes32 r,
    bytes32 s
  ) external;


  function authorizeExecutors(address[] calldata executors) external;


  function unauthorizeExecutors(address[] calldata executors) external;


  function authorizeVotingPowerStrategies(address[] calldata strategies) external;


  function unauthorizeVotingPowerStrategies(address[] calldata strategies) external;


  function isExecutorAuthorized(address executor) external view returns (bool);


  function isVotingPowerStrategyAuthorized(address strategy) external view returns (bool);


  function getDaoOperator() external view returns (address);


  function getProposalsCount() external view returns (uint256);


  function getProposalById(uint256 proposalId) external view returns (ProposalWithoutVote memory);


  function getProposalVoteDataById(uint256 proposalId)
    external
    view
    returns (
      uint256,
      uint256[] memory,
      string[] memory
    );


  function getVoteOnProposal(uint256 proposalId, address voter)
    external
    view
    returns (Vote memory);


  function getProposalState(uint256 proposalId) external view returns (ProposalState);

}// agpl-3.0
pragma solidity 0.7.6;


interface IExecutorWithTimelock {

  event NewPendingAdmin(address newPendingAdmin);

  event NewAdmin(address newAdmin);

  event NewDelay(uint256 delay);

  event QueuedAction(
    bytes32 actionHash,
    address indexed target,
    uint256 value,
    string signature,
    bytes data,
    uint256 executionTime,
    bool withDelegatecall
  );

  event CancelledAction(
    bytes32 actionHash,
    address indexed target,
    uint256 value,
    string signature,
    bytes data,
    uint256 executionTime,
    bool withDelegatecall
  );

  event ExecutedAction(
    bytes32 actionHash,
    address indexed target,
    uint256 value,
    string signature,
    bytes data,
    uint256 executionTime,
    bool withDelegatecall,
    bytes resultData
  );

  function queueTransaction(
    address target,
    uint256 value,
    string memory signature,
    bytes memory data,
    uint256 executionTime,
    bool withDelegatecall
  ) external returns (bytes32);


  function executeTransaction(
    address target,
    uint256 value,
    string memory signature,
    bytes memory data,
    uint256 executionTime,
    bool withDelegatecall
  ) external payable returns (bytes memory);


  function cancelTransaction(
    address target,
    uint256 value,
    string memory signature,
    bytes memory data,
    uint256 executionTime,
    bool withDelegatecall
  ) external returns (bytes32);


  function getAdmin() external view returns (address);


  function getPendingAdmin() external view returns (address);


  function getDelay() external view returns (uint256);


  function isActionQueued(bytes32 actionHash) external view returns (bool);


  function isProposalOverGracePeriod(IKyberGovernance governance, uint256 proposalId)
    external
    view
    returns (bool);


  function GRACE_PERIOD() external view returns (uint256);


  function MINIMUM_DELAY() external view returns (uint256);


  function MAXIMUM_DELAY() external view returns (uint256);

}// MIT

pragma solidity ^0.7.0;

library SafeMath {

    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        uint256 c = a + b;
        if (c < a) return (false, 0);
        return (true, c);
    }

    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        if (b > a) return (false, 0);
        return (true, a - b);
    }

    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        if (a == 0) return (true, 0);
        uint256 c = a * b;
        if (c / a != b) return (false, 0);
        return (true, c);
    }

    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        if (b == 0) return (false, 0);
        return (true, a / b);
    }

    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        if (b == 0) return (false, 0);
        return (true, a % b);
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {

        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");
        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b <= a, "SafeMath: subtraction overflow");
        return a - b;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {

        if (a == 0) return 0;
        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");
        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b > 0, "SafeMath: division by zero");
        return a / b;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b > 0, "SafeMath: modulo by zero");
        return a % b;
    }

    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        require(b <= a, errorMessage);
        return a - b;
    }

    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        require(b > 0, errorMessage);
        return a / b;
    }

    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        require(b > 0, errorMessage);
        return a % b;
    }
}// agpl-3.0
pragma solidity 0.7.6;


contract DefaultExecutorWithTimelock is IExecutorWithTimelock {

  using SafeMath for uint256;

  uint256 public immutable override GRACE_PERIOD;
  uint256 public immutable override MINIMUM_DELAY;
  uint256 public immutable override MAXIMUM_DELAY;

  address private _admin;
  address private _pendingAdmin;
  uint256 private _delay;

  mapping(bytes32 => bool) private _queuedTransactions;

  constructor(
    address admin,
    uint256 delay,
    uint256 gracePeriod,
    uint256 minimumDelay,
    uint256 maximumDelay
  ) {
    require(delay >= minimumDelay, 'DELAY_SHORTER_THAN_MINIMUM');
    require(delay <= maximumDelay, 'DELAY_LONGER_THAN_MAXIMUM');
    _delay = delay;
    _admin = admin;

    GRACE_PERIOD = gracePeriod;
    MINIMUM_DELAY = minimumDelay;
    MAXIMUM_DELAY = maximumDelay;

    emit NewDelay(delay);
    emit NewAdmin(admin);
  }

  modifier onlyAdmin() {

    require(msg.sender == _admin, 'ONLY_BY_ADMIN');
    _;
  }

  modifier onlyTimelock() {

    require(msg.sender == address(this), 'ONLY_BY_THIS_TIMELOCK');
    _;
  }

  modifier onlyPendingAdmin() {

    require(msg.sender == _pendingAdmin, 'ONLY_BY_PENDING_ADMIN');
    _;
  }

  function setDelay(uint256 delay) public onlyTimelock {

    _validateDelay(delay);
    _delay = delay;

    emit NewDelay(delay);
  }

  function acceptAdmin() public onlyPendingAdmin {

    _admin = msg.sender;
    _pendingAdmin = address(0);

    emit NewAdmin(msg.sender);
  }

  function setPendingAdmin(address newPendingAdmin) public onlyTimelock {

    _pendingAdmin = newPendingAdmin;

    emit NewPendingAdmin(newPendingAdmin);
  }

  function queueTransaction(
    address target,
    uint256 value,
    string memory signature,
    bytes memory data,
    uint256 executionTime,
    bool withDelegatecall
  ) public override onlyAdmin returns (bytes32) {

    require(executionTime >= block.timestamp.add(_delay), 'EXECUTION_TIME_UNDERESTIMATED');

    bytes32 actionHash = keccak256(
      abi.encode(target, value, signature, data, executionTime, withDelegatecall)
    );
    _queuedTransactions[actionHash] = true;

    emit QueuedAction(actionHash, target, value, signature, data, executionTime, withDelegatecall);
    return actionHash;
  }

  function cancelTransaction(
    address target,
    uint256 value,
    string memory signature,
    bytes memory data,
    uint256 executionTime,
    bool withDelegatecall
  ) public override onlyAdmin returns (bytes32) {

    bytes32 actionHash = keccak256(
      abi.encode(target, value, signature, data, executionTime, withDelegatecall)
    );
    _queuedTransactions[actionHash] = false;

    emit CancelledAction(
      actionHash,
      target,
      value,
      signature,
      data,
      executionTime,
      withDelegatecall
    );
    return actionHash;
  }

  function executeTransaction(
    address target,
    uint256 value,
    string memory signature,
    bytes memory data,
    uint256 executionTime,
    bool withDelegatecall
  ) public override payable onlyAdmin returns (bytes memory) {

    bytes32 actionHash = keccak256(
      abi.encode(target, value, signature, data, executionTime, withDelegatecall)
    );
    require(_queuedTransactions[actionHash], 'ACTION_NOT_QUEUED');
    require(block.timestamp >= executionTime, 'TIMELOCK_NOT_FINISHED');
    require(block.timestamp <= executionTime.add(GRACE_PERIOD), 'GRACE_PERIOD_FINISHED');

    _queuedTransactions[actionHash] = false;

    bytes memory callData;

    if (bytes(signature).length == 0) {
      callData = data;
    } else {
      callData = abi.encodePacked(bytes4(keccak256(bytes(signature))), data);
    }

    bool success;
    bytes memory resultData;
    if (withDelegatecall) {
      require(msg.value >= value, 'NOT_ENOUGH_MSG_VALUE');
      (success, resultData) = target.delegatecall(callData);
    } else {
      (success, resultData) = target.call{value: value}(callData);
    }

    require(success, 'FAILED_ACTION_EXECUTION');

    emit ExecutedAction(
      actionHash,
      target,
      value,
      signature,
      data,
      executionTime,
      withDelegatecall,
      resultData
    );

    return resultData;
  }

  function getAdmin() external override view returns (address) {

    return _admin;
  }

  function getPendingAdmin() external override view returns (address) {

    return _pendingAdmin;
  }

  function getDelay() external override view returns (uint256) {

    return _delay;
  }

  function isActionQueued(bytes32 actionHash) external override view returns (bool) {

    return _queuedTransactions[actionHash];
  }

  function isProposalOverGracePeriod(IKyberGovernance governance, uint256 proposalId)
    external
    override
    view
    returns (bool)
  {

    IKyberGovernance.ProposalWithoutVote memory proposal = governance.getProposalById(proposalId);

    return (block.timestamp > proposal.executionTime.add(GRACE_PERIOD));
  }

  function _validateDelay(uint256 delay) internal view {

    require(delay >= MINIMUM_DELAY, 'DELAY_SHORTER_THAN_MINIMUM');
    require(delay <= MAXIMUM_DELAY, 'DELAY_LONGER_THAN_MAXIMUM');
  }

  receive() external payable {}
}// agpl-3.0
pragma solidity 0.7.6;


interface IProposalValidator {

  function validateBinaryProposalCreation(
    IVotingPowerStrategy strategy,
    address creator,
    uint256 startTime,
    uint256 endTime,
    address daoOperator
  ) external view returns (bool);


  function validateGenericProposalCreation(
    IVotingPowerStrategy strategy,
    address creator,
    uint256 startTime,
    uint256 endTime,
    string[] calldata options,
    address daoOperator
  ) external view returns (bool);


  function validateProposalCancellation(
    IKyberGovernance governance,
    uint256 proposalId,
    address user
  ) external view returns (bool);


  function isBinaryProposalPassed(IKyberGovernance governance, uint256 proposalId)
    external
    view
    returns (bool);


  function isQuorumValid(IKyberGovernance governance, uint256 proposalId)
    external
    view
    returns (bool);


  function isVoteDifferentialValid(IKyberGovernance governance, uint256 proposalId)
    external
    view
    returns (bool);


  function MAX_VOTING_OPTIONS() external view returns (uint256);


  function MIN_VOTING_DURATION() external view returns (uint256);


  function VOTE_DIFFERENTIAL() external view returns (uint256);


  function MINIMUM_QUORUM() external view returns (uint256);

}// MIT

pragma solidity ^0.7.0;

interface IERC20 {

    function totalSupply() external view returns (uint256);


    function balanceOf(address account) external view returns (uint256);


    function transfer(address recipient, uint256 amount) external returns (bool);


    function allowance(address owner, address spender) external view returns (uint256);


    function approve(address spender, uint256 amount) external returns (bool);


    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);


    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}// MIT
pragma solidity 0.7.6;



interface IERC20Ext is IERC20 {

    function decimals() external view returns (uint8 digits);

}// MIT
pragma solidity 0.7.6;



abstract contract Utils {
    IERC20Ext internal constant ETH_TOKEN_ADDRESS = IERC20Ext(
        0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE
    );
    IERC20Ext internal constant USDT_TOKEN_ADDRESS = IERC20Ext(
        0xdAC17F958D2ee523a2206206994597C13D831ec7
    );
    IERC20Ext internal constant DAI_TOKEN_ADDRESS = IERC20Ext(
        0x6B175474E89094C44Da98b954EedeAC495271d0F
    );
    IERC20Ext internal constant USDC_TOKEN_ADDRESS = IERC20Ext(
        0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48
    );
    IERC20Ext internal constant WBTC_TOKEN_ADDRESS = IERC20Ext(
        0x2260FAC5E5542a773Aa44fBCfeDf7C193bc2C599
    );
    IERC20Ext internal constant KNC_TOKEN_ADDRESS = IERC20Ext(
        0xdd974D5C2e2928deA5F71b9825b8b646686BD200
    );
    uint256 public constant BPS = 10000; // Basic Price Steps. 1 step = 0.01%
    uint256 internal constant PRECISION = (10**18);
    uint256 internal constant MAX_QTY = (10**28); // 10B tokens
    uint256 internal constant MAX_RATE = (PRECISION * 10**7); // up to 10M tokens per eth
    uint256 internal constant MAX_DECIMALS = 18;
    uint256 internal constant ETH_DECIMALS = 18;
    uint256 internal constant MAX_ALLOWANCE = uint256(-1); // token.approve inifinite

    mapping(IERC20Ext => uint256) internal decimals;

    function getSetDecimals(IERC20Ext token) internal returns (uint256 tokenDecimals) {
        tokenDecimals = getDecimalsConstant(token);
        if (tokenDecimals > 0) return tokenDecimals;

        tokenDecimals = decimals[token];
        if (tokenDecimals == 0) {
            tokenDecimals = token.decimals();
            decimals[token] = tokenDecimals;
        }
    }

    function getBalance(IERC20Ext token, address user) internal view returns (uint256) {
        if (token == ETH_TOKEN_ADDRESS) {
            return user.balance;
        } else {
            return token.balanceOf(user);
        }
    }

    function getDecimals(IERC20Ext token) internal view returns (uint256 tokenDecimals) {
        tokenDecimals = getDecimalsConstant(token);
        if (tokenDecimals > 0) return tokenDecimals;

        tokenDecimals = decimals[token];
        return (tokenDecimals > 0) ? tokenDecimals : token.decimals();
    }

    function calcDestAmount(
        IERC20Ext src,
        IERC20Ext dest,
        uint256 srcAmount,
        uint256 rate
    ) internal view returns (uint256) {
        return calcDstQty(srcAmount, getDecimals(src), getDecimals(dest), rate);
    }

    function calcSrcAmount(
        IERC20Ext src,
        IERC20Ext dest,
        uint256 destAmount,
        uint256 rate
    ) internal view returns (uint256) {
        return calcSrcQty(destAmount, getDecimals(src), getDecimals(dest), rate);
    }

    function calcDstQty(
        uint256 srcQty,
        uint256 srcDecimals,
        uint256 dstDecimals,
        uint256 rate
    ) internal pure returns (uint256) {
        require(srcQty <= MAX_QTY, "srcQty > MAX_QTY");
        require(rate <= MAX_RATE, "rate > MAX_RATE");

        if (dstDecimals >= srcDecimals) {
            require((dstDecimals - srcDecimals) <= MAX_DECIMALS, "dst - src > MAX_DECIMALS");
            return (srcQty * rate * (10**(dstDecimals - srcDecimals))) / PRECISION;
        } else {
            require((srcDecimals - dstDecimals) <= MAX_DECIMALS, "src - dst > MAX_DECIMALS");
            return (srcQty * rate) / (PRECISION * (10**(srcDecimals - dstDecimals)));
        }
    }

    function calcSrcQty(
        uint256 dstQty,
        uint256 srcDecimals,
        uint256 dstDecimals,
        uint256 rate
    ) internal pure returns (uint256) {
        require(dstQty <= MAX_QTY, "dstQty > MAX_QTY");
        require(rate <= MAX_RATE, "rate > MAX_RATE");

        uint256 numerator;
        uint256 denominator;
        if (srcDecimals >= dstDecimals) {
            require((srcDecimals - dstDecimals) <= MAX_DECIMALS, "src - dst > MAX_DECIMALS");
            numerator = (PRECISION * dstQty * (10**(srcDecimals - dstDecimals)));
            denominator = rate;
        } else {
            require((dstDecimals - srcDecimals) <= MAX_DECIMALS, "dst - src > MAX_DECIMALS");
            numerator = (PRECISION * dstQty);
            denominator = (rate * (10**(dstDecimals - srcDecimals)));
        }
        return (numerator + denominator - 1) / denominator; //avoid rounding down errors
    }

    function calcRateFromQty(
        uint256 srcAmount,
        uint256 destAmount,
        uint256 srcDecimals,
        uint256 dstDecimals
    ) internal pure returns (uint256) {
        require(srcAmount <= MAX_QTY, "srcAmount > MAX_QTY");
        require(destAmount <= MAX_QTY, "destAmount > MAX_QTY");

        if (dstDecimals >= srcDecimals) {
            require((dstDecimals - srcDecimals) <= MAX_DECIMALS, "dst - src > MAX_DECIMALS");
            return ((destAmount * PRECISION) / ((10**(dstDecimals - srcDecimals)) * srcAmount));
        } else {
            require((srcDecimals - dstDecimals) <= MAX_DECIMALS, "src - dst > MAX_DECIMALS");
            return ((destAmount * PRECISION * (10**(srcDecimals - dstDecimals))) / srcAmount);
        }
    }

    function getDecimalsConstant(IERC20Ext token) internal pure returns (uint256) {
        if (token == ETH_TOKEN_ADDRESS) {
            return ETH_DECIMALS;
        } else if (token == USDT_TOKEN_ADDRESS) {
            return 6;
        } else if (token == DAI_TOKEN_ADDRESS) {
            return 18;
        } else if (token == USDC_TOKEN_ADDRESS) {
            return 6;
        } else if (token == WBTC_TOKEN_ADDRESS) {
            return 8;
        } else if (token == KNC_TOKEN_ADDRESS) {
            return 18;
        } else {
            return 0;
        }
    }

    function minOf(uint256 x, uint256 y) internal pure returns (uint256) {
        return x > y ? y : x;
    }
}// agpl-3.0
pragma solidity 0.7.6;


contract DefaultProposalValidator is IProposalValidator, Utils {

  using SafeMath for uint256;

  uint256 public immutable override MIN_VOTING_DURATION;
  uint256 public immutable override MAX_VOTING_OPTIONS;
  uint256 public immutable override VOTE_DIFFERENTIAL;
  uint256 public immutable override MINIMUM_QUORUM;

  uint256 public constant YES_INDEX = 0;
  uint256 public constant NO_INDEX = 1;

  constructor(
    uint256 minVotingDuration,
    uint256 maxVotingOptions,
    uint256 voteDifferential,
    uint256 minimumQuorum
  ) {
    MIN_VOTING_DURATION = minVotingDuration;
    MAX_VOTING_OPTIONS = maxVotingOptions;
    VOTE_DIFFERENTIAL = voteDifferential;
    MINIMUM_QUORUM = minimumQuorum;
  }

  function validateProposalCancellation(
    IKyberGovernance governance,
    uint256 proposalId,
    address user
  ) external override pure returns (bool) {

    governance;
    proposalId;
    user;
    return false;
  }

  function validateBinaryProposalCreation(
    IVotingPowerStrategy strategy,
    address creator,
    uint256 startTime,
    uint256 endTime,
    address daoOperator
  ) external override view returns (bool) {

    if (creator != daoOperator) return false;
    if (endTime.sub(startTime) < MIN_VOTING_DURATION) return false;

    return strategy.validateProposalCreation(startTime, endTime);
  }

  function validateGenericProposalCreation(
    IVotingPowerStrategy strategy,
    address creator,
    uint256 startTime,
    uint256 endTime,
    string[] calldata options,
    address daoOperator
  ) external override view returns (bool) {

    if (creator != daoOperator) return false;
    if (endTime.sub(startTime) < MIN_VOTING_DURATION) return false;
    if (options.length <= 1 || options.length > MAX_VOTING_OPTIONS) return false;

    return strategy.validateProposalCreation(startTime, endTime);
  }

  function isBinaryProposalPassed(IKyberGovernance governance, uint256 proposalId)
    public
    override
    view
    returns (bool)
  {

    return (isQuorumValid(governance, proposalId) &&
      isVoteDifferentialValid(governance, proposalId));
  }

  function isQuorumValid(IKyberGovernance governance, uint256 proposalId)
    public
    override
    view
    returns (bool)
  {

    IKyberGovernance.ProposalWithoutVote memory proposal = governance.getProposalById(proposalId);
    if (proposal.proposalType != IKyberGovernance.ProposalType.Binary) return false;
    return isMinimumQuorumReached(proposal.voteCounts[YES_INDEX], proposal.maxVotingPower);
  }

  function isVoteDifferentialValid(IKyberGovernance governance, uint256 proposalId)
    public
    override
    view
    returns (bool)
  {

    IKyberGovernance.ProposalWithoutVote memory proposal = governance.getProposalById(proposalId);
    if (proposal.proposalType != IKyberGovernance.ProposalType.Binary) return false;
    return (proposal.voteCounts[YES_INDEX].mul(BPS).div(proposal.maxVotingPower) >
      proposal.voteCounts[NO_INDEX].mul(BPS).div(proposal.maxVotingPower).add(VOTE_DIFFERENTIAL));
  }

  function isMinimumQuorumReached(uint256 votes, uint256 voteSupply) internal view returns (bool) {

    return votes >= voteSupply.mul(MINIMUM_QUORUM).div(BPS);
  }
}// agpl-3.0
pragma solidity 0.7.6;


contract DefaultExecutor is DefaultExecutorWithTimelock, DefaultProposalValidator {

  constructor(
    address admin,
    uint256 delay,
    uint256 gracePeriod,
    uint256 minimumDelay,
    uint256 maximumDelay,
    uint256 minVoteDuration,
    uint256 maxVotingOptions,
    uint256 voteDifferential,
    uint256 minimumQuorum
  )
    DefaultExecutorWithTimelock(admin, delay, gracePeriod, minimumDelay, maximumDelay)
    DefaultProposalValidator(minVoteDuration, maxVotingOptions, voteDifferential, minimumQuorum)
  {}
}