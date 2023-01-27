pragma solidity ^0.7.4;

interface IOwned
{

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    function owner() external view returns (address);


    function transferOwnership(address newOwner) external;

    function claimOwnership() external;

}// J-J-J-JENGA!!!
pragma solidity ^0.7.4;



abstract contract Owned is IOwned
{
    address public override owner = msg.sender;
    address internal pendingOwner;

    modifier ownerOnly()
    {
        require (msg.sender == owner, "Owner only");
        _;
    }

    function transferOwnership(address newOwner) public override ownerOnly()
    {
        pendingOwner = newOwner;
    }

    function claimOwnership() public override
    {
        require (pendingOwner == msg.sender);
        pendingOwner = address(0);
        emit OwnershipTransferred(owner, msg.sender);
        owner = msg.sender;
    }
}// J-J-J-JENGA!!!
pragma solidity ^0.7.4;

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

}// J-J-J-JENGA!!!
pragma solidity ^0.7.4;

interface IERC20 
{

    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);

    function totalSupply() external view returns (uint256);

    function balanceOf(address _account) external view returns (uint256);

    function transfer(address _recipient, uint256 _amount) external returns (bool);

    function allowance(address _owner, address _spender) external view returns (uint256);

    function approve(address _spender, uint256 _amount) external returns (bool);

    function transferFrom(address _sender, address _recipient, uint256 _amount) external returns (bool);


    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);

}// J-J-J-JENGA!!!
pragma solidity ^0.7.4;

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

}// J-J-J-JENGA!!!
pragma solidity ^0.7.4;


library SafeMath 
{

    function add(uint256 a, uint256 b) internal pure returns (uint256) 
    {

        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");
        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) 
    {

        return sub(a, b, "SafeMath: subtraction overflow");
    }

    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) 
    {

        require(b <= a, errorMessage);
        uint256 c = a - b;
        return c;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) 
    {

        if (a == 0) 
        {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");
        return c;
    }
    
    function div(uint256 a, uint256 b) internal pure returns (uint256) 
    {

        return div(a, b, "SafeMath: division by zero");
    }

    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) 
    {

        require(b > 0, errorMessage);
        uint256 c = a / b;
        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) 
    {

        return mod(a, b, "SafeMath: modulo by zero");
    }

    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) 
    {

        require(b != 0, errorMessage);
        return a % b;
    }
}// J-J-J-JENGA!!!
pragma solidity ^0.7.4;




