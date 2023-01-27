

pragma solidity ^0.6.0;

abstract contract DataValidator {
    function validateSinglePixelData(
        uint256[] calldata pixelData
    ) external virtual pure returns (uint256 numberOfPixels);
    
    function validatePixelGroupData(
        uint256[] calldata pixelGroups,
        uint256[] calldata pixelGroupIndexes
    ) external virtual pure returns (uint256 numberOfPixels);
    
    function validateTransparentPixelGroupData(
        uint256[] calldata transparentPixelGroups,
        uint256[] calldata transparentPixelGroupIndexes,
        uint256[2] calldata metadata
    ) external virtual pure returns (uint256 numberOfPixels);
}


pragma solidity ^0.6.0;

library SafeMath {

    function add(uint256 a, uint256 b) internal pure returns (uint256) {

        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {

        return sub(a, b, "SafeMath: subtraction overflow");
    }

    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        require(b <= a, errorMessage);
        uint256 c = a - b;

        return c;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {

        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {

        return div(a, b, "SafeMath: division by zero");
    }

    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        require(b > 0, errorMessage);
        uint256 c = a / b;

        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {

        return mod(a, b, "SafeMath: modulo by zero");
    }

    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        require(b != 0, errorMessage);
        return a % b;
    }
}


pragma solidity ^0.6.0;



contract MurAllDataValidator is DataValidator {

    using SafeMath for uint256;
    uint256 constant MAX_PIXEL_RES = 2097152; // 2048 x 1024 pixels
    uint256 constant NUMBER_PER_GROUP = 32;
    uint256 constant MAX_NUM_OF_GROUPS = 65536; // 2097152 pixels / 32 pixels per group (max number in 2 bytes 0 - 65535)
    uint256 constant TRANSPARENT_PIXELS_THRESHOLD = 24; // 32 - 8; if 8 pixels or less then should be an individual group
    uint256 constant MAX_INDIVIDUAL_PIXEL_ARRAY_LENGTH = 262144; //Each slot in the data fits 8 px and 8 indexes (2097152 / 8)
    uint256 constant NUMBER_PER_INDIVIDUAL_PIXEL_GROUP = 8; // 8 individual pixels per uint256
    uint256 constant METADATA_HAS_ALPHA_CHANNEL_BYTES_MASK = 15;

    modifier onlyValidGroupData(uint256[] memory pixelGroups, uint256[] memory pixelGroupIndexes) {

        (uint256 quotient, uint256 remainder) = getDivided(pixelGroups.length, 16);

        if (remainder != 0) {
            quotient += 1; // e.g. when groupLen = 16, groupLen/16 = 1, we expect a group index length of 1 as 16 positions fit in 1 uint256
        }

        require(pixelGroupIndexes.length == quotient, "unexpected group index array length"); //Each group slot fits 16 coords of each 32 px group
        require(pixelGroups.length <= MAX_NUM_OF_GROUPS, "pixel groups too large");
        _;
    }

    modifier onlyValidSinglePixelData(uint256[] memory pixelData) {

        require(pixelData.length <= MAX_INDIVIDUAL_PIXEL_ARRAY_LENGTH, "pixelData too large");
        _;
    }

    function validateSinglePixelData(uint256[] memory pixelData)
        public
        override
        pure
        onlyValidSinglePixelData(pixelData)
        returns (uint256 numberOfPixels)
    {

        uint256 len = pixelData.length;

        if (len > 0) {
            numberOfPixels = NUMBER_PER_INDIVIDUAL_PIXEL_GROUP.mul(len).sub(
                checkIndividualPixelGroupForZeroes(pixelData[len - 1])
            );
        }
    }

    function validatePixelGroupData(uint256[] memory pixelGroups, uint256[] memory pixelGroupIndexes)
        public
        override
        pure
        onlyValidGroupData(pixelGroups, pixelGroupIndexes)
        returns (uint256 numberOfPixels)
    {

        if (pixelGroups.length > 0) {
            numberOfPixels = NUMBER_PER_GROUP.mul(pixelGroups.length); // 32 pixels per group
        }
    }

    function validateTransparentPixelGroupData(
        uint256[] memory transparentPixelGroups,
        uint256[] memory transparentPixelGroupIndexes,
        uint256[2] memory metadata
    )
        public
        override
        pure
        onlyValidGroupData(transparentPixelGroups, transparentPixelGroupIndexes)
        returns (uint256 numberOfPixels)
    {

        uint256 len = transparentPixelGroups.length;
        if (len > 0) {
            numberOfPixels = len.mul(NUMBER_PER_GROUP); // 32 pixels per group

            if (hasAlphaChannel(metadata[1])) {
                numberOfPixels = len.mul(NUMBER_PER_GROUP); // 32 pixels per group
                uint256 currentGroup;
                uint256 previousNumberOfPixels;

                for (uint256 i = 0; i < len; i++) {
                    previousNumberOfPixels = numberOfPixels;
                    assembly {
                        currentGroup := mload(add(add(transparentPixelGroups, 0x20), mul(i, 0x20)))

                        numberOfPixels := sub(
                            numberOfPixels,
                            iszero(
                                and(currentGroup, 0x00000000000000000000000000000000000000000000000000000000000000FF)
                            )
                        )
                        mstore(0x1F, currentGroup)
                        numberOfPixels := sub(
                            numberOfPixels,
                            iszero(and(mload(0), 0x00000000000000000000000000000000000000000000000000000000000000FF))
                        )

                        mstore(0x1E, currentGroup)
                        numberOfPixels := sub(
                            numberOfPixels,
                            iszero(and(mload(0), 0x00000000000000000000000000000000000000000000000000000000000000FF))
                        )

                        mstore(0x1D, currentGroup)
                        numberOfPixels := sub(
                            numberOfPixels,
                            iszero(and(mload(0), 0x00000000000000000000000000000000000000000000000000000000000000FF))
                        )

                        mstore(0x1C, currentGroup)
                        numberOfPixels := sub(
                            numberOfPixels,
                            iszero(and(mload(0), 0x00000000000000000000000000000000000000000000000000000000000000FF))
                        )

                        mstore(0x1B, currentGroup)
                        numberOfPixels := sub(
                            numberOfPixels,
                            iszero(and(mload(0), 0x00000000000000000000000000000000000000000000000000000000000000FF))
                        )

                        mstore(0x1A, currentGroup)
                        numberOfPixels := sub(
                            numberOfPixels,
                            iszero(and(mload(0), 0x00000000000000000000000000000000000000000000000000000000000000FF))
                        )

                        mstore(0x19, currentGroup)
                        numberOfPixels := sub(
                            numberOfPixels,
                            iszero(and(mload(0), 0x00000000000000000000000000000000000000000000000000000000000000FF))
                        )

                        mstore(0x18, currentGroup)
                        numberOfPixels := sub(
                            numberOfPixels,
                            iszero(and(mload(0), 0x00000000000000000000000000000000000000000000000000000000000000FF))
                        )

                        mstore(0x17, currentGroup)
                        numberOfPixels := sub(
                            numberOfPixels,
                            iszero(and(mload(0), 0x00000000000000000000000000000000000000000000000000000000000000FF))
                        )

                        mstore(0x16, currentGroup)
                        numberOfPixels := sub(
                            numberOfPixels,
                            iszero(and(mload(0), 0x00000000000000000000000000000000000000000000000000000000000000FF))
                        )

                        mstore(0x15, currentGroup)
                        numberOfPixels := sub(
                            numberOfPixels,
                            iszero(and(mload(0), 0x00000000000000000000000000000000000000000000000000000000000000FF))
                        )

                        mstore(0x14, currentGroup)
                        numberOfPixels := sub(
                            numberOfPixels,
                            iszero(and(mload(0), 0x00000000000000000000000000000000000000000000000000000000000000FF))
                        )

                        mstore(0x13, currentGroup)
                        numberOfPixels := sub(
                            numberOfPixels,
                            iszero(and(mload(0), 0x00000000000000000000000000000000000000000000000000000000000000FF))
                        )

                        mstore(0x12, currentGroup)
                        numberOfPixels := sub(
                            numberOfPixels,
                            iszero(and(mload(0), 0x00000000000000000000000000000000000000000000000000000000000000FF))
                        )

                        mstore(0x11, currentGroup)
                        numberOfPixels := sub(
                            numberOfPixels,
                            iszero(and(mload(0), 0x00000000000000000000000000000000000000000000000000000000000000FF))
                        )

                        mstore(0x10, currentGroup)
                        numberOfPixels := sub(
                            numberOfPixels,
                            iszero(and(mload(0), 0x00000000000000000000000000000000000000000000000000000000000000FF))
                        )

                        mstore(0x0F, currentGroup)
                        numberOfPixels := sub(
                            numberOfPixels,
                            iszero(and(mload(0), 0x00000000000000000000000000000000000000000000000000000000000000FF))
                        )

                        mstore(0x0E, currentGroup)
                        numberOfPixels := sub(
                            numberOfPixels,
                            iszero(and(mload(0), 0x00000000000000000000000000000000000000000000000000000000000000FF))
                        )

                        mstore(0x0D, currentGroup)
                        numberOfPixels := sub(
                            numberOfPixels,
                            iszero(and(mload(0), 0x00000000000000000000000000000000000000000000000000000000000000FF))
                        )

                        mstore(0x0C, currentGroup)
                        numberOfPixels := sub(
                            numberOfPixels,
                            iszero(and(mload(0), 0x00000000000000000000000000000000000000000000000000000000000000FF))
                        )

                        mstore(0x0B, currentGroup)
                        numberOfPixels := sub(
                            numberOfPixels,
                            iszero(and(mload(0), 0x00000000000000000000000000000000000000000000000000000000000000FF))
                        )

                        mstore(0x0A, currentGroup)
                        numberOfPixels := sub(
                            numberOfPixels,
                            iszero(and(mload(0), 0x00000000000000000000000000000000000000000000000000000000000000FF))
                        )

                        mstore(0x09, currentGroup)
                        numberOfPixels := sub(
                            numberOfPixels,
                            iszero(and(mload(0), 0x00000000000000000000000000000000000000000000000000000000000000FF))
                        )

                        mstore(0x08, currentGroup)
                        numberOfPixels := sub(
                            numberOfPixels,
                            iszero(and(mload(0), 0x00000000000000000000000000000000000000000000000000000000000000FF))
                        )

                        mstore(0x07, currentGroup)
                        numberOfPixels := sub(
                            numberOfPixels,
                            iszero(and(mload(0), 0x00000000000000000000000000000000000000000000000000000000000000FF))
                        )

                        mstore(0x06, currentGroup)
                        numberOfPixels := sub(
                            numberOfPixels,
                            iszero(and(mload(0), 0x00000000000000000000000000000000000000000000000000000000000000FF))
                        )

                        mstore(0x05, currentGroup)
                        numberOfPixels := sub(
                            numberOfPixels,
                            iszero(and(mload(0), 0x00000000000000000000000000000000000000000000000000000000000000FF))
                        )

                        mstore(0x04, currentGroup)
                        numberOfPixels := sub(
                            numberOfPixels,
                            iszero(and(mload(0), 0x00000000000000000000000000000000000000000000000000000000000000FF))
                        )

                        mstore(0x03, currentGroup)
                        numberOfPixels := sub(
                            numberOfPixels,
                            iszero(and(mload(0), 0x00000000000000000000000000000000000000000000000000000000000000FF))
                        )

                        mstore(0x02, currentGroup)
                        numberOfPixels := sub(
                            numberOfPixels,
                            iszero(and(mload(0), 0x00000000000000000000000000000000000000000000000000000000000000FF))
                        )

                        mstore(0x01, currentGroup)
                        numberOfPixels := sub(
                            numberOfPixels,
                            iszero(and(mload(0), 0x00000000000000000000000000000000000000000000000000000000000000FF))
                        )
                    }
                    require(
                        previousNumberOfPixels.sub(numberOfPixels) < TRANSPARENT_PIXELS_THRESHOLD,
                        "Misuse of transparency detected"
                    );
                }
            }
        }
    }

    function getDivided(uint256 numerator, uint256 denominator)
        internal
        pure
        returns (uint256 quotient, uint256 remainder)
    {

        quotient = numerator / denominator;
        remainder = numerator - denominator * quotient;
    }

    function hasAlphaChannel(uint256 metadata) internal pure returns (bool) {

        return (METADATA_HAS_ALPHA_CHANNEL_BYTES_MASK & metadata) != 0;
    }

    function checkIndividualPixelGroupForZeroes(uint256 toCheck) public pure returns (uint256 amountOfZeroes) {

        assembly {
            amountOfZeroes := add(
                amountOfZeroes,
                iszero(and(toCheck, 0x00000000000000000000000000000000000000000000000000000000FFFFFFFF))
            )

            mstore(0x1C, toCheck)
            amountOfZeroes := add(
                amountOfZeroes,
                iszero(and(mload(0), 0x00000000000000000000000000000000000000000000000000000000FFFFFFFF))
            )

            mstore(0x18, toCheck)
            amountOfZeroes := add(
                amountOfZeroes,
                iszero(and(mload(0), 0x00000000000000000000000000000000000000000000000000000000FFFFFFFF))
            )

            mstore(0x14, toCheck)
            amountOfZeroes := add(
                amountOfZeroes,
                iszero(and(mload(0), 0x00000000000000000000000000000000000000000000000000000000FFFFFFFF))
            )

            mstore(0x10, toCheck)
            amountOfZeroes := add(
                amountOfZeroes,
                iszero(and(mload(0), 0x00000000000000000000000000000000000000000000000000000000FFFFFFFF))
            )

            mstore(0x0C, toCheck)
            amountOfZeroes := add(
                amountOfZeroes,
                iszero(and(mload(0), 0x00000000000000000000000000000000000000000000000000000000FFFFFFFF))
            )

            mstore(0x08, toCheck)
            amountOfZeroes := add(
                amountOfZeroes,
                iszero(and(mload(0), 0x00000000000000000000000000000000000000000000000000000000FFFFFFFF))
            )

            mstore(0x04, toCheck)
            amountOfZeroes := add(
                amountOfZeroes,
                iszero(and(mload(0), 0x00000000000000000000000000000000000000000000000000000000FFFFFFFF))
            )
        }
    }
}