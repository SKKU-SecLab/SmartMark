
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


abstract contract ERC165 is IERC165 {
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IERC165).interfaceId;
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

pragma solidity ^0.8.10;


contract LotteryBox {

  uint constant SEED_BLOCK_HASH_AMOUNT = 3;
  
  uint constant MAX_BLOCK_HASH_DISTANCE = 256;


  function simpleRandom(uint seed) internal view returns(uint256) {
    return uint256(keccak256(abi.encodePacked(
      tx.origin,
      block.timestamp,
      seed
    )));
  }

  function randomNumber(uint requestBlockNumber, uint seed) internal view returns (uint256) {
    bytes32[SEED_BLOCK_HASH_AMOUNT] memory blockhashs;
    for (uint i = 0; i < SEED_BLOCK_HASH_AMOUNT; i++) {
      blockhashs[i] = blockhash(requestBlockNumber+1+i);
    }
    return uint256(keccak256(abi.encodePacked(
      tx.origin,
      blockhashs,
      seed
    )));
  }

  function boxState(uint requestBlockNumber) internal view returns (uint) {
    if (requestBlockNumber == 0) {
      return 0; // not requested
    }
    if (openCountdown(requestBlockNumber) > 0) {
      return 1; // waiting for reveal
    }
    if (timeoutCountdown(requestBlockNumber) > 0) {
      return 2; // waiting to reveal the result
    }

    return 3; // timeout
  }

  function openCountdown(uint requestBlockNumber) internal view returns(uint) {
    return countdown(requestBlockNumber, SEED_BLOCK_HASH_AMOUNT+1);
  }

  function timeoutCountdown(uint requestBlockNumber) internal view returns(uint) {
    return countdown(requestBlockNumber, MAX_BLOCK_HASH_DISTANCE+1);
  }

  function countdown(uint requestBlockNumber, uint v) internal view returns(uint) {
    uint diff = block.number - requestBlockNumber;
    if (diff > v) {
      return 0;
    }
    return v - diff;
  }

  function percentNumber(uint random) internal pure returns(uint) {
    if (random > 0) {
      return (random % 100) + 1;
    }
    return 0;
  }

  function openBox(uint requestBlockNumber) internal view returns (uint) {
    
    require(openCountdown(requestBlockNumber) == 0, "Invalid block number");

    
    if (timeoutCountdown(requestBlockNumber) > 0) {
      
      return randomNumber(requestBlockNumber, 0);
    } else {
     
      return 0;
    }

  }


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
}// MIT

pragma solidity ^0.8.10;


struct HunterHoundTraits {

  bool isHunter;
  uint alpha;
  uint metadataId;
}
uint constant MIN_ALPHA = 5;
uint constant MAX_ALPHA = 8;
contract HunterHound is ERC721Enumerable, Ownable {

  using Strings for uint256;

  mapping(address => bool) public controllers;

  mapping(uint256 => HunterHoundTraits) private tokenTraits;

  string baseUrl = "ipfs://QmVkCrCmvZEk3kuZDiSJXw25Urf3f93damrbRJLbDY5yT2/";

  constructor() ERC721("HunterHound","HH") {

  }

  function setBaseUrl(string calldata baseUrl_) external onlyOwner {
    baseUrl = baseUrl_;
  }

  function getTokenTraits(uint256 tokenId) external view returns (HunterHoundTraits memory) {
    return tokenTraits[tokenId];
  }

  function getTraitsByTokenIds(uint256[] calldata tokenIds) external view returns (HunterHoundTraits[] memory traits) {
    traits = new HunterHoundTraits[](tokenIds.length);
    for (uint256 i = 0; i < tokenIds.length; i++) {
      traits[i] = tokenTraits[tokenIds[i]];
    }
  }
  function tokenURI(uint256 tokenId) public view override returns (string memory) {
    HunterHoundTraits memory s = tokenTraits[tokenId];

    return string(abi.encodePacked(
      baseUrl,
      s.isHunter ? 'Hunter' : 'Hound',
      '-',
      s.alpha.toString(),
      '/',
      s.isHunter ? 'Hunter' : 'Hound',
      '-',
      s.alpha.toString(),
      '-',
      s.metadataId.toString(),
      '.json'
    ));
  }

  function tokensByOwner(address owner) external view returns (uint256[] memory tokenIds, HunterHoundTraits[] memory traits) {
    uint totalCount = balanceOf(owner);
    tokenIds = new uint256[](totalCount);
    traits = new HunterHoundTraits[](totalCount);
    for (uint256 i = 0; i < totalCount; i++) {
      tokenIds[i] = tokenOfOwnerByIndex(owner, i);
      traits[i] = tokenTraits[tokenIds[i]];
    }
  }

  function isHunterAndAlphaByTokenId(uint256 tokenId) external view returns (bool, uint) {
    HunterHoundTraits memory traits = tokenTraits[tokenId];
    return (traits.isHunter, traits.alpha);
  }

  function mintByController(address account, uint256 tokenId, HunterHoundTraits calldata traits) external {
    require(controllers[_msgSender()], "Only controllers can mint");
    tokenTraits[tokenId] = traits;
    _safeMint(account, tokenId);
  }

  function transferByController(address from, address to, uint256 tokenId) external {
    require(controllers[_msgSender()], "Only controllers can transfer");
    _transfer(from, to, tokenId);
  }

  function addController(address controller) external onlyOwner {
    controllers[controller] = true;
  }

  function removeController(address controller) external onlyOwner {
    controllers[controller] = false;
  }

}// MIT

