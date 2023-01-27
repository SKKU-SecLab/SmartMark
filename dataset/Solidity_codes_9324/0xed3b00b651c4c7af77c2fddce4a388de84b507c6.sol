

pragma solidity ^0.6.0;

library Pairing {

    uint256 constant PRIME_Q = 21888242871839275222246405745257275088696311157297823662689037894645226208583;

    struct G1Point {
        uint256 X;
        uint256 Y;
    }

    struct G2Point {
        uint256[2] X;
        uint256[2] Y;
    }

    function negate(G1Point memory p) internal pure returns (G1Point memory) {

        if (p.X == 0 && p.Y == 0) {
            return G1Point(0, 0);
        } else {
            return G1Point(p.X, PRIME_Q - (p.Y % PRIME_Q));
        }
    }

    function plus(
        G1Point memory p1,
        G1Point memory p2
    ) internal view returns (G1Point memory r) {

        uint256[4] memory input = [
            p1.X, p1.Y,
            p2.X, p2.Y
        ];
        bool success;

        assembly {
            success := staticcall(sub(gas(), 2000), 6, input, 0xc0, r, 0x60)
            switch success case 0 { invalid() }
        }

        require(success, "pairing-add-failed");
    }

    function scalarMul(G1Point memory p, uint256 s) internal view returns (G1Point memory r) {

        uint256[3] memory input = [p.X, p.Y, s];
        bool success;

        assembly {
            success := staticcall(sub(gas(), 2000), 7, input, 0x80, r, 0x60)
            switch success case 0 { invalid() }
        }

        require(success, "pairing-mul-failed");
    }

    function pairing(
        G1Point memory a1,
        G2Point memory a2,
        G1Point memory b1,
        G2Point memory b2,
        G1Point memory c1,
        G2Point memory c2,
        G1Point memory d1,
        G2Point memory d2
    ) internal view returns (bool) {

        uint256[24] memory input = [
            a1.X, a1.Y, a2.X[0], a2.X[1], a2.Y[0], a2.Y[1],
            b1.X, b1.Y, b2.X[0], b2.X[1], b2.Y[0], b2.Y[1],
            c1.X, c1.Y, c2.X[0], c2.X[1], c2.Y[0], c2.Y[1],
            d1.X, d1.Y, d2.X[0], d2.X[1], d2.Y[0], d2.Y[1]
        ];
        uint256[1] memory out;
        bool success;

        assembly {
            success := staticcall(sub(gas(), 2000), 8, input, mul(24, 0x20), out, 0x20)
            switch success case 0 { invalid() }
        }

        require(success, "pairing-opcode-failed");
        return out[0] != 0;
    }
}

contract BatchTreeUpdateVerifier {

    uint256 constant SNARK_SCALAR_FIELD = 21888242871839275222246405745257275088548364400416034343698204186575808495617;
    uint256 constant PRIME_Q = 21888242871839275222246405745257275088696311157297823662689037894645226208583;
    using Pairing for *;

    struct VerifyingKey {
        Pairing.G1Point alfa1;
        Pairing.G2Point beta2;
        Pairing.G2Point gamma2;
        Pairing.G2Point delta2;
        Pairing.G1Point[2] IC;
    }

    function verifyingKey() internal pure returns (VerifyingKey memory vk) {

        vk.alfa1 = Pairing.G1Point(uint256(19360222473599753392474140999642462782406015010651475239676750626919891911298), uint256(15433641113177540616118974013882790364449258614668991375889700133598548962504));
        vk.beta2 = Pairing.G2Point([uint256(20352549598375923930163338415619514891333474976728345209732853168194461958130), uint256(15928938448757582303286704529408632825397883219516050215673087776022895999221)], [uint256(10164481431081050301006259076689316428456764009439079963261513338123552835437), uint256(8931105432035705738697832833376199018659019761364101988872766567112563208472)]);
        vk.gamma2 = Pairing.G2Point([uint256(9773073290448282032806995957352051830928286870763344330304060950189862630303), uint256(8204451641727457456525654290423707102913193984839196518035455938925589819651)], [uint256(11446678366000561995602686720421200690123845534305731431490243646198601060525), uint256(9012063374709103786811329806750746527391110577451870539020183222123210919598)]);
        vk.delta2 = Pairing.G2Point([uint256(1028204307662614490456879796808328179103972196893170031568703019449998490180), uint256(7094365175330511714867501549609647584245664153355165212680927387131750844096)], [uint256(10868771041910518094418451346158185819971244963373369132032907138162163476371), uint256(4793220841171189943394751429319720333700908680136571589422036850762324474308)]);
        vk.IC[0] = Pairing.G1Point(uint256(6389858293900471727828070450153193478269966090299602151830237445928594514512), uint256(20104199553659062256084112868936774039665965270744876859187110236412219060915));
        vk.IC[1] = Pairing.G1Point(uint256(4961000994550775281794403664908809733805597000992825829888303679432542020365), uint256(12218984008807329944204628569426155677502685935045687625083252682780978173448));

    }

    function verifyProof(
        bytes memory proof,
        uint256[1] memory input
    ) public view returns (bool) {

        uint256[8] memory p = abi.decode(proof, (uint256[8]));
        for (uint8 i = 0; i < p.length; i++) {
            require(p[i] < PRIME_Q, "verifier-proof-element-gte-prime-q");
        }
        Pairing.G1Point memory proofA = Pairing.G1Point(p[0], p[1]);
        Pairing.G2Point memory proofB = Pairing.G2Point([p[2], p[3]], [p[4], p[5]]);
        Pairing.G1Point memory proofC = Pairing.G1Point(p[6], p[7]);

        VerifyingKey memory vk = verifyingKey();
        Pairing.G1Point memory vkX = vk.IC[0];
        for (uint256 i = 0; i < input.length; i++) {
            require(input[i] < SNARK_SCALAR_FIELD, "verifier-input-gte-snark-scalar-field");
            vkX = Pairing.plus(vkX, Pairing.scalarMul(vk.IC[i + 1], input[i]));
        }

        return Pairing.pairing(
            Pairing.negate(proofA),
            proofB,
            vk.alfa1,
            vk.beta2,
            vkX,
            vk.gamma2,
            proofC,
            vk.delta2
        );
    }
}