pragma solidity ^0.8.12;

library utils {

    string internal constant NULL = "";

    function rgbaString(string memory _rgb, string memory _a)
        internal
        pure
        returns (string memory)
    {

        string memory formattedA = stringsEqual(_a, "100")
            ? "1"
            : string.concat("0.", _a);

        return string.concat("rgba(", _rgb, ",", formattedA, ")");
    }

    function rgba(
        uint256 _r,
        uint256 _g,
        uint256 _b,
        string memory _a
    ) internal pure returns (string memory) {

        string memory formattedA = stringsEqual(_a, "100")
            ? "1"
            : string.concat("0.", _a);

        return
            string.concat(
                "rgba(",
                utils.uint2str(_r),
                ",",
                utils.uint2str(_g),
                ",",
                utils.uint2str(_b),
                ",",
                formattedA,
                ")"
            );
    }

    function rgbaFromArray(uint256[3] memory _arr, string memory _a)
        internal
        pure
        returns (string memory)
    {

        return rgba(_arr[0], _arr[1], _arr[2], _a);
    }

    function stringsEqual(string memory _a, string memory _b)
        internal
        pure
        returns (bool)
    {

        return
            keccak256(abi.encodePacked(_a)) == keccak256(abi.encodePacked(_b));
    }

    function uint2str(uint256 _i)
        internal
        pure
        returns (string memory _uintAsString)
    {

        if (_i == 0) {
            return "0";
        }
        uint256 j = _i;
        uint256 len;
        while (j != 0) {
            len++;
            j /= 10;
        }
        bytes memory bstr = new bytes(len);
        uint256 k = len;
        while (_i != 0) {
            k = k - 1;
            uint8 temp = (48 + uint8(_i - (_i / 10) * 10));
            bytes1 b1 = bytes1(temp);
            bstr[k] = b1;
            _i /= 10;
        }
        return string(bstr);
    }

    function getRandomInteger(
        string memory _name,
        uint256 _seed,
        uint256 _min,
        uint256 _max
    ) internal pure returns (uint256) {

        if (_max <= _min) return _min;
        return
            (uint256(keccak256(abi.encodePacked(_name, _seed))) %
                (_max - _min)) + _min;
    }

    function shuffle(uint256[3] memory _arr, uint256 _seed)
        internal
        view
        returns (uint256[3] memory)
    {

        for (uint256 i = 0; i < _arr.length; i++) {
            uint256 n = i +
                (uint256(keccak256(abi.encodePacked(block.timestamp, _seed))) %
                    (_arr.length - i));
            uint256 temp = _arr[n];
            _arr[n] = _arr[i];
            _arr[i] = temp;
        }

        return _arr;
    }
}
pragma solidity ^0.8.12;

library svg {

    function g(string memory _props, string memory _children)
        internal
        pure
        returns (string memory)
    {

        return el("g", _props, _children);
    }

    function defs(string memory _props, string memory _children)
        internal
        pure
        returns (string memory)
    {

        return el("defs", _props, _children);
    }

    function circle(string memory _props, string memory _children)
        internal
        pure
        returns (string memory)
    {

        return el("circle", _props, _children);
    }

    function radialGradient(string memory _props, string memory _children)
        internal
        pure
        returns (string memory)
    {

        return el("radialGradient", _props, _children);
    }

    function gradientStop(
        uint256 offset,
        string memory stopColor,
        string memory _props
    ) internal pure returns (string memory) {

        return
            el(
                "stop",
                string.concat(
                    prop("stop-color", stopColor),
                    " ",
                    prop("offset", string.concat(utils.uint2str(offset), "%")),
                    " ",
                    _props
                ),
                utils.NULL
            );
    }

    function animateTransform(string memory _props)
        internal
        pure
        returns (string memory)
    {

        return el("animateTransform", _props, utils.NULL);
    }

    function el(
        string memory _tag,
        string memory _props,
        string memory _children
    ) internal pure returns (string memory) {

        return
            string.concat(
                "<",
                _tag,
                " ",
                _props,
                ">",
                _children,
                "</",
                _tag,
                ">"
            );
    }

    function prop(string memory _key, string memory _val)
        internal
        pure
        returns (string memory)
    {

        return string.concat(_key, "=", '"', _val, '" ');
    }
}
pragma solidity ^0.8.12;

