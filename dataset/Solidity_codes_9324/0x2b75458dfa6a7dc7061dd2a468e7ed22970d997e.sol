pragma solidity ^0.4.21;


contract ERC721Receiver {

  bytes4 constant ERC721_RECEIVED = 0xf0b9e5ba;

  function onERC721Received(address _from, uint256 _tokenId, bytes _data) public returns(bytes4);

}
pragma solidity ^0.4.18;


contract ERC721Basic {

  event Transfer(address indexed _from, address indexed _to, uint256 _tokenId, uint256 _timestamp);
  event Approval(address indexed _owner, address indexed _approved, uint256 _tokenId);
  event ApprovalForAll(address indexed _owner, address indexed _operator, bool _approved);

  function balanceOf(address _owner) public view returns (uint256 _balance);

  function ownerOf(uint256 _tokenId) public view returns (address _owner);

  function exists(uint256 _tokenId) public view returns (bool _exists);


  function approve(address _to, uint256 _tokenId) public;

  function getApproved(uint256 _tokenId) public view returns (address _operator);


  function setApprovalForAll(address _operator, bool _approved) public;

  function isApprovedForAll(address _owner, address _operator) public view returns (bool);


  function transferFrom(address _from, address _to, uint256 _tokenId) public;

  function safeTransferFrom(address _from, address _to, uint256 _tokenId) public;

  function safeTransferFrom(
    address _from,
    address _to,
    uint256 _tokenId,
    bytes _data
  )
  public;

}
pragma solidity ^0.4.18;



contract ERC721Enumerable is ERC721Basic {

  function totalSupply() public view returns (uint256);

  function tokenOfOwnerByIndex(address _owner, uint256 _index) public view returns (uint256 _tokenId);

  function tokenByIndex(uint256 _index) public view returns (uint256);

}


contract ERC721Metadata is ERC721Basic {

  function name() public view returns (string _name);

  function symbol() public view returns (string _symbol);

  function tokenURI(uint256 _tokenId) public view returns (address);

}


contract ERC721 is ERC721Basic, ERC721Enumerable, ERC721Metadata {

}
pragma solidity ^0.4.18;


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
pragma solidity ^0.4.18;


library AddressUtils {


  function isContract(address addr) internal view returns (bool) {

    uint256 size;
    assembly { size := extcodesize(addr) }  // solium-disable-line security/no-inline-assembly
    return size > 0;
  }

}
pragma solidity ^0.4.18;



contract ERC721BasicToken is ERC721Basic {

  using SafeMath for uint256;
  using AddressUtils for address;

  bytes4 constant ERC721_RECEIVED = 0xf0b9e5ba;

  mapping (uint256 => address) internal tokenOwner;

  mapping (uint256 => address) internal tokenApprovals;

  mapping (address => uint256) internal ownedTokensCount;

  mapping (address => mapping (address => bool)) internal operatorApprovals;

  modifier onlyOwnerOf(uint256 _tokenId) {

    require(ownerOf(_tokenId) == msg.sender);
    _;
  }

  modifier canTransfer(uint256 _tokenId) {

    require(isApprovedOrOwner(msg.sender, _tokenId));
    _;
  }

  function balanceOf(address _owner) public view returns (uint256) {

    require(_owner != address(0));
    return ownedTokensCount[_owner];
  }

  function ownerOf(uint256 _tokenId) public view returns (address) {

    address owner = tokenOwner[_tokenId];
    require(owner != address(0));
    return owner;
  }

  function exists(uint256 _tokenId) public view returns (bool) {

    address owner = tokenOwner[_tokenId];
    return owner != address(0);
  }

  function approve(address _to, uint256 _tokenId) public {

    address owner = ownerOf(_tokenId);
    require(_to != owner);
    require(msg.sender == owner || isApprovedForAll(owner, msg.sender));

    if (getApproved(_tokenId) != address(0) || _to != address(0)) {
      tokenApprovals[_tokenId] = _to;
      Approval(owner, _to, _tokenId);
    }
  }

  function getApproved(uint256 _tokenId) public view returns (address) {

    return tokenApprovals[_tokenId];
  }

  function setApprovalForAll(address _to, bool _approved) public {

    require(_to != msg.sender);
    operatorApprovals[msg.sender][_to] = _approved;
    ApprovalForAll(msg.sender, _to, _approved);
  }

  function isApprovedForAll(address _owner, address _operator) public view returns (bool) {

    return operatorApprovals[_owner][_operator];
  }

  function transferFrom(address _from, address _to, uint256 _tokenId) public canTransfer(_tokenId) {

    require(_from != address(0));
    require(_to != address(0));

    clearApproval(_from, _tokenId);
    removeTokenFrom(_from, _tokenId);
    addTokenTo(_to, _tokenId);

    Transfer(_from, _to, _tokenId, now);
  }

  function safeTransferFrom(
    address _from,
    address _to,
    uint256 _tokenId
  )
  public
  canTransfer(_tokenId)
  {

    safeTransferFrom(_from, _to, _tokenId, "");
  }

  function safeTransferFrom(
    address _from,
    address _to,
    uint256 _tokenId,
    bytes _data
  )
  public
  canTransfer(_tokenId)
  {

    transferFrom(_from, _to, _tokenId);
    require(checkAndCallSafeTransfer(_from, _to, _tokenId, _data));
  }

  function isApprovedOrOwner(address _spender, uint256 _tokenId) internal view returns (bool) {

    address owner = ownerOf(_tokenId);
    return _spender == owner || getApproved(_tokenId) == _spender || isApprovedForAll(owner, _spender);
  }

  function _mint(address _to, uint256 _tokenId) internal {

    require(_to != address(0));
    addTokenTo(_to, _tokenId);
    Transfer(address(0), _to, _tokenId, now);
  }

  function _burn(address _owner, uint256 _tokenId) internal {

    clearApproval(_owner, _tokenId);
    removeTokenFrom(_owner, _tokenId);
    Transfer(_owner, address(0), _tokenId, now);
  }

  function clearApproval(address _owner, uint256 _tokenId) internal {

    require(ownerOf(_tokenId) == _owner);
    if (tokenApprovals[_tokenId] != address(0)) {
      tokenApprovals[_tokenId] = address(0);
      Approval(_owner, address(0), _tokenId);
    }
  }

  function addTokenTo(address _to, uint256 _tokenId) internal {

    require(tokenOwner[_tokenId] == address(0));
    tokenOwner[_tokenId] = _to;
    ownedTokensCount[_to] = ownedTokensCount[_to].add(1);
  }

  function removeTokenFrom(address _from, uint256 _tokenId) internal {

    require(ownerOf(_tokenId) == _from);
    ownedTokensCount[_from] = ownedTokensCount[_from].sub(1);
    tokenOwner[_tokenId] = address(0);
  }

  function checkAndCallSafeTransfer(
    address _from,
    address _to,
    uint256 _tokenId,
    bytes _data
  )
  internal
  returns (bool)
  {

    if (!_to.isContract()) {
      return true;
    }
    bytes4 retval = ERC721Receiver(_to).onERC721Received(_from, _tokenId, _data);
    return (retval == ERC721_RECEIVED);
  }
}
pragma solidity ^0.4.18;