pragma solidity ^0.8.10;



contract Mintor is LotteryBox {

  event MintEvent(address indexed operator, uint hunters, uint hounds, uint256[] tokenIds);

  struct Minting {
    uint blockNumber;
    uint amount;
  }

  uint256 constant MINT_PRICE = .067 ether;
  uint256 constant MINT_PHASE2_PRICE = 40000 ether;
  uint256 constant MINT_PHASE3_PRICE = 60000 ether;
  uint256 constant MINT_PHASE4_PRICE = 80000 ether;

  uint constant maxAlpha8Count = 500;
  uint constant maxAlpha7Count = 1500;
  uint constant maxAlpha6Count = 3000;
  uint constant maxAlpha5Count = 5000;

  uint constant MAX_TOKENS = 50000;
  uint constant PHASE1_AMOUNT = 10000;
  uint constant PHASE2_AMOUNT = 10000;
  uint constant PHASE3_AMOUNT = 20000;
  uint constant PHASE4_AMOUNT = 10000;


  uint private alpha8Count = 1;
  uint private alpha7Count = 1;
  uint private alpha6Count = 1;
  uint private alpha5Count = 1;

  uint internal totalHoundMinted = 1;

  mapping(address => Minting) internal mintRequests;

  uint256 internal minted;

  uint256 internal hunterMinted;

  uint internal requested;

  function _mintRequestState(address requestor) internal view returns (uint blockNumber, uint amount, uint state, uint open, uint timeout) {
    Minting memory req = mintRequests[requestor];
    blockNumber = req.blockNumber;
    amount = req.amount;
    state = boxState(req.blockNumber);
    open = openCountdown(req.blockNumber);
    timeout = timeoutCountdown(req.blockNumber);
  }

  function _request(address requestor, uint amount) internal {

    require(mintRequests[requestor].blockNumber == 0, 'Request already exists');
    
    mintRequests[requestor] = Minting({
      blockNumber: block.number,
      amount: amount
    });

    requested = requested + amount;
  }

  function _receive(address requestor, HunterHound hh) internal {
    Minting memory minting = mintRequests[requestor];
    require(minting.blockNumber > 0, "No mint request found");

    delete mintRequests[requestor];

    uint random = openBox(minting.blockNumber);
    uint boxResult = percentNumber(random);
    uint percent = boxResult;
    uint hunters = 0;
    uint256[] memory tokenIds = new uint256[](minting.amount);
    for (uint256 i = 0; i < minting.amount; i++) {
      HunterHoundTraits memory traits;
      if (i > 0 && boxResult > 0) {
        random = simpleRandom(percent);
        percent = percentNumber(random);
      }
      if (percent == 0) {
        traits = selectHound();
      } else if (percent >= 80) {
        traits = selectHunter(random);
      } else {
        traits = selectHound();
      }
      minted = minted + 1;
      hh.mintByController(requestor, minted, traits);
      tokenIds[i] = minted;
      if (traits.isHunter) {
        hunters ++;
      }
    }
    if (hunters > 0) {
      hunterMinted = hunterMinted + hunters;
    }
    emit MintEvent(requestor, hunters, minting.amount - hunters, tokenIds);
  }

  function selectHunter(uint random) private returns(HunterHoundTraits memory hh) {
    
    random = simpleRandom(random);
    uint percent = percentNumber(random);
    if (percent <= 5 && alpha8Count <= maxAlpha8Count) {
      hh.alpha = 8;
      hh.metadataId = alpha8Count;
      alpha8Count = alpha8Count + 1;
    } else if (percent <= 20 && alpha7Count <= maxAlpha7Count) {
      hh.alpha = 7;
      hh.metadataId = alpha7Count;
      alpha7Count = alpha7Count + 1;
    } else if (percent <= 50 && alpha6Count <= maxAlpha6Count) {
      hh.alpha = 6;
      hh.metadataId = alpha6Count;
      alpha6Count = alpha6Count + 1;
    } else if (alpha5Count <= maxAlpha5Count) {
      hh.alpha = 5;
      hh.metadataId = alpha5Count;
      alpha5Count = alpha5Count + 1;
    } else {
      return selectHound();
    }
    hh.isHunter = true;

  }

  function selectHound() private returns(HunterHoundTraits memory hh) {
    hh.isHunter = false;
    hh.metadataId = totalHoundMinted;
    totalHoundMinted = totalHoundMinted + 1;
  }

}// MIT

