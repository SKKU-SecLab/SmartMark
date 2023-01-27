
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

interface IAccessControl {

    event RoleAdminChanged(bytes32 indexed role, bytes32 indexed previousAdminRole, bytes32 indexed newAdminRole);

    event RoleGranted(bytes32 indexed role, address indexed account, address indexed sender);

    event RoleRevoked(bytes32 indexed role, address indexed account, address indexed sender);

    function hasRole(bytes32 role, address account) external view returns (bool);


    function getRoleAdmin(bytes32 role) external view returns (bytes32);


    function grantRole(bytes32 role, address account) external;


    function revokeRole(bytes32 role, address account) external;


    function renounceRole(bytes32 role, address account) external;

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


abstract contract AccessControl is Context, IAccessControl, ERC165 {
    struct RoleData {
        mapping(address => bool) members;
        bytes32 adminRole;
    }

    mapping(bytes32 => RoleData) private _roles;

    bytes32 public constant DEFAULT_ADMIN_ROLE = 0x00;

    modifier onlyRole(bytes32 role) {
        _checkRole(role, _msgSender());
        _;
    }

    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IAccessControl).interfaceId || super.supportsInterface(interfaceId);
    }

    function hasRole(bytes32 role, address account) public view override returns (bool) {
        return _roles[role].members[account];
    }

    function _checkRole(bytes32 role, address account) internal view {
        if (!hasRole(role, account)) {
            revert(
                string(
                    abi.encodePacked(
                        "AccessControl: account ",
                        Strings.toHexString(uint160(account), 20),
                        " is missing role ",
                        Strings.toHexString(uint256(role), 32)
                    )
                )
            );
        }
    }

    function getRoleAdmin(bytes32 role) public view override returns (bytes32) {
        return _roles[role].adminRole;
    }

    function grantRole(bytes32 role, address account) public virtual override onlyRole(getRoleAdmin(role)) {
        _grantRole(role, account);
    }

    function revokeRole(bytes32 role, address account) public virtual override onlyRole(getRoleAdmin(role)) {
        _revokeRole(role, account);
    }

    function renounceRole(bytes32 role, address account) public virtual override {
        require(account == _msgSender(), "AccessControl: can only renounce roles for self");

        _revokeRole(role, account);
    }

    function _setupRole(bytes32 role, address account) internal virtual {
        _grantRole(role, account);
    }

    function _setRoleAdmin(bytes32 role, bytes32 adminRole) internal virtual {
        bytes32 previousAdminRole = getRoleAdmin(role);
        _roles[role].adminRole = adminRole;
        emit RoleAdminChanged(role, previousAdminRole, adminRole);
    }

    function _grantRole(bytes32 role, address account) internal virtual {
        if (!hasRole(role, account)) {
            _roles[role].members[account] = true;
            emit RoleGranted(role, account, _msgSender());
        }
    }

    function _revokeRole(bytes32 role, address account) internal virtual {
        if (hasRole(role, account)) {
            _roles[role].members[account] = false;
            emit RoleRevoked(role, account, _msgSender());
        }
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
pragma solidity >0.8.0;


library NftTokenHandler {

  bytes4 private constant _INTERFACE_ID_ERC721 = 0x80ac58cd;
  bytes4 private constant _INTERFACE_ID_ERC1155 = 0xd9b67a26;

  function isOwner(
      address nftContract, 
      uint256 tokenId, 
      address account 
  ) internal view returns (bool) {


      if(IERC165(nftContract).supportsInterface(_INTERFACE_ID_ERC721)) {
        return IERC721(nftContract).ownerOf(tokenId) == account;
      }

      if(IERC165(nftContract).supportsInterface(_INTERFACE_ID_ERC1155)) {
        return IERC1155(nftContract).balanceOf(account, tokenId) > 0;
      }

      return false;

  }

  function isApproved(
      address nftContract, 
      uint256 tokenId, 
      address owner, 
      address operator
    ) internal view returns (bool) {


      if(IERC165(nftContract).supportsInterface(_INTERFACE_ID_ERC721)) {
        return IERC721(nftContract).getApproved(tokenId) == operator;
      }

      if(IERC165(nftContract).supportsInterface(_INTERFACE_ID_ERC1155)) {
        return IERC1155(nftContract).isApprovedForAll(owner, operator);
      }

      return false;
    }

  function transfer(
      address nftContract, 
      uint256 tokenId, 
      address from, 
      address to, 
      bytes memory data 
    ) internal {


      if(IERC165(nftContract).supportsInterface(_INTERFACE_ID_ERC721)) {
        return IERC721(nftContract).safeTransferFrom(from, to, tokenId);
      }

      if(IERC165(nftContract).supportsInterface(_INTERFACE_ID_ERC1155)) {
        return IERC1155(nftContract).safeTransferFrom(from, to, tokenId, 1, data);
      }

      revert("Unidentified NFT contract.");
    }
}// MIT

interface IRoality {

  function roalityAccount() external view returns (address);

  function roality() external view returns (uint256);

  function setRoalityAccount(address account) external;

  function setRoality(uint256 thousandths) external;

}// MIT


library RoalityHandler {


  modifier hasRoality(address nftContract) {

    require(isSupportRoality(nftContract));
    _;
  }

  function isSupportRoality(address nftContract) 
    internal 
    view 
    returns (bool) {

    
      return IERC165(nftContract)
        .supportsInterface(
          type(IRoality).interfaceId
        );

    }

  function roalityAccount(address nftContract) 
    internal 
    view 
    hasRoality(nftContract) 
    returns (address) {


      return IRoality(nftContract).roalityAccount();

    }

  function roality(address nftContract)
    internal
    view
    hasRoality(nftContract) 
    returns (uint256) {


      return IRoality(nftContract).roality();

    }

  function setRoalityAccount(address nftContract, address account)
    internal
    hasRoality(nftContract) {


      IRoality(nftContract).setRoalityAccount(account);

    }

  function setRoality(address nftContract, uint256 thousandths)
    internal
    hasRoality(nftContract) {


      IRoality(nftContract).setRoality(thousandths);
      
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
}// MIT


contract NftMarket is AccessControl, ReentrancyGuard, Pausable {

  bytes32 public constant ADMIN_ROLE = keccak256("ADMIN_ROLE");
  using SafeMath for uint256;
  address private serviceAccount;
  address private dealerOneTimeOperator;
  address public dealerContract;

  constructor() {
    _setupRole(DEFAULT_ADMIN_ROLE, msg.sender);
    _setupRole(ADMIN_ROLE, msg.sender);
    serviceAccount = msg.sender;
    dealerOneTimeOperator = msg.sender;
  }

  function alterServiceAccount(address account) public onlyRole(ADMIN_ROLE) {

    serviceAccount = account;
  }

  function alterDealerContract(address _dealerContract) public {

    require(msg.sender == dealerOneTimeOperator, "Permission Denied.");
    dealerOneTimeOperator = address(0);
    dealerContract = _dealerContract;
  }

  event Deal (
    address currency,
    address indexed nftContract,
    uint256 tokenId,
    address seller,
    address buyer,
    uint256 price,
    uint256 comission,
    uint256 roality,
    uint256 dealTime,
    bytes32 indexed tokenIndex,
    bytes32 indexed dealIndex
  );

  function pause() public onlyRole(ADMIN_ROLE) {

    _pause();
  }

  function unpause() public onlyRole(ADMIN_ROLE) {

    _unpause();
  }
  
  function indexToken(address nftContract, uint256 tokenId) public pure returns (bytes32) {

    return keccak256(abi.encodePacked(nftContract, tokenId));
  }

  function indexDeal(bytes32 tokenIndex, address seller, address buyer, uint256 dealTime) public pure returns (bytes32) {

    return keccak256(abi.encodePacked(tokenIndex, seller, buyer, dealTime));
  }

  function isMoneyApproved(IERC20 money, address account, uint256 amount) public view returns (bool) {

    if (money.allowance(account, address(this)) >= amount) return true;
    if (money.balanceOf(account) >= amount) return true;
    return false;
  }

  function isNftApproved(address nftContract, uint256 tokenId, address owner) public view returns (bool) {

    return NftTokenHandler.isApproved(nftContract, tokenId, owner, address(this));
  }

  function _dealPayments(
    uint256 price,
    uint256 comission,
    uint256 roality
  ) private pure returns (uint256[3] memory) {


    uint256 serviceFee = price
      .mul(comission).div(1000);

    uint256 roalityFee = roality > 0 ? 
      price.mul(roality).div(1000) : 0;

    uint256 sellerEarned = price
      .sub(serviceFee)
      .sub(roalityFee);

    return [sellerEarned, serviceFee, roalityFee];
  }

  function _payByPayable(address[3] memory receivers, uint256[3] memory payments) private {

      
    if(payments[0] > 0) payable(receivers[0]).transfer(payments[0]); // seller : sellerEarned
    if(payments[1] > 0) payable(receivers[1]).transfer(payments[1]); // serviceAccount : serviceFee
    if(payments[2] > 0) payable(receivers[2]).transfer(payments[2]); // roalityAccount : roalityFee
      
  }

  function _payByERC20(
    address erc20Contract, 
    address buyer,
    uint256 price,
    address[3] memory receivers, 
    uint256[3] memory payments) private {

    
    IERC20 money = IERC20(erc20Contract);
    require(money.balanceOf(buyer) >= price, "Buyer doesn't have enough money to pay.");
    require(money.allowance(buyer, address(this)) >= price, "Buyer allowance isn't enough.");

    money.transferFrom(buyer, address(this), price);
    if(payments[0] > 0) money.transfer(receivers[0], payments[0]); // seller : sellerEarned
    if(payments[0] > 0) money.transfer(receivers[1], payments[1]); // serviceAccount : serviceFee
    if(payments[0] > 0) money.transfer(receivers[2], payments[2]); // roalityAccount : roalityFee

  }

  function deal(
    address erc20Contract,
    address nftContract,
    uint256 tokenId,
    address seller,
    address buyer,
    uint256 price,
    uint256 comission,
    uint256 roality,
    address roalityAccount,
    bytes32 dealIndex
  ) 
    public 
    nonReentrant 
    whenNotPaused
    payable
  {

    require(msg.sender == dealerContract, "Permission Denied.");
    require(isNftApproved(nftContract, tokenId, seller), "Doesn't have approval of this token.");
    
    uint256[3] memory payments = _dealPayments(price, comission, roality);
    
    if(erc20Contract == address(0) && msg.value > 0) {
      require(msg.value == price, "Payment amount incorrect.");
      _payByPayable([seller, serviceAccount, roalityAccount], payments);
    } else {
      _payByERC20(erc20Contract, buyer, price, [seller, serviceAccount, roalityAccount], payments);
    }

    NftTokenHandler.transfer(nftContract, tokenId, seller, buyer, abi.encodePacked(dealIndex));
    
    emit Deal(
      erc20Contract,
      nftContract,
      tokenId,
      seller,
      buyer,
      price,
      payments[1],
      payments[2],
      block.timestamp,
      indexToken(nftContract, tokenId),
      dealIndex
    );
  }

}// MIT


contract NftMarketResaller is AccessControl {

  using SafeMath for uint256;
  bytes32 public constant ADMIN_ROLE = keccak256("ADMIN_ROLE");
  enum SellMethod { NOT_FOR_SELL, FIXED_PRICE, SELL_TO_HIGHEST_BIDDER, SELL_WITH_DECLINING_PRICE, ACCEPT_OFFER }
  enum SellState { NONE, ON_SALE, PAUSED, SOLD, FAILED, CANCELED }

  NftMarket market;
  uint256 public comission;
  uint256 public maxBookDuration;
  uint256 public minBookDuration;

  constructor(NftMarket mainMarket) {
    market = mainMarket;
    comission = 25; // 25 / 1000 = 2.5%
    maxBookDuration = 86400 * 30 * 6; // six month
    _setupRole(DEFAULT_ADMIN_ROLE, msg.sender);
    _setupRole(ADMIN_ROLE, msg.sender);
  }
  
  struct Book {
    bytes32 bookId;
    address erc20Contract;
    address nftContract;
    uint256 tokenId;
    uint256 price; // dealed price
    uint256[] priceOptions;
    SellMethod method;
    SellState state; // 0: NONE, 2: ON_SALE, 3: PAUSED
    address seller;
    address buyer;
    uint256 payableAmount;
  }

  struct BookTiming {
    uint256 timestamp;
    uint256 beginTime;
    uint256 endTime;
  }

  struct BookSummary {
    uint256 topAmount;
    address topBidder;
  }

  struct BookShare {
    uint256 comission;
    uint256 roality;
  }

  struct Bid {
    bytes32 bookId;
    address buyer;
    uint256 price;
    uint256 timestamp;
  }

  mapping(bytes32 => Book) public books;
  mapping(bytes32 => BookTiming) public booktimes;
  mapping(bytes32 => BookSummary) public booksums;
  mapping(bytes32 => BookShare) public bookshares;
  mapping(bytes32 => Bid) public biddings;

  event Booked(
    bytes32 bookId,
    address erc20Contract,
    address indexed nftContract,
    uint256 tokenId,
    address seller, 
    SellMethod method,
    uint256[] priceOptions,
    uint256 beginTime,
    uint256 bookedTime,
    bytes32 indexed tokenIndex
  );

  event Bidded(
    bytes32 bookId, 
    address indexed nftContract,
    uint256 tokenId,
    address seller, 
    address buyer, 
    uint256 price,
    uint256 timestamp,
    bytes32 indexed tokenIndex
  );

  event Dealed(
    address erc20Contract,
    address indexed nftContract,
    uint256 tokenId,
    address seller, 
    address buyer, 
    SellMethod method,
    uint256 price,
    uint256 comission,
    uint256 roality,
    uint256 dealedTime,
    bytes32 referenceId,
    bytes32 indexed tokenIndex
  );

  event Failed(
    address indexed nftContract,
    uint256 tokenId,
    address seller, 
    address buyer, 
    SellMethod method,
    uint256 price,
    uint256 timestamp,
    bytes32 referenceId,
    bytes32 indexed tokenIndex
  );

  modifier isBiddable(bytes32 bookId) {

    require(books[bookId].state == SellState.ON_SALE, "Not on sale.");
    require(books[bookId].method == SellMethod.SELL_TO_HIGHEST_BIDDER, "This sale didn't accept bidding.");
    require(booktimes[bookId].beginTime <= block.timestamp, "Auction not start yet.");
    require(booktimes[bookId].endTime > block.timestamp, "Auction finished.");
    _;
  }

  modifier isBuyable(bytes32 bookId) {

    require(books[bookId].state == SellState.ON_SALE, "Not on sale.");
    require(
      books[bookId].method == SellMethod.FIXED_PRICE || 
      books[bookId].method == SellMethod.SELL_WITH_DECLINING_PRICE, 
      "Sale not allow direct purchase.");
    require(booktimes[bookId].beginTime <= block.timestamp, "This sale is not availble yet.");
    require(booktimes[bookId].endTime > block.timestamp, "This sale has expired.");
    _;
  }

  modifier isValidBook(bytes32 bookId) {

    _validateBook(bookId);
    _;
  }

  modifier onlySeller(bytes32 bookId) {

    require(books[bookId].seller == msg.sender, "Only seller may modify the sale");
    _;
  }

  function _validateBook(bytes32 bookId) private view {

    
    require(
      address(books[bookId].nftContract) != address(0), 
      "NFT Contract unavailable");

    require(
      market.isNftApproved(
        books[bookId].nftContract, 
        books[bookId].tokenId, 
        books[bookId].seller), 
      "Owner hasn't grant permission for sell");

    require(booktimes[bookId].endTime > booktimes[bookId].beginTime, 
      "Duration setting incorrect");
    
    if(books[bookId].method == SellMethod.FIXED_PRICE) {
      require(books[bookId].priceOptions.length == 1, "Price format incorrect.");
      require(books[bookId].priceOptions[0] > 0, "Price must greater than zero.");
    }

    if(books[bookId].method == SellMethod.SELL_TO_HIGHEST_BIDDER) {
      require(books[bookId].priceOptions.length == 2, "Price format incorrect.");
      require(books[bookId].priceOptions[1] >= books[bookId].priceOptions[0], "Reserve price must not less then starting price.");
    }

    if(books[bookId].method == SellMethod.SELL_WITH_DECLINING_PRICE) {
      require(books[bookId].priceOptions.length == 2, "Price format incorrect.");
      require(books[bookId].priceOptions[0] > books[bookId].priceOptions[1], "Ending price must less then starting price.");
    }
  }

  function index(address nftContract, uint256 tokenId) public pure returns (bytes32) {

    return keccak256(abi.encodePacked(nftContract, tokenId));
  }

  function bookIndex(address nftContract, uint256 tokenId, uint256 timestamp) public pure returns (bytes32) {

    return keccak256(abi.encodePacked(nftContract, tokenId, timestamp));
  }

  function bidIndex(bytes32 bookId, uint256 beginTime, address buyer) public pure returns (bytes32) {

    return keccak256(abi.encodePacked(bookId, beginTime, buyer));
  }

  function decliningPrice(
    uint256 beginTime,
    uint256 endTime,
    uint256 startingPrice,
    uint256 endingPrice,
    uint256 targetTime
  ) public pure returns (uint256) {

      return startingPrice.sub(
        targetTime.sub(beginTime)
        .mul(startingPrice.sub(endingPrice))
        .div(endTime.sub(beginTime)));
  }


  function book(
    address erc20Contract,
    address nftContract, 
    uint256 tokenId, 
    uint256 beginTime,
    uint256 endTime,
    SellMethod method, 
    uint256[] memory priceOptions 
    ) public payable returns (bytes32) {

    require(NftTokenHandler.isOwner(nftContract, tokenId, msg.sender), "Callee doesn't own this token");
    require(market.isNftApproved(nftContract, tokenId, msg.sender), "Not having approval of this token.");
    require(beginTime > block.timestamp.sub(3600), "Sell must not start 1 hour earilar than book time.");
    require(endTime > block.timestamp.add(minBookDuration), "Sell ending in less than 5 minute will be revert.");
    require(endTime.sub(beginTime) < maxBookDuration, "Exceed maximum selling duration.");

    bytes32 bookId = bookIndex(nftContract, tokenId, block.timestamp);
    
    books[bookId].bookId = bookId;
    books[bookId].erc20Contract = erc20Contract;
    books[bookId].nftContract = nftContract;
    books[bookId].tokenId = tokenId;
    books[bookId].priceOptions = priceOptions;
    books[bookId].method = method;
    books[bookId].state = SellState.ON_SALE;
    books[bookId].seller = msg.sender;
    booktimes[bookId].timestamp = block.timestamp;
    booktimes[bookId].beginTime = beginTime;
    booktimes[bookId].endTime = endTime;
    bookshares[bookId].comission = comission;
    bookshares[bookId].roality = RoalityHandler.roality(nftContract);
    
    _validateBook(bookId);

    emit Booked(
      books[bookId].bookId, 
      books[bookId].erc20Contract,
      books[bookId].nftContract,
      books[bookId].tokenId,
      books[bookId].seller,
      books[bookId].method,
      books[bookId].priceOptions,
      booktimes[bookId].beginTime,
      block.timestamp,
      index(
        books[bookId].nftContract, 
        books[bookId].tokenId)
      );

    return bookId;
  }

  function priceOf(bytes32 bookId) public view returns (uint256) {

    
    if(books[bookId].method == SellMethod.FIXED_PRICE) {
      return books[bookId].priceOptions[0];
    }

    if(books[bookId].method == SellMethod.SELL_WITH_DECLINING_PRICE) {
      return decliningPrice(
        booktimes[bookId].beginTime,
        booktimes[bookId].endTime,
        books[bookId].priceOptions[0],
        books[bookId].priceOptions[1],
        block.timestamp
      );
    }

    if(books[bookId].method == SellMethod.SELL_TO_HIGHEST_BIDDER) {
      return booksums[bookId].topAmount;
    }

    return 0;
  }

  function priceOptionsOf(bytes32 bookId) public view returns (uint256[] memory) {

    return books[bookId].priceOptions;
  }

  function pauseBook(bytes32 bookId) public onlySeller(bookId) {

    require(books[bookId].state == SellState.ON_SALE, "Sale not available.");
    books[bookId].state = SellState.PAUSED;
  }

  function resumeBook(bytes32 bookId, uint256 endTime) public onlySeller(bookId) {

    require(books[bookId].state == SellState.PAUSED, "Sale not paused.");
    books[bookId].state = SellState.ON_SALE;
    booktimes[bookId].endTime = endTime;
  }

  function _cancelBook(bytes32 bookId) private {

    require(
      books[bookId].state != SellState.SOLD &&
      books[bookId].state != SellState.FAILED &&
      books[bookId].state != SellState.CANCELED, 
      "Sale ended."
    );
    
    books[bookId].buyer = address(0);
    booktimes[bookId].endTime = block.timestamp;
    books[bookId].state = SellState.CANCELED;

    emit Failed(
      books[bookId].nftContract, 
      books[bookId].tokenId,
      books[bookId].seller, 
      books[bookId].buyer,
      books[bookId].method, 
      books[bookId].price,
      block.timestamp,
      bookId,
      index(
        books[bookId].nftContract, 
        books[bookId].tokenId)
    );
  }

  function forceCancelBook(bytes32 bookId) public onlyRole(ADMIN_ROLE) {

    _cancelBook(bookId);
  }

  function cancelBook(bytes32 bookId) public onlySeller(bookId) {

    _cancelBook(bookId);
  }

  function bid(bytes32 bookId, uint256 price) public payable isValidBook(bookId) isBiddable(bookId) returns (bytes32) {

    require(market.isMoneyApproved(IERC20(books[bookId].erc20Contract), msg.sender, price), "Allowance or balance not enough for this bid");
    require(price >= books[bookId].priceOptions[0], "Bid amount too low.");
    require(price > booksums[bookId].topAmount, "Given offer lower than top offer.");
    
    bytes32 bidId = bidIndex(bookId, booktimes[bookId].beginTime, msg.sender);
    
    biddings[bidId].bookId = bookId;
    biddings[bidId].buyer = msg.sender;
    biddings[bidId].price = price;
    biddings[bidId].timestamp = block.timestamp;

    if(biddings[bidId].price > booksums[bookId].topAmount) {
      booksums[bookId].topAmount = biddings[bidId].price;
      booksums[bookId].topBidder = biddings[bidId].buyer;
    }

    emit Bidded(
      bookId,
      books[bookId].nftContract,
      books[bookId].tokenId,
      books[bookId].seller,
      biddings[bidId].buyer,
      biddings[bidId].price,
      biddings[bidId].timestamp,
      index(
        books[bookId].nftContract, 
        books[bookId].tokenId)
    );

    return bidId;
  }

  function endBid(bytes32 bookId) public isValidBook(bookId) {

    require(
      books[bookId].state != SellState.SOLD &&
      books[bookId].state != SellState.FAILED &&
      books[bookId].state != SellState.CANCELED, 
      "Sale ended."
    );
    require(books[bookId].method == SellMethod.SELL_TO_HIGHEST_BIDDER, "Not an auction.");
    require(block.timestamp > booktimes[bookId].endTime, "Must end after auction finish.");

    uint256 topAmount = booksums[bookId].topAmount;
    address buyer = booksums[bookId].topBidder;
    
    books[bookId].price = topAmount;
    books[bookId].buyer = buyer;
    
    if(
      buyer == address(0) ||
      topAmount < books[bookId].priceOptions[1] || // low than reserved price
      market.isMoneyApproved(IERC20(books[bookId].erc20Contract), buyer, topAmount) == false ||
      IERC20(books[bookId].erc20Contract).balanceOf(buyer) < topAmount // buy money not enough
      ) {
        
      books[bookId].state = SellState.FAILED;

      emit Failed(
        books[bookId].nftContract, 
        books[bookId].tokenId,
        books[bookId].seller, 
        books[bookId].buyer,
        books[bookId].method, 
        books[bookId].price,
        block.timestamp,
        bookId,
        index(
          books[bookId].nftContract, 
          books[bookId].tokenId)
      );
      
      return;
    }

    _deal(bookId);

    books[bookId].state = SellState.SOLD;
  }

  function buy(bytes32 bookId) public 
    isValidBook(bookId) 
    isBuyable(bookId) 
    payable {


    uint256 priceNow = priceOf(bookId);

    if(books[bookId].erc20Contract == address(0)) {

      require(msg.value >= priceNow, "Incorrect payment value.");

      if(msg.value > priceNow) {
        payable(msg.sender).transfer(msg.value - priceNow);
      }
      
      books[bookId].payableAmount = priceNow;

    }

    books[bookId].price = priceNow;
    books[bookId].buyer = msg.sender;
    booktimes[bookId].endTime = block.timestamp;

    _deal(bookId);

    books[bookId].state = SellState.SOLD;
  }

  function _deal(bytes32 bookId) private {


    market.deal{value:books[bookId].payableAmount}(
      books[bookId].erc20Contract, 
      books[bookId].nftContract, 
      books[bookId].tokenId, 
      books[bookId].seller, 
      books[bookId].buyer, 
      books[bookId].price, 
      bookshares[bookId].comission, 
      bookshares[bookId].roality, 
      RoalityHandler.roalityAccount(books[bookId].nftContract),
      bookId
    );

    emit Dealed(
      books[bookId].erc20Contract,
      books[bookId].nftContract,
      books[bookId].tokenId,
      books[bookId].seller,
      books[bookId].buyer,
      books[bookId].method,
      books[bookId].price,
      bookshares[bookId].comission,
      bookshares[bookId].roality,
      booktimes[bookId].endTime,
      bookId,
      index(
        books[bookId].nftContract, 
        books[bookId].tokenId)
    );
  }

  function alterFormula(
    uint256 _comission,
    uint256 _maxBookDuration,
    uint256 _minBookDuration
  ) public onlyRole(ADMIN_ROLE) {

    comission = _comission;
    maxBookDuration = _maxBookDuration;
    minBookDuration = _minBookDuration;
  }
}