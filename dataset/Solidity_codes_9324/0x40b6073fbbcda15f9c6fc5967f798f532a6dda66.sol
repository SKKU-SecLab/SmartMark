
pragma solidity >=0.8.0;

library DynamicBuffer {

    function allocate(uint256 capacity)
        internal
        pure
        returns (bytes memory buffer)
    {

        assembly {
            let container := mload(0x40)

            {
                let size := add(capacity, 0x60)
                let newNextFree := add(container, size)
                mstore(0x40, newNextFree)
            }

            {
                let length := add(capacity, 0x40)
                mstore(container, length)
            }

            buffer := add(container, 0x20)

            mstore(buffer, 0)
        }

        return buffer;
    }

    function appendUnchecked(bytes memory buffer, bytes memory data)
        internal
        pure
    {

        assembly {
            let length := mload(data)
            for {
                data := add(data, 0x20)
                let dataEnd := add(data, length)
                let copyTo := add(buffer, add(mload(buffer), 0x20))
            } lt(data, dataEnd) {
                data := add(data, 0x20)
                copyTo := add(copyTo, 0x20)
            } {
                mstore(copyTo, mload(data))
            }

            mstore(buffer, add(mload(buffer), length))
        }
    }

    function appendSafe(bytes memory buffer, bytes memory data) internal pure {

        uint256 capacity;
        uint256 length;
        assembly {
            capacity := sub(mload(sub(buffer, 0x20)), 0x40)
            length := mload(buffer)
        }

        require(
            length + data.length <= capacity,
            "DynamicBuffer: Appending out of bounds."
        );
        appendUnchecked(buffer, data);
    }
}// MIT

pragma solidity ^0.8.0;

library Strings {

    bytes16 private constant _HEX_SYMBOLS = "0123456789abcdef";

    function toString(uint256 value) internal pure returns (string memory) {


        if (value == 0) {
            return "0";
        }
        uint256 temp = value;
        uint256 digits;
        while (temp != 0) {
            digits++;
            temp /= 10;
        }
        bytes memory buffer = new bytes(digits);
        while (value != 0) {
            digits -= 1;
            buffer[digits] = bytes1(uint8(48 + uint256(value % 10)));
            value /= 10;
        }
        return string(buffer);
    }

    function toHexString(uint256 value) internal pure returns (string memory) {

        if (value == 0) {
            return "0x00";
        }
        uint256 temp = value;
        uint256 length = 0;
        while (temp != 0) {
            length++;
            temp >>= 8;
        }
        return toHexString(value, length);
    }

    function toHexString(uint256 value, uint256 length) internal pure returns (string memory) {

        bytes memory buffer = new bytes(2 * length + 2);
        buffer[0] = "0";
        buffer[1] = "x";
        for (uint256 i = 2 * length + 1; i > 1; --i) {
            buffer[i] = _HEX_SYMBOLS[value & 0xf];
            value >>= 4;
        }
        require(value == 0, "Strings: hex length insufficient");
        return string(buffer);
    }
}// UNLICENSED
pragma solidity >=0.8.8 <0.9.0;

uint8 constant NUM_BACKGROUNDS = 13;
uint8 constant NUM_BODIES = 36;
uint8 constant NUM_MOUTHS = 35;
uint8 constant NUM_EYES = 45;

enum Special {
    None,
    Devil,
    Angel,
    Both
}

struct Features {
    uint8 background;
    uint8 body;
    uint8 mouth;
    uint8 eyes;
    Special special;
    bool golden;
}

type FeaturesSerialized is bytes32;// UNLICENSED
pragma solidity >=0.8.8 <0.9.0;


library Serializer {

    function serialize(Features memory features)
        internal
        pure
        returns (FeaturesSerialized)
    {

        unchecked {
            uint48 packed;
            packed += features.background;
            packed <<= 8;
            packed += features.body;
            packed <<= 8;
            packed += features.mouth;
            packed <<= 8;
            packed += features.eyes;
            packed <<= 8;
            packed += uint8(features.special);
            packed <<= 8;
            packed += features.golden ? 1 : 0;
            return FeaturesSerialized.wrap(bytes32(uint256(packed)));
        }
    }

    function hash(Features memory features) internal pure returns (bytes32) {

        return bytes32(FeaturesSerialized.unwrap(serialize(features)));
    }
}

