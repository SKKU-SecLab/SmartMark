

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


pragma solidity 0.5.11;

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


pragma solidity 0.5.11;

interface ILendingProtocol {

  function mint() external returns (uint256);

  function redeem(address account) external returns (uint256);

  function nextSupplyRate(uint256 amount) external view returns (uint256);

  function nextSupplyRateWithParams(uint256[] calldata params) external view returns (uint256);

  function getAPR() external view returns (uint256);

  function getPriceInToken() external view returns (uint256);

  function token() external view returns (address);

  function underlying() external view returns (address);

}


pragma solidity 0.5.11;

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


pragma solidity 0.5.11;

interface CERC20 {

  function mint(uint256 mintAmount) external returns (uint256);

  function redeem(uint256 redeemTokens) external returns (uint256);

  function exchangeRateStored() external view returns (uint256);

  function supplyRatePerBlock() external view returns (uint256);


  function borrowRatePerBlock() external view returns (uint256);

  function totalReserves() external view returns (uint256);

  function getCash() external view returns (uint256);

  function totalBorrows() external view returns (uint256);

  function reserveFactorMantissa() external view returns (uint256);

  function interestRateModel() external view returns (address);

}


pragma solidity 0.5.11;

interface WhitePaperInterestRateModel {

  function getBorrowRate(uint256 cash, uint256 borrows, uint256 _reserves) external view returns (uint256, uint256);

  function getSupplyRate(uint256 cash, uint256 borrows, uint256 reserves, uint256 reserveFactorMantissa) external view returns (uint256);

  function multiplier() external view returns (uint256);

  function baseRate() external view returns (uint256);

  function blocksPerYear() external view returns (uint256);

  function dsrPerBlock() external view returns (uint256);

}


pragma solidity 0.5.11;








