
pragma solidity ^0.4.19; //


contract ERC721 {

  function approve(address _to, uint256 _tokenId) public;

  function balanceOf(address _owner) public view returns (uint256 balance);

  function implementsERC721() public pure returns (bool);

  function ownerOf(uint256 _tokenId) public view returns (address addr);

  function takeOwnership(uint256 _tokenId) public;

  function totalSupply() public view returns (uint256 total);

  function transferFrom(address _from, address _to, uint256 _tokenId) public;

  function transfer(address _to, uint256 _tokenId) public;


  event Transfer(address indexed from, address indexed to, uint256 tokenId);
  event Approval(address indexed owner, address indexed approved, uint256 tokenId);

}

contract MobSquads2 is ERC721 {



  event Birth(uint256 tokenId, string name, address owner);

  event TokenSold(uint256 tokenId, uint256 oldPrice, uint256 newPrice, address prevOwner, address winner);

  event Transfer(address from, address to, uint256 tokenId);


  string public constant NAME = "MobSquads2"; //
  string public constant SYMBOL = "MOBS2"; //

  uint256 public precision = 1000000000000; //0.000001 Eth

  uint256 public hitPrice =  0.010 ether;

  uint256 public setPriceFee = 0.02 ether; // must be a cost to set your own price.
  uint256 public setPriceCoolingPeriod = 5 minutes; // you can't set price until 5 minutes after buying


  mapping (uint256 => address) public mobsterIndexToOwner;

  mapping (address => uint256) private ownershipTokenCount;

  mapping (uint256 => address) public mobsterIndexToApproved;

  mapping (uint256 => uint256) private mobsterIndexToPrice;

  address public ceoAddress;
  address public cooAddress;

  bool public saleStarted = false;

  struct Mobster {
    uint256 id; // needed for gnarly front end
    string name;
    uint256 boss; // which gang member of
    uint256 state; // 0 = normal , 1 = dazed
    uint256 dazedExipryTime; // if this mobster was disarmed, when does it expire
    uint256 buyPrice; // the price at which this mobster was bought
    uint256 startingPrice; // price through which no deflation can go
    uint256 buyTime;
    uint256 level;
    string show;
    bool hasWhacked;
  }

  Mobster[] private mobsters;
  uint256 public leadingGang;
  uint256 public leadingHitCount;
  uint256[] public gangHits;  // number of hits a gang has done
  uint256[] public gangBadges;  // number of whacking badges a gang has
  uint256 public currentHitTotal = 0; //
  uint256 public lethalBonusAtHitsLead = 10; // whan a squad takes the lead by this much they win the bonus
  uint256 public whackingPool;


  mapping (uint256 => uint256) private bossIndexToGang;

  mapping (address => uint256) public mobsterBalances;


  modifier onlyCEO() {

    require(msg.sender == ceoAddress);
    _;
  }

  modifier onlyCOO() {

    require(msg.sender == cooAddress);
    _;
  }

  modifier onlyCLevel() {

    require(
      msg.sender == ceoAddress ||
      msg.sender == cooAddress
    );
    _;
  }

  function MobSquads2() public {

    ceoAddress = msg.sender;
    cooAddress = msg.sender;
    leadingHitCount = 0;
     gangHits.length++;
     gangBadges.length++;
  }

  function approve(
    address _to,
    uint256 _tokenId
  ) public {

    require(_owns(msg.sender, _tokenId));

    mobsterIndexToApproved[_tokenId] = _to;

    Approval(msg.sender, _to, _tokenId);
  }

  function balanceOf(address _owner) public view returns (uint256 balance) {

    return ownershipTokenCount[_owner];
  }

  function createMobster(string _name, uint256 _startPrice, uint256 _boss, uint256 _level, string _show) public onlyCLevel {

    _createMobster(_name, address(this), _startPrice,_boss, _level, _show);
  }

  function createMobsterWithOwner(string _name, address _owner, uint256 _startPrice, uint256 _boss, uint256 _level, string _show) public onlyCLevel {

    address firstOwner = _owner;
    if (_owner==0 || _owner== address(0)){
      firstOwner =  address(this);
    }
    _createMobster(_name,firstOwner, _startPrice,_boss, _level, _show);
  }

  function getMobster(uint256 _tokenId) public view returns (
    uint256 id,
    string name,
    uint256 boss,
    uint256 sellingPrice,
    address owner,
    uint256 state,
    uint256 dazedExipryTime,
    uint256 nextPrice,
    uint256 level,
    bool canSetPrice,
    string show,
    bool hasWhacked
  ) {

    id = _tokenId;
    Mobster storage mobster = mobsters[_tokenId];
    name = mobster.name;
    boss = mobster.boss;
    sellingPrice =priceOf(_tokenId);
    owner = mobsterIndexToOwner[_tokenId];
    state = mobster.state;
    if (mobster.state==1 && now>mobster.dazedExipryTime){
        state=0; // time expired so say they are armed
    }
    dazedExipryTime=mobster.dazedExipryTime;
    nextPrice=calculateNewPrice(_tokenId);
    level=mobster.level;
    canSetPrice=(mobster.buyTime + setPriceCoolingPeriod)<now;
    show=mobster.show;
    hasWhacked=mobster.hasWhacked;
  }


  function lethalBonusAtHitsLead (uint256 _count) public onlyCLevel {
    lethalBonusAtHitsLead = _count;
  }

  function startSale () public onlyCLevel {
    saleStarted = true; // no going back
  }

  function setHitPrice (uint256 _price) public onlyCLevel {
    hitPrice = _price;
  }

  function hitMobster(uint256 _victim  , uint256 _hitter) public payable returns (bool){

    address mobsterOwner = mobsterIndexToOwner[_victim];
    require(msg.sender != mobsterOwner); // it doesn't make sense, but hey
    require(msg.sender==mobsterIndexToOwner[_hitter]); // they must be a hitter owner
    require(saleStarted==true);

    if (msg.value>=hitPrice && _victim!=0 && _hitter!=0 && mobsters[_victim].level>1){
        mobsters[_victim].state=1;
        mobsters[_victim].dazedExipryTime = now + (2 * 1 minutes);

        if(mobsters[_victim].hasWhacked==true){
          mobsters[_victim].hasWhacked=false; // injury removes your whacking badge, you have to whack again!
          gangBadges[SafeMath.div(mobsters[_victim].boss,16)+1]++;
        }

        uint256 gangNumber=SafeMath.div(mobsters[_hitter].boss,16)+1;

        gangHits[gangNumber]++; // increase the hit count for this gang
        currentHitTotal++;
        whackingPool+=hitPrice;

        if(mobsters[_hitter].hasWhacked==false){
          mobsters[_hitter].hasWhacked=true;
          gangBadges[gangNumber]++;
        }

        if  (gangHits[gangNumber]>leadingHitCount){
            leadingHitCount=gangHits[gangNumber];
            leadingGang=gangNumber;
        }

        bool lethalBonusTime = false;
        for (uint256 g = 0 ; g<gangHits.length;g++){
          if (leadingHitCount-gangHits[g]>lethalBonusAtHitsLead)
            {
              lethalBonusTime=true;
            }
        }

     if (lethalBonusTime){
       uint256 lethalBonus = SafeMath.mul(SafeMath.div(whackingPool,120),SafeMath.div(100,gangBadges[leadingGang]+1));

         uint256 winningMobsterIndex  = (16*(leadingGang-1))+1; // include the boss

         for (uint256 x = 1;x<totalSupply();x++){
             if (x>=winningMobsterIndex && x<16+winningMobsterIndex && mobsters[x].hasWhacked==true){
                mobsterBalances[ mobsterIndexToOwner[x]]+=lethalBonus; // available for withdrawal
             }
             mobsters[x].hasWhacked=false; // reset this for all
         }

         if (mobsterIndexToOwner[0]!=address(this)){
               mobsterBalances[mobsterIndexToOwner[0]]+=lethalBonus; // available for withdrawal
         }

         currentHitTotal=0; // reset the counter
         whackingPool=0; // reset this

         for (uint256 y = 0 ; y<gangHits.length;y++){
           gangHits[y]=0; // reset hit counters
           gangBadges[y]=0; // remove all bagdes
           leadingHitCount=0;
           leadingGang=0;
         }

     } // end if bonus time


   } // end if this is a hit

}


  function implementsERC721() public pure returns (bool) {

    return true;
  }

  function name() public pure returns (string) {

    return NAME;
  }

  function ownerOf(uint256 _tokenId)
    public
    view
    returns (address owner)
  {

    owner = mobsterIndexToOwner[_tokenId];
    require(owner != address(0));
  }


  function purchase(uint256 _tokenId) public payable {

    address oldOwner = mobsterIndexToOwner[_tokenId];

    uint256 sellingPrice = priceOf(_tokenId);

    require(saleStarted==true);

    require(oldOwner != msg.sender);

    require(_addressNotNull(msg.sender));

    require(msg.value >= sellingPrice);



    uint256 contractFee = roundIt(uint256(SafeMath.mul(SafeMath.div(mobsters[_tokenId].buyPrice,1000),35))); // 3.5%
    uint256 previousOwnerPayout = 0;

    if (_tokenId==0){
      whackingPool+= contractFee;
    }


    uint256 godFatherFee = 0;
    if (_tokenId!=0){
        godFatherFee = contractFee; // 3.5%
    }

    uint256 superiorFee = 0;

    if (mobsters[_tokenId].level==2 || mobsters[_tokenId].level==3){
        superiorFee =  roundIt(uint256(SafeMath.div(mobsters[_tokenId].buyPrice,20))); // 5% goes to superior
    }

    if (mobsters[_tokenId].level==3){
        whackingPool+= SafeMath.mul(SafeMath.div(mobsters[_tokenId].buyPrice, 100), 7); // 7% to whackingpool
        previousOwnerPayout = roundIt(SafeMath.mul(SafeMath.div(mobsters[_tokenId].buyPrice, 100), 118)); // 118% to previous owner
        uint256 bossFee = roundIt(SafeMath.mul(SafeMath.div(mobsters[_tokenId].buyPrice, 100), 3)); // 3% to squad boss
        address bossAddress = mobsterIndexToOwner[mobsters[mobsters[_tokenId].boss].boss]; // bosses boss
        if (bossAddress!=address(this)){
            bossAddress.transfer(bossFee);
        }
  }else{
        previousOwnerPayout = roundIt(SafeMath.mul(SafeMath.div(mobsters[_tokenId].buyPrice, 100), 110)); // 110% to previous owner
    }

    if (mobsterIndexToOwner[0]!=address(this) && _tokenId!=0){
        mobsterIndexToOwner[0].transfer(godFatherFee);
    }

    if (_tokenId!=0 && superiorFee>0 && mobsterIndexToOwner[mobsters[_tokenId].boss]!=address(this)){
        mobsterIndexToOwner[mobsters[_tokenId].boss].transfer(superiorFee);
    }


     mobsterIndexToPrice[_tokenId]  = calculateNewPrice(_tokenId);
     mobsters[_tokenId].state=0;
     mobsters[_tokenId].buyPrice=sellingPrice;
     mobsters[_tokenId].buyTime = now;

    _transfer(oldOwner, msg.sender, _tokenId);

    if (oldOwner != address(this)) {
      oldOwner.transfer(previousOwnerPayout); 
    }

    TokenSold(_tokenId, sellingPrice, mobsterIndexToPrice[_tokenId], oldOwner, msg.sender);

    if(SafeMath.sub(msg.value, sellingPrice)>0){
             msg.sender.transfer(SafeMath.sub(msg.value, sellingPrice)); // return any additional amount
    }

  }

  function priceOf(uint256 _tokenId) public view returns (uint256 price) {

    return mobsterIndexToPrice[_tokenId];
  }


  function max(uint a, uint b) private pure returns (uint) {

         return a > b ? a : b;
  }

  function nextPrice(uint256 _tokenId) public view returns (uint256 nPrice) {

    return calculateNewPrice(_tokenId);
  }

  function setTokenPrice(uint256 _tokenId , uint256 _newSellPrice) public payable {

    require(saleStarted==true);
    require(msg.sender==mobsterIndexToOwner[_tokenId]); // they must own this mobbie and not already be deflating
    require(msg.value>=setPriceFee); // they must own this mobbie and not already be deflating
    require((mobsters[_tokenId].buyTime + setPriceCoolingPeriod)<now); // no setting this until some 5 minutes after

    if (_tokenId==0 || mobsters[_tokenId].level==1){
          mobsters[_tokenId].buyPrice = roundIt(SafeMath.mul(SafeMath.div(_newSellPrice, 117), 100));
    }
   if (mobsters[_tokenId].level==2){
     mobsters[_tokenId].buyPrice = roundIt(SafeMath.mul(SafeMath.div(_newSellPrice, 122), 100));
    }
   if (mobsters[_tokenId].level==3){
     mobsters[_tokenId].buyPrice = roundIt(SafeMath.mul(SafeMath.div(_newSellPrice, 140), 100));
    }

    mobsterIndexToPrice[_tokenId]=_newSellPrice;
  }


    function claimMobsterFunds() public {

      if (mobsterBalances[msg.sender]==0) revert();
      uint256 amount = mobsterBalances[msg.sender];
      if (amount>0){
        mobsterBalances[msg.sender] = 0;
        msg.sender.transfer(amount);
      }
    }


 function calculateNewPrice(uint256 _tokenId) internal view returns (uint256 price){

   uint256 sellingPrice = priceOf(_tokenId);
   uint256 newPrice;

   if (_tokenId==0){
         newPrice = roundIt(SafeMath.div(SafeMath.mul(sellingPrice, 117), 100));
   }
  if (mobsters[_tokenId].level==1 ){
        newPrice = roundIt(SafeMath.div(SafeMath.mul(sellingPrice, 117), 100));
   }
  if (mobsters[_tokenId].level==2){
        newPrice= roundIt(SafeMath.div(SafeMath.mul(sellingPrice, 122), 100));
   }
  if (mobsters[_tokenId].level==3){
        newPrice= roundIt(SafeMath.div(SafeMath.mul(sellingPrice, 140), 100));
   }

   return newPrice;
 }

  function setCEO(address _newCEO) public onlyCEO {

    require(_newCEO != address(0));

    ceoAddress = _newCEO;
  }

  function setCOO(address _newCOO) public onlyCEO {

    require(_newCOO != address(0));

    cooAddress = _newCOO;
  }

  function symbol() public pure returns (string) {

    return SYMBOL;
  }

  function takeOwnership(uint256 _tokenId) public {

    address newOwner = msg.sender;
    address oldOwner = mobsterIndexToOwner[_tokenId];

    require(_addressNotNull(newOwner));

    require(_approved(newOwner, _tokenId));

    _transfer(oldOwner, newOwner, _tokenId);
  }

  function tokensOfOwner(address _owner) public view returns(uint256[] ownerTokens) {

    uint256 tokenCount = balanceOf(_owner);
    if (tokenCount == 0) {
      return new uint256[](0);
    } else {
      uint256[] memory result = new uint256[](tokenCount);
      uint256 totalmobsters = totalSupply();
      uint256 resultIndex = 0;

      uint256 mobsterId;
      for (mobsterId = 0; mobsterId <= totalmobsters; mobsterId++) {
        if (mobsterIndexToOwner[mobsterId] == _owner) {
          result[resultIndex] = mobsterId;
          resultIndex++;
        }
      }
      return result;
    }
  }

  function totalSupply() public view returns (uint256 total) {

    return mobsters.length;
  }

  function transfer(
    address _to,
    uint256 _tokenId
  ) public {

    require(_owns(msg.sender, _tokenId));
    require(_addressNotNull(_to));

    _transfer(msg.sender, _to, _tokenId);
  }

  function transferFrom(
    address _from,
    address _to,
    uint256 _tokenId
  ) public {

    require(_owns(_from, _tokenId));
    require(_approved(_to, _tokenId));
    require(_addressNotNull(_to));

    _transfer(_from, _to, _tokenId);
  }

  function _addressNotNull(address _to) private pure returns (bool) {

    return _to != address(0);
  }

  function _approved(address _to, uint256 _tokenId) private view returns (bool) {

    return mobsterIndexToApproved[_tokenId] == _to;
  }


  function _createMobster(string _name, address _owner, uint256 _price, uint256 _boss, uint256 _level, string _show) private {


    Mobster memory _mobster = Mobster({
      name: _name,
      boss: _boss,
      state: 0,
      dazedExipryTime: 0,
      buyPrice: _price,
      startingPrice: _price,
      id: mobsters.length-1,
      buyTime: now,
      level: _level,
      show: _show,
      hasWhacked: false
    });
    uint256 newMobsterId = mobsters.push(_mobster) - 1;
    mobsters[newMobsterId].id=newMobsterId;

    if (newMobsterId==0){
       mobsters[0].hasWhacked=true; // Godfather always has his badge
    }

    if (newMobsterId % 16 ==0 || newMobsterId==1)
    {
        gangHits.length++;
        gangBadges.length++;
    }



    require(newMobsterId == uint256(uint32(newMobsterId)));

    Birth(newMobsterId, _name, _owner);

    mobsterIndexToPrice[newMobsterId] = _price;

    _transfer(address(0), _owner, newMobsterId);
  }

  function _owns(address claimant, uint256 _tokenId) private view returns (bool) {

    return claimant == mobsterIndexToOwner[_tokenId];
  }

  function withdraw(uint256 amount) public onlyCLevel {

        require(this.balance>whackingPool);
        require(amount<=this.balance-whackingPool);
        if (amount==0){
            amount=this.balance-whackingPool;
        }
        ceoAddress.transfer(amount);
    }


  function canMakeUnrefusableOffer() public view returns (bool can){

      return (now > mobsters[0].buyTime + 48 hours);
  }

  function anOfferWeCantRefuse() public {

     require(msg.sender==mobsterIndexToOwner[0]); // owner of Godfather
     require(now > mobsters[0].buyTime + 48 hours); // 48 hours after purchase
     ceoAddress = msg.sender; // now owner of contract
     cooAddress = msg.sender; // entitled to withdraw any new contract fees
  }


  function _transfer(address _from, address _to, uint256 _tokenId) private {

    ownershipTokenCount[_to]++;
    mobsterIndexToOwner[_tokenId] = _to;

    if (_from != address(0)) {
      ownershipTokenCount[_from]--;
      delete mobsterIndexToApproved[_tokenId];
    }

    Transfer(_from, _to, _tokenId);
  }

    function roundIt(uint256 amount) internal constant returns (uint256)
    {

        uint256 result = (amount/precision)*precision;
        return result;
    }

}



library SafeMath {


  function mul(uint256 a, uint256 b) internal pure returns (uint256) {

    if (a == 0) {
      return 0;
    }
    uint256 c = a * b;
    assert(c / a == b);
    return c;
  }

  function div(uint256 a, uint256 b) internal pure returns (uint256) {

    uint256 c = a / b;
    return c;
  }

  function sub(uint256 a, uint256 b) internal pure returns (uint256) {

    assert(b <= a);
    return a - b;
  }

  function add(uint256 a, uint256 b) internal pure returns (uint256) {

    uint256 c = a + b;
    assert(c >= a);
    return c;
  }
}