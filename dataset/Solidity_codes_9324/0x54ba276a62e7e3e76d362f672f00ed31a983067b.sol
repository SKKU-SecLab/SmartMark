


pragma solidity ^0.7.1;


library SafeMath {


    function mul(uint256 a, uint256 b) internal pure returns (uint256 c) {

        if (a == 0) {
            return 0;
        }
        c = a * b;
        assert(c / a == b);
        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b != 0, "SafeMath: division by zero");
        return a / b;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {

        assert(b <= a);
        return a - b;
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256 c) {

        c = a + b;
        assert(c >= a);
        return c;
    }
}


pragma solidity ^0.7.1;


contract Auth {


    VaultParameters public vaultParameters;

    constructor(address _parameters) public {
        vaultParameters = VaultParameters(_parameters);
    }

    modifier onlyManager() {

        require(vaultParameters.isManager(msg.sender), "Unit Protocol: AUTH_FAILED");
        _;
    }

    modifier hasVaultAccess() {

        require(vaultParameters.canModifyVault(msg.sender), "Unit Protocol: AUTH_FAILED");
        _;
    }

    modifier onlyVault() {

        require(msg.sender == vaultParameters.vault(), "Unit Protocol: AUTH_FAILED");
        _;
    }
}


contract VaultParameters is Auth {


    mapping(address => uint) public stabilityFee;

    mapping(address => uint) public liquidationFee;

    mapping(address => uint) public tokenDebtLimit;

    mapping(address => bool) public canModifyVault;

    mapping(address => bool) public isManager;

    mapping(uint => mapping (address => bool)) public isOracleTypeEnabled;

    address payable public vault;

    address public foundation;

    constructor(address payable _vault, address _foundation) public Auth(address(this)) {
        require(_vault != address(0), "Unit Protocol: ZERO_ADDRESS");
        require(_foundation != address(0), "Unit Protocol: ZERO_ADDRESS");

        isManager[msg.sender] = true;
        vault = _vault;
        foundation = _foundation;
    }

    function setManager(address who, bool permit) external onlyManager {

        isManager[who] = permit;
    }

    function setFoundation(address newFoundation) external onlyManager {

        require(newFoundation != address(0), "Unit Protocol: ZERO_ADDRESS");
        foundation = newFoundation;
    }

    function setCollateral(
        address asset,
        uint stabilityFeeValue,
        uint liquidationFeeValue,
        uint usdpLimit,
        uint[] calldata oracles
    ) external onlyManager {

        setStabilityFee(asset, stabilityFeeValue);
        setLiquidationFee(asset, liquidationFeeValue);
        setTokenDebtLimit(asset, usdpLimit);
        for (uint i=0; i < oracles.length; i++) {
            setOracleType(oracles[i], asset, true);
        }
    }

    function setVaultAccess(address who, bool permit) external onlyManager {

        canModifyVault[who] = permit;
    }

    function setStabilityFee(address asset, uint newValue) public onlyManager {

        stabilityFee[asset] = newValue;
    }

    function setLiquidationFee(address asset, uint newValue) public onlyManager {

        require(newValue <= 100, "Unit Protocol: VALUE_OUT_OF_RANGE");
        liquidationFee[asset] = newValue;
    }

    function setOracleType(uint _type, address asset, bool enabled) public onlyManager {

        isOracleTypeEnabled[_type][asset] = enabled;
    }

    function setTokenDebtLimit(address asset, uint limit) public onlyManager {

        tokenDebtLimit[asset] = limit;
    }
}



pragma solidity ^0.7.1;

library TransferHelper {

    function safeApprove(address token, address to, uint value) internal {

        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0x095ea7b3, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'TransferHelper: APPROVE_FAILED');
    }

    function safeTransfer(address token, address to, uint value) internal {

        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0xa9059cbb, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'TransferHelper: TRANSFER_FAILED');
    }

    function safeTransferFrom(address token, address from, address to, uint value) internal {

        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0x23b872dd, from, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'TransferHelper: TRANSFER_FROM_FAILED');
    }

    function safeTransferETH(address to, uint value) internal {

        (bool success,) = to.call{value:value}(new bytes(0));
        require(success, 'TransferHelper: ETH_TRANSFER_FAILED');
    }
}


pragma solidity ^0.7.1;




