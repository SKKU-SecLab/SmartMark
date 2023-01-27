
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
}//Unlicense
pragma solidity ^0.8.6;


library StringLib {

    bytes16 private constant _HEX_SYMBOLS = '0123456789abcdef';

    function toBalanceString(uint256 balance, uint256 decimals)
        internal
        pure
        returns (string memory)
    {

        return
            string(
                abi.encodePacked(
                    StringLib.toString(balance / 1e18),
                    '.',
                    StringLib.toFixedLengthString(
                        (balance % 1e18) / (10**(18 - decimals)),
                        decimals
                    )
                )
            );
    }

    function toFixedLengthString(uint256 value, uint256 digits)
        internal
        pure
        returns (string memory)
    {

        require(value <= 10**digits, 'Value cannot be in digits');

        bytes memory buffer = new bytes(digits);
        for (uint8 i = 0; i < digits; i++) {
            buffer[digits - 1 - i] = bytes1(uint8(48 + uint256(value % 10)));
            value /= 10;
        }

        return string(buffer);
    }

    function toString(uint256 value) internal pure returns (string memory) {

        return Strings.toString(value);
    }

    function toHex(uint256 value) internal pure returns (string memory) {

        return Strings.toHexString(value);
    }

    function toHex(uint256 value, uint256 length) internal pure returns (string memory) {

        return Strings.toHexString(value, length);
    }


    function toHexColor(uint256 value) internal pure returns (string memory) {

        bytes memory buffer = new bytes(8);
        buffer[0] = _HEX_SYMBOLS[(value >> 28) & 0xf];
        buffer[1] = _HEX_SYMBOLS[(value >> 24) & 0xf];
        buffer[2] = _HEX_SYMBOLS[(value >> 20) & 0xf];
        buffer[3] = _HEX_SYMBOLS[(value >> 16) & 0xf];
        buffer[4] = _HEX_SYMBOLS[(value >> 12) & 0xf];
        buffer[5] = _HEX_SYMBOLS[(value >> 8) & 0xf];
        buffer[6] = _HEX_SYMBOLS[(value >> 4) & 0xf];
        buffer[7] = _HEX_SYMBOLS[(value) & 0xf];
        return string(buffer);
    }
}//Unlicense
pragma solidity ^0.8.6;



library ColorLib {

    uint256 internal constant COLOR_MASK = 0xFFFFFFFF;

    function createPaletteFromColorList(uint256[] memory _colors)
        internal
        pure
        returns (uint256[] memory)
    {

        uint256 subCount = _colors.length % 8 > 0 ? _colors.length / 8 + 1 : _colors.length / 8;
        uint256[] memory palette = new uint256[](subCount);
        for (uint8 i = 0; i < subCount; i++) {
            uint256 available = _min(_colors.length - i * 8, 8);
            uint256[] memory subList = new uint256[](available);
            for (uint8 j = 0; j < available; j++) {
                subList[j] = _colors[i * 8 + j];
            }
            palette[i] = _createSubPaletteFromColorList(subList);
        }
        return palette;
    }

    function _createSubPaletteFromColorList(uint256[] memory _colors)
        internal
        pure
        returns (uint256)
    {

        require(_colors.length <= 8, 'Too long');
        uint256 subPalette = 0;
        for (uint8 i = 0; i < _colors.length; i++) {
            require(_colors[i] <= COLOR_MASK, 'Not a color');
            subPalette += _colors[i] * 256**(i * 4);
        }
        return subPalette;
    }

    function getColor(uint256[] memory colorPalette, uint256 index)
        internal
        pure
        returns (uint256)
    {

        if (index / 8 > colorPalette.length - 1) {
            return 0;
        }
        uint256 subPalette = colorPalette[index / 8];
        uint256 shift = 256**((index % 8) * 4);
        return (subPalette / shift) & COLOR_MASK;
    }

    function _min(uint256 a, uint256 b) internal pure returns (uint256) {

        return a > b ? b : a;
    }
}//Unlicense
pragma solidity ^0.8.6;


