
pragma solidity 0.4.24;
pragma experimental "v0.5.0";



library SafeMath {


  function mul(uint256 _a, uint256 _b) internal pure returns (uint256 c) {

    if (_a == 0) {
      return 0;
    }

    c = _a * _b;
    assert(c / _a == _b);
    return c;
  }

  function div(uint256 _a, uint256 _b) internal pure returns (uint256) {

    return _a / _b;
  }

  function sub(uint256 _a, uint256 _b) internal pure returns (uint256) {

    assert(_b <= _a);
    return _a - _b;
  }

  function add(uint256 _a, uint256 _b) internal pure returns (uint256 c) {

    c = _a + _b;
    assert(c >= _a);
    return c;
  }
}


library Math {

  function max64(uint64 _a, uint64 _b) internal pure returns (uint64) {

    return _a >= _b ? _a : _b;
  }

  function min64(uint64 _a, uint64 _b) internal pure returns (uint64) {

    return _a < _b ? _a : _b;
  }

  function max256(uint256 _a, uint256 _b) internal pure returns (uint256) {

    return _a >= _b ? _a : _b;
  }

  function min256(uint256 _a, uint256 _b) internal pure returns (uint256) {

    return _a < _b ? _a : _b;
  }
}


library Fraction {

    struct Fraction128 {
        uint128 num;
        uint128 den;
    }
}


library FractionMath {

    using SafeMath for uint256;
    using SafeMath for uint128;

    function add(
        Fraction.Fraction128 memory a,
        Fraction.Fraction128 memory b
    )
        internal
        pure
        returns (Fraction.Fraction128 memory)
    {

        uint256 left = a.num.mul(b.den);
        uint256 right = b.num.mul(a.den);
        uint256 denominator = a.den.mul(b.den);

        if (left + right < left) {
            left = left.div(2);
            right = right.div(2);
            denominator = denominator.div(2);
        }

        return bound(left.add(right), denominator);
    }

    function sub1Over(
        Fraction.Fraction128 memory a,
        uint128 d
    )
        internal
        pure
        returns (Fraction.Fraction128 memory)
    {

        if (a.den % d == 0) {
            return bound(
                a.num.sub(a.den.div(d)),
                a.den
            );
        }
        return bound(
            a.num.mul(d).sub(a.den),
            a.den.mul(d)
        );
    }

    function div(
        Fraction.Fraction128 memory a,
        uint128 d
    )
        internal
        pure
        returns (Fraction.Fraction128 memory)
    {

        if (a.num % d == 0) {
            return bound(
                a.num.div(d),
                a.den
            );
        }
        return bound(
            a.num,
            a.den.mul(d)
        );
    }

    function mul(
        Fraction.Fraction128 memory a,
        Fraction.Fraction128 memory b
    )
        internal
        pure
        returns (Fraction.Fraction128 memory)
    {

        return bound(
            a.num.mul(b.num),
            a.den.mul(b.den)
        );
    }

    function bound(
        uint256 num,
        uint256 den
    )
        internal
        pure
        returns (Fraction.Fraction128 memory)
    {

        uint256 max = num > den ? num : den;
        uint256 first128Bits = (max >> 128);
        if (first128Bits != 0) {
            first128Bits += 1;
            num /= first128Bits;
            den /= first128Bits;
        }

        assert(den != 0); // coverage-enable-line
        assert(den < 2**128);
        assert(num < 2**128);

        return Fraction.Fraction128({
            num: uint128(num),
            den: uint128(den)
        });
    }

    function copy(
        Fraction.Fraction128 memory a
    )
        internal
        pure
        returns (Fraction.Fraction128 memory)
    {

        validate(a);
        return Fraction.Fraction128({ num: a.num, den: a.den });
    }


    function validate(
        Fraction.Fraction128 memory a
    )
        private
        pure
    {

        assert(a.den != 0); // coverage-enable-line
    }
}