pragma solidity ^0.8.0;

interface IERC20 {
    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount) external returns (bool);

    function allowance(address owner, address spender) external view returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}// MIT

pragma solidity ^0.8.0;


interface IERC20Metadata is IERC20 {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);
}// MIT

pragma solidity ^0.8.0;


contract ERC20 is Context, IERC20, IERC20Metadata {
    mapping(address => uint256) private _balances;

    mapping(address => mapping(address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;

    constructor(string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
    }

    function name() public view virtual override returns (string memory) {
        return _name;
    }

    function symbol() public view virtual override returns (string memory) {
        return _symbol;
    }

    function decimals() public view virtual override returns (uint8) {
        return 18;
    }

    function totalSupply() public view virtual override returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account) public view virtual override returns (uint256) {
        return _balances[account];
    }

    function transfer(address recipient, uint256 amount) public virtual override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function allowance(address owner, address spender) public view virtual override returns (uint256) {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public virtual override returns (bool) {
        _transfer(sender, recipient, amount);

        uint256 currentAllowance = _allowances[sender][_msgSender()];
        require(currentAllowance >= amount, "ERC20: transfer amount exceeds allowance");
        unchecked {
            _approve(sender, _msgSender(), currentAllowance - amount);
        }

        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender] + addedValue);
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        uint256 currentAllowance = _allowances[_msgSender()][spender];
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
        unchecked {
            _approve(_msgSender(), spender, currentAllowance - subtractedValue);
        }

        return true;
    }

    function _transfer(
        address sender,
        address recipient,
        uint256 amount
    ) internal virtual {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(sender, recipient, amount);

        uint256 senderBalance = _balances[sender];
        require(senderBalance >= amount, "ERC20: transfer amount exceeds balance");
        unchecked {
            _balances[sender] = senderBalance - amount;
        }
        _balances[recipient] += amount;

        emit Transfer(sender, recipient, amount);

        _afterTokenTransfer(sender, recipient, amount);
    }

    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply += amount;
        _balances[account] += amount;
        emit Transfer(address(0), account, amount);

        _afterTokenTransfer(address(0), account, amount);
    }

    function _burn(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: burn from the zero address");

        _beforeTokenTransfer(account, address(0), amount);

        uint256 accountBalance = _balances[account];
        require(accountBalance >= amount, "ERC20: burn amount exceeds balance");
        unchecked {
            _balances[account] = accountBalance - amount;
        }
        _totalSupply -= amount;

        emit Transfer(account, address(0), amount);

        _afterTokenTransfer(account, address(0), amount);
    }

    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}

    function _afterTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}
}// MIT

pragma solidity ^0.8.10;


