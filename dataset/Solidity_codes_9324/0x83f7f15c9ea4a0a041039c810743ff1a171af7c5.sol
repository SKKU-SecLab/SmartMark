
pragma solidity >=0.5.6 <0.6.0;






interface ERC165Interface {

    function supportsInterface(bytes4 interfaceId) external view returns (bool);

}


contract DuelResolverInterfaceId {

    bytes4 internal constant _INTERFACE_ID_DUELRESOLVER = 0x41fc4f1e;
}

contract DuelResolverInterface is DuelResolverInterfaceId, ERC165Interface {

    function isValidMoveSet(bytes32 moveSet) public pure returns(bool);


    function isValidAffinity(uint256 affinity) external pure returns(bool);


    function resolveDuel(
        bytes32 moveSet1,
        bytes32 moveSet2,
        uint256 power1,
        uint256 power2,
        uint256 affinity1,
        uint256 affinity2)
        public pure returns(int256);

}



contract ThreeAffinityDuelResolver is DuelResolverInterface {

    bytes32 public constant MOVE_MASK = 0x0303030303000000000000000000000000000000000000000000000000000000;

    uint256 public constant MOVE_DELTA = 0x0202020202000000000000000000000000000000000000000000000000000000;

    uint256 public constant WEIGHT_SUM = 78 + 79 + 81 + 86 + 100;

    function supportsInterface(bytes4 interfaceId) external view returns (bool) {

        return
            interfaceId == this.supportsInterface.selector || // ERC165
            interfaceId == _INTERFACE_ID_DUELRESOLVER; // DuelResolverInterface
    }

    function isValidMoveSet(bytes32 moveSet) public pure returns(bool) { // solium-disable-line security/no-assign-params

        moveSet = bytes32(uint256(moveSet) - MOVE_DELTA);

        if (moveSet != (moveSet & MOVE_MASK)) {
            return false;
        }

        if ((moveSet & (moveSet << 1)) != bytes32(0)) {
            return false;
        }

        return true;
    }

    function isValidAffinity(uint256) public pure returns(bool) {

        return true;
    }

    function resolveDuel(
        bytes32 moveSet1,
        bytes32 moveSet2,
        uint256 power1,
        uint256 power2,
        uint256 affinity1,
        uint256 affinity2)
        public pure returns(int256 power)
    {

        require(isValidMoveSet(moveSet1) && isValidMoveSet(moveSet2), "Invalid moveset");

        int256 score = _duelScore(moveSet1, moveSet2, affinity1, affinity2);
        power = _powerTransfer(score, power1, power2);
    }

    function _duelScore(bytes32 moveSet1, bytes32 moveSet2, uint256 affinity1, uint256 affinity2) internal pure returns (int256 score) {

        int256[5] memory weights = [int256(78), int256(79), int256(81), int256(86), int256(100)];

        moveSet1 = bytes32(uint256(moveSet1) - MOVE_DELTA);
        moveSet2 = bytes32(uint256(moveSet2) - MOVE_DELTA);
        affinity1 -= 2;
        affinity2 -= 2;

        for (uint256 i = 0; i < 5; i++) {
            int256 move1 = int256(uint8(moveSet1[i]));
            int256 move2 = int256(uint8(moveSet2[i]));
            int256 diff = move1 - move2;

            if (diff == 0) {
                continue;
            }

            if (diff*diff == 4) {
                diff = -(diff >> 1);
            }

            diff *= 100;

            if (move1 == int256(affinity1)) {
                diff = diff * 130 / 100;
            }

            if (move2 == int256(affinity2)) {
                diff = diff * 130 / 100;
            }

            score += diff * weights[i];
        }

        score /= 100;
    }

    function _powerTransfer(int256 score, uint256 power1, uint256 power2) private pure returns(int256) {

        if (score < 0) {
            return -_powerTransfer(-score, power2, power1);
        }

        require((power1 < (1<<245)) && power2 < (1<<245), "Invalid power value");

        require(power1 > 0 && power2 > 0, "Invalid power value");

        if (score == 0) {
            return 0;
        }


        uint256 normalizedScoreQ10 = 1024 * uint256(score) / WEIGHT_SUM;

        if (normalizedScoreQ10 > 1024) {
            normalizedScoreQ10 = 1024;
        }

        uint256 baseTransferRatioQ10 = _fakePowQ10(normalizedScoreQ10, 1024 * 1/2);


        if (power2 > power1 * 7) {
            power2 = power1 * 7;
        } else if (power1 > power2 * 7) {
            power1 = power2 * 7;
        }

        uint256 transferRatioQ10 = _fakePowQ10(baseTransferRatioQ10, 1024 * power2 / power1);

        return int256((power2 * transferRatioQ10) >> 10);
    }

    function _fakePowQ10(uint256 xQ10, uint256 yQ10) private pure returns(uint256) {


        uint256 yQ6 = (yQ10 + 8) >> 4;

        return _fakePowInternal(xQ10, yQ6, 64, 5);
    }


    function _fakePowInternal(uint256 xQ10, uint256 numerator, uint256 denominator, uint256 iterations) private pure returns (uint256) {

        uint256 resultQ10 = 1024;

        uint256 integerExponent = numerator / denominator;

        while (integerExponent >= 22) {
            resultQ10 *= xQ10 ** 22;
            resultQ10 >>= 220; // back out the 22 extra multiples of 1024
            integerExponent -= 22;
        }

        if (integerExponent > 0) {
            resultQ10 *= xQ10 ** integerExponent;
            resultQ10 >>= (integerExponent * 10);
        }

        uint256 fractionalExponent = numerator % denominator;

        if ((iterations == 0) || (fractionalExponent == 0)) {
            return resultQ10;
        }

        resultQ10 *= (1024 - _fakePowInternal(1024 - xQ10, denominator, fractionalExponent, iterations - 1));

        return resultQ10 >> 10;
    }
}