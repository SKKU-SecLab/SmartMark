
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
}// MIT

pragma solidity ^0.8.0;

library MerkleProof {

    function verify(
        bytes32[] memory proof,
        bytes32 root,
        bytes32 leaf
    ) internal pure returns (bool) {

        return processProof(proof, leaf) == root;
    }

    function processProof(bytes32[] memory proof, bytes32 leaf) internal pure returns (bytes32) {

        bytes32 computedHash = leaf;
        for (uint256 i = 0; i < proof.length; i++) {
            bytes32 proofElement = proof[i];
            if (computedHash <= proofElement) {
                computedHash = keccak256(abi.encodePacked(computedHash, proofElement));
            } else {
                computedHash = keccak256(abi.encodePacked(proofElement, computedHash));
            }
        }
        return computedHash;
    }
}// MIT LICENSE

pragma solidity ^0.8.0;

interface IHNDGame {

  
}// MIT LICENSE 

pragma solidity ^0.8.0;

interface IKingdom {

  function addManyToKingdom(address account, uint16[] calldata tokenIds) external;

  function randomDemonOwner(uint256 seed) external view returns (address);

  function recycleExp(uint256 amount) external;

}// MIT LICENSE 

pragma solidity ^0.8.0;

interface ITraits {

  function tokenURI(uint256 tokenId) external view returns (string memory);

}// MIT LICENSE

pragma solidity ^0.8.0;

interface IEXP {

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


interface IHND is IERC721Enumerable {


    struct HeroDemon {
        bool isHero;
        bool isFemale;
        uint8 body;
        uint8 face;
        uint8 eyes;
        uint8 headpiecehorns;
        uint8 gloves;
        uint8 armor;
        uint8 weapon;
        uint8 shield;
        uint8 shoes;
        uint8 tailflame;
        uint8 rankIndex;
    }

    function minted() external returns (uint16);

    function updateOriginAccess(uint16[] memory tokenIds) external;

    function mint(address recipient, uint256 seed) external;

    function burn(uint256 tokenId) external;

    function getMaxTokens() external view returns (uint256);

    function getPaidTokens() external view returns (uint256);

    function getTokenTraits(uint256 tokenId) external view returns (HeroDemon memory);

    function getTokenWriteBlock(uint256 tokenId) external view returns(uint64);

    function isHero(uint256 tokenId) external view returns(bool);

  
}// MIT LICENSE

pragma solidity ^0.8.0;

interface IShop {

    function mint(uint256 typeId, uint16 qty, address recipient) external;

    function burn(uint256 typeId, uint16 qty, address burnFrom) external;

    function updateOriginAccess() external;

    function balanceOf(address account, uint256 id) external returns (uint256);