contract IdleRebalancer is Ownable {

  using SafeMath for uint256;
  address public idleToken;
  address public cToken;
  address public iToken;
  address public cWrapper;
  address public iWrapper;
  uint256 public maxRateDifference; // 10**17 -> 0.1 %
  uint256 public maxSupplyedParamsDifference; // 100000 -> 0.001%
  uint256 public maxIterations;

  constructor(address _cToken, address _iToken, address _cWrapper, address _iWrapper) public {
    require(_cToken != address(0) && _iToken != address(0) && _cWrapper != address(0) && _iWrapper != address(0), 'some addr is 0');

    cToken = _cToken;
    iToken = _iToken;
    cWrapper = _cWrapper;
    iWrapper = _iWrapper;
    maxRateDifference = 10**17; // 0.1%
    maxSupplyedParamsDifference = 100000; // 0.001%
    maxIterations = 30;
  }

  modifier onlyIdle() {

    require(msg.sender == idleToken, "Ownable: caller is not IdleToken contract");
    _;
  }

  function setIdleToken(address _idleToken)
    external onlyOwner {

      require(idleToken == address(0), "idleToken addr already set");
      require(_idleToken != address(0), "_idleToken addr is 0");
      idleToken = _idleToken;
  }

  function setMaxIterations(uint256 _maxIterations)
    external onlyOwner {

      maxIterations = _maxIterations;
  }

  function setMaxRateDifference(uint256 _maxDifference)
    external onlyOwner {

      maxRateDifference = _maxDifference;
  }

  function setMaxSupplyedParamsDifference(uint256 _maxSupplyedParamsDifference)
    external onlyOwner {

      maxSupplyedParamsDifference = _maxSupplyedParamsDifference;
  }

  function calcRebalanceAmounts(uint256[] calldata _rebalanceParams)
    external view onlyIdle
    returns (address[] memory tokenAddresses, uint256[] memory amounts)
  {

    CERC20 _cToken = CERC20(cToken);
    WhitePaperInterestRateModel white = WhitePaperInterestRateModel(_cToken.interestRateModel());
    uint256[] memory paramsCompound = new uint256[](10);
    paramsCompound[0] = 10**18; // j
    paramsCompound[1] = white.baseRate(); // a
    paramsCompound[2] = _cToken.totalBorrows(); // b
    paramsCompound[3] = white.multiplier(); // c
    paramsCompound[4] = _cToken.totalReserves(); // d
    paramsCompound[5] = paramsCompound[0].sub(_cToken.reserveFactorMantissa()); // e
    paramsCompound[6] = _cToken.getCash(); // s
    paramsCompound[7] = white.blocksPerYear(); // k
    paramsCompound[8] = 100; // f

    iERC20Fulcrum _iToken = iERC20Fulcrum(iToken);
    uint256[] memory paramsFulcrum = new uint256[](4);
    paramsFulcrum[0] = _iToken.protocolInterestRate(); // a1
    paramsFulcrum[1] = _iToken.totalAssetBorrow(); // b1
    paramsFulcrum[2] = _iToken.totalAssetSupply(); // s1

    tokenAddresses = new address[](2);
    tokenAddresses[0] = cToken;
    tokenAddresses[1] = iToken;

    if (_rebalanceParams.length == 3) {
      (bool amountsAreCorrect, uint256[] memory checkedAmounts) = checkRebalanceAmounts(_rebalanceParams, paramsCompound, paramsFulcrum);
      if (amountsAreCorrect) {
        return (tokenAddresses, checkedAmounts);
      }
    }


    uint256 amountFulcrum = _rebalanceParams[0].mul(paramsFulcrum[2].add(paramsFulcrum[1])).div(
      paramsFulcrum[2].add(paramsFulcrum[1]).add(paramsCompound[6].add(paramsCompound[2]).add(paramsCompound[2]))
    );

    amounts = bisectionRec(
      _rebalanceParams[0].sub(amountFulcrum), // amountCompound
      amountFulcrum,
      maxRateDifference, // 0.1% of rate difference,
      0, // currIter
      maxIterations, // maxIter
      _rebalanceParams[0],
      paramsCompound,
      paramsFulcrum
    ); // returns [amountCompound, amountFulcrum]

    return (tokenAddresses, amounts);
  }
  function checkRebalanceAmounts(
    uint256[] memory rebalanceParams,
    uint256[] memory paramsCompound,
    uint256[] memory paramsFulcrum
  )
    internal view
    returns (bool, uint256[] memory checkedAmounts)
  {

    uint256 actualAmountToBeRebalanced = rebalanceParams[0]; // n
    uint256 totAmountSentByUser;
    for (uint8 i = 1; i < rebalanceParams.length; i++) {
      totAmountSentByUser = totAmountSentByUser.add(rebalanceParams[i]);
    }

    if (totAmountSentByUser > actualAmountToBeRebalanced ||
        totAmountSentByUser.add(totAmountSentByUser.div(maxSupplyedParamsDifference)) < actualAmountToBeRebalanced) {
      return (false, new uint256[](2));
    }

    uint256 interestToBeSplitted = actualAmountToBeRebalanced.sub(totAmountSentByUser);

    paramsCompound[9] = rebalanceParams[1].add(interestToBeSplitted.div(2));
    paramsFulcrum[3] = rebalanceParams[2].add(interestToBeSplitted.sub(interestToBeSplitted.div(2)));


    uint256 currFulcRate = (paramsFulcrum[1].mul(10**20).div(paramsFulcrum[2])) > 90 ether ?
      ILendingProtocol(iWrapper).nextSupplyRate(paramsFulcrum[3]) :
      ILendingProtocol(iWrapper).nextSupplyRateWithParams(paramsFulcrum);
    uint256 currCompRate = ILendingProtocol(cWrapper).nextSupplyRateWithParams(paramsCompound);
    bool isCompoundBest = currCompRate > currFulcRate;
    bool areParamsOk = (currFulcRate.add(maxRateDifference) >= currCompRate && isCompoundBest) ||
      (currCompRate.add(maxRateDifference) >= currFulcRate && !isCompoundBest);

    uint256[] memory actualParams = new uint256[](2);
    actualParams[0] = paramsCompound[9];
    actualParams[1] = paramsFulcrum[3];

    return (areParamsOk, actualParams);
  }

  function bisectionRec(
    uint256 amountCompound, uint256 amountFulcrum,
    uint256 tolerance, uint256 currIter, uint256 maxIter, uint256 n,
    uint256[] memory paramsCompound,
    uint256[] memory paramsFulcrum
  )
    internal view
    returns (uint256[] memory amounts) {


    paramsCompound[9] = amountCompound;
    paramsFulcrum[3] = amountFulcrum;


    uint256 currFulcRate = (paramsFulcrum[1].mul(10**20).div(paramsFulcrum[2])) > 90 ether ?
      ILendingProtocol(iWrapper).nextSupplyRate(amountFulcrum) :
      ILendingProtocol(iWrapper).nextSupplyRateWithParams(paramsFulcrum);

    uint256 currCompRate = ILendingProtocol(cWrapper).nextSupplyRateWithParams(paramsCompound);
    bool isCompoundBest = currCompRate > currFulcRate;

    uint256 step = amountCompound < amountFulcrum ? amountCompound.div(2) : amountFulcrum.div(2);

    if (
      ((currFulcRate.add(tolerance) >= currCompRate && isCompoundBest) ||
      (currCompRate.add(tolerance) >= currFulcRate && !isCompoundBest)) ||
      currIter >= maxIter
    ) {
      amounts = new uint256[](2);
      amounts[0] = amountCompound;
      amounts[1] = amountFulcrum;
      return amounts;
    }

    return bisectionRec(
      isCompoundBest ? amountCompound.add(step) : amountCompound.sub(step),
      isCompoundBest ? amountFulcrum.sub(step) : amountFulcrum.add(step),
      tolerance, currIter + 1, maxIter, n,
      paramsCompound, // paramsCompound[9] would be overwritten on next iteration
      paramsFulcrum // paramsFulcrum[3] would be overwritten on next iteration
    );
  }
}


