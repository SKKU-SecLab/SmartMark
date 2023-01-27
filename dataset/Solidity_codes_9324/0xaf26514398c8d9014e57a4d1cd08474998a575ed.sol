
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

}// MIT

pragma solidity ^0.8.0;


interface IDEX {

   function calculatePrice(uint256 _price, uint256 base, uint256 currencyType, uint256 tokenId, address seller, address nft_a) external view returns(uint256);

   function mintWithCollection(address collection, address to, string memory tokesnURI, uint256 royalty ) external returns(uint256);

   function createCollection(string calldata name_, string calldata symbol_) external;

   function transferCollectionOwnership(address collection, address newOwner) external;

}pragma solidity ^0.8.0;




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
    mapping (uint256=>address) public genCollection;
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
        address collection;
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
    mapping(address => mapping(bool => uint256[])) seriesIdsByCollection;
    uint256 deployTime;
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
    address internal gasFeeCollector;
    uint256 internal gasFee;
    constructor() {
       

    }
    function init() public {

         MATIC = IERC20(0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2); //for eth chain wrapped ethereum 
        USD = IERC20(0xdAC17F958D2ee523a2206206994597C13D831ec7);
        platform = 0x9c427ea9cE5fd3101a273815Ff8530f2AC75Db37;
        nft = INFT(0x54994ba4b4A42297B3B88E27185CDe1F51DcA288);
        dex = IDEX(0x9d5dc3cc15E5618434A2737DBF76158C59CA1e65);
        _setOwner(_msgSender());
    }
    function setVRF(address _vrf) onlyOwner public {

        vrf = IRand(_vrf);
        emit VRF(address(vrf));
    }
    function setGaseFeeData(address _address, uint256 gasFeeInUSDT ) onlyOwner public  {

       gasFeeCollector = _address;
       gasFee = gasFeeInUSDT;
    }
    function getRand() internal returns(uint256) {


        vrf.getRandomNumber();
        uint256 rndm = vrf.getRandomVal();
        return rndm.mod(100); // taking to limit value within range of 0 - 99
    }
    function blindCreateCollection(string memory name_, string memory symbol_) onlyOwner public {

        dex.createCollection(name_, symbol_);
    }

    function transferOwnerShipCollection(address[] memory collections, address newOwner) onlyOwner public {

       for (uint256 index = 0; index < collections.length; index++) {
            dex.transferCollectionOwnership(collections[index], newOwner);
       }
    }

    event VRF(address indexed vrf);
    
}// MIT

pragma solidity ^0.8.0;

