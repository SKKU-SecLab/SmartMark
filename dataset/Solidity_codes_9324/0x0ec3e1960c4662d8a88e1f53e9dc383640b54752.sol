
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


  function activateWallet(
    address _wallet
  ) external;


  function deactivateWallet(
    address _wallet
  ) external;


  function walletActivated(
    address _wallet
  ) external returns(bool);

}

interface IERC20Detailed {

  function decimals() external view returns (uint8);


  function name() external view returns (string memory);


  function symbol() external view returns (string memory);


}

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

library Roles {

    struct Role {
        mapping (address => bool) bearer;
    }

    function add(Role storage role, address account) internal {

        require(!has(role, account), "Roles: account already has role");
        role.bearer[account] = true;
    }

    function remove(Role storage role, address account) internal {

        require(has(role, account), "Roles: account does not have role");
        role.bearer[account] = false;
    }

    function has(Role storage role, address account) internal view returns (bool) {

        require(account != address(0), "Roles: account is the zero address");
        return role.bearer[account];
    }
}

contract MinterRole is Initializable, Context {

    using Roles for Roles.Role;

    event MinterAdded(address indexed account);
    event MinterRemoved(address indexed account);

    Roles.Role private _minters;

    function initialize(address sender) public initializer {

        if (!isMinter(sender)) {
            _addMinter(sender);
        }
    }

    modifier onlyMinter() {

        require(isMinter(_msgSender()), "MinterRole: caller does not have the Minter role");
        _;
    }

    function isMinter(address account) public view returns (bool) {

        return _minters.has(account);
    }

    function addMinter(address account) public onlyMinter {

        _addMinter(account);
    }

    function renounceMinter() public {

        _removeMinter(_msgSender());
    }

    function _addMinter(address account) internal {

        _minters.add(account);
        emit MinterAdded(account);
    }

    function _removeMinter(address account) internal {

        _minters.remove(account);
        emit MinterRemoved(account);
    }

    uint256[50] private ______gap;
}

contract ERC20Mintable is Initializable, ERC20, MinterRole {

    function initialize(address sender) public initializer {

        MinterRole.initialize(sender);
    }

    function mint(address account, uint256 amount) public onlyMinter returns (bool) {

        _mint(account, amount);
        return true;
    }

    uint256[50] private ______gap;
}

contract ERC20Capped is Initializable, ERC20Mintable {

    uint256 private _cap;

    function initialize(uint256 cap, address sender) public initializer {

        ERC20Mintable.initialize(sender);

        require(cap > 0, "ERC20Capped: cap is 0");
        _cap = cap;
    }

    function cap() public view returns (uint256) {

        return _cap;
    }

    function _mint(address account, uint256 value) internal {

        require(totalSupply().add(value) <= _cap, "ERC20Capped: cap exceeded");
        super._mint(account, value);
    }

    uint256[50] private ______gap;
}

contract PauserRole is Initializable, Context {

    using Roles for Roles.Role;

    event PauserAdded(address indexed account);
    event PauserRemoved(address indexed account);

    Roles.Role private _pausers;

    function initialize(address sender) public initializer {

        if (!isPauser(sender)) {
            _addPauser(sender);
        }
    }

    modifier onlyPauser() {

        require(isPauser(_msgSender()), "PauserRole: caller does not have the Pauser role");
        _;
    }

    function isPauser(address account) public view returns (bool) {

        return _pausers.has(account);
    }

    function addPauser(address account) public onlyPauser {

        _addPauser(account);
    }

    function renouncePauser() public {

        _removePauser(_msgSender());
    }

    function _addPauser(address account) internal {

        _pausers.add(account);
        emit PauserAdded(account);
    }

    function _removePauser(address account) internal {

        _pausers.remove(account);
        emit PauserRemoved(account);
    }

    uint256[50] private ______gap;
}

contract Pausable is Initializable, Context, PauserRole {

    event Paused(address account);

    event Unpaused(address account);

    bool private _paused;

    function initialize(address sender) public initializer {

        PauserRole.initialize(sender);

        _paused = false;
    }

    function paused() public view returns (bool) {

        return _paused;
    }

    modifier whenNotPaused() {

        require(!_paused, "Pausable: paused");
        _;
    }

    modifier whenPaused() {

        require(_paused, "Pausable: not paused");
        _;
    }

    function pause() public onlyPauser whenNotPaused {

        _paused = true;
        emit Paused(_msgSender());
    }

    function unpause() public onlyPauser whenPaused {

        _paused = false;
        emit Unpaused(_msgSender());
    }

    uint256[50] private ______gap;
}

