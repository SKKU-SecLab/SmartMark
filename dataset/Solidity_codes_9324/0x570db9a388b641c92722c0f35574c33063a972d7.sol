
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

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}// MIT

pragma solidity ^0.8.0;


contract ERC20 is Context, IERC20, IERC20Metadata {

    mapping(address => uint256) private _balances;

    mapping(address => mapping(address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;

    constructor(string memory name_, string memory symbol_) {
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

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public virtual override returns (bool) {

        _transfer(sender, recipient, amount);

        uint256 currentAllowance = _allowances[sender][_msgSender()];
        require(currentAllowance >= amount, "ERC20: transfer amount exceeds allowance");
        unchecked {
            _approve(sender, _msgSender(), currentAllowance - amount);
        }

        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {

        _approve(_msgSender(), spender, _allowances[_msgSender()][spender] + addedValue);
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {

        uint256 currentAllowance = _allowances[_msgSender()][spender];
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
        unchecked {
            _approve(_msgSender(), spender, currentAllowance - subtractedValue);
        }

        return true;
    }

    function _transfer(
        address sender,
        address recipient,
        uint256 amount
    ) internal virtual {

        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(sender, recipient, amount);

        uint256 senderBalance = _balances[sender];
        require(senderBalance >= amount, "ERC20: transfer amount exceeds balance");
        unchecked {
            _balances[sender] = senderBalance - amount;
        }
        _balances[recipient] += amount;

        emit Transfer(sender, recipient, amount);

        _afterTokenTransfer(sender, recipient, amount);
    }

    function _mint(address account, uint256 amount) internal virtual {

        require(account != address(0), "ERC20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply += amount;
        _balances[account] += amount;
        emit Transfer(address(0), account, amount);

        _afterTokenTransfer(address(0), account, amount);
    }

    function _burn(address account, uint256 amount) internal virtual {

        require(account != address(0), "ERC20: burn from the zero address");

        _beforeTokenTransfer(account, address(0), amount);

        uint256 accountBalance = _balances[account];
        require(accountBalance >= amount, "ERC20: burn amount exceeds balance");
        unchecked {
            _balances[account] = accountBalance - amount;
        }
        _totalSupply -= amount;

        emit Transfer(account, address(0), amount);

        _afterTokenTransfer(account, address(0), amount);
    }

    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {

        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}


    function _afterTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}

}// MIT

pragma solidity ^0.8.0;


abstract contract ERC20Burnable is Context, ERC20 {
    function burn(uint256 amount) public virtual {
        _burn(_msgSender(), amount);
    }

    function burnFrom(address account, uint256 amount) public virtual {
        uint256 currentAllowance = allowance(account, _msgSender());
        require(currentAllowance >= amount, "ERC20: burn amount exceeds allowance");
        unchecked {
            _approve(account, _msgSender(), currentAllowance - amount);
        }
        _burn(account, amount);
    }
}// MIT

pragma solidity ^0.8.0;


abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor() {
        _transferOwnership(_msgSender());
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }

    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
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
        return verifyCallResult(success, returndata, errorMessage);
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
        return verifyCallResult(success, returndata, errorMessage);
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
        return verifyCallResult(success, returndata, errorMessage);
    }

    function verifyCallResult(
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) internal pure returns (bytes memory) {
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
}pragma solidity >=0.5.0;

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
}pragma solidity >=0.5.0;

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
}pragma solidity >=0.6.2;

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
}pragma solidity >=0.6.2;


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
}// MIT

pragma solidity ^0.8.0;


library SafeMath {
    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            uint256 c = a + b;
            if (c < a) return (false, 0);
            return (true, c);
        }
    }

    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b > a) return (false, 0);
            return (true, a - b);
        }
    }

    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (a == 0) return (true, 0);
            uint256 c = a * b;
            if (c / a != b) return (false, 0);
            return (true, c);
        }
    }

    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a / b);
        }
    }

    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a % b);
        }
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        return a + b;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return a - b;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        return a * b;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return a / b;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return a % b;
    }

    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b <= a, errorMessage);
            return a - b;
        }
    }

    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a / b;
        }
    }

    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a % b;
        }
    }
}// UNLICENSED

