

pragma solidity 0.8.6;




contract BetaRunnerWithCallback {

  address private constant NO_CALLER = address(42); // nonzero so we don't repeatedly clear storage
  address private caller = NO_CALLER;

  modifier withCallback() {

    require(caller == NO_CALLER);
    caller = msg.sender;
    _;
    caller = NO_CALLER;
  }

  modifier isCallback() {

    require(caller == tx.origin);
    _;
  }
}


library BytesLib {

  function slice(
    bytes memory _bytes,
    uint _start,
    uint _length
  ) internal pure returns (bytes memory) {

    require(_length + 31 >= _length, 'slice_overflow');
    require(_start + _length >= _start, 'slice_overflow');
    require(_bytes.length >= _start + _length, 'slice_outOfBounds');

    bytes memory tempBytes;

    assembly {
      switch iszero(_length)
      case 0 {
        tempBytes := mload(0x40)

        let lengthmod := and(_length, 31)

        let mc := add(add(tempBytes, lengthmod), mul(0x20, iszero(lengthmod)))
        let end := add(mc, _length)

        for {
          let cc := add(add(add(_bytes, lengthmod), mul(0x20, iszero(lengthmod))), _start)
        } lt(mc, end) {
          mc := add(mc, 0x20)
          cc := add(cc, 0x20)
        } {
          mstore(mc, mload(cc))
        }

        mstore(tempBytes, _length)

        mstore(0x40, and(add(mc, 31), not(31)))
      }
      default {
        tempBytes := mload(0x40)
        mstore(tempBytes, 0)

        mstore(0x40, add(tempBytes, 0x20))
      }
    }

    return tempBytes;
  }

  function toAddress(bytes memory _bytes, uint _start) internal pure returns (address) {

    require(_start + 20 >= _start, 'toAddress_overflow');
    require(_bytes.length >= _start + 20, 'toAddress_outOfBounds');
    address tempAddress;

    assembly {
      tempAddress := div(mload(add(add(_bytes, 0x20), _start)), 0x1000000000000000000000000)
    }

    return tempAddress;
  }

  function toUint24(bytes memory _bytes, uint _start) internal pure returns (uint24) {

    require(_start + 3 >= _start, 'toUint24_overflow');
    require(_bytes.length >= _start + 3, 'toUint24_outOfBounds');
    uint24 tempUint;

    assembly {
      tempUint := mload(add(add(_bytes, 0x3), _start))
    }

    return tempUint;
  }
}


interface IBetaBank {

  function bTokens(address _underlying) external view returns (address);


  function underlyings(address _bToken) external view returns (address);


  function oracle() external view returns (address);


  function config() external view returns (address);


  function interestModel() external view returns (address);


  function getPositionTokens(address _owner, uint _pid)
    external
    view
    returns (address _collateral, address _bToken);


  function fetchPositionDebt(address _owner, uint _pid) external returns (uint);


  function fetchPositionLTV(address _owner, uint _pid) external returns (uint);


  function open(
    address _owner,
    address _underlying,
    address _collateral
  ) external returns (uint pid);


  function borrow(
    address _owner,
    uint _pid,
    uint _amount
  ) external;


  function repay(
    address _owner,
    uint _pid,
    uint _amount
  ) external;


  function put(
    address _owner,
    uint _pid,
    uint _amount
  ) external;


  function take(
    address _owner,
    uint _pid,
    uint _amount
  ) external;


  function liquidate(
    address _owner,
    uint _pid,
    uint _amount
  ) external;

}


interface IUniswapV3Pool {

  function mint(
    address recipient,
    int24 tickLower,
    int24 tickUpper,
    uint128 amount,
    bytes calldata data
  ) external returns (uint amount0, uint amount1);


  function swap(
    address recipient,
    bool zeroForOne,
    int amountSpecified,
    uint160 sqrtPriceLimitX96,
    bytes calldata data
  ) external returns (int amount0, int amount1);


  function initialize(uint160 sqrtPriceX96) external;

}


interface IUniswapV3SwapCallback {

  function uniswapV3SwapCallback(
    int amount0Delta,
    int amount1Delta,
    bytes calldata data
  ) external;

}


interface IWETH {

  function deposit() external payable;


  function withdraw(uint wad) external;


  function approve(address guy, uint wad) external returns (bool);

}


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
}


abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}


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
}


