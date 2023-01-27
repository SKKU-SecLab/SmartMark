
pragma solidity >=0.6.0 <0.8.0;

interface IERC165 {

    function supportsInterface(bytes4 interfaceId) external view returns (bool);

}// MIT

pragma solidity >=0.6.0 <0.8.0;


abstract contract ERC165 is IERC165 {
    bytes4 private constant _INTERFACE_ID_ERC165 = 0x01ffc9a7;

    mapping(bytes4 => bool) private _supportedInterfaces;

    constructor () internal {
        _registerInterface(_INTERFACE_ID_ERC165);
    }

    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return _supportedInterfaces[interfaceId];
    }

    function _registerInterface(bytes4 interfaceId) internal virtual {
        require(interfaceId != 0xffffffff, "ERC165: invalid interface id");
        _supportedInterfaces[interfaceId] = true;
    }
}// MIT

pragma solidity >=0.6.2 <0.8.0;


interface IERC1155 is IERC165 {

    event TransferSingle(address indexed operator, address indexed from, address indexed to, uint256 id, uint256 value);

    event TransferBatch(address indexed operator, address indexed from, address indexed to, uint256[] ids, uint256[] values);

    event ApprovalForAll(address indexed account, address indexed operator, bool approved);

    event URI(string value, uint256 indexed id);

    function balanceOf(address account, uint256 id) external view returns (uint256);


    function balanceOfBatch(address[] calldata accounts, uint256[] calldata ids) external view returns (uint256[] memory);


    function setApprovalForAll(address operator, bool approved) external;


    function isApprovedForAll(address account, address operator) external view returns (bool);


    function safeTransferFrom(address from, address to, uint256 id, uint256 amount, bytes calldata data) external;


    function safeBatchTransferFrom(address from, address to, uint256[] calldata ids, uint256[] calldata amounts, bytes calldata data) external;

}// MIT

pragma solidity >=0.6.2 <0.8.0;


interface IERC1155MetadataURI is IERC1155 {

    function uri(uint256 id) external view returns (string memory);

}// MIT

pragma solidity >=0.6.0 <0.8.0;


interface IERC1155Receiver is IERC165 {


    function onERC1155Received(
        address operator,
        address from,
        uint256 id,
        uint256 value,
        bytes calldata data
    )
        external
        returns(bytes4);


    function onERC1155BatchReceived(
        address operator,
        address from,
        uint256[] calldata ids,
        uint256[] calldata values,
        bytes calldata data
    )
        external
        returns(bytes4);

}// MIT

pragma solidity >=0.6.0 <0.8.0;

library SafeMath {

    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        uint256 c = a + b;
        if (c < a) return (false, 0);
        return (true, c);
    }

    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        if (b > a) return (false, 0);
        return (true, a - b);
    }

    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        if (a == 0) return (true, 0);
        uint256 c = a * b;
        if (c / a != b) return (false, 0);
        return (true, c);
    }

    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        if (b == 0) return (false, 0);
        return (true, a / b);
    }

    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        if (b == 0) return (false, 0);
        return (true, a % b);
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {

        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");
        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b <= a, "SafeMath: subtraction overflow");
        return a - b;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {

        if (a == 0) return 0;
        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");
        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b > 0, "SafeMath: division by zero");
        return a / b;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b > 0, "SafeMath: modulo by zero");
        return a % b;
    }

    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        require(b <= a, errorMessage);
        return a - b;
    }

    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        require(b > 0, errorMessage);
        return a / b;
    }

    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        require(b > 0, errorMessage);
        return a % b;
    }
}// MIT

pragma solidity >=0.6.2 <0.8.0;

