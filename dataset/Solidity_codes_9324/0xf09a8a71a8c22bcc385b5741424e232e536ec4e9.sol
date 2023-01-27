
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

interface IERC721Receiver {

    function onERC721Received(
        address operator,
        address from,
        uint256 tokenId,
        bytes calldata data
    ) external returns (bytes4);

}// MIT
pragma solidity ^0.8.10;

library MerkleProofIndexed {

    function verify(
        bytes32[] memory proof,
        bytes32 root,
        bytes32 leaf,
        uint256 leafIndex
    ) internal pure returns (bool) {

        bytes32 computedHash = leaf;
        bytes32 proofElement;

        for (uint256 i = 0; i < proof.length; i++) {
            proofElement = proof[i];

            if ((leafIndex >> i) % 2 == 0) {
                computedHash = keccak256(
                    abi.encodePacked(computedHash, proofElement)
                );
            } else {
                computedHash = keccak256(
                    abi.encodePacked(proofElement, computedHash)
                );
            }
        }
        return computedHash == root;
    }
}// MIT
pragma solidity ^0.8.0;

interface LinkTokenInterface {

  function allowance(address owner, address spender) external view returns (uint256 remaining);


  function approve(address spender, uint256 value) external returns (bool success);


  function balanceOf(address owner) external view returns (uint256 balance);


  function decimals() external view returns (uint8 decimalPlaces);


  function decreaseApproval(address spender, uint256 addedValue) external returns (bool success);


  function increaseApproval(address spender, uint256 subtractedValue) external;


  function name() external view returns (string memory tokenName);


  function symbol() external view returns (string memory tokenSymbol);


  function totalSupply() external view returns (uint256 totalTokensIssued);


  function transfer(address to, uint256 value) external returns (bool success);


  function transferAndCall(
    address to,
    uint256 value,
    bytes calldata data
  ) external returns (bool success);


  function transferFrom(
    address from,
    address to,
    uint256 value
  ) external returns (bool success);

}// MIT
pragma solidity ^0.8.0;

interface VRFCoordinatorV2Interface {

  function getRequestConfig()
    external
    view
    returns (
      uint16,
      uint32,
      bytes32[] memory
    );


  function requestRandomWords(
    bytes32 keyHash,
    uint64 subId,
    uint16 minimumRequestConfirmations,
    uint32 callbackGasLimit,
    uint32 numWords
  ) external returns (uint256 requestId);


  function createSubscription() external returns (uint64 subId);


  function getSubscription(uint64 subId)
    external
    view
    returns (
      uint96 balance,
      uint64 reqCount,
      address owner,
      address[] memory consumers
    );


  function requestSubscriptionOwnerTransfer(uint64 subId, address newOwner) external;


  function acceptSubscriptionOwnerTransfer(uint64 subId) external;


  function addConsumer(uint64 subId, address consumer) external;


  function removeConsumer(uint64 subId, address consumer) external;


  function cancelSubscription(uint64 subId, address to) external;

}// MIT
pragma solidity ^0.8.0;

abstract contract VRFConsumerBaseV2 {
  error OnlyCoordinatorCanFulfill(address have, address want);
  address private immutable vrfCoordinator;

  constructor(address _vrfCoordinator) {
    vrfCoordinator = _vrfCoordinator;
  }

  function fulfillRandomWords(uint256 requestId, uint256[] memory randomWords) internal virtual;

  function rawFulfillRandomWords(uint256 requestId, uint256[] memory randomWords) external {
    if (msg.sender != vrfCoordinator) {
      revert OnlyCoordinatorCanFulfill(msg.sender, vrfCoordinator);
    }
    fulfillRandomWords(requestId, randomWords);
  }
}//MIT
pragma solidity ^0.8.10;


