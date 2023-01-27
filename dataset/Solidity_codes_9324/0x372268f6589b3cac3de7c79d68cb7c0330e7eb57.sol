
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

interface LinkTokenInterface {


  function allowance(
    address owner,
    address spender
  )
    external
    view
    returns (
      uint256 remaining
    );


  function approve(
    address spender,
    uint256 value
  )
    external
    returns (
      bool success
    );


  function balanceOf(
    address owner
  )
    external
    view
    returns (
      uint256 balance
    );


  function decimals()
    external
    view
    returns (
      uint8 decimalPlaces
    );


  function decreaseApproval(
    address spender,
    uint256 addedValue
  )
    external
    returns (
      bool success
    );


  function increaseApproval(
    address spender,
    uint256 subtractedValue
  ) external;


  function name()
    external
    view
    returns (
      string memory tokenName
    );


  function symbol()
    external
    view
    returns (
      string memory tokenSymbol
    );


  function totalSupply()
    external
    view
    returns (
      uint256 totalTokensIssued
    );


  function transfer(
    address to,
    uint256 value
  )
    external
    returns (
      bool success
    );


  function transferAndCall(
    address to,
    uint256 value,
    bytes calldata data
  )
    external
    returns (
      bool success
    );


  function transferFrom(
    address from,
    address to,
    uint256 value
  )
    external
    returns (
      bool success
    );


}// MIT
pragma solidity ^0.8.0;

contract VRFRequestIDBase {


  function makeVRFInputSeed(
    bytes32 _keyHash,
    uint256 _userSeed,
    address _requester,
    uint256 _nonce
  )
    internal
    pure
    returns (
      uint256
    )
  {

    return uint256(keccak256(abi.encode(_keyHash, _userSeed, _requester, _nonce)));
  }

  function makeRequestId(
    bytes32 _keyHash,
    uint256 _vRFInputSeed
  )
    internal
    pure
    returns (
      bytes32
    )
  {

    return keccak256(abi.encodePacked(_keyHash, _vRFInputSeed));
  }
}// MIT
pragma solidity ^0.8.0;



abstract contract VRFConsumerBase is VRFRequestIDBase {

  function fulfillRandomness(
    bytes32 requestId,
    uint256 randomness
  )
    internal
    virtual;

  uint256 constant private USER_SEED_PLACEHOLDER = 0;

  function requestRandomness(
    bytes32 _keyHash,
    uint256 _fee
  )
    internal
    returns (
      bytes32 requestId
    )
  {
    LINK.transferAndCall(vrfCoordinator, _fee, abi.encode(_keyHash, USER_SEED_PLACEHOLDER));
    uint256 vRFSeed  = makeVRFInputSeed(_keyHash, USER_SEED_PLACEHOLDER, address(this), nonces[_keyHash]);
    nonces[_keyHash] = nonces[_keyHash] + 1;
    return makeRequestId(_keyHash, vRFSeed);
  }

  LinkTokenInterface immutable internal LINK;
  address immutable private vrfCoordinator;

  mapping(bytes32 /* keyHash */ => uint256 /* nonce */) private nonces;

  constructor(
    address _vrfCoordinator,
    address _link
  ) {
    vrfCoordinator = _vrfCoordinator;
    LINK = LinkTokenInterface(_link);
  }

  function rawFulfillRandomness(
    bytes32 requestId,
    uint256 randomness
  )
    external
  {
    require(msg.sender == vrfCoordinator, "Only VRFCoordinator can fulfill");
    fulfillRandomness(requestId, randomness);
  }
}// MIT

pragma solidity ^0.8.0;

interface IERC165 {

    function supportsInterface(bytes4 interfaceId) external view returns (bool);

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
}// MIT

pragma solidity ^0.8.0;

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
pragma solidity ^0.8.4;