contract GenerativeBB is Utils {

    
    using Counters for Counters.Counter;
    using SafeMath for uint256;
    constructor()  {

    }


    function setAttributes(uint256 seriesId, uint256 attrType, string[] memory name, string[] memory uri, uint256[] memory rarity) onlyOwner public {

        uint256 totalRarity = 0;
        if(attrType == 0){
            genSeries[seriesId].attrType.increment(); // should do +=
            attrType = genSeries[seriesId].attrType.current();
        }else {
            require(abi.encodePacked(genSeries[seriesId].attributes[attrType][1].name).length != 0,"attrType doesn't exists, please pass attrType=0 for new attrType");
        }
        require(name.length == uri.length && name.length == rarity.length, "attributes length mismatched");
        Counters.Counter storage _attrId = genSeries[seriesId].attrId; // need to reset so rarity sum calc could be exact to avoid rarity issues
        _attrId.reset(); // reseting attrIds to overwrite
        uint256 from = _attrId.current() + 1;
        for (uint256 index = 0; index < name.length; index++) {
            totalRarity = totalRarity + rarity[index];
            require( totalRarity <= 100, "Rarity sum of attributes can't exceed 100");
            _attrId.increment();
            genSeries[seriesId].attributes[attrType][_attrId.current()] = Attribute(name[index], uri[index], rarity[index]);
        }

        require( totalRarity == 100, "Rarity sum of attributes shoud be equal to 100");
        emit AttributesAdded(seriesId, attrType,from, _attrId.current());
    }
    function generativeSeries(address bCollection, string memory name, string memory seriesURI, string memory boxName, string memory boxURI, uint256 startTime, uint256 endTime, uint256 royalty) onlyOwner internal {

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
       token = USD;
        
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
        _openGenBox(boxId);

        emit BoxOpenedGen(boxId);

    }
    event Msg(string msg);
    event Value(uint256 value);
    function _openGenBox(uint256 boxId) private {

        uint256 sId = boxesGen[boxId].series;
        uint256 attrType = genSeries[sId].attrType.current();
        
        uint256 rand = getRand(); // should get random number within range of 100
        uint256 i;
        uint256 j;
        bytes32 combHash;
        uint256 rand1;
        for ( i = 1; i <= boxesGen[boxId].countNFTs; i++) {
            emit Msg("into NFT loop");
            combHash = bytes32(0); // reset combHash for next iteration of possible NFT
            
            for ( j = 1; j <= attrType; j++){
                emit Msg("into attrType loop");
                rand1 = uint256(keccak256(abi.encodePacked(block.coinbase, rand, msg.sender, i,j))).mod(100); // to keep each iteration further randomize and reducing fee of invoking VRF on each iteration.
                emit Value(rand1);
                nftsToMint[boxId][i][j] = getRandAttr(sId, boxId, j, rand1);
                combHash = keccak256(abi.encode(combHash, nftsToMint[boxId][i][j])); // TODO: need to test if hash appending work same like hashing with all values at once. [DONE]
            }
            if( isBlackListed(sId, combHash)){
                i = i - 1;
                j = j - 1;
                rand = getRand(); // getting new random number to skip blacklisted comb on same iteration.
            }
        }

        boxesGen[boxId].isOpened = true;
    }

    function getRandAttr(uint256 seriesId, uint256 boxId, uint256 attrType, uint256 rand) private returns(uint256) {

        uint256[] memory attrs = new uint256[](100);
        Attribute memory attr;
        uint256 occurence;
        uint256 i = 0;
        for (uint256 attrId = 1; attrId <= genSeries[seriesId].attrId.current(); attrId++) {
            attr = genSeries[seriesId].attributes[attrType][attrId];
            occurence = attr.rarity;
            for (uint256 index = 0; index < occurence; index++) {
                attrs[i] = attrId;
                i++;
                if( i > rand ){
                    break;
                }
            }
        }
        return attrs[rand];
    }

    function isBlackListed(uint256 seriesId, bytes32 combHash) public view returns(bool) {

        return genSeries[seriesId].blackList[combHash];
    }
    function getCombHash(uint256 seriesId, uint256 boxId, uint256[] memory attrTypes, uint256[] memory attrIds) public pure returns(bytes32) {

        bytes32 combHash = bytes32(0);
            for (uint256 j = 0; j < attrIds.length; j++) {
                combHash = keccak256(abi.encode(combHash,attrIds[j]));
            }
            
        return combHash;
    }
    function blackListAttribute(uint256 seriesId, bytes32 combHash, bool flag) public onlyOwner {

        genSeries[seriesId].blackList[combHash] = flag;
        emit BlackList(seriesId, combHash, flag);
    }
    function mintGenerativeNFTs(address collection, uint256 boxId, string[] memory uris) public onlyOwner {

        require(nftsToMint[boxId][1][1] > 0, "boxId isn't opened");
        require(boxesGen[boxId].countNFTs == uris.length, "insufficient URIs to mint");
         for (uint256 i = 0; i < uris.length; i++) {
            dex.mintWithCollection(collection, genBoxOwner[boxId], uris[i], genseriesRoyalty[boxesGen[boxId].series]);
         }
         uint256 countNFTs = boxesGen[boxId].countNFTs;
         delete boxesGen[boxId]; // deleting box to avoid duplicate NFTs mint
         emit NFTsMinted(boxId, genBoxOwner[boxId], countNFTs);
    }
    function getAttributes(uint256 seriesId, uint256 attrType, uint256 attrId) public view returns(Attribute memory){

        return genSeries[seriesId].attributes[attrType][attrId];
    }
    
    event NewGenSeries(uint256 indexed seriesId, string name, uint256 startTime, uint256 endTime);
    event BoxMintGen(uint256 boxId, uint256 seriesId);
    event AttributesAdded(uint256 indexed seriesId, uint256 indexed attrType, uint256 from, uint256 to);
    event BuyBoxGen(uint256 boxId, uint256 seriesId);
    event BoxOpenedGen(uint256 indexed boxId);
    event BlackList(uint256 indexed seriesId, bytes32 indexed combHash, bool flag);
    event NFTsMinted(uint256 indexed boxId, address owner, uint256 countNFTs);
    

}// MIT

pragma solidity ^0.8.0;


