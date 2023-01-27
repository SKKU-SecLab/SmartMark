


pragma solidity >=0.6.0 <0.8.0;

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
}


pragma solidity >=0.5.7;
pragma experimental ABIEncoderV2;

library Account {

    enum Status {Normal, Liquid, Vapor}
    struct Info {
        address owner; // The address that owns the account
        uint256 number; // A nonce that allows a single address to control many accounts
    }
    struct Storage {
        mapping(uint256 => Types.Par) balances; // Mapping from marketId to principal
        Status status;
    }
}

library Actions {

    enum ActionType {
        Deposit, // supply tokens
        Withdraw, // borrow tokens
        Transfer, // transfer balance between accounts
        Buy, // buy an amount of some token (publicly)
        Sell, // sell an amount of some token (publicly)
        Trade, // trade tokens against another account
        Liquidate, // liquidate an undercollateralized or expiring account
        Vaporize, // use excess tokens to zero-out a completely negative account
        Call // send arbitrary data to an address
    }

    enum AccountLayout {OnePrimary, TwoPrimary, PrimaryAndSecondary}

    enum MarketLayout {ZeroMarkets, OneMarket, TwoMarkets}

    struct ActionArgs {
        ActionType actionType;
        uint256 accountId;
        Types.AssetAmount amount;
        uint256 primaryMarketId;
        uint256 secondaryMarketId;
        address otherAddress;
        uint256 otherAccountId;
        bytes data;
    }

    struct DepositArgs {
        Types.AssetAmount amount;
        Account.Info account;
        uint256 market;
        address from;
    }

    struct WithdrawArgs {
        Types.AssetAmount amount;
        Account.Info account;
        uint256 market;
        address to;
    }

    struct TransferArgs {
        Types.AssetAmount amount;
        Account.Info accountOne;
        Account.Info accountTwo;
        uint256 market;
    }

    struct BuyArgs {
        Types.AssetAmount amount;
        Account.Info account;
        uint256 makerMarket;
        uint256 takerMarket;
        address exchangeWrapper;
        bytes orderData;
    }

    struct SellArgs {
        Types.AssetAmount amount;
        Account.Info account;
        uint256 takerMarket;
        uint256 makerMarket;
        address exchangeWrapper;
        bytes orderData;
    }

    struct TradeArgs {
        Types.AssetAmount amount;
        Account.Info takerAccount;
        Account.Info makerAccount;
        uint256 inputMarket;
        uint256 outputMarket;
        address autoTrader;
        bytes tradeData;
    }

    struct LiquidateArgs {
        Types.AssetAmount amount;
        Account.Info solidAccount;
        Account.Info liquidAccount;
        uint256 owedMarket;
        uint256 heldMarket;
    }

    struct VaporizeArgs {
        Types.AssetAmount amount;
        Account.Info solidAccount;
        Account.Info vaporAccount;
        uint256 owedMarket;
        uint256 heldMarket;
    }

    struct CallArgs {
        Account.Info account;
        address callee;
        bytes data;
    }
}

library Decimal {

    struct D256 {
        uint256 value;
    }
}

library Interest {

    struct Rate {
        uint256 value;
    }

    struct Index {
        uint96 borrow;
        uint96 supply;
        uint32 lastUpdate;
    }
}

library Monetary {

    struct Price {
        uint256 value;
    }
    struct Value {
        uint256 value;
    }
}

library Storage {

    struct Market {
        address token;
        Types.TotalPar totalPar;
        Interest.Index index;
        address priceOracle;
        address interestSetter;
        Decimal.D256 marginPremium;
        Decimal.D256 spreadPremium;
        bool isClosing;
    }

    struct RiskParams {
        Decimal.D256 marginRatio;
        Decimal.D256 liquidationSpread;
        Decimal.D256 earningsRate;
        Monetary.Value minBorrowedValue;
    }

    struct RiskLimits {
        uint64 marginRatioMax;
        uint64 liquidationSpreadMax;
        uint64 earningsRateMax;
        uint64 marginPremiumMax;
        uint64 spreadPremiumMax;
        uint128 minBorrowedValueMax;
    }

    struct State {
        uint256 numMarkets;
        mapping(uint256 => Market) markets;
        mapping(address => mapping(uint256 => Account.Storage)) accounts;
        mapping(address => mapping(address => bool)) operators;
        mapping(address => bool) globalOperators;
        RiskParams riskParams;
        RiskLimits riskLimits;
    }
}

