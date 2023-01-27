
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
}// MIT LICENSE 

pragma solidity ^0.8.0;

interface ITraits {

  function tokenURI(uint256 tokenId) external view returns (string memory);

}// MIT

pragma solidity ^0.8.0;

interface IERC165 {

    function supportsInterface(bytes4 interfaceId) external view returns (bool);

}// MIT

pragma solidity ^0.8.0;


interface IERC721 is IERC165 {

    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);

    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);

    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);

    function balanceOf(address owner) external view returns (uint256 balance);


    function ownerOf(uint256 tokenId) external view returns (address owner);


    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;


    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;


    function approve(address to, uint256 tokenId) external;


    function getApproved(uint256 tokenId) external view returns (address operator);


    function setApprovalForAll(address operator, bool _approved) external;


    function isApprovedForAll(address owner, address operator) external view returns (bool);


    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes calldata data
    ) external;

}// MIT

pragma solidity ^0.8.0;


interface IERC721Enumerable is IERC721 {

    function totalSupply() external view returns (uint256);


    function tokenOfOwnerByIndex(address owner, uint256 index) external view returns (uint256 tokenId);


    function tokenByIndex(uint256 index) external view returns (uint256);

}// MIT LICENSE

pragma solidity ^0.8.0;


interface IDefpunk is IERC721Enumerable {


  struct Defpunk {
    bool isMale;
    uint8 background;
    uint8 skin;
    uint8 nose;
    uint8 eyes;
    uint8 neck;
    uint8 mouth;
    uint8 ears;
    uint8 hair;
    uint8 mouthAccessory;
    uint8 fusionIndex;
    uint8[3] aged;
  }

    function minted() external returns (uint16);

    function updateOriginAccess(uint16[] memory tokenIds) external;

    function setBaseURI(string memory _baseURI) external;

    function mint(address recipient, uint256 seed) external;

    function burn(uint256 tokenId) external;

    function fuseTokens(uint256 fuseTokenId, uint256 burnTokenId, uint256 seed) external;

    function setPaused(bool _paused) external;

    function getBaseURI() external view returns (string memory);

    function getMaxTokens() external view returns (uint256);

    function getTokenTraits(uint256 tokenId) external view returns (Defpunk memory);

    function getTokenWriteBlock(uint256 tokenId) external view returns(uint64);

    function isMale(uint256 tokenId) external view returns(bool);

}// MIT
pragma solidity ^0.8.0;


