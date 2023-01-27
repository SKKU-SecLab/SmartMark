
pragma solidity ^0.8.0;

interface IERC165 {

    function supportsInterface(bytes4 interfaceId) external view returns (bool);

}// MIT

pragma solidity ^0.8.0;


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

}// MIT

pragma solidity ^0.8.0;


abstract contract ERC165 is IERC165 {
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IERC165).interfaceId;
    }
}// MIT

pragma solidity ^0.8.0;


abstract contract ERC1155Receiver is ERC165, IERC1155Receiver {
    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC165, IERC165) returns (bool) {
        return interfaceId == type(IERC1155Receiver).interfaceId || super.supportsInterface(interfaceId);
    }
}// MIT

pragma solidity ^0.8.0;


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
}// UNLICENSED

pragma solidity 0.8.6;

contract GaiminERC1155Ids {

  uint16 public constant MAX_TOTAL_UNKNOWN = 8888;
  uint16 public constant MAX_TOTAL_SILVER = 6000;
  uint16 public constant MAX_TOTAL_GOLD = 2800;
  uint16 public constant MAX_TOTAL_BLACKGOLD = 88;

  uint16 public constant UNKNOWN = 0;
  uint16 public constant SILVER = 1;
  uint16 public constant GOLD = 2;
  uint16 public constant BLACKGOLD = 3;
}// MIT

pragma solidity ^0.8.0;


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

}// UNLICENSED

pragma solidity 0.8.6;


interface IGaiminERC1155 is IERC1155 {

  function mint(address account, uint256 id, uint256 amount, bytes memory data) external;

  
  function mintBatch(address to, uint256[] memory ids, uint256[] memory amounts, bytes memory data) external;


  function burn(address account, uint256 id, uint256 value) external;



}// UNLICENSED

pragma solidity 0.8.6;




