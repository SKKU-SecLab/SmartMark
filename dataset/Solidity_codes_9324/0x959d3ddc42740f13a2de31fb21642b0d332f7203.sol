
pragma solidity >=0.6.0 <0.8.0;

library SafeMath {

    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        uint256 c = a + b;
        if (c < a) return (false, 0);
        return (true, c);
    }

    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        if (b > a) return (false, 0);
        return (true, a - b);
    }

    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        if (a == 0) return (true, 0);
        uint256 c = a * b;
        if (c / a != b) return (false, 0);
        return (true, c);
    }

    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        if (b == 0) return (false, 0);
        return (true, a / b);
    }

    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        if (b == 0) return (false, 0);
        return (true, a % b);
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {

        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");
        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b <= a, "SafeMath: subtraction overflow");
        return a - b;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {

        if (a == 0) return 0;
        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");
        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b > 0, "SafeMath: division by zero");
        return a / b;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b > 0, "SafeMath: modulo by zero");
        return a % b;
    }

    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        require(b <= a, errorMessage);
        return a - b;
    }

    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        require(b > 0, errorMessage);
        return a / b;
    }

    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        require(b > 0, errorMessage);
        return a % b;
    }
}

pragma solidity >=0.6.0 <0.8.0;

abstract contract ReentrancyGuard {

    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor () internal {
        _status = _NOT_ENTERED;
    }

    modifier nonReentrant() {
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        _status = _ENTERED;

        _;

        _status = _NOT_ENTERED;
    }
}
pragma solidity 0.6.12;

contract HoldefiOwnable {

    address public owner;
    address public pendingOwner;

    event OwnershipTransferRequested(address newPendingOwner);

    event OwnershipTransferred(address newOwner, address oldOwner);

    constructor () public {
        owner = msg.sender;
        emit OwnershipTransferred(owner, address(0));
    }

    modifier onlyOwner() {

        require(msg.sender == owner, "OE01");
        _;
    }

    function transferOwnership(address newOwner) external onlyOwner {

        require(newOwner != address(0), "OE02");
        pendingOwner = newOwner;

        emit OwnershipTransferRequested(newOwner);
    }

    function acceptTransferOwnership () external {
        require (pendingOwner != address(0), "OE03");
        require (pendingOwner == msg.sender, "OE04");
        
        emit OwnershipTransferred(pendingOwner, owner);
        owner = pendingOwner;
        pendingOwner = address(0);
    }
}// UNLICENSED
pragma solidity 0.6.12;
pragma experimental ABIEncoderV2;


contract HoldefiPausableOwnable is HoldefiOwnable {


    uint256 constant private maxPauseDuration = 2592000;     //seconds per month

    struct Operation {
        bool isValid;
        uint256 pauseEndTime;
    }

    address public pauser;

    mapping(string => Operation) public paused;

    event PauserChanged(address newPauser, address oldPauser);

    event OperationPaused(string operation, uint256 pauseDuration);

    event OperationUnpaused(string operation);
    
    constructor () public {
        paused["supply"].isValid = true;
        paused["withdrawSupply"].isValid = true;
        paused["collateralize"].isValid = true;
        paused["withdrawCollateral"].isValid = true;
        paused["borrow"].isValid = true;
        paused["repayBorrow"].isValid = true;
        paused["liquidateBorrowerCollateral"].isValid = true;
        paused["buyLiquidatedCollateral"].isValid = true;
        paused["depositPromotionReserve"].isValid = true;
        paused["depositLiquidationReserve"].isValid = true;
    }

    modifier onlyPausers() {

        require(msg.sender == owner || msg.sender == pauser , "POE01");
        _;
    }
    
    modifier whenNotPaused(string memory operation) {

        require(!isPaused(operation), "POE02");
        _;
    }

    modifier whenPaused(string memory operation) {

        require(isPaused(operation), "POE03");
        _;
    }

    modifier operationIsValid(string memory operation) {

        require(paused[operation].isValid ,"POE04");
        _;
    }

    function isPaused(string memory operation) public view returns (bool res) {

        res = block.timestamp <= paused[operation].pauseEndTime;
    }

    function pause(string memory operation, uint256 pauseDuration)
        public
        onlyPausers
        operationIsValid(operation)
        whenNotPaused(operation)
    {

        require (pauseDuration <= maxPauseDuration, "POE05");
        paused[operation].pauseEndTime = block.timestamp + pauseDuration;
        emit OperationPaused(operation, pauseDuration);
    }

    function unpause(string memory operation)
        public
        onlyOwner
        operationIsValid(operation)
        whenPaused(operation)
    {

        paused[operation].pauseEndTime = 0;
        emit OperationUnpaused(operation);
    }

    function batchPause(string[] memory operations, uint256[] memory pauseDurations) external {

        require (operations.length == pauseDurations.length, "POE06");
        for (uint256 i = 0 ; i < operations.length ; i++) {
            pause(operations[i], pauseDurations[i]);
        }
    }

    function batchUnpause(string[] memory operations) external {

        for (uint256 i = 0 ; i < operations.length ; i++) {
            unpause(operations[i]);
        }
    }

    function setPauser(address newPauser) external onlyOwner {

        emit PauserChanged(newPauser, pauser);
        pauser = newPauser;
    }
}// MIT

pragma solidity ^0.6.0;

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