contract TokenTimelock {

    Prey private immutable _token;

    address private immutable _beneficiary;

    uint256 private immutable _releaseTime;
    
    uint256 private immutable _releaseDuration;
    
    uint256 private lastWithdrawTime;
    uint256 private immutable _totalToken;

    constructor(
        Prey token_,
        address beneficiary_,
        uint256 releaseTime_,
        uint256 releaseDuration_,
        uint256 totalToken_
    ) {
        require(releaseTime_ > block.timestamp, "TokenTimelock: release time is before current time");
        _token = token_;
        _beneficiary = beneficiary_;
        _releaseTime = releaseTime_;
        lastWithdrawTime = _releaseTime;
        _releaseDuration = releaseDuration_;
        _totalToken = totalToken_;
    }

    function token() public view virtual returns (Prey) {
        return _token;
    }

    function beneficiary() public view virtual returns (address) {
        return _beneficiary;
    }

    function releaseTime() public view virtual returns (uint256) {
        return _releaseTime;
    }

    function release() public virtual {
        require(block.timestamp >= releaseTime(), "TokenTimelock: current time is before release time");

        uint256 amount = token().balanceOf(address(this));
        uint256 releaseAmount = (block.timestamp - lastWithdrawTime) * _totalToken / _releaseDuration;
        
        require(amount >= releaseAmount, "TokenTimelock: no tokens to release");

        lastWithdrawTime = block.timestamp;
        token().transfer(beneficiary(), releaseAmount);
    }
}// MIT

pragma solidity ^0.8.10;


contract Prey is ERC20, Ownable {

  mapping(address => bool) public controllers;
  
  uint constant developerTokenAmount = 600000000 ether;

  uint constant communityTokenAmount = 2000000000 ether;

  uint constant forestTokenAmount = 2400000000 ether;
  
  uint mintedByCommunity;
  uint mintedByForest;

  constructor(address developerAccount) ERC20("Prey", "PREY") {

    TokenTimelock timelock = new TokenTimelock(this, developerAccount, block.timestamp + 732 days, 300 days, developerTokenAmount);
    _mint(address(timelock), developerTokenAmount);
    controllers[_msgSender()] = true;
  }
  function mintByCommunity(address account, uint256 amount) external {
    require(controllers[_msgSender()], "Only controllers can mint");
    require(mintedByCommunity + amount <= communityTokenAmount, "No mint out");
    mintedByCommunity = mintedByCommunity + amount;
    _mint(account, amount);
  }

  function mintsByCommunity(address[] calldata accounts, uint256 amount) external {
    require(controllers[_msgSender()], "Only controllers can mint");
    require(mintedByCommunity + (amount * accounts.length) <= communityTokenAmount, "No mint out");
    mintedByCommunity = mintedByCommunity + (amount * accounts.length);
    for (uint256 i = 0; i < accounts.length; i++) {
      _mint(accounts[i], amount);
    }
  }

  function mintByForest(address account, uint256 amount) external {
    require(controllers[_msgSender()], "Only controllers can mint");
    require(mintedByForest + amount <= forestTokenAmount, "No mint out");
    mintedByForest = mintedByForest + amount;
    _mint(account, amount);
  }

  function burn(address account, uint256 amount) external {
    require(controllers[_msgSender()], "Only controllers can mint");
    _burn(account, amount);
  }

  function addController(address controller) external onlyOwner {
    controllers[controller] = true;
  }

  function removeController(address controller) external onlyOwner {
    controllers[controller] = false;
  }

}// MIT

pragma solidity ^0.8.10;


