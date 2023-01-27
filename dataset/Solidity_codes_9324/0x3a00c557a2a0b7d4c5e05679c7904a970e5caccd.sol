



pragma solidity ^0.8.0;

interface IERC20 {

    function totalSupply() external view returns (uint256);


    function balanceOf(address account) external view returns (uint256);


    function transfer(address recipient, uint256 amount) external returns (bool);


    function allowance(address owner, address spender) external view returns (uint256);


    function approve(address spender, uint256 amount) external returns (bool);


    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);


    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}


interface IERC165 {

    function supportsInterface(bytes4 interfaceId) external view returns (bool);

}

interface IERC721Supply is IERC165 {

    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);

    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);

    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);

    function totalSupply() external view returns (uint256);

    
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

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor() {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
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

library MerkleProof {

    function verify(
        bytes32[] memory proof,
        bytes32 root,
        bytes32 leaf
    ) internal pure returns (bool) {

        bytes32 computedHash = leaf;

        for (uint256 i = 0; i < proof.length; i++) {
            bytes32 proofElement = proof[i];

            if (computedHash <= proofElement) {
                computedHash = keccak256(abi.encodePacked(computedHash, proofElement));
            } else {
                computedHash = keccak256(abi.encodePacked(proofElement, computedHash));
            }
        }

        return computedHash == root;
    }
}

interface Minter {

  function MAX_SUPPLY() external returns (uint256);

  function mintNFTs(address to, uint256[] memory tokenId) external;

  function owner() external returns (address);

}

contract KillerGFWaveLockSale is Ownable, ReentrancyGuard {

  uint256 constant BASE = 1e18;

  uint256 constant TEAM_INDEX = 0;
  uint256 constant UWULIST_INDEX = 1;
  uint256 constant WHITELIST_INDEX = 2;

  uint256 constant SLOT_COUNT = 256/32;
  uint256 constant MAX_WAVES = 6;
  uint256 constant PRESALE_SLOT_INDEX = 0;
  uint256 constant MINTED_SLOT_INDEX = 6;
  uint256 constant BALANCE_SLOT_INDEX = 7;
  
  bytes32 public teamRoot;
  bytes32 public uwuRoot;
  bytes32 public whitelistRoot;

  address public nft; 
  uint256 public amountForSale;
  uint256 public amountSold;
  uint256 public devSupply;
  uint256 public devMinted;

  uint64 public teamMinted;
  uint64 public uwuMinted;
  uint64 public whitelistMinted;

  uint256 public buyPrice = 0.08 ether;
  uint256 public uwuPrice = 0.065 ether;
  
  uint256 public startTime = type(uint256).max;
  uint256 public constant waveTimeLength = 5 minutes;

  mapping(address => uint256) purchases;

  event Reserved(address sender, uint256 count);
  event Minted(address sender, uint256 count);

  constructor(address _nft, address _owner, uint256 _startTime, uint256 saleCount, uint256 _ownerCount) Ownable() ReentrancyGuard() {
    require(_startTime != 0, "No start time");
    nft = _nft;
    startTime = _startTime;
    amountForSale = saleCount;
    devSupply = _ownerCount;
    transferOwnership(_owner);
  }

  function withdrawETH() external onlyOwner {

    uint256 fullAmount = address(this).balance;
    sendValue(payable(msg.sender), fullAmount*700/1000);
    sendValue(payable(0x354A70969F0b4a4C994403051A81C2ca45db3615), address(this).balance);
  }

  function setStartTime(uint256 _startTime) external onlyOwner {

    startTime = _startTime;
  }

  function setPresaleRoots(bytes32 _whitelistRoot, bytes32 _uwulistRoot, bytes32 _teamRoot) external onlyOwner {

    whitelistRoot = _whitelistRoot;
    uwuRoot = _uwulistRoot;
    teamRoot = _teamRoot;
  }

  function setNFT(address _nft) external onlyOwner {

    nft = _nft;
  }
  
  function devMint(uint256 count) public onlyOwner {

    devMintTo(msg.sender, count);
  }

  function devMintTo(address to, uint256 count) public onlyOwner {

    uint256 _devMinted = devMinted;
    uint256 remaining = devSupply - _devMinted;
    require(remaining != 0, "No more dev minted");
    if (count > remaining) {
      count = remaining;
    } 
    devMinted = _devMinted + count;

    uint256[] memory ids = new uint256[](count);
    for (uint256 i; i < count; ++i) {
      ids[i] = _devMinted+i+1;
    }
    Minter(nft).mintNFTs(to, ids);
  }
  
  function presaleBuy(uint256[3] calldata amountsToBuy, uint256[3] calldata amounts, uint256[3] calldata indexes, bytes32[][3] calldata merkleProof) external payable { 

    require(block.timestamp < startTime, "Presale has ended");
    require(amountsToBuy.length == 3, "Not right length");
    require(amountsToBuy.length == amounts.length, "Not equal amounts");
    require(amounts.length == indexes.length, "Not equal indexes");
    require(indexes.length == merkleProof.length, "Not equal proof");

    uint256 purchaseInfo = purchases[msg.sender];
    require(!hasDoneWave(purchaseInfo, PRESALE_SLOT_INDEX), "Already whitelist minted");

    uint256 expectedPayment;
    if (merkleProof[UWULIST_INDEX].length != 0) {
      expectedPayment += amountsToBuy[UWULIST_INDEX]*uwuPrice;
    }
    if (merkleProof[WHITELIST_INDEX].length != 0) {
      expectedPayment += amountsToBuy[WHITELIST_INDEX]*buyPrice;
    } 
    require(msg.value == expectedPayment, "Not right ETH sent");

    uint256 count;
    if (merkleProof[TEAM_INDEX].length != 0) {
      require(teamRoot.length != 0, "team root not assigned");
      bytes32 node = keccak256(abi.encodePacked(indexes[TEAM_INDEX], msg.sender, amounts[TEAM_INDEX]));
      require(MerkleProof.verify(merkleProof[TEAM_INDEX], teamRoot, node), 'MerkleProof: Invalid team proof.');
      require(amountsToBuy[TEAM_INDEX] <= amounts[TEAM_INDEX], "Cant buy this many");
      count += amountsToBuy[TEAM_INDEX];
      teamMinted += uint64(amountsToBuy[TEAM_INDEX]);
    }
    if (merkleProof[UWULIST_INDEX].length != 0) {
      require(uwuRoot.length != 0, "uwu root not assigned");
      bytes32 node = keccak256(abi.encodePacked(indexes[UWULIST_INDEX], msg.sender, amounts[UWULIST_INDEX]));
      require(MerkleProof.verify(merkleProof[UWULIST_INDEX], uwuRoot, node), 'MerkleProof: Invalid uwu proof.');
      require(amountsToBuy[UWULIST_INDEX] <= amounts[UWULIST_INDEX], "Cant buy this many");
      count += amountsToBuy[UWULIST_INDEX];
      uwuMinted += uint64(amountsToBuy[UWULIST_INDEX]);
    }
    if (merkleProof[WHITELIST_INDEX].length != 0) {
      require(whitelistRoot.length != 0, "wl root not assigned");
      bytes32 node = keccak256(abi.encodePacked(indexes[WHITELIST_INDEX], msg.sender, amounts[WHITELIST_INDEX]));
      require(MerkleProof.verify(merkleProof[WHITELIST_INDEX], whitelistRoot, node), 'MerkleProof: Invalid wl proof.');
      require(amountsToBuy[WHITELIST_INDEX] <= amounts[WHITELIST_INDEX], "Cant buy this many");
      count += amountsToBuy[WHITELIST_INDEX];
      whitelistMinted += uint64(amountsToBuy[WHITELIST_INDEX]);
    }  

    uint256 startSupply = currentMintIndex();
    uint256 _amountSold = amountSold;
    amountSold = _amountSold + count;
    purchases[msg.sender] = _createNewPurchaseInfo(purchaseInfo, PRESALE_SLOT_INDEX, startSupply, count);

    emit Reserved(msg.sender, count);
  }

  function buyKGF(uint256 count) external payable nonReentrant {

    uint256 _amountSold = amountSold;
    uint256 _amountForSale = amountForSale;
    uint256 remaining = _amountForSale - _amountSold;
    require(remaining != 0, "Sold out! Sorry!");

    require(block.timestamp >= startTime, "Sale has not started");
    require(tx.origin == msg.sender, "Only direct calls pls");
    require(count > 0, "Cannot mint 0");

    uint256 wave = currentWave();
    require(count <= maxPerTX(wave), "Max for TX in this wave");
    require(wave < MAX_WAVES, "Not in main sale");
    require(msg.value == count * buyPrice, "Not enough ETH");

    uint256 ethAmountOwed;
    if (count > remaining) {
      ethAmountOwed = buyPrice * (count - remaining);
      count = remaining;
    }

    uint256 purchaseInfo = purchases[msg.sender];
    require(!hasDoneWave(purchaseInfo, wave), "Already purchased this wave");

    uint256 startSupply = currentMintIndex();
    amountSold = _amountSold + count;
    purchases[msg.sender] = _createNewPurchaseInfo(purchaseInfo, wave, startSupply, count);
    
    emit Reserved(msg.sender, count);

    if (ethAmountOwed > 0) {
      sendValue(payable(msg.sender), ethAmountOwed);
    }
  }

  function buyKGFPostSale(uint256 count) external payable {

    uint256 _amountSold = amountSold;
    uint256 _amountForSale = amountForSale;
    uint256 remaining = _amountForSale - _amountSold;
    require(remaining != 0, "Sold out! Sorry!");
    require(block.timestamp >= startTime, "Sale has not started");

    require(count > 0, "Cannot mint 0");
    require(count <= remaining, "Just out");
    require(tx.origin == msg.sender, "Only direct calls pls");
    require(msg.value == count * buyPrice, "Not enough ETH");

    uint256 wave = currentWave();
    require(count <= maxPerTX(wave), "Max for TX in this wave");
    require(wave >= MAX_WAVES, "Not in post sale");

    uint256 startSupply = currentMintIndex();
    amountSold = _amountSold + count;
    uint256[] memory ids = new uint256[](count);
    for (uint256 i; i < count; ++i) {
      ids[i] = startSupply + i;
    }
    Minter(nft).mintNFTs(msg.sender, ids);
  }

  function mint(uint256 count) external nonReentrant {

    _mintFor(msg.sender, count, msg.sender);
  }

  function devMintFrom(address from, uint256 count) public onlyOwner {

    require(block.timestamp > startTime + 3 days, "Too soon");
    _mintFor(from, count, msg.sender);
  }

  function devMintsFrom(address[] calldata froms, uint256[] calldata counts) public onlyOwner {

    for (uint256 i; i < froms.length; ++i) {
      devMintFrom(froms[i], counts[i]);
    }
  }

  function _mintFor(address account, uint256 count, address to) internal {

    require(count > 0, "0?");
    require(block.timestamp >= startTime, "Can only mint after the sale has begun");

    uint256 purchaseInfo = purchases[account];
    uint256 _mintedBalance =_getSlot(purchaseInfo, MINTED_SLOT_INDEX);
    uint256[] memory ids = _allIdsPurchased(purchaseInfo);
    require(count <= ids.length-_mintedBalance, "Not enough balance");

    uint256 newMintedBalance = _mintedBalance + count;
    purchases[account] = _writeDataSlot(purchaseInfo, MINTED_SLOT_INDEX, newMintedBalance);

    uint256[] memory mintableIds = new uint256[](count);
    for (uint256 i; i < count; ++i) {
      mintableIds[i] = ids[_mintedBalance+i];
    }

    Minter(nft).mintNFTs(to, mintableIds);
    
    emit Minted(account, count);
  }

  function wavePurchaseInfo(uint256 wave, address who) external view returns (uint256, uint256) {

    uint256 cache = purchases[who];
    return _getInfo(cache, wave);
  }

  function currentMaxPerTX() external view returns (uint256) {

    return maxPerTX(currentWave());
  } 

  function allIdsPurchasedBy(address who) external view returns (uint256[] memory) {

    uint256 cache = purchases[who];
    return _allIdsPurchased(cache);
  } 
  
  function mintedBalance(address who) external view returns (uint256) {

    uint256 cache = purchases[who];
    uint256 _mintedBalance =_getSlot(cache, MINTED_SLOT_INDEX);
    return _mintedBalance;
  }

  function currentWave() public view returns (uint256) {

    if (block.timestamp < startTime) {
      return 0;
    }
    uint256 timeSinceStart = block.timestamp - startTime;
    uint256 _currentWave = timeSinceStart/waveTimeLength;
    return _currentWave;
  }

  function currentMintIndex() public view returns (uint256) {

    return amountSold + devSupply + 1;
  }

  function maxPerTX(uint256 _wave) public pure returns (uint256) {

    if (_wave == 0) {
      return 1;
    } else if (_wave == 1) {
      return 2;
    } else if (_wave == 2) {
      return 4;
    } else {
      return 8;
    }
  }

  function hasDoneWave(uint256 purchaseInfo, uint256 wave) public pure returns (bool) {

    uint256 slot = _getSlot(purchaseInfo, wave);
    return slot != 0;
  }

  function balanceOf(address who) public view returns (uint256) {

    uint256 cache = purchases[who];
    uint256 currentBalance = _getSlot(cache, BALANCE_SLOT_INDEX);
    uint256 _mintedBalance = _getSlot(cache, MINTED_SLOT_INDEX);
    return currentBalance-_mintedBalance;
  }

  function _createNewPurchaseInfo(uint256 purchaseInfo, uint256 wave, uint256 _startingSupply, uint256 count) internal pure returns (uint256) {

    require(wave < MAX_WAVES, "Not a wave index");
    uint256 purchase = _startingSupply<<8;
    purchase |= count;
    uint256 newWaveSlot = _writeWaveSlot(purchaseInfo, wave, purchase);
    uint256 newBalance = _getBalance(purchaseInfo) + count;
    return _writeDataSlot(newWaveSlot, BALANCE_SLOT_INDEX, newBalance);
  }

  function _allIdsPurchased(uint256 purchaseInfo) internal pure returns (uint256[] memory) {

    uint256 currentBalance = _getBalance(purchaseInfo);
    if (currentBalance == 0) {
      uint256[] memory empty;
      return empty;
    }

    uint256[] memory ids = new uint256[](currentBalance);

    uint256 index;
    for (uint256 wave; wave < MAX_WAVES; ++wave) {
      (uint256 supply, uint256 count) = _getInfo(purchaseInfo, wave);
      if (count == 0)
        continue;
      for (uint256 i; i < count; ++i) {
        ids[index] = supply + i;
        ++index;
      }
    }
    require(index == ids.length, "not all");

    return ids;
  }

  function _getInfo(uint256 purchaseInfo, uint256 wave) internal pure returns (uint256, uint256) {

    require(wave < MAX_WAVES, "Not a wave index");
    uint256 slot = _getSlot(purchaseInfo, wave);
    uint256 supply = slot>>8;
    uint256 count = uint256(uint8(slot));
    return (supply, count);
  } 

  function _getBalance(uint256 purchaseInfo) internal pure returns (uint256) {

    return _getSlot(purchaseInfo, BALANCE_SLOT_INDEX);
  }

  function _writeWaveSlot(uint256 purchase, uint256 index, uint256 data) internal pure returns (uint256) {

    require(index < MAX_WAVES, "not valid index");
    uint256 writeIndex = 256 - ((index+1) * 32);
    require(uint32(purchase<<writeIndex) == 0, "Cannot write in wave slot twice");
    uint256 newSlot = data<<writeIndex;
    uint256 newPurchase = purchase | newSlot;
    return newPurchase;
  }

  function _writeDataSlot(uint256 purchase, uint256 index, uint256 data) internal pure returns (uint256) {

    require(index == MINTED_SLOT_INDEX || index == BALANCE_SLOT_INDEX, "not valid index");
    uint256 writeIndex = 256 - ((index+1) * 32);
    uint256 newSlot = uint256(uint32(data))<<writeIndex;
    uint256 newPurchase = purchase>>(writeIndex+32)<<(writeIndex+32);
    if (index == MINTED_SLOT_INDEX) 
      newPurchase |= _getSlot(purchase, BALANCE_SLOT_INDEX);
    newPurchase |= newSlot;
    return newPurchase;
  }

  function _getSlot(uint256 purchase, uint256 index) internal pure returns (uint256) {

    require(index < SLOT_COUNT, "not valid index");
    uint256 writeIndex = 256 - ((index+1) * 32);
    uint256 slot = uint32(purchase>>writeIndex);
    return slot;
  }

  function sendValue(address payable recipient, uint256 amount) internal {

    require(address(this).balance >= amount, "Address: insufficient balance");

    (bool success, ) = recipient.call{ value: amount }("");
    require(success, "Address: unable to send value, recipient may have reverted");
  }
}