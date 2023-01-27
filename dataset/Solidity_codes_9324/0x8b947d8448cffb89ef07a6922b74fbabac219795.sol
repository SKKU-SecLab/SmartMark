

pragma solidity 0.6.12;
pragma experimental ABIEncoderV2;




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


interface ICurvePool {

  function add_liquidity(uint[2] calldata, uint) external;


  function add_liquidity(uint[3] calldata, uint) external;


  function add_liquidity(uint[4] calldata, uint) external;


  function remove_liquidity(uint, uint[2] calldata) external;


  function remove_liquidity(uint, uint[3] calldata) external;


  function remove_liquidity(uint, uint[4] calldata) external;


  function remove_liquidity_imbalance(uint[2] calldata, uint) external;


  function remove_liquidity_imbalance(uint[3] calldata, uint) external;


  function remove_liquidity_imbalance(uint[4] calldata, uint) external;


  function remove_liquidity_one_coin(
    uint,
    int128,
    uint
  ) external;


  function get_virtual_price() external view returns (uint);

}


interface ICurveRegistry {

  function get_n_coins(address lp) external view returns (uint, uint);


  function pool_list(uint id) external view returns (address);


  function get_coins(address pool) external view returns (address[8] memory);


  function get_gauges(address pool) external view returns (address[10] memory, uint128[10] memory);


  function get_lp_token(address pool) external view returns (address);


  function get_pool_from_lp_token(address lp) external view returns (address);

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


interface IWLiquidityGauge is IERC1155, IERC20Wrapper {

  function mint(
    uint pid,
    uint gid,
    uint amount
  ) external returns (uint id);


  function burn(uint id, uint amount) external returns (uint pid);


  function crv() external returns (IERC20);


  function registry() external returns (ICurveRegistry);


  function encodeId(
    uint,
    uint,
    uint
  ) external pure returns (uint);


  function decodeId(uint id)
    external
    pure
    returns (
      uint,
      uint,
      uint
    );


