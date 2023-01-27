


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


interface ERC20Like {

    function balanceOf(address) external view returns (uint);

    function transfer(address, uint256) external returns (bool);

    function transferFrom(address, address, uint256) external returns (bool);

    function totalSupply() external view returns (uint256);

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


contract OracleRegistry is Auth {


    mapping(address => address) public oracleByAsset;

    mapping(uint => address) public oracleByType;

    constructor(address vaultParameters) Auth(vaultParameters) {
        require(vaultParameters != address(0), "Unit Protocol: ZERO_ADDRESS");
    }

    function setOracle(address asset, address oracle, uint oracleType) public onlyManager {

        require(asset != address(0) && oracleType != 0, "Unit Protocol: INVALID_ARGS");
        oracleByAsset[asset] = oracle;
        oracleByType[oracleType] = oracle;
    }

}







contract BearingAssetOracleSimple is OracleSimple, Auth {


    OracleRegistry public immutable oracleRegistry;

    mapping (address => address) underlyings;

    constructor(address _vaultParameters, address _oracleRegistry) Auth(_vaultParameters) {
        require(_vaultParameters != address(0) && _oracleRegistry != address(0), "Unit Protocol: ZERO_ADDRESS");
        oracleRegistry = OracleRegistry(_oracleRegistry);
    }

    function setUnderlying(address bearing, address underlying) external onlyManager {

        underlyings[bearing] = underlying;
    }

    function assetToUsd(address bearing, uint amount) public override view returns (uint) {

        if (amount == 0) return 0;
        (address underlying, uint underlyingAmount) = bearingToUnderlying(bearing, amount);
        OracleSimple _oracleForUnderlying = OracleSimple(oracleRegistry.oracleByAsset(underlying));
        return _oracleForUnderlying.assetToUsd(underlying, underlyingAmount);
    }

    function bearingToUnderlying(address bearing, uint amount) public view returns (address, uint) {

        address _underlying = underlyings[bearing];
        require(_underlying != address(0), "Unit Protocol: UNDEFINED_UNDERLYING");
        uint _reserve = ERC20Like(_underlying).balanceOf(address(bearing));
        uint _totalSupply = ERC20Like(bearing).totalSupply();
        require(amount <= _totalSupply, "Unit Protocol: AMOUNT_EXCEEDS_SUPPLY");
        return (_underlying, amount * _reserve / _totalSupply);
    }

}