pragma solidity 0.5.17;


library ModUtils {


    function modExp(uint256 base, uint256 exponent, uint256 p)
        internal
        view returns(uint256 o)
    {

        assembly {
            let output := mload(0x40)
            let args := add(output, 0x20)
            mstore(args, 0x20)
            mstore(add(args, 0x20), 0x20)
            mstore(add(args, 0x40), 0x20)
            mstore(add(args, 0x60), base)
            mstore(add(args, 0x80), exponent)
            mstore(add(args, 0xa0), p)

            if iszero(staticcall(not(0), 0x05, args, 0xc0, output, 0x20)) {
                revert(0, 0)
            }
            o := mload(output)
        }
    }

    function modSqrt(uint256 a, uint256 p)
        internal
        view returns(uint256)
    {


        if (legendre(a, p) != 1) {
            return 0;
        }

        if (a == 0) {
            return 0;
        }

        if (p == 2) {
            return p;
        }

        if (p % 4 == 3) {
            return modExp(a, (p + 1) / 4, p);
        }

        uint256 s = p - 1;
        uint256 e = 0;

        while (s % 2 == 0) {
            s = s / 2;
            e = e + 1;
        }

        uint256 n = 2;
        while (legendre(n, p) != -1) {
            n = n + 1;
        }

        uint256 x = modExp(a, (s + 1) / 2, p);
        uint256 b = modExp(a, s, p);
        uint256 g = modExp(n, s, p);
        uint256 r = e;
        uint256 gs = 0;
        uint256 m = 0;
        uint256 t = b;

        while (true) {
            t = b;
            m = 0;

            for (m = 0; m < r; m++) {
                if (t == 1) {
                    break;
                }
                t = modExp(t, 2, p);
            }

            if (m == 0) {
                return x;
            }

            gs = modExp(g, uint256(2) ** (r - m - 1), p);
            g = (gs * gs) % p;
            x = (x * gs) % p;
            b = (b * g) % p;
            r = m;
        }
    }

    function legendre(uint256 a, uint256 p)
        internal
        view returns(int256)
    {

        uint256 raised = modExp(a, (p - 1) / uint256(2), p);

        if (raised == 0 || raised == 1) {
            return int256(raised);
        } else if (raised == p - 1) {
            return -1;
        }

        require(false, "Failed to calculate legendre.");
    }
}pragma solidity 0.5.17;


