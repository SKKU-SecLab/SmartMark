
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
}// BUSL-1.1
pragma solidity 0.7.6;


abstract contract LPoolStorage {

    bool internal _notEntered;

    string public name;

    string public symbol;

    uint8 public decimals;

    uint public totalSupply;


    mapping(address => uint) internal accountTokens;

    mapping(address => mapping(address => uint)) internal transferAllowances;


    uint internal constant borrowRateMaxMantissa = 0.0005e16;

    uint public  borrowCapFactorMantissa;
    address public controller;


    uint internal initialExchangeRateMantissa;

    uint public accrualBlockNumber;

    uint public borrowIndex;

    uint public totalBorrows;

    uint internal totalCash;

    uint public reserveFactorMantissa;

    uint public totalReserves;

    address public underlying;

    bool public isWethPool;

    struct BorrowSnapshot {
        uint principal;
        uint interestIndex;
    }

    uint256 public baseRatePerBlock;
    uint256 public multiplierPerBlock;
    uint256 public jumpMultiplierPerBlock;
    uint256 public kink;


    mapping(address => BorrowSnapshot) internal accountBorrows;





    event Mint(address minter, uint mintAmount, uint mintTokens);

    event Transfer(address indexed from, address indexed to, uint amount);

    event Approval(address indexed owner, address indexed spender, uint amount);


    event AccrueInterest(uint cashPrior, uint interestAccumulated, uint borrowIndex, uint totalBorrows);

    event Redeem(address redeemer, uint redeemAmount, uint redeemTokens);

    event Borrow(address borrower, address payee, uint borrowAmount, uint accountBorrows, uint totalBorrows);

    event RepayBorrow(address payer, address borrower, uint repayAmount, uint badDebtsAmount, uint accountBorrows, uint totalBorrows);


    event NewController(address oldController, address newController);

    event NewInterestParam(uint baseRatePerBlock, uint multiplierPerBlock, uint jumpMultiplierPerBlock, uint kink);

    event NewReserveFactor(uint oldReserveFactorMantissa, uint newReserveFactorMantissa);

    event ReservesAdded(address benefactor, uint addAmount, uint newTotalReserves);

    event ReservesReduced(address to, uint reduceAmount, uint newTotalReserves);

    event NewBorrowCapFactorMantissa(uint oldBorrowCapFactorMantissa, uint newBorrowCapFactorMantissa);

}

abstract contract LPoolInterface is LPoolStorage {



    function transfer(address dst, uint amount) external virtual returns (bool);

    function transferFrom(address src, address dst, uint amount) external virtual returns (bool);

    function approve(address spender, uint amount) external virtual returns (bool);

    function allowance(address owner, address spender) external virtual view returns (uint);

    function balanceOf(address owner) external virtual view returns (uint);

    function balanceOfUnderlying(address owner) external virtual returns (uint);


    function mint(uint mintAmount) external virtual;

    function mintTo(address to, uint amount) external payable virtual;

    function mintEth() external payable virtual;

    function redeem(uint redeemTokens) external virtual;

    function redeemUnderlying(uint redeemAmount) external virtual;

    function borrowBehalf(address borrower, uint borrowAmount) external virtual;

    function repayBorrowBehalf(address borrower, uint repayAmount) external virtual;

    function repayBorrowEndByOpenLev(address borrower, uint repayAmount) external virtual;

    function availableForBorrow() external view virtual returns (uint);

    function getAccountSnapshot(address account) external virtual view returns (uint, uint, uint);

    function borrowRatePerBlock() external virtual view returns (uint);

    function supplyRatePerBlock() external virtual view returns (uint);

    function totalBorrowsCurrent() external virtual view returns (uint);

    function borrowBalanceCurrent(address account) external virtual view returns (uint);

    function borrowBalanceStored(address account) external virtual view returns (uint);

    function exchangeRateCurrent() public virtual returns (uint);

    function exchangeRateStored() public virtual view returns (uint);

    function getCash() external view virtual returns (uint);

    function accrueInterest() public virtual;


    function setController(address newController) external virtual;

    function setBorrowCapFactorMantissa(uint newBorrowCapFactorMantissa) external virtual;

    function setInterestParams(uint baseRatePerBlock_, uint multiplierPerBlock_, uint jumpMultiplierPerBlock_, uint kink_) external virtual;

    function setReserveFactor(uint newReserveFactorMantissa) external virtual;

    function addReserves(uint addAmount) external payable virtual;

    function reduceReserves(address payable to, uint reduceAmount) external virtual;

}// MIT

pragma solidity >=0.6.0 <0.8.0;

interface IERC20 {

    function totalSupply() external view returns (uint256);


    function balanceOf(address account) external view returns (uint256);


    function transfer(address recipient, uint256 amount) external returns (bool);


    function allowance(address owner, address spender) external view returns (uint256);


    function approve(address spender, uint256 amount) external returns (bool);


    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);


    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}// BUSL-1.1
