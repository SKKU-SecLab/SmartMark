




pragma solidity ^0.5.0;

contract Ownable {

    address internal _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    function ownerInit() internal {

         _owner = msg.sender;
        emit OwnershipTransferred(address(0), _owner);
    }
    function owner() public view returns (address) {

        return _owner;
    }

    modifier onlyOwner() {

        require(isOwner(), "Ownable: caller is not the owner");
        _;
    }

    function isOwner() public view returns (bool) {

        return msg.sender == _owner;
    }

    function renounceOwnership() public onlyOwner {

        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    function transferOwnership(address newOwner) public onlyOwner {

        _transferOwnership(newOwner);
    }

    function _transferOwnership(address newOwner) internal {

        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}


pragma solidity ^0.5.0;
interface IERC20 {

    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount) external returns (bool);

    function allowance(address owner, address spender) external view returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

    function mint(address recipient, uint256 amount) external returns(bool);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
      function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);

    function blindBox(address seller, string calldata tokenURI, bool flag, address to, string calldata ownerId) external returns (uint256);

    function mintAliaForNonCrypto(uint256 price, address from) external returns (bool);

    function nonCryptoNFTVault() external returns(address);

    function mainPerecentage() external returns(uint256);

    function authorPercentage() external returns(uint256);

    function platformPerecentage() external returns(uint256);

    function updateAliaBalance(string calldata stringId, uint256 amount) external returns(bool);

    function getSellDetail(uint256 tokenId) external view returns (address, uint256, uint256, address, uint256, uint256, uint256);

    function getNonCryptoWallet(string calldata ownerId) external view returns(uint256);

    function getNonCryptoOwner(uint256 tokenId) external view returns(string memory);

    function adminOwner(address _address) external view returns(bool);

     function getAuthor(uint256 tokenIdFunction) external view returns (address);

     function _royality(uint256 tokenId) external view returns (uint256);

     function getrevenueAddressBlindBox(string calldata info) external view returns(address);

     function getboxNameByToken(uint256 token) external view returns(string memory);

    function addNonCryptoAuthor(string calldata artistId, uint256 tokenId, bool _isArtist) external returns(bool);

    function transferAliaArtist(address buyer, uint256 price, address nftVaultAddress, uint256 tokenId ) external returns(bool);

    function checkArtistOwner(string calldata artistId, uint256 tokenId) external returns(bool);

    function checkTokenAuthorIsArtist(uint256 tokenId) external returns(bool);

    function withdraw(uint) external;

    function deposit() payable external;


    function isSellable (string calldata name) external view returns(bool);

    function tokenURI(uint256 tokenId) external view returns (string memory);


    function ownerOf(uint256 tokenId) external view returns (address);


    function burn (uint256 tokenId) external;

}


pragma solidity ^0.5.0;


interface INFT {

    function transferFromAdmin(address owner, address to, uint256 tokenId) external;

    function mintWithTokenURI(address to, string calldata tokenURI) external returns (uint256);

    function getAuthor(uint256 tokenIdFunction) external view returns (address);

    function updateTokenURI(uint256 tokenIdT, string calldata uriT) external;

    function mint(address to, string calldata tokenURI) external returns (uint256);

    function transferOwnership(address newOwner) external;

    function ownerOf(uint256 tokenId) external view returns(address);

    function transferFrom(address owner, address to, uint256 tokenId) external;

}


pragma solidity ^0.5.0;


contract IFactory {

    function create(string calldata name_, string calldata symbol_, address owner_) external returns(address);

    function getCollections(address owner_) external view returns(address [] memory);

}


pragma solidity ^0.5.0;

interface LPInterface {

    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);


   
}


pragma solidity ^0.5.0;

library SafeMath {

    function add(uint256 a, uint256 b) internal pure returns (uint256) {

        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b <= a, "SafeMath: subtraction overflow");
        uint256 c = a - b;

        return c;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {

        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b > 0, "SafeMath: division by zero");
        uint256 c = a / b;

        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b != 0, "SafeMath: modulo by zero");
        return a % b;
    }
}


pragma solidity ^0.5.0;







