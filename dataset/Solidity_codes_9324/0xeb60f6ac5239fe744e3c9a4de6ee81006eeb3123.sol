
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

interface ISharkGame {


}// MIT LICENSE

pragma solidity ^0.8.0;


interface ISharks is IERC721Enumerable {

    enum SGTokenType {
        MINNOW,
        SHARK,
        ORCA
    }

    struct SGToken {
        SGTokenType tokenType;
        uint8 base;
        uint8 accessory;
    }

    function minted() external returns (uint16);

    function updateOriginAccess(uint16[] memory tokenIds) external;

    function mint(address recipient, uint256 seed) external;

    function burn(uint256 tokenId) external;

    function getMaxTokens() external view returns (uint16);

    function getPaidTokens() external view returns (uint16);

    function tokenURI(uint256 tokenId) external view returns (string memory);

    function getTokenTraits(uint256 tokenId) external view returns (SGToken memory);

    function getTokenWriteBlock(uint256 tokenId) external view returns(uint64);

    function getTokenType(uint256 tokenId) external view returns(SGTokenType);

}// MIT LICENSE

pragma solidity ^0.8.0;


interface ICoral {

  function addManyToCoral(address account, uint16[] calldata tokenIds) external;

  function randomTokenOwner(ISharks.SGTokenType tokenType, uint256 seed) external view returns (address);

}// MIT LICENSE 

pragma solidity ^0.8.0;

interface ITraits {

  function tokenURI(uint256 tokenId) external view returns (string memory);

}// MIT LICENSE

pragma solidity ^0.8.0;

interface IChum {

    function mint(address to, uint256 amount) external;

    function burn(address from, uint256 amount) external;

    function updateOriginAccess() external;

    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

}// MIT LICENSE

pragma solidity ^0.8.0;

interface IRandomizer {

    function random() external returns (uint256);

}// MIT LICENSE

pragma solidity ^0.8.0;


