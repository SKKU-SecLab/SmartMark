

pragma solidity 0.5.17;

interface IWhitelist {

  function detectTransferRestriction(
    address from,
    address to,
    uint value
  ) external view returns (uint8);


  function messageForTransferRestriction(uint8 restrictionCode)
    external
    pure
    returns (string memory);


  function authorizeTransfer(
    address _from,
    address _to,
    uint _value,
    bool _isSell
  ) external;


  function walletActivated(
    address _wallet
  ) external returns(bool);

}



pragma solidity 0.5.17;

interface IERC20Detailed {

  function decimals() external view returns (uint8);

}



pragma solidity ^0.5.0;

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



pragma solidity ^0.5.0;

library BigDiv {

  using SafeMath for uint;

  uint private constant MAX_UINT = 2**256 - 1;

  uint private constant MAX_BEFORE_SQUARE = 2**128 - 1;

  uint private constant MAX_ERROR = 100000000;

  uint private constant MAX_ERROR_BEFORE_DIV = MAX_ERROR * 2;

  function bigDiv2x1(
    uint _numA,
    uint _numB,
    uint _den
  ) internal pure returns (uint) {

    if (_numA == 0 || _numB == 0) {
      return 0;
    }

    uint value;

    if (MAX_UINT / _numA >= _numB) {
      value = _numA * _numB;
      value /= _den;
      return value;
    }

    uint numMax = _numB;
    uint numMin = _numA;
    if (_numA > _numB) {
      numMax = _numA;
      numMin = _numB;
    }

    value = numMax / _den;
    if (value > MAX_ERROR) {
      value = value.mul(numMin);
      return value;
    }

    uint factor = numMin - 1;
    factor /= MAX_BEFORE_SQUARE;
    factor += 1;
    uint temp = numMax - 1;
    temp /= MAX_BEFORE_SQUARE;
    temp += 1;
    if (MAX_UINT / factor >= temp) {
      factor *= temp;
      value = numMax / factor;
      if (value > MAX_ERROR_BEFORE_DIV) {
        value = value.mul(numMin);
        temp = _den - 1;
        temp /= factor;
        temp = temp.add(1);
        value /= temp;
        return value;
      }
    }

    factor = numMin - 1;
    factor /= MAX_BEFORE_SQUARE;
    factor += 1;
    value = numMin / factor;
    temp = _den - 1;
    temp /= factor;
    temp += 1;
    temp = numMax / temp;
    value = value.mul(temp);
    return value;
  }

  function bigDiv2x1RoundUp(
    uint _numA,
    uint _numB,
    uint _den
  ) internal pure returns (uint) {

    uint value = bigDiv2x1(_numA, _numB, _den);

    if (value == 0) {
      return 1;
    }

    uint temp = value - 1;
    temp /= MAX_ERROR;
    temp += 1;
    if (MAX_UINT - value < temp) {
      return MAX_UINT;
    }

    value += temp;

    return value;
  }

  function bigDiv2x2(
    uint _numA,
    uint _numB,
    uint _denA,
    uint _denB
  ) internal pure returns (uint) {

    if (MAX_UINT / _denA >= _denB) {
      return bigDiv2x1(_numA, _numB, _denA * _denB);
    }

    if (_numA == 0 || _numB == 0) {
      return 0;
    }

    uint denMax = _denB;
    uint denMin = _denA;
    if (_denA > _denB) {
      denMax = _denA;
      denMin = _denB;
    }

    uint value;

    if (MAX_UINT / _numA >= _numB) {
      value = _numA * _numB;
      value /= denMin;
      value /= denMax;
      return value;
    }


    uint numMax = _numB;
    uint numMin = _numA;
    if (_numA > _numB) {
      numMax = _numA;
      numMin = _numB;
    }

    uint temp = numMax / denMin;
    if (temp > MAX_ERROR_BEFORE_DIV) {
      return bigDiv2x1(temp, numMin, denMax);
    }

    uint factor = numMin - 1;
    factor /= MAX_BEFORE_SQUARE;
    factor += 1;
    temp = numMax - 1;
    temp /= MAX_BEFORE_SQUARE;
    temp += 1;
    if (MAX_UINT / factor >= temp) {
      factor *= temp;

      value = numMax / factor;
      if (value > MAX_ERROR_BEFORE_DIV) {
        value = value.mul(numMin);
        value /= denMin;
        if (value > 0 && MAX_UINT / value >= factor) {
          value *= factor;
          value /= denMax;
          return value;
        }
      }
    }

    factor = denMin;
    factor /= MAX_BEFORE_SQUARE;
    temp = denMax;
    temp /= MAX_BEFORE_SQUARE + 1;
    factor *= temp;
    return bigDiv2x1(numMax / factor, numMin, MAX_UINT);
  }
}



pragma solidity ^0.5.0;