library Exponent {

    using SafeMath for uint256;
    using FractionMath for Fraction.Fraction128;


    uint128 constant public MAX_NUMERATOR = 340282366920938463463374607431768211455;

    uint256 constant public MAX_PRECOMPUTE_PRECISION = 32;

    uint256 constant public NUM_PRECOMPUTED_INTEGERS = 32;


    function exp(
        Fraction.Fraction128 memory X,
        uint256 precomputePrecision,
        uint256 maclaurinPrecision
    )
        internal
        pure
        returns (Fraction.Fraction128 memory)
    {

        require(
            precomputePrecision <= MAX_PRECOMPUTE_PRECISION,
            "Exponent#exp: Precompute precision over maximum"
        );

        Fraction.Fraction128 memory Xcopy = X.copy();
        if (Xcopy.num == 0) { // e^0 = 1
            return ONE();
        }

        uint256 integerX = uint256(Xcopy.num).div(Xcopy.den);

        if (integerX == 0) {
            return expHybrid(Xcopy, precomputePrecision, maclaurinPrecision);
        }

        Fraction.Fraction128 memory expOfInt =
            getPrecomputedEToThe(integerX % NUM_PRECOMPUTED_INTEGERS);
        while (integerX >= NUM_PRECOMPUTED_INTEGERS) {
            expOfInt = expOfInt.mul(getPrecomputedEToThe(NUM_PRECOMPUTED_INTEGERS));
            integerX -= NUM_PRECOMPUTED_INTEGERS;
        }

        Fraction.Fraction128 memory decimalX = Fraction.Fraction128({
            num: Xcopy.num % Xcopy.den,
            den: Xcopy.den
        });
        return expHybrid(decimalX, precomputePrecision, maclaurinPrecision).mul(expOfInt);
    }

    function expHybrid(
        Fraction.Fraction128 memory X,
        uint256 precomputePrecision,
        uint256 maclaurinPrecision
    )
        internal
        pure
        returns (Fraction.Fraction128 memory)
    {

        assert(precomputePrecision <= MAX_PRECOMPUTE_PRECISION);
        assert(X.num < X.den);

        Fraction.Fraction128 memory Xtemp = X.copy();
        if (Xtemp.num == 0) { // e^0 = 1
            return ONE();
        }

        Fraction.Fraction128 memory result = ONE();

        uint256 d = 1; // 2^i
        for (uint256 i = 1; i <= precomputePrecision; i++) {
            d *= 2;

            if (d.mul(Xtemp.num) >= Xtemp.den) {
                Xtemp = Xtemp.sub1Over(uint128(d));
                result = result.mul(getPrecomputedEToTheHalfToThe(i));
            }
        }
        return result.mul(expMaclaurin(Xtemp, maclaurinPrecision));
    }

    function expMaclaurin(
        Fraction.Fraction128 memory X,
        uint256 precision
    )
        internal
        pure
        returns (Fraction.Fraction128 memory)
    {

        Fraction.Fraction128 memory Xcopy = X.copy();
        if (Xcopy.num == 0) { // e^0 = 1
            return ONE();
        }

        Fraction.Fraction128 memory result = ONE();
        Fraction.Fraction128 memory Xtemp = ONE();
        for (uint256 i = 1; i <= precision; i++) {
            Xtemp = Xtemp.mul(Xcopy.div(uint128(i)));
            result = result.add(Xtemp);
        }
        return result;
    }

    function getPrecomputedEToTheHalfToThe(
        uint256 x
    )
        internal
        pure
        returns (Fraction.Fraction128 memory)
    {

        assert(x <= MAX_PRECOMPUTE_PRECISION);

        uint128 denominator = [
            125182886983370532117250726298150828301,
            206391688497133195273760705512282642279,
            265012173823417992016237332255925138361,
            300298134811882980317033350418940119802,
            319665700530617779809390163992561606014,
            329812979126047300897653247035862915816,
            335006777809430963166468914297166288162,
            337634268532609249517744113622081347950,
            338955731696479810470146282672867036734,
            339618401537809365075354109784799900812,
            339950222128463181389559457827561204959,
            340116253979683015278260491021941090650,
            340199300311581465057079429423749235412,
            340240831081268226777032180141478221816,
            340261598367316729254995498374473399540,
            340271982485676106947851156443492415142,
            340277174663693808406010255284800906112,
            340279770782412691177936847400746725466,
            340281068849199706686796915841848278311,
            340281717884450116236033378667952410919,
            340282042402539547492367191008339680733,
            340282204661700319870089970029119685699,
            340282285791309720262481214385569134454,
            340282326356121674011576912006427792656,
            340282346638529464274601981200276914173,
            340282356779733812753265346086924801364,
            340282361850336100329388676752133324799,
            340282364385637272451648746721404212564,
            340282365653287865596328444437856608255,
            340282366287113163939555716675618384724,
            340282366604025813553891209601455838559,
            340282366762482138471739420386372790954,
            340282366841710300958333641874363209044
        ][x];
        return Fraction.Fraction128({
            num: MAX_NUMERATOR,
            den: denominator
        });
    }

    function getPrecomputedEToThe(
        uint256 x
    )
        internal
        pure
        returns (Fraction.Fraction128 memory)
    {

        assert(x <= NUM_PRECOMPUTED_INTEGERS);

        uint128 denominator = [
            340282366920938463463374607431768211455,
            125182886983370532117250726298150828301,
            46052210507670172419625860892627118820,
            16941661466271327126146327822211253888,
            6232488952727653950957829210887653621,
            2292804553036637136093891217529878878,
            843475657686456657683449904934172134,
            310297353591408453462393329342695980,
            114152017036184782947077973323212575,
            41994180235864621538772677139808695,
            15448795557622704876497742989562086,
            5683294276510101335127414470015662,
            2090767122455392675095471286328463,
            769150240628514374138961856925097,
            282954560699298259527814398449860,
            104093165666968799599694528310221,
            38293735615330848145349245349513,
            14087478058534870382224480725096,
            5182493555688763339001418388912,
            1906532833141383353974257736699,
            701374233231058797338605168652,
            258021160973090761055471434334,
            94920680509187392077350434438,
            34919366901332874995585576427,
            12846117181722897538509298435,
            4725822410035083116489797150,
            1738532907279185132707372378,
            639570514388029575350057932,
            235284843422800231081973821,
            86556456714490055457751527,
            31842340925906738090071268,
            11714142585413118080082437,
            4309392228124372433711936
        ][x];
        return Fraction.Fraction128({
            num: MAX_NUMERATOR,
            den: denominator
        });
    }


    function ONE()
        private
        pure
        returns (Fraction.Fraction128 memory)
    {

        return Fraction.Fraction128({ num: 1, den: 1 });
    }
}


