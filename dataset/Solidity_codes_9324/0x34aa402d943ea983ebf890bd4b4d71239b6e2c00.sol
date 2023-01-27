
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

  error NotAsyncSwapper();
  error NotSyncSwapper();
  error InvalidSwapper();
  error SwapperInUse();

  function strategySyncSwapper(address _strategy) external view returns (address _swapper);


  function swappers() external view returns (address[] memory _swappersList);


  function isSwapper(address _swapper) external view returns (bool _isSwapper);


  function swapperStrategies(address _swapper) external view returns (address[] memory _strategies);


  function setStrategySyncSwapper(address _strategy, address _swapper) external;


  function addSwappers(address[] memory __swappers) external;


  function removeSwappers(address[] memory __swappers) external;

}

abstract contract TradeFactorySwapperHandler is ITradeFactorySwapperHandler, TradeFactoryAccessManager {
  using EnumerableSet for EnumerableSet.AddressSet;

  bytes32 public constant SWAPPER_ADDER = keccak256('SWAPPER_ADDER');
  bytes32 public constant SWAPPER_SETTER = keccak256('SWAPPER_SETTER');

  EnumerableSet.AddressSet internal _swappers;
  mapping(address => EnumerableSet.AddressSet) internal _swapperStrategies;
  mapping(address => address) public override strategySyncSwapper;

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

  function setStrategySyncSwapper(address _strategy, address _swapper) external override onlyRole(SWAPPER_SETTER) {
    if (_strategy == address(0) || _swapper == address(0)) revert CommonErrors.ZeroAddress();
    if (ISwapper(_swapper).SWAPPER_TYPE() != ISwapper.SwapperType.SYNC) revert NotSyncSwapper();
    if (!_swappers.contains(_swapper)) revert InvalidSwapper();
    if (strategySyncSwapper[_strategy] != address(0)) _swapperStrategies[strategySyncSwapper[_strategy]].remove(_strategy);
    strategySyncSwapper[_strategy] = _swapper;
    _swapperStrategies[_swapper].add(_strategy);
  }

  function addSwappers(address[] memory __swappers) external override onlyRole(SWAPPER_ADDER) {
    for (uint256 i; i < __swappers.length; i++) {
      if (__swappers[i] == address(0)) revert CommonErrors.ZeroAddress();
      _swappers.add(__swappers[i]);
    }
  }

  function removeSwappers(address[] memory __swappers) external override onlyRole(SWAPPER_ADDER) {
    for (uint256 i; i < __swappers.length; i++) {
      if (_swapperStrategies[__swappers[i]].length() > 0) revert SwapperInUse();
      _swappers.remove(__swappers[i]);
    }
  }
}// MIT

pragma solidity >=0.8.4 <0.9.0;

interface ISwapperEnabled {

  error NotTradeFactory();

  function tradeFactory() external returns (address _tradeFactory);


  function swapper() external returns (string memory _swapper);


  function setSwapper(string calldata _swapper, bool _migrateSwaps) external;


  function setTradeFactory(address _tradeFactory) external;


  function enableTrade(address _tokenIn, address _tokenOut) external;


  function disableTrade(address _tokenIn, address _tokenOut) external;


  function disableTradeCallback(address _tokenIn, address _tokenOut) external;

}// MIT
pragma solidity >=0.8.4 <0.9.0;



interface ITradeFactoryPositionsHandler {

  struct EnabledTrade {
    address _strategy;
    address _tokenIn;
    address _tokenOut;
  }

  error InvalidTrade();

  error AllowanceShouldBeZero();

  function enabledTrades() external view returns (EnabledTrade[] memory _enabledTrades);


  function enable(address _tokenIn, address _tokenOut) external;


  function disable(address _tokenIn, address _tokenOut) external;


  function disableByAdmin(
    address _strategy,
    address _tokenIn,
    address _tokenOut
  ) external;

}

