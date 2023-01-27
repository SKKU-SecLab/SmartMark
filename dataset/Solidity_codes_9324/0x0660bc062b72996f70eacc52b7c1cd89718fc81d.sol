
pragma solidity ^0.8.0;

library Counters {

    struct Counter {
        uint256 _value; // default: 0
    }

    function current(Counter storage counter) internal view returns (uint256) {

        return counter._value;
    }

    function increment(Counter storage counter) internal {

        unchecked {
            counter._value += 1;
        }
    }

    function decrement(Counter storage counter) internal {

        uint256 value = counter._value;
        require(value > 0, "Counter: decrement overflow");
        unchecked {
            counter._value = value - 1;
        }
    }

    function reset(Counter storage counter) internal {

        counter._value = 0;
    }
}// MIT

pragma solidity ^0.8.0;

interface IERC165 {

    function supportsInterface(bytes4 interfaceId) external view returns (bool);

}// MIT

pragma solidity ^0.8.0;


interface IERC1155 is IERC165 {

    event TransferSingle(address indexed operator, address indexed from, address indexed to, uint256 id, uint256 value);

    event TransferBatch(
        address indexed operator,
        address indexed from,
        address indexed to,
        uint256[] ids,
        uint256[] values
    );

    event ApprovalForAll(address indexed account, address indexed operator, bool approved);

    event URI(string value, uint256 indexed id);

    function balanceOf(address account, uint256 id) external view returns (uint256);


    function balanceOfBatch(address[] calldata accounts, uint256[] calldata ids)
        external
        view
        returns (uint256[] memory);


    function setApprovalForAll(address operator, bool approved) external;


    function isApprovedForAll(address account, address operator) external view returns (bool);


    function safeTransferFrom(
        address from,
        address to,
        uint256 id,
        uint256 amount,
        bytes calldata data
    ) external;


    function safeBatchTransferFrom(
        address from,
        address to,
        uint256[] calldata ids,
        uint256[] calldata amounts,
        bytes calldata data
    ) external;

}// MIT

pragma solidity ^0.8.0;


interface IERC1155Receiver is IERC165 {

    function onERC1155Received(
        address operator,
        address from,
        uint256 id,
        uint256 value,
        bytes calldata data
    ) external returns (bytes4);


    function onERC1155BatchReceived(
        address operator,
        address from,
        uint256[] calldata ids,
        uint256[] calldata values,
        bytes calldata data
    ) external returns (bytes4);

}// MIT

pragma solidity ^0.8.0;


abstract contract ERC165 is IERC165 {
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IERC165).interfaceId;
    }
}// MIT

pragma solidity ^0.8.0;


abstract contract ERC1155Receiver is ERC165, IERC1155Receiver {
    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC165, IERC165) returns (bool) {
        return interfaceId == type(IERC1155Receiver).interfaceId || super.supportsInterface(interfaceId);
    }
}// MIT

pragma solidity ^0.8.0;


