
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
pragma solidity 0.8.9;

interface ChainRunnersTypes {

    struct ChainRunner {
        uint256 dna;
    }
}// MIT
pragma solidity 0.8.9;


interface IChainRunnersRenderer {

    struct Layer {
        string name;
        bytes hexString;
    }
    
    struct Color {
        string hexString;
        uint alpha;
        uint red;
        uint green;
        uint blue;
    }

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

    function tokenURI(uint256 tokenId, ChainRunnersTypes.ChainRunner memory runnerData) external view returns (string memory);

    function byteToHexString(bytes1 b) external pure returns (string memory);

    function byteToUint(bytes1 b) external pure returns (uint);

    function uintToHexString6(uint a) external pure returns (string memory);

    function getRaceIndex(uint16 _dna) external view returns (uint8);

    function getLayer(uint8 layerIndex, uint8 itemIndex) external view returns (Layer memory);

    function getLayerIndex(uint16 _dna, uint8 _index, uint16 _raceIndex) external view returns (uint);

    function tokenSVGBuffer(Layer [13] memory tokenLayers, Color [8][13] memory tokenPalettes, uint8 numTokenLayers) external pure returns (string[4] memory);

}// MIT
pragma solidity 0.8.9;

interface IBlitmapCRConverter {

    function getBlitmapLayer(uint256 tokenId) external view returns (bytes memory);

    function tokenNameOf(uint256 tokenId) external view returns (string memory);

}// MIT
pragma solidity 0.8.9;



