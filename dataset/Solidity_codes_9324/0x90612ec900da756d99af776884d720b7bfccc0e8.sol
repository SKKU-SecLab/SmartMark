



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
}





pragma solidity ^0.8.0;

library Counters {

    struct Counter {
        uint256 _value; // default: 0
    }

    function current(Counter storage counter) internal view returns (uint256) {

        return counter._value;
    }

    function increment(Counter storage counter) internal {

        unchecked {
            counter._value += 1;
        }
    }

    function decrement(Counter storage counter) internal {

        uint256 value = counter._value;
        require(value > 0, "Counter: decrement overflow");
        unchecked {
            counter._value = value - 1;
        }
    }

    function reset(Counter storage counter) internal {

        counter._value = 0;
    }
}





pragma solidity ^0.8.0;

library Strings {

    bytes16 private constant _HEX_SYMBOLS = "0123456789abcdef";

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

    function toHexString(uint256 value) internal pure returns (string memory) {

        if (value == 0) {
            return "0x00";
        }
        uint256 temp = value;
        uint256 length = 0;
        while (temp != 0) {
            length++;
            temp >>= 8;
        }
        return toHexString(value, length);
    }

    function toHexString(uint256 value, uint256 length) internal pure returns (string memory) {

        bytes memory buffer = new bytes(2 * length + 2);
        buffer[0] = "0";
        buffer[1] = "x";
        for (uint256 i = 2 * length + 1; i > 1; --i) {
            buffer[i] = _HEX_SYMBOLS[value & 0xf];
            value >>= 4;
        }
        require(value == 0, "Strings: hex length insufficient");
        return string(buffer);
    }
}





pragma solidity ^0.8.0;

library ECDSA {

    enum RecoverError {
        NoError,
        InvalidSignature,
        InvalidSignatureLength,
        InvalidSignatureS,
        InvalidSignatureV
    }

    function _throwError(RecoverError error) private pure {

        if (error == RecoverError.NoError) {
            return; // no error: do nothing
        } else if (error == RecoverError.InvalidSignature) {
            revert("ECDSA: invalid signature");
        } else if (error == RecoverError.InvalidSignatureLength) {
            revert("ECDSA: invalid signature length");
        } else if (error == RecoverError.InvalidSignatureS) {
            revert("ECDSA: invalid signature 's' value");
        } else if (error == RecoverError.InvalidSignatureV) {
            revert("ECDSA: invalid signature 'v' value");
        }
    }

    function tryRecover(bytes32 hash, bytes memory signature) internal pure returns (address, RecoverError) {

        if (signature.length == 65) {
            bytes32 r;
            bytes32 s;
            uint8 v;
            assembly {
                r := mload(add(signature, 0x20))
                s := mload(add(signature, 0x40))
                v := byte(0, mload(add(signature, 0x60)))
            }
            return tryRecover(hash, v, r, s);
        } else if (signature.length == 64) {
            bytes32 r;
            bytes32 vs;
            assembly {
                r := mload(add(signature, 0x20))
                vs := mload(add(signature, 0x40))
            }
            return tryRecover(hash, r, vs);
        } else {
            return (address(0), RecoverError.InvalidSignatureLength);
        }
    }

    function recover(bytes32 hash, bytes memory signature) internal pure returns (address) {

        (address recovered, RecoverError error) = tryRecover(hash, signature);
        _throwError(error);
        return recovered;
    }

    function tryRecover(
        bytes32 hash,
        bytes32 r,
        bytes32 vs
    ) internal pure returns (address, RecoverError) {

        bytes32 s = vs & bytes32(0x7fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff);
        uint8 v = uint8((uint256(vs) >> 255) + 27);
        return tryRecover(hash, v, r, s);
    }

    function recover(
        bytes32 hash,
        bytes32 r,
        bytes32 vs
    ) internal pure returns (address) {

        (address recovered, RecoverError error) = tryRecover(hash, r, vs);
        _throwError(error);
        return recovered;
    }

    function tryRecover(
        bytes32 hash,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) internal pure returns (address, RecoverError) {

        if (uint256(s) > 0x7FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF5D576E7357A4501DDFE92F46681B20A0) {
            return (address(0), RecoverError.InvalidSignatureS);
        }
        if (v != 27 && v != 28) {
            return (address(0), RecoverError.InvalidSignatureV);
        }

        address signer = ecrecover(hash, v, r, s);
        if (signer == address(0)) {
            return (address(0), RecoverError.InvalidSignature);
        }

        return (signer, RecoverError.NoError);
    }

    function recover(
        bytes32 hash,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) internal pure returns (address) {

        (address recovered, RecoverError error) = tryRecover(hash, v, r, s);
        _throwError(error);
        return recovered;
    }

    function toEthSignedMessageHash(bytes32 hash) internal pure returns (bytes32) {

        return keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", hash));
    }

    function toEthSignedMessageHash(bytes memory s) internal pure returns (bytes32) {

        return keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n", Strings.toString(s.length), s));
    }

    function toTypedDataHash(bytes32 domainSeparator, bytes32 structHash) internal pure returns (bytes32) {

        return keccak256(abi.encodePacked("\x19\x01", domainSeparator, structHash));
    }
}




