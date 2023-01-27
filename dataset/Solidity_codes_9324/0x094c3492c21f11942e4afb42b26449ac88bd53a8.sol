

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
}


pragma solidity ^0.8.0;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}


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
}


pragma solidity >=0.7.0 <0.9.0;

library Library {

    string internal constant TABLE =
        "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/";

    function encode(bytes memory data) internal pure returns (string memory) {

        if (data.length == 0) return "";

        string memory table = TABLE;

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

                mstore(
                    resultPtr,
                    shl(248, mload(add(tablePtr, and(shr(18, input), 0x3F))))
                )
                resultPtr := add(resultPtr, 1)
                mstore(
                    resultPtr,
                    shl(248, mload(add(tablePtr, and(shr(12, input), 0x3F))))
                )
                resultPtr := add(resultPtr, 1)
                mstore(
                    resultPtr,
                    shl(248, mload(add(tablePtr, and(shr(6, input), 0x3F))))
                )
                resultPtr := add(resultPtr, 1)
                mstore(
                    resultPtr,
                    shl(248, mload(add(tablePtr, and(input, 0x3F))))
                )
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

    function parseInt(string memory _a)
        internal
        pure
        returns (uint8 _parsedInt)
    {

        bytes memory bresult = bytes(_a);
        uint8 mint = 0;
        for (uint8 i = 0; i < bresult.length; i++) {
            if (
                (uint8(uint8(bresult[i])) >= 48) &&
                (uint8(uint8(bresult[i])) <= 57)
            ) {
                mint *= 10;
                mint += uint8(bresult[i]) - 48;
            }
        }
        return mint;
    }
    
    function substring(
        string memory str,
        uint256 startIndex,
        uint256 endIndex
    ) internal pure returns (string memory) {

        bytes memory strBytes = bytes(str);
        bytes memory result = new bytes(endIndex - startIndex);
        for (uint256 i = startIndex; i < endIndex; i++) {
            result[i - startIndex] = strBytes[i];
        }
        return string(result);
    }
}


interface IEcoz {}


contract BananaTreesURI is Ownable {

    IEcoz public ecozContract;
    
    uint256 traitCount = 5;
    uint256 babyTraitCount = 5;

    uint8 randI = 0;

    string []Colors;

    string[] LETTERS;
  
    struct Trait {
        string traitName;
        string traitType;
        string pixels;
        uint256 pixelCount;
    }

    bool public revealed = false;

    string[4] Leg;

    mapping (uint256 => Trait[]) public traitTypes;
    
    mapping (uint256 => Trait[]) public babyTraitTypes;

    mapping (uint256 => string) treeIDToHash;

    mapping (uint256 => uint256) traitTypeCount;
    
    mapping (uint256 => uint256) babyTraitTypeCount;

    function traitGenerator(uint256 thisTraitCount, uint256 traitProbability) internal view returns(uint256) {

        uint256 thisTrait;

        if (traitProbability >= 8000 && traitProbability < 10000) {//common
            thisTrait = 0;
        }   
        else if (traitProbability >=6000 && traitProbability < 8000) {//common
            if(thisTraitCount < 2) {
                thisTrait = 1 % thisTraitCount;
            }
            else {
                thisTrait = 1;
            }
        }
        else if (traitProbability >=4750 && traitProbability < 6000) {//uncommon
            if(thisTraitCount < 3) {
                thisTrait = 2 % thisTraitCount;
            }
            else {
                thisTrait = 2;
            }
        }
        else if (traitProbability >=3500 && traitProbability < 4750) {//uncommon
            if(thisTraitCount < 4) {
                thisTrait = 3 % thisTraitCount;
            }
            else {
                thisTrait = 3;
            }
            
        }
        else if (traitProbability >=2750 && traitProbability < 3500) {//rare
            if(thisTraitCount < 5) {
                thisTrait = 4 % thisTraitCount;
            }
            else {
                thisTrait = 4;
            }
        }
        else if (traitProbability >=2000 && traitProbability < 2750) {//rare
            if(thisTraitCount < 6) {
                thisTrait = 5 % thisTraitCount;
            }
            else {
                thisTrait = 5;
            }
        }
        else if (traitProbability >=1250 && traitProbability < 2000) {//rare
            if(thisTraitCount < 7) {
                thisTrait = 6 % thisTraitCount;
            }
            else {
                thisTrait = 6;
            }
        }
        else if (traitProbability >=750 && traitProbability < 1250) {//super rare
            if(thisTraitCount < 8) {
                thisTrait = 7 % thisTraitCount;
            }
            else {
                thisTrait = 7;
            }
        }
        else if (traitProbability >=250 && traitProbability < 750) {//super rare
            if(traitCount < 9) {
                thisTrait = 8 % thisTraitCount;
            }
            else {
                thisTrait = 8;
            }
        }
        else if (traitProbability >=0 && traitProbability < 250) {//legendary
            if(thisTraitCount < 10) {
                thisTrait = 9 % thisTraitCount;
            }
            else {
                thisTrait = 9;
            }
        }
        return thisTrait;
    }
    
    function treeRandomizer(address user, uint256 treeID) external returns(uint256) {

        require(msg.sender == address(ecozContract));
        uint256 thisTrait;
        if (treeID <= 5850 && treeID > 4053) {
            uint256 value = 7;

            for (uint256 i = 0; i < traitCount; i++) {
                uint256 rand = random(user, treeID);
                thisTrait = traitGenerator(traitTypeCount[i], rand);

                if (i != 3) {
                    treeIDToHash[treeID] = string(abi.encodePacked(treeIDToHash[treeID], Library.toString(thisTrait)));              
                }
                else {
                    treeIDToHash[treeID] = string(abi.encodePacked(treeIDToHash[treeID], Library.toString(thisTrait), Library.toString(thisTrait)));
                    i++;
                }
                value = value + thisTrait;
            }
            if (value < 16) {
                return 5;
            }
            else if (value >= 16 && value < 20) {
                return 6;
            }
            else {
                return 7;
            }
        }
        else if (treeID > 5850) {
            for (uint256 i = 0; i < babyTraitCount; i++) {
                uint256 rand = random(user, treeID);
                treeIDToHash[treeID] = string(abi.encodePacked(treeIDToHash[treeID], Library.toString(traitGenerator(babyTraitTypeCount[i], rand))));
            }
            return 0;
        }
        else {
            return 7;
        }
    } 

    function random(address user, uint256 treeID) internal returns (uint256) {

        randI = randI + 1;
        
        if (randI >= 10) {
            randI = 0;
        }
        return uint256(keccak256(abi.encodePacked(block.difficulty, block.timestamp, user, treeID, randI))) % 10000;
    }

    function letterToNumber(string memory _inputLetter) internal view returns (uint8) {

        for (uint8 i = 0; i < LETTERS.length; i++) {   

            if (keccak256(abi.encodePacked((LETTERS[i]))) ==keccak256(abi.encodePacked((_inputLetter)))) return (i);
        }
        revert();
    }
        
    function letterToColor(string memory _inputLetter) internal view returns (string memory) {

        for (uint8 i = 0; i < LETTERS.length; i++) {

            if (keccak256(abi.encodePacked((LETTERS[i]))) == keccak256(abi.encodePacked((_inputLetter)))) {
                return Colors[i];
                }
            }
            revert();
    }

    function bananaTreeTokenURI(uint256 treeID, uint256 treeWeight) external view virtual returns(string memory) {

        require(msg.sender == address(ecozContract));

        if (treeID <= 5850) {
            string memory metadataString = '{"trait_type":"Species","value":"Banana Tree"},';
            string memory svgString;
            bool[32][32] memory placedPixels;
            uint256 count;
            string memory thisPixel;
            string memory thisTrait;
            uint8 thisTraitIndex;
            string memory BGcolor = 'B6EAFF';

            if (revealed == false && treeID > 4053) {
                thisTrait = Leg[3];
                metadataString = string(abi.encodePacked(metadataString,'{"trait_type":"','Status','","value":"','Unrevealed''"}'));
                BGcolor = '6c6c6c';
                count = bytes(Leg[3]).length / 3;

                for (uint16 j = 0; j < count; j++) {
                    thisPixel = Library.substring(thisTrait, j * 3, j * 3 + 3);
                    uint8 x = letterToNumber(Library.substring(thisPixel, 0, 1));
                    uint8 y = letterToNumber(Library.substring(thisPixel, 1, 2));
            
                    if (placedPixels[x][y]) continue;
            
                    svgString = string(abi.encodePacked(svgString,"<rect fill='#",letterToColor(Library.substring(thisPixel, 2, 3)),"' x='",Library.toString(x),"' y='",Library.toString(y),"'/>"));
                    placedPixels[x][y] = true;
                }

                svgString = string(
                Library.encode(bytes(abi.encodePacked(
                '<svg id="ecoz-svg" xmlns="http://www.w3.org/2000/svg" preserveAspectRatio="xMinYMin meet" viewBox="0 0 32 32"> <rect class="bg" x="0" y="0" />',
                svgString,
                '<style>rect.bg{width:32px;height:32px;fill:#',BGcolor,'} rect{width:1px;height:1px;} #ecoz-svg{shape-rendering: crispedges;} </style></svg>'
                )))
                );

                return string(abi.encodePacked(
                    'data:application/json;base64,',Base64.encode(bytes(abi.encodePacked(
                    '{"name":',
                    '"Banana Tree #',
                    Library.toString(treeID),
                    '", "description":"',
                    "The Banana Tree Ecoz is the abundant producer of the Ecozystem. Their population stays strong and fruitful unless the Bush Bucks get too hungry...",
                    '", "image": "',
                    'data:image/svg+xml;base64,',
                    svgString,'",',
                     '"attributes": [',
                    metadataString,']',
                    '}')))));      
            }     

            if (treeID == 4051) {
                thisTrait = Leg[0];
                metadataString = string(abi.encodePacked(metadataString,'{"trait_type":"','1/1','","value":"','Treedenza''"},','{"trait_type":"','Generation','","value":"','Genesis''"},','{"trait_type":"','Thrive Production','","value":"',Library.toString(treeWeight),'"}'));
                BGcolor = 'e0d195';
            }

            else if (treeID == 4052) {
                thisTrait = Leg[1];
                metadataString = string(abi.encodePacked(metadataString,'{"trait_type":"','1/1','","value":"','Alien''"},','{"trait_type":"','Generation','","value":"','Genesis''"},','{"trait_type":"','Thrive Production','","value":"',Library.toString(treeWeight),'"}'));
                BGcolor = '98e2bb';
            }

            else if (treeID == 4053) {
                thisTrait = Leg[2];
                metadataString = string(abi.encodePacked(metadataString,'{"trait_type":"','1/1','","value":"','Bubble Gum Blossom''"},','{"trait_type":"','Generation','","value":"','Genesis''"},','{"trait_type":"','Thrive Production','","value":"',Library.toString(treeWeight),'"}'));
                BGcolor = '4e3e6f';
            }
            else {
                metadataString = string(abi.encodePacked(metadataString,'{"trait_type":"','Generation','","value":"','Genesis''"},','{"trait_type":"','Thrive Production','","value":"',Library.toString(treeWeight),'"},'));
            }
            
            if (treeID > 4053) {
                for (uint256 i = 0; i < traitCount; i++) {
                    if (i != 4) {
                        thisTraitIndex = Library.parseInt(Library.substring(treeIDToHash[treeID], i, i + 1));
                        metadataString = string(abi.encodePacked(metadataString,'{"trait_type":"',traitTypes[i][thisTraitIndex].traitType,'","value":"',traitTypes[i][thisTraitIndex].traitName,'"}'));
                    }
                    
                    if (i != 3 && i != 4) {
                        metadataString = string(abi.encodePacked(metadataString, ","));
                    }
                }
            } 
            
            for (uint256 i = traitCount-1; i >=0 ; i--) {
                if (treeID > 4053) {
                    thisTraitIndex = Library.parseInt(Library.substring(treeIDToHash[treeID], i, i + 1));
                    count = traitTypes[i][thisTraitIndex].pixelCount;
                }
                else {
                    if (treeID == 4051) {
                        count = bytes(Leg[0]).length / 3;
                    }
                    else if (treeID == 4052) {
                        count = bytes(Leg[1]).length / 3;
                    }
                    else if (treeID == 4053) {
                        count = bytes(Leg[2]).length / 3;
                    }
                }

                for (uint16 j = 0; j < count; j++) {
                    if (treeID < 4054) {
                        thisPixel = Library.substring(thisTrait, j * 3, j * 3 + 3);
                    }
                    else {
                        thisPixel = Library.substring(traitTypes[i][thisTraitIndex].pixels, j * 3, j * 3 + 3);
                    }

                    uint8 x = letterToNumber(Library.substring(thisPixel, 0, 1));
                    uint8 y = letterToNumber(Library.substring(thisPixel, 1, 2));
            
                    if (placedPixels[x][y]) continue;
            
                    svgString = string(abi.encodePacked(svgString,"<rect fill='#",letterToColor(Library.substring(thisPixel, 2, 3)),"' x='",Library.toString(x),"' y='",Library.toString(y),"'/>"));
                    placedPixels[x][y] = true;
                }

                if (i == 0 || treeID < 4054) {
                    break;
                }
            }
                

            svgString = string(
                Library.encode(bytes(abi.encodePacked(
                '<svg id="ecoz-svg" xmlns="http://www.w3.org/2000/svg" preserveAspectRatio="xMinYMin meet" viewBox="0 0 32 32"> <rect class="bg" x="0" y="0" />',
                svgString,
                '<style>rect.bg{width:32px;height:32px;fill:#',BGcolor,'} rect{width:1px;height:1px;} #ecoz-svg{shape-rendering: crispedges;} </style></svg>'
                )))
                );

            return string(abi.encodePacked(
                'data:application/json;base64,',Base64.encode(bytes(abi.encodePacked(
                '{"name":',
                '"Banana Tree #',
                Library.toString(treeID),
                '", "description":"',
                "The Banana Tree Ecoz is the abundant producer of the Ecozystem. Their population stays strong and fruitful unless the Bush Bucks get too hungry...",
                '", "image": "',
                'data:image/svg+xml;base64,',
                svgString,'",',
                 '"attributes": [',
                metadataString,']',
                '}')))));
        }
        else {
            string memory metadataString = '{"trait_type":"Species","value":"Banana Tree"},';
            string memory svgString;
            bool[32][32] memory placedPixels;
            uint256 count;
            string memory thisPixel;
            uint8 thisTraitIndex;
            string memory BGcolor = 'B6EAFF';
            metadataString = string(abi.encodePacked(metadataString,'{"trait_type":"','Generation','","value":"','Baby''"},'));

            for (uint256 i = 0; i < babyTraitCount; i++) {
                thisTraitIndex = Library.parseInt(Library.substring(treeIDToHash[treeID], i, i + 1));
                metadataString = string(abi.encodePacked(metadataString,'{"trait_type":"',babyTraitTypes[i][thisTraitIndex].traitType,'","value":"',babyTraitTypes[i][thisTraitIndex].traitName,'"}'));
                    
                if (i != babyTraitCount-1) {
                    metadataString = string(abi.encodePacked(metadataString, ","));
                }
            }
            
            for (uint256 i = babyTraitCount-1; i >=0; i--) {
                thisTraitIndex = Library.parseInt(Library.substring(treeIDToHash[treeID], i, i + 1));
                count = babyTraitTypes[i][thisTraitIndex].pixelCount;

                for (uint16 j = 0; j < count; j++) {
                    thisPixel = Library.substring(babyTraitTypes[i][thisTraitIndex].pixels, j * 3, j * 3 + 3);
                    uint8 x = letterToNumber(Library.substring(thisPixel, 0, 1));
                    uint8 y = letterToNumber(Library.substring(thisPixel, 1, 2));

                    if (placedPixels[x][y]) continue;

                    svgString = string(abi.encodePacked(svgString,"<rect fill='#",letterToColor(Library.substring(thisPixel, 2, 3)),"' x='",Library.toString(x),"' y='",Library.toString(y),"'/>"));
                    placedPixels[x][y] = true;
                }

                if (i == 0) {
                    break;
                }
            }
        

            svgString = string(
                Library.encode(bytes(abi.encodePacked(
                '<svg id="ecoz-svg" xmlns="http://www.w3.org/2000/svg" preserveAspectRatio="xMinYMin meet" viewBox="0 0 32 32"> <rect class="bg" x="0" y="0" />',
                svgString,
                '<style>rect.bg{width:32px;height:32px;fill:#',BGcolor,'} rect{width:1px;height:1px;} #ecoz-svg{shape-rendering: crispedges;} </style></svg>'
                )))
                );

            return string(abi.encodePacked(
                'data:application/json;base64,',Base64.encode(bytes(abi.encodePacked(
                '{"name":',
                '"Banana Tree #',
                Library.toString(treeID),
                '", "description":"',
                "The Banana Tree Ecoz is the abundant producer of the Ecozystem. Their population stays strong and fruitful unless the Bush Bucks get too hungry...",
                '", "image": "',
                'data:image/svg+xml;base64,',
                svgString,'",',
                 '"attributes": [',
                metadataString,']',
                '}')))));    
        }
    }

    function setTreeLegendary(string memory leg1, string memory leg2, string memory leg3, string memory unrevealed) public onlyOwner {

        Leg[0] = leg1;
        Leg[1] = leg2;
        Leg[2] = leg3;
        Leg[3] = unrevealed;
        return;
    }
    
    function setTreeColorsLETTERS(string[87] memory colors, string[87] memory letters) public onlyOwner {

        Colors = colors;
        LETTERS = letters;
        return;
    }

    function addTreeTraitType(uint256 _traitTypeIndex, Trait[] memory traits) public onlyOwner {

        for (uint256 i = 0; i < traits.length; i++) {
            traitTypes[_traitTypeIndex].push(
                Trait(
                    traits[i].traitName,
                    traits[i].traitType,
                    traits[i].pixels,
                    traits[i].pixelCount
                )
            );
        }
        
        traitTypeCount[_traitTypeIndex] = traitTypeCount[_traitTypeIndex] + traits.length;

        return;
    }

    function addBabyTreeTraitType(uint256 _traitTypeIndex, Trait[] memory traits) public onlyOwner {

        for (uint256 i = 0; i < traits.length; i++) {
            babyTraitTypes[_traitTypeIndex].push(
                Trait(
                    traits[i].traitName,
                    traits[i].traitType,
                    traits[i].pixels,
                    traits[i].pixelCount
                )
            );
        }
        babyTraitTypeCount[_traitTypeIndex] = babyTraitTypeCount[_traitTypeIndex] + traits.length;

        return;
    }

    function clearTraitType(uint256 index) public onlyOwner {

        delete traitTypes[index];
        traitTypeCount[index] = 0;
        return;
    }
    function clearBabyTraitType(uint256 index) public onlyOwner {

        delete babyTraitTypes[index];
        babyTraitTypeCount[index] = 0;
        return;
    }

    function setTreeEcoz(address ecozAddress) external onlyOwner {

        ecozContract = IEcoz(ecozAddress);
        return;
    }
    
    function reveal() public onlyOwner {

        revealed = true;
        return;
    }
}