contract ERC721Token is ERC721, ERC721BasicToken {

  string internal name_;

  string internal symbol_;

  mapping(address => uint256[]) internal ownedTokens;

  mapping(uint256 => uint256) internal ownedTokensIndex;

  uint256[] internal allTokens;

  mapping(uint256 => uint256) internal allTokensIndex;

  mapping(uint256 => address) internal tokenURIs;

  function ERC721Token(string _name, string _symbol) public {

    name_ = _name;
    symbol_ = _symbol;
  }

  function name() public view returns (string) {

    return name_;
  }

  function symbol() public view returns (string) {

    return symbol_;
  }

  function tokenURI(uint256 _tokenId) public view returns (address) {

    require(exists(_tokenId));
    return tokenURIs[_tokenId];
  }

  function tokenOfOwnerByIndex(address _owner, uint256 _index) public view returns (uint256) {

    require(_index < balanceOf(_owner));
    return ownedTokens[_owner][_index];
  }

  function totalSupply() public view returns (uint256) {

    return allTokens.length;
  }

  function tokenByIndex(uint256 _index) public view returns (uint256) {

    require(_index < totalSupply());
    return allTokens[_index];
  }

  function _setTokenURI(uint256 _tokenId, address _uri) internal {

    require(exists(_tokenId));
    tokenURIs[_tokenId] = _uri;
  }

  function addTokenTo(address _to, uint256 _tokenId) internal {

    super.addTokenTo(_to, _tokenId);
    uint256 length = ownedTokens[_to].length;
    ownedTokens[_to].push(_tokenId);
    ownedTokensIndex[_tokenId] = length;
  }

  function removeTokenFrom(address _from, uint256 _tokenId) internal {

    super.removeTokenFrom(_from, _tokenId);

    uint256 tokenIndex = ownedTokensIndex[_tokenId];
    uint256 lastTokenIndex = ownedTokens[_from].length.sub(1);
    uint256 lastToken = ownedTokens[_from][lastTokenIndex];

    ownedTokens[_from][tokenIndex] = lastToken;
    ownedTokens[_from][lastTokenIndex] = 0;

    ownedTokens[_from].length--;
    ownedTokensIndex[_tokenId] = 0;
    ownedTokensIndex[lastToken] = tokenIndex;
  }

  function _mint(address _to, uint256 _tokenId) internal {

    super._mint(_to, _tokenId);

    allTokensIndex[_tokenId] = allTokens.length;
    allTokens.push(_tokenId);
  }
}



pragma solidity ^0.4.13;

contract DSAuthority {

  function canCall(
    address src, address dst, bytes4 sig
  ) public view returns (bool);

}

contract DSAuthEvents {

  event LogSetAuthority (address indexed authority);
  event LogSetOwner     (address indexed owner);
}

contract DSAuth is DSAuthEvents {

  DSAuthority  public  authority;
  address      public  owner;

  function DSAuth() public {

    owner = msg.sender;
    LogSetOwner(msg.sender);
  }

  function setOwner(address owner_)
  public
  auth
  {

    owner = owner_;
    LogSetOwner(owner);
  }

  function setAuthority(DSAuthority authority_)
  public
  auth
  {

    authority = authority_;
    LogSetAuthority(authority);
  }

  modifier auth {

    require(isAuthorized(msg.sender, msg.sig));
    _;
  }

  function isAuthorized(address src, bytes4 sig) internal view returns (bool) {

    if (src == address(this)) {
      return true;
    } else if (src == owner) {
      return true;
    } else if (authority == DSAuthority(0)) {
      return false;
    } else {
      return authority.canCall(src, this, sig);
    }
  }
}
pragma solidity ^0.4.18;



contract EternalDb is DSAuth {


  enum Types {UInt, String, Address, Bytes, Bytes32, Boolean, Int}

  event EternalDbEvent(bytes32[] records, uint[] values, uint timestamp);

  function EternalDb(){

  }


  mapping(bytes32 => uint) UIntStorage;

  function getUIntValue(bytes32 record) constant returns (uint){

    return UIntStorage[record];
  }

  function getUIntValues(bytes32[] records) constant returns (uint[] results){

    results = new uint[](records.length);
    for (uint i = 0; i < records.length; i++) {
      results[i] = UIntStorage[records[i]];
    }
  }

  function setUIntValue(bytes32 record, uint value)
  auth
  {

    UIntStorage[record] = value;
    bytes32[] memory records = new bytes32[](1);
    records[0] = record;
    uint[] memory values = new uint[](1);
    values[0] = value;
    emit EternalDbEvent(records, values, now);
  }

  function setUIntValues(bytes32[] records, uint[] values)
  auth
  {

    for (uint i = 0; i < records.length; i++) {
      UIntStorage[records[i]] = values[i];
    }
    emit EternalDbEvent(records, values, now);
  }

  function deleteUIntValue(bytes32 record)
  auth
  {

    delete UIntStorage[record];
  }


  mapping(bytes32 => string) StringStorage;

  function getStringValue(bytes32 record) constant returns (string){

    return StringStorage[record];
  }

  function setStringValue(bytes32 record, string value)
  auth
  {

    StringStorage[record] = value;
  }

  function deleteStringValue(bytes32 record)
  auth
  {

    delete StringStorage[record];
  }


  mapping(bytes32 => address) AddressStorage;

  function getAddressValue(bytes32 record) constant returns (address){

    return AddressStorage[record];
  }

  function setAddressValues(bytes32[] records, address[] values)
  auth
  {

    for (uint i = 0; i < records.length; i++) {
      AddressStorage[records[i]] = values[i];
    }
  }

  function setAddressValue(bytes32 record, address value)
  auth
  {

    AddressStorage[record] = value;
  }

  function deleteAddressValue(bytes32 record)
  auth
  {

    delete AddressStorage[record];
  }


  mapping(bytes32 => bytes) BytesStorage;

  function getBytesValue(bytes32 record) constant returns (bytes){

    return BytesStorage[record];
  }

  function setBytesValue(bytes32 record, bytes value)
  auth
  {

    BytesStorage[record] = value;
  }

  function deleteBytesValue(bytes32 record)
  auth
  {

    delete BytesStorage[record];
  }


  mapping(bytes32 => bytes32) Bytes32Storage;

  function getBytes32Value(bytes32 record) constant returns (bytes32){

    return Bytes32Storage[record];
  }

  function getBytes32Values(bytes32[] records) constant returns (bytes32[] results){

    results = new bytes32[](records.length);
    for (uint i = 0; i < records.length; i++) {
      results[i] = Bytes32Storage[records[i]];
    }
  }

  function setBytes32Value(bytes32 record, bytes32 value)
  auth
  {

    Bytes32Storage[record] = value;
  }

  function setBytes32Values(bytes32[] records, bytes32[] values)
  auth
  {

    for (uint i = 0; i < records.length; i++) {
      Bytes32Storage[records[i]] = values[i];
    }
  }

  function deleteBytes32Value(bytes32 record)
  auth
  {

    delete Bytes32Storage[record];
  }


  mapping(bytes32 => bool) BooleanStorage;

  function getBooleanValue(bytes32 record) constant returns (bool){

    return BooleanStorage[record];
  }

  function getBooleanValues(bytes32[] records) constant returns (bool[] results){

    results = new bool[](records.length);
    for (uint i = 0; i < records.length; i++) {
      results[i] = BooleanStorage[records[i]];
    }
  }

  function setBooleanValue(bytes32 record, bool value)
  auth
  {

    BooleanStorage[record] = value;
  }

  function setBooleanValues(bytes32[] records, bool[] values)
  auth
  {

    for (uint i = 0; i < records.length; i++) {
      BooleanStorage[records[i]] = values[i];
    }
  }

  function deleteBooleanValue(bytes32 record)
  auth
  {

    delete BooleanStorage[record];
  }

  mapping(bytes32 => int) IntStorage;

  function getIntValue(bytes32 record) constant returns (int){

    return IntStorage[record];
  }

  function getIntValues(bytes32[] records) constant returns (int[] results){

    results = new int[](records.length);
    for (uint i = 0; i < records.length; i++) {
      results[i] = IntStorage[records[i]];
    }
  }

  function setIntValue(bytes32 record, int value)
  auth
  {

    IntStorage[record] = value;
  }

  function setIntValues(bytes32[] records, int[] values)
  auth
  {

    for (uint i = 0; i < records.length; i++) {
      IntStorage[records[i]] = values[i];
    }
  }

  function deleteIntValue(bytes32 record)
  auth
  {

    delete IntStorage[record];
  }

}
pragma solidity ^0.4.18;

