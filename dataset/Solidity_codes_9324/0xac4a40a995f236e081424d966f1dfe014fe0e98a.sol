
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

library Math {

  function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {

    unchecked {
      if (a == 0) return (true, 0);
      uint256 c = a * b;
      if (c / a != b) return (false, 0);
      return (true, c);
    }
  }
}// BUSL-1.1
pragma solidity ^0.8.6;




abstract contract DCAPairParameters is IDCAPairParameters {
  using EnumerableSet for EnumerableSet.UintSet;

  uint112 internal _magnitudeA;
  uint112 internal _magnitudeB;
  uint24 internal _feePrecision;

  IDCAGlobalParameters public override globalParameters;
  IERC20Metadata public override tokenA;
  IERC20Metadata public override tokenB;

  mapping(uint32 => mapping(address => mapping(uint32 => int256))) public override swapAmountDelta; // swap interval => from token => swap number => delta
  mapping(uint32 => uint32) public override performedSwaps; // swap interval => performed swaps
  mapping(uint32 => mapping(address => mapping(uint32 => uint256))) internal _accumRatesPerUnit; // swap interval => from token => swap number => accum
  mapping(address => uint256) internal _balances;
  EnumerableSet.UintSet internal _activeSwapIntervals;

  constructor(
    IDCAGlobalParameters _globalParameters,
    IERC20Metadata _tokenA,
    IERC20Metadata _tokenB
  ) {
    if (address(_globalParameters) == address(0) || address(_tokenA) == address(0) || address(_tokenB) == address(0))
      revert CommonErrors.ZeroAddress();
    globalParameters = _globalParameters;
    _feePrecision = globalParameters.FEE_PRECISION();
    tokenA = _tokenA;
    tokenB = _tokenB;
    _magnitudeA = uint112(10**_tokenA.decimals());
    _magnitudeB = uint112(10**_tokenB.decimals());
  }

  function isSwapIntervalActive(uint32 _activeSwapInterval) external view override returns (bool _isIntervalActive) {
    _isIntervalActive = _activeSwapIntervals.contains(_activeSwapInterval);
  }

  function _getFeeFromAmount(uint32 _feeAmount, uint256 _amount) internal view returns (uint256) {
    return (_amount * _feeAmount) / _feePrecision / 100;
  }
}// MIT

pragma solidity ^0.8.0;

interface IERC165 {

    function supportsInterface(bytes4 interfaceId) external view returns (bool);

}// MIT

pragma solidity ^0.8.0;


interface IERC721 is IERC165 {

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

interface IERC721Receiver {

    function onERC721Received(
        address operator,
        address from,
        uint256 tokenId,
        bytes calldata data
    ) external returns (bytes4);

}// MIT

pragma solidity ^0.8.0;


interface IERC721Metadata is IERC721 {

    function name() external view returns (string memory);


    function symbol() external view returns (string memory);


    function tokenURI(uint256 tokenId) external view returns (string memory);

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


abstract contract ERC165 is IERC165 {
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IERC165).interfaceId;
    }
}// MIT

pragma solidity ^0.8.0;


