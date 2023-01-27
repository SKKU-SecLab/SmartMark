
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


interface IDCAFactoryPairsHandler {

  error IdenticalTokens();
  error PairAlreadyExists();

  event PairCreated(address indexed _tokenA, address indexed _tokenB, address _pair);

  function globalParameters() external view returns (IDCAGlobalParameters);


  function pairByTokens(address _tokenA, address _tokenB) external view returns (address _pair);


  function allPairs() external view returns (address[] memory _pairs);


  function isPair(address _address) external view returns (bool _isPair);


  function createPair(address _tokenA, address _tokenB) external returns (address pair);

}

interface IDCAFactory is IDCAFactoryPairsHandler {}// MIT


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
}// GPL-2.0-or-later
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


interface IKeep3rV1 is IERC20 {

  function name() external returns (string memory);


  function ETH() external view returns (address);


  function isKeeper(address _keeper) external returns (bool);


  function governance() external view returns (address);


  function isMinKeeper(
    address _keeper,
    uint256 _minBond,
    uint256 _earned,
    uint256 _age
  ) external returns (bool);


  function isBondedKeeper(
    address _keeper,
    address _bond,
    uint256 _minBond,
    uint256 _earned,
    uint256 _age
  ) external returns (bool);


  function addCreditETH(address job) external payable;


  function addCredit(
    address credit,
    address job,
    uint256 amount
  ) external;


  function addKPRCredit(address _job, uint256 _amount) external;


  function addJob(address _job) external;


  function removeJob(address _job) external;


  function addVotes(address voter, uint256 amount) external;


  function removeVotes(address voter, uint256 amount) external;


  function revoke(address keeper) external;


  function worked(address _keeper) external;


  function workReceipt(address _keeper, uint256 _amount) external;


  function receipt(
    address credit,
    address _keeper,
    uint256 _amount
  ) external;


  function receiptETH(address _keeper, uint256 _amount) external;


  function addLiquidityToJob(
    address liquidity,
    address job,
    uint256 amount
  ) external;


  function applyCreditToJob(
    address provider,
    address liquidity,
    address job
  ) external;


  function unbondLiquidityFromJob(
    address liquidity,
    address job,
    uint256 amount
  ) external;


  function removeLiquidityFromJob(address liquidity, address job) external;


  function bonds(address _keeper, address _credit) external view returns (uint256 _amount);


  function jobs(address _job) external view returns (bool);


  function jobList(uint256 _index) external view returns (address _job);


  function credits(address _job, address _credit) external view returns (uint256 _amount);


  function liquidityAccepted(address _liquidity) external view returns (bool);


  function liquidityProvided(
    address _provider,
    address _liquidity,
    address _job
  ) external view returns (uint256 _amount);


  function liquidityApplied(
    address _provider,
    address _liquidity,
    address _job
  ) external view returns (uint256 _amount);


  function liquidityAmount(
    address _provider,
    address _liquidity,
    address _job
  ) external view returns (uint256 _amount);


  function liquidityUnbonding(
    address _provider,
    address _liquidity,
    address _job
  ) external view returns (uint256 _amount);


  function liquidityAmountsUnbonding(
    address _provider,
    address _liquidity,
    address _job
  ) external view returns (uint256 _amount);


  function bond(address bonding, uint256 amount) external;


  function activate(address bonding) external;


  function unbond(address bonding, uint256 amount) external;


  function withdraw(address bonding) external;


  function setGovernance(address _governance) external;


  function acceptGovernance() external;

}// GPL-2.0-or-later
pragma solidity ^0.8.6;


interface IDCAKeep3rJob {

  event SubsidizingNewPairs(address[] _pairs);

  event StoppedSubsidizingPairs(address[] _pairs);

  event SwapperSet(IDCASwapper _swapper);

  event Keep3rV1Set(IKeep3rV1 _keep3rV1);

  event Worked(uint256 _amountSwapped);

  event DelaySet(uint32 _swapInterval, uint32 _delay);

  error InvalidPairAddress();

  error PairNotSubsidized();

  error NotAKeeper();

  error NotWorked();

  error MustWaitDelay();

  function subsidizedPairs() external view returns (address[] memory _pairs);


  function keep3rV1() external view returns (IKeep3rV1 _keeper);


  function factory() external view returns (IDCAFactory _factory);


  function swapper() external view returns (IDCASwapper _swapper);


  function delay(uint32 _swapInterval) external view returns (uint32 _delay);


  function workable() external returns (IDCASwapper.PairToSwap[] memory _pairs, uint32[] memory _smallestIntervals);


  function setKeep3rV1(IKeep3rV1 _keep3rV1) external;


  function setSwapper(IDCASwapper _swapper) external;


  function startSubsidizingPairs(address[] calldata _pairs) external;


  function stopSubsidizingPairs(address[] calldata _pairs) external;


  function setDelay(uint32 _swapInterval, uint32 _delay) external;


  function work(IDCASwapper.PairToSwap[] calldata _pairs, uint32[] calldata _smallestIntervals) external returns (uint256 _amountSwapped);

}// GPL-2.0-or-later
pragma solidity ^0.8.6;

library CommonErrors {

  error ZeroAddress();
  error Paused();
  error InsufficientLiquidity();
  error LiquidityNotReturned();
}// BUSL-1.1
pragma solidity ^0.8.6;




