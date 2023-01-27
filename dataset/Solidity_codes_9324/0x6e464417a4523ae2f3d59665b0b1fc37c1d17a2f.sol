
pragma solidity 0.6.12;

interface marketManagerInterface  {

	function setBreakerTable(address _target, bool _status) external returns (bool);


	function getCircuitBreaker() external view returns (bool);

	function setCircuitBreaker(bool _emergency) external returns (bool);


	function getTokenHandlerInfo(uint256 handlerID) external view returns (bool, address, string memory);


	function handlerRegister(uint256 handlerID, address tokenHandlerAddr) external returns (bool);


	function applyInterestHandlers(address payable userAddr, uint256 callerID, bool allFlag) external returns (uint256, uint256, uint256, uint256, uint256, uint256);


	function getTokenHandlerPrice(uint256 handlerID) external view returns (uint256);

	function getTokenHandlerBorrowLimit(uint256 handlerID) external view returns (uint256);

	function getTokenHandlerSupport(uint256 handlerID) external view returns (bool);


	function getTokenHandlersLength() external view returns (uint256);

	function setTokenHandlersLength(uint256 _tokenHandlerLength) external returns (bool);


	function getTokenHandlerID(uint256 index) external view returns (uint256);

	function getTokenHandlerMarginCallLimit(uint256 handlerID) external view returns (uint256);


	function getUserIntraHandlerAssetWithInterest(address payable userAddr, uint256 handlerID) external view returns (uint256, uint256);


	function getUserTotalIntraCreditAsset(address payable userAddr) external view returns (uint256, uint256);


	function getUserLimitIntraAsset(address payable userAddr) external view returns (uint256, uint256);


	function getUserCollateralizableAmount(address payable userAddr, uint256 handlerID) external view returns (uint256);


	function getUserExtraLiquidityAmount(address payable userAddr, uint256 handlerID) external view returns (uint256);

	function partialLiquidationUser(address payable delinquentBorrower, uint256 liquidateAmount, address payable liquidator, uint256 liquidateHandlerID, uint256 rewardHandlerID) external returns (uint256, uint256, uint256);


	function getMaxLiquidationReward(address payable delinquentBorrower, uint256 liquidateHandlerID, uint256 liquidateAmount, uint256 rewardHandlerID, uint256 rewardRatio) external view returns (uint256);

	function partialLiquidationUserReward(address payable delinquentBorrower, uint256 rewardAmount, address payable liquidator, uint256 handlerID) external returns (uint256);


	function setLiquidationManager(address liquidationManagerAddr) external returns (bool);


	function rewardClaimAll(address payable userAddr) external returns (bool);


	function updateRewardParams(address payable userAddr) external returns (bool);

	function interestUpdateReward() external returns (bool);

	function getGlobalRewardInfo() external view returns (uint256, uint256, uint256);


	function setOracleProxy(address oracleProxyAddr) external returns (bool);


	function rewardUpdateOfInAction(address payable userAddr, uint256 callerID) external returns (bool);

	function ownerRewardTransfer(uint256 _amount) external returns (bool);

}

pragma solidity 0.6.12;

interface managerDataStorageInterface  {

	function getGlobalRewardPerBlock() external view returns (uint256);

	function setGlobalRewardPerBlock(uint256 _globalRewardPerBlock) external returns (bool);


	function getGlobalRewardDecrement() external view returns (uint256);

	function setGlobalRewardDecrement(uint256 _globalRewardDecrement) external returns (bool);


	function getGlobalRewardTotalAmount() external view returns (uint256);

	function setGlobalRewardTotalAmount(uint256 _globalRewardTotalAmount) external returns (bool);


	function getAlphaRate() external view returns (uint256);

	function setAlphaRate(uint256 _alphaRate) external returns (bool);


	function getAlphaLastUpdated() external view returns (uint256);

	function setAlphaLastUpdated(uint256 _alphaLastUpdated) external returns (bool);


	function getRewardParamUpdateRewardPerBlock() external view returns (uint256);

	function setRewardParamUpdateRewardPerBlock(uint256 _rewardParamUpdateRewardPerBlock) external returns (bool);


	function getRewardParamUpdated() external view returns (uint256);

	function setRewardParamUpdated(uint256 _rewardParamUpdated) external returns (bool);


	function getInterestUpdateRewardPerblock() external view returns (uint256);

	function setInterestUpdateRewardPerblock(uint256 _interestUpdateRewardPerblock) external returns (bool);


	function getInterestRewardUpdated() external view returns (uint256);

	function setInterestRewardUpdated(uint256 _interestRewardLastUpdated) external returns (bool);


	function setTokenHandler(uint256 handlerID, address handlerAddr) external returns (bool);


	function getTokenHandlerInfo(uint256 handlerID) external view returns (bool, address);


	function getTokenHandlerID(uint256 index) external view returns (uint256);


	function getTokenHandlerAddr(uint256 handlerID) external view returns (address);

	function setTokenHandlerAddr(uint256 handlerID, address handlerAddr) external returns (bool);


	function getTokenHandlerExist(uint256 handlerID) external view returns (bool);

	function setTokenHandlerExist(uint256 handlerID, bool exist) external returns (bool);


	function getTokenHandlerSupport(uint256 handlerID) external view returns (bool);

	function setTokenHandlerSupport(uint256 handlerID, bool support) external returns (bool);


	function setLiquidationManagerAddr(address _liquidationManagerAddr) external returns (bool);

