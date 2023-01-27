
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

}//*~~~> MIT
pragma solidity 0.8.7;

interface IOffers {

  function fetchOfferId(uint marketId) external returns(uint);

  function refundOffer(uint itemID, uint offerId) external returns (bool);

}
interface ITrades {

  function fetchTradeId(uint marketId) external returns(uint);

  function refundTrade(uint itemId, uint tradeId) external returns (bool);

}
interface IBids {

  function fetchBidId(uint marketId) external returns(uint);

  function refundBid(uint bidId) external returns (bool);

}//*~~~> MIT
pragma solidity 0.8.7;

interface INFTMarket { 

    function transferNftForSale(address receiver, uint itemId) external returns(bool);

}//*~~~> MIT
pragma solidity 0.8.7;

interface IRoleProvider {

  function hasTheRole(bytes32 role, address theaddress) external returns(bool);

  function fetchAddress(bytes32 thevar) external returns(address);

  function hasContractRole(address theaddress) external view returns(bool);

}//*~~~> MIT
pragma solidity 0.8.7;

interface IRewardsController {

  function createNftHodler(uint tokenId) external returns (bool);

  function depositERC20Rewards(uint amount, address tokenAddress) external returns(bool);

  function getFee() external view returns(uint);

  function setFee(uint fee) external returns (bool);

  function depositEthRewards(uint reward) external payable returns(bool);

  function createUser(address userAddress) external returns(bool);

  function setUser(bool canClaim, address userAddress) external returns(bool);

}//*~~~> MIT make it better, stronger, faster




pragma solidity 0.8.7;


interface IERC721 {

  function ownerOf(uint tokenId) external view returns(address);

  function balanceOf(address owner) external view returns(uint);

}

