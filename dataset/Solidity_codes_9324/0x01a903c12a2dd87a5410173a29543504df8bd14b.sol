
pragma solidity ^0.7.3;

interface IBasket {

    function transfer(address dst, uint256 amount) external returns (bool);


    function totalSupply() external view returns (uint256);


    function mint(uint256) external;


    function getOne() external view returns (address[] memory, uint256[] memory);


    function getAssetsAndBalances() external view returns (address[] memory, uint256[] memory);


    function burn(uint256) external;


    function viewMint(uint256 _amountOut) external view returns (uint256[] memory _amountsIn);

}

pragma solidity ^0.7.3;

interface ICToken {

    function _acceptAdmin() external returns (uint256);


    function _addReserves(uint256 addAmount) external returns (uint256);


    function _reduceReserves(uint256 reduceAmount) external returns (uint256);


    function _setComptroller(address newComptroller) external returns (uint256);


    function _setImplementation(
        address implementation_,
        bool allowResign,
        bytes memory becomeImplementationData
    ) external;


    function _setInterestRateModel(address newInterestRateModel) external returns (uint256);


    function _setPendingAdmin(address newPendingAdmin) external returns (uint256);


    function _setReserveFactor(uint256 newReserveFactorMantissa) external returns (uint256);


    function accrualBlockNumber() external view returns (uint256);


    function accrueInterest() external returns (uint256);


    function admin() external view returns (address);


    function allowance(address owner, address spender) external view returns (uint256);


    function approve(address spender, uint256 amount) external returns (bool);


    function balanceOf(address owner) external view returns (uint256);


    function balanceOfUnderlying(address owner) external returns (uint256);


    function borrow(uint256 borrowAmount) external returns (uint256);


    function borrowBalanceCurrent(address account) external returns (uint256);


    function borrowBalanceStored(address account) external view returns (uint256);


    function borrowIndex() external view returns (uint256);


    function borrowRatePerBlock() external view returns (uint256);


    function comptroller() external view returns (address);


    function decimals() external view returns (uint8);


    function delegateToImplementation(bytes memory data) external returns (bytes memory);


    function delegateToViewImplementation(bytes memory data) external view returns (bytes memory);


    function exchangeRateCurrent() external returns (uint256);


    function exchangeRateStored() external view returns (uint256);


    function getAccountSnapshot(address account)
        external
        view
        returns (
            uint256,
            uint256,
            uint256,
            uint256
        );


    function getCash() external view returns (uint256);


    function implementation() external view returns (address);


    function interestRateModel() external view returns (address);


    function isCToken() external view returns (bool);


    function liquidateBorrow(
        address borrower,
        uint256 repayAmount,
        address cTokenCollateral
    ) external returns (uint256);


    function mint(uint256 mintAmount) external returns (uint256);


    function name() external view returns (string memory);


    function pendingAdmin() external view returns (address);


    function redeem(uint256 redeemTokens) external returns (uint256);


    function redeemUnderlying(uint256 redeemAmount) external returns (uint256);


    function repayBorrow(uint256 repayAmount) external returns (uint256);


    function repayBorrowBehalf(address borrower, uint256 repayAmount) external returns (uint256);


    function reserveFactorMantissa() external view returns (uint256);


    function seize(
        address liquidator,
        address borrower,
        uint256 seizeTokens
    ) external returns (uint256);


    function supplyRatePerBlock() external view returns (uint256);


    function symbol() external view returns (string memory);


    function totalBorrows() external view returns (uint256);


    function totalBorrowsCurrent() external returns (uint256);


    function totalReserves() external view returns (uint256);


    function totalSupply() external view returns (uint256);


    function transfer(address dst, uint256 amount) external returns (bool);


    function transferFrom(
        address src,
        address dst,
        uint256 amount
    ) external returns (bool);


    function underlying() external view returns (address);

}

pragma solidity ^0.7.3;

interface IYearn {

    function initialize(
        address token,
        address governance,
        address rewards,
        string memory nameOverride,
        string memory symbolOverride
    ) external;


    function initialize(
        address token,
        address governance,
        address rewards,
        string memory nameOverride,
        string memory symbolOverride,
        address guardian
    ) external;


    function apiVersion() external pure returns (string memory);


    function setName(string memory name) external;


    function setSymbol(string memory symbol) external;


    function setGovernance(address governance) external;


    function acceptGovernance() external;


    function setManagement(address management) external;


    function setGuestList(address guestList) external;


    function setRewards(address rewards) external;


    function setLockedProfitDegration(uint256 degration) external;


    function setDepositLimit(uint256 limit) external;


    function setPerformanceFee(uint256 fee) external;


    function setManagementFee(uint256 fee) external;


    function setGuardian(address guardian) external;


    function setEmergencyShutdown(bool active) external;


    function setWithdrawalQueue(address[20] memory queue) external;


    function transfer(address receiver, uint256 amount) external returns (bool);


    function transferFrom(
        address sender,
        address receiver,
        uint256 amount
    ) external returns (bool);


    function approve(address spender, uint256 amount) external returns (bool);


    function increaseAllowance(address spender, uint256 amount) external returns (bool);


    function decreaseAllowance(address spender, uint256 amount) external returns (bool);


    function permit(
        address owner,
        address spender,
        uint256 amount,
        uint256 expiry,
        bytes memory signature
    ) external returns (bool);


    function totalAssets() external view returns (uint256);


    function deposit() external returns (uint256);


    function deposit(uint256 _amount) external returns (uint256);


    function deposit(uint256 _amount, address recipient) external returns (uint256);


    function maxAvailableShares() external view returns (uint256);


    function withdraw() external returns (uint256);


    function withdraw(uint256 maxShares) external returns (uint256);


    function withdraw(uint256 maxShares, address recipient) external returns (uint256);


    function withdraw(
        uint256 maxShares,
        address recipient,
        uint256 maxLoss
    ) external returns (uint256);


    function pricePerShare() external view returns (uint256);


    function addStrategy(
        address strategy,
        uint256 debtRatio,
        uint256 minDebtPerHarvest,
        uint256 maxDebtPerHarvest,
        uint256 performanceFee
    ) external;


    function updateStrategyDebtRatio(address strategy, uint256 debtRatio) external;


    function updateStrategyMinDebtPerHarvest(address strategy, uint256 minDebtPerHarvest) external;


    function updateStrategyMaxDebtPerHarvest(address strategy, uint256 maxDebtPerHarvest) external;


    function updateStrategyPerformanceFee(address strategy, uint256 performanceFee) external;


    function migrateStrategy(address oldVersion, address newVersion) external;


    function revokeStrategy() external;


    function revokeStrategy(address strategy) external;


    function addStrategyToQueue(address strategy) external;


    function removeStrategyFromQueue(address strategy) external;


    function debtOutstanding() external view returns (uint256);


    function debtOutstanding(address strategy) external view returns (uint256);


    function creditAvailable() external view returns (uint256);


    function creditAvailable(address strategy) external view returns (uint256);


    function availableDepositLimit() external view returns (uint256);


    function expectedReturn() external view returns (uint256);


    function expectedReturn(address strategy) external view returns (uint256);


    function report(
        uint256 gain,
        uint256 loss,
        uint256 _debtPayment
    ) external returns (uint256);


    function sweep(address token) external;


    function sweep(address token, uint256 amount) external;


    function name() external view returns (string memory);


    function symbol() external view returns (string memory);


    function decimals() external view returns (uint256);


    function precisionFactor() external view returns (uint256);


    function balanceOf(address arg0) external view returns (uint256);


    function allowance(address arg0, address arg1) external view returns (uint256);


    function totalSupply() external view returns (uint256);


    function token() external view returns (address);


    function governance() external view returns (address);


    function management() external view returns (address);


    function guardian() external view returns (address);


    function guestList() external view returns (address);


    function strategies(address arg0)
        external
        view
        returns (
            uint256 performanceFee,
            uint256 activation,
            uint256 debtRatio,
            uint256 minDebtPerHarvest,
            uint256 maxDebtPerHarvest,
            uint256 lastReport,
            uint256 totalDebt,
            uint256 totalGain,
            uint256 totalLoss
        );


    function withdrawalQueue(uint256 arg0) external view returns (address);


    function emergencyShutdown() external view returns (bool);


    function depositLimit() external view returns (uint256);


    function debtRatio() external view returns (uint256);


    function totalDebt() external view returns (uint256);


    function lastReport() external view returns (uint256);


    function activation() external view returns (uint256);


    function lockedProfit() external view returns (uint256);


    function lockedProfitDegration() external view returns (uint256);


    function rewards() external view returns (address);


    function managementFee() external view returns (uint256);


    function performanceFee() external view returns (uint256);


    function nonces(address arg0) external view returns (uint256);


    function DOMAIN_SEPARATOR() external view returns (bytes32);

}

pragma solidity ^0.7.3;

interface ILendingPoolV2 {

    function FLASHLOAN_PREMIUM_TOTAL() external view returns (uint256);


    function LENDINGPOOL_REVISION() external view returns (uint256);


    function MAX_NUMBER_RESERVES() external view returns (uint256);


