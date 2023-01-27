
pragma solidity ^0.8.0;

interface ISvgValidator {

    function isValid(string memory check) external view returns (bool);

}//MIT

pragma solidity ^0.8.0;


contract ScriptChecker is ISvgValidator {

    function isValid(string memory check) external pure override returns (bool) {

        return _strContains("<script", _lowerAndFilterControlChars(check));
    }

    function _strContains(string memory what, string memory where) internal pure returns (bool) {

        bytes memory whatBytes = bytes(what);
        bytes memory whereBytes = bytes(where);

        bool found = false;
        for (uint256 i = 0; i < whereBytes.length - whatBytes.length; i++) {
            bool flag = true;
            for (uint256 j = 0; j < whatBytes.length; j++)
                if (whereBytes[i + j] != whatBytes[j]) {
                    flag = false;
                    break;
                }
            if (flag) {
                found = true;
                break;
            }
        }

        return found;
    }

    function _lowerAndFilterControlChars(string memory _base) private pure returns (string memory) {

        bytes memory _baseBytes = bytes(_base);
        uint256 skip = 0;
        for (uint256 i = 0; i < _baseBytes.length; i++) {
            if (_baseBytes[i] > 0x20) {
                _baseBytes[i - skip] = _lower(_baseBytes[i]);
            } else {
                skip = skip + 1;
            }
        }
        return string(_baseBytes);
    }

    function _lower(bytes1 _b1) private pure returns (bytes1) {

        if (_b1 >= 0x41 && _b1 <= 0x5A) {
            return bytes1(uint8(_b1) + 32);
        }

        return _b1;
    }
}