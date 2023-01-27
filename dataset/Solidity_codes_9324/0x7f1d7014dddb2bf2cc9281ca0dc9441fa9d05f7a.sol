
pragma solidity ^0.8.0;

abstract contract ReentrancyGuard {

    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor() {
        _status = _NOT_ENTERED;
    }

    modifier nonReentrant() {
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        _status = _ENTERED;

        _;

        _status = _NOT_ENTERED;
    }
}// MIT

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
        _setOwner(_msgSender());
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        _setOwner(address(0));
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _setOwner(newOwner);
    }

    function _setOwner(address newOwner) private {
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
pragma solidity 0.8.4;

interface ChainRunnersTypes {

    struct ChainRunner {
        uint256 dna;
    }
}// MIT
pragma solidity 0.8.4;


interface IChainRunnersRenderer {

    function tokenURI(uint256 tokenId, ChainRunnersTypes.ChainRunner memory runnerData) external view returns (string memory);

}// MIT

pragma solidity ^0.8.0;

interface IERC165 {

    function supportsInterface(bytes4 interfaceId) external view returns (bool);

}// MIT

pragma solidity ^0.8.0;


interface IERC721 is IERC165 {

    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);

    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);

    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);

    function balanceOf(address owner) external view returns (uint256 balance);


    function ownerOf(uint256 tokenId) external view returns (address owner);


    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;


    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;


    function approve(address to, uint256 tokenId) external;


    function getApproved(uint256 tokenId) external view returns (address operator);


    function setApprovalForAll(address operator, bool _approved) external;


    function isApprovedForAll(address owner, address operator) external view returns (bool);


    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes calldata data
    ) external;

}// MIT

pragma solidity ^0.8.0;


interface IERC721Enumerable is IERC721 {

    function totalSupply() external view returns (uint256);


    function tokenOfOwnerByIndex(address owner, uint256 index) external view returns (uint256 tokenId);


    function tokenByIndex(uint256 index) external view returns (uint256);

}// MIT
pragma solidity 0.8.4;


interface IChainRunners is IERC721Enumerable {

    function getDna(uint256 _tokenId) external view returns (uint256);

}// MIT
pragma solidity 0.8.4;



