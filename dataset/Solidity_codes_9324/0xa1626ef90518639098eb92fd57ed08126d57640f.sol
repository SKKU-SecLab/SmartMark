

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
}

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

interface IFOOD{

    function burn(address account, uint256 amount) external;

    function mint(address account, uint256 amount) external;

    function claimed(address account) external;

}

interface IERC165 {

    function supportsInterface(bytes4 interfaceId) external view returns (bool);

}

interface IERC721Receiver {

    function onERC721Received(
        address operator,
        address from,
        uint256 tokenId,
        bytes calldata data
    ) external returns (bytes4);

}

interface IKONGS {

    struct KaijuKong {
        bool isKaiju;
        uint8 background;
        uint8 species;

        uint8 companion;
        uint8 trophy;
        uint8 sky;
        uint8 fur;
        uint8 hat;
        uint8 face;
        uint8 weapons;
        uint8 accessories;        
        uint8 kingScore;
    }


  function getPaidTokens() external view returns (uint256);

  function getTokenTraits(uint256 tokenId) external view returns (KaijuKong memory);

  function ownerOf(uint256 tokenId) external view returns (address owner);

  function safeTransferFrom(address from,address to,uint256 tokenId,bytes calldata data) external;

  function transferFrom(address from,address to,uint256 tokenId) external;

  function KingScore(uint256 tokenId) external view returns (uint8);

  function isKaiju(uint256 tokenId) external view returns (bool);

  function LATE_PHASE() external view returns(uint256);

  function minted() external view returns (uint16);

}

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
}

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
}

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
}

abstract contract ERC165 is IERC165 {
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IERC165).interfaceId;
    }
}

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

}


interface IERC721Enumerable is IERC721 {

    function totalSupply() external view returns (uint256);


    function tokenOfOwnerByIndex(address owner, uint256 index) external view returns (uint256 tokenId);


    function tokenByIndex(uint256 index) external view returns (uint256);

}

interface IERC721Metadata is IERC721 {

    function name() external view returns (string memory);


    function symbol() external view returns (string memory);


    function tokenURI(uint256 tokenId) external view returns (string memory);

}



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

}

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
}

