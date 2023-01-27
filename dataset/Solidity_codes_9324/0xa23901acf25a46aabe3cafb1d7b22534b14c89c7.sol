
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

pragma solidity ^0.8.9;


library ClayLibrary {

  uint256 public constant SEED = 144261992486;

  function getBaseMultiplier(uint index) internal pure returns (uint256) {

    uint8[4] memory baseTiers = [
      10,
      20,
      30,
      40
    ];

    return uint256(baseTiers[index]);
  }

  function getOreMultiplier(uint index) internal pure returns (uint256) {

    uint16[9] memory oreTiers = [
      1000,
      2500,
      3000,
      3500,
      4000,
      1500,
      2000,
      6000,
      10000
    ];

    return uint256(oreTiers[index]);
  }

  function getUpgradeCost(uint index) internal pure returns (uint256) {

    uint16[4] memory baseTiers = [
      50,
      100,
      250,
      400
    ];

    return uint256(baseTiers[index] * 2);
  }

  function toString(uint256 value) internal pure returns (string memory) {

      if (value == 0) {
          return "0";
      }
      uint256 temp = value;
      uint256 digits;
      while (temp != 0) {
          digits++;
          temp /= 10;
      }
      bytes memory buffer = new bytes(digits);
      while (value != 0) {
          digits -= 1;
          buffer[digits] = bytes1(uint8(48 + uint256(value % 10)));
          value /= 10;
      }
      return string(buffer);
  }

  function parseInt(string memory _a)
      internal
      pure
      returns (uint8 _parsedInt)
  {

      bytes memory bresult = bytes(_a);
      uint8 mint = 0;
      for (uint8 i = 0; i < bresult.length; i++) {
          if (
              (uint8(uint8(bresult[i])) >= 48) &&
              (uint8(uint8(bresult[i])) <= 57)
          ) {
              mint *= 10;
              mint += uint8(bresult[i]) - 48;
          }
      }
      return mint;
  }

  function substring(
      string memory str,
      uint256 startIndex,
      uint256 endIndex
  ) internal pure returns (string memory) {

      bytes memory strBytes = bytes(str);
      bytes memory result = new bytes(endIndex - startIndex);
      for (uint256 i = startIndex; i < endIndex; i++) {
          result[i - startIndex] = strBytes[i];
      }
      return string(result);
  }

  function stringLength(
      string memory str
  ) internal pure returns (uint256) {

      bytes memory strBytes = bytes(str);
      return strBytes.length;
  }

  function isNotEmpty(string memory str) internal pure returns (bool) {

      return bytes(str).length > 0;
  }
}// MIT

pragma solidity ^0.8.9;


