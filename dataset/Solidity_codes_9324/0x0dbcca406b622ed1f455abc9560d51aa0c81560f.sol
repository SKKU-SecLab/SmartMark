
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


interface IAccessControl {

    function hasRole(bytes32 role, address account) external view returns (bool);


    function getRoleAdmin(bytes32 role) external view returns (bytes32);


    function grantRole(bytes32 role, address account) external;


    function revokeRole(bytes32 role, address account) external;


    function renounceRole(bytes32 role, address account) external;

}

abstract contract AccessControl is Context, IAccessControl, ERC165 {
    struct RoleData {
        mapping(address => bool) members;
        bytes32 adminRole;
    }

    mapping(bytes32 => RoleData) private _roles;

    bytes32 public constant DEFAULT_ADMIN_ROLE = 0x00;

    event RoleAdminChanged(bytes32 indexed role, bytes32 indexed previousAdminRole, bytes32 indexed newAdminRole);

    event RoleGranted(bytes32 indexed role, address indexed account, address indexed sender);

    event RoleRevoked(bytes32 indexed role, address indexed account, address indexed sender);

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
        emit RoleAdminChanged(role, getRoleAdmin(role), adminRole);
        _roles[role].adminRole = adminRole;
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
}// GPL-2.0-or-later
pragma solidity >=0.5.0;

interface IUniswapV3Factory {

    event OwnerChanged(address indexed oldOwner, address indexed newOwner);

    event PoolCreated(
        address indexed token0,
        address indexed token1,
        uint24 indexed fee,
        int24 tickSpacing,
        address pool
    );

    event FeeAmountEnabled(uint24 indexed fee, int24 indexed tickSpacing);

    function owner() external view returns (address);


    function feeAmountTickSpacing(uint24 fee) external view returns (int24);


    function getPool(
        address tokenA,
        address tokenB,
        uint24 fee
    ) external view returns (address pool);


    function createPool(
        address tokenA,
        address tokenB,
        uint24 fee
    ) external returns (address pool);


    function setOwner(address _owner) external;


    function enableFeeAmount(uint24 fee, int24 tickSpacing) external;

}// GPL-2.0-or-later
pragma solidity >=0.5.0;


interface ITimeWeightedOracle {

  event AddedSupportForPair(address _tokenA, address _tokenB);

  function canSupportPair(address _tokenA, address _tokenB) external view returns (bool _canSupport);


  function quote(
    address _tokenIn,
    uint128 _amountIn,
    address _tokenOut
  ) external view returns (uint256 _amountOut);


  function addSupportForPair(address _tokenA, address _tokenB) external;

}

interface IUniswapV3OracleAggregator is ITimeWeightedOracle {

  event AddedFeeTier(uint24 _feeTier);

  event PeriodChanged(uint32 _period);

  function factory() external view returns (IUniswapV3Factory _factory);


  function supportedFeeTiers() external view returns (uint24[] memory _feeTiers);


  function poolsUsedForPair(address _tokenA, address _tokenB) external view returns (address[] memory _pools);


  function period() external view returns (uint16 _period);


  function MINIMUM_PERIOD() external view returns (uint16);


  function MAXIMUM_PERIOD() external view returns (uint16);


  function MINIMUM_LIQUIDITY_THRESHOLD() external view returns (uint16);


  function addFeeTier(uint24 _feeTier) external;


  function setPeriod(uint16 _period) external;

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


interface IERC20Metadata is IERC20 {

    function name() external view returns (string memory);


    function symbol() external view returns (string memory);


    function decimals() external view returns (uint8);

}// GPL-2.0-or-later
pragma solidity ^0.8.6;


interface IDCAPairParameters {

  function globalParameters() external view returns (IDCAGlobalParameters);


  function tokenA() external view returns (IERC20Metadata);


  function tokenB() external view returns (IERC20Metadata);


  function swapAmountDelta(
    uint32 _swapInterval,
    address _from,
    uint32 _swap
  ) external view returns (int256 _delta);


  function isSwapIntervalActive(uint32 _swapInterval) external view returns (bool _isActive);


  function performedSwaps(uint32 _swapInterval) external view returns (uint32 _swaps);

}

interface IDCAPairPositionHandler is IDCAPairParameters {

  struct UserPosition {
    IERC20Metadata from;
    IERC20Metadata to;
    uint32 swapInterval;
    uint32 swapsExecuted;
    uint256 swapped;
    uint32 swapsLeft;
    uint256 remaining;
    uint160 rate;
  }