	function getLiquidationManagerAddr() external view returns (address);


	function setManagerAddr(address _managerAddr) external returns (bool);

}


pragma solidity 0.6.12;

interface marketHandlerInterface  {

	function setCircuitBreaker(bool _emergency) external returns (bool);

	function setCircuitBreakWithOwner(bool _emergency) external returns (bool);


	function getTokenName() external view returns (string memory);


	function ownershipTransfer(address payable newOwner) external returns (bool);


	function deposit(uint256 unifiedTokenAmount, bool allFlag) external payable returns (bool);

	function withdraw(uint256 unifiedTokenAmount, bool allFlag) external returns (bool);

	function borrow(uint256 unifiedTokenAmount, bool allFlag) external returns (bool);

	function repay(uint256 unifiedTokenAmount, bool allFlag) external payable returns (bool);


	function partialLiquidationUser(address payable delinquentBorrower, uint256 liquidateAmount, address payable liquidator, uint256 rewardHandlerID) external returns (uint256, uint256, uint256);

	function partialLiquidationUserReward(address payable delinquentBorrower, uint256 liquidationAmountWithReward, address payable liquidator) external returns (uint256);


	function getTokenHandlerLimit() external view returns (uint256, uint256);

    function getTokenHandlerBorrowLimit() external view returns (uint256);

	function getTokenHandlerMarginCallLimit() external view returns (uint256);

	function setTokenHandlerBorrowLimit(uint256 borrowLimit) external returns (bool);

	function setTokenHandlerMarginCallLimit(uint256 marginCallLimit) external returns (bool);


	function getUserAmountWithInterest(address payable userAddr) external view returns (uint256, uint256);

	function getUserAmount(address payable userAddr) external view returns (uint256, uint256);


	function getUserMaxBorrowAmount(address payable userAddr) external view returns (uint256);

	function getUserMaxWithdrawAmount(address payable userAddr) external view returns (uint256);

	function getUserMaxRepayAmount(address payable userAddr) external view returns (uint256);


	function checkFirstAction() external returns (bool);

	function applyInterest(address payable userAddr) external returns (uint256, uint256);


	function reserveDeposit(uint256 unifiedTokenAmount) external payable returns (bool);

	function reserveWithdraw(uint256 unifiedTokenAmount) external returns (bool);


	function getDepositTotalAmount() external view returns (uint256);

	function getBorrowTotalAmount() external view returns (uint256);


	function getSIRandBIR() external view returns (uint256, uint256);

}


pragma solidity 0.6.12;

interface oracleProxyInterface  {

	function getTokenPrice(uint256 tokenID) external view returns (uint256);


	function getOracleFeed(uint256 tokenID) external view returns (address, uint256);

	function setOracleFeed(uint256 tokenID, address feedAddr, uint256 decimals) external returns (bool);

}


pragma solidity 0.6.12;

interface liquidationManagerInterface  {

	function setCircuitBreaker(bool _emergency) external returns (bool);

	function partialLiquidation(address payable delinquentBorrower, uint256 targetHandler, uint256 liquidateAmount, uint256 receiveHandler) external returns (uint256);

	function checkLiquidation(address payable userAddr) external view returns (bool);

}


pragma solidity 0.6.12;

interface proxyContractInterface  {

	function handlerProxy(bytes memory data) external returns (bool, bytes memory);

	function handlerViewProxy(bytes memory data) external view returns (bool, bytes memory);

	function siProxy(bytes memory data) external returns (bool, bytes memory);

	function siViewProxy(bytes memory data) external view returns (bool, bytes memory);

}


pragma solidity 0.6.12;

interface IERC20 {

    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount) external ;

    function allowance(address owner, address spender) external view returns (uint256);

    function approve(address spender, uint256 amount) external view returns (bool);

    function transferFrom(address from, address to, uint256 value) external ;

}


pragma solidity 0.6.12;

contract Modifier {

    string internal constant ONLY_OWNER = "O";
    string internal constant ONLY_MANAGER = "M";
    string internal constant CIRCUIT_BREAKER = "emergency";
}

contract ManagerModifier is Modifier {

    string internal constant ONLY_HANDLER = "H";
    string internal constant ONLY_LIQUIDATION_MANAGER = "LM";
    string internal constant ONLY_BREAKER = "B";
}

contract HandlerDataStorageModifier is Modifier {

    string internal constant ONLY_BIFI_CONTRACT = "BF";
}

contract SIDataStorageModifier is Modifier {

    string internal constant ONLY_SI_HANDLER = "SI";
}

contract HandlerErrors is Modifier {

    string internal constant USE_VAULE = "use value";
    string internal constant USE_ARG = "use arg";
    string internal constant EXCEED_LIMIT = "exceed limit";
    string internal constant NO_LIQUIDATION = "no liquidation";
    string internal constant NO_LIQUIDATION_REWARD = "no enough reward";
    string internal constant NO_EFFECTIVE_BALANCE = "not enough balance";
    string internal constant TRANSFER = "err transfer";
}

contract SIErrors is Modifier { }


contract InterestErrors is Modifier { }


contract LiquidationManagerErrors is Modifier {

    string internal constant NO_DELINQUENT = "not delinquent";
}

contract ManagerErrors is ManagerModifier {

    string internal constant REWARD_TRANSFER = "RT";
    string internal constant UNSUPPORTED_TOKEN = "UT";
}

