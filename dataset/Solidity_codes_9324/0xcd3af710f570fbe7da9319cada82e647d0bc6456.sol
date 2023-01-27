
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