library Deserializer {

    function deserialize(FeaturesSerialized data_)
        internal
        pure
        returns (Features memory)
    {

        unchecked {
            Features memory feats;
            uint256 data = _toUint256(data_);
            feats.golden = uint8(data) == 1;
            data >>= 8;
            feats.special = Special(uint8(data));
            data >>= 8;
            feats.eyes = uint8(data);
            data >>= 8;
            feats.mouth = uint8(data);
            data >>= 8;
            feats.body = uint8(data);
            data >>= 8;
            feats.background = uint8(data);
            return feats;
        }
    }

    function isSet(FeaturesSerialized data) internal pure returns (bool) {

        return FeaturesSerialized.unwrap(data) != 0;
    }

    function _toUint256(FeaturesSerialized data)
        private
        pure
        returns (uint256)
    {

        return uint256(FeaturesSerialized.unwrap(data));
    }

    function hash(FeaturesSerialized features) internal pure returns (bytes32) {

        return FeaturesSerialized.unwrap(features);
    }
}// UNLICENSED
pragma solidity >=0.8.0 <0.9.0;



library FeaturesHelper {

    using Serializer for Features;
    using Deserializer for FeaturesSerialized;

    function generateRandomFeatures(uint256 tokenId, bytes32 entropy)
        internal
        pure
        returns (Features memory)
    {

        unchecked {
            Features memory features;
            uint256 rand = uint256(
                keccak256(abi.encode(entropy ^ bytes32(tokenId)))
            );

            uint8 body = uint8((uint64(rand) % (NUM_BODIES - 1)) + 1);
            if (body >= 2) {
                body += 1;
            }

            features.body = body;
            rand >>= 64;
            features.mouth = uint8((uint64(rand) % NUM_MOUTHS) + 1);
            rand >>= 64;
            features.eyes = uint8((uint64(rand) % NUM_EYES) + 1);

            features.background = 13;
            features.special = Special.None;
            features.golden = (tokenId == 0);
            return features;
        }
    }

    function tokenFeatures(
        uint256 tokenId,
        FeaturesSerialized data,
        bytes32 entropy
    ) internal pure returns (FeaturesSerialized, bool) {

        if (entropy == 0 && !data.isSet()) {
            return (FeaturesSerialized.wrap(bytes32(0)), false);
        }

        if (entropy > 0 && !data.isSet()) {
            return (generateRandomFeatures(tokenId, entropy).serialize(), true);
        }

        return (data, true);
    }

    function countTokensWithFeatures(
        FeaturesSerialized features,
        bytes32 entropy,
        FeaturesSerialized[] memory allData
    ) internal pure returns (uint256) {

        uint256 numTokens = allData.length;
        bytes32 tokenHash = features.hash();
        uint256 numIdentical = 0;

        for (uint256 idx = 0; idx < numTokens; ++idx) {
            (
                FeaturesSerialized sibling,
                bool isSiblingRevealed
            ) = tokenFeatures(idx, allData[idx], entropy);

            if (!isSiblingRevealed) continue;
            if (tokenHash == sibling.hash()) ++numIdentical;
        }

        return numIdentical;
    }

    function computeEntropy(FeaturesSerialized[] memory data)
        internal
        pure
        returns (bytes32)
    {

        return keccak256(abi.encode(data));
    }
}// UNLICENSED
pragma solidity >=0.8.8 <0.9.0;


interface IMetadataRenderer {

    function tokenFeatures(
        uint256 tokenId,
        FeaturesSerialized data,
        FeaturesSerialized[] memory allData,
        bool autogenerate
    ) external view returns (Features memory, bool);


