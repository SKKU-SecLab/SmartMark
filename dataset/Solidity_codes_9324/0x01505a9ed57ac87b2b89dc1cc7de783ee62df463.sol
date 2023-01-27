

pragma solidity 0.6.9;
pragma experimental ABIEncoderV2;

library Types {

    enum RStatus {ONE, ABOVE_ONE, BELOW_ONE}
}

interface IERC20 {

    function totalSupply() external view returns (uint256);


    function decimals() external view returns (uint8);


    function name() external view returns (string memory);


    function balanceOf(address account) external view returns (uint256);


    function transfer(address recipient, uint256 amount) external returns (bool);


    function allowance(address owner, address spender) external view returns (uint256);


    function approve(address spender, uint256 amount) external returns (bool);


    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

}

contract InitializableOwnable {

    address public _OWNER_;
    address public _NEW_OWNER_;


    event OwnershipTransferPrepared(address indexed previousOwner, address indexed newOwner);

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);


    modifier onlyOwner() {

        require(msg.sender == _OWNER_, "NOT_OWNER");
        _;
    }


    function transferOwnership(address newOwner) external onlyOwner {

        require(newOwner != address(0), "INVALID_OWNER");
        emit OwnershipTransferPrepared(_OWNER_, newOwner);
        _NEW_OWNER_ = newOwner;
    }

    function claimOwnership() external {

        require(msg.sender == _NEW_OWNER_, "INVALID_CLAIM");
        emit OwnershipTransferred(_OWNER_, _NEW_OWNER_);
        _OWNER_ = _NEW_OWNER_;
        _NEW_OWNER_ = address(0);
    }
}

library SafeMath {

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {

        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "MUL_ERROR");

        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b > 0, "DIVIDING_ERROR");
        return a / b;
    }

    function divCeil(uint256 a, uint256 b) internal pure returns (uint256) {

        uint256 quotient = div(a, b);
        uint256 remainder = a - quotient * b;
        if (remainder > 0) {
            return quotient + 1;
        } else {
            return quotient;
        }
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b <= a, "SUB_ERROR");
        return a - b;
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {

        uint256 c = a + b;
        require(c >= a, "ADD_ERROR");
        return c;
    }

    function sqrt(uint256 x) internal pure returns (uint256 y) {

        uint256 z = x / 2 + 1;
        y = x;
        while (z < y) {
            y = z;
            z = (x / z + z) / 2;
        }
    }
}

library DecimalMath {

    using SafeMath for uint256;

    uint256 constant ONE = 10**18;
    uint256 constant STEP = 3921568627450980; // ONE/255
    function mul(uint256 target, uint256 d) internal pure returns (uint256) {

        return target.mul(d) / ONE;
    }

    function mulCeil(uint256 target, uint256 d) internal pure returns (uint256) {

        return target.mul(d).divCeil(ONE);
    }

    function divFloor(uint256 target, uint256 d) internal pure returns (uint256) {

        return target.mul(ONE).div(d);
    }

    function divCeil(uint256 target, uint256 d) internal pure returns (uint256) {

        return target.mul(ONE).divCeil(d);
    }
}

contract ReentrancyGuard {

    bool private _ENTERED_;

    modifier preventReentrant() {

        require(!_ENTERED_, "REENTRANT");
        _ENTERED_ = true;
        _;
        _ENTERED_ = false;
    }
}

interface IChargeCallee {

    function ChargeCall(
        bool isBuyBaseToken,
        uint256 baseAmount,
        uint256 quoteAmount,
        bytes calldata data
    ) external;

}

interface IOracle {

    function getChainlinkPrice() external view returns (uint256, uint256);

    function getUniswapPrice (address pair) external view returns (uint256, uint256, uint256, uint32); 
    function getPrice() external view returns (uint256, uint8);

}

interface IChargeLpToken {

    function mint(address user, uint256 value) external;


    function burn(address user, uint256 value) external;


    function balanceOf(address owner) external view returns (uint256);


    function totalSupply() external view returns (uint256);

}


contract Storage is InitializableOwnable, ReentrancyGuard {

    using SafeMath for uint256;


    bool internal _INITIALIZED_;
    bool public _CLOSED_;
    bool public _DEPOSIT_QUOTE_ALLOWED_;
    bool public _DEPOSIT_BASE_ALLOWED_;
    bool public _TRADE_ALLOWED_;
    uint256 public _GAS_PRICE_LIMIT_;

    bool public _BUYING_ALLOWED_;
    bool public _SELLING_ALLOWED_;
    uint256 public _BASE_BALANCE_LIMIT_;
    uint256 public _QUOTE_BALANCE_LIMIT_;


    address public _SUPERVISOR_; // could freeze system in emergency
    address public _MAINTAINER_; // collect maintainer fee to buy food for Charge

    address public _BASE_TOKEN_;
    address public _QUOTE_TOKEN_;
    address public _ORACLE_;


    uint256 public _LP_FEE_RATE_;
    uint256 public _MT_FEE_RATE_;
    uint256 public _K_;
    uint256 public _K_CONFIG_;

    Types.RStatus public _R_STATUS_;
    uint256 public _TARGET_BASE_TOKEN_AMOUNT_;
    uint256 public _TARGET_QUOTE_TOKEN_AMOUNT_;
    uint256 public _BASE_BALANCE_;
    uint256 public _QUOTE_BALANCE_;

    address public _BASE_CAPITAL_TOKEN_;
    address public _QUOTE_CAPITAL_TOKEN_;


    uint256 public _BASE_CAPITAL_RECEIVE_QUOTE_;
    uint256 public _QUOTE_CAPITAL_RECEIVE_BASE_;
    mapping(address => bool) public _CLAIMED_;


    modifier onlySupervisorOrOwner() {

        require(msg.sender == _SUPERVISOR_ || msg.sender == _OWNER_, "NOT_SUPERVISOR_OR_OWNER");
        _;
    }

    modifier notClosed() {

        require(!_CLOSED_, "Charge_CLOSED");
        _;
    }


    function _checkChargeParameters() internal view returns (uint256) {

        require(_K_ < DecimalMath.ONE, "K>=1");
        require(_K_ > 0, "K=0");
        require(_LP_FEE_RATE_.add(_MT_FEE_RATE_) < DecimalMath.ONE, "FEE_RATE>=1");
    }

    function getOraclePrice() public returns (uint256) {

        (uint256 price, uint8 deviation) = IOracle(_ORACLE_).getPrice();
        uint256 k = deviation * DecimalMath.STEP; 
        if (k < _K_CONFIG_) {
            _K_ = _K_CONFIG_;
        } else {
            _K_ = k;
        }
        return price;
    }

    function readOraclePrice() public view returns (uint256) {

        (uint256 price, ) = IOracle(_ORACLE_).getPrice();
        return price;
    }

    function getBaseCapitalBalanceOf(address lp) public view returns (uint256) {

        return IChargeLpToken(_BASE_CAPITAL_TOKEN_).balanceOf(lp);
    }

    function getTotalBaseCapital() public view returns (uint256) {

        return IChargeLpToken(_BASE_CAPITAL_TOKEN_).totalSupply();
    }

    function getQuoteCapitalBalanceOf(address lp) public view returns (uint256) {

        return IChargeLpToken(_QUOTE_CAPITAL_TOKEN_).balanceOf(lp);
    }

    function getTotalQuoteCapital() public view returns (uint256) {

        return IChargeLpToken(_QUOTE_CAPITAL_TOKEN_).totalSupply();
    }

    function version() external pure returns (uint256) {

        return 101; // 1.0.1
    }
}


