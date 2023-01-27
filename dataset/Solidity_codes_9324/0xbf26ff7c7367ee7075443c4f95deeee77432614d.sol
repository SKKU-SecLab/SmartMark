
pragma solidity ^0.8.0;

library EnumerableSet {


    struct Set {
        bytes32[] _values;
        mapping(bytes32 => uint256) _indexes;
    }

    function _add(Set storage set, bytes32 value) private returns (bool) {

        if (!_contains(set, value)) {
            set._values.push(value);
            set._indexes[value] = set._values.length;
            return true;
        } else {
            return false;
        }
    }

    function _remove(Set storage set, bytes32 value) private returns (bool) {

        uint256 valueIndex = set._indexes[value];

        if (valueIndex != 0) {

            uint256 toDeleteIndex = valueIndex - 1;
            uint256 lastIndex = set._values.length - 1;

            if (lastIndex != toDeleteIndex) {
                bytes32 lastvalue = set._values[lastIndex];

                set._values[toDeleteIndex] = lastvalue;
                set._indexes[lastvalue] = valueIndex; // Replace lastvalue's index to valueIndex
            }

            set._values.pop();

            delete set._indexes[value];

            return true;
        } else {
            return false;
        }
    }

    function _contains(Set storage set, bytes32 value) private view returns (bool) {

        return set._indexes[value] != 0;
    }

    function _length(Set storage set) private view returns (uint256) {

        return set._values.length;
    }

    function _at(Set storage set, uint256 index) private view returns (bytes32) {

        return set._values[index];
    }

    function _values(Set storage set) private view returns (bytes32[] memory) {

        return set._values;
    }


    struct Bytes32Set {
        Set _inner;
    }

    function add(Bytes32Set storage set, bytes32 value) internal returns (bool) {

        return _add(set._inner, value);
    }

    function remove(Bytes32Set storage set, bytes32 value) internal returns (bool) {

        return _remove(set._inner, value);
    }

    function contains(Bytes32Set storage set, bytes32 value) internal view returns (bool) {

        return _contains(set._inner, value);
    }

    function length(Bytes32Set storage set) internal view returns (uint256) {

        return _length(set._inner);
    }

    function at(Bytes32Set storage set, uint256 index) internal view returns (bytes32) {

        return _at(set._inner, index);
    }

    function values(Bytes32Set storage set) internal view returns (bytes32[] memory) {

        return _values(set._inner);
    }


    struct AddressSet {
        Set _inner;
    }

    function add(AddressSet storage set, address value) internal returns (bool) {

        return _add(set._inner, bytes32(uint256(uint160(value))));
    }

    function remove(AddressSet storage set, address value) internal returns (bool) {

        return _remove(set._inner, bytes32(uint256(uint160(value))));
    }

    function contains(AddressSet storage set, address value) internal view returns (bool) {

        return _contains(set._inner, bytes32(uint256(uint160(value))));
    }

    function length(AddressSet storage set) internal view returns (uint256) {

        return _length(set._inner);
    }

    function at(AddressSet storage set, uint256 index) internal view returns (address) {

        return address(uint160(uint256(_at(set._inner, index))));
    }

    function values(AddressSet storage set) internal view returns (address[] memory) {

        bytes32[] memory store = _values(set._inner);
        address[] memory result;

        assembly {
            result := store
        }

        return result;
    }


    struct UintSet {
        Set _inner;
    }

    function add(UintSet storage set, uint256 value) internal returns (bool) {

        return _add(set._inner, bytes32(value));
    }

    function remove(UintSet storage set, uint256 value) internal returns (bool) {

        return _remove(set._inner, bytes32(value));
    }

    function contains(UintSet storage set, uint256 value) internal view returns (bool) {

        return _contains(set._inner, bytes32(value));
    }

    function length(UintSet storage set) internal view returns (uint256) {

        return _length(set._inner);
    }

    function at(UintSet storage set, uint256 index) internal view returns (uint256) {

        return uint256(_at(set._inner, index));
    }

    function values(UintSet storage set) internal view returns (uint256[] memory) {

        bytes32[] memory store = _values(set._inner);
        uint256[] memory result;

        assembly {
            result := store
        }

        return result;
    }
}// MIT

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
pragma solidity >=0.8.4 <0.9.0;

interface ICollectableDust {

  event DustSent(address _to, address token, uint256 amount);

  function sendDust(
    address _to,
    address _token,
    uint256 _amount
  ) external;

}// MIT
pragma solidity >=0.8.4 <0.9.0;



abstract contract CollectableDust is ICollectableDust {
  using SafeERC20 for IERC20;
  using EnumerableSet for EnumerableSet.AddressSet;

  address public constant ETH_ADDRESS = 0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE;
  EnumerableSet.AddressSet internal protocolTokens;

  constructor() {}

  function _addProtocolToken(address _token) internal {
    require(!protocolTokens.contains(_token), 'collectable-dust/token-is-part-of-the-protocol');
    protocolTokens.add(_token);
  }

  function _removeProtocolToken(address _token) internal {
    require(protocolTokens.contains(_token), 'collectable-dust/token-not-part-of-the-protocol');
    protocolTokens.remove(_token);
  }

  function _sendDust(
    address _to,
    address _token,
    uint256 _amount
  ) internal {
    require(_to != address(0), 'collectable-dust/cant-send-dust-to-zero-address');
    require(!protocolTokens.contains(_token), 'collectable-dust/token-is-part-of-the-protocol');
    if (_token == ETH_ADDRESS) {
      payable(_to).transfer(_amount);
    } else {
      IERC20(_token).safeTransfer(_to, _amount);
    }
    emit DustSent(_to, _token, _amount);
  }
}// MIT

