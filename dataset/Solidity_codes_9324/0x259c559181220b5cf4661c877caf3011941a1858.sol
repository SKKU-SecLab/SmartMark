
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
}// AGPL-3.0-only
pragma solidity ^0.8.0;

interface IERC721Receiver {

  function onERC721Received(
    address operator,
    address from,
    uint256 tokenId,
    bytes calldata data
  ) external returns (bytes4);

}

contract ERC721 {


  event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);

  event Approval(address indexed owner, address indexed spender, uint256 indexed tokenId);

  event ApprovalForAll(address indexed owner, address indexed operator, bool approved);


  address implementation_;
  address admin;

  string public name;
  string public symbol;


  mapping(address => uint256) public balanceOf;

  mapping(uint256 => address) public ownerOf;

  mapping(uint256 => address) public getApproved;

  mapping(address => mapping(address => bool)) public isApprovedForAll;


  modifier onlyOwner() {

    require(msg.sender == admin);
    _;
  }

  function owner() external view returns (address) {

    return admin;
  }


  function transfer(address to, uint256 tokenId) external {

    require(msg.sender == ownerOf[tokenId], "NOT_OWNER");

    _transfer(msg.sender, to, tokenId);
  }


  function supportsInterface(bytes4 interfaceId) external pure returns (bool supported) {

    supported = true;
  }

  function approve(address spender, uint256 tokenId) external {

    address owner_ = ownerOf[tokenId];

    require(msg.sender == owner_ || isApprovedForAll[owner_][msg.sender], "NOT_APPROVED");

    getApproved[tokenId] = spender;

    emit Approval(owner_, spender, tokenId);
  }

  function setApprovalForAll(address operator, bool approved) external {

    isApprovedForAll[msg.sender][operator] = approved;

    emit ApprovalForAll(msg.sender, operator, approved);
  }

  function transferFrom(
    address from,
    address to,
    uint256 tokenId
  ) public virtual {

    require(
      msg.sender == from || msg.sender == getApproved[tokenId] || isApprovedForAll[from][msg.sender],
      "NOT_APPROVED"
    );

    _transfer(from, to, tokenId);
  }

  function safeTransferFrom(
    address from,
    address to,
    uint256 tokenId
  ) external {

    safeTransferFrom(from, to, tokenId, "");
  }

  function safeTransferFrom(
    address from,
    address to,
    uint256 tokenId,
    bytes memory data
  ) public {

    transferFrom(from, to, tokenId);

    if (to.code.length != 0) {
      try IERC721Receiver(to).onERC721Received(msg.sender, from, tokenId, data) returns (bytes4 retval) {
        require(retval == IERC721Receiver.onERC721Received.selector);
      } catch (bytes memory reason) {
        if (reason.length == 0) {
          revert("ERC721: transfer to non ERC721Receiver implementer");
        } else {
          assembly {
            revert(add(32, reason), mload(reason))
          }
        }
      }
    }
  }


  function _transfer(
    address from,
    address to,
    uint256 tokenId
  ) internal {

    require(ownerOf[tokenId] == from);
    _beforeTokenTransfer(from, to, tokenId);

    balanceOf[from]--;
    balanceOf[to]++;

    delete getApproved[tokenId];

    ownerOf[tokenId] = to;
    emit Transfer(from, to, tokenId);

    _afterTokenTransfer(from, to, tokenId);
  }

  function _mint(address to, uint256 tokenId) internal {

    require(ownerOf[tokenId] == address(0), "ALREADY_MINTED");
    _beforeTokenTransfer(address(0), to, tokenId);

    unchecked {
      balanceOf[to]++;
    }

    ownerOf[tokenId] = to;

    emit Transfer(address(0), to, tokenId);

    _afterTokenTransfer(address(0), to, tokenId);
  }

  function _burn(uint256 tokenId) internal {

    address owner_ = ownerOf[tokenId];

    require(owner_ != address(0), "NOT_MINTED");
    _beforeTokenTransfer(owner_, address(0), tokenId);

    balanceOf[owner_]--;

    delete ownerOf[tokenId];

    emit Transfer(owner_, address(0), tokenId);

    _afterTokenTransfer(owner_, address(0), tokenId);
  }

  function _beforeTokenTransfer(
    address from,
    address to,
    uint256 tokenId
  ) internal virtual {}


  function _afterTokenTransfer(
    address from,
    address to,
    uint256 tokenId
  ) internal virtual {}

}// MIT

