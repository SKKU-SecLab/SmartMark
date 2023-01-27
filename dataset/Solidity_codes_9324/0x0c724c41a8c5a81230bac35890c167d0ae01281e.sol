
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

interface ITrainingGrounds {

  function addManyToTowerAndFlight(address tokenOwner, uint16[] calldata tokenIds) external;

  function claimManyFromTowerAndFlight(address tokenOwner, uint16[] calldata tokenIds, bool unstake) external;

  function addManyToTrainingAndFlight(uint256 seed, address tokenOwner, uint16[] calldata tokenIds) external;

  function claimManyFromTrainingAndFlight(uint256 seed, address tokenOwner, uint16[] calldata tokenIds, bool unstake) external;

  function randomDragonOwner(uint256 seed) external view returns (address);

  function isTokenStaked(uint256 tokenId, bool isTraining) external view returns (bool);

  function ownsToken(uint256 tokenId) external view returns (bool);

  function calculateGpRewards(uint256 tokenId) external view returns (uint256 owed);

  function calculateErcEmissionRewards(uint256 tokenId) external view returns (uint256 owed);

  function curWhipsEmitted() external view returns (uint16);

  function curMagicRunesEmitted() external view returns (uint16);

  function totalGPEarned() external view returns (uint256);

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

}// MIT LICENSE

pragma solidity ^0.8.0;