abstract contract ERC20 is IERC20 
{
    using SafeMath for uint256;

    mapping (address => uint256) internal _balanceOf;
    mapping (address => mapping (address => uint256)) public override allowance;

    uint256 public override totalSupply;

    string public override name;
    string public override symbol;
    uint8 public override decimals = 18;

    constructor (string memory _name, string memory _symbol) 
    {
        name = _name;
        symbol = _symbol;
    }

    function balanceOf(address a) public virtual override view returns (uint256) { return _balanceOf[a]; }

    function transfer(address recipient, uint256 amount) public virtual override returns (bool) {
        _transfer(msg.sender, recipient, amount);
        return true;
    }

    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        _approve(msg.sender, spender, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) public virtual override returns (bool) {
        _transfer(sender, recipient, amount);
        uint256 oldAllowance = allowance[sender][msg.sender];
        if (oldAllowance != uint256(-1)) {
            _approve(sender, msg.sender, oldAllowance.sub(amount, "ERC20: transfer amount exceeds allowance"));
        }
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        _approve(msg.sender, spender, allowance[msg.sender][spender].add(addedValue));
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        _approve(msg.sender, spender, allowance[msg.sender][spender].sub(subtractedValue, "ERC20: decreased allowance below zero"));
        return true;
    }

    function _transfer(address sender, address recipient, uint256 amount) internal virtual {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(sender, recipient, amount);

        _balanceOf[sender] = _balanceOf[sender].sub(amount, "ERC20: transfer amount exceeds balance");
        _balanceOf[recipient] = _balanceOf[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
    }

    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        totalSupply = totalSupply.add(amount);
        _balanceOf[account] = _balanceOf[account].add(amount);
        emit Transfer(address(0), account, amount);
    }

    function _burn(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: burn from the zero address");

        _beforeTokenTransfer(account, address(0), amount);

        _balanceOf[account] = _balanceOf[account].sub(amount, "ERC20: burn amount exceeds balance");
        totalSupply = totalSupply.sub(amount);
        emit Transfer(account, address(0), amount);
    }

    function _approve(address owner, address spender, uint256 amount) internal virtual {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        allowance[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _setupDecimals(uint8 _decimals) internal {
        decimals = _decimals;
    }

    function _beforeTokenTransfer(address from, address to, uint256 amount) internal virtual { }
}// J-J-J-JENGA!!!
pragma solidity ^0.7.4;
pragma experimental ABIEncoderV2;

struct TransferGateTarget
{
    address destination;
    uint256 amount;
}

interface ITransferGate
{

    function handleTransfer(address msgSender, address from, address to, uint256 amount) external
        returns (uint256 burn, TransferGateTarget[] memory targets);

}// J-J-J-JENGA!!!
pragma solidity ^0.7.4;

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
}// J-J-J-JENGA!!!
pragma solidity ^0.7.4;



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

        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function _callOptionalReturn(IERC20 token, bytes memory data) private {


        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) { // Return data is optional
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}// J-J-J-JENGA!!!
pragma solidity ^0.7.4;


interface ITokensRecoverable
{

    function recoverTokens(IERC20 token) external;

}// J-J-J-JENGA!!!
pragma solidity ^0.7.4;



abstract contract TokensRecoverable is Owned, ITokensRecoverable
{
    using SafeERC20 for IERC20;

    function recoverTokens(IERC20 token) public override ownerOnly() 
    {
        require (canRecoverTokens(token));
        token.safeTransfer(msg.sender, token.balanceOf(address(this)));
    }

    function canRecoverTokens(IERC20 token) internal virtual view returns (bool) 
    { 
        return address(token) != address(this); 
    }
}// J-J-J-JENGA!!!
pragma solidity ^0.7.4;


interface IGatedERC20 is IERC20
{

    function transferGate() external view returns (ITransferGate);


    function setTransferGate(ITransferGate _transferGate) external;

}// J-J-J-JENGA!!!
pragma solidity ^0.7.4;



abstract contract GatedERC20 is ERC20, TokensRecoverable, IGatedERC20
{
    using SafeMath for uint256;

    ITransferGate public override transferGate;

    constructor(string memory _name, string memory _symbol) ERC20(_name, _symbol)
    {
    }

    function setTransferGate(ITransferGate _transferGate) public override ownerOnly()
    {
        transferGate = _transferGate;
    }

    function _transfer(address sender, address recipient, uint256 amount) internal virtual override 
    {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(sender, recipient, amount);

        ITransferGate _transferGate = transferGate;
        uint256 remaining = amount;
        if (address(_transferGate) != address(0)) {
            (uint256 burn, TransferGateTarget[] memory targets) = _transferGate.handleTransfer(msg.sender, sender, recipient, amount);            
            if (burn > 0) {
                amount = remaining = remaining.sub(burn, "Burn too much");
                _burn(sender, burn);
            }
            for (uint256 x = 0; x < targets.length; ++x) {
                (address dest, uint256 amt) = (targets[x].destination, targets[x].amount);
                remaining = remaining.sub(amt, "Transfer too much");
                _balanceOf[dest] = _balanceOf[dest].add(amt);
                emit Transfer(sender, dest, amt);
            }
        }
        _balanceOf[sender] = _balanceOf[sender].sub(amount, "ERC20: transfer amount exceeds balance");
        _balanceOf[recipient] = _balanceOf[recipient].add(remaining);
        emit Transfer(sender, recipient, remaining);
    }
}// J-J-J-JENGA!!!
pragma solidity ^0.7.4;



contract RootKit is GatedERC20("RootKit", "ROOT")
{

    constructor()
    {
        _mint(msg.sender, 10000 ether);
    }
}// J-J-J-JENGA!!!
pragma solidity ^0.7.4;

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

}// J-J-J-JENGA!!!
pragma solidity ^0.7.4;


interface IUniswapV2Router02 is IUniswapV2Router01 {