pragma solidity ^0.8.0;


abstract contract ERC721Enumerable is ERC721 {
  mapping(address => mapping(uint256 => uint256)) private _ownedTokens;

  mapping(uint256 => uint256) private _ownedTokensIndex;

  uint256 public totalSupply;

  function tokenOfOwnerByIndex(address owner, uint256 index) public view virtual returns (uint256) {
    require(index < balanceOf[owner], "ERC721Enumerable: owner index out of bounds");
    return _ownedTokens[owner][index];
  }

  function _beforeTokenTransfer(
    address from,
    address to,
    uint256 tokenId
  ) internal virtual override {
    super._beforeTokenTransfer(from, to, tokenId);

    if (from == address(0)) {
      totalSupply++;
    } else if (from != to) {
      _removeTokenFromOwnerEnumeration(from, tokenId);
    }
    if (to == address(0)) {
      totalSupply--;
    } else if (to != from) {
      _addTokenToOwnerEnumeration(to, tokenId);
    }
  }

  function _addTokenToOwnerEnumeration(address to, uint256 tokenId) private {
    uint256 length = balanceOf[to];
    _ownedTokens[to][length] = tokenId;
    _ownedTokensIndex[tokenId] = length;
  }

  function _removeTokenFromOwnerEnumeration(address from, uint256 tokenId) private {

    uint256 lastTokenIndex = balanceOf[from] - 1;
    uint256 tokenIndex = _ownedTokensIndex[tokenId];

    if (tokenIndex != lastTokenIndex) {
      uint256 lastTokenId = _ownedTokens[from][lastTokenIndex];

      _ownedTokens[from][tokenIndex] = lastTokenId; // Move the last token to the slot of the to-delete token
      _ownedTokensIndex[lastTokenId] = tokenIndex; // Update the moved token's index
    }

    delete _ownedTokensIndex[tokenId];
    delete _ownedTokens[from][lastTokenIndex];
  }
}// MIT
pragma solidity ^0.8.0;