contract DelegateProxy {

  function delegatedFwd(address _dst, bytes _calldata) internal {

    require(isContract(_dst));
    assembly {
      let result := delegatecall(sub(gas, 10000), _dst, add(_calldata, 0x20), mload(_calldata), 0, 0)
      let size := returndatasize

      let ptr := mload(0x40)
      returndatacopy(ptr, 0, size)

      switch result case 0 {revert(ptr, size)}
      default {return (ptr, size)}
    }
  }

  function isContract(address _target) internal view returns (bool) {

    uint256 size;
    assembly {size := extcodesize(_target)}
    return size > 0;
  }
}pragma solidity ^0.4.18;



contract MutableForwarder is DelegateProxy, DSAuth {


  address public target = 0xBEeFbeefbEefbeEFbeEfbEEfBEeFbeEfBeEfBeef; // checksumed to silence warning

  function setTarget(address _target) public auth {

    target = _target;
  }

  function() payable {
    delegatedFwd(target, msg.data);
  }

}pragma solidity ^0.4.24;



contract Registry is DSAuth {

  address private dummyTarget; // Keep it here, because this contract is deployed as MutableForwarder

  bytes32 public constant challengePeriodDurationKey = sha3("challengePeriodDuration");
  bytes32 public constant commitPeriodDurationKey = sha3("commitPeriodDuration");
  bytes32 public constant revealPeriodDurationKey = sha3("revealPeriodDuration");
  bytes32 public constant depositKey = sha3("deposit");
  bytes32 public constant challengeDispensationKey = sha3("challengeDispensation");
  bytes32 public constant voteQuorumKey = sha3("voteQuorum");
  bytes32 public constant maxTotalSupplyKey = sha3("maxTotalSupply");
  bytes32 public constant maxAuctionDurationKey = sha3("maxAuctionDuration");

  event MemeConstructedEvent(address registryEntry, uint version, address creator, bytes metaHash, uint totalSupply, uint deposit, uint challengePeriodEnd);
  event MemeMintedEvent(address registryEntry, uint version, address creator, uint tokenStartId, uint tokenEndId, uint totalMinted);

  event ChallengeCreatedEvent(address registryEntry, uint version, address challenger, uint commitPeriodEnd, uint revealPeriodEnd, uint rewardPool, bytes metahash);
  event VoteCommittedEvent(address registryEntry, uint version, address voter, uint amount);
  event VoteRevealedEvent(address registryEntry, uint version, address voter, uint option);
  event VoteAmountClaimedEvent(address registryEntry, uint version, address voter);
  event VoteRewardClaimedEvent(address registryEntry, uint version, address voter, uint amount);
  event ChallengeRewardClaimedEvent(address registryEntry, uint version, address challenger, uint amount);

  event ParamChangeConstructedEvent(address registryEntry, uint version, address creator, address db, string key, uint value, uint deposit, uint challengePeriodEnd);
  event ParamChangeAppliedEvent(address registryEntry, uint version);

  EternalDb public db;
  bool private wasConstructed;

  function construct(EternalDb _db)
  external
  {

    require(address(_db) != 0x0, "Registry: Address can't be 0x0");

    db = _db;
    wasConstructed = true;
    owner = msg.sender;
  }

  modifier onlyFactory() {

    require(isFactory(msg.sender), "Registry: Sender should be factory");
    _;
  }

  modifier onlyRegistryEntry() {

    require(isRegistryEntry(msg.sender), "Registry: Sender should registry entry");
    _;
  }

  modifier notEmergency() {

    require(!isEmergency(),"Registry: Emergency mode is enable");
    _;
  }

  function setFactory(address _factory, bool _isFactory)
  external
  auth
  {

    db.setBooleanValue(sha3("isFactory", _factory), _isFactory);
  }

  function addRegistryEntry(address _registryEntry)
  external
  onlyFactory
  notEmergency
  {

    db.setBooleanValue(sha3("isRegistryEntry", _registryEntry), true);
  }

  function setEmergency(bool _isEmergency)
  external
  auth
  {

    db.setBooleanValue("isEmergency", _isEmergency);
  }

  function fireMemeConstructedEvent(uint version, address creator, bytes metaHash, uint totalSupply, uint deposit, uint challengePeriodEnd)
  public
  onlyRegistryEntry
  {

    emit MemeConstructedEvent(msg.sender, version, creator, metaHash, totalSupply, deposit, challengePeriodEnd);
  }

  function fireMemeMintedEvent(uint version, address creator, uint tokenStartId, uint tokenEndId, uint totalMinted)
  public
  onlyRegistryEntry
  {

    emit MemeMintedEvent(msg.sender, version, creator, tokenStartId, tokenEndId, totalMinted);
  }

  function fireChallengeCreatedEvent(uint version, address challenger, uint commitPeriodEnd, uint revealPeriodEnd, uint rewardPool, bytes metahash)
  public
  onlyRegistryEntry
  {

    emit ChallengeCreatedEvent(msg.sender, version,  challenger, commitPeriodEnd, revealPeriodEnd, rewardPool, metahash);
  }

  function fireVoteCommittedEvent(uint version, address voter, uint amount)
  public
  onlyRegistryEntry
  {

    emit VoteCommittedEvent(msg.sender, version, voter, amount);
  }

  function fireVoteRevealedEvent(uint version, address voter, uint option)
  public
  onlyRegistryEntry
  {

    emit VoteRevealedEvent(msg.sender, version, voter, option);
  }

  function fireVoteAmountClaimedEvent(uint version, address voter)
  public
  onlyRegistryEntry
  {

    emit VoteAmountClaimedEvent(msg.sender, version, voter);
  }

  function fireVoteRewardClaimedEvent(uint version, address voter, uint amount)
  public
  onlyRegistryEntry
  {

    emit VoteRewardClaimedEvent(msg.sender, version, voter, amount);
  }

  function fireChallengeRewardClaimedEvent(uint version, address challenger, uint amount)
  public
  onlyRegistryEntry
  {

    emit ChallengeRewardClaimedEvent(msg.sender, version, challenger, amount);
  }

  function fireParamChangeConstructedEvent(uint version, address creator, address db, string key, uint value, uint deposit, uint challengePeriodEnd)
  public
  onlyRegistryEntry
  {

    emit ParamChangeConstructedEvent(msg.sender, version, creator, db, key, value, deposit, challengePeriodEnd);
  }

  function fireParamChangeAppliedEvent(uint version)
  public
  onlyRegistryEntry
  {

    emit ParamChangeAppliedEvent(msg.sender, version);
  }

  function isFactory(address factory) public constant returns (bool) {

    return db.getBooleanValue(sha3("isFactory", factory));
  }

  function isRegistryEntry(address registryEntry) public constant returns (bool) {

    return db.getBooleanValue(sha3("isRegistryEntry", registryEntry));
  }

  function isEmergency() public constant returns (bool) {

    return db.getBooleanValue("isEmergency");
  }
}
pragma solidity ^0.4.24;