    function removeLiquidityETHSupportingFeeOnTransferTokens(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external returns (uint amountETH);

    function removeLiquidityETHWithPermitSupportingFeeOnTransferTokens(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountETH);


    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;

    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external payable;

    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;

}// J-J-J-JENGA!!!
pragma solidity ^0.7.4;



struct RootKitTransferGateParameters
{
    address dev;
    uint16 stakeRate; // 10000 = 100%
    uint16 burnRate; // 10000 = 100%
    uint16 devRate;  // 10000 = 100%
    address stake;
}

contract RootKitTransferGate is TokensRecoverable, ITransferGate
{   

    using Address for address;
    using SafeERC20 for IERC20;
    using SafeMath for uint256;

    enum AddressState
    {
        Unknown,
        NotPool,
        DisallowedPool,
        AllowedPool
    }

    RootKitTransferGateParameters public parameters;
    IUniswapV2Router02 immutable uniswapV2Router;
    IUniswapV2Factory immutable uniswapV2Factory;
    RootKit immutable rootKit;

    mapping (address => AddressState) public addressStates;
    IERC20[] public allowedPoolTokens;
    
    bool public unrestricted;
    mapping (address => bool) public unrestrictedControllers;
    mapping (address => bool) public feeControllers;
    mapping (address => bool) public freeParticipant;

    mapping (address => uint256) public liquiditySupply;
    address public mustUpdate; 

    uint8 public sellStakeRateMultiplier;
    address public taxedPool;

    uint16 public dumpTaxStartRate; 
    uint256 public dumpTaxDurationInSeconds;
    uint256 public dumpTaxEndTimestamp;

    constructor(RootKit _rootKit, address _taxedPool, IUniswapV2Router02 _uniswapV2Router)
    {
        rootKit = _rootKit;
        taxedPool = _taxedPool;
        uniswapV2Router = _uniswapV2Router;
        uniswapV2Factory = IUniswapV2Factory(_uniswapV2Router.factory());
    }

    function allowedPoolTokensCount() public view returns (uint256) { return allowedPoolTokens.length; }


    function setUnrestrictedController(address unrestrictedController, bool allow) public ownerOnly()
    {

        unrestrictedControllers[unrestrictedController] = allow;
    }

    function setFreeParticipant(address participant, bool free) public
    {

        require (feeControllers[msg.sender] || msg.sender == owner, "Not an owner or fee controller");
        freeParticipant[participant] = free;
    }

    function setFeeControllers(address feeController, bool allow) public ownerOnly()
    {

        feeControllers[feeController] = allow;
    }

    function setUnrestricted(bool _unrestricted) public
    {

        require (unrestrictedControllers[msg.sender], "Not an unrestricted controller");
        unrestricted = _unrestricted;
    }

    function setParameters(address _dev, address _stake, uint16 _stakeRate, uint16 _burnRate, uint16 _devRate) public ownerOnly()
    {

        require (_stakeRate <= 10000 && _burnRate <= 10000 && _devRate <= 10000 && _stakeRate + _burnRate + _devRate <= 10000, "> 100%");
        require (_dev != address(0) && _stake != address(0));
        require (_stakeRate <= 500 && _burnRate <= 500 && _devRate <= 10, "Sanity");
        
        RootKitTransferGateParameters memory _parameters;
        _parameters.dev = _dev;
        _parameters.stakeRate = _stakeRate;
        _parameters.burnRate = _burnRate;
        _parameters.devRate = _devRate;
        _parameters.stake = _stake;
        parameters = _parameters;
    }

    function setSellStakeRateMultiplier(uint8 multiplier) public
    {

        require (feeControllers[msg.sender] || msg.sender == owner, "Not an owner or fee controller");
        require (multiplier > 0 && multiplier <= 20 , "Must be between 1 and 20"); // protecting everyone from Ponzo
        
        sellStakeRateMultiplier = multiplier;
    }

    function setDumpTax(uint16 startTaxRate, uint256 durationInSeconds) public
    {

        require (feeControllers[msg.sender] || msg.sender == owner, "Not an owner or fee controller");
        require (startTaxRate <= 1000, "Dump tax rate should be less than or equal to 10%");  // protecting everyone from Ponzo

        dumpTaxStartRate = startTaxRate;
        dumpTaxDurationInSeconds = durationInSeconds;
        dumpTaxEndTimestamp = block.timestamp + durationInSeconds;
    }

    function getDumpTax() public view returns (uint256)
    {

        if (block.timestamp >= dumpTaxEndTimestamp) 
        {
            return 0;
        }       
        
        return dumpTaxStartRate*(dumpTaxEndTimestamp - block.timestamp)*1e18/dumpTaxDurationInSeconds/1e18;
    }

    function allowPool(IERC20 token) public ownerOnly()
    {

        address pool = uniswapV2Factory.getPair(address(rootKit), address(token));
        if (pool == address(0)) {
            pool = uniswapV2Factory.createPair(address(rootKit), address(token));
        }
        AddressState state = addressStates[pool];
        require (state != AddressState.AllowedPool, "Already allowed");
        addressStates[pool] = AddressState.AllowedPool;
        allowedPoolTokens.push(token);
        liquiditySupply[pool] = IERC20(pool).totalSupply();
    }

    function safeAddLiquidity(IERC20 token, uint256 tokenAmount, uint256 rootKitAmount, uint256 minTokenAmount, uint256 minRootKitAmount, address to, uint256 deadline) public
        returns (uint256 rootKitUsed, uint256 tokenUsed, uint256 liquidity)
    {

        address pool = uniswapV2Factory.getPair(address(rootKit), address(token));
        require (pool != address(0) && addressStates[pool] == AddressState.AllowedPool, "Pool not approved");
        require (!unrestricted);
        unrestricted = true;

        uint256 tokenBalance = token.balanceOf(address(this));
        token.safeTransferFrom(msg.sender, address(this), tokenAmount);
        rootKit.transferFrom(msg.sender, address(this), rootKitAmount);
        rootKit.approve(address(uniswapV2Router), rootKitAmount);
        token.safeApprove(address(uniswapV2Router), tokenAmount);
        (rootKitUsed, tokenUsed, liquidity) = uniswapV2Router.addLiquidity(address(rootKit), address(token), rootKitAmount, tokenAmount, minRootKitAmount, minTokenAmount, to, deadline);
        liquiditySupply[pool] = IERC20(pool).totalSupply();
        if (mustUpdate == pool) {
            mustUpdate = address(0);
        }

        if (rootKitUsed < rootKitAmount) {
            rootKit.transfer(msg.sender, rootKitAmount - rootKitUsed);
        }
        tokenBalance = token.balanceOf(address(this)).sub(tokenBalance); // we do it this way in case there's a burn
        if (tokenBalance > 0) {
            token.safeTransfer(msg.sender, tokenBalance);
        }
        
        unrestricted = false;
    }

    function handleTransfer(address, address from, address to, uint256 amount) external override
        returns (uint256 burn, TransferGateTarget[] memory targets)
    {

        {
            address mustUpdateAddress = mustUpdate;
            if (mustUpdateAddress != address(0)) {
                mustUpdate = address(0);
                uint256 newSupply = IERC20(mustUpdateAddress).totalSupply();
                uint256 oldSupply = liquiditySupply[mustUpdateAddress];
                if (newSupply != oldSupply) {
                    liquiditySupply[mustUpdateAddress] = unrestricted ? newSupply : (newSupply > oldSupply ? newSupply : oldSupply);
                }
            }
        }
        {
            AddressState fromState = addressStates[from];
            AddressState toState = addressStates[to];
            if (fromState != AddressState.AllowedPool && toState != AddressState.AllowedPool) {
                if (fromState == AddressState.Unknown) { fromState = detectState(from); }
                if (toState == AddressState.Unknown) { toState = detectState(to); }
                require (unrestricted || (fromState != AddressState.DisallowedPool && toState != AddressState.DisallowedPool), "Pool not approved");
            }
            if (toState == AddressState.AllowedPool) {
                mustUpdate = to;
            }
            if (fromState == AddressState.AllowedPool) {
                if (unrestricted) {
                    liquiditySupply[from] = IERC20(from).totalSupply();
                }
                require (IERC20(from).totalSupply() >= liquiditySupply[from], "Cannot remove liquidity");            
            }
        }
        if (unrestricted || freeParticipant[from] || freeParticipant[to]) {
            return (0, new TransferGateTarget[](0));
        }
        RootKitTransferGateParameters memory params = parameters;
        burn = amount * params.burnRate / 10000;

        if (to == address(taxedPool))
        {
            burn = burn + amount * getDumpTax() / 10000;
        }

        targets = new TransferGateTarget[]((params.devRate > 0 ? 1 : 0) + (params.stakeRate > 0 ? 1 : 0));
        uint256 index = 0;
        if (params.stakeRate > 0) {
            targets[index].destination = params.stake;
            targets[index++].amount = to == address(taxedPool) 
                ? amount * params.stakeRate * sellStakeRateMultiplier / 10000  
                : amount * params.stakeRate / 10000;
        }
        if (params.devRate > 0) {
            targets[index].destination = params.dev;
            targets[index].amount = amount * params.devRate / 10000;
        }
    }

    function setAddressState(address a, AddressState state) public ownerOnly()
    {

        addressStates[a] = state;
    }

    function detectState(address a) public returns (AddressState state) 
    {

        state = AddressState.NotPool;
        if (a.isContract()) {
            try this.throwAddressState(a)
            {
                assert(false);
            }
            catch Error(string memory result) {
                if (bytes(result).length == 2) {
                    state = AddressState.DisallowedPool;
                }
            }
            catch {
            }
        }
        addressStates[a] = state;
        return state;
    }
    
    function throwAddressState(address a) external view
    {

        try IUniswapV2Pair(a).factory() returns (address factory)
        {
            if (factory == address(uniswapV2Factory)) {
                try IUniswapV2Pair(a).token0() returns (address token0)
                {
                    if (token0 == address(rootKit)) {
                        revert("22");
                    }
                    try IUniswapV2Pair(a).token1() returns (address token1)
                    {
                        if (token1 == address(rootKit)) {
                            revert("22");
                        }                        
                    }
                    catch { 
                    }                    
                }
                catch { 
                }
            }
        }
        catch {             
        }
        revert("1");
    }
}// J-J-J-JENGA!!!
pragma solidity ^0.7.4;


interface IFloorCalculator
{