contract ERC1155Holder is ERC1155Receiver {

    function onERC1155Received(
        address,
        address,
        uint256,
        uint256,
        bytes memory
    ) public virtual override returns (bytes4) {

        return this.onERC1155Received.selector;
    }

    function onERC1155BatchReceived(
        address,
        address,
        uint256[] memory,
        uint256[] memory,
        bytes memory
    ) public virtual override returns (bytes4) {

        return this.onERC1155BatchReceived.selector;
    }
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


contract ERC721Holder is IERC721Receiver {

    function onERC721Received(
        address,
        address,
        uint256,
        bytes memory
    ) public virtual override returns (bytes4) {

        return this.onERC721Received.selector;
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
}// MIT

pragma solidity ^0.8.0;


library SafeMath {

    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        unchecked {
            uint256 c = a + b;
            if (c < a) return (false, 0);
            return (true, c);
        }
    }

    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        unchecked {
            if (b > a) return (false, 0);
            return (true, a - b);
        }
    }

    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        unchecked {
            if (a == 0) return (true, 0);
            uint256 c = a * b;
            if (c / a != b) return (false, 0);
            return (true, c);
        }
    }

    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        unchecked {
            if (b == 0) return (false, 0);
            return (true, a / b);
        }
    }

    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        unchecked {
            if (b == 0) return (false, 0);
            return (true, a % b);
        }
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {

        return a + b;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {

        return a - b;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {

        return a * b;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {

        return a / b;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {

        return a % b;
    }

    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {

        unchecked {
            require(b <= a, errorMessage);
            return a - b;
        }
    }

    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {

        unchecked {
            require(b > 0, errorMessage);
            return a / b;
        }
    }

    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {

        unchecked {
            require(b > 0, errorMessage);
            return a % b;
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
pragma solidity ^0.8.13;


contract DagenMarket is ReentrancyGuard, Ownable, Pausable, ERC1155Holder {

  using Counters for Counters.Counter;
  using SafeMath for uint256;

  string public constant REVERT_NFT_NOT_SENT = "Marketplace::NFT not sent";

  Counters.Counter private _itemIds;
  Counters.Counter private _itemsSold;
  address payable public beneficiary;

  constructor(uint256 _fee) {
    beneficiary = payable(_msgSender());
    fee = _fee;
  }

  struct MarketItem {
    uint256 itemId;
    address nftContract;
    uint256 tokenId;
    address payable creator;
    address payable nftOwner;
    uint256 price;
    uint256 leftAmount;
    uint256 amount;
    bool bid;
    bool sold;
  }

  mapping(uint256 => MarketItem) private idToMarketItem;

  event MarketItemLog(
    uint256 indexed itemId,
    address indexed nftContract,
    uint256 indexed tokenId,
    address creator,
    address nftOwner,
    uint256 price,
    uint256 amount,
    bool bid,
    bool sold
  );

  event NFTRecovery(address indexed token, uint256 indexed tokenId);


  uint256 public fee = 250;
  uint256 public constant HUNDRED_PERCENT = 10_000;

  function _takeFee(uint256 totalPrice) internal virtual returns (uint256) {

    uint256 cut = (totalPrice * fee) / HUNDRED_PERCENT;
    require(cut < totalPrice, "");
    payable(beneficiary).transfer(cut);
    uint256 left = totalPrice - cut;
    return left;
  }

  function changeFee(uint256 newFee) external onlyOwner {

    require(newFee < HUNDRED_PERCENT, "exceed");
    fee = newFee;
  }

  function changeBeneficiary(address _beneficiary) external onlyOwner {

    beneficiary = payable(_beneficiary);
  }

  function pause() public onlyOwner {

    _pause();
  }

  function unpause() public onlyOwner {

    _unpause();
  }

  function createMarketItem(
    IERC1155 nftContract,
    uint256 tokenId,
    uint256 price,
    uint256 amount
  ) public payable nonReentrant whenNotPaused {

    require(price > 0, "Price must be greater than 0");

    _itemIds.increment();
    uint256 itemId = _itemIds.current();

    idToMarketItem[itemId] = MarketItem(
      itemId,
      address(nftContract),
      tokenId,
      payable(msg.sender),
      payable(address(this)),
      price,
      amount,
      amount,
      false,
      false
    );

    nftContract.safeTransferFrom(msg.sender, address(this), tokenId, amount, new bytes(0));

    emit MarketItemLog(
      itemId,
      address(nftContract),
      tokenId,
      msg.sender,
      address(this),
      price,
      amount,
      false,
      false
    );
  }

  function createBidMarketItem(
    IERC1155 nftContract,
    uint256 tokenId,
    uint256 price,
    uint256 amount
  ) public payable nonReentrant whenNotPaused {

    require(price > 0, "Price must be greater than 0");
    require(
      msg.value == price.mul(amount),
      "Incorrect value"
    );

    _itemIds.increment();
    uint256 itemId = _itemIds.current();

    idToMarketItem[itemId] = MarketItem(
      itemId,
      address(nftContract),
      tokenId,
      payable(msg.sender),
      payable(address(0)),
      price,
      amount,
      amount,
      true,
      false
    );

    emit MarketItemLog(
      itemId,
      address(nftContract),
      tokenId,
      msg.sender,
      address(0),
      price,
      amount,
      true,
      false
    );
  }

  function removeMarketItem(IERC1155 nftContract, uint256 itemId)
    public
    payable
    nonReentrant
    whenNotPaused
  {

    require(idToMarketItem[itemId].sold != true, "The order had finished");
    require(idToMarketItem[itemId].creator == payable(msg.sender), "Must be creator of item");
    if (idToMarketItem[itemId].bid) {
      payable(msg.sender).transfer(idToMarketItem[itemId].price.mul(idToMarketItem[itemId].amount));
    } else {
      idToMarketItem[itemId].nftOwner = payable(msg.sender);
      nftContract.safeTransferFrom(
        address(this),
        idToMarketItem[itemId].creator,
        idToMarketItem[itemId].tokenId,
        idToMarketItem[itemId].amount,
        new bytes(0)
      );
    }

    idToMarketItem[itemId].leftAmount = 0;
    idToMarketItem[itemId].sold = true;
    _itemsSold.increment();

    emit MarketItemLog(
      itemId,
      address(nftContract),
      idToMarketItem[itemId].tokenId,
      address(this),
      msg.sender,
      idToMarketItem[itemId].price,
      idToMarketItem[itemId].amount,
      idToMarketItem[itemId].bid,
      true
    );
  }

  function adjustPrice(uint256 itemId, uint256 price) public payable nonReentrant whenNotPaused {

    require(idToMarketItem[itemId].creator == payable(msg.sender), "Must be creator of item");
    require(price != idToMarketItem[itemId].price, "should not same");

    uint256 amount = idToMarketItem[itemId].amount;
    if (idToMarketItem[itemId].bid) {
      if (price > idToMarketItem[itemId].price) {
        uint256 margin = price.mul(amount).sub(idToMarketItem[itemId].price.mul(amount));
        require(msg.value == margin, "Please submit correct price");
      } else {
        uint256 margin = idToMarketItem[itemId].price.mul(amount).sub(price.mul(amount));
        payable(msg.sender).transfer(margin);
      }
      idToMarketItem[itemId].price = price;
    } else {
      idToMarketItem[itemId].price = price;
    }

    emit MarketItemLog(
      itemId,
      idToMarketItem[itemId].nftContract,
      idToMarketItem[itemId].tokenId,
      idToMarketItem[itemId].creator,
      idToMarketItem[itemId].nftOwner,
      idToMarketItem[itemId].price,
      idToMarketItem[itemId].amount,
      idToMarketItem[itemId].bid,
      idToMarketItem[itemId].sold
    );
  }

  function createMarketSale(
    IERC1155 nftContract,
    uint256 itemId,
    uint256 dealAmount
  ) public payable nonReentrant whenNotPaused {

    require(dealAmount > 0, "amount is 0");
    require(idToMarketItem[itemId].bid == false, "need sale order");
    require(idToMarketItem[itemId].sold != true, "order had finished");

    uint256 price = idToMarketItem[itemId].price;
    require(msg.value == price.mul(dealAmount), "invalid order value");

    uint256 tokenId = idToMarketItem[itemId].tokenId;
    uint256 leftAmount = idToMarketItem[itemId].leftAmount.sub(dealAmount);

    nftContract.safeTransferFrom(address(this), msg.sender, tokenId, dealAmount, new bytes(0));

    idToMarketItem[itemId].creator.transfer(_takeFee(msg.value));

    if (leftAmount == 0) {
      idToMarketItem[itemId].sold = true;
      _itemsSold.increment();
    }

    idToMarketItem[itemId].nftOwner = payable(msg.sender);
    idToMarketItem[itemId].leftAmount = leftAmount;

    emit MarketItemLog(
      itemId,
      address(nftContract),
      tokenId,
      address(this),
      msg.sender,
      price,
      dealAmount,
      false,
      leftAmount == 0
    );
  }

  function createMarketBuy(
    IERC1155 nftContract,
    uint256 itemId,
    uint256 dealAmount
  ) public payable nonReentrant whenNotPaused {

    require(dealAmount > 0, "amount is 0");
    require(idToMarketItem[itemId].bid == true, "need buy order");
    require(idToMarketItem[itemId].sold != true, "order had finished");

    uint256 price = idToMarketItem[itemId].price;
    uint256 tokenId = idToMarketItem[itemId].tokenId;

    uint256 leftAmount = idToMarketItem[itemId].leftAmount.sub(dealAmount);

    nftContract.safeTransferFrom(
      msg.sender,
      idToMarketItem[itemId].creator,
      tokenId,
      dealAmount,
      new bytes(0)
    );

    payable(msg.sender).transfer(_takeFee(dealAmount.mul(price)));

    if (leftAmount == 0) {
      idToMarketItem[itemId].sold = true;
      _itemsSold.increment();
    }

    idToMarketItem[itemId].nftOwner = idToMarketItem[itemId].creator;
    idToMarketItem[itemId].leftAmount = leftAmount;

    emit MarketItemLog(
      itemId,
      address(nftContract),
      tokenId,
      msg.sender,
      idToMarketItem[itemId].creator,
      price,
      dealAmount,
      true,
      leftAmount == 0
    );
  }

  function fetchMarketItems() public view returns (MarketItem[] memory) {

    uint256 itemCount = _itemIds.current();

    MarketItem[] memory items = new MarketItem[](itemCount);
    for (uint256 i = 0; i < itemCount; i++) {
      MarketItem storage currentItem = idToMarketItem[i + 1];
      items[i] = currentItem;
    }
    return items;
  }

  function fetchMarketItemsPaged(uint256 cursor, uint256 size)
    public
    view
    returns (MarketItem[] memory marketItems, uint256 total)
  {

    uint256 itemCount = _itemIds.current();
    MarketItem[] memory items = new MarketItem[](itemCount);

    uint256 length = size;

    if (length > itemCount - cursor) {
      length = itemCount - cursor;
    }

    marketItems = new MarketItem[](length);

    for (uint256 i = 0; i < length; i++) {
      MarketItem storage currentItem = idToMarketItem[cursor + 1];
      marketItems[i] = currentItem;
    }

    return (marketItems, items.length);
  }

  function fetchMarketItemsById(
    IERC1155 nftContract,
    uint256 tokenId,
    bool bid
  ) public view returns (MarketItem[] memory) {

    uint256 itemCount = _itemIds.current();

    uint256 matchCount = 0;
    for (uint256 i = 0; i < itemCount; i++) {
      if (
        !idToMarketItem[i + 1].sold &&
        idToMarketItem[i + 1].nftContract == address(nftContract) &&
        idToMarketItem[i + 1].tokenId == tokenId &&
        idToMarketItem[i + 1].bid == bid
      ) {
        matchCount += 1;
      }
    }

    MarketItem[] memory items = new MarketItem[](matchCount);

    uint256 currentIndex = 0;
    for (uint256 i = 0; i < itemCount; i++) {
      if (
        !idToMarketItem[i + 1].sold &&
        idToMarketItem[i + 1].nftContract == address(nftContract) &&
        idToMarketItem[i + 1].tokenId == tokenId &&
        idToMarketItem[i + 1].bid == bid
      ) {
        uint256 currentId = i + 1;
        MarketItem storage currentItem = idToMarketItem[currentId];
        items[currentIndex] = currentItem;
        currentIndex += 1;
      }
    }

    return items;
  }

  function fetchMarketItemsByIdPaged(
    IERC1155 nftContract,
    uint256 tokenId,
    bool bid,
    uint256 cursor,
    uint256 size
  ) public view returns (MarketItem[] memory marketItems, uint256 total) {

    MarketItem[] memory items = fetchMarketItemsById(nftContract, tokenId, bid);

    uint256 length = size;

    if (length > items.length - cursor) {
      length = items.length - cursor;
    }

    marketItems = new MarketItem[](length);

    for (uint256 i = 0; i < length; i++) {
      marketItems[i] = items[cursor + i];
    }

    return (marketItems, items.length);
  }

  function recoverNFT(
    IERC1155 nftContract,
    uint256 tokenId,
    uint256 amount
  ) external onlyOwner {

    nftContract.safeTransferFrom(address(this), address(msg.sender), tokenId, amount, new bytes(0));
    emit NFTRecovery(address(nftContract), tokenId);
  }
}