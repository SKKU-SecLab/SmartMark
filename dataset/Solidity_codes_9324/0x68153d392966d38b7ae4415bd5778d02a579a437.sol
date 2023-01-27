
pragma solidity ^0.6.0;

abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

contract Ownable is Context {

    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    function init() internal {

        require(_owner == address(0), "Ownable: Contract initialized");
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    function owner() public view returns (address) {

        return _owner;
    }

    modifier onlyOwner() {

        require(_owner == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {

        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}pragma solidity ^0.6.6;


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

library ACOAssetHelper {

    uint256 internal constant MAX_UINT = 0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff;

    function _isEther(address _address) internal pure returns(bool) {

        return _address == address(0);
    }
    
    function _callApproveERC20(address token, address spender, uint256 amount) internal {

        (bool success, bytes memory returndata) = token.call(abi.encodeWithSelector(0x095ea7b3, spender, amount));
        require(success && (returndata.length == 0 || abi.decode(returndata, (bool))), "ACOAssetHelper::_callApproveERC20");
    }
    
    function _callTransferERC20(address token, address recipient, uint256 amount) internal {

        (bool success, bytes memory returndata) = token.call(abi.encodeWithSelector(0xa9059cbb, recipient, amount));
        require(success && (returndata.length == 0 || abi.decode(returndata, (bool))), "ACOAssetHelper::_callTransferERC20");
    }
    
     function _callTransferFromERC20(address token, address sender, address recipient, uint256 amount) internal {

        (bool success, bytes memory returndata) = token.call(abi.encodeWithSelector(0x23b872dd, sender, recipient, amount));
        require(success && (returndata.length == 0 || abi.decode(returndata, (bool))), "ACOAssetHelper::_callTransferFromERC20");
    }
    
    function _getAssetSymbol(address asset) internal view returns(string memory) {

        if (_isEther(asset)) {
            return "ETH";
        } else {
            (bool success, bytes memory returndata) = asset.staticcall(abi.encodeWithSelector(0x95d89b41));
            require(success, "ACOAssetHelper::_getAssetSymbol");
            return abi.decode(returndata, (string));
        }
    }
    
    function _getAssetDecimals(address asset) internal view returns(uint8) {

        if (_isEther(asset)) {
            return uint8(18);
        } else {
            (bool success, bytes memory returndata) = asset.staticcall(abi.encodeWithSelector(0x313ce567));
            require(success, "ACOAssetHelper::_getAssetDecimals");
            return abi.decode(returndata, (uint8));
        }
    }

    function _getAssetName(address asset) internal view returns(string memory) {

        if (_isEther(asset)) {
            return "Ethereum";
        } else {
            (bool success, bytes memory returndata) = asset.staticcall(abi.encodeWithSelector(0x06fdde03));
            require(success, "ACOAssetHelper::_getAssetName");
            return abi.decode(returndata, (string));
        }
    }
    
    function _getAssetBalanceOf(address asset, address account) internal view returns(uint256) {

        if (_isEther(asset)) {
            return account.balance;
        } else {
            (bool success, bytes memory returndata) = asset.staticcall(abi.encodeWithSelector(0x70a08231, account));
            require(success, "ACOAssetHelper::_getAssetBalanceOf");
            return abi.decode(returndata, (uint256));
        }
    }
    
    function _getAssetAllowance(address asset, address owner, address spender) internal view returns(uint256) {

        if (_isEther(asset)) {
            return 0;
        } else {
            (bool success, bytes memory returndata) = asset.staticcall(abi.encodeWithSelector(0xdd62ed3e, owner, spender));
            require(success, "ACOAssetHelper::_getAssetAllowance");
            return abi.decode(returndata, (uint256));
        }
    }

    function _transferAsset(address asset, address to, uint256 amount) internal {

        if (_isEther(asset)) {
            (bool success,) = to.call{value:amount}(new bytes(0));
            require(success, 'ACOAssetHelper::_transferAsset');
        } else {
            _callTransferERC20(asset, to, amount);
        }
    }
    
    function _receiveAsset(address asset, uint256 amount) internal {

        if (_isEther(asset)) {
            require(msg.value == amount, "ACOAssetHelper:: Invalid ETH amount");
        } else {
            require(msg.value == 0, "ACOAssetHelper:: Ether is not expected");
            _callTransferFromERC20(asset, msg.sender, address(this), amount);
        }
    }

    function _setAssetInfinityApprove(address asset, address owner, address spender, uint256 amount) internal {

        if (_getAssetAllowance(asset, owner, spender) < amount) {
            _callApproveERC20(asset, spender, MAX_UINT);
        }
    }
}pragma solidity ^0.6.6;


library SafeMath {

    function add(uint256 a, uint256 b) internal pure returns (uint256) {

        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {

        return sub(a, b, "SafeMath: subtraction overflow");
    }

    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        require(b <= a, errorMessage);
        uint256 c = a - b;

        return c;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {

        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {

        return div(a, b, "SafeMath: division by zero");
    }

    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        require(b > 0, errorMessage);
        uint256 c = a / b;

        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {

        return mod(a, b, "SafeMath: modulo by zero");
    }

    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        require(b != 0, errorMessage);
        return a % b;
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


abstract contract ERC20 is IERC20 {
    using SafeMath for uint256;
    
    uint256 private _totalSupply;
    mapping (address => uint256) private _balances;
    mapping (address => mapping (address => uint256)) private _allowances;

    function name() public view virtual returns(string memory);
    function symbol() public view virtual returns(string memory);
    function decimals() public view virtual returns(uint8);

    function totalSupply() public view override returns(uint256) {
        return _totalSupply;
    }

    function balanceOf(address account) public view override returns(uint256) {
        return _balances[account];
    }

    function allowance(address owner, address spender) public view override returns(uint256) {
        return _allowances[owner][spender];
    }

    function transfer(address recipient, uint256 amount) public override returns(bool) {
        _transfer(msg.sender, recipient, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) public override returns(bool) {
        _approveAction(sender, msg.sender, _allowances[sender][msg.sender].sub(amount));
        _transfer(sender, recipient, amount);
        return true;
    }

    function approve(address spender, uint256 amount) public override returns(bool) {
        _approve(msg.sender, spender, amount);
        return true;
    }

    function increaseAllowance(address spender, uint256 amount) public returns(bool) {
        _approve(msg.sender, spender, _allowances[msg.sender][spender].add(amount));
        return true;
    }

    function decreaseAllowance(address spender, uint256 amount) public returns(bool) {
        _approve(msg.sender, spender, _allowances[msg.sender][spender].sub(amount));
        return true;
    }
    
    function _transfer(address sender, address recipient, uint256 amount) internal virtual {
        _transferAction(sender, recipient, amount);
    }

    function _approve(address owner, address spender, uint256 amount) internal virtual {
        _approveAction(owner, spender, amount);
    }
    
    function _burnFrom(address account, uint256 amount) internal {
        _approveAction(account, msg.sender, _allowances[account][msg.sender].sub(amount));
        _burnAction(account, amount);
    }

    function _transferAction(address sender, address recipient, uint256 amount) internal {
        require(sender != address(0), "ERC20::_transferAction: Invalid sender");
        require(recipient != address(0), "ERC20::_transferAction: Invalid recipient");

        _balances[sender] = _balances[sender].sub(amount);
        _balances[recipient] = _balances[recipient].add(amount);
        
        emit Transfer(sender, recipient, amount);
    }
    
    function _approveAction(address owner, address spender, uint256 amount) internal {
        require(owner != address(0), "ERC20::_approveAction: Invalid owner");
        require(spender != address(0), "ERC20::_approveAction: Invalid spender");

        _allowances[owner][spender] = amount;
        
        emit Approval(owner, spender, amount);
    }
    
    function _mintAction(address account, uint256 amount) internal {
        require(account != address(0), "ERC20::_mintAction: Invalid account");

        _totalSupply = _totalSupply.add(amount);
        _balances[account] = _balances[account].add(amount);
        
        emit Transfer(address(0), account, amount);
    }

    function _burnAction(address account, uint256 amount) internal {
        require(account != address(0), "ERC20::_burnAction: Invalid account");

        _balances[account] = _balances[account].sub(amount);
        _totalSupply = _totalSupply.sub(amount);
        
        emit Transfer(account, address(0), amount);
    }
}    
pragma solidity ^0.6.6;

interface IACOFactory {

	function init(address _factoryAdmin, address _acoTokenImplementation, uint256 _acoFee, address _acoFeeDestination) external;

    function acoFee() external view returns(uint256);

    function factoryAdmin() external view returns(address);

    function acoTokenImplementation() external view returns(address);

    function acoFeeDestination() external view returns(address);

    function acoTokenData(address acoToken) external view returns(address, address, bool, uint256, uint256);

    function creators(address acoToken) external view returns(address);

    function createAcoToken(address underlying, address strikeAsset, bool isCall, uint256 strikePrice, uint256 expiryTime, uint256 maxExercisedAccounts) external returns(address);

    function setFactoryAdmin(address newFactoryAdmin) external;

    function setAcoTokenImplementation(address newAcoTokenImplementation) external;

    function setAcoFee(uint256 newAcoFee) external;

    function setAcoFeeDestination(address newAcoFeeDestination) external;

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


interface IACOToken is IERC20 {

	function init(address _underlying, address _strikeAsset, bool _isCall, uint256 _strikePrice, uint256 _expiryTime, uint256 _acoFee, address payable _feeDestination, uint256 _maxExercisedAccounts) external;

    function name() external view returns(string memory);

    function symbol() external view returns(string memory);

    function decimals() external view returns(uint8);

    function underlying() external view returns (address);

    function strikeAsset() external view returns (address);

    function feeDestination() external view returns (address);

    function isCall() external view returns (bool);

    function strikePrice() external view returns (uint256);

    function expiryTime() external view returns (uint256);

    function totalCollateral() external view returns (uint256);

    function acoFee() external view returns (uint256);

	function maxExercisedAccounts() external view returns (uint256);

    function underlyingSymbol() external view returns (string memory);

    function strikeAssetSymbol() external view returns (string memory);

    function underlyingDecimals() external view returns (uint8);

    function strikeAssetDecimals() external view returns (uint8);

    function currentCollateral(address account) external view returns(uint256);

    function unassignableCollateral(address account) external view returns(uint256);

    function assignableCollateral(address account) external view returns(uint256);

    function currentCollateralizedTokens(address account) external view returns(uint256);

    function unassignableTokens(address account) external view returns(uint256);

    function assignableTokens(address account) external view returns(uint256);

    function getCollateralAmount(uint256 tokenAmount) external view returns(uint256);

    function getTokenAmount(uint256 collateralAmount) external view returns(uint256);

    function getBaseExerciseData(uint256 tokenAmount) external view returns(address, uint256);

    function numberOfAccountsWithCollateral() external view returns(uint256);

    function getCollateralOnExercise(uint256 tokenAmount) external view returns(uint256, uint256);

    function collateral() external view returns(address);

    function mintPayable() external payable returns(uint256);

    function mintToPayable(address account) external payable returns(uint256);

    function mint(uint256 collateralAmount) external returns(uint256);

    function mintTo(address account, uint256 collateralAmount) external returns(uint256);

    function burn(uint256 tokenAmount) external returns(uint256);

    function burnFrom(address account, uint256 tokenAmount) external returns(uint256);

    function redeem() external returns(uint256);

    function redeemFrom(address account) external returns(uint256);

    function exercise(uint256 tokenAmount, uint256 salt) external payable returns(uint256);

    function exerciseFrom(address account, uint256 tokenAmount, uint256 salt) external payable returns(uint256);

    function exerciseAccounts(uint256 tokenAmount, address[] calldata accounts) external payable returns(uint256);

    function exerciseAccountsFrom(address account, uint256 tokenAmount, address[] calldata accounts) external payable returns(uint256);

    function transferCollateralOwnership(address recipient, uint256 tokenCollateralizedAmount) external;

}pragma solidity ^0.6.6;


interface IChiToken is IERC20 {

    function mint(uint256 value) external;

    function computeAddress2(uint256 salt) external view returns(address);

    function free(uint256 value) external returns(uint256);

    function freeUpTo(uint256 value) external returns(uint256);

    function freeFrom(address from, uint256 value) external returns(uint256);

    function freeFromUpTo(address from, uint256 value) external returns(uint256);

}pragma solidity ^0.6.6;
pragma experimental ABIEncoderV2;

interface IACOPoolStrategy {

    
    struct OptionQuote {
        uint256 underlyingPrice;
        address underlying;
        address strikeAsset;
        bool isCallOption;
        uint256 strikePrice; 
        uint256 expiryTime;
        uint256 baseVolatility;
        uint256 collateralOrderAmount;
        uint256 collateralAvailable;
    }

    function quote(OptionQuote calldata quoteData) external view returns(uint256 optionPrice, uint256 volatility);

}pragma solidity ^0.6.6;


interface IACOPool2 is IERC20 {


    struct InitData {
        address acoFactory;
        address chiToken;
        address underlying;
        address strikeAsset;
        bool isCall; 
		address assetConverter;
        uint256 fee;
        address feeDestination;
        uint256 withdrawOpenPositionPenalty;
        uint256 underlyingPriceAdjustPercentage;
		uint256 maximumOpenAco;
        uint256 tolerancePriceBelow;
        uint256 tolerancePriceAbove; 
        uint256 minExpiration;
        uint256 maxExpiration;
        address strategy;
        uint256 baseVolatility;    
    }

	struct AcoData {
        bool open;
        uint256 valueSold;
        uint256 collateralLocked;
        uint256 collateralRedeemed;
        uint256 index;
		uint256 openIndex;
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

	function setValidAcoCreator(address newAcoCreator, bool newPermission) external;

    function withdrawStuckToken(address token, address destination) external;

    function deposit(uint256 collateralAmount, uint256 minShares, address to) external payable returns(uint256 acoPoolTokenAmount);

	function depositWithGasToken(uint256 collateralAmount, uint256 minShares, address to) external payable returns(uint256 acoPoolTokenAmount);

	function withdrawNoLocked(uint256 shares, uint256 minCollateral, address account) external returns (
		uint256 underlyingWithdrawn,
		uint256 strikeAssetWithdrawn
	);

	function withdrawNoLockedWithGasToken(uint256 shares, uint256 minCollateral, address account) external returns (
		uint256 underlyingWithdrawn,
		uint256 strikeAssetWithdrawn
	);

    function withdrawWithLocked(uint256 shares, address account) external returns (
		uint256 underlyingWithdrawn,
		uint256 strikeAssetWithdrawn,
		address[] memory acos,
		uint256[] memory acosAmount
	);

	function withdrawWithLockedWithGasToken(uint256 shares, address account) external returns (
		uint256 underlyingWithdrawn,
		uint256 strikeAssetWithdrawn,
		address[] memory acos,
		uint256[] memory acosAmount
	);

    function swap(address acoToken, uint256 tokenAmount, uint256 restriction, address to, uint256 deadline) external;

    function swapWithGasToken(address acoToken, uint256 tokenAmount, uint256 restriction, address to, uint256 deadline) external;

    function redeemACOTokens() external;

	function redeemACOToken(address acoToken) external;

    function restoreCollateral() external;

}pragma solidity ^0.6.6;


contract ACOPool2 is Ownable, ERC20, IACOPool2 {

    using Address for address;
    
    uint256 internal constant PERCENTAGE_PRECISION = 100000;
    uint256 internal constant MAX_UINT = 0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff;

    event SetAssetConverter(address indexed oldAssetConverter, address indexed newAssetConverter);
	
    event SetTolerancePriceAbove(uint256 indexed oldTolerancePriceAbove, uint256 indexed newTolerancePriceAbove);
	
    event SetTolerancePriceBelow(uint256 indexed oldTolerancePriceBelow, uint256 indexed newTolerancePriceBelow);
	
    event SetMinExpiration(uint256 indexed oldMinExpiration, uint256 indexed newMinExpiration);
	
    event SetMaxExpiration(uint256 indexed oldMaxExpiration, uint256 indexed newMaxExpiration);
	
	event SetWithdrawOpenPositionPenalty(uint256 indexed oldWithdrawOpenPositionPenalty, uint256 indexed newWithdrawOpenPositionPenalty);
	
	event SetUnderlyingPriceAdjustPercentage(uint256 indexed oldUnderlyingPriceAdjustPercentage, uint256 indexed newUnderlyingPriceAdjustPercentage);
	
	event SetMaximumOpenAco(uint256 indexed oldMaximumOpenAco, uint256 indexed newMaximumOpenAco);
	
    event SetFee(uint256 indexed oldFee, uint256 indexed newFee);
	
    event SetFeeDestination(address indexed oldFeeDestination, address indexed newFeeDestination);
	
    event SetValidAcoCreator(address indexed creator, bool indexed previousPermission, bool indexed newPermission);
	
	event SetStrategy(address indexed oldStrategy, address indexed newStrategy);
	
    event SetBaseVolatility(uint256 indexed oldBaseVolatility, uint256 indexed newBaseVolatility);
	
    event RestoreCollateral(uint256 amountOut, uint256 collateralRestored);
	
	event ACORedeem(address indexed acoToken, uint256 valueSold, uint256 collateralLocked, uint256 collateralRedeemed);
	
    event Deposit(address indexed account, uint256 shares, uint256 collateralAmount);
	
    event Withdraw(
		address indexed account, 
		uint256 shares, 
		bool noLocked, 
		uint256 underlyingWithdrawn, 
		uint256 strikeAssetWithdrawn, 
		address[] acos, 
		uint256[] acosAmount
	);
	
	event Swap(
        address indexed account, 
        address indexed acoToken, 
        uint256 tokenAmount, 
        uint256 price, 
        uint256 protocolFee,
        uint256 underlyingPrice,
		uint256 volatility
    );

    IACOFactory public acoFactory;
	
	IChiToken public chiToken;
	
    address public underlying;
	
    address public strikeAsset;
	
    bool public isCall;
    
    IACOAssetConverterHelper public assetConverter;
	
	IACOPoolStrategy public strategy;
	
	address public feeDestination;
	
    uint256 public baseVolatility;
	
    uint256 public tolerancePriceAbove;
	
    uint256 public tolerancePriceBelow;
	
    uint256 public minExpiration;
	
    uint256 public maxExpiration;
	
    uint256 public fee;
	
	uint256 public withdrawOpenPositionPenalty;
	
	uint256 public underlyingPriceAdjustPercentage;

	uint256 public maximumOpenAco;
	
    address[] public acoTokens;
	
    address[] public openAcos;
	
    mapping(address => bool) public validAcoCreators;
	
    mapping(address => AcoData) public acoData;
	
	uint256 internal underlyingPrecision;
    
	modifier discountCHI {

        uint256 gasStart = gasleft();
        _;
        uint256 gasSpent = 21000 + gasStart - gasleft() + 16 * msg.data.length;
        chiToken.freeFromUpTo(msg.sender, (gasSpent + 14154) / 41947);
    }
	
    function init(InitData calldata initData) external override {

		require(underlying == address(0) && strikeAsset == address(0), "E00");
        
        require(initData.acoFactory.isContract(), "E01");
        require(initData.chiToken.isContract(), "E02");
        require(initData.underlying != initData.strikeAsset, "E03");
        require(ACOAssetHelper._isEther(initData.underlying) || initData.underlying.isContract(), "E04");
        require(ACOAssetHelper._isEther(initData.strikeAsset) || initData.strikeAsset.isContract(), "E05");
        
        super.init();

        acoFactory = IACOFactory(initData.acoFactory);
        chiToken = IChiToken(initData.chiToken);
        underlying = initData.underlying;
        strikeAsset = initData.strikeAsset;
        isCall = initData.isCall;
		
        _setAssetConverter(initData.assetConverter);
        _setFee(initData.fee);
        _setFeeDestination(initData.feeDestination);
		_setWithdrawOpenPositionPenalty(initData.withdrawOpenPositionPenalty);
		_setUnderlyingPriceAdjustPercentage(initData.underlyingPriceAdjustPercentage);
        _setMaximumOpenAco(initData.maximumOpenAco);
        _setMaxExpiration(initData.maxExpiration);
        _setMinExpiration(initData.minExpiration);
        _setTolerancePriceAbove(initData.tolerancePriceAbove);
        _setTolerancePriceBelow(initData.tolerancePriceBelow);
        _setStrategy(initData.strategy);
        _setBaseVolatility(initData.baseVolatility);
		
		underlyingPrecision = 10 ** uint256(ACOAssetHelper._getAssetDecimals(initData.underlying));
    }

    receive() external payable {
    }

    function name() public override view returns(string memory) {

        return _name();
    }
	
	function symbol() public override view returns(string memory) {

        return _name();
    }

    function decimals() public override view returns(uint8) {

        return ACOAssetHelper._getAssetDecimals(collateral());
    }

    function numberOfAcoTokensNegotiated() external view override returns(uint256) {

        return acoTokens.length;
    }

    function numberOfOpenAcoTokens() external view override returns(uint256) {

        return openAcos.length;
    }
	
	function collateral() public view override returns(address) {

        if (isCall) {
            return underlying;
        } else {
            return strikeAsset;
        }
    }

    function canSwap(address acoToken) external view override returns(bool) {

        (address _underlying, address _strikeAsset, bool _isCall, uint256 _strikePrice, uint256 _expiryTime) = acoFactory.acoTokenData(acoToken);
		if (_acoBasicDataIsValid(acoToken, _underlying, _strikeAsset, _isCall) && _acoExpirationIsValid(_expiryTime)) {
            uint256 price = assetConverter.getPrice(_underlying, _strikeAsset);
            return _acoStrikePriceIsValid(_strikePrice, price);
        }
        return false;
    }
	
	function quote(address acoToken, uint256 tokenAmount) external view override returns(
        uint256 swapPrice, 
        uint256 protocolFee, 
        uint256 underlyingPrice, 
        uint256 volatility
    ) {

        (swapPrice, protocolFee, underlyingPrice, volatility,) = _quote(acoToken, tokenAmount);
    }
	
	function getDepositShares(uint256 collateralAmount) external view override returns(uint256) {

        return _getDepositShares(collateralAmount);
    }

	function getWithdrawNoLockedData(uint256 shares) external view override returns(
        uint256 underlyingWithdrawn,
		uint256 strikeAssetWithdrawn,
		bool isPossible
    ) {

        (underlyingWithdrawn, strikeAssetWithdrawn, isPossible) = _getWithdrawNoLockedData(shares);
    }
	
	function getWithdrawWithLocked(uint256 shares) external view override returns(
        uint256 underlyingWithdrawn,
		uint256 strikeAssetWithdrawn,
		address[] memory acos,
		uint256[] memory acosAmount
    ) {

        (underlyingWithdrawn, strikeAssetWithdrawn, acos, acosAmount) = _getWithdrawWithLocked(shares);
    }

    function setAssetConverter(address newAssetConverter) external override {

        onlyFactory();
        _setAssetConverter(newAssetConverter);
    }

    function setTolerancePriceBelow(uint256 newTolerancePriceBelow) external override {

        onlyFactory();
        _setTolerancePriceBelow(newTolerancePriceBelow);
    }

    function setTolerancePriceAbove(uint256 newTolerancePriceAbove) external override {

        onlyFactory();
        _setTolerancePriceAbove(newTolerancePriceAbove);
    }

    function setMinExpiration(uint256 newMinExpiration) external override {

        onlyFactory();
        _setMinExpiration(newMinExpiration);
    }

    function setMaxExpiration(uint256 newMaxExpiration) external override {

        onlyFactory();
        _setMaxExpiration(newMaxExpiration);
    }
    
    function setFee(uint256 newFee) external override {

        onlyFactory();
        _setFee(newFee);
    }
    
    function setFeeDestination(address newFeeDestination) external override {

        onlyFactory();
        _setFeeDestination(newFeeDestination);
    }
	
	function setWithdrawOpenPositionPenalty(uint256 newWithdrawOpenPositionPenalty) external override {

        onlyFactory();
		_setWithdrawOpenPositionPenalty(newWithdrawOpenPositionPenalty);
	}
	
	function setUnderlyingPriceAdjustPercentage(uint256 newUnderlyingPriceAdjustPercentage) external override {

        onlyFactory();
		_setUnderlyingPriceAdjustPercentage(newUnderlyingPriceAdjustPercentage);
	}
	
	function setMaximumOpenAco(uint256 newMaximumOpenAco) external override {

        onlyFactory();
		_setMaximumOpenAco(newMaximumOpenAco);
	}

	function setStrategy(address newStrategy) external override {

        onlyFactory();
		_setStrategy(newStrategy);
	}
	
	function setBaseVolatility(uint256 newBaseVolatility) external override {

        onlyFactory();
		_setBaseVolatility(newBaseVolatility);
	}
	
	function setValidAcoCreator(address newAcoCreator, bool newPermission) external override {

        onlyFactory();
        _setValidAcoCreator(newAcoCreator, newPermission);
    }
	
    function withdrawStuckToken(address token, address destination) external override {

        onlyFactory();
        require(token != underlying && token != strikeAsset && !acoData[token].open, "E80");
        uint256 _balance = ACOAssetHelper._getAssetBalanceOf(token, address(this));
        if (_balance > 0) {
            ACOAssetHelper._transferAsset(token, destination, _balance);
        }
    }

	function deposit(uint256 collateralAmount, uint256 minShares, address to) external payable override returns(uint256) {

        return _deposit(collateralAmount, minShares, to);
    }
	
	function depositWithGasToken(uint256 collateralAmount, uint256 minShares, address to) discountCHI external payable override returns(uint256) {

        return _deposit(collateralAmount, minShares, to);
    }

	function withdrawNoLocked(uint256 shares, uint256 minCollateral, address account) external override returns (
		uint256 underlyingWithdrawn,
		uint256 strikeAssetWithdrawn
	) {

        (underlyingWithdrawn, strikeAssetWithdrawn) = _withdrawNoLocked(shares, minCollateral, account);
    }
	
	function withdrawNoLockedWithGasToken(uint256 shares, uint256 minCollateral, address account) discountCHI external override returns (
		uint256 underlyingWithdrawn,
		uint256 strikeAssetWithdrawn
	) {

        (underlyingWithdrawn, strikeAssetWithdrawn) = _withdrawNoLocked(shares, minCollateral, account);
    }
	
    function withdrawWithLocked(uint256 shares, address account) external override returns (
		uint256 underlyingWithdrawn,
		uint256 strikeAssetWithdrawn,
		address[] memory acos,
		uint256[] memory acosAmount
	) {

        (underlyingWithdrawn, strikeAssetWithdrawn, acos, acosAmount) = _withdrawWithLocked(shares, account);
    }
	
	function withdrawWithLockedWithGasToken(uint256 shares, address account) discountCHI external override returns (
		uint256 underlyingWithdrawn,
		uint256 strikeAssetWithdrawn,
		address[] memory acos,
		uint256[] memory acosAmount
	) {

        (underlyingWithdrawn, strikeAssetWithdrawn, acos, acosAmount) = _withdrawWithLocked(shares, account);
    }
	
	function swap(
        address acoToken, 
        uint256 tokenAmount, 
        uint256 restriction, 
        address to, 
        uint256 deadline
    ) external override {

        _swap(acoToken, tokenAmount, restriction, to, deadline);
    }

    function swapWithGasToken(
        address acoToken, 
        uint256 tokenAmount, 
        uint256 restriction, 
        address to, 
        uint256 deadline
    ) discountCHI external override {

        _swap(acoToken, tokenAmount, restriction, to, deadline);
    }
    
    function redeemACOTokens() public override {

        for (uint256 i = openAcos.length; i > 0; --i) {
            address acoToken = openAcos[i - 1];
            _redeemACOToken(acoToken);
        }
    }

	function redeemACOToken(address acoToken) external override {

		_redeemACOToken(acoToken);
    }
	
	function restoreCollateral() external override {

        address _strikeAsset = strikeAsset;
        address _underlying = underlying;
        bool _isCall = isCall;
        
        uint256 balanceOut;
        address assetIn;
        address assetOut;
        if (_isCall) {
            balanceOut = _getPoolBalanceOf(_strikeAsset);
            assetIn = _underlying;
            assetOut = _strikeAsset;
        } else {
            balanceOut = _getPoolBalanceOf(_underlying);
            assetIn = _strikeAsset;
            assetOut = _underlying;
        }
        require(balanceOut > 0, "E60");
        
		uint256 etherAmount = 0;
        if (ACOAssetHelper._isEther(assetOut)) {
			etherAmount = balanceOut;
        }
        uint256 collateralRestored = assetConverter.swapExactAmountOut{value: etherAmount}(assetOut, assetIn, balanceOut);

        emit RestoreCollateral(balanceOut, collateralRestored);
    }

	function _deposit(uint256 collateralAmount, uint256 minShares, address to) internal returns(uint256 shares) {

        require(collateralAmount > 0, "E10");
        require(to != address(0) && to != address(this), "E11");
		
		(,,uint256 collateralBalance, uint256 collateralOnOpenPosition,) = _getTotalCollateralBalance(true);
		collateralBalance = collateralBalance.sub(collateralOnOpenPosition);

		address _collateral = collateral();
		if (ACOAssetHelper._isEther(_collateral)) {
            collateralBalance = collateralBalance.sub(msg.value);
		}
        
        if (collateralBalance == 0) {
            shares = collateralAmount;
        } else {
            shares = collateralAmount.mul(totalSupply()).div(collateralBalance);
        }
        require(shares >= minShares, "E12");

        ACOAssetHelper._receiveAsset(_collateral, collateralAmount);

        super._mintAction(to, shares);
        
        emit Deposit(to, shares, collateralAmount);
    }
	
	function _getWithdrawWithLocked(uint256 shares) internal view returns (
		uint256 underlyingWithdrawn,
		uint256 strikeAssetWithdrawn,
		address[] memory acos,
		uint256[] memory acosAmount
	) {

        uint256 _totalSupply = totalSupply();	
        if (shares > 0 && shares <= _totalSupply) {
        
			uint256 underlyingBalance = _getPoolBalanceOf(underlying);
			uint256 strikeAssetBalance = _getPoolBalanceOf(strikeAsset);
		
            acos = new address[](openAcos.length);
            acosAmount = new uint256[](openAcos.length);
			for (uint256 i = 0; i < openAcos.length; ++i) {
				address acoToken = openAcos[i];
				uint256 tokens = IACOToken(acoToken).currentCollateralizedTokens(address(this));
				
				acos[i] = acoToken;
				acosAmount[i] = tokens.mul(shares).div(_totalSupply);
			}
			
			underlyingWithdrawn = underlyingBalance.mul(shares).div(_totalSupply);
			strikeAssetWithdrawn = strikeAssetBalance.mul(shares).div(_totalSupply);
		}
    }

	function _getDepositShares(uint256 collateralAmount) internal view returns(uint256) {

        (,,uint256 collateralBalance, uint256 collateralOnOpenPosition,) = _getTotalCollateralBalance(true);
		collateralBalance = collateralBalance.sub(collateralOnOpenPosition);

        if (collateralBalance == 0) {
            return collateralAmount;
        } else {
            return collateralAmount.mul(totalSupply()).div(collateralBalance);
        }
    }
	
	function _getWithdrawNoLockedData(uint256 shares) internal view returns (
		uint256 underlyingWithdrawn,
		uint256 strikeAssetWithdrawn,
		bool isPossible
	) {

        uint256 _totalSupply = totalSupply();
		if (shares > 0 && shares <= _totalSupply) {
			
			(uint256 underlyingBalance, 
             uint256 strikeAssetBalance, 
             uint256 collateralBalance, 
             uint256 collateralOnOpenPosition,
             uint256 collateralLockedRedeemable) = _getTotalCollateralBalance(false);

			if (collateralBalance > collateralOnOpenPosition) {
				
				uint256 collateralAmount = shares.mul(collateralBalance.sub(collateralOnOpenPosition)).div(_totalSupply);
				
				if (isCall) {
					if (collateralAmount <= underlyingBalance.add(collateralLockedRedeemable)) {
						underlyingWithdrawn = collateralAmount;
						strikeAssetWithdrawn = strikeAssetBalance.mul(shares).div(_totalSupply);
						isPossible = true;
					}
				} else if (collateralAmount <= strikeAssetBalance.add(collateralLockedRedeemable)) {
					strikeAssetWithdrawn = collateralAmount;
					underlyingWithdrawn = underlyingBalance.mul(shares).div(_totalSupply);
					isPossible = true;
				}
			}
		}
	}

    function _withdrawNoLocked(uint256 shares, uint256 minCollateral, address account) internal returns (
		uint256 underlyingWithdrawn,
		uint256 strikeAssetWithdrawn
	) {

        require(shares > 0, "E30");
        
		redeemACOTokens();
		
        uint256 _totalSupply = totalSupply();
        _callBurn(account, shares);
        
		(uint256 underlyingBalance, 
         uint256 strikeAssetBalance, 
         uint256 collateralBalance,
         uint256 collateralOnOpenPosition,) = _getTotalCollateralBalance(false);
		require(collateralBalance > collateralOnOpenPosition, "E31");

		uint256 collateralAmount = shares.mul(collateralBalance.sub(collateralOnOpenPosition)).div(_totalSupply);
		require(collateralAmount >= minCollateral, "E32");

        if (isCall) {
			require(collateralAmount <= underlyingBalance, "E33");
			underlyingWithdrawn = collateralAmount;
			strikeAssetWithdrawn = strikeAssetBalance.mul(shares).div(_totalSupply);
        } else {
			require(collateralAmount <= strikeAssetBalance, "E34");
			strikeAssetWithdrawn = collateralAmount;
			underlyingWithdrawn = underlyingBalance.mul(shares).div(_totalSupply);
		}
        
		ACOAssetHelper._transferAsset(underlying, msg.sender, underlyingWithdrawn);
		ACOAssetHelper._transferAsset(strikeAsset, msg.sender, strikeAssetWithdrawn);
		
        emit Withdraw(account, shares, true, underlyingWithdrawn, strikeAssetWithdrawn, new address[](0), new uint256[](0));
    }
	
	function _withdrawWithLocked(uint256 shares, address account) internal returns (
		uint256 underlyingWithdrawn,
		uint256 strikeAssetWithdrawn,
		address[] memory acos,
		uint256[] memory acosAmount
	) {

        require(shares > 0, "E20");
        
		redeemACOTokens();
		
        uint256 _totalSupply = totalSupply();
        _callBurn(account, shares);
        
		address _underlying = underlying;
		address _strikeAsset = strikeAsset;
		uint256 underlyingBalance = _getPoolBalanceOf(_underlying);
		uint256 strikeAssetBalance = _getPoolBalanceOf(_strikeAsset);
		
		(acos, acosAmount) = _transferOpenPositions(shares, _totalSupply);
		
		underlyingWithdrawn = underlyingBalance.mul(shares).div(_totalSupply);
		strikeAssetWithdrawn = strikeAssetBalance.mul(shares).div(_totalSupply);
		
		ACOAssetHelper._transferAsset(_underlying, msg.sender, underlyingWithdrawn);
		ACOAssetHelper._transferAsset(_strikeAsset, msg.sender, strikeAssetWithdrawn);
		
        emit Withdraw(account, shares, false, underlyingWithdrawn, strikeAssetWithdrawn, acos, acosAmount);
    }
	
	function _getTotalCollateralBalance(bool isDeposit) internal view returns(
        uint256 underlyingBalance, 
        uint256 strikeAssetBalance, 
        uint256 collateralBalance,
        uint256 collateralOnOpenPosition,
        uint256 collateralLockedRedeemable
    ) {

		underlyingBalance = _getPoolBalanceOf(underlying);
		strikeAssetBalance = _getPoolBalanceOf(strikeAsset);
		
		uint256 underlyingPrice = assetConverter.getPrice(underlying, strikeAsset);
		
		if (isCall) {
			collateralBalance = underlyingBalance;
			if (isDeposit && strikeAssetBalance > 0) {
				uint256 priceAdjusted = _getUnderlyingPriceAdjusted(underlyingPrice, false); 
				collateralBalance = collateralBalance.add(strikeAssetBalance.mul(underlyingPrecision).div(priceAdjusted));
			}
		} else {
			collateralBalance = strikeAssetBalance;
			if (isDeposit && underlyingBalance > 0) {
				uint256 priceAdjusted = _getUnderlyingPriceAdjusted(underlyingPrice, true); 
				collateralBalance = collateralBalance.add(underlyingBalance.mul(priceAdjusted).div(underlyingPrecision));
			}
		}
		
        uint256 collateralLocked;
		(collateralLocked, collateralOnOpenPosition, collateralLockedRedeemable) = _poolOpenPositionCollateralBalance(underlyingPrice, isDeposit);
		
        collateralBalance = collateralBalance.add(collateralLocked);
	}
	
	function _callBurn(address account, uint256 tokenAmount) internal {

        if (account == msg.sender) {
            super._burnAction(account, tokenAmount);
        } else {
            super._burnFrom(account, tokenAmount);
        }
    }
	
	function _swap(
        address acoToken, 
        uint256 tokenAmount, 
        uint256 restriction, 
        address to, 
        uint256 deadline
    ) internal {

        require(block.timestamp <= deadline, "E40");
        require(to != address(0) && to != acoToken && to != address(this), "E41");
        
        (uint256 swapPrice, uint256 protocolFee, uint256 underlyingPrice, uint256 volatility, uint256 collateralAmount) = _quote(acoToken, tokenAmount);
        
        _internalSelling(to, acoToken, collateralAmount, tokenAmount, restriction, swapPrice, protocolFee);

        if (protocolFee > 0) {
            ACOAssetHelper._transferAsset(strikeAsset, feeDestination, protocolFee);
        }
        
        emit Swap(msg.sender, acoToken, tokenAmount, swapPrice, protocolFee, underlyingPrice, volatility);
    }

	function _quote(address acoToken, uint256 tokenAmount) internal view returns(
        uint256 swapPrice, 
        uint256 protocolFee, 
        uint256 underlyingPrice, 
        uint256 volatility, 
        uint256 collateralAmount
    ) {

        require(tokenAmount > 0, "E50");
        
        (address _underlying, address _strikeAsset, bool _isCall, uint256 strikePrice, uint256 expiryTime) = acoFactory.acoTokenData(acoToken);
        
		require(_acoBasicDataIsValid(acoToken, _underlying, _strikeAsset, _isCall), "E51");
		require(_acoExpirationIsValid(expiryTime), "E52");
		
		underlyingPrice = assetConverter.getPrice(_underlying, _strikeAsset);
		require(_acoStrikePriceIsValid(strikePrice, underlyingPrice), "E53");

        require(expiryTime > block.timestamp, "E54");
        (swapPrice, protocolFee, volatility, collateralAmount) = _internalQuote(acoToken, tokenAmount, strikePrice, expiryTime, underlyingPrice);
    }
	
	function _internalQuote(
		address acoToken, 
		uint256 tokenAmount, 
		uint256 strikePrice, 
		uint256 expiryTime, 
		uint256 underlyingPrice
	) internal view returns(
        uint256 swapPrice, 
        uint256 protocolFee, 
        uint256 volatility, 
        uint256 collateralAmount
    ) {

        uint256 collateralAvailable;
        (collateralAmount, collateralAvailable) = _getSizeData(acoToken, tokenAmount);
        (swapPrice, volatility) = _strategyQuote(strikePrice, expiryTime, underlyingPrice, collateralAmount, collateralAvailable);
        
        swapPrice = swapPrice.mul(tokenAmount).div(underlyingPrecision);
        
        if (fee > 0) {
            protocolFee = swapPrice.mul(fee).div(PERCENTAGE_PRECISION);
			swapPrice = swapPrice.add(protocolFee);
        }
        require(swapPrice > 0, "E55");
    }

    function _getSizeData(address acoToken, uint256 tokenAmount) internal view returns(
        uint256 collateralAmount, 
        uint256 collateralAvailable
    ) {

        if (isCall) {
            collateralAvailable = _getPoolBalanceOf(underlying);
            collateralAmount = tokenAmount; 
        } else {
            collateralAvailable = _getPoolBalanceOf(strikeAsset);
            collateralAmount = IACOToken(acoToken).getCollateralAmount(tokenAmount);
            require(collateralAmount > 0, "E56");
        }
        require(collateralAmount <= collateralAvailable, "E57");
    }

    function _strategyQuote(
        uint256 strikePrice,
        uint256 expiryTime,
        uint256 underlyingPrice,
        uint256 collateralAmount,
        uint256 collateralAvailable
    ) internal view returns(uint256 swapPrice, uint256 volatility) {

        (swapPrice, volatility) = strategy.quote(IACOPoolStrategy.OptionQuote(
			underlyingPrice,
            underlying, 
            strikeAsset, 
            isCall, 
            strikePrice, 
            expiryTime, 
            baseVolatility, 
            collateralAmount, 
            collateralAvailable
        ));
    }

    function _internalSelling(
        address to,
        address acoToken, 
        uint256 collateralAmount, 
        uint256 tokenAmount,
        uint256 maxPayment,
        uint256 swapPrice,
        uint256 protocolFee
    ) internal {

        require(swapPrice <= maxPayment, "E42");
        
        ACOAssetHelper._callTransferFromERC20(strikeAsset, msg.sender, address(this), swapPrice);

		address _collateral = collateral();
        AcoData storage data = acoData[acoToken];
		if (ACOAssetHelper._isEther(_collateral)) {
			tokenAmount = IACOToken(acoToken).mintPayable{value: collateralAmount}();
		} else {
			if (!data.open) {
				_setAuthorizedSpender(_collateral, acoToken);    
			}
			tokenAmount = IACOToken(acoToken).mint(collateralAmount);
		}

		if (!data.open) {
            require(openAcos.length < maximumOpenAco, "E43");
			acoData[acoToken] = AcoData(true, swapPrice.sub(protocolFee), collateralAmount, 0, acoTokens.length, openAcos.length);
            acoTokens.push(acoToken);    
            openAcos.push(acoToken);   
        } else {
			data.collateralLocked = collateralAmount.add(data.collateralLocked);
			data.valueSold = swapPrice.sub(protocolFee).add(data.valueSold);
		}
        
        ACOAssetHelper._callTransferERC20(acoToken, to, tokenAmount);
    }
	
	function _poolOpenPositionCollateralBalance(uint256 underlyingPrice, bool isDeposit) internal view returns(
        uint256 collateralLocked, 
        uint256 collateralOnOpenPosition,
        uint256 collateralLockedRedeemable
    ) {

		bool _collateralIsUnderlying = isCall;
        uint256 _underlyingPrecision = underlyingPrecision;
        IACOFactory _acoFactory = acoFactory;
		for (uint256 i = 0; i < openAcos.length; ++i) {
			address acoToken = openAcos[i];

            (uint256 locked, uint256 openPosition, uint256 lockedRedeemable) = _getOpenPositionCollateralBalance(
                acoToken,
                underlyingPrice,
                _underlyingPrecision,
                _acoFactory,
                _collateralIsUnderlying
            );
            
            collateralLocked = collateralLocked.add(locked);
            collateralOnOpenPosition = collateralOnOpenPosition.add(openPosition);
            collateralLockedRedeemable = collateralLockedRedeemable.add(lockedRedeemable);
		}
		if (!isDeposit) {
			collateralOnOpenPosition = collateralOnOpenPosition.mul(PERCENTAGE_PRECISION.add(withdrawOpenPositionPenalty)).div(PERCENTAGE_PRECISION);
		}
	}

    function _getOpenPositionCollateralBalance(
        address acoToken,
        uint256 underlyingPrice,
        uint256 _underlyingPrecision,
        IACOFactory _acoFactory,
        bool _collateralIsUnderlying
    ) internal view returns(
        uint256 collateralLocked, 
        uint256 collateralOnOpenPosition,
        uint256 collateralLockedRedeemable
    ) {

        (,,,uint256 _strikePrice, uint256 _expiryTime) = _acoFactory.acoTokenData(acoToken);
			
        uint256 tokenAmount = IACOToken(acoToken).currentCollateralizedTokens(address(this));
        
        if (_collateralIsUnderlying) {
            collateralLocked = tokenAmount;
        } else {
            collateralLocked = tokenAmount.mul(_strikePrice).div(_underlyingPrecision);
        }
		
        if (_expiryTime > block.timestamp) {
            (uint256 price,) = _strategyQuote(_strikePrice, _expiryTime, underlyingPrice, 0, 1);
            if (_collateralIsUnderlying) {
                uint256 priceAdjusted = _getUnderlyingPriceAdjusted(underlyingPrice, false); 
                collateralOnOpenPosition = price.mul(tokenAmount).div(priceAdjusted);
            } else {
                collateralOnOpenPosition = price.mul(tokenAmount).div(_underlyingPrecision);
            }
        } else {
            collateralLockedRedeemable = collateralLocked;
        }
    }
	
	function _transferOpenPositions(uint256 shares, uint256 _totalSupply) internal returns(
        address[] memory acos, 
        uint256[] memory acosAmount
    ) {

        uint256 size = openAcos.length;
        acos = new address[](size);
        acosAmount = new uint256[](size);
		for (uint256 i = 0; i < size; ++i) {
			address acoToken = openAcos[i];
			uint256 tokens = IACOToken(acoToken).currentCollateralizedTokens(address(this));
			
			acos[i] = acoToken;
			acosAmount[i] = tokens.mul(shares).div(_totalSupply);
			
            if (acosAmount[i] > 0) {
			    IACOToken(acoToken).transferCollateralOwnership(msg.sender, acosAmount[i]);
            }
		}
	}
	
	function _getUnderlyingPriceAdjusted(uint256 underlyingPrice, bool isMaximum) internal view returns(uint256) {

		if (isMaximum) {
			return underlyingPrice.mul(PERCENTAGE_PRECISION.add(underlyingPriceAdjustPercentage)).div(PERCENTAGE_PRECISION);
		} else {
			return underlyingPrice.mul(PERCENTAGE_PRECISION.sub(underlyingPriceAdjustPercentage)).div(PERCENTAGE_PRECISION);
		}
    }
	
    function _removeFromOpenAcos(AcoData storage data) internal {

        uint256 lastIndex = openAcos.length - 1;
		uint256 index = data.openIndex;
		if (lastIndex != index) {
		    address last = openAcos[lastIndex];
			openAcos[index] = last;
			acoData[last].openIndex = index;
		}
		data.openIndex = 0;
        openAcos.pop();
    }
	
	function _redeemACOToken(address acoToken) internal {

		AcoData storage data = acoData[acoToken];
		if (data.open && IACOToken(acoToken).expiryTime() <= block.timestamp) {
			
            data.open = false;

            if (IACOToken(acoToken).currentCollateralizedTokens(address(this)) > 0) {	
			    data.collateralRedeemed = IACOToken(acoToken).redeem();
            }
            
			_removeFromOpenAcos(data);
			
			emit ACORedeem(acoToken, data.valueSold, data.collateralLocked, data.collateralRedeemed);
		}
    }
	
	function _acoBasicDataIsValid(address acoToken, address _underlying, address _strikeAsset, bool _isCall) internal view returns(bool) {

		return _underlying == underlying && _strikeAsset == strikeAsset && _isCall == isCall && validAcoCreators[acoFactory.creators(acoToken)];
	}
	
	function _acoExpirationIsValid(uint256 _expiryTime) internal view returns(bool) {

		return _expiryTime >= block.timestamp.add(minExpiration) && _expiryTime <= block.timestamp.add(maxExpiration);
	}
	
	function _acoStrikePriceIsValid(uint256 _strikePrice, uint256 price) internal view returns(bool) {

		uint256 _tolerancePriceAbove = tolerancePriceAbove;
		uint256 _tolerancePriceBelow = tolerancePriceBelow;
		return (_tolerancePriceBelow == 0 && _tolerancePriceAbove == 0) ||
			(_tolerancePriceBelow == 0 && _strikePrice > price.mul(PERCENTAGE_PRECISION.add(_tolerancePriceAbove)).div(PERCENTAGE_PRECISION)) ||
			(_tolerancePriceAbove == 0 && _strikePrice < price.mul(PERCENTAGE_PRECISION.sub(_tolerancePriceBelow)).div(PERCENTAGE_PRECISION)) ||
			(_strikePrice >= price.mul(PERCENTAGE_PRECISION.sub(_tolerancePriceBelow)).div(PERCENTAGE_PRECISION) && 
			 _strikePrice <= price.mul(PERCENTAGE_PRECISION.add(_tolerancePriceAbove)).div(PERCENTAGE_PRECISION));
	}
	
	function _approveAssetsOnConverterHelper(
        bool _isCall, 
        address _assetConverterHelper,
        address _underlying,
        address _strikeAsset
    ) internal {

        if (_isCall) {
            if (!ACOAssetHelper._isEther(_strikeAsset)) {
                _setAuthorizedSpender(_strikeAsset, _assetConverterHelper);
            }
        } else if (!ACOAssetHelper._isEther(_underlying)) {
            _setAuthorizedSpender(_underlying, _assetConverterHelper);
        }
    }
	
	function _getPoolBalanceOf(address asset) internal view returns(uint256) {

        return ACOAssetHelper._getAssetBalanceOf(asset, address(this));
    }
	
	function _setAuthorizedSpender(address asset, address spender) internal {

        ACOAssetHelper._callApproveERC20(asset, spender, MAX_UINT);
    }
	
	function _setStrategy(address newStrategy) internal {

        require(newStrategy.isContract(), "E81");
        emit SetStrategy(address(strategy), newStrategy);
        strategy = IACOPoolStrategy(newStrategy);
    }

    function _setBaseVolatility(uint256 newBaseVolatility) internal {

        require(newBaseVolatility > 0, "E82");
        emit SetBaseVolatility(baseVolatility, newBaseVolatility);
        baseVolatility = newBaseVolatility;
    }

    function _setAssetConverter(address newAssetConverter) internal {

        require(newAssetConverter.isContract(), "E83");
		require(IACOAssetConverterHelper(newAssetConverter).getPrice(underlying, strikeAsset) > 0, "E84");
		
		_approveAssetsOnConverterHelper(isCall, newAssetConverter, underlying, strikeAsset);
		
        emit SetAssetConverter(address(assetConverter), newAssetConverter);
        assetConverter = IACOAssetConverterHelper(newAssetConverter);
    }

    function _setTolerancePriceAbove(uint256 newTolerancePriceAbove) internal {

        require(newTolerancePriceAbove < PERCENTAGE_PRECISION, "E85");
        emit SetTolerancePriceAbove(tolerancePriceAbove, newTolerancePriceAbove);
        tolerancePriceAbove = newTolerancePriceAbove;
    }
    
    function _setTolerancePriceBelow(uint256 newTolerancePriceBelow) internal {

        require(newTolerancePriceBelow < PERCENTAGE_PRECISION, "E86");
        emit SetTolerancePriceBelow(tolerancePriceBelow, newTolerancePriceBelow);
        tolerancePriceBelow = newTolerancePriceBelow;
    }
    
    function _setMinExpiration(uint256 newMinExpiration) internal {

        require(newMinExpiration <= maxExpiration, "E87");
        emit SetMinExpiration(minExpiration, newMinExpiration);
        minExpiration = newMinExpiration;
    }
    
    function _setMaxExpiration(uint256 newMaxExpiration) internal {

        require(newMaxExpiration >= minExpiration, "E88");
        emit SetMaxExpiration(maxExpiration, newMaxExpiration);
        maxExpiration = newMaxExpiration;
    }
    
    function _setFeeDestination(address newFeeDestination) internal {

        require(newFeeDestination != address(0), "E89");
        emit SetFeeDestination(feeDestination, newFeeDestination);
        feeDestination = newFeeDestination;
    }
    
    function _setFee(uint256 newFee) internal {

        require(newFee <= 12500, "E91");
        emit SetFee(fee, newFee);
        fee = newFee;
    }
	
    function _setWithdrawOpenPositionPenalty(uint256 newWithdrawOpenPositionPenalty) internal {

        require(newWithdrawOpenPositionPenalty <= PERCENTAGE_PRECISION, "E92");
        emit SetWithdrawOpenPositionPenalty(withdrawOpenPositionPenalty, newWithdrawOpenPositionPenalty);
        withdrawOpenPositionPenalty = newWithdrawOpenPositionPenalty;
    }
	
	function _setUnderlyingPriceAdjustPercentage(uint256 newUnderlyingPriceAdjustPercentage) internal {

        require(newUnderlyingPriceAdjustPercentage < PERCENTAGE_PRECISION, "E93");
        emit SetUnderlyingPriceAdjustPercentage(underlyingPriceAdjustPercentage, newUnderlyingPriceAdjustPercentage);
        underlyingPriceAdjustPercentage = newUnderlyingPriceAdjustPercentage;
    }

	function _setMaximumOpenAco(uint256 newMaximumOpenAco) internal {

        require(newMaximumOpenAco > 0, "E94");
        emit SetMaximumOpenAco(maximumOpenAco, newMaximumOpenAco);
        maximumOpenAco = newMaximumOpenAco;
    }
	
    function _setValidAcoCreator(address creator, bool newPermission) internal {

        emit SetValidAcoCreator(creator, validAcoCreators[creator], newPermission);
        validAcoCreators[creator] = newPermission;
    }

    function onlyFactory() internal view {

        require(owner() == msg.sender, "E90");
    }
	
	function _name() internal view returns(string memory) {

        return string(abi.encodePacked(
            "ACO POOL WRITE ",
            ACOAssetHelper._getAssetSymbol(underlying),
            "-",
            ACOAssetHelper._getAssetSymbol(strikeAsset),
            "-",
            (isCall ? "CALL" : "PUT")
        ));
    }
}