library Base64 {
  string private constant base64stdchars =
    'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/';

  function encode(bytes memory data) internal pure returns (string memory) {
    if (data.length == 0) return '';

    string memory table = base64stdchars;

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
}//MIT
pragma solidity ^0.8.0;


contract AmbassadorNFT is ERC721Enumerable {
  using Base64 for *;
  using Strings for uint256;

  struct Base {
    string image; // base image
    address collection; // Drops dToken
  }

  event CollectionRegistered(address collection, string name);

  event BaseUpdated(uint256 index, Base base);

  event AmbassadorUpdated(uint256 tokenId, uint256 base, uint256 weight);

  uint128 public constant DEFAULT_WEIGHT = 3_000 * 1e18; // 3k

  string public constant DESCRIPTION =
    'The Ambassador NFT is a non-transferable token exclusively available to Drops DAO ambassadors. Each NFT provides veDOP voting power which is used in DAO governance process.';

  bool public initialized;

  mapping(address => string) public collectionNames;

  Base[] public bases;

  mapping(uint256 => uint256) public info;

  string private baseURI;

  function initialize(string memory _baseURI) external {
    require(msg.sender == admin);
    require(!initialized);
    initialized = true;

    name = 'Drops DAO Ambassadors';
    symbol = 'DROPSAMB';

    baseURI = _baseURI;
  }

  function registerCollection(address collection, string calldata name) external onlyOwner {
    collectionNames[collection] = name;

    emit CollectionRegistered(collection, name);
  }

  function addBase(string calldata image, address collection) external onlyOwner {
    require(bytes(collectionNames[collection]).length > 0, 'addBase: Invalid collection');
    Base memory base = Base(image, collection);
    emit BaseUpdated(bases.length, base);
    bases.push(base);
  }

  function updateBase(
    uint256 index,
    string calldata image,
    address collection
  ) external onlyOwner {
    require(index < bases.length, 'updateBase: Invalid index');

    Base storage base = bases[index];
    base.image = image;
    base.collection = collection;

    emit BaseUpdated(index, base);
  }

  function totalBases() external view returns (uint256) {
    return bases.length;
  }

  function mintInternal(
    uint256 tokenId,
    address to,
    uint256 base
  ) internal {
    require(to != address(0), 'mint: Invalid to');
    require(base < bases.length, 'mint: Invalid base');

    info[tokenId] = (base << 128) | DEFAULT_WEIGHT;
    _mint(to, tokenId);

    emit AmbassadorUpdated(tokenId, base, DEFAULT_WEIGHT);
  }

  function mint(
    uint256 tokenId,
    address to,
    uint256 base
  ) public onlyOwner {
    mintInternal(tokenId, to, base);
  }

  function mints(
    uint256[] calldata tokenIds,
    address[] calldata wallets,
    uint256[] calldata baseIndexes
  ) external onlyOwner {
    for (uint256 i = 0; i < tokenIds.length; i++) {
      mintInternal(tokenIds[i], wallets[i], baseIndexes[i]);
    }
  }

  function updateAmbWeight(uint256 tokenId, uint256 weight) external onlyOwner {
    require(ownerOf[tokenId] != address(0), 'updateWeight: Non-existent token');

    uint256 base = info[tokenId] >> 128;
    info[tokenId] = (base << 128) | weight;

    emit AmbassadorUpdated(tokenId, base, weight);
  }

  function updateAmbBase(uint256 tokenId, uint256 base) external onlyOwner {
    require(ownerOf[tokenId] != address(0), 'updateBase: Non-existent token');

    uint128 weight = uint128(info[tokenId]);
    info[tokenId] = (base << 128) | weight;

    emit AmbassadorUpdated(tokenId, base, weight);
  }

  function getAmbassador(uint256 tokenId)
    public
    view
    returns (
      uint256 weight,
      string memory image,
      address collection
    )
  {
    require(ownerOf[tokenId] != address(0), 'getAmbassador: Non-existent token');

    uint256 base = info[tokenId];
    weight = uint128(base);
    base = base >> 128;
    image = bases[base].image;
    collection = bases[base].collection;
  }

  function burn(uint256 tokenId) external onlyOwner {
    _burn(tokenId);
  }

  function tokenURI(uint256 tokenId) public view returns (string memory) {
    require(ownerOf[tokenId] != address(0), 'tokenURI: Non-existent token');

    (uint256 weight, string memory image, address collection) = getAmbassador(tokenId);

    string memory attributes = string(
      abi.encodePacked(
        '[{"trait_type":"Collection","value":"',
        collectionNames[collection],
        '"},{"display_type":"number","trait_type":"veDOP","value":',
        (weight / 1e18).toString(),
        '}]'
      )
    );

    return
      string(
        abi.encodePacked(
          'data:application/json;base64,',
          Base64.encode(
            abi.encodePacked(
              '{"name":"',
              string(abi.encodePacked('Ambassador', ' #', tokenId.toString())),
              '","description":"',
              DESCRIPTION,
              '","image":"',
              string(abi.encodePacked(baseURI, image)),
              '","attributes":',
              attributes,
              '}'
            )
          )
        )
      );
  }

  function _beforeTokenTransfer(
    address from,
    address to,
    uint256 tokenId
  ) internal virtual override onlyOwner {
    require(balanceOf[to] == 0, 'transfer: Already an ambassador');
    ERC721Enumerable._beforeTokenTransfer(from, to, tokenId);
  }

  function transferFrom(
    address from,
    address to,
    uint256 tokenId
  ) public virtual override {
    _transfer(from, to, tokenId);
  }
}