pragma solidity 0.8.4;



contract FoundersTimelock is Ownable {

    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    event TokensReleased(address token, uint256 amount);

    address private immutable _beneficiary;

    IERC20 private immutable _token;

    uint256 private immutable _cliff; // cliff period in seconds
    uint256 private immutable _vestingPeriod; // ie: 1 month
    uint8 private immutable _vestingDuration; // ie: 10 (vesting will last for 10 months and release linearly every month)

    uint256 private _released = 0;

    constructor (IERC20 token_, address beneficiary_, uint256 cliffDuration_, uint256 vestingPeriod_, uint8 vestingDuration_) {
        require(beneficiary_ != address(0), "FoundersTimelock: beneficiary is the zero address");
        require(vestingPeriod_ > 0, "FoundersTimelock: vestingPeriod is 0");
        require(vestingDuration_ > 0, "FoundersTimelock: vestingDuration is 0");
        require(vestingDuration_ < 256, "FoundersTimelock: vestingDuration is bigger than 255");

        _token = token_;
        _beneficiary = beneficiary_;
        _cliff = block.timestamp.add(cliffDuration_); // safe the use with the 15-seconds rule 
        _vestingPeriod = vestingPeriod_;
        _vestingDuration = vestingDuration_;
    }

    function beneficiary() external view returns (address) {
        return _beneficiary;
    }

    function cliff() external view returns (uint256) {
        return _cliff;
    }

    function vestingPeriod() external view returns (uint256) {
        return _vestingPeriod;
    }

    function vestingDuration() external view returns (uint256) {
        return _vestingDuration;
    }

    function releasedBalance() external view returns (uint256) {
        return _released;
    }

    function lockedBalance() external view returns (uint256) {
        return _token.balanceOf(address(this));
    }


    function release() external {
        require (msg.sender == _beneficiary, "FoundersTimelock: only beneficiary can release tokens");

        uint256 unreleased = _releasableAmount();

        require(unreleased > 0, "FoundersTimelock: no tokens are due");

        _released = _released + unreleased;

        _token.safeTransfer(_beneficiary, unreleased);

        emit TokensReleased(address(_token), unreleased);
    }

    function _releasableAmount() private view returns (uint256) {
        return _vestedAmount().sub(_released);
    }

    function _vestedAmount() private view returns (uint256) {
        uint256 currentBalance = _token.balanceOf(address(this));
        uint256 totalBalance = currentBalance.add(_released);

        if (block.timestamp < _cliff) {
            return 0;
        } else if (block.timestamp >= _cliff.add(_vestingDuration * _vestingPeriod)) { // solhint-disable-line not-rely-on-time
            return totalBalance;
        } else {
            uint256 vestingElapsed = block.timestamp.sub(_cliff);
            uint256 vestingStep = (vestingElapsed / _vestingPeriod) + 1; // Round up
            if(vestingStep > _vestingDuration) {
                vestingStep = _vestingDuration;
            }
            return totalBalance.mul(vestingStep).div(_vestingDuration);
        }
    }
}// UNLICENSED

pragma solidity 0.8.4;





