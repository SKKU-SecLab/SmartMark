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


interface IFloorCalculator
{

    function calculateSubFloor(IERC20 wrappedToken, IERC20 backingToken) external view returns (uint256);

}// J-J-J-JENGA!!!
pragma solidity ^0.7.4;




abstract contract ERC20 is IERC20 
{
    using SafeMath for uint256;

    mapping (address => uint256) public override balanceOf;
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

        balanceOf[sender] = balanceOf[sender].sub(amount, "ERC20: transfer amount exceeds balance");
        balanceOf[recipient] = balanceOf[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
    }

    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        totalSupply = totalSupply.add(amount);
        balanceOf[account] = balanceOf[account].add(amount);
        emit Transfer(address(0), account, amount);
    }

    function _burn(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: burn from the zero address");

        _beforeTokenTransfer(account, address(0), amount);

        balanceOf[account] = balanceOf[account].sub(amount, "ERC20: burn amount exceeds balance");
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



contract ERC31337 is Owned, WrappedERC20, IERC31337
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

    constructor (IWETH _weth)
        ERC31337(_weth, "RootKit [Wrapped ETH]", "RK:ETH")
    {
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
}// J-J-J-JENGA!!!
pragma solidity ^0.7.4;
pragma experimental ABIEncoderV2;



contract RootKitMoneyButton is Owned, TokensRecoverable
{

    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    IUniswapV2Router02 immutable uniswapV2Router;
    IUniswapV2Factory immutable uniswapV2Factory;
    KETH immutable keth;
    IWETH immutable weth;
    mapping (address => bool) approved;

    address public vault;
    uint16 public percentToVault; // 10000 = 100%;

    constructor(IUniswapV2Router02 _uniswapV2Router, KETH _keth)
    {
        uniswapV2Router = _uniswapV2Router;
        uniswapV2Factory = IUniswapV2Factory(_uniswapV2Router.factory());
        keth = _keth;
        IWETH _weth = weth = IWETH(address(_keth.wrappedToken()));

        _weth.approve(address(_keth), uint256(-1));
    }

    receive() external payable
    {
        require (msg.sender == address(weth) || msg.sender == address(keth));
    }

    function configure(address _vault, uint16 _percentToVault) public ownerOnly() {

        require (_vault != address(0) && _percentToVault <= 10000);
        vault = _vault;
        percentToVault = _percentToVault;
    }

    function estimateProfit(address[] calldata _fullPath, uint256 _amountIn) public view returns (uint256)
    {

        uint256 amountOut = _amountIn;
        address[] memory path = new address[](2);
        for (uint256 x=1; x<=_fullPath.length; ++x) {
            path[0] = _fullPath[x-1];
            path[1] = _fullPath[x%_fullPath.length];
            bool kindaEthIn = path[0] == address(0) || path[0] == address(weth) || path[0] == address(keth);
            bool kindaEthOut = path[1] == address(0) || path[1] == address(weth) || path[1] == address(keth);
            if (kindaEthIn && kindaEthOut) { continue; }
            (uint256[] memory amountsOut) = UniswapV2Library.getAmountsOut(address(uniswapV2Factory), amountOut, path);
            amountOut = amountsOut[1];
        }
        if (amountOut <= _amountIn) { return 0; }
        return amountOut - _amountIn;
    }

    function gimmeMoney(address[] calldata _fullPath, uint256 _amountIn, uint256 _minProfit) public payable
    {

        uint256 amountOut = _amountIn;
        address[] memory path = new address[](2);
        uint256 count = _fullPath.length;
        if (_fullPath[0] != address(0)) {
            IERC20(_fullPath[0]).safeTransferFrom(msg.sender, address(this), _amountIn);
        }
        else {
            require ((msg.value == 0) != (_fullPath[0] == address(0)), "Send ETH if and only if the path starts with ETH");
        }
        for (uint256 x=1; x<=_fullPath.length; ++x) {
            address tokenIn = _fullPath[x-1];
            address tokenOut = _fullPath[x%count];
            if (tokenIn == tokenOut) { continue; }
            if (tokenIn == address(0)) {
                require (x == 1, "Conversion from ETH can only happen first");
                amountOut = _amountIn = msg.value;
                if (tokenOut == address(weth)) {
                    weth.deposit{ value: amountOut }();
                }
                else if (tokenOut == address(keth)) {
                    keth.deposit{ value: amountOut }();
                }
                else {
                    revert("ETH must convert to WETH or KETH");
                }
                continue;
            }
            if (tokenOut == address(0)) {
                require (x == _fullPath.length, "Conversion to ETH can only happen last");
                if (tokenIn == address(weth)) {
                    weth.withdraw(amountOut);
                }
                else if (tokenIn == address(keth)) {
                    keth.withdraw(amountOut);
                }
                else {
                    revert("ETH must be converted from WETH or KETH");
                }
                continue;
            }
            if (tokenIn == address(weth) && tokenOut == address(keth)) {
                keth.depositTokens(amountOut);
                continue;
            }
            if (tokenIn == address(keth) && tokenOut == address(weth)) {
                keth.withdrawTokens(amountOut);
                continue;
            }            
            if (!approved[tokenIn]) {
                IERC20(tokenIn).safeApprove(address(uniswapV2Router), uint256(-1));
                approved[tokenIn] = true;
            }
            path[0] = tokenIn;
            path[1] = tokenOut;
            (uint256[] memory amounts) = uniswapV2Router.swapExactTokensForTokens(amountOut, 0, path, address(this), block.timestamp);
            amountOut = amounts[1];
        }

        amountOut = _fullPath[0] == address(0) ? address(this).balance : IERC20(_fullPath[0]).balanceOf(address(this));

        require (amountOut >= _amountIn.add(_minProfit), "Not enough profit");

        uint256 forVault = (amountOut - _amountIn).mul(percentToVault) / 10000;
        if (_fullPath[0] == address(0)) {
            (bool success,) = msg.sender.call{ value: amountOut - forVault }("");
            require (success, "Transfer failed");
            (success,) = vault.call{ value: forVault }("");
            require (success, "Transfer failed");
            return;
        }
        IERC20(_fullPath[0]).safeTransfer(msg.sender, amountOut - forVault);
        IERC20(_fullPath[0]).safeTransfer(vault, forVault);
    }
}// J-J-J-JENGA!!!
pragma solidity ^0.7.4;


contract DevSplitter
{

    using SafeMath for uint256;
    using SafeERC20 for IERC20;
    using Address for address;

    mapping (IERC20 => uint256) public totalPaid;
    mapping (IERC20 => mapping(address => uint256)) public totalPaidToPayee;
    
    mapping (address => uint256) public share;
    uint256 immutable public totalShares;

    constructor(address[] memory payees, uint256[] memory shares)
    {
        require (payees.length == shares.length && payees.length > 0);

        uint256 total = 0;
        for (uint256 x=0; x<payees.length; ++x) {
            address payee = payees[x];
            uint256 sh = shares[x];
            require (payee != address(0) && sh > 0 && share[payee] == 0);
            require (!payee.isContract(), "Cannot pay a contract");
            total = total.add(sh);
            share[payee] = sh;
        }
        totalShares = total;
    }

    receive() external payable {}

    function owed(IERC20 token, address payee) public view returns (uint256) {        

        uint256 balance = address(token) == address(0) ? address(this).balance : token.balanceOf(address(this));
        uint256 payeeShare = balance.add(totalPaid[token]).mul(share[payee]) / totalShares;
        uint256 paid = totalPaidToPayee[token][payee];
        return payeeShare > paid ? payeeShare - paid : 0;
    }

    function pay(IERC20 token, address payable payee) public {

        uint256 toPay = owed(token, payee);
        require (toPay > 0, "Nothing to pay");

        totalPaid[token] = totalPaid[token].add(toPay);
        totalPaidToPayee[token][payee] = totalPaidToPayee[token][payee].add(toPay);
                
        if (address(token) == address(0)) {
            (bool success,) = payee.call{ value: toPay }("");
            require (success, "Transfer failed");
        }
        else {
            token.safeTransfer(payee, toPay);
        }
    }
}// J-J-J-JENGA!!!
pragma solidity ^0.7.4;

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


interface IGatedERC20 is IERC20
{

    function transferGate() external view returns (ITransferGate);


    function setTransferGate(ITransferGate _transferGate) external;

}// J-J-J-JENGA!!!
pragma solidity ^0.7.4;



abstract contract GatedERC20 is ERC20, Owned, TokensRecoverable, IGatedERC20
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
                balanceOf[dest] = balanceOf[dest].add(amt);
            }
        }
        balanceOf[sender] = balanceOf[sender].sub(amount, "ERC20: transfer amount exceeds balance");
        balanceOf[recipient] = balanceOf[recipient].add(remaining);
        emit Transfer(sender, recipient, amount);
    }
}// J-J-J-JENGA!!!
pragma solidity ^0.7.4;