library ChargeMath {

    using SafeMath for uint256;

    function _GeneralIntegrate(
        uint256 V0,
        uint256 V1,
        uint256 V2,
        uint256 i,
        uint256 k
    ) internal pure returns (uint256) {

        uint256 fairAmount = DecimalMath.mul(i, V1.sub(V2)); // i*delta
        uint256 V0V0V1V2 = DecimalMath.divCeil(V0.mul(V0).div(V1), V2);
        uint256 penalty = DecimalMath.mul(k, V0V0V1V2); // k(V0^2/V1/V2)
        return DecimalMath.mul(fairAmount, DecimalMath.ONE.sub(k).add(penalty));
    }

    function _SolveQuadraticFunctionForTrade(
        uint256 Q0,
        uint256 Q1,
        uint256 ideltaB,
        bool deltaBSig,
        uint256 k
    ) internal pure returns (uint256) {

        uint256 kQ02Q1 = DecimalMath.mul(k, Q0).mul(Q0).div(Q1); // kQ0^2/Q1
        uint256 b = DecimalMath.mul(DecimalMath.ONE.sub(k), Q1); // (1-k)Q1
        bool minusbSig = true;
        if (deltaBSig) {
            b = b.add(ideltaB); // (1-k)Q1+i*deltaB
        } else {
            kQ02Q1 = kQ02Q1.add(ideltaB); // i*deltaB+kQ0^2/Q1
        }
        if (b >= kQ02Q1) {
            b = b.sub(kQ02Q1);
            minusbSig = true;
        } else {
            b = kQ02Q1.sub(b);
            minusbSig = false;
        }

        uint256 squareRoot = DecimalMath.mul(
            DecimalMath.ONE.sub(k).mul(4),
            DecimalMath.mul(k, Q0).mul(Q0)
        ); // 4(1-k)kQ0^2
        squareRoot = b.mul(b).add(squareRoot).sqrt(); // sqrt(b*b+4(1-k)kQ0*Q0)

        uint256 denominator = DecimalMath.ONE.sub(k).mul(2); // 2(1-k)
        uint256 numerator;
        if (minusbSig) {
            numerator = b.add(squareRoot);
        } else {
            numerator = squareRoot.sub(b);
        }

        if (deltaBSig) {
            return DecimalMath.divFloor(numerator, denominator);
        } else {
            return DecimalMath.divCeil(numerator, denominator);
        }
    }

    function _SolveQuadraticFunctionForTarget(
        uint256 V1,
        uint256 k,
        uint256 fairAmount
    ) internal pure returns (uint256 V0) {

        uint256 sqrt = DecimalMath.divCeil(DecimalMath.mul(k, fairAmount).mul(4), V1);
        sqrt = sqrt.add(DecimalMath.ONE).mul(DecimalMath.ONE).sqrt();
        uint256 premium = DecimalMath.divCeil(sqrt.sub(DecimalMath.ONE), k.mul(2));
        return DecimalMath.mul(V1, DecimalMath.ONE.add(premium));
    }
}