contract DexStorage {

  using SafeMath for uint256;
   address x; // dummy variable, never set or use its value in any logic contracts. It keeps garbage value & append it with any value set on it.
   IERC20 ALIA;
   INFT XNFT;
   IFactory factory;
   IERC20 OldNFTDex;
   IERC20 BUSD;
   IERC20 BNB;
   struct RDetails {
       address _address;
       uint256 percentage;
   }
  struct AuthorDetails {
    address _address;
    uint256 royalty;
    string ownerId;
    bool isSecondry;
  }
  mapping (uint256 => mapping(address => AuthorDetails)) internal _tokenAuthors;
  mapping (address => bool) public adminOwner;
  address payable public platform;
  address payable public authorVault;
  uint256 internal platformPerecentage;
  struct fixedSell {
    address seller;
    uint256 price;
    uint256 timestamp;
    bool isDollar;
    uint256 currencyType;
  }
  struct auctionSell {
    address seller;
    address nftContract;
    address bidder;
    uint256 minPrice;
    uint256 startTime;
    uint256 endTime;
    uint256 bidAmount;
    bool isDollar;
    uint256 currencyType;
  }

  
  mapping (uint256 => mapping (address  => fixedSell)) internal _saleTokens;
  mapping(address => bool) public _supportNft;
  mapping(uint256 => mapping ( address => auctionSell)) internal _auctionTokens;
  address payable public nonCryptoNFTVault;
  mapping (uint256=> mapping (address => string)) internal _nonCryptoOwners;
  struct balances{
    uint256 bnb;
    uint256 Alia;
    uint256 BUSD;
  }
  mapping (string => balances) internal _nonCryptoWallet;
 
  LPInterface LPAlia;
  LPInterface LPBNB;
  uint256 public adminDiscount;
  address admin;
  mapping (string => address) internal revenueAddressBlindBox;
  mapping (uint256=>string) internal boxNameByToken;
   bool public collectionConfig;
  uint256 public countCopy;
  mapping (uint256=> mapping( address => mapping(uint256 => bool))) _allowedCurrencies;
  IERC20 token;
  uint256[] allowedArray;

}


pragma solidity ^0.5.0;