library MathHelpers {

    using SafeMath for uint256;

    function getPartialAmount(
        uint256 numerator,
        uint256 denominator,
        uint256 target
    )
        internal
        pure
        returns (uint256)
    {

        return numerator.mul(target).div(denominator);
    }

    function getPartialAmountRoundedUp(
        uint256 numerator,
        uint256 denominator,
        uint256 target
    )
        internal
        pure
        returns (uint256)
    {

        return divisionRoundedUp(numerator.mul(target), denominator);
    }

    function divisionRoundedUp(
        uint256 numerator,
        uint256 denominator
    )
        internal
        pure
        returns (uint256)
    {

        assert(denominator != 0); // coverage-enable-line
        if (numerator == 0) {
            return 0;
        }
        return numerator.sub(1).div(denominator).add(1);
    }

    function maxUint256(
    )
        internal
        pure
        returns (uint256)
    {

        return 2 ** 256 - 1;
    }

    function maxUint32(
    )
        internal
        pure
        returns (uint32)
    {

        return 2 ** 32 - 1;
    }

    function getNumBits(
        uint256 n
    )
        internal
        pure
        returns (uint256)
    {

        uint256 first = 0;
        uint256 last = 256;
        while (first < last) {
            uint256 check = (first + last) / 2;
            if ((n >> check) == 0) {
                last = check;
            } else {
                first = check + 1;
            }
        }
        assert(first <= 256);
        return first;
    }
}