interface IRootKitDistribution
{

    function distributionComplete() external view returns (bool);

    
    function distribute() external payable;

    function claim(address _to, uint256 _contribution) external;

}// J-J-J-JENGA!!!
pragma solidity ^0.7.4;


interface IStoneface
{

    event PendingOwnershipTransfer(IOwned target, address newOwner, uint256 when);

    struct TransferOwnership
    {
        uint256 when;
        IOwned target;
        address newOwner;
    }

    function delay() external view returns (uint256);

    function pendingTransferOwnership(uint256 index) external view returns (TransferOwnership memory);

    function pendingTransferOwnershipCount() external view returns (uint256);

    function callTransferOwnership(IOwned target, address newOwner) external;

    function callTransferOwnershipNow(uint256 index) external;

    function callClaimOwnership(IOwned target) external;

    function rootKitDistribution() external view returns (IRootKitDistribution);

    function watchDistribution(IRootKitDistribution _rootKitDistribution) external;

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



struct RootKitTransferGateParameters
{
    address dev;
    uint16 stakeRate; // 10000 = 100%
    uint16 burnRate; // 10000 = 100%
    uint16 devRate;  // 10000 = 100%
    address stake;
}

contract RootKitTransferGate is Owned, TokensRecoverable, ITransferGate
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
    mapping (address => bool) public freeParticipant;

