
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
pragma solidity 0.8.10;

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
pragma solidity 0.8.10;

library Base64 {

  string internal constant TABLE =
    'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/';

  function encode(bytes memory data) internal pure returns (string memory) {

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
pragma solidity 0.8.10;

interface IDescriptor {

  function tokenURI(uint256[8] calldata) external view returns (string memory);

}// MIT

pragma solidity 0.8.10;

interface ITokenIdResolver {

  function getTokenId(uint256[8] calldata traits) external view returns (uint256);

}// MIT
pragma solidity 0.8.10;

library LibSvg {

  event StoreSvg(SvgTypeAndSizes[] typesAndSizes);
  event UpdateSvg(SvgTypeAndIdsAndSizes[] typesAndIdsAndSizes);

  struct SvgLayer {
    address svgLayersContract;
    uint16 offset;
    uint16 size;
  }

  struct SvgTypeAndSizes {
    bytes32 svgType;
    uint256[] sizes;
  }

  struct SvgTypeAndIdsAndSizes {
    bytes32 svgType;
    uint256[] ids;
    uint256[] sizes;
  }

  function _getSvg(SvgLayer[] storage svgLayers, uint256 id)
    internal
    view
    returns (bytes memory svg)
  {

    require(id < svgLayers.length, 'LibSvg: SVG type or id does not exist');

    SvgLayer storage svgLayer = svgLayers[id];
    address svgContract = svgLayer.svgLayersContract;
    uint256 size = svgLayer.size;
    uint256 offset = svgLayer.offset;
    svg = new bytes(size);
    assembly {
      extcodecopy(svgContract, add(svg, 32), offset, size)
    }
  }

  function _storeSvg(
    mapping(bytes32 => SvgLayer[]) storage svgLayers,
    string calldata svg,
    SvgTypeAndSizes[] calldata typesAndSizes
  ) internal {

    emit StoreSvg(typesAndSizes);
    address svgContract = _storeSvgInContract(svg);
    uint256 offset;
    for (uint256 i; i < typesAndSizes.length; i++) {
      SvgTypeAndSizes calldata svgTypeAndSizes = typesAndSizes[i];
      for (uint256 j; j < svgTypeAndSizes.sizes.length; j++) {
        uint256 size = svgTypeAndSizes.sizes[j];
        svgLayers[svgTypeAndSizes.svgType].push(
          SvgLayer(svgContract, uint16(offset), uint16(size))
        );
        offset += size;
      }
    }
  }

  function _updateSvg(
    mapping(bytes32 => SvgLayer[]) storage svgLayers,
    string calldata svg,
    SvgTypeAndIdsAndSizes[] calldata typesAndIdsAndSizes
  ) internal {

    emit UpdateSvg(typesAndIdsAndSizes);
    address svgContract = _storeSvgInContract(svg);
    uint256 offset;
    for (uint256 i; i < typesAndIdsAndSizes.length; i++) {
      SvgTypeAndIdsAndSizes calldata svgTypeAndIdsAndSizes = typesAndIdsAndSizes[i];
      for (uint256 j; j < svgTypeAndIdsAndSizes.sizes.length; j++) {
        uint256 size = svgTypeAndIdsAndSizes.sizes[j];
        uint256 id = svgTypeAndIdsAndSizes.ids[j];
        svgLayers[svgTypeAndIdsAndSizes.svgType][id] = SvgLayer(
          svgContract,
          uint16(offset),
          uint16(size)
        );
        offset += size;
      }
    }
  }

  function _storeSvgInContract(string calldata svg) internal returns (address svgContract) {

    require(bytes(svg).length < 24576, 'SvgStorage: Exceeded 24,576 bytes max contract size');
    bytes memory init = hex'610000600e6000396100006000f3';
    bytes1 size1 = bytes1(uint8(bytes(svg).length));
    bytes1 size2 = bytes1(uint8(bytes(svg).length >> 8));
    init[2] = size1;
    init[1] = size2;
    init[10] = size1;
    init[9] = size2;
    bytes memory code = abi.encodePacked(init, svg);

    assembly {
      svgContract := create(0, add(code, 32), mload(code))
      if eq(svgContract, 0) {
        returndatacopy(0, 0, returndatasize())
        revert(0, returndatasize())
      }
    }
  }
}// MIT


pragma solidity 0.8.10;


contract DecentralistsDescriptor is Ownable, IDescriptor {

  bytes32 private constant SVG_TYPE_BASE = 'BASE'; // 0x4241534500000000000000000000000000000000000000000000000000000000
  bytes32 private constant SVG_TYPE_NECKLACE_MALE = 'NECKLACE_MALE'; // 	0x4e45434b4c4143455f4d414c4500000000000000000000000000000000000000
  bytes32 private constant SVG_TYPE_NECKLACE_FEMALE = 'NECKLACE_FEMALE'; // 	0x4e45434b4c4143455f46454d414c450000000000000000000000000000000000
  bytes32 private constant SVG_TYPE_FACIAL_MALE = 'FACIAL_MALE'; // 	0x46414349414c5f4d414c45000000000000000000000000000000000000000000
  bytes32 private constant SVG_TYPE_FACIAL_FEMALE = 'FACIAL_FEMALE'; // 	0x46414349414c5f46454d414c4500000000000000000000000000000000000000
  bytes32 private constant SVG_TYPE_EARRING_MALE = 'EARRING_MALE'; // 	0x45415252494e475f4d414c450000000000000000000000000000000000000000
  bytes32 private constant SVG_TYPE_EARRING_FEMALE = 'EARRING_FEMALE'; // 	0x45415252494e475f46454d414c45000000000000000000000000000000000000
  bytes32 private constant SVG_TYPE_HEAD_MALE = 'HEAD_MALE'; // 	0x484541445f4d414c450000000000000000000000000000000000000000000000
  bytes32 private constant SVG_TYPE_HEAD_FEMALE = 'HEAD_FEMALE'; // 	0x484541445f46454d414c45000000000000000000000000000000000000000000
  bytes32 private constant SVG_TYPE_GLASSES_MALE = 'GLASSES_MALE'; // 	0x474c41535345535f4d414c450000000000000000000000000000000000000000
  bytes32 private constant SVG_TYPE_GLASSES_FEMALE = 'GLASSES_FEMALE'; // 	0x474c41535345535f46454d414c45000000000000000000000000000000000000
  bytes32 private constant SVG_TYPE_LIPSTICK_MALE = 'LIPSTICK_MALE'; // 	0x4c4950535449434b5f4d414c4500000000000000000000000000000000000000
  bytes32 private constant SVG_TYPE_LIPSTICK_FEMALE = 'LIPSTICK_FEMALE'; // 	0x4c4950535449434b5f46454d414c450000000000000000000000000000000000
  bytes32 private constant SVG_TYPE_SMOKING_MALE = 'SMOKING_MALE'; // 	0x534d4f4b494e475f4d414c450000000000000000000000000000000000000000
  bytes32 private constant SVG_TYPE_SMOKING_FEMALE = 'SMOKING_FEMALE'; // 	0x534d4f4b494e475f46454d414c45000000000000000000000000000000000000

  string[] private TRAIT_BASE = [
    'Human Male Black',
    'Human Female Black',
    'Human Male Dark',
    'Human Female Dark',
    'Human Male Pale',
    'Human Female Pale',
    'Human Male White',
    'Human Female White',
    'Vampire Male',
    'Vampire Female',
    'Metahuman Male',
    'Metahuman Female',
    'Ape Male'
  ];
  string[] private TRAIT_NECKLACE = ['None', 'Diamond', 'Golden', 'Silver'];
  string[] private TRAIT_FACIAL_MALE = [
    'None',
    'Chivo Black',
    'Chivo Blonde',
    'Chivo Brown',
    'Chivo Gray',
    'Chivo Red',
    'Chivo White',
    'Long Black',
    'Long Blonde',
    'Long Brown',
    'Long Gray',
    'Long Red',
    'Long White',
    'Regular Black',
    'Regular Blonde',
    'Regular Brown',
    'Regular Gray',
    'Regular Red',
    'Regular White',
    'Sideburns Black',
    'Sideburns Blonde',
    'Sideburns Brown',
    'Sideburns Gray',
    'Sideburns Red',
    'Sideburns White'
  ];
  string[] private TRAIT_FACIAL_FEMALE = ['None'];
  string[] private TRAIT_EARRING = ['None', 'Cross', 'Diamond', 'Golden', 'Silver'];
  string[] private TRAIT_HEAD_MALE = [
    'None',
    'Afro',
    'CapUp Green',
    'CapUp Red',
    'Kangaroo Black',
    'CapBack Blue',
    'CapBack Orange',
    'Conspiracist',
    'Cop',
    'CapFront Purple',
    'CapFront Red',
    'Hat Black',
    'Long Black',
    'Long Blonde',
    'Long Brown',
    'Long Gray',
    'Long Red',
    'Long White',
    'Punky Black',
    'Punky Blonde',
    'Punky Brown',
    'Punky Gray',
    'Punky Purple',
    'Punky Red',
    'Punky White',
    'Short Black',
    'Short Blonde',
    'Short Brown',
    'Short Gray',
    'Short Red',
    'Short White',
    'Trapper',
    'Wool Blue',
    'Wool Green',
    'Wool Red'
  ];
  string[] private TRAIT_HEAD_FEMALE = [
    'None',
    'Afro',
    'CapUp Green',
    'CapUp Red',
    'Kangaroo Black',
    'CapBack Blue',
    'CapBack Orange',
    'Conspiracist',
    'Cop',
    'CapFront Purple',
    'CapFront Red',
    'Hat Black',
    'Long Black',
    'Long Blonde',
    'Long Brown',
    'Long Gray',
    'Long Red',
    'Long White',
    'Punky Black',
    'Punky Blonde',
    'Punky Brown',
    'Punky Gray',
    'Punky Purple',
    'Punky Red',
    'Punky White',
    'Short Black',
    'Short Blonde',
    'Short Brown',
    'Short Gray',
    'Short Red',
    'Short White',
    'Straight Black',
    'Straight Blonde',
    'Straight Brown',
    'Straight Gray',
    'Straight Orange',
    'Straight Platinum',
    'Straight Purple',
    'Straight Red',
    'Straight White',
    'Trapper',
    'Wool Blue',
    'Wool Green',
    'Wool Red'
  ];
  string[] private TRAIT_GLASSES = ['None', 'Beetle', 'Nerd', 'Patch', 'Pilot', 'Surf', 'VR'];
  string[] private TRAIT_LIPSTICK_MALE = ['None'];
  string[] private TRAIT_LIPSTICK_FEMALE = ['None', 'Green', 'Orange', 'Pink', 'Purple', 'Red'];
  string[] private TRAIT_SMOKING = ['None', 'Cigar', 'Cigarette', 'E-Cigarette'];

  mapping(bytes32 => LibSvg.SvgLayer[]) private svgLayers;

  ITokenIdResolver public tokenIdResolver;

  constructor(address tokenIdResolver_) {
    tokenIdResolver = ITokenIdResolver(tokenIdResolver_);
  }

  function getSizeOfSvgType(bytes32 svgType) external view returns (uint256) {

    return svgLayers[svgType].length;
  }

  function getSvg(bytes32 svgType, uint256 id) public view returns (bytes memory) {

    return LibSvg._getSvg(svgLayers[svgType], id);
  }

  function storeSvg(string calldata svgs, LibSvg.SvgTypeAndSizes[] calldata typesAndSizes)
    external
    onlyOwner
  {

    LibSvg._storeSvg(svgLayers, svgs, typesAndSizes);
  }

  function updateSvg(
    string calldata svgs,
    LibSvg.SvgTypeAndIdsAndSizes[] calldata typesAndIdsAndSizes
  ) external onlyOwner {

    LibSvg._updateSvg(svgLayers, svgs, typesAndIdsAndSizes);
  }

  function tokenURI(uint256[8] calldata traits) external view override returns (string memory) {

    uint256 tokenId = tokenIdResolver.getTokenId(traits);
    string memory traitsString = _buildAttributes(
      _traitsToAttributesString(traits),
      _getBreedAndSexString(traits[0])
    );
    string memory svg = _buildSvg(traits);
    return _buildTokenURI(tokenId, traitsString, svg);
  }

  function _buildSvg(uint256[8] calldata traits) internal view returns (string memory) {

    bytes memory linesRendered;

    if (traits[0] % 2 == 0) {
      linesRendered = abi.encodePacked(
        getSvg(SVG_TYPE_BASE, traits[0]),
        getSvg(SVG_TYPE_NECKLACE_MALE, traits[1]),
        getSvg(SVG_TYPE_FACIAL_MALE, traits[2]),
        getSvg(SVG_TYPE_HEAD_MALE, traits[4]),
        getSvg(SVG_TYPE_EARRING_MALE, traits[3]),
        getSvg(SVG_TYPE_GLASSES_MALE, traits[5]),
        getSvg(SVG_TYPE_LIPSTICK_MALE, traits[6]),
        getSvg(SVG_TYPE_SMOKING_MALE, traits[7])
      );
    } else {
      linesRendered = abi.encodePacked(
        getSvg(SVG_TYPE_BASE, traits[0]),
        getSvg(SVG_TYPE_NECKLACE_FEMALE, traits[1]),
        getSvg(SVG_TYPE_FACIAL_FEMALE, traits[2]),
        getSvg(SVG_TYPE_HEAD_FEMALE, traits[4]),
        getSvg(SVG_TYPE_EARRING_FEMALE, traits[3]),
        getSvg(SVG_TYPE_GLASSES_FEMALE, traits[5]),
        getSvg(SVG_TYPE_LIPSTICK_FEMALE, traits[6]),
        getSvg(SVG_TYPE_SMOKING_FEMALE, traits[7])
      );
    }

    return
      Base64.encode(
        abi.encodePacked(
          '<svg xmlns="http://www.w3.org/2000/svg" width="350" height="350" viewBox="0 -0.5 24 24" shape-rendering="crispEdges">',
          string(linesRendered),
          '</svg>'
        )
      );
  }

  function _buildAttributes(string[] memory attributes, string memory breedAndSex)
    internal
    pure
    returns (string memory)
  {

    string memory firstPart = string(
      abi.encodePacked(
        '"attributes":[{"trait_type":"Tier","value":"',
        attributes[0],
        '"},{"trait_type":"Sex","value":"',
        attributes[1],
        '"},{"trait_type":"Base","value":"',
        attributes[2],
        '"},{"trait_type":"Necklace","value":"',
        attributes[3],
        breedAndSex,
        '"},{"trait_type":"Facial","value":"',
        attributes[4],
        breedAndSex,
        '"},{"trait_type":"Earring","value":"',
        attributes[5]
      )
    );
    string memory secondPart = string(
      abi.encodePacked(
        breedAndSex,
        '"},{"trait_type":"Head","value":"',
        attributes[6],
        breedAndSex,
        '"},{"trait_type":"Glasses","value":"',
        attributes[7],
        breedAndSex,
        '"},{"trait_type":"Lipstick","value":"',
        attributes[8],
        breedAndSex,
        '"},{"trait_type":"Smoking","value":"',
        attributes[9],
        breedAndSex,
        '"}]'
      )
    );

    return string(abi.encodePacked(firstPart, secondPart));
  }

  function _buildTokenURI(
    uint256 tokenId,
    string memory traits,
    string memory imageSVG
  ) internal pure returns (string memory) {

    return
      string(
        abi.encodePacked(
          'data:application/json;base64,',
          Base64.encode(
            bytes(
              abi.encodePacked(
                '{"name":"Decentralist #',
                Strings.toString(tokenId),
                '","description":"Decentralists is the collection for those who believe in the revolutionary power of crypto technology. Each one represents a customizable and unique combination stored 100% in the Ethereum blockchain.",',
                traits,
                ',"background_color":"12223B","image":"',
                'data:image/svg+xml;base64,',
                imageSVG,
                '"}'
              )
            )
          )
        )
      );
  }

  function _traitsToAttributesString(uint256[8] calldata traits)
    internal
    view
    returns (string[] memory)
  {

    string[] memory traitsToString = new string[](10);
    traitsToString[0] = traits[0] < 8 ? 'Standard' : 'Premium';
    traitsToString[1] = traits[0] % 2 == 0 ? 'Male' : 'Female';
    if (traits[0] % 2 == 0) {
      traitsToString[2] = TRAIT_BASE[traits[0]];
      traitsToString[3] = TRAIT_NECKLACE[traits[1]];
      traitsToString[4] = TRAIT_FACIAL_MALE[traits[2]];
      traitsToString[5] = TRAIT_EARRING[traits[3]];
      traitsToString[6] = TRAIT_HEAD_MALE[traits[4]];
      traitsToString[7] = TRAIT_GLASSES[traits[5]];
      traitsToString[8] = TRAIT_LIPSTICK_MALE[traits[6]];
      traitsToString[9] = TRAIT_SMOKING[traits[7]];
    } else {
      traitsToString[2] = TRAIT_BASE[traits[0]];
      traitsToString[3] = TRAIT_NECKLACE[traits[1]];
      traitsToString[4] = TRAIT_FACIAL_FEMALE[traits[2]];
      traitsToString[5] = TRAIT_EARRING[traits[3]];
      traitsToString[6] = TRAIT_HEAD_FEMALE[traits[4]];
      traitsToString[7] = TRAIT_GLASSES[traits[5]];
      traitsToString[8] = TRAIT_LIPSTICK_FEMALE[traits[6]];
      traitsToString[9] = TRAIT_SMOKING[traits[7]];
    }
    return traitsToString;
  }

  function _getBreedAndSexString(uint256 base) internal pure returns (string memory) {

    string memory breed;
    if (base / 2 < 4) {
      breed = ' (Human ';
    } else if (base / 2 == 4) {
      breed = ' (Vampire ';
    } else if (base / 2 == 5) {
      breed = ' (Metahuman ';
    } else {
      breed = ' (Ape ';
    }
    return string(abi.encodePacked(breed, base % 2 == 0 ? 'Male)' : 'Female)'));
  }
}