contract SharkGameCR is ISharkGame, Ownable, ReentrancyGuard, Pausable {

  using MerkleProof for bytes32[];

  event MintCommitted(address indexed owner, uint256 indexed amount);
  event MintRevealed(address indexed owner, uint256 indexed amount);

  struct MintCommit {
    bool stake;
    uint16 amount;
  }

  uint256 public treasureChestTypeId;
  uint256 private maxChumCost = 80000 ether;
  uint256 private ethCost = 0.04 ether;

  mapping(address => mapping(uint16 => MintCommit)) private _mintCommits;
  mapping(address => uint16) private _pendingCommitId;
  mapping(uint16 => uint256) private _commitRandoms;
  uint16 private _commitId = 1;
  uint16 private pendingMintAmt;
  uint8 public saleStage = 0;
  mapping(address => uint16) private _mintedByWallet;
  mapping(address => uint16) public freeMints;
  bytes32 whitelistMerkelRoot;

  mapping(address => bool) private admins;

  ICoral public coral;
  IChum public chumToken;
  ITraits public traits;
  ISharks public sharksNft;

  constructor() {
    _pause();
  }


  modifier requireContractsSet() {

      require(address(chumToken) != address(0) && address(traits) != address(0)
        && address(sharksNft) != address(0) && address(coral) != address(0)
        , "Contracts not set");
      _;
  }

  function setContracts(address _chum, address _traits, address _sharksNft, address _coral) external onlyOwner {

    chumToken = IChum(_chum);
    traits = ITraits(_traits);
    sharksNft = ISharks(_sharksNft);
    coral = ICoral(_coral);
  }

  function setWhitelistRoot(bytes32 val) public onlyOwner {

    whitelistMerkelRoot = val;
  }

  function addFreeMints(address addr, uint16 qty) public onlyOwner {

    freeMints[addr] += qty;
  }

  function setSaleStage(uint8 val) public onlyOwner {

    saleStage = val;
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

  function mintCommit(uint16 amount, bool stake, bytes32[] memory proof) external whenNotPaused nonReentrant payable {

    require(tx.origin == _msgSender(), "Only EOA");
    require(_pendingCommitId[_msgSender()] == 0, "Already have pending mints");
    require(saleStage > 0, "Sale not started yet");
    uint16 minted = sharksNft.minted();
    uint16 maxTokens = sharksNft.getMaxTokens();
    uint16 paidTokens = sharksNft.getPaidTokens();
    bool isWhitelistOnly = saleStage < 2;
    uint16 maxTxMint = isWhitelistOnly ? 4 : 6;
    uint16 maxWalletMint = isWhitelistOnly ? 4 : 12;
    require(minted + pendingMintAmt + amount <= maxTokens, "All tokens minted");
    require(amount > 0 && amount <= maxTxMint, "Invalid mint amount");
    require(minted + pendingMintAmt > paidTokens || _mintedByWallet[_msgSender()] + amount <= maxWalletMint, "Invalid mint amount");
    if (isWhitelistOnly) {
      require(whitelistMerkelRoot != 0, "Whitelist not set");
      require(
        proof.verify(whitelistMerkelRoot, keccak256(abi.encodePacked(_msgSender()))),
        "You aren't whitelisted"
      );
    }

    uint256 totalChumCost = 0;
    uint256 totalEthCost = 0;
    for (uint16 i = 1; i <= amount; i++) {
      uint16 tokenId = minted + pendingMintAmt + i;
      if (tokenId <= paidTokens) {
        totalEthCost += ethCost;
      }
      totalChumCost += mintCostChum(tokenId, maxTokens);
    }

    if (freeMints[_msgSender()] >= 0) {
      if (freeMints[_msgSender()] >= amount) {
        totalEthCost = 0;
        freeMints[_msgSender()] -= amount;
      } else {
        totalEthCost -= ethCost * freeMints[_msgSender()];
        freeMints[_msgSender()] = 0;
      }
    }

    require(msg.value >= totalEthCost, "Not enough ETH");
    if (totalChumCost > 0) {
      chumToken.burn(_msgSender(), totalChumCost);
      chumToken.updateOriginAccess();
    }
    uint16 amt = uint16(amount);
    _mintCommits[_msgSender()][_commitId] = MintCommit(stake, amt);
    _pendingCommitId[_msgSender()] = _commitId;
    pendingMintAmt += amt;
    _mintedByWallet[_msgSender()] += amount;
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
    uint16 minted = sharksNft.minted();
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
        sharksNft.mint(recipient, seed);
      } else {
        sharksNft.mint(address(coral), seed);
      }
    }
    sharksNft.updateOriginAccess(tokenIds);
    if(commit.stake) {
      coral.addManyToCoral(addr, tokenIds);
    }
    delete _mintCommits[addr][commitIdCur];
    delete _pendingCommitId[addr];
    emit MintCommitted(addr, tokenIds.length);
  }

  function mintCostChum(uint256 tokenId, uint256 maxTokens) public view returns (uint256) {

    if (tokenId <= maxTokens / 6) return 0;
    if (tokenId <= maxTokens / 3) return maxChumCost / 4;
    if (tokenId <= maxTokens * 2 / 3) return maxChumCost / 2;
    return maxChumCost;
  }


  function selectRecipient(uint256 seed) internal view returns (address) {

    if (((seed >> 245) % 10) != 0) return _msgSender(); // top 10 bits haven't been used
    address thief = coral.randomTokenOwner(ISharks.SGTokenType.ORCA, seed >> 144); // 144 bits reserved for trait selection
    if (thief == address(0x0)) return _msgSender();
    return thief;
  }


  function setPaused(bool _paused) external requireContractsSet onlyOwner {

    if (_paused) _pause();
    else _unpause();
  }

  function setMaxChumCost(uint256 _amount) external requireContractsSet onlyOwner {

    maxChumCost = _amount;
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