contract GiveawayContractV2 is VRFConsumerBaseV2, IERC721Receiver {

  struct ERC721Token {
    address contractAddress;
    uint256 tokenId;
    bool claimed;
  }

  ERC721Token[] public nftToDrop;

  VRFCoordinatorV2Interface COORDINATOR;
  LinkTokenInterface LINKTOKEN;

  bytes32 keyHash;

  uint32 callbackGasLimit = 100000;

  uint16 requestConfirmations = 3;

  uint256[] public s_randomWords;
  uint256 public s_requestId;
  uint64 public s_subscriptionId;
  address s_owner;

  uint256 public startIndex;

  bytes32[] merkleRoot;
  uint256[] numberOfParticipants;
  uint256[] numberOfPrizes;

  bool public dropSet;

  modifier onlyOwner() {

    require(msg.sender == s_owner);
    _;
  }

  modifier onlyIfNotSet() {

    require(!dropSet, "Drop already set");
    _;
  }

  modifier onlyWithNFT() {

    require(nftToDrop.length > 0, "No NFT to drop");
    _;
  }

  constructor(
    uint64 subscriptionId,
    address vrfCoordinator,
    address link_token_contract,
    bytes32 keyHash_
  ) VRFConsumerBaseV2(vrfCoordinator) {
    COORDINATOR = VRFCoordinatorV2Interface(vrfCoordinator);
    LINKTOKEN = LinkTokenInterface(link_token_contract);
    keyHash = keyHash_;
    s_subscriptionId = subscriptionId;
    s_owner = msg.sender;
  }

  function setupDrop(
    bytes32[] memory merkleRoot_,
    uint256[] memory numberOfParticipants_,
    uint256[] memory numberOfPrizes_
  ) public onlyOwner onlyIfNotSet {

    require(
      merkleRoot_.length == numberOfParticipants_.length &&
        merkleRoot_.length == numberOfPrizes_.length,
      "Invalid drop configuration"
    );
    require(merkleRoot_.length < 5, "To much drops");

    merkleRoot = merkleRoot_;
    numberOfParticipants = numberOfParticipants_;
    numberOfPrizes = numberOfPrizes_;

    dropSet = true;

    s_requestId = getRandomNumber(2);
  }

  function addNFT(address contractAddress, uint256[] memory tokenIds)
    public
    onlyOwner
    onlyIfNotSet
  {

    for (uint256 i = 0; i < tokenIds.length; i++) {
      IERC721(contractAddress).safeTransferFrom(IERC721(contractAddress).ownerOf(tokenIds[i]), address(this), tokenIds[i]);
      nftToDrop.push(
        ERC721Token({contractAddress: contractAddress, tokenId: tokenIds[i], claimed: false})
      );
    }
  }

  function adjustLeafIndex(uint256 dropNumber, uint256 index) internal view returns (uint256) {

    uint256 _startIndex = s_randomWords[1] % numberOfParticipants[dropNumber];
    int256 difference = int256(index) - int256(_startIndex);
    uint256 remaining = numberOfParticipants[dropNumber] - _startIndex;

    if (difference >= 0) {
      return uint256(difference);
    } else {
      return remaining + index;
    }
  }

  function adjustNFTIndex(uint256 index) internal view returns (uint256) {

    uint256 _startIndex = s_randomWords[0] % nftToDrop.length;
    if (_startIndex + index >= nftToDrop.length) {
      return (_startIndex + index) % nftToDrop.length;
    } else {
      return _startIndex + index;
    }
  }

  function getPrecDropLength(uint256 dropNumber) public view returns (uint256) {

    uint256 sum = 0;
    for (uint8 i = 0; i < dropNumber; i++) {
      sum = sum + numberOfPrizes[i];
    }

    return sum;
  }

  function claimNFT(
    uint256 dropNumber,
    bytes32[] memory proof,
    bytes32 leaf,
    uint256 leafIndex,
    address receiver
  ) public {

    require(dropNumber < merkleRoot.length, "Invalid drop number");
    require(verifyProof(dropNumber, proof, leaf, leafIndex), "Invalid proof");
    require(keccak256(abi.encodePacked(receiver)) == leaf, "Invalid receiver");
    require(leafIndex < numberOfParticipants[dropNumber], "Invalid leaf index");

    uint256 adjustedLeafIndex = adjustLeafIndex(dropNumber, leafIndex);
    require(adjustedLeafIndex < numberOfPrizes[dropNumber], "No more NFT for this drop");

    uint256 precDropLength = getPrecDropLength(dropNumber);
    uint256 indexToClaim = adjustNFTIndex(adjustedLeafIndex + precDropLength);

    require(nftToDrop[indexToClaim].claimed != true, "Already claimed token");

    nftToDrop[indexToClaim].claimed = true;
    IERC721(nftToDrop[indexToClaim].contractAddress).safeTransferFrom(
      address(this),
      receiver,
      nftToDrop[indexToClaim].tokenId
    );
  }

  function getRandomNumber(uint32 numWords) internal returns (uint256 requestId) {

    return
      COORDINATOR.requestRandomWords(
        keyHash,
        s_subscriptionId,
        requestConfirmations,
        callbackGasLimit,
        numWords
      );
  }

  function fulfillRandomWords(
    uint256, /* requestId */
    uint256[] memory randomWords
  ) internal override {

    s_randomWords = randomWords;
  }

  function verifyProof(
    uint256 dropNumber,
    bytes32[] memory proof,
    bytes32 leaf,
    uint256 leafIndex
  ) public view returns (bool) {

    return MerkleProofIndexed.verify(proof, merkleRoot[dropNumber], leaf, leafIndex);
  }

  function onERC721Received(
    address,
    address,
    uint256,
    bytes memory
  ) public virtual override returns (bytes4) {

    return this.onERC721Received.selector;
  }
}