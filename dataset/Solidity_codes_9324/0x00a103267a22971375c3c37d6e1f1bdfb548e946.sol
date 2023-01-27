
pragma solidity ^0.8.7;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

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
}


interface IERC165 {

    function supportsInterface(bytes4 interfaceId) external view returns (bool);

}


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

}


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

}


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
}


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
}


interface IERC1155Receiver is IERC165 {

    function onERC1155Received(
        address operator,
        address from,
        uint256 id,
        uint256 value,
        bytes calldata data
    ) external returns (bytes4);


    function onERC1155BatchReceived(
        address operator,
        address from,
        uint256[] calldata ids,
        uint256[] calldata values,
        bytes calldata data
    ) external returns (bytes4);

}

abstract contract ERC165 is IERC165 {
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IERC165).interfaceId;
    }
}

abstract contract ERC1155Receiver is ERC165, IERC1155Receiver {
    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC165, IERC165) returns (bool) {
        return interfaceId == type(IERC1155Receiver).interfaceId || super.supportsInterface(interfaceId);
    }
}

contract ERC1155Holder is ERC1155Receiver {

    function onERC1155Received(
        address,
        address,
        uint256,
        uint256,
        bytes memory
    ) public virtual override returns (bytes4) {

        return this.onERC1155Received.selector;
    }

    function onERC1155BatchReceived(
        address,
        address,
        uint256[] memory,
        uint256[] memory,
        bytes memory
    ) public virtual override returns (bytes4) {

        return this.onERC1155BatchReceived.selector;
    }
}


