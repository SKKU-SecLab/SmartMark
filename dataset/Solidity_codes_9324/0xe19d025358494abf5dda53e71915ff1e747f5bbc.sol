


pragma solidity ^0.4.17;

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

    function sin(uint16 _angle) public pure returns (int) {

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

    function cos(uint16 _angle) public pure returns (int) {

        if (_angle > ANGLES_IN_CYCLE - QUADRANT_LOW_MASK) {
            _angle = QUADRANT_LOW_MASK - ANGLES_IN_CYCLE - _angle;
        } else {
            _angle += QUADRANT_LOW_MASK;
        }
        return sin(_angle);
    }
    
        function sinDegrees (uint256 _degrees) public pure returns (int256) {
            uint256 degrees = _degrees % 360;
            uint16 angle16bit = uint16((degrees * 16384) / 360);
            return sin(angle16bit);
        }

        function sinNanodegrees (uint256 _nanodegrees) public pure returns (int256) {
            return sinDegrees(_nanodegrees / 10 ** 9 );
        }

        function cosDegrees (uint256 _degrees) public pure returns (int256) {
            uint256 degrees = _degrees % 360;
            uint16 angle16bit = uint16((degrees * 16384) / 360);
            return cos(angle16bit);
        }

        function cosNanodegrees (uint256 _nanodegrees) public pure returns (int256) {
            return cosDegrees(_nanodegrees / 10 ** 9 );
        }

        function sqrt (int256 _x) public pure returns (uint256 y_) {
            if (_x < 0) {
                _x = _x * -1;
            }

            uint256 x = uint256(_x);

            uint256 z = (x + 1) / 2;
            y_ = x;
            while (z < y_) {
                y_ = z;
                z = (x / z + z) / 2;
            }
        }
}