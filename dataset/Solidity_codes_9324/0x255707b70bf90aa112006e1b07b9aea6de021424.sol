
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

}// ISC

pragma solidity 0.8.4;


abstract contract ForwarderV2Storage is Initializable {

  struct LpData {
    address lp;
    address token;
    address oppositeToken;
  }

  struct UniFee {
    uint numerator;
    uint denominator;
  }

  mapping(bytes32 => uint256) private uintStorage;
  mapping(bytes32 => address) private addressStorage;

  mapping(address => LpData) public largestLps;
  mapping(address => mapping(address => LpData)) public blueChipsLps;
  mapping(address => UniFee) public uniPlatformFee;
  mapping(address => bool) public blueChipsTokens;

  event UpdatedAddressSlot(string indexed name, address oldValue, address newValue);
  event UpdatedUint256Slot(string indexed name, uint256 oldValue, uint256 newValue);


  function _setLiquidityRouter(address _address) internal {
    emit UpdatedAddressSlot("liquidityRouter", liquidityRouter(), _address);
    setAddress("liquidityRouter", _address);
  }

  function liquidityRouter() public view returns (address) {
    return getAddress("liquidityRouter");
  }

  function _setLiquidityNumerator(uint256 _value) internal {
    emit UpdatedUint256Slot("liquidityNumerator", liquidityNumerator(), _value);
    setUint256("liquidityNumerator", _value);
  }

  function liquidityNumerator() public view returns (uint256) {
    return getUint256("liquidityNumerator");
  }

  function _setSlippageNumerator(uint256 _value) internal {
    emit UpdatedUint256Slot("slippageNumerator", _slippageNumerator(), _value);
    setUint256("slippageNumerator", _value);
  }

  function _slippageNumerator() internal view returns (uint256) {
    return getUint256("slippageNumerator");
  }


  function setAddress(string memory key, address _address) private {
    addressStorage[keccak256(abi.encodePacked(key))] = _address;
  }

  function getAddress(string memory key) private view returns (address) {
    return addressStorage[keccak256(abi.encodePacked(key))];
  }

  function setUint256(string memory key, uint256 _value) private {
    uintStorage[keccak256(abi.encodePacked(key))] = _value;
  }

  function getUint256(string memory key) private view returns (uint256) {
    return uintStorage[keccak256(abi.encodePacked(key))];
  }

  uint256[50] private ______gap;
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

interface ISmartVault {


  function setStrategy(address _strategy) external;


  function changeActivityStatus(bool _active) external;


  function changeProtectionMode(bool _active) external;


  function changePpfsDecreaseAllowed(bool _value) external;


  function setLockPeriod(uint256 _value) external;


  function setLockPenalty(uint256 _value) external;


  function setToInvest(uint256 _value) external;


  function doHardWork() external;


  function rebalance() external;


  function disableLock() external;


  function notifyTargetRewardAmount(address _rewardToken, uint256 reward) external;


  function notifyRewardWithoutPeriodChange(address _rewardToken, uint256 reward) external;


  function deposit(uint256 amount) external;


  function depositAndInvest(uint256 amount) external;


  function depositFor(uint256 amount, address holder) external;


  function withdraw(uint256 numberOfShares) external;


  function exit() external;


  function getAllRewards() external;


  function getReward(address rt) external;


  function underlying() external view returns (address);


  function strategy() external view returns (address);


  function getRewardTokenIndex(address rt) external view returns (uint256);


  function getPricePerFullShare() external view returns (uint256);


  function underlyingUnit() external view returns (uint256);


  function duration() external view returns (uint256);


  function underlyingBalanceInVault() external view returns (uint256);


  function underlyingBalanceWithInvestment() external view returns (uint256);


  function underlyingBalanceWithInvestmentForHolder(address holder) external view returns (uint256);


  function availableToInvestOut() external view returns (uint256);


  function earned(address rt, address account) external view returns (uint256);


  function earnedWithBoost(address rt, address account) external view returns (uint256);


  function rewardPerToken(address rt) external view returns (uint256);


  function lastTimeRewardApplicable(address rt) external view returns (uint256);


  function rewardTokensLength() external view returns (uint256);


  function active() external view returns (bool);


  function rewardTokens() external view returns (address[] memory);


  function periodFinishForToken(address _rt) external view returns (uint256);


  function rewardRateForToken(address _rt) external view returns (uint256);


  function lastUpdateTimeForToken(address _rt) external view returns (uint256);


  function rewardPerTokenStoredForToken(address _rt) external view returns (uint256);


  function userRewardPerTokenPaidForToken(address _rt, address account) external view returns (uint256);


  function rewardsForToken(address _rt, address account) external view returns (uint256);


  function userLastWithdrawTs(address _user) external view returns (uint256);


  function userLastDepositTs(address _user) external view returns (uint256);


  function userBoostTs(address _user) external view returns (uint256);


  function userLockTs(address _user) external view returns (uint256);


  function addRewardToken(address rt) external;


  function removeRewardToken(address rt) external;


  function stop() external;


  function ppfsDecreaseAllowed() external view returns (bool);


  function lockPeriod() external view returns (uint256);


  function lockPenalty() external view returns (uint256);


  function toInvest() external view returns (uint256);


  function depositFeeNumerator() external view returns (uint256);


  function lockAllowed() external view returns (bool);


  function protectionMode() external view returns (bool);

}// ISC

pragma solidity 0.8.4;

interface IFeeRewardForwarder {

  function distribute(uint256 _amount, address _token, address _vault) external returns (uint256);


  function notifyPsPool(address _token, uint256 _amount) external returns (uint256);


  function notifyCustomPool(address _token, address _rewardPool, uint256 _maxBuyback) external returns (uint256);


  function liquidate(address tokenIn, address tokenOut, uint256 amount) external returns (uint256);

}// ISC

pragma solidity 0.8.4;

interface IBookkeeper {


  struct PpfsChange {
    address vault;
    uint256 block;
    uint256 time;
    uint256 value;
    uint256 oldBlock;
    uint256 oldTime;
    uint256 oldValue;
  }

  struct HardWork {
    address strategy;
    uint256 block;
    uint256 time;
    uint256 targetTokenAmount;
  }

  function addVault(address _vault) external;


  function addStrategy(address _strategy) external;


  function registerStrategyEarned(uint256 _targetTokenAmount) external;


  function registerFundKeeperEarned(address _token, uint256 _fundTokenAmount) external;


  function registerUserAction(address _user, uint256 _amount, bool _deposit) external;


  function registerVaultTransfer(address from, address to, uint256 amount) external;


  function registerUserEarned(address _user, address _vault, address _rt, uint256 _amount) external;


  function registerPpfsChange(address vault, uint256 value) external;


  function registerRewardDistribution(address vault, address token, uint256 amount) external;


  function vaults() external view returns (address[] memory);


  function vaultsLength() external view returns (uint256);


  function strategies() external view returns (address[] memory);


  function strategiesLength() external view returns (uint256);


  function lastPpfsChange(address vault) external view returns (PpfsChange memory);


  function targetTokenEarned(address strategy) external view returns (uint256);


  function vaultUsersBalances(address vault, address user) external view returns (uint256);


  function userEarned(address user, address vault, address token) external view returns (uint256);


  function lastHardWork(address vault) external view returns (HardWork memory);


  function vaultUsersQuantity(address vault) external view returns (uint256);


  function fundKeeperEarned(address vault) external view returns (uint256);


  function vaultRewards(address vault, address token, uint256 idx) external view returns (uint256);


  function vaultRewardsLength(address vault, address token) external view returns (uint256);


  function strategyEarnedSnapshots(address strategy, uint256 idx) external view returns (uint256);


  function strategyEarnedSnapshotsTime(address strategy, uint256 idx) external view returns (uint256);


  function strategyEarnedSnapshotsLength(address strategy) external view returns (uint256);

}// UNLICENSED
pragma solidity 0.8.4;

interface IUniswapV2Router02 {

  function factory() external view returns (address);


  function WETH() external view returns (address);


  function addLiquidity(
    address tokenA,
    address tokenB,
    uint amountADesired,
    uint amountBDesired,
    uint amountAMin,
    uint amountBMin,
    address to,
    uint deadline
  ) external returns (uint amountA, uint amountB, uint liquidity);


  function addLiquidityETH(
    address token,
    uint amountTokenDesired,
    uint amountTokenMin,
    uint amountETHMin,
    address to,
    uint deadline
  ) external payable returns (uint amountToken, uint amountETH, uint liquidity);


  function removeLiquidity(
    address tokenA,
    address tokenB,
    uint liquidity,
    uint amountAMin,
    uint amountBMin,
    address to,
    uint deadline
  ) external returns (uint amountA, uint amountB);


  function removeLiquidityETH(
    address token,
    uint liquidity,
    uint amountTokenMin,
    uint amountETHMin,
    address to,
    uint deadline
  ) external returns (uint amountToken, uint amountETH);


  function removeLiquidityWithPermit(
    address tokenA,
    address tokenB,
    uint liquidity,
    uint amountAMin,
    uint amountBMin,
    address to,
    uint deadline,
    bool approveMax, uint8 v, bytes32 r, bytes32 s
  ) external returns (uint amountA, uint amountB);


  function removeLiquidityETHWithPermit(
    address token,
    uint liquidity,
    uint amountTokenMin,
    uint amountETHMin,
    address to,
    uint deadline,
    bool approveMax, uint8 v, bytes32 r, bytes32 s
  ) external returns (uint amountToken, uint amountETH);


  function swapExactTokensForTokens(
    uint amountIn,
    uint amountOutMin,
    address[] calldata path,
    address to,
    uint deadline
  ) external returns (uint[] memory amounts);


  function swapTokensForExactTokens(
    uint amountOut,
    uint amountInMax,
    address[] calldata path,
    address to,
    uint deadline
  ) external returns (uint[] memory amounts);


  function swapExactETHForTokens(uint amountOutMin, address[] calldata path, address to, uint deadline)
  external
  payable
  returns (uint[] memory amounts);


  function swapTokensForExactETH(uint amountOut, uint amountInMax, address[] calldata path, address to, uint deadline)
  external
  returns (uint[] memory amounts);


  function swapExactTokensForETH(uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline)
  external
  returns (uint[] memory amounts);


  function swapETHForExactTokens(uint amountOut, address[] calldata path, address to, uint deadline)
  external
  payable
  returns (uint[] memory amounts);


  function quote(uint amountA, uint reserveA, uint reserveB) external pure returns (uint amountB);


  function getAmountOut(uint amountIn, uint reserveIn, uint reserveOut) external pure returns (uint amountOut);


  function getAmountIn(uint amountOut, uint reserveIn, uint reserveOut) external pure returns (uint amountIn);


  function getAmountsOut(uint amountIn, address[] calldata path) external view returns (uint[] memory amounts);


  function getAmountsIn(uint amountOut, address[] calldata path) external view returns (uint[] memory amounts);


  function removeLiquidityETHSupportingFeeOnTransferTokens(
    address token,
    uint liquidity,
    uint amountTokenMin,
    uint amountETHMin,
    address to,
    uint deadline
  ) external returns (uint amountETH);


  function removeLiquidityETHWithPermitSupportingFeeOnTransferTokens(
    address token,
    uint liquidity,
    uint amountTokenMin,
    uint amountETHMin,
    address to,
    uint deadline,
    bool approveMax, uint8 v, bytes32 r, bytes32 s
  ) external returns (uint amountETH);


  function swapExactTokensForTokensSupportingFeeOnTransferTokens(
    uint amountIn,
    uint amountOutMin,
    address[] calldata path,
    address to,
    uint deadline
  ) external;


  function swapExactETHForTokensSupportingFeeOnTransferTokens(
    uint amountOutMin,
    address[] calldata path,
    address to,
    uint deadline
  ) external payable;


  function swapExactTokensForETHSupportingFeeOnTransferTokens(
    uint amountIn,
    uint amountOutMin,
    address[] calldata path,
    address to,
    uint deadline
  ) external;

}// UNLICENSED
pragma solidity 0.8.4;

interface IUniswapV2Factory {

  event PairCreated(address indexed token0, address indexed token1, address pair, uint);

  function getPair(address tokenA, address tokenB) external view returns (address pair);


  function allPairs(uint) external view returns (address pair);


  function allPairsLength() external view returns (uint);


  function feeTo() external view returns (address);


  function feeToSetter() external view returns (address);


  function createPair(address tokenA, address tokenB) external returns (address pair);

}// UNLICENSED

pragma solidity 0.8.4;

interface IUniswapV2Pair {

  event Approval(address indexed owner, address indexed spender, uint value);
  event Transfer(address indexed from, address indexed to, uint value);

  function name() external pure returns (string memory);


  function symbol() external pure returns (string memory);


  function decimals() external pure returns (uint8);


  function totalSupply() external view returns (uint);


  function balanceOf(address owner) external view returns (uint);


  function allowance(address owner, address spender) external view returns (uint);


  function approve(address spender, uint value) external returns (bool);


  function transfer(address to, uint value) external returns (bool);


  function transferFrom(address from, address to, uint value) external returns (bool);


  function DOMAIN_SEPARATOR() external view returns (bytes32);


  function PERMIT_TYPEHASH() external pure returns (bytes32);


  function nonces(address owner) external view returns (uint);


  function permit(address owner, address spender, uint value, uint deadline, uint8 v, bytes32 r, bytes32 s) external;


  event Mint(address indexed sender, uint amount0, uint amount1);
  event Burn(address indexed sender, uint amount0, uint amount1, address indexed to);
  event Swap(
    address indexed sender,
    uint amount0In,
    uint amount1In,
    uint amount0Out,
    uint amount1Out,
    address indexed to
  );
  event Sync(uint112 reserve0, uint112 reserve1);

  function MINIMUM_LIQUIDITY() external pure returns (uint);


  function factory() external view returns (address);


  function token0() external view returns (address);


  function token1() external view returns (address);


  function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);


  function price0CumulativeLast() external view returns (uint);


  function price1CumulativeLast() external view returns (uint);


  function kLast() external view returns (uint);


  function mint(address to) external returns (uint liquidity);


  function burn(address to) external returns (uint amount0, uint amount1);


  function swap(uint amount0Out, uint amount1Out, address to, bytes calldata data) external;


  function skim(address to) external;


  function sync() external;


  function initialize(address, address) external;

}// ISC