contract KongIsland is Ownable, IERC721Receiver, Pausable {
  
  uint8 public constant MAX_King = 8;

  struct Stake {
    uint16 tokenId;
    uint80 value;
    address owner;
  }

  struct StakedTokens {
    uint256[] ID;
  }

  event TokenStaked(address owner, uint256 tokenId, uint256 value);
  event KaijuClaimed(uint256 tokenId, uint256 earned, bool unstaked);
  event KongClaimed(uint256 tokenId, uint256 earned, bool unstaked);


  IKONGS kongs;
  IFOOD food;

  mapping(address => StakedTokens) StakedByAddress;   
  mapping(uint256 => Stake) public kongIsland; 
  mapping(uint256 => Stake[]) public pack; 
  mapping(uint256 => uint256) public packIndices; 
  uint256 totalKingStaked; //
  uint256 totalKongsStaked; //
  uint256 unaccountedRewards = 0;// 
  uint256 FOODPerKing = 0; //
  uint256 lastStakeTimestamp;

  mapping(address => uint256) private _lastUnstakeBlock;
  mapping(address => uint256) private _owed;


  uint256 public constant DAILY_FOOD_RATE = 5000 gwei;//5000 ether;
  uint256 public MINIMUM_TO_EXIT = 2 days; //2 days;
  uint256 public constant FOOD_CLAIM_TAX_PERCENTAGE = 20;
  uint256 public constant MAXIMUM_GLOBAL_FOOD = 2400000000 gwei; // 2.4 Billion  2400000000 ether;

  uint256 public totalFOODEarned;
  uint256 totalKaijuStaked;
  uint256 totalKaijuStakedGen0_1;
  uint256 totalKaijuStakedGen2;
  uint256 totalKaijuStakedGen3;
  uint256 totalKaijuStakedGen4;
  uint256 public lastClaimTimestamp;

  bool public rescueEnabled = false;


  constructor(address _KONGS, address _FOOD) { 
    kongs = IKONGS(_KONGS);
    food = IFOOD(_FOOD);
  }

  function addManyToKongIslandAndPack(address account, uint16[] calldata tokenIds) external {
    require(account == tx.origin && _msgSender() == tx.origin|| _msgSender() == address(kongs), "Not token owner");
    if(_msgSender() != address(kongs)){require(_lastUnstakeBlock[tx.origin] != block.number, "NoReEntrancy");}
    lastStakeTimestamp = block.timestamp;
    _lastUnstakeBlock[tx.origin] = block.number;
    for (uint i = 0; i < tokenIds.length; i++) {
        if (_msgSender() != address(kongs)){
        require(kongs.ownerOf(tokenIds[i]) == _msgSender() && kongs.ownerOf(tokenIds[i]) == tx.origin, "Not token owner");
        kongs.transferFrom(_msgSender(), address(this), tokenIds[i]);
        } else if (tokenIds[i] == 0) {
        continue; 
        }
        StakedByAddress[tx.origin].ID.push(tokenIds[i]);

        if (isKaiju(tokenIds[i]))
        _addKaijuToKongIsland(account, tokenIds[i]);
        else 
        _addKongToPack(account, tokenIds[i]);
    }
  }

  function multiplier(uint256 tokenId) internal pure returns(uint256){
      if(tokenId >20000){
      if(tokenId <= 30000){return 8;} 
      else if(tokenId <= 40000){return 6;} 
      else {return 4;}
      } return 10;
  }

  function _addKaijuToKongIsland(address account, uint256 tokenId) internal whenNotPaused _updateEarnings {
    kongIsland[tokenId] = Stake({
      owner: account,
      tokenId: uint16(tokenId),
      value: uint80(block.timestamp)
    });
    totalKaijuStaked += 1;
    if(tokenId <=20000){totalKaijuStakedGen0_1 += 1;}
    else if(tokenId <=30000){totalKaijuStakedGen2 += 1;}
    else if (tokenId <=40000){totalKaijuStakedGen3 += 1;}
    else {totalKaijuStakedGen4 += 1;}
    emit TokenStaked(account, tokenId, block.timestamp);
  }

  function _addKongToPack(address account, uint256 tokenId) internal {
    uint256 King = _KingForKong(tokenId);
    totalKingStaked += King;
    totalKongsStaked += 1;
    packIndices[tokenId] = pack[King].length;
    pack[King].push(Stake({
      owner: account,
      tokenId: uint16(tokenId),
      value: uint80(FOODPerKing)
    }));
    kongIsland[tokenId] = Stake({
      owner: account,
      tokenId: uint16(tokenId),
      value: uint80(FOODPerKing)
    });
    emit TokenStaked(account, tokenId, FOODPerKing);
  }


  function claimFromKongIslandAndPack(uint16[] calldata tokenIds, bool _unstake) external whenNotPaused _updateEarnings {
    require(_lastUnstakeBlock[_msgSender()] + 1 < block.number, "No ReEntrancy");
    _lastUnstakeBlock[_msgSender()] = block.number;
    for (uint i = 0; i < tokenIds.length; i++) {
      if (isKaiju(tokenIds[i]))
       _owed[_msgSender()] += _claimKaijuFromKongIsland(tokenIds[i],_unstake);
      else
        _owed[_msgSender()] += _claimKongFromPack(tokenIds[i],_unstake);
    }
    uint256 owed = _owed[_msgSender()];
    _owed[_msgSender()] = 0;
    if (owed == 0) {food.claimed(_msgSender()); return;}
    food.mint(_msgSender(), owed);
  }

  function _claimKaijuFromKongIsland(uint256 tokenId, bool unstake) internal returns (uint256 owed) {
    bool nearlyWar = kongs.minted() >= kongs.LATE_PHASE();
    Stake memory stake = kongIsland[tokenId];
    require(stake.owner == _msgSender() && stake.owner == tx.origin, "Not token owner");
    require(!(block.timestamp - stake.value < MINIMUM_TO_EXIT), "Still farming for food");
    if (totalFOODEarned < MAXIMUM_GLOBAL_FOOD) {
      owed = ((((block.timestamp - stake.value) * DAILY_FOOD_RATE / 1 days) * multiplier(tokenId))/10) ;
    } else if (stake.value > lastClaimTimestamp) {
      owed = 0; // $FOOD production stopped already
    } else {
      owed = (lastClaimTimestamp - stake.value) * DAILY_FOOD_RATE / 1 days; // stop earning additional $FOOD if it's all been earned
    }
    if (unstake) {
    uint256 stealChance = (random(tokenId) % 10);
      if (!nearlyWar && stealChance >= 5|| nearlyWar && stealChance >= 4 ) {
        _payKongTax(owed);
        owed = 0;
      }
      delete kongIsland[tokenId];
      totalKaijuStaked -= 1;
      removeTokenID(tokenId);
      kongs.safeTransferFrom(address(this), _msgSender(), tokenId, ""); // send back Kaiju
    } else {
    _payKongTax(owed * FOOD_CLAIM_TAX_PERCENTAGE / 100);
    owed = owed * (100 - FOOD_CLAIM_TAX_PERCENTAGE) / 100;
    kongIsland[tokenId] = Stake({
        owner: _msgSender(),
        tokenId: uint16(tokenId),
        value: uint80(block.timestamp)
      });}
    emit KaijuClaimed(tokenId, owed, unstake);
    return owed;
  }


  function _claimKongFromPack(uint256 tokenId, bool unstake) internal returns (uint256 owed) {
    require(kongs.ownerOf(tokenId) == address(this), "Not token owner");
    uint256 King = _KingForKong(tokenId);
    Stake memory stake = pack[King][packIndices[tokenId]];
    require(stake.owner == _msgSender(), "Not token owner");
    owed = (King) * (FOODPerKing - stake.value); // Calculate portion of tokens based on King
    if (unstake) {
      totalKingStaked -= King; // Remove King from total staked
      totalKongsStaked -= 1; 
      Stake memory lastStake = pack[King][pack[King].length - 1];
      pack[King][packIndices[tokenId]] = lastStake; // Shuffle last Kong to current position
      packIndices[lastStake.tokenId] = packIndices[tokenId];
      pack[King].pop(); // Remove duplicate
      delete packIndices[tokenId]; // Delete old mapping
      delete kongIsland[tokenId];
      removeTokenID(tokenId);
      kongs.safeTransferFrom(address(this), _msgSender(), tokenId, ""); // Send back Kong
    }
    else {
        pack[King][packIndices[tokenId]] = Stake({
        owner: _msgSender(),
        tokenId: uint16(tokenId),
        value: uint80(FOODPerKing)
      });
      kongIsland[tokenId].value = uint80(FOODPerKing); // reset stake
    emit KongClaimed(tokenId, owed, unstake);}
    return owed;
  }
	
  function rescue(uint256[] calldata tokenIds) external {
    require(rescueEnabled, "RESCUE DISABLED");
    require(_lastUnstakeBlock[tx.origin] != block.number, "No ReEntry");
    _lastUnstakeBlock[tx.origin] = block.number;
    uint256 tokenId;
    Stake memory stake;
    Stake memory lastStake;
    uint256 King;
    for (uint i = 0; i < tokenIds.length; i++) {
      tokenId = tokenIds[i];
      delete kongIsland[tokenId];
      if (isKaiju(tokenId)) {
        stake = kongIsland[tokenId];
        require(stake.owner == _msgSender(), "Not token owner");
        totalKaijuStaked -= 1;
        removeTokenID(tokenId);
        kongs.safeTransferFrom(address(this), _msgSender(), tokenId, ""); // send back Kaiju
        emit KaijuClaimed(tokenId, 0, true);
      } else {
        King = _KingForKong(tokenId);
        stake = pack[King][packIndices[tokenId]];
        require(stake.owner == _msgSender(), "Not token owner");
        totalKingStaked -= King; // Remove King from total staked
        lastStake = pack[King][pack[King].length - 1];
        pack[King][packIndices[tokenId]] = lastStake; // Shuffle last Kong to current position
        packIndices[lastStake.tokenId] = packIndices[tokenId];
        pack[King].pop(); // Remove duplicate
        delete packIndices[tokenId]; // Delete old mapping
        removeTokenID(tokenId);
        kongs.safeTransferFrom(address(this), _msgSender(), tokenId, ""); // Send back Kong
        emit KongClaimed(tokenId, 0, true);
      }
    }
  }

    function removeTokenID(uint256 tokenID) internal {
       for (uint256 i = 0; i < StakedByAddress[msg.sender].ID.length; i++) {
            if (StakedByAddress[msg.sender].ID[i] == tokenID) {
                StakedByAddress[msg.sender].ID[i] = StakedByAddress[msg.sender].ID[StakedByAddress[msg.sender].ID.length -1];
                StakedByAddress[msg.sender].ID.pop();
                break;
            }
        }
    }

  function _payKongTax(uint256 amount) internal {
    if (totalKingStaked == 0) {
      unaccountedRewards += amount;
      return;
    }
    FOODPerKing += (amount + unaccountedRewards) / totalKingStaked;
    unaccountedRewards = 0;
  }

  modifier _updateEarnings() {
    if (totalFOODEarned < MAXIMUM_GLOBAL_FOOD) {
      totalFOODEarned += 
        ((block.timestamp - lastClaimTimestamp)
        * totalKaijuStakedGen0_1
        * DAILY_FOOD_RATE / 1 days) + 
        ((block.timestamp - lastClaimTimestamp)
        * totalKaijuStakedGen2
        * (((DAILY_FOOD_RATE / 1 days)*8)/10))
        + ((block.timestamp - lastClaimTimestamp)
        * totalKaijuStakedGen3
        * (((DAILY_FOOD_RATE / 1 days)*6)/10))
        + ((block.timestamp - lastClaimTimestamp)
        * totalKaijuStakedGen4
        * (((DAILY_FOOD_RATE / 1 days)*4)/10));

      lastClaimTimestamp = block.timestamp;
    }
    _;
  }

  function setRescueEnabled(bool _enabled) external onlyOwner {
    rescueEnabled = _enabled;
  }


  function UpdateContracts(address _KONGS, address _FOOD) external onlyOwner{ 
    kongs = IKONGS(_KONGS);
    food = IFOOD(_FOOD);
  }

  function setPaused(bool _paused) external onlyOwner {
    if (_paused) _pause();
    else _unpause();
  }

  function setMinDaysToStake(uint256 _days) external onlyOwner {
    MINIMUM_TO_EXIT = _days * (1 days);
  }

  function isKaiju(uint256 tokenId) internal view returns (bool Kaiju) {
        return kongs.isKaiju(tokenId);
  }

  function stakedIDsbyAddress(address _staker) public view returns (uint256[] memory) {
        return StakedByAddress[_staker].ID;
  }

  function _KingForKong(uint256 tokenId) internal view returns (uint8) {
    return MAX_King - kongs.KingScore(tokenId); // King index is 0-3
  }

  function gainsUnclaimed(uint256 tokenId) external view returns(uint256 owed){
      require(kongIsland[tokenId].value >0, "Token not Staked");
        Stake memory stake = kongIsland[tokenId];
        if(isKaiju(tokenId)){
        if (totalFOODEarned < MAXIMUM_GLOBAL_FOOD) {
        owed = ((((block.timestamp - stake.value) * DAILY_FOOD_RATE / 1 days)* multiplier(tokenId))/10) ;}
        else if (stake.value > lastClaimTimestamp) {
        owed = 0;} else {owed = (lastClaimTimestamp - stake.value) * DAILY_FOOD_RATE / 1 days;}
        }else{
        owed = (_KingForKong(tokenId)) * (FOODPerKing - stake.value);
        }
        return owed;
  }

  function kongsStaked() external view returns(uint256){
    require(lastStakeTimestamp + 1 < block.timestamp);
    return totalKongsStaked;
    }

  function kaijusStaked() external view returns(uint256){
    require(lastStakeTimestamp + 1 < block.timestamp);
    return totalKaijuStaked;
    }
  function kingsStaked() external view returns(uint256){
    require(lastStakeTimestamp + 1 < block.timestamp);
    return totalKingStaked;
    }    

  function foodperKing() external view returns(uint256){
    require(lastStakeTimestamp + 1 < block.timestamp);
    return FOODPerKing;
    }

  function randomKongOwner(uint256 seed) external view returns (address) {
    if (totalKingStaked == 0) return address(0x0);
    uint256 bucket = (seed & 0xFFFFFFFF) % totalKingStaked;
    uint256 cumulative;
    seed >>= 32;
    for (uint i = MAX_King - 3; i <= MAX_King; i++) {
      cumulative += pack[i].length * i;
      if (bucket >= cumulative) continue;
      return pack[i][seed % pack[i].length].owner;
    }
    return address(0x0);
  }

  function random(uint256 seed) internal view returns (uint256) {
    return uint256(keccak256(abi.encodePacked(
      tx.origin,
      blockhash(block.number - 1),
      block.timestamp,
      seed
    )));
  }

  function onERC721Received(
        address,
        address from,
        uint256,
        bytes calldata
    ) external pure override returns (bytes4) {
      require(from == address(0x0), "Cannot send tokens to KongIsland directly");
      return IERC721Receiver.onERC721Received.selector;
    }

  
}