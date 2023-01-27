interface IEthTerrestrials {

   function LINK_address() external view returns (address);


   function VRF_coordinator_address() external view returns (address);


   function VRF_randomness() external view returns (uint256);


   function _UFOhasArrived() external view returns (bool);


   function _contractsealed() external view returns (bool);


   function _mothershipHasArrived() external view returns (bool);


   function abduct(uint256 quantity) external;


   function address_genesis_descriptor() external view returns (address);


   function address_opensea_token() external view returns (address);


   function address_v2_descriptor() external view returns (address);


   function approve(address to, uint256 tokenId) external;


   function authorizedMinter() external view returns (address);


   function balanceOf(address owner) external view returns (uint256);


   function blockhashData(uint256) external view returns (bytes8);


   function changeLinkFee(
      uint256 _fee,
      address _VRF_coordinator_address,
      bytes32 _keyhash
   ) external;


   function checkType(uint256 tokenId) external pure returns (uint8);


   function distributeOneOfOnes() external;


   function emergencyWithdraw(uint256 tokenId) external;


   function genesisSupply() external view returns (uint256);


   function genesisTokenOSSStoNewTokenId(uint256) external view returns (uint256);


   function getApproved(uint256 tokenId) external view returns (address);


   function getRandomNumber() external returns (bytes32 requestId);


   function getTokenSeed(uint256 tokenId) external view returns (uint8[10] memory);


   function isApprovedForAll(address owner, address operator) external view returns (bool);


   function maxMintsPerTransaction() external view returns (uint256);


   function maxTokens() external view returns (uint256);


   function mintAdmin(address to, uint256 quantity) external;


   function mintToContract() external;


   function name() external view returns (string memory);


   function onERC1155Received(
      address operator,
      address from,
      uint256 tokenId,
      uint256 value,
      bytes memory data
   ) external returns (bytes4);


   function owner() external view returns (address);


   function ownerOf(uint256 tokenId) external view returns (address);


   function payee(uint256 index) external view returns (address);


   function rawFulfillRandomness(bytes32 requestId, uint256 randomness) external;


   function rawSeedForTokenId(uint256 tokenId) external view returns (uint256);


   function release(address account) external;


   function release(address token, address account) external;


   function released(address token, address account) external view returns (uint256);


   function released(address account) external view returns (uint256);


   function renounceOwnership() external;


   function safeTransferFrom(
      address from,
      address to,
      uint256 tokenId
   ) external;


   function safeTransferFrom(
      address from,
      address to,
      uint256 tokenId,
      bytes memory _data
   ) external;


   function seal() external;


   function setAddresses(
      address _genesis_descriptor,
      address _v2_descriptor,
      address _os_address,
      address _authorizedMinter
   ) external;


   function setApprovalForAll(address operator, bool approved) external;


   function setGenesisTokenIds(uint256[] memory _OSSS_id, uint256[] memory _newTokenId) external;


   function setReverseRecord(string memory _name, address registrar_address) external;


   function setv2Price(uint256 _price) external;


   function shares(address account) external view returns (uint256);


   function supportsInterface(bytes4 interfaceId) external view returns (bool);


   function symbol() external view returns (string memory);


   function togglePublicMint() external;


   function toggleUpgrade() external;


   function tokenIdToBlockhashIndex(uint256 tokenId) external view returns (uint16);


   function tokenMap(uint256) external view returns (uint16 startingTokenId, uint16 blockhashIndex);


   function tokenSVG(uint256 tokenId, bool background) external view returns (string memory);


   function tokenURI(uint256 tokenId) external view returns (string memory);


   function totalReleased(address token) external view returns (uint256);


   function totalReleased() external view returns (uint256);


   function totalShares() external view returns (uint256);


   function totalSupply() external view returns (uint256);


   function transferFrom(
      address from,
      address to,
      uint256 tokenId
   ) external;


   function transferOwnership(address newOwner) external;


   function v2oneOfOneCount() external view returns (uint256);


   function v2price() external view returns (uint256);


   function v2supplyMax() external view returns (uint256);

}interface IEthTerrestrialsV2Descriptor {
   struct TraitType {
      string name;
      uint16[] rarity;
   }
   struct Trait {
      address imageStore;
      uint96 imagelen;
      string name;
   }
   struct TraitDescriptor {
      uint8 traitType;
      uint8 trait;
   }

   function contractsealed() external view returns (bool);


   function customs(uint256)
      external
      view
      returns (
         address imageStore,
         uint96 imagelen,
         string memory name
      );


   function decompress(bytes memory input, uint256 len) external pure returns (string memory);


   function enforceRequiredCombinations(uint8[10] memory seed) external view returns (uint8[10] memory);


   function generateTokenURI(
      uint256 tokenId,
      uint256 rawSeed,
      uint256 tokenType
   ) external view returns (string memory);


   function getArrangedSeed(uint8[10] memory seed) external view returns (uint8[20] memory);


   function getSvgCustomToken(uint256 tokenId) external view returns (string memory);


   function getSvgFromSeed(uint8[10] memory seed) external view returns (string memory);


   function getTraitSVG(uint8 traitType, uint8 traitCode) external view returns (string memory);


   function processRawSeed(uint256 rawSeed) external view returns (uint8[10] memory);


   function sealContract() external;


   function setCustom(uint256[] memory _tokenIds, Trait[] memory _oneOfOnes) external;


   function setHiddenTraits(uint8[] memory _traitTypes, bool _hidden) external;


   function setTraitExclusions(
      uint8 traitType,
      uint8 trait,
      TraitDescriptor[] memory exclusions
   ) external;


   function setTraitRearrangements(
      uint8 traitType,
      uint8 trait,
      TraitDescriptor[] memory rearrangements
   ) external;


   function setTraitTypes(TraitType[] memory _traitTypes) external;


   function setTraits(
      uint8 _traitType,
      Trait[] memory _traits,
      uint8[] memory _traitNumber
   ) external;


   function terraforms() external view returns (address);


   function traitExclusions(bytes32, uint256) external view returns (uint8 traitType, uint8 trait);


   function traitRearrangement(bytes32, uint256) external view returns (uint8 traitType, uint8 trait);


   function traitTypes(uint8) external view returns (string memory name);


   function traits(uint8, uint8)
      external
      view
      returns (
         address imageStore,
         uint96 imagelen,
         string memory name
      );


   function viewTraitsJSON(uint8[10] memory seed) external view returns (string memory);


   function viewTraitsJSONCustom(uint256 tokenId) external view returns (string memory);

}library Strings {
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
}// MIT

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
}// MIT
pragma solidity ^0.8.0;