contract ChainRunnersBaseRenderer is Ownable, ReentrancyGuard {

    struct SVGCursor {
        uint8 x;
        uint8 y;
        string color1;
        string color2;
        string color3;
        string color4;
    }

    struct Buffer {
        string one;
        string two;
        string three;
        string four;
        string five;
        string six;
        string seven;
        string eight;
    }

    struct Color {
        string hexString;
        uint alpha;
        uint red;
        uint green;
        uint blue;
    }

    struct Layer {
        string name;
        bytes hexString;
    }

    struct LayerInput {
        string name;
        bytes hexString;
        uint8 layerIndex;
        uint8 itemIndex;
    }

    uint256 public constant NUM_LAYERS = 13;
    uint256 public constant NUM_COLORS = 8;

    mapping(uint256 => Layer) [NUM_LAYERS] layers;

    uint16[][NUM_LAYERS][3] WEIGHTS;

    constructor() {
        WEIGHTS[0][0] = [36, 225, 225, 225, 360, 135, 27, 360, 315, 315, 315, 315, 225, 180, 225, 180, 360, 180, 45, 360, 360, 360, 27, 36, 360, 45, 180, 360, 225, 360, 225, 225, 360, 180, 45, 360, 18, 225, 225, 225, 225, 180, 225, 361];
        WEIGHTS[0][1] = [875, 1269, 779, 779, 779, 779, 779, 779, 779, 779, 779, 779, 17, 8, 41];
        WEIGHTS[0][2] = [303, 303, 303, 303, 151, 30, 0, 0, 151, 151, 151, 151, 30, 303, 151, 30, 303, 303, 303, 303, 303, 303, 30, 151, 303, 303, 303, 303, 303, 303, 303, 303, 3066];
        WEIGHTS[0][3] = [645, 0, 1290, 322, 645, 645, 645, 967, 322, 967, 645, 967, 967, 973];
        WEIGHTS[0][4] = [0, 0, 0, 1250, 1250, 1250, 1250, 1250, 1250, 1250, 1250];
        WEIGHTS[0][5] = [121, 121, 121, 121, 121, 121, 243, 0, 0, 0, 0, 121, 121, 243, 121, 121, 243, 121, 121, 121, 121, 121, 243, 121, 121, 121, 121, 243, 121, 121, 121, 121, 243, 121, 121, 121, 243, 121, 121, 121, 121, 243, 121, 121, 121, 121, 243, 121, 121, 121, 121, 243, 121, 121, 121, 121, 243, 121, 121, 121, 121, 243, 121, 121, 243, 0, 0, 0, 121, 121, 243, 121, 121, 306];
        WEIGHTS[0][6] = [925, 555, 185, 555, 925, 925, 185, 1296, 1296, 1296, 1857];
        WEIGHTS[0][7] = [88, 88, 88, 88, 88, 265, 442, 8853];
        WEIGHTS[0][8] = [189, 189, 47, 18, 9, 28, 37, 9483];
        WEIGHTS[0][9] = [340, 340, 340, 340, 340, 340, 34, 340, 340, 340, 340, 170, 170, 170, 102, 238, 238, 238, 272, 340, 340, 340, 272, 238, 238, 238, 238, 170, 34, 340, 340, 136, 340, 340, 340, 340, 344];
        WEIGHTS[0][10] = [159, 212, 106, 53, 26, 159, 53, 265, 53, 212, 159, 265, 53, 265, 265, 212, 53, 159, 239, 53, 106, 5, 106, 53, 212, 212, 106, 159, 212, 265, 212, 265, 5066];
        WEIGHTS[0][11] = [139, 278, 278, 250, 250, 194, 222, 278, 278, 194, 222, 83, 222, 278, 139, 139, 27, 278, 278, 278, 278, 27, 278, 139, 278, 278, 278, 278, 278, 278, 278, 278, 278, 278, 278, 27, 139, 139, 139, 139, 0, 278, 194, 83, 83, 278, 83, 27, 306];
        WEIGHTS[0][12] = [981, 2945, 654, 16, 981, 327, 654, 163, 3279];

        WEIGHTS[1][0] = [36, 225, 225, 225, 360, 135, 27, 360, 315, 315, 315, 315, 225, 180, 225, 180, 360, 180, 45, 360, 360, 360, 27, 36, 360, 45, 180, 360, 225, 360, 225, 225, 360, 180, 45, 360, 18, 225, 225, 225, 225, 180, 225, 361];
        WEIGHTS[1][1] = [875, 1269, 779, 779, 779, 779, 779, 779, 779, 779, 779, 779, 17, 8, 41];
        WEIGHTS[1][2] = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 10000];
        WEIGHTS[1][3] = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0];
        WEIGHTS[1][4] = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0];
        WEIGHTS[1][5] = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 384, 7692, 1923, 0, 0, 0, 0, 0, 1];
        WEIGHTS[1][6] = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 10000];
        WEIGHTS[1][7] = [0, 0, 0, 0, 0, 909, 0, 9091];
        WEIGHTS[1][8] = [0, 0, 0, 0, 0, 0, 0, 10000];
        WEIGHTS[1][9] = [526, 526, 526, 0, 0, 0, 0, 0, 526, 0, 0, 0, 526, 0, 526, 0, 0, 0, 526, 526, 526, 526, 526, 526, 526, 526, 526, 526, 526, 0, 0, 526, 0, 0, 0, 0, 532];
        WEIGHTS[1][10] = [80, 0, 400, 240, 80, 0, 240, 0, 0, 80, 80, 80, 0, 0, 0, 0, 80, 80, 0, 0, 80, 80, 0, 80, 80, 80, 80, 80, 0, 0, 0, 0, 8000];
        WEIGHTS[1][11] = [289, 0, 0, 0, 0, 404, 462, 578, 578, 0, 462, 173, 462, 578, 0, 0, 57, 0, 57, 0, 57, 57, 578, 289, 578, 57, 0, 57, 57, 57, 578, 578, 0, 0, 0, 0, 0, 0, 57, 289, 578, 0, 0, 0, 231, 57, 0, 0, 1745];
        WEIGHTS[1][12] = [714, 714, 714, 0, 714, 0, 0, 0, 7144];

        WEIGHTS[2][0] = [36, 225, 225, 225, 360, 135, 27, 360, 315, 315, 315, 315, 225, 180, 225, 180, 360, 180, 45, 360, 360, 360, 27, 36, 360, 45, 180, 360, 225, 360, 225, 225, 360, 180, 45, 360, 18, 225, 225, 225, 225, 180, 225, 361];
        WEIGHTS[2][1] = [875, 1269, 779, 779, 779, 779, 779, 779, 779, 779, 779, 779, 17, 8, 41];
        WEIGHTS[2][2] = [303, 303, 303, 303, 151, 30, 0, 0, 151, 151, 151, 151, 30, 303, 151, 30, 303, 303, 303, 303, 303, 303, 30, 151, 303, 303, 303, 303, 303, 303, 303, 303, 3066];
        WEIGHTS[2][3] = [645, 0, 1290, 322, 645, 645, 645, 967, 322, 967, 645, 967, 967, 973];
        WEIGHTS[2][4] = [2500, 2500, 2500, 0, 0, 0, 0, 0, 0, 2500, 0];
        WEIGHTS[2][5] = [0, 0, 0, 0, 0, 0, 588, 588, 588, 588, 588, 0, 0, 588, 0, 0, 588, 0, 0, 0, 0, 0, 588, 0, 0, 0, 0, 588, 0, 0, 0, 588, 588, 0, 0, 0, 588, 0, 0, 0, 0, 588, 0, 0, 0, 0, 0, 0, 0, 0, 0, 588, 0, 0, 0, 0, 588, 0, 0, 0, 0, 588, 0, 0, 0, 0, 0, 0, 0, 0, 588, 0, 0, 4];
        WEIGHTS[2][6] = [925, 555, 185, 555, 925, 925, 185, 1296, 1296, 1296, 1857];
        WEIGHTS[2][7] = [88, 88, 88, 88, 88, 265, 442, 8853];
        WEIGHTS[2][8] = [183, 274, 274, 18, 18, 27, 36, 9170];
        WEIGHTS[2][9] = [340, 340, 340, 340, 340, 340, 34, 340, 340, 340, 340, 170, 170, 170, 102, 238, 238, 238, 272, 340, 340, 340, 272, 238, 238, 238, 238, 170, 34, 340, 340, 136, 340, 340, 340, 340, 344];
        WEIGHTS[2][10] = [217, 362, 217, 144, 72, 289, 144, 362, 72, 289, 217, 362, 72, 362, 362, 289, 0, 217, 0, 72, 144, 7, 217, 72, 217, 217, 289, 217, 289, 362, 217, 362, 3269];
        WEIGHTS[2][11] = [139, 278, 278, 250, 250, 194, 222, 278, 278, 194, 222, 83, 222, 278, 139, 139, 27, 278, 278, 278, 278, 27, 278, 139, 278, 278, 278, 278, 278, 278, 278, 278, 278, 278, 278, 27, 139, 139, 139, 139, 0, 278, 194, 83, 83, 278, 83, 27, 306];
        WEIGHTS[2][12] = [981, 2945, 654, 16, 981, 327, 654, 163, 3279];
    }

    function setLayers(LayerInput[] calldata toSet) external onlyOwner {

        for (uint16 i = 0; i < toSet.length; i++) {
            layers[toSet[i].layerIndex][toSet[i].itemIndex] = Layer(toSet[i].name, toSet[i].hexString);
        }
    }

    function getLayer(uint8 layerIndex, uint8 itemIndex) public view returns (Layer memory) {

        return layers[layerIndex][itemIndex];
    }

    function getRaceIndex(uint16 _dna) public view returns (uint8) {

        uint16 lowerBound;
        uint16 percentage;
        for (uint8 i; i < WEIGHTS[0][1].length; i++) {
            percentage = WEIGHTS[0][1][i];
            if (_dna >= lowerBound && _dna < lowerBound + percentage) {
                if (i == 1) {
                    return 2;
                } else if (i > 11) {
                    return 1;
                } else {
                    return 0;
                }
            }
            lowerBound += percentage;
        }
        revert();
    }

    function getLayerIndex(uint16 _dna, uint8 _index, uint16 _raceIndex) public view returns (uint) {

        uint16 lowerBound;
        uint16 percentage;
        for (uint8 i; i < WEIGHTS[_raceIndex][_index].length; i++) {
            percentage = WEIGHTS[_raceIndex][_index][i];
            if (_dna >= lowerBound && _dna < lowerBound + percentage) {
                return i;
            }
            lowerBound += percentage;
        }
        return WEIGHTS[_raceIndex][_index].length;
    }

    function tokenURI(uint256 tokenId, ChainRunnersTypes.ChainRunner memory runnerData) public view returns (string memory) {

        (Layer [NUM_LAYERS] memory tokenLayers, Color [NUM_COLORS][NUM_LAYERS] memory tokenPalettes, uint8 numTokenLayers, string[NUM_LAYERS] memory traitTypes) = getTokenData(runnerData.dna);
        string memory attributes;
        for (uint8 i = 0; i < numTokenLayers; i++) {
            attributes = string(abi.encodePacked(attributes,
                bytes(attributes).length == 0 ? 'eyAg' : 'LCB7',
                'InRyYWl0X3R5cGUiOiAi', traitTypes[i], 'IiwidmFsdWUiOiAi', tokenLayers[i].name, 'IiB9'
                ));
        }
        string[4] memory svgBuffers = tokenSVGBuffer(tokenLayers, tokenPalettes, numTokenLayers);
        return string(abi.encodePacked(
                'data:application/json;base64,eyAgImltYWdlX2RhdGEiOiAiPHN2ZyB2ZXJzaW9uPScxLjEnIHZpZXdCb3g9JzAgMCAzMjAgMzIwJyB4bWxucz0naHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmcnIHNoYXBlLXJlbmRlcmluZz0nY3Jpc3BFZGdlcyc+',
                svgBuffers[0], svgBuffers[1], svgBuffers[2], svgBuffers[3],
                'PHN0eWxlPnJlY3R7d2lkdGg6MTBweDtoZWlnaHQ6MTBweDt9PC9zdHlsZT48L3N2Zz4gIiwgImF0dHJpYnV0ZXMiOiBb',
                attributes,
                'XSwgICAibmFtZSI6IlJ1bm5lciAj',
                Base64.encode(uintToByteString(tokenId, 6)),
                'IiwgImRlc2NyaXB0aW9uIjogIkNoYWluIFJ1bm5lcnMgYXJlIE1lZ2EgQ2l0eSByZW5lZ2FkZXMgMTAwJSBnZW5lcmF0ZWQgb24gY2hhaW4uIn0g'
            ));
    }

    function tokenSVG(uint256 _dna) public view returns (string memory) {

        (Layer [NUM_LAYERS] memory tokenLayers, Color [NUM_COLORS][NUM_LAYERS] memory tokenPalettes, uint8 numTokenLayers, string[NUM_LAYERS] memory traitTypes) = getTokenData(_dna);
        string[4] memory buffer256 = tokenSVGBuffer(tokenLayers, tokenPalettes, numTokenLayers);
        return string(abi.encodePacked(
                "PHN2ZyB2ZXJzaW9uPScxLjEnIHZpZXdCb3g9JzAgMCAzMiAzMicgeG1sbnM9J2h0dHA6Ly93d3cudzMub3JnLzIwMDAvc3ZnJyBzaGFwZS1yZW5kZXJpbmc9J2NyaXNwRWRnZXMnIGhlaWdodD0nMTAwJScgd2lkdGg9JzEwMCUnICA+",
                buffer256[0], buffer256[1], buffer256[2], buffer256[3],
                "PHN0eWxlPnJlY3R7d2lkdGg6MXB4O2hlaWdodDoxcHg7fTwvc3R5bGU+PC9zdmc+"
            )
        );
    }

    function getTokenData(uint256 _dna) public view returns (Layer [NUM_LAYERS] memory tokenLayers, Color [NUM_COLORS][NUM_LAYERS] memory tokenPalettes, uint8 numTokenLayers, string [NUM_LAYERS] memory traitTypes) {

        uint16[NUM_LAYERS] memory dna = splitNumber(_dna);
        uint16 raceIndex = getRaceIndex(dna[1]);

        bool hasFaceAcc = dna[7] < (10000 - WEIGHTS[raceIndex][7][7]);
        bool hasMask = dna[8] < (10000 - WEIGHTS[raceIndex][8][7]);
        bool hasHeadBelow = dna[9] < (10000 - WEIGHTS[raceIndex][9][36]);
        bool hasHeadAbove = dna[11] < (10000 - WEIGHTS[raceIndex][11][48]);
        bool useHeadAbove = (dna[0] % 2) > 0;
        for (uint8 i = 0; i < NUM_LAYERS; i ++) {
            Layer memory layer = layers[i][getLayerIndex(dna[i], i, raceIndex)];
            if (layer.hexString.length > 0) {
                if (((i == 2 || i == 12) && !hasMask && !hasFaceAcc) || (i == 7 && !hasMask) || (i == 10 && !hasMask) || (i < 2 || (i > 2 && i < 7) || i == 8 || i == 9 || i == 11)) {
                    if (hasHeadBelow && hasHeadAbove && (i == 9 && useHeadAbove) || (i == 11 && !useHeadAbove)) continue;
                    tokenLayers[numTokenLayers] = layer;
                    tokenPalettes[numTokenLayers] = palette(tokenLayers[numTokenLayers].hexString);
                    traitTypes[numTokenLayers] = ["QmFja2dyb3VuZCAg","UmFjZSAg","RmFjZSAg","TW91dGgg","Tm9zZSAg","RXllcyAg","RWFyIEFjY2Vzc29yeSAg","RmFjZSBBY2Nlc3Nvcnkg","TWFzayAg","SGVhZCBCZWxvdyAg","RXllIEFjY2Vzc29yeSAg","SGVhZCBBYm92ZSAg","TW91dGggQWNjZXNzb3J5"][i];
                    numTokenLayers++;
                }
            }
        }
        return (tokenLayers, tokenPalettes, numTokenLayers, traitTypes);
    }

    function tokenSVGBuffer(Layer [NUM_LAYERS] memory tokenLayers, Color [NUM_COLORS][NUM_LAYERS] memory tokenPalettes, uint8 numTokenLayers) public pure returns (string[4] memory) {

        string[32] memory lookup = ["MDAw", "MDEw", "MDIw", "MDMw", "MDQw", "MDUw", "MDYw", "MDcw", "MDgw", "MDkw", "MTAw", "MTEw", "MTIw", "MTMw", "MTQw", "MTUw", "MTYw", "MTcw", "MTgw", "MTkw", "MjAw", "MjEw", "MjIw", "MjMw", "MjQw", "MjUw", "MjYw", "Mjcw", "Mjgw", "Mjkw", "MzAw", "MzEw"];
        SVGCursor memory cursor;

        Buffer memory buffer4;
        string[8] memory buffer32;
        string[4] memory buffer256;
        uint8 buffer32count;
        uint8 buffer256count;
        for (uint k = 32; k < 416;) {
            cursor.color1 = colorForIndex(tokenLayers, k, 0, tokenPalettes, numTokenLayers);
            cursor.color2 = colorForIndex(tokenLayers, k, 1, tokenPalettes, numTokenLayers);
            cursor.color3 = colorForIndex(tokenLayers, k, 2, tokenPalettes, numTokenLayers);
            cursor.color4 = colorForIndex(tokenLayers, k, 3, tokenPalettes, numTokenLayers);
            buffer4.one = pixel4(lookup, cursor);
            cursor.x += 4;

            cursor.color1 = colorForIndex(tokenLayers, k, 4, tokenPalettes, numTokenLayers);
            cursor.color2 = colorForIndex(tokenLayers, k, 5, tokenPalettes, numTokenLayers);
            cursor.color3 = colorForIndex(tokenLayers, k, 6, tokenPalettes, numTokenLayers);
            cursor.color4 = colorForIndex(tokenLayers, k, 7, tokenPalettes, numTokenLayers);
            buffer4.two = pixel4(lookup, cursor);
            cursor.x += 4;

            k += 3;

            cursor.color1 = colorForIndex(tokenLayers, k, 0, tokenPalettes, numTokenLayers);
            cursor.color2 = colorForIndex(tokenLayers, k, 1, tokenPalettes, numTokenLayers);
            cursor.color3 = colorForIndex(tokenLayers, k, 2, tokenPalettes, numTokenLayers);
            cursor.color4 = colorForIndex(tokenLayers, k, 3, tokenPalettes, numTokenLayers);
            buffer4.three = pixel4(lookup, cursor);
            cursor.x += 4;

            cursor.color1 = colorForIndex(tokenLayers, k, 4, tokenPalettes, numTokenLayers);
            cursor.color2 = colorForIndex(tokenLayers, k, 5, tokenPalettes, numTokenLayers);
            cursor.color3 = colorForIndex(tokenLayers, k, 6, tokenPalettes, numTokenLayers);
            cursor.color4 = colorForIndex(tokenLayers, k, 7, tokenPalettes, numTokenLayers);
            buffer4.four = pixel4(lookup, cursor);
            cursor.x += 4;

            k += 3;

            cursor.color1 = colorForIndex(tokenLayers, k, 0, tokenPalettes, numTokenLayers);
            cursor.color2 = colorForIndex(tokenLayers, k, 1, tokenPalettes, numTokenLayers);
            cursor.color3 = colorForIndex(tokenLayers, k, 2, tokenPalettes, numTokenLayers);
            cursor.color4 = colorForIndex(tokenLayers, k, 3, tokenPalettes, numTokenLayers);
            buffer4.five = pixel4(lookup, cursor);
            cursor.x += 4;

            cursor.color1 = colorForIndex(tokenLayers, k, 4, tokenPalettes, numTokenLayers);
            cursor.color2 = colorForIndex(tokenLayers, k, 5, tokenPalettes, numTokenLayers);
            cursor.color3 = colorForIndex(tokenLayers, k, 6, tokenPalettes, numTokenLayers);
            cursor.color4 = colorForIndex(tokenLayers, k, 7, tokenPalettes, numTokenLayers);
            buffer4.six = pixel4(lookup, cursor);
            cursor.x += 4;

            k += 3;

            cursor.color1 = colorForIndex(tokenLayers, k, 0, tokenPalettes, numTokenLayers);
            cursor.color2 = colorForIndex(tokenLayers, k, 1, tokenPalettes, numTokenLayers);
            cursor.color3 = colorForIndex(tokenLayers, k, 2, tokenPalettes, numTokenLayers);
            cursor.color4 = colorForIndex(tokenLayers, k, 3, tokenPalettes, numTokenLayers);
            buffer4.seven = pixel4(lookup, cursor);
            cursor.x += 4;

            cursor.color1 = colorForIndex(tokenLayers, k, 4, tokenPalettes, numTokenLayers);
            cursor.color2 = colorForIndex(tokenLayers, k, 5, tokenPalettes, numTokenLayers);
            cursor.color3 = colorForIndex(tokenLayers, k, 6, tokenPalettes, numTokenLayers);
            cursor.color4 = colorForIndex(tokenLayers, k, 7, tokenPalettes, numTokenLayers);
            buffer4.eight = pixel4(lookup, cursor);
            cursor.x += 4;

            k += 3;

            buffer32[buffer32count++] = string(abi.encodePacked(buffer4.one, buffer4.two, buffer4.three, buffer4.four, buffer4.five, buffer4.six, buffer4.seven, buffer4.eight));
            cursor.x = 0;
            cursor.y += 1;
            if (buffer32count >= 8) {
                buffer256[buffer256count++] = string(abi.encodePacked(buffer32[0], buffer32[1], buffer32[2], buffer32[3], buffer32[4], buffer32[5], buffer32[6], buffer32[7]));
                buffer32count = 0;
            }
        }
        return buffer256;
    }

    function palette(bytes memory data) internal pure returns (Color [NUM_COLORS] memory) {

        Color [NUM_COLORS] memory colors;
        for (uint16 i = 0; i < NUM_COLORS; i++) {
            colors[i].hexString = Base64.encode(bytes(abi.encodePacked(
                    byteToHexString(data[i * 4]),
                    byteToHexString(data[i * 4 + 1]),
                    byteToHexString(data[i * 4 + 2])
                )));
            colors[i].red = byteToUint(data[i * 4]);
            colors[i].green = byteToUint(data[i * 4 + 1]);
            colors[i].blue = byteToUint(data[i * 4 + 2]);
            colors[i].alpha = byteToUint(data[i * 4 + 3]);
        }
        return colors;
    }

    function colorForIndex(Layer[NUM_LAYERS] memory tokenLayers, uint k, uint index, Color [NUM_COLORS][NUM_LAYERS] memory palettes, uint numTokenLayers) internal pure returns (string memory) {

        for (uint256 i = numTokenLayers - 1; i >= 0; i--) {
            Color memory fg = palettes[i][colorIndex(tokenLayers[i].hexString, k, index)];
            if (fg.alpha == 0) {
                continue;
            } else if (fg.alpha == 255) {
                return fg.hexString;
            } else {
                for (uint256 j = i - 1; j >= 0; j--) {
                    Color memory bg = palettes[j][colorIndex(tokenLayers[j].hexString, k, index)];
                    if (bg.alpha > 0) {
                        return Base64.encode(bytes(blendColors(fg, bg)));
                    }
                }
            }
        }
        return "000000";
    }

    function colorIndex(bytes memory data, uint k, uint index) internal pure returns (uint8) {

        if (index == 0) {
            return uint8(data[k]) >> 5;
        } else if (index == 1) {
            return (uint8(data[k]) >> 2) % 8;
        } else if (index == 2) {
            return ((uint8(data[k]) % 4) * 2) + (uint8(data[k + 1]) >> 7);
        } else if (index == 3) {
            return (uint8(data[k + 1]) >> 4) % 8;
        } else if (index == 4) {
            return (uint8(data[k + 1]) >> 1) % 8;
        } else if (index == 5) {
            return ((uint8(data[k + 1]) % 2) * 4) + (uint8(data[k + 2]) >> 6);
        } else if (index == 6) {
            return (uint8(data[k + 2]) >> 3) % 8;
        } else {
            return uint8(data[k + 2]) % 8;
        }
    }

    function pixel4(string[32] memory lookup, SVGCursor memory cursor) internal pure returns (string memory result) {

        return string(abi.encodePacked(
                "PHJlY3QgICBmaWxsPScj", cursor.color1, "JyAgeD0n", lookup[cursor.x], "JyAgeT0n", lookup[cursor.y],
                "JyAvPjxyZWN0ICBmaWxsPScj", cursor.color2, "JyAgeD0n", lookup[cursor.x + 1], "JyAgeT0n", lookup[cursor.y],
                "JyAvPjxyZWN0ICBmaWxsPScj", cursor.color3, "JyAgeD0n", lookup[cursor.x + 2], "JyAgeT0n", lookup[cursor.y],
                "JyAvPjxyZWN0ICBmaWxsPScj", cursor.color4, "JyAgeD0n", lookup[cursor.x + 3], "JyAgeT0n", lookup[cursor.y], "JyAgIC8+"
            ));
    }

    function blendColors(Color memory fg, Color memory bg) internal pure returns (string memory) {

        uint alpha = uint16(fg.alpha + 1);
        uint inv_alpha = uint16(256 - fg.alpha);
        return uintToHexString6(uint24((alpha * fg.blue + inv_alpha * bg.blue) >> 8) + (uint24((alpha * fg.green + inv_alpha * bg.green) >> 8) << 8) + (uint24((alpha * fg.red + inv_alpha * bg.red) >> 8) << 16));
    }

    function splitNumber(uint256 _number) internal pure returns (uint16[NUM_LAYERS] memory numbers) {

        for (uint256 i = 0; i < numbers.length; i++) {
            numbers[i] = uint16(_number % 10000);
            _number >>= 14;
        }
        return numbers;
    }

    function uintToHexDigit(uint8 d) public pure returns (bytes1) {

        if (0 <= d && d <= 9) {
            return bytes1(uint8(bytes1('0')) + d);
        } else if (10 <= uint8(d) && uint8(d) <= 15) {
            return bytes1(uint8(bytes1('a')) + d - 10);
        }
        revert();
    }

    function uintToHexString6(uint a) public pure returns (string memory) {

        string memory str = uintToHexString2(a);
        if (bytes(str).length == 2) {
            return string(abi.encodePacked("0000", str));
        } else if (bytes(str).length == 3) {
            return string(abi.encodePacked("000", str));
        } else if (bytes(str).length == 4) {
            return string(abi.encodePacked("00", str));
        } else if (bytes(str).length == 5) {
            return string(abi.encodePacked("0", str));
        }
        return str;
    }

    function uintToHexString2(uint a) public pure returns (string memory) {

        uint count = 0;
        uint b = a;
        while (b != 0) {
            count++;
            b /= 16;
        }
        bytes memory res = new bytes(count);
        for (uint i = 0; i < count; ++i) {
            b = a % 16;
            res[count - i - 1] = uintToHexDigit(uint8(b));
            a /= 16;
        }

        string memory str = string(res);
        if (bytes(str).length == 0) {
            return "00";
        } else if (bytes(str).length == 1) {
            return string(abi.encodePacked("0", str));
        }
        return str;
    }

    function uintToByteString(uint a, uint fixedLen) internal pure returns (bytes memory _uintAsString) {

        uint j = a;
        uint len;
        while (j != 0) {
            len++;
            j /= 10;
        }
        bytes memory bstr = new bytes(fixedLen);
        j = fixedLen;
        if (a == 0) {
            bstr[0] = "0";
            len = 1;
        }
        while (j > len) {
            j = j - 1;
            bstr[j] = bytes1(' ');
        }
        uint k = len;
        while (a != 0) {
            k = k - 1;
            uint8 temp = (48 + uint8(a - a / 10 * 10));
            bytes1 b1 = bytes1(temp);
            bstr[k] = b1;
            a /= 10;
        }
        return bstr;
    }

    function byteToUint(bytes1 b) public pure returns (uint) {

        return uint(uint8(b));
    }

    function byteToHexString(bytes1 b) public pure returns (string memory) {

        return uintToHexString2(byteToUint(b));
    }
}