pragma solidity ^0.8.0;

interface IAccessControl {

    event RoleAdminChanged(bytes32 indexed role, bytes32 indexed previousAdminRole, bytes32 indexed newAdminRole);

    event RoleGranted(bytes32 indexed role, address indexed account, address indexed sender);

    event RoleRevoked(bytes32 indexed role, address indexed account, address indexed sender);

    function hasRole(bytes32 role, address account) external view returns (bool);


    function getRoleAdmin(bytes32 role) external view returns (bytes32);


    function grantRole(bytes32 role, address account) external;


    function revokeRole(bytes32 role, address account) external;


    function renounceRole(bytes32 role, address account) external;

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
}// MIT

pragma solidity ^0.8.0;

interface IERC165 {

    function supportsInterface(bytes4 interfaceId) external view returns (bool);

}// MIT

pragma solidity ^0.8.0;


abstract contract ERC165 is IERC165 {
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IERC165).interfaceId;
    }
}// MIT

pragma solidity ^0.8.0;


abstract contract AccessControl is Context, IAccessControl, ERC165 {
    struct RoleData {
        mapping(address => bool) members;
        bytes32 adminRole;
    }

    mapping(bytes32 => RoleData) private _roles;

    bytes32 public constant DEFAULT_ADMIN_ROLE = 0x00;

    modifier onlyRole(bytes32 role) {
        _checkRole(role, _msgSender());
        _;
    }

    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IAccessControl).interfaceId || super.supportsInterface(interfaceId);
    }

    function hasRole(bytes32 role, address account) public view override returns (bool) {
        return _roles[role].members[account];
    }

    function _checkRole(bytes32 role, address account) internal view {
        if (!hasRole(role, account)) {
            revert(
                string(
                    abi.encodePacked(
                        "AccessControl: account ",
                        Strings.toHexString(uint160(account), 20),
                        " is missing role ",
                        Strings.toHexString(uint256(role), 32)
                    )
                )
            );
        }
    }

    function getRoleAdmin(bytes32 role) public view override returns (bytes32) {
        return _roles[role].adminRole;
    }

    function grantRole(bytes32 role, address account) public virtual override onlyRole(getRoleAdmin(role)) {
        _grantRole(role, account);
    }

    function revokeRole(bytes32 role, address account) public virtual override onlyRole(getRoleAdmin(role)) {
        _revokeRole(role, account);
    }

    function renounceRole(bytes32 role, address account) public virtual override {
        require(account == _msgSender(), "AccessControl: can only renounce roles for self");

        _revokeRole(role, account);
    }

    function _setupRole(bytes32 role, address account) internal virtual {
        _grantRole(role, account);
    }

    function _setRoleAdmin(bytes32 role, bytes32 adminRole) internal virtual {
        bytes32 previousAdminRole = getRoleAdmin(role);
        _roles[role].adminRole = adminRole;
        emit RoleAdminChanged(role, previousAdminRole, adminRole);
    }

    function _grantRole(bytes32 role, address account) private {
        if (!hasRole(role, account)) {
            _roles[role].members[account] = true;
            emit RoleGranted(role, account, _msgSender());
        }
    }

    function _revokeRole(bytes32 role, address account) private {
        if (hasRole(role, account)) {
            _roles[role].members[account] = false;
            emit RoleRevoked(role, account, _msgSender());
        }
    }
}// MIT
pragma solidity >=0.8.4 <0.9.0;

interface IGovernable {

  event PendingGovernorSet(address pendingGovernor);
  event GovernorAccepted();

  function setPendingGovernor(address _pendingGovernor) external;


  function acceptGovernor() external;


  function governor() external view returns (address _governor);


  function pendingGovernor() external view returns (address _pendingGovernor);


  function isGovernor(address _account) external view returns (bool _isGovernor);

}// MIT
pragma solidity >=0.8.4 <0.9.0;


contract Governable is IGovernable {

  address public override governor;
  address public override pendingGovernor;

  constructor(address _governor) {
    require(_governor != address(0), 'governable/governor-should-not-be-zero-address');
    governor = _governor;
  }

  function setPendingGovernor(address _pendingGovernor) external virtual override onlyGovernor {

    _setPendingGovernor(_pendingGovernor);
  }

  function acceptGovernor() external virtual override onlyPendingGovernor {

    _acceptGovernor();
  }

  function _setPendingGovernor(address _pendingGovernor) internal {

    require(_pendingGovernor != address(0), 'governable/pending-governor-should-not-be-zero-addres');
    pendingGovernor = _pendingGovernor;
    emit PendingGovernorSet(_pendingGovernor);
  }

  function _acceptGovernor() internal {

    governor = pendingGovernor;
    pendingGovernor = address(0);
    emit GovernorAccepted();
  }

  function isGovernor(address _account) public view override returns (bool _isGovernor) {

    return _account == governor;
  }

  modifier onlyGovernor() {

    require(isGovernor(msg.sender), 'governable/only-governor');
    _;
  }

  modifier onlyPendingGovernor() {

    require(msg.sender == pendingGovernor, 'governable/only-pending-governor');
    _;
  }
}// MIT
pragma solidity >=0.8.4 <0.9.0;

