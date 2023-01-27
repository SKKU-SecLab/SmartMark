
pragma solidity 0.8.4;

interface IVault {

    function withdraw(uint256 amount) external;


    function withdraw(uint256 amount, address recipient) external;


    function withdrawByStrategyOrder(
        uint256 amount,
        address recipient,
        bool reversed
    ) external;


    function withdrawByStrategyIndex(
        uint256 amount,
        address recipient,
        uint256 strategyIndex
    ) external;


    function deposit(uint256 amount) external;


    function setStrategyDebtRatio(uint256[] calldata strategyRetios) external;


    function totalAssets() external view returns (uint256);


    function getStrategiesLength() external view returns (uint256);


    function strategyHarvestTrigger(uint256 index, uint256 callCost) external view returns (bool);


    function strategyHarvest(uint256 index) external returns (bool);


    function getStrategyAssets(uint256 index) external view returns (uint256);


    function token() external view returns (address);


    function vault() external view returns (address);


    function investTrigger() external view returns (bool);


    function invest() external;

}

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor() {
        _transferOwnership(_msgSender());
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }

    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

contract Whitelist is Ownable {

    mapping(address => bool) public whitelist;

    event LogAddToWhitelist(address indexed user);
    event LogRemoveFromWhitelist(address indexed user);

    modifier onlyWhitelist() {

        require(whitelist[msg.sender], "only whitelist");
        _;
    }

    function addToWhitelist(address user) external onlyOwner {

        require(user != address(0), "WhiteList: 0x");
        whitelist[user] = true;
        emit LogAddToWhitelist(user);
    }

    function removeFromWhitelist(address user) external onlyOwner {

        require(user != address(0), "WhiteList: 0x");
        whitelist[user] = false;
        emit LogRemoveFromWhitelist(user);
    }
}

interface ICurveMetaPool {

    function coins(uint256 i) external view returns (address);


    function get_virtual_price() external view returns (uint256);


    function get_dy_underlying(
        int128 i,
        int128 j,
        uint256 dx
    ) external view returns (uint256);


    function calc_withdraw_one_coin(uint256 _token_amount, int128 i) external view returns (uint256);


    function calc_token_amount(uint256[2] calldata inAmounts, bool deposit) external view returns (uint256);


    function exchange(
        int128 i,
        int128 j,
        uint256 dx,
        uint256 min_dy
    ) external;


    function add_liquidity(uint256[2] calldata uamounts, uint256 min_mint_amount) external;


    function remove_liquidity_one_coin(
        uint256 _token_amount,
        int128 i,
        uint256 min_uamount
    ) external;

}

interface IERC20Detailed {

    function name() external view returns (string memory);


    function symbol() external view returns (string memory);


    function decimals() external view returns (uint8);

}

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
}

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
}

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

struct StrategyParams {
    uint256 activation;
    uint256 debtRatio;
    uint256 minDebtPerHarvest;
    uint256 maxDebtPerHarvest;
    uint256 lastReport;
    uint256 totalDebt;
    uint256 totalGain;
    uint256 totalLoss;
}

interface VaultAPI {

    function decimals() external view returns (uint256);

    function token() external view returns (address);

    function vaultAdapter() external view returns (address);

    function strategies(address _strategy) external view returns (StrategyParams memory);

    function creditAvailable() external view returns (uint256);


    function debtOutstanding() external view returns (uint256);


    function expectedReturn() external view returns (uint256);


    function report(
        uint256 _gain,
        uint256 _loss,
        uint256 _debtPayment
    ) external returns (uint256);


    function revokeStrategy() external;

    function governance() external view returns (address);

}

interface StrategyAPI {

    function name() external view returns (string memory);

    function vault() external view returns (address);

    function want() external view returns (address);

    function keeper() external view returns (address);

    function isActive() external view returns (bool);

    function estimatedTotalAssets() external view returns (uint256);

    function expectedReturn() external view returns (uint256);

    function tendTrigger(uint256 callCost) external view returns (bool);

    function tend() external;

    function harvestTrigger(uint256 callCost) external view returns (bool);

    function harvest() external;

    event Harvested(uint256 profit, uint256 loss, uint256 debtPayment, uint256 debtOutstanding);
}