    function tokenURI(
        uint256 tokenId,
        FeaturesSerialized data,
        string memory baseURI,
        FeaturesSerialized[] memory allData,
        bool autogenerate,
        bool countSiblings
    ) external view returns (string memory);

}// UNLICENSED
pragma solidity >=0.8.0 <0.9.0;



library JSONEncoder {

    using DynamicBuffer for bytes;

    bytes private constant DESCRIPTION =
        "My Imaginary Friend is a collection of 3000 Imaginary Friend (IF) NFTs released by Kai, the internationally renowned artist who is known for his themes that include time, money and love. This collection combines Kai's passion for art and new mediums across the NFT community.";

    function init(uint256 tokenId) internal pure returns (bytes memory) {

        bytes memory uri = DynamicBuffer.allocate(1 << 12);

        uri.appendSafe('data:application/json;utf-8,{"name":"');
        uri.appendSafe(_tokenName(tokenId));
        uri.appendUnchecked('","description":"');
        uri.appendSafe(DESCRIPTION);
        uri.appendSafe('"');
        return uri;
    }

    function addAttributes(
        bytes memory uri,
        Features memory features,
        uint256 numIdentical
    ) internal pure {
        uri.appendSafe(', "attributes":[');
        uri.appendSafe(
            _traitStringNoComma(
                "Background",
                Strings.toString(features.background)
            )
        );
        uri.appendSafe(_traitString("Body", _getBodyTraitStr(features.body)));
        uri.appendSafe(
            _traitString("Mouth", _getMouthTraitStr(features.mouth))
        );
        uri.appendSafe(_traitString("Eyes", _getEyesTraitStr(features.eyes)));
        if (numIdentical > 1) {
            if (numIdentical == 2) {
                uri.appendSafe(_traitString("Twin"));
            }
            if (numIdentical == 3) {
                uri.appendSafe(_traitString("Triplet"));
            }
            if (numIdentical > 3) {
                uri.appendSafe(
                    _traitString("Multiplet", Strings.toString(numIdentical))
                );
            }
        }
        if (
            features.special == Special.Angel ||
            features.special == Special.Both
        ) {
            uri.appendSafe(_traitString("Angel"));
        }
        if (
            features.special == Special.Devil ||
            features.special == Special.Both
        ) {
            uri.appendSafe(_traitString("Devil"));
        }
        if (features.golden) {
            uri.appendSafe(_traitString("Golden"));
        }
        uri.appendSafe("]");
    }

    function addImageUrl(
        bytes memory uri,
        string memory baseUrl,
        uint256 tokenId
    ) internal pure {
        uri.appendSafe(', "image": "');
        uri.appendSafe(bytes(baseUrl));
        uri.appendSafe("/");
        uri.appendSafe(bytes(Strings.toString(tokenId)));
        uri.appendSafe('"');
    }

    function finalize(bytes memory uri) internal pure {
        uri.appendSafe("}");
    }

    function _tokenName(uint256 tokenId) private pure returns (bytes memory) {

        return
            abi.encodePacked("Imaginary Friend %23", Strings.toString(tokenId));
    }

    function _traitStringNoComma(bytes memory name, string memory value)
        private
        pure
        returns (bytes memory)
    {

        return
            abi.encodePacked(
                '{"trait_type": "',
                name,
                '", "value":"',
                value,
                '"}'
            );
    }

    function _traitString(bytes memory name, string memory value)
        private
        pure
        returns (bytes memory)
    {

        return abi.encodePacked(",", _traitStringNoComma(name, value));
    }

    function _traitString(string memory value)
        private
        pure
        returns (bytes memory)
    {

        return abi.encodePacked(',{"value":"', value, '"}');
    }

    function _getBodyTraitStr(uint8 id) private pure returns (string memory) {

        return
            [
                "", // Skip 0, since we are 1 indexed
                "Special 1",
                "Special 2",
                "Special 3",
                "Big Heart",
                "Big Broken Heart",
                "Balloon",
                "Bunch of Hearts",
                "Winged Heart",
                "Brick of Bills",
                "Gold Brick",
                "Coins and Bills",
                "Diamond",
                "Pirates Treasure",
                "Bag of Money",
                "Cement Spreader",
                "Hammer",
                "Garden Shovel",
                "Welder",
                "Flower",
                "Earth",
                "Plant",
                "Watering Can",
                "Light Bulb",
                "Book",
                "Stacked Books",
                "Clock",
                "Hourglass",
                "Skull",
                "Pocket Watch",
                "Video Camera",
                "Film Camera",
                "Painter",
                "Guitar",
                "Camera",
                "Paper and Pencil",
                "Paint Roller and Can"
            ][id];
    }

    function _getMouthTraitStr(uint8 id) private pure returns (string memory) {

        uint8[4] memory nums = [10, 10, 10, 5];
        string[4] memory names = ["Happy", "Sad", "Mad", "Special"];

        for (uint256 idx = 0; idx < 4; ++idx) {
            if (id <= nums[idx]) {
                return
                    string(
                        abi.encodePacked(names[idx], " ", Strings.toString(id))
                    );
            }
            id -= nums[idx];
        }
        return "";
    }

    function _getEyesTraitStr(uint8 id) private pure returns (string memory) {

        uint8[6] memory nums = [9, 8, 8, 8, 8, 4];
        string[6] memory names = [
            "Happy",
            "Sad",
            "Mad",
            "Annoyed",
            "Lost and Confused",
            "Special"
        ];

        for (uint256 idx = 0; idx < 6; ++idx) {
            if (id <= nums[idx]) {
                return
                    string(
                        abi.encodePacked(names[idx], " ", Strings.toString(id))
                    );
            }
            id -= nums[idx];
        }
        return "";
    }
}

