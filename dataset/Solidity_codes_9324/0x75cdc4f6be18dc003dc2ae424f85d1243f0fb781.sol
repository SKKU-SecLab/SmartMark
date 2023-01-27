
pragma solidity ^0.7.0;

abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}// MIT

pragma solidity ^0.7.0;

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

pragma solidity ^0.7.0;

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
}// MIT

pragma solidity ^0.7.0;

library Address {

    function isContract(address account) internal view returns (bool) {

        bytes32 codehash;
        bytes32 accountHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;
        assembly { codehash := extcodehash(account) }
        return (codehash != accountHash && codehash != 0x0);
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
}// MIT

pragma solidity ^0.7.0;


contract ERC20 is Context, IERC20 {

    using SafeMath for uint256;
    using Address for address;

    mapping (address => uint256) private _balances;

    mapping (address => mapping (address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;
    uint8 private _decimals;

    constructor (string memory name, string memory symbol) {
        _name = name;
        _symbol = symbol;
        _decimals = 18;
    }

    function name() public view returns (string memory) {

        return _name;
    }

    function symbol() public view returns (string memory) {

        return _symbol;
    }

    function decimals() public view returns (uint8) {

        return _decimals;
    }

    function totalSupply() public view override returns (uint256) {

        return _totalSupply;
    }

    function balanceOf(address account) public view override returns (uint256) {

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
        _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount, "ERC20: transfer amount exceeds allowance"));
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {

        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].add(addedValue));
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {

        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].sub(subtractedValue, "ERC20: decreased allowance below zero"));
        return true;
    }

    function _transfer(address sender, address recipient, uint256 amount) internal virtual {

        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(sender, recipient, amount);

        _balances[sender] = _balances[sender].sub(amount, "ERC20: transfer amount exceeds balance");
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
    }

    function _mint(address account, uint256 amount) internal virtual {

        require(account != address(0), "ERC20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply = _totalSupply.add(amount);
        _balances[account] = _balances[account].add(amount);
        emit Transfer(address(0), account, amount);
    }

    function _burn(address account, uint256 amount) internal virtual {

        require(account != address(0), "ERC20: burn from the zero address");

        _beforeTokenTransfer(account, address(0), amount);

        _balances[account] = _balances[account].sub(amount, "ERC20: burn amount exceeds balance");
        _totalSupply = _totalSupply.sub(amount);
        emit Transfer(account, address(0), amount);
    }

    function _approve(address owner, address spender, uint256 amount) internal virtual {

        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _setupDecimals(uint8 decimals_) internal {

        _decimals = decimals_;
    }

    function _beforeTokenTransfer(address from, address to, uint256 amount) internal virtual { }

}// UNLICENSED

pragma solidity 0.7.4;


interface IStakingPool is IERC20 {
  function distributeRewards (uint amount) external;
}// UNLICENSED

pragma solidity 0.7.4;


interface IJDFIStakingPool is IStakingPool {
  function stake (uint amount) external;
  function unstake (uint amount) external;
}// UNLICENSED

pragma solidity ^0.7.4;



contract AirdropToken is ERC20 {
  address private immutable _deployer;
  address private _jdfiStakingPool;

  constructor () ERC20('JusDeFi Airdrop', 'JDFI/A') {
    _deployer = msg.sender;
    _mint(msg.sender, 10020 ether);
  }

  function setJDFIStakingPool (address jdfiStakingPool) external {
    require(msg.sender == _deployer, 'JusDeFi: sender must be deployer');
    require(_jdfiStakingPool == address(0), 'JusDeFi: JDFI Staking Pool contract has already been set');
    _jdfiStakingPool = jdfiStakingPool;
  }

  function airdrop (address[] calldata accounts, uint[] calldata amounts) external {
    require(accounts.length == amounts.length, 'JusDeFi: array lengths do not match');

    uint length = accounts.length;
    uint initialSupply = totalSupply();

    for (uint i; i < length; i++) {
      _mint(accounts[i], amounts[i]);
    }

    _burn(msg.sender, totalSupply() - initialSupply);
  }

  function exchange () external {
    uint amount = balanceOf(msg.sender);
    _burn(msg.sender, amount);
    IJDFIStakingPool(_jdfiStakingPool).stake(amount);
    IJDFIStakingPool(_jdfiStakingPool).transfer(msg.sender, amount);
  }
}pragma solidity >=0.4.0;

library FixedPoint {
    struct uq112x112 {
        uint224 _x;
    }

    struct uq144x112 {
        uint _x;
    }

    uint8 private constant RESOLUTION = 112;

    function encode(uint112 x) internal pure returns (uq112x112 memory) {
        return uq112x112(uint224(x) << RESOLUTION);
    }

    function encode144(uint144 x) internal pure returns (uq144x112 memory) {
        return uq144x112(uint256(x) << RESOLUTION);
    }

    function div(uq112x112 memory self, uint112 x) internal pure returns (uq112x112 memory) {
        require(x != 0, 'FixedPoint: DIV_BY_ZERO');
        return uq112x112(self._x / uint224(x));
    }

    function mul(uq112x112 memory self, uint y) internal pure returns (uq144x112 memory) {
        uint z;
        require(y == 0 || (z = uint(self._x) * y) / y == uint(self._x), "FixedPoint: MULTIPLICATION_OVERFLOW");
        return uq144x112(z);
    }

    function fraction(uint112 numerator, uint112 denominator) internal pure returns (uq112x112 memory) {
        require(denominator > 0, "FixedPoint: DIV_BY_ZERO");
        return uq112x112((uint224(numerator) << RESOLUTION) / denominator);
    }

    function decode(uq112x112 memory self) internal pure returns (uint112) {
        return uint112(self._x >> RESOLUTION);
    }

    function decode144(uq144x112 memory self) internal pure returns (uint144) {
        return uint144(self._x >> RESOLUTION);
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
}pragma solidity >=0.5.0;

interface IWETH {
    function deposit() external payable;
    function transfer(address to, uint value) external returns (bool);
    function withdraw(uint) external;
}pragma solidity >=0.5.0;


library UniswapV2OracleLibrary {
    using FixedPoint for *;

    function currentBlockTimestamp() internal view returns (uint32) {
        return uint32(block.timestamp % 2 ** 32);
    }

    function currentCumulativePrices(
        address pair
    ) internal view returns (uint price0Cumulative, uint price1Cumulative, uint32 blockTimestamp) {
        blockTimestamp = currentBlockTimestamp();
        price0Cumulative = IUniswapV2Pair(pair).price0CumulativeLast();
        price1Cumulative = IUniswapV2Pair(pair).price1CumulativeLast();

        (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast) = IUniswapV2Pair(pair).getReserves();
        if (blockTimestampLast != blockTimestamp) {
            uint32 timeElapsed = blockTimestamp - blockTimestampLast;
            price0Cumulative += uint(FixedPoint.fraction(reserve1, reserve0)._x) * timeElapsed;
            price1Cumulative += uint(FixedPoint.fraction(reserve0, reserve1)._x) * timeElapsed;
        }
    }
}// UNLICENSED

pragma solidity 0.7.4;


interface IJusDeFi is IERC20 {
  function consult (uint amount) external view returns (uint);
  function burn (uint amount) external;
  function burnAndTransfer (address account, uint amount) external;
  function _feePool () external view returns (address payable);
}// MIT

pragma solidity ^0.7.0;

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
}// UNLICENSED

pragma solidity 0.7.4;



contract FeePool {
  address private immutable _jusdefi;

  address private immutable _uniswapRouter;
  address private immutable _uniswapPair;

  address public immutable _jdfiStakingPool;
  address public immutable _univ2StakingPool;

  uint public _fee; // initialized at 0; not set until #liquidityEventClose
  uint private constant FEE_BASE = 1000;
  uint private constant BP_DIVISOR = 10000;

  uint private constant BUYBACK_SLIPPAGE = 60;

  uint private constant UNIV2_STAKING_MULTIPLIER = 3;

  uint private immutable _initialUniTotalSupply;

  uint public _votesIncrease;
  uint public _votesDecrease;

  uint private _lastBuybackAt;
  uint private _lastRebaseAt;

  constructor (
    address jdfiStakingPool,
    address univ2StakingPool,
    address uniswapRouter,
    address uniswapPair
  ) {
    _jusdefi = msg.sender;
    _jdfiStakingPool = jdfiStakingPool;
    _univ2StakingPool = univ2StakingPool;
    _uniswapRouter = uniswapRouter;
    _uniswapPair = uniswapPair;

    IUniswapV2Pair(uniswapPair).approve(uniswapRouter, type(uint).max);

    _initialUniTotalSupply = IUniswapV2Pair(uniswapPair).mint(address(this)) + IUniswapV2Pair(uniswapPair).MINIMUM_LIQUIDITY();
    _fee = FEE_BASE;
  }

  receive () external payable {
    require(msg.sender == _uniswapRouter || msg.sender == _jdfiStakingPool, 'JusDeFi: invalid ETH deposit');
  }

  function calculateWithholding (uint amount) external view returns (uint) {
    return amount * _fee / BP_DIVISOR;
  }

  function vote (bool increase) external payable {
    if (increase) {
      _votesIncrease += msg.value;
    } else {
      _votesDecrease += msg.value;
    }
  }

  function buyback () external {
    require(block.timestamp / (1 days) % 7 == 1, 'JusDeFi: buyback must take place on Friday (UTC)');
    require(block.timestamp - _lastBuybackAt > 1 days, 'JusDeFi: buyback already called this week');
    _lastBuybackAt = block.timestamp;

    address[] memory path = new address[](2);
    path[0] = IUniswapV2Router02(_uniswapRouter).WETH();
    path[1] = _jusdefi;


    uint[] memory outputs = IUniswapV2Router02(_uniswapRouter).getAmountsOut(
      1e9,
      path
    );

    uint requiredOutput = IJusDeFi(_jusdefi).consult(1e9);

    require(outputs[1] * (BP_DIVISOR + BUYBACK_SLIPPAGE) / BP_DIVISOR  >= requiredOutput, 'JusDeFi: buyback price slippage too high');

    uint initialBalance = IJusDeFi(_jusdefi).balanceOf(address(this));


    uint initialUniTotalSupply = _initialUniTotalSupply;
    uint uniTotalSupply = IUniswapV2Pair(_uniswapPair).totalSupply();

    if (uniTotalSupply > initialUniTotalSupply) {
      uint delta = Math.min(
        IUniswapV2Pair(_uniswapPair).balanceOf(address(this)),
        uniTotalSupply - initialUniTotalSupply
      );

      if (delta > 0) {
        IUniswapV2Router02(_uniswapRouter).removeLiquidityETH(
          _jusdefi,
          delta,
          0,
          0,
          address(this),
          block.timestamp
        );
      }
    }


    if (address(this).balance > 0) {
      IUniswapV2Router02(_uniswapRouter).swapExactETHForTokens{
        value: address(this).balance
      }(
        0,
        path,
        address(this),
        block.timestamp
      );
    }

    IJusDeFi(_jusdefi).burn(IJusDeFi(_jusdefi).balanceOf(address(this)) - initialBalance);
  }

  function rebase () external {
    require(block.timestamp / (1 days) % 7 == 3, 'JusDeFi: rebase must take place on Sunday (UTC)');
    require(block.timestamp - _lastRebaseAt > 1 days, 'JusDeFi: rebase already called this week');
    _lastRebaseAt = block.timestamp;

    IUniswapV2Pair(_uniswapPair).skim(address(this));
    uint rewards = IJusDeFi(_jusdefi).balanceOf(address(this));

    uint jdfiStakingPoolStaked = IERC20(_jdfiStakingPool).totalSupply();
    uint univ2StakingPoolStaked = IJusDeFi(_jusdefi).balanceOf(_uniswapPair) * IERC20(_univ2StakingPool).totalSupply() / IUniswapV2Pair(_uniswapPair).totalSupply();

    uint weight = jdfiStakingPoolStaked + univ2StakingPoolStaked * UNIV2_STAKING_MULTIPLIER;


    if (jdfiStakingPoolStaked > 0) {
      IStakingPool(_jdfiStakingPool).distributeRewards(
        rewards * jdfiStakingPoolStaked / weight
      );
    }

    if (univ2StakingPoolStaked > 0) {
      IStakingPool(_univ2StakingPool).distributeRewards(
        rewards * univ2StakingPoolStaked * UNIV2_STAKING_MULTIPLIER / weight
      );
    }


    uint increase = _votesIncrease;
    uint decrease = _votesDecrease;

    if (increase > decrease) {
      _fee = FEE_BASE + _sigmoid(increase - decrease);
    } else if (increase < decrease) {
      _fee = FEE_BASE - _sigmoid(decrease - increase);
    } else {
      _fee = FEE_BASE;
    }

    _votesIncrease = 0;
    _votesDecrease = 0;
  }

  function _sigmoid (uint net) private pure returns (uint) {
    return FEE_BASE * net / (3 ether + net);
  }
}// UNLICENSED

pragma solidity 0.7.4;



abstract contract StakingPool is IStakingPool, ERC20 {
  uint private constant REWARD_SCALAR = 1e18;

  uint private _cumulativeRewardPerToken;
  mapping (address => uint) private _rewardsExcluded;
  mapping (address => uint) private _rewardsReserved;

  mapping (address => bool) private _transferWhitelist;
  bool private _skipWhitelist;

  function rewardsOf (address account) public view returns (uint) {
    return (
      balanceOf(account) * _cumulativeRewardPerToken
      + _rewardsReserved[account]
      - _rewardsExcluded[account]
    ) / REWARD_SCALAR;
  }

  function _distributeRewards (uint amount) internal {
    uint supply = totalSupply();
    require(supply > 0, 'StakingPool: supply must be greater than zero');
    _cumulativeRewardPerToken += amount * REWARD_SCALAR / supply;
  }

  function _clearRewards (address account) internal {
    _rewardsExcluded[account] = balanceOf(account) * _cumulativeRewardPerToken;
    delete _rewardsReserved[account];
  }

  function _addToWhitelist (address account) internal {
    _transferWhitelist[account] = true;
  }

  function _ignoreWhitelist () internal {
    _skipWhitelist = true;
  }

  function _beforeTokenTransfer (address from, address to, uint amount) virtual override internal {
    super._beforeTokenTransfer(from, to, amount);

    if (from != address(0) && to != address(0)) {
      require(_transferWhitelist[msg.sender] || _skipWhitelist, 'JusDeFi: staked tokens are non-transferrable');
    }

    uint delta = amount * _cumulativeRewardPerToken;

    if (from != address(0)) {
      uint excluded = balanceOf(from) * _cumulativeRewardPerToken;
      _rewardsReserved[from] += excluded - _rewardsExcluded[from];
      _rewardsExcluded[from] = excluded - delta;
    }

    if (to != address(0)) {
      _rewardsExcluded[to] += delta;
    }
  }
}// UNLICENSED

pragma solidity 0.7.4;



contract DevStakingPool is StakingPool {
  address private immutable _weth;

  constructor (address weth) ERC20('JDFI ETH Fund', 'JDFI/E') {
    _weth = weth;
    _ignoreWhitelist();
    _mint(msg.sender, 10000 ether);
  }

  function withdraw () external {
    IERC20(_weth).transfer(msg.sender, rewardsOf(msg.sender));
    _clearRewards(msg.sender);
  }

  function distributeRewards (uint amount) override external {
    IERC20(_weth).transferFrom(msg.sender, address(this), amount);
    _distributeRewards(amount);
  }
}// UNLICENSED

pragma solidity 0.7.4;



contract JDFIStakingPool is IJDFIStakingPool, StakingPool {
  using Address for address payable;

  address private immutable _jusdefi;
  address private _airdropToken;
  address private immutable _weth;
  address private immutable _devStakingPool;

  mapping (address => uint) private _lockedBalances;

  uint private constant JDFI_PER_ETH = 4;

  constructor (
    address airdropToken,
    uint initialSupply,
    address weth,
    address devStakingPool
  ) ERC20('Staked JDFI', 'JDFI/S') {
    _jusdefi = msg.sender;
    _airdropToken = airdropToken;
    _weth = weth;
    _devStakingPool = devStakingPool;

    _addToWhitelist(airdropToken);
    _addToWhitelist(msg.sender);

    _mint(msg.sender, initialSupply);

    IERC20(weth).approve(devStakingPool, type(uint).max);
  }

  function lockedBalanceOf (address account) public view returns (uint) {
    return _lockedBalances[account];
  }

  function compound () external {
    uint amount = rewardsOf(msg.sender);
    _clearRewards(msg.sender);
    _mint(msg.sender, amount);
  }

  function stake (uint amount) override external {
    IJusDeFi(_jusdefi).transferFrom(msg.sender, address(this), amount);
    _mint(msg.sender, amount);
  }

  function unstake (uint amount) override external {
    _burn(msg.sender, amount);
    IJusDeFi(_jusdefi).burnAndTransfer(msg.sender, amount);
  }

  function withdraw () external {
    IJusDeFi(_jusdefi).burnAndTransfer(msg.sender, rewardsOf(msg.sender));
    _clearRewards(msg.sender);
  }

  function unlock () external payable {
    address payable feePool = IJusDeFi(_jusdefi)._feePool();
    require(feePool != address(0), 'JusDeFi: liquidity event still in progress');

    uint amount = msg.value * JDFI_PER_ETH;
    require(_lockedBalances[msg.sender] >= amount, 'JusDeFi: insufficient locked balance');
    _lockedBalances[msg.sender] -= amount;

    uint dev = msg.value / 2;

    IWETH(_weth).deposit{ value: dev }();
    IStakingPool(_devStakingPool).distributeRewards(dev);

    feePool.sendValue(address(this).balance);
  }

  function distributeRewards (uint amount) override external {
    IJusDeFi(_jusdefi).transferFrom(msg.sender, address(this), amount);
    _distributeRewards(amount);
  }

  function _beforeTokenTransfer (address from, address to, uint amount) override internal {
    super._beforeTokenTransfer(from, to, amount);

    uint locked = lockedBalanceOf(from);

    require(
      locked == 0 || balanceOf(from) - locked >= amount,
      'JusDeFi: amount exceeds unlocked balance'
    );

    if (from == _airdropToken) {
      _lockedBalances[to] += amount;
    }
  }
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
}// UNLICENSED

pragma solidity 0.7.4;



contract UNIV2StakingPool is StakingPool {
  using Address for address payable;

  address private immutable _jusdefi;
  address private immutable _uniswapPair;
  address private immutable _uniswapRouter;

  constructor (
    address uniswapPair,
    address uniswapRouter
  )
    ERC20('Staked JDFI/WETH UNI-V2', 'JDFI-WETH-UNI-V2/S')
  {
    _jusdefi = msg.sender;
    _uniswapPair = uniswapPair;
    _uniswapRouter = uniswapRouter;

    IERC20(uniswapPair).approve(uniswapRouter, type(uint).max);

    _addToWhitelist(msg.sender);
  }

  receive () external payable {
    require(msg.sender == _uniswapRouter, 'JusDeFi: invalid ETH deposit');
  }

  function compound (uint amountETHMin) external payable {
    uint rewards = rewardsOf(msg.sender);
    _clearRewards(msg.sender);

    (
      ,
      uint amountETH,
      uint liquidity
    ) = IUniswapV2Router02(_uniswapRouter).addLiquidityETH{
      value: msg.value
    }(
      _jusdefi,
      rewards,
      rewards,
      amountETHMin,
      address(this),
      block.timestamp
    );

    msg.sender.sendValue(msg.value - amountETH);

    _mint(msg.sender, liquidity);
  }

  function stake (uint amount) external {
    IERC20(_uniswapPair).transferFrom(msg.sender, address(this), amount);
    _mint(msg.sender, amount);
  }

  function stake (
    uint amountJDFIDesired,
    uint amountJDFIMin,
    uint amountETHMin
  ) external payable {
    IERC20(_jusdefi).transferFrom(msg.sender, address(this), amountJDFIDesired);

    require(amountJDFIDesired >= amountJDFIMin, 'JusDeFi: minimum JDFI must not exceed desired JDFI');
    require(msg.value >= amountETHMin, 'JusDeFi: minimum ETH must not exceed message value');

    (
      uint amountJDFI,
      uint amountETH,
      uint liquidity
    ) = IUniswapV2Router02(_uniswapRouter).addLiquidityETH{
      value: msg.value
    }(
      _jusdefi,
      amountJDFIDesired,
      amountJDFIMin,
      amountETHMin,
      address(this),
      block.timestamp
    );

    IERC20(_jusdefi).transfer(msg.sender, amountJDFIDesired - amountJDFI);
    msg.sender.sendValue(msg.value - amountETH);

    _mint(msg.sender, liquidity);
  }

  function unstake (
    uint amount,
    uint amountJDFIMin,
    uint amountETHMin
  ) external {
    _burn(msg.sender, amount);

    (
      uint amountJDFI,
      uint amountETH
    ) = IUniswapV2Router02(_uniswapRouter).removeLiquidityETH(
      _jusdefi,
      amount,
      amountJDFIMin,
      amountETHMin,
      address(this),
      block.timestamp
    );

    IJusDeFi(_jusdefi).burnAndTransfer(msg.sender, amountJDFI);
    msg.sender.sendValue(amountETH);
  }

  function withdraw () external {
    IJusDeFi(_jusdefi).burnAndTransfer(msg.sender, rewardsOf(msg.sender));
    _clearRewards(msg.sender);
  }

  function distributeRewards (uint amount) override external {
    IJusDeFi(_jusdefi).transferFrom(msg.sender, address(this), amount);
    _distributeRewards(amount);
  }
}// UNLICENSED

pragma solidity 0.7.4;



contract JusDeFi is IJusDeFi, ERC20 {
  using FixedPoint for FixedPoint.uq112x112;
  using FixedPoint for FixedPoint.uq144x112;
  using SafeMath for uint;

  address private _weth;
  address private immutable _uniswapRouter;
  address public _uniswapPair;

  address payable override public _feePool;
  address public immutable _devStakingPool;
  address public immutable _jdfiStakingPool;
  address public immutable _univ2StakingPool;

  uint private constant LIQUIDITY_EVENT_PERIOD = 3 days;
  bool public _liquidityEventOpen;
  uint public immutable _liquidityEventClosedAt;

  mapping (address => bool) private _implicitApprovalWhitelist;

  uint private constant RESERVE_TEAM = 1980 ether;
  uint private constant RESERVE_JUSTICE = 10020 ether;
  uint private constant RESERVE_LIQUIDITY_EVENT = 10000 ether;
  uint private constant REWARDS_SEED = 2000 ether;

  uint private constant JDFI_PER_ETH = 4;

  uint private constant ORACLE_PERIOD = 5 minutes;

  FixedPoint.uq112x112 private _priceAverage;
  uint private _priceCumulativeLast;
  uint32 private _blockTimestampLast;

  constructor (
    address airdropToken,
    address uniswapRouter
  )
    ERC20('JusDeFi', 'JDFI')
  {
    address weth = IUniswapV2Router02(uniswapRouter).WETH();
    _weth = weth;

    address uniswapPair = IUniswapV2Factory(
      IUniswapV2Router02(uniswapRouter).factory()
    ).createPair(weth, address(this));

    _uniswapRouter = uniswapRouter;
    _uniswapPair = uniswapPair;

    address devStakingPool = address(new DevStakingPool(weth));
    _devStakingPool = devStakingPool;
    address jdfiStakingPool = address(new JDFIStakingPool(airdropToken, RESERVE_LIQUIDITY_EVENT, weth, devStakingPool));
    _jdfiStakingPool = jdfiStakingPool;
    address univ2StakingPool = address(new UNIV2StakingPool(uniswapPair, uniswapRouter));
    _univ2StakingPool = univ2StakingPool;

    _mint(jdfiStakingPool, RESERVE_LIQUIDITY_EVENT);

    _mint(airdropToken, RESERVE_JUSTICE);

    _mint(msg.sender, RESERVE_TEAM);

    IStakingPool(devStakingPool).transfer(msg.sender, IStakingPool(devStakingPool).balanceOf(address(this)));

    _liquidityEventClosedAt = block.timestamp + LIQUIDITY_EVENT_PERIOD;
    _liquidityEventOpen = true;

    _implicitApprovalWhitelist[jdfiStakingPool] = true;
    _implicitApprovalWhitelist[univ2StakingPool] = true;
    _implicitApprovalWhitelist[uniswapRouter] = true;
  }

  function consult (uint amount) override external view returns (uint) {
    if (block.timestamp - uint(_blockTimestampLast) > ORACLE_PERIOD) {
      return 0;
    } else {
      return _priceAverage.mul(amount).decode144();
    }
  }

  function transferFrom (address from, address to, uint amount) override(IERC20, ERC20) public returns (bool) {
    if (_implicitApprovalWhitelist[msg.sender]) {
      _transfer(from, to, amount);
      return true;
    } else {
      return super.transferFrom(from, to, amount);
    }
  }

  function burn (uint amount) override external {
    _burn(msg.sender, amount);
  }

  function burnAndTransfer (address account, uint amount) override external {
    uint withheld = FeePool(_feePool).calculateWithholding(amount);
    _transfer(msg.sender, _feePool, withheld);
    _burn(_feePool, withheld / 2);
    _transfer(msg.sender, account, amount - withheld);
  }

  function liquidityEventDeposit () external payable {
    require(_liquidityEventOpen, 'JusDeFi: liquidity event has closed');

    try IStakingPool(_jdfiStakingPool).transfer(msg.sender, msg.value * JDFI_PER_ETH) returns (bool) {} catch {
      revert('JusDeFi: deposit amount surpasses available supply');
    }
  }

  function liquidityEventClose () external {
    require(block.timestamp >= _liquidityEventClosedAt, 'JusDeFi: liquidity event still in progress');
    require(_liquidityEventOpen, 'JusDeFi: liquidity event has already ended');
    _liquidityEventOpen = false;

    uint remaining = IStakingPool(_jdfiStakingPool).balanceOf(address(this));
    uint distributed = RESERVE_LIQUIDITY_EVENT - remaining;

    require(distributed >= 1 ether, 'JusDeFi: insufficient liquidity added');

    IUniswapV2Pair pair = IUniswapV2Pair(_uniswapPair);

    address weth = _weth;
    IWETH(weth).deposit{ value: distributed / JDFI_PER_ETH }();
    IWETH(weth).transfer(address(pair), distributed / JDFI_PER_ETH);
    _mint(address(pair), distributed);

    _feePool = payable(new FeePool(
      _jdfiStakingPool,
      _univ2StakingPool,
      _uniswapRouter,
      _uniswapPair
    ));

    _priceCumulativeLast =  address(this) > _weth ? pair.price0CumulativeLast() : pair.price1CumulativeLast();
    _blockTimestampLast = UniswapV2OracleLibrary.currentBlockTimestamp();

    IJDFIStakingPool(_jdfiStakingPool).unstake(remaining);
    _burn(address(this), balanceOf(address(this)));
    _burn(_feePool, balanceOf(_feePool));

    _mint(_feePool, REWARDS_SEED);
  }

  function _beforeTokenTransfer (address from, address to, uint amount) override internal {
    require(!_liquidityEventOpen, 'JusDeFi: liquidity event still in progress');
    super._beforeTokenTransfer(from, to, amount);

    address pair = _uniswapPair;

    if (from == pair || (to == pair && from != address(0))) {
      (
        uint price0Cumulative,
        uint price1Cumulative,
        uint32 blockTimestamp
      ) = UniswapV2OracleLibrary.currentCumulativePrices(pair);

      uint32 timeElapsed = blockTimestamp - _blockTimestampLast; // overflow is desired

      uint priceCumulative = address(this) > _weth ? price0Cumulative : price1Cumulative;

      if (timeElapsed >= ORACLE_PERIOD) {
        _priceAverage = FixedPoint.uq112x112(uint224((priceCumulative - _priceCumulativeLast) / timeElapsed));

        _priceCumulativeLast = priceCumulative;
        _blockTimestampLast = blockTimestamp;
      }
    }
  }
}// UNLICENSED

pragma solidity 0.7.4;


contract JusDeFiMock is JusDeFi {
  constructor (address airdropToken, address uniswapRouter) JusDeFi(airdropToken, uniswapRouter) {}

  function mint (address account, uint amount) external {
    _mint(account, amount);
  }

  function distributeJDFIStakingPoolRewards (uint amount) external {
    _mint(address(this), amount);
    IStakingPool(_jdfiStakingPool).distributeRewards(amount);
  }

  function distributeUNIV2StakingPoolRewards (uint amount) external {
    _mint(address(this), amount);
    IStakingPool(_univ2StakingPool).distributeRewards(amount);
  }
}// UNLICENSED

pragma solidity 0.7.4;


contract StakingPoolMock is StakingPool {
  constructor () ERC20('', '') {}

  function mint (address account, uint amount) external {
    _mint(account, amount);
  }

  function distributeRewards (uint amount) override external {
    _distributeRewards(amount);
  }

  function clearRewards (address account) external {
    _clearRewards(account);
  }

  function addToWhitelist (address account) external {
    _addToWhitelist(account);
  }

  function ignoreWhitelist () external {
    _ignoreWhitelist();
  }
}