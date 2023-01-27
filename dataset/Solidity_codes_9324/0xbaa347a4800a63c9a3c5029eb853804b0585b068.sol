

pragma solidity 0.6.2;



contract Ownable
{


  string public constant NOT_CURRENT_OWNER = "018001";
  string public constant CANNOT_TRANSFER_TO_ZERO_ADDRESS = "018002";

  address public owner;

  event OwnershipTransferred(
    address indexed previousOwner,
    address indexed newOwner
  );

  constructor()
    public
  {
    owner = msg.sender;
  }

  modifier onlyOwner()
  {

    require(msg.sender == owner, NOT_CURRENT_OWNER);
    _;
  }

  function transferOwnership(
    address _newOwner
  )
    public
    onlyOwner
  {

    require(_newOwner != address(0), CANNOT_TRANSFER_TO_ZERO_ADDRESS);
    emit OwnershipTransferred(owner, _newOwner);
    owner = _newOwner;
  }

}



library SafeMath
{

  string constant OVERFLOW = "008001";
  string constant SUBTRAHEND_GREATER_THEN_MINUEND = "008002";
  string constant DIVISION_BY_ZERO = "008003";

  function mul(
    uint256 _factor1,
    uint256 _factor2
  )
    internal
    pure
    returns (uint256 product)
  {

    if (_factor1 == 0)
    {
      return 0;
    }

    product = _factor1 * _factor2;
    require(product / _factor1 == _factor2, OVERFLOW);
  }

  function div(
    uint256 _dividend,
    uint256 _divisor
  )
    internal
    pure
    returns (uint256 quotient)
  {

    require(_divisor > 0, DIVISION_BY_ZERO);
    quotient = _dividend / _divisor;
  }

  function sub(
    uint256 _minuend,
    uint256 _subtrahend
  )
    internal
    pure
    returns (uint256 difference)
  {

    require(_subtrahend <= _minuend, SUBTRAHEND_GREATER_THEN_MINUEND);
    difference = _minuend - _subtrahend;
  }

  function add(
    uint256 _addend1,
    uint256 _addend2
  )
    internal
    pure
    returns (uint256 sum)
  {

    sum = _addend1 + _addend2;
    require(sum >= _addend1, OVERFLOW);
  }

  function mod(
    uint256 _dividend,
    uint256 _divisor
  )
    internal
    pure
    returns (uint256 remainder)
  {

    require(_divisor != 0, DIVISION_BY_ZERO);
    remainder = _dividend % _divisor;
  }

}


contract ERC20Token {

 
    function totalSupply() external view returns (uint256){}

    function balanceOf(address account) external view returns (uint256){}
    function allowance(address owner, address spender) external view returns (uint256){}

    function transfer(address recipient, uint256 amount) external returns (bool){}
    function approve(address spender, uint256 amount) external returns (bool){}

    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool){}
    function decimals()  external view returns (uint8){}

  
}



contract CyclopsTokens {

    
 
 
 function mint(address _to, uint256 _tokenId, string calldata _uri) external {}

 
 function ownerOf(uint256 _tokenId) external view returns (address) {}

 function burn(uint256 _tokenId) external {}
 
 function tokenURI(uint256 _tokenId) external  view returns(string memory) {}

    
}

contract mpContract {

    function getNextTokenId() external  view returns (uint256){}

    function nftProfiles(uint256) public view returns (uint32, uint256, uint256, string memory, uint32){}
}


