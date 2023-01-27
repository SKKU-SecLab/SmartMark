


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