contract Forest is LotteryBox {

  event StakeEvent(address indexed operator, uint256[][] pairs);
  event ClaimEvent(address indexed operator, uint256 receiveProfit, uint256 totalProfit);
  event UnstakeEvent(address indexed operator, address indexed recipient, uint256 indexed tokenId, uint256 receiveProfit, uint256 totalProfit);

  struct Stake{
    uint timestamp;
    bool hunter;
    uint hounds;
    uint alpha;
    uint256[] tokenIds;
  }
  uint constant GAMBLE_CLAIM = 1;
  uint constant GAMBLE_UNSTAKE = 2;
  uint constant GAMBLE_UNSTAKE_GREDDY = 3;
  struct Gamble {
    uint action;
    uint blockNumber;
  }

  uint constant MINIMUN_UNSTAKE_AMOUNT = 20000 ether; 
  uint constant PROFIT_PER_SINGLE_HOUND = 10000 ether;

  uint constant TOTAL_PROFIT = 2400000000 ether;

  uint internal totalClaimed; 
  uint internal totalBurned;

  mapping(address => Stake[]) internal stakes;

  mapping(uint => address) internal tokenOwners;

  mapping(uint256 => uint256[]) internal hunterAlphaMap;

  mapping(uint256 => uint256) internal hunterTokenIndices;

  uint internal houndStaked;
  uint internal hunterStaked;
  uint internal houndsCaptured;

  mapping(address => Gamble) internal gambleRequests;


  modifier whenGambleRequested() {
      require(gambleRequests[msg.sender].blockNumber == 0, "Unstake or claim first");
      _;
  }

  function _stake(address owner, uint256[][] calldata pairs, HunterHound hh) internal whenGambleRequested {

    require(pairs.length > 0, "Tokens empty");
    require(totalClaimed < TOTAL_PROFIT, "No profit");

    uint totalHunter = 0;
    uint totalHounds = 0;
    
    (totalHunter, totalHounds) = _storeStake(owner, pairs, hh);

    hunterStaked = hunterStaked + totalHunter;
    houndStaked = houndStaked + totalHounds;

    for (uint256 i = 0; i < pairs.length; i++) {
      for (uint256 j = 0; j < pairs[i].length; j++) {
        uint256 tokenId = pairs[i][j];
        hh.transferByController(owner, address(this), tokenId);
      }
    }
    emit StakeEvent(owner, pairs);
  }

  function _storeStake(address owner, uint256[][] calldata paris, HunterHound hh) private returns(uint totalHunter, uint totalHounds) {
    for (uint256 i = 0; i < paris.length; i++) {
      uint256[] calldata tokenIds = paris[i];
      uint hunters;
      uint hounds;
      uint256 hunterAlpha;
      uint hunterIndex = 0;
      (hunters, hounds, hunterAlpha, hunterIndex) = _storeTokenOwner(owner, tokenIds, hh);
      require(hounds > 0 && hounds <= 3, "Must have 1-3 hound in a pair");
      require(hunters <= 1, "Only be one hunter in a pair");
      
      require(hunters == 0 || hunterIndex == (tokenIds.length-1), "Hunter must be last one");
      totalHunter = totalHunter + hunters;
      totalHounds = totalHounds + hounds;
      stakes[owner].push(Stake({
        timestamp: block.timestamp,
        hunter: hunters > 0,
        hounds: hounds,
        alpha: hunterAlpha,
        tokenIds: tokenIds
      }));

      if (hunters > 0) {
        uint256 hunterTokenId = tokenIds[tokenIds.length-1];
        hunterTokenIndices[hunterTokenId] = hunterAlphaMap[hunterAlpha].length;
        hunterAlphaMap[hunterAlpha].push(hunterTokenId);
      }
    }
  }

  function _storeTokenOwner(address owner, uint[] calldata tokenIds, HunterHound hh) private 
    returns(uint hunters,uint hounds,uint hunterAlpha,uint hunterIndex) {
    for (uint256 j = 0; j < tokenIds.length; j++) {
        uint256 tokenId = tokenIds[j];
        require(tokenOwners[tokenId] == address(0), "Unstake first");
        require(hh.ownerOf(tokenId) == owner, "Not your token");
        bool isHunter;
        uint alpha;
        (isHunter, alpha) = hh.isHunterAndAlphaByTokenId(tokenId);

        if (isHunter) {
          hunters = hunters + 1;
          hunterAlpha = alpha;
          hunterIndex = j;
        } else {
          hounds = hounds + 1;
        }
        tokenOwners[tokenId] = owner;
      }
  }
  
  function _claim(address owner, Prey prey) internal {

    uint requestBlockNumber = gambleRequests[owner].blockNumber;
    uint totalProfit = _claimProfit(owner, false);
    uint receiveProfit;
    if (requestBlockNumber > 0) {
      require(gambleRequests[owner].action == GAMBLE_CLAIM, "Unstake first");
      uint random = openBox(requestBlockNumber);
      uint percent = percentNumber(random);
      if (percent <= 50) {
        receiveProfit = 0;
      } else {
        receiveProfit = totalProfit;
      }
      delete gambleRequests[owner];
    } else {
      receiveProfit = (totalProfit * 80) / 100;
    }

    if (receiveProfit > 0) {
      prey.mintByForest(owner, receiveProfit);
    }
    if (totalProfit - receiveProfit > 0) {
      totalBurned = totalBurned + (totalProfit - receiveProfit);
    }
    emit ClaimEvent(owner, receiveProfit, totalProfit);
  }

  function _collectStakeProfit(address owner, bool unstake) private returns (uint profit) {
    for (uint i = 0; i < stakes[owner].length; i++) {
      Stake storage stake = stakes[owner][i];
      
      profit = profit + _caculateProfit(stake);
      if (!unstake) {
        stake.timestamp = block.timestamp;
      }
    }
    
    require(unstake == false || profit >= MINIMUN_UNSTAKE_AMOUNT, "Minimum claim is 20000 PREY");
  }
  
  function _claimProfit(address owner, bool unstake) private returns (uint) {
    uint profit = _collectStakeProfit(owner, unstake);
    
    if (totalClaimed + profit > TOTAL_PROFIT) {
      profit = TOTAL_PROFIT - totalClaimed;
    }
    totalClaimed = totalClaimed + profit;
    
    return profit;
  }

  function _requestGamble(address owner, uint action) internal whenGambleRequested {

    require(stakes[owner].length > 0, 'Stake first');
    require(action == GAMBLE_CLAIM || action == GAMBLE_UNSTAKE || action == GAMBLE_UNSTAKE_GREDDY, 'Invalid action');
    if (action != GAMBLE_CLAIM) {
      _collectStakeProfit(owner, true);
    }
    gambleRequests[owner] = Gamble({
      action: action,
      blockNumber: block.number
    });
  }

  function _gambleRequestState(address requestor) internal view returns (uint blockNumber, uint action, uint state, uint open, uint timeout) {
    Gamble memory req = gambleRequests[requestor];
    blockNumber = req.blockNumber;
    action = req.action;
    state = boxState(req.blockNumber);
    open = openCountdown(req.blockNumber);
    timeout = timeoutCountdown(req.blockNumber);
  }

  
  function _unstake(address owner, Prey prey, HunterHound hh) internal {
    uint requestBlockNumber = gambleRequests[owner].blockNumber;
    require(requestBlockNumber > 0, "No unstake request found");
    uint action = gambleRequests[owner].action;
    require(action == GAMBLE_UNSTAKE || action == GAMBLE_UNSTAKE_GREDDY, "Claim first");

    uint256 totalProfit = _claimProfit(owner, true);

    uint random = openBox(requestBlockNumber);
    uint percent = percentNumber(random);

    address houndRecipient;
    if (percent <= 20) {
      houndRecipient= selectLuckyRecipient(owner, percent);
      if (houndRecipient != address(0)) {
        houndsCaptured = houndsCaptured + 1;
      }
    }

    uint receiveProfit = totalProfit;
    if (action == GAMBLE_UNSTAKE_GREDDY) {
      if (percent > 0) {
        random = randomNumber(requestBlockNumber, random);
        percent = percentNumber(random);
        if (percent <= 50) {
          receiveProfit = 0;
        }
      } else {
          receiveProfit = 0;
      }
    } else {
      receiveProfit = (receiveProfit * 80) / 100;
    }


    delete gambleRequests[owner];

    uint totalHunter = 0;
    uint totalHound = 0;
    uint256 capturedTokenId;
    (totalHunter, totalHound, capturedTokenId) = _cleanOwner(percent, owner, hh, houndRecipient);
    
    hunterStaked = hunterStaked - totalHunter;
    houndStaked = houndStaked - totalHound;
    delete stakes[owner];

    if (receiveProfit > 0) {
      prey.mintByForest(owner, receiveProfit);
    }

    if (totalProfit - receiveProfit > 0) {
      totalBurned = totalBurned + (totalProfit - receiveProfit);
    }
    emit UnstakeEvent(owner, houndRecipient, capturedTokenId, receiveProfit, totalProfit);
  }

  function _cleanOwner(uint percent, address owner, HunterHound hh, address houndRecipient) private returns(uint totalHunter, uint totalHound, uint256 capturedTokenId) {
    uint randomRow = percent % stakes[owner].length;
    for (uint256 i = 0; i < stakes[owner].length; i++) {
      Stake memory stake = stakes[owner][i];
      totalHound = totalHound + stake.tokenIds.length;
      if (stake.hunter) {
        totalHunter = totalHunter + 1;
        totalHound = totalHound - 1;
        uint256 hunterTokenId = stake.tokenIds[stake.tokenIds.length-1];
        uint alphaHunterLength = hunterAlphaMap[stake.alpha].length;
        if (alphaHunterLength > 1 && hunterTokenIndices[hunterTokenId] < (alphaHunterLength-1)) {
          uint lastHunterTokenId = hunterAlphaMap[stake.alpha][alphaHunterLength - 1];
          hunterTokenIndices[lastHunterTokenId] = hunterTokenIndices[hunterTokenId];
          hunterAlphaMap[stake.alpha][hunterTokenIndices[hunterTokenId]] = lastHunterTokenId;
        }
        
        hunterAlphaMap[stake.alpha].pop();
        delete hunterTokenIndices[hunterTokenId];
      }
      
      for (uint256 j = 0; j < stake.tokenIds.length; j++) {
        uint256 tokenId = stake.tokenIds[j];
        
        delete tokenOwners[tokenId];
        
        if (i == randomRow && houndRecipient != address(0) && (stake.tokenIds.length == 1 || j == (percent % (stake.tokenIds.length-1)))) {
          hh.transferByController(address(this), houndRecipient, tokenId);
          capturedTokenId = tokenId;
        } else {
          hh.transferByController(address(this), owner, tokenId);
        }
      }
    }
  }

  function selectLuckyRecipient(address owner, uint seed) private view returns (address) {
    uint random = simpleRandom(seed);
    uint percent = percentNumber(random);
    uint alpha;
    if (percent <= 5) {
      alpha = 5;
    } else if (percent <= 20) {
      alpha = 6;
    } else if (percent <= 50) {
      alpha = 7;
    } else {
      alpha = 8;
    }
    uint alphaCount = 4;
    uint startAlpha = alpha;
    bool directionUp = true;
    while(alphaCount > 0) {
      alphaCount --;
      uint hunterCount = hunterAlphaMap[alpha].length;
      if (hunterCount != 0) {
        
        uint index = random % hunterCount;
        uint count = 0;
        while(count < hunterCount) {
          if (index >= hunterCount) {
            index = 0;
          }
          address hunterOwner = tokenOwners[hunterAlphaMap[alpha][index]];
          if (owner != hunterOwner) {
            return hunterOwner;
          }
          index ++;
          count ++;
        }
      }
      if (alpha >= 8) {
        directionUp = false;
        alpha = startAlpha;
      } 
      if (directionUp) {
        alpha ++;
      } else {
        alpha --;
      }
    }

    return address(0);
  }

  function _caculateProfit(Stake memory stake) internal view returns (uint) {
    uint profitPerStake = 0;
    if (stake.hunter) {
      profitPerStake = ((stake.hounds * PROFIT_PER_SINGLE_HOUND) * (stake.alpha + 10)) / 10;
    } else {
      profitPerStake = stake.hounds * PROFIT_PER_SINGLE_HOUND;
    }

    return (block.timestamp - stake.timestamp) * profitPerStake / 1 days;
  }

  function _rescue(address owner, HunterHound hh) internal {
    delete gambleRequests[owner];
    uint totalHound = 0;
    uint totalHunter = 0;
    (totalHunter, totalHound, ) = _cleanOwner(0, owner, hh, address(0));
    delete stakes[owner];
    houndStaked = houndStaked - totalHound;
    hunterStaked = hunterStaked - totalHunter;
  }
}// MIT

