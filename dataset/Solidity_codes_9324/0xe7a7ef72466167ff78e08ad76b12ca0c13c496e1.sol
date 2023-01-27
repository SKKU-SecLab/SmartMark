
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

}// MIT

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


abstract contract ERC20 is Context, IERC20, IERC20Metadata {
    mapping (address => uint256) internal _balances;

    mapping (address => mapping (address => uint256)) private _allowances;

    uint256 internal _totalSupply;

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
}// UNLICENSED

pragma solidity ^0.8.0;

abstract contract StakingPool {
  uint private constant SCALE = 1e18;
  uint private _rewardPerToken;
  mapping (address => uint) private _rewardsAccounted;
  mapping (address => uint) private _rewardsSkipped;

  mapping (address => uint) private _taxCredits;
  uint private _taxCreditsTotal;

  function taxCreditsOf (
    address account
  ) public view returns (uint) {
    return _taxCredits[account];
  }

  function taxRewardsOf (
    address account
  ) public view returns (uint) {
    return (_taxCredits[account] * _rewardPerToken + _rewardsAccounted[account] - _rewardsSkipped[account]) / SCALE;
  }

  function _distributeTax (
    uint amount
  ) internal {
    _rewardPerToken += amount * SCALE / _taxCreditsTotal;
  }

  function _mintTaxCredit (
    address account,
    uint amount
  ) internal {
    uint skipped = taxCreditsOf(account) * _rewardPerToken;
    _rewardsAccounted[account] += skipped - _rewardsSkipped[account];
    _rewardsSkipped[account] = skipped - amount * _rewardPerToken;

    _taxCredits[account] += amount;
    _taxCreditsTotal += amount;
  }

  function _burnTaxCredit (
    address account
  ) internal {
    _taxCreditsTotal -= _taxCredits[account];
    delete _taxCredits[account];
  }
}// UNLICENSED

pragma solidity ^0.8.0;