contract MarketBids is ReentrancyGuard {


  uint public bidMin;
  uint private bidIds;
  uint private blindBidIds;
  uint[] private openStorage;
  uint[] private blindOpenStorage;
  address public roleAdd;

  bytes32 public constant MARKET = keccak256("MARKET");
  bytes32 public constant NFT = keccak256("NFT");
  bytes32 public constant REWARDS = keccak256("REWARDS");
  bytes32 public constant OFFERS = keccak256("OFFERS");
  bytes32 public constant TRADES = keccak256("TRADES");

  bytes32 public constant PROXY_ROLE = keccak256("PROXY_ROLE");
  bytes32 public constant DEV = keccak256("DEV");

  modifier hasAdmin(){

    require(IRoleProvider(roleAdd).hasTheRole(PROXY_ROLE, msg.sender), "DOES NOT HAVE ADMIN ROLE");
    _;
  }
  modifier hasContractAdmin(){

    require(IRoleProvider(roleAdd).hasContractRole(msg.sender), "DOES NOT HAVE CONTRACT ROLE");
    _;
  }
  modifier hasDevAdmin(){

    require(IRoleProvider(roleAdd).hasTheRole(DEV, msg.sender), "DOES NOT HAVE DEV ROLE");
    _;
  }
  
  constructor(address role) {
    bidMin = 1e15;
    roleAdd = role;
  }

  struct Bid {
    uint itemId;
    uint tokenId;
    uint bidId;
    uint bidValue;
    uint timestamp;
    address payable bidder;
    address payable seller;
  }

  struct BlindBid {
    bool specific;
    uint tokenId;
    uint bidId;
    uint bidValue;
    uint amount1155;
    address payable collectionBid;
    address payable bidder;
  }

  mapping (uint256 => Bid) private idToNftBid;

  mapping (uint256 => uint256) private mktIdToBidId;

  mapping (uint256 => BlindBid) private idToBlindBid;

  event BidEntered(
    uint tokenId,
    uint itemId,
    uint bidId,
    uint bidValue, 
    address indexed bidder,
    address indexed seller
    );

  event BlindBidentered (
    bool isSpecified,
    uint indexed tokenId,
    uint blindBidId,
    uint bidValue,
    uint amount1155,
    address indexed collectionBid,
    address indexed bidder
  );

  event BlindBidAccepted(
    uint indexed tokenId,
    uint blindBidId,
    uint bidValue,
    address indexed bidder,
    address indexed seller
  );

  event BidAccepted(
    uint indexed tokenId,
    uint bidId,
    uint bidValue,
    address indexed bidder,
    address indexed seller
  );

  event BidWithdrawn(
    uint256 indexed tokenId, 
    uint indexed bidId,
    address indexed bidder
    );

  event BlindBidWithdrawn(
    uint indexed blindBidId,
    address indexed bidder
    );

  event BidRefunded(
    uint indexed tokenId,
    uint indexed bidId,
    address indexed bidder
  );

  function setBidMinimum(uint minWei) external hasDevAdmin returns(bool){

    bidMin = minWei;
    return true;
  }

  function enterBidForNft(
    uint[] memory tokenId,
    uint[] memory itemId,
    uint[] memory bidValue,
    address[] memory seller
  ) external payable returns(bool){

    uint total;
    for (uint i=0;i < tokenId.length;i++){
      total += bidValue[i];
      require(bidValue[i] > bidMin, "Must be greater than min. bid.");
      uint id = mktIdToBidId[itemId[i]];
      if (id > 0) {
        Bid memory existing = idToNftBid[id];
        if (bidValue[i] <= existing.bidValue) revert();
        if (existing.bidValue < bidValue[i]) {
          require(sendEther(existing.bidder, existing.bidValue));
        }
      }
      uint bidId;
      uint len = openStorage.length;
      if (len>=1){
        bidId = openStorage[len-1];
        removeId(0);
      } else {
        bidId = bidIds+=1;
      }
      idToNftBid[bidId] = Bid(itemId[i], tokenId[i], bidId, bidValue[i], block.timestamp, payable(msg.sender), payable(seller[i]));

      emit BidEntered(
        tokenId[i],
        itemId[i],
        bidId,
        bidValue[i],
        msg.sender, 
        seller[i]);
    }
    require(total == msg.value);
    return true;
  }

  function enterBlindBid(
    bool[] memory isSpecific, 
    uint[] memory value, 
    uint[] memory tokenId, 
    uint[] memory amount1155, 
    address[] memory bidAddress) external payable nonReentrant returns(bool){

    
    uint total;
    for (uint i=0;i<bidAddress.length;i++){
      total += value[i];
      require(value[i] > bidMin, "Must be greater than min. bid.");
      uint bidId;
      uint len = blindOpenStorage.length;
      if (len>=1){
        bidId=blindOpenStorage[len-1];
        removeId(1);
      } else {
        bidId = blindBidIds+=1;
      }
      idToBlindBid[bidId] = BlindBid(isSpecific[i], tokenId[i], bidId, value[i], amount1155[i], payable(bidAddress[i]), payable(msg.sender));

      emit BlindBidentered(
        isSpecific[i],
        tokenId[i],
        bidId,
        value[i],
        amount1155[i],
        bidAddress[i],
        msg.sender
      );
    }
    require(msg.value == total);
    return true;
  }

  function acceptBlindBid(
    uint[] memory blindBidId, 
    uint[] memory tokenId,
    uint[] memory listedId, 
    bool[] memory is1155) external nonReentrant returns(bool){

    
    address rewardsAdd = IRoleProvider(roleAdd).fetchAddress(REWARDS);
    address marketAdd = IRoleProvider(roleAdd).fetchAddress(MARKET);
    uint balance = IERC721(marketAdd).balanceOf(msg.sender);

    for (uint i=0; i<blindBidId.length; i++){
      BlindBid memory bid = idToBlindBid[blindBidId[i]];
      if(bid.specific){
          require(tokenId[i]==bid.tokenId,"Wrong item!");
        }
        if(balance<1){
          uint256 saleFee = calcFee(bid.bidValue);
          uint256 userAmnt = (bid.bidValue - saleFee);
          require(sendEther(rewardsAdd, saleFee));
          require(sendEther(msg.sender, userAmnt));
        } else {
          require(sendEther(msg.sender, bid.bidValue));
        }
        if (!is1155[i]){
        require(IERC721(bid.collectionBid).ownerOf(tokenId[i]) == msg.sender, "Not the token owner!");
        if(listedId[i]>0){
            require(INFTMarket(marketAdd).transferNftForSale(bid.bidder, listedId[i]));
          } else {
            require(transferFromERC721(bid.collectionBid, tokenId[i], bid.bidder));
          }
      } else {
        uint bal = IERC1155(bid.collectionBid).balanceOf(msg.sender, tokenId[i]);
        require( bal> 0, "Not the token owner!");
        if(listedId[i]==0){
          IERC1155(bid.collectionBid).safeTransferFrom(address(msg.sender), bid.bidder, tokenId[i], bid.amount1155, "");
        } else {
          require(INFTMarket(marketAdd).transferNftForSale(bid.bidder, listedId[i]));
        }
      }
      blindOpenStorage.push(blindBidId[i]);
      idToBlindBid[blindBidId[i]] = BlindBid(false, 0, blindBidId[i], 0, 0, payable(0x0), payable(0x0));
      emit BlindBidAccepted(tokenId[i], blindBidId[i], bid.bidValue, bid.bidder, msg.sender);
    }
    return true;
  }
  
  function acceptBidForNft(
      uint[] memory bidId
  ) external nonReentrant returns (bool) {

    address marketNft = IRoleProvider(roleAdd).fetchAddress(NFT);
    address marketAdd = IRoleProvider(roleAdd).fetchAddress(MARKET);
    address offersAdd = IRoleProvider(roleAdd).fetchAddress(OFFERS);
    address tradesAdd = IRoleProvider(roleAdd).fetchAddress(TRADES);
    address rewardsAdd = IRoleProvider(roleAdd).fetchAddress(REWARDS);

    uint balance = IERC721(marketNft).balanceOf(msg.sender);
    for (uint i=0; i<bidId.length; i++){
      Bid memory bid = idToNftBid[bidId[i]];
      require(msg.sender == bid.seller);
      if(balance<1) {
          uint256 saleFee = calcFee(bid.bidValue);
          uint256 userAmnt = (bid.bidValue - saleFee);
          require(sendEther(rewardsAdd, saleFee));
          require(sendEther(bid.seller, userAmnt));
      } else {
        require(sendEther(bid.seller, bid.bidValue));
      }
      uint offerId = IOffers(offersAdd).fetchOfferId(bid.itemId);
      if (offerId > 0) {
        require(IOffers(offersAdd).refundOffer(bid.itemId, offerId));
      }
      uint tradeId = ITrades(tradesAdd).fetchTradeId(bid.itemId);
      if (tradeId > 0) {
        require(ITrades(tradesAdd).refundTrade(bid.itemId, tradeId));
      }
      require(INFTMarket(marketAdd).transferNftForSale(address(bid.bidder), bid.itemId));

      openStorage.push(bidId[i]);
      idToNftBid[bidId[i]] = Bid(0, 0, 0, 0, 0, payable(address(0x0)), payable(address(0x0)));
      
      emit BidAccepted(bid.itemId, bidId[i], bid.bidValue, bid.bidder, bid.seller);
    }
  return true;
  }

  function withdrawBid(uint[] memory bidId, bool[] memory isBlind) external nonReentrant returns(bool){

    for (uint i=0;i<bidId.length;i++){
      if (isBlind[i]){
        BlindBid memory bid = idToBlindBid[bidId[i]];
        if (bid.bidder != msg.sender) revert();
        require(sendEther(bid.bidder, bid.bidValue));
        blindOpenStorage.push(bidId[i]);
        idToBlindBid[bidId[i]] = BlindBid(false, 0, 0, 0, 0, payable(address(0x0)), payable(address(0x0)));
        emit BlindBidWithdrawn(bidId[i], msg.sender);
      } else {
        Bid memory bid = idToNftBid[bidId[i]];
        require(bid.timestamp < block.timestamp - 1 days);
        if (bid.bidder != msg.sender) revert();
        require(sendEther(bid.bidder, bid.bidValue));
        openStorage.push(bidId[i]);
        idToNftBid[bidId[i]] = Bid(0, 0, 0, 0, 0, payable(address(0x0)), payable(address(0x0)));
        emit BidWithdrawn(bid.tokenId, bidId[i], msg.sender);
      }
    }
    return true;
  }

  function refundBid(uint bidId) external nonReentrant hasContractAdmin returns(bool) {

    Bid memory bid = idToNftBid[bidId];
    require(sendEther(bid.bidder, bid.bidValue));
    openStorage.push(bidId);
    emit BidRefunded(bid.tokenId, bidId, msg.sender);
    idToNftBid[bidId] = Bid(0, 0, 0, 0, 0, payable(address(0x0)), payable(address(0x0)));
    return true;
  }

function transferFromERC721(address assetAddr, uint256 tokenId, address to) internal virtual returns(bool){

    address kitties = 0x06012c8cf97BEaD5deAe237070F9587f8E7A266d;
    address punks = 0xb47e3cd837dDF8e4c57F05d70Ab865de6e193BBB;
    bytes memory data;
    if (assetAddr == kitties) {
        data = abi.encodeWithSignature("transferFrom(address,address,uint256)", msg.sender, to, tokenId);
    } else if (assetAddr == punks) {
        bytes memory punkIndexToAddress = abi.encodeWithSignature("punkIndexToAddress(uint256)", tokenId);
        (bool checkSuccess, bytes memory result) = address(assetAddr).staticcall(punkIndexToAddress);
        (address nftOwner) = abi.decode(result, (address));
        require(checkSuccess && nftOwner == msg.sender, "Not the NFT owner");
        data = abi.encodeWithSignature("transferPunk(address,uint256)", msg.sender, tokenId);
    } else {
        data = abi.encodeWithSignature("safeTransferFrom(address,address,uint256)", msg.sender, to, tokenId);
    }
    (bool success, bytes memory resultData) = address(assetAddr).call(data);
    require(success, string(resultData));
    return true;
  }

  function sendEther(address recipient, uint ethvalue) internal returns (bool){

    (bool success, bytes memory data) = address(recipient).call{value: ethvalue}("");
    return(success);
  }

  function calcFee(uint256 value) internal returns (uint256) {

      address rewardsAdd = IRoleProvider(roleAdd).fetchAddress(REWARDS);
      uint fee = IRewardsController(rewardsAdd).getFee();
      uint256 percent = ((value * fee) / 10000);
      return percent;
    }

  function removeId(uint store) internal {

      if (store==0){
      openStorage.pop();
      } else if (store==1){
      blindOpenStorage.pop();
      }
    }

  function fetchBidItems() external view returns (Bid[] memory) {

    uint bidcount = bidIds;
    Bid[] memory bids = new Bid[](bidcount);
    for (uint i=0; i < bidcount; i++) {
      if (idToNftBid[i + 1].itemId > 0) {
        Bid storage currentItem = idToNftBid[i + 1];
        bids[i] = currentItem;
      }
    }
    return bids;
  }

  function fetchBidItemsByBidder(address bidder) external view returns (Bid[] memory) {

    uint bidcount = bidIds;
    Bid[] memory bids = new Bid[](bidcount);
    for (uint i=0; i < bidcount; i++) {
      if (idToNftBid[i + 1].bidder == bidder) {
        Bid storage currentItem = idToNftBid[i + 1];
        bids[i] = currentItem;
      }
    }
    return bids;
  }

  function fetchBlindBidItems() external view returns (BlindBid[] memory) {

    uint bidcount = blindBidIds;
    BlindBid[] memory bids = new BlindBid[](bidcount);
    for (uint i=0; i < bidcount; i++) {
      if (idToBlindBid[i + 1].bidValue > 0) {
        BlindBid storage currentItem = idToBlindBid[i + 1];
        bids[i] = currentItem;
      }
    }
    return bids;
  }

  function fetchBlindBidItemsByBidder(address bidder) external view returns (BlindBid[] memory) {

    uint bidcount = blindBidIds;
    BlindBid[] memory bids = new BlindBid[](bidcount);
    for (uint i=0; i < bidcount; i++) {
      if (idToBlindBid[i + 1].bidder == bidder) {
        BlindBid storage currentItem = idToBlindBid[i + 1];
        bids[i] = currentItem;
      }
    }
    return bids;
  }

  function fetchBlindBidItemById(uint bidId) external view returns (BlindBid memory bid) {

    BlindBid memory currentItem = idToBlindBid[bidId];
    return currentItem;
  }

  function fetchBidItemById(uint tokenId) external view returns (Bid memory bid) { 

    uint bidcount = bidIds;
    for (uint i=0; i < bidcount; i++) {
      if (idToNftBid[i + 1].tokenId == tokenId) {
        Bid memory currentItem = idToNftBid[i + 1];
        return currentItem;
      }
    }
  }

  function fetchBidId(uint marketId) external view returns (uint id) {

    uint _id = mktIdToBidId[marketId];
    return _id;
  }

  event FundsForwarded(uint value, address from, address to);
  receive() external payable {
    require(sendEther(roleAdd, msg.value));
      emit FundsForwarded(msg.value, msg.sender, roleAdd);
  }
}