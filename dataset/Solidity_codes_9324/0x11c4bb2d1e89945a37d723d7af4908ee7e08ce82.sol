
pragma solidity ^0.6.3;

library BN256G2 {

    uint256 internal constant FIELD_MODULUS = 0x30644e72e131a029b85045b68181585d97816a916871ca8d3c208c16d87cfd47;
    uint256 internal constant TWISTBX = 0x2b149d40ceb8aaae81be18991be06ac3b5b4c5e559dbefa33267e6dc24a138e5;
    uint256 internal constant TWISTBY = 0x9713b03af0fed4cd2cafadeed8fdf4a74fa084e52d1852e4a2bd0685c315d2;
    uint256 internal constant PTXX = 0;
    uint256 internal constant PTXY = 1;
    uint256 internal constant PTYX = 2;
    uint256 internal constant PTYY = 3;
    uint256 internal constant PTZX = 4;
    uint256 internal constant PTZY = 5;

    function ECTwistAdd(
        uint256 pt1xx,
        uint256 pt1xy,
        uint256 pt1yx,
        uint256 pt1yy,
        uint256 pt2xx,
        uint256 pt2xy,
        uint256 pt2yx,
        uint256 pt2yy
    ) public view returns (uint256, uint256, uint256, uint256) {

        if (pt1xx == 0 && pt1xy == 0 && pt1yx == 0 && pt1yy == 0) {
            if (!(pt2xx == 0 && pt2xy == 0 && pt2yx == 0 && pt2yy == 0)) {
                assert(_isOnCurve(pt2xx, pt2xy, pt2yx, pt2yy));
            }
            return (pt2xx, pt2xy, pt2yx, pt2yy);
        } else if (pt2xx == 0 && pt2xy == 0 && pt2yx == 0 && pt2yy == 0) {
            assert(_isOnCurve(pt1xx, pt1xy, pt1yx, pt1yy));
            return (pt1xx, pt1xy, pt1yx, pt1yy);
        }

        assert(_isOnCurve(pt1xx, pt1xy, pt1yx, pt1yy));
        assert(_isOnCurve(pt2xx, pt2xy, pt2yx, pt2yy));

        uint256[6] memory pt3 = _ECTwistAddJacobian(
            pt1xx,
            pt1xy,
            pt1yx,
            pt1yy,
            1,
            0,
            pt2xx,
            pt2xy,
            pt2yx,
            pt2yy,
            1,
            0
        );

        return
            _fromJacobian(
                pt3[PTXX],
                pt3[PTXY],
                pt3[PTYX],
                pt3[PTYY],
                pt3[PTZX],
                pt3[PTZY]
            );
    }

    function ECTwistMul(
        uint256 s,
        uint256 pt1xx,
        uint256 pt1xy,
        uint256 pt1yx,
        uint256 pt1yy
    ) public view returns (uint256, uint256, uint256, uint256) {

        uint256 pt1zx = 1;
        if (pt1xx == 0 && pt1xy == 0 && pt1yx == 0 && pt1yy == 0) {
            pt1xx = 1;
            pt1yx = 1;
            pt1zx = 0;
        } else {
            assert(_isOnCurve(pt1xx, pt1xy, pt1yx, pt1yy));
        }

        uint256[6] memory pt2 = _ECTwistMulJacobian(
            s,
            pt1xx,
            pt1xy,
            pt1yx,
            pt1yy,
            pt1zx,
            0
        );

        return
            _fromJacobian(
                pt2[PTXX],
                pt2[PTXY],
                pt2[PTYX],
                pt2[PTYY],
                pt2[PTZX],
                pt2[PTZY]
            );
    }

    function GetFieldModulus() public pure returns (uint256) {

        return FIELD_MODULUS;
    }

    function submod(uint256 a, uint256 b, uint256 n)
        internal
        pure
        returns (uint256)
    {

        return addmod(a, n - b, n);
    }

    function _FQ2Mul(uint256 xx, uint256 xy, uint256 yx, uint256 yy)
        internal
        pure
        returns (uint256, uint256)
    {

        return (
            submod(
                mulmod(xx, yx, FIELD_MODULUS),
                mulmod(xy, yy, FIELD_MODULUS),
                FIELD_MODULUS
            ),
            addmod(
                mulmod(xx, yy, FIELD_MODULUS),
                mulmod(xy, yx, FIELD_MODULUS),
                FIELD_MODULUS
            )
        );
    }

    function _FQ2Muc(uint256 xx, uint256 xy, uint256 c)
        internal
        pure
        returns (uint256, uint256)
    {

        return (mulmod(xx, c, FIELD_MODULUS), mulmod(xy, c, FIELD_MODULUS));
    }

    function _FQ2Add(uint256 xx, uint256 xy, uint256 yx, uint256 yy)
        internal
        pure
        returns (uint256, uint256)
    {

        return (addmod(xx, yx, FIELD_MODULUS), addmod(xy, yy, FIELD_MODULUS));
    }

    function _FQ2Sub(uint256 xx, uint256 xy, uint256 yx, uint256 yy)
        internal
        pure
        returns (uint256 rx, uint256 ry)
    {

        return (submod(xx, yx, FIELD_MODULUS), submod(xy, yy, FIELD_MODULUS));
    }

    function _FQ2Div(uint256 xx, uint256 xy, uint256 yx, uint256 yy)
        internal
        view
        returns (uint256, uint256)
    {

        (yx, yy) = _FQ2Inv(yx, yy);
        return _FQ2Mul(xx, xy, yx, yy);
    }

    function _FQ2Inv(uint256 x, uint256 y)
        internal
        view
        returns (uint256, uint256)
    {

        uint256 inv = _modInv(
            addmod(
                mulmod(y, y, FIELD_MODULUS),
                mulmod(x, x, FIELD_MODULUS),
                FIELD_MODULUS
            ),
            FIELD_MODULUS
        );
        return (
            mulmod(x, inv, FIELD_MODULUS),
            FIELD_MODULUS - mulmod(y, inv, FIELD_MODULUS)
        );
    }

    function _isOnCurve(uint256 xx, uint256 xy, uint256 yx, uint256 yy)
        internal
        pure
        returns (bool)
    {

        uint256 yyx;
        uint256 yyy;
        uint256 xxxx;
        uint256 xxxy;
        (yyx, yyy) = _FQ2Mul(yx, yy, yx, yy);
        (xxxx, xxxy) = _FQ2Mul(xx, xy, xx, xy);
        (xxxx, xxxy) = _FQ2Mul(xxxx, xxxy, xx, xy);
        (yyx, yyy) = _FQ2Sub(yyx, yyy, xxxx, xxxy);
        (yyx, yyy) = _FQ2Sub(yyx, yyy, TWISTBX, TWISTBY);
        return yyx == 0 && yyy == 0;
    }

    function _modInv(uint256 a, uint256 n)
        internal
        view
        returns (uint256 result)
    {

        bool success;
        assembly {
            let freemem := mload(0x40)
            mstore(freemem, 0x20)
            mstore(add(freemem, 0x20), 0x20)
            mstore(add(freemem, 0x40), 0x20)
            mstore(add(freemem, 0x60), a)
            mstore(add(freemem, 0x80), sub(n, 2))
            mstore(add(freemem, 0xA0), n)
            success := staticcall(
                sub(gas(), 2000),
                5,
                freemem,
                0xC0,
                freemem,
                0x20
            )
            result := mload(freemem)
        }
        require(success);
    }

    function _fromJacobian(
        uint256 pt1xx,
        uint256 pt1xy,
        uint256 pt1yx,
        uint256 pt1yy,
        uint256 pt1zx,
        uint256 pt1zy
    )
        internal
        view
        returns (uint256 pt2xx, uint256 pt2xy, uint256 pt2yx, uint256 pt2yy)
    {

        uint256 invzx;
        uint256 invzy;
        (invzx, invzy) = _FQ2Inv(pt1zx, pt1zy);
        (pt2xx, pt2xy) = _FQ2Mul(pt1xx, pt1xy, invzx, invzy);
        (pt2yx, pt2yy) = _FQ2Mul(pt1yx, pt1yy, invzx, invzy);
    }

    function _ECTwistAddJacobian(
        uint256 pt1xx,
        uint256 pt1xy,
        uint256 pt1yx,
        uint256 pt1yy,
        uint256 pt1zx,
        uint256 pt1zy,
        uint256 pt2xx,
        uint256 pt2xy,
        uint256 pt2yx,
        uint256 pt2yy,
        uint256 pt2zx,
        uint256 pt2zy
    ) internal pure returns (uint256[6] memory pt3) {

        if (pt1zx == 0 && pt1zy == 0) {
            (
                pt3[PTXX],
                pt3[PTXY],
                pt3[PTYX],
                pt3[PTYY],
                pt3[PTZX],
                pt3[PTZY]
            ) = (pt2xx, pt2xy, pt2yx, pt2yy, pt2zx, pt2zy);
            return pt3;
        } else if (pt2zx == 0 && pt2zy == 0) {
            (
                pt3[PTXX],
                pt3[PTXY],
                pt3[PTYX],
                pt3[PTYY],
                pt3[PTZX],
                pt3[PTZY]
            ) = (pt1xx, pt1xy, pt1yx, pt1yy, pt1zx, pt1zy);
            return pt3;
        }

        (pt2yx, pt2yy) = _FQ2Mul(pt2yx, pt2yy, pt1zx, pt1zy); // U1 = y2 * z1
        (pt3[PTYX], pt3[PTYY]) = _FQ2Mul(pt1yx, pt1yy, pt2zx, pt2zy); // U2 = y1 * z2
        (pt2xx, pt2xy) = _FQ2Mul(pt2xx, pt2xy, pt1zx, pt1zy); // V1 = x2 * z1
        (pt3[PTZX], pt3[PTZY]) = _FQ2Mul(pt1xx, pt1xy, pt2zx, pt2zy); // V2 = x1 * z2

        if (pt2xx == pt3[PTZX] && pt2xy == pt3[PTZY]) {
            if (pt2yx == pt3[PTYX] && pt2yy == pt3[PTYY]) {
                (
                    pt3[PTXX],
                    pt3[PTXY],
                    pt3[PTYX],
                    pt3[PTYY],
                    pt3[PTZX],
                    pt3[PTZY]
                ) = _ECTwistDoubleJacobian(
                    pt1xx,
                    pt1xy,
                    pt1yx,
                    pt1yy,
                    pt1zx,
                    pt1zy
                );
                return pt3;
            }
            (
                pt3[PTXX],
                pt3[PTXY],
                pt3[PTYX],
                pt3[PTYY],
                pt3[PTZX],
                pt3[PTZY]
            ) = (1, 0, 1, 0, 0, 0);
            return pt3;
        }

        (pt2zx, pt2zy) = _FQ2Mul(pt1zx, pt1zy, pt2zx, pt2zy); // W = z1 * z2
        (pt1xx, pt1xy) = _FQ2Sub(pt2yx, pt2yy, pt3[PTYX], pt3[PTYY]); // U = U1 - U2
        (pt1yx, pt1yy) = _FQ2Sub(pt2xx, pt2xy, pt3[PTZX], pt3[PTZY]); // V = V1 - V2
        (pt1zx, pt1zy) = _FQ2Mul(pt1yx, pt1yy, pt1yx, pt1yy); // V_squared = V * V
        (pt2yx, pt2yy) = _FQ2Mul(pt1zx, pt1zy, pt3[PTZX], pt3[PTZY]); // V_squared_times_V2 = V_squared * V2
        (pt1zx, pt1zy) = _FQ2Mul(pt1zx, pt1zy, pt1yx, pt1yy); // V_cubed = V * V_squared
        (pt3[PTZX], pt3[PTZY]) = _FQ2Mul(pt1zx, pt1zy, pt2zx, pt2zy); // newz = V_cubed * W
        (pt2xx, pt2xy) = _FQ2Mul(pt1xx, pt1xy, pt1xx, pt1xy); // U * U
        (pt2xx, pt2xy) = _FQ2Mul(pt2xx, pt2xy, pt2zx, pt2zy); // U * U * W
        (pt2xx, pt2xy) = _FQ2Sub(pt2xx, pt2xy, pt1zx, pt1zy); // U * U * W - V_cubed
        (pt2zx, pt2zy) = _FQ2Muc(pt2yx, pt2yy, 2); // 2 * V_squared_times_V2
        (pt2xx, pt2xy) = _FQ2Sub(pt2xx, pt2xy, pt2zx, pt2zy); // A = U * U * W - V_cubed - 2 * V_squared_times_V2
        (pt3[PTXX], pt3[PTXY]) = _FQ2Mul(pt1yx, pt1yy, pt2xx, pt2xy); // newx = V * A
        (pt1yx, pt1yy) = _FQ2Sub(pt2yx, pt2yy, pt2xx, pt2xy); // V_squared_times_V2 - A
        (pt1yx, pt1yy) = _FQ2Mul(pt1xx, pt1xy, pt1yx, pt1yy); // U * (V_squared_times_V2 - A)
        (pt1xx, pt1xy) = _FQ2Mul(pt1zx, pt1zy, pt3[PTYX], pt3[PTYY]); // V_cubed * U2
        (pt3[PTYX], pt3[PTYY]) = _FQ2Sub(pt1yx, pt1yy, pt1xx, pt1xy); // newy = U * (V_squared_times_V2 - A) - V_cubed * U2
    }

    function _ECTwistDoubleJacobian(
        uint256 pt1xx,
        uint256 pt1xy,
        uint256 pt1yx,
        uint256 pt1yy,
        uint256 pt1zx,
        uint256 pt1zy
    )
        internal
        pure
        returns (
            uint256 pt2xx,
            uint256 pt2xy,
            uint256 pt2yx,
            uint256 pt2yy,
            uint256 pt2zx,
            uint256 pt2zy
        )
    {

        (pt2xx, pt2xy) = _FQ2Muc(pt1xx, pt1xy, 3); // 3 * x
        (pt2xx, pt2xy) = _FQ2Mul(pt2xx, pt2xy, pt1xx, pt1xy); // W = 3 * x * x
        (pt1zx, pt1zy) = _FQ2Mul(pt1yx, pt1yy, pt1zx, pt1zy); // S = y * z
        (pt2yx, pt2yy) = _FQ2Mul(pt1xx, pt1xy, pt1yx, pt1yy); // x * y
        (pt2yx, pt2yy) = _FQ2Mul(pt2yx, pt2yy, pt1zx, pt1zy); // B = x * y * S
        (pt1xx, pt1xy) = _FQ2Mul(pt2xx, pt2xy, pt2xx, pt2xy); // W * W
        (pt2zx, pt2zy) = _FQ2Muc(pt2yx, pt2yy, 8); // 8 * B
        (pt1xx, pt1xy) = _FQ2Sub(pt1xx, pt1xy, pt2zx, pt2zy); // H = W * W - 8 * B
        (pt2zx, pt2zy) = _FQ2Mul(pt1zx, pt1zy, pt1zx, pt1zy); // S_squared = S * S
        (pt2yx, pt2yy) = _FQ2Muc(pt2yx, pt2yy, 4); // 4 * B
        (pt2yx, pt2yy) = _FQ2Sub(pt2yx, pt2yy, pt1xx, pt1xy); // 4 * B - H
        (pt2yx, pt2yy) = _FQ2Mul(pt2yx, pt2yy, pt2xx, pt2xy); // W * (4 * B - H)
        (pt2xx, pt2xy) = _FQ2Muc(pt1yx, pt1yy, 8); // 8 * y
        (pt2xx, pt2xy) = _FQ2Mul(pt2xx, pt2xy, pt1yx, pt1yy); // 8 * y * y
        (pt2xx, pt2xy) = _FQ2Mul(pt2xx, pt2xy, pt2zx, pt2zy); // 8 * y * y * S_squared
        (pt2yx, pt2yy) = _FQ2Sub(pt2yx, pt2yy, pt2xx, pt2xy); // newy = W * (4 * B - H) - 8 * y * y * S_squared
        (pt2xx, pt2xy) = _FQ2Muc(pt1xx, pt1xy, 2); // 2 * H
        (pt2xx, pt2xy) = _FQ2Mul(pt2xx, pt2xy, pt1zx, pt1zy); // newx = 2 * H * S
        (pt2zx, pt2zy) = _FQ2Mul(pt1zx, pt1zy, pt2zx, pt2zy); // S * S_squared
        (pt2zx, pt2zy) = _FQ2Muc(pt2zx, pt2zy, 8); // newz = 8 * S * S_squared
    }

    function _ECTwistMulJacobian(
        uint256 d,
        uint256 pt1xx,
        uint256 pt1xy,
        uint256 pt1yx,
        uint256 pt1yy,
        uint256 pt1zx,
        uint256 pt1zy
    ) internal pure returns (uint256[6] memory pt2) {

        while (d != 0) {
            if ((d & 1) != 0) {
                pt2 = _ECTwistAddJacobian(
                    pt2[PTXX],
                    pt2[PTXY],
                    pt2[PTYX],
                    pt2[PTYY],
                    pt2[PTZX],
                    pt2[PTZY],
                    pt1xx,
                    pt1xy,
                    pt1yx,
                    pt1yy,
                    pt1zx,
                    pt1zy
                );
            }
            (pt1xx, pt1xy, pt1yx, pt1yy, pt1zx, pt1zy) = _ECTwistDoubleJacobian(
                pt1xx,
                pt1xy,
                pt1yx,
                pt1yy,
                pt1zx,
                pt1zy
            );

            d = d / 2;
        }
    }
}
pragma solidity ^0.6.3;