    function safeTransferFrom(address from, address to, uint256 id, uint256 amount, bytes memory data) external;

}// MIT LICENSE

pragma solidity ^0.8.0;



contract HNDGame is IHNDGame, Ownable, ReentrancyGuard, Pausable {


  event MintCommitted(address indexed owner, uint256 indexed amount);
  event MintRevealed(address indexed owner, uint256 indexed amount);

  struct MintCommit {
    bool stake;
    uint16 amount;
  }

  uint256 private maxExpCost = 105000 ether;

  uint256 public presalePrice = 0.07 ether;
  uint256 public publicSalePrice = 0.08 ether;


  mapping(address => mapping(uint16 => MintCommit)) private _mintCommits;

  mapping(address => uint16) private _pendingCommitId;

  mapping(uint16 => uint256) private _commitRandoms;


  mapping(address => uint256) private _whitelistClaims;

  bytes32 private whitelistMerkleRoot;

  uint16 private _commitBatch = 1;

  uint16 private pendingMintAmt;

  bool public isPublicSale;

  mapping(address => bool) private admins;


  IKingdom public kingdom;

  ITraits public traits;

  IEXP public expToken;

  IHND public HNDNFT;

  address private kingdomAddr;

  address private treasury;

  IShop public shop;

  constructor() {
    _pause();
  }


  modifier requireContractsSet() {

      require(address(expToken) != address(0) && address(traits) != address(0) 
        && address(expToken) != address(0) && address(kingdom) != address(0) && address(shop) != address(0)
        , "Contracts not set");
      _;
  }

  modifier requireEOA() {

    require(tx.origin == _msgSender(), "Only EOA");

    _;
  }

  function setContracts(address _exp, address _traits, address _HND, address _kingdom, address _shop) external onlyOwner {

    expToken = IEXP(_exp);
    traits = ITraits(_traits);
    HNDNFT = IHND(_HND);
    kingdom = IKingdom(_kingdom);
    kingdomAddr = _kingdom;
    shop = IShop(_shop);
  }


  function setTreasury(address _treasury) external onlyOwner {

    treasury = _treasury;
  }

  function setWhitelistMerkleRoot(bytes32 root) external onlyOwner {

    whitelistMerkleRoot = root;
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

  function addCommitRandom(uint256 seed, bytes32 parentBlockHash) external {

    require(owner() == _msgSender() || admins[_msgSender()], "Only admins can call this");

    if (parentBlockHash != "") {
      require(blockhash(block.number - 1) == parentBlockHash, "block was uncled");
    }
    _commitRandoms[_commitBatch] = seed;
    _commitBatch += 1;
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




  function whitelistMintCommit(uint256 index, uint256 a, uint256 amount, bytes32[] calldata merkleProof, bool stake) external payable whenNotPaused nonReentrant requireEOA {

    
    require(_pendingCommitId[_msgSender()] == 0, "Already have pending mints");
    require(_whitelistClaims[_msgSender()] + amount <= 2, "exceeds whitelist mint limit");
    require(amount * presalePrice == msg.value, "Invalid payment amount");

    
    bytes32 node = keccak256(abi.encodePacked(index, _msgSender(), a));
    require(MerkleProof.verify(merkleProof, whitelistMerkleRoot, node), "Not on Whitelist: Invalid Merkle proof.");  
  
    _whitelistClaims[_msgSender()] += amount;

    uint16 amt = uint16(amount);
    _mintCommits[_msgSender()][_commitBatch] = MintCommit(stake, amt);
    _pendingCommitId[_msgSender()] = _commitBatch;
    pendingMintAmt += amt;
    emit MintCommitted(_msgSender(), amount);

  }

  function mintCommit(uint256 amount, bool stake) external payable whenNotPaused nonReentrant requireEOA {

    require(isPublicSale == true, "Public Sale not started!");
    require(_pendingCommitId[_msgSender()] == 0, "Already have pending mints");
    uint16 minted = HNDNFT.minted();
    uint256 maxTokens = HNDNFT.getMaxTokens();
    uint256 paidTokens = HNDNFT.getPaidTokens();
    require(minted + pendingMintAmt + amount <= maxTokens, "All tokens minted");
    require(amount <= 10, "HNDGame: Maximum mint amount of 10");

    if (minted < paidTokens) {
      require(minted + amount <= paidTokens, "HNDGame: Paid tokens sold out");
      require(amount * publicSalePrice == msg.value, "HNDGame: Invalid payment amount");
    } else {
      require(msg.value == 0);
      uint256 totalExpCost = 0;
      for (uint i = 1; i <= amount; i++) {
        totalExpCost += mintCost(minted + pendingMintAmt + i, maxTokens);
      }

      if (totalExpCost > 0) {
        expToken.burn(_msgSender(), totalExpCost * 13 / 20);
        
        kingdom.recycleExp(totalExpCost * 7/20);

        expToken.transferFrom(_msgSender(), treasury, totalExpCost * 7 / 20);


        expToken.updateOriginAccess();
      }
    }

    uint16 amt = uint16(amount);
    _mintCommits[_msgSender()][_commitBatch] = MintCommit(stake, amt);
    _pendingCommitId[_msgSender()] = _commitBatch;
    pendingMintAmt += amt;
    emit MintCommitted(_msgSender(), amount);
  }

  function mintReveal() external whenNotPaused nonReentrant requireEOA {

    reveal(_msgSender());
  }

  function reveal(address addr) internal {

    uint16 commitIdCur = _pendingCommitId[addr];
    require(commitIdCur > 0, "No pending commit");
    require(_commitRandoms[commitIdCur] > 0, "random seed not set");
    uint16 minted = HNDNFT.minted();
    MintCommit memory commit = _mintCommits[addr][commitIdCur];
    pendingMintAmt -= commit.amount;
    uint16[] memory tokenIds = new uint16[](commit.amount);
    uint256 seed = _commitRandoms[commitIdCur];
    for (uint k = 0; k < commit.amount; k++) {
      minted++;

      seed = uint256(keccak256(abi.encode(seed, addr)));
      address recipient = selectRecipient(seed);

      tokenIds[k] = minted;
      if (!commit.stake || recipient != addr) {
        HNDNFT.mint(recipient, seed);
      } else {
        HNDNFT.mint(address(kingdom), seed);
      }
    }
    HNDNFT.updateOriginAccess(tokenIds);
    if(commit.stake) {
      kingdom.addManyToKingdom(addr, tokenIds);
    }
    delete _mintCommits[addr][commitIdCur];
    delete _pendingCommitId[addr];
    emit MintCommitted(addr, tokenIds.length);
  }

  function mintCost(uint256 tokenId, uint256 maxTokens) public view returns (uint256) {

    if (tokenId <= maxTokens * 2 / 5) return 20000 ether;
    if (tokenId <= maxTokens * 3 / 5) return 45000 ether;
    if (tokenId <= maxTokens * 4 / 5) return 80000 ether;
    if (tokenId <= maxTokens)         return 105000 ether; 
    return maxExpCost;
  }


  function selectRecipient(uint256 seed) internal returns (address) {

    if (HNDNFT.getPaidTokens() < HNDNFT.minted()) {
      if (((seed >> 245) % 10) != 0) return _msgSender(); // top 10 bits haven't been used
      address thief = kingdom.randomDemonOwner(seed >> 144); // 144 bits reserved for trait selection
      if (thief == address(0x0)) return _msgSender();
      return thief;
    } else {
      return _msgSender();
    }
  }


  function setPaused(bool _paused) external requireContractsSet onlyOwner {

    if (_paused) _pause();
    else _unpause();
  }

  function startPublicSale(bool _saleStarted) external onlyOwner {

    isPublicSale = _saleStarted;
  }

  function setMaxExpCost(uint256 _amount) external requireContractsSet onlyOwner {

    maxExpCost = _amount;
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