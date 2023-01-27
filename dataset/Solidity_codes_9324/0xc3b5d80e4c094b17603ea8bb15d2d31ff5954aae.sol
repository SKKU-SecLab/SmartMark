
pragma solidity ^0.8.0;

library Math {

  function max(uint256 a, uint256 b) internal pure returns (uint256) {

    return a >= b ? a : b;
  }

  function min(uint256 a, uint256 b) internal pure returns (uint256) {

    return a < b ? a : b;
  }

  function average(uint256 a, uint256 b) internal pure returns (uint256) {

    return (a & b) + (a ^ b) / 2;
  }

  function ceilDiv(uint256 a, uint256 b) internal pure returns (uint256) {

    return a / b + (a % b == 0 ? 0 : 1);
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
}// MIT

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


abstract contract StrategyStorage is Initializable {

  mapping(bytes32 => uint256) private uintStorage;
  mapping(bytes32 => address) private addressStorage;
  mapping(bytes32 => bool) private boolStorage;

  mapping(address => bool) internal _unsalvageableTokens;
  address[] internal _rewardTokens;

  event UpdatedAddressSlot(string name, address oldValue, address newValue);
  event UpdatedUint256Slot(string name, uint256 oldValue, uint256 newValue);
  event UpdatedBoolSlot(string name, bool oldValue, bool newValue);


  function _setUnderlying(address _address) internal {
    emit UpdatedAddressSlot("underlying", _underlying(), _address);
    setAddress("underlying", _address);
  }

  function _underlying() internal view returns (address) {
    return getAddress("underlying");
  }

  function _setVault(address _address) internal {
    emit UpdatedAddressSlot("vault", _vault(), _address);
    setAddress("vault", _address);
  }

  function _vault() internal view returns (address) {
    return getAddress("vault");
  }

  function _setBuyBackRatio(uint _value) internal {
    emit UpdatedUint256Slot("buyBackRatio", _buyBackRatio(), _value);
    setUint256("buyBackRatio", _value);
  }

  function _buyBackRatio() internal view returns (uint) {
    return getUint256("buyBackRatio");
  }

  function _setOnPause(bool _value) internal {
    emit UpdatedBoolSlot("onPause", _onPause(), _value);
    setBoolean("onPause", _value);
  }

  function _onPause() internal view returns (bool) {
    return getBoolean("onPause");
  }

  function _setToleranceNumerator(uint _value) internal {
    emit UpdatedUint256Slot("tolerance", _toleranceNumerator(), _value);
    setUint256("tolerance", _value);
  }

  function _toleranceNumerator() internal view returns (uint) {
    return getUint256("tolerance");
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

  function setBoolean(string memory key, bool _value) private {
    boolStorage[keccak256(abi.encodePacked(key))] = _value;
  }

  function getBoolean(string memory key) private view returns (bool) {
    return boolStorage[keccak256(abi.encodePacked(key))];
  }

  uint256[50] private ______gap;
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

interface IStrategy {


  enum Platform {
    UNKNOWN, // 0
    TETU, // 1
    QUICK, // 2
    SUSHI, // 3
    WAULT, // 4
    IRON, // 5
    COSMIC, // 6
    CURVE, // 7
    DINO, // 8
    IRON_LEND, // 9
    HERMES, // 10
    CAFE, // 11
    TETU_SWAP, // 12
    SPOOKY, // 13
    AAVE_LEND, //14
    AAVE_MAI_BAL, // 15
    GEIST, //16
    HARVEST, //17
    SCREAM_LEND, //18
    KLIMA, //19
    VESQ, //20
    QIDAO, //21
    SUNFLOWER, //22
    NACHO, //23
    STRATEGY_SPLITTER, //24
    TOMB, //25
    TAROT, //26
    BEETHOVEN, //27
    IMPERMAX, //28
    TETU_SF, //29
    ALPACA, //30
    MARKET, //31
    UNIVERSE, //32
    MAI_BAL, //33
    UMA, //34
    SPHERE, //35
    BALANCER, //36
    OTTERCLAM, //37
    SLOT_38, //38
    SLOT_39, //39
    SLOT_40, //40
    SLOT_41, //41
    SLOT_42, //42
    SLOT_43, //43
    SLOT_44, //44
    SLOT_45, //45
    SLOT_46, //46
    SLOT_47, //47
    SLOT_48, //48
    SLOT_49, //49
    SLOT_50 //50
  }

  function STRATEGY_NAME() external view returns (string memory);


  function withdrawAllToVault() external;


  function withdrawToVault(uint256 amount) external;


  function salvage(address recipient, address token, uint256 amount) external;


  function doHardWork() external;


  function investAllUnderlying() external;


  function emergencyExit() external;


  function pauseInvesting() external;


  function continueInvesting() external;


  function rewardTokens() external view returns (address[] memory);


  function underlying() external view returns (address);


  function underlyingBalance() external view returns (uint256);


  function rewardPoolBalance() external view returns (uint256);


  function buyBackRatio() external view returns (uint256);


  function unsalvageableTokens(address token) external view returns (bool);


  function vault() external view returns (address);


  function investedUnderlyingBalance() external view returns (uint256);


  function platform() external view returns (Platform);


  function assets() external view returns (address[] memory);


  function pausedInvesting() external view returns (bool);


  function readyToClaim() external view returns (uint256[] memory);


  function poolTotalAmount() external view returns (uint256);

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

}// ISC
pragma solidity 0.8.4;



abstract contract ProxyStrategyBase is IStrategy, ControllableV2, StrategyStorage {
  using SafeERC20 for IERC20;

  uint internal constant _BUY_BACK_DENOMINATOR = 100_00;
  uint internal constant _TOLERANCE_DENOMINATOR = 1000;


  modifier restricted() {
    require(msg.sender == _vault()
    || msg.sender == address(_controller())
      || IController(_controller()).governance() == msg.sender,
      "SB: Not Gov or Vault");
    _;
  }

  modifier hardWorkers() {
    require(msg.sender == _vault()
    || msg.sender == address(_controller())
    || IController(_controller()).isHardWorker(msg.sender)
      || IController(_controller()).governance() == msg.sender,
      "SB: Not HW or Gov or Vault");
    _;
  }

  modifier onlyController() {
    require(_controller() == msg.sender, "SB: Not controller");
    _;
  }

  modifier onlyNotPausedInvesting() {
    require(!_onPause(), "SB: Paused");
    _;
  }

  function initializeStrategyBase(
    address _controller,
    address _underlying,
    address _vault,
    address[] memory __rewardTokens,
    uint _bbRatio
  ) public initializer {
    ControllableV2.initializeControllable(_controller);
    require(ISmartVault(_vault).underlying() == _underlying, "SB: Wrong underlying");
    require(IControllable(_vault).isController(_controller), "SB: Wrong controller");
    _setUnderlying(_underlying);
    _setVault(_vault);
    require(_bbRatio <= _BUY_BACK_DENOMINATOR, "SB: Too high buyback ratio");
    _setBuyBackRatio(_bbRatio);

    for (uint i = 0; i < __rewardTokens.length; i++) {
      _rewardTokens.push(__rewardTokens[i]);
      _unsalvageableTokens[__rewardTokens[i]] = true;
    }
    _unsalvageableTokens[_underlying] = true;
    _setToleranceNumerator(999);
  }


  function rewardTokens() external view override returns (address[] memory) {
    return _rewardTokens;
  }

  function underlying() external view override returns (address) {
    return _underlying();
  }

  function underlyingBalance() external view override returns (uint) {
    return IERC20(_underlying()).balanceOf(address(this));
  }

  function vault() external view override returns (address) {
    return _vault();
  }

  function unsalvageableTokens(address token) external override view returns (bool) {
    return _unsalvageableTokens[token];
  }

  function buyBackRatio() external view override returns (uint) {
    return _buyBackRatio();
  }

  function investedUnderlyingBalance() external override virtual view returns (uint) {
    return _rewardPoolBalance() + IERC20(_underlying()).balanceOf(address(this));
  }

  function rewardPoolBalance() external override view returns (uint) {
    return _rewardPoolBalance();
  }

  function pausedInvesting() external override view returns (bool) {
    return _onPause();
  }



  function emergencyExit() external override hardWorkers {
    emergencyExitRewardPool();
    _setOnPause(true);
  }

  function pauseInvesting() external override hardWorkers {
    _setOnPause(true);
  }

  function continueInvesting() external override restricted {
    _setOnPause(false);
  }

  function salvage(address recipient, address token, uint amount)
  external override onlyController {
    require(!_unsalvageableTokens[token], "SB: Not salvageable");
    IERC20(token).safeTransfer(recipient, amount);
  }

  function withdrawAllToVault() external override hardWorkers {
    exitRewardPool();
    IERC20(_underlying()).safeTransfer(_vault(), IERC20(_underlying()).balanceOf(address(this)));
  }

  function withdrawToVault(uint amount) external override hardWorkers {
    uint uBalance = IERC20(_underlying()).balanceOf(address(this));
    if (amount > uBalance) {
      uint needToWithdraw = amount - uBalance;
      uint toWithdraw = Math.min(_rewardPoolBalance(), needToWithdraw);
      withdrawAndClaimFromPool(toWithdraw);
    }
    uBalance = IERC20(_underlying()).balanceOf(address(this));
    uint amountAdjusted = Math.min(amount, uBalance);
    require(amountAdjusted > amount * toleranceNumerator() / _TOLERANCE_DENOMINATOR, "SB: Withdrew too low");
    IERC20(_underlying()).safeTransfer(_vault(), amountAdjusted);
  }

  function investAllUnderlying() external override hardWorkers onlyNotPausedInvesting {
    _investAllUnderlying();
  }

  function setToleranceNumerator(uint numerator) external restricted {
    require(numerator <= _TOLERANCE_DENOMINATOR, "SB: Too high");
    _setToleranceNumerator(numerator);
  }

  function setBuyBackRatio(uint value) external restricted {
    require(value <= _BUY_BACK_DENOMINATOR, "SB: Too high buyback ratio");
    _setBuyBackRatio(value);
  }


  function _rewardBalance(uint rewardTokenIdx) internal view returns (uint) {
    return IERC20(_rewardTokens[rewardTokenIdx]).balanceOf(address(this));
  }

  function toleranceNumerator() internal view virtual returns (uint){
    return _toleranceNumerator();
  }

  function _investAllUnderlying() internal {
    uint uBalance = IERC20(_underlying()).balanceOf(address(this));
    if (uBalance > 0) {
      depositToPool(uBalance);
    }
  }

  function exitRewardPool() internal virtual {
    uint bal = _rewardPoolBalance();
    if (bal != 0) {
      withdrawAndClaimFromPool(bal);
    }
  }

  function emergencyExitRewardPool() internal {
    uint bal = _rewardPoolBalance();
    if (bal != 0) {
      emergencyWithdrawFromPool();
    }
  }

  function liquidateRewardDefault() internal {
    _liquidateReward(true);
  }

  function liquidateRewardSilently() internal {
    _liquidateReward(false);
  }

  function _liquidateReward(bool revertOnErrors) internal {
    address forwarder = IController(_controller()).feeRewardForwarder();
    uint targetTokenEarnedTotal = 0;
    for (uint i = 0; i < _rewardTokens.length; i++) {
      address rt = _rewardTokens[i];
      uint amount = IERC20(rt).balanceOf(address(this));
      if (amount != 0) {
        IERC20(rt).safeApprove(forwarder, 0);
        IERC20(rt).safeApprove(forwarder, amount);
        uint targetTokenEarned = 0;
        if (revertOnErrors) {
          targetTokenEarned = IFeeRewardForwarder(forwarder).distribute(amount, rt, _vault());
        } else {
          try IFeeRewardForwarder(forwarder).distribute(amount, rt, _vault()) returns (uint r) {
            targetTokenEarned = r;
          } catch {}
        }
        targetTokenEarnedTotal += targetTokenEarned;
      }
    }
    if (targetTokenEarnedTotal > 0) {
      IBookkeeper(IController(_controller()).bookkeeper()).registerStrategyEarned(targetTokenEarnedTotal);
    }
  }

  function autocompound() internal {
    address forwarder = IController(_controller()).feeRewardForwarder();
    for (uint i = 0; i < _rewardTokens.length; i++) {
      address rt = _rewardTokens[i];
      uint amount = IERC20(rt).balanceOf(address(this));
      if (amount != 0) {
        uint toCompound = amount * (_BUY_BACK_DENOMINATOR - _buyBackRatio()) / _BUY_BACK_DENOMINATOR;
        IERC20(rt).safeApprove(forwarder, 0);
        IERC20(rt).safeApprove(forwarder, toCompound);
        IFeeRewardForwarder(forwarder).liquidate(rt, _underlying(), toCompound);
      }
    }
  }

  function autocompoundLP(address _router) internal {
    address forwarder = IController(_controller()).feeRewardForwarder();
    for (uint i = 0; i < _rewardTokens.length; i++) {
      address rt = _rewardTokens[i];
      uint amount = IERC20(rt).balanceOf(address(this));
      if (amount != 0) {
        uint toCompound = amount * (_BUY_BACK_DENOMINATOR - _buyBackRatio()) / _BUY_BACK_DENOMINATOR;
        IERC20(rt).safeApprove(forwarder, 0);
        IERC20(rt).safeApprove(forwarder, toCompound);

        IUniswapV2Pair pair = IUniswapV2Pair(_underlying());
        if (rt != pair.token0()) {
          uint token0Amount = IFeeRewardForwarder(forwarder).liquidate(rt, pair.token0(), toCompound / 2);
          require(token0Amount != 0, "SB: Token0 zero amount");
        }
        if (rt != pair.token1()) {
          uint token1Amount = IFeeRewardForwarder(forwarder).liquidate(rt, pair.token1(), toCompound / 2);
          require(token1Amount != 0, "SB: Token1 zero amount");
        }
        addLiquidity(_underlying(), _router);
      }
    }
  }

  function addLiquidity(address _pair, address _router) internal {
    IUniswapV2Router02 router = IUniswapV2Router02(_router);
    IUniswapV2Pair pair = IUniswapV2Pair(_pair);
    address _token0 = pair.token0();
    address _token1 = pair.token1();

    uint amount0 = IERC20(_token0).balanceOf(address(this));
    uint amount1 = IERC20(_token1).balanceOf(address(this));

    IERC20(_token0).safeApprove(_router, 0);
    IERC20(_token0).safeApprove(_router, amount0);
    IERC20(_token1).safeApprove(_router, 0);
    IERC20(_token1).safeApprove(_router, amount1);
    router.addLiquidity(
      _token0,
      _token1,
      amount0,
      amount1,
      1,
      1,
      address(this),
      block.timestamp
    );
  }


  function _rewardPoolBalance() internal virtual view returns (uint);

  function depositToPool(uint amount) internal virtual;

  function withdrawAndClaimFromPool(uint amount) internal virtual;

  function emergencyWithdrawFromPool() internal virtual;

  function liquidateReward() internal virtual;

}// UNLICENSED
pragma solidity 0.8.4;

interface IERC20Extended {

  function name() external view returns (string memory);


  function symbol() external view returns (string memory);


  function decimals() external view returns (uint8);



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
}// ISC

pragma solidity 0.8.4;

interface IDelegation {

  function clearDelegate(bytes32 _id) external;


  function setDelegate(bytes32 _id, address _delegate) external;


  function delegation(address _address, bytes32 _id) external view returns (address);

}// ISC

pragma solidity 0.8.4;

library SlotsLib {


  function stringToBytes32(string memory source) internal pure returns (bytes32 result) {

    bytes memory tempEmptyStringTest = bytes(source);
    if (tempEmptyStringTest.length == 0) {
      return 0x0;
    }
    assembly {
      result := mload(add(source, 32))
    }
  }

  function bytes32ToString(bytes32 _bytes32) internal pure returns (string memory) {

    uint8 i = 0;
    while(i < 32 && _bytes32[i] != 0) {
      i++;
    }
    bytes memory bytesArray = new bytes(i);
    for (uint8 j = 0; j < i; j++) {
      bytesArray[j] = _bytes32[j];
    }
    return string(bytesArray);
  }


  function getBytes32(bytes32 slot) internal view returns (bytes32 result) {

    assembly {
      result := sload(slot)
    }
  }

  function getAddress(bytes32 slot) internal view returns (address result) {

    assembly {
      result := sload(slot)
    }
  }

  function getUint(bytes32 slot) internal view returns (uint result) {

    assembly {
      result := sload(slot)
    }
  }

  function getString(bytes32 slot) internal view returns (string memory result) {

    bytes32 data;
    assembly {
      data := sload(slot)
    }
    result = bytes32ToString(data);
  }


  function arrayLength(bytes32 slot) internal view returns (uint result) {

    assembly {
      result := sload(slot)
    }
  }

  function addressAt(bytes32 slot, uint index) internal view returns (address result) {

    bytes32 pointer = bytes32(uint(slot) - 1 - index);
    assembly {
      result := sload(pointer)
    }
  }

  function uintAt(bytes32 slot, uint index) internal view returns (uint result) {

    bytes32 pointer = bytes32(uint(slot) - 1 - index);
    assembly {
      result := sload(pointer)
    }
  }


  function set(bytes32 slot, bytes32 value) internal {

    assembly {
      sstore(slot, value)
    }
  }

  function set(bytes32 slot, address value) internal {

    assembly {
      sstore(slot, value)
    }
  }

  function set(bytes32 slot, uint value) internal {

    assembly {
      sstore(slot, value)
    }
  }

  function set(bytes32 slot, string memory str) internal {

    bytes32 value = stringToBytes32(str);
    assembly {
      sstore(slot, value)
    }
  }


  function setAt(bytes32 slot, uint index, address value) internal {

    bytes32 pointer = bytes32(uint(slot) - 1 - index);
    assembly {
      sstore(pointer, value)
    }
  }

  function setAt(bytes32 slot, uint index, uint value) internal {

    bytes32 pointer = bytes32(uint(slot) - 1 - index);
    assembly {
      sstore(pointer, value)
    }
  }

  function setLength(bytes32 slot, uint length) internal {

    assembly {
      sstore(slot, length)
    }
  }

  function push(bytes32 slot, address value) internal {

    uint length = arrayLength(slot);
    setAt(slot, length, value);
    setLength(slot, length + 1);
  }


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


}//Unlicense
pragma solidity 0.8.4;

interface IGaugeController {


  function vote_for_many_gauge_weights(address[] memory _gauges, uint[] memory _userWeights) external;


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


abstract contract BalStakingStrategyBase is ProxyStrategyBase {
  using SafeERC20 for IERC20;
  using SlotsLib for bytes32;

  string public constant override STRATEGY_NAME = "BalStakingStrategyBase";
  string public constant VERSION = "1.0.0";
  uint256 private constant _BUY_BACK_RATIO = 0;

  address public constant GAUGE_CONTROLLER = 0xC128468b7Ce63eA702C1f104D55A2566b13D3ABD;
  address public constant VE_DELEGATION = 0x2E96068b3D5B5BAE3D7515da4A1D2E52d08A2647;
  uint256 private constant _MAX_LOCK = 365 * 86400;
  uint256 private constant _WEEK = 7 * 86400;
  bytes32 internal constant _VE_BAL_KEY = bytes32(uint256(keccak256("s.ve_bal")) - 1);
  bytes32 internal constant _DEPOSITOR_KEY = bytes32(uint256(keccak256("s.depositor")) - 1);
  bytes32 internal constant _FEE_DISTRIBUTOR_KEY = bytes32(uint256(keccak256("s.fee_dist")) - 1);


  function initializeStrategy(
    address controller_,
    address underlying_,
    address vault_,
    address[] memory rewardTokens_,
    address veBAL_,
    address depositor_,
    address feeDistributor_
  ) public initializer {
    _VE_BAL_KEY.set(veBAL_);
    _DEPOSITOR_KEY.set(depositor_);
    _FEE_DISTRIBUTOR_KEY.set(feeDistributor_);
    ProxyStrategyBase.initializeStrategyBase(
      controller_,
      underlying_,
      vault_,
      rewardTokens_,
      _BUY_BACK_RATIO
    );

    IERC20(underlying_).safeApprove(veBAL_, type(uint256).max);
  }



  function depositor() external view returns (address){
    return _DEPOSITOR_KEY.getAddress();
  }

  function _veBAL() internal view returns (IVotingEscrow) {
    return IVotingEscrow(_VE_BAL_KEY.getAddress());
  }

  function _feeDistributor() internal view returns (IFeeDistributor) {
    return IFeeDistributor(_FEE_DISTRIBUTOR_KEY.getAddress());
  }

  function manualWithdraw() external restricted {
    _veBAL().withdraw();
    IERC20(_underlying()).safeTransfer(_vault(), IERC20(_underlying()).balanceOf(address(this)));
  }


  function voteForManyGaugeWeights(address[] memory _gauges, uint[] memory _userWeights) external {
    require(_isGovernance(msg.sender), "Not gov");
    require(_gauges.length == _userWeights.length, "Wrong input");
    IGaugeController(GAUGE_CONTROLLER).vote_for_many_gauge_weights(_gauges, _userWeights);
  }



  function investedUnderlyingBalance() external override view returns (uint) {
    return _rewardPoolBalance();
  }

  function _rewardPoolBalance() internal override view returns (uint256) {
    (uint amount,) = _veBAL().locked(address(this));
    return amount;
  }

  function doHardWork() external override {
    uint length = _rewardTokens.length;

    IERC20[] memory rtToClaim = new IERC20[](length);
    for (uint i; i < length; i++) {
      rtToClaim[i] = IERC20(_rewardTokens[i]);
    }

    _feeDistributor().claimTokens(address(this), rtToClaim);

    address _depositor = _DEPOSITOR_KEY.getAddress();
    require(msg.sender == _depositor, "Not depositor");
    for (uint i; i < length; ++i) {
      IERC20 rt = rtToClaim[i];
      uint balance = rt.balanceOf(address(this));
      if (balance != 0) {
        rt.safeTransfer(_depositor, balance);
      }
    }
  }

  function depositToPool(uint256 amount) internal override {
    if (amount > 0) {

      (uint balanceLocked, uint unlockTime) = _veBAL().locked(address(this));
      if (unlockTime == 0 && balanceLocked == 0) {
        _veBAL().create_lock(amount, block.timestamp + _MAX_LOCK);
      } else {
        _veBAL().increase_amount(amount);

        uint256 unlockAt = block.timestamp + _MAX_LOCK;
        uint256 unlockInWeeks = (unlockAt / _WEEK) * _WEEK;

        if (unlockInWeeks > unlockTime && unlockInWeeks - unlockTime > 2) {
          _veBAL().increase_unlock_time(unlockAt);
        }
      }
      _feeDistributor().checkpointUser(address(this));
    }
  }

  function withdrawAndClaimFromPool(uint256) internal pure override {
    revert("BSS: Withdraw forbidden");
  }

  function emergencyWithdrawFromPool() internal pure override {
    revert("BSS: Withdraw forbidden");
  }

  function readyToClaim() external view override returns (uint256[] memory) {
    uint256[] memory toClaim = new uint256[](_rewardTokens.length);
    return toClaim;
  }

  function poolTotalAmount() external view override returns (uint256) {
    return IERC20(_underlying()).balanceOf(_VE_BAL_KEY.getAddress());
  }

  function platform() external override pure returns (Platform) {
    return Platform.BALANCER;
  }

  function liquidateReward() internal pure override {
  }

}// ISC
pragma solidity 0.8.4;


contract StrategyBalStaking is BalStakingStrategyBase {


  address private constant _BPT_BAL_WETH = 0x5c6Ee304399DBdB9C8Ef030aB642B10820DB8F56;
  address private constant _BAL = 0xba100000625a3754423978a60c9317c58a424e3D;
  address private constant _WETH = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;
  address private constant _VE_BAL = 0xC128a9954e6c874eA3d62ce62B468bA073093F25;
  address private constant _FEE_DISTRIBUTOR = 0x26743984e3357eFC59f2fd6C1aFDC310335a61c9;
  address[] private _assets;
  address[] private _poolRewards;

  function initialize(
    address controller_,
    address vault_,
    address depositor_
  ) external initializer {

    _assets.push(_BAL);
    _assets.push(_WETH);
    _poolRewards.push(_BAL);
    BalStakingStrategyBase.initializeStrategy(
      controller_,
      _BPT_BAL_WETH,
      vault_,
      _poolRewards,
      _VE_BAL,
      depositor_,
      _FEE_DISTRIBUTOR
    );
  }

  function assets() external override view returns (address[] memory) {

    return _assets;
  }
}