library Types {

    enum AssetDenomination {
        Wei, // the amount is denominated in wei
        Par // the amount is denominated in par
    }

    enum AssetReference {
        Delta, // the amount is given as a delta from the current value
        Target // the amount is given as an exact number to end up at
    }

    struct AssetAmount {
        bool sign; // true if positive
        AssetDenomination denomination;
        AssetReference ref;
        uint256 value;
    }

    struct TotalPar {
        uint128 borrow;
        uint128 supply;
    }

    struct Par {
        bool sign; // true if positive
        uint128 value;
    }

    struct Wei {
        bool sign; // true if positive
        uint256 value;
    }
}

abstract contract ISoloMargin {
    struct OperatorArg {
        address operator;
        bool trusted;
    }

    function ownerSetSpreadPremium(
        uint256 marketId,
        Decimal.D256 memory spreadPremium
    ) public virtual;

    function getIsGlobalOperator(address operator)
        public
        view
        virtual
        returns (bool);

    function getMarketTokenAddress(uint256 marketId)
        public
        view
        virtual
        returns (address);

    function ownerSetInterestSetter(uint256 marketId, address interestSetter)
        public
        virtual;

    function getAccountValues(Account.Info memory account)
        public
        view
        virtual
        returns (Monetary.Value memory, Monetary.Value memory);

    function getMarketPriceOracle(uint256 marketId)
        public
        view
        virtual
        returns (address);

    function getMarketInterestSetter(uint256 marketId)
        public
        view
        virtual
        returns (address);

    function getMarketSpreadPremium(uint256 marketId)
        public
        view
        virtual
        returns (Decimal.D256 memory);

    function getNumMarkets() public view virtual returns (uint256);

    function ownerWithdrawUnsupportedTokens(address token, address recipient)
        public
        virtual
        returns (uint256);

    function ownerSetMinBorrowedValue(Monetary.Value memory minBorrowedValue)
        public
        virtual;

    function ownerSetLiquidationSpread(Decimal.D256 memory spread)
        public
        virtual;

    function ownerSetEarningsRate(Decimal.D256 memory earningsRate)
        public
        virtual;

    function getIsLocalOperator(address owner, address operator)
        public
        view
        virtual
        returns (bool);

    function getAccountPar(Account.Info memory account, uint256 marketId)
        public
        view
        virtual
        returns (Types.Par memory);

    function ownerSetMarginPremium(
        uint256 marketId,
        Decimal.D256 memory marginPremium
    ) public virtual;

    function getMarginRatio() public view virtual returns (Decimal.D256 memory);

    function getMarketCurrentIndex(uint256 marketId)
        public
        view
        virtual
        returns (Interest.Index memory);

    function getMarketIsClosing(uint256 marketId)
        public
        view
        virtual
        returns (bool);

    function getRiskParams()
        public
        view
        virtual
        returns (Storage.RiskParams memory);

    function getAccountBalances(Account.Info memory account)
        public
        view
        virtual
        returns (
            address[] memory,
            Types.Par[] memory,
            Types.Wei[] memory
        );

    function renounceOwnership() public virtual;

    function getMinBorrowedValue()
        public
        view
        virtual
        returns (Monetary.Value memory);

    function setOperators(OperatorArg[] memory args) public virtual;

    function getMarketPrice(uint256 marketId)
        public
        view
        virtual
        returns (address);

    function owner() public view virtual returns (address);

    function isOwner() public view virtual returns (bool);

    function ownerWithdrawExcessTokens(uint256 marketId, address recipient)
        public
        virtual
        returns (uint256);

    function ownerAddMarket(
        address token,
        address priceOracle,
        address interestSetter,
        Decimal.D256 memory marginPremium,
        Decimal.D256 memory spreadPremium
    ) public virtual;

    function operate(
        Account.Info[] memory accounts,
        Actions.ActionArgs[] memory actions
    ) public virtual;

    function getMarketWithInfo(uint256 marketId)
        public
        view
        virtual
        returns (
            Storage.Market memory,
            Interest.Index memory,
            Monetary.Price memory,
            Interest.Rate memory
        );

    function ownerSetMarginRatio(Decimal.D256 memory ratio) public virtual;

    function getLiquidationSpread()
        public
        view
        virtual
        returns (Decimal.D256 memory);

    function getAccountWei(Account.Info memory account, uint256 marketId)
        public
        view
        virtual
        returns (Types.Wei memory);

    function getMarketTotalPar(uint256 marketId)
        public
        view
        virtual
        returns (Types.TotalPar memory);

    function getLiquidationSpreadForPair(
        uint256 heldMarketId,
        uint256 owedMarketId
    ) public view virtual returns (Decimal.D256 memory);

    function getNumExcessTokens(uint256 marketId)
        public
        view
        virtual
        returns (Types.Wei memory);

    function getMarketCachedIndex(uint256 marketId)
        public
        view
        virtual
        returns (Interest.Index memory);

    function getAccountStatus(Account.Info memory account)
        public
        view
        virtual
        returns (uint8);

    function getEarningsRate()
        public
        view
        virtual
        returns (Decimal.D256 memory);

    function ownerSetPriceOracle(uint256 marketId, address priceOracle)
        public
        virtual;

    function getRiskLimits()
        public
        view
        virtual
        returns (Storage.RiskLimits memory);

    function getMarket(uint256 marketId)
        public
        view
        virtual
        returns (Storage.Market memory);

    function ownerSetIsClosing(uint256 marketId, bool isClosing) public virtual;

    function ownerSetGlobalOperator(address operator, bool approved)
        public
        virtual;

    function transferOwnership(address newOwner) public virtual;

    function getAdjustedAccountValues(Account.Info memory account)
        public
        view
        virtual
        returns (Monetary.Value memory, Monetary.Value memory);

    function getMarketMarginPremium(uint256 marketId)
        public
        view
        virtual
        returns (Decimal.D256 memory);

    function getMarketInterestRate(uint256 marketId)
        public
        view
        virtual
        returns (Interest.Rate memory);
}


