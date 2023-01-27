
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


abstract contract ERC165 is IERC165 {
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IERC165).interfaceId;
    }
}// MIT

pragma solidity ^0.8.0;

library Math {

    function max(uint256 a, uint256 b) internal pure returns (uint256) {

        return a >= b ? a : b;
    }

    function min(uint256 a, uint256 b) internal pure returns (uint256) {

        return a < b ? a : b;
    }

    function average(uint256 a, uint256 b) internal pure returns (uint256) {

        return (a & b) + (a ^ b) / 2;
    }

    function ceilDiv(uint256 a, uint256 b) internal pure returns (uint256) {

        return a / b + (a % b == 0 ? 0 : 1);
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


contract ERC1155Receiver is IERC1155Receiver, ERC165  {

    
    event ERC1155Received(
        address operator,
        address from,
        uint256 id,
        uint256 value,
        bytes data
    );

    event ERC1155BatchReceived(
        address operator,
        address from,
        uint256[] ids,
        uint256[] values,
        bytes data
    );

    function onERC1155Received(
        address operator,
        address from,
        uint256 id,
        uint256 value,
        bytes calldata data
    ) external override returns (bytes4){

        emit ERC1155Received(operator, from, id, value, data);
        return bytes4(keccak256("onERC1155Received(address,address,uint256,uint256,bytes)"));
    }

    function onERC1155BatchReceived(
        address operator,
        address from,
        uint256[] calldata ids,
        uint256[] calldata values,
        bytes calldata data
    ) external override returns (bytes4){

        emit ERC1155BatchReceived(operator, from, ids, values, data);
        return bytes4(keccak256("onERC1155BatchReceived(address,address,uint256[],uint256[],bytes)"));
    }


}// MIT
pragma solidity >=0.7.5 <0.9.0;
pragma abicoder v2;


interface IERC2981 is IERC165 {

    function royaltyInfo(
        uint256 _tokenId,
        uint256 _salePrice
    ) external view returns (
        address receiver,
        uint256 royaltyAmount
    );

}

contract NAMarketV4 is Ownable, ReentrancyGuard, ERC1155Receiver {

  bytes4 private constant _INTERFACE_ID_ERC2981 = 0x2a55205a;
  using SafeMath for uint256;
  using Math for uint256;
  using Counters for Counters.Counter;
  Counters.Counter public totalAuctionCount;
  Counters.Counter private closedAuctionCount;

  enum TokenType { NONE, ERC721, ERC1155 }
  enum AuctionStatus { NONE, OPEN, CLOSE, SETTLED, CANCELED }
  enum Sort { ASC, DESC, NEW, END, HOT }
  enum BidType { BID, CANCELED }
  
  struct Auction {
      address contractAddress;
      uint256 tokenId;
      uint256 currentPrice;
      uint256 buyNowPrice;
      address seller;
      address highestBidder;
      address ERC20Token;
      string auctionTitle;
      uint256 expiryDate;
      uint256 auctionId;
      AuctionType auctionTypes;
  }

  struct AuctionType {
      uint256 category;
      AuctionStatus status;
      TokenType tokenType;
      uint256 quantity;
  }
  struct previousInfo {
    uint256 previousPrice;
  }
  struct Bid {
        uint256 bidId;
        address bidder;
        uint256 price;
        BidType Type;
        uint256 timestamp;
  }
  struct SellerSale {
    address seller;
    uint256 price;
    uint256 timestamp;
  }

  address public adminAddress; 

  uint256 public minAuctionLiveness = 10 * 60;
    
  uint256 public gasSize = 100000;
  address public feeAddress;
  uint256 public feePercentage = 250; // default fee percentage : 2.5%
  uint256 public createAuctionFee = 1000000000000000;// default 0.001

  uint256 public totalMarketVolume;
  uint256 public totalSales;
  bool public marketStatus = true;

  mapping(address => uint256) public userPriceList;
  mapping(address => mapping(address => uint256)) public userERC20PriceList;
  mapping (address => SellerSale[]) private sellerSales;
  mapping(uint256 => previousInfo) private previousPriceList;
  mapping(uint256 => Auction) public auctions;
  mapping (uint256 => Bid[]) private bidList;
  address[] private uniqSellerList;// Unique seller address
  mapping(address => bool) public blackList;
  uint256[] private recommendAuctionIds;
  
  event AuctionCreated(
      uint256 auctionId,
      address contractAddress,
      uint256 tokenId,
      uint256 startingPrice,
      address seller,
      uint256 expiryDate
  );
  event NFTApproved(address nftContract);
  event AuctionCanceled(uint256 auctionId);
  event AuctionSettled(uint256 auctionId, bool sold);
  event BidPlaced(uint256 auctionId, uint256 bidPrice);
  event BidFailed(uint256 auctionId, uint256 bidPrice);
  event UserCredited(address creditAddress, uint256 amount);
  event priceBid(uint256 auctionId, uint256 bidPrice);
  event AdminAuctionCancel(uint256 auctionId, bool feeApproved);
  event CancelBid(uint256 auctionId);
  event RoyaltiesPaid(uint256 tokenId, uint value);


  modifier onlyAdmin() {

        require(msg.sender == adminAddress, "admin: wut?");
        _;
  }
  
  modifier checkBlackList() {

    if (blackList[msg.sender] == true) {
      require(false, "Blacklist wallet address.");
    }
    _;
  }

  modifier openAuction(uint256 auctionId) {

      require(auctions[auctionId].auctionTypes.status == AuctionStatus.OPEN, "Transaction only open Auctions");
        _;
  }

  modifier settleStatusCheck(uint256 auctionId) {

    AuctionStatus auctionStatus = auctions[auctionId].auctionTypes.status;
      require( auctionStatus != AuctionStatus.SETTLED || 
        auctionStatus != AuctionStatus.CANCELED, "Transaction only open or close Auctions");

      if (auctionStatus == AuctionStatus.OPEN) {
        require(auctions[auctionId].expiryDate < block.timestamp, "Transaction only valid for expired Auctions");
      }
    _;
  }

  modifier nonExpiredAuction(uint256 auctionId) {

      require(auctions[auctionId].expiryDate >= block.timestamp, "Transaction not valid for expired Auctions");
        _;
  }

  modifier onlyExpiredAuction(uint256 auctionId) {

      require(auctions[auctionId].expiryDate < block.timestamp, "Transaction only valid for expired Auctions");
        _;
  }

  modifier noBids(uint256 auctionId) {

      require(auctions[auctionId].highestBidder == address(0), "Auction has bids already");
        _;
  }

  modifier sellerOnly(uint256 auctionId) {

      require(msg.sender == auctions[auctionId].seller, "Caller is not Seller");
        _;
  }

  modifier marketStatusCheck() {

      require(marketStatus, "Market is closed");
        _;
  }

  function setMarkStatus(bool _marketStatus) public onlyOwner {

        marketStatus = _marketStatus;
  }
  
  function setFeeAddress(address _feeAddress) public onlyOwner {

        require(_feeAddress != address(0), "Invalid Address");
        feeAddress = _feeAddress;
  }
  function setAdmin(address _adminAddress) public onlyOwner {

        adminAddress = _adminAddress;
  }
  function setGasSize(uint256 _gasSize) public onlyAdmin {

        gasSize = _gasSize;
  }

  function setBlackList(address blackAddress, bool approved) public onlyAdmin {

    blackList[blackAddress] = approved;
  }
  function setRecommendAuctionId(uint256 auctionId, bool approved) public onlyAdmin {

    if (approved) {
      recommendAuctionIds.push(auctionId);
    } else {
      for (uint256 i = 0; i < recommendAuctionIds.length ; i++) {
        if (recommendAuctionIds[i] == auctionId) {
          for (uint j = i; j < recommendAuctionIds.length - 1; j++) {
            recommendAuctionIds[j] = recommendAuctionIds[j + 1];
          }
          recommendAuctionIds.pop();
        }
      }
    }
  }
  function setMinAuctionLiveness(uint256 _minAuctionLiveness) public onlyAdmin {

        minAuctionLiveness = _minAuctionLiveness;
  }
  function setFeePercentage(uint256 _feePercentage) public onlyAdmin {

        require(_feePercentage <= 10000, "Fee percentages exceed max");
        feePercentage = _feePercentage;
  }
  function setCreateAuctionFee(uint256 _createAuctionFee) public onlyAdmin {

        createAuctionFee = (_createAuctionFee.mul(10**18)).div(1000);
  }

  function calculateFee(uint256 _cuPrice) private view returns(uint256 fee){

      fee  = _cuPrice.mul(feePercentage).div(10000);
  }



  function createAuction(address _contractAddress, uint256 _tokenId, uint256 _startingPrice, string memory auctionTitle,
    uint256 _buyNowPrice, uint256 expiryDate, uint256 _category, TokenType _tokenType, address ERC20Token,
    uint256 _quantity
    ) public payable marketStatusCheck() checkBlackList() nonReentrant 
    returns(uint256 auctionId){

      require(msg.value == createAuctionFee, "The fee amount is different.");
      require(expiryDate.sub(minAuctionLiveness) > block.timestamp, "Expiry date is not far enough in the future");
      require(_tokenType != TokenType.NONE, "Invalid token type provided");
      require(_buyNowPrice > _startingPrice, "Invalid _buyNowPrice");

      uint256 quantity = 1;
      if(_tokenType == TokenType.ERC1155){
        quantity = _quantity;
      }
      totalAuctionCount.increment();
      auctionId = totalAuctionCount.current();
      auctions[auctionId] = Auction(_contractAddress, _tokenId, _startingPrice, _buyNowPrice, msg.sender,
       address(0), ERC20Token, auctionTitle, expiryDate, auctionId, 
       AuctionType(_category,AuctionStatus.OPEN,  _tokenType, quantity));
      transferToken(auctionId, msg.sender, address(this));
      emit AuctionCreated(auctionId, _contractAddress, _tokenId, _startingPrice, msg.sender, expiryDate);
  }

  function updateAuction(uint256 auctionId, string memory auctionTitle, uint256 expiryDate,
    uint256 category, TokenType tokenType, AuctionStatus status,
    uint256 quantity) public onlyAdmin  nonReentrant{

    Auction storage auction = auctions[auctionId];
    auction.auctionTitle = auctionTitle;
    auction.expiryDate = expiryDate;
    auction.auctionTypes.category = category;
    auction.auctionTypes.tokenType = tokenType;
    auction.auctionTypes.status = status;
    auction.auctionTypes.quantity = quantity;
  }

  function cancelAuction(uint256 auctionId) public openAuction(auctionId) noBids(auctionId) sellerOnly(auctionId) nonReentrant{

      auctions[auctionId].auctionTypes.status = AuctionStatus.CANCELED;
      closedAuctionCount.increment();
      transferToken(auctionId, address(this), msg.sender);
      emit AuctionCanceled(auctionId);
  }

  function settleAuction(uint256 auctionId) public settleStatusCheck(auctionId) nonReentrant{

      Auction storage auction = auctions[auctionId];
      auction.auctionTypes.status = AuctionStatus.SETTLED;
      closedAuctionCount.increment();
      
      bool sold = auction.highestBidder != address(0);
      if(sold){
        transferToken(auctionId, address(this), auction.highestBidder);
        uint256 cuPrice = 0;
		    if (_checkRoyalties(auction.contractAddress)) {
            (address royaltiesReceiver, uint256 royaltiesAmount) = IERC2981(auction.contractAddress).royaltyInfo(auction.tokenId, auction.currentPrice);
            if (auction.seller != royaltiesReceiver) {
			        cuPrice = auction.currentPrice - royaltiesAmount;
            } else {
              cuPrice = auction.currentPrice;
            }
            if (royaltiesAmount > 0) {
                if (_isERC20Auction(auction.ERC20Token)) {
                    creditUserToken(royaltiesReceiver, auction.ERC20Token, royaltiesAmount);
                } else {
                    creditUser(royaltiesReceiver, royaltiesAmount);
                }
            } 
            emit RoyaltiesPaid(auction.tokenId, royaltiesAmount);
        }
        if (_isERC20Auction(auction.ERC20Token)) {
          creditUserToken(auction.seller, auction.ERC20Token, cuPrice);
          creditUserToken(feeAddress, auction.ERC20Token, calculateFee(auction.currentPrice));
        } else {
          creditUser(auction.seller, cuPrice); 
          creditUser(feeAddress, calculateFee(auction.currentPrice));
        }

        saveSales(auction.seller, auction.currentPrice);
        totalSales = totalSales.add(auction.currentPrice);
      } else {
        transferToken(auctionId, address(this), auction.seller);
      }
      emit AuctionSettled(auctionId, sold);
  }
  function saveSales(address sellerAddress, uint256 price) private {

    if (uniqSellerList.length == 0) {
      uniqSellerList.push(sellerAddress);
    } else {
      bool chkSeller = false;
      for (uint256 i = 0; i < uniqSellerList.length; i++) {
        if (uniqSellerList[i] == sellerAddress) {
          chkSeller = true;
        }
      }
      if (!chkSeller) {
        uniqSellerList.push(sellerAddress);
      }
    }
    SellerSale memory sellerInfo = SellerSale(sellerAddress, price, block.timestamp);
    sellerSales[sellerAddress].push(sellerInfo);
  }

	function _checkRoyalties(address _contract) internal view returns (bool) {

        (bool success) = IERC165(_contract).supportsInterface(_INTERFACE_ID_ERC2981);
		return success;
    }

  function creditUser(address creditAddress, uint256 amount) private {

      userPriceList[creditAddress] = userPriceList[creditAddress].add(amount);
      emit UserCredited(creditAddress, amount);
  }
  function creditUserToken(address creditAddress, address tokenAddress, uint256 amount) private {

      userERC20PriceList[creditAddress][tokenAddress] = userERC20PriceList[creditAddress][tokenAddress].add(amount);
      emit UserCredited(creditAddress, amount);
  }

  function withdrawCredit() public nonReentrant{

      uint256 creditBalance = userPriceList[msg.sender];
      require(creditBalance > 0, "User has no credits to withdraw");
      userPriceList[msg.sender] = 0;

      (bool success, ) = msg.sender.call{value: creditBalance}("");
      require(success);
  }

  function withdrawToken(address tokenAddress) public nonReentrant{

    uint256 creditBalance = userERC20PriceList[msg.sender][tokenAddress];
    require(creditBalance > 0, "User has no credits to withdraw");
    userERC20PriceList[msg.sender][tokenAddress] = 0;

    IERC20(tokenAddress).transfer(msg.sender, creditBalance);
  }

  function placeBid(uint256 auctionId, uint256 bidPrice) public payable openAuction(auctionId) nonExpiredAuction(auctionId) nonReentrant{

      Auction storage auction = auctions[auctionId];
      require(bidPrice > auction.currentPrice, "It should be higher than the current bid amount");

      if (_isERC20Auction(auction.ERC20Token)) {
        require(msg.value == 0, "msg.value must be zero.");
        _payout(auction.ERC20Token, msg.sender, bidPrice);
      } else {
        require(msg.value == bidPrice.add(calculateFee(bidPrice)), "The payment amount and the bid amount are different");
      }

      emit priceBid(auctionId, bidPrice);

      uint256 creditAmount;
      address previousBidder = auction.highestBidder;
    
      if (auction.buyNowPrice <= bidPrice) {
        if (auction.auctionTypes.tokenType == TokenType.ERC721) {
          auction.auctionTypes.status = AuctionStatus.CLOSE;
        } else if (auction.auctionTypes.tokenType == TokenType.ERC1155){
          if (auction.auctionTypes.quantity == 0) {
            auction.auctionTypes.status = AuctionStatus.CLOSE;
          } else {
            auction.auctionTypes.quantity--;
          }
        }
      }

      uint256 newBidId = bidList[auctionId].length + 1;
      Bid memory newBid = Bid(newBidId, msg.sender, bidPrice, BidType.BID, block.timestamp);
      bidList[auctionId].push(newBid);

      if(previousBidder != address(0)){
        creditAmount = previousPriceList[auctionId].previousPrice;
        if (_isERC20Auction(auction.ERC20Token)) {
          creditUserToken(previousBidder, auction.ERC20Token, creditAmount);
        } else {
          creditUser(previousBidder, creditAmount);
        }
      }
    
      previousPriceList[auctionId].previousPrice = bidPrice.add(calculateFee(bidPrice));

      auction.highestBidder = msg.sender;
      auction.currentPrice = bidPrice;

  }

  function _payout(
        address ERC20Token,
        address bidder,
        uint256 bidPrice
    ) internal {

        uint256 newBidPrice = bidPrice.add(calculateFee(bidPrice));
            bool sent = IERC20(ERC20Token).transferFrom(bidder, address(this), newBidPrice);
            require(sent, "transfer fail");
  }

    function _isERC20Auction(address _auctionERC20Token)
        internal
        pure
        returns (bool)
    {

        return _auctionERC20Token != address(0);
    }

  function transferToken(uint256 auctionId, address from, address to) private {

      require(to != address(0), "Cannot transfer token to zero address");

      Auction storage auction = auctions[auctionId];
      require(auction.auctionTypes.status != AuctionStatus.NONE, "Cannot transfer token of non existent auction");

      TokenType tokenType = auction.auctionTypes.tokenType;
      uint256 tokenId = auction.tokenId;
      address contractAddress = auction.contractAddress;

      if(tokenType == TokenType.ERC721){
        IERC721(contractAddress).transferFrom(from, to, tokenId);
      }
      else if(tokenType == TokenType.ERC1155){
        uint256 quantity = auction.auctionTypes.quantity;
        require(quantity > 0, "Cannot transfer 0 quantity of ERC1155 tokens");
        IERC1155(contractAddress).safeTransferFrom(from, to, tokenId, quantity, "");
      }
      else{
        revert("Invalid token type for transfer");
      }
  }
  function adminCancelAuction(uint256 auctionId, bool feeApproved) public openAuction(auctionId) onlyAdmin  nonReentrant{

    Auction storage auction = auctions[auctionId];
    address previousBidder = auction.highestBidder;
    uint256 creditAmount = 0;
    if(previousBidder != address(0)){
      if (feeApproved) {
        creditAmount = auction.currentPrice; //only price, Cancellation fee.
      } else {
        creditAmount = previousPriceList[auctionId].previousPrice; //fee+ price
      }
      if (_isERC20Auction(auction.ERC20Token)) {
          creditUserToken(previousBidder, auction.ERC20Token, creditAmount);
      } else {
        creditUser(previousBidder, creditAmount);
      }
    }
    auction.auctionTypes.status = AuctionStatus.CANCELED;
  
    emit AdminAuctionCancel(auctionId, feeApproved);
  }
  function cancelBid(uint256 auctionId) public openAuction(auctionId) nonExpiredAuction(auctionId) nonReentrant {

    Auction storage auction = auctions[auctionId];
    require(msg.sender == auction.highestBidder, "Invalid Request");
    address previousBidder = auction.highestBidder;
    uint256 creditAmount = 0;
    if(previousBidder != address(0)){
      creditAmount = auction.currentPrice; //only price, Cancellation fee.
      if (_isERC20Auction(auction.ERC20Token)) {
          creditUserToken(previousBidder, auction.ERC20Token, creditAmount);
      } else {
        creditUser(previousBidder, creditAmount);
      }
    }
    uint256 newBidId = bidList[auctionId].length + 1;
    Bid memory newBid = Bid(newBidId, msg.sender, auction.currentPrice, BidType.BID, block.timestamp);
    bidList[auctionId].push(newBid);
    
    auction.highestBidder = address(0);
    previousPriceList[auctionId].previousPrice = 0;
  
    emit CancelBid(auctionId);
  }


  function getOpenAuctions(uint256 category, Sort sort, string memory keyword, 
  uint256 offset, uint256 limit) public view returns 
  (Auction[] memory, uint256, uint256) {

        uint256 totalLen = totalAuctionCount.current();
        Auction[] memory values = new Auction[] (totalLen);
        uint256 resultLen = 0;
        bytes memory checkString = bytes(keyword);

        for (uint256 i = 1; i <= totalLen; i++) {
          if(auctions[i].auctionTypes.status == AuctionStatus.OPEN){
            values[resultLen] = auctions[i];
            resultLen++;
          }  
        }
        resultLen = 0;
        if (checkString.length > 0) {
          values = sfilter(values, category, keyword);
        } else if (category != 0) {
          values = cfilter(values, category);
        }

        for (uint256 i = 0; i < values.length; i++) {
          if(values[i].seller != address(0)){
            resultLen++;
          }  
        }

        Auction[] memory result = new Auction[](resultLen);
        uint256 rId = 0;
        for (uint256 i = 0; i < values.length; i++) {
          if(values[i].seller != address(0)){
            result[rId] = values[i];
            rId++;
          }  
        }
        result = sortMap(result, resultLen, sort);


        if(limit == 0) {
            limit = 1;
        }
        
        if (limit > resultLen - offset) {
            limit = 0 > resultLen - offset ? 0 : resultLen - offset;
        }
       
        Auction[] memory newAuctions = new Auction[] (result.length > limit ? limit: result.length);

        if (result.length > limit) {
          for (uint256 i = 0; i < limit; i++) {
            newAuctions[i] = result[offset+i];
          }
          return (newAuctions, offset + limit, resultLen);
        } else {
          return (result, offset + limit, resultLen);
        }
        
  }

  function getSellerAuctions(address sellerAddress, Sort sort, uint256 offset, uint256 limit) public view returns 
  (Auction[] memory, uint256, uint256) {

        uint256 totalLen = totalAuctionCount.current();
        Auction[] memory values = new Auction[] (totalLen);
        uint256 resultLen = 0;

        for (uint256 i = 1; i <= totalLen; i++) {
          if(auctions[i].auctionTypes.status == AuctionStatus.OPEN
            && auctions[i].seller == sellerAddress){
            values[resultLen] = auctions[i];
            resultLen++;
          }  
        }

        values = sortMap(values, resultLen, sort);

        if(limit == 0) {
            limit = 1;
        }
        
        if (limit > resultLen - offset) {
            limit = 0 > resultLen - offset ? 0 : resultLen - offset;
        }
       
        Auction[] memory newAuctions = new Auction[] (resultLen > limit ? limit: resultLen);

        if (resultLen > limit) {
          for (uint256 i = 0; i < limit; i++) {
            newAuctions[i] = values[offset+i];
          }
          return (newAuctions, offset + limit, resultLen);
        } else {
          return (values, offset + limit, resultLen);
        }
        
  }
 
  function getRecommendationAuctions() public view returns (Auction[] memory, uint256) {

    uint256 totalLen = recommendAuctionIds.length;
    Auction[] memory values = new Auction[] (totalLen);
    uint256 resultLen = 0;

    for (uint256 i = 0; i < totalLen; i++) {
      if(auctions[recommendAuctionIds[i]].auctionTypes.status == AuctionStatus.OPEN) {
        values[resultLen] = auctions[i];
        resultLen++;
      }  
    }
    return (values, resultLen);
  }
  function getBids(uint256 auctionId) public view returns(Bid[] memory){

      return bidList[auctionId];
  }

  function getUserAuctions(address seller) public view returns(Auction[] memory) {

    uint256 resultCount = 0;

    for(uint256 i = 1; i <= totalAuctionCount.current(); i++) {
      if (auctions[i].seller == seller) {
        resultCount++;
      }
    }
    Auction[] memory values = new Auction[] (resultCount);
    uint256 rInt = 0;
    for(uint256 i = 1; i <= totalAuctionCount.current(); i++) {
      if (auctions[i].seller == seller) {
        values[rInt] = auctions[i];
        rInt++;
      }
    }
    return values;
  }
  function getUserBidAuctions(address seller) public view returns(Auction[] memory) {

    uint256 resultCount = 0;

    for(uint256 i = 1; i <= totalAuctionCount.current(); i++) {
      if (auctions[i].highestBidder == seller) {
        resultCount++;
      }
    }
    Auction[] memory values = new Auction[] (resultCount);
    uint256 rInt = 0;
    for(uint256 i = 1; i <= totalAuctionCount.current(); i++) {
      if (auctions[i].highestBidder == seller) {
        values[rInt] = auctions[i];
        rInt++;
      }
    }
    return values;
  }
  function getSellerSalesList(uint256 timestamp) public view returns(SellerSale[] memory) {

    SellerSale[] memory topSellerList = new SellerSale[](uniqSellerList.length);
    SellerSale memory cuSellerSales;
    for(uint256 i = 0; i < uniqSellerList.length; i++) {
      cuSellerSales.seller = uniqSellerList[i];
      cuSellerSales.price = 0;
      cuSellerSales.timestamp = timestamp;
      for(uint256 j = 0; j < sellerSales[uniqSellerList[i]].length; j++) {
        if (timestamp <= sellerSales[uniqSellerList[i]][j].timestamp) {
          cuSellerSales.price = cuSellerSales.price.add(sellerSales[uniqSellerList[i]][j].price);
        }
      }
      topSellerList[i] = cuSellerSales;
    }
    return topSellerList;
  }
  function substring(string memory str, uint256 startIndex, uint256 endIndex) private pure returns (string memory) {

        bytes memory strBytes = bytes(str);
        bytes memory result = new bytes(endIndex-startIndex);
        for(uint256 i = startIndex; i < endIndex; i++) {
            result[i-startIndex] = strBytes[i];
        }
        return string(result);
  }

  function sfilter(Auction[] memory values, uint256 category, string memory keyword) 
    private pure returns (Auction[] memory) {

    Auction[] memory sValues = new Auction[](values.length);

    bytes memory kBytes = bytes(keyword);
    for (uint256 i = 0; i < values.length; i ++) {
      bytes memory tBytes = bytes(values[i].auctionTitle);
      for (uint256 j = 0; j < tBytes.length; j ++) {

          if(keccak256(abi.encodePacked(substring(values[i].auctionTitle, j, 
          tBytes.length < j+kBytes.length ? tBytes.length : j+kBytes.length))) 
            == keccak256(abi.encodePacked(keyword))) {
              sValues[i] = values[i];
              break;
          }
      }
    }
    sValues = cfilter(sValues, category);
    return sValues;

  }

  function cfilter(Auction[] memory values, uint256 category) private pure returns (Auction[] memory) {

    Auction[] memory cValues = new Auction[](values.length);
    if (category != 0) {
      for (uint256 i = 0; i < values.length; i++) {
        if(values[i].auctionTypes.category == category){
          cValues[i] = values[i];
        } 
      }
      return cValues;
    } else {
      return values;
    }
  }

  function sortMap(Auction[] memory arr, uint256 limit, Sort sort) private view returns (Auction[] memory) {

    Auction memory temp;
    for(uint256 i = 0; i < limit; i++) {
        for(uint256 j = i+1; j < limit ;j++) {
          if (sort == Sort.NEW) {
            if(arr[i].expiryDate > arr[j].expiryDate) {
                temp = arr[i];
                arr[i] = arr[j];
                arr[j] = temp;
            }
          } else if (sort == Sort.END) {
            if(arr[i].expiryDate < arr[j].expiryDate) {
                temp = arr[i];
                arr[i] = arr[j];
                arr[j] = temp;
            }
          } else if (sort == Sort.ASC) {
            if(arr[i].currentPrice > arr[j].currentPrice) {
                temp = arr[i];
                arr[i] = arr[j];
                arr[j] = temp;
            }
          } else if (sort == Sort.HOT) {
            if( bidList[arr[i].auctionId].length < bidList[arr[j].auctionId].length) {
                temp = arr[i];
                arr[i] = arr[j];
                arr[j] = temp;
            }
          } else {
            if(arr[i].currentPrice < arr[j].currentPrice) {
                temp = arr[i];
                arr[i] = arr[j];
                arr[j] = temp;
            }
          } 
        }
    }
    return arr;
  }

}