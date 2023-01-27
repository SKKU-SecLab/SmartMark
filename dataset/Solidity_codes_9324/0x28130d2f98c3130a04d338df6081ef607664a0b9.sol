

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


interface IPancakeCallee {

  function pancakeCall(
    address sender,
    uint amount0,
    uint amount1,
    bytes calldata data
  ) external;

}


interface IUniswapV2Callee {

  function uniswapV2Call(
    address sender,
    uint amount0,
    uint amount1,
    bytes calldata data
  ) external;

}


interface IUniswapV2Pair {

  function getReserves()
    external
    view
    returns (
      uint112 reserve0,
      uint112 reserve1,
      uint32 blockTimestampLast
    );


  function price0CumulativeLast() external view returns (uint);


  function price1CumulativeLast() external view returns (uint);


  function swap(
    uint amount0Out,
    uint amount1Out,
    address to,
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


contract BetaRunnerUniswapV2 is
  BetaRunnerBase,
  BetaRunnerWithCallback,
  IUniswapV2Callee,
  IPancakeCallee
{

  using SafeCast for uint;
  using SafeERC20 for IERC20;

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

  struct CallbackData {
    uint pid;
    int memo; // positive if short (extra collateral) | negative if close (amount to take)
    address[] path;
    uint[] amounts;
  }

  function short(
    uint _pid,
    uint _amountBorrow,
    uint _amountPutExtra,
    address[] memory _path,
    uint _amountOutMin
  ) external payable onlyEOA withCallback {

    _transferIn(_path[_path.length - 1], msg.sender, _amountPutExtra);
    uint[] memory amounts = _getAmountsOut(_amountBorrow, _path);
    require(amounts[amounts.length - 1] >= _amountOutMin, 'short/not-enough-out');
    IUniswapV2Pair(_pairFor(_path[0], _path[1])).swap(
      _path[0] < _path[1] ? 0 : amounts[1],
      _path[0] < _path[1] ? amounts[1] : 0,
      address(this),
      abi.encode(
        CallbackData({pid: _pid, memo: _amountPutExtra.toInt256(), path: _path, amounts: amounts})
      )
    );
  }

  function close(
    uint _pid,
    uint _amountRepay,
    uint _amountTake,
    address[] memory _path,
    uint _amountInMax
  ) external payable onlyEOA withCallback {

    _amountRepay = _capRepay(msg.sender, _pid, _amountRepay);
    uint[] memory amounts = _getAmountsIn(_amountRepay, _path);
    require(amounts[0] <= _amountInMax, 'close/too-much-in');
    IUniswapV2Pair(_pairFor(_path[0], _path[1])).swap(
      _path[0] < _path[1] ? 0 : amounts[1],
      _path[0] < _path[1] ? amounts[1] : 0,
      address(this),
      abi.encode(
        CallbackData({pid: _pid, memo: -_amountTake.toInt256(), path: _path, amounts: amounts})
      )
    );
  }

  function uniswapV2Call(
    address sender,
    uint,
    uint,
    bytes calldata data
  ) external override isCallback {

    require(sender == address(this), 'uniswapV2Call/bad-sender');
    _pairCallback(data);
  }

  function pancakeCall(
    address sender,
    uint,
    uint,
    bytes calldata data
  ) external override isCallback {

    require(sender == address(this), 'pancakeCall/bad-sender');
    _pairCallback(data);
  }

  function _pairCallback(bytes calldata data) internal {

    CallbackData memory cb = abi.decode(data, (CallbackData));
    require(msg.sender == _pairFor(cb.path[0], cb.path[1]), '_pairCallback/bad-caller');
    uint len = cb.path.length;
    if (len > 2) {
      address pair = _pairFor(cb.path[1], cb.path[2]);
      IERC20(cb.path[1]).safeTransfer(pair, cb.amounts[1]);
      for (uint idx = 1; idx < len - 1; idx++) {
        (address input, address output) = (cb.path[idx], cb.path[idx + 1]);
        address to = idx < len - 2 ? _pairFor(output, cb.path[idx + 2]) : address(this);
        uint amount0Out = input < output ? 0 : cb.amounts[idx + 1];
        uint amount1Out = input < output ? cb.amounts[idx + 1] : 0;
        IUniswapV2Pair(pair).swap(amount0Out, amount1Out, to, new bytes(0));
        pair = to;
      }
    }
    if (cb.memo > 0) {
      uint amountCollateral = uint(cb.memo);
      (address und, address col) = (cb.path[0], cb.path[len - 1]);
      _borrow(tx.origin, cb.pid, und, col, cb.amounts[0], cb.amounts[len - 1] + amountCollateral);
      IERC20(und).safeTransfer(msg.sender, cb.amounts[0]);
    } else {
      uint amountTake = uint(-cb.memo);
      (address und, address col) = (cb.path[len - 1], cb.path[0]);
      _repay(tx.origin, cb.pid, und, col, cb.amounts[len - 1], amountTake);
      IERC20(col).safeTransfer(msg.sender, cb.amounts[0]);
      _transferOut(col, tx.origin, IERC20(col).balanceOf(address(this)));
    }
  }

  function _sortTokens(address tokenA, address tokenB)
    internal
    pure
    returns (address token0, address token1)
  {

    require(tokenA != tokenB, 'IDENTICAL_ADDRESSES');
    (token0, token1) = tokenA < tokenB ? (tokenA, tokenB) : (tokenB, tokenA);
    require(token0 != address(0), 'ZERO_ADDRESS');
  }

  function _pairFor(address tokenA, address tokenB) internal view returns (address) {

    (address token0, address token1) = _sortTokens(tokenA, tokenB);
    bytes32 salt = keccak256(abi.encodePacked(token0, token1));
    return address(uint160(uint(keccak256(abi.encodePacked(hex'ff', factory, salt, codeHash)))));
  }

  function _getReserves(address tokenA, address tokenB)
    internal
    view
    returns (uint reserveA, uint reserveB)
  {

    (address token0, ) = _sortTokens(tokenA, tokenB);
    (uint reserve0, uint reserve1, ) = IUniswapV2Pair(_pairFor(tokenA, tokenB)).getReserves();
    (reserveA, reserveB) = tokenA == token0 ? (reserve0, reserve1) : (reserve1, reserve0);
  }

  function _getAmountOut(
    uint amountIn,
    uint reserveIn,
    uint reserveOut
  ) internal pure returns (uint amountOut) {

    require(amountIn > 0, 'INSUFFICIENT_INPUT_AMOUNT');
    require(reserveIn > 0 && reserveOut > 0, 'INSUFFICIENT_LIQUIDITY');
    uint amountInWithFee = amountIn * 997;
    uint numerator = amountInWithFee * reserveOut;
    uint denominator = (reserveIn * 1000) + amountInWithFee;
    amountOut = numerator / denominator;
  }

  function _getAmountIn(
    uint amountOut,
    uint reserveIn,
    uint reserveOut
  ) internal pure returns (uint amountIn) {

    require(amountOut > 0, 'INSUFFICIENT_OUTPUT_AMOUNT');
    require(reserveIn > 0 && reserveOut > 0, 'INSUFFICIENT_LIQUIDITY');
    uint numerator = reserveIn * amountOut * 1000;
    uint denominator = (reserveOut - amountOut) * 997;
    amountIn = (numerator / denominator) + 1;
  }

  function _getAmountsOut(uint amountIn, address[] memory path)
    internal
    view
    returns (uint[] memory amounts)
  {

    require(path.length >= 2, 'INVALID_PATH');
    amounts = new uint[](path.length);
    amounts[0] = amountIn;
    for (uint i; i < path.length - 1; i++) {
      (uint reserveIn, uint reserveOut) = _getReserves(path[i], path[i + 1]);
      amounts[i + 1] = _getAmountOut(amounts[i], reserveIn, reserveOut);
    }
  }

  function _getAmountsIn(uint amountOut, address[] memory path)
    internal
    view
    returns (uint[] memory amounts)
  {

    require(path.length >= 2, 'INVALID_PATH');
    amounts = new uint[](path.length);
    amounts[amounts.length - 1] = amountOut;
    for (uint i = path.length - 1; i > 0; i--) {
      (uint reserveIn, uint reserveOut) = _getReserves(path[i - 1], path[i]);
      amounts[i - 1] = _getAmountIn(amounts[i], reserveIn, reserveOut);
    }
  }
}