pragma solidity >=0.8.0 <0.9.0;



contract ImaginaryFriendMetadataRenderer is IMetadataRenderer {

    using JSONEncoder for bytes;
    using Serializer for Features;
    using Deserializer for FeaturesSerialized;

    function tokenFeatures(
        uint256 tokenId,
        FeaturesSerialized data,
        FeaturesSerialized[] memory allData,
        bool autogenerate
    ) external pure override returns (Features memory, bool) {

        bytes32 entropy = autogenerate
            ? FeaturesHelper.computeEntropy(allData)
            : bytes32(0);
        return _tokenFeatures(tokenId, data, entropy);
    }

    function tokenURI(
        uint256 tokenId,
        FeaturesSerialized data,
        string memory baseURI,
        FeaturesSerialized[] memory allData,
        bool autogenerate,
        bool countSiblings
    ) external pure override returns (string memory) {

        bytes32 entropy = autogenerate
            ? FeaturesHelper.computeEntropy(allData)
            : bytes32(0);
        return
            _tokenURI(tokenId, data, baseURI, entropy, allData, countSiblings);
    }


    function _tokenFeatures(
        uint256 tokenId,
        FeaturesSerialized data,
        bytes32 entropy
    ) internal pure returns (Features memory, bool) {

        (FeaturesSerialized features, bool isRevealed) = FeaturesHelper
            .tokenFeatures(tokenId, data, entropy);
        return (features.deserialize(), isRevealed);
    }

    function _tokenURI(
        uint256 tokenId,
        FeaturesSerialized data,
        string memory baseURI,
        bytes32 entropy,
        FeaturesSerialized[] memory allData,
        bool countSiblings
    ) internal pure returns (string memory) {

        (FeaturesSerialized features, bool isRevealed) = FeaturesHelper
            .tokenFeatures(tokenId, data, entropy);

        bytes memory uri = JSONEncoder.init(tokenId);

        if (isRevealed) {
            uint256 numIdentical = countSiblings
                ? FeaturesHelper.countTokensWithFeatures(
                    features,
                    entropy,
                    allData
                )
                : 0;
            uri.addAttributes(features.deserialize(), numIdentical);
        }

        uri.addImageUrl(baseURI, tokenId);
        uri.finalize();
        return string(uri);
    }
}