library InterestImpl {

    using SafeMath for uint256;
    using FractionMath for Fraction.Fraction128;


    uint256 constant DEFAULT_PRECOMPUTE_PRECISION = 11;

    uint256 constant DEFAULT_MACLAURIN_PRECISION = 5;

    uint256 constant MAXIMUM_EXPONENT = 80;

    uint128 constant E_TO_MAXIUMUM_EXPONENT = 55406223843935100525711733958316613;


    function getCompoundedInterest(
        uint256 principal,
        uint256 interestRate,
        uint256 secondsOfInterest
    )
        public
        pure
        returns (uint256)
    {

        uint256 numerator = interestRate.mul(secondsOfInterest);
        uint128 denominator = (10**8) * (365 * 1 days);

        assert(numerator < 2**128);

        Fraction.Fraction128 memory rt = Fraction.Fraction128({
            num: uint128(numerator),
            den: denominator
        });

        Fraction.Fraction128 memory eToRT;
        if (numerator.div(denominator) >= MAXIMUM_EXPONENT) {
            eToRT = Fraction.Fraction128({
                num: E_TO_MAXIUMUM_EXPONENT,
                den: 1
            });
        } else {
            eToRT = Exponent.exp(
                rt,
                DEFAULT_PRECOMPUTE_PRECISION,
                DEFAULT_MACLAURIN_PRECISION
            );
        }

        assert(eToRT.num >= eToRT.den);

        return safeMultiplyUint256ByFraction(principal, eToRT);
    }


    function safeMultiplyUint256ByFraction(
        uint256 n,
        Fraction.Fraction128 memory f
    )
        private
        pure
        returns (uint256)
    {

        uint256 term1 = n.div(2 ** 128); // first 128 bits
        uint256 term2 = n % (2 ** 128); // second 128 bits

        if (term1 > 0) {
            term1 = term1.mul(f.num);
            uint256 numBits = MathHelpers.getNumBits(term1);

            term1 = MathHelpers.divisionRoundedUp(
                term1 << (uint256(256).sub(numBits)),
                f.den);

            if (numBits > 128) {
                term1 = term1 << (numBits.sub(128));
            } else if (numBits < 128) {
                term1 = term1 >> (uint256(128).sub(numBits));
            }
        }

        term2 = MathHelpers.getPartialAmountRoundedUp(
            f.num,
            f.den,
            term2
        );

        return term1.add(term2);
    }
}


library MarginState {

    struct State {
        address VAULT;

        address TOKEN_PROXY;

        mapping (bytes32 => uint256) loanFills;

        mapping (bytes32 => uint256) loanCancels;

        mapping (bytes32 => MarginCommon.Position) positions;

        mapping (bytes32 => bool) closedPositions;

        mapping (bytes32 => uint256) totalOwedTokenRepaidToLender;
    }
}


library AddressUtils {


  function isContract(address _addr) internal view returns (bool) {

    uint256 size;
    assembly { size := extcodesize(_addr) }
    return size > 0;
  }

}


interface LoanOwner {



    function receiveLoanOwnership(
        address from,
        bytes32 positionId
    )
        external
        returns (address);

}


interface PositionOwner {



    function receivePositionOwnership(
        address from,
        bytes32 positionId
    )
        external
        returns (address);

}


library TransferInternal {



    event LoanTransferred(
        bytes32 indexed positionId,
        address indexed from,
        address indexed to
    );

    event PositionTransferred(
        bytes32 indexed positionId,
        address indexed from,
        address indexed to
    );


    function grantLoanOwnership(
        bytes32 positionId,
        address oldOwner,
        address newOwner
    )
        internal
        returns (address)
    {

        if (oldOwner != address(0)) {
            emit LoanTransferred(positionId, oldOwner, newOwner);
        }

        if (AddressUtils.isContract(newOwner)) {
            address nextOwner =
                LoanOwner(newOwner).receiveLoanOwnership(oldOwner, positionId);
            if (nextOwner != newOwner) {
                return grantLoanOwnership(positionId, newOwner, nextOwner);
            }
        }

        require(
            newOwner != address(0),
            "TransferInternal#grantLoanOwnership: New owner did not consent to owning loan"
        );

        return newOwner;
    }

    function grantPositionOwnership(
        bytes32 positionId,
        address oldOwner,
        address newOwner
    )
        internal
        returns (address)
    {

        if (oldOwner != address(0)) {
            emit PositionTransferred(positionId, oldOwner, newOwner);
        }

        if (AddressUtils.isContract(newOwner)) {
            address nextOwner =
                PositionOwner(newOwner).receivePositionOwnership(oldOwner, positionId);
            if (nextOwner != newOwner) {
                return grantPositionOwnership(positionId, newOwner, nextOwner);
            }
        }

        require(
            newOwner != address(0),
            "TransferInternal#grantPositionOwnership: New owner did not consent to owning position"
        );

        return newOwner;
    }
}


