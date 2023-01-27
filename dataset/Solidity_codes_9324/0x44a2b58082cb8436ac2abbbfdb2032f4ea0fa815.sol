pragma solidity ^0.8.4;

library Trigonometry {


    uint constant INDEX_WIDTH = 4;
    uint constant INTERP_WIDTH = 8;
    uint constant INDEX_OFFSET = 12 - INDEX_WIDTH;
    uint constant INTERP_OFFSET = INDEX_OFFSET - INTERP_WIDTH;
    uint16 constant ANGLES_IN_CYCLE = 16384;
    uint16 constant QUADRANT_HIGH_MASK = 8192;
    uint16 constant QUADRANT_LOW_MASK = 4096;
    uint constant SINE_TABLE_SIZE = 16;

    uint8 constant entry_bytes = 2;
    bytes constant sin_table = "\x00\x00\x0c\x8c\x18\xf9\x25\x28\x30\xfb\x3c\x56\x47\x1c\x51\x33\x5a\x82\x62\xf1\x6a\x6d\x70\xe2\x76\x41\x7a\x7c\x7d\x89\x7f\x61\x7f\xff";

    function bits(uint _value, uint _width, uint _offset) pure internal returns (uint) {

        return (_value / (2 ** _offset)) & (((2 ** _width)) - 1);
    }

    function sin_table_lookup(uint index) pure internal returns (uint16) {

        bytes memory table = sin_table;
        uint offset = (index + 1) * entry_bytes;
        uint16 trigint_value;
        assembly {
            trigint_value := mload(add(table, offset))
        }

        return trigint_value;
    }

    function sin(uint16 _angle) internal pure returns (int) {

        uint interp = bits(_angle, INTERP_WIDTH, INTERP_OFFSET);
        uint index = bits(_angle, INDEX_WIDTH, INDEX_OFFSET);

        bool is_odd_quadrant = (_angle & QUADRANT_LOW_MASK) == 0;
        bool is_negative_quadrant = (_angle & QUADRANT_HIGH_MASK) != 0;

        if (!is_odd_quadrant) {
            index = SINE_TABLE_SIZE - 1 - index;
        }

        uint x1 = sin_table_lookup(index);
        uint x2 = sin_table_lookup(index + 1);
        uint approximation = ((x2 - x1) * interp) / (2 ** INTERP_WIDTH);

        int sine;
        if (is_odd_quadrant) {
            sine = int(x1) + int(approximation);
        } else {
            sine = int(x2) - int(approximation);
        }

        if (is_negative_quadrant) {
            sine *= -1;
        }

        return sine;
    }

    function cos(uint16 _angle) internal pure returns (int) {

        _angle = (_angle + QUADRANT_LOW_MASK) % ANGLES_IN_CYCLE;

        return sin(_angle);
    }
}// MIT
pragma solidity ^0.8.4;


library Fixed {

    uint8 constant scale = 32;

    function toFixed(int64 i) internal pure returns (int64){

        return i << scale;
    }

    function toInt(int64 f) internal pure returns (int64){

        return f >> scale;
    }

    function fractionPart(int64 f) internal pure returns (int64){

        int8 sign = f < 0 ? - 1 : int8(1);
        int64 fraction = (sign * f) & 2 ** 32 - 1;
        return int64(int128(fraction) * 1e5 >> scale);
    }

    function wholePart(int64 f) internal pure returns (int64){

        return f >> scale;
    }

    function mul(int64 a, int64 b) internal pure returns (int64) {

        return int64(int128(a) * int128(b) >> scale);
    }

    function div(int64 a, int64 b) internal pure returns (int64){

        return int64((int128(a) << scale) / b);
    }
}//"GPL-3.0


pragma solidity ^0.8.4;



