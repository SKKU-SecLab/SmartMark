
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

library MerkleProof {

    function verify(
        bytes32[] memory proof,
        bytes32 root,
        bytes32 leaf
    ) internal pure returns (bool) {

        return processProof(proof, leaf) == root;
    }

    function processProof(bytes32[] memory proof, bytes32 leaf) internal pure returns (bytes32) {

        bytes32 computedHash = leaf;
        for (uint256 i = 0; i < proof.length; i++) {
            bytes32 proofElement = proof[i];
            if (computedHash <= proofElement) {
                computedHash = keccak256(abi.encodePacked(computedHash, proofElement));
            } else {
                computedHash = keccak256(abi.encodePacked(proofElement, computedHash));
            }
        }
        return computedHash;
    }
}//Contract based on https://docs.openzeppelin.com/contracts/3.x/erc721
pragma solidity ^0.8.9;


interface ICryptoBees {

    struct Token {
        uint8 _type;
        uint8 color;
        uint8 eyes;
        uint8 mouth;
        uint8 nose;
        uint8 hair;
        uint8 accessory;
        uint8 feelers;
        uint8 strength;
        uint48 lastAttackTimestamp;
        uint48 cooldownTillTimestamp;
    }

    function getMinted() external view returns (uint256 m);


    function increaseTokensPot(address _owner, uint256 amount) external;


    function updateTokensLastAttack(
        uint256 tokenId,
        uint48 timestamp,
        uint48 till
    ) external;


    function mint(
        address addr,
        uint256 tokenId,
        bool stake
    ) external;


    function setPaused(bool _paused) external;


    function getTokenData(uint256 tokenId) external view returns (Token memory token);


    function getOwnerOf(uint256 tokenId) external view returns (address);


    function doesExist(uint256 tokenId) external view returns (bool exists);


    function performTransferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external;


    function performSafeTransferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;

}// MIT LICENSE

pragma solidity ^0.8.9;

interface IHoney {

    function mint(address to, uint256 amount) external;


    function mintGiveaway(address[] calldata addresses, uint256 amount) external;


    function burn(address from, uint256 amount) external;


    function disableGiveaway() external;


    function addController(address controller) external;


    function removeController(address controller) external;

}// MIT

pragma solidity ^0.8.9;

library Base64 {

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

                mstore(resultPtr, shl(248, mload(add(tablePtr, and(shr(18, input), 0x3F)))))
                resultPtr := add(resultPtr, 1)
                mstore(resultPtr, shl(248, mload(add(tablePtr, and(shr(12, input), 0x3F)))))
                resultPtr := add(resultPtr, 1)
                mstore(resultPtr, shl(248, mload(add(tablePtr, and(shr(6, input), 0x3F)))))
                resultPtr := add(resultPtr, 1)
                mstore(resultPtr, shl(248, mload(add(tablePtr, and(input, 0x3F)))))
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
}//Contract based on https://docs.openzeppelin.com/contracts/3.x/erc721
pragma solidity ^0.8.9;



