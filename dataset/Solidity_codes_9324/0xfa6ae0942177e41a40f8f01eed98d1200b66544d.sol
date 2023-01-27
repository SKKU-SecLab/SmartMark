


pragma solidity 0.6.9;
pragma experimental ABIEncoderV2;

contract InitializableOwnable {

    address public _OWNER_;
    address public _NEW_OWNER_;
    bool internal _INITIALIZED_;


    event OwnershipTransferPrepared(address indexed previousOwner, address indexed newOwner);

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);


    modifier notInitialized() {

        require(!_INITIALIZED_, "DODO_INITIALIZED");
        _;
    }

    modifier onlyOwner() {

        require(msg.sender == _OWNER_, "NOT_OWNER");
        _;
    }


    function initOwner(address newOwner) public notInitialized {

        _INITIALIZED_ = true;
        _OWNER_ = newOwner;
    }

    function transferOwnership(address newOwner) public onlyOwner {

        emit OwnershipTransferPrepared(_OWNER_, newOwner);
        _NEW_OWNER_ = newOwner;
    }

    function claimOwnership() public {

        require(msg.sender == _NEW_OWNER_, "INVALID_CLAIM");
        emit OwnershipTransferred(_OWNER_, _NEW_OWNER_);
        _OWNER_ = _NEW_OWNER_;
        _NEW_OWNER_ = address(0);
    }
}




interface IFeeRateImpl {

    function getFeeRate(address pool, address trader) external view returns (uint256);

}

interface IFeeRateModel {

    function getFeeRate(address trader) external view returns (uint256);

}

contract FeeRateModel is InitializableOwnable {

    address public feeRateImpl;

    function setFeeProxy(address _feeRateImpl) public onlyOwner {

        feeRateImpl = _feeRateImpl;
    }
    
    function getFeeRate(address trader) external view returns (uint256) {

        if(feeRateImpl == address(0))
            return 0;
        return IFeeRateImpl(feeRateImpl).getFeeRate(msg.sender,trader);
    }
}


interface IERC20 {

    function totalSupply() external view returns (uint256);


    function decimals() external view returns (uint8);


    function name() external view returns (string memory);


    function symbol() external view returns (string memory);


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

    uint256 internal constant ONE = 10**18;
    uint256 internal constant ONE2 = 10**36;

    function mulFloor(uint256 target, uint256 d) internal pure returns (uint256) {

        return target.mul(d) / (10**18);
    }

    function mulCeil(uint256 target, uint256 d) internal pure returns (uint256) {

        return target.mul(d).divCeil(10**18);
    }

    function divFloor(uint256 target, uint256 d) internal pure returns (uint256) {

        return target.mul(10**18).div(d);
    }

    function divCeil(uint256 target, uint256 d) internal pure returns (uint256) {

        return target.mul(10**18).divCeil(d);
    }

    function reciprocalFloor(uint256 target) internal pure returns (uint256) {

        return uint256(10**36).div(target);
    }

    function reciprocalCeil(uint256 target) internal pure returns (uint256) {

        return uint256(10**36).divCeil(target);
    }
}