    function MAX_STABLE_RATE_BORROW_SIZE_PERCENT() external view returns (uint256);


    function borrow(
        address asset,
        uint256 amount,
        uint256 interestRateMode,
        uint16 referralCode,
        address onBehalfOf
    ) external;


    function deposit(
        address asset,
        uint256 amount,
        address onBehalfOf,
        uint16 referralCode
    ) external;


    function finalizeTransfer(
        address asset,
        address from,
        address to,
        uint256 amount,
        uint256 balanceFromBefore,
        uint256 balanceToBefore
    ) external;


    function flashLoan(
        address receiverAddress,
        address[] memory assets,
        uint256[] memory amounts,
        uint256[] memory modes,
        address onBehalfOf,
        bytes memory params,
        uint16 referralCode
    ) external;


    function getAddressesProvider() external view returns (address);


    function getConfiguration(address asset) external view returns (uint256);


    function getReserveData(address asset)
        external
        view
        returns (
            uint256,
            uint128,
            uint128,
            uint128,
            uint128,
            uint128,
            uint40,
            address,
            address,
            address,
            address,
            uint8
        );


    function getReserveNormalizedIncome(address asset) external view returns (uint256);


    function getReserveNormalizedVariableDebt(address asset) external view returns (uint256);


    function getReservesList() external view returns (address[] memory);


    function getUserAccountData(address user)
        external
        view
        returns (
            uint256 totalCollateralETH,
            uint256 totalDebtETH,
            uint256 availableBorrowsETH,
            uint256 currentLiquidationThreshold,
            uint256 ltv,
            uint256 healthFactor
        );


    function initReserve(
        address asset,
        address aTokenAddress,
        address stableDebtAddress,
        address variableDebtAddress,
        address interestRateStrategyAddress
    ) external;


    function initialize(address provider) external;


    function liquidationCall(
        address collateralAsset,
        address debtAsset,
        address user,
        uint256 debtToCover,
        bool receiveAToken
    ) external;


    function paused() external view returns (bool);


    function rebalanceStableBorrowRate(address asset, address user) external;


    function repay(
        address asset,
        uint256 amount,
        uint256 rateMode,
        address onBehalfOf
    ) external returns (uint256);


    function setConfiguration(address asset, uint256 configuration) external;


    function setPause(bool val) external;


    function setReserveInterestRateStrategyAddress(address asset, address rateStrategyAddress) external;


    function setUserUseReserveAsCollateral(address asset, bool useAsCollateral) external;


    function swapBorrowRateMode(address asset, uint256 rateMode) external;


    function withdraw(
        address asset,
        uint256 amount,
        address to
    ) external returns (uint256);

}

pragma solidity ^0.7.3;

interface IATokenV2 {

    function ATOKEN_REVISION() external view returns (uint256);


    function DOMAIN_SEPARATOR() external view returns (bytes32);


    function EIP712_REVISION() external view returns (bytes memory);


    function PERMIT_TYPEHASH() external view returns (bytes32);


    function POOL() external view returns (address);


    function RESERVE_TREASURY_ADDRESS() external view returns (address);


    function UINT_MAX_VALUE() external view returns (uint256);


    function UNDERLYING_ASSET_ADDRESS() external view returns (address);


    function _nonces(address) external view returns (uint256);


    function allowance(address owner, address spender) external view returns (uint256);


    function approve(address spender, uint256 amount) external returns (bool);


    function balanceOf(address user) external view returns (uint256);


    function burn(
        address user,
        address receiverOfUnderlying,
        uint256 amount,
        uint256 index
    ) external;


    function decimals() external view returns (uint8);


    function decreaseAllowance(address spender, uint256 subtractedValue) external returns (bool);


    function getScaledUserBalanceAndSupply(address user) external view returns (uint256, uint256);


    function increaseAllowance(address spender, uint256 addedValue) external returns (bool);


    function initialize(
        uint8 underlyingAssetDecimals,
        string memory tokenName,
        string memory tokenSymbol
    ) external;


    function mint(
        address user,
        uint256 amount,
        uint256 index
    ) external returns (bool);


    function mintToTreasury(uint256 amount, uint256 index) external;


    function name() external view returns (string memory);


    function permit(
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external;


    function scaledBalanceOf(address user) external view returns (uint256);


    function scaledTotalSupply() external view returns (uint256);


    function symbol() external view returns (string memory);


    function totalSupply() external view returns (uint256);


    function transfer(address recipient, uint256 amount) external returns (bool);


    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);


    function transferOnLiquidation(
        address from,
        address to,
        uint256 value
    ) external;


    function transferUnderlyingTo(address target, uint256 amount) external returns (uint256);

}

pragma solidity ^0.7.3;

interface ICurveZapSimple {

    function add_liquidity(uint256[3] memory _deposit_amounts, uint256 _min_mint_amount) external;


    function add_liquidity(
        uint256[3] memory _deposit_amounts,
        uint256 _min_mint_amount,
        bool use_underlying
    ) external;


    function add_liquidity(uint256[4] memory _deposit_amounts, uint256 _min_mint_amount) external;


    function add_liquidity(
        address _pool,
        uint256[4] memory _deposit_amounts,
        uint256 _min_mint_amount
    ) external returns (uint256);


    function add_liquidity(
        address _pool,
        uint256[4] memory _deposit_amounts,
        uint256 _min_mint_amount,
        address _receiver
    ) external returns (uint256);


    function remove_liquidity_one_coin(
        uint256 _token_amount,
        int128 i,
        uint256 min_amount,
        bool _donate_dust
    ) external;


    function remove_liquidity_one_coin(
        uint256 _token_amount,
        int128 i,
        uint256 min_amount
    ) external;


    function remove_liquidity_one_coin(
        address pool,
        uint256 _token_amount,
        int128 i,
        uint256 min_amount,
        address _receiver
    ) external returns (uint256);


    function remove_liquidity_one_coin(
        uint256 _token_amount,
        int128 i,
        uint256 min_amount,
        address _receiver
    ) external returns (uint256);


    function calc_withdraw_one_coin(uint256 _token_amount, int128 i) external view returns (uint256);


    function calc_withdraw_one_coin(
        uint256 _token_amount,
        int128 i,
        bool use_underlying
    ) external view returns (uint256);


    function calc_withdraw_one_coin(
        address pool,
        uint256 _token_amount,
        int128 i
    ) external view returns (uint256);

}

pragma solidity ^0.7.3;

interface ICurvePool {

    function exchange(
        int128 i,
        int128 j,
        uint256 _dx,
        uint256 _min_dy
    ) external;


    function get_dy(
        int128 i,
        int128 j,
        uint256 _dx
    ) external view returns (uint256);


    function get_virtual_price() external view returns (uint256);

}

interface ICurveLINK {

    function A() external view returns (uint256);


    function A_precise() external view returns (uint256);


    function get_virtual_price() external view returns (uint256);


    function calc_token_amount(uint256[2] memory _amounts, bool _is_deposit) external view returns (uint256);


    function add_liquidity(uint256[2] memory _amounts, uint256 _min_mint_amount) external returns (uint256);


    function get_dy(
        int128 i,
        int128 j,
        uint256 _dx
    ) external view returns (uint256);


    function exchange(
        int128 i,
        int128 j,
        uint256 _dx,
        uint256 _min_dy
    ) external returns (uint256);


    function remove_liquidity(uint256 _amount, uint256[2] memory _min_amounts) external returns (uint256[2] memory);


    function remove_liquidity_imbalance(uint256[2] memory _amounts, uint256 _max_burn_amount)
        external
        returns (uint256);


    function calc_withdraw_one_coin(uint256 _token_amount, int128 i) external view returns (uint256);


    function remove_liquidity_one_coin(
        uint256 _token_amount,
        int128 i,
        uint256 _min_amount
    ) external returns (uint256);


    function ramp_A(uint256 _future_A, uint256 _future_time) external;


    function stop_ramp_A() external;


    function commit_new_fee(uint256 _new_fee, uint256 _new_admin_fee) external;


    function apply_new_fee() external;


    function revert_new_parameters() external;


    function commit_transfer_ownership(address _owner) external;


    function apply_transfer_ownership() external;


    function revert_transfer_ownership() external;


    function admin_balances(uint256 i) external view returns (uint256);


    function withdraw_admin_fees() external;


    function donate_admin_fees() external;


    function kill_me() external;


    function unkill_me() external;


    function coins(uint256 arg0) external view returns (address);


    function balances(uint256 arg0) external view returns (uint256);


    function fee() external view returns (uint256);


    function admin_fee() external view returns (uint256);


    function previous_balances(uint256 arg0) external view returns (uint256);


    function block_timestamp_last() external view returns (uint256);


    function owner() external view returns (address);


    function lp_token() external view returns (address);


    function initial_A() external view returns (uint256);


    function future_A() external view returns (uint256);


    function initial_A_time() external view returns (uint256);


    function future_A_time() external view returns (uint256);


    function admin_actions_deadline() external view returns (uint256);


    function transfer_ownership_deadline() external view returns (uint256);


    function future_fee() external view returns (uint256);


    function future_admin_fee() external view returns (uint256);


    function future_owner() external view returns (address);

}