  event Terminated(address indexed _user, uint256 _dcaId, uint256 _returnedUnswapped, uint256 _returnedSwapped);

  event Deposited(
    address indexed _user,
    uint256 _dcaId,
    address _fromToken,
    uint160 _rate,
    uint32 _startingSwap,
    uint32 _swapInterval,
    uint32 _lastSwap
  );

  event Withdrew(address indexed _user, uint256 _dcaId, address _token, uint256 _amount);

  event WithdrewMany(address indexed _user, uint256[] _dcaIds, uint256 _swappedTokenA, uint256 _swappedTokenB);

  event Modified(address indexed _user, uint256 _dcaId, uint160 _rate, uint32 _startingSwap, uint32 _lastSwap);

  error InvalidToken();

  error InvalidInterval();

  error InvalidPosition();

  error UnauthorizedCaller();

  error ZeroRate();

  error ZeroSwaps();

  error ZeroAmount();

  error PositionCompleted();

  error MandatoryWithdraw();

  function userPosition(uint256 _dcaId) external view returns (UserPosition memory _position);


  function deposit(
    address _tokenAddress,
    uint160 _rate,
    uint32 _amountOfSwaps,
    uint32 _swapInterval
  ) external returns (uint256 _dcaId);


  function withdrawSwapped(uint256 _dcaId) external returns (uint256 _swapped);


  function withdrawSwappedMany(uint256[] calldata _dcaIds) external returns (uint256 _swappedTokenA, uint256 _swappedTokenB);


  function modifyRate(uint256 _dcaId, uint160 _newRate) external;


  function modifySwaps(uint256 _dcaId, uint32 _newSwaps) external;


  function modifyRateAndSwaps(
    uint256 _dcaId,
    uint160 _newRate,
    uint32 _newSwaps
  ) external;


  function addFundsToPosition(
    uint256 _dcaId,
    uint256 _amount,
    uint32 _newSwaps
  ) external;


  function terminate(uint256 _dcaId) external;

}

interface IDCAPairSwapHandler {

  struct SwapInformation {
    uint32 interval;
    uint32 swapToPerform;
    uint256 amountToSwapTokenA;
    uint256 amountToSwapTokenB;
  }

  struct NextSwapInformation {
    SwapInformation[] swapsToPerform;
    uint8 amountOfSwaps;
    uint256 availableToBorrowTokenA;
    uint256 availableToBorrowTokenB;
    uint256 ratePerUnitBToA;
    uint256 ratePerUnitAToB;
    uint256 platformFeeTokenA;
    uint256 platformFeeTokenB;
    uint256 amountToBeProvidedBySwapper;
    uint256 amountToRewardSwapperWith;
    IERC20Metadata tokenToBeProvidedBySwapper;
    IERC20Metadata tokenToRewardSwapperWith;
  }

  event Swapped(
    address indexed _sender,
    address indexed _to,
    uint256 _amountBorrowedTokenA,
    uint256 _amountBorrowedTokenB,
    uint32 _fee,
    NextSwapInformation _nextSwapInformation
  );

  error NoSwapsToExecute();

  function nextSwapAvailable(uint32 _swapInterval) external view returns (uint32 _when);


  function swapAmountAccumulator(uint32 _swapInterval, address _from) external view returns (uint256);


  function getNextSwapInfo() external view returns (NextSwapInformation memory _nextSwapInformation);


  function swap() external;


  function swap(
    uint256 _amountToBorrowTokenA,
    uint256 _amountToBorrowTokenB,
    address _to,
    bytes calldata _data
  ) external;


  function secondsUntilNextSwap() external view returns (uint32 _secondsUntilNextSwap);

}

interface IDCAPairLoanHandler {

  event Loaned(address indexed _sender, address indexed _to, uint256 _amountBorrowedTokenA, uint256 _amountBorrowedTokenB, uint32 _loanFee);

  error ZeroLoan();

  function availableToBorrow() external view returns (uint256 _amountToBorrowTokenA, uint256 _amountToBorrowTokenB);


  function loan(
    uint256 _amountToBorrowTokenA,
    uint256 _amountToBorrowTokenB,
    address _to,
    bytes calldata _data
  ) external;

}

interface IDCAPair is IDCAPairParameters, IDCAPairSwapHandler, IDCAPairPositionHandler, IDCAPairLoanHandler {}// GPL-2.0-or-later

pragma solidity ^0.8.6;


interface IDCATokenDescriptor {