library DODOMath {

    using SafeMath for uint256;

    function _GeneralIntegrate(
        uint256 V0,
        uint256 V1,
        uint256 V2,
        uint256 i,
        uint256 k
    ) internal pure returns (uint256) {

        require(V0 > 0, "TARGET_IS_ZERO");
        uint256 fairAmount = i.mul(V1.sub(V2)); // i*delta
        if (k == 0) {
            return fairAmount.div(DecimalMath.ONE);
        }
        uint256 V0V0V1V2 = DecimalMath.divFloor(V0.mul(V0).div(V1), V2);
        uint256 penalty = DecimalMath.mulFloor(k, V0V0V1V2); // k(V0^2/V1/V2)
        return DecimalMath.ONE.sub(k).add(penalty).mul(fairAmount).div(DecimalMath.ONE2);
    }

    function _SolveQuadraticFunctionForTarget(
        uint256 V1,
        uint256 delta,
        uint256 i,
        uint256 k
    ) internal pure returns (uint256) {

        if (V1 == 0) {
            return 0;
        }
        if (k == 0) {
            return V1.add(DecimalMath.mulFloor(i, delta));
        }
        uint256 sqrt;
        uint256 ki = (4 * k).mul(i);
        if (ki == 0) {
            sqrt = DecimalMath.ONE;
        } else if ((ki * delta) / ki == delta) {
            sqrt = (ki * delta).div(V1).add(DecimalMath.ONE2).sqrt();
        } else {
            sqrt = ki.div(V1).mul(delta).add(DecimalMath.ONE2).sqrt();
        }
        uint256 premium =
            DecimalMath.divFloor(sqrt.sub(DecimalMath.ONE), k * 2).add(DecimalMath.ONE);
        return DecimalMath.mulFloor(V1, premium);
    }

    function _SolveQuadraticFunctionForTrade(
        uint256 V0,
        uint256 V1,
        uint256 delta,
        uint256 i,
        uint256 k
    ) internal pure returns (uint256) {

        require(V0 > 0, "TARGET_IS_ZERO");
        if (delta == 0) {
            return 0;
        }

        if (k == 0) {
            return DecimalMath.mulFloor(i, delta) > V1 ? V1 : DecimalMath.mulFloor(i, delta);
        }

        if (k == DecimalMath.ONE) {
            uint256 temp;
            uint256 idelta = i.mul(delta);
            if (idelta == 0) {
                temp = 0;
            } else if ((idelta * V1) / idelta == V1) {
                temp = (idelta * V1).div(V0.mul(V0));
            } else {
                temp = delta.mul(V1).div(V0).mul(i).div(V0);
            }
            return V1.mul(temp).div(temp.add(DecimalMath.ONE));
        }

        uint256 part2 = k.mul(V0).div(V1).mul(V0).add(i.mul(delta)); // kQ0^2/Q1-i*deltaB
        uint256 bAbs = DecimalMath.ONE.sub(k).mul(V1); // (1-k)Q1

        bool bSig;
        if (bAbs >= part2) {
            bAbs = bAbs - part2;
            bSig = false;
        } else {
            bAbs = part2 - bAbs;
            bSig = true;
        }
        bAbs = bAbs.div(DecimalMath.ONE);

        uint256 squareRoot =
            DecimalMath.mulFloor(
                DecimalMath.ONE.sub(k).mul(4),
                DecimalMath.mulFloor(k, V0).mul(V0)
            ); // 4(1-k)kQ0^2
        squareRoot = bAbs.mul(bAbs).add(squareRoot).sqrt(); // sqrt(b*b+4(1-k)kQ0*Q0)

        uint256 denominator = DecimalMath.ONE.sub(k).mul(2); // 2(1-k)
        uint256 numerator;
        if (bSig) {
            numerator = squareRoot.sub(bAbs);
        } else {
            numerator = bAbs.add(squareRoot);
        }

        uint256 V2 = DecimalMath.divCeil(numerator, denominator);
        if (V2 > V1) {
            return 0;
        } else {
            return V1 - V2;
        }
    }
}





