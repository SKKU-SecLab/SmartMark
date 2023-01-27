
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
}// MIT

pragma solidity ^0.8.0;

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

pragma solidity ^0.8.0;

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
}// MIT

pragma solidity ^0.8.0;


library SafeERC20 {

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

        uint256 newAllowance = token.allowance(address(this), spender) + value;
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(IERC20 token, address spender, uint256 value) internal {

        unchecked {
            uint256 oldAllowance = token.allowance(address(this), spender);
            require(oldAllowance >= value, "SafeERC20: decreased allowance below zero");
            uint256 newAllowance = oldAllowance - value;
            _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
        }
    }

    function _callOptionalReturn(IERC20 token, bytes memory data) private {


        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) { // Return data is optional
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}// MIT

pragma solidity ^0.8.0;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}// MIT

pragma solidity 0.8.3;

interface IVesperPool is IERC20 {

    function deposit() external payable;


    function deposit(uint256 _share) external;


    function multiTransfer(address[] memory _recipients, uint256[] memory _amounts) external returns (bool);


    function excessDebt(address _strategy) external view returns (uint256);


    function permit(
        address,
        address,
        uint256,
        uint256,
        uint8,
        bytes32,
        bytes32
    ) external;


    function poolRewards() external returns (address);


    function reportEarning(
        uint256 _profit,
        uint256 _loss,
        uint256 _payback
    ) external;


    function reportLoss(uint256 _loss) external;


    function resetApproval() external;


    function sweepERC20(address _fromToken) external;


    function withdraw(uint256 _amount) external;


    function withdrawETH(uint256 _amount) external;


    function whitelistedWithdraw(uint256 _amount) external;


    function governor() external view returns (address);


    function keepers() external view returns (address[] memory);


    function isKeeper(address _address) external view returns (bool);


    function maintainers() external view returns (address[] memory);


    function isMaintainer(address _address) external view returns (bool);


    function feeCollector() external view returns (address);


    function pricePerShare() external view returns (uint256);


    function strategy(address _strategy)
        external
        view
        returns (
            bool _active,
            uint256 _interestFee,
            uint256 _debtRate,
            uint256 _lastRebalance,
            uint256 _totalDebt,
            uint256 _totalLoss,
            uint256 _totalProfit,
            uint256 _debtRatio
        );


    function stopEverything() external view returns (bool);


    function token() external view returns (IERC20);


    function tokensHere() external view returns (uint256);


    function totalDebtOf(address _strategy) external view returns (uint256);


    function totalValue() external view returns (uint256);


    function withdrawFee() external view returns (uint256);


    function getPricePerShare() external view returns (uint256);

}// MIT
pragma solidity 0.8.3;

library Errors {

    string public constant INVALID_COLLATERAL_AMOUNT = "1"; // Collateral must be greater than 0
    string public constant INVALID_SHARE_AMOUNT = "2"; // Share must be greater than 0
    string public constant INVALID_INPUT_LENGTH = "3"; // Input array length must be greater than 0
    string public constant INPUT_LENGTH_MISMATCH = "4"; // Input array length mismatch with another array length
    string public constant NOT_WHITELISTED_ADDRESS = "5"; // Caller is not whitelisted to withdraw without fee
    string public constant MULTI_TRANSFER_FAILED = "6"; // Multi transfer of tokens has failed
    string public constant FEE_COLLECTOR_NOT_SET = "7"; // Fee Collector is not set
    string public constant NOT_ALLOWED_TO_SWEEP = "8"; // Token is not allowed to sweep
    string public constant INSUFFICIENT_BALANCE = "9"; // Insufficient balance to performs operations to follow
    string public constant INPUT_ADDRESS_IS_ZERO = "10"; // Input address is zero
    string public constant FEE_LIMIT_REACHED = "11"; // Fee must be less than MAX_BPS
    string public constant ALREADY_INITIALIZED = "12"; // Data structure, contract, or logic already initialized and can not be called again
    string public constant ADD_IN_LIST_FAILED = "13"; // Cannot add address in address list
    string public constant REMOVE_FROM_LIST_FAILED = "14"; // Cannot remove address from address list
    string public constant STRATEGY_IS_ACTIVE = "15"; // Strategy is already active, an inactive strategy is required
    string public constant STRATEGY_IS_NOT_ACTIVE = "16"; // Strategy is not active, an active strategy is required
    string public constant INVALID_STRATEGY = "17"; // Given strategy is not a strategy of this pool
    string public constant DEBT_RATIO_LIMIT_REACHED = "18"; // Debt ratio limit reached. It must be less than MAX_BPS
    string public constant TOTAL_DEBT_IS_NOT_ZERO = "19"; // Strategy total debt must be 0
    string public constant LOSS_TOO_HIGH = "20"; // Strategy reported loss must be less than current debt
}// MIT