abstract contract BaseStrategy {
    using SafeERC20 for IERC20;

    VaultAPI public vault;
    address public rewards;
    address public keeper;

    IERC20 public want;

    event Harvested(uint256 profit, uint256 loss, uint256 debtPayment, uint256 debtOutstanding);
    event UpdatedKeeper(address newKeeper);
    event UpdatedRewards(address rewards);
    event UpdatedMinReportDelay(uint256 delay);
    event UpdatedMaxReportDelay(uint256 delay);
    event UpdatedProfitFactor(uint256 profitFactor);
    event UpdatedDebtThreshold(uint256 debtThreshold);
    event EmergencyExitEnabled();

    uint256 public minReportDelay;

    uint256 public maxReportDelay;

    uint256 public profitFactor;

    uint256 public debtThreshold;

    bool public emergencyExit;

    modifier onlyAuthorized() {
        require(msg.sender == keeper || msg.sender == owner(), "!authorized");
        _;
    }

    modifier onlyOwner() {
        require(msg.sender == owner(), "!authorized");
        _;
    }

    constructor(address _vault) {
        _initialize(_vault, msg.sender, msg.sender);
    }

    function name() external view virtual returns (string memory);

    function _initialize(
        address _vault,
        address _rewards,
        address _keeper
    ) internal {
        require(address(want) == address(0), "Strategy already initialized");

        vault = VaultAPI(_vault);
        want = IERC20(vault.token());
        want.safeApprove(_vault, type(uint256).max); // Give Vault unlimited access (might save gas)
        rewards = _rewards;
        keeper = _keeper;

        minReportDelay = 0;
        maxReportDelay = 86400;
        profitFactor = 100;
        debtThreshold = 0;
    }

    function setKeeper(address _keeper) external onlyOwner {
        require(_keeper != address(0));
        keeper = _keeper;
        emit UpdatedKeeper(_keeper);
    }

    function setMinReportDelay(uint256 _delay) external onlyAuthorized {
        minReportDelay = _delay;
        emit UpdatedMinReportDelay(_delay);
    }

    function setMaxReportDelay(uint256 _delay) external onlyAuthorized {
        maxReportDelay = _delay;
        emit UpdatedMaxReportDelay(_delay);
    }

    function setProfitFactor(uint256 _profitFactor) external onlyAuthorized {
        profitFactor = _profitFactor;
        emit UpdatedProfitFactor(_profitFactor);
    }

    function setDebtThreshold(uint256 _debtThreshold) external onlyAuthorized {
        debtThreshold = _debtThreshold;
        emit UpdatedDebtThreshold(_debtThreshold);
    }

    function owner() internal view returns (address) {
        return vault.governance();
    }

    function estimatedTotalAssets() public view virtual returns (uint256);

    function isActive() public view returns (bool) {
        return vault.strategies(address(this)).debtRatio > 0 || estimatedTotalAssets() > 0;
    }

    function prepareReturn(uint256 _debtOutstanding)
        internal
        virtual
        returns (
            uint256 _profit,
            uint256 _loss,
            uint256 _debtPayment
        );

    function adjustPosition(uint256 _debtOutstanding) internal virtual;

    function liquidatePosition(uint256 _amountNeeded)
        internal
        virtual
        returns (uint256 _liquidatedAmount, uint256 _loss);

    function tendTrigger(uint256 callCost) public view virtual returns (bool); 

    function tend() external onlyAuthorized {
        adjustPosition(vault.debtOutstanding());
    }

    function harvestTrigger(uint256 callCost) public view virtual returns (bool) {
        StrategyParams memory params = vault.strategies(address(this));

        if (params.activation == 0) return false;

        if (block.timestamp - params.lastReport < minReportDelay) return false;

        if (block.timestamp - params.lastReport >= maxReportDelay) return true;

        uint256 outstanding = vault.debtOutstanding();
        if (outstanding > debtThreshold) return true;

        uint256 total = estimatedTotalAssets();
        if (total + debtThreshold < params.totalDebt) return true;

        uint256 profit = 0;
        if (total > params.totalDebt) profit = total - params.totalDebt; // We've earned a profit!

        uint256 credit = vault.creditAvailable();
        return (profitFactor * callCost < credit + profit);
    }

    function harvest() external {
        require(msg.sender == vault.vaultAdapter(), 'harvest: Call from vault');
        uint256 profit = 0;
        uint256 loss = 0;
        uint256 debtOutstanding = vault.debtOutstanding();
        uint256 debtPayment = 0;
        if (emergencyExit) {
            uint256 totalAssets = estimatedTotalAssets();
            (debtPayment, loss) = liquidatePosition(
                totalAssets > debtOutstanding ? totalAssets : debtOutstanding
            );
            if (debtPayment > debtOutstanding) {
                profit = debtPayment - debtOutstanding;
                debtPayment = debtOutstanding;
            }
        } else {
            (profit, loss, debtPayment) = prepareReturn(debtOutstanding);
        }
        debtOutstanding = vault.report(profit, loss, debtPayment);

        adjustPosition(debtOutstanding);

        emit Harvested(profit, loss, debtPayment, debtOutstanding);
    }

    function withdraw(uint256 _amountNeeded) external returns (uint256 _loss) {
        require(msg.sender == address(vault), "!vault");
        uint256 amountFreed;
        (amountFreed, _loss) = liquidatePosition(_amountNeeded);
        want.safeTransfer(msg.sender, amountFreed);
    }

    function prepareMigration(address _newStrategy) internal virtual;

    function migrate(address _newStrategy) external {
        require(msg.sender == address(vault));
        require(BaseStrategy(_newStrategy).vault() == vault);
        prepareMigration(_newStrategy);
        want.safeTransfer(_newStrategy, want.balanceOf(address(this)));
    }

    function setEmergencyExit() external onlyAuthorized {
        emergencyExit = true;
        vault.revokeStrategy();

        emit EmergencyExitEnabled();
    }

    function protectedTokens() internal view virtual returns (address[] memory);

    function sweep(address _token) external onlyOwner {
        require(_token != address(want), "!want");
        require(_token != address(vault), "!shares");

        address[] memory _protectedTokens = protectedTokens();
        for (uint256 i; i < _protectedTokens.length; i++)
            require(_token != _protectedTokens[i], "!protected");

        IERC20(_token).safeTransfer(owner(), IERC20(_token).balanceOf(address(this)));
    }
}
interface V2YVault {

