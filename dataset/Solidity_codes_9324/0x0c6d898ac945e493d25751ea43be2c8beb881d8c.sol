pragma solidity >=0.6.0 <0.9.0;
pragma experimental ABIEncoderV2;

interface IAdapter {

    struct Call {
        address target;
        bytes callData;
    }

    function outputTokens(address inputToken) external view returns (address[] memory outputs);


    function encodeMigration(address _genericRouter, address _strategy, address _lp, uint256 _amount)
        external view returns (Call[] memory calls);


    function encodeWithdraw(address _lp, uint256 _amount) external view returns (Call[] memory calls);


    function buy(address _lp, address _exchange, uint256 _minAmountOut, uint256 _deadline) external payable;


    function getAmountOut(address _lp, address _exchange, uint256 _amountIn) external returns (uint256);


    function isWhitelisted(address _token) external view returns (bool);

}//GPL-3.0-or-later
pragma solidity >=0.6.0 <0.9.0;

interface IERC20NonStandard {


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
}//GPL-3.0-or-later
pragma solidity >=0.6.0 <0.9.0;


interface IStrategyToken is IERC20NonStandard {

    function increaseAllowance(address spender, uint256 addedValue) external returns (bool);


    function decreaseAllowance(address spender, uint256 subtractedValue) external returns (bool);


    function permit(
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external;


    function nonces(address owner) external view returns (uint256);

}//GPL-3.0-or-later
pragma solidity >=0.6.0 <0.9.0;

interface IEstimator {

    function estimateItem(
        uint256 balance,
        address token
    ) external view returns (int256);

}//GPL-3.0-or-later
pragma solidity >=0.6.0 <0.9.0;


interface ITokenRegistry {

    function itemCategories(address token) external view returns (uint256);


    function estimatorCategories(address token) external view returns (uint256);


    function estimators(uint256 categoryIndex) external view returns (IEstimator);


    function getEstimator(address token) external view returns (IEstimator);


    function addEstimator(uint256 estimatorCategoryIndex, address estimator) external;


    function addItem(uint256 itemCategoryIndex, uint256 estimatorCategoryIndex, address token) external;

}//GPL-3.0-or-later
pragma solidity >=0.6.0 <0.9.0;


interface IOracle {

    function weth() external view returns (address);


    function susd() external view returns (address);


    function tokenRegistry() external view returns (ITokenRegistry);


    function estimateStrategy(IStrategy strategy) external view returns (uint256, int256[] memory);


    function estimateItem(
        uint256 balance,
        address token
    ) external view returns (int256);

}//GPL-3.0-or-later
pragma solidity >=0.6.0 <0.9.0;

interface IWhitelist {

    function approve(address account) external;


    function revoke(address account) external;


    function approved(address account) external view returns (bool);

}//GPL-3.0-or-later
pragma solidity >=0.6.0 <0.9.0;

interface StrategyTypes {


    enum ItemCategory {BASIC, SYNTH, DEBT, RESERVE}
    enum EstimatorCategory {
      DEFAULT_ORACLE,
      CHAINLINK_ORACLE,
      UNISWAP_TWAP_ORACLE,
      SUSHI_TWAP_ORACLE,
      STRATEGY,
      BLOCKED,
      AAVE_V1,
      AAVE_V2,
      AAVE_DEBT,
      BALANCER,
      COMPOUND,
      CURVE,
      CURVE_GAUGE,
      SUSHI_LP,
      SUSHI_FARM,
      UNISWAP_V2_LP,
      UNISWAP_V3_LP,
      YEARN_V1,
      YEARN_V2
    }
    enum TimelockCategory {RESTRUCTURE, THRESHOLD, REBALANCE_SLIPPAGE, RESTRUCTURE_SLIPPAGE, TIMELOCK, PERFORMANCE}

    struct StrategyItem {
        address item;
        int256 percentage;
        TradeData data;
    }

    struct TradeData {
        address[] adapters;
        address[] path;
        bytes cache;
    }

    struct InitialState {
        uint32 timelock;
        uint16 rebalanceThreshold;
        uint16 rebalanceSlippage;
        uint16 restructureSlippage;
        uint16 performanceFee;
        bool social;
        bool set;
    }

    struct StrategyState {
        uint32 timelock;
        uint16 rebalanceSlippage;
        uint16 restructureSlippage;
        bool social;
        bool set;
    }

    struct Timelock {
        TimelockCategory category;
        uint256 timestamp;
        bytes data;
    }
}//GPL-3.0-or-later
pragma solidity >=0.6.0 <0.9.0;


interface IStrategy is IStrategyToken, StrategyTypes {

    function approveToken(
        address token,
        address account,
        uint256 amount
    ) external;


    function approveDebt(
        address token,
        address account,
        uint256 amount
    ) external;