contract Ownable {

  address public owner;

  event OwnershipRenounced(address indexed previousOwner);
  event OwnershipTransferred(
    address indexed previousOwner,
    address indexed newOwner
  );

  constructor() public {
    owner = msg.sender;
  }

  modifier onlyOwner() {

    require(msg.sender == owner);
    _;
  }

  function renounceOwnership() public onlyOwner {

    emit OwnershipRenounced(owner);
    owner = address(0);
  }

  function transferOwnership(address _newOwner) public onlyOwner {

    _transferOwnership(_newOwner);
  }

  function _transferOwnership(address _newOwner) internal {

    require(_newOwner != address(0));
    emit OwnershipTransferred(owner, _newOwner);
    owner = _newOwner;
  }
}


contract AccessControlledBase {


    mapping (address => bool) public authorized;


    event AccessGranted(
        address who
    );

    event AccessRevoked(
        address who
    );


    modifier requiresAuthorization() {

        require(
            authorized[msg.sender],
            "AccessControlledBase#requiresAuthorization: Sender not authorized"
        );
        _;
    }
}


contract StaticAccessControlled is AccessControlledBase, Ownable {

    using SafeMath for uint256;


    uint256 public GRACE_PERIOD_EXPIRATION;


    constructor(
        uint256 gracePeriod
    )
        public
        Ownable()
    {
        GRACE_PERIOD_EXPIRATION = block.timestamp.add(gracePeriod);
    }


    function grantAccess(
        address who
    )
        external
        onlyOwner
    {

        require(
            block.timestamp < GRACE_PERIOD_EXPIRATION,
            "StaticAccessControlled#grantAccess: Cannot grant access after grace period"
        );

        emit AccessGranted(who);
        authorized[who] = true;
    }
}


interface GeneralERC20 {

    function totalSupply(
    )
        external
        view
        returns (uint256);


    function balanceOf(
        address who
    )
        external
        view
        returns (uint256);


    function allowance(
        address owner,
        address spender
    )
        external
        view
        returns (uint256);


    function transfer(
        address to,
        uint256 value
    )
        external;


    function transferFrom(
        address from,
        address to,
        uint256 value
    )
        external;


    function approve(
        address spender,
        uint256 value
    )
        external;

}


library TokenInteract {

    function balanceOf(
        address token,
        address owner
    )
        internal
        view
        returns (uint256)
    {

        return GeneralERC20(token).balanceOf(owner);
    }

    function allowance(
        address token,
        address owner,
        address spender
    )
        internal
        view
        returns (uint256)
    {

        return GeneralERC20(token).allowance(owner, spender);
    }

    function approve(
        address token,
        address spender,
        uint256 amount
    )
        internal
    {

        GeneralERC20(token).approve(spender, amount);

        require(
            checkSuccess(),
            "TokenInteract#approve: Approval failed"
        );
    }

    function transfer(
        address token,
        address to,
        uint256 amount
    )
        internal
    {

        address from = address(this);
        if (
            amount == 0
            || from == to
        ) {
            return;
        }

        GeneralERC20(token).transfer(to, amount);

        require(
            checkSuccess(),
            "TokenInteract#transfer: Transfer failed"
        );
    }

    function transferFrom(
        address token,
        address from,
        address to,
        uint256 amount
    )
        internal
    {

        if (
            amount == 0
            || from == to
        ) {
            return;
        }

        GeneralERC20(token).transferFrom(from, to, amount);

        require(
            checkSuccess(),
            "TokenInteract#transferFrom: TransferFrom failed"
        );
    }


    function checkSuccess(
    )
        private
        pure
        returns (bool)
    {

        uint256 returnValue = 0;

        assembly {
            switch returndatasize

            case 0x0 {
                returnValue := 1
            }

            case 0x20 {
                returndatacopy(0x0, 0x0, 0x20)

                returnValue := mload(0x0)
            }

            default { }
        }

        return returnValue != 0;
    }
}


