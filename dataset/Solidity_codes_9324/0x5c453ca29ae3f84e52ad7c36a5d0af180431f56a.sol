



pragma solidity 0.5.16;


interface IWhitelist
{

  function detectTransferRestriction(
    address from,
    address to,
    uint value
  ) external view
    returns (uint8);


  function messageForTransferRestriction(
    uint8 restrictionCode
  ) external pure
    returns (string memory);


  function authorizeTransfer(
    address _from,
    address _to,
    uint _value,
    bool _isSell
  ) external;

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


library BigDiv
{

  using SafeMath for uint256;

  uint256 private constant MAX_UINT = 2**256 - 1;

  uint256 private constant MAX_BEFORE_SQUARE = 2**128 - 1;

  uint256 private constant MAX_ERROR = 100000000;

  uint256 private constant MAX_ERROR_BEFORE_DIV = MAX_ERROR * 2;

  function bigDiv2x1(
    uint256 _numA,
    uint256 _numB,
    uint256 _den
  ) internal pure
    returns(uint256)
  {

    if(_numA == 0 || _numB == 0)
    {
      return 0;
    }

    uint256 value;

    if(MAX_UINT / _numA >= _numB)
    {
      value = _numA * _numB;
      value /= _den;
      return value;
    }

    uint256 numMax = _numB;
    uint256 numMin = _numA;
    if(_numA > _numB)
    {
      numMax = _numA;
      numMin = _numB;
    }

    value = numMax / _den;
    if(value > MAX_ERROR)
    {
      value = value.mul(numMin);
      return value;
    }

    uint256 factor = numMin - 1;
    factor /= MAX_BEFORE_SQUARE;
    factor += 1;
    uint256 temp = numMax - 1;
    temp /= MAX_BEFORE_SQUARE;
    temp += 1;
    if(MAX_UINT / factor >= temp)
    {
      factor *= temp;
      value = numMax / factor;
      if(value > MAX_ERROR_BEFORE_DIV)
      {
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
    uint256 _numA,
    uint256 _numB,
    uint256 _den
  ) internal pure
    returns(uint256)
  {

    uint256 value = bigDiv2x1(_numA, _numB, _den);

    if(value == 0)
    {
      return 1;
    }

    uint256 temp = value - 1;
    temp /= MAX_ERROR;
    temp += 1;
    if(MAX_UINT - value < temp)
    {
      return MAX_UINT;
    }

    value += temp;

    return value;
  }

  function bigDiv2x2(
    uint256 _numA,
    uint256 _numB,
    uint256 _denA,
    uint256 _denB
  ) internal pure
    returns (uint256)
  {

    if(MAX_UINT / _denA >= _denB)
    {
      return bigDiv2x1(_numA, _numB, _denA * _denB);
    }

    if(_numA == 0 || _numB == 0)
    {
      return 0;
    }

    uint256 denMax = _denB;
    uint256 denMin = _denA;
    if(_denA > _denB)
    {
      denMax = _denA;
      denMin = _denB;
    }

    uint256 value;

    if(MAX_UINT / _numA >= _numB)
    {
      value = _numA * _numB;
      value /= denMin;
      value /= denMax;
      return value;
    }


    uint256 numMax = _numB;
    uint256 numMin = _numA;
    if(_numA > _numB)
    {
      numMax = _numA;
      numMin = _numB;
    }

    uint256 temp = numMax / denMin;
    if(temp > MAX_ERROR_BEFORE_DIV)
    {
      return bigDiv2x1(temp, numMin, denMax);
    }

    uint256 factor = numMin - 1;
    factor /= MAX_BEFORE_SQUARE;
    factor += 1;
    temp = numMax - 1;
    temp /= MAX_BEFORE_SQUARE;
    temp += 1;
    if(MAX_UINT / factor >= temp)
    {
      factor *= temp;

      value = numMax / factor;
      if(value > MAX_ERROR_BEFORE_DIV)
      {
        value = value.mul(numMin);
        value /= denMin;
        if(value > 0 && MAX_UINT / value >= factor)
        {
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


library Sqrt
{

  uint256 private constant MAX_UINT = 2**256 - 1;

  function sqrt(
    uint x
  ) internal pure
    returns (uint y)
  {

    if (x == 0)
    {
      return 0;
    }
    else if (x <= 3)
    {
      return 1;
    }
    else if (x == MAX_UINT)
    {
      return 2**128 - 1;
    }

    uint z = (x + 1) / 2;
    y = x;
    while (z < y)
    {
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
        return (codehash != 0x0 && codehash != accountHash);
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


pragma solidity >=0.4.24 <0.6.0;


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

    uint256 cs;
    assembly { cs := extcodesize(address) }
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


pragma solidity 0.5.16;











contract DecentralizedAutonomousTrust
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
  event Pay(
    address indexed _from,
    address indexed _to,
    uint _currencyValue,
    uint _fairValue
  );
  event Close(
    uint _exitFee
  );
  event StateChange(
    uint _previousState,
    uint _newState
  );
  event UpdateConfig(
    address _whitelistAddress,
    address indexed _beneficiary,
    address indexed _control,
    address indexed _feeCollector,
    bool _autoBurn,
    uint _revenueCommitmentBasisPoints,
    uint _feeBasisPoints,
    uint _minInvestment,
    uint _openUntilAtLeast
  );


  uint private constant STATE_INIT = 0;

  uint private constant STATE_RUN = 1;

  uint private constant STATE_CLOSE = 2;

  uint private constant STATE_CANCEL = 3;

  uint private constant MAX_BEFORE_SQUARE = 2**128 - 1;

  uint private constant BASIS_POINTS_DEN = 10000;

  uint private constant MAX_SUPPLY = 10 ** 38;


  IWhitelist public whitelist;

  uint public burnedSupply;


  bool public autoBurn;

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

  uint public investmentReserveBasisPoints;

  uint public openUntilAtLeast;

  uint public minInvestment;

  uint public revenueCommitmentBasisPoints;

  uint public state;

  string public constant version = "2";
  mapping (address => uint) public nonces;
  bytes32 public DOMAIN_SEPARATOR;
  bytes32 public constant PERMIT_TYPEHASH = 0xea2aa0a1be11a07ed86d755c93467f4f82362b452371d1ba94d1715123511acb;

  modifier authorizeTransfer(
    address _from,
    address _to,
    uint _value,
    bool _isSell
  )
  {

    if(address(whitelist) != address(0))
    {
      whitelist.authorizeTransfer(_from, _to, _value, _isSell);
    }
    _;
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

    return reserve;
  }


  function _detectTransferRestriction(
    address _from,
    address _to,
    uint _value
  ) private view
    returns (uint)
  {

    if(address(whitelist) != address(0))
    {
      return whitelist.detectTransferRestriction(_from, _to, _value);
    }

    return 0;
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
      require(state == STATE_RUN, "ONLY_DURING_RUN");
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
    uint _quantityToInvest,
    uint _msgValue,
    bool _refundRemainder
  ) private
  {

    if(address(currency) == address(0))
    {
      if(_refundRemainder)
      {
        uint refund = _msgValue.sub(_quantityToInvest);
        if(refund > 0)
        {
          Address.sendValue(msg.sender, refund);
        }
      }
      else
      {
        require(_quantityToInvest == _msgValue, "INCORRECT_MSG_VALUE");
      }
    }
    else
    {
      require(_msgValue == 0, "DO_NOT_SEND_ETH");

      currency.safeTransferFrom(msg.sender, address(this), _quantityToInvest);
    }
  }

  function _transferCurrency(
    address payable _to,
    uint _amount
  ) private
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
    uint _investmentReserveBasisPoints,
    string memory _name,
    string memory _symbol
  ) public
  {

    require(control == address(0), "ALREADY_INITIALIZED");

    ERC20Detailed.initialize(_name, _symbol, 18);

    if(_initGoal == 0)
    {
      emit StateChange(state, STATE_RUN);
      state = STATE_RUN;
    }
    else
    {
      require(_initGoal < MAX_SUPPLY, "EXCESSIVE_GOAL");
      initGoal = _initGoal;
    }

    require(_buySlopeNum > 0, "INVALID_SLOPE_NUM");
    require(_buySlopeDen > 0, "INVALID_SLOPE_DEN");
    require(_buySlopeNum < MAX_BEFORE_SQUARE, "EXCESSIVE_SLOPE_NUM");
    require(_buySlopeDen < MAX_BEFORE_SQUARE, "EXCESSIVE_SLOPE_DEN");
    buySlopeNum = _buySlopeNum;
    buySlopeDen = _buySlopeDen;
    require(_investmentReserveBasisPoints <= BASIS_POINTS_DEN, "INVALID_RESERVE");
    investmentReserveBasisPoints = _investmentReserveBasisPoints;

    minInvestment = 100 ether;
    beneficiary = msg.sender;
    control = msg.sender;
    feeCollector = msg.sender;

    currency = IERC20(_currencyAddress);

    if(_initReserve > 0)
    {
      initReserve = _initReserve;
      _mint(beneficiary, initReserve);
    }
  }
  function getChainId(
  ) private pure
    returns (uint id)
  {

    assembly
    {
      id := chainid()
    }
  }

  function initializePermit(
  ) public
  {

    DOMAIN_SEPARATOR = keccak256(
      abi.encode(
        keccak256("EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)"),
        keccak256(bytes(name())),
        keccak256(bytes(version)),
        getChainId(),
        address(this)
      )
    );
  }

  function updateConfig(
    address _whitelistAddress,
    address payable _beneficiary,
    address _control,
    address payable _feeCollector,
    uint _feeBasisPoints,
    bool _autoBurn,
    uint _revenueCommitmentBasisPoints,
    uint _minInvestment,
    uint _openUntilAtLeast
  ) public
  {

    require(msg.sender == control, "CONTROL_ONLY");

    whitelist = IWhitelist(_whitelistAddress);

    require(_control != address(0), "INVALID_ADDRESS");
    control = _control;

    require(_feeCollector != address(0), "INVALID_ADDRESS");
    feeCollector = _feeCollector;

    autoBurn = _autoBurn;

    require(_revenueCommitmentBasisPoints <= BASIS_POINTS_DEN, "INVALID_COMMITMENT");
    require(_revenueCommitmentBasisPoints >= revenueCommitmentBasisPoints, "COMMITMENT_MAY_NOT_BE_REDUCED");
    revenueCommitmentBasisPoints = _revenueCommitmentBasisPoints;

    require(_feeBasisPoints <= BASIS_POINTS_DEN, "INVALID_FEE");
    feeBasisPoints = _feeBasisPoints;

    require(_minInvestment > 0, "INVALID_MIN_INVESTMENT");
    minInvestment = _minInvestment;

    require(_openUntilAtLeast >= openUntilAtLeast, "OPEN_UNTIL_MAY_NOT_BE_REDUCED");
    openUntilAtLeast = _openUntilAtLeast;

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

    emit UpdateConfig(
      _whitelistAddress,
      _beneficiary,
      _control,
      _feeCollector,
      _autoBurn,
      _revenueCommitmentBasisPoints,
      _feeBasisPoints,
      _minInvestment,
      _openUntilAtLeast
    );
  }


  function burn(
    uint _amount
  ) public
  {

    _burn(msg.sender, _amount, false);
  }


  function _distributeInvestment(
    uint _value
  ) private
  {


    uint reserve = investmentReserveBasisPoints.mul(_value);
    reserve /= BASIS_POINTS_DEN;
    reserve = _value.sub(reserve);
    uint fee = reserve.mul(feeBasisPoints);
    fee /= BASIS_POINTS_DEN;

    _transferCurrency(beneficiary, reserve - fee);
    _transferCurrency(feeCollector, fee);
  }

  function estimateBuyValue(
    uint _currencyValue
  ) public view
    returns (uint)
  {

    if(_currencyValue < minInvestment)
    {
      return 0;
    }

    uint tokenValue;
    if(state == STATE_INIT)
    {
      uint currencyValue = _currencyValue;
      uint _totalSupply = totalSupply();
      uint max = BigDiv.bigDiv2x1(
        initGoal * buySlopeNum,
        initGoal + initReserve - _totalSupply,
        2 * buySlopeDen
      );
      if(currencyValue > max)
      {
        currencyValue = max;
      }
      tokenValue = BigDiv.bigDiv2x1(
        currencyValue,
        2 * buySlopeDen,
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

        tokenValue = tokenValue.add(temp);
      }
    }
    else if(state == STATE_RUN)
    {
      uint supply = totalSupply() + burnedSupply - initReserve;
      tokenValue = BigDiv.bigDiv2x1(
        _currencyValue,
        2 * buySlopeDen,
        buySlopeNum
      );

      tokenValue = tokenValue.add(supply * supply);
      tokenValue = tokenValue.sqrt();

      tokenValue = tokenValue.sub(supply);
    }
    else
    {
      return 0;
    }

    return tokenValue;
  }

  function buy(
    address _to,
    uint _currencyValue,
    uint _minTokensBought
  ) public payable
  {

    require(_to != address(0), "INVALID_ADDRESS");
    require(_minTokensBought > 0, "MUST_BUY_AT_LEAST_1");

    uint tokenValue = estimateBuyValue(_currencyValue);
    require(tokenValue >= _minTokensBought, "PRICE_SLIPPAGE");

    emit Buy(msg.sender, _to, _currencyValue, tokenValue);

    _collectInvestment(_currencyValue, msg.value, false);

    if(state == STATE_INIT)
    {
      initInvestors[_to] += tokenValue;
      if(totalSupply() + tokenValue - initReserve >= initGoal)
      {
        emit StateChange(state, STATE_RUN);
        state = STATE_RUN;
        uint beneficiaryContribution = BigDiv.bigDiv2x1(
          initInvestors[beneficiary],
          buySlopeNum * initGoal,
          buySlopeDen * 2
        );
        _distributeInvestment(buybackReserve().sub(beneficiaryContribution));
      }
    }
    else // implied: if(state == STATE_RUN)
    {
      if(_to != beneficiary)
      {
        _distributeInvestment(_currencyValue);
      }
    }

    _mint(_to, tokenValue);

    if(state == STATE_RUN && msg.sender == beneficiary && _to == beneficiary && autoBurn)
    {
      _burn(beneficiary, tokenValue, false);
    }
  }


  function estimateSellValue(
    uint _quantityToSell
  ) public view
    returns(uint)
  {

    uint reserve = buybackReserve();

    uint currencyValue;
    if(state == STATE_RUN)
    {
      uint supply = totalSupply() + burnedSupply;


      currencyValue = BigDiv.bigDiv2x2(
        _quantityToSell.mul(reserve),
        burnedSupply * burnedSupply,
        totalSupply(), supply * supply
      );

      uint temp = _quantityToSell.mul(2 * reserve);
      temp /= supply;

      currencyValue += temp;

      currencyValue -= BigDiv.bigDiv2x1RoundUp(
        _quantityToSell.mul(_quantityToSell),
        reserve,
        supply * supply
      );
    }
    else if(state == STATE_CLOSE)
    {
      currencyValue = _quantityToSell.mul(reserve);
      currencyValue /= totalSupply();
    }
    else
    {
      currencyValue = _quantityToSell.mul(reserve);
      currencyValue /= totalSupply() - initReserve;
    }

    return currencyValue;
  }

  function sell(
    address payable _to,
    uint _quantityToSell,
    uint _minCurrencyReturned
  ) public
  {

    require(msg.sender != beneficiary || state >= STATE_CLOSE, "BENEFICIARY_ONLY_SELL_IN_CLOSE_OR_CANCEL");
    require(_minCurrencyReturned > 0, "MUST_SELL_AT_LEAST_1");

    uint currencyValue = estimateSellValue(_quantityToSell);
    require(currencyValue >= _minCurrencyReturned, "PRICE_SLIPPAGE");

    if(state == STATE_INIT || state == STATE_CANCEL)
    {
      initInvestors[msg.sender] = initInvestors[msg.sender].sub(_quantityToSell);
    }

    _burn(msg.sender, _quantityToSell, true);
    uint supply = totalSupply() + burnedSupply;
    if(supply < initReserve)
    {
      initReserve = supply;
    }

    _transferCurrency(_to, currencyValue);
    emit Sell(msg.sender, _to, currencyValue, _quantityToSell);
  }


  function estimatePayValue(
    uint _currencyValue
  ) public view
    returns (uint)
  {


    uint supply = totalSupply() + burnedSupply;

    uint tokenValue = BigDiv.bigDiv2x1(
      _currencyValue.mul(2 * revenueCommitmentBasisPoints),
      buySlopeDen,
      BASIS_POINTS_DEN * buySlopeNum
    );

    tokenValue = tokenValue.add(supply * supply);
    tokenValue = tokenValue.sqrt();

    if(tokenValue > supply)
    {
      tokenValue -= supply;
    }
    else
    {
      tokenValue = 0;
    }

    return tokenValue;
  }

  function _pay(
    address _to,
    uint _currencyValue
  ) private
  {

    require(_currencyValue > 0, "MISSING_CURRENCY");
    require(state == STATE_RUN, "INVALID_STATE");

    uint reserve = _currencyValue.mul(investmentReserveBasisPoints);
    reserve /= BASIS_POINTS_DEN;

    uint tokenValue = estimatePayValue(_currencyValue);

    address to = _to;
    if(to == address(0))
    {
      to = beneficiary;
    }
    else if(_detectTransferRestriction(address(0), _to, tokenValue) != 0)
    {
      to = beneficiary;
    }

    _transferCurrency(beneficiary, _currencyValue - reserve);

    if(tokenValue > 0)
    {
      _mint(to, tokenValue);
      if(to == beneficiary && autoBurn)
      {
        _burn(beneficiary, tokenValue, false);
      }
    }

    emit Pay(msg.sender, _to, _currencyValue, tokenValue);
  }

  function pay(
    address _to,
    uint _currencyValue
  ) public payable
  {

    _collectInvestment(_currencyValue, msg.value, false);
    _pay(_to, _currencyValue);
  }


  function estimateExitFee(
    uint _msgValue
  ) public view
    returns(uint)
  {

    uint exitFee;

    if(state == STATE_RUN)
    {
      uint reserve = buybackReserve();
      reserve = reserve.sub(_msgValue);


      uint _totalSupply = totalSupply();

      exitFee = BigDiv.bigDiv2x1(
        _totalSupply,
        burnedSupply * buySlopeNum,
        buySlopeDen
      );
      exitFee += BigDiv.bigDiv2x1(
        _totalSupply,
        buySlopeNum * _totalSupply,
        buySlopeDen
      );
      if(exitFee <= reserve)
      {
        exitFee = 0;
      }
      else
      {
        exitFee -= reserve;
      }
    }

    return exitFee;
  }

  function close() public payable
  {

    require(msg.sender == beneficiary, "BENEFICIARY_ONLY");

    uint exitFee = 0;

    if(state == STATE_INIT)
    {
      emit StateChange(state, STATE_CANCEL);
      state = STATE_CANCEL;
    }
    else if(state == STATE_RUN)
    {
      require(openUntilAtLeast <= block.timestamp, "TOO_EARLY");

      exitFee = estimateExitFee(msg.value);

      emit StateChange(state, STATE_CLOSE);
      state = STATE_CLOSE;

      _collectInvestment(exitFee, msg.value, true);
    }
    else
    {
      revert("INVALID_STATE");
    }

    emit Close(exitFee);
  }

  function permit(
    address holder,
    address spender,
    uint256 nonce,
    uint256 expiry,
    bool allowed,
    uint8 v,
    bytes32 r,
    bytes32 s
  ) external
  {

    bytes32 digest = keccak256(
      abi.encodePacked(
        "\x19\x01",
        DOMAIN_SEPARATOR,
        keccak256(
          abi.encode(PERMIT_TYPEHASH,
                    holder,
                    spender,
                    nonce,
                    expiry,
                    allowed
          )
        )
      )
    );

    require(holder != address(0), "DAT/invalid-address-0");
    require(holder == ecrecover(digest, v, r, s), "DAT/invalid-permit");
    require(expiry == 0 || now <= expiry, "DAT/permit-expired");
    require(nonce == nonces[holder]++, "DAT/invalid-nonce");
    uint wad = allowed ? uint(-1) : 0;
    _approve(holder, spender, wad);
  }
}