contract USDP is Auth {

    using SafeMath for uint;

    string public constant name = "USDP Stablecoin";

    string public constant symbol = "USDP";

    string public constant version = "1";

    uint8 public constant decimals = 18;

    uint public totalSupply;

    mapping(address => uint) public balanceOf;

    mapping(address => mapping(address => uint)) public allowance;

    event Approval(address indexed owner, address indexed spender, uint value);

    event Transfer(address indexed from, address indexed to, uint value);

    constructor(address _parameters) public Auth(_parameters) {}

    function mint(address to, uint amount) external onlyVault {

        require(to != address(0), "Unit Protocol: ZERO_ADDRESS");

        balanceOf[to] = balanceOf[to].add(amount);
        totalSupply = totalSupply.add(amount);

        emit Transfer(address(0), to, amount);
    }

    function burn(uint amount) external onlyManager {

        _burn(msg.sender, amount);
    }

    function burn(address from, uint amount) external onlyVault {

        _burn(from, amount);
    }

    function transfer(address to, uint amount) external returns (bool) {

        return transferFrom(msg.sender, to, amount);
    }

    function transferFrom(address from, address to, uint amount) public returns (bool) {

        require(to != address(0), "Unit Protocol: ZERO_ADDRESS");
        require(balanceOf[from] >= amount, "Unit Protocol: INSUFFICIENT_BALANCE");

        if (from != msg.sender) {
            require(allowance[from][msg.sender] >= amount, "Unit Protocol: INSUFFICIENT_ALLOWANCE");
            _approve(from, msg.sender, allowance[from][msg.sender].sub(amount));
        }
        balanceOf[from] = balanceOf[from].sub(amount);
        balanceOf[to] = balanceOf[to].add(amount);

        emit Transfer(from, to, amount);
        return true;
    }

    function approve(address spender, uint amount) external returns (bool) {

        _approve(msg.sender, spender, amount);
        return true;
    }

    function increaseAllowance(address spender, uint addedValue) public virtual returns (bool) {

        _approve(msg.sender, spender, allowance[msg.sender][spender].add(addedValue));
        return true;
    }

    function decreaseAllowance(address spender, uint subtractedValue) public virtual returns (bool) {

        _approve(msg.sender, spender, allowance[msg.sender][spender].sub(subtractedValue));
        return true;
    }

    function _approve(address owner, address spender, uint amount) internal virtual {

        require(owner != address(0), "Unit Protocol: approve from the zero address");
        require(spender != address(0), "Unit Protocol: approve to the zero address");

        allowance[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _burn(address from, uint amount) internal virtual {

        balanceOf[from] = balanceOf[from].sub(amount);
        totalSupply = totalSupply.sub(amount);

        emit Transfer(from, address(0), amount);
    }
}


pragma solidity ^0.7.1;


interface IWETH {

    function deposit() external payable;

    function transfer(address to, uint value) external returns (bool);

    function withdraw(uint) external;

}


pragma solidity ^0.7.1;







contract Vault is Auth {

    using SafeMath for uint;

    address public immutable col;

    address payable public immutable weth;

    uint public constant DENOMINATOR_1E5 = 1e5;

    uint public constant DENOMINATOR_1E2 = 1e2;

    address public immutable usdp;

    mapping(address => mapping(address => uint)) public collaterals;

    mapping(address => mapping(address => uint)) public colToken;

    mapping(address => mapping(address => uint)) public debts;

    mapping(address => mapping(address => uint)) public liquidationBlock;

    mapping(address => mapping(address => uint)) public liquidationPrice;

    mapping(address => uint) public tokenDebts;

    mapping(address => mapping(address => uint)) public stabilityFee;

    mapping(address => mapping(address => uint)) public liquidationFee;

    mapping(address => mapping(address => uint)) public oracleType;

    mapping(address => mapping(address => uint)) public lastUpdate;

    modifier notLiquidating(address asset, address user) {

        require(liquidationBlock[asset][user] == 0, "Unit Protocol: LIQUIDATING_POSITION");
        _;
    }

    constructor(address _parameters, address _col, address _usdp, address payable _weth) public Auth(_parameters) {
        col = _col;
        usdp = _usdp;
        weth = _weth;
    }

    receive() external payable {
        require(msg.sender == weth, "Unit Protocol: RESTRICTED");
    }

    function update(address asset, address user) public hasVaultAccess notLiquidating(asset, user) {


        uint debtWithFee = getTotalDebt(asset, user);
        tokenDebts[asset] = tokenDebts[asset].sub(debts[asset][user]).add(debtWithFee);
        debts[asset][user] = debtWithFee;

        stabilityFee[asset][user] = vaultParameters.stabilityFee(asset);
        liquidationFee[asset][user] = vaultParameters.liquidationFee(asset);
        lastUpdate[asset][user] = block.timestamp;
    }

    function spawn(address asset, address user, uint _oracleType) external hasVaultAccess notLiquidating(asset, user) {

        oracleType[asset][user] = _oracleType;
        delete liquidationBlock[asset][user];
    }

    function destroy(address asset, address user) public hasVaultAccess notLiquidating(asset, user) {

        delete stabilityFee[asset][user];
        delete oracleType[asset][user];
        delete lastUpdate[asset][user];
        delete liquidationFee[asset][user];
    }

    function depositMain(address asset, address user, uint amount) external hasVaultAccess notLiquidating(asset, user) {

        collaterals[asset][user] = collaterals[asset][user].add(amount);
        TransferHelper.safeTransferFrom(asset, user, address(this), amount);
    }

    function depositEth(address user) external payable notLiquidating(weth, user) {

        IWETH(weth).deposit{value: msg.value}();
        collaterals[weth][user] = collaterals[weth][user].add(msg.value);
    }

    function withdrawMain(address asset, address user, uint amount) external hasVaultAccess notLiquidating(asset, user) {

        collaterals[asset][user] = collaterals[asset][user].sub(amount);
        TransferHelper.safeTransfer(asset, user, amount);
    }

    function withdrawEth(address payable user, uint amount) external hasVaultAccess notLiquidating(weth, user) {

        collaterals[weth][user] = collaterals[weth][user].sub(amount);
        IWETH(weth).withdraw(amount);
        TransferHelper.safeTransferETH(user, amount);
    }

    function depositCol(address asset, address user, uint amount) external hasVaultAccess notLiquidating(asset, user) {

        colToken[asset][user] = colToken[asset][user].add(amount);
        TransferHelper.safeTransferFrom(col, user, address(this), amount);
    }

    function withdrawCol(address asset, address user, uint amount) external hasVaultAccess notLiquidating(asset, user) {

        colToken[asset][user] = colToken[asset][user].sub(amount);
        TransferHelper.safeTransfer(col, user, amount);
    }

    function borrow(
        address asset,
        address user,
        uint amount
    )
    external
    hasVaultAccess
    notLiquidating(asset, user)
    returns(uint)
    {

        require(vaultParameters.isOracleTypeEnabled(oracleType[asset][user], asset), "Unit Protocol: WRONG_ORACLE_TYPE");
        update(asset, user);
        debts[asset][user] = debts[asset][user].add(amount);
        tokenDebts[asset] = tokenDebts[asset].add(amount);

        require(tokenDebts[asset] <= vaultParameters.tokenDebtLimit(asset), "Unit Protocol: ASSET_DEBT_LIMIT");

        USDP(usdp).mint(user, amount);

        return debts[asset][user];
    }

    function repay(
        address asset,
        address user,
        uint amount
    )
    external
    hasVaultAccess
    notLiquidating(asset, user)
    returns(uint)
    {

        uint debt = debts[asset][user];
        debts[asset][user] = debt.sub(amount);
        tokenDebts[asset] = tokenDebts[asset].sub(amount);
        USDP(usdp).burn(user, amount);

        return debts[asset][user];
    }

    function chargeFee(address asset, address user, uint amount) external hasVaultAccess notLiquidating(asset, user) {

        if (amount != 0) {
            TransferHelper.safeTransferFrom(asset, user, vaultParameters.foundation(), amount);
        }
    }

    function triggerLiquidation(
        address asset,
        address positionOwner,
        uint initialPrice
    )
    external
    hasVaultAccess
    notLiquidating(asset, positionOwner)
    {

        require(vaultParameters.isOracleTypeEnabled(oracleType[asset][positionOwner], asset), "Unit Protocol: WRONG_ORACLE_TYPE");

        debts[asset][positionOwner] = getTotalDebt(asset, positionOwner);

        liquidationBlock[asset][positionOwner] = block.number;
        liquidationPrice[asset][positionOwner] = initialPrice;
    }

    function liquidate(
        address asset,
        address positionOwner,
        uint mainAssetToLiquidator,
        uint colToLiquidator,
        uint mainAssetToPositionOwner,
        uint colToPositionOwner,
        uint repayment,
        uint penalty,
        address liquidator
    )
        external
        hasVaultAccess
    {

        require(liquidationBlock[asset][positionOwner] != 0, "Unit Protocol: NOT_TRIGGERED_LIQUIDATION");

        uint mainAssetInPosition = collaterals[asset][positionOwner];
        uint mainAssetToFoundation = mainAssetInPosition.sub(mainAssetToLiquidator).sub(mainAssetToPositionOwner);

        uint colInPosition = colToken[asset][positionOwner];
        uint colToFoundation = colInPosition.sub(colToLiquidator).sub(colToPositionOwner);

        delete liquidationPrice[asset][positionOwner];
        delete liquidationBlock[asset][positionOwner];
        delete debts[asset][positionOwner];
        delete collaterals[asset][positionOwner];
        delete colToken[asset][positionOwner];

        destroy(asset, positionOwner);

        if (repayment > penalty) {
            if (penalty != 0) {
                TransferHelper.safeTransferFrom(usdp, liquidator, vaultParameters.foundation(), penalty);
            }
            USDP(usdp).burn(liquidator, repayment.sub(penalty));
        } else {
            if (repayment != 0) {
                TransferHelper.safeTransferFrom(usdp, liquidator, vaultParameters.foundation(), repayment);
            }
        }

        if (mainAssetToLiquidator != 0) {
            TransferHelper.safeTransfer(asset, liquidator, mainAssetToLiquidator);
        }

        if (colToLiquidator != 0) {
            TransferHelper.safeTransfer(col, liquidator, colToLiquidator);
        }

        if (mainAssetToPositionOwner != 0) {
            TransferHelper.safeTransfer(asset, positionOwner, mainAssetToPositionOwner);
        }

        if (colToPositionOwner != 0) {
            TransferHelper.safeTransfer(col, positionOwner, colToPositionOwner);
        }

        if (mainAssetToFoundation != 0) {
            TransferHelper.safeTransfer(asset, vaultParameters.foundation(), mainAssetToFoundation);
        }

        if (colToFoundation != 0) {
            TransferHelper.safeTransfer(col, vaultParameters.foundation(), colToFoundation);
        }
    }

    function changeOracleType(address asset, address user, uint newOracleType) external onlyManager {

        oracleType[asset][user] = newOracleType;
    }

    function getTotalDebt(address asset, address user) public view returns (uint) {

        uint debt = debts[asset][user];
        if (liquidationBlock[asset][user] != 0) return debt;
        uint fee = calculateFee(asset, user, debt);
        return debt.add(fee);
    }

    function calculateFee(address asset, address user, uint amount) public view returns (uint) {

        uint sFeePercent = stabilityFee[asset][user];
        uint timePast = block.timestamp.sub(lastUpdate[asset][user]);

        return amount.mul(sFeePercent).mul(timePast).div(365 days).div(DENOMINATOR_1E5);
    }
}


pragma solidity ^0.7.1;

library Math {

    function max(uint256 a, uint256 b) internal pure returns (uint256) {

        return a >= b ? a : b;
    }

    function min(uint256 a, uint256 b) internal pure returns (uint256) {

        return a < b ? a : b;
    }

    function average(uint256 a, uint256 b) internal pure returns (uint256) {

        return (a / 2) + (b / 2) + ((a % 2 + b % 2) / 2);
    }
}


pragma solidity ^0.7.1;

contract ReentrancyGuard {


    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor () public {
        _status = _NOT_ENTERED;
    }

    modifier nonReentrant() {

        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        _status = _ENTERED;

        _;

        _status = _NOT_ENTERED;
    }
}


pragma solidity ^0.7.1;

contract VaultManagerParameters is Auth {


    mapping(address => uint) public minColPercent;

    mapping(address => uint) public maxColPercent;

    mapping(address => uint) public initialCollateralRatio;

    mapping(address => uint) public liquidationRatio;

    mapping(address => uint) public liquidationDiscount;

    mapping(address => uint) public devaluationPeriod;

    constructor(address _vaultParameters) public Auth(_vaultParameters) {}

    function setCollateral(
        address asset,
        uint stabilityFeeValue,
        uint liquidationFeeValue,
        uint initialCollateralRatioValue,
        uint liquidationRatioValue,
        uint liquidationDiscountValue,
        uint devaluationPeriodValue,
        uint usdpLimit,
        uint[] calldata oracles,
        uint minColP,
        uint maxColP
    ) external onlyManager {

        vaultParameters.setCollateral(asset, stabilityFeeValue, liquidationFeeValue, usdpLimit, oracles);
        setInitialCollateralRatio(asset, initialCollateralRatioValue);
        setLiquidationRatio(asset, liquidationRatioValue);
        setDevaluationPeriod(asset, devaluationPeriodValue);
        setLiquidationDiscount(asset, liquidationDiscountValue);
        setColPartRange(asset, minColP, maxColP);
    }

    function setInitialCollateralRatio(address asset, uint newValue) public onlyManager {

        require(newValue != 0 && newValue <= 100, "Unit Protocol: INCORRECT_COLLATERALIZATION_VALUE");
        initialCollateralRatio[asset] = newValue;
    }

    function setLiquidationRatio(address asset, uint newValue) public onlyManager {

        require(newValue != 0 && newValue >= initialCollateralRatio[asset], "Unit Protocol: INCORRECT_COLLATERALIZATION_VALUE");
        liquidationRatio[asset] = newValue;
    }

    function setLiquidationDiscount(address asset, uint newValue) public onlyManager {

        require(newValue < 1e5, "Unit Protocol: INCORRECT_DISCOUNT_VALUE");
        liquidationDiscount[asset] = newValue;
    }

    function setDevaluationPeriod(address asset, uint newValue) public onlyManager {

        require(newValue != 0, "Unit Protocol: INCORRECT_DEVALUATION_VALUE");
        devaluationPeriod[asset] = newValue;
    }

    function setColPartRange(address asset, uint min, uint max) public onlyManager {

        require(max <= 100 && min <= max, "Unit Protocol: WRONG_RANGE");
        minColPercent[asset] = min;
        maxColPercent[asset] = max;
    }
}


pragma solidity ^0.7.1;


abstract contract OracleSimple {
    function assetToUsd(address asset, uint amount) public virtual view returns (uint);
}


abstract contract OracleSimplePoolToken is OracleSimple {
    ChainlinkedOracleSimple public oracleMainAsset;
}


abstract contract ChainlinkedOracleSimple is OracleSimple {
    address public WETH;
    function ethToUsd(uint ethAmount) public virtual view returns (uint);
    function assetToEth(address asset, uint amount) public virtual view returns (uint);
}


pragma solidity ^0.7.1;


contract VaultManagerKeep3rSushiSwapMainAsset is ReentrancyGuard {

    using SafeMath for uint;

    Vault public immutable vault;
    VaultManagerParameters public immutable vaultManagerParameters;
    ChainlinkedOracleSimple public immutable oracle;
    uint public constant ORACLE_TYPE = 7;
    uint public constant Q112 = 2 ** 112;

    event Join(address indexed asset, address indexed user, uint main, uint usdp);

    event Exit(address indexed asset, address indexed user, uint main, uint usdp);

    modifier spawned(address asset, address user) {


        require(vault.getTotalDebt(asset, user) != 0, "Unit Protocol: NOT_SPAWNED_POSITION");
        require(vault.oracleType(asset, user) == ORACLE_TYPE, "Unit Protocol: WRONG_ORACLE_TYPE");
        _;
    }

    constructor(address _vaultManagerParameters, address _keep3rOracleSushiSwapMainAsset) public {
        vaultManagerParameters = VaultManagerParameters(_vaultManagerParameters);
        vault = Vault(VaultManagerParameters(_vaultManagerParameters).vaultParameters().vault());
        oracle = ChainlinkedOracleSimple(_keep3rOracleSushiSwapMainAsset);
    }

    function spawn(address asset, uint mainAmount, uint usdpAmount) public nonReentrant {

        require(usdpAmount != 0, "Unit Protocol: ZERO_BORROWING");

        require(vault.getTotalDebt(asset, msg.sender) == 0, "Unit Protocol: SPAWNED_POSITION");

        require(vault.vaultParameters().isOracleTypeEnabled(ORACLE_TYPE, asset), "Unit Protocol: WRONG_ORACLE_TYPE");

        vault.spawn(asset, msg.sender, ORACLE_TYPE);

        _depositAndBorrow(asset, msg.sender, mainAmount, usdpAmount);

        emit Join(asset, msg.sender, mainAmount, usdpAmount);
    }

    function spawn_Eth(uint usdpAmount) public payable nonReentrant {

        require(usdpAmount != 0, "Unit Protocol: ZERO_BORROWING");

        require(vault.getTotalDebt(vault.weth(), msg.sender) == 0, "Unit Protocol: SPAWNED_POSITION");

        require(vault.vaultParameters().isOracleTypeEnabled(ORACLE_TYPE, vault.weth()), "Unit Protocol: WRONG_ORACLE_TYPE");

        vault.spawn(vault.weth(), msg.sender, ORACLE_TYPE);

        _depositAndBorrow_Eth(msg.sender, usdpAmount);

        emit Join(vault.weth(), msg.sender, msg.value, usdpAmount);
    }

    function depositAndBorrow(
        address asset,
        uint mainAmount,
        uint usdpAmount
    )
    public
    spawned(asset, msg.sender)
    nonReentrant
    {

        require(usdpAmount != 0, "Unit Protocol: ZERO_BORROWING");

        _depositAndBorrow(asset, msg.sender, mainAmount, usdpAmount);

        emit Join(asset, msg.sender, mainAmount, usdpAmount);
    }

    function depositAndBorrow_Eth(uint usdpAmount) public payable spawned(vault.weth(), msg.sender) nonReentrant {

        require(usdpAmount != 0, "Unit Protocol: ZERO_BORROWING");

        _depositAndBorrow_Eth(msg.sender, usdpAmount);

        emit Join(vault.weth(), msg.sender, msg.value, usdpAmount);
    }

    function withdrawAndRepay(
        address asset,
        uint mainAmount,
        uint usdpAmount
    )
    public
    spawned(asset, msg.sender)
    nonReentrant
    {

        require(mainAmount != 0, "Unit Protocol: USELESS_TX");

        uint debt = vault.debts(asset, msg.sender);
        require(debt != 0 && usdpAmount != debt, "Unit Protocol: USE_REPAY_ALL_INSTEAD");

        if (mainAmount != 0) {
            vault.withdrawMain(asset, msg.sender, mainAmount);
        }

        if (usdpAmount != 0) {
            uint fee = vault.calculateFee(asset, msg.sender, usdpAmount);
            vault.chargeFee(vault.usdp(), msg.sender, fee);
            vault.repay(asset, msg.sender, usdpAmount);
        }

        vault.update(asset, msg.sender);

        _ensurePositionCollateralization(asset, msg.sender);

        emit Exit(asset, msg.sender, mainAmount, usdpAmount);
    }

    function withdrawAndRepay_Eth(
        uint ethAmount,
        uint usdpAmount
    )
    public
    spawned(vault.weth(), msg.sender)
    nonReentrant
    {

        require(ethAmount != 0, "Unit Protocol: USELESS_TX");

        uint debt = vault.debts(vault.weth(), msg.sender);
        require(debt != 0 && usdpAmount != debt, "Unit Protocol: USE_REPAY_ALL_INSTEAD");

        if (ethAmount != 0) {
            vault.withdrawEth(msg.sender, ethAmount);
        }

        if (usdpAmount != 0) {
            uint fee = vault.calculateFee(vault.weth(), msg.sender, usdpAmount);
            vault.chargeFee(vault.usdp(), msg.sender, fee);
            vault.repay(vault.weth(), msg.sender, usdpAmount);
        }

        vault.update(vault.weth(), msg.sender);

        _ensurePositionCollateralization_Eth(msg.sender);

        emit Exit(vault.weth(), msg.sender, ethAmount, usdpAmount);
    }

    function _depositAndBorrow(
        address asset,
        address user,
        uint mainAmount,
        uint usdpAmount
    )
    internal
    {

        if (mainAmount != 0) {
            vault.depositMain(asset, user, mainAmount);
        }

        vault.borrow(asset, user, usdpAmount);

        _ensurePositionCollateralization(asset, user);
    }

    function _depositAndBorrow_Eth(address user, uint usdpAmount) internal {

        if (msg.value != 0) {
            vault.depositEth{value:msg.value}(user);
        }

        vault.borrow(vault.weth(), user, usdpAmount);

        _ensurePositionCollateralization_Eth(user);
    }

    function _ensurePositionCollateralization(
        address asset,
        address user
    )
    internal
    view
    {

        uint mainUsdValue_q112 = oracle.assetToUsd(asset, vault.collaterals(asset, user));

        _ensureCollateralization(asset, user, mainUsdValue_q112);
    }

    function _ensurePositionCollateralization_Eth(address user) internal view {

        uint ethUsdValue_q112 = oracle.ethToUsd(vault.collaterals(vault.weth(), user).mul(Q112));

        _ensureCollateralization(vault.weth(), user, ethUsdValue_q112);
    }

    function _ensureCollateralization(
        address asset,
        address user,
        uint mainUsdValue_q112
    )
    internal
    view
    {

        uint usdLimit = mainUsdValue_q112 * vaultManagerParameters.initialCollateralRatio(asset) / Q112 / 100;

        require(vault.getTotalDebt(asset, user) <= usdLimit, "Unit Protocol: UNDERCOLLATERALIZED");
    }
}