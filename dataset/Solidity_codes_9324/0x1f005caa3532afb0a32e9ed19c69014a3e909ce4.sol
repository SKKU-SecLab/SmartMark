
pragma solidity ^0.8.0;

interface IERC20 {

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

pragma solidity ^0.8.7;


interface ICareToken is IERC20 {

  function mintToApprovedContract(uint256 amount, address mintToAddress) external;

  function burn(address sender, uint256 paymentAmount) external;

}

interface ISpiritOrbPetsv1 is IERC721, IERC721Enumerable {

  function getPetInfo(uint16 id) external view returns (
    uint8 level,
    bool active
  );


  function getPetCooldowns(uint16 id) external view returns (
    uint64 cdPlay,
    uint64 cdFeed,
    uint64 cdClean,
    uint64 cdTrain,
    uint64 cdDaycare
  );


  function getPausedState() external view returns (bool);

  function getMaxPetLevel() external view returns (uint8);

  function petName(uint16 id) external view returns (string memory);


  function setPetName(uint16 id, string memory name) external;

  function setPetLevel(uint16 id, uint8 level) external;

  function setPetActive(uint16 id, bool active) external;

  function setPetCdPlay(uint16 id, uint64 cdPlay) external;

  function setPetCdFeed(uint16 id, uint64 cdFeed) external;

  function setPetCdClean(uint16 id, uint64 cdClean) external;

  function setPetCdTrain(uint16 id, uint64 cdTrain) external;

