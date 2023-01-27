
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

interface IUniswapV3SwapCallback {

    function uniswapV3SwapCallback(
        int256 amount0Delta,
        int256 amount1Delta,
        bytes calldata data
    ) external;

}// GPL-2.0-or-later
pragma solidity >=0.7.5;
pragma abicoder v2;


interface ISwapRouter is IUniswapV3SwapCallback {

    struct ExactInputSingleParams {
        address tokenIn;
        address tokenOut;
        uint24 fee;
        address recipient;
        uint256 deadline;
        uint256 amountIn;
        uint256 amountOutMinimum;
        uint160 sqrtPriceLimitX96;
    }

    function exactInputSingle(ExactInputSingleParams calldata params) external payable returns (uint256 amountOut);


    struct ExactInputParams {
        bytes path;
        address recipient;
        uint256 deadline;
        uint256 amountIn;
        uint256 amountOutMinimum;
    }

    function exactInput(ExactInputParams calldata params) external payable returns (uint256 amountOut);


    struct ExactOutputSingleParams {
        address tokenIn;
        address tokenOut;
        uint24 fee;
        address recipient;
        uint256 deadline;
        uint256 amountOut;
        uint256 amountInMaximum;
        uint160 sqrtPriceLimitX96;
    }

    function exactOutputSingle(ExactOutputSingleParams calldata params) external payable returns (uint256 amountIn);


    struct ExactOutputParams {
        bytes path;
        address recipient;
        uint256 deadline;
        uint256 amountOut;
        uint256 amountInMaximum;
    }

    function exactOutput(ExactOutputParams calldata params) external payable returns (uint256 amountIn);

}// GPL-2.0-or-later
pragma solidity >=0.7.5;

interface IQuoter {

    function quoteExactInput(bytes memory path, uint256 amountIn) external returns (uint256 amountOut);


    function quoteExactInputSingle(
        address tokenIn,
        address tokenOut,
        uint24 fee,
        uint256 amountIn,
        uint160 sqrtPriceLimitX96
    ) external returns (uint256 amountOut);


    function quoteExactOutput(bytes memory path, uint256 amountOut) external returns (uint256 amountIn);


    function quoteExactOutputSingle(
        address tokenIn,
        address tokenOut,
        uint24 fee,
        uint256 amountOut,
        uint160 sqrtPriceLimitX96
    ) external returns (uint256 amountIn);

}// GPL-2.0-or-later
pragma solidity >=0.5.0;

interface IPeripheryImmutableState {

    function factory() external view returns (address);


    function WETH9() external view returns (address);

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
}// GPL-2.0-or-later
pragma solidity >=0.6.0;


