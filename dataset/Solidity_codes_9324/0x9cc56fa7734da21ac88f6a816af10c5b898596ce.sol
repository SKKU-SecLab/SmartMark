
pragma solidity ^0.8.0;

abstract contract Initializable {
  bool private _initialized;

  bool private _initializing;

  modifier initializer() {
    require(_initializing || !_initialized, "Initializable: contract is already initialized");

    bool isTopLevelCall = !_initializing;
    if (isTopLevelCall) {
      _initializing = true;
      _initialized = true;
    }

    _;

    if (isTopLevelCall) {
      _initializing = false;
    }
  }
}// ISC

pragma solidity 0.8.4;

interface IControllable {


  function isController(address _contract) external view returns (bool);


  function isGovernance(address _contract) external view returns (bool);


}// ISC

pragma solidity 0.8.4;

interface IControllableExtended {


  function created() external view returns (uint256 ts);


  function controller() external view returns (address adr);


}// ISC

pragma solidity 0.8.4;

interface IController {


  function addVaultsAndStrategies(address[] memory _vaults, address[] memory _strategies) external;


  function addStrategy(address _strategy) external;


  function governance() external view returns (address);


  function dao() external view returns (address);


  function bookkeeper() external view returns (address);


  function feeRewardForwarder() external view returns (address);


  function mintHelper() external view returns (address);


  function rewardToken() external view returns (address);


  function fundToken() external view returns (address);


  function psVault() external view returns (address);


  function fund() external view returns (address);


  function distributor() external view returns (address);


  function announcer() external view returns (address);


  function vaultController() external view returns (address);


  function whiteList(address _target) external view returns (bool);


  function vaults(address _target) external view returns (bool);


  function strategies(address _target) external view returns (bool);


  function psNumerator() external view returns (uint256);


  function psDenominator() external view returns (uint256);


  function fundNumerator() external view returns (uint256);


  function fundDenominator() external view returns (uint256);


  function isAllowedUser(address _adr) external view returns (bool);


  function isDao(address _adr) external view returns (bool);


  function isHardWorker(address _adr) external view returns (bool);


  function isRewardDistributor(address _adr) external view returns (bool);


  function isPoorRewardConsumer(address _adr) external view returns (bool);


  function isValidVault(address _vault) external view returns (bool);


  function isValidStrategy(address _strategy) external view returns (bool);


  function rebalance(address _strategy) external;


  function setPSNumeratorDenominator(uint256 numerator, uint256 denominator) external;


  function setFundNumeratorDenominator(uint256 numerator, uint256 denominator) external;


  function changeWhiteListStatus(address[] calldata _targets, bool status) external;

}// ISC

pragma solidity 0.8.4;


abstract contract ControllableV2 is Initializable, IControllable, IControllableExtended {

  bytes32 internal constant _CONTROLLER_SLOT = bytes32(uint256(keccak256("eip1967.controllable.controller")) - 1);
  bytes32 internal constant _CREATED_SLOT = bytes32(uint256(keccak256("eip1967.controllable.created")) - 1);
  bytes32 internal constant _CREATED_BLOCK_SLOT = bytes32(uint256(keccak256("eip1967.controllable.created_block")) - 1);

  event ContractInitialized(address controller, uint ts, uint block);

  function initializeControllable(address __controller) public initializer {
    _setController(__controller);
    _setCreated(block.timestamp);
    _setCreatedBlock(block.number);
    emit ContractInitialized(__controller, block.timestamp, block.number);
  }

  function isController(address _value) external override view returns (bool) {
    return _isController(_value);
  }

  function _isController(address _value) internal view returns (bool) {
    return _value == _controller();
  }

  function isGovernance(address _value) external override view returns (bool) {
    return _isGovernance(_value);
  }

  function _isGovernance(address _value) internal view returns (bool) {
    return IController(_controller()).governance() == _value;
  }


  function controller() external view override returns (address) {
    return _controller();
  }

  function _controller() internal view returns (address result) {
    bytes32 slot = _CONTROLLER_SLOT;
    assembly {
      result := sload(slot)
    }
  }

  function _setController(address _newController) private {
    require(_newController != address(0));
    bytes32 slot = _CONTROLLER_SLOT;
    assembly {
      sstore(slot, _newController)
    }
  }

  function created() external view override returns (uint256 ts) {
    bytes32 slot = _CREATED_SLOT;
    assembly {
      ts := sload(slot)
    }
  }

  function _setCreated(uint256 _value) private {
    bytes32 slot = _CREATED_SLOT;
    assembly {
      sstore(slot, _value)
    }
  }

  function createdBlock() external view returns (uint256 ts) {
    bytes32 slot = _CREATED_BLOCK_SLOT;
    assembly {
      ts := sload(slot)
    }
  }

  function _setCreatedBlock(uint256 _value) private {
    bytes32 slot = _CREATED_BLOCK_SLOT;
    assembly {
      sstore(slot, _value)
    }
  }

}// MIT