contract TokenProxy is StaticAccessControlled {

    using SafeMath for uint256;


    constructor(
        uint256 gracePeriod
    )
        public
        StaticAccessControlled(gracePeriod)
    {}


    function transferTokens(
        address token,
        address from,
        address to,
        uint256 value
    )
        external
        requiresAuthorization
    {

        TokenInteract.transferFrom(
            token,
            from,
            to,
            value
        );
    }


    function available(
        address who,
        address token
    )
        external
        view
        returns (uint256)
    {

        return Math.min256(
            TokenInteract.allowance(token, who, address(this)),
            TokenInteract.balanceOf(token, who)
        );
    }
}


contract Vault is StaticAccessControlled
{

    using SafeMath for uint256;


    event ExcessTokensWithdrawn(
        address indexed token,
        address indexed to,
        address caller
    );


    address public TOKEN_PROXY;

    mapping (bytes32 => mapping (address => uint256)) public balances;

    mapping (address => uint256) public totalBalances;


    constructor(
        address proxy,
        uint256 gracePeriod
    )
        public
        StaticAccessControlled(gracePeriod)
    {
        TOKEN_PROXY = proxy;
    }


    function withdrawExcessToken(
        address token,
        address to
    )
        external
        onlyOwner
        returns (uint256)
    {

        uint256 actualBalance = TokenInteract.balanceOf(token, address(this));
        uint256 accountedBalance = totalBalances[token];
        uint256 withdrawableBalance = actualBalance.sub(accountedBalance);

        require(
            withdrawableBalance != 0,
            "Vault#withdrawExcessToken: Withdrawable token amount must be non-zero"
        );

        TokenInteract.transfer(token, to, withdrawableBalance);

        emit ExcessTokensWithdrawn(token, to, msg.sender);

        return withdrawableBalance;
    }


    function transferToVault(
        bytes32 id,
        address token,
        address from,
        uint256 amount
    )
        external
        requiresAuthorization
    {

        TokenProxy(TOKEN_PROXY).transferTokens(
            token,
            from,
            address(this),
            amount
        );

        balances[id][token] = balances[id][token].add(amount);
        totalBalances[token] = totalBalances[token].add(amount);

        assert(totalBalances[token] >= balances[id][token]);

        validateBalance(token);
    }

    function transferFromVault(
        bytes32 id,
        address token,
        address to,
        uint256 amount
    )
        external
        requiresAuthorization
    {

        balances[id][token] = balances[id][token].sub(amount);

        totalBalances[token] = totalBalances[token].sub(amount);

        assert(totalBalances[token] >= balances[id][token]);

        TokenInteract.transfer(token, to, amount); // asserts transfer succeeded

        validateBalance(token);
    }


    function validateBalance(
        address token
    )
        private
        view
    {

        assert(TokenInteract.balanceOf(token, address(this)) >= totalBalances[token]);
    }
}


library TimestampHelper {

    function getBlockTimestamp32()
        internal
        view
        returns (uint32)
    {

        assert(uint256(uint32(block.timestamp)) == block.timestamp);

        assert(block.timestamp > 0);

        return uint32(block.timestamp);
    }
}