contract Pricing is Storage {

    using SafeMath for uint256;


    function _ROneSellBaseToken(uint256 amount, uint256 targetQuoteTokenAmount)
        internal
        view
        returns (uint256 receiveQuoteToken)
    {

        uint256 i = readOraclePrice();
        uint256 Q2 = ChargeMath._SolveQuadraticFunctionForTrade(
            targetQuoteTokenAmount,
            targetQuoteTokenAmount,
            DecimalMath.mul(i, amount),
            false,
            _K_
        );
        return targetQuoteTokenAmount.sub(Q2);
    }

    function _ROneBuyBaseToken(uint256 amount, uint256 targetBaseTokenAmount)
        internal
        view
        returns (uint256 payQuoteToken)
    {

        require(amount < targetBaseTokenAmount, "Charge_BASE_BALANCE_NOT_ENOUGH");
        uint256 B2 = targetBaseTokenAmount.sub(amount);
        payQuoteToken = _RAboveIntegrate(targetBaseTokenAmount, targetBaseTokenAmount, B2);
        return payQuoteToken;
    }


    function _RBelowSellBaseToken(
        uint256 amount,
        uint256 quoteBalance,
        uint256 targetQuoteAmount
    ) internal view returns (uint256 receieQuoteToken) {

        uint256 i = readOraclePrice();
        uint256 Q2 = ChargeMath._SolveQuadraticFunctionForTrade(
            targetQuoteAmount,
            quoteBalance,
            DecimalMath.mul(i, amount),
            false,
            _K_
        );
        return quoteBalance.sub(Q2);
    }

    function _RBelowBuyBaseToken(
        uint256 amount,
        uint256 quoteBalance,
        uint256 targetQuoteAmount
    ) internal view returns (uint256 payQuoteToken) {

        uint256 i = readOraclePrice();
        uint256 Q2 = ChargeMath._SolveQuadraticFunctionForTrade(
            targetQuoteAmount,
            quoteBalance,
            DecimalMath.mulCeil(i, amount),
            true,
            _K_
        );
        return Q2.sub(quoteBalance);
    }

    function _RBelowBackToOne() internal view returns (uint256 payQuoteToken) {

        uint256 spareBase = _BASE_BALANCE_.sub(_TARGET_BASE_TOKEN_AMOUNT_);
        uint256 price = readOraclePrice();
        uint256 fairAmount = DecimalMath.mul(spareBase, price);
        uint256 newTargetQuote = ChargeMath._SolveQuadraticFunctionForTarget(
            _QUOTE_BALANCE_,
            _K_,
            fairAmount
        );
        return newTargetQuote.sub(_QUOTE_BALANCE_);
    }


    function _RAboveBuyBaseToken(
        uint256 amount,
        uint256 baseBalance,
        uint256 targetBaseAmount
    ) internal view returns (uint256 payQuoteToken) {

        require(amount < baseBalance, "Charge_BASE_BALANCE_NOT_ENOUGH");
        uint256 B2 = baseBalance.sub(amount);
        return _RAboveIntegrate(targetBaseAmount, baseBalance, B2);
    }

    function _RAboveSellBaseToken(
        uint256 amount,
        uint256 baseBalance,
        uint256 targetBaseAmount
    ) internal view returns (uint256 receiveQuoteToken) {

        uint256 B1 = baseBalance.add(amount);
        return _RAboveIntegrate(targetBaseAmount, B1, baseBalance);
    }

    function _RAboveBackToOne() internal view returns (uint256 payBaseToken) {

        uint256 spareQuote = _QUOTE_BALANCE_.sub(_TARGET_QUOTE_TOKEN_AMOUNT_);
        uint256 price = readOraclePrice();
        uint256 fairAmount = DecimalMath.divFloor(spareQuote, price);
        uint256 newTargetBase = ChargeMath._SolveQuadraticFunctionForTarget(
            _BASE_BALANCE_,
            _K_,
            fairAmount
        );
        return newTargetBase.sub(_BASE_BALANCE_);
    }


    function getExpectedTarget() public view returns (uint256 baseTarget, uint256 quoteTarget) {

        uint256 Q = _QUOTE_BALANCE_;
        uint256 B = _BASE_BALANCE_;
        if (_R_STATUS_ == Types.RStatus.ONE) {
            return (_TARGET_BASE_TOKEN_AMOUNT_, _TARGET_QUOTE_TOKEN_AMOUNT_);
        } else if (_R_STATUS_ == Types.RStatus.BELOW_ONE) {
            uint256 payQuoteToken = _RBelowBackToOne();
            return (_TARGET_BASE_TOKEN_AMOUNT_, Q.add(payQuoteToken));
        } else if (_R_STATUS_ == Types.RStatus.ABOVE_ONE) {
            uint256 payBaseToken = _RAboveBackToOne();
            return (B.add(payBaseToken), _TARGET_QUOTE_TOKEN_AMOUNT_);
        }
    }

    function getMidPrice() public view returns (uint256 midPrice) {

        (uint256 baseTarget, uint256 quoteTarget) = getExpectedTarget();
        if (_R_STATUS_ == Types.RStatus.BELOW_ONE) {
            uint256 R = DecimalMath.divFloor(
                quoteTarget.mul(quoteTarget).div(_QUOTE_BALANCE_),
                _QUOTE_BALANCE_
            );
            R = DecimalMath.ONE.sub(_K_).add(DecimalMath.mul(_K_, R));
            return DecimalMath.divFloor(readOraclePrice(), R);
        } else {
            uint256 R = DecimalMath.divFloor(
                baseTarget.mul(baseTarget).div(_BASE_BALANCE_),
                _BASE_BALANCE_
            );
            R = DecimalMath.ONE.sub(_K_).add(DecimalMath.mul(_K_, R));
            return DecimalMath.mul(readOraclePrice(), R);
        }
    }

    function _RAboveIntegrate(
        uint256 B0,
        uint256 B1,
        uint256 B2
    ) internal view returns (uint256) {

        uint256 i = readOraclePrice();
        return ChargeMath._GeneralIntegrate(B0, B1, B2, i, _K_);
    }

}

