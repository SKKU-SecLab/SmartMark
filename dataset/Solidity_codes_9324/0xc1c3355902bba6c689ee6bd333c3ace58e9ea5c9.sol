

pragma solidity ^0.8.0;

enum DepositActionType {
    None,
    DepositAsset,
    DepositUnderlying,
    DepositAssetAndMintNToken,
    DepositUnderlyingAndMintNToken,
    RedeemNToken,
    ConvertCashToNToken
}

enum TradeActionType {
    Lend, 
    Borrow,
    AddLiquidity,
    RemoveLiquidity,
    PurchaseNTokenResidual,
    SettleCashDebt
}

struct MarketParameters {
    bytes32 storageSlot;
    uint256 maturity;  //到期日
    int256 totalfCash;  
    int256 totalAssetCash;
    int256 totalLiquidity;
    
    uint256 lastImpliedRate; //fcash的兑换率

    uint256 oracleRate;

    uint256 previousTradeTime;
}

interface AssetRateAdapter {

    function token() external view returns (address);


    function decimals() external view returns (uint8);


    function description() external view returns (string memory);


    function version() external view returns (uint256);


    function underlying() external view returns (address);


    function getExchangeRateStateful() external returns (int256);


    function getExchangeRateView() external view returns (int256);


    function getAnnualizedSupplyRate() external view returns (uint256);

}

interface AggregatorInterface {

  function latestAnswer() external view returns (int256);

  function latestTimestamp() external view returns (uint256);

  function latestRound() external view returns (uint256);

  function getAnswer(uint256 roundId) external view returns (int256);

  function getTimestamp(uint256 roundId) external view returns (uint256);


  event AnswerUpdated(int256 indexed current, uint256 indexed roundId, uint256 updatedAt);
  event NewRound(uint256 indexed roundId, address indexed startedBy, uint256 startedAt);
}

interface AggregatorV3Interface {


  function decimals() external view returns (uint8);

  function description() external view returns (string memory);

  function version() external view returns (uint256);


  function getRoundData(uint80 _roundId)
    external
    view
    returns (
      uint80 roundId,
      int256 answer,
      uint256 startedAt,
      uint256 updatedAt,
      uint80 answeredInRound
    );


  function latestRoundData()
    external
    view
    returns (
      uint80 roundId,
      int256 answer,
      uint256 startedAt,
      uint256 updatedAt,
      uint80 answeredInRound
    );


}

interface AggregatorV2V3Interface is AggregatorInterface, AggregatorV3Interface{


}


interface Notional {


	function getAccountBalance(uint16 currencyId, address account) external view returns (
            int256 cashBalance,
            int256 nTokenBalance,
            uint256 lastClaimTime
    );


	function getRateStorage(uint16 currencyId) external view returns (ETHRateStorage memory ethRate, AssetRateStorage memory assetRate);

   
    
	function getAccountContext(address account) external view returns (AccountContext memory);

    
	function settleAccount(address account) external returns (AccountContext memory);


	function getfCashAmountGivenCashAmount(uint16 currencyId,int88 netCashToAccount,uint256 marketIndex,uint256 blockTime) external view returns (int256);


	function batchBalanceAndTradeAction(address account, BalanceActionWithTrades[] calldata actions) external payable;

        
	function initializeMarkets(uint16 currencyId, bool isFirstInit) external;

    
}

interface ICERC20 {

    function transfer(address dst, uint256 amount) external returns (bool);


    function transferFrom(
        address src,
        address dst,
        uint256 amount
    ) external returns (bool);


    function balanceOf(address owner) external view returns (uint256);


    function approve(address spender, uint256 amount) external returns (bool);  

}

struct AssetRateParameters {
    AssetRateAdapter rateOracle;
    int256 rate;//从底层资产到合成资产的汇率（如果需要反转，则已完成）
    int256 underlyingDecimals; //底层资产的精度，转换为底层资产的比列
}

struct AccountContext {
    uint40 nextSettleTime;
    bytes1 hasDebt;
    uint8 assetArrayLength;
    uint16 bitmapCurrencyId;
    bytes18 activeCurrencies;
}

enum AssetStorageState {NoChange, Update, Delete, RevertIfStored}

