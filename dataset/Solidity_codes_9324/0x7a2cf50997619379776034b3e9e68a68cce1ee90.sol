pragma solidity 0.8.11;

struct Freak {
  uint8 species;
  uint8 body;
  uint8 armor;
  uint8 mainHand;
  uint8 offHand;
  uint8 power;
  uint8 health;
  uint8 criticalStrikeMod;

}
struct Celestial {
  uint8 healthMod;
  uint8 powMod;
  uint8 cPP;
  uint8 cLevel;
}

struct Layer {
  string name;
  string data;
}

struct LayerInput {
  string name;
  string data;
  uint8 layerIndex;
  uint8 itemIndex;
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
pragma solidity 0.8.11;



contract InventoryFreaks is Ownable {

  using Strings for uint8;



  mapping(uint256 => mapping(uint256 => Layer)[4]) internal _layers;

  function addLayers(LayerInput[] memory inputs, uint256 species) external onlyOwner {

    for (uint256 i = 0; i < inputs.length; i++) {
      _layers[species][inputs[i].layerIndex][inputs[i].itemIndex] = Layer(inputs[i].name, inputs[i].data);
    }
  }

  function getLayer(uint8 layerIndex, uint8 itemIndex, uint256 species) external view returns (Layer memory) {

    return _layers[species][layerIndex][itemIndex];
  }


  function getAttributes(Freak memory character, uint256 id) external view returns (bytes memory) {

    return
      abi.encodePacked(
        '{"trait_type": "Type", "value": "Freak"},',
        '{"trait_type": "Generation", "value":"',
        id <= 10000 ? "Gen 0" : id <= 20000 ? "Gen 1" : "Gen 2",
        '"},'
        '{"trait_type": "Species", "value": "',
        character.species == 1 ? "Troll" : character.species == 2 ? "Fairy" : "Ogre",
        '"},'
        '{"trait_type": "Body", "value": "',
        _layers[character.species][0][character.body].name,
        '"},',
        '{"trait_type": "Armor", "value": "',
        _layers[character.species][1][character.armor].name,
        '"},',
        '{"trait_type": "Main Hand", "value": "',
        _layers[character.species][2][character.mainHand].name,
        '"},',
        '{"trait_type": "Off Hand", "value": "',
        _layers[character.species][3][character.offHand].name,
        '"},',
        '{"trait_type": "Power", "value": "',
        character.power.toString(),
        '"},',
        '{"trait_type": "Health", "value": "',
        character.health.toString(),
        '"},',
        '{"trait_type": "Critical Strike Mod", "value": "',
        character.criticalStrikeMod.toString(),
        '"}'
      );
  }

  function getImage(Freak memory character) external view returns (bytes memory) {

    if(character.offHand == 0){
      return
        abi.encodePacked(
          _buildImage(_layers[character.species][0][character.body].data),
          _buildImage(_layers[character.species][1][character.armor].data),
          _buildImage(_layers[character.species][2][character.mainHand].data)
        );
    }else{
      return
        abi.encodePacked(
          _buildImage(_layers[character.species][0][character.body].data),
          _buildImage(_layers[character.species][1][character.armor].data),
          _buildImage(_layers[character.species][2][character.mainHand].data),
          _buildImage(_layers[character.species][3][character.offHand].data)
        );
    }
  }

  function _buildImage(string memory image) internal pure returns (bytes memory) {

    return
      abi.encodePacked(
        '<image x="0" y="0" width="64" height="64" image-rendering="pixelated" preserveAspectRatio="xMidYMid" xlink:href="data:image/png;base64,',
        image,
        '"/>'
      );
  }
}