contract OracleProxyErrors is Modifier {

    string internal constant ZERO_PRICE = "price zero";
}

contract RequestProxyErrors is Modifier { }


contract ManagerDataStorageErrors is ManagerModifier {

    string internal constant NULL_ADDRESS = "err addr null";
}


pragma solidity ^0.6.12;

library SafeMath {

    uint256 internal constant unifiedPoint = 10 ** 18;

	function add(uint256 a, uint256 b) internal pure returns (uint256)
	{

		uint256 c = a + b;
		require(c >= a, "a");
		return c;
	}

	function sub(uint256 a, uint256 b) internal pure returns (uint256)
	{

		return _sub(a, b, "s");
	}

	function mul(uint256 a, uint256 b) internal pure returns (uint256)
	{

		return _mul(a, b);
	}

	function div(uint256 a, uint256 b) internal pure returns (uint256)
	{

		return _div(a, b, "d");
	}

	function _sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256)
	{

		require(b <= a, errorMessage);
		return a - b;
	}

	function _mul(uint256 a, uint256 b) internal pure returns (uint256)
	{

		if (a == 0)
		{
			return 0;
		}

		uint256 c = a* b;
		require((c / a) == b, "m");
		return c;
	}

	function _div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256)
	{

		require(b > 0, errorMessage);
		return a / b;
	}

	function unifiedDiv(uint256 a, uint256 b) internal pure returns (uint256)
	{

		return _div(_mul(a, unifiedPoint), b, "d");
	}

	function unifiedMul(uint256 a, uint256 b) internal pure returns (uint256)
	{

		return _div(_mul(a, b), unifiedPoint, "m");
	}
}


pragma solidity 0.6.12;

