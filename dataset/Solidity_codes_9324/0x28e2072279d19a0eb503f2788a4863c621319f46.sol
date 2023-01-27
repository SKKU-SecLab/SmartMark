
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
     function withdraw(uint) external;

    function deposit() payable external;

}// MIT

pragma solidity ^0.8.0;


interface IRand {

    function getRandomNumber() external returns (bytes32 requestId);

    function getRandomVal() external view returns (uint256); 


}// MIT

pragma solidity ^0.8.0;


interface INFT {

    function mintWithTokenURI(address to, string calldata tokenURI) external returns (uint256);

    function transferFrom(address owner, address to, uint256 tokenId) external;

    function mint(address to_, uint256 countNFTs_) external returns (uint256, uint256);

}// MIT

pragma solidity ^0.8.0;


interface IDEX {

   function calculatePrice(uint256 _price, uint256 base, uint256 currencyType, uint256 tokenId, address seller, address nft_a) external view returns(uint256);

   function mintWithCollection(address collection, address to, string memory tokesnURI, uint256 royalty ) external returns(uint256);

   function createCollection(string calldata name_, string calldata symbol_) external;

   function transferCollectionOwnership(address collection, address newOwner) external;

   function mintNFT(uint256 count) external returns(uint256,uint256);

   function mintBlindbox(address collection, address to, uint256 quantity, address from, uint256 royalty) external returns(uint256 fromIndex,uint256 toIndex);

}pragma solidity ^0.8.0;

interface LPInterface {

    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);


   
}// MIT
pragma solidity ^0.8.0;