contract ERC20Pausable is Initializable, ERC20, Pausable {

    function initialize(address sender) public initializer {

        Pausable.initialize(sender);
    }

    function transfer(address to, uint256 value) public whenNotPaused returns (bool) {

        return super.transfer(to, value);
    }

    function transferFrom(address from, address to, uint256 value) public whenNotPaused returns (bool) {

        return super.transferFrom(from, to, value);
    }

    function approve(address spender, uint256 value) public whenNotPaused returns (bool) {

        return super.approve(spender, value);
    }

    function increaseAllowance(address spender, uint256 addedValue) public whenNotPaused returns (bool) {

        return super.increaseAllowance(spender, addedValue);
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public whenNotPaused returns (bool) {

        return super.decreaseAllowance(spender, subtractedValue);
    }

    uint256[50] private ______gap;
}

contract ContinuousOffering is ERC20Pausable, ERC20Capped, IERC20Detailed
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


  uint internal constant STATE_INIT = 0;

  uint internal constant STATE_RUN = 1;

  uint internal constant STATE_CLOSE = 2;

  uint internal constant STATE_CANCEL = 3;

  uint internal constant MAX_BEFORE_SQUARE = 2**128 - 1;

  uint internal constant BASIS_POINTS_DEN = 10000;

  uint internal constant MAX_SUPPLY = 10 ** 38;


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

  string public constant version = "3";
  mapping (address => uint) public nonces;
  bytes32 public DOMAIN_SEPARATOR;
  bytes32 public constant PERMIT_TYPEHASH = 0x6e71edae12b1b97f4d1f60370fef10105fa2faae0126114a169c64845d6126c9;

  uint public setupFee;

  address payable public setupFeeRecipient;

  uint public minDuration;

  uint public __startedOn;

  uint internal constant MAX_UINT = 2**256 - 1;

  bytes32 public constant PERMIT_BUY_TYPEHASH = 0xaf42a244b3020d6a2253d9f291b4d3e82240da42b22129a8113a58aa7a3ddb6a;

  bytes32 public constant PERMIT_SELL_TYPEHASH = 0x5dfdc7fb4c68a4c249de5e08597626b84fbbe7bfef4ed3500f58003e722cc548;

  modifier authorizeTransfer(
    address _from,
    address _to,
    uint _value,
    bool _isSell
  )
  {

    if(address(whitelist) != address(0))
    {
      if(!whitelist.walletActivated(_from) && _from != address(0) && !(_to == address(0) && !_isSell)){
        whitelist.activateWallet(_from);
      }
      if(!whitelist.walletActivated(_to) && _to != address(0)){
        whitelist.activateWallet(_to);
      }
      whitelist.authorizeTransfer(_from, _to, _value, _isSell);
    }
    _;
    if(address(whitelist) != address(0)){
      if(balanceOf(_from) == 0 && _from != address(0) && !(_to==address(0) && !_isSell)){
        whitelist.deactivateWallet(_from);
      }
    }
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
      require(state == STATE_RUN, "INVALID_STATE");
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
    uint _msgValue,
    bool _refundRemainder
  ) internal
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


  function _initialize(
    uint _initReserve,
    address _currencyAddress,
    uint _initGoal,
    uint _buySlopeNum,
    uint _buySlopeDen,
    uint _setupFee,
    address payable _setupFeeRecipient
  ) internal
  {

    ERC20Capped.initialize((5000000 * (10 ** 18)), msg.sender);
    _addPauser(msg.sender);

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

  function _updateConfig(
    address _whitelistAddress,
    address payable _beneficiary,
    address _control,
    address payable _feeCollector,
    uint _feeBasisPoints,
    uint _minInvestment,
    uint _minDuration
  ) internal
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
  }


  function burn(
    uint _amount
  ) public
  {

    _burn(msg.sender, _amount, false);
  }

  function burnFrom(
    address _from,
    uint _amount
  ) public
  {

    _approve(_from, msg.sender, allowance(_from, msg.sender).sub(_amount, "ERC20: burn amount exceeds allowance"));
    _burn(_from, _amount, false);
  }


  function _distributeInvestment(uint _value) internal;


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
        buySlopeDen
      );
      if(currencyValue > max)
      {
        currencyValue = max;
      }
      tokenValue = BigDiv.bigDiv2x1(
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

  function _buy(
    address payable _from,
    address _to,
    uint _currencyValue,
    uint _minTokensBought
  ) internal
  {

    require(_to != address(0), "INVALID_ADDRESS");
    require(_minTokensBought > 0, "MUST_BUY_AT_LEAST_1");

    uint tokenValue = estimateBuyValue(_currencyValue);
    require(tokenValue >= _minTokensBought, "PRICE_SLIPPAGE");

    emit Buy(_from, _to, _currencyValue, tokenValue);

    _collectInvestment(_from, _currencyValue, msg.value, false);

    if(state == STATE_INIT)
    {
      initInvestors[_to] += tokenValue;
      if(totalSupply() + tokenValue - initReserve >= initGoal)
      {
        emit StateChange(state, STATE_RUN);
        state = STATE_RUN;
        if(__startedOn == 0) {
          __startedOn = block.timestamp;
        }

        uint beneficiaryContribution = BigDiv.bigDiv2x1(
          initInvestors[beneficiary],
          buySlopeNum * initGoal,
          buySlopeDen
        );

        if(setupFee > 0)
        {
          _transferCurrency(setupFeeRecipient, setupFee);
          if(beneficiaryContribution > setupFee)
          {
            beneficiaryContribution -= setupFee;
          }
          else
          {
            beneficiaryContribution = 0;
          }
        }

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
  }

  function buy(
    address _to,
    uint _currencyValue,
    uint _minTokensBought
  ) public payable
  {

    _buy(msg.sender, _to, _currencyValue, _minTokensBought);
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
    _buy(_from, _to, _currencyValue, _minTokensBought);
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

      temp = BigDiv.bigDiv2x1RoundUp(
        _quantityToSell.mul(_quantityToSell),
        reserve,
        supply * supply
      );
      if(currencyValue > temp)
      {
        currencyValue -= temp;
      }
      else
      {
        currencyValue = 0;
      }
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

  function _sell(
    address _from,
    address payable _to,
    uint _quantityToSell,
    uint _minCurrencyReturned
  ) internal
  {

    require(_from != beneficiary || state >= STATE_CLOSE, "BENEFICIARY_ONLY_SELL_IN_CLOSE_OR_CANCEL");
    require(_minCurrencyReturned > 0, "MUST_SELL_AT_LEAST_1");

    uint currencyValue = estimateSellValue(_quantityToSell);
    require(currencyValue >= _minCurrencyReturned, "PRICE_SLIPPAGE");

    if(state == STATE_INIT || state == STATE_CANCEL)
    {
      initInvestors[_from] = initInvestors[_from].sub(_quantityToSell);
    }

    _burn(_from, _quantityToSell, true);
    uint supply = totalSupply() + burnedSupply;
    if(supply < initReserve)
    {
      initReserve = supply;
    }

    _transferCurrency(_to, currencyValue);
    emit Sell(_from, _to, currencyValue, _quantityToSell);
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


  function _close() internal
  {

    require(msg.sender == beneficiary, "BENEFICIARY_ONLY");

    if(state == STATE_INIT)
    {
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

  function name() public view returns (string memory) {

    return "Liquidity Vision";
  }

  function symbol() public view returns (string memory) {

    return "VISION";
  }

  function decimals() public view returns (uint8) {

    return 18;
  }

  uint256[50] private __gap;
}

contract LiquidityVisionToken is ContinuousOffering {

  event Close(uint _exitFee);
  event Pay(address indexed _from, uint _currencyValue);
  event UpdateConfig(
    address _whitelistAddress,
    address indexed _beneficiary,
    address indexed _control,
    address indexed _feeCollector,
    uint _revenueCommitmentBasisPoints,
    uint _feeBasisPoints,
    uint _minInvestment,
    uint _minDuration
  );

  function revenueCommitmentBasisPoints() public view returns (uint) {

    return __revenueCommitmentBasisPoints;
  }

  function investmentReserveBasisPoints() public view returns (uint) {

    return __investmentReserveBasisPoints;
  }

  function runStartedOn() public view returns (uint) {

    return __startedOn;
  }

  function initialize(
    uint _initReserve,
    address _currencyAddress,
    uint _initGoal,
    uint _buySlopeNum,
    uint _buySlopeDen,
    uint _investmentReserveBasisPoints,
    uint _setupFee,
    address payable _setupFeeRecipient
  ) public
  {

    super._initialize(
      _initReserve,
      _currencyAddress,
      _initGoal,
      _buySlopeNum,
      _buySlopeDen,
      _setupFee,
      _setupFeeRecipient
    );

    if(_initGoal == 0)
    {
      emit StateChange(state, STATE_RUN);
      state = STATE_RUN;
      __startedOn = block.timestamp;
    }
    else
    {
      require(_initGoal < MAX_SUPPLY, "EXCESSIVE_GOAL");
      initGoal = _initGoal;
    }

    require(_investmentReserveBasisPoints <= BASIS_POINTS_DEN, "INVALID_RESERVE");
    __investmentReserveBasisPoints = _investmentReserveBasisPoints;
  }





  function estimateExitFee(uint _msgValue) public view returns (uint) {

    uint exitFee;

    if (state == STATE_RUN) {
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
      if (exitFee <= reserve) {
        exitFee = 0;
      } else {
        exitFee -= reserve;
      }
    }

    return exitFee;
  }

  function close() public payable {

    uint exitFee = 0;

    if (state == STATE_RUN) {
      exitFee = estimateExitFee(msg.value);
      _collectInvestment(msg.sender, exitFee, msg.value, true);
    }

    super._close();
    emit Close(exitFee);
  }


  function pay(uint _currencyValue) public payable {

    _collectInvestment(msg.sender, _currencyValue, msg.value, false);
    require(state == STATE_RUN, "INVALID_STATE");
    require(_currencyValue > 0, "MISSING_CURRENCY");

    uint reserve = _currencyValue.mul(__revenueCommitmentBasisPoints);
    reserve /= BASIS_POINTS_DEN;

    _transferCurrency(beneficiary, _currencyValue - reserve);

    emit Pay(msg.sender, _currencyValue);
  }

  function() external payable {
    require(address(currency) == address(0), "ONLY_FOR_CURRENCY_ETH");
  }

  function updateConfig(
    address _whitelistAddress,
    address payable _beneficiary,
    address _control,
    address payable _feeCollector,
    uint _feeBasisPoints,
    uint _revenueCommitmentBasisPoints,
    uint _minInvestment,
    uint _minDuration
  ) public {

    _updateConfig(
      _whitelistAddress,
      _beneficiary,
      _control,
      _feeCollector,
      _feeBasisPoints,
      _minInvestment,
      _minDuration
    );

    require(
      _revenueCommitmentBasisPoints <= BASIS_POINTS_DEN,
      "INVALID_COMMITMENT"
    );
    require(
      _revenueCommitmentBasisPoints >= __revenueCommitmentBasisPoints,
      "COMMITMENT_MAY_NOT_BE_REDUCED"
    );
    __revenueCommitmentBasisPoints = _revenueCommitmentBasisPoints;

    emit UpdateConfig(
      _whitelistAddress,
      _beneficiary,
      _control,
      _feeCollector,
      _revenueCommitmentBasisPoints,
      _feeBasisPoints,
      _minInvestment,
      _minDuration
    );
  }

  function initializeRunStartedOn(
    uint _runStartedOn
  ) external
  {

    require(msg.sender == control, "CONTROL_ONLY");
    require(state == STATE_RUN, "ONLY_CALL_IN_RUN");
    require(__startedOn == 0, "ONLY_CALL_IF_NOT_AUTO_SET");
    require(_runStartedOn <= block.timestamp, "DATE_MUST_BE_IN_PAST");

    __startedOn = _runStartedOn;
  }

  function _distributeInvestment(
    uint _value
  ) internal
  {


    uint reserve = __investmentReserveBasisPoints.mul(_value);
    reserve /= BASIS_POINTS_DEN;
    reserve = _value.sub(reserve);
    uint fee = reserve.mul(feeBasisPoints);
    fee /= BASIS_POINTS_DEN;

    _transferCurrency(beneficiary, reserve - fee);
    _transferCurrency(feeCollector, fee);
  }
}