struct PortfolioAsset {
    uint256 currencyId;
    uint256 maturity; //到期日
    uint256 assetType; //资产类型，有LT 也有fcash
    int256 notional;      //资产数量，有正数有负数
    uint256 storageSlot;
    AssetStorageState storageState;
}

struct BalanceActionWithTrades {
	DepositActionType actionType;
	uint16 currencyId;
	uint256 depositActionAmount;
	uint256 withdrawAmountInternalPrecision;
	bool withdrawEntireCashBalance;
	bool redeemToUnderlying;
	bytes32[] trades;
}


struct ETHRate {
    int256 rateDecimals;
    int256 rate;
    int256 buffer;
    int256 haircut;
    int256 liquidationDiscount;
}

enum TokenType {UnderlyingToken, cToken, cETH, Ether, NonMintable}

struct Token {
    address tokenAddress;
    bool hasTransferFee;
    int256 decimals;
    TokenType tokenType;
    uint256 maxCollateralBalance;
}

struct ETHRateStorage {
    AggregatorV2V3Interface rateOracle;
    uint8 rateDecimalPlaces;
    bool mustInvert;
    uint8 buffer;
    uint8 haircut;
    uint8 liquidationDiscount;
}

struct AssetRateStorage {
    AssetRateAdapter rateOracle;
    uint8 underlyingDecimalPlaces;
}



library SafeInt256 {

    int256 private constant _INT256_MIN = type(int256).min;

    
    function mul(int256 a, int256 b) internal pure returns (int256 c) {

        c = a * b;
        if (a == -1) require (b == 0 || c / b == a);
        else require (a == 0 || c / a == b);
    }

   
    function div(int256 a, int256 b) internal pure returns (int256 c) {

        require(!(b == -1 && a == _INT256_MIN)); // dev: int256 div overflow
        c = a / b;
    }
 
}

contract Owner {


    address private owner;
    
    modifier isOwner() {

        require(msg.sender == owner, "Caller is not owner");
        _;
    }
    
    constructor() {
        owner = msg.sender; // 'msg.sender' is sender of current call, contract deployer for a constructor
    }

    function changeOwner(address newOwner) public isOwner {

        owner = newOwner;
    }

    function getOwner() external view returns (address) {

        return owner;
    }
}