pragma solidity 0.7.6;


 library TransferHelper{


    function safeTransfer(IERC20 _token, address _to, uint _amount) internal returns (uint amountReceived){

        if (_amount > 0){
            uint balanceBefore = _token.balanceOf(_to);
            address(_token).call(abi.encodeWithSelector(_token.transfer.selector, _to, _amount));
            uint balanceAfter = _token.balanceOf(_to);
            require(balanceAfter > balanceBefore, "TF");
            amountReceived = balanceAfter - balanceBefore;
        }
    }

    function safeTransferFrom(IERC20 _token, address _from, address _to, uint _amount) internal returns (uint amountReceived){

        if (_amount > 0){
            uint balanceBefore = _token.balanceOf(_to);
            address(_token).call(abi.encodeWithSelector(_token.transferFrom.selector, _from, _to, _amount));
            uint balanceAfter = _token.balanceOf(_to);
            require(balanceAfter > balanceBefore, "TFF");
            amountReceived = balanceAfter - balanceBefore;
        }
    }

    function safeApprove(IERC20 _token, address _spender, uint256 _amount) internal returns (uint) {

        bool success;
        if (_token.allowance(address(this), _spender) != 0){
            (success, ) = address(_token).call(abi.encodeWithSelector(_token.approve.selector, _spender, 0));
            require(success, "AF");
        }
        (success, ) = address(_token).call(abi.encodeWithSelector(_token.approve.selector, _spender, _amount));
        require(success, "AF");

        return _token.allowance(address(this), _spender);
    }


}// BUSL-1.1
pragma solidity 0.7.6;


library Types {

    using TransferHelper for IERC20;

    struct Market {// Market info
        LPoolInterface pool0;       // Lending Pool 0
        LPoolInterface pool1;       // Lending Pool 1
        address token0;              // Lending Token 0
        address token1;              // Lending Token 1
        uint16 marginLimit;         // Margin ratio limit for specific trading pair. Two decimal in percentage, ex. 15.32% => 1532
        uint16 feesRate;            // feesRate 30=>0.3%
        uint16 priceDiffientRatio;
        address priceUpdater;
        uint pool0Insurance;        // Insurance balance for token 0
        uint pool1Insurance;        // Insurance balance for token 1
        uint32[] dexs;
    }

    struct Trade {// Trade storage
        uint deposited;             // Balance of deposit token
        uint held;                  // Balance of held position
        bool depositToken;          // Indicate if the deposit token is token 0 or token 1
        uint128 lastBlockNum;       // Block number when the trade was touched last time, to prevent more than one operation within same block
    }

    struct MarketVars {// A variables holder for market info
        LPoolInterface buyPool;     // Lending pool address of the token to buy. It's a calculated field on open or close trade.
        LPoolInterface sellPool;    // Lending pool address of the token to sell. It's a calculated field on open or close trade.
        IERC20 buyToken;            // Token to buy
        IERC20 sellToken;           // Token to sell
        uint reserveBuyToken;
        uint reserveSellToken;
        uint buyPoolInsurance;      // Insurance balance of token to buy
        uint sellPoolInsurance;     // Insurance balance of token to sell
        uint16 marginLimit;         // Margin Ratio Limit for specific trading pair.
        uint16 priceDiffientRatio;
        uint32[] dexs;
    }

    struct TradeVars {// A variables holder for trade info
        uint depositValue;          // Deposit value
        IERC20 depositErc20;        // Deposit Token address
        uint fees;                  // Fees value
        uint depositAfterFees;      // Deposit minus fees
        uint tradeSize;             // Trade amount to be swap on DEX
        uint newHeld;               // Latest held position
        uint borrowValue;
        uint token0Price;
        uint32 dexDetail;
        uint totalHeld;
    }

    struct CloseTradeVars {// A variables holder for close trade info
        uint16 marketId;
        bool longToken;
        bool depositToken;
        uint closeRatio;          // Close ratio
        bool isPartialClose;        // Is partial close
        uint closeAmountAfterFees;  // Close amount sub Fees value
        uint borrowed;
        uint repayAmount;           // Repay to pool value
        uint depositDecrease;       // Deposit decrease
        uint depositReturn;         // Deposit actual returns
        uint sellAmount;
        uint receiveAmount;
        uint token0Price;
        uint fees;                  // Fees value
        uint32 dexDetail;
    }


    struct LiquidateVars {// A variable holder for liquidation process
        uint16 marketId;
        bool longToken;
        uint borrowed;              // Total borrowed balance of trade
        uint fees;                  // Fees for liquidation process
        uint penalty;               // Penalty
        uint remainAmountAfterFees;   // Held-fees-penalty
        bool isSellAllHeld;         // Is need sell all held
        uint depositDecrease;       // Deposit decrease
        uint depositReturn;         // Deposit actual returns
        uint sellAmount;
        uint receiveAmount;
        uint token0Price;
        uint outstandingAmount;
        uint finalRepayAmount;
        uint32 dexDetail;
    }

    struct MarginRatioVars {
        address heldToken;
        address sellToken;
        address owner;
        uint held;
        bytes dexData;
        uint16 multiplier;
        uint price;
        uint cAvgPrice;
        uint hAvgPrice; 
        uint8 decimals;
        uint lastUpdateTime;
    }
}// BUSL-1.1
pragma solidity ^0.7.6;
pragma experimental ABIEncoderV2;

