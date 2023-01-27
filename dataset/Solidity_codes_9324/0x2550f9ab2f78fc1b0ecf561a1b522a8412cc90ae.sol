pragma solidity ^0.6.6;


library Address {

    function isContract(address account) internal view returns (bool) {

        bytes32 codehash;
        bytes32 accountHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;
        assembly { codehash := extcodehash(account) }
        return (codehash != accountHash && codehash != 0x0);
    }

    function sendValue(address payable recipient, uint256 amount) internal {

        require(address(this).balance >= amount, "Address: insufficient balance");

        (bool success, ) = recipient.call{ value: amount }("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }
}
pragma solidity ^0.6.6;


contract ACOProxy {

    
    event ProxyAdminUpdated(address previousAdmin, address newAdmin);
    
    event SetImplementation(address previousImplementation, address newImplementation);
    
    bytes32 private constant adminPosition = keccak256("acoproxy.admin");
    
    bytes32 private constant implementationPosition = keccak256("acoproxy.implementation");

    modifier onlyAdmin() {

        require(msg.sender == admin(), "ACOProxy::onlyAdmin");
        _;
    }
    
    constructor(address _admin, address _implementation, bytes memory _initdata) public {
        _setAdmin(_admin);
        _setImplementation(_implementation, _initdata);
    }

    fallback() external payable {
        address addr = implementation();
        assembly {
            calldatacopy(0, 0, calldatasize())
            let result := delegatecall(gas(), addr, 0, calldatasize(), 0, 0)
            returndatacopy(0, 0, returndatasize())
            switch result
            case 0 { revert(0, returndatasize()) }
            default { return(0, returndatasize()) }
        }
    }
    
    function proxyType() public pure returns(uint256) {

        return 2; 
    }
    
    function admin() public view returns (address adm) {

        bytes32 position = adminPosition;
        assembly {
            adm := sload(position)
        }
    }
    
    function implementation() public view returns (address impl) {

        bytes32 position = implementationPosition;
        assembly {
            impl := sload(position)
        }
    }

    function transferProxyAdmin(address newAdmin) external onlyAdmin {

        _setAdmin(newAdmin);
    }
    
    function setImplementation(address newImplementation, bytes calldata initData) external onlyAdmin {

        _setImplementation(newImplementation, initData);
    }

    function _setAdmin(address newAdmin) internal {

        require(newAdmin != address(0), "ACOProxy::_setAdmin: Invalid admin");
        
        emit ProxyAdminUpdated(admin(), newAdmin);
        
        bytes32 position = adminPosition;
        assembly {
            sstore(position, newAdmin)
        }
    }
    
    function _setImplementation(address newImplementation, bytes memory initData) internal {

        require(Address.isContract(newImplementation), "ACOProxy::_setImplementation: Invalid implementation");
        
        emit SetImplementation(implementation(), newImplementation);
        
        bytes32 position = implementationPosition;
        assembly {
            sstore(position, newImplementation)
        }
        if (initData.length > 0) {
            (bool success,) = newImplementation.delegatecall(initData);
            assert(success);
        }
    }
}
pragma solidity ^0.6.6;


interface IERC20 {

    function totalSupply() external view returns (uint256);


    function balanceOf(address account) external view returns (uint256);


    function transfer(address recipient, uint256 amount) external returns (bool);


    function allowance(address owner, address spender) external view returns (uint256);


    function approve(address spender, uint256 amount) external returns (bool);


    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);


    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}
pragma solidity ^0.6.6;
pragma experimental ABIEncoderV2;


interface IACOPool2 is IERC20 {


    struct InitData {
        address acoFactory;
        address lendingPool;
        address underlying;
        address strikeAsset;
        bool isCall; 
        uint256 baseVolatility;  
        address admin;
        address strategy;  
        bool isPrivate;
        uint256 poolId;
        PoolAcoPermissionConfigV2 acoPermissionConfigV2;
        PoolProtocolConfig protocolConfig;
    }

	struct AcoData {
        bool open;
        uint256 valueSold;
        uint256 collateralLocked;
        uint256 collateralRedeemed;
        uint256 index;
		uint256 openIndex;
    }
    
    struct PoolAcoPermissionConfig {
        uint256 tolerancePriceBelowMin;
        uint256 tolerancePriceBelowMax;
        uint256 tolerancePriceAboveMin;
        uint256 tolerancePriceAboveMax;
        uint256 minExpiration;
        uint256 maxExpiration;
    }
    
    struct PoolAcoPermissionConfigV2 {
        int256 tolerancePriceBelowMin;
        int256 tolerancePriceBelowMax;
        int256 tolerancePriceAboveMin;
        int256 tolerancePriceAboveMax;
        uint256 minStrikePrice;
        uint256 maxStrikePrice;
        uint256 minExpiration;
        uint256 maxExpiration;
    }
    
    struct PoolProtocolConfig {
        uint16 lendingPoolReferral;
        uint256 withdrawOpenPositionPenalty;
        uint256 underlyingPriceAdjustPercentage;
        uint256 fee;
        uint256 maximumOpenAco;
        address feeDestination;
        address assetConverter;
    }
    
	function init(InitData calldata initData) external;

	function numberOfAcoTokensNegotiated() external view returns(uint256);

    function numberOfOpenAcoTokens() external view returns(uint256);

    function collateral() external view returns(address);

	function canSwap(address acoToken) external view returns(bool);

	function quote(address acoToken, uint256 tokenAmount) external view returns(
		uint256 swapPrice, 
		uint256 protocolFee, 
		uint256 underlyingPrice, 
		uint256 volatility
	);

	function getDepositShares(uint256 collateralAmount) external view returns(uint256 shares);

	function getWithdrawNoLockedData(uint256 shares) external view returns(
		uint256 underlyingWithdrawn, 
		uint256 strikeAssetWithdrawn, 
		bool isPossible
	);

	function getWithdrawWithLocked(uint256 shares) external view returns(
		uint256 underlyingWithdrawn, 
		uint256 strikeAssetWithdrawn, 
		address[] memory acos, 
		uint256[] memory acosAmount
	);

	function getGeneralData() external view returns(
        uint256 underlyingBalance,
		uint256 strikeAssetBalance,
		uint256 collateralLocked,
        uint256 collateralOnOpenPosition,
        uint256 collateralLockedRedeemable,
        uint256 poolSupply
    );

	function setLendingPoolReferral(uint16 newLendingPoolReferral) external;

	function setPoolDataForAcoPermission(uint256 newTolerancePriceBelow, uint256 newTolerancePriceAbove, uint256 newMinExpiration, uint256 newMaxExpiration) external;

	function setAcoPermissionConfig(PoolAcoPermissionConfig calldata newConfig) external;

	function setAcoPermissionConfigV2(PoolAcoPermissionConfigV2 calldata newConfig) external;

	function setPoolAdmin(uint256 newAdmin) external;

	function setProtocolConfig(PoolProtocolConfig calldata newConfig) external;

	function setFeeData(address newFeeDestination, uint256 newFee) external;

	function setAssetConverter(address newAssetConverter) external;

    function setTolerancePriceBelow(uint256 newTolerancePriceBelow) external;

    function setTolerancePriceAbove(uint256 newTolerancePriceAbove) external;

    function setMinExpiration(uint256 newMinExpiration) external;

    function setMaxExpiration(uint256 newMaxExpiration) external;

    function setFee(uint256 newFee) external;

    function setFeeDestination(address newFeeDestination) external;

	function setWithdrawOpenPositionPenalty(uint256 newWithdrawOpenPositionPenalty) external;

	function setUnderlyingPriceAdjustPercentage(uint256 newUnderlyingPriceAdjustPercentage) external;

	function setMaximumOpenAco(uint256 newMaximumOpenAco) external;

	function setStrategy(address newStrategy) external;

	function setBaseVolatility(uint256 newBaseVolatility) external;

	function setValidAcoCreator(address acoCreator, bool newPermission) external;

	function setForbiddenAcoCreator(address acoCreator, bool newStatus) external;

    function withdrawStuckToken(address token, address destination) external;

    function deposit(uint256 collateralAmount, uint256 minShares, address to, bool isLendingToken) external payable returns(uint256 acoPoolTokenAmount);

	function depositWithGasToken(uint256 collateralAmount, uint256 minShares, address to, bool isLendingToken) external payable returns(uint256 acoPoolTokenAmount);

	function withdrawNoLocked(uint256 shares, uint256 minCollateral, address account, bool withdrawLendingToken) external returns (
		uint256 underlyingWithdrawn,
		uint256 strikeAssetWithdrawn
	);

	function withdrawNoLockedWithGasToken(uint256 shares, uint256 minCollateral, address account, bool withdrawLendingToken) external returns (
		uint256 underlyingWithdrawn,
		uint256 strikeAssetWithdrawn
	);

    function withdrawWithLocked(uint256 shares, address account, bool withdrawLendingToken) external returns (
		uint256 underlyingWithdrawn,
		uint256 strikeAssetWithdrawn,
		address[] memory acos,
		uint256[] memory acosAmount
	);

	function withdrawWithLockedWithGasToken(uint256 shares, address account, bool withdrawLendingToken) external returns (
		uint256 underlyingWithdrawn,
		uint256 strikeAssetWithdrawn,
		address[] memory acos,
		uint256[] memory acosAmount
	);

    function swap(address acoToken, uint256 tokenAmount, uint256 restriction, address to, uint256 deadline) external payable;

    function swapWithGasToken(address acoToken, uint256 tokenAmount, uint256 restriction, address to, uint256 deadline) external payable;

    function redeemACOTokens() external;

	function redeemACOToken(address acoToken) external;

    function restoreCollateral() external;

    function lendCollateral() external;

}pragma solidity ^0.6.6;

interface IACOAssetConverterHelper {

    function setPairTolerancePercentage(address baseAsset, address quoteAsset, uint256 tolerancePercentage) external;

    function setAggregator(address baseAsset, address quoteAsset, address aggregator) external;

    function setUniswapMiddleRoute(address baseAsset, address quoteAsset, address[] calldata uniswapMiddleRoute) external;

    function withdrawStuckAsset(address asset, address destination) external;

    function hasAggregator(address baseAsset, address quoteAsset) external view returns(bool);

    function getPairData(address baseAsset, address quoteAsset) external view returns(address, uint256, uint256, uint256);

    function getUniswapMiddleRouteByIndex(address baseAsset, address quoteAsset, uint256 index) external view returns(address);

    function getPrice(address baseAsset, address quoteAsset) external view returns(uint256);

    function getPriceWithTolerance(address baseAsset, address quoteAsset, bool isMinimumPrice) external view returns(uint256);

    function getExpectedAmountOutToSwapExactAmountIn(address assetToSold, address assetToBuy, uint256 amountToBuy) external view returns(uint256);

    function getExpectedAmountOutToSwapExactAmountInWithSpecificTolerance(address assetToSold, address assetToBuy, uint256 amountToBuy, uint256 tolerancePercentage) external view returns(uint256);

    function swapExactAmountOut(address assetToSold, address assetToBuy, uint256 amountToSold) external payable returns(uint256);

    function swapExactAmountOutWithSpecificTolerance(address assetToSold, address assetToBuy, uint256 amountToSold, uint256 tolerancePercentage) external payable returns(uint256);

    function swapExactAmountOutWithMinAmountToReceive(address assetToSold, address assetToBuy, uint256 amountToSold, uint256 minAmountToReceive) external payable returns(uint256);

    function swapExactAmountIn(address assetToSold, address assetToBuy, uint256 amountToBuy) external payable returns(uint256);

    function swapExactAmountInWithSpecificTolerance(address assetToSold, address assetToBuy, uint256 amountToBuy, uint256 tolerancePercentage) external payable returns(uint256);

    function swapExactAmountInWithMaxAmountToSold(address assetToSold, address assetToBuy, uint256 amountToBuy, uint256 maxAmountToSold) external payable returns(uint256);

}pragma solidity ^0.6.6;


contract ACOPoolFactory2 {

    
    struct ACOPoolBasicData {
        
        address underlying;
        
        address strikeAsset;
        
        bool isCall;
    }
    
    event SetFactoryAdmin(address indexed previousFactoryAdmin, address indexed newFactoryAdmin);
    
    event SetAcoPoolImplementation(address indexed previousAcoPoolImplementation, address indexed newAcoPoolImplementation);
    
    event SetAcoFactory(address indexed previousAcoFactory, address indexed newAcoFactory);
    
    event SetChiToken(address indexed previousChiToken, address indexed newChiToken);
    
    event SetAssetConverterHelper(address indexed previousAssetConverterHelper, address indexed newAssetConverterHelper);
    
    event SetAcoPoolFee(uint256 indexed previousAcoFee, uint256 indexed newAcoFee);
    
    event SetAcoPoolFeeDestination(address indexed previousAcoPoolFeeDestination, address indexed newAcoPoolFeeDestination);
     
    event SetAcoPoolWithdrawOpenPositionPenalty(uint256 indexed previousWithdrawOpenPositionPenalty, uint256 indexed newWithdrawOpenPositionPenalty);
	
    event SetAcoPoolUnderlyingPriceAdjustPercentage(uint256 indexed previousUnderlyingPriceAdjustPercentage, uint256 indexed newUnderlyingPriceAdjustPercentage);
	
    event SetAcoPoolMaximumOpenAco(uint256 indexed previousMaximumOpenAco, uint256 indexed newMaximumOpenAco);
	
    event SetAcoPoolPermission(address indexed poolAdmin, bool indexed previousPermission, bool indexed newPermission);
    
    event SetStrategyPermission(address indexed strategy, bool indexed previousPermission, bool newPermission);

    event NewAcoPool(address indexed underlying, address indexed strikeAsset, bool indexed isCall, address acoPool, address acoPoolImplementation);
    
    address public factoryAdmin;
    
    address public acoPoolImplementation;
    
    address public acoFactory;
    
    address public assetConverterHelper;
    
    address public chiToken;
    
    uint256 public acoPoolFee;
    
    address public acoPoolFeeDestination;
      
    uint256 public acoPoolWithdrawOpenPositionPenalty;
	  
    uint256 public acoPoolUnderlyingPriceAdjustPercentage;

    uint256 public acoPoolMaximumOpenAco;

    mapping(address => bool) public poolAdminPermission;
    
    mapping(address => bool) public strategyPermitted;
    
    mapping(address => ACOPoolBasicData) public acoPoolBasicData;
    
    modifier onlyFactoryAdmin() {

        require(msg.sender == factoryAdmin, "ACOPoolFactory::onlyFactoryAdmin");
        _;
    }
    
    modifier onlyPoolAdmin() {

        require(poolAdminPermission[msg.sender], "ACOPoolFactory::onlyPoolAdmin");
        _;
    }
    
    function init(
        address _factoryAdmin, 
        address _acoPoolImplementation, 
        address _acoFactory, 
        address _assetConverterHelper,
        address _chiToken,
        uint256 _acoPoolFee,
        address _acoPoolFeeDestination,
		uint256 _acoPoolWithdrawOpenPositionPenalty,
		uint256 _acoPoolUnderlyingPriceAdjustPercentage,
        uint256 _acoPoolMaximumOpenAco
    ) public {

        require(factoryAdmin == address(0) && acoPoolImplementation == address(0), "ACOPoolFactory::init: Contract already initialized.");
        
        _setFactoryAdmin(_factoryAdmin);
        _setAcoPoolImplementation(_acoPoolImplementation);
        _setAcoFactory(_acoFactory);
        _setAssetConverterHelper(_assetConverterHelper);
        _setChiToken(_chiToken);
        _setAcoPoolFee(_acoPoolFee);
        _setAcoPoolFeeDestination(_acoPoolFeeDestination);
		_setAcoPoolWithdrawOpenPositionPenalty(_acoPoolWithdrawOpenPositionPenalty);
		_setAcoPoolUnderlyingPriceAdjustPercentage(_acoPoolUnderlyingPriceAdjustPercentage);
        _setAcoPoolMaximumOpenAco(_acoPoolMaximumOpenAco);
        _setAcoPoolPermission(_factoryAdmin, true);
    }

    receive() external payable virtual {
        revert();
    }
    
    function setFactoryAdmin(address newFactoryAdmin) onlyFactoryAdmin external virtual {

        _setFactoryAdmin(newFactoryAdmin);
    }
    
    function setAcoPoolImplementation(address newAcoPoolImplementation) onlyFactoryAdmin external virtual {

        _setAcoPoolImplementation(newAcoPoolImplementation);
    }
    
    function setAcoFactory(address newAcoFactory) onlyFactoryAdmin external virtual {

        _setAcoFactory(newAcoFactory);
    }
    
    function setChiToken(address newChiToken) onlyFactoryAdmin external virtual {

        _setChiToken(newChiToken);
    }
    
    function setAssetConverterHelper(address newAssetConverterHelper) onlyFactoryAdmin external virtual {

        _setAssetConverterHelper(newAssetConverterHelper);
    }
    
    function setAcoPoolFee(uint256 newAcoPoolFee) onlyFactoryAdmin external virtual {

        _setAcoPoolFee(newAcoPoolFee);
    }
    
    function setAcoPoolFeeDestination(address newAcoPoolFeeDestination) onlyFactoryAdmin external virtual {

        _setAcoPoolFeeDestination(newAcoPoolFeeDestination);
    }
    
    function setAcoPoolWithdrawOpenPositionPenalty(uint256 newWithdrawOpenPositionPenalty) onlyFactoryAdmin external virtual {

        _setAcoPoolWithdrawOpenPositionPenalty(newWithdrawOpenPositionPenalty);
    }
	
    function setAcoPoolUnderlyingPriceAdjustPercentage(uint256 newUnderlyingPriceAdjustPercentage) onlyFactoryAdmin external virtual {

        _setAcoPoolUnderlyingPriceAdjustPercentage(newUnderlyingPriceAdjustPercentage);
    }

    function setAcoPoolMaximumOpenAco(uint256 newMaximumOpenAco) onlyFactoryAdmin external virtual {

        _setAcoPoolMaximumOpenAco(newMaximumOpenAco);
    }
	
    function setAcoPoolPermission(address poolAdmin, bool newPermission) onlyFactoryAdmin external virtual {

        _setAcoPoolPermission(poolAdmin, newPermission);
    }
    
    function setAcoPoolStrategyPermission(address strategy, bool newPermission) onlyFactoryAdmin external virtual {

        _setAcoPoolStrategyPermission(strategy, newPermission);
    }
	
    function setStrategyOnAcoPool(address strategy, address[] calldata acoPools) onlyPoolAdmin external virtual {

        _setStrategyOnAcoPool(strategy, acoPools);
    }
    
    function setBaseVolatilityOnAcoPool(uint256[] calldata baseVolatilities, address[] calldata acoPools) onlyPoolAdmin external virtual {

        _setAcoPoolUint256Data(IACOPool2.setBaseVolatility.selector, baseVolatilities, acoPools);
    }
	
    function setWithdrawOpenPositionPenaltyOnAcoPool(uint256[] calldata withdrawOpenPositionPenalties, address[] calldata acoPools) onlyPoolAdmin external virtual {

        _setAcoPoolUint256Data(IACOPool2.setWithdrawOpenPositionPenalty.selector, withdrawOpenPositionPenalties, acoPools);
    }
	
    function setUnderlyingPriceAdjustPercentageOnAcoPool(uint256[] calldata underlyingPriceAdjustPercentages, address[] calldata acoPools) onlyPoolAdmin external virtual {

        _setAcoPoolUint256Data(IACOPool2.setUnderlyingPriceAdjustPercentage.selector, underlyingPriceAdjustPercentages, acoPools);
    }

    function setMaximumOpenAcoOnAcoPool(uint256[] calldata maximumOpenAcos, address[] calldata acoPools) onlyPoolAdmin external virtual {

        _setAcoPoolUint256Data(IACOPool2.setMaximumOpenAco.selector, maximumOpenAcos, acoPools);
    }
	
    function setTolerancePriceBelowOnAcoPool(uint256[] calldata tolerancePricesBelow, address[] calldata acoPools) onlyPoolAdmin external virtual {

        _setAcoPoolUint256Data(IACOPool2.setTolerancePriceBelow.selector, tolerancePricesBelow, acoPools);
    }
	
    function setTolerancePriceAboveOnAcoPool(uint256[] calldata tolerancePricesAbove, address[] calldata acoPools) onlyPoolAdmin external virtual {

        _setAcoPoolUint256Data(IACOPool2.setTolerancePriceAbove.selector, tolerancePricesAbove, acoPools);
    }

    function setMinExpirationOnAcoPool(uint256[] calldata minExpirations, address[] calldata acoPools) onlyPoolAdmin external virtual {

        _setAcoPoolUint256Data(IACOPool2.setMinExpiration.selector, minExpirations, acoPools);
    }
	
    function setMaxExpirationOnAcoPool(uint256[] calldata maxExpirations, address[] calldata acoPools) onlyPoolAdmin external virtual {

        _setAcoPoolUint256Data(IACOPool2.setMaxExpiration.selector, maxExpirations, acoPools);
    }
	
    function setFeeOnAcoPool(uint256[] calldata fees, address[] calldata acoPools) onlyPoolAdmin external virtual {

        _setAcoPoolUint256Data(IACOPool2.setFee.selector, fees, acoPools);
    }
	
    function setFeeDestinationOnAcoPool(address[] calldata feeDestinations, address[] calldata acoPools) onlyPoolAdmin external virtual {

        _setAcoPoolAddressData(IACOPool2.setFeeDestination.selector, feeDestinations, acoPools);
    }
	
    function setAssetConverterOnAcoPool(address[] calldata assetConverters, address[] calldata acoPools) onlyPoolAdmin external virtual {

        _setAcoPoolAddressData(IACOPool2.setAssetConverter.selector, assetConverters, acoPools);
    }
	
	function setValidAcoCreatorOnAcoPool(address acoCreator, bool permission, address[] calldata acoPools) onlyPoolAdmin external virtual {

		_setValidAcoCreatorOnAcoPool(acoCreator, permission, acoPools);
	}
	
    function withdrawStuckAssetOnAcoPool(address asset, address destination, address[] calldata acoPools) onlyPoolAdmin external virtual {

		_withdrawStuckAssetOnAcoPool(asset, destination, acoPools);
	}
	
    function _setFactoryAdmin(address newFactoryAdmin) internal virtual {

        require(newFactoryAdmin != address(0), "ACOPoolFactory::_setFactoryAdmin: Invalid factory admin");
        emit SetFactoryAdmin(factoryAdmin, newFactoryAdmin);
        factoryAdmin = newFactoryAdmin;
    }
    
    function _setAcoPoolImplementation(address newAcoPoolImplementation) internal virtual {

        require(Address.isContract(newAcoPoolImplementation), "ACOPoolFactory::_setAcoPoolImplementation: Invalid ACO pool implementation");
        emit SetAcoPoolImplementation(acoPoolImplementation, newAcoPoolImplementation);
        acoPoolImplementation = newAcoPoolImplementation;
    }
    
    function _setAcoFactory(address newAcoFactory) internal virtual {

        require(Address.isContract(newAcoFactory), "ACOPoolFactory::_setAcoFactory: Invalid ACO factory");
        emit SetAcoFactory(acoFactory, newAcoFactory);
        acoFactory = newAcoFactory;
    }
    
    function _setAssetConverterHelper(address newAssetConverterHelper) internal virtual {

        require(Address.isContract(newAssetConverterHelper), "ACOPoolFactory::_setAssetConverterHelper: Invalid asset converter helper");
        emit SetAssetConverterHelper(assetConverterHelper, newAssetConverterHelper);
        assetConverterHelper = newAssetConverterHelper;
    }
    
    function _setChiToken(address newChiToken) internal virtual {

        require(Address.isContract(newChiToken), "ACOPoolFactory::_setChiToken: Invalid Chi Token");
        emit SetChiToken(chiToken, newChiToken);
        chiToken = newChiToken;
    }
    
    function _setAcoPoolFee(uint256 newAcoPoolFee) internal virtual {

        emit SetAcoPoolFee(acoPoolFee, newAcoPoolFee);
        acoPoolFee = newAcoPoolFee;
    }
    
    function _setAcoPoolFeeDestination(address newAcoPoolFeeDestination) internal virtual {

        require(newAcoPoolFeeDestination != address(0), "ACOFactory::_setAcoPoolFeeDestination: Invalid ACO Pool fee destination");
        emit SetAcoPoolFeeDestination(acoPoolFeeDestination, newAcoPoolFeeDestination);
        acoPoolFeeDestination = newAcoPoolFeeDestination;
    }
    
    function _setAcoPoolWithdrawOpenPositionPenalty(uint256 newWithdrawOpenPositionPenalty) internal virtual {

        emit SetAcoPoolWithdrawOpenPositionPenalty(acoPoolWithdrawOpenPositionPenalty, newWithdrawOpenPositionPenalty);
        acoPoolWithdrawOpenPositionPenalty = newWithdrawOpenPositionPenalty;
    }
    
    function _setAcoPoolUnderlyingPriceAdjustPercentage(uint256 newUnderlyingPriceAdjustPercentage) internal virtual {

        emit SetAcoPoolUnderlyingPriceAdjustPercentage(acoPoolUnderlyingPriceAdjustPercentage, newUnderlyingPriceAdjustPercentage);
        acoPoolUnderlyingPriceAdjustPercentage = newUnderlyingPriceAdjustPercentage;
    }

    function _setAcoPoolMaximumOpenAco(uint256 newMaximumOpenAco) internal virtual {

        emit SetAcoPoolMaximumOpenAco(acoPoolMaximumOpenAco, newMaximumOpenAco);
        acoPoolMaximumOpenAco = newMaximumOpenAco;
    }
    
    function _setAcoPoolPermission(address poolAdmin, bool newPermission) internal virtual {

        emit SetAcoPoolPermission(poolAdmin, poolAdminPermission[poolAdmin], newPermission);
        poolAdminPermission[poolAdmin] = newPermission;
    }
    
    function _setAcoPoolStrategyPermission(address strategy, bool newPermission) internal virtual {

        require(Address.isContract(strategy), "ACOPoolFactory::_setAcoPoolStrategy: Invalid strategy");
        emit SetStrategyPermission(strategy, strategyPermitted[strategy], newPermission);
        strategyPermitted[strategy] = newPermission;
    }
    
    function _validateStrategy(address strategy) view internal virtual {

        require(strategyPermitted[strategy], "ACOPoolFactory::_validateStrategy: Invalid strategy");
    }
    
    function _setStrategyOnAcoPool(address strategy, address[] memory acoPools) internal virtual {

        _validateStrategy(strategy);
        for (uint256 i = 0; i < acoPools.length; ++i) {
            IACOPool2(acoPools[i]).setStrategy(strategy);
        }
    }
	
    function _setValidAcoCreatorOnAcoPool(address acoCreator, bool permission, address[] memory acoPools) internal virtual {

        for (uint256 i = 0; i < acoPools.length; ++i) {
            IACOPool2(acoPools[i]).setValidAcoCreator(acoCreator, permission);
        }
    }
	
    function _withdrawStuckAssetOnAcoPool(address asset, address destination, address[] memory acoPools) internal virtual {

        for (uint256 i = 0; i < acoPools.length; ++i) {
            IACOPool2(acoPools[i]).withdrawStuckToken(asset, destination);
        }
    }
    
    function _setAcoPoolUint256Data(bytes4 selector, uint256[] memory numbers, address[] memory acoPools) internal virtual {

        require(numbers.length == acoPools.length, "ACOPoolFactory::_setAcoPoolUint256Data: Invalid arguments");
        for (uint256 i = 0; i < acoPools.length; ++i) {
			(bool success,) = acoPools[i].call(abi.encodeWithSelector(selector, numbers[i]));
			require(success, "ACOPoolFactory::_setAcoPoolUint256Data");
        }
    }
    
    function _setAcoPoolAddressData(bytes4 selector, address[] memory addresses, address[] memory acoPools) internal virtual {

        require(addresses.length == acoPools.length, "ACOPoolFactory::_setAcoPoolAddressData: Invalid arguments");
        for (uint256 i = 0; i < acoPools.length; ++i) {
			(bool success,) = acoPools[i].call(abi.encodeWithSelector(selector, addresses[i]));
			require(success, "ACOPoolFactory::_setAcoPoolAddressData");
        }
    }
    
    function _createAcoPool(IACOPool2.InitData memory initData) internal virtual returns(address) {

        address acoPool  = _deployAcoPool(initData);
        acoPoolBasicData[acoPool] = ACOPoolBasicData(initData.underlying, initData.strikeAsset, initData.isCall);
        emit NewAcoPool(
            initData.underlying, 
            initData.strikeAsset, 
            initData.isCall, 
            acoPool, 
            acoPoolImplementation
        );
        return acoPool;
    }
    
    function _deployAcoPool(IACOPool2.InitData memory initData) internal virtual returns(address) {

        bytes20 implentationBytes = bytes20(acoPoolImplementation);
        address proxy;
        assembly {
            let clone := mload(0x40)
            mstore(clone, 0x3d602d80600a3d3981f3363d3d373d3d3d363d73000000000000000000000000)
            mstore(add(clone, 0x14), implentationBytes)
            mstore(add(clone, 0x28), 0x5af43d82803e903d91602b57fd5bf30000000000000000000000000000000000)
            proxy := create(0, clone, 0x37)
        }
        IACOPool2(proxy).init(initData);
        return proxy;
    }
}

contract ACOPoolFactory2V2 is ACOPoolFactory2 {

 
    event SetAcoPoolLendingPool(address indexed oldLendingPool, address indexed newLendingPool);
    
    event SetAcoPoolLendingPoolReferral(uint256 indexed oldLendingPoolReferral, uint256 indexed newLendingPoolReferral);
    
	uint16 public lendingPoolReferral;
	
	address public lendingPool;
    
    function setAcoPoolLendingPool(address newLendingPool) onlyFactoryAdmin external virtual {

        _setAcoPoolLendingPool(newLendingPool);
    }   

    function setAcoPoolLendingPoolReferral(uint16 newLendingPoolReferral) onlyFactoryAdmin external virtual {

        _setAcoPoolLendingPoolReferral(newLendingPoolReferral);
    }
    
    function setFeeDataOnAcoPool(address[] calldata feeDestinations, uint256[] calldata fees, address[] calldata acoPools) onlyPoolAdmin external virtual {

        _setAcoPoolAddressUint256Data(IACOPool2.setFeeData.selector, feeDestinations, fees, acoPools);
    }
    
    function setAcoPermissionDataOnAcoPool(
        uint256[] calldata tolerancePricesBelow, 
        uint256[] calldata tolerancePricesAbove, 
        uint256[] calldata minExpirations,
        uint256[] calldata maxExpirations,
        address[] calldata acoPools
    ) onlyPoolAdmin external virtual {

        require(tolerancePricesBelow.length == tolerancePricesAbove.length 
            && tolerancePricesAbove.length == minExpirations.length
            && minExpirations.length == maxExpirations.length
            && maxExpirations.length == acoPools.length, "ACOPoolFactory::setAcoPermissionDataOnAcoPool: Invalid arguments");
        
        bytes4 selector = IACOPool2.setPoolDataForAcoPermission.selector;
        for (uint256 i = 0; i < acoPools.length; ++i) {
			(bool success,) = acoPools[i].call(abi.encodeWithSelector(selector, tolerancePricesBelow[i], tolerancePricesAbove[i], minExpirations[i], maxExpirations[i]));
			require(success, "ACOPoolFactory::setAcoPermissionDataOnAcoPool");
        }
    }
    
    function setLendingPoolReferralOnAcoPool(uint256[] calldata lendingPoolReferrals, address[] calldata acoPools) onlyPoolAdmin external virtual {

        _setAcoPoolUint256Data(IACOPool2.setLendingPoolReferral.selector, lendingPoolReferrals, acoPools);
    }
    
    function _setAcoPoolLendingPool(address newLendingPool) internal virtual {

        emit SetAcoPoolLendingPool(lendingPool, newLendingPool);
        lendingPool = newLendingPool;
    }
    
    function _setAcoPoolLendingPoolReferral(uint16 newLendingPoolReferral) internal virtual {

        emit SetAcoPoolLendingPoolReferral(lendingPoolReferral, newLendingPoolReferral);
        lendingPoolReferral = newLendingPoolReferral;
    }
    
    function _setAcoPoolAddressUint256Data(bytes4 selector, address[] memory addresses, uint256[] memory numbers, address[] memory acoPools) internal virtual {

        require(addresses.length == acoPools.length && numbers.length == acoPools.length, "ACOPoolFactory::_setAcoPoolAddressUint256Data: Invalid arguments");
        for (uint256 i = 0; i < acoPools.length; ++i) {
			(bool success,) = acoPools[i].call(abi.encodeWithSelector(selector, addresses[i], numbers[i]));
			require(success, "ACOPoolFactory::_setAcoPoolAddressUint256Data");
        }
    }
}

contract ACOPoolFactory2V3 is ACOPoolFactory2V2 {


    event SetOperator(address indexed operator, bool indexed previousPermission, bool indexed newPermission);
    
    event SetAuthorizedAcoCreator(address indexed acoCreator, bool indexed previousPermission, bool indexed newPermission);

    mapping(address => bool) public operators;
    
    mapping(address => address) public creators;
    
    address[] internal acoAuthorizedCreators;
    
    function getNumberOfAcoCreatorsAuthorized() view external virtual returns(uint256) {

        return acoAuthorizedCreators.length;
    }
    
    function getAcoCreatorAuthorized(uint256 index) view external virtual returns(address) {

        return acoAuthorizedCreators[index];
    }
    
    function setOperator(address operator, bool newPermission) onlyFactoryAdmin external virtual {

        _setOperator(operator, newPermission);
    }
    
    function setAuthorizedAcoCreator(address acoCreator, bool newPermission) onlyFactoryAdmin external virtual {

        _setAuthorizedAcoCreator(acoCreator, newPermission);
    }

    function setProtocolConfigOnAcoPool(
        uint16 lendingPoolReferral,
        uint256 withdrawOpenPositionPenalty,
        uint256 underlyingPriceAdjustPercentage,
        uint256 fee,
        uint256 maximumOpenAco,
        address feeDestination,
        address assetConverter, 
        address[] calldata acoPools
    ) onlyPoolAdmin external virtual {

        IACOPool2.PoolProtocolConfig memory config = IACOPool2.PoolProtocolConfig(lendingPoolReferral, withdrawOpenPositionPenalty, underlyingPriceAdjustPercentage, fee, maximumOpenAco, feeDestination, assetConverter);
        for (uint256 i = 0; i < acoPools.length; ++i) {
            IACOPool2(acoPools[i]).setProtocolConfig(config);
        }
    }
    
    function _setOperator(address operator, bool newPermission) internal virtual {

        emit SetOperator(operator, operators[operator], newPermission);
        operators[operator] = newPermission;
    }
    
    function _setAuthorizedAcoCreator(address acoCreator, bool newPermission) internal virtual {

        bool previousPermission = false;
        uint256 size = acoAuthorizedCreators.length;
        for (uint256 i = size; i > 0; --i) {
            if (acoAuthorizedCreators[i - 1] == acoCreator) {
                previousPermission = true;
                if (!newPermission) {
                    if (i < size) {
                        acoAuthorizedCreators[i - 1] = acoAuthorizedCreators[(size - 1)];
                    }
                    acoAuthorizedCreators.pop();
                }
                break;
            }
        }
        if (newPermission && !previousPermission) {
            acoAuthorizedCreators.push(acoCreator);
        }
        emit SetAuthorizedAcoCreator(acoCreator, previousPermission, newPermission);
    }
}

contract ACOPoolFactory2V4 is ACOPoolFactory2V3 {


    event SetPoolProxyAdmin(address indexed previousPoolProxyAdmin, address indexed newPoolProxyAdmin);

    event SetForbiddenAcoCreator(address indexed acoCreator, bool indexed previousStatus, bool indexed newStatus);

    address public poolProxyAdmin;

    address[] internal acoForbiddenCreators;
    
    function setPoolProxyAdmin(address newPoolProxyAdmin) onlyFactoryAdmin external virtual {

        _setPoolProxyAdmin(newPoolProxyAdmin);
    }

    function updatePoolsImplementation(
        address payable[] calldata pools,
        bytes calldata initData
    ) external virtual {

        require(poolProxyAdmin == msg.sender, "ACOPoolFactory::onlyPoolProxyAdmin");
        for (uint256 i = 0; i < pools.length; ++i) {
            ACOProxy(pools[i]).setImplementation(acoPoolImplementation, initData);
        }
    }

    function transferPoolProxyAdmin(address newPoolProxyAdmin, address payable[] calldata pools) external virtual {

        require(poolProxyAdmin == msg.sender, "ACOPoolFactory::onlyPoolProxyAdmin");
        for (uint256 i = 0; i < pools.length; ++i) {
            ACOProxy(pools[i]).transferProxyAdmin(newPoolProxyAdmin);
        }
    }

    function getNumberOfAcoCreatorsForbidden() view external virtual returns(uint256) {

        return acoForbiddenCreators.length;
    }
    
    function getAcoCreatorForbidden(uint256 index) view external virtual returns(address) {

        return acoForbiddenCreators[index];
    }

    function setForbiddenAcoCreator(address acoCreator, bool newStatus) onlyFactoryAdmin external virtual {

        _setForbiddenAcoCreator(acoCreator, newStatus);
    }

	function setForbiddenAcoCreatorOnAcoPool(address acoCreator, bool status, address[] calldata acoPools) onlyPoolAdmin external virtual {

		_setForbiddenAcoCreatorOnAcoPool(acoCreator, status, acoPools);
	}

    function _deployAcoPool(IACOPool2.InitData memory initData) internal override virtual returns(address) {

        ACOProxy proxy = new ACOProxy(address(this), acoPoolImplementation, abi.encodeWithSelector(IACOPool2.init.selector, initData));
        return address(proxy);
    }
    
    function _createAcoPool(IACOPool2.InitData memory initData) internal override virtual returns(address) {

        address acoPool  = _deployAcoPool(initData);
        acoPoolBasicData[acoPool] = ACOPoolBasicData(initData.underlying, initData.strikeAsset, initData.isCall);
        creators[acoPool] = msg.sender;
        for (uint256 i = 0; i < acoAuthorizedCreators.length; ++i) {
            IACOPool2(acoPool).setValidAcoCreator(acoAuthorizedCreators[i], true);
        }
        for (uint256 j = 0; j < acoForbiddenCreators.length; ++j) {
            IACOPool2(acoPool).setForbiddenAcoCreator(acoForbiddenCreators[j], true);
        }
        emit NewAcoPool(initData.underlying, initData.strikeAsset, initData.isCall, acoPool, acoPoolImplementation);
        return acoPool;
    }	
    
    function _setPoolProxyAdmin(address newPoolProxyAdmin) internal virtual {

        require(newPoolProxyAdmin != address(0), "ACOPoolFactory::_setPoolProxyAdmin: Invalid pool proxy admin");
        emit SetPoolProxyAdmin(poolProxyAdmin, newPoolProxyAdmin);
        poolProxyAdmin = newPoolProxyAdmin;
    }

    function _setForbiddenAcoCreator(address acoCreator, bool newStatus) internal virtual {

        bool previousStatus = false;
        uint256 size = acoForbiddenCreators.length;
        for (uint256 i = size; i > 0; --i) {
            if (acoForbiddenCreators[i - 1] == acoCreator) {
                previousStatus = true;
                if (!newStatus) {
                    if (i < size) {
                        acoForbiddenCreators[i - 1] = acoForbiddenCreators[(size - 1)];
                    }
                    acoForbiddenCreators.pop();
                }
                break;
            }
        }
        if (newStatus && !previousStatus) {
            acoForbiddenCreators.push(acoCreator);
        }
        emit SetForbiddenAcoCreator(acoCreator, previousStatus, newStatus);
    }

    function _setForbiddenAcoCreatorOnAcoPool(address acoCreator, bool status, address[] memory acoPools) internal virtual {

        for (uint256 i = 0; i < acoPools.length; ++i) {
            IACOPool2(acoPools[i]).setForbiddenAcoCreator(acoCreator, status);
        }
    }
}

contract ACOPoolFactory2V5 is ACOPoolFactory2V4 {

    
    event SetDefaultStrategy(address indexed previousDefaultStrategy, address indexed newDefaultStrategy);
    
    event SetStrikeAssetPermission(address indexed strikeAsset, bool indexed previousPermission, bool indexed newPermission);
    
    address public defaultStrategy;
    
    uint256 public poolCount;
    
    mapping(address => bool) public strikeAssets;
    
    function createAcoPool(
        address underlying, 
        address strikeAsset, 
        bool isCall,
        uint256 baseVolatility,
        address poolAdmin,
        address strategy,
        bool isPrivate,
        IACOPool2.PoolAcoPermissionConfigV2 calldata acoPermissionConfig
    ) external virtual returns(address) {

        require((operators[address(0)] || operators[msg.sender]), "ACOPoolFactory2::createAcoPool: Only authorized operators");
        return _createAcoPool(IACOPool2.InitData(
            acoFactory,
            lendingPool,
            underlying, 
            strikeAsset,
            isCall,
            baseVolatility,
            poolAdmin,
            strategy,
            isPrivate,
            ++poolCount,
            acoPermissionConfig,
            IACOPool2.PoolProtocolConfig(
                lendingPoolReferral,
                acoPoolWithdrawOpenPositionPenalty,
                acoPoolUnderlyingPriceAdjustPercentage,
                acoPoolFee,
                acoPoolMaximumOpenAco,
                acoPoolFeeDestination,
                assetConverterHelper
            )
        ));
    }
    
    function newAcoPool(
        address underlying, 
        address strikeAsset, 
        bool isCall,
        uint256 baseVolatility,
        address poolAdmin,
        IACOPool2.PoolAcoPermissionConfigV2 calldata acoPermissionConfig
    ) external virtual returns(address) {

        require(strikeAssets[strikeAsset], "ACOPoolFactory2::newAcoPool: Invalid strike asset");
        require(IACOAssetConverterHelper(assetConverterHelper).hasAggregator(underlying, strikeAsset), "ACOPoolFactory2::newAcoPool: Invalid pair");
        
        return _createAcoPool(IACOPool2.InitData(
            acoFactory,
            lendingPool,
            underlying, 
            strikeAsset,
            isCall,
            baseVolatility,
            poolAdmin,
            defaultStrategy,
            true,
            ++poolCount,
            acoPermissionConfig,
            IACOPool2.PoolProtocolConfig(
                lendingPoolReferral,
                acoPoolWithdrawOpenPositionPenalty,
                acoPoolUnderlyingPriceAdjustPercentage,
                acoPoolFee,
                acoPoolMaximumOpenAco,
                acoPoolFeeDestination,
                assetConverterHelper
            )
        ));
    }
    
    function setPoolDefaultStrategy(address newDefaultStrategy) onlyFactoryAdmin external virtual {

        _setPoolDefaultStrategy(newDefaultStrategy);
    }
    
    function setStrikeAssetPermission(address strikeAsset, bool newPermission) onlyFactoryAdmin external virtual {

        _setStrikeAssetPermission(strikeAsset, newPermission);
    }
    
    function _setPoolDefaultStrategy(address newDefaultStrategy) internal virtual {

        _validateStrategy(newDefaultStrategy);
        emit SetDefaultStrategy(defaultStrategy, newDefaultStrategy);
        defaultStrategy = newDefaultStrategy;
    }
    
    function _setStrikeAssetPermission(address strikeAsset, bool newPermission) internal virtual {

        emit SetStrikeAssetPermission(strikeAsset, strikeAssets[strikeAsset], newPermission);
        strikeAssets[strikeAsset] = newPermission;
    }
}