library CommonErrors {

  error ZeroAddress();
  error NotAuthorized();
  error ZeroAmount();
  error ZeroSlippage();
  error IncorrectSwapInformation();
}// MIT
pragma solidity >=0.8.4 <0.9.0;




interface ISwapper {

  enum SwapperType {
    ASYNC,
    SYNC
  }

  function TRADE_FACTORY() external view returns (address);


  function SWAPPER_TYPE() external view returns (SwapperType);

}

abstract contract Swapper is ISwapper, Governable, CollectableDust {
  using SafeERC20 for IERC20;

  address public immutable override TRADE_FACTORY;

  constructor(address _tradeFactory) {
    if (_tradeFactory == address(0)) revert CommonErrors.ZeroAddress();
    TRADE_FACTORY = _tradeFactory;
  }

  modifier onlyTradeFactory() {
    if (msg.sender != TRADE_FACTORY) revert CommonErrors.NotAuthorized();
    _;
  }

  function sendDust(
    address _to,
    address _token,
    uint256 _amount
  ) external virtual override onlyGovernor {
    _sendDust(_to, _token, _amount);
  }
}// MIT
pragma solidity >=0.8.4 <0.9.0;



abstract contract TradeFactoryAccessManager is AccessControl {
  bytes32 public constant MASTER_ADMIN = keccak256('MASTER_ADMIN');

  constructor(address _masterAdmin) {
    if (_masterAdmin == address(0)) revert CommonErrors.ZeroAddress();
    _setRoleAdmin(MASTER_ADMIN, MASTER_ADMIN);
    _setupRole(MASTER_ADMIN, _masterAdmin);
  }
}// MIT
pragma solidity >=0.8.4 <0.9.0;




interface ITradeFactorySwapperHandler {

  event SyncStrategySwapperSet(address indexed _strategy, address _swapper);
  event AsyncStrategySwapperSet(address indexed _strategy, address _swapper);
  event StrategyPermissionsSet(address indexed _strategy, bytes1 _permissions);
  event OTCPoolSet(address _otcPool);
  event SwappersAdded(address[] _swappers);
  event SwappersRemoved(address[] _swapper);

  error NotAsyncSwapper();
  error NotSyncSwapper();
  error InvalidSwapper();
  error InvalidPermissions();
  error SwapperInUse();

  function strategySyncSwapper(address _strategy) external view returns (address _swapper);


  function strategyPermissions(address _strategy) external view returns (bytes1 _permissions);


  function swappers() external view returns (address[] memory _swappersList);


  function isSwapper(address _swapper) external view returns (bool _isSwapper);


  function swapperStrategies(address _swapper) external view returns (address[] memory _strategies);


  function setStrategyPermissions(address _strategy, bytes1 _permissions) external;


  function setOTCPool(address _otcPool) external;


  function setStrategySyncSwapper(address _strategy, address _swapper) external;


  function addSwappers(address[] memory __swappers) external;


  function removeSwappers(address[] memory __swappers) external;

}

abstract contract TradeFactorySwapperHandler is ITradeFactorySwapperHandler, TradeFactoryAccessManager {
  using EnumerableSet for EnumerableSet.AddressSet;

  bytes32 public constant SWAPPER_ADDER = keccak256('SWAPPER_ADDER');
  bytes32 public constant SWAPPER_SETTER = keccak256('SWAPPER_SETTER');

  bytes1 internal constant _OTC_MASK = 0x01;
  bytes1 internal constant _COW_MASK = 0x02;

  address public otcPool;
  EnumerableSet.AddressSet internal _swappers;
  mapping(address => EnumerableSet.AddressSet) internal _swapperStrategies;
  mapping(address => address) public override strategySyncSwapper;
  mapping(address => bytes1) public override strategyPermissions;

  constructor(address _swapperAdder, address _swapperSetter) {
    if (_swapperAdder == address(0) || _swapperSetter == address(0)) revert CommonErrors.ZeroAddress();
    _setRoleAdmin(SWAPPER_ADDER, MASTER_ADMIN);
    _setRoleAdmin(SWAPPER_SETTER, MASTER_ADMIN);
    _setupRole(SWAPPER_ADDER, _swapperAdder);
    _setupRole(SWAPPER_SETTER, _swapperSetter);
  }

  function isSwapper(address _swapper) external view override returns (bool _isSwapper) {
    _isSwapper = _swappers.contains(_swapper);
  }

  function swappers() external view override returns (address[] memory _swappersList) {
    _swappersList = _swappers.values();
  }

  function swapperStrategies(address _swapper) external view override returns (address[] memory _strategies) {
    _strategies = _swapperStrategies[_swapper].values();
  }

  function setStrategyPermissions(address _strategy, bytes1 _permissions) external override onlyRole(SWAPPER_SETTER) {
    if (_strategy == address(0)) revert CommonErrors.ZeroAddress();
    strategyPermissions[_strategy] = _permissions;
    emit StrategyPermissionsSet(_strategy, _permissions);
  }

  function setOTCPool(address _otcPool) external override onlyRole(MASTER_ADMIN) {
    if (_otcPool == address(0)) revert CommonErrors.ZeroAddress();
    otcPool = _otcPool;
    emit OTCPoolSet(_otcPool);
  }

  function setStrategySyncSwapper(address _strategy, address _swapper) external override onlyRole(SWAPPER_SETTER) {
    if (_strategy == address(0) || _swapper == address(0)) revert CommonErrors.ZeroAddress();
    if (ISwapper(_swapper).SWAPPER_TYPE() != ISwapper.SwapperType.SYNC) revert NotSyncSwapper();
    if (!_swappers.contains(_swapper)) revert InvalidSwapper();
    if (strategySyncSwapper[_strategy] != address(0)) _swapperStrategies[strategySyncSwapper[_strategy]].remove(_strategy);
    strategySyncSwapper[_strategy] = _swapper;
    _swapperStrategies[_swapper].add(_strategy);
    emit SyncStrategySwapperSet(_strategy, _swapper);
  }

  function addSwappers(address[] memory __swappers) external override onlyRole(SWAPPER_ADDER) {
    for (uint256 i; i < __swappers.length; i++) {
      if (__swappers[i] == address(0)) revert CommonErrors.ZeroAddress();
      _swappers.add(__swappers[i]);
    }
    emit SwappersAdded(__swappers);
  }

  function removeSwappers(address[] memory __swappers) external override onlyRole(SWAPPER_ADDER) {
    for (uint256 i; i < __swappers.length; i++) {
      if (_swapperStrategies[__swappers[i]].length() > 0) revert SwapperInUse();
      _swappers.remove(__swappers[i]);
    }
    emit SwappersRemoved(__swappers);
  }
}// MIT
pragma solidity >=0.8.4 <0.9.0;


