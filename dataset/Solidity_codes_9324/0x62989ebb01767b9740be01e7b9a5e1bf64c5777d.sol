
pragma solidity ^0.8.0;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}// MIT

pragma solidity ^0.8.0;


abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor() {
        _transferOwnership(_msgSender());
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }

    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
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
}// MIT

pragma solidity >=0.6.0;

library Base64 {

    string internal constant TABLE_ENCODE = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/';
    bytes  internal constant TABLE_DECODE = hex"0000000000000000000000000000000000000000000000000000000000000000"
                                            hex"00000000000000000000003e0000003f3435363738393a3b3c3d000000000000"
                                            hex"00000102030405060708090a0b0c0d0e0f101112131415161718190000000000"
                                            hex"001a1b1c1d1e1f202122232425262728292a2b2c2d2e2f303132330000000000";

    function encode(bytes memory data) internal pure returns (string memory) {

        if (data.length == 0) return '';

        string memory table = TABLE_ENCODE;

        uint256 encodedLen = 4 * ((data.length + 2) / 3);

        string memory result = new string(encodedLen + 32);

        assembly {
            mstore(result, encodedLen)

            let tablePtr := add(table, 1)

            let dataPtr := data
            let endPtr := add(dataPtr, mload(data))

            let resultPtr := add(result, 32)

            for {} lt(dataPtr, endPtr) {}
            {
                dataPtr := add(dataPtr, 3)
                let input := mload(dataPtr)

                mstore8(resultPtr, mload(add(tablePtr, and(shr(18, input), 0x3F))))
                resultPtr := add(resultPtr, 1)
                mstore8(resultPtr, mload(add(tablePtr, and(shr(12, input), 0x3F))))
                resultPtr := add(resultPtr, 1)
                mstore8(resultPtr, mload(add(tablePtr, and(shr( 6, input), 0x3F))))
                resultPtr := add(resultPtr, 1)
                mstore8(resultPtr, mload(add(tablePtr, and(        input,  0x3F))))
                resultPtr := add(resultPtr, 1)
            }

            switch mod(mload(data), 3)
            case 1 { mstore(sub(resultPtr, 2), shl(240, 0x3d3d)) }
            case 2 { mstore(sub(resultPtr, 1), shl(248, 0x3d)) }
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

            for {} lt(dataPtr, endPtr) {}
            {
               dataPtr := add(dataPtr, 4)
               let input := mload(dataPtr)

               let output := add(
                   add(
                       shl(18, and(mload(add(tablePtr, and(shr(24, input), 0xFF))), 0xFF)),
                       shl(12, and(mload(add(tablePtr, and(shr(16, input), 0xFF))), 0xFF))),
                   add(
                       shl( 6, and(mload(add(tablePtr, and(shr( 8, input), 0xFF))), 0xFF)),
                               and(mload(add(tablePtr, and(        input , 0xFF))), 0xFF)
                    )
                )
                mstore(resultPtr, shl(232, output))
                resultPtr := add(resultPtr, 3)
            }
        }

        return result;
    }
}// MIT
pragma solidity ^0.8.0;


