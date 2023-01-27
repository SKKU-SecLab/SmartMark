
pragma solidity ^0.8.0;

abstract contract Initializable {
    bool private _initialized;

    bool private _initializing;

    modifier initializer() {
        require(_initializing || !_initialized, "Initializable: contract is already initialized");

        bool isTopLevelCall = !_initializing;
        if (isTopLevelCall) {
            _initializing = true;
            _initialized = true;
        }

        _;

        if (isTopLevelCall) {
            _initializing = false;
        }
    }
}// MIT

pragma solidity ^0.8.0;

library AddressUpgradeable {

    function isContract(address account) internal view returns (bool) {


        uint256 size;
        assembly {
            size := extcodesize(account)
        }
        return size > 0;
    }

    function sendValue(address payable recipient, uint256 amount) internal {

        require(address(this).balance >= amount, "Address: insufficient balance");

        (bool success, ) = recipient.call{value: amount}("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    function functionCall(address target, bytes memory data) internal returns (bytes memory) {

        return functionCall(target, data, "Address: low-level call failed");
    }

    function functionCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {

        return functionCallWithValue(target, data, 0, errorMessage);
    }

    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value
    ) internal returns (bytes memory) {

        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value,
        string memory errorMessage
    ) internal returns (bytes memory) {

        require(address(this).balance >= value, "Address: insufficient balance for call");
        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{value: value}(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {

        return functionStaticCall(target, data, "Address: low-level static call failed");
    }

    function functionStaticCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal view returns (bytes memory) {

        require(isContract(target), "Address: static call to non-contract");

        (bool success, bytes memory returndata) = target.staticcall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    function verifyCallResult(
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) internal pure returns (bytes memory) {

        if (success) {
            return returndata;
        } else {
            if (returndata.length > 0) {

                assembly {
                    let returndata_size := mload(returndata)
                    revert(add(32, returndata), returndata_size)
                }
            } else {
                revert(errorMessage);
            }
        }
    }
}// MIT

pragma solidity ^0.8.0;

library CountersUpgradeable {

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

library EnumerableSetUpgradeable {


    struct Set {
        bytes32[] _values;
        mapping(bytes32 => uint256) _indexes;
    }

    function _add(Set storage set, bytes32 value) private returns (bool) {

        if (!_contains(set, value)) {
            set._values.push(value);
            set._indexes[value] = set._values.length;
            return true;
        } else {
            return false;
        }
    }

    function _remove(Set storage set, bytes32 value) private returns (bool) {

        uint256 valueIndex = set._indexes[value];

        if (valueIndex != 0) {

            uint256 toDeleteIndex = valueIndex - 1;
            uint256 lastIndex = set._values.length - 1;

            if (lastIndex != toDeleteIndex) {
                bytes32 lastvalue = set._values[lastIndex];

                set._values[toDeleteIndex] = lastvalue;
                set._indexes[lastvalue] = valueIndex; // Replace lastvalue's index to valueIndex
            }

            set._values.pop();

            delete set._indexes[value];

            return true;
        } else {
            return false;
        }
    }

    function _contains(Set storage set, bytes32 value) private view returns (bool) {

        return set._indexes[value] != 0;
    }

    function _length(Set storage set) private view returns (uint256) {

        return set._values.length;
    }

    function _at(Set storage set, uint256 index) private view returns (bytes32) {

        return set._values[index];
    }

    function _values(Set storage set) private view returns (bytes32[] memory) {

        return set._values;
    }


    struct Bytes32Set {
        Set _inner;
    }

    function add(Bytes32Set storage set, bytes32 value) internal returns (bool) {

        return _add(set._inner, value);
    }

    function remove(Bytes32Set storage set, bytes32 value) internal returns (bool) {

        return _remove(set._inner, value);
    }

    function contains(Bytes32Set storage set, bytes32 value) internal view returns (bool) {

        return _contains(set._inner, value);
    }

    function length(Bytes32Set storage set) internal view returns (uint256) {

        return _length(set._inner);
    }

    function at(Bytes32Set storage set, uint256 index) internal view returns (bytes32) {

        return _at(set._inner, index);
    }

    function values(Bytes32Set storage set) internal view returns (bytes32[] memory) {

        return _values(set._inner);
    }


    struct AddressSet {
        Set _inner;
    }

    function add(AddressSet storage set, address value) internal returns (bool) {

        return _add(set._inner, bytes32(uint256(uint160(value))));
    }

    function remove(AddressSet storage set, address value) internal returns (bool) {

        return _remove(set._inner, bytes32(uint256(uint160(value))));
    }

    function contains(AddressSet storage set, address value) internal view returns (bool) {

        return _contains(set._inner, bytes32(uint256(uint160(value))));
    }

    function length(AddressSet storage set) internal view returns (uint256) {

        return _length(set._inner);
    }

    function at(AddressSet storage set, uint256 index) internal view returns (address) {

        return address(uint160(uint256(_at(set._inner, index))));
    }

    function values(AddressSet storage set) internal view returns (address[] memory) {

        bytes32[] memory store = _values(set._inner);
        address[] memory result;

        assembly {
            result := store
        }

        return result;
    }


    struct UintSet {
        Set _inner;
    }

    function add(UintSet storage set, uint256 value) internal returns (bool) {

        return _add(set._inner, bytes32(value));
    }

    function remove(UintSet storage set, uint256 value) internal returns (bool) {

        return _remove(set._inner, bytes32(value));
    }

    function contains(UintSet storage set, uint256 value) internal view returns (bool) {

        return _contains(set._inner, bytes32(value));
    }

    function length(UintSet storage set) internal view returns (uint256) {

        return _length(set._inner);
    }

    function at(UintSet storage set, uint256 index) internal view returns (uint256) {

        return uint256(_at(set._inner, index));
    }

    function values(UintSet storage set) internal view returns (uint256[] memory) {

        bytes32[] memory store = _values(set._inner);
        uint256[] memory result;

        assembly {
            result := store
        }

        return result;
    }
}// MIT

pragma solidity ^0.8.0;

abstract contract ReentrancyGuardUpgradeable is Initializable {

    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    function __ReentrancyGuard_init() internal initializer {
        __ReentrancyGuard_init_unchained();
    }

    function __ReentrancyGuard_init_unchained() internal initializer {
        _status = _NOT_ENTERED;
    }

    modifier nonReentrant() {
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        _status = _ENTERED;

        _;

        _status = _NOT_ENTERED;
    }
    uint256[49] private __gap;
}// MIT

pragma solidity ^0.8.0;

abstract contract ContextUpgradeable is Initializable {
    function __Context_init() internal initializer {
        __Context_init_unchained();
    }

    function __Context_init_unchained() internal initializer {
    }
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
    uint256[50] private __gap;
}// MIT

pragma solidity ^0.8.0;


abstract contract PausableUpgradeable is Initializable, ContextUpgradeable {
    event Paused(address account);

    event Unpaused(address account);

    bool private _paused;

    function __Pausable_init() internal initializer {
        __Context_init_unchained();
        __Pausable_init_unchained();
    }

    function __Pausable_init_unchained() internal initializer {
        _paused = false;
    }

    function paused() public view virtual returns (bool) {
        return _paused;
    }

    modifier whenNotPaused() {
        require(!paused(), "Pausable: paused");
        _;
    }

    modifier whenPaused() {
        require(paused(), "Pausable: not paused");
        _;
    }

    function _pause() internal virtual whenNotPaused {
        _paused = true;
        emit Paused(_msgSender());
    }

    function _unpause() internal virtual whenPaused {
        _paused = false;
        emit Unpaused(_msgSender());
    }
    uint256[49] private __gap;
}// MIT

pragma solidity ^0.8.0;


abstract contract OwnableUpgradeable is Initializable, ContextUpgradeable {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    function __Ownable_init() internal initializer {
        __Context_init_unchained();
        __Ownable_init_unchained();
    }

    function __Ownable_init_unchained() internal initializer {
        _transferOwnership(_msgSender());
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }

    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
    uint256[49] private __gap;
}// MIT

pragma solidity ^0.8.0;

interface IERC20Upgradeable {

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
}// MIT LICENSE
pragma solidity ^0.8.7;




interface HeadStaking {

    function depositsOf(address account) external view returns (uint256[] memory);

}

interface IHead {

    function mint(address to, uint256 amount) external;

    function burn(address from, uint256 amount) external;

    function updateOriginAccess() external;

    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

}

interface IStaking {

  function stakeMany(address account, uint16[] calldata tokenIds) external;

  function randomHunterOwner(uint256 seed) external view returns (address);

}

interface IMint {

  struct Traits {uint8 alphaIndex; bool isHunter;}
  function getPaidTokens() external view returns (uint256);

  function getTokenTraits(uint256 tokenId) external view returns (Traits memory);

  function minted() external view returns (uint16);

  function mint(address recipient) external;


}

contract paymentContract is ReentrancyGuardUpgradeable, OwnableUpgradeable, PausableUpgradeable  {

  
  IStaking public stakingContract;                                          
  IHead public ERC20Token;               
  IMint public ERC721Contract;      
  HeadStaking public HeadDAOStaking;   

  
  using AddressUpgradeable for address;
  using EnumerableSetUpgradeable for EnumerableSetUpgradeable.UintSet; 
  using CountersUpgradeable for CountersUpgradeable.Counter;



  struct PendingCommits {bool stake; uint16 amount;}

  uint256 public HeadDaoMinted;
  uint256 public HeadDAOExpiry;
  uint256 private pendingMintAmt;

  bool public hasPublicSaleStarted;

  mapping (address => uint256) public daoMints;
  mapping (address => bool)     private whitelistedContracts;    
  mapping(uint256 => uint256) private _tokenIndex; 
  mapping(address => uint256) private _pendingCommitId;  
  mapping(address => mapping(uint256 => PendingCommits)) private _pendingCommits;        
  mapping (uint16 => bool) public daoUsedTokens;  
  mapping(address => bool)      public  whitelists;           

  uint256 public MAX_TOKENS;    
  uint256 private PAID_TOKENS;         
  uint256 public MINT_PRICE;    

  uint256[] internal seeds;  
  uint256 seed_interval;
  uint256 _nextID;

  function initialize(uint256 _maxTokens) initializer public {


    __Ownable_init();
    __ReentrancyGuard_init();
    __Pausable_init();
    _pause();

    MINT_PRICE = 0.07 ether;   
    MAX_TOKENS = _maxTokens;
    PAID_TOKENS = _maxTokens / 5;
    _nextID = 0;
    seed_interval = 100;
    HeadDAOExpiry = block.timestamp + 172800;

    _addSeed();


  }


  function commitMint(uint256 amount, bool stake) external payable whenNotPaused {

    address msgSender = _msgSender();
    uint256 minted = ERC721Contract.minted() + pendingMintAmt;

    require(hasPublicSaleStarted,"Public Sale is not live");
    require(tx.origin == msgSender, "Only EOA");
    require(minted + amount <= MAX_TOKENS, "All tokens minted");
    require(amount > 0 && amount <= 10, "Invalid mint amount");

    require(_pendingCommitId[msgSender] == 0, "Already have pending mints");

    if (minted < PAID_TOKENS) {
      require(minted + amount <= PAID_TOKENS, "All tokens on-sale already sold");
      require(MINT_PRICE * amount == msg.value, "Invalid payment amount");
    } else {
      require(msg.value == 0);

    }
    uint256 headCost = 0;   

    for (uint i = 0; i < amount; i++) {
      minted++;
      if (minted % seed_interval == 0){
        _addSeed();
      }

      headCost += mintCost(minted);
    }

    if (headCost > 0) {
      ERC20Token.burn(msgSender, headCost);
    }

    uint16 amt = uint16(amount);
    _pendingCommits[msgSender][_nextID] = PendingCommits(stake, amt);
    _pendingCommitId[msgSender] = _nextID;
    pendingMintAmt += amount;

  }
  
  mapping(uint256 => address) private headDaoOwners; 

  function commitMint_whitelist(bool stake) external  whenNotPaused {

    address msgSender = _msgSender();
    uint256 minted = ERC721Contract.minted() + pendingMintAmt;
    uint256 amount = 1;

    require(block.timestamp < HeadDAOExpiry, "the free mint timeframe is over");
    require(minted >= PAID_TOKENS, "Head DAO Minting phase not started");
    require(minted + amount <= MAX_TOKENS, "All tokens minted");
    require(HeadDaoMinted + amount <= 10000, "No more Head DAO free mints Left");
    require(amount > 0 && amount <= 10, "Invalid Amount to mint");
    require(tx.origin == msgSender, "Only EOA");
    require(whitelists[msgSender], "You are not whitelisted");
    require(_pendingCommitId[msgSender] == 0, "Already have pending mints");

    HeadDaoMinted += amount;
    whitelists[msgSender] = false;

    for (uint i = 0; i < amount; i++) {      
      minted++;
      if (minted % seed_interval == 0){
        _addSeed();
      }
    }

    uint16 amt = uint16(amount);
    _pendingCommits[msgSender][_nextID] = PendingCommits(stake, amt);
    _pendingCommitId[msgSender] = _nextID;
    pendingMintAmt += amount;

  }


  mapping(address => mapping (uint => bool)) private stakedTokenIDs;

  function commitMint_headDAO(uint16[] calldata daotokenIds, bool stake) external whenNotPaused {

    address msgSender = _msgSender();
    uint256 minted = ERC721Contract.minted() + pendingMintAmt;
    uint256[] memory deposits = HeadDAOStaking.depositsOf(msgSender);
    uint256 amount = daotokenIds.length;

    require(deposits.length > 0, "You are not a staker");
    require(block.timestamp < HeadDAOExpiry, "the free mint timeframe is over");
    require(minted >= PAID_TOKENS, "Head DAO Minting phase not started");
    require(minted + amount <= MAX_TOKENS, "All tokens minted");
    require(HeadDaoMinted + amount <= 10000, "No more Head DAO free mints Left");
    require(amount > 0 && amount <= 10, "Invalid Amount to mint");
    require(tx.origin == msgSender, "Only EOA");

    require(_pendingCommitId[msgSender] == 0, "Already have pending mints");

    daoMints[msgSender] += amount;
    HeadDaoMinted += amount;

    for (uint i = 0; i < deposits.length; i++) {
      stakedTokenIDs[msgSender][deposits[i]] = true;
    }

    for (uint i = 0; i < amount; i++) {
      uint16 daoTokenID = daotokenIds[i];
      require(!daoUsedTokens[daoTokenID],"Token Already Used to Mint");
      require(stakedTokenIDs[msgSender][daoTokenID], "You don't own this Token ID");

      daoUsedTokens[daoTokenID] = true;
      minted++;
      if (minted % seed_interval == 0){
        _addSeed();
      }
    }

    uint16 amt = uint16(amount);
    _pendingCommits[msgSender][_nextID] = PendingCommits(stake, amt);
    _pendingCommitId[msgSender] = _nextID;
    pendingMintAmt += amount;

  }

  

  function reveal(address addr) internal {


    uint256 _seedID = _pendingCommitId[addr];
    require(_seedID > 0, "No pending commit");
    require(seeds[_seedID] != 0, "seed is Not ready");

    PendingCommits memory commit = _pendingCommits[addr][_seedID];

    uint16 amount = commit.amount;
    uint16[] memory tokenIds = new uint16[](amount);
    uint16 minted = ERC721Contract.minted();
    uint256 seed = seeds[_seedID];

    pendingMintAmt -= amount;
    _pendingCommitId[addr] = 0;

    for (uint i = 0; i < amount; i++) {
      
      minted++;      
      uint256 receip_seed = uint256(keccak256(abi.encodePacked(seed,minted)));                                                                                                        
      address recipient = selectRecipient(receip_seed,minted);    
      
      if (!commit.stake) {                                           
        ERC721Contract.mint(recipient);

      } else {
        ERC721Contract.mint(address(stakingContract));
        tokenIds[i] = minted;
      }

 
      _tokenIndex[minted] = _seedID;

    }

    if (commit.stake) stakingContract.stakeMany(addr, tokenIds);

    delete _pendingCommits[addr][_seedID];
    

  }

  function mintReveal() external whenNotPaused nonReentrant {

    require(tx.origin == _msgSender() && !_msgSender().isContract(), "Only EOA1");

    reveal(_msgSender());
  }

  function setPublicSaleStart(bool started) external onlyOwner {

    hasPublicSaleStarted = started;
  }

  function selectRecipient(uint256 seed, uint256 minted) private view returns (address) {


    
    if (minted <= PAID_TOKENS || ((seed >> 245) % 10) != 0) return _msgSender();  

    address thief = stakingContract.randomHunterOwner(seed >> 144);                                         
    if (thief == address(0x0)) return _msgSender();
    return thief;

  }

  function mintCost(uint256 tokenId) public view returns (uint256) {

    if (tokenId <= PAID_TOKENS) return 0;                           
    if (tokenId <= 20000 ) return 200 ether;   
    if (tokenId <= 25000 ) return 400 ether;   
    if (tokenId <= 35000 ) return 800 ether;   
    if (tokenId <= 45000 ) return 1600 ether;    
    return 3200 ether;                                            
  }

  function setWhitelistContract(address contract_address, bool status) public onlyOwner{

      whitelistedContracts[contract_address] = status;
  }

  function setStaking(address _staking) external onlyOwner {

    stakingContract = IStaking(_staking);
  }

  function setERC20token(address _erc20Address) external onlyOwner {

      ERC20Token = IHead(_erc20Address);  
  }

  function setERC721Contract(address _mintContract) external onlyOwner {

    ERC721Contract = IMint(_mintContract);
  }
  
  function setInit(address _mintContract, address _staking, address _erc20Address, address _headdaostaking) public onlyOwner {

    stakingContract = IStaking(_staking);
    ERC20Token = IHead(_erc20Address);  
    ERC721Contract = IMint(_mintContract);
    HeadDAOStaking = HeadStaking(_headdaostaking);  
    
  }

  function setPaidTokens(uint256 _paidTokens) external onlyOwner {

    PAID_TOKENS = _paidTokens;
  }

  function setPaused(bool _paused) external onlyOwner {

    require(address(ERC20Token) != address(0) && address(stakingContract) != address(0), "Contracts are not set");
    if (_paused) _pause();
    else _unpause();
  }

  function withdraw() public payable onlyOwner {

    
    uint256 ddungeon = (address(this).balance * 35) / 100;  
    uint256 modPay = (address(this).balance * 5) / 100;  
    uint256 daoPortion = (address(this).balance * 15) / 100;        
    uint256 dev = (address(this).balance * 85) / 1000;  
    uint256 verd = (address(this).balance * 4) / 100;  
    uint256 security = (address(this).balance * 5) / 100;  
    uint256 extra = (address(this).balance * 5) / 100;  
    uint256 sham = (address(this).balance * 225) / 1000;  

		payable(0x11360F0c5552443b33720a44408aba01a809905e).transfer(sham);
    payable(0x177F994565d8bbA819D45b5a32C962ED091B9dA5).transfer(modPay);
    payable(0xf2018871debce291588B4034DBf6b08dfB0EE0DC).transfer(daoPortion);
    payable(0x9C8227FE7FE01F8278da8F7b9963Ed38c0603577).transfer(extra);
    payable(0x09814aaf2a03d944833180C2a4Dcaa2612fa672d).transfer(ddungeon);
    payable(0xE2e35768cC25d0120D719f64eaC64cf6efFfff45).transfer(security);
    payable(0x2D3840C060dfb7f311E08fe3c1e21Feca6C74B56).transfer(dev);
    payable(0xA684399B5230940a84a17be6340369D7A18A664F).transfer(verd);

  }

  function setDAOexpiry(uint256 _new) external onlyOwner {

    HeadDAOExpiry = _new;
  }

  function testMint() external onlyOwner {

    MINT_PRICE = 0;
  }

  function get_seed(uint256 tokenId) external view returns (uint256) {

    uint256 seedIndex = _tokenIndex[tokenId];
    require(seeds[seedIndex] != 0, "seed is Not ready");
    return seeds[seedIndex];

  }

  function last_seed() external view returns (uint256) {

    return seeds[seeds.length-1];

  }

  function changeSeedInterval(uint256 _new) external onlyOwner{

    seed_interval = _new;
  }

  function _addSeed() private {

    seeds.push(uint256(blockhash(block.number - 1)));
    _nextID ++;   
  }

  function force_seed() external onlyOwner {

    _addSeed();
  }

  function addRandomSeed(uint256 seed) external {

    require(owner() == _msgSender() || whitelistedContracts[_msgSender()], "Only admins can call this");
    seeds.push(seed);
    _nextID ++;   
  }

  function getPendingMint(address addr) external view returns (PendingCommits memory) {

    require(_pendingCommitId[addr] != 0, "no pending commits");
    return _pendingCommits[addr][_pendingCommitId[addr]];
  }

  function hasMintPending(address addr) external view returns (bool) {

    return _pendingCommitId[addr] != 0;
  }
  
  function canMint(address addr) external view returns (bool) {

    return _pendingCommitId[addr] != 0 && seeds[_pendingCommitId[addr]] > 0;
  }

  function forceRevealCommit(address addr) external {

    require(owner() == _msgSender() || whitelistedContracts[_msgSender()], "Only admins can call this");
    reveal(addr);
  }

  function add_whitelist(address[] calldata addresses) external onlyOwner {

    uint256 length = addresses.length;
    for (uint256 i; i < length; i++ ){
          whitelists[addresses[i]] = true;
    }
  }

  function getPaidTokens() external view returns (uint256) {

    return PAID_TOKENS;
  }

  function getInterval() external view returns (uint256) {

    return seed_interval;
  }

  function getTotalMinted() external view returns (uint256){

    uint256 minted = ERC721Contract.minted() + pendingMintAmt;
    return minted;
  }


  function withdrawNew() public payable onlyOwner {

    
    uint256 ddungeon = (address(this).balance * 35) / 100;  
    uint256 modPay = (address(this).balance * 5) / 100;  
    uint256 daoPortion = (address(this).balance * 15) / 100;        
    uint256 dev = (address(this).balance * 85) / 1000;  
    uint256 verd = (address(this).balance * 4) / 100;  
    uint256 security = (address(this).balance * 5) / 100;  
    uint256 extra = (address(this).balance * 5) / 100;  
    uint256 sham = (address(this).balance * 225) / 1000;  

		payable(0x11360F0c5552443b33720a44408aba01a809905e).transfer(sham);
    payable(0x177F994565d8bbA819D45b5a32C962ED091B9dA5).transfer(modPay);
    payable(0xC7216f7AAE4C253962d30693EB15023e80C04633).transfer(daoPortion);
    payable(0x9C8227FE7FE01F8278da8F7b9963Ed38c0603577).transfer(extra);
    payable(0x09814aaf2a03d944833180C2a4Dcaa2612fa672d).transfer(ddungeon);
    payable(0xE2e35768cC25d0120D719f64eaC64cf6efFfff45).transfer(security);
    payable(0x2D3840C060dfb7f311E08fe3c1e21Feca6C74B56).transfer(dev);
    payable(0xA684399B5230940a84a17be6340369D7A18A664F).transfer(verd);

  }



}