library DexData {

    uint constant DEX_INDEX = 0;
    uint constant FEE_INDEX = 1;
    uint constant ARRYLENTH_INDEX = 4;
    uint constant TRANSFERFEE_INDEX = 5;
    uint constant PATH_INDEX = 5;
    uint constant FEE_SIZE = 3;
    uint constant ADDRESS_SIZE = 20;
    uint constant NEXT_OFFSET = ADDRESS_SIZE + FEE_SIZE;

    uint8 constant DEX_UNIV2 = 1;
    uint8 constant DEX_UNIV3 = 2;
    uint8 constant DEX_PANCAKE = 3;
    uint8 constant DEX_SUSHI = 4;
    uint8 constant DEX_MDEX = 5;
    uint8 constant DEX_TRADERJOE = 6;
    uint8 constant DEX_SPOOKY = 7;
    uint8 constant DEX_QUICK = 8;
    uint8 constant DEX_SHIBA = 9;
    uint8 constant DEX_APE = 10;
    uint8 constant DEX_PANCAKEV1 = 11;
    uint8 constant DEX_BABY = 12;

    struct V3PoolData {
        address tokenA;
        address tokenB;
        uint24 fee;
    }

    function toDex(bytes memory data) internal pure returns (uint8) {

        require(data.length >= FEE_INDEX, "DexData: toDex wrong data format");
        uint8 temp;
        assembly {
            temp := byte(0, mload(add(data, add(0x20, DEX_INDEX))))
        }
        return temp;
    }

    function toFee(bytes memory data) internal pure returns (uint24) {

        require(data.length >= ARRYLENTH_INDEX, "DexData: toFee wrong data format");
        uint temp;
        assembly {
            temp := mload(add(data, add(0x20, FEE_INDEX)))
        }
        return uint24(temp >> (256 - (ARRYLENTH_INDEX - FEE_INDEX) * 8));
    }

    function toDexDetail(bytes memory data) internal pure returns (uint32) {

        require (data.length >= FEE_INDEX, "DexData: toDexDetail wrong data format");
        if (isUniV2Class(data)){
            uint8 temp;
            assembly {
                temp := byte(0, mload(add(data, add(0x20, DEX_INDEX))))
            }
            return uint32(temp);
        } else {
            uint temp;
            assembly {
                temp := mload(add(data, add(0x20, DEX_INDEX)))
            }
            return uint32(temp >> (256 - ((FEE_SIZE + FEE_INDEX) * 8)));
        }
    }

    function toArrayLength(bytes memory data) internal pure returns(uint8 length){

        require(data.length >= TRANSFERFEE_INDEX, "DexData: toArrayLength wrong data format");

        assembly {
            length := byte(0, mload(add(data, add(0x20, ARRYLENTH_INDEX))))
        }
    }

    function toTransferFeeRates(bytes memory data) internal pure returns (uint24[] memory transferFeeRates){

        uint8 length = toArrayLength(data) * 3;
        uint start = TRANSFERFEE_INDEX;

        transferFeeRates = new uint24[](length);
        for (uint i = 0; i < length; i++){
            if (data.length <= start){
                transferFeeRates[i] = 0;
                continue;
            }

            uint temp;
            assembly {
                temp := mload(add(data, add(0x20, start)))
            }

            transferFeeRates[i] = uint24(temp >> (256 - FEE_SIZE * 8));
            start += FEE_SIZE;
        }
    }

    function toUniV2Path(bytes memory data) internal pure returns (address[] memory path) {

        uint8 length = toArrayLength(data);
        uint end =  PATH_INDEX + ADDRESS_SIZE * length;
        require(data.length >= end, "DexData: toUniV2Path wrong data format");

        uint start = PATH_INDEX;
        path = new address[](length);
        for (uint i = 0; i < length; i++) {
            uint startIndex = start + ADDRESS_SIZE * i;
            uint temp;
            assembly {
                temp := mload(add(data, add(0x20, startIndex)))
            }

            path[i] = address(temp >> (256 - ADDRESS_SIZE * 8));
        }
    }

    function isUniV2Class(bytes memory data) internal pure returns(bool){

        return toDex(data) != DEX_UNIV3;
    }

    function toUniV3Path(bytes memory data) internal pure returns (V3PoolData[] memory path) {

        uint8 length = toArrayLength(data);
        uint end = PATH_INDEX + (FEE_SIZE  + ADDRESS_SIZE) * length - FEE_SIZE;
        require(data.length >= end, "DexData: toUniV3Path wrong data format");
        require(length > 1, "DexData: toUniV3Path path too short");

        uint temp;
        uint index = PATH_INDEX;
        path = new V3PoolData[](length - 1);

        for (uint i = 0; i < length - 1; i++) {
            V3PoolData memory pool;

            if (i == 0) {
                assembly {
                    temp := mload(add(data, add(0x20, index)))
                }
                pool.tokenA = address(temp >> (256 - ADDRESS_SIZE * 8));
                index += ADDRESS_SIZE;
            }else{
                pool.tokenA = path[i-1].tokenB;
                index += NEXT_OFFSET;
            }

            assembly {
                temp := mload(add(data, add(0x20, index)))
            }

            uint tokenBAndFee = temp >> (256 - NEXT_OFFSET * 8);
            pool.tokenB = address(tokenBAndFee >> (FEE_SIZE * 8));
            pool.fee = uint24(tokenBAndFee - (tokenBAndFee << (FEE_SIZE * 8)));

            path[i] = pool;
        }
    }
}// BUSL-1.1
pragma solidity ^0.7.6;