contract MemeToken is ERC721Token {

  Registry public registry;

  modifier onlyRegistryEntry() {

    require(registry.isRegistryEntry(msg.sender),"MemeToken: onlyRegistryEntry failed");
    _;
  }

  function MemeToken(Registry _registry)
  ERC721Token("MemeToken", "MEME")
  {

    registry = _registry;
  }

  function mint(address _to, uint256 _tokenId)
  onlyRegistryEntry
  public
  {

    super._mint(_to, _tokenId);
    tokenURIs[_tokenId] = msg.sender;
  }

  function safeTransferFromMulti(
    address _from,
    address _to,
    uint256[] _tokenIds,
    bytes _data
  ) {

    for (uint i = 0; i < _tokenIds.length; i++) {
      safeTransferFrom(_from, _to, _tokenIds[i], _data);
    }
  }
}
pragma solidity ^0.4.18;


contract Forwarder is DelegateProxy {

  address public constant target = 0x92268d9c15657f14c9b0d551b97e260467dbe585; // checksumed to silence warning

  function() payable {
    delegatedFwd(target, msg.data);
  }
}pragma solidity ^0.4.18;

contract Controlled {


  event ControllerChangedEvent(address newController);

  modifier onlyController { require(msg.sender == controller); _; }


  address public controller;

  function Controlled() public { controller = msg.sender;}


  function changeController(address _newController) public onlyController {

    controller = _newController;
    emit ControllerChangedEvent(_newController);
  }
}
pragma solidity ^0.4.18;

contract TokenController {

  function proxyPayment(address _owner) public payable returns(bool);


  function onTransfer(address _from, address _to, uint _amount) public returns(bool);


  function onApprove(address _owner, address _spender, uint _amount) public
  returns(bool);

}
pragma solidity ^0.4.18;




contract ApproveAndCallFallBack {

  function receiveApproval(address from, uint256 _amount, address _token, bytes _data) public;

}

contract MiniMeToken is Controlled {


  string public name;                //The Token's name: e.g. DigixDAO Tokens
  uint8 public decimals;             //Number of decimals of the smallest unit
  string public symbol;              //An identifier: e.g. REP
  string public version = 'MMT_0.2'; //An arbitrary versioning scheme


  struct  Checkpoint {

    uint128 fromBlock;

    uint128 value;
  }

  MiniMeToken public parentToken;

  uint public parentSnapShotBlock;

  uint public creationBlock;

  mapping (address => Checkpoint[]) balances;

  mapping (address => mapping (address => uint256)) allowed;

  Checkpoint[] totalSupplyHistory;

  bool public transfersEnabled;

  MiniMeTokenFactory public tokenFactory;


  function MiniMeToken(
    address _tokenFactory,
    address _parentToken,
    uint _parentSnapShotBlock,
    string _tokenName,
    uint8 _decimalUnits,
    string _tokenSymbol,
    bool _transfersEnabled
  ) public {

    tokenFactory = MiniMeTokenFactory(_tokenFactory);
    name = _tokenName;                                 // Set the name
    decimals = _decimalUnits;                          // Set the decimals
    symbol = _tokenSymbol;                             // Set the symbol
    parentToken = MiniMeToken(_parentToken);
    parentSnapShotBlock = _parentSnapShotBlock;
    transfersEnabled = _transfersEnabled;
    creationBlock = block.number;
  }



  function transfer(address _to, uint256 _amount) public returns (bool success) {

    require(transfersEnabled);
    doTransfer(msg.sender, _to, _amount);
    return true;
  }

  function transferFrom(address _from, address _to, uint256 _amount
  ) public returns (bool success) {


    if (msg.sender != controller) {
      require(transfersEnabled);

      require(allowed[_from][msg.sender] >= _amount);
      allowed[_from][msg.sender] -= _amount;
    }
    doTransfer(_from, _to, _amount);
    return true;
  }

  function doTransfer(address _from, address _to, uint _amount
  ) internal {


    if (_amount == 0) {
      Transfer(_from, _to, _amount);    // Follow the spec to louch the event when transfer 0
      return;
    }

    require(parentSnapShotBlock < block.number);

    require((_to != 0) && (_to != address(this)));

    var previousBalanceFrom = balanceOfAt(_from, block.number);

    require(previousBalanceFrom >= _amount);

    if (isContract(controller)) {
      require(TokenController(controller).onTransfer(_from, _to, _amount));
    }

    updateValueAtNow(balances[_from], previousBalanceFrom - _amount);

    var previousBalanceTo = balanceOfAt(_to, block.number);
    require(previousBalanceTo + _amount >= previousBalanceTo); // Check for overflow
    updateValueAtNow(balances[_to], previousBalanceTo + _amount);

    Transfer(_from, _to, _amount);

  }

  function balanceOf(address _owner) public constant returns (uint256 balance) {

    return balanceOfAt(_owner, block.number);
  }

  function approve(address _spender, uint256 _amount) public returns (bool success) {

    require(transfersEnabled);

    require((_amount == 0) || (allowed[msg.sender][_spender] == 0));

    if (isContract(controller)) {
      require(TokenController(controller).onApprove(msg.sender, _spender, _amount));
    }

    allowed[msg.sender][_spender] = _amount;
    Approval(msg.sender, _spender, _amount);
    return true;
  }

  function allowance(address _owner, address _spender
  ) public constant returns (uint256 remaining) {

    return allowed[_owner][_spender];
  }

  function approveAndCall(address _spender, uint256 _amount, bytes _extraData
  ) public returns (bool success) {

    require(approve(_spender, _amount));

    ApproveAndCallFallBack(_spender).receiveApproval(
      msg.sender,
      _amount,
      this,
      _extraData
    );

    return true;
  }

  function totalSupply() public constant returns (uint) {

    return totalSupplyAt(block.number);
  }



  function balanceOfAt(address _owner, uint _blockNumber) public constant
  returns (uint) {


    if ((balances[_owner].length == 0)
      || (balances[_owner][0].fromBlock > _blockNumber)) {
      if (address(parentToken) != 0) {
        return parentToken.balanceOfAt(_owner, min(_blockNumber, parentSnapShotBlock));
      } else {
        return 0;
      }

    } else {
      return getValueAt(balances[_owner], _blockNumber);
    }
  }

  function totalSupplyAt(uint _blockNumber) public constant returns(uint) {


    if ((totalSupplyHistory.length == 0)
      || (totalSupplyHistory[0].fromBlock > _blockNumber)) {
      if (address(parentToken) != 0) {
        return parentToken.totalSupplyAt(min(_blockNumber, parentSnapShotBlock));
      } else {
        return 0;
      }

    } else {
      return getValueAt(totalSupplyHistory, _blockNumber);
    }
  }


  function createCloneToken(
    string _cloneTokenName,
    uint8 _cloneDecimalUnits,
    string _cloneTokenSymbol,
    uint _snapshotBlock,
    bool _transfersEnabled
  ) public returns(address) {

    if (_snapshotBlock == 0) _snapshotBlock = block.number;
    MiniMeToken cloneToken = tokenFactory.createCloneToken(
      this,
      _snapshotBlock,
      _cloneTokenName,
      _cloneDecimalUnits,
      _cloneTokenSymbol,
      _transfersEnabled
    );

    cloneToken.changeController(msg.sender);

    NewCloneToken(address(cloneToken), _snapshotBlock);
    return address(cloneToken);
  }


  function generateTokens(address _owner, uint _amount
  ) public onlyController returns (bool) {

    uint curTotalSupply = totalSupply();
    require(curTotalSupply + _amount >= curTotalSupply); // Check for overflow
    uint previousBalanceTo = balanceOf(_owner);
    require(previousBalanceTo + _amount >= previousBalanceTo); // Check for overflow
    updateValueAtNow(totalSupplyHistory, curTotalSupply + _amount);
    updateValueAtNow(balances[_owner], previousBalanceTo + _amount);
    Transfer(0, _owner, _amount);
    return true;
  }


  function destroyTokens(address _owner, uint _amount
  ) onlyController public returns (bool) {

    uint curTotalSupply = totalSupply();
    require(curTotalSupply >= _amount);
    uint previousBalanceFrom = balanceOf(_owner);
    require(previousBalanceFrom >= _amount);
    updateValueAtNow(totalSupplyHistory, curTotalSupply - _amount);
    updateValueAtNow(balances[_owner], previousBalanceFrom - _amount);
    Transfer(_owner, 0, _amount);
    return true;
  }



  function enableTransfers(bool _transfersEnabled) public onlyController {

    transfersEnabled = _transfersEnabled;
  }


  function getValueAt(Checkpoint[] storage checkpoints, uint _block
  ) constant internal returns (uint) {

    if (checkpoints.length == 0) return 0;

    if (_block >= checkpoints[checkpoints.length-1].fromBlock)
      return checkpoints[checkpoints.length-1].value;
    if (_block < checkpoints[0].fromBlock) return 0;

    uint min = 0;
    uint max = checkpoints.length-1;
    while (max > min) {
      uint mid = (max + min + 1)/ 2;
      if (checkpoints[mid].fromBlock<=_block) {
        min = mid;
      } else {
        max = mid-1;
      }
    }
    return checkpoints[min].value;
  }

  function updateValueAtNow(Checkpoint[] storage checkpoints, uint _value
  ) internal  {

    if ((checkpoints.length == 0)
      || (checkpoints[checkpoints.length -1].fromBlock < block.number)) {
      Checkpoint storage newCheckPoint = checkpoints[ checkpoints.length++ ];
      newCheckPoint.fromBlock =  uint128(block.number);
      newCheckPoint.value = uint128(_value);
    } else {
      Checkpoint storage oldCheckPoint = checkpoints[checkpoints.length-1];
      oldCheckPoint.value = uint128(_value);
    }
  }

  function isContract(address _addr) constant internal returns(bool) {

    uint size;
    if (_addr == 0) return false;
    assembly {
      size := extcodesize(_addr)
    }
    return size>0;
  }

  function min(uint a, uint b) pure internal returns (uint) {

    return a < b ? a : b;
  }

  function () public payable {
    require(isContract(controller));
    require(TokenController(controller).proxyPayment.value(msg.value)(msg.sender));
  }


  function claimTokens(address _token) public onlyController {

    if (_token == 0x0) {
      controller.transfer(this.balance);
      return;
    }

    MiniMeToken token = MiniMeToken(_token);
    uint balance = token.balanceOf(this);
    token.transfer(controller, balance);
    ClaimedTokens(_token, controller, balance);
  }

  event ClaimedTokens(address indexed _token, address indexed _controller, uint _amount);
  event Transfer(address indexed _from, address indexed _to, uint256 _amount);
  event NewCloneToken(address indexed _cloneToken, uint _snapshotBlock);
  event Approval(
    address indexed _owner,
    address indexed _spender,
    uint256 _amount
  );

}