contract ApeGenerator is Ownable {

    string private constant svgEyeToEnd =
        '</tspan>&#x2591;&#x2591;&#x2591;&#x2588;&#x2588;&#xd;</tspan><tspan x="31.75%" dy="1.2em">&#x2588;&#x2588;&#x2593;&#x2593;&#x2588;&#x2588;&#x2593;&#x2593;&#x2591;&#x2591;&#x2588;&#x2588;&#x2591;&#x2591;&#x2591;&#x2591;&#x2591;&#x2591;&#x2591;&#x2591;&#x2591;&#x2591;&#x2591;&#x2591;&#x2591;&#x2591;&#x2588;&#x2588;&#xd;</tspan><tspan x="35.75%" dy="1.2em">&#x2588;&#x2588;&#x2593;&#x2593;&#x2593;&#x2593;&#x2588;&#x2588;&#x2591;&#x2591;&#x2591;&#x2591;&#x2591;&#x2591;&#x2591;&#x2591;&#x2591;&#x2591;&#x2591;&#x2591;&#x2591;&#x2591;&#x2591;&#x2591;&#x2591;&#x2591;&#x2588;&#x2588;&#xd;</tspan><tspan x="12%" dy="1.2em">&#x2588;&#x2588;&#x2588;&#x2588;&#x2588;&#x2588;        &#x2588;&#x2588;&#x2593;&#x2593;&#x2588;&#x2588;&#x2591;&#x2591;&#x2591;&#x2591;&#x2591;&#x2591;&#x2591;&#x2591;&#x2588;&#x2588;&#x2588;&#x2588;&#x2591;&#x2591;&#x2591;&#x2591;&#x2591;&#x2591;&#x2588;&#x2588;&#xd;</tspan><tspan x="8%" dy="1.2em">&#x2588;&#x2588;&#x2593;&#x2593;&#x2593;&#x2593;&#x2593;&#x2593;&#x2588;&#x2588;        &#x2588;&#x2588;&#x2591;&#x2591;&#x2588;&#x2588;&#x2588;&#x2588;&#x2588;&#x2588;&#x2588;&#x2588;&#x2591;&#x2591;&#x2591;&#x2591;&#x2588;&#x2588;&#x2588;&#x2588;&#x2588;&#x2588;&#xd;</tspan><tspan x="4%" dy="1.2em">&#x2588;&#x2588;&#x2593;&#x2593;&#x2593;&#x2593;&#x2593;&#x2593;&#x2593;&#x2593;&#x2593;&#x2593;&#x2588;&#x2588;      &#x2588;&#x2588;&#x2588;&#x2588;&#x2591;&#x2591;&#x2591;&#x2591;&#x2591;&#x2591;&#x2591;&#x2591;&#x2591;&#x2591;&#x2591;&#x2591;&#x2591;&#x2591;&#x2588;&#x2588;      &#xd;</tspan><tspan x="4%" dy="1.2em">&#x2588;&#x2588;&#x2593;&#x2593;&#x2593;&#x2593;&#x2588;&#x2588;&#x2593;&#x2593;&#x2593;&#x2593;&#x2588;&#x2588;    &#x2588;&#x2588;&#x2593;&#x2593;&#x2593;&#x2593;&#x2588;&#x2588;&#x2588;&#x2588;&#x2588;&#x2588;&#x2588;&#x2588;&#x2588;&#x2588;&#x2588;&#x2588;&#x2588;&#x2588;        &#xd;</tspan><tspan x="4%" dy="1.2em">&#x2588;&#x2588;&#x2593;&#x2593;&#x2593;&#x2593;&#x2593;&#x2593;&#x2588;&#x2588;&#x2588;&#x2588;&#x2588;&#x2588;&#x2588;&#x2588;&#x2588;&#x2588;&#x2593;&#x2593;&#x2593;&#x2593;&#x2593;&#x2593;&#x2593;&#x2593;&#x2593;&#x2593;&#x2588;&#x2588;&#x2593;&#x2593;&#x2593;&#x2593;&#x2588;&#x2588;        &#xd;</tspan><tspan x="8%" dy="1.2em">&#x2588;&#x2588;&#x2593;&#x2593;&#x2593;&#x2593;&#x2593;&#x2593;&#x2593;&#x2593;&#x2593;&#x2593;&#x2588;&#x2588;&#x2593;&#x2593;&#x2593;&#x2593;&#x2593;&#x2593;&#x2593;&#x2593;&#x2588;&#x2588;&#x2593;&#x2593;&#x2593;&#x2593;&#x2588;&#x2588;&#x2593;&#x2593;&#x2593;&#x2593;&#x2588;&#x2588;    &#xd;</tspan><tspan x="12%" dy="1.2em">&#x2588;&#x2588;&#x2588;&#x2588;&#x2588;&#x2588;&#x2588;&#x2588;&#x2588;&#x2588;&#x2588;&#x2588;&#x2593;&#x2593;&#x2593;&#x2593;&#x2593;&#x2593;&#x2593;&#x2593;&#x2593;&#x2593;&#x2588;&#x2588;&#x2593;&#x2593;&#x2593;&#x2593;&#x2588;&#x2588;&#x2593;&#x2593;&#x2593;&#x2593;&#x2588;&#x2588;    &#xd;</tspan><tspan x="32%" dy="1.2em">&#x2588;&#x2588;&#x2588;&#x2588;&#x2588;&#x2588;&#x2588;&#x2588;&#x2588;&#x2588;&#x2593;&#x2593;&#x2588;&#x2588;&#x2591;&#x2591;&#x2591;&#x2591;&#x2591;&#x2591;&#x2588;&#x2588;&#x2591;&#x2591;&#x2591;&#x2591;&#x2588;&#x2588;&#xd;</tspan><tspan x="28%" dy="1.2em">&#x2588;&#x2588;&#x2591;&#x2591;&#x2591;&#x2591;&#x2591;&#x2591;&#x2591;&#x2591;&#x2591;&#x2591;&#x2588;&#x2588;&#x2591;&#x2591;&#x2591;&#x2591;&#x2591;&#x2591;&#x2588;&#x2588;&#x2591;&#x2591;&#x2591;&#x2591;&#x2588;&#x2588;&#xd;</tspan><tspan x="28%" dy="1.2em">&#x2588;&#x2588;&#x2588;&#x2588;&#x2588;&#x2588;&#x2588;&#x2588;&#x2588;&#x2588;&#x2588;&#x2588;&#x2588;&#x2588;&#x2588;&#x2588;&#x2588;&#x2588;&#x2588;&#x2588;&#x2588;&#x2588;&#x2588;&#x2588;&#x2588;&#x2588;</tspan></text></svg>';

    string[14] apeEyes = [
        "&#x20;",
        "&#x2588;",
        "&#x2665;",
        "&#xac;",
        "&#x2d8;",
        "&#x5e;",
        "&#x58;",
        "&#x20BF;",
        "&#x39E;",
        "&#x30;",
        "&#xD2;",
        "&#xB4;",
        "&#x60;",
        "&#x24;"
    ];

    struct st_apeCoreElements {
        uint8 tokenId;
        uint8 eyeIndexLeft;
        uint8 eyeIndexRight;
        uint8 eyeColorIndexLeft;
        uint8 eyeColorIndexRight;
    }

    struct st_apeDefiningElements {
        uint8 specialApeIndex;
        uint8 eyeIndexLeft;
        uint8 eyeIndexRight;
        uint8 eyeColorIndexLeft;
        uint8 eyeColorIndexRight;
        uint8 tokenId;
        uint8 apeNameIndex;
        uint8 bananascore;
    }

    struct mintCombination {
        uint8 eyeIndexLeft;
        uint8 eyeIndexRight;
    }

    struct st_SpecialApe {
        st_apeCoreElements apeCoreElements;
        string name;
        string apeColor;
    }

    mapping(uint256 => st_apeDefiningElements) id_to_apeDefiningElements;

    st_SpecialApe[] ast_specialApeDetails;

    uint8 private maxTokenSupply;
    bool mintWasReduced;

    mintCombination[] arrayOfAvailableMintCombinations;

    event mintEndedSupplyReduced(uint8 newTotalSupply);

    constructor() {
        defineMintCombinations();
        addSpecialApes();
    }

    function nrOfSpecialApes() public view returns (uint256) {

        return ast_specialApeDetails.length;
    }

    function getSpecialApeIndex(uint8 tokenId) public view returns (uint8) {

        for (
            uint8 currentActiveSpecialApeIndex = 0;
            currentActiveSpecialApeIndex < ast_specialApeDetails.length;
            currentActiveSpecialApeIndex++
        ) {
            if (
                ast_specialApeDetails[currentActiveSpecialApeIndex]
                    .apeCoreElements
                    .tokenId == tokenId
            ) {
                return (currentActiveSpecialApeIndex);
            }
        }
        return (maxTokenSupply + 1);
    }

    function defineMintCombinations() private {

        for (uint8 j = 0; j < apeEyes.length; j++) {
            for (uint8 i = 0; i < apeEyes.length; i++) {
                arrayOfAvailableMintCombinations.push(mintCombination(j, i));
                maxTokenSupply += 1;
            }
        }
    }

    function nrOfAvailableMintCombinations() public view returns (uint8) {

        return uint8(arrayOfAvailableMintCombinations.length);
    }

    function endMintReduceTotalSupply(uint8 _TokensAlreadyMinted)
        public
        onlyOwner
        returns (uint8)
    {

        require(!mintWasReduced);
        maxTokenSupply = _TokensAlreadyMinted + 3; //+3 = leave 3 apes for the top3 donators, they need to be delivered
        uint256 nrOfExistingSpecialApes = ast_specialApeDetails.length;
        for (uint8 i = 1; i <= 3; i++) {
            ast_specialApeDetails[nrOfExistingSpecialApes - i]
                .apeCoreElements
                .tokenId = maxTokenSupply - i;
        }
        emit mintEndedSupplyReduced(maxTokenSupply);
        mintWasReduced = true;
        return (maxTokenSupply);
    }

    function removeMintCombinationUnordered(uint256 _indexToRemove)
        public
        onlyOwner
    {

        require(
            _indexToRemove <= arrayOfAvailableMintCombinations.length ||
                arrayOfAvailableMintCombinations.length > 0,
            "index out of range"
        );
        if (_indexToRemove == arrayOfAvailableMintCombinations.length - 1) {
            arrayOfAvailableMintCombinations.pop();
        } else {
            arrayOfAvailableMintCombinations[
                _indexToRemove
            ] = arrayOfAvailableMintCombinations[
                arrayOfAvailableMintCombinations.length - 1
            ];
            arrayOfAvailableMintCombinations.pop();
        }
    }

    function addSpecialApes() private {

        ast_specialApeDetails.push(
            st_SpecialApe(
                st_apeCoreElements(0, 9, 9, 0, 0),
                "Zero the first ever minted 0 eyed ape #0",
                "#6fd1c4" //downy colored
            )
        );

        ast_specialApeDetails.push(
            st_SpecialApe(
                st_apeCoreElements(40, 5, 5, 0, 0),
                "Icy the glowing happy eyed frozen ape #40",
                "#00bdc7" //ice blue
            )
        );

        ast_specialApeDetails.push(
            st_SpecialApe(
                st_apeCoreElements(80, 2, 2, 0, 0),
                "Harry the banana power love eyed ape #80",
                "#c7ba00" //banana yellow
            )
        );

        ast_specialApeDetails.push(
            st_SpecialApe(
                st_apeCoreElements(120, 0, 0, 1, 1),
                "Piu the golden empty eyed ape #120",
                "#ffd900" //golden
            )
        );

        ast_specialApeDetails.push(
            st_SpecialApe(
                st_apeCoreElements(160, 12, 11, 0, 0),
                "ApeNorris the angry eyed rarest toughest mf ape #160",
                "#ff230a" //red
            )
        );

        ast_specialApeDetails.push(
            st_SpecialApe(
                st_apeCoreElements(201, 9, 9, 2, 2),
                "Carl the dead invisible ape #201",
                "#000000" //black->invisible
            )
        );
        ast_specialApeDetails.push(
            st_SpecialApe(
                st_apeCoreElements(202, 7, 7, 1, 1),
                "Satoshi the btc eyed ape #202",
                "#ff33cc" //pink
            )
        );

        ast_specialApeDetails.push(
            st_SpecialApe(
                st_apeCoreElements(203, 8, 8, 2, 2),
                "Vitalik the eth eyed ape #203",
                "#ffd900" //gold
            )
        );

        ast_specialApeDetails.push(
            st_SpecialApe(
                st_apeCoreElements(204, 13, 13, 0, 0),
                "Dollari the inflationary dollar eyed ape #204",
                "#ff0000" //red
            )
        );

        maxTokenSupply += uint8(ast_specialApeDetails.length);
    }

    function totalSupply() public view returns (uint256) {

        return maxTokenSupply;
    }

    function genNameAndSymmetry(uint8 _tokenId)
        public
        view
        returns (bytes memory)
    {

        require(
            id_to_apeDefiningElements[_tokenId].apeNameIndex < 13 && /*gas optimized, not apeName.length used */
                id_to_apeDefiningElements[_tokenId].eyeIndexLeft < 14, /*gas optimized, not apeEyes.length used */
            "invalid index"
        );

        if (
            id_to_apeDefiningElements[_tokenId].specialApeIndex <=
            maxTokenSupply
        ) {
            return (
                abi.encodePacked(
                    ast_specialApeDetails[
                        id_to_apeDefiningElements[_tokenId].specialApeIndex
                    ].name,
                    '","attributes":[{"trait_type":"Facesymmetry","value":"',
                    "100"
                )
            );
        }

        string[13] memory apeNames = [
            "Arti",
            "Abu",
            "Aldo",
            "Bingo",
            "Krabs",
            "DC",
            "Groot",
            "Phaedrus",
            "D-Sasta",
            "Doxed",
            "Kinay",
            "Kodiak",
            "Cophi"
        ];

        string[14] memory apeEyeDescription = [
            "dead",
            "blind",
            "heart",
            "peek",
            "wink",
            "grin",
            "cross",
            "btc",
            "eth",
            "zero",
            "brow",
            "small",
            "small",
            "dollar"
        ];

        string memory eyePrefix;
        string memory faceSymmetry;
        if (
            id_to_apeDefiningElements[_tokenId].eyeIndexLeft ==
            id_to_apeDefiningElements[_tokenId].eyeIndexRight
        ) {
            eyePrefix = string(
                abi.encodePacked(
                    " the full ",
                    apeEyeDescription[
                        id_to_apeDefiningElements[_tokenId].eyeIndexLeft
                    ],
                    " eyed ascii ape"
                )
            );
            faceSymmetry = "100";
        } else {
            eyePrefix = string(
                abi.encodePacked(
                    " the half ",
                    apeEyeDescription[
                        id_to_apeDefiningElements[_tokenId].eyeIndexLeft
                    ],
                    " half ",
                    apeEyeDescription[
                        id_to_apeDefiningElements[_tokenId].eyeIndexRight
                    ],
                    " eyed ascii ape"
                )
            );
            faceSymmetry = "50";
        }

        return (
            abi.encodePacked(
                apeNames[id_to_apeDefiningElements[_tokenId].apeNameIndex],
                eyePrefix,
                " #",
                Strings.toString(_tokenId),
                '","attributes":[{"trait_type":"Facesymmetry","value":"',
                faceSymmetry
            )
        );
    }

    function generateSpecialApeSvg(
        uint8 _specialApeIndex,
        string memory textFillToEye
    ) private view returns (string memory) {
        string[3] memory eyeColor = ['ff1414">', 'ffd700">', 'ff33cc">']; //red, gold, pink

        return (
            Base64.encode(
                abi.encodePacked(
                    '<svg width="500" height="500" xmlns="http://www.w3.org/2000/svg"><rect height="500" width="500" fill="black"/><text y="10%" fill="',
                    ast_specialApeDetails[_specialApeIndex].apeColor,
                    textFillToEye,
                    eyeColor[
                        ast_specialApeDetails[_specialApeIndex]
                            .apeCoreElements
                            .eyeColorIndexLeft
                    ],
                    apeEyes[
                        ast_specialApeDetails[_specialApeIndex]
                            .apeCoreElements
                            .eyeIndexLeft
                    ],
                    '</tspan>&#x2591;&#x2591;&#x2591;&#x2591;&#x2591;<tspan fill="#',
                    eyeColor[
                        ast_specialApeDetails[_specialApeIndex]
                            .apeCoreElements
                            .eyeColorIndexRight
                    ],
                    apeEyes[
                        ast_specialApeDetails[_specialApeIndex]
                            .apeCoreElements
                            .eyeIndexRight
                    ],
                    svgEyeToEnd
                )
            )
        );
    }

    function generateApeSvg(uint8 _tokenId, string memory textFillToEye)
        private
        view
        returns (string memory)
    {
        string[3] memory eyeColor = ['ff1414">', 'ffd700">', 'ff33cc">']; //red, gold, pink

        return (
            Base64.encode(
                abi.encodePacked(
                    '<svg width="500" height="500" xmlns="http://www.w3.org/2000/svg"><rect height="500" width="500" fill="black"/><text y="10%" fill="', //start to textFill
                    "#ffffff",
                    textFillToEye,
                    eyeColor[
                        id_to_apeDefiningElements[_tokenId].eyeColorIndexLeft
                    ],
                    apeEyes[id_to_apeDefiningElements[_tokenId].eyeIndexLeft],
                    '</tspan>&#x2591;&#x2591;&#x2591;&#x2591;&#x2591;<tspan fill="#',
                    eyeColor[
                        id_to_apeDefiningElements[_tokenId].eyeColorIndexRight
                    ],
                    apeEyes[id_to_apeDefiningElements[_tokenId].eyeIndexRight],
                    svgEyeToEnd
                )
            )
        );
    }

    function registerApe(
        uint8 _specialApeIndex,
        uint8 _randomNumber,
        uint8 eyeColorIndexLeft,
        uint8 eyeColorIndexRight,
        uint8 tokenId,
        uint8 _apeNameIndex,
        uint8 bananascore
    ) public onlyOwner returns (bool) {
        require(tokenId >= 0 && tokenId < maxTokenSupply, "invalid tokenId");
        if (_specialApeIndex <= maxTokenSupply) {
            id_to_apeDefiningElements[tokenId] = st_apeDefiningElements(
                _specialApeIndex,
                0,
                0,
                0,
                0,
                tokenId,
                0,
                bananascore
            );
        } else {
            id_to_apeDefiningElements[tokenId] = st_apeDefiningElements(
                _specialApeIndex,
                arrayOfAvailableMintCombinations[_randomNumber].eyeIndexLeft,
                arrayOfAvailableMintCombinations[_randomNumber].eyeIndexRight,
                eyeColorIndexLeft,
                eyeColorIndexRight,
                tokenId,
                _apeNameIndex,
                bananascore
            );
        }
        return (true);
    }

    function getTokenURI(uint8 tokenId) public view returns (string memory) {
        require(
            id_to_apeDefiningElements[tokenId].bananascore != 0,
            "invalid tokenId"
        ); //ape not registered/minted or tokenId invalid
        string
            memory textFillToEye = '" text-anchor="start" font-size="18" xml:space="preserve" font-family="monospace"><tspan x="43.75%" dy="1.2em">&#x2588;&#x2588;&#x2588;&#x2588;&#x2588;&#x2588;&#x2588;&#x2588;&#x2588;&#x2588;&#x2588;&#x2588;&#x2588;&#x2588;&#xd;</tspan><tspan x="39.75%" dy="1.2em">&#x2588;&#x2588;&#x2593;&#x2593;&#x2593;&#x2593;&#x2593;&#x2593;&#x2593;&#x2593;&#x2593;&#x2593;&#x2593;&#x2593;&#x2593;&#x2593;&#x2588;&#x2588;&#x2588;&#x2588;&#xd;</tspan><tspan x="35.75%" dy="1.2em">&#x2588;&#x2588;&#x2588;&#x2588;&#x2593;&#x2593;&#x2593;&#x2593;&#x2593;&#x2593;&#x2591;&#x2591;&#x2591;&#x2591;&#x2593;&#x2593;&#x2593;&#x2593;&#x2591;&#x2591;&#x2588;&#x2588;&#xd;</tspan><tspan x="31.75%" dy="1.2em">&#x2588;&#x2588;&#x2593;&#x2593;&#x2593;&#x2593;&#x2593;&#x2593;&#x2593;&#x2593;&#x2591;&#x2591;&#x2591;&#x2591;&#x2591;&#x2591;&#x2591;&#x2591;&#x2591;&#x2591;&#x2591;&#x2591;&#x2591;&#x2591;&#x2588;&#x2588;&#xd;</tspan><tspan x="31.75%" dy="1.2em">&#x2588;&#x2588;&#x2593;&#x2593;&#x2593;&#x2593;&#x2593;&#x2593;&#x2591;&#x2591;&#x2591;&#x2591;&#x2591;&#x2591;<tspan fill="#';

        string memory generatedApeSvg;
        if (
            id_to_apeDefiningElements[tokenId].specialApeIndex <= maxTokenSupply
        ) {
            generatedApeSvg = generateSpecialApeSvg(
                id_to_apeDefiningElements[tokenId].specialApeIndex,
                textFillToEye
            );
        } else {
            generatedApeSvg = generateApeSvg(tokenId, textFillToEye);
        }
        return (
            string(
                abi.encodePacked(
                    "data:application/json;base64,",
                    Base64.encode(
                        abi.encodePacked(
                            '{"description":"Fully onchain generated AsciiApe","image":"data:image/svg+xml;base64,',
                            generatedApeSvg,
                            apeAttributes(tokenId)
                        )
                    )
                )
            )
        );
    }

    function apeAttributes(uint8 _tokenId) public view returns (bytes memory) {
        bytes memory nameAndSymmetry;
        string memory apeColor;
        if (
            id_to_apeDefiningElements[_tokenId].specialApeIndex <=
            maxTokenSupply
        ) {
            apeColor = ast_specialApeDetails[
                id_to_apeDefiningElements[_tokenId].specialApeIndex
            ].apeColor;
        } else {
            apeColor = "#ffffff";
        }
        nameAndSymmetry = genNameAndSymmetry(_tokenId);

        string[3] memory eyeColor = ["#ff1414", "#ffd700", "#ff33cc"]; //red, gold, pink
        return (
            abi.encodePacked(
                '","name":"',
                nameAndSymmetry,
                '"},{"trait_type":"EyeLeft","value":"',
                apeEyes[id_to_apeDefiningElements[_tokenId].eyeIndexLeft],
                '"},{"trait_type":"EyeRight","value":"',
                apeEyes[id_to_apeDefiningElements[_tokenId].eyeIndexRight],
                '"},{"trait_type":"EyeColorLeft","value":"',
                eyeColor[id_to_apeDefiningElements[_tokenId].eyeColorIndexLeft],
                '"},{"trait_type":"EyeColorRight","value":"',
                eyeColor[
                    id_to_apeDefiningElements[_tokenId].eyeColorIndexRight
                ],
                '"},{"trait_type":"ApeColor","value":"',
                apeColor,
                '"},{"trait_type":"BananaScore","value":"',
                Strings.toString(
                    id_to_apeDefiningElements[_tokenId].bananascore
                ),
                '"}]}'
            )
        );
    }
}