library Utils{

    using SafeMath for uint;

    uint constant feeRatePrecision = 10**6;

    function toAmountBeforeTax(uint256 amount, uint24 feeRate) internal pure returns (uint){

        uint denominator = feeRatePrecision.sub(feeRate);
        uint numerator = amount.mul(feeRatePrecision).add(denominator).sub(1);
        return numerator / denominator;
    }

    function toAmountAfterTax(uint256 amount, uint24 feeRate) internal pure returns (uint){

        return amount.mul(feeRatePrecision.sub(feeRate)) / feeRatePrecision;
    }

    function minOf(uint a, uint b) internal pure returns (uint){

        return a < b ? a : b;
    }

    function maxOf(uint a, uint b) internal pure returns (uint){

        return a > b ? a : b;
    }
}// MIT

pragma solidity >=0.6.2 <0.8.0;

library Address {

    function isContract(address account) internal view returns (bool) {


        uint256 size;
        assembly { size := extcodesize(account) }
        return size > 0;
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

        return functionCallWithValue(target, data, 0, errorMessage);
    }

    function functionCallWithValue(address target, bytes memory data, uint256 value) internal returns (bytes memory) {

        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    function functionCallWithValue(address target, bytes memory data, uint256 value, string memory errorMessage) internal returns (bytes memory) {

        require(address(this).balance >= value, "Address: insufficient balance for call");
        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{ value: value }(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {

        return functionStaticCall(target, data, "Address: low-level static call failed");
    }

    function functionStaticCall(address target, bytes memory data, string memory errorMessage) internal view returns (bytes memory) {

        require(isContract(target), "Address: static call to non-contract");

        (bool success, bytes memory returndata) = target.staticcall(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {

        return functionDelegateCall(target, data, "Address: low-level delegate call failed");
    }

    function functionDelegateCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {

        require(isContract(target), "Address: delegate call to non-contract");

        (bool success, bytes memory returndata) = target.delegatecall(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function _verifyCallResult(bool success, bytes memory returndata, string memory errorMessage) private pure returns(bytes memory) {

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
}// MIT

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
}pragma solidity >=0.5.0;

interface IUniswapV2Factory {

    event PairCreated(address indexed token0, address indexed token1, address pair, uint);

    function feeTo() external view returns (address);

    function feeToSetter() external view returns (address);


    function getPair(address tokenA, address tokenB) external view returns (address pair);

    function allPairs(uint) external view returns (address pair);

    function allPairsLength() external view returns (uint);


    function createPair(address tokenA, address tokenB) external returns (address pair);


    function setFeeTo(address) external;

    function setFeeToSetter(address) external;

}// BUSL-1.1

pragma solidity 0.7.6;

interface DexAggregatorInterface {


    function sell(address buyToken, address sellToken, uint sellAmount, uint minBuyAmount, bytes memory data) external returns (uint buyAmount);


    function sellMul(uint sellAmount, uint minBuyAmount, bytes memory data) external returns (uint buyAmount);


    function buy(address buyToken, address sellToken, uint24 buyTax, uint24 sellTax, uint buyAmount, uint maxSellAmount, bytes memory data) external returns (uint sellAmount);


    function calBuyAmount(address buyToken, address sellToken, uint24 buyTax, uint24 sellTax, uint sellAmount, bytes memory data) external view returns (uint);


    function calSellAmount(address buyToken, address sellToken, uint24 buyTax, uint24 sellTax, uint buyAmount, bytes memory data) external view returns (uint);


    function getPrice(address desToken, address quoteToken, bytes memory data) external view returns (uint256 price, uint8 decimals);


    function getAvgPrice(address desToken, address quoteToken, uint32 secondsAgo, bytes memory data) external view returns (uint256 price, uint8 decimals, uint256 timestamp);


    function getPriceCAvgPriceHAvgPrice(address desToken, address quoteToken, uint32 secondsAgo, bytes memory dexData) external view returns (uint price, uint cAvgPrice, uint256 hAvgPrice, uint8 decimals, uint256 timestamp);


    function updatePriceOracle(address desToken, address quoteToken, uint32 timeWindow, bytes memory data) external returns(bool);


    function updateV3Observation(address desToken, address quoteToken, bytes memory data) external;


    function setDexInfo(uint8[] memory dexName, IUniswapV2Factory[] memory factoryAddr, uint16[] memory fees) external;

}// BUSL-1.1
pragma solidity 0.7.6;



contract XOLEStorage {


    string public constant name = 'xOLE';

    string public constant symbol = 'xOLE';

    uint8 public constant decimals = 18;

    uint public totalSupply;

    uint public totalLocked;

    mapping(address => uint) internal balances;

    mapping(address => LockedBalance) public locked;

    DexAggregatorInterface public dexAgg;

    IERC20 public oleToken;

    struct LockedBalance {
        uint256 amount;
        uint256 end;
    }

    uint constant oneWeekExtraRaise = 208;// 2.08% * 210 = 436% (4 years raise)

    int128 constant DEPOSIT_FOR_TYPE = 0;
    int128 constant CREATE_LOCK_TYPE = 1;
    int128 constant INCREASE_LOCK_AMOUNT = 2;
    int128 constant INCREASE_UNLOCK_TIME = 3;

    uint256 constant WEEK = 7 * 86400;  // all future times are rounded by week
    uint256 constant MAXTIME = 4 * 365 * 86400;  // 4 years
    uint256 constant MULTIPLIER = 10 ** 18;


    address public dev;

    uint public devFund;

    uint public devFundRatio; // ex. 5000 => 50%

    mapping(address => uint256) public rewards;

    uint public totalStaked;

    uint public totalRewarded;

    uint public withdrewReward;

    uint public lastUpdateTime;

    uint public rewardPerTokenStored;

    mapping(address => uint256) public userRewardPerTokenPaid;


    mapping(address => address) public delegates;

    struct Checkpoint {
        uint32 fromBlock;
        uint votes;
    }

    mapping(uint256 => Checkpoint) public totalSupplyCheckpoints;

    uint256 public totalSupplyNumCheckpoints;

    mapping(address => mapping(uint32 => Checkpoint)) public checkpoints;

    mapping(address => uint32) public numCheckpoints;

    bytes32 public constant DOMAIN_TYPEHASH = keccak256("EIP712Domain(string name,uint256 chainId,address verifyingContract)");

    bytes32 public constant DELEGATION_TYPEHASH = keccak256("Delegation(address delegatee,uint256 nonce,uint256 expiry)");

    mapping(address => uint) public nonces;

    event DelegateChanged(address indexed delegator, address indexed fromDelegate, address indexed toDelegate);

    event DelegateVotesChanged(address indexed delegate, uint previousBalance, uint newBalance);


    event RewardAdded(address fromToken, uint convertAmount, uint reward);
    event RewardConvert(address fromToken, address toToken, uint convertAmount, uint returnAmount);

    event Transfer(address indexed from, address indexed to, uint256 value);

    event Deposit (
        address indexed provider,
        uint256 value,
        uint256 indexed locktime,
        int128 type_,
        uint256 ts
    );

    event Withdraw (
        address indexed provider,
        uint256 value,
        uint256 ts
    );

    event Supply (
        uint256 prevSupply,
        uint256 supply
    );

    event RewardPaid (
        address paidTo,
        uint256 amount
    );

    event FailedDelegateBySig(
        address indexed delegatee,
        uint indexed nonce, 
        uint expiry,
        uint8 v, 
        bytes32 r, 
        bytes32 s
    );
}


interface XOLEInterface {


    function convertToSharingToken(uint amount, uint minBuyAmount, bytes memory data) external;


    function withdrawDevFund() external;


    function earned(address account) external view returns (uint);


    function withdrawReward() external;



    function setDevFundRatio(uint newRatio) external;


    function setDev(address newDev) external;


    function setDexAgg(DexAggregatorInterface newDexAgg) external;



    function create_lock(uint256 _value, uint256 _unlock_time) external;


    function increase_amount(uint256 _value) external;


    function increase_unlock_time(uint256 _unlock_time) external;


    function withdraw() external;


    function balanceOf(address addr) external view returns (uint256);


}// BUSL-1.1
pragma solidity 0.7.6;



contract QueryHelper {

    using DexData for bytes;
    using SafeMath for uint;

    constructor ()
    {

    }
    struct PositionVars {
        uint deposited;
        uint held;
        uint borrowed;
        uint marginRatio;
        uint32 marginLimit;
    }
    enum LiqStatus{
        HEALTHY, // Do nothing
        UPDATE, // Need update price
        WAITING, // Waiting
        LIQ, // Can liquidate
        NOP// No position
    }

    struct LiqVars {
        LiqStatus status;
        uint lastUpdateTime;
        uint currentMarginRatio;
        uint cAvgMarginRatio;
        uint hAvgMarginRatio;
        uint32 marginLimit;
    }

    struct PoolVars {
        uint totalBorrows;
        uint cash;
        uint totalReserves;
        uint availableForBorrow;
        uint insurance;
        uint supplyRatePerBlock;
        uint borrowRatePerBlock;
        uint reserveFactorMantissa;
        uint exchangeRate;
        uint baseRatePerBlock;
        uint multiplierPerBlock;
        uint jumpMultiplierPerBlock;
        uint kink;
    }

    struct XOLEVars {
        uint totalStaked;
        uint totalShared;
        uint tranferedToAccount;
        uint devFund;
        uint balanceOf;
    }

    struct Balance {
        uint balance;
        uint totalHelds;
    }

    function getTraderPositons(IOpenLev openLev, uint16 marketId, address[] calldata traders, bool[] calldata longTokens, bytes calldata dexData) external view returns (PositionVars[] memory results){

        results = new PositionVars[](traders.length);
        IOpenLev.MarketVar memory market = openLev.markets(marketId);
        for (uint i = 0; i < traders.length; i++) {
            PositionVars memory item;
            Types.Trade memory trade = openLev.activeTrades(traders[i], marketId, longTokens[i]);
            if (trade.held == 0) {
                results[i] = item;
                continue;
            }
            item.held = trade.held;
            item.deposited = trade.deposited;
            (item.marginRatio,,,item.marginLimit) = openLev.marginRatio(traders[i], marketId, longTokens[i], dexData);
            item.borrowed = longTokens[i] ? market.pool0.borrowBalanceCurrent(traders[i]) : market.pool1.borrowBalanceCurrent(traders[i]);
            results[i] = item;
        }
        return results;
    }

    struct LiqReqVars {
        IOpenLev openLev;
        address owner;
        uint16 marketId;
        bool longToken;
        uint256 token0price;
        uint256 token0cAvgPrice;
        uint256 token1price;
        uint256 token1cAvgPrice;
        uint256 timestamp;
        bytes dexData;
    }
    function getTraderLiqs(IOpenLev openLev, uint16 marketId, address[] calldata traders, bool[] calldata longTokens, bytes calldata dexData) external returns (LiqVars[] memory results){

        results = new LiqVars[](traders.length);
        LiqReqVars memory reqVar;
        reqVar.openLev = openLev;
        reqVar.marketId = marketId;
        reqVar.dexData = dexData;
        IOpenLev.MarketVar memory market = reqVar.openLev.markets(reqVar.marketId);
        IOpenLev.AddressConfig memory adrConf = reqVar.openLev.addressConfig();
        IOpenLev.CalculateConfig memory calConf = reqVar.openLev.calculateConfig();
        (,,,, reqVar.timestamp) = adrConf.dexAggregator.getPriceCAvgPriceHAvgPrice(market.token0, market.token1, calConf.twapDuration, reqVar.dexData);
        openLev.updatePrice(marketId, dexData);
        (reqVar.token0price, reqVar.token0cAvgPrice,,,) = adrConf.dexAggregator.getPriceCAvgPriceHAvgPrice(market.token0, market.token1, calConf.twapDuration, reqVar.dexData);
        (reqVar.token1price, reqVar.token1cAvgPrice,,,) = adrConf.dexAggregator.getPriceCAvgPriceHAvgPrice(market.token1, market.token0, calConf.twapDuration, reqVar.dexData);

        for (uint i = 0; i < traders.length; i++) {
            reqVar.owner = traders[i];
            reqVar.longToken = longTokens[i];
            LiqVars memory item;
            Types.Trade memory trade = reqVar.openLev.activeTrades(reqVar.owner, reqVar.marketId, reqVar.longToken);
            if (trade.held == 0) {
                item.status = LiqStatus.NOP;
                results[i] = item;
                continue;
            }
            item.lastUpdateTime = reqVar.timestamp;
            bool canUpdatePrice = block.timestamp - calConf.twapDuration > item.lastUpdateTime;
            (item.currentMarginRatio, item.cAvgMarginRatio, item.hAvgMarginRatio, item.marginLimit) = reqVar.openLev.marginRatio(reqVar.owner, reqVar.marketId, reqVar.longToken, reqVar.dexData);
            if (item.currentMarginRatio > item.marginLimit && item.cAvgMarginRatio > item.marginLimit && item.hAvgMarginRatio > item.marginLimit) {
                item.status = LiqStatus.HEALTHY;
            }
            else if (item.currentMarginRatio < item.marginLimit && item.cAvgMarginRatio > item.marginLimit && item.hAvgMarginRatio > item.marginLimit) {
                if (dexData.isUniV2Class() && canUpdatePrice) {
                    item.status = LiqStatus.UPDATE;
                } else {
                    item.status = LiqStatus.WAITING;
                }
            } else if (item.currentMarginRatio < item.marginLimit && item.cAvgMarginRatio < item.marginLimit) {
                if (canUpdatePrice || item.hAvgMarginRatio < item.marginLimit) {
                    if ((longTokens[i] == false && reqVar.token0cAvgPrice > reqVar.token0price && reqVar.token0cAvgPrice.mul(100).div(reqVar.token0price) - 100 >= calConf.maxLiquidationPriceDiffientRatio)
                        || (longTokens[i] == true && reqVar.token1cAvgPrice > reqVar.token1price && reqVar.token1cAvgPrice.mul(100).div(reqVar.token1price) - 100 >= calConf.maxLiquidationPriceDiffientRatio)) {
                        if (dexData.isUniV2Class() && canUpdatePrice) {
                            item.status = LiqStatus.UPDATE;
                        } else {
                            item.status = LiqStatus.WAITING;
                        }
                    } else {
                        item.status = LiqStatus.LIQ;
                    }
                } else {
                    item.status = LiqStatus.WAITING;
                }
            }
            results[i] = item;
        }
        return results;
    }
    function calPriceCAvgPriceHAvgPrice(IOpenLev openLev, uint16 marketId, address desToken, address quoteToken, uint32 secondsAgo, bytes memory dexData) external
    returns (uint price, uint cAvgPrice, uint256 hAvgPrice, uint8 decimals, uint256 timestamp){

        IOpenLev.AddressConfig memory adrConf = openLev.addressConfig();
        (,,,, timestamp) = adrConf.dexAggregator.getPriceCAvgPriceHAvgPrice(desToken, quoteToken, secondsAgo, dexData);
        openLev.updatePrice(marketId, dexData);
        (price, cAvgPrice, hAvgPrice, decimals,) = adrConf.dexAggregator.getPriceCAvgPriceHAvgPrice(desToken, quoteToken, secondsAgo, dexData);
    }

    struct LiqCallVars {
        uint defaultFees;
        uint newFees;
        uint penalty;
        uint heldAfterFees;
        uint borrows;
        uint currentBuyAmount;
        uint currentSellAmount;
        bool canRepayBorrows;
        address buyToken;
        address sellToken;
        uint24 txTax;
        uint24 buyTax;
        uint24 sellTax;
        uint totalHeld;
        uint balance;
    }
    function getLiqCallData(IOpenLev openLev, IV3Quoter v3Quoter, uint16 marketId, uint16 slippage, address trader, bool longToken, bytes memory dexData)
    external returns (uint minBuy, uint maxSell)
    {

        IOpenLev.MarketVar memory market = openLev.markets(marketId);
        Types.Trade memory trade = openLev.activeTrades(trader, marketId, longToken);
        LiqCallVars memory callVars;
        callVars.totalHeld = openLev.totalHelds(longToken ? market.token1 : market.token0);
        callVars.balance = IERC20(longToken ? market.token1 : market.token0).balanceOf(address(openLev));
        trade.held = trade.held.mul(callVars.balance).div(callVars.totalHeld);
        callVars.buyToken = longToken ? market.token0 : market.token1;
        callVars.sellToken = longToken ? market.token1 : market.token0;
        callVars.defaultFees = trade.held.mul(market.feesRate).div(10000);
        callVars.newFees = callVars.defaultFees;
        IOpenLev.AddressConfig memory adrConf = openLev.addressConfig();
        IOpenLev.CalculateConfig memory calConf = openLev.calculateConfig();
        if (XOLEInterface(adrConf.xOLE).balanceOf(trader) > calConf.feesDiscountThreshold) {
            callVars.newFees = callVars.defaultFees.sub(callVars.defaultFees.mul(calConf.feesDiscount).div(100));
        }
        if (market.priceUpdater == trader) {
            callVars.newFees = callVars.newFees.sub(callVars.defaultFees.mul(calConf.updatePriceDiscount).div(100));
        }
        callVars.penalty = trade.held.mul(calConf.penaltyRatio).div(10000);
        callVars.heldAfterFees = trade.held.sub(callVars.penalty).sub(callVars.newFees);
        callVars.txTax = openLev.taxes(marketId, callVars.buyToken, 0);
        callVars.buyTax = openLev.taxes(marketId, callVars.buyToken, 2);
        callVars.sellTax = openLev.taxes(marketId, callVars.sellToken, 1);
        callVars.borrows = Utils.toAmountBeforeTax(longToken ? market.pool0.borrowBalanceCurrent(trader) : market.pool1.borrowBalanceCurrent(trader), callVars.txTax);
        callVars.currentBuyAmount = dexData.isUniV2Class() ?
        adrConf.dexAggregator.calBuyAmount(callVars.buyToken, callVars.sellToken, callVars.buyTax, callVars.sellTax, callVars.heldAfterFees, dexData) :
        v3Quoter.quoteExactInputSingle(callVars.sellToken, callVars.buyToken, dexData.toFee(), callVars.heldAfterFees, 0);
        callVars.canRepayBorrows = callVars.currentBuyAmount >= callVars.borrows;
        if (trade.depositToken != longToken || !callVars.canRepayBorrows) {
            minBuy = callVars.currentBuyAmount.sub(callVars.currentBuyAmount.mul(slippage).div(1000));
        }
        else {
            callVars.currentSellAmount = dexData.isUniV2Class() ?
            adrConf.dexAggregator.calSellAmount(callVars.buyToken, callVars.sellToken, callVars.buyTax, callVars.sellTax, callVars.borrows, dexData) :
            v3Quoter.quoteExactOutputSingle(callVars.sellToken, callVars.buyToken, dexData.toFee(), callVars.borrows, 0);
            maxSell = callVars.currentSellAmount.add(callVars.currentSellAmount.mul(slippage).div(1000));
        }
    }

    function getPoolDetails(IOpenLev openLev, uint16[] calldata marketIds, LPoolInterface[] calldata pools) external view returns (PoolVars[] memory results){

        results = new PoolVars[](pools.length);
        for (uint i = 0; i < pools.length; i++) {
            LPoolInterface pool = pools[i];
            IOpenLev.MarketVar memory market = openLev.markets(marketIds[i]);
            PoolVars memory item;
            item.insurance = address(market.pool0) == address(pool) ? market.pool0Insurance : market.pool1Insurance;
            item.cash = pool.getCash();
            item.totalBorrows = pool.totalBorrowsCurrent();
            item.totalReserves = pool.totalReserves();
            item.availableForBorrow = pool.availableForBorrow();
            item.supplyRatePerBlock = pool.supplyRatePerBlock();
            item.borrowRatePerBlock = pool.borrowRatePerBlock();
            item.reserveFactorMantissa = pool.reserveFactorMantissa();
            item.exchangeRate = pool.exchangeRateStored();
            item.baseRatePerBlock = pool.baseRatePerBlock();
            item.multiplierPerBlock = pool.multiplierPerBlock();
            item.jumpMultiplierPerBlock = pool.jumpMultiplierPerBlock();
            item.kink = pool.kink();
            results[i] = item;
        }
        return results;
    }

    function getXOLEDetail(IXOLE xole, IERC20 balanceOfToken) external view returns (XOLEVars memory vars){

        vars.totalStaked = xole.totalLocked();
        vars.totalShared = xole.totalRewarded();
        vars.tranferedToAccount = xole.withdrewReward();
        vars.devFund = xole.devFund();
        if (address(0) != address(balanceOfToken)) {
            vars.balanceOf = balanceOfToken.balanceOf(address(xole));
        }
    }

    function getOpenLevBalances(IOpenLev openLev, address[] calldata tokens) external view returns (Balance[] memory results){

        results = new Balance[](tokens.length);
        for (uint i = 0; i < tokens.length; i++) {
            uint balance = IERC20(tokens[i]).balanceOf(address(openLev));
            uint totalHelds = openLev.totalHelds(tokens[i]);
            results[i] = Balance(balance, totalHelds);
        }
        return results;
    }
}

interface IXOLE {

    function totalLocked() external view returns (uint256);


    function totalRewarded() external view returns (uint256);


    function withdrewReward() external view returns (uint256);


    function devFund() external view returns (uint256);


}

interface IV3Quoter {

    function quoteExactInputSingle(
        address tokenIn,
        address tokenOut,
        uint24 fee,
        uint256 amountIn,
        uint160 sqrtPriceLimitX96
    ) external returns (uint256 amountOut);


    function quoteExactOutputSingle(
        address tokenIn,
        address tokenOut,
        uint24 fee,
        uint256 amountOut,
        uint160 sqrtPriceLimitX96
    ) external returns (uint256 amountIn);

}

interface IOpenLev {

    struct MarketVar {// Market info
        LPoolInterface pool0;       // Lending Pool 0
        LPoolInterface pool1;       // Lending Pool 1
        address token0;              // Lending Token 0
        address token1;              // Lending Token 1
        uint16 marginLimit;         // Margin ratio limit for specific trading pair. Two decimal in percentage, ex. 15.32% => 1532
        uint16 feesRate;            // feesRate 30=>0.3%
        uint16 priceDiffientRatio;
        address priceUpdater;
        uint pool0Insurance;        // Insurance balance for token 0
        uint pool1Insurance;        // Insurance balance for token 1
    }

    struct AddressConfig {
        DexAggregatorInterface dexAggregator;
        address controller;
        address wETH;
        address xOLE;
    }

    struct CalculateConfig {
        uint16 defaultFeesRate; // 30 =>0.003
        uint8 insuranceRatio; // 33=>33%
        uint16 defaultMarginLimit; // 3000=>30%
        uint16 priceDiffientRatio; //10=>10%
        uint16 updatePriceDiscount;//25=>25%
        uint16 feesDiscount; // 25=>25%
        uint128 feesDiscountThreshold; //  30 * (10 ** 18) minimal holding of xOLE to enjoy fees discount
        uint16 penaltyRatio;//100=>1%
        uint8 maxLiquidationPriceDiffientRatio;//30=>30%
        uint16 twapDuration;//28=>28s
    }

    function activeTrades(address owner, uint16 marketId, bool longToken) external view returns (Types.Trade memory);


    function marginRatio(address owner, uint16 marketId, bool longToken, bytes memory dexData) external view returns (uint current, uint cAvg, uint hAvg, uint32 limit);


    function markets(uint16 marketId) external view returns (MarketVar memory);


    function getMarketSupportDexs(uint16 marketId) external view returns (uint32[] memory);


    function addressConfig() external view returns (AddressConfig memory);


    function calculateConfig() external view returns (CalculateConfig memory);


    function updatePrice(uint16 marketId, bytes memory dexData) external;


    function taxes(uint16 marketId, address token, uint index) external view returns (uint24);


    function totalHelds(address token) external view returns (uint);

}