library TransferHelper {

    function safeTransferFrom(
        address token,
        address from,
        address to,
        uint256 value
    ) internal {

        (bool success, bytes memory data) =
            token.call(abi.encodeWithSelector(IERC20.transferFrom.selector, from, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'STF');
    }

    function safeTransfer(
        address token,
        address to,
        uint256 value
    ) internal {

        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(IERC20.transfer.selector, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'ST');
    }

    function safeApprove(
        address token,
        address to,
        uint256 value
    ) internal {

        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(IERC20.approve.selector, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'SA');
    }

    function safeTransferETH(address to, uint256 value) internal {

        (bool success, ) = to.call{value: value}(new bytes(0));
        require(success, 'STE');
    }
}// BUSL-1.1

pragma solidity >=0.7.0;

interface IGovernable {

  event PendingGovernorSet(address _pendingGovernor);
  event PendingGovernorAccepted();

  function setPendingGovernor(address _pendingGovernor) external;


  function acceptPendingGovernor() external;


  function governor() external view returns (address);


  function pendingGovernor() external view returns (address);


  function isGovernor(address _account) external view returns (bool _isGovernor);


  function isPendingGovernor(address _account) external view returns (bool _isPendingGovernor);

}

abstract contract Governable is IGovernable {
  address private _governor;
  address private _pendingGovernor;

  constructor(address __governor) {
    require(__governor != address(0), 'Governable: zero address');
    _governor = __governor;
  }

  function governor() external view override returns (address) {
    return _governor;
  }

  function pendingGovernor() external view override returns (address) {
    return _pendingGovernor;
  }

  function setPendingGovernor(address __pendingGovernor) external virtual override onlyGovernor {
    _setPendingGovernor(__pendingGovernor);
  }

  function _setPendingGovernor(address __pendingGovernor) internal {
    require(__pendingGovernor != address(0), 'Governable: zero address');
    _pendingGovernor = __pendingGovernor;
    emit PendingGovernorSet(__pendingGovernor);
  }

  function acceptPendingGovernor() external virtual override onlyPendingGovernor {
    _acceptPendingGovernor();
  }

  function _acceptPendingGovernor() internal {
    require(_pendingGovernor != address(0), 'Governable: no pending governor');
    _governor = _pendingGovernor;
    _pendingGovernor = address(0);
    emit PendingGovernorAccepted();
  }

  function isGovernor(address _account) public view override returns (bool _isGovernor) {
    return _account == _governor;
  }

  function isPendingGovernor(address _account) public view override returns (bool _isPendingGovernor) {
    return _account == _pendingGovernor;
  }

  modifier onlyGovernor() {
    require(isGovernor(msg.sender), 'Governable: only governor');
    _;
  }

  modifier onlyPendingGovernor() {
    require(isPendingGovernor(msg.sender), 'Governable: only pending governor');
    _;
  }
}// MIT

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
        return _verifyCallResult(success, returndata, errorMessage);
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
        return _verifyCallResult(success, returndata, errorMessage);
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
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function _verifyCallResult(
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) private pure returns (bytes memory) {

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
}// BUSL-1.1

pragma solidity ^0.8.6;


interface ICollectableDust {

  event DustSent(address _to, address token, uint256 amount);

  function ETH() external view returns (address);


  function sendDust(
    address _to,
    address _token,
    uint256 _amount
  ) external;

}

abstract contract CollectableDust is ICollectableDust {
  using SafeERC20 for IERC20;
  using EnumerableSet for EnumerableSet.AddressSet;

  address public constant override ETH = 0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE;
  EnumerableSet.AddressSet internal _protocolTokens;

  function _addProtocolToken(address _token) internal {
    require(!_protocolTokens.contains(_token), 'CollectableDust: token already part of protocol');
    _protocolTokens.add(_token);
  }

  function _removeProtocolToken(address _token) internal {
    require(_protocolTokens.contains(_token), 'CollectableDust: token is not part of protocol');
    _protocolTokens.remove(_token);
  }

  function _sendDust(
    address _to,
    address _token,
    uint256 _amount
  ) internal {
    require(_to != address(0), 'CollectableDust: zero address');
    require(!_protocolTokens.contains(_token), 'CollectableDust: token is part of protocol');
    if (_token == ETH) {
      payable(_to).transfer(_amount);
    } else {
      IERC20(_token).safeTransfer(_to, _amount);
    }
    emit DustSent(_to, _token, _amount);
  }
}// MIT

pragma solidity ^0.8.0;


interface IERC20Metadata is IERC20 {

    function name() external view returns (string memory);


    function symbol() external view returns (string memory);


    function decimals() external view returns (uint8);

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

}// GPL-2.0-or-later
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


interface IDCASwapper is ICollectableDust {

  struct PairToSwap {
    IDCAPair pair;
    bytes swapPath;
  }

  event Swapped(PairToSwap[] _pairsToSwap, uint256 _amountSwapped);

  error ZeroPairsToSwap();

  function paused() external view returns (bool _isPaused);


  function findBestSwap(IDCAPair _pair) external returns (bytes memory _swapPath);


  function swapPairs(PairToSwap[] calldata _pairsToSwap) external returns (uint256 _amountSwapped);


  function pause() external;


  function unpause() external;

}// GPL-2.0-or-later
pragma solidity ^0.8.6;


interface IDCAPairSwapCallee {

  function DCAPairSwapCall(
    address _sender,
    IERC20Metadata _tokenA,
    IERC20Metadata _tokenB,
    uint256 _amountBorrowedTokenA,
    uint256 _amountBorrowedTokenB,
    bool _isRewardTokenA,
    uint256 _rewardAmount,
    uint256 _amountToProvide,
    bytes calldata _data
  ) external;

}// GPL-2.0-or-later
pragma solidity ^0.8.6;

library CommonErrors {

  error ZeroAddress();
  error Paused();
  error InsufficientLiquidity();
  error LiquidityNotReturned();
}// BUSL-1.1
pragma solidity ^0.8.6;


interface ICustomQuoter is IQuoter, IPeripheryImmutableState {}


contract DCAUniswapV3Swapper is IDCASwapper, Governable, IDCAPairSwapCallee, CollectableDust, Pausable {

  uint24[] private _FEE_TIERS = [500, 3000, 10000];
  ISwapRouter public immutable swapRouter;
  ICustomQuoter public immutable quoter;

  constructor(
    address _governor,
    ISwapRouter _swapRouter,
    ICustomQuoter _quoter
  ) Governable(_governor) {
    if (address(_swapRouter) == address(0) || address(_quoter) == address(0)) revert CommonErrors.ZeroAddress();
    swapRouter = _swapRouter;
    quoter = _quoter;
  }

  function swapPairs(PairToSwap[] calldata _pairsToSwap) external override whenNotPaused returns (uint256 _amountSwapped) {

    if (_pairsToSwap.length == 0) revert ZeroPairsToSwap();

    uint256 _maxGasSpent;

    do {
      uint256 _gasLeftStart = gasleft();
      _swap(_pairsToSwap[_amountSwapped++]);
      uint256 _gasSpent = _gasLeftStart - gasleft();

      if (_gasSpent > _maxGasSpent) {
        _maxGasSpent = _gasSpent;
      }

    } while (_amountSwapped < _pairsToSwap.length && gasleft() >= (_maxGasSpent * 3) / 2);

    emit Swapped(_pairsToSwap, _amountSwapped);
  }

  function paused() public view override(IDCASwapper, Pausable) returns (bool) {

    return super.paused();
  }

  function pause() external override onlyGovernor {

    _pause();
  }

  function unpause() external override onlyGovernor {

    _unpause();
  }

  function findBestSwap(IDCAPair _pair) external override returns (bytes memory _swapPath) {

    IDCAPairSwapHandler.NextSwapInformation memory _nextSwapInformation = _pair.getNextSwapInfo();
    if (_nextSwapInformation.amountOfSwaps > 0) {
      if (_nextSwapInformation.amountToBeProvidedBySwapper == 0) {
        return abi.encode(type(uint24).max);
      } else {
        uint256 _minNecessary;
        uint24 _feeTier;
        for (uint256 i; i < _FEE_TIERS.length; i++) {
          address _factory = quoter.factory();
          address _pool = IUniswapV3Factory(_factory).getPool(
            address(_nextSwapInformation.tokenToRewardSwapperWith),
            address(_nextSwapInformation.tokenToBeProvidedBySwapper),
            _FEE_TIERS[i]
          );
          if (_pool != address(0)) {
            try
              quoter.quoteExactOutputSingle(
                address(_nextSwapInformation.tokenToRewardSwapperWith),
                address(_nextSwapInformation.tokenToBeProvidedBySwapper),
                _FEE_TIERS[i],
                _nextSwapInformation.amountToBeProvidedBySwapper,
                0
              )
            returns (uint256 _inputNecessary) {
              if (_nextSwapInformation.amountToRewardSwapperWith >= _inputNecessary && (_minNecessary == 0 || _inputNecessary < _minNecessary)) {
                _minNecessary = _inputNecessary;
                _feeTier = _FEE_TIERS[i];
              }
            } catch {}
          }
        }
        if (_feeTier > 0) {
          _swapPath = abi.encode(_feeTier);
        }
      }
    }
  }

  function _swap(PairToSwap memory _pair) internal {
    _pair.pair.swap(0, 0, address(this), _pair.swapPath);
  }

  function sendDust(
    address _to,
    address _token,
    uint256 _amount
  ) external override onlyGovernor {
    _sendDust(_to, _token, _amount);
  }

  function DCAPairSwapCall(
    address,
    IERC20Metadata _tokenA,
    IERC20Metadata _tokenB,
    uint256,
    uint256,
    bool _isRewardTokenA,
    uint256 _rewardAmount,
    uint256 _amountToProvide,
    bytes calldata _bytes
  ) external override {
    if (_amountToProvide > 0) {
      address _tokenIn = _isRewardTokenA ? address(_tokenA) : address(_tokenB);
      address _tokenOut = _isRewardTokenA ? address(_tokenB) : address(_tokenA);

      TransferHelper.safeApprove(_tokenIn, address(swapRouter), _rewardAmount);

      ISwapRouter.ExactOutputSingleParams memory params = ISwapRouter.ExactOutputSingleParams({
        tokenIn: _tokenIn,
        tokenOut: _tokenOut,
        fee: abi.decode(_bytes, (uint24)),
        recipient: msg.sender, // Send it directly to pair
        deadline: block.timestamp, // Needs to happen now
        amountOut: _amountToProvide,
        amountInMaximum: _rewardAmount,
        sqrtPriceLimitX96: 0
      });

      uint256 _amountIn = swapRouter.exactOutputSingle(params);

      if (_amountIn < _rewardAmount) {
        TransferHelper.safeApprove(_tokenIn, address(swapRouter), 0);
        TransferHelper.safeTransfer(_tokenIn, msg.sender, _rewardAmount - _amountIn);
      }
    }
  }
}