interface ILinkGauge {

    function decimals() external view returns (uint256);


    function integrate_checkpoint() external view returns (uint256);


    function user_checkpoint(address addr) external returns (bool);


    function claimable_tokens(address addr) external returns (uint256);


    function claimable_reward(address _addr, address _token) external returns (uint256);


    function claim_rewards() external;


    function claim_rewards(address _addr) external;


    function claim_historic_rewards(address[8] memory _reward_tokens) external;


    function claim_historic_rewards(address[8] memory _reward_tokens, address _addr) external;


    function kick(address addr) external;


    function set_approve_deposit(address addr, bool can_deposit) external;


    function deposit(uint256 _value) external;


    function deposit(uint256 _value, address _addr) external;


    function withdraw(uint256 _value) external;


    function allowance(address _owner, address _spender) external view returns (uint256);


    function transfer(address _to, uint256 _value) external returns (bool);


    function transferFrom(
        address _from,
        address _to,
        uint256 _value
    ) external returns (bool);


    function approve(address _spender, uint256 _value) external returns (bool);


    function increaseAllowance(address _spender, uint256 _added_value) external returns (bool);


    function decreaseAllowance(address _spender, uint256 _subtracted_value) external returns (bool);


    function set_rewards(
        address _reward_contract,
        bytes32 _sigs,
        address[8] memory _reward_tokens
    ) external;


    function set_killed(bool _is_killed) external;


    function commit_transfer_ownership(address addr) external;


    function accept_transfer_ownership() external;


    function minter() external view returns (address);


    function crv_token() external view returns (address);


    function lp_token() external view returns (address);


    function controller() external view returns (address);


    function voting_escrow() external view returns (address);


    function future_epoch_time() external view returns (uint256);


    function balanceOf(address arg0) external view returns (uint256);


    function totalSupply() external view returns (uint256);


    function name() external view returns (string memory);


    function symbol() external view returns (string memory);


    function approved_to_deposit(address arg0, address arg1) external view returns (bool);


    function working_balances(address arg0) external view returns (uint256);


    function working_supply() external view returns (uint256);


    function period() external view returns (int128);


    function period_timestamp(uint256 arg0) external view returns (uint256);


    function integrate_inv_supply(uint256 arg0) external view returns (uint256);


    function integrate_inv_supply_of(address arg0) external view returns (uint256);


    function integrate_checkpoint_of(address arg0) external view returns (uint256);


    function integrate_fraction(address arg0) external view returns (uint256);


    function inflation_rate() external view returns (uint256);


    function reward_contract() external view returns (address);


    function reward_tokens(uint256 arg0) external view returns (address);


    function reward_integral(address arg0) external view returns (uint256);


    function reward_integral_for(address arg0, address arg1) external view returns (uint256);


    function admin() external view returns (address);


    function future_admin() external view returns (address);


    function is_killed() external view returns (bool);

}
pragma solidity ^0.7.0;