abstract contract TradeFactoryPositionsHandler is ITradeFactoryPositionsHandler, TradeFactorySwapperHandler {
  using EnumerableSet for EnumerableSet.AddressSet;

  bytes32 public constant STRATEGY = keccak256('STRATEGY');
  bytes32 public constant STRATEGY_MANAGER = keccak256('STRATEGY_MANAGER');

  EnumerableSet.AddressSet internal _strategies;

  mapping(address => EnumerableSet.AddressSet) internal _tokensInByStrategy;

  mapping(address => mapping(address => EnumerableSet.AddressSet)) internal _tokensOutByStrategyAndTokenIn;

  constructor(address _strategyModifier) {
    if (_strategyModifier == address(0)) revert CommonErrors.ZeroAddress();
    _setRoleAdmin(STRATEGY, STRATEGY_MANAGER);
    _setRoleAdmin(STRATEGY_MANAGER, MASTER_ADMIN);
    _setupRole(STRATEGY_MANAGER, _strategyModifier);
  }

  function enabledTrades() external view override returns (EnabledTrade[] memory _enabledTrades) {
    uint256 _totalEnabledTrades;
    for (uint256 i; i < _strategies.values().length; i++) {
      address _strategy = _strategies.at(i);
      address[] memory _tokensIn = _tokensInByStrategy[_strategy].values();
      for (uint256 j; j < _tokensIn.length; j++) {
        address _tokenIn = _tokensIn[j];
        _totalEnabledTrades += _tokensOutByStrategyAndTokenIn[_strategy][_tokenIn].length();
      }
    }
    _enabledTrades = new EnabledTrade[](_totalEnabledTrades);
    uint256 _enabledTradesIndex;
    for (uint256 i; i < _strategies.values().length; i++) {
      address _strategy = _strategies.at(i);
      address[] memory _tokensIn = _tokensInByStrategy[_strategy].values();
      for (uint256 j; j < _tokensIn.length; j++) {
        address _tokenIn = _tokensIn[j];
        address[] memory _tokensOut = _tokensOutByStrategyAndTokenIn[_strategy][_tokenIn].values();
        for (uint256 k; k < _tokensOut.length; k++) {
          _enabledTrades[_enabledTradesIndex] = EnabledTrade(_strategy, _tokenIn, _tokensOut[k]);
          _enabledTradesIndex++;
        }
      }
    }
  }

  function enable(address _tokenIn, address _tokenOut) external override onlyRole(STRATEGY) {
    if (_tokenIn == address(0) || _tokenOut == address(0)) revert CommonErrors.ZeroAddress();
    _strategies.add(msg.sender);
    _tokensInByStrategy[msg.sender].add(_tokenIn);
    if (!_tokensOutByStrategyAndTokenIn[msg.sender][_tokenIn].add(_tokenOut)) revert InvalidTrade();
  }

  function disable(address _tokenIn, address _tokenOut) external override onlyRole(STRATEGY) {
    _disable(msg.sender, _tokenIn, _tokenOut);
  }

  function disableByAdmin(
    address _strategy,
    address _tokenIn,
    address _tokenOut
  ) external override onlyRole(STRATEGY_MANAGER) {
    ISwapperEnabled(_strategy).disableTradeCallback(_tokenIn, _tokenOut);
  }

  function _disable(
    address _strategy,
    address _tokenIn,
    address _tokenOut
  ) internal {
    if (_tokenIn == address(0) || _tokenOut == address(0)) revert CommonErrors.ZeroAddress();
    if (IERC20(_tokenIn).allowance(msg.sender, address(this)) != 0) revert AllowanceShouldBeZero();
    if (!_tokensOutByStrategyAndTokenIn[_strategy][_tokenIn].remove(_tokenOut)) revert InvalidTrade();
    if (_tokensOutByStrategyAndTokenIn[_strategy][_tokenIn].length() == 0) {
      _tokensInByStrategy[_strategy].remove(_tokenIn);
      if (_tokensInByStrategy[_strategy].length() == 0) {
        _strategies.remove(_strategy);
      }
    }
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

  function swap(
    address _receiver,
    address _tokenIn,
    address _tokenOut,
    uint256 _amountIn,
    uint256 _minAmountOut,
    bytes calldata _data
  ) external;

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
  ) internal virtual;

  function swap(
    address _receiver,
    address _tokenIn,
    address _tokenOut,
    uint256 _amountIn,
    uint256 _minAmountOut,
    bytes calldata _data
  ) external virtual override onlyTradeFactory {
    _assertPreSwap(_receiver, _tokenIn, _tokenOut, _amountIn, _minAmountOut);
    _executeSwap(_receiver, _tokenIn, _tokenOut, _amountIn, _data);
  }
}// MIT
pragma solidity >=0.8.4 <0.9.0;


interface IMultipleAsyncSwapper is IAsyncSwapper {

  function swapMultiple(bytes calldata _data) external;

}

abstract contract MultipleAsyncSwapper is IMultipleAsyncSwapper, AsyncSwapper {
  constructor(address _governor, address _tradeFactory) AsyncSwapper(_governor, _tradeFactory) {}
}// MIT
pragma solidity >=0.8.4 <0.9.0;