interface ITradeFactoryPositionsHandler {

  struct Trade {
    uint256 _id;
    address _strategy;
    address _tokenIn;
    address _tokenOut;
    uint256 _amountIn;
    uint256 _deadline;
  }

  event TradeCreated(uint256 indexed _id, address _strategy, address _tokenIn, address _tokenOut, uint256 _amountIn, uint256 _deadline);

  event TradesCanceled(address indexed _strategy, uint256[] _ids);

  event TradesSwapperChanged(uint256[] _ids, address _newSwapper);

  event TradesMerged(uint256 indexed _anchorTrade, uint256[] _ids);

  error InvalidTrade();

  error InvalidDeadline();

  function pendingTradesById(uint256)
    external
    view
    returns (
      uint256 _id,
      address _strategy,
      address _tokenIn,
      address _tokenOut,
      uint256 _amountIn,
      uint256 _deadline
    );


  function pendingTradesIds() external view returns (uint256[] memory _pendingIds);


  function pendingTradesIds(address _strategy) external view returns (uint256[] memory _pendingIds);


  function create(
    address _tokenIn,
    address _tokenOut,
    uint256 _amountIn,
    uint256 _deadline
  ) external returns (uint256 _id);


  function cancelPendingTrades(uint256[] calldata _ids) external;


  function mergePendingTrades(uint256 _anchorTradeId, uint256[] calldata _toMergeIds) external;

}

abstract contract TradeFactoryPositionsHandler is ITradeFactoryPositionsHandler, TradeFactorySwapperHandler {
  using EnumerableSet for EnumerableSet.UintSet;
  using EnumerableSet for EnumerableSet.AddressSet;

  bytes32 public constant STRATEGY = keccak256('STRATEGY');
  bytes32 public constant STRATEGY_ADDER = keccak256('STRATEGY_ADDER');
  bytes32 public constant TRADES_MODIFIER = keccak256('TRADES_MODIFIER');

  uint256 private _tradeCounter = 1;

  mapping(uint256 => Trade) public override pendingTradesById;

  EnumerableSet.UintSet internal _pendingTradesIds;

  mapping(address => EnumerableSet.UintSet) internal _pendingTradesByOwner;

  constructor(address _strategyAdder, address _tradesModifier) {
    if (_strategyAdder == address(0) || _tradesModifier == address(0)) revert CommonErrors.ZeroAddress();
    _setRoleAdmin(STRATEGY, STRATEGY_ADDER);
    _setRoleAdmin(STRATEGY_ADDER, MASTER_ADMIN);
    _setupRole(STRATEGY_ADDER, _strategyAdder);
    _setRoleAdmin(TRADES_MODIFIER, MASTER_ADMIN);
    _setupRole(TRADES_MODIFIER, _tradesModifier);
  }

  function pendingTradesIds() external view override returns (uint256[] memory _pendingIds) {
    _pendingIds = _pendingTradesIds.values();
  }

  function pendingTradesIds(address _strategy) external view override returns (uint256[] memory _pendingIds) {
    _pendingIds = _pendingTradesByOwner[_strategy].values();
  }

  function create(
    address _tokenIn,
    address _tokenOut,
    uint256 _amountIn,
    uint256 _deadline
  ) external override onlyRole(STRATEGY) returns (uint256 _id) {
    if (_tokenIn == address(0) || _tokenOut == address(0)) revert CommonErrors.ZeroAddress();
    if (_amountIn == 0) revert CommonErrors.ZeroAmount();
    if (_deadline <= block.timestamp) revert InvalidDeadline();
    _id = _tradeCounter;
    Trade memory _trade = Trade(_tradeCounter, msg.sender, _tokenIn, _tokenOut, _amountIn, _deadline);
    pendingTradesById[_trade._id] = _trade;
    _pendingTradesByOwner[msg.sender].add(_trade._id);
    _pendingTradesIds.add(_trade._id);
    _tradeCounter += 1;
    emit TradeCreated(_trade._id, _trade._strategy, _trade._tokenIn, _trade._tokenOut, _trade._amountIn, _trade._deadline);
  }

  function cancelPendingTrades(uint256[] calldata _ids) external override onlyRole(STRATEGY) {
    for (uint256 i; i < _ids.length; i++) {
      if (!_pendingTradesIds.contains(_ids[i])) revert InvalidTrade();
      if (pendingTradesById[_ids[i]]._strategy != msg.sender) revert CommonErrors.NotAuthorized();
      _removePendingTrade(msg.sender, _ids[i]);
    }
    emit TradesCanceled(msg.sender, _ids);
  }

  function mergePendingTrades(uint256 _anchorTradeId, uint256[] calldata _toMergeIds) external override onlyRole(TRADES_MODIFIER) {
    Trade storage _anchorTrade = pendingTradesById[_anchorTradeId];
    for (uint256 i; i < _toMergeIds.length; i++) {
      Trade storage _trade = pendingTradesById[_toMergeIds[i]];
      if (
        _anchorTrade._id == _trade._id ||
        _anchorTrade._strategy != _trade._strategy ||
        _anchorTrade._tokenIn != _trade._tokenIn ||
        _anchorTrade._tokenOut != _trade._tokenOut
      ) revert InvalidTrade();
      _anchorTrade._amountIn += _trade._amountIn;
      _removePendingTrade(_trade._strategy, _trade._id);
    }
    emit TradesMerged(_anchorTradeId, _toMergeIds);
  }

  function _removePendingTrade(address _strategy, uint256 _id) internal {
    _pendingTradesByOwner[_strategy].remove(_id);
    _pendingTradesIds.remove(_id);
    delete pendingTradesById[_id];
  }
}// MIT

