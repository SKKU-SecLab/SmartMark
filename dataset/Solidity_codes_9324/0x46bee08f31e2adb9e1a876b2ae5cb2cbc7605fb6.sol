
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

interface IERC20 {

    function totalSupply() external view returns (uint256);


    function balanceOf(address account) external view returns (uint256);


    function transfer(address to, uint256 amount) external returns (bool);


    function allowance(address owner, address spender) external view returns (uint256);


    function approve(address spender, uint256 amount) external returns (bool);


    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);


    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
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

interface IRoleProvider {

  function hasTheRole(bytes32 role, address theaddress) external returns(bool);

  function fetchAddress(bytes32 thevar) external returns(address);

  function hasContractRole(address theaddress) external view returns(bool);

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

}//*~~~> MIT make it better, stronger, faster


pragma solidity  0.8.7;


contract RewardsControl is ReentrancyGuard {


  address public roleAdd;

  uint public fee;

  bytes32 public constant DAO = keccak256("DAO");

  bytes32 public constant NFTADD = keccak256("NFT");

  bytes32 public constant MINT = keccak256("MINT");
  

  uint[] private openStorage;
  
  address private JON = 0x39a79815fA7431434E49757ED4118b873Ca1F580;
  
  address private WHALE = 0x41538872240Ef02D6eD9aC45cf4Ff864349D51ED;
  
  uint private devCount;
  uint private userCount;
  uint private nftHodlerCount;

  uint private tokenCount;

  mapping(uint256 => User) private idToUser; //Internal index => User
  mapping(uint256 => NftHodler) private nftIdToHodler; // Tracking NFT ids => Hodler placement, to limit claims
  mapping(address => User) private addressToUser;
  mapping(address => uint256) private addressToId; //For user Id
  mapping(address => uint256) private addressToTokenId; // For token Id
  mapping(address => uint256) public addressToRewardsId;
  mapping(uint256 => RewardsToken) public idToRewardsToken;
  mapping(uint256 => DevTeam) private idToDevTeam;
  mapping(address => uint256) private addressToDevTeamId;
  mapping(uint256 => ClaimClock) private idToClock;
  
  constructor(address newRole, address getPhunky) {
    roleAdd = newRole;
    addressToTokenId[getPhunky]=1;
    fee = 200;
  }

  struct User {
    bool canClaim;
    uint claims;
    uint timestamp;
    uint userId;
    address userAddress;
  }
  struct NftHodler {
    uint timestamp;
    uint hodlerId;
    uint tokenId;
  }
  struct DevTeam {
    uint timestamp;
    uint devId;
    address devAddress;
  }
  struct RewardsToken {
    uint tokenId;
    uint tokenAmount;
    address tokenAddress;
  }

  struct ClaimClock {
    uint alpha; // initial claim cutoff
    uint delta; // mid claim cutoff
    uint omega; // final claim cutoff
    uint howManyUsers; // total user count set with each distribution call
  }
  
  bytes32 public constant PROXY_ROLE = keccak256("PROXY_ROLE"); 
  bytes32 public constant DEV = keccak256("DEV"); 
  modifier hasAdmin(){

    require(IRoleProvider(roleAdd).hasTheRole(PROXY_ROLE, msg.sender), "DOES NOT HAVE ADMIN ROLE");
    _;
  }
  modifier hasDevAdmin(){

    require(IRoleProvider(roleAdd).hasTheRole(DEV, msg.sender), "DOES NOT HAVE DEV ROLE");
    _;
  }
  modifier hasContractAdmin(){

    require(IRoleProvider(roleAdd).hasContractRole(msg.sender), "DOES NOT HAVE CONTRACT ROLE");
    _;
  }

  function setRoleAddress(address newRole) external hasAdmin returns(bool){

    roleAdd = newRole;
    return true;
  }

  event NewUser(uint indexed userId, address indexed userAddress);
  event RewardsClaimed(address indexed userAddress, uint amount, uint[] erc20Amount, address[] contractAddress);
  event NewDev(address indexed devAddress);
  event RemovedDev(address indexed devAddress);
  event DevClaimed(address indexed devAddress, uint amount, uint[] erc20Amount, address[] contractAddress);
  event DaoClaimed(address indexed daoAddress, uint amount, uint[] erc20Amount, address[] contractAddress);
  event SetTime(uint indexed alpha, uint delta, uint omega, uint currentUserCount);
  event TokensReceived(address indexed tokenAddress, uint indexed amount);
  event Received(address from, uint value);

  function setFee(uint newFee) external hasAdmin returns (bool) {

    fee = newFee;
    return true;
  }

  function addDev(address devAddress) external hasDevAdmin nonReentrant returns(bool) {

    uint devLen = devCount;
    devLen+=1;
    uint id = devLen;
    idToDevTeam[id] = DevTeam(block.timestamp, id, devAddress);
    addressToDevTeamId[devAddress] = id;
    devCount=devLen;
    emit NewDev(devAddress);
    return true;
  }

  function removeDev(address devAddress) external hasDevAdmin nonReentrant returns(bool) {

    uint id = addressToDevTeamId[devAddress];
    idToDevTeam[id] = DevTeam(0, 0, address(0x0));
    addressToDevTeamId[devAddress] = 0;
    emit RemovedDev(devAddress);
    return true;
  }

  function createUser(address userAddress) external hasContractAdmin nonReentrant returns(bool) {

    uint userId;
    if(addressToId[userAddress] > 0){
      userId = addressToId[userAddress];
    } else {
      uint len = openStorage.length;
      if (len >= 1){
        userId = openStorage[len-1];
        removeStorage();
      } else {
        userCount;
        userId = userCount;
        addressToId[userAddress] = userId;
      }
    }
    User memory user = User(false, 0, block.timestamp, userId, userAddress);
    idToUser[userId] = user;
    addressToUser[userAddress] = user; 
    emit NewUser(userId, userAddress);
    return true;
  }

  function createNftHodler(uint tokenId) external hasContractAdmin nonReentrant returns(bool) {

    address mrktNft = IRoleProvider(roleAdd).fetchAddress(NFTADD);
    nftHodlerCount+=1;
    uint hodlerId = nftHodlerCount;
    NftHodler memory hodler = NftHodler(block.timestamp, hodlerId, tokenId);
    nftIdToHodler[tokenId] = hodler;
    emit NewUser(hodlerId, mrktNft);
    return true;
  }

  function createOGHodlers(uint[] memory tokenId) external hasDevAdmin nonReentrant returns(bool){

    address mrktNft = IRoleProvider(roleAdd).fetchAddress(NFTADD);
    uint count = nftHodlerCount;
    for (uint i=0; i<tokenId.length; i++){
      count+=1;
      uint hodlerId = count;
      NftHodler memory hodler = NftHodler(block.timestamp, hodlerId, tokenId[i]);
      nftIdToHodler[tokenId[i]] = hodler;
      emit NewUser(hodlerId, mrktNft);
    }
    nftHodlerCount=count;
    return true;
  }
  
  function setUser(bool canClaim, address userAddress) external hasContractAdmin nonReentrant returns(bool) {

    uint userId = addressToId[userAddress];
    User memory user = idToUser[userId];
    if(canClaim){
      idToUser[userId] = User(true, 0, user.timestamp, user.userId, userAddress);
    } else {
      openStorage.push(userId);
      idToUser[userId] = User(false, 0, 0, user.userId,  userAddress);
    }
    return true;
  }

  function setClaimClock() external nonReentrant {

    uint users = fetchUserAmnt();
    ClaimClock memory clock = idToClock[8];
    require(clock.alpha < (block.timestamp - 3 days));
    uint alpha = block.timestamp;
    uint delta = clock.alpha;
    uint omega = clock.delta;
    uint totalUsers = users + nftHodlerCount;
    idToClock[8] = ClaimClock(alpha, delta, omega, totalUsers);
    emit SetTime(alpha, delta, omega, totalUsers);
  }

  function claimRewards(address[] calldata contractAddress) external nonReentrant {

    uint id = addressToId[msg.sender];
    User memory user = idToUser[id];
    ClaimClock memory clock = idToClock[8];
    require(user.canClaim == true, "Ineligible!");
    uint userEthSplit = (address(this).balance - (address(this).balance / 3));
    uint userSplits = userEthSplit - (userEthSplit / clock.howManyUsers);
    if (user.timestamp < clock.alpha && user.timestamp > clock.delta){
      if (user.claims==0){
        require(sendEther(msg.sender, userSplits));
      uint tokenLen = contractAddress.length;
      for (uint i; i < tokenLen; i++) {
        uint tokenId = addressToRewardsId[contractAddress[i]];
        RewardsToken memory toke = idToRewardsToken[tokenId];
        if(toke.tokenAmount > 0){
          uint userErcSplits = (toke.tokenAmount - (toke.tokenAmount / 3));
          uint ercSplit = (userErcSplits / clock.howManyUsers);
          require(IERC20(toke.tokenAddress).transfer(payable(msg.sender), ercSplit));
          toke.tokenAmount = (toke.tokenAmount - ercSplit);
        }
        idToRewardsToken[tokenId] = RewardsToken(tokenId, toke.tokenAmount, toke.tokenAddress);
      }
        user.claims += 1;
      }
    }
    if (user.timestamp < clock.delta && user.timestamp > clock.omega){
      if(user.claims <= 1){
        require(sendEther(msg.sender, (userSplits / 2)));
      uint tokenLen = contractAddress.length;
      for (uint i; i < tokenLen; i++) {
        uint tokenId = addressToRewardsId[contractAddress[i]];
        RewardsToken memory toke = idToRewardsToken[tokenId];
        if(toke.tokenAmount > 0){
          uint userErcSplits = (toke.tokenAmount - (toke.tokenAmount / 3));
          uint ercSplit = ((userErcSplits / clock.howManyUsers) / 2);
          require(IERC20(toke.tokenAddress).transfer(payable(msg.sender), ercSplit));
          toke.tokenAmount = (toke.tokenAmount - ercSplit);
        }
        idToRewardsToken[tokenId] = RewardsToken(tokenId, toke.tokenAmount, toke.tokenAddress);
      }
        user.claims += 1;
      }
    }
    if (user.timestamp < clock.omega && user.claims <= 2){
        require(sendEther(msg.sender,(userSplits / 3)));
      uint tokenLen = contractAddress.length;
      for (uint i; i < tokenLen; i++) {
        uint tokenId = addressToRewardsId[contractAddress[i]];
        RewardsToken memory toke = idToRewardsToken[tokenId];
        if(toke.tokenAmount > 0){
          uint userErcSplits = (toke.tokenAmount - (toke.tokenAmount / 3));
          uint ercSplit = ((userErcSplits / clock.howManyUsers) / 3);
          require(IERC20(toke.tokenAddress).transfer(payable(msg.sender), ercSplit));
          toke.tokenAmount = (toke.tokenAmount - ercSplit);
        }
        idToRewardsToken[tokenId] = RewardsToken(tokenId, toke.tokenAmount, toke.tokenAddress);
      }
      user.claims += 1;
    }
    if(user.claims == 3){
      idToUser[user.userId] = User(false, 0, user.timestamp, user.userId, user.userAddress);
      clock.howManyUsers -= 1;
    } else {
      idToUser[user.userId] = User(true, user.claims, user.timestamp, user.userId, user.userAddress);
    }
    idToClock[8] = ClaimClock(clock.alpha, clock.delta, clock.omega, clock.howManyUsers);
  }

  function claimNFTRewards(uint nftId, address[] calldata contractAddress) external nonReentrant {

    ClaimClock memory clock = idToClock[8];
    
    address mrktNft = IRoleProvider(roleAdd).fetchAddress(NFTADD);

    require(IERC721(mrktNft).balanceOf(msg.sender) > 0, "Ineligible!");

    NftHodler memory hodler = nftIdToHodler[nftId];
    require(hodler.timestamp < (block.timestamp - 1 days));
    uint userRewards = (address(this).balance - (address(this).balance / 3));
    uint splits = userRewards - (userRewards / clock.howManyUsers);
    require(sendEther(msg.sender, splits));
    
    uint len = contractAddress.length;
    address[] memory adds;
    uint[] memory amnts;
    for (uint i; i < len; i++) {
      uint tokenId = addressToRewardsId[contractAddress[i]];
      RewardsToken memory toke = idToRewardsToken[tokenId];
      if(toke.tokenAmount > 0) {
        adds[i] = toke.tokenAddress;
        uint userSplit = (toke.tokenAmount - (toke.tokenAmount / 3));
        uint ercSplit = (userSplit / clock.howManyUsers);
        amnts[i] = ercSplit;
        require(IERC20(toke.tokenAddress).transfer(payable(msg.sender), ercSplit));
        toke.tokenAmount -= ercSplit;
      }
      idToRewardsToken[tokenId] = RewardsToken(tokenId, toke.tokenAmount, toke.tokenAddress);
    }
    idToClock[8] = ClaimClock(clock.alpha, clock.delta, clock.omega, clock.howManyUsers);
    emit RewardsClaimed(msg.sender, splits, amnts, adds);
  }

  function claimDevRewards(address[] calldata contractAddress) external nonReentrant {

    uint devId = addressToDevTeamId[msg.sender];
    require(devId>0);
    DevTeam memory dev = idToDevTeam[devId];
    address devMultiPass = IRoleProvider(roleAdd).fetchAddress(DEV);
    if(msg.sender != devMultiPass || msg.sender != dev.devAddress){
      require(msg.sender == WHALE || msg.sender == JON);
    }
    require(dev.timestamp < (block.timestamp - 1 days), "Ineligible!");
    uint len = contractAddress.length;
    address[] memory adds;
    uint[] memory amnts;
    for (uint i; i < len; i++) {
      uint tokenId = addressToRewardsId[contractAddress[i]];
      RewardsToken memory token = idToRewardsToken[tokenId];
      if(token.tokenAmount > 0){
        adds[i] = token.tokenAddress;
        uint devTokenSig = (token.tokenAmount / 24);
        uint devTokenSplit = (devTokenSig / devCount);
        if(msg.sender != devMultiPass){
          amnts[i] = devTokenSplit;
          require(IERC20(token.tokenAddress).transfer(payable(dev.devAddress), devTokenSplit));
          token.tokenAmount -= devTokenSplit;
        } else {
          amnts[i] = devTokenSig;
          require(IERC20(token.tokenAddress).transfer(payable(devMultiPass), devTokenSig));
          token.tokenAmount -= devTokenSig;
        }
        idToDevTeam[devId] = DevTeam(block.timestamp, devId, dev.devAddress);
      }
      idToRewardsToken[tokenId] = RewardsToken(tokenId, token.tokenAmount, token.tokenAddress);
    }
    uint devSig = (address(this).balance / 24);
    uint devSplit = (devSig / devCount);
    if(msg.sender != devMultiPass){
      require(sendEther(dev.devAddress, devSplit));
      emit DevClaimed(msg.sender, devSplit, amnts, adds);
    } else {
      require(sendEther(devMultiPass, devSig));
      emit DevClaimed(msg.sender, devSig, amnts, adds);
    }
  }

  function claimDaoRewards(address[] calldata tokenAddress) external nonReentrant {

    address daoAdd = IRoleProvider(roleAdd).fetchAddress(DAO);
    require(msg.sender == daoAdd);
    uint daoSplit = (address(this).balance / 3);
    uint daoAmount = (daoSplit - (daoSplit / 4));
    require(sendEther(daoAdd, daoAmount));
    uint count = tokenAddress.length;
    address[] memory adds;
    uint[] memory amnts;
    for (uint i; i < count; i++) {
      uint tokenId = addressToRewardsId[tokenAddress[i]];
      RewardsToken memory token = idToRewardsToken[tokenId];
      adds[i] = token.tokenAddress;
      uint daoTokenSplit = (token.tokenAmount / 3);
      uint daoTokenAmount = (daoTokenSplit - (daoTokenSplit / 4));
      if (daoTokenAmount > 0) {
        amnts[i] = daoTokenSplit;
        IERC20(token.tokenAddress).transfer(daoAdd, daoTokenAmount);
        token.tokenAmount -= daoTokenAmount;
        idToRewardsToken[tokenId] = RewardsToken(tokenId, token.tokenAmount, token.tokenAddress);
      }
    }
    emit DaoClaimed(msg.sender, daoAmount, amnts, adds);
  }

  function depositERC20Rewards(uint amount, address tokenAddress) external nonReentrant returns(bool){

    uint tokenId = addressToTokenId[tokenAddress];
    if(tokenId>0){
      RewardsToken memory reward = idToRewardsToken[tokenId];
      uint newAmnt = (reward.tokenAmount + amount);
      idToRewardsToken[tokenId] = RewardsToken(tokenId, newAmnt, tokenAddress);
    } else {
      tokenCount+=1;
      addressToTokenId[tokenAddress] = tokenCount;
      idToRewardsToken[tokenId] = RewardsToken(tokenId, amount, tokenAddress);
    }
    emit TokensReceived(tokenAddress, amount);
    return true;  
  }

  function removeStorage() internal {

      openStorage.pop();
    }

    function getFee() public view returns(uint){

    return fee;
  }  

  function fetchUsers() public view returns (User[] memory user){

    User[] memory users = new User[](userCount);
    for (uint i; i < userCount; i++) {
      if (idToUser[i+1].canClaim) {
        User storage currentUser = idToUser[i+1];
        users[i] = currentUser;
      }
    }
    return users;
  }

  function fetchHodler(uint tokenId) public view returns (NftHodler memory){

    NftHodler memory hodler = nftIdToHodler[tokenId];
    return hodler;
  }

  function fetchDevs() public view returns (DevTeam[] memory dev){

    DevTeam[] memory devs = new DevTeam[](devCount);
    for (uint i; i < devCount; i++) {
      if (idToDevTeam[i+1].devAddress != address(0x0)) {
        DevTeam storage currentDev = idToDevTeam[i+1];
        devs[i] = currentDev;
      }
    }
    return devs;
  }

  function fetchUserAmnt() public view returns (uint amount) {

    for (uint i; i < userCount; i++) {
      if (idToUser[i+1].canClaim == true) {
        amount++;
      }
    }
    return amount;
  }

  function fetchRewardTokens() public view returns (RewardsToken[] memory token){

    RewardsToken[] memory tokens = new RewardsToken[](tokenCount);
    for (uint i; i < tokenCount; i++) {
      tokens[i] = idToRewardsToken[i+1];
    }
    return tokens;
  }

  function fetchUserByAddress(address userAdd) public view returns (User memory user){

    user = addressToUser[userAdd]; 
    return user;
  }

  function fetchClaimTime() public view returns (ClaimClock memory time){

    return idToClock[8];
  }

  function fetchEthAmount() public view returns(uint totalEth){

    return address(this).balance;
  }

  function transferNft(address receiver, address nftContract, uint tokenId) nonReentrant public hasAdmin {

    IERC721(nftContract).safeTransferFrom(address(this), receiver, tokenId);
  }

  function transfer1155(address receiver, address nftContract, uint tokenId, uint amount) nonReentrant public hasAdmin {

    IERC1155(nftContract).safeTransferFrom(address(this), receiver, tokenId, amount, "");
  }

  function sendEther(address recipient, uint ethvalue) internal returns (bool){

    (bool success, bytes memory data) = address(recipient).call{value: ethvalue}("");
    return(success);
  }
  
  receive() external payable {
    emit Received(msg.sender, msg.value);
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