contract GaiminICO is Ownable, GaiminERC1155Ids, ReentrancyGuard, ERC1155Holder {


  IGaiminERC1155 public token;

  uint256 public salesEndPeriod;
  uint256 public rarityPrice;
  
  uint256 public totalUnknownRarityMinted = 0;
  bool public whitelistingEnabled = true;

  uint8 public constant MAX_NFTS_PER_ACCOUNT = 20;

  bytes32 whiteslitedAddressesMerkleRoot = 0x00;

  mapping (uint256 => uint256) public mintedRarity;

  event PurchaseRarity(
    address indexed user, 
    uint256 purchasedRarity,
    uint256 etherToRefund,
    uint256 etherUsed,
    uint256 etherSent,
    uint256 timestamp
  );  

  event DelegatePurchase(
    address[] indexed users, 
    uint256[] amounts,
    uint256 timestamp
  );  

  event AllocateRarity(
    address[] indexed receivers, 
    uint256[] amounts,
    uint256 timestamp
  );  

  event Withdraw(
    address indexed user, 
    uint256 amount,
    uint256 timestamp
  );  

  event UpdateMerkleRoot(
    bytes32 indexed newRoot, 
    uint256 timestamp
  );  

  event UpdateSalesEndPeriod(
    uint256 indexed newSalesEndPeriod, 
    uint256 timestamp
  );  

  constructor(address token_, uint256 salesEndPeriod_, uint256 rarityPrice_) {
    require(token_ != address(0), "Not a valid token address");
    require(rarityPrice_ > 0, "Rarity Price can not be equal to zero");
    require(salesEndPeriod_ > block.timestamp, "Distribution date is in the past");

    token = IGaiminERC1155(token_);
    salesEndPeriod = salesEndPeriod_;
    rarityPrice = rarityPrice_;
  }

  receive() external payable {
    revert();
  }

  function purchaseRarity(bytes32[] memory proof) external payable nonReentrant {

    require(block.timestamp <= salesEndPeriod, "Rarity sale period have ended");
    require(msg.value >= rarityPrice, "Price must be greather than or equal to the rarity price");

    require(token.balanceOf(msg.sender, UNKNOWN) != MAX_NFTS_PER_ACCOUNT, "Receiver have reached the allocated limit");

    if (whitelistingEnabled) {
      require(proof.length > 0, "Proof length can not be zero");
      bytes32 leaf = keccak256(abi.encodePacked(msg.sender));
      bool iswhitelisted = verifyProof(leaf, proof);
      require(iswhitelisted, "User not whitelisted");
    } 

    uint256 numOfRarityPerPrice = msg.value / rarityPrice;

    uint256 numOfEligibleRarityToPurchase = MAX_NFTS_PER_ACCOUNT - token.balanceOf(msg.sender, UNKNOWN);
    uint256 numOfRarityPurchased = numOfRarityPerPrice > numOfEligibleRarityToPurchase ? numOfEligibleRarityToPurchase : numOfRarityPerPrice;
        
    require((token.balanceOf(msg.sender, UNKNOWN) + numOfRarityPurchased) <= MAX_NFTS_PER_ACCOUNT, "Receiver total rarity plus the rarity you want to purchase exceed your limit");
    require((totalUnknownRarityMinted + numOfRarityPurchased) <= MAX_TOTAL_UNKNOWN, "The amount of rarity you want to purchase plus the total rarity minted exceed the total unknown rarity");

    uint256 totalEtherUsed = numOfRarityPurchased * rarityPrice;

    uint256 etherToRefund = _transferBalance(msg.value, payable(msg.sender), totalEtherUsed);

    totalUnknownRarityMinted += numOfRarityPurchased;

    token.mint(msg.sender, UNKNOWN, numOfRarityPurchased, "0x0");

    emit PurchaseRarity(msg.sender, UNKNOWN, etherToRefund, totalEtherUsed, msg.value, block.timestamp);
  }

  function _transferBalance(uint256 totalEtherSpent, address payable user, uint256 totalEtherUsed) internal returns(uint256) {

    uint256 balance = 0;
    if (totalEtherSpent > totalEtherUsed) {
      balance = totalEtherSpent - totalEtherUsed;
      (bool sent, ) = user.call{value: balance}("");
      require(sent, "Failed to send remaining Ether balance");
    } 
    return balance;
  }

  function delegatePurchase(address[] memory newUsers, uint256[] memory amounts) external onlyOwner nonReentrant{

    require(newUsers.length == amounts.length, "newUsers and amounts length mismatch");

    uint256 _totalUnknownRarityMinted = totalUnknownRarityMinted;

    for (uint256 i = 0; i < newUsers.length; i++) {

      address newUser = newUsers[i];
      uint256 amount = amounts[i];

      require(newUser != address(0), "Not a valid address");
      require(amount != 0, "Rarity mint amount can not be zero");
      require((_totalUnknownRarityMinted + amount) <= MAX_TOTAL_UNKNOWN, "Rarity to be minted will exceed maximum total UNKNOWN rarity");

      _totalUnknownRarityMinted += amount;
      token.mint(newUser, UNKNOWN, amount, "0x0");
 
    }
    totalUnknownRarityMinted = _totalUnknownRarityMinted;
    emit DelegatePurchase(newUsers, amounts, block.timestamp);

  }

  function allocateRarity(uint256[] memory amounts, address[] memory receivers) external onlyOwner nonReentrant {


    require(amounts.length == receivers.length, "amounts and receivers length mismatch");
    require(block.timestamp > salesEndPeriod, "Rarity can not be distributed now");

    uint256 randomNumber = uint256(blockhash(block.number - 1) ^ blockhash(block.number - 2) ^ blockhash(block.number - 3));

    for (uint256 i = 0; i < receivers.length; i++) {
      
      address receiver = receivers[i];
      uint256 amount = amounts[i];

      uint256[] memory purchasedRarity = new uint[](amount);
      uint256[] memory amountPerRarity = new uint[](amount);

      require(receiver != address(0), "Not a valid address");
      require(amount != 0, "Rarity mint amount can not be zero");

      for (uint256 j = 0; j < amount; j++) {

        unchecked {
          randomNumber += uint256(blockhash(block.number - 4));  
        }

        uint256 remainingSilver = (MAX_TOTAL_SILVER - mintedRarity[SILVER]);
        uint256 remainingGold = (MAX_TOTAL_GOLD - mintedRarity[GOLD]);
        uint256 remainingBlackgold = (MAX_TOTAL_BLACKGOLD - mintedRarity[BLACKGOLD]);

        uint256 remainingSupply = remainingSilver + remainingGold + remainingBlackgold;

        uint256 raritySlot = (randomNumber % remainingSupply);

        uint256 rarity;
        
        if (raritySlot < remainingSilver) {
          rarity = SILVER;
        } else if (raritySlot < (remainingSilver + remainingGold)) {
          rarity = GOLD;
        } else {
          rarity = BLACKGOLD;
        }

        purchasedRarity[j] = rarity;
        amountPerRarity[j] = 1; 
        mintedRarity[rarity]++;

      }

      token.burn(receiver, UNKNOWN, amount);

      token.mintBatch(receiver, purchasedRarity, amountPerRarity, "0x0");

    }

    emit AllocateRarity(receivers, amounts, block.timestamp);

  } 

  function verifyProof(bytes32 leaf, bytes32[] memory proof) public view returns (bool) {


    bytes32 computedHash = leaf;

    for (uint256 i = 0; i < proof.length; i++) {
      bytes32 proofElement = proof[i];

      if (computedHash <= proofElement) {
        computedHash = keccak256(abi.encodePacked(computedHash, proofElement));
      } else {
        computedHash = keccak256(abi.encodePacked(proofElement, computedHash));
      }
    }

    return computedHash == whiteslitedAddressesMerkleRoot;
  }

  function withdrawEther(address payable receiver) external onlyOwner nonReentrant {

    require(receiver != address(0), "Not a valid address");
    require(address(this).balance > 0, "Contract have zero balance");

    (bool sent, ) = receiver.call{value: address(this).balance}("");
    require(sent, "Failed to send ether");
    emit Withdraw(receiver, address(this).balance, block.timestamp);
  }

  function updateMerkleRoot(bytes32 newMerkleRoot) external onlyOwner {

    require(newMerkleRoot.length > 0, "New merkle tree is empty");
    whiteslitedAddressesMerkleRoot = newMerkleRoot;
    emit UpdateMerkleRoot(newMerkleRoot, block.timestamp);
  } 

  function updateSalesEndPeriod(uint256 newSalesEndPeriod) external onlyOwner{

    require(newSalesEndPeriod > block.timestamp, "New sale end period is in the past");
    salesEndPeriod = newSalesEndPeriod;
    emit UpdateSalesEndPeriod(newSalesEndPeriod, block.timestamp);
  } 

  function toggleWhitelist() external onlyOwner {

    whitelistingEnabled = !whitelistingEnabled;
  }

  function getBalance() external view returns (uint) {

    return address(this).balance;
  }

}