pragma solidity ^0.8.0;

interface IERC20 {

  function totalSupply() external view returns (uint256);


  function balanceOf(address account) external view returns (uint256);


  function transfer(address recipient, uint256 amount) external returns (bool);


  function allowance(address owner, address spender) external view returns (uint256);


  function approve(address spender, uint256 amount) external returns (bool);


  function transferFrom(
    address sender,
    address recipient,
    uint256 amount
  ) external returns (bool);


  event Transfer(address indexed from, address indexed to, uint256 value);

  event Approval(address indexed owner, address indexed spender, uint256 value);
}// MIT

pragma solidity ^0.8.0;

library Address {

  function isContract(address account) internal view returns (bool) {


    uint256 size;
    assembly {
      size := extcodesize(account)
    }
    return size > 0;
  }

  function sendValue(address payable recipient, uint256 amount) internal {

    require(address(this).balance >= amount, "Address: insufficient balance");

    (bool success, ) = recipient.call{value: amount}("");
    require(success, "Address: unable to send value, recipient may have reverted");
  }

  function functionCall(address target, bytes memory data) internal returns (bytes memory) {

    return functionCall(target, data, "Address: low-level call failed");
  }

  function functionCall(
    address target,
    bytes memory data,
    string memory errorMessage
  ) internal returns (bytes memory) {

    return functionCallWithValue(target, data, 0, errorMessage);
  }

  function functionCallWithValue(
    address target,
    bytes memory data,
    uint256 value
  ) internal returns (bytes memory) {

    return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
  }

  function functionCallWithValue(
    address target,
    bytes memory data,
    uint256 value,
    string memory errorMessage
  ) internal returns (bytes memory) {

    require(address(this).balance >= value, "Address: insufficient balance for call");
    require(isContract(target), "Address: call to non-contract");

    (bool success, bytes memory returndata) = target.call{value: value}(data);
    return verifyCallResult(success, returndata, errorMessage);
  }

  function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {

    return functionStaticCall(target, data, "Address: low-level static call failed");
  }

  function functionStaticCall(
    address target,
    bytes memory data,
    string memory errorMessage
  ) internal view returns (bytes memory) {

    require(isContract(target), "Address: static call to non-contract");

    (bool success, bytes memory returndata) = target.staticcall(data);
    return verifyCallResult(success, returndata, errorMessage);
  }

  function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {

    return functionDelegateCall(target, data, "Address: low-level delegate call failed");
  }

  function functionDelegateCall(
    address target,
    bytes memory data,
    string memory errorMessage
  ) internal returns (bytes memory) {

    require(isContract(target), "Address: delegate call to non-contract");

    (bool success, bytes memory returndata) = target.delegatecall(data);
    return verifyCallResult(success, returndata, errorMessage);
  }

  function verifyCallResult(
    bool success,
    bytes memory returndata,
    string memory errorMessage
  ) internal pure returns (bytes memory) {

    if (success) {
      return returndata;
    } else {
      if (returndata.length > 0) {

        assembly {
          let returndata_size := mload(returndata)
          revert(add(32, returndata), returndata_size)
        }
      } else {
        revert(errorMessage);
      }
    }
  }
}// MIT