    function approveSynths(
        address account,
        uint256 amount
    ) external;


    function setStructure(StrategyItem[] memory newItems) external;


    function setCollateral(address token) external;


    function withdrawAll(uint256 amount) external;


    function mint(address account, uint256 amount) external;


    function burn(address account, uint256 amount) external returns (uint256);


    function delegateSwap(
        address adapter,
        uint256 amount,
        address tokenIn,
        address tokenOut
    ) external;


    function settleSynths() external;


    function issueStreamingFee() external;


    function updateTokenValue(uint256 total, uint256 supply) external;


    function updatePerformanceFee(uint16 fee) external;


    function updateRebalanceThreshold(uint16 threshold) external;


    function updateTradeData(address item, TradeData memory data) external;


    function lock() external;


    function unlock() external;


    function locked() external view returns (bool);


    function items() external view returns (address[] memory);


    function synths() external view returns (address[] memory);


    function debt() external view returns (address[] memory);


    function rebalanceThreshold() external view returns (uint256);


    function performanceFee() external view returns (uint256);


    function getPercentage(address item) external view returns (int256);


    function getTradeData(address item) external view returns (TradeData memory);


    function getPerformanceFeeOwed(address account) external view returns (uint256);


    function controller() external view returns (address);


    function manager() external view returns (address);


    function oracle() external view returns (IOracle);


    function whitelist() external view returns (IWhitelist);


    function supportsSynths() external view returns (bool);

}//GPL-3.0-or-later
pragma solidity >=0.6.0 <0.9.0;


interface IStrategyController is StrategyTypes {

    function setupStrategy(
        address manager_,
        address strategy_,
        InitialState memory state_,
        address router_,
        bytes memory data_
    ) external payable;


    function deposit(
        IStrategy strategy,
        IStrategyRouter router,
        uint256 amount,
        uint256 slippage,
        bytes memory data
    ) external payable;


    function withdrawETH(
        IStrategy strategy,
        IStrategyRouter router,
        uint256 amount,
        uint256 slippage,
        bytes memory data
    ) external;


    function withdrawWETH(
        IStrategy strategy,
        IStrategyRouter router,
        uint256 amount,
        uint256 slippage,
        bytes memory data
    ) external;


    function rebalance(
        IStrategy strategy,
        IStrategyRouter router,
        bytes memory data
    ) external;


    function restructure(
        IStrategy strategy,
        StrategyItem[] memory strategyItems
    ) external;


    function finalizeStructure(
        IStrategy strategy,
        IStrategyRouter router,
        bytes memory data
    ) external;


    function updateValue(
        IStrategy strategy,
        TimelockCategory category,
        uint256 newValue
    ) external;


    function finalizeValue(address strategy) external;


    function openStrategy(IStrategy strategy) external;


    function setStrategy(IStrategy strategy) external;


    function initialized(address strategy) external view returns (bool);


    function strategyState(address strategy) external view returns (StrategyState memory);


    function verifyStructure(address strategy, StrategyItem[] memory newItems)
        external
        view
        returns (bool);


    function oracle() external view returns (IOracle);


    function whitelist() external view returns (IWhitelist);

}//GPL-3.0-or-later
pragma solidity >=0.6.0 <0.9.0;


interface IStrategyRouter {

    enum RouterCategory {GENERIC, LOOP, SYNTH, BATCH}

    function rebalance(address strategy, bytes calldata data) external;


    function restructure(address strategy, bytes calldata data) external;


    function deposit(address strategy, bytes calldata data) external;


    function withdraw(address strategy, bytes calldata) external;


    function controller() external view returns (IStrategyController);


    function category() external view returns (RouterCategory);

}// WTFPL
pragma solidity >=0.6.0 <0.9.0;

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
}// WTFPL
pragma solidity >=0.6.0 <0.9.0;

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

        (bool success, ) = recipient.call{ value: amount }("");
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

        (bool success, bytes memory returndata) = target.call{ value: value }(data);
        return _verifyCallResult(success, returndata, errorMessage);
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
        return _verifyCallResult(success, returndata, errorMessage);
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
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function _verifyCallResult(
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) private pure returns (bytes memory) {

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
}// WTFPL
pragma solidity >=0.6.0 <0.9.0;


library SafeERC20Transfer {

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

    function _callOptionalReturn(IERC20 token, bytes memory data) private {


        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) {
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}//GPL-3.0-or-later
pragma solidity >=0.6.0 <0.9.0;


interface IMigrationController {

    function migrate(
        IStrategy strategy,
        IStrategyRouter genericRouter,
        IERC20 lpToken,
        IAdapter adapter,
        uint256 amount
    ) external;


    function initialized(address strategy) external view returns (bool);

}//GPL-3.0-or-later
pragma solidity >=0.6.0 <0.9.0;

interface ILiquidityMigrationV2 {

    function setStake(address user, address lp, address adapter, uint256 amount) external;


    function migrateAll(address lp, address adapter) external;

}// WTFPL

pragma solidity ^0.8.0;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}// WTFPL

