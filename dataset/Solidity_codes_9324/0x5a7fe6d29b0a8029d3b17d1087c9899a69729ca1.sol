
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

interface IERC721Receiver {

    function onERC721Received(
        address operator,
        address from,
        uint256 tokenId,
        bytes calldata data
    ) external returns (bytes4);

}// MIT

pragma solidity ^0.8.0;


interface IERC721Enumerable is IERC721 {

    function totalSupply() external view returns (uint256);


    function tokenOfOwnerByIndex(address owner, uint256 index) external view returns (uint256 tokenId);


    function tokenByIndex(uint256 index) external view returns (uint256);

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

interface IChum {

    function mint(address to, uint256 amount) external;

    function burn(address from, uint256 amount) external;

    function updateOriginAccess() external;

    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

}// MIT LICENSE

pragma solidity ^0.8.0;


interface ICoral {

  function addManyToCoral(address account, uint16[] calldata tokenIds) external;

  function randomTokenOwner(ISharks.SGTokenType tokenType, uint256 seed) external view returns (address);

}// MIT LICENSE

pragma solidity ^0.8.0;

interface IRandomizer {

    function random() external returns (uint256);

}// MIT LICENSE

pragma solidity ^0.8.0;


contract Coral is ICoral, Ownable, ReentrancyGuard, IERC721Receiver, Pausable {

  struct Stake {
    uint16 tokenId;
    uint80 value;
    uint256 timestamp;
    address owner;
  }

  event TokenStaked(address indexed owner, uint256 indexed tokenId, ISharks.SGTokenType indexed tokenType);
  event TokenClaimed(uint256 indexed tokenId, bool indexed unstaked, ISharks.SGTokenType indexed tokenType, uint256 earned);

  ISharks public sharksNft;
  ISharkGame public sharkGame;
  IChum public chumToken;
  IRandomizer public randomizer;

  mapping(ISharks.SGTokenType => uint16) public numStaked;
  mapping(uint16 => Stake) public coral;
  mapping(ISharks.SGTokenType => uint16[]) public coralByType;
  mapping(uint16 => uint256) public  coralByTypeIndex;
  uint256[] public unaccountedRewards = [0, 0, 0];
  uint256[] public chumStolen = [0, 0, 0];
  bool public orcasEnabled = false;

  uint256[] public DAILY_CHUM_RATES = [10000 ether, 0, 20000 ether];
  uint256 public constant MINIMUM_TO_EXIT = 2 days;
  uint256 public constant SHARK_RISK_CHANCE = 5;
  uint256 public constant MINNOW_CLAIM_TAX = 20;
  uint256 public constant SHARK_CLAIM_TAX = 10;
  uint256 public constant MAXIMUM_GLOBAL_CHUM = 5000000000 ether;

  uint256 public totalChumEarned;
  uint256 private lastClaimTimestamp;

  bool public rescueEnabled = false;

  constructor() {
    _pause();
  }


  modifier requireContractsSet() {

      require(address(sharksNft) != address(0) && address(chumToken) != address(0)
        && address(sharkGame) != address(0) && address(randomizer) != address(0), "Contracts not set");
      _;
  }

  function setContracts(address _sharksNft, address _chum, address _sharkGame, address _rand) external onlyOwner {

    sharksNft = ISharks(_sharksNft);
    chumToken = IChum(_chum);
    sharkGame = ISharkGame(_sharkGame);
    randomizer = IRandomizer(_rand);
  }


  function addManyToCoral(address account, uint16[] calldata tokenIds) external override _updateEarnings nonReentrant {

    require(tx.origin == _msgSender() || _msgSender() == address(sharkGame), "Only EOA");
    require(account == tx.origin, "account to sender mismatch");
    for (uint i = 0; i < tokenIds.length; i++) {
      uint16 tokenId = tokenIds[i];
      if (_msgSender() != address(sharkGame)) { // dont do this step if its a mint + stake
        require(sharksNft.ownerOf(tokenIds[i]) == _msgSender(), "You don't own this token");
        sharksNft.transferFrom(_msgSender(), address(this), tokenIds[i]);
      } else if (tokenId == 0) {
        continue; // there may be gaps in the array for stolen tokens
      }

      ISharks.SGTokenType tokenType = sharksNft.getTokenType(tokenId);
      coral[tokenId] = Stake({
        owner: account,
        tokenId: uint16(tokenId),
        value: uint80(chumStolen[uint8(tokenType)]),
        timestamp: block.timestamp
      });
      coralByTypeIndex[tokenId] = coralByType[tokenType].length;
      coralByType[tokenType].push(tokenId);
      numStaked[tokenType] += 1;
      if (tokenType == ISharks.SGTokenType.ORCA) {
        orcasEnabled = true;
      }
      emit TokenStaked(account, tokenId, tokenType);
    }
  }


  function claimManyFromCoral(uint16[] calldata tokenIds, bool unstake) external whenNotPaused _updateEarnings nonReentrant {

    require(tx.origin == _msgSender() || _msgSender() == address(sharkGame), "Only EOA");
    uint256 owed = 0;
    for (uint i = 0; i < tokenIds.length; i++) {
      uint16 tokenId = tokenIds[i];
      Stake memory stake = coral[tokenId];
      require(stake.owner != address(0), "Token is not staked");
      uint256 tokenOwed = this.calculateRewards(stake);
      ISharks.SGTokenType tokenType = sharksNft.getTokenType(tokenId);

      if (unstake) {
        address recipient = _msgSender();
        if (tokenType == ISharks.SGTokenType.MINNOW) {
          if (randomizer.random() & 1 == 1) {
            uint256 orcasSteal = tokenOwed * 3 / 10;
            _payTax(orcasSteal, ISharks.SGTokenType.ORCA);
            _payTax(tokenOwed - orcasSteal, ISharks.SGTokenType.SHARK);
            tokenOwed = 0;
          }
        } else if (tokenType == ISharks.SGTokenType.SHARK) {
          uint256 seed = randomizer.random();
          if (orcasEnabled && (seed & 0xFFFF) % 100 < SHARK_RISK_CHANCE) {
            recipient = this.randomTokenOwner(ISharks.SGTokenType.ORCA, seed);
          }
        }

        delete coral[tokenId];
        if (coralByType[tokenType].length > 1) {
          coralByTypeIndex[coralByType[tokenType][coralByType[tokenType].length - 1]] = coralByTypeIndex[tokenId];
          coralByType[tokenType][coralByTypeIndex[tokenId]] = coralByType[tokenType][coralByType[tokenType].length - 1];
        }
        coralByType[tokenType].pop();
        numStaked[tokenType] -= 1;
        sharksNft.safeTransferFrom(address(this), recipient, tokenId, "");
      } else {
        if (tokenType == ISharks.SGTokenType.MINNOW) {
          uint256 sharksSteal = tokenOwed * MINNOW_CLAIM_TAX / 100;
          _payTax(sharksSteal, ISharks.SGTokenType.SHARK);
          tokenOwed -= sharksSteal;
        } else if (tokenType == ISharks.SGTokenType.SHARK && orcasEnabled) {
          uint256 orcasSteal = tokenOwed * SHARK_CLAIM_TAX / 100;
          _payTax(orcasSteal, ISharks.SGTokenType.ORCA);
          tokenOwed -= orcasSteal;
        }
        coral[tokenId] = Stake({
          owner: _msgSender(),
          tokenId: uint16(tokenId),
          value: uint80(chumStolen[uint8(tokenType)]),
          timestamp: block.timestamp
        }); // reset stake
      }
      owed += tokenOwed;
      emit TokenClaimed(tokenId, unstake, tokenType, owed);
    }
    chumToken.updateOriginAccess();
    if (owed == 0) {
      return;
    }
    chumToken.mint(_msgSender(), owed);
  }

  function calculateRewards(Stake calldata stake) external view returns (uint256 owed) {

    uint64 lastTokenWrite = sharksNft.getTokenWriteBlock(stake.tokenId);
    require(lastTokenWrite < block.number, "hmmmm what doing?");
    uint8 tokenType = uint8(sharksNft.getTokenType(stake.tokenId));
    uint256 dailyRate = DAILY_CHUM_RATES[tokenType];
    if (dailyRate > 0) {
      if (totalChumEarned < MAXIMUM_GLOBAL_CHUM) {
        owed = (block.timestamp - stake.timestamp) * DAILY_CHUM_RATES[tokenType] / 1 days;
      } else if (stake.timestamp > lastClaimTimestamp) {
        owed = 0; // $CHUM production stopped already
      } else {
        owed = (lastClaimTimestamp - stake.timestamp) * DAILY_CHUM_RATES[tokenType] / 1 days; // stop earning additional $CHUM if it's all been earned
      }
    }
    owed += chumStolen[tokenType] - stake.value;
  }

  function rescue(uint16[] calldata tokenIds) external nonReentrant {

    require(rescueEnabled, "RESCUE DISABLED");
    uint16 tokenId;
    ISharks.SGTokenType tokenType;
    Stake memory stake;
    for (uint i = 0; i < tokenIds.length; i++) {
      tokenId = tokenIds[i];
      tokenType = sharksNft.getTokenType(tokenId);
      stake = coral[tokenId];
      require(stake.owner == _msgSender(), "SWIPER, NO SWIPING");
      delete coral[tokenId];
      if (coralByType[tokenType].length > 1) {
        coralByTypeIndex[coralByType[tokenType][coralByType[tokenType].length - 1]] = coralByTypeIndex[tokenId];
        coralByType[tokenType][coralByTypeIndex[tokenId]] = coralByType[tokenType][coralByType[tokenType].length - 1];
      }
      coralByType[tokenType].pop();
      numStaked[tokenType] -= 1;
      sharksNft.safeTransferFrom(address(this), _msgSender(), tokenId, "");
      emit TokenClaimed(tokenId, true, tokenType, 0);
    }
  }


  function _payTax(uint256 amount, ISharks.SGTokenType tokenType) internal {

    if (numStaked[tokenType] == 0) { // if there's no staked sharks/orcas
      unaccountedRewards[uint8(tokenType)] += amount; // keep track of $CHUM due to sharks/orcas
      return;
    }
    chumStolen[uint8(tokenType)] += (amount + unaccountedRewards[uint8(tokenType)]) / numStaked[tokenType];
    unaccountedRewards[uint8(tokenType)] = 0;
  }

  modifier _updateEarnings() {

    if (totalChumEarned < MAXIMUM_GLOBAL_CHUM) {
      totalChumEarned +=
        (block.timestamp - lastClaimTimestamp)
        * numStaked[ISharks.SGTokenType.MINNOW]
        * DAILY_CHUM_RATES[uint8(ISharks.SGTokenType.MINNOW)] / 1 days
      + (block.timestamp - lastClaimTimestamp)
        * numStaked[ISharks.SGTokenType.ORCA]
        * DAILY_CHUM_RATES[uint8(ISharks.SGTokenType.ORCA)] / 1 days;
      lastClaimTimestamp = block.timestamp;
    }
    _;
  }


  function setRescueEnabled(bool _enabled) external onlyOwner {

    rescueEnabled = _enabled;
  }

  function setPaused(bool _paused) external requireContractsSet onlyOwner {

    if (_paused) _pause();
    else _unpause();
  }


  function randomTokenOwner(ISharks.SGTokenType tokenType, uint256 seed) external view override returns (address) {

    uint256 numStakedOfType = numStaked[tokenType];
    if (numStakedOfType == 0) {
      return address(0x0);
    }
    uint256 i = (seed & 0xFFFFFFFF) % numStakedOfType; // choose a value from 0 to total rank staked
    return coral[coralByType[tokenType][i]].owner;
  }

  function onERC721Received(
        address,
        address from,
        uint256,
        bytes calldata
    ) external pure override returns (bytes4) {

      require(from == address(0x0), "Cannot send to Coral directly");
      return IERC721Receiver.onERC721Received.selector;
    }
}