contract FixPriceDex is Ownable, DexStorage {

   
  event SellNFT(address indexed from, address nft_a, uint256 tokenId, address seller, uint256 price, uint256 royalty, uint256 baseCurrency, uint256[] allowedCurrencies);
  event BuyNFT(address indexed from, address nft_a, uint256 tokenId, address buyer, uint256 price, uint256 baseCurrency, uint256 calculated, uint256 currencyType);
  event CancelSell(address indexed from, address nftContract, uint256 tokenId);
  event UpdatePrice(address indexed from, uint256 tokenId, uint256 newPrice, bool isDollar, address nftContract, uint256 baseCurrency, uint256[] allowedCurrencies);
  event BuyNFTNonCrypto( address indexed from, address nft_a, uint256 tokenId, string buyer, uint256 price, uint256 baseCurrency, uint256 calculated, uint256 currencyType);
  event SellNFTNonCrypto( address indexed from, address nft_a, uint256 tokenId, string seller, uint256 price, uint256 baseCurrency, uint256[] allowedCurrencies);
  event MintWithTokenURINonCrypto(address indexed from, string to, string tokenURI, address collection);
  event TransferPackNonCrypto(address indexed from, string to, uint256 tokenId);
  event updateTokenEvent(address to,uint256 tokenId, string uriT);
  event updateDiscount(uint256 amount);
  event Collection(address indexed creater, address collection, string name, string symbol);
  event CollectionsConfigured(address indexed xCollection, address factory);
  event MintWithTokenURI(address indexed collection, uint256 indexed tokenId, address minter, string tokenURI);


  modifier onlyAdminMinter() {

      require(msg.sender==admin);
      _;
  }
  function() external payable {}


  function updateSellDetail(uint256 tokenId) internal {

    (address seller, uint256 price, uint256 endTime, address bidder, uint256 minPrice, uint256 startTime, uint256 isDollar) = OldNFTDex.getSellDetail(tokenId);
    if(minPrice == 0){
      _saleTokens[tokenId][address(XNFT)].seller = seller;
      _saleTokens[tokenId][address(XNFT)].price = price;
      _saleTokens[tokenId][address(XNFT)].timestamp = endTime;
      if(isDollar == 1){
        _saleTokens[tokenId][address(XNFT)].isDollar = true;
      }
      _allowedCurrencies[tokenId][address(XNFT)][isDollar] = true;
      if(seller == nonCryptoNFTVault){
        string memory ownerId = OldNFTDex.getNonCryptoOwner(tokenId);
        _nonCryptoOwners[tokenId][address(XNFT)] = ownerId;
        _nonCryptoWallet[ownerId].Alia = OldNFTDex.getNonCryptoWallet(ownerId);
      }
    } else {
      _auctionTokens[tokenId][address(XNFT)].seller = seller;
      _auctionTokens[tokenId][address(XNFT)].nftContract = address(this);
      _auctionTokens[tokenId][address(XNFT)].minPrice = minPrice;
      _auctionTokens[tokenId][address(XNFT)].startTime = startTime;
      _auctionTokens[tokenId][address(XNFT)].endTime = endTime;
      _auctionTokens[tokenId][address(XNFT)].bidder = bidder;
      _auctionTokens[tokenId][address(XNFT)].bidAmount = price;
      if(seller == nonCryptoNFTVault ){
         string memory ownerId = OldNFTDex.getNonCryptoOwner(tokenId);
        _nonCryptoOwners[tokenId][address(XNFT)] = ownerId;
        _nonCryptoWallet[ownerId].Alia = OldNFTDex.getNonCryptoWallet(ownerId);
        _auctionTokens[tokenId][address(XNFT)].isDollar = true;
      }
    }
  }


  
  modifier isValid( address collection_) {

    require(_supportNft[collection_],"unsupported collection");
    _;
  }
  
  function sellNFT(address nft_a,uint256 tokenId, address seller, uint256 price, uint256 baseCurrency, uint256[] memory allowedCurrencies) isValid(nft_a) public{

    require(msg.sender == admin || (msg.sender == seller && INFT(nft_a).ownerOf(tokenId) == seller), "101");
    uint256 royality;
    require(baseCurrency <= 1, "121");
    bool isValid = true;
    for(uint256 i = 0; i< allowedCurrencies.length; i++){
      if(allowedCurrencies[i] > 1){
        isValid = false;
      }
      _allowedCurrencies[tokenId][nft_a][allowedCurrencies[i]] = true;
    }
    require(isValid,"122");
    _saleTokens[tokenId][nft_a].seller = seller;
    _saleTokens[tokenId][nft_a].price = price;
    _saleTokens[tokenId][nft_a].timestamp = now;
    _saleTokens[tokenId][nft_a].currencyType = baseCurrency;
    if(nft_a == address(XNFT)){
         msg.sender == admin ? XNFT.transferFromAdmin(seller, address(this), tokenId) : XNFT.transferFrom(seller, address(this), tokenId);        
          royality =  _tokenAuthors[tokenId][nft_a].royalty;
    } else {
      INFT(nft_a).transferFrom(seller, address(this), tokenId);
      royality =  0; // making it zero as not setting royality for user defined collection's NFT
    }
    
    emit SellNFT(msg.sender, nft_a, tokenId, seller, price, royality, baseCurrency, allowedCurrencies);
  }

  function MintAndSellNFT(address to, string memory tokenURI, uint256 price, string memory ownerId, uint256 royality, uint256 currencyType, uint256[] memory allowedCurrencies)  public { 

    uint256 tokenId;
     tokenId = XNFT.mintWithTokenURI(to,string(abi.encodePacked("https://ipfs.infura.io:5001/api/v0/cat?arg=", tokenURI)));
     emit MintWithTokenURI(address(XNFT), tokenId, msg.sender, tokenURI);
     if(royality > 0) _tokenAuthors[tokenId][address(XNFT)].royalty = royality;
     else _tokenAuthors[tokenId][address(XNFT)].royalty = 25;
     sellNFT(address(XNFT), tokenId, to, price, currencyType, allowedCurrencies);
     _tokenAuthors[tokenId][address(XNFT)]._address = msg.sender;
     if(msg.sender == admin) adminOwner[to] = true;
     if(msg.sender == nonCryptoNFTVault){
      emit MintWithTokenURINonCrypto(msg.sender, ownerId, tokenURI, address(XNFT));
      _nonCryptoOwners[tokenId][address(XNFT)] = ownerId;
      _tokenAuthors[tokenId][address(XNFT)].ownerId = ownerId;
      emit SellNFTNonCrypto(msg.sender, address(XNFT), tokenId, ownerId, price,  currencyType, allowedCurrencies);
    }
 }

 function Mint(address to, string memory tokenURI, uint256 royality, string memory ownerId)  public { 

    uint256 tokenId;
     tokenId = XNFT.mintWithTokenURI(to,string(abi.encodePacked("https://ipfs.infura.io:5001/api/v0/cat?arg=", tokenURI)));
     emit MintWithTokenURI(address(XNFT), tokenId, msg.sender, tokenURI);
     if(royality > 0) _tokenAuthors[tokenId][address(XNFT)].royalty = royality;
     else _tokenAuthors[tokenId][address(XNFT)].royalty = 25;
     _tokenAuthors[tokenId][address(XNFT)]._address = msg.sender;
     if(msg.sender == admin) adminOwner[to] = true;
     if(msg.sender == nonCryptoNFTVault){
      emit MintWithTokenURINonCrypto(msg.sender, ownerId, tokenURI, address(XNFT));
      _nonCryptoOwners[tokenId][address(XNFT)] = ownerId;
      _tokenAuthors[tokenId][address(XNFT)].ownerId = ownerId;
    }
 }


  function cancelSell(address nftContract, uint256 tokenId) isValid(nftContract) public{

        require(_saleTokens[tokenId][nftContract].seller == msg.sender || _auctionTokens[tokenId][nftContract].seller == msg.sender, "101");
    if(_saleTokens[tokenId][nftContract].seller != address(0)){
        INFT(nftContract).transferFrom(address(this), _saleTokens[tokenId][nftContract].seller, tokenId);
         delete _saleTokens[tokenId][nftContract];
    }else {
        require(_auctionTokens[tokenId][nftContract].bidder == address(0),"109");
        INFT(nftContract).transferFrom(address(this), msg.sender, tokenId);
        delete _auctionTokens[tokenId][nftContract];
    }
   
    emit CancelSell(msg.sender, nftContract, tokenId);      
  }

  function getSellDetail(address nftContract, uint256 tokenId) public view returns (address, uint256, uint256, address, uint256, uint256, bool, uint256) {

  fixedSell storage abc = _saleTokens[tokenId][nftContract];
  auctionSell storage def = _auctionTokens[tokenId][nftContract];
      if(abc.seller != address(0)){
        uint256 salePrice = abc.price;
        return (abc.seller, salePrice , abc.timestamp, address(0), 0, 0,abc.isDollar, abc.currencyType);
      }else{
          return (def.seller, def.bidAmount, def.endTime, def.bidder, def.minPrice,  def.startTime, def.isDollar, def.currencyType);
      }
  }
  function updatePrice(address nftContract, uint256 tokenId, uint256 newPrice, uint256 baseCurrency, uint256[] memory allowedCurrencies) isValid(nftContract)  public{

    require(msg.sender == _saleTokens[tokenId][nftContract].seller || _auctionTokens[tokenId][nftContract].seller == msg.sender, "110");
    require(newPrice > 0 ,"111");
    if(_saleTokens[tokenId][nftContract].seller != address(0)){
    require(newPrice > 0,"121");
    bool isValid = true;
    _allowedCurrencies[tokenId][nftContract][0]=false;
    _allowedCurrencies[tokenId][nftContract][1]=false;
    for(uint256 i = 0; i< allowedCurrencies.length; i++){
      if(allowedCurrencies[i] > 1){
        isValid = false;
      }
      _allowedCurrencies[tokenId][nftContract][allowedCurrencies[i]] = true;
    }
    require(isValid,"122");
        _saleTokens[tokenId][nftContract].price = newPrice;
        _saleTokens[tokenId][nftContract].currencyType = baseCurrency;
      }else{
        _auctionTokens[tokenId][nftContract].minPrice = newPrice;
        _auctionTokens[tokenId][nftContract].currencyType = baseCurrency;
      }
    emit UpdatePrice(msg.sender, tokenId, newPrice, false, nftContract, baseCurrency, allowedCurrencies); // added nftContract here as well
  }
  function calculatePrice(uint256 _price, uint256 base, uint256 currencyType, uint256 tokenId, address seller, address nft_a) public view returns(uint256 price) {

    price = _price;
     (uint112 _reserve0, uint112 _reserve1,) =LPBNB.getReserves();
    if(nft_a == address(XNFT) && _tokenAuthors[tokenId][address(XNFT)]._address == admin && adminOwner[seller] && adminDiscount > 0){ // getAuthor() can break generalization if isn't supported in Collection.sol. SOLUTION: royality isn't paying for user-defined collections
        price = _price- ((_price * adminDiscount) / 1000);
    }
    if(currencyType == 0 && base == 1){
      price = SafeMath.div(SafeMath.mul(price,SafeMath.mul(_reserve1,1000000000000)),_reserve0);
    } else if(currencyType == 1 && base == 0){
      price = SafeMath.div(SafeMath.mul(price,_reserve0),SafeMath.mul(_reserve1,1000000000000));
    }
    
  }
  function getPercentages(uint256 tokenId, address nft_a) public view returns(uint256 mainPerecentage, uint256 authorPercentage, address blindRAddress) {

    if(_tokenAuthors[tokenId][nft_a].royalty > 0 && nft_a == address(XNFT)) { // royality for XNFT only (non-user defined collection)
          mainPerecentage = SafeMath.sub(SafeMath.sub(1000,_tokenAuthors[tokenId][nft_a].royalty),platformPerecentage); //50
          authorPercentage = _tokenAuthors[tokenId][nft_a].royalty;
        } else {
          mainPerecentage = SafeMath.sub(1000, platformPerecentage);
        }
     blindRAddress = revenueAddressBlindBox[boxNameByToken[tokenId]];
    if(blindRAddress != address(0x0)){
          mainPerecentage = 865;
          authorPercentage =135;    
    }
  }
  function buyNFT(address nft_a,uint256 tokenId, string memory ownerId, uint256 currencyType) isValid(nft_a) public{

        fixedSell storage temp = _saleTokens[tokenId][nft_a];
        require(temp.price > 0, "108");
        require(_allowedCurrencies[tokenId][nft_a][currencyType] && currencyType != 1, "123");
        uint256 price = calculatePrice(temp.price, temp.currencyType, currencyType, tokenId, temp.seller, nft_a);
        (uint256 mainPerecentage, uint256 authorPercentage, address blindRAddress) = getPercentages(tokenId, nft_a);
        price = SafeMath.div(price,1000000000000);
        BUSD.transferFrom(msg.sender, platform, (price  / 1000) * platformPerecentage);
        if( nft_a == address(XNFT)) {
          BUSD.transferFrom(msg.sender,blindRAddress, (price  / 1000) *authorPercentage );
        }
        BUSD.transferFrom(msg.sender, temp.seller, (price  / 1000) * mainPerecentage); 
        clearMapping(tokenId, nft_a, temp.price, temp.currencyType, price, currencyType);
  }
  function buyNFTBnb(address nft_a,uint256 tokenId, string memory ownerId) isValid(nft_a) payable public{

        fixedSell storage temp = _saleTokens[tokenId][nft_a];
        require(_allowedCurrencies[tokenId][nft_a][1], "123");
        require(msg.sender != nonCryptoNFTVault, "125");
        require(temp.price > 0 , "108");
        uint256 price = calculatePrice(temp.price, temp.currencyType, 1, tokenId, temp.seller, nft_a);
        (uint256 mainPerecentage, uint256 authorPercentage, address blindRAddress) = getPercentages(tokenId, nft_a);
        uint256 before_bal = BNB.balanceOf(address(this));
        BNB.deposit.value(msg.value)();
        uint256 after_bal = BNB.balanceOf(address(this));
        uint256 depositAmount = after_bal - before_bal;
        require(price <= depositAmount, "NFT 108");
        if(blindRAddress == address(0x0)) {
         blindRAddress = _tokenAuthors[tokenId][nft_a]._address;
          bnbTransfer(platform, platformPerecentage, price);
        }
        if( nft_a == address(XNFT)) {
         bnbTransfer(blindRAddress, authorPercentage, price);
        }
        bnbTransfer(temp.seller, mainPerecentage, price);
        if(depositAmount - price > 0) bnbTransfer(msg.sender, 1000, (depositAmount - price));
        clearMapping(tokenId, nft_a, temp.price, temp.currencyType, price, 1 );
        
  }  

  function clearMapping(uint256 tokenId, address nft_a, uint256 price, uint256 baseCurrency, uint256 calcultated, uint256 currencyType ) internal {

      INFT(nft_a).transferFrom(address(this), msg.sender, tokenId);
        delete _saleTokens[tokenId][nft_a];
        for(uint256 i = 0; i <=2 ; i++) {
            _allowedCurrencies[tokenId][nft_a][i] = false;
        }
        emit BuyNFT(msg.sender, nft_a, tokenId, msg.sender, price, baseCurrency, calcultated, currencyType);
  }
    function bnbTransfer(address _address, uint256 percentage, uint256 price) public {

      address payable newAddress = address(uint160(_address));
      uint256 initialBalance;
      uint256 newBalance;
      initialBalance = address(this).balance;
      BNB.withdraw((price / 1000) * percentage);
      newBalance = address(this).balance.sub(initialBalance);
      newAddress.transfer(newBalance);
  }

}