pragma solidity ^0.8.0;

library Math {

    function max(uint256 a, uint256 b) internal pure returns (uint256) {

        return a >= b ? a : b;
    }

    function min(uint256 a, uint256 b) internal pure returns (uint256) {

        return a < b ? a : b;
    }

    function average(uint256 a, uint256 b) internal pure returns (uint256) {

        return (a & b) + (a ^ b) / 2;
    }

    function ceilDiv(uint256 a, uint256 b) internal pure returns (uint256) {

        return a / b + (a % b == 0 ? 0 : 1);
    }
}// MIT

pragma solidity ^0.8.0;


interface IERC20Metadata is IERC20 {

    function name() external view returns (string memory);


    function symbol() external view returns (string memory);


    function decimals() external view returns (uint8);

}// MIT
pragma solidity >=0.8.4 <0.9.0;

interface IMachinery {

  function mechanicsRegistry() external view returns (address _mechanicsRegistry);


  function isMechanic(address mechanic) external view returns (bool _isMechanic);


  function setMechanicsRegistry(address _mechanicsRegistry) external;

}// MIT
pragma solidity >=0.8.4 <0.9.0;

interface IMechanicsRegistry {

  event MechanicAdded(address _mechanic);
  event MechanicRemoved(address _mechanic);

  function addMechanic(address _mechanic) external;


  function removeMechanic(address _mechanic) external;


  function mechanics() external view returns (address[] memory _mechanicsList);


  function isMechanic(address mechanic) external view returns (bool _isMechanic);

}// MIT
pragma solidity >=0.8.4 <0.9.0;


contract Machinery is IMachinery {

  using EnumerableSet for EnumerableSet.AddressSet;

  IMechanicsRegistry internal _mechanicsRegistry;

  constructor(address __mechanicsRegistry) {
    _setMechanicsRegistry(__mechanicsRegistry);
  }

  modifier onlyMechanic() {

    require(_mechanicsRegistry.isMechanic(msg.sender), 'Machinery: not mechanic');
    _;
  }

  function setMechanicsRegistry(address __mechanicsRegistry) external virtual override {

    _setMechanicsRegistry(__mechanicsRegistry);
  }

  function _setMechanicsRegistry(address __mechanicsRegistry) internal {

    _mechanicsRegistry = IMechanicsRegistry(__mechanicsRegistry);
  }

  function mechanicsRegistry() external view override returns (address _mechanicRegistry) {

    return address(_mechanicsRegistry);
  }

  function isMechanic(address _mechanic) public view override returns (bool _isMechanic) {

    return _mechanicsRegistry.isMechanic(_mechanic);
  }
}// MIT
pragma solidity >=0.8.4 <0.9.0;


interface IAsyncSwapper is ISwapper {

  event Swapped(
    address _receiver,
    address _tokenIn,
    address _tokenOut,
    uint256 _amountIn,
    uint256 _minAmountOut,
    uint256 _receivedAmount,
    bytes _data
  );

  error InvalidAmountOut();

  function swap(
    address _receiver,
    address _tokenIn,
    address _tokenOut,
    uint256 _amountIn,
    uint256 _minAmountOut,
    bytes calldata _data
  ) external returns (uint256 _receivedAmount);

}