library Sqrt {

  uint private constant MAX_UINT = 2**256 - 1;

  function sqrt(uint x) internal pure returns (uint y) {

    if (x == 0) {
      return 0;
    } else if (x <= 3) {
      return 1;
    } else if (x == MAX_UINT) {
      return 2**128 - 1;
    }

    uint z = (x + 1) / 2;
    y = x;
    while (z < y) {
      y = z;
      z = (x / z + z) / 2;
    }
  }
}



pragma solidity ^0.5.0;

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



pragma solidity ^0.5.5;

library Address {

    function isContract(address account) internal view returns (bool) {

        bytes32 codehash;
        bytes32 accountHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;
        assembly { codehash := extcodehash(account) }
        return (codehash != accountHash && codehash != 0x0);
    }

    function toPayable(address account) internal pure returns (address payable) {

        return address(uint160(account));
    }

    function sendValue(address payable recipient, uint256 amount) internal {

        require(address(this).balance >= amount, "Address: insufficient balance");

        (bool success, ) = recipient.call.value(amount)("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }
}



pragma solidity ^0.5.0;



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

        uint256 newAllowance = token.allowance(address(this), spender).sub(value, "SafeERC20: decreased allowance below zero");
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



pragma solidity >=0.4.24 <0.7.0;


contract Initializable {


  bool private initialized;

  bool private initializing;

  modifier initializer() {

    require(initializing || isConstructor() || !initialized, "Contract instance has already been initialized");

    bool isTopLevelCall = !initializing;
    if (isTopLevelCall) {
      initializing = true;
      initialized = true;
    }

    _;

    if (isTopLevelCall) {
      initializing = false;
    }
  }

  function isConstructor() private view returns (bool) {

    address self = address(this);
    uint256 cs;
    assembly { cs := extcodesize(self) }
    return cs == 0;
  }

  uint256[50] private ______gap;
}



pragma solidity ^0.5.0;

contract Context is Initializable {

    constructor () internal { }

    function _msgSender() internal view returns (address payable) {

        return msg.sender;
    }

    function _msgData() internal view returns (bytes memory) {

        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}



pragma solidity ^0.5.0;



contract ERC20 is Initializable, Context, IERC20 {

    using SafeMath for uint256;

    mapping (address => uint256) private _balances;

    mapping (address => mapping (address => uint256)) private _allowances;

    uint256 private _totalSupply;

    function totalSupply() public view returns (uint256) {

        return _totalSupply;
    }

    function balanceOf(address account) public view returns (uint256) {

        return _balances[account];
    }

    function transfer(address recipient, uint256 amount) public returns (bool) {

        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function allowance(address owner, address spender) public view returns (uint256) {

        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public returns (bool) {

        _approve(_msgSender(), spender, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) public returns (bool) {

        _transfer(sender, recipient, amount);
        _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount, "ERC20: transfer amount exceeds allowance"));
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public returns (bool) {

        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].add(addedValue));
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public returns (bool) {

        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].sub(subtractedValue, "ERC20: decreased allowance below zero"));
        return true;
    }

    function _transfer(address sender, address recipient, uint256 amount) internal {

        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        _balances[sender] = _balances[sender].sub(amount, "ERC20: transfer amount exceeds balance");
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
    }

    function _mint(address account, uint256 amount) internal {

        require(account != address(0), "ERC20: mint to the zero address");

        _totalSupply = _totalSupply.add(amount);
        _balances[account] = _balances[account].add(amount);
        emit Transfer(address(0), account, amount);
    }

    function _burn(address account, uint256 amount) internal {

        require(account != address(0), "ERC20: burn from the zero address");

        _balances[account] = _balances[account].sub(amount, "ERC20: burn amount exceeds balance");
        _totalSupply = _totalSupply.sub(amount);
        emit Transfer(account, address(0), amount);
    }

    function _approve(address owner, address spender, uint256 amount) internal {

        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _burnFrom(address account, uint256 amount) internal {

        _burn(account, amount);
        _approve(account, _msgSender(), _allowances[account][_msgSender()].sub(amount, "ERC20: burn amount exceeds allowance"));
    }

    uint256[50] private ______gap;
}



pragma solidity ^0.5.0;


contract ERC20Detailed is Initializable, IERC20 {

    string private _name;
    string private _symbol;
    uint8 private _decimals;

    function initialize(string memory name, string memory symbol, uint8 decimals) public initializer {

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

    uint256[50] private ______gap;
}



pragma solidity 0.5.17;









contract CAFE
  is ERC20, ERC20Detailed
{

  using SafeMath for uint;
  using Sqrt for uint;
  using SafeERC20 for IERC20;
  event Buy(
    address indexed _from,
    address indexed _to,
    uint _currencyValue,
    uint _fairValue
  );
  event Sell(
    address indexed _from,
    address indexed _to,
    uint _currencyValue,
    uint _fairValue
  );
  event Burn(
    address indexed _from,
    uint _fairValue
  );
  event StateChange(
    uint _previousState,
    uint _newState
  );
  event Close();
  event UpdateConfig(
    address _whitelistAddress,
    address indexed _beneficiary,
    address indexed _control,
    address indexed _feeCollector,
    uint _feeBasisPoints,
    uint _minInvestment,
    uint _minDuration,
    uint _stakeholdersPoolAuthorized,
    uint _gasFee
  );


  uint internal constant STATE_INIT = 0;

  uint internal constant STATE_RUN = 1;

  uint internal constant STATE_CLOSE = 2;

  uint internal constant STATE_CANCEL = 3;

  uint internal constant MAX_BEFORE_SQUARE = 2**128 - 1;

  uint internal constant BASIS_POINTS_DEN = 10000;

  uint internal constant MAX_SUPPLY = 10 ** 38;

  uint internal constant MAX_ITERATION = 10;


  IWhitelist public whitelist;

  uint public burnedSupply;


  bool private __autoBurn;

  address payable public beneficiary;

  uint public buySlopeNum;

  uint public buySlopeDen;

  address public control;

  IERC20 public currency;

  address payable public feeCollector;

  uint public feeBasisPoints;

  uint public initGoal;

  mapping(address => uint) public initInvestors;

  uint public initReserve;

  uint internal __investmentReserveBasisPoints;

  uint private __openUntilAtLeast;

  uint public minInvestment;

  uint internal __revenueCommitmentBasisPoints;

  uint public state;

  string public constant version = "cafe-1.6";
  mapping (address => uint) public nonces;
  bytes32 public DOMAIN_SEPARATOR;
  bytes32 public constant PERMIT_TYPEHASH = 0x6e71edae12b1b97f4d1f60370fef10105fa2faae0126114a169c64845d6126c9;

  uint public setupFee;

  address payable public setupFeeRecipient;

  uint public minDuration;

  uint private __startedOn;

  uint internal constant MAX_UINT = 2**256 - 1;

  bytes32 public constant PERMIT_BUY_TYPEHASH = 0xaf42a244b3020d6a2253d9f291b4d3e82240da42b22129a8113a58aa7a3ddb6a;

  bytes32 public constant PERMIT_SELL_TYPEHASH = 0x5dfdc7fb4c68a4c249de5e08597626b84fbbe7bfef4ed3500f58003e722cc548;

  uint public stakeholdersPoolIssued;

  uint public stakeholdersPoolAuthorized;

  uint public equityCommitment;

  uint public shareholdersPool;

  uint public maxGoal;

  uint public initTrial;

  uint public fundraisingGoal;

  uint public gasFee;

  uint public manualBuybackReserve;

  modifier authorizeTransfer(
    address _from,
    address _to,
    uint _value,
    bool _isSell
  )
  {

    require(state != STATE_CLOSE, "INVALID_STATE");
    if(address(whitelist) != address(0))
    {
      whitelist.authorizeTransfer(_from, _to, _value, _isSell);
    }
    _;
  }

  function stakeholdersPool() public view returns (uint256 issued, uint256 authorized) {

    return (stakeholdersPoolIssued, stakeholdersPoolAuthorized);
  }

  function trialEndedOn() public view returns(uint256 timestamp) {

    return __startedOn;
  }


  function buybackReserve() public view returns (uint)
  {

    uint reserve = address(this).balance;
    if(address(currency) != address(0))
    {
      reserve = currency.balanceOf(address(this));
    }

    if(reserve > MAX_BEFORE_SQUARE)
    {
      return MAX_BEFORE_SQUARE;
    }

    return reserve + manualBuybackReserve;
  }


  function _transfer(
    address _from,
    address _to,
    uint _amount
  ) internal
    authorizeTransfer(_from, _to, _amount, false)
  {

    require(state != STATE_INIT || _from == beneficiary, "ONLY_BENEFICIARY_DURING_INIT");
    super._transfer(_from, _to, _amount);
  }

  function _burn(
    address _from,
    uint _amount,
    bool _isSell
  ) internal
    authorizeTransfer(_from, address(0), _amount, _isSell)
  {

    super._burn(_from, _amount);

    if(!_isSell)
    {
      burnedSupply += _amount;
      emit Burn(_from, _amount);
    }
  }

  function _mint(
    address _to,
    uint _quantity
  ) internal
    authorizeTransfer(address(0), _to, _quantity, false)
  {

    super._mint(_to, _quantity);

    require(totalSupply().add(burnedSupply) <= MAX_SUPPLY, "EXCESSIVE_SUPPLY");
  }


  function _collectInvestment(
    address payable _from,
    uint _quantityToInvest,
    uint _msgValue
  ) internal
  {

    if(address(currency) == address(0))
    {
      require(_quantityToInvest == _msgValue, "INCORRECT_MSG_VALUE");
    }
    else
    {
      require(_msgValue == 0, "DO_NOT_SEND_ETH");

      currency.safeTransferFrom(_from, address(this), _quantityToInvest);
    }
  }

  function _transferCurrency(
    address payable _to,
    uint _amount
  ) internal
  {

    if(_amount > 0)
    {
      if(address(currency) == address(0))
      {
        Address.sendValue(_to, _amount);
      }
      else
      {
        currency.safeTransfer(_to, _amount);
      }
    }
  }



  function initialize(
    uint _initReserve,
    address _currencyAddress,
    uint _initGoal,
    uint _buySlopeNum,
    uint _buySlopeDen,
    uint _setupFee,
    address payable _setupFeeRecipient,
    string memory _name,
    string memory _symbol,
    uint _maxGoal,
    uint _initTrial,
    uint _stakeholdersAuthorized,
    uint _equityCommitment
  ) public
  {

    ERC20Detailed.initialize(_name, _symbol, 18);

    require(_buySlopeNum > 0, "INVALID_SLOPE_NUM");
    require(_buySlopeDen > 0, "INVALID_SLOPE_DEN");
    require(_buySlopeNum < MAX_BEFORE_SQUARE, "EXCESSIVE_SLOPE_NUM");
    require(_buySlopeDen < MAX_BEFORE_SQUARE, "EXCESSIVE_SLOPE_DEN");
    buySlopeNum = _buySlopeNum;
    buySlopeDen = _buySlopeDen;

    require(_setupFee == 0 || _setupFeeRecipient != address(0), "MISSING_SETUP_FEE_RECIPIENT");
    require(_setupFeeRecipient == address(0) || _setupFee != 0, "MISSING_SETUP_FEE");
    uint initGoalInCurrency = _initGoal * _initGoal;
    initGoalInCurrency = initGoalInCurrency.mul(_buySlopeNum);
    initGoalInCurrency /= 2 * _buySlopeDen;
    require(_setupFee <= initGoalInCurrency, "EXCESSIVE_SETUP_FEE");
    setupFee = _setupFee;
    setupFeeRecipient = _setupFeeRecipient;

    uint decimals = 18;
    if(_currencyAddress != address(0))
    {
      decimals = IERC20Detailed(_currencyAddress).decimals();
    }
    minInvestment = 100 * (10 ** decimals);
    beneficiary = msg.sender;
    control = msg.sender;
    feeCollector = msg.sender;

    currency = IERC20(_currencyAddress);

    if(_initReserve > 0)
    {
      initReserve = _initReserve;
      _mint(beneficiary, initReserve);
    }

    initializeDomainSeparator();
    require(_maxGoal < MAX_SUPPLY, "EXCESSIVE_GOAL");
    require(_initGoal < MAX_SUPPLY, "EXCESSIVE_GOAL");
    require(_initTrial < MAX_SUPPLY, "EXCESSIVE_GOAL");

    require(_maxGoal == 0 || _initGoal == 0 || _maxGoal >= _initGoal, "MAX_GOAL_SMALLER_THAN_INIT_GOAL");
    require(_initGoal == 0 || _initTrial == 0 || _initGoal >= _initTrial, "INIT_GOAL_SMALLER_THAN_INIT_TRIAL");
    maxGoal = _maxGoal;
    initTrial = _initTrial;
    stakeholdersPoolIssued = _initReserve;
    require(_stakeholdersAuthorized <= BASIS_POINTS_DEN, "STAKEHOLDERS_POOL_AUTHORIZED_SHOULD_BE_SMALLER_THAN_BASIS_POINTS_DEN");
    stakeholdersPoolAuthorized = _stakeholdersAuthorized;
    require(_equityCommitment > 0, "EQUITY_COMMITMENT_CANNOT_BE_ZERO");
    require(_equityCommitment <= BASIS_POINTS_DEN, "EQUITY_COMMITMENT_SHOULD_BE_LESS_THAN_100%");
    equityCommitment = _equityCommitment;
    if(_initGoal == 0)
    {
      emit StateChange(state, STATE_RUN);
      state = STATE_RUN;
      __startedOn = block.timestamp;
    }
    else
    {
      initGoal = _initGoal;
    }
  }

  function updateConfig(
    address _whitelistAddress,
    address payable _beneficiary,
    address _control,
    address payable _feeCollector,
    uint _feeBasisPoints,
    uint _minInvestment,
    uint _minDuration,
    uint _stakeholdersAuthorized,
    uint _gasFee
  ) public
  {

    require(msg.sender == control, "CONTROL_ONLY");

    whitelist = IWhitelist(_whitelistAddress);

    require(_control != address(0), "INVALID_ADDRESS");
    control = _control;

    require(_feeCollector != address(0), "INVALID_ADDRESS");
    feeCollector = _feeCollector;

    require(_feeBasisPoints <= BASIS_POINTS_DEN, "INVALID_FEE");
    feeBasisPoints = _feeBasisPoints;

    require(_minInvestment > 0, "INVALID_MIN_INVESTMENT");
    minInvestment = _minInvestment;

    require(_minDuration >= minDuration, "MIN_DURATION_MAY_NOT_BE_REDUCED");
    minDuration = _minDuration;

    if(beneficiary != _beneficiary)
    {
      require(_beneficiary != address(0), "INVALID_ADDRESS");
      uint tokens = balanceOf(beneficiary);
      initInvestors[_beneficiary] = initInvestors[_beneficiary].add(initInvestors[beneficiary]);
      initInvestors[beneficiary] = 0;
      if(tokens > 0)
      {
        _transfer(beneficiary, _beneficiary, tokens);
      }
      beneficiary = _beneficiary;
    }

    require(_stakeholdersAuthorized <= BASIS_POINTS_DEN, "STAKEHOLDERS_POOL_AUTHORIZED_SHOULD_BE_SMALLER_THAN_BASIS_POINTS_DEN");
    stakeholdersPoolAuthorized = _stakeholdersAuthorized;

    gasFee = _gasFee;

    emit UpdateConfig(
      _whitelistAddress,
      _beneficiary,
      _control,
      _feeCollector,
      _feeBasisPoints,
      _minInvestment,
      _minDuration,
      _stakeholdersAuthorized,
      _gasFee
    );
  }

  function initializeDomainSeparator() public
  {

    uint id;
    assembly
    {
      id := chainid()
    }
    DOMAIN_SEPARATOR = keccak256(
      abi.encode(
        keccak256("EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)"),
        keccak256(bytes(name())),
        keccak256(bytes(version)),
        id,
        address(this)
      )
    );
  }


  function burn(
    uint _amount
  ) public
  {

    require(state == STATE_RUN, "INVALID_STATE");
    require(msg.sender == beneficiary, "BENEFICIARY_ONLY");
    _burn(msg.sender, _amount, false);
  }


  function buy(
    address _to,
    uint _currencyValue,
    uint _minTokensBought
  ) public payable
  {

    _collectInvestment(msg.sender, _currencyValue, msg.value);
    uint256 currencyValue = _currencyValue.sub(gasFee);
    _transferCurrency(feeCollector, gasFee);
    _buy(msg.sender, _to, currencyValue, _minTokensBought, false);
  }

  function permitBuy(
    address payable _from,
    address _to,
    uint _currencyValue,
    uint _minTokensBought,
    uint _deadline,
    uint8 _v,
    bytes32 _r,
    bytes32 _s
  ) external
  {

    require(_deadline >= block.timestamp, "EXPIRED");
    bytes32 digest = keccak256(abi.encode(PERMIT_BUY_TYPEHASH, _from, _to, _currencyValue, _minTokensBought, nonces[_from]++, _deadline));
    digest = keccak256(
      abi.encodePacked(
        "\x19\x01",
        DOMAIN_SEPARATOR,
        digest
      )
    );
    address recoveredAddress = ecrecover(digest, _v, _r, _s);
    require(recoveredAddress != address(0) && recoveredAddress == _from, "INVALID_SIGNATURE");
    _collectInvestment(_from, _currencyValue, 0);
    uint256 currencyValue = _currencyValue.sub(gasFee);
    _transferCurrency(feeCollector, gasFee);
    _buy(_from, _to, currencyValue, _minTokensBought, false);
  }

  function _buy(
    address payable _from,
    address _to,
    uint _currencyValue,
    uint _minTokensBought,
    bool _manual
  ) internal
  {

    require(_to != address(0), "INVALID_ADDRESS");
    require(_to != beneficiary, "BENEFICIARY_CANNOT_BUY");
    require(_minTokensBought > 0, "MUST_BUY_AT_LEAST_1");
    require(state == STATE_INIT || state == STATE_RUN, "ONLY_BUY_IN_INIT_OR_RUN");
    uint tokenValue = _estimateBuyValue(_currencyValue);
    require(tokenValue >= _minTokensBought, "PRICE_SLIPPAGE");
    if(state == STATE_INIT){
      if(tokenValue + shareholdersPool < initTrial){
        if(!_manual) {
          initInvestors[_to] = initInvestors[_to].add(tokenValue);
        }
        initTrial = initTrial.sub(tokenValue);
      }
      else if (initTrial > shareholdersPool){
        if(setupFee > 0){
          _transferCurrency(setupFeeRecipient, setupFee);
        }
        _distributeInvestment(buybackReserve().sub(manualBuybackReserve));
        manualBuybackReserve = 0;
        initTrial = shareholdersPool;
        __startedOn = block.timestamp;
      }
      else{
        _distributeInvestment(buybackReserve().sub(manualBuybackReserve));
        manualBuybackReserve = 0;
      }
    }
    else { //state == STATE_RUN
      require(maxGoal == 0 || tokenValue.add(totalSupply()).sub(stakeholdersPoolIssued) <= maxGoal, "EXCEEDING_MAX_GOAL");
      _distributeInvestment(buybackReserve().sub(manualBuybackReserve));
      manualBuybackReserve = 0;
      if(fundraisingGoal != 0){
        if (tokenValue >= fundraisingGoal){
          changeBuySlope(totalSupply() - stakeholdersPoolIssued, fundraisingGoal + totalSupply() - stakeholdersPoolIssued);
          fundraisingGoal = 0;
        } else { //if (tokenValue < fundraisingGoal) {
          changeBuySlope(totalSupply() - stakeholdersPoolIssued, tokenValue + totalSupply() - stakeholdersPoolIssued);
          fundraisingGoal -= tokenValue;
        }
      }
    }

    emit Buy(_from, _to, _currencyValue, tokenValue);
    _mint(_to, tokenValue);

    if(state == STATE_INIT && totalSupply() - stakeholdersPoolIssued >= initGoal){
      state = STATE_RUN;
      emit StateChange(STATE_INIT, STATE_RUN);
    }
  }

  function _distributeInvestment(
    uint _value
  ) internal
  {

    uint fee = _value.mul(feeBasisPoints);
    fee /= BASIS_POINTS_DEN;

    _transferCurrency(beneficiary, _value - fee);
    _transferCurrency(feeCollector, fee);
  }

  function estimateBuyValue(
    uint _currencyValue
  ) external view
  returns(uint)
  {

    return _estimateBuyValue(_currencyValue.sub(gasFee));
  }

  function _estimateBuyValue(
    uint _currencyValue
  ) internal view
  returns(uint)
  {

    if(_currencyValue < minInvestment){
      return 0;
    }
    if(state == STATE_INIT){
      uint currencyValue = _currencyValue;
      uint _totalSupply = totalSupply();
      uint max = BigDiv.bigDiv2x1(
        initGoal * buySlopeNum,
        initGoal - _totalSupply + stakeholdersPoolIssued,
        buySlopeDen
      );

      if(currencyValue > max)
      {
        currencyValue = max;
      }

      uint256 tokenAmount = BigDiv.bigDiv2x1(
        currencyValue,
        buySlopeDen,
        initGoal * buySlopeNum
      );
      if(currencyValue != _currencyValue)
      {
        currencyValue = _currencyValue - max;

        uint temp = 2 * buySlopeDen;
        currencyValue = temp.mul(currencyValue);

        temp = initGoal;
        temp *= temp;

        temp = temp.mul(buySlopeNum);

        temp = currencyValue.add(temp);

        temp /= buySlopeNum;

        temp = temp.sqrt();

        temp -= initGoal;

        tokenAmount = tokenAmount.add(temp);
      }
      return tokenAmount;
    }
    else if(state == STATE_RUN) {//state == STATE_RUN{
      uint supply = totalSupply() - stakeholdersPoolIssued;
      uint currencyValue = _currencyValue;
      uint fundraisedAmount;
      if(fundraisingGoal > 0){
        uint max = BigDiv.bigDiv2x1(
          supply,
          fundraisingGoal * buySlopeNum,
          buySlopeDen
        );
        if(currencyValue > max){
          currencyValue = max;
        }
        fundraisedAmount = BigDiv.bigDiv2x2(
          currencyValue,
          buySlopeDen,
          supply,
          buySlopeNum
        );
        currencyValue = _currencyValue - currencyValue;
      }

      uint tokenAmount = BigDiv.bigDiv2x1(
        currencyValue,
        2 * buySlopeDen,
        buySlopeNum
      );

      tokenAmount = tokenAmount.add(supply * supply);
      tokenAmount = tokenAmount.sqrt();

      tokenAmount = tokenAmount.sub(supply);
      return fundraisedAmount.add(tokenAmount);
    } else {
      return 0;
    }
  }


  function sell(
    address payable _to,
    uint _quantityToSell,
    uint _minCurrencyReturned
  ) public
  {

    _sell(msg.sender, _to, _quantityToSell, _minCurrencyReturned);
  }

  function permitSell(
    address _from,
    address payable _to,
    uint _quantityToSell,
    uint _minCurrencyReturned,
    uint _deadline,
    uint8 _v,
    bytes32 _r,
    bytes32 _s
  ) external
  {

    require(_deadline >= block.timestamp, "EXPIRED");
    bytes32 digest = keccak256(abi.encode(PERMIT_SELL_TYPEHASH, _from, _to, _quantityToSell, _minCurrencyReturned, nonces[_from]++, _deadline));
    digest = keccak256(
      abi.encodePacked(
        "\x19\x01",
        DOMAIN_SEPARATOR,
        digest
      )
    );
    address recoveredAddress = ecrecover(digest, _v, _r, _s);
    require(recoveredAddress != address(0) && recoveredAddress == _from, "INVALID_SIGNATURE");
    _sell(_from, _to, _quantityToSell, _minCurrencyReturned);
  }

  function _sell(
    address _from,
    address payable _to,
    uint _quantityToSell,
    uint _minCurrencyReturned
  ) internal
  {

    require(_from != beneficiary, "BENEFICIARY_CANNOT_SELL");
    require(state != STATE_INIT || initTrial != shareholdersPool, "INIT_TRIAL_ENDED");
    require(state == STATE_INIT || state == STATE_CANCEL, "ONLY_SELL_IN_INIT_OR_CANCEL");
    require(_minCurrencyReturned > 0, "MUST_SELL_AT_LEAST_1");
    uint currencyValue = estimateSellValue(_quantityToSell);
    require(currencyValue >= _minCurrencyReturned, "PRICE_SLIPPAGE");
    initInvestors[_from] = initInvestors[_from].sub(_quantityToSell);
    _burn(_from, _quantityToSell, true);
    _transferCurrency(_to, currencyValue);
    if(state == STATE_INIT && initTrial != 0){
      initTrial = initTrial.add(_quantityToSell);
    }
    emit Sell(_from, _to, currencyValue, _quantityToSell);
  }

  function estimateSellValue(
    uint _quantityToSell
  ) public view
    returns(uint)
  {

    if(state != STATE_INIT && state != STATE_CANCEL){
      return 0;
    }
    uint reserve = buybackReserve();

    uint currencyValue;
    currencyValue = _quantityToSell.mul(reserve);
    currencyValue /= totalSupply() - stakeholdersPoolIssued - shareholdersPool;

    return currencyValue;
  }



  function close() public
  {

    _close();
    emit Close();
  }

  function _close() internal
  {

    require(msg.sender == beneficiary, "BENEFICIARY_ONLY");

    if(state == STATE_INIT)
    {
      require(initTrial > shareholdersPool,"CANNOT_CANCEL_IF_INITTRIAL_IS_ZERO");
      emit StateChange(state, STATE_CANCEL);
      state = STATE_CANCEL;
    }
    else if(state == STATE_RUN)
    {
      require(MAX_UINT - minDuration > __startedOn, "MAY_NOT_CLOSE");
      require(minDuration + __startedOn <= block.timestamp, "TOO_EARLY");

      emit StateChange(state, STATE_CLOSE);
      state = STATE_CLOSE;
    }
    else
    {
      revert("INVALID_STATE");
    }
  }

  function mint(
    address _wallet,
    uint256 _amount
  ) external
  {

    require(msg.sender == beneficiary, "ONLY_BENEFICIARY_CAN_MINT");
    require(
      _amount.add(stakeholdersPoolIssued) <= stakeholdersPoolAuthorized.mul(totalSupply().add(_amount)).div(BASIS_POINTS_DEN),
      "CANNOT_MINT_MORE_THAN_AUTHORIZED_PERCENTAGE"
    );
    stakeholdersPoolIssued = stakeholdersPoolIssued.add(_amount);
    address to = _wallet == address(0) ? beneficiary : _wallet;
    _mint(to, _amount);
  }

  function manualBuy(
    address payable _wallet,
    uint256 _currencyValue
  ) external
  {

    require(msg.sender == beneficiary, "ONLY_BENEFICIARY_CAN_MINT");
    manualBuybackReserve += _currencyValue;
    _buy(_wallet, _wallet, _currencyValue, 1, true);
  }

  function increaseCommitment(
    uint256 _newCommitment,
    uint256 _amount
  ) external
  {

    require(state == STATE_INIT || state == STATE_RUN, "ONLY_IN_INIT_OR_RUN");
    require(msg.sender == beneficiary, "ONLY_BENEFICIARY_CAN_INCREASE_COMMITMENT");
    require(_newCommitment > 0, "COMMITMENT_CANT_BE_ZERO");
    require(equityCommitment.add(_newCommitment) <= BASIS_POINTS_DEN, "EQUITY_COMMITMENT_SHOULD_BE_LESS_THAN_100%");
    equityCommitment = equityCommitment.add(_newCommitment);
    if(_amount > 0 ){
      if(state == STATE_INIT){
        changeBuySlope(initGoal, _amount + initGoal);
        initGoal = initGoal.add(_amount);
      } else {
        fundraisingGoal = _amount;
      }
      if(maxGoal != 0){
        maxGoal = maxGoal.add(_amount);
      }
    }
  }

  function convertToCafe(
    uint256 _newCommitment,
    uint256 _amount,
    address _wallet
  ) external {

    require(state == STATE_INIT || state == STATE_RUN, "ONLY_IN_INIT_OR_RUN");
    require(msg.sender == beneficiary, "ONLY_BENEFICIARY_CAN_INCREASE_COMMITMENT");
    require(_newCommitment > 0, "COMMITMENT_CANT_BE_ZERO");
    require(equityCommitment.add(_newCommitment) <= BASIS_POINTS_DEN, "EQUITY_COMMITMENT_SHOULD_BE_LESS_THAN_100%");
    require(_wallet != beneficiary && _wallet != address(0), "WALLET_CANNOT_BE_ZERO_OR_BENEFICIARY");
    equityCommitment = equityCommitment.add(_newCommitment);
    if(_amount > 0 ){
      shareholdersPool = shareholdersPool.add(_amount);
      if(state == STATE_INIT){
        changeBuySlope(initGoal, _amount + initGoal);
        initGoal = initGoal.add(_amount);
        if(initTrial != 0){
          initTrial = initTrial.add(_amount);
        }
      }
      else {
        changeBuySlope(totalSupply() - stakeholdersPoolIssued, _amount + totalSupply() - stakeholdersPoolIssued);
      }
      _mint(_wallet, _amount);
      if(maxGoal != 0){
        maxGoal = maxGoal.add(_amount);
      }
    }
  }

  function increaseValuation(uint256 _newValuation) external {

    require(state == STATE_INIT || state == STATE_RUN, "ONLY_IN_INIT_OR_RUN");
    require(msg.sender == beneficiary, "ONLY_BENEFICIARY_CAN_INCREASE_VALUATION");
    uint256 oldValuation;
    if(state == STATE_INIT){
      oldValuation = (initGoal).mul(initGoal).mul(buySlopeNum).mul(BASIS_POINTS_DEN).div(buySlopeDen).div(equityCommitment);
      require(_newValuation > oldValuation, "VALUATION_CAN_NOT_DECREASE");
      changeBuySlope(_newValuation, oldValuation);
    }else {
      oldValuation = (totalSupply() - stakeholdersPoolIssued).mul(totalSupply() - stakeholdersPoolIssued).mul(buySlopeNum).mul(BASIS_POINTS_DEN).div(buySlopeDen).div(equityCommitment);
      require(_newValuation > oldValuation, "VALUATION_CAN_NOT_DECREASE");
      changeBuySlope(_newValuation, oldValuation);
    }
  }

  function changeBuySlope(uint256 _numerator, uint256 _denominator) internal {

    require(_denominator > 0, "DIV_0");
    if(_numerator == 0){
      buySlopeNum = 0;
      return;
    }
    uint256 tryDen = BigDiv.bigDiv2x1(
      buySlopeDen,
      _denominator,
      _numerator
    );
    if(tryDen <= MAX_BEFORE_SQUARE){
      buySlopeDen = tryDen;
      return;
    }
    uint256 tryNum = BigDiv.bigDiv2x1(
      buySlopeNum,
      _numerator,
      _denominator
    );
    if(tryNum > 0 && tryNum <= MAX_BEFORE_SQUARE) {
      buySlopeNum = tryNum;
      return;
    }
    revert("error while changing slope");
  }

  function batchTransfer(address[] calldata recipients, uint256[] calldata amounts) external {

    require(msg.sender == beneficiary, "ONLY_BENEFICIARY_CAN_BATCH_TRANSFER");
    require(recipients.length == amounts.length, "ARRAY_LENGTH_DIFF");
    require(recipients.length <= MAX_ITERATION, "EXCEEDS_MAX_ITERATION");
    for(uint256 i = 0; i<recipients.length; i++) {
      _transfer(msg.sender, recipients[i], amounts[0]);
    }
  }

  function() external payable {
    require(address(currency) == address(0), "ONLY_FOR_CURRENCY_ETH");
  }


  function permit(
    address owner,
    address spender,
    uint value,
    uint deadline,
    uint8 v,
    bytes32 r,
    bytes32 s
  ) external
  {

    require(deadline >= block.timestamp, "EXPIRED");
    bytes32 digest = keccak256(abi.encode(PERMIT_TYPEHASH, owner, spender, value, nonces[owner]++, deadline));
    digest = keccak256(
      abi.encodePacked(
        "\x19\x01",
        DOMAIN_SEPARATOR,
        digest
      )
    );
    address recoveredAddress = ecrecover(digest, v, r, s);
    require(recoveredAddress != address(0) && recoveredAddress == owner, "INVALID_SIGNATURE");
    _approve(owner, spender, value);
  }

  uint256[50] private __gap;
}