contract DogstonksPro is ERC20, StakingPool {

  using Address for address payable;

  enum Phase { PENDING, LIQUIDITY_EVENT, OPEN, CLOSED }

  Phase public _phase;
  uint public _phaseChangedAt;

  string public override name = 'DogstonksPro (dogstonks.com)';
  string public override symbol = 'DOGPRO';

  address private constant UNISWAP_ROUTER = 0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D;
  address private constant WETH = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;
  address private constant DOGSTONKS = 0xC9aA1007b1619d04C1911E48A8a7a95770BE21a2;

  uint private constant SUPPLY = 1e12 ether;

  uint private constant TAX_RATE = 1000;
  uint private constant BP_DIVISOR = 10000;

  uint private constant V1_VALUE = 12.659726999081298826 ether;
  uint private constant V1_SUPPLY = 913290958465.509630323815153677 ether;

  address private _owner;
  address private _pair;

  uint private _initialBasis;

  mapping (address => uint) private _basisOf;
  mapping (address => uint) public cooldownOf;

  mapping (address => uint) private _lpCredits;
  uint private _lpCreditsTotal;

  uint private _holderDistributionUNIV2;
  uint private _holderDistributionETH;
  uint private _lpDistributionETH;

  uint private _ath;
  uint private _athTimestamp;

  address private _lastOrigin;
  uint private _lastBlock;

  bool private _nohook;

  struct Minting {
    address recipient;
    uint amount;
  }

  modifier phase (Phase p) {

    require(_phase == p, 'ERR: invalid phase');
    _;
  }

  modifier nohook () {

    _nohook = true;
    _;
    _nohook = false;
  }

  constructor (
    Minting[] memory mintings
  ) payable {
    _owner = msg.sender;
    _phaseChangedAt = block.timestamp;


    _pair = IUniswapV2Factory(
      IUniswapV2Router02(UNISWAP_ROUTER).factory()
    ).createPair(WETH, address(this));


    _approve(address(this), UNISWAP_ROUTER, type(uint).max);
    IERC20(_pair).approve(UNISWAP_ROUTER, type(uint).max);


    uint mintedSupply;

    for (uint i; i < mintings.length; i++) {
      Minting memory m = mintings[i];
      uint amount = m.amount;
      address recipient = m.recipient;

      mintedSupply += amount;
      _balances[recipient] += amount;
      emit Transfer(address(0), recipient, amount);
    }

    _totalSupply = mintedSupply;
  }

  receive () external payable {}

  function balanceOf (
    address account
  ) override public view returns (uint) {
    if (msg.sender == _pair && tx.origin == _lastOrigin && block.number == _lastBlock) {
      (uint res0, uint res1, ) = IUniswapV2Pair(_pair).getReserves();
      require(
        (address(this) > WETH ? res0 : res1) > IERC20(WETH).balanceOf(_pair),
        'ERR: liquidity add'
      );
    }
    return super.balanceOf(account);
  }

  function basisOf (
    address account
  ) public view returns (uint) {
    uint basis = _basisOf[account];

    if (basis == 0 && balanceOf(account) > 0) {
      basis = _initialBasis;
    }

    return basis;
  }

  function basisOfSale (
    uint amount
  ) public view returns (uint) {
    address[] memory path = new address[](2);
    path[0] = address(this);
    path[1] = WETH;

    uint[] memory amounts = IUniswapV2Router02(UNISWAP_ROUTER).getAmountsOut(
      amount,
      path
    );

    return (1 ether) * amounts[1] / amount;
  }

  function taxFor (
    uint fromBasis,
    uint toBasis,
    uint amount
  ) public pure returns (uint) {
    return amount * (toBasis - fromBasis) / toBasis * TAX_RATE / BP_DIVISOR;
  }

  function openLiquidityEvent () external phase(Phase.PENDING) {
    require(
      msg.sender == _owner || block.timestamp > _phaseChangedAt + (2 weeks),
      'ERR: sender must be owner'
    );

    _incrementPhase();


    _lpCredits[address(this)] = address(this).balance;
    _lpCreditsTotal += address(this).balance;


    _mint(address(this), SUPPLY - totalSupply());

    IUniswapV2Router02(
      UNISWAP_ROUTER
    ).addLiquidityETH{
      value: address(this).balance
    }(
      address(this),
      balanceOf(address(this)),
      0,
      0,
      address(this),
      block.timestamp
    );
  }

  function contributeV1 () external {
    require(_phase == Phase.LIQUIDITY_EVENT || _phase == Phase.OPEN, 'ERR: invalid phase');

    uint amount = IERC20(DOGSTONKS).balanceOf(msg.sender);
    IERC20(DOGSTONKS).transferFrom(msg.sender, DOGSTONKS, amount);

    address[] memory path = new address[](2);
    path[0] = WETH;
    path[1] = address(this);

    uint[] memory amounts = IUniswapV2Router02(
      UNISWAP_ROUTER
    ).getAmountsOut(
      amount * V1_VALUE / V1_SUPPLY,
      path
    );


    _mintTaxCredit(msg.sender, amounts[1]);
  }

  function contributeETH () external payable phase(Phase.LIQUIDITY_EVENT) nohook {
    if (block.timestamp < _phaseChangedAt + (15 minutes)) {
      require(
        taxCreditsOf(msg.sender) >= 1e6 ether || balanceOf(msg.sender) > 0,
        'ERR: must contribute V1 tokens'
      );
    }


    address[] memory path = new address[](2);
    path[0] = WETH;
    path[1] = address(this);

    uint[] memory amounts = IUniswapV2Router02(
      UNISWAP_ROUTER
    ).swapExactETHForTokens{
      value: msg.value
    }(
      0,
      path,
      msg.sender,
      block.timestamp
    );

    _transfer(msg.sender, _pair, amounts[1]);
    IUniswapV2Pair(_pair).sync();


    _mintTaxCredit(msg.sender, amounts[1]);
    _lpCredits[msg.sender] += msg.value;
    _lpCreditsTotal += msg.value;
  }

  function open () external phase(Phase.LIQUIDITY_EVENT) {
    require(
      msg.sender == _owner || block.timestamp > _phaseChangedAt + (1 hours),
      'ERR: sender must be owner'
    );

    _incrementPhase();


    _initialBasis = (1 ether) * IERC20(WETH).balanceOf(_pair) / balanceOf(_pair);


    _holderDistributionUNIV2 = IERC20(_pair).totalSupply() * _lpCredits[address(this)] / _lpCreditsTotal;
  }

  function addLiquidity (
    uint amount
  ) external payable phase(Phase.OPEN) {
    _transfer(msg.sender, address(this), amount);

    uint liquidityETH = IERC20(WETH).balanceOf(_pair);

    (uint amountToken, uint amountETH, ) = IUniswapV2Router02(
      UNISWAP_ROUTER
    ).addLiquidityETH{
      value: msg.value
    }(
      address(this),
      amount,
      0,
      0,
      address(this),
      block.timestamp
    );

    if (amountToken < amount) {
      _transfer(address(this), msg.sender, amount - amountToken);
    }

    if (amountETH < msg.value) {
      payable(msg.sender).sendValue(msg.value - amountETH);
    }

    uint lpCreditsDelta = _lpCreditsTotal * amountETH / liquidityETH;
    _lpCredits[msg.sender] += lpCreditsDelta;
    _lpCreditsTotal += lpCreditsDelta;

    _mintTaxCredit(msg.sender, amountToken);
  }

  function close () external phase(Phase.OPEN) {
    require(block.timestamp > _phaseChangedAt + (1 days), 'ERR: too soon');

    _incrementPhase();

    require(
      block.timestamp > _athTimestamp + (1 weeks),
      'ERR: recent ATH'
    );

    uint univ2 = IERC20(_pair).balanceOf(address(this));

    (uint amountToken, ) = IUniswapV2Router02(
      UNISWAP_ROUTER
    ).removeLiquidityETH(
      address(this),
      univ2,
      0,
      0,
      address(this),
      block.timestamp
    );

    _burn(address(this), amountToken);


    _holderDistributionETH = address(this).balance * _holderDistributionUNIV2 / univ2;
    _lpDistributionETH = address(this).balance - _holderDistributionETH;


    _lpCreditsTotal -= _lpCredits[address(this)];
    delete _lpCredits[address(this)];
  }

  function liquidate () external phase(Phase.CLOSED) {

    if (taxCreditsOf(msg.sender) > 0) {
      _transfer(address(this), msg.sender, taxRewardsOf(msg.sender));
      _burnTaxCredit(msg.sender);
    }


    uint balance = balanceOf(msg.sender);
    uint holderPayout;

    if (balance > 0) {
      holderPayout = _holderDistributionETH * balance / totalSupply();
      _holderDistributionETH -= holderPayout;
      _burn(msg.sender, balance);
    }


    uint lpCredits = _lpCredits[msg.sender];
    uint lpPayout;

    if (lpCredits > 0) {
      lpPayout = _lpDistributionETH * lpCredits / _lpCreditsTotal;
      _lpDistributionETH -= lpPayout;

      delete _lpCredits[msg.sender];
      _lpCreditsTotal -= lpCredits;
    }

    payable(msg.sender).sendValue(holderPayout + lpPayout);
  }

  function liquidateUnclaimed () external phase(Phase.CLOSED) {
    require(block.timestamp > _phaseChangedAt + (52 weeks), 'ERR: too soon');
    payable(_owner).sendValue(address(this).balance);
  }

  function _incrementPhase () private {
    _phase = Phase(uint8(_phase) + 1);
    _phaseChangedAt = block.timestamp;
  }

  function _beforeTokenTransfer (
    address from,
    address to,
    uint amount
  ) override internal {
    super._beforeTokenTransfer(from, to, amount);

    if (_nohook) return;

    if (from == address(0) || to == address(0)) return;

    if (from == address(this) || to == address(this)) return;
    if (from == UNISWAP_ROUTER || to == UNISWAP_ROUTER) return;

    require(uint8(_phase) >= uint8(Phase.OPEN));

    require(
      msg.sender == UNISWAP_ROUTER || msg.sender == _pair,
      'ERR: sender must be uniswap'
    );
    require(amount <= 5e9 ether /* revert message not returned by Uniswap */);

    if (from == _pair) {
      require(cooldownOf[to] < block.timestamp /* revert message not returned by Uniswap */);
      cooldownOf[to] = block.timestamp + (5 minutes);

      address[] memory path = new address[](2);
      path[0] = WETH;
      path[1] = address(this);

      uint[] memory amounts = IUniswapV2Router02(UNISWAP_ROUTER).getAmountsIn(
        amount,
        path
      );

      uint balance = balanceOf(to);
      uint fromBasis = (1 ether) * amounts[0] / amount;
      _basisOf[to] = (fromBasis * amount + basisOf(to) * balance) / (amount + balance);

      if (fromBasis > _ath) {
        _ath = fromBasis;
        _athTimestamp = block.timestamp;
      }
    } else if (to == _pair) {
      _lastOrigin = tx.origin;
      _lastBlock = block.number;

      require(cooldownOf[from] < block.timestamp /* revert message not returned by Uniswap */);
      cooldownOf[from] = block.timestamp + (5 minutes);

      uint fromBasis = basisOf(from);
      uint toBasis = basisOfSale(amount);

      require(fromBasis <= toBasis /* revert message not returned by Uniswap */);

      uint tax = taxFor(fromBasis, toBasis, amount);
      _transfer(from, address(this), tax);
      _distributeTax(tax);
    }
  }
}