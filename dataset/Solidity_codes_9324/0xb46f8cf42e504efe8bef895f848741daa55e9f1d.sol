


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