library SceneLib {

    uint256 constant bitsPerPixel = 4; // Best if divisor of 256, e.g., 2, 4, 8, 16, 32
    uint256 constant unitSize = 2**bitsPerPixel; // The number of colors we can handle
    uint256 constant encodingInWord = 256 / bitsPerPixel;
    uint256 constant wordsNeeded = 576 / encodingInWord; //_layer.length / encodingInWord;

    function encodeScene(uint8[] memory _scene) internal pure returns (bytes memory) {

        uint256[wordsNeeded] memory scene;
        for (uint16 i = 0; i < wordsNeeded; i++) {
            for (uint16 j = 0; j < encodingInWord; j++) {
                scene[i] += uint256(_scene[i * encodingInWord + j]) * unitSize**j; // Is this real actually. Only have 8 possibilities here
            }
        }
        return abi.encode(scene);
    }

    function decodeToWords(bytes memory _layer)
        internal
        pure
        returns (uint256[wordsNeeded] memory)
    {

        uint256[wordsNeeded] memory layer = abi.decode(_layer, (uint256[9]));
        return layer;
    }

    function decodeWord(uint256 _word) internal pure returns (uint8[encodingInWord] memory) {

        uint8[encodingInWord] memory wordVals;
        for (uint16 i = 0; i < encodingInWord; i++) {
            wordVals[i] = uint8((_word / unitSize**i) & (unitSize - 1));
        }
        return wordVals;
    }
}// MIT
pragma solidity ^0.8.6;

library Base64 {

    string internal constant TABLE =
        'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/';

    function encode(bytes memory data) internal pure returns (string memory) {

        if (data.length == 0) return '';

        string memory table = TABLE;

        uint256 encodedLen = 4 * ((data.length + 2) / 3);

        string memory result = new string(encodedLen + 32);

        assembly {
            mstore(result, encodedLen)

            let tablePtr := add(table, 1)

            let dataPtr := data
            let endPtr := add(dataPtr, mload(data))

            let resultPtr := add(result, 32)

            for {

            } lt(dataPtr, endPtr) {

            } {
                dataPtr := add(dataPtr, 3)

                let input := mload(dataPtr)

                mstore(resultPtr, shl(248, mload(add(tablePtr, and(shr(18, input), 0x3F)))))
                resultPtr := add(resultPtr, 1)
                mstore(resultPtr, shl(248, mload(add(tablePtr, and(shr(12, input), 0x3F)))))
                resultPtr := add(resultPtr, 1)
                mstore(resultPtr, shl(248, mload(add(tablePtr, and(shr(6, input), 0x3F)))))
                resultPtr := add(resultPtr, 1)
                mstore(resultPtr, shl(248, mload(add(tablePtr, and(input, 0x3F)))))
                resultPtr := add(resultPtr, 1)
            }

            switch mod(mload(data), 3)
            case 1 {
                mstore(sub(resultPtr, 2), shl(240, 0x3d3d))
            }
            case 2 {
                mstore(sub(resultPtr, 1), shl(248, 0x3d))
            }
        }

        return result;
    }
}//Unlicense
pragma solidity ^0.8.6;

interface IMetaDataGenerator {

    struct MetaDataParams {
        uint256 tokenId;
        uint256 activeGene;
        uint256 balance;
        address owner;
    }

    struct Attribute {
        uint256 layer;
        uint256 scene;
    }

    struct EncodedData {
        uint8[576] composite;
        uint256[] colorPalette;
        string[] attributes;
    }

    function getSVG(uint256 activeGene, uint256 balance) external view returns (string memory);


    function tokenURI(MetaDataParams memory params) external view returns (string memory);


    function getEncodedData(uint256 activeGene) external view returns (EncodedData memory);


    function ossified() external view returns (bool);

}//Unlicense
pragma solidity ^0.8.6;