library Pairing {

    struct G1Point {
        uint256 X;
        uint256 Y;
    }
    struct G2Point {
        uint256[2] X;
        uint256[2] Y;
    }
    function P1() internal pure returns (G1Point memory) {

        return G1Point(1, 2);
    }
    function P2() internal pure returns (G2Point memory) {

        return
            G2Point(
                [
                    11559732032986387107991004021392285783925812861821192530917403151452391805634,
                    10857046999023057135944570762232829481370756359578518086990519993285655852781
                ],
                [
                    4082367875863433681332203403145435568316851327593401208105741076214120093531,
                    8495653923123431417604973247489272438418190587263600148770280649306958101930
                ]
            );
    }
    function negate(G1Point memory p) internal pure returns (G1Point memory) {

        uint256 q = 21888242871839275222246405745257275088696311157297823662689037894645226208583;
        if (p.X == 0 && p.Y == 0) return G1Point(0, 0);
        return G1Point(p.X, q - (p.Y % q));
    }
    function addition(G1Point memory p1, G1Point memory p2)
        internal
        returns (G1Point memory r)
    {

        uint256[4] memory input;
        input[0] = p1.X;
        input[1] = p1.Y;
        input[2] = p2.X;
        input[3] = p2.Y;
        bool success;
        assembly {
            success := call(sub(gas(), 2000), 6, 0, input, 0xc0, r, 0x60)
            switch success
                case 0 {
                    invalid()
                }
        }
        require(success);
    }
    function addition(G2Point memory p1, G2Point memory p2)
        internal
        view
        returns (G2Point memory r)
    {

        (r.X[1], r.X[0], r.Y[1], r.Y[0]) = BN256G2.ECTwistAdd(
            p1.X[1],
            p1.X[0],
            p1.Y[1],
            p1.Y[0],
            p2.X[1],
            p2.X[0],
            p2.Y[1],
            p2.Y[0]
        );
    }
    function scalar_mul(G1Point memory p, uint256 s)
        internal
        returns (G1Point memory r)
    {

        uint256[3] memory input;
        input[0] = p.X;
        input[1] = p.Y;
        input[2] = s;
        bool success;
        assembly {
            success := call(sub(gas(), 2000), 7, 0, input, 0x80, r, 0x60)
            switch success
                case 0 {
                    invalid()
                }
        }
        require(success);
    }
    function pairing(G1Point[] memory p1, G2Point[] memory p2)
        internal
        returns (bool)
    {

        require(p1.length == p2.length);
        uint256 elements = p1.length;
        uint256 inputSize = elements * 6;
        uint256[] memory input = new uint256[](inputSize);
        for (uint256 i = 0; i < elements; i++) {
            input[i * 6 + 0] = p1[i].X;
            input[i * 6 + 1] = p1[i].Y;
            input[i * 6 + 2] = p2[i].X[0];
            input[i * 6 + 3] = p2[i].X[1];
            input[i * 6 + 4] = p2[i].Y[0];
            input[i * 6 + 5] = p2[i].Y[1];
        }
        uint256[1] memory out;
        bool success;
        assembly {
            success := call(
                sub(gas(), 2000),
                8,
                0,
                add(input, 0x20),
                mul(inputSize, 0x20),
                out,
                0x20
            )
            switch success
                case 0 {
                    invalid()
                }
        }
        require(success);
        return out[0] != 0;
    }
    function pairingProd2(
        G1Point memory a1,
        G2Point memory a2,
        G1Point memory b1,
        G2Point memory b2
    ) internal returns (bool) {

        G1Point[] memory p1 = new G1Point[](2);
        G2Point[] memory p2 = new G2Point[](2);
        p1[0] = a1;
        p1[1] = b1;
        p2[0] = a2;
        p2[1] = b2;
        return pairing(p1, p2);
    }
    function pairingProd3(
        G1Point memory a1,
        G2Point memory a2,
        G1Point memory b1,
        G2Point memory b2,
        G1Point memory c1,
        G2Point memory c2
    ) internal returns (bool) {

        G1Point[] memory p1 = new G1Point[](3);
        G2Point[] memory p2 = new G2Point[](3);
        p1[0] = a1;
        p1[1] = b1;
        p1[2] = c1;
        p2[0] = a2;
        p2[1] = b2;
        p2[2] = c2;
        return pairing(p1, p2);
    }
    function pairingProd4(
        G1Point memory a1,
        G2Point memory a2,
        G1Point memory b1,
        G2Point memory b2,
        G1Point memory c1,
        G2Point memory c2,
        G1Point memory d1,
        G2Point memory d2
    ) internal returns (bool) {

        G1Point[] memory p1 = new G1Point[](4);
        G2Point[] memory p2 = new G2Point[](4);
        p1[0] = a1;
        p1[1] = b1;
        p1[2] = c1;
        p1[3] = d1;
        p2[0] = a2;
        p2[1] = b2;
        p2[2] = c2;
        p2[3] = d2;
        return pairing(p1, p2);
    }
}
pragma solidity ^0.6.3;