abstract contract AsyncSwapper is IAsyncSwapper, Swapper {
  SwapperType public constant override SWAPPER_TYPE = SwapperType.ASYNC;

  constructor(address _governor, address _tradeFactory) Governable(_governor) Swapper(_tradeFactory) {}

  function _assertPreSwap(
    address _receiver,
    address _tokenIn,
    address _tokenOut,
    uint256 _amountIn,
    uint256 _minAmountOut
  ) internal pure {
    if (_receiver == address(0) || _tokenIn == address(0) || _tokenOut == address(0)) revert CommonErrors.ZeroAddress();
    if (_amountIn == 0) revert CommonErrors.ZeroAmount();
    if (_minAmountOut == 0) revert CommonErrors.ZeroAmount();
  }

  function _executeSwap(
    address _receiver,
    address _tokenIn,
    address _tokenOut,
    uint256 _amountIn,
    bytes calldata _data
  ) internal virtual returns (uint256 _receivedAmount);

  function swap(
    address _receiver,
    address _tokenIn,
    address _tokenOut,
    uint256 _amountIn,
    uint256 _minAmountOut,
    bytes calldata _data
  ) external virtual override onlyTradeFactory returns (uint256 _receivedAmount) {
    _assertPreSwap(_receiver, _tokenIn, _tokenOut, _amountIn, _minAmountOut);
    uint256 _preExecutionBalance = IERC20(_tokenOut).balanceOf(_receiver);
    _receivedAmount = _executeSwap(_receiver, _tokenIn, _tokenOut, _amountIn, _data);
    if (IERC20(_tokenOut).balanceOf(_receiver) - _preExecutionBalance < _minAmountOut) revert InvalidAmountOut();
    emit Swapped(_receiver, _tokenIn, _tokenOut, _amountIn, _minAmountOut, _receivedAmount, _data);
  }
}// MIT
pragma solidity >=0.8.4 <0.9.0;


interface ISyncSwapper is ISwapper {

  event Swapped(
    address _receiver,
    address _tokenIn,
    address _tokenOut,
    uint256 _amountIn,
    uint256 _maxSlippage,
    uint256 _receivedAmount,
    bytes _data
  );

  function SLIPPAGE_PRECISION() external view returns (uint256);


  function swap(
    address _receiver,
    address _tokenIn,
    address _tokenOut,
    uint256 _amountIn,
    uint256 _maxSlippage,
    bytes calldata _data
  ) external returns (uint256 _receivedAmount);

}

abstract contract SyncSwapper is ISyncSwapper, Swapper {
  uint256 public immutable override SLIPPAGE_PRECISION = 10000; // 1 is 0.0001%, 1_000 is 0.1%

  SwapperType public constant override SWAPPER_TYPE = SwapperType.SYNC;

  constructor(address _governor, address _tradeFactory) Governable(_governor) Swapper(_tradeFactory) {}

  function _assertPreSwap(
    address _receiver,
    address _tokenIn,
    address _tokenOut,
    uint256 _amountIn,
    uint256 _maxSlippage
  ) internal pure {
    if (_receiver == address(0) || _tokenIn == address(0) || _tokenOut == address(0)) revert CommonErrors.ZeroAddress();
    if (_amountIn == 0) revert CommonErrors.ZeroAmount();
    if (_maxSlippage == 0) revert CommonErrors.ZeroSlippage();
  }

  function _executeSwap(
    address _receiver,
    address _tokenIn,
    address _tokenOut,
    uint256 _amountIn,
    uint256 _maxSlippage,
    bytes calldata _data
  ) internal virtual returns (uint256 _receivedAmount);

  function swap(
    address _receiver,
    address _tokenIn,
    address _tokenOut,
    uint256 _amountIn,
    uint256 _maxSlippage,
    bytes calldata _data
  ) external virtual override onlyTradeFactory returns (uint256 _receivedAmount) {
    _assertPreSwap(_receiver, _tokenIn, _tokenOut, _amountIn, _maxSlippage);
    _receivedAmount = _executeSwap(_receiver, _tokenIn, _tokenOut, _amountIn, _maxSlippage, _data);
    emit Swapped(_receiver, _tokenIn, _tokenOut, _amountIn, _maxSlippage, _receivedAmount, _data);
  }
}// MIT
pragma solidity >=0.8.4 <0.9.0;




interface IOTCPool is IGovernable {

  event TradeFactorySet(address indexed _tradeFactory);

  event OfferCreate(address indexed _offeredToken, uint256 _amount);

  event OfferTaken(address indexed _wantedToken, uint256 _amount, address _receiver);

  function tradeFactory() external view returns (address);


  function offers(address) external view returns (uint256);


  function setTradeFactory(address _tradeFactory) external;


  function create(address _offeredToken, uint256 _amount) external;


  function take(
    address _wantedToken,
    uint256 _amount,
    address _receiver
  ) external;

}