pragma solidity ^0.8.0;


library SafeERC20 {

  using Address for address;

  function safeTransfer(
    IERC20 token,
    address to,
    uint256 value
  ) internal {

    _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
  }

  function safeTransferFrom(
    IERC20 token,
    address from,
    address to,
    uint256 value
  ) internal {

    _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
  }

  function safeApprove(
    IERC20 token,
    address spender,
    uint256 value
  ) internal {

    require(
      (value == 0) || (token.allowance(address(this), spender) == 0),
      "SafeERC20: approve from non-zero to non-zero allowance"
    );
    _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
  }

  function safeIncreaseAllowance(
    IERC20 token,
    address spender,
    uint256 value
  ) internal {

    uint256 newAllowance = token.allowance(address(this), spender) + value;
    _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
  }

  function safeDecreaseAllowance(
    IERC20 token,
    address spender,
    uint256 value
  ) internal {

  unchecked {
    uint256 oldAllowance = token.allowance(address(this), spender);
    require(oldAllowance >= value, "SafeERC20: decreased allowance below zero");
    uint256 newAllowance = oldAllowance - value;
    _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
  }
  }

  function _callOptionalReturn(IERC20 token, bytes memory data) private {


    bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
    if (returndata.length > 0) {
      require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
    }
  }
}// ISC

pragma solidity 0.8.4;

interface IDelegation {

  function clearDelegate(bytes32 _id) external;


  function setDelegate(bytes32 _id, address _delegate) external;


  function delegation(address _address, bytes32 _id) external view returns (address);

}//Unlicense

pragma solidity 0.8.4;

interface IVotingEscrow {


  struct Point {
    int128 bias;
    int128 slope; // - dweight / dt
    uint256 ts;
    uint256 blk; // block
  }

  function balanceOf(address addr) external view returns (uint);


  function balanceOfAt(address addr, uint block_) external view returns (uint);


  function totalSupply() external view returns (uint);


  function totalSupplyAt(uint block_) external view returns (uint);


  function locked(address user) external view returns (uint amount, uint end);


  function create_lock(uint value, uint unlock_time) external;


  function increase_amount(uint value) external;


  function increase_unlock_time(uint unlock_time) external;


  function withdraw() external;


  function commit_smart_wallet_checker(address addr) external;


  function apply_smart_wallet_checker() external;


  function user_point_history(address user, uint256 timestamp) external view returns (Point memory);


  function user_point_epoch(address user) external view returns (uint256);


}// GPL-3.0-or-later



pragma solidity 0.8.4;


interface IFeeDistributor {

  event TokenCheckpointed(IERC20 token, uint256 amount, uint256 lastCheckpointTimestamp);
  event TokensClaimed(address user, IERC20 token, uint256 amount, uint256 userTokenTimeCursor);

  function getVotingEscrow() external view returns (IVotingEscrow);


  function getTimeCursor() external view returns (uint256);


  function getUserTimeCursor(address user) external view returns (uint256);


  function getTokenTimeCursor(IERC20 token) external view returns (uint256);


  function getUserTokenTimeCursor(address user, IERC20 token) external view returns (uint256);


  function getUserBalanceAtTimestamp(address user, uint256 timestamp) external view returns (uint256);


  function getTotalSupplyAtTimestamp(uint256 timestamp) external view returns (uint256);


  function getTokenLastBalance(IERC20 token) external view returns (uint256);


  function getTokensDistributedInWeek(IERC20 token, uint256 timestamp) external view returns (uint256);



  function depositToken(IERC20 token, uint256 amount) external;


  function depositTokens(IERC20[] calldata tokens, uint256[] calldata amounts) external;



