pragma solidity ^0.6.11;

interface IFactRegistry {

    function isValid(bytes32 fact)
        external view
        returns(bool);

}
pragma solidity ^0.6.11;


interface IQueryableFactRegistry is IFactRegistry {


    function hasRegisteredFact()
        external view
        returns(bool);


}
pragma solidity ^0.6.11;


contract FactRegistry is IQueryableFactRegistry {

    mapping (bytes32 => bool) private verifiedFact;

    bool anyFactRegistered;

    function isValid(bytes32 fact)
        external view override
        returns(bool)
    {

        return _factCheck(fact);
    }


    function _factCheck(bytes32 fact)
        internal view
        returns(bool)
    {

        return verifiedFact[fact];
    }

    function registerFact(
        bytes32 factHash
        )
        internal
    {

        verifiedFact[factHash] = true;

        if (!anyFactRegistered) {
            anyFactRegistered = true;
        }
    }

    function hasRegisteredFact()
        external view override
        returns(bool)
    {

        return anyFactRegistered;
    }

}
pragma solidity ^0.6.11;

contract PedersenMerkleVerifier {


    uint256 constant internal N_TABLES = 63;

    address[N_TABLES] lookupTables;
    constructor(address[N_TABLES] memory tables) public {
        lookupTables = tables;

        assembly {
            if gt(lookupTables_slot, 0) {
                revert(0, 0)
            }

        }
    }

    function verifyMerkle(uint256[] memory merkleProof) internal view {

        uint256 proofLength = merkleProof.length;

        require(proofLength >= 4, "Proof too short.");

        require(proofLength <= 402, "Proof too long.");

        require((proofLength & 1) == 0, "Proof length must be even.");

        uint256 height = (proofLength - 2) / 2; // NOLINT: divide-before-multiply.


        uint256 nodeIdx = merkleProof[proofLength - 1] >> 8;
        require(nodeIdx < 2**height, "nodeIdx not in tree.");
        require((nodeIdx & 1) == 0, "nodeIdx must be even.");

        uint256 rowSize = (2 * height) * 0x20;
        uint256[] memory proof = merkleProof;
        assembly {
            proof := add(proof, 0x20)

            function raise_error(message, msg_len) {

                mstore(0, 0x08c379a000000000000000000000000000000000000000000000000000000000)
                mstore(0x4, 0x20)
                mstore(0x24, msg_len)
                mstore(0x44, message)
                revert(0, add(0x44, msg_len))
            }

            let left_node := shr(4, mload(proof))
            let right_node := and(mload(add(proof, 0x1f)),
                               0x0fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff)

            let primeMinusOne := 0x800000000000011000000000000000000000000000000000000000000000000
            if or(gt(left_node, primeMinusOne), gt(right_node, primeMinusOne)) {
                raise_error("Bad starkKey or assetId.", 24)
            }

            let nodeSelectors := nodeIdx

            let table := mload(0x40)
            let tableEnd := add(table, mul(rowSize, /*N_TABLES*/63))

            for { let i := 0 } lt(i, 63) { i := add(i, 1)} {
                if iszero(staticcall(gas(), sload(i), add(proof, i), rowSize,
                                     add(table, mul(i, rowSize)), rowSize)) {
                   returndatacopy(0, 0, returndatasize())
                   revert(0, returndatasize())
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

                nodeSelectors := shr(1, nodeSelectors)
                if and(nodeSelectors, 1) {
                    expected_hash := other_node
                }

                if iszero(aZ) {
                   raise_error("aZ is zero.", 11)
                }

                if sub(aX, mulmod(expected_hash, aZ, PRIME))/*!=0*/ {
                   raise_error("Bad Merkle path.", 16)
                }
            }
        }
    }
}
pragma solidity ^0.6.11;

interface Identity {


    function identify()
        external pure
        returns(string memory);

}
pragma solidity ^0.6.11;

contract ProgramOutputOffsets {

    uint256 internal constant PROG_OUT_GENERAL_CONFIG_HASH = 0;
    uint256 internal constant PROG_OUT_N_ASSET_CONFIGS = 1;
    uint256 internal constant PROG_OUT_ASSET_CONFIG_HASHES = 2;

    uint256 internal constant PROG_OUT_N_WORDS_MIN_SIZE = 8;

    uint256 internal constant PROG_OUT_N_WORDS_PER_ASSET_CONFIG = 2;
    uint256 internal constant PROG_OUT_N_WORDS_PER_MODIFICATION = 3;

    uint256 internal constant ASSET_CONFIG_OFFSET_ASSET_ID = 0;
    uint256 internal constant ASSET_CONFIG_OFFSET_CONFIG_HASH = 1;

    uint256 internal constant MODIFICATIONS_OFFSET_STARKKEY = 0;
    uint256 internal constant MODIFICATIONS_OFFSET_POS_ID = 1;
    uint256 internal constant MODIFICATIONS_OFFSET_BIASED_DIFF = 2;

    uint256 internal constant STATE_OFFSET_VAULTS_ROOT = 0;
    uint256 internal constant STATE_OFFSET_VAULTS_HEIGHT = 1;
    uint256 internal constant STATE_OFFSET_ORDERS_ROOT = 2;
    uint256 internal constant STATE_OFFSET_ORDERS_HEIGHT = 3;
    uint256 internal constant STATE_OFFSET_N_FUNDING = 4;
    uint256 internal constant STATE_OFFSET_FUNDING = 5;

    uint256 internal constant APP_DATA_BATCH_ID_OFFSET = 0;
    uint256 internal constant APP_DATA_PREVIOUS_BATCH_ID_OFFSET = 1;
    uint256 internal constant APP_DATA_N_CONDITIONAL_TRANSFER = 2;
    uint256 internal constant APP_DATA_CONDITIONAL_TRANSFER_DATA_OFFSET = 3;
    uint256 internal constant APP_DATA_N_WORDS_PER_CONDITIONAL_TRANSFER = 2;
}
pragma solidity ^0.6.11;


contract PerpetualEscapeVerifier is
    PedersenMerkleVerifier, FactRegistry,
    Identity, ProgramOutputOffsets {

    event LogEscapeVerified(
        uint256 publicKey,
        int256 withdrawalAmount,
        bytes32 sharedStateHash,
        uint256 positionId
    );

    uint256 internal constant N_ASSETS_BITS = 16;
    uint256 internal constant BALANCE_BITS = 64;
    uint256 internal constant FUNDING_BITS = 64;
    uint256 internal constant BALANCE_BIAS = 2**63;
    uint256 internal constant FXP_BITS = 32;

    uint256 internal constant FUNDING_ENTRY_SIZE = 2;
    uint256 internal constant PRICE_ENTRY_SIZE = 2;

    constructor(address[N_TABLES] memory tables)
        PedersenMerkleVerifier(tables)
        public
    {
    }

    function identify()
        external pure override virtual
        returns(string memory)
    {

        return "StarkWare_PerpetualEscapeVerifier_2021_2";
    }

    function findAssetId(
        uint256 assetId, uint256[] memory array, uint256 startIdx, uint256 endIdx)
        internal pure returns (uint256 idx) {

        idx = startIdx;
        while(array[idx] != assetId) {
            idx += /*entry_size*/2;
            require(idx < endIdx, "assetId not found.");
        }
    }


    function computeFxpBalance(
        uint256[] memory position, uint256[] memory sharedState)
        internal pure returns (int256) {


        uint256 nAssets;
        uint256 fxpBalance;

        {
            uint256 lastWord = position[position.length - 1];
            nAssets = lastWord & ((1 << N_ASSETS_BITS) - 1);
            uint256 biasedBalance = lastWord >> N_ASSETS_BITS;

            require(position.length == nAssets + 2, "Bad number of assets.");
            require(biasedBalance < 2**BALANCE_BITS, "Bad balance.");

            fxpBalance = (biasedBalance - BALANCE_BIAS) << FXP_BITS;
        }

        uint256 fundingIndicesOffset = STATE_OFFSET_FUNDING;
        uint256 nFundingIndices = sharedState[fundingIndicesOffset - 1];

        uint256 fundingEnd = fundingIndicesOffset + FUNDING_ENTRY_SIZE * nFundingIndices;

        uint256 pricesOffset = fundingEnd + 2;
        uint256 nPrices = sharedState[pricesOffset - 1];
        uint256 pricesEnd = pricesOffset + PRICE_ENTRY_SIZE * nPrices;
        uint256[] memory sharedStateCopy = sharedState;

        uint256 fundingTotal = 0;
        for (uint256 i = 0; i < nAssets; i++) {
            uint256 positionAsset = position[i];
            uint256 assedId = positionAsset >> 128;

            uint256 cachedFunding = (positionAsset >> BALANCE_BITS) & (2**FUNDING_BITS - 1);
            uint256 assetBalance = (positionAsset & (2**BALANCE_BITS - 1)) - BALANCE_BIAS;

            fundingIndicesOffset = findAssetId(
                assedId, sharedStateCopy, fundingIndicesOffset, fundingEnd);
            fundingTotal -= assetBalance *
                (sharedStateCopy[fundingIndicesOffset + 1] - cachedFunding);

            pricesOffset = findAssetId(assedId, sharedStateCopy, pricesOffset, pricesEnd);
            fxpBalance += assetBalance * sharedStateCopy[pricesOffset + 1];
        }

        uint256 truncatedFunding = fundingTotal & ~(2**FXP_BITS - 1);
        return int256(fxpBalance + truncatedFunding);
    }


    function extractPosition(uint256[] memory merkleProof, uint256 nAssets)
        internal pure
        returns (uint256 positionId, uint256[] memory position) {


        require((merkleProof[0] >> 8) == 0, 'Position hash-chain must start with 0.');

        uint256 positionLength = nAssets + 2;
        position = new uint256[](positionLength);
        uint256 nodeIdx = merkleProof[merkleProof.length - 1] >> 8;

        require(
            (nodeIdx & ((1 << positionLength) - 1)) == 0,
            "merkleProof is inconsistent with nAssets.");
        positionId = nodeIdx >> positionLength;

        assembly {
            let positionPtr := add(position, 0x20)
            let positionEnd := add(positionPtr, mul(mload(position), 0x20))
            let proofPtr := add(merkleProof, 0x3f)

            for { } lt(positionPtr, positionEnd)  { positionPtr := add(positionPtr, 0x20) } {
                mstore(positionPtr, and(mload(proofPtr),
                       0x0fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff))
                proofPtr := add(proofPtr, 0x40)
            }
        }
    }


    function verifyEscape(
        uint256[] calldata merkleProof, uint256 nAssets, uint256[] calldata sharedState) external {
        (uint256 positionId, uint256[] memory position) = extractPosition(merkleProof, nAssets);

        int256 withdrawalAmount = computeFxpBalance(position, sharedState) >> FXP_BITS;

        uint256 nHashes = (merkleProof.length - 2) / 2; // NOLINT: divide-before-multiply.
        uint256 positionTreeHeight = nHashes - position.length;

        require(
            sharedState[STATE_OFFSET_VAULTS_ROOT] == (merkleProof[merkleProof.length - 2] >> 4),
            "merkleProof is inconsistent with the root in the sharedState.");

        require(
            sharedState[STATE_OFFSET_VAULTS_HEIGHT] == positionTreeHeight,
            "merkleProof is inconsistent with the height in the sharedState.");

        require(withdrawalAmount > 0, "Withdrawal amount must be positive.");
        bytes32 sharedStateHash = keccak256(abi.encodePacked(sharedState));

        uint256 publicKey = position[nAssets];
        emit LogEscapeVerified(publicKey, withdrawalAmount, sharedStateHash, positionId);
        bytes32 fact = keccak256(
            abi.encodePacked(
            publicKey, withdrawalAmount, sharedStateHash, positionId));

        verifyMerkle(merkleProof);

        registerFact(fact);
    }
}
