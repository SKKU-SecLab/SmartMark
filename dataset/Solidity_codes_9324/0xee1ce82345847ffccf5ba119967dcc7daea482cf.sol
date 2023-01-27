
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

library Base64 {

    string internal constant _TABLE = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/";

    function encode(bytes memory data) internal pure returns (string memory) {

        if (data.length == 0) return "";

        string memory table = _TABLE;

        string memory result = new string(4 * ((data.length + 2) / 3));

        assembly {
            let tablePtr := add(table, 1)

            let resultPtr := add(result, 32)

            for {
                let dataPtr := data
                let endPtr := add(data, mload(data))
            } lt(dataPtr, endPtr) {

            } {
                dataPtr := add(dataPtr, 3)
                let input := mload(dataPtr)


                mstore8(resultPtr, mload(add(tablePtr, and(shr(18, input), 0x3F))))
                resultPtr := add(resultPtr, 1) // Advance

                mstore8(resultPtr, mload(add(tablePtr, and(shr(12, input), 0x3F))))
                resultPtr := add(resultPtr, 1) // Advance

                mstore8(resultPtr, mload(add(tablePtr, and(shr(6, input), 0x3F))))
                resultPtr := add(resultPtr, 1) // Advance

                mstore8(resultPtr, mload(add(tablePtr, and(input, 0x3F))))
                resultPtr := add(resultPtr, 1) // Advance
            }

            switch mod(mload(data), 3)
            case 1 {
                mstore8(sub(resultPtr, 1), 0x3d)
                mstore8(sub(resultPtr, 2), 0x3d)
            }
            case 2 {
                mstore8(sub(resultPtr, 1), 0x3d)
            }
        }

        return result;
    }
}// MIT
pragma solidity 0.8.7;


contract ASCIIGenerator is Ownable {

    using Base64 for string;
    using Strings for uint256;

    uint256 [][] public imageRows;
    string internal description = "MEV Army Legion Banners by x0r are fully on-chain and customizable. Banners are legion owned, and when you customize a banner, it will change for everyone who owns that banner.";
    string internal SVGHeaderPartOne = "<svg xmlns='http://www.w3.org/2000/svg' viewBox='0 0 1500 550'><defs><style>.cls-1{font-size: 10px; fill:";
    string internal SVGHeaderPartTwo = ";font-family: monospace}</style></defs><g><rect width='1500' height='550' fill='black' />";
    string internal firstTextTagPart = "<text lengthAdjust='spacing' textLength='1500' class='cls-1' x='0' y='";
    string internal SVGFooter = "</g></svg>";
    uint256 internal tspanLineHeight = 12;



    function generateMetadata(string memory _legionName, uint256 _legion, string memory _fillChar, string memory _color) public view returns (string memory){

        string memory SVG = generateSVG(_legion, _fillChar, _color);

        string memory metadata = Base64.encode(bytes(string(abi.encodePacked('{"name":"', _legionName, ' Banner','","description":"', description,'","image":"', SVG, '"}'))));
        
        return string(abi.encodePacked('data:application/json;base64,', metadata));
    }

    function generateSVG(uint256 _legion, string memory _fillChar, string memory _color) public view returns (string memory){


        string [45] memory rows = generateCoreAscii(_legion, _fillChar);

        string memory SVGHeader = string(abi.encodePacked(SVGHeaderPartOne, _color, SVGHeaderPartTwo));

        string memory _firstTextTagPart = firstTextTagPart;

        string memory center;
        string memory span;
        uint256 y = tspanLineHeight;

        for(uint256 i; i < rows.length; i++){
            span = string(abi.encodePacked(_firstTextTagPart, y.toString(), "'>", rows[i], "</text>")); 
            center = string(abi.encodePacked(center, span));
            y += tspanLineHeight;
        }

        string memory SVGImage = Base64.encode(bytes(string(abi.encodePacked(SVGHeader, center, SVGFooter))));
        return string(abi.encodePacked('data:image/svg+xml;base64,', SVGImage));
    }

    function generateCoreAscii(uint256 _legion, string memory _fillChar) public view returns (string [45] memory){

        string [45] memory asciiImage;

        for (uint256 i; i < asciiImage.length; i++) {
            asciiImage[i] = rowToString(imageRows[_legion - 1][i], _fillChar);
        }
        
        return asciiImage;
    }

    function rowToString(uint256 _row, string memory _fillchar) internal pure returns (string memory){

        string memory rowString;
        
        for (uint256 i; i < 250; i++) {
            if ( ((_row >> 1 * i) & 1) == 0) {
                rowString = string(abi.encodePacked(rowString, "."));
            } else {
                rowString = string(abi.encodePacked(rowString, _fillchar));
            }
        }

        return rowString;
    }


    

    function storeImageStores(uint256 [][] memory _imageRows) external onlyOwner {

        imageRows = _imageRows;
    }

    function setDescription(string calldata _description) external onlyOwner {

        description = _description;
    }

    function setSVGParts(
        uint256 _tspanLineHeight, 
        string calldata _SVGHeaderPartOne, 
        string calldata _SVGHeaderPartTwo,
        string calldata _firstTextTagPart,
        string calldata _SVGFooter) external onlyOwner {

            tspanLineHeight = _tspanLineHeight;
            SVGHeaderPartOne = _SVGHeaderPartOne;
            SVGHeaderPartTwo = _SVGHeaderPartTwo;
            firstTextTagPart = _firstTextTagPart;
            SVGFooter = _SVGFooter;
    }

    function getSVGParts() external view returns (string memory, string memory, string memory, string memory, uint256){

        return (SVGHeaderPartOne, SVGHeaderPartTwo, firstTextTagPart, SVGFooter, tspanLineHeight);
    }

}