pragma solidity ^0.6.2;

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

    function functionCall(address target, bytes memory data) internal returns (bytes memory) {

      return functionCall(target, data, "Address: low-level call failed");
    }

    function functionCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {

        return _functionCallWithValue(target, data, 0, errorMessage);
    }

    function functionCallWithValue(address target, bytes memory data, uint256 value) internal returns (bytes memory) {

        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    function functionCallWithValue(address target, bytes memory data, uint256 value, string memory errorMessage) internal returns (bytes memory) {

        require(address(this).balance >= value, "Address: insufficient balance for call");
        return _functionCallWithValue(target, data, value, errorMessage);
    }

    function _functionCallWithValue(address target, bytes memory data, uint256 weiValue, string memory errorMessage) private returns (bytes memory) {

        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{ value: weiValue }(data);
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

pragma solidity >=0.6.0 <0.8.0;


library SafeERC20 {

    using SafeMath for uint256;
    using Address for address;

    function safeTransfer(IERC20 token, address to, uint256 value) internal {

        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(IERC20 token, address from, address to, uint256 value) internal {

        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    function safeApprove(IERC20 token, address spender, uint256 value) internal {

        require((value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(IERC20 token, address spender, uint256 value) internal {

        uint256 newAllowance = token.allowance(address(this), spender).add(value);
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(IERC20 token, address spender, uint256 value) internal {

        uint256 newAllowance = token.allowance(address(this), spender).sub(value, "SafeERC20: decreased allowance below zero");
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function _callOptionalReturn(IERC20 token, bytes memory data) private {


        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) { // Return data is optional
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}
pragma solidity 0.6.12;



contract HoldefiCollaterals {


	using SafeERC20 for IERC20;

	address constant private ethAddress = 0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE;

	address public holdefiContract;

	constructor() public {
		holdefiContract = msg.sender;
	}

    modifier onlyHoldefiContract() {

        require (msg.sender == holdefiContract, "CE01");
        _;
    }

    receive() external payable onlyHoldefiContract {
	}

	function withdraw (address collateral, address recipient, uint256 amount)
		external
		onlyHoldefiContract
	{
		if (collateral == ethAddress){
			(bool success, ) = recipient.call{value:amount}("");
			require (success, "CE02");
		}
		else {
			IERC20 token = IERC20(collateral);
			token.safeTransfer(recipient, amount);
		}
	}
}// UNLICENSED
pragma solidity 0.6.12;



interface HoldefiPricesInterface {

	function getAssetValueFromAmount(address asset, uint256 amount) external view returns(uint256 value);

	function getAssetAmountFromValue(address asset, uint256 value) external view returns(uint256 amount);	

}

interface HoldefiSettingsInterface {


	struct MarketSettings {
		bool isExist;
		bool isActive;      

		uint256 borrowRate;
		uint256 borrowRateUpdateTime;

		uint256 suppliersShareRate;
		uint256 suppliersShareRateUpdateTime;

		uint256 promotionRate;
	}

	struct CollateralSettings {
		bool isExist;
		bool isActive;    

		uint256 valueToLoanRate; 
		uint256 VTLUpdateTime;

		uint256 penaltyRate;
		uint256 penaltyUpdateTime;

		uint256 bonusRate;
	}

	function getInterests(address market)
		external
		view
		returns (uint256 borrowRate, uint256 supplyRateBase, uint256 promotionRate);

	function resetPromotionRate (address market) external;
	function getMarketsList() external view returns(address[] memory marketsList);

	function marketAssets(address market) external view returns(MarketSettings memory);

	function collateralAssets(address collateral) external view returns(CollateralSettings memory);

}

contract Holdefi is HoldefiPausableOwnable, ReentrancyGuard {


	using SafeMath for uint256;

	using SafeERC20 for IERC20;

	struct Market {
		uint256 totalSupply;

		uint256 supplyIndex;      				// Scaled by: secondsPerYear * rateDecimals
		uint256 supplyIndexUpdateTime;

		uint256 totalBorrow;

		uint256 borrowIndex;      				// Scaled by: secondsPerYear * rateDecimals
		uint256 borrowIndexUpdateTime;

		uint256 promotionReserveScaled;      	// Scaled by: secondsPerYear * rateDecimals
		uint256 promotionReserveLastUpdateTime;

		uint256 promotionDebtScaled;      		// Scaled by: secondsPerYear * rateDecimals
		uint256 promotionDebtLastUpdateTime;
	}

	struct Collateral {
		uint256 totalCollateral;
		uint256 totalLiquidatedCollateral;
	}

	struct MarketAccount {
		mapping (address => uint) allowance;
		uint256 balance;
		uint256 accumulatedInterest;

		uint256 lastInterestIndex;      		// Scaled by: secondsPerYear * rateDecimals
	}

	struct CollateralAccount {
		mapping (address => uint) allowance;
		uint256 balance;
		uint256 lastUpdateTime;
	}

	struct MarketData {
		uint256 balance;
		uint256 interest;
		uint256 currentIndex; 
	}

	address constant private ethAddress = 0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE;

	uint256 constant private rateDecimals = 10 ** 4;

	uint256 constant private secondsPerYear = 31536000;

	uint256 constant private oneUnit = 1;

	uint256 constant private fivePercentLiquidationGap = 500;

	HoldefiSettingsInterface public holdefiSettings;

	HoldefiPricesInterface public holdefiPrices;

	HoldefiCollaterals public holdefiCollaterals;

	mapping (address => Market) public marketAssets;

	mapping (address => Collateral) public collateralAssets;

	mapping (address => mapping (address => uint256)) public marketDebt;

	mapping (address => mapping (address => MarketAccount)) private supplies;

	mapping (address => mapping (address => mapping (address => MarketAccount))) private borrows;

	mapping (address => mapping (address => CollateralAccount)) private collaterals;
	

	event Supply(
		address sender,
		address indexed supplier,
		address indexed market,
		uint256 amount,
		uint256 balance,
		uint256 interest,
		uint256 index,
		uint16 referralCode
	);

	event WithdrawSupply(
		address sender,
		address indexed supplier,
		address indexed market,
		uint256 amount,
		uint256 balance,
		uint256 interest,
		uint256 index
	);

	event Collateralize(
		address sender,
		address indexed collateralizer,
		address indexed collateral,
		uint256 amount,
		uint256 balance
	);

	event WithdrawCollateral(
		address sender,
		address indexed collateralizer,
		address indexed collateral,
		uint256 amount,
		uint256 balance
	);

	event Borrow(
		address sender,
		address indexed borrower,
		address indexed market,
		address indexed collateral,
		uint256 amount,
		uint256 balance,
		uint256 interest,
		uint256 index,
		uint16 referralCode
	);

	event RepayBorrow(
		address sender,
		address indexed borrower,
		address indexed market,
		address indexed collateral,
		uint256 amount,
		uint256 balance,
		uint256 interest,
		uint256 index
	);

	event UpdateSupplyIndex(address indexed market, uint256 newSupplyIndex, uint256 supplyRate);

	event UpdateBorrowIndex(address indexed market, uint256 newBorrowIndex, uint256 borrowRate);

	event CollateralLiquidated(
		address indexed borrower,
		address indexed market,
		address indexed collateral,
		uint256 marketDebt,
		uint256 liquidatedCollateral
	);

	event BuyLiquidatedCollateral(
		address indexed market,
		address indexed collateral,
		uint256 marketAmount,
		uint256 collateralAmount
	);

	event HoldefiPricesContractChanged(address newAddress, address oldAddress);

	event LiquidationReserveWithdrawn(address indexed collateral, uint256 amount);

	event LiquidationReserveDeposited(address indexed collateral, uint256 amount);

	event PromotionReserveWithdrawn(address indexed market, uint256 amount, uint256 newPromotionReserve);

	event PromotionReserveDeposited(address indexed market, uint256 amount, uint256 newPromotionReserve);

	event PromotionReserveUpdated(address indexed market, uint256 promotionReserve);

	event PromotionDebtUpdated(address indexed market, uint256 promotionDebt);

	constructor(
		HoldefiSettingsInterface holdefiSettingsAddress,
		HoldefiPricesInterface holdefiPricesAddress
	)
		public
	{
		holdefiSettings = holdefiSettingsAddress;
		holdefiPrices = holdefiPricesAddress;
		holdefiCollaterals = new HoldefiCollaterals();
	}


    modifier isNotETHAddress(address asset) {

        require (asset != ethAddress, "E01");
        _;
    }

    modifier marketIsActive(address market) {

		require (holdefiSettings.marketAssets(market).isActive, "E02");
        _;
    }

    modifier collateralIsActive(address collateral) {

		require (holdefiSettings.collateralAssets(collateral).isActive, "E03");
        _;
    }

    modifier accountIsValid(address account) {

		require (msg.sender != account, "E04");
        _;
    }

    receive() external payable {
        revert();
    }

	function getAccountSupply(address account, address market)
		public
		view
		returns (uint256 balance, uint256 interest, uint256 currentSupplyIndex)
	{

		balance = supplies[account][market].balance;

		(currentSupplyIndex,) = getCurrentSupplyIndex(market);

		uint256 deltaInterestIndex = currentSupplyIndex.sub(supplies[account][market].lastInterestIndex);
		uint256 deltaInterestScaled = deltaInterestIndex.mul(balance);
		uint256 deltaInterest = deltaInterestScaled.div(secondsPerYear).div(rateDecimals);
		
		interest = supplies[account][market].accumulatedInterest.add(deltaInterest);
	}

	function getAccountBorrow(address account, address market, address collateral)
		public
		view
		returns (uint256 balance, uint256 interest, uint256 currentBorrowIndex)
	{

		balance = borrows[account][collateral][market].balance;

		(currentBorrowIndex,) = getCurrentBorrowIndex(market);

		uint256 deltaInterestIndex =
			currentBorrowIndex.sub(borrows[account][collateral][market].lastInterestIndex);

		uint256 deltaInterestScaled = deltaInterestIndex.mul(balance);
		uint256 deltaInterest = deltaInterestScaled.div(secondsPerYear).div(rateDecimals);
		if (balance > 0) {
			deltaInterest = deltaInterest.add(oneUnit);
		}

		interest = borrows[account][collateral][market].accumulatedInterest.add(deltaInterest);
	}


	function getAccountCollateral(address account, address collateral)
		public
		view
		returns (
			uint256 balance,
			uint256 timeSinceLastActivity,
			uint256 borrowPowerValue,
			uint256 totalBorrowValue,
			bool underCollateral
		)
	{

		uint256 valueToLoanRate = holdefiSettings.collateralAssets(collateral).valueToLoanRate;
		if (valueToLoanRate == 0) {
			return (0, 0, 0, 0, false);
		}

		balance = collaterals[account][collateral].balance;

		uint256 collateralValue = holdefiPrices.getAssetValueFromAmount(collateral, balance);
		uint256 liquidationThresholdRate = valueToLoanRate.sub(fivePercentLiquidationGap);

		uint256 totalBorrowPowerValue = collateralValue.mul(rateDecimals).div(valueToLoanRate);
		uint256 liquidationThresholdValue = collateralValue.mul(rateDecimals).div(liquidationThresholdRate);

		totalBorrowValue = getAccountTotalBorrowValue(account, collateral);
		if (totalBorrowValue > 0) {
			timeSinceLastActivity = block.timestamp.sub(collaterals[account][collateral].lastUpdateTime);
		}

		borrowPowerValue = 0;
		if (totalBorrowValue < totalBorrowPowerValue) {
			borrowPowerValue = totalBorrowPowerValue.sub(totalBorrowValue);
		}

		underCollateral = false;	
		if (totalBorrowValue > liquidationThresholdValue) {
			underCollateral = true;
		}
	}

	function getAccountTotalBorrowValue (address account, address collateral)
		public
		view
		returns (uint256 totalBorrowValue)
	{
		MarketData memory borrowData;
		address market;
		uint256 totalDebt;
		uint256 assetValue;
		
		totalBorrowValue = 0;
		address[] memory marketsList = holdefiSettings.getMarketsList();
		for (uint256 i = 0 ; i < marketsList.length ; i++) {
			market = marketsList[i];
			
			(borrowData.balance, borrowData.interest,) = getAccountBorrow(account, market, collateral);
			totalDebt = borrowData.balance.add(borrowData.interest);

			assetValue = holdefiPrices.getAssetValueFromAmount(market, totalDebt);
			totalBorrowValue = totalBorrowValue.add(assetValue);
		}
	}

	function getLiquidationReserve (address collateral) public view returns(uint256 reserve) {
		address market;
		uint256 assetValue;
		uint256 totalDebtValue = 0;

		address[] memory marketsList = holdefiSettings.getMarketsList();
		for (uint256 i = 0 ; i < marketsList.length ; i++) {
			market = marketsList[i];
			assetValue = holdefiPrices.getAssetValueFromAmount(market, marketDebt[collateral][market]);
			totalDebtValue = totalDebtValue.add(assetValue); 
		}

		uint256 bonusRate = holdefiSettings.collateralAssets(collateral).bonusRate;
		uint256 totalDebtCollateralValue = totalDebtValue.mul(bonusRate).div(rateDecimals);
		uint256 liquidatedCollateralNeeded = holdefiPrices.getAssetAmountFromValue(
			collateral,
			totalDebtCollateralValue
		);
		
		reserve = 0;
		uint256 totalLiquidatedCollateral = collateralAssets[collateral].totalLiquidatedCollateral;
		if (totalLiquidatedCollateral > liquidatedCollateralNeeded) {
			reserve = totalLiquidatedCollateral.sub(liquidatedCollateralNeeded);
		}
	}

	function getDiscountedCollateralAmount (address market, address collateral, uint256 marketAmount)
		public
		view
		returns (uint256 collateralAmountWithDiscount)
	{
		uint256 marketValue = holdefiPrices.getAssetValueFromAmount(market, marketAmount);
		uint256 bonusRate = holdefiSettings.collateralAssets(collateral).bonusRate;
		uint256 collateralValue = marketValue.mul(bonusRate).div(rateDecimals);

		collateralAmountWithDiscount = holdefiPrices.getAssetAmountFromValue(collateral, collateralValue);
	}

	function getCurrentSupplyIndex (address market)
		public
		view
		returns (
			uint256 supplyIndex,
			uint256 supplyRate
		)
	{
		(, uint256 supplyRateBase, uint256 promotionRate) = holdefiSettings.getInterests(market);
		uint256 deltaTimeSupply = block.timestamp.sub(marketAssets[market].supplyIndexUpdateTime);

		supplyRate = supplyRateBase.add(promotionRate);
		uint256 deltaTimeInterest = deltaTimeSupply.mul(supplyRate);
		supplyIndex = marketAssets[market].supplyIndex.add(deltaTimeInterest);
	}

	function getCurrentBorrowIndex (address market)
		public
		view
		returns (
			uint256 borrowIndex,
			uint256 borrowRate
		)
	{
		borrowRate = holdefiSettings.marketAssets(market).borrowRate;
		uint256 deltaTimeBorrow = block.timestamp.sub(marketAssets[market].borrowIndexUpdateTime);

		uint256 deltaTimeInterest = deltaTimeBorrow.mul(borrowRate);
		borrowIndex = marketAssets[market].borrowIndex.add(deltaTimeInterest);
	}

	function getPromotionReserve (address market)
		public
		view
		returns (uint256 promotionReserveScaled)
	{
		(uint256 borrowRate, uint256 supplyRateBase,) = holdefiSettings.getInterests(market);
	
		uint256 allSupplyInterest = marketAssets[market].totalSupply.mul(supplyRateBase);
		uint256 allBorrowInterest = marketAssets[market].totalBorrow.mul(borrowRate);

		uint256 deltaTime = block.timestamp.sub(marketAssets[market].promotionReserveLastUpdateTime);
		uint256 currentInterest = allBorrowInterest.sub(allSupplyInterest);
		uint256 deltaTimeInterest = currentInterest.mul(deltaTime);
		promotionReserveScaled = marketAssets[market].promotionReserveScaled.add(deltaTimeInterest);
	}

	function getPromotionDebt (address market)
		public
		view
		returns (uint256 promotionDebtScaled)
	{
		uint256 promotionRate = holdefiSettings.marketAssets(market).promotionRate;
		promotionDebtScaled = marketAssets[market].promotionDebtScaled;

		if (promotionRate != 0) {
			uint256 deltaTime = block.timestamp.sub(marketAssets[market].promotionDebtLastUpdateTime);
			uint256 currentInterest = marketAssets[market].totalSupply.mul(promotionRate);
			uint256 deltaTimeInterest = currentInterest.mul(deltaTime);
			promotionDebtScaled = promotionDebtScaled.add(deltaTimeInterest);
		}
	}

	function beforeChangeSupplyRate (address market) public {
		updateSupplyIndex(market);
		
		uint256 reserveScaled = getPromotionReserve(market);
		uint256 debtScaled = getPromotionDebt(market);

    	if (marketAssets[market].promotionDebtScaled != debtScaled) {
    		if (debtScaled >= reserveScaled) {
	      		holdefiSettings.resetPromotionRate(market);
	      	}

	      	marketAssets[market].promotionDebtScaled = debtScaled;
	      	marketAssets[market].promotionDebtLastUpdateTime = block.timestamp;
	      	emit PromotionDebtUpdated(market, debtScaled);
    	}

		marketAssets[market].promotionReserveScaled = reserveScaled;
    	marketAssets[market].promotionReserveLastUpdateTime = block.timestamp;
		emit PromotionReserveUpdated(market, reserveScaled);
	}

	function beforeChangeBorrowRate (address market) external {
		updateBorrowIndex(market);
		beforeChangeSupplyRate(market);
	}

	function getAccountWithdrawSupplyAllowance (address account, address spender, address market)
		external 
		view
		returns (uint256 res)
	{
		res = supplies[account][market].allowance[spender];
	}

	function getAccountWithdrawCollateralAllowance (
		address account, 
		address spender, 
		address collateral
	)
		external 
		view
		returns (uint256 res)
	{
		res = collaterals[account][collateral].allowance[spender];
	}

	function getAccountBorrowAllowance (
		address account, 
		address spender, 
		address market, 
		address collateral
	)
		external 
		view
		returns (uint256 res)
	{
		res = borrows[account][collateral][market].allowance[spender];
	}

	function supply(address market, uint256 amount, uint16 referralCode)
		external
		isNotETHAddress(market)
	{

		supplyInternal(msg.sender, market, amount, referralCode);
	}

	function supply(uint16 referralCode) external payable {		

		supplyInternal(msg.sender, ethAddress, msg.value, referralCode);
	}

	function supplyBehalf(address account, address market, uint256 amount, uint16 referralCode)
		external
		isNotETHAddress(market)
	{

		supplyInternal(account, market, amount, referralCode);
	}

	function supplyBehalf(address account, uint16 referralCode) 
		external
		payable
	{

		supplyInternal(account, ethAddress, msg.value, referralCode);
	}

	function approveWithdrawSupply(address account, address market, uint256 amount)
		external
		accountIsValid(account)
		marketIsActive(market)
	{

		supplies[msg.sender][market].allowance[account] = amount;
	}

	function withdrawSupply(address market, uint256 amount)
		external
	{

		withdrawSupplyInternal(msg.sender, market, amount);
	}

	function withdrawSupplyBehalf(address account, address market, uint256 amount) external {

		supplies[account][market].allowance[msg.sender] = supplies[account][market].allowance[msg.sender].sub(amount, 'E14');
		withdrawSupplyInternal(account, market, amount);
	}

	function collateralize (address collateral, uint256 amount)
		external
		isNotETHAddress(collateral)
	{
		collateralizeInternal(msg.sender, collateral, amount);
	}

	function collateralize () external payable {
		collateralizeInternal(msg.sender, ethAddress, msg.value);
	}

	function collateralizeBehalf (address account, address collateral, uint256 amount)
		external
		isNotETHAddress(collateral)
	{
		collateralizeInternal(account, collateral, amount);
	}

	function collateralizeBehalf (address account) external payable {
		collateralizeInternal(account, ethAddress, msg.value);
	}

	function approveWithdrawCollateral (address account, address collateral, uint256 amount)
		external
		accountIsValid(account)
		collateralIsActive(collateral)
	{
		collaterals[msg.sender][collateral].allowance[account] = amount;
	}

	function withdrawCollateral (address collateral, uint256 amount)
		external
	{
		withdrawCollateralInternal(msg.sender, collateral, amount);
	}

	function withdrawCollateralBehalf (address account, address collateral, uint256 amount)
		external
	{
		collaterals[account][collateral].allowance[msg.sender] = 
			collaterals[account][collateral].allowance[msg.sender].sub(amount, 'E14');
		withdrawCollateralInternal(account, collateral, amount);
	}

	function approveBorrow (address account, address market, address collateral, uint256 amount)
		external
		accountIsValid(account)
		marketIsActive(market)
	{
		borrows[msg.sender][collateral][market].allowance[account] = amount;
	}

	function borrow (address market, address collateral, uint256 amount, uint16 referralCode)
		external
	{
		borrowInternal(msg.sender, market, collateral, amount, referralCode);
	}

	function borrowBehalf (address account, address market, address collateral, uint256 amount, uint16 referralCode)
		external
	{
		borrows[account][collateral][market].allowance[msg.sender] = 
			borrows[account][collateral][market].allowance[msg.sender].sub(amount, 'E14');
		borrowInternal(account, market, collateral, amount, referralCode);
	}

	function repayBorrow (address market, address collateral, uint256 amount)
		external
		isNotETHAddress(market)
	{
		repayBorrowInternal(msg.sender, market, collateral, amount);
	}

	function repayBorrow (address collateral) external payable {		
		repayBorrowInternal(msg.sender, ethAddress, collateral, msg.value);
	}

	function repayBorrowBehalf (address account, address market, address collateral, uint256 amount)
		external
		isNotETHAddress(market)
	{
		repayBorrowInternal(account, market, collateral, amount);
	}

	function repayBorrowBehalf (address account, address collateral)
		external
		payable
	{		
		repayBorrowInternal(account, ethAddress, collateral, msg.value);
	}

	function liquidateBorrowerCollateral (address borrower, address market, address collateral)
		external
		whenNotPaused("liquidateBorrowerCollateral")
	{
		MarketData memory borrowData;
		(borrowData.balance, borrowData.interest,) = getAccountBorrow(borrower, market, collateral);
		require(borrowData.balance > 0, "E05");

		(uint256 collateralBalance, uint256 timeSinceLastActivity,,, bool underCollateral) = 
			getAccountCollateral(borrower, collateral);
		require (underCollateral || (timeSinceLastActivity > secondsPerYear),
			"E06"
		);

		uint256 totalBorrowedBalance = borrowData.balance.add(borrowData.interest);
		uint256 totalBorrowedBalanceValue = holdefiPrices.getAssetValueFromAmount(market, totalBorrowedBalance);
		
		uint256 liquidatedCollateralValue = totalBorrowedBalanceValue
			.mul(holdefiSettings.collateralAssets(collateral).penaltyRate)
			.div(rateDecimals);

		uint256 liquidatedCollateral =
			holdefiPrices.getAssetAmountFromValue(collateral, liquidatedCollateralValue);

		if (liquidatedCollateral > collateralBalance) {
			liquidatedCollateral = collateralBalance;
		}

		collaterals[borrower][collateral].balance = collateralBalance.sub(liquidatedCollateral);
		collateralAssets[collateral].totalCollateral =
			collateralAssets[collateral].totalCollateral.sub(liquidatedCollateral);
		collateralAssets[collateral].totalLiquidatedCollateral =
			collateralAssets[collateral].totalLiquidatedCollateral.add(liquidatedCollateral);

		delete borrows[borrower][collateral][market];
		beforeChangeSupplyRate(market);
		marketAssets[market].totalBorrow = marketAssets[market].totalBorrow.sub(borrowData.balance);
		marketDebt[collateral][market] = marketDebt[collateral][market].add(totalBorrowedBalance);

		emit CollateralLiquidated(borrower, market, collateral, totalBorrowedBalance, liquidatedCollateral);	
	}

	function buyLiquidatedCollateral (address market, address collateral, uint256 marketAmount)
		external
		isNotETHAddress(market)
	{
		buyLiquidatedCollateralInternal(market, collateral, marketAmount);
	}

	function buyLiquidatedCollateral (address collateral) external payable {
		buyLiquidatedCollateralInternal(ethAddress, collateral, msg.value);
	}

	function depositLiquidationReserve(address collateral, uint256 amount)
		external
		isNotETHAddress(collateral)
	{

		depositLiquidationReserveInternal(collateral, amount);
	}

	function depositLiquidationReserve() external payable {

		depositLiquidationReserveInternal(ethAddress, msg.value);
	}

	function withdrawLiquidationReserve (address collateral, uint256 amount) external onlyOwner {
		uint256 maxWithdraw = getLiquidationReserve(collateral);
		uint256 transferAmount = amount;
		
		if (transferAmount > maxWithdraw){
			transferAmount = maxWithdraw;
		}

		collateralAssets[collateral].totalLiquidatedCollateral =
			collateralAssets[collateral].totalLiquidatedCollateral.sub(transferAmount);
		holdefiCollaterals.withdraw(collateral, msg.sender, transferAmount);

		emit LiquidationReserveWithdrawn(collateral, transferAmount);
	}

	function depositPromotionReserve (address market, uint256 amount)
		external
		isNotETHAddress(market)
	{
		depositPromotionReserveInternal(market, amount);
	}

	function depositPromotionReserve () external payable {
		depositPromotionReserveInternal(ethAddress, msg.value);
	}

	function withdrawPromotionReserve (address market, uint256 amount) external onlyOwner {
	    uint256 reserveScaled = getPromotionReserve(market);
	    uint256 debtScaled = getPromotionDebt(market);

	    uint256 amountScaled = amount.mul(secondsPerYear).mul(rateDecimals);
	    require (reserveScaled > amountScaled.add(debtScaled), "E07");

	    marketAssets[market].promotionReserveScaled = reserveScaled.sub(amountScaled);
	    marketAssets[market].promotionReserveLastUpdateTime = block.timestamp;

	    transferFromHoldefi(msg.sender, market, amount);

	    emit PromotionReserveWithdrawn(market, amount, marketAssets[market].promotionReserveScaled);
	 }


	function setHoldefiPricesContract (HoldefiPricesInterface newHoldefiPrices) external onlyOwner {
		emit HoldefiPricesContractChanged(address(newHoldefiPrices), address(holdefiPrices));
		holdefiPrices = newHoldefiPrices;
	}

	function reserveSettlement (address market) external {
		require(msg.sender == address(holdefiSettings), "E15");

		updateSupplyIndex(market);
		uint256 reserveScaled = getPromotionReserve(market);
		uint256 debtScaled = getPromotionDebt(market);

		marketAssets[market].promotionReserveScaled = reserveScaled.sub(debtScaled, "E13");
		marketAssets[market].promotionDebtScaled = 0;

		marketAssets[market].promotionReserveLastUpdateTime = block.timestamp;
		marketAssets[market].promotionDebtLastUpdateTime = block.timestamp;

		emit PromotionReserveUpdated(market, marketAssets[market].promotionReserveScaled);
		emit PromotionDebtUpdated(market, 0);
	}

	function updateSupplyIndex (address market) internal {
		(uint256 currentSupplyIndex, uint256 supplyRate) = getCurrentSupplyIndex(market);

		marketAssets[market].supplyIndex = currentSupplyIndex;
		marketAssets[market].supplyIndexUpdateTime = block.timestamp;

		emit UpdateSupplyIndex(market, currentSupplyIndex, supplyRate);
	}

	function updateBorrowIndex (address market) internal {
		(uint256 currentBorrowIndex, uint256 borrowRate) = getCurrentBorrowIndex(market);

		marketAssets[market].borrowIndex = currentBorrowIndex;
		marketAssets[market].borrowIndexUpdateTime = block.timestamp;

		emit UpdateBorrowIndex(market, currentBorrowIndex, borrowRate);
	}

	function transferFromHoldefi(address receiver, address asset, uint256 amount) internal {

		if (asset == ethAddress){
			(bool success, ) = receiver.call{value:amount}("");
			require (success, "E08");
		}
		else {
			IERC20 token = IERC20(asset);
			token.safeTransfer(receiver, amount);
		}
	}

	function transferFromSender(address receiver, address asset, uint256 amount) internal returns(uint256 transferAmount) {

		transferAmount = amount;
		if (asset != ethAddress) {
			IERC20 token = IERC20(asset);
			uint256 oldBalance = token.balanceOf(receiver);
			token.safeTransferFrom(msg.sender, receiver, amount);
			transferAmount = token.balanceOf(receiver).sub(oldBalance);
		}
	}

	function supplyInternal(address account, address market, uint256 amount, uint16 referralCode)
		internal
		nonReentrant
		whenNotPaused("supply")
		marketIsActive(market)
	{

		uint256 transferAmount = transferFromSender(address(this), market, amount);

		MarketData memory supplyData;
		(supplyData.balance, supplyData.interest, supplyData.currentIndex) = getAccountSupply(account, market);
		
		supplyData.balance = supplyData.balance.add(transferAmount);
		supplies[account][market].balance = supplyData.balance;
		supplies[account][market].accumulatedInterest = supplyData.interest;
		supplies[account][market].lastInterestIndex = supplyData.currentIndex;

		beforeChangeSupplyRate(market);
		marketAssets[market].totalSupply = marketAssets[market].totalSupply.add(transferAmount);

		emit Supply(
			msg.sender,
			account,
			market,
			transferAmount,
			supplyData.balance,
			supplyData.interest,
			supplyData.currentIndex,
			referralCode
		);
	}

	function withdrawSupplyInternal (address account, address market, uint256 amount) 
		internal
		nonReentrant
		whenNotPaused("withdrawSupply")
	{
		MarketData memory supplyData;
		(supplyData.balance, supplyData.interest, supplyData.currentIndex) = getAccountSupply(account, market);
		uint256 totalSuppliedBalance = supplyData.balance.add(supplyData.interest);
		require (totalSuppliedBalance != 0, "E09");

		uint256 transferAmount = amount;
		if (transferAmount > totalSuppliedBalance){
			transferAmount = totalSuppliedBalance;
		}

		if (transferAmount <= supplyData.interest) {
			supplyData.interest = supplyData.interest.sub(transferAmount);
		}
		else {
			uint256 remaining = transferAmount.sub(supplyData.interest);
			supplyData.interest = 0;
			supplyData.balance = supplyData.balance.sub(remaining);

			beforeChangeSupplyRate(market);
			marketAssets[market].totalSupply = marketAssets[market].totalSupply.sub(remaining);	
		}

		supplies[account][market].balance = supplyData.balance;
		supplies[account][market].accumulatedInterest = supplyData.interest;
		supplies[account][market].lastInterestIndex = supplyData.currentIndex;

		transferFromHoldefi(msg.sender, market, transferAmount);
	
		emit WithdrawSupply(
			msg.sender,
			account,
			market,
			transferAmount,
			supplyData.balance,
			supplyData.interest,
			supplyData.currentIndex
		);
	}

	function collateralizeInternal (address account, address collateral, uint256 amount)
		internal
		nonReentrant
		whenNotPaused("collateralize")
		collateralIsActive(collateral)
	{
		uint256 transferAmount = transferFromSender(address(holdefiCollaterals), collateral, amount);
		if (collateral == ethAddress) {
			transferFromHoldefi(address(holdefiCollaterals), collateral, amount);
		}

		uint256 balance = collaterals[account][collateral].balance.add(transferAmount);
		collaterals[account][collateral].balance = balance;
		collaterals[account][collateral].lastUpdateTime = block.timestamp;

		collateralAssets[collateral].totalCollateral = collateralAssets[collateral].totalCollateral.add(transferAmount);	
		
		emit Collateralize(msg.sender, account, collateral, transferAmount, balance);
	}

	function withdrawCollateralInternal (address account, address collateral, uint256 amount) 
		internal
		nonReentrant
		whenNotPaused("withdrawCollateral")
	{
		(uint256 balance,, uint256 borrowPowerValue, uint256 totalBorrowValue,) =
			getAccountCollateral(account, collateral);

		require (borrowPowerValue != 0, "E10");

		uint256 collateralNedeed = 0;
		if (totalBorrowValue != 0) {
			uint256 valueToLoanRate = holdefiSettings.collateralAssets(collateral).valueToLoanRate;
			uint256 totalCollateralValue = totalBorrowValue.mul(valueToLoanRate).div(rateDecimals);
			collateralNedeed = holdefiPrices.getAssetAmountFromValue(collateral, totalCollateralValue);
		}

		uint256 maxWithdraw = balance.sub(collateralNedeed);
		uint256 transferAmount = amount;
		if (transferAmount > maxWithdraw){
			transferAmount = maxWithdraw;
		}
		balance = balance.sub(transferAmount);
		collaterals[account][collateral].balance = balance;
		collaterals[account][collateral].lastUpdateTime = block.timestamp;

		collateralAssets[collateral].totalCollateral =
			collateralAssets[collateral].totalCollateral.sub(transferAmount);

		holdefiCollaterals.withdraw(collateral, msg.sender, transferAmount);

		emit WithdrawCollateral(msg.sender, account, collateral, transferAmount, balance);
	}

	function borrowInternal (address account, address market, address collateral, uint256 amount, uint16 referralCode)
		internal
		nonReentrant
		whenNotPaused("borrow")
		marketIsActive(market)
		collateralIsActive(collateral)
	{
		require (amount <= (marketAssets[market].totalSupply.sub(marketAssets[market].totalBorrow)), "E11");

		(,, uint256 borrowPowerValue,,) = getAccountCollateral(account, collateral);
		uint256 assetToBorrowValue = holdefiPrices.getAssetValueFromAmount(market, amount);
		require (borrowPowerValue >= assetToBorrowValue, "E12");

		MarketData memory borrowData;
		(borrowData.balance, borrowData.interest, borrowData.currentIndex) = getAccountBorrow(account, market, collateral);
		
		borrowData.balance = borrowData.balance.add(amount);
		borrows[account][collateral][market].balance = borrowData.balance;
		borrows[account][collateral][market].accumulatedInterest = borrowData.interest;
		borrows[account][collateral][market].lastInterestIndex = borrowData.currentIndex;
		collaterals[account][collateral].lastUpdateTime = block.timestamp;

		beforeChangeSupplyRate(market);
		marketAssets[market].totalBorrow = marketAssets[market].totalBorrow.add(amount);

		transferFromHoldefi(msg.sender, market, amount);

		emit Borrow(
			msg.sender, 
			account,
			market,
			collateral,
			amount,
			borrowData.balance,
			borrowData.interest,
			borrowData.currentIndex,
			referralCode
		);
	}

	function repayBorrowInternal (address account, address market, address collateral, uint256 amount)
		internal
		nonReentrant
		whenNotPaused("repayBorrow")
	{
		MarketData memory borrowData;
		(borrowData.balance, borrowData.interest, borrowData.currentIndex) =
			getAccountBorrow(account, market, collateral);

		uint256 totalBorrowedBalance = borrowData.balance.add(borrowData.interest);
		require (totalBorrowedBalance != 0, "E09");

		uint256 transferAmount = transferFromSender(address(this), market, amount);
		uint256 extra = 0;
		if (transferAmount > totalBorrowedBalance) {
			extra = transferAmount.sub(totalBorrowedBalance);
			transferAmount = totalBorrowedBalance;
		}

		if (transferAmount <= borrowData.interest) {
			borrowData.interest = borrowData.interest.sub(transferAmount);
		}
		else {
			uint256 remaining = transferAmount.sub(borrowData.interest);
			borrowData.interest = 0;
			borrowData.balance = borrowData.balance.sub(remaining);

			beforeChangeSupplyRate(market);
			marketAssets[market].totalBorrow = marketAssets[market].totalBorrow.sub(remaining);	
		}
		borrows[account][collateral][market].balance = borrowData.balance;
		borrows[account][collateral][market].accumulatedInterest = borrowData.interest;
		borrows[account][collateral][market].lastInterestIndex = borrowData.currentIndex;
		collaterals[account][collateral].lastUpdateTime = block.timestamp;

		if (extra > 0) {
			transferFromHoldefi(msg.sender, market, extra);
		}
		
		emit RepayBorrow (
			msg.sender,
			account,
			market,
			collateral,
			transferAmount,
			borrowData.balance,
			borrowData.interest,
			borrowData.currentIndex
		);
	}

	function buyLiquidatedCollateralInternal (address market, address collateral, uint256 marketAmount)
		internal
		nonReentrant
		whenNotPaused("buyLiquidatedCollateral")
	{
		uint256 transferAmount = transferFromSender(address(this), market, marketAmount);
		marketDebt[collateral][market] = marketDebt[collateral][market].sub(transferAmount, 'E17');

		uint256 collateralAmountWithDiscount =
			getDiscountedCollateralAmount(market, collateral, transferAmount);		
		collateralAssets[collateral].totalLiquidatedCollateral = 
			collateralAssets[collateral].totalLiquidatedCollateral.sub(collateralAmountWithDiscount, 'E16');
		
		holdefiCollaterals.withdraw(collateral, msg.sender, collateralAmountWithDiscount);

		emit BuyLiquidatedCollateral(market, collateral, transferAmount, collateralAmountWithDiscount);
	}

	function depositPromotionReserveInternal (address market, uint256 amount)
		internal
		nonReentrant
		whenNotPaused("depositPromotionReserve")
		marketIsActive(market)
	{
		uint256 transferAmount = transferFromSender(address(this), market, amount);

		uint256 amountScaled = transferAmount.mul(secondsPerYear).mul(rateDecimals);

		marketAssets[market].promotionReserveScaled = 
			marketAssets[market].promotionReserveScaled.add(amountScaled);

		emit PromotionReserveDeposited(market, transferAmount, marketAssets[market].promotionReserveScaled);
	}

	function depositLiquidationReserveInternal (address collateral, uint256 amount)
		internal
		nonReentrant
		whenNotPaused("depositLiquidationReserve")
		collateralIsActive(collateral)
	{
		uint256 transferAmount = transferFromSender(address(holdefiCollaterals), collateral, amount);
		if (collateral == ethAddress) {
			transferFromHoldefi(address(holdefiCollaterals), collateral, amount);
		}

		collateralAssets[collateral].totalLiquidatedCollateral =
			collateralAssets[collateral].totalLiquidatedCollateral.add(transferAmount);
		
		emit LiquidationReserveDeposited(collateral, transferAmount);
	}
}