contract OTCPool is IOTCPool, CollectableDust, Governable {

  using SafeERC20 for IERC20;

  address public override tradeFactory;

  mapping(address => uint256) public override offers;

  constructor(address _governor, address _tradeFactory) Governable(_governor) {
    if (_tradeFactory == address(0)) revert CommonErrors.ZeroAddress();
    tradeFactory = _tradeFactory;
  }

  modifier onlyTradeFactory() {

    if (msg.sender != tradeFactory) revert CommonErrors.NotAuthorized();
    _;
  }

  function setTradeFactory(address _tradeFactory) external override onlyGovernor {

    if (_tradeFactory == address(0)) revert CommonErrors.ZeroAddress();
    tradeFactory = _tradeFactory;
    emit TradeFactorySet(_tradeFactory);
  }

  function create(address _offeredToken, uint256 _amount) external override onlyGovernor {

    if (_offeredToken == address(0)) revert CommonErrors.ZeroAddress();
    if (_amount == 0) revert CommonErrors.ZeroAmount();
    if (IERC20(_offeredToken).allowance(governor, address(this)) < offers[_offeredToken]) revert CommonErrors.NotAuthorized();
    offers[_offeredToken] += _amount;
    emit OfferCreate(_offeredToken, _amount);
  }

  function take(
    address _wantedToken,
    uint256 _amount,
    address _receiver
  ) external override onlyTradeFactory {

    IERC20(_wantedToken).safeTransferFrom(governor, _receiver, _amount);
    offers[_wantedToken] -= _amount;
    emit OfferTaken(_wantedToken, _amount, _receiver);
  }

  function sendDust(
    address _to,
    address _token,
    uint256 _amount
  ) external override onlyGovernor {

    _sendDust(_to, _token, _amount);
  }
}// MIT
pragma solidity >=0.8.4 <0.9.0;






interface ITradeFactoryExecutor {

  event SyncTradeExecuted(
    address indexed _strategy,
    address indexed _swapper,
    address _tokenIn,
    address _tokenOut,
    uint256 _amountIn,
    uint256 _maxSlippage,
    bytes _data,
    uint256 _receivedAmount
  );

  event AsyncTradeExecuted(uint256 indexed _id, uint256 _receivedAmount);

  event AsyncTradesMatched(
    uint256 indexed _firstTradeId,
    uint256 indexed _secondTradeId,
    uint256 _consumedFirstTrade,
    uint256 _consumedSecondTrade
  );

  event AsyncOTCTradesExecuted(uint256[] _ids, uint256 _rateTokenInToOut);

  event AsyncTradeExpired(uint256 indexed _id);

  event SwapperAndTokenEnabled(address indexed _swapper, address _token);

  error OngoingTrade();

  error ExpiredTrade();

  error ZeroRate();

  function execute(
    address _tokenIn,
    address _tokenOut,
    uint256 _amountIn,
    uint256 _maxSlippage,
    bytes calldata _data
  ) external returns (uint256 _receivedAmount);


  function execute(
    uint256 _id,
    address _swapper,
    uint256 _minAmountOut,
    bytes calldata _data
  ) external returns (uint256 _receivedAmount);


  function expire(uint256 _id) external returns (uint256 _freedAmount);


  function execute(uint256[] calldata _ids, uint256 _rateTokenInToOut) external;


  function execute(
    uint256 _firstTradeId,
    uint256 _secondTradeId,
    uint256 _consumedFirstTrade,
    uint256 _consumedSecondTrade
  ) external;

}