library Base64 {

    bytes internal constant TABLE = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/";

    function encode(bytes memory data) internal pure returns (string memory) {

        uint256 len = data.length;
        if (len == 0) return "";

        uint256 encodedLen = 4 * ((len + 2) / 3);

        bytes memory result = new bytes(encodedLen + 32);

        bytes memory table = TABLE;

        assembly {
            let tablePtr := add(table, 1)
            let resultPtr := add(result, 32)

            for {
                let i := 0
            } lt(i, len) {

            } {
                i := add(i, 3)
                let input := and(mload(add(data, i)), 0xffffff)

                let out := mload(add(tablePtr, and(shr(18, input), 0x3F)))
                out := shl(8, out)
                out := add(out, and(mload(add(tablePtr, and(shr(12, input), 0x3F))), 0xFF))
                out := shl(8, out)
                out := add(out, and(mload(add(tablePtr, and(shr(6, input), 0x3F))), 0xFF))
                out := shl(8, out)
                out := add(out, and(mload(add(tablePtr, and(input, 0x3F))), 0xFF))
                out := shl(224, out)

                mstore(resultPtr, out)

                resultPtr := add(resultPtr, 4)
            }

            switch mod(len, 3)
            case 1 {
                mstore(sub(resultPtr, 2), shl(240, 0x3d3d))
            }
            case 2 {
                mstore(sub(resultPtr, 1), shl(248, 0x3d))
            }

            mstore(result, encodedLen)
        }

        return string(result);
    }
}// MIT
pragma solidity 0.8.4;