contract ZeneKa {

    using Pairing for *;
    uint256 constant SNARK_SCALAR_FIELD = 21888242871839275222246405745257275088548364400416034343698204186575808495617;

    event Register(bytes32 indexed _id, address indexed _registrant);
    event Commit(
        bytes32 indexed _id,
        bytes32 indexed _proofHash,
        address indexed _prover
    );
    event Verify(
        bytes32 indexed _id,
        bytes32 indexed _proofHash,
        address indexed _prover
    );

    mapping(bytes32 => bytes32) _idToCommit;
    mapping(bytes32 => address) _proofHashToProver;
    mapping(bytes32 => uint256) _proofHashToBlock;
    mapping(bytes32 => bool) _proofHashToProven;
    mapping(bytes32 => mapping(address => uint256[])) _idToProverToInput;
    mapping(bytes32 => mapping(address => bool)) _idToProverToVerified;

    function _verified(bytes32 _id, bytes32 _proofHash, uint256[] memory _input)
        internal
    {

        _proofHashToProven[_proofHash] = true;
        _idToProverToVerified[_id][msg.sender] = true;
        _idToProverToInput[_id][msg.sender] = _input;
        emit Verify(_id, _proofHash, msg.sender);
    }

    function verify(bytes32 _id, address _address)
        public
        view
        returns (bool isVerified)
    {

        return _idToProverToVerified[_id][_address];
    }

    function input(bytes32 _id, address _prover)
        public
        view
        returns (uint256[] memory zkInput)
    {

        require(_idToProverToVerified[_id][_prover], "Unverified");
        return _idToProverToInput[_id][_prover];
    }

    function prover(bytes32 _proofHash)
        public
        view
        returns (address commitProver)
    {

        return _proofHashToProver[_proofHash];
    }

    function commitBlock(bytes32 _proofHash)
        public
        view
        returns (uint256 commitBlockNumber)
    {

        return _proofHashToBlock[_proofHash];
    }
}
pragma solidity ^0.6.3;