pragma solidity 0.5.11;






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

      for (uint8 i = 0; i < currentTokensUsed.length; i++) {
        currPrice = ILendingProtocol(protocolWrappersAddresses[i]).getPriceInToken();
        currNav = currPrice.mul(IERC20(currentTokensUsed[i]).balanceOf(idleToken));
        totNav = totNav.add(currNav);
      }

      price = totNav.div(totalSupply); // idleToken price in token wei
  }
}


pragma solidity 0.5.11;














contract IdleToken is ERC20, ERC20Detailed, ReentrancyGuard, Ownable, Pausable, IIdleToken {

  using SafeERC20 for IERC20;
  using SafeMath for uint256;


  mapping(address => address) public protocolWrappers;
  address public token;
  uint256 public tokenDecimals;
  address public iToken; // used for claimITokens and userClaimITokens
  uint256 public minRateDifference;
  address public rebalancer;
  address public priceCalculator;
  uint256 public lastITokenPrice;
  bool public manualPlay = false;
  bool private _notLocalEntered;

  address[] public currentTokensUsed;
  address[] public allAvailableTokens;

  struct TokenProtocol {
    address tokenAddr;
    address protocolAddr;
  }

  event Rebalance(uint256 amount);

  constructor(
    string memory _name, // eg. IdleDAI
    string memory _symbol, // eg. IDLEDAI
    uint8 _decimals, // eg. 18
    address _token,
    address _cToken,
    address _iToken,
    address _rebalancer,
    address _priceCalculator,
    address _idleCompound,
    address _idleFulcrum)
    public
    ERC20Detailed(_name, _symbol, _decimals) {
      token = _token;
      tokenDecimals = ERC20Detailed(_token).decimals();
      iToken = _iToken; // used for claimITokens and userClaimITokens methods
      rebalancer = _rebalancer;
      priceCalculator = _priceCalculator;
      protocolWrappers[_cToken] = _idleCompound;
      protocolWrappers[_iToken] = _idleFulcrum;
      allAvailableTokens = [_cToken, _iToken];
      minRateDifference = 100000000000000000; // 0.1% min
      _notLocalEntered = true;
  }

  modifier whenITokenPriceHasNotDecreased() {

    uint256 iTokenPrice = iERC20Fulcrum(iToken).tokenPrice();
    require(
      iTokenPrice >= lastITokenPrice || manualPlay,
      "Paused: iToken price decreased"
    );

    _;

    if (iTokenPrice > lastITokenPrice) {
      lastITokenPrice = iTokenPrice;
    }
  }

  modifier nonLocallyReentrant() {

    require(_notLocalEntered, "LocalReentrancyGuard: reentrant call");

    _notLocalEntered = false;

    _;

    _notLocalEntered = true;
  }

  function setIToken(address _iToken)
    external onlyOwner {

      iToken = _iToken;
  }
  function setRebalancer(address _rebalancer)
    external onlyOwner {

      rebalancer = _rebalancer;
  }
  function setPriceCalculator(address _priceCalculator)
    external onlyOwner {

      priceCalculator = _priceCalculator;
  }
  function setProtocolWrapper(address _token, address _wrapper)
    external onlyOwner {

      require(_token != address(0) && _wrapper != address(0), 'some addr is 0');
      if (protocolWrappers[_token] == address(0)) {
        allAvailableTokens.push(_token);
      }
      protocolWrappers[_token] = _wrapper;
  }

  function setMinRateDifference(uint256 _rate)
    external onlyOwner {

      minRateDifference = _rate;
  }
  function setManualPlay(bool _manualPlay)
    external onlyOwner {

      manualPlay = _manualPlay;
  }

  function tokenPrice()
    public view
    returns (uint256 price) {

      address[] memory protocolWrappersAddresses = new address[](currentTokensUsed.length);
      for (uint8 i = 0; i < currentTokensUsed.length; i++) {
        protocolWrappersAddresses[i] = protocolWrappers[currentTokensUsed[i]];
      }
      price = IdlePriceCalculator(priceCalculator).tokenPrice(
        this.totalSupply(), address(this), currentTokensUsed, protocolWrappersAddresses
      );
  }

  function getAPRs()
    public view
    returns (address[] memory addresses, uint256[] memory aprs) {

      address currToken;
      addresses = new address[](allAvailableTokens.length);
      aprs = new uint256[](allAvailableTokens.length);
      for (uint8 i = 0; i < allAvailableTokens.length; i++) {
        currToken = allAvailableTokens[i];
        addresses[i] = currToken;
        aprs[i] = ILendingProtocol(protocolWrappers[currToken]).getAPR();
      }
  }

  function mintIdleToken(uint256 _amount, uint256[] memory _clientProtocolAmounts)
    public nonReentrant whenNotPaused whenITokenPriceHasNotDecreased
    returns (uint256 mintedTokens) {

      uint256 idlePrice = tokenPrice();
      IERC20(token).safeTransferFrom(msg.sender, address(this), _amount);
      rebalance(_amount, _clientProtocolAmounts);

      mintedTokens = _amount.mul(10**18).div(idlePrice);
      _mint(msg.sender, mintedTokens);
  }

  function getParamsForMintIdleToken(uint256 _amount)
    external nonLocallyReentrant whenNotPaused whenITokenPriceHasNotDecreased
    returns (address[] memory, uint256[] memory) {

      mintIdleToken(_amount, new uint256[](0));
      return _getCurrentAllocations();
  }

  function redeemIdleToken(uint256 _amount, bool _skipRebalance, uint256[] memory _clientProtocolAmounts)
    public nonReentrant
    returns (uint256 redeemedTokens) {

      address currentToken;

      for (uint8 i = 0; i < currentTokensUsed.length; i++) {
        currentToken = currentTokensUsed[i];
        redeemedTokens = redeemedTokens.add(
          _redeemProtocolTokens(
            protocolWrappers[currentToken],
            currentToken,
            _amount.mul(IERC20(currentToken).balanceOf(address(this))).div(this.totalSupply()), // amount to redeem
            msg.sender
          )
        );
      }

      _burn(msg.sender, _amount);

      if (this.paused() || iERC20Fulcrum(iToken).tokenPrice() < lastITokenPrice || _skipRebalance) {
        return redeemedTokens;
      }

      rebalance(0, _clientProtocolAmounts);
  }

   function getParamsForRedeemIdleToken(uint256 _amount, bool _skipRebalance)
    external nonLocallyReentrant
    returns (address[] memory, uint256[] memory) {

      redeemIdleToken(_amount, _skipRebalance, new uint256[](0));
      return _getCurrentAllocations();
  }

  function redeemInterestBearingTokens(uint256 _amount)
    external nonReentrant {

      uint256 idleSupply = this.totalSupply();
      address currentToken;

      for (uint8 i = 0; i < currentTokensUsed.length; i++) {
        currentToken = currentTokensUsed[i];
        IERC20(currentToken).safeTransfer(
          msg.sender,
          _amount.mul(IERC20(currentToken).balanceOf(address(this))).div(idleSupply) // amount to redeem
        );
      }

      _burn(msg.sender, _amount);
  }

  function claimITokens(uint256[] calldata _clientProtocolAmounts)
    external whenNotPaused whenITokenPriceHasNotDecreased
    returns (uint256 claimedTokens) {

      claimedTokens = iERC20Fulcrum(iToken).claimLoanToken();
      rebalance(claimedTokens, _clientProtocolAmounts);
  }

  function rebalance(uint256 _newAmount, uint256[] memory _clientProtocolAmounts)
    public whenNotPaused whenITokenPriceHasNotDecreased
    returns (bool) {


      bool shouldRebalance;
      address bestToken;

      if (currentTokensUsed.length == 1 && _newAmount > 0) {
        (shouldRebalance, bestToken) = _rebalanceCheck(_newAmount, currentTokensUsed[0]);

        if (!shouldRebalance) {
          _mintProtocolTokens(protocolWrappers[currentTokensUsed[0]], _newAmount);
          return false; // hasNotRebalanced
        }
      }


      TokenProtocol[] memory tokenProtocols = _getCurrentProtocols();
      for (uint8 i = 0; i < tokenProtocols.length; i++) {
        _redeemProtocolTokens(
          tokenProtocols[i].protocolAddr,
          tokenProtocols[i].tokenAddr,
          IERC20(tokenProtocols[i].tokenAddr).balanceOf(address(this)),
          address(this) // tokens are now in this contract
        );
      }
      delete currentTokensUsed;

      uint256 tokenBalance = IERC20(token).balanceOf(address(this));
      if (tokenBalance == 0) {
        return false;
      }
      (shouldRebalance, bestToken) = _rebalanceCheck(tokenBalance, address(0));

      if (!shouldRebalance) {
        _mintProtocolTokens(protocolWrappers[bestToken], tokenBalance);
        currentTokensUsed.push(bestToken);
        return false; // hasNotRebalanced
      }

      (address[] memory tokenAddresses, uint256[] memory protocolAmounts) = _calcAmounts(tokenBalance, _clientProtocolAmounts);

      uint256 currAmount;
      address currAddr;
      for (uint8 i = 0; i < protocolAmounts.length; i++) {
        currAmount = protocolAmounts[i];
        if (currAmount == 0) {
          continue;
        }
        currAddr = tokenAddresses[i];
        _mintProtocolTokens(protocolWrappers[currAddr], currAmount);
        currentTokensUsed.push(currAddr);
      }

      emit Rebalance(tokenBalance);

      return true; // hasRebalanced
  }

  function getParamsForRebalance(uint256 _newAmount)
    external whenNotPaused whenITokenPriceHasNotDecreased
    returns (address[] memory, uint256[] memory) {

      rebalance(_newAmount, new uint256[](0));
      return _getCurrentAllocations();
  }


  function _rebalanceCheck(uint256 _amount, address currentToken)
    internal view
    returns (bool, address) {

      (address[] memory addresses, uint256[] memory aprs) = getAPRs();
      if (aprs.length == 0) {
        return (false, address(0));
      }

      uint256 maxRate;
      address maxAddress;
      uint256 secondBestRate;
      uint256 currApr;
      address currAddr;

      for (uint8 i = 0; i < aprs.length; i++) {
        currApr = aprs[i];
        currAddr = addresses[i];
        if (currApr > maxRate) {
          secondBestRate = maxRate;
          maxRate = currApr;
          maxAddress = currAddr;
        } else if (currApr <= maxRate && currApr >= secondBestRate) {
          secondBestRate = currApr;
        }
      }

      if (currentToken != address(0) && currentToken != maxAddress) {
        return (true, maxAddress);
      } else {
        uint256 nextRate = _getProtocolNextRate(protocolWrappers[maxAddress], _amount);
        if (nextRate.add(minRateDifference) < secondBestRate) {
          return (true, maxAddress);
        }
      }

      return (false, maxAddress);
  }

  function _calcAmounts(uint256 _amount, uint256[] memory _clientProtocolAmounts)
    internal view
    returns (address[] memory, uint256[] memory) {

      uint256[] memory paramsRebalance = new uint256[](_clientProtocolAmounts.length + 1);
      paramsRebalance[0] = _amount;

      for (uint8 i = 1; i <= _clientProtocolAmounts.length; i++) {
        paramsRebalance[i] = _clientProtocolAmounts[i-1];
      }

      return IdleRebalancer(rebalancer).calcRebalanceAmounts(paramsRebalance);
  }

  function _getCurrentProtocols()
    internal view
    returns (TokenProtocol[] memory currentProtocolsUsed) {

      currentProtocolsUsed = new TokenProtocol[](currentTokensUsed.length);
      for (uint8 i = 0; i < currentTokensUsed.length; i++) {
        currentProtocolsUsed[i] = TokenProtocol(
          currentTokensUsed[i],
          protocolWrappers[currentTokensUsed[i]]
        );
      }
  }

  function _getCurrentAllocations() internal view
    returns (address[] memory tokenAddresses, uint256[] memory amounts) {

      tokenAddresses = new address[](allAvailableTokens.length);
      amounts = new uint256[](allAvailableTokens.length);

      address currentToken;
      uint256 currTokenPrice;

      for (uint8 i = 0; i < allAvailableTokens.length; i++) {
        currentToken = allAvailableTokens[i];
        tokenAddresses[i] = currentToken;
        currTokenPrice = ILendingProtocol(protocolWrappers[currentToken]).getPriceInToken();
        amounts[i] = currTokenPrice.mul(
          IERC20(currentToken).balanceOf(address(this))
        ).div(10**18);
      }

      return (tokenAddresses, amounts);
  }

  function _getProtocolNextRate(address _wrapperAddr, uint256 _amount)
    internal view
    returns (uint256 apr) {

      ILendingProtocol _wrapper = ILendingProtocol(_wrapperAddr);
      apr = _wrapper.nextSupplyRate(_amount);
  }

  function _mintProtocolTokens(address _wrapperAddr, uint256 _amount)
    internal
    returns (uint256 tokens) {

      if (_amount == 0) {
        return tokens;
      }
      ILendingProtocol _wrapper = ILendingProtocol(_wrapperAddr);
      IERC20(token).safeTransfer(_wrapperAddr, _amount);
      tokens = _wrapper.mint();
  }

  function _redeemProtocolTokens(address _wrapperAddr, address _token, uint256 _amount, address _account)
    internal
    returns (uint256 tokens) {

      if (_amount == 0) {
        return tokens;
      }
      ILendingProtocol _wrapper = ILendingProtocol(_wrapperAddr);
      IERC20(_token).safeTransfer(_wrapperAddr, _amount);
      tokens = _wrapper.redeem(_account);
  }
}


