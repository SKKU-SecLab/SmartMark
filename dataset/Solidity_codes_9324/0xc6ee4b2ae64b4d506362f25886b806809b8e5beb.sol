
pragma solidity ^0.4.21;

library BWUtility {

    


    function ceil(uint _amount, uint _multiple) pure public returns (uint) {

        return ((_amount + _multiple - 1) / _multiple) * _multiple;
    }

    function isAdjacent(uint8 _x1, uint8 _y1, uint8 _x2, uint8 _y2) pure public returns (bool) {

        return ((_x1 == _x2 &&      (_y2 - _y1 == 1 || _y1 - _y2 == 1))) ||      // Same column
               ((_y1 == _y2 &&      (_x2 - _x1 == 1 || _x1 - _x2 == 1))) ||      // Same row
               ((_x2 - _x1 == 1 &&  (_y2 - _y1 == 1 || _y1 - _y2 == 1))) ||      // Right upper or lower diagonal
               ((_x1 - _x2 == 1 &&  (_y2 - _y1 == 1 || _y1 - _y2 == 1)));        // Left upper or lower diagonal
    }

    function toTileId(uint8 _x, uint8 _y) pure public returns (uint16) {

        return uint16(_x) << 8 | uint16(_y);
    }

    function fromTileId(uint16 _tileId) pure public returns (uint8, uint8) {

        uint8 y = uint8(_tileId);
        uint8 x = uint8(_tileId >> 8);
        return (x, y);
    }
    
    function getBoostFromTile(address _claimer, address _attacker, address _defender, uint _blockValue) pure public returns (uint, uint) {

        if (_claimer == _attacker) {
            return (_blockValue, 0);
        } else if (_claimer == _defender) {
            return (0, _blockValue);
        }
    }
}