pragma solidity ^0.5.2;


interface ERC20Token {


    function transfer(address _to, uint256 _value) external returns (bool success);


    function approve(address _spender, uint256 _value) external returns (bool success);


    function transferFrom(address _from, address _to, uint256 _value) external returns (bool success);


    function balanceOf(address _owner) external view returns (uint256 balance);


    function allowance(address _owner, address _spender) external view returns (uint256 remaining);


    function totalSupply() external view returns (uint256 supply);


    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);
}
pragma solidity ^0.5.2;



contract MiniMeTokenInterface is ERC20Token {


    function approveAndCall(
        address _spender,
        uint256 _amount,
        bytes calldata _extraData
    ) 
        external 
        returns (bool success);


    function createCloneToken(
        string calldata _cloneTokenName,
        uint8 _cloneDecimalUnits,
        string calldata _cloneTokenSymbol,
        uint _snapshotBlock,
        bool _transfersEnabled
    ) 
        external
        returns(address);


    function generateTokens(
        address _owner,
        uint _amount
    )
        external
        returns (bool);


    function destroyTokens(
        address _owner,
        uint _amount
    ) 
        external
        returns (bool);


    function enableTransfers(bool _transfersEnabled) external;


    function claimTokens(address _token) external;


    function balanceOfAt(
        address _owner,
        uint _blockNumber
    ) 
        public
        view
        returns (uint);


    function totalSupplyAt(uint _blockNumber) public view returns(uint);


}pragma solidity ^0.5.2;


contract ApproveAndCallFallBack {

    function receiveApproval(
        address from, 
        uint256 _amount, 
        address _token, 
        bytes calldata _data) external;

}
pragma solidity ^0.5.2;


library SafeMath {

    function add(uint256 _x, uint256 _y) internal pure returns (uint256) {

        uint256 z = _x + _y;
        require(z >= _x, "SafeMath failed");
        return z;
    }

    function sub(uint256 _x, uint256 _y) internal pure returns (uint256) {

        require(_x >= _y, "SafeMath failed");
        return _x - _y;
    }

    function mul(uint256 _x, uint256 _y) internal pure returns (uint256) {

        if (_x == 0)
            return 0;

        uint256 z = _x * _y;
        require(z / _x == _y, "SafeMath failed");
        return z;
    }

    function div(uint256 _x, uint256 _y) internal pure returns (uint256) {

        require(_y > 0, "SafeMath failed");
        uint256 c = _x / _y;

        return c;
    }
}pragma solidity ^0.5.2;