contract etherManager is marketManagerInterface, ManagerErrors {

	using SafeMath for uint256;
	address public owner;

	bool public emergency = false;

	managerDataStorageInterface internal dataStorageInstance;

	oracleProxyInterface internal oracleProxy;

	IERC20 internal rewardErc20Instance;

	string internal constant updateRewardLane = "updateRewardLane(address)";

	mapping(address => Breaker) internal breakerTable;

	struct UserAssetsInfo {
		uint256 depositAssetSum;
		uint256 borrowAssetSum;
		uint256 marginCallLimitSum;
		uint256 depositAssetBorrowLimitSum;
		uint256 depositAsset;
		uint256 borrowAsset;
		uint256 price;
		uint256 callerPrice;
		uint256 depositAmount;
		uint256 borrowAmount;
		uint256 borrowLimit;
		uint256 marginCallLimit;
		uint256 callerBorrowLimit;
		uint256 userBorrowableAsset;
		uint256 withdrawableAsset;
	}

	struct Breaker {
		bool auth;
		bool tried;
	}

	struct HandlerInfo {
		bool support;
		address addr;

		proxyContractInterface tokenHandler;
		bytes data;
	}

	uint256 public tokenHandlerLength;

	modifier onlyOwner {

		require(msg.sender == owner, ONLY_OWNER);
		_;
	}

	modifier onlyHandler(uint256 handlerID) {

		_isHandler(handlerID);
		_;
	}

	function _isHandler(uint256 handlerID) internal view {

		address msgSender = msg.sender;
		require((msgSender == dataStorageInstance.getTokenHandlerAddr(handlerID)) || (msgSender == owner), ONLY_HANDLER);
	}

	modifier onlyLiquidationManager {

		_isLiquidationManager();
		_;
	}

	function _isLiquidationManager() internal view {

		address msgSender = msg.sender;
		require((msgSender == dataStorageInstance.getLiquidationManagerAddr()) || (msgSender == owner), ONLY_LIQUIDATION_MANAGER);
	}

	modifier circuitBreaker {

		_isCircuitBreak();
		_;
	}

	function _isCircuitBreak() internal view {

		require((!emergency) || (msg.sender == owner), CIRCUIT_BREAKER);
	}

	modifier onlyBreaker {

		_isBreaker();
		_;
	}

	function _isBreaker() internal view {

		require(breakerTable[msg.sender].auth, ONLY_BREAKER);
	}

	constructor (address managerDataStorageAddr, address oracleProxyAddr, address breaker, address erc20Addr) public
	{
		owner = msg.sender;
		dataStorageInstance = managerDataStorageInterface(managerDataStorageAddr);
		oracleProxy = oracleProxyInterface(oracleProxyAddr);
		rewardErc20Instance = IERC20(erc20Addr);
		breakerTable[owner].auth = true;
		breakerTable[breaker].auth = true;
	}

	function ownershipTransfer(address payable _owner) onlyOwner public returns (bool)
	{

		owner = _owner;
		return true;
	}

	function setOracleProxy(address oracleProxyAddr) onlyOwner external override returns (bool)
	{

		oracleProxy = oracleProxyInterface(oracleProxyAddr);
		return true;
	}

	function setRewardErc20(address erc20Addr) onlyOwner public returns (bool)
	{

		rewardErc20Instance = IERC20(erc20Addr);
		return true;
	}

	function setBreakerTable(address _target, bool _status) onlyOwner external override returns (bool)
	{

		breakerTable[_target].auth = _status;
		return true;
	}

	function setCircuitBreaker(bool _emergency) onlyBreaker external override returns (bool)
	{

		bytes memory data;

		for (uint256 handlerID = 0; handlerID < tokenHandlerLength; handlerID++)
		{
			address tokenHandlerAddr = dataStorageInstance.getTokenHandlerAddr(handlerID);
			proxyContractInterface tokenHandler = proxyContractInterface(tokenHandlerAddr);

			bytes memory callData = abi.encodeWithSignature("setCircuitBreaker(bool)", _emergency);

			tokenHandler.handlerProxy(callData);
			tokenHandler.siProxy(callData);
		}

		address liquidationManagerAddr = dataStorageInstance.getLiquidationManagerAddr();
		liquidationManagerInterface liquidationManager = liquidationManagerInterface(liquidationManagerAddr);
		liquidationManager.setCircuitBreaker(_emergency);
		emergency = _emergency;
		return true;
	}

	function getCircuitBreaker() external view override returns (bool)
	{

		return emergency;
	}

	function getTokenHandlerInfo(uint256 handlerID) external view override returns (bool, address, string memory)
	{

		bool support;
		address tokenHandlerAddr;
		string memory tokenName;
		if (dataStorageInstance.getTokenHandlerSupport(handlerID))
		{
			tokenHandlerAddr = dataStorageInstance.getTokenHandlerAddr(handlerID);
			proxyContractInterface tokenHandler = proxyContractInterface(tokenHandlerAddr);
			bytes memory data;
			(, data) = tokenHandler.handlerViewProxy(abi.encodeWithSignature("getTokenName()"));
			tokenName = abi.decode(data, (string));
			support = true;
		}

		return (support, tokenHandlerAddr, tokenName);
	}

	function handlerRegister(uint256 handlerID, address tokenHandlerAddr) onlyOwner external override returns (bool)
	{

		return _handlerRegister(handlerID, tokenHandlerAddr);
	}

	function setLiquidationManager(address liquidationManagetAddr) onlyOwner external override returns (bool)
	{

		dataStorageInstance.setLiquidationManagerAddr(liquidationManagetAddr);
		return true;
	}

	function rewardUpdateOfInAction(address payable userAddr, uint256 callerID) external override returns (bool)
	{

		HandlerInfo memory handlerInfo;
		(handlerInfo.support, handlerInfo.addr) = dataStorageInstance.getTokenHandlerInfo(callerID);
		if (handlerInfo.support)
		{
			proxyContractInterface tokenHandler;
			tokenHandler = proxyContractInterface(handlerInfo.addr);
			tokenHandler.siProxy(abi.encodeWithSignature(updateRewardLane, userAddr));
		}

		return true;
	}

	function applyInterestHandlers(address payable userAddr, uint256 callerID, bool allFlag) external override returns (uint256, uint256, uint256, uint256, uint256, uint256)
	{

		UserAssetsInfo memory userAssetsInfo;
		HandlerInfo memory handlerInfo;
		oracleProxyInterface _oracleProxy = oracleProxy;
		managerDataStorageInterface _dataStorage = dataStorageInstance;

		for (uint256 handlerID; handlerID < tokenHandlerLength; handlerID++)
		{
			(handlerInfo.support, handlerInfo.addr) = _dataStorage.getTokenHandlerInfo(handlerID);
			if (handlerInfo.support)
			{
				handlerInfo.tokenHandler = proxyContractInterface(handlerInfo.addr);

				if ((handlerID == callerID) || allFlag)
				{
					handlerInfo.tokenHandler.siProxy( abi.encodeWithSignature("updateRewardLane(address)", userAddr) );
					(, handlerInfo.data) = handlerInfo.tokenHandler.handlerProxy( abi.encodeWithSignature("applyInterest(address)", userAddr) );

					(userAssetsInfo.depositAmount, userAssetsInfo.borrowAmount) = abi.decode(handlerInfo.data, (uint256, uint256));
				}
				else
				{
					(, handlerInfo.data) = handlerInfo.tokenHandler.handlerViewProxy( abi.encodeWithSignature("getUserAmount(address)", userAddr) );
					(userAssetsInfo.depositAmount, userAssetsInfo.borrowAmount) = abi.decode(handlerInfo.data, (uint256, uint256));
				}

				(, handlerInfo.data) = handlerInfo.tokenHandler.handlerViewProxy( abi.encodeWithSignature("getTokenHandlerLimit()") );
				(userAssetsInfo.borrowLimit, userAssetsInfo.marginCallLimit) = abi.decode(handlerInfo.data, (uint256, uint256));

				if (handlerID == callerID)
				{
					userAssetsInfo.price = _oracleProxy.getTokenPrice(handlerID);
					userAssetsInfo.callerPrice = userAssetsInfo.price;
					userAssetsInfo.callerBorrowLimit = userAssetsInfo.borrowLimit;
				}

				if ((userAssetsInfo.depositAmount > 0) || (userAssetsInfo.borrowAmount > 0))
				{
					if (handlerID != callerID)
					{
						userAssetsInfo.price = _oracleProxy.getTokenPrice(handlerID);
					}

					if (userAssetsInfo.depositAmount > 0)
					{
						userAssetsInfo.depositAsset = userAssetsInfo.depositAmount.unifiedMul(userAssetsInfo.price);
						userAssetsInfo.depositAssetBorrowLimitSum = userAssetsInfo.depositAssetBorrowLimitSum.add(userAssetsInfo.depositAsset.unifiedMul(userAssetsInfo.borrowLimit));
						userAssetsInfo.marginCallLimitSum = userAssetsInfo.marginCallLimitSum.add(userAssetsInfo.depositAsset.unifiedMul(userAssetsInfo.marginCallLimit));
						userAssetsInfo.depositAssetSum = userAssetsInfo.depositAssetSum.add(userAssetsInfo.depositAsset);
					}

					if (userAssetsInfo.borrowAmount > 0)
					{
						userAssetsInfo.borrowAsset = userAssetsInfo.borrowAmount.unifiedMul(userAssetsInfo.price);
						userAssetsInfo.borrowAssetSum = userAssetsInfo.borrowAssetSum.add(userAssetsInfo.borrowAsset);
					}

				}

			}

		}

		if (userAssetsInfo.depositAssetBorrowLimitSum > userAssetsInfo.borrowAssetSum)
		{
			userAssetsInfo.userBorrowableAsset = userAssetsInfo.depositAssetBorrowLimitSum.sub(userAssetsInfo.borrowAssetSum);

			userAssetsInfo.withdrawableAsset = userAssetsInfo.depositAssetBorrowLimitSum.sub(userAssetsInfo.borrowAssetSum).unifiedDiv(userAssetsInfo.callerBorrowLimit);
		}

		return (userAssetsInfo.userBorrowableAsset.unifiedDiv(userAssetsInfo.callerPrice), userAssetsInfo.withdrawableAsset.unifiedDiv(userAssetsInfo.callerPrice), userAssetsInfo.marginCallLimitSum, userAssetsInfo.depositAssetSum, userAssetsInfo.borrowAssetSum, userAssetsInfo.callerPrice);
	}

	function interestUpdateReward() external override returns (bool)
	{

		uint256 thisBlock = block.number;
		uint256 interestRewardUpdated = dataStorageInstance.getInterestRewardUpdated();
		uint256 delta = thisBlock - interestRewardUpdated;
		if (delta == 0)
		{
			return false;
		}

		dataStorageInstance.setInterestRewardUpdated(thisBlock);
		for (uint256 handlerID; handlerID < tokenHandlerLength; handlerID++)
		{
			proxyContractInterface tokenHandler = proxyContractInterface(dataStorageInstance.getTokenHandlerAddr(handlerID));
			bytes memory data;
			(, data) = tokenHandler.handlerProxy(abi.encodeWithSignature("checkFirstAction()"));
		}

		uint256 globalRewardPerBlock = dataStorageInstance.getInterestUpdateRewardPerblock();
		uint256 rewardAmount = delta.mul(globalRewardPerBlock);

		return _rewardTransfer(msg.sender, rewardAmount);
	}

	function updateRewardParams(address payable userAddr) external override returns (bool)
	{

		if (_determineRewardParams(userAddr))
		{
			return _calcRewardParams(userAddr);
		}

		return false;
	}

	function rewardClaimAll(address payable userAddr) external override returns (bool)
	{

		uint256 handlerID;
		uint256 claimAmountSum;
		bytes memory data;
		for (handlerID; handlerID < tokenHandlerLength; handlerID++)
		{
			proxyContractInterface tokenHandler = proxyContractInterface(dataStorageInstance.getTokenHandlerAddr(handlerID));
			(, data) = tokenHandler.siProxy(abi.encodeWithSignature(updateRewardLane, userAddr));

			(, data) = tokenHandler.siProxy(abi.encodeWithSignature("claimRewardAmountUser(address)", userAddr));
			claimAmountSum = claimAmountSum.add(abi.decode(data, (uint256)));
		}

		return _rewardTransfer(userAddr, claimAmountSum);
	}

	function ownerRewardTransfer(uint256 _amount) onlyOwner external override returns (bool)
	{

		return _rewardTransfer(address(uint160(owner)), _amount);
	}

	function _rewardTransfer(address payable userAddr, uint256 _amount) internal returns (bool)
	{

		uint256 beforeBalance = rewardErc20Instance.balanceOf(userAddr);
		rewardErc20Instance.transfer(userAddr, _amount);
		uint256 afterBalance = rewardErc20Instance.balanceOf(userAddr);
		require(_amount == afterBalance.sub(beforeBalance), REWARD_TRANSFER);
		return true;
	}

	function _determineRewardParams(address payable userAddr) internal returns (bool)
	{

		uint256 thisBlockNum = block.number;
		managerDataStorageInterface _dataStorageInstance = dataStorageInstance;
		uint256 delta = thisBlockNum - _dataStorageInstance.getRewardParamUpdated();
		_dataStorageInstance.setRewardParamUpdated(thisBlockNum);
		if (delta == 0)
		{
			return false;
		}

		uint256 globalRewardPerBlock = _dataStorageInstance.getGlobalRewardPerBlock();
		uint256 globalRewardDecrement = _dataStorageInstance.getGlobalRewardDecrement();
		uint256 globalRewardTotalAmount = _dataStorageInstance.getGlobalRewardTotalAmount();

		uint256 remainingPeriod = globalRewardPerBlock.unifiedDiv(globalRewardDecrement);

		if (remainingPeriod >= delta.mul(SafeMath.unifiedPoint))
		{
			remainingPeriod = remainingPeriod.sub(delta.mul(SafeMath.unifiedPoint));
		}
		else
		{
			return _epilogueOfDetermineRewardParams(_dataStorageInstance, userAddr, delta, 0, globalRewardDecrement, 0);
		}

		if (globalRewardTotalAmount >= globalRewardPerBlock.mul(delta))
		{
			globalRewardTotalAmount = globalRewardTotalAmount - globalRewardPerBlock.mul(delta);
		}
		else
		{
			return _epilogueOfDetermineRewardParams(_dataStorageInstance, userAddr, delta, 0, globalRewardDecrement, 0);
		}

		globalRewardPerBlock = globalRewardTotalAmount.mul(2).unifiedDiv(remainingPeriod.add(SafeMath.unifiedPoint));
		return _epilogueOfDetermineRewardParams(_dataStorageInstance, userAddr, delta, globalRewardPerBlock, globalRewardDecrement, globalRewardTotalAmount);
	}

	function _epilogueOfDetermineRewardParams(
		managerDataStorageInterface _dataStorageInstance,
		address payable userAddr,
		uint256 _delta,
		uint256 _globalRewardPerBlock,
		uint256 _globalRewardDecrement,
		uint256 _globalRewardTotalAmount
	) internal returns (bool) {

		_updateDeterminedRewardModelParam(_globalRewardPerBlock, _globalRewardDecrement, _globalRewardTotalAmount);
		uint256 rewardAmount = _delta.mul(_dataStorageInstance.getRewardParamUpdateRewardPerBlock());
		_rewardTransfer(userAddr, rewardAmount);
		return true;
	}
	function _updateDeterminedRewardModelParam(uint256 _rewardPerBlock, uint256 _dcrement, uint256 _total) internal returns (bool)
	{

		dataStorageInstance.setGlobalRewardPerBlock(_rewardPerBlock);
		dataStorageInstance.setGlobalRewardDecrement(_dcrement);
		dataStorageInstance.setGlobalRewardTotalAmount(_total);
		return true;
	}

	function _calcRewardParams(address payable userAddr) internal returns (bool)
	{

		uint256 handlerLength = tokenHandlerLength;
		bytes memory data;
		uint256[] memory handlerAlphaRateBaseAsset = new uint256[](handlerLength);
		uint256 handlerID;
		uint256 alphaRateBaseGlobalAssetSum;
		for (handlerID; handlerID < handlerLength; handlerID++)
		{
			handlerAlphaRateBaseAsset[handlerID] = _getAlphaBaseAsset(handlerID);
			alphaRateBaseGlobalAssetSum = alphaRateBaseGlobalAssetSum.add(handlerAlphaRateBaseAsset[handlerID]);
		}

		handlerID = 0;
		for (handlerID; handlerID < handlerLength; handlerID++)
		{
			proxyContractInterface tokenHandler = proxyContractInterface(dataStorageInstance.getTokenHandlerAddr(handlerID));
			(, data) = tokenHandler.siProxy(abi.encodeWithSignature(updateRewardLane, userAddr));

			data = abi.encodeWithSignature("updateRewardPerBlockLogic(uint256)",
							dataStorageInstance.getGlobalRewardPerBlock()
							.unifiedMul(
								handlerAlphaRateBaseAsset[handlerID]
								.unifiedDiv(alphaRateBaseGlobalAssetSum)
								)
							);
			(, data) = tokenHandler.siProxy(data);
		}

		return true;
	}

	function _getAlphaBaseAsset(uint256 _handlerID) internal view returns (uint256)
	{

		bytes memory data;
		proxyContractInterface tokenHandler = proxyContractInterface(dataStorageInstance.getTokenHandlerAddr(_handlerID));
		(, data) = tokenHandler.handlerViewProxy(abi.encodeWithSignature("getDepositTotalAmount()"));
		uint256 _depositAmount = abi.decode(data, (uint256));

		(, data) = tokenHandler.handlerViewProxy(abi.encodeWithSignature("getBorrowTotalAmount()"));
		uint256 _borrowAmount = abi.decode(data, (uint256));

		uint256 _alpha = dataStorageInstance.getAlphaRate();
		uint256 _price = _getTokenHandlerPrice(_handlerID);
		return _calcAlphaBaseAmount(_alpha, _depositAmount, _borrowAmount).unifiedMul(_price);
	}

	function _calcAlphaBaseAmount(uint256 _alpha, uint256 _depositAmount, uint256 _borrowAmount) internal pure returns (uint256)
	{

		return _depositAmount.unifiedMul(_alpha).add(_borrowAmount.unifiedMul(SafeMath.unifiedPoint.sub(_alpha)));
	}

	function getTokenHandlerPrice(uint256 handlerID) external view override returns (uint256)
	{

		return _getTokenHandlerPrice(handlerID);
	}

	function getTokenHandlerMarginCallLimit(uint256 handlerID) external view override returns (uint256)
	{

		return _getTokenHandlerMarginCallLimit(handlerID);
	}

	function _getTokenHandlerMarginCallLimit(uint256 handlerID) internal view returns (uint256)
	{

		proxyContractInterface tokenHandler = proxyContractInterface(dataStorageInstance.getTokenHandlerAddr(handlerID));
		bytes memory data;
		(, data) = tokenHandler.handlerViewProxy(abi.encodeWithSignature("getTokenHandlerMarginCallLimit()"));
		return abi.decode(data, (uint256));
	}

	function getTokenHandlerBorrowLimit(uint256 handlerID) external view override returns (uint256)
	{

		return _getTokenHandlerBorrowLimit(handlerID);
	}

	function _getTokenHandlerBorrowLimit(uint256 handlerID) internal view returns (uint256)
	{

		proxyContractInterface tokenHandler = proxyContractInterface(dataStorageInstance.getTokenHandlerAddr(handlerID));

		bytes memory data;
		(, data) = tokenHandler.handlerViewProxy(abi.encodeWithSignature("getTokenHandlerBorrowLimit()"));
		return abi.decode(data, (uint256));
	}

	function getTokenHandlerSupport(uint256 handlerID) external view override returns (bool)
	{

		return dataStorageInstance.getTokenHandlerSupport(handlerID);
	}

	function setTokenHandlersLength(uint256 _tokenHandlerLength) onlyOwner external override returns (bool)
	{

		tokenHandlerLength = _tokenHandlerLength;
		return true;
	}

	function getTokenHandlersLength() external view override returns (uint256)
	{

		return tokenHandlerLength;
	}

	function getTokenHandlerID(uint256 index) external view override returns (uint256)
	{

		return dataStorageInstance.getTokenHandlerID(index);
	}

	function getUserExtraLiquidityAmount(address payable userAddr, uint256 handlerID) external view override returns (uint256)
	{

		uint256 depositCredit;
		uint256 borrowCredit;
		(depositCredit, borrowCredit) = _getUserTotalIntraCreditAsset(userAddr);
		if (depositCredit == 0)
		{
			return 0;
		}

		if (depositCredit > borrowCredit)
		{
			return depositCredit.sub(borrowCredit).unifiedDiv(_getTokenHandlerPrice(handlerID));
		}
		else
		{
			return 0;
		}

	}

	function getUserIntraHandlerAssetWithInterest(address payable userAddr, uint256 handlerID) external view override returns (uint256, uint256)
	{

		return _getUserIntraHandlerAssetWithInterest(userAddr, handlerID);
	}

	function getUserTotalIntraCreditAsset(address payable userAddr) external view override returns (uint256, uint256)
	{

		return _getUserTotalIntraCreditAsset(userAddr);
	}

	function getUserLimitIntraAsset(address payable userAddr) external view override returns (uint256, uint256)
	{

		uint256 userTotalBorrowLimitAsset;
		uint256 userTotalMarginCallLimitAsset;
		(userTotalBorrowLimitAsset, userTotalMarginCallLimitAsset) = _getUserLimitIntraAsset(userAddr);
		return (userTotalBorrowLimitAsset, userTotalMarginCallLimitAsset);
	}


	function getUserCollateralizableAmount(address payable userAddr, uint256 callerID) external view override returns (uint256)
	{

		uint256 userTotalBorrowAsset;
		uint256 depositAssetBorrowLimitSum;
		uint256 depositHandlerAsset;
		uint256 borrowHandlerAsset;
		for (uint256 handlerID; handlerID < tokenHandlerLength; handlerID++)
		{
			if (dataStorageInstance.getTokenHandlerSupport(handlerID))
			{

				(depositHandlerAsset, borrowHandlerAsset) = _getUserIntraHandlerAssetWithInterest(userAddr, handlerID);
				userTotalBorrowAsset = userTotalBorrowAsset.add(borrowHandlerAsset);
				depositAssetBorrowLimitSum = depositAssetBorrowLimitSum
												.add(
													depositHandlerAsset
													.unifiedMul( _getTokenHandlerBorrowLimit(handlerID) )
												);
			}
		}

		if (depositAssetBorrowLimitSum > userTotalBorrowAsset)
		{
			return depositAssetBorrowLimitSum
					.sub(userTotalBorrowAsset)
					.unifiedDiv( _getTokenHandlerBorrowLimit(callerID) )
					.unifiedDiv( _getTokenHandlerPrice(callerID) );
		}
		return 0;
	}

	function partialLiquidationUser(address payable delinquentBorrower, uint256 liquidateAmount, address payable liquidator, uint256 liquidateHandlerID, uint256 rewardHandlerID) onlyLiquidationManager external override returns (uint256, uint256, uint256)
	{

		address tokenHandlerAddr = dataStorageInstance.getTokenHandlerAddr(liquidateHandlerID);
		proxyContractInterface tokenHandler = proxyContractInterface(tokenHandlerAddr);
		bytes memory data;

		data = abi.encodeWithSignature("partialLiquidationUser(address,uint256,address,uint256)", delinquentBorrower, liquidateAmount, liquidator, rewardHandlerID);
		(, data) = tokenHandler.handlerProxy(data);

		return abi.decode(data, (uint256, uint256, uint256));
	}

	function getMaxLiquidationReward(address payable delinquentBorrower, uint256 liquidateHandlerID, uint256 liquidateAmount, uint256 rewardHandlerID, uint256 rewardRatio) external view override returns (uint256)
	{

		uint256 liquidatePrice = _getTokenHandlerPrice(liquidateHandlerID);
		uint256 rewardPrice = _getTokenHandlerPrice(rewardHandlerID);
		uint256 delinquentBorrowerRewardDeposit;
		(delinquentBorrowerRewardDeposit, ) = _getHandlerAmount(delinquentBorrower, rewardHandlerID);
		uint256 rewardAsset = delinquentBorrowerRewardDeposit.unifiedMul(rewardPrice).unifiedMul(rewardRatio);
		if (liquidateAmount.unifiedMul(liquidatePrice) > rewardAsset)
		{
			return rewardAsset.unifiedDiv(liquidatePrice);
		}
		else
		{
			return liquidateAmount;
		}

	}

	function partialLiquidationUserReward(address payable delinquentBorrower, uint256 rewardAmount, address payable liquidator, uint256 handlerID) onlyLiquidationManager external override returns (uint256)
	{

		address tokenHandlerAddr = dataStorageInstance.getTokenHandlerAddr(handlerID);
		proxyContractInterface tokenHandler = proxyContractInterface(tokenHandlerAddr);
		bytes memory data;
		data = abi.encodeWithSignature("partialLiquidationUserReward(address,uint256,address)", delinquentBorrower, rewardAmount, liquidator);
		(, data) = tokenHandler.handlerProxy(data);

		return abi.decode(data, (uint256));
	}

	function _getHandlerAmount(address payable userAddr, uint256 handlerID) internal view returns (uint256, uint256)
	{

		proxyContractInterface tokenHandler = proxyContractInterface(dataStorageInstance.getTokenHandlerAddr(handlerID));
		bytes memory data;
		(, data) = tokenHandler.handlerViewProxy(abi.encodeWithSignature("getUserAmount(address)", userAddr));
		return abi.decode(data, (uint256, uint256));
	}

	function setHandlerSupport(uint256 handlerID, bool support) onlyOwner public returns (bool)
	{

		require(!dataStorageInstance.getTokenHandlerExist(handlerID), UNSUPPORTED_TOKEN);
		dataStorageInstance.setTokenHandlerSupport(handlerID, support);
		return true;
	}

	function getOwner() public view returns (address)
	{

		return owner;
	}

	function _handlerRegister(uint256 handlerID, address handlerAddr) internal returns (bool)
	{

		dataStorageInstance.setTokenHandler(handlerID, handlerAddr);
		tokenHandlerLength = tokenHandlerLength + 1;
		return true;
	}

	function _getUserIntraHandlerAssetWithInterest(address payable userAddr, uint256 handlerID) internal view returns (uint256, uint256)
	{

		uint256 price = _getTokenHandlerPrice(handlerID);
		proxyContractInterface tokenHandler = proxyContractInterface(dataStorageInstance.getTokenHandlerAddr(handlerID));
		uint256 depositAmount;
		uint256 borrowAmount;

		bytes memory data;
		(, data) = tokenHandler.handlerViewProxy(abi.encodeWithSignature("getUserAmountWithInterest(address)", userAddr));
		(depositAmount, borrowAmount) = abi.decode(data, (uint256, uint256));

		uint256 depositAsset = depositAmount.unifiedMul(price);
		uint256 borrowAsset = borrowAmount.unifiedMul(price);
		return (depositAsset, borrowAsset);
	}

	function _getUserLimitIntraAsset(address payable userAddr) internal view returns (uint256, uint256)
	{

		uint256 userTotalBorrowLimitAsset;
		uint256 userTotalMarginCallLimitAsset;
		for (uint256 handlerID; handlerID < tokenHandlerLength; handlerID++)
		{
			if (dataStorageInstance.getTokenHandlerSupport(handlerID))
			{
				uint256 depositHandlerAsset;
				uint256 borrowHandlerAsset;
				(depositHandlerAsset, borrowHandlerAsset) = _getUserIntraHandlerAssetWithInterest(userAddr, handlerID);
				uint256 borrowLimit = _getTokenHandlerBorrowLimit(handlerID);
				uint256 marginCallLimit = _getTokenHandlerMarginCallLimit(handlerID);
				uint256 userBorrowLimitAsset = depositHandlerAsset.unifiedMul(borrowLimit);
				uint256 userMarginCallLimitAsset = depositHandlerAsset.unifiedMul(marginCallLimit);
				userTotalBorrowLimitAsset = userTotalBorrowLimitAsset.add(userBorrowLimitAsset);
				userTotalMarginCallLimitAsset = userTotalMarginCallLimitAsset.add(userMarginCallLimitAsset);
			}
			else
			{
				continue;
			}

		}

		return (userTotalBorrowLimitAsset, userTotalMarginCallLimitAsset);
	}

	function _getUserTotalIntraCreditAsset(address payable userAddr) internal view returns (uint256, uint256)
	{

		uint256 depositTotalCredit;
		uint256 borrowTotalCredit;
		for (uint256 handlerID; handlerID < tokenHandlerLength; handlerID++)
		{
			if (dataStorageInstance.getTokenHandlerSupport(handlerID))
			{
				uint256 depositHandlerAsset;
				uint256 borrowHandlerAsset;
				(depositHandlerAsset, borrowHandlerAsset) = _getUserIntraHandlerAssetWithInterest(userAddr, handlerID);
				uint256 borrowLimit = _getTokenHandlerBorrowLimit(handlerID);
				uint256 depositHandlerCredit = depositHandlerAsset.unifiedMul(borrowLimit);
				depositTotalCredit = depositTotalCredit.add(depositHandlerCredit);
				borrowTotalCredit = borrowTotalCredit.add(borrowHandlerAsset);
			}
			else
			{
				continue;
			}

		}

		return (depositTotalCredit, borrowTotalCredit);
	}

	function _getTokenHandlerPrice(uint256 handlerID) internal view returns (uint256)
	{

		return (oracleProxy.getTokenPrice(handlerID));
	}

	function getRewardErc20() public view returns (address)
	{

		return address(rewardErc20Instance);
	}

	function getGlobalRewardInfo() external view override returns (uint256, uint256, uint256)
	{

		managerDataStorageInterface _dataStorage = dataStorageInstance;
		return (_dataStorage.getGlobalRewardPerBlock(), _dataStorage.getGlobalRewardDecrement(), _dataStorage.getGlobalRewardTotalAmount());
	}
}