contract ZeneKaPGHR13 is ZeneKa {

    struct VerifyingKeyPGHR13 {
        Pairing.G2Point a;
        Pairing.G1Point b;
        Pairing.G2Point c;
        Pairing.G2Point gamma;
        Pairing.G1Point gamma_beta_1;
        Pairing.G2Point gamma_beta_2;
        Pairing.G2Point z;
        Pairing.G1Point[] ic;
    }

    struct ProofPGHR13 {
        Pairing.G1Point a;
        Pairing.G1Point a_p;
        Pairing.G2Point b;
        Pairing.G1Point b_p;
        Pairing.G1Point c;
        Pairing.G1Point c_p;
        Pairing.G1Point k;
        Pairing.G1Point h;
    }

    struct ParamsPGHR13 {
        bytes32[2][2] a;
        bytes32[2] b;
        bytes32[2][2] c;
        bytes32[2][2] gamma;
        bytes32[2] gamma_beta_1;
        bytes32[2][2] gamma_beta_2;
        bytes32[2][2] z;
        uint256 ic_len;
        bytes32[2][] ic;
        bool registered;
    }

    mapping(bytes32 => ParamsPGHR13) private _idToVkParamsPGHR13;

    function _verifyingKeyPGHR13(bytes32 _id)
        internal
        view
        returns (VerifyingKeyPGHR13 memory vk)
    {

        ParamsPGHR13 memory params = _idToVkParamsPGHR13[_id];

        vk.a = Pairing.G2Point(
            [uint256(params.a[0][0]), uint256(params.a[0][1])],
            [uint256(params.a[1][0]), uint256(params.a[1][1])]
        );
        vk.b = Pairing.G1Point(uint256(params.b[0]), uint256(params.b[1]));
        vk.c = Pairing.G2Point(
            [uint256(params.c[0][0]), uint256(params.c[0][1])],
            [uint256(params.c[1][0]), uint256(params.c[1][1])]
        );
        vk.gamma = Pairing.G2Point(
            [uint256(params.gamma[0][0]), uint256(params.gamma[0][1])],
            [uint256(params.gamma[1][0]), uint256(params.gamma[1][1])]
        );
        vk.gamma_beta_1 = Pairing.G1Point(
            uint256(params.gamma_beta_1[0]),
            uint256(params.gamma_beta_1[1])
        );
        vk.gamma_beta_2 = Pairing.G2Point(
            [
                uint256(params.gamma_beta_2[0][0]),
                uint256(params.gamma_beta_2[0][1])
            ],
            [
                uint256(params.gamma_beta_2[1][0]),
                uint256(params.gamma_beta_2[1][1])
            ]
        );
        vk.z = Pairing.G2Point(
            [uint256(params.z[0][0]), uint256(params.z[0][1])],
            [uint256(params.z[1][0]), uint256(params.z[1][1])]
        );
        vk.ic = new Pairing.G1Point[](params.ic_len);
        for (uint256 i = 0; i < params.ic_len; i++) {
            vk.ic[i] = Pairing.G1Point(
                uint256(params.ic[i][0]),
                uint256(params.ic[i][1])
            );
        }
    }

    function registerPGHR13(
        bytes32[2][2] memory _a,
        bytes32[2] memory _b,
        bytes32[2][2] memory _c,
        bytes32[2][2] memory _gamma,
        bytes32[2] memory _gamma_beta_1,
        bytes32[2][2] memory _gamma_beta_2,
        bytes32[2][2] memory _z,
        uint256 _ic_len,
        bytes32[2][] memory _ic
    ) public returns (bool isRegistered) {

        bytes32 id = keccak256(
            abi.encodePacked(
                _a,
                _b,
                _c,
                _gamma,
                _gamma_beta_1,
                _gamma_beta_2,
                _z,
                _ic_len,
                _ic
            )
        );

        if (_idToVkParamsPGHR13[id].registered) return true;

        _idToVkParamsPGHR13[id] = ParamsPGHR13({
            a: _a,
            b: _b,
            c: _c,
            gamma: _gamma,
            gamma_beta_1: _gamma_beta_1,
            gamma_beta_2: _gamma_beta_2,
            z: _z,
            ic_len: _ic_len,
            ic: _ic,
            registered: true
        });

        emit Register(id, msg.sender);
        return true;
    }

    function commitPGHR13(bytes32 _id, bytes32 _proofHash)
        public
        returns (bool didCommit)
    {

        if (
            !_idToVkParamsPGHR13[_id].registered ||
            _proofHashToProver[_proofHash] != address(0)
        ) return false;
        _proofHashToProver[_proofHash] = msg.sender;
        _proofHashToBlock[_proofHash] = block.number;
        emit Commit(_id, _proofHash, msg.sender);
        return true;
    }

    function provePGHR13(
        bytes32 _id,
        uint256[2] memory _a,
        uint256[2] memory _a_p,
        uint256[2][2] memory _b,
        uint256[2] memory _b_p,
        uint256[2] memory _c,
        uint256[2] memory _c_p,
        uint256[2] memory _h,
        uint256[2] memory _k,
        uint256[] memory _input
    ) public returns (bool isValid) {

        bytes32 proofHash = keccak256(
            abi.encodePacked(_a, _a_p, _b, _b_p, _c, _c_p, _h, _k, _input)
        );
        if (_proofHashToProven[proofHash]) return true;
        if (
            !_idToVkParamsPGHR13[_id].registered ||
            _proofHashToProver[proofHash] != msg.sender ||
            block.number <= _proofHashToBlock[proofHash]
        ) return false;

        VerifyingKeyPGHR13 memory vk = _verifyingKeyPGHR13(_id);
        if (_input.length + 1 != _idToVkParamsPGHR13[_id].ic_len) return false;
        ProofPGHR13 memory proof;
        proof.a = Pairing.G1Point(_a[0], _a[1]);
        proof.a_p = Pairing.G1Point(_a_p[0], _a_p[1]);
        proof.b = Pairing.G2Point([_b[0][0], _b[0][1]], [_b[1][0], _b[1][1]]);
        proof.b_p = Pairing.G1Point(_b_p[0], _b_p[1]);
        proof.c = Pairing.G1Point(_c[0], _c[1]);
        proof.c_p = Pairing.G1Point(_c_p[0], _c_p[1]);
        proof.h = Pairing.G1Point(_h[0], _h[1]);
        proof.k = Pairing.G1Point(_k[0], _k[1]);

        Pairing.G1Point memory vk_x = Pairing.G1Point(0, 0);
        for (uint256 i = 0; i < _input.length; i++) {
            if (_input[i] >= SNARK_SCALAR_FIELD) return false;
            vk_x = Pairing.addition(
                vk_x,
                Pairing.scalar_mul(vk.ic[i + 1], _input[i])
            );
        }
        vk_x = Pairing.addition(vk_x, vk.ic[0]);
        if (
            !Pairing.pairingProd2(
                proof.a,
                vk.a,
                Pairing.negate(proof.a_p),
                Pairing.P2()
            ) ||
            !Pairing.pairingProd2(
                vk.b,
                proof.b,
                Pairing.negate(proof.b_p),
                Pairing.P2()
            ) ||
            !Pairing.pairingProd2(
                proof.c,
                vk.c,
                Pairing.negate(proof.c_p),
                Pairing.P2()
            ) ||
            !Pairing.pairingProd3(
                proof.k,
                vk.gamma,
                Pairing.negate(
                    Pairing.addition(vk_x, Pairing.addition(proof.a, proof.c))
                ),
                vk.gamma_beta_2,
                Pairing.negate(vk.gamma_beta_1),
                proof.b
            ) ||
            !Pairing.pairingProd3(
                Pairing.addition(vk_x, proof.a),
                proof.b,
                Pairing.negate(proof.h),
                vk.z,
                Pairing.negate(proof.c),
                Pairing.P2()
            )
        ) return false;

        _verified(_id, proofHash, _input);
        return true;
    }
}