contract BancorFormula {

    using SafeMath for uint256;

    uint256 private constant ONE = 1;
    uint8 private constant MIN_PRECISION = 32;
    uint8 private constant MAX_PRECISION = 127;

    uint256 private constant FIXED_1 = 0x080000000000000000000000000000000;
    uint256 private constant FIXED_2 = 0x100000000000000000000000000000000;
    uint256 private constant MAX_NUM = 0x200000000000000000000000000000000;

    uint256 private constant LN2_NUMERATOR   = 0x3f80fe03f80fe03f80fe03f80fe03f8;
    uint256 private constant LN2_DENOMINATOR = 0x5b9de1d10bf4103d647b0955897ba80;

    uint256 private constant OPT_LOG_MAX_VAL = 0x15bf0a8b1457695355fb8ac404e7a79e3;
    uint256 private constant OPT_EXP_MAX_VAL = 0x800000000000000000000000000000000;

    uint256[128] private maxExpArray;
    constructor() public {
        maxExpArray[32] = 0x1c35fedd14ffffffffffffffffffffffff;
        maxExpArray[33] = 0x1b0ce43b323fffffffffffffffffffffff;
        maxExpArray[34] = 0x19f0028ec1ffffffffffffffffffffffff;
        maxExpArray[35] = 0x18ded91f0e7fffffffffffffffffffffff;
        maxExpArray[36] = 0x17d8ec7f0417ffffffffffffffffffffff;
        maxExpArray[37] = 0x16ddc6556cdbffffffffffffffffffffff;
        maxExpArray[38] = 0x15ecf52776a1ffffffffffffffffffffff;
        maxExpArray[39] = 0x15060c256cb2ffffffffffffffffffffff;
        maxExpArray[40] = 0x1428a2f98d72ffffffffffffffffffffff;
        maxExpArray[41] = 0x13545598e5c23fffffffffffffffffffff;
        maxExpArray[42] = 0x1288c4161ce1dfffffffffffffffffffff;
        maxExpArray[43] = 0x11c592761c666fffffffffffffffffffff;
        maxExpArray[44] = 0x110a688680a757ffffffffffffffffffff;
        maxExpArray[45] = 0x1056f1b5bedf77ffffffffffffffffffff;
        maxExpArray[46] = 0x0faadceceeff8bffffffffffffffffffff;
        maxExpArray[47] = 0x0f05dc6b27edadffffffffffffffffffff;
        maxExpArray[48] = 0x0e67a5a25da4107fffffffffffffffffff;
        maxExpArray[49] = 0x0dcff115b14eedffffffffffffffffffff;
        maxExpArray[50] = 0x0d3e7a392431239fffffffffffffffffff;
        maxExpArray[51] = 0x0cb2ff529eb71e4fffffffffffffffffff;
        maxExpArray[52] = 0x0c2d415c3db974afffffffffffffffffff;
        maxExpArray[53] = 0x0bad03e7d883f69bffffffffffffffffff;
        maxExpArray[54] = 0x0b320d03b2c343d5ffffffffffffffffff;
        maxExpArray[55] = 0x0abc25204e02828dffffffffffffffffff;
        maxExpArray[56] = 0x0a4b16f74ee4bb207fffffffffffffffff;
        maxExpArray[57] = 0x09deaf736ac1f569ffffffffffffffffff;
        maxExpArray[58] = 0x0976bd9952c7aa957fffffffffffffffff;
        maxExpArray[59] = 0x09131271922eaa606fffffffffffffffff;
        maxExpArray[60] = 0x08b380f3558668c46fffffffffffffffff;
        maxExpArray[61] = 0x0857ddf0117efa215bffffffffffffffff;
        maxExpArray[62] = 0x07ffffffffffffffffffffffffffffffff;
        maxExpArray[63] = 0x07abbf6f6abb9d087fffffffffffffffff;
        maxExpArray[64] = 0x075af62cbac95f7dfa7fffffffffffffff;
        maxExpArray[65] = 0x070d7fb7452e187ac13fffffffffffffff;
        maxExpArray[66] = 0x06c3390ecc8af379295fffffffffffffff;
        maxExpArray[67] = 0x067c00a3b07ffc01fd6fffffffffffffff;
        maxExpArray[68] = 0x0637b647c39cbb9d3d27ffffffffffffff;
        maxExpArray[69] = 0x05f63b1fc104dbd39587ffffffffffffff;
        maxExpArray[70] = 0x05b771955b36e12f7235ffffffffffffff;
        maxExpArray[71] = 0x057b3d49dda84556d6f6ffffffffffffff;
        maxExpArray[72] = 0x054183095b2c8ececf30ffffffffffffff;
        maxExpArray[73] = 0x050a28be635ca2b888f77fffffffffffff;
        maxExpArray[74] = 0x04d5156639708c9db33c3fffffffffffff;
        maxExpArray[75] = 0x04a23105873875bd52dfdfffffffffffff;
        maxExpArray[76] = 0x0471649d87199aa990756fffffffffffff;
        maxExpArray[77] = 0x04429a21a029d4c1457cfbffffffffffff;
        maxExpArray[78] = 0x0415bc6d6fb7dd71af2cb3ffffffffffff;
        maxExpArray[79] = 0x03eab73b3bbfe282243ce1ffffffffffff;
        maxExpArray[80] = 0x03c1771ac9fb6b4c18e229ffffffffffff;
        maxExpArray[81] = 0x0399e96897690418f785257fffffffffff;
        maxExpArray[82] = 0x0373fc456c53bb779bf0ea9fffffffffff;
        maxExpArray[83] = 0x034f9e8e490c48e67e6ab8bfffffffffff;
        maxExpArray[84] = 0x032cbfd4a7adc790560b3337ffffffffff;
        maxExpArray[85] = 0x030b50570f6e5d2acca94613ffffffffff;
        maxExpArray[86] = 0x02eb40f9f620fda6b56c2861ffffffffff;
        maxExpArray[87] = 0x02cc8340ecb0d0f520a6af58ffffffffff;
        maxExpArray[88] = 0x02af09481380a0a35cf1ba02ffffffffff;
        maxExpArray[89] = 0x0292c5bdd3b92ec810287b1b3fffffffff;
        maxExpArray[90] = 0x0277abdcdab07d5a77ac6d6b9fffffffff;
        maxExpArray[91] = 0x025daf6654b1eaa55fd64df5efffffffff;
        maxExpArray[92] = 0x0244c49c648baa98192dce88b7ffffffff;
        maxExpArray[93] = 0x022ce03cd5619a311b2471268bffffffff;
        maxExpArray[94] = 0x0215f77c045fbe885654a44a0fffffffff;
        maxExpArray[95] = 0x01ffffffffffffffffffffffffffffffff;
        maxExpArray[96] = 0x01eaefdbdaaee7421fc4d3ede5ffffffff;
        maxExpArray[97] = 0x01d6bd8b2eb257df7e8ca57b09bfffffff;
        maxExpArray[98] = 0x01c35fedd14b861eb0443f7f133fffffff;
        maxExpArray[99] = 0x01b0ce43b322bcde4a56e8ada5afffffff;
        maxExpArray[100] = 0x019f0028ec1fff007f5a195a39dfffffff;
        maxExpArray[101] = 0x018ded91f0e72ee74f49b15ba527ffffff;
        maxExpArray[102] = 0x017d8ec7f04136f4e5615fd41a63ffffff;
        maxExpArray[103] = 0x016ddc6556cdb84bdc8d12d22e6fffffff;
        maxExpArray[104] = 0x015ecf52776a1155b5bd8395814f7fffff;
        maxExpArray[105] = 0x015060c256cb23b3b3cc3754cf40ffffff;
        maxExpArray[106] = 0x01428a2f98d728ae223ddab715be3fffff;
        maxExpArray[107] = 0x013545598e5c23276ccf0ede68034fffff;
        maxExpArray[108] = 0x01288c4161ce1d6f54b7f61081194fffff;
        maxExpArray[109] = 0x011c592761c666aa641d5a01a40f17ffff;
        maxExpArray[110] = 0x0110a688680a7530515f3e6e6cfdcdffff;
        maxExpArray[111] = 0x01056f1b5bedf75c6bcb2ce8aed428ffff;
        maxExpArray[112] = 0x00faadceceeff8a0890f3875f008277fff;
        maxExpArray[113] = 0x00f05dc6b27edad306388a600f6ba0bfff;
        maxExpArray[114] = 0x00e67a5a25da41063de1495d5b18cdbfff;
        maxExpArray[115] = 0x00dcff115b14eedde6fc3aa5353f2e4fff;
        maxExpArray[116] = 0x00d3e7a3924312399f9aae2e0f868f8fff;
        maxExpArray[117] = 0x00cb2ff529eb71e41582cccd5a1ee26fff;
        maxExpArray[118] = 0x00c2d415c3db974ab32a51840c0b67edff;
        maxExpArray[119] = 0x00bad03e7d883f69ad5b0a186184e06bff;
        maxExpArray[120] = 0x00b320d03b2c343d4829abd6075f0cc5ff;
        maxExpArray[121] = 0x00abc25204e02828d73c6e80bcdb1a95bf;
        maxExpArray[122] = 0x00a4b16f74ee4bb2040a1ec6c15fbbf2df;
        maxExpArray[123] = 0x009deaf736ac1f569deb1b5ae3f36c130f;
        maxExpArray[124] = 0x00976bd9952c7aa957f5937d790ef65037;
        maxExpArray[125] = 0x009131271922eaa6064b73a22d0bd4f2bf;
        maxExpArray[126] = 0x008b380f3558668c46c91c49a2f8e967b9;
        maxExpArray[127] = 0x00857ddf0117efa215952912839f6473e6;
    }

    function power(
        uint256 _baseN, 
        uint256 _baseD, 
        uint32 _expN, 
        uint32 _expD) internal view returns (uint256, uint8) 
        {

        require(_baseN < MAX_NUM, "SNT available is invalid");

        uint256 baseLog;
        uint256 base = _baseN * FIXED_1 / _baseD;
        if (base < OPT_LOG_MAX_VAL) {
            baseLog = optimalLog(base);
        } else {
            baseLog = generalLog(base);
        }

        uint256 baseLogTimesExp = baseLog * _expN / _expD;
        if (baseLogTimesExp < OPT_EXP_MAX_VAL) {
            return (optimalExp(baseLogTimesExp), MAX_PRECISION);
        } else {
            uint8 precision = findPositionInMaxExpArray(baseLogTimesExp);
            return (generalExp(baseLogTimesExp >> (MAX_PRECISION - precision), precision), precision);
        }
    }

    function generalLog(uint256 x) internal pure returns (uint256) {

        uint256 res = 0;

        if (x >= FIXED_2) {
            uint8 count = floorLog2(x / FIXED_1);
            x >>= count; // now x < 2
            res = count * FIXED_1;
        }

        if (x > FIXED_1) {
            for (uint8 i = MAX_PRECISION; i > 0; --i) {
                x = (x * x) / FIXED_1; // now 1 < x < 4
                if (x >= FIXED_2) {
                    x >>= 1; // now 1 < x < 2
                    res += ONE << (i - 1);
                }
            }
        }

        return res * LN2_NUMERATOR / LN2_DENOMINATOR;
    }

    function floorLog2(uint256 _n) internal pure returns (uint8) {

        uint8 res = 0;

        if (_n < 256) {
            while (_n > 1) {
                _n >>= 1;
                res += 1;
            }
        } else {
            for (uint8 s = 128; s > 0; s >>= 1) {
                if (_n >= (ONE << s)) {
                    _n >>= s;
                    res |= s;
                }
            }
        }

        return res;
    }

    function findPositionInMaxExpArray(uint256 _x) internal view returns (uint8) {

        uint8 lo = MIN_PRECISION;
        uint8 hi = MAX_PRECISION;

        while (lo + 1 < hi) {
            uint8 mid = (lo + hi) / 2;
            if (maxExpArray[mid] >= _x) {
                lo = mid;
            } else {
                hi = mid;
            }
        }

        if (maxExpArray[hi] >= _x)
            return hi;
        if (maxExpArray[lo] >= _x)
            return lo;

        require(false, "Could not find a suitable position");
        return 0;
    }

    function generalExp(uint256 _x, uint8 _precision) internal pure returns (uint256) {

        uint256 xi = _x;
        uint256 res = 0;

        xi = (xi * _x) >> _precision; 
        res += xi * 0x3442c4e6074a82f1797f72ac0000000; // add x^02 * (33! / 02!)
        xi = (xi * _x) >> _precision; 
        res += xi * 0x116b96f757c380fb287fd0e40000000; // add x^03 * (33! / 03!)
        xi = (xi * _x) >> _precision; 
        res += xi * 0x045ae5bdd5f0e03eca1ff4390000000; // add x^04 * (33! / 04!)
        xi = (xi * _x) >> _precision; 
        res += xi * 0x00defabf91302cd95b9ffda50000000; // add x^05 * (33! / 05!)
        xi = (xi * _x) >> _precision; 
        res += xi * 0x002529ca9832b22439efff9b8000000; // add x^06 * (33! / 06!)
        xi = (xi * _x) >> _precision; 
        res += xi * 0x00054f1cf12bd04e516b6da88000000; // add x^07 * (33! / 07!)
        xi = (xi * _x) >> _precision; 
        res += xi * 0x0000a9e39e257a09ca2d6db51000000; // add x^08 * (33! / 08!)
        xi = (xi * _x) >> _precision; 
        res += xi * 0x000012e066e7b839fa050c309000000; // add x^09 * (33! / 09!)
        xi = (xi * _x) >> _precision; 
        res += xi * 0x000001e33d7d926c329a1ad1a800000; // add x^10 * (33! / 10!)
        xi = (xi * _x) >> _precision; 
        res += xi * 0x0000002bee513bdb4a6b19b5f800000; // add x^11 * (33! / 11!)
        xi = (xi * _x) >> _precision; 
        res += xi * 0x00000003a9316fa79b88eccf2a00000; // add x^12 * (33! / 12!)
        xi = (xi * _x) >> _precision; 
        res += xi * 0x0000000048177ebe1fa812375200000; // add x^13 * (33! / 13!)
        xi = (xi * _x) >> _precision; 
        res += xi * 0x0000000005263fe90242dcbacf00000; // add x^14 * (33! / 14!)
        xi = (xi * _x) >> _precision; 
        res += xi * 0x000000000057e22099c030d94100000; // add x^15 * (33! / 15!)
        xi = (xi * _x) >> _precision; 
        res += xi * 0x0000000000057e22099c030d9410000; // add x^16 * (33! / 16!)
        xi = (xi * _x) >> _precision; 
        res += xi * 0x00000000000052b6b54569976310000; // add x^17 * (33! / 17!)
        xi = (xi * _x) >> _precision; 
        res += xi * 0x00000000000004985f67696bf748000; // add x^18 * (33! / 18!)
        xi = (xi * _x) >> _precision; 
        res += xi * 0x000000000000003dea12ea99e498000; // add x^19 * (33! / 19!)
        xi = (xi * _x) >> _precision; 
        res += xi * 0x00000000000000031880f2214b6e000; // add x^20 * (33! / 20!)
        xi = (xi * _x) >> _precision; 
        res += xi * 0x000000000000000025bcff56eb36000; // add x^21 * (33! / 21!)
        xi = (xi * _x) >> _precision; 
        res += xi * 0x000000000000000001b722e10ab1000; // add x^22 * (33! / 22!)
        xi = (xi * _x) >> _precision; 
        res += xi * 0x0000000000000000001317c70077000; // add x^23 * (33! / 23!)
        xi = (xi * _x) >> _precision; 
        res += xi * 0x00000000000000000000cba84aafa00; // add x^24 * (33! / 24!)
        xi = (xi * _x) >> _precision; 
        res += xi * 0x00000000000000000000082573a0a00; // add x^25 * (33! / 25!)
        xi = (xi * _x) >> _precision; 
        res += xi * 0x00000000000000000000005035ad900; // add x^26 * (33! / 26!)
        xi = (xi * _x) >> _precision; 
        res += xi * 0x000000000000000000000002f881b00; // add x^27 * (33! / 27!)
        xi = (xi * _x) >> _precision; 
        res += xi * 0x0000000000000000000000001b29340; // add x^28 * (33! / 28!)
        xi = (xi * _x) >> _precision; 
        res += xi * 0x00000000000000000000000000efc40; // add x^29 * (33! / 29!)
        xi = (xi * _x) >> _precision; 
        res += xi * 0x0000000000000000000000000007fe0; // add x^30 * (33! / 30!)
        xi = (xi * _x) >> _precision; 
        res += xi * 0x0000000000000000000000000000420; // add x^31 * (33! / 31!)
        xi = (xi * _x) >> _precision; 
        res += xi * 0x0000000000000000000000000000021; // add x^32 * (33! / 32!)
        xi = (xi * _x) >> _precision; 
        res += xi * 0x0000000000000000000000000000001; // add x^33 * (33! / 33!)

        return res / 0x688589cc0e9505e2f2fee5580000000 + _x + (ONE << _precision); // divide by 33! and then add x^1 / 1! + x^0 / 0!
    }

    function optimalLog(uint256 x) internal pure returns (uint256) {

        uint256 res = 0;

        uint256 y = 0;
        uint256 z;
        uint256 w;

        if (x >= 0xd3094c70f034de4b96ff7d5b6f99fcd8) {
            res += 0x40000000000000000000000000000000; 
            x = x * FIXED_1 / 0xd3094c70f034de4b96ff7d5b6f99fcd8;} // add 1 / 2^1
        if (x >= 0xa45af1e1f40c333b3de1db4dd55f29a7) {
            res += 0x20000000000000000000000000000000; 
            x = x * FIXED_1 / 0xa45af1e1f40c333b3de1db4dd55f29a7;} // add 1 / 2^2
        if (x >= 0x910b022db7ae67ce76b441c27035c6a1) {
            res += 0x10000000000000000000000000000000; 
            x = x * FIXED_1 / 0x910b022db7ae67ce76b441c27035c6a1;} // add 1 / 2^3
        if (x >= 0x88415abbe9a76bead8d00cf112e4d4a8) {
            res += 0x08000000000000000000000000000000; 
            x = x * FIXED_1 / 0x88415abbe9a76bead8d00cf112e4d4a8;} // add 1 / 2^4
        if (x >= 0x84102b00893f64c705e841d5d4064bd3) {
            res += 0x04000000000000000000000000000000; 
            x = x * FIXED_1 / 0x84102b00893f64c705e841d5d4064bd3;} // add 1 / 2^5
        if (x >= 0x8204055aaef1c8bd5c3259f4822735a2) {
            res += 0x02000000000000000000000000000000; 
            x = x * FIXED_1 / 0x8204055aaef1c8bd5c3259f4822735a2;} // add 1 / 2^6
        if (x >= 0x810100ab00222d861931c15e39b44e99) {
            res += 0x01000000000000000000000000000000; 
            x = x * FIXED_1 / 0x810100ab00222d861931c15e39b44e99;} // add 1 / 2^7
        if (x >= 0x808040155aabbbe9451521693554f733) {
            res += 0x00800000000000000000000000000000; 
            x = x * FIXED_1 / 0x808040155aabbbe9451521693554f733;} // add 1 / 2^8

        z = y = x - FIXED_1;
        w = y * y / FIXED_1;
        res += z * (0x100000000000000000000000000000000 - y) / 0x100000000000000000000000000000000; 
        z = z * w / FIXED_1; // add y^01 / 01 - y^02 / 02
        res += z * (0x0aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa - y) / 0x200000000000000000000000000000000; 
        z = z * w / FIXED_1; // add y^03 / 03 - y^04 / 04
        res += z * (0x099999999999999999999999999999999 - y) / 0x300000000000000000000000000000000; 
        z = z * w / FIXED_1; // add y^05 / 05 - y^06 / 06
        res += z * (0x092492492492492492492492492492492 - y) / 0x400000000000000000000000000000000; 
        z = z * w / FIXED_1; // add y^07 / 07 - y^08 / 08
        res += z * (0x08e38e38e38e38e38e38e38e38e38e38e - y) / 0x500000000000000000000000000000000; 
        z = z * w / FIXED_1; // add y^09 / 09 - y^10 / 10
        res += z * (0x08ba2e8ba2e8ba2e8ba2e8ba2e8ba2e8b - y) / 0x600000000000000000000000000000000; 
        z = z * w / FIXED_1; // add y^11 / 11 - y^12 / 12
        res += z * (0x089d89d89d89d89d89d89d89d89d89d89 - y) / 0x700000000000000000000000000000000; 
        z = z * w / FIXED_1; // add y^13 / 13 - y^14 / 14
        res += z * (0x088888888888888888888888888888888 - y) / 0x800000000000000000000000000000000;                      

        return res;
    }

    function optimalExp(uint256 x) internal pure returns (uint256) {

        uint256 res = 0;

        uint256 y = 0;
        uint256 z;

        z = y = x % 0x10000000000000000000000000000000; // get the input modulo 2^(-3)
        z = z * y / FIXED_1; 
        res += z * 0x10e1b3be415a0000; // add y^02 * (20! / 02!)
        z = z * y / FIXED_1; 
        res += z * 0x05a0913f6b1e0000; // add y^03 * (20! / 03!)
        z = z * y / FIXED_1; 
        res += z * 0x0168244fdac78000; // add y^04 * (20! / 04!)
        z = z * y / FIXED_1; 
        res += z * 0x004807432bc18000; // add y^05 * (20! / 05!)
        z = z * y / FIXED_1; 
        res += z * 0x000c0135dca04000; // add y^06 * (20! / 06!)
        z = z * y / FIXED_1; 
        res += z * 0x0001b707b1cdc000; // add y^07 * (20! / 07!)
        z = z * y / FIXED_1; 
        res += z * 0x000036e0f639b800; // add y^08 * (20! / 08!)
        z = z * y / FIXED_1; 
        res += z * 0x00000618fee9f800; // add y^09 * (20! / 09!)
        z = z * y / FIXED_1; 
        res += z * 0x0000009c197dcc00; // add y^10 * (20! / 10!)
        z = z * y / FIXED_1; 
        res += z * 0x0000000e30dce400; // add y^11 * (20! / 11!)
        z = z * y / FIXED_1; 
        res += z * 0x000000012ebd1300; // add y^12 * (20! / 12!)
        z = z * y / FIXED_1; 
        res += z * 0x0000000017499f00; // add y^13 * (20! / 13!)
        z = z * y / FIXED_1; 
        res += z * 0x0000000001a9d480; // add y^14 * (20! / 14!)
        z = z * y / FIXED_1; 
        res += z * 0x00000000001c6380; // add y^15 * (20! / 15!)
        z = z * y / FIXED_1; 
        res += z * 0x000000000001c638; // add y^16 * (20! / 16!)
        z = z * y / FIXED_1; 
        res += z * 0x0000000000001ab8; // add y^17 * (20! / 17!)
        z = z * y / FIXED_1; 
        res += z * 0x000000000000017c; // add y^18 * (20! / 18!)
        z = z * y / FIXED_1; 
        res += z * 0x0000000000000014; // add y^19 * (20! / 19!)
        z = z * y / FIXED_1; 
        res += z * 0x0000000000000001; // add y^20 * (20! / 20!)
        res = res / 0x21c3677c82b40000 + y + FIXED_1; // divide by 20! and then add y^1 / 1! + y^0 / 0!

        if ((x & 0x010000000000000000000000000000000) != 0) 
        res = res * 0x1c3d6a24ed82218787d624d3e5eba95f9 / 0x18ebef9eac820ae8682b9793ac6d1e776; // multiply by e^2^(-3)
        if ((x & 0x020000000000000000000000000000000) != 0) 
        res = res * 0x18ebef9eac820ae8682b9793ac6d1e778 / 0x1368b2fc6f9609fe7aceb46aa619baed4; // multiply by e^2^(-2)
        if ((x & 0x040000000000000000000000000000000) != 0) 
        res = res * 0x1368b2fc6f9609fe7aceb46aa619baed5 / 0x0bc5ab1b16779be3575bd8f0520a9f21f; // multiply by e^2^(-1)
        if ((x & 0x080000000000000000000000000000000) != 0) 
        res = res * 0x0bc5ab1b16779be3575bd8f0520a9f21e / 0x0454aaa8efe072e7f6ddbab84b40a55c9; // multiply by e^2^(+0)
        if ((x & 0x100000000000000000000000000000000) != 0) 
        res = res * 0x0454aaa8efe072e7f6ddbab84b40a55c5 / 0x00960aadc109e7a3bf4578099615711ea; // multiply by e^2^(+1)
        if ((x & 0x200000000000000000000000000000000) != 0) 
        res = res * 0x00960aadc109e7a3bf4578099615711d7 / 0x0002bf84208204f5977f9a8cf01fdce3d; // multiply by e^2^(+2)
        if ((x & 0x400000000000000000000000000000000) != 0) 
        res = res * 0x0002bf84208204f5977f9a8cf01fdc307 / 0x0000003c6ab775dd0b95b4cbee7e65d11; // multiply by e^2^(+3)

        return res;
    }
}pragma solidity ^0.5.2;