library Bytecode {

  error InvalidCodeAtRange(uint256 _size, uint256 _start, uint256 _end);

  function creationCodeFor(bytes memory _code) internal pure returns (bytes memory) {


    return abi.encodePacked(
      hex"63",
      uint32(_code.length),
      hex"80_60_0E_60_00_39_60_00_F3",
      _code
    );
  }

  function codeSize(address _addr) internal view returns (uint256 size) {

    assembly { size := extcodesize(_addr) }
  }

  function codeAt(address _addr, uint256 _start, uint256 _end) internal view returns (bytes memory oCode) {

    uint256 csize = codeSize(_addr);
    if (csize == 0) return bytes("");

    if (_start > csize) return bytes("");
    if (_end < _start) revert InvalidCodeAtRange(csize, _start, _end); 

    unchecked {
      uint256 reqSize = _end - _start;
      uint256 maxSize = csize - _start;

      uint256 size = maxSize < reqSize ? maxSize : reqSize;

      assembly {
        oCode := mload(0x40)
        mstore(0x40, add(oCode, and(add(add(size, 0x20), 0x1f), not(0x1f))))
        mstore(oCode, size)
        extcodecopy(_addr, add(oCode, 0x20), _start, size)
      }
    }
  }
}// MIT
pragma solidity ^0.8.0;