contract ChainRunnersXRBaseRenderer is Ownable, ReentrancyGuard {

    event SetBodyType(address indexed owner, uint8 indexed to, uint256 indexed tokenId);

    uint256 public constant NUM_LAYERS = 13;
    uint256 public constant NUM_COLORS = 8;

    address public genesisRendererContractAddress;
    address public xrContractAddress;
    string public baseImageURI;
    string public baseAnimationURI;
    string public baseModelURI;
    string public modelStandardName;
    string public modelExtensionName;
    string public modelFileType;

    uint16[][NUM_LAYERS][3] WEIGHTS;

    struct BodyTypeOverride {
        bool isSet;
        uint8 id;
    }

    mapping(uint256 => BodyTypeOverride) bodyTypeOverrides;

    constructor(
        address genesisRendererContractAddress_
    ) {
        genesisRendererContractAddress = genesisRendererContractAddress_;


        WEIGHTS[0][0] = [36, 225, 225, 225, 360, 135, 27, 360, 315, 315, 315, 315, 225, 180, 225, 180, 360, 180, 45, 360, 360, 360, 27, 36, 360, 45, 180, 360, 225, 360, 225, 225, 360, 180, 45, 360, 18, 225, 225, 225, 225, 180, 225, 361];
        WEIGHTS[0][1] = [875, 1269, 779, 779, 779, 779, 779, 779, 779, 779, 779, 779, 17, 8, 41];
        WEIGHTS[0][2] = [172, 172, 172, 172, 86, 17, 0, 0, 86, 86, 86, 86, 17, 172, 86, 17, 172, 172, 172, 172, 172, 172, 17, 86, 172, 172, 172, 172, 172, 172, 172, 172, 6062];
        WEIGHTS[0][3] = [645, 0, 1290, 322, 645, 645, 645, 967, 322, 967, 645, 967, 967, 973];
        WEIGHTS[0][4] = [0, 0, 0, 1250, 1250, 1250, 1250, 1250, 1250, 1250, 1250];
        WEIGHTS[0][5] = [121, 121, 121, 121, 121, 121, 243, 0, 0, 0, 0, 121, 121, 243, 121, 121, 243, 121, 121, 121, 121, 121, 243, 121, 121, 121, 121, 243, 121, 121, 121, 121, 243, 121, 121, 121, 243, 121, 121, 121, 121, 243, 121, 121, 121, 121, 243, 121, 121, 121, 121, 243, 121, 121, 121, 121, 243, 121, 121, 121, 121, 243, 121, 121, 243, 0, 0, 0, 121, 121, 243, 121, 121, 306];
        WEIGHTS[0][6] = [833, 555, 138, 416, 694, 416, 138, 1111, 1111, 1111, 3477];
        WEIGHTS[0][7] = [88, 88, 88, 88, 88, 265, 442, 8853];
        WEIGHTS[0][8] = [189, 189, 47, 18, 9, 28, 37, 9483];
        WEIGHTS[0][9] = [340, 340, 340, 340, 340, 340, 34, 340, 340, 340, 340, 170, 170, 170, 102, 238, 238, 238, 272, 340, 340, 340, 272, 238, 238, 238, 238, 170, 34, 340, 340, 136, 340, 340, 340, 340, 344];
        WEIGHTS[0][10] = [159, 212, 106, 53, 26, 159, 53, 265, 53, 212, 159, 265, 53, 265, 265, 212, 53, 159, 239, 53, 106, 5, 106, 53, 212, 212, 106, 159, 212, 265, 212, 265, 5066];
        WEIGHTS[0][11] = [139, 278, 278, 250, 250, 194, 222, 278, 278, 194, 222, 83, 222, 278, 139, 139, 27, 278, 278, 278, 278, 27, 278, 139, 278, 278, 278, 278, 278, 278, 278, 278, 278, 278, 278, 27, 139, 139, 139, 139, 0, 278, 194, 83, 83, 278, 83, 27, 306];
        WEIGHTS[0][12] = [548, 1097, 182, 11, 274, 91, 365, 114, 7318];

        WEIGHTS[1][0] = [36, 225, 225, 225, 360, 135, 27, 360, 315, 315, 315, 315, 225, 180, 225, 180, 360, 180, 45, 360, 360, 360, 27, 36, 360, 45, 180, 360, 225, 360, 225, 225, 360, 180, 45, 360, 18, 225, 225, 225, 225, 180, 225, 361];
        WEIGHTS[1][1] = [875, 1269, 779, 779, 779, 779, 779, 779, 779, 779, 779, 779, 17, 8, 41];
        WEIGHTS[1][2] = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 10000];
        WEIGHTS[1][3] = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0];
        WEIGHTS[1][4] = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0];
        WEIGHTS[1][5] = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 384, 7692, 1923, 0, 0, 0, 0, 0, 1];
        WEIGHTS[1][6] = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 10000];
        WEIGHTS[1][7] = [0, 0, 0, 0, 0, 909, 0, 9091];
        WEIGHTS[1][8] = [0, 0, 0, 0, 0, 0, 0, 10000];
        WEIGHTS[1][9] = [526, 526, 526, 0, 0, 0, 0, 0, 526, 0, 0, 0, 526, 0, 526, 0, 0, 0, 526, 526, 526, 526, 526, 526, 526, 526, 526, 526, 526, 0, 0, 526, 0, 0, 0, 0, 532];
        WEIGHTS[1][10] = [80, 0, 400, 240, 80, 0, 240, 0, 0, 80, 80, 80, 0, 0, 0, 0, 80, 80, 0, 0, 80, 80, 0, 80, 80, 80, 80, 80, 0, 0, 0, 0, 8000];
        WEIGHTS[1][11] = [289, 0, 0, 0, 0, 404, 462, 578, 578, 0, 462, 173, 462, 578, 0, 0, 57, 0, 57, 0, 57, 57, 578, 289, 578, 57, 0, 57, 57, 57, 578, 578, 0, 0, 0, 0, 0, 0, 57, 289, 578, 0, 0, 0, 231, 57, 0, 0, 1745];
        WEIGHTS[1][12] = [666, 666, 666, 0, 666, 0, 0, 0, 7336];

        WEIGHTS[2][0] = [36, 225, 225, 225, 360, 135, 27, 360, 315, 315, 315, 315, 225, 180, 225, 180, 360, 180, 45, 360, 360, 360, 27, 36, 360, 45, 180, 360, 225, 360, 225, 225, 360, 180, 45, 360, 18, 225, 225, 225, 225, 180, 225, 361];
        WEIGHTS[2][1] = [875, 1269, 779, 779, 779, 779, 779, 779, 779, 779, 779, 779, 17, 8, 41];
        WEIGHTS[2][2] = [172, 172, 172, 172, 86, 17, 0, 0, 86, 86, 86, 86, 17, 172, 86, 17, 172, 172, 172, 172, 172, 172, 17, 86, 172, 172, 172, 172, 172, 172, 172, 172, 6062];
        WEIGHTS[2][3] = [645, 0, 1290, 322, 645, 645, 645, 967, 322, 967, 645, 967, 967, 973];
        WEIGHTS[2][4] = [2500, 2500, 2500, 0, 0, 0, 0, 0, 0, 2500, 0];
        WEIGHTS[2][5] = [0, 0, 0, 0, 0, 0, 588, 588, 588, 588, 588, 0, 0, 588, 0, 0, 588, 0, 0, 0, 0, 0, 588, 0, 0, 0, 0, 588, 0, 0, 0, 588, 588, 0, 0, 0, 588, 0, 0, 0, 0, 588, 0, 0, 0, 0, 0, 0, 0, 0, 0, 588, 0, 0, 0, 0, 588, 0, 0, 0, 0, 588, 0, 0, 0, 0, 0, 0, 0, 0, 588, 0, 0, 4];
        WEIGHTS[2][6] = [833, 555, 138, 416, 694, 416, 138, 1111, 1111, 1111, 3477];
        WEIGHTS[2][7] = [88, 88, 88, 88, 88, 265, 442, 8853];
        WEIGHTS[2][8] = [183, 274, 274, 18, 18, 27, 36, 9170];
        WEIGHTS[2][9] = [340, 340, 340, 340, 340, 340, 34, 340, 340, 340, 340, 170, 170, 170, 102, 238, 238, 238, 272, 340, 340, 340, 272, 238, 238, 238, 238, 170, 34, 340, 340, 136, 340, 340, 340, 340, 344];
        WEIGHTS[2][10] = [217, 362, 217, 144, 72, 289, 144, 362, 72, 289, 217, 362, 72, 362, 362, 289, 0, 217, 0, 72, 144, 7, 217, 72, 217, 217, 289, 217, 289, 362, 217, 362, 3269];
        WEIGHTS[2][11] = [139, 278, 278, 250, 250, 194, 222, 278, 278, 194, 222, 83, 222, 278, 139, 139, 27, 278, 278, 278, 278, 27, 278, 139, 278, 278, 278, 278, 278, 278, 278, 278, 278, 278, 278, 27, 139, 139, 139, 139, 0, 278, 194, 83, 83, 278, 83, 27, 306];
        WEIGHTS[2][12] = [548, 1097, 182, 11, 274, 91, 365, 114, 7318];
    }

    function getRaceIndex(uint16 _dna) public view returns (uint8) {

        uint16 lowerBound;
        uint16 percentage;
        for (uint8 i; i < WEIGHTS[0][1].length; i++) {
            percentage = WEIGHTS[0][1][i];
            if (_dna >= lowerBound && _dna < lowerBound + percentage) {
                if (i == 1) {
                    return 2;
                } else if (i > 11) {
                    return 1;
                } else {
                    return 0;
                }
            }
            lowerBound += percentage;
        }
        revert();
    }

    function getLayerIndex(uint16 _dna, uint8 _index, uint16 _raceIndex) public view returns (uint) {

        uint16 lowerBound;
        uint16 percentage;
        for (uint8 i; i < WEIGHTS[_raceIndex][_index].length; i++) {
            percentage = WEIGHTS[_raceIndex][_index][i];
            if (_dna >= lowerBound && _dna < lowerBound + percentage) {
                return i;
            }
            lowerBound += percentage;
        }
        return WEIGHTS[_raceIndex][_index].length;
    }

    function _baseImageURI() internal view virtual returns (string memory) {

        return baseImageURI;
    }

    function setBaseImageURI(string calldata _baseImageURI) external onlyOwner {

        baseImageURI = _baseImageURI;
    }

    function _baseAnimationURI() internal view virtual returns (string memory) {

        return baseAnimationURI;
    }

    function setBaseAnimationURI(string calldata _baseAnimationURI) external onlyOwner {

        baseAnimationURI = _baseAnimationURI;
    }

    function _baseModelURI() internal view virtual returns (string memory) {

        return baseModelURI;
    }

    function setBaseModelURI(string calldata _baseModelURI) external onlyOwner {

        baseModelURI = _baseModelURI;
    }

    function _modelStandardName() internal view virtual returns (string memory) {

        return bytes(modelStandardName).length > 0 ? modelStandardName : 'EIP-XXXX';
    }

    function setModelStandardName(string calldata _modelStandardName) external onlyOwner {

        modelStandardName = _modelStandardName;
    }

    function _modelExtensionName() internal view virtual returns (string memory) {

        return bytes(modelExtensionName).length > 0 ? modelExtensionName : 'NIMDE-1';
    }

    function setModelExtensionName(string calldata _modelExtensionName) external onlyOwner {

        modelExtensionName = _modelExtensionName;
    }

    function _modelFileType() internal view virtual returns (string memory) {

        return bytes(modelFileType).length > 0 ? modelFileType : 'model/fbx';
    }

    function setModelFileType(string calldata _modelFileType) external onlyOwner {

        modelFileType = _modelFileType;
    }

    function _xrContractAddress() public view returns (address) {

        return xrContractAddress;
    }

    function setXRContractAddress(address _xrContractAddress) external onlyOwner {

        xrContractAddress = _xrContractAddress;
    }

    function setBodyTypeOverride(uint256 _tokenId, uint8 _bodyTypeId) external {

        IERC721 xrContract = IERC721(_xrContractAddress());
        require(xrContract.ownerOf(_tokenId) == msg.sender, "not the owner of token");

        bodyTypeOverrides[_tokenId] = BodyTypeOverride(true, _bodyTypeId % 2);

        emit SetBodyType(msg.sender, bodyTypeOverrides[_tokenId].id, _tokenId);
    }

    function tokenURI(uint256 _tokenId, ChainRunnersTypes.ChainRunner memory _runnerData) public view returns (string memory) {

        if (_tokenId <= 10000) {
            return genesisXRTokenURI(_tokenId, _runnerData.dna);
        }
        (ChainRunnersBaseRenderer.Layer [NUM_LAYERS] memory tokenLayers, ChainRunnersBaseRenderer.Color [NUM_COLORS][NUM_LAYERS] memory tokenPalettes, uint8 numTokenLayers, string[NUM_LAYERS] memory traitTypes) = getXRTokenData(_runnerData.dna);
        return base64TokenMetadata(_tokenId, tokenLayers, numTokenLayers, traitTypes, _runnerData.dna);
    }

    function genesisXRTokenURI(uint256 _tokenId, uint256 _dna) public view returns (string memory) {

        ChainRunnersBaseRenderer genesisRendererContract = ChainRunnersBaseRenderer(genesisRendererContractAddress);
        (ChainRunnersBaseRenderer.Layer [NUM_LAYERS] memory tokenLayers, ChainRunnersBaseRenderer.Color [NUM_COLORS][NUM_LAYERS] memory tokenPalettes, uint8 numTokenLayers, string[NUM_LAYERS] memory traitTypes) = genesisRendererContract.getTokenData(_dna);
        return base64TokenMetadata(_tokenId, tokenLayers, numTokenLayers, traitTypes, _dna);
    }

    function base64TokenMetadata(uint256 _tokenId,
        ChainRunnersBaseRenderer.Layer [NUM_LAYERS] memory _tokenLayers,
        uint8 _numTokenLayers,
        string[NUM_LAYERS] memory _traitTypes,
        uint256 _dna) public view returns (string memory) {


        string memory attributes;
        for (uint8 i = 0; i < _numTokenLayers; i++) {
            attributes = string(abi.encodePacked(attributes,
                bytes(attributes).length == 0 ? 'eyAg' : 'LCB7',
                'InRyYWl0X3R5cGUiOiAi', _traitTypes[i], 'IiwidmFsdWUiOiAi', _tokenLayers[i].name, 'IiB9'
                ));
        }
        string memory baseFileName = getBaseFileName(_tokenId, _dna);
        return string(abi.encodePacked(
                'data:application/json;base64,eyAiaW1hZ2UiOiAi',
                getBase64ImageURI(baseFileName),
                getBase64AnimationURI(baseFileName),
                'IiwgImF0dHJpYnV0ZXMiOiBb',
                attributes,
                'XSwgICAibmFtZSI6IlJ1bm5lciAj',
                getBase64TokenString(_tokenId),
                getBase64ModelMetadata(baseFileName),
                'LCAiZGVzY3JpcHRpb24iOiAiQ2hhaW4gUnVubmVycyBYUiBhcmUgM0QgTWVnYSBDaXR5IHJlbmVnYWRlcy4gIn0g'
            ));
    }

    function getBaseFileName(uint256 _tokenId, uint256 _dna) public view returns (string memory) {

        uint8 bodyTypeId = getBodyType(_tokenId, _dna);
        return string(abi.encodePacked(Strings.toString(_dna), '_', Strings.toString(bodyTypeId)));
    }

    function getBodyType(uint256 _tokenId, uint256 _dna) public view returns (uint8) {

        BodyTypeOverride memory bodyTypeOverride = bodyTypeOverrides[_tokenId];
        if (bodyTypeOverride.isSet) {
            return bodyTypeOverride.id;
        }
        return uint8((_dna & (uint256(1111111) << (14 * NUM_LAYERS))) >> (14 * NUM_LAYERS)) % 2;
    }

    function getBase64TokenString(uint256 _tokenId) public view returns (string memory) {

        return Base64.encode(uintToByteString(_tokenId, 6));
    }

    function getBase64ImageURI(string memory _baseFileName) public view returns (string memory) {

        return Base64.encode(padStringBytes(abi.encodePacked(_baseImageURI(), _baseFileName), 3));
    }

    function getBase64AnimationURI(string memory _baseFileName) public view returns (string memory) {

        return bytes(_baseImageURI()).length > 0
            ? string(abi.encodePacked('IiwgImFuaW1hdGlvbl91cmwiOiAi', Base64.encode(bytes(padString(string(abi.encodePacked(_baseImageURI(), _baseFileName)), 3)))))
            : '';
    }

    function getBase64ModelMetadata(string memory _baseFileName) public view returns (string memory) {

        return Base64.encode(padStringBytes(abi.encodePacked(
            '","metadataStandard": "',
            _modelStandardName(),
            '","extensions": [ "',
            _modelExtensionName(),
            '" ],"assets": [{ "mediaType": "model", "assetType": "avatar", "files": [{"url": "',
            _baseModelURI(),
                _baseFileName,
            '","fileType": "',
            _modelFileType(),
            '"}]}]'
        ), 3));
    }

    function getTokenData(uint256 _tokenId, uint256 _dna) public view returns (ChainRunnersBaseRenderer.Layer [NUM_LAYERS] memory tokenLayers, ChainRunnersBaseRenderer.Color [NUM_COLORS][NUM_LAYERS] memory tokenPalettes, uint8 numTokenLayers, string [NUM_LAYERS] memory traitTypes) {

        if (_tokenId <= 10000) {
            ChainRunnersBaseRenderer genesisRendererContract = ChainRunnersBaseRenderer(genesisRendererContractAddress);
            return genesisRendererContract.getTokenData(_dna);
        }
        return getXRTokenData(_dna);
    }

    function getXRTokenData(uint256 _dna) public view returns (ChainRunnersBaseRenderer.Layer [NUM_LAYERS] memory tokenLayers, ChainRunnersBaseRenderer.Color [NUM_COLORS][NUM_LAYERS] memory tokenPalettes, uint8 numTokenLayers, string [NUM_LAYERS] memory traitTypes) {

        uint16[NUM_LAYERS] memory dna = splitNumber(_dna);
        uint16 raceIndex = getRaceIndex(dna[1]);

        bool hasFaceAcc = dna[7] < (10000 - WEIGHTS[raceIndex][7][7]);
        bool hasMask = dna[8] < (10000 - WEIGHTS[raceIndex][8][7]);
        bool hasHeadBelow = dna[9] < (10000 - WEIGHTS[raceIndex][9][36]);
        bool hasHeadAbove = dna[11] < (10000 - WEIGHTS[raceIndex][11][48]);
        bool useHeadAbove = (dna[0] % 2) > 0;
        for (uint8 i = 0; i < NUM_LAYERS; i ++) {
            ChainRunnersBaseRenderer genesisRenderer = ChainRunnersBaseRenderer(genesisRendererContractAddress);
            ChainRunnersBaseRenderer.Layer memory layer = genesisRenderer.getLayer(i, uint8(getLayerIndex(dna[i], i, raceIndex)));
            if (layer.hexString.length > 0) {
                if (((i == 2 || i == 12) && !hasMask && !hasFaceAcc) || (i == 7 && !hasMask) || (i == 10 && !hasMask) || (i < 2 || (i > 2 && i < 7) || i == 8 || i == 9 || i == 11)) {
                    if (hasHeadBelow && hasHeadAbove && (i == 9 && useHeadAbove) || (i == 11 && !useHeadAbove)) continue;
                    tokenLayers[numTokenLayers] = layer;
                    traitTypes[numTokenLayers] = ["QmFja2dyb3VuZCAg","UmFjZSAg","RmFjZSAg","TW91dGgg","Tm9zZSAg","RXllcyAg","RWFyIEFjY2Vzc29yeSAg","RmFjZSBBY2Nlc3Nvcnkg","TWFzayAg","SGVhZCBCZWxvdyAg","RXllIEFjY2Vzc29yeSAg","SGVhZCBBYm92ZSAg","TW91dGggQWNjZXNzb3J5"][i];
                    numTokenLayers++;
                }
            }
        }
        return (tokenLayers, tokenPalettes, numTokenLayers, traitTypes);
    }

    function splitNumber(uint256 _number) internal view returns (uint16[NUM_LAYERS] memory numbers) {

        for (uint256 i = 0; i < numbers.length; i++) {
            numbers[i] = uint16(_number % 10000);
            _number >>= 14;
        }
        return numbers;
    }

    function uintToByteString(uint _a, uint _fixedLen) internal pure returns (bytes memory _uintAsString) {

        uint j = _a;
        uint len;
        while (j != 0) {
            len++;
            j /= 10;
        }
        bytes memory bstr = new bytes(_fixedLen);
        j = _fixedLen;
        if (_a == 0) {
            bstr[0] = "0";
            len = 1;
        }
        while (j > len) {
            j = j - 1;
            bstr[j] = bytes1(' ');
        }
        uint k = len;
        while (_a != 0) {
            k = k - 1;
            uint8 temp = (48 + uint8(_a - _a / 10 * 10));
            bytes1 b1 = bytes1(temp);
            bstr[k] = b1;
            _a /= 10;
        }
        return bstr;
    }

    function padString(string memory _s, uint256 _multiple) internal view returns (string memory) {

        uint256 numPaddingSpaces = (_multiple - (bytes(_s).length % _multiple)) % _multiple;
        while (numPaddingSpaces > 0) {
            _s = string(abi.encodePacked(_s, ' '));
            numPaddingSpaces--;
        }
        return _s;
    }

    function padStringBytes(bytes memory _s, uint256 _multiple) internal view returns (bytes memory) {

        uint256 numPaddingSpaces = (_multiple - (_s.length % _multiple)) % _multiple;
        while (numPaddingSpaces > 0) {
            _s = abi.encodePacked(_s, ' ');
            numPaddingSpaces--;
        }
        return _s;
    }
}