
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

pragma solidity ^0.7.6;

interface IVaultManagerBorrowFeeParameters {


    function BASIS_POINTS_IN_1() external view returns (uint);


    function feeReceiver() external view returns (address);


    function setFeeReceiver(address newFeeReceiver) external;


    function setBaseBorrowFee(uint16 newBaseBorrowFeeBasisPoints) external;


    function setAssetBorrowFee(address asset, bool newEnabled, uint16 newFeeBasisPoints) external;


    function getBorrowFee(address asset) external view returns (uint16 feeBasisPoints);


    function calcBorrowFeeAmount(address asset, uint usdpAmount) external view returns (uint);

}// bsl-1.1

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



contract VaultManagerBorrowFeeParameters is Auth, IVaultManagerBorrowFeeParameters {

    using SafeMath for uint;

    uint public constant override BASIS_POINTS_IN_1 = 1e4;

    struct AssetBorrowFeeParams {
        bool enabled; // is custom fee for asset enabled
        uint16 feeBasisPoints; // fee basis points, 1 basis point = 0.0001
    }

    mapping(address => AssetBorrowFeeParams) public assetBorrowFee;
    uint16 public baseBorrowFeeBasisPoints;

    address public override feeReceiver;

    event AssetBorrowFeeParamsEnabled(address asset, uint16 feeBasisPoints);
    event AssetBorrowFeeParamsDisabled(address asset);

    modifier nonZeroAddress(address addr) {

        require(addr != address(0), "Unit Protocol: ZERO_ADDRESS");
        _;
    }

    modifier correctFee(uint16 fee) {

        require(fee < BASIS_POINTS_IN_1, "Unit Protocol: INCORRECT_FEE_VALUE");
        _;
    }

    constructor(address _vaultParameters, uint16 _baseBorrowFeeBasisPoints, address _feeReceiver)
        Auth(_vaultParameters)
        nonZeroAddress(_feeReceiver)
        correctFee(_baseBorrowFeeBasisPoints)
    {
        baseBorrowFeeBasisPoints = _baseBorrowFeeBasisPoints;
        feeReceiver = _feeReceiver;
    }

    function setFeeReceiver(address newFeeReceiver) external override onlyManager nonZeroAddress(newFeeReceiver) {

        feeReceiver = newFeeReceiver;
    }

    function setBaseBorrowFee(uint16 newBaseBorrowFeeBasisPoints) external override onlyManager correctFee(newBaseBorrowFeeBasisPoints) {

        baseBorrowFeeBasisPoints = newBaseBorrowFeeBasisPoints;
    }

    function setAssetBorrowFee(address asset, bool newEnabled, uint16 newFeeBasisPoints) external override onlyManager correctFee(newFeeBasisPoints) {

        assetBorrowFee[asset].enabled = newEnabled;
        assetBorrowFee[asset].feeBasisPoints = newFeeBasisPoints;

        if (newEnabled) {
            emit AssetBorrowFeeParamsEnabled(asset, newFeeBasisPoints);
        } else {
            emit AssetBorrowFeeParamsDisabled(asset);
        }
    }

    function getBorrowFee(address asset) public override view returns (uint16 feeBasisPoints) {

        if (assetBorrowFee[asset].enabled) {
            return assetBorrowFee[asset].feeBasisPoints;
        }

        return baseBorrowFeeBasisPoints;
    }

    function calcBorrowFeeAmount(address asset, uint usdpAmount) external override view returns (uint) {

        uint16 borrowFeeBasisPoints = getBorrowFee(asset);
        if (borrowFeeBasisPoints == 0) {
            return 0;
        }

        return usdpAmount.mul(uint(borrowFeeBasisPoints)).div(BASIS_POINTS_IN_1);
    }
}