contract ERC721 is Context, ERC165, IERC721, IERC721Metadata {

    using Address for address;
    using Strings for uint256;

    string private _name;

    string private _symbol;

    mapping(uint256 => address) private _owners;

    mapping(address => uint256) private _balances;

    mapping(uint256 => address) private _tokenApprovals;

    mapping(address => mapping(address => bool)) private _operatorApprovals;

    constructor(string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
    }

    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC165, IERC165) returns (bool) {

        return
            interfaceId == type(IERC721).interfaceId ||
            interfaceId == type(IERC721Metadata).interfaceId ||
            super.supportsInterface(interfaceId);
    }

    function balanceOf(address owner) public view virtual override returns (uint256) {

        require(owner != address(0), "ERC721: balance query for the zero address");
        return _balances[owner];
    }

    function ownerOf(uint256 tokenId) public view virtual override returns (address) {

        address owner = _owners[tokenId];
        require(owner != address(0), "ERC721: owner query for nonexistent token");
        return owner;
    }

    function name() public view virtual override returns (string memory) {

        return _name;
    }

    function symbol() public view virtual override returns (string memory) {

        return _symbol;
    }

    function tokenURI(uint256 tokenId) public view virtual override returns (string memory) {

        require(_exists(tokenId), "ERC721Metadata: URI query for nonexistent token");

        string memory baseURI = _baseURI();
        return bytes(baseURI).length > 0 ? string(abi.encodePacked(baseURI, tokenId.toString())) : "";
    }

    function _baseURI() internal view virtual returns (string memory) {

        return "";
    }

    function approve(address to, uint256 tokenId) public virtual override {

        address owner = ERC721.ownerOf(tokenId);
        require(to != owner, "ERC721: approval to current owner");

        require(
            _msgSender() == owner || isApprovedForAll(owner, _msgSender()),
            "ERC721: approve caller is not owner nor approved for all"
        );

        _approve(to, tokenId);
    }

    function getApproved(uint256 tokenId) public view virtual override returns (address) {

        require(_exists(tokenId), "ERC721: approved query for nonexistent token");

        return _tokenApprovals[tokenId];
    }

    function setApprovalForAll(address operator, bool approved) public virtual override {

        require(operator != _msgSender(), "ERC721: approve to caller");

        _operatorApprovals[_msgSender()][operator] = approved;
        emit ApprovalForAll(_msgSender(), operator, approved);
    }

    function isApprovedForAll(address owner, address operator) public view virtual override returns (bool) {

        return _operatorApprovals[owner][operator];
    }

    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) public virtual override {

        require(_isApprovedOrOwner(_msgSender(), tokenId), "ERC721: transfer caller is not owner nor approved");

        _transfer(from, to, tokenId);
    }

    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId
    ) public virtual override {

        safeTransferFrom(from, to, tokenId, "");
    }

    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes memory _data
    ) public virtual override {

        require(_isApprovedOrOwner(_msgSender(), tokenId), "ERC721: transfer caller is not owner nor approved");
        _safeTransfer(from, to, tokenId, _data);
    }

    function _safeTransfer(
        address from,
        address to,
        uint256 tokenId,
        bytes memory _data
    ) internal virtual {

        _transfer(from, to, tokenId);
        require(_checkOnERC721Received(from, to, tokenId, _data), "ERC721: transfer to non ERC721Receiver implementer");
    }

    function _exists(uint256 tokenId) internal view virtual returns (bool) {

        return _owners[tokenId] != address(0);
    }

    function _isApprovedOrOwner(address spender, uint256 tokenId) internal view virtual returns (bool) {

        require(_exists(tokenId), "ERC721: operator query for nonexistent token");
        address owner = ERC721.ownerOf(tokenId);
        return (spender == owner || getApproved(tokenId) == spender || isApprovedForAll(owner, spender));
    }

    function _safeMint(address to, uint256 tokenId) internal virtual {

        _safeMint(to, tokenId, "");
    }

    function _safeMint(
        address to,
        uint256 tokenId,
        bytes memory _data
    ) internal virtual {

        _mint(to, tokenId);
        require(
            _checkOnERC721Received(address(0), to, tokenId, _data),
            "ERC721: transfer to non ERC721Receiver implementer"
        );
    }

    function _mint(address to, uint256 tokenId) internal virtual {

        require(to != address(0), "ERC721: mint to the zero address");
        require(!_exists(tokenId), "ERC721: token already minted");

        _beforeTokenTransfer(address(0), to, tokenId);

        _balances[to] += 1;
        _owners[tokenId] = to;

        emit Transfer(address(0), to, tokenId);
    }

    function _burn(uint256 tokenId) internal virtual {

        address owner = ERC721.ownerOf(tokenId);

        _beforeTokenTransfer(owner, address(0), tokenId);

        _approve(address(0), tokenId);

        _balances[owner] -= 1;
        delete _owners[tokenId];

        emit Transfer(owner, address(0), tokenId);
    }

    function _transfer(
        address from,
        address to,
        uint256 tokenId
    ) internal virtual {

        require(ERC721.ownerOf(tokenId) == from, "ERC721: transfer of token that is not own");
        require(to != address(0), "ERC721: transfer to the zero address");

        _beforeTokenTransfer(from, to, tokenId);

        _approve(address(0), tokenId);

        _balances[from] -= 1;
        _balances[to] += 1;
        _owners[tokenId] = to;

        emit Transfer(from, to, tokenId);
    }

    function _approve(address to, uint256 tokenId) internal virtual {

        _tokenApprovals[tokenId] = to;
        emit Approval(ERC721.ownerOf(tokenId), to, tokenId);
    }

    function _checkOnERC721Received(
        address from,
        address to,
        uint256 tokenId,
        bytes memory _data
    ) private returns (bool) {

        if (to.isContract()) {
            try IERC721Receiver(to).onERC721Received(_msgSender(), from, tokenId, _data) returns (bytes4 retval) {
                return retval == IERC721Receiver(to).onERC721Received.selector;
            } catch (bytes memory reason) {
                if (reason.length == 0) {
                    revert("ERC721: transfer to non ERC721Receiver implementer");
                } else {
                    assembly {
                        revert(add(32, reason), mload(reason))
                    }
                }
            }
        } else {
            return true;
        }
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 tokenId
    ) internal virtual {}

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
}// BUSL-1.1
pragma solidity ^0.8.6;