contract MiniMeTokenFactory {


  function createCloneToken(
    address _parentToken,
    uint _snapshotBlock,
    string _tokenName,
    uint8 _decimalUnits,
    string _tokenSymbol,
    bool _transfersEnabled
  ) public returns (MiniMeToken) {

    MiniMeToken newToken = new MiniMeToken(
      this,
      _parentToken,
      _snapshotBlock,
      _tokenName,
      _decimalUnits,
      _tokenSymbol,
      _transfersEnabled
    );

    newToken.changeController(msg.sender);
    return newToken;
  }
}
pragma solidity ^0.4.24;


library RegistryEntryLib {


  using SafeMath for uint;

  enum VoteOption {NoVote, VoteFor, VoteAgainst}

  enum Status {ChallengePeriod, CommitPeriod, RevealPeriod, Blacklisted, Whitelisted}

  struct Vote {
    bytes32 secretHash;
    VoteOption option;
    uint amount;
    uint revealedOn;
    uint claimedRewardOn;
    uint reclaimedVoteAmountOn;
  }

  struct Challenge {
    address challenger;
    uint voteQuorum;
    uint rewardPool;
    bytes metaHash;
    uint commitPeriodEnd;
    uint revealPeriodEnd;
    uint challengePeriodEnd;
    uint votesFor;
    uint votesAgainst;
    uint claimedRewardOn;
    mapping(address => Vote) vote;
  }




  function isVoteRevealPeriodActive(Challenge storage self)
    internal
    constant
    returns (bool) {

    return !isVoteCommitPeriodActive(self) && now <= self.revealPeriodEnd;
  }

  function isVoteRevealed(Challenge storage self, address _voter)
    internal
    constant
    returns (bool) {

    return self.vote[_voter].revealedOn > 0;
  }

  function isVoteRewardClaimed(Challenge storage self, address _voter)
    internal
    constant
    returns (bool) {

    return self.vote[_voter].claimedRewardOn > 0;
  }

  function isVoteAmountReclaimed(Challenge storage self, address _voter)
    internal
    constant
    returns (bool) {

    return self.vote[_voter].reclaimedVoteAmountOn > 0;
  }

  function isChallengeRewardClaimed(Challenge storage self)
    internal
    constant
    returns (bool) {

    return self.claimedRewardOn > 0;
  }

  function isChallengePeriodActive(Challenge storage self)
    internal
    constant
    returns (bool) {

    return now <= self.challengePeriodEnd;
  }

  function isWhitelisted(Challenge storage self)
    internal
    constant
    returns (bool) {

    return status(self) == Status.Whitelisted;
  }

  function isVoteCommitPeriodActive(Challenge storage self)
    internal
    constant
    returns (bool) {

    return now <= self.commitPeriodEnd;
  }

  function isVoteRevealPeriodOver(Challenge storage self)
    internal
    constant
    returns (bool) {

    return self.revealPeriodEnd > 0 && now > self.revealPeriodEnd;
  }

  function isWinningOptionVoteFor(Challenge storage self)
    internal
    constant
    returns (bool) {

    return winningVoteOption(self) == VoteOption.VoteFor;
  }

  function hasVoted(Challenge storage self, address _voter)
    internal
    constant
    returns (bool) {

    return self.vote[_voter].amount != 0;
  }

  function wasChallenged(Challenge storage self)
    internal
    constant
    returns (bool) {

    return self.challenger != 0x0;
  }

  function votedWinningVoteOption(Challenge storage self, address _voter)
    internal
    constant
    returns (bool) {

    return self.vote[_voter].option == winningVoteOption(self);
  }

  function status(Challenge storage self)
    internal
    constant
    returns (Status) {

    if (isChallengePeriodActive(self) && !wasChallenged(self)) {
      return Status.ChallengePeriod;
    } else if (isVoteCommitPeriodActive(self)) {
      return Status.CommitPeriod;
    } else if (isVoteRevealPeriodActive(self)) {
      return Status.RevealPeriod;
    } else if (isVoteRevealPeriodOver(self)) {
      if (isWinningOptionVoteFor(self)) {
        return Status.Whitelisted;
      } else {
        return Status.Blacklisted;
      }
    } else {
      return Status.Whitelisted;
    }
  }

  function challengeReward(Challenge storage self, uint deposit)
    internal
    constant
    returns (uint) {

    return deposit.sub(self.rewardPool);
  }

  function voteReward(Challenge storage self, address _voter)
    internal
    constant
    returns (uint) {

    uint winningAmount = winningVotesAmount(self);
    uint voterAmount = 0;

    if (!votedWinningVoteOption(self, _voter)) {
      return voterAmount;
    }

    voterAmount = self.vote[_voter].amount;
    return (voterAmount.mul(self.rewardPool)) / winningAmount;
  }

  function isChangeAllowed(Registry registry, bytes32 record, uint _value)
    internal
    constant
    returns (bool) {


      if(record == registry.challengePeriodDurationKey() || record == registry.commitPeriodDurationKey() ||
         record == registry.revealPeriodDurationKey() || record == registry.depositKey()) {
        if(_value > 0) {
          return true;
        }
      }

      if(record == registry.challengeDispensationKey() || record == registry.voteQuorumKey() ||
         record == registry.maxTotalSupplyKey()) {
        if (_value >= 0 && _value <= 100) {
          return true;
        }
      }

      if(record == registry.maxAuctionDurationKey()) {
        if(_value >= 1 minutes) {
          return true;
        }
      }

    return false;
  }


  function bytesToUint(bytes b)
    internal
    returns (uint256) {

    uint256 number;
    for(uint i = 0; i < b.length; i++){
      number = number + uint(b[i]) * (2 ** (8 * (b.length - (i + 1))));
    }
    return number;
  }

  function stringToUint(string s)
    internal
    constant
    returns (uint result) {

    bytes memory b = bytes(s);
    uint i;
    result = 0;
    for (i = 0; i < b.length; i++) {
      uint c = uint(b[i]);
      if (c >= 48 && c <= 57) {
        result = result * 10 + (c - 48);
      }
    }
  }


  function isBlacklisted(Challenge storage self)
    private
    constant
    returns (bool) {

    return status(self) == Status.Blacklisted;
  }

  function winningVoteOption(Challenge storage self)
    private
    constant
    returns (VoteOption) {

    if (!isVoteRevealPeriodOver(self)) {
      return VoteOption.NoVote;
    }

    if (self.votesFor.mul(100) > self.voteQuorum.mul(self.votesFor.add(self.votesAgainst))) {
      return VoteOption.VoteFor;
    } else {
      return VoteOption.VoteAgainst;
    }
  }

  function winningVotesAmount(Challenge storage self)
    private
    constant
    returns (uint) {

    VoteOption voteOption = winningVoteOption(self);

    if (voteOption == VoteOption.VoteFor) {
      return self.votesFor;
    } else if (voteOption == VoteOption.VoteAgainst) {
      return self.votesAgainst;
    } else {
      return 0;
    }
  }

}
pragma solidity ^0.4.24;



