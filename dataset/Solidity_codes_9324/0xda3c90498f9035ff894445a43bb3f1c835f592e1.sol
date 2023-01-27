
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

library Address {

    function isContract(address account) internal view returns (bool) {


        uint256 size;
        assembly {
            size := extcodesize(account)
        }
        return size > 0;
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

    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {

        return functionDelegateCall(target, data, "Address: low-level delegate call failed");
    }

    function functionDelegateCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {

        require(isContract(target), "Address: delegate call to non-contract");

        (bool success, bytes memory returndata) = target.delegatecall(data);
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


library SafeERC20 {

    using Address for address;

    function safeTransfer(
        IERC20 token,
        address to,
        uint256 value
    ) internal {

        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(
        IERC20 token,
        address from,
        address to,
        uint256 value
    ) internal {

        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    function safeApprove(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {

        require(
            (value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {

        uint256 newAllowance = token.allowance(address(this), spender) + value;
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {

        unchecked {
            uint256 oldAllowance = token.allowance(address(this), spender);
            require(oldAllowance >= value, "SafeERC20: decreased allowance below zero");
            uint256 newAllowance = oldAllowance - value;
            _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
        }
    }

    function _callOptionalReturn(IERC20 token, bytes memory data) private {


        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) {
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
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
}// GPL-3.0
pragma solidity ^0.8.7;


abstract contract PermitControl is Ownable {
  using Address for address;

  bytes32 public constant ZERO_RIGHT = hex"00000000000000000000000000000000";

  bytes32 public constant UNIVERSAL = hex"FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF";

  bytes32 public constant MANAGER = hex"FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF";

  mapping( address => mapping( bytes32 => mapping( bytes32 => uint256 )))
    public permissions;

  mapping( bytes32 => bytes32 ) public managerRight;

  event PermitUpdated(
    address indexed updator,
    address indexed updatee,
    bytes32 circumstance,
    bytes32 indexed role,
    uint256 expirationTime
  );

    

  event ManagementUpdated(
    address indexed manager,
    bytes32 indexed managedRight,
    bytes32 indexed managerRight
  );

  modifier hasValidPermit(
    bytes32 _circumstance,
    bytes32 _right
  ) {
    require(_msgSender() == owner()
      || hasRight(_msgSender(), _circumstance, _right),
      "P1");
    _;
  }

  function version() external virtual pure returns (uint256) {
    return 1;
  }

  function hasRightUntil(
    address _address,
    bytes32 _circumstance,
    bytes32 _right
  ) public view returns (uint256) {
    return permissions[_address][_circumstance][_right];
  }

  function hasRight(
    address _address,
    bytes32 _circumstance,
    bytes32 _right
  ) public view returns (bool) {
    return permissions[_address][_circumstance][_right] > block.timestamp;
  }

  function setPermit(
    address _address,
    bytes32 _circumstance,
    bytes32 _right,
    uint256 _expirationTime
  ) public virtual hasValidPermit(UNIVERSAL, managerRight[_right]) {
    require(_right != ZERO_RIGHT,
      "P2");
    permissions[_address][_circumstance][_right] = _expirationTime;
    emit PermitUpdated(_msgSender(), _address, _circumstance, _right,
      _expirationTime);
  }



  function setManagerRight(
    bytes32 _managedRight,
    bytes32 _managerRight
  ) external virtual hasValidPermit(UNIVERSAL, MANAGER) {
    require(_managedRight != ZERO_RIGHT,
      "P3");
    managerRight[_managedRight] = _managerRight;
    emit ManagementUpdated(_msgSender(), _managedRight, _managerRight);
  }
}// GPL-3.0
pragma solidity ^0.8.7;




contract Sweepable is PermitControl {

  using SafeERC20 for IERC20;

  bytes32 public constant SWEEP = keccak256("SWEEP");

  bytes32 public constant LOCK_SWEEP = keccak256("LOCK_SWEEP");

  bool public sweepLocked;

  event TokenSweep(address indexed sweeper, IERC20 indexed token,
    uint256 amount, address indexed recipient);

  event SweepLocked(address indexed locker);

  function version() external virtual override pure returns (uint256) {

    return 1;
  }

  function sweep(IERC20 _token, uint256 _amount, address _address) external
    hasValidPermit(UNIVERSAL, SWEEP) {

    require(!sweepLocked,
      "Sweep: the sweep function is locked");
    _token.safeTransfer(_address, _amount);
    emit TokenSweep(_msgSender(), _token, _amount, _address);
  }

  function lockSweep() external hasValidPermit(UNIVERSAL, LOCK_SWEEP) {

    sweepLocked = true;
    emit SweepLocked(_msgSender());
  }
}pragma solidity 0.8.8;

library DFStorage {

    struct PoolInput {
        string name;
        uint256 startTime;
        uint256 endTime;
        uint256 purchaseLimit;
        uint256 singlePurchaseLimit;
        PoolRequirement requirement;
        address collection;
    }

    enum AccessType {
        Public,
        TokenRequired,
        ItemRequired,
        PointRequired,
        ItemRequired721
    }

    struct PoolRequirement {
        AccessType requiredType;
        address[] requiredAsset;
        uint256 requiredAmount;
        uint256[] requiredId;
    }

    enum AssetType {
        Point,
        Ether,
        Token
    }

    struct Price {
        AssetType assetType;
        address asset;
        uint256 price;
    }
  enum SupplyType {
    Capped,
    Uncapped,
    Flexible
  }

  enum ItemType {
    Nonfungible,
    Fungible,
    Semifungible
  }

  enum BurnType {
    None,
    Burnable,
    Replenishable
  }

  struct ItemGroupInput {
    uint256 supplyData;
    uint256 itemData;
    uint256 burnData;
    SupplyType supplyType;
    ItemType itemType;
    BurnType burnType;
    string name;
  }


  struct WhiteListInput {
    uint256 whiteListId;
    uint256 index; 
    uint256 allowance;
    bytes32 node; 
    bytes32[] merkleProof;
  }


  struct WhiteListCreate {
    uint256 _accesslistId;
    bytes32 _merkleRoot;
    uint256 _startTime; 
    uint256 _endTime; 
    uint256 _price; 
    address _token;
  }
}// GPL-3.0
pragma solidity ^0.8.8;


interface ISuper1155 {


  function SET_URI () external view returns (bytes32);

  function SET_PROXY_REGISTRY () external view returns (bytes32);

  function CONFIGURE_GROUP () external view returns (bytes32);

  function MINT () external view returns (bytes32);

  function BURN () external view returns (bytes32);

  function SET_METADATA () external view returns (bytes32);

  function LOCK_URI () external view returns (bytes32);

  function LOCK_ITEM_URI () external view returns (bytes32);

  function LOCK_CREATION () external view returns (bytes32);

  function name () external view returns (string memory);

  function metadataUri () external view returns (string memory);

  function proxyRegistryAddress () external view returns (address);

  function groupBalances (uint256, address) external view returns (uint256);

  function totalBalances (address) external view returns (uint256);


  function circulatingSupply (uint256) external view returns (uint256);

  function mintCount (uint256) external view returns (uint256);

  function burnCount (uint256) external view returns (uint256);

  function metadataFrozen (uint256) external view returns (bool);

  function metadata (uint256) external view returns (string memory);

  function uriLocked () external view returns (bool);

  function locked () external view returns (bool);

  function version () external view returns (uint256);

  function uri (uint256) external view returns (string memory);

  function setURI (string memory _uri) external;

  function setProxyRegistry (address _proxyRegistryAddress) external;

  function balanceOf (address _owner, uint256 _id) external view returns (uint256);

  function balanceOfBatch (address[] memory _owners, uint256[] memory _ids) external view returns (uint256[] memory);

  function isApprovedForAll (address _owner, address _operator) external view returns (bool);

  function setApprovalForAll (address _operator, bool _approved) external;

  function safeTransferFrom (address _from, address _to, uint256 _id, uint256 _amount, bytes memory _data) external;

  function safeBatchTransferFrom (address _from, address _to, uint256[] memory _ids, uint256[] memory _amounts, bytes memory _data) external;

  function configureGroup (uint256 _groupId, DFStorage.ItemGroupInput calldata _data) external;

  function mintBatch (address _recipient, uint256[] memory _ids, uint256[] memory _amounts, bytes memory _data) external;

  function burn (address _burner, uint256 _id, uint256 _amount) external;

  function burnBatch (address _burner, uint256[] memory _ids, uint256[] memory _amounts) external;

  function setMetadata (uint256 _id, string memory _metadata) external;

  function lockURI(string calldata _uri) external;


  function lockURI(string calldata _uri, uint256 _id) external;



  function lockGroupURI(string calldata _uri, uint256 groupId) external;


  function lock() external;

}// GPL-3.0
pragma solidity ^0.8.8;

interface ISuper721 {


    function balanceOfGroup(address _owner, uint256 _id) external view returns (uint256);


    function balanceOf(address _owner) external view returns (uint256);


    function balanceOfBatch(address[] calldata _owners, uint256[] calldata _ids)
        external
        view
        returns (uint256[] memory);

}// GPL-3.0
pragma solidity 0.8.8;

interface IStaker {


    function spendPoints(address _user, uint256 _amount) external;


    function getAvailablePoints(address _user) external view returns (uint256);

}// GPL-3.0
pragma solidity 0.8.8;


interface IMintShop {


    function addPool(
        DFStorage.PoolInput calldata _pool,
        uint256[] calldata _groupIds,
        uint256[] calldata _issueNumberOffsets,
        uint256[] calldata _caps,
        DFStorage.Price[][] memory _prices
    ) external;


    function addWhiteList(uint256 _poolId, DFStorage.WhiteListCreate[] calldata whitelist) external;


    function setItems(ISuper1155[] memory _items) external;


    function SET_ITEMS() external view returns (bytes32); 


    function POOL() external view returns (bytes32); 


    function WHITELIST() external view returns (bytes32); 


}// GPL-3.0
pragma solidity ^0.8.7;


abstract contract MerkleCore is Sweepable {

  function getRootHash(uint256 _index, bytes32 _node,
  bytes32[] calldata _merkleProof) internal pure returns(bytes32) {

    uint256 path = _index;
    for (uint256 i = 0; i < _merkleProof.length; i++) {
      if ((path & 0x01) == 1) {
          _node = keccak256(abi.encodePacked(_merkleProof[i], _node));
      } else {
          _node = keccak256(abi.encodePacked(_node, _merkleProof[i]));
      }
      path /= 2;
    }
    return _node;
  }
}// GPL-3.0
pragma solidity 0.8.8;

interface IMerkle {


   function setAccessRound(uint256 _accesslistId, bytes32 _merkleRoot,
  uint256 _startTime, uint256 _endTime, uint256 _price, address _token) external;


}// GPL-3.0
pragma solidity ^0.8.7;


abstract contract SuperMerkleAccess is MerkleCore {

  bytes32 public constant SET_ACCESS_ROUND = keccak256("SET_ACCESS_ROUND");

  struct AccessList {
    bytes32 merkleRoot;
    uint256 startTime;
    uint256 endTime;
    uint256 round;
    uint256 price;
    address token;
  }

  mapping (uint256 => AccessList) public accessRoots;

  function setAccessRound(uint256 _accesslistId, bytes32 _merkleRoot,
  uint256 _startTime, uint256 _endTime, uint256 _price, address _token) public virtual
  hasValidPermit(UNIVERSAL, SET_ACCESS_ROUND) {

    AccessList memory accesslist = AccessList({
      merkleRoot: _merkleRoot,
      startTime: _startTime,
      endTime: _endTime,
      round: accessRoots[_accesslistId].round + 1,
      price: _price,
      token: _token
    });
    accessRoots[_accesslistId] = accesslist;
  }

  function verify(uint256 _accesslistId, uint256 _index, bytes32 _node,
  bytes32[] calldata _merkleProof) public virtual view returns(bool) {
    
    if (accessRoots[_accesslistId].merkleRoot == 0) {
      return false;
    } else if (block.timestamp < accessRoots[_accesslistId].startTime) {
      return false;
    } else if (block.timestamp > accessRoots[_accesslistId].endTime) {
      return false;
    } else if (getRootHash(_index, _node, _merkleProof) != accessRoots[_accesslistId].merkleRoot) {
      return false;
    }
    return true;
  }
}// GPL-3.0
pragma solidity ^0.8.8;



contract MintShop1155 is Sweepable, ReentrancyGuard, IMintShop, SuperMerkleAccess {

  using SafeERC20 for IERC20;


  bytes32 public constant SET_PAYMENT_RECEIVER
    = keccak256("SET_PAYMENT_RECEIVER");

  bytes32 public constant LOCK_PAYMENT_RECEIVER
    = keccak256("LOCK_PAYMENT_RECEIVER");

  bytes32 public constant UPDATE_GLOBAL_LIMIT
    = keccak256("UPDATE_GLOBAL_LIMIT");

  bytes32 public constant LOCK_GLOBAL_LIMIT = keccak256("LOCK_GLOBAL_LIMIT");

  bytes32 public constant WHITELIST = keccak256("WHITELIST");

  bytes32 public constant POOL = keccak256("POOL");

  bytes32 public constant SET_ITEMS = keccak256("SET_ITEMS");

  uint256 constant GROUP_MASK = uint256(type(uint128).max) << 128;


  uint256 public immutable maxAllocation;

  ISuper1155[] public items;

  address public paymentReceiver;

  bool public paymentReceiverLocked;

  uint256 public globalPurchaseLimit;

  bool public globalPurchaseLimitLocked;

  mapping (address => uint256) public globalPurchaseCounts;

  uint256 public nextPoolId;

  mapping (uint256 => Pool) public pools;

  mapping (bytes32 => uint256) public nextItemIssues;

  struct Pool {
    uint256 currentPoolVersion;
    DFStorage.PoolInput config;
    mapping (address => uint256) purchaseCounts;
    mapping (bytes32 => uint256) itemCaps;
    mapping (bytes32 => uint256) itemMinted;
    mapping (bytes32 => uint256) itemPricesLength;
    mapping (bytes32 => mapping (uint256 => DFStorage.Price)) itemPrices;
    uint256[] itemGroups;
    Whitelist[] whiteLists;
  }

  struct Whitelist {
    uint256 id;
    mapping (address => uint256) minted;
  }



  struct PoolItem {
    uint256 groupId;
    uint256 cap;
    uint256 minted;
    DFStorage.Price[] prices;
  }

  struct PoolOutput {
    DFStorage.PoolInput config;
    string itemMetadataUri;
    PoolItem[] items;
  }


  event PaymentReceiverUpdated(address indexed updater,
    address indexed oldPaymentReceiver, address indexed newPaymentReceiver);

  event PaymentReceiverLocked(address indexed locker);

  event GlobalPurchaseLimitUpdated(address indexed updater,
    uint256 indexed oldPurchaseLimit, uint256 indexed newPurchaseLimit);

  event GlobalPurchaseLimitLocked(address indexed locker);

  event WhitelistUpdated(address indexed updater, uint256 whitelistId,
    uint256 timestamp);

  event PoolUpdated(address indexed updater, uint256 poolId,
    DFStorage.PoolInput indexed pool, uint256[] groupIds, uint256[] caps,
    DFStorage.Price[][] indexed prices);

  event ItemPurchased(address indexed buyer, uint256 poolId,
    uint256[] indexed itemIds, uint256[] amounts);

  constructor(address _owner, address _paymentReceiver,
    uint256 _globalPurchaseLimit, uint256 _maxAllocation) {

    if (_owner != owner()) {
      transferOwnership(_owner);
    }
    paymentReceiver = _paymentReceiver;
    globalPurchaseLimit = _globalPurchaseLimit;
    maxAllocation = _maxAllocation;
  }

  function updatePaymentReceiver(address _newPaymentReceiver) external
    hasValidPermit(UNIVERSAL, SET_PAYMENT_RECEIVER) {

    require(!paymentReceiverLocked, "XXX"
      );
    emit PaymentReceiverUpdated(_msgSender(), paymentReceiver,
      _newPaymentReceiver);
    paymentReceiver = _newPaymentReceiver;

  }


  function setItems(ISuper1155[] calldata _items) external hasValidPermit(UNIVERSAL, SET_ITEMS) {

    items = _items;
  }

  function lockPaymentReceiver() external
    hasValidPermit(UNIVERSAL, LOCK_PAYMENT_RECEIVER) {

    paymentReceiverLocked = true;
    emit PaymentReceiverLocked(_msgSender());
  }

  function updateGlobalPurchaseLimit(uint256 _newGlobalPurchaseLimit) external
    hasValidPermit(UNIVERSAL, UPDATE_GLOBAL_LIMIT) {

    require(!globalPurchaseLimitLocked,
      "0x0A");
    emit GlobalPurchaseLimitUpdated(_msgSender(), globalPurchaseLimit,
      _newGlobalPurchaseLimit);
    globalPurchaseLimit = _newGlobalPurchaseLimit;

  }

  function lockGlobalPurchaseLimit() external
    hasValidPermit(UNIVERSAL, LOCK_GLOBAL_LIMIT) {

    globalPurchaseLimitLocked = true;
    emit GlobalPurchaseLimitLocked(_msgSender());
  }

  function addWhiteList(uint256 _poolId, DFStorage.WhiteListCreate[] calldata whitelist) external hasValidPermit(UNIVERSAL, WHITELIST) {

    for (uint256 i = 0; i < whitelist.length; i++) {
      super.setAccessRound(whitelist[i]._accesslistId, whitelist[i]._merkleRoot, whitelist[i]._startTime, whitelist[i]._endTime, whitelist[i]._price, whitelist[i]._token);
      pools[_poolId].whiteLists.push();
      uint256 newIndex = pools[_poolId].whiteLists.length - 1;
      pools[_poolId].whiteLists[newIndex].id = whitelist[i]._accesslistId;
      emit WhitelistUpdated(_msgSender(), whitelist[i]._accesslistId, block.timestamp);
    }
  }


  function getPools(uint256[] calldata _ids, uint256 _itemIndex) external view
    returns (PoolOutput[] memory) {

    PoolOutput[] memory poolOutputs = new PoolOutput[](_ids.length);
    for (uint256 i = 0; i < _ids.length; i++) {
      uint256 id = _ids[i];

      PoolItem[] memory poolItems = new PoolItem[](pools[id].itemGroups.length);
      for (uint256 j = 0; j < pools[id].itemGroups.length; j++) {
        uint256 itemGroupId = pools[id].itemGroups[j];
        bytes32 itemKey = keccak256(abi.encodePacked(pools[id].config.collection,
          pools[id].currentPoolVersion, itemGroupId));

        DFStorage.Price[] memory itemPrices =
          new DFStorage.Price[](pools[id].itemPricesLength[itemKey]);
        for (uint256 k = 0; k < pools[id].itemPricesLength[itemKey]; k++) {
          itemPrices[k] = pools[id].itemPrices[itemKey][k];
        }

        poolItems[j] = PoolItem({
          groupId: itemGroupId,
          cap: pools[id].itemCaps[itemKey],
          minted: pools[id].itemMinted[itemKey],
          prices: itemPrices
        });
      }

      poolOutputs[i] = PoolOutput({
        config: pools[id].config,
        itemMetadataUri: items[_itemIndex].metadataUri(),
        items: poolItems
      });
    }

    return poolOutputs;
  }

  function getPurchaseCounts(address[] calldata _purchasers,
  uint256[] calldata _ids) external view returns (uint256[][] memory) {

    uint256[][] memory purchaseCounts = new uint256[][](_purchasers.length);
    for (uint256 i = 0; i < _purchasers.length; i++) {
      purchaseCounts[i] = new uint256[](_ids.length);
      for (uint256 j = 0; j < _ids.length; j++) {
        uint256 id = _ids[j];
        address purchaser = _purchasers[i];
        purchaseCounts[i][j] = pools[id].purchaseCounts[purchaser];
      }
    }
    return purchaseCounts;
  }








  function addPool(DFStorage.PoolInput calldata _pool, uint256[] calldata _groupIds,
    uint256[] calldata _issueNumberOffsets, uint256[] calldata _caps,
    DFStorage.Price[][] calldata _prices) external hasValidPermit(UNIVERSAL, POOL) {

    updatePool(nextPoolId, _pool, _groupIds, _issueNumberOffsets, _caps,
      _prices);

    nextPoolId += 1;
  }

  function updatePool(uint256 _id, DFStorage.PoolInput calldata _config,
    uint256[] calldata _groupIds, uint256[] calldata _issueNumberOffsets,
    uint256[] calldata _caps, DFStorage.Price[][] memory _prices) public
    hasValidPermit(UNIVERSAL, POOL) {

    require(_id <= nextPoolId && _config.endTime >= _config.startTime && _groupIds.length > 0,
      "0x1A");
    require(_groupIds.length == _caps.length && _caps.length == _prices.length && _issueNumberOffsets.length == _prices.length,
      "0x4A");

    Pool storage pool = pools[_id];
    pool.config = _config;
    pool.itemGroups = _groupIds;
    pool.currentPoolVersion = pools[_id].currentPoolVersion + 1;

    _updatePoolHelper(_id, _groupIds, _issueNumberOffsets, _caps, _prices);

    emit PoolUpdated(_msgSender(), _id, _config, _groupIds, _caps, _prices);
  }

  function _updatePoolHelper(uint256 _id,
    uint256[] calldata _groupIds, uint256[] calldata _issueNumberOffsets,
    uint256[] calldata _caps, DFStorage.Price[][] memory _prices) private {

    for (uint256 i = 0; i < _groupIds.length; i++) {
      require(_caps[i] > 0,
        "0x5A");
      bytes32 itemKey = keccak256(abi.encodePacked(pools[_id].config.collection, pools[_id].currentPoolVersion, _groupIds[i]));
      pools[_id].itemCaps[itemKey] = _caps[i];

      bytes32 key = keccak256(abi.encodePacked(pools[_id].config.collection, _groupIds[i]));
      nextItemIssues[key] = _issueNumberOffsets[i];

      for (uint256 j = 0; j < _prices[i].length; j++) {
        pools[_id].itemPrices[itemKey][j] = _prices[i][j];
      }
      pools[_id].itemPricesLength[itemKey] = _prices[i].length;
    }
  }

  function updatePoolConfig(uint256 _id, DFStorage.PoolInput calldata _config) external hasValidPermit(UNIVERSAL, POOL){

    require(_id <= nextPoolId && _config.endTime >= _config.startTime,
      "0x1A");
    pools[_id].config = _config;
  }

  function mintFromPool(uint256 _id, uint256 _groupId, uint256 _assetIndex,
    uint256 _amount, uint256 _itemIndex, DFStorage.WhiteListInput calldata _whiteList) external nonReentrant payable {

    require(_amount > 0,
      "0x0B");
    require(_id < nextPoolId && pools[_id].config.singlePurchaseLimit >= _amount,
      "0x1B");

    bool whiteListed;
    if (pools[_id].whiteLists.length != 0)
    {
        bytes32 root = keccak256(abi.encodePacked(_whiteList.index, _msgSender(), _whiteList.allowance));
        whiteListed = super.verify(_whiteList.whiteListId, _whiteList.index, root, _whiteList.merkleProof) &&
                                root == _whiteList.node &&
                                pools[_id].whiteLists[_whiteList.whiteListId].minted[_msgSender()] + _amount <= _whiteList.allowance;
    }

    require(block.timestamp >= pools[_id].config.startTime && block.timestamp <= pools[_id].config.endTime || whiteListed, "0x4B");

    bytes32 itemKey = keccak256(abi.encodePacked(pools[_id].config.collection,
       pools[_id].currentPoolVersion, _groupId));
    require(_assetIndex < pools[_id].itemPricesLength[itemKey],
      "0x3B");



    uint256 userGlobalPurchaseAmount =
        _amount + globalPurchaseCounts[_msgSender()];


    if (globalPurchaseLimit != 0) {
      require(userGlobalPurchaseAmount <= globalPurchaseLimit,
        "0x5B");

    }
    uint256 userPoolPurchaseAmount =
        _amount + pools[_id].purchaseCounts[_msgSender()];

    uint256 newCirculatingTotal = pools[_id].itemMinted[itemKey] + _amount;
    require(newCirculatingTotal <= pools[_id].itemCaps[itemKey],
      "0x7B");

    {
        uint256 result;
        for (uint256 i = 0; i < nextPoolId; i++) {
            for (uint256 j = 0; j < pools[i].itemGroups.length; j++) {
                result += pools[i].itemMinted[itemKey];
            }
        }
        require(maxAllocation >= result + _amount, "0x0D");
    }

    require(checkRequirments(_id), "0x8B");

    sellingHelper(_id, itemKey, _assetIndex, _amount, whiteListed, _whiteList.whiteListId);


    mintingHelper(_itemIndex, _groupId, _id, itemKey, _amount, newCirculatingTotal, userPoolPurchaseAmount, userGlobalPurchaseAmount);

  }

  function remainder(DFStorage.WhiteListInput calldata _whiteList, uint256 _id, address _user) public view returns (uint256) {

      return (pools[_id].whiteLists[_whiteList.whiteListId].minted[_user] < _whiteList.allowance) ? _whiteList.allowance - pools[_id].whiteLists[_whiteList.whiteListId].minted[_user] : 0;
  }

  function isEligible(DFStorage.WhiteListInput calldata _whiteList, uint256 _id) public view returns (bool) {

    return  (super.verify(_whiteList.whiteListId, _whiteList.index, keccak256(abi.encodePacked(_whiteList.index, _msgSender(), _whiteList.allowance)), _whiteList.merkleProof)) &&
                    pools[_id].whiteLists[_whiteList.whiteListId].minted[_msgSender()] < _whiteList.allowance ||
                    (block.timestamp >= pools[_id].config.startTime && block.timestamp <= pools[_id].config.endTime);
  }

  function sellingHelper(uint256 _id, bytes32 itemKey, uint256 _assetIndex, uint256 _amount, bool _whiteListPrice, uint256 _accesListId) private {

    if (_whiteListPrice) {
      SuperMerkleAccess.AccessList storage accessList = SuperMerkleAccess.accessRoots[_accesListId];
      uint256 price = accessList.price * _amount;
      if (accessList.token == address(0)) {
        require(msg.value >= price,
          "0x9B");
        (bool success, ) = payable(paymentReceiver).call{ value: msg.value }("");
        require(success,
          "0x0C");
        pools[_id].whiteLists[_accesListId].minted[_msgSender()] += _amount;
      } else {
        require(IERC20(accessList.token).balanceOf(_msgSender()) >= price,
          "0x1C");
        IERC20(accessList.token).safeTransferFrom(_msgSender(), paymentReceiver, price);
        pools[_id].whiteLists[_accesListId].minted[_msgSender()] += _amount;
      }
    } else {
      DFStorage.Price storage sellingPair = pools[_id].itemPrices[itemKey][_assetIndex];
      if (sellingPair.assetType == DFStorage.AssetType.Point) {
        IStaker(sellingPair.asset).spendPoints(_msgSender(),
          sellingPair.price * _amount);

      } else if (sellingPair.assetType == DFStorage.AssetType.Ether) {
        uint256 etherPrice = sellingPair.price * _amount;
        require(msg.value >= etherPrice,
          "0x9B");
        (bool success, ) = payable(paymentReceiver).call{ value: msg.value }("");
        require(success,
          "0x0C");

      } else if (sellingPair.assetType == DFStorage.AssetType.Token) {
        uint256 tokenPrice = sellingPair.price * _amount;
        require(IERC20(sellingPair.asset).balanceOf(_msgSender()) >= tokenPrice,
          "0x1C");
        IERC20(sellingPair.asset).safeTransferFrom(_msgSender(), paymentReceiver, tokenPrice);

      } else {
        revert("0x0");
      }
    }
  }

  function checkRequirments(uint256 _id) private view returns (bool) {

    uint256 amount;

    DFStorage.PoolRequirement memory poolRequirement = pools[_id].config.requirement;
    if (poolRequirement.requiredType == DFStorage.AccessType.TokenRequired) {
      for (uint256 i = 0; i < poolRequirement.requiredAsset.length; i++) {
        amount += IERC20(poolRequirement.requiredAsset[i]).balanceOf(_msgSender());
      }
      return amount >= poolRequirement.requiredAmount;
    } else if (poolRequirement.requiredType == DFStorage.AccessType.PointRequired) {
       return IStaker(poolRequirement.requiredAsset[0]).getAvailablePoints(_msgSender())
          >= poolRequirement.requiredAmount;
    }

    if (poolRequirement.requiredId.length == 0) {
      if (poolRequirement.requiredType == DFStorage.AccessType.ItemRequired) {
        for (uint256 i = 0; i < poolRequirement.requiredAsset.length; i++) {
            amount += ISuper1155(poolRequirement.requiredAsset[i]).totalBalances(_msgSender());
        }
        return amount >= poolRequirement.requiredAmount;
      }
      else if (poolRequirement.requiredType == DFStorage.AccessType.ItemRequired721) {
        for (uint256 i = 0; i < poolRequirement.requiredAsset.length; i++) {
            amount += ISuper721(poolRequirement.requiredAsset[i]).balanceOf(_msgSender());
        }
        return amount >= poolRequirement.requiredAmount;
      }
    } else {
      if (poolRequirement.requiredType == DFStorage.AccessType.ItemRequired) {
        for (uint256 i = 0; i < poolRequirement.requiredAsset.length; i++) {
          for (uint256 j = 0; j < poolRequirement.requiredAsset.length; j++) {
            amount += ISuper1155(poolRequirement.requiredAsset[i]).balanceOf(_msgSender(), poolRequirement.requiredId[j]);
          }
        }
        return amount >= poolRequirement.requiredAmount;
      }
      else if (poolRequirement.requiredType == DFStorage.AccessType.ItemRequired721) {
        for (uint256 i = 0; i < poolRequirement.requiredAsset.length; i++) {
            for (uint256 j = 0; j < poolRequirement.requiredAsset.length; j++) {
              amount += ISuper721(poolRequirement.requiredAsset[i]).balanceOfGroup(_msgSender(), poolRequirement.requiredId[j]);
            }
        }
        return amount >= poolRequirement.requiredAmount;
    }
  }
  return true;
}


  function mintingHelper(uint256 _itemIndex, uint256 _groupId, uint256 _id, bytes32 _itemKey, uint256 _amount, uint256 _newCirculatingTotal, uint256 _userPoolPurchaseAmount, uint256 _userGlobalPurchaseAmount) private {

    uint256[] memory itemIds = new uint256[](_amount);
    uint256[] memory amounts = new uint256[](_amount);
    bytes32 key = keccak256(abi.encodePacked(pools[_id].config.collection,
       pools[_id].currentPoolVersion, _groupId));
    uint256 nextIssueNumber = nextItemIssues[key];
    {
      uint256 shiftedGroupId = _groupId << 128;

      for (uint256 i = 1; i <= _amount; i++) {
        uint256 itemId = (shiftedGroupId + nextIssueNumber) + i;
        itemIds[i - 1] = itemId;
        amounts[i - 1] = 1;
      }
    }
    nextItemIssues[key] = nextIssueNumber + _amount;

    pools[_id].itemMinted[_itemKey] = _newCirculatingTotal;

    pools[_id].purchaseCounts[_msgSender()] = _userPoolPurchaseAmount;

    globalPurchaseCounts[_msgSender()] = _userGlobalPurchaseAmount;



    items[_itemIndex].mintBatch(_msgSender(), itemIds, amounts, "");

    emit ItemPurchased(_msgSender(), _id, itemIds, amounts);
  }

}