abstract contract DCAPairPositionHandler is ReentrancyGuard, DCAPairParameters, IDCAPairPositionHandler, ERC721 {
  struct DCA {
    uint32 lastWithdrawSwap;
    uint32 lastSwap;
    uint32 swapInterval;
    uint160 rate;
    bool fromTokenA;
    uint248 swappedBeforeModified;
  }

  using SafeERC20 for IERC20Metadata;
  using EnumerableSet for EnumerableSet.UintSet;

  mapping(uint256 => DCA) internal _userPositions;
  uint256 internal _idCounter;

  constructor(IERC20Metadata _tokenA, IERC20Metadata _tokenB)
    ERC721(string(abi.encodePacked('DCA: ', _tokenA.symbol(), ' - ', _tokenB.symbol())), 'DCA')
  {}

  function userPosition(uint256 _dcaId) external view override returns (UserPosition memory _userPosition) {
    DCA memory _position = _userPositions[_dcaId];
    _userPosition.from = _position.fromTokenA ? tokenA : tokenB;
    _userPosition.to = _position.fromTokenA ? tokenB : tokenA;
    _userPosition.swapInterval = _position.swapInterval;
    _userPosition.swapsExecuted = _position.swapInterval > 0 ? performedSwaps[_position.swapInterval] - _position.lastWithdrawSwap : 0;
    _userPosition.swapped = _calculateSwapped(_dcaId);
    _userPosition.swapsLeft = _position.lastSwap > performedSwaps[_position.swapInterval]
      ? _position.lastSwap - performedSwaps[_position.swapInterval]
      : 0;
    _userPosition.remaining = _calculateUnswapped(_dcaId);
    _userPosition.rate = _position.rate;
  }

  function deposit(
    address _tokenAddress,
    uint160 _rate,
    uint32 _amountOfSwaps,
    uint32 _swapInterval
  ) external override nonReentrant returns (uint256) {
    if (_tokenAddress != address(tokenA) && _tokenAddress != address(tokenB)) revert InvalidToken();
    if (_amountOfSwaps == 0) revert ZeroSwaps();
    if (!_activeSwapIntervals.contains(_swapInterval) && !globalParameters.isSwapIntervalAllowed(_swapInterval)) revert InvalidInterval();
    IERC20Metadata _from = _tokenAddress == address(tokenA) ? tokenA : tokenB;
    uint256 _amount = _rate * _amountOfSwaps;
    _from.safeTransferFrom(msg.sender, address(this), _amount);
    _balances[_tokenAddress] += _amount;
    _idCounter += 1;
    _safeMint(msg.sender, _idCounter);
    _activeSwapIntervals.add(_swapInterval);
    (uint32 _startingSwap, uint32 _lastSwap) = _addPosition(_idCounter, _tokenAddress, _rate, _amountOfSwaps, 0, _swapInterval);
    emit Deposited(msg.sender, _idCounter, _tokenAddress, _rate, _startingSwap, _swapInterval, _lastSwap);
    return _idCounter;
  }

  function withdrawSwapped(uint256 _dcaId) external override nonReentrant returns (uint256 _swapped) {
    _assertPositionExistsAndCanBeOperatedByCaller(_dcaId);

    _swapped = _calculateSwapped(_dcaId);

    _userPositions[_dcaId].lastWithdrawSwap = performedSwaps[_userPositions[_dcaId].swapInterval];
    _userPositions[_dcaId].swappedBeforeModified = 0;

    IERC20Metadata _to = _getTo(_dcaId);
    _balances[address(_to)] -= _swapped;
    _to.safeTransfer(msg.sender, _swapped);

    emit Withdrew(msg.sender, _dcaId, address(_to), _swapped);
  }

  function withdrawSwappedMany(uint256[] calldata _dcaIds)
    external
    override
    nonReentrant
    returns (uint256 _swappedTokenA, uint256 _swappedTokenB)
  {
    for (uint256 i; i < _dcaIds.length; i++) {
      uint256 _dcaId = _dcaIds[i];
      _assertPositionExistsAndCanBeOperatedByCaller(_dcaId);
      uint256 _swappedDCA = _calculateSwapped(_dcaId);
      if (_userPositions[_dcaId].fromTokenA) {
        _swappedTokenB += _swappedDCA;
      } else {
        _swappedTokenA += _swappedDCA;
      }
      _userPositions[_dcaId].lastWithdrawSwap = performedSwaps[_userPositions[_dcaId].swapInterval];
      _userPositions[_dcaId].swappedBeforeModified = 0;
    }

    if (_swappedTokenA > 0) {
      _balances[address(tokenA)] -= _swappedTokenA;
      tokenA.safeTransfer(msg.sender, _swappedTokenA);
    }

    if (_swappedTokenB > 0) {
      _balances[address(tokenB)] -= _swappedTokenB;
      tokenB.safeTransfer(msg.sender, _swappedTokenB);
    }
    emit WithdrewMany(msg.sender, _dcaIds, _swappedTokenA, _swappedTokenB);
  }

  function terminate(uint256 _dcaId) external override nonReentrant {
    _assertPositionExistsAndCanBeOperatedByCaller(_dcaId);

    uint256 _swapped = _calculateSwapped(_dcaId);
    uint256 _unswapped = _calculateUnswapped(_dcaId);

    IERC20Metadata _from = _getFrom(_dcaId);
    IERC20Metadata _to = _getTo(_dcaId);
    _removePosition(_dcaId);
    _burn(_dcaId);

    if (_swapped > 0) {
      _balances[address(_to)] -= _swapped;
      _to.safeTransfer(msg.sender, _swapped);
    }

    if (_unswapped > 0) {
      _balances[address(_from)] -= _unswapped;
      _from.safeTransfer(msg.sender, _unswapped);
    }

    emit Terminated(msg.sender, _dcaId, _unswapped, _swapped);
  }

  function modifyRate(uint256 _dcaId, uint160 _newRate) external override nonReentrant {
    _assertPositionExistsAndCanBeOperatedByCaller(_dcaId);
    uint32 _swapsLeft = _userPositions[_dcaId].lastSwap - performedSwaps[_userPositions[_dcaId].swapInterval];
    if (_swapsLeft == 0) revert PositionCompleted();

    _modifyRateAndSwaps(_dcaId, _newRate, _swapsLeft);
  }

  function modifySwaps(uint256 _dcaId, uint32 _newSwaps) external override nonReentrant {
    _modifyRateAndSwaps(_dcaId, _userPositions[_dcaId].rate, _newSwaps);
  }

  function modifyRateAndSwaps(
    uint256 _dcaId,
    uint160 _newRate,
    uint32 _newAmountOfSwaps
  ) external override nonReentrant {
    _modifyRateAndSwaps(_dcaId, _newRate, _newAmountOfSwaps);
  }

  function addFundsToPosition(
    uint256 _dcaId,
    uint256 _amount,
    uint32 _newSwaps
  ) external override nonReentrant {
    if (_amount == 0) revert ZeroAmount();
    if (_newSwaps == 0) revert ZeroSwaps();

    uint256 _unswapped = _calculateUnswapped(_dcaId);
    uint256 _total = _unswapped + _amount;

    _modifyPosition(_dcaId, _total, _unswapped, uint160(_total / _newSwaps), _newSwaps);
  }

  function tokenURI(uint256 tokenId) public view override returns (string memory) {
    return globalParameters.nftDescriptor().tokenURI(this, tokenId);
  }

  function _modifyRateAndSwaps(
    uint256 _dcaId,
    uint160 _newRate,
    uint32 _newAmountOfSwaps
  ) internal {
    _modifyPosition(_dcaId, _newRate * _newAmountOfSwaps, _calculateUnswapped(_dcaId), _newRate, _newAmountOfSwaps);
  }

  function _modifyPosition(
    uint256 _dcaId,
    uint256 _totalNecessary,
    uint256 _unswapped,
    uint160 _newRate,
    uint32 _newAmountOfSwaps
  ) internal {
    _assertPositionExistsAndCanBeOperatedByCaller(_dcaId);
    IERC20Metadata _from = _getFrom(_dcaId);

    uint256 _swapped = _calculateSwapped(_dcaId);
    if (_swapped > type(uint248).max) revert MandatoryWithdraw(); // You should withdraw before modifying, to avoid losing funds

    uint32 _swapInterval = _userPositions[_dcaId].swapInterval;
    _removePosition(_dcaId);
    (uint32 _startingSwap, uint32 _lastSwap) = _addPosition(
      _dcaId,
      address(_from),
      _newRate,
      _newAmountOfSwaps,
      uint248(_swapped),
      _swapInterval
    );

    if (_totalNecessary > _unswapped) {
      _from.safeTransferFrom(msg.sender, address(this), _totalNecessary - _unswapped);
      _balances[address(_from)] += _totalNecessary - _unswapped;
    } else if (_totalNecessary < _unswapped) {
      _balances[address(_from)] -= _unswapped - _totalNecessary;
      _from.safeTransfer(msg.sender, _unswapped - _totalNecessary);
    }

    emit Modified(msg.sender, _dcaId, _newRate, _startingSwap, _lastSwap);
  }

  function _assertPositionExistsAndCanBeOperatedByCaller(uint256 _dcaId) internal view {
    if (_userPositions[_dcaId].rate == 0) revert InvalidPosition();
    if (!_isApprovedOrOwner(msg.sender, _dcaId)) revert UnauthorizedCaller();
  }

  function _addPosition(
    uint256 _dcaId,
    address _from,
    uint160 _rate,
    uint32 _amountOfSwaps,
    uint248 _swappedBeforeModified,
    uint32 _swapInterval
  ) internal returns (uint32 _startingSwap, uint32 _lastSwap) {
    if (_rate == 0) revert ZeroRate();
    uint32 _performedSwaps = performedSwaps[_swapInterval];
    _startingSwap = _performedSwaps + 1;
    _lastSwap = _performedSwaps + _amountOfSwaps;
    swapAmountDelta[_swapInterval][_from][_startingSwap] += int160(_rate);
    swapAmountDelta[_swapInterval][_from][_lastSwap + 1] -= int160(_rate);
    _userPositions[_dcaId] = DCA(_performedSwaps, _lastSwap, _swapInterval, _rate, _from == address(tokenA), _swappedBeforeModified);
  }

  function _removePosition(uint256 _dcaId) internal {
    uint32 _swapInterval = _userPositions[_dcaId].swapInterval;
    uint32 _lastSwap = _userPositions[_dcaId].lastSwap;
    uint32 _performedSwaps = performedSwaps[_swapInterval];

    if (_lastSwap > _performedSwaps) {
      int160 _rate = int160(_userPositions[_dcaId].rate);
      address _from = address(_getFrom(_dcaId));
      swapAmountDelta[_swapInterval][_from][_performedSwaps + 1] -= _rate;
      swapAmountDelta[_swapInterval][_from][_lastSwap + 1] += _rate;
    }
    delete _userPositions[_dcaId];
  }

  function _calculateSwapped(uint256 _dcaId) internal view returns (uint256 _swapped) {
    DCA memory _userDCA = _userPositions[_dcaId];
    address _from = _userDCA.fromTokenA ? address(tokenA) : address(tokenB);
    uint256 _accumRatesLastSwap = _accumRatesPerUnit[_userDCA.swapInterval][_from][
      performedSwaps[_userDCA.swapInterval] < _userDCA.lastSwap ? performedSwaps[_userDCA.swapInterval] : _userDCA.lastSwap
    ];

    uint256 _accumPerUnit = _accumRatesLastSwap - _accumRatesPerUnit[_userDCA.swapInterval][_from][_userDCA.lastWithdrawSwap];
    uint256 _magnitude = _userDCA.fromTokenA ? _magnitudeA : _magnitudeB;
    (bool _ok, uint256 _mult) = Math.tryMul(_accumPerUnit, _userDCA.rate);
    uint256 _swappedInCurrentPosition = _ok ? _mult / _magnitude : (_accumPerUnit / _magnitude) * _userDCA.rate;
    _swapped = _swappedInCurrentPosition + _userDCA.swappedBeforeModified;
  }

  function _calculateUnswapped(uint256 _dcaId) internal view returns (uint256 _unswapped) {
    uint32 _performedSwaps = performedSwaps[_userPositions[_dcaId].swapInterval];
    uint32 _lastSwap = _userPositions[_dcaId].lastSwap;

    if (_lastSwap <= _performedSwaps) return 0;
    _unswapped = (_lastSwap - _performedSwaps) * _userPositions[_dcaId].rate;
  }

  function _getFrom(uint256 _dcaId) internal view returns (IERC20Metadata _from) {
    _from = _userPositions[_dcaId].fromTokenA ? tokenA : tokenB;
  }

  function _getTo(uint256 _dcaId) internal view returns (IERC20Metadata _to) {
    _to = _userPositions[_dcaId].fromTokenA ? tokenB : tokenA;
  }
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
}// BUSL-1.1
pragma solidity ^0.8.6;
pragma abicoder v2;