  function tokenURI(IDCAPairPositionHandler _positionHandler, uint256 _tokenId) external view returns (string memory _description);

}// GPL-2.0-or-later
pragma solidity ^0.8.6;


interface IDCAGlobalParameters {

  struct SwapParameters {
    address feeRecipient;
    bool isPaused;
    uint32 swapFee;
    ITimeWeightedOracle oracle;
  }

  struct LoanParameters {
    address feeRecipient;
    bool isPaused;
    uint32 loanFee;
  }

  event FeeRecipientSet(address _feeRecipient);

  event NFTDescriptorSet(IDCATokenDescriptor _descriptor);

  event OracleSet(ITimeWeightedOracle _oracle);

  event SwapFeeSet(uint32 _feeSet);

  event LoanFeeSet(uint32 _feeSet);

  event SwapIntervalsAllowed(uint32[] _swapIntervals, string[] _descriptions);

  event SwapIntervalsForbidden(uint32[] _swapIntervals);

  error HighFee();

  error InvalidParams();

  error ZeroInterval();

  error EmptyDescription();

  function feeRecipient() external view returns (address _feeRecipient);


  function swapFee() external view returns (uint32 _swapFee);


  function loanFee() external view returns (uint32 _loanFee);


  function nftDescriptor() external view returns (IDCATokenDescriptor _nftDescriptor);


  function oracle() external view returns (ITimeWeightedOracle _oracle);


  function FEE_PRECISION() external view returns (uint24 _precision);


  function MAX_FEE() external view returns (uint32 _maxFee);


  function allowedSwapIntervals() external view returns (uint32[] memory _allowedSwapIntervals);


  function intervalDescription(uint32 _swapInterval) external view returns (string memory _description);


  function isSwapIntervalAllowed(uint32 _swapInterval) external view returns (bool _isAllowed);


  function paused() external view returns (bool _isPaused);


  function swapParameters() external view returns (SwapParameters memory _swapParameters);


  function loanParameters() external view returns (LoanParameters memory _loanParameters);


  function setFeeRecipient(address _feeRecipient) external;


  function setSwapFee(uint32 _fee) external;


  function setLoanFee(uint32 _fee) external;


  function setNFTDescriptor(IDCATokenDescriptor _descriptor) external;


  function setOracle(ITimeWeightedOracle _oracle) external;


  function addSwapIntervalsToAllowedList(uint32[] calldata _swapIntervals, string[] calldata _descriptions) external;


  function removeSwapIntervalsFromAllowedList(uint32[] calldata _swapIntervals) external;


  function pause() external;