library Base64 {

    string internal constant TABLE_ENCODE =
        "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/";
    bytes internal constant TABLE_DECODE =
        hex"0000000000000000000000000000000000000000000000000000000000000000"
        hex"00000000000000000000003e0000003f3435363738393a3b3c3d000000000000"
        hex"00000102030405060708090a0b0c0d0e0f101112131415161718190000000000"
        hex"001a1b1c1d1e1f202122232425262728292a2b2c2d2e2f303132330000000000";

    function encode(bytes memory data) internal pure returns (string memory) {

        if (data.length == 0) return "";

        string memory table = TABLE_ENCODE;

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

                mstore8(
                    resultPtr,
                    mload(add(tablePtr, and(shr(18, input), 0x3F)))
                )
                resultPtr := add(resultPtr, 1)
                mstore8(
                    resultPtr,
                    mload(add(tablePtr, and(shr(12, input), 0x3F)))
                )
                resultPtr := add(resultPtr, 1)
                mstore8(
                    resultPtr,
                    mload(add(tablePtr, and(shr(6, input), 0x3F)))
                )
                resultPtr := add(resultPtr, 1)
                mstore8(resultPtr, mload(add(tablePtr, and(input, 0x3F))))
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

    function decode(string memory _data) internal pure returns (bytes memory) {

        bytes memory data = bytes(_data);

        if (data.length == 0) return new bytes(0);
        require(data.length % 4 == 0, "invalid base64 decoder input");

        bytes memory table = TABLE_DECODE;

        uint256 decodedLen = (data.length / 4) * 3;

        bytes memory result = new bytes(decodedLen + 32);

        assembly {
            let lastBytes := mload(add(data, mload(data)))
            if eq(and(lastBytes, 0xFF), 0x3d) {
                decodedLen := sub(decodedLen, 1)
                if eq(and(lastBytes, 0xFFFF), 0x3d3d) {
                    decodedLen := sub(decodedLen, 1)
                }
            }

            mstore(result, decodedLen)

            let tablePtr := add(table, 1)

            let dataPtr := data
            let endPtr := add(dataPtr, mload(data))

            let resultPtr := add(result, 32)

            for {

            } lt(dataPtr, endPtr) {

            } {
                dataPtr := add(dataPtr, 4)
                let input := mload(dataPtr)

                let output := add(
                    add(
                        shl(
                            18,
                            and(
                                mload(add(tablePtr, and(shr(24, input), 0xFF))),
                                0xFF
                            )
                        ),
                        shl(
                            12,
                            and(
                                mload(add(tablePtr, and(shr(16, input), 0xFF))),
                                0xFF
                            )
                        )
                    ),
                    add(
                        shl(
                            6,
                            and(
                                mload(add(tablePtr, and(shr(8, input), 0xFF))),
                                0xFF
                            )
                        ),
                        and(mload(add(tablePtr, and(input, 0xFF))), 0xFF)
                    )
                )
                mstore(resultPtr, shl(232, output))
                resultPtr := add(resultPtr, 3)
            }
        }

        return result;
    }
}
pragma solidity ^0.8.12;


interface SpectrumGeneratorInterface {

    function tokenURI(uint256 _tokenId, uint256 _seed)
        external
        view
        returns (string memory);

}
pragma solidity ^0.8.12;


interface SpectrumDetailsInterface {

    function getDetail(uint256 _detail)
        external
        view
        returns (string memory, string memory);

}
pragma solidity ^0.8.12;



contract SpectrumGenerator is SpectrumGeneratorInterface {

    uint256 private MIN_LAYERS = 2;
    uint256 private MAX_LAYERS = 6;
    uint256 private MIN_DURATION = 10;
    uint256 private MAX_DURATION = 30;

    SpectrumDetailsInterface public spectrumDetails;

    mapping(uint256 => string) private _tokenURIs;

    uint256 public tokenCounter;

    constructor(SpectrumDetailsInterface _spectrumDetails) {
        spectrumDetails = _spectrumDetails;
    }

    function createLayer(
        string memory _name,
        string memory _duration,
        string memory _rgb
    ) internal pure returns (string memory) {

        return
            string.concat(
                svg.g(
                    string.concat(
                        svg.prop("style", "mix-blend-mode: multiply")
                    ),
                    string.concat(
                        svg.circle(
                            string.concat(
                                svg.prop("cx", "500"),
                                svg.prop("cy", "500"),
                                svg.prop("r", "500"),
                                svg.prop(
                                    "fill",
                                    string.concat("url(#", _name, ")")
                                )
                            ),
                            utils.NULL
                        ),
                        svg.animateTransform(
                            string.concat(
                                svg.prop("attributeType", "xml"),
                                svg.prop("attributeName", "transform"),
                                svg.prop("type", "rotate"),
                                svg.prop("from", "360 500 500"),
                                svg.prop("to", "0 500 500"),
                                svg.prop("dur", string.concat(_duration, "s")),
                                svg.prop("additive", "sum"),
                                svg.prop("repeatCount", "indefinite")
                            )
                        )
                    )
                ),
                svg.defs(
                    utils.NULL,
                    svg.radialGradient(
                        string.concat(
                            svg.prop("id", _name),
                            svg.prop("cx", "0"),
                            svg.prop("cy", "0"),
                            svg.prop("r", "1"),
                            svg.prop("gradientUnits", "userSpaceOnUse"),
                            svg.prop(
                                "gradientTransform",
                                "translate(500) rotate(90) scale(1000)"
                            )
                        ),
                        string.concat(
                            svg.gradientStop(0, _rgb, utils.NULL),
                            svg.gradientStop(
                                100,
                                _rgb,
                                string.concat(svg.prop("stop-opacity", "0"))
                            )
                        )
                    )
                )
            );
    }

    function _getLayers(uint256 seed, uint256 d)
        private
        view
        returns (string memory, string memory)
    {

        uint256 i;
        uint256 iterations = utils.getRandomInteger(
            "iterations",
            seed,
            MIN_LAYERS,
            MAX_LAYERS
        );
        string memory layers;
        string memory layersMeta;

        while (i < iterations) {
            string memory id = utils.uint2str(i);
            uint256 duration = utils.getRandomInteger(
                id,
                seed,
                MIN_DURATION,
                MAX_DURATION
            );
            uint256 r = utils.getRandomInteger(
                string.concat("r_", id),
                seed,
                0,
                255
            );
            uint256[3] memory arr = [r, 0, 255];
            uint256[3] memory shuffledArr = utils.shuffle(arr, i + d);

            layers = string.concat(
                layers,
                createLayer(
                    string.concat("layer_", id),
                    utils.uint2str(duration),
                    string.concat(
                        "rgb(",
                        utils.uint2str(shuffledArr[0]),
                        ",",
                        utils.uint2str(shuffledArr[1]),
                        ",",
                        utils.uint2str(shuffledArr[2]),
                        ")"
                    )
                )
            );

            layersMeta = string.concat(
                layersMeta,
                _createAttribute(
                    "Layer Color",
                    string.concat(
                        utils.uint2str(shuffledArr[0]),
                        ",",
                        utils.uint2str(shuffledArr[1]),
                        ",",
                        utils.uint2str(shuffledArr[2])
                    ),
                    true
                ),
                _createAttribute("Layer Speed", utils.uint2str(duration), true)
            );

            i++;
        }

        return (
            layers,
            string.concat(
                _createAttribute("Layers", utils.uint2str(iterations), true),
                layersMeta
            )
        );
    }

    function _createSvg(uint256 _seed, uint256 _tokenId)
        internal
        view
        returns (string memory, string memory)
    {

        uint256 d = _tokenId < 2
            ? 92 + _tokenId
            : utils.getRandomInteger("_detail", _seed, 1, 92);
        (string memory detail, string memory detailName) = spectrumDetails
            .getDetail(d);
        (string memory layers, string memory layersMeta) = _getLayers(_seed, d);

        string memory stringSvg = string.concat(
            '<svg xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink" viewBox="0 0 1000 1000">',
            svg.circle(
                string.concat(
                    svg.prop("cx", "500"),
                    svg.prop("cy", "500"),
                    svg.prop("r", "500"),
                    svg.prop("fill", "#fff")
                ),
                utils.NULL
            ),
            layers,
            detail,
            "</svg>"
        );

        return (
            string(
                abi.encodePacked(
                    "data:image/svg+xml;base64,",
                    Base64.encode(bytes(stringSvg))
                )
            ),
            string.concat(
                '"attributes":[',
                _createAttribute("Detail", detailName, false),
                layersMeta,
                "]"
            )
        );
    }

    function _createAttribute(
        string memory _type,
        string memory _value,
        bool _leadingComma
    ) internal pure returns (string memory) {

        return
            string.concat(
                _leadingComma ? "," : "",
                '{"trait_type":"',
                _type,
                '","value":"',
                _value,
                '"}'
            );
    }

    function _prepareMetadata(
        uint256 tokenId,
        string memory image,
        string memory attributes
    ) internal pure returns (string memory) {

        return
            string(
                abi.encodePacked(
                    "data:application/json;base64,",
                    Base64.encode(
                        bytes(
                            abi.encodePacked(
                                '{"name":"Spectrum #',
                                utils.uint2str(tokenId),
                                '", "description":"Kinetic Spectrums is a collection of dynamic, ever changing artworks stored on the Ethereum Network. Each Spectrum is made by combining 2 to 5 layers of color. These layers multiply with each other and slowly rotate at a different speeds meaning your NFT is constantly changing color and evolving the longer you watch it.", ',
                                attributes,
                                ', "image":"',
                                image,
                                '"}'
                            )
                        )
                    )
                )
            );
    }

    function tokenURI(uint256 _tokenId, uint256 _seed)
        external
        view
        returns (string memory)
    {

        (string memory svg64, string memory attributes) = _createSvg(
            _seed,
            _tokenId
        );

        return _prepareMetadata(_tokenId, svg64, attributes);
    }
}