abstract contract DCAPairSwapHandler is ReentrancyGuard, DCAPairParameters, IDCAPairSwapHandler {
  using SafeERC20 for IERC20Metadata;
  using EnumerableSet for EnumerableSet.UintSet;

  mapping(uint32 => mapping(address => uint256)) public override swapAmountAccumulator; // swap interval => from token => swap amount accum

  mapping(uint32 => uint32) public override nextSwapAvailable; // swap interval => timestamp

  function _addNewRatePerUnit(
    uint32 _swapInterval,
    address _address,
    uint32 _performedSwap,
    uint256 _ratePerUnit
  ) internal {
    uint256 _accumRatesPerUnitPreviousSwap = _accumRatesPerUnit[_swapInterval][_address][_performedSwap - 1];
    _accumRatesPerUnit[_swapInterval][_address][_performedSwap] = _accumRatesPerUnitPreviousSwap + _ratePerUnit;
  }

  function _registerSwap(
    uint32 _swapInterval,
    address _token,
    uint256 _internalAmountUsedToSwap,
    uint256 _ratePerUnit,
    uint32 _swapToRegister
  ) internal {
    swapAmountAccumulator[_swapInterval][_token] = _internalAmountUsedToSwap;
    _addNewRatePerUnit(_swapInterval, _token, _swapToRegister, _ratePerUnit);
    delete swapAmountDelta[_swapInterval][_token][_swapToRegister];
  }

  function _getAmountToSwap(
    uint32 _swapInterval,
    address _address,
    uint32 _swapToPerform
  ) internal view returns (uint256 _swapAmountAccumulator) {
    unchecked {
      _swapAmountAccumulator =
        swapAmountAccumulator[_swapInterval][_address] +
        uint256(swapAmountDelta[_swapInterval][_address][_swapToPerform]);
    }
  }

  function _convertTo(
    uint256 _fromTokenMagnitude,
    uint256 _amountFrom,
    uint256 _rateFromTo
  ) internal pure returns (uint256 _amountTo) {
    _amountTo = (_amountFrom * _rateFromTo) / _fromTokenMagnitude;
  }

  function _getNextSwapsToPerform() internal view virtual returns (SwapInformation[] memory _swapsToPerform, uint8 _amountOfSwapsToPerform) {
    uint256 _activeSwapIntervalsLength = _activeSwapIntervals.length();
    _swapsToPerform = new SwapInformation[](_activeSwapIntervalsLength);
    for (uint256 i; i < _activeSwapIntervalsLength; i++) {
      uint32 _swapInterval = uint32(_activeSwapIntervals.at(i));
      if (nextSwapAvailable[_swapInterval] <= _getTimestamp()) {
        uint32 _swapToPerform = performedSwaps[_swapInterval] + 1;
        _swapsToPerform[_amountOfSwapsToPerform++] = SwapInformation({
          interval: _swapInterval,
          swapToPerform: _swapToPerform,
          amountToSwapTokenA: _getAmountToSwap(_swapInterval, address(tokenA), _swapToPerform),
          amountToSwapTokenB: _getAmountToSwap(_swapInterval, address(tokenB), _swapToPerform)
        });
      }
    }
  }

  function secondsUntilNextSwap() external view override returns (uint32 _secondsUntil) {
    _secondsUntil = type(uint32).max;
    uint32 _timestamp = _getTimestamp();
    for (uint256 i; i < _activeSwapIntervals.length(); i++) {
      uint32 _swapInterval = uint32(_activeSwapIntervals.at(i));
      if (nextSwapAvailable[_swapInterval] <= _timestamp) {
        _secondsUntil = 0;
        break;
      } else {
        uint32 _diff = nextSwapAvailable[_swapInterval] - _timestamp;
        if (_diff < _secondsUntil) {
          _secondsUntil = _diff;
        }
      }
    }
  }

  function getNextSwapInfo() external view override returns (NextSwapInformation memory _nextSwapInformation) {
    IDCAGlobalParameters.SwapParameters memory _swapParameters = globalParameters.swapParameters();
    (_nextSwapInformation, , ) = _getNextSwapInfo(_swapParameters.swapFee, _swapParameters.oracle);
  }

  function _getNextSwapInfo(uint32 _swapFee, ITimeWeightedOracle _oracle)
    internal
    view
    virtual
    returns (
      NextSwapInformation memory _nextSwapInformation,
      uint256 _ratePerUnitBToAWithFee,
      uint256 _ratePerUnitAToBWithFee
    )
  {
    uint256 _amountToSwapTokenA;
    uint256 _amountToSwapTokenB;
    {
      (SwapInformation[] memory _swapsToPerform, uint8 _amountOfSwaps) = _getNextSwapsToPerform();
      for (uint256 i; i < _amountOfSwaps; i++) {
        _amountToSwapTokenA += _swapsToPerform[i].amountToSwapTokenA;
        _amountToSwapTokenB += _swapsToPerform[i].amountToSwapTokenB;
      }
      _nextSwapInformation.swapsToPerform = _swapsToPerform;
      _nextSwapInformation.amountOfSwaps = _amountOfSwaps;
    }

    _nextSwapInformation.ratePerUnitBToA = _oracle.quote(address(tokenB), _magnitudeB, address(tokenA));
    _nextSwapInformation.ratePerUnitAToB = (uint256(_magnitudeB) * _magnitudeA) / _nextSwapInformation.ratePerUnitBToA;

    _ratePerUnitBToAWithFee = _nextSwapInformation.ratePerUnitBToA - _getFeeFromAmount(_swapFee, _nextSwapInformation.ratePerUnitBToA);
    _ratePerUnitAToBWithFee = _nextSwapInformation.ratePerUnitAToB - _getFeeFromAmount(_swapFee, _nextSwapInformation.ratePerUnitAToB);

    uint256 _finalNeededTokenA = _convertTo(_magnitudeB, _amountToSwapTokenB, _ratePerUnitBToAWithFee);
    uint256 _finalNeededTokenB = _convertTo(_magnitudeA, _amountToSwapTokenA, _ratePerUnitAToBWithFee);

    uint256 _amountOfTokenAIfTokenBSwapped = _convertTo(_magnitudeB, _amountToSwapTokenB, _nextSwapInformation.ratePerUnitBToA);
    if (_amountOfTokenAIfTokenBSwapped < _amountToSwapTokenA) {
      _nextSwapInformation.tokenToBeProvidedBySwapper = tokenB;
      _nextSwapInformation.tokenToRewardSwapperWith = tokenA;
      _nextSwapInformation.platformFeeTokenA = _getFeeFromAmount(_swapFee, _amountOfTokenAIfTokenBSwapped);
      _nextSwapInformation.platformFeeTokenB = _getFeeFromAmount(_swapFee, _amountToSwapTokenB);
      _nextSwapInformation.amountToBeProvidedBySwapper = _finalNeededTokenB + _nextSwapInformation.platformFeeTokenB - _amountToSwapTokenB;
      _nextSwapInformation.amountToRewardSwapperWith = _amountToSwapTokenA - _finalNeededTokenA - _nextSwapInformation.platformFeeTokenA;
      _nextSwapInformation.availableToBorrowTokenA = _balances[address(tokenA)] - _nextSwapInformation.amountToRewardSwapperWith;
      _nextSwapInformation.availableToBorrowTokenB = _balances[address(tokenB)];
    } else if (_amountOfTokenAIfTokenBSwapped > _amountToSwapTokenA) {
      _nextSwapInformation.tokenToBeProvidedBySwapper = tokenA;
      _nextSwapInformation.tokenToRewardSwapperWith = tokenB;
      _nextSwapInformation.platformFeeTokenA = _getFeeFromAmount(_swapFee, _amountToSwapTokenA);
      _nextSwapInformation.platformFeeTokenB = _getFeeFromAmount(
        _swapFee,
        (_amountToSwapTokenA * _magnitudeB) / _nextSwapInformation.ratePerUnitBToA
      );
      _nextSwapInformation.amountToBeProvidedBySwapper = _finalNeededTokenA + _nextSwapInformation.platformFeeTokenA - _amountToSwapTokenA;
      _nextSwapInformation.amountToRewardSwapperWith = _amountToSwapTokenB - _finalNeededTokenB - _nextSwapInformation.platformFeeTokenB;
      _nextSwapInformation.availableToBorrowTokenA = _balances[address(tokenA)];
      _nextSwapInformation.availableToBorrowTokenB = _balances[address(tokenB)] - _nextSwapInformation.amountToRewardSwapperWith;
    } else {
      _nextSwapInformation.platformFeeTokenA = _getFeeFromAmount(_swapFee, _amountToSwapTokenA);
      _nextSwapInformation.platformFeeTokenB = _getFeeFromAmount(_swapFee, _amountToSwapTokenB);
      _nextSwapInformation.availableToBorrowTokenA = _balances[address(tokenA)];
      _nextSwapInformation.availableToBorrowTokenB = _balances[address(tokenB)];
    }
  }

  function swap() external override {
    swap(0, 0, msg.sender, '');
  }

  function swap(
    uint256 _amountToBorrowTokenA,
    uint256 _amountToBorrowTokenB,
    address _to,
    bytes memory _data
  ) public override nonReentrant {
    IDCAGlobalParameters.SwapParameters memory _swapParameters = globalParameters.swapParameters();
    if (_swapParameters.isPaused) revert CommonErrors.Paused();

    NextSwapInformation memory _nextSwapInformation;

    {
      uint256 _ratePerUnitBToAWithFee;
      uint256 _ratePerUnitAToBWithFee;
      (_nextSwapInformation, _ratePerUnitBToAWithFee, _ratePerUnitAToBWithFee) = _getNextSwapInfo(
        _swapParameters.swapFee,
        _swapParameters.oracle
      );
      if (_nextSwapInformation.amountOfSwaps == 0) revert NoSwapsToExecute();

      uint32 _timestamp = _getTimestamp();
      for (uint256 i; i < _nextSwapInformation.amountOfSwaps; i++) {
        uint32 _swapInterval = _nextSwapInformation.swapsToPerform[i].interval;
        uint32 _swapToPerform = _nextSwapInformation.swapsToPerform[i].swapToPerform;
        if (_nextSwapInformation.swapsToPerform[i].amountToSwapTokenA > 0 || _nextSwapInformation.swapsToPerform[i].amountToSwapTokenB > 0) {
          _registerSwap(
            _swapInterval,
            address(tokenA),
            _nextSwapInformation.swapsToPerform[i].amountToSwapTokenA,
            _ratePerUnitAToBWithFee,
            _swapToPerform
          );
          _registerSwap(
            _swapInterval,
            address(tokenB),
            _nextSwapInformation.swapsToPerform[i].amountToSwapTokenB,
            _ratePerUnitBToAWithFee,
            _swapToPerform
          );
          performedSwaps[_swapInterval] = _swapToPerform;
          nextSwapAvailable[_swapInterval] = ((_timestamp / _swapInterval) + 1) * _swapInterval;
        } else {
          _activeSwapIntervals.remove(_swapInterval);
        }
      }
    }

    if (
      _amountToBorrowTokenA > _nextSwapInformation.availableToBorrowTokenA ||
      _amountToBorrowTokenB > _nextSwapInformation.availableToBorrowTokenB
    ) revert CommonErrors.InsufficientLiquidity();

    uint256 _finalAmountToHaveTokenA = _nextSwapInformation.availableToBorrowTokenA - _nextSwapInformation.platformFeeTokenA;
    uint256 _finalAmountToHaveTokenB = _nextSwapInformation.availableToBorrowTokenB - _nextSwapInformation.platformFeeTokenB;

    {
      uint256 _amountToSendTokenA = _amountToBorrowTokenA;
      uint256 _amountToSendTokenB = _amountToBorrowTokenB;

      if (_nextSwapInformation.tokenToRewardSwapperWith == tokenA) {
        _amountToSendTokenA += _nextSwapInformation.amountToRewardSwapperWith;
        _finalAmountToHaveTokenB += _nextSwapInformation.amountToBeProvidedBySwapper;
      } else {
        _amountToSendTokenB += _nextSwapInformation.amountToRewardSwapperWith;
        _finalAmountToHaveTokenA += _nextSwapInformation.amountToBeProvidedBySwapper;
      }

      if (_amountToSendTokenA > 0) tokenA.safeTransfer(_to, _amountToSendTokenA);
      if (_amountToSendTokenB > 0) tokenB.safeTransfer(_to, _amountToSendTokenB);
    }

    if (_data.length > 0) {
      IDCAPairSwapCallee(_to).DCAPairSwapCall(
        msg.sender,
        tokenA,
        tokenB,
        _amountToBorrowTokenA,
        _amountToBorrowTokenB,
        _nextSwapInformation.tokenToRewardSwapperWith == tokenA,
        _nextSwapInformation.amountToRewardSwapperWith,
        _nextSwapInformation.amountToBeProvidedBySwapper,
        _data
      );
    }

    uint256 _balanceTokenA = tokenA.balanceOf(address(this));
    uint256 _balanceTokenB = tokenB.balanceOf(address(this));

    if (
      _balanceTokenA < (_finalAmountToHaveTokenA + _nextSwapInformation.platformFeeTokenA) ||
      _balanceTokenB < (_finalAmountToHaveTokenB + _nextSwapInformation.platformFeeTokenB)
    ) revert CommonErrors.LiquidityNotReturned();

    _balances[address(tokenA)] = _finalAmountToHaveTokenA;
    _balances[address(tokenB)] = _finalAmountToHaveTokenB;

    uint256 _toFeeRecipientTokenA = _balanceTokenA - _finalAmountToHaveTokenA;
    uint256 _toFeeRecipientTokenB = _balanceTokenB - _finalAmountToHaveTokenB;
    if (_toFeeRecipientTokenA > 0) tokenA.safeTransfer(_swapParameters.feeRecipient, _toFeeRecipientTokenA);
    if (_toFeeRecipientTokenB > 0) tokenB.safeTransfer(_swapParameters.feeRecipient, _toFeeRecipientTokenB);

    emit Swapped(msg.sender, _to, _amountToBorrowTokenA, _amountToBorrowTokenB, _swapParameters.swapFee, _nextSwapInformation);
  }

  function _getTimestamp() internal view virtual returns (uint32 _blockTimestamp) {
    _blockTimestamp = uint32(block.timestamp);
  }
}// GPL-2.0-or-later
pragma solidity ^0.8.6;