contract RegistryEntry is ApproveAndCallFallBack {

  using SafeMath for uint;
  using RegistryEntryLib for RegistryEntryLib.Challenge;

  Registry internal constant registry = Registry(0x770a2dd63d87d24f57fbec86118b0f88914246ed);
  MiniMeToken internal constant registryToken = MiniMeToken(0x0cb8d0b37c7487b11d57f1f33defa2b1d3cfccfe);

  address internal creator;
  uint internal version;
  uint internal deposit;
  RegistryEntryLib.Challenge internal challenge;

  modifier notEmergency() {

    require(!registry.isEmergency());
    _;
  }

  modifier onlyWhitelisted() {

    require(challenge.isWhitelisted());
    _;
  }

  function construct(
                     address _creator,
                     uint _version
                     )
    public
  {

    require(challenge.challengePeriodEnd == 0);
    deposit = registry.db().getUIntValue(registry.depositKey());
    require(registryToken.transferFrom(msg.sender, this, deposit));

    challenge.challengePeriodEnd = now.add(registry.db().getUIntValue(registry.challengePeriodDurationKey()));

    creator = _creator;
    version = _version;
  }

  function createChallenge(
                           address _challenger,
                           bytes _challengeMetaHash
                           )
    external
    notEmergency
  {

    require(challenge.isChallengePeriodActive());
    require(!challenge.wasChallenged());
    require(registryToken.transferFrom(_challenger, this, deposit));

    challenge.challenger = _challenger;
    challenge.voteQuorum = registry.db().getUIntValue(registry.voteQuorumKey());
    uint commitDuration = registry.db().getUIntValue(registry.commitPeriodDurationKey());
    uint revealDuration = registry.db().getUIntValue(registry.revealPeriodDurationKey());

    challenge.commitPeriodEnd = now.add(commitDuration);
    challenge.revealPeriodEnd = challenge.commitPeriodEnd.add(revealDuration);
    challenge.rewardPool = uint(100).sub(registry.db().getUIntValue(registry.challengeDispensationKey())).mul(deposit).div(uint(100));
    challenge.metaHash = _challengeMetaHash;

    registry.fireChallengeCreatedEvent(version,
                                       challenge.challenger,
                                       challenge.commitPeriodEnd,
                                       challenge.revealPeriodEnd,
                                       challenge.rewardPool,
                                       challenge.metaHash);
  }

  function commitVote(
                      address _voter,
                      uint _amount,
                      bytes32 _secretHash
                      )
    external
    notEmergency
  {

    require(challenge.isVoteCommitPeriodActive());
    require(_amount > 0);
    require(!challenge.hasVoted(_voter));
    require(registryToken.transferFrom(_voter, this, _amount));

    challenge.vote[_voter].secretHash = _secretHash;
    challenge.vote[_voter].amount += _amount;

    registry.fireVoteCommittedEvent(version,
                                    _voter,
                                    challenge.vote[_voter].amount);
  }

  function revealVote(
                      RegistryEntryLib.VoteOption _voteOption,
                      string _salt
                      )
    external
    notEmergency
  {

    address _voter=msg.sender;
    require(challenge.isVoteRevealPeriodActive());
    require(keccak256(abi.encodePacked(uint(_voteOption), _salt)) == challenge.vote[_voter].secretHash);
    require(!challenge.isVoteRevealed(_voter));

    challenge.vote[_voter].revealedOn = now;
    uint amount = challenge.vote[_voter].amount;
    require(registryToken.transfer(_voter, amount));
    challenge.vote[_voter].option = _voteOption;

    if (_voteOption == RegistryEntryLib.VoteOption.VoteFor) {
      challenge.votesFor = challenge.votesFor.add(amount);
    } else if (_voteOption == RegistryEntryLib.VoteOption.VoteAgainst) {
      challenge.votesAgainst = challenge.votesAgainst.add(amount);
    } else {
      revert();
    }

    registry.fireVoteRevealedEvent(version,
                                   _voter,
                                   uint(challenge.vote[_voter].option));
  }

  function reclaimVoteAmount(address _voter)
    public
    notEmergency {


    require(challenge.isVoteRevealPeriodOver());
    require(!challenge.isVoteRevealed(_voter));
    require(!challenge.isVoteAmountReclaimed(_voter));

    uint amount = challenge.vote[_voter].amount;
    require(registryToken.transfer(_voter, amount));

    challenge.vote[_voter].reclaimedVoteAmountOn = now;

    registry.fireVoteAmountClaimedEvent(version, _voter);
  }


  function claimRewards(address _user)
    external
    notEmergency
  {

    if(challenge.isVoteRevealPeriodOver() &&
       !challenge.isChallengeRewardClaimed() &&
       !challenge.isWinningOptionVoteFor() &&
       challenge.challenger == _user){

      registryToken.transfer(challenge.challenger, challenge.challengeReward(deposit));

      registry.fireChallengeRewardClaimedEvent(version,
                                               challenge.challenger,
                                               challenge.challengeReward(deposit));
    }

    if(challenge.isVoteRevealPeriodOver() &&
       !challenge.isVoteRewardClaimed(_user) &&
       challenge.isVoteRevealed(_user) &&
       challenge.votedWinningVoteOption(_user)){

      uint reward = challenge.voteReward(_user);

      if(reward > 0){
        registryToken.transfer(_user, reward);
        challenge.vote[_user].claimedRewardOn = now;

        registry.fireVoteRewardClaimedEvent(version,
                                            _user,
                                            reward);
      }
    }
  }

  function status()
    external
    constant
    returns (uint)
  {

    return uint(challenge.status());
  }

  function receiveApproval(
                           address _from,
                           uint256 _amount,
                           address _token,
                           bytes _data)
    public
  {

    require(address(this).call(_data));
  }

  function load() external constant returns (uint,
                                             address,
                                             uint,
                                             address,
                                             uint,
                                             uint,
                                             uint,
                                             uint,
                                             bytes,
                                             uint){

    return (deposit,
            creator,
            version,
            challenge.challenger,
            challenge.voteQuorum,
            challenge.commitPeriodEnd,
            challenge.revealPeriodEnd,
            challenge.rewardPool,
            challenge.metaHash,
            challenge.claimedRewardOn);
  }

  function loadVote(address voter) external constant returns (bytes32,
                                                              uint,
                                                              uint,
                                                              uint,
                                                              uint,
                                                              uint){

    return(challenge.vote[voter].secretHash,
           uint(challenge.vote[voter].option),
           challenge.vote[voter].amount,
           challenge.vote[voter].revealedOn,
           challenge.vote[voter].claimedRewardOn,
           challenge.vote[voter].reclaimedVoteAmountOn);
  }
}
pragma solidity ^0.4.24;


