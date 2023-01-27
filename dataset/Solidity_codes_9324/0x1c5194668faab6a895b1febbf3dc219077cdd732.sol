
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

    function _setOwner(address newOwner) private {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}// MIT

pragma solidity ^0.8.0;


abstract contract Pausable is Context {
    event Paused(address account);

    event Unpaused(address account);

    bool private _paused;

    constructor() {
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
}// MIT

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
}// MIT LICENSE

pragma solidity ^0.8.0;

interface IWnDGame {

  
}// MIT LICENSE 

pragma solidity ^0.8.0;

interface ITower {

  function addManyToTowerAndFlight(address account, uint16[] calldata tokenIds) external;

  function randomDragonOwner(uint256 seed) external view returns (address);

}// MIT LICENSE 

pragma solidity ^0.8.0;

interface ITraits {

  function tokenURI(uint256 tokenId) external view returns (string memory);

}// MIT LICENSE

pragma solidity ^0.8.0;

interface IGP {

    function mint(address to, uint256 amount) external;

    function burn(address from, uint256 amount) external;

    function updateOriginAccess() external;

    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

}// MIT

pragma solidity ^0.8.0;

interface IERC165 {

    function supportsInterface(bytes4 interfaceId) external view returns (bool);

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

}// MIT

pragma solidity ^0.8.0;


interface IERC721Enumerable is IERC721 {

    function totalSupply() external view returns (uint256);


    function tokenOfOwnerByIndex(address owner, uint256 index) external view returns (uint256 tokenId);


    function tokenByIndex(uint256 index) external view returns (uint256);

}// MIT LICENSE

pragma solidity ^0.8.0;


interface IWnD is IERC721Enumerable {


    struct WizardDragon {
        bool isWizard;
        uint8 body;
        uint8 head;
        uint8 spell;
        uint8 eyes;
        uint8 neck;
        uint8 mouth;
        uint8 wand;
        uint8 tail;
        uint8 rankIndex;
    }

    function minted() external returns (uint16);

    function updateOriginAccess(uint16[] memory tokenIds) external;

    function mint(address recipient, uint256 seed) external;

    function burn(uint256 tokenId) external;

    function getMaxTokens() external view returns (uint256);

    function getPaidTokens() external view returns (uint256);

    function getTokenTraits(uint256 tokenId) external view returns (WizardDragon memory);

    function getTokenWriteBlock(uint256 tokenId) external view returns(uint64);

    function isWizard(uint256 tokenId) external view returns(bool);

  
}// MIT LICENSE

pragma solidity ^0.8.0;

interface ISacrificialAlter {

    function mint(uint256 typeId, uint16 qty, address recipient) external;

    function burn(uint256 typeId, uint16 qty, address burnFrom) external;

    function updateOriginAccess() external;

    function balanceOf(address account, uint256 id) external returns (uint256);

    function safeTransferFrom(address from, address to, uint256 id, uint256 amount, bytes memory data) external;

}pragma solidity ^0.8.0;

interface IRandomizer {

    function random() external returns (uint256);

}// MIT LICENSE

pragma solidity ^0.8.0;