    function calculateSubFloor(IERC20 wrappedToken, IERC20 backingToken) external view returns (uint256);

}// J-J-J-JENGA!!!
pragma solidity ^0.7.4;

interface IWrappedERC20Events
{

    event Deposit(address indexed from, uint256 amount);
    event Withdrawal(address indexed to, uint256 amount);
}
pragma solidity ^0.7.4;


interface IWrappedERC20 is IERC20, IWrappedERC20Events
{

    function wrappedToken() external view returns (IERC20);

    function depositTokens(uint256 _amount) external;

    function withdrawTokens(uint256 _amount) external;

}// J-J-J-JENGA!!!
pragma solidity ^0.7.4;



contract WrappedERC20 is ERC20, IWrappedERC20, TokensRecoverable
{

    using SafeERC20 for IERC20;
    using SafeMath for uint256;

    IERC20 public immutable override wrappedToken;

    constructor (IERC20 _wrappedToken, string memory _name, string memory _symbol)
        ERC20(_name, _symbol)
    {        
        if (_wrappedToken.decimals() != 18) {
            _setupDecimals(_wrappedToken.decimals());
        }
        wrappedToken = _wrappedToken;
    }

    function depositTokens(uint256 _amount) public override
    {

        _beforeDepositTokens(_amount);
        uint256 myBalance = wrappedToken.balanceOf(address(this));
        wrappedToken.safeTransferFrom(msg.sender, address(this), _amount);
        uint256 received = wrappedToken.balanceOf(address(this)).sub(myBalance);
        _mint(msg.sender, received);
        emit Deposit(msg.sender, _amount);
    }

    function withdrawTokens(uint256 _amount) public override
    {

        _beforeWithdrawTokens(_amount);
        _burn(msg.sender, _amount);
        uint256 myBalance = wrappedToken.balanceOf(address(this));
        wrappedToken.safeTransfer(msg.sender, _amount);
        require (wrappedToken.balanceOf(address(this)) == myBalance.sub(_amount), "Transfer not exact");
        emit Withdrawal(msg.sender, _amount);
    }

    function canRecoverTokens(IERC20 token) internal virtual override view returns (bool) 
    {

        return token != this && token != wrappedToken;
    }

    function _beforeDepositTokens(uint256 _amount) internal virtual view { }

    function _beforeWithdrawTokens(uint256 _amount) internal virtual view { }
}// J-J-J-JENGA!!!
pragma solidity ^0.7.4;


interface IERC31337 is IWrappedERC20
{