contract ScratchToken is Context, IERC20, Ownable {

    using Address for address;

    string private constant _NAME = "ScratchToken";
    string private constant _SYMBOL = "SCRATCH";
    uint8 private constant _DECIMALS = 9;
    uint256 private constant _MAX_SUPPLY = 100 * 10**15 * 10 ** _DECIMALS;
    uint256 private _totalSupply;
    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;

    uint256 private constant _PERCENTAGE_RELATIVE_TO = 10000;

    uint256 private constant _DIST_BURN_PERCENTAGE = 1850;
    uint256 private constant _DIST_FOUNDER1_PERCENTAGE = 250;
    uint256 private constant _DIST_FOUNDER2_PERCENTAGE = 250;
    uint256 private constant _DIST_FOUNDER3_PERCENTAGE = 250;
    uint256 private constant _DIST_FOUNDER4_PERCENTAGE = 250;
    uint256 private constant _DIST_FOUNDER5_PERCENTAGE = 250;
    uint256 private constant _DIST_EXCHANGE_PERCENTAGE = 750;
    uint256 private constant _DIST_DEV_PERCENTAGE = 500;
    uint256 private constant _DIST_OPS_PERCENTAGE = 150;

    uint256 private constant _FOUNDERS_CLIFF_DURATION = 30 days * 6; // 6 months
    uint256 private constant _FOUNDERS_VESTING_PERIOD = 30 days; // Release every 30 days
    uint8 private constant _FOUNDERS_VESTING_DURATION = 10; // Linear release 10 times every 30 days
    mapping(address => FoundersTimelock) public foundersTimelocks;
    event FounderLiquidityLocked (
        address wallet,
        address timelockContract,
        uint256 tokensAmount
    );

    uint256 private constant _TAX_NORMAL_DEV_PERCENTAGE = 200;
    uint256 private constant _TAX_NORMAL_LIQUIDITY_PERCENTAGE = 200;
    uint256 private constant _TAX_NORMAL_OPS_PERCENTAGE = 100;
    uint256 private constant _TAX_NORMAL_ARCHA_PERCENTAGE = 100;
    uint256 private constant _TAX_EXTRA_LIQUIDITY_PERCENTAGE = 1000;
    uint256 private constant _TAX_EXTRA_BURN_PERCENTAGE = 500;
    uint256 private constant _TAX_EXTRA_DEV_PERCENTAGE = 500;
    uint256 private constant _TOKEN_STABILITY_PROTECTION_THRESHOLD_PERCENTAGE = 200;

    bool private _devFeeEnabled = true;
    bool private _opsFeeEnabled = true;
    bool private _liquidityFeeEnabled = true;
    bool private _archaFeeEnabled = true;
    bool private _burnFeeEnabled = true;
    bool private _tokenStabilityProtectionEnabled = true;

    mapping (address => bool) private _isExcludedFromFee;
    address private immutable _developmentWallet;
    address private _operationsWallet;
    address private _archaWallet;
    uint256 private _devFeePendingSwap = 0;
    uint256 private _opsFeePendingSwap = 0;
    uint256 private _liquidityFeePendingSwap = 0;

    uint256 private constant _UNISWAP_DEADLINE_DELAY = 60; // in seconds
    IUniswapV2Router02 private _uniswapV2Router;
    IUniswapV2Pair private _uniswapV2Pair;
    address private immutable _lpTokensWallet;
    bool private _inSwap = false; // Whether a previous call of swap process is still in process.
    bool private _swapAndLiquifyEnabled = true;
    uint256 private _minTokensBeforeSwapAndLiquify = 1 * 10 ** _DECIMALS;
    address private _liquidityWallet = 0x0000000000000000000000000000000000000000;

    event SwapAndLiquify(
        uint256 tokensSwapped,
        uint256 ethReceived,
        uint256 tokensAddedToLiquidity
    );
    event SwapAndLiquifyEnabledUpdated(bool enabled);
    event MinTokensBeforeSwapUpdated(uint256 minTokensBeforeSwap);
    event DevFeeEnabledUpdated(bool enabled);
    event OpsFeeEnabledUpdated(bool enabled);
    event LiquidityFeeEnabledUpdated(bool enabled);
    event ArchaFeeEnabledUpdated(bool enabled);
    event BurnFeeEnabledUpdated(bool enabled);
    event TokenStabilityProtectionEnabledUpdated(bool enabled);

    event ExclusionFromFeesUpdated(address account, bool isExcluded);
    event ArchaWalletUpdated(address newWallet);
    event LiquidityWalletUpdated(address newWallet);


    modifier lockTheSwap {
        require(!_inSwap, "Currently in swap.");
        _inSwap = true;
        _;
        _inSwap = false;
    }

    receive() external payable {}
    
    constructor (
        address owner,
        address founder1Wallet_,
        address founder2Wallet_,
        address founder3Wallet_,
        address founder4Wallet_,
        address founder5Wallet_,
        address developmentWallet_,
        address exchangeWallet_,
        address operationsWallet_,
        address archaWallet_,
        address uniswapV2RouterAddress_
    ) {

        require(developmentWallet_ != address(0), "ScratchToken: set wallet to the zero address");
        require(exchangeWallet_ != address(0), "ScratchToken: set wallet to the zero address");
        require(operationsWallet_ != address(0), "ScratchToken: set wallet to the zero address");
        require(archaWallet_ != address(0), "ScratchToken: set wallet to the zero address");

        _isExcludedFromFee[owner] = true;
        _isExcludedFromFee[address(this)] = true;
        _isExcludedFromFee[founder1Wallet_] = true;
        _isExcludedFromFee[founder2Wallet_] = true;
        _isExcludedFromFee[founder3Wallet_] = true;
        _isExcludedFromFee[founder4Wallet_] = true;
        _isExcludedFromFee[founder5Wallet_] = true;
        _isExcludedFromFee[developmentWallet_] = true;
        _isExcludedFromFee[exchangeWallet_] = true;
        _isExcludedFromFee[operationsWallet_] = true;
        _isExcludedFromFee[archaWallet_] = true;

        _lockFounderLiquidity(founder1Wallet_, _DIST_FOUNDER1_PERCENTAGE);
        _lockFounderLiquidity(founder2Wallet_, _DIST_FOUNDER2_PERCENTAGE);
        _lockFounderLiquidity(founder3Wallet_, _DIST_FOUNDER3_PERCENTAGE);
        _lockFounderLiquidity(founder4Wallet_, _DIST_FOUNDER4_PERCENTAGE);
        _lockFounderLiquidity(founder5Wallet_, _DIST_FOUNDER5_PERCENTAGE);
        _mint(exchangeWallet_, _getAmountToDistribute(_DIST_EXCHANGE_PERCENTAGE));
        _lpTokensWallet = exchangeWallet_;
        _mint(developmentWallet_, _getAmountToDistribute(_DIST_DEV_PERCENTAGE));
        _developmentWallet = developmentWallet_;
        _mint(operationsWallet_, _getAmountToDistribute(_DIST_OPS_PERCENTAGE));
        _operationsWallet = operationsWallet_;
        _archaWallet = archaWallet_;
        uint256 burnAmount = _getAmountToDistribute(_DIST_BURN_PERCENTAGE);
        emit Transfer(address(0), address(0), burnAmount);
        _mint(owner, _MAX_SUPPLY - totalSupply() - burnAmount);

        _initSwap(uniswapV2RouterAddress_);

        transferOwnership(owner);
    }

    function _getAmountToDistribute(uint256 distributionPercentage) private pure returns (uint256) {
        return (_MAX_SUPPLY * distributionPercentage) / _PERCENTAGE_RELATIVE_TO;
    }

    function _lockFounderLiquidity(address wallet, uint256 distributionPercentage) internal {
        FoundersTimelock timelockContract = new FoundersTimelock(this, wallet, _FOUNDERS_CLIFF_DURATION, _FOUNDERS_VESTING_PERIOD, _FOUNDERS_VESTING_DURATION);
        foundersTimelocks[wallet] = timelockContract;
        _isExcludedFromFee[address(timelockContract)] = true;
        _mint(address(timelockContract), _getAmountToDistribute(distributionPercentage));
        emit FounderLiquidityLocked(wallet, address(timelockContract), _getAmountToDistribute(distributionPercentage));
    }

    function isExcludedFromFees(address account) external view returns (bool) {
        return _isExcludedFromFee[account];
    }

    function excludeFromFees(address account, bool isExcluded) external onlyOwner {
        _isExcludedFromFee[account] = isExcluded;
        emit ExclusionFromFeesUpdated(account, isExcluded);
    }
    function archaWallet() external view returns (address) {
        return _archaWallet;
    }
    function setArchaWallet(address newWallet) external onlyOwner {
        require(newWallet != address(0), "ScratchToken: set wallet to the zero address");
        _archaWallet = newWallet;
        emit ArchaWalletUpdated(newWallet);
    }

    function swapAndLiquifyEnabled() external view returns (bool) {
        return _swapAndLiquifyEnabled;
    }

    function enableSwapAndLiquify(bool isEnabled) external onlyOwner {
        _swapAndLiquifyEnabled = isEnabled;
        emit SwapAndLiquifyEnabledUpdated(isEnabled);
    }

    function minTokensBeforeSwapAndLiquify() external view returns (uint256) {
        return _minTokensBeforeSwapAndLiquify;
    }

    function setMinTokensBeforeSwapAndLiquify(uint256 minTokens) external onlyOwner {
        require(minTokens < _totalSupply, "New value must be lower than total supply.");
        _minTokensBeforeSwapAndLiquify = minTokens;
        emit MinTokensBeforeSwapUpdated(minTokens);
    }
    function liquidityWallet() external view returns (address) {
        return _liquidityWallet;
    }
    function setLiquidityWallet(address newWallet) external onlyOwner {
        _isExcludedFromFee[newWallet] = true;
        _liquidityWallet = newWallet;
        emit LiquidityWalletUpdated(newWallet);
    }

    function devFeeEnabled() external view returns (bool) {
        return _devFeeEnabled;
    }

    function enableDevFee(bool isEnabled) external onlyOwner {
        _devFeeEnabled = isEnabled;
        emit DevFeeEnabledUpdated(isEnabled);
    }

    function opsFeeEnabled() external view returns (bool) {
        return _opsFeeEnabled;
    }

    function enableOpsFee(bool isEnabled) external onlyOwner {
        _opsFeeEnabled = isEnabled;
        emit OpsFeeEnabledUpdated(isEnabled);
    }

    function liquidityFeeEnabled() external view returns (bool) {
        return _liquidityFeeEnabled;
    }

    function enableLiquidityFee(bool isEnabled) external onlyOwner {
        _liquidityFeeEnabled = isEnabled;
        emit LiquidityFeeEnabledUpdated(isEnabled);
    }

    function archaFeeEnabled() external view returns (bool) {
        return _archaFeeEnabled;
    }

    function enableArchaFee(bool isEnabled) external onlyOwner {
        _archaFeeEnabled = isEnabled;
        emit ArchaFeeEnabledUpdated(isEnabled);
    }

    function burnFeeEnabled() external view returns (bool) {
        return _burnFeeEnabled;
    }

    function enableBurnFee(bool isEnabled) external onlyOwner {
        _burnFeeEnabled = isEnabled;
        emit BurnFeeEnabledUpdated(isEnabled);
    }

    function tokenStabilityProtectionEnabled() external view returns (bool) {
        return _tokenStabilityProtectionEnabled;
    }

    function enableTokenStabilityProtection(bool isEnabled) external onlyOwner {
        _tokenStabilityProtectionEnabled = isEnabled;
        emit TokenStabilityProtectionEnabledUpdated(isEnabled);
    }

    function devFeePendingSwap() external onlyOwner view returns (uint256) {
        return _devFeePendingSwap;
    }
    function opsFeePendingSwap() external onlyOwner view returns (uint256) {
        return _opsFeePendingSwap;
    }
    function liquidityFeePendingSwap() external onlyOwner view returns (uint256) {
        return _liquidityFeePendingSwap;
    }

    function _initSwap(address routerAddress) private {
        _uniswapV2Router = IUniswapV2Router02(routerAddress);
        address uniswapV2Pair_ = IUniswapV2Factory(_uniswapV2Router.factory())
            .getPair(address(this), _uniswapV2Router.WETH());

        if (uniswapV2Pair_ == address(0)) {
            uniswapV2Pair_ = IUniswapV2Factory(_uniswapV2Router.factory())
                .createPair(address(this), _uniswapV2Router.WETH());
        }
        _uniswapV2Pair = IUniswapV2Pair(uniswapV2Pair_);

        _isExcludedFromFee[address(_uniswapV2Router)] = true;
    }

    function uniswapV2Pair() external view returns (address) {
        return address(_uniswapV2Pair);
    }

    function _swapTokensForEth(uint256 amount, address recipient) private lockTheSwap {
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = _uniswapV2Router.WETH();

        _approve(address(this), address(_uniswapV2Router), amount);

        _uniswapV2Router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            amount,
            0, // accept any amount of ETH
            path,
            recipient,
            block.timestamp + _UNISWAP_DEADLINE_DELAY
        );
    }
    
    function _addLiquidity(uint256 ethAmount, uint256 tokenAmount) private {
        _approve(address(this), address(_uniswapV2Router), tokenAmount);

        _uniswapV2Router.addLiquidityETH {value: ethAmount} (
            address(this), 
            tokenAmount, 
            0, // amountTokenMin
            0, // amountETHMin
            _lpTokensWallet, // the receiver of the lp tokens
            block.timestamp + _UNISWAP_DEADLINE_DELAY
        );
    }
    function _swapAndLiquify(uint256 amount) private {
        require(_swapAndLiquifyEnabled, "Swap And Liquify is disabled");
        uint256 tokensToSwap = amount / 2;
        uint256 tokensAddToLiquidity = amount - tokensToSwap;

        uint256 initialBalance = address(this).balance;

        _swapTokensForEth(tokensToSwap, address(this));

        uint256 ethAddToLiquify = address(this).balance - initialBalance;

        _addLiquidity(ethAddToLiquify, tokensAddToLiquidity);
        emit SwapAndLiquify(tokensToSwap, ethAddToLiquify, tokensAddToLiquidity);
    }

    function getTokenReserves() public view returns (uint256) {
        uint112 reserve;
        if (_uniswapV2Pair.token0() == address(this))
            (reserve,,) = _uniswapV2Pair.getReserves();
        else
            (,reserve,) = _uniswapV2Pair.getReserves();

        return uint256(reserve);
    }


    function _transfer(
        address sender,
        address recipient,
        uint256 amount
    ) private {

        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");
        require(amount > 0, "ScratchToken: Transfer amount must be greater than zero");

        require(_balances[sender] >= amount, "ERC20: transfer amount exceeds balance");
        
        bool selling = recipient == address(_uniswapV2Pair);
        bool buying = sender == address(_uniswapV2Pair) && recipient != address(_uniswapV2Router);
        bool takeFee = (selling || buying) && (!_isExcludedFromFee[sender] && !_isExcludedFromFee[recipient]);
        _tokenTransfer(sender, recipient, amount, takeFee, buying);
    }

    function _tokenTransfer(address sender, address recipient, uint256 amount, bool takeFee, bool buying) private {
        uint256 amountMinusFees = amount;
        if (takeFee) {
            uint256 extraLiquidityFee = 0;
            uint256 extraDevFee = 0;
            uint256 extraBurnFee = 0;
            if (!buying && _tokenStabilityProtectionEnabled && amount >= (getTokenReserves() * _TOKEN_STABILITY_PROTECTION_THRESHOLD_PERCENTAGE / _PERCENTAGE_RELATIVE_TO)) {
                extraLiquidityFee = amount * _TAX_EXTRA_LIQUIDITY_PERCENTAGE / _PERCENTAGE_RELATIVE_TO;
                extraDevFee = amount * _TAX_EXTRA_DEV_PERCENTAGE / _PERCENTAGE_RELATIVE_TO;
                extraBurnFee = amount * _TAX_EXTRA_BURN_PERCENTAGE / _PERCENTAGE_RELATIVE_TO;
            }
            uint256 archaFee = 0;
            if (_archaFeeEnabled) {
                archaFee = amount * _TAX_NORMAL_ARCHA_PERCENTAGE / _PERCENTAGE_RELATIVE_TO;
                if (archaFee > 0) {
                    _balances[_archaWallet] += archaFee;
                    emit Transfer(sender, _archaWallet, archaFee);
                }
            }
            uint256 devFee = 0;
            if (_devFeeEnabled) {
                devFee = (amount * _TAX_NORMAL_DEV_PERCENTAGE / _PERCENTAGE_RELATIVE_TO) + extraDevFee;
                if (devFee > 0) {
                    _balances[address(this)] += devFee;
                    if (buying || _inSwap) {
                        _devFeePendingSwap += devFee;
                    }
                    else {
                        _swapTokensForEth(devFee + _devFeePendingSwap, _developmentWallet);
                        emit Transfer(sender, _developmentWallet, devFee + _devFeePendingSwap);
                        _devFeePendingSwap = 0;
                    }
                }
            }
            uint256 opsFee = 0;
            if (_opsFeeEnabled) {
                opsFee = amount * _TAX_NORMAL_OPS_PERCENTAGE / _PERCENTAGE_RELATIVE_TO;
                if (opsFee > 0) {
                    _balances[address(this)] += opsFee;
                    if (buying || _inSwap) {
                        _opsFeePendingSwap += opsFee;
                    }
                    else {
                        _swapTokensForEth(opsFee + _opsFeePendingSwap, _operationsWallet);
                        emit Transfer(sender, _operationsWallet, opsFee + _opsFeePendingSwap);
                        _opsFeePendingSwap = 0;
                    }
                }
            }
            uint256 liquidityFee = 0;
            if (_liquidityFeeEnabled) {
                liquidityFee = (amount * _TAX_NORMAL_LIQUIDITY_PERCENTAGE / _PERCENTAGE_RELATIVE_TO) + extraLiquidityFee;
                if (liquidityFee > 0) {
                    _balances[address(this)] += liquidityFee;
                    if (buying || _inSwap) {
                        _liquidityFeePendingSwap += liquidityFee;
                    }
                    else {
                        uint256 swapAndLiquifyAmount = liquidityFee + _liquidityFeePendingSwap;
                        if(_swapAndLiquifyEnabled) {
                            if(swapAndLiquifyAmount > _minTokensBeforeSwapAndLiquify) {
                                _swapAndLiquify(swapAndLiquifyAmount);
                                _liquidityFeePendingSwap = 0;
                            } else {
                                _liquidityFeePendingSwap += liquidityFee;
                            }
                        } else if (_liquidityWallet != address(0)) {
                            _swapTokensForEth(swapAndLiquifyAmount, _liquidityWallet);
                            emit Transfer(sender, _liquidityWallet, swapAndLiquifyAmount);
                            _liquidityFeePendingSwap = 0;
                        } else {
                            _liquidityFeePendingSwap += liquidityFee;
                        }
                    }
                }
            }
            uint256 burnFee = 0;
            if(_burnFeeEnabled && extraBurnFee > 0) {
                burnFee = extraBurnFee;
                _totalSupply -= burnFee;
                emit Transfer(sender, address(0), amount);
            }
            uint256 totalFees = devFee + liquidityFee + opsFee + archaFee + burnFee;
            require (amount > totalFees, "ScratchToken: Token fees exceeds transfer amount");
            amountMinusFees = amount - totalFees;
        } else {
            amountMinusFees = amount;
        }
        _balances[sender] -= amount;
        _balances[recipient] += amountMinusFees;
        emit Transfer(sender, recipient, amountMinusFees);
    }


    function name() external view virtual returns (string memory) {
        return _NAME;
    }

    function symbol() external view virtual returns (string memory) {
        return _SYMBOL;
    }

    function decimals() external view returns (uint8) {
        return _DECIMALS;
    }

    function totalSupply() public view virtual override returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account) external view virtual override returns (uint256) {
        return _balances[account];
    }

    function maxSupply() external view returns (uint256) {
        return _MAX_SUPPLY;
    }


    function transfer(address recipient, uint256 amount) external override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external virtual override returns (bool) {
        _transfer(sender, recipient, amount);

        uint256 currentAllowance = _allowances[sender][_msgSender()];
        require(currentAllowance >= amount, "ERC20: transfer amount exceeds allowance");
        unchecked {
            _approve(sender, _msgSender(), currentAllowance - amount);
        }

        return true;
    }
    
    

    function approve(address spender, uint256 amount) external virtual override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    function allowance(address owner, address spender) external view virtual override returns (uint256) {
        return _allowances[owner][spender];
    }

    function increaseAllowance(address spender, uint256 addedValue) external virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender] + addedValue);
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) external virtual returns (bool) {
        uint256 currentAllowance = _allowances[_msgSender()][spender];
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
        unchecked {
            _approve(_msgSender(), spender, currentAllowance - subtractedValue);
        }

        return true;
    }

    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) internal {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }


    function _mint(address account, uint256 amount) internal {
        require(account != address(0), "ERC20: mint to the zero address");

        _totalSupply += amount;
        _balances[account] += amount;
        emit Transfer(address(0), account, amount);
    }

}