  function unpause() external;

}// GPL-2.0-or-later
pragma solidity ^0.8.6;

library CommonErrors {

  error ZeroAddress();
  error Paused();
  error InsufficientLiquidity();
  error LiquidityNotReturned();
}// BUSL-1.1
pragma solidity ^0.8.6;



contract DCAGlobalParameters is IDCAGlobalParameters, AccessControl, Pausable {

  using EnumerableSet for EnumerableSet.UintSet;

  bytes32 public constant IMMEDIATE_ROLE = keccak256('IMMEDIATE_ROLE');
  bytes32 public constant TIME_LOCKED_ROLE = keccak256('TIME_LOCKED_ROLE');

  address public override feeRecipient;
  IDCATokenDescriptor public override nftDescriptor;
  ITimeWeightedOracle public override oracle;
  uint32 public override swapFee = 6000; // 0.6%
  uint32 public override loanFee = 1000; // 0.1%
  uint24 public constant override FEE_PRECISION = 10000;
  uint32 public constant override MAX_FEE = 10 * FEE_PRECISION; // 10%
  mapping(uint32 => string) public override intervalDescription;
  EnumerableSet.UintSet internal _allowedSwapIntervals;

  constructor(
    address _immediateGovernor,
    address _timeLockedGovernor,
    address _feeRecipient,
    IDCATokenDescriptor _nftDescriptor,
    ITimeWeightedOracle _oracle
  ) {
    if (
      _immediateGovernor == address(0) ||
      _timeLockedGovernor == address(0) ||
      _feeRecipient == address(0) ||
      address(_nftDescriptor) == address(0) ||
      address(_oracle) == address(0)
    ) revert CommonErrors.ZeroAddress();
    _setupRole(IMMEDIATE_ROLE, _immediateGovernor);
    _setupRole(TIME_LOCKED_ROLE, _timeLockedGovernor);
    _setRoleAdmin(IMMEDIATE_ROLE, IMMEDIATE_ROLE);
    _setRoleAdmin(TIME_LOCKED_ROLE, TIME_LOCKED_ROLE);
    feeRecipient = _feeRecipient;
    nftDescriptor = _nftDescriptor;
    oracle = _oracle;
  }

  function setFeeRecipient(address _feeRecipient) external override onlyRole(IMMEDIATE_ROLE) {

    if (_feeRecipient == address(0)) revert CommonErrors.ZeroAddress();
    feeRecipient = _feeRecipient;
    emit FeeRecipientSet(_feeRecipient);
  }

  function setNFTDescriptor(IDCATokenDescriptor _descriptor) external override onlyRole(IMMEDIATE_ROLE) {

    if (address(_descriptor) == address(0)) revert CommonErrors.ZeroAddress();
    nftDescriptor = _descriptor;
    emit NFTDescriptorSet(_descriptor);
  }

  function setOracle(ITimeWeightedOracle _oracle) external override onlyRole(TIME_LOCKED_ROLE) {

    if (address(_oracle) == address(0)) revert CommonErrors.ZeroAddress();
    oracle = _oracle;
    emit OracleSet(_oracle);
  }

  function setSwapFee(uint32 _swapFee) external override onlyRole(TIME_LOCKED_ROLE) {

    if (_swapFee > MAX_FEE) revert HighFee();
    swapFee = _swapFee;
    emit SwapFeeSet(_swapFee);
  }

  function setLoanFee(uint32 _loanFee) external override onlyRole(TIME_LOCKED_ROLE) {

    if (_loanFee > MAX_FEE) revert HighFee();
    loanFee = _loanFee;
    emit LoanFeeSet(_loanFee);
  }

  function addSwapIntervalsToAllowedList(uint32[] calldata _swapIntervals, string[] calldata _descriptions)
    external
    override
    onlyRole(IMMEDIATE_ROLE)
  {

    if (_swapIntervals.length != _descriptions.length) revert InvalidParams();
    for (uint256 i; i < _swapIntervals.length; i++) {
      if (_swapIntervals[i] == 0) revert ZeroInterval();
      if (bytes(_descriptions[i]).length == 0) revert EmptyDescription();
      _allowedSwapIntervals.add(_swapIntervals[i]);
      intervalDescription[_swapIntervals[i]] = _descriptions[i];
    }
    emit SwapIntervalsAllowed(_swapIntervals, _descriptions);
  }

  function removeSwapIntervalsFromAllowedList(uint32[] calldata _swapIntervals) external override onlyRole(IMMEDIATE_ROLE) {

    for (uint256 i; i < _swapIntervals.length; i++) {
      _allowedSwapIntervals.remove(_swapIntervals[i]);
      delete intervalDescription[_swapIntervals[i]];
    }
    emit SwapIntervalsForbidden(_swapIntervals);
  }

  function allowedSwapIntervals() external view override returns (uint32[] memory __allowedSwapIntervals) {

    uint256 _allowedSwapIntervalsLength = _allowedSwapIntervals.length();
    __allowedSwapIntervals = new uint32[](_allowedSwapIntervalsLength);
    for (uint256 i; i < _allowedSwapIntervalsLength; i++) {
      __allowedSwapIntervals[i] = uint32(_allowedSwapIntervals.at(i));
    }
  }

  function isSwapIntervalAllowed(uint32 _swapInterval) external view override returns (bool) {

    return _allowedSwapIntervals.contains(_swapInterval);
  }

  function paused() public view override(IDCAGlobalParameters, Pausable) returns (bool) {

    return super.paused();
  }

  function pause() external override onlyRole(IMMEDIATE_ROLE) {

    _pause();
  }

  function unpause() external override onlyRole(IMMEDIATE_ROLE) {

    _unpause();
  }

  function loanParameters() external view override returns (LoanParameters memory _loanParameters) {

    _loanParameters.feeRecipient = feeRecipient;
    _loanParameters.isPaused = paused();
    _loanParameters.loanFee = loanFee;
  }

  function swapParameters() external view override returns (SwapParameters memory _swapParameters) {

    _swapParameters.feeRecipient = feeRecipient;
    _swapParameters.isPaused = paused();
    _swapParameters.swapFee = swapFee;
    _swapParameters.oracle = oracle;
  }
}