pragma solidity 0.7.5;


library HeaderRLP {

    function checkBlockHash(bytes calldata rlp) external view returns (uint256) {

        uint256 rlpBlockNumber = getBlockNumber(rlp);

        require(
            blockhash(rlpBlockNumber) == keccak256(rlp), // blockhash() costs 20 now but it may cost 5000 in the future
            "HeaderRLP.checkBlockHash: Block hashes don't match"
        );
        return rlpBlockNumber;
    }

    function nextElementJump(uint8 prefix) public pure returns (uint8) {

        if (prefix <= 128) {
            return 1;
        } else if (prefix <= 183) {
            return prefix - 128 + 1;
        }
        revert("HeaderRLP.nextElementJump: Given element length not implemented");
    }

    function getBlockNumberPositionNoLoop(bytes memory rlp) public pure returns (uint256) {

        uint256 pos;
        pos = 448;
        pos += nextElementJump(uint8(rlp[pos]));

        return pos;
    }

    function getGasLimitPositionNoLoop(bytes memory rlp) public pure returns (uint256) {

        uint256 pos;
        pos = 448;
        pos += nextElementJump(uint8(rlp[pos]));
        pos += nextElementJump(uint8(rlp[pos]));

        return pos;
    }

    function getTimestampPositionNoLoop(bytes memory rlp) public pure returns (uint256) {

        uint256 pos;
        pos = 448;
        pos += nextElementJump(uint8(rlp[pos]));
        pos += nextElementJump(uint8(rlp[pos]));
        pos += nextElementJump(uint8(rlp[pos]));
        pos += nextElementJump(uint8(rlp[pos]));

        return pos;
    }

    function getBaseFeePositionNoLoop(bytes memory rlp) public pure returns (uint256) {

        uint256 pos = 448;

        pos += nextElementJump(uint8(rlp[pos]));
        pos += nextElementJump(uint8(rlp[pos]));
        pos += nextElementJump(uint8(rlp[pos]));
        pos += nextElementJump(uint8(rlp[pos]));
        pos += nextElementJump(uint8(rlp[pos]));
        pos += nextElementJump(uint8(rlp[pos]));
        pos += nextElementJump(uint8(rlp[pos]));
        pos += nextElementJump(uint8(rlp[pos]));

        return pos;
    }

    function extractFromRLP(bytes calldata rlp, uint256 elementPosition) public pure returns (uint256 element) {

        if (uint8(rlp[elementPosition]) < 128) {
            return uint256(uint8(rlp[elementPosition]));
        }

        uint8 elementSize = uint8(rlp[elementPosition]) - 128;


        assembly {
            calldatacopy(
                add(mload(0x40), sub(32, elementSize)), // Copy to: Memory 0x40 (free memory pointer) + 32bytes (uint256 size) - length of our element (in bytes)
                add(0x44, add(elementPosition, 1)), // Copy from: Calldata 0x44 (RLP raw data offset) + elementPosition + 1 byte for the size of element
                elementSize
            )
            element := mload(mload(0x40)) // Load the 32 bytes (uint256) stored at memory 0x40 pointer - into return value
        }
        return element;
    }

    function getBlockNumber(bytes calldata rlp) public pure returns (uint256 bn) {

        return extractFromRLP(rlp, getBlockNumberPositionNoLoop(rlp));
    }

    function getTimestamp(bytes calldata rlp) external pure returns (uint256 ts) {

        return extractFromRLP(rlp, getTimestampPositionNoLoop(rlp));
    }

    function getDifficulty(bytes calldata rlp) external pure returns (uint256 diff) {

        return extractFromRLP(rlp, 448);
    }

    function getGasLimit(bytes calldata rlp) external pure returns (uint256 gasLimit) {

        return extractFromRLP(rlp, getGasLimitPositionNoLoop(rlp));
    }

    function getBaseFee(bytes calldata rlp) external pure returns (uint256 baseFee) {

        return extractFromRLP(rlp, getBaseFeePositionNoLoop(rlp));
    }
}