contract WnDGameCR is IWnDGame, Ownable, ReentrancyGuard, Pausable {


  event MintCommitted(address indexed owner, uint256 indexed amount);
  event MintRevealed(address indexed owner, uint256 indexed amount);

  struct MintCommit {
    bool stake;
    uint16 amount;
  }

  uint256 public treasureChestTypeId;
  uint256 private maxGpCost = 72000 ether;

  mapping(address => mapping(uint16 => MintCommit)) private _mintCommits;
  mapping(address => uint16) private _pendingCommitId;
  mapping(uint16 => uint256) private _commitRandoms;
  uint16 private _commitId = 1;
  uint16 private pendingMintAmt;
  bool public allowCommits = true;

  mapping(address => bool) private admins;

  ITower public tower;
  IGP public gpToken;
  ITraits public traits;
  IWnD public wndNFT;
  ISacrificialAlter public alter;

  constructor() {
    _pause();
  }


  modifier requireContractsSet() {

      require(address(gpToken) != address(0) && address(traits) != address(0) 
        && address(wndNFT) != address(0) && address(tower) != address(0) && address(alter) != address(0)
        , "Contracts not set");
      _;
  }

  function setContracts(address _gp, address _traits, address _wnd, address _tower, address _alter) external onlyOwner {

    gpToken = IGP(_gp);
    traits = ITraits(_traits);
    wndNFT = IWnD(_wnd);
    tower = ITower(_tower);
    alter = ISacrificialAlter(_alter);
  }


  function getPendingMint(address addr) external view returns (MintCommit memory) {

    require(_pendingCommitId[addr] != 0, "no pending commits");
    return _mintCommits[addr][_pendingCommitId[addr]];
  }

  function hasMintPending(address addr) external view returns (bool) {

    return _pendingCommitId[addr] != 0;
  }

  function canMint(address addr) external view returns (bool) {

    return _pendingCommitId[addr] != 0 && _commitRandoms[_pendingCommitId[addr]] > 0;
  }

  function addCommitRandom(uint256 seed) external {

    require(owner() == _msgSender() || admins[_msgSender()], "Only admins can call this");
    _commitRandoms[_commitId] = seed;
    _commitId += 1;
  }

  function deleteCommit(address addr) external {

    require(owner() == _msgSender() || admins[_msgSender()], "Only admins can call this");
    uint16 commitIdCur = _pendingCommitId[_msgSender()];
    require(commitIdCur > 0, "No pending commit");
    delete _mintCommits[addr][commitIdCur];
    delete _pendingCommitId[addr];
  }

  function forceRevealCommit(address addr) external {

    require(owner() == _msgSender() || admins[_msgSender()], "Only admins can call this");
    reveal(addr);
  }

  function mintCommit(uint256 amount, bool stake) external whenNotPaused nonReentrant {

    require(allowCommits, "adding commits disallowed");
    require(tx.origin == _msgSender(), "Only EOA");
    require(_pendingCommitId[_msgSender()] == 0, "Already have pending mints");
    uint16 minted = wndNFT.minted();
    uint256 maxTokens = wndNFT.getMaxTokens();
    require(minted + pendingMintAmt + amount <= maxTokens, "All tokens minted");
    require(amount > 0 && amount <= 10, "Invalid mint amount");

    uint256 totalGpCost = 0;
    for (uint i = 1; i <= amount; i++) {
      totalGpCost += mintCost(minted + pendingMintAmt + i, maxTokens);
    }
    if (totalGpCost > 0) {
      gpToken.burn(_msgSender(), totalGpCost);
      gpToken.updateOriginAccess();
    }
    uint16 amt = uint16(amount);
    _mintCommits[_msgSender()][_commitId] = MintCommit(stake, amt);
    _pendingCommitId[_msgSender()] = _commitId;
    pendingMintAmt += amt;
    emit MintCommitted(_msgSender(), amount);
  }

  function mintReveal() external whenNotPaused nonReentrant {

    require(tx.origin == _msgSender(), "Only EOA1");
    reveal(_msgSender());
  }

  function reveal(address addr) internal {

    uint16 commitIdCur = _pendingCommitId[addr];
    require(commitIdCur > 0, "No pending commit");
    require(_commitRandoms[commitIdCur] > 0, "random seed not set");
    uint16 minted = wndNFT.minted();
    MintCommit memory commit = _mintCommits[addr][commitIdCur];
    pendingMintAmt -= commit.amount;
    uint16[] memory tokenIds = new uint16[](commit.amount);
    uint16[] memory tokenIdsToStake = new uint16[](commit.amount);
    uint256 seed = _commitRandoms[commitIdCur];
    for (uint k = 0; k < commit.amount; k++) {
      minted++;
      seed = uint256(keccak256(abi.encode(seed, addr)));
      address recipient = selectRecipient(seed);
      if(recipient != addr && alter.balanceOf(addr, treasureChestTypeId) > 0) {
        if(seed & 1 == 1) {
          alter.safeTransferFrom(addr, recipient, treasureChestTypeId, 1, "");
          recipient = addr;
        }
      }
      tokenIds[k] = minted;
      if (!commit.stake || recipient != addr) {
        wndNFT.mint(recipient, seed);
      } else {
        wndNFT.mint(address(tower), seed);
        tokenIdsToStake[k] = minted;
      }
    }
    wndNFT.updateOriginAccess(tokenIds);
    if(commit.stake) {
      tower.addManyToTowerAndFlight(addr, tokenIdsToStake);
    }
    delete _mintCommits[addr][commitIdCur];
    delete _pendingCommitId[addr];
    emit MintCommitted(addr, tokenIds.length);
  }

  function mintCost(uint256 tokenId, uint256 maxTokens) public view returns (uint256) {

    if (tokenId <= maxTokens * 8 / 20) return 24000 ether;
    if (tokenId <= maxTokens * 11 / 20) return 36000 ether;
    if (tokenId <= maxTokens * 14 / 20) return 48000 ether;
    if (tokenId <= maxTokens * 17 / 20) return 60000 ether; 
    return maxGpCost;
  }

  function payTribute(uint256 gpAmt) external whenNotPaused nonReentrant {

    require(tx.origin == _msgSender(), "Only EOA");
    uint16 minted = wndNFT.minted();
    uint256 maxTokens = wndNFT.getMaxTokens();
    uint256 gpMintCost = mintCost(minted, maxTokens);
    require(gpMintCost > 0, "Sacrificial alter currently closed");
    require(gpAmt >= gpMintCost, "Not enough gp given");
    gpToken.burn(_msgSender(), gpAmt);
    if(gpAmt < gpMintCost * 2) {
      alter.mint(1, 1, _msgSender());
    }
    else {
      alter.mint(2, 1, _msgSender());
    }
  }

  function makeTreasureChests(uint16 qty) external whenNotPaused {

    require(tx.origin == _msgSender(), "Only EOA");
    require(treasureChestTypeId > 0, "DEVS DO SOMETHING");
    alter.mint(treasureChestTypeId, qty, _msgSender());
  }

  function sellTreasureChests(uint16 qty) external whenNotPaused {

    require(tx.origin == _msgSender(), "Only EOA");
    require(treasureChestTypeId > 0, "DEVS DO SOMETHING");
    alter.burn(treasureChestTypeId, qty, _msgSender());
  }

  function sacrifice(uint256 tokenId, uint256 gpAmt) external whenNotPaused nonReentrant {

    require(tx.origin == _msgSender(), "Only EOA");
    uint64 lastTokenWrite = wndNFT.getTokenWriteBlock(tokenId);
    require(lastTokenWrite < block.number, "hmmmm what doing?");
    IWnD.WizardDragon memory nft = wndNFT.getTokenTraits(tokenId);
    uint16 minted = wndNFT.minted();
    uint256 maxTokens = wndNFT.getMaxTokens();
    uint256 gpMintCost = mintCost(minted, maxTokens);
    require(gpMintCost > 0, "Sacrificial alter currently closed");
    if(nft.isWizard) {
      require(gpAmt >= gpMintCost * 3, "not enough gp provided");
      gpToken.burn(_msgSender(), gpAmt);
      wndNFT.burn(tokenId);
      alter.mint(3, 1, _msgSender());
    }
    else {
      require(gpAmt >= gpMintCost * 4, "not enough gp provided");
      gpToken.burn(_msgSender(), gpAmt);
      wndNFT.burn(tokenId);
      alter.mint(4, 1, _msgSender());
    }
  }


  function selectRecipient(uint256 seed) internal view returns (address) {

    if (((seed >> 245) % 10) != 0) return _msgSender(); // top 10 bits haven't been used
    address thief = tower.randomDragonOwner(seed >> 144); // 144 bits reserved for trait selection
    if (thief == address(0x0)) return _msgSender();
    return thief;
  }


  function setPaused(bool _paused) external requireContractsSet onlyOwner {

    if (_paused) _pause();
    else _unpause();
  }

  function setMaxGpCost(uint256 _amount) external requireContractsSet onlyOwner {

    maxGpCost = _amount;
  } 

  function setTreasureChestId(uint256 typeId) external onlyOwner {

    treasureChestTypeId = typeId;
  }

  function setAllowCommits(bool allowed) external onlyOwner {

    allowCommits = allowed;
  }

  function setPendingMintAmt(uint256 pendingAmt) external onlyOwner {

    pendingMintAmt = uint16(pendingAmt);
  }

  function addAdmin(address addr) external onlyOwner {

      admins[addr] = true;
  }

  function removeAdmin(address addr) external onlyOwner {

      admins[addr] = false;
  }

  function withdraw() external onlyOwner {

    payable(owner()).transfer(address(this).balance);
  }
}