contract DCAKeep3rJob is IDCAKeep3rJob, Governable {

  using EnumerableSet for EnumerableSet.AddressSet;

  IDCAFactory public immutable override factory;
  IDCASwapper public override swapper;
  IKeep3rV1 public override keep3rV1;
  mapping(uint32 => uint32) internal _delay; // swap interval => delay
  EnumerableSet.AddressSet internal _subsidizedPairs;

  constructor(
    address _governor,
    IDCAFactory _factory,
    IKeep3rV1 _keep3rV1,
    IDCASwapper _swapper
  ) Governable(_governor) {
    if (address(_factory) == address(0) || address(_keep3rV1) == address(0) || address(_swapper) == address(0))
      revert CommonErrors.ZeroAddress();
    factory = _factory;
    keep3rV1 = _keep3rV1;
    swapper = _swapper;
  }

  function setKeep3rV1(IKeep3rV1 _keep3rV1) external override onlyGovernor {

    if (address(_keep3rV1) == address(0)) revert CommonErrors.ZeroAddress();
    keep3rV1 = _keep3rV1;
    emit Keep3rV1Set(_keep3rV1);
  }

  function setSwapper(IDCASwapper _swapper) external override onlyGovernor {

    if (address(_swapper) == address(0)) revert CommonErrors.ZeroAddress();
    swapper = _swapper;
    emit SwapperSet(_swapper);
  }

  function startSubsidizingPairs(address[] calldata _pairs) external override onlyGovernor {

    for (uint256 i; i < _pairs.length; i++) {
      if (!factory.isPair(_pairs[i])) revert InvalidPairAddress();
      _subsidizedPairs.add(_pairs[i]);
    }
    emit SubsidizingNewPairs(_pairs);
  }

  function stopSubsidizingPairs(address[] calldata _pairs) external override onlyGovernor {

    for (uint256 i; i < _pairs.length; i++) {
      _subsidizedPairs.remove(_pairs[i]);
    }
    emit StoppedSubsidizingPairs(_pairs);
  }

  function subsidizedPairs() external view override returns (address[] memory _pairs) {

    uint256 _length = _subsidizedPairs.length();
    _pairs = new address[](_length);
    for (uint256 i; i < _length; i++) {
      _pairs[i] = _subsidizedPairs.at(i);
    }
  }

  function setDelay(uint32 _swapInterval, uint32 __delay) external override onlyGovernor {

    _delay[_swapInterval] = __delay;
    emit DelaySet(_swapInterval, __delay);
  }

  function delay(uint32 _swapInterval) external view override returns (uint32 __delay) {

    __delay = _delay[_swapInterval];
    if (__delay == 0) {
      __delay = _swapInterval / 2;
    }
  }

  function workable() external override returns (IDCASwapper.PairToSwap[] memory _pairs, uint32[] memory _smallestIntervals) {

    uint256 _count;
    uint256 _length = _subsidizedPairs.length();
    for (uint256 i; i < _length; i++) {
      IDCAPair _pair = IDCAPair(_subsidizedPairs.at(i));
      bytes memory _swapPath = swapper.findBestSwap(_pair);
      uint32 _swapInterval = _getSmallestSwapInterval(_pair);
      if (_swapPath.length > 0 && _hasDelayPassedAlready(_pair, _swapInterval)) {
        _count++;
      }
    }
    _pairs = new IDCASwapper.PairToSwap[](_count);
    _smallestIntervals = new uint32[](_count);

    for (uint256 i; i < _length; i++) {
      IDCAPair _pair = IDCAPair(_subsidizedPairs.at(i));
      bytes memory _swapPath = swapper.findBestSwap(_pair);
      uint32 _swapInterval = _getSmallestSwapInterval(_pair);
      if (_swapPath.length > 0 && _hasDelayPassedAlready(_pair, _swapInterval)) {
        _pairs[--_count] = IDCASwapper.PairToSwap({pair: _pair, swapPath: _swapPath});
        _smallestIntervals[_count] = _swapInterval;
      }
    }
  }

  function work(IDCASwapper.PairToSwap[] calldata _pairsToSwap, uint32[] calldata _smallestIntervals)
    external
    override
    returns (uint256 _amountSwapped)
  {

    if (!keep3rV1.isKeeper(msg.sender)) revert NotAKeeper();
    for (uint256 i; i < _pairsToSwap.length; i++) {
      IDCAPair _pair = _pairsToSwap[i].pair;
      if (!_subsidizedPairs.contains(address(_pair))) {
        revert PairNotSubsidized();
      }
      if (!_hasDelayPassedAlready(_pair, _smallestIntervals[i])) {
        revert MustWaitDelay();
      }
    }
    _amountSwapped = swapper.swapPairs(_pairsToSwap);
    if (_amountSwapped == 0) revert NotWorked();
    keep3rV1.worked(msg.sender);
    emit Worked(_amountSwapped);
  }

  function _hasDelayPassedAlready(IDCAPair _pair, uint32 _swapInterval) internal view returns (bool) {

    uint32 _nextAvailable = _pair.nextSwapAvailable(_swapInterval);
    return _getTimestamp() >= _nextAvailable + this.delay(_swapInterval);
  }

  function _getSmallestSwapInterval(IDCAPair _pair) internal view returns (uint32 _minSwapInterval) {

    IDCAPair.NextSwapInformation memory _nextSwapInfo = _pair.getNextSwapInfo();
    for (uint256 i; i < _nextSwapInfo.amountOfSwaps; i++) {
      if (_minSwapInterval == 0 || _nextSwapInfo.swapsToPerform[i].interval < _minSwapInterval) {
        _minSwapInterval = _nextSwapInfo.swapsToPerform[i].interval;
      }
    }
  }

  function _getTimestamp() internal view virtual returns (uint32) {

    return uint32(block.timestamp);
  }
}