pragma solidity 0.8.4;


contract ForwarderV2 is ControllableV2, IFeeRewardForwarder, ForwarderV2Storage {

  using SafeERC20 for IERC20;

  string public constant VERSION = "1.3.0";
  uint256 public constant LIQUIDITY_DENOMINATOR = 100;
  uint constant public DEFAULT_UNI_FEE_DENOMINATOR = 1000;
  uint constant public DEFAULT_UNI_FEE_NUMERATOR = 997;
  uint constant public ROUTE_LENGTH_MAX = 5;
  uint constant public SLIPPAGE_DENOMINATOR = 100;
  uint constant public MINIMUM_AMOUNT = 100;

  event FeeMovedToPs(address indexed ps, address indexed token, uint256 amount);
  event FeeMovedToVault(address indexed vault, address indexed token, uint256 amount);
  event FeeMovedToFund(address indexed fund, address indexed token, uint256 amount);
  event Liquidated(address indexed tokenIn, address indexed tokenOut, uint256 amount);
  event LiquidityAdded(
    address router,
    address token0,
    uint256 token0Amount,
    address token1,
    uint256 token1Amount
  );

  function initialize(address _controller) external initializer {

    ControllableV2.initializeControllable(_controller);
  }

  modifier onlyControllerOrGovernance() {

    require(_isController(msg.sender) || _isGovernance(msg.sender), "F2: Not controller or gov");
    _;
  }

  modifier onlyRewardDistribution() {

    require(IController(_controller()).isRewardDistributor(msg.sender), "F2: Only distributor");
    _;
  }


  function psVault() public view returns (address) {

    return IController(_controller()).psVault();
  }

  function fund() public view returns (address) {

    return IController(_controller()).fund();
  }

  function tetu() public view returns (address) {

    return IController(_controller()).rewardToken();
  }

  function fundToken() public view returns (address) {

    return IController(_controller()).fundToken();
  }

  function slippageNumerator() public view returns (uint) {

    return _slippageNumerator();
  }



  function addLargestLps(address[] memory _tokens, address[] memory _lps) external onlyControllerOrGovernance {

    require(_tokens.length == _lps.length, "F2: Wrong arrays");
    for (uint i = 0; i < _lps.length; i++) {
      IUniswapV2Pair lp = IUniswapV2Pair(_lps[i]);
      address oppositeToken;
      if (lp.token0() == _tokens[i]) {
        oppositeToken = lp.token1();
      } else if (lp.token1() == _tokens[i]) {
        oppositeToken = lp.token0();
      } else {
        revert("F2: Wrong LP");
      }
      largestLps[_tokens[i]] = LpData(address(lp), _tokens[i], oppositeToken);
    }
  }

  function addBlueChipsLps(address[] memory _lps) external onlyControllerOrGovernance {

    for (uint i = 0; i < _lps.length; i++) {
      IUniswapV2Pair lp = IUniswapV2Pair(_lps[i]);
      blueChipsLps[lp.token0()][lp.token1()] = LpData(address(lp), lp.token0(), lp.token1());
      blueChipsLps[lp.token1()][lp.token0()] = LpData(address(lp), lp.token0(), lp.token1());
      blueChipsTokens[lp.token0()] = true;
      blueChipsTokens[lp.token1()] = true;
    }
  }

  function setLiquidityNumerator(uint256 _value) external onlyControllerOrGovernance {

    require(_value <= LIQUIDITY_DENOMINATOR, "F2: Too high value");
    _setLiquidityNumerator(_value);
  }

  function setSlippageNumerator(uint256 _value) external onlyControllerOrGovernance {

    require(_value <= SLIPPAGE_DENOMINATOR, "F2: Too high value");
    _setSlippageNumerator(_value);
  }

  function setLiquidityRouter(address _value) external onlyControllerOrGovernance {

    _setLiquidityRouter(_value);
  }

  function setUniPlatformFee(address _factory, uint _feeNumerator, uint _feeDenominator) external onlyControllerOrGovernance {

    require(_factory != address(0), "F2: Zero factory");
    require(_feeNumerator <= _feeDenominator, "F2: Wrong values");
    require(_feeDenominator != 0, "F2: Wrong denominator");
    uniPlatformFee[_factory] = UniFee(_feeNumerator, _feeDenominator);
  }


  function distribute(
    uint256 _amount,
    address _token,
    address _vault
  ) public override onlyRewardDistribution returns (uint256){

    require(fundToken() != address(0), "F2: Fund token is zero");
    require(_amount != 0, "F2: Zero amount for distribute");
    IERC20(_token).safeTransferFrom(msg.sender, address(this), _amount);

    if (_amount < MINIMUM_AMOUNT) {
      return 0;
    }

    uint toFund = _toFundAmount(_amount);
    uint toPsAndLiq = _toPsAndLiqAmount(_amount - toFund);
    uint toLiq = _toTetuLiquidityAmount(toPsAndLiq);
    uint toLiqFundTokenPart = toLiq / 2;
    uint toLiqTetuTokenPart = toLiq - toLiqFundTokenPart;
    uint toPs = toPsAndLiq - toLiq;
    uint toVault = _amount - toFund - toPsAndLiq;

    uint fundTokenRequires = toFund + toLiqFundTokenPart;
    uint tetuTokenRequires = toLiqTetuTokenPart + toPs + toVault;
    require(fundTokenRequires + tetuTokenRequires == _amount, "F2: Wrong amount sum");


    uint fundTokenAmount = _liquidate(_token, fundToken(), fundTokenRequires);
    uint sentToFund = _sendToFund(fundTokenAmount, toFund, toLiqFundTokenPart);

    uint tetuTokenAmount = _liquidate(_token, tetu(), tetuTokenRequires);

    uint256 tetuDistributed = 0;
    if (toPsAndLiq > MINIMUM_AMOUNT && fundTokenAmount > sentToFund) {
      tetuDistributed += _sendToPsAndLiquidity(
        tetuTokenAmount,
        toLiqTetuTokenPart,
        toPs,
        toVault,
        fundTokenAmount - sentToFund
      );
    }
    if (toVault > MINIMUM_AMOUNT) {
      tetuDistributed += _sendToVault(
        _vault,
        tetuTokenAmount,
        toLiqTetuTokenPart,
        toPs,
        toVault
      );
    }

    _sendExcessTokens();
    return _plusFundAmountToDistributedAmount(tetuDistributed);
  }

  function liquidate(address tokenIn, address tokenOut, uint256 amount) external override returns (uint256) {

    if (tokenIn == tokenOut) {
      return amount;
    }
    if (amount == 0) {
      return 0;
    }
    IERC20(tokenIn).safeTransferFrom(msg.sender, address(this), amount);
    uint256 resultAmount = _liquidate(tokenIn, tokenOut, amount);
    require(resultAmount > 0, "F2: Liquidated with zero result");
    IERC20(tokenOut).safeTransfer(msg.sender, resultAmount);
    emit Liquidated(tokenIn, tokenOut, amount);
    return resultAmount;
  }

  function notifyPsPool(address, uint256) external pure override returns (uint256) {

    revert("F2: Directly notifyPsPool not implemented");
  }

  function notifyCustomPool(address, address, uint256) external pure override returns (uint256) {

    revert("F2: Directly notifyCustomPool not implemented");
  }



  function _sendExcessTokens() internal {

    uint excessFundToken = IERC20(fundToken()).balanceOf(address(this));
    if (excessFundToken > MINIMUM_AMOUNT && fund() != address(0)) {
      IERC20(fundToken()).safeTransfer(fund(), excessFundToken);
      IBookkeeper(IController(_controller()).bookkeeper())
      .registerFundKeeperEarned(fundToken(), excessFundToken);
      emit FeeMovedToFund(fund(), fundToken(), excessFundToken);
    }

    uint excessTetuToken = IERC20(tetu()).balanceOf(address(this));
    if (excessTetuToken > MINIMUM_AMOUNT) {
      IERC20(tetu()).safeTransfer(psVault(), excessTetuToken);
      emit FeeMovedToPs(psVault(), tetu(), excessTetuToken);
    }
  }

  function _sendToPsAndLiquidity(
    uint tetuTokenAmount,
    uint baseToLiqTetuTokenPart,
    uint baseToPs,
    uint baseToVault,
    uint toLiqFundTokenPart
  ) internal returns (uint) {

    uint baseSum = baseToLiqTetuTokenPart + baseToPs + baseToVault;

    uint toLiqTetuTokenPart = tetuTokenAmount * baseToLiqTetuTokenPart / baseSum;
    uint tetuLiqAmount = _sendToLiquidity(toLiqTetuTokenPart, toLiqFundTokenPart);

    uint toPs = tetuTokenAmount * baseToPs / baseSum;
    if (toPs > MINIMUM_AMOUNT) {
      IERC20(tetu()).safeTransfer(psVault(), toPs);
      emit FeeMovedToPs(psVault(), tetu(), toPs);
    }
    return toPs + tetuLiqAmount;
  }

  function _sendToVault(
    address _vault,
    uint tetuTokenAmount,
    uint baseToLiqTetuTokenPart,
    uint baseToPs,
    uint baseToVault
  ) internal returns (uint256) {

    address xTetu = psVault();
    ISmartVault smartVault = ISmartVault(_vault);
    address[] memory rts = smartVault.rewardTokens();
    require(rts.length > 0, "F2: No reward tokens");
    address rt = rts[0];

    uint baseSum = baseToLiqTetuTokenPart + baseToPs + baseToVault;
    uint toVault = tetuTokenAmount * baseToVault / baseSum;
    if (toVault < MINIMUM_AMOUNT) {
      return 0;
    }

    uint256 amountToSend;
    if (rt == xTetu) {
      uint rtBalanceBefore = IERC20(xTetu).balanceOf(address(this));
      IERC20(tetu()).safeApprove(psVault(), toVault);
      ISmartVault(psVault()).deposit(toVault);
      amountToSend = IERC20(xTetu).balanceOf(address(this)) - rtBalanceBefore;
    } else if (rt == tetu()) {
      amountToSend = toVault;
    } else {
      revert("F2: First reward token not TETU nor xTETU");
    }

    IERC20(rt).safeApprove(_vault, amountToSend);
    smartVault.notifyTargetRewardAmount(rt, amountToSend);
    emit FeeMovedToVault(_vault, rt, amountToSend);
    return toVault;
  }

  function _sendToFund(uint256 fundTokenAmount, uint baseToFundAmount, uint baseToLiqFundTokenPart) internal returns (uint){

    uint toFund = fundTokenAmount * baseToFundAmount / (baseToFundAmount + baseToLiqFundTokenPart);

    if (toFund == 0) {
      return 0;
    }
    require(fund() != address(0), "F2: Fund is zero");

    IERC20(fundToken()).safeTransfer(fund(), toFund);

    IBookkeeper(IController(_controller()).bookkeeper())
    .registerFundKeeperEarned(fundToken(), toFund);
    emit FeeMovedToFund(fund(), fundToken(), toFund);
    return toFund;
  }

  function _sendToLiquidity(uint toLiqTetuTokenPart, uint toLiqFundTokenPart) internal returns (uint256) {

    if (toLiqTetuTokenPart < MINIMUM_AMOUNT || toLiqFundTokenPart < MINIMUM_AMOUNT) {
      return 0;
    }

    uint256 lpAmount = _addLiquidity(
      liquidityRouter(),
      fundToken(),
      tetu(),
      toLiqFundTokenPart,
      toLiqTetuTokenPart
    );

    require(lpAmount != 0, "F2: Liq: Zero LP amount");

    address liquidityPair = IUniswapV2Factory(IUniswapV2Router02(liquidityRouter()).factory())
    .getPair(fundToken(), tetu());

    IERC20(liquidityPair).safeTransfer(fund(), lpAmount);
    return toLiqTetuTokenPart * 2;
  }

  function _toFundAmount(uint256 _amount) internal view returns (uint256) {

    uint256 fundNumerator = IController(_controller()).fundNumerator();
    uint256 fundDenominator = IController(_controller()).fundDenominator();
    return _amount * fundNumerator / fundDenominator;
  }

  function _toPsAndLiqAmount(uint _amount) internal view returns (uint) {

    uint256 psNumerator = IController(_controller()).psNumerator();
    uint256 psDenominator = IController(_controller()).psDenominator();
    return _amount * psNumerator / psDenominator;
  }

  function _toTetuLiquidityAmount(uint256 _amount) internal view returns (uint256) {

    return _amount * liquidityNumerator() / LIQUIDITY_DENOMINATOR;
  }

  function _plusFundAmountToDistributedAmount(uint256 _amount) internal view returns (uint256) {

    uint256 fundNumerator = IController(_controller()).fundNumerator();
    uint256 fundDenominator = IController(_controller()).fundDenominator();
    return _amount * fundDenominator / (fundDenominator - fundNumerator);
  }

  function _liquidate(address _tokenIn, address _tokenOut, uint256 _amount) internal returns (uint256) {

    if (_tokenIn == _tokenOut) {
      return _amount;
    }
    (LpData[] memory route, uint count) = _createLiquidationRoute(_tokenIn, _tokenOut);

    uint outBalance = _amount;
    for (uint i = 0; i < count; i++) {
      LpData memory lpData = route[i];
      uint outBalanceBefore = IERC20(lpData.oppositeToken).balanceOf(address(this));
      _swap(lpData.token, lpData.oppositeToken, IUniswapV2Pair(lpData.lp), outBalance);
      outBalance = IERC20(lpData.oppositeToken).balanceOf(address(this)) - outBalanceBefore;
    }
    return outBalance;
  }

  function _createLiquidationRoute(address _tokenIn, address _tokenOut) internal view returns (LpData[] memory, uint)  {

    LpData[] memory route = new LpData[](ROUTE_LENGTH_MAX);
    LpData memory lpDataBC = blueChipsLps[_tokenIn][_tokenOut];
    if (lpDataBC.lp != address(0)) {
      lpDataBC.token = _tokenIn;
      lpDataBC.oppositeToken = _tokenOut;
      route[0] = lpDataBC;
      return (route, 1);
    }

    LpData memory lpDataIn = largestLps[_tokenIn];
    require(lpDataIn.lp != address(0), "F2: not found LP for tokenIn");
    route[0] = lpDataIn;
    if (lpDataIn.oppositeToken == _tokenOut) {
      return (route, 1);
    }

    lpDataBC = blueChipsLps[lpDataIn.oppositeToken][_tokenOut];
    if (lpDataBC.lp != address(0)) {
      lpDataBC.token = lpDataIn.oppositeToken;
      lpDataBC.oppositeToken = _tokenOut;
      route[1] = lpDataBC;
      return (route, 2);
    }

    LpData memory lpDataOut = largestLps[_tokenOut];
    require(lpDataIn.lp != address(0), "F2: not found LP for tokenOut");
    if (lpDataIn.oppositeToken == lpDataOut.oppositeToken) {
      lpDataOut.oppositeToken = lpDataOut.token;
      lpDataOut.token = lpDataIn.oppositeToken;
      route[1] = lpDataOut;
      return (route, 2);
    }

    lpDataBC = blueChipsLps[lpDataIn.oppositeToken][lpDataOut.oppositeToken];
    if (lpDataBC.lp != address(0)) {
      lpDataBC.token = lpDataIn.oppositeToken;
      lpDataBC.oppositeToken = lpDataOut.oppositeToken;
      route[1] = lpDataBC;
      lpDataOut.oppositeToken = lpDataOut.token;
      lpDataOut.token = lpDataBC.oppositeToken;
      route[2] = lpDataOut;
      return (route, 3);
    }

    LpData memory lpDataInMiddle;
    if (!blueChipsTokens[lpDataIn.oppositeToken]) {

      lpDataInMiddle = largestLps[lpDataIn.oppositeToken];
      require(lpDataInMiddle.lp != address(0), "F2: not found LP for middle in");
      route[1] = lpDataInMiddle;
      if (lpDataInMiddle.oppositeToken == _tokenOut) {
        return (route, 2);
      }

      lpDataBC = blueChipsLps[lpDataInMiddle.oppositeToken][_tokenOut];
      if (lpDataBC.lp != address(0)) {
        lpDataBC.token = lpDataInMiddle.oppositeToken;
        lpDataBC.oppositeToken = _tokenOut;
        route[2] = lpDataBC;
        return (route, 3);
      }

      lpDataBC = blueChipsLps[lpDataInMiddle.oppositeToken][lpDataOut.oppositeToken];
      if (lpDataBC.lp != address(0)) {
        lpDataBC.token = lpDataInMiddle.oppositeToken;
        lpDataBC.oppositeToken = lpDataOut.oppositeToken;
        route[2] = lpDataBC;
        (lpDataOut.oppositeToken, lpDataOut.token) = (lpDataOut.token, lpDataOut.oppositeToken);
        route[3] = lpDataOut;
        return (route, 4);
      }

    }


    LpData memory lpDataOutMiddle = largestLps[lpDataOut.oppositeToken];
    require(lpDataOutMiddle.lp != address(0), "F2: not found LP for middle out");
    if (lpDataOutMiddle.oppositeToken == lpDataIn.oppositeToken) {
      (lpDataOutMiddle.oppositeToken, lpDataOutMiddle.token) = (lpDataOutMiddle.token, lpDataOutMiddle.oppositeToken);
      route[1] = lpDataOutMiddle;
      return (route, 2);
    }

    if (lpDataInMiddle.lp != address(0)) {
      lpDataBC = blueChipsLps[lpDataInMiddle.oppositeToken][lpDataOutMiddle.oppositeToken];
      if (lpDataBC.lp != address(0)) {
        lpDataBC.token = lpDataInMiddle.oppositeToken;
        lpDataBC.oppositeToken = lpDataOutMiddle.oppositeToken;
        route[2] = lpDataBC;
        (lpDataOutMiddle.oppositeToken, lpDataOutMiddle.token) = (lpDataOutMiddle.token, lpDataOutMiddle.oppositeToken);
        route[3] = lpDataOutMiddle;
        (lpDataOut.oppositeToken, lpDataOut.token) = (lpDataOut.token, lpDataOut.oppositeToken);
        route[4] = lpDataOut;
        return (route, 5);
      }
    } else {
      lpDataBC = blueChipsLps[lpDataIn.oppositeToken][lpDataOutMiddle.oppositeToken];
      if (lpDataBC.lp != address(0)) {
        lpDataBC.token = lpDataIn.oppositeToken;
        lpDataBC.oppositeToken = lpDataOutMiddle.oppositeToken;
        route[1] = lpDataBC;
        (lpDataOutMiddle.oppositeToken, lpDataOutMiddle.token) = (lpDataOutMiddle.token, lpDataOutMiddle.oppositeToken);
        route[2] = lpDataOutMiddle;
        (lpDataOut.oppositeToken, lpDataOut.token) = (lpDataOut.token, lpDataOut.oppositeToken);
        route[3] = lpDataOut;
        return (route, 4);
      }
    }

    revert("F2: Liquidation path not found");
  }


  function _swap(address tokenIn, address tokenOut, IUniswapV2Pair lp, uint amount) internal {

    require(amount != 0, "F2: Zero swap amount");
    (uint reserveIn, uint reserveOut) = getReserves(lp, tokenIn, tokenOut);
    address factory = lp.factory();
    UniFee memory fee = uniPlatformFee[factory];
    if (fee.numerator == 0) {
      fee = UniFee(DEFAULT_UNI_FEE_NUMERATOR, DEFAULT_UNI_FEE_DENOMINATOR);
    }
    if(factory == 0x684d8c187be836171a1Af8D533e4724893031828) {
      lp.sync();
    }
    uint amountOut = getAmountOut(amount, reserveIn, reserveOut, fee);
    IERC20(tokenIn).safeTransfer(address(lp), amount);
    if (amountOut != 0) {
      _swapCall(lp, tokenIn, tokenOut, amountOut);
    }
  }

  function _addLiquidity(
    address _router,
    address _token0,
    address _token1,
    uint256 _token0Amount,
    uint256 _token1Amount
  ) internal returns (uint256){

    IERC20(_token0).safeApprove(_router, 0);
    IERC20(_token0).safeApprove(_router, _token0Amount);
    IERC20(_token1).safeApprove(_router, 0);
    IERC20(_token1).safeApprove(_router, _token1Amount);

    (,, uint256 liquidity) = IUniswapV2Router02(_router).addLiquidity(
      _token0,
      _token1,
      _token0Amount,
      _token1Amount,
      _token0Amount * _slippageNumerator() / SLIPPAGE_DENOMINATOR,
      _token1Amount * _slippageNumerator() / SLIPPAGE_DENOMINATOR,
      address(this),
      block.timestamp
    );
    emit LiquidityAdded(_router, _token0, _token0Amount, _token1, _token1Amount);
    return liquidity;
  }

  function getAmountOut(uint amountIn, uint reserveIn, uint reserveOut, UniFee memory fee) internal pure returns (uint amountOut) {

    uint amountInWithFee = amountIn * fee.numerator;
    uint numerator = amountInWithFee * reserveOut;
    uint denominator = (reserveIn * fee.denominator) + amountInWithFee;
    amountOut = numerator / denominator;
  }

  function _swapCall(IUniswapV2Pair _lp, address tokenIn, address tokenOut, uint amountOut) internal {

    (address token0,) = sortTokens(tokenIn, tokenOut);
    (uint amount0Out, uint amount1Out) = tokenIn == token0 ? (uint(0), amountOut) : (amountOut, uint(0));
    _lp.swap(amount0Out, amount1Out, address(this), new bytes(0));
  }

  function sortTokens(address tokenA, address tokenB) internal pure returns (address token0, address token1) {

    (token0, token1) = tokenA < tokenB ? (tokenA, tokenB) : (tokenB, tokenA);
  }

  function getReserves(IUniswapV2Pair _lp, address tokenA, address tokenB) internal view returns (uint reserveA, uint reserveB) {

    (address token0,) = sortTokens(tokenA, tokenB);
    (uint reserve0, uint reserve1,) = _lp.getReserves();
    (reserveA, reserveB) = tokenA == token0 ? (reserve0, reserve1) : (reserve1, reserve0);
  }
}