interface ISyncSwapper is ISwapper {

  function SLIPPAGE_PRECISION() external view returns (uint256);


  function swap(
    address _receiver,
    address _tokenIn,
    address _tokenOut,
    uint256 _amountIn,
    uint256 _maxSlippage,
    bytes calldata _data
  ) external;

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
    uint256
  ) internal pure {
    if (_receiver == address(0) || _tokenIn == address(0) || _tokenOut == address(0)) revert CommonErrors.ZeroAddress();
    if (_amountIn == 0) revert CommonErrors.ZeroAmount();
  }

  function _executeSwap(
    address _receiver,
    address _tokenIn,
    address _tokenOut,
    uint256 _amountIn,
    uint256 _maxSlippage,
    bytes calldata _data
  ) internal virtual;

  function swap(
    address _receiver,
    address _tokenIn,
    address _tokenOut,
    uint256 _amountIn,
    uint256 _maxSlippage,
    bytes calldata _data
  ) external virtual override onlyTradeFactory {
    _assertPreSwap(_receiver, _tokenIn, _tokenOut, _amountIn, _maxSlippage);
    _executeSwap(_receiver, _tokenIn, _tokenOut, _amountIn, _maxSlippage, _data);
  }
}// MIT
pragma solidity >=0.8.4 <0.9.0;





interface ITradeFactoryExecutor {

  event SyncTradeExecuted(address indexed _strategy, uint256 _receivedAmount, address indexed _swapper);

  event AsyncTradeExecuted(uint256 _receivedAmount, address _swapper);

  event MultipleAsyncTradeExecuted(uint256[] _receivedAmount, address _swapper);

  error InvalidAmountOut();

  struct SyncTradeExecutionDetails {
    address _tokenIn;
    address _tokenOut;
    uint256 _amountIn;
    uint256 _maxSlippage;
  }

  struct AsyncTradeExecutionDetails {
    address _strategy;
    address _tokenIn;
    address _tokenOut;
    uint256 _amount;
    uint256 _minAmountOut;
  }

  function execute(SyncTradeExecutionDetails calldata _tradeExecutionDetails, bytes calldata _data) external returns (uint256 _receivedAmount);


  function execute(
    AsyncTradeExecutionDetails calldata _tradeExecutionDetails,
    address _swapper,
    bytes calldata _data
  ) external returns (uint256 _receivedAmount);


  function execute(
    AsyncTradeExecutionDetails[] calldata _tradesExecutionDetails,
    address _swapper,
    bytes calldata _data
  ) external;

}