library ClayGen {  

  struct Trait {
    string traitType;
    string traitName;
  }

  uint8 public constant BASE_INDEX = 0;
  uint8 public constant ORE_INDEX = 1;
  uint8 public constant EYES_INDEX = 2;
  uint8 public constant MOUTH_INDEX = 3;
  uint8 public constant BG_COLOR_INDEX = 4;
  uint8 public constant LARGE_ORE_INDEX = 5;

  function getTiers() internal pure returns (uint16[][6] memory) {

    uint16[][6] memory TIERS = [
      new uint16[](4),
      new uint16[](9),
      new uint16[](2),
      new uint16[](2),
      new uint16[](6),
      new uint16[](2)      
    ];

    TIERS[0][0] = 4000;
    TIERS[0][1] = 3000;
    TIERS[0][2] = 2000;
    TIERS[0][3] = 1000;

    TIERS[1][0] = 5000;
    TIERS[1][1] = 1500;
    TIERS[1][2] = 1500;
    TIERS[1][3] = 750;
    TIERS[1][4] = 750;
    TIERS[1][5] = 200;
    TIERS[1][6] = 200;
    TIERS[1][7] = 90;
    TIERS[1][8] = 10;
    
    TIERS[2][0] = 8000; 
    TIERS[2][1] = 2000;

    TIERS[3][0] = 9000;
    TIERS[3][1] = 1000;

    TIERS[4][0] = 2000;
    TIERS[4][1] = 2000;
    TIERS[4][2] = 1500;
    TIERS[4][3] = 1500;
    TIERS[4][4] = 1500;
    TIERS[4][5] = 1500;

    TIERS[5][0] = 7500;
    TIERS[5][1] = 2500;

    return TIERS;
  }

  function getTraitTypes() internal pure returns (Trait[][6] memory) {

    Trait[][6] memory TIERS = [
      new Trait[](4),
      new Trait[](9),
      new Trait[](2),
      new Trait[](2),
      new Trait[](6),
      new Trait[](2)      
    ];

    TIERS[0][0] = Trait('Base', 'Clay');
    TIERS[0][1] = Trait('Base', 'Stone');
    TIERS[0][2] = Trait('Base', 'Metal');
    TIERS[0][3] = Trait('Base', 'Obsidian');

    TIERS[1][0] = Trait('Ore', 'None');
    TIERS[1][1] = Trait('Ore', 'Grass');
    TIERS[1][2] = Trait('Ore', 'Bronze');
    TIERS[1][3] = Trait('Ore', 'Jade');
    TIERS[1][4] = Trait('Ore', 'Gold');
    TIERS[1][5] = Trait('Ore', 'Ruby');
    TIERS[1][6] = Trait('Ore', 'Sapphire');
    TIERS[1][7] = Trait('Ore', 'Amethyst');
    TIERS[1][8] = Trait('Ore', 'Diamond');
    
    TIERS[2][0] = Trait('HasEyes', 'No'); 
    TIERS[2][1] = Trait('HasEyes', 'Yes');

    TIERS[3][0] = Trait('HasMouth', 'No');
    TIERS[3][1] = Trait('HasMouth', 'Yes');

    TIERS[4][0] = Trait('BgColor', 'Forest');
    TIERS[4][1] = Trait('BgColor', 'Mountain');
    TIERS[4][2] = Trait('BgColor', 'River');
    TIERS[4][3] = Trait('BgColor', 'Field');
    TIERS[4][4] = Trait('BgColor', 'Cave');
    TIERS[4][5] = Trait('BgColor', 'Clouds');

    TIERS[5][0] = Trait('LargeOre', 'No');
    TIERS[5][1] = Trait('LargeOre', 'Yes');

    return TIERS;
  }

    function generateMetadataHash(uint256 _t, uint256 _c)
        internal
        pure
        returns (string memory)
    {

        string memory currentHash = "";
        for (uint8 i = 0; i < 6; i++) {
            uint16 _randinput = uint16(
                uint256(keccak256(abi.encodePacked(_t, _c))) % 10000
            );

            currentHash = string(
                abi.encodePacked(currentHash, rarityGen(_randinput, i))
            );
        }

        return currentHash;
    }

    function rarityGen(uint256 _randinput, uint8 _rarityTier)
        internal
        pure
        returns (string memory)
    {

      uint16[][6] memory TIERS = getTiers();
      uint16 currentLowerBound = 0;
      for (uint8 i = 0; i < TIERS[_rarityTier].length; i++) {
          uint16 thisPercentage = TIERS[_rarityTier][i];
          if (
              _randinput >= currentLowerBound &&
              _randinput < currentLowerBound + thisPercentage
          ) return ClayLibrary.toString(i);
          currentLowerBound = currentLowerBound + thisPercentage;
      }

      revert();
    }
    

  function getTraitIndex(string memory _hash, uint index) internal pure returns (uint8) {

    return ClayLibrary.parseInt(ClayLibrary.substring(_hash, index, index + 1));
  }

  function getTraits(uint256 _t) internal pure returns (uint8[6] memory) {

    string memory _hash = generateMetadataHash(_t, ClayLibrary.SEED);
    uint8 baseIndex = getTraitIndex(_hash, 0);
    uint8 oreIndex = getTraitIndex(_hash, 1);
    uint8 hasEyesIndex = getTraitIndex(_hash, 2);
    uint8 hasMouthIndex = getTraitIndex(_hash, 3);
    uint8 bgColorIndex = getTraitIndex(_hash, 4);
    uint8 largeOreIndex = getTraitIndex(_hash, 5);
    uint8[6] memory traits = [baseIndex, oreIndex, hasEyesIndex, hasMouthIndex, bgColorIndex, largeOreIndex];
    return traits;
  }

  function getOreTrait(uint256 _t) internal pure returns (uint8) {

    string memory _hash = generateMetadataHash(_t, ClayLibrary.SEED);
    return getTraitIndex(_hash, 1);
  }

  function renderAttributesFromTraits(uint8[6] memory traits, uint256 _t) internal pure returns (string memory) {

    Trait[][6] memory traitTypes = getTraitTypes();
    string memory metadataString = string(abi.encodePacked('{"trait_type":"Base","value":"', traitTypes[0][traits[0]].traitName,'"},'));
    metadataString = string(abi.encodePacked(metadataString, '{"trait_type":"Ore","value":"', traitTypes[1][traits[1]].traitName,'"},'));
    metadataString = string(abi.encodePacked(metadataString, '{"trait_type":"HasEyes","value":"', traitTypes[2][traits[2]].traitName,'"},'));
    metadataString = string(abi.encodePacked(metadataString, '{"trait_type":"HasMouth","value":"', traitTypes[3][traits[3]].traitName,'"},'));
    metadataString = string(abi.encodePacked(metadataString, '{"trait_type":"BgColor","value":"', traitTypes[4][traits[4]].traitName,'"},'));
    metadataString = string(abi.encodePacked(metadataString, '{"trait_type":"LargeOre","value":"', traitTypes[5][traits[5]].traitName,'"},'));

    uint256 seed = uint256(keccak256(abi.encodePacked(_t, ClayLibrary.SEED))) % 100000;
    metadataString = string(abi.encodePacked(metadataString, '{"trait_type":"Seed","value":"', ClayLibrary.toString(seed), '"}'));

    return metadataString;
  }
}// MIT