    mapping (address => uint256) public liquiditySupply;
    address public mustUpdate;    

    constructor(RootKit _rootKit, IUniswapV2Router02 _uniswapV2Router)
    {
        rootKit = _rootKit;
        uniswapV2Router = _uniswapV2Router;
        uniswapV2Factory = IUniswapV2Factory(_uniswapV2Router.factory());
    }

    function allowedPoolTokensCount() public view returns (uint256) { return allowedPoolTokens.length; }


    function setUnrestrictedController(address unrestrictedController, bool allow) public ownerOnly()
    {

        unrestrictedControllers[unrestrictedController] = allow;
    }

    function setFreeParticipant(address participant, bool free) public ownerOnly()
    {

        freeParticipant[participant] = free;
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

        address mustUpdateAddress = mustUpdate;
        if (mustUpdateAddress != address(0)) {
            mustUpdate = address(0);
            liquiditySupply[mustUpdateAddress] = IERC20(mustUpdateAddress).totalSupply();
        }
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
        if (unrestricted || freeParticipant[from] || freeParticipant[to]) {
            return (0, new TransferGateTarget[](0));
        }
        RootKitTransferGateParameters memory params = parameters;
        burn = amount * params.burnRate / 10000;
        targets = new TransferGateTarget[]((params.devRate > 0 ? 1 : 0) + (params.stakeRate > 0 ? 1 : 0));
        uint256 index = 0;
        if (params.stakeRate > 0) {
            targets[index].destination = params.stake;
            targets[index++].amount = amount * params.stakeRate / 10000;
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



contract RootKitDistribution is Owned, TokensRecoverable, IRootKitDistribution
{

    using SafeMath for uint256;

    bool public override distributionComplete;

    IUniswapV2Router02 immutable uniswapV2Router;
    IUniswapV2Factory immutable uniswapV2Factory;
    RootKit immutable rootKit;
    KETH immutable keth;
    IERC20 immutable weth;
    IERC20 immutable wbtc;
    address immutable vault;

    IUniswapV2Pair kethRootKit;
    IUniswapV2Pair wbtcRootKit;
    IWrappedERC20 wrappedKethRootKit;
    IWrappedERC20 wrappedWbtcRootKit;

    uint256 public totalEthCollected;
    uint256 public totalRootKitBought;
    uint256 public totalWbtcRootKit;
    uint256 public totalKethRootKit;
    address rootKitLiquidityGeneration;
    uint256 recoveryDate = block.timestamp + 2592000; // 1 Month

    uint8 public jengaCount;
    
    uint16 constant public vaultPercent = 2500; // Proportionate amount used to seed the vault
    uint16 constant public buyPercent = 2500; // Proportionate amount used to group buy RootKit for distribution to participants
    uint16 constant public wbtcPercent = 2500; // Proportionate amount used to create wBTC/RootKit pool

    constructor(RootKit _rootKit, IUniswapV2Router02 _uniswapV2Router, KETH _keth, IERC20 _wbtc, address _vault)
    {
        require (address(_rootKit) != address(0));
        require (address(_wbtc) != address(0));
        require (address(_vault) != address(0));

        rootKit = _rootKit;
        uniswapV2Router = _uniswapV2Router;
        keth = _keth;
        wbtc = _wbtc;
        vault = _vault;

        uniswapV2Factory = IUniswapV2Factory(_uniswapV2Router.factory());
        weth = _keth.wrappedToken();
    }

    function setupKethRootKit() public
    {

        kethRootKit = IUniswapV2Pair(uniswapV2Factory.getPair(address(keth), address(rootKit)));
        if (address(kethRootKit) == address(0)) {
            kethRootKit = IUniswapV2Pair(uniswapV2Factory.createPair(address(keth), address(rootKit)));
            require (address(kethRootKit) != address(0));
        }
    }
    function setupWbtcRootKit() public
    {

        wbtcRootKit = IUniswapV2Pair(uniswapV2Factory.getPair(address(wbtc), address(rootKit)));
        if (address(wbtcRootKit) == address(0)) {
            wbtcRootKit = IUniswapV2Pair(uniswapV2Factory.createPair(address(wbtc), address(rootKit)));
            require (address(wbtcRootKit) != address(0));
        }
    }
    function completeSetup(IWrappedERC20 _wrappedKethRootKit, IWrappedERC20 _wrappedWbtcRootKit) public ownerOnly()
    {        

        require (address(_wrappedKethRootKit.wrappedToken()) == address(kethRootKit), "Wrong LP Wrapper");
        require (address(_wrappedWbtcRootKit.wrappedToken()) == address(wbtcRootKit), "Wrong LP Wrapper");
        wrappedKethRootKit = _wrappedKethRootKit;
        wrappedWbtcRootKit = _wrappedWbtcRootKit;
        keth.approve(address(uniswapV2Router), uint256(-1));
        rootKit.approve(address(uniswapV2Router), uint256(-1));
        weth.approve(address(keth), uint256(-1));
        weth.approve(address(uniswapV2Router), uint256(-1));
        wbtc.approve(address(uniswapV2Router), uint256(-1));
        kethRootKit.approve(address(wrappedKethRootKit), uint256(-1));
        wbtcRootKit.approve(address(wrappedWbtcRootKit), uint256(-1));
    }

    function setJengaCount(uint8 _jengaCount) public ownerOnly()
    {

        jengaCount = _jengaCount;
    }

    function distribute() public override payable
    {

        require (!distributionComplete, "Distribution complete");
        uint256 totalEth = msg.value;
        require (totalEth > 0, "Nothing to distribute");
        distributionComplete = true;
        totalEthCollected = totalEth;
        rootKitLiquidityGeneration = msg.sender;

        rootKit.transferFrom(msg.sender, address(this), rootKit.totalSupply());
        
        RootKitTransferGate gate = RootKitTransferGate(address(rootKit.transferGate()));
        gate.setUnrestricted(true);

        createKethRootKitLiquidity(totalEth);

        jenga(jengaCount);

        sweepFloorToWeth();
        uint256 wethBalance = weth.balanceOf(address(this));

        createWbtcRootKitLiquidity(wethBalance * wbtcPercent / 10000);
        preBuyForGroup(wethBalance * buyPercent / 10000);

        sweepFloorToWeth();
        weth.transfer(vault, wethBalance * vaultPercent / 10000);
        weth.transfer(owner, weth.balanceOf(address(this)));
        kethRootKit.transfer(owner, kethRootKit.balanceOf(address(this)));

        gate.setUnrestricted(false);
    }

    function sweepFloorToWeth() private
    {

        keth.sweepFloor(address(this));
        keth.withdrawTokens(keth.balanceOf(address(this)));
    }
    function createKethRootKitLiquidity(uint256 totalEth) private
    {

        keth.deposit{ value: totalEth }();
        (,,totalKethRootKit) = uniswapV2Router.addLiquidity(address(keth), address(rootKit), keth.balanceOf(address(this)), rootKit.totalSupply(), 0, 0, address(this), block.timestamp);
        
        wrappedKethRootKit.depositTokens(totalKethRootKit);  
    }
    function createWbtcRootKitLiquidity(uint256 wethAmount) private
    {

        address[] memory path = new address[](2);
        path[0] = address(keth);
        path[1] = address(rootKit);
        keth.depositTokens(wethAmount / 2);
        uint256[] memory amountsRootKit = uniswapV2Router.swapExactTokensForTokens(wethAmount / 2, 0, path, address(this), block.timestamp);

        path[0] = address(weth);
        path[1] = address(wbtc);
        uint256[] memory amountsWbtc = uniswapV2Router.swapExactTokensForTokens(wethAmount / 2, 0, path, address(this), block.timestamp);
        (,,totalWbtcRootKit) = uniswapV2Router.addLiquidity(address(wbtc), address(rootKit), amountsWbtc[1], amountsRootKit[1], 0, 0, address(this), block.timestamp);

        wrappedWbtcRootKit.depositTokens(totalWbtcRootKit);
    }
    function preBuyForGroup(uint256 wethAmount) private
    {      

        address[] memory path = new address[](2);
        path[0] = address(keth);
        path[1] = address(rootKit);
        keth.depositTokens(wethAmount);
        uint256[] memory amountsRootKit = uniswapV2Router.swapExactTokensForTokens(wethAmount, 0, path, address(this), block.timestamp);
        totalRootKitBought = amountsRootKit[1];
    }
    
    function jenga(uint8 count) private
    {

        address[] memory path = new address[](2);
        path[0] = address(keth);
        path[1] = address(rootKit);
        for (uint x=0; x<count; ++x) {
            keth.depositTokens(keth.sweepFloor(address(this)));
            uint256[] memory amounts = uniswapV2Router.swapExactTokensForTokens(keth.balanceOf(address(this)) * 2 / 5, 0, path, address(this), block.timestamp);
            keth.depositTokens(keth.sweepFloor(address(this)));
            uniswapV2Router.addLiquidity(address(keth), address(rootKit), keth.balanceOf(address(this)), amounts[1], 0, 0, address(this), block.timestamp);
        }
    }

    function claim(address _to, uint256 _contribution) public override
    {

        require (msg.sender == rootKitLiquidityGeneration, "Unauthorized");
        uint256 totalEth = totalEthCollected;

        uint256 share = _contribution.mul(totalKethRootKit) / totalEth;        
        if (share > wrappedKethRootKit.balanceOf(address(this))) {
            share = wrappedKethRootKit.balanceOf(address(this)); // Should never happen, but just being safe.
        }
        wrappedKethRootKit.transfer(_to, share);

        share = _contribution.mul(totalWbtcRootKit) / totalEth;        
        if (share > wrappedWbtcRootKit.balanceOf(address(this))) {
            share = wrappedWbtcRootKit.balanceOf(address(this)); // Should never happen, but just being safe.
        }
        wrappedWbtcRootKit.transfer(_to, share);

        RootKitTransferGate gate = RootKitTransferGate(address(rootKit.transferGate()));
        gate.setUnrestricted(true);

        share = _contribution.mul(totalRootKitBought) / totalEth;
        if (share > rootKit.balanceOf(address(this))) {
            share = rootKit.balanceOf(address(this)); // Should never happen, but just being safe.
        }
        rootKit.transfer(_to, share);

        gate.setUnrestricted(false);
    }

    function canRecoverTokens(IERC20 token) internal override view returns (bool) { 

        return 
            block.timestamp > recoveryDate ||
            (
                token != rootKit && 
                address(token) != address(wrappedKethRootKit) && 
                address(token) != address(wrappedWbtcRootKit)
            );
    }
}// J-J-J-JENGA!!!
pragma solidity ^0.7.4;



contract RootKitFloorCalculator is IFloorCalculator, TokensRecoverable
{

    using SafeMath for uint256;

    RootKit immutable rootKit;
    IUniswapV2Factory immutable uniswapV2Factory;

    constructor(RootKit _rootKit, IUniswapV2Factory _uniswapV2Factory)
    {
        rootKit = _rootKit;
        uniswapV2Factory = _uniswapV2Factory;
    }

    function calculateSubFloor(IERC20 wrappedToken, IERC20 backingToken) public override view returns (uint256)
    {

        address pair = UniswapV2Library.pairFor(address(uniswapV2Factory), address(rootKit), address(backingToken));
        uint256 freeRootKit = rootKit.totalSupply().sub(rootKit.balanceOf(pair));
        uint256 sellAllProceeds = 0;
        if (freeRootKit > 0) {
            address[] memory path = new address[](2);
            path[0] = address(rootKit);
            path[1] = address(backingToken);
            uint256[] memory amountsOut = UniswapV2Library.getAmountsOut(address(uniswapV2Factory), freeRootKit, path);
            sellAllProceeds = amountsOut[1];
        }
        uint256 backingInPool = backingToken.balanceOf(pair);
        if (backingInPool <= sellAllProceeds) { return 0; }
        uint256 excessInPool = backingInPool - sellAllProceeds;

        uint256 requiredBacking = backingToken.totalSupply().sub(excessInPool);
        uint256 currentBacking = wrappedToken.balanceOf(address(backingToken));
        if (requiredBacking >= currentBacking) { return 0; }
        return currentBacking - requiredBacking;
    }
}// J-J-J-JENGA!!!
pragma solidity ^0.7.4;



contract RootKitLiquidity is ERC31337
{

    constructor(IUniswapV2Pair _pair, string memory _name, string memory _symbol)
        ERC31337(IERC20(address(_pair)), _name, _symbol)
    {
    }

    function _beforeWithdrawTokens(uint256) internal override pure
    { 

        revert("RootKit liquidity is locked");
    }
}// J-J-J-JENGA!!!
pragma solidity ^0.7.4;


contract RootKitLiquidityGeneration is Owned, TokensRecoverable
{

    mapping (address => uint256) public contribution;
    address[] public contributors;

    bool public isActive;

    RootKit immutable rootKit;
    IRootKitDistribution public rootKitDistribution;
    uint256 refundsAllowedUntil;

    constructor (RootKit _rootKit)
    {
        rootKit = _rootKit;
    }

    modifier active()
    {

        require (isActive, "Distribution not active");
        _;
    }

    function contributorsCount() public view returns (uint256) { return contributors.length; }


    function activate(IRootKitDistribution _rootKitDistribution) public ownerOnly()
    {

        require (!isActive && contributors.length == 0 && block.timestamp >= refundsAllowedUntil, "Already activated");        
        require (rootKit.balanceOf(address(this)) == rootKit.totalSupply(), "Missing supply");
        require (address(_rootKitDistribution) != address(0));
        rootKitDistribution = _rootKitDistribution;
        isActive = true;
    }

    function setRootKitDistribution(IRootKitDistribution _rootKitDistribution) public ownerOnly() active()
    {

        require (address(_rootKitDistribution) != address(0));
        if (_rootKitDistribution == rootKitDistribution) { return; }
        rootKitDistribution = _rootKitDistribution;

        refundsAllowedUntil = block.timestamp + 86400;
    }

    function complete() public ownerOnly() active()
    {

        require (block.timestamp >= refundsAllowedUntil, "Refund period is still active");
        isActive = false;
        if (address(this).balance == 0) { return; }
        rootKit.approve(address(rootKitDistribution), uint256(-1));
        rootKitDistribution.distribute{ value: address(this).balance }();
    }

    function allowRefunds() public ownerOnly() active()
    {

        isActive = false;
        refundsAllowedUntil = uint256(-1);
    }

    function claim() public
    {

        uint256 amount = contribution[msg.sender];
        require (amount > 0, "Nothing to claim");
        contribution[msg.sender] = 0;
        if (refundsAllowedUntil > block.timestamp) {
            (bool success,) = msg.sender.call{ value: amount }("");
            require (success, "Transfer failed");
        }
        else {
            rootKitDistribution.claim(msg.sender, amount);
        }
    }

    receive() external payable active()
    {
        uint256 oldContribution = contribution[msg.sender];
        uint256 newContribution = oldContribution + msg.value;
        if (oldContribution == 0 && newContribution > 0) {
            contributors.push(msg.sender);
        }
        contribution[msg.sender] = newContribution;
    }
}// J-J-J-JENGA!!!
pragma solidity ^0.7.4;



contract RootKitStaking is Owned, TokensRecoverable
{

    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    event Deposit(address indexed user, uint256 indexed poolId, uint256 amount);
    event Withdraw(address indexed user, uint256 indexed poolId, uint256 amount);
    event EmergencyWithdraw(address indexed user, uint256 indexed poolId, uint256 amount);
    event Emergency();

    struct UserInfo 
    {
        uint256 amountStaked;
        uint256 rewardDebt;
    }

    struct PoolInfo 
    {
        IERC20 token;
        uint256 allocationPoints;
        uint256 lastTotalReward;
        uint256 accRewardPerShare;
    }

    IERC20 public immutable rewardToken;

    PoolInfo[] public poolInfo;
    mapping (uint256 => mapping (address => UserInfo)) public userInfo;
    uint256 public totalAllocationPoints;

    mapping (IERC20 => bool) existingPools;
    uint256 constant maxPoolCount = 20; // to simplify things and ensure massUpdatePools is safe
    uint256 totalReward;
    uint256 lastRewardBalance;

    uint256 public emergencyRecoveryTimestamp;

    constructor(IERC20 _rewardToken)
    {
        rewardToken = _rewardToken;
    }

    function poolInfoCount() external view returns (uint256) 
    {

        return poolInfo.length;
    }

    function addPool(uint256 _allocationPoints, IERC20 _token) public ownerOnly()
    {

        require (address(_token) != address(0) && _token != rewardToken && emergencyRecoveryTimestamp == 0);
        require (!existingPools[_token], "Pool exists");
        require (poolInfo.length < maxPoolCount, "Too many pools");
        existingPools[_token] = true;
        massUpdatePools();
        totalAllocationPoints = totalAllocationPoints.add(_allocationPoints);
        poolInfo.push(PoolInfo({
            token: _token,
            allocationPoints: _allocationPoints,
            lastTotalReward: totalReward,
            accRewardPerShare: 0
        }));
    }

    function setPoolAllocationPoints(uint256 _poolId, uint256 _allocationPoints) public ownerOnly()
    {

        require (emergencyRecoveryTimestamp == 0);
        massUpdatePools();
        totalAllocationPoints = totalAllocationPoints.sub(poolInfo[_poolId].allocationPoints).add(_allocationPoints);
        poolInfo[_poolId].allocationPoints = _allocationPoints;
    }

    function pendingReward(uint256 _poolId, address _user) external view returns (uint256) 
    {

        PoolInfo storage pool = poolInfo[_poolId];
        UserInfo storage user = userInfo[_poolId][_user];
        uint256 accRewardPerShare = pool.accRewardPerShare;
        uint256 supply = pool.token.balanceOf(address(this));
        uint256 balance = rewardToken.balanceOf(address(this));
        uint256 _totalReward = totalReward;
        if (balance > lastRewardBalance) {
            _totalReward = _totalReward.add(balance.sub(lastRewardBalance));
        }
        if (_totalReward > pool.lastTotalReward && supply != 0) {
            uint256 reward = _totalReward.sub(pool.lastTotalReward).mul(pool.allocationPoints).div(totalAllocationPoints);
            accRewardPerShare = accRewardPerShare.add(reward.mul(1e12).div(supply));
        }
        return user.amountStaked.mul(accRewardPerShare).div(1e12).sub(user.rewardDebt);
    }

    function massUpdatePools() public 
    {

        uint256 length = poolInfo.length;
        for (uint256 poolId = 0; poolId < length; ++poolId) {
            updatePool(poolId);
        }
    }

    function updatePool(uint256 _poolId) public 
    {

        PoolInfo storage pool = poolInfo[_poolId];
        uint256 rewardBalance = rewardToken.balanceOf(address(this));
        if (pool.lastTotalReward == rewardBalance) {
            return;
        }
        uint256 _totalReward = totalReward.add(rewardBalance.sub(lastRewardBalance));
        lastRewardBalance = rewardBalance;
        totalReward = _totalReward;
        uint256 supply = pool.token.balanceOf(address(this));
        if (supply == 0) {
            pool.lastTotalReward = _totalReward;
            return;
        }
        uint256 reward = _totalReward.sub(pool.lastTotalReward).mul(pool.allocationPoints).div(totalAllocationPoints);
        pool.accRewardPerShare = pool.accRewardPerShare.add(reward.mul(1e12).div(supply));
        pool.lastTotalReward = _totalReward;
    }

    function deposit(uint256 _poolId, uint256 _amount) public 
    {

        require (emergencyRecoveryTimestamp == 0, "Withdraw only");
        PoolInfo storage pool = poolInfo[_poolId];
        UserInfo storage user = userInfo[_poolId][msg.sender];
        updatePool(_poolId);
        if (user.amountStaked > 0) {
            uint256 pending = user.amountStaked.mul(pool.accRewardPerShare).div(1e12).sub(user.rewardDebt);
            if (pending > 0) {
                safeRewardTransfer(msg.sender, pending);                
            }
        }
        if (_amount > 0) {
            pool.token.safeTransferFrom(address(msg.sender), address(this), _amount);
            user.amountStaked = user.amountStaked.add(_amount);
        }
        user.rewardDebt = user.amountStaked.mul(pool.accRewardPerShare).div(1e12);
        emit Deposit(msg.sender, _poolId, _amount);
    }

    function withdraw(uint256 _poolId, uint256 _amount) public 
    {

        PoolInfo storage pool = poolInfo[_poolId];
        UserInfo storage user = userInfo[_poolId][msg.sender];
        require(user.amountStaked >= _amount, "Amount more than staked");
        updatePool(_poolId);
        uint256 pending = user.amountStaked.mul(pool.accRewardPerShare).div(1e12).sub(user.rewardDebt);
        if (pending > 0) {
            safeRewardTransfer(msg.sender, pending);
        }
        if (_amount > 0) {
            user.amountStaked = user.amountStaked.sub(_amount);
            pool.token.safeTransfer(address(msg.sender), _amount);
        }
        user.rewardDebt = user.amountStaked.mul(pool.accRewardPerShare).div(1e12);
        emit Withdraw(msg.sender, _poolId, _amount);
    }

    function emergencyWithdraw(uint256 _poolId) public 
    {

        PoolInfo storage pool = poolInfo[_poolId];
        UserInfo storage user = userInfo[_poolId][msg.sender];
        uint256 amount = user.amountStaked;
        user.amountStaked = 0;
        user.rewardDebt = 0;
        pool.token.safeTransfer(address(msg.sender), amount);
        emit EmergencyWithdraw(msg.sender, _poolId, amount);
    }

    function safeRewardTransfer(address _to, uint256 _amount) internal 
    {

        uint256 balance = rewardToken.balanceOf(address(this));
        rewardToken.safeTransfer(_to, _amount > balance ? balance : _amount);
        lastRewardBalance = rewardToken.balanceOf(address(this));
    }

    function declareEmergency() public ownerOnly() 
    {

        emergencyRecoveryTimestamp = block.timestamp + 60*60*24*3;
        emit Emergency();
    }

    function canRecoverTokens(IERC20 token) internal override view returns (bool) 
    { 

        if (emergencyRecoveryTimestamp != 0 && block.timestamp > emergencyRecoveryTimestamp) {
            return true;
        }
        else {
            return token != rewardToken && !existingPools[token];
        }
    }
}// J-J-J-JENGA!!!
pragma solidity ^0.7.4;


contract RootKitVault is Owned
{

    using SafeERC20 for IERC20;
    
    receive() external payable { }

    function sendEther(address payable _to, uint256 _amount) public ownerOnly()
    {

        (bool success,) = _to.call{ value: _amount }("");
        require (success, "Transfer failed");
    }

    function sendToken(IERC20 _token, address _to, uint256 _amount) public ownerOnly()
    {

        _token.safeTransfer(_to, _amount);
    }
}// J-J-J-JENGA!!!
pragma solidity ^0.7.4;



contract Stoneface is Owned, TokensRecoverable, IStoneface
{

    uint256 public immutable override delay;

    IRootKitDistribution public override rootKitDistribution;

    TransferOwnership[] _pendingTransferOwnership;
    function pendingTransferOwnership(uint256 index) public override view returns (TransferOwnership memory) { return _pendingTransferOwnership[index]; }

    function pendingTransferOwnershipCount() public override view returns (uint256) { return _pendingTransferOwnership.length; }


    constructor(uint256 _delay)
    {
        delay = _delay;
    }

    function watchDistribution(IRootKitDistribution _rootKitDistribution) public override ownerOnly()
    {

        require (address(rootKitDistribution) == address(0), "Can only be set once");
        rootKitDistribution = _rootKitDistribution;
    }

    function callTransferOwnership(IOwned target, address newOwner) public override ownerOnly()
    {

        TransferOwnership memory pending;
        pending.target = target;
        pending.newOwner = newOwner;
        pending.when = block.timestamp + delay;
        _pendingTransferOwnership.push(pending);
        emit PendingOwnershipTransfer(target, newOwner, pending.when);
    }

    function callTransferOwnershipNow(uint256 index) public override ownerOnly()
    {

        require (_pendingTransferOwnership[index].when <= block.timestamp, "Too early");
        require (address(rootKitDistribution) == address(0) || rootKitDistribution.distributionComplete(), "Distribution not yet complete");
        _pendingTransferOwnership[index].target.transferOwnership(_pendingTransferOwnership[index].newOwner);
        _pendingTransferOwnership[index] = _pendingTransferOwnership[_pendingTransferOwnership.length - 1];
        _pendingTransferOwnership.pop();
    }

    function callClaimOwnership(IOwned target) public override ownerOnly()
    {

        target.claimOwnership();
    }
}// J-J-J-JENGA!!!
pragma solidity ^0.7.4;


contract WETH9 is IWETH
{

    string public override name     = "Wrapped Ether";
    string public override symbol   = "WETH";
    uint8  public override decimals = 18;

    mapping (address => uint)                       public override balanceOf;
    mapping (address => mapping (address => uint))  public override allowance;

    receive() external payable {
        deposit();
    }
    function deposit() public payable override {

        balanceOf[msg.sender] += msg.value;
        emit Deposit(msg.sender, msg.value);
    }
    function withdraw(uint wad) public override {

        require(balanceOf[msg.sender] >= wad, "weth a: not enough balance");
        balanceOf[msg.sender] -= wad;
        msg.sender.transfer(wad);
        emit Withdrawal(msg.sender, wad);
    }

    function totalSupply() public override view returns (uint) {

        return address(this).balance;
    }

    function approve(address guy, uint wad) public override returns (bool) {

        allowance[msg.sender][guy] = wad;
        emit Approval(msg.sender, guy, wad);
        return true;
    }

    function transfer(address dst, uint wad) public override returns (bool) {

        return transferFrom(msg.sender, dst, wad);
    }

    function transferFrom(address src, address dst, uint wad)
        public
        override
        returns (bool)
    {

        require(balanceOf[src] >= wad, "weth b: not enough balance");

        if (src != msg.sender && allowance[src][msg.sender] != uint(-1)) {
            require(allowance[src][msg.sender] >= wad, "weth c: not enough allowance");
            allowance[src][msg.sender] -= wad;
        }

        balanceOf[src] -= wad;
        balanceOf[dst] += wad;

        emit Transfer(src, dst, wad);

        return true;
    }
}