
pragma solidity ^0.4.23;

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

contract CryptoWorldCupToken is ERC721 {



  event NewPlayerCreated(uint256 tokenId, uint256 id, string prename, string surname, address owner, uint256 price);

  event PlayerWasSold(uint256 tokenId, uint256 oldPrice, uint256 newPrice, address prevOwner, address winner, string prename, string surname);

  event Transfer(address from, address to, uint256 tokenId);

  event countryWonAndPlayersValueIncreased(string country, string prename, string surname);

  event NewUserRegistered(string userName);


  string public constant NAME = "CryptoWorldCup";
  string public constant SYMBOL = "CryptoWorldCupToken";

  address private netFee = 0x5e02f153d571C1FBB6851928975079812DF4c8cd;

  uint256 public myFinneyValue =  100 finney;
  uint256 public myWeiValue = 1 wei;

  bool public presaleIsRunning;

   uint256 public currentwealth;

  address public ceoAddress;

  uint256 public totalTxVolume = 0;
  uint256 public totalContractsAvailable = 0;
  uint256 public totalContractHolders = 0;
  uint256 public totalUsers = 0;


  mapping (uint256 => address) public PlayerIndexToOwner;

  mapping (address => uint256) private ownershipTokenCount;

  mapping (uint256 => address) public PlayerIndexToApproved;

  mapping (uint256 => uint256) private PlayerIndexToPrice;
  mapping (uint256 => uint256) private PlayerInternalIndexToGlobalIndex;

  mapping (uint256 => address) private UserIDsToWallet;
  mapping (uint256 => string) private UserIDToUsername;
  mapping (address => uint256) private UserWalletToID;
  mapping (address => bool) private isUser;

  mapping (address => uint256) private addressWealth;

  mapping (address => bool) blacklist;

  mapping (uint256 => PlayerIDs) PlayerIDsToUniqueID;

  struct Player {
    uint256 id;
    uint256 countryId;
    string country;
    string surname;
    string middlename;
    string prename;
    string position;
    uint256 age;
    uint64 offensive;
    uint64 defensive;
    uint64 totalRating;
    uint256 price;
    string pictureUrl;
    string flagUrl;
  }

  Player[] private players;

  struct User{
    uint256 id;
    address userAddress;
    string userName;
  }

  User[] private users;

  struct PlayerIDs {
        uint256 id;
        uint256 countryId;
  }

  PlayerIDs[] public PlayerIDsArrayForMapping;

  modifier onlyCEO() {

    require(msg.sender == ceoAddress);
    _;
  }

  modifier onlyDuringPresale(){

      require(presaleIsRunning);
      _;
  }

  constructor() public {
    presaleIsRunning = true;
    ceoAddress = msg.sender;
  }

  function implementsERC721() public pure returns (bool) {

    return true;
  }

  function name() public pure returns (string) {

    return NAME;
  }

  function symbol() public pure returns (string) {

    return SYMBOL;
  }


  function endPresale() public onlyCEO{

    require(presaleIsRunning == true);
    presaleIsRunning = false;
  }


  function blackListUser(address _address) public onlyCEO{

      blacklist[_address] = true;
  }

  function deleteUser(address _address) public onlyCEO{


      uint256 userID = getUserIDByWallet(_address) + 1;
      delete users[userID];

      isUser[_address] = false;

      uint256 userIDForMappings = UserWalletToID[_address];

     delete UserIDsToWallet[userIDForMappings];
     delete UserIDToUsername[userIDForMappings];
     delete UserWalletToID[_address];

      totalUsers = totalUsers - 1;
  }

  function payout(address _to) public onlyCEO {

    _payout(_to);
  }


  function createPlayer(uint256 _id, uint256 _countryId, string _country, string _prename, string _middlename, string _surname, string _pictureUrl, string _flagUrl, address _owner, uint256 _price) public onlyCEO onlyDuringPresale{


    uint256 newPrice = SafeMath.mul(_price, myFinneyValue);

    Player memory _player = Player({
     id: _id,
     countryId: _countryId,
     country: _country,
     surname: _surname,
     middlename: _middlename,
     prename: _prename,
     price: newPrice,
     pictureUrl: _pictureUrl,
     flagUrl: _flagUrl,
     position: "",
     age: 0,
     offensive: 0,
     defensive: 0,
     totalRating: 0
    });

    uint256 newPlayerId = players.push(_player) - 1;

    require(newPlayerId == uint256(uint32(newPlayerId)));

    emit NewPlayerCreated(newPlayerId, newPlayerId, _prename, _surname, _owner, _price);

    addMappingForPlayerIDs (newPlayerId, _id, _countryId );

    PlayerIndexToPrice[newPlayerId] = newPrice;
    PlayerInternalIndexToGlobalIndex[newPlayerId] = newPlayerId;

    currentwealth =   addressWealth[_owner];
    addressWealth[_owner] = currentwealth + newPrice;

    totalTxVolume = totalTxVolume + newPrice;

    _transfer(address(0), _owner, newPlayerId);

    totalContractsAvailable = totalContractsAvailable;

    if(numberOfTokensOfOwner(_owner) == 0 || numberOfTokensOfOwner(_owner) == 1){
        totalContractHolders = totalContractHolders + 1;
    }
  }

  function deletePlayer (uint256 _uniqueID) public onlyCEO{
      uint256 arrayPos = _uniqueID + 1;
      address _owner = PlayerIndexToOwner[_uniqueID];

      currentwealth =   addressWealth[_owner];
    addressWealth[_owner] = currentwealth + priceOf(_uniqueID);

    totalContractsAvailable = totalContractsAvailable - 1;

    if(numberOfTokensOfOwner(_owner) != 0 || numberOfTokensOfOwner(_owner) == 1){
        totalContractHolders = totalContractHolders - 1;
    }

      delete players[arrayPos];
      delete PlayerIndexToOwner[_uniqueID];
      delete PlayerIndexToPrice[_uniqueID];

  }

  function adjustPriceOfCountryPlayersAfterWin(uint256 _tokenId) public onlyCEO {

    uint256 _price = SafeMath.mul(105, SafeMath.div(players[_tokenId].price, 100));
    uint256 playerInternalIndex = _tokenId;
    uint256 playerGlobalIndex = PlayerInternalIndexToGlobalIndex[playerInternalIndex];
    PlayerIndexToPrice[playerGlobalIndex] = _price;

    emit countryWonAndPlayersValueIncreased(players[_tokenId].country, players[_tokenId].prename, players[_tokenId].surname);
  }

  function adjustPriceAndOwnerOfPlayerDuringPresale(uint256 _tokenId, address _newOwner, uint256 _newPrice) public onlyCEO{

    require(presaleIsRunning);
    _newPrice = SafeMath.mul(_newPrice, myFinneyValue);
    PlayerIndexToPrice[_tokenId] = _newPrice;
    PlayerIndexToOwner[_tokenId] = _newOwner;
  }

  function addPlayerData(uint256 _playerId, uint256 _countryId, string _position, uint256 _age, uint64 _offensive, uint64 _defensive, uint64 _totalRating) public onlyCEO{


       uint256 _id = getIDMapping(_playerId, _countryId);

       players[_id].position = _position;
       players[_id].age = _age;
       players[_id].offensive = _offensive;
       players[_id].defensive = _defensive;
       players[_id].totalRating = _totalRating;
    }


    function addMappingForPlayerIDs (uint256 _uniquePlayerId, uint256 _playerId, uint256 _countryId ) private{

        PlayerIDs memory _playerIdStruct = PlayerIDs({
            id: _playerId,
            countryId: _countryId
        });

        PlayerIDsArrayForMapping.push(_playerIdStruct)-1;

        PlayerIDsToUniqueID[_uniquePlayerId] = _playerIdStruct;

    }


  function balanceOf(address _owner) public view returns (uint256 balance) {

    return ownershipTokenCount[_owner];
  }

  function isUserBlacklisted(address _address) public view returns (bool){

      return blacklist[_address];
  }

   function getPlayerFrontDataForMarketPlaceCards(uint256 _tokenId) public view returns (
    uint256 _id,
    uint256 _countryId,
    string _country,
    string _surname,
    string _prename,
    uint256 _sellingPrice,
    string _picUrl,
    string _flagUrl
  ) {

    Player storage player = players[_tokenId];
    _id = player.id;
    _countryId = player.countryId;
    _country = player.country;
    _surname = player.surname;
    _prename = player.prename;
    _sellingPrice = PlayerIndexToPrice[_tokenId];
    _picUrl = player.pictureUrl;
    _flagUrl = player.flagUrl;

    return (_id, _countryId, _country, _surname, _prename, _sellingPrice, _picUrl, _flagUrl);

  }

    function getPlayerBackDataForMarketPlaceCards(uint256 _tokenId) public view returns (
    uint256 _id,
    uint256 _countryId,
    string _country,
    string _surname,
    string _prename,
    string _position,
    uint256 _age,
    uint64 _offensive,
    uint64 _defensive,
    uint64 _totalRating
  ) {

    Player storage player = players[_tokenId];
    _id = player.id;
    _countryId = player.countryId;
    _country = player.country;
    _surname = player.surname;
    _prename = player.prename;
    _age = player.age;

    _position = player.position;
    _offensive = player.offensive;
    _defensive = player.defensive;
    _totalRating = player.totalRating;

    return (_id, _countryId, _country, _surname, _prename, _position, _age, _offensive,_defensive, _totalRating);
  }

  function ownerOf(uint256 _tokenId)
    public
    view
    returns (address owner)
  {

    owner = PlayerIndexToOwner[_tokenId];
    require(owner != address(0));
  }

  function priceOf(uint256 _tokenId) public view returns (uint256 price) {

    return PlayerIndexToPrice[_tokenId];
  }

  function calcNetworkFee(uint256 _tokenId) public view returns (uint256 networkFee) {

    uint256 price = PlayerIndexToPrice[_tokenId];
    networkFee = SafeMath.div(price, 100);
    return networkFee;
  }

  function getLeaderBoardData(address _owner)public view returns (address _user, uint256 _token, uint _wealth){

      _user = _owner;
      _token = numberOfTokensOfOwner(_owner);
      _wealth = getWealthOfUser(_owner);
      return (_user, _token, _wealth);
  }


  function getUserByID(uint256 _id) public view returns (address _wallet, string _username){

    _username = UserIDToUsername[_id];
    _wallet = UserIDsToWallet[_id];
    return (_wallet, _username);
  }

   function getUserWalletByID(uint256 _id) public view returns (address _wallet){

    _wallet = UserIDsToWallet[_id];
    return (_wallet);
  }

  function getUserNameByWallet(address _wallet) public view returns (string _username){

    require(isAlreadyUser(_wallet));
    uint256 _id = UserWalletToID[_wallet];
    _username = UserIDToUsername[_id];
    return _username;
  }

  function getUserIDByWallet(address _wallet) public view returns (uint256 _id){

    _id = UserWalletToID[_wallet];
    return _id;
  }

  function getUniqueIdOfPlayerByPlayerAndCountryID(uint256 _tokenId) public view returns (uint256 id){

      uint256 idOfPlyaer = players[_tokenId].id;
      return idOfPlyaer;
  }

  function getIDMapping (uint256 _playerId, uint256 _countryId) public view returns (uint256 _uniqueId){

        for (uint64 x=0; x<totalSupply(); x++){
            PlayerIDs memory _player = PlayerIDsToUniqueID[x];
            if(_player.id == _playerId && _player.countryId == _countryId){
                _uniqueId = x;
            }
        }

        return _uniqueId;
   }

  function getWealthOfUser(address _address) private view returns (uint256 _wealth){

    return addressWealth[_address];
  }


  function adjustAddressWealthOnSale(uint256 _tokenId, address _oldOwner, address _newOwner,uint256 _sellingPrice) private {

        uint256 currentOldOwnerWealth = addressWealth[_oldOwner];
        uint256 currentNewOwnerWealth = addressWealth[_newOwner];
        addressWealth[_oldOwner] = currentOldOwnerWealth - _sellingPrice;
        addressWealth[_newOwner] = currentNewOwnerWealth + PlayerIndexToPrice[_tokenId];
    }

  function purchase(uint256 _tokenId) public payable {


    require(presaleIsRunning == false);

    address oldOwner = PlayerIndexToOwner[_tokenId];
    address newOwner = msg.sender;

    uint256 sellingPrice = PlayerIndexToPrice[_tokenId];
    uint256 payment = SafeMath.mul(99,(SafeMath.div(PlayerIndexToPrice[_tokenId],100)));
    uint256 networkFee  = calcNetworkFee(_tokenId);

    require(oldOwner != newOwner);

    require(_addressNotNull(newOwner));

    require(msg.value >= sellingPrice);

    uint256 purchaseExcess = SafeMath.sub(msg.value, sellingPrice);

    PlayerIndexToPrice[_tokenId] = SafeMath.div(SafeMath.mul(sellingPrice, 110), 100);

    _transfer(oldOwner, newOwner, _tokenId);

    if (oldOwner != address(this)) {
      oldOwner.transfer(payment); //(1-0.06)
    }

    emit PlayerWasSold(_tokenId, sellingPrice, PlayerIndexToPrice[_tokenId], oldOwner, newOwner, players[_tokenId].prename, players[_tokenId].surname);

    msg.sender.transfer(purchaseExcess);

    netFee.transfer(networkFee);

    totalTxVolume = totalTxVolume + msg.value;

    if(numberOfTokensOfOwner(msg.sender) == 1){
        totalContractHolders = totalContractHolders + 1;
    }

    if(numberOfTokensOfOwner(oldOwner) == 0){
        totalContractHolders = totalContractHolders - 1;
    }

    adjustAddressWealthOnSale(_tokenId, oldOwner, newOwner,sellingPrice);

  }

  function takeOwnership(uint256 _tokenId) public {

    address newOwner = msg.sender;
    address oldOwner = PlayerIndexToOwner[_tokenId];

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
      uint256 totalPlayers = totalSupply();
      uint256 resultIndex = 0;

      uint256 PlayerId;
      for (PlayerId = 0; PlayerId <= totalPlayers; PlayerId++) {
        if (PlayerIndexToOwner[PlayerId] == _owner) {
          result[resultIndex] = PlayerId;
          resultIndex++;
        }
      }
      return result;
    }
  }

  function numberOfTokensOfOwner(address _owner) private view returns(uint256 numberOfTokens){

      return tokensOfOwner(_owner).length;
  }

  function totalSupply() public view returns (uint256 total) {

    return players.length;
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


  function createNewUser(address _address, string _username) public {


    require(!blacklist[_address]);
    require(!isAlreadyUser(_address));

    uint256 userIdForMapping = users.length;

    User memory _user = User({
      id: userIdForMapping,
      userAddress: _address,
      userName: _username
    });


    uint256 newUserId = users.push(_user) - 1;

    require(newUserId == uint256(uint32(newUserId)));

    emit NewUserRegistered(_username);

    UserIDsToWallet[userIdForMapping] = _address;
    UserIDToUsername[userIdForMapping] = _username;
    UserWalletToID[_address] = userIdForMapping;
    isUser[_address] = true;

    totalUsers = totalUsers + 1;
  }

  function isAlreadyUser(address _address) public view returns (bool status){

    if (isUser[_address]){
      return true;
    } else {
      return false;
    }
  }

  function _addressNotNull(address _to) private pure returns (bool) {

    return _to != address(0);
  }



    function fixPlayerID(uint256 _uniqueID, uint256 _playerID) public onlyCEO onlyDuringPresale{

        players[_uniqueID].id = _playerID;
    }

      function fixPlayerCountryId(uint256 _uniqueID, uint256 _countryID) public onlyCEO onlyDuringPresale{

        players[_uniqueID].countryId = _countryID;
    }

    function fixPlayerCountryString(uint256 _uniqueID, string _country) public onlyCEO onlyDuringPresale{

        players[_uniqueID].country = _country;
    }

    function fixPlayerPrename(uint256 _uniqueID, string _prename) public onlyCEO onlyDuringPresale{

        players[_uniqueID].prename = _prename;
    }

    function fixPlayerMiddlename(uint256 _uniqueID, string _middlename) public onlyCEO onlyDuringPresale{

         players[_uniqueID].middlename = _middlename;
    }

    function fixPlayerSurname(uint256 _uniqueID, string _surname) public onlyCEO onlyDuringPresale{

         players[_uniqueID].surname = _surname;
    }

    function fixPlayerFlag(uint256 _uniqueID, string _flag) public onlyCEO onlyDuringPresale{

         players[_uniqueID].flagUrl = _flag;
    }

    function fixPlayerGraphic(uint256 _uniqueID, string _pictureUrl) public onlyCEO onlyDuringPresale{

         players[_uniqueID].pictureUrl = _pictureUrl;
    }



  function approve(
    address _to,
    uint256 _tokenId
  ) public {

    require(_owns(msg.sender, _tokenId));

    PlayerIndexToApproved[_tokenId] = _to;

    emit Approval(msg.sender, _to, _tokenId);
  }

  function _approved(address _to, uint256 _tokenId) private view returns (bool) {

    return PlayerIndexToApproved[_tokenId] == _to;
  }

  function _owns(address claimant, uint256 _tokenId) private view returns (bool) {

    return claimant == PlayerIndexToOwner[_tokenId];
  }

  function _payout(address _to) private {

    if (_to == address(0)) {
        ceoAddress.transfer(address(this).balance);
    } else {
      _to.transfer(address(this).balance);
    }
  }

  function _transfer(address _from, address _to, uint256 _tokenId) private {

    ownershipTokenCount[_to]++;
    PlayerIndexToOwner[_tokenId] = _to;

    if (_from != address(0)) {
      ownershipTokenCount[_from]--;
      delete PlayerIndexToApproved[_tokenId];
    }

    emit Transfer(_from, _to, _tokenId);
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