  function getUnderlyingTokenFromIds(uint pid, uint gid) external view returns (address);

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


contract CurveSpellV1 is WhitelistSpell {

  using SafeMath for uint;
  using HomoraMath for uint;

  ICurveRegistry public immutable registry; // Curve registry
  IWLiquidityGauge public immutable wgauge; // Wrapped liquidity gauge
  address public immutable crv; // CRV token address
  mapping(address => address[]) public ulTokens; // Mapping from LP token address -> underlying token addresses
  mapping(address => address) public poolOf; // Mapping from LP token address to -> pool address

  constructor(
    IBank _bank,
    address _werc20,
    address _weth,
    address _wgauge
  ) public WhitelistSpell(_bank, _werc20, _weth) {
    wgauge = IWLiquidityGauge(_wgauge);
    IWLiquidityGauge(_wgauge).setApprovalForAll(address(_bank), true);
    registry = IWLiquidityGauge(_wgauge).registry();
    crv = address(IWLiquidityGauge(_wgauge).crv());
  }

  function getPool(address lp) public returns (address) {

    address pool = poolOf[lp];
    if (pool == address(0)) {
      require(lp != address(0), 'no lp token');
      pool = registry.get_pool_from_lp_token(lp);
      require(pool != address(0), 'no corresponding pool for lp token');
      poolOf[lp] = pool;
      (uint n, ) = registry.get_n_coins(pool);
      address[8] memory tokens = registry.get_coins(pool);
      ulTokens[lp] = new address[](n);
      for (uint i = 0; i < n; i++) {
        ulTokens[lp][i] = tokens[i];
      }
    }
    return pool;
  }

  function ensureApproveN(address lp, uint n) public {

    require(ulTokens[lp].length == n, 'incorrect pool length');
    address pool = poolOf[lp];
    address[] memory tokens = ulTokens[lp];
    for (uint idx = 0; idx < n; idx++) {
      ensureApprove(tokens[idx], pool);
    }
  }

  function addLiquidity2(
    address lp,
    uint[2] calldata amtsUser,
    uint amtLPUser,
    uint[2] calldata amtsBorrow,
    uint amtLPBorrow,
    uint minLPMint,
    uint pid,
    uint gid
  ) external {

    require(whitelistedLpTokens[lp], 'lp token not whitelisted');
    address pool = getPool(lp);
    require(ulTokens[lp].length == 2, 'incorrect pool length');
    require(wgauge.getUnderlyingTokenFromIds(pid, gid) == lp, 'incorrect underlying');
    address[] memory tokens = ulTokens[lp];

    (, address collToken, uint collId, uint collSize) = bank.getCurrentPositionInfo();
    if (collSize > 0) {
      (uint decodedPid, uint decodedGid, ) = wgauge.decodeId(collId);
      require(decodedPid == pid && decodedGid == gid, 'bad pid or gid');
      require(collToken == address(wgauge), 'collateral token & wgauge mismatched');
      bank.takeCollateral(address(wgauge), collId, collSize);
      wgauge.burn(collId, collSize);
    }

    ensureApproveN(lp, 2);

    for (uint i = 0; i < 2; i++) doTransmit(tokens[i], amtsUser[i]);
    doTransmit(lp, amtLPUser);

    for (uint i = 0; i < 2; i++) doBorrow(tokens[i], amtsBorrow[i]);
    doBorrow(lp, amtLPBorrow);

    uint[2] memory suppliedAmts;
    for (uint i = 0; i < 2; i++) {
      suppliedAmts[i] = IERC20(tokens[i]).balanceOf(address(this));
    }
    if (suppliedAmts[0] > 0 || suppliedAmts[1] > 0) {
      ICurvePool(pool).add_liquidity(suppliedAmts, minLPMint);
    }

    ensureApprove(lp, address(wgauge));
    {
      uint amount = IERC20(lp).balanceOf(address(this));
      uint id = wgauge.mint(pid, gid, amount);
      bank.putCollateral(address(wgauge), id, amount);
    }

    for (uint i = 0; i < 2; i++) doRefund(tokens[i]);

    doRefund(crv);
  }

  function addLiquidity3(
    address lp,
    uint[3] calldata amtsUser,
    uint amtLPUser,
    uint[3] calldata amtsBorrow,
    uint amtLPBorrow,
    uint minLPMint,
    uint pid,
    uint gid
  ) external {

    require(whitelistedLpTokens[lp], 'lp token not whitelisted');
    address pool = getPool(lp);
    require(ulTokens[lp].length == 3, 'incorrect pool length');
    require(wgauge.getUnderlyingTokenFromIds(pid, gid) == lp, 'incorrect underlying');
    address[] memory tokens = ulTokens[lp];

    (, address collToken, uint collId, uint collSize) = bank.getCurrentPositionInfo();
    if (collSize > 0) {
      (uint decodedPid, uint decodedGid, ) = wgauge.decodeId(collId);
      require(decodedPid == pid && decodedGid == gid, 'incorrect coll id');
      require(collToken == address(wgauge), 'collateral token & wgauge mismatched');
      bank.takeCollateral(address(wgauge), collId, collSize);
      wgauge.burn(collId, collSize);
    }

    ensureApproveN(lp, 3);

    for (uint i = 0; i < 3; i++) doTransmit(tokens[i], amtsUser[i]);
    doTransmit(lp, amtLPUser);

    for (uint i = 0; i < 3; i++) doBorrow(tokens[i], amtsBorrow[i]);
    doBorrow(lp, amtLPBorrow);

    uint[3] memory suppliedAmts;
    for (uint i = 0; i < 3; i++) {
      suppliedAmts[i] = IERC20(tokens[i]).balanceOf(address(this));
    }
    if (suppliedAmts[0] > 0 || suppliedAmts[1] > 0 || suppliedAmts[2] > 0) {
      ICurvePool(pool).add_liquidity(suppliedAmts, minLPMint);
    }

    ensureApprove(lp, address(wgauge));
    {
      uint amount = IERC20(lp).balanceOf(address(this));
      uint id = wgauge.mint(pid, gid, amount);
      bank.putCollateral(address(wgauge), id, amount);
    }

    for (uint i = 0; i < 3; i++) doRefund(tokens[i]);

    doRefund(crv);
  }

  function addLiquidity4(
    address lp,
    uint[4] calldata amtsUser,
    uint amtLPUser,
    uint[4] calldata amtsBorrow,
    uint amtLPBorrow,
    uint minLPMint,
    uint pid,
    uint gid
  ) external {

    require(whitelistedLpTokens[lp], 'lp token not whitelisted');
    address pool = getPool(lp);
    require(ulTokens[lp].length == 4, 'incorrect pool length');
    require(wgauge.getUnderlyingTokenFromIds(pid, gid) == lp, 'incorrect underlying');
    address[] memory tokens = ulTokens[lp];

    (, address collToken, uint collId, uint collSize) = bank.getCurrentPositionInfo();
    if (collSize > 0) {
      (uint decodedPid, uint decodedGid, ) = wgauge.decodeId(collId);
      require(decodedPid == pid && decodedGid == gid, 'incorrect coll id');
      require(collToken == address(wgauge), 'collateral token & wgauge mismatched');
      bank.takeCollateral(address(wgauge), collId, collSize);
      wgauge.burn(collId, collSize);
    }

    ensureApproveN(lp, 4);

    for (uint i = 0; i < 4; i++) doTransmit(tokens[i], amtsUser[i]);
    doTransmit(lp, amtLPUser);

    for (uint i = 0; i < 4; i++) doBorrow(tokens[i], amtsBorrow[i]);
    doBorrow(lp, amtLPBorrow);

    uint[4] memory suppliedAmts;
    for (uint i = 0; i < 4; i++) {
      suppliedAmts[i] = IERC20(tokens[i]).balanceOf(address(this));
    }
    if (suppliedAmts[0] > 0 || suppliedAmts[1] > 0 || suppliedAmts[2] > 0 || suppliedAmts[3] > 0) {
      ICurvePool(pool).add_liquidity(suppliedAmts, minLPMint);
    }

    ensureApprove(lp, address(wgauge));
    {
      uint amount = IERC20(lp).balanceOf(address(this));
      uint id = wgauge.mint(pid, gid, amount);
      bank.putCollateral(address(wgauge), id, amount);
    }

    for (uint i = 0; i < 4; i++) doRefund(tokens[i]);

    doRefund(crv);
  }

  function removeLiquidity2(
    address lp,
    uint amtLPTake,
    uint amtLPWithdraw,
    uint[2] calldata amtsRepay,
    uint amtLPRepay,
    uint[2] calldata amtsMin
  ) external {

    require(whitelistedLpTokens[lp], 'lp token not whitelisted');
    address pool = getPool(lp);
    uint positionId = bank.POSITION_ID();
    (, address collToken, uint collId, ) = bank.getPositionInfo(positionId);
    require(IWLiquidityGauge(collToken).getUnderlyingToken(collId) == lp, 'incorrect underlying');
    require(collToken == address(wgauge), 'collateral token & wgauge mismatched');
    address[] memory tokens = ulTokens[lp];

    ensureApproveN(lp, 2);

    uint[2] memory actualAmtsRepay;
    for (uint i = 0; i < 2; i++) {
      actualAmtsRepay[i] = amtsRepay[i] == uint(-1)
        ? bank.borrowBalanceCurrent(positionId, tokens[i])
        : amtsRepay[i];
    }
    uint[2] memory amtsDesired;
    for (uint i = 0; i < 2; i++) {
      amtsDesired[i] = actualAmtsRepay[i].add(amtsMin[i]); // repay amt + slippage control
    }

    bank.takeCollateral(address(wgauge), collId, amtLPTake);
    wgauge.burn(collId, amtLPTake);

    uint amtLPToRemove;
    if (amtsDesired[0] > 0 || amtsDesired[1] > 0) {
      amtLPToRemove = IERC20(lp).balanceOf(address(this)).sub(amtLPWithdraw);
      ICurvePool(pool).remove_liquidity_imbalance(amtsDesired, amtLPToRemove);
    }

    amtLPToRemove = IERC20(lp).balanceOf(address(this)).sub(amtLPWithdraw);
    if (amtLPToRemove > 0) {
      uint[2] memory mins;
      ICurvePool(pool).remove_liquidity(amtLPToRemove, mins);
    }
    for (uint i = 0; i < 2; i++) {
      doRepay(tokens[i], actualAmtsRepay[i]);
    }
    doRepay(lp, amtLPRepay);

    for (uint i = 0; i < 2; i++) {
      doRefund(tokens[i]);
    }
    doRefund(lp);

    doRefund(crv);
  }

  function removeLiquidity3(
    address lp,
    uint amtLPTake,
    uint amtLPWithdraw,
    uint[3] calldata amtsRepay,
    uint amtLPRepay,
    uint[3] calldata amtsMin
  ) external {

    require(whitelistedLpTokens[lp], 'lp token not whitelisted');
    address pool = getPool(lp);
    uint positionId = bank.POSITION_ID();
    (, address collToken, uint collId, ) = bank.getPositionInfo(positionId);
    require(IWLiquidityGauge(collToken).getUnderlyingToken(collId) == lp, 'incorrect underlying');
    require(collToken == address(wgauge), 'collateral token & wgauge mismatched');
    address[] memory tokens = ulTokens[lp];

    ensureApproveN(lp, 3);

    uint[3] memory actualAmtsRepay;
    for (uint i = 0; i < 3; i++) {
      actualAmtsRepay[i] = amtsRepay[i] == uint(-1)
        ? bank.borrowBalanceCurrent(positionId, tokens[i])
        : amtsRepay[i];
    }
    uint[3] memory amtsDesired;
    for (uint i = 0; i < 3; i++) {
      amtsDesired[i] = actualAmtsRepay[i].add(amtsMin[i]); // repay amt + slippage control
    }

    bank.takeCollateral(address(wgauge), collId, amtLPTake);
    wgauge.burn(collId, amtLPTake);

    uint amtLPToRemove;
    if (amtsDesired[0] > 0 || amtsDesired[1] > 0 || amtsDesired[2] > 0) {
      amtLPToRemove = IERC20(lp).balanceOf(address(this)).sub(amtLPWithdraw);
      ICurvePool(pool).remove_liquidity_imbalance(amtsDesired, amtLPToRemove);
    }

    amtLPToRemove = IERC20(lp).balanceOf(address(this)).sub(amtLPWithdraw);
    if (amtLPToRemove > 0) {
      uint[3] memory mins;
      ICurvePool(pool).remove_liquidity(amtLPToRemove, mins);
    }

    for (uint i = 0; i < 3; i++) {
      doRepay(tokens[i], actualAmtsRepay[i]);
    }
    doRepay(lp, amtLPRepay);

    for (uint i = 0; i < 3; i++) {
      doRefund(tokens[i]);
    }
    doRefund(lp);

    doRefund(crv);
  }

  function removeLiquidity4(
    address lp,
    uint amtLPTake,
    uint amtLPWithdraw,
    uint[4] calldata amtsRepay,
    uint amtLPRepay,
    uint[4] calldata amtsMin
  ) external {

    require(whitelistedLpTokens[lp], 'lp token not whitelisted');
    address pool = getPool(lp);
    uint positionId = bank.POSITION_ID();
    (, address collToken, uint collId, ) = bank.getPositionInfo(positionId);
    require(IWLiquidityGauge(collToken).getUnderlyingToken(collId) == lp, 'incorrect underlying');
    require(collToken == address(wgauge), 'collateral token & wgauge mismatched');
    address[] memory tokens = ulTokens[lp];

    ensureApproveN(lp, 4);

    uint[4] memory actualAmtsRepay;
    for (uint i = 0; i < 4; i++) {
      actualAmtsRepay[i] = amtsRepay[i] == uint(-1)
        ? bank.borrowBalanceCurrent(positionId, tokens[i])
        : amtsRepay[i];
    }
    uint[4] memory amtsDesired;
    for (uint i = 0; i < 4; i++) {
      amtsDesired[i] = actualAmtsRepay[i].add(amtsMin[i]); // repay amt + slippage control
    }

    bank.takeCollateral(address(wgauge), collId, amtLPTake);
    wgauge.burn(collId, amtLPTake);

    uint amtLPToRemove;
    if (amtsDesired[0] > 0 || amtsDesired[1] > 0 || amtsDesired[2] > 0 || amtsDesired[3] > 0) {
      amtLPToRemove = IERC20(lp).balanceOf(address(this)).sub(amtLPWithdraw);
      ICurvePool(pool).remove_liquidity_imbalance(amtsDesired, amtLPToRemove);
    }

    amtLPToRemove = IERC20(lp).balanceOf(address(this)).sub(amtLPWithdraw);
    if (amtLPToRemove > 0) {
      uint[4] memory mins;
      ICurvePool(pool).remove_liquidity(amtLPToRemove, mins);
    }

    for (uint i = 0; i < 4; i++) {
      doRepay(tokens[i], actualAmtsRepay[i]);
    }
    doRepay(lp, amtLPRepay);

    for (uint i = 0; i < 4; i++) {
      doRefund(tokens[i]);
    }
    doRefund(lp);

    doRefund(crv);
  }

  function harvest() external {

    (, address collToken, uint collId, uint collSize) = bank.getCurrentPositionInfo();
    (uint pid, uint gid, ) = wgauge.decodeId(collId);
    address lp = wgauge.getUnderlyingToken(collId);
    require(whitelistedLpTokens[lp], 'lp token not whitelisted');
    require(collToken == address(wgauge), 'collateral token & wgauge mismatched');

    bank.takeCollateral(address(wgauge), collId, collSize);
    wgauge.burn(collId, collSize);

    uint amount = IERC20(lp).balanceOf(address(this));
    ensureApprove(lp, address(wgauge));
    uint id = wgauge.mint(pid, gid, amount);
    bank.putCollateral(address(wgauge), id, amount);

    doRefund(crv);
  }
}