library SSTORE2 {

  error WriteError();

  function write(bytes memory _data) internal returns (address pointer) {

    bytes memory code = Bytecode.creationCodeFor(
      abi.encodePacked(
        hex'00',
        _data
      )
    );

    assembly { pointer := create(0, add(code, 32), mload(code)) }

    if (pointer == address(0)) revert WriteError();
  }

  function read(address _pointer) internal view returns (bytes memory) {

    return Bytecode.codeAt(_pointer, 1, type(uint256).max);
  }

  function read(address _pointer, uint256 _start) internal view returns (bytes memory) {

    return Bytecode.codeAt(_pointer, _start + 1, type(uint256).max);
  }

  function read(address _pointer, uint256 _start, uint256 _end) internal view returns (bytes memory) {

    return Bytecode.codeAt(_pointer, _start + 1, _end + 1);
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


pragma solidity ^0.8.7;

contract EthTerrestrialsInjector is Ownable {

   using Strings for uint256;

   IEthTerrestrialsV2Descriptor public v2descriptor = IEthTerrestrialsV2Descriptor(0xEdAC00935844245e40218F418cC6527C41513B25);
   IEthTerrestrials public ethTerrestrials = IEthTerrestrials(0xd65c5D035A35F41f31570887E3ddF8c3289EB920);

   struct Mask {
      address imageStore; //SSTORE2 storage location for SVG image data
      bool isSpecial;
      address imageStore2;
      uint8 removeTraitTypeIfSpecial;
   }

   mapping(uint256 => Mask) masks; 
   mapping(uint256 => uint256) tokenIdMaskSelected; // tokenId => maskNumber
   mapping(uint256 => mapping (uint256 => bool)) specialMaskAllowList; // masknumber ==> tokenId ==> bool

   function setMaskPerToken(uint256 tokenId, uint256 maskChoice) external {

      require(msg.sender == ethTerrestrials.ownerOf(tokenId), "You do not hold this EthT");
      require(tokenId >= 112 && tokenId <= 4269, "Not available for genesis or 1/1 EthTs");
      require(
         maskChoice == 0 || masks[maskChoice].imageStore != address(0),
         "Unavailable option"
      ); //Prevents users from choosing a mask that does not exist

      if (masks[maskChoice].isSpecial) require(specialMaskAllowList[maskChoice][tokenId],"You do not meet the criteria to use this trait");

      tokenIdMaskSelected[tokenId] = maskChoice;
   }

   function getSvgCustomToken(uint256 tokenId) public view returns (string memory) {

      return v2descriptor.getSvgCustomToken(tokenId);
   }

   function getSvgFromSeed(uint8[10] memory seed) public view returns (string memory) {

      return v2descriptor.getSvgFromSeed(seed);
   }

   function processRawSeed(uint256 rawseed) external view returns (uint8[10] memory) {

      return v2descriptor.processRawSeed(rawseed);
   }

   function generateTokenURI(
      uint256 tokenId,
      uint256 rawSeed,
      uint256 tokenType
   ) public view returns (string memory) {

      uint256 maskNumber = tokenIdMaskSelected[tokenId];
      if (maskNumber == 0) return v2descriptor.generateTokenURI(tokenId, rawSeed, tokenType);
      else return inject(tokenId, rawSeed, tokenType, maskNumber);
   }

   function inject(
      uint256 tokenId,
      uint256 rawSeed,
      uint256 tokenType,
      uint256 maskNumber
   ) public view returns (string memory) {

      string memory name = string(abi.encodePacked("EtherTerrestrial #", tokenId.toString()));
      string
         memory description = "EtherTerrestrials are inter-dimensional Extra-Terrestrials who came to Earth's internet to infuse consciousness into all other pixelated Lifeforms. They can be encountered in the form of on-chain characters as interpreted by the existential explorer Kye."; //need to write
      string memory traits_json;

      uint8[10] memory seed = v2descriptor.processRawSeed(rawSeed);
      traits_json = v2descriptor.viewTraitsJSON(seed);
      seed[0] = 100;
      seed[9] = 100;
      if (masks[maskNumber].isSpecial) seed[masks[maskNumber].removeTraitTypeIfSpecial] = 100;

      (string memory header, string memory body) = getMaskSvg(maskNumber);
      string memory image = string(abi.encodePacked(header, v2descriptor.getSvgFromSeed(seed), body));

      string memory json = Base64.encode(
         bytes(
            string(
               abi.encodePacked(
                  '{"name": "',
                  name,
                  '", "description": "',
                  description,
                  '", "attributes":',
                  traits_json,
                  ',"image": "',
                  "data:image/svg+xml;base64,",
                  Base64.encode(bytes(image)),
                  '"}'
               )
            )
         )
      );

      string memory output = string(abi.encodePacked("data:application/json;base64,", json));
      return output;
   }

   function getMaskSvg(uint256 maskNumber) public view returns (string memory, string memory) {

      string memory header = string(SSTORE2.read(masks[maskNumber].imageStore));
      string memory body = string(SSTORE2.read(masks[maskNumber].imageStore2));
      return (header, body);
   }

   function uploadMask(
      uint256 _maskNumber,
      string memory _svgHeader,
      string memory _svgBody,
      bool _isSpecial,
      uint8 _removeTraitTypeIfSpecial
   ) external onlyOwner {

      require(_maskNumber != 0,"cannot use the zero trait");
      require(bytes(_svgHeader).length!=0 && bytes(_svgBody).length!=0, "Both header and body must be utilized");
      masks[_maskNumber] = Mask({imageStore: SSTORE2.write(bytes(_svgHeader)), imageStore2: SSTORE2.write(bytes(_svgBody)), isSpecial:_isSpecial, removeTraitTypeIfSpecial:_removeTraitTypeIfSpecial});
   }

   function setSpecialMaskAllowlist(
      uint256 _maskNumber,
      uint256[] memory _allowListTokenIds,
      bool _setting
   ) external onlyOwner {

      require(_maskNumber != 0, "cannot use the zero trait");
      require(masks[_maskNumber].isSpecial, "mask not flagged as special");
      for (uint256 i; i<_allowListTokenIds.length; i++) {
         specialMaskAllowList[_maskNumber][_allowListTokenIds[i]]=_setting;
      }
   }

}