contract NonGenerativeBB is GenerativeBB {


   using Counters for Counters.Counter;
    using SafeMath for uint256;

    constructor() public {

    }

    function setURIs(uint256 seriesId, string[] memory name, string[] memory uri, uint256[] memory rarity, uint256 copies) onlyOwner public {

        require(abi.encode(nonGenSeries[seriesId].name).length != 0,"Non-GenerativeSeries doesn't exist");
        require(name.length == uri.length && name.length == rarity.length, "URIs length mismatched");
        Counters.Counter storage _attrId = nonGenSeries[seriesId].attrId;
        
        uint256 from = _attrId.current() + 1;
        for (uint256 index = 0; index < name.length; index++) {
            _attrId.increment();
            nonGenSeries[seriesId].uris[_attrId.current()] = URI(name[index], uri[index], rarity[index], copies);
            
        }
        _CopiesData[seriesId].total = _attrId.current();
        emit URIsAdded(seriesId,from, _attrId.current(), uri, name, rarity);
    }
    function nonGenerativeSeries(address bCollection,string memory name, string memory seriesURI, string memory boxName, string memory boxURI, uint256 startTime, uint256 endTime, uint256 royalty) onlyOwner internal {

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
    function buyNonGenBox(uint256 seriesId, uint256 currencyType) validateCurrencyType(seriesId,currencyType, false) internal {

        require(abi.encodePacked(nonGenSeries[seriesId].name).length > 0,"Series doesn't exist"); 
        require(nonGenSeries[seriesId].maxBoxes > nonGenSeries[seriesId].boxId.current(),"boxes sold out");
        require(nonGenSeries[seriesId].attrId.current() > nonGenSeries[seriesId].boxId.current(),"boxes sold out");
        mintNonGenBox(seriesId);
            token = USD;
        
        uint256 price = dex.calculatePrice(nonGenSeries[seriesId].price , baseCurrency[seriesId], currencyType, 0, address(this), address(this));
        uint256 price2 = dex.calculatePrice(gasFee ,0, currencyType, 0, address(this), address(this));
            price = SafeMath.div(price,1000000000000);
            price2 = SafeMath.div(price2,1000000000000);

        token.transferFrom(msg.sender, bankAddress[seriesId], price);
        token.transferFrom(msg.sender, gasFeeCollector, price2);
        nonGenBoxOwner[_boxId.current()] = msg.sender;
        emitBuyBoxNonGen(seriesId, currencyType, price);
       
    }
    function timeTester() internal {

    if(deployTime+ 7 days <= block.timestamp)
    {
      deployTime = block.timestamp;
      vrf.getRandomNumber();
    }
  }
    function buyNonGenBoxPayable(uint256 seriesId) validateCurrencyType(seriesId,1, true)  internal {

        require(abi.encodePacked(nonGenSeries[seriesId].name).length > 0,"Series doesn't exist"); 
        require(nonGenSeries[seriesId].maxBoxes > nonGenSeries[seriesId].boxId.current(),"boxes sold out");
        uint256 before_bal = MATIC.balanceOf(address(this));
        MATIC.deposit{value : msg.value}();
        uint256 after_bal = MATIC.balanceOf(address(this));
        uint256 depositAmount = after_bal - before_bal;
        uint256 price = dex.calculatePrice(nonGenSeries[seriesId].price , baseCurrency[seriesId], 1, 0, address(this), address(this));
        uint256 price2 = dex.calculatePrice(gasFee , 0, 1, 0, address(this), address(this));
        require(price + price2 <= depositAmount, "NFT 108");
        chainTransfer(bankAddress[seriesId], 1000, price);
        chainTransfer(gasFeeCollector, 1000, price2);
        if((depositAmount - (price + price2)) > 0) chainTransfer(msg.sender, 1000, (depositAmount - (price + price2)));
        mintNonGenBox(seriesId);
        nonGenBoxOwner[_boxId.current()] = msg.sender;
        emitBuyBoxNonGen(seriesId, 1, price);
      }
    function emitBuyBoxNonGen(uint256 seriesId, uint256 currencyType, uint256 price) private{

    emit BuyBoxNonGen(_boxId.current(), seriesId, nonGenSeries[seriesId].price, currencyType, nonGenSeries[seriesId].collection, msg.sender, baseCurrency[seriesId], price);
    }
    function openNonGenBox(uint256 boxId) public {

        require(nonGenBoxOwner[boxId] == msg.sender, "Box not owned");
        require(!boxesNonGen[boxId].isOpened, "Box already opened");
        _openNonGenBox(boxId);

        emit BoxOpenedNonGen(boxId);
    }
    function _openNonGenBox(uint256 boxId) private {

        uint256 sId = boxesNonGen[boxId].series;
        address collection = nonGenSeries[sId].collection;
    timeTester();
        uint256 rand =  vrf.getRandomVal();
        uint256 rand1;
        uint256 tokenId;
        for (uint256 j = 0; j < boxesNonGen[boxId].countNFTs; j++) {
          rand1 = uint256(keccak256(abi.encodePacked(block.coinbase, rand, msg.sender, j))).mod(_CopiesData[sId].total); // to keep each iteration further randomize and reducing fee of invoking VRF on each iteration.
          tokenId = dex.mintWithCollection(collection, msg.sender, nonGenSeries[sId].uris[rand1].uri, nonGenseriesRoyalty[sId] );
          _CopiesData[sId].nftCopies[rand1]++;
          if(_CopiesData[sId].nftCopies[rand1] >= nonGenSeries[sId].uris[rand1].copies){
              URI storage temp = nonGenSeries[sId].uris[rand1];
            nonGenSeries[sId].uris[rand1] = nonGenSeries[sId].uris[_CopiesData[sId].total];
            nonGenSeries[sId].uris[_CopiesData[sId].total] = temp;
            _CopiesData[sId].total--;
            
          }
          emit NonGenNFTMinted(boxId, tokenId, msg.sender, collection, rand1);
        }
        boxesNonGen[boxId].isOpened = true;
       
    }
    function getRandURIs(uint256 seriesId, uint256 countNFTs) internal view returns(uint256[] memory) {

        uint256[] memory URIs = new uint256[](countNFTs);
        URI memory uri;
        uint256 occurence;
        uint256 i = 0;
        for (uint256 uriId = 1; uriId <= nonGenSeries[seriesId].attrId.current(); uriId++) {
            uri = nonGenSeries[seriesId].uris[uriId];
            occurence = uri.rarity;
            for (uint256 index = 0; index < occurence; index++) {
                URIs[i] = uriId;
                i++;
            }
        }
        
        return URIs;
    }
    
    event NewNonGenSeries(uint256 indexed seriesId, string name, uint256 startTime, uint256 endTime);
    event BoxMintNonGen(uint256 boxId, uint256 seriesId);
    event URIsAdded(uint256 indexed boxId, uint256 from, uint256 to, string[] uris, string[] name, uint256[] rarity);
    event BuyBoxNonGen(uint256 boxId, uint256 seriesId, uint256 orignalPrice, uint256 currencyType, address collection, address from,uint256 baseCurrency, uint256 calculated);
    event BoxOpenedNonGen(uint256 indexed boxId);
    event NonGenNFTMinted(uint256 indexed boxId, uint256 tokenId, address from, address collection, uint256 uriIndex );
    

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
        address collection; 
    }
    struct Series2 {
        uint256 maxBoxes;
        uint256 perBoxNftMint;
        uint256 perBoxPrice;
        address bankAddress;
        uint256 baseCurrency;
        uint256[] allowedCurrencies; 
    }
    constructor() payable  {

    }

    function StartSeries(
        address[] memory addressData, // [collection, bankAddress]
        string[] memory stringsData, // [name, seriesURI, boxName, boxURI]
       uint256[] memory integerData, //[startTime, endTime, maxBoxes, perBoxNftMint, perBoxPrice, baseCurrency]
       uint256[] memory allowedCurrencies,
        bool isGenerative,  address bankAddress, uint256 royalty ) onlyOwner public {

            Series1 memory series = Series1( stringsData[0], stringsData[1], stringsData[2], stringsData[3], integerData[0], integerData[1],addressData[0]);
        if(isGenerative){
            generativeSeries(addressData[0],  stringsData[0], stringsData[1], stringsData[2], stringsData[3], integerData[0], integerData[1], royalty);
            

        } else {
            nonGenerativeSeriesId.increment();
            nonGenerativeSeries(addressData[0], stringsData[0], stringsData[1], stringsData[2], stringsData[3], integerData[0], integerData[1], royalty);
            emit SeriesInputValue(series,nonGenerativeSeriesId.current(), isGenerative, royalty );
        }
       extraPsrams(integerData, bankAddress, allowedCurrencies, isGenerative);
        
    }
    function extraPsrams(uint256[] memory integerData, //[startTime, endTime, maxBoxes, perBoxNftMint, perBoxPrice, baseCurrency]
         address bankAddress,
        uint256[] memory allowedCurrencies, bool isGenerative) internal {

        if(isGenerative){
      setExtraParamsGen(integerData[5], allowedCurrencies, bankAddress, integerData[4], integerData[2], integerData[3]);  

        } else {
      setExtraParams(integerData[5], allowedCurrencies, bankAddress, integerData[4], integerData[2], integerData[3]);  

        }
        Series2 memory series = Series2(integerData[2], integerData[3], integerData[4], bankAddress, integerData[5], allowedCurrencies );
        emit Series1InputValue(series,nonGenerativeSeriesId.current(), isGenerative );
    }

    function buyBox(uint256 seriesId, bool isGenerative, uint256 currencyType) public {

        if(isGenerative){
        } else {
            buyNonGenBox(seriesId, currencyType);
        }
    }
    function buyBoxPayable(uint256 seriesId, bool isGenerative) payable public {

        if(isGenerative){
        } else {
            buyNonGenBoxPayable(seriesId);
        }
    }

    function openBox(uint256 boxId, bool isGenerative) public {

        if(isGenerative){
        } else {
            openNonGenBox(boxId);
        }
    }
    fallback() payable external {}
    receive() payable external {}
    event SeriesInputValue(Series1 _series, uint256 seriesId, bool isGenerative, uint256 royalty);
    event Series1InputValue(Series2 _series, uint256 seriesId, bool isGenerative);
}