library MarginCommon {

    using SafeMath for uint256;


    struct Position {
        address owedToken;       // Immutable
        address heldToken;       // Immutable
        address lender;
        address owner;
        uint256 principal;
        uint256 requiredDeposit;
        uint32  callTimeLimit;   // Immutable
        uint32  startTimestamp;  // Immutable, cannot be 0
        uint32  callTimestamp;
        uint32  maxDuration;     // Immutable
        uint32  interestRate;    // Immutable
        uint32  interestPeriod;  // Immutable
    }

    struct LoanOffering {
        address   owedToken;
        address   heldToken;
        address   payer;
        address   owner;
        address   taker;
        address   positionOwner;
        address   feeRecipient;
        address   lenderFeeToken;
        address   takerFeeToken;
        LoanRates rates;
        uint256   expirationTimestamp;
        uint32    callTimeLimit;
        uint32    maxDuration;
        uint256   salt;
        bytes32   loanHash;
        bytes     signature;
    }

    struct LoanRates {
        uint256 maxAmount;
        uint256 minAmount;
        uint256 minHeldToken;
        uint256 lenderFee;
        uint256 takerFee;
        uint32  interestRate;
        uint32  interestPeriod;
    }


    function storeNewPosition(
        MarginState.State storage state,
        bytes32 positionId,
        Position memory position,
        address loanPayer
    )
        internal
    {

        assert(!positionHasExisted(state, positionId));
        assert(position.owedToken != address(0));
        assert(position.heldToken != address(0));
        assert(position.owedToken != position.heldToken);
        assert(position.owner != address(0));
        assert(position.lender != address(0));
        assert(position.maxDuration != 0);
        assert(position.interestPeriod <= position.maxDuration);
        assert(position.callTimestamp == 0);
        assert(position.requiredDeposit == 0);

        state.positions[positionId].owedToken = position.owedToken;
        state.positions[positionId].heldToken = position.heldToken;
        state.positions[positionId].principal = position.principal;
        state.positions[positionId].callTimeLimit = position.callTimeLimit;
        state.positions[positionId].startTimestamp = TimestampHelper.getBlockTimestamp32();
        state.positions[positionId].maxDuration = position.maxDuration;
        state.positions[positionId].interestRate = position.interestRate;
        state.positions[positionId].interestPeriod = position.interestPeriod;

        state.positions[positionId].owner = TransferInternal.grantPositionOwnership(
            positionId,
            (position.owner != msg.sender) ? msg.sender : address(0),
            position.owner
        );

        state.positions[positionId].lender = TransferInternal.grantLoanOwnership(
            positionId,
            (position.lender != loanPayer) ? loanPayer : address(0),
            position.lender
        );
    }

    function getPositionIdFromNonce(
        uint256 nonce
    )
        internal
        view
        returns (bytes32)
    {

        return keccak256(abi.encodePacked(msg.sender, nonce));
    }

    function getUnavailableLoanOfferingAmountImpl(
        MarginState.State storage state,
        bytes32 loanHash
    )
        internal
        view
        returns (uint256)
    {

        return state.loanFills[loanHash].add(state.loanCancels[loanHash]);
    }

    function cleanupPosition(
        MarginState.State storage state,
        bytes32 positionId
    )
        internal
    {

        delete state.positions[positionId];
        state.closedPositions[positionId] = true;
    }

    function calculateOwedAmount(
        Position storage position,
        uint256 closeAmount,
        uint256 endTimestamp
    )
        internal
        view
        returns (uint256)
    {

        uint256 timeElapsed = calculateEffectiveTimeElapsed(position, endTimestamp);

        return InterestImpl.getCompoundedInterest(
            closeAmount,
            position.interestRate,
            timeElapsed
        );
    }

    function calculateEffectiveTimeElapsed(
        Position storage position,
        uint256 timestamp
    )
        internal
        view
        returns (uint256)
    {

        uint256 elapsed = timestamp.sub(position.startTimestamp);

        uint256 period = position.interestPeriod;
        if (period > 1) {
            elapsed = MathHelpers.divisionRoundedUp(elapsed, period).mul(period);
        }

        return Math.min256(
            elapsed,
            position.maxDuration
        );
    }

    function calculateLenderAmountForIncreasePosition(
        Position storage position,
        uint256 principalToAdd,
        uint256 endTimestamp
    )
        internal
        view
        returns (uint256)
    {

        uint256 timeElapsed = calculateEffectiveTimeElapsedForNewLender(position, endTimestamp);

        return InterestImpl.getCompoundedInterest(
            principalToAdd,
            position.interestRate,
            timeElapsed
        );
    }

    function getLoanOfferingHash(
        LoanOffering loanOffering
    )
        internal
        view
        returns (bytes32)
    {

        return keccak256(
            abi.encodePacked(
                address(this),
                loanOffering.owedToken,
                loanOffering.heldToken,
                loanOffering.payer,
                loanOffering.owner,
                loanOffering.taker,
                loanOffering.positionOwner,
                loanOffering.feeRecipient,
                loanOffering.lenderFeeToken,
                loanOffering.takerFeeToken,
                getValuesHash(loanOffering)
            )
        );
    }

    function getPositionBalanceImpl(
        MarginState.State storage state,
        bytes32 positionId
    )
        internal
        view
        returns(uint256)
    {

        return Vault(state.VAULT).balances(positionId, state.positions[positionId].heldToken);
    }

    function containsPositionImpl(
        MarginState.State storage state,
        bytes32 positionId
    )
        internal
        view
        returns (bool)
    {

        return state.positions[positionId].startTimestamp != 0;
    }

    function positionHasExisted(
        MarginState.State storage state,
        bytes32 positionId
    )
        internal
        view
        returns (bool)
    {

        return containsPositionImpl(state, positionId) || state.closedPositions[positionId];
    }

    function getPositionFromStorage(
        MarginState.State storage state,
        bytes32 positionId
    )
        internal
        view
        returns (Position storage)
    {

        Position storage position = state.positions[positionId];

        require(
            position.startTimestamp != 0,
            "MarginCommon#getPositionFromStorage: The position does not exist"
        );

        return position;
    }


    function calculateEffectiveTimeElapsedForNewLender(
        Position storage position,
        uint256 timestamp
    )
        private
        view
        returns (uint256)
    {

        uint256 elapsed = timestamp.sub(position.startTimestamp);

        uint256 period = position.interestPeriod;
        if (period > 1) {
            elapsed = elapsed.div(period).mul(period);
        }

        return Math.min256(
            elapsed,
            position.maxDuration
        );
    }

    function getValuesHash(
        LoanOffering loanOffering
    )
        private
        pure
        returns (bytes32)
    {

        return keccak256(
            abi.encodePacked(
                loanOffering.rates.maxAmount,
                loanOffering.rates.minAmount,
                loanOffering.rates.minHeldToken,
                loanOffering.rates.lenderFee,
                loanOffering.rates.takerFee,
                loanOffering.expirationTimestamp,
                loanOffering.salt,
                loanOffering.callTimeLimit,
                loanOffering.maxDuration,
                loanOffering.rates.interestRate,
                loanOffering.rates.interestPeriod
            )
        );
    }
}