contract MoonStaking is ERC1155Holder, Ownable, ReentrancyGuard {

    IERC721 public ApeNft;
    IERC721 public LootNft;
    IERC1155 public PetNft;
    IERC721 public TreasuryNft;
    IERC721 public BreedingNft;

    uint256 public constant SECONDS_IN_DAY = 86400;

    bool public stakingLaunched;
    bool public depositPaused;

    mapping(address => mapping(uint256 => uint256)) stakerPetAmounts;
    mapping(address => mapping(uint256 => uint256)) stakerApeLoot;

    struct Staker {
      uint256 currentYield;
      uint256 accumulatedAmount;
      uint256 lastCheckpoint;
      uint256[] stakedAPE;
      uint256[] stakedTREASURY;
      uint256[] stakedBREEDING;
      uint256[] stakedPET;
    }

    mapping(address => Staker) private _stakers;

    enum ContractTypes {
      APE,
      LOOT,
      PET,
      TREASURY,
      BREEDING
    }

    mapping(address => ContractTypes) private _contractTypes;

    mapping(address => uint256) public _baseRates;
    mapping(address => mapping(uint256 => uint256)) private _individualRates;
    mapping(address => mapping(uint256 => address)) private _ownerOfToken;
    mapping (address => bool) private _authorised;
    address[] public authorisedLog;

    event Stake721(address indexed staker,address contractAddress,uint256 tokensAmount);
    event StakeApesWithLoots(address indexed staker,uint256 apesAmount);
    event AddLootToStakedApes(address indexed staker,uint256 apesAmount);
    event RemoveLootFromStakedApes(address indexed staker,uint256 lootsAmount);
    event StakePets(address indexed staker,uint256 numberOfPetIds);
    event Unstake721(address indexed staker,address contractAddress,uint256 tokensAmount);
    event UnstakePets(address indexed staker,uint256 numberOfPetIds);
    event ForceWithdraw721(address indexed receiver, address indexed tokenAddress, uint256 indexed tokenId);
    

    constructor(address _ape) {
        ApeNft = IERC721(_ape);
        _contractTypes[_ape] = ContractTypes.APE;
        _baseRates[_ape] = 150 ether;
    }

    modifier authorised() {

      require(_authorised[_msgSender()], "The token contract is not authorised");
        _;
    }

    function stake721(address contractAddress, uint256[] memory tokenIds) public nonReentrant {

      require(!depositPaused, "Deposit paused");
      require(stakingLaunched, "Staking is not launched yet");
      require(contractAddress != address(0) && contractAddress == address(ApeNft) || contractAddress == address(TreasuryNft) || contractAddress == address(BreedingNft), "Unknown contract or staking is not yet enabled for this NFT");
      ContractTypes contractType = _contractTypes[contractAddress];

      Staker storage user = _stakers[_msgSender()];
      uint256 newYield = user.currentYield;

      for (uint256 i; i < tokenIds.length; i++) {
        require(IERC721(contractAddress).ownerOf(tokenIds[i]) == _msgSender(), "Not the owner of staking NFT");
        IERC721(contractAddress).safeTransferFrom(_msgSender(), address(this), tokenIds[i]);

        _ownerOfToken[contractAddress][tokenIds[i]] = _msgSender();

        newYield += getTokenYield(contractAddress, tokenIds[i]);

        if (contractType == ContractTypes.APE) { user.stakedAPE.push(tokenIds[i]); }
        if (contractType == ContractTypes.BREEDING) { user.stakedBREEDING.push(tokenIds[i]); }
        if (contractType == ContractTypes.TREASURY) { user.stakedTREASURY.push(tokenIds[i]); }
      }

      accumulate(_msgSender());
      user.currentYield = newYield;

      emit Stake721(_msgSender(), contractAddress, tokenIds.length);
    }

    function stake1155(uint256[] memory tokenIds, uint256[] memory amounts) public nonReentrant {

      require(!depositPaused, "Deposit paused");
      require(stakingLaunched, "Staking is not launched yet");
      require(address(PetNft) != address(0), "Moon Pets staking is not yet enabled");

      Staker storage user = _stakers[_msgSender()];
      uint256 newYield = user.currentYield;

      for (uint256 i; i < tokenIds.length; i++) {
        require(amounts[i] > 0, "Invalid amount");
        require(PetNft.balanceOf(_msgSender(), tokenIds[i]) >= amounts[i], "Not the owner of staking Pet or insufficiant balance of staking Pet");

        newYield += getPetTokenYield(tokenIds[i], amounts[i]);
        if (stakerPetAmounts[_msgSender()][tokenIds[i]] == 0){
            user.stakedPET.push(tokenIds[i]);
        }
        stakerPetAmounts[_msgSender()][tokenIds[i]] += amounts[i];
      }

      PetNft.safeBatchTransferFrom(_msgSender(), address(this), tokenIds, amounts, "");

      accumulate(_msgSender());
      user.currentYield = newYield;

      emit StakePets(_msgSender(), tokenIds.length);
    }

    function addLootToStakedApes(uint256[] memory apeIds, uint256[] memory lootIds) public nonReentrant {

      require(!depositPaused, "Deposit paused");
      require(stakingLaunched, "Staking is not launched yet");
      require(apeIds.length == lootIds.length, "Lists not same length");
      require(address(LootNft) != address(0), "Loot Bags staking is not yet enabled");

      Staker storage user = _stakers[_msgSender()];
      uint256 newYield = user.currentYield;

      for (uint256 i; i < apeIds.length; i++) {
        require(_ownerOfToken[address(ApeNft)][apeIds[i]] == _msgSender(), "Not the owner of staked Ape");
        require(stakerApeLoot[_msgSender()][apeIds[i]] == 0, "Selected staked Ape already has Loot staked together");
        require(lootIds[i] > 0, "Invalid Loot NFT");
        require(IERC721(address(LootNft)).ownerOf(lootIds[i]) == _msgSender(), "Not the owner of staking Loot");
        IERC721(address(LootNft)).safeTransferFrom(_msgSender(), address(this), lootIds[i]);

        _ownerOfToken[address(LootNft)][lootIds[i]] = _msgSender();

        newYield += getApeLootTokenYield(apeIds[i], lootIds[i]) - getTokenYield(address(ApeNft), apeIds[i]);

        stakerApeLoot[_msgSender()][apeIds[i]] = lootIds[i];
      }

      accumulate(_msgSender());
      user.currentYield = newYield;

      emit AddLootToStakedApes(_msgSender(), apeIds.length);
    }

    function removeLootFromStakedApes(uint256[] memory apeIds) public nonReentrant{

       Staker storage user = _stakers[_msgSender()];
       uint256 newYield = user.currentYield;

       for (uint256 i; i < apeIds.length; i++) {
        require(_ownerOfToken[address(ApeNft)][apeIds[i]] == _msgSender(), "Not the owner of staked Ape");
        uint256 ape_loot = stakerApeLoot[_msgSender()][apeIds[i]];
        require(ape_loot > 0, "Selected staked Ape does not have any Loot staked with");
        require(_ownerOfToken[address(LootNft)][ape_loot] == _msgSender(), "Not the owner of staked Ape");
        IERC721(address(LootNft)).safeTransferFrom(address(this), _msgSender(), ape_loot);

        _ownerOfToken[address(LootNft)][ape_loot] = address(0);

        newYield -= getApeLootTokenYield(apeIds[i], ape_loot);
        newYield += getTokenYield(address(ApeNft), apeIds[i]);

        stakerApeLoot[_msgSender()][apeIds[i]] = 0;
      }

      accumulate(_msgSender());
      user.currentYield = newYield;

      emit RemoveLootFromStakedApes(_msgSender(), apeIds.length);
    }

    function stakeApesWithLoots(uint256[] memory apeIds, uint256[] memory lootIds) public nonReentrant {

      require(!depositPaused, "Deposit paused");
      require(stakingLaunched, "Staking is not launched yet");
      require(apeIds.length == lootIds.length, "Lists not same length");
      require(address(LootNft) != address(0), "Loot Bags staking is not yet enabled");

      Staker storage user = _stakers[_msgSender()];
      uint256 newYield = user.currentYield;

      for (uint256 i; i < apeIds.length; i++) {
        require(IERC721(address(ApeNft)).ownerOf(apeIds[i]) == _msgSender(), "Not the owner of staking Ape");
        if (lootIds[i] > 0){
          require(IERC721(address(LootNft)).ownerOf(lootIds[i]) == _msgSender(), "Not the owner of staking Loot");
          IERC721(address(LootNft)).safeTransferFrom(_msgSender(), address(this), lootIds[i]);
          _ownerOfToken[address(LootNft)][lootIds[i]] = _msgSender();
          stakerApeLoot[_msgSender()][apeIds[i]] = lootIds[i];
        }
        
        IERC721(address(ApeNft)).safeTransferFrom(_msgSender(), address(this), apeIds[i]);
        _ownerOfToken[address(ApeNft)][apeIds[i]] = _msgSender();
        
        newYield += getApeLootTokenYield(apeIds[i], lootIds[i]);
        user.stakedAPE.push(apeIds[i]);
      }

      accumulate(_msgSender());
      user.currentYield = newYield;

      emit StakeApesWithLoots(_msgSender(), apeIds.length);
    }

    function unstake721(address contractAddress, uint256[] memory tokenIds) public nonReentrant {

      require(contractAddress != address(0) && contractAddress == address(ApeNft) || contractAddress == address(TreasuryNft) || contractAddress == address(BreedingNft), "Unknown contract or staking is not yet enabled for this NFT");
      ContractTypes contractType = _contractTypes[contractAddress];
      Staker storage user = _stakers[_msgSender()];
      uint256 newYield = user.currentYield;

      for (uint256 i; i < tokenIds.length; i++) {
        require(IERC721(contractAddress).ownerOf(tokenIds[i]) == address(this), "Not the owner");

        _ownerOfToken[contractAddress][tokenIds[i]] = address(0);

        if (user.currentYield != 0) {
            if (contractType == ContractTypes.APE){
                uint256 ape_loot = stakerApeLoot[_msgSender()][tokenIds[i]];
                uint256 tokenYield = getApeLootTokenYield(tokenIds[i], ape_loot);
                newYield -= tokenYield;
                if (ape_loot > 0){
                  IERC721(address(LootNft)).safeTransferFrom(address(this), _msgSender(), ape_loot);
                  _ownerOfToken[address(LootNft)][ape_loot] = address(0);
                }
                
            } else {
                uint256 tokenYield = getTokenYield(contractAddress, tokenIds[i]);
                newYield -= tokenYield;
            }
        }

        if (contractType == ContractTypes.APE) {
          user.stakedAPE = _prepareForDeletion(user.stakedAPE, tokenIds[i]);
          user.stakedAPE.pop();
          stakerApeLoot[_msgSender()][tokenIds[i]] = 0;
        }
        if (contractType == ContractTypes.TREASURY) {
          user.stakedTREASURY = _prepareForDeletion(user.stakedTREASURY, tokenIds[i]);
          user.stakedTREASURY.pop();
        }
        if (contractType == ContractTypes.BREEDING) {
          user.stakedBREEDING = _prepareForDeletion(user.stakedBREEDING, tokenIds[i]);
          user.stakedBREEDING.pop();
        }

        IERC721(contractAddress).safeTransferFrom(address(this), _msgSender(), tokenIds[i]);
      }

      if (user.stakedAPE.length == 0 && user.stakedTREASURY.length == 0 && user.stakedPET.length == 0 && user.stakedBREEDING.length == 0) {
        newYield = 0;
      }

      accumulate(_msgSender());
      user.currentYield = newYield;

      emit Unstake721(_msgSender(), contractAddress, tokenIds.length);
    }

    function unstake1155(uint256[] memory tokenIds) public nonReentrant {

      Staker storage user = _stakers[_msgSender()];
      uint256 newYield = user.currentYield;
      uint256[] memory transferAmounts = new uint256[](tokenIds.length);

      for (uint256 i; i < tokenIds.length; i++) {
        require(stakerPetAmounts[_msgSender()][tokenIds[i]] > 0, "Not the owner of staked Pet");
        transferAmounts[i] = stakerPetAmounts[_msgSender()][tokenIds[i]];

        newYield -= getPetTokenYield(tokenIds[i], transferAmounts[i]);

        user.stakedPET = _prepareForDeletion(user.stakedPET, tokenIds[i]);
        user.stakedPET.pop();
        stakerPetAmounts[_msgSender()][tokenIds[i]] = 0;
      }

      if (user.stakedAPE.length == 0 && user.stakedTREASURY.length == 0 && user.stakedPET.length == 0 && user.stakedBREEDING.length == 0) {
        newYield = 0;
      }
      PetNft.safeBatchTransferFrom(address(this), _msgSender(), tokenIds, transferAmounts, "");

      accumulate(_msgSender());
      user.currentYield = newYield;

      emit UnstakePets(_msgSender(), tokenIds.length);
    }

    function getTokenYield(address contractAddress, uint256 tokenId) public view returns (uint256) {

      uint256 tokenYield = _individualRates[contractAddress][tokenId];
      if (tokenYield == 0) { tokenYield = _baseRates[contractAddress]; }

      return tokenYield;
    }

    function getApeLootTokenYield(uint256 apeId, uint256 lootId) public view returns (uint256){

        uint256 apeYield = _individualRates[address(ApeNft)][apeId];
        if (apeYield == 0) { apeYield = _baseRates[address(ApeNft)]; }

        uint256 lootBoost = _individualRates[address(LootNft)][lootId];
        if (lootId == 0){
            lootBoost = 10;
        } else {
            if (lootBoost == 0) { lootBoost = _baseRates[address(LootNft)]; }
        }
        
        return apeYield * lootBoost / 10;
    }

    function getPetTokenYield(uint256 petId, uint256 amount) public view returns(uint256){

        uint256 petYield = _individualRates[address(PetNft)][petId];
        if (petYield == 0) { petYield = _baseRates[address(PetNft)]; }
        return petYield * amount;
    }

    function getStakerYield(address staker) public view returns (uint256) {

      return _stakers[staker].currentYield;
    }

    function getStakerNFT(address staker) public view returns (uint256[] memory, uint256[] memory, uint256[] memory, uint256[] memory, uint256[] memory) {

        uint256[] memory lootIds = new uint256[](_stakers[staker].stakedAPE.length);
        uint256[] memory petAmounts = new uint256[](8);
        for (uint256 i; i < _stakers[staker].stakedAPE.length; i++){
            lootIds[i] = stakerApeLoot[staker][_stakers[staker].stakedAPE[i]];
        }
        for (uint256 i; i < 8; i++){
            petAmounts[i] = stakerPetAmounts[staker][i];
        }
      return (_stakers[staker].stakedAPE, lootIds, _stakers[staker].stakedTREASURY, petAmounts, _stakers[staker].stakedBREEDING);
    }

    function _prepareForDeletion(uint256[] memory list, uint256 tokenId) internal pure returns (uint256[] memory) {

      uint256 tokenIndex = 0;
      uint256 lastTokenIndex = list.length - 1;
      uint256 length = list.length;

      for(uint256 i = 0; i < length; i++) {
        if (list[i] == tokenId) {
          tokenIndex = i + 1;
          break;
        }
      }
      require(tokenIndex != 0, "Not the owner or duplicate NFT in list");

      tokenIndex -= 1;

      if (tokenIndex != lastTokenIndex) {
        list[tokenIndex] = list[lastTokenIndex];
        list[lastTokenIndex] = tokenId;
      }

      return list;
    }

    function getCurrentReward(address staker) public view returns (uint256) {

      Staker memory user = _stakers[staker];
      if (user.lastCheckpoint == 0) { return 0; }
      return (block.timestamp - user.lastCheckpoint) * user.currentYield / SECONDS_IN_DAY;
    }

    function getAccumulatedAmount(address staker) external view returns (uint256) {

      return _stakers[staker].accumulatedAmount + getCurrentReward(staker);
    }

    function accumulate(address staker) internal {

      _stakers[staker].accumulatedAmount += getCurrentReward(staker);
      _stakers[staker].lastCheckpoint = block.timestamp;
    }

    function ownerOf(address contractAddress, uint256 tokenId) public view returns (address) {

      return _ownerOfToken[contractAddress][tokenId];
    }

    function balanceOf(address user) public view returns (uint256){

      return _stakers[user].stakedAPE.length;
    }

    function setTREASURYContract(address _treasury, uint256 _baseReward) public onlyOwner {

      TreasuryNft = IERC721(_treasury);
      _contractTypes[_treasury] = ContractTypes.TREASURY;
      _baseRates[_treasury] = _baseReward;
    }

    function setPETContract(address _pet, uint256 _baseReward) public onlyOwner {

      PetNft = IERC1155(_pet);
      _contractTypes[_pet] = ContractTypes.PET;
      _baseRates[_pet] = _baseReward;
    }

    function setLOOTContract(address _loot, uint256 _baseBoost) public onlyOwner {

      LootNft = IERC721(_loot);
      _contractTypes[_loot] = ContractTypes.LOOT;
      _baseRates[_loot] = _baseBoost;
    }

    function setBREEDING(address _breeding, uint256 _baseReward) public onlyOwner{

      BreedingNft = IERC721(_breeding);
      _contractTypes[_breeding] = ContractTypes.BREEDING;
      _baseRates[_breeding] = _baseReward;
    }

    function authorise(address toAuth) public onlyOwner {

      _authorised[toAuth] = true;
      authorisedLog.push(toAuth);
    }

    function unauthorise(address addressToUnAuth) public onlyOwner {

      _authorised[addressToUnAuth] = false;
    }

    function forceWithdraw721(address tokenAddress, uint256[] memory tokenIds) public onlyOwner {

      require(tokenIds.length <= 50, "50 is max per tx");
      pauseDeposit(true);
      for (uint256 i; i < tokenIds.length; i++) {
        address receiver = _ownerOfToken[tokenAddress][tokenIds[i]];
        if (receiver != address(0) && IERC721(tokenAddress).ownerOf(tokenIds[i]) == address(this)) {
          IERC721(tokenAddress).transferFrom(address(this), receiver, tokenIds[i]);
          emit ForceWithdraw721(receiver, tokenAddress, tokenIds[i]);
        }
      }
    }

    function pauseDeposit(bool _pause) public onlyOwner {

      depositPaused = _pause;
    }

    function launchStaking() public onlyOwner {

      require(!stakingLaunched, "Staking has been launched already");
      stakingLaunched = true;
    }

    function updateBaseYield(address _contract, uint256 _yield) public onlyOwner {

      _baseRates[_contract] = _yield;
    }

    function setIndividualRates(address contractAddress, uint256[] memory tokenIds, uint256[] memory rates) public onlyOwner{

        require(contractAddress != address(0) && contractAddress == address(ApeNft) || contractAddress == address(LootNft) || contractAddress == address(TreasuryNft) || contractAddress == address(PetNft), "Unknown contract");
        require(tokenIds.length == rates.length, "Lists not same length");
        for (uint256 i; i < tokenIds.length; i++){
            _individualRates[contractAddress][tokenIds[i]] = rates[i];
        }
    }

    function onERC721Received(address, address, uint256, bytes calldata) external pure returns(bytes4){

      return bytes4(keccak256("onERC721Received(address,address,uint256,bytes)"));
    }

    function withdrawETH() external onlyOwner {

      payable(owner()).transfer(address(this).balance);
    }
}