    function floorCalculator() external view returns (IFloorCalculator);

    function sweepers(address _sweeper) external view returns (bool);

    
    function setFloorCalculator(IFloorCalculator _floorCalculator) external;

    function setSweeper(address _sweeper, bool _allow) external;

    function sweepFloor(address _to) external returns (uint256 amountSwept);

}// J-J-J-JENGA!!!
pragma solidity ^0.7.4;



contract ERC31337 is WrappedERC20, IERC31337
{

    using SafeERC20 for IERC20;

    IFloorCalculator public override floorCalculator;
    
    mapping (address => bool) public override sweepers;

    constructor(IERC20 _wrappedToken, string memory _name, string memory _symbol)
        WrappedERC20(_wrappedToken, _name, _symbol)
    {
    }

    function setFloorCalculator(IFloorCalculator _floorCalculator) public override ownerOnly()
    {

        floorCalculator = _floorCalculator;
    }

    function setSweeper(address sweeper, bool allow) public override ownerOnly()
    {

        sweepers[sweeper] = allow;
    }

    function sweepFloor(address to) public override returns (uint256 amountSwept)
    {

        require (to != address(0));
        require (sweepers[msg.sender], "Sweepers only");
        amountSwept = floorCalculator.calculateSubFloor(wrappedToken, this);
        if (amountSwept > 0) {
            wrappedToken.safeTransfer(to, amountSwept);
        }
    }
}// J-J-J-JENGA!!!
pragma solidity ^0.7.4;


interface IWETH is IERC20, IWrappedERC20Events
{    