pragma solidity ^0.8.0;


abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    function _setOwner(address owner_) 
        internal
    {
        _owner = owner_;
        emit OwnershipTransferred(address(0), owner_);
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
}// WTFPL
pragma solidity >=0.8.0;


contract Timelocked is Ownable {


    uint256 public unlocked; // timestamp unlock migration
    uint256 public modify;   // timestamp disallow changes

    modifier onlyUnlocked() {

        require(block.timestamp >= unlocked, "Timelock#onlyUnlocked: not unlocked");
        _;
    }

    modifier onlyModify() {

        require(block.timestamp < modify, "Timelock#onlyModify: cannot modify");
        _;
    }

    constructor(uint256 unlock_, uint256 modify_, address owner_) {
        require(unlock_ > block.timestamp, 'Timelock#not greater');
        unlocked = unlock_;
        modify = modify_;
        _setOwner(owner_);
    }

    function updateUnlock(
        uint256 unlock_
    ) 
        public
        onlyOwner
        onlyModify
    {

        unlocked = unlock_;
    }
}//GPL-3.0-or-later
pragma solidity >=0.8.0;


contract LiquidityMigrationV2 is ILiquidityMigrationV2, Timelocked {

    using SafeERC20 for IERC20;

    address public controller;
    address public genericRouter;
    address public migrationCoordinator;
    address public emergencyReceiver;

    bool public paused;
    mapping (address => bool) public adapters; // adapter -> bool
    mapping (address => uint256) public totalStaked; // lp -> total staked
    mapping (address => address) public strategies; // lp -> enso strategy
    mapping (address => mapping (address => uint256)) public staked; // user -> lp -> stake

    event Staked(address adapter, address strategy, uint256 amount, address account);
    event Migrated(address adapter, address lp, address strategy, address account);
    event Created(address adapter, address lp, address strategy, address account);
    event Refunded(address lp, uint256 amount, address account);
    event EmergencyMigration(address lp, uint256 amount, address receiver);

    modifier onlyRegistered(address adapter) {

        require(adapters[adapter], "Not registered");
        _;
    }

    modifier onlyWhitelisted(address adapter, address lp) {

        require(IAdapter(adapter).isWhitelisted(lp), "Not whitelist");
        _;
    }

    modifier onlyLocked() {

        require(block.timestamp < unlocked, "Unlocked");
        _;
    }

    modifier isPaused() {

        require(paused, "Not paused");
        _;
    }

    modifier notPaused() {

        require(!paused, "Paused");
        _;
    }

    constructor(
        address[] memory adapters_,
        uint256 unlock_,
        uint256 modify_
    )
        Timelocked(unlock_, modify_, msg.sender)
    {
        for (uint256 i = 0; i < adapters_.length; i++) {
            adapters[adapters_[i]] = true;
        }
    }

    function setStrategy(address lp, address strategy) external onlyOwner notPaused {

        require(
            IMigrationController(controller).initialized(strategy),
            "Not enso strategy"
        );
        if (strategies[lp] != address(0)) {
          require(IERC20(strategies[lp]).balanceOf(address(this)) == 0, "Already set");
        }
        strategies[lp] = strategy;
    }

    function setStake(
        address user,
        address lp,
        address adapter,
        uint256 amount
    )
        external
        override
        notPaused
        onlyLocked
    {

        require(msg.sender == migrationCoordinator, "Wrong sender");
        _stake(user, lp, adapter, amount);
    }

    function stake(
        address lp,
        uint256 amount,
        address adapter
    )
        external
        notPaused
        onlyLocked
        onlyRegistered(adapter)
    {

        _transferFromAndStake(lp, adapter, amount);
    }

    function batchStake(
        address[] memory lps,
        uint256[] memory amounts,
        address adapter
    )
        external
        notPaused
        onlyLocked
        onlyRegistered(adapter)
    {

        require(lps.length == amounts.length, "Incorrect arrays");
        for (uint256 i = 0; i < lps.length; i++) {
            _transferFromAndStake(lps[i], adapter, amounts[i]);
        }
    }

    function buyAndStake(
        address lp,
        address adapter,
        address exchange,
        uint256 minAmountOut,
        uint256 deadline
    )
        external
        payable
        notPaused
        onlyLocked
        onlyRegistered(adapter)
        onlyWhitelisted(adapter, lp)
    {

        require(msg.value > 0, "No value");
        _buyAndStake(lp, msg.value, adapter, exchange, minAmountOut, deadline);
    }

    function migrateAll(
        address lp,
        address adapter
    )
        external
        override
        notPaused
        onlyOwner
        onlyUnlocked
        onlyRegistered(adapter)
        onlyWhitelisted(adapter, lp)
    {

        address strategy = strategies[lp];
        require(strategy != address(0), "Strategy not initialized");
        uint256 totalStake = totalStaked[lp];
        delete totalStaked[lp];
        uint256 strategyBalanceBefore = IStrategy(strategy).balanceOf(address(this));
        IERC20(lp).safeTransfer(genericRouter, totalStake);
        IMigrationController(controller).migrate(IStrategy(strategy), IStrategyRouter(genericRouter), IERC20(lp), IAdapter(adapter), totalStake);
        uint256 strategyBalanceAfter = IStrategy(strategy).balanceOf(address(this));
        assert((strategyBalanceAfter - strategyBalanceBefore) == totalStake);
    }

    function refund(address user, address lp) external onlyOwner {

        _refund(user, lp);
    }

    function withdraw(address lp) external {

        _refund(msg.sender, lp);
    }

    function claim(address lp) external {

        require(totalStaked[lp] == 0, "Not yet migrated");
        uint256 amount = staked[msg.sender][lp];
        require(amount > 0, "No claim");
        delete staked[msg.sender][lp];

        address strategy = strategies[lp];
        IERC20(strategy).safeTransfer(msg.sender, amount);
        emit Migrated(address(0), lp, strategy, msg.sender);
    }

    function emergencyMigrate(IERC20 lp) external isPaused onlyOwner {

        require(emergencyReceiver != address(0), "Emergency receiver not set");
        uint256 balance = lp.balanceOf(address(this));
        require(balance > 0, "No balance");
        lp.safeTransfer(emergencyReceiver, balance);
        emit EmergencyMigration(address(lp), balance, emergencyReceiver);
    }

    function pause() external notPaused onlyOwner {

        paused = true;
    }

    function unpause() external isPaused onlyOwner {

        paused = false;
    }

    function _stake(
        address user,
        address lp,
        address adapter,
        uint256 amount
    )
        internal
    {

        staked[user][lp] += amount;
        totalStaked[lp] += amount;
        emit Staked(adapter, lp, amount, user);
    }

    function _transferFromAndStake(
        address lp,
        address adapter,
        uint256 amount
    )
        internal
        onlyWhitelisted(adapter, lp)
    {

        require(amount > 0, "No amount");
        IERC20(lp).safeTransferFrom(msg.sender, address(this), amount);
        _stake(msg.sender, lp, adapter, amount);
    }

    function _buyAndStake(
        address lp,
        uint256 amount,
        address adapter,
        address exchange,
        uint256 minAmountOut,
        uint256 deadline
    )
        internal
    {

        uint256 balanceBefore = IERC20(lp).balanceOf(address(this));
        IAdapter(adapter).buy{value: amount}(lp, exchange, minAmountOut, deadline);
        uint256 amountAdded = IERC20(lp).balanceOf(address(this)) - balanceBefore;
        _stake(msg.sender, lp, adapter, amountAdded);
    }

    function _refund(address user, address lp) internal {

        require(totalStaked[lp] > 0, "Not refundable");
        uint256 amount = staked[user][lp];
        require(amount > 0, "No stake");
        delete staked[user][lp];
        totalStaked[lp] -= amount;

        IERC20(lp).safeTransfer(user, amount);
        emit Refunded(lp, amount, user);
    }

    function updateController(address newController)
        external
        onlyOwner
    {

        require(controller != newController, "Controller already exists");
        controller = newController;
    }

    function updateGenericRouter(address newGenericRouter)
        external
        onlyOwner
    {

        require(genericRouter != newGenericRouter, "GenericRouter already exists");
        genericRouter = newGenericRouter;
    }

    function updateCoordinator(address newCoordinator)
        external
        onlyOwner
    {

        require(migrationCoordinator != newCoordinator, "Coordinator already exists");
        migrationCoordinator = newCoordinator;
    }

    function updateEmergencyReceiver(address newReceiver)
        external
        onlyOwner
    {

        require(emergencyReceiver != newReceiver, "Receiver already exists");
        emergencyReceiver = newReceiver;
    }

    function addAdapter(address adapter)
        external
        onlyOwner
    {

        require(!adapters[adapter], "Adapter already exists");
        adapters[adapter] = true;
    }

    function removeAdapter(address adapter)
        external
        onlyOwner
    {

        require(adapters[adapter], "Adapter does not exist");
        adapters[adapter] = false;
    }

    function hasStaked(address account, address lp)
        external
        view
        returns(bool)
    {

        return staked[account][lp] > 0;
    }
}// WTFPL

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
}