library Math {

    function max(uint256 a, uint256 b) internal pure returns (uint256) {

        return a >= b ? a : b;
    }

    function min(uint256 a, uint256 b) internal pure returns (uint256) {

        return a < b ? a : b;
    }

    function average(uint256 a, uint256 b) internal pure returns (uint256) {

        return (a / 2) + (b / 2) + (((a % 2) + (b % 2)) / 2);
    }

    function ceilDiv(uint256 a, uint256 b) internal pure returns (uint256) {

        return a / b + (a % b == 0 ? 0 : 1);
    }
}


library SafeCast {

  function toUint160(uint y) internal pure returns (uint160 z) {

    require((z = uint160(y)) == y);
  }

  function toInt128(int y) internal pure returns (int128 z) {

    require((z = int128(y)) == y);
  }

  function toInt256(uint y) internal pure returns (int z) {

    require(y < 2**255);
    z = int(y);
  }
}


abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor() {
        _setOwner(_msgSender());
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        _setOwner(address(0));
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _setOwner(newOwner);
    }

    function _setOwner(address newOwner) private {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}


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
}


library Path {

  using BytesLib for bytes;

  uint private constant ADDR_SIZE = 20;
  uint private constant FEE_SIZE = 3;

  uint private constant NEXT_OFFSET = ADDR_SIZE + FEE_SIZE;
  uint private constant POP_OFFSET = NEXT_OFFSET + ADDR_SIZE;
  uint private constant MULTIPLE_POOLS_MIN_LENGTH = POP_OFFSET + NEXT_OFFSET;

  function hasMultiplePools(bytes memory path) internal pure returns (bool) {

    return path.length >= MULTIPLE_POOLS_MIN_LENGTH;
  }

  function decodeFirstPool(bytes memory path)
    internal
    pure
    returns (
      address tokenA,
      address tokenB,
      uint24 fee
    )
  {

    tokenA = path.toAddress(0);
    fee = path.toUint24(ADDR_SIZE);
    tokenB = path.toAddress(NEXT_OFFSET);
  }

  function decodeLastPool(bytes memory path)
    internal
    pure
    returns (
      address tokenA,
      address tokenB,
      uint24 fee
    )
  {

    tokenB = path.toAddress(path.length - ADDR_SIZE);
    fee = path.toUint24(path.length - NEXT_OFFSET);
    tokenA = path.toAddress(path.length - POP_OFFSET);
  }

  function skipToken(bytes memory path) internal pure returns (bytes memory) {

    return path.slice(NEXT_OFFSET, path.length - NEXT_OFFSET);
  }
}


