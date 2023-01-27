pragma solidity >=0.5.0;

library Base64 {

    bytes32 internal constant TABLE0 = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdef';
    bytes32 internal constant TABLE1 = 'ghijklmnopqrstuvwxyz0123456789+/';

    function encode(bytes memory data) internal pure returns (string memory) {

        uint256 bitLen = data.length * 8;
        if (bitLen == 0) return '';

        uint256 encodedLen = (data.length * 4 + 2) / 3;
        if (encodedLen % 4 != 0) encodedLen += 4 - (encodedLen % 4);

        bytes memory result = new bytes(encodedLen);

        for (uint256 i = 0; i < encodedLen; i++) {
            uint256 bitStartIndex = (i * 6);
            if (bitStartIndex >= bitLen) {
                result[i] = '=';
            } else {
                uint256 byteIndex = (bitStartIndex / 8);
                uint8 bsiMod8 = uint8(bitStartIndex % 8);
                if (bsiMod8 < 3) {
                    uint8 c = (uint8(data[byteIndex]) >> (2 - bsiMod8)) % 64;
                    if (c < 32) result[i] = TABLE0[c];
                    else result[i] = TABLE1[c - 32];
                } else {
                    uint16 bytesCombined =
                        (uint16(uint8(data[byteIndex])) << 8) +
                            (byteIndex == data.length - 1 ? 0 : uint16(uint8(data[byteIndex + 1])));

                    uint8 c = uint8((bytesCombined >> uint8(10 - bsiMod8)) % 64);

                    if (c < 32) result[i] = TABLE0[c];
                    else result[i] = TABLE1[c - 32];
                }
            }
        }
        return string(result);
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
}// GPL-3.0
pragma solidity >=0.7.0 <0.9.0;


library PuzzleGenerator {


    struct Rect {
        uint x; 
        uint y;
        uint width;
        uint height;
        Color color;
    }
    
    enum Color {
        red,
        blue,
        white,
        yellow,
        black
     }

    struct Traits {
        uint score;
        string dominantColor;
        uint rectangles;
    }

    uint internal constant denominator = 20;
    uint internal constant tolerance = 25;

    function generateMetadata(uint tokenId) public view returns (string memory)
    {   

  
        uint rectsWanted = uint( (random(tokenId) % 10) + 6); //6-16
        Rect[] memory rectangles = generateRectangles(tokenId, rectsWanted, 500, 500);
    
        Traits memory traits = calculateTraits(rectangles);
        string memory json =  Base64.encode(abi.encodePacked('{"name":"Mondrian puzzle #', Strings.toString(tokenId) ,'", "description":"A randomly generated and colorful Mondrian Puzzle, fully generated and stored on the chain.","image": "data:image/svg+xml;base64,', Base64.encode(generateSVG(rectangles)), '", "attributes": [ { "trait_type": "Mondrian Score", "value": "', Strings.toString(traits.score), '" },{ "trait_type": "Dominant color", "value": "', traits.dominantColor, '"},{ "trait_type": "Rectangles used", "value":"', Strings.toString(traits.rectangles), '" } ]}'));

        return json;
    }


    function generateSVG(Rect[] memory rectangles) internal pure returns (bytes memory)
    {

        bytes memory output = abi.encodePacked("<svg xmlns='http://www.w3.org/2000/svg' xmlns:v='https://vecta.io/nano' width='", Strings.toString(rectangles[0].width), "' height='", Strings.toString(rectangles[0].height), "' stroke-width='5' stroke='black' >");         
        for(uint i = 0; i < rectangles.length; i ++)
        {
            output = abi.encodePacked(output, "<rect x='", Strings.toString(rectangles[i].x), "' y='", Strings.toString(rectangles[i].y), "' width='", Strings.toString(rectangles[i].width), "' height='", Strings.toString(rectangles[i].height), "' fill='", stringFromColor(rectangles[i].color), """' />" );
        }
        return abi.encodePacked(output, "</svg>");        
    }

    function calculateTraits(Rect[] memory rectangles) private pure returns (Traits memory)
    {

        uint small = 99999;
        uint large = 0;        
        uint[] memory colorsUsed = new uint[](5);

        for(uint i = 1; i < rectangles.length; i++)
        {
            uint area = (rectangles[i].width/denominator) * (rectangles[i].height/denominator);
            colorsUsed[uint(rectangles[i].color)] += area;

            if(area < small){
                small = area;
            } else if(area > large){
                large = area;
            }            
        }

        Color dColor = Color.red; //0
        for(uint i = 1; i < colorsUsed.length;i++)
        {
            if(colorsUsed[i] > colorsUsed[uint(dColor)])
                dColor = Color(i);
        }
        return Traits({score: large-small, dominantColor: stringFromColor(dColor), rectangles: rectangles.length-1 });
    }

    function generateRectangles(uint tokenId, uint wantedRects, uint canvas_width, uint canvas_height) private view returns (Rect[] memory)
    {


        Color[12] memory colors = [Color.red, Color.red, Color.red, Color.blue, Color.blue, Color.blue, Color.white, Color.white, Color.yellow, Color.yellow, Color.yellow, Color.black];
        Rect[] memory rectangles = new Rect[](wantedRects+1);
        uint counter = 0;
        uint probability = 5;
        uint seed = (tokenId**wantedRects) ;
        uint numerator = uint(denominator)/(wantedRects/2);        
        
        Rect memory availableRect = Rect({ x:0, y:0, width: canvas_width, height:canvas_height, color: Color.white });
        Rect memory newRect;

        rectangles[counter++] = availableRect;

        while (counter < rectangles.length && (availableRect.width >= tolerance && availableRect.height >= tolerance))
        {
            seed += counter;            
            uint fraction = (random(seed) % numerator) +1; 
            
            Color newColor = colors[random(seed) % colors.length];                
            while (newColor == availableRect.color )
                newColor = colors[random(++seed) % colors.length];
 
            if((random(seed) % 10) > probability) //Vertical 
            {
                probability = probability+2;
                uint new_width = (canvas_width * fraction) / denominator;
                                
                while(new_width >= availableRect.width)
                {
                    fraction = (random(++seed) % numerator) + 1;
                    new_width = (canvas_width * fraction) / denominator;
                }

                uint newX = availableRect.x;
                uint deltaX = availableRect.x + new_width;
                if((random(++seed) % 10) >= 5 ){
                    newX = availableRect.width + availableRect.x - new_width;
                    deltaX = availableRect.x;
                }

                newRect = Rect({x: newX, y: availableRect.y, width: new_width, height: availableRect.height, color: newColor});
                rectangles[counter++] = newRect;
                availableRect = Rect({x: deltaX, y: availableRect.y, width: availableRect.width - newRect.width, height: availableRect.height, color: newRect.color});
            }
            else //Horizontal
            {
                if(probability > 2)
                    probability = probability - 2;

                uint new_height = (canvas_height * fraction) / denominator;

                while(new_height >= availableRect.height)
                {
                    fraction = (random(++seed)% numerator) +1;
                    new_height = (canvas_height * fraction) / denominator;
                }        

                uint newY = availableRect.y;
                uint deltaY = availableRect.y + new_height;
                if((random(++seed) % 10) < 5){
                    newY = availableRect.height + availableRect.y - new_height;
                    deltaY = availableRect.y;
                }

                newRect = Rect({x: availableRect.x, y: newY, width: availableRect.width, height: new_height, color: newColor});
                rectangles[counter++] = newRect;
                availableRect = Rect({x: availableRect.x, y: deltaY, width: availableRect.width, height: availableRect.height-new_height, color: newRect.color});
            }
        }            
        return rectangles;
    }


    function random(uint seed) private view returns (uint) {

        return uint(keccak256(abi.encodePacked( block.difficulty, seed)));
    }
    
    function stringFromColor(Color color) private pure returns (string memory) {

        if(color == Color.red)
            return "red";
        else if(color == Color.blue)
            return "blue";
        else if(color == Color.white)
            return "white";
        else if(color == Color.yellow)
            return "yellow";
        else if(color == Color.black)
            return "black";
        else
            return "green";
    }
}