    function deposit() external payable;

    function withdraw(uint256 _amount) external;

}
pragma solidity ^0.7.4;



contract KETH is ERC31337, IWETH
{

    using SafeMath for uint256;

    mapping (address => bool) public freeParticipant;
    uint16 public burnRate; 

    constructor (IWETH _weth) ERC31337(_weth, "RootKit ETH", "KETH")
    {
        _mint(msg.sender, 2000 ether);
    }

    receive() external payable
    {
        if (msg.sender != address(wrappedToken)) {
            deposit();
        }
    }

    function deposit() public payable override
    {

        uint256 amount = msg.value;
        IWETH(address(wrappedToken)).deposit{ value: amount }();
        _mint(msg.sender, amount);
        emit Deposit(msg.sender, amount); 
    }

    function withdraw(uint256 _amount) public override
    {

        _burn(msg.sender, _amount);
        IWETH(address(wrappedToken)).withdraw(_amount);
        emit Withdrawal(msg.sender, _amount);
        (bool success,) = msg.sender.call{ value: _amount }("");
        require (success, "Transfer failed");
    }

    function setFreeParticipant(address participant, bool free) public ownerOnly()
    {

        freeParticipant[participant] = free;
    }

    function setBurnRate(uint16 _burnRate) public ownerOnly()
    {

        require (_burnRate <= 2000 , "Dump tax rate should be less than or equal to 20%"); // protecting everyone from Ponzo
        
        burnRate = _burnRate;
    }
    
    function burn(uint256 amount) public
    {

        _burn(msg.sender, amount);
    }

    function _transfer(address sender, address recipient, uint256 amount) internal virtual override 
    {

        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(sender, recipient, amount);

        if (burnRate > 0 && !freeParticipant[sender] && !freeParticipant[recipient]) {
            uint256 burnAmount = amount * burnRate / 10000;
            amount = amount.sub(burnAmount, "Burn too much");
            _burn(sender, burnAmount);
        }
        _balanceOf[sender] = _balanceOf[sender].sub(amount, "ERC20: transfer amount exceeds balance");
        _balanceOf[recipient] = _balanceOf[recipient].add(amount);

        emit Transfer(sender, recipient, amount);
    }
}// J-J-J-JENGA!!!
pragma solidity ^0.7.4;


library UniswapV2Library {

    using SafeMath for uint;

    function sortTokens(address tokenA, address tokenB) internal pure returns (address token0, address token1) {

        require(tokenA != tokenB, 'UniswapV2Library: IDENTICAL_ADDRESSES');
        (token0, token1) = tokenA < tokenB ? (tokenA, tokenB) : (tokenB, tokenA);
        require(token0 != address(0), 'UniswapV2Library: ZERO_ADDRESS');
    }

    function pairFor(address factory, address tokenA, address tokenB) internal pure returns (address pair) {

        (address token0, address token1) = sortTokens(tokenA, tokenB);
        pair = address(uint(keccak256(abi.encodePacked(
                hex'ff',
                factory,
                keccak256(abi.encodePacked(token0, token1)),
                hex'96e8ac4277198ff8b6f785478aa9a39f403cb768dd02cbee326c3e7da348845f' // init code hash
            ))));
    }

    function getReserves(address factory, address tokenA, address tokenB) internal view returns (uint reserveA, uint reserveB) {

        (address token0,) = sortTokens(tokenA, tokenB);
        (uint reserve0, uint reserve1,) = IUniswapV2Pair(pairFor(factory, tokenA, tokenB)).getReserves();
        (reserveA, reserveB) = tokenA == token0 ? (reserve0, reserve1) : (reserve1, reserve0);
    }

    function quote(uint amountA, uint reserveA, uint reserveB) internal pure returns (uint amountB) {

        require(amountA > 0, 'UniswapV2Library: INSUFFICIENT_AMOUNT');
        require(reserveA > 0 && reserveB > 0, 'UniswapV2Library: INSUFFICIENT_LIQUIDITY');
        amountB = amountA.mul(reserveB) / reserveA;
    }

    function getAmountOut(uint amountIn, uint reserveIn, uint reserveOut) internal pure returns (uint amountOut) {

        require(amountIn > 0, 'UniswapV2Library: INSUFFICIENT_INPUT_AMOUNT');
        require(reserveIn > 0 && reserveOut > 0, 'UniswapV2Library: INSUFFICIENT_LIQUIDITY');
        uint amountInWithFee = amountIn.mul(997);
        uint numerator = amountInWithFee.mul(reserveOut);
        uint denominator = reserveIn.mul(1000).add(amountInWithFee);
        amountOut = numerator / denominator;
    }

    function getAmountIn(uint amountOut, uint reserveIn, uint reserveOut) internal pure returns (uint amountIn) {

        require(amountOut > 0, 'UniswapV2Library: INSUFFICIENT_OUTPUT_AMOUNT');
        require(reserveIn > 0 && reserveOut > 0, 'UniswapV2Library: INSUFFICIENT_LIQUIDITY');
        uint numerator = reserveIn.mul(amountOut).mul(1000);
        uint denominator = reserveOut.sub(amountOut).mul(997);
        amountIn = (numerator / denominator).add(1);
    }

    function getAmountsOut(address factory, uint amountIn, address[] memory path) internal view returns (uint[] memory amounts) {

        require(path.length >= 2, 'UniswapV2Library: INVALID_PATH');
        amounts = new uint[](path.length);
        amounts[0] = amountIn;
        for (uint i; i < path.length - 1; i++) {
            (uint reserveIn, uint reserveOut) = getReserves(factory, path[i], path[i + 1]);
            amounts[i + 1] = getAmountOut(amounts[i], reserveIn, reserveOut);
        }
    }

    function getAmountsIn(address factory, uint amountOut, address[] memory path) internal view returns (uint[] memory amounts) {

        require(path.length >= 2, 'UniswapV2Library: INVALID_PATH');
        amounts = new uint[](path.length);
        amounts[amounts.length - 1] = amountOut;
        for (uint i = path.length - 1; i > 0; i--) {
            (uint reserveIn, uint reserveOut) = getReserves(factory, path[i - 1], path[i]);
            amounts[i - 1] = getAmountIn(amounts[i], reserveIn, reserveOut);
        }
    }
}