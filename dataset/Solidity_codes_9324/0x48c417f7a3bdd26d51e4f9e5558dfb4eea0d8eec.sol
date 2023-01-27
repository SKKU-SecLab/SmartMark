
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


pragma solidity  0.8.7;


interface IERC20 {

  function balanceOf(address account) external view returns (uint256);

  function allowance(address owner, address spender) external view returns (uint256);

  function transfer(address recipient, uint256 amount) external returns (bool);

  function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

  event Transfer(address indexed from, address indexed to, uint256 value);
}

contract MarketOffers is ReentrancyGuard {

  uint private offerIds;

  uint private blindOfferIds;

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

  address public roleAdd;
  uint[] private openStorage;
  uint[] private blindOpenStorage;

  bytes32 public constant NFTADD = keccak256("NFT");

  bytes32 public constant REWARDS = keccak256("REWARDS");

  bytes32 public constant MARKET = keccak256("MARKET");

  bytes32 public constant BIDS = keccak256("BIDS");
  
  bytes32 public constant TRADES = keccak256("TRADES");

  bytes32 public constant MINT = keccak256("MINT");


  constructor(address role) {
    roleAdd = role;
  }

  struct Offer {
    bool isActive;
    uint offerId;
    uint itemId;
    uint amount;
    address tokenCont;
    address offerer;
    address seller;
  }

  struct BlindOffer {
    bool isSpecific;
    uint amount1155;
    uint tokenId;
    uint blindOfferId;
    uint amount;
    address tokenCont;
    address collectionOffer;
    address offerer;
  }

  mapping (uint => Offer) private idToMktOffer;
  mapping (uint => BlindOffer) private idToBlindOffer;
  mapping (uint => uint) private marketIdToOfferId;

  event Offered(
    uint offerId,
    uint itemId,
    address indexed token_address,
    address indexed seller,
    address indexed offerer,
    uint amount
  );

  event BlindOffered(
    bool isSpecific,
    uint amount1155,
    uint tokenId,
    uint offerId,
    uint amount,
    address indexed offerer,
    address indexed token_address,
    address indexed collectionOffer
  );
  
  event OfferWithdrawn(
    uint indexed offerId,
    uint indexed itemId,
    address indexed offerer
  );

  event BlindOfferWithdrawn(
    uint indexed offerId,
    address indexed offerer
  );
  
  event OfferAccepted(
    uint offerId,
    uint indexed itemId,
    address indexed offerer,
    address indexed seller
  );

  event BlindOfferAccepted(
    uint blindOfferId,
    address indexed offerer,
    address indexed seller
  );

  event OfferRefunded(
    uint indexed offerId,
    uint indexed itemId,
    address indexed offerer
  );

  function enterOfferForNft(
    uint[] memory itemId,
    uint[] memory amount,
    address[] memory tokenCont,
    address[] memory seller
  ) external nonReentrant returns(bool){


    for (uint i=0; i< itemId.length; i++) {
      require (amount[i] > 0,"Amount needs to be > 0");

      IERC20 tokenContract = IERC20(tokenCont[i]);
      uint256 allowance = tokenContract.allowance(msg.sender, address(this));
      require(allowance >= amount[i], "Check the token allowance");
      require((tokenContract).transferFrom(msg.sender, (address(this)), amount[i]));
      uint offerId;
      uint len = openStorage.length;
      if (len>=1) {
        offerId = openStorage[len-1];
        _remove(0);
      } else {
        offerIds+=1;
        offerId = offerIds;
      }
      idToMktOffer[offerId] = Offer(true, offerId, itemId[i], amount[i], tokenCont[i], msg.sender, seller[i]);
      marketIdToOfferId[itemId[i]] = offerId;
      emit Offered(
        offerId,
        itemId[i],
        tokenCont[i],
        seller[i],
        msg.sender,
        amount[i]);
      }
    return true;
  }

  function enterBlindOffer(
    bool[] memory isSpecific,
    uint[] memory amount1155,
    uint[] memory tokenId,
    uint[] memory amount,
    address[] memory tokenCont,
    address[] memory collection
  ) external nonReentrant{

    for (uint i=0; i<tokenCont.length;i++){
      
      uint256 allowance = IERC20(tokenCont[i]).allowance(msg.sender, address(this));
      require(allowance >= amount[i], "Check the token allowance");

      require(IERC20(tokenCont[i]).transferFrom(msg.sender, (address(this)), amount[i]));

      uint offerId;
      uint len = blindOpenStorage.length;
      if (len>=1) {
        offerId = blindOpenStorage[len-1];
        _remove(1);
      } else {
        blindOfferIds+=1;
        offerId = blindOfferIds;
      }
      idToBlindOffer[offerId] = BlindOffer(isSpecific[i], amount1155[i], tokenId[i], offerId, amount[i], tokenCont[i], collection[i], msg.sender);
      emit BlindOffered(
        isSpecific[i],
        amount1155[i],
        tokenId[i],
        offerId,
        amount[i],
        payable(msg.sender),
        tokenCont[i],
        collection[i]
      );
    }

  }

  function acceptBlindOffer(
    uint[] memory blindOfferId,
    uint[] memory tokenId,
    uint[] memory offerId,
    uint[] memory listedId,
    bool[] memory isListed,
    bool[] memory is1155
  ) external nonReentrant returns(bool){


    address rewardsAdd = IRoleProvider(roleAdd).fetchAddress(REWARDS);
    address mrktAdd = IRoleProvider(roleAdd).fetchAddress(MARKET);
    uint balance = IERC721(IRoleProvider(roleAdd).fetchAddress(NFTADD)).balanceOf(msg.sender);

    for (uint i=0; i<blindOfferId.length;i++){
      
      BlindOffer memory offer = idToBlindOffer[blindOfferId[i]];
      IERC20 tokenContract = IERC20(offer.tokenCont);

      if(offer.isSpecific){
        require(tokenId[i]==offer.tokenId,"Wrong item!");
      }

      if(balance<1){
        uint256 saleFee = calcFee(offer.amount);
        uint256 userAmnt = (offer.amount-saleFee);
        require(IRewardsController(rewardsAdd).depositERC20Rewards(saleFee, offer.tokenCont));
        require((tokenContract).transfer(rewardsAdd, saleFee));
        require((tokenContract).transfer(msg.sender, userAmnt));
      } else {
        require((tokenContract).transfer(msg.sender, offer.amount));
      }

      if(isListed[i]){
        require(INFTMarket(mrktAdd).transferNftForSale(offer.offerer, listedId[i]));
      } else {
        if (is1155[i]){
          IERC1155(offer.collectionOffer).safeTransferFrom(address(this), msg.sender, tokenId[i], offer.amount1155, "");
        } else {
          require(transferFromERC721(offer.collectionOffer, tokenId[i], offer.offerer));
        }
      }
      blindOpenStorage.push(offerId[i]);
      idToBlindOffer[offerId[i]] = BlindOffer(false, 0, 0, 0, 0, address(0x0), address(0x0), address(0x0));
      emit BlindOfferAccepted(
        blindOfferId[i],
        offer.offerer,
        msg.sender
      );
    }
    return true;
  }

  function acceptOfferForNft(uint[] calldata offerId) external nonReentrant returns(bool){


    address mrktNft = IRoleProvider(roleAdd).fetchAddress(NFTADD);
    address rewardsAdd = IRoleProvider(roleAdd).fetchAddress(REWARDS);
    address bidsAdd = IRoleProvider(roleAdd).fetchAddress(BIDS);
    address tradesAdd = IRoleProvider(roleAdd).fetchAddress(TRADES);
    address mrktAdd = IRoleProvider(roleAdd).fetchAddress(MARKET);
    uint balance = IERC721(mrktNft).balanceOf(msg.sender);

    for (uint i=0; i<offerId.length; i++) {
      Offer memory offer = idToMktOffer[offerId[i]];
      if (msg.sender != offer.seller) revert();
      IERC20 tokenContract = IERC20(offer.tokenCont);
      if(balance<1){
        uint256 saleFee = calcFee(offer.amount);
        uint256 userAmnt = (offer.amount - saleFee);
        require(IRewardsController(rewardsAdd).depositERC20Rewards(saleFee, offer.tokenCont));
        require((tokenContract).transfer(rewardsAdd, saleFee));
        require((tokenContract).transfer(offer.seller, userAmnt));
      } else {
        require((tokenContract).transfer(offer.seller, offer.amount));
      }
      if (IBids(bidsAdd).fetchBidId(offer.itemId) > 0) {
        require(IBids(bidsAdd).refundBid(IBids(bidsAdd).fetchBidId(offer.itemId)));
      }
      if (ITrades(tradesAdd).fetchTradeId(offer.itemId) > 0) {
        require(ITrades(tradesAdd).refundTrade(offer.itemId, ITrades(tradesAdd).fetchTradeId(offer.itemId)));
      }

      marketIdToOfferId[offer.itemId] = 0;
      openStorage.push(offerId[i]);
      idToMktOffer[offerId[i]] = Offer(false, 0, 0, 0, address(0x0), address(0x0), address(0x0));
      
      require(INFTMarket(mrktAdd).transferNftForSale(offer.offerer, offer.itemId));

      emit OfferAccepted(
        offerId[i],
        offer.itemId,
        offer.offerer,
        offer.seller
      );
    }
    return true;
  }

  function withdrawOffer(uint[] memory offerId, bool[] memory isBlind) external nonReentrant returns(bool){

    for (uint i=0; i< offerId.length; i++) {
    if (isBlind[i]){
      BlindOffer memory offer = idToBlindOffer[offerId[i]];
      if (offer.offerer != msg.sender) revert();
      IERC20 tokenContract = IERC20(offer.tokenCont);
      require((tokenContract).transfer(offer.offerer, offer.amount));
      blindOpenStorage.push(offerId[i]);
      idToBlindOffer[offerId[i]] = BlindOffer(false, 0, 0, 0, 0, address(0x0), address(0x0), address(0x0));
      emit BlindOfferWithdrawn(
        offerId[i],
        msg.sender);
    } else {
      Offer memory offer = idToMktOffer[offerId[i]];
      if (offer.offerer != msg.sender) revert();
      IERC20 tokenContract = IERC20(offer.tokenCont);
      require((tokenContract).transfer(offer.offerer, offer.amount));
      openStorage.push(offerId[i]);
      marketIdToOfferId[offer.itemId] = 0;
      idToMktOffer[offerId[i]] = Offer(false, 0, 0, 0, address(0x0), address(0x0), address(0x0));
      emit OfferWithdrawn(
        offerId[i], 
        offer.itemId,
        msg.sender);
      }
    }
    return true;
  }

  function refundOffer(uint itemId, uint offerId) external nonReentrant hasContractAdmin returns(bool){

      Offer memory offer = idToMktOffer[itemId];
      require(offer.offerId == offerId);
      IERC20 tokenContract = IERC20(offer.tokenCont);
      require((tokenContract).transfer(offer.offerer, offer.amount));
      openStorage.push(offerId);
      marketIdToOfferId[itemId] = 0;
      idToMktOffer[offerId] = Offer(false, 0, 0, 0, address(0x0), address(0x0), address(0x0));
      emit OfferRefunded(offerId, itemId, offer.offerer);
    return true;
  }

function transferFromERC721(address assetAddr, uint256 tokenId, address to) internal virtual returns(bool) {

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

  function calcFee(uint256 value) internal returns (uint256)  {

      address rewardsAdd = IRoleProvider(roleAdd).fetchAddress(REWARDS);
      uint fee = IRewardsController(rewardsAdd).getFee();
      uint256 percent = ((value * fee) /10000);
      return percent;
    }

  function _remove(uint store) internal {

      if (store==0){
        openStorage.pop();
      } else if (store==1){
        blindOpenStorage.pop();
      }
    }

  function fetchOffers() public view returns (Offer[] memory) {

    uint itemCount = offerIds;
    Offer[] memory items = new Offer[](itemCount);
    for (uint i=0; i < itemCount; i++) {
      if (idToMktOffer[i + 1].isActive == true) {
        Offer storage currentItem = idToMktOffer[i + 1];
        items[i] = currentItem;
      }
    }
  return items;
  }

  function fetchOffersByItemId(uint itemId) public view returns (Offer[] memory) {

    uint itemCount = offerIds;
    Offer[] memory items = new Offer[](itemCount);
    for (uint i=0; i < itemCount; i++) {
      if (idToMktOffer[i + 1].isActive == true) {
        if (idToMktOffer[i + 1].itemId == itemId){
          Offer storage currentItem = idToMktOffer[i + 1];
          items[i] = currentItem;
        }
      }
    }
  return items;
  }

  function fetchOffersByOfferer(address user) public view returns (Offer[] memory) {

    uint itemCount = offerIds;
    Offer[] memory items = new Offer[](itemCount);
    for (uint i=0; i < itemCount; i++) {
      if (idToMktOffer[i + 1].isActive == true) {
        if (idToMktOffer[i + 1].offerer == user){
          Offer storage currentItem = idToMktOffer[i + 1];
          items[i] = currentItem;
        }
      }
    }
  return items;
  }

  function fetchBlindOffers() public view returns (BlindOffer[] memory) {

    uint itemCount = blindOfferIds;
    BlindOffer[] memory items = new BlindOffer[](itemCount);
    for (uint i=0; i < itemCount; i++) {
      BlindOffer storage currentItem = idToBlindOffer[i + 1];
      items[i] = currentItem;
    }
  return items;
  }

  function fetchBlindOffersByOfferer(address user) public view returns (BlindOffer[] memory) {

    uint itemCount = blindOfferIds;
    BlindOffer[] memory items = new BlindOffer[](itemCount);
    for (uint i=0; i < itemCount; i++) {
      if (idToBlindOffer[i + 1].offerer == user){
        BlindOffer storage currentItem = idToBlindOffer[i + 1];
        items[i] = currentItem;
      }
    }
  return items;
  }

  function fetchOfferId(uint itemId) public view returns (uint) {

    uint id = marketIdToOfferId[itemId];
    return id;
  }

  event FundsForwarded(uint value, address from, address to);
  receive() external payable {
    require(sendEther(roleAdd, msg.value));
      emit FundsForwarded(msg.value, msg.sender, roleAdd);
  }
}