pragma solidity ^0.8.9;


interface IClayStorage {  

  function setStorage(uint256 id, uint128 key, uint256 value) external;

  function getStorage(uint256 id, uint128 key) external view returns (uint256);

}

interface IMudToken {  

  function mint(address to, uint256 amount) external;

  function burn(address from, uint256 amount) external;

}

interface IClayTraitModifier {

  function renderAttributes(uint256 _t) external view returns (string memory);

}

contract ClayWarsV1001 is Ownable, ReentrancyGuard, IClayTraitModifier  {

  IClayStorage internal storageContract;
  IERC721 internal nftContract;
  IMudToken internal tokenContract;

  string internal overrideImageUrl;

  uint256 internal immutable startCountTime = 1651553997;
  uint128 internal constant STG_LAST_MUD_WITHDRAWAL = 1;
  uint128 internal constant STG_ORE = 2;
  uint128 internal constant STG_EYES = 3;
  uint128 internal constant STG_MOUTH = 4;
  uint128 internal constant STG_LARGE_ORE = 5;
  uint128 internal constant STG_UPGRADE_CD = 6;
  uint128 internal constant STG_GEM_ULTIMATE_CD = 7;
  uint128 internal constant STG_MANIFEST_CD = 8;
  uint128 internal constant STG_NATURE_ULTIMATE_CD = 10;
  uint128 internal constant STG_SAP_CD = 11;
  uint128 internal constant STG_SELF_DESTRUCT_CD = 12;

  uint256 internal constant TRAIT_DEFAULT = 0;
  uint256 internal constant TRAIT_NO = 1;
  uint256 internal constant TRAIT_YES = 2;

  uint256 internal constant COST_EYES = 200 ether;
  uint256 internal constant COST_MOUTH = 25 ether;
  uint256 internal constant COST_LARGE_ORE = 1000 ether;

  bool internal withdrawEnabled = false;

  constructor() {
  }

  function setStorageContract(address _storageContract) public onlyOwner {

    storageContract = IClayStorage(_storageContract);
  }

  function setNFTContract(address _nftContract) public onlyOwner {

    nftContract = IERC721(_nftContract);
  }

  function setTokenContract(address _tokenContract) public onlyOwner {

    tokenContract = IMudToken(_tokenContract);
  }

  function setWithdrawEnabled(bool _withdrawEnabled) public onlyOwner {

    withdrawEnabled = _withdrawEnabled;
  }

  function getTraits(uint256 _t) internal view returns (uint8[6] memory) {

    uint8[6] memory traits = ClayGen.getTraits(_t);

    {
      uint8 ore = uint8(storageContract.getStorage(_t, STG_ORE));
      traits[ClayGen.ORE_INDEX] = ore == TRAIT_DEFAULT ? traits[ClayGen.ORE_INDEX] : ore - 1;
    }

    {
      uint8 hasEyes = uint8(storageContract.getStorage(_t, STG_EYES));
      traits[ClayGen.EYES_INDEX] = hasEyes == TRAIT_DEFAULT ? traits[ClayGen.EYES_INDEX] : hasEyes - 1;
    }

    {
      uint8 hasMouth = uint8(storageContract.getStorage(_t, STG_MOUTH));
      traits[ClayGen.MOUTH_INDEX] = hasMouth == TRAIT_DEFAULT ? traits[ClayGen.MOUTH_INDEX] : hasMouth - 1;
    }

    {
      uint8 largeOre = uint8(storageContract.getStorage(_t, STG_LARGE_ORE));
      traits[ClayGen.LARGE_ORE_INDEX] = largeOre == TRAIT_DEFAULT ? traits[ClayGen.LARGE_ORE_INDEX] : largeOre - 1;
    }

    return traits;
  }

  function getWithdrawAmountWithTimestamp(uint256 lastMudWithdrawal, uint8[6] memory traits) internal view returns (uint256) {

    uint256 largeOre = traits[ClayGen.LARGE_ORE_INDEX] == 1 ? 2 : 1;

    uint256 withdrawAmount = (ClayLibrary.getBaseMultiplier(traits[ClayGen.BASE_INDEX]) * 
      ClayLibrary.getOreMultiplier(traits[ClayGen.ORE_INDEX]) * largeOre) / 1000 * 1 ether;

    uint256 stakeStartTime = lastMudWithdrawal;
    uint256 firstTimeBonus = 0;
    if(lastMudWithdrawal == 0) {
      stakeStartTime = startCountTime;
      firstTimeBonus = 100 * 1 ether;
    }

    uint256 stakingTime = block.timestamp - stakeStartTime;
    withdrawAmount *= stakingTime;
    withdrawAmount /= 1 days;
    withdrawAmount += firstTimeBonus;
    return withdrawAmount;
  }

  function getWithdrawAmount(uint256 _t) public view returns (uint256) {

    uint8[6] memory traits = getTraits(_t);
    uint256 lastMudWithdrawal = storageContract.getStorage(_t, STG_LAST_MUD_WITHDRAWAL);
    return getWithdrawAmountWithTimestamp(lastMudWithdrawal, traits);
  }

  function getWithdrawTotal(uint256[] calldata ids) public view returns (uint256) {

    uint256 accum = 0;
    for(uint256 i = 0;i < ids.length;i++) {
      accum += getWithdrawAmount(ids[i]);
    }

    return accum;
  }

  function getWithdrawTotalWithBonus(uint256[] calldata ids, uint256 bgColorIndex) public view returns (uint256) {

    uint256 accum = 0;
    uint256 totalBonus = 1000;
    for(uint256 i = 0;i < ids.length;i++) {
      uint256 _t = ids[i];
      uint8[6] memory traits = getTraits(_t);
      if(traits[ClayGen.ORE_INDEX] < 5 && traits[ClayGen.BG_COLOR_INDEX] == bgColorIndex) {
        totalBonus += 100;
      }
      uint256 lastMudWithdrawal = storageContract.getStorage(_t, STG_LAST_MUD_WITHDRAWAL);
      accum += getWithdrawAmountWithTimestamp(lastMudWithdrawal, traits);
    }

    return accum * (totalBonus - 100) / 1000;
  }

  function getSetCd(uint256 _t, uint128 storageIndex) internal returns (uint256) {

    uint256 lastCd = storageContract.getStorage(_t, storageIndex);
    storageContract.setStorage(_t, storageIndex, block.timestamp);
    return lastCd;
  }

  function withdrawToWithPenalty(uint256 _t, uint256 penalty) internal {

    uint256 lastMudWithdrawal = getSetCd(_t, STG_LAST_MUD_WITHDRAWAL);
    uint8[6] memory traits = getTraits(_t);
    uint256 withdrawAmount = getWithdrawAmountWithTimestamp(lastMudWithdrawal, traits);
    tokenContract.mint(nftContract.ownerOf(_t), withdrawAmount - penalty);
  }

  function withdraw(uint256 _t) public nonReentrant {

    require(nftContract.ownerOf(_t) == msg.sender, "Not owner");
    require(withdrawEnabled, "Disabled");
    withdrawToWithPenalty(_t, 0);
  }

  function withdrawAll(uint256[] calldata ids) public {

    require(withdrawEnabled, "Disabled");
    uint256 totalWithdrawAmount = 0;

    for(uint256 i = 0;i < ids.length;i++) {
      uint256 _t = ids[i];
      require(nftContract.ownerOf(_t) == msg.sender, "Not owner");
      uint256 lastMudWithdrawal = getSetCd(_t, STG_LAST_MUD_WITHDRAWAL);
      uint8[6] memory traits = getTraits(_t);
      totalWithdrawAmount += getWithdrawAmountWithTimestamp(lastMudWithdrawal, traits);
    }
    
    tokenContract.mint(msg.sender, totalWithdrawAmount);
  }

  function withdrawAllWithBonus(uint256[] calldata ids, uint256 bgColorIndex) public {

    require(withdrawEnabled, "Disabled");
    uint256 totalWithdrawAmount = 0;
    uint256 totalBonus = 1000;

    for(uint256 i = 0;i < ids.length;i++) {
      uint256 _t = ids[i];
      require(nftContract.ownerOf(_t) == msg.sender, "Not owner");
      uint256 lastMudWithdrawal = getSetCd(_t, STG_LAST_MUD_WITHDRAWAL);
      uint8[6] memory traits = getTraits(_t);
      if(traits[ClayGen.ORE_INDEX] < 5 && traits[ClayGen.BG_COLOR_INDEX] == bgColorIndex) {
        totalBonus += 100;
      }
      totalWithdrawAmount += getWithdrawAmountWithTimestamp(lastMudWithdrawal, traits);
    }
    
    tokenContract.mint(msg.sender, totalWithdrawAmount * (totalBonus - 100) / 1000);
  }

  function renderAttributes(uint256 _t) external view returns (string memory) {

    uint8[6] memory traits = getTraits(_t);
    string memory metadataString = ClayGen.renderAttributesFromTraits(traits, _t);
    uint256 mud = getWithdrawAmount(_t);
    metadataString = string(
      abi.encodePacked(
        metadataString,
        ',{"trait_type":"Mud","value":',
        ClayLibrary.toString(mud / 1 ether),
        '}'
      )
    );

    metadataString = string(abi.encodePacked("[", metadataString, "]"));

    if(ClayLibrary.isNotEmpty(overrideImageUrl)) {
      metadataString = string(abi.encodePacked(metadataString,
        ',"image":"', overrideImageUrl, ClayLibrary.toString(_t),'"'));
    }

    return metadataString;    
  }

  function setOverrideImageUrl(string calldata _overrideImageUrl) public onlyOwner {

    overrideImageUrl = _overrideImageUrl;
  }

  function checkCoolDown(uint256 _t, uint256 cooldownTime, uint128 storageIndex, uint8[6] memory traits) internal {

    uint256 upgradeCd = storageContract.getStorage(_t, storageIndex);
    if(upgradeCd >= block.timestamp - cooldownTime) {
      uint8 hasEyes = uint8(storageContract.getStorage(_t, STG_EYES));
      hasEyes = hasEyes == TRAIT_DEFAULT ? traits[ClayGen.EYES_INDEX] : hasEyes - 1;
      if(hasEyes > 0) {        
        storageContract.setStorage(_t, STG_EYES, TRAIT_NO);
      } else {
        require(upgradeCd < block.timestamp - cooldownTime, "Cooldown");
      }
    }

    storageContract.setStorage(_t, storageIndex, block.timestamp);
  }

  
  function upgradeOre(uint256 _t) public nonReentrant {

    require(nftContract.ownerOf(_t) == msg.sender, "Not owner");
    uint256 ore = storageContract.getStorage(_t, STG_ORE);
    uint8[6] memory traits = getTraits(_t);
    uint256 oreLevel = ore == TRAIT_DEFAULT ? traits[ClayGen.ORE_INDEX] : ore - 1;
    require(oreLevel != 4 && oreLevel != 8, "oreLevel > 3");
    require(oreLevel > 0, "oreLevel == 0");
    
    checkCoolDown(_t, 1 days, STG_UPGRADE_CD, traits);

    uint256 upgradeCost = ClayLibrary.getUpgradeCost(traits[ClayGen.BASE_INDEX]) * (((oreLevel - 1) % 4) + 2) * 1 ether;

    tokenContract.burn(msg.sender, upgradeCost);
    storageContract.setStorage(_t, STG_ORE, oreLevel + 2);
  }

  function chooseOre(uint256 _t, bool pathChoice) public nonReentrant {

    require(nftContract.ownerOf(_t) == msg.sender, "Not owner");
    uint256 ore = storageContract.getStorage(_t, STG_ORE);
    uint8[6] memory traits = getTraits(_t);
    uint256 oreLevel = ore == TRAIT_DEFAULT ? traits[ClayGen.ORE_INDEX] : ore - 1;
    require(oreLevel == 0, "oreLevel > 0");
    
    uint256 upgradeCost = ClayLibrary.getUpgradeCost(traits[ClayGen.BASE_INDEX]) * 1 ether;
    if(pathChoice) {
      upgradeCost *= 3;
    }
    
    checkCoolDown(_t, 1 days, STG_UPGRADE_CD, traits);

    uint256 newOreLevel = pathChoice ? 5 : 1;
    tokenContract.burn(msg.sender, upgradeCost);
    storageContract.setStorage(_t, STG_ORE, newOreLevel + 1);
  }

  function purchaseBinary(uint256 _t, uint128 storageIndex, uint256 traitIndex, uint256 cost) internal {

    require(nftContract.ownerOf(_t) == msg.sender, "Not owner");
    uint256 eyes = storageContract.getStorage(_t, storageIndex);
    uint8[6] memory traits = getTraits(_t);
    require(eyes == TRAIT_NO || 
      (eyes == TRAIT_DEFAULT && traits[traitIndex] == 0), "Already have");
    
    tokenContract.burn(msg.sender, cost);
    storageContract.setStorage(_t, storageIndex, TRAIT_YES);
  }

  function purchaseEyes(uint256 _t) public nonReentrant {

    purchaseBinary(_t, STG_EYES, ClayGen.EYES_INDEX, COST_EYES);
  }

  function purchaseMouth(uint256 _t) public nonReentrant {

    purchaseBinary(_t, STG_MOUTH, ClayGen.MOUTH_INDEX, COST_MOUTH);
  } 

  function purchaseLargeOre(uint256 _t) public nonReentrant {

    purchaseBinary(_t, STG_LARGE_ORE, ClayGen.LARGE_ORE_INDEX, COST_LARGE_ORE);
  }  


  function gemUltimate(uint256 _t, uint256 target) public nonReentrant {

    require(nftContract.ownerOf(_t) == msg.sender, "Not owner");
    
    uint8[6] memory myTraits = getTraits(_t);
    uint8[6] memory targetTraits = getTraits(target);
    
    uint256 myOre = storageContract.getStorage(_t, STG_ORE);
    uint256 targetOre = storageContract.getStorage(target, STG_ORE);
    uint256 myOreLevel = myOre == TRAIT_DEFAULT ? myTraits[ClayGen.ORE_INDEX] : myOre - 1;
    uint256 targetOreLevel = targetOre == TRAIT_DEFAULT ? targetTraits[ClayGen.ORE_INDEX] : targetOre - 1;

    require(myOreLevel > 4, "Not gem");
    require(targetOreLevel != 0, "No ore");
    
    uint256 myOreLevelAdjusted = (myOreLevel - 1) % 4;
    uint256 targetOreLevelAdjusted = (targetOreLevel - 1) % 4;

    require(targetOreLevelAdjusted <= myOreLevelAdjusted, "Target > mine");
    require(targetOreLevelAdjusted != 0, "Target == 0");

    checkCoolDown(_t, 3 days, STG_GEM_ULTIMATE_CD, myTraits);

    uint256 mouth = storageContract.getStorage(target, STG_MOUTH);
    if(mouth == TRAIT_YES || (mouth == TRAIT_DEFAULT && targetTraits[ClayGen.MOUTH_INDEX] == 1)) {
      storageContract.setStorage(target, STG_MOUTH, TRAIT_NO);
      return;
    }

    withdrawToWithPenalty(target, 0);
    storageContract.setStorage(target, STG_ORE, targetOreLevel);
    tokenContract.mint(msg.sender, 5000 ether);
  }  

  function manifest(uint256 _t) public nonReentrant {

    require(nftContract.ownerOf(_t) == msg.sender, "Not owner");
    uint256 mouth = storageContract.getStorage(_t, STG_MOUTH);
    uint8[6] memory traits = getTraits(_t);
    require(mouth == TRAIT_NO || 
      (mouth == TRAIT_DEFAULT && traits[ClayGen.MOUTH_INDEX] == 0), "Already have");
        
    uint256 myOre = storageContract.getStorage(_t, STG_ORE);
    uint256 myOreLevel = myOre == TRAIT_DEFAULT ? traits[ClayGen.ORE_INDEX] : myOre - 1;
    require(myOreLevel > 4, "Not gem");

    checkCoolDown(_t, 7 days, STG_MANIFEST_CD, traits);

    storageContract.setStorage(_t, STG_MOUTH, TRAIT_YES);
  }  

  function coalesce(uint256 _t, uint256[] calldata ids) public nonReentrant {

    require(nftContract.ownerOf(_t) == msg.sender, "Not owner");
    
    uint8[6] memory myTraits = getTraits(_t);
    uint256 myOre = storageContract.getStorage(_t, STG_ORE);
    uint256 myOreLevel = myOre == TRAIT_DEFAULT ? myTraits[ClayGen.ORE_INDEX] : myOre - 1;
    require(myOreLevel > 4, "Not gem");

    uint256 totalWithdrawAmount = 0;
    for(uint256 i = 0;i < ids.length;i++) {
      uint256 tokenId = ids[i];
      require(nftContract.ownerOf(tokenId) == msg.sender, "Not owner");
      uint256 lastMudWithdrawal = storageContract.getStorage(tokenId, STG_LAST_MUD_WITHDRAWAL);
      storageContract.setStorage(tokenId, STG_LAST_MUD_WITHDRAWAL, block.timestamp);
      uint8[6] memory traits = getTraits(tokenId);
      totalWithdrawAmount += getWithdrawAmountWithTimestamp(lastMudWithdrawal, traits);
    }
    
    tokenContract.burn(msg.sender, 20 ether);
    tokenContract.mint(msg.sender, totalWithdrawAmount * 1100 / 1000);
  }

  function natureUltimate(uint256 _t, uint256 target) public nonReentrant {

    require(nftContract.ownerOf(_t) == msg.sender, "Not owner");
    
    uint8[6] memory myTraits = getTraits(_t);
    uint8[6] memory targetTraits = getTraits(target);
    
    uint256 myOre = storageContract.getStorage(_t, STG_ORE);
    uint256 targetOre = storageContract.getStorage(target, STG_ORE);
    uint256 myOreLevel = myOre == TRAIT_DEFAULT ? myTraits[ClayGen.ORE_INDEX] : myOre - 1;
    uint256 targetOreLevel = targetOre == TRAIT_DEFAULT ? targetTraits[ClayGen.ORE_INDEX] : targetOre - 1;

    require(myOreLevel > 0 && myOreLevel < 5, "Not nature");
    require(targetOreLevel != 0, "No ore");
    
    uint256 myOreLevelAdjusted = (myOreLevel - 1) % 4;
    uint256 targetOreLevelAdjusted = (targetOreLevel - 1) % 4;

    require(targetOreLevelAdjusted == myOreLevelAdjusted + 1, "Target != mine + 1");

    checkCoolDown(_t, 3 days, STG_NATURE_ULTIMATE_CD, myTraits);
    tokenContract.burn(msg.sender, 50 ether);
    
    uint256 mouth = storageContract.getStorage(target, STG_MOUTH);
    if(mouth == TRAIT_YES || (mouth == TRAIT_DEFAULT && targetTraits[ClayGen.MOUTH_INDEX] == 1)) {
      storageContract.setStorage(target, STG_MOUTH, TRAIT_NO);
      return;
    }

    withdrawToWithPenalty(target, 0);
    withdrawToWithPenalty(_t, 0);
    storageContract.setStorage(target, STG_ORE, myOreLevel + 1);
    storageContract.setStorage(_t, STG_ORE, targetOreLevel + 1);
  }  

  function sap(uint256 _t, uint256 target) public nonReentrant {

    require(nftContract.ownerOf(_t) == msg.sender, "Not owner");
    
    uint8[6] memory myTraits = getTraits(_t);    
    uint256 myOre = storageContract.getStorage(_t, STG_ORE);
    uint256 myOreLevel = myOre == TRAIT_DEFAULT ? myTraits[ClayGen.ORE_INDEX] : myOre - 1;
    require(myOreLevel > 0 && myOreLevel < 5, "Not nature");    

    checkCoolDown(_t, 1 days, STG_SAP_CD, myTraits);

    withdrawToWithPenalty(target, 2500 ether);
    tokenContract.mint(msg.sender, 2500 ether);
  }

  function selfDestruct(uint256 _t) public nonReentrant {

    require(nftContract.ownerOf(_t) == msg.sender, "Not owner");

    uint8[6] memory myTraits = getTraits(_t);    
    uint256 myOre = storageContract.getStorage(_t, STG_ORE);
    uint256 myOreLevel = myOre == TRAIT_DEFAULT ? myTraits[ClayGen.ORE_INDEX] : myOre - 1;
    require(myOreLevel > 0 && myOreLevel < 5, "Not nature");   

    checkCoolDown(_t, 1 days, STG_SELF_DESTRUCT_CD, myTraits);

    withdrawToWithPenalty(_t, 0);
    storageContract.setStorage(_t, STG_ORE, myOreLevel);
  
    uint256 upgradeCost = ClayLibrary.getUpgradeCost(myTraits[ClayGen.BASE_INDEX]) * (((myOreLevel - 1) % 4) + 1) * 1 ether;
    tokenContract.mint(msg.sender, upgradeCost * 750 / 1000);
  }
  
  function getByOre(uint8 oreIndex, uint256 startId, uint256 endId) external view returns (uint256[] memory) {

    uint256[] memory matchingOres = new uint256[](endId - startId);
    uint256 index = 0;

    for (uint256 _t = startId; _t < endId; _t++) {
      uint8 oreTrait = ClayGen.getOreTrait(_t);
      uint256 myOre = storageContract.getStorage(_t, STG_ORE);
      uint256 myOreLevel = myOre == TRAIT_DEFAULT ? oreTrait : myOre - 1;

      if(myOreLevel == oreIndex) {
        matchingOres[index] = _t;
        index++;
      }
    }

    uint256[] memory result = new uint256[](index);
    for (uint256 i = 0; i < index; i++) {
      result[i] = matchingOres[i];
    }
    return result;
  }
}