library PMMPricing {

    using SafeMath for uint256;

    enum RState {ONE, ABOVE_ONE, BELOW_ONE}

    struct PMMState {
        uint256 i;
        uint256 K;
        uint256 B;
        uint256 Q;
        uint256 B0;
        uint256 Q0;
        RState R;
    }


    function sellBaseToken(PMMState memory state, uint256 payBaseAmount)
        internal
        pure
        returns (uint256 receiveQuoteAmount, RState newR)
    {

        if (state.R == RState.ONE) {
            receiveQuoteAmount = _ROneSellBaseToken(state, payBaseAmount);
            newR = RState.BELOW_ONE;
        } else if (state.R == RState.ABOVE_ONE) {
            uint256 backToOnePayBase = state.B0.sub(state.B);
            uint256 backToOneReceiveQuote = state.Q.sub(state.Q0);
            if (payBaseAmount < backToOnePayBase) {
                receiveQuoteAmount = _RAboveSellBaseToken(state, payBaseAmount);
                newR = RState.ABOVE_ONE;
                if (receiveQuoteAmount > backToOneReceiveQuote) {
                    receiveQuoteAmount = backToOneReceiveQuote;
                }
            } else if (payBaseAmount == backToOnePayBase) {
                receiveQuoteAmount = backToOneReceiveQuote;
                newR = RState.ONE;
            } else {
                receiveQuoteAmount = backToOneReceiveQuote.add(
                    _ROneSellBaseToken(state, payBaseAmount.sub(backToOnePayBase))
                );
                newR = RState.BELOW_ONE;
            }
        } else {
            receiveQuoteAmount = _RBelowSellBaseToken(state, payBaseAmount);
            newR = RState.BELOW_ONE;
        }
    }

    function sellQuoteToken(PMMState memory state, uint256 payQuoteAmount)
        internal
        pure
        returns (uint256 receiveBaseAmount, RState newR)
    {

        if (state.R == RState.ONE) {
            receiveBaseAmount = _ROneSellQuoteToken(state, payQuoteAmount);
            newR = RState.ABOVE_ONE;
        } else if (state.R == RState.ABOVE_ONE) {
            receiveBaseAmount = _RAboveSellQuoteToken(state, payQuoteAmount);
            newR = RState.ABOVE_ONE;
        } else {
            uint256 backToOnePayQuote = state.Q0.sub(state.Q);
            uint256 backToOneReceiveBase = state.B.sub(state.B0);
            if (payQuoteAmount < backToOnePayQuote) {
                receiveBaseAmount = _RBelowSellQuoteToken(state, payQuoteAmount);
                newR = RState.BELOW_ONE;
                if (receiveBaseAmount > backToOneReceiveBase) {
                    receiveBaseAmount = backToOneReceiveBase;
                }
            } else if (payQuoteAmount == backToOnePayQuote) {
                receiveBaseAmount = backToOneReceiveBase;
                newR = RState.ONE;
            } else {
                receiveBaseAmount = backToOneReceiveBase.add(
                    _ROneSellQuoteToken(state, payQuoteAmount.sub(backToOnePayQuote))
                );
                newR = RState.ABOVE_ONE;
            }
        }
    }


    function _ROneSellBaseToken(PMMState memory state, uint256 payBaseAmount)
        internal
        pure
        returns (
            uint256 // receiveQuoteToken
        )
    {

        return
            DODOMath._SolveQuadraticFunctionForTrade(
                state.Q0,
                state.Q0,
                payBaseAmount,
                state.i,
                state.K
            );
    }

    function _ROneSellQuoteToken(PMMState memory state, uint256 payQuoteAmount)
        internal
        pure
        returns (
            uint256 // receiveBaseToken
        )
    {

        return
            DODOMath._SolveQuadraticFunctionForTrade(
                state.B0,
                state.B0,
                payQuoteAmount,
                DecimalMath.reciprocalFloor(state.i),
                state.K
            );
    }


    function _RBelowSellQuoteToken(PMMState memory state, uint256 payQuoteAmount)
        internal
        pure
        returns (
            uint256 // receiveBaseToken
        )
    {

        return
            DODOMath._GeneralIntegrate(
                state.Q0,
                state.Q.add(payQuoteAmount),
                state.Q,
                DecimalMath.reciprocalFloor(state.i),
                state.K
            );
    }

    function _RBelowSellBaseToken(PMMState memory state, uint256 payBaseAmount)
        internal
        pure
        returns (
            uint256 // receiveQuoteToken
        )
    {

        return
            DODOMath._SolveQuadraticFunctionForTrade(
                state.Q0,
                state.Q,
                payBaseAmount,
                state.i,
                state.K
            );
    }


    function _RAboveSellBaseToken(PMMState memory state, uint256 payBaseAmount)
        internal
        pure
        returns (
            uint256 // receiveQuoteToken
        )
    {

        return
            DODOMath._GeneralIntegrate(
                state.B0,
                state.B.add(payBaseAmount),
                state.B,
                state.i,
                state.K
            );
    }

    function _RAboveSellQuoteToken(PMMState memory state, uint256 payQuoteAmount)
        internal
        pure
        returns (
            uint256 // receiveBaseToken
        )
    {

        return
            DODOMath._SolveQuadraticFunctionForTrade(
                state.B0,
                state.B,
                payQuoteAmount,
                DecimalMath.reciprocalFloor(state.i),
                state.K
            );
    }


    function adjustedTarget(PMMState memory state) internal pure {

        if (state.R == RState.BELOW_ONE) {
            state.Q0 = DODOMath._SolveQuadraticFunctionForTarget(
                state.Q,
                state.B.sub(state.B0),
                state.i,
                state.K
            );
        } else if (state.R == RState.ABOVE_ONE) {
            state.B0 = DODOMath._SolveQuadraticFunctionForTarget(
                state.B,
                state.Q.sub(state.Q0),
                DecimalMath.reciprocalFloor(state.i),
                state.K
            );
        }
    }

    function getMidPrice(PMMState memory state) internal pure returns (uint256) {

        if (state.R == RState.BELOW_ONE) {
            uint256 R = DecimalMath.divFloor(state.Q0.mul(state.Q0).div(state.Q), state.Q);
            R = DecimalMath.ONE.sub(state.K).add(DecimalMath.mulFloor(state.K, R));
            return DecimalMath.divFloor(state.i, R);
        } else {
            uint256 R = DecimalMath.divFloor(state.B0.mul(state.B0).div(state.B), state.B);
            R = DecimalMath.ONE.sub(state.K).add(DecimalMath.mulFloor(state.K, R));
            return DecimalMath.mulFloor(state.i, R);
        }
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



contract ReentrancyGuard {

    bool private _ENTERED_;

    modifier preventReentrant() {

        require(!_ENTERED_, "REENTRANT");
        _ENTERED_ = true;
        _;
        _ENTERED_ = false;
    }
}




contract DSPStorage is ReentrancyGuard {

    using SafeMath for uint256;

    bool internal _DSP_INITIALIZED_;
    bool public _IS_OPEN_TWAP_ = false;
    

    address public _MAINTAINER_;

    IERC20 public _BASE_TOKEN_;
    IERC20 public _QUOTE_TOKEN_;

    uint112 public _BASE_RESERVE_;
    uint112 public _QUOTE_RESERVE_;
    uint32 public _BLOCK_TIMESTAMP_LAST_;
    
    uint256 public _BASE_PRICE_CUMULATIVE_LAST_;

    uint112 public _BASE_TARGET_;
    uint112 public _QUOTE_TARGET_;
    uint32 public _RState_;


    string public symbol;
    uint8 public decimals;
    string public name;

    uint256 public totalSupply;
    mapping(address => uint256) internal _SHARES_;
    mapping(address => mapping(address => uint256)) internal _ALLOWED_;


    bytes32 public DOMAIN_SEPARATOR;
    bytes32 public constant PERMIT_TYPEHASH =
        0x6e71edae12b1b97f4d1f60370fef10105fa2faae0126114a169c64845d6126c9;
    mapping(address => uint256) public nonces;


    IFeeRateModel public _MT_FEE_RATE_MODEL_;

    uint256 public _LP_FEE_RATE_;
    uint256 public _K_;
    uint256 public _I_;


    function getPMMState() public view returns (PMMPricing.PMMState memory state) {

        state.i = _I_;
        state.K = _K_;
        state.B = _BASE_RESERVE_;
        state.Q = _QUOTE_RESERVE_;
        state.B0 = _BASE_TARGET_; // will be calculated in adjustedTarget
        state.Q0 = _QUOTE_TARGET_;
        state.R = PMMPricing.RState(_RState_);
        PMMPricing.adjustedTarget(state);
    }

    function getPMMStateForCall()
        external
        view
        returns (
            uint256 i,
            uint256 K,
            uint256 B,
            uint256 Q,
            uint256 B0,
            uint256 Q0,
            uint256 R
        )
    {

        PMMPricing.PMMState memory state = getPMMState();
        i = state.i;
        K = state.K;
        B = state.B;
        Q = state.Q;
        B0 = state.B0;
        Q0 = state.Q0;
        R = uint256(state.R);
    }

    function getMidPrice() public view returns (uint256 midPrice) {

        return PMMPricing.getMidPrice(getPMMState());
    }
}





contract DSPVault is DSPStorage {

    using SafeMath for uint256;
    using SafeERC20 for IERC20;


    event Transfer(address indexed from, address indexed to, uint256 amount);

    event Approval(address indexed owner, address indexed spender, uint256 amount);

    event Mint(address indexed user, uint256 value);

    event Burn(address indexed user, uint256 value);


    function getVaultReserve() external view returns (uint256 baseReserve, uint256 quoteReserve) {

        baseReserve = _BASE_RESERVE_;
        quoteReserve = _QUOTE_RESERVE_;
    }

    function getUserFeeRate(address user)
        external
        view
        returns (uint256 lpFeeRate, uint256 mtFeeRate)
    {

        lpFeeRate = _LP_FEE_RATE_;
        mtFeeRate = _MT_FEE_RATE_MODEL_.getFeeRate(user);
    }


    function getBaseInput() public view returns (uint256 input) {

        return _BASE_TOKEN_.balanceOf(address(this)).sub(uint256(_BASE_RESERVE_));
    }

    function getQuoteInput() public view returns (uint256 input) {

        return _QUOTE_TOKEN_.balanceOf(address(this)).sub(uint256(_QUOTE_RESERVE_));
    }


    function _twapUpdate() internal {

        uint32 blockTimestamp = uint32(block.timestamp % 2**32);
        uint32 timeElapsed = blockTimestamp - _BLOCK_TIMESTAMP_LAST_;
        if (timeElapsed > 0 && _BASE_RESERVE_ != 0 && _QUOTE_RESERVE_ != 0) {
            _BASE_PRICE_CUMULATIVE_LAST_ += getMidPrice() * timeElapsed;
        }
        _BLOCK_TIMESTAMP_LAST_ = blockTimestamp;
    }


    function _setReserve(uint256 baseReserve, uint256 quoteReserve) internal {

        require(baseReserve <= uint112(-1) && quoteReserve <= uint112(-1), "OVERFLOW");
        _BASE_RESERVE_ = uint112(baseReserve);
        _QUOTE_RESERVE_ = uint112(quoteReserve);

        if (_IS_OPEN_TWAP_) _twapUpdate();
    }

    function _sync() internal {

        uint256 baseBalance = _BASE_TOKEN_.balanceOf(address(this));
        uint256 quoteBalance = _QUOTE_TOKEN_.balanceOf(address(this));
        require(baseBalance <= uint112(-1) && quoteBalance <= uint112(-1), "OVERFLOW");
        if (baseBalance != _BASE_RESERVE_) {
            _BASE_RESERVE_ = uint112(baseBalance);
        }
        if (quoteBalance != _QUOTE_RESERVE_) {
            _QUOTE_RESERVE_ = uint112(quoteBalance);
        }

        if (_IS_OPEN_TWAP_) _twapUpdate();
    }

    function sync() external preventReentrant {

        _sync();
    }

    function correctRState() public {

        if (_RState_ == uint32(PMMPricing.RState.BELOW_ONE) && _BASE_RESERVE_<_BASE_TARGET_) {
          _RState_ = uint32(PMMPricing.RState.ONE);
          _BASE_TARGET_ = _BASE_RESERVE_;
          _QUOTE_TARGET_ = _QUOTE_RESERVE_;
        }
        if (_RState_ == uint32(PMMPricing.RState.ABOVE_ONE) && _QUOTE_RESERVE_<_QUOTE_TARGET_) {
          _RState_ = uint32(PMMPricing.RState.ONE);
          _BASE_TARGET_ = _BASE_RESERVE_;
          _QUOTE_TARGET_ = _QUOTE_RESERVE_;
        }
    }


    function _transferBaseOut(address to, uint256 amount) internal {

        if (amount > 0) {
            _BASE_TOKEN_.safeTransfer(to, amount);
        }
    }

    function _transferQuoteOut(address to, uint256 amount) internal {

        if (amount > 0) {
            _QUOTE_TOKEN_.safeTransfer(to, amount);
        }
    }


    function transfer(address to, uint256 amount) public returns (bool) {

        require(amount <= _SHARES_[msg.sender], "BALANCE_NOT_ENOUGH");

        _SHARES_[msg.sender] = _SHARES_[msg.sender].sub(amount);
        _SHARES_[to] = _SHARES_[to].add(amount);
        emit Transfer(msg.sender, to, amount);
        return true;
    }

    function balanceOf(address owner) external view returns (uint256 balance) {

        return _SHARES_[owner];
    }

    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) public returns (bool) {

        require(amount <= _SHARES_[from], "BALANCE_NOT_ENOUGH");
        require(amount <= _ALLOWED_[from][msg.sender], "ALLOWANCE_NOT_ENOUGH");

        _SHARES_[from] = _SHARES_[from].sub(amount);
        _SHARES_[to] = _SHARES_[to].add(amount);
        _ALLOWED_[from][msg.sender] = _ALLOWED_[from][msg.sender].sub(amount);
        emit Transfer(from, to, amount);
        return true;
    }

    function approve(address spender, uint256 amount) public returns (bool) {

        _approve(msg.sender, spender, amount);
        return true;
    }

    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) private {

        _ALLOWED_[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function allowance(address owner, address spender) public view returns (uint256) {

        return _ALLOWED_[owner][spender];
    }

    function _mint(address user, uint256 value) internal {

        require(value > 1000, "MINT_AMOUNT_NOT_ENOUGH");
        _SHARES_[user] = _SHARES_[user].add(value);
        totalSupply = totalSupply.add(value);
        emit Mint(user, value);
        emit Transfer(address(0), user, value);
    }

    function _burn(address user, uint256 value) internal {

        _SHARES_[user] = _SHARES_[user].sub(value);
        totalSupply = totalSupply.sub(value);
        emit Burn(user, value);
        emit Transfer(user, address(0), value);
    }


    function permit(
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external {

        require(deadline >= block.timestamp, "DODO_DSP_LP: EXPIRED");
        bytes32 digest =
            keccak256(
                abi.encodePacked(
                    "\x19\x01",
                    DOMAIN_SEPARATOR,
                    keccak256(
                        abi.encode(
                            PERMIT_TYPEHASH,
                            owner,
                            spender,
                            value,
                            nonces[owner]++,
                            deadline
                        )
                    )
                )
            );
        address recoveredAddress = ecrecover(digest, v, r, s);
        require(
            recoveredAddress != address(0) && recoveredAddress == owner,
            "DODO_DSP_LP: INVALID_SIGNATURE"
        );
        _approve(owner, spender, value);
    }
}



interface IDODOCallee {

    function DVMSellShareCall(
        address sender,
        uint256 burnShareAmount,
        uint256 baseAmount,
        uint256 quoteAmount,
        bytes calldata data
    ) external;


    function DVMFlashLoanCall(
        address sender,
        uint256 baseAmount,
        uint256 quoteAmount,
        bytes calldata data
    ) external;


    function DPPFlashLoanCall(
        address sender,
        uint256 baseAmount,
        uint256 quoteAmount,
        bytes calldata data
    ) external;


    function DSPFlashLoanCall(
        address sender,
        uint256 baseAmount,
        uint256 quoteAmount,
        bytes calldata data
    ) external;


    function CPCancelCall(
        address sender,
        uint256 amount,
        bytes calldata data
    ) external;


	function CPClaimBidCall(
        address sender,
        uint256 baseAmount,
        uint256 quoteAmount,
        bytes calldata data
    ) external;

}



contract DSPTrader is DSPVault {

    using SafeMath for uint256;


    event DODOSwap(
        address fromToken,
        address toToken,
        uint256 fromAmount,
        uint256 toAmount,
        address trader,
        address receiver
    );

    event DODOFlashLoan(address borrower, address assetTo, uint256 baseAmount, uint256 quoteAmount);

    event RChange(PMMPricing.RState newRState);


    function sellBase(address to) external preventReentrant returns (uint256 receiveQuoteAmount) {

        uint256 baseBalance = _BASE_TOKEN_.balanceOf(address(this));
        uint256 baseInput = baseBalance.sub(uint256(_BASE_RESERVE_));
        uint256 mtFee;
        uint256 newBaseTarget;
        PMMPricing.RState newRState;
        (receiveQuoteAmount, mtFee, newRState, newBaseTarget) = querySellBase(tx.origin, baseInput);

        _transferQuoteOut(to, receiveQuoteAmount);
        _transferQuoteOut(_MAINTAINER_, mtFee);

        if (_RState_ != uint32(newRState)) {
            require(newBaseTarget <= uint112(-1), "OVERFLOW");
            _BASE_TARGET_ = uint112(newBaseTarget);
            _RState_ = uint32(newRState);
            emit RChange(newRState);
        }

        _setReserve(baseBalance, _QUOTE_TOKEN_.balanceOf(address(this)));

        emit DODOSwap(
            address(_BASE_TOKEN_),
            address(_QUOTE_TOKEN_),
            baseInput,
            receiveQuoteAmount,
            msg.sender,
            to
        );
    }

    function sellQuote(address to) external preventReentrant returns (uint256 receiveBaseAmount) {

        uint256 quoteBalance = _QUOTE_TOKEN_.balanceOf(address(this));
        uint256 quoteInput = quoteBalance.sub(uint256(_QUOTE_RESERVE_));
        uint256 mtFee;
        uint256 newQuoteTarget;
        PMMPricing.RState newRState;
        (receiveBaseAmount, mtFee, newRState, newQuoteTarget) = querySellQuote(
            tx.origin,
            quoteInput
        );

        _transferBaseOut(to, receiveBaseAmount);
        _transferBaseOut(_MAINTAINER_, mtFee);

        if (_RState_ != uint32(newRState)) {
            require(newQuoteTarget <= uint112(-1), "OVERFLOW");
            _QUOTE_TARGET_ = uint112(newQuoteTarget);
            _RState_ = uint32(newRState);
            emit RChange(newRState);
        }

        _setReserve(_BASE_TOKEN_.balanceOf(address(this)), quoteBalance);

        emit DODOSwap(
            address(_QUOTE_TOKEN_),
            address(_BASE_TOKEN_),
            quoteInput,
            receiveBaseAmount,
            msg.sender,
            to
        );
    }

    function flashLoan(
        uint256 baseAmount,
        uint256 quoteAmount,
        address assetTo,
        bytes calldata data
    ) external preventReentrant {

        _transferBaseOut(assetTo, baseAmount);
        _transferQuoteOut(assetTo, quoteAmount);

        if (data.length > 0)
            IDODOCallee(assetTo).DSPFlashLoanCall(msg.sender, baseAmount, quoteAmount, data);

        uint256 baseBalance = _BASE_TOKEN_.balanceOf(address(this));
        uint256 quoteBalance = _QUOTE_TOKEN_.balanceOf(address(this));

        require(
            baseBalance >= _BASE_RESERVE_ || quoteBalance >= _QUOTE_RESERVE_,
            "FLASH_LOAN_FAILED"
        );

        if (baseBalance < _BASE_RESERVE_) {
            uint256 quoteInput = quoteBalance.sub(uint256(_QUOTE_RESERVE_));
            (
                uint256 receiveBaseAmount,
                uint256 mtFee,
                PMMPricing.RState newRState,
                uint256 newQuoteTarget
            ) = querySellQuote(tx.origin, quoteInput); // revert if quoteBalance<quoteReserve
            require(
                uint256(_BASE_RESERVE_).sub(baseBalance) <= receiveBaseAmount,
                "FLASH_LOAN_FAILED"
            );

            _transferBaseOut(_MAINTAINER_, mtFee);
            if (_RState_ != uint32(newRState)) {
                require(newQuoteTarget <= uint112(-1), "OVERFLOW");
                _QUOTE_TARGET_ = uint112(newQuoteTarget);
                _RState_ = uint32(newRState);
                emit RChange(newRState);
            }
            emit DODOSwap(
                address(_QUOTE_TOKEN_),
                address(_BASE_TOKEN_),
                quoteInput,
                receiveBaseAmount,
                msg.sender,
                assetTo
            );
        }

        if (quoteBalance < _QUOTE_RESERVE_) {
            uint256 baseInput = baseBalance.sub(uint256(_BASE_RESERVE_));
            (
                uint256 receiveQuoteAmount,
                uint256 mtFee,
                PMMPricing.RState newRState,
                uint256 newBaseTarget
            ) = querySellBase(tx.origin, baseInput); // revert if baseBalance<baseReserve
            require(
                uint256(_QUOTE_RESERVE_).sub(quoteBalance) <= receiveQuoteAmount,
                "FLASH_LOAN_FAILED"
            );

            _transferQuoteOut(_MAINTAINER_, mtFee);
            if (_RState_ != uint32(newRState)) {
                require(newBaseTarget <= uint112(-1), "OVERFLOW");
                _BASE_TARGET_ = uint112(newBaseTarget);
                _RState_ = uint32(newRState);
                emit RChange(newRState);
            }
            emit DODOSwap(
                address(_BASE_TOKEN_),
                address(_QUOTE_TOKEN_),
                baseInput,
                receiveQuoteAmount,
                msg.sender,
                assetTo
            );
        }

        _sync();

        emit DODOFlashLoan(msg.sender, assetTo, baseAmount, quoteAmount);
    }


    function querySellBase(address trader, uint256 payBaseAmount)
        public
        view
        returns (
            uint256 receiveQuoteAmount,
            uint256 mtFee,
            PMMPricing.RState newRState,
            uint256 newBaseTarget
        )
    {

        PMMPricing.PMMState memory state = getPMMState();
        (receiveQuoteAmount, newRState) = PMMPricing.sellBaseToken(state, payBaseAmount);

        uint256 lpFeeRate = _LP_FEE_RATE_;
        uint256 mtFeeRate = _MT_FEE_RATE_MODEL_.getFeeRate(trader);
        mtFee = DecimalMath.mulFloor(receiveQuoteAmount, mtFeeRate);
        receiveQuoteAmount = receiveQuoteAmount
            .sub(DecimalMath.mulFloor(receiveQuoteAmount, lpFeeRate))
            .sub(mtFee);
        newBaseTarget = state.B0;
    }

    function querySellQuote(address trader, uint256 payQuoteAmount)
        public
        view
        returns (
            uint256 receiveBaseAmount,
            uint256 mtFee,
            PMMPricing.RState newRState,
            uint256 newQuoteTarget
        )
    {

        PMMPricing.PMMState memory state = getPMMState();
        (receiveBaseAmount, newRState) = PMMPricing.sellQuoteToken(state, payQuoteAmount);

        uint256 lpFeeRate = _LP_FEE_RATE_;
        uint256 mtFeeRate = _MT_FEE_RATE_MODEL_.getFeeRate(trader);
        mtFee = DecimalMath.mulFloor(receiveBaseAmount, mtFeeRate);
        receiveBaseAmount = receiveBaseAmount
            .sub(DecimalMath.mulFloor(receiveBaseAmount, lpFeeRate))
            .sub(mtFee);
        newQuoteTarget = state.Q0;
    }
}



contract DSPFunding is DSPVault {


    event BuyShares(address to, uint256 increaseShares, uint256 totalShares);

    event SellShares(address payer, address to, uint256 decreaseShares, uint256 totalShares);


    function buyShares(address to)
        external
        preventReentrant
        returns (
            uint256 shares,
            uint256 baseInput,
            uint256 quoteInput
        )
    {

        uint256 baseBalance = _BASE_TOKEN_.balanceOf(address(this));
        uint256 quoteBalance = _QUOTE_TOKEN_.balanceOf(address(this));
        uint256 baseReserve = _BASE_RESERVE_;
        uint256 quoteReserve = _QUOTE_RESERVE_;

        baseInput = baseBalance.sub(baseReserve);
        quoteInput = quoteBalance.sub(quoteReserve);
        require(baseInput > 0, "NO_BASE_INPUT");

        if (totalSupply == 0) {
            shares = quoteBalance < DecimalMath.mulFloor(baseBalance, _I_)
                ? DecimalMath.divFloor(quoteBalance, _I_)
                : baseBalance;
            _BASE_TARGET_ = uint112(shares);
            _QUOTE_TARGET_ = uint112(DecimalMath.mulFloor(shares, _I_));
        } else if (baseReserve > 0 && quoteReserve > 0) {
            uint256 baseInputRatio = DecimalMath.divFloor(baseInput, baseReserve);
            uint256 quoteInputRatio = DecimalMath.divFloor(quoteInput, quoteReserve);
            uint256 mintRatio = quoteInputRatio < baseInputRatio ? quoteInputRatio : baseInputRatio;
            shares = DecimalMath.mulFloor(totalSupply, mintRatio);

            _BASE_TARGET_ = uint112(uint256(_BASE_TARGET_).add(DecimalMath.mulFloor(uint256(_BASE_TARGET_), mintRatio)));
            _QUOTE_TARGET_ = uint112(uint256(_QUOTE_TARGET_).add(DecimalMath.mulFloor(uint256(_QUOTE_TARGET_), mintRatio)));
        }
        _mint(to, shares);
        _setReserve(baseBalance, quoteBalance);
        emit BuyShares(to, shares, _SHARES_[to]);
    }

    function sellShares(
        uint256 shareAmount,
        address to,
        uint256 baseMinAmount,
        uint256 quoteMinAmount,
        bytes calldata data,
        uint256 deadline
    ) external preventReentrant returns (uint256 baseAmount, uint256 quoteAmount) {

        require(deadline >= block.timestamp, "TIME_EXPIRED");
        require(shareAmount <= _SHARES_[msg.sender], "DLP_NOT_ENOUGH");

        uint256 baseBalance = _BASE_TOKEN_.balanceOf(address(this));
        uint256 quoteBalance = _QUOTE_TOKEN_.balanceOf(address(this));
        uint256 totalShares = totalSupply;

        baseAmount = baseBalance.mul(shareAmount).div(totalShares);
        quoteAmount = quoteBalance.mul(shareAmount).div(totalShares);

        _BASE_TARGET_ = uint112(uint256(_BASE_TARGET_).sub(uint256(_BASE_TARGET_).mul(shareAmount).divCeil(totalShares)));
        _QUOTE_TARGET_ = uint112(uint256(_QUOTE_TARGET_).sub(uint256(_QUOTE_TARGET_).mul(shareAmount).divCeil(totalShares)));

        require(
            baseAmount >= baseMinAmount && quoteAmount >= quoteMinAmount,
            "WITHDRAW_NOT_ENOUGH"
        );

        _burn(msg.sender, shareAmount);
        _transferBaseOut(to, baseAmount);
        _transferQuoteOut(to, quoteAmount);
        _sync();

        if (data.length > 0) {
            IDODOCallee(to).DVMSellShareCall(
                msg.sender,
                shareAmount,
                baseAmount,
                quoteAmount,
                data
            );
        }

        emit SellShares(msg.sender, to, shareAmount, _SHARES_[msg.sender]);
    }
}





contract DSP is DSPTrader, DSPFunding {

    function init(
        address maintainer,
        address baseTokenAddress,
        address quoteTokenAddress,
        uint256 lpFeeRate,
        address mtFeeRateModel,
        uint256 i,
        uint256 k,
        bool isOpenTWAP
    ) external {

        require(!_DSP_INITIALIZED_, "DSP_INITIALIZED");
        _DSP_INITIALIZED_ = true;
        
        require(baseTokenAddress != quoteTokenAddress, "BASE_QUOTE_CAN_NOT_BE_SAME");
        _BASE_TOKEN_ = IERC20(baseTokenAddress);
        _QUOTE_TOKEN_ = IERC20(quoteTokenAddress);

        require(i > 0 && i <= 10**36);
        _I_ = i;

        require(k <= 10**18);
        _K_ = k;

        _LP_FEE_RATE_ = lpFeeRate;
        _MT_FEE_RATE_MODEL_ = IFeeRateModel(mtFeeRateModel);
        _MAINTAINER_ = maintainer;

        _IS_OPEN_TWAP_ = isOpenTWAP;
        if (isOpenTWAP) _BLOCK_TIMESTAMP_LAST_ = uint32(block.timestamp % 2**32);

        string memory connect = "_";
        string memory suffix = "DLP";

        name = string(abi.encodePacked(suffix, connect, addressToShortString(address(this))));
        symbol = "DLP";
        decimals = _BASE_TOKEN_.decimals();

        uint256 chainId;
        assembly {
            chainId := chainid()
        }
        DOMAIN_SEPARATOR = keccak256(
            abi.encode(
                0x8b73c3c69bb8fe3d512ecc4cf759cc79239f7b179b0ffacaa9a75d522b39400f,
                keccak256(bytes(name)),
                keccak256(bytes("1")),
                chainId,
                address(this)
            )
        );
    }

    function addressToShortString(address _addr) public pure returns (string memory) {

        bytes32 value = bytes32(uint256(_addr));
        bytes memory alphabet = "0123456789abcdef";

        bytes memory str = new bytes(8);
        for (uint256 i = 0; i < 4; i++) {
            str[i * 2] = alphabet[uint8(value[i + 12] >> 4)];
            str[1 + i * 2] = alphabet[uint8(value[i + 12] & 0x0f)];
        }
        return string(str);
    }


    function version() external pure returns (string memory) {

        return "DSP 1.0.1";
    }
}