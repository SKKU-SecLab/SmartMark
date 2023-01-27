

pragma solidity ^0.6.0;

library SafeMathChainlink {

  function add(uint256 a, uint256 b) internal pure returns (uint256) {

    uint256 c = a + b;
    require(c >= a, "SafeMath: addition overflow");

    return c;
  }

  function sub(uint256 a, uint256 b) internal pure returns (uint256) {

    require(b <= a, "SafeMath: subtraction overflow");
    uint256 c = a - b;

    return c;
  }

  function mul(uint256 a, uint256 b) internal pure returns (uint256) {

    if (a == 0) {
      return 0;
    }

    uint256 c = a * b;
    require(c / a == b, "SafeMath: multiplication overflow");

    return c;
  }

  function div(uint256 a, uint256 b) internal pure returns (uint256) {

    require(b > 0, "SafeMath: division by zero");
    uint256 c = a / b;

    return c;
  }

  function mod(uint256 a, uint256 b) internal pure returns (uint256) {

    require(b != 0, "SafeMath: modulo by zero");
    return a % b;
  }
}


pragma solidity ^0.6.0;

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

  function transferAndCall(address to, uint256 value, bytes calldata data) external returns (bool success);

  function transferFrom(address from, address to, uint256 value) external returns (bool success);

}


pragma solidity ^0.6.0;

contract VRFRequestIDBase {


  function makeVRFInputSeed(bytes32 _keyHash, uint256 _userSeed,
    address _requester, uint256 _nonce)
    internal pure returns (uint256)
  {

    return  uint256(keccak256(abi.encode(_keyHash, _userSeed, _requester, _nonce)));
  }

  function makeRequestId(
    bytes32 _keyHash, uint256 _vRFInputSeed) internal pure returns (bytes32) {

    return keccak256(abi.encodePacked(_keyHash, _vRFInputSeed));
  }
}


pragma solidity ^0.6.0;




abstract contract VRFConsumerBase is VRFRequestIDBase {

  using SafeMathChainlink for uint256;

  function fulfillRandomness(bytes32 requestId, uint256 randomness)
    internal virtual;

  uint256 constant private USER_SEED_PLACEHOLDER = 0;

  function requestRandomness(bytes32 _keyHash, uint256 _fee)
    internal returns (bytes32 requestId)
  {
    LINK.transferAndCall(vrfCoordinator, _fee, abi.encode(_keyHash, USER_SEED_PLACEHOLDER));
    uint256 vRFSeed  = makeVRFInputSeed(_keyHash, USER_SEED_PLACEHOLDER, address(this), nonces[_keyHash]);
    nonces[_keyHash] = nonces[_keyHash].add(1);
    return makeRequestId(_keyHash, vRFSeed);
  }

  LinkTokenInterface immutable internal LINK;
  address immutable private vrfCoordinator;

  mapping(bytes32 /* keyHash */ => uint256 /* nonce */) private nonces;

  constructor(address _vrfCoordinator, address _link) public {
    vrfCoordinator = _vrfCoordinator;
    LINK = LinkTokenInterface(_link);
  }

  function rawFulfillRandomness(bytes32 requestId, uint256 randomness) external {
    require(msg.sender == vrfCoordinator, "Only VRFCoordinator can fulfill");
    fulfillRandomness(requestId, randomness);
  }
}



pragma solidity ^0.6.0;

interface IERC165 {

    function supportsInterface(bytes4 interfaceId) external view returns (bool);

}



pragma solidity ^0.6.2;


interface IERC721 is IERC165 {

    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);

    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);

    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);

    function balanceOf(address owner) external view returns (uint256 balance);


    function ownerOf(uint256 tokenId) external view returns (address owner);


    function safeTransferFrom(address from, address to, uint256 tokenId) external;


    function transferFrom(address from, address to, uint256 tokenId) external;


    function approve(address to, uint256 tokenId) external;


    function getApproved(uint256 tokenId) external view returns (address operator);


    function setApprovalForAll(address operator, bool _approved) external;


    function isApprovedForAll(address owner, address operator) external view returns (bool);


    function safeTransferFrom(address from, address to, uint256 tokenId, bytes calldata data) external;

}



pragma solidity ^0.6.0;

interface IERC721Receiver {

    function onERC721Received(address operator, address from, uint256 tokenId, bytes calldata data)
    external returns (bytes4);

}



pragma solidity ^0.6.0;


contract ERC721Holder is IERC721Receiver {


    function onERC721Received(address, address, uint256, bytes memory) public virtual override returns (bytes4) {

        return this.onERC721Received.selector;
    }
}



pragma solidity ^0.6.8;





contract NFTLottery is VRFConsumerBase, ERC721Holder {


  bytes32 internal immutable keyHash;
  LinkTokenInterface public immutable link;

  mapping(bytes32 => address) public rewardAddress;
  mapping(bytes32 => uint256) public rewardId;


  mapping(bytes32 => address[]) public addressRecipients;

  mapping(bytes32 => address) public nftRecipientAddress;
  mapping(bytes32 => uint256) public nftRecipientStart;
  mapping(bytes32 => uint256) public nftRecipientEnd;

  constructor(address _vrf, address _link, bytes32 _keyHash) 
    VRFConsumerBase(
      _vrf, _link
    ) public {
      link = LinkTokenInterface(_link);
      keyHash = _keyHash;
  }

  function distributeToAddresses(uint256 fee, address[] calldata recipients, address _rewardAddress, uint256 _rewardId) external {

    link.transferFrom(msg.sender, address(this), fee);
    IERC721(_rewardAddress).safeTransferFrom(msg.sender, address(this), _rewardId);
    bytes32 requestId = requestRandomness(keyHash, fee);
    addressRecipients[requestId] = recipients;
    rewardAddress[requestId] = _rewardAddress;
    rewardId[requestId] = _rewardId;
  }
  
  function distributeToNftHolders(uint256 fee, address _nftRecipientAddress, uint256 startIndex, uint256 endIndex, address _rewardAddress, uint256 _rewardId) external {

    link.transferFrom(msg.sender, address(this), fee);
    IERC721(_rewardAddress).safeTransferFrom(msg.sender, address(this), _rewardId);
    bytes32 requestId = requestRandomness(keyHash, fee);
    nftRecipientAddress[requestId] = _nftRecipientAddress;
    nftRecipientStart[requestId] = startIndex;
    nftRecipientEnd[requestId] = endIndex;
    rewardAddress[requestId] = _rewardAddress;
    rewardId[requestId] = _rewardId;
  }
  
  function fulfillRandomness(bytes32 requestId, uint256 randomness) internal override {


    if (addressRecipients[requestId].length == 0) {
      uint256 startIndex = nftRecipientStart[requestId];
      uint256 endIndex = nftRecipientEnd[requestId];
      IERC721(rewardAddress[requestId]).transferFrom(
        address(this),
        IERC721(nftRecipientAddress[requestId]).ownerOf(randomness % (endIndex+1-startIndex) + startIndex),
        rewardId[requestId]
      );
      delete nftRecipientAddress[requestId];
      delete nftRecipientStart[requestId];
      delete nftRecipientEnd[requestId];
    }

    else {
      address[] memory recipients = addressRecipients[requestId];
      IERC721(rewardAddress[requestId]).transferFrom(
        address(this),
        recipients[randomness % recipients.length],
        rewardId[requestId]
      );
      delete addressRecipients[requestId];
    }
    delete rewardAddress[requestId];
    delete rewardId[requestId];
  }

}