  function setPetCdDaycare(uint16 id, uint64 cdDaycare) external;

}

contract SpiritOrbPetsCarev1 is Ownable {


    ISpiritOrbPetsv1 public SOPv1;
    ICareToken public CareToken;

    uint256 public _timeUntilLevelDown = 72 hours; // 259200 uint value in seconds

    event Activated(address sender, uint16 id);
    event Deactivated(address sender, uint16 id);
    event PlayedWithPet(address sender, uint16 id, bool levelDownEventOccurred);
    event FedPet(address sender, uint16 id, uint careTokensToPay, bool levelDownEventOccurred);
    event CleanedPet(address sender,uint16 id, bool levelDownEventOccurred);
    event TrainedPet(address sender, uint16 id);
    event SentToDaycare(address sender, uint16 id, uint daysToPayFor);

    modifier notAtDaycare(uint16 id) {

      ( , , , , uint cdDaycare ) = SOPv1.getPetCooldowns(id);
      require(cdDaycare <= block.timestamp, "Cannot perform action while pet is at daycare.");
      _;
    }

    function setTimeUntilLevelDown(uint256 newTime) external onlyOwner {

      _timeUntilLevelDown = newTime;
    }

    function getTrueLevel(uint16 id) public view returns (uint8) {

      (uint64 cdPlay, uint64 cdFeed, uint64 cdClean, , ) = SOPv1.getPetCooldowns(id);
      (uint8 level, ) = SOPv1.getPetInfo(id);
      uint64 blockTimestamp = uint64(block.timestamp);
      bool hungry = cdFeed <= blockTimestamp;
      bool dirty = cdClean + _timeUntilLevelDown <= blockTimestamp;
      bool unhappy = cdPlay + _timeUntilLevelDown <= blockTimestamp;

      if (hungry && dirty && unhappy && level != 30) {
        level = 1;
      }
      if (hungry && level > 1 && level != 30) {
        level = level - 1;
      }
      if (dirty && level > 1 && level != 30) {
        level = level - 1;
      }
      if (unhappy && level > 1 && level != 30) {
        level = level - 1;
      }
      return level;
    }

    function activatePet(uint16 id) external {

      ( , bool active) = SOPv1.getPetInfo(id);
      require(!SOPv1.getPausedState(), "Pet adoption has not yet begun.");
      require(SOPv1.ownerOf(id) == msg.sender);
      require(!active, "Pet is already active!");

      resetPetCooldowns(id);

      emit Activated(msg.sender, id);
    }

    function resetPetCooldowns(uint16 id) internal {

      (uint64 cdPlay, , , , ) = SOPv1.getPetCooldowns(id);
      SOPv1.setPetActive(id, true);
      if (cdPlay == 0) SOPv1.setPetCdPlay(id, uint64(block.timestamp));
      SOPv1.setPetCdFeed(id, uint64(block.timestamp + 1 hours));
      SOPv1.setPetCdClean(id, uint64(block.timestamp + 3 days - 1 hours));
      SOPv1.setPetCdTrain(id, uint64(block.timestamp + 23 hours));
    }

    function deactivatePet(uint16 id) external {

      ( , , , , uint cdDaycare) = SOPv1.getPetCooldowns(id);
      (  uint8 level, bool active) = SOPv1.getPetInfo(id);
      require(SOPv1.ownerOf(id) == msg.sender);
      require(active, "Pet is not active yet.");

      SOPv1.setPetActive(id, false);
      if (cdDaycare > uint64(block.timestamp)) {
        SOPv1.setPetCdDaycare(id, 0);
        SOPv1.setPetCdPlay(id, uint64(block.timestamp));
      }
      if (level < SOPv1.getMaxPetLevel()) {
        SOPv1.setPetLevel(id, 1);
      }

      emit Deactivated(msg.sender, id);
    }

    function levelDown(uint16 id) internal {

      (uint64 cdPlay, uint64 cdFeed, uint64 cdClean, , ) = SOPv1.getPetCooldowns(id);
      (uint8 level, ) = SOPv1.getPetInfo(id);
      uint64 blockTimestamp = uint64(block.timestamp);
      bool hungry = cdFeed <= blockTimestamp;
      bool dirty = cdClean + _timeUntilLevelDown <= blockTimestamp;
      bool unhappy = cdPlay + _timeUntilLevelDown <= blockTimestamp;

      if (level > 1 && level != 30) {
        SOPv1.setPetLevel(id, level - 1);
      }

      if (hungry && dirty && unhappy && level != 30) {
        SOPv1.setPetLevel(id, 1);
      }
    }

    function levelUp(uint16 id) internal {

      (uint8 level, ) = SOPv1.getPetInfo(id);
      if (level < SOPv1.getMaxPetLevel()) {
        SOPv1.setPetLevel(id, level + 1);
      }
    }

    function playWithPet(uint16 id) external {

      (uint64 cdPlay, uint64 cdFeed, uint64 cdClean, , ) = SOPv1.getPetCooldowns(id);
      ( , bool active) = SOPv1.getPetInfo(id);
      require(SOPv1.ownerOf(id) == msg.sender, "Only the owner of the pet can play with it!");
      require(active, "Pet needs to be active to receive CARE tokens.");
      require(cdFeed >= uint64(block.timestamp), "Pet is too hungry to play.");
      require(cdClean >= uint64(block.timestamp), "Pet is too dirty to play.");
      require(cdPlay <= uint64(block.timestamp), "You can only redeem CARE tokens every 23 hours.");

      CareToken.mintToApprovedContract(10 * 10 ** 18, msg.sender);

      bool levelDownEventOccurred = false;
      if (cdPlay + _timeUntilLevelDown <= uint64(block.timestamp)) {
        levelDown(id);
        levelDownEventOccurred = true;
      }

      SOPv1.setPetCdPlay(id, uint64(block.timestamp + 23 hours));

      emit PlayedWithPet(msg.sender, id, levelDownEventOccurred);
    }

    function feedPet(uint16 id, uint careTokensToPay) external notAtDaycare(id) {

      ( , uint64 cdFeed, uint64 cdClean,  ,  ) = SOPv1.getPetCooldowns(id);
      ( , bool active) = SOPv1.getPetInfo(id);
      require(SOPv1.ownerOf(id) == msg.sender, "Only the owner of the pet can feed it!");
      require(active, "Pet needs to be active to feed it.");
      require(cdClean >= uint64(block.timestamp), "Pet is too dirty to eat.");
      require(careTokensToPay <= 15, "You should not overfeed your pet.");
      require(careTokensToPay >= 5, "Too little CARE sent to feed pet.");

      uint paymentAmount = careTokensToPay * 10 ** 18;
      CareToken.burn(msg.sender, paymentAmount);

      uint64 blockTimestamp = uint64(block.timestamp);

      bool levelDownEventOccurred = false;
      if (cdFeed <= blockTimestamp) {
        levelDown(id);
        levelDownEventOccurred = true;
      }

      if (cdFeed > blockTimestamp) {
        uint64 newFeedTime = cdFeed + uint64(careTokensToPay/5 * 1 days);
        SOPv1.setPetCdFeed(id, newFeedTime);
        if (newFeedTime > blockTimestamp + 3 days) {
          SOPv1.setPetCdFeed(id, blockTimestamp + 3 days);
        }
      } else {
        SOPv1.setPetCdFeed(id, uint64(blockTimestamp + (careTokensToPay/5 * 1 days))); //5 tokens per 24hrs up to 72hrs
      }

      emit FedPet(msg.sender, id, careTokensToPay, levelDownEventOccurred);
    }

    function cleanPet(uint16 id) external {

      ( , , uint64 cdClean, , ) = SOPv1.getPetCooldowns(id);
      ( , bool active) = SOPv1.getPetInfo(id);
      require(SOPv1.ownerOf(id) == msg.sender, "Only the owner of the pet can clean it!");
      require(active, "Pet needs to be active to clean.");
      uint64 blockTimestamp = uint64(block.timestamp);
      require(cdClean <= blockTimestamp, "Pet is not dirty yet.");

      CareToken.mintToApprovedContract(30 * 10 ** 18, msg.sender);

      bool levelDownEventOccurred = false;
      if ((cdClean + _timeUntilLevelDown) <= blockTimestamp) {
        levelDown(id);
        levelDownEventOccurred = true;
      }

      SOPv1.setPetCdClean(id, blockTimestamp + 3 days - 1 hours);
      emit CleanedPet(msg.sender, id, levelDownEventOccurred);
    }

    function trainPet(uint16 id) external notAtDaycare(id) {

      ( , uint64 cdFeed, uint64 cdClean, uint64 cdTrain, ) = SOPv1.getPetCooldowns(id);
      ( uint8 level, bool active) = SOPv1.getPetInfo(id);
      uint64 blockTimestamp = uint64(block.timestamp);
      require(SOPv1.ownerOf(id) == msg.sender, "Only the owner of the pet can train it!");
      require(active, "Pet needs to be active to train.");
      require(cdFeed >= blockTimestamp, "Pet is too hungry to train.");
      require(cdClean >= blockTimestamp, "Pet is too dirty to train.");
      require(cdTrain <= blockTimestamp, "Pet is too tired to train.");

      if (level < 30) {

        uint paymentAmount = 10 * 10 ** 18;
        CareToken.burn(msg.sender, paymentAmount);

        levelUp(id);
      } else {
        CareToken.mintToApprovedContract(10 * 10 ** 18, msg.sender);
      }

      SOPv1.setPetCdTrain(id, blockTimestamp + 23 hours);
      emit TrainedPet(msg.sender, id);
    }

    function sendToDaycare(uint16 id, uint daysToPayFor) external notAtDaycare(id) {

      (uint8 level , bool active) = SOPv1.getPetInfo(id);
      require(SOPv1.ownerOf(id) == msg.sender, "Only the owner of the pet can send it to daycare!");
      require(active, "Pet needs to be active to send it to daycare.");
      require(daysToPayFor >= 1, "Minimum 1 day of daycare required.");
      require(daysToPayFor <= 30, "You cannot send pet to daycare for that long.");

      require(getTrueLevel(id) == level, "Pet cannot go to daycare if it has been neglected.");

      uint paymentAmount = daysToPayFor * 10 * 10 ** 18;
      CareToken.burn(msg.sender, paymentAmount);

      uint timeToSendPet = daysToPayFor * 1 days;

      uint64 timeToSetCareCooldowns = uint64(block.timestamp + timeToSendPet);
      SOPv1.setPetCdDaycare(id, timeToSetCareCooldowns);
      SOPv1.setPetCdPlay(id, timeToSetCareCooldowns);
      SOPv1.setPetCdFeed(id, timeToSetCareCooldowns);
      SOPv1.setPetCdClean(id, timeToSetCareCooldowns + 3 days - 1 hours);
      SOPv1.setPetCdTrain(id, timeToSetCareCooldowns);

      emit SentToDaycare(msg.sender, id, daysToPayFor);
    }

    function retrieveFromDaycare(uint16 id) external {

      ( ,  ,  ,  , uint cdDaycare) = SOPv1.getPetCooldowns(id);
      ( , bool active) = SOPv1.getPetInfo(id);
      uint64 blockTimestamp = uint64(block.timestamp);
      require(SOPv1.ownerOf(id) == msg.sender, "Only the owner of the pet send it to daycare!");
      require(active, "Pet needs to be active to retrieve it from daycare.");
      require(cdDaycare > blockTimestamp, "Cannot perform action if pet is not in daycare.");

      resetPetCooldowns(id);
      SOPv1.setPetCdDaycare(id, 0);
      SOPv1.setPetCdPlay(id, blockTimestamp);
    }

    function namePet(uint16 id, string memory newName) external {

      ( , bool active) = SOPv1.getPetInfo(id);
      require(SOPv1.ownerOf(id) == msg.sender, "Only the owner of the pet can name it!");
      require(active, "Pet needs to be active to name it.");
      require(keccak256(abi.encodePacked(newName)) != keccak256(abi.encodePacked(SOPv1.petName(id))), "Pet already has this name.");

      if (keccak256(abi.encodePacked(SOPv1.petName(id))) == keccak256(abi.encodePacked(""))) {
        SOPv1.setPetName(id, newName);
      } else {
        uint paymentAmount = 100 * 10 ** 18;
        CareToken.burn(msg.sender, paymentAmount);

        SOPv1.setPetName(id, newName);
      }
    }

    function levelUpWithCare(uint16 id, uint levelsToGoUp) external notAtDaycare(id) {

      (uint8 level, bool active) = SOPv1.getPetInfo(id);
      require(SOPv1.ownerOf(id) == msg.sender, "Only the owner of the pet can level it up!");
      require(active, "Pet needs to be active to level up.");
      require(level < 30, "Pet is already at max level.");
      require(level + uint8(levelsToGoUp) <= 30, "This would make your pet exceed level 30 and waste tokens.");

      uint paymentAmount = levelsToGoUp * 100 * 10 ** 18;
      CareToken.burn(msg.sender, paymentAmount);

      for (uint i = 0; i < levelsToGoUp; i++) {
        levelUp(id);
      }
    }

    function setCareToken(address careTokenAddress) external onlyOwner {

      CareToken = ICareToken(careTokenAddress);
    }

    function setSOPV1Contract(address sopv1Address) external onlyOwner {

      SOPv1 = ISpiritOrbPetsv1(sopv1Address);
    }

}