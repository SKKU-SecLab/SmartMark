

pragma solidity 0.8.1;

interface IMoonCatAcclimator {

    function getApproved(uint256 tokenId) external view returns (address);

    function isApprovedForAll(address owner, address operator) external view returns (bool);

    function ownerOf(uint256 tokenId) external view returns (address);

    function balanceOf(address _owner) external view returns (uint256);

    function tokenOfOwnerByIndex(address _owner, uint256 _index) external view returns (uint256);

}

interface IMoonCatRescue {

    function rescueOrder(uint256 tokenId) external view returns (bytes5);

    function catOwners(bytes5 catId) external view returns (address);

}

interface IReverseResolver {

    function claim(address owner) external returns (bytes32);

}

interface IERC20 {

    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount) external returns (bool);

}

interface IERC721 {

    function safeTransferFrom(address from, address to, uint256 tokenId) external;

}

interface IMoonCatReference {

    function doc (address contractAddress) external view returns (string memory name, string memory description, string memory details);
    function setDoc (address contractAddress, string calldata name, string calldata description) external;
}


contract MoonCatColors {



    IMoonCatRescue MCR = IMoonCatRescue(0x60cd862c9C687A9dE49aecdC3A99b74A4fc54aB6);
    IMoonCatReference MoonCatReference;


    uint256 constant private ONE = 1e15;
    uint256 constant private SIX = 6e15;
    uint256 constant private HUNDREDTH = 1e13;

    function RGBToHue (uint256 r, uint256 g, uint256 b) public pure returns (uint256) {
        r = r * ONE / 255;
        g = g * ONE / 255;
        b = b * ONE / 255;

        uint256 cMax = r;
        uint256 cMin = r;

        if (g > r || b > r) {
            if (g > b) {
                cMax = g;
            } else {
                cMax = b;
            }
        }

        if (g < r || b < r) {
            if (g < b) {
                cMin = g;
            } else {
                cMin = b;
            }
        }

        uint256 delta = cMax - cMin;

        uint256 numerator;
        uint256 offset = 0;
        bool neg = false;

        if (delta == 0) {
            return 0;
        } else if (cMax == r) {
            if (g >= b) {
                numerator = g - b;
            } else {
                numerator = b - g;
                neg = true;
            }
        } else if (cMax == g) {
            if (b >= r) {
                numerator = b - r;
            } else {
                numerator = r - b;
                neg = true;
            }
            offset = 2 * ONE;
        } else {
            if (r >= g) {
                numerator = r - g;
            } else {
                numerator = g - r;
                neg = true;
            }
            offset = 4 * ONE;
        }

        uint256 hue = ((numerator * ONE) + (delta / 2)) / delta;
        if (neg) {
            hue = offset + SIX - hue;
        } else {
            hue = hue + offset;
        }

        while (hue > SIX) {
            hue -= SIX;
        }

        return hue * 60;
    }

    function roundComponent (uint256 c, uint256 m) internal pure returns (uint8) {
        uint256 t = (c + m) * 255;
        uint256 r = (t / ONE);
        uint256 rem = t - r * ONE;
        if (rem >= 499999999999000) {
            return uint8(r + 1);
        } else {
            return uint8(r);
        }
    }

    function hueToRGB (uint256 hue, uint8 _lightness) public pure returns (uint8, uint8, uint8) {

        uint256 c;
        uint256 lightness = _lightness * HUNDREDTH;
        if (lightness < (ONE / 2)) {
            c = 2 * lightness;
        } else {
            c = 2 * (ONE - lightness);
        }
        uint256 x;
        uint256 temp = (hue / 60) % (2 * ONE);

        if (temp > ONE) {
            x = c * (ONE - (temp - ONE)) / ONE;
        } else {
            x = c * (ONE - (ONE - temp)) / ONE;
        }

        uint256 m = lightness - c / 2;

        uint256 r;
        uint256 g;
        uint256 b;

        if (hue < (60 * ONE)) {
            r = c;
            g = x;
            b = 0;
        } else if (hue < (120 * ONE)) {
            r = x;
            g = c;
            b = 0;
        } else if (hue < (180 * ONE)) {
            r = 0;
            g = c;
            b = x;
        } else if (hue < (240 * ONE)) {
            r = 0;
            g = x;
            b = c;
        } else if (hue < (300 * ONE)) {
            r = x;
            g = 0;
            b = c;
        } else {
            r = c;
            g = 0;
            b = x;
        }
        return (roundComponent(r, m), roundComponent(g, m), roundComponent(b, m));
    }

    function deriveColors (uint8 red, uint8 green, uint8 blue, bool invert) public pure returns (uint8[24] memory) {

        uint8[24] memory palette;

        uint256 hx = RGBToHue(red, green, blue);
        uint256 hy = hx + (320 * ONE);
        if (hy >= (360 * ONE)) {
            hy -= (360 * ONE);
        }
        uint256 hz = 180 * ONE;
        if (invert) {
            hz += hy;
        } else {
            hz += hx;
        }
        if (hz >= (360 * ONE)) {
            hz -= (360 * ONE);
        }

        palette[0] = red;
        palette[1] = green;
        palette[2] = blue;

        uint8 r;
        uint8 g;
        uint8 b;

        (r,g,b) = hueToRGB(hx, 10);
        palette[3] = r;
        palette[4] = g;
        palette[5] = b;

        if (invert) {

            (r,g,b) = hueToRGB(hx, 70);
            palette[6] = r;
            palette[7] = g;
            palette[8] = b;

            (r,g,b) = hueToRGB(hy, 80);
            palette[9]  = r;
            palette[10] = g;
            palette[11] = b;

            (r,g,b) = hueToRGB(hx, 20);
            palette[12] = r;
            palette[13] = g;
            palette[14] = b;

            (r,g,b) = hueToRGB(hx, 45);
            palette[15] = r;
            palette[16] = g;
            palette[17] = b;

        } else {

            (r,g,b) = hueToRGB(hx, 20);
            palette[6] = r;
            palette[7] = g;
            palette[8] = b;

            (r,g,b) = hueToRGB(hx, 45);
            palette[9]  = r;
            palette[10] = g;
            palette[11] = b;

            (r,g,b) = hueToRGB(hx, 70);
            palette[12] = r;
            palette[13] = g;
            palette[14] = b;

            (r,g,b) = hueToRGB(hy, 80);
            palette[15] = r;
            palette[16] = g;
            palette[17] = b;

        }

        (r,g,b) = hueToRGB(hz, 45);
        palette[18] = r;
        palette[19] = g;
        palette[20] = b;

        (r,g,b) = hueToRGB(hz, 80);
        palette[21] = r;
        palette[22] = g;
        palette[23] = b;

        return palette;

    }

    mapping (bytes5 => uint128) internal MappedColors;

    function mapColors (bytes5[] calldata keys, uint128[] calldata vals) public onlyOwner {
        require(!finalized, "palettes have been finalized");
        require(keys.length == vals.length, "mismatched lengths");
        for (uint i = 0; i < keys.length; i++) {
            MappedColors[keys[i]] = vals[i];
        }
    }


    function glowOf (bytes5 catId) public pure returns (uint8[3] memory) {
        uint40 c = uint40(catId);
        uint8[3] memory glow;
        glow[0] = uint8(c >> 16);
        glow[1] = uint8(c >> 8);
        glow[2] = uint8(c);
        return glow;
    }

    function glowOf (uint256 rescueOrder) public view returns (uint8[3] memory) {
        require(rescueOrder < 25440, "Invalid Rescue Order");
        return glowOf(MCR.rescueOrder(rescueOrder));
    }


    uint8[24] GenesisBlack = [100,100,100,85,85,85,34,34,34,17,17,17,187,187,187,255,153,153,211,211,211,255,255,255];
    uint8[24] GenesisWhite = [100,100,100,85,85,85,211,211,211,255,255,255,170,170,170,255,153,153,17,17,17,34,34,34];

    function colorsOf (bytes5 catId) public view returns (uint8[24] memory) {
        uint40 c = uint40(catId);
        bool invert = ((c >> 31) & 1) == 1;
        if (c >= 1095216663719) {
            bool even_k = uint8(c >> 24) % 2 == 0;
            if ((even_k && invert) || (!even_k && !invert)) {
                return GenesisWhite;
            } else {
                return GenesisBlack;
            }
        }

        uint8 r = uint8(c >> 16);
        uint8 g = uint8(c >> 8);
        uint8 b = uint8(c);

        uint8[24] memory colors = deriveColors(r, g, b, invert);

        uint128 mapped = MappedColors[catId];
        if (mapped != 0) {
            for (uint i = 1; i < 16; i++) {
                colors[18 - i] = uint8(mapped >> (i * 8));
            }
        }
        return colors;
    }

    function colorsOf (uint256 rescueOrder) public view returns (uint8[24] memory) {
        require(rescueOrder < 25440, "Invalid Rescue Order");
        return colorsOf(MCR.rescueOrder(rescueOrder));
    }

    function accessoryColorsOf(bytes5 catId) public view returns (uint8[45] memory) {

        uint8[45] memory accessoryColors;
        uint8[24] memory mcColors = colorsOf(catId);

        for (uint i = 0; i < 18; i++) {
            accessoryColors[i] = mcColors[i];
        }
        accessoryColors[18] = mcColors[3];
        accessoryColors[19] = mcColors[4];
        accessoryColors[20] = mcColors[5];

        for (uint i = 0; i < 12; i+=3) {
            accessoryColors[21 + i] = mcColors[18];
            accessoryColors[22 + i] = mcColors[19];
            accessoryColors[23 + i] = mcColors[20];

            accessoryColors[33 + i] = mcColors[21];
            accessoryColors[34 + i] = mcColors[22];
            accessoryColors[35 + i] = mcColors[23];
        }

        return accessoryColors;
    }

    function accessoryColorsOf(uint256 rescueOrder) public view returns (uint8[45] memory) {

        require(rescueOrder < 25440, "Invalid Rescue Order");
        return accessoryColorsOf(MCR.rescueOrder(rescueOrder));
    }

    function colorAlpha (uint8 id) public pure returns (uint8) {
        if (id == 0) {
            return 0;
        } else if (id <= 70) {
            return 255;
        } else if (id <= 91) {
            return 200;
        } else if (id <= 105) {
            return 128;
        } else if (id <= 112) {
            return 200;
        } else if (id == 121 || id == 125) {
            return 127;
        } else if (id == 122 || id == 126) {
            return 102;
        } else if (id == 123 || id == 127) {
            return 76;
        }
        return 255;
    }

    uint8[339] public BasePalette = [255,255,255,255,255,255,212,212,212,170,170,170,128,128,128,85,85,85,42,42,42,0,0,0,
                                     249,134,134,242,13,13,161,8,8,249,178,134,242,101,13,161,67,8,249,220,134,242,185,13,
                                     161,123,8,249,249,134,242,242,13,161,161,8,210,249,134,166,242,13,110,161,8,134,249,
                                     134,13,242,13,8,161,8,134,249,205,13,242,154,8,161,103,134,249,249,13,242,242,8,161,
                                     161,134,205,249,13,154,242,8,103,161,134,134,249,13,13,242,8,8,161,182,134,249,108,
                                     13,242,72,8,161,210,134,249,166,13,242,110,8,161,235,134,249,215,13,242,144,8,161,
                                     249,134,210,242,13,166,161,8,110,65,22,22,65,54,22,43,65,22,22,65,48,22,33,65,43,22,
                                     65,65,22,54,236,198,198,236,221,198,202,236,198,198,236,236,198,217,236,217,198,236,
                                     236,198,226,56,43,31,72,47,25,101,62,29,130,79,35,153,96,46,184,132,86,218,192,169,
                                     255,255,255,212,212,212,170,170,170,128,128,128,85,85,85,42,42,42,0,0,0,242,13,13,
                                     108,19,19,242,185,13,108,86,19,128,242,13,64,108,19,13,242,154,19,108,74,13,70,242,
                                     19,41,108,127,13,242,64,19,108,242,13,185,108,19,86,242,13,13,108,19,19,242,185,13,
                                     108,86,19,128,242,13,64,108,19,13,242,154,19,108,74,13,70,242,19,41,108,127,13,242,
                                     64,19,108,242,13,185,108,19,86,247,171,171,247,228,171,180,247,171,171,247,247,171,
                                     209,247,209,171,247,247,171,228];

    function paletteOf(bytes5 catId) public view returns (uint8[384] memory) {

        uint8[384] memory palette;
        for (uint i = 0; i < 339; i++) {
            palette[i] = BasePalette[i];
        }
        uint8[45] memory accessoryColors = accessoryColorsOf(catId);
        for (uint i = 339; i < 384; i++) {
            palette[i] = accessoryColors[i - 339];
        }
        return palette;
    }

    function paletteOf(uint256 rescueOrder) public view returns (uint8[384] memory) {

        require(rescueOrder < 25440, "Invalid Rescue Order");
        return paletteOf(MCR.rescueOrder(rescueOrder));
    }

    function hueName (uint16 hue) public pure returns (string memory) {
        if (hue == 2000) {
            return "white";
        } else if (hue == 1000) {
            return "black";
        }

        require(hue < 360, "Invalid Hue");

        if (hue <= 15 || hue > 345) {
            return "red";
        } else if (hue <= 45) {
            return "orange";
        } else if (hue <= 75) {
            return "yellow";
        } else if (hue <= 105) {
            return "chartreuse";
        } else if (hue <= 135) {
            return "green";
        } else if (hue <= 165) {
            return "teal";
        } else if (hue <= 195) {
            return "cyan";
        } else if (hue <= 225) {
            return "skyblue";
        } else if (hue <= 255) {
            return "blue";
        } else if (hue <= 285) {
            return "purple";
        } else if (hue <= 315) {
            return "magenta";
        } else if (hue <= 345) {
            return "fuchsia";
        }
        return "How'd you get here?!?";
    }

    function hueIntOf (bytes5 catId) public view returns (uint16) {
        uint40 c = uint40(catId);
        bool invert = ((c >> 31) & 1) == 1;
        if (c >= 1095216663719) {
            bool even_k = uint8(c >> 24) % 2 == 0;
            if ((even_k && invert) || (!even_k && !invert)) {
                return 2000;
            } else {
                return 1000;
            }
        }

        uint16 offset = 0;
        uint128 mapped = MappedColors[catId];
        if (mapped != 0 && (mapped & 1 == 1)) {
            offset = 1;
        }
        uint8 r = uint8(c >> 16);
        uint8 g = uint8(c >> 8);
        uint8 b = uint8(c);

        uint256 hue = RGBToHue(r, g, b) + 2000; // 2000 is a correction factor

        return uint16(hue / ONE) - offset;
    }

    function hueIntOf (uint256 rescueOrder) public view returns (uint16) {
        require(rescueOrder < 25440, "Invalid Rescue Order");
        return hueIntOf(MCR.rescueOrder(rescueOrder));
    }


    function doc() public view returns (string memory name, string memory description, string memory details) {

        return MoonCatReference.doc(address(this));
    }

    constructor (address MoonCatReferenceAddress) {
        owner = payable(msg.sender);
        IReverseResolver(0x084b1c3C81545d370f3634392De611CaaBFf8148).claim(msg.sender);
        MoonCatReference = IMoonCatReference(MoonCatReferenceAddress);

    }

    address payable public owner;

    modifier onlyOwner () {

        require(msg.sender == owner, "Only Owner");
        _;
    }

    bool public finalized = false;

    function finalize () public onlyOwner {
        finalized = true;
    }

    function transferOwnership (address payable newOwner) public onlyOwner {
        owner = newOwner;
    }

    function setReferenceContract (address referenceContract) public onlyOwner {
        MoonCatReference = IMoonCatReference(referenceContract);
    }

    function withdrawForeignERC20 (address tokenContract) public onlyOwner {
        IERC20 token = IERC20(tokenContract);
        token.transfer(owner, token.balanceOf(address(this)));
    }

    function withdrawForeignERC721 (address tokenContract, uint256 tokenId) public onlyOwner {
        IERC721(tokenContract).safeTransferFrom(address(this), owner, tokenId);
    }

}