contract BetaRunnerBase is Ownable {

  using SafeERC20 for IERC20;

  address public immutable betaBank;
  address public immutable weth;

  modifier onlyEOA() {

    require(msg.sender == tx.origin, 'BetaRunnerBase/not-eoa');
    _;
  }

  constructor(address _betaBank, address _weth) {
    address bweth = IBetaBank(_betaBank).bTokens(_weth);
    require(bweth != address(0), 'BetaRunnerBase/no-bweth');
    IERC20(_weth).safeApprove(_betaBank, type(uint).max);
    IERC20(_weth).safeApprove(bweth, type(uint).max);
    betaBank = _betaBank;
    weth = _weth;
  }

  function _borrow(
    address _owner,
    uint _pid,
    address _underlying,
    address _collateral,
    uint _amountBorrow,
    uint _amountCollateral
  ) internal {

    if (_pid == type(uint).max) {
      _pid = IBetaBank(betaBank).open(_owner, _underlying, _collateral);
    } else {
      (address collateral, address bToken) = IBetaBank(betaBank).getPositionTokens(_owner, _pid);
      require(_collateral == collateral, '_borrow/collateral-not-_collateral');
      require(_underlying == IBetaBank(betaBank).underlyings(bToken), '_borrow/bad-underlying');
    }
    _approve(_collateral, betaBank, _amountCollateral);
    IBetaBank(betaBank).put(_owner, _pid, _amountCollateral);
    IBetaBank(betaBank).borrow(_owner, _pid, _amountBorrow);
  }

  function _repay(
    address _owner,
    uint _pid,
    address _underlying,
    address _collateral,
    uint _amountRepay,
    uint _amountCollateral
  ) internal {

    (address collateral, address bToken) = IBetaBank(betaBank).getPositionTokens(_owner, _pid);
    require(_collateral == collateral, '_repay/collateral-not-_collateral');
    require(_underlying == IBetaBank(betaBank).underlyings(bToken), '_repay/bad-underlying');
    _approve(_underlying, bToken, _amountRepay);
    IBetaBank(betaBank).repay(_owner, _pid, _amountRepay);
    IBetaBank(betaBank).take(_owner, _pid, _amountCollateral);
  }

  function _transferIn(
    address _token,
    address _from,
    uint _amount
  ) internal {

    if (_token == weth) {
      require(_from == msg.sender, '_transferIn/not-from-sender');
      require(_amount <= msg.value, '_transferIn/insufficient-eth-amount');
      IWETH(weth).deposit{value: _amount}();
      if (msg.value > _amount) {
        (bool success, ) = _from.call{value: msg.value - _amount}(new bytes(0));
        require(success, '_transferIn/eth-transfer-failed');
      }
    } else {
      IERC20(_token).safeTransferFrom(_from, address(this), _amount);
    }
  }

  function _transferOut(
    address _token,
    address _to,
    uint _amount
  ) internal {

    if (_token == weth) {
      IWETH(weth).withdraw(_amount);
      (bool success, ) = _to.call{value: _amount}(new bytes(0));
      require(success, '_transferOut/eth-transfer-failed');
    } else {
      IERC20(_token).safeTransfer(_to, _amount);
    }
  }

  function _approve(
    address _token,
    address _spender,
    uint _minAmount
  ) internal {

    uint current = IERC20(_token).allowance(address(this), _spender);
    if (current < _minAmount) {
      if (current != 0) {
        IERC20(_token).safeApprove(_spender, 0);
      }
      IERC20(_token).safeApprove(_spender, type(uint).max);
    }
  }

  function _capRepay(
    address _owner,
    uint _pid,
    uint _amountRepay
  ) internal returns (uint) {

    return Math.min(_amountRepay, IBetaBank(betaBank).fetchPositionDebt(_owner, _pid));
  }

  function recover(address _token, uint _amount) external onlyOwner {

    if (_amount == type(uint).max) {
      _amount = IERC20(_token).balanceOf(address(this));
    }
    IERC20(_token).safeTransfer(msg.sender, _amount);
  }

  function recoverETH(uint _amount) external onlyOwner {

    if (_amount == type(uint).max) {
      _amount = address(this).balance;
    }
    (bool success, ) = msg.sender.call{value: _amount}(new bytes(0));
    require(success, 'recoverETH/eth-transfer-failed');
  }

  function renounceOwnership() public override onlyOwner {

    revert('renounceOwnership/disabled');
  }

  receive() external payable {
    require(msg.sender == weth, 'receive/not-weth');
  }
}