contract AntiRunnersBaseRenderer is Ownable, ReentrancyGuard {

    address public chainRunnersBaseRenderer;
    address public blitmapCRConverter;

    uint256 public constant NUM_LAYERS = 13;
    uint256 public constant NUM_COLORS = 8;

    uint16[][NUM_LAYERS][3] WEIGHTS;

    constructor(address chainRunnersBaseRendererAddress, address blitmapConverterAddress) {
        chainRunnersBaseRenderer = chainRunnersBaseRendererAddress;
        blitmapCRConverter = blitmapConverterAddress;

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

    function setChainRunnersBaseRenderer(address _addr) public onlyOwner {

        chainRunnersBaseRenderer = _addr;
    }

    function setBlitmapCRConverter(address _addr) public onlyOwner {

        blitmapCRConverter = _addr;
    }

    struct TokenURIInput {
        uint256 tokenId;
        uint256 dna;
        bool isReunited;
    }

    function tokenURI(TokenURIInput memory input) public view returns (string memory) {

        (
            IChainRunnersRenderer.Layer[NUM_LAYERS] memory tokenLayers,
            IChainRunnersRenderer.Color[NUM_COLORS][NUM_LAYERS] memory tokenPalettes,
            uint8 numTokenLayers,
            string[NUM_LAYERS] memory traitTypes
        ) = getTokenData(input.dna, input.isReunited);

        string memory attributes;
        for (uint8 i = 0; i < numTokenLayers; i++) {
            attributes = string(
                abi.encodePacked(
                    attributes,
                    bytes(attributes).length == 0 ? "eyAg" : "LCB7",
                    "InRyYWl0X3R5cGUiOiAi",
                    traitTypes[i],
                    "IiwidmFsdWUiOiAi",
                    tokenLayers[i].name,
                    "IiB9"
                )
            );
        }

        if (input.isReunited) {
            attributes = string(
                abi.encodePacked(
                    attributes,
                    "LCB7InRyYWl0X3R5cGUiOiAiUmV1bml0ZWQiLCAidmFsdWUiOiAiWWVzIiB9"
                )
            );
        }

        string[4] memory svgBuffers = IChainRunnersRenderer(chainRunnersBaseRenderer).tokenSVGBuffer(
            tokenLayers,
            tokenPalettes,
            numTokenLayers
        );

        string memory encodedTokenId = Base64.encode(uintToByteString(input.tokenId, 6));

        return
            string(
                abi.encodePacked(
                    "data:application/json;base64,eyAgImltYWdlX2RhdGEiOiAiPHN2ZyB2ZXJzaW9uPScxLjEnIHZpZXdCb3g9JzAgMCAzMjAgMzIwJyB4bWxucz0naHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmcnIHNoYXBlLXJlbmRlcmluZz0nY3Jpc3BFZGdlcyc+",
                    svgBuffers[0],
                    svgBuffers[1],
                    svgBuffers[2],
                    svgBuffers[3],
                    "PHN0eWxlPnJlY3R7d2lkdGg6MTBweDtoZWlnaHQ6MTBweDt9PC9zdHlsZT48L3N2Zz4gIiwgImF0dHJpYnV0ZXMiOiBb",
                    attributes,
                    "XSwgICAibmFtZSI6ICJBbnRpIFJ1bm5lciAj",
                    encodedTokenId,
                    "IiwgImRlc2NyaXB0aW9uIjogIkEgYnVnIGluIHRoZSBjb2RlIHByb2R1Y2VkIDEwLDAwMCBBbnRpIFJ1bm5lcnM7IDEwMCUgZ2VuZXJhdGVkIG9uIGNoYWluLlxuXG5WaWV3IHRoaXMgcnVubmVyJ3Mgc2libGluZzogaHR0cHM6Ly9vcGVuc2VhLmlvL2Fzc2V0cy8weDk3NTk3MDAyOTgwMTM0YmVhNDYyNTBhYTA1MTBjOWI5MGQ4N2E1ODcv",
                    encodedTokenId,
                    "In0g"
                )
            );
    }

    function tokenSVG(uint256 _dna, bool isReunited) public view returns (string memory) {

        (
            IChainRunnersRenderer.Layer[NUM_LAYERS] memory tokenLayers,
            IChainRunnersRenderer.Color[NUM_COLORS][NUM_LAYERS] memory tokenPalettes,
            uint8 numTokenLayers,
            string[NUM_LAYERS] memory traitTypes
        ) = getTokenData(_dna, isReunited);

        string[4] memory buffer256 = IChainRunnersRenderer(chainRunnersBaseRenderer).tokenSVGBuffer(
            tokenLayers,
            tokenPalettes,
            numTokenLayers
        );

        return
            string(
                abi.encodePacked(
                    "PHN2ZyB2ZXJzaW9uPScxLjEnIHZpZXdCb3g9JzAgMCAzMjAgMzIwJyB4bWxucz0naHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmcnIHNoYXBlLXJlbmRlcmluZz0nY3Jpc3BFZGdlcyc+",
                    buffer256[0],
                    buffer256[1],
                    buffer256[2],
                    buffer256[3],
                    "PHN0eWxlPnJlY3R7d2lkdGg6MTBweDtoZWlnaHQ6MTBweDt9PC9zdHlsZT48L3N2Zz4"
                )
            );
    }

    function getTokenData(uint256 _dna, bool isReunited) public view returns (IChainRunnersRenderer.Layer [NUM_LAYERS] memory tokenLayers, IChainRunnersRenderer.Color [NUM_COLORS][NUM_LAYERS] memory tokenPalettes, uint8 numTokenLayers, string [NUM_LAYERS] memory traitTypes) {

        uint16[NUM_LAYERS] memory dna = splitNumber(_dna);
        uint16 raceIndex = getRaceIndex(dna[1]);

        uint16 ogRaceIndex = IChainRunnersRenderer(chainRunnersBaseRenderer).getRaceIndex(dna[1]);

        bool hasFaceAcc = dna[7] < (10000 - WEIGHTS[ogRaceIndex][7][7]);
        bool hasMask = dna[8] < (10000 - WEIGHTS[ogRaceIndex][8][7]);
        bool hasHeadBelow = dna[9] < (10000 - WEIGHTS[ogRaceIndex][9][36]);
        bool hasHeadAbove = dna[11] < (10000 - WEIGHTS[ogRaceIndex][11][48]);
        bool useHeadAbove = (dna[0] % 2) > 0;
        for (uint8 i = 0; i < NUM_LAYERS; i ++) {
            IChainRunnersRenderer.Layer memory layer;

            if (i==0 && isReunited) {
                uint blitmapTokenId = dna[i] % 100;
                layer.hexString = IBlitmapCRConverter(blitmapCRConverter).getBlitmapLayer(blitmapTokenId);
                string memory name = IBlitmapCRConverter(blitmapCRConverter).tokenNameOf(blitmapTokenId);
                layer.name = string(abi.encodePacked(Base64.encode(bytes(name))));
            
            } else {
                layer = IChainRunnersRenderer(chainRunnersBaseRenderer).getLayer(i, uint8(getLayerIndex(dna[i], i, raceIndex, ogRaceIndex)));
            }

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

    function getRaceIndex(uint16 _dna) public pure returns (uint8) {

        if (_dna <= 875) { // alien -> skull
            return 1;
        
        } else if (_dna <= 2144) { // bot -> alien
            return 0;
        
        } else if (_dna <= 9934) { // human -> bot
            return 2;
        
        } else { // skull -> human
            return 0;
        }
    }

    function getRaceLayer(uint16 _dna) public pure returns (uint) {

        if (_dna <= 875) { // alien -> skull
            return (_dna % 3) + 12;
        
        } else if (_dna <= 2144) { // bot -> alien
            return 0;
        
        } else if (_dna <= 9934) { // human -> bot
            return 1;
        
        } else {
            return (_dna % 10) + 2; // skull -> human
        }
    }

    function getLayerIndex(uint16 _dna, uint8 _index, uint16 _raceIndex, uint16 _ogRaceIndex) public view returns (uint) {

        if (_index == 1) {
            return getRaceLayer(_dna);
        }

        uint16 lowerBound;
        uint16 percentage;
        for (uint8 i; i < WEIGHTS[_ogRaceIndex][_index].length; i++) {
            percentage = WEIGHTS[_ogRaceIndex][_index][i];
            if (_dna >= lowerBound && _dna < lowerBound + percentage && WEIGHTS[_raceIndex][_index][i] != 0) {
                return i;
            }
            lowerBound += percentage;
        }

        return IChainRunnersRenderer(chainRunnersBaseRenderer).getLayerIndex(_dna, _index, _raceIndex);
    }

    function splitNumber(uint256 _number) internal pure returns (uint16[NUM_LAYERS] memory numbers) {

        for (uint256 i = 0; i < numbers.length; i++) {
            numbers[i] = uint16(_number % 10000);
            _number >>= 14;
        }
        return numbers;
    }

    function palette(bytes memory data)
        internal
        view
        returns (IChainRunnersRenderer.Color[NUM_COLORS] memory)
    {

        IChainRunnersRenderer.Color[NUM_COLORS] memory colors;
        for (uint16 i = 0; i < NUM_COLORS; i++) {
            colors[i].hexString = Base64.encode(
                bytes(
                    abi.encodePacked(
                        IChainRunnersRenderer(chainRunnersBaseRenderer).byteToHexString(data[i * 4]),
                        IChainRunnersRenderer(chainRunnersBaseRenderer).byteToHexString(
                            data[i * 4 + 1]
                        ),
                        IChainRunnersRenderer(chainRunnersBaseRenderer).byteToHexString(
                            data[i * 4 + 2]
                        )
                    )
                )
            );
            colors[i].red = IChainRunnersRenderer(chainRunnersBaseRenderer).byteToUint(data[i * 4]);
            colors[i].green = IChainRunnersRenderer(chainRunnersBaseRenderer).byteToUint(
                data[i * 4 + 1]
            );
            colors[i].blue = IChainRunnersRenderer(chainRunnersBaseRenderer).byteToUint(
                data[i * 4 + 2]
            );
            colors[i].alpha = IChainRunnersRenderer(chainRunnersBaseRenderer).byteToUint(
                data[i * 4 + 3]
            );
        }
        return colors;
    }

    function uintToByteString(uint256 a, uint256 fixedLen)
        internal
        pure
        returns (bytes memory _uintAsString)
    {

        uint256 j = a;
        uint256 len;
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
            bstr[j] = bytes1(" ");
        }
        uint256 k = len;
        while (a != 0) {
            k = k - 1;
            uint8 temp = (48 + uint8(a - (a / 10) * 10));
            bytes1 b1 = bytes1(temp);
            bstr[k] = b1;
            a /= 10;
        }
        return bstr;
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
}