abstract contract TradeFactoryExecutor is ITradeFactoryExecutor, TradeFactoryPositionsHandler, Machinery {
  using SafeERC20 for IERC20;
  using EnumerableSet for EnumerableSet.UintSet;
  using EnumerableSet for EnumerableSet.AddressSet;

  constructor(address _mechanicsRegistry) Machinery(_mechanicsRegistry) {}

  function setMechanicsRegistry(address __mechanicsRegistry) external virtual override onlyRole(MASTER_ADMIN) {
    _setMechanicsRegistry(__mechanicsRegistry);
  }

  function execute(SyncTradeExecutionDetails calldata _tradeExecutionDetails, bytes calldata _data)
    external
    override
    onlyRole(STRATEGY)
    returns (uint256 _receivedAmount)
  {
    address _swapper = strategySyncSwapper[msg.sender];
    if (_tradeExecutionDetails._tokenIn == address(0) || _tradeExecutionDetails._tokenOut == address(0)) revert CommonErrors.ZeroAddress();
    if (_tradeExecutionDetails._amountIn == 0) revert CommonErrors.ZeroAmount();
    if (_tradeExecutionDetails._maxSlippage == 0) revert CommonErrors.ZeroSlippage();
    IERC20(_tradeExecutionDetails._tokenIn).safeTransferFrom(msg.sender, _swapper, _tradeExecutionDetails._amountIn);
    uint256 _preSwapBalanceOut = IERC20(_tradeExecutionDetails._tokenOut).balanceOf(msg.sender);
    ISyncSwapper(_swapper).swap(
      msg.sender,
      _tradeExecutionDetails._tokenIn,
      _tradeExecutionDetails._tokenOut,
      _tradeExecutionDetails._amountIn,
      _tradeExecutionDetails._maxSlippage,
      _data
    );
    _receivedAmount = IERC20(_tradeExecutionDetails._tokenOut).balanceOf(msg.sender) - _preSwapBalanceOut;
    emit SyncTradeExecuted(msg.sender, _receivedAmount, _swapper);
  }

  function execute(
    AsyncTradeExecutionDetails calldata _tradeExecutionDetails,
    address _swapper,
    bytes calldata _data
  ) external override onlyMechanic returns (uint256 _receivedAmount) {
    if (
      !_tokensOutByStrategyAndTokenIn[_tradeExecutionDetails._strategy][_tradeExecutionDetails._tokenIn].contains(
        _tradeExecutionDetails._tokenOut
      )
    ) revert InvalidTrade();
    if (!_swappers.contains(_swapper)) revert InvalidSwapper();
    uint256 _amount = _tradeExecutionDetails._amount != 0
      ? _tradeExecutionDetails._amount
      : IERC20(_tradeExecutionDetails._tokenIn).balanceOf(_tradeExecutionDetails._strategy);
    IERC20(_tradeExecutionDetails._tokenIn).safeTransferFrom(_tradeExecutionDetails._strategy, _swapper, _amount);
    uint256 _preSwapBalanceOut = IERC20(_tradeExecutionDetails._tokenOut).balanceOf(_tradeExecutionDetails._strategy);
    IAsyncSwapper(_swapper).swap(
      _tradeExecutionDetails._strategy,
      _tradeExecutionDetails._tokenIn,
      _tradeExecutionDetails._tokenOut,
      _amount,
      _tradeExecutionDetails._minAmountOut,
      _data
    );
    _receivedAmount = IERC20(_tradeExecutionDetails._tokenOut).balanceOf(_tradeExecutionDetails._strategy) - _preSwapBalanceOut;
    if (_receivedAmount < _tradeExecutionDetails._minAmountOut) revert InvalidAmountOut();
    emit AsyncTradeExecuted(_receivedAmount, _swapper);
  }

  function execute(
    AsyncTradeExecutionDetails[] calldata _tradesExecutionDetails,
    address _swapper,
    bytes calldata _data
  ) external override onlyMechanic {
    uint256[] memory _balanceOutHolder = new uint256[](_tradesExecutionDetails.length);
    if (!_swappers.contains(_swapper)) revert InvalidSwapper();
    for (uint256 i; i < _tradesExecutionDetails.length; i++) {
      if (
        !_tokensOutByStrategyAndTokenIn[_tradesExecutionDetails[i]._strategy][_tradesExecutionDetails[i]._tokenIn].contains(
          _tradesExecutionDetails[i]._tokenOut
        )
      ) revert InvalidTrade();
      uint256 _amount = _tradesExecutionDetails[i]._amount != 0
        ? _tradesExecutionDetails[i]._amount
        : IERC20(_tradesExecutionDetails[i]._tokenIn).balanceOf(_tradesExecutionDetails[i]._strategy);
      IERC20(_tradesExecutionDetails[i]._tokenIn).safeTransferFrom(_tradesExecutionDetails[i]._strategy, _swapper, _amount);
      _balanceOutHolder[i] = IERC20(_tradesExecutionDetails[i]._tokenOut).balanceOf(_tradesExecutionDetails[i]._strategy);
    }
    IMultipleAsyncSwapper(_swapper).swapMultiple(_data);
    for (uint256 i; i < _tradesExecutionDetails.length; i++) {
      _balanceOutHolder[i] = IERC20(_tradesExecutionDetails[i]._tokenOut).balanceOf(_tradesExecutionDetails[i]._strategy) - _balanceOutHolder[i];
      if (_balanceOutHolder[i] < _tradesExecutionDetails[i]._minAmountOut) revert InvalidAmountOut();
    }
    emit MultipleAsyncTradeExecuted(_balanceOutHolder, _swapper);
  }
}// MIT
pragma solidity >=0.8.4 <0.9.0;



interface ITradeFactory is ITradeFactoryExecutor, ITradeFactoryPositionsHandler {}


contract TradeFactory is TradeFactoryExecutor, CollectableDust, ITradeFactory {

  constructor(
    address _masterAdmin,
    address _swapperAdder,
    address _swapperSetter,
    address _strategyModifier,
    address _mechanicsRegistry
  )
    TradeFactoryAccessManager(_masterAdmin)
    TradeFactoryPositionsHandler(_strategyModifier)
    TradeFactorySwapperHandler(_swapperAdder, _swapperSetter)
    TradeFactoryExecutor(_mechanicsRegistry)
  {}

  function sendDust(
    address _to,
    address _token,
    uint256 _amount
  ) external virtual override onlyRole(MASTER_ADMIN) {

    _sendDust(_to, _token, _amount);
  }
}