interface IDCAPairLoanCallee {
  function DCAPairLoanCall(
    address _sender,
    IERC20Metadata _tokenA,
    IERC20Metadata _tokenB,
    uint256 _amountBorrowedTokenA,
    uint256 _amountBorrowedTokenB,
    uint256 _feeTokenA,
    uint256 _feeTokenB,
    bytes calldata _data
  ) external;
}// BUSL-1.1
pragma solidity ^0.8.6;




abstract contract DCAPairLoanHandler is ReentrancyGuard, DCAPairParameters, IDCAPairLoanHandler {
  using SafeERC20 for IERC20Metadata;

  function availableToBorrow() external view override returns (uint256 _amountToBorrowTokenA, uint256 _amountToBorrowTokenB) {
    _amountToBorrowTokenA = _balances[address(tokenA)];
    _amountToBorrowTokenB = _balances[address(tokenB)];
  }

  function loan(
    uint256 _amountToBorrowTokenA,
    uint256 _amountToBorrowTokenB,
    address _to,
    bytes calldata _data
  ) external override nonReentrant {
    if (_amountToBorrowTokenA == 0 && _amountToBorrowTokenB == 0) revert ZeroLoan();

    IDCAGlobalParameters.LoanParameters memory _loanParameters = globalParameters.loanParameters();

    if (_loanParameters.isPaused) revert CommonErrors.Paused();

    uint256 _beforeBalanceTokenA = _balances[address(tokenA)];
    uint256 _beforeBalanceTokenB = _balances[address(tokenB)];

    if (_amountToBorrowTokenA > _beforeBalanceTokenA || _amountToBorrowTokenB > _beforeBalanceTokenB)
      revert CommonErrors.InsufficientLiquidity();

    uint256 _feeTokenA = _amountToBorrowTokenA > 0 ? _getFeeFromAmount(_loanParameters.loanFee, _amountToBorrowTokenA) : 0;
    uint256 _feeTokenB = _amountToBorrowTokenB > 0 ? _getFeeFromAmount(_loanParameters.loanFee, _amountToBorrowTokenB) : 0;

    if (_amountToBorrowTokenA > 0) tokenA.safeTransfer(_to, _amountToBorrowTokenA);
    if (_amountToBorrowTokenB > 0) tokenB.safeTransfer(_to, _amountToBorrowTokenB);

    IDCAPairLoanCallee(_to).DCAPairLoanCall(
      msg.sender,
      tokenA,
      tokenB,
      _amountToBorrowTokenA,
      _amountToBorrowTokenB,
      _feeTokenA,
      _feeTokenB,
      _data
    );

    uint256 _afterBalanceTokenA = tokenA.balanceOf(address(this));
    uint256 _afterBalanceTokenB = tokenB.balanceOf(address(this));

    if (_afterBalanceTokenA < (_beforeBalanceTokenA + _feeTokenA) || _afterBalanceTokenB < (_beforeBalanceTokenB + _feeTokenB))
      revert CommonErrors.LiquidityNotReturned();

    {
      uint256 _toFeeRecipientTokenA = _afterBalanceTokenA - _beforeBalanceTokenA;
      uint256 _toFeeRecipientTokenB = _afterBalanceTokenB - _beforeBalanceTokenB;
      if (_toFeeRecipientTokenA > 0) tokenA.safeTransfer(_loanParameters.feeRecipient, _toFeeRecipientTokenA);
      if (_toFeeRecipientTokenB > 0) tokenB.safeTransfer(_loanParameters.feeRecipient, _toFeeRecipientTokenB);
    }

    emit Loaned(msg.sender, _to, _amountToBorrowTokenA, _amountToBorrowTokenB, _loanParameters.loanFee);
  }
}// BUSL-1.1
pragma solidity ^0.8.6;