library ABDKMath64x64 {

  int128 private constant MIN_64x64 = -0x80000000000000000000000000000000;

  int128 private constant MAX_64x64 = 0x7FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF;

  function fromInt (int256 x) internal pure returns (int128) {
    require (x >= -0x8000000000000000 && x <= 0x7FFFFFFFFFFFFFFF);
    return int128 (x << 64);
  }

  function toInt (int128 x) internal pure returns (int64) {
    return int64 (x >> 64);
  }

  function fromUInt (uint256 x) internal pure returns (int128) {
    require (x <= 0x7FFFFFFFFFFFFFFF);
    return int128 (x << 64);
  }

  function toUInt (int128 x) internal pure returns (uint64) {
    require (x >= 0);
    return uint64 (x >> 64);
  }

  function from128x128 (int256 x) internal pure returns (int128) {
    int256 result = x >> 64;
    require (result >= MIN_64x64 && result <= MAX_64x64);
    return int128 (result);
  }

  function to128x128 (int128 x) internal pure returns (int256) {
    return int256 (x) << 64;
  }

  function add (int128 x, int128 y) internal pure returns (int128) {
    int256 result = int256(x) + y;
    require (result >= MIN_64x64 && result <= MAX_64x64);
    return int128 (result);
  }

  function sub (int128 x, int128 y) internal pure returns (int128) {
    int256 result = int256(x) - y;
    require (result >= MIN_64x64 && result <= MAX_64x64);
    return int128 (result);
  }

  function mul (int128 x, int128 y) internal pure returns (int128) {
    int256 result = int256(x) * y >> 64;
    require (result >= MIN_64x64 && result <= MAX_64x64);
    return int128 (result);
  }

  function muli (int128 x, int256 y) internal pure returns (int256) {
    if (x == MIN_64x64) {
      require (y >= -0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF &&
        y <= 0x1000000000000000000000000000000000000000000000000);
      return -y << 63;
    } else {
      bool negativeResult = false;
      if (x < 0) {
        x = -x;
        negativeResult = true;
      }
      if (y < 0) {
        y = -y; // We rely on overflow behavior here
        negativeResult = !negativeResult;
      }
      uint256 absoluteResult = mulu (x, uint256 (y));
      if (negativeResult) {
        require (absoluteResult <=
          0x8000000000000000000000000000000000000000000000000000000000000000);
        return -int256 (absoluteResult); // We rely on overflow behavior here
      } else {
        require (absoluteResult <=
          0x7FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF);
        return int256 (absoluteResult);
      }
    }
  }

  function mulu (int128 x, uint256 y) internal pure returns (uint256) {
    if (y == 0) return 0;

    require (x >= 0);

    uint256 lo = (uint256 (x) * (y & 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF)) >> 64;
    uint256 hi = uint256 (x) * (y >> 128);

    require (hi <= 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF);
    hi <<= 64;

    require (hi <=
      0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF - lo);
    return hi + lo;
  }

  function div (int128 x, int128 y) internal pure returns (int128) {
    require (y != 0);
    int256 result = (int256 (x) << 64) / y;
    require (result >= MIN_64x64 && result <= MAX_64x64);
    return int128 (result);
  }

  function divi (int256 x, int256 y) internal pure returns (int128) {
    require (y != 0);

    bool negativeResult = false;
    if (x < 0) {
      x = -x; // We rely on overflow behavior here
      negativeResult = true;
    }
    if (y < 0) {
      y = -y; // We rely on overflow behavior here
      negativeResult = !negativeResult;
    }
    uint128 absoluteResult = divuu (uint256 (x), uint256 (y));
    if (negativeResult) {
      require (absoluteResult <= 0x80000000000000000000000000000000);
      return -int128 (absoluteResult); // We rely on overflow behavior here
    } else {
      require (absoluteResult <= 0x7FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF);
      return int128 (absoluteResult); // We rely on overflow behavior here
    }
  }

  function divu (uint256 x, uint256 y) internal pure returns (int128) {
    require (y != 0);
    uint128 result = divuu (x, y);
    require (result <= uint128 (MAX_64x64));
    return int128 (result);
  }

  function neg (int128 x) internal pure returns (int128) {
    require (x != MIN_64x64);
    return -x;
  }

  function abs (int128 x) internal pure returns (int128) {
    require (x != MIN_64x64);
    return x < 0 ? -x : x;
  }

  function inv (int128 x) internal pure returns (int128) {
    require (x != 0);
    int256 result = int256 (0x100000000000000000000000000000000) / x;
    require (result >= MIN_64x64 && result <= MAX_64x64);
    return int128 (result);
  }

  function avg (int128 x, int128 y) internal pure returns (int128) {
    return int128 ((int256 (x) + int256 (y)) >> 1);
  }

  function gavg (int128 x, int128 y) internal pure returns (int128) {
    int256 m = int256 (x) * int256 (y);
    require (m >= 0);
    require (m <
        0x4000000000000000000000000000000000000000000000000000000000000000);
    return int128 (sqrtu (uint256 (m)));
  }

  function pow (int128 x, uint256 y) internal pure returns (int128) {
    uint256 absoluteResult;
    bool negativeResult = false;
    if (x >= 0) {
      absoluteResult = powu (uint256 (x) << 63, y);
    } else {
      absoluteResult = powu (uint256 (uint128 (-x)) << 63, y);
      negativeResult = y & 1 > 0;
    }

    absoluteResult >>= 63;

    if (negativeResult) {
      require (absoluteResult <= 0x80000000000000000000000000000000);
      return -int128 (absoluteResult); // We rely on overflow behavior here
    } else {
      require (absoluteResult <= 0x7FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF);
      return int128 (absoluteResult); // We rely on overflow behavior here
    }
  }

  function sqrt (int128 x) internal pure returns (int128) {
    require (x >= 0);
    return int128 (sqrtu (uint256 (x) << 64));
  }

  function log_2 (int128 x) internal pure returns (int128) {
    require (x > 0);

    int256 msb = 0;
    int256 xc = x;
    if (xc >= 0x10000000000000000) { xc >>= 64; msb += 64; }
    if (xc >= 0x100000000) { xc >>= 32; msb += 32; }
    if (xc >= 0x10000) { xc >>= 16; msb += 16; }
    if (xc >= 0x100) { xc >>= 8; msb += 8; }
    if (xc >= 0x10) { xc >>= 4; msb += 4; }
    if (xc >= 0x4) { xc >>= 2; msb += 2; }
    if (xc >= 0x2) msb += 1;  // No need to shift xc anymore

    int256 result = msb - 64 << 64;
    uint256 ux = uint256 (x) << uint256 (127 - msb);
    for (int256 bit = 0x8000000000000000; bit > 0; bit >>= 1) {
      ux *= ux;
      uint256 b = ux >> 255;
      ux >>= 127 + b;
      result += bit * int256 (b);
    }

    return int128 (result);
  }

  function ln (int128 x) internal pure returns (int128) {
    require (x > 0);

    return int128 (
        uint256 (log_2 (x)) * 0xB17217F7D1CF79ABC9E3B39803F2F6AF >> 128);
  }

  function exp_2 (int128 x) internal pure returns (int128) {
    require (x < 0x400000000000000000); // Overflow

    if (x < -0x400000000000000000) return 0; // Underflow

    uint256 result = 0x80000000000000000000000000000000;

    if (x & 0x8000000000000000 > 0)
      result = result * 0x16A09E667F3BCC908B2FB1366EA957D3E >> 128;
    if (x & 0x4000000000000000 > 0)
      result = result * 0x1306FE0A31B7152DE8D5A46305C85EDEC >> 128;
    if (x & 0x2000000000000000 > 0)
      result = result * 0x1172B83C7D517ADCDF7C8C50EB14A791F >> 128;
    if (x & 0x1000000000000000 > 0)
      result = result * 0x10B5586CF9890F6298B92B71842A98363 >> 128;
    if (x & 0x800000000000000 > 0)
      result = result * 0x1059B0D31585743AE7C548EB68CA417FD >> 128;
    if (x & 0x400000000000000 > 0)
      result = result * 0x102C9A3E778060EE6F7CACA4F7A29BDE8 >> 128;
    if (x & 0x200000000000000 > 0)
      result = result * 0x10163DA9FB33356D84A66AE336DCDFA3F >> 128;
    if (x & 0x100000000000000 > 0)
      result = result * 0x100B1AFA5ABCBED6129AB13EC11DC9543 >> 128;
    if (x & 0x80000000000000 > 0)
      result = result * 0x10058C86DA1C09EA1FF19D294CF2F679B >> 128;
    if (x & 0x40000000000000 > 0)
      result = result * 0x1002C605E2E8CEC506D21BFC89A23A00F >> 128;
    if (x & 0x20000000000000 > 0)
      result = result * 0x100162F3904051FA128BCA9C55C31E5DF >> 128;
    if (x & 0x10000000000000 > 0)
      result = result * 0x1000B175EFFDC76BA38E31671CA939725 >> 128;
    if (x & 0x8000000000000 > 0)
      result = result * 0x100058BA01FB9F96D6CACD4B180917C3D >> 128;
    if (x & 0x4000000000000 > 0)
      result = result * 0x10002C5CC37DA9491D0985C348C68E7B3 >> 128;
    if (x & 0x2000000000000 > 0)
      result = result * 0x1000162E525EE054754457D5995292026 >> 128;
    if (x & 0x1000000000000 > 0)
      result = result * 0x10000B17255775C040618BF4A4ADE83FC >> 128;
    if (x & 0x800000000000 > 0)
      result = result * 0x1000058B91B5BC9AE2EED81E9B7D4CFAB >> 128;
    if (x & 0x400000000000 > 0)
      result = result * 0x100002C5C89D5EC6CA4D7C8ACC017B7C9 >> 128;
    if (x & 0x200000000000 > 0)
      result = result * 0x10000162E43F4F831060E02D839A9D16D >> 128;
    if (x & 0x100000000000 > 0)
      result = result * 0x100000B1721BCFC99D9F890EA06911763 >> 128;
    if (x & 0x80000000000 > 0)
      result = result * 0x10000058B90CF1E6D97F9CA14DBCC1628 >> 128;
    if (x & 0x40000000000 > 0)
      result = result * 0x1000002C5C863B73F016468F6BAC5CA2B >> 128;
    if (x & 0x20000000000 > 0)
      result = result * 0x100000162E430E5A18F6119E3C02282A5 >> 128;
    if (x & 0x10000000000 > 0)
      result = result * 0x1000000B1721835514B86E6D96EFD1BFE >> 128;
    if (x & 0x8000000000 > 0)
      result = result * 0x100000058B90C0B48C6BE5DF846C5B2EF >> 128;
    if (x & 0x4000000000 > 0)
      result = result * 0x10000002C5C8601CC6B9E94213C72737A >> 128;
    if (x & 0x2000000000 > 0)
      result = result * 0x1000000162E42FFF037DF38AA2B219F06 >> 128;
    if (x & 0x1000000000 > 0)
      result = result * 0x10000000B17217FBA9C739AA5819F44F9 >> 128;
    if (x & 0x800000000 > 0)
      result = result * 0x1000000058B90BFCDEE5ACD3C1CEDC823 >> 128;
    if (x & 0x400000000 > 0)
      result = result * 0x100000002C5C85FE31F35A6A30DA1BE50 >> 128;
    if (x & 0x200000000 > 0)
      result = result * 0x10000000162E42FF0999CE3541B9FFFCF >> 128;
    if (x & 0x100000000 > 0)
      result = result * 0x100000000B17217F80F4EF5AADDA45554 >> 128;
    if (x & 0x80000000 > 0)
      result = result * 0x10000000058B90BFBF8479BD5A81B51AD >> 128;
    if (x & 0x40000000 > 0)
      result = result * 0x1000000002C5C85FDF84BD62AE30A74CC >> 128;
    if (x & 0x20000000 > 0)
      result = result * 0x100000000162E42FEFB2FED257559BDAA >> 128;
    if (x & 0x10000000 > 0)
      result = result * 0x1000000000B17217F7D5A7716BBA4A9AE >> 128;
    if (x & 0x8000000 > 0)
      result = result * 0x100000000058B90BFBE9DDBAC5E109CCE >> 128;
    if (x & 0x4000000 > 0)
      result = result * 0x10000000002C5C85FDF4B15DE6F17EB0D >> 128;
    if (x & 0x2000000 > 0)
      result = result * 0x1000000000162E42FEFA494F1478FDE05 >> 128;
    if (x & 0x1000000 > 0)
      result = result * 0x10000000000B17217F7D20CF927C8E94C >> 128;
    if (x & 0x800000 > 0)
      result = result * 0x1000000000058B90BFBE8F71CB4E4B33D >> 128;
    if (x & 0x400000 > 0)
      result = result * 0x100000000002C5C85FDF477B662B26945 >> 128;
    if (x & 0x200000 > 0)
      result = result * 0x10000000000162E42FEFA3AE53369388C >> 128;
    if (x & 0x100000 > 0)
      result = result * 0x100000000000B17217F7D1D351A389D40 >> 128;
    if (x & 0x80000 > 0)
      result = result * 0x10000000000058B90BFBE8E8B2D3D4EDE >> 128;
    if (x & 0x40000 > 0)
      result = result * 0x1000000000002C5C85FDF4741BEA6E77E >> 128;
    if (x & 0x20000 > 0)
      result = result * 0x100000000000162E42FEFA39FE95583C2 >> 128;
    if (x & 0x10000 > 0)
      result = result * 0x1000000000000B17217F7D1CFB72B45E1 >> 128;
    if (x & 0x8000 > 0)
      result = result * 0x100000000000058B90BFBE8E7CC35C3F0 >> 128;
    if (x & 0x4000 > 0)
      result = result * 0x10000000000002C5C85FDF473E242EA38 >> 128;
    if (x & 0x2000 > 0)
      result = result * 0x1000000000000162E42FEFA39F02B772C >> 128;
    if (x & 0x1000 > 0)
      result = result * 0x10000000000000B17217F7D1CF7D83C1A >> 128;
    if (x & 0x800 > 0)
      result = result * 0x1000000000000058B90BFBE8E7BDCBE2E >> 128;
    if (x & 0x400 > 0)
      result = result * 0x100000000000002C5C85FDF473DEA871F >> 128;
    if (x & 0x200 > 0)
      result = result * 0x10000000000000162E42FEFA39EF44D91 >> 128;
    if (x & 0x100 > 0)
      result = result * 0x100000000000000B17217F7D1CF79E949 >> 128;
    if (x & 0x80 > 0)
      result = result * 0x10000000000000058B90BFBE8E7BCE544 >> 128;
    if (x & 0x40 > 0)
      result = result * 0x1000000000000002C5C85FDF473DE6ECA >> 128;
    if (x & 0x20 > 0)
      result = result * 0x100000000000000162E42FEFA39EF366F >> 128;
    if (x & 0x10 > 0)
      result = result * 0x1000000000000000B17217F7D1CF79AFA >> 128;
    if (x & 0x8 > 0)
      result = result * 0x100000000000000058B90BFBE8E7BCD6D >> 128;
    if (x & 0x4 > 0)
      result = result * 0x10000000000000002C5C85FDF473DE6B2 >> 128;
    if (x & 0x2 > 0)
      result = result * 0x1000000000000000162E42FEFA39EF358 >> 128;
    if (x & 0x1 > 0)
      result = result * 0x10000000000000000B17217F7D1CF79AB >> 128;

    result >>= uint256 (63 - (x >> 64));
    require (result <= uint256 (MAX_64x64));

    return int128 (result);
  }

  function exp (int128 x) internal pure returns (int128) {
    require (x < 0x400000000000000000); // Overflow

    if (x < -0x400000000000000000) return 0; // Underflow

    return exp_2 (
        int128 (int256 (x) * 0x171547652B82FE1777D0FFDA0D23A7D12 >> 128));
  }

  function divuu (uint256 x, uint256 y) private pure returns (uint128) {
    require (y != 0);

    uint256 result;

    if (x <= 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF)
      result = (x << 64) / y;
    else {
      uint256 msb = 192;
      uint256 xc = x >> 192;
      if (xc >= 0x100000000) { xc >>= 32; msb += 32; }
      if (xc >= 0x10000) { xc >>= 16; msb += 16; }
      if (xc >= 0x100) { xc >>= 8; msb += 8; }
      if (xc >= 0x10) { xc >>= 4; msb += 4; }
      if (xc >= 0x4) { xc >>= 2; msb += 2; }
      if (xc >= 0x2) msb += 1;  // No need to shift xc anymore

      result = (x << 255 - msb) / ((y - 1 >> msb - 191) + 1);
      require (result <= 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF);

      uint256 hi = result * (y >> 128);
      uint256 lo = result * (y & 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF);

      uint256 xh = x >> 192;
      uint256 xl = x << 64;

      if (xl < lo) xh -= 1;
      xl -= lo; // We rely on overflow behavior here
      lo = hi << 128;
      if (xl < lo) xh -= 1;
      xl -= lo; // We rely on overflow behavior here

      assert (xh == hi >> 128);

      result += xl / y;
    }

    require (result <= 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF);
    return uint128 (result);
  }

  function powu (uint256 x, uint256 y) private pure returns (uint256) {
    if (y == 0) return 0x80000000000000000000000000000000;
    else if (x == 0) return 0;
    else {
      int256 msb = 0;
      uint256 xc = x;
      if (xc >= 0x100000000000000000000000000000000) { xc >>= 128; msb += 128; }
      if (xc >= 0x10000000000000000) { xc >>= 64; msb += 64; }
      if (xc >= 0x100000000) { xc >>= 32; msb += 32; }
      if (xc >= 0x10000) { xc >>= 16; msb += 16; }
      if (xc >= 0x100) { xc >>= 8; msb += 8; }
      if (xc >= 0x10) { xc >>= 4; msb += 4; }
      if (xc >= 0x4) { xc >>= 2; msb += 2; }
      if (xc >= 0x2) msb += 1;  // No need to shift xc anymore

      int256 xe = msb - 127;
      if (xe > 0) x >>= uint256 (xe);
      else x <<= uint256 (-xe);

      uint256 result = 0x80000000000000000000000000000000;
      int256 re = 0;

      while (y > 0) {
        if (y & 1 > 0) {
          result = result * x;
          y -= 1;
          re += xe;
          if (result >=
            0x8000000000000000000000000000000000000000000000000000000000000000) {
            result >>= 128;
            re += 1;
          } else result >>= 127;
          if (re < -127) return 0; // Underflow
          require (re < 128); // Overflow
        } else {
          x = x * x;
          y >>= 1;
          xe <<= 1;
          if (x >=
            0x8000000000000000000000000000000000000000000000000000000000000000) {
            x >>= 128;
            xe += 1;
          } else x >>= 127;
          if (xe < -127) return 0; // Underflow
          require (xe < 128); // Overflow
        }
      }

      if (re > 0) result <<= uint256 (re);
      else if (re < 0) result >>= uint256 (-re);

      return result;
    }
  }

  function sqrtu (uint256 x) private pure returns (uint128) {
    if (x == 0) return 0;
    else {
      uint256 xx = x;
      uint256 r = 1;
      if (xx >= 0x100000000000000000000000000000000) { xx >>= 128; r <<= 64; }
      if (xx >= 0x10000000000000000) { xx >>= 64; r <<= 32; }
      if (xx >= 0x100000000) { xx >>= 32; r <<= 16; }
      if (xx >= 0x10000) { xx >>= 16; r <<= 8; }
      if (xx >= 0x100) { xx >>= 8; r <<= 4; }
      if (xx >= 0x10) { xx >>= 4; r <<= 2; }
      if (xx >= 0x8) { r <<= 1; }
      r = (r + x / r) >> 1;
      r = (r + x / r) >> 1;
      r = (r + x / r) >> 1;
      r = (r + x / r) >> 1;
      r = (r + x / r) >> 1;
      r = (r + x / r) >> 1;
      r = (r + x / r) >> 1; // Seven iterations should be enough
      uint256 r1 = x / r;
      return uint128 (r < r1 ? r : r1);
    }
  }
}// MIT