pragma solidity >=0.5.7;




contract DydxFlashloanBase {

    using SafeMath for uint256;


    function _getMarketIdFromTokenAddress(address _solo, address token)
        internal
        view
        returns (uint256)
    {

        ISoloMargin solo = ISoloMargin(_solo);

        uint256 numMarkets = solo.getNumMarkets();

        address curToken;
        for (uint256 i = 0; i < numMarkets; i++) {
            curToken = solo.getMarketTokenAddress(i);

            if (curToken == token) {
                return i;
            }
        }

        revert("No marketId found for provided token");
    }

    function _getRepaymentAmountInternal(uint256 amount)
        internal
        pure
        returns (uint256)
    {

        return amount.add(2);
    }

    function _getAccountInfo() internal view returns (Account.Info memory) {

        return Account.Info({owner: address(this), number: 1});
    }

    function _getWithdrawAction(uint256 marketId, uint256 amount)
        internal
        view
        returns (Actions.ActionArgs memory)
    {

        return
            Actions.ActionArgs({
                actionType: Actions.ActionType.Withdraw,
                accountId: 0,
                amount: Types.AssetAmount({
                    sign: false,
                    denomination: Types.AssetDenomination.Wei,
                    ref: Types.AssetReference.Delta,
                    value: amount
                }),
                primaryMarketId: marketId,
                secondaryMarketId: 0,
                otherAddress: address(this),
                otherAccountId: 0,
                data: ""
            });
    }

    function _getCallAction(bytes memory data)
        internal
        view
        returns (Actions.ActionArgs memory)
    {

        return
            Actions.ActionArgs({
                actionType: Actions.ActionType.Call,
                accountId: 0,
                amount: Types.AssetAmount({
                    sign: false,
                    denomination: Types.AssetDenomination.Wei,
                    ref: Types.AssetReference.Delta,
                    value: 0
                }),
                primaryMarketId: 0,
                secondaryMarketId: 0,
                otherAddress: address(this),
                otherAccountId: 0,
                data: data
            });
    }

    function _getDepositAction(uint256 marketId, uint256 amount)
        internal
        view
        returns (Actions.ActionArgs memory)
    {

        return
            Actions.ActionArgs({
                actionType: Actions.ActionType.Deposit,
                accountId: 0,
                amount: Types.AssetAmount({
                    sign: true,
                    denomination: Types.AssetDenomination.Wei,
                    ref: Types.AssetReference.Delta,
                    value: amount
                }),
                primaryMarketId: marketId,
                secondaryMarketId: 0,
                otherAddress: address(this),
                otherAccountId: 0,
                data: ""
            });
    }
}


