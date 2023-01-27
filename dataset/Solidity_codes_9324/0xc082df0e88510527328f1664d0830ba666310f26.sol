
pragma solidity >=0.6.0 <0.8.0;

abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
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
}// MIT

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
}// MIT

pragma solidity >=0.6.0 <0.8.0;


contract ERC20 is Context, IERC20 {

    using SafeMath for uint256;

    mapping (address => uint256) private _balances;

    mapping (address => mapping (address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;
    uint8 private _decimals;

    constructor (string memory name_, string memory symbol_) public {
        _name = name_;
        _symbol = symbol_;
        _decimals = 18;
    }

    function name() public view virtual returns (string memory) {

        return _name;
    }

    function symbol() public view virtual returns (string memory) {

        return _symbol;
    }

    function decimals() public view virtual returns (uint8) {

        return _decimals;
    }

    function totalSupply() public view virtual override returns (uint256) {

        return _totalSupply;
    }

    function balanceOf(address account) public view virtual override returns (uint256) {

        return _balances[account];
    }

    function transfer(address recipient, uint256 amount) public virtual override returns (bool) {

        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function allowance(address owner, address spender) public view virtual override returns (uint256) {

        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public virtual override returns (bool) {

        _approve(_msgSender(), spender, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) public virtual override returns (bool) {

        _transfer(sender, recipient, amount);
        _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount, "ERC20: transfer amount exceeds allowance"));
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {

        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].add(addedValue));
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {

        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].sub(subtractedValue, "ERC20: decreased allowance below zero"));
        return true;
    }

    function _transfer(address sender, address recipient, uint256 amount) internal virtual {

        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(sender, recipient, amount);

        _balances[sender] = _balances[sender].sub(amount, "ERC20: transfer amount exceeds balance");
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
    }

    function _mint(address account, uint256 amount) internal virtual {

        require(account != address(0), "ERC20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply = _totalSupply.add(amount);
        _balances[account] = _balances[account].add(amount);
        emit Transfer(address(0), account, amount);
    }

    function _burn(address account, uint256 amount) internal virtual {

        require(account != address(0), "ERC20: burn from the zero address");

        _beforeTokenTransfer(account, address(0), amount);

        _balances[account] = _balances[account].sub(amount, "ERC20: burn amount exceeds balance");
        _totalSupply = _totalSupply.sub(amount);
        emit Transfer(account, address(0), amount);
    }

    function _approve(address owner, address spender, uint256 amount) internal virtual {

        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _setupDecimals(uint8 decimals_) internal virtual {

        _decimals = decimals_;
    }

    function _beforeTokenTransfer(address from, address to, uint256 amount) internal virtual { }

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
pragma experimental ABIEncoderV2;

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



contract ControllerStorage {

    struct LPoolPair {
        address lpool0;
        address lpool1;
    }
    struct LPoolDistribution {
        uint64 startTime;
        uint64 endTime;
        uint64 duration;
        uint64 lastUpdateTime;
        uint256 totalRewardAmount;
        uint256 rewardRate;
        uint256 rewardPerTokenStored;
        uint256 extraTotalToken;
    }
    struct LPoolRewardByAccount {
        uint rewardPerTokenStored;
        uint rewards;
        uint extraToken;
    }

    struct OLETokenDistribution {
        uint supplyBorrowBalance;
        uint extraBalance;
        uint128 updatePricePer;
        uint128 liquidatorMaxPer;
        uint16 liquidatorOLERatio;//300=>300%
        uint16 xoleRaiseRatio;//150=>150%
        uint128 xoleRaiseMinAmount;
    }

    IERC20 public oleToken;

    address public xoleToken;

    address public wETH;

    address public lpoolImplementation;

    uint256 public baseRatePerBlock;
    uint256 public multiplierPerBlock;
    uint256 public jumpMultiplierPerBlock;
    uint256 public kink;

    bytes public oleWethDexData;

    address public openLev;

    DexAggregatorInterface public dexAggregator;

    bool public suspend;

    OLETokenDistribution public oleTokenDistribution;
    mapping(address => mapping(address => LPoolPair)) public lpoolPairs;
    mapping(uint => bool) public marketExtraDistribution;
    mapping(uint => bool) public marketSuspend;
    mapping(address => bool) public lpoolUnAlloweds;
    mapping(LPoolInterface => mapping(bool => LPoolDistribution)) public lpoolDistributions;
    mapping(LPoolInterface => mapping(bool => mapping(address => LPoolRewardByAccount))) public lPoolRewardByAccounts;

    bool public suspendAll;

    event LPoolPairCreated(address token0, address pool0, address token1, address pool1, uint16 marketId, uint16 marginLimit, bytes dexData);

    event Distribution2Pool(address pool, uint supplyAmount, uint borrowerAmount, uint64 startTime, uint64 duration, uint newSupplyBorrowBalance);

    event UpdatePriceReward(uint marketId, address updator, uint reward, uint newExtraBalance);

    event LiquidateReward(uint marketId, address liquidator, uint reward, uint newExtraBalance);

    event PoolReward(address pool, address rewarder, bool isBorrow, uint reward);

    event NewOLETokenDistribution(uint moreSupplyBorrowBalance, uint moreExtraBalance, uint128 updatePricePer, uint128 liquidatorMaxPer, uint16 liquidatorOLERatio, uint16 xoleRaiseRatio, uint128 xoleRaiseMinAmount);


}
interface ControllerInterface {

    function createLPoolPair(address tokenA, address tokenB, uint16 marginLimit, bytes memory dexData) external;


    function mintAllowed(address minter, uint lTokenAmount) external;

    function transferAllowed(address from, address to, uint lTokenAmount) external;

    function redeemAllowed(address redeemer, uint lTokenAmount) external;

    function borrowAllowed(address borrower, address payee, uint borrowAmount) external;

    function repayBorrowAllowed(address payer, address borrower, uint repayAmount, bool isEnd) external;

    function liquidateAllowed(uint marketId, address liquidator, uint liquidateAmount, bytes memory dexData) external;

    function marginTradeAllowed(uint marketId) external view returns (bool);

    function closeTradeAllowed(uint marketId) external view returns (bool);

    function updatePriceAllowed(uint marketId, address to) external;


    function setLPoolImplementation(address _lpoolImplementation) external;

    function setOpenLev(address _openlev) external;

    function setDexAggregator(DexAggregatorInterface _dexAggregator) external;

    function setInterestParam(uint256 _baseRatePerBlock, uint256 _multiplierPerBlock, uint256 _jumpMultiplierPerBlock, uint256 _kink) external;

    function setLPoolUnAllowed(address lpool, bool unAllowed) external;

    function setSuspend(bool suspend) external;

    function setSuspendAll(bool suspend) external;

    function setMarketSuspend(uint marketId, bool suspend) external;

    function setOleWethDexData(bytes memory _oleWethDexData) external;

    function setOLETokenDistribution(uint moreSupplyBorrowBalance, uint moreExtraBalance, uint128 updatePricePer, uint128 liquidatorMaxPer, uint16 liquidatorOLERatio, uint16 xoleRaiseRatio, uint128 xoleRaiseMinAmount) external;

    function distributeRewards2Pool(address pool, uint supplyAmount, uint borrowAmount, uint64 startTime, uint64 duration) external;

    function distributeRewards2PoolMore(address pool, uint supplyAmount, uint borrowAmount) external;

    function distributeExtraRewards2Markets(uint[] memory marketIds, bool isDistribution) external;


    function earned(LPoolInterface lpool, address account, bool isBorrow) external view returns (uint256);

    function getSupplyRewards(LPoolInterface[] calldata lpools, address account) external;

}// BUSL-1.1
pragma solidity ^0.7.6;

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
}// BUSL-1.1
pragma solidity 0.7.6;



abstract contract OpenLevStorage {
    using SafeMath for uint;
    using TransferHelper for IERC20;

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

    struct AddressConfig {
        DexAggregatorInterface dexAggregator;
        address controller;
        address wETH;
        address xOLE;
    }

    uint16 public numPairs;

    mapping(uint16 => Types.Market) public markets;

    mapping(address => mapping(uint16 => mapping(bool => Types.Trade))) public activeTrades;

    mapping(address => bool) public allowedDepositTokens;

    CalculateConfig public calculateConfig;

    AddressConfig public addressConfig;

    mapping(uint8 => bool) public supportDexs;

    mapping(address => uint) public totalHelds;

    mapping(uint16 => mapping(address => mapping(uint => uint24))) public taxes;

    event MarginTrade(
        address trader,
        uint16 marketId,
        bool longToken, // 0 => long token 0; 1 => long token 1;
        bool depositToken,
        uint deposited,
        uint borrowed,
        uint held,
        uint fees,
        uint token0Price,
        uint32 dex
    );

    event TradeClosed(
        address owner,
        uint16 marketId,
        bool longToken,
        bool depositToken,
        uint closeAmount,
        uint depositDecrease,
        uint depositReturn,
        uint fees,
        uint token0Price,
        uint32 dex
    );

    event Liquidation(
        address owner,
        uint16 marketId,
        bool longToken,
        bool depositToken,
        uint liquidationAmount,
        uint outstandingAmount,
        address liquidator,
        uint depositDecrease,
        uint depositReturn,
        uint fees,
        uint token0Price,
        uint penalty,
        uint32 dex
    );

    event NewAddressConfig(address controller, address dexAggregator);

    event NewCalculateConfig(
        uint16 defaultFeesRate,
        uint8 insuranceRatio,
        uint16 defaultMarginLimit,
        uint16 priceDiffientRatio,
        uint16 updatePriceDiscount,
        uint16 feesDiscount,
        uint128 feesDiscountThreshold,
        uint16 penaltyRatio,
        uint8 maxLiquidationPriceDiffientRatio,
        uint16 twapDuration);

    event NewMarketConfig(uint16 marketId, uint16 feesRate, uint32 marginLimit, uint16 priceDiffientRatio, uint32[] dexs);

    event ChangeAllowedDepositTokens(address[] token, bool allowed);

}

interface OpenLevInterface {

    function addMarket(
        LPoolInterface pool0,
        LPoolInterface pool1,
        uint16 marginLimit,
        bytes memory dexData
    ) external returns (uint16);


    function marginTrade(uint16 marketId, bool longToken, bool depositToken, uint deposit, uint borrow, uint minBuyAmount, bytes memory dexData) external payable;

    function closeTrade(uint16 marketId, bool longToken, uint closeAmount, uint minOrMaxAmount, bytes memory dexData) external;

    function liquidate(address owner, uint16 marketId, bool longToken, uint minBuy, uint maxAmount, bytes memory dexData) external;

    function marginRatio(address owner, uint16 marketId, bool longToken, bytes memory dexData) external view returns (uint current, uint cAvg, uint hAvg, uint32 limit);

    function updatePrice(uint16 marketId, bytes memory dexData) external;

    function shouldUpdatePrice(uint16 marketId, bytes memory dexData) external view returns (bool);

    function getMarketSupportDexs(uint16 marketId) external view returns (uint32[] memory);


    function setCalculateConfig(uint16 defaultFeesRate, uint8 insuranceRatio, uint16 defaultMarginLimit, uint16 priceDiffientRatio,
        uint16 updatePriceDiscount, uint16 feesDiscount, uint128 feesDiscountThreshold, uint16 penaltyRatio, uint8 maxLiquidationPriceDiffientRatio, uint16 twapDuration) external;

    function setAddressConfig(address controller, DexAggregatorInterface dexAggregator) external;

    function setMarketConfig(uint16 marketId, uint16 feesRate, uint16 marginLimit, uint16 priceDiffientRatio, uint32[] memory dexs) external;

    function moveInsurance(uint16 marketId, uint8 poolIndex, address to, uint amount) external;

    function setSupportDex(uint8 dex, bool support) external;

    function setTaxRate(uint16 marketId, address token, uint index, uint24 tax) external;

}// BUSL-1.1


pragma solidity 0.7.6;

abstract contract Adminable {
    address payable public admin;
    address payable public pendingAdmin;
    address payable public developer;

    event NewPendingAdmin(address oldPendingAdmin, address newPendingAdmin);

    event NewAdmin(address oldAdmin, address newAdmin);
    constructor () {
        developer = msg.sender;
    }

    modifier onlyAdmin() {
        require(msg.sender == admin, "caller must be admin");
        _;
    }
    modifier onlyAdminOrDeveloper() {
        require(msg.sender == admin || msg.sender == developer, "caller must be admin or developer");
        _;
    }

    function setPendingAdmin(address payable newPendingAdmin) external virtual onlyAdmin {
        address oldPendingAdmin = pendingAdmin;
        pendingAdmin = newPendingAdmin;
        emit NewPendingAdmin(oldPendingAdmin, newPendingAdmin);
    }

    function acceptAdmin() external virtual {
        require(msg.sender == pendingAdmin, "only pendingAdmin can accept admin");
        address oldAdmin = admin;
        address oldPendingAdmin = pendingAdmin;
        admin = pendingAdmin;
        pendingAdmin = address(0);
        emit NewAdmin(oldAdmin, admin);
        emit NewPendingAdmin(oldPendingAdmin, pendingAdmin);
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

interface IWETH {
    function deposit() external payable;

    function withdraw(uint256) external;
}pragma solidity 0.7.6;




library OpenLevV1Lib {
    using SafeMath for uint;
    using TransferHelper for IERC20;
    using DexData for bytes;

    struct PricesVar {
        uint current;
        uint cAvg;
        uint hAvg;
        uint price;
        uint cAvgPrice;
    }

    function addMarket(
        LPoolInterface pool0,
        LPoolInterface pool1,
        uint16 marginLimit,
        bytes memory dexData,
        uint16 marketId,
        mapping(uint16 => Types.Market) storage markets,
        OpenLevStorage.CalculateConfig storage config,
        OpenLevStorage.AddressConfig storage addressConfig,
        mapping(uint8 => bool) storage _supportDexs,
        mapping(uint16 => mapping(address => mapping(uint => uint24))) storage taxes
    ) external {
        address token0 = pool0.underlying();
        address token1 = pool1.underlying(); 
        uint8 dex = dexData.toDex();
        require(isSupportDex(_supportDexs, dex) && msg.sender == address(addressConfig.controller) && marginLimit >= config.defaultMarginLimit && marginLimit < 100000, "UDX");

        {
            uint24[] memory taxRates = dexData.toTransferFeeRates();
            require(taxRates[0] < 200000 && taxRates[1] < 200000 && taxRates[2] < 200000 && taxRates[3] < 200000 &&taxRates[4] < 200000 && taxRates[5] < 200000, "WTR" );
            taxes[marketId][token0][0]= taxRates[0];
            taxes[marketId][token1][0]= taxRates[1];
            taxes[marketId][token0][1]= taxRates[2];
            taxes[marketId][token1][1]= taxRates[3];
            taxes[marketId][token0][2]= taxRates[4];
            taxes[marketId][token1][2]= taxRates[5];
        }

        IERC20(token0).safeApprove(address(pool0), uint256(- 1));
        IERC20(token1).safeApprove(address(pool1), uint256(- 1));
        uint32[] memory dexs = new uint32[](1);
        dexs[0] = dexData.toDexDetail();
        markets[marketId] = Types.Market(pool0, pool1, token0, token1, marginLimit, config.defaultFeesRate, config.priceDiffientRatio, address(0), 0, 0, dexs);
        if (dexData.isUniV2Class()) {
            updatePriceInternal(token0, token1, dexData);
        } else if (dex == DexData.DEX_UNIV3) {
            addressConfig.dexAggregator.updateV3Observation(token0, token1, dexData);
        }
    }

    function setCalculateConfigInternal(
        uint16 defaultFeesRate,
        uint8 insuranceRatio,
        uint16 defaultMarginLimit,
        uint16 priceDiffientRatio,
        uint16 updatePriceDiscount,
        uint16 feesDiscount,
        uint128 feesDiscountThreshold,
        uint16 penaltyRatio,
        uint8 maxLiquidationPriceDiffientRatio,
        uint16 twapDuration,
        OpenLevStorage.CalculateConfig storage calculateConfig
    ) external {
        require(defaultFeesRate < 10000 && insuranceRatio < 100 && defaultMarginLimit > 0 && updatePriceDiscount <= 100
        && feesDiscount <= 100 && penaltyRatio < 10000 && twapDuration > 0, 'PRI');
        calculateConfig.defaultFeesRate = defaultFeesRate;
        calculateConfig.insuranceRatio = insuranceRatio;
        calculateConfig.defaultMarginLimit = defaultMarginLimit;
        calculateConfig.priceDiffientRatio = priceDiffientRatio;
        calculateConfig.updatePriceDiscount = updatePriceDiscount;
        calculateConfig.feesDiscount = feesDiscount;
        calculateConfig.feesDiscountThreshold = feesDiscountThreshold;
        calculateConfig.penaltyRatio = penaltyRatio;
        calculateConfig.maxLiquidationPriceDiffientRatio = maxLiquidationPriceDiffientRatio;
        calculateConfig.twapDuration = twapDuration;
    }

    function setAddressConfigInternal(
        address controller,
        DexAggregatorInterface dexAggregator,
        OpenLevStorage.AddressConfig storage addressConfig
    ) external {
        require(controller != address(0) && address(dexAggregator) != address(0), 'CD0');
        addressConfig.controller = controller;
        addressConfig.dexAggregator = dexAggregator;
    }

    function setMarketConfigInternal(
        uint16 feesRate,
        uint16 marginLimit,
        uint16 priceDiffientRatio,
        uint32[] memory dexs,
        Types.Market storage market
    ) external {
        require(feesRate < 10000 && marginLimit > 0 && dexs.length > 0, 'PRI');
        market.feesRate = feesRate;
        market.marginLimit = marginLimit;
        market.dexs = dexs;
        market.priceDiffientRatio = priceDiffientRatio;
    }

    function marginRatio(
        address owner,
        uint held,
        address heldToken,
        address sellToken,
        LPoolInterface borrowPool,
        bytes memory dexData
    ) external view returns (uint, uint, uint, uint, uint){
        return marginRatioPrivate(owner, held, heldToken, sellToken, borrowPool, false, dexData);
    }

    function marginRatioPrivate(
        address owner,
        uint held,
        address heldToken,
        address sellToken,
        LPoolInterface borrowPool,
        bool isOpen,
        bytes memory dexData
    ) private view returns (uint, uint, uint, uint, uint){
        Types.MarginRatioVars memory ratioVars;
        ratioVars.held = held;
        ratioVars.dexData = dexData;
        ratioVars.heldToken = heldToken;
        ratioVars.sellToken = sellToken;
        ratioVars.owner = owner;
        ratioVars.multiplier = 10000;

        (DexAggregatorInterface dexAggregator,,,) = OpenLevStorage(address(this)).addressConfig();
        (,,,,,,,,,uint16 twapDuration) = OpenLevStorage(address(this)).calculateConfig();

        uint borrowed = isOpen ? borrowPool.borrowBalanceStored(ratioVars.owner) : borrowPool.borrowBalanceCurrent(ratioVars.owner);
        if (borrowed == 0) {
            return (ratioVars.multiplier, ratioVars.multiplier, ratioVars.multiplier, ratioVars.multiplier, ratioVars.multiplier);
        }
        (ratioVars.price, ratioVars.cAvgPrice, ratioVars.hAvgPrice, ratioVars.decimals, ratioVars.lastUpdateTime) = dexAggregator.getPriceCAvgPriceHAvgPrice(ratioVars.heldToken, ratioVars.sellToken, twapDuration, ratioVars.dexData);
        if (block.timestamp > ratioVars.lastUpdateTime.add(twapDuration)) {
            ratioVars.hAvgPrice = ratioVars.cAvgPrice;
        }
        uint marketValue = ratioVars.held.mul(ratioVars.price).div(10 ** uint(ratioVars.decimals));
        uint current = marketValue >= borrowed ? marketValue.sub(borrowed).mul(ratioVars.multiplier).div(borrowed) : 0;
        marketValue = ratioVars.held.mul(ratioVars.cAvgPrice).div(10 ** uint(ratioVars.decimals));
        uint cAvg = marketValue >= borrowed ? marketValue.sub(borrowed).mul(ratioVars.multiplier).div(borrowed) : 0;
        marketValue = ratioVars.held.mul(ratioVars.hAvgPrice).div(10 ** uint(ratioVars.decimals));
        uint hAvg = marketValue >= borrowed ? marketValue.sub(borrowed).mul(ratioVars.multiplier).div(borrowed) : 0;
        return (current, cAvg, hAvg, ratioVars.price, ratioVars.cAvgPrice);
    }

    function isPositionHealthy(
        address owner,
        bool isOpen,
        uint amount,
        Types.MarketVars memory vars,
        bytes memory dexData
    ) external view returns (bool){
        PricesVar memory prices;
        (prices.current, prices.cAvg, prices.hAvg, prices.price, prices.cAvgPrice) = marginRatioPrivate(owner,
            amount,
            isOpen ? address(vars.buyToken) : address(vars.sellToken),
            isOpen ? address(vars.sellToken) : address(vars.buyToken),
            isOpen ? vars.sellPool : vars.buyPool,
            isOpen,
            dexData
        );

        (,,,,,,,,uint8 maxLiquidationPriceDiffientRatio,) = OpenLevStorage(address(this)).calculateConfig();
        if (isOpen) {
            return prices.current >= vars.marginLimit && prices.cAvg >= vars.marginLimit && prices.hAvg >= vars.marginLimit;
        } else {
            if (prices.price < prices.cAvgPrice) {
                uint differencePriceRatio = prices.cAvgPrice.mul(100).div(prices.price);
                require(differencePriceRatio - 100 < maxLiquidationPriceDiffientRatio, 'MPT');
            }
            return prices.current >= vars.marginLimit || prices.cAvg >= vars.marginLimit || prices.hAvg >= vars.marginLimit;
        }
    }

    function updatePriceInternal(address token0, address token1, bytes memory dexData) internal returns (bool){
        (DexAggregatorInterface dexAggregator,,,) = OpenLevStorage(address(this)).addressConfig();
        (,,,,,,,,,uint16 twapDuration) = OpenLevStorage(address(this)).calculateConfig();
        return dexAggregator.updatePriceOracle(token0, token1, twapDuration, dexData);
    }

    function shouldUpdatePriceInternal(DexAggregatorInterface dexAggregator, uint16 twapDuration, uint16 priceDiffientRatio, address token0, address token1, bytes memory dexData) public view returns (bool){
        if (!dexData.isUniV2Class()) {
            return false;
        }
        (, uint cAvgPrice, uint hAvgPrice,, uint lastUpdateTime) = dexAggregator.getPriceCAvgPriceHAvgPrice(token0, token1, twapDuration, dexData);
        if (block.timestamp < lastUpdateTime.add(twapDuration)) {
            return false;
        }
        if (cAvgPrice == 0 || hAvgPrice == 0) {
            return true;
        }
        uint one = 100;
        uint differencePriceRatio = cAvgPrice.mul(one).div(hAvgPrice);
        if (differencePriceRatio >= (one.add(priceDiffientRatio)) || differencePriceRatio <= (one.sub(priceDiffientRatio))) {
            return true;
        }
        return false;
    }

    function updatePrice(uint16 marketId, Types.Market storage market, OpenLevStorage.AddressConfig storage addressConfig,
        OpenLevStorage.CalculateConfig storage calculateConfig, bytes memory dexData) external {
        bool shouldUpdate = shouldUpdatePriceInternal(addressConfig.dexAggregator, calculateConfig.twapDuration, market.priceDiffientRatio, market.token1, market.token0, dexData);
        bool updateResult = updatePriceInternal(market.token0, market.token1, dexData);
        if (updateResult) {
            market.priceUpdater = msg.sender;
            if (shouldUpdate) {
                (ControllerInterface(addressConfig.controller)).updatePriceAllowed(marketId, msg.sender);
            }
        }
    }

    function transferIn(address from, IERC20 token, address weth, uint amount) external returns (uint) {
        if (address(token) == weth) {
            IWETH(weth).deposit{value : msg.value}();
            return msg.value;
        } else {
            return token.safeTransferFrom(from, address(this), amount);
        }
    }

    function doTransferOut(address to, IERC20 token, address weth, uint amount) external {
        if (address(token) == weth) {
            IWETH(weth).withdraw(amount);
            (bool success, ) = to.call{value: amount}("");
            require(success);
        } else {
            token.safeTransfer(to, amount);
        }
    }

    function isInSupportDex(uint32[] memory dexs, uint32 dex) internal pure returns (bool supported){
        for (uint i = 0; i < dexs.length; i++) {
            if (dexs[i] == 0) {
                break;
            }
            if (dexs[i] == dex) {
                supported = true;
                break;
            }
        }
    }

    function feeAndInsurance(
        address trader, 
        uint tradeSize, 
        address token, 
        address xOLE,
        uint totalHeld, 
        uint reserve,
        Types.Market storage  market, 
        mapping(address => uint) storage totalHelds,
        OpenLevStorage.CalculateConfig memory calculateConfig
    ) external returns (uint newFees) {
        uint defaultFees = tradeSize.mul(market.feesRate).div(10000);
        newFees = defaultFees;
        if (XOLEInterface(xOLE).balanceOf(trader) > calculateConfig.feesDiscountThreshold) {
            newFees = defaultFees.sub(defaultFees.mul(calculateConfig.feesDiscount).div(100));
        }
        if (market.priceUpdater == trader) {
            newFees = newFees.sub(defaultFees.mul(calculateConfig.updatePriceDiscount).div(100));
        }
        uint newInsurance = newFees.mul(calculateConfig.insuranceRatio).div(100);
        IERC20(token).safeTransfer(xOLE, newFees.sub(newInsurance));

        newInsurance = OpenLevV1Lib.amountToShare(newInsurance, totalHeld, reserve);
        if (token == market.token1) {
            market.pool1Insurance = market.pool1Insurance.add(newInsurance);
        } else {
            market.pool0Insurance = market.pool0Insurance.add(newInsurance);
        }

        totalHelds[token] = totalHelds[token].add(newInsurance);
        return newFees;
    }

    function reduceInsurance(
        uint totalRepayment, 
        uint remaining, 
        bool longToken, 
        address token, 
        uint reserve, 
        Types.Market storage  market, 
        mapping(address => uint
    ) storage totalHelds) external returns (uint maxCanRepayAmount) {
        uint needed = totalRepayment.sub(remaining);
        needed = amountToShare(needed, totalHelds[token], reserve);
        maxCanRepayAmount = totalRepayment;
        if (longToken) {
            if (market.pool0Insurance >= needed) {
                market.pool0Insurance = market.pool0Insurance - needed;
                totalHelds[token] = totalHelds[token].sub(needed);
            } else {
                maxCanRepayAmount = shareToAmount(market.pool0Insurance, totalHelds[token], reserve);
                maxCanRepayAmount = maxCanRepayAmount.add(remaining);
                totalHelds[token] = totalHelds[token].sub(market.pool0Insurance);
                market.pool0Insurance = 0;
            }
        } else {
            if (market.pool1Insurance >= needed) {
                market.pool1Insurance = market.pool1Insurance - needed;
            } else {
                maxCanRepayAmount = shareToAmount(market.pool1Insurance, totalHelds[token], reserve);
                maxCanRepayAmount = maxCanRepayAmount.add(remaining);
                totalHelds[token] = totalHelds[token].sub(market.pool1Insurance);
                market.pool1Insurance = 0;
            }
        }
    }  

    function moveInsurance(Types.Market storage market, uint8 poolIndex, address to, uint amount,  mapping(address => uint) storage totalHelds) external{
        if (poolIndex == 0) {
            market.pool0Insurance = market.pool0Insurance.sub(amount);
            (IERC20(market.token0)).safeTransfer(to, shareToAmount(amount, totalHelds[market.token0], IERC20(market.token0).balanceOf(address(this))));
        }else{
            market.pool1Insurance = market.pool1Insurance.sub(amount);
            (IERC20(market.token1)).safeTransfer(to, shareToAmount(amount, totalHelds[market.token1], IERC20(market.token1).balanceOf(address(this))));
        }
    }

    function updateLegacy(address[] calldata tokens, mapping(address => uint) storage totalHelds) external{
        for(uint i; i < tokens.length; i++){
            address token = tokens[i];
            uint balance = IERC20(token).balanceOf(address(this));
            if (totalHelds[token] == 0 && balance > 0){
                totalHelds[token] = balance;
            }
        }
    }

    function isSupportDex(mapping(uint8 => bool) storage _supportDexs, uint8 dex) internal view returns (bool){
        return _supportDexs[dex];
    }

    function amountToShare(uint amount, uint totalShare, uint reserve) internal pure returns (uint share){
        share = totalShare > 0 && reserve > 0 ? totalShare.mul(amount) / reserve : amount;
    }

    function shareToAmount(uint share, uint totalShare, uint reserve) internal pure returns (uint amount){
        if (totalShare > 0 && reserve > 0){
            amount = reserve.mul(share) / totalShare;
        }
    }

    function verifyTrade(Types.MarketVars memory vars, bool longToken, bool depositToken, uint deposit, uint borrow, bytes memory dexData, OpenLevStorage.AddressConfig memory addressConfig, Types.Trade memory trade) external view {
        address depositTokenAddr = depositToken == longToken ? address(vars.buyToken) : address(vars.sellToken);

        uint decimals = ERC20(depositTokenAddr).decimals();
        uint minimalDeposit = decimals > 4 ? 10 ** (decimals - 4) : 1;
        uint actualDeposit = depositTokenAddr == addressConfig.wETH ? msg.value : deposit;
        require(actualDeposit > minimalDeposit, "DTS");
        require(isInSupportDex(vars.dexs, dexData.toDexDetail()), "DNS");

        if (trade.lastBlockNum == 0) {
            require(borrow > 0, "BB0");
            return;
        } else {
            require(depositToken == trade.depositToken && trade.lastBlockNum != uint128(block.number), " DTS");
        }
    }
}