  function checkpoint() external;


  function checkpointUser(address user) external;


  function checkpointToken(IERC20 token) external;


  function checkpointTokens(IERC20[] calldata tokens) external;



  function claimToken(address user, IERC20 token) external returns (uint256);


  function claimTokens(address user, IERC20[] calldata tokens) external returns (uint256[] memory);

}// ISC

pragma solidity 0.8.4;


interface IBalLocker {


  function VE_BAL() external view returns (address);


  function VE_BAL_UNDERLYING() external view returns (address);


  function BALANCER_MINTER() external view returns (address);


  function BAL() external view returns (address);


  function gaugeController() external view returns (address);


  function feeDistributor() external view returns (address);


  function operator() external view returns (address);


  function voter() external view returns (address);


  function delegateVotes(bytes32 _id, address _delegateContract, address _delegate) external;


  function clearDelegatedVotes(bytes32 _id, address _delegateContract) external;


  function depositVe(uint256 amount) external;


  function claimVeRewards(IERC20[] memory tokens, address recipient) external;


  function investedUnderlyingBalance() external view returns (uint);


  function depositToGauge(address gauge, uint amount) external;


  function withdrawFromGauge(address gauge, uint amount) external;


  function claimRewardsFromGauge(address gauge, address receiver) external;


  function claimRewardsFromMinter(address gauge, address receiver) external returns (uint claimed);


}//Unlicense
pragma solidity 0.8.4;

interface IGauge {


  struct Reward {
    address token;
    address distributor;
    uint256 period_finish;
    uint256 rate;
    uint256 last_update;
    uint256 integral;
  }

  function deposit(uint _value) external;


  function deposit(uint _value, address receiver, bool claim) external;


  function claimable_reward(address _addr, address _token) external view returns (uint256);


  function claimed_reward(address _addr, address _token) external view returns (uint256);


  function claimable_reward_write(address _addr, address _token) external returns (uint256);


  function withdraw(uint _value, bool) external;


  function claim_rewards(address _addr) external;


  function claim_rewards(address _addr, address receiver) external;


  function balanceOf(address) external view returns (uint);


  function lp_token() external view returns (address);


  function deposit_reward_token(address reward_token, uint256 amount) external;


  function add_reward(address reward_token, address distributor) external;


  function reward_tokens(uint id) external view returns (address);


  function reward_data(address token) external view returns (Reward memory);


  function reward_count() external view returns (uint);


  function initialize(address lp) external;

}//Unlicense
pragma solidity 0.8.4;

interface IGaugeController {


  function vote_for_many_gauge_weights(address[] memory _gauges, uint[] memory _userWeights) external;


  function vote_for_gauge_weights(address gauge, uint weight) external;


}// UNLICENSED

pragma solidity 0.8.4;

interface IBalancerMinter {

  event Minted(address indexed recipient, address gauge, uint256 minted);
  event MinterApprovalSet(
    address indexed user,
    address indexed minter,
    bool approval
  );

  function allowed_to_mint_for(address minter, address user)
  external
  view
  returns (bool);


  function getBalancerToken() external view returns (address);


  function getBalancerTokenAdmin() external view returns (address);


  function getDomainSeparator() external view returns (bytes32);


  function getGaugeController() external view returns (address);


  function getMinterApproval(address minter, address user)
  external
  view
  returns (bool);


  function getNextNonce(address user) external view returns (uint256);


  function mint(address gauge) external returns (uint256);


  function mintFor(address gauge, address user) external returns (uint256);


  function mintMany(address[] memory gauges) external returns (uint256);


  function mintManyFor(address[] memory gauges, address user)
  external
  returns (uint256);


  function mint_for(address gauge, address user) external;


  function mint_many(address[8] memory gauges) external;


  function minted(address user, address gauge)
  external
  view
  returns (uint256);


  function setMinterApproval(address minter, bool approval) external;