contract DistrictConfig is DSAuth {

  address public depositCollector;
  address public memeAuctionCutCollector;
  uint public memeAuctionCut; // Values 0-10,000 map to 0%-100%

  function DistrictConfig(address _depositCollector, address _memeAuctionCutCollector, uint _memeAuctionCut) {

    require(_depositCollector != 0x0, "District Config deposit collector isn't 0x0");
    require(_memeAuctionCutCollector != 0x0, "District Config meme auction cut collector isn't 0x0");
    require(_memeAuctionCut < 10000, "District Config meme auction cut should be < 1000");
    depositCollector = _depositCollector;
    memeAuctionCutCollector = _memeAuctionCutCollector;
    memeAuctionCut = _memeAuctionCut;
  }

  function setDepositCollector(address _depositCollector) public auth {

    require(_depositCollector != 0x0, "District Config deposit collector isn't 0x0");
    depositCollector = _depositCollector;
  }

  function setMemeAuctionCutCollector(address _memeAuctionCutCollector) public auth {

    require(_memeAuctionCutCollector != 0x0, "District Config meme auction cut collector isn't 0x0");
    memeAuctionCutCollector = _memeAuctionCutCollector;
  }

  function setCollectors(address _collector) public auth {

    setDepositCollector(_collector);
    setMemeAuctionCutCollector(_collector);
  }

  function setMemeAuctionCut(uint _memeAuctionCut) public auth {

    require(_memeAuctionCut < 10000, "District Config meme auction cut should be < 1000");
    memeAuctionCut = _memeAuctionCut;
  }
}
pragma solidity ^0.4.24;



contract Meme is RegistryEntry {


  DistrictConfig private constant districtConfig = DistrictConfig(0xABCDabcdABcDabcDaBCDAbcdABcdAbCdABcDABCd);
  MemeToken private constant memeToken = MemeToken(0xdaBBdABbDABbDabbDaBbDabbDaBbdaBbdaBbDAbB);
  bytes private metaHash;
  uint private tokenIdStart;
  uint private totalSupply;
  uint private totalMinted;

  function construct(
                     address _creator,
                     uint _version,
                     bytes _metaHash,
                     uint _totalSupply
                     )
    external
  {

    super.construct(_creator, _version);

    require(_totalSupply > 0);
    require(_totalSupply <= registry.db().getUIntValue(registry.maxTotalSupplyKey()));

    totalSupply = _totalSupply;
    metaHash = _metaHash;

    registry.fireMemeConstructedEvent(version,
                                      _creator,
                                      metaHash,
                                      totalSupply,
                                      deposit,
                                      challenge.challengePeriodEnd);
  }

  function transferDeposit()
    external
    notEmergency
    onlyWhitelisted
  {

    require(registryToken.transfer(districtConfig.depositCollector(), deposit));

  }

  function mint(uint _amount)
    public
    notEmergency
    onlyWhitelisted
  {

    uint restSupply = totalSupply.sub(totalMinted);
    if (_amount == 0 || _amount > restSupply) {
      _amount = restSupply;
    }

    require(_amount > 0);

    tokenIdStart = memeToken.totalSupply().add(1);
    uint tokenIdEnd = tokenIdStart.add(_amount);
    for (uint i = tokenIdStart; i < tokenIdEnd; i++) {
      memeToken.mint(creator, i);
      totalMinted = totalMinted + 1;
    }

    registry.fireMemeMintedEvent(version,
                                 creator,
                                 tokenIdStart,
                                 tokenIdEnd-1,
                                 totalMinted);
  }

  function loadMeme() external constant returns (bytes,
                                                 uint,
                                                 uint,
                                                 uint){

    return(metaHash,
           totalSupply,
           totalMinted,
           tokenIdStart);
  }

}
pragma solidity ^0.4.24;