contract BetaRunnerUniswapV3 is BetaRunnerBase, BetaRunnerWithCallback, IUniswapV3SwapCallback {

  using SafeERC20 for IERC20;
  using Path for bytes;
  using SafeCast for uint;

  uint160 internal constant MIN_SQRT_RATIO = 4295128739;
  uint160 internal constant MAX_SQRT_RATIO = 1461446703485210103287273052203988822378723970342;

  address public immutable factory;
  bytes32 public immutable codeHash;

  constructor(
    address _betaBank,
    address _weth,
    address _factory,
    bytes32 _codeHash
  ) BetaRunnerBase(_betaBank, _weth) {
    factory = _factory;
    codeHash = _codeHash;
  }

  struct ShortData {
    uint pid;
    uint amountBorrow;
    uint amountPutExtra;
    bytes path;
    uint amountOutMin;
  }

  struct CloseData {
    uint pid;
    uint amountRepay;
    uint amountTake;
    bytes path;
    uint amountInMax;
  }

  struct CallbackData {
    uint pid;
    address path0;
    uint amount0;
    int memo; // positive if short (extra collateral) | negative if close (amount to take)
    bytes path;
  }

  function short(ShortData calldata _data) external payable onlyEOA withCallback {

    (, address collateral, ) = _data.path.decodeLastPool();
    _transferIn(collateral, msg.sender, _data.amountPutExtra);
    (address tokenIn, address tokenOut, uint24 fee) = _data.path.decodeFirstPool();
    bool zeroForOne = tokenIn < tokenOut;
    CallbackData memory cb = CallbackData({
      pid: _data.pid,
      path0: tokenIn,
      amount0: _data.amountBorrow,
      memo: _data.amountPutExtra.toInt256(),
      path: _data.path
    });
    (int amount0, int amount1) = IUniswapV3Pool(_poolFor(tokenIn, tokenOut, fee)).swap(
      address(this),
      zeroForOne,
      _data.amountBorrow.toInt256(),
      zeroForOne ? MIN_SQRT_RATIO + 1 : MAX_SQRT_RATIO - 1,
      abi.encode(cb)
    );
    uint amountReceived = amount0 > 0 ? uint(-amount1) : uint(-amount0);
    require(amountReceived >= _data.amountOutMin, '!slippage');
  }

  function close(CloseData calldata _data) external payable onlyEOA withCallback {

    uint amountRepay = _capRepay(msg.sender, _data.pid, _data.amountRepay);
    (address tokenOut, address tokenIn, uint24 fee) = _data.path.decodeFirstPool();
    bool zeroForOne = tokenIn < tokenOut;
    CallbackData memory cb = CallbackData({
      pid: _data.pid,
      path0: tokenOut,
      amount0: amountRepay,
      memo: -_data.amountTake.toInt256(),
      path: _data.path
    });
    (int amount0, int amount1) = IUniswapV3Pool(_poolFor(tokenIn, tokenOut, fee)).swap(
      address(this),
      zeroForOne,
      -amountRepay.toInt256(),
      zeroForOne ? MIN_SQRT_RATIO + 1 : MAX_SQRT_RATIO - 1,
      abi.encode(cb)
    );
    uint amountPaid = amount0 > 0 ? uint(amount0) : uint(amount1);
    require(amountPaid <= _data.amountInMax, '!slippage');
  }

  function uniswapV3SwapCallback(
    int _amount0Delta,
    int _amount1Delta,
    bytes calldata _data
  ) external override isCallback {

    CallbackData memory data = abi.decode(_data, (CallbackData));
    (uint amountToPay, uint amountReceived) = _amount0Delta > 0
      ? (uint(_amount0Delta), uint(-_amount1Delta))
      : (uint(_amount1Delta), uint(-_amount0Delta));
    if (data.memo > 0) {
      _shortCallback(amountToPay, amountReceived, data);
    } else {
      _closeCallback(amountToPay, amountReceived, data);
    }
  }

  function _shortCallback(
    uint _amountToPay,
    uint _amountReceived,
    CallbackData memory data
  ) internal {

    (address tokenIn, address tokenOut, uint24 prevFee) = data.path.decodeFirstPool();
    require(msg.sender == _poolFor(tokenIn, tokenOut, prevFee), '_shortCallback/bad-caller');
    if (data.path.hasMultiplePools()) {
      data.path = data.path.skipToken();
      (, address tokenNext, uint24 fee) = data.path.decodeFirstPool();
      bool zeroForOne = tokenOut < tokenNext;
      IUniswapV3Pool(_poolFor(tokenOut, tokenNext, fee)).swap(
        address(this),
        zeroForOne,
        _amountReceived.toInt256(),
        zeroForOne ? MIN_SQRT_RATIO + 1 : MAX_SQRT_RATIO - 1,
        abi.encode(data)
      );
    } else {
      uint amountPut = _amountReceived + uint(data.memo);
      _borrow(tx.origin, data.pid, data.path0, tokenOut, data.amount0, amountPut);
    }
    IERC20(tokenIn).safeTransfer(msg.sender, _amountToPay);
  }

  function _closeCallback(
    uint _amountToPay,
    uint,
    CallbackData memory data
  ) internal {

    (address tokenOut, address tokenIn, uint24 prevFee) = data.path.decodeFirstPool();
    require(msg.sender == _poolFor(tokenIn, tokenOut, prevFee), '_closeCallback/bad-caller');
    if (data.path.hasMultiplePools()) {
      data.path = data.path.skipToken();
      (, address tokenNext, uint24 fee) = data.path.decodeFirstPool();
      bool zeroForOne = tokenNext < tokenIn;
      IUniswapV3Pool(_poolFor(tokenIn, tokenNext, fee)).swap(
        msg.sender,
        zeroForOne,
        -_amountToPay.toInt256(),
        zeroForOne ? MIN_SQRT_RATIO + 1 : MAX_SQRT_RATIO - 1,
        abi.encode(data)
      );
    } else {
      uint amountTake = uint(-data.memo);
      _repay(tx.origin, data.pid, data.path0, tokenIn, data.amount0, amountTake);
      IERC20(tokenIn).safeTransfer(msg.sender, _amountToPay);
      _transferOut(tokenIn, tx.origin, IERC20(tokenIn).balanceOf(address(this)));
    }
  }

  function _poolFor(
    address tokenA,
    address tokenB,
    uint24 fee
  ) internal view returns (address) {

    (address token0, address token1) = tokenA < tokenB ? (tokenA, tokenB) : (tokenB, tokenA);
    bytes32 salt = keccak256(abi.encode(token0, token1, fee));
    return address(uint160(uint(keccak256(abi.encodePacked(hex'ff', factory, salt, codeHash)))));
  }
}