pragma solidity 0.8.3;


contract PoolAccountantStorageV1 {

    address public pool; // Address of Vesper pool
    uint256 public totalDebtRatio; // Total debt ratio. This will keep some buffer amount in pool
    uint256 public totalDebt; // Total debt. Sum of debt of all strategies.
    address[] public strategies; // Array of strategies
    address[] public withdrawQueue; // Array of strategy in the order in which funds should be withdrawn.
}

contract PoolAccountantStorageV2 is PoolAccountantStorageV1 {

    struct StrategyConfig {
        bool active;
        uint256 interestFee; // Strategy fee
        uint256 debtRate; // Strategy can not borrow large amount in short durations. Can set big limit for trusted strategy
        uint256 lastRebalance; // Timestamp of last rebalance
        uint256 totalDebt; // Total outstanding debt strategy has
        uint256 totalLoss; // Total loss that strategy has realized
        uint256 totalProfit; // Total gain that strategy has realized
        uint256 debtRatio; // % of asset allocation
        uint256 externalDepositFee; // External deposit fee of strategy
    }

    mapping(address => StrategyConfig) public strategy; // Strategy address to its configuration

    uint256 public externalDepositFee; // External deposit fee of Vesper pool
}

contract PoolAccountant is Initializable, Context, PoolAccountantStorageV2 {

    using SafeERC20 for IERC20;

    string public constant VERSION = "4.0.0";
    uint256 public constant MAX_BPS = 10_000;

    event EarningReported(
        address indexed strategy,
        uint256 profit,
        uint256 loss,
        uint256 payback,
        uint256 strategyDebt,
        uint256 poolDebt,
        uint256 creditLine
    );
    event StrategyAdded(
        address indexed strategy,
        uint256 interestFee,
        uint256 debtRatio,
        uint256 debtRate,
        uint256 externalDepositFee
    );
    event StrategyRemoved(address indexed strategy);
    event StrategyMigrated(
        address indexed oldStrategy,
        address indexed newStrategy,
        uint256 interestFee,
        uint256 debtRatio,
        uint256 debtRate,
        uint256 externalDepositFee
    );
    event UpdatedExternalDepositFee(address indexed strategy, uint256 previousFee, uint256 newFee);
    event UpdatedInterestFee(address indexed strategy, uint256 previousInterestFee, uint256 newInterestFee);
    event UpdatedPoolExternalDepositFee(uint256 previousFee, uint256 newFee);
    event UpdatedStrategyDebtParams(address indexed strategy, uint256 debtRatio, uint256 debtRate);

    function init(address _pool) public initializer {

        require(_pool != address(0), Errors.INPUT_ADDRESS_IS_ZERO);
        pool = _pool;
    }

    modifier onlyGovernor() {

        require(IVesperPool(pool).governor() == _msgSender(), "not-the-governor");
        _;
    }

    modifier onlyKeeper() {

        require(
            IVesperPool(pool).governor() == _msgSender() || IVesperPool(pool).isKeeper(_msgSender()),
            "not-a-keeper"
        );
        _;
    }

    modifier onlyMaintainer() {

        require(
            IVesperPool(pool).governor() == _msgSender() || IVesperPool(pool).isMaintainer(_msgSender()),
            "not-a-maintainer"
        );
        _;
    }

    modifier onlyPool() {

        require(pool == _msgSender(), "not-a-pool");
        _;
    }


    function addStrategy(
        address _strategy,
        uint256 _interestFee,
        uint256 _debtRatio,
        uint256 _debtRate,
        uint256 _externalDepositFee
    ) public onlyGovernor {

        require(_strategy != address(0), Errors.INPUT_ADDRESS_IS_ZERO);
        require(!strategy[_strategy].active, Errors.STRATEGY_IS_ACTIVE);
        totalDebtRatio = totalDebtRatio + _debtRatio;
        require(totalDebtRatio <= MAX_BPS, Errors.DEBT_RATIO_LIMIT_REACHED);
        require(_interestFee <= MAX_BPS, Errors.FEE_LIMIT_REACHED);
        require(_externalDepositFee <= MAX_BPS, Errors.FEE_LIMIT_REACHED);
        StrategyConfig memory newStrategy =
            StrategyConfig({
                active: true,
                interestFee: _interestFee,
                debtRatio: _debtRatio,
                totalDebt: 0,
                totalProfit: 0,
                totalLoss: 0,
                debtRate: _debtRate,
                lastRebalance: block.number,
                externalDepositFee: _externalDepositFee
            });
        strategy[_strategy] = newStrategy;
        strategies.push(_strategy);
        withdrawQueue.push(_strategy);
        emit StrategyAdded(_strategy, _interestFee, _debtRatio, _debtRate, _externalDepositFee);

        _recalculatePoolExternalDepositFee();
    }

    function removeStrategy(uint256 _index) external onlyGovernor {

        address _strategy = strategies[_index];
        require(strategy[_strategy].active, Errors.STRATEGY_IS_NOT_ACTIVE);
        require(strategy[_strategy].totalDebt == 0, Errors.TOTAL_DEBT_IS_NOT_ZERO);
        totalDebtRatio -= strategy[_strategy].debtRatio;
        delete strategy[_strategy];
        strategies[_index] = strategies[strategies.length - 1];
        strategies.pop();
        address[] memory _withdrawQueue = new address[](strategies.length);
        uint256 j;
        for (uint256 i = 0; i < withdrawQueue.length; i++) {
            if (withdrawQueue[i] != _strategy) {
                _withdrawQueue[j] = withdrawQueue[i];
                j++;
            }
        }
        withdrawQueue = _withdrawQueue;
        emit StrategyRemoved(_strategy);

        _recalculatePoolExternalDepositFee();
    }

    function updateExternalDepositFee(address _strategy, uint256 _externalDepositFee) external onlyGovernor {

        require(strategy[_strategy].active, Errors.STRATEGY_IS_NOT_ACTIVE);
        require(_externalDepositFee <= MAX_BPS, Errors.FEE_LIMIT_REACHED);
        uint256 _oldExternalDepositFee = strategy[_strategy].externalDepositFee;
        strategy[_strategy].externalDepositFee = _externalDepositFee;
        emit UpdatedExternalDepositFee(_strategy, _oldExternalDepositFee, _externalDepositFee);

        _recalculatePoolExternalDepositFee();
    }

    function updateInterestFee(address _strategy, uint256 _interestFee) external onlyGovernor {

        require(strategy[_strategy].active, Errors.STRATEGY_IS_NOT_ACTIVE);
        require(_interestFee <= MAX_BPS, Errors.FEE_LIMIT_REACHED);
        emit UpdatedInterestFee(_strategy, strategy[_strategy].interestFee, _interestFee);
        strategy[_strategy].interestFee = _interestFee;
    }

    function updateDebtRate(address _strategy, uint256 _debtRate) external onlyKeeper {

        require(strategy[_strategy].active, Errors.STRATEGY_IS_NOT_ACTIVE);
        strategy[_strategy].debtRate = _debtRate;
        emit UpdatedStrategyDebtParams(_strategy, strategy[_strategy].debtRatio, _debtRate);
    }

    function sweepERC20(address _fromToken) external virtual onlyKeeper {

        IERC20(_fromToken).safeTransfer(pool, IERC20(_fromToken).balanceOf(address(this)));
    }

    function updateDebtRatio(address _strategy, uint256 _debtRatio) external onlyMaintainer {

        require(strategy[_strategy].active, Errors.STRATEGY_IS_NOT_ACTIVE);
        totalDebtRatio = (totalDebtRatio - strategy[_strategy].debtRatio) + _debtRatio;
        require(totalDebtRatio <= MAX_BPS, Errors.DEBT_RATIO_LIMIT_REACHED);
        strategy[_strategy].debtRatio = _debtRatio;
        emit UpdatedStrategyDebtParams(_strategy, _debtRatio, strategy[_strategy].debtRate);

        _recalculatePoolExternalDepositFee();
    }

    function updateWithdrawQueue(address[] memory _withdrawQueue) external onlyMaintainer {

        uint256 _length = _withdrawQueue.length;
        require(_length == withdrawQueue.length && _length == strategies.length, Errors.INPUT_LENGTH_MISMATCH);
        for (uint256 i = 0; i < _length; i++) {
            require(strategy[_withdrawQueue[i]].active, Errors.STRATEGY_IS_NOT_ACTIVE);
        }
        withdrawQueue = _withdrawQueue;
    }


    function migrateStrategy(address _old, address _new) external onlyPool {

        require(strategy[_old].active, Errors.STRATEGY_IS_NOT_ACTIVE);
        require(!strategy[_new].active, Errors.STRATEGY_IS_ACTIVE);
        StrategyConfig memory _newStrategy =
            StrategyConfig({
                active: true,
                interestFee: strategy[_old].interestFee,
                debtRatio: strategy[_old].debtRatio,
                totalDebt: strategy[_old].totalDebt,
                totalProfit: 0,
                totalLoss: 0,
                debtRate: strategy[_old].debtRate,
                lastRebalance: strategy[_old].lastRebalance,
                externalDepositFee: strategy[_old].externalDepositFee
            });
        delete strategy[_old];
        strategy[_new] = _newStrategy;

        for (uint256 i = 0; i < strategies.length; i++) {
            if (strategies[i] == _old) {
                strategies[i] = _new;
                break;
            }
        }
        for (uint256 i = 0; i < withdrawQueue.length; i++) {
            if (withdrawQueue[i] == _old) {
                withdrawQueue[i] = _new;
                break;
            }
        }
        emit StrategyMigrated(
            _old,
            _new,
            strategy[_new].interestFee,
            strategy[_new].debtRatio,
            strategy[_new].debtRate,
            strategy[_new].externalDepositFee
        );
    }

    function reportEarning(
        address _strategy,
        uint256 _profit,
        uint256 _loss,
        uint256 _payback
    )
        external
        onlyPool
        returns (
            uint256 _actualPayback,
            uint256 _creditLine,
            uint256 _fee
        )
    {

        require(strategy[_strategy].active, Errors.STRATEGY_IS_NOT_ACTIVE);
        require(IVesperPool(pool).token().balanceOf(_strategy) >= (_profit + _payback), Errors.INSUFFICIENT_BALANCE);
        if (_loss != 0) {
            _reportLoss(_strategy, _loss);
        }

        uint256 _overLimitDebt = _excessDebt(_strategy);
        _actualPayback = _min(_overLimitDebt, _payback);
        if (_actualPayback != 0) {
            strategy[_strategy].totalDebt -= _actualPayback;
            totalDebt -= _actualPayback;
        }
        _creditLine = _availableCreditLimit(_strategy);
        if (_creditLine != 0) {
            strategy[_strategy].totalDebt += _creditLine;
            totalDebt += _creditLine;
        }
        if (_profit != 0) {
            strategy[_strategy].totalProfit += _profit;
            _fee = (_profit * strategy[_strategy].interestFee) / MAX_BPS;
        }
        strategy[_strategy].lastRebalance = block.number;
        emit EarningReported(
            _strategy,
            _profit,
            _loss,
            _actualPayback,
            strategy[_strategy].totalDebt,
            totalDebt,
            _creditLine
        );
        return (_actualPayback, _creditLine, _fee);
    }

    function reportLoss(address _strategy, uint256 _loss) external onlyPool {

        require(strategy[_strategy].active, Errors.STRATEGY_IS_NOT_ACTIVE);
        _reportLoss(_strategy, _loss);
    }

    function decreaseDebt(address _strategy, uint256 _decreaseBy) external onlyPool {

        _decreaseBy = _min(strategy[_strategy].totalDebt, _decreaseBy);
        strategy[_strategy].totalDebt -= _decreaseBy;
        totalDebt -= _decreaseBy;
    }


    function availableCreditLimit(address _strategy) external view returns (uint256) {

        return _availableCreditLimit(_strategy);
    }

    function excessDebt(address _strategy) external view returns (uint256) {

        return _excessDebt(_strategy);
    }

    function getStrategies() external view returns (address[] memory) {

        return strategies;
    }

    function getWithdrawQueue() external view returns (address[] memory) {

        return withdrawQueue;
    }

    function totalDebtOf(address _strategy) external view returns (uint256) {

        return strategy[_strategy].totalDebt;
    }

    function _recalculatePoolExternalDepositFee() internal {

        uint256 _len = strategies.length;
        uint256 _externalDepositFee;

        if (totalDebtRatio != 0) {
            for (uint256 i = 0; i < _len; i++) {
                _externalDepositFee +=
                    (strategy[strategies[i]].externalDepositFee * strategy[strategies[i]].debtRatio) /
                    totalDebtRatio;
            }
        }

        emit UpdatedPoolExternalDepositFee(externalDepositFee, externalDepositFee = _externalDepositFee);
    }

    function _reportLoss(address _strategy, uint256 _loss) internal {

        uint256 _currentDebt = strategy[_strategy].totalDebt;
        require(_currentDebt >= _loss, Errors.LOSS_TOO_HIGH);
        strategy[_strategy].totalLoss += _loss;
        strategy[_strategy].totalDebt -= _loss;
        totalDebt -= _loss;
        uint256 _deltaDebtRatio =
            _min((_loss * MAX_BPS) / IVesperPool(pool).totalValue(), strategy[_strategy].debtRatio);
        strategy[_strategy].debtRatio -= _deltaDebtRatio;
        totalDebtRatio -= _deltaDebtRatio;
    }

    function _availableCreditLimit(address _strategy) internal view returns (uint256) {

        if (IVesperPool(pool).stopEverything()) {
            return 0;
        }
        uint256 _totalValue = IVesperPool(pool).totalValue();
        uint256 _maxDebt = (strategy[_strategy].debtRatio * _totalValue) / MAX_BPS;
        uint256 _currentDebt = strategy[_strategy].totalDebt;
        if (_currentDebt >= _maxDebt) {
            return 0;
        }
        uint256 _poolDebtLimit = (totalDebtRatio * _totalValue) / MAX_BPS;
        if (totalDebt >= _poolDebtLimit) {
            return 0;
        }
        uint256 _available = _maxDebt - _currentDebt;
        _available = _min(_min(IVesperPool(pool).tokensHere(), _available), _poolDebtLimit - totalDebt);
        _available = _min(
            (block.number - strategy[_strategy].lastRebalance) * strategy[_strategy].debtRate,
            _available
        );
        return _available;
    }

    function _excessDebt(address _strategy) internal view returns (uint256) {

        uint256 _currentDebt = strategy[_strategy].totalDebt;
        if (IVesperPool(pool).stopEverything()) {
            return _currentDebt;
        }
        uint256 _maxDebt = (strategy[_strategy].debtRatio * IVesperPool(pool).totalValue()) / MAX_BPS;
        return _currentDebt > _maxDebt ? (_currentDebt - _maxDebt) : 0;
    }

    function _min(uint256 a, uint256 b) internal pure returns (uint256) {

        return a < b ? a : b;
    }
}