library Address {

    function isContract(address account) internal view returns (bool) {


        uint256 size;
        assembly { size := extcodesize(account) }
        return size > 0;
    }

    function sendValue(address payable recipient, uint256 amount) internal {

        require(address(this).balance >= amount, "Address: insufficient balance");

        (bool success, ) = recipient.call{ value: amount }("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    function functionCall(address target, bytes memory data) internal returns (bytes memory) {

      return functionCall(target, data, "Address: low-level call failed");
    }

    function functionCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {

        return functionCallWithValue(target, data, 0, errorMessage);
    }

    function functionCallWithValue(address target, bytes memory data, uint256 value) internal returns (bytes memory) {

        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    function functionCallWithValue(address target, bytes memory data, uint256 value, string memory errorMessage) internal returns (bytes memory) {

        require(address(this).balance >= value, "Address: insufficient balance for call");
        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{ value: value }(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {

        return functionStaticCall(target, data, "Address: low-level static call failed");
    }

    function functionStaticCall(address target, bytes memory data, string memory errorMessage) internal view returns (bytes memory) {

        require(isContract(target), "Address: static call to non-contract");

        (bool success, bytes memory returndata) = target.staticcall(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {

        return functionDelegateCall(target, data, "Address: low-level delegate call failed");
    }

    function functionDelegateCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {

        require(isContract(target), "Address: delegate call to non-contract");

        (bool success, bytes memory returndata) = target.delegatecall(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function _verifyCallResult(bool success, bytes memory returndata, string memory errorMessage) private pure returns(bytes memory) {

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

pragma solidity >=0.6.0 <0.8.0;

abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}// MIT

pragma solidity >=0.6.0 <0.8.0;

abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor () internal {
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
}// GPL-3.0
pragma solidity 0.7.6;
pragma experimental ABIEncoderV2;


abstract contract PermitControl is Ownable {
  using SafeMath for uint256;
  using Address for address;

  bytes32 public constant ZERO_RIGHT = hex"00000000000000000000000000000000";

  bytes32 public constant UNIVERSAL = hex"FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF";

  bytes32 public constant MANAGER = hex"FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF";

  mapping (address => mapping (bytes32 => mapping (bytes32 => uint256))) public
    permissions;

  mapping (bytes32 => bytes32) public managerRight;

  event PermitUpdated(address indexed updator, address indexed updatee,
    bytes32 circumstance, bytes32 indexed role, uint256 expirationTime);

  event ManagementUpdated(address indexed manager, bytes32 indexed managedRight,
    bytes32 indexed managerRight);

  modifier hasValidPermit(bytes32 _circumstance, bytes32 _right) {
    require(_msgSender() == owner()
      || hasRightUntil(_msgSender(), _circumstance, _right) > block.timestamp,
      "PermitControl: sender does not have a valid permit");
    _;
  }

  function version() external virtual pure returns (uint256) {
    return 1;
  }

  function hasRightUntil(address _address, bytes32 _circumstance,
    bytes32 _right) public view returns (uint256) {
    return permissions[_address][_circumstance][_right];
  }

  function setPermit(address _address, bytes32 _circumstance, bytes32 _right,
    uint256 _expirationTime) external virtual hasValidPermit(UNIVERSAL,
    managerRight[_right]) {
    require(_right != ZERO_RIGHT,
      "PermitControl: you may not grant the zero right");
    permissions[_address][_circumstance][_right] = _expirationTime;
    emit PermitUpdated(_msgSender(), _address, _circumstance, _right,
      _expirationTime);
  }

  function setManagerRight(bytes32 _managedRight, bytes32 _managerRight)
    external virtual hasValidPermit(UNIVERSAL, MANAGER) {
    require(_managedRight != ZERO_RIGHT,
      "PermitControl: you may not specify a manager for the zero right");
    managerRight[_managedRight] = _managerRight;
    emit ManagementUpdated(_msgSender(), _managedRight, _managerRight);
  }
}// GPL-3.0
pragma solidity 0.7.6;

abstract contract StubProxyRegistry {

  mapping(address => address) public proxies;
}// GPL-3.0
pragma solidity 0.7.6;



contract Super1155 is PermitControl, ERC165, IERC1155, IERC1155MetadataURI {

  using Address for address;
  using SafeMath for uint256;

  bytes32 public constant SET_URI = keccak256("SET_URI");

  bytes32 public constant SET_PROXY_REGISTRY = keccak256("SET_PROXY_REGISTRY");

  bytes32 public constant CONFIGURE_GROUP = keccak256("CONFIGURE_GROUP");

  bytes32 public constant MINT = keccak256("MINT");

  bytes32 public constant BURN = keccak256("BURN");

  bytes32 public constant SET_METADATA = keccak256("SET_METADATA");

  bytes32 public constant LOCK_URI = keccak256("LOCK_URI");

  bytes32 public constant LOCK_ITEM_URI = keccak256("LOCK_ITEM_URI");

  bytes32 public constant LOCK_CREATION = keccak256("LOCK_CREATION");

  bytes4 private constant INTERFACE_ERC1155 = 0xd9b67a26;

  bytes4 private constant INTERFACE_ERC1155_METADATA_URI = 0x0e89341c;

  uint256 private constant GROUP_MASK = uint256(uint128(~0)) << 128;

  string public name;

  string public metadataUri;

  address public proxyRegistryAddress;

  mapping (uint256 => mapping(address => uint256)) private balances;

  mapping (uint256 => mapping(address => uint256)) public groupBalances;

  mapping(address => uint256) public totalBalances;

  mapping (address => mapping(address => bool)) private operatorApprovals;

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
    string name;
    SupplyType supplyType;
    uint256 supplyData;
    ItemType itemType;
    uint256 itemData;
    BurnType burnType;
    uint256 burnData;
  }

  struct ItemGroup {
    bool initialized;
    string name;
    SupplyType supplyType;
    uint256 supplyData;
    ItemType itemType;
    uint256 itemData;
    BurnType burnType;
    uint256 burnData;
    uint256 circulatingSupply;
    uint256 mintCount;
    uint256 burnCount;
  }

  mapping (uint256 => ItemGroup) public itemGroups;

  mapping (uint256 => uint256) public circulatingSupply;

  mapping (uint256 => uint256) public mintCount;

  mapping (uint256 => uint256) public burnCount;

  mapping (uint256 => bool) public metadataFrozen;

  mapping (uint256 => string) public metadata;

  bool public uriLocked;

  bool public locked;

  event ChangeURI(string indexed oldURI, string indexed newURI);

  event ChangeProxyRegistry(address indexed oldRegistry,
    address indexed newRegistry);

  event ItemGroupConfigured(address indexed manager, uint256 groupId,
    ItemGroupInput indexed newGroup);

  event CollectionLocked(address indexed locker);

  event MetadataChanged(address indexed changer, uint256 indexed id,
    string oldMetadata, string indexed newMetadata);

  event PermanentURI(string _value, uint256 indexed _id);

  modifier hasItemRight(uint256 _id, bytes32 _right) {

    uint256 groupId = (_id & GROUP_MASK) >> 128;
    if (_msgSender() == owner()) {
      _;
    } else if (hasRightUntil(_msgSender(), UNIVERSAL, _right)
      > block.timestamp) {
      _;
    } else if (hasRightUntil(_msgSender(), bytes32(groupId), _right)
      > block.timestamp) {
      _;
    } else if (hasRightUntil(_msgSender(), bytes32(_id), _right)
      > block.timestamp) {
      _;
    }
  }

  constructor(address _owner, string memory _name, string memory _uri,
    address _proxyRegistryAddress) public {

    _registerInterface(INTERFACE_ERC1155);
    _registerInterface(INTERFACE_ERC1155_METADATA_URI);

    if (_owner != owner()) {
      transferOwnership(_owner);
    }

    name = _name;
    metadataUri = _uri;
    proxyRegistryAddress = _proxyRegistryAddress;
  }

  function version() external virtual override pure returns (uint256) {

    return 1;
  }

  function uri(uint256) external override view returns (string memory) {

    return metadataUri;
  }

  function setURI(string calldata _uri) external virtual
    hasValidPermit(UNIVERSAL, SET_URI) {

    require(!uriLocked,
      "Super1155: the collection URI has been permanently locked");
    string memory oldURI = metadataUri;
    metadataUri = _uri;
    emit ChangeURI(oldURI, _uri);
  }

  function setProxyRegistry(address _proxyRegistryAddress) external virtual
    hasValidPermit(UNIVERSAL, SET_PROXY_REGISTRY) {

    address oldRegistry = proxyRegistryAddress;
    proxyRegistryAddress = _proxyRegistryAddress;
    emit ChangeProxyRegistry(oldRegistry, _proxyRegistryAddress);
  }

  function balanceOf(address _owner, uint256 _id) public override view virtual
  returns (uint256) {

    require(_owner != address(0),
      "ERC1155: balance query for the zero address");
    return balances[_id][_owner];
  }

  function balanceOfBatch(address[] calldata _owners, uint256[] calldata _ids)
    external override view virtual returns (uint256[] memory) {

    require(_owners.length == _ids.length,
      "ERC1155: accounts and ids length mismatch");

    uint256[] memory batchBalances = new uint256[](_owners.length);
    for (uint256 i = 0; i < _owners.length; ++i) {
      batchBalances[i] = balanceOf(_owners[i], _ids[i]);
    }
    return batchBalances;
  }

  function isApprovedForAll(address _owner, address _operator) public override
    view virtual returns (bool) {

    StubProxyRegistry proxyRegistry = StubProxyRegistry(proxyRegistryAddress);
    if (address(proxyRegistry.proxies(_owner)) == _operator) {
      return true;
    }

    return operatorApprovals[_owner][_operator];
  }

  function setApprovalForAll(address _operator, bool _approved) external
    override virtual {

    require(_msgSender() != _operator,
      "ERC1155: setting approval status for self");
    operatorApprovals[_msgSender()][_operator] = _approved;
    emit ApprovalForAll(_msgSender(), _operator, _approved);
  }

  function _asSingletonArray(uint256 _element) private pure
    returns (uint256[] memory) {

    uint256[] memory array = new uint256[](1);
    array[0] = _element;
    return array;
  }

  function _beforeTokenTransfer(address _operator, address _from, address _to,
    uint256[] memory _ids, uint256[] memory _amounts, bytes memory _data)
    internal virtual {

  }

  function _doSafeTransferAcceptanceCheck(address _operator, address _from,
    address _to, uint256 _id, uint256 _amount, bytes calldata _data) private {

    if (_to.isContract()) {
      try IERC1155Receiver(_to).onERC1155Received(_operator, _from, _id,
        _amount, _data) returns (bytes4 response) {
        if (response != IERC1155Receiver(_to).onERC1155Received.selector) {
          revert("ERC1155: ERC1155Receiver rejected tokens");
        }
      } catch Error(string memory reason) {
        revert(reason);
      } catch {
        revert("ERC1155: transfer to non ERC1155Receiver implementer");
      }
    }
  }

  function safeTransferFrom(address _from, address _to, uint256 _id,
    uint256 _amount, bytes calldata _data) external override virtual {

    require(_to != address(0),
      "ERC1155: transfer to the zero address");
    require(_from == _msgSender() || isApprovedForAll(_from, _msgSender()),
      "ERC1155: caller is not owner nor approved");

    address operator = _msgSender();
    _beforeTokenTransfer(operator, _from, _to, _asSingletonArray(_id),
    _asSingletonArray(_amount), _data);

    uint256 shiftedGroupId = (_id & GROUP_MASK);
    uint256 groupId = shiftedGroupId >> 128;

    balances[_id][_from] = balances[_id][_from].sub(_amount,
      "ERC1155: insufficient balance for transfer");
    balances[_id][_to] = balances[_id][_to].add(_amount);
    groupBalances[groupId][_from] = groupBalances[groupId][_from].sub(_amount);
    groupBalances[groupId][_to] = groupBalances[groupId][_to].add(_amount);
    totalBalances[_from] = totalBalances[_from].sub(_amount);
    totalBalances[_to] = totalBalances[_to].add(_amount);

    emit TransferSingle(operator, _from, _to, _id, _amount);
    _doSafeTransferAcceptanceCheck(operator, _from, _to, _id, _amount, _data);
  }

  function _doSafeBatchTransferAcceptanceCheck(address _operator, address _from,
    address _to, uint256[] memory _ids, uint256[] memory _amounts, bytes memory
    _data) private {

    if (_to.isContract()) {
      try IERC1155Receiver(_to).onERC1155BatchReceived(_operator, _from, _ids,
        _amounts, _data) returns (bytes4 response) {
        if (response != IERC1155Receiver(_to).onERC1155BatchReceived.selector) {
          revert("ERC1155: ERC1155Receiver rejected tokens");
        }
      } catch Error(string memory reason) {
        revert(reason);
      } catch {
        revert("ERC1155: transfer to non ERC1155Receiver implementer");
      }
    }
  }

  function safeBatchTransferFrom(address _from, address _to,
    uint256[] memory _ids, uint256[] memory _amounts, bytes memory _data)
    external override virtual {

    require(_ids.length == _amounts.length,
      "ERC1155: ids and amounts length mismatch");
    require(_to != address(0),
      "ERC1155: transfer to the zero address");
    require(_from == _msgSender() || isApprovedForAll(_from, _msgSender()),
      "ERC1155: caller is not owner nor approved");

    _beforeTokenTransfer(_msgSender(), _from, _to, _ids, _amounts, _data);
    for (uint256 i = 0; i < _ids.length; ++i) {

      uint256 groupId = (_ids[i] & GROUP_MASK) >> 128;

      balances[_ids[i]][_from] = balances[_ids[i]][_from].sub(_amounts[i],
        "ERC1155: insufficient balance for transfer");
      balances[_ids[i]][_to] = balances[_ids[i]][_to].add(_amounts[i]);
      groupBalances[groupId][_from] = groupBalances[groupId][_from]
        .sub(_amounts[i]);
      groupBalances[groupId][_to] = groupBalances[groupId][_to]
        .add(_amounts[i]);
      totalBalances[_from] = totalBalances[_from].sub(_amounts[i]);
      totalBalances[_to] = totalBalances[_to].add(_amounts[i]);
    }

    emit TransferBatch(_msgSender(), _from, _to, _ids, _amounts);
    _doSafeBatchTransferAcceptanceCheck(_msgSender(), _from, _to, _ids,
      _amounts, _data);
  }

  function configureGroup(uint256 _groupId, ItemGroupInput calldata _data)
    external virtual hasItemRight(_groupId, CONFIGURE_GROUP) {

    require(_groupId != 0,
      "Super1155: group ID 0 is invalid");

    if (!itemGroups[_groupId].initialized) {
      require(!locked,
        "Super1155: the collection is locked so groups cannot be created");
      itemGroups[_groupId] = ItemGroup({
        initialized: true,
        name: _data.name,
        supplyType: _data.supplyType,
        supplyData: _data.supplyData,
        itemType: _data.itemType,
        itemData: _data.itemData,
        burnType: _data.burnType,
        burnData: _data.burnData,
        circulatingSupply: 0,
        mintCount: 0,
        burnCount: 0
      });

    } else {
      itemGroups[_groupId].name = _data.name;

      if (itemGroups[_groupId].supplyType == SupplyType.Capped) {
        require(_data.supplyType == SupplyType.Capped,
          "Super1155: you may not uncap a capped supply type");
        require(_data.supplyData <= itemGroups[_groupId].supplyData,
          "Super1155: you may not increase the supply of a capped type");

      } else {
        itemGroups[_groupId].supplyType = _data.supplyType;
      }

      require(_data.supplyData >= itemGroups[_groupId].circulatingSupply,
        "Super1155: you may not decrease supply below the circulating amount");
      itemGroups[_groupId].supplyData = _data.supplyData;

      if (itemGroups[_groupId].itemType == ItemType.Nonfungible) {
        require(_data.itemType == ItemType.Nonfungible,
          "Super1155: you may not alter nonfungible items");

      } else if (itemGroups[_groupId].itemType == ItemType.Semifungible) {
        require(_data.itemType == ItemType.Semifungible,
          "Super1155: you may not alter nonfungible items");

      } else if (itemGroups[_groupId].itemType == ItemType.Fungible) {
        if (_data.itemType == ItemType.Nonfungible) {
          require(itemGroups[_groupId].circulatingSupply <= 1,
            "Super1155: the fungible item is not unique enough to change");
          itemGroups[_groupId].itemType = ItemType.Nonfungible;

        } else if (_data.itemType == ItemType.Semifungible) {
          require(itemGroups[_groupId].circulatingSupply <= _data.itemData,
            "Super1155: the fungible item is not unique enough to change");
          itemGroups[_groupId].itemType = ItemType.Semifungible;
          itemGroups[_groupId].itemData = _data.itemData;
        }
      }
    }

    emit ItemGroupConfigured(_msgSender(), _groupId, _data);
  }

  function _hasItemRight(uint256 _id, bytes32 _right) private view
    returns (bool) {

    uint256 groupId = (_id & GROUP_MASK) >> 128;
    if (_msgSender() == owner()) {
      return true;
    } else if (hasRightUntil(_msgSender(), UNIVERSAL, _right)
      > block.timestamp) {
      return true;
    } else if (hasRightUntil(_msgSender(), bytes32(groupId), _right)
      > block.timestamp) {
      return true;
    } else if (hasRightUntil(_msgSender(), bytes32(_id), _right)
      > block.timestamp) {
      return true;
    } else {
      return false;
    }
  }

  function _mintChecker(uint256 _id, uint256 _amount) private view
    returns (uint256) {


    uint256 shiftedGroupId = (_id & GROUP_MASK);
    uint256 groupId = shiftedGroupId >> 128;
    require(itemGroups[groupId].initialized,
      "Super1155: you cannot mint a non-existent item group");

    uint256 currentGroupSupply = itemGroups[groupId].mintCount;
    uint256 currentItemSupply = mintCount[_id];
    if (itemGroups[groupId].burnType == BurnType.Replenishable) {
      currentGroupSupply = itemGroups[groupId].circulatingSupply;
      currentItemSupply = circulatingSupply[_id];
    }

    if (itemGroups[groupId].supplyType != SupplyType.Uncapped) {
      require(currentGroupSupply.add(_amount) <= itemGroups[groupId].supplyData,
        "Super1155: you cannot mint a group beyond its cap");
    }

    if (itemGroups[groupId].itemType == ItemType.Nonfungible) {
      require(currentItemSupply.add(_amount) <= 1,
        "Super1155: you cannot mint more than a single nonfungible item");

    } else if (itemGroups[groupId].itemType == ItemType.Semifungible) {
      require(currentItemSupply.add(_amount) <= itemGroups[groupId].itemData,
        "Super1155: you cannot mint more than the alloted semifungible items");
    }

    uint256 mintedItemId = _id;
    if (itemGroups[groupId].itemType == ItemType.Fungible) {
      mintedItemId = shiftedGroupId.add(1);
    }
    return mintedItemId;
  }


  function mintBatch(address _recipient, uint256[] calldata _ids,
    uint256[] calldata _amounts, bytes calldata _data)
    external virtual {

    require(_recipient != address(0),
      "ERC1155: mint to the zero address");
    require(_ids.length == _amounts.length,
      "ERC1155: ids and amounts length mismatch");

    address operator = _msgSender();
    _beforeTokenTransfer(operator, address(0), _recipient, _ids, _amounts,
      _data);

    for (uint256 i = 0; i < _ids.length; i++) {
      require(_hasItemRight(_ids[i], MINT),
        "Super1155: you do not have the right to mint that item");

      uint256 shiftedGroupId = (_ids[i] & GROUP_MASK);
      uint256 groupId = shiftedGroupId >> 128;
      uint256 mintedItemId = _mintChecker(_ids[i], _amounts[i]);

      balances[mintedItemId][_recipient] = balances[mintedItemId][_recipient]
        .add(_amounts[i]);
      groupBalances[groupId][_recipient] = groupBalances[groupId][_recipient]
        .add(_amounts[i]);
      totalBalances[_recipient] = totalBalances[_recipient].add(_amounts[i]);
      mintCount[mintedItemId] = mintCount[mintedItemId].add(_amounts[i]);
      circulatingSupply[mintedItemId] = circulatingSupply[mintedItemId]
        .add(_amounts[i]);
      itemGroups[groupId].mintCount = itemGroups[groupId].mintCount
        .add(_amounts[i]);
      itemGroups[groupId].circulatingSupply =
        itemGroups[groupId].circulatingSupply.add(_amounts[i]);
    }

    emit TransferBatch(operator, address(0), _recipient, _ids, _amounts);
    _doSafeBatchTransferAcceptanceCheck(operator, address(0), _recipient, _ids,
      _amounts, _data);
  }

  function _burnChecker(uint256 _id, uint256 _amount) private view
    returns (uint256) {


    uint256 shiftedGroupId = (_id & GROUP_MASK);
    uint256 groupId = shiftedGroupId >> 128;
    require(itemGroups[groupId].initialized,
      "Super1155: you cannot burn a non-existent item group");

    if (itemGroups[groupId].burnType == BurnType.Burnable) {
      require(itemGroups[groupId].burnCount.add(_amount)
        <= itemGroups[groupId].burnData,
        "Super1155: you may not exceed the burn limit on this item group");
    }

    uint256 burntItemId = _id;
    if (itemGroups[groupId].itemType == ItemType.Fungible) {
      burntItemId = shiftedGroupId.add(1);
    }
    return burntItemId;
  }

  function burn(address _burner, uint256 _id, uint256 _amount)
    external virtual hasItemRight(_id, BURN) {

    require(_burner != address(0),
      "ERC1155: burn from the zero address");

    uint256 shiftedGroupId = (_id & GROUP_MASK);
    uint256 groupId = shiftedGroupId >> 128;
    uint256 burntItemId = _burnChecker(_id, _amount);

    address operator = _msgSender();
    _beforeTokenTransfer(operator, _burner, address(0),
      _asSingletonArray(burntItemId), _asSingletonArray(_amount), "");

    balances[burntItemId][_burner] = balances[burntItemId][_burner]
      .sub(_amount,
      "ERC1155: burn amount exceeds balance");
    groupBalances[groupId][_burner] = groupBalances[groupId][_burner]
      .sub(_amount);
    totalBalances[_burner] = totalBalances[_burner].sub(_amount);
    burnCount[burntItemId] = burnCount[burntItemId].add(_amount);
    circulatingSupply[burntItemId] = circulatingSupply[burntItemId]
      .sub(_amount);
    itemGroups[groupId].burnCount = itemGroups[groupId].burnCount.add(_amount);
    itemGroups[groupId].circulatingSupply =
      itemGroups[groupId].circulatingSupply.sub(_amount);

    emit TransferSingle(operator, _burner, address(0), _id, _amount);
  }

  function burnBatch(address _burner, uint256[] memory _ids,
    uint256[] memory _amounts) external virtual {

    require(_burner != address(0),
      "ERC1155: burn from the zero address");
    require(_ids.length == _amounts.length,
      "ERC1155: ids and amounts length mismatch");

    address operator = _msgSender();
    _beforeTokenTransfer(operator, _burner, address(0), _ids, _amounts, "");

    for (uint i = 0; i < _ids.length; i++) {
      require(_hasItemRight(_ids[i], BURN),
        "Super1155: you do not have the right to burn that item");

      uint256 shiftedGroupId = (_ids[i] & GROUP_MASK);
      uint256 groupId = shiftedGroupId >> 128;
      uint256 burntItemId = _burnChecker(_ids[i], _amounts[i]);

      balances[burntItemId][_burner] = balances[burntItemId][_burner]
        .sub(_amounts[i],
        "ERC1155: burn amount exceeds balance");
      groupBalances[groupId][_burner] = groupBalances[groupId][_burner]
        .sub(_amounts[i]);
      totalBalances[_burner] = totalBalances[_burner].sub(_amounts[i]);
      burnCount[burntItemId] = burnCount[burntItemId].add(_amounts[i]);
      circulatingSupply[burntItemId] = circulatingSupply[burntItemId]
        .sub(_amounts[i]);
      itemGroups[groupId].burnCount = itemGroups[groupId].burnCount
        .add(_amounts[i]);
      itemGroups[groupId].circulatingSupply =
        itemGroups[groupId].circulatingSupply.sub(_amounts[i]);
    }

    emit TransferBatch(operator, _burner, address(0), _ids, _amounts);
  }

  function setMetadata(uint256 _id, string memory _metadata)
    external hasItemRight(_id, SET_METADATA) {

    require(!uriLocked && !metadataFrozen[_id],
      "Super1155: you cannot edit this metadata because it is frozen");
    string memory oldMetadata = metadata[_id];
    metadata[_id] = _metadata;
    emit MetadataChanged(_msgSender(), _id, oldMetadata, _metadata);
  }

  function lockURI(string calldata _uri) external
    hasValidPermit(UNIVERSAL, LOCK_URI) {

    string memory oldURI = metadataUri;
    metadataUri = _uri;
    emit ChangeURI(oldURI, _uri);
    uriLocked = true;
    emit PermanentURI(_uri, 2 ** 256 - 1);
  }

  function lockURI(string calldata _uri, uint256 _id) external
    hasItemRight(_id, LOCK_ITEM_URI) {

    metadataFrozen[_id] = true;
    emit PermanentURI(_uri, _id);
  }

  function lock() external virtual hasValidPermit(UNIVERSAL, LOCK_CREATION) {

    locked = true;
    emit CollectionLocked(_msgSender());
  }
}