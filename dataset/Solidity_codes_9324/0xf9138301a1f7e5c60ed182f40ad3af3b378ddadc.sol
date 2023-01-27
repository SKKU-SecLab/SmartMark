
pragma solidity 0.5.8;

library SafeMath {

    function add(uint256 a, uint256 b) internal pure returns (uint256) {

        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b <= a, "SafeMath: subtraction overflow");
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

        require(b > 0, "SafeMath: division by zero");
        uint256 c = a / b;

        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b != 0, "SafeMath: modulo by zero");
        return a % b;
    }
}

contract Ownable {

    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor () internal {
        _owner = msg.sender;
        emit OwnershipTransferred(address(0), _owner);
    }

    function owner() public view returns (address) {

        return _owner;
    }

    modifier onlyOwner() {

        require(isOwner(), "Ownable: caller is not the owner");
        _;
    }

    function isOwner() public view returns (bool) {

        return msg.sender == _owner;
    }

    function renounceOwnership() public onlyOwner {

        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    function transferOwnership(address newOwner) public onlyOwner {

        _transferOwnership(newOwner);
    }

    function _transferOwnership(address newOwner) internal {

        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

contract ReentrancyGuard {

    uint256 private _guardCounter;

    constructor () internal {
        _guardCounter = 1;
    }

    modifier nonReentrant() {

        _guardCounter += 1;
        uint256 localCounter = _guardCounter;
        _;
        require(localCounter == _guardCounter, "ReentrancyGuard: reentrant call");
    }
}

interface IMiniMeToken {

    function balanceOf(address _owner) external view returns (uint256 balance);

    function totalSupply() external view returns(uint);

    function generateTokens(address _owner, uint _amount) external returns (bool);

    function destroyTokens(address _owner, uint _amount) external returns (bool);

    function totalSupplyAt(uint _blockNumber) external view returns(uint);

    function balanceOfAt(address _holder, uint _blockNumber) external view returns (uint);

    function transferOwnership(address newOwner) external;

}

contract TokenController {

  function proxyPayment(address _owner) public payable returns(bool);


  function onTransfer(address _from, address _to, uint _amount) public returns(bool);


  function onApprove(address _owner, address _spender, uint _amount) public
    returns(bool);

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

contract ERC20Detailed is IERC20 {

    string private _name;
    string private _symbol;
    uint8 private _decimals;

    constructor (string memory name, string memory symbol, uint8 decimals) public {
        _name = name;
        _symbol = symbol;
        _decimals = decimals;
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
}

library Address {

    function isContract(address account) internal view returns (bool) {


        uint256 size;
        assembly { size := extcodesize(account) }
        return size > 0;
    }
}

library SafeERC20 {

    using SafeMath for uint256;
    using Address for address;

    function safeTransfer(IERC20 token, address to, uint256 value) internal {

        callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(IERC20 token, address from, address to, uint256 value) internal {

        callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    function safeApprove(IERC20 token, address spender, uint256 value) internal {

        require((value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(IERC20 token, address spender, uint256 value) internal {

        uint256 newAllowance = token.allowance(address(this), spender).add(value);
        callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(IERC20 token, address spender, uint256 value) internal {

        uint256 newAllowance = token.allowance(address(this), spender).sub(value);
        callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function callOptionalReturn(IERC20 token, bytes memory data) private {


        require(address(token).isContract(), "SafeERC20: call to non-contract");

        (bool success, bytes memory returndata) = address(token).call(data);
        require(success, "SafeERC20: low-level call failed");

        if (returndata.length > 0) { // Return data is optional
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}

interface KyberNetwork {

  function getExpectedRate(ERC20Detailed src, ERC20Detailed dest, uint srcQty) external view
      returns (uint expectedRate, uint slippageRate);


  function tradeWithHint(
    ERC20Detailed src, uint srcAmount, ERC20Detailed dest, address payable destAddress, uint maxDestAmount,
    uint minConversionRate, address walletId, bytes calldata hint) external payable returns(uint);

}

contract Utils {

  using SafeMath for uint256;
  using SafeERC20 for ERC20Detailed;

  modifier isValidToken(address _token) {

    require(_token != address(0));
    if (_token != address(ETH_TOKEN_ADDRESS)) {
      require(isContract(_token));
    }
    _;
  }

  address public DAI_ADDR;
  address payable public KYBER_ADDR;
  
  bytes public constant PERM_HINT = "PERM";

  ERC20Detailed internal constant ETH_TOKEN_ADDRESS = ERC20Detailed(0x00eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee);
  ERC20Detailed internal dai;
  KyberNetwork internal kyber;

  uint constant internal PRECISION = (10**18);
  uint constant internal MAX_QTY   = (10**28); // 10B tokens
  uint constant internal ETH_DECIMALS = 18;
  uint constant internal MAX_DECIMALS = 18;

  constructor(
    address _daiAddr,
    address payable _kyberAddr
  ) public {
    DAI_ADDR = _daiAddr;
    KYBER_ADDR = _kyberAddr;

    dai = ERC20Detailed(_daiAddr);
    kyber = KyberNetwork(_kyberAddr);
  }

  function getDecimals(ERC20Detailed _token) internal view returns(uint256) {

    if (address(_token) == address(ETH_TOKEN_ADDRESS)) {
      return uint256(ETH_DECIMALS);
    }
    return uint256(_token.decimals());
  }

  function getBalance(ERC20Detailed _token, address _addr) internal view returns(uint256) {

    if (address(_token) == address(ETH_TOKEN_ADDRESS)) {
      return uint256(_addr.balance);
    }
    return uint256(_token.balanceOf(_addr));
  }

  function calcRateFromQty(uint srcAmount, uint destAmount, uint srcDecimals, uint dstDecimals)
        internal pure returns(uint)
  {

    require(srcAmount <= MAX_QTY);
    require(destAmount <= MAX_QTY);

    if (dstDecimals >= srcDecimals) {
      require((dstDecimals - srcDecimals) <= MAX_DECIMALS);
      return (destAmount * PRECISION / ((10 ** (dstDecimals - srcDecimals)) * srcAmount));
    } else {
      require((srcDecimals - dstDecimals) <= MAX_DECIMALS);
      return (destAmount * PRECISION * (10 ** (srcDecimals - dstDecimals)) / srcAmount);
    }
  }

  function __kyberTrade(ERC20Detailed _srcToken, uint256 _srcAmount, ERC20Detailed _destToken)
    internal
    returns(
      uint256 _destPriceInSrc,
      uint256 _srcPriceInDest,
      uint256 _actualDestAmount,
      uint256 _actualSrcAmount
    )
  {

    require(_srcToken != _destToken);

    (, uint256 rate) = kyber.getExpectedRate(_srcToken, _destToken, _srcAmount);
    require(rate > 0);

    uint256 beforeSrcBalance = getBalance(_srcToken, address(this));
    uint256 msgValue;
    if (_srcToken != ETH_TOKEN_ADDRESS) {
      msgValue = 0;
      _srcToken.safeApprove(KYBER_ADDR, 0);
      _srcToken.safeApprove(KYBER_ADDR, _srcAmount);
    } else {
      msgValue = _srcAmount;
    }
    _actualDestAmount = kyber.tradeWithHint.value(msgValue)(
      _srcToken,
      _srcAmount,
      _destToken,
      toPayableAddr(address(this)),
      MAX_QTY,
      rate,
      0x332D87209f7c8296389C307eAe170c2440830A47,
      PERM_HINT
    );
    require(_actualDestAmount > 0);
    if (_srcToken != ETH_TOKEN_ADDRESS) {
      _srcToken.safeApprove(KYBER_ADDR, 0);
    }

    _actualSrcAmount = beforeSrcBalance.sub(getBalance(_srcToken, address(this)));
    _destPriceInSrc = calcRateFromQty(_actualDestAmount, _actualSrcAmount, getDecimals(_destToken), getDecimals(_srcToken));
    _srcPriceInDest = calcRateFromQty(_actualSrcAmount, _actualDestAmount, getDecimals(_srcToken), getDecimals(_destToken));
  }

  function isContract(address _addr) view internal returns(bool) {

    uint size;
    if (_addr == address(0)) return false;
    assembly {
        size := extcodesize(_addr)
    }
    return size>0;
  }

  function toPayableAddr(address _addr) pure internal returns (address payable) {

    return address(uint160(_addr));
  }
}

interface BetokenProxyInterface {

  function betokenFundAddress() external view returns (address payable);

  function updateBetokenFundAddress() external;

}

contract BetokenStorage is Ownable, ReentrancyGuard {

  using SafeMath for uint256;

  enum CyclePhase { Intermission, Manage }
  enum VoteDirection { Empty, For, Against }
  enum Subchunk { Propose, Vote }

  struct Investment {
    address tokenAddress;
    uint256 cycleNumber;
    uint256 stake;
    uint256 tokenAmount;
    uint256 buyPrice; // token buy price in 18 decimals in DAI
    uint256 sellPrice; // token sell price in 18 decimals in DAI
    uint256 buyTime;
    uint256 buyCostInDAI;
    bool isSold;
  }

  uint256 public constant COMMISSION_RATE = 20 * (10 ** 16); // The proportion of profits that gets distributed to Kairo holders every cycle.
  uint256 public constant ASSET_FEE_RATE = 1 * (10 ** 15); // The proportion of fund balance that gets distributed to Kairo holders every cycle.
  uint256 public constant NEXT_PHASE_REWARD = 1 * (10 ** 18); // Amount of Kairo rewarded to the user who calls nextPhase().
  uint256 public constant MAX_BUY_KRO_PROP = 1 * (10 ** 16); // max Kairo you can buy is 1% of total supply
  uint256 public constant FALLBACK_MAX_DONATION = 100 * (10 ** 18); // If payment cap for registration is below 100 DAI, use 100 DAI instead
  uint256 public constant MIN_KRO_PRICE = 25 * (10 ** 17); // 1 KRO >= 2.5 DAI
  uint256 public constant COLLATERAL_RATIO_MODIFIER = 75 * (10 ** 16); // Modifies Compound's collateral ratio, gets 2:1 ratio from current 1.5:1 ratio
  uint256 public constant MIN_RISK_TIME = 9 days; // Mininum risk taken to get full commissions is 9 days * kairoBalance
  uint256 public constant INACTIVE_THRESHOLD = 6; // Number of inactive cycles after which a manager's Kairo balance can be burned
  uint256 public constant CHUNK_SIZE = 3 days;
  uint256 public constant PROPOSE_SUBCHUNK_SIZE = 1 days;
  uint256 public constant CYCLES_TILL_MATURITY = 3;
  uint256 public constant QUORUM = 10 * (10 ** 16); // 10% quorum
  uint256 public constant VOTE_SUCCESS_THRESHOLD = 75 * (10 ** 16); // Votes on upgrade candidates need >75% voting weight to pass


  bool public hasInitializedTokenListings;

  address public controlTokenAddr;

  address public shareTokenAddr;

  address payable public proxyAddr;

  address public compoundFactoryAddr;

  address public betokenLogic;

  address payable public devFundingAccount;

  address payable public previousVersion;

  uint256 public cycleNumber;

  uint256 public totalFundsInDAI;

  uint256 public startTimeOfCyclePhase;

  uint256 public devFundingRate;

  uint256 public totalCommissionLeft;

  uint256[2] public phaseLengths;

  mapping(address => uint256) public lastCommissionRedemption;

  mapping(address => mapping(uint256 => bool)) public hasRedeemedCommissionForCycle;

  mapping(address => mapping(uint256 => uint256)) public riskTakenInCycle;

  mapping(address => uint256) public baseRiskStakeFallback;

  mapping(address => Investment[]) public userInvestments;

  mapping(address => address payable[]) public userCompoundOrders;

  mapping(uint256 => uint256) public totalCommissionOfCycle;

  mapping(uint256 => uint256) public managePhaseEndBlock;

  mapping(address => uint256) public lastActiveCycle;

  mapping(address => bool) public isKyberToken;

  mapping(address => bool) public isCompoundToken;

  mapping(address => bool) public isPositionToken;

  CyclePhase public cyclePhase;

  bool public hasFinalizedNextVersion; // Denotes if the address of the next smart contract version has been finalized
  bool public upgradeVotingActive; // Denotes if the vote for which contract to upgrade to is active
  address payable public nextVersion; // Address of the next version of BetokenFund.
  address[5] public proposers; // Manager who proposed the upgrade candidate in a chunk
  address payable[5] public candidates; // Candidates for a chunk
  uint256[5] public forVotes; // For votes for a chunk
  uint256[5] public againstVotes; // Against votes for a chunk
  uint256 public proposersVotingWeight; // Total voting weight of previous and current proposers. This is used for excluding the voting weight of proposers.
  mapping(uint256 => mapping(address => VoteDirection[5])) public managerVotes; // Records each manager's vote
  mapping(uint256 => uint256) public upgradeSignalStrength; // Denotes the amount of Kairo that's signalling in support of beginning the upgrade process during a cycle
  mapping(uint256 => mapping(address => bool)) public upgradeSignal; // Maps manager address to whether they support initiating an upgrade

  IMiniMeToken internal cToken;
  IMiniMeToken internal sToken;
  BetokenProxyInterface internal proxy;


  event ChangedPhase(uint256 indexed _cycleNumber, uint256 indexed _newPhase, uint256 _timestamp, uint256 _totalFundsInDAI);

  event Deposit(uint256 indexed _cycleNumber, address indexed _sender, address _tokenAddress, uint256 _tokenAmount, uint256 _daiAmount, uint256 _timestamp);
  event Withdraw(uint256 indexed _cycleNumber, address indexed _sender, address _tokenAddress, uint256 _tokenAmount, uint256 _daiAmount, uint256 _timestamp);

  event CreatedInvestment(uint256 indexed _cycleNumber, address indexed _sender, uint256 _id, address _tokenAddress, uint256 _stakeInWeis, uint256 _buyPrice, uint256 _costDAIAmount, uint256 _tokenAmount);
  event SoldInvestment(uint256 indexed _cycleNumber, address indexed _sender, uint256 _id, address _tokenAddress, uint256 _receivedKairo, uint256 _sellPrice, uint256 _earnedDAIAmount);

  event CreatedCompoundOrder(uint256 indexed _cycleNumber, address indexed _sender, uint256 _id, address _order, bool _orderType, address _tokenAddress, uint256 _stakeInWeis, uint256 _costDAIAmount);
  event SoldCompoundOrder(uint256 indexed _cycleNumber, address indexed _sender, uint256 _id, address _order,  bool _orderType, address _tokenAddress, uint256 _receivedKairo, uint256 _earnedDAIAmount);
  event RepaidCompoundOrder(uint256 indexed _cycleNumber, address indexed _sender, uint256 _id, address _order, uint256 _repaidDAIAmount);

  event CommissionPaid(uint256 indexed _cycleNumber, address indexed _sender, uint256 _commission);
  event TotalCommissionPaid(uint256 indexed _cycleNumber, uint256 _totalCommissionInDAI);

  event Register(address indexed _manager, uint256 _donationInDAI, uint256 _kairoReceived);
  
  event SignaledUpgrade(uint256 indexed _cycleNumber, address indexed _sender, bool indexed _inSupport);
  event DeveloperInitiatedUpgrade(uint256 indexed _cycleNumber, address _candidate);
  event InitiatedUpgrade(uint256 indexed _cycleNumber);
  event ProposedCandidate(uint256 indexed _cycleNumber, uint256 indexed _voteID, address indexed _sender, address _candidate);
  event Voted(uint256 indexed _cycleNumber, uint256 indexed _voteID, address indexed _sender, bool _inSupport, uint256 _weight);
  event FinalizedNextVersion(uint256 indexed _cycleNumber, address _nextVersion);


  function currentChunk() public view returns (uint) {

    if (cyclePhase != CyclePhase.Manage) {
      return 0;
    }
    return (now - startTimeOfCyclePhase) / CHUNK_SIZE;
  }

  function currentSubchunk() public view returns (Subchunk _subchunk) {

    if (cyclePhase != CyclePhase.Manage) {
      return Subchunk.Vote;
    }
    uint256 timeIntoCurrChunk = (now - startTimeOfCyclePhase) % CHUNK_SIZE;
    return timeIntoCurrChunk < PROPOSE_SUBCHUNK_SIZE ? Subchunk.Propose : Subchunk.Vote;
  }

  function getVotingWeight(address _of) public view returns (uint256 _weight) {

    if (cycleNumber <= CYCLES_TILL_MATURITY || _of == address(0)) {
      return 0;
    }
    return cToken.balanceOfAt(_of, managePhaseEndBlock[cycleNumber.sub(CYCLES_TILL_MATURITY)]);
  }

  function getTotalVotingWeight() public view returns (uint256 _weight) {

    if (cycleNumber <= CYCLES_TILL_MATURITY) {
      return 0;
    }
    return cToken.totalSupplyAt(managePhaseEndBlock[cycleNumber.sub(CYCLES_TILL_MATURITY)]).sub(proposersVotingWeight);
  }

  function kairoPrice() public view returns (uint256 _kairoPrice) {

    if (cToken.totalSupply() == 0) { return MIN_KRO_PRICE; }
    uint256 controlPerKairo = totalFundsInDAI.mul(10 ** 18).div(cToken.totalSupply());
    if (controlPerKairo < MIN_KRO_PRICE) {
      return MIN_KRO_PRICE;
    }
    return controlPerKairo;
  }
}

interface PositionToken {

  function mintWithToken(
    address receiver,
    address depositTokenAddress,
    uint256 depositAmount,
    uint256 maxPriceAllowed)
    external
    returns (uint256);


  function burnToToken(
    address receiver,
    address burnTokenAddress,
    uint256 burnAmount,
    uint256 minPriceAllowed)
    external
    returns (uint256);


  function tokenPrice()
   external
   view
   returns (uint256 price);


  function liquidationPrice()
   external
   view
   returns (uint256 price);


  function currentLeverage()
    external
    view
    returns (uint256 leverage);


  function decimals()
    external
    view
    returns (uint8);


  function balanceOf(address account)
    external
    view
    returns (uint256);

}

interface Comptroller {

    function enterMarkets(address[] calldata cTokens) external returns (uint[] memory);

    function markets(address cToken) external view returns (bool isListed, uint256 collateralFactorMantissa);

}

interface PriceOracle {

  function getPrice(address asset) external view returns (uint);

}

interface CERC20 {

  function mint(uint mintAmount) external returns (uint);

  function redeemUnderlying(uint redeemAmount) external returns (uint);

  function borrow(uint borrowAmount) external returns (uint);

  function repayBorrow(uint repayAmount) external returns (uint);

  function borrowBalanceCurrent(address account) external returns (uint);

  function exchangeRateCurrent() external returns (uint);


  function balanceOf(address account) external view returns (uint);

  function decimals() external view returns (uint);

  function underlying() external view returns (address);

}

contract CompoundOrderStorage is Ownable {

  uint256 internal constant NEGLIGIBLE_DEBT = 10 ** 14; // we don't care about debts below 10^-4 DAI (0.1 cent)
  uint256 internal constant MAX_REPAY_STEPS = 3; // Max number of times we attempt to repay remaining debt

  Comptroller public COMPTROLLER; // The Compound comptroller
  PriceOracle public ORACLE; // The Compound price oracle
  CERC20 public CDAI; // The Compound DAI market token
  address public CETH_ADDR;

  uint256 public stake;
  uint256 public collateralAmountInDAI;
  uint256 public loanAmountInDAI;
  uint256 public cycleNumber;
  uint256 public buyTime; // Timestamp for order execution
  uint256 public outputAmount; // Records the total output DAI after order is sold
  address public compoundTokenAddr;
  bool public isSold;
  bool public orderType; // True for shorting, false for longing

  address public logicContract;
}

contract CompoundOrder is CompoundOrderStorage, Utils {

  constructor(
    address _compoundTokenAddr,
    uint256 _cycleNumber,
    uint256 _stake,
    uint256 _collateralAmountInDAI,
    uint256 _loanAmountInDAI,
    bool _orderType,
    address _logicContract,
    address _daiAddr,
    address payable _kyberAddr,
    address _comptrollerAddr,
    address _priceOracleAddr,
    address _cDAIAddr,
    address _cETHAddr
  ) public Utils(_daiAddr, _kyberAddr)  {
    require(_compoundTokenAddr != _cDAIAddr);
    require(_stake > 0 && _collateralAmountInDAI > 0 && _loanAmountInDAI > 0); // Validate inputs
    stake = _stake;
    collateralAmountInDAI = _collateralAmountInDAI;
    loanAmountInDAI = _loanAmountInDAI;
    cycleNumber = _cycleNumber;
    compoundTokenAddr = _compoundTokenAddr;
    orderType = _orderType;
    logicContract = _logicContract;

    COMPTROLLER = Comptroller(_comptrollerAddr);
    ORACLE = PriceOracle(_priceOracleAddr);
    CDAI = CERC20(_cDAIAddr);
    CETH_ADDR = _cETHAddr;
  }
  
  function executeOrder(uint256 _minPrice, uint256 _maxPrice) public {

    (bool success,) = logicContract.delegatecall(abi.encodeWithSelector(this.executeOrder.selector, _minPrice, _maxPrice));
    if (!success) { revert(); }
  }

  function sellOrder(uint256 _minPrice, uint256 _maxPrice) public returns (uint256 _inputAmount, uint256 _outputAmount) {

    (bool success, bytes memory result) = logicContract.delegatecall(abi.encodeWithSelector(this.sellOrder.selector, _minPrice, _maxPrice));
    if (!success) { revert(); }
    return abi.decode(result, (uint256, uint256));
  }

  function repayLoan(uint256 _repayAmountInDAI) public {

    (bool success,) = logicContract.delegatecall(abi.encodeWithSelector(this.repayLoan.selector, _repayAmountInDAI));
    if (!success) { revert(); }
  }

  function getCurrentLiquidityInDAI() public returns (bool _isNegative, uint256 _amount) {

    (bool success, bytes memory result) = logicContract.delegatecall(abi.encodeWithSelector(this.getCurrentLiquidityInDAI.selector));
    if (!success) { revert(); }
    return abi.decode(result, (bool, uint256));
  }

  function getCurrentCollateralRatioInDAI() public returns (uint256 _amount) {

    (bool success, bytes memory result) = logicContract.delegatecall(abi.encodeWithSelector(this.getCurrentCollateralRatioInDAI.selector));
    if (!success) { revert(); }
    return abi.decode(result, (uint256));
  }

  function getCurrentProfitInDAI() public returns (bool _isNegative, uint256 _amount) {

    (bool success, bytes memory result) = logicContract.delegatecall(abi.encodeWithSelector(this.getCurrentProfitInDAI.selector));
    if (!success) { revert(); }
    return abi.decode(result, (bool, uint256));
  }

  function getMarketCollateralFactor() public returns (uint256) {

    (bool success, bytes memory result) = logicContract.delegatecall(abi.encodeWithSelector(this.getMarketCollateralFactor.selector));
    if (!success) { revert(); }
    return abi.decode(result, (uint256));
  }

  function getCurrentCollateralInDAI() public returns (uint256 _amount) {

    (bool success, bytes memory result) = logicContract.delegatecall(abi.encodeWithSelector(this.getCurrentCollateralInDAI.selector));
    if (!success) { revert(); }
    return abi.decode(result, (uint256));
  }

  function getCurrentBorrowInDAI() public returns (uint256 _amount) {

    (bool success, bytes memory result) = logicContract.delegatecall(abi.encodeWithSelector(this.getCurrentBorrowInDAI.selector));
    if (!success) { revert(); }
    return abi.decode(result, (uint256));
  }

  function getCurrentCashInDAI() public returns (uint256 _amount) {

    (bool success, bytes memory result) = logicContract.delegatecall(abi.encodeWithSelector(this.getCurrentCashInDAI.selector));
    if (!success) { revert(); }
    return abi.decode(result, (uint256));
  }

  function() external payable {}
}

contract CompoundOrderFactory {

  address public SHORT_CERC20_LOGIC_CONTRACT;
  address public SHORT_CEther_LOGIC_CONTRACT;
  address public LONG_CERC20_LOGIC_CONTRACT;
  address public LONG_CEther_LOGIC_CONTRACT;

  address public DAI_ADDR;
  address payable public KYBER_ADDR;
  address public COMPTROLLER_ADDR;
  address public ORACLE_ADDR;
  address public CDAI_ADDR;
  address public CETH_ADDR;

  constructor(
    address _shortCERC20LogicContract,
    address _shortCEtherLogicContract,
    address _longCERC20LogicContract,
    address _longCEtherLogicContract,
    address _daiAddr,
    address payable _kyberAddr,
    address _comptrollerAddr,
    address _priceOracleAddr,
    address _cDAIAddr,
    address _cETHAddr
  ) public {
    SHORT_CERC20_LOGIC_CONTRACT = _shortCERC20LogicContract;
    SHORT_CEther_LOGIC_CONTRACT = _shortCEtherLogicContract;
    LONG_CERC20_LOGIC_CONTRACT = _longCERC20LogicContract;
    LONG_CEther_LOGIC_CONTRACT = _longCEtherLogicContract;

    DAI_ADDR = _daiAddr;
    KYBER_ADDR = _kyberAddr;
    COMPTROLLER_ADDR = _comptrollerAddr;
    ORACLE_ADDR = _priceOracleAddr;
    CDAI_ADDR = _cDAIAddr;
    CETH_ADDR = _cETHAddr;
  }

  function createOrder(
    address _compoundTokenAddr,
    uint256 _cycleNumber,
    uint256 _stake,
    uint256 _collateralAmountInDAI,
    uint256 _loanAmountInDAI,
    bool _orderType
  ) public returns (CompoundOrder) {

    require(_compoundTokenAddr != address(0));

    CompoundOrder order;
    address logicContract;

    if (_compoundTokenAddr != CETH_ADDR) {
      logicContract = _orderType ? SHORT_CERC20_LOGIC_CONTRACT : LONG_CERC20_LOGIC_CONTRACT;
    } else {
      logicContract = _orderType ? SHORT_CEther_LOGIC_CONTRACT : LONG_CEther_LOGIC_CONTRACT;
    }
    order = new CompoundOrder(_compoundTokenAddr, _cycleNumber, _stake, _collateralAmountInDAI, _loanAmountInDAI, _orderType, logicContract, DAI_ADDR, KYBER_ADDR, COMPTROLLER_ADDR, ORACLE_ADDR, CDAI_ADDR, CETH_ADDR);
    order.transferOwnership(msg.sender);
    return order;
  }

  function getMarketCollateralFactor(address _compoundTokenAddr) public view returns (uint256) {

    Comptroller troll = Comptroller(COMPTROLLER_ADDR);
    (, uint256 factor) = troll.markets(_compoundTokenAddr);
    return factor;
  }
}

contract BetokenLogic is BetokenStorage, Utils(address(0), address(0)) {


  function developerInitiateUpgrade(address payable _candidate) public returns (bool _success) {

    if (_candidate == address(0) || _candidate == address(this) || !__isMature()) {
      return false;
    }
    nextVersion = _candidate;
    upgradeVotingActive = true;
    emit DeveloperInitiatedUpgrade(cycleNumber, _candidate);
    return true;
  }

  function signalUpgrade(bool _inSupport) public returns (bool _success) {

    if (!__isMature()) {
      return false;
    }

    if (upgradeSignal[cycleNumber][msg.sender] == false) {
      if (_inSupport == true) {
        upgradeSignal[cycleNumber][msg.sender] = true;
        upgradeSignalStrength[cycleNumber] = upgradeSignalStrength[cycleNumber].add(getVotingWeight(msg.sender));
      } else {
        return false;
      }
    } else {
      if (_inSupport == false) {
        upgradeSignal[cycleNumber][msg.sender] = false;
        upgradeSignalStrength[cycleNumber] = upgradeSignalStrength[cycleNumber].sub(getVotingWeight(msg.sender));
      } else {
        return false;
      }
    }
    emit SignaledUpgrade(cycleNumber, msg.sender, _inSupport);
    return true;
  }

  function proposeCandidate(uint256 _chunkNumber, address payable _candidate) public returns (bool _success) {

    if (!__isValidChunk(_chunkNumber) || currentChunk() != _chunkNumber || currentSubchunk() != Subchunk.Propose ||
      upgradeVotingActive == false || _candidate == address(0) || msg.sender == address(0) || !__isMature()) {
      return false;
    }

    uint256 voteID = _chunkNumber.sub(1);
    uint256 i;
    for (i = 0; i < voteID; i = i.add(1)) {
      if (proposers[i] == msg.sender || candidates[i] == _candidate) {
        return false;
      }
    }

    uint256 senderWeight = getVotingWeight(msg.sender);
    uint256 currProposerWeight = getVotingWeight(proposers[voteID]);
    if (senderWeight > currProposerWeight || (senderWeight == currProposerWeight && msg.sender > proposers[voteID]) || msg.sender == proposers[voteID]) {
      proposers[voteID] = msg.sender;
      candidates[voteID] = _candidate;
      proposersVotingWeight = proposersVotingWeight.add(senderWeight).sub(currProposerWeight);
      emit ProposedCandidate(cycleNumber, voteID, msg.sender, _candidate);
      return true;
    }
    return false;
  }

  function voteOnCandidate(uint256 _chunkNumber, bool _inSupport) public returns (bool _success) {

    if (!__isValidChunk(_chunkNumber) || currentChunk() != _chunkNumber || currentSubchunk() != Subchunk.Vote || upgradeVotingActive == false || !__isMature()) {
      return false;
    }

    uint256 voteID = _chunkNumber.sub(1);
    uint256 i;
    for (i = 0; i < voteID; i = i.add(1)) {
      if (proposers[i] == msg.sender) {
        return false;
      }
    }

    VoteDirection currVote = managerVotes[cycleNumber][msg.sender][voteID];
    uint256 votingWeight = getVotingWeight(msg.sender);
    if ((currVote == VoteDirection.Empty || currVote == VoteDirection.Against) && _inSupport) {
      managerVotes[cycleNumber][msg.sender][voteID] = VoteDirection.For;
      forVotes[voteID] = forVotes[voteID].add(votingWeight);
      if (currVote == VoteDirection.Against) {
        againstVotes[voteID] = againstVotes[voteID].sub(votingWeight);
      }
    } else if ((currVote == VoteDirection.Empty || currVote == VoteDirection.For) && !_inSupport) {
      managerVotes[cycleNumber][msg.sender][voteID] = VoteDirection.Against;
      againstVotes[voteID] = againstVotes[voteID].add(votingWeight);
      if (currVote == VoteDirection.For) {
        forVotes[voteID] = forVotes[voteID].sub(votingWeight);
      }
    }
    emit Voted(cycleNumber, voteID, msg.sender, _inSupport, votingWeight);
    return true;
  }

  function finalizeSuccessfulVote(uint256 _chunkNumber) public returns (bool _success) {

    if (!__isValidChunk(_chunkNumber) || !__isMature()) {
      return false;
    }

    if (__voteSuccessful(_chunkNumber) == false) {
      return false;
    }

    if (_chunkNumber >= currentChunk()) {
      return false;
    }

    for (uint256 i = 1; i < _chunkNumber; i = i.add(1)) {
      if (__voteSuccessful(i)) {
        return false;
      }
    }

    upgradeVotingActive = false;
    nextVersion = candidates[_chunkNumber.sub(1)];
    hasFinalizedNextVersion = true;
    return true;
  }

  function __isMature() internal view returns (bool) {

    return cycleNumber > CYCLES_TILL_MATURITY;
  }

  function __isValidChunk(uint256 _chunkNumber) internal pure returns (bool) {

    return _chunkNumber >= 1 && _chunkNumber <= 5;
  }

  function __voteSuccessful(uint256 _chunkNumber) internal view returns (bool _success) {

    if (!__isValidChunk(_chunkNumber)) {
      return false;
    }
    uint256 voteID = _chunkNumber.sub(1);
    return forVotes[voteID].mul(PRECISION).div(forVotes[voteID].add(againstVotes[voteID])) > VOTE_SUCCESS_THRESHOLD
      && forVotes[voteID].add(againstVotes[voteID]) > getTotalVotingWeight().mul(QUORUM).div(PRECISION);
  }


  function nextPhase()
    public
  {

    require(now >= startTimeOfCyclePhase.add(phaseLengths[uint(cyclePhase)]));

    if (cycleNumber == 0) {
      require(msg.sender == owner());
    }

    if (cyclePhase == CyclePhase.Intermission) {
      require(hasFinalizedNextVersion == false); // Shouldn't progress to next phase if upgrading

      if (upgradeSignalStrength[cycleNumber] > getTotalVotingWeight().div(2)) {
        upgradeVotingActive = true;
        emit InitiatedUpgrade(cycleNumber);
      }
    } else if (cyclePhase == CyclePhase.Manage) {
      require(cToken.destroyTokens(address(this), cToken.balanceOf(address(this))));

      uint256 profit = 0;
      if (getBalance(dai, address(this)) > totalFundsInDAI.add(totalCommissionLeft)) {
        profit = getBalance(dai, address(this)).sub(totalFundsInDAI).sub(totalCommissionLeft);
      }
      uint256 commissionThisCycle = COMMISSION_RATE.mul(profit).add(ASSET_FEE_RATE.mul(getBalance(dai, address(this)))).div(PRECISION);
      totalCommissionOfCycle[cycleNumber] = totalCommissionOfCycle[cycleNumber].add(commissionThisCycle); // account for penalties
      totalCommissionLeft = totalCommissionLeft.add(commissionThisCycle);

      totalFundsInDAI = getBalance(dai, address(this)).sub(totalCommissionLeft);

      uint256 devFunding = devFundingRate.mul(sToken.totalSupply()).div(PRECISION);
      require(sToken.generateTokens(devFundingAccount, devFunding));

      emit TotalCommissionPaid(cycleNumber, totalCommissionOfCycle[cycleNumber]);

      managePhaseEndBlock[cycleNumber] = block.number;

      if (nextVersion == address(this)) {
        delete nextVersion;
        delete hasFinalizedNextVersion;
      }
      if (nextVersion == address(0)) {
        delete proposers;
        delete candidates;
        delete forVotes;
        delete againstVotes;
        delete upgradeVotingActive;
        delete proposersVotingWeight;
      } else {
        hasFinalizedNextVersion = true;
        emit FinalizedNextVersion(cycleNumber, nextVersion);
      }

      cycleNumber = cycleNumber.add(1);
    }

    cyclePhase = CyclePhase(addmod(uint(cyclePhase), 1, 2));
    startTimeOfCyclePhase = now;

    if (cToken.balanceOf(msg.sender) > 0) {
      require(cToken.generateTokens(msg.sender, NEXT_PHASE_REWARD));
    }

    emit ChangedPhase(cycleNumber, uint(cyclePhase), now, totalFundsInDAI);
  }


  
  function maxRegistrationPaymentInDAI() public view returns (uint256 _maxDonationInDAI) {

    uint256 kroPrice = kairoPrice();
    _maxDonationInDAI = MAX_BUY_KRO_PROP.mul(cToken.totalSupply()).div(PRECISION).mul(kroPrice).div(PRECISION);
    if (_maxDonationInDAI < FALLBACK_MAX_DONATION) {
      _maxDonationInDAI = FALLBACK_MAX_DONATION;
    }
  }

  function registerWithDAI(uint256 _donationInDAI) public {

    dai.safeTransferFrom(msg.sender, address(this), _donationInDAI);

    uint256 maxDonationInDAI = maxRegistrationPaymentInDAI();
    if (_donationInDAI > maxDonationInDAI) {
      dai.safeTransfer(msg.sender, _donationInDAI.sub(maxDonationInDAI));
      _donationInDAI = maxDonationInDAI;
    }

    __register(_donationInDAI);
  }

  function registerWithETH() public payable {

    uint256 receivedDAI;

    (,,receivedDAI,) = __kyberTrade(ETH_TOKEN_ADDRESS, msg.value, dai);
    
    uint256 maxDonationInDAI = maxRegistrationPaymentInDAI();
    if (receivedDAI > maxDonationInDAI) {
      dai.safeTransfer(msg.sender, receivedDAI.sub(maxDonationInDAI));
      receivedDAI = maxDonationInDAI;
    }

    __register(receivedDAI);
  }

  function registerWithToken(address _token, uint256 _donationInTokens) public {

    require(_token != address(0) && _token != address(ETH_TOKEN_ADDRESS) && _token != DAI_ADDR);
    ERC20Detailed token = ERC20Detailed(_token);
    require(token.totalSupply() > 0);

    token.safeTransferFrom(msg.sender, address(this), _donationInTokens);

    uint256 receivedDAI;

    (,,receivedDAI,) = __kyberTrade(token, _donationInTokens, dai);

    uint256 maxDonationInDAI = maxRegistrationPaymentInDAI();
    if (receivedDAI > maxDonationInDAI) {
      dai.safeTransfer(msg.sender, receivedDAI.sub(maxDonationInDAI));
      receivedDAI = maxDonationInDAI;
    }

    __register(receivedDAI);
  }

  function __register(uint256 _donationInDAI) internal {

    require(cToken.balanceOf(msg.sender) == 0 && userInvestments[msg.sender].length == 0 && userCompoundOrders[msg.sender].length == 0); // each address can only join once

    uint256 kroAmount = _donationInDAI.mul(PRECISION).div(kairoPrice());
    require(cToken.generateTokens(msg.sender, kroAmount));

    baseRiskStakeFallback[msg.sender] = kroAmount;

    if (cyclePhase == CyclePhase.Intermission) {
      dai.safeTransfer(devFundingAccount, _donationInDAI);
    } else {
      totalFundsInDAI = totalFundsInDAI.add(_donationInDAI);
    }
    
    emit Register(msg.sender, _donationInDAI, kroAmount);
  }

  function investmentsCount(address _userAddr) public view returns(uint256 _count) {

    return userInvestments[_userAddr].length;
  }

  function createInvestment(
    address _tokenAddress,
    uint256 _stake,
    uint256 _minPrice,
    uint256 _maxPrice
  )
    public
  {

    require(_minPrice <= _maxPrice);
    require(_stake > 0);
    require(isKyberToken[_tokenAddress] || isPositionToken[_tokenAddress]);

    require(cToken.generateTokens(address(this), _stake));
    require(cToken.destroyTokens(msg.sender, _stake));

    userInvestments[msg.sender].push(Investment({
      tokenAddress: _tokenAddress,
      cycleNumber: cycleNumber,
      stake: _stake,
      tokenAmount: 0,
      buyPrice: 0,
      sellPrice: 0,
      buyTime: now,
      buyCostInDAI: 0,
      isSold: false
    }));

    uint256 investmentId = investmentsCount(msg.sender).sub(1);
    (, uint256 actualSrcAmount) = __handleInvestment(investmentId, _minPrice, _maxPrice, true);

    lastActiveCycle[msg.sender] = cycleNumber;

    emit CreatedInvestment(cycleNumber, msg.sender, investmentId, _tokenAddress, _stake, userInvestments[msg.sender][investmentId].buyPrice, actualSrcAmount, userInvestments[msg.sender][investmentId].tokenAmount);
  }

  function sellInvestmentAsset(
    uint256 _investmentId,
    uint256 _tokenAmount,
    uint256 _minPrice,
    uint256 _maxPrice
  )
    public
  {

    Investment storage investment = userInvestments[msg.sender][_investmentId];
    require(investment.buyPrice > 0 && investment.cycleNumber == cycleNumber && !investment.isSold);
    require(_tokenAmount > 0 && _tokenAmount <= investment.tokenAmount);
    require(_minPrice <= _maxPrice);

    bool isPartialSell = false;
    uint256 stakeOfSoldTokens = investment.stake.mul(_tokenAmount).div(investment.tokenAmount);
    if (_tokenAmount != investment.tokenAmount) {
      isPartialSell = true;

      uint256 soldBuyCostInDAI = investment.buyCostInDAI.mul(_tokenAmount).div(investment.tokenAmount);

      userInvestments[msg.sender].push(Investment({
        tokenAddress: investment.tokenAddress,
        cycleNumber: cycleNumber,
        stake: investment.stake.sub(stakeOfSoldTokens),
        tokenAmount: investment.tokenAmount.sub(_tokenAmount),
        buyPrice: investment.buyPrice,
        sellPrice: 0,
        buyTime: investment.buyTime,
        buyCostInDAI: investment.buyCostInDAI.sub(soldBuyCostInDAI),
        isSold: false
      }));

      investment.tokenAmount = _tokenAmount;
      investment.stake = stakeOfSoldTokens;
      investment.buyCostInDAI = soldBuyCostInDAI;
    }
    
    investment.isSold = true;

    (uint256 actualDestAmount, uint256 actualSrcAmount) = __handleInvestment(_investmentId, _minPrice, _maxPrice, false);
    if (isPartialSell) {
      userInvestments[msg.sender][investmentsCount(msg.sender).sub(1)].tokenAmount = userInvestments[msg.sender][investmentsCount(msg.sender).sub(1)].tokenAmount.add(_tokenAmount.sub(actualSrcAmount));
    }

    uint256 receiveKairoAmount = stakeOfSoldTokens.mul(investment.sellPrice).div(investment.buyPrice);
    __returnStake(receiveKairoAmount, stakeOfSoldTokens);

    __recordRisk(investment.stake, investment.buyTime);

    totalFundsInDAI = totalFundsInDAI.sub(investment.buyCostInDAI).add(actualDestAmount);
    
    if (isPartialSell) {
      Investment storage newInvestment = userInvestments[msg.sender][investmentsCount(msg.sender).sub(1)];
      emit CreatedInvestment(
        cycleNumber, msg.sender, investmentsCount(msg.sender).sub(1),
        newInvestment.tokenAddress, newInvestment.stake, newInvestment.buyPrice,
        newInvestment.buyCostInDAI, newInvestment.tokenAmount);
    }
    emit SoldInvestment(cycleNumber, msg.sender, _investmentId, investment.tokenAddress, receiveKairoAmount, investment.sellPrice, actualDestAmount);
  }

  function createCompoundOrder(
    bool _orderType,
    address _tokenAddress,
    uint256 _stake,
    uint256 _minPrice,
    uint256 _maxPrice
  )
    public
  {

    require(_minPrice <= _maxPrice);
    require(_stake > 0);
    require(isCompoundToken[_tokenAddress]);

    require(cToken.generateTokens(address(this), _stake));
    require(cToken.destroyTokens(msg.sender, _stake));

    uint256 collateralAmountInDAI = totalFundsInDAI.mul(_stake).div(cToken.totalSupply());
    CompoundOrder order = __createCompoundOrder(_orderType, _tokenAddress, _stake, collateralAmountInDAI);
    dai.safeApprove(address(order), 0);
    dai.safeApprove(address(order), collateralAmountInDAI);
    order.executeOrder(_minPrice, _maxPrice);

    userCompoundOrders[msg.sender].push(address(order));

    lastActiveCycle[msg.sender] = cycleNumber;

    emit CreatedCompoundOrder(cycleNumber, msg.sender, userCompoundOrders[msg.sender].length - 1, address(order), _orderType, _tokenAddress, _stake, collateralAmountInDAI);
  }

  function sellCompoundOrder(
    uint256 _orderId,
    uint256 _minPrice,
    uint256 _maxPrice
  )
    public
  {

    require(userCompoundOrders[msg.sender][_orderId] != address(0));
    CompoundOrder order = CompoundOrder(userCompoundOrders[msg.sender][_orderId]);
    require(order.isSold() == false && order.cycleNumber() == cycleNumber);

    (uint256 inputAmount, uint256 outputAmount) = order.sellOrder(_minPrice, _maxPrice);

    uint256 stake = order.stake();
    uint256 receiveKairoAmount = order.stake().mul(outputAmount).div(inputAmount);
    __returnStake(receiveKairoAmount, stake);

    __recordRisk(stake, order.buyTime());

    totalFundsInDAI = totalFundsInDAI.sub(inputAmount).add(outputAmount);

    emit SoldCompoundOrder(cycleNumber, msg.sender, userCompoundOrders[msg.sender].length - 1, address(order), order.orderType(), order.compoundTokenAddr(), receiveKairoAmount, outputAmount);
  }

  function repayCompoundOrder(uint256 _orderId, uint256 _repayAmountInDAI) public {

    require(userCompoundOrders[msg.sender][_orderId] != address(0));
    CompoundOrder order = CompoundOrder(userCompoundOrders[msg.sender][_orderId]);
    require(order.isSold() == false && order.cycleNumber() == cycleNumber);

    order.repayLoan(_repayAmountInDAI);

    emit RepaidCompoundOrder(cycleNumber, msg.sender, userCompoundOrders[msg.sender].length - 1, address(order), _repayAmountInDAI);
  }

  function __handleInvestment(uint256 _investmentId, uint256 _minPrice, uint256 _maxPrice, bool _buy)
    public
    returns (uint256 _actualDestAmount, uint256 _actualSrcAmount)
  {

    Investment storage investment = userInvestments[msg.sender][_investmentId];
    address token = investment.tokenAddress;
    if (isPositionToken[token]) {
      PositionToken pToken = PositionToken(token);
      uint256 beforeBalance;
      if (_buy) {
        _actualSrcAmount = totalFundsInDAI.mul(investment.stake).div(cToken.totalSupply());
        dai.safeApprove(token, 0);
        dai.safeApprove(token, _actualSrcAmount);
        beforeBalance = pToken.balanceOf(address(this));
        pToken.mintWithToken(address(this), DAI_ADDR, _actualSrcAmount, 0);
        _actualDestAmount = pToken.balanceOf(address(this)).sub(beforeBalance);
        require(_actualDestAmount > 0);
        dai.safeApprove(token, 0);

        investment.buyPrice = calcRateFromQty(_actualDestAmount, _actualSrcAmount, pToken.decimals(), dai.decimals()); // price of pToken in DAI
        require(_minPrice <= investment.buyPrice && investment.buyPrice <= _maxPrice);

        investment.tokenAmount = _actualDestAmount;
        investment.buyCostInDAI = _actualSrcAmount;
      } else {
        _actualSrcAmount = investment.tokenAmount;
        beforeBalance = dai.balanceOf(address(this));
        pToken.burnToToken(address(this), DAI_ADDR, _actualSrcAmount, 0);
        _actualDestAmount = dai.balanceOf(address(this)).sub(beforeBalance);

        investment.sellPrice = calcRateFromQty(_actualSrcAmount, _actualDestAmount, dai.decimals(), pToken.decimals()); // price of pToken in DAI
        require(_minPrice <= investment.sellPrice && investment.sellPrice <= _maxPrice);
      }
    } else {
      uint256 dInS; // price of dest token denominated in src token
      uint256 sInD; // price of src token denominated in dest token
      if (_buy) {
        (dInS, sInD, _actualDestAmount, _actualSrcAmount) = __kyberTrade(dai, totalFundsInDAI.mul(investment.stake).div(cToken.totalSupply()), ERC20Detailed(token));
        require(_minPrice <= dInS && dInS <= _maxPrice);
        investment.buyPrice = dInS;
        investment.tokenAmount = _actualDestAmount;
        investment.buyCostInDAI = _actualSrcAmount;
      } else {
        (dInS, sInD, _actualDestAmount, _actualSrcAmount) = __kyberTrade(ERC20Detailed(token), investment.tokenAmount, dai);
        require(_minPrice <= sInD && sInD <= _maxPrice);
        investment.sellPrice = sInD;
      }
    }
  }

  function __createCompoundOrder(
    bool _orderType, // True for shorting, false for longing
    address _tokenAddress,
    uint256 _stake,
    uint256 _collateralAmountInDAI
  ) internal returns (CompoundOrder) {

    CompoundOrderFactory factory = CompoundOrderFactory(compoundFactoryAddr);
    uint256 loanAmountInDAI = _collateralAmountInDAI.mul(COLLATERAL_RATIO_MODIFIER).div(PRECISION).mul(factory.getMarketCollateralFactor(_tokenAddress)).div(PRECISION);
    CompoundOrder order = factory.createOrder(
      _tokenAddress,
      cycleNumber,
      _stake,
      _collateralAmountInDAI,
      loanAmountInDAI,
      _orderType
    );
    return order;
  }

  function __returnStake(uint256 _receiveKairoAmount, uint256 _stake) internal {

    require(cToken.destroyTokens(address(this), _stake));
    require(cToken.generateTokens(msg.sender, _receiveKairoAmount));
  }

  function __recordRisk(uint256 _stake, uint256 _buyTime) internal {

    riskTakenInCycle[msg.sender][cycleNumber] = riskTakenInCycle[msg.sender][cycleNumber].add(_stake.mul(now.sub(_buyTime)));
  }
}