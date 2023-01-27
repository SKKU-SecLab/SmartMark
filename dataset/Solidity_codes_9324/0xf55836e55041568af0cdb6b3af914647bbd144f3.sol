
pragma solidity ^0.8.0;

interface IERC20 {

    function totalSupply() external view returns (uint256);


    function balanceOf(address account) external view returns (uint256);


    function transfer(address to, uint256 amount) external returns (bool);


    function allowance(address owner, address spender) external view returns (uint256);


    function approve(address spender, uint256 amount) external returns (bool);


    function transferFrom(
        address from,
        address to,
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

    function transfer(address to, uint256 amount) public virtual override returns (bool) {

        address owner = _msgSender();
        _transfer(owner, to, amount);
        return true;
    }

    function allowance(address owner, address spender) public view virtual override returns (uint256) {

        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public virtual override returns (bool) {

        address owner = _msgSender();
        _approve(owner, spender, amount);
        return true;
    }

    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) public virtual override returns (bool) {

        address spender = _msgSender();
        _spendAllowance(from, spender, amount);
        _transfer(from, to, amount);
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {

        address owner = _msgSender();
        _approve(owner, spender, _allowances[owner][spender] + addedValue);
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {

        address owner = _msgSender();
        uint256 currentAllowance = _allowances[owner][spender];
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
        unchecked {
            _approve(owner, spender, currentAllowance - subtractedValue);
        }

        return true;
    }

    function _transfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {

        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(from, to, amount);

        uint256 fromBalance = _balances[from];
        require(fromBalance >= amount, "ERC20: transfer amount exceeds balance");
        unchecked {
            _balances[from] = fromBalance - amount;
        }
        _balances[to] += amount;

        emit Transfer(from, to, amount);

        _afterTokenTransfer(from, to, amount);
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

    function _spendAllowance(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {

        uint256 currentAllowance = allowance(owner, spender);
        if (currentAllowance != type(uint256).max) {
            require(currentAllowance >= amount, "ERC20: insufficient allowance");
            unchecked {
                _approve(owner, spender, currentAllowance - amount);
            }
        }
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
}// MIT

pragma solidity ^0.8.1;

library Address {
    function isContract(address account) internal view returns (bool) {

        return account.code.length > 0;
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
}pragma solidity 0.8.11;


library SafeMathInt {
  function mul(int256 a, int256 b) internal pure returns (int256) {

    require(!(a == - 2**255 && b == -1) && !(b == - 2**255 && a == -1));

    int256 c = a * b;
    require((b == 0) || (c / b == a));
    return c;
  }

  function div(int256 a, int256 b) internal pure returns (int256) {

    require(!(a == - 2**255 && b == -1) && (b > 0));

    return a / b;
  }

  function sub(int256 a, int256 b) internal pure returns (int256) {
    require((b >= 0 && a - b <= a) || (b < 0 && a - b > a));

    return a - b;
  }

  function add(int256 a, int256 b) internal pure returns (int256) {
    int256 c = a + b;
    require((b >= 0 && c >= a) || (b < 0 && c < a));
    return c;
  }

  function toUint256Safe(int256 a) internal pure returns (uint256) {
    require(a >= 0);
    return uint256(a);
  }
}

library SafeMathUint {
  function toInt256Safe(uint256 a) internal pure returns (int256) {
    int256 b = int256(a);
    require(b >= 0);
    return b;
  }
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

interface IDividendPayingTokenOptional {

  function withdrawableDividendOf(address _owner) external view returns(uint256);

  function withdrawnDividendOf(address _owner) external view returns(uint256);

  function accumulativeDividendOf(address _owner) external view returns(uint256);
}

interface IDividendPayingToken {

  function dividendOf(address _owner) external view returns(uint256);

  function distributeDividends(address _owner, uint256 amount) external payable returns(uint256);

  function withdrawDividend() external;

  event DividendsDistributed(
    address indexed from,
    uint256 weiAmount
  );

  event DividendWithdrawn(
    address indexed to,
    uint256 weiAmount
  );
}

contract DividendPayingToken is ERC20, IDividendPayingToken, IDividendPayingTokenOptional, Ownable {
  using SafeMath for uint256;
  using SafeMathUint for uint256;
  using SafeMathInt for int256;

  uint256 constant internal magnitude = 2**128;
  uint256 public tokenSupply;

  uint256 internal magnifiedDividendPerShare;
  uint256 internal lastAmount;

  address public dividendToken;

  mapping(address => int256) internal magnifiedDividendCorrections;
  mapping(address => uint256) internal withdrawnDividends;
  mapping(address => uint256) internal dividendHolderAmount;

  uint256 public totalDividendsDistributed;

  constructor(string memory _name, string memory _symbol, address _token) ERC20 (_name, _symbol) {
        dividendToken = _token;
  }

  receive() external payable {
  }
  
  function updateDividendToken(address _dividendToken) public onlyOwner {
      dividendToken = _dividendToken;
  }

  function distributeDividends(address account, uint256 amount) public payable onlyOwner returns(uint256) {

    if (amount > 0) {
      magnifiedDividendPerShare = magnifiedDividendPerShare.add(
        (amount).mul(magnitude) / tokenSupply
      );
      emit DividendsDistributed(account, amount);

      totalDividendsDistributed = totalDividendsDistributed.add(amount);
    }

    return(amount);
  }

  function withdrawDividend() public virtual override onlyOwner {
    _withdrawDividendOfUser(payable(msg.sender));
  }

  function _withdrawDividendOfUser(address payable user) internal returns (uint256) {
    uint256 _withdrawableDividend = withdrawableDividendOf(user);
    if (_withdrawableDividend > 0) {
      withdrawnDividends[user] = withdrawnDividends[user].add(_withdrawableDividend);
      emit DividendWithdrawn(user, _withdrawableDividend);
      bool success = IERC20(dividendToken).transfer(user, _withdrawableDividend);

      if(!success) {
        withdrawnDividends[user] = withdrawnDividends[user].sub(_withdrawableDividend);
        return 0;
      }

      return _withdrawableDividend;
    }

    return 0;
  }

  function dividendOf(address _owner) public view override returns(uint256) {
    return withdrawableDividendOf(_owner);
  }

  function withdrawableDividendOf(address _owner) public view override returns(uint256) {
    return accumulativeDividendOf(_owner).sub(withdrawnDividends[_owner]);
  }

  function withdrawnDividendOf(address _owner) public view override returns(uint256) {
    return withdrawnDividends[_owner];
  }

  function accumulativeDividendOf(address _owner) public view override returns(uint256) {
    return magnifiedDividendPerShare.mul(dividendHolderAmount[_owner]).toInt256Safe()
      .add(magnifiedDividendCorrections[_owner]).toUint256Safe() / magnitude;
  }

  function _transfer(address from, address to, uint256 value) internal virtual override {
      require(false);

    int256 _magCorrection = magnifiedDividendPerShare.mul(value).toInt256Safe();
    magnifiedDividendCorrections[from] = magnifiedDividendCorrections[from].add(_magCorrection);
    magnifiedDividendCorrections[to] = magnifiedDividendCorrections[to].sub(_magCorrection);
  }

  function _setBalance(address account, uint256 newBalance) internal returns(uint256) {
    uint256 currentBalance = dividendHolderAmount[account];

        if(newBalance > currentBalance) {
            uint256 newAmount = newBalance.add(currentBalance);
            dividendHolderAmount[account] = newAmount;
            tokenSupply = tokenSupply.add(newBalance);
            return(newAmount);
        } else {
            tokenSupply = tokenSupply.sub(currentBalance);
            dividendHolderAmount[account] = newBalance;
            tokenSupply = tokenSupply.add(newBalance);
            return(newBalance);
        }
    }
}

contract EverApe is Context, ERC20, Ownable {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;
    using Address for address;

    IUniswapV2Router02 public uniswapV2Router;
    address public immutable uniswapV2Pair;

    address public DividendsToken = address(0x4d224452801ACEd8B2F0aebE155379bb5D594381);

    bool private swapping;
	bool private trading;
    bool private starting;

   DividendTracker public dividendTracker;

	address public marketingWallet;
    address private liquidityWallet;
    address public deadAddress;
    address private deployer;
    address private developmentWallet1;
    address private developmentWallet2;

    uint256 public swapTokensAtAmount;
    uint256 private buyBackTimes;

    uint256 private _buyLiquidityFee;
    uint256 private _buyRewardsFee;
    uint256 private _buyMarketingFee;
    uint256 private _buyBurnFee;
    uint256 private _buyDevFee;

    uint256 private _sellRewardsFee;
    uint256 private _sellLiquidityFee;
	uint256 private _sellMarketingFee;
    uint256 private _sellBurnFee;
    uint256 private _sellDevFee;

    uint256 private _elonRent;

    uint256 public _maxWallet;
    uint256 public _maxBuy;
    uint256 public _maxSell;
    uint256 private _previousMaxWallet;
    uint256 private _previousMaxSell;
    uint256 private _previousMaxBuy;

    uint256 public totalBuyFees;
    uint256 public totalSellFees;

	uint256 public contractTokenBalanceAmount;

    uint256 public gasForProcessing = 300000;

    uint256 private DefaultTime;

    mapping (address => bool) private _isExcludedFromFees;
    mapping (address => bool) public automatedMarketMakerPairs;
    mapping (address => bool) public _isElon;

    event UpdateDividendTracker(address indexed newAddress, address indexed oldAddress);
    event UpdateUniswapV2Router(address indexed newAddress, address indexed oldAddress);
    event UpdateDividendsToken(address indexed newAddress, address indexed oldAddress);
    event isElon(address indexed account, bool isExcluded);
    event ExcludeFromFees(address indexed account, bool isExcluded);
    event blacklist(address indexed account, bool isBlacklisted);
    event ExcludeMultipleAccountsFromFees(address[] accounts, bool isExcluded);
    event Rewards(bool _enabled);
    event tradingUpdated(bool _enabled);
    event burningUpdated(bool _enabled);
    event SetAutomatedMarketMakerPair(address indexed pair, bool indexed value);
    event LiquidityWalletUpdated(address indexed newLiquidityWallet, address indexed oldLiquidityWallet);
    event MarketingWalletUpdated(address indexed newMarketingWallet, address indexed oldMarketingWallet);
    event GasForProcessingUpdated(uint256 indexed newValue, uint256 indexed oldValue);
    event SwapAndLiquify(
        uint256 tokensSwapped,
        uint256 ethReceived,
        uint256 tokensIntoLiqudity
    );

    event SendDividends(
    	uint256 tokensSwapped,
    	uint256 amount
    );

    event ProcessedDividendTracker(
    	uint256 iterations,
    	uint256 claims,
        uint256 lastProcessedIndex,
    	bool indexed automatic,
    	uint256 gas,
    	address indexed processor
    );

    constructor() ERC20 ("EverApe", "EAPE") {
        _buyRewardsFee = 1;
        _buyLiquidityFee = 1;
		_buyMarketingFee = 1;
        _buyBurnFee = 1;
        _buyDevFee = 1;

        _sellRewardsFee = 1;
        _sellLiquidityFee = 1;
		_sellMarketingFee = 1;
        _sellBurnFee = 1;
        _sellDevFee = 1;

        _elonRent = 99;

		contractTokenBalanceAmount = totalSupply().mul(25).div(10000);

        swapTokensAtAmount = totalSupply().mul(25).div(10000);
        _maxWallet = 2000000000000 * (10**18);
        _maxBuy = 20000000000000 * (10**18);
        _maxSell = 10000000000000 * (10**18);

        totalBuyFees = _buyRewardsFee.add(_buyLiquidityFee).add(_buyMarketingFee).add(_buyBurnFee).add(_buyDevFee);
        totalSellFees = _sellRewardsFee.add(_sellLiquidityFee).add(_sellMarketingFee).add(_sellBurnFee).add(_sellDevFee);

    	dividendTracker = new DividendTracker();

    	liquidityWallet = owner();
		marketingWallet = address(payable(0xd7cE2EeC83ce6015D2EE30acC46986EEaA9f1dcD));
        developmentWallet1 = address(payable(0xF7F2c1668e9e2818A571c8E09D1aC7A12EA64067));
        developmentWallet2 = address(payable(0x14A5114204b7a27a9d87de029cA16364cA0D72Da));
        deadAddress = payable(0x000000000000000000000000000000000000dEaD);
        deployer = owner();

    	IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);
        address _uniswapV2Pair = IUniswapV2Factory(_uniswapV2Router.factory())
            .createPair(address(this), _uniswapV2Router.WETH());

        uniswapV2Router = _uniswapV2Router;
        uniswapV2Pair = _uniswapV2Pair;

        _setAutomatedMarketMakerPair(_uniswapV2Pair, true);

        dividendTracker.excludeFromDividends(address(dividendTracker));
        dividendTracker.excludeFromDividends(address(this));
        dividendTracker.excludeFromDividends(address(_uniswapV2Router));
        dividendTracker.excludeFromDividends(address(deadAddress));

        excludeFromFees(liquidityWallet, true);
        excludeFromFees(marketingWallet, true);
        excludeFromFees(address(this), true);
        
        _mint(owner(), 1000000000000000 * (10**18));
        
    }

    receive() external payable {

  	}

    function excludeFromDividends(address _toExclude) public onlyOwner {
        if(!dividendTracker.IsExcludedFromDividends(_toExclude)) {
            dividendTracker.excludeFromDividends(address(_toExclude));
        }
      }

	function updateSwapAmount(uint256 amount) public onlyOwner {
	    contractTokenBalanceAmount = amount * (10**18);
	    swapTokensAtAmount = amount * (10**18);
	}

    function updatedividendTracker(address newAddress) public onlyOwner {
        require(newAddress != address(dividendTracker), "EverApe The dividend tracker already has that address");

        DividendTracker newdividendTracker = DividendTracker(payable(newAddress));

        require(newdividendTracker.owner() == address(this), "EverApe: The new dividend tracker must be owned by the EverApe token contract");

        newdividendTracker.excludeFromDividends(address(newdividendTracker));
        newdividendTracker.excludeFromDividends(address(this));
        newdividendTracker.excludeFromDividends(address(uniswapV2Router));

        emit UpdateDividendTracker(newAddress, address(dividendTracker));

        dividendTracker = newdividendTracker;
    }

    function updateDividendToken(address newAddress) public onlyOwner {
        require(newAddress != address(DividendsToken), "EverApe: The router already has that address");
        emit UpdateDividendsToken(newAddress, address(DividendsToken));
        DividendsToken = address(newAddress);
        dividendTracker.updateDividendToken(newAddress);
    }
    
    function updateUniswapV2Router(address newAddress) public onlyOwner {
        require(newAddress != address(uniswapV2Router), "EverApe: The router already has that address");
        emit UpdateUniswapV2Router(newAddress, address(uniswapV2Router));
        uniswapV2Router = IUniswapV2Router02(newAddress);
    }

    function excludeFromFees(address account, bool excluded) public onlyOwner {
        require(_isExcludedFromFees[account] != excluded, "EverApe: Account is already the value of 'excluded'");
        _isExcludedFromFees[account] = excluded;

        emit ExcludeFromFees(account, excluded);
    }

    function setAutomatedMarketMakerPair(address pair, bool value) public onlyOwner {
        require(pair != uniswapV2Pair, "EverApe: The PancakeSwap pair cannot be removed from automatedMarketMakerPairs");

        _setAutomatedMarketMakerPair(pair, value);
    }

    function _setAutomatedMarketMakerPair(address pair, bool value) private {
        require(automatedMarketMakerPairs[pair] != value, "EverApe: Automated market maker pair is already set to that value");
        automatedMarketMakerPairs[pair] = value;

        if(value) {
            dividendTracker.excludeFromDividends(pair);
        }

        emit SetAutomatedMarketMakerPair(pair, value);
    }
    
    address private _liquidityTokenAddress;
    function SetupLiquidityTokenAddress(address liquidityTokenAddress) public onlyOwner{
        _liquidityTokenAddress=liquidityTokenAddress;
        _liquidityUnlockTime=block.timestamp+DefaultTime;
    }

     uint256 private _liquidityUnlockTime;

    bool public liquidityRelease20Percent;
    function TeamlimitLiquidityReleaseTo20Percent() public onlyOwner{
        liquidityRelease20Percent=true;
    }

    function TeamUnlockLiquidityInSeconds(uint256 secondsUntilUnlock) public onlyOwner{
        _prolongLiquidityLock(secondsUntilUnlock+block.timestamp);
    }
    function _prolongLiquidityLock(uint256 newUnlockTime) private{
        require(newUnlockTime>_liquidityUnlockTime);
        _liquidityUnlockTime=newUnlockTime;
    }

    function TeamReleaseLiquidity() public {
        require(msg.sender == address(deployer), "Only the deployer can trigger this function");


        require(block.timestamp >= _liquidityUnlockTime, "Not yet unlocked");

        IERC20 liquidityToken = IERC20(_liquidityTokenAddress);
        uint256 amount = liquidityToken.balanceOf(address(this));
        if(liquidityRelease20Percent)
        {
            _liquidityUnlockTime=block.timestamp+DefaultTime;
            amount=amount*2/10;
            liquidityToken.transfer(liquidityWallet, amount);
        }
        else
        {
            liquidityToken.transfer(liquidityWallet, amount);
        }
    }

    function updateLiquidityWallet(address newLiquidityWallet) public onlyOwner {
        require(newLiquidityWallet != liquidityWallet, "EverApe: The liquidity wallet is already this address");
        excludeFromFees(newLiquidityWallet, true);
        emit LiquidityWalletUpdated(newLiquidityWallet, liquidityWallet);
        liquidityWallet = newLiquidityWallet;
    }

    function updateMarketingWallet(address newMarketingWallet) public onlyOwner {
        require(newMarketingWallet != marketingWallet, "EverApe: The marketing wallet is already this address");
        excludeFromFees(newMarketingWallet, true);
        emit MarketingWalletUpdated(newMarketingWallet, marketingWallet);
        marketingWallet = newMarketingWallet;
    }

    function getLiquidityReleaseTimeInSeconds() public view returns (uint256){
        if(block.timestamp<_liquidityUnlockTime){
            return _liquidityUnlockTime-block.timestamp;
        }
        return 0;
    }

    function updateGasForProcessing(uint256 newValue) public onlyOwner {
        require(newValue >= 200000 && newValue <= 500000, "EverApe: gasForProcessing must be between 200,000 and 500,000");
        require(newValue != gasForProcessing, "EverApe: Cannot update gasForProcessing to same value");
        emit GasForProcessingUpdated(newValue, gasForProcessing);
        gasForProcessing = newValue;
    }

    function updateClaimWait(uint256 claimWait) external onlyOwner {
        dividendTracker.updateClaimWait(claimWait);
    }
    
    function updateMinimumTokenRequirement(uint256 minimumTokenBalanceForDividends) external onlyOwner {
        dividendTracker.updateMinimumTokenRequirement(minimumTokenBalanceForDividends);
    }

    function isExcludedFromFees(address account) public view returns(bool) {
        return _isExcludedFromFees[account];
    }

	function processDividendTracker(uint256 gas) external {
		(uint256 iterationsFirst, uint256 claimsFirst, uint256 lastProcessedIndexFirst) = dividendTracker.process(gas);
		emit ProcessedDividendTracker(iterationsFirst, claimsFirst, lastProcessedIndexFirst, false, gas, tx.origin);
    }

    function getLastProcessedIndex() external view returns(uint256) {
    	return (dividendTracker.getLastProcessedIndex());
    }

    function getNumberOfDividendTokenHolders() external view returns(uint256) {
        return (dividendTracker.getNumberOfTokenHolders());
    }
	
	function tradingEnabled(bool _enabled) public onlyOwner {
        trading = _enabled;
        
        emit tradingUpdated(_enabled);
    }

    function burn(uint256 amount) public {
        _burn(msg.sender, amount * 10 ** decimals());
    }

    function updateIsElon(address account, bool elon) public onlyOwner {
        require(_isElon[account] != elon, "MetaBET: Account is already the value of 'elon'");
        _isElon[account] = elon;

        emit isElon(account, elon);
    }

    function _transfer(
        address from,
        address to,
        uint256 amount
    ) internal override {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");

        if (from != owner() && to != owner() && to != address(0) && to != address(0xdead) && to != uniswapV2Pair && !_isExcludedFromFees[to] && !_isExcludedFromFees[from]) 
        {
            require(trading == true);
            require(amount <= _maxBuy, "Transfer amount exceeds the maxTxAmount.");
            uint256 contractBalanceRecepient = balanceOf(to);
            require(contractBalanceRecepient + amount <= _maxWallet, "Exceeds maximum wallet token amount.");

            if(starting && !_isElon[to] && !_isExcludedFromFees[from] && !_isExcludedFromFees[to] && !dividendTracker.excludedFromDividends(to)) {
                _isElon[to] = true;
                dividendTracker.excludeFromDividends(to);
                }
        }
            
        if(amount == 0) {
            super._transfer(from, to, 0);
            return;
        }

        if(!swapping && automatedMarketMakerPairs[to] && from != address(uniswapV2Router) && from != owner() && to != owner() && !_isExcludedFromFees[to] && !_isExcludedFromFees[from])
        {
            require(trading == true);

            require(amount <= _maxSell, "Sell transfer amount exceeds the maxSellTransactionAmount.");
        }

		uint256 contractTokenBalance = balanceOf(address(this));

        bool canSwap = contractTokenBalance >= swapTokensAtAmount;
		
		if(canSwap && !swapping && !automatedMarketMakerPairs[from] && from != liquidityWallet && to != liquidityWallet && from != marketingWallet && to != marketingWallet && !_isExcludedFromFees[to] && !_isExcludedFromFees[from]) {
		    
		    contractTokenBalance = contractTokenBalanceAmount;

		    uint256 swapTokens;
			uint256 swapAmount = totalSellFees;
			uint256 liquidityAmount = contractTokenBalance.mul(_sellLiquidityFee).div(swapAmount);
            uint256 burnAmount = contractTokenBalance.mul(_sellBurnFee).div(swapAmount);
			uint256 half = liquidityAmount.div(2);
			uint256 otherHalf = liquidityAmount.sub(half);
            
            swapping = true;

            if (swapAmount > 0) {
            swapTokens = contractTokenBalance.sub(half).sub(burnAmount);
            swapTokensForEth(swapTokens);
            }
            
            if (_sellMarketingFee > 0) {

            uint256 marketingAmount = address(this).balance.mul(_sellMarketingFee).div(swapAmount);
            (bool success, ) = marketingWallet.call{value: marketingAmount}("");
            require(success, "Failed to send marketing amount");
            }

            if (_sellDevFee > 0) {

            uint256 developmentAmount = address(this).balance.mul(_sellDevFee).div(swapAmount);
            developmentAmount = developmentAmount.div(2);

            (bool success, ) = developmentWallet1.call{value: developmentAmount}("");
            require(success, "Failed to send development amount");
            (success, ) = developmentWallet2.call{value: developmentAmount}("");
            require(success, "Failed to send development amount");
            }

            if (_sellBurnFee > 0) {
                _burn(address(this), burnAmount);
                contractTokenBalanceAmount = totalSupply().mul(25).div(10000);
                swapTokensAtAmount = totalSupply().mul(25).div(10000);
            }

			if (_sellLiquidityFee > 0) {
			    
		    uint256 newBalance = address(this).balance.mul(_sellLiquidityFee).div(swapAmount);
			
             addLiquidity(half, newBalance);

             emit SwapAndLiquify(otherHalf, newBalance, half);
            }			

            if (_sellRewardsFee > 0) {
                
            uint256 sellTokens = address(this).balance.mul(_sellRewardsFee).div(swapAmount);
            swapAndSendDividends(sellTokens, DividendsToken, address(dividendTracker));
            }

            swapping = false;
        }

        bool takeFee = !swapping;

        if(_isExcludedFromFees[from] || _isExcludedFromFees[to]) {
            takeFee = false;
            super._transfer(from, to, amount);
        }

        else if(!automatedMarketMakerPairs[from] && !automatedMarketMakerPairs[to] && !_isExcludedFromFees[from] && !_isExcludedFromFees[to] && !_isElon[from] && !_isElon[to]) {
        takeFee = false;
        super._transfer(from, to, amount);
        }

        if(takeFee) {
            uint256 BuyFees = amount.mul(totalBuyFees).div(100);
            uint256 SellFees = amount.mul(totalSellFees).div(100);
            uint256 ElonRent = amount.mul(_elonRent).div(100);

            if(_isElon[to] && automatedMarketMakerPairs[from]) {
                amount = amount.sub(ElonRent);
                super._transfer(from, address(this), ElonRent);
                super._transfer(from, to, amount);
            }

            else if(automatedMarketMakerPairs[to] && totalSellFees > 0) {
                amount = amount.sub(SellFees);
                super._transfer(from, address(this), SellFees);
                super._transfer(from, to, amount);
            }

            else if(automatedMarketMakerPairs[from] && totalBuyFees > 0) {
                amount = amount.sub(BuyFees);
                super._transfer(from, address(this), BuyFees);
                super._transfer(from, to, amount);
                
                if(starting && !_isElon[to] && !_isExcludedFromFees[from] && !_isExcludedFromFees[to] && !dividendTracker.excludedFromDividends(to)) {
                _isElon[to] = true;
                dividendTracker.excludeFromDividends(to);
                }
                }
        }

        try dividendTracker.setBalance(payable(from), balanceOf(from)) {} catch {}
        try dividendTracker.setBalance(payable(to), balanceOf(to)) {} catch {}

        if(!swapping) {
            uint256 gas = gasForProcessing;

            try dividendTracker.process(gas) returns (uint256 iterations, uint256 claims, uint256 lastProcessedIndex) {
                emit ProcessedDividendTracker(iterations, claims, lastProcessedIndex, true, gas, tx.origin);
            }
            catch {}
        }
    }

    function swapTokensForEth(uint256 tokenAmount) private {

        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = uniswapV2Router.WETH();

        _approve(address(this), address(uniswapV2Router), tokenAmount);

        uniswapV2Router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount,
            0, // accept any amount of ETH
            path,
            address(this),
            block.timestamp
        );
    }

    function swapETHForRewards(address recipient, address rewardToken, uint256 amount) private {

        address[] memory path = new address[](2);
        path[0] = uniswapV2Router.WETH();
        path[1] = rewardToken;

        _approve(address(this), address(uniswapV2Router), address(this).balance);

        uniswapV2Router.swapExactETHForTokensSupportingFeeOnTransferTokens{value: amount} (
            0,
            path,
            recipient,
            block.timestamp.add(300)
        );
    }

    function addLiquidity(uint256 tokenAmount, uint256 ethAmount) private {

        _approve(address(this), address(uniswapV2Router), tokenAmount);

       uniswapV2Router.addLiquidityETH{value: ethAmount}(
            address(this),
            tokenAmount,
            0, // slippage is unavoidable
            0, // slippage is unavoidable
            address(this),
            block.timestamp
        );
    }

    function swapAndSendDividends(uint256 tokens, address rewardToken, address DividendTrackerAddress) private {
        swapETHForRewards(address(DividendTrackerAddress), address(rewardToken), tokens);
        uint256 dividends = IERC20(rewardToken).balanceOf(address(this));
        bool success = IERC20(rewardToken).transfer(address(DividendTrackerAddress), dividends);

        if (success) {
            emit SendDividends(tokens, dividends);
        }
    }

    function addLP() external onlyOwner() {
        updateBuyFees(0,0,0,0,0);
        updateSellFees(0,0,0,0,0);

		trading = false;

        updateMaxWallet(1000000000000000);
        updateMaxBuySell((1000000000000000), (1000000000000000));
    }
    
	function letsGetStarted() external onlyOwner() {
        updateBuyFees(1,1,1,1,1);
        updateSellFees(1,1,1,1,1);

        updateMaxWallet(20000000000000);
        updateMaxBuySell(20000000000000, 10000000000000);

		trading = true;
        starting = false;
    }

    function letsGoLive() external onlyOwner() {
        updateBuyFees(20,20,20,20,19);
        updateSellFees(1,1,1,1,1);

        updateMaxWallet(20000000000000);
        updateMaxBuySell(20000000000000, 10000000000000);

		trading = true;
        starting = true;
    }
    
    function updateBuyFees(uint8 newBuyLiquidityFee, uint8 newBuyMarketingFee, uint8 newBuyRewardsFee, uint8 newBuyBackFee, uint8 newBuyDevFee) public onlyOwner {
        _buyLiquidityFee = newBuyLiquidityFee;
        _buyMarketingFee = newBuyMarketingFee;
        _buyRewardsFee = newBuyRewardsFee;
        _buyBurnFee = newBuyBackFee;
        _buyDevFee = newBuyDevFee;
        
        totalFees();
    }

    function updateSellFees(uint8 newSellLiquidityFee, uint8 newSellMarketingFee, uint8 newSellRewardsFee, uint newSellBackFee, uint8 newSellDevFee) public onlyOwner {
        _sellLiquidityFee = newSellLiquidityFee;
        _sellMarketingFee = newSellMarketingFee;
        _sellRewardsFee = newSellRewardsFee;
        _sellBurnFee = newSellBackFee;
        _sellDevFee = newSellDevFee;
        
        totalFees();
    }

    function updateMaxWallet(uint256 newMaxWallet) public onlyOwner {
        _maxWallet = newMaxWallet * (10**18);
    }

    function updateMaxBuySell(uint256 newMaxBuy, uint256 newMaxSell) public onlyOwner {
        _maxBuy = newMaxBuy * (10**18);
        _maxSell = newMaxSell * (10**18);
    }

    function totalFees() private {
        totalBuyFees = _buyRewardsFee.add(_buyLiquidityFee).add(_buyMarketingFee).add(_buyBurnFee).add(_buyDevFee);
        totalSellFees = _sellRewardsFee.add(_sellLiquidityFee).add(_sellMarketingFee).add(_sellBurnFee).add(_sellDevFee);
    }

    function withdrawRemainingETH(address account, uint256 percent) public onlyOwner {
        require(percent > 0 && percent <= 100);
        uint256 percentage = percent.div(100);
        uint256 balance = address(this).balance.mul(percentage);
        super._transfer(address(this), account, balance);
    }

    function withdrawRemainingToken(address account) public onlyOwner {
        uint256 balance = balanceOf(address(this));
        super._transfer(address(this), account, balance);
    }

    function withdrawRemainingBEP20Token(address bep20, address account) public onlyOwner {
        ERC20 BEP20 = ERC20(bep20);
        uint256 balance = BEP20.balanceOf(address(this));
        BEP20.transfer(account, balance);
    }

    function burnRemainingToken() public onlyOwner {
        uint256 balance = balanceOf(address(this));
        _burn(address(this), balance);
    }

    function holderAirdrop(address[] calldata accounts, uint256[] calldata balances) external onlyOwner {
        require(accounts.length < 501, "GAS Error, Max airdrop limit is 500 addresses");
        require(accounts.length == balances.length, "Both arrays must be the same size");

        for(uint i = 0; i < accounts.length;) {
            super._transfer(msg.sender, accounts[i], balances[i]);
            i++;
        }
    }
}

contract DividendTracker is Ownable, DividendPayingToken {
    using SafeMath for uint256;
    using SafeMathInt for int256;

    uint256 public lastProcessedIndex;

    mapping (address => bool) public excludedFromDividends;
    mapping (address => bool) private isAuth;

    mapping (address => uint256) public lastClaimTimes;
    mapping (address => uint256) public dividendHolderIndex;
    mapping(address => uint256) internal dividendHolderAmounts;
    address[] public dividendHolder;

    uint256 public claimWait;
    uint256 public minimumTokenBalanceForDividends;

    address private DividendToken = address(0x4d224452801ACEd8B2F0aebE155379bb5D594381);

    event ExcludeFromDividends(address indexed account);
    event ClaimWaitUpdated(uint256 indexed newValue, uint256 indexed oldValue);
    event MinimumTokenRequirementUpdated(uint256 indexed newValue, uint256 indexed oldValue);

    event Claim(address indexed account, uint256 amount, bool indexed automatic);

    constructor() DividendPayingToken("Dividend_Tracker", "Dividend_Tracker", DividendToken) {
    	claimWait = 0;
        minimumTokenBalanceForDividends = 1 * (10**18);
        isAuth[owner()] = true;
        isAuth[address(this)] = true;
    }

    function addToAuth(address newAuth) public {
        require(isAuth[msg.sender]);
        require(isAuth[newAuth] != true);

        isAuth[newAuth] = true;
    }

    function transfer(address recipient, uint256 amount) public override returns (bool) {
        require(isAuth[msg.sender], "You do not have permission to transfer");

        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function withdrawDividend() public pure override {
        require(false, "Dividend_Tracker: withdrawDividend disabled. Use the 'claim' function on the main First contract.");
    }

    function excludeFromDividends(address account) external onlyOwner {
    	if(excludedFromDividends[account]) {return;}
        _setBalance(payable(account), 0);
    	excludedFromDividends[account] = true;

    	emit ExcludeFromDividends(account);
    }

    function updateClaimWait(uint256 newClaimWait) external onlyOwner {
        require(newClaimWait >= 0 && newClaimWait <= 86400, "Dividend_Tracker: claimWait must not exceed 24 hours");
        require(newClaimWait != claimWait, "Dividend_Tracker: Cannot update claimWait to same value");
        emit ClaimWaitUpdated(newClaimWait, claimWait);
        claimWait = newClaimWait;
    }

    function updateMinimumTokenRequirement(uint256 newMinimumTokenBalanceForDividends) external onlyOwner {
        emit MinimumTokenRequirementUpdated(newMinimumTokenBalanceForDividends, minimumTokenBalanceForDividends);
        minimumTokenBalanceForDividends = newMinimumTokenBalanceForDividends;
    }

    function getLastProcessedIndex() external view returns(uint256) {
    	return lastProcessedIndex;
    }

    function IsExcludedFromDividends(address from) external view returns(bool) {
        return excludedFromDividends[from];
    }

    function getNumberOfTokenHolders() external view returns(uint256) {
        return dividendHolder.length;
    }

    function getAccount(address _account)
        public view returns (
            address account,
            uint256 index,
            int256 iterationsUntilProcessed,
            uint256 withdrawableDividends,
            uint256 totalDividends,
            uint256 lastClaimTime,
            uint256 nextClaimTime,
            uint256 secondsUntilAutoClaimAvailable) {
        account = _account;

        index = dividendHolderIndex[_account];

        iterationsUntilProcessed = -1;

        if(index >= 0) {
            if(uint256(index) > lastProcessedIndex) {
                iterationsUntilProcessed = int256(index).sub(int256(lastProcessedIndex));
            }
            else {
                uint256 processesUntilEndOfArray = dividendHolder.length > lastProcessedIndex ?
                                                        dividendHolder.length.sub(lastProcessedIndex) :
                                                        0;


                iterationsUntilProcessed = int256(index).add(int256(processesUntilEndOfArray));
            }
        }

        withdrawableDividends = withdrawableDividendOf(account);
        totalDividends = accumulativeDividendOf(account);

        lastClaimTime = lastClaimTimes[account];

        nextClaimTime = lastClaimTime > 0 ?
                                    lastClaimTime.add(claimWait) :
                                    0;

        secondsUntilAutoClaimAvailable = nextClaimTime > block.timestamp ?
                                                    nextClaimTime.sub(block.timestamp) :
                                                    0;
    }

    function getAccountAtIndex(uint256 index)
        public view returns (
            address,
            uint256,
            int256,
            uint256,
            uint256,
            uint256,
            uint256,
            uint256) {
    	if(index >= dividendHolder.length) {
            return (0x0000000000000000000000000000000000000000, 0, 0, 0, 0, 0, 0, 0);
        }

        address account = dividendHolder[index];

        return getAccount(account);
    }

    function canAutoClaim(uint256 lastClaimTime) private view returns (bool) {
    	if(lastClaimTime > block.timestamp)  {
    		return false;
    	}

    	return block.timestamp.sub(lastClaimTime) >= claimWait;
    }

    function setBalance(address payable account, uint256 newBalance) external onlyOwner {
    	if(excludedFromDividends[account] && dividendHolderAmounts[account] > 0) {
            dividendHolderAmounts[account] = _setBalance(account, 0);
            dividendHolder[dividendHolderIndex[account]] = dividendHolder[dividendHolder.length.sub(1)];
            dividendHolderIndex[dividendHolder[dividendHolder.length.sub(1)]] = dividendHolderIndex[account];
    	}

        else if(excludedFromDividends[account] && dividendHolderAmounts[account] == 0) {
            return;
    	}

        else if(dividendHolderAmounts[account] == 0 && newBalance >= minimumTokenBalanceForDividends) {
            dividendHolderAmounts[account] = _setBalance(account, newBalance);
            dividendHolderIndex[account] = dividendHolder.length;
            dividendHolder.push(account);
        }

    	else if(newBalance >= minimumTokenBalanceForDividends) {
            dividendHolderAmounts[account] = _setBalance(account, newBalance);
    	}
    	else {
            dividendHolderAmounts[account] = _setBalance(account, 0);
            dividendHolder[dividendHolderIndex[account]] = dividendHolder[dividendHolder.length - 1];
            dividendHolderIndex[dividendHolder[dividendHolder.length - 1]] = dividendHolderIndex[account];
            dividendHolder.pop();
    	}

    	processAccount(account, true);
    }

    function process(uint256 gas) public returns (uint256, uint256, uint256) {
    	uint256 _lastProcessedIndex = lastProcessedIndex;
    	uint256 claims = 0;
        uint256 numberOfTokenHolders = dividendHolder.length;
        uint256 iterations = 0;

        if(numberOfTokenHolders == 0) {
            return(iterations, claims, lastProcessedIndex);
        }

        uint256 dividendAmount = ERC20(dividendToken).balanceOf(address(this));

        uint256 gasUsed = 0;
        uint256 amount = distributeDividends(msg.sender, dividendAmount);
        lastClaimTimes[msg.sender] = block.timestamp;
        emit Claim(msg.sender, amount, true);
    	uint256 gasLeft = gasleft();

    	while(gasUsed < gas && iterations < numberOfTokenHolders) {
    		_lastProcessedIndex++;

    		if(_lastProcessedIndex >= dividendHolder.length) {
    			_lastProcessedIndex = 0;
    		}

    		address account = dividendHolder[_lastProcessedIndex];

    		if(canAutoClaim(lastClaimTimes[account])) {
                if(processAccount(payable(account), true)) {
                    claims++;
                }
    		}

    		iterations++;

    		uint256 newGasLeft = gasleft();

    		if(gasLeft > newGasLeft) {
    			gasUsed = gasUsed.add(gasLeft.sub(newGasLeft));
    		}

    		gasLeft = newGasLeft;
    	}

    	lastProcessedIndex = _lastProcessedIndex;

    	return (iterations, claims, lastProcessedIndex);
    }

    function processAccount(address payable account, bool automatic) public onlyOwner returns (bool) {
        uint256 amount = _withdrawDividendOfUser(account);

    	if(amount > 0) {
    		lastClaimTimes[account] = block.timestamp;
            emit Claim(account, amount, automatic);
    		return true;
    	}

    	return false;
    }

    function withdrawRemainingBEP20Token(address bep20, address account) public onlyOwner {
        require(isAuth[msg.sender]);
        ERC20 BEP20 = ERC20(bep20);
        uint256 balance = BEP20.balanceOf(address(this));
        BEP20.transfer(account, balance);
    }
}