contract Traits is Ownable {

    using Strings for uint256;
    using MerkleProof for bytes32[];
    struct Trait {
        string name;
        string png;
    }
    string unrevealedImage;

    ICryptoBees beesContract;
    IHoney honeyContract;
    uint256 public constant MINT_PRICE = .06 ether;
    uint256 public constant MINT_PRICE_DISCOUNT = .055 ether;
    uint256 public constant MINTS_PER_WHITELIST = 6;
    mapping(uint256 => uint256) public existingCombinations;

    uint256 public constant MINT_PRICE_HONEY = 3000 ether;
    uint256 public mintPriceWool = 6600 ether;
    uint256 public constant MAX_TOKENS = 40000;
    uint256 public constant PAID_TOKENS = 10000;
    bool public mintWithEthPresalePaused = true;
    bool public mintWithWoolPaused = true;
    bool public mintWithEthPaused = true;

    mapping(address => uint8) public whitelistMints;

    bytes32 private merkleRootWhitelist;

    string[8] _traitTypes = ["Body", "Color", "Eyes", "Mouth", "Nose", "Hair", "Accessories", "Feelers"];
    mapping(uint8 => mapping(uint8 => Trait)) public traitData;
    string[4] _strengths = ["5", "6", "7", "8"];
    uint8[][24] public rarities;
    uint8[][24] public aliases;

    constructor() {
        rarities[1] = [255, 215, 122, 76, 30, 15];
        aliases[1] = [0, 0, 0, 0, 0, 0];
        rarities[2] = [255, 217, 217, 230, 217, 204, 230, 230, 230, 230, 230, 191, 191, 191, 191];
        aliases[2] = [0, 0, 1, 2, 3, 4, 0, 1, 2, 6, 7, 1, 1, 2, 5];
        rarities[3] = [255, 202, 191, 181, 215, 248, 199, 194, 189, 184, 179, 217, 174, 174, 174, 174, 174];
        aliases[3] = [0, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 0, 1, 2, 3, 4, 10];
        rarities[4] = [255, 230, 204, 192, 179, 179, 179];
        aliases[4] = [0, 0, 1, 2, 0, 1, 3];
        rarities[5] = [255, 127, 204, 230, 115, 115, 115, 115, 115];
        aliases[5] = [0, 0, 1, 3, 5, 4, 1, 1, 2];
        rarities[6] = [255, 99, 53];
        aliases[6] = [0, 0, 0];
        rarities[7] = [255, 140, 204, 102, 179, 89, 89];
        aliases[7] = [0, 0, 1, 2, 0, 1, 3];

        rarities[9] = [255, 153, 153];
        aliases[9] = [0, 0, 1];

        rarities[10] = [255, 220, 184, 148, 222, 186, 151, 225, 189, 153, 117, 240, 204, 168, 133, 145, 145, 97, 97];
        aliases[10] = [0, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 3, 6, 10, 14];

        rarities[11] = [255, 235, 184, 204, 225, 174, 245, 245, 245, 184, 184, 122];
        aliases[11] = [0, 0, 1, 2, 3, 4, 0, 1, 6, 2, 3, 5];

        rarities[12] = [255, 230, 204, 179, 179, 179, 179];
        aliases[12] = [0, 0, 1, 3, 1, 2, 3];

        rarities[13] = [255, 204, 204, 204, 102, 102, 102, 102];
        aliases[13] = [0, 1, 0, 2, 3, 2, 4, 4];

        rarities[14] = [255, 89, 89, 53, 53, 35, 35];
        aliases[14] = [0, 0, 1, 1, 2, 2, 3];

        rarities[15] = [255, 102, 153, 51];
        aliases[15] = [0, 0, 1, 1];

        rarities[17] = [255, 153, 153, 153, 76, 76];
        aliases[17] = [0, 0, 1, 1, 2, 2];

        rarities[18] = [255, 170, 142, 113];
        aliases[18] = [0, 0, 1, 2];

        rarities[19] = [255, 243, 230, 217, 204, 192, 179];
        aliases[19] = [0, 0, 1, 2, 3, 4, 5];

        rarities[21] = [255, 230, 230, 230, 230, 230, 230, 230, 230];
        aliases[21] = [0, 0, 1, 1, 3, 4, 3, 1, 0];

        rarities[22] = [255, 122, 122, 122, 122, 122, 122, 122, 122, 122, 92, 30];
        aliases[22] = [0, 0, 1, 1, 4, 3, 0, 2, 2, 1, 5, 4];
        rarities[23] = [255, 102, 153, 51];
        aliases[23] = [0, 0, 1, 2];
    }

    function setContracts(address _BEES, address _HONEY) external onlyOwner {

        honeyContract = IHoney(_HONEY);
        beesContract = ICryptoBees(_BEES);
    }

    function mintForEth(
        address addr,
        uint256 amount,
        uint256 minted,
        uint256 value,
        bool stake
    ) external {

        require(_msgSender() == address(beesContract), "DONT CHEAT!");
        mintCheck(addr, amount, minted, false, value, true);
        for (uint256 i = 1; i <= amount; i++) {
            beesContract.mint(addr, minted + i, stake);
        }
    }

    function mintForEthWhitelist(
        address addr,
        uint256 amount,
        uint256 minted,
        uint256 value,
        bytes32[] calldata _merkleProof,
        bool stake
    ) external {

        require(_msgSender() == address(beesContract), "DONT CHEAT!");
        bytes32 leaf = keccak256(abi.encodePacked(addr));
        require(MerkleProof.verify(_merkleProof, merkleRootWhitelist, leaf), "You are not on the whitelist!");
        mintCheck(addr, amount, minted, true, value, true);
        for (uint256 i = 1; i <= amount; i++) {
            beesContract.mint(addr, minted + i, stake);
            whitelistMints[addr]++;
        }
    }

    function mintForHoney(
        address addr,
        uint256 amount,
        uint256 minted,
        bool stake
    ) external {

        require(_msgSender() == address(beesContract), "DONT CHEAT!");
        mintCheck(addr, amount, minted, false, 0, false);
        uint256 totalHoneyCost = 0;
        for (uint256 i = 1; i <= amount; i++) {
            totalHoneyCost += mintCost(minted + i);
            beesContract.mint(addr, minted + i, stake);
        }
        honeyContract.burn(addr, totalHoneyCost);
    }

    function mintForWool(
        address addr,
        uint256 amount,
        uint256 minted,
        bool stake
    ) external returns (uint256 totalWoolCost) {

        require(_msgSender() == address(beesContract), "DONT CHEAT!");
        require(!mintWithWoolPaused, "WOOL minting paused");
        require(minted + amount <= PAID_TOKENS, "All tokens on-sale already sold");
        mintCheck(addr, amount, minted, false, 0, false);

        for (uint256 i = 1; i <= amount; i++) {
            totalWoolCost += mintPriceWool;
            beesContract.mint(addr, minted + i, stake);
        }
    }

    function mintCheck(
        address addr,
        uint256 amount,
        uint256 minted,
        bool presale,
        uint256 value,
        bool isEth
    ) private view {

        require(tx.origin == addr, "Only EOA");
        require(minted + amount <= MAX_TOKENS, "All tokens minted");
        if (presale) {
            require(!mintWithEthPresalePaused, "Presale mint paused");
            require(amount > 0 && whitelistMints[addr] + amount <= MINTS_PER_WHITELIST, "Only limited amount for WL mint");
        } else {
            require(amount > 0 && amount <= 10, "Invalid mint amount sale");
        }
        if (isEth) {
            require(minted + amount <= PAID_TOKENS, "All tokens on-sale already sold");
            if (presale) require(amount * MINT_PRICE_DISCOUNT == value, "Invalid payment amount presale");
            else {
                require(amount * MINT_PRICE == value, "Invalid payment amount sale");
                require(!mintWithEthPaused, "Public sale currently paused");
            }
        }
    }

    function getTokenTextType(uint256 tokenId) external view returns (string memory) {

        require(beesContract.doesExist(tokenId), "ERC721Metadata: Nonexistent token");
        return _getTokenTextType(tokenId);
    }

    function _getTokenTextType(uint256 tokenId) private view returns (string memory) {

        uint8 _type = beesContract.getTokenData(tokenId)._type;
        if (_type == 1) return "BEE";
        else if (_type == 2) return "BEAR";
        else if (_type == 3) return "BEEKEEPER";
        else return "NOT REVEALED";
    }

    function setPresaleMintPaused(bool _paused) external onlyOwner {

        mintWithEthPresalePaused = _paused;
    }

    function setWoolMintPaused(bool _paused) external onlyOwner {

        mintWithWoolPaused = _paused;
    }

    function setMintWithEthPaused(bool _paused) external onlyOwner {

        mintWithEthPaused = _paused;
    }

    function setWoolMintPrice(uint256 _price) external onlyOwner {

        mintPriceWool = _price;
    }

    function setMerkleRoot(bytes32 root) public onlyOwner {

        merkleRootWhitelist = root;
    }

    function generate(uint256 seed) public view returns (ICryptoBees.Token memory) {

        require(_msgSender() == address(beesContract), "DONT CHEAT!");
        ICryptoBees.Token memory t = selectTraits(seed);
        return t;
    }

    function selectTraits(uint256 seed) internal view returns (ICryptoBees.Token memory t) {

        uint256 num = ((seed & 0xFFFF) % 100);
        t._type = 1;
        if (num == 0) t._type = 3;
        else if (num < 10) t._type = 2;
        uint8 shift = t._type > 0 ? ((t._type - 1) * 8) : 0;
        seed >>= 16;
        t.color = selectTrait(uint16(seed & 0xFFFF), 1 + shift);
        seed >>= 16;
        t.eyes = selectTrait(uint16(seed & 0xFFFF), 2 + shift);
        seed >>= 16;
        t.mouth = selectTrait(uint16(seed & 0xFFFF), 3 + shift);
        if (t._type != 3) {
            seed >>= 16;
            t.nose = selectTrait(uint16(seed & 0xFFFF), 4 + shift);
        }
        seed >>= 16;
        t.hair = selectTrait(uint16(seed & 0xFFFF), 5 + shift);
        seed >>= 16;
        t.accessory = selectTrait(uint16(seed & 0xFFFF), 6 + shift);
        if (t._type == 1) {
            seed >>= 16;
            t.feelers = selectTrait(uint16(seed & 0xFFFF), 7);
        } else {
            seed >>= 16;
            t.strength = selectTrait(uint16(seed & 0xFFFF), 7 + shift);
        }
    }

    function selectTrait(uint16 seed, uint8 traitType) internal view returns (uint8) {

        uint8 trait = uint8(seed) % uint8(rarities[traitType].length);
        if (seed >> 8 < rarities[traitType][trait]) return trait;
        return aliases[traitType][trait];
    }

    function structToHash(ICryptoBees.Token memory t) internal pure returns (uint256) {

        return uint256(bytes32(abi.encodePacked(t._type, t.color, t.eyes, t.mouth, t.nose, t.hair, t.accessory, t.feelers, t.strength)));
    }

    function mintCost(uint256 tokenId) public pure returns (uint256) {

        if (tokenId <= 20000) return MINT_PRICE_HONEY;
        if (tokenId <= 30000) return 7500 ether;
        return 15000 ether;
    }

    function uploadTraits(
        uint8 traitType,
        string[] calldata traitNames,
        string[] calldata traitImages
    ) external onlyOwner {

        require(traitNames.length == traitImages.length, "Mismatched inputs");
        for (uint256 i = 0; i < traitNames.length; i++) {
            traitData[traitType][uint8(i)] = Trait(traitNames[i], traitImages[i]);
        }
    }

    function uploadUnrevealImage(string calldata image) external onlyOwner {

        unrevealedImage = image;
    }



    function drawTrait(Trait memory trait) internal pure returns (string memory) {

        if (bytes(trait.png).length == 0) return "";
        return
            string(
                abi.encodePacked(
                    '<image x="4" y="4" width="32" height="32" image-rendering="pixelated" preserveAspectRatio="xMidYMid" xlink:href="data:image/png;base64,',
                    trait.png,
                    '"/>'
                )
            );
    }

    function drawUnrevealedImage() internal view returns (string memory) {

        return
            string(
                abi.encodePacked(
                    '<image x="4" y="4" width="32" height="32" image-rendering="pixelated" preserveAspectRatio="xMidYMid" xlink:href="data:image/png;base64,',
                    unrevealedImage,
                    '"/>'
                )
            );
    }

    function drawSVG(uint256 tokenId) public view returns (string memory) {

        ICryptoBees.Token memory s = beesContract.getTokenData(tokenId);
        uint8 shift = s._type > 0 ? ((s._type - 1) * 8) : 0;
        string memory svgString;
        if (s._type == 0) svgString = drawUnrevealedImage();
        else {
            svgString = string(
                abi.encodePacked(
                    drawTrait(traitData[0 + shift][0]),
                    drawTrait(traitData[1 + shift][s.color]),
                    drawTrait(traitData[2 + shift][s.eyes]),
                    drawTrait(traitData[3 + shift][s.mouth]),
                    drawTrait(traitData[4 + shift][s.nose]),
                    drawTrait(traitData[5 + shift][s.hair]),
                    drawTrait(traitData[6 + shift][s.accessory]),
                    drawTrait(traitData[7][s.feelers])
                )
            );
        }

        return
            string(
                abi.encodePacked(
                    '<svg id="cryptobees" width="100%" height="100%" version="1.1" viewBox="0 0 40 40" xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink">',
                    svgString,
                    "</svg>"
                )
            );
    }

    function attributeForTypeAndValue(string memory traitType, string memory value) internal pure returns (string memory) {

        return string(abi.encodePacked('{"trait_type":"', traitType, '","value":"', value, '"}'));
    }

    function compileAttributes(uint256 tokenId) public view returns (string memory) {

        ICryptoBees.Token memory t = beesContract.getTokenData(tokenId);
        string memory textType = _getTokenTextType(tokenId);
        uint8 shift = t._type > 0 ? ((t._type - 1) * 8) : 0;
        string memory traits;
        traits = string(
            abi.encodePacked(
                attributeForTypeAndValue(_traitTypes[1], traitData[1 + shift][t.color].name),
                ",",
                attributeForTypeAndValue(_traitTypes[2], traitData[2 + shift][t.eyes].name),
                ",",
                attributeForTypeAndValue(_traitTypes[3], traitData[3 + shift][t.mouth].name),
                ",",
                attributeForTypeAndValue(_traitTypes[5], traitData[5 + shift][t.hair].name),
                ",",
                attributeForTypeAndValue(_traitTypes[6], traitData[6 + shift][t.accessory].name),
                ","
            )
        );
        if (t._type != 3) {
            traits = string(abi.encodePacked(traits, attributeForTypeAndValue(_traitTypes[4], traitData[4 + shift][t.nose].name), ","));
        }
        if (t._type == 1) {
            traits = string(abi.encodePacked(traits, attributeForTypeAndValue(_traitTypes[7], traitData[7][t.feelers].name), ","));
        } else if (t._type == 2) {
            traits = string(abi.encodePacked(traits, attributeForTypeAndValue("Strength", _strengths[t.strength]), ","));
        } else if (t._type == 3) {
            traits = string(abi.encodePacked(traits, attributeForTypeAndValue("Skill", _strengths[t.strength]), ","));
        }

        return
            string(
                abi.encodePacked(
                    "[",
                    traits,
                    '{"trait_type":"Generation","value":',
                    tokenId <= PAID_TOKENS ? '"Gen 0"' : '"Gen 1"',
                    '},{"trait_type":"Type","value":"',
                    textType,
                    '"}]'
                )
            );
    }

    function tokenURI(uint256 tokenId) public view returns (string memory) {


        string memory textType = _getTokenTextType(tokenId);
        string memory metadata = string(
            abi.encodePacked(
                '{"name": "',
                textType,
                " #",
                uint256(tokenId).toString(),
                '", "type": "',
                textType,
                '", "description": "People realized that the path to prosperity is to relocate to a farm. Some have bought sheep, some land but many ended up with nothing. $HONEY is the new opportunity.',
                '","image": "data:image/svg+xml;base64,',
                Base64.encode(bytes(drawSVG(tokenId))),
                '","attributes":',
                compileAttributes(tokenId),
                "}"
            )
        );

        return string(abi.encodePacked("data:application/json;base64,", Base64.encode(bytes(metadata))));
    }
}