  function setMinterApprovalWithSignature(
    address minter,
    bool approval,
    address user,
    uint256 deadline,
    uint8 v,
    bytes32 r,
    bytes32 s
  ) external;


  function toggle_approve_mint(address minter) external;

}// ISC

pragma solidity 0.8.4;



contract BalLocker is ControllableV2, IBalLocker {

  using SafeERC20 for IERC20;

  address public constant override VE_BAL = 0xC128a9954e6c874eA3d62ce62B468bA073093F25;
  address public constant override VE_BAL_UNDERLYING = 0x5c6Ee304399DBdB9C8Ef030aB642B10820DB8F56;
  address public constant override BALANCER_MINTER = 0x239e55F427D44C3cc793f49bFB507ebe76638a2b;
  address public constant override BAL = 0xba100000625a3754423978a60c9317c58a424e3D;
  uint256 private constant _MAX_LOCK = 365 * 86400;
  uint256 private constant _WEEK = 7 * 86400;

  address public override gaugeController;
  address public override feeDistributor;
  address public override operator;
  address public override voter;
  mapping(address => address) public gaugesToDepositors;

  event ChangeOperator(address oldValue, address newValue);
  event ChangeGaugeController(address oldValue, address newValue);
  event ChangeFeeDistributor(address oldValue, address newValue);
  event ChangeVoter(address oldValue, address newValue);
  event LinkGaugeToDistributor(address gauge, address depositor);

  constructor(
    address controller_,
    address operator_,
    address gaugeController_,
    address feeDistributor_
  ) {
    require(controller_ != address(0), "Zero controller");
    require(operator_ != address(0), "Zero operator");
    require(gaugeController_ != address(0), "Zero gaugeController");
    require(feeDistributor_ != address(0), "Zero feeDistributor");

    ControllableV2.initializeControllable(controller_);
    operator = operator_;
    gaugeController = gaugeController_;
    feeDistributor = feeDistributor_;
    voter = IController(_controller()).governance();

    IERC20(VE_BAL_UNDERLYING).safeApprove(VE_BAL, type(uint).max);
  }

  modifier onlyGovernance() {

    require(_isGovernance(msg.sender), "Not gov");
    _;
  }

  modifier onlyVoter() {

    require(msg.sender == voter, "Not voter");
    _;
  }

  modifier onlyAllowedDepositor(address gauge) {

    require(gaugesToDepositors[gauge] == msg.sender, "Not allowed");
    _;
  }


  function delegateVotes(
    bytes32 _id,
    address _delegateContract,
    address _delegate
  ) external override onlyVoter {

    IDelegation(_delegateContract).setDelegate(_id, _delegate);
  }

  function clearDelegatedVotes(
    bytes32 _id,
    address _delegateContract
  ) external override onlyVoter {

    IDelegation(_delegateContract).clearDelegate(_id);
  }


  function depositVe(uint256 amount) external override {

    require(amount != 0, "Zero amount");

    IVotingEscrow ve = IVotingEscrow(VE_BAL);

    (uint balanceLocked, uint unlockTime) = ve.locked(address(this));
    if (unlockTime == 0 && balanceLocked == 0) {
      ve.create_lock(amount, block.timestamp + _MAX_LOCK);
    } else {
      ve.increase_amount(amount);

      uint256 unlockAt = block.timestamp + _MAX_LOCK;
      uint256 unlockInWeeks = (unlockAt / _WEEK) * _WEEK;

      if (unlockInWeeks > unlockTime && unlockInWeeks - unlockTime > 2) {
        ve.increase_unlock_time(unlockAt);
      }
    }
    IFeeDistributor(feeDistributor).checkpointUser(address(this));
  }

  function claimVeRewards(IERC20[] memory tokens, address recipient) external override {

    require(msg.sender == operator, "Not operator");
    require(recipient != address(0), "Zero recipient");

    IFeeDistributor(feeDistributor).claimTokens(address(this), tokens);

    for (uint i; i < tokens.length; ++i) {
      IERC20 token = tokens[i];
      uint balance = token.balanceOf(address(this));
      if (balance != 0) {
        token.safeTransfer(recipient, balance);
      }
    }
  }

  function investedUnderlyingBalance() external override view returns (uint) {

    (uint amount,) = IVotingEscrow(VE_BAL).locked(address(this));
    return amount;
  }


  function depositToGauge(address gauge, uint amount) external override onlyAllowedDepositor(gauge) {

    require(amount != 0, "Zero amount");
    require(gauge != address(0), "Zero gauge");

    address underlying = IGauge(gauge).lp_token();
    IERC20(underlying).safeTransferFrom(msg.sender, address(this), amount);
    IERC20(underlying).safeApprove(gauge, 0);
    IERC20(underlying).safeApprove(gauge, amount);
    IGauge(gauge).deposit(amount, address(this), false);
  }

  function withdrawFromGauge(
    address gauge,
    uint amount
  ) external override onlyAllowedDepositor(gauge) {

    require(amount != 0, "Zero amount");
    require(gauge != address(0), "Zero gauge");

    IGauge(gauge).withdraw(amount, false);
    address underlying = IGauge(gauge).lp_token();
    IERC20(underlying).safeTransfer(msg.sender, amount);
  }

  function claimRewardsFromGauge(
    address gauge,
    address receiver
  ) external override onlyAllowedDepositor(gauge) {

    require(gauge != address(0), "Zero gauge");
    require(receiver != address(0), "Zero receiver");

    IGauge(gauge).claim_rewards(address(this), receiver);
  }

  function claimRewardsFromMinter(
    address gauge,
    address receiver
  ) external override onlyAllowedDepositor(gauge) returns (uint) {

    require(gauge != address(0), "Zero gauge");
    require(receiver != address(0), "Zero receiver");

    uint balance = IERC20(BAL).balanceOf(address(this));
    IBalancerMinter(BALANCER_MINTER).mint(gauge);
    uint claimed = IERC20(BAL).balanceOf(address(this)) - balance;
    IERC20(BAL).safeTransfer(receiver, claimed);
    return claimed;
  }


  function voteForManyGaugeWeights(
    address[] memory _gauges,
    uint[] memory _userWeights
  ) external onlyVoter {

    require(_gauges.length == _userWeights.length, "Wrong input");
    for (uint i; i < _gauges.length; i++) {
      IGaugeController(gaugeController).vote_for_gauge_weights(_gauges[i], _userWeights[i]);
    }
  }


  function setOperator(address operator_) external onlyGovernance {

    require(operator_ != address(0), "Zero operator");
    emit ChangeOperator(operator, operator_);
    operator = operator_;
  }

  function setGaugeController(address value) external onlyGovernance {

    require(value != address(0), "Zero value");
    emit ChangeGaugeController(gaugeController, value);
    gaugeController = value;
  }

  function setFeeDistributor(address value) external onlyGovernance {

    require(value != address(0), "Zero value");
    emit ChangeFeeDistributor(feeDistributor, value);
    feeDistributor = value;
  }

  function setVoter(address value) external onlyVoter {

    require(value != address(0), "Zero value");
    emit ChangeVoter(voter, value);
    voter = value;
  }

  function linkDepositorsToGauges(
    address[] memory depositors,
    address[] memory gauges
  ) external onlyGovernance {

    for (uint i; i < depositors.length; i++) {
      address depositor = depositors[i];
      address gauge = gauges[i];
      require(gaugesToDepositors[gauge] == address(0), "Gauge already linked");
      gaugesToDepositors[gauge] = depositor;
      emit LinkGaugeToDistributor(gauge, depositor);
    }
  }

  function changeDepositorToGaugeLink(address gauge, address newDepositor) external {

    address depositor = gaugesToDepositors[gauge];
    require(depositor == msg.sender, "Not depositor");
    gaugesToDepositors[gauge] = newDepositor;
  }
}