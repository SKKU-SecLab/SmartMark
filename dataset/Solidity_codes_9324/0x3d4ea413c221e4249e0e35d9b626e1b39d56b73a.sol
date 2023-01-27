
pragma solidity >=0.6.0 <0.8.0;

interface IERC20 {

    function totalSupply() external view returns (uint256);


    function balanceOf(address account) external view returns (uint256);


    function transfer(address recipient, uint256 amount) external returns (bool);


    function allowance(address owner, address spender) external view returns (uint256);


    function approve(address spender, uint256 amount) external returns (bool);


    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);


    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}// MIT

pragma solidity >=0.6.0 <0.8.0;

interface IERC165 {

    function supportsInterface(bytes4 interfaceId) external view returns (bool);

}// MIT

pragma solidity >=0.6.2 <0.8.0;


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

}// MIT

pragma solidity >=0.6.0 <0.8.0;

abstract contract ReentrancyGuard {

    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor () internal {
        _status = _NOT_ENTERED;
    }

    modifier nonReentrant() {
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        _status = _ENTERED;

        _;

        _status = _NOT_ENTERED;
    }
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


library SafeERC20 {

    using SafeMath for uint256;
    using Address for address;

    function safeTransfer(IERC20 token, address to, uint256 value) internal {

        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(IERC20 token, address from, address to, uint256 value) internal {

        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    function safeApprove(IERC20 token, address spender, uint256 value) internal {

        require((value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(IERC20 token, address spender, uint256 value) internal {

        uint256 newAllowance = token.allowance(address(this), spender).add(value);
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(IERC20 token, address spender, uint256 value) internal {

        uint256 newAllowance = token.allowance(address(this), spender).sub(value, "SafeERC20: decreased allowance below zero");
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function _callOptionalReturn(IERC20 token, bytes memory data) private {


        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) { // Return data is optional
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
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
      || hasRightUntil(_msgSender(), _circumstance, _right) > block.timestamp,
      "PermitControl: sender does not have a valid permit");
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

  function setPermit(
    address _address,
    bytes32 _circumstance,
    bytes32 _right,
    uint256 _expirationTime
  ) external virtual hasValidPermit(UNIVERSAL, managerRight[_right]) {
    require(_right != ZERO_RIGHT,
      "PermitControl: you may not grant the zero right");
    permissions[_address][_circumstance][_right] = _expirationTime;
    emit PermitUpdated(_msgSender(), _address, _circumstance, _right,
      _expirationTime);
  }

  function setManagerRight(
    bytes32 _managedRight,
    bytes32 _managerRight
  ) external virtual hasValidPermit(UNIVERSAL, MANAGER) {
    require(_managedRight != ZERO_RIGHT,
      "PermitControl: you may not specify a manager for the zero right");
    managerRight[_managedRight] = _managerRight;
    emit ManagementUpdated(_msgSender(), _managedRight, _managerRight);
  }
}// GPL-3.0
pragma solidity 0.7.6;



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
      "MintShop1155: the sweep function is locked");
    _token.safeTransferFrom(address(this), _address, _amount);
    emit TokenSweep(_msgSender(), _token, _amount, _address);
  }

  function lockSweep() external hasValidPermit(UNIVERSAL, LOCK_SWEEP) {

    sweepLocked = true;
    emit SweepLocked(_msgSender());
  }
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
}// GPL-3.0
pragma solidity 0.7.6;


contract Staker is Ownable, ReentrancyGuard {

  using SafeMath for uint256;
  using SafeERC20 for IERC20;

  string public name;

  IERC20 public token;

  uint256 public totalTokenDeposited;

  bool public canAlterDevelopers;

  address[] public developerAddresses;

  mapping (address => uint256) public developerShares;

  bool public canAlterTokenEmissionSchedule;
  bool public canAlterPointEmissionSchedule;

  struct EmissionPoint {
    uint256 blockNumber;
    uint256 rate;
  }

  uint256 public tokenEmissionBlockCount;
  mapping (uint256 => EmissionPoint) public tokenEmissionBlocks;
  uint256 public pointEmissionBlockCount;
  mapping (uint256 => EmissionPoint) public pointEmissionBlocks;

  uint256 MAX_INT = 2**256 - 1;
  uint256 internal earliestTokenEmissionBlock;
  uint256 internal earliestPointEmissionBlock;

  struct PoolInfo {
    IERC20 token;
    uint256 tokenStrength;
    uint256 tokensPerShare;
    uint256 pointStrength;
    uint256 pointsPerShare;
    uint256 lastRewardBlock;
  }

  IERC20[] public poolTokens;

  mapping (IERC20 => PoolInfo) public poolInfo;

  struct UserInfo {
    uint256 amount;
    uint256 tokenPaid;
    uint256 pointPaid;
  }

  mapping (IERC20 => mapping (address => UserInfo)) public userInfo;

  uint256 public totalTokenStrength;
  uint256 public totalPointStrength;

  uint256 public totalTokenDisbursed;

  mapping (address => uint256) public userPoints;
  mapping (address => uint256) public userSpentPoints;

  mapping (address => bool) public approvedPointSpenders;

  event Deposit(address indexed user, IERC20 indexed token, uint256 amount);
  event Withdraw(address indexed user, IERC20 indexed token, uint256 amount);

  event SpentPoints(address indexed source, address indexed user, uint256 amount);

  constructor(string memory _name, IERC20 _token) public {
    name = _name;
    token = _token;
    token.approve(address(this), MAX_INT);
    canAlterDevelopers = true;
    canAlterTokenEmissionSchedule = true;
    earliestTokenEmissionBlock = MAX_INT;
    canAlterPointEmissionSchedule = true;
    earliestPointEmissionBlock = MAX_INT;
  }

  function addDeveloper(address _developerAddress, uint256 _share) external onlyOwner {

    require(canAlterDevelopers,
      "This Staker has locked the addition of developers; no more may be added.");
    developerAddresses.push(_developerAddress);
    developerShares[_developerAddress] = _share;
  }

  function lockDevelopers() external onlyOwner {

    canAlterDevelopers = false;
  }

  function updateDeveloper(address _newDeveloperAddress, uint256 _newShare) external {

    uint256 developerShare = developerShares[msg.sender];
    require(developerShare > 0,
      "You are not a developer of this Staker.");
    require(_newShare <= developerShare,
      "You cannot increase your developer share.");
    developerShares[msg.sender] = 0;
    developerAddresses.push(_newDeveloperAddress);
    developerShares[_newDeveloperAddress] = _newShare;
  }

  function setEmissions(EmissionPoint[] memory _tokenSchedule, EmissionPoint[] memory _pointSchedule) external onlyOwner {

    if (_tokenSchedule.length > 0) {
      require(canAlterTokenEmissionSchedule,
        "This Staker has locked the alteration of token emissions.");
      tokenEmissionBlockCount = _tokenSchedule.length;
      for (uint256 i = 0; i < tokenEmissionBlockCount; i++) {
        tokenEmissionBlocks[i] = _tokenSchedule[i];
        if (earliestTokenEmissionBlock > _tokenSchedule[i].blockNumber) {
          earliestTokenEmissionBlock = _tokenSchedule[i].blockNumber;
        }
      }
    }
    require(tokenEmissionBlockCount > 0,
      "You must set the token emission schedule.");

    if (_pointSchedule.length > 0) {
      require(canAlterPointEmissionSchedule,
        "This Staker has locked the alteration of point emissions.");
      pointEmissionBlockCount = _pointSchedule.length;
      for (uint256 i = 0; i < pointEmissionBlockCount; i++) {
        pointEmissionBlocks[i] = _pointSchedule[i];
        if (earliestPointEmissionBlock > _pointSchedule[i].blockNumber) {
          earliestPointEmissionBlock = _pointSchedule[i].blockNumber;
        }
      }
    }
    require(tokenEmissionBlockCount > 0,
      "You must set the point emission schedule.");
  }

  function lockTokenEmissions() external onlyOwner {

    canAlterTokenEmissionSchedule = false;
  }

  function lockPointEmissions() external onlyOwner {

    canAlterPointEmissionSchedule = false;
  }

  function getDeveloperCount() external view returns (uint256) {

    return developerAddresses.length;
  }

  function getPoolCount() external view returns (uint256) {

    return poolTokens.length;
  }

  function getRemainingToken() external view returns (uint256) {

    return token.balanceOf(address(this));
  }

  function addPool(IERC20 _token, uint256 _tokenStrength, uint256 _pointStrength) external onlyOwner {

    require(tokenEmissionBlockCount > 0 && pointEmissionBlockCount > 0,
      "Staking pools cannot be addded until an emission schedule has been defined.");
    uint256 lastTokenRewardBlock = block.number > earliestTokenEmissionBlock ? block.number : earliestTokenEmissionBlock;
    uint256 lastPointRewardBlock = block.number > earliestPointEmissionBlock ? block.number : earliestPointEmissionBlock;
    uint256 lastRewardBlock = lastTokenRewardBlock > lastPointRewardBlock ? lastTokenRewardBlock : lastPointRewardBlock;
    if (address(poolInfo[_token].token) == address(0)) {
      poolTokens.push(_token);
      totalTokenStrength = totalTokenStrength.add(_tokenStrength);
      totalPointStrength = totalPointStrength.add(_pointStrength);
      poolInfo[_token] = PoolInfo({
        token: _token,
        tokenStrength: _tokenStrength,
        tokensPerShare: 0,
        pointStrength: _pointStrength,
        pointsPerShare: 0,
        lastRewardBlock: lastRewardBlock
      });
    } else {
      totalTokenStrength = totalTokenStrength.sub(poolInfo[_token].tokenStrength).add(_tokenStrength);
      poolInfo[_token].tokenStrength = _tokenStrength;
      totalPointStrength = totalPointStrength.sub(poolInfo[_token].pointStrength).add(_pointStrength);
      poolInfo[_token].pointStrength = _pointStrength;
    }
  }

  function getTotalEmittedTokens(uint256 _fromBlock, uint256 _toBlock) public view returns (uint256) {

    require(_toBlock >= _fromBlock,
      "Tokens cannot be emitted from a higher block to a lower block.");
    uint256 totalEmittedTokens = 0;
    uint256 workingRate = 0;
    uint256 workingBlock = _fromBlock;
    for (uint256 i = 0; i < tokenEmissionBlockCount; ++i) {
      uint256 emissionBlock = tokenEmissionBlocks[i].blockNumber;
      uint256 emissionRate = tokenEmissionBlocks[i].rate;
      if (_toBlock < emissionBlock) {
        totalEmittedTokens = totalEmittedTokens.add(_toBlock.sub(workingBlock).mul(workingRate));
        return totalEmittedTokens;
      } else if (workingBlock < emissionBlock) {
        totalEmittedTokens = totalEmittedTokens.add(emissionBlock.sub(workingBlock).mul(workingRate));
        workingBlock = emissionBlock;
      }
      workingRate = emissionRate;
    }
    if (workingBlock < _toBlock) {
      totalEmittedTokens = totalEmittedTokens.add(_toBlock.sub(workingBlock).mul(workingRate));
    }
    return totalEmittedTokens;
  }

  function getTotalEmittedPoints(uint256 _fromBlock, uint256 _toBlock) public view returns (uint256) {

    require(_toBlock >= _fromBlock,
      "Points cannot be emitted from a higher block to a lower block.");
    uint256 totalEmittedPoints = 0;
    uint256 workingRate = 0;
    uint256 workingBlock = _fromBlock;
    for (uint256 i = 0; i < pointEmissionBlockCount; ++i) {
      uint256 emissionBlock = pointEmissionBlocks[i].blockNumber;
      uint256 emissionRate = pointEmissionBlocks[i].rate;
      if (_toBlock < emissionBlock) {
        totalEmittedPoints = totalEmittedPoints.add(_toBlock.sub(workingBlock).mul(workingRate));
        return totalEmittedPoints;
      } else if (workingBlock < emissionBlock) {
        totalEmittedPoints = totalEmittedPoints.add(emissionBlock.sub(workingBlock).mul(workingRate));
        workingBlock = emissionBlock;
      }
      workingRate = emissionRate;
    }
    if (workingBlock < _toBlock) {
      totalEmittedPoints = totalEmittedPoints.add(_toBlock.sub(workingBlock).mul(workingRate));
    }
    return totalEmittedPoints;
  }

  function updatePool(IERC20 _token) internal {

    PoolInfo storage pool = poolInfo[_token];
    if (block.number <= pool.lastRewardBlock) {
      return;
    }
    uint256 poolTokenSupply = pool.token.balanceOf(address(this));
    if (address(_token) == address(token)) {
      poolTokenSupply = totalTokenDeposited;
    }
    if (poolTokenSupply <= 0) {
      pool.lastRewardBlock = block.number;
      return;
    }

    uint256 totalEmittedTokens = getTotalEmittedTokens(pool.lastRewardBlock, block.number);
    uint256 tokensReward = totalEmittedTokens.mul(pool.tokenStrength).div(totalTokenStrength).mul(1e12);
    uint256 totalEmittedPoints = getTotalEmittedPoints(pool.lastRewardBlock, block.number);
    uint256 pointsReward = totalEmittedPoints.mul(pool.pointStrength).div(totalPointStrength).mul(1e30);

    for (uint256 i = 0; i < developerAddresses.length; ++i) {
      address developer = developerAddresses[i];
      uint256 share = developerShares[developer];
      uint256 devTokens = tokensReward.mul(share).div(100000);
      tokensReward = tokensReward - devTokens;
      uint256 devPoints = pointsReward.mul(share).div(100000);
      pointsReward = pointsReward - devPoints;
      token.safeTransferFrom(address(this), developer, devTokens.div(1e12));
      userPoints[developer] = userPoints[developer].add(devPoints.div(1e30));
    }

    pool.tokensPerShare = pool.tokensPerShare.add(tokensReward.div(poolTokenSupply));
    pool.pointsPerShare = pool.pointsPerShare.add(pointsReward.div(poolTokenSupply));
    pool.lastRewardBlock = block.number;
  }

  function getPendingTokens(IERC20 _token, address _user) public view returns (uint256) {

    PoolInfo storage pool = poolInfo[_token];
    UserInfo storage user = userInfo[_token][_user];
    uint256 tokensPerShare = pool.tokensPerShare;
    uint256 poolTokenSupply = pool.token.balanceOf(address(this));
    if (address(_token) == address(token)) {
      poolTokenSupply = totalTokenDeposited;
    }

    if (block.number > pool.lastRewardBlock && poolTokenSupply > 0) {
      uint256 totalEmittedTokens = getTotalEmittedTokens(pool.lastRewardBlock, block.number);
      uint256 tokensReward = totalEmittedTokens.mul(pool.tokenStrength).div(totalTokenStrength).mul(1e12);
      tokensPerShare = tokensPerShare.add(tokensReward.div(poolTokenSupply));
    }

    return user.amount.mul(tokensPerShare).div(1e12).sub(user.tokenPaid);
  }

  function getPendingPoints(IERC20 _token, address _user) public view returns (uint256) {

    PoolInfo storage pool = poolInfo[_token];
    UserInfo storage user = userInfo[_token][_user];
    uint256 pointsPerShare = pool.pointsPerShare;
    uint256 poolTokenSupply = pool.token.balanceOf(address(this));
    if (address(_token) == address(token)) {
      poolTokenSupply = totalTokenDeposited;
    }

    if (block.number > pool.lastRewardBlock && poolTokenSupply > 0) {
      uint256 totalEmittedPoints = getTotalEmittedPoints(pool.lastRewardBlock, block.number);
      uint256 pointsReward = totalEmittedPoints.mul(pool.pointStrength).div(totalPointStrength).mul(1e30);
      pointsPerShare = pointsPerShare.add(pointsReward.div(poolTokenSupply));
    }

    return user.amount.mul(pointsPerShare).div(1e30).sub(user.pointPaid);
  }

  function getAvailablePoints(address _user) public view returns (uint256) {

    uint256 concreteTotal = userPoints[_user];
    uint256 pendingTotal = 0;
    for (uint256 i = 0; i < poolTokens.length; ++i) {
      IERC20 poolToken = poolTokens[i];
      uint256 _pendingPoints = getPendingPoints(poolToken, _user);
      pendingTotal = pendingTotal.add(_pendingPoints);
    }
    uint256 spentTotal = userSpentPoints[_user];
    return concreteTotal.add(pendingTotal).sub(spentTotal);
  }

  function getTotalPoints(address _user) external view returns (uint256) {

    uint256 concreteTotal = userPoints[_user];
    uint256 pendingTotal = 0;
    for (uint256 i = 0; i < poolTokens.length; ++i) {
      IERC20 poolToken = poolTokens[i];
      uint256 _pendingPoints = getPendingPoints(poolToken, _user);
      pendingTotal = pendingTotal.add(_pendingPoints);
    }
    return concreteTotal.add(pendingTotal);
  }

  function getSpentPoints(address _user) external view returns (uint256) {

    return userSpentPoints[_user];
  }

  function deposit(IERC20 _token, uint256 _amount) external nonReentrant {

    PoolInfo storage pool = poolInfo[_token];
    require(pool.tokenStrength > 0 || pool.pointStrength > 0,
      "You cannot deposit assets into an inactive pool.");
    UserInfo storage user = userInfo[_token][msg.sender];
    updatePool(_token);
    if (user.amount > 0) {
      uint256 pendingTokens = user.amount.mul(pool.tokensPerShare).div(1e12).sub(user.tokenPaid);
      token.safeTransferFrom(address(this), msg.sender, pendingTokens);
      totalTokenDisbursed = totalTokenDisbursed.add(pendingTokens);
      uint256 pendingPoints = user.amount.mul(pool.pointsPerShare).div(1e30).sub(user.pointPaid);
      userPoints[msg.sender] = userPoints[msg.sender].add(pendingPoints);
    }
    pool.token.safeTransferFrom(address(msg.sender), address(this), _amount);
    if (address(_token) == address(token)) {
      totalTokenDeposited = totalTokenDeposited.add(_amount);
    }
    user.amount = user.amount.add(_amount);
    user.tokenPaid = user.amount.mul(pool.tokensPerShare).div(1e12);
    user.pointPaid = user.amount.mul(pool.pointsPerShare).div(1e30);
    emit Deposit(msg.sender, _token, _amount);
  }

  function withdraw(IERC20 _token, uint256 _amount) external nonReentrant {

    PoolInfo storage pool = poolInfo[_token];
    UserInfo storage user = userInfo[_token][msg.sender];
    require(user.amount >= _amount,
      "You cannot withdraw that much of the specified token; you are not owed it.");
    updatePool(_token);
    uint256 pendingTokens = user.amount.mul(pool.tokensPerShare).div(1e12).sub(user.tokenPaid);
    token.safeTransferFrom(address(this), msg.sender, pendingTokens);
    totalTokenDisbursed = totalTokenDisbursed.add(pendingTokens);
    uint256 pendingPoints = user.amount.mul(pool.pointsPerShare).div(1e30).sub(user.pointPaid);
    userPoints[msg.sender] = userPoints[msg.sender].add(pendingPoints);
    if (address(_token) == address(token)) {
      totalTokenDeposited = totalTokenDeposited.sub(_amount);
    }
    user.amount = user.amount.sub(_amount);
    user.tokenPaid = user.amount.mul(pool.tokensPerShare).div(1e12);
    user.pointPaid = user.amount.mul(pool.pointsPerShare).div(1e30);
    pool.token.safeTransfer(address(msg.sender), _amount);
    emit Withdraw(msg.sender, _token, _amount);
  }

  function approvePointSpender(address _spender, bool _approval) external onlyOwner {

    approvedPointSpenders[_spender] = _approval;
  }

  function spendPoints(address _user, uint256 _amount) external {

    require(approvedPointSpenders[msg.sender],
      "You are not permitted to spend user points.");
    uint256 _userPoints = getAvailablePoints(_user);
    require(_userPoints >= _amount,
      "The user does not have enough points to spend the requested amount.");
    userSpentPoints[_user] = userSpentPoints[_user].add(_amount);
    emit SpentPoints(msg.sender, _user, _amount);
  }

  function sweep(IERC20 _token) external onlyOwner {

    uint256 balance = _token.balanceOf(address(this));
    _token.safeTransferFrom(address(this), msg.sender, balance);
  }
}// GPL-3.0
pragma solidity 0.7.6;



contract MintShop1155 is Sweepable, ReentrancyGuard {

  using SafeERC20 for IERC20;
  using SafeMath for uint256;

  bytes32 public constant SET_PAYMENT_RECEIVER
    = keccak256("SET_PAYMENT_RECEIVER");

  bytes32 public constant LOCK_PAYMENT_RECEIVER
    = keccak256("LOCK_PAYMENT_RECEIVER");

  bytes32 public constant UPDATE_GLOBAL_LIMIT
    = keccak256("UPDATE_GLOBAL_LIMIT");

  bytes32 public constant LOCK_GLOBAL_LIMIT = keccak256("LOCK_GLOBAL_LIMIT");

  bytes32 public constant WHITELIST = keccak256("WHITELIST");

  bytes32 public constant POOL = keccak256("POOL");

  uint256 constant GROUP_MASK = uint256(uint128(~0)) << 128;

  Super1155 public item;

  address public paymentReceiver;

  bool public paymentReceiverLocked;

  uint256 public globalPurchaseLimit;

  bool public globalPurchaseLimitLocked;

  mapping (address => uint256) public globalPurchaseCounts;

  uint256 public nextWhitelistId = 1;

  mapping (uint256 => Whitelist) public whitelists;

  uint256 public nextPoolId;

  mapping (uint256 => Pool) public pools;

  mapping (uint256 => uint256) public nextItemIssues;

  struct PoolInput {
    string name;
    uint256 startTime;
    uint256 endTime;
    uint256 purchaseLimit;
    uint256 singlePurchaseLimit;
    PoolRequirement requirement;
  }

  struct Pool {
    string name;
    uint256 startTime;
    uint256 endTime;
    uint256 purchaseLimit;
    uint256 singlePurchaseLimit;
    mapping (address => uint256) purchaseCounts;
    PoolRequirement requirement;
    uint256[] itemGroups;
    uint256 currentPoolVersion;
    mapping (bytes32 => uint256) itemCaps;
    mapping (bytes32 => uint256) itemMinted;
    mapping (bytes32 => uint256) itemPricesLength;
    mapping (bytes32 => mapping (uint256 => Price)) itemPrices;
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
    address requiredAsset;
    uint256 requiredAmount;
    uint256 whitelistId;
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

  struct WhitelistInput {
    uint256 expiryTime;
    bool isActive;
    address[] addresses;
  }

  struct Whitelist {
    uint256 expiryTime;
    bool isActive;
    uint256 currentWhitelistVersion;
    mapping (bytes32 => bool) addresses;
  }

  struct PoolItem {
    uint256 groupId;
    uint256 cap;
    uint256 minted;
    Price[] prices;
  }

  struct PoolOutput {
    string name;
    uint256 startTime;
    uint256 endTime;
    uint256 purchaseLimit;
    uint256 singlePurchaseLimit;
    PoolRequirement requirement;
    string itemMetadataUri;
    PoolItem[] items;
  }

  struct PoolAddressOutput {
    string name;
    uint256 startTime;
    uint256 endTime;
    uint256 purchaseLimit;
    uint256 singlePurchaseLimit;
    PoolRequirement requirement;
    string itemMetadataUri;
    PoolItem[] items;
    uint256 purchaseCount;
    bool whitelistStatus;
  }

  event PaymentReceiverUpdated(address indexed updater,
    address indexed oldPaymentReceiver, address indexed newPaymentReceiver);

  event PaymentReceiverLocked(address indexed locker);

  event GlobalPurchaseLimitUpdated(address indexed updater,
    uint256 indexed oldPurchaseLimit, uint256 indexed newPurchaseLimit);

  event GlobalPurchaseLimitLocked(address indexed locker);

  event WhitelistUpdated(address indexed updater, uint256 indexed whitelistId,
    address[] indexed addresses);

  event WhitelistAddition(address indexed adder, uint256 indexed whitelistId,
    address[] indexed addresses);

  event WhitelistRemoval(address indexed remover, uint256 indexed whitelistId,
    address[] indexed addresses);

  event WhitelistActiveUpdate(address indexed updater,
    uint256 indexed whitelistId, bool indexed isActive);

  event PoolUpdated(address indexed updater, uint256 poolId,
    PoolInput indexed pool, uint256[] groupIds, uint256[] caps,
    Price[][] indexed prices);

  event ItemPurchased(address indexed buyer, uint256 poolId,
    uint256[] indexed itemIds, uint256[] amounts);

  constructor(address _owner, Super1155 _item, address _paymentReceiver,
    uint256 _globalPurchaseLimit) public {

    if (_owner != owner()) {
      transferOwnership(_owner);
    }

    item = _item;
    paymentReceiver = _paymentReceiver;
    globalPurchaseLimit = _globalPurchaseLimit;
  }

  function version() external virtual override pure returns (uint256) {

    return 1;
  }

  function updatePaymentReceiver(address _newPaymentReceiver) external
    hasValidPermit(UNIVERSAL, SET_PAYMENT_RECEIVER) {

    require(!paymentReceiverLocked,
      "MintShop1155: the payment receiver address is locked");
    address oldPaymentReceiver = paymentReceiver;
    paymentReceiver = _newPaymentReceiver;
    emit PaymentReceiverUpdated(_msgSender(), oldPaymentReceiver,
      _newPaymentReceiver);
  }

  function lockPaymentReceiver() external
    hasValidPermit(UNIVERSAL, LOCK_PAYMENT_RECEIVER) {

    paymentReceiverLocked = true;
    emit PaymentReceiverLocked(_msgSender());
  }

  function updateGlobalPurchaseLimit(uint256 _newGlobalPurchaseLimit) external
    hasValidPermit(UNIVERSAL, UPDATE_GLOBAL_LIMIT) {

    require(!globalPurchaseLimitLocked,
      "MintShop1155: the global purchase limit is locked");
    uint256 oldGlobalPurchaseLimit = globalPurchaseLimit;
    globalPurchaseLimit = _newGlobalPurchaseLimit;
    emit GlobalPurchaseLimitUpdated(_msgSender(), oldGlobalPurchaseLimit,
      _newGlobalPurchaseLimit);
  }

  function lockGlobalPurchaseLimit() external
    hasValidPermit(UNIVERSAL, LOCK_GLOBAL_LIMIT) {

    globalPurchaseLimitLocked = true;
    emit GlobalPurchaseLimitLocked(_msgSender());
  }

  function addWhitelist(WhitelistInput memory _whitelist) external
    hasValidPermit(UNIVERSAL, WHITELIST) {

    updateWhitelist(nextWhitelistId, _whitelist);

    nextWhitelistId = nextWhitelistId.add(1);
  }

  function updateWhitelist(uint256 _id, WhitelistInput memory _whitelist)
    public hasValidPermit(UNIVERSAL, WHITELIST) {

    uint256 newWhitelistVersion =
      whitelists[_id].currentWhitelistVersion.add(1);

    Whitelist storage whitelist = whitelists[_id];
    whitelist.expiryTime = _whitelist.expiryTime;
    whitelist.isActive = _whitelist.isActive;
    whitelist.currentWhitelistVersion = newWhitelistVersion;

    for (uint256 i = 0; i < _whitelist.addresses.length; i++) {
      bytes32 addressKey = keccak256(abi.encode(newWhitelistVersion,
        _whitelist.addresses[i]));
      whitelists[_id].addresses[addressKey] = true;
    }

    emit WhitelistUpdated(_msgSender(), _id, _whitelist.addresses);
  }

  function addToWhitelist(uint256 _id, address[] calldata _addresses) external
    hasValidPermit(UNIVERSAL, WHITELIST) {

    uint256 whitelistVersion = whitelists[_id].currentWhitelistVersion;
    for (uint256 i = 0; i < _addresses.length; i++) {
      bytes32 addressKey = keccak256(abi.encode(whitelistVersion,
        _addresses[i]));
      whitelists[_id].addresses[addressKey] = true;
    }

    emit WhitelistAddition(_msgSender(), _id, _addresses);
  }

  function removeFromWhitelist(uint256 _id, address[] calldata _addresses)
    external hasValidPermit(UNIVERSAL, WHITELIST) {

    uint256 whitelistVersion = whitelists[_id].currentWhitelistVersion;
    for (uint256 i = 0; i < _addresses.length; i++) {
      bytes32 addressKey = keccak256(abi.encode(whitelistVersion,
        _addresses[i]));
      whitelists[_id].addresses[addressKey] = false;
    }

    emit WhitelistRemoval(_msgSender(), _id, _addresses);
  }

  function setWhitelistActive(uint256 _id, bool _isActive) external
    hasValidPermit(UNIVERSAL, WHITELIST) {

    whitelists[_id].isActive = _isActive;

    emit WhitelistActiveUpdate(_msgSender(), _id, _isActive);
  }

  function getWhitelistStatus(uint256[] calldata _ids,
    address[] calldata _addresses) external view returns (bool[][] memory) {

    bool[][] memory whitelistStatus;
    for (uint256 i = 0; i < _ids.length; i++) {
      uint256 id = _ids[i];
      uint256 whitelistVersion = whitelists[id].currentWhitelistVersion;
      for (uint256 j = 0; j < _addresses.length; j++) {
        bytes32 addressKey = keccak256(abi.encode(whitelistVersion,
          _addresses[j]));
        whitelistStatus[j][i] = whitelists[id].addresses[addressKey];
      }
    }
    return whitelistStatus;
  }

  function getPools(uint256[] calldata _ids) external view
    returns (PoolOutput[] memory) {

    PoolOutput[] memory poolOutputs = new PoolOutput[](_ids.length);
    for (uint256 i = 0; i < _ids.length; i++) {
      uint256 id = _ids[i];

      PoolItem[] memory poolItems = new PoolItem[](pools[id].itemGroups.length);
      for (uint256 j = 0; j < pools[id].itemGroups.length; j++) {
        uint256 itemGroupId = pools[id].itemGroups[j];
        bytes32 itemKey = keccak256(abi.encodePacked(
          pools[id].currentPoolVersion, itemGroupId));

        Price[] memory itemPrices =
          new Price[](pools[id].itemPricesLength[itemKey]);
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
        name: pools[id].name,
        startTime: pools[id].startTime,
        endTime: pools[id].endTime,
        purchaseLimit: pools[id].purchaseLimit,
        singlePurchaseLimit: pools[id].singlePurchaseLimit,
        requirement: pools[id].requirement,
        itemMetadataUri: item.metadataUri(),
        items: poolItems
      });
    }

    return poolOutputs;
  }

  function getPurchaseCounts(uint256[] calldata _ids,
    address[] calldata _purchasers) external view returns (uint256[][] memory) {

    uint256[][] memory purchaseCounts;
    for (uint256 i = 0; i < _ids.length; i++) {
      uint256 id = _ids[i];
      for (uint256 j = 0; j < _purchasers.length; j++) {
        address purchaser = _purchasers[j];
        purchaseCounts[j][i] = pools[id].purchaseCounts[purchaser];
      }
    }
    return purchaseCounts;
  }

  function getPoolsWithAddress(uint256[] calldata _ids, address _address)
    external view returns (PoolAddressOutput[] memory) {

    PoolAddressOutput[] memory poolOutputs =
      new PoolAddressOutput[](_ids.length);
    for (uint256 i = 0; i < _ids.length; i++) {
      uint256 id = _ids[i];

      PoolItem[] memory poolItems = new PoolItem[](pools[id].itemGroups.length);
      for (uint256 j = 0; j < pools[id].itemGroups.length; j++) {
        uint256 itemGroupId = pools[id].itemGroups[j];
        bytes32 itemKey = keccak256(abi.encodePacked(
          pools[id].currentPoolVersion, itemGroupId));

        Price[] memory itemPrices =
          new Price[](pools[id].itemPricesLength[itemKey]);
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

      uint256 whitelistId = pools[id].requirement.whitelistId;
      bytes32 addressKey = keccak256(
        abi.encode(whitelists[whitelistId].currentWhitelistVersion, _address));
      poolOutputs[i] = PoolAddressOutput({
        name: pools[id].name,
        startTime: pools[id].startTime,
        endTime: pools[id].endTime,
        purchaseLimit: pools[id].purchaseLimit,
        singlePurchaseLimit: pools[id].singlePurchaseLimit,
        requirement: pools[id].requirement,
        itemMetadataUri: item.metadataUri(),
        items: poolItems,
        purchaseCount: pools[id].purchaseCounts[_address],
        whitelistStatus: whitelists[whitelistId].addresses[addressKey]
      });
    }

    return poolOutputs;
  }

  function addPool(PoolInput calldata _pool, uint256[] calldata _groupIds,
    uint256[] calldata _issueNumberOffsets, uint256[] calldata _caps,
    Price[][] memory _prices) external hasValidPermit(UNIVERSAL, POOL) {

    updatePool(nextPoolId, _pool, _groupIds, _issueNumberOffsets, _caps,
      _prices);

    nextPoolId = nextPoolId.add(1);
  }

  function _updatePoolHelper(uint256 _id,
    uint256[] calldata _groupIds, uint256[] calldata _issueNumberOffsets,
    uint256[] calldata _caps, Price[][] memory _prices) private {

    for (uint256 i = 0; i < _groupIds.length; i++) {
      require(_caps[i] > 0,
        "MintShop1155: cannot add an item group with no mintable amount");
      bytes32 itemKey = keccak256(abi.encode(
        pools[_id].currentPoolVersion, _groupIds[i]));
      pools[_id].itemCaps[itemKey] = _caps[i];

      nextItemIssues[_groupIds[i]] = _issueNumberOffsets[i];

      for (uint256 j = 0; j < _prices[i].length; j++) {
        pools[_id].itemPrices[itemKey][j] = _prices[i][j];
      }
      pools[_id].itemPricesLength[itemKey] = _prices[i].length;
    }
  }

  function updatePool(uint256 _id, PoolInput calldata _pool,
    uint256[] calldata _groupIds, uint256[] calldata _issueNumberOffsets,
    uint256[] calldata _caps, Price[][] memory _prices) public
    hasValidPermit(UNIVERSAL, POOL) {

    require(_id <= nextPoolId,
      "MintShop1155: cannot update a non-existent pool");
    require(_pool.endTime >= _pool.startTime,
      "MintShop1155: cannot create a pool which ends before it starts");
    require(_groupIds.length > 0,
      "MintShop1155: must list at least one item group");
    require(_groupIds.length == _issueNumberOffsets.length,
      "MintShop1155: item groups length must equal issue offsets length");
    require(_groupIds.length == _caps.length,
      "MintShop1155: item groups length must equal caps length");
    require(_groupIds.length == _prices.length,
      "MintShop1155: item groups length must equal prices input length");

    Pool storage pool = pools[_id];
    pool.name = _pool.name;
    pool.startTime = _pool.startTime;
    pool.endTime = _pool.endTime;
    pool.purchaseLimit = _pool.purchaseLimit;
    pool.singlePurchaseLimit = _pool.singlePurchaseLimit;
    pool.itemGroups = _groupIds;
    pool.currentPoolVersion = pools[_id].currentPoolVersion.add(1);
    pool.requirement = _pool.requirement;

    _updatePoolHelper(_id, _groupIds, _issueNumberOffsets, _caps, _prices);

    emit PoolUpdated(_msgSender(), _id, _pool, _groupIds, _caps, _prices);
  }

  function mintFromPool(uint256 _id, uint256 _groupId, uint256 _assetIndex,
    uint256 _amount) external nonReentrant payable {

    require(_amount > 0,
      "MintShop1155: must purchase at least one item");
    require(_id < nextPoolId,
      "MintShop1155: can only purchase items from an active pool");
    require(pools[_id].singlePurchaseLimit >= _amount,
      "MintShop1155: cannot exceed the per-transaction maximum");

    bytes32 itemKey = keccak256(abi.encode(pools[_id].currentPoolVersion,
      _groupId));
    require(_assetIndex < pools[_id].itemPricesLength[itemKey],
      "MintShop1155: specified asset index is not valid");

    require(block.timestamp >= pools[_id].startTime
      && block.timestamp <= pools[_id].endTime,
      "MintShop1155: pool is not currently running its sale");

    uint256 userGlobalPurchaseAmount =
      _amount.add(globalPurchaseCounts[_msgSender()]);
    require(userGlobalPurchaseAmount <= globalPurchaseLimit,
      "MintShop1155: you may not purchase any more items from this shop");

    uint256 userPoolPurchaseAmount =
      _amount.add(pools[_id].purchaseCounts[_msgSender()]);
    require(userPoolPurchaseAmount <= pools[_id].purchaseLimit,
      "MintShop1155: you may not purchase any more items from this pool");

    {
      uint256 whitelistId = pools[_id].requirement.whitelistId;
      uint256 whitelistVersion =
        whitelists[whitelistId].currentWhitelistVersion;
      bytes32 addressKey = keccak256(abi.encode(whitelistVersion,
        _msgSender()));
      bool addressWhitelisted = whitelists[whitelistId].addresses[addressKey];
      require(whitelistId == 0
        || !whitelists[whitelistId].isActive
        || block.timestamp > whitelists[whitelistId].expiryTime
        || addressWhitelisted,
        "MintShop1155: you are not whitelisted on this pool");
    }

    uint256 newCirculatingTotal = pools[_id].itemMinted[itemKey].add(_amount);
    require(newCirculatingTotal <= pools[_id].itemCaps[itemKey],
      "MintShop1155: there are not enough items available for you to purchase");

    PoolRequirement memory poolRequirement = pools[_id].requirement;
    if (poolRequirement.requiredType == AccessType.TokenRequired) {
      IERC20 requiredToken = IERC20(poolRequirement.requiredAsset);
      require(requiredToken.balanceOf(_msgSender())
        >= poolRequirement.requiredAmount,
        "MintShop1155: you do not have enough required token for this pool");

    } else if (poolRequirement.requiredType == AccessType.ItemRequired) {
      Super1155 requiredItem = Super1155(poolRequirement.requiredAsset);
      require(requiredItem.totalBalances(_msgSender())
        >= poolRequirement.requiredAmount,
        "MintShop1155: you do not have enough required item for this pool");

    } else if (poolRequirement.requiredType == AccessType.ItemRequired721) {
      IERC721 requiredItem = IERC721(poolRequirement.requiredAsset);
      require(requiredItem.balanceOf(_msgSender())
        >= poolRequirement.requiredAmount,
        "MintShop1155: you do not have enough required item for this pool");

    } else if (poolRequirement.requiredType == AccessType.PointRequired) {
      Staker requiredStaker = Staker(poolRequirement.requiredAsset);
      require(requiredStaker.getAvailablePoints(_msgSender())
        >= poolRequirement.requiredAmount,
        "MintShop1155: you do not have enough required points for this pool");
    }

    Price memory sellingPair = pools[_id].itemPrices[itemKey][_assetIndex];
    if (sellingPair.assetType == AssetType.Point) {
      Staker(sellingPair.asset).spendPoints(_msgSender(),
        sellingPair.price.mul(_amount));

    } else if (sellingPair.assetType == AssetType.Ether) {
      uint256 etherPrice = sellingPair.price.mul(_amount);
      require(msg.value >= etherPrice,
        "MintShop1155: you did not send enough Ether to complete the purchase");
      (bool success, ) = payable(paymentReceiver).call{ value: msg.value }("");
      require(success,
        "MintShop1155: payment receiver transfer failed");

    } else if (sellingPair.assetType == AssetType.Token) {
      IERC20 sellingAsset = IERC20(sellingPair.asset);
      uint256 tokenPrice = sellingPair.price.mul(_amount);
      require(sellingAsset.balanceOf(_msgSender()) >= tokenPrice,
        "MintShop1155: you do not have enough token to complete the purchase");
      sellingAsset.safeTransferFrom(_msgSender(), paymentReceiver, tokenPrice);

    } else {
      revert("MintShop1155: unrecognized asset type");
    }

    uint256[] memory itemIds = new uint256[](_amount);
    uint256[] memory amounts = new uint256[](_amount);
    uint256 nextIssueNumber = nextItemIssues[_groupId];
    {
      uint256 shiftedGroupId = _groupId << 128;
      for (uint256 i = 1; i <= _amount; i++) {
        uint256 itemId = shiftedGroupId.add(nextIssueNumber).add(i);
        itemIds[i - 1] = itemId;
        amounts[i - 1] = 1;
      }
    }

    item.mintBatch(_msgSender(), itemIds, amounts, "");

    nextItemIssues[_groupId] = nextIssueNumber.add(_amount);

    pools[_id].itemMinted[itemKey] = newCirculatingTotal;

    pools[_id].purchaseCounts[_msgSender()] = userPoolPurchaseAmount;

    globalPurchaseCounts[_msgSender()] = userGlobalPurchaseAmount;

    emit ItemPurchased(_msgSender(), _id, itemIds, amounts);
  }
}