    function deposit(uint256 _amount) external;


    function deposit() external;


    function withdraw(uint256 maxShares) external returns (uint256);


    function withdraw() external returns (uint256);


    function balanceOf(address account) external view returns (uint256);


    function totalSupply() external view returns (uint256);


    function transfer(address recipient, uint256 amount) external returns (bool);


    function pricePerShare() external view returns (uint256);


    function token() external view returns (address);

}

library Math {

    function max(uint256 a, uint256 b) internal pure returns (uint256) {

        return a >= b ? a : b;
    }

    function min(uint256 a, uint256 b) internal pure returns (uint256) {

        return a < b ? a : b;
    }

    function average(uint256 a, uint256 b) internal pure returns (uint256) {

        return (a / 2) + (b / 2) + (((a % 2) + (b % 2)) / 2);
    }
}

contract StableYearnXPool is BaseStrategy {

    using SafeERC20 for IERC20;

    IERC20 public lpToken; // Meta lp token (MLP)
    address public curve = 0xbEbc44782C7dB0a1A60Cb6fe97d0b483032FF1C7;
    V2YVault public yVault = V2YVault(address(0x84E13785B5a27879921D6F685f041421C7F482dA));
    int128 wantIndex = 1;
    uint256 constant metaPool = 2;
    uint256 constant PERCENTAGE_DECIMAL_FACTOR = 10000;
    uint256 public decimals = 18;
    int256 public difference = 0;

    address public prepCurve = address(0);
    address public prepYVault = address(0);

    event LogNewMigration(address indexed yVault, address indexed curve, address lpToken);
    event LogNewMigrationPreperation(address indexed yVault, address indexed curve);
    event LogForceMigration(bool status);
    event LogMigrationCost(int256 cost);

    constructor(address _vault) public BaseStrategy(_vault) {
        profitFactor = 1000;
        debtThreshold = 1_000_000 * 1e18;
        lpToken = want;
    }

    function setMetaPool(address _yVault, address _curve) external onlyOwner {

        prepYVault = _yVault;
        prepCurve = _curve;

        emit LogNewMigrationPreperation(_yVault, _curve);
    }

    function name() external view override returns (string memory) {

        return "StrategyCurveXPool";
    }

    function resetDifference() external onlyOwner {

        difference = 0;
    }

    function estimatedTotalAssets() public view override returns (uint256) {

        (uint256 estimatedAssets, ) = _estimatedTotalAssets(true);
        return estimatedAssets;
    }

    function expectedReturn() public view returns (uint256) {

        return _expectedReturn();
    }

    function _expectedReturn() private view returns (uint256) {

        (uint256 estimatedAssets, ) = _estimatedTotalAssets(true);
        uint256 debt = vault.strategies(address(this)).totalDebt;
        if (debt > estimatedAssets) {
            return 0;
        } else {
            return estimatedAssets - debt;
        }
    }

    function prepareReturn(uint256 _debtOutstanding)
        internal
        override
        returns (
            uint256 _profit,
            uint256 _loss,
            uint256 _debtPayment
        )
    {

        uint256 lentAssets = 0;
        _debtPayment = _debtOutstanding;
        address _prepCurve = prepCurve;
        address _prepYVault = prepYVault;
        uint256 looseAssets;
        if (_prepCurve != address(0) && _prepYVault != address(0)){
            migratePool(_prepCurve, _prepYVault);
        }
        (lentAssets, looseAssets) = _estimatedTotalAssets(false);
        uint256 debt = vault.strategies(address(this)).totalDebt;

        if (lentAssets - looseAssets == 0) {
            _debtPayment = Math.min(looseAssets, _debtPayment);

            return (_profit, _loss, _debtPayment);
        }

        if (lentAssets > debt) {
            _profit = lentAssets - debt;
            uint256 amountToFree = _profit + (_debtPayment);
            if (amountToFree > 0 && looseAssets < amountToFree) {
                uint256 newLoose = _withdrawSome(amountToFree, looseAssets);

                if (newLoose < amountToFree) {
                    if (_profit > newLoose) {
                        _profit = newLoose;
                        _debtPayment = 0;
                    } else {
                        _debtPayment = Math.min(newLoose - _profit, _debtPayment);
                    }
                }
            }
        } else {
            if (_debtPayment == debt) {
                _withdrawSome(debt, looseAssets);
                _debtPayment = want.balanceOf(address(this));
                if (_debtPayment > debt) {
                    _profit = _debtPayment - debt;
                } else {
                    _loss = debt - _debtPayment;
                }
            } else {
                _loss = debt - lentAssets;
                uint256 amountToFree = _debtPayment;
                if (amountToFree > 0 && looseAssets < amountToFree) {
                    _debtPayment = _withdrawSome(amountToFree, looseAssets);
                }
            }
        }
    }

    function _withdrawSome(uint256 _amountToFree, uint256 _loose) internal returns (uint256) {

        uint256 _amount = _amountToFree - _loose;
        uint256 yBalance = yVault.balanceOf(address(this));
        uint256 lpBalance = lpToken.balanceOf(address(this));

        if (yBalance > 0 ) {
            uint256 _amount_buffered = _amount * (PERCENTAGE_DECIMAL_FACTOR + 500) / PERCENTAGE_DECIMAL_FACTOR;
            uint256 amountInYtokens = convertFromUnderlying(_amount_buffered, decimals, wantIndex);
            if (amountInYtokens > yBalance) {
                amountInYtokens = yBalance;
            }
            uint256 yValue = yVault.withdraw(amountInYtokens);
            lpBalance += yValue;
        }
        ICurveMetaPool _curve = ICurveMetaPool(curve);
        uint256 tokenAmount = _curve.calc_withdraw_one_coin(lpBalance, wantIndex);
        uint256 minAmount = tokenAmount - (tokenAmount * (9995) / (10000));

        _curve.remove_liquidity_one_coin(lpBalance, wantIndex, minAmount);

        return Math.min(_amountToFree, want.balanceOf(address(this)));
    }

    function liquidatePosition(uint256 _amountNeeded)
        internal
        override
        returns (uint256 _liquidatedAmount, uint256 _loss)
    {

        uint256 looseAssets = want.balanceOf(address(this));

        if (looseAssets < _amountNeeded) {
            _liquidatedAmount = _withdrawSome(_amountNeeded, looseAssets);
        } else {
            _liquidatedAmount = Math.min(_amountNeeded, looseAssets);
        }
        _loss = _amountNeeded - _liquidatedAmount;
        calcDifference(_loss);
    }

    function adjustPosition(uint256 _debtOutstanding) internal override {

        uint256 _wantBal = want.balanceOf(address(this));
        if (_wantBal > _debtOutstanding) {
            ICurveMetaPool _curve = ICurveMetaPool(curve);
            uint256[metaPool] memory tokenAmounts;
            tokenAmounts[uint256(int256(wantIndex))] = _wantBal;

            uint256 minAmount = _curve.calc_token_amount(tokenAmounts, true);
            minAmount = minAmount - (minAmount * (9995) / (10000));

            _curve.add_liquidity(tokenAmounts, minAmount);
            uint256 lpBalance = lpToken.balanceOf(address(this));
            yVault.deposit(lpBalance);
        }
        calcDifference(0);
    }

    function calcDifference(uint256 _loss) internal {

        uint256 debt = vault.strategies(address(this)).totalDebt;
        if (_loss > debt) debt = 0;
        if (_loss > 0) debt = debt - _loss;
        (uint256 _estimate, ) = _estimatedTotalAssets(false);
        if (debt != _estimate) {
            difference = int256(debt) - int256(_estimate);
        } else {
            difference = 0;
        }
    }

    function hardMigration() external onlyOwner() {

        prepareMigration(address(vault));
    }

    function prepareMigration(address _newStrategy) internal override {

        yVault.withdraw();
        ICurveMetaPool _curve = ICurveMetaPool(curve);

        uint256 lpBalance = lpToken.balanceOf(address(this));
        uint256 tokenAmonut = _curve.calc_withdraw_one_coin(lpBalance, wantIndex);
        uint256 minAmount = tokenAmonut - (tokenAmonut * (9995) / (10000));
        _curve.remove_liquidity_one_coin(lpToken.balanceOf(address(this)), wantIndex, minAmount);
        uint256 looseAssets = want.balanceOf(address(this));
        want.safeTransfer(_newStrategy, looseAssets);
    }

    function protectedTokens() internal view override returns (address[] memory) {

        address[] memory protected = new address[](1);
        protected[1] = address(yVault);
        protected[2] = address(lpToken);
        return protected;
    }

    function migratePool(address _prepCurve, address _prepYVault) private  {

        if (yVault.balanceOf(address(this)) > 0) {
            migrateWant();
        }
        address _lpToken = migrateYearn(_prepYVault, _prepCurve);
        emit LogNewMigration(_prepYVault, _prepCurve, _lpToken);
        prepCurve = address(0);
        prepYVault = address(0);
    }

    function migrateYearn(address _prepYVault, address _prepCurve) private returns (address){

        yVault = V2YVault(_prepYVault); // Set the yearn vault for this strategy
        curve = _prepCurve;
        address _lpToken = yVault.token();
        lpToken = IERC20(_lpToken);
        if (lpToken.allowance(address(this), _prepYVault) == 0) {
            lpToken.safeApprove(_prepYVault, type(uint256).max);
        }
        if (want.allowance(address(this), _prepCurve) == 0) {
            want.safeApprove(_prepCurve, type(uint256).max);
        }
        return _lpToken;
    }

    function migrateWant() private returns (bool) {

        yVault.withdraw();
        ICurveMetaPool _curve = ICurveMetaPool(curve);

        uint256 lpBalance = lpToken.balanceOf(address(this));
        uint256 tokenAmonut = _curve.calc_withdraw_one_coin(lpBalance, wantIndex);
        uint256 minAmount = tokenAmonut - (tokenAmonut * (9995) / (10000));

        _curve.remove_liquidity_one_coin(lpToken.balanceOf(address(this)), wantIndex, minAmount);
        return true;
    }

    function _estimatedTotalAssets(bool diff) private view returns (uint256, uint256) {

        uint256 amount = yVault.balanceOf(address(this)) * (yVault.pricePerShare()) / (uint256(10)**decimals);
        amount += lpToken.balanceOf(address(this));
        uint256 estimated = 0;
        if (amount > 0) {
            estimated = ICurveMetaPool(curve).calc_withdraw_one_coin(amount, wantIndex);
        }
        uint256 balance = want.balanceOf(address(this));
        estimated += balance;
        if (diff) {
            if (difference > int256(estimated)) return (balance, balance);
            return (uint256(int256(estimated) + (difference)), balance);
        } else {
            return (estimated, balance);
        }
    }

    function convertToUnderlying(
        uint256 amountOfTokens,
        uint256 _decimals,
        int128 index
    ) private view returns (uint256 balance) {

        if (amountOfTokens == 0) {
            balance = 0;
        } else {
            uint256 lpAmount = amountOfTokens * (yVault.pricePerShare()) / (uint256(10)**_decimals);
            balance = ICurveMetaPool(curve).calc_withdraw_one_coin(lpAmount, index);
        }
    }

    function convertFromUnderlying(
        uint256 amountOfUnderlying,
        uint256 _decimals,
        int128 index
    ) private view returns (uint256 balance) {

        if (amountOfUnderlying == 0) {
            balance = 0;
        } else {
            uint256 lpAmount = wantToLp(amountOfUnderlying, index);
            balance = lpAmount * (uint256(10)**_decimals) / (yVault.pricePerShare());
        }
    }

    function wantToLp(uint256 amount, int128 index) private view returns (uint256) {

        uint256[metaPool] memory tokenAmounts;
        tokenAmounts[uint256(int256(index))] = amount;

        return ICurveMetaPool(curve).calc_token_amount(tokenAmounts, true);
    }

    function tendTrigger(uint256 callCost) public view override returns (bool) {

        return false;
    }
}