pragma solidity >=0.6.0 <0.8.0;

abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

pragma solidity >=0.6.0 <0.8.0;

interface IERC20 {

    function totalSupply() external view returns (uint256);


    function balanceOf(address account) external view returns (uint256);


    function transfer(address recipient, uint256 amount) external returns (bool);


    function allowance(address owner, address spender) external view returns (uint256);


    function approve(address spender, uint256 amount) external returns (bool);


    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);


    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}

pragma solidity >=0.6.0 <0.8.0;

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
}

pragma solidity >=0.6.0 <0.8.0;


contract ERC20 is Context, IERC20 {

    using SafeMath for uint256;

    mapping (address => uint256) private _balances;

    mapping (address => mapping (address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;
    uint8 private _decimals;

    constructor (string memory name_, string memory symbol_) public {
        _name = name_;
        _symbol = symbol_;
        _decimals = 18;
    }

    function name() public view virtual returns (string memory) {

        return _name;
    }

    function symbol() public view virtual returns (string memory) {

        return _symbol;
    }

    function decimals() public view virtual returns (uint8) {

        return _decimals;
    }

    function totalSupply() public view virtual override returns (uint256) {

        return _totalSupply;
    }

    function balanceOf(address account) public view virtual override returns (uint256) {

        return _balances[account];
    }

    function transfer(address recipient, uint256 amount) public virtual override returns (bool) {

        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function allowance(address owner, address spender) public view virtual override returns (uint256) {

        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public virtual override returns (bool) {

        _approve(_msgSender(), spender, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) public virtual override returns (bool) {

        _transfer(sender, recipient, amount);
        _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount, "ERC20: transfer amount exceeds allowance"));
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {

        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].add(addedValue));
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {

        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].sub(subtractedValue, "ERC20: decreased allowance below zero"));
        return true;
    }

    function _transfer(address sender, address recipient, uint256 amount) internal virtual {

        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(sender, recipient, amount);

        _balances[sender] = _balances[sender].sub(amount, "ERC20: transfer amount exceeds balance");
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
    }

    function _mint(address account, uint256 amount) internal virtual {

        require(account != address(0), "ERC20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply = _totalSupply.add(amount);
        _balances[account] = _balances[account].add(amount);
        emit Transfer(address(0), account, amount);
    }

    function _burn(address account, uint256 amount) internal virtual {

        require(account != address(0), "ERC20: burn from the zero address");

        _beforeTokenTransfer(account, address(0), amount);

        _balances[account] = _balances[account].sub(amount, "ERC20: burn amount exceeds balance");
        _totalSupply = _totalSupply.sub(amount);
        emit Transfer(account, address(0), amount);
    }

    function _approve(address owner, address spender, uint256 amount) internal virtual {

        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _setupDecimals(uint8 decimals_) internal virtual {

        _decimals = decimals_;
    }

    function _beforeTokenTransfer(address from, address to, uint256 amount) internal virtual { }

}

pragma solidity >=0.6.2 <0.8.0;

library Address {
    function isContract(address account) internal view returns (bool) {

        uint256 size;
        assembly { size := extcodesize(account) }
        return size > 0;
    }

    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");

        (bool success, ) = recipient.call{ value: amount }("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
      return functionCall(target, data, "Address: low-level call failed");
    }

    function functionCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0, errorMessage);
    }

    function functionCallWithValue(address target, bytes memory data, uint256 value) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    function functionCallWithValue(address target, bytes memory data, uint256 value, string memory errorMessage) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{ value: value }(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {
        return functionStaticCall(target, data, "Address: low-level static call failed");
    }

    function functionStaticCall(address target, bytes memory data, string memory errorMessage) internal view returns (bytes memory) {
        require(isContract(target), "Address: static call to non-contract");

        (bool success, bytes memory returndata) = target.staticcall(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionDelegateCall(target, data, "Address: low-level delegate call failed");
    }

    function functionDelegateCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {
        require(isContract(target), "Address: delegate call to non-contract");

        (bool success, bytes memory returndata) = target.delegatecall(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function _verifyCallResult(bool success, bytes memory returndata, string memory errorMessage) private pure returns(bytes memory) {
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
}

pragma solidity >=0.6.0 <0.8.0;


library SafeERC20 {
    using SafeMath for uint256;
    using Address for address;

    function safeTransfer(IERC20 token, address to, uint256 value) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(IERC20 token, address from, address to, uint256 value) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    function safeApprove(IERC20 token, address spender, uint256 value) internal {
        require((value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(IERC20 token, address spender, uint256 value) internal {
        uint256 newAllowance = token.allowance(address(this), spender).add(value);
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(IERC20 token, address spender, uint256 value) internal {
        uint256 newAllowance = token.allowance(address(this), spender).sub(value, "SafeERC20: decreased allowance below zero");
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function _callOptionalReturn(IERC20 token, bytes memory data) private {

        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) { // Return data is optional
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}

pragma solidity >=0.6.0 <0.8.0;

abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor () internal {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

pragma solidity ^0.7.3;




contract BMIZapper is Ownable {
    using SafeERC20 for IERC20;
    using SafeMath for uint256;

    using ABDKMath64x64 for int128;
    using ABDKMath64x64 for uint256;

    address constant AAVE_LENDING_POOL_V2 = 0x7d2768dE32b0b80b7a3454c06BdAc94A69DDc7A9;


    address constant BMI = 0x0aC00355F80E289f53BF368C9Bdb70f5c114C44B;

    address constant DAI = 0x6B175474E89094C44Da98b954EedeAC495271d0F;
    address constant USDC = 0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48;
    address constant USDT = 0xdAC17F958D2ee523a2206206994597C13D831ec7;
    address constant TUSD = 0x0000000000085d4780B73119b644AE5ecd22b376;
    address constant SUSD = 0x57Ab1ec28D129707052df4dF418D58a2D46d5f51;
    address constant BUSD = 0x4Fabb145d64652a948d72533023f6E7A623C7C53;
    address constant USDP = 0x1456688345527bE1f37E9e627DA0837D6f08C925;
    address constant FRAX = 0x853d955aCEf822Db058eb8505911ED77F175b99e;
    address constant ALUSD = 0xBC6DA0FE9aD5f3b0d58160288917AA56653660E9;
    address constant LUSD = 0x5f98805A4E8be255a32880FDeC7F6728C6568bA0;
    address constant USDN = 0x674C6Ad92Fd080e4004b2312b45f796a192D27a0;

    address constant yDAI = 0x19D3364A399d251E894aC732651be8B0E4e85001;
    address constant yUSDC = 0x5f18C75AbDAe578b483E5F43f12a39cF75b973a9;
    address constant yUSDT = 0x7Da96a3891Add058AdA2E826306D812C638D87a7;
    address constant yTUSD = 0x37d19d1c4E1fa9DC47bD1eA12f742a0887eDa74a;
    address constant ySUSD = 0xa5cA62D95D24A4a350983D5B8ac4EB8638887396;

    address constant yCRV = 0x4B5BfD52124784745c1071dcB244C6688d2533d3; // Y Pool
    address constant ycrvSUSD = 0x5a770DbD3Ee6bAF2802D29a901Ef11501C44797A;
    address constant ycrvYBUSD = 0x8ee57c05741aA9DB947A744E713C15d4d19D8822;
    address constant ycrvBUSD = 0x6Ede7F19df5df6EF23bD5B9CeDb651580Bdf56Ca;
    address constant ycrvUSDP = 0xC4dAf3b5e2A9e93861c3FBDd25f1e943B8D87417;
    address constant ycrvFRAX = 0xB4AdA607B9d6b2c9Ee07A275e9616B84AC560139;
    address constant ycrvALUSD = 0xA74d4B67b3368E83797a35382AFB776bAAE4F5C8;
    address constant ycrvLUSD = 0x5fA5B62c8AF877CB37031e0a3B2f34A78e3C56A6;
    address constant ycrvUSDN = 0x3B96d491f067912D18563d56858Ba7d6EC67a6fa;
    address constant ycrvIB = 0x27b7b1ad7288079A66d12350c828D3C00A6F07d7;
    address constant ycrvThree = 0x84E13785B5a27879921D6F685f041421C7F482dA;
    address constant ycrvDUSD = 0x30FCf7c6cDfC46eC237783D94Fc78553E79d4E9C;
    address constant ycrvMUSD = 0x8cc94ccd0f3841a468184aCA3Cc478D2148E1757;
    address constant ycrvUST = 0x1C6a9783F812b3Af3aBbf7de64c3cD7CC7D1af44;

    address constant aDAI = 0x028171bCA77440897B824Ca71D1c56caC55b68A3;
    address constant aUSDC = 0xBcca60bB61934080951369a648Fb03DF4F96263C;
    address constant aUSDT = 0x3Ed3B47Dd13EC9a98b44e6204A523E766B225811;
    address constant aTUSD = 0x101cc05f4A51C0319f570d5E146a8C625198e636;
    address constant aSUSD = 0x6C5024Cd4F8A59110119C56f8933403A539555EB;

    address constant cDAI = 0x5d3a536E4D6DbD6114cc1Ead35777bAB948E3643;
    address constant cUSDC = 0x39AA39c021dfbaE8faC545936693aC917d5E7563;
    address constant cUSDT = 0xf650C3d88D12dB855b8bf7D11Be6C55A4e07dCC9;
    address constant cTUSD = 0x12392F67bdf24faE0AF363c24aC620a2f67DAd86;

    address constant crvY = 0xdF5e0e81Dff6FAF3A7e52BA697820c5e32D806A8;
    address constant crvYPool = 0x45F783CCE6B7FF23B2ab2D70e416cdb7D6055f51;
    address constant crvYZap = 0xbBC81d23Ea2c3ec7e56D39296F0cbB648873a5d3;

    address constant crvSUSD = 0xC25a3A3b969415c80451098fa907EC722572917F;
    address constant crvSUSDPool = 0xA5407eAE9Ba41422680e2e00537571bcC53efBfD;
    address constant crvSUSDZap = 0xFCBa3E75865d2d561BE8D220616520c171F12851;

    address constant crvYBUSD = 0x3B3Ac5386837Dc563660FB6a0937DFAa5924333B;
    address constant crvYBUSDPool = 0x79a8C46DeA5aDa233ABaFFD40F3A0A2B1e5A4F27;
    address constant crvYBUSDZap = 0xb6c057591E073249F2D9D88Ba59a46CFC9B59EdB;

    address constant crvThree = 0x6c3F90f043a72FA612cbac8115EE7e52BDe6E490;
    address constant crvThreePool = 0xbEbc44782C7dB0a1A60Cb6fe97d0b483032FF1C7;

    address constant crvUSDP = 0x7Eb40E450b9655f4B3cC4259BCC731c63ff55ae6;
    address constant crvUSDPPool = 0x42d7025938bEc20B69cBae5A77421082407f053A;
    address constant crvUSDPZap = 0x3c8cAee4E09296800f8D29A68Fa3837e2dae4940;

    address constant crvDUSD = 0x3a664Ab939FD8482048609f652f9a0B0677337B9;
    address constant crvDUSDPool = 0x8038C01A0390a8c547446a0b2c18fc9aEFEcc10c;
    address constant crvDUSDZap = 0x61E10659fe3aa93d036d099405224E4Ac24996d0;

    address constant crvMUSD = 0x1AEf73d49Dedc4b1778d0706583995958Dc862e6;
    address constant crvMUSDPool = 0x8474DdbE98F5aA3179B3B3F5942D724aFcdec9f6;
    address constant crvMUSDZap = 0x803A2B40c5a9BB2B86DD630B274Fa2A9202874C2;

    address constant crvUST = 0x94e131324b6054c0D789b190b2dAC504e4361b53;
    address constant crvUSTPool = 0x890f4e345B1dAED0367A877a1612f86A1f86985f;
    address constant crvUSTZap = 0xB0a0716841F2Fc03fbA72A891B8Bb13584F52F2d;

    address constant crvUSDN = 0x4f3E8F405CF5aFC05D68142F3783bDfE13811522;
    address constant crvUSDNPool = 0x0f9cb53Ebe405d49A0bbdBD291A65Ff571bC83e1;
    address constant crvUSDNZap = 0x094d12e5b541784701FD8d65F11fc0598FBC6332;

    address constant crvIB = 0x5282a4eF67D9C33135340fB3289cc1711c13638C;
    address constant crvIBPool = 0x2dded6Da1BF5DBdF597C45fcFaa3194e53EcfeAF;

    address constant crvBUSD = 0x4807862AA8b2bF68830e4C8dc86D0e9A998e085a;
    address constant crvFRAX = 0xd632f22692FaC7611d2AA1C0D552930D43CAEd3B;
    address constant crvALUSD = 0x43b4FdFD4Ff969587185cDB6f0BD875c5Fc83f8c;
    address constant crvLUSD = 0xEd279fDD11cA84bEef15AF5D39BB4d4bEE23F0cA;

    address constant crvMetaZapper = 0xA79828DF1850E8a3A3064576f380D90aECDD3359;


    constructor() {}

    function recoverERC20(address _token) public onlyOwner {
        IERC20(_token).safeTransfer(msg.sender, IERC20(_token).balanceOf(address(this)));
    }

    function recoverERC20s(address[] memory _tokens) public onlyOwner {
        for (uint256 i = 0; i < _tokens.length; i++) {
            IERC20(_tokens[i]).safeTransfer(msg.sender, IERC20(_tokens[i]).balanceOf(address(this)));
        }
    }


    function calcUSDCEquilavent(address _from, uint256 _amount) public view returns (uint256) {
        if (_isYearnCRV(_from)) {
            _amount = _amount.mul(IYearn(_from).pricePerShare()).div(1e18);
            _from = IYearn(_from).token();
        }

        if (_from == crvY || _from == crvSUSD || _from == crvThree || _from == crvYBUSD) {
            address zap = crvYZap;

            if (_from == crvSUSD) {
                zap = crvSUSDZap;
            } else if (_from == crvThree) {
                zap = crvThreePool;
            } else if (_from == crvYBUSD) {
                zap = crvYBUSDZap;
            }

            return ICurveZapSimple(zap).calc_withdraw_one_coin(_amount, 1);
        } else if (_from == crvUSDN || _from == crvUSDP || _from == crvDUSD || _from == crvMUSD || _from == crvUST) {
            address zap = crvUSDNZap;

            if (_from == crvUSDP) {
                zap = crvUSDPZap;
            } else if (_from == crvDUSD) {
                zap = crvDUSDZap;
            } else if (_from == crvMUSD) {
                zap = crvMUSDZap;
            } else if (_from == crvUST) {
                zap = crvUSTZap;
            }

            return ICurveZapSimple(zap).calc_withdraw_one_coin(_amount, 2);
        } else if (_from == crvIB) {
            return ICurveZapSimple(crvIBPool).calc_withdraw_one_coin(_amount, 1, true);
        } else {
            return ICurveZapSimple(crvMetaZapper).calc_withdraw_one_coin(_from, _amount, 2);
        }
    }

    function getUnderlyingAmount(address _derivative, uint256 _amount) public view returns (address, uint256) {
        if (_isAave(_derivative)) {
            return (IATokenV2(_derivative).UNDERLYING_ASSET_ADDRESS(), _amount);
        }

        if (_isCompound(_derivative)) {
            uint256 rate = ICToken(_derivative).exchangeRateStored();
            address underlying = ICToken(_derivative).underlying();
            uint256 underlyingDecimals = ERC20(underlying).decimals();
            uint256 mantissa = 18 + underlyingDecimals - 8;
            uint256 oneCTokenInUnderlying = rate.mul(1e18).div(10**mantissa);
            return (underlying, _amount.mul(oneCTokenInUnderlying).div(1e8));
        }

        if (_isCRV(_derivative) || _isYearnCRV(_derivative)) {
            return (USDC, calcUSDCEquilavent(_derivative, _amount));
        }

        if (_isYearn(_derivative)) {
            _amount = _amount.mul(IYearn(_derivative).pricePerShare()).div(1e18);

            if (_derivative == yDAI) {
                return (DAI, _amount);
            }

            if (_derivative == yUSDC) {
                return (USDC, _amount);
            }

            if (_derivative == yUSDT) {
                return (USDT, _amount);
            }

            if (_derivative == yTUSD) {
                return (TUSD, _amount);
            }

            if (_derivative == ySUSD) {
                return (SUSD, _amount);
            }
        }

        return (_derivative, _amount);
    }


    function zapToBMI(
        address _from,
        uint256 _amount,
        address _fromUnderlying,
        uint256 _fromUnderlyingAmount,
        uint256 _minBMIRecv,
        address[] memory _bmiConstituents,
        uint256[] memory _bmiConstituentsWeightings,
        address _aggregator,
        bytes memory _aggregatorData,
        bool refundDust
    ) public returns (uint256) {
        uint256 sum = 0;
        for (uint256 i = 0; i < _bmiConstituentsWeightings.length; i++) {
            sum = sum.add(_bmiConstituentsWeightings[i]);
        }

        assert(sum <= 1e18);
        assert(sum >= 999e15);

        IERC20(_from).safeTransferFrom(msg.sender, address(this), _amount);

        if (_isBare(_from)) {
            _primitiveToBMI(_from, _amount, _bmiConstituents, _bmiConstituentsWeightings, _aggregator, _aggregatorData);
        }
        else if (_isYearn(_from)) {
            IYearn(_from).withdraw();
            _primitiveToBMI(
                _fromUnderlying,
                _fromUnderlyingAmount,
                _bmiConstituents,
                _bmiConstituentsWeightings,
                _aggregator,
                _aggregatorData
            );
        }
        else if (_isYearnCRV(_from)) {
            IYearn(_from).withdraw();
            address crvToken = IYearn(_from).token();
            _crvToPrimitive(crvToken, IERC20(crvToken).balanceOf(address(this)));
            _primitiveToBMI(
                USDC,
                IERC20(USDC).balanceOf(address(this)),
                _bmiConstituents,
                _bmiConstituentsWeightings,
                address(0),
                ""
            );
        }
        else if (_isCompound(_from)) {
            require(ICToken(_from).redeem(_amount) == 0, "!ctoken-redeem");
            _primitiveToBMI(
                _fromUnderlying,
                _fromUnderlyingAmount,
                _bmiConstituents,
                _bmiConstituentsWeightings,
                _aggregator,
                _aggregatorData
            );
        }
        else if (_isAave(_from)) {
            IERC20(_from).safeApprove(AAVE_LENDING_POOL_V2, 0);
            IERC20(_from).safeApprove(AAVE_LENDING_POOL_V2, _amount);
            ILendingPoolV2(AAVE_LENDING_POOL_V2).withdraw(_fromUnderlying, type(uint256).max, address(this));

            _primitiveToBMI(
                _fromUnderlying,
                _fromUnderlyingAmount,
                _bmiConstituents,
                _bmiConstituentsWeightings,
                _aggregator,
                _aggregatorData
            );
        }
        else {
            _crvToPrimitive(_from, _amount);
            _primitiveToBMI(
                USDC,
                IERC20(USDC).balanceOf(address(this)),
                _bmiConstituents,
                _bmiConstituentsWeightings,
                address(0),
                ""
            );
        }

        uint256 _bmiBal = IERC20(BMI).balanceOf(address(this));
        require(_bmiBal >= _minBMIRecv, "!min-mint");
        IERC20(BMI).safeTransfer(msg.sender, _bmiBal);

        if (refundDust) {
            for (uint256 i = 0; i < _bmiConstituents.length; i++) {
                _fromBMIConstituentToUSDC(_bmiConstituents[i], IERC20(_bmiConstituents[i]).balanceOf(address(this)));
            }
            IERC20(USDC).safeTransfer(msg.sender, IERC20(USDC).balanceOf(address(this)));
        }

        return _bmiBal;
    }


    function _crvToPrimitive(address _from, uint256 _amount) internal {
        if (_from == crvY || _from == crvSUSD || _from == crvYBUSD) {
            address zap = crvYZap;

            if (_from == crvSUSD) {
                zap = crvSUSDZap;
            } else if (_from == crvYBUSD) {
                zap = crvYBUSDZap;
            }

            IERC20(_from).safeApprove(zap, 0);
            IERC20(_from).safeApprove(zap, _amount);
            ICurveZapSimple(zap).remove_liquidity_one_coin(_amount, 1, 0, false);
        } else if (_from == crvUSDP || _from == crvUSDN || _from == crvDUSD || _from == crvMUSD || _from == crvUST) {
            address zap = crvUSDNZap;

            if (_from == crvUSDP) {
                zap = crvUSDPZap;
            } else if (_from == crvDUSD) {
                zap = crvDUSDZap;
            } else if (_from == crvMUSD) {
                zap = crvMUSDZap;
            } else if (_from == crvUST) {
                zap = crvUSTZap;
            }

            IERC20(_from).safeApprove(zap, 0);
            IERC20(_from).safeApprove(zap, _amount);
            ICurveZapSimple(zap).remove_liquidity_one_coin(_amount, 2, 0);
        } else if (_from == crvIB) {
            IERC20(_from).safeApprove(crvIBPool, 0);
            IERC20(_from).safeApprove(crvIBPool, _amount);
            ICurveZapSimple(crvIBPool).remove_liquidity_one_coin(_amount, 1, 0, true);
        } else if (_from == crvThree) {
            address zap = crvThreePool;

            IERC20(_from).safeApprove(zap, 0);
            IERC20(_from).safeApprove(zap, _amount);
            ICurveZapSimple(zap).remove_liquidity_one_coin(_amount, 1, 0);
        } else {
            IERC20(_from).safeApprove(crvMetaZapper, 0);
            IERC20(_from).safeApprove(crvMetaZapper, _amount);
            ICurveZapSimple(crvMetaZapper).remove_liquidity_one_coin(_from, _amount, 2, 0, address(this));
        }
    }

    function _primitiveToBMI(
        address _token,
        uint256 _amount,
        address[] memory _bmiConstituents,
        uint256[] memory _bmiConstituentsWeightings,
        address _aggregator,
        bytes memory _aggregatorData
    ) internal {
        uint256 offset = 0;

        if (_token != DAI && _token != USDC && _token != USDT) {
            IERC20(_token).safeApprove(_aggregator, 0);
            IERC20(_token).safeApprove(_aggregator, _amount);

            (bool success, ) = _aggregator.call(_aggregatorData);
            require(success, "!swap");

            _token = USDC;
        }

        if (_token == USDC) {
            offset = 1;
        } else if (_token == USDT) {
            offset = 2;
        }

        uint256 amountToMint;
        uint256 bmiSupply = IERC20(BMI).totalSupply();

        uint256 tokenBal = IERC20(_token).balanceOf(address(this));
        uint256 tokenAmount;
        for (uint256 i = 0; i < _bmiConstituents.length; i++) {
            tokenAmount = tokenBal.mul(_bmiConstituentsWeightings[i]).div(1e18);
            _toBMIConstituent(_token, _bmiConstituents[i], tokenAmount, offset);

            amountToMint = _approveBMIAndGetMintableAmount(bmiSupply, _bmiConstituents[i], amountToMint);
        }

        IBasket(BMI).mint(amountToMint);
    }

    function _approveBMIAndGetMintableAmount(
        uint256 _bmiTotalSupply,
        address _bmiConstituient,
        uint256 _curMintAmount
    ) internal returns (uint256) {
        uint256 bal = IERC20(_bmiConstituient).balanceOf(address(this));
        uint256 bmiBal = IERC20(_bmiConstituient).balanceOf(BMI);

        IERC20(_bmiConstituient).safeApprove(BMI, 0);
        IERC20(_bmiConstituient).safeApprove(BMI, bal);

        if (_curMintAmount == 0) {
            return _bmiTotalSupply.mul(bal).div(bmiBal);
        }

        uint256 temp = _bmiTotalSupply.mul(bal).div(bmiBal);
        if (temp < _curMintAmount) {
            return temp;
        }

        return _curMintAmount;
    }

    function _toBMIConstituent(
        address _fromToken,
        address _toToken,
        uint256 _amount,
        uint256 _curveOffset
    ) internal {
        uint256 bal;
        uint256[4] memory depositAmounts4 = [uint256(0), uint256(0), uint256(0), uint256(0)];

        if (_toToken == ySUSD) {
            IERC20(_fromToken).safeApprove(crvSUSDPool, 0);
            IERC20(_fromToken).safeApprove(crvSUSDPool, _amount);

            ICurvePool(crvSUSDPool).exchange(int128(_curveOffset), 3, _amount, 0);

            bal = IERC20(SUSD).balanceOf(address(this));
            IERC20(SUSD).safeApprove(ySUSD, 0);
            IERC20(SUSD).safeApprove(ySUSD, bal);
        }
        else if (
            _toToken == yCRV ||
            _toToken == ycrvSUSD ||
            _toToken == ycrvYBUSD ||
            _toToken == ycrvUSDN ||
            _toToken == ycrvUSDP ||
            _toToken == ycrvDUSD ||
            _toToken == ycrvMUSD ||
            _toToken == ycrvUST
        ) {
            address crvToken = IYearn(_toToken).token();

            address zap = crvYZap;
            if (_toToken == ycrvSUSD) {
                zap = crvSUSDZap;
            } else if (_toToken == ycrvYBUSD) {
                zap = crvYBUSDZap;
            } else if (_toToken == ycrvUSDN) {
                zap = crvUSDNZap;
                _curveOffset += 1;
            } else if (_toToken == ycrvUSDP) {
                zap = crvUSDPZap;
                _curveOffset += 1;
            } else if (_toToken == ycrvDUSD) {
                zap = crvDUSDZap;
                _curveOffset += 1;
            } else if (_toToken == ycrvMUSD) {
                zap = crvMUSDZap;
                _curveOffset += 1;
            } else if (_toToken == ycrvUST) {
                zap = crvUSTZap;
                _curveOffset += 1;
            }

            depositAmounts4[_curveOffset] = _amount;
            IERC20(_fromToken).safeApprove(zap, 0);
            IERC20(_fromToken).safeApprove(zap, _amount);
            ICurveZapSimple(zap).add_liquidity(depositAmounts4, 0);

            bal = IERC20(crvToken).balanceOf(address(this));
            IERC20(crvToken).safeApprove(_toToken, 0);
            IERC20(crvToken).safeApprove(_toToken, bal);
        } else if (_toToken == ycrvThree || _toToken == ycrvIB) {
            address crvToken = IYearn(_toToken).token();

            uint256[3] memory depositAmounts3 = [uint256(0), uint256(0), uint256(0)];
            depositAmounts3[_curveOffset] = _amount;

            address zap = crvThreePool;
            if (_toToken == ycrvIB) {
                zap = crvIBPool;
            }

            IERC20(_fromToken).safeApprove(zap, 0);
            IERC20(_fromToken).safeApprove(zap, _amount);

            if (_toToken == ycrvThree) {
                ICurveZapSimple(zap).add_liquidity(depositAmounts3, 0);
            } else {
                ICurveZapSimple(zap).add_liquidity(depositAmounts3, 0, true);
            }

            bal = IERC20(crvToken).balanceOf(address(this));
            IERC20(crvToken).safeApprove(_toToken, 0);
            IERC20(crvToken).safeApprove(_toToken, bal);
        }
        else if (_toToken == ycrvBUSD || _toToken == ycrvFRAX || _toToken == ycrvALUSD || _toToken == ycrvLUSD) {
            address crvToken = IYearn(_toToken).token();

            depositAmounts4[_curveOffset + 1] = _amount;
            IERC20(_fromToken).safeApprove(crvMetaZapper, 0);
            IERC20(_fromToken).safeApprove(crvMetaZapper, _amount);

            ICurveZapSimple(crvMetaZapper).add_liquidity(crvToken, depositAmounts4, 0);

            bal = IERC20(crvToken).balanceOf(address(this));
            IERC20(crvToken).safeApprove(_toToken, 0);
            IERC20(crvToken).safeApprove(_toToken, bal);
        }

        IYearn(_toToken).deposit();
    }

    function _fromBMIConstituentToUSDC(address _fromToken, uint256 _amount) internal {
        if (_isYearnCRV(_fromToken)) {
            _crvToPrimitive(IYearn(_fromToken).token(), IYearn(_fromToken).withdraw(_amount));
        }
    }

    function _isBare(address _token) internal pure returns (bool) {
        return (_token == DAI ||
            _token == USDC ||
            _token == USDT ||
            _token == TUSD ||
            _token == SUSD ||
            _token == BUSD ||
            _token == USDP ||
            _token == FRAX ||
            _token == ALUSD ||
            _token == LUSD ||
            _token == USDN);
    }

    function _isYearn(address _token) internal pure returns (bool) {
        return (_token == yDAI || _token == yUSDC || _token == yUSDT || _token == yTUSD || _token == ySUSD);
    }

    function _isYearnCRV(address _token) internal pure returns (bool) {
        return (_token == yCRV ||
            _token == ycrvSUSD ||
            _token == ycrvYBUSD ||
            _token == ycrvBUSD ||
            _token == ycrvUSDP ||
            _token == ycrvFRAX ||
            _token == ycrvALUSD ||
            _token == ycrvLUSD ||
            _token == ycrvUSDN ||
            _token == ycrvThree ||
            _token == ycrvIB ||
            _token == ycrvMUSD ||
            _token == ycrvUST ||
            _token == ycrvDUSD);
    }

    function _isCRV(address _token) internal pure returns (bool) {
        return (_token == crvY ||
            _token == crvSUSD ||
            _token == crvYBUSD ||
            _token == crvBUSD ||
            _token == crvUSDP ||
            _token == crvFRAX ||
            _token == crvALUSD ||
            _token == crvLUSD ||
            _token == crvThree ||
            _token == crvUSDN ||
            _token == crvDUSD ||
            _token == crvMUSD ||
            _token == crvUST ||
            _token == crvIB);
    }

    function _isCompound(address _token) internal pure returns (bool) {
        return (_token == cDAI || _token == cUSDC || _token == cUSDT || _token == cTUSD);
    }

    function _isAave(address _token) internal pure returns (bool) {
        return (_token == aDAI || _token == aUSDC || _token == aUSDT || _token == aTUSD || _token == aSUSD);
    }
}

pragma solidity ^0.7.3;



contract BMIBurner is BMIZapper {
    using SafeERC20 for IERC20;

    constructor() {}

    function burnBMIToUSDC(uint256 _amount, uint256 _minRecv) public returns (uint256) {
        IERC20(BMI).safeTransferFrom(msg.sender, address(this), _amount);
        (address[] memory constituients, ) = IBasket(BMI).getAssetsAndBalances();
        IBasket(BMI).burn(_amount);

        for (uint256 i = 0; i < constituients.length; i++) {
            _fromBMIConstituentToUSDC(constituients[i], IERC20(constituients[i]).balanceOf(address(this)));
        }
        uint256 usdcBal = IERC20(USDC).balanceOf(address(this));
        require(usdcBal >= _minRecv, "!min-usdc");
        IERC20(USDC).safeTransfer(msg.sender, usdcBal);

        return usdcBal;
    }
}