library PolyRenderer {

    using Trigonometry for uint16;
    using Fixed for int64;

    struct Polygon {
        uint8 sides;
        uint8 color;
        uint64 size;
        uint16 rotation;
        uint64 top;
        uint64 left;
        uint64 opacity;
    }

    struct Circle {
        uint8 color;
        uint64 radius;
        uint64 c_y;
        uint64 c_x;
        uint64 opacity;
    }

    function svgOf(bytes calldata data, bool isCircle) external pure returns (string memory){

        string memory svg = '<svg width="256" height="256" viewBox="0 0 256 256" xmlns="http://www.w3.org/2000/svg">';

        string memory bgColor = string(abi.encodePacked("rgb(", uint2str(uint8(data[0]), 0, 1), ",", uint2str(uint8(data[1]), 0, 1), ",", uint2str(uint8(data[2]), 0, 1), ")"));
        svg = string(abi.encodePacked(svg, '<rect width="256" height="256" fill="', bgColor, '"/>'));

        string[4] memory colors;
        for (uint8 i = 0; i < 4; i++) {
            colors[i] = string(abi.encodePacked(uint2str(uint8(data[3 + i * 3]), 0, 1), ",", uint2str(uint8(data[4 + i * 3]), 0, 1), ",", uint2str(uint8(data[5 + i * 3]), 0, 1), ","));
        }

        uint polygons = (data.length - 15) / 5;
        string memory poly = '';
        Polygon memory polygon;
        for (uint i = 0; i < polygons; i++) {
            polygon = polygonFromBytes(data[15 + i * 5 : 15 + (i + 1) * 5]);
            poly = string(abi.encodePacked(poly,
                isCircle
                ? renderCircle(polygon, colors)
                : renderPolygon(polygon, colors))
            );
        }
        return string(abi.encodePacked(svg, poly, '</svg>'));
    }

    function attributesOf(bytes calldata data, bool isCircle) external pure returns (string memory){

        uint elements = (data.length - 15) / 5;
        if (isCircle) {
            return string(abi.encodePacked('[{"trait_type":"Circles","value":', uint2str(elements, 0, 1), '}]'));
        }
        string[4] memory types = ["Triangles", "Squares", "Pentagons", "Hexagons"];
        uint256[4] memory sides_count;
        for (uint i = 0; i < elements; i++) {
            sides_count[uint8(data[15 + i * 5] >> 6)]++;
        }
        string memory result = '[';
        string memory last;
        for (uint i = 0; i < 4; i++) {
            last = i == 3 ? '}' : '},';
            result = string(abi.encodePacked(result, '{"trait_type":"', types[i], '","value":',
                uint2str(sides_count[i], 0, 1), last));
        }
        return string(abi.encodePacked(result, ']'));
    }

    function renderCircle(Polygon memory polygon, string[4] memory colors) internal pure returns (string memory){

        int64 radius = getRadius(polygon.sides, polygon.size);
        return string(abi.encodePacked('<circle cx="', fixedToString(int64(polygon.left).toFixed(), 1), '" cy="',
            fixedToString(int64(polygon.top).toFixed(), 1), '" r="', fixedToString(radius, 1), '" style="fill:rgba(',
            colors[polygon.color], opacityToString(polygon.opacity), ')"/>'));
    }

    function opacityToString(uint64 opacity) internal pure returns (string memory) {

        return opacity == 31
        ? '1'
        : string(abi.encodePacked('0.', uint2str(uint64(int64(opacity).div(31).fractionPart()), 5, 1)));
    }

    function polygonFromBytes(bytes calldata data) internal pure returns (Polygon memory) {

        Polygon memory polygon;
        polygon.sides = (uint8(data[0]) >> 6) + 3;
        polygon.color = (uint8(data[0]) >> 4) & 3;
        polygon.opacity = ((uint8(data[0]) % 16) << 1) + (uint8(data[1]) >> 7);
        polygon.rotation = uint8(data[1]) % 128;
        polygon.top = uint8(data[2]);
        polygon.left = uint8(data[3]);
        polygon.size = uint64(uint8(data[4])) + 1;
        return polygon;
    }

    function renderPolygon(Polygon memory polygon, string[4] memory colors) internal pure returns (string memory){

        int64[] memory points = getVertices(polygon);

        int64 v;
        int8 sign;
        string memory last;
        string memory result = '<polygon points="';
        for (uint j = 0; j < points.length; j++) {
            v = points[j];
            sign = v < 0 ? - 1 : int8(1);
            last = j == points.length - 1 ? '" style="fill:rgba(' : ",";
            result = string(abi.encodePacked(result, fixedToString(v, sign), last));
        }
        return string(abi.encodePacked(result, colors[polygon.color], opacityToString(polygon.opacity), ')"/>'));
    }

    function fixedToString(int64 fPoint, int8 sign) internal pure returns (bytes memory){

        return abi.encodePacked(uint2str(uint64(sign * fPoint.wholePart()), 0, sign), ".",
            uint2str(uint64(fPoint.fractionPart()), 5, 1));
    }

    function getRotationVector(uint16 angle) internal pure returns (int64[2] memory){

        return [
            int64(angle.cos()).div(32767), //-32767 to 32767.
            int64(-angle.sin()).div(32767)
        ];
    }

    function rotate(int64[2] memory R, int64[2] memory pos) internal pure returns (int64[2] memory){

        int64[2] memory result;
        result[0] = R[0].mul(pos[0]) + R[1].mul(pos[1]);
        result[1] = - R[1].mul(pos[0]) + R[0].mul(pos[1]);
        return result;
    }

    function vectorSum(int64[2] memory a, int64[2] memory b) internal pure returns (int64[2] memory){

        return [a[0] + b[0], a[1] + b[1]];
    }

    function getRadius(uint8 sides, uint64 size) internal pure returns (int64){

        int64 cos_ang_2 = int64(uint64([7439101574, 6074001000, 5049036871, 4294967296][sides - 3]));
        return int64(size).toFixed().div(cos_ang_2);
    }

    function getVertices(Polygon memory polygon) internal pure returns (int64[] memory) {

        int64[] memory result = new int64[](2 * polygon.sides);
        uint16 internalAngle = [1365, 2048, 2458, 2731][polygon.sides - 3]; // Note: 16384 is 2pi
        uint16 angle = [5461, 4096, 3277, 2731][polygon.sides - 3]; // 16384/sides
        int64 radius = getRadius(polygon.sides, polygon.size);


        uint16 rotation = uint16((polygon.rotation << 7) / polygon.sides + internalAngle);

        int64[2] memory R = getRotationVector(rotation);
        int64[2] memory vector = rotate(R, [radius, 0]);
        int64[2] memory center = [int64(polygon.left).toFixed(), int64(polygon.top).toFixed()];
        int64[2] memory pos = vectorSum(center, vector);
        result[0] = pos[0];
        result[1] = pos[1];
        R = getRotationVector(angle);
        for (uint8 i = 0; i < polygon.sides - 1; i++) {
            vector = rotate(R, vector);
            pos = vectorSum(center, vector);
            result[(i + 1) * 2] = pos[0];
            result[(i + 1) * 2 + 1] = pos[1];
        }
        return result;
    }

    function uint2str(uint _i, uint8 zero_padding, int8 sign) internal pure returns (string memory str) {

        if (_i == 0) {
            return "0";
        }
        uint j = _i;
        uint length;
        while (j != 0) {
            length++;
            j /= 10;
        }
        bytes memory bstr = new bytes(length);
        uint k = length;
        j = _i;
        while (j != 0) {
            bstr[--k] = bytes1(uint8(48 + j % 10));
            j /= 10;
        }
        if ((zero_padding > 0) && (zero_padding > length)) {
            uint pad_length = zero_padding - length;
            bytes memory pad = new bytes(pad_length);
            k = 0;
            while (k < pad_length) {
                pad[k++] = bytes1(uint8(48));
            }
            bstr = abi.encodePacked(pad, bstr);
        }
        if (sign < 0) {
            return string(abi.encodePacked("-", bstr));
        } else {
            return string(bstr);
        }
    }
}