contract WnDGameTG is IWnDGame, Ownable, ReentrancyGuard, Pausable {


  struct MintCommit {
    address recipient;
    bool stake;
    uint16 amount;
  }

  struct TrainingCommit {
    address tokenOwner;
    uint16 tokenId;
    bool isAdding; // If false, the commit is for claiming rewards
    bool isUnstaking; // If !isAdding, this will determine if user is unstaking
    bool isTraining; // If !isAdding, this will define where the staked token is (only necessary for wizards)
  }

  uint256 public constant TREASURE_CHEST = 5;
  uint256 private maxGpCost = 72000 ether;

  mapping(uint16 => MintCommit[]) private commitQueueMints;
  mapping(uint16 => uint256) private commitIdStartTimeMints;
  mapping(address => uint16) private pendingMintCommitsForAddr;
  uint16 private _commitIdCurMints = 1;
  uint16 private _commitIdPendingMints = 0;
  mapping(uint16 => TrainingCommit[]) private commitQueueTraining;
  mapping(uint16 => uint256) private commitIdStartTimeTraining;
  mapping(address => uint16) private pendingTrainingCommitsForAddr;
  mapping(uint256 => bool) private tokenHasPendingCommit;
  uint16 private _commitIdCurTraining = 1;
  uint16 private _commitIdPendingTraining = 0;

  uint64 private timePerCommitBatch = 5 minutes;
  uint64 private timeToAllowArb = 1 hours;
  uint16 private pendingMintAmt;
  bool public allowCommits = true;

  uint256 private revealRewardAmt = 36000 ether;
  uint256 private stakingCost = 8000 ether;

  ITrainingGrounds public trainingGrounds;
  IGP public gpToken;
  ITraits public traits;
  IWnD public wndNFT;
  ISacrificialAlter public alter;

  constructor() {
    _pause();
  }


  modifier requireContractsSet() {

      require(address(gpToken) != address(0) && address(traits) != address(0) 
        && address(wndNFT) != address(0) && address(alter) != address(0)
         && address(trainingGrounds) != address(0)
        , "Contracts not set");
      _;
  }

  function setContracts(address _gp, address _traits, address _wnd, address _alter, address _trainingGrounds) external onlyOwner {

    gpToken = IGP(_gp);
    traits = ITraits(_traits);
    wndNFT = IWnD(_wnd);
    alter = ISacrificialAlter(_alter);
    trainingGrounds = ITrainingGrounds(_trainingGrounds);
  }


  function getPendingMintCommits(address addr) external view returns (uint16) {

    return pendingMintCommitsForAddr[addr];
  }
  function getPendingTrainingCommits(address addr) external view returns (uint16) {

    return pendingTrainingCommitsForAddr[addr];
  }
  function isTokenPendingReveal(uint256 tokenId) external view returns (bool) {

    return tokenHasPendingCommit[tokenId];
  }
  function hasStaleMintCommit() external view returns (bool) {

    uint16 pendingId = _commitIdPendingMints;
    while(commitQueueMints[pendingId].length == 0 && pendingId < _commitIdCurMints) {
      pendingId += 1;
    }
    return commitIdStartTimeMints[pendingId] < block.timestamp - timeToAllowArb && commitQueueMints[pendingId].length > 0;
  }
  function hasStaleTrainingCommit() external view returns (bool) {

    uint16 pendingId = _commitIdPendingTraining;
    while(commitQueueTraining[pendingId].length == 0 && pendingId < _commitIdCurTraining) {
      pendingId += 1;
    }
    return commitIdStartTimeTraining[pendingId] < block.timestamp - timeToAllowArb && commitQueueTraining[pendingId].length > 0;
  }

  function revealOldestMint() external whenNotPaused {

    require(tx.origin == _msgSender(), "Only EOA");

    while(commitQueueMints[_commitIdPendingMints].length == 0 && _commitIdPendingMints < _commitIdCurMints) {
      _commitIdPendingMints += 1;
    }
    require(commitIdStartTimeMints[_commitIdPendingMints] < block.timestamp - timeToAllowArb && commitQueueMints[_commitIdPendingMints].length > 0, "No stale commits to reveal");
    MintCommit memory commit = commitQueueMints[_commitIdPendingMints][commitQueueMints[_commitIdPendingMints].length - 1];
    commitQueueMints[_commitIdPendingMints].pop();
    revealMint(commit);
    gpToken.mint(_msgSender(), revealRewardAmt * commit.amount);
  }

  function skipOldestMint() external onlyOwner {

    while(commitQueueMints[_commitIdPendingMints].length == 0 && _commitIdPendingMints < _commitIdCurMints) {
      _commitIdPendingMints += 1;
    }
    require(commitQueueMints[_commitIdPendingMints].length > 0, "No stale commits to reveal");
    commitQueueMints[_commitIdPendingMints].pop();
  }

  function revealOldestTraining() external whenNotPaused {

    require(tx.origin == _msgSender(), "Only EOA");

    while(commitQueueTraining[_commitIdPendingTraining].length == 0 && _commitIdPendingTraining < _commitIdCurTraining) {
      _commitIdPendingTraining += 1;
    }
    require(commitIdStartTimeTraining[_commitIdPendingTraining] < block.timestamp - timeToAllowArb && commitQueueTraining[_commitIdPendingTraining].length > 0, "No stale commits to reveal");
    TrainingCommit memory commit = commitQueueTraining[_commitIdPendingTraining][commitQueueTraining[_commitIdPendingTraining].length - 1];
    commitQueueTraining[_commitIdPendingTraining].pop();
    revealTraining(commit);
    gpToken.mint(_msgSender(), revealRewardAmt);
  }

  function skipOldestTraining() external onlyOwner {

    while(commitQueueTraining[_commitIdPendingTraining].length == 0 && _commitIdPendingTraining < _commitIdCurTraining) {
      _commitIdPendingTraining += 1;
    }
    require(commitQueueTraining[_commitIdPendingTraining].length > 0, "No stale commits to reveal");
    TrainingCommit memory commit = commitQueueTraining[_commitIdPendingTraining][commitQueueTraining[_commitIdPendingTraining].length - 1];
    commitQueueTraining[_commitIdPendingTraining].pop();
    tokenHasPendingCommit[commit.tokenId] = false;
  }

  function mintCommit(uint256 amount, bool stake) external whenNotPaused nonReentrant {

    require(allowCommits, "adding commits disallowed");
    require(tx.origin == _msgSender(), "Only EOA");
    uint16 minted = wndNFT.minted();
    uint256 maxTokens = wndNFT.getMaxTokens();
    require(minted + pendingMintAmt + amount <= maxTokens, "All tokens minted");
    require(amount > 0 && amount <= 10, "Invalid mint amount");
    if(commitIdStartTimeMints[_commitIdCurMints] == 0) {
      commitIdStartTimeMints[_commitIdCurMints] = block.timestamp;
    }

    if(commitIdStartTimeMints[_commitIdCurMints] < block.timestamp - timePerCommitBatch) {
      _commitIdCurMints += 1;
      commitIdStartTimeMints[_commitIdCurMints] = block.timestamp;
    }

    uint256 totalGpCost = 0;
    for (uint i = 1; i <= amount; i++) {
      commitQueueMints[_commitIdCurMints].push(MintCommit(_msgSender(), stake, 1));
      totalGpCost += mintCost(minted + pendingMintAmt + i, maxTokens);
    }
    if (totalGpCost > 0) {
      gpToken.burn(_msgSender(), totalGpCost);
      gpToken.updateOriginAccess();
    }
    uint16 amt = uint16(amount);
    pendingMintCommitsForAddr[_msgSender()] += amt;
    pendingMintAmt += amt;

    while(commitQueueMints[_commitIdPendingMints].length == 0 && _commitIdPendingMints < _commitIdCurMints) {
      _commitIdPendingMints += 1;
    }
    if(commitIdStartTimeMints[_commitIdPendingMints] < block.timestamp - timePerCommitBatch && commitQueueMints[_commitIdPendingMints].length > 0) {
      for (uint256 i = 0; i < amount; i++) {
        MintCommit memory commit = commitQueueMints[_commitIdPendingMints][commitQueueMints[_commitIdPendingMints].length - 1];
        commitQueueMints[_commitIdPendingMints].pop();
        revealMint(commit);
        if(commitQueueMints[_commitIdPendingMints].length == 0 && _commitIdPendingMints < _commitIdCurMints) {
          _commitIdPendingMints += 1;
          if(commitIdStartTimeMints[_commitIdPendingMints] > block.timestamp - timePerCommitBatch 
            || commitQueueMints[_commitIdPendingMints].length == 0
            || _commitIdPendingMints == _commitIdCurMints)
          {
            break;
          }
        }
      }
    }
  }

  function revealMint(MintCommit memory commit) internal {

    uint16 minted = wndNFT.minted();
    pendingMintAmt -= commit.amount;
    uint16[] memory tokenIds = new uint16[](commit.amount);
    uint16[] memory tokenIdsToStake = new uint16[](commit.amount);
    uint256 seed = uint256(keccak256(abi.encode(commit.recipient, minted, commitIdStartTimeMints[_commitIdPendingMints])));
    for (uint k = 0; k < commit.amount; k++) {
      minted++;
      seed = uint256(keccak256(abi.encode(seed, commit.recipient)));
      address recipient = selectRecipient(seed, commit.recipient);
      if(recipient != commit.recipient && alter.balanceOf(commit.recipient, TREASURE_CHEST) > 0) {
        if(seed & 1 == 1) {
          alter.safeTransferFrom(commit.recipient, recipient, TREASURE_CHEST, 1, "");
          recipient = commit.recipient;
        }
      }
      tokenIds[k] = minted;
      if (!commit.stake || recipient != commit.recipient) {
        wndNFT.mint(recipient, seed);
      } else {
        wndNFT.mint(address(trainingGrounds), seed);
        tokenIdsToStake[k] = minted;
      }
    }
    wndNFT.updateOriginAccess(tokenIds);
    if(commit.stake && tokenIdsToStake[0] != 0) {
      trainingGrounds.addManyToTowerAndFlight(commit.recipient, tokenIdsToStake);
    }
    pendingMintCommitsForAddr[commit.recipient] -= commit.amount;
  }

  function addToTower(uint16[] calldata tokenIds) external whenNotPaused {

    require(_msgSender() == tx.origin, "Only EOA");
    for (uint256 i = 0; i < tokenIds.length; i++) {
      require(!tokenHasPendingCommit[tokenIds[i]], "token has pending commit");
    }
    trainingGrounds.addManyToTowerAndFlight(tx.origin, tokenIds);
  }

  function addToTrainingCommit(uint16[] calldata tokenIds) external whenNotPaused {

    require(allowCommits, "adding commits disallowed");
    require(tx.origin == _msgSender(), "Only EOA");
    if(commitIdStartTimeTraining[_commitIdCurTraining] == 0) {
      commitIdStartTimeTraining[_commitIdCurTraining] = block.timestamp;
    }

    if(commitIdStartTimeTraining[_commitIdCurTraining] < block.timestamp - timePerCommitBatch) {
      _commitIdCurTraining += 1;
      commitIdStartTimeTraining[_commitIdCurTraining] = block.timestamp;
    }
    uint16 numDragons;
    for (uint i = 0; i < tokenIds.length; i++) {
      require(address(trainingGrounds) != wndNFT.ownerOf(tokenIds[i]), "token already staked");
      require(!tokenHasPendingCommit[tokenIds[i]], "token has pending commit");
      require(_msgSender() == wndNFT.ownerOf(tokenIds[i]), "not owner of token");
      if(!wndNFT.isWizard(tokenIds[i])) {
        numDragons += 1;
      }
      tokenHasPendingCommit[tokenIds[i]] = true;
      commitQueueTraining[_commitIdCurTraining].push(TrainingCommit(_msgSender(), tokenIds[i], true, false, true));
    }
    gpToken.burn(_msgSender(), stakingCost * (tokenIds.length - numDragons)); // Dragons are free to stake
    gpToken.updateOriginAccess();
    pendingTrainingCommitsForAddr[_msgSender()] += uint16(tokenIds.length);
    tryRevealTraining(tokenIds.length);
  }

  function claimTrainingsCommit(uint16[] calldata tokenIds, bool isUnstaking, bool isTraining) external whenNotPaused {

    require(allowCommits, "adding commits disallowed");
    require(tx.origin == _msgSender(), "Only EOA");
    if(commitIdStartTimeTraining[_commitIdCurTraining] == 0) {
      commitIdStartTimeTraining[_commitIdCurTraining] = block.timestamp;
    }

    if(commitIdStartTimeTraining[_commitIdCurTraining] < block.timestamp - timePerCommitBatch) {
      _commitIdCurTraining += 1;
      commitIdStartTimeTraining[_commitIdCurTraining] = block.timestamp;
    }
    for (uint i = 0; i < tokenIds.length; i++) {
      require(!tokenHasPendingCommit[tokenIds[i]], "token has pending commit");
      require(trainingGrounds.isTokenStaked(tokenIds[i], isTraining) && trainingGrounds.ownsToken(tokenIds[i])
      , "Token not in staking pool");
      uint64 lastTokenWrite = wndNFT.getTokenWriteBlock(tokenIds[i]);
      require(lastTokenWrite < block.number, "hmmmm what doing?");
      if(isUnstaking && wndNFT.isWizard(tokenIds[i])) {
        if(isTraining) {
          require(trainingGrounds.curWhipsEmitted() >= 16000
            || trainingGrounds.calculateErcEmissionRewards(tokenIds[i]) > 0, "can't unstake wizard yet");
        }
        else {
          require(trainingGrounds.totalGPEarned() > 500000000 ether - 4000 ether
            || trainingGrounds.calculateGpRewards(tokenIds[i]) >= 4000 ether, "can't unstake wizard yet");
        }
      }
      tokenHasPendingCommit[tokenIds[i]] = true;
      commitQueueTraining[_commitIdCurTraining].push(TrainingCommit(_msgSender(), tokenIds[i], false, isUnstaking, isTraining));
    }
    if(isUnstaking) {
      gpToken.burn(_msgSender(), stakingCost * tokenIds.length);
      gpToken.updateOriginAccess();
    }
    pendingTrainingCommitsForAddr[_msgSender()] += uint16(tokenIds.length);
    tryRevealTraining(tokenIds.length);
  }

  function tryRevealTraining(uint256 amount) internal {

    while(commitQueueTraining[_commitIdPendingTraining].length == 0 && _commitIdPendingTraining < _commitIdCurTraining) {
      _commitIdPendingTraining += 1;
    }
    if(commitIdStartTimeTraining[_commitIdPendingTraining] < block.timestamp - timePerCommitBatch && commitQueueTraining[_commitIdPendingTraining].length > 0) {
      for (uint256 i = 0; i < amount; i++) {
        TrainingCommit memory commit = commitQueueTraining[_commitIdPendingTraining][commitQueueTraining[_commitIdPendingTraining].length - 1];
        commitQueueTraining[_commitIdPendingTraining].pop();
        revealTraining(commit);
        if(commitQueueTraining[_commitIdPendingTraining].length == 0 && _commitIdPendingTraining < _commitIdCurTraining) {
          _commitIdPendingTraining += 1;
          if(commitIdStartTimeTraining[_commitIdPendingTraining] > block.timestamp - timePerCommitBatch 
            || commitQueueTraining[_commitIdPendingTraining].length == 0
            || _commitIdPendingTraining == _commitIdCurTraining)
          {
            break;
          }
        }
      }
    }
  }

  function revealTraining(TrainingCommit memory commit) internal {

    uint16[] memory idSingle = new uint16[](1);
    idSingle[0] = commit.tokenId;
    tokenHasPendingCommit[commit.tokenId] = false;
    if(commit.isAdding) {
      if(wndNFT.ownerOf(commit.tokenId) != commit.tokenOwner) {
        return;
      }
      if(wndNFT.isWizard(commit.tokenId)) {
        uint256 seed = random(commit.tokenId, commitIdStartTimeTraining[_commitIdPendingTraining], commit.tokenOwner);
        trainingGrounds.addManyToTrainingAndFlight(seed, commit.tokenOwner, idSingle);
      }
      else {
        trainingGrounds.addManyToTowerAndFlight(commit.tokenOwner, idSingle);
      }
    }
    else {
      if(!trainingGrounds.isTokenStaked(commit.tokenId, commit.isTraining)) {
        return;
      }
      if(commit.isTraining) {
        uint256 seed = random(commit.tokenId, commitIdStartTimeTraining[_commitIdPendingTraining], commit.tokenOwner);
        trainingGrounds.claimManyFromTrainingAndFlight(seed, commit.tokenOwner, idSingle, commit.isUnstaking);
      }
      else {
        trainingGrounds.claimManyFromTowerAndFlight(commit.tokenOwner, idSingle, commit.isUnstaking);
      }
    }
    pendingTrainingCommitsForAddr[commit.tokenOwner] -= 1;
  }

  function random(uint16 tokenId, uint256 time, address owner) internal pure returns (uint256) {

    return uint256(keccak256(abi.encodePacked(
      owner,
      tokenId,
      time
    )));
  }

  function mintCost(uint256 tokenId, uint256 maxTokens) public view returns (uint256) {

    if (tokenId <= maxTokens * 8 / 20) return 24000 ether;
    if (tokenId <= maxTokens * 11 / 20) return 36000 ether;
    if (tokenId <= maxTokens * 14 / 20) return 48000 ether;
    if (tokenId <= maxTokens * 17 / 20) return 60000 ether; 
    return maxGpCost;
  }

  function makeTreasureChests(uint16 qty) external whenNotPaused {

    require(tx.origin == _msgSender(), "Only EOA");
    alter.mint(TREASURE_CHEST, qty, _msgSender());
  }

  function sellTreasureChests(uint16 qty) external whenNotPaused {

    require(tx.origin == _msgSender(), "Only EOA");
    alter.burn(TREASURE_CHEST, qty, _msgSender());
  }


  function selectRecipient(uint256 seed, address committer) internal view returns (address) {

    if (((seed >> 245) % 10) != 0) return committer; // top 10 bits haven't been used
    address thief = trainingGrounds.randomDragonOwner(seed >> 144); // 144 bits reserved for trait selection
    if (thief == address(0x0)) return committer;
    return thief;
  }


  function setPaused(bool _paused) external requireContractsSet onlyOwner {

    if (_paused) _pause();
    else _unpause();
  }

  function setMaxGpCost(uint256 _amount) external requireContractsSet onlyOwner {

    maxGpCost = _amount;
  }

  function setAllowCommits(bool allowed) external onlyOwner {

    allowCommits = allowed;
  }

  function setRevealRewardAmt(uint256 rewardAmt) external onlyOwner {

    revealRewardAmt = rewardAmt;
  }

  function setPendingMintAmt(uint256 pendingAmt) external onlyOwner {

    pendingMintAmt = uint16(pendingAmt);
  }

  function withdraw() external onlyOwner {

    payable(owner()).transfer(address(this).balance);
  }
}