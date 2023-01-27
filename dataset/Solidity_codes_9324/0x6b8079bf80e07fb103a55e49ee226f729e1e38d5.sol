

pragma solidity 0.6.12;
pragma experimental ABIEncoderV2;




interface IBalancerPool {

  function getFinalTokens() external view returns (address[] memory);


  function getNormalizedWeight(address token) external view returns (uint);


  function getSwapFee() external view returns (uint);


  function getNumTokens() external view returns (uint);


  function getBalance(address token) external view returns (uint);


  function totalSupply() external view returns (uint);


  function joinPool(uint poolAmountOut, uint[] calldata maxAmountsIn) external;


  function swapExactAmountOut(
    address tokenIn,
    uint maxAmountIn,
    address tokenOut,
    uint tokenAmountOut,
    uint maxPrice
  ) external returns (uint tokenAmountIn, uint spotPriceAfter);


  function joinswapExternAmountIn(
    address tokenIn,
    uint tokenAmountIn,
    uint minPoolAmountOut
  ) external returns (uint poolAmountOut);


  function exitPool(uint poolAmoutnIn, uint[] calldata minAmountsOut) external;


  function exitswapExternAmountOut(
    address tokenOut,
    uint tokenAmountOut,
    uint maxPoolAmountIn
  ) external returns (uint poolAmountIn);

}


interface IBank {

  event AddBank(address token, address cToken);
  event SetOracle(address oracle);
  event SetFeeBps(uint feeBps);
  event WithdrawReserve(address user, address token, uint amount);
  event Borrow(uint positionId, address caller, address token, uint amount, uint share);
  event Repay(uint positionId, address caller, address token, uint amount, uint share);
  event PutCollateral(uint positionId, address caller, address token, uint id, uint amount);
  event TakeCollateral(uint positionId, address caller, address token, uint id, uint amount);
  event Liquidate(
    uint positionId,
    address liquidator,
    address debtToken,
    uint amount,
    uint share,
    uint bounty
  );

  function POSITION_ID() external view returns (uint);


  function SPELL() external view returns (address);


  function EXECUTOR() external view returns (address);


  function getBankInfo(address token)
    external
    view
    returns (
      bool isListed,
      address cToken,
      uint reserve,
      uint totalDebt,
      uint totalShare
    );


  function getPositionInfo(uint positionId)
    external
    view
    returns (
      address owner,
      address collToken,
      uint collId,
      uint collateralSize
    );


  function borrowBalanceStored(uint positionId, address token) external view returns (uint);


  function borrowBalanceCurrent(uint positionId, address token) external returns (uint);


  function borrow(address token, uint amount) external;


  function repay(address token, uint amountCall) external;


  function transmit(address token, uint amount) external;


  function putCollateral(
    address collToken,
    uint collId,
    uint amountCall
  ) external;


  function takeCollateral(
    address collToken,
    uint collId,
    uint amount
  ) external;


  function liquidate(
    uint positionId,
    address debtToken,
    uint amountCall
  ) external;


  function getBorrowETHValue(uint positionId) external view returns (uint);


  function accrue(address token) external;


  function nextPositionId() external view returns (uint);


  function getCurrentPositionInfo()
    external
    view
    returns (
      address owner,
      address collToken,
      uint collId,
      uint collateralSize
    );


  function support(address token) external view returns (bool);


}


interface IERC20Wrapper {

  function getUnderlyingToken(uint id) external view returns (address);


  function getUnderlyingRate(uint id) external view returns (uint);

}


interface IWETH {

  function balanceOf(address user) external returns (uint);


  function approve(address to, uint value) external returns (bool);


  function transfer(address to, uint value) external returns (bool);


  function deposit() external payable;


  function withdraw(uint) external;

}


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
}


interface IERC165 {

    function supportsInterface(bytes4 interfaceId) external view returns (bool);

}


interface IERC20 {

    function totalSupply() external view returns (uint256);


    function balanceOf(address account) external view returns (uint256);


    function transfer(address recipient, uint256 amount) external returns (bool);


    function allowance(address owner, address spender) external view returns (uint256);


    function approve(address spender, uint256 amount) external returns (bool);


    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);


    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}


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
}