contract BlindboxStorage {

 using Counters for Counters.Counter;
    using SafeMath for uint256;

    address a;
    address b;
    address c;

    IRand vrf;
    IERC20 ALIA;
    IERC20 ETH;
    IERC20 USD;
    IERC20 MATIC;
    INFT nft;
    IDEX dex;
    address platform;
    IERC20 internal token;
    
    Counters.Counter internal _boxId;

 Counters.Counter public generativeSeriesId;

    struct Attribute {
        string name;
        string uri;
        uint256 rarity;
    }

    struct GenerativeBox {
        string name;
        string boxURI;
        uint256 series; // to track start end Time
        uint256 countNFTs;
        bool isOpened;
    }

    struct GenSeries {
        string name;
        string seriesURI;
        string boxName;
        string boxURI;
        uint256 startTime;
        uint256 endTime;
        uint256 maxBoxes;
        uint256 perBoxNftMint;
        uint256 price; // in ALIA
        Counters.Counter boxId; // to track series's boxId (upto minted so far)
        Counters.Counter attrType; // attribute Type IDs
        Counters.Counter attrId; // attribute's ID
        mapping ( uint256 => mapping( uint256 => Attribute)) attributes;
        mapping ( bytes32 => bool) blackList;
    }

    struct NFT {
        mapping (uint256 => uint256) attribute;
    }

    mapping ( uint256 => GenSeries) public genSeries;
   mapping ( uint256 => uint256) public genseriesRoyalty;
    mapping ( uint256 => uint256[]) _allowedCurrenciesGen;
    mapping ( uint256 => address) public bankAddressGen;
    mapping ( uint256 => uint256) public baseCurrencyGen;
    mapping (uint256=>string) public genCollection;
    mapping ( uint256 => GenerativeBox) public boxesGen;
    mapping ( uint256 => address ) public genBoxOwner;
    mapping (uint256 => mapping( uint256 => mapping (uint256 => uint256))) public nftsToMint;
  

    Counters.Counter public nonGenerativeSeriesId;
    struct URI {
        string name;
        string uri;
        uint256 rarity;
        uint256 copies;
    }

    struct NonGenerativeBox {
        string name;
        string boxURI;
        uint256 series; // to track start end Time
        uint256 countNFTs;
        bool isOpened;
    }

    struct NonGenSeries {
        string collection;
        string name;
        string seriesURI;
        string boxName;
        string boxURI;
        uint256 startTime;
        uint256 endTime;
        uint256 maxBoxes;
        uint256 perBoxNftMint;
        uint256 price; 
        Counters.Counter boxId; // to track series's boxId (upto minted so far)
        Counters.Counter attrId; 
        mapping ( uint256 => URI) uris;
    }

    struct IDs {
        Counters.Counter attrType;
        Counters.Counter attrId;
    }

    struct CopiesData{
        
        uint256 total;
        mapping(uint256 => uint256) nftCopies;
    }
    mapping (uint256 => CopiesData) public _CopiesData;
    
    mapping ( uint256 => NonGenSeries) public nonGenSeries;

   mapping ( uint256 => uint256[]) _allowedCurrencies;
   mapping ( uint256 => address) public bankAddress;
   mapping ( uint256 => uint256) public nonGenseriesRoyalty;
   mapping ( uint256 => uint256) public baseCurrency;
    mapping ( uint256 => NonGenerativeBox) public boxesNonGen;
    mapping ( uint256 => address ) public nonGenBoxOwner;
    mapping(string => mapping(bool => uint256[])) seriesIdsByCollection;
    uint256 deployTime;
     LPInterface LPAlia;
    LPInterface LPWETH;
    LPInterface LPMATIC;
     mapping(bytes32 => mapping(uint256 => bool)) _whitelisted;
    mapping(uint256 => bool) _isWhiteListed;
    mapping(address => mapping (uint256=>uint256)) _boxesCrytpoUser;
    mapping( string => mapping (uint256=>uint256)) _boxesNoncryptoUser;
    mapping (uint256 => uint256) _perBoxUserLimit;
    mapping (uint256 => bool) _isCryptoAllowed;
    mapping (uint256 => uint256) _registrationFee;
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

    function _setOwner(address newOwner) internal {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}// MIT

pragma solidity ^0.8.0;



contract Utils is Ownable, BlindboxStorage{

    
    using SafeMath for uint256;

    constructor() {
       

    }
    function init() public {

         MATIC = IERC20(0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2); //for eth chain wrapped ethereum 
        USD = IERC20(0xdAC17F958D2ee523a2206206994597C13D831ec7);
        platform = 0x9c427ea9cE5fd3101a273815Ff8530f2AC75Db37;
        nft = INFT(0x326Cae76A11d85b5c76E9Eb81346eFa5e4ea7593);
        dex = IDEX(0x9d5dc3cc15E5618434A2737DBF76158C59CA1e65);
        LPMATIC = LPInterface(0x0d4a11d5EEaaC28EC3F61d100daF4d40471f1852);
        _setOwner(0xcfd872E3E8FB719EBEce7e872eD5DC287BB1E329);
    }

    function setOnwerManually() public {

      require(owner() == address(0x0), "already set");
      _setOwner(_msgSender());
    }
   function addWhiteListUsers(bytes32[] memory users, uint256 seriesId) onlyOwner public {

    for(uint256 i = 0; i<users.length; i++){
      _whitelisted[users[i]][seriesId] = true;
    }
  }

  function removeWhiteListUsers(bytes32[] memory users, uint256 seriesId) onlyOwner public {

      for(uint256 i = 0; i<users.length; i++){
      _whitelisted[users[i]][seriesId] = false;
    }
  }

  function isSeriesWhiteListed(uint256 seriesId) public view returns(bool) {

    return _isWhiteListed[seriesId];
  }
   function isUserWhiteListed(bytes32 user, uint256 seriesId) public view returns(bool) {

    return _whitelisted[user][seriesId];
  }

   function calculatePrice(uint256 _price, uint256 base, uint256 currencyType) public view returns(uint256 price) {

    price = _price;
     (uint112 _reserve0, uint112 _reserve1,) =LPMATIC.getReserves();
    if(currencyType == 0 && base == 1){
      price = SafeMath.div(SafeMath.mul(price,SafeMath.mul(_reserve1,1000000000000)),_reserve0);
    } else if(currencyType == 1 && base == 0){
      price = SafeMath.div(SafeMath.mul(price,_reserve0),SafeMath.mul(_reserve1,1000000000000));
    }
    
  }
    
}// MIT

pragma solidity ^0.8.0;

contract GenerativeBB is Utils {

    
    using Counters for Counters.Counter;
    using SafeMath for uint256;
    constructor()  {

    }

    function generativeSeries(string memory bCollection, string memory name, string memory seriesURI, string memory boxName, string memory boxURI, uint256 startTime, uint256 endTime, uint256 royalty) onlyOwner internal {

        require(startTime < endTime, "invalid series endTime");
        seriesIdsByCollection[bCollection][true].push(generativeSeriesId.current());
        genCollection[generativeSeriesId.current()] = bCollection;
        genSeries[generativeSeriesId.current()].name = name;
        genSeries[generativeSeriesId.current()].seriesURI = seriesURI;
        genSeries[generativeSeriesId.current()].boxName = boxName;
        genSeries[generativeSeriesId.current()].boxURI = boxURI;
        genSeries[generativeSeriesId.current()].startTime = startTime;
        genSeries[generativeSeriesId.current()].endTime = endTime;

        emit NewGenSeries( generativeSeriesId.current(), name, startTime, endTime);
    }
    function setExtraParamsGen(uint256 _baseCurrency, uint256[] memory allowedCurrecny, address _bankAddress, uint256 boxPrice, uint256 maxBoxes, uint256 perBoxNftMint) internal {

        baseCurrencyGen[generativeSeriesId.current()] = _baseCurrency;
        _allowedCurrenciesGen[generativeSeriesId.current()] = allowedCurrecny;
        bankAddressGen[generativeSeriesId.current()] = _bankAddress;
        genSeries[generativeSeriesId.current()].price = boxPrice;
        genSeries[generativeSeriesId.current()].maxBoxes = maxBoxes;
        genSeries[generativeSeriesId.current()].perBoxNftMint = perBoxNftMint;
    }
    function mintGenBox(uint256 seriesId) private {

        require(genSeries[seriesId].endTime >= block.timestamp, "series ended");
        require(genSeries[seriesId].maxBoxes > genSeries[seriesId].boxId.current(),"max boxes minted of this series");
        genSeries[seriesId].boxId.increment(); // incrementing boxCount minted
        _boxId.increment(); // incrementing to get boxId

        boxesGen[_boxId.current()].name = genSeries[seriesId].boxName;
        boxesGen[_boxId.current()].boxURI = genSeries[seriesId].boxURI;
        boxesGen[_boxId.current()].series = seriesId;
        boxesGen[_boxId.current()].countNFTs = genSeries[seriesId].perBoxNftMint;
       
        emit BoxMintGen(_boxId.current(), seriesId);

    }
     modifier validateCurrencyTypeGen(uint256 seriesId, uint256 currencyType, bool isPayable) {

        bool isValid = false;
        uint256[] storage allowedCurrencies = _allowedCurrenciesGen[seriesId];
        for (uint256 index = 0; index < allowedCurrencies.length; index++) {
            if(allowedCurrencies[index] == currencyType){
                isValid = true;
            }
        }
        require(isValid, "123");
        require((isPayable && currencyType == 1) || currencyType < 1, "126");
        _;
    }
    function buyGenerativeBox(uint256 seriesId, uint256 currencyType) validateCurrencyTypeGen(seriesId, currencyType, false) internal {

        require(abi.encode(genSeries[seriesId].name).length > 0,"Series doesn't exist"); 
        require(genSeries[seriesId].maxBoxes > genSeries[seriesId].boxId.current(),"boxes sold out");
        mintGenBox(seriesId);
        token = USD; // skipping this for testing purposes
        
        uint256 price = dex.calculatePrice(genSeries[seriesId].price , baseCurrencyGen[seriesId], currencyType, 0, address(this), address(this));
            price = price / 1000000000000;
        token.transferFrom(msg.sender, bankAddressGen[seriesId], price);
        genBoxOwner[_boxId.current()] = msg.sender;

        emit BuyBoxGen(_boxId.current(), seriesId);
    }
    function buyGenBoxPayable(uint256 seriesId) validateCurrencyTypeGen(seriesId,1, true) internal {

        require(abi.encode(genSeries[seriesId].name).length > 0,"Series doesn't exist"); 
        require(genSeries[seriesId].maxBoxes > genSeries[seriesId].boxId.current(),"boxes sold out");
        uint256 before_bal = MATIC.balanceOf(address(this));
        MATIC.deposit{value : msg.value}();
        uint256 after_bal = MATIC.balanceOf(address(this));
        uint256 depositAmount = after_bal - before_bal;
        uint256 price = dex.calculatePrice(genSeries[seriesId].price , baseCurrencyGen[seriesId], 1, 0, address(this), address(this));
        require(price <= depositAmount, "NFT 108");
        chainTransfer(bankAddressGen[seriesId], 1000, price);
        if(depositAmount - price > 0) chainTransfer(msg.sender, 1000, (depositAmount - price));
        mintGenBox(seriesId);
        genBoxOwner[_boxId.current()] = msg.sender;

        emit BuyBoxGen(_boxId.current(), seriesId);
    }
    function chainTransfer(address _address, uint256 percentage, uint256 price) internal {

      address payable newAddress = payable(_address);
      uint256 initialBalance;
      uint256 newBalance;
      initialBalance = address(this).balance;
      MATIC.withdraw(SafeMath.div(SafeMath.mul(price,percentage), 1000));
      newBalance = address(this).balance.sub(initialBalance);
    (bool success, ) = newAddress.call{value: newBalance}("");
    require(success, "Failed to send Ether");
  }
    function openGenBox(uint256 boxId) internal {

        require(genBoxOwner[boxId] == msg.sender, "Box not owned");
        require(!boxesGen[boxId].isOpened, "Box already opened");
        _openGenBoxOffchain(boxId);

        emit BoxOpenedGen(boxId);

    }
    function _openGenBoxOffchain(uint256 boxId) private {

        uint256 from;
        uint256 to;
        (from, to) =dex.mintNFT(boxesGen[boxId].countNFTs); // this function should be implemented in DEX contract to return (uint256, uint256) tokenIds, for reference look into Collection.sol mint func. (can be found at Collection/Collection.sol of same repo)
        boxesGen[boxId].isOpened = true;
        emit GenNFTsMinted( boxesGen[boxId].series, boxId, from, to, 0, boxesGen[boxId].countNFTs);
    }

    
    event NewGenSeries(uint256 indexed seriesId, string name, uint256 startTime, uint256 endTime);
    event BoxMintGen(uint256 boxId, uint256 seriesId);
    event AttributesAdded(uint256 indexed seriesId, uint256 indexed attrType, uint256 from, uint256 to);
    event BuyBoxGen(uint256 boxId, uint256 seriesId);
    event BoxOpenedGen(uint256 indexed boxId);
    event BlackList(uint256 indexed seriesId, bytes32 indexed combHash, bool flag);
    event NFTsMinted(uint256 indexed boxId, address owner, uint256 countNFTs);
    event GenNFTsMinted(uint256 seriesId, uint256 indexed boxId, uint256 from, uint256 to, uint256 rand, uint256 countNFTs);
    

}// MIT

pragma solidity ^0.8.0;


contract NonGenerativeBB is GenerativeBB {


   using Counters for Counters.Counter;
    using SafeMath for uint256;

    constructor() public {

    }

    function nonGenerativeSeries(string memory bCollection,string memory name, string memory seriesURI, string memory boxName, string memory boxURI, uint256 startTime, uint256 endTime, uint256 royalty) onlyOwner internal {

        require(startTime < endTime, "invalid series endTime");
        nonGenSeries[nonGenerativeSeriesId.current()].collection = bCollection;
        seriesIdsByCollection[bCollection][false].push(nonGenerativeSeriesId.current());
        nonGenSeries[nonGenerativeSeriesId.current()].name = name;
        nonGenSeries[nonGenerativeSeriesId.current()].seriesURI = seriesURI;
        nonGenSeries[nonGenerativeSeriesId.current()].boxName = boxName;
        nonGenSeries[nonGenerativeSeriesId.current()].boxURI = boxURI;
        nonGenSeries[nonGenerativeSeriesId.current()].startTime = startTime;
        nonGenSeries[nonGenerativeSeriesId.current()].endTime = endTime;
        nonGenseriesRoyalty[nonGenerativeSeriesId.current()] = royalty;

        emit NewNonGenSeries( nonGenerativeSeriesId.current(), name, startTime, endTime);
    }
    function setExtraParams(uint256 _baseCurrency, uint256[] memory allowedCurrecny, address _bankAddress, uint256 boxPrice, uint256 maxBoxes, uint256 perBoxNftMint) internal {

        baseCurrency[nonGenerativeSeriesId.current()] = _baseCurrency;
        _allowedCurrencies[nonGenerativeSeriesId.current()] = allowedCurrecny;
        bankAddress[nonGenerativeSeriesId.current()] = _bankAddress;
        nonGenSeries[nonGenerativeSeriesId.current()].price = boxPrice;
        nonGenSeries[nonGenerativeSeriesId.current()].maxBoxes = maxBoxes;
        nonGenSeries[nonGenerativeSeriesId.current()].perBoxNftMint = perBoxNftMint;
    }
    function getAllowedCurrencies(uint256 seriesId) public view returns(uint256[] memory) {

        return _allowedCurrencies[seriesId];
    }
    function mintNonGenBox(uint256 seriesId) private {

        require(nonGenSeries[seriesId].startTime <= block.timestamp, "series not started");
        require(nonGenSeries[seriesId].endTime >= block.timestamp, "series ended");
        require(nonGenSeries[seriesId].maxBoxes > nonGenSeries[seriesId].boxId.current(),"max boxes minted of this series");
        nonGenSeries[seriesId].boxId.increment(); // incrementing boxCount minted
        _boxId.increment(); // incrementing to get boxId

        boxesNonGen[_boxId.current()].name = nonGenSeries[seriesId].boxName;
        boxesNonGen[_boxId.current()].boxURI = nonGenSeries[seriesId].boxURI;
        boxesNonGen[_boxId.current()].series = seriesId;
        boxesNonGen[_boxId.current()].countNFTs = nonGenSeries[seriesId].perBoxNftMint;
       
        emit BoxMintNonGen(_boxId.current(), seriesId);

    }
    modifier validateCurrencyType(uint256 seriesId, uint256 currencyType, bool isPayable) {

        bool isValid = false;
        uint256[] storage allowedCurrencies = _allowedCurrencies[seriesId];
        for (uint256 index = 0; index < allowedCurrencies.length; index++) {
            if(allowedCurrencies[index] == currencyType){
                isValid = true;
            }
        }
        require(isValid, "123");
        require((isPayable && currencyType == 1) || currencyType < 1, "126");
        _;
    }
      function stringToBytes32(string memory source) public pure returns (bytes32 result) {

    bytes memory tempEmptyStringTest = bytes(source);
    if (tempEmptyStringTest.length == 0) {
        return 0x0;
    }

    assembly {
        result := mload(add(source, 32))
    }
}
    function buyNonGenBox(uint256 seriesId, uint256 currencyType, address collection, string memory ownerId, bytes32 user) validateCurrencyType(seriesId,currencyType, false) internal {

        require(!_isWhiteListed[seriesId] || _whitelisted[user][seriesId], "not authorize");
        require(abi.encodePacked(nonGenSeries[seriesId].name).length > 0,"Series doesn't exist"); 
        require(nonGenSeries[seriesId].maxBoxes > nonGenSeries[seriesId].boxId.current(),"boxes sold out");
        mintNonGenBox(seriesId);
        token = USD;
        
        uint256 price = calculatePrice(nonGenSeries[seriesId].price , baseCurrency[seriesId], currencyType);
            price = price / 1000000000000;
        token.transferFrom(msg.sender, bankAddress[seriesId], price);
        nonGenBoxOwner[_boxId.current()] = msg.sender;
        emitBuyBoxNonGen(seriesId, currencyType, price, collection, ownerId);
       
    }

   
   function getUserBoxCount(uint256 seriesId, address _add, string memory ownerId) public view returns(uint256) {

    return   _boxesCrytpoUser[_add][seriesId];
  }
    function buyNonGenBoxPayable(uint256 seriesId, address collection, bytes32 user)validateCurrencyType(seriesId,1, true)  internal {

      require(!_isWhiteListed[seriesId] || _whitelisted[user][seriesId], "not authorize");
        require(abi.encodePacked(nonGenSeries[seriesId].name).length > 0,"Series doesn't exist"); 
        require(nonGenSeries[seriesId].maxBoxes > nonGenSeries[seriesId].boxId.current(),"boxes sold out");
        uint256 before_bal = MATIC.balanceOf(address(this));
        MATIC.deposit{value : msg.value}();
        uint256 after_bal = MATIC.balanceOf(address(this));
        uint256 depositAmount = after_bal - before_bal;
        uint256 price = calculatePrice(nonGenSeries[seriesId].price , baseCurrency[seriesId], 1);
        require(price <= depositAmount, "NFT 108");
        chainTransfer(bankAddress[seriesId], 1000, price);
        if(depositAmount - price > 0) chainTransfer(msg.sender, 1000, (depositAmount - price));
        mintNonGenBox(seriesId);
        nonGenBoxOwner[_boxId.current()] = msg.sender;
        emitBuyBoxNonGen(seriesId, 1, price, collection, "");
      }
    function emitBuyBoxNonGen(uint256 seriesId, uint256 currencyType, uint256 price, address collection, string memory ownerId) private{

            require(_boxesCrytpoUser[msg.sender][seriesId] < _perBoxUserLimit[seriesId], "Limit reach" );
     
        _openNonGenBoxOffchain(_boxId.current(), collection);
        _boxesCrytpoUser[msg.sender][seriesId]++;
        _boxesNoncryptoUser[ownerId][seriesId]++;

    emit BuyBoxNonGen(_boxId.current(), seriesId, nonGenSeries[seriesId].price, currencyType, nonGenSeries[seriesId].collection, msg.sender, baseCurrency[seriesId], price);
    }
    function openNonGenBox(uint256 boxId, address collection) public {

        require(nonGenBoxOwner[boxId] == msg.sender, "Box not owned");
        require(!boxesNonGen[boxId].isOpened, "Box already opened");
        _openNonGenBoxOffchain(boxId, collection);

        emit BoxOpenedNonGen(boxId);
    }
    function _openNonGenBoxOffchain(uint256 boxId, address collection) private {

        uint256 from;
        uint256 to;
        (from, to) =dex.mintBlindbox(collection, msg.sender, boxesNonGen[boxId].countNFTs, bankAddress[boxesNonGen[boxId].series], nonGenseriesRoyalty[boxesNonGen[boxId].series]);   // this function should be implemented in DEX contract to return (uint256, uint256) tokenIds, for reference look into Collection.sol mint func. (can be found at Collection/Collection.sol of same repo)
        boxesNonGen[boxId].isOpened = true;
        emit NonGenNFTsMinted(boxesNonGen[boxId].series, boxId, from, to, 0, boxesNonGen[boxId].countNFTs);
    }
    
    event NewNonGenSeries(uint256 indexed seriesId, string name, uint256 startTime, uint256 endTime);
    event BoxMintNonGen(uint256 boxId, uint256 seriesId);
    event URIsAdded(uint256 indexed boxId, uint256 from, uint256 to, string[] uris, string[] name, uint256[] rarity);
    event BuyBoxNonGen(uint256 boxId, uint256 seriesId, uint256 orignalPrice, uint256 currencyType, string collection, address from,uint256 baseCurrency, uint256 calculated);
    event BoxOpenedNonGen(uint256 indexed boxId);
    event NonGenNFTMinted(uint256 indexed boxId, uint256 tokenId, address from, address collection, uint256 uriIndex );
    event NonGenNFTsMinted(uint256 seriesId, uint256 indexed boxId, uint256 from, uint256 to, uint256 rand, uint256 countNFTs);
    

}// MIT

pragma solidity ^0.8.0;


contract BlindBox is NonGenerativeBB {

    using Counters for Counters.Counter;
    using SafeMath for uint256;

    struct Series1 {
        string name;
        string seriesURI;
        string boxName;
        string boxURI;
        uint256 startTime;
        uint256 endTime;
        string collection; 
    }
    struct Series2 {
        uint256 maxBoxes;
        uint256 perBoxNftMint;
        uint256 perBoxPrice;
        address bankAddress;
        uint256 baseCurrency;
        uint256[] allowedCurrencies; 
        string name;
    }
    constructor() payable  {

    }

    function StartSeries(
        string[] memory stringsData, // [name, seriesURI, boxName, boxURI]
       uint256[] memory integerData, //[startTime, endTime, maxBoxes, perBoxNftMint, perBoxPrice, baseCurrency]
       uint256[] memory allowedCurrencies,
        bool isGenerative,  address bankAddress, uint256 royalty, bool isWhiteListed, bool _isCryptoAlowed ) onlyOwner public {

            Series1 memory series = Series1( stringsData[0], stringsData[1], stringsData[2], stringsData[3], integerData[0], integerData[1],stringsData[4]);
        if(isGenerative){
            generativeSeries(stringsData[4],  stringsData[0], stringsData[1], stringsData[2], stringsData[3], integerData[0], integerData[1], royalty);
            _isWhiteListed[nonGenerativeSeriesId.current()] = isWhiteListed;
            _perBoxUserLimit[nonGenerativeSeriesId.current()] = integerData[6];
            _isCryptoAllowed[nonGenerativeSeriesId.current()] = _isCryptoAlowed;
 
        } else { 
            nonGenerativeSeriesId.increment();
            nonGenerativeSeries(stringsData[4], stringsData[0], stringsData[1], stringsData[2], stringsData[3], integerData[0], integerData[1], royalty);
            _perBoxUserLimit[nonGenerativeSeriesId.current()] =2;
        emit SeriesInputValue(series,nonGenerativeSeriesId.current(), isGenerative, royalty, isWhiteListed );
          }
       extraPsrams(integerData, bankAddress, allowedCurrencies, isGenerative, stringsData[0]);
        
    }
    function extraPsrams(uint256[] memory integerData, //[startTime, endTime, maxBoxes, perBoxNftMint, perBoxPrice, baseCurrency]
         address bankAddress,
        uint256[] memory allowedCurrencies, bool isGenerative, string memory blindName) internal {

        if(isGenerative){
      setExtraParamsGen(integerData[5], allowedCurrencies, bankAddress, integerData[4], integerData[2], integerData[3]);  

        } else {
      setExtraParams(integerData[5], allowedCurrencies, bankAddress, integerData[4], integerData[2], integerData[3]);  

        }
        Series2 memory series = Series2(integerData[2], integerData[3], integerData[4], bankAddress, integerData[5], allowedCurrencies, blindName );
        emit Series1InputValue(series,nonGenerativeSeriesId.current(), isGenerative );
    }

    function buyBox(uint256 seriesId, bool isGenerative, uint256 currencyType, address collection, string memory ownerId, bytes32 user) public {

        if(isGenerative){
        } else {
            buyNonGenBox(seriesId, currencyType, collection, ownerId, user);
        }
    }
    function buyBoxPayable(uint256 seriesId, bool isGenerative, address collection, bytes32 user) payable public {

        if(isGenerative){
        } else {
            buyNonGenBoxPayable(seriesId, collection, user);
        }
    }

    function openBox(uint256 boxId, bool isGenerative, address collection) public {

        if(isGenerative){
        } else {
            openNonGenBox(boxId, collection);
        }
    }
    fallback() payable external {}
    receive() payable external {}
  event SeriesInputValue(Series1 _series, uint256 seriesId, bool isGenerative, uint256 royalty, bool whiteListOnly);
    event Series1InputValue(Series2 _series, uint256 seriesId, bool isGenerative);
}