contract MemeAuction is ERC721Receiver {

  using SafeMath for uint;

  DistrictConfig public constant districtConfig = DistrictConfig(0xABCDabcdABcDabcDaBCDAbcdABcdAbCdABcDABCd);
  Registry public constant registry = Registry(0xfEEDFEEDfeEDFEedFEEdFEEDFeEdfEEdFeEdFEEd);
  MemeToken public constant memeToken = MemeToken(0xdaBBdABbDABbDabbDaBbDabbDaBbdaBbdaBbDAbB);
  MemeAuctionFactory public constant memeAuctionFactory = MemeAuctionFactory(0xdAFfDaFfDAfFDAFFDafFdAfFdAffdAffDAFFdAFF);
  address public seller;
  uint public tokenId;
  uint public startPrice;
  uint public endPrice;
  uint public duration;
  uint public startedOn;
  string public description;

  modifier notEmergency() {

    require(!registry.isEmergency(),"MemeAuction: Emergency mode enabled");
    _;
  }

  function construct(address _seller, uint _tokenId)
  external
  notEmergency
  {

    require(_seller != 0x0,"MemeAuction: _seller is 0x0");
    require(seller == 0x0, "MemeAcution: seller is 0x0");
    seller = _seller;
    tokenId = _tokenId;
  }

  function startAuction(uint _startPrice, uint _endPrice, uint _duration, string _description)
  external
  notEmergency
  {

    require(memeToken.ownerOf(tokenId) == address(this), "MemeAuction: Not the owner of the token");
    require(startedOn == 0, "MemeAuction: Already started");
    require(_duration <= registry.db().getUIntValue(registry.maxAuctionDurationKey()),"MemeAuction: duration > maxDurationKey");
    require(_duration >= 1 minutes, "MemeAuction: duration < 1 minute");

    startPrice = _startPrice;
    description = _description;
    endPrice = _endPrice;
    duration = _duration;
    startedOn = now;
    memeAuctionFactory.fireMemeAuctionStartedEvent(tokenId,
                                                   seller,
                                                   startPrice,
                                                   endPrice,
                                                   duration,
                                                   description,
                                                   startedOn);
  }

  function buy()
  payable
  public
  notEmergency
  {

    require(startedOn > 0, "MemeAuction: Can't buy because not started");
    var price = currentPrice();
    require(msg.value >= price, "MemeAuction: Can't buy because money sent is lower than price");
    uint auctioneerCut = 0;
    uint sellerProceeds = 0;
    if (price > 0) {
      auctioneerCut = computeCut(price);
      sellerProceeds = price.sub(auctioneerCut);

      seller.transfer(sellerProceeds);
      if (msg.value > price) {
        msg.sender.transfer(msg.value.sub(price));
      }
      if (auctioneerCut > 0) {
        districtConfig.memeAuctionCutCollector().transfer(auctioneerCut);
      }
    }
    memeToken.safeTransferFrom(this, msg.sender, tokenId);

    memeAuctionFactory.fireMemeAuctionBuyEvent(msg.sender,
                                               price,
                                               auctioneerCut,
                                               sellerProceeds);
  }

  function cancel()
  external
  {

    require(startedOn > 0, "MemeAuction: Can't cancel because not started");
    require(msg.sender == seller, "MemeAuction: Can't cancel because sender is not seller");

    memeToken.safeTransferFrom(this, seller, tokenId);
    memeAuctionFactory.fireMemeAuctionCanceledEvent();
  }

  function onERC721Received(address _from, uint256 _tokenId, bytes _data)
  public
  notEmergency
  returns (bytes4)
  {

    require(_tokenId == tokenId, "MemeAuction: _tokenId is not tokenId");
    require(startedOn == 0, "MemeAuction: Already started");
    require(this.call(_data), "MemeAuction: No data to call");
    return ERC721_RECEIVED;
  }

  function currentPrice()
  public
  constant
  returns (uint256)
  {

    uint256 secondsPassed = 0;

    if (now > startedOn) {
      secondsPassed = now - startedOn;
    }

    return _computeCurrentPrice(
      startPrice,
      endPrice,
      duration,
      secondsPassed
    );
  }

  function _computeCurrentPrice(
    uint256 _startingPrice,
    uint256 _endingPrice,
    uint256 _duration,
    uint256 _secondsPassed
  )
  internal
  pure
  returns (uint256)
  {

    if (_secondsPassed >= _duration) {
      return _endingPrice;
    } else {
      int256 totalPriceChange = int256(_endingPrice) - int256(_startingPrice);

      int256 currentPriceChange = totalPriceChange * int256(_secondsPassed) / int256(_duration);

      int256 currentPrice = int256(_startingPrice) + currentPriceChange;

      return uint256(currentPrice);
    }
  }

  function computeCut(uint256 _price)
    public
    constant
    returns (uint256) {

    return _price.mul(districtConfig.memeAuctionCut()).div(10000);
  }

  function() public payable {
    buy();
  }

  function load() external constant returns (address,
                                             uint,
                                             uint,
                                             uint,
                                             uint,
                                             uint,
                                             string){

    return(seller,
           tokenId,
           startPrice,
           endPrice,
           duration,
           startedOn,
           description);
  }
}
pragma solidity ^0.4.24;


contract MemeAuctionFactory is ERC721Receiver {

  address private dummyTarget; // Keep it here, because this contract is deployed as MutableForwarder

  event MemeAuctionStartedEvent(address indexed memeAuction,
                                uint tokenId,
                                address seller,
                                uint startPrice,
                                uint endPrice,
                                uint duration,
                                string description,
                                uint startedOn);

  event MemeAuctionBuyEvent(address indexed memeAuction,
                            address buyer,
                            uint price,
                            uint auctioneerCut,
                            uint sellerProceeds);

  event MemeAuctionCanceledEvent(address indexed memeAuction);


  MemeToken public memeToken;
  bool public wasConstructed;
  mapping(address => bool) public isMemeAuction;

  modifier onlyMemeAuction() {

    require(isMemeAuction[msg.sender], "MemeAuctionFactory: onlyMemeAuction falied");
    _;
  }

  function construct(MemeToken _memeToken) public {

    require(address(_memeToken) != 0x0, "MemeAuctionFactory: _memeToken address is 0x0");
    require(!wasConstructed, "MemeAuctionFactory: Was already constructed");

    memeToken = _memeToken;
    wasConstructed = true;
  }

  function onERC721Received(address _from, uint256 _tokenId, bytes _data) public returns (bytes4) {

    address memeAuction = new Forwarder();
    isMemeAuction[memeAuction] = true;
    MemeAuction(memeAuction).construct(_from, _tokenId);
    memeToken.safeTransferFrom(address(this), memeAuction, _tokenId, _data);
    return ERC721_RECEIVED;
  }

  function fireMemeAuctionStartedEvent(uint tokenId, address seller, uint startPrice, uint endPrice, uint duration, string description, uint startedOn)
    onlyMemeAuction
  {

    emit MemeAuctionStartedEvent(msg.sender,
                                 tokenId,
                                 seller,
                                 startPrice,
                                 endPrice,
                                 duration,
                                 description,
                                 startedOn);
  }

  function fireMemeAuctionBuyEvent(address buyer, uint price, uint auctioneerCut, uint sellerProceeds)
    onlyMemeAuction
  {

    emit MemeAuctionBuyEvent(msg.sender, buyer, price, auctioneerCut, sellerProceeds);
  }

  function fireMemeAuctionCanceledEvent()
    onlyMemeAuction
  {

    emit MemeAuctionCanceledEvent(msg.sender);
  }

}
