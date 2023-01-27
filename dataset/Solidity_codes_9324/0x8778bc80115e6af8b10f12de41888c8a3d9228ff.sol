
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


library SafeERC20 {

    using Address for address;

    function safeTransfer(
        IERC20 token,
        address to,
        uint256 value
    ) internal {

        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(
        IERC20 token,
        address from,
        address to,
        uint256 value
    ) internal {

        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    function safeApprove(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {

        require(
            (value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {

        uint256 newAllowance = token.allowance(address(this), spender) + value;
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {

        unchecked {
            uint256 oldAllowance = token.allowance(address(this), spender);
            require(oldAllowance >= value, "SafeERC20: decreased allowance below zero");
            uint256 newAllowance = oldAllowance - value;
            _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
        }
    }

    function _callOptionalReturn(IERC20 token, bytes memory data) private {


        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) {
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
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

        _setApprovalForAll(_msgSender(), operator, approved);
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

    function _setApprovalForAll(
        address owner,
        address operator,
        bool approved
    ) internal virtual {

        require(owner != operator, "ERC721: approve to caller");
        _operatorApprovals[owner][operator] = approved;
        emit ApprovalForAll(owner, operator, approved);
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
}//UNLICENSED

pragma solidity ^0.8.0;


contract BazaarBoard is Pausable, Ownable {
  using SafeERC20 for IERC20;

  struct Listing {
    uint256 price;
    uint256 timestamp;
    address lister;
    uint256 expiresAt;
  }

  struct Offer {
    address purchaser;
    uint256 price;
    OfferState status;
    uint256 expiresAt;  
    uint256 timestamp;
    bytes32 identHash;
  }

  enum OfferState{ WAITING, CANCELLED, ACCEPTED }

  mapping(address => mapping(uint256 => Listing)) public collectionToTokensToListing;
  mapping(address => mapping(uint256 => Offer[])) public collectionToTokenIdToOffers;

  mapping(address => address) public collectionToCurrency;
  mapping(address => address) public collectionToTreasury;

  address public bazaarBank;

  mapping(address => uint256) public collectionToTreasuryFee; 
  mapping(address => uint256) public collectionToBazaarFee;

  event ListingCreated(address indexed collection, uint256 tokenid, address indexed lister, uint256 price, uint256 expiresAt, uint256 timestamp);
  event ListingRemoved(address indexed collection, uint256 tokenid, address indexed user, uint256 price, uint256 timestamp);
  event ListingBought(address indexed collection, uint256 tokenid, address indexed lister, address indexed buyer, uint256 price, uint256 timestamp);
  event ListingUpdated(address indexed collection, uint256 tokenid, address indexed lister, uint256 price, uint256 expiresAt, uint256 timestamp);

  event OfferPlaced(address indexed collection, uint256 tokenid, bytes32 identHash, address indexed purchaser, uint256 price, uint256 expiresAt, uint256 timestamp);
  event OfferCancelled(address indexed collection, uint256 tokenid, bytes32 identHash, address indexed purchaser, uint256 price, uint256 expiresAt, uint256 timestamp);
  event OfferAccepted(address indexed collection, uint256 tokenid, bytes32 identHash, address indexed purchaser, address indexed seller, uint256 price, uint256 expiresAt, uint256 timestamp);

  constructor(address _bazaar) {
    bazaarBank = _bazaar;
  }


  function calculateFee(uint256 price, uint256 fee) public pure returns(uint256) {
    return (price * fee) / 10000;
  }

  function handleTransfer(address collection, uint256 tokenId, uint256 price, address from, address to) internal {
    uint256 treasuryFee = calculateFee(price, collectionToTreasuryFee[collection]);
    uint256 bazaarFee = calculateFee(price, collectionToBazaarFee[collection]);

    uint256 saleProceeds = price;

    if (treasuryFee != 0) {
      saleProceeds = saleProceeds - treasuryFee;
      require(collectionToTreasury[collection] != address(0), "Invalid treasury");
      IERC20(collectionToCurrency[collection]).safeTransferFrom(to, collectionToTreasury[collection], treasuryFee);
    }

    if (bazaarFee != 0) {
      saleProceeds = saleProceeds - bazaarFee;
      IERC20(collectionToCurrency[collection]).safeTransferFrom(to, bazaarBank, bazaarFee);
    }

    
    IERC20(collectionToCurrency[collection]).safeTransferFrom(to, from, saleProceeds);
    
    IERC721(collection).safeTransferFrom(
      from,
      to,
      tokenId
    );
    
  }



  modifier isValidListing(address collection, uint256 tokenId) {
    require(isListed(collection, tokenId), "Must be valid listing");
    _;
  }

  modifier isValidPrice(uint256 price) {
    require(price >= 1,"Invalid Price");
    _;
  }

  function listForSale(address collection, uint256 tokenId, uint256 price, uint256 expiresAt) external whenNotPaused isValidPrice(price) {
    require(expiresAt > block.timestamp, "Time must be in future");
    if (isListed(collection, tokenId)) {
      require(getListing(collection, tokenId).expiresAt <= block.timestamp);
    }
    require(IERC721(collection).getApproved(tokenId) == address(this) || IERC721(collection).isApprovedForAll(msg.sender, address(this)),"Not approved");
    
    collectionToTokensToListing[collection][tokenId] = Listing(
      price,
      block.timestamp,
      msg.sender,
      expiresAt
    );
    emit ListingCreated(collection, tokenId,msg.sender, price, expiresAt, block.timestamp);
  }

  function isListed(address collection, uint256 tokenId) public view returns (bool) {
    return collectionToTokensToListing[collection][tokenId].timestamp != 0;
  }

  function getListing(address collection, uint256 tokenId) public view isValidListing(collection, tokenId) returns (Listing memory) {
    Listing memory listing = collectionToTokensToListing[collection][tokenId];

    return listing;
  }

  function removeListing(address collection, uint256 tokenId) internal {
    delete collectionToTokensToListing[collection][tokenId];
  }

  function withdrawFromSale(address collection, uint256 tokenId)  isValidListing(collection, tokenId) external {
    Listing memory thisListing = collectionToTokensToListing[collection][tokenId];

    require(
      msg.sender == thisListing.lister ||
          msg.sender == owner() || IERC721(collection).ownerOf(tokenId) == msg.sender, "Must be lister/deployer/current owner"
    );
    emit ListingRemoved(collection, tokenId, msg.sender, thisListing.price, block.timestamp);

    removeListing(collection, tokenId);
  }

  function updatePrice(address collection, uint256 tokenId, uint256 price) external isValidPrice(price) {
    Listing memory thisListing = collectionToTokensToListing[collection][tokenId];

    require(
      msg.sender == thisListing.lister, "Must be lister/deployer"
    );

    collectionToTokensToListing[collection][tokenId].price = price;
    emit ListingUpdated(collection, tokenId, msg.sender, price, thisListing.expiresAt, block.timestamp);
  }

  function updateExpiry(address collection, uint256 tokenId, uint256 expiresAt) external {
    Listing memory thisListing = collectionToTokensToListing[collection][tokenId];

    require(
      msg.sender == thisListing.lister, "Must be lister/deployer"
    );

    require(expiresAt >= block.timestamp,"Time in past");

    collectionToTokensToListing[collection][tokenId].expiresAt = expiresAt;
    emit ListingUpdated(collection, tokenId, msg.sender, thisListing.price, expiresAt, block.timestamp);
  }

  function buyListing(address collection, uint256 tokenId, uint256 currentPrice) external whenNotPaused {
    Listing memory thisListing = getListing(collection, tokenId);
    require(thisListing.lister == IERC721(collection).ownerOf(tokenId), "Listing by previous owner");
    require(msg.sender != thisListing.lister,"You cannot buy your own listing");
    require(thisListing.price == currentPrice,"Price has changed");
    require(thisListing.expiresAt >= block.timestamp,"Listing expired");

    removeListing(collection, tokenId);

    handleTransfer(collection, tokenId, currentPrice, thisListing.lister, msg.sender);
    emit ListingBought(collection, tokenId, thisListing.lister, msg.sender, thisListing.price, block.timestamp);

  }


  function getOffers(address collection, uint256 tokenId) external view returns (Offer[] memory) {
    return collectionToTokenIdToOffers[collection][tokenId];
  }

  function getOffersCount(address collection, uint256 tokenId) external view returns (uint256) {
    return collectionToTokenIdToOffers[collection][tokenId].length;
  }
  

  function placeOffer(address collection, uint256 tokenId, uint256 price, uint256 expiry) external whenNotPaused isValidPrice(price) returns (bytes32) {
    require(IERC20(collectionToCurrency[collection]).balanceOf(msg.sender) >= price,"Token balance too low.");

    bytes32 ident = keccak256(abi.encodePacked(msg.sender,collection, tokenId, price, block.timestamp));
    Offer memory thisOffer = Offer(msg.sender, price, OfferState.WAITING, expiry, block.timestamp, ident);
    collectionToTokenIdToOffers[collection][tokenId].push(thisOffer);
    emit OfferPlaced(collection, tokenId,ident, msg.sender, price, expiry, block.timestamp);
    return ident;
  }

  function acceptOfferViaIdentHash(address collection, uint256 tokenId, bytes32 _identHash) external {
    Offer memory theOffer;
    uint thisIndex;
    for (uint256 i = 0; i < collectionToTokenIdToOffers[collection][tokenId].length; i++) {
      Offer memory thisOffer = collectionToTokenIdToOffers[collection][tokenId][i];
      if (thisOffer.identHash == _identHash) {
        theOffer = thisOffer;
        thisIndex = i;
      }
    }
    finalizeOfferAccepting(collection, tokenId, theOffer, thisIndex);
  }

  function acceptOfferViaIndex(address collection, uint256 tokenId, uint256 thisIndex) external {
    Offer memory theOffer = collectionToTokenIdToOffers[collection][tokenId][thisIndex];
    finalizeOfferAccepting(collection, tokenId, theOffer, thisIndex);
  }

  function cancelOfferViaIdentHash(address collection, uint256 tokenId, bytes32 _identHash) external {
    Offer memory theOffer;
    uint thisIndex;
    for (uint256 i = 0; i < collectionToTokenIdToOffers[collection][tokenId].length; i++) {
      Offer memory thisOffer = collectionToTokenIdToOffers[collection][tokenId][i];
      if (thisOffer.identHash == _identHash) {
        theOffer = thisOffer;
        thisIndex = i;
      }
    }
    finalizeOfferCancelling(collection, tokenId, theOffer, thisIndex);
  }

  function cancelOfferViaIndex(address collection, uint256 tokenId, uint256 thisIndex) external {
    finalizeOfferCancelling(collection, tokenId, collectionToTokenIdToOffers[collection][tokenId][thisIndex], thisIndex);
  }

  function finalizeOfferAccepting(address collection, uint256 tokenId, Offer memory theOffer, uint256 thisIndex) internal {
    require(block.timestamp < theOffer.expiresAt,"Offer expired");
    require(theOffer.status == OfferState.WAITING,"Offer is not available");
    collectionToTokenIdToOffers[collection][tokenId][thisIndex].status = OfferState.ACCEPTED;
    handleTransfer(collection, tokenId, theOffer.price, msg.sender, theOffer.purchaser);
    emit OfferAccepted(collection, tokenId, theOffer.identHash, theOffer.purchaser, msg.sender, theOffer.price, theOffer.expiresAt, block.timestamp);
  }

  function finalizeOfferCancelling(address collection, uint256 tokenId, Offer memory theOffer, uint256 thisIndex) internal {
    require(
      msg.sender == theOffer.purchaser ||
          msg.sender == owner(), "Must be bidder/deployer"
    );
    require(block.timestamp < theOffer.expiresAt,"Offer expired");
    collectionToTokenIdToOffers[collection][tokenId][thisIndex].status = OfferState.CANCELLED;
    emit OfferCancelled(collection, tokenId,theOffer.identHash, msg.sender, theOffer.price, theOffer.expiresAt, block.timestamp);
  }



  function emergencyPause() external onlyOwner {
    _pause();
  }

  function unPause() external onlyOwner {
    _unpause();
  }

  function setNewBazaarBank(address _bazaar) external onlyOwner  {
    bazaarBank = _bazaar;
  }

  function setCurrencyForCollection(address collection, address erc20) external onlyOwner {
    collectionToCurrency[collection] = erc20;
  }

  function setTreasuryForCollection(address collection, address newAddress) external onlyOwner {
    collectionToTreasury[collection] = newAddress;
  }

  function setTreasuryFeeForCollection(address collection, uint256 feeAmt) external onlyOwner {
    collectionToTreasuryFee[collection] = feeAmt;
  }

  function setBazaarFeeForCollection(address collection, uint256 feeAmt) external onlyOwner {
    collectionToBazaarFee[collection] = feeAmt;
  }

}