contract DCAPair is DCAPairParameters, DCAPairSwapHandler, DCAPairPositionHandler, DCAPairLoanHandler, IDCAPair {
  constructor(
    IDCAGlobalParameters _globalParameters,
    IERC20Metadata _tokenA,
    IERC20Metadata _tokenB
  ) DCAPairParameters(_globalParameters, _tokenA, _tokenB) DCAPairPositionHandler(_tokenA, _tokenB) {}
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

interface IDCAFactory is IDCAFactoryPairsHandler {}// BUSL-1.1
pragma solidity ^0.8.6;


abstract contract DCAFactoryPairsHandler is IDCAFactoryPairsHandler {
  using EnumerableSet for EnumerableSet.AddressSet;

  mapping(address => mapping(address => address)) internal _pairByTokens; // tokenA => tokenB => pair
  EnumerableSet.AddressSet internal _allPairs;
  IDCAGlobalParameters public override globalParameters;

  constructor(IDCAGlobalParameters _globalParameters) {
    if (address(_globalParameters) == address(0)) revert CommonErrors.ZeroAddress();
    globalParameters = _globalParameters;
  }

  function _sortTokens(address _tokenA, address _tokenB) internal pure returns (address __tokenA, address __tokenB) {
    (__tokenA, __tokenB) = _tokenA < _tokenB ? (_tokenA, _tokenB) : (_tokenB, _tokenA);
  }

  function allPairs() external view override returns (address[] memory _pairs) {
    uint256 _length = _allPairs.length();
    _pairs = new address[](_length);
    for (uint256 i; i < _length; i++) {
      _pairs[i] = _allPairs.at(i);
    }
  }

  function isPair(address _address) external view override returns (bool _isPair) {
    _isPair = _allPairs.contains(_address);
  }

  function pairByTokens(address _tokenA, address _tokenB) external view override returns (address _pair) {
    (address __tokenA, address __tokenB) = _sortTokens(_tokenA, _tokenB);
    _pair = _pairByTokens[__tokenA][__tokenB];
  }

  function createPair(address _tokenA, address _tokenB) external override returns (address _pair) {
    if (_tokenA == address(0) || _tokenB == address(0)) revert CommonErrors.ZeroAddress();
    if (_tokenA == _tokenB) revert IdenticalTokens();
    (address __tokenA, address __tokenB) = _sortTokens(_tokenA, _tokenB);
    if (_pairByTokens[__tokenA][__tokenB] != address(0)) revert PairAlreadyExists();
    globalParameters.oracle().addSupportForPair(__tokenA, __tokenB); // Note: this call will revert if the oracle doesn't support this particular pair
    _pair = address(new DCAPair(globalParameters, IERC20Metadata(__tokenA), IERC20Metadata(__tokenB)));
    _pairByTokens[__tokenA][__tokenB] = _pair;
    _allPairs.add(_pair);
    emit PairCreated(__tokenA, __tokenB, _pair);
  }
}// BUSL-1.1
pragma solidity ^0.8.6;


contract DCAFactory is DCAFactoryPairsHandler, IDCAFactory {
  constructor(IDCAGlobalParameters _globalParameters) DCAFactoryPairsHandler(_globalParameters) {}
}