library SafeERC20 {

    using SafeMath for uint256;

    function safeTransfer(
        IERC20 token,
        address to,
        uint256 value
    ) internal {

        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(
        IERC20 token,
        address from,
        address to,
        uint256 value
    ) internal {

        _callOptionalReturn(
            token,
            abi.encodeWithSelector(token.transferFrom.selector, from, to, value)
        );
    }

    function safeApprove(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {

        require(
            (value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function _callOptionalReturn(IERC20 token, bytes memory data) private {



        (bool success, bytes memory returndata) = address(token).call(data);
        require(success, "SafeERC20: low-level call failed");

        if (returndata.length > 0) {
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}

contract Settlement is Storage {

    using SafeMath for uint256;
    using SafeERC20 for IERC20;


    event Donate(uint256 amount, bool isBaseToken);

    event ClaimAssets(address indexed user, uint256 baseTokenAmount, uint256 quoteTokenAmount);


    function _baseTokenTransferIn(address from, uint256 amount) internal {

        require(_BASE_BALANCE_.add(amount) <= _BASE_BALANCE_LIMIT_, "BASE_BALANCE_LIMIT_EXCEEDED");
        IERC20(_BASE_TOKEN_).safeTransferFrom(from, address(this), amount);
        _BASE_BALANCE_ = _BASE_BALANCE_.add(amount);
    }

    function _quoteTokenTransferIn(address from, uint256 amount) internal {

        require(
            _QUOTE_BALANCE_.add(amount) <= _QUOTE_BALANCE_LIMIT_,
            "QUOTE_BALANCE_LIMIT_EXCEEDED"
        );
        IERC20(_QUOTE_TOKEN_).safeTransferFrom(from, address(this), amount);
        _QUOTE_BALANCE_ = _QUOTE_BALANCE_.add(amount);
    }

    function _baseTokenTransferOut(address to, uint256 amount) internal {

        IERC20(_BASE_TOKEN_).safeTransfer(to, amount);
        _BASE_BALANCE_ = _BASE_BALANCE_.sub(amount);
    }

    function _quoteTokenTransferOut(address to, uint256 amount) internal {

        IERC20(_QUOTE_TOKEN_).safeTransfer(to, amount);
        _QUOTE_BALANCE_ = _QUOTE_BALANCE_.sub(amount);
    }


    function _donateBaseToken(uint256 amount) internal {

        _TARGET_BASE_TOKEN_AMOUNT_ = _TARGET_BASE_TOKEN_AMOUNT_.add(amount);
        emit Donate(amount, true);
    }

    function _donateQuoteToken(uint256 amount) internal {

        _TARGET_QUOTE_TOKEN_AMOUNT_ = _TARGET_QUOTE_TOKEN_AMOUNT_.add(amount);
        emit Donate(amount, false);
    }

    function donateBaseToken(uint256 amount) external preventReentrant {

        _baseTokenTransferIn(msg.sender, amount);
        _donateBaseToken(amount);
    }

    function donateQuoteToken(uint256 amount) external preventReentrant {

        _quoteTokenTransferIn(msg.sender, amount);
        _donateQuoteToken(amount);
    }


    function finalSettlement() external onlyOwner notClosed {

        _CLOSED_ = true;
        _DEPOSIT_QUOTE_ALLOWED_ = false;
        _DEPOSIT_BASE_ALLOWED_ = false;
        _TRADE_ALLOWED_ = false;
        uint256 totalBaseCapital = getTotalBaseCapital();
        uint256 totalQuoteCapital = getTotalQuoteCapital();

        if (_QUOTE_BALANCE_ > _TARGET_QUOTE_TOKEN_AMOUNT_) {
            uint256 spareQuote = _QUOTE_BALANCE_.sub(_TARGET_QUOTE_TOKEN_AMOUNT_);
            _BASE_CAPITAL_RECEIVE_QUOTE_ = DecimalMath.divFloor(spareQuote, totalBaseCapital);
        } else {
            _TARGET_QUOTE_TOKEN_AMOUNT_ = _QUOTE_BALANCE_;
        }

        if (_BASE_BALANCE_ > _TARGET_BASE_TOKEN_AMOUNT_) {
            uint256 spareBase = _BASE_BALANCE_.sub(_TARGET_BASE_TOKEN_AMOUNT_);
            _QUOTE_CAPITAL_RECEIVE_BASE_ = DecimalMath.divFloor(spareBase, totalQuoteCapital);
        } else {
            _TARGET_BASE_TOKEN_AMOUNT_ = _BASE_BALANCE_;
        }

        _R_STATUS_ = Types.RStatus.ONE;
    }

    function claimAssets() external preventReentrant {

        require(_CLOSED_, "Charge_NOT_CLOSED");
        require(!_CLAIMED_[msg.sender], "ALREADY_CLAIMED");
        _CLAIMED_[msg.sender] = true;

        uint256 quoteCapital = getQuoteCapitalBalanceOf(msg.sender);
        uint256 baseCapital = getBaseCapitalBalanceOf(msg.sender);

        uint256 quoteAmount = 0;
        if (quoteCapital > 0) {
            quoteAmount = _TARGET_QUOTE_TOKEN_AMOUNT_.mul(quoteCapital).div(getTotalQuoteCapital());
        }
        uint256 baseAmount = 0;
        if (baseCapital > 0) {
            baseAmount = _TARGET_BASE_TOKEN_AMOUNT_.mul(baseCapital).div(getTotalBaseCapital());
        }

        _TARGET_QUOTE_TOKEN_AMOUNT_ = _TARGET_QUOTE_TOKEN_AMOUNT_.sub(quoteAmount);
        _TARGET_BASE_TOKEN_AMOUNT_ = _TARGET_BASE_TOKEN_AMOUNT_.sub(baseAmount);

        quoteAmount = quoteAmount.add(DecimalMath.mul(baseCapital, _BASE_CAPITAL_RECEIVE_QUOTE_));
        baseAmount = baseAmount.add(DecimalMath.mul(quoteCapital, _QUOTE_CAPITAL_RECEIVE_BASE_));

        _baseTokenTransferOut(msg.sender, baseAmount);
        _quoteTokenTransferOut(msg.sender, quoteAmount);

        IChargeLpToken(_BASE_CAPITAL_TOKEN_).burn(msg.sender, baseCapital);
        IChargeLpToken(_QUOTE_CAPITAL_TOKEN_).burn(msg.sender, quoteCapital);

        emit ClaimAssets(msg.sender, baseAmount, quoteAmount);
        return;
    }

    function retrieve(address token, uint256 amount) external onlyOwner {

        if (token == _BASE_TOKEN_) {
            require(
                IERC20(_BASE_TOKEN_).balanceOf(address(this)) >= _BASE_BALANCE_.add(amount),
                "Charge_BASE_BALANCE_NOT_ENOUGH"
            );
        }
        if (token == _QUOTE_TOKEN_) {
            require(
                IERC20(_QUOTE_TOKEN_).balanceOf(address(this)) >= _QUOTE_BALANCE_.add(amount),
                "Charge_QUOTE_BALANCE_NOT_ENOUGH"
            );
        }
        IERC20(token).safeTransfer(msg.sender, amount);
    }
}

contract Trader is Storage, Pricing, Settlement {

    using SafeMath for uint256;


    event SellBaseToken(address indexed seller, uint256 payBase, uint256 receiveQuote);

    event BuyBaseToken(address indexed buyer, uint256 receiveBase, uint256 payQuote);

    event ChargeMaintainerFee(address indexed maintainer, bool isBaseToken, uint256 amount);


    modifier tradeAllowed() {

        require(_TRADE_ALLOWED_, "TRADE_NOT_ALLOWED");
        _;
    }

    modifier buyingAllowed() {

        require(_BUYING_ALLOWED_, "BUYING_NOT_ALLOWED");
        _;
    }

    modifier sellingAllowed() {

        require(_SELLING_ALLOWED_, "SELLING_NOT_ALLOWED");
        _;
    }

    modifier gasPriceLimit() {

        require(tx.gasprice <= _GAS_PRICE_LIMIT_, "GAS_PRICE_EXCEED");
        _;
    }


    function sellBaseToken(
        uint256 amount,
        uint256 minReceiveQuote,
        bytes calldata data
    ) external tradeAllowed sellingAllowed gasPriceLimit preventReentrant returns (uint256) {

        (
            uint256 receiveQuote,
            uint256 lpFeeQuote,
            uint256 mtFeeQuote,
            Types.RStatus newRStatus,
            uint256 newQuoteTarget,
            uint256 newBaseTarget
        ) = _querySellBaseToken(amount);
        require(receiveQuote >= minReceiveQuote, "SELL_BASE_RECEIVE_NOT_ENOUGH");

        _quoteTokenTransferOut(msg.sender, receiveQuote);
        if (data.length > 0) {
            IChargeCallee(msg.sender).ChargeCall(false, amount, receiveQuote, data);
        }
        _baseTokenTransferIn(msg.sender, amount);
        if (mtFeeQuote != 0) {
            _quoteTokenTransferOut(_MAINTAINER_, mtFeeQuote);
            emit ChargeMaintainerFee(_MAINTAINER_, false, mtFeeQuote);
        }

        if (_TARGET_QUOTE_TOKEN_AMOUNT_ != newQuoteTarget) {
            _TARGET_QUOTE_TOKEN_AMOUNT_ = newQuoteTarget;
        }
        if (_TARGET_BASE_TOKEN_AMOUNT_ != newBaseTarget) {
            _TARGET_BASE_TOKEN_AMOUNT_ = newBaseTarget;
        }
        if (_R_STATUS_ != newRStatus) {
            _R_STATUS_ = newRStatus;
        }

        _donateQuoteToken(lpFeeQuote);
        emit SellBaseToken(msg.sender, amount, receiveQuote);

        return receiveQuote;
    }

    function buyBaseToken(
        uint256 amount,
        uint256 maxPayQuote,
        bytes calldata data
    ) external tradeAllowed buyingAllowed gasPriceLimit preventReentrant returns (uint256) {

        (
            uint256 payQuote,
            uint256 lpFeeBase,
            uint256 mtFeeBase,
            Types.RStatus newRStatus,
            uint256 newQuoteTarget,
            uint256 newBaseTarget
        ) = _queryBuyBaseToken(amount);
        require(payQuote <= maxPayQuote, "BUY_BASE_COST_TOO_MUCH");

        _baseTokenTransferOut(msg.sender, amount);
        if (data.length > 0) {
            IChargeCallee(msg.sender).ChargeCall(true, amount, payQuote, data);
        }
        _quoteTokenTransferIn(msg.sender, payQuote);
        if (mtFeeBase != 0) {
            _baseTokenTransferOut(_MAINTAINER_, mtFeeBase);
            emit ChargeMaintainerFee(_MAINTAINER_, true, mtFeeBase);
        }

        if (_TARGET_QUOTE_TOKEN_AMOUNT_ != newQuoteTarget) {
            _TARGET_QUOTE_TOKEN_AMOUNT_ = newQuoteTarget;
        }
        if (_TARGET_BASE_TOKEN_AMOUNT_ != newBaseTarget) {
            _TARGET_BASE_TOKEN_AMOUNT_ = newBaseTarget;
        }
        if (_R_STATUS_ != newRStatus) {
            _R_STATUS_ = newRStatus;
        }

        _donateBaseToken(lpFeeBase);
        emit BuyBaseToken(msg.sender, amount, payQuote);

        return payQuote;
    }


    function querySellBaseToken(uint256 amount) external view returns (uint256 receiveQuote) {

        (receiveQuote, , , , , ) = _querySellBaseToken(amount);
        return receiveQuote;
    }

    function queryBuyBaseToken(uint256 amount) external view returns (uint256 payQuote) {

        (payQuote, , , , , ) = _queryBuyBaseToken(amount);
        return payQuote;
    }

    function _querySellBaseToken(uint256 amount)
        internal
        view
        returns (
            uint256 receiveQuote,
            uint256 lpFeeQuote,
            uint256 mtFeeQuote,
            Types.RStatus newRStatus,
            uint256 newQuoteTarget,
            uint256 newBaseTarget
        )
    {

        (newBaseTarget, newQuoteTarget) = getExpectedTarget();

        uint256 sellBaseAmount = amount;

        if (_R_STATUS_ == Types.RStatus.ONE) {
            receiveQuote = _ROneSellBaseToken(sellBaseAmount, newQuoteTarget);
            newRStatus = Types.RStatus.BELOW_ONE;
        } else if (_R_STATUS_ == Types.RStatus.ABOVE_ONE) {
            uint256 backToOnePayBase = newBaseTarget.sub(_BASE_BALANCE_);
            uint256 backToOneReceiveQuote = _QUOTE_BALANCE_.sub(newQuoteTarget);
            if (sellBaseAmount < backToOnePayBase) {
                receiveQuote = _RAboveSellBaseToken(sellBaseAmount, _BASE_BALANCE_, newBaseTarget);
                newRStatus = Types.RStatus.ABOVE_ONE;
                if (receiveQuote > backToOneReceiveQuote) {
                    receiveQuote = backToOneReceiveQuote;
                }
            } else if (sellBaseAmount == backToOnePayBase) {
                receiveQuote = backToOneReceiveQuote;
                newRStatus = Types.RStatus.ONE;
            } else {
                receiveQuote = backToOneReceiveQuote.add(
                    _ROneSellBaseToken(sellBaseAmount.sub(backToOnePayBase), newQuoteTarget)
                );
                newRStatus = Types.RStatus.BELOW_ONE;
            }
        } else {
            receiveQuote = _RBelowSellBaseToken(sellBaseAmount, _QUOTE_BALANCE_, newQuoteTarget);
            newRStatus = Types.RStatus.BELOW_ONE;
        }

        lpFeeQuote = DecimalMath.mul(receiveQuote, _LP_FEE_RATE_);
        mtFeeQuote = DecimalMath.mul(receiveQuote, _MT_FEE_RATE_);
        receiveQuote = receiveQuote.sub(lpFeeQuote).sub(mtFeeQuote);

        return (receiveQuote, lpFeeQuote, mtFeeQuote, newRStatus, newQuoteTarget, newBaseTarget);
    }

    function _queryBuyBaseToken(uint256 amount)
        internal
        view
        returns (
            uint256 payQuote,
            uint256 lpFeeBase,
            uint256 mtFeeBase,
            Types.RStatus newRStatus,
            uint256 newQuoteTarget,
            uint256 newBaseTarget
        )
    {

        (newBaseTarget, newQuoteTarget) = getExpectedTarget();

        lpFeeBase = DecimalMath.mul(amount, _LP_FEE_RATE_);
        mtFeeBase = DecimalMath.mul(amount, _MT_FEE_RATE_);
        uint256 buyBaseAmount = amount.add(lpFeeBase).add(mtFeeBase);

        if (_R_STATUS_ == Types.RStatus.ONE) {
            payQuote = _ROneBuyBaseToken(buyBaseAmount, newBaseTarget);
            newRStatus = Types.RStatus.ABOVE_ONE;
        } else if (_R_STATUS_ == Types.RStatus.ABOVE_ONE) {
            payQuote = _RAboveBuyBaseToken(buyBaseAmount, _BASE_BALANCE_, newBaseTarget);
            newRStatus = Types.RStatus.ABOVE_ONE;
        } else if (_R_STATUS_ == Types.RStatus.BELOW_ONE) {
            uint256 backToOnePayQuote = newQuoteTarget.sub(_QUOTE_BALANCE_);
            uint256 backToOneReceiveBase = _BASE_BALANCE_.sub(newBaseTarget);
            if (buyBaseAmount < backToOneReceiveBase) {
                payQuote = _RBelowBuyBaseToken(buyBaseAmount, _QUOTE_BALANCE_, newQuoteTarget);
                newRStatus = Types.RStatus.BELOW_ONE;
            } else if (buyBaseAmount == backToOneReceiveBase) {
                payQuote = backToOnePayQuote;
                newRStatus = Types.RStatus.ONE;
            } else {
                payQuote = backToOnePayQuote.add(
                    _ROneBuyBaseToken(buyBaseAmount.sub(backToOneReceiveBase), newBaseTarget)
                );
                newRStatus = Types.RStatus.ABOVE_ONE;
            }
        }

        return (payQuote, lpFeeBase, mtFeeBase, newRStatus, newQuoteTarget, newBaseTarget);
    }
}

contract LiquidityProvider is Storage, Pricing, Settlement {

    using SafeMath for uint256;


    event Deposit(
        address indexed payer,
        address indexed receiver,
        bool isBaseToken,
        uint256 amount,
        uint256 lpTokenAmount
    );

    event Withdraw(
        address indexed payer,
        address indexed receiver,
        bool isBaseToken,
        uint256 amount,
        uint256 lpTokenAmount
    );

    event ChargePenalty(address indexed payer, bool isBaseToken, uint256 amount);


    modifier depositQuoteAllowed() {

        require(_DEPOSIT_QUOTE_ALLOWED_, "DEPOSIT_QUOTE_NOT_ALLOWED");
        _;
    }

    modifier depositBaseAllowed() {

        require(_DEPOSIT_BASE_ALLOWED_, "DEPOSIT_BASE_NOT_ALLOWED");
        _;
    }

    modifier ChargeNotClosed() {

        require(!_CLOSED_, "Charge_CLOSED");
        _;
    }


    function withdrawBase(uint256 amount) external returns (uint256) {

        return withdrawBaseTo(msg.sender, amount);
    }

    function depositBase(uint256 amount) external returns (uint256) {

        return depositBaseTo(msg.sender, amount);
    }

    function withdrawQuote(uint256 amount) external returns (uint256) {

        return withdrawQuoteTo(msg.sender, amount);
    }

    function depositQuote(uint256 amount) external returns (uint256) {

        return depositQuoteTo(msg.sender, amount);
    }

    function withdrawAllBase() external returns (uint256) {

        return withdrawAllBaseTo(msg.sender);
    }

    function withdrawAllQuote() external returns (uint256) {

        return withdrawAllQuoteTo(msg.sender);
    }


    function depositQuoteTo(address to, uint256 amount)
        public
        preventReentrant
        depositQuoteAllowed
        returns (uint256)
    {

        (, uint256 quoteTarget) = getExpectedTarget();
        uint256 totalQuoteCapital = getTotalQuoteCapital();
        uint256 capital = amount;
        if (totalQuoteCapital == 0) {
            capital = amount.add(quoteTarget);
        } else if (quoteTarget > 0) {
            capital = amount.mul(totalQuoteCapital).div(quoteTarget);
        }

        _quoteTokenTransferIn(msg.sender, amount);
        _mintQuoteCapital(to, capital);
        _TARGET_QUOTE_TOKEN_AMOUNT_ = _TARGET_QUOTE_TOKEN_AMOUNT_.add(amount);

        emit Deposit(msg.sender, to, false, amount, capital);
        return capital;
    }

    function depositBaseTo(address to, uint256 amount)
        public
        preventReentrant
        depositBaseAllowed
        returns (uint256)
    {

        (uint256 baseTarget, ) = getExpectedTarget();
        uint256 totalBaseCapital = getTotalBaseCapital();
        uint256 capital = amount;
        if (totalBaseCapital == 0) {
            capital = amount.add(baseTarget);
        } else if (baseTarget > 0) {
            capital = amount.mul(totalBaseCapital).div(baseTarget);
        }

        _baseTokenTransferIn(msg.sender, amount);
        _mintBaseCapital(to, capital);
        _TARGET_BASE_TOKEN_AMOUNT_ = _TARGET_BASE_TOKEN_AMOUNT_.add(amount);

        emit Deposit(msg.sender, to, true, amount, capital);
        return capital;
    }


    function withdrawQuoteTo(address to, uint256 amount)
        public
        preventReentrant
        ChargeNotClosed
        returns (uint256)
    {

        (, uint256 quoteTarget) = getExpectedTarget();
        uint256 totalQuoteCapital = getTotalQuoteCapital();
        require(totalQuoteCapital > 0, "NO_QUOTE_LP");

        uint256 requireQuoteCapital = amount.mul(totalQuoteCapital).divCeil(quoteTarget);
        require(
            requireQuoteCapital <= getQuoteCapitalBalanceOf(msg.sender),
            "LP_QUOTE_CAPITAL_BALANCE_NOT_ENOUGH"
        );

        uint256 penalty = getWithdrawQuotePenalty(amount);
        require(penalty < amount, "PENALTY_EXCEED");

        _TARGET_QUOTE_TOKEN_AMOUNT_ = _TARGET_QUOTE_TOKEN_AMOUNT_.sub(amount);
        _burnQuoteCapital(msg.sender, requireQuoteCapital);
        _quoteTokenTransferOut(to, amount.sub(penalty));
        _donateQuoteToken(penalty);

        emit Withdraw(msg.sender, to, false, amount.sub(penalty), requireQuoteCapital);
        emit ChargePenalty(msg.sender, false, penalty);

        return amount.sub(penalty);
    }

    function withdrawBaseTo(address to, uint256 amount)
        public
        preventReentrant
        ChargeNotClosed
        returns (uint256)
    {

        (uint256 baseTarget, ) = getExpectedTarget();
        uint256 totalBaseCapital = getTotalBaseCapital();
        require(totalBaseCapital > 0, "NO_BASE_LP");

        uint256 requireBaseCapital = amount.mul(totalBaseCapital).divCeil(baseTarget);
        require(
            requireBaseCapital <= getBaseCapitalBalanceOf(msg.sender),
            "LP_BASE_CAPITAL_BALANCE_NOT_ENOUGH"
        );

        uint256 penalty = getWithdrawBasePenalty(amount);
        require(penalty <= amount, "PENALTY_EXCEED");

        _TARGET_BASE_TOKEN_AMOUNT_ = _TARGET_BASE_TOKEN_AMOUNT_.sub(amount);
        _burnBaseCapital(msg.sender, requireBaseCapital);
        _baseTokenTransferOut(to, amount.sub(penalty));
        _donateBaseToken(penalty);

        emit Withdraw(msg.sender, to, true, amount.sub(penalty), requireBaseCapital);
        emit ChargePenalty(msg.sender, true, penalty);

        return amount.sub(penalty);
    }


    function withdrawAllQuoteTo(address to)
        public
        preventReentrant
        ChargeNotClosed
        returns (uint256)
    {

        uint256 withdrawAmount = getLpQuoteBalance(msg.sender);
        uint256 capital = getQuoteCapitalBalanceOf(msg.sender);

        uint256 penalty = getWithdrawQuotePenalty(withdrawAmount);
        require(penalty <= withdrawAmount, "PENALTY_EXCEED");

        _TARGET_QUOTE_TOKEN_AMOUNT_ = _TARGET_QUOTE_TOKEN_AMOUNT_.sub(withdrawAmount);
        _burnQuoteCapital(msg.sender, capital);
        _quoteTokenTransferOut(to, withdrawAmount.sub(penalty));
        _donateQuoteToken(penalty);

        emit Withdraw(msg.sender, to, false, withdrawAmount, capital);
        emit ChargePenalty(msg.sender, false, penalty);

        return withdrawAmount.sub(penalty);
    }

    function withdrawAllBaseTo(address to) public preventReentrant ChargeNotClosed returns (uint256) {

        uint256 withdrawAmount = getLpBaseBalance(msg.sender);
        uint256 capital = getBaseCapitalBalanceOf(msg.sender);

        uint256 penalty = getWithdrawBasePenalty(withdrawAmount);
        require(penalty <= withdrawAmount, "PENALTY_EXCEED");

        _TARGET_BASE_TOKEN_AMOUNT_ = _TARGET_BASE_TOKEN_AMOUNT_.sub(withdrawAmount);
        _burnBaseCapital(msg.sender, capital);
        _baseTokenTransferOut(to, withdrawAmount.sub(penalty));
        _donateBaseToken(penalty);

        emit Withdraw(msg.sender, to, true, withdrawAmount, capital);
        emit ChargePenalty(msg.sender, true, penalty);

        return withdrawAmount.sub(penalty);
    }


    function _mintBaseCapital(address user, uint256 amount) internal {

        IChargeLpToken(_BASE_CAPITAL_TOKEN_).mint(user, amount);
    }

    function _mintQuoteCapital(address user, uint256 amount) internal {

        IChargeLpToken(_QUOTE_CAPITAL_TOKEN_).mint(user, amount);
    }

    function _burnBaseCapital(address user, uint256 amount) internal {

        IChargeLpToken(_BASE_CAPITAL_TOKEN_).burn(user, amount);
    }

    function _burnQuoteCapital(address user, uint256 amount) internal {

        IChargeLpToken(_QUOTE_CAPITAL_TOKEN_).burn(user, amount);
    }


    function getLpBaseBalance(address lp) public view returns (uint256 lpBalance) {

        uint256 totalBaseCapital = getTotalBaseCapital();
        (uint256 baseTarget, ) = getExpectedTarget();
        if (totalBaseCapital == 0) {
            return 0;
        }
        lpBalance = getBaseCapitalBalanceOf(lp).mul(baseTarget).div(totalBaseCapital);
        return lpBalance;
    }

    function getLpQuoteBalance(address lp) public view returns (uint256 lpBalance) {

        uint256 totalQuoteCapital = getTotalQuoteCapital();
        (, uint256 quoteTarget) = getExpectedTarget();
        if (totalQuoteCapital == 0) {
            return 0;
        }
        lpBalance = getQuoteCapitalBalanceOf(lp).mul(quoteTarget).div(totalQuoteCapital);
        return lpBalance;
    }

    function getWithdrawQuotePenalty(uint256 amount) public view returns (uint256 penalty) {

        require(amount <= _QUOTE_BALANCE_, "Charge_QUOTE_BALANCE_NOT_ENOUGH");
        if (_R_STATUS_ == Types.RStatus.BELOW_ONE) {
            uint256 spareBase = _BASE_BALANCE_.sub(_TARGET_BASE_TOKEN_AMOUNT_);
            uint256 price = readOraclePrice();
            uint256 fairAmount = DecimalMath.mul(spareBase, price);
            uint256 targetQuote = ChargeMath._SolveQuadraticFunctionForTarget(
                _QUOTE_BALANCE_,
                _K_,
                fairAmount
            );
            uint256 targetQuoteWithWithdraw = ChargeMath._SolveQuadraticFunctionForTarget(
                _QUOTE_BALANCE_.sub(amount),
                _K_,
                fairAmount
            );
            return targetQuote.sub(targetQuoteWithWithdraw.add(amount));
        } else {
            return 0;
        }
    }

    function getWithdrawBasePenalty(uint256 amount) public view returns (uint256 penalty) {

        require(amount <= _BASE_BALANCE_, "Charge_BASE_BALANCE_NOT_ENOUGH");
        if (_R_STATUS_ == Types.RStatus.ABOVE_ONE) {
            uint256 spareQuote = _QUOTE_BALANCE_.sub(_TARGET_QUOTE_TOKEN_AMOUNT_);
            uint256 price = readOraclePrice();
            uint256 fairAmount = DecimalMath.divFloor(spareQuote, price);
            uint256 targetBase = ChargeMath._SolveQuadraticFunctionForTarget(
                _BASE_BALANCE_,
                _K_,
                fairAmount
            );
            uint256 targetBaseWithWithdraw = ChargeMath._SolveQuadraticFunctionForTarget(
                _BASE_BALANCE_.sub(amount),
                _K_,
                fairAmount
            );
            return targetBase.sub(targetBaseWithWithdraw.add(amount));
        } else {
            return 0;
        }
    }
}

contract Admin is Storage {


    event UpdateGasPriceLimit(uint256 oldGasPriceLimit, uint256 newGasPriceLimit);

    event UpdateLiquidityProviderFeeRate(
        uint256 oldLiquidityProviderFeeRate,
        uint256 newLiquidityProviderFeeRate
    );

    event UpdateMaintainerFeeRate(uint256 oldMaintainerFeeRate, uint256 newMaintainerFeeRate);

    event UpdateK(uint256 oldK, uint256 newK);


    function setOracle(address newOracle) external onlyOwner {

        _ORACLE_ = newOracle;
    }

    function setSupervisor(address newSupervisor) external onlyOwner {

        _SUPERVISOR_ = newSupervisor;
    }

    function setMaintainer(address newMaintainer) external onlyOwner {

        _MAINTAINER_ = newMaintainer;
    }

    function setLiquidityProviderFeeRate(uint256 newLiquidityPorviderFeeRate) external onlyOwner {

        emit UpdateLiquidityProviderFeeRate(_LP_FEE_RATE_, newLiquidityPorviderFeeRate);
        _LP_FEE_RATE_ = newLiquidityPorviderFeeRate;
        _checkChargeParameters();
    }

    function setMaintainerFeeRate(uint256 newMaintainerFeeRate) external onlyOwner {

        emit UpdateMaintainerFeeRate(_MT_FEE_RATE_, newMaintainerFeeRate);
        _MT_FEE_RATE_ = newMaintainerFeeRate;
        _checkChargeParameters();
    }

    function setK(uint256 newK) external onlyOwner {

        emit UpdateK(_K_, newK);
        _K_ = newK;
        _K_CONFIG_ = newK;
        _checkChargeParameters();
    }

    function setGasPriceLimit(uint256 newGasPriceLimit) external onlySupervisorOrOwner {

        emit UpdateGasPriceLimit(_GAS_PRICE_LIMIT_, newGasPriceLimit);
        _GAS_PRICE_LIMIT_ = newGasPriceLimit;
    }


    function disableTrading() external onlySupervisorOrOwner {

        _TRADE_ALLOWED_ = false;
    }

    function enableTrading() external onlyOwner notClosed {

        _TRADE_ALLOWED_ = true;
    }

    function disableQuoteDeposit() external onlySupervisorOrOwner {

        _DEPOSIT_QUOTE_ALLOWED_ = false;
    }

    function enableQuoteDeposit() external onlyOwner notClosed {

        _DEPOSIT_QUOTE_ALLOWED_ = true;
    }

    function disableBaseDeposit() external onlySupervisorOrOwner {

        _DEPOSIT_BASE_ALLOWED_ = false;
    }

    function enableBaseDeposit() external onlyOwner notClosed {

        _DEPOSIT_BASE_ALLOWED_ = true;
    }


    function disableBuying() external onlySupervisorOrOwner {

        _BUYING_ALLOWED_ = false;
    }

    function enableBuying() external onlyOwner notClosed {

        _BUYING_ALLOWED_ = true;
    }

    function disableSelling() external onlySupervisorOrOwner {

        _SELLING_ALLOWED_ = false;
    }

    function enableSelling() external onlyOwner notClosed {

        _SELLING_ALLOWED_ = true;
    }

    function setBaseBalanceLimit(uint256 newBaseBalanceLimit) external onlyOwner notClosed {

        _BASE_BALANCE_LIMIT_ = newBaseBalanceLimit;
    }

    function setQuoteBalanceLimit(uint256 newQuoteBalanceLimit) external onlyOwner notClosed {

        _QUOTE_BALANCE_LIMIT_ = newQuoteBalanceLimit;
    }
}

contract Ownable {

    address public _OWNER_;
    address public _NEW_OWNER_;


    event OwnershipTransferPrepared(address indexed previousOwner, address indexed newOwner);

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);


    modifier onlyOwner() {

        require(msg.sender == _OWNER_, "NOT_OWNER");
        _;
    }


    constructor() internal {
        _OWNER_ = msg.sender;
        emit OwnershipTransferred(address(0), _OWNER_);
    }

    function transferOwnership(address newOwner) external onlyOwner {

        require(newOwner != address(0), "INVALID_OWNER");
        emit OwnershipTransferPrepared(_OWNER_, newOwner);
        _NEW_OWNER_ = newOwner;
    }

    function claimOwnership() external {

        require(msg.sender == _NEW_OWNER_, "INVALID_CLAIM");
        emit OwnershipTransferred(_OWNER_, _NEW_OWNER_);
        _OWNER_ = _NEW_OWNER_;
        _NEW_OWNER_ = address(0);
    }
}

contract ChargeLpToken is Ownable {

    using SafeMath for uint256;

    string public symbol = "Charge";
    address public originToken;

    uint256 public totalSupply;
    mapping(address => uint256) internal balances;
    mapping(address => mapping(address => uint256)) internal allowed;


    event Transfer(address indexed from, address indexed to, uint256 amount);

    event Approval(address indexed owner, address indexed spender, uint256 amount);

    event Mint(address indexed user, uint256 value);

    event Burn(address indexed user, uint256 value);


    constructor(address _originToken) public {
        originToken = _originToken;
    }

    function name() public view returns (string memory) {

        string memory lpTokenSuffix = "_Charge_LP_TOKEN_";
        return string(abi.encodePacked(IERC20(originToken).name(), lpTokenSuffix));
    }

    function decimals() public view returns (uint8) {

        return IERC20(originToken).decimals();
    }

    function transfer(address to, uint256 amount) public returns (bool) {

        require(amount <= balances[msg.sender], "BALANCE_NOT_ENOUGH");

        balances[msg.sender] = balances[msg.sender].sub(amount);
        balances[to] = balances[to].add(amount);
        emit Transfer(msg.sender, to, amount);
        return true;
    }

    function balanceOf(address owner) external view returns (uint256 balance) {

        return balances[owner];
    }

    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) public returns (bool) {

        require(amount <= balances[from], "BALANCE_NOT_ENOUGH");
        require(amount <= allowed[from][msg.sender], "ALLOWANCE_NOT_ENOUGH");

        balances[from] = balances[from].sub(amount);
        balances[to] = balances[to].add(amount);
        allowed[from][msg.sender] = allowed[from][msg.sender].sub(amount);
        emit Transfer(from, to, amount);
        return true;
    }

    function approve(address spender, uint256 amount) public returns (bool) {

        allowed[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }

    function allowance(address owner, address spender) public view returns (uint256) {

        return allowed[owner][spender];
    }

    function mint(address user, uint256 value) external onlyOwner {

        balances[user] = balances[user].add(value);
        totalSupply = totalSupply.add(value);
        emit Mint(user, value);
        emit Transfer(address(0), user, value);
    }

    function burn(address user, uint256 value) external onlyOwner {

        balances[user] = balances[user].sub(value);
        totalSupply = totalSupply.sub(value);
        emit Burn(user, value);
        emit Transfer(user, address(0), value);
    }
}

contract Charge is Admin, Trader, LiquidityProvider {

    function init(
        address owner,
        address supervisor,
        address maintainer,
        address baseToken,
        address quoteToken,
        address oracle,
        uint256 lpFeeRate,
        uint256 mtFeeRate,
        uint256 k,
        uint256 gasPriceLimit
    ) external {

        require(!_INITIALIZED_, "Charge_INITIALIZED");
        _INITIALIZED_ = true;

        _OWNER_ = owner;
        emit OwnershipTransferred(address(0), _OWNER_);

        _SUPERVISOR_ = supervisor;
        _MAINTAINER_ = maintainer;
        _BASE_TOKEN_ = baseToken;
        _QUOTE_TOKEN_ = quoteToken;
        _ORACLE_ = oracle;

        _DEPOSIT_BASE_ALLOWED_ = false;
        _DEPOSIT_QUOTE_ALLOWED_ = false;
        _TRADE_ALLOWED_ = false;
        _GAS_PRICE_LIMIT_ = gasPriceLimit;

        _BUYING_ALLOWED_ = true;
        _SELLING_ALLOWED_ = true;
        uint256 MAX_INT = 0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff;
        _BASE_BALANCE_LIMIT_ = MAX_INT;
        _QUOTE_BALANCE_LIMIT_ = MAX_INT;

        _LP_FEE_RATE_ = lpFeeRate;
        _MT_FEE_RATE_ = mtFeeRate;
        _K_ = k;
        _K_CONFIG_ = k;
        _R_STATUS_ = Types.RStatus.ONE;

        _BASE_CAPITAL_TOKEN_ = address(new ChargeLpToken(_BASE_TOKEN_));
        _QUOTE_CAPITAL_TOKEN_ = address(new ChargeLpToken(_QUOTE_TOKEN_));

        _checkChargeParameters();
    }
}