
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

interface GearTypes {

  struct Gear {
    uint8 background;
    uint8 armament;
    uint8 class;
    uint8 rarity;
    uint8 meansOfAcquisition;
    uint8 faction;
    uint8 powerLevel;
  }
}// MIT

pragma solidity ^0.8.0;
library Base64 {

    bytes internal constant TABLE = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/";

    function encode(bytes memory data) internal pure returns (string memory) {

        uint256 len = data.length;
        if (len == 0) return "";

        uint256 encodedLen = 4 * ((len + 2) / 3);

        bytes memory result = new bytes(encodedLen + 32);

        bytes memory table = TABLE;

        assembly {
            let tablePtr := add(table, 1)
            let resultPtr := add(result, 32)

            for {
                let i := 0
            } lt(i, len) {

            } {
                i := add(i, 3)
                let input := and(mload(add(data, i)), 0xffffff)

                let out := mload(add(tablePtr, and(shr(18, input), 0x3F)))
                out := shl(8, out)
                out := add(out, and(mload(add(tablePtr, and(shr(12, input), 0x3F))), 0xFF))
                out := shl(8, out)
                out := add(out, and(mload(add(tablePtr, and(shr(6, input), 0x3F))), 0xFF))
                out := shl(8, out)
                out := add(out, and(mload(add(tablePtr, and(input, 0x3F))), 0xFF))
                out := shl(224, out)

                mstore(resultPtr, out)

                resultPtr := add(resultPtr, 4)
            }

            switch mod(len, 3)
            case 1 {
                mstore(sub(resultPtr, 2), shl(240, 0x3d3d))
            }
            case 2 {
                mstore(sub(resultPtr, 1), shl(248, 0x3d))
            }

            mstore(result, encodedLen)
        }

        return string(result);
    }
}// MIT


pragma solidity 0.8.7;
pragma abicoder v2;

contract ChainRunnerGearRenderer is Ownable {

  using Strings for uint256;
  using Strings for uint8;

  struct TraitImageInput {
    uint8 armamentId;
    uint8 classId;
    uint8 rarityId;
    string image;
  }

  uint256 internal constant MAX = 5000;
  string[7] internal _traits = [
    "Background",
    "Armament",
    "Class",
    "Means of Acquisition",
    "Faction",
    "Rarity",
    "Power Level"
  ];

  mapping(uint8 => mapping(uint8 => mapping(uint8 => string))) public traitImages;
  mapping(uint8 => mapping(uint8 => string)) public traitNames;
  mapping(uint8 => string) public factionImages;

  function uploadTraitNames(
    uint8 traitType,
    uint8[] calldata traitIds,
    string[] calldata traits
  ) external onlyOwner {

    require(traitIds.length == traits.length, "Mismatched inputs");
    for (uint i = 0; i < traits.length; i++) {
      traitNames[traitType][traitIds[i]] = traits[i];
    }
  }

  function uploadTraitImages(TraitImageInput[] calldata inputs) external onlyOwner {

    for (uint8 i = 0; i < inputs.length; i++) {
      TraitImageInput memory inp = inputs[i];
      traitImages[inp.armamentId][inp.classId][inp.rarityId] = inp.image;
    }
  }

  function uploadFactionImages(string[] calldata inputs) external onlyOwner {

    for (uint8 i = 0; i < inputs.length; i++) {
      factionImages[i] = inputs[i];
    }
  }

  function tokenURI(uint256 tokenId, GearTypes.Gear memory g) external view returns (string memory) {

    string memory image = Base64.encode(bytes(generateSVGImage(g)));

    return string(
      abi.encodePacked(
        "data:application/json;base64,",
        Base64.encode(
          bytes(
            abi.encodePacked(
              '{"name":"',
              traitNames[5][g.rarity],
              ' ',
              traitNames[3][g.meansOfAcquisition],
              ' ',
              traitNames[4][g.faction],
              ' ',
              traitNames[1][g.armament],
              ' ',
              traitNames[2][g.class],
              ' #',
              tokenId.toString(),
              '", ',
              '"attributes": ',
              compileAttributes(g),
              ', "image": "',
              "data:image/svg+xml;base64,",
              image,
              '"}'
            )
          )
        )
      )
    );
  }

  function generateSVGImage(GearTypes.Gear memory params) internal view returns (string memory) {

    return string(
      abi.encodePacked(
        generateSVGHeader(),
        generateBackground(params.background),
        generateArmament(params),
        generateFaction(params),
        "</svg>"
      )
    );
  }

  function generateSVGHeader() private pure returns (string memory) {

    return
    string(
      abi.encodePacked(
        '<svg version="1.1" xmlns="http://www.w3.org/2000/svg" x="0px" y="0px"',
        ' viewBox="0 0 480 480" style="enable-background:new 0 0 480 480;" xml:space="preserve">'
      )
    );
  }

  function generateArmament(GearTypes.Gear memory gear) internal view returns (string memory) {

    bytes memory svgString = abi.encodePacked(
      '<image x="0" y="0" width="480" height="480" image-rendering="pixelated" preserveAspectRatio="xMidYMid" href="data:image/png;base64,',
      traitImages[gear.armament][gear.class][gear.rarity],
      '"/>'
    );
    return string(svgString);
  }

  function generateFaction(GearTypes.Gear memory gear) internal view returns (string memory) {

    bytes memory svgString = abi.encodePacked(
      '<image x="0" y="0" width="480" height="480" image-rendering="pixelated" preserveAspectRatio="xMidYMid" href="data:image/png;base64,',
      factionImages[gear.faction],
      '"/>'
    );
    return string(svgString);
  }

  function generateBackground(uint8 backgroundId) internal view returns (string memory) {

    return string(
      abi.encodePacked(
        '<rect x="0" y="0" style="width:480px;height: 480px;" fill="#',
        traitNames[0][backgroundId],
        '"></rect>'
      )
    );
  }

  function compileAttributes(GearTypes.Gear memory g) public view returns (string memory) {

    string memory traits;
    traits = string(abi.encodePacked(
      attributeForTypeAndValue(_traits[0], traitNames[0][g.background]),',',
      attributeForTypeAndValue(_traits[1], traitNames[1][g.armament]),',',
      attributeForTypeAndValue(_traits[2], traitNames[2][g.class]),',',
      attributeForTypeAndValue(_traits[3], traitNames[3][g.meansOfAcquisition]),',',
      attributeForTypeAndValue(_traits[4], traitNames[4][g.faction]),',',
      attributeForTypeAndValue(_traits[5], traitNames[5][g.rarity]),',',
      attributeForNumberAndValue(_traits[6], g.powerLevel)
    ));
    return string(abi.encodePacked(
      '[',
      traits,
      ']'
    ));
  }

  function attributeForTypeAndValue(string memory traitType, string memory value) internal pure returns (string memory) {

    return string(abi.encodePacked(
      '{"trait_type":"',
      traitType,
      '","value":"',
      value,
      '"}'
    ));
  }

  function attributeForNumberAndValue(string memory traitType, uint8 value) internal pure returns (string memory) {

    return string(abi.encodePacked(
      '{"display_type":"number","trait_type":"',
      traitType,
      '","value": ',
      value.toString(),
      '}'
    ));
  }
}