library HomoraMath {

  using SafeMath for uint;

  function divCeil(uint lhs, uint rhs) internal pure returns (uint) {

    return lhs.add(rhs).sub(1) / rhs;
  }

  function fmul(uint lhs, uint rhs) internal pure returns (uint) {

    return lhs.mul(rhs) / (2**112);
  }

  function fdiv(uint lhs, uint rhs) internal pure returns (uint) {

    return lhs.mul(2**112) / rhs;
  }

  function sqrt(uint x) internal pure returns (uint) {

    if (x == 0) return 0;
    uint xx = x;
    uint r = 1;

    if (xx >= 0x100000000000000000000000000000000) {
      xx >>= 128;
      r <<= 64;
    }

    if (xx >= 0x10000000000000000) {
      xx >>= 64;
      r <<= 32;
    }
    if (xx >= 0x100000000) {
      xx >>= 32;
      r <<= 16;
    }
    if (xx >= 0x10000) {
      xx >>= 16;
      r <<= 8;
    }
    if (xx >= 0x100) {
      xx >>= 8;
      r <<= 4;
    }
    if (xx >= 0x10) {
      xx >>= 4;
      r <<= 2;
    }
    if (xx >= 0x8) {
      r <<= 1;
    }

    r = (r + x / r) >> 1;
    r = (r + x / r) >> 1;
    r = (r + x / r) >> 1;
    r = (r + x / r) >> 1;
    r = (r + x / r) >> 1;
    r = (r + x / r) >> 1;
    r = (r + x / r) >> 1; // Seven iterations should be enough
    uint r1 = x / r;
    return (r < r1 ? r : r1);
  }
}


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
}


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

}


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

}


abstract contract Initializable {

    bool private _initialized;

    bool private _initializing;

    modifier initializer() {
        require(_initializing || _isConstructor() || !_initialized, "Initializable: contract is already initialized");

        bool isTopLevelCall = !_initializing;
        if (isTopLevelCall) {
            _initializing = true;
            _initialized = true;
        }

        _;

        if (isTopLevelCall) {
            _initializing = false;
        }
    }

    function _isConstructor() private view returns (bool) {
        return !Address.isContract(address(this));
    }
}


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
}


contract Governable is Initializable {

  event SetGovernor(address governor);
  event SetPendingGovernor(address pendingGovernor);
  event AcceptGovernor(address governor);

  address public governor; // The current governor.
  address public pendingGovernor; // The address pending to become the governor once accepted.

  bytes32[64] _gap; // reserve space for upgrade

  modifier onlyGov() {

    require(msg.sender == governor, 'not the governor');
    _;
  }

  function __Governable__init() internal initializer {

    governor = msg.sender;
    pendingGovernor = address(0);
    emit SetGovernor(msg.sender);
  }

  function setPendingGovernor(address _pendingGovernor) external onlyGov {

    pendingGovernor = _pendingGovernor;
    emit SetPendingGovernor(_pendingGovernor);
  }

  function acceptGovernor() external {

    require(msg.sender == pendingGovernor, 'not the pending governor');
    pendingGovernor = address(0);
    governor = msg.sender;
    emit AcceptGovernor(msg.sender);
  }
}


interface IWERC20 is IERC1155, IERC20Wrapper {

  function balanceOfERC20(address token, address user) external view returns (uint);


  function mint(address token, uint amount) external;


  function burn(address token, uint amount) external;

}


interface IWStakingRewards is IERC1155, IERC20Wrapper {

  function mint(uint amount) external returns (uint id);


  function burn(uint id, uint amount) external returns (uint);


  function reward() external returns (address);

}


abstract contract ERC1155Receiver is ERC165, IERC1155Receiver {
    constructor() internal {
        _registerInterface(
            ERC1155Receiver(address(0)).onERC1155Received.selector ^
            ERC1155Receiver(address(0)).onERC1155BatchReceived.selector
        );
    }
}


contract ERC1155NaiveReceiver is ERC1155Receiver {

  bytes32[64] __gap; // reserve space for upgrade

  function onERC1155Received(
    address, /* operator */
    address, /* from */
    uint, /* id */
    uint, /* value */
    bytes calldata /* data */
  ) external override returns (bytes4) {

    return this.onERC1155Received.selector;
  }

  function onERC1155BatchReceived(
    address, /* operator */
    address, /* from */
    uint[] calldata, /* ids */
    uint[] calldata, /* values */
    bytes calldata /* data */
  ) external override returns (bytes4) {

    return this.onERC1155BatchReceived.selector;
  }
}