pragma solidity 0.5.11;



contract IdleFactory is Ownable {

  mapping (address => address) public underlyingToIdleTokenMap;
  address[] public tokensSupported;

  function newIdleToken(
    string calldata _name, // eg. IdleDAI
    string calldata _symbol, // eg. IDLEDAI
    uint8 _decimals, // eg. 18
    address _token,
    address _cToken,
    address _iToken,
    address _rebalancer,
    address _priceCalculator,
    address _idleCompound,
    address _idleFulcrum
  ) external onlyOwner returns(address) {

    require(
      _token != address(0) && _cToken != address(0) &&
      _iToken != address(0) && _rebalancer != address(0) &&
      _priceCalculator != address(0) && _idleCompound != address(0) &&
      _idleFulcrum != address(0), 'some addr is 0');

    IdleToken idleToken = new IdleToken(
      _name, // eg. IdleDAI
      _symbol, // eg. IDLEDAI
      _decimals, // eg. 18
      _token,
      _cToken,
      _iToken,
      _rebalancer,
      _priceCalculator,
      _idleCompound,
      _idleFulcrum
    );
    if (underlyingToIdleTokenMap[_token] == address(0)) {
      tokensSupported.push(_token);
    }
    underlyingToIdleTokenMap[_token] = address(idleToken);

    return address(idleToken);
  }

  function setTokenOwnershipAndPauser(address _idleToken) external onlyOwner {

    require(_idleToken != address(0), '_idleToken addr is 0');

    IdleToken idleToken = IdleToken(_idleToken);
    idleToken.transferOwnership(msg.sender);
    idleToken.addPauser(msg.sender);
    idleToken.renouncePauser();
  }

  function supportedTokens() external view returns(address[] memory) {

    return tokensSupported;
  }

  function getIdleTokenAddress(address _underlying) external view returns(address) {

    return underlyingToIdleTokenMap[_underlying];
  }
}