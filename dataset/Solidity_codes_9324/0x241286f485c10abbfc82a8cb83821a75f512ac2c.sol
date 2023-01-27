
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

interface IRewardsController {

  function createNftHodler(uint tokenId) external returns (bool);

  function depositERC20Rewards(uint amount, address tokenAddress) external returns(bool);

  function getFee() external view returns(uint);

  function setFee(uint fee) external returns (bool);

  function depositEthRewards(uint reward) external payable returns(bool);

  function createUser(address userAddress) external returns(bool);

  function setUser(bool canClaim, address userAddress) external returns(bool);

}//*~~~> MIT
pragma solidity 0.8.7;

interface IRoleProvider {

  function hasTheRole(bytes32 role, address theaddress) external returns(bool);

  function fetchAddress(bytes32 thevar) external returns(address);

  function hasContractRole(address theaddress) external view returns(bool);

}//*~~~> MIT make it better, stronger, faster


pragma solidity  0.8.7;


interface IERC20 {

  function transfer(address to, uint value) external returns (bool);

}

contract NFTMarket is ReentrancyGuard {


  bytes32 public constant PROXY_ROLE = keccak256("PROXY_ROLE"); 
  bytes32 public constant DEV = keccak256("DEV");

  address public roleAdd;

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

  uint256 public itemIds;

  bytes32 public constant REWARDS = keccak256("REWARDS");
  
  bytes32 public constant BIDS = keccak256("BIDS");
  
  bytes32 public constant OFFERS = keccak256("OFFERS");
  
  bytes32 public constant TRADES = keccak256("TRADES");

  bytes32 public constant NFTADD = keccak256("NFT");

  uint[] private openStorage;

  uint public minVal;

  constructor(address newrole) {
    roleAdd = newrole;
    minVal = 1e15;
  }

  struct MktItem {
    bool is1155;
    uint itemId;
    uint amount1155;
    uint price;
    uint tokenId;
    address nftContract;
    address payable seller;
  }

  mapping(uint256 => MktItem) private idToMktItem;
  mapping(address => uint) public addressToUserBal;

  event ItemListed (
    uint itemId,
    uint amount1155,
    uint price,
    uint indexed tokenId, 
    address indexed nftContract, 
    address indexed seller
    );

  event ItemDelisted(
    uint indexed itemId,
    uint indexed tokenId,
    address indexed nftContract
    );

  event ItemBought(
    uint itemId,
    uint indexed tokenId, 
    address indexed nftContract, 
    address fromAddress, 
    address indexed toAddress
    );

  event ItemUpdated(
    uint itemId,
    uint indexed tokenId,
    uint price,
    address indexed nftContract,
    address indexed seller
  );

  function setMinimumValue(uint minWei) external hasDevAdmin returns(bool){

    minVal = minWei;
    return true;
  }

  function listMarketItems(
    bool[] memory is1155,
    uint[] memory amount1155,
    uint[] memory tokenId,
    uint[] memory price,
    address[] memory nftContract
  ) external nonReentrant returns(bool){

    require(tokenId.length>0);
    require(tokenId.length == nftContract.length);
    uint user = addressToUserBal[msg.sender];
    if (user==0) {
        require(IRewardsController(IRoleProvider(roleAdd).fetchAddress(REWARDS)).createUser(msg.sender));
      }
    uint tokenLen = tokenId.length;
    for (uint i=0;i<tokenLen;i++){
        require(price[i] >= minVal);
        uint itemId;
        uint len = openStorage.length;
        if (len>=1){
          itemId=openStorage[len-1];
          _remove();
        } else {
          itemId = itemIds+=1;
        }
        if(!is1155[i]){
        require(transferFromERC721(nftContract[i], tokenId[i], address(this)));
        require(approveERC721(nftContract[i], address(this), tokenId[i]));
        idToMktItem[itemId] =  MktItem(false, itemId, amount1155[i], price[i], tokenId[i], nftContract[i], payable(msg.sender));
      } else {
        IERC1155(nftContract[i]).safeTransferFrom(msg.sender, address(this), tokenId[i], amount1155[i], "");
        IERC1155(nftContract[i]).setApprovalForAll(address(this), true);
        idToMktItem[itemId] =  MktItem(true, itemId, amount1155[i], price[i], tokenId[i], nftContract[i], payable(msg.sender));
      }
      emit ItemListed(itemId, amount1155[i], price[i], tokenId[i], nftContract[i], msg.sender);
    }
    addressToUserBal[msg.sender] += tokenLen;
    return true;
  }


  function delistMarketItems(
    uint256[] calldata itemId
  ) public nonReentrant returns(bool){


    address rewardsAdd = IRoleProvider(roleAdd).fetchAddress(REWARDS);
    address bidsAdd = IRoleProvider(roleAdd).fetchAddress(BIDS);
    address offersAdd = IRoleProvider(roleAdd).fetchAddress(OFFERS);
    address tradesAdd = IRoleProvider(roleAdd).fetchAddress(TRADES);

    for (uint i=0;i<itemId.length;i++){
      MktItem memory it = idToMktItem[itemId[i]];
      require(it.seller == msg.sender, "Not owner");

      uint bidId = IBids(bidsAdd).fetchBidId(itemId[i]);
      if (bidId>0) {
        require(IBids(bidsAdd).refundBid(bidId));
      }
      uint offerId = IOffers(offersAdd).fetchOfferId(itemId[i]);
      if (offerId > 0) {
        require(IOffers(offersAdd).refundOffer(itemId[i], offerId));
      }
      uint tradeId = ITrades(tradesAdd).fetchTradeId(itemId[i]);
      if (tradeId > 0) {
        require(ITrades(tradesAdd).refundTrade(itemId[i], tradeId));
      }
      if(it.is1155){
        IERC1155(it.nftContract).safeTransferFrom(address(this), msg.sender, it.tokenId, it.amount1155, "");
      } else {
        require(transferERC721(it.nftContract, it.seller, it.tokenId));
      }
      openStorage.push(itemId[i]);
      idToMktItem[itemId[i]] =  MktItem(false, itemId[i], 0, 0, 0, address(0x0), payable(0x0));
      emit ItemDelisted(itemId[i], it.tokenId, it.nftContract);
      addressToUserBal[msg.sender] -= 1;
      }
      if (addressToUserBal[msg.sender]==0){
          require(IRewardsController(rewardsAdd).setUser(false, msg.sender));
        } else { //*~~~> Allow claims
          require(IRewardsController(rewardsAdd).setUser(true, msg.sender));
        }
      return true;
  }

  function buyMarketItems(
    uint256[] memory itemId
    ) public payable nonReentrant returns(bool) {

    
    address bidsAdd = IRoleProvider(roleAdd).fetchAddress(BIDS);
    address offersAdd = IRoleProvider(roleAdd).fetchAddress(OFFERS);
    address tradesAdd = IRoleProvider(roleAdd).fetchAddress(TRADES);
    address rewardsAdd = IRoleProvider(roleAdd).fetchAddress(REWARDS);

    uint balance = IERC721(IRoleProvider(roleAdd).fetchAddress(NFTADD)).balanceOf(msg.sender);
    uint prices=0;
    uint length = itemId.length;
    for (uint i=0; i < length; i++) {
      MktItem memory it = idToMktItem[itemId[i]];
      prices += it.price;
    }
    require(msg.value == prices);
    for (uint i=0; i<length; i++) {
      MktItem memory it = idToMktItem[itemId[i]];
      if(balance<1){
        uint256 saleFee = calcFee(it.price);
        uint256 userAmnt = it.price - saleFee;
        require(sendEther(rewardsAdd, saleFee));
        require(sendEther(it.seller, userAmnt));
      } else {
        require(sendEther(it.seller, it.price));
      }
      if (IBids(bidsAdd).fetchBidId(itemId[i])>0) {
        require(IBids(bidsAdd).refundBid(IBids(bidsAdd).fetchBidId(itemId[i])));
      }
      if (IOffers(offersAdd).fetchOfferId(itemId[i]) > 0) {
        require(IOffers(offersAdd).refundOffer(itemId[i], IOffers(offersAdd).fetchOfferId(itemId[i])));
      }
      if (ITrades(tradesAdd).fetchTradeId(itemId[i]) > 0) {
        require(ITrades(tradesAdd).refundTrade(itemId[i], ITrades(tradesAdd).fetchTradeId(itemId[i])));
      }
      addressToUserBal[it.seller] -= 1;
      emit ItemBought(itemId[i], it.tokenId, it.nftContract, it.seller, msg.sender);
      if(it.is1155){
        IERC1155(it.nftContract).safeTransferFrom(address(this), msg.sender, it.tokenId, it.amount1155, "");
        idToMktItem[itemId[i]] = MktItem(true, itemId[i], 0, 0, 0, address(0x0), payable(0x0));
      } else {
        require(transferERC721(it.nftContract, msg.sender, it.tokenId));
        idToMktItem[itemId[i]] = MktItem(false, itemId[i], 0, 0, 0, address(0x0), payable(0x0));
      }
      openStorage.push(itemId[i]);
      if (addressToUserBal[it.seller]==0){
          require(IRewardsController(rewardsAdd).setUser(false, it.seller));
        } else { //*~~~> Allow claims
          require(IRewardsController(rewardsAdd).setUser(true, it.seller));
        }
    }
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

  function approveERC721(address assetAddr, address to, uint256 tokenId) internal virtual returns(bool) {

    address punks = 0xb47e3cd837dDF8e4c57F05d70Ab865de6e193BBB;
    bytes memory data;
    if (assetAddr == punks) {
        data = abi.encodeWithSignature("offerPunkForSaleToAddress(uint256,uint256,address)", tokenId, 0, to);
        (bool success, bytes memory resultData) = address(assetAddr).call(data);
        require(success, string(resultData));
    } else {
      data = abi.encodeWithSignature("approve(address,uint256)", to, tokenId);
    }
    return(true);
  }

  function transferERC721(address assetAddr, address to, uint256 tokenId) internal virtual returns(bool) {

    address kitties = 0x06012c8cf97BEaD5deAe237070F9587f8E7A266d;
    address punks = 0xb47e3cd837dDF8e4c57F05d70Ab865de6e193BBB;
    bytes memory data;
    if (assetAddr == kitties) {
        data = abi.encodeWithSignature("transfer(address,uint256)", to, tokenId);
    } else if (assetAddr == punks) {
        data = abi.encodeWithSignature("transferPunk(address,uint256)", to, tokenId);
    } else {
        data = abi.encodeWithSignature("safeTransferFrom(address,address,uint256)", address(this), to, tokenId);
    }
    (bool success, bytes memory returnData) = address(assetAddr).call(data);
    require(success, string(returnData));
    return true;
  }

  function calcFee(uint256 value) internal returns (uint256)  {

      address rewardsAdd = IRoleProvider(roleAdd).fetchAddress(REWARDS);
      uint fee = IRewardsController(rewardsAdd).getFee();
      uint256 percent = ((value * fee) / 10000);
      return percent;
    }
    
  function updateMarketItemPrice(uint itemId, uint price) external nonReentrant {

    MktItem memory it = idToMktItem[itemId];
    require(msg.sender == it.seller);
    require(price >= minVal);
    idToMktItem[it.itemId] = MktItem(it.is1155, it.itemId, price, it.amount1155, it.tokenId, it.nftContract, it.seller);
    emit ItemUpdated(itemId, it.tokenId, price, it.nftContract, it.seller);
  }

  function fetchMarketItems() public view returns (MktItem[] memory) {

    uint itemCount = itemIds;
    MktItem[] memory items = new MktItem[](itemCount);
    for (uint i = 0; i < itemCount; i++) {
      if (idToMktItem[i + 1].itemId > 0) {
        MktItem storage currentItem = idToMktItem[i + 1];
        items[i] = currentItem;
      }
    }
    return items;
  }
  
  function fetchItemsBySeller(address userAdd) public view returns (MktItem[] memory) {

    uint itemCount = itemIds;
    MktItem[] memory items = new MktItem[](itemCount);
    for (uint i=0; i < itemCount; i++) {
      if (idToMktItem[i + 1].seller == userAdd) {
        MktItem storage currentItem = idToMktItem[i + 1];
        items[i] = currentItem;
      }
    }
    return items;
  }

  function fetchAmountListed(address userAdd) public view returns (uint howMany){

    uint user = addressToUserBal[userAdd];
    return user;
  }

  function _remove() internal {

      openStorage.pop();
    }

  function withdrawToken(address receiver, address tokenContract, uint256 amount) external nonReentrant hasDevAdmin returns(bool) {

    require(IERC20(tokenContract).transfer(receiver, amount));
    return true;
  }

  function transferForSale(address receiver, uint itemId) internal {


    address bidsAdd = IRoleProvider(roleAdd).fetchAddress(BIDS);
    address tradesAdd = IRoleProvider(roleAdd).fetchAddress(TRADES);
    address offersAdd = IRoleProvider(roleAdd).fetchAddress(OFFERS);

    MktItem memory it = idToMktItem[itemId];
    if ( it.is1155 ){
        IERC1155(it.nftContract).safeTransferFrom(address(this), payable(receiver), it.tokenId, it.amount1155, "");
      } else {
        require(transferERC721(it.nftContract, payable(receiver), it.tokenId));
      }
      uint bidId = IBids(bidsAdd).fetchBidId(itemId);
      if (bidId>0) {
        require(IBids(bidsAdd).refundBid(bidId));
      }
      uint offerId = IOffers(offersAdd).fetchOfferId(itemId);
      if (offerId > 0) {
        require(IOffers(offersAdd).refundOffer(itemId, offerId));
      }
      uint tradeId = ITrades(tradesAdd).fetchTradeId(itemId);
      if (tradeId > 0) {
        require(ITrades(tradesAdd).refundTrade(itemId, tradeId));
      }
      openStorage.push(itemId);
      idToMktItem[itemId] = MktItem(false, itemId, 0, 0, 0, address(0x0), payable(0x0));
      emit ItemBought(itemId, it.tokenId, it.nftContract, it.seller, receiver);
  }

  function transferNftForSale(address receiver, uint itemId) public nonReentrant hasContractAdmin returns(bool) {

    transferForSale(receiver, itemId);
    return true;
  }

  function sendEther(address recipient, uint ethvalue) internal returns (bool){

    (bool success, bytes memory data) = address(recipient).call{value: ethvalue}("");
    return(success);
  }

  event FundsForwarded(uint value, address from, address to);
  receive() external payable {
    require(sendEther(roleAdd, msg.value));
    emit FundsForwarded(msg.value, msg.sender, roleAdd);
  }
  function onERC1155Received(address, address, uint256, uint256, bytes memory) public virtual returns (bytes4) {

        return this.onERC1155Received.selector;
    }
  function onERC721Received(
      address, 
      address, 
      uint256, 
      bytes calldata
    )external pure returns(bytes4) {

        return bytes4(keccak256("onERC721Received(address,address,uint256,bytes)"));
  }
}