pragma solidity >=0.5.7;


abstract contract ICallee {

    function callFunction(
        address sender,
        Account.Info memory accountInfo,
        bytes memory data
    ) public virtual;
}


pragma solidity >=0.4.21 <0.7.0;







contract FUCK is ICallee, DydxFlashloanBase {

    struct MyCustomData {
        address token;
        address pairAddress;
        uint256 repayAmount;
        uint256 lendProject;
        uint256[] dexList;
        address[] tokens;
    }

    address uniRouter = 0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D;
    address sushiRouter = 0xd9e1cE17f2641f24aE83637ab66a2cca9C378B9F;
    address soloAddress = 0x1E0447b19BB6EcFdAe1e4AE1694b0C3659614e4e;
    address manager;
    mapping(address => bool) public approvalList;
    mapping(address => uint256) public profitAll; // 累计每个erc20的套利
    mapping(address => mapping(address => uint256)) public profitAddress; // 累计每个地址的每个erc20的套利
    uint256 public percent = 300; // div 10000

    constructor() public {
        manager = msg.sender;
    }

    modifier isManager() {

        require(manager == msg.sender, "Not manager!");
        _;
    }

    function setManager(address _manager) public isManager {

        manager = _manager;
    }

    function setPercent(uint256 _percent) public isManager {

        percent = _percent;
    }

    function dydxLoan(
        address _token,
        uint256 _amount,
        uint256[] calldata _dexList,
        address[] calldata _tokens
    ) external {

        require(
            _dexList.length >= 2 && _dexList.length == _tokens.length,
            "Length inconsistency!"
        );
        approvalToken(_token);
        for (uint256 i = 0; i < _tokens.length; i++) {
            approvalToken(_tokens[i]);
        }
        ISoloMargin solo = ISoloMargin(soloAddress);
        uint256 marketId = _getMarketIdFromTokenAddress(soloAddress, _token);
        uint256 repayAmount = _getRepaymentAmountInternal(_amount);
        Actions.ActionArgs[] memory operations = new Actions.ActionArgs[](3);
        operations[0] = _getWithdrawAction(marketId, _amount);
        operations[1] = _getCallAction(
            abi.encode(
                MyCustomData({
                    token: _token,
                    pairAddress: address(0),
                    repayAmount: repayAmount,
                    lendProject: uint256(0),
                    dexList: _dexList,
                    tokens: _tokens
                })
            )
        );
        operations[2] = _getDepositAction(marketId, repayAmount);
        Account.Info[] memory accountInfos = new Account.Info[](1);
        accountInfos[0] = _getAccountInfo();
        solo.operate(accountInfos, operations);
    }

    function uniLoan(
        address _token,
        address pairAddress,
        uint256 lendProject,
        uint256 _amount,
        uint256[] calldata _dexList,
        address[] calldata _tokens
    ) external {

        require(
            _dexList.length >= 2 && _dexList.length == _tokens.length,
            "Length inconsistency!"
        );
        approvalToken(_token);
        for (uint256 i = 0; i < _tokens.length; i++) {
            approvalToken(_tokens[i]);
        }
        uint256 _amount0 = 0;
        uint256 _amount1 = 0;
        if (IUniswapV2Pair(pairAddress).token0() == _token) {
            _amount0 = _amount;
        } else {
            _amount1 = _amount;
        }

        bytes memory data =
            abi.encode(
                MyCustomData({
                    token: _token,
                    pairAddress: pairAddress,
                    repayAmount: uint256(0),
                    lendProject: lendProject,
                    dexList: _dexList,
                    tokens: _tokens
                })
            );
        IUniswapV2Pair(pairAddress).swap(
            _amount0,
            _amount1,
            address(this),
            data
        );
    }

    function callFunction(
        address sender,
        Account.Info memory account,
        bytes memory data
    ) public override {

        MyCustomData memory mcd = abi.decode(data, (MyCustomData));

        address[] memory path = new address[](2);
        uint256[] memory amounts;
        address _lendToken = address(mcd.token);
        uint256 _repayAmount = mcd.repayAmount.sub(2);
        for (uint256 i = 0; i < mcd.dexList.length; i++) {
            path[0] = address(_lendToken);
            path[1] = address(mcd.tokens[i]);

            if (mcd.dexList[i] == 1) {
                amounts = IUniswapV2Router01(uniRouter)
                    .swapExactTokensForTokens(
                    _repayAmount,
                    0,
                    path,
                    address(this),
                    now + 1800
                );
            }
            if (mcd.dexList[i] == 2) {
                amounts = IUniswapV2Router01(sushiRouter)
                    .swapExactTokensForTokens(
                    _repayAmount,
                    0,
                    path,
                    address(this),
                    now + 1800
                );
            }
            _lendToken = address(mcd.tokens[i]);
            _repayAmount = amounts[1];
        }

        uint256 newBal = IERC20(mcd.token).balanceOf(address(this));

        require(
            newBal > mcd.repayAmount,
            "Not enough funds to repay dydx loan!"
        );

        uint256 profit = newBal - mcd.repayAmount;
        uint256 transferAmount = (profit * (10000 - percent)) / 10000;
        (bool success, bytes memory result) =
            mcd.token.call(
                abi.encodeWithSelector(0xa9059cbb, tx.origin, transferAmount)
            );
        require(
            success && (result.length == 0 || abi.decode(result, (bool))),
            "Failed to transfer to sender!"
        );
        profitAll[mcd.token] += profit;
        profitAddress[tx.origin][mcd.token] += profit;
        if (profit > transferAmount) {
            IERC20(mcd.token).transfer(manager, profit - transferAmount);
        }
    }

    function uniswapV2Call(
        address account,
        uint256 amount0,
        uint256 amount1,
        bytes memory data
    ) public {

        MyCustomData memory mcd = abi.decode(data, (MyCustomData));

        address[] memory path = new address[](2);
        uint256[] memory amounts;
        address _lendToken = address(mcd.token);
        uint256 swapResult = IERC20(mcd.token).balanceOf(address(this));
        for (uint256 i = 0; i < mcd.dexList.length; i++) {
            path[0] = address(_lendToken);
            path[1] = address(mcd.tokens[i]);
            if (mcd.dexList[i] == 1) {
                amounts = IUniswapV2Router01(uniRouter)
                    .swapExactTokensForTokens(
                    swapResult,
                    0,
                    path,
                    address(this),
                    now + 1800
                );
            }
            if (mcd.dexList[i] == 2) {
                amounts = IUniswapV2Router01(sushiRouter)
                    .swapExactTokensForTokens(
                    swapResult,
                    0,
                    path,
                    address(this),
                    now + 1800
                );
            }
            _lendToken = address(mcd.tokens[i]);
            swapResult = amounts[1];
        }

        uint256 reply = 0;
        if (mcd.lendProject == 1) {
            path[0] = address(mcd.tokens[mcd.tokens.length - 1]);
            path[1] = address(mcd.token);
            amounts = IUniswapV2Router01(uniRouter).getAmountsIn(
                amount0 > 0 ? amount0 : amount1,
                path
            );
            reply = amounts[0];
        } else if (mcd.lendProject == 2) {
            path[0] = address(mcd.tokens[mcd.tokens.length - 1]);
            path[1] = address(mcd.token);
            amounts = IUniswapV2Router01(sushiRouter).getAmountsIn(
                amount0 > 0 ? amount0 : amount1,
                path
            );
            reply = amounts[0];
        }

        uint256 newBal =
            IERC20(mcd.tokens[mcd.tokens.length - 1]).balanceOf(address(this));

        require(
            newBal > reply,
            "Not enough funds to repay uniswap or sushiswap!"
        );

        IERC20(mcd.tokens[mcd.tokens.length - 1]).transfer(
            mcd.pairAddress,
            reply
        );
        uint256 profit = newBal - reply;
        uint256 transferAmount = (profit * (10000 - percent)) / 10000;
        (bool success, bytes memory result) =
            address(mcd.tokens[mcd.tokens.length - 1]).call(
                abi.encodeWithSelector(0xa9059cbb, tx.origin, transferAmount)
            );
        require(
            success && (result.length == 0 || abi.decode(result, (bool))),
            "Failed to transfer to sender!"
        );

        profitAll[mcd.tokens[mcd.tokens.length - 1]] += profit;
        profitAddress[tx.origin][mcd.tokens[mcd.tokens.length - 1]] += profit;
        if (profit > transferAmount) {
            IERC20(mcd.tokens[mcd.tokens.length - 1]).transfer(
                manager,
                profit - transferAmount
            );
        }
    }

    function calculate(
        address lendToken,
        uint256 lendNumber,
        uint256 lendProject,
        uint256[] memory dexList,
        address[] memory tokens
    ) public view returns (uint256 swapResult, uint256 reply) {

        require(
            dexList.length >= 2 && dexList.length == tokens.length,
            "Length inconsistency!"
        );
        address[] memory path = new address[](2);
        uint256[] memory amounts;
        address _lendToken = address(lendToken);
        swapResult = lendNumber;
        for (uint256 i = 0; i < dexList.length; i++) {
            path[0] = address(_lendToken);
            path[1] = address(tokens[i]);
            if (dexList[i] == 1) {
                amounts = IUniswapV2Router01(uniRouter).getAmountsOut(
                    swapResult,
                    path
                );
            } else if (dexList[i] == 2) {
                amounts = IUniswapV2Router01(sushiRouter).getAmountsOut(
                    swapResult,
                    path
                );
            } else {
                require(false, "Not the DEX id!");
            }
            _lendToken = tokens[i];
            swapResult = amounts[1];
        }
        reply = lendNumber; // 需要还的数量
        if (lendToken != _lendToken) {
            path[0] = lendToken;
            path[1] = _lendToken;
            if (lendProject == 1) {
                amounts = IUniswapV2Router01(uniRouter).getAmountsOut(
                    lendNumber,
                    path
                );
                reply = amounts[1];
            } else if (lendProject == 2) {
                amounts = IUniswapV2Router01(sushiRouter).getAmountsOut(
                    lendNumber,
                    path
                );
                reply = amounts[1];
            }
        }
    }

    function approvalToken(address _token) public {

        if (!approvalList[_token]) {
            address[] memory adds = new address[](3);
            adds[0] = uniRouter;
            adds[1] = sushiRouter;
            adds[2] = soloAddress;
            for (uint256 i = 0; i < adds.length; i++) {
                (bool success, bytes memory data) =
                    _token.call(
                        abi.encodeWithSelector(0x095ea7b3, adds[i], uint256(-1))
                    );
                require(
                    success && (data.length == 0 || abi.decode(data, (bool))),
                    "Approval of failure!"
                );
            }
            approvalList[_token] = true;
        }
    }
}

interface IUniswapV2Router01 {

    function swapExactTokensForTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);


    function getAmountsOut(uint256 amountIn, address[] calldata path)
        external
        view
        returns (uint256[] memory amounts);


    function getAmountsIn(uint256 amountOut, address[] calldata path)
        external
        view
        returns (uint256[] memory amounts);

}

interface IUniswapV2Pair {

    function swap(
        uint256 amount0Out,
        uint256 amount1Out,
        address to,
        bytes calldata data
    ) external;


    function token0() external view returns (address);

}