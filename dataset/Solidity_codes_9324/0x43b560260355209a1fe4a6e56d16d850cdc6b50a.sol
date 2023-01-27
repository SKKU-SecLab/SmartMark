
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

interface INFTMarket { 

    function transferNftForSale(address receiver, uint itemId) external returns(bool);

}//*~~~> MIT
pragma solidity 0.8.7;

interface IRoleProvider {

  function hasTheRole(bytes32 role, address theaddress) external returns(bool);

  function fetchAddress(bytes32 thevar) external returns(address);

  function hasContractRole(address theaddress) external view returns(bool);

}//*~~~> MIT make it better, stronger, faster


pragma solidity  0.8.7;


contract MarketTrades is ReentrancyGuard {

  
  uint private tradeCount;
  uint private blindTradeCount;

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

  bytes32 public constant MARKET = keccak256("MARKET");

  bytes32 public constant BIDS = keccak256("BIDS");

  bytes32 public constant OFFERS = keccak256("OFFERS");

  uint[] private openStorage;
  uint[] private blindOpenStorage;

  constructor(address role){
    roleAdd = role;
  }

  struct Trade {
    bool is1155; 
    uint itemId;
    uint tradeId;
    uint tokenId;
    uint amount1155;
    address nftCont;
    address trader;
    address seller;
  }
  struct BlindTrade {
    bool is1155;
    bool isWant1155;
    bool isActive;
    bool isSpecific;
    uint wantedId;
    uint tradeId;
    uint tokenId;
    uint amount1155;
    uint wAmount1155;
    address nftCont;
    address wantCont;
    address trader;
  }

  mapping (uint256 => Trade) private idToNftTrade;
  mapping (uint256 => BlindTrade) private idToBlindTrade;
  mapping (uint => uint) private marketIdToTradeId;

  event TradeEntered(
      bool is1155,
      uint itemId,
      uint tradeId,
      uint tokenId,
      uint amount1155,
      address indexed nftCont,
      address indexed trader,
      address indexed seller
  );
  event BlindTradeEntered(
      bool isWanted1155,
      bool isGiven1155,
      bool isSpecific,
      uint wantedId,
      uint tokenId,
      uint tradeId,
      uint amount1155,
      uint wAmount1155,
      address indexed nftCont,
      address indexed wantCont,
      address indexed trader
  );

  event TradeWithdrawn(
      bool is1155,
      uint itemId,
      uint tradeId,
      uint indexed tokenId,
      address indexed nftCont,
      address indexed trader
  );

  event TradeAccepted(
      bool is1155,
      bool isActive,
      uint indexed itemId,
      uint indexed tradeId,
      uint tokenId,
      address nftCont,
      address indexed trader,
      address seller
  ); 
  
  event BlindTradeAccepted(
      bool is1155,
      bool isActive,
      uint indexed itemId,
      uint indexed tradeId,
      uint tokenId,
      address nftCont,
      address indexed trader,
      address seller
  );  

  event TradeUpdated(
      bool is1155,
      bool isActive,
      uint indexed itemId,
      uint indexed tradeId,
      uint tokenId,
      address nftCont,
      address indexed trader,
      address seller
  );

  function enterTrade(
      uint[] memory amount1155,
      uint[] memory itemId,
      uint[] memory tokenId,
      address[] memory nftContract,
      address[] memory seller
  ) external nonReentrant returns(bool){

    for (uint i=0;i<itemId.length;i++) {
      uint tradeId;
      if (openStorage.length>=1) {
        tradeId = openStorage[openStorage.length-1];
        _remove(0);
      } else {
        tradeId = tradeCount+=1;
      }
      if (amount1155[i]>0){
        IERC1155(nftContract[i]).safeTransferFrom(msg.sender, address(this), tokenId[i], amount1155[i], "");
        IERC1155(nftContract[i]).setApprovalForAll(address(this), true);
        marketIdToTradeId[itemId[i]] = tradeId;
        idToNftTrade[tradeId] = Trade(true, itemId[i], tradeId, tokenId[i], amount1155[i], nftContract[i], msg.sender, seller[i]);
        emit TradeEntered(
          true,
          itemId[i], 
          tradeId, 
          tokenId[i],
          amount1155[i],
          nftContract[i], 
          msg.sender, 
          seller[i]);
      } else {
        require(transferFromERC721(nftContract[i], tokenId[i], address(this)));
        require(approveERC721(nftContract[i], address(this), tokenId[i]));
        marketIdToTradeId[itemId[i]] = tradeId;
        idToNftTrade[tradeId] = Trade(false, itemId[i], tradeId, tokenId[i], amount1155[i], nftContract[i], msg.sender, seller[i]);
        emit TradeEntered(
          false,
          itemId[i], 
          tradeId, 
          tokenId[i],
          amount1155[i],
          nftContract[i], 
          msg.sender, 
          seller[i]);
        }
      }
    return true;
  }

  function enterBlindTrade(
      bool[] memory isWanted1155,
      bool[] memory isGiven1155,
      bool[] memory isSpecific,
      uint[] memory wantedId,
      uint[] memory tokenId,
      uint[] memory amount1155,
      uint[] memory wAmount1155,
      address[] memory nftContract,
      address[] memory wantContract
  ) external nonReentrant{


    for (uint i=0;i<tokenId.length;i++) {
      uint tradeId;
      if (blindOpenStorage.length>=1) {
        tradeId = blindOpenStorage[blindOpenStorage.length-1];
        _remove(1);
      } else {
        tradeId = blindTradeCount+=1;
      }
      if (isGiven1155[i]){
        IERC1155(nftContract[i]).safeTransferFrom(msg.sender, address(this), tokenId[i], amount1155[i], "");
        IERC1155(nftContract[i]).setApprovalForAll(address(this), true);
      } else {
        require(transferFromERC721(nftContract[i], tokenId[i], address(this)));
        require(approveERC721(nftContract[i], address(this), tokenId[i]));
      }
      idToBlindTrade[tradeId] = BlindTrade(isWanted1155[i], isGiven1155[i], true, isSpecific[i], wantedId[i], tradeId, tokenId[i], amount1155[i], wAmount1155[i], nftContract[i], wantContract[i], msg.sender);
      emit BlindTradeEntered(
          isWanted1155[i],
          isGiven1155[i],
          isSpecific[i],
          wantedId[i],
          tokenId[i],
          tradeId, 
          amount1155[i],
          wAmount1155[i],
          nftContract[i], 
          wantContract[i],
          msg.sender);
      }
  }

  function withdrawTrade(
      bool[] memory isBlind,
      uint[] memory itemId,
      uint[] memory tradeId
  ) external nonReentrant returns(bool){

    for (uint i=0; i<itemId.length; i++) {
      if(isBlind[i]){
      BlindTrade memory trade = idToBlindTrade[tradeId[i]];
      require(trade.isActive == true, "Item is not listed for trade...");
      if (trade.trader != msg.sender) revert();
      if ( trade.is1155 ){
        IERC1155(trade.nftCont).safeTransferFrom(address(this), trade.trader, trade.tokenId, trade.amount1155, "");
      } else {
        require(transferERC721(trade.nftCont, trade.trader, trade.tokenId));
      }
      blindOpenStorage.push(tradeId[i]);
      idToBlindTrade[tradeId[i]] = BlindTrade(false, false, false, false, 0, 0, 0, 0, 0, address(0x0), address(0x0), address(0x0));
      emit TradeWithdrawn(
          false,
          itemId[i], 
          tradeId[i],  
          trade.tokenId,
          trade.nftCont, 
          trade.trader
          );
      } else {
      Trade memory trade = idToNftTrade[tradeId[i]];
      require(trade.tradeId > 0, "Item is not listed for trade...");
      if (trade.trader != msg.sender) revert();
      if ( trade.is1155 ){
        IERC1155(trade.nftCont).safeTransferFrom(address(this), msg.sender, trade.tokenId, trade.amount1155, "");
      } else {
        require(transferERC721(trade.nftCont, trade.trader, trade.tokenId));
      }
      openStorage.push(tradeId[i]);
      marketIdToTradeId[itemId[i]] = 0;
      idToNftTrade[tradeId[i]] = Trade(false, 0, 0, 0, 0, address(0x0), address(0x0), address(0x0));
      
      emit TradeWithdrawn(
          false,
          itemId[i], 
          tradeId[i],  
          trade.tokenId,
          trade.nftCont, 
          trade.trader
          );
        }
      }
      return true;
  }

  function refundTrade(uint itemId, uint tradeId) public nonReentrant hasContractAdmin returns(bool){

    Trade memory trade = idToNftTrade[tradeId];
    if ( trade.is1155 ){
      IERC1155(trade.nftCont).safeTransferFrom(address(this), trade.trader, trade.tokenId, trade.amount1155, "");
    } else {
      require(transferERC721(trade.nftCont, trade.trader, trade.tokenId));
    }
    idToNftTrade[tradeId] = Trade(false, 0, 0, 0, 0, address(0x0), address(0x0), address(0x0));
    openStorage.push(tradeId);
    emit TradeUpdated(
       trade.is1155,
       false,
       itemId, 
       tradeId, 
       trade.tokenId,
       trade.nftCont, 
       trade.trader,
       trade.seller
      );
    return true;
  }

  function _refundTradeFromSale(uint itemId, uint tradeId) internal returns(bool){

    Trade memory trade = idToNftTrade[tradeId];
    if ( trade.is1155 ){
      IERC1155(trade.nftCont).safeTransferFrom(address(this), trade.trader, trade.tokenId, trade.amount1155, "");
    } else {
      require(transferERC721(trade.nftCont, trade.trader, trade.tokenId));
    }
    idToNftTrade[tradeId] = Trade(false, 0, 0, 0, 0, address(0x0), address(0x0), address(0x0));
    openStorage.push(tradeId);
    emit TradeUpdated(
       trade.is1155,
       false,
       itemId, 
       tradeId, 
       trade.tokenId,
       trade.nftCont, 
       trade.trader,
       trade.seller
      );
    return true;
  }

  function acceptTrade(
      uint[] calldata itemId,
      uint[] calldata tradeId
  ) public nonReentrant returns(bool){

    
    address marketAdd = IRoleProvider(roleAdd).fetchAddress(MARKET);
    address bidsAdd = IRoleProvider(roleAdd).fetchAddress(BIDS);
    address offersAdd = IRoleProvider(roleAdd).fetchAddress(OFFERS);
    for(uint i=0; i<itemId.length;i++) {
      Trade memory trade = idToNftTrade[tradeId[i]];
      require(msg.sender == trade.seller,"Not Owner");
      if ( trade.is1155 ){
        IERC1155(trade.nftCont).safeTransferFrom(address(this), trade.seller, trade.tokenId, trade.amount1155, "");
      } else {
        require(transferERC721(trade.nftCont, trade.seller, trade.tokenId));
      }
      uint offerId = IOffers(offersAdd).fetchOfferId(itemId[i]);
      if (offerId > 0) {
        require(IOffers(offersAdd).refundOffer(itemId[i], offerId));
      }
      uint bidId = IBids(bidsAdd).fetchBidId(itemId[i]);
      if (bidId>0) {
        require(IBids(bidsAdd).refundBid(bidId));
      }
       openStorage.push(tradeId[i]);
       marketIdToTradeId[itemId[i]] = 0;
       idToNftTrade[tradeId[i]] = Trade(
           false,
           0,
           0,
           0,
           0,
           address(0x0),
           address(0x0),
           address(0x0)
       );
      Trade[] memory trades = fetchTradesById(itemId[i]);
      for(uint j; j<trades.length;j++){
        require(_refundTradeFromSale(trades[i].itemId, trades[i].tradeId));
      }
       require(INFTMarket(marketAdd).transferNftForSale(trade.trader, itemId[i]));
       emit TradeAccepted(
           trade.is1155,
           false,
           itemId[i], 
           tradeId[i], 
           trade.tokenId,
           trade.nftCont,
           trade.trader, 
           trade.seller
           );
      }
    return true;
    }

    function acceptBlindTrade(
      uint[] memory tradeId,
      uint[] memory tokenId,
      uint[] memory listedId
  ) public  nonReentrant returns(bool){

    address marketAdd = IRoleProvider(roleAdd).fetchAddress(MARKET);
    for(uint i=0; i<tradeId.length;i++) {
      uint j = tradeId[i];
      BlindTrade memory trade = idToBlindTrade[j];
      if(trade.isSpecific){
          require(tokenId[i]==trade.wantedId,"Wrong item!");
        }
      
      if (trade.is1155){
        if(listedId[i]==0){
          IERC1155(trade.nftCont).safeTransferFrom(address(this), msg.sender, trade.tokenId, trade.amount1155, "");
        } else {
          require(INFTMarket(marketAdd).transferNftForSale(msg.sender, listedId[i]));
        }
      } else {
        if(listedId[i]==0){
          require(transferERC721(trade.nftCont, msg.sender, trade.tokenId));
        } else {
          require(INFTMarket(marketAdd).transferNftForSale(msg.sender, listedId[i]));
        }
      }
      if (trade.isWant1155){
        IERC1155(trade.wantCont).safeTransferFrom(msg.sender, trade.trader, tokenId[i], trade.wAmount1155, "");
      } else {
        require(IERC721(trade.wantCont).ownerOf(trade.wantedId) == msg.sender, "Not the token owner!");
        require(transferERC721(trade.wantCont, trade.trader, tokenId[i]));
      }
       blindOpenStorage.push(tradeId[i]);
       idToBlindTrade[tradeId[i]] = BlindTrade(
           false,
           false,
           false,
           false,
           0,
           0,
           0,
           0,
           0,
           address(0x0),
           address(0x0),
           address(0x0)
       );
       emit BlindTradeAccepted(
           trade.is1155,
           false,
           listedId[i], 
           tradeId[i], 
           tokenId[i],
           trade.nftCont, 
           trade.trader,
           msg.sender
           );
           
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
    return true;
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

  function fetchTrades() public view returns (Trade[] memory) {

    uint itemCount = tradeCount;
    uint currentIndex;
    Trade[] memory trades = new Trade[](itemCount);
    for (uint i=0; i < itemCount; i++) {
      if (idToNftTrade[i + 1].tradeId > 0) {
        Trade storage currentItem = idToNftTrade[i + 1];
         trades[currentIndex] = currentItem;
         currentIndex++;
      }
    }
    return trades;
  }
  function fetchUserTrades(address user) public view returns (Trade[] memory) {

    uint itemCount = tradeCount;
    uint currentIndex;
    Trade[] memory trades = new Trade[](itemCount);
    for (uint i=0; i < itemCount; i++) {
      if (idToNftTrade[i + 1].trader == user) {
        Trade storage currentItem = idToNftTrade[i + 1];
         trades[currentIndex] = currentItem;
         currentIndex++;
      }
    }
    return trades;
  }
  function fetchBlindTrades() public view returns (BlindTrade[] memory) {

    uint itemCount = blindTradeCount;
    uint currentIndex;
    BlindTrade[] memory trades = new BlindTrade[](itemCount);
    for (uint i=0; i < itemCount; i++) {
      if (idToBlindTrade[i + 1].isActive) {
        BlindTrade storage currentItem = idToBlindTrade[i + 1];
         trades[currentIndex] = currentItem;
         currentIndex++;
      }
    }
    return trades;
  }
  function fetchUserBlindTrades(address user) public view returns (BlindTrade[] memory) {

    uint itemCount = blindTradeCount;
    uint currentIndex;
    BlindTrade[] memory trades = new BlindTrade[](itemCount);
    for (uint i=0; i < itemCount; i++) {
      if (idToBlindTrade[i + 1].trader == user) {
        BlindTrade storage currentItem = idToBlindTrade[i + 1];
         trades[currentIndex] = currentItem;
         currentIndex++;
      }
    }
    return trades;
  }

  function fetchTradesById(uint itemId) public view returns (Trade[] memory) {

    uint itemCount = tradeCount;
    uint currentIndex;
    Trade[] memory trades = new Trade[](itemCount);
    for (uint i=0; i < itemCount; i++) {
      if (idToNftTrade[i + 1].tradeId > 0) {
          if (idToNftTrade[i + 1].itemId == itemId) {
            Trade storage currentItem = idToNftTrade[i + 1];
            trades[currentIndex] = currentItem;
            currentIndex++;
        }
      }
    }
    return trades;
  }

  function fetchTrade(uint itemId) public view returns (Trade memory item) {

    uint id = marketIdToTradeId[itemId];
    return idToNftTrade[id];
  }

  function fetchTradeId(uint itemId) public view returns(uint tradeId){

    uint id = marketIdToTradeId[itemId];
    return id;
  }

  function _remove(uint store) internal {

      if (store==0){
      openStorage.pop();
      } else if (store==1){
      blindOpenStorage.pop();
      }
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
      bytes memory
    )external pure returns(bytes4) {

        return bytes4(keccak256("onERC721Received(address,address,uint256,bytes)"));
  }
}