abstract contract TradeFactoryExecutor is ITradeFactoryExecutor, TradeFactoryPositionsHandler, Machinery {
  using SafeERC20 for IERC20;
  using EnumerableSet for EnumerableSet.UintSet;
  using EnumerableSet for EnumerableSet.AddressSet;

  bytes32 public constant TRADES_SETTLER = keccak256('TRADES_SETTLER');

  constructor(address _tradesSettler, address _mechanicsRegistry) Machinery(_mechanicsRegistry) {
    _setRoleAdmin(TRADES_SETTLER, MASTER_ADMIN);
    _setupRole(TRADES_SETTLER, _tradesSettler);
  }

  function setMechanicsRegistry(address _mechanicsRegistry) external virtual override onlyRole(MASTER_ADMIN) {
    _setMechanicsRegistry(_mechanicsRegistry);
  }

  function execute(
    address _tokenIn,
    address _tokenOut,
    uint256 _amountIn,
    uint256 _maxSlippage,
    bytes calldata _data
  ) external override onlyRole(STRATEGY) returns (uint256 _receivedAmount) {
    address _swapper = strategySyncSwapper[msg.sender];
    if (_tokenIn == address(0) || _tokenOut == address(0)) revert CommonErrors.ZeroAddress();
    if (_amountIn == 0) revert CommonErrors.ZeroAmount();
    if (_maxSlippage == 0) revert CommonErrors.ZeroSlippage();
    IERC20(_tokenIn).safeTransferFrom(msg.sender, _swapper, _amountIn);
    _receivedAmount = ISyncSwapper(_swapper).swap(msg.sender, _tokenIn, _tokenOut, _amountIn, _maxSlippage, _data);
    emit SyncTradeExecuted(msg.sender, _swapper, _tokenIn, _tokenOut, _amountIn, _maxSlippage, _data, _receivedAmount);
  }

  function execute(
    uint256 _id,
    address _swapper,
    uint256 _minAmountOut,
    bytes calldata _data
  ) external override onlyMechanic returns (uint256 _receivedAmount) {
    if (!_pendingTradesIds.contains(_id)) revert InvalidTrade();
    Trade storage _trade = pendingTradesById[_id];
    if (block.timestamp > _trade._deadline) revert ExpiredTrade();
    if (!_swappers.contains(_swapper)) revert InvalidSwapper();
    IERC20(_trade._tokenIn).safeTransferFrom(_trade._strategy, _swapper, _trade._amountIn);
    _receivedAmount = IAsyncSwapper(_swapper).swap(_trade._strategy, _trade._tokenIn, _trade._tokenOut, _trade._amountIn, _minAmountOut, _data);
    _removePendingTrade(_trade._strategy, _id);
    emit AsyncTradeExecuted(_id, _receivedAmount);
  }

  function expire(uint256 _id) external override onlyMechanic returns (uint256 _freedAmount) {
    if (!_pendingTradesIds.contains(_id)) revert InvalidTrade();
    Trade storage _trade = pendingTradesById[_id];
    if (block.timestamp < _trade._deadline) revert OngoingTrade();
    _freedAmount = _trade._amountIn;
    IERC20(_trade._tokenIn).safeTransferFrom(_trade._strategy, address(this), _trade._amountIn);
    IERC20(_trade._tokenIn).safeTransfer(_trade._strategy, _trade._amountIn);
    _removePendingTrade(_trade._strategy, _id);
    emit AsyncTradeExpired(_id);
  }

  function execute(uint256[] calldata _ids, uint256 _rateTokenInToOut) external override onlyMechanic {
    if (_rateTokenInToOut == 0) revert ZeroRate();
    address _tokenIn = pendingTradesById[_ids[0]]._tokenIn;
    address _tokenOut = pendingTradesById[_ids[0]]._tokenOut;
    uint256 _magnitudeIn = 10**IERC20Metadata(_tokenIn).decimals();
    for (uint256 i; i < _ids.length; i++) {
      Trade storage _trade = pendingTradesById[_ids[i]];
      if (i > 0 && (_trade._tokenIn != _tokenIn || _trade._tokenOut != _tokenOut)) revert InvalidTrade();
      if (block.timestamp > _trade._deadline) revert ExpiredTrade();
      if ((strategyPermissions[_trade._strategy] & _OTC_MASK) != _OTC_MASK) revert CommonErrors.NotAuthorized();
      uint256 _consumedOut = (_trade._amountIn * _rateTokenInToOut) / _magnitudeIn;
      IERC20(_trade._tokenIn).safeTransferFrom(_trade._strategy, IOTCPool(otcPool).governor(), _trade._amountIn);
      IOTCPool(otcPool).take(_trade._tokenOut, _consumedOut, _trade._strategy);
      _removePendingTrade(_trade._strategy, _trade._id);
    }
    emit AsyncOTCTradesExecuted(_ids, _rateTokenInToOut);
  }

  function execute(
    uint256 _firstTradeId,
    uint256 _secondTradeId,
    uint256 _consumedFirstTrade,
    uint256 _consumedSecondTrade
  ) external override onlyRole(TRADES_SETTLER) {
    Trade storage _firstTrade = pendingTradesById[_firstTradeId];
    Trade storage _secondTrade = pendingTradesById[_secondTradeId];
    if (_firstTrade._tokenIn != _secondTrade._tokenOut || _firstTrade._tokenOut != _secondTrade._tokenIn) revert InvalidTrade();
    if (block.timestamp > _firstTrade._deadline || block.timestamp > _secondTrade._deadline) revert ExpiredTrade();
    if (
      (strategyPermissions[_firstTrade._strategy] & _COW_MASK) != _COW_MASK ||
      (strategyPermissions[_secondTrade._strategy] & _COW_MASK) != _COW_MASK
    ) revert CommonErrors.NotAuthorized();

    IERC20(_firstTrade._tokenIn).safeTransferFrom(_firstTrade._strategy, _secondTrade._strategy, _consumedFirstTrade);
    IERC20(_secondTrade._tokenIn).safeTransferFrom(_secondTrade._strategy, _firstTrade._strategy, _consumedSecondTrade);

    if (_consumedFirstTrade != _firstTrade._amountIn) {
      _firstTrade._amountIn -= _consumedFirstTrade;
    } else {
      _removePendingTrade(_firstTrade._strategy, _firstTradeId);
    }

    if (_consumedSecondTrade != _secondTrade._amountIn) {
      _secondTrade._amountIn -= _consumedSecondTrade;
    } else {
      _removePendingTrade(_secondTrade._strategy, _secondTradeId);
    }

    emit AsyncTradesMatched(_firstTradeId, _secondTradeId, _consumedFirstTrade, _consumedSecondTrade);
  }
}// MIT
pragma solidity >=0.8.4 <0.9.0;



interface ITradeFactory is ITradeFactoryExecutor, ITradeFactoryPositionsHandler {}


contract TradeFactory is TradeFactoryExecutor, CollectableDust, ITradeFactory {

  constructor(
    address _masterAdmin,
    address _swapperAdder,
    address _swapperSetter,
    address _strategyAdder,
    address _tradesModifier,
    address _tradesSettler,
    address _mechanicsRegistry
  )
    TradeFactoryAccessManager(_masterAdmin)
    TradeFactoryPositionsHandler(_strategyAdder, _tradesModifier)
    TradeFactorySwapperHandler(_swapperAdder, _swapperSetter)
    TradeFactoryExecutor(_tradesSettler, _mechanicsRegistry)
  {}

  function sendDust(
    address _to,
    address _token,
    uint256 _amount
  ) external virtual override onlyRole(MASTER_ADMIN) {

    _sendDust(_to, _token, _amount);
  }
}