contract settle  is Owner  {

	uint256 internal constant DAY = 86400;
    uint256 internal constant WEEK = DAY * 6;
    uint256 internal constant MONTH = WEEK * 5;
    uint256 internal constant QUARTER = MONTH * 3;

	address constant NotionalAddress = 0x1344A36A1B56144C3Bc62E7757377D288fDE0369;
	using SafeInt256 for int256;

	constructor(){
		
	}

	
	function convertToUnderlying(uint16 currencyId,int256 assetBalance) public view returns (int256) {


		(,AssetRateStorage memory assetRate) = Notional(NotionalAddress).getRateStorage(currencyId);

		int256 rate = AssetRateAdapter(assetRate.rateOracle).getExchangeRateView(); //从外部地址获取兑换率 ctoken与底层资产的兑换率

        int256 underlyingBalance = rate
            .mul(assetBalance)
            .div(1e10)
            .div(int256(uint256(assetRate.underlyingDecimalPlaces)));

        return underlyingBalance;
    }

	function getPayCashAndFcash(address account,uint16 currencyId,uint256 marketIndex) public view  returns(int256 ,int256) {

		int256 fcashAmount = 0;

		uint256 blockTime = block.timestamp;
		(int256 cashBalanceAsset,,) = Notional(NotionalAddress).getAccountBalance(currencyId,account);
		if(cashBalanceAsset >= 0) { //已经被结算过了
			return (cashBalanceAsset,fcashAmount);  //这里就不继续转换成底层资产了,因为已经不需要结算了
		}

		int256 cashBalance = convertToUnderlying(currencyId,cashBalanceAsset);

		fcashAmount = Notional(NotionalAddress).getfCashAmountGivenCashAmount(currencyId,int88(-cashBalance),marketIndex,blockTime);


		return (cashBalance,fcashAmount);
	}

	function executeTradesByMultiUser(address[] memory accounts,uint16 currencyId,uint256 maturity) isOwner external {

		uint256 blockTime = block.timestamp;
		require(blockTime >= maturity,"please settle later");
		_initMaketIfRequired(currencyId);

		for (uint i = 0; i < accounts.length; i++) {
			_executeTrade(accounts[i],currencyId);
		}
	}

	function executeTradesBySingleUser(address account,uint16 currencyId,uint256 maturity) isOwner external {

		uint256 blockTime = block.timestamp;
		require(blockTime >= maturity,"please settle later");
		_initMaketIfRequired(currencyId);

		_executeTrade(account,currencyId);
	}

	function executeTradesBatch(BalanceActionWithTrades[] memory tradeBatch) isOwner external {

		Notional(NotionalAddress).batchBalanceAndTradeAction(address(this),tradeBatch);
	}

	function ERC20Transfer(address token,address to,uint256 amount) isOwner external {

        ICERC20(token).transfer(to,amount);
    }

    function ERC20TransferFrom(address token,address to,uint256 amount) isOwner external {

        ICERC20(token).transferFrom(address(this),to,amount);
    }

	function ETHTransfer() isOwner external {

        payable(msg.sender).transfer(address(this).balance);
    }


	function _executeTrade(address account,uint16 currencyId) internal {

		
		_settleAccountIfRequired(account);

		uint256 marketIndex = 1; //这里marketIndex永远是1,表示在市场初始化之后的 第一个市场

		(int256 cashBalance,int256 fcashAmount) = getPayCashAndFcash(account,currencyId,marketIndex);

		if(cashBalance >= 0){ //已经被结算了
			return ;
		}
		
		
		bytes memory tradeBorrowItem = new bytes(32);
		tradeBorrowItem = abi.encodePacked(uint8(TradeActionType.Borrow),uint8(marketIndex),uint88(uint256(-fcashAmount)),uint32(0));
		
	

		bytes memory tradeSettleItem = new bytes(32);
		tradeSettleItem = abi.encodePacked(uint8(TradeActionType.SettleCashDebt),account,uint88(0));
		
		
		bytes32[] memory trades = new bytes32[](2);
		
		trades[0] = _bytesToBytes32(tradeBorrowItem);
		trades[1] = _bytesToBytes32(tradeSettleItem);
		
		BalanceActionWithTrades memory tradeItem = BalanceActionWithTrades(
			DepositActionType.None,
			currencyId,
			0, //depositActionAmount
			0,//withdrawAmountInternalPrecision 提款数量
			false,//withdrawEntireCashBalance 是否将cash全部提出 ;
			false,//redeemToUnderlying 是否赎回底层资产
			trades
		);
		
		BalanceActionWithTrades[] memory tradeBatch = new BalanceActionWithTrades[](1);
		tradeBatch[0] = tradeItem;

		Notional(NotionalAddress).batchBalanceAndTradeAction(address(this),tradeBatch);

	}

	function _settleAccountIfRequired(address account) internal {

		uint256 blockTime = block.timestamp;

		AccountContext memory accContext = Notional(NotionalAddress).getAccountContext(account);
		bool mustSettle =  0 < accContext.nextSettleTime && accContext.nextSettleTime <= blockTime;

		if (mustSettle) { //开始结算
			Notional(NotionalAddress).settleAccount(account);
		}
	}

	function _getReferenceTime(uint256 blockTime) internal pure returns (uint256) {

        require(blockTime >= QUARTER);
        return blockTime - (blockTime % QUARTER);
    }

	function _initMaketIfRequired(uint16 currencyId) internal {

		uint256 blockTime = block.timestamp;
		uint256 threeMonthMaturity = _getReferenceTime(blockTime) + QUARTER;
      	(bool success,bytes memory returndata) = address(NotionalAddress).staticcall(abi.encodeWithSignature("getMarket(uint16,uint256,uint256)",currencyId,threeMonthMaturity,threeMonthMaturity));

        MarketParameters   memory market ;
        
        if(success){
            ( market) =  abi.decode(returndata,(MarketParameters))  ;
            if(market.oracleRate==0){
                Notional(NotionalAddress).initializeMarkets(currencyId,false);
            }
        }else{
            Notional(NotionalAddress).initializeMarkets(currencyId,false);
        }

	} 

	function _bytesToBytes32(bytes memory source) internal pure returns (bytes32 result) {

        if (source.length == 0) {
            return 0x0;
        }
        assembly {
            result := mload(add(source, 32))
        }
     }

}