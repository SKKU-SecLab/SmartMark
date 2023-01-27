
pragma solidity 0.6.11; 
pragma experimental ABIEncoderV2;





abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }
    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}



contract Ownable is Context {

    address private _owner;
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    constructor () internal {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }
    function owner() public view returns (address) {

        return _owner;
    }
    modifier onlyOwner() {

        require(_owner == _msgSender(), "Ownable: caller is not the owner");
        _;
    }
    function renounceOwnership() public virtual onlyOwner {

        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }
    function transferOwnership(address newOwner) public virtual onlyOwner {

        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}


library SafeMath {

    function add(uint256 a, uint256 b) internal pure returns (uint256) {

        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");
        return c;
    }
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {

        return sub(a, b, "SafeMath: subtraction overflow");
    }
    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        require(b <= a, errorMessage);
        uint256 c = a - b;
        return c;
    }
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {

        if (a == 0) {
            return 0;
        }
        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");
        return c;
    }
    function div(uint256 a, uint256 b) internal pure returns (uint256) {

        return div(a, b, "SafeMath: division by zero");
    }
    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        require(b > 0, errorMessage);
        uint256 c = a / b;
        return c;
    }
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {

        return mod(a, b, "SafeMath: modulo by zero");
    }
    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        require(b != 0, errorMessage);
        return a % b;
    }
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

        return _functionCallWithValue(target, data, 0, errorMessage);
    }
    function functionCallWithValue(address target, bytes memory data, uint256 value) internal returns (bytes memory) {

        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }
    function functionCallWithValue(address target, bytes memory data, uint256 value, string memory errorMessage) internal returns (bytes memory) {

        require(address(this).balance >= value, "Address: insufficient balance for call");
        return _functionCallWithValue(target, data, value, errorMessage);
    }
    function _functionCallWithValue(address target, bytes memory data, uint256 weiValue, string memory errorMessage) private returns (bytes memory) {

        require(isContract(target), "Address: call to non-contract");
        (bool success, bytes memory returndata) = target.call{ value: weiValue }(data);
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


library EnumerableSet {

    struct Set {
        bytes32[] _values;
        mapping (bytes32 => uint256) _indexes;
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
        if (valueIndex != 0) { // Equivalent to contains(set, value)
            uint256 toDeleteIndex = valueIndex - 1;
            uint256 lastIndex = set._values.length - 1;
            bytes32 lastvalue = set._values[lastIndex];
            set._values[toDeleteIndex] = lastvalue;
            set._indexes[lastvalue] = toDeleteIndex + 1; // All indexes are 1-based
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

        require(set._values.length > index, "EnumerableSet: index out of bounds");
        return set._values[index];
    }
    struct AddressSet {
        Set _inner;
    }
    function add(AddressSet storage set, address value) internal returns (bool) {

        return _add(set._inner, bytes32(uint256(value)));
    }
    function remove(AddressSet storage set, address value) internal returns (bool) {

        return _remove(set._inner, bytes32(uint256(value)));
    }
    function contains(AddressSet storage set, address value) internal view returns (bool) {

        return _contains(set._inner, bytes32(uint256(value)));
    }
    function length(AddressSet storage set) internal view returns (uint256) {

        return _length(set._inner);
    }
    function at(AddressSet storage set, uint256 index) internal view returns (address) {

        return address(uint256(_at(set._inner, index)));
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
}





abstract contract AccessControl is Context {
    using EnumerableSet for EnumerableSet.AddressSet;
    using Address for address;
    struct RoleData {
        EnumerableSet.AddressSet members;
        bytes32 adminRole;
    }
    mapping (bytes32 => RoleData) private _roles;
    bytes32 public constant DEFAULT_ADMIN_ROLE = 0x00;
    event RoleAdminChanged(bytes32 indexed role, bytes32 indexed previousAdminRole, bytes32 indexed newAdminRole);
    event RoleGranted(bytes32 indexed role, address indexed account, address indexed sender);
    event RoleRevoked(bytes32 indexed role, address indexed account, address indexed sender);
    function hasRole(bytes32 role, address account) public view returns (bool) {
        return _roles[role].members.contains(account);
    }
    function getRoleMemberCount(bytes32 role) public view returns (uint256) {
        return _roles[role].members.length();
    }
    function getRoleMember(bytes32 role, uint256 index) public view returns (address) {
        return _roles[role].members.at(index);
    }
    function getRoleAdmin(bytes32 role) public view returns (bytes32) {
        return _roles[role].adminRole;
    }
    function grantRole(bytes32 role, address account) public virtual {
        require(hasRole(_roles[role].adminRole, _msgSender()), "AccessControl: sender must be an admin to grant");
        _grantRole(role, account);
    }
    function revokeRole(bytes32 role, address account) public virtual {
        require(hasRole(_roles[role].adminRole, _msgSender()), "AccessControl: sender must be an admin to revoke");
        _revokeRole(role, account);
    }
    function renounceRole(bytes32 role, address account) public virtual {
        require(account == _msgSender(), "AccessControl: can only renounce roles for self");
        _revokeRole(role, account);
    }
    function _setupRole(bytes32 role, address account) internal virtual {
        _grantRole(role, account);
    }
    function _setRoleAdmin(bytes32 role, bytes32 adminRole) internal virtual {
        emit RoleAdminChanged(role, _roles[role].adminRole, adminRole);
        _roles[role].adminRole = adminRole;
    }
    function _grantRole(bytes32 role, address account) private {
        if (_roles[role].members.add(account)) {
            emit RoleGranted(role, account, _msgSender());
        }
    }
    function _revokeRole(bytes32 role, address account) private {
        if (_roles[role].members.remove(account)) {
            emit RoleRevoked(role, account, _msgSender());
        }
    }
}




interface IShareToken is IERC20 {  

    function pool_mint(address m_address, uint256 m_amount) external; 

    function pool_burn_from(address b_address, uint256 b_amount) external; 

    function burn(uint256 amount) external;

}


interface IUniswapPairOracle { 

    function getPairToken(address token) external view returns(address);

    function containsToken(address token) external view returns(bool);

    function getSwapTokenReserve(address token) external view returns(uint256);

    function update() external returns(bool);

    function consult(address token, uint amountIn) external view returns (uint amountOut);

}



interface IUSEStablecoin {

    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount) external returns (bool);

    function allowance(address owner, address spender) external view returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

    function owner_address() external returns (address);

    function creator_address() external returns (address);

    function timelock_address() external returns (address); 

    function genesis_supply() external returns (uint256); 

    function refresh_cooldown() external returns (uint256);

    function price_target() external returns (uint256);

    function price_band() external returns (uint256);

    function DEFAULT_ADMIN_ADDRESS() external returns (address);

    function COLLATERAL_RATIO_PAUSER() external returns (bytes32);

    function collateral_ratio_paused() external returns (bool);

    function last_call_time() external returns (uint256);

    function USEDAIOracle() external returns (IUniswapPairOracle);

    function USESharesOracle() external returns (IUniswapPairOracle); 

    function use_pools(address a) external view returns (bool);

    function global_collateral_ratio() external view returns (uint256);

    function use_price() external view returns (uint256);

    function share_price()  external view returns (uint256);

    function share_price_in_use()  external view returns (uint256); 

    function globalCollateralValue() external view returns (uint256);

    function refreshCollateralRatio() external;

    function swapCollateralAmount() external view returns(uint256);

    function pool_mint(address m_address, uint256 m_amount) external;

    function pool_burn_from(address b_address, uint256 b_amount) external;

    function burn(uint256 amount) external;

}


interface IUSEPool { 

    function collatDollarBalance() external view returns (uint256); 

}


interface IUniswapV2Pair {

    event Approval(address indexed owner, address indexed spender, uint value);
    event Transfer(address indexed from, address indexed to, uint value);
    function name() external pure returns (string memory);

    function symbol() external pure returns (string memory);

    function decimals() external pure returns (uint8);

    function totalSupply() external view returns (uint);

    function balanceOf(address owner) external view returns (uint);

    function allowance(address owner, address spender) external view returns (uint);

    function approve(address spender, uint value) external returns (bool);

    function transfer(address to, uint value) external returns (bool);

    function transferFrom(address from, address to, uint value) external returns (bool);

    function DOMAIN_SEPARATOR() external view returns (bytes32);

    function PERMIT_TYPEHASH() external pure returns (bytes32);

    function nonces(address owner) external view returns (uint);

    function permit(address owner, address spender, uint value, uint deadline, uint8 v, bytes32 r, bytes32 s) external;

    event Mint(address indexed sender, uint amount0, uint amount1);
    event Burn(address indexed sender, uint amount0, uint amount1, address indexed to);
    event Swap(
        address indexed sender,
        uint amount0In,
        uint amount1In,
        uint amount0Out,
        uint amount1Out,
        address indexed to
    );
    event Sync(uint112 reserve0, uint112 reserve1);
    function MINIMUM_LIQUIDITY() external pure returns (uint);

    function factory() external view returns (address);

    function token0() external view returns (address);

    function token1() external view returns (address);

    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);

    function price0CumulativeLast() external view returns (uint);

    function price1CumulativeLast() external view returns (uint);

    function kLast() external view returns (uint);

    function mint(address to) external returns (uint liquidity);

    function burn(address to) external returns (uint amount0, uint amount1);

    function swap(uint amount0Out, uint amount1Out, address to, bytes calldata data) external;

    function skim(address to) external;

    function sync() external;

    function initialize(address, address) external;

}


interface IUniswapV2Factory {

    event PairCreated(address indexed token0, address indexed token1, address pair, uint);
    function feeTo() external view returns (address);

    function feeToSetter() external view returns (address);

    function getPair(address tokenA, address tokenB) external view returns (address pair);

    function allPairs(uint) external view returns (address pair);

    function allPairsLength() external view returns (uint);

    function createPair(address tokenA, address tokenB) external returns (address pair);

    function setFeeTo(address) external;

    function setFeeToSetter(address) external;

}


interface IUniswapV2Router01 {

    function factory() external pure returns (address);

    function WETH() external pure returns (address);

    function addLiquidity(
        address tokenA,
        address tokenB,
        uint amountADesired,
        uint amountBDesired,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB, uint liquidity);

    function addLiquidityETH(
        address token,
        uint amountTokenDesired,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external payable returns (uint amountToken, uint amountETH, uint liquidity);

    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB);

    function removeLiquidityETH(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external returns (uint amountToken, uint amountETH);

    function removeLiquidityWithPermit(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountA, uint amountB);

    function removeLiquidityETHWithPermit(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountToken, uint amountETH);

    function swapExactTokensForTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);

    function swapTokensForExactTokens(
        uint amountOut,
        uint amountInMax,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);

    function swapExactETHForTokens(uint amountOutMin, address[] calldata path, address to, uint deadline)
        external
        payable
        returns (uint[] memory amounts);

    function swapTokensForExactETH(uint amountOut, uint amountInMax, address[] calldata path, address to, uint deadline)
        external
        returns (uint[] memory amounts);

    function swapExactTokensForETH(uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline)
        external
        returns (uint[] memory amounts);

    function swapETHForExactTokens(uint amountOut, address[] calldata path, address to, uint deadline)
        external
        payable
        returns (uint[] memory amounts);

    function quote(uint amountA, uint reserveA, uint reserveB) external pure returns (uint amountB);

    function getAmountOut(uint amountIn, uint reserveIn, uint reserveOut) external pure returns (uint amountOut);

    function getAmountIn(uint amountOut, uint reserveIn, uint reserveOut) external pure returns (uint amountIn);

    function getAmountsOut(uint amountIn, address[] calldata path) external view returns (uint[] memory amounts);

    function getAmountsIn(uint amountOut, address[] calldata path) external view returns (uint[] memory amounts);

}



abstract contract ProtocolValue  { 
    using SafeMath for uint256;
    using SafeERC20 for IERC20;
    uint256 public constant PERCENT = 1e6;  
    struct PCVInfo{
        uint256 targetTokenRemoved;
        uint256 otherTokenRemoved;
        uint256 liquidityRemoved;
        uint256 otherTokenIn;
        uint256 targetTokenOut;
        uint256 targetTokenAdded;
        uint256 otherTokenAdded;
        uint256 liquidityAdded; 
        uint256 targetTokenRemain;       
    }
    event PCVResult(address targetToken,address otherToken,uint256 lpp,uint256 cp,PCVInfo pcv);
    function _getPair(address router,address token0,address token1) internal view returns(address){
        address _factory =  IUniswapV2Router01(router).factory();
        return IUniswapV2Factory(_factory).getPair(token0,token1);
    }
    function _checkOrApproveRouter(address _router,address _token,uint256 _amount) internal{
        if(IERC20(_token).allowance(address(this),_router) < _amount){
            IERC20(_token).safeApprove(_router,0);
            IERC20(_token).safeApprove(_router,uint256(-1));
        }        
    }
    function _swapToken(address router,address tokenIn,address tokenOut,uint256 amountIn) internal returns (uint256){
        address[] memory path = new address[](2);
        path[0] = tokenIn;
        path[1] = tokenOut; 
        uint256 exptime = block.timestamp+60;
        _checkOrApproveRouter(router,tokenIn,amountIn); 
        return IUniswapV2Router01(router).swapExactTokensForTokens(amountIn,0,path,address(this),exptime)[1];
    }
    function _addLiquidity(
        address router,
        address tokenA,
        address tokenB,
        uint amountADesired,
        uint amountBDesired,
        uint amountAMin,
        uint amountBMin
    ) internal returns (uint amountA, uint amountB, uint liquidity){
         uint256 exptime = block.timestamp+60;
        _checkOrApproveRouter(router,tokenA,amountADesired);
        _checkOrApproveRouter(router,tokenB,amountBDesired);
        return IUniswapV2Router01(router).addLiquidity(tokenA,tokenB,amountADesired,amountBDesired,amountAMin,amountBMin,address(this), exptime);
    }
    function _removeLiquidity(
        address router,
        address pair,
        address tokenA,
        address tokenB,
        uint256 lpp 
    ) internal returns (uint amountA, uint amountB,uint256 liquidity){
        uint256 exptime = block.timestamp+60;
        liquidity = IERC20(pair).balanceOf(address(this)).mul(lpp).div(PERCENT);
        _checkOrApproveRouter(router,pair,liquidity);
        (amountA, amountB) = IUniswapV2Router01(router).removeLiquidity(tokenA,tokenB,liquidity,0,0,address(this),exptime);
    }
    function getOtherToken(address _pair,address _targetToken) public view returns(address){
        address token0 = IUniswapV2Pair(_pair).token0();
        address token1 = IUniswapV2Pair(_pair).token1(); 
        require(token0 == _targetToken || token1 == _targetToken,"!_targetToken");
        return _targetToken == token0 ? token1 : token0;
    } 
    function _protocolValue(address _router,address _pair,address _targetToken,uint256 _lpp,uint256 _cp) internal returns(uint256){
        address otherToken = getOtherToken(_pair,_targetToken); 
        PCVInfo memory pcv =  PCVInfo(0,0,0,0,0,0,0,0,0);
        (pcv.targetTokenRemoved,pcv.otherTokenRemoved,pcv.liquidityRemoved) = _removeLiquidity(_router,_pair,_targetToken,otherToken,_lpp);
        pcv.otherTokenIn = pcv.otherTokenRemoved.mul(_cp).div(PERCENT);
        pcv.targetTokenOut = _swapToken(_router,otherToken,_targetToken,pcv.otherTokenIn);
        uint256 otherTokenRemain  = (pcv.otherTokenRemoved).sub((pcv.otherTokenIn));
        uint256 targetTokenAmount = (pcv.targetTokenRemoved).add(pcv.targetTokenOut);        
        (pcv.targetTokenAdded, pcv.otherTokenAdded, pcv.liquidityAdded) = _addLiquidity(_router,
                                                                                        _targetToken,otherToken,
                                                                                        targetTokenAmount,otherTokenRemain,
                                                                                        0,otherTokenRemain);
        pcv.targetTokenRemain = targetTokenAmount.sub(pcv.targetTokenAdded);
        emit PCVResult(_targetToken,otherToken,_lpp,_cp,pcv);
        return pcv.targetTokenRemain;  
    }
}


contract USEMasterChefPool is IUSEPool,AccessControl,ProtocolValue {

    using SafeMath for uint256;
    using SafeERC20 for IERC20;
    struct UserInfo {
        uint256 amount; // How many LP tokens the user has provided.
        uint256 rewardDebt; // Reward debt. See explanation below.
    }
    struct PoolInfo {
        IERC20 lpToken; // Address of LP token contract.
        uint256 allocPoint; // How many allocation points assigned to this pool. rewardTokens to distribute per block.
        uint256 lastRewardBlock; // Last block number that rewardTokens distribution occurs.
        uint256 accrewardTokenPerShare; // Accumulated rewardTokens per share, times 1e12. See below.
    }
    uint256 public constant PRECISION = 1e6;
    bytes32 public constant COMMUNITY_MASTER = keccak256("COMMUNITY_MASTER");
    bytes32 public constant COMMUNITY_MASTER_PCV = keccak256("COMMUNITY_MASTER_PCV");
    IShareToken public rewardToken;
    address public swapRouter;
    address public communityaddr;
    uint256 public communityRateAmount; 
    uint256 public rewardTokenPerBlock; 
    PoolInfo[] public poolInfo;
    mapping(uint256 => mapping(address => UserInfo)) public userInfo;
    uint256 public totalAllocPoint = 0;
    uint256 public startBlock;
    uint256 public miningEndBlock;
    event Deposit(address indexed user, uint256 indexed pid, uint256 amount,uint256 rewardToken);
    event Withdraw(address indexed user, uint256 indexed pid, uint256 amount,uint256 rewardToken);
    event EmergencyWithdraw(
        address indexed user,
        uint256 indexed pid,
        uint256 amount
    );
    constructor(
        address _rewardToken,
        address _communityaddr,
        address _swapRouter,
        uint256 _rewardTokenPerBlock,
        uint256 _startBlock,
        uint256 _miningEndBlock
    ) public {
        rewardToken =IShareToken(_rewardToken);
        communityaddr = _communityaddr;
        swapRouter = _swapRouter;
        rewardTokenPerBlock = _rewardTokenPerBlock; 
        startBlock = _startBlock;
        miningEndBlock = _miningEndBlock;
        _setupRole(DEFAULT_ADMIN_ROLE, _msgSender());
        grantRole(COMMUNITY_MASTER, _communityaddr);
        grantRole(COMMUNITY_MASTER_PCV, _communityaddr);        
    }
    modifier onlyAdmin(){

         require(hasRole(DEFAULT_ADMIN_ROLE, msg.sender));
         _;
    }
    modifier onlyPCVMaster(){

         require(hasRole(COMMUNITY_MASTER_PCV, msg.sender));
         _;
    }
    function collatDollarBalance() external view override returns (uint256){

         return 0;
     }
    function poolLength() external view returns (uint256) {

        return poolInfo.length;
    }
    function add(uint256 _allocPoint, IERC20 _lpToken, bool _withUpdate) public onlyAdmin {

        if (_withUpdate) {
            massUpdatePools();
        }
        uint256 lastRewardBlock =  block.number > startBlock ? block.number : startBlock;
        totalAllocPoint = totalAllocPoint.add(_allocPoint);
        poolInfo.push(
            PoolInfo({
                lpToken: _lpToken,
                allocPoint: _allocPoint,
                lastRewardBlock: lastRewardBlock,
                accrewardTokenPerShare: 0
            })
        );
    }
    function set(uint256 _pid,uint256 _allocPoint, bool _withUpdate) public onlyAdmin {

        if (_withUpdate) {
            massUpdatePools();
        }
        totalAllocPoint = totalAllocPoint.sub(poolInfo[_pid].allocPoint).add(
            _allocPoint
        );
        poolInfo[_pid].allocPoint = _allocPoint;
    }
    function getMultiplier(uint256 _from, uint256 _to) public pure returns (uint256){

        return _to.sub(_from);
    }
    function pendingrewardToken(uint256 _pid, address _user)external view returns (uint256){

        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][_user];
        uint256 accrewardTokenPerShare = pool.accrewardTokenPerShare;
        uint256 lpSupply = pool.lpToken.balanceOf(address(this));
        if (block.number > pool.lastRewardBlock && lpSupply != 0) {
            uint256 multiplier =
                getMultiplier(pool.lastRewardBlock, block.number);
            uint256 rewardTokenReward =
                multiplier.mul(rewardTokenPerBlock).mul(pool.allocPoint).div(
                    totalAllocPoint
                );
            accrewardTokenPerShare = accrewardTokenPerShare.add(
                rewardTokenReward.mul(1e12).div(lpSupply)
            );
        }
        return user.amount.mul(accrewardTokenPerShare).div(1e12).sub(user.rewardDebt);
    }
    function massUpdatePools() public {

        uint256 length = poolInfo.length;
        for (uint256 pid = 0; pid < length; ++pid) {
            updatePool(pid);
        }
    }
    function updatePool(uint256 _pid) public {

        PoolInfo storage pool = poolInfo[_pid];
        if (block.number <= pool.lastRewardBlock) {
            return;
        }
        uint256 lpSupply = pool.lpToken.balanceOf(address(this));
        if (lpSupply == 0) {
            pool.lastRewardBlock = block.number;
            return;
        }
        uint256 multiplier = getMultiplier(pool.lastRewardBlock, block.number);
        uint256 rewardTokenReward = multiplier.mul(rewardTokenPerBlock).mul(pool.allocPoint).div(totalAllocPoint);
        communityRateAmount = communityRateAmount.add(rewardTokenReward.div(5));
        rewardToken.pool_mint(address(this), rewardTokenReward);
        pool.accrewardTokenPerShare = pool.accrewardTokenPerShare.add(
            rewardTokenReward.mul(1e12).div(lpSupply)
        );
        pool.lastRewardBlock = block.number;
    }
    function deposit(uint256 _pid, uint256 _amount) public {

        uint256 pending = 0;
        require(block.number > startBlock,"!!!start");
        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][msg.sender];
        updatePool(_pid);
        if (user.amount > 0) {
            pending = user.amount.mul(pool.accrewardTokenPerShare).div(1e12).sub(user.rewardDebt);
            safeRewardTokenTransfer(msg.sender, pending);
        }
        if(_amount > 0){
            pool.lpToken.safeTransferFrom(address(msg.sender), address(this), _amount);
            user.amount = user.amount.add(_amount);
        }
        user.rewardDebt = user.amount.mul(pool.accrewardTokenPerShare).div(1e12);
        emit Deposit(msg.sender, _pid, _amount,pending);
    }
    function withdraw(uint256 _pid, uint256 _amount) public {

        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][msg.sender];
        require(user.amount >= _amount, "withdraw: not good");
        updatePool(_pid);
        uint256 pending = user.amount.mul(pool.accrewardTokenPerShare).div(1e12).sub(user.rewardDebt);
        safeRewardTokenTransfer(msg.sender, pending);
        user.amount = user.amount.sub(_amount);
        user.rewardDebt = user.amount.mul(pool.accrewardTokenPerShare).div(1e12);
        pool.lpToken.safeTransfer(address(msg.sender), _amount);
        emit Withdraw(msg.sender, _pid, _amount,pending);
    }
    function claimReward(uint256 _pid) public {

        deposit(_pid,0);
    }
    function protocolValueForUSE(address _pair,address _use,uint256 _lpp,uint256 _cp) public onlyPCVMaster{

        require(block.number >= miningEndBlock,"pcv: only start after mining");
        uint256 _useRemain =  _protocolValue(swapRouter,_pair,_use,_lpp,_cp);
        IUSEStablecoin(_use).burn(_useRemain); 
    }
    function emergencyWithdraw(uint256 _pid) public {

        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][msg.sender];
        pool.lpToken.safeTransfer(address(msg.sender), user.amount);
        emit EmergencyWithdraw(msg.sender, _pid, user.amount);
        user.amount = 0;
        user.rewardDebt = 0;
    }
    function safeRewardTokenTransfer(address _to, uint256 _amount) internal {

        uint256 rewardTokenBal = rewardToken.balanceOf(address(this));
        if (_amount > rewardTokenBal) {
            rewardToken.transfer(_to, rewardTokenBal);
        } else {
            rewardToken.transfer(_to, _amount);
        }
    }
    function communityRate(uint256 _rate) public{

        require(communityRateAmount > 0,"No community rate");
        require(hasRole(COMMUNITY_MASTER, msg.sender),"!role");
        uint256 _community_amount = communityRateAmount.mul(_rate).div(PRECISION);
        communityRateAmount = communityRateAmount.sub(_community_amount);
        rewardToken.pool_mint(msg.sender,_community_amount);   
    }
    function rewardTokenRate(uint256 _rewardTokenPerBlock) public onlyAdmin{ 

         rewardTokenPerBlock = _rewardTokenPerBlock;
    }
    function updateStartBlock(uint256 _startBlock,uint256 _miningEndBlock) public onlyAdmin{ 

         startBlock = _startBlock;
         miningEndBlock = _miningEndBlock;
    }
}