contract MetaDataGenerator is IMetaDataGenerator {

    string internal constant svgStart =
        '<svg xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink" version="1.1" viewBox="0 0 24 24">\n';
    string internal constant svgEnd = '</svg>';

    uint256[] public baseColorPalette;

    uint256[] public randomizeColorPalettes;

    bytes[][] public scenes;

    string[] public attributeNames;
    string[][] public attributeValues;
    string public constant NOTHING = 'Nothing';

    address public owner;

    bool public override ossified;

    modifier onlyOwner() {

        require(owner == msg.sender, 'Not owner');
        _;
    }

    modifier notOssified() {

        require(!ossified, 'Contract ossified');
        _;
    }

    constructor() {
        owner = msg.sender;
    }

    function init(
        string[] memory _attributeNames,
        string[] memory _attributeValues,
        uint256[] memory _basePalette,
        uint256[] memory _randomizePalette,
        bytes[] memory _scenes,
        uint256[] memory _indexes
    ) public notOssified onlyOwner {

        addLayers(_attributeNames);
        setBaseColorPalette(_basePalette);
        setRandomizeColorPalette(_randomizePalette);
        addScenes(_scenes, _attributeValues, _indexes);
        ossified = true;
        owner = address(0);
    }

    function setBaseColorPalette(uint256[] memory _basePalette) internal {

        baseColorPalette = _basePalette;
    }

    function setRandomizeColorPalette(uint256[] memory _randomizePalette) internal {

        randomizeColorPalettes = _randomizePalette;
    }

    function addLayers(string[] memory _attributeNames) internal {

        for (uint8 i = 0; i < _attributeNames.length; i++) {
            scenes.push();
            attributeValues.push();
            attributeNames.push(_attributeNames[i]);
        }
    }

    function addScenes(
        bytes[] memory _scenes,
        string[] memory _attributeValues,
        uint256[] memory _indexes
    ) internal {

        require(_scenes.length == _indexes.length, 'Invalid size');
        require(_attributeValues.length == _indexes.length, 'Invalid size');
        for (uint8 i = 0; i < _indexes.length; i++) {
            scenes[_indexes[i]].push(_scenes[i]);
            attributeValues[_indexes[i]].push(_attributeValues[i]);
        }
    }

    function constructPalette(uint256 activeGene)
        internal
        view
        returns (uint256[] memory colorPalette)
    {

        colorPalette = new uint256[](2);
        colorPalette[0] = baseColorPalette[0];
        colorPalette[1] = baseColorPalette[1];

        for (uint8 i = 0; i < 4; i++) {
            uint256 activeIndex = 4 * i + (((activeGene >> (4 * i)) & 0x0f) % 4);
            uint256 color = ColorLib.getColor(randomizeColorPalettes, activeIndex);
            colorPalette[1] += color * (256**((4 + i) * 4)); // each color use 4 bytes so we add it at value bytes* (4+i*4), e.g., starting at byte 16 and moving 4 bytes at a time until 32
        }
    }

    function getEncodedData(uint256 activeGene) public view override returns (EncodedData memory) {

        uint8[576] memory composite;
        string[] memory attributes = new string[](scenes.length);
        uint256[] memory colorPalette = constructPalette(activeGene);

        activeGene >>= 16; // Get past the colors. // We could probably just do it inside 1 byte

        for (uint256 layerIndex = 0; layerIndex < scenes.length; layerIndex++) {
            bool isActive = layerIndex == 0 || (activeGene & 0x0f) > 0;
            uint256 sceneIndex = (activeGene & 0x0f) % scenes[layerIndex].length;
            attributes[layerIndex] = isActive ? attributeValues[layerIndex][sceneIndex] : NOTHING;

            if (isActive) {
                uint256[9] memory words = SceneLib.decodeToWords(scenes[layerIndex][sceneIndex]);
                uint256 compositeIndex = 0;
                for (uint8 i = 0; i < 9; i++) {
                    if (words[i] == 0) {
                        compositeIndex += 64;
                        continue;
                    }
                    uint8[64] memory vals = SceneLib.decodeWord(words[i]);
                    for (uint8 j = 0; j < 64; j++) {
                        if (vals[j] > 0) {
                            composite[compositeIndex + j] = vals[j];
                        }
                    }
                    compositeIndex += 64;
                }
            }
            activeGene >>= 4;
        }

        return EncodedData(composite, colorPalette, attributes);
    }

    function ethBalanceLine(uint256 balance) internal pure returns (string memory) {

        return
            string(
                abi.encodePacked(
                    '<text x="1" y="23" fill="green" font-family="sans-serif" font-size="1.25">',
                    StringLib.toBalanceString(balance, 3),
                    'ETH</text>\n'
                )
            );
    }

    function getSVG(uint256 activeGene, uint256 balance)
        public
        view
        override
        returns (string memory)
    {

        EncodedData memory data = getEncodedData(activeGene);
        return createSVG(data.composite, data.colorPalette, balance);
    }

    function createSVG(
        uint8[576] memory composite,
        uint256[] memory colorPalette,
        uint256 balance
    ) internal pure returns (string memory svg) {

        svg = string(abi.encodePacked(svgStart));

        string[] memory colors = new string[](16);
        for (uint8 i = 1; i < colors.length; i++) {
            colors[i] = StringLib.toHexColor(ColorLib.getColor(colorPalette, i));
        }
        string[] memory location = new string[](24);
        for (uint8 i = 0; i < 24; i++) {
            location[i] = StringLib.toString(i);
        }

        for (uint32 y = 0; y < 24; y++) {
            uint32 xStart = 0;
            uint32 xEnd = 0;
            uint256 lastVal = 0;
            for (uint32 x = 0; x < 24; x++) {
                uint256 val = composite[y * 24 + x];
                if (val == lastVal) {
                    xEnd = x;
                } else {
                    if (lastVal > 0) {
                        svg = string(
                            abi.encodePacked(
                                svg,
                                '<rect x ="',
                                location[xStart],
                                '" y="',
                                location[y],
                                '" width="',
                                location[xEnd - xStart + 1],
                                '" height="1" shape-rendering="crispEdges" fill="#',
                                colors[lastVal],
                                '"/>\n'
                            )
                        );
                    }
                    xStart = x;
                    xEnd = x;
                    lastVal = val;
                }
            }
            if (lastVal > 0) {
                svg = string(
                    abi.encodePacked(
                        svg,
                        '<rect x ="',
                        location[xStart],
                        '" y="',
                        location[y],
                        '" width="',
                        location[xEnd - xStart + 1],
                        '" height="1" shape-rendering="crispEdges" fill="#',
                        colors[lastVal],
                        '"/>\n'
                    )
                );
            }
        }
        svg = string(abi.encodePacked(svg, ethBalanceLine(balance), svgEnd));
    }

    function toAttributeString(
        string[] memory attributes,
        uint256 balance,
        uint256 activeGene
    ) internal view returns (string memory attributeString) {

        attributeString = string(
            abi.encodePacked(
                '"attributes": [{"trait_type": "balance", "value": ',
                StringLib.toBalanceString(balance, 3),
                '}, {"trait_type": "colorgene", "value": "',
                StringLib.toHex(activeGene & 0xffff),
                '"}'
            )
        );

        for (uint8 i = 0; i < attributes.length; i++) {
            attributeString = string(
                abi.encodePacked(
                    attributeString,
                    ', {"trait_type" : "',
                    attributeNames[i],
                    '", "value": "',
                    attributes[i],
                    '"}'
                )
            );
        }

        attributeString = string(abi.encodePacked(attributeString, ']'));
    }

    function tokenURI(MetaDataParams memory params) public view override returns (string memory) {

        string memory name = string(
            abi.encodePacked('CryptoPiggy #', StringLib.toString(params.tokenId))
        );
        string memory tokenOwner = StringLib.toHex(uint160(params.owner), 20);
        string memory description = 'The mighty holder of coin';
        EncodedData memory data = getEncodedData(params.activeGene);
        string memory image = Base64.encode(
            bytes(createSVG(data.composite, data.colorPalette, params.balance))
        );

        return
            string(
                abi.encodePacked(
                    'data:application/json;base64,',
                    Base64.encode(
                        bytes(
                            abi.encodePacked(
                                '{"name":"',
                                name,
                                '", "description":"',
                                description,
                                '",',
                                toAttributeString(
                                    data.attributes,
                                    params.balance,
                                    params.activeGene
                                ),
                                ',"owner":"',
                                tokenOwner,
                                '", "image": "data:image/svg+xml;base64,',
                                image,
                                '"}'
                            )
                        )
                    )
                )
            );
    }
}