contract Pixelvault1155Giveaway is VRFConsumerBase, ERC1155Holder, Ownable, Pausable {

    using Counters for Counters.Counter;
    Counters.Counter private counter; 

    bytes32 internal keyHash;
    uint256 internal fee;

    mapping(uint256 => Giveaway) public giveaways;

    IERC1155 public erc1155Contract;

    event Claimed(uint indexed index, address indexed account, uint amount);

    struct Giveaway {
        uint256 snapshotEntries;
        uint256 amountOfWinners;        
        uint256 randomNumber;
        uint256 tokenId;
        uint256 claimOpen;
        uint256 claimClose;
        bool isFulfilled;
        bool allowDuplicates;
        string entryListIpfsHash;
        address contractAddress;
        mapping(address => uint256) claimed;
        bytes32 merkleRoot;
    }

    constructor(
        address _vrfCoordinator,
        address _linkToken,
        bytes32 _keyHash,
        uint256 _fee
    ) VRFConsumerBase(_vrfCoordinator, _linkToken) {
        keyHash = _keyHash;
        fee = _fee;
    }   

    function setMerkleRoot(
        bytes32 _merkleRoot, 
        uint256 _drawId
    ) external onlyOwner {

        require(giveaways[_drawId].isFulfilled, "setMerkleRoot: draw not fulfilled");

        giveaways[_drawId].merkleRoot = _merkleRoot;
    } 

    function getWinners(uint256 giveawayId) external view returns (uint256[] memory) {

        require(giveaways[giveawayId].isFulfilled, "GetWinners: draw not fulfilled");        
        require(giveaways[giveawayId].amountOfWinners > 0, "GetWinners: not a draw");        

        uint256[] memory expandedValues = new uint256[](giveaways[giveawayId].amountOfWinners);
        bool[] memory isNumberPicked = new bool[](giveaways[giveawayId].snapshotEntries);

        uint256 resultIndex;
        uint256 i;
        while (resultIndex < giveaways[giveawayId].amountOfWinners) {
            uint256 number = (uint256(keccak256(abi.encode(giveaways[giveawayId].randomNumber, i))) % giveaways[giveawayId].snapshotEntries) + 1;
            
            if(giveaways[giveawayId].allowDuplicates || !isNumberPicked[number-1]) {
                expandedValues[resultIndex] = number;
                isNumberPicked[number-1] = true;

                resultIndex++;
            }
            i++;
        }

        return expandedValues;
    }

    function withdrawLink() external onlyOwner {

        LINK.transfer(owner(), LINK.balanceOf(address(this)));
    }    

    function startDraw(
        uint256 _snapshotEntries, 
        uint256 _amountOfWinners, 
        uint256 _tokenId, 
        address _contractAddress, 
        string memory _entryListIpfsHash, 
        bool _allowDuplicates, 
        uint256 _claimOpen, 
        uint256 _claimClose
    ) external onlyOwner returns (bytes32 requestId) {

        require(counter.current() == 0 || giveaways[counter.current()-1].isFulfilled, "Draw: previous draw not fulfilled");    
        require(_amountOfWinners < _snapshotEntries, "Draw: amount of winners must be smaller than number of entries");    
        require(
            LINK.balanceOf(address(this)) >= fee,
            "Not enough LINK - fill contract with faucet"
        );

        Giveaway storage d = giveaways[counter.current()];
        d.snapshotEntries = _snapshotEntries;
        d.amountOfWinners = _amountOfWinners;
        d.tokenId = _tokenId;     
        d.contractAddress = _contractAddress;
        d.entryListIpfsHash = _entryListIpfsHash;
        d.allowDuplicates = _allowDuplicates;
        d.claimOpen = _claimOpen;
        d.claimClose = _claimClose;

        counter.increment();

        return requestRandomness(keyHash, fee);
    }

    function startGiveaway(
        uint256 _tokenId, 
        address _contractAddress, 
        bytes32 _merkleRoot, 
        uint256 _claimOpen, 
        uint256 _claimClose
    ) external onlyOwner {

        require(counter.current() == 0 || giveaways[counter.current()-1].isFulfilled, "Giveaway: previous giveaway not fulfilled");    

        Giveaway storage d = giveaways[counter.current()];
        d.tokenId = _tokenId;     
        d.isFulfilled = true;
        d.contractAddress = _contractAddress;
        d.merkleRoot = _merkleRoot;
        d.claimOpen = _claimOpen;
        d.claimClose = _claimClose;

        counter.increment();
    }    

    function claim(
        uint256 amount,
        uint256 giveawayId,
        uint256 index,
        uint256 maxAmount,
        bytes32[] calldata merkleProof
    ) external whenNotPaused {

        require(giveaways[giveawayId].claimed[msg.sender] + amount <= maxAmount, "Claim: Not allowed to claim given amount");
        require (block.timestamp >= giveaways[giveawayId].claimOpen && block.timestamp <= giveaways[giveawayId].claimClose, "Claim: time window closed");        

        bytes32 node = keccak256(abi.encodePacked(index, msg.sender, maxAmount));
        require(
            MerkleProof.verify(merkleProof, giveaways[giveawayId].merkleRoot, node),
            "MerkleDistributor: Invalid proof."
        );

        giveaways[giveawayId].claimed[msg.sender] = giveaways[giveawayId].claimed[msg.sender] + amount;

        IERC1155(giveaways[giveawayId].contractAddress).safeTransferFrom(address(this), msg.sender, giveaways[giveawayId].tokenId, amount, "");

        emit Claimed(giveaways[giveawayId].tokenId, msg.sender, amount);                
    }  

    function withdrawTokens(address _contractAddress, uint256 _tokenId, uint256 _amount) external onlyOwner {

        IERC1155(_contractAddress).safeTransferFrom(address(this), msg.sender, _tokenId, _amount, "");
    }

    function pause() external onlyOwner {

        _pause();
    }

    function unpause() external onlyOwner {

        _unpause();
    }   

    function forceFulfill(uint256 _giveawayId) external onlyOwner {

        giveaways[_giveawayId].isFulfilled = true;
    }       

    function setClaimWindow(uint256 _giveawayId, uint256 _claimOpen, uint256 _claimClose) external onlyOwner {

        require(_giveawayId < counter.current(), "Draw id does not exist");

        giveaways[_giveawayId].claimOpen = _claimOpen;
        giveaways[_giveawayId].claimClose = _claimClose;
    }    

    function getClaimedTokens(uint256 drawId, address userAdress) public view returns (uint256) {

        return giveaways[drawId].claimed[userAdress];
    }              

    function fulfillRandomness(bytes32, uint256 randomness) internal override {

        giveaways[counter.current()-1].randomNumber = randomness;
        giveaways[counter.current()-1].isFulfilled = true;
    }
   
}