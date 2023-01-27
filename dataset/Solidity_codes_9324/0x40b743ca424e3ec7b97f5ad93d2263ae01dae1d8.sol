
pragma solidity 0.7.6;


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
}// bsl-1.1

pragma solidity 0.7.6;


interface ERC20Like {

    function balanceOf(address) external view returns (uint);

    function decimals() external view returns (uint8);

    function transfer(address, uint256) external returns (bool);

    function transferFrom(address, address, uint256) external returns (bool);

    function totalSupply() external view returns (uint256);

}// bsl-1.1

pragma solidity ^0.7.6;

interface IcyToken {

    function underlying() external view returns (address);

    function implementation() external view returns (address);

    function decimals() external view returns (uint8);

    function exchangeRateStored() external view returns (uint);

}// bsl-1.1

pragma solidity ^0.7.6;

interface IOracleUsd {


    function assetToUsd(address asset, uint amount) external view returns (uint);

}// bsl-1.1

pragma solidity ^0.7.6;
pragma abicoder v2;

interface IOracleRegistry {


    struct Oracle {
        uint oracleType;
        address oracleAddress;
    }

    function WETH (  ) external view returns ( address );
    function getKeydonixOracleTypes (  ) external view returns ( uint256[] memory );
    function getOracles (  ) external view returns ( Oracle[] memory foundOracles );
    function keydonixOracleTypes ( uint256 ) external view returns ( uint256 );
    function maxOracleType (  ) external view returns ( uint256 );
    function oracleByAsset ( address asset ) external view returns ( address );
    function oracleByType ( uint256 ) external view returns ( address );
    function oracleTypeByAsset ( address ) external view returns ( uint256 );
    function oracleTypeByOracle ( address ) external view returns ( uint256 );
    function setKeydonixOracleTypes ( uint256[] memory _keydonixOracleTypes ) external;
    function setOracle ( uint256 oracleType, address oracle ) external;
    function setOracleTypeForAsset ( address asset, uint256 oracleType ) external;
    function setOracleTypeForAssets ( address[] memory assets, uint256 oracleType ) external;
    function unsetOracle ( uint256 oracleType ) external;
    function unsetOracleForAsset ( address asset ) external;
    function unsetOracleForAssets ( address[] memory assets ) external;
    function vaultParameters (  ) external view returns ( address );
}// bsl-1.1

pragma solidity ^0.7.6;

interface IOracleEth {


    function assetToEth(address asset, uint amount) external view returns (uint);


    function ethToUsd(uint amount) external view returns (uint);


    function usdToEth(uint amount) external view returns (uint);

}// bsl-1.1

pragma solidity 0.7.6;



contract Auth {


    VaultParameters public vaultParameters;

    constructor(address _parameters) {
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

    constructor(address payable _vault, address _foundation) Auth(address(this)) {
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
}// bsl-1.1

pragma solidity 0.7.6;



contract CyTokenOracle is IOracleUsd, Auth  {

    using SafeMath for uint;

    uint constant expScale = 1e18;

    mapping (address => bool) public enabledImplementations;

    IOracleRegistry public immutable oracleRegistry;

    event ImplementationChanged(address indexed implementation, bool enabled);

    constructor(address _vaultParameters, address _oracleRegistry, address[] memory impls) Auth(_vaultParameters) {
        require(_vaultParameters != address(0) && _oracleRegistry != address(0), "Unit Protocol: ZERO_ADDRESS");
        oracleRegistry = IOracleRegistry(_oracleRegistry);
        for (uint i = 0; i < impls.length; i++) {
          require(impls[i] != address(0), "Unit Protocol: ZERO_ADDRESS");
          enabledImplementations[impls[i]] = true;
          emit ImplementationChanged(impls[i], true);
        }
    }

    function setImplementation(address impl, bool enable) external onlyManager {

      require(impl != address(0), "Unit Protocol: ZERO_ADDRESS");
      enabledImplementations[impl] = enable;
      emit ImplementationChanged(impl, enable);
    }

    function assetToUsd(address bearing, uint amount) public override view returns (uint) {

        if (amount == 0) return 0;
        (address underlying, uint underlyingAmount) = bearingToUnderlying(bearing, amount);
        IOracleUsd _oracleForUnderlying = IOracleUsd(oracleRegistry.oracleByAsset(underlying));
        require(address(_oracleForUnderlying) != address(0), "Unit Protocol: ORACLE_NOT_FOUND");
        return _oracleForUnderlying.assetToUsd(underlying, underlyingAmount);
    }

    function bearingToUnderlying(address bearing, uint amount) public view returns (address, uint) {

        address _underlying = IcyToken(bearing).underlying();
        require(_underlying != address(0), "Unit Protocol: UNDEFINED_UNDERLYING");
        address _implementation = IcyToken(bearing).implementation();
        require(enabledImplementations[_implementation], "Unit Protocol: UNSUPPORTED_CYTOKEN_IMPLEMENTATION");
        uint _exchangeRateStored = IcyToken(bearing).exchangeRateStored();
        uint _totalSupply = ERC20Like(bearing).totalSupply();
        require(amount <= _totalSupply, "Unit Protocol: AMOUNT_EXCEEDS_SUPPLY");
        return (_underlying, amount.mul(_exchangeRateStored).div(expScale));
    }

}