
pragma solidity ^0.8.0;

interface IERC20 {

    function totalSupply() external view returns (uint256);


    function balanceOf(address account) external view returns (uint256);


    function transfer(address recipient, uint256 amount) external returns (bool);


    function allowance(address owner, address spender) external view returns (uint256);


    function approve(address spender, uint256 amount) external returns (bool);


    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);


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

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}// MIT

pragma solidity ^0.8.0;


contract ERC20 is Context, IERC20, IERC20Metadata {

    mapping (address => uint256) private _balances;

    mapping (address => mapping (address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;

    constructor (string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
    }

    function name() public view virtual override returns (string memory) {

        return _name;
    }

    function symbol() public view virtual override returns (string memory) {

        return _symbol;
    }

    function decimals() public view virtual override returns (uint8) {

        return 18;
    }

    function totalSupply() public view virtual override returns (uint256) {

        return _totalSupply;
    }

    function balanceOf(address account) public view virtual override returns (uint256) {

        return _balances[account];
    }

    function transfer(address recipient, uint256 amount) public virtual override returns (bool) {

        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function allowance(address owner, address spender) public view virtual override returns (uint256) {

        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public virtual override returns (bool) {

        _approve(_msgSender(), spender, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) public virtual override returns (bool) {

        _transfer(sender, recipient, amount);

        uint256 currentAllowance = _allowances[sender][_msgSender()];
        require(currentAllowance >= amount, "ERC20: transfer amount exceeds allowance");
        _approve(sender, _msgSender(), currentAllowance - amount);

        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {

        _approve(_msgSender(), spender, _allowances[_msgSender()][spender] + addedValue);
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {

        uint256 currentAllowance = _allowances[_msgSender()][spender];
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
        _approve(_msgSender(), spender, currentAllowance - subtractedValue);

        return true;
    }

    function _transfer(address sender, address recipient, uint256 amount) internal virtual {

        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(sender, recipient, amount);

        uint256 senderBalance = _balances[sender];
        require(senderBalance >= amount, "ERC20: transfer amount exceeds balance");
        _balances[sender] = senderBalance - amount;
        _balances[recipient] += amount;

        emit Transfer(sender, recipient, amount);
    }

    function _mint(address account, uint256 amount) internal virtual {

        require(account != address(0), "ERC20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply += amount;
        _balances[account] += amount;
        emit Transfer(address(0), account, amount);
    }

    function _burn(address account, uint256 amount) internal virtual {

        require(account != address(0), "ERC20: burn from the zero address");

        _beforeTokenTransfer(account, address(0), amount);

        uint256 accountBalance = _balances[account];
        require(accountBalance >= amount, "ERC20: burn amount exceeds balance");
        _balances[account] = accountBalance - amount;
        _totalSupply -= amount;

        emit Transfer(account, address(0), amount);
    }

    function _approve(address owner, address spender, uint256 amount) internal virtual {

        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _beforeTokenTransfer(address from, address to, uint256 amount) internal virtual { }

}// MIT

pragma solidity ^0.8.0;

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
}// MIT

pragma solidity ^0.8.0;


library SafeERC20 {
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
        uint256 newAllowance = token.allowance(address(this), spender) + value;
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(IERC20 token, address spender, uint256 value) internal {
        unchecked {
            uint256 oldAllowance = token.allowance(address(this), spender);
            require(oldAllowance >= value, "SafeERC20: decreased allowance below zero");
            uint256 newAllowance = oldAllowance - value;
            _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
        }
    }

    function _callOptionalReturn(IERC20 token, bytes memory data) private {

        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) { // Return data is optional
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}// MIT

pragma solidity ^0.8.0;

abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor () {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
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
}// MIT

pragma solidity ^0.8.0;


abstract contract Pausable is Context {
    event Paused(address account);

    event Unpaused(address account);

    bool private _paused;

    constructor () {
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
}// MIT

pragma solidity ^0.8.0;

abstract contract ReentrancyGuard {

    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor () {
        _status = _NOT_ENTERED;
    }

    modifier nonReentrant() {
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        _status = _ENTERED;

        _;

        _status = _NOT_ENTERED;
    }
}// MIT

pragma solidity ^0.8.0;

library Math {
    function max(uint256 a, uint256 b) internal pure returns (uint256) {
        return a >= b ? a : b;
    }

    function min(uint256 a, uint256 b) internal pure returns (uint256) {
        return a < b ? a : b;
    }

    function average(uint256 a, uint256 b) internal pure returns (uint256) {
        return (a / 2) + (b / 2) + ((a % 2 + b % 2) / 2);
    }
}// MIT
pragma solidity 0.8.4;

abstract contract Governable {
    address public governance;

    constructor() {
        governance = msg.sender;
    }

    modifier onlyGovernance() {
        require(msg.sender == governance, "only governance");
        _;
    }

    function setGovernance(address _governance) external onlyGovernance {
        require(_governance != address(0), "null governance");
        governance = _governance;
    }
}// MIT
pragma solidity 0.8.4;


abstract contract Salvageable {
    using SafeERC20 for IERC20;

    function _salvage(address[] memory tokens) internal {
        for (uint256 i = 0; i < tokens.length; i++) {
            address token = tokens[i];
            require(canSalvage(token), "token not salvageable");
            uint256 balance = IERC20(token).balanceOf(address(this));
            if (balance > 0) {
                IERC20(token).safeTransfer(msg.sender, balance);
            }
        }
    }

    function canSalvage(address token) public pure virtual returns (bool);
}// MIT
pragma solidity 0.8.4;


interface IChainlinkOracle {
    function latestAnswer() external view returns (uint256);
}

abstract contract PriceGuard {
    event PausePriceGuard(address indexed sender, bool paused);

    uint256 public constant SPREAD_TOLERANCE = 10; // max 10% spread
    address public constant CHAINLINK_ORACLE = address(0x5f4eC3Df9cbd43714FE2740f5E3616155c5b8419);

    bool public priceGuardPaused = false;

    modifier verifyPrice(uint256 priceETHUSD) {
        if (!priceGuardPaused) {
            uint256 oraclePrice = chainlinkPriceETHUSD();
            uint256 min = Math.min(priceETHUSD, oraclePrice);
            uint256 max = Math.max(priceETHUSD, oraclePrice);
            uint256 upperLimit = (min * (SPREAD_TOLERANCE + 100)) / 100;
            require(max <= upperLimit, "PriceOracle ETHUSD");
        }
        _;
    }

    function chainlinkPriceETHUSD() public view returns (uint256) {
        return IChainlinkOracle(CHAINLINK_ORACLE).latestAnswer() / 100; // chainlink answer is 8 decimals
    }

    function _pausePriceGuard(bool _paused) internal {
        priceGuardPaused = _paused;
        emit PausePriceGuard(msg.sender, priceGuardPaused);
    }
}// MIT
pragma solidity 0.8.4;


abstract contract LiquidityNexusBase is Ownable, Pausable, Governable, Salvageable, ReentrancyGuard, PriceGuard {
    using SafeERC20 for IERC20;

    address public constant WETH = address(0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2);
    address public constant USDC = address(0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48);

    function depositCapital(uint256 amount) public onlyOwner {
        IERC20(USDC).safeTransferFrom(msg.sender, address(this), amount);
    }

    function depositAllCapital() external onlyOwner {
        depositCapital(IERC20(USDC).balanceOf(msg.sender));
    }

    function withdrawFreeCapital() public onlyOwner {
        uint256 balance = IERC20(USDC).balanceOf(address(this));
        if (balance > 0) {
            IERC20(USDC).safeTransfer(msg.sender, balance);
        }
    }

    function pause() external onlyOwner {
        _pause();
    }

    function unpause() external onlyOwner {
        _unpause();
    }

    function pausePriceGuard() external onlyOwner {
        _pausePriceGuard(true);
    }

    function unpausePriceGuard() external onlyOwner {
        _pausePriceGuard(false);
    }

    function salvage(address[] memory tokens) external onlyOwner {
        _salvage(tokens);
    }

    receive() external payable {} // solhint-disable-line no-empty-blocks
}// MIT
pragma solidity 0.8.4;

interface IUniswapV2Pair {
    event Approval(address indexed owner, address indexed spender, uint256 value);
    event Transfer(address indexed from, address indexed to, uint256 value);

    function name() external pure returns (string memory);

    function symbol() external pure returns (string memory);

    function decimals() external pure returns (uint8);

    function totalSupply() external view returns (uint256);

    function balanceOf(address owner) external view returns (uint256);

    function allowance(address owner, address spender) external view returns (uint256);

    function approve(address spender, uint256 value) external returns (bool);

    function transfer(address to, uint256 value) external returns (bool);

    function transferFrom(
        address from,
        address to,
        uint256 value
    ) external returns (bool);

    function DOMAIN_SEPARATOR() external view returns (bytes32);

    function PERMIT_TYPEHASH() external pure returns (bytes32);

    function nonces(address owner) external view returns (uint256);

    function permit(
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external;

    event Mint(address indexed sender, uint256 amount0, uint256 amount1);
    event Burn(address indexed sender, uint256 amount0, uint256 amount1, address indexed to);
    event Swap(
        address indexed sender,
        uint256 amount0In,
        uint256 amount1In,
        uint256 amount0Out,
        uint256 amount1Out,
        address indexed to
    );
    event Sync(uint112 reserve0, uint112 reserve1);

    function MINIMUM_LIQUIDITY() external pure returns (uint256);

    function factory() external view returns (address);

    function token0() external view returns (address);

    function token1() external view returns (address);

    function getReserves()
        external
        view
        returns (
            uint112 reserve0,
            uint112 reserve1,
            uint32 blockTimestampLast
        );

    function price0CumulativeLast() external view returns (uint256);

    function price1CumulativeLast() external view returns (uint256);

    function kLast() external view returns (uint256);

    function mint(address to) external returns (uint256 liquidity);

    function burn(address to) external returns (uint256 amount0, uint256 amount1);

    function swap(
        uint256 amount0Out,
        uint256 amount1Out,
        address to,
        bytes calldata data
    ) external;

    function skim(address to) external;

    function sync() external;

    function initialize(address, address) external;
}

interface IUniswapV2Router01 {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);

    function addLiquidity(
        address tokenA,
        address tokenB,
        uint256 amountADesired,
        uint256 amountBDesired,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline
    )
        external
        returns (
            uint256 amountA,
            uint256 amountB,
            uint256 liquidity
        );

    function addLiquidityETH(
        address token,
        uint256 amountTokenDesired,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    )
        external
        payable
        returns (
            uint256 amountToken,
            uint256 amountETH,
            uint256 liquidity
        );

    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint256 liquidity,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountA, uint256 amountB);

    function removeLiquidityETH(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountToken, uint256 amountETH);

    function removeLiquidityWithPermit(
        address tokenA,
        address tokenB,
        uint256 liquidity,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline,
        bool approveMax,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external returns (uint256 amountA, uint256 amountB);

    function removeLiquidityETHWithPermit(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline,
        bool approveMax,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external returns (uint256 amountToken, uint256 amountETH);

    function swapExactTokensForTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapTokensForExactTokens(
        uint256 amountOut,
        uint256 amountInMax,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapExactETHForTokens(
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable returns (uint256[] memory amounts);

    function swapTokensForExactETH(
        uint256 amountOut,
        uint256 amountInMax,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapExactTokensForETH(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapETHForExactTokens(
        uint256 amountOut,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable returns (uint256[] memory amounts);

    function quote(
        uint256 amountA,
        uint256 reserveA,
        uint256 reserveB
    ) external pure returns (uint256 amountB);

    function getAmountOut(
        uint256 amountIn,
        uint256 reserveIn,
        uint256 reserveOut
    ) external pure returns (uint256 amountOut);

    function getAmountIn(
        uint256 amountOut,
        uint256 reserveIn,
        uint256 reserveOut
    ) external pure returns (uint256 amountIn);

    function getAmountsOut(uint256 amountIn, address[] calldata path) external view returns (uint256[] memory amounts);

    function getAmountsIn(uint256 amountOut, address[] calldata path) external view returns (uint256[] memory amounts);
}

interface IUniswapV2Router02 is IUniswapV2Router01 {
    function removeLiquidityETHSupportingFeeOnTransferTokens(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountETH);

    function removeLiquidityETHWithPermitSupportingFeeOnTransferTokens(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline,
        bool approveMax,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external returns (uint256 amountETH);

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;

    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable;

    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;
}

interface IUniswapV2Factory {
    event PairCreated(address indexed token0, address indexed token1, address pair, uint256);

    function feeTo() external view returns (address);

    function feeToSetter() external view returns (address);

    function migrator() external view returns (address);

    function getPair(address tokenA, address tokenB) external view returns (address pair);

    function allPairs(uint256) external view returns (address pair);

    function allPairsLength() external view returns (uint256);

    function createPair(address tokenA, address tokenB) external returns (address pair);

    function setFeeTo(address) external;

    function setFeeToSetter(address) external;

    function setMigrator(address) external;
}

interface IERC20Uniswap {
    event Approval(address indexed owner, address indexed spender, uint256 value);
    event Transfer(address indexed from, address indexed to, uint256 value);

    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);

    function totalSupply() external view returns (uint256);

    function balanceOf(address owner) external view returns (uint256);

    function allowance(address owner, address spender) external view returns (uint256);

    function approve(address spender, uint256 value) external returns (bool);

    function transfer(address to, uint256 value) external returns (bool);

    function transferFrom(
        address from,
        address to,
        uint256 value
    ) external returns (bool);
}

interface IWETH {
    function deposit() external payable;

    function transfer(address to, uint256 value) external returns (bool);

    function withdraw(uint256) external;
}// MIT
pragma solidity 0.8.4;

interface IMasterChef {
    function deposit(uint256 _pid, uint256 _amount) external;

    function withdraw(uint256 _pid, uint256 _amount) external;

    function emergencyWithdraw(uint256 _pid) external;

    function userInfo(uint256 _pid, address _user) external view returns (uint256 amount, uint256 rewardDebt);

    function poolInfo(uint256 _pid)
        external
        view
        returns (
            address lpToken,
            uint256,
            uint256,
            uint256
        );

    function massUpdatePools() external;
}// MIT
pragma solidity 0.8.4;


abstract contract SushiswapIntegration is Salvageable, LiquidityNexusBase {
    using SafeERC20 for IERC20;

    address public constant SLP = address(0x397FF1542f962076d0BFE58eA045FfA2d347ACa0); // Sushiswap USDC/ETH pair
    address public constant ROUTER = address(0xd9e1cE17f2641f24aE83637ab66a2cca9C378B9F); // Sushiswap Router2
    address public constant MASTERCHEF = address(0xc2EdaD668740f1aA35E4D8f227fB8E17dcA888Cd);
    address public constant REWARD = address(0x6B3595068778DD592e39A122f4f5a5cF09C90fE2);
    uint256 public constant POOL_ID = 1;
    address[] public pathToETH = new address[](2);
    address[] public pathToUSDC = new address[](2);

    constructor() {
        pathToUSDC[0] = WETH;
        pathToUSDC[1] = USDC;
        pathToETH[0] = USDC;
        pathToETH[1] = WETH;

        IERC20(USDC).safeApprove(ROUTER, type(uint256).max);
        IERC20(WETH).safeApprove(ROUTER, type(uint256).max);
        IERC20(SLP).safeApprove(ROUTER, type(uint256).max);

        IERC20(SLP).safeApprove(MASTERCHEF, type(uint256).max);
    }

    function quote(uint256 inETH) public view returns (uint256 outUSDC) {
        (uint112 rUSDC, uint112 rETH, ) = IUniswapV2Pair(SLP).getReserves();
        outUSDC = IUniswapV2Router02(ROUTER).quote(inETH, rETH, rUSDC);
    }

    function quoteInverse(uint256 inUSDC) public view returns (uint256 outETH) {
        (uint112 rUSDC, uint112 rETH, ) = IUniswapV2Pair(SLP).getReserves();
        outETH = IUniswapV2Router02(ROUTER).quote(inUSDC, rUSDC, rETH);
    }

    function amountInETHForRequestedOutUSDC(uint256 outUSDC) public view returns (uint256 inETH) {
        inETH = IUniswapV2Router02(ROUTER).getAmountsIn(outUSDC, pathToUSDC)[0];
    }

    function _swapExactUSDCForETH(uint256 inUSDC) internal returns (uint256 outETH) {
        if (inUSDC == 0) return 0;

        uint256[] memory amounts =
            IUniswapV2Router02(ROUTER).swapExactTokensForTokens(inUSDC, 0, pathToETH, address(this), block.timestamp); // solhint-disable-line not-rely-on-time
        require(inUSDC == amounts[0], "leftover USDC");
        outETH = amounts[1];
    }

    function _swapExactETHForUSDC(uint256 inETH) internal returns (uint256 outUSDC) {
        if (inETH == 0) return 0;

        uint256[] memory amounts =
            IUniswapV2Router02(ROUTER).swapExactTokensForTokens(
                inETH,
                0,
                pathToUSDC,
                address(this),
                block.timestamp // solhint-disable-line not-rely-on-time
            );
        require(inETH == amounts[0], "leftover ETH");
        outUSDC = amounts[1];
    }

    function _addLiquidityAndStake(uint256 amountETH, uint256 deadline)
        internal
        returns (
            uint256 addedUSDC,
            uint256 addedETH,
            uint256 liquidity
        )
    {
        require(IERC20(WETH).balanceOf(address(this)) >= amountETH, "not enough WETH");
        uint256 quotedUSDC = quote(amountETH);
        require(IERC20(USDC).balanceOf(address(this)) >= quotedUSDC, "not enough free capital");

        (addedETH, addedUSDC, liquidity) = IUniswapV2Router02(ROUTER).addLiquidity(
            WETH,
            USDC,
            amountETH,
            quotedUSDC,
            amountETH,
            0,
            address(this),
            deadline
        );
        require(addedETH == amountETH, "leftover ETH");

        IMasterChef(MASTERCHEF).deposit(POOL_ID, liquidity);
    }

    function _unstakeAndRemoveLiquidity(uint256 liquidity, uint256 deadline)
        internal
        returns (uint256 removedETH, uint256 removedUSDC)
    {
        if (liquidity == 0) return (0, 0);

        IMasterChef(MASTERCHEF).withdraw(POOL_ID, liquidity);

        (removedETH, removedUSDC) = IUniswapV2Router02(ROUTER).removeLiquidity(
            WETH,
            USDC,
            liquidity,
            0,
            0,
            address(this),
            deadline
        );
    }

    function _claimRewards() internal {
        IMasterChef(MASTERCHEF).deposit(POOL_ID, 0);
    }

    function canSalvage(address token) public pure override returns (bool) {
        return token != WETH && token != USDC && token != SLP && token != REWARD;
    }
}// MIT
pragma solidity 0.8.4;


abstract contract RebalancingStrategy1 is SushiswapIntegration {
    function applyRebalance(
        uint256 removedUSDC,
        uint256 removedETH,
        uint256 entryUSDC,
        uint256 //entryETH
    ) internal returns (uint256 exitUSDC, uint256 exitETH) {
        if (removedUSDC > entryUSDC) {
            uint256 deltaUSDC = removedUSDC - entryUSDC;
            exitETH = removedETH + _swapExactUSDCForETH(deltaUSDC);
            exitUSDC = entryUSDC;
        } else {
            uint256 deltaUSDC = entryUSDC - removedUSDC;
            uint256 deltaETH = Math.min(removedETH, amountInETHForRequestedOutUSDC(deltaUSDC));
            exitUSDC = removedUSDC + _swapExactETHForUSDC(deltaETH);
            exitETH = removedETH - deltaETH;
        }
    }
}// MIT
pragma solidity 0.8.4;


contract NexusLPSushi is ERC20("Nexus LP SushiSwap ETH/USDC", "NSLP"), RebalancingStrategy1 {
    using SafeERC20 for IERC20;

    event Mint(address indexed sender, address indexed beneficiary, uint256 shares);
    event Burn(address indexed sender, address indexed beneficiary, uint256 shares);
    event Pair(
        address indexed sender,
        address indexed minter,
        uint256 pairedUSDC,
        uint256 pairedETH,
        uint256 liquidity
    );
    event Unpair(address indexed sender, address indexed minter, uint256 exitUSDC, uint256 exitETH, uint256 liquidity);
    event ClaimRewards(address indexed sender, uint256 amount);
    event CompoundProfits(address indexed sender, uint256 liquidity);

    struct Minter {
        uint256 pairedETH;
        uint256 pairedUSDC;
        uint256 pairedShares; // Nexus LP tokens that represent ETH paired with USDC to create Sushi LP
        uint256 unpairedETH;
        uint256 unpairedShares; // Nexus LP tokens that represent standalone ETH (waiting in this contract's balance)
    }

    uint256 public totalLiquidity;
    uint256 public totalPairedUSDC;
    uint256 public totalPairedETH;
    uint256 public totalPairedShares;
    mapping(address => Minter) public minters;

    function availableSpaceToDepositETH() external view returns (uint256 amountETH) {
        return quoteInverse(IERC20(USDC).balanceOf(address(this)));
    }

    function pricePerFullShare() external view returns (uint256) {
        if (totalPairedShares == 0) return 0;
        return (1 ether * totalLiquidity) / totalPairedShares;
    }

    function addLiquidityETH(address beneficiary, uint256 deadline)
        external
        payable
        nonReentrant
        whenNotPaused
        verifyPrice(quote(1 ether))
    {
        uint256 amountETH = msg.value;
        IWETH(WETH).deposit{value: amountETH}();
        _deposit(beneficiary, amountETH, deadline);
    }

    function addLiquidity(
        address beneficiary,
        uint256 amountETH,
        uint256 deadline
    ) external nonReentrant whenNotPaused verifyPrice(quote(1 ether)) {
        IERC20(WETH).safeTransferFrom(msg.sender, address(this), amountETH);
        _deposit(beneficiary, amountETH, deadline);
    }

    function removeLiquidityETH(
        address payable beneficiary,
        uint256 shares,
        uint256 deadline
    ) external nonReentrant verifyPrice(quote(1 ether)) returns (uint256 exitETH) {
        exitETH = _withdraw(msg.sender, beneficiary, shares, deadline);
        IWETH(WETH).withdraw(exitETH);
        Address.sendValue(beneficiary, exitETH);
    }

    function removeLiquidity(
        address beneficiary,
        uint256 shares,
        uint256 deadline
    ) external nonReentrant verifyPrice(quote(1 ether)) returns (uint256 exitETH) {
        exitETH = _withdraw(msg.sender, beneficiary, shares, deadline);
        IERC20(WETH).safeTransfer(beneficiary, exitETH);
    }

    function removeAllLiquidityETH(address payable beneficiary, uint256 deadline)
        external
        nonReentrant
        verifyPrice(quote(1 ether))
        returns (uint256 exitETH)
    {
        exitETH = _withdraw(msg.sender, beneficiary, balanceOf(msg.sender), deadline);
        require(exitETH <= IERC20(WETH).balanceOf(address(this)), "not enough ETH");
        IWETH(WETH).withdraw(exitETH);
        Address.sendValue(beneficiary, exitETH);
    }

    function removeAllLiquidity(address beneficiary, uint256 deadline)
        external
        nonReentrant
        verifyPrice(quote(1 ether))
        returns (uint256 exitETH)
    {
        exitETH = _withdraw(msg.sender, beneficiary, balanceOf(msg.sender), deadline);
        IERC20(WETH).safeTransfer(beneficiary, exitETH);
    }

    function claimRewards() external nonReentrant onlyGovernance {
        _claimRewards();
        uint256 amount = IERC20(REWARD).balanceOf(address(this));
        IERC20(REWARD).safeTransfer(msg.sender, amount);

        emit ClaimRewards(msg.sender, amount);
    }

    function compoundProfits(uint256 amountETH, uint256 capitalProviderRewardPercentmil)
        external
        nonReentrant
        onlyGovernance
        returns (
            uint256 pairedUSDC,
            uint256 pairedETH,
            uint256 liquidity
        )
    {
        IERC20(WETH).safeTransferFrom(msg.sender, address(this), amountETH);

        if (capitalProviderRewardPercentmil > 0) {
            uint256 ownerETH = (amountETH * capitalProviderRewardPercentmil) / 100_000;
            _swapExactETHForUSDC(ownerETH);
            amountETH -= ownerETH;
        }

        amountETH /= 2;
        _swapExactETHForUSDC(amountETH);

        (pairedUSDC, pairedETH, liquidity) = _addLiquidityAndStake(amountETH, block.timestamp); // solhint-disable-line not-rely-on-time
        totalPairedUSDC += pairedUSDC;
        totalPairedETH += pairedETH;
        totalLiquidity += liquidity;

        emit CompoundProfits(msg.sender, liquidity);
    }

    function _deposit(
        address beneficiary,
        uint256 amountETH,
        uint256 deadline
    ) private {
        uint256 shares = _pair(beneficiary, amountETH, deadline);
        _mint(beneficiary, shares);
        emit Mint(msg.sender, beneficiary, shares);
    }

    function _pair(
        address minterAddress,
        uint256 amountETH,
        uint256 deadline
    ) private returns (uint256 shares) {
        (uint256 pairedUSDC, uint256 pairedETH, uint256 liquidity) = _addLiquidityAndStake(amountETH, deadline);

        if (totalPairedShares == 0) {
            shares = liquidity;
        } else {
            shares = (liquidity * totalPairedShares) / totalLiquidity;
        }

        Minter storage minter = minters[minterAddress];
        minter.pairedUSDC += pairedUSDC;
        minter.pairedETH += pairedETH;
        minter.pairedShares += shares;

        totalPairedUSDC += pairedUSDC;
        totalPairedETH += pairedETH;
        totalPairedShares += shares;
        totalLiquidity += liquidity;

        emit Pair(msg.sender, minterAddress, pairedUSDC, pairedETH, liquidity);
    }

    function _withdraw(
        address sender,
        address beneficiary,
        uint256 shares,
        uint256 deadline
    ) private returns (uint256 exitETH) {
        Minter storage minter = minters[sender];
        shares = Math.min(shares, minter.pairedShares + minter.unpairedShares);
        require(shares > 0, "sender not in minters");

        if (shares > minter.unpairedShares) {
            _unpair(sender, shares - minter.unpairedShares, deadline);
        }

        exitETH = (shares * minter.unpairedETH) / minter.unpairedShares;
        minter.unpairedETH -= exitETH;
        minter.unpairedShares -= shares;

        _burn(sender, shares);
        emit Burn(sender, beneficiary, shares);
    }

    function _unpair(
        address minterAddress,
        uint256 shares,
        uint256 deadline
    ) private {
        uint256 liquidity = (shares * totalLiquidity) / totalPairedShares;
        (uint256 removedETH, uint256 removedUSDC) = _unstakeAndRemoveLiquidity(liquidity, deadline);

        Minter storage minter = minters[minterAddress];
        uint256 pairedUSDC = (minter.pairedUSDC * shares) / minter.pairedShares;
        uint256 pairedETH = (minter.pairedETH * shares) / minter.pairedShares;
        (uint256 exitUSDC, uint256 exitETH) = applyRebalance(removedUSDC, removedETH, pairedUSDC, pairedETH);

        minter.pairedUSDC -= pairedUSDC;
        minter.pairedETH -= pairedETH;
        minter.pairedShares -= shares;

        minter.unpairedETH += exitETH;
        minter.unpairedShares += shares;

        totalPairedUSDC -= pairedUSDC;
        totalPairedETH -= pairedETH;
        totalPairedShares -= shares;
        totalLiquidity -= liquidity;

        emit Unpair(msg.sender, minterAddress, exitUSDC, exitETH, liquidity);
    }

    function emergencyExit(address[] memory minterAddresses) external onlyOwner {
        for (uint256 i = 0; i < minterAddresses.length; i++) {
            address minterAddress = minterAddresses[i];
            Minter storage minter = minters[minterAddress];
            uint256 shares = minter.pairedShares;
            if (shares > 0) {
                _unpair(minterAddress, shares, block.timestamp); //solhint-disable-line not-rely-on-time
            }
        }

        withdrawFreeCapital();
    }
}