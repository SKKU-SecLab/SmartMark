


pragma solidity ^0.8.9;

library NormieLib {


    struct Normie {
        uint32 skinType; // Max number is 4,294,967,296
        uint32 hair; 
        uint32 eyes;
        uint32 mouth;
        uint32 torso;
        uint32 pants;
        uint32 shoes;
        uint32 accessoryOne;
        uint32 accessoryTwo;
        uint32 accessoryThree;
    }

    struct Trait {
        string traitName;
        string traitType;
        string hash;
        uint16 pixelCount;
        uint32 traitID;
    }

    string internal constant TABLE = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/";

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
            return "a";
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

    function parseInt(string memory _a) internal pure
    returns (uint8 _parsedInt) {

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

    function substring(string memory str, uint256 startIndex, uint256 endIndex) internal pure 
    returns (string memory) {

        bytes memory strBytes = bytes(str);
        bytes memory result = new bytes(endIndex - startIndex);
        for (uint256 i = startIndex; i < endIndex; i++) {
            result[i - startIndex] = strBytes[i];
        }
        return string(result);
    }
}


pragma solidity ^0.8.9;


contract NormieTraits {

    using NormieLib for uint8;

    address private owner;
    uint256 private SEED_NONCE = 0;
    mapping(address => bool) private adminAccess;
    NormieLib.Trait private emptyTrait = NormieLib.Trait("Empty", "Empty", "", 0, 1000001);

    string public colorString = ".c000{fill:#503e38}.c001{fill:#228b22}.c002{fill:#562c1a}.c003{fill:#313131}.c004{fill:#fee761}.c005{fill:#ff0044}"
    ".c006{fill:#ffffff}.c007{fill:#01badb}.c008{fill:#b9f2ff}.c009{fill:#000000}.c00A{fill:#01f8fc}.c00B{fill:#0088fc}.c00C{fill:#039112}.c00D{fill:#1a3276}"
    ".c00E{fill:#e2646d}.c00F{fill:#ea8c8f}.c00G{fill:#f6757a}.c00H{fill:#7234b2}.c00I{fill:#b881ef}.c00J{fill:#b90e0a}.c00K{fill:#e43b44}.c00L{fill:#f5999e}"
    ".c00M{fill:#1258d3}.c00N{fill:#733e39}.c00O{fill:#2dcf51}.c00P{fill:#260701}.c00Q{fill:#743d2b}.c00R{fill:#dcbeb5}.c00S{fill:#e8b796}.c00T{fill:#67371a}"
    ".c00U{fill:#874f2e}.c00V{fill:#182812}.c00W{fill:#115c35}.c00X{fill:#ff9493}.c00Y{fill:#a22633}.c00Z{fill:#302f2f}.c010{fill:#f0d991}.c011{fill:#f2e7c7}"
    ".c012{fill:#0099db}.c013{fill:#2ce8f5}.c014{fill:#124e89}.c015{fill:#b86f50}.c016{fill:#777777}.c017{fill:#afafaf}.c018{fill:#878787}.c019{fill:#ffed1b}"
    ".c01A{fill:#1b1a1b}.c01B{fill:#131314}.c01C{fill:#191970}.c01D{fill:#bb8b1f}.c01E{fill:#f8f7ed}.c01F{fill:#072083}.c01G{fill:#f65c1a}.c01H{fill:#4b5320}"
    ".c01I{fill:#8a9294}.c01J{fill:#969cba}.c01K{fill:#c0c0c0}.c01L{fill:#8c92ac}.c01M{fill:#01796f}.c01N{fill:#ce1141}.c01O{fill:#ff007f}.c01P{fill:#b6005b}"
    ".c01Q{fill:#feed26}.c01R{fill:#dccd21}.c01S{fill:#080808}.c01T{fill:#b2ffff}.c01U{fill:#18a8d8}.c01V{fill:#818589}.c01W{fill:#98fb98}.c01X{fill:#e0c4ff}"
    ".c01Y{fill:#e1c4ff}.c01Z{fill:#c0a8da}.c020{fill:#ce2029}.c021{fill:#b01b23}.c022{fill:#87ceeb}.c023{fill:#ff0000}";
    uint32 public CURRENT_TRAIT = 1;

    mapping(uint256 => uint256[]) public currentCollectionTraits;
    mapping(uint256 => NormieLib.Trait) public traitIDToTrait;

    string[] LETTERS = ["a","b","c","d","e","f","g","h","i","j","k","l","m","n","o","p","q","r","s","t","u","v","w","x","y","z"];

    uint256[][10] public traitRarity;

    modifier onlyOwner() {

        require(owner == msg.sender, "Not the owner");
        _;
    }

    modifier onlyAdmin() {

        require(adminAccess[msg.sender], "No admin access");
        _;
    }
    
    constructor() {
        owner = msg.sender;
        traitIDToTrait[1000001] = emptyTrait;

        traitRarity[0] = [2500, 5000, 7500, 10000];
        traitRarity[1] = [400, 800, 1600, 2400, 3200, 4200, 5200, 6600, 8000, 10000];
        traitRarity[2] = [800, 1600, 2800, 4000, 5500, 7000, 8500, 10000];
        traitRarity[3] = [200, 400, 1300, 2200, 4150, 6100, 8050, 10000];
        traitRarity[4] = [200, 800, 1400, 2000, 3000, 4000, 5000, 6600, 8200, 10000];
        traitRarity[5] = [200, 600, 1600, 2800, 4000, 6000, 8000, 10000];
        traitRarity[6] = [100, 600, 1100, 2600, 4100, 7050, 10000];
        traitRarity[7] = [100,600,1100,2100,10000];
        traitRarity[8] = [100,800,2400,4400,10000];
        traitRarity[9] = [100,600,2100,10000];
    }


    function generateNormie(uint256 tokenID, address _address) external onlyAdmin
    returns (NormieLib.Normie memory) {

        for (uint256 i=0; i < 10; i++){
            require(traitRarity[i].length == currentCollectionTraits[i].length, "Trait arrays mismatch");
        }
        uint256[] memory generatedHash = hash(tokenID, _address);

        return NormieLib.Normie(
            uint32(currentCollectionTraits[0][generatedHash[0]]),
            uint32(currentCollectionTraits[1][generatedHash[1]]),
            uint32(currentCollectionTraits[2][generatedHash[2]]),
            uint32(currentCollectionTraits[3][generatedHash[3]]),
            uint32(currentCollectionTraits[4][generatedHash[4]]),
            uint32(currentCollectionTraits[5][generatedHash[5]]),
            uint32(currentCollectionTraits[6][generatedHash[6]]),
            uint32(currentCollectionTraits[7][generatedHash[7]]),
            uint32(currentCollectionTraits[8][generatedHash[8]]),
            uint32(currentCollectionTraits[9][generatedHash[9]])
            );
    }

    function hash(uint256 _t, address _a) public onlyAdmin 
    returns (uint256[] memory) {

        uint256[] memory ret = new uint[](10);
        uint counter = SEED_NONCE;
        uint256 _randinput = 0;
        uint256 left = 0;
        uint256 right = 0;
        uint256 mid = 0;
        uint256 traitRarityValue = 0;
        for (uint256 i = 0; i <= 9; i++) {
            counter++;
            _randinput = 
                uint256(
                    keccak256(
                        abi.encodePacked(
                            block.timestamp,
                            block.difficulty,
                            _t,
                            _a,
                            counter
                        )
                    )
                ) % 10000;
            left = 0;
            right = traitRarity[i].length - 1;

            while (left < right){
                mid = (left + right) / 2;
                traitRarityValue = traitRarity[i][mid];
                if (traitRarityValue == _randinput){
                    left = mid;
                    break;
                }
                else if (traitRarityValue < _randinput){
                    left = mid + 1;
                } else {
                    right = mid;
                }
            }
            ret[i] = left;
        }
        SEED_NONCE = counter;
        return ret;
    }


    function getNormieURI(NormieLib.Normie memory normie, uint256 normieID) external view returns (string memory) {

        return string(
            abi.encodePacked(
                "data:application/json;base64,",
                NormieLib.encode(
                    bytes(string(abi.encodePacked(
                        '{"name": "Normie #',
                        NormieLib.toString(normieID),
                        '", "description": "Normies are generated and stored 100% on the blockchain.", "image": "data:image/svg+xml;base64,',
                        NormieLib.encode(
                            bytes(normieToSVG(normie))
                        ),
                        '","attributes":',
                        getMainTraitsString(normie),
                        getOptionalTraitsString(normie),
                        "}")))
            )));
    }

    function getAssetURI(uint256 assetID) external view returns (string memory) {

        NormieLib.Trait memory trait = traitIDToTrait[assetID];
        return string(
            abi.encodePacked(
                "data:application/json;base64,",
                NormieLib.encode(
                    bytes(
                        string(
                            abi.encodePacked(
                                '{"name": "',
                                trait.traitName,
                                '", "description": "Normie assets are generated and stored 100% on the blockchain.", "image": "data:image/svg+xml;base64,',
                                NormieLib.encode(
                                    bytes(assetToSVG(assetID))
                                ),
                                '","attributes":',
                                getSingleTraitString(trait),
                                "}"
                            )
                        )
                    )
                )
            )
        );
    }

    function getTraitTypeByTraitID(uint256 traitID) external view returns (string memory){

        return traitIDToTrait[traitID].traitType;
    }

    function getTraitFromCurrentCollection(uint256 traitIndex, uint256 index) public view
    returns (NormieLib.Trait memory) {

        return traitIDToTrait[currentCollectionTraits[traitIndex][index]];
    }


    function normieToSVG(NormieLib.Normie memory normie) private view returns (string memory) {

        string memory svgString;
        for (uint8 i = 0; i <= 9; i++) {
            NormieLib.Trait memory trait = getNormieTraitObject(normie, i);
            for (uint16 j = 0; j < trait.pixelCount; j++) {
                string memory thisPixel = NormieLib.substring(trait.hash, j * 5, j * 5 + 5);
                uint8 x = letterToNumber(NormieLib.substring(thisPixel, 0, 1));
                uint8 y = letterToNumber(NormieLib.substring(thisPixel, 1, 2));
                svgString = string(
                    abi.encodePacked(
                        svgString,
                        "<rect class='c",
                        NormieLib.substring(thisPixel, 2, 5),
                        "' x='",
                        x.toString(),
                        "' y='",
                        y.toString(),
                        "'/>"
                    )
                );
            }
        }
        svgString = string(
            abi.encodePacked(
                '<svg id="normie-svg" xmlns="http://www.w3.org/2000/svg" preserveAspectRatio="xMinYMin meet" viewBox="0 0 24 24"> ',
                svgString,
                "<style>rect{width:1px;height:1px;} #normie-svg{shape-rendering: crispedges;} ",
                colorString,
                "</style></svg>"
            )
        );
        return svgString;
    }

    function assetToSVG(uint256 assetID) private view returns (string memory) {

        NormieLib.Trait memory trait = traitIDToTrait[assetID];
        string memory svgString;
        for (uint16 j = 0; j < trait.pixelCount; j++) {
            string memory thisPixel = NormieLib.substring(trait.hash, j * 5, j * 5 + 5);
            uint8 x = letterToNumber(NormieLib.substring(thisPixel, 0, 1));
            uint8 y = letterToNumber(NormieLib.substring(thisPixel, 1, 2));
            svgString = string(
                abi.encodePacked(
                    svgString,
                    "<rect class='c",
                    NormieLib.substring(thisPixel, 2, 5),
                    "' x='",
                    x.toString(),
                    "' y='",
                    y.toString(),
                    "'/>"
                )
            );
        }
        svgString = string(
            abi.encodePacked(
                '<svg id="normie-svg" xmlns="http://www.w3.org/2000/svg" preserveAspectRatio="xMinYMin meet" viewBox="0 0 24 24"> ',
                svgString,
                "<style>rect{width:1px;height:1px;} #normie-svg{shape-rendering: crispedges;} ",
                colorString,
                "</style></svg>"
            )
        );
        return svgString;
    }

    function letterToNumber(string memory _inputLetter) private view returns (uint8) {

        for (uint8 i = 0; i < LETTERS.length; i++) {
            if (
                keccak256(abi.encodePacked((LETTERS[i]))) ==
                keccak256(abi.encodePacked((_inputLetter)))
            ) return (i);
        }
        revert();
    }

    function getNormieTraitObject(NormieLib.Normie memory normie, uint256 traitIndex) private view returns (NormieLib.Trait memory) {

            if (traitIndex == 0) {
                return traitIDToTrait[normie.skinType];
            } else if (traitIndex == 1) {
                return traitIDToTrait[normie.pants];
            } else if (traitIndex == 2){
                return traitIDToTrait[normie.shoes];
            } else if (traitIndex == 3) {
                return traitIDToTrait[normie.torso];
            } else if (traitIndex == 4) {
                return traitIDToTrait[normie.mouth];
            } else if (traitIndex == 5) {
                return traitIDToTrait[normie.eyes];
            } else if (traitIndex == 6) {
                return traitIDToTrait[normie.hair];
            } else if (traitIndex == 7) {
                return traitIDToTrait[normie.accessoryOne];
            } else if (traitIndex == 8) {
                return traitIDToTrait[normie.accessoryTwo];
            } else {
                return traitIDToTrait[normie.accessoryThree];
            }
    }

    function getMainTraitsString(NormieLib.Normie memory normie) private view returns (string memory) {

        return string(abi.encodePacked(
                '{"Skin Type":"', 
                traitIDToTrait[normie.skinType].traitName,
                '","Hair":"', traitIDToTrait[normie.hair].traitName,
                '","Eyes":"', traitIDToTrait[normie.eyes].traitName,
                '","Mouth":"', traitIDToTrait[normie.mouth].traitName,
                '","Torso":"', traitIDToTrait[normie.torso].traitName,
                '","Pants":"', traitIDToTrait[normie.pants].traitName,
                '","Shoes":"', traitIDToTrait[normie.shoes].traitName
            )
        );
    }

    function getOptionalTraitsString(NormieLib.Normie memory normie) private view returns (string memory) {
        return string(abi.encodePacked(
                '","Accessory One":"', traitIDToTrait[normie.accessoryOne].traitName,
                '","Accessory Two":"', traitIDToTrait[normie.accessoryTwo].traitName,
                '","Accessory Three":"', traitIDToTrait[normie.accessoryThree].traitName,
                '"}'
            )
        );
    }

    function getSingleTraitString(NormieLib.Trait memory trait) private pure returns (string memory) {

        return string(abi.encodePacked(
                '{"Trait Type":"', 
                trait.traitType,
                '","Trait Name":"', trait.traitName,
                '"}'
            )
        );
    }


    function clearTraitRarity(uint256 traitIndex) external onlyOwner {

        delete traitRarity[traitIndex];
    }

    function clearAllTraitRarities() external onlyOwner {

        for (uint256 i = 0; i < traitRarity.length; i++){
            delete traitRarity[i];
        }
    }

    function addTraitRarity(uint256 traitIndex, uint256[] memory newRarities) external onlyOwner {

        require(traitRarity[traitIndex].length == 0, "Not empty trait");
        require(newRarities[newRarities.length-1] == 10000, "Trait rarity does not end in 10,000. Reverting");
        for (uint256 i = 0; i < newRarities.length; i++) {
            traitRarity[traitIndex].push(newRarities[i]);
        }
        return;
    }

    function clearCurrentCollectionTrait(uint256 index) external onlyOwner {

        delete currentCollectionTraits[index];
    }

    function clearAllTraitsInCurrentCollection() external onlyOwner {

        for (uint256 i = 0; i < 10; i++){
            delete currentCollectionTraits[i];
        }
    }

    function addTraitToTraitMap(NormieLib.Trait[] memory newTraits) external onlyOwner {

        uint32 currentTraitLocal = CURRENT_TRAIT;
        for (uint256 i = 0; i < newTraits.length; i++){
            NormieLib.Trait memory _trait = NormieLib.Trait(
                    newTraits[i].traitName,
                    newTraits[i].traitType,
                    newTraits[i].hash,
                    newTraits[i].pixelCount,
                    1000001 + currentTraitLocal
            );
            traitIDToTrait[1000001 + currentTraitLocal] = _trait;
            currentTraitLocal = currentTraitLocal + 1;
        }
        CURRENT_TRAIT = currentTraitLocal;
    }

    function editTrait(uint256 traitID, NormieLib.Trait memory newTraitData) external onlyOwner {

        NormieLib.Trait memory _trait = traitIDToTrait[traitID];
        _trait.traitName = newTraitData.traitName;
        _trait.traitType = newTraitData.traitType;
        _trait.hash = newTraitData.hash;
        _trait.pixelCount = newTraitData.pixelCount;
        traitIDToTrait[traitID] = _trait;
    }

    function removeTraitFromTraitMap(uint256 traitID) external onlyOwner {

        require(traitID >= 1000000, "Trait ID < 1,000,000");
        traitIDToTrait[traitID] = emptyTrait;
    }

    function addTraitsToCurrentCollection(uint256 traitIndex, uint256[] memory traitID) external onlyOwner {

        require(currentCollectionTraits[traitIndex].length + traitID.length <= traitRarity[traitIndex].length, "Trait array mismatch");
        for (uint256 i = 0; i < traitID.length; i++){
            currentCollectionTraits[traitIndex].push(traitID[i]);
        }
    }

    function setColorString(string calldata _colorString) external onlyOwner {

        colorString = _colorString;
    }

    function addAdminAccess(address _addressToAdd) external onlyOwner {

        adminAccess[_addressToAdd] = true;
    }
}