pragma solidity ^0.8.0;

interface AggregatorV3Interface {

  function decimals() external view returns (uint8);


  function description() external view returns (string memory);


  function version() external view returns (uint256);


  function getRoundData(uint80 _roundId)
    external
    view
    returns (
      uint80 roundId,
      int256 answer,
      uint256 startedAt,
      uint256 updatedAt,
      uint80 answeredInRound
    );


  function latestRoundData()
    external
    view
    returns (
      uint80 roundId,
      int256 answer,
      uint256 startedAt,
      uint256 updatedAt,
      uint80 answeredInRound
    );

}




pragma solidity ^0.8.0;

interface IHabitatNFT {

  function mint(
    address account,
    uint256 id,
    uint256 amount,
    uint96 editionRoyalty,
    bytes memory data
  ) external;


  function safeTransferFrom(
    address from,
    address to,
    uint256 id,
    uint256 amount,
    bytes memory data
  ) external;

  
  function burn(
    address from,
    uint256 id,
    uint256 amount
    ) external;

}




pragma solidity ^0.8.0;



contract PrimaryMarketplace is ReentrancyGuard {

  using ECDSA for bytes32;
  using Counters for Counters.Counter;

  event AddItem(uint256 indexed _itemID);
  struct Edition {
    uint256 itemId;
    address nftContract;
    uint256 tokenId;
    uint256 totalAmount;
    uint256 availableAmount;
    uint256 price;
    uint256 royalty;
    address seller;
    bool isHighestBidAuction;
  }

  mapping(uint256 => Edition) private idToEdition;
  mapping(address => bool) private creatorsWhitelist;
  mapping(address => uint256) public creatorBalances;

  Counters.Counter private _itemIds;
  AggregatorV3Interface private priceFeed;
  address private owner;

  constructor(address priceAggregatorAddress) {
    owner = msg.sender;
    priceFeed = AggregatorV3Interface(priceAggregatorAddress);
  }

  function buyEdition(uint256 itemId, uint256 amount)
    external
    payable
    nonReentrant
    onlyAvailableEdition(itemId)
  {

    require(!idToEdition[itemId].isHighestBidAuction, "NOT_PERMITTED");
    uint256 pricePerItemInUSD = idToEdition[itemId].price;
    uint256 pricePerItem = pricePerItemInUSD * priceInWEI();
    uint256 price = pricePerItem * amount;
    require(msg.value >= price, "WRONG_PRICE");
    creatorBalances[idToEdition[itemId].seller] = msg.value;

    _safeTransfer(itemId, amount, msg.sender);
  }

  function payForBid(
    uint256 itemId,
    uint256 price,
    bytes memory signature
  ) external payable nonReentrant {

    require(idToEdition[itemId].isHighestBidAuction, "AUCTION_NOT_EXIST");
    address verifiedSigner = recoverSignerAddress(msg.sender, price, signature);
    require(verifiedSigner == owner, "NOT_AUTHORIZED");
    require(msg.value >= price * priceInWEI(), "WRONG_PRICE");
    creatorBalances[idToEdition[itemId].seller] = msg.value;
    _safeTransfer(itemId, 1, msg.sender);
  }

  function transferEdition(
    uint256 itemId,
    uint256 amount,
    address receiver
  ) external nonReentrant onlyOwner {

    _safeTransfer(itemId, amount, receiver);
  }

  function addEdition(
    address nftContract,
    uint256 tokenId,
    uint256 amount,
    uint256 price,
    uint96 royalty,
    address seller,
    bool isHighestBidAuction
  ) external nonReentrant onlyOwnerOrCreator {

    _itemIds.increment();
    uint256 itemId = _itemIds.current();

    uint256 amountToMint = amount;

    if (isHighestBidAuction) {
      amountToMint = 1;
    }

    idToEdition[itemId] = Edition(
      itemId,
      nftContract,
      tokenId,
      amountToMint,
      amountToMint,
      price,
      royalty,
      seller,
      isHighestBidAuction
    );

    emit AddItem(itemId);

    IHabitatNFT(nftContract).mint(seller, tokenId, amountToMint, royalty, "");
  }

  function addCreator(address creator) external onlyOwner {

    creatorsWhitelist[creator] = true;
  }

  function burnToken(uint256 itemId) external onlyOwnerOrCreator {

    uint256 amount = idToEdition[itemId].availableAmount;
    idToEdition[itemId].availableAmount = 0;
    IHabitatNFT(idToEdition[itemId].nftContract).burn(
      idToEdition[itemId].seller,
      idToEdition[itemId].tokenId,
      amount
    );
  }

  function withdraw(address receiver) external onlyOwnerOrCreator nonReentrant {

    uint256 amount;

    if (owner == msg.sender) {
      amount = address(this).balance;
    } else {
      amount = creatorBalances[msg.sender];
      require(amount > 0, "OUT_OF_MONEY");
      creatorBalances[msg.sender] -= amount;
    }

    payable(receiver).transfer(amount);
  }

  function closeMarket(address receiver) external onlyOwner {

    selfdestruct(payable(receiver));
  }

  function itemPrice(uint256 itemId)
    external
    view
    onlyAvailableEdition(itemId)
    returns (uint256)
  {

    uint256 pricePerItemInUSD = idToEdition[itemId].price;
    uint256 pricePerItem = pricePerItemInUSD * priceInWEI();
    return pricePerItem;
  }

  function fetchEditions() external view returns (Edition[] memory) {

    uint256 itemCount = _itemIds.current();
    uint256 currentIndex = 0;
    Edition[] memory items = new Edition[](itemCount);
    for (uint256 i = 0; i < itemCount; ) {
      Edition memory currentItem = idToEdition[i + 1];
      items[currentIndex] = currentItem;
      currentIndex += 1;

      unchecked {
        ++i;
      }
    }
    return items;
  }

  function fetchCreatorEditions(address habitatNFTCreatorAddress)
    external
    view
    returns (Edition[] memory)
  {

    uint256 itemCount = _itemIds.current();
    uint256 resultCount = 0;
    uint256 currentIndex = 0;
    for (uint256 i = 0; i < itemCount; ) {
      if (idToEdition[i + 1].nftContract == habitatNFTCreatorAddress) {
        resultCount += 1;
      }
      unchecked {
        ++i;
      }
    }
    Edition[] memory result = new Edition[](resultCount);
    for (uint256 i = 0; i < itemCount; ) {
      Edition memory currentItem = idToEdition[i + 1];

      if (currentItem.nftContract == habitatNFTCreatorAddress) {
        result[currentIndex] = currentItem;
        currentIndex += 1;
      }

      unchecked {
        ++i;
      }
    }
    return result;
  }

  function priceInWEI() public view returns (uint256) {

    return uint256(1e18 / uint256(_priceOfETH() / 10**_decimals()));
  }

  function hashTransaction(address account, uint256 price)
    internal
    pure
    returns (bytes32)
  {

    bytes32 dataHash = keccak256(abi.encodePacked(account, price));
    return
      keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", dataHash));
  }

  function recoverSignerAddress(
    address account,
    uint256 price,
    bytes memory signature
  ) internal pure returns (address) {

    bytes32 hash = hashTransaction(account, price);
    return hash.recover(signature);
  }

  function _safeTransfer(
    uint256 itemId,
    uint256 amount,
    address receiver
  ) internal {

    uint256 availableAmount = idToEdition[itemId].availableAmount;
    require(availableAmount >= amount, "OUT_OF_STOCK");

    idToEdition[itemId].availableAmount -= amount;

    IHabitatNFT(idToEdition[itemId].nftContract).safeTransferFrom(
      idToEdition[itemId].seller,
      receiver,
      idToEdition[itemId].tokenId,
      amount,
      ""
    );
  }

  function _priceOfETH() private view returns (uint256) {

    (
      uint80 roundID,
      int256 price,
      uint256 startedAt,
      uint256 timeStamp,
      uint80 answeredInRound
    ) = priceFeed.latestRoundData();
    (roundID, startedAt, timeStamp, answeredInRound);
    return uint256(price);
  }

  function _decimals() private view returns (uint256) {

    uint256 decimals = uint256(priceFeed.decimals());
    return decimals;
  }

  modifier onlyOwnerOrCreator() {

    require(
      creatorsWhitelist[msg.sender] || msg.sender == owner,
      "NOT_AUTHORIZED"
    );
    _;
  }

  modifier onlyOwner() {

    require(msg.sender == owner, "NOT_AUTHORIZED");
    _;
  }

  modifier onlyAvailableEdition(uint256 itemId) {

    require(idToEdition[itemId].nftContract != address(0), "NOT_EXIST");
    _;
  }
}