abstract contract BasicSpell is ERC1155NaiveReceiver {
  using SafeERC20 for IERC20;

  IBank public immutable bank;
  IWERC20 public immutable werc20;
  address public immutable weth;

  mapping(address => mapping(address => bool)) public approved; // Mapping from token to (mapping from spender to approve status)

  constructor(
    IBank _bank,
    address _werc20,
    address _weth
  ) public {
    bank = _bank;
    werc20 = IWERC20(_werc20);
    weth = _weth;
    ensureApprove(_weth, address(_bank));
    IWERC20(_werc20).setApprovalForAll(address(_bank), true);
  }

  function ensureApprove(address token, address spender) internal {
    if (!approved[token][spender]) {
      IERC20(token).safeApprove(spender, uint(-1));
      approved[token][spender] = true;
    }
  }

  function doTransmitETH() internal {
    if (msg.value > 0) {
      IWETH(weth).deposit{value: msg.value}();
    }
  }

  function doTransmit(address token, uint amount) internal {
    if (amount > 0) {
      bank.transmit(token, amount);
    }
  }

  function doRefund(address token) internal {
    uint balance = IERC20(token).balanceOf(address(this));
    if (balance > 0) {
      IERC20(token).safeTransfer(bank.EXECUTOR(), balance);
    }
  }

  function doRefundETH() internal {
    uint balance = IWETH(weth).balanceOf(address(this));
    if (balance > 0) {
      IWETH(weth).withdraw(balance);
      (bool success, ) = bank.EXECUTOR().call{value: balance}(new bytes(0));
      require(success, 'refund ETH failed');
    }
  }

  function doBorrow(address token, uint amount) internal {
    if (amount > 0) {
      bank.borrow(token, amount);
    }
  }

  function doRepay(address token, uint amount) internal {
    if (amount > 0) {
      ensureApprove(token, address(bank));
      bank.repay(token, amount);
    }
  }

  function doPutCollateral(address token, uint amount) internal {
    if (amount > 0) {
      ensureApprove(token, address(werc20));
      werc20.mint(token, amount);
      bank.putCollateral(address(werc20), uint(token), amount);
    }
  }

  function doTakeCollateral(address token, uint amount) internal {
    if (amount > 0) {
      if (amount == uint(-1)) {
        (, , , amount) = bank.getCurrentPositionInfo();
      }
      bank.takeCollateral(address(werc20), uint(token), amount);
      werc20.burn(token, amount);
    }
  }

  receive() external payable {
    require(msg.sender == weth, 'ETH must come from WETH');
  }
}


contract WhitelistSpell is BasicSpell, Governable {

  mapping(address => bool) public whitelistedLpTokens; // mapping from lp token to whitelist status

  constructor(
    IBank _bank,
    address _werc20,
    address _weth
  ) public BasicSpell(_bank, _werc20, _weth) {
    __Governable__init();
  }

  function setWhitelistLPTokens(address[] calldata lpTokens, bool[] calldata statuses)
    external
    onlyGov
  {

    require(lpTokens.length == statuses.length, 'lpTokens & statuses length mismatched');
    for (uint idx = 0; idx < lpTokens.length; idx++) {
      if (statuses[idx]) {
        require(bank.support(lpTokens[idx]), 'oracle not support lp token');
      }
      whitelistedLpTokens[lpTokens[idx]] = statuses[idx];
    }
  }
}