contract Traits is Ownable, ITraits {


  using Strings for uint256;

  struct Trait {
    string name;
  }

  string[9] _traitTypes = [
    "Background", // 0
    "Skin", // 1
    "Nose", // 2
    "Eyes", // 3
    "Neck", // 4
    "Mouth", // 5
    "Ears", // 6
    "Hair", // 7
    "Mouth Accessory" // 8
  ];
  mapping(uint8 => mapping(uint8 => Trait)) public traitData;
  
  IDefpunk public defpunkNFT;

  constructor() {}


  function setDefpunk(address _defpunk) external onlyOwner {

    defpunkNFT = IDefpunk(_defpunk);
  }

  function uploadTraits(uint8 traitType, uint8[] calldata traitIds, Trait[] calldata traits) external onlyOwner {

    require(traitIds.length == traits.length, "Mismatched inputs");
    for (uint i = 0; i < traits.length; i++) {
      traitData[traitType][traitIds[i]] = Trait(
        traits[i].name
      );
    }
  }

  function attributeForTypeAndValue(string memory traitType, string memory value, bool aged) internal pure returns (string memory) {

    if (aged) {
      return string(abi.encodePacked(
        '{"trait_type":"',
        traitType,
        '","value":"',
        value, ' (Aged)',
        '"}'
      ));
    } else {
      return string(abi.encodePacked(
        '{"trait_type":"',
        traitType,
        '","value":"',
        value,
        '"}'
      ));
    }

  }

  function getBaseURI() external view returns (string memory) {

    return defpunkNFT.getBaseURI();
  }

  function compileAttributes(uint256 tokenId) public view returns (string memory) {

    IDefpunk.Defpunk memory d = defpunkNFT.getTokenTraits(tokenId);
    string memory traits;
    if (d.isMale) {
      traits = string(abi.encodePacked(
        attributeForTypeAndValue(_traitTypes[0], traitData[1][d.background].name, false),',',
        attributeForTypeAndValue(_traitTypes[1], traitData[2][d.skin].name, d.aged[0] == 2),',',
        attributeForTypeAndValue(_traitTypes[2], traitData[3][d.nose].name, false),',',
        attributeForTypeAndValue(_traitTypes[3], traitData[4][d.eyes].name, false),',',
        attributeForTypeAndValue(_traitTypes[4], traitData[5][d.neck].name, false),',',
        attributeForTypeAndValue(_traitTypes[5], traitData[6][d.mouth].name, d.aged[1] == 6), ',',
        attributeForTypeAndValue(_traitTypes[6], traitData[7][d.ears].name, false),',',
        attributeForTypeAndValue(_traitTypes[7], traitData[8][d.hair].name, d.aged[2] == 8), ',',
        attributeForTypeAndValue(_traitTypes[8], traitData[9][d.mouthAccessory].name, false),',',
        attributeForTypeAndValue("Fusion Index", uint2str(d.fusionIndex), false),','
      ));
    } else {
      traits = string(abi.encodePacked(
        attributeForTypeAndValue(_traitTypes[0], traitData[10][d.background].name, false),',',
        attributeForTypeAndValue(_traitTypes[1], traitData[11][d.skin].name, d.aged[0] == 11),',',
        attributeForTypeAndValue(_traitTypes[2], traitData[12][d.nose].name, false),',',
        attributeForTypeAndValue(_traitTypes[3], traitData[13][d.eyes].name, false),',',
        attributeForTypeAndValue(_traitTypes[4], traitData[14][d.neck].name, false),',',
        attributeForTypeAndValue(_traitTypes[5], traitData[15][d.mouth].name, false),',',
        attributeForTypeAndValue(_traitTypes[6], traitData[16][d.ears].name, false),',',
        attributeForTypeAndValue(_traitTypes[7], traitData[17][d.hair].name, d.aged[2] == 17),',',
        attributeForTypeAndValue(_traitTypes[8], traitData[18][d.mouthAccessory].name, false),',',
        attributeForTypeAndValue("Fusion Index", uint2str(d.fusionIndex), false),','
      ));
    }

    return string(abi.encodePacked(
      '[',
      traits,
      '{"trait_type":"Gender","value":',
      d.isMale ? '"Male"' : '"Female"',
      '}]'
    ));
  }

  function traitHasAged(uint8[3] memory aged, uint8 traitIndex) internal pure returns (bool) {

    for (uint i = 0; i < aged.length; i++) {
      if (aged[i] == traitIndex) return true;
    }
    return false;
  }

  function tokenURI(uint256 tokenId) public view override returns (string memory) {

    string memory metadata = string(abi.encodePacked(
      '{"name": "',
      'Defpunk #',
      tokenId.toString(),
      '", "description": "This is the Defpunk description. All the metadata and are generated and stored 100% on-chain.", "image": "',
      defpunkNFT.getBaseURI(),
      tokenId.toString(),
      '", "attributes":',
      compileAttributes(tokenId),
      "}"
    ));

    return string(abi.encodePacked(
      "data:application/json;base64,",
      base64(bytes(metadata))
    ));
  }

  
  string internal constant TABLE = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/';

  function base64(bytes memory data) internal pure returns (string memory) {

    if (data.length == 0) return '';
    
    string memory table = TABLE;

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
          
          mstore(resultPtr, shl(248, mload(add(tablePtr, and(shr(18, input), 0x3F)))))
          resultPtr := add(resultPtr, 1)
          mstore(resultPtr, shl(248, mload(add(tablePtr, and(shr(12, input), 0x3F)))))
          resultPtr := add(resultPtr, 1)
          mstore(resultPtr, shl(248, mload(add(tablePtr, and(shr( 6, input), 0x3F)))))
          resultPtr := add(resultPtr, 1)
          mstore(resultPtr, shl(248, mload(add(tablePtr, and(        input,  0x3F)))))
          resultPtr := add(resultPtr, 1)
      }
      
      switch mod(mload(data), 3)
      case 1 { mstore(sub(resultPtr, 2), shl(240, 0x3d3d)) }
      case 2 { mstore(sub(resultPtr, 1), shl(248, 0x3d)) }
    }
    
    return result;
  }

  function uint2str(uint _i) internal pure returns (string memory _uintAsString) {

        if (_i == 0) {
            return "0";
        }
        uint j = _i;
        uint len;
        while (j != 0) {
            len++;
            j /= 10;
        }
        bytes memory bstr = new bytes(len);
        uint k = len;
        while (_i != 0) {
            k = k-1;
            uint8 temp = (48 + uint8(_i - _i / 10 * 10));
            bytes1 b1 = bytes1(temp);
            bstr[k] = b1;
            _i /= 10;
        }
        return string(bstr);
    }
}