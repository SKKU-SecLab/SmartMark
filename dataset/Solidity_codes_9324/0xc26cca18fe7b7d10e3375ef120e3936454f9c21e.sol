
pragma solidity 0.6.6;

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


  function getAmountsOut(uint256 amountIn, address[] calldata path)
    external
    view
    returns (uint256[] memory amounts);


  function getAmountsIn(uint256 amountOut, address[] calldata path)
    external
    view
    returns (uint256[] memory amounts);

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


interface IERC20 {

  function totalSupply() external view returns (uint256);


  function balanceOf(address account) external view returns (uint256);


  function transfer(address recipient, uint256 amount) external returns (bool);


  function allowance(address owner, address spender)
    external
    view
    returns (uint256);


  function approve(address spender, uint256 amount) external returns (bool);


  function transferFrom(
    address sender,
    address recipient,
    uint256 amount
  ) external returns (bool);


  event Transfer(address indexed from, address indexed to, uint256 value);

  event Approval(address indexed owner, address indexed spender, uint256 value);
}


contract ERC20 is IERC20 {

  using SafeMath for uint256;

  mapping(address => uint256) private _balances;

  mapping(address => mapping(address => uint256)) private _allowances;

  uint256 private _totalSupply;

  string private _name;
  string private _symbol;
  uint8 private _decimals;

  constructor(string memory name, string memory symbol) public {
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

  function totalSupply() public override view returns (uint256) {

    return _totalSupply;
  }

  function balanceOf(address account) public override view returns (uint256) {

    return _balances[account];
  }

  function transfer(address recipient, uint256 amount)
    public
    override
    returns (bool)
  {

    _transfer(msg.sender, recipient, amount);
    return true;
  }

  function allowance(address owner, address spender)
    public
    override
    view
    returns (uint256)
  {

    return _allowances[owner][spender];
  }

  function approve(address spender, uint256 amount)
    public
    override
    returns (bool)
  {

    _approve(msg.sender, spender, amount);
    return true;
  }

  function transferFrom(
    address sender,
    address recipient,
    uint256 amount
  ) public virtual override returns (bool) {

    _transfer(sender, recipient, amount);
    _approve(
      sender,
      msg.sender,
      _allowances[sender][msg.sender].sub(
        amount,
        'ERC20: transfer amount exceeds allowance'
      )
    );
    return true;
  }

  function increaseAllowance(address spender, uint256 addedValue)
    public
    returns (bool)
  {

    _approve(
      msg.sender,
      spender,
      _allowances[msg.sender][spender].add(addedValue)
    );
    return true;
  }

  function decreaseAllowance(address spender, uint256 subtractedValue)
    public
    virtual
    returns (bool)
  {

    _approve(
      msg.sender,
      spender,
      _allowances[msg.sender][spender].sub(
        subtractedValue,
        'ERC20: decreased allowance below zero'
      )
    );
    return true;
  }

  function _transfer(
    address sender,
    address recipient,
    uint256 amount
  ) internal virtual {

    require(sender != address(0), 'ERC20: transfer from the zero address');
    require(recipient != address(0), 'ERC20: transfer to the zero address');
    _balances[sender] = _balances[sender].sub(
      amount,
      'ERC20: transfer amount exceeds balance'
    );
    _balances[recipient] = _balances[recipient].add(amount);
    emit Transfer(sender, recipient, amount);
  }

  function _mint(address account, uint256 amount) internal virtual {

    require(account != address(0), 'ERC20: mint to the zero address');
    _totalSupply = _totalSupply.add(amount);
    _balances[account] = _balances[account].add(amount);
    emit Transfer(address(0), account, amount);
  }

  function _burn(address account, uint256 amount) internal virtual {

    require(account != address(0), 'ERC20: burn from the zero address');
    _balances[account] = _balances[account].sub(
      amount,
      'ERC20: burn amount exceeds balance'
    );
    _totalSupply = _totalSupply.sub(amount);
    emit Transfer(account, address(0), amount);
  }

  function _approve(
    address owner,
    address spender,
    uint256 amount
  ) internal virtual {

    require(owner != address(0), 'ERC20: approve from the zero address');
    require(spender != address(0), 'ERC20: approve to the zero address');

    _allowances[owner][spender] = amount;
    emit Approval(owner, spender, amount);
  }
}


abstract contract ERC20Burnable is ERC20 {
  function burn(uint256 amount) public virtual {
    _burn(msg.sender, amount);
  }

  function burnFrom(address account, uint256 amount) public virtual {
    uint256 decreasedAllowance = allowance(account, msg.sender).sub(
      amount,
      'ERC20: burn amount exceeds allowance'
    );
    _approve(account, msg.sender, decreasedAllowance);
    _burn(account, amount);
  }
}


contract Token is ERC20Burnable {

  using SafeMath for uint256;

  constructor(
    string memory name,
    string memory symbol,
    address recipient,
    uint256 totalSupply
  ) public ERC20(name, symbol) {
    _mint(recipient, totalSupply);
  }
}


contract UnistakeTokenSale {

  using SafeMath for uint256;

  struct Contributor {
        uint256 phase;
        uint256 remainder;
        uint256 fromTotalDivs;
    }
  
  address payable public immutable wallet;

  uint256 public immutable totalSupplyR1;
  uint256 public immutable totalSupplyR2;
  uint256 public immutable totalSupplyR3;

  uint256 public immutable totalSupplyUniswap;

  uint256 public immutable rateR1;
  uint256 public immutable rateR2;
  uint256 public immutable rateR3;

  uint256 public immutable periodDurationR3;

  uint256 public immutable timeDelayR1;
  uint256 public immutable timeDelayR2;

  uint256 public immutable stakingPeriodR1;
  uint256 public immutable stakingPeriodR2;
  uint256 public immutable stakingPeriodR3;

  Token public immutable token;
  IUniswapV2Router02 public immutable uniswapRouter;

  uint256 public immutable decreasingPctToken;
  uint256 public immutable decreasingPctETH;
  uint256 public immutable decreasingPctRate;
  uint256 public immutable decreasingPctBonus;
  
  uint256 public immutable listingRate;
  address public immutable platformStakingContract;

  mapping(address => bool)        private _contributor;
  mapping(address => Contributor) private _contributors;
  mapping(address => uint256)[3]  private _contributions;
  
  bool[3]    private _hasEnded;
  uint256[3] private _actualSupply;

  uint256 private _startTimeR2 = 2**256 - 1;
  uint256 private _startTimeR3 = 2**256 - 1;
  uint256 private _endTimeR3   = 2**256 - 1;

  mapping(address => bool)[3] private _hasWithdrawn;

  bool    private _bonusOfferingActive;
  uint256 private _bonusOfferingActivated;
  uint256 private _bonusTotal;
  
  uint256 private _contributionsTotal;

  uint256 private _contributorsTotal;
  uint256 private _contributedFundsTotal;
 
  uint256 private _bonusReductionFactor;
  uint256 private _fundsWithdrawn;
  
  uint256 private _endedDayR3;
  
  uint256 private _latestStakingPlatformPayment;
  
  uint256 private _totalDividends;
  uint256 private _scaledRemainder;
  uint256 private _scaling = uint256(10) ** 12;
  uint256 private _phase = 1;
  uint256 private _totalRestakedDividends;
  
  mapping(address => uint256) private _restkedDividends;
  mapping(uint256 => uint256) private _payouts;         

  
  event Staked(
      address indexed account, 
      uint256 amount);
      
  event Claimed(
      address indexed account, 
      uint256 amount);
      
  event Reclaimed(
      address indexed account, 
      uint256 amount);
      
  event Withdrawn(
      address indexed account, 
      uint256 amount); 
      
  event Penalized(
      address indexed account, 
      uint256 amount);
      
  event Ended(
      address indexed account, 
      uint256 amount, 
      uint256 time);
      
  event Splitted(
      address indexed account, 
      uint256 amount1, 
      uint256 amount2);  
  
  event Bought(
      uint8 indexed round, 
      address indexed account,
      uint256 amount);
      
  event Activated(
      bool status, 
      uint256 time);


  constructor(
    address tokenArg,
    uint256[3] memory totalSupplyArg,
    uint256 totalSupplyUniswapArg,
    uint256[3] memory ratesArg,
    uint256 periodDurationR3Arg,
    uint256 timeDelayR1Arg,
    uint256 timeDelayR2Arg,
    uint256[3] memory stakingPeriodArg,
    address uniswapRouterArg,
    uint256[4] memory decreasingPctArg,
    uint256 listingRateArg,
    address platformStakingContractArg,
    address payable walletArg
    ) public {
    for (uint256 j = 0; j < 3; j++) {
        require(totalSupplyArg[j] > 0, 
        "The 'totalSupplyArg' argument must be larger than zero");
        require(ratesArg[j] > 0, 
        "The 'ratesArg' argument must be larger than zero");
        require(stakingPeriodArg[j] > 0, 
        "The 'stakingPeriodArg' argument must be larger than zero");
    }
    for (uint256 j = 0; j < 4; j++) {
        require(decreasingPctArg[j] < 10000, 
        "The 'decreasingPctArg' arguments must be less than 100 percent");
    }
    require(totalSupplyUniswapArg > 0, 
    "The 'totalSupplyUniswapArg' argument must be larger than zero");
    require(periodDurationR3Arg > 0, 
    "The 'slotDurationR3Arg' argument must be larger than zero");
    require(tokenArg != address(0), 
    "The 'tokenArg' argument cannot be the zero address");
    require(uniswapRouterArg != address(0), 
    "The 'uniswapRouterArg' argument cannot be the zero addresss");
    require(listingRateArg > 0,
    "The 'listingRateArg' argument must be larger than zero");
    require(platformStakingContractArg != address(0), 
    "The 'vestingContractArg' argument cannot be the zero address");
    require(walletArg != address(0), 
    "The 'walletArg' argument cannot be the zero address");
    
    token = Token(tokenArg);
    
    totalSupplyR1 = totalSupplyArg[0];
    totalSupplyR2 = totalSupplyArg[1];
    totalSupplyR3 = totalSupplyArg[2];
    
    totalSupplyUniswap = totalSupplyUniswapArg;
    
    periodDurationR3 = periodDurationR3Arg;
    
    timeDelayR1 = timeDelayR1Arg;
    timeDelayR2 = timeDelayR2Arg;
    
    rateR1 = ratesArg[0];
    rateR2 = ratesArg[1];
    rateR3 = ratesArg[2];
    
    stakingPeriodR1 = stakingPeriodArg[0];
    stakingPeriodR2 = stakingPeriodArg[1];
    stakingPeriodR3 = stakingPeriodArg[2];
    
    uniswapRouter = IUniswapV2Router02(uniswapRouterArg);
    
    decreasingPctToken = decreasingPctArg[0];
    decreasingPctETH = decreasingPctArg[1];
    decreasingPctRate = decreasingPctArg[2];
    decreasingPctBonus = decreasingPctArg[3];
    
    listingRate = listingRateArg;
    
    platformStakingContract = platformStakingContractArg;
    wallet = walletArg;
  }
  
  receive() external payable {
      if (token.balanceOf(address(this)) > 0) {
          uint8 currentRound = _calculateCurrentRound();
          
          if (currentRound == 0) {
              _buyTokenR1();
          } else if (currentRound == 1) {
              _buyTokenR2();
          } else if (currentRound == 2) {
              _buyTokenR3();
          } else {
              revert("The stake offering rounds are not active");
          }
    } else {
        revert("The stake offering must be active");
    }
  }
  
  function closeR3() external {

      uint256 period = _calculatePeriod(block.timestamp);
      _closeR3(period);
  }
  
  function activateStakesAndUniswapLiquidity() external {

      require(_hasEnded[0] && _hasEnded[1] && _hasEnded[2], 
      "all rounds must have ended");
      require(!_bonusOfferingActive, 
      "the bonus offering and uniswap paring can only be done once per ISO");
      
      uint256[3] memory bonusSupplies = [
          (_actualSupply[0].mul(_bonusReductionFactor)).div(10000),
          (_actualSupply[1].mul(_bonusReductionFactor)).div(10000),
          (_actualSupply[2].mul(_bonusReductionFactor)).div(10000)
          ];
          
      uint256 totalSupply = totalSupplyR1.add(totalSupplyR2).add(totalSupplyR3);
      uint256 soldSupply = _actualSupply[0].add(_actualSupply[1]).add(_actualSupply[2]);
      uint256 unsoldSupply = totalSupply.sub(soldSupply);
          
      uint256 exceededBonus = totalSupply
      .sub(bonusSupplies[0])
      .sub(bonusSupplies[1])
      .sub(bonusSupplies[2]);
      
      uint256 exceededUniswapAmount = _createUniswapPair(_endedDayR3); 
      
      _bonusOfferingActive = true;
      _bonusOfferingActivated = block.timestamp;
      _bonusTotal = bonusSupplies[0].add(bonusSupplies[1]).add(bonusSupplies[2]);
      _contributionsTotal = soldSupply;
      
      _distribute(unsoldSupply.add(exceededBonus).add(exceededUniswapAmount));
     
      emit Activated(true, block.timestamp);
  }
  
  function restakeDividends() external {

      uint256 pending = _pendingDividends(msg.sender);
      pending = pending.add(_contributors[msg.sender].remainder);
      require(pending >= 0, "You do not have dividends to restake");
      _restkedDividends[msg.sender] = _restkedDividends[msg.sender].add(pending);
      _totalRestakedDividends = _totalRestakedDividends.add(pending);
      _bonusTotal = _bonusTotal.sub(pending);

      _contributors[msg.sender].phase = _phase;
      _contributors[msg.sender].remainder = 0;
      _contributors[msg.sender].fromTotalDivs = _totalDividends;
      
      emit Staked(msg.sender, pending);
  }

  function withdrawR1Tokens() external {

      require(_bonusOfferingActive, 
      "The bonus offering is not active yet");
      
      _withdrawTokens(0);
  }
 
  function withdrawR2Tokens() external {

      require(_bonusOfferingActive, 
      "The bonus offering is not active yet");
      
      _withdrawTokens(1);
  }
 
  function withdrawR3Tokens() external {

      require(_bonusOfferingActive, 
      "The bonus offering is not active yet");  

      _withdrawTokens(2);
  }
 
  function withdrawFunds() external {

      uint256 amount = ((address(this).balance).sub(_fundsWithdrawn)).div(2);
      
      _withdrawFunds(amount);
  }  
 
  function getRestakedDividendsTotal() external view returns (uint256) { 

      return _totalRestakedDividends;
  }
  
  function getStakingBonusesTotal() external view returns (uint256) {

      return _bonusTotal;
  }

  function getLatestStakingPlatformPayment() external view returns (uint256) {

      return _latestStakingPlatformPayment;
  }
 
  function getCurrentDayR3() external view returns (uint256) {

      if (_endedDayR3 != 0) {
          return _endedDayR3;
      }
      return _calculatePeriod(block.timestamp);
  }

  function getEndedDayR3() external view returns (uint256) {

      return _endedDayR3;
  }

  function getR2Start() external view returns (uint256) {

      return _startTimeR2;
  }

  function getR3Start() external view returns (uint256) {

      return _startTimeR3;
  }

  function getR3End() external view returns (uint256) {

      return _endTimeR3;
  }

  function getContributorsTotal() external view returns (uint256) {

      return _contributorsTotal;
  }

  function getContributedFundsTotal() external view returns (uint256) {

      return _contributedFundsTotal;
  }
  
  function getCurrentRound() external view returns (uint8) {

      uint8 round = _calculateCurrentRound();
      
      if (round == 0 && !_hasEnded[0]) {
          return 1;
      } 
      if (round == 1 && !_hasEnded[1] && _hasEnded[0]) {
          if (block.timestamp <= _startTimeR2) {
              return 0;
          }
          return 2;
      }
      if (round == 2 && !_hasEnded[2] && _hasEnded[1]) {
          if (block.timestamp <= _startTimeR3) {
              return 0;
          }
          return 3;
      } 
      else {
          return 0;
      }
  }

  function hasR1Ended() external view returns (bool) {

      return _hasEnded[0];
  }

  function hasR2Ended() external view returns (bool) {

      return _hasEnded[1];
  }

  function hasR3Ended() external view returns (bool) { 

      return _hasEnded[2];
  }

  function getRemainingTimeDelayR1R2() external view returns (uint256) {

      if (timeDelayR1 > 0) {
          if (_hasEnded[0] && !_hasEnded[1]) {
              if (_startTimeR2.sub(block.timestamp) > 0) {
                  return _startTimeR2.sub(block.timestamp);
              } else {
                  return 0;
              }
          } else {
              return 0;
          }
      } else {
          return 0;
      }
  }

  function getRemainingTimeDelayR2R3() external view returns (uint256) {

      if (timeDelayR2 > 0) {
          if (_hasEnded[0] && _hasEnded[1] && !_hasEnded[2]) {
              if (_startTimeR3.sub(block.timestamp) > 0) {
                  return _startTimeR3.sub(block.timestamp);
              } else {
                  return 0;
              }
          } else {
              return 0;
          }
      } else {
          return 0;
      }
  }

  function getR1Sales() external view returns (uint256) {

      return _actualSupply[0];
  }

  function getR2Sales() external view returns (uint256) {

      return _actualSupply[1];
  }

  function getR3Sales() external view returns (uint256) {

      return _actualSupply[2];
  }

  function getStakingActivationStatus() external view returns (bool) {

      return _bonusOfferingActive;
  }
  
  function claimDividends() public {

      if (_totalDividends > _contributors[msg.sender].fromTotalDivs) {
          uint256 pending = _pendingDividends(msg.sender);
          pending = pending.add(_contributors[msg.sender].remainder);
          require(pending >= 0, "You do not have dividends to claim");
          
          _contributors[msg.sender].phase = _phase;
          _contributors[msg.sender].remainder = 0;
          _contributors[msg.sender].fromTotalDivs = _totalDividends;
          
          _bonusTotal = _bonusTotal.sub(pending);

          require(token.transfer(msg.sender, pending), "Error in sending reward from contract");

          emit Claimed(msg.sender, pending);

      }
  }

  function withdrawRestakedDividends() public {

      uint256 amount = _restkedDividends[msg.sender];
      require(amount >= 0, "You do not have restaked dividends to withdraw");
      
      claimDividends();
      
      _restkedDividends[msg.sender] = 0;
      _totalRestakedDividends = _totalRestakedDividends.sub(amount);
      
      token.transfer(msg.sender, amount);      
      
      emit Reclaimed(msg.sender, amount);
  }    
  
  function getDividends(address accountArg) public view returns (uint256) {

      uint256 amount = ((_totalDividends.sub(_payouts[_contributors[accountArg].phase - 1])).mul(getContributionTotal(accountArg))).div(_scaling);
      amount += ((_totalDividends.sub(_payouts[_contributors[accountArg].phase - 1])).mul(getContributionTotal(accountArg))) % _scaling ;
      return (amount.add(_contributors[msg.sender].remainder));
  }
 
  function getRestakedDividends(address accountArg) public view returns (uint256) { 

      return _restkedDividends[accountArg];
  }

  function getR1Contribution(address accountArg) public view returns (uint256) {

      return _contributions[0][accountArg];
  }
  
  function getR2Contribution(address accountArg) public view returns (uint256) {

      return _contributions[1][accountArg];
  }
  
  function getR3Contribution(address accountArg) public view returns (uint256) { 

      return _contributions[2][accountArg];
  }

  function getContributionTotal(address accountArg) public view returns (uint256) {

      uint256 contributionR1 = getR1Contribution(accountArg);
      uint256 contributionR2 = getR2Contribution(accountArg);
      uint256 contributionR3 = getR3Contribution(accountArg);
      uint256 restaked = getRestakedDividends(accountArg);

      return contributionR1.add(contributionR2).add(contributionR3).add(restaked);
  }

  function getContributionsTotal() public view returns (uint256) {

      return _contributionsTotal.add(_totalRestakedDividends);
  }

  function getStakingBonusR1(address accountArg) public view returns (uint256) {

      uint256 contribution = _contributions[0][accountArg];
      
      return (contribution.mul(_bonusReductionFactor)).div(10000);
  }

  function getStakingBonusR2(address accountArg) public view returns (uint256) {

      uint256 contribution = _contributions[1][accountArg];
      
      return (contribution.mul(_bonusReductionFactor)).div(10000);
  }

  function getStakingBonusR3(address accountArg) public view returns (uint256) {

      uint256 contribution = _contributions[2][accountArg];
      
      return (contribution.mul(_bonusReductionFactor)).div(10000);
  }

  function getStakingBonusTotal(address accountArg) public view returns (uint256) {

      uint256 stakeR1 = getStakingBonusR1(accountArg);
      uint256 stakeR2 = getStakingBonusR2(accountArg);
      uint256 stakeR3 = getStakingBonusR3(accountArg);

      return stakeR1.add(stakeR2).add(stakeR3);
 }   

  function _distribute(uint256 amountArg) private {

      uint256 vested = amountArg.div(2);
      uint256 burned = amountArg.sub(vested);
      
      token.transfer(platformStakingContract, vested);
      token.burn(burned);
  }

  function _withdrawTokens(uint8 indexArg) private {

      require(_hasEnded[0] && _hasEnded[1] && _hasEnded[2], 
      "The rounds must be inactive before any tokens can be withdrawn");
      require(!_hasWithdrawn[indexArg][msg.sender], 
      "The caller must have withdrawable tokens available from this round");
      
      claimDividends();
      
      uint256 amount = _contributions[indexArg][msg.sender];
      uint256 amountBonus = (amount.mul(_bonusReductionFactor)).div(10000);
      
      _contributions[indexArg][msg.sender] = _contributions[indexArg][msg.sender].sub(amount);
      _contributionsTotal = _contributionsTotal.sub(amount);
      
      uint256 contributions = getContributionTotal(msg.sender);
      uint256 restaked = getRestakedDividends(msg.sender);
      
      if (contributions.sub(restaked) == 0) withdrawRestakedDividends();
    
      uint pending = _pendingDividends(msg.sender);
      _contributors[msg.sender].remainder = (_contributors[msg.sender].remainder).add(pending);
      _contributors[msg.sender].fromTotalDivs = _totalDividends;
      _contributors[msg.sender].phase = _phase;
      
      _hasWithdrawn[indexArg][msg.sender] = true;
      
      token.transfer(msg.sender, amount);
      
      _endStake(indexArg, msg.sender, amountBonus);
  }
 
  function _withdrawFunds(uint256 amountArg) private {

      require(msg.sender == wallet, 
      "The caller must be the specified funds wallet of the team");
      require(amountArg <= ((address(this).balance.sub(_fundsWithdrawn)).div(2)),
      "The 'amountArg' argument exceeds the limit");
      require(!_hasEnded[2], 
      "The third round is not active");
      
      _fundsWithdrawn = _fundsWithdrawn.add(amountArg);
      
      wallet.transfer(amountArg);
  }  

  function _buyTokenR1() private {

      if (token.balanceOf(address(this)) > 0) {
          require(!_hasEnded[0], 
          "The first round must be active");
          
          bool isRoundEnded = _buyToken(0, rateR1, totalSupplyR1);
          
          if (isRoundEnded == true) {
              _startTimeR2 = block.timestamp.add(timeDelayR1);
          }
      } else {
          revert("The stake offering must be active");
    }
  }
 
  function _buyTokenR2() private {

      require(_hasEnded[0] && !_hasEnded[1],
      "The first round one must not be active while the second round must be active");
      require(block.timestamp >= _startTimeR2,
      "The time delay between the first round and the second round must be surpassed");
      
      bool isRoundEnded = _buyToken(1, rateR2, totalSupplyR2);
      
      if (isRoundEnded == true) {
          _startTimeR3 = block.timestamp.add(timeDelayR2);
      }
  }
 
  function _buyTokenR3() private {

      require(_hasEnded[1] && !_hasEnded[2],
      "The second round one must not be active while the third round must be active");
      require(block.timestamp >= _startTimeR3,
      "The time delay between the first round and the second round must be surpassed"); 
      
      uint256 period = _calculatePeriod(block.timestamp);
      
      (bool isRoundClosed, uint256 actualPeriodTotalSupply) = _closeR3(period);

      if (!isRoundClosed) {
          bool isRoundEnded = _buyToken(2, rateR3, actualPeriodTotalSupply);
          
          if (isRoundEnded == true) {
              _endTimeR3 = block.timestamp;
              uint256 endingPeriod = _calculateEndingPeriod();
              uint256 reductionFactor = _calculateBonusReductionFactor(endingPeriod);
              _bonusReductionFactor = reductionFactor;
              _endedDayR3 = endingPeriod;
          }
      }
  }
  
  function _endStake(uint256 indexArg, address accountArg, uint256 amountArg) private {

      uint256 elapsedTime = (block.timestamp).sub(_bonusOfferingActivated);
      uint256 payout;
      
      uint256 duration = _getDuration(indexArg);
      
      if (elapsedTime >= duration) {
          payout = amountArg;
      } else if (elapsedTime >= duration.mul(3).div(4) && elapsedTime < duration) {
          payout = amountArg.mul(3).div(4);
      } else if (elapsedTime >= duration.div(2) && elapsedTime < duration.mul(3).div(4)) {
          payout = amountArg.div(2);
      } else if (elapsedTime >= duration.div(4) && elapsedTime < duration.div(2)) {
          payout = amountArg.div(4);
      } else {
          payout = 0;
      }
      
      _split(amountArg.sub(payout));
      
      if (payout != 0) {
          token.transfer(accountArg, payout);
      }
      
      emit Ended(accountArg, amountArg, block.timestamp);
  }
 
  function _split(uint256 amountArg) private {

      if (amountArg == 0) {
        return;
      }
      
      uint256 dividends = amountArg.div(2);
      uint256 platformStakingShare = amountArg.sub(dividends);
      
      _bonusTotal = _bonusTotal.sub(platformStakingShare);
      _latestStakingPlatformPayment = platformStakingShare;
      
      token.transfer(platformStakingContract, platformStakingShare);
      
      _addDividends(_latestStakingPlatformPayment);
      
      emit Splitted(msg.sender, dividends, platformStakingShare);
  }
  
  function _addDividends(uint256 bonusArg) private {

      uint256 latest = (bonusArg.mul(_scaling)).add(_scaledRemainder);
      uint256 dividendPerToken = latest.div(_contributionsTotal.add(_totalRestakedDividends));
      _scaledRemainder = latest.mod(_contributionsTotal.add(_totalRestakedDividends));
      _totalDividends = _totalDividends.add(dividendPerToken);
      _payouts[_phase] = _payouts[_phase-1].add(dividendPerToken);
      _phase++;
  }
  
  function _pendingDividends(address accountArg) private returns (uint256) {

      uint256 amount = ((_totalDividends.sub(_payouts[_contributors[accountArg].phase - 1])).mul(getContributionTotal(accountArg))).div(_scaling);
      _contributors[accountArg].remainder += ((_totalDividends.sub(_payouts[_contributors[accountArg].phase - 1])).mul(getContributionTotal(accountArg))) % _scaling ;
      return amount;
  }
  
  function _createUniswapPair(uint256 endingPeriodArg) private returns (uint256) {

      uint256 listingPrice = endingPeriodArg.mul(decreasingPctRate);

      uint256 ethDecrease = uint256(5000).sub(endingPeriodArg.mul(decreasingPctETH));
      uint256 ethOnUniswap = (_contributedFundsTotal.mul(ethDecrease)).div(10000);
      
      ethOnUniswap = ethOnUniswap <= (address(this).balance)
      ? ethOnUniswap
      : (address(this).balance);
      
      uint256 tokensOnUniswap = ethOnUniswap
      .mul(listingRate)
      .mul(10000)
      .div(uint256(10000).sub(listingPrice))
      .div(100000);
      
      token.approve(address(uniswapRouter), tokensOnUniswap);
      
      uniswapRouter.addLiquidityETH.value(ethOnUniswap)(
      address(token),
      tokensOnUniswap,
      0,
      0,
      wallet,
      block.timestamp
      );
      
      wallet.transfer(address(this).balance);
      
      return (totalSupplyUniswap.sub(tokensOnUniswap));
  } 
 
  function _closeR3(uint256 periodArg) private returns (bool isRoundEnded, uint256 maxPeriodSupply) {

      require(_hasEnded[0] && _hasEnded[1] && !_hasEnded[2],
      'Round 3 has ended or Round 1 or 2 have not ended yet');
      require(block.timestamp >= _startTimeR3,
      'Pause period between Round 2 and 3');
      
      uint256 decreasingTokenNumber = totalSupplyR3.mul(decreasingPctToken).div(10000);
      maxPeriodSupply = totalSupplyR3.sub(periodArg.mul(decreasingTokenNumber));
      
      if (maxPeriodSupply <= _actualSupply[2]) {
          msg.sender.transfer(msg.value);
          _hasEnded[2] = true;
          
          _endTimeR3 = block.timestamp;
          
          uint256 endingPeriod = _calculateEndingPeriod();
          uint256 reductionFactor = _calculateBonusReductionFactor(endingPeriod);
          
          _endedDayR3 = endingPeriod;
          
          _bonusReductionFactor = reductionFactor;
          return (true, maxPeriodSupply);
          
      } else {
          return (false, maxPeriodSupply);
      }
  }
 
  function _buyToken(uint8 indexArg, uint256 rateArg, uint256 totalSupplyArg) private returns (bool isRoundEnded) {

      uint256 tokensNumber = msg.value.mul(rateArg).div(100000);
      uint256 actualTotalBalance = _actualSupply[indexArg];
      uint256 newTotalRoundBalance = actualTotalBalance.add(tokensNumber);
      
      if (!_contributor[msg.sender]) {
          _contributor[msg.sender] = true;
          _contributorsTotal++;
      }  
      
      if (newTotalRoundBalance < totalSupplyArg) {
          _contributions[indexArg][msg.sender] = _contributions[indexArg][msg.sender].add(tokensNumber);
          _actualSupply[indexArg] = newTotalRoundBalance;
          _contributedFundsTotal = _contributedFundsTotal.add(msg.value);
          
          emit Bought(uint8(indexArg + 1), msg.sender, tokensNumber);
          
          return false;
          
      } else {
          uint256 availableTokens = totalSupplyArg.sub(actualTotalBalance);
          uint256 availableEth = availableTokens.mul(100000).div(rateArg);
          
          _contributions[indexArg][msg.sender] = _contributions[indexArg][msg.sender].add(availableTokens);
          _actualSupply[indexArg] = totalSupplyArg;
          _contributedFundsTotal = _contributedFundsTotal.add(availableEth);
          _hasEnded[indexArg] = true;
          
          msg.sender.transfer(msg.value.sub(availableEth));

          emit Bought(uint8(indexArg + 1), msg.sender, availableTokens);
          
          return true;
      }
  }

  function _getDuration(uint256 indexArg) private view returns (uint256) {

      if (indexArg == 0) {
          return stakingPeriodR1;
      }
      if (indexArg == 1) {
          return stakingPeriodR2;
      }
      if (indexArg == 2) {
          return stakingPeriodR3;
      }
    }
 
  function _calculateBonusReductionFactor(uint256 periodArg) private view returns (uint256) {

      uint256 reductionFactor = uint256(10000).sub(periodArg.mul(decreasingPctBonus));
      return reductionFactor;
  } 
 
  function _calculateCurrentRound() private view returns (uint8) {

      if (!_hasEnded[0]) {
          return 0;
      } else if (_hasEnded[0] && !_hasEnded[1] && !_hasEnded[2]) {
          return 1;
      } else if (_hasEnded[0] && _hasEnded[1] && !_hasEnded[2]) {
          return 2;
      } else {
          return 2**8 - 1;
      }
  }
 
  function _calculatePeriod(uint256 timeArg) private view returns (uint256) {

      uint256 period = ((timeArg.sub(_startTimeR3)).div(periodDurationR3));
      uint256 maxPeriods = uint256(10000).div(decreasingPctToken);
      
      if (period > maxPeriods) {
          return maxPeriods;
      }
      return period;
  }
 
  function _calculateEndingPeriod() private view returns (uint256) {

      require(_endTimeR3 != (2**256) - 1, 
      "The third round must be active");
      
      uint256 endingPeriod = _calculatePeriod(_endTimeR3);
      return endingPeriod;
  }
 

  
  
  
  
  
}