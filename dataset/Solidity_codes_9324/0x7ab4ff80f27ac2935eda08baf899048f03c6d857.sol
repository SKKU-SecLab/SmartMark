
pragma solidity 0.7.6;


interface ISwapper {


    function predictAssetOut(address _asset, uint256 _usdpAmountIn) external view returns (uint predictedAssetAmount);


    function predictUsdpOut(address _asset, uint256 _assetAmountIn) external view returns (uint predictedUsdpAmount);


    function swapUsdpToAsset(address _user, address _asset, uint256 _usdpAmount, uint256 _minAssetAmount) external returns (uint swappedAssetAmount);


    function swapAssetToUsdp(address _user, address _asset, uint256 _assetAmount, uint256 _minUsdpAmount) external returns (uint swappedUsdpAmount);


    function swapUsdpToAssetWithDirectSending(address _user, address _asset, uint256 _usdpAmount, uint256 _minAssetAmount) external returns (uint swappedAssetAmount);


    function swapAssetToUsdpWithDirectSending(address _user, address _asset, uint256 _assetAmount, uint256 _minUsdpAmount) external returns (uint swappedUsdpAmount);

}// bsl-1.1

pragma solidity 0.7.6;



interface ISwappersRegistry {

    event SwapperAdded(ISwapper swapper);
    event SwapperRemoved(ISwapper swapper);

    function getSwapperId(ISwapper _swapper) external view returns (uint);

    function getSwapper(uint _id) external view returns (ISwapper);

    function hasSwapper(ISwapper _swapper) external view returns (bool);


    function getSwappersLength() external view returns (uint);

    function getSwappers() external view returns (ISwapper[] memory);

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



contract Auth2 {


    VaultParameters public immutable vaultParameters;

    constructor(address _parameters) {
        require(_parameters != address(0), "Unit Protocol: ZERO_ADDRESS");

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
}// bsl-1.1

pragma solidity 0.7.6;



contract SwappersRegistry is ISwappersRegistry, Auth2 {


    struct SwapperInfo {
        uint240 id;
        bool exists;
    }

    mapping(ISwapper => SwapperInfo) internal swappersInfo;
    ISwapper[] internal swappers;

    constructor(address _vaultParameters) Auth2(_vaultParameters) {}

    function getSwappersLength() external view override returns (uint) {

        return swappers.length;
    }

    function getSwapperId(ISwapper _swapper) external view override returns (uint) {

        require(hasSwapper(_swapper), "Unit Protocol Swappers: SWAPPER_IS_NOT_EXIST");

        return uint(swappersInfo[_swapper].id);
    }

    function getSwapper(uint _id) external view override returns (ISwapper) {

        return swappers[_id];
    }

    function hasSwapper(ISwapper _swapper) public view override returns (bool) {

        return swappersInfo[_swapper].exists;
    }

    function getSwappers() external view override returns (ISwapper[] memory) {

        return swappers;
    }

    function add(ISwapper _swapper) public onlyManager {

        require(address(_swapper) != address(0), "Unit Protocol Swappers: ZERO_ADDRESS");
        require(!hasSwapper(_swapper), "Unit Protocol Swappers: SWAPPER_ALREADY_EXISTS");

        swappers.push(_swapper);
        swappersInfo[_swapper] = SwapperInfo(uint240(swappers.length - 1), true);

        emit SwapperAdded(_swapper);
    }

    function remove(ISwapper _swapper) public onlyManager {

        require(address(_swapper) != address(0), "Unit Protocol Swappers: ZERO_ADDRESS");
        require(hasSwapper(_swapper), "Unit Protocol Swappers: SWAPPER_IS_NOT_EXIST");

        uint id = uint(swappersInfo[_swapper].id);
        delete swappersInfo[_swapper];

        uint lastId = swappers.length - 1;
        if (id != lastId) {
            ISwapper lastSwapper = swappers[lastId];
            swappers[id] = lastSwapper;
            swappersInfo[lastSwapper] = SwapperInfo(uint240(id), true);
        }
        swappers.pop();

        emit SwapperRemoved(_swapper);
    }
}