pragma solidity ^0.5.2;

contract IFactRegistry {

    function isValid(bytes32 fact)
        external view
        returns(bool);

}
pragma solidity ^0.5.2;


contract EscapeVerifier is IFactRegistry {


    uint256 constant internal N_TABLES = 63;

    address[N_TABLES] lookupTables;
    constructor(address[N_TABLES] memory tables)
        public {
        lookupTables = tables;

        assembly {
            if gt(lookupTables_slot, 0) {
                revert(0, 0)
            }

        }
    }

    function verifyEscape(uint256[] calldata escapeProof) external {

        uint256 proofLength = escapeProof.length;

        require(proofLength >= 68, "Proof too short.");

        require(proofLength < 200, "Proof too long.");

        require((proofLength & 1) == 0, "Proof length must be even.");

        uint256 nHashes = (proofLength - 2) / 2;

        uint256 height = nHashes - 2;

        uint256 vaultId = escapeProof[proofLength - 1] >> 8;
        require(vaultId < 2**height, "vaultId not in tree.");

        uint256 rowSize = (2 * nHashes) * 0x20;
        uint256[] memory proof = escapeProof;
        assembly {
            proof := add(proof, 0x20)

            function raise_error(message, msg_len) {

                mstore(0, 0x08c379a000000000000000000000000000000000000000000000000000000000)
                mstore(0x4, 0x20)
                mstore(0x24, msg_len)
                mstore(0x44, message)
                revert(0, add(0x44, msg_len))
            }

            let starkKey := shr(4, mload(proof))
            let tokenId := and(mload(add(proof, 0x1f)),
                               0x0fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff)

            let primeMinusOne := 0x800000000000011000000000000000000000000000000000000000000000000
            if or(gt(starkKey, primeMinusOne), gt(tokenId, primeMinusOne)) {
                raise_error("Bad starkKey or tokenId.", 24)
            }

            let nodeSelectors := shl(1, vaultId)

            let table := mload(0x40)
            let tableEnd := add(table, mul(rowSize, /*N_TABLES*/63))

            for { let i := 0 } lt(i, 63) { i := add(i, 1)} {
                if iszero(staticcall(gas, sload(i), add(proof, i), rowSize,
                                     add(table, mul(i, rowSize)), rowSize)) {
                   returndatacopy(0, 0, returndatasize)
                   revert(0, returndatasize)
                }
            }

            let offset := 0
            let ptr
            let aZ

            let PRIME := 0x800000000000011000000000000000000000000000000000000000000000001

            for { } lt(offset, rowSize) { } {
                ptr := add(table, offset)
                aZ := 1
                let aX := mload(ptr)
                let aY := mload(add(ptr, 0x20))

                for { ptr := add(ptr, rowSize) } lt(ptr, tableEnd)
                    { ptr:= add(ptr, rowSize) } {

                    let bX := mload(ptr)
                    let bY := mload(add(ptr, 0x20))

                    let minusAZ := sub(PRIME, aZ)
                    let sN := addmod(aY, mulmod(minusAZ, bY, PRIME), PRIME)

                    let minusAZBX := mulmod(minusAZ, bX, PRIME)
                    let sD := addmod(aX, minusAZBX, PRIME)

                    let sSqrD := mulmod(sD, sD, PRIME)


                    let xN := addmod(mulmod(mulmod(sN, sN, PRIME), aZ, PRIME),
                                    mulmod(sSqrD,
                                            add(minusAZBX, sub(PRIME, aX)),
                                            PRIME),
                                    PRIME)

                    let xD := mulmod(sSqrD, aZ, PRIME)

                    aZ := mulmod(sD, xD, PRIME)
                    aY := addmod(sub(PRIME, mulmod(bY, aZ, PRIME)),
                                    mulmod(sN,
                                    add(sub(PRIME, xN),
                                        mulmod(xD, bX, PRIME)),
                                    PRIME),
                                PRIME)

                    aX := mulmod(xN, sD, PRIME)
                }

                offset := add(offset, 0x40)

                let expected_hash := shr(4, mload(add(proof, offset)))

                let other_node := and(  // right_node
                    mload(add(proof, add(offset, 0x1f))),
                    0x0fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff)

                if or(gt(expected_hash, primeMinusOne), gt(other_node, primeMinusOne)) {
                    raise_error("Value out of range.", 19)
                }

                if and(nodeSelectors, 1) {
                    expected_hash := other_node
                }

                if iszero(aZ) {
                   raise_error("aZ is zero.", 11)
                }

                if sub(aX, mulmod(expected_hash, aZ, PRIME))/*!=0*/ {
                   raise_error("Bad Merkle path.", 16)
                }
                nodeSelectors := shr(1, nodeSelectors)
            }

            mstore(0, starkKey)
            mstore(0x20,  tokenId)
            mstore(0x40,  // quantizedAmount
                   and(mload(add(proof, 0x5f)),
                       0x0fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff))
            mstore(0x60, shr(4, mload(add(proof, rowSize)))) // vaultRoot
            mstore(0x80, height)
            mstore(0xa0, vaultId)

            sstore(keccak256(0, 0xc0), 1)
        }
    }


    function isValid(bytes32 hash)
    external view returns(bool val)
    {
        assembly {
            val := sload(hash)
        }
    }
}
