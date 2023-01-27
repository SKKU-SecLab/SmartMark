
pragma solidity ^0.8.0;

library CountersUpgradeable {

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

pragma solidity ^0.8.1;

library AddressUpgradeable {

    function isContract(address account) internal view returns (bool) {


        return account.code.length > 0;
    }

    function sendValue(address payable recipient, uint256 amount) internal {

        require(address(this).balance >= amount, "Address: insufficient balance");

        (bool success, ) = recipient.call{value: amount}("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    function functionCall(address target, bytes memory data) internal returns (bytes memory) {

        return functionCall(target, data, "Address: low-level call failed");
    }

    function functionCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {

        return functionCallWithValue(target, data, 0, errorMessage);
    }

    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value
    ) internal returns (bytes memory) {

        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value,
        string memory errorMessage
    ) internal returns (bytes memory) {

        require(address(this).balance >= value, "Address: insufficient balance for call");
        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{value: value}(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {

        return functionStaticCall(target, data, "Address: low-level static call failed");
    }

    function functionStaticCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal view returns (bytes memory) {

        require(isContract(target), "Address: static call to non-contract");

        (bool success, bytes memory returndata) = target.staticcall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    function verifyCallResult(
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) internal pure returns (bytes memory) {

        if (success) {
            return returndata;
        } else {
            if (returndata.length > 0) {

                assembly {
                    let returndata_size := mload(returndata)
                    revert(add(32, returndata), returndata_size)
                }
            } else {
                revert(errorMessage);
            }
        }
    }
}// MIT

pragma solidity ^0.8.0;


abstract contract Initializable {
    bool private _initialized;

    bool private _initializing;

    modifier initializer() {
        require(_initializing ? _isConstructor() : !_initialized, "Initializable: contract is already initialized");

        bool isTopLevelCall = !_initializing;
        if (isTopLevelCall) {
            _initializing = true;
            _initialized = true;
        }

        _;

        if (isTopLevelCall) {
            _initializing = false;
        }
    }

    modifier onlyInitializing() {
        require(_initializing, "Initializable: contract is not initializing");
        _;
    }

    function _isConstructor() private view returns (bool) {
        return !AddressUpgradeable.isContract(address(this));
    }
}// MIT

pragma solidity ^0.8.0;

abstract contract ContextUpgradeable is Initializable {
    function __Context_init() internal onlyInitializing {
    }

    function __Context_init_unchained() internal onlyInitializing {
    }
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }

    uint256[50] private __gap;
}// MIT

pragma solidity ^0.8.0;

abstract contract ReentrancyGuardUpgradeable is Initializable {

    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    function __ReentrancyGuard_init() internal onlyInitializing {
        __ReentrancyGuard_init_unchained();
    }

    function __ReentrancyGuard_init_unchained() internal onlyInitializing {
        _status = _NOT_ENTERED;
    }

    modifier nonReentrant() {
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        _status = _ENTERED;

        _;

        _status = _NOT_ENTERED;
    }

    uint256[49] private __gap;
}// MIT

pragma solidity ^0.8.0;


abstract contract OwnableUpgradeable is Initializable, ContextUpgradeable {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    function __Ownable_init() internal onlyInitializing {
        __Ownable_init_unchained();
    }

    function __Ownable_init_unchained() internal onlyInitializing {
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

    uint256[49] private __gap;
}// MIT

pragma solidity ^0.8.0;

interface IERC20Upgradeable {

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
}// MIT

pragma solidity ^0.8.0;

interface IERC165Upgradeable {

    function supportsInterface(bytes4 interfaceId) external view returns (bool);

}// MIT

pragma solidity ^0.8.0;


interface IERC721Upgradeable is IERC165Upgradeable {

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


interface IERC721EnumerableUpgradeable is IERC721Upgradeable {

    function totalSupply() external view returns (uint256);


    function tokenOfOwnerByIndex(address owner, uint256 index) external view returns (uint256);


    function tokenByIndex(uint256 index) external view returns (uint256);

}// MIT

pragma solidity ^0.8.0;

interface IERC721ReceiverUpgradeable {

    function onERC721Received(
        address operator,
        address from,
        uint256 tokenId,
        bytes calldata data
    ) external returns (bytes4);

}// MIT

pragma solidity ^0.8.0;


contract ERC721HolderUpgradeable is Initializable, IERC721ReceiverUpgradeable {

    function __ERC721Holder_init() internal onlyInitializing {

    }

    function __ERC721Holder_init_unchained() internal onlyInitializing {

    }
    function onERC721Received(
        address,
        address,
        uint256,
        bytes memory
    ) public virtual override returns (bytes4) {

        return this.onERC721Received.selector;
    }

    uint256[50] private __gap;
}// MIT

pragma solidity ^0.8.0;


interface IERC1155Upgradeable is IERC165Upgradeable {

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


interface IERC1155ReceiverUpgradeable is IERC165Upgradeable {

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


abstract contract ERC165Upgradeable is Initializable, IERC165Upgradeable {
    function __ERC165_init() internal onlyInitializing {
    }

    function __ERC165_init_unchained() internal onlyInitializing {
    }
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IERC165Upgradeable).interfaceId;
    }

    uint256[50] private __gap;
}// MIT

pragma solidity ^0.8.0;


abstract contract ERC1155ReceiverUpgradeable is Initializable, ERC165Upgradeable, IERC1155ReceiverUpgradeable {
    function __ERC1155Receiver_init() internal onlyInitializing {
    }

    function __ERC1155Receiver_init_unchained() internal onlyInitializing {
    }
    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC165Upgradeable, IERC165Upgradeable) returns (bool) {
        return interfaceId == type(IERC1155ReceiverUpgradeable).interfaceId || super.supportsInterface(interfaceId);
    }

    uint256[50] private __gap;
}// MIT

pragma solidity ^0.8.0;


contract ERC1155HolderUpgradeable is Initializable, ERC1155ReceiverUpgradeable {

    function __ERC1155Holder_init() internal onlyInitializing {

    }

    function __ERC1155Holder_init_unchained() internal onlyInitializing {

    }
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

    uint256[50] private __gap;
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

}// agpl-3.0
pragma solidity 0.8.4;

interface IBNFTRegistry {

  event Initialized(address genericImpl, string namePrefix, string symbolPrefix);
  event GenericImplementationUpdated(address genericImpl);
  event BNFTCreated(address indexed nftAsset, address bNftImpl, address bNftProxy, uint256 totals);
  event BNFTUpgraded(address indexed nftAsset, address bNftImpl, address bNftProxy, uint256 totals);
  event CustomeSymbolsAdded(address[] nftAssets, string[] symbols);
  event ClaimAdminUpdated(address oldAdmin, address newAdmin);

  function getBNFTAddresses(address nftAsset) external view returns (address bNftProxy, address bNftImpl);


  function getBNFTAddressesByIndex(uint16 index) external view returns (address bNftProxy, address bNftImpl);


  function getBNFTAssetList() external view returns (address[] memory);


  function allBNFTAssetLength() external view returns (uint256);


  function initialize(
    address genericImpl,
    string memory namePrefix_,
    string memory symbolPrefix_
  ) external;


  function setBNFTGenericImpl(address genericImpl) external;


  function createBNFT(address nftAsset) external returns (address bNftProxy);


  function createBNFTWithImpl(address nftAsset, address bNftImpl) external returns (address bNftProxy);


  function upgradeBNFTWithImpl(
    address nftAsset,
    address bNftImpl,
    bytes memory encodedCallData
  ) external;


  function addCustomeSymbols(address[] memory nftAssets_, string[] memory symbols_) external;

}// agpl-3.0
pragma solidity 0.8.4;

interface IBNFT {

  event Initialized(address indexed underlyingAsset_);

  event OwnershipTransferred(address oldOwner, address newOwner);

  event ClaimAdminUpdated(address oldAdmin, address newAdmin);

  event Mint(address indexed user, address indexed nftAsset, uint256 nftTokenId, address indexed owner);

  event Burn(address indexed user, address indexed nftAsset, uint256 nftTokenId, address indexed owner);

  event FlashLoan(address indexed target, address indexed initiator, address indexed nftAsset, uint256 tokenId);

  event ClaimERC20Airdrop(address indexed token, address indexed to, uint256 amount);

  event ClaimERC721Airdrop(address indexed token, address indexed to, uint256[] ids);

  event ClaimERC1155Airdrop(address indexed token, address indexed to, uint256[] ids, uint256[] amounts, bytes data);

  function initialize(
    address underlyingAsset_,
    string calldata bNftName,
    string calldata bNftSymbol,
    address owner_,
    address claimAdmin_
  ) external;


  function mint(address to, uint256 tokenId) external;


  function burn(uint256 tokenId) external;


  function flashLoan(
    address receiverAddress,
    uint256[] calldata nftTokenIds,
    bytes calldata params
  ) external;


  function claimERC20Airdrop(
    address token,
    address to,
    uint256 amount
  ) external;


  function claimERC721Airdrop(
    address token,
    address to,
    uint256[] calldata ids
  ) external;


  function claimERC1155Airdrop(
    address token,
    address to,
    uint256[] calldata ids,
    uint256[] calldata amounts,
    bytes calldata data
  ) external;


  function minterOf(uint256 tokenId) external view returns (address);


  function underlyingAsset() external view returns (address);


  function contractURI() external view returns (string memory);

}// agpl-3.0
pragma solidity 0.8.4;




contract AirdropDistribution is
  Initializable,
  ContextUpgradeable,
  ReentrancyGuardUpgradeable,
  OwnableUpgradeable,
  ERC721HolderUpgradeable,
  ERC1155HolderUpgradeable
{

  using CountersUpgradeable for CountersUpgradeable.Counter;

  error OnlyCoordinatorCanFulfill(address have, address want);
  event AirdropCreated(
    uint256 airdropId,
    address nftAsset,
    address airdropTokenAddress,
    uint256 airdropTokenType,
    uint256 claimType
  );
  event AidropERC20Claimed(address user, uint256 airdropId, uint256 nftTokenId, uint256 airdropAmount);
  event AidropERC721Claimed(address user, uint256 airdropId, uint256 nftTokenId, uint256 airdropTokenId);
  event AidropERC1155Claimed(
    address user,
    uint256 airdropId,
    uint256 nftTokenId,
    uint256 airdropTokenId,
    uint256 airdropAmount
  );

  VRFCoordinatorV2Interface public vrfCoordinator;

  uint64 public vrfSubscriptionId;

  bytes32 public vrfKeyHash;

  uint32 public vrfCallbackGasLimit;
  uint16 public vrfRequestConfirmations;
  uint32 public vrfNumWords;

  uint256[] public vrfAllRequestIds;
  mapping(uint256 => uint256[]) public vrfAllRandomWords;

  IBNFTRegistry public bnftRegistry;

  uint256 public constant TOKEN_TYPE_ERC20 = 1;
  uint256 public constant TOKEN_TYPE_ERC721 = 2;
  uint256 public constant TOKEN_TYPE_ERC1155 = 3;

  uint256 public constant CLAIM_TYPE_FIXED_SAME = 1; /* Fixed, same id */
  uint256 public constant CLAIM_TYPE_FIXED_DIFF = 2; /* Fixed, diff id */
  uint256 public constant CLAIM_TYPE_RANDOM = 3;

  struct AirdropData {
    uint256 airdropId;
    address nftAsset;
    address bnftProxy;
    address airdropTokenAddress;
    uint256 airdropTokenType; // 1-ERC20, 2-ERC721, 3-ERC1155
    uint256 claimType; // 1-Fixed, 2-Random
    uint256 vrfRequestId;
    address[] nftAllUsers;
    mapping(address => uint256[]) nftUserTokenIds;
    mapping(uint256 => bool) nftTokenClaimeds;
    uint256[] erc1155AirdropTokenIds;
  }

  CountersUpgradeable.Counter public airdropIdTracker;
  mapping(uint256 => AirdropData) public airdropDatas;
  mapping(address => mapping(address => uint256)) public nftAirdropToIds;
  mapping(uint256 => uint256) public vrfReqIdToAirdropIds;

  function initialize(
    address bnftRegistry_,
    address vrfCoordinator_,
    uint64 subscriptionId_
  ) public initializer {

    __Context_init();
    __ReentrancyGuard_init();
    __Ownable_init();
    __ERC721Holder_init();
    __ERC1155Holder_init();

    bnftRegistry = IBNFTRegistry(bnftRegistry_);
    vrfCoordinator = VRFCoordinatorV2Interface(vrfCoordinator_);
    vrfSubscriptionId = subscriptionId_;
    airdropIdTracker.increment();

    vrfCallbackGasLimit = 100000;
    vrfRequestConfirmations = 3;
    vrfNumWords = 1;
  }

  function rawFulfillRandomWords(uint256 requestId, uint256[] calldata randomWords) external {

    if (_msgSender() != address(vrfCoordinator)) {
      revert OnlyCoordinatorCanFulfill(_msgSender(), address(vrfCoordinator));
    }
    fulfillRandomWords(requestId, randomWords);
  }

  function fulfillRandomWords(uint256 requestId, uint256[] calldata randomWords) internal {

    vrfAllRandomWords[requestId] = randomWords;
  }

  function configureVRFCoordinator(address vrfCoordinator_, uint64 subscriptionId_) public onlyOwner nonReentrant {

    vrfCoordinator = VRFCoordinatorV2Interface(vrfCoordinator_);
    vrfSubscriptionId = subscriptionId_;
  }

  function configureVRFParams(
    bytes32 keyHash,
    uint32 gasLimit,
    uint16 confirmations,
    uint32 numWords
  ) public onlyOwner nonReentrant {

    vrfKeyHash = keyHash;
    vrfCallbackGasLimit = gasLimit;
    vrfRequestConfirmations = confirmations;
    vrfNumWords = numWords;
  }

  function createAirdrop(
    address nftAsset,
    address airdropTokenAddress,
    uint256 airdropTokenType,
    uint256 claimType
  ) public onlyOwner nonReentrant returns (uint256) {

    (address bnftProxy, ) = bnftRegistry.getBNFTAddresses(nftAsset);
    require(bnftProxy != address(0), "bnft not exist");

    uint256 airdropId = airdropIdTracker.current();
    airdropIdTracker.increment();

    nftAirdropToIds[nftAsset][airdropTokenAddress] = airdropId;

    AirdropData storage data = airdropDatas[airdropId];
    data.airdropId = airdropId;
    data.nftAsset = nftAsset;
    data.bnftProxy = bnftProxy;
    data.airdropTokenAddress = airdropTokenAddress;
    data.airdropTokenType = airdropTokenType;
    data.claimType = claimType;

    emit AirdropCreated(airdropId, nftAsset, airdropTokenAddress, airdropTokenType, claimType);

    return airdropId;
  }

  function requestVRFRandomWords(uint256 airdropId) public onlyOwner nonReentrant {

    AirdropData storage data = airdropDatas[airdropId];
    require(data.airdropId != 0, "invalid airdrop id");
    require(data.claimType == CLAIM_TYPE_RANDOM, "claim type not random");

    data.vrfRequestId = vrfCoordinator.requestRandomWords(
      vrfKeyHash,
      vrfSubscriptionId,
      vrfRequestConfirmations,
      vrfCallbackGasLimit,
      vrfNumWords
    );

    vrfAllRequestIds.push(data.vrfRequestId);

    vrfReqIdToAirdropIds[data.vrfRequestId] = airdropId;
  }

  function configureNftUserTokenIds(
    uint256 airdropId,
    address[] calldata nftUsers,
    uint256[] calldata nftTokenIds
  ) public onlyOwner nonReentrant {

    require(nftUsers.length == nftTokenIds.length, "inconsistent params");

    AirdropData storage data = airdropDatas[airdropId];
    require(data.airdropId != 0, "invalid airdrop id");

    for (uint256 i = 0; i < nftUsers.length; i++) {
      if (data.nftUserTokenIds[nftUsers[i]].length == 0) {
        data.nftAllUsers.push(nftUsers[i]);
      }
      data.nftUserTokenIds[nftUsers[i]].push(nftTokenIds[i]);
    }
  }

  function clearNftUserTokenIds(uint256 airdropId, address[] calldata nftUsers) public onlyOwner nonReentrant {

    AirdropData storage data = airdropDatas[airdropId];
    require(data.airdropId != 0, "invalid airdrop id");

    for (uint256 i = 0; i < nftUsers.length; i++) {
      delete data.nftUserTokenIds[nftUsers[i]];
    }
  }

  function getNftUserTokenIds(uint256 airdropId, address nftUser) public view returns (uint256[] memory) {

    AirdropData storage data = airdropDatas[airdropId];
    require(data.airdropId != 0, "invalid airdrop id");

    return data.nftUserTokenIds[nftUser];
  }

  function isNftTokenClaimed(uint256 airdropId, uint256 tokenId) public view returns (bool) {

    AirdropData storage data = airdropDatas[airdropId];
    require(data.airdropId != 0, "invalid airdrop id");

    return data.nftTokenClaimeds[tokenId];
  }

  function configureERC1155(uint256 airdropId, uint256[] calldata airdropTokenIds) public onlyOwner nonReentrant {

    AirdropData storage data = airdropDatas[airdropId];
    require(data.airdropId != 0, "invalid airdrop id");
    require(data.airdropTokenType == TOKEN_TYPE_ERC1155, "token type not erc1155");

    data.erc1155AirdropTokenIds = airdropTokenIds;
  }

  function getERC1155Config(uint256 airdropId) public view returns (uint256[] memory, uint256[] memory) {

    AirdropData storage data = airdropDatas[airdropId];
    require(data.airdropId != 0, "invalid airdrop id");

    uint256[] memory erc1155Balances = new uint256[](data.erc1155AirdropTokenIds.length);
    for (uint256 airIdIdx = 0; airIdIdx < data.erc1155AirdropTokenIds.length; airIdIdx++) {
      erc1155Balances[airIdIdx] = IERC1155Upgradeable(data.airdropTokenAddress).balanceOf(
        address(this),
        data.erc1155AirdropTokenIds[airIdIdx]
      );
    }
    return (data.erc1155AirdropTokenIds, erc1155Balances);
  }

  struct ClaimLocalVars {
    uint256 userNftTokenId;
    uint256 airdropTokenId;
    uint256 randomIndex;
    uint256 airdropTokenBalance;
    uint256[] erc1155NonEmptyTokenIds;
    uint256 erc1155NonEmptyIdNum;
    uint256 erc1155TokenIdBalance;
  }

  function claimERC721(uint256 airdropId) public nonReentrant {

    ClaimLocalVars memory vars;

    AirdropData storage data = airdropDatas[airdropId];
    require(data.airdropId != 0, "invalid airdrop id");

    require(data.airdropTokenType == TOKEN_TYPE_ERC721, "invalid token type");
    require(data.nftUserTokenIds[_msgSender()].length > 0, "claim nothing");

    for (uint256 i = 0; i < data.nftUserTokenIds[_msgSender()].length; i++) {
      vars.userNftTokenId = data.nftUserTokenIds[_msgSender()][i];
      require(data.nftTokenClaimeds[vars.userNftTokenId] == false, "nft token claimed");

      if (data.claimType == CLAIM_TYPE_FIXED_SAME) {
        vars.airdropTokenId = vars.userNftTokenId;
      } else if (data.claimType == CLAIM_TYPE_RANDOM) {
        uint256 randomWord = _getRandomWord(data);

        vars.airdropTokenBalance = IERC721Upgradeable(data.airdropTokenAddress).balanceOf(address(this));
        vars.randomIndex = _calcRandomIndex(randomWord, vars.airdropTokenBalance);
        vars.airdropTokenId = IERC721EnumerableUpgradeable(data.airdropTokenAddress).tokenOfOwnerByIndex(
          address(this),
          vars.randomIndex
        );
      } else {
        vars.airdropTokenId = type(uint256).max;
        continue;
      }

      IERC721Upgradeable(data.airdropTokenAddress).safeTransferFrom(address(this), _msgSender(), vars.airdropTokenId);

      data.nftTokenClaimeds[vars.userNftTokenId] = true;

      emit AidropERC721Claimed(_msgSender(), data.airdropId, vars.userNftTokenId, vars.airdropTokenId);
    }
  }

  function claimERC1155(uint256 airdropId) public nonReentrant {

    ClaimLocalVars memory vars;

    AirdropData storage data = airdropDatas[airdropId];
    require(data.airdropId != 0, "invalid airdrop id");

    require(data.airdropTokenType == TOKEN_TYPE_ERC1155, "invalid token type");
    require(data.nftUserTokenIds[_msgSender()].length > 0, "claim nothing");

    vars.erc1155NonEmptyTokenIds = new uint256[](data.erc1155AirdropTokenIds.length);

    for (uint256 nftIdIdx = 0; nftIdIdx < data.nftUserTokenIds[_msgSender()].length; nftIdIdx++) {
      vars.userNftTokenId = data.nftUserTokenIds[_msgSender()][nftIdIdx];
      require(data.nftTokenClaimeds[vars.userNftTokenId] == false, "nft token claimed");

      if (data.claimType == CLAIM_TYPE_FIXED_SAME) {
        vars.airdropTokenId = vars.userNftTokenId;
      } else if (data.claimType == CLAIM_TYPE_RANDOM) {
        uint256 randomWord = _getRandomWord(data);

        vars.erc1155NonEmptyIdNum = 0;
        for (uint256 airIdIdx = 0; airIdIdx < data.erc1155AirdropTokenIds.length; airIdIdx++) {
          vars.erc1155TokenIdBalance = IERC1155Upgradeable(data.airdropTokenAddress).balanceOf(
            address(this),
            data.erc1155AirdropTokenIds[airIdIdx]
          );
          if (vars.erc1155TokenIdBalance > 0) {
            vars.erc1155NonEmptyTokenIds[vars.erc1155NonEmptyIdNum] = data.erc1155AirdropTokenIds[airIdIdx];
            vars.erc1155NonEmptyIdNum++;
          }
        }
        require(vars.erc1155NonEmptyIdNum > 0, "erc1155 id empty");

        vars.randomIndex = _calcRandomIndex(randomWord, vars.erc1155NonEmptyIdNum);
        vars.airdropTokenId = vars.erc1155NonEmptyTokenIds[vars.randomIndex];
      } else {
        vars.airdropTokenId = type(uint256).max;
        continue;
      }

      IERC1155Upgradeable(data.airdropTokenAddress).safeTransferFrom(
        address(this),
        _msgSender(),
        vars.airdropTokenId,
        1,
        new bytes(0)
      );

      emit AidropERC1155Claimed(_msgSender(), data.airdropId, vars.userNftTokenId, vars.airdropTokenId, 1);

      data.nftTokenClaimeds[vars.userNftTokenId] = true;
    }
  }

  function _calcRandomIndex(uint256 vrfRandomWord, uint256 maxIndex) internal view returns (uint256) {

    uint256 randomSeed = uint256(
      keccak256(abi.encodePacked(vrfRandomWord, blockhash(block.number - 1), msg.sender, maxIndex))
    );
    return randomSeed % maxIndex;
  }

  function _getRandomWord(AirdropData storage airdropData) internal view returns (uint256) {

    require(airdropData.vrfRequestId != 0, "zero request id");
    require(vrfAllRandomWords[airdropData.vrfRequestId].length > 0, "zero random words");

    return vrfAllRandomWords[airdropData.vrfRequestId][0];
  }
}