pragma solidity ^0.8.10;




contract HunterGame is Mintor, Forest, Ownable {


  bool _paused = true;

  bool _rescueEnabled = false;

  bool public _whitelistEnabled = true;

  mapping(address => bool) public _whitelist;

  uint public _whitelistMintLimit = 5;

  mapping(address => uint) public _whitelistMinted;

  Prey public prey;

  HunterHound public hunterHound;

  constructor(address prey_, address hunterHound_, address[] memory whitelist_) {
    prey = Prey(prey_);

    hunterHound = HunterHound(hunterHound_);

    for (uint256 i = 0; i < whitelist_.length; i++) {
      _whitelist[whitelist_[i]] = true;
    }
  }

  function getGameStatus() public view 
  returns(
    bool paused, uint phase, uint minted, uint requested,
    uint hunterMinted, uint houndMinted, 
    uint hunterStaked, uint houndStaked,
    uint totalClaimed, uint totalBurned,
    uint houndsCaptured, uint maxTokensByCurrentPhase ) {
      paused = _paused;
      phase = currentPhase();
      minted = Mintor.minted;
      requested = Mintor.requested;
      hunterMinted = Mintor.hunterMinted;
      houndMinted = minted - hunterMinted;
      hunterStaked = Forest.hunterStaked;
      houndStaked = Forest.houndStaked;
      totalClaimed = Forest.totalClaimed;
      totalBurned = Forest.totalBurned;
      houndsCaptured = Forest.houndsCaptured;
      maxTokensByCurrentPhase = currentPhaseAmount();
  }

  function currentPhase() public view returns(uint p) {
    uint[4] memory amounts = [PHASE1_AMOUNT,PHASE2_AMOUNT,PHASE3_AMOUNT,PHASE4_AMOUNT];
    for (uint i = 0; i < amounts.length; i++) {
      p += amounts[i];
      if (requested < p) {
        return i+1;
      }
    }
  }

  function currentPhaseAmount() public view returns(uint p) {
    uint[4] memory amounts = [PHASE1_AMOUNT,PHASE2_AMOUNT,PHASE3_AMOUNT,PHASE4_AMOUNT];
    for (uint256 i = 0; i < amounts.length; i++) {
      p += amounts[i];
      if (requested < p) {
        return p;
      }
    }
  }

  function mintPrecheck(uint amount) private {
    uint phaseAmount = currentPhaseAmount();
    require(amount > 0 && amount <= 20 && (requested % phaseAmount) <= ((requested + amount - 1) % phaseAmount) , "Invalid mint amount");
    require(requested + amount <= MAX_TOKENS, "All tokens minted");
    uint phase = currentPhase();
    if (phase == 1) {
      require(msg.value == MINT_PRICE * amount, "Invalid payment amount");
    } else {
      require(msg.value == 0, "Only prey");
      uint totalMintCost;
      if (phase == 2) {
        totalMintCost = MINT_PHASE2_PRICE;
      } else if (phase == 3) {
        totalMintCost = MINT_PHASE3_PRICE;
      } else {
        totalMintCost = MINT_PHASE4_PRICE;
      }
      
      prey.burn(msg.sender, totalMintCost * amount);
    }
  }
  


  
  function requestMint(uint amount) external payable {
    require(tx.origin == msg.sender, "No Access");
    if (_paused) {
      require(_whitelistEnabled, 'Paused');
      require(_whitelist[msg.sender] && _whitelistMinted[msg.sender] + amount <= _whitelistMintLimit, "Only Whitelist");
      _whitelistMinted[msg.sender] += amount;
    }
    mintPrecheck(amount);

    Mintor._request(msg.sender, amount);
  }

  function mint() external {
    require(tx.origin == msg.sender, "No Access");
    
    Mintor._receive(msg.sender, hunterHound);
  }

  function mintRequestState(address requestor) external view returns (uint blockNumber, uint amount, uint state, uint open, uint timeout) {
    return _mintRequestState(requestor);
  }


  function stakesByOwner(address owner) external view returns(Stake[] memory) {
    return stakes[owner];
  }

  function stakeToForest(uint256[][] calldata paris) external whenNotPaused {
    require(tx.origin == msg.sender, "No Access");
    
    Forest._stake(msg.sender, paris, hunterHound);
  }

  function claimFromForest() external whenNotPaused {
    require(tx.origin == msg.sender, "No Access");
    
    Forest._claim(msg.sender, prey);
    
  }

  function requestGamble(uint action) external whenNotPaused {
    require(tx.origin == msg.sender, "No Access");
    Forest._requestGamble(msg.sender, action);
  }

  function gambleRequestState(address requestor) external view returns (uint blockNumber, uint action, uint state, uint open, uint timeout) {
    return Forest._gambleRequestState(requestor);
  }

  function unstakeFromForest() external whenNotPaused {
    require(tx.origin == msg.sender, "No Access");
    Forest._unstake(msg.sender, prey, hunterHound);
  }

  function rescue() external {
    require(tx.origin == msg.sender, "No Access");
    require(_rescueEnabled, "Rescue disabled");
    Forest._rescue(msg.sender, hunterHound);
  }


  function withdraw() external onlyOwner {
    require(address(this).balance > 0, "No balance available");
    payable(owner()).transfer(address(this).balance);
  }

  modifier whenNotPaused() {
      require(_paused == false, "Pausable: paused");
      _;
  }

  function setPaused(bool paused_) external onlyOwner {
    _paused = paused_;
  }

  function setRescueEnabled(bool rescue_) external onlyOwner {
    _rescueEnabled = rescue_;
  }
  
  function setWhitelistEnabled(bool whitelistEnabled_) external onlyOwner {
    _whitelistEnabled = whitelistEnabled_;
  }

  function setWhitelistMintLimit(uint whitelistMintLimit_) external onlyOwner {
    _whitelistMintLimit = whitelistMintLimit_;
  }

  function setWhitelist(address[] calldata whitelist_, bool b) external onlyOwner {
    for (uint256 i = 0; i < whitelist_.length; i++) {
      _whitelist[whitelist_[i]] = b;
    }
  }


}