library AltBn128 {


    using ModUtils for uint256;

    struct G1Point {
        uint256 x;
        uint256 y;
    }

    struct gfP2 {
        uint256 x;
        uint256 y;
    }

    struct G2Point {
        gfP2 x;
        gfP2 y;
    }

    uint256 constant p = 21888242871839275222246405745257275088696311157297823662689037894645226208583;

    function getP() internal pure returns (uint256) {

        return p;
    }

    uint256 constant g1x = 1;
    uint256 constant g1y = 2;
    function g1() internal pure returns (G1Point memory) {

        return G1Point(g1x, g1y);
    }

    uint256 constant g2xx = 11559732032986387107991004021392285783925812861821192530917403151452391805634;
    uint256 constant g2xy = 10857046999023057135944570762232829481370756359578518086990519993285655852781;
    uint256 constant g2yx = 4082367875863433681332203403145435568316851327593401208105741076214120093531;
    uint256 constant g2yy = 8495653923123431417604973247489272438418190587263600148770280649306958101930;
    function g2() internal pure returns (G2Point memory) {

        return G2Point(
            gfP2(g2xx, g2xy),
            gfP2(g2yx, g2yy)
        );
    }

    uint256 constant twistBx = 266929791119991161246907387137283842545076965332900288569378510910307636690;
    uint256 constant twistBy = 19485874751759354771024239261021720505790618469301721065564631296452457478373;
    function twistB() private pure returns (gfP2 memory) {

        return gfP2(twistBx, twistBy);
    }

    uint256 constant hexRootX = 21573744529824266246521972077326577680729363968861965890554801909984373949499;
    uint256 constant hexRootY = 16854739155576650954933913186877292401521110422362946064090026408937773542853;
    function hexRoot() private pure returns (gfP2 memory) {

        return gfP2(hexRootX, hexRootY);
    }

    function g1YFromX(uint256 x)
        internal
        view returns(uint256)
    {

        return ((x.modExp(3, p) + 3) % p).modSqrt(p);
    }

    function g2YFromX(gfP2 memory _x)
        internal
        pure returns(gfP2 memory y)
    {

        (uint256 xx, uint256 xy) = _gfP2CubeAddTwistB(_x.x, _x.y);

        uint256 a = 3869331240733915743250440106392954448556483137451914450067252501901456824595;
        uint256 b = 146360017852723390495514512480590656176144969185739259173561346299185050597;

        (uint256 xbx, uint256 xby) = _gfP2Pow(xx, xy, b);
        (uint256 yax, uint256 yay) = _gfP2Pow(xx, xy, a);
        (uint256 ya2x, uint256 ya2y) = _gfP2Pow(yax, yay, a);
        (y.x, y.y) = _gfP2Multiply(ya2x, ya2y, xbx, xby);

        while (!_g2X2y(xx, xy, y.x, y.y)) {
            (y.x, y.y) = _gfP2Multiply(y.x, y.y, hexRootX, hexRootY);
        }
    }

    function g1HashToPoint(bytes memory m)
        internal
        view returns(G1Point memory)
    {

        bytes32 h = sha256(m);
        uint256 x = uint256(h) % p;
        uint256 y;

        while (true) {
            y = g1YFromX(x);
            if (y > 0) {
                return G1Point(x, y);
            }
            x += 1;
        }
    }

    function parity(uint256 value) private pure returns (byte) {

        return bytes32(value)[31] & 0x01;
    }

    function g1Compress(G1Point memory point)
        internal
        pure returns(bytes32)
    {

        bytes32 m = bytes32(point.x);

        byte leadM = m[0] | parity(point.y) << 7;
        uint256 mask = 0xff << 31*8;
        m = (m & ~bytes32(mask)) | (leadM >> 0);

        return m;
    }

    function g2Compress(G2Point memory point)
        internal
        pure returns(bytes memory)
    {

        bytes32 m = bytes32(point.x.x);

        byte leadM = m[0] | parity(point.y.x) << 7;
        uint256 mask = 0xff << 31*8;
        m = (m & ~bytes32(mask)) | (leadM >> 0);

        return abi.encodePacked(m, bytes32(point.x.y));
    }

    function g1Decompress(bytes32 m)
        internal
        view returns(G1Point memory)
    {

        bytes32 mX = bytes32(0);
        byte leadX = m[0] & 0x7f;
        uint256 mask = 0xff << 31*8;
        mX = (m & ~bytes32(mask)) | (leadX >> 0);

        uint256 x = uint256(mX);
        uint256 y = g1YFromX(x);

        if (parity(y) != (m[0] & 0x80) >> 7) {
            y = p - y;
        }

        require(isG1PointOnCurve(G1Point(x, y)), "Malformed bn256.G1 point.");

        return G1Point(x, y);
    }

    function g1Unmarshal(bytes memory m) internal pure returns(G1Point memory) {

        require(
            m.length == 64,
            "Invalid G1 bytes length"
        );

        bytes32 x;
        bytes32 y;

        assembly {
            x := mload(add(m, 0x20))
            y := mload(add(m, 0x40))
        }

        return G1Point(uint256(x), uint256(y));
    }

    function g1Marshal(G1Point memory point) internal pure returns(bytes memory) {

        bytes memory m = new bytes(64);
        bytes32 x = bytes32(point.x);
        bytes32 y = bytes32(point.y);

        assembly {
            mstore(add(m, 32), x)
            mstore(add(m, 64), y)
        }

        return m;
    }

    function g2Unmarshal(bytes memory m) internal pure returns(G2Point memory) {

        require(
            m.length == 128,
            "Invalid G2 bytes length"
        );

        uint256 xx;
        uint256 xy;
        uint256 yx;
        uint256 yy;

        assembly {
            xx := mload(add(m, 0x20))
            xy := mload(add(m, 0x40))
            yx := mload(add(m, 0x60))
            yy := mload(add(m, 0x80))
        }

        return G2Point(gfP2(xx, xy), gfP2(yx,yy));
    }

    function g2Decompress(bytes memory m)
        internal
        pure returns(G2Point memory)
    {

        require(
            m.length == 64,
            "Invalid G2 compressed bytes length"
        );

        bytes32 x1;
        bytes32 x2;
        uint256 temp;

        assembly {
            temp := add(m, 32)
            x1 := mload(temp)
            temp := add(m, 64)
            x2 := mload(temp)
        }

        bytes32 mX = bytes32(0);
        byte leadX = x1[0] & 0x7f;
        uint256 mask = 0xff << 31*8;
        mX = (x1 & ~bytes32(mask)) | (leadX >> 0);

        gfP2 memory x = gfP2(uint256(mX), uint256(x2));
        gfP2 memory y = g2YFromX(x);

        if (parity(y.x) != (m[0] & 0x80) >> 7) {
            y.x = p - y.x;
            y.y = p - y.y;
        }

        return G2Point(x, y);
    }

    function g1Add(G1Point memory a, G1Point memory b)
        internal view returns (G1Point memory c) {

        assembly {
            let arg := mload(0x40)
            mstore(arg, mload(a))
            mstore(add(arg, 0x20), mload(add(a, 0x20)))
            mstore(add(arg, 0x40), mload(b))
            mstore(add(arg, 0x60), mload(add(b, 0x20)))
            if iszero(staticcall(not(0), 0x06, arg, 0x80, c, 0x40)) {
                revert(0, 0)
            }
        }
    }

    function gfP2Add(gfP2 memory a, gfP2 memory b) internal pure returns(gfP2 memory) {

        return gfP2(
            addmod(a.x, b.x, p),
            addmod(a.y, b.y, p)
        );
    }

    function gfP2Multiply(gfP2 memory a, gfP2 memory b) internal pure returns(gfP2 memory) {

        return gfP2(
            addmod(mulmod(a.x, b.y, p), mulmod(b.x, a.y, p), p),
            addmod(mulmod(a.y, b.y, p), p - mulmod(a.x, b.x, p), p)
        );
    }

    function gfP2Pow(gfP2 memory _a, uint256 _exp) internal pure returns(gfP2 memory result) {

        (uint256 x, uint256 y) = _gfP2Pow(_a.x, _a.y, _exp);
        return gfP2(x, y);
    }

    function gfP2Square(gfP2 memory a) internal pure returns (gfP2 memory) {

        return gfP2Multiply(a, a);
    }

    function gfP2Cube(gfP2 memory a) internal pure returns (gfP2 memory) {

        return gfP2Multiply(a, gfP2Square(a));
    }

    function gfP2CubeAddTwistB(gfP2 memory a) internal pure returns (gfP2 memory) {

        (uint256 x, uint256 y) = _gfP2CubeAddTwistB(a.x, a.y);
        return gfP2(x, y);
    }

    function g2X2y(gfP2 memory x, gfP2 memory y) internal pure returns(bool) {

        gfP2 memory y2;
        y2 = gfP2Square(y);

        return (y2.x == x.x && y2.y == x.y);
    }

    function isG1PointOnCurve(G1Point memory point) internal view returns (bool) {

        return point.y.modExp(2, p) == (point.x.modExp(3, p) + 3) % p;
    }

    function isG2PointOnCurve(G2Point memory point) internal pure returns(bool) {

        (uint256 y2x, uint256 y2y) = _gfP2Square(point.y.x, point.y.y);
        (uint256 x3x, uint256 x3y) = _gfP2CubeAddTwistB(point.x.x, point.x.y);

        return (y2x == x3x && y2y == x3y);
    }

    function scalarMultiply(G1Point memory p_1, uint256 scalar)
        internal view returns (G1Point memory p_2) {

        assembly {
            let arg := mload(0x40)
            mstore(arg, mload(p_1))
            mstore(add(arg, 0x20), mload(add(p_1, 0x20)))
            mstore(add(arg, 0x40), scalar)
            if iszero(staticcall(not(0), 0x07, arg, 0x60, p_2, 0x40)) {
                revert(0, 0)
            }
        }
    }

    function pairing(
        G1Point memory p1,
        G2Point memory p2,
        G1Point memory p3,
        G2Point memory p4
    ) internal view returns (bool result) {

        uint256 _c;
        assembly {
            let c := mload(0x40)
            let arg := add(c, 0x20)

            mstore(arg, mload(p1))
            mstore(add(arg, 0x20), mload(add(p1, 0x20)))

            let p2x := mload(p2)
            mstore(add(arg, 0x40), mload(p2x))
            mstore(add(arg, 0x60), mload(add(p2x, 0x20)))

            let p2y := mload(add(p2, 0x20))
            mstore(add(arg, 0x80), mload(p2y))
            mstore(add(arg, 0xa0), mload(add(p2y, 0x20)))

            mstore(add(arg, 0xc0), mload(p3))
            mstore(add(arg, 0xe0), mload(add(p3, 0x20)))

            let p4x := mload(p4)
            mstore(add(arg, 0x100), mload(p4x))
            mstore(add(arg, 0x120), mload(add(p4x, 0x20)))

            let p4y := mload(add(p4, 0x20))
            mstore(add(arg, 0x140), mload(p4y))
            mstore(add(arg, 0x160), mload(add(p4y, 0x20)))

            if iszero(staticcall(not(0), 0x08, arg, 0x180, c, 0x20)) {
                revert(0, 0)
            }
            _c := mload(c)
        }
        return _c != 0;
    }

    function _gfP2Add(uint256 ax, uint256 ay, uint256 bx, uint256 by)
        private pure returns(uint256 x, uint256 y) {

        x = addmod(ax, bx, p);
        y = addmod(ay, by, p);
    }

    function _gfP2Multiply(uint256 ax, uint256 ay, uint256 bx, uint256 by)
        private pure returns(uint256 x, uint256 y) {

        x = addmod(mulmod(ax, by, p), mulmod(bx, ay, p), p);
        y = addmod(mulmod(ay, by, p), p - mulmod(ax, bx, p), p);
    }

    function _gfP2CubeAddTwistB(uint256 ax, uint256 ay)
        private pure returns (uint256 x, uint256 y) {

        (uint256 a3x, uint256 a3y) = _gfP2Cube(ax, ay);
        return _gfP2Add(a3x, a3y, twistBx, twistBy);
    }

    function _gfP2Pow(uint256 _ax, uint256 _ay, uint256 _exp)
        private pure returns (uint256 x, uint256 y) {

        uint256 exp = _exp;
        x = 0;
        y = 1;
        uint256 ax = _ax;
        uint256 ay = _ay;

        while (exp > 0) {
            if (parity(exp) == 0x01) {
                (x, y) = _gfP2Multiply(x, y, ax, ay);
            }

            exp = exp / 2;
            (ax, ay) = _gfP2Multiply(ax, ay, ax, ay);
        }
    }

    function _gfP2Square(uint256 _ax, uint256 _ay)
        private pure returns (uint256 x, uint256 y) {

        return _gfP2Multiply(_ax, _ay, _ax, _ay);
    }

    function _gfP2Cube(uint256 _ax, uint256 _ay)
        private pure returns (uint256 x, uint256 y) {

        (uint256 _bx, uint256 _by) = _gfP2Square(_ax, _ay);
        return _gfP2Multiply(_ax, _ay, _bx, _by);
    }

    function _g2X2y(uint256 xx, uint256 xy, uint256 yx, uint256 yy)
        private pure returns (bool) {

        (uint256 y2x, uint256 y2y) = _gfP2Square(yx, yy);

        return (y2x == xx && y2y == xy);
    }
}pragma solidity 0.5.17;



library BLS {


    function sign(bytes memory message, uint256 secretKey) public view returns(bytes memory) {

        AltBn128.G1Point memory p_1 = AltBn128.g1HashToPoint(message);
        AltBn128.G1Point memory p_2 = AltBn128.scalarMultiply(p_1, secretKey);

        return AltBn128.g1Marshal(p_2);
    }

    function verify(
        bytes memory publicKey,
        bytes memory message,
        bytes memory signature
    ) public view returns (bool) {


        AltBn128.G1Point memory _signature = AltBn128.g1Unmarshal(signature);

        return AltBn128.pairing(
            AltBn128.G1Point(_signature.x, AltBn128.getP() - _signature.y),
            AltBn128.g2(),
            AltBn128.g1Unmarshal(message),
            AltBn128.g2Unmarshal(publicKey)
        );
    }

    function verifyBytes(
        bytes memory publicKey,
        bytes memory message,
        bytes memory signature
    ) public view returns (bool) {

        AltBn128.G1Point memory point = AltBn128.g1HashToPoint(message);
        bytes memory messageAsPoint = AltBn128.g1Marshal(point);

        return verify(publicKey, messageAsPoint, signature);
    }
}