interface ForceRecoverCollateralDelegator {



    function forceRecoverCollateralOnBehalfOf(
        address recoverer,
        bytes32 positionId,
        address recipient
    )
        external
        returns (address);

}


library ForceRecoverCollateralImpl {

    using SafeMath for uint256;


    event CollateralForceRecovered(
        bytes32 indexed positionId,
        address indexed recipient,
        uint256 amount
    );


    function forceRecoverCollateralImpl(
        MarginState.State storage state,
        bytes32 positionId,
        address recipient
    )
        public
        returns (uint256)
    {

        MarginCommon.Position storage position =
            MarginCommon.getPositionFromStorage(state, positionId);

        require( /* solium-disable-next-line */
            (
                position.callTimestamp > 0
                && block.timestamp >= uint256(position.callTimestamp).add(position.callTimeLimit)
            ) || (
                block.timestamp >= uint256(position.startTimestamp).add(position.maxDuration)
            ),
            "ForceRecoverCollateralImpl#forceRecoverCollateralImpl: Cannot recover yet"
        );

        forceRecoverCollateralOnBehalfOfRecurse(
            position.lender,
            msg.sender,
            positionId,
            recipient
        );

        uint256 heldTokenRecovered = MarginCommon.getPositionBalanceImpl(state, positionId);
        Vault(state.VAULT).transferFromVault(
            positionId,
            position.heldToken,
            recipient,
            heldTokenRecovered
        );

        MarginCommon.cleanupPosition(
            state,
            positionId
        );

        emit CollateralForceRecovered(
            positionId,
            recipient,
            heldTokenRecovered
        );

        return heldTokenRecovered;
    }


    function forceRecoverCollateralOnBehalfOfRecurse(
        address contractAddr,
        address recoverer,
        bytes32 positionId,
        address recipient
    )
        private
    {

        if (recoverer == contractAddr) {
            return;
        }

        address newContractAddr =
            ForceRecoverCollateralDelegator(contractAddr).forceRecoverCollateralOnBehalfOf(
                recoverer,
                positionId,
                recipient
            );

        if (newContractAddr != contractAddr) {
            forceRecoverCollateralOnBehalfOfRecurse(
                newContractAddr,
                recoverer,
                positionId,
                recipient
            );
        }
    }
}