contract NFTMarketplace is
  Ownable
{

    using SafeMath for uint256;    
    
     modifier onlyPriceManager() {

      require(
          msg.sender == price_manager,
          "only price manager can call this function"
          );
          _;
    }
    
    modifier onlyOwnerOrPriceManager() {

      require(
          msg.sender == price_manager || msg.sender == owner,
          "only price manager or owner can call this function"
          );
          _;
    }
 
    function isContract(address _addr) internal view returns (bool){

      uint32 size;
      assembly {
          size := extcodesize(_addr)
      }
    
      return (size > 0);
    }

    modifier notContract(){

      require(
          (!isContract(msg.sender)),
          "external contracts are not allowed"
          );
          _;
    }

 
    
  CyclopsTokens nftContract;
  ERC20Token token; //CYTR
  mpContract prevMPContract;
  
  address nftContractAddress = 0x2Eec2D8FFb26eB04dD37078f52913321d840f607; //NFT contract (Cyclops)
  address paymentTokenAddress = 0xBD05CeE8741100010D8E93048a80Ed77645ac7bf; //payment token (ERC20, CYTR)
  
  address price_manager = 0xE285D1408A223bE34bF2b39e9D38BdE26708a246;
  
  bool internal_prices = true;
  uint256 price_curve = 5; //5%
  
  uint32 constant BAD_NFT_PROFILE_ID = 9999999;
  uint256 constant BAD_PRICE = 0;
  string constant BAD_URL = '';
  uint32 constant UNLIMITED = 9999999;
  
  struct NFTProfile{
      uint32 id;
      uint256 price; //in CYTR, i.e. 1,678 CYTR last 18 digits are decimals
      uint256 sell_price; //in CYTR i.e. 1,678 CYTR last 18 digits are decimals
      string url;
      uint32 limit;
  }
  
  NFTProfile[] public nftProfiles;
  
  uint256 next_token_id = 10;

    event Minted(uint32 profileID, uint256 tokenId, address wallet, uint256 cytrAmount, uint256 priceAtMoment);
    
    event GotCYTRForNFT(uint32 profileID, address wallet, uint256 cytrAmount, uint256 priceAtMoment);
    
    event SendCYTRForNFT(uint32 profileID, address wallet, uint256 cytrAmount, uint256 buybackPriceAtMoment);
    
    event Burned(uint32 profileID, uint256 tokenId, address wallet, uint256 cytrAmount, uint256 buybackPriceAtMoment);
    
    event TokensDeposited(uint256 amount, address wallet);
    event FinneyDeposited(uint256 amount, address wallet);
    event Withdrawn(uint256 amount, address wallet);
    event TokensWithdrawn(uint256 amount, address wallet);
    event AdminMinted(uint32 profileID, uint256 tokenId, address wallet, uint256 curPrice); 
    event AdminBurned(uint256 _tokenId,uint32 tokenProfileId, uint256 curSellPrice); 

  constructor()
    public
  {
     price_manager = owner;
     nftContract = CyclopsTokens(nftContractAddress);   //NFT minting interface
     token = ERC20Token(paymentTokenAddress);           //CYTR interface
  }
    
    function setPriceManagerRight(address newPriceManager) external onlyOwner{

          price_manager = newPriceManager;
    }
      
    
    function getPriceManager() public view returns(address){

        return price_manager;
    }

    function setInternalPriceCurve() external onlyOwnerOrPriceManager{

          internal_prices = true;
    }
    
    function setExternalPriceCurve() external onlyOwnerOrPriceManager{

          internal_prices = false;
    }
      
    function isPriceCurveInternal() public view returns(bool){

        return internal_prices;
    }
      
    function setPriceCurve(uint256 new_curve) external onlyOwnerOrPriceManager{

          price_curve = new_curve;
    }
      
    
    function getPriceCurve() public view returns(uint256){

        return price_curve;
    }
    
    
    function setPaymentToken(address newERC20Contract) external onlyOwner returns(bool){

    
        paymentTokenAddress = newERC20Contract;
        token = ERC20Token(paymentTokenAddress);
    }
    
    
    function getPaymentToken() external view returns(address){

        return paymentTokenAddress;
    }
    
    
    
    function setNFTContract(address newNFTContract) external onlyOwner returns(bool){

    
        nftContractAddress = newNFTContract;
        nftContract = CyclopsTokens(nftContractAddress);
    }
    
    
    function getNFTContract() external view returns(address){

        return nftContractAddress;
    }



  function getNextTokenId() external  view returns (uint256){

      return next_token_id;
  }
  
  function setNextTokenId(uint32 setId) external onlyOwnerOrPriceManager (){

      next_token_id = setId;
  }
  
  function addNFTProfile(uint32 id, uint256 price, uint256 sell_price, string calldata url, uint32 limit) external onlyOwnerOrPriceManager {

      NFTProfile memory temp = NFTProfile(id,price,sell_price,url, limit);
      nftProfiles.push(temp);
  }
  
  
  
  function setupFrom(address mpContractAddress, uint32 lenght) external onlyOwner {

      prevMPContract = mpContract(mpContractAddress); 
      
      next_token_id = prevMPContract.getNextTokenId();
      
      for (uint32 i = 0; i < lenght; i++){
         
        (uint32 id, uint256 price, uint256 sell_price, string memory url,uint32 limit) = prevMPContract.nftProfiles(i);
        NFTProfile memory temp = NFTProfile( id,  price,  sell_price,  url, limit);    
        nftProfiles.push(temp);
      }
  }
  
  
  function removeNFTProfileAtId(uint32 id) external onlyOwnerOrPriceManager {

     for (uint32 i = 0; i < nftProfiles.length; i++){
          if (nftProfiles[i].id == id){
              removeNFTProfileAtIndex(i);      
              return;
          }
     }
  }
  
  
  
  function removeNFTProfileAtIndex(uint32 index) internal {

     if (index >= nftProfiles.length) return;
     if (index == nftProfiles.length -1){
         nftProfiles.pop();
     } else {
         for (uint i = index; i < nftProfiles.length-1; i++){
             nftProfiles[i] = nftProfiles[i+1];
         }
         nftProfiles.pop();
     }
  }
  
  
  
  function replaceNFTProfileAtId(uint32 id, uint256 price, uint256 sell_price, string calldata url, uint32 limit) external onlyOwnerOrPriceManager {

     for (uint i = 0; i < nftProfiles.length; i++){
          if (nftProfiles[i].id == id){
              nftProfiles[i].price = price;
              nftProfiles[i].sell_price = sell_price;
              nftProfiles[i].url = url;
              nftProfiles[i].limit = limit;
              return;
          }
     }
  }
  
  
  function replaceNFTProfileAtIndex(uint32 atIndex, uint32 id, uint256 price, uint256 sell_price, string calldata url, uint32 limit) external onlyOwnerOrPriceManager  {

     nftProfiles[atIndex].id = id;
     nftProfiles[atIndex].price = price;
     nftProfiles[atIndex].sell_price = sell_price;
     nftProfiles[atIndex].url = url;
     nftProfiles[atIndex].limit = limit;
  }
  
  function viewNFTProfilesPrices() external view returns( uint32[] memory, uint256[] memory, uint256[] memory){

      uint32[] memory ids = new uint32[](nftProfiles.length);
      uint256[] memory prices = new uint256[](nftProfiles.length);
      uint256[] memory sell_prices = new uint256[](nftProfiles.length);
      for (uint i = 0; i < nftProfiles.length; i++){
          ids[i] = nftProfiles[i].id;
          prices[i] = nftProfiles[i].price;
          sell_prices[i] = nftProfiles[i].sell_price;
      }
      return (ids, prices, sell_prices);
  }
  
  
  function viewNFTProfileDetails(uint32 id) external view returns(uint256, uint256, string memory, uint32){

     for (uint i = 0; i < nftProfiles.length; i++){
          if (nftProfiles[i].id == id){
              return (nftProfiles[i].price, nftProfiles[i].sell_price, nftProfiles[i].url, nftProfiles[i].limit);     
          }
     }
     return (BAD_PRICE, BAD_PRICE, BAD_URL, UNLIMITED);
  }
  
  function getPriceById(uint32 id) public  view returns (uint256){

      for (uint i = 0; i < nftProfiles.length; i++){
          if (nftProfiles[i].id == id){
              return nftProfiles[i].price;
          }
      }
      return BAD_PRICE;
  }
  
  
 
  
  function getSellPriceById(uint32 id) public  view returns (uint256){

      for (uint i = 0; i < nftProfiles.length; i++){
          if (nftProfiles[i].id == id){
              return nftProfiles[i].sell_price;
          }
      }
      return BAD_PRICE;
  }
  
  function setPriceById(uint32 id, uint256 new_price) external onlyOwnerOrPriceManager{

      for (uint i = 0; i < nftProfiles.length; i++){
          if (nftProfiles[i].id == id){
              nftProfiles[i].price = new_price;
              return;
          }
      }
  }
  
  function setSellPriceById(uint32 id, uint256 new_price) external onlyOwnerOrPriceManager{

      for (uint i = 0; i < nftProfiles.length; i++){
          if (nftProfiles[i].id == id){
              nftProfiles[i].sell_price = new_price;
              return;
          }
      }
  }
  
  function updatePricesById(uint32 id, uint256 new_price, uint256 new_sell_price) external onlyOwnerOrPriceManager{

      for (uint i = 0; i < nftProfiles.length; i++){
          if (nftProfiles[i].id == id){
              nftProfiles[i].price = new_price;
              nftProfiles[i].sell_price = new_sell_price;
              return;
          }
      }
  }
  
 
  
  function  getUrlById(uint32 id) public view returns (string memory){
      for (uint i = 0; i < nftProfiles.length; i++){
          if (nftProfiles[i].id == id){
              return nftProfiles[i].url;
          }
      }
      return BAD_URL;
  }
  
  function  getLimitById(uint32 id) public view returns (uint32){
      for (uint i = 0; i < nftProfiles.length; i++){
          if (nftProfiles[i].id == id){
             return nftProfiles[i].limit;
          }
      }
      return UNLIMITED;
  }
  
   
  function buyNFT(          //'buy' == mint NFT token function, provides NFT token in exchange of CYTR    
    uint32 profileID,       //id of NFT profile
    uint256 cytrAmount,     //amount of CYTR we check it is equal to price, amount in real form i.e. 18 decimals
    address _to,            //where to deliver 
    uint256 _tokenId        //with which id NFT will be generated
  ) 
    external 
    notContract 
    returns (uint256)
  {

    require (getLimitById(profileID) > 0,"limit is over");
    
    uint256 curPrice = getPriceById(profileID);
    require(curPrice != BAD_PRICE, "price for NFT profile not found");
    require(cytrAmount > 0, "You need to provide some CYTR"); //it is already in 'real' form, i.e. with decimals
    
    require(cytrAmount == curPrice); //correct work (i.e. dApp calculated price correctly)
    
    uint256 token_bal = token.balanceOf(msg.sender); //how much CYTR buyer has
    
    require(token_bal >= cytrAmount, "Check the CYTR balance on your wallet"); //is it enough
    
    uint256 allowance = token.allowance(msg.sender, address(this));
    
    require(allowance >= cytrAmount, "Check the CYTR allowance"); //is allowance provided
    
    require(isFreeTokenId(_tokenId), "token id is is occupied"); //adjust on calling party

    try token.transferFrom(msg.sender, address(this), cytrAmount) { // get CYTR from buyer
        emit GotCYTRForNFT(profileID, msg.sender, cytrAmount, curPrice);
    } catch {
        require(false,"CYTR transfer failed");
        return 0; 
    }
  
   
    try nftContract.mint(_to,_tokenId, getUrlById(profileID)){
        next_token_id++;
        emit Minted(profileID, _tokenId, msg.sender, cytrAmount, curPrice); 
    } catch {
        require(false,"mint failed");
    }
    
    for (uint i = 0; i < nftProfiles.length; i++){
      if (nftProfiles[i].id == profileID){
          if (nftProfiles[i].limit != UNLIMITED) nftProfiles[i].limit--;
      }
    }
    
    if (internal_prices){ //if we manage price curve internally
        for (uint i = 0; i < nftProfiles.length; i++){
          if (nftProfiles[i].id == profileID){
              uint256 change = nftProfiles[i].price.div(100).mul(price_curve);
              nftProfiles[i].price = nftProfiles[i].price.add(change);
              change = nftProfiles[i].sell_price.div(100).mul(price_curve);
              nftProfiles[i].sell_price = nftProfiles[i].sell_price.add(change);
          }
      }
    }
 
  }

  function sellNFTBack(uint256 _tokenId) external notContract returns(uint256){ //'sell' == burn, burns and returns CYTR to user

        require(nftContract.ownerOf(_tokenId) == msg.sender, "it is not your NFT");
        uint32 tokenProfileId = getProfileIdByTokenId(_tokenId);
        require(tokenProfileId != BAD_NFT_PROFILE_ID, "NFT profile ID not found");
        uint256 sellPrice = getSellPriceById(tokenProfileId); 
        require(sellPrice != BAD_PRICE, "NFT price not found");
        
        require(token.balanceOf(address(this)) > sellPrice, "unsufficient CYTR on contract");
        
        try nftContract.burn(_tokenId) {
            emit Burned(tokenProfileId, _tokenId, msg.sender, sellPrice, sellPrice); 
        } catch {
            require (false, "NFT burn failed");
        }
      
        try token.transfer(msg.sender,  sellPrice) { // send CYTR to seller
            emit SendCYTRForNFT(tokenProfileId, msg.sender, sellPrice, sellPrice);
        } catch {
            require(false,"CYTR transfer failed");
            return 0; 
        }
        
        for (uint i = 0; i < nftProfiles.length; i++){
          if (nftProfiles[i].id == tokenProfileId){
              if (nftProfiles[i].limit != UNLIMITED) nftProfiles[i].limit++;
          }
        }
       
        if (internal_prices){ //if we manage price curve internally
            for (uint i = 0; i < nftProfiles.length; i++){
              if (nftProfiles[i].id == tokenProfileId){
                  uint256 change = nftProfiles[i].price.div(100).mul(price_curve);
                  nftProfiles[i].price = nftProfiles[i].price.sub(change);
                  change = nftProfiles[i].sell_price.div(100).mul(price_curve);
                  nftProfiles[i].sell_price = nftProfiles[i].sell_price.sub(change);
              }
            }
        }
  }
  
  
  function adminMint(       //mint for free as admin
    uint32 profileID,       //id of NFT profile
    address _to,            //where to deliver 
    uint256 _tokenId        //with which id NFT will be generated
  ) 
    external 
    onlyOwnerOrPriceManager
    returns (uint256)
  {

    uint256 curPrice = getPriceById(profileID);
    require(curPrice != BAD_PRICE, "price for NFT profile not found");
    require(isFreeTokenId(_tokenId), "token id is is occupied");
  

    
    try nftContract.mint(_to,_tokenId, getUrlById(profileID)){
        next_token_id++;
        emit AdminMinted(profileID, _tokenId, _to, curPrice); 
    } catch {
        require(false,"mint failed");
    }
    
    return _tokenId; //success, return generated tokenId (works if called by another contract)
  }

  
  
  function adminBurn(uint256 _tokenId) external  onlyOwnerOrPriceManager returns(uint256){  //burn as admin, without CYTR move


        uint32 tokenProfileId = getProfileIdByTokenId(_tokenId);
        uint256 sellPrice = getSellPriceById(tokenProfileId); 
        
        try nftContract.burn(_tokenId) {
            emit AdminBurned(_tokenId, tokenProfileId, sellPrice); 
        } catch {
            require (false, "NFT burn failed");
        }
      
  }
  
  
  function getProfileIdByTokenId(uint256 tokenId) public view returns(uint32){

      string memory url = BAD_URL;
      try nftContract.tokenURI(tokenId) {
        url = nftContract.tokenURI(tokenId);
        return getProfileIdbyUrl(url);
      } catch {
        return BAD_NFT_PROFILE_ID;
      }
     
  }
  
  function getProfileIdbyUrl(string memory url) public  view returns (uint32){

      for (uint i = 0; i < nftProfiles.length; i++){
          if (keccak256(bytes(nftProfiles[i].url)) == keccak256(bytes(url))){
              return nftProfiles[i].id;
          }
      }
      return BAD_NFT_PROFILE_ID;
  }
  
 
  
  function isFreeTokenId(uint256 tokenId) public view returns (bool){

      try nftContract.tokenURI(tokenId) { 
          return false;
      } catch {
          return true; //if we errored getting url by tokenId, it is free -> true
      }
  }
  
  
  function getTokenPriceByTokenId(uint256 tokenId) public view returns(uint256){

      string memory url = BAD_URL;
      try nftContract.tokenURI(tokenId) {
        url = nftContract.tokenURI(tokenId);
        uint32 profileId = getProfileIdbyUrl(url);
        if (profileId == BAD_NFT_PROFILE_ID){
            return BAD_NFT_PROFILE_ID;
        } else {
            return getSellPriceById(profileId);
        }
      } catch {
        return BAD_NFT_PROFILE_ID;
      }
     
  }
  
  
    
    function getContractBalance() external view returns (uint256) {

        return address(this).balance;
    }

    function getContractTokensBalance() external view returns (uint256) {

        return token.balanceOf(address(this));
    }
    
    
    function withdraw(address payable sendTo, uint256 amount) external onlyOwner {

        require(address(this).balance >= amount, "unsufficient funds");
        bool success = false;
        (success, ) = sendTo.call.value(amount)("");
        require(success, "Transfer failed.");
        emit Withdrawn(amount, sendTo); //in wei
    }
    
    
    function deposit(uint256 amount) payable external onlyOwner { 

        require(amount*(1 finney) == msg.value,"please provide value in finney");
        emit FinneyDeposited(amount, owner); //in finney
    }
    
    
    function depositTokens(uint256 amount) external onlyOwner {

        require(amount > 0, "You need to deposit at least some tokens");
        uint256 allowance = token.allowance(msg.sender, address(this));
        require(allowance >= amount, "Check the token allowance");
        token.transferFrom(msg.sender, address(this), amount);
    
        emit TokensDeposited(amount, owner);
    }
    
    
    function withdrawTokens(address to_wallet, uint256 realAmountTokens) external onlyOwner {

            
        require(realAmountTokens > 0, "You need to withdraw at least some tokens");
      
        uint256 contractTokenBalance = token.balanceOf(address(this));
    
        require(contractTokenBalance > realAmountTokens, "unsufficient funds");
    
        try token.transfer(to_wallet, realAmountTokens) {
            emit TokensWithdrawn(realAmountTokens, to_wallet); //in real representation
        } catch {
            require(false,"tokens transfer failed");
    
        }
    
    }
        
    
    
}