contract BalancerSpellV1 is WhitelistSpell {

  using SafeMath for uint;
  using HomoraMath for uint;

  mapping(address => address[2]) public pairs; // Mapping from lp token to underlying token (only pairs)

  constructor(
    IBank _bank,
    address _werc20,
    address _weth
  ) public WhitelistSpell(_bank, _werc20, _weth) {}

  function getAndApprovePair(address lp) public returns (address, address) {

    address[2] memory ulTokens = pairs[lp];
    if (ulTokens[0] == address(0) || ulTokens[1] == address(0)) {
      address[] memory tokens = IBalancerPool(lp).getFinalTokens();
      require(tokens.length == 2, 'underlying tokens not 2');
      ulTokens[0] = tokens[0];
      ulTokens[1] = tokens[1];
      pairs[lp] = ulTokens;
      ensureApprove(ulTokens[0], lp);
      ensureApprove(ulTokens[1], lp);
    }
    return (ulTokens[0], ulTokens[1]);
  }

  struct Amounts {
    uint amtAUser; // Supplied tokenA amount
    uint amtBUser; // Supplied tokenB amount
    uint amtLPUser; // Supplied LP token amount
    uint amtABorrow; // Borrow tokenA amount
    uint amtBBorrow; // Borrow tokenB amount
    uint amtLPBorrow; // Borrow LP token amount
    uint amtLPDesired; // Desired LP token amount (slippage control)
  }

  function addLiquidityInternal(address lp, Amounts calldata amt) internal returns (uint) {

    require(whitelistedLpTokens[lp], 'lp token not whitelisted');
    (address tokenA, address tokenB) = getAndApprovePair(lp);

    doTransmitETH();
    doTransmit(tokenA, amt.amtAUser);
    doTransmit(tokenB, amt.amtBUser);
    doTransmit(lp, amt.amtLPUser);

    doBorrow(tokenA, amt.amtABorrow);
    doBorrow(tokenB, amt.amtBBorrow);
    doBorrow(lp, amt.amtLPBorrow);

    uint[] memory maxAmountsIn = new uint[](2);
    maxAmountsIn[0] = IERC20(tokenA).balanceOf(address(this));
    maxAmountsIn[1] = IERC20(tokenB).balanceOf(address(this));
    uint totalLPSupply = IBalancerPool(lp).totalSupply();
    uint poolAmountFromA =
      maxAmountsIn[0].mul(1e18).div(IBalancerPool(lp).getBalance(tokenA)).mul(totalLPSupply).div(
        1e18
      ); // compute in reverse order of how Balancer's `joinPool` computes tokenAmountIn
    uint poolAmountFromB =
      maxAmountsIn[1].mul(1e18).div(IBalancerPool(lp).getBalance(tokenB)).mul(totalLPSupply).div(
        1e18
      ); // compute in reverse order of how Balancer's `joinPool` computes tokenAmountIn

    uint poolAmountOut = poolAmountFromA > poolAmountFromB ? poolAmountFromB : poolAmountFromA;
    if (poolAmountOut > 0) IBalancerPool(lp).joinPool(poolAmountOut, maxAmountsIn);

    uint ABal = IERC20(tokenA).balanceOf(address(this));
    uint BBal = IERC20(tokenB).balanceOf(address(this));
    if (ABal > 0) IBalancerPool(lp).joinswapExternAmountIn(tokenA, ABal, 0);
    if (BBal > 0) IBalancerPool(lp).joinswapExternAmountIn(tokenB, BBal, 0);

    uint lpBalance = IERC20(lp).balanceOf(address(this));
    require(lpBalance >= amt.amtLPDesired, 'lp desired not met');

    return lpBalance;
  }

  function addLiquidityWERC20(address lp, Amounts calldata amt) external payable {

    uint lpBalance = addLiquidityInternal(lp, amt);

    doPutCollateral(lp, lpBalance);

    (address tokenA, address tokenB) = getAndApprovePair(lp);
    doRefundETH();
    doRefund(tokenA);
    doRefund(tokenB);
  }

  function addLiquidityWStakingRewards(
    address lp,
    Amounts calldata amt,
    address wstaking
  ) external payable {

    addLiquidityInternal(lp, amt);

    (, address collToken, uint collId, uint collSize) = bank.getCurrentPositionInfo();
    if (collSize > 0) {
      require(IWStakingRewards(collToken).getUnderlyingToken(collId) == lp, 'incorrect underlying');
      require(collToken == wstaking, 'collateral token & wstaking mismatched');
      bank.takeCollateral(wstaking, collId, collSize);
      IWStakingRewards(wstaking).burn(collId, collSize);
    }

    ensureApprove(lp, wstaking);
    uint amount = IERC20(lp).balanceOf(address(this));
    uint id = IWStakingRewards(wstaking).mint(amount);
    if (!IWStakingRewards(wstaking).isApprovedForAll(address(this), address(bank))) {
      IWStakingRewards(wstaking).setApprovalForAll(address(bank), true);
    }
    bank.putCollateral(address(wstaking), id, amount);

    (address tokenA, address tokenB) = getAndApprovePair(lp);
    doRefundETH();
    doRefund(tokenA);
    doRefund(tokenB);

    doRefund(IWStakingRewards(wstaking).reward());
  }

  struct RepayAmounts {
    uint amtLPTake; // Take out LP token amount (from Homora)
    uint amtLPWithdraw; // Withdraw LP token amount (back to caller)
    uint amtARepay; // Repay tokenA amount
    uint amtBRepay; // Repay tokenB amount
    uint amtLPRepay; // Repay LP token amount
    uint amtAMin; // Desired tokenA amount (slippage control)
    uint amtBMin; // Desired tokenB amount (slippage control)
  }

  function removeLiquidityInternal(address lp, RepayAmounts calldata amt) internal {

    require(whitelistedLpTokens[lp], 'lp token not whitelisted');
    (address tokenA, address tokenB) = getAndApprovePair(lp);
    uint amtARepay = amt.amtARepay;
    uint amtBRepay = amt.amtBRepay;
    uint amtLPRepay = amt.amtLPRepay;

    {
      uint positionId = bank.POSITION_ID();
      if (amtARepay == uint(-1)) {
        amtARepay = bank.borrowBalanceCurrent(positionId, tokenA);
      }
      if (amtBRepay == uint(-1)) {
        amtBRepay = bank.borrowBalanceCurrent(positionId, tokenB);
      }
      if (amtLPRepay == uint(-1)) {
        amtLPRepay = bank.borrowBalanceCurrent(positionId, lp);
      }
    }

    uint amtLPToRemove = IERC20(lp).balanceOf(address(this)).sub(amt.amtLPWithdraw);

    if (amtLPToRemove > 0) {
      uint[] memory minAmountsOut = new uint[](2);
      IBalancerPool(lp).exitPool(amtLPToRemove, minAmountsOut);
    }

    uint amtADesired = amtARepay.add(amt.amtAMin);
    uint amtBDesired = amtBRepay.add(amt.amtBMin);

    uint amtA = IERC20(tokenA).balanceOf(address(this));
    uint amtB = IERC20(tokenB).balanceOf(address(this));

    if (amtA < amtADesired && amtB > amtBDesired) {
      IBalancerPool(lp).swapExactAmountOut(
        tokenB,
        amtB.sub(amtBDesired),
        tokenA,
        amtADesired.sub(amtA),
        uint(-1)
      );
    } else if (amtA > amtADesired && amtB < amtBDesired) {
      IBalancerPool(lp).swapExactAmountOut(
        tokenA,
        amtA.sub(amtADesired),
        tokenB,
        amtBDesired.sub(amtB),
        uint(-1)
      );
    }

    doRepay(tokenA, amtARepay);
    doRepay(tokenB, amtBRepay);
    doRepay(lp, amtLPRepay);

    require(IERC20(tokenA).balanceOf(address(this)) >= amt.amtAMin);
    require(IERC20(tokenB).balanceOf(address(this)) >= amt.amtBMin);
    require(IERC20(lp).balanceOf(address(this)) >= amt.amtLPWithdraw);

    doRefundETH();
    doRefund(tokenA);
    doRefund(tokenB);
    doRefund(lp);
  }

  function removeLiquidityWERC20(address lp, RepayAmounts calldata amt) external {

    doTakeCollateral(lp, amt.amtLPTake);

    removeLiquidityInternal(lp, amt);
  }

  function removeLiquidityWStakingRewards(
    address lp,
    RepayAmounts calldata amt,
    address wstaking
  ) external {

    (, address collToken, uint collId, ) = bank.getCurrentPositionInfo();

    require(IWStakingRewards(collToken).getUnderlyingToken(collId) == lp, 'incorrect underlying');
    require(collToken == wstaking, 'collateral token & wstaking mismatched');
    bank.takeCollateral(wstaking, collId, amt.amtLPTake);
    IWStakingRewards(wstaking).burn(collId, amt.amtLPTake);

    removeLiquidityInternal(lp, amt);

    doRefund(IWStakingRewards(wstaking).reward());
  }

  function harvestWStakingRewards(address wstaking) external {

    (, address collToken, uint collId, ) = bank.getCurrentPositionInfo();
    address lp = IWStakingRewards(wstaking).getUnderlyingToken(collId);
    require(whitelistedLpTokens[lp], 'lp token not whitelisted');
    require(collToken == wstaking, 'collateral token & wstaking mismatched');

    bank.takeCollateral(wstaking, collId, uint(-1));
    IWStakingRewards(wstaking).burn(collId, uint(-1));

    uint amount = IERC20(lp).balanceOf(address(this));
    ensureApprove(lp, wstaking);
    uint id = IWStakingRewards(wstaking).mint(amount);
    bank.putCollateral(wstaking, id, amount);

    doRefund(IWStakingRewards(wstaking).reward());
  }
}