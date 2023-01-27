
pragma solidity ^0.8.0;

library Address {

    function isContract(address account) internal view returns (bool) {


        uint256 size;
        assembly {
            size := extcodesize(account)
        }
        return size > 0;
    }

    function sendValue(address payable recipient, uint256 amount) internal {

        require(address(this).balance >= amount, "Address: insufficient balance");

        (bool success, ) = recipient.call{value: amount}("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    function functionCall(address target, bytes memory data) internal returns (bytes memory) {

        return functionCall(target, data, "Address: low-level call failed");
    }

    function functionCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {

        return functionCallWithValue(target, data, 0, errorMessage);
    }

    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value
    ) internal returns (bytes memory) {

        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value,
        string memory errorMessage
    ) internal returns (bytes memory) {

        require(address(this).balance >= value, "Address: insufficient balance for call");
        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{value: value}(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {

        return functionStaticCall(target, data, "Address: low-level static call failed");
    }

    function functionStaticCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal view returns (bytes memory) {

        require(isContract(target), "Address: static call to non-contract");

        (bool success, bytes memory returndata) = target.staticcall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {

        return functionDelegateCall(target, data, "Address: low-level delegate call failed");
    }

    function functionDelegateCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {

        require(isContract(target), "Address: delegate call to non-contract");

        (bool success, bytes memory returndata) = target.delegatecall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    function verifyCallResult(
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) internal pure returns (bytes memory) {

        if (success) {
            return returndata;
        } else {
            if (returndata.length > 0) {

                assembly {
                    let returndata_size := mload(returndata)
                    revert(add(32, returndata), returndata_size)
                }
            } else {
                revert(errorMessage);
            }
        }
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

interface IERC165 {

    function supportsInterface(bytes4 interfaceId) external view returns (bool);

}// MIT

pragma solidity ^0.8.0;


abstract contract ERC165 is IERC165 {
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IERC165).interfaceId;
    }
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

interface IERC721Receiver {

    function onERC721Received(
        address operator,
        address from,
        uint256 tokenId,
        bytes calldata data
    ) external returns (bytes4);

}// MIT

pragma solidity ^0.8.0;


interface IERC721Metadata is IERC721 {

    function name() external view returns (string memory);


    function symbol() external view returns (string memory);


    function tokenURI(uint256 tokenId) external view returns (string memory);

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


contract ERC721 is Context, ERC165, IERC721, IERC721Metadata {

    using Address for address;
    using Strings for uint256;

    string private _name;

    string private _symbol;

    mapping(uint256 => address) private _owners;

    mapping(address => uint256) private _balances;

    mapping(uint256 => address) private _tokenApprovals;

    mapping(address => mapping(address => bool)) private _operatorApprovals;

    constructor(string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
    }

    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC165, IERC165) returns (bool) {

        return
            interfaceId == type(IERC721).interfaceId ||
            interfaceId == type(IERC721Metadata).interfaceId ||
            super.supportsInterface(interfaceId);
    }

    function balanceOf(address owner) public view virtual override returns (uint256) {

        require(owner != address(0), "ERC721: balance query for the zero address");
        return _balances[owner];
    }

    function ownerOf(uint256 tokenId) public view virtual override returns (address) {

        address owner = _owners[tokenId];
        require(owner != address(0), "ERC721: owner query for nonexistent token");
        return owner;
    }

    function name() public view virtual override returns (string memory) {

        return _name;
    }

    function symbol() public view virtual override returns (string memory) {

        return _symbol;
    }

    function tokenURI(uint256 tokenId) public view virtual override returns (string memory) {

        require(_exists(tokenId), "ERC721Metadata: URI query for nonexistent token");

        string memory baseURI = _baseURI();
        return bytes(baseURI).length > 0 ? string(abi.encodePacked(baseURI, tokenId.toString())) : "";
    }

    function _baseURI() internal view virtual returns (string memory) {

        return "";
    }

    function approve(address to, uint256 tokenId) public virtual override {

        address owner = ERC721.ownerOf(tokenId);
        require(to != owner, "ERC721: approval to current owner");

        require(
            _msgSender() == owner || isApprovedForAll(owner, _msgSender()),
            "ERC721: approve caller is not owner nor approved for all"
        );

        _approve(to, tokenId);
    }

    function getApproved(uint256 tokenId) public view virtual override returns (address) {

        require(_exists(tokenId), "ERC721: approved query for nonexistent token");

        return _tokenApprovals[tokenId];
    }

    function setApprovalForAll(address operator, bool approved) public virtual override {

        require(operator != _msgSender(), "ERC721: approve to caller");

        _operatorApprovals[_msgSender()][operator] = approved;
        emit ApprovalForAll(_msgSender(), operator, approved);
    }

    function isApprovedForAll(address owner, address operator) public view virtual override returns (bool) {

        return _operatorApprovals[owner][operator];
    }

    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) public virtual override {

        require(_isApprovedOrOwner(_msgSender(), tokenId), "ERC721: transfer caller is not owner nor approved");

        _transfer(from, to, tokenId);
    }

    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId
    ) public virtual override {

        safeTransferFrom(from, to, tokenId, "");
    }

    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes memory _data
    ) public virtual override {

        require(_isApprovedOrOwner(_msgSender(), tokenId), "ERC721: transfer caller is not owner nor approved");
        _safeTransfer(from, to, tokenId, _data);
    }

    function _safeTransfer(
        address from,
        address to,
        uint256 tokenId,
        bytes memory _data
    ) internal virtual {

        _transfer(from, to, tokenId);
        require(_checkOnERC721Received(from, to, tokenId, _data), "ERC721: transfer to non ERC721Receiver implementer");
    }

    function _exists(uint256 tokenId) internal view virtual returns (bool) {

        return _owners[tokenId] != address(0);
    }

    function _isApprovedOrOwner(address spender, uint256 tokenId) internal view virtual returns (bool) {

        require(_exists(tokenId), "ERC721: operator query for nonexistent token");
        address owner = ERC721.ownerOf(tokenId);
        return (spender == owner || getApproved(tokenId) == spender || isApprovedForAll(owner, spender));
    }

    function _safeMint(address to, uint256 tokenId) internal virtual {

        _safeMint(to, tokenId, "");
    }

    function _safeMint(
        address to,
        uint256 tokenId,
        bytes memory _data
    ) internal virtual {

        _mint(to, tokenId);
        require(
            _checkOnERC721Received(address(0), to, tokenId, _data),
            "ERC721: transfer to non ERC721Receiver implementer"
        );
    }

    function _mint(address to, uint256 tokenId) internal virtual {

        require(to != address(0), "ERC721: mint to the zero address");
        require(!_exists(tokenId), "ERC721: token already minted");

        _beforeTokenTransfer(address(0), to, tokenId);

        _balances[to] += 1;
        _owners[tokenId] = to;

        emit Transfer(address(0), to, tokenId);
    }

    function _burn(uint256 tokenId) internal virtual {

        address owner = ERC721.ownerOf(tokenId);

        _beforeTokenTransfer(owner, address(0), tokenId);

        _approve(address(0), tokenId);

        _balances[owner] -= 1;
        delete _owners[tokenId];

        emit Transfer(owner, address(0), tokenId);
    }

    function _transfer(
        address from,
        address to,
        uint256 tokenId
    ) internal virtual {

        require(ERC721.ownerOf(tokenId) == from, "ERC721: transfer of token that is not own");
        require(to != address(0), "ERC721: transfer to the zero address");

        _beforeTokenTransfer(from, to, tokenId);

        _approve(address(0), tokenId);

        _balances[from] -= 1;
        _balances[to] += 1;
        _owners[tokenId] = to;

        emit Transfer(from, to, tokenId);
    }

    function _approve(address to, uint256 tokenId) internal virtual {

        _tokenApprovals[tokenId] = to;
        emit Approval(ERC721.ownerOf(tokenId), to, tokenId);
    }

    function _checkOnERC721Received(
        address from,
        address to,
        uint256 tokenId,
        bytes memory _data
    ) private returns (bool) {

        if (to.isContract()) {
            try IERC721Receiver(to).onERC721Received(_msgSender(), from, tokenId, _data) returns (bytes4 retval) {
                return retval == IERC721Receiver.onERC721Received.selector;
            } catch (bytes memory reason) {
                if (reason.length == 0) {
                    revert("ERC721: transfer to non ERC721Receiver implementer");
                } else {
                    assembly {
                        revert(add(32, reason), mload(reason))
                    }
                }
            }
        } else {
            return true;
        }
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 tokenId
    ) internal virtual {}

}// MIT

pragma solidity ^0.8.0;


interface IERC721Enumerable is IERC721 {
    function totalSupply() external view returns (uint256);

    function tokenOfOwnerByIndex(address owner, uint256 index) external view returns (uint256 tokenId);

    function tokenByIndex(uint256 index) external view returns (uint256);
}// MIT

pragma solidity ^0.8.0;


abstract contract ERC721Enumerable is ERC721, IERC721Enumerable {
    mapping(address => mapping(uint256 => uint256)) private _ownedTokens;

    mapping(uint256 => uint256) private _ownedTokensIndex;

    uint256[] private _allTokens;

    mapping(uint256 => uint256) private _allTokensIndex;

    function supportsInterface(bytes4 interfaceId) public view virtual override(IERC165, ERC721) returns (bool) {
        return interfaceId == type(IERC721Enumerable).interfaceId || super.supportsInterface(interfaceId);
    }

    function tokenOfOwnerByIndex(address owner, uint256 index) public view virtual override returns (uint256) {
        require(index < ERC721.balanceOf(owner), "ERC721Enumerable: owner index out of bounds");
        return _ownedTokens[owner][index];
    }

    function totalSupply() public view virtual override returns (uint256) {
        return _allTokens.length;
    }

    function tokenByIndex(uint256 index) public view virtual override returns (uint256) {
        require(index < ERC721Enumerable.totalSupply(), "ERC721Enumerable: global index out of bounds");
        return _allTokens[index];
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 tokenId
    ) internal virtual override {
        super._beforeTokenTransfer(from, to, tokenId);

        if (from == address(0)) {
            _addTokenToAllTokensEnumeration(tokenId);
        } else if (from != to) {
            _removeTokenFromOwnerEnumeration(from, tokenId);
        }
        if (to == address(0)) {
            _removeTokenFromAllTokensEnumeration(tokenId);
        } else if (to != from) {
            _addTokenToOwnerEnumeration(to, tokenId);
        }
    }

    function _addTokenToOwnerEnumeration(address to, uint256 tokenId) private {
        uint256 length = ERC721.balanceOf(to);
        _ownedTokens[to][length] = tokenId;
        _ownedTokensIndex[tokenId] = length;
    }

    function _addTokenToAllTokensEnumeration(uint256 tokenId) private {
        _allTokensIndex[tokenId] = _allTokens.length;
        _allTokens.push(tokenId);
    }

    function _removeTokenFromOwnerEnumeration(address from, uint256 tokenId) private {

        uint256 lastTokenIndex = ERC721.balanceOf(from) - 1;
        uint256 tokenIndex = _ownedTokensIndex[tokenId];

        if (tokenIndex != lastTokenIndex) {
            uint256 lastTokenId = _ownedTokens[from][lastTokenIndex];

            _ownedTokens[from][tokenIndex] = lastTokenId; // Move the last token to the slot of the to-delete token
            _ownedTokensIndex[lastTokenId] = tokenIndex; // Update the moved token's index
        }

        delete _ownedTokensIndex[tokenId];
        delete _ownedTokens[from][lastTokenIndex];
    }

    function _removeTokenFromAllTokensEnumeration(uint256 tokenId) private {

        uint256 lastTokenIndex = _allTokens.length - 1;
        uint256 tokenIndex = _allTokensIndex[tokenId];

        uint256 lastTokenId = _allTokens[lastTokenIndex];

        _allTokens[tokenIndex] = lastTokenId; // Move the last token to the slot of the to-delete token
        _allTokensIndex[lastTokenId] = tokenIndex; // Update the moved token's index

        delete _allTokensIndex[tokenId];
        _allTokens.pop();
    }
}// MIT LICENSE

pragma solidity ^0.8.0;

interface IBattleground {}// MIT LICENSE

pragma solidity ^0.8.0;

interface IGOLD {
  function mint(address to, uint256 amount) external;
  function burn(address from, uint256 amount) external;
}// MIT LICENSE

pragma solidity ^0.8.0;

interface IRandomizer {
  function getChunkId() external view returns (uint256);
  function random(uint256 data) external returns (uint256);
  function randomChunk(uint256 chunkId, uint256 data) external returns (uint256);
}// MIT LICENSE

pragma solidity ^0.8.0;

interface ITraits {
  struct TokenTraits {
    bool isVillager;
    uint8 alphaIndex;
  }

  function getTokenTraits(uint256 tokenId) external view returns (TokenTraits memory);
  function generateTokenTraits(uint256 tokenId, uint256 seed) external;
}// MIT LICENSE

pragma solidity ^0.8.0;

interface IVAndV {}// MIT LICENSE

pragma solidity ^0.8.0;

interface IVAndVMinter {}// MIT LICENSE

pragma solidity ^0.8.0;

interface IVillage {
  function randomVikingOwner(uint256 seed) external view returns (address);
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


abstract contract Pausable is Context {
    event Paused(address account);

    event Unpaused(address account);

    bool private _paused;

    constructor() {
        _paused = false;
    }

    function paused() public view virtual returns (bool) {
        return _paused;
    }

    modifier whenNotPaused() {
        require(!paused(), "Pausable: paused");
        _;
    }

    modifier whenPaused() {
        require(paused(), "Pausable: not paused");
        _;
    }

    function _pause() internal virtual whenNotPaused {
        _paused = true;
        emit Paused(_msgSender());
    }

    function _unpause() internal virtual whenPaused {
        _paused = false;
        emit Unpaused(_msgSender());
    }
}// MIT

pragma solidity ^0.8.0;

abstract contract ReentrancyGuard {

    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor() {
        _status = _NOT_ENTERED;
    }

    modifier nonReentrant() {
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        _status = _ENTERED;

        _;

        _status = _NOT_ENTERED;
    }
}// MIT LICENSE

pragma solidity ^0.8.0;


contract VAndV is IVAndV, ERC721Enumerable, Ownable {
  using Address for address;
  using Strings for uint256;

  uint256 public immutable MAX_TOKENS;
  uint256 public immutable PAID_TOKENS;

  uint16 public minted = 0;

  IVAndVMinter private vandvMinter;
  IVillage private village;
  IBattleground private battleground;

  constructor(uint256 _maxTokens) ERC721("Vikings & Villagers", "VANDV") {
    MAX_TOKENS = _maxTokens;
    PAID_TOKENS = _maxTokens / 5;
  }

  function mint(address to) external returns (uint256) {
    require(_msgSender() == address(vandvMinter), "V&V: Only minter can call this function");
    require(minted + 1 <= MAX_TOKENS, "V&V: All tokens minted");

    minted++;

    _safeMint(to, minted);

    return minted;
  }

  function tokenURI(uint256 tokenId) public view override returns (string memory) {
    require(_exists(tokenId), "ERC721Metadata: URI query for nonexistent token");

    return string(abi.encodePacked("https://vikingsandvillagers.com/metadata/", tokenId.toString()));
  }

  function transferFrom(address from, address to, uint256 tokenId) public virtual override {
    if (_msgSender() != address(vandvMinter) && _msgSender() != address(village) && _msgSender() != address(battleground)) {
      require(_isApprovedOrOwner(_msgSender(), tokenId), "ERC721: transfer caller is not owner nor approved");
    }

    _transfer(from, to, tokenId);
  }

  function getMinted() external view returns (uint16) {
    return minted;
  }

  function getMaxTokens() external view returns (uint256) {
    return MAX_TOKENS;
  }

  function getPaidTokens() external view returns (uint256) {
    return PAID_TOKENS;
  }

  function setVAndVMinter(address _vandvMinter) external onlyOwner {
    vandvMinter = IVAndVMinter(_vandvMinter);
  }

  function setVillage(address _village) external onlyOwner {
    village = IVillage(_village);
  }

  function setBattleground(address _battleground) external onlyOwner {
    battleground = IBattleground(_battleground);
  }

}// MIT LICENSE

pragma solidity ^0.8.0;


contract Village is IVillage, Ownable, IERC721Receiver, Pausable, ReentrancyGuard {
  using Address for address;

  event GoldTaxed(address from, uint256 taxed);
  event GoldStolen(address from, uint256 total);

  struct Stake {
    uint16 tokenId;
    uint80 value;
    address owner;
  }

  uint8 public constant MAX_ALPHA = 8;
  uint256 public constant DAILY_GOLD_RATE = 10000 ether;
  uint256 public constant MINIMUM_TO_EXIT = 2 days;
  uint256 public constant GOLD_CLAIM_TAX_PERCENTAGE = 20;
  uint256 public constant MAXIMUM_GLOBAL_GOLD = 4000000000 ether;

  uint256 public totalAlphaStaked = 0;
  uint256 public unaccountedRewards = 0;
  uint256 public rewardsPerAlpha = 0;
  uint256 public totalGoldEarned = 0;
  uint256 public totalVillagersStaked = 0;
  uint256 public totalVikingsStaked = 0;
  uint256 public lastClaimTimestamp = 0;

  mapping(uint256 => Stake) private village;
  mapping(uint8 => Stake[]) private parties;
  mapping(uint256 => uint256) private partyIndices;
  mapping(address => uint256[]) private ownerTokens;
  mapping(uint256 => uint256) private ownerTokensIndices;

  IRandomizer private randomizer;
  IGOLD private gold;
  ITraits private traits;
  VAndV private vandv;

  constructor() {
    _pause();
  }

  function stakeTokens(uint16[] calldata tokenIds) external nonReentrant whenNotPaused {
    require(tx.origin == _msgSender() && !_msgSender().isContract(), "VILLAGE: Only EOA");

    for (uint i = 0; i < tokenIds.length; i++) {
      require(vandv.ownerOf(tokenIds[i]) == _msgSender(), "VILLAGE: Doesn't own that token");

      vandv.transferFrom(_msgSender(), address(this), tokenIds[i]);

      ownerTokensIndices[tokenIds[i]] = ownerTokens[_msgSender()].length;
      ownerTokens[_msgSender()].push(tokenIds[i]);

      if (_isVillager(tokenIds[i])) {
        _addVillagerToVillage(_msgSender(), tokenIds[i]);
      } else {
        _addVikingToRaidParty(_msgSender(), tokenIds[i]);
      }
    }
  }

  function claimEarnings(uint16[] calldata tokenIds, bool shouldUnstake) external nonReentrant whenNotPaused _updateEarnings {
    require(tx.origin == _msgSender() && !_msgSender().isContract(), "VILLAGE: Only EOA");

    uint256 totalEarned = 0;

    for (uint i = 0; i < tokenIds.length; i++) {
      require(vandv.ownerOf(tokenIds[i]) == address(this), "VILLAGE: Token not owned by village contract");

      if (_isVillager(tokenIds[i])) {
        totalEarned += _claimVillagerRewards(tokenIds[i], shouldUnstake);
      } else {
        totalEarned += _claimVikingRewards(tokenIds[i], shouldUnstake);
      }
    }

    if (totalEarned > 0) {
      gold.mint(_msgSender(), totalEarned);
    }
  }

  function getTokensForOwner(address owner) external view returns (uint256[] memory) {
    require(owner == _msgSender(), "VILLAGE: Only the owner can check their tokens");

    return ownerTokens[owner];
  }

  function getEarningsForToken(uint256 tokenId) external view returns (uint256) {
    uint256 owed = 0;

    if (_isVillager(tokenId)) {
      Stake memory stake = village[tokenId];

      require(stake.owner == _msgSender(), "VILLAGE: Only the owner can check their earnings");

      if (totalGoldEarned < MAXIMUM_GLOBAL_GOLD) {
        owed = (block.timestamp - stake.value) * DAILY_GOLD_RATE / 1 days;
      } else if (stake.value > lastClaimTimestamp) {
        owed = 0; // $GOLD production stopped already
      } else {
        owed = (lastClaimTimestamp - stake.value) * DAILY_GOLD_RATE / 1 days; // stop earning additional $GOLD if it's all been earned
      }
    } else {
      uint8 alpha = _alphaForViking(tokenId);
      Stake memory stake = parties[alpha][partyIndices[tokenId]];

      require(stake.owner == _msgSender(), "VILLAGE: Only the owner can check their earnings");

      owed = alpha * (rewardsPerAlpha - stake.value);
    }

    return owed;
  }

  function canUnstake(uint256 tokenId) external view returns (bool) {
    if (_isVillager(tokenId)) {
      Stake memory stake = village[tokenId];

      require(stake.owner == _msgSender(), "VILLAGE: Only the owner can check their tokens");

      return block.timestamp - stake.value >= MINIMUM_TO_EXIT;
    } else {
      uint8 alpha = _alphaForViking(tokenId);
      Stake memory stake = parties[alpha][partyIndices[tokenId]];

      require(stake.owner == _msgSender(), "VILLAGE: Only the owner can check their tokens");

      return true;
    }
  }

  function randomVikingOwner(uint256 seed) external override view returns (address) {
    if (totalAlphaStaked == 0) {
      return address(0x0);
    }

    uint256 bucket = (seed & 0xFFFFFFFF) % totalAlphaStaked; // choose a value from 0 to total alpha staked
    uint256 cumulative;

    seed >>= 32;

    for (uint8 i = MAX_ALPHA - 3; i <= MAX_ALPHA; i++) {
      cumulative += parties[i].length * i;

      if (bucket >= cumulative) {
        continue;
      }

      return parties[i][seed % parties[i].length].owner;
    }

    return address(0x0);
  }

  function onERC721Received(address, address from, uint256, bytes calldata) external pure override returns (bytes4) {
    require(from == address(0x0), "VILLAGE: Cannot send tokens directly");

    return IERC721Receiver.onERC721Received.selector;
  }

  function setRandomizer(address _randomizer) external onlyOwner {
    randomizer = IRandomizer(_randomizer);
  }

  function setGold(address _gold) external onlyOwner {
    gold = IGOLD(_gold);
  }

  function setTraits(address _traits) external onlyOwner {
    traits = ITraits(_traits);
  }

  function setVAndV(address _vandv) external onlyOwner {
    vandv = VAndV(_vandv);
  }

  function setPaused(bool enabled) external onlyOwner {
    if (enabled) {
      _pause();
    } else {
      _unpause();
    }
  }

  function _addVillagerToVillage(address owner, uint256 tokenId) internal _updateEarnings {
    village[tokenId] = Stake({
      owner: owner,
      tokenId: uint16(tokenId),
      value: uint80(block.timestamp)
    });

    totalVillagersStaked += 1;
  }

  function _addVikingToRaidParty(address owner, uint256 tokenId) internal {
    uint8 alpha = _alphaForViking(tokenId);

    partyIndices[tokenId] = parties[alpha].length;

    parties[alpha].push(Stake({
      owner: owner,
      tokenId: uint16(tokenId),
      value: uint80(rewardsPerAlpha)
    }));

    totalVikingsStaked += 1;
    totalAlphaStaked += alpha; // Portion of earnings ranges from 8 to 5
  }

  function _claimVillagerRewards(uint256 tokenId, bool shouldUnstake) internal returns (uint256 owed) {
    Stake memory stake = village[tokenId];

    require(stake.owner == _msgSender(), "VILLAGE: Unable to claim because wrong owner");

    if (shouldUnstake) {
      require(block.timestamp - stake.value >= MINIMUM_TO_EXIT, "VILLAGE: Can't unstake and claim yet");
    }

    if (totalGoldEarned < MAXIMUM_GLOBAL_GOLD) {
      owed = (block.timestamp - stake.value) * DAILY_GOLD_RATE / 1 days;
    } else if (stake.value > lastClaimTimestamp) {
      owed = 0; // $GOLD production stopped already
    } else {
      owed = (lastClaimTimestamp - stake.value) * DAILY_GOLD_RATE / 1 days; // stop earning additional $GOLD if it's all been earned
    }

    if (shouldUnstake) {
      if (randomizer.random(tokenId) & 1 == 1) {
        _addTaxedRewards(owed);
        emit GoldStolen(_msgSender(), owed);
        owed = 0;
      }

      delete village[tokenId];

      uint256 lastTokenId = ownerTokens[_msgSender()][ownerTokens[_msgSender()].length - 1];
      ownerTokens[_msgSender()][ownerTokensIndices[tokenId]] = lastTokenId;
      ownerTokensIndices[lastTokenId] = ownerTokensIndices[tokenId];
      ownerTokens[_msgSender()].pop();
      delete ownerTokensIndices[tokenId];

      totalVillagersStaked -= 1;

      vandv.safeTransferFrom(address(this), _msgSender(), tokenId, "");
    } else {
      uint256 tax = owed * GOLD_CLAIM_TAX_PERCENTAGE / 100;
      _addTaxedRewards(tax);
      emit GoldTaxed(_msgSender(), tax);
      owed -= tax;

      village[tokenId] = Stake({
        owner: _msgSender(),
        tokenId: uint16(tokenId),
        value: uint80(block.timestamp)
      });
    }
  }

  function _claimVikingRewards(uint256 tokenId, bool shouldUnstake) internal returns (uint256 owed) {
    uint8 alpha = _alphaForViking(tokenId);
    Stake memory stake = parties[alpha][partyIndices[tokenId]];

    require(stake.owner == _msgSender(), "VILLAGE: Unable to claim because wrong owner");

    owed = alpha * (rewardsPerAlpha - stake.value);

    if (shouldUnstake) {
      Stake memory lastStake = parties[alpha][parties[alpha].length - 1];
      parties[alpha][partyIndices[tokenId]] = lastStake;
      partyIndices[lastStake.tokenId] = partyIndices[tokenId];
      parties[alpha].pop();
      delete partyIndices[tokenId];

      uint256 lastTokenId = ownerTokens[_msgSender()][ownerTokens[_msgSender()].length - 1];
      ownerTokens[_msgSender()][ownerTokensIndices[tokenId]] = lastTokenId;
      ownerTokensIndices[lastTokenId] = ownerTokensIndices[tokenId];
      ownerTokens[_msgSender()].pop();
      delete ownerTokensIndices[tokenId];

      totalVikingsStaked -= 1;
      totalAlphaStaked -= alpha;

      vandv.safeTransferFrom(address(this), _msgSender(), tokenId, "");
    } else {
      parties[alpha][partyIndices[tokenId]] = Stake({
        owner: _msgSender(),
        tokenId: uint16(tokenId),
        value: uint80(rewardsPerAlpha)
      });
    }
  }

  function _addTaxedRewards(uint256 amount) internal {
    if (totalAlphaStaked == 0) {
      unaccountedRewards += amount;
      return;
    }

    rewardsPerAlpha += (amount + unaccountedRewards) / totalAlphaStaked;
    unaccountedRewards = 0;
  }

  function _isVillager(uint256 tokenId) internal view returns (bool) {
    return traits.getTokenTraits(tokenId).isVillager;
  }

  function _alphaForViking(uint256 tokenId) internal view returns (uint8) {
    return MAX_ALPHA - traits.getTokenTraits(tokenId).alphaIndex;
  }

  modifier _updateEarnings() {
    if (totalGoldEarned < MAXIMUM_GLOBAL_GOLD) {
      totalGoldEarned += (block.timestamp - lastClaimTimestamp) * totalVillagersStaked * DAILY_GOLD_RATE / 1 days;
      lastClaimTimestamp = block.timestamp;
    }

    _;
  }

}