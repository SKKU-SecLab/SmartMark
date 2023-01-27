

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


pragma solidity ^0.5.0;

contract Context {

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




contract ERC20 is Context, IERC20 {

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
}


pragma solidity ^0.5.0;


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


pragma solidity ^0.5.0;

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


pragma solidity ^0.5.0;

contract Ownable is Context {

    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor () internal {
        _owner = _msgSender();
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

        return _msgSender() == _owner;
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


pragma solidity ^0.5.0;

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


pragma solidity ^0.5.0;



contract PauserRole is Context {

    using Roles for Roles.Role;

    event PauserAdded(address indexed account);
    event PauserRemoved(address indexed account);

    Roles.Role private _pausers;

    constructor () internal {
        _addPauser(_msgSender());
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
}


pragma solidity ^0.5.0;



contract Pausable is Context, PauserRole {

    event Paused(address account);

    event Unpaused(address account);

    bool private _paused;

    constructor () internal {
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


pragma solidity 0.5.16;

interface iERC20Fulcrum {

  function mint(
    address receiver,
    uint256 depositAmount)
    external
    returns (uint256 mintAmount);


  function burn(
    address receiver,
    uint256 burnAmount)
    external
    returns (uint256 loanAmountPaid);


  function tokenPrice()
    external
    view
    returns (uint256 price);


  function supplyInterestRate()
    external
    view
    returns (uint256);


  function rateMultiplier()
    external
    view
    returns (uint256);

  function baseRate()
    external
    view
    returns (uint256);


  function borrowInterestRate()
    external
    view
    returns (uint256);


  function avgBorrowInterestRate()
    external
    view
    returns (uint256);


  function protocolInterestRate()
    external
    view
    returns (uint256);


  function spreadMultiplier()
    external
    view
    returns (uint256);


  function totalAssetBorrow()
    external
    view
    returns (uint256);


  function totalAssetSupply()
    external
    view
    returns (uint256);


  function nextSupplyInterestRate(uint256)
    external
    view
    returns (uint256);


  function nextBorrowInterestRate(uint256)
    external
    view
    returns (uint256);

  function nextLoanInterestRate(uint256)
    external
    view
    returns (uint256);

  function totalSupplyInterestRate(uint256)
    external
    view
    returns (uint256);


  function claimLoanToken()
    external
    returns (uint256 claimedAmount);


  function dsr()
    external
    view
    returns (uint256);


  function chaiPrice()
    external
    view
    returns (uint256);

}


pragma solidity 0.5.16;

interface ILendingProtocol {

  function mint() external returns (uint256);

  function redeem(address account) external returns (uint256);

  function nextSupplyRate(uint256 amount) external view returns (uint256);

  function nextSupplyRateWithParams(uint256[] calldata params) external view returns (uint256);

  function getAPR() external view returns (uint256);

  function getPriceInToken() external view returns (uint256);

  function token() external view returns (address);

  function underlying() external view returns (address);

  function availableLiquidity() external view returns (uint256);

}


pragma solidity 0.5.16;

interface IIdleTokenV3 {

  function tokenPrice() external view returns (uint256 price);

  function token() external view returns (address);


  function tokenDecimals() external view returns (uint256 decimals);


  function getAPRs() external view returns (address[] memory addresses, uint256[] memory aprs);



  function mintIdleToken(uint256 _amount, uint256[] calldata) external returns (uint256 mintedTokens);


  function redeemIdleToken(uint256 _amount, bool _skipRebalance, uint256[] calldata)
    external returns (uint256 redeemedTokens);


  function redeemInterestBearingTokens(uint256 _amount) external;


  function rebalance(uint256 _newAmount, uint256[] calldata) external returns (bool);


  function rebalance() external returns (bool);

}


pragma solidity 0.5.16;

interface IIdleRebalancerV3 {

  function getAllocations() external view returns (uint256[] memory _allocations);

}


pragma solidity 0.5.16;




contract IdleRebalancerV3 is IIdleRebalancerV3, Ownable {

  using SafeMath for uint256;
  uint256[] public lastAmounts;
  address[] public lastAmountsAddresses;
  address public rebalancerManager;
  address public idleToken;

  constructor(address _cToken, address _iToken, address _aToken, address _yxToken, address _rebalancerManager) public {
    require(_cToken != address(0) && _iToken != address(0) && _aToken != address(0) && _yxToken != address(0) && _rebalancerManager != address(0), 'some addr is 0');
    rebalancerManager = _rebalancerManager;

    lastAmounts = [100000, 0, 0, 0];
    lastAmountsAddresses = [_cToken, _iToken, _aToken, _yxToken];
  }

  modifier onlyRebalancerAndIdle() {

    require(msg.sender == rebalancerManager || msg.sender == idleToken, "Only rebalacer and IdleToken");
    _;
  }

  function setRebalancerManager(address _rebalancerManager)
    external onlyOwner {

      require(_rebalancerManager != address(0), "_rebalancerManager addr is 0");

      rebalancerManager = _rebalancerManager;
  }

  function setIdleToken(address _idleToken)
    external onlyOwner {

      require(idleToken == address(0), "idleToken addr already set");
      require(_idleToken != address(0), "_idleToken addr is 0");
      idleToken = _idleToken;
  }

  function setNewToken(address _newToken)
    external onlyOwner {

      require(_newToken != address(0), "New token should be != 0");
      for (uint256 i = 0; i < lastAmountsAddresses.length; i++) {
        if (lastAmountsAddresses[i] == _newToken) {
          return;
        }
      }

      lastAmountsAddresses.push(_newToken);
      lastAmounts.push(0);
  }

  function setAllocations(uint256[] calldata _allocations, address[] calldata _addresses)
    external onlyRebalancerAndIdle
  {

    require(_allocations.length == lastAmounts.length, "Alloc lengths are different, allocations");
    require(_allocations.length == _addresses.length, "Alloc lengths are different, addresses");

    uint256 total;
    for (uint256 i = 0; i < _allocations.length; i++) {
      require(_addresses[i] == lastAmountsAddresses[i], "Addresses do not match");
      total = total.add(_allocations[i]);
      lastAmounts[i] = _allocations[i];
    }
    require(total == 100000, "Not allocating 100%");
  }

  function getAllocations()
    external view returns (uint256[] memory _allocations) {

    return lastAmounts;
  }

  function getAllocationsLength()
    external view returns (uint256) {

    return lastAmounts.length;
  }
}


pragma solidity 0.5.16;

interface IIdleToken {

  function tokenPrice() external view returns (uint256 price);


  function tokenDecimals() external view returns (uint256 decimals);


  function getAPRs() external view returns (address[] memory addresses, uint256[] memory aprs);



  function mintIdleToken(uint256 _amount, uint256[] calldata _clientProtocolAmounts) external returns (uint256 mintedTokens);


  function getParamsForMintIdleToken(uint256 _amount) external returns (address[] memory, uint256[] memory);


  function redeemIdleToken(uint256 _amount, bool _skipRebalance, uint256[] calldata _clientProtocolAmounts)
    external returns (uint256 redeemedTokens);


  function getParamsForRedeemIdleToken(uint256 _amount, bool _skipRebalance)
    external returns (address[] memory, uint256[] memory);


  function redeemInterestBearingTokens(uint256 _amount) external;


  function claimITokens(uint256[] calldata _clientProtocolAmounts) external returns (uint256 claimedTokens);


  function rebalance(uint256 _newAmount, uint256[] calldata _clientProtocolAmounts) external returns (bool);


  function getParamsForRebalance(uint256 _newAmount) external returns (address[] memory, uint256[] memory);

}


pragma solidity 0.5.16;






contract IdlePriceCalculator {

  using SafeMath for uint256;
  function tokenPrice(
    uint256 totalSupply,
    address idleToken,
    address[] calldata currentTokensUsed,
    address[] calldata protocolWrappersAddresses
  )
    external view
    returns (uint256 price) {

      require(currentTokensUsed.length == protocolWrappersAddresses.length, "Different Length");

      if (totalSupply == 0) {
        return 10**(IIdleToken(idleToken).tokenDecimals());
      }

      uint256 currPrice;
      uint256 currNav;
      uint256 totNav;

      for (uint256 i = 0; i < currentTokensUsed.length; i++) {
        currPrice = ILendingProtocol(protocolWrappersAddresses[i]).getPriceInToken();
        currNav = currPrice.mul(IERC20(currentTokensUsed[i]).balanceOf(idleToken));
        totNav = totNav.add(currNav);
      }

      price = totNav.div(totalSupply); // idleToken price in token wei
  }
}


pragma solidity 0.5.16;

interface GasToken {

  function freeUpTo(uint256 value) external returns (uint256 freed);

  function freeFromUpTo(address from, uint256 value) external returns (uint256 freed);

  function balanceOf(address from) external returns (uint256 balance);

}


pragma solidity 0.5.16;


contract GST2Consumer {

  GasToken public constant gst2 = GasToken(0x0000000000b3F879cb30FE243b4Dfee438691c04);
  uint256[] internal gasAmounts = [14154, 41130, 27710, 7020];

  modifier gasDiscountFrom(address from) {

    uint256 initialGasLeft = gasleft();
    _;
    _makeGasDiscount(initialGasLeft - gasleft(), from);
  }

  function _makeGasDiscount(uint256 gasSpent, address from) internal {

    uint256 tokens = (gasSpent + gasAmounts[0]) / gasAmounts[1];
    uint256 safeNumTokens;
    uint256 gas = gasleft();

    if (gas >= gasAmounts[2]) {
      safeNumTokens = (gas - gasAmounts[2]) / gasAmounts[3];
    }

    if (tokens > safeNumTokens) {
      tokens = safeNumTokens;
    }

    if (tokens > 0) {
      if (from == address(this)) {
        gst2.freeUpTo(tokens);
      } else {
        gst2.freeFromUpTo(from, tokens);
      }
    }
  }
}


pragma solidity 0.5.16;















contract IdleTokenV3SUSD is ERC20, ERC20Detailed, ReentrancyGuard, Ownable, Pausable, IIdleTokenV3, GST2Consumer {

  using SafeERC20 for IERC20;
  using SafeMath for uint256;

  mapping(address => address) public protocolWrappers;
  address public token;
  address public iToken; // used for claimITokens and userClaimITokens
  address public rebalancer;
  address public priceCalculator;
  address public feeAddress;
  uint256 public lastITokenPrice;
  uint256 public tokenDecimals;
  uint256 constant MAX_FEE = 10000; // 100000 == 100% -> 10000 == 10%
  uint256 constant NEW_PROTOCOL_DELAY = 60 * 60 * 24 * 3; // 3 days in seconds
  uint256 public fee;
  bool public manualPlay;
  bool public isRiskAdjusted;
  bool public isNewProtocolDelayed;
  address[] public allAvailableTokens;
  uint256[] public lastAllocations;
  mapping(address => uint256) public userAvgPrices;
  mapping(address => uint256) private userNoFeeQty;
  mapping(address => uint256) public releaseTimes;

  constructor(
    string memory _name, // eg. IdleDAI
    string memory _symbol, // eg. IDLEDAI
    uint8 _decimals, // eg. 18
    address _token,
    address _aToken,
    address _rebalancer,
    address _priceCalculator,
    address _idleAave)
    public
    ERC20Detailed(_name, _symbol, _decimals) {
      token = _token;
      tokenDecimals = ERC20Detailed(_token).decimals();
      rebalancer = _rebalancer;
      priceCalculator = _priceCalculator;
      protocolWrappers[_aToken] = _idleAave;
      allAvailableTokens = [_aToken];
  }

  modifier whenITokenPriceHasNotDecreased() {

    if (iToken != address(0)) {
      uint256 iTokenPrice = iERC20Fulcrum(iToken).tokenPrice();
      require(
        iTokenPrice >= lastITokenPrice || manualPlay,
        "Paused: iToken price decreased"
      );

      _;

      if (iTokenPrice > lastITokenPrice) {
        lastITokenPrice = iTokenPrice;
      }
    } else {
      _;
    }
  }

  function setRebalancer(address _rebalancer)
    external onlyOwner {

      require(_rebalancer != address(0), 'Addr is 0');
      rebalancer = _rebalancer;
  }
  function setPriceCalculator(address _priceCalculator)
    external onlyOwner {

      require(_priceCalculator != address(0), 'Addr is 0');
      if (!isNewProtocolDelayed || (releaseTimes[_priceCalculator] != 0 && now - releaseTimes[_priceCalculator] > NEW_PROTOCOL_DELAY)) {
        priceCalculator = _priceCalculator;
        releaseTimes[_priceCalculator] = 0;
        return;
      }
      releaseTimes[_priceCalculator] = now;
  }

  function setProtocolWrapper(address _token, address _wrapper)
    external onlyOwner {

      require(_token != address(0) && _wrapper != address(0), 'some addr is 0');

      if (!isNewProtocolDelayed || (releaseTimes[_wrapper] != 0 && now - releaseTimes[_wrapper] > NEW_PROTOCOL_DELAY)) {
        if (protocolWrappers[_token] == address(0)) {
          allAvailableTokens.push(_token);
        }
        protocolWrappers[_token] = _wrapper;
        releaseTimes[_wrapper] = 0;
        return;
      }

      releaseTimes[_wrapper] = now;
  }

  function setManualPlay(bool _manualPlay)
    external onlyOwner {

      manualPlay = _manualPlay;
  }

  function setIsRiskAdjusted(bool _isRiskAdjusted)
    external onlyOwner {

      isRiskAdjusted = _isRiskAdjusted;
  }

  function delayNewProtocols()
    external onlyOwner {

      isNewProtocolDelayed = true;
  }

  function setFee(uint256 _fee)
    external onlyOwner {

      require(_fee <= MAX_FEE, "Fee too high");
      fee = _fee;
  }

  function setFeeAddress(address _feeAddress)
    external onlyOwner {

      require(_feeAddress != address(0), 'Addr is 0');
      feeAddress = _feeAddress;
  }

  function setGasParams(uint256[] calldata _amounts)
    external onlyOwner {

      gasAmounts = _amounts;
  }
  function tokenPrice()
    public view
    returns (uint256 price) {

      address[] memory protocolWrappersAddresses = new address[](allAvailableTokens.length);
      for (uint256 i = 0; i < allAvailableTokens.length; i++) {
        protocolWrappersAddresses[i] = protocolWrappers[allAvailableTokens[i]];
      }
      price = IdlePriceCalculator(priceCalculator).tokenPrice(
        totalSupply(), address(this), allAvailableTokens, protocolWrappersAddresses
      );
  }

  function getAPRs()
    external view
    returns (address[] memory addresses, uint256[] memory aprs) {

      address currToken;
      addresses = new address[](allAvailableTokens.length);
      aprs = new uint256[](allAvailableTokens.length);
      for (uint256 i = 0; i < allAvailableTokens.length; i++) {
        currToken = allAvailableTokens[i];
        addresses[i] = currToken;
        aprs[i] = ILendingProtocol(protocolWrappers[currToken]).getAPR();
      }
  }

  function getAvgAPR()
    public view
    returns (uint256 avgApr) {

      (, uint256[] memory amounts, uint256 total) = _getCurrentAllocations();
      uint256 currApr;
      uint256 weight;
      for (uint256 i = 0; i < allAvailableTokens.length; i++) {
        if (amounts[i] == 0) {
          continue;
        }
        currApr = ILendingProtocol(protocolWrappers[allAvailableTokens[i]]).getAPR();
        weight = amounts[i].mul(10**18).div(total);
        avgApr = avgApr.add(currApr.mul(weight).div(10**18));
      }
  }

  function transferFrom(address sender, address recipient, uint256 amount) public returns (bool) {

    _transfer(sender, recipient, amount);
    _approve(sender, msg.sender, allowance(sender, msg.sender).sub(amount, "ERC20: transfer amount exceeds allowance"));
    _updateAvgPrice(recipient, amount, userAvgPrices[sender]);
    return true;
  }
  function transfer(address recipient, uint256 amount) public returns (bool) {

    _transfer(msg.sender, recipient, amount);
    _updateAvgPrice(recipient, amount, userAvgPrices[msg.sender]);
    return true;
  }

  function mintIdleToken(uint256 _amount, bool _skipWholeRebalance)
    external nonReentrant gasDiscountFrom(address(this))
    returns (uint256 mintedTokens) {

    return _mintIdleToken(_amount, new uint256[](0), _skipWholeRebalance);
  }

  function mintIdleToken(uint256 _amount, uint256[] calldata)
    external nonReentrant gasDiscountFrom(address(this))
    returns (uint256 mintedTokens) {

    return _mintIdleToken(_amount, new uint256[](0), false);
  }

  function redeemIdleToken(uint256 _amount, bool _skipRebalance, uint256[] calldata)
    external nonReentrant
    returns (uint256 redeemedTokens) {

      uint256 balance;
      for (uint256 i = 0; i < allAvailableTokens.length; i++) {
        balance = IERC20(allAvailableTokens[i]).balanceOf(address(this));
        if (balance == 0) {
          continue;
        }
        redeemedTokens = redeemedTokens.add(
          _redeemProtocolTokens(
            protocolWrappers[allAvailableTokens[i]],
            allAvailableTokens[i],
            _amount.mul(balance).div(totalSupply()), // amount to redeem
            address(this)
          )
        );
      }

      _burn(msg.sender, _amount);
      if (fee > 0 && feeAddress != address(0)) {
        redeemedTokens = _getFee(_amount, redeemedTokens);
      }
      IERC20(token).safeTransfer(msg.sender, redeemedTokens);

      if (this.paused() || iERC20Fulcrum(iToken).tokenPrice() < lastITokenPrice || _skipRebalance) {
        return redeemedTokens;
      }

      _rebalance(0, false);
  }

  function redeemInterestBearingTokens(uint256 _amount)
    external nonReentrant {

      uint256 idleSupply = totalSupply();
      address currentToken;
      uint256 balance;

      for (uint256 i = 0; i < allAvailableTokens.length; i++) {
        currentToken = allAvailableTokens[i];
        balance = IERC20(currentToken).balanceOf(address(this));
        if (balance == 0) {
          continue;
        }
        IERC20(currentToken).safeTransfer(
          msg.sender,
          _amount.mul(balance).div(idleSupply) // amount to redeem
        );
      }

      _burn(msg.sender, _amount);
  }

  function openRebalance(uint256[] calldata _newAllocations)
    external whenNotPaused whenITokenPriceHasNotDecreased
    returns (bool, uint256 avgApr) {

      require(!isRiskAdjusted, "Setting allocations not allowed");
      uint256 initialAPR = getAvgAPR();
      IdleRebalancerV3(rebalancer).setAllocations(_newAllocations, allAvailableTokens);
      bool hasRebalanced = _rebalance(0, false);
      uint256 newAprAfterRebalance = getAvgAPR();
      require(newAprAfterRebalance > initialAPR, "APR not improved");
      return (hasRebalanced, newAprAfterRebalance);
  }

  function rebalanceWithGST()
    external gasDiscountFrom(msg.sender)
    returns (bool) {

      return _rebalance(0, false);
  }

  function rebalance(uint256, uint256[] calldata)
    external returns (bool) {

    return _rebalance(0, false);
  }

  function rebalance() external returns (bool) {

    return _rebalance(0, false);
  }

  function getCurrentAllocations() external view
    returns (address[] memory tokenAddresses, uint256[] memory amounts, uint256 total) {

    return _getCurrentAllocations();
  }

  function _mintIdleToken(uint256 _amount, uint256[] memory, bool _skipWholeRebalance)
    internal whenNotPaused whenITokenPriceHasNotDecreased
    returns (uint256 mintedTokens) {

      uint256 idlePrice = tokenPrice();
      IERC20(token).safeTransferFrom(msg.sender, address(this), _amount);

      _rebalance(0, _skipWholeRebalance);

      mintedTokens = _amount.mul(10**18).div(idlePrice);
      _mint(msg.sender, mintedTokens);

      _updateAvgPrice(msg.sender, mintedTokens, idlePrice);
  }

  function _rebalance(uint256, bool _skipWholeRebalance)
    internal whenNotPaused whenITokenPriceHasNotDecreased
    returns (bool) {

      uint256[] memory rebalancerLastAllocations = IdleRebalancerV3(rebalancer).getAllocations();
      bool areAllocationsEqual = rebalancerLastAllocations.length == lastAllocations.length;
      if (areAllocationsEqual) {
        for (uint256 i = 0; i < lastAllocations.length || !areAllocationsEqual; i++) {
          if (lastAllocations[i] != rebalancerLastAllocations[i]) {
            areAllocationsEqual = false;
            break;
          }
        }
      }
      uint256 balance = IERC20(token).balanceOf(address(this));
      if (areAllocationsEqual && balance == 0) {
        return false;
      }

      if (balance > 0) {
        if (lastAllocations.length == 0 && _skipWholeRebalance) {
          lastAllocations = rebalancerLastAllocations;
        }
        _mintWithAmounts(allAvailableTokens, _amountsFromAllocations(rebalancerLastAllocations, balance));
      }

      if (_skipWholeRebalance || areAllocationsEqual) {
        return false;
      }

      (address[] memory tokenAddresses, uint256[] memory amounts, uint256 totalInUnderlying) = _getCurrentAllocations();
      uint256[] memory newAmounts = _amountsFromAllocations(rebalancerLastAllocations, totalInUnderlying);
      (uint256[] memory toMintAllocations, uint256 totalToMint, bool lowLiquidity) = _redeemAllNeeded(tokenAddresses, amounts, newAmounts);

      if (!lowLiquidity) {
        delete lastAllocations;
        lastAllocations = rebalancerLastAllocations;
      }
      uint256 totalRedeemd = IERC20(token).balanceOf(address(this));
      if (totalRedeemd > 1 && totalToMint > 1) {
        uint256[] memory tempAllocations = new uint256[](toMintAllocations.length);
        for (uint256 i = 0; i < toMintAllocations.length; i++) {
          tempAllocations[i] = toMintAllocations[i].mul(100000).div(totalToMint);
        }

        uint256[] memory partialAmounts = _amountsFromAllocations(tempAllocations, totalRedeemd);
        _mintWithAmounts(allAvailableTokens, partialAmounts);
      }

      return true; // hasRebalanced
  }

  function _updateAvgPrice(address usr, uint256 qty, uint256 price) internal {

    if (fee == 0) {
      userNoFeeQty[usr] = userNoFeeQty[usr].add(qty);
      return;
    }

    uint256 totBalance = balanceOf(usr).sub(userNoFeeQty[usr]);
    uint256 oldAvgPrice = userAvgPrices[usr];
    uint256 oldBalance = totBalance.sub(qty);
    userAvgPrices[usr] = oldAvgPrice.mul(oldBalance).div(totBalance).add(price.mul(qty).div(totBalance));
  }

  function _getFee(uint256 amount, uint256 redeemed) internal returns (uint256) {

    uint256 noFeeQty = userNoFeeQty[msg.sender];
    uint256 currPrice = tokenPrice();
    if (noFeeQty > 0 && noFeeQty > amount) {
      noFeeQty = amount;
    }

    uint256 totalValPaid = noFeeQty.mul(currPrice).add(amount.sub(noFeeQty).mul(userAvgPrices[msg.sender])).div(10**18);
    uint256 currVal = amount.mul(currPrice).div(10**18);
    if (currVal < totalValPaid) {
      return redeemed;
    }
    uint256 gain = currVal.sub(totalValPaid);
    uint256 feeDue = gain.mul(fee).div(100000);
    IERC20(token).safeTransfer(feeAddress, feeDue);
    userNoFeeQty[msg.sender] = userNoFeeQty[msg.sender].sub(noFeeQty);
    return currVal.sub(feeDue);
  }

  function _mintWithAmounts(address[] memory tokenAddresses, uint256[] memory protocolAmounts) internal {

    require(tokenAddresses.length == protocolAmounts.length, "All tokens length != allocations length");

    uint256 currAmount;

    for (uint256 i = 0; i < protocolAmounts.length; i++) {
      currAmount = protocolAmounts[i];
      if (currAmount == 0) {
        continue;
      }
      _mintProtocolTokens(protocolWrappers[tokenAddresses[i]], currAmount);
    }
  }

  function _amountsFromAllocations(uint256[] memory allocations, uint256 total)
    internal pure returns (uint256[] memory) {

    uint256[] memory newAmounts = new uint256[](allocations.length);
    uint256 currBalance = 0;
    uint256 allocatedBalance = 0;

    for (uint256 i = 0; i < allocations.length; i++) {
      if (i == allocations.length - 1) {
        newAmounts[i] = total.sub(allocatedBalance);
      } else {
        currBalance = total.mul(allocations[i]).div(100000);
        allocatedBalance = allocatedBalance.add(currBalance);
        newAmounts[i] = currBalance;
      }
    }
    return newAmounts;
  }

  function _redeemAllNeeded(
    address[] memory tokenAddresses,
    uint256[] memory amounts,
    uint256[] memory newAmounts
    ) internal returns (
      uint256[] memory toMintAllocations,
      uint256 totalToMint,
      bool lowLiquidity
    ) {

    require(amounts.length == newAmounts.length, 'Lengths not equal');
    toMintAllocations = new uint256[](amounts.length);
    ILendingProtocol protocol;
    uint256 currAmount;
    uint256 newAmount;
    address currToken;
    for (uint256 i = 0; i < amounts.length; i++) {
      currToken = tokenAddresses[i];
      newAmount = newAmounts[i];
      currAmount = amounts[i];
      protocol = ILendingProtocol(protocolWrappers[currToken]);
      if (currAmount > newAmount) {
        toMintAllocations[i] = 0;
        uint256 toRedeem = currAmount.sub(newAmount);
        uint256 availableLiquidity = protocol.availableLiquidity();
        if (availableLiquidity < toRedeem) {
          lowLiquidity = true;
          toRedeem = availableLiquidity;
        }
        _redeemProtocolTokens(
          protocolWrappers[currToken],
          currToken,
          toRedeem.mul(10**18).div(protocol.getPriceInToken()),
          address(this) // tokens are now in this contract
        );
      } else {
        toMintAllocations[i] = newAmount.sub(currAmount);
        totalToMint = totalToMint.add(toMintAllocations[i]);
      }
    }
  }

  function _getCurrentAllocations() internal view
    returns (address[] memory tokenAddresses, uint256[] memory amounts, uint256 total) {

      tokenAddresses = new address[](allAvailableTokens.length);
      amounts = new uint256[](allAvailableTokens.length);

      address currentToken;
      uint256 currTokenPrice;

      for (uint256 i = 0; i < allAvailableTokens.length; i++) {
        currentToken = allAvailableTokens[i];
        tokenAddresses[i] = currentToken;
        currTokenPrice = ILendingProtocol(protocolWrappers[currentToken]).getPriceInToken();
        amounts[i] = currTokenPrice.mul(
          IERC20(currentToken).balanceOf(address(this))
        ).div(10**18);
        total = total.add(amounts[i]);
      }

      return (tokenAddresses, amounts, total);
  }

  function _mintProtocolTokens(address _wrapperAddr, uint256 _amount)
    internal
    returns (uint256 tokens) {

      if (_amount == 0) {
        return tokens;
      }
      IERC20(token).safeTransfer(_wrapperAddr, _amount);
      tokens = ILendingProtocol(_wrapperAddr).mint();
  }

  function _redeemProtocolTokens(address _wrapperAddr, address _token, uint256 _amount, address _account)
    internal
    returns (uint256 tokens) {

      if (_amount == 0) {
        return tokens;
      }
      IERC20(_token).safeTransfer(_wrapperAddr, _amount);
      tokens = ILendingProtocol(_wrapperAddr).redeem(_account);
  }
}