contract Controlled {

    modifier onlyController { 

        require(msg.sender == controller, "Unauthorized"); 
        _; 
    }

    address payable public controller;

    constructor() internal { 
        controller = msg.sender; 
    }

    function changeController(address payable _newController) external onlyController {

        controller = _newController;
    }
}pragma solidity ^0.5.2;



contract Discover is Controlled, ApproveAndCallFallBack, BancorFormula {

    using SafeMath for uint;

    MiniMeTokenInterface SNT;

    uint public total;

    uint public ceiling;

    uint public max;

    uint public decimals;

    uint public safeMax;

    struct Data {
        address developer;
        bytes32 id;
        bytes32 metadata;
        uint balance;
        uint rate;
        uint available;
        uint votesMinted;
        uint votesCast;
        uint effectiveBalance;
    }

    Data[] public dapps;
    mapping(bytes32 => uint) public id2index;
    mapping(bytes32 => bool) public existingIDs;

    event DAppCreated(bytes32 indexed id, uint newEffectiveBalance);
    event Upvote(bytes32 indexed id, uint newEffectiveBalance);
    event Downvote(bytes32 indexed id, uint newEffectiveBalance);
    event Withdraw(bytes32 indexed id, uint newEffectiveBalance);
    event MetadataUpdated(bytes32 indexed id);
    event CeilingUpdated(uint oldCeiling, uint newCeiling);


    constructor(MiniMeTokenInterface _SNT) public {
        SNT = _SNT;

        total = 6804870174;

        ceiling = 292;   // See here for more: https://observablehq.com/@andytudhope/dapp-store-snt-curation-mechanism

        decimals = 1000000; // 4 decimal points for %, 2 because we only use 1/100th of total in circulation

        max = total.mul(ceiling).div(decimals);

        safeMax = uint(77).mul(max).div(100); // Limited by accuracy of BancorFormula
    }

    function setCeiling(uint _newCeiling) external onlyController {

        emit CeilingUpdated(ceiling, _newCeiling);

        ceiling = _newCeiling;
        max = total.mul(ceiling).div(decimals);
        safeMax = uint(77).mul(max).div(100);
    }

    function createDApp(bytes32 _id, uint _amount, bytes32 _metadata) external {

        _createDApp(
            msg.sender,
            _id,
            _amount,
            _metadata);
    }

    function upvote(bytes32 _id, uint _amount) external {

        _upvote(msg.sender, _id, _amount);
    }

    function downvote(bytes32 _id, uint _amount) external {

        _downvote(msg.sender, _id, _amount);
    }

    function withdrawMax(bytes32 _id) external view returns(uint) {

        Data storage d = _getDAppById(_id);
        return d.available;
    }

    function withdraw(bytes32 _id, uint _amount) external {


        Data storage d = _getDAppById(_id);

        uint256 tokensQuantity = _amount.div(1 ether);

        require(msg.sender == d.developer, "Only the developer can withdraw SNT staked on this data");
        require(tokensQuantity <= d.available, "You can only withdraw a percentage of the SNT staked, less what you have already received");

        uint precision;
        uint result;

        d.balance = d.balance.sub(tokensQuantity);
        d.rate = decimals.sub(d.balance.mul(decimals).div(max));
        d.available = d.balance.mul(d.rate);

        (result, precision) = BancorFormula.power(
            d.available,
            decimals,
            uint32(decimals),
            uint32(d.rate));

        d.votesMinted = result >> precision;
        if (d.votesCast > d.votesMinted) {
            d.votesCast = d.votesMinted;
        }

        uint temp1 = d.votesCast.mul(d.rate).mul(d.available);
        uint temp2 = d.votesMinted.mul(decimals).mul(decimals);
        uint effect = temp1.div(temp2);

        d.effectiveBalance = d.balance.sub(effect);

        require(SNT.transfer(d.developer, _amount), "Transfer failed");

        emit Withdraw(_id, d.effectiveBalance);
    }

    function setMetadata(bytes32 _id, bytes32 _metadata) external {

        uint dappIdx = id2index[_id];
        Data storage d = dapps[dappIdx];
        require(d.developer == msg.sender, "Only the developer can update the metadata");
        d.metadata = _metadata;
        emit MetadataUpdated(_id);
    }

    function getDAppsCount() external view returns(uint) {

        return dapps.length;
    }

    function receiveApproval(
        address _from,
        uint256 _amount,
        address _token,
        bytes calldata _data
    )
        external
    {

        require(_token == address(SNT), "Wrong token");
        require(_token == address(msg.sender), "Wrong account");
        require(_data.length <= 196, "Incorrect data");

        bytes4 sig;
        bytes32 id;
        uint256 amount;
        bytes32 metadata;

        (sig, id, amount, metadata) = abiDecodeRegister(_data);
        require(_amount == amount, "Wrong amount");

        if (sig == bytes4(0x7e38d973)) {
            _createDApp(
                _from,
                id,
                amount,
                metadata);
        } else if (sig == bytes4(0xac769090)) {
            _downvote(_from, id, amount);
        } else if (sig == bytes4(0x2b3df690)) {
            _upvote(_from, id, amount);
        } else {
            revert("Wrong method selector");
        }
    }

    function upvoteEffect(bytes32 _id, uint _amount) external view returns(uint effect) {

        Data memory d = _getDAppById(_id);
        require(d.balance.add(_amount) <= safeMax, "You cannot upvote by this much, try with a lower amount");

        if (d.votesCast == 0) {
            return _amount;
        }

        uint precision;
        uint result;

        uint mBalance = d.balance.add(_amount);
        uint mRate = decimals.sub(mBalance.mul(decimals).div(max));
        uint mAvailable = mBalance.mul(mRate);

        (result, precision) = BancorFormula.power(
            mAvailable,
            decimals,
            uint32(decimals),
            uint32(mRate));

        uint mVMinted = result >> precision;

        uint temp1 = d.votesCast.mul(mRate).mul(mAvailable);
        uint temp2 = mVMinted.mul(decimals).mul(decimals);
        uint mEffect = temp1.div(temp2);

        uint mEBalance = mBalance.sub(mEffect);

        return (mEBalance.sub(d.effectiveBalance));
    }

    function downvoteCost(bytes32 _id) external view returns(uint b, uint vR, uint c) {

        Data memory d = _getDAppById(_id);
        return _downvoteCost(d);
    }

    function _createDApp(
        address _from,
        bytes32 _id,
        uint _amount,
        bytes32 _metadata
        )
      internal
      {

        require(!existingIDs[_id], "You must submit a unique ID");

        uint256 tokensQuantity = _amount.div(1 ether);

        require(tokensQuantity > 0, "You must spend some SNT to submit a ranking in order to avoid spam");
        require (tokensQuantity <= safeMax, "You cannot stake more SNT than the ceiling dictates");

        uint dappIdx = dapps.length;

        dapps.length++;

        Data storage d = dapps[dappIdx];
        d.developer = _from;
        d.id = _id;
        d.metadata = _metadata;

        uint precision;
        uint result;

        d.balance = tokensQuantity;
        d.rate = decimals.sub((d.balance).mul(decimals).div(max));
        d.available = d.balance.mul(d.rate);

        (result, precision) = BancorFormula.power(
            d.available,
            decimals,
            uint32(decimals),
            uint32(d.rate));

        d.votesMinted = result >> precision;
        d.votesCast = 0;
        d.effectiveBalance = tokensQuantity;

        id2index[_id] = dappIdx;
        existingIDs[_id] = true;

        require(SNT.transferFrom(_from, address(this), _amount), "Transfer failed");

        emit DAppCreated(_id, d.effectiveBalance);
    }

    function _upvote(address _from, bytes32 _id, uint _amount) internal {

        uint256 tokensQuantity = _amount.div(1 ether);
        require(tokensQuantity > 0, "You must send some SNT in order to upvote");

        Data storage d = _getDAppById(_id);

        require(d.balance.add(tokensQuantity) <= safeMax, "You cannot upvote by this much, try with a lower amount");

        uint precision;
        uint result;

        d.balance = d.balance.add(tokensQuantity);
        d.rate = decimals.sub((d.balance).mul(decimals).div(max));
        d.available = d.balance.mul(d.rate);

        (result, precision) = BancorFormula.power(
            d.available,
            decimals,
            uint32(decimals),
            uint32(d.rate));

        d.votesMinted = result >> precision;

        uint temp1 = d.votesCast.mul(d.rate).mul(d.available);
        uint temp2 = d.votesMinted.mul(decimals).mul(decimals);
        uint effect = temp1.div(temp2);

        d.effectiveBalance = d.balance.sub(effect);

        require(SNT.transferFrom(_from, address(this), _amount), "Transfer failed");

        emit Upvote(_id, d.effectiveBalance);
    }

    function _downvote(address _from, bytes32 _id, uint _amount) internal {

        uint256 tokensQuantity = _amount.div(1 ether);
        Data storage d = _getDAppById(_id);
        (uint b, uint vR, uint c) = _downvoteCost(d);

        require(tokensQuantity == c, "Incorrect amount: valid iff effect on ranking is 1%");

        d.available = d.available.sub(tokensQuantity);
        d.votesCast = d.votesCast.add(vR);
        d.effectiveBalance = d.effectiveBalance.sub(b);

        require(SNT.transferFrom(_from, d.developer, _amount), "Transfer failed");

        emit Downvote(_id, d.effectiveBalance);
    }

    function _downvoteCost(Data memory d) internal view returns(uint b, uint vR, uint c) {

        uint balanceDownBy = (d.effectiveBalance.div(100));
        uint votesRequired = (balanceDownBy.mul(d.votesMinted).mul(d.rate)).div(d.available);
        uint votesAvailable = d.votesMinted.sub(d.votesCast).sub(votesRequired);
        uint temp = (d.available.div(votesAvailable)).mul(votesRequired);
        uint cost = temp.div(decimals);
        return (balanceDownBy, votesRequired, cost);
    }

    function _getDAppById(bytes32 _id) internal view returns(Data storage d) {

        uint dappIdx = id2index[_id];
        d = dapps[dappIdx];
        require(d.id == _id, "Error fetching correct data");
    }

    function abiDecodeRegister(
        bytes memory _data
    )
        private
        pure
        returns(
            bytes4 sig,
            bytes32 id,
            uint256 amount,
            bytes32 metadata
        )
    {

        assembly {
            sig := mload(add(_data, add(0x20, 0)))
            id := mload(add(_data, 36))
            amount := mload(add(_data, 68))
            metadata := mload(add(_data, 100))
        }
    }
}
pragma solidity ^0.5.2;


interface TokenController {

    function proxyPayment(address _owner) external payable returns(bool);


    function onTransfer(address _from, address _to, uint _amount) external returns(bool);


    function onApprove(address _owner, address _spender, uint _amount) external
        returns(bool);

}pragma solidity ^0.5.2;


contract TokenFactory {

    function createCloneToken(
        address _parentToken,
        uint _snapshotBlock,
        string calldata _tokenName,
        uint8 _decimalUnits,
        string calldata _tokenSymbol,
        bool _transfersEnabled
        ) external returns (address payable);

}
pragma solidity ^0.5.2;





contract MiniMeToken is MiniMeTokenInterface, Controlled {


    string public name;                //The Token's name: e.g. DigixDAO Tokens
    uint8 public decimals;             //Number of decimals of the smallest unit
    string public symbol;              //An identifier: e.g. REP
    string public constant VERSION = "MMT_0.1"; //An arbitrary versioning scheme

    struct Checkpoint {

        uint128 fromBlock;

        uint128 value;
    }

    MiniMeToken public parentToken;

    uint public parentSnapShotBlock;

    uint public creationBlock;

    mapping (address => Checkpoint[]) balances;

    mapping (address => mapping (address => uint256)) allowed;

    Checkpoint[] totalSupplyHistory;

    bool public transfersEnabled;

    TokenFactory public tokenFactory;


    constructor(
        address _tokenFactory,
        address _parentToken,
        uint _parentSnapShotBlock,
        string memory _tokenName,
        uint8 _decimalUnits,
        string memory _tokenSymbol,
        bool _transfersEnabled
    ) 
        public
    {
        tokenFactory = TokenFactory(_tokenFactory);
        name = _tokenName;                                 // Set the name
        decimals = _decimalUnits;                          // Set the decimals
        symbol = _tokenSymbol;                             // Set the symbol
        parentToken = MiniMeToken(address(uint160(_parentToken)));
        parentSnapShotBlock = _parentSnapShotBlock;
        transfersEnabled = _transfersEnabled;
        creationBlock = block.number;
    }



    function transfer(address _to, uint256 _amount) external returns (bool success) {

        require(transfersEnabled);
        return doTransfer(msg.sender, _to, _amount);
    }

    function transferFrom(
        address _from,
        address _to,
        uint256 _amount
    ) 
        external 
        returns (bool success)
    {


        if (msg.sender != controller) {
            require(transfersEnabled);

            if (allowed[_from][msg.sender] < _amount) { 
                return false;
            }
            allowed[_from][msg.sender] -= _amount;
        }
        return doTransfer(_from, _to, _amount);
    }

    function doTransfer(
        address _from,
        address _to,
        uint _amount
    ) 
        internal
        returns(bool)
    {


        if (_amount == 0) {
            return true;
        }

        require(parentSnapShotBlock < block.number);

        require((_to != address(0)) && (_to != address(this)));

        uint256 previousBalanceFrom = balanceOfAt(_from, block.number);
        if (previousBalanceFrom < _amount) {
            return false;
        }

        if (isContract(controller)) {
            require(TokenController(controller).onTransfer(_from, _to, _amount));
        }

        updateValueAtNow(balances[_from], previousBalanceFrom - _amount);

        uint256 previousBalanceTo = balanceOfAt(_to, block.number);
        require(previousBalanceTo + _amount >= previousBalanceTo); // Check for overflow
        updateValueAtNow(balances[_to], previousBalanceTo + _amount);

        emit Transfer(_from, _to, _amount);

        return true;
    }

    function doApprove(
        address _from,
        address _spender,
        uint256 _amount
    )
        internal 
        returns (bool)
    {

        require(transfersEnabled);

        require((_amount == 0) || (allowed[_from][_spender] == 0));

        if (isContract(controller)) {
            require(TokenController(controller).onApprove(_from, _spender, _amount));
        }

        allowed[_from][_spender] = _amount;
        emit Approval(_from, _spender, _amount);
        return true;
    }

    function balanceOf(address _owner) external view returns (uint256 balance) {

        return balanceOfAt(_owner, block.number);
    }

    function approve(address _spender, uint256 _amount) external returns (bool success) {

        doApprove(msg.sender, _spender, _amount);
    }

    function allowance(
        address _owner,
        address _spender
    ) 
        external
        view
        returns (uint256 remaining)
    {

        return allowed[_owner][_spender];
    }
    function approveAndCall(
        address _spender,
        uint256 _amount,
        bytes calldata _extraData
    ) 
        external
        returns (bool success)
    {

        require(doApprove(msg.sender, _spender, _amount));

        ApproveAndCallFallBack(_spender).receiveApproval(
            msg.sender,
            _amount,
            address(this),
            _extraData
        );

        return true;
    }

    function totalSupply() external view returns (uint) {

        return totalSupplyAt(block.number);
    }



    function balanceOfAt(
        address _owner,
        uint _blockNumber
    ) 
        public
        view
        returns (uint) 
    {


        if ((balances[_owner].length == 0) || (balances[_owner][0].fromBlock > _blockNumber)) {
            if (address(parentToken) != address(0)) {
                return parentToken.balanceOfAt(_owner, min(_blockNumber, parentSnapShotBlock));
            } else {
                return 0;
            }

        } else {
            return getValueAt(balances[_owner], _blockNumber);
        }
    }

    function totalSupplyAt(uint _blockNumber) public view returns(uint) {


        if ((totalSupplyHistory.length == 0) || (totalSupplyHistory[0].fromBlock > _blockNumber)) {
            if (address(parentToken) != address(0)) {
                return parentToken.totalSupplyAt(min(_blockNumber, parentSnapShotBlock));
            } else {
                return 0;
            }

        } else {
            return getValueAt(totalSupplyHistory, _blockNumber);
        }
    }


    function createCloneToken(
        string calldata _cloneTokenName,
        uint8 _cloneDecimalUnits,
        string calldata _cloneTokenSymbol,
        uint _snapshotBlock,
        bool _transfersEnabled
        ) 
            external
            returns(address)
        {

        uint snapshotBlock = _snapshotBlock;
        if (snapshotBlock == 0) {
            snapshotBlock = block.number;
        }
        MiniMeToken cloneToken = MiniMeToken(
            tokenFactory.createCloneToken(
            address(this),
            snapshotBlock,
            _cloneTokenName,
            _cloneDecimalUnits,
            _cloneTokenSymbol,
            _transfersEnabled
            ));

        cloneToken.changeController(msg.sender);

        emit NewCloneToken(address(cloneToken), snapshotBlock);
        return address(cloneToken);
    }

    
    function generateTokens(
        address _owner,
        uint _amount
    )
        external
        onlyController
        returns (bool)
    {

        uint curTotalSupply = totalSupplyAt(block.number);
        require(curTotalSupply + _amount >= curTotalSupply); // Check for overflow
        uint previousBalanceTo = balanceOfAt(_owner, block.number);
        require(previousBalanceTo + _amount >= previousBalanceTo); // Check for overflow
        updateValueAtNow(totalSupplyHistory, curTotalSupply + _amount);
        updateValueAtNow(balances[_owner], previousBalanceTo + _amount);
        emit Transfer(address(0), _owner, _amount);
        return true;
    }

    function destroyTokens(
        address _owner,
        uint _amount
    ) 
        external
        onlyController
        returns (bool)
    {

        uint curTotalSupply = totalSupplyAt(block.number);
        require(curTotalSupply >= _amount);
        uint previousBalanceFrom = balanceOfAt(_owner, block.number);
        require(previousBalanceFrom >= _amount);
        updateValueAtNow(totalSupplyHistory, curTotalSupply - _amount);
        updateValueAtNow(balances[_owner], previousBalanceFrom - _amount);
        emit Transfer(_owner, address(0), _amount);
        return true;
    }


    function enableTransfers(bool _transfersEnabled) external onlyController {

        transfersEnabled = _transfersEnabled;
    }


    function getValueAt(
        Checkpoint[] storage checkpoints,
        uint _block
    ) 
        internal
        view
        returns (uint)
    {

        if (checkpoints.length == 0) {
            return 0;
        }

        if (_block >= checkpoints[checkpoints.length-1].fromBlock) {
            return checkpoints[checkpoints.length-1].value;
        }
        if (_block < checkpoints[0].fromBlock) {
            return 0;
        }

        uint min = 0;
        uint max = checkpoints.length-1;
        while (max > min) {
            uint mid = (max + min + 1) / 2;
            if (checkpoints[mid].fromBlock<=_block) {
                min = mid;
            } else {
                max = mid-1;
            }
        }
        return checkpoints[min].value;
    }

    function updateValueAtNow(Checkpoint[] storage checkpoints, uint _value) internal {

        if ((checkpoints.length == 0) || (checkpoints[checkpoints.length - 1].fromBlock < block.number)) {
            Checkpoint storage newCheckPoint = checkpoints[checkpoints.length++];
            newCheckPoint.fromBlock = uint128(block.number);
            newCheckPoint.value = uint128(_value);
        } else {
            Checkpoint storage oldCheckPoint = checkpoints[checkpoints.length-1];
            oldCheckPoint.value = uint128(_value);
        }
    }

    function isContract(address _addr) internal returns(bool) {

        uint size;
        if (_addr == address(0)) {
            return false;
        }    
        assembly {
            size := extcodesize(_addr)
        }
        return size>0;
    }

    function min(uint a, uint b) internal pure returns (uint) {

        return a < b ? a : b;
    }

    function () external payable {
        require(isContract(controller));
        require(TokenController(controller).proxyPayment.value(msg.value)(msg.sender));
    }


    function claimTokens(address _token) external onlyController {

        if (_token == address(0)) {
            controller.transfer(address(this).balance);
            return;
        }

        MiniMeToken token = MiniMeToken(address(uint160(_token)));
        uint balance = token.balanceOf(address(this));
        token.transfer(controller, balance);
        emit ClaimedTokens(_token, controller, balance);
    }

    event ClaimedTokens(address indexed _token, address indexed _controller, uint _amount);
    event Transfer(address indexed _from, address indexed _to, uint256 _amount);
    event NewCloneToken(address indexed _cloneToken, uint snapshotBlock);
    event Approval(
        address indexed _owner,
        address indexed _spender,
        uint256 _amount
    );

}
pragma solidity ^0.5.2;



contract MiniMeTokenFactory is TokenFactory {


    function createCloneToken(
        address _parentToken,
        uint _snapshotBlock,
        string calldata _tokenName,
        uint8 _decimalUnits,
        string calldata _tokenSymbol,
        bool _transfersEnabled
    ) external returns (address payable) 
    {

        MiniMeToken newToken = new MiniMeToken(
            address(this),
            _parentToken,
            _snapshotBlock,
            _tokenName,
            _decimalUnits,
            _tokenSymbol,
            _transfersEnabled
            );

        newToken.changeController(msg.sender);
        return address(newToken);
    }
}