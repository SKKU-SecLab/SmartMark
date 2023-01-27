

pragma solidity ^0.6.0;

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


pragma solidity ^0.6.0;


contract ContextUpgradeSafe is Initializable {


    function __Context_init() internal initializer {

        __Context_init_unchained();
    }

    function __Context_init_unchained() internal initializer {



    }


    function _msgSender() internal view virtual returns (address payable) {

        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {

        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }

    uint256[50] private __gap;
}


pragma solidity ^0.6.0;

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


pragma solidity ^0.6.2;

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
}


pragma solidity ^0.6.0;






contract ERC20UpgradeSafe is Initializable, ContextUpgradeSafe, IERC20 {

    using SafeMath for uint256;
    using Address for address;

    mapping (address => uint256) private _balances;

    mapping (address => mapping (address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;
    uint8 private _decimals;


    function __ERC20_init(string memory name, string memory symbol) internal initializer {

        __Context_init_unchained();
        __ERC20_init_unchained(name, symbol);
    }

    function __ERC20_init_unchained(string memory name, string memory symbol) internal initializer {



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


    uint256[44] private __gap;
}


pragma solidity ^0.6.0;




library SafeERC20 {

    using SafeMath for uint256;
    using Address for address;

    function safeTransfer(IERC20 token, address to, uint256 value) internal {

        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(IERC20 token, address from, address to, uint256 value) internal {

        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    function safeApprove(IERC20 token, address spender, uint256 value) internal {

        require((value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(IERC20 token, address spender, uint256 value) internal {

        uint256 newAllowance = token.allowance(address(this), spender).add(value);
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(IERC20 token, address spender, uint256 value) internal {

        uint256 newAllowance = token.allowance(address(this), spender).sub(value, "SafeERC20: decreased allowance below zero");
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function _callOptionalReturn(IERC20 token, bytes memory data) private {


        require(address(token).isContract(), "SafeERC20: call to non-contract");

        (bool success, bytes memory returndata) = address(token).call(data);
        require(success, "SafeERC20: low-level call failed");

        if (returndata.length > 0) { // Return data is optional
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}


pragma solidity ^0.6.0;


contract ReentrancyGuardUpgradeSafe is Initializable {

    bool private _notEntered;


    function __ReentrancyGuard_init() internal initializer {

        __ReentrancyGuard_init_unchained();
    }

    function __ReentrancyGuard_init_unchained() internal initializer {



        _notEntered = true;

    }


    modifier nonReentrant() {

        require(_notEntered, "ReentrancyGuard: reentrant call");

        _notEntered = false;

        _;

        _notEntered = true;
    }

    uint256[49] private __gap;
}


pragma solidity >=0.6.0;

interface AggregatorV3Interface {


  function decimals() external view returns (uint8);

  function description() external view returns (string memory);

  function version() external view returns (uint256);


  function getRoundData(uint80 _roundId)
    external
    view
    returns (
      uint80 roundId,
      int256 answer,
      uint256 startedAt,
      uint256 updatedAt,
      uint80 answeredInRound
    );

  function latestRoundData()
    external
    view
    returns (
      uint80 roundId,
      int256 answer,
      uint256 startedAt,
      uint256 updatedAt,
      uint80 answeredInRound
    );


}


pragma solidity ^0.6.0;


contract OwnableUpgradeSafe is Initializable, ContextUpgradeSafe {

    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);


    function __Ownable_init() internal initializer {

        __Context_init_unchained();
        __Ownable_init_unchained();
    }

    function __Ownable_init_unchained() internal initializer {



        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);

    }


    function owner() public view returns (address) {

        return _owner;
    }

    modifier onlyOwner() {

        require(_owner == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {

        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {

        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }

    uint256[49] private __gap;
}


pragma solidity ^0.6.0;







interface TwapOracle {

    function update() external;

    function consult(address token, uint amountIn) external view returns (uint amountOut);

    function changePeriod(uint256 seconds_) external;

}

interface IGaia {

    function burn(address from, uint256 amount) external;

    function mint(address to, uint256 amount) external;

}

contract USDf is ERC20UpgradeSafe, OwnableUpgradeSafe, ReentrancyGuardUpgradeSafe {

    using SafeMath for uint256;

    uint256 constant public MAX_RESERVE_RATIO = 100 * 10 ** 9;
    uint256 private constant DECIMALS = 9;
    uint256 private _lastRefreshReserve;
    uint256 private _minimumRefreshTime;
    uint256 public gaiaDecimals;
    uint256 private constant MAX_SUPPLY = ~uint128(0);
    uint256 private extraVar;
    uint256 private _totalSupply;
    uint256 private _mintFee;
    uint256 private _withdrawFee;
    uint256 private _minimumDelay;                        // how long a user must wait between actions
    uint256 public MIN_RESERVE_RATIO;
    uint256 private _reserveRatio;

    address public gaia;            
    address public synthOracle;
    address public gaiaOracle;
    address public usdcAddress;
    
    address[] private collateralArray;

    AggregatorV3Interface internal usdcPrice;

    mapping(address => uint256) private _synthBalance;
    mapping(address => uint256) private _lastAction;
    mapping (address => mapping (address => uint256)) private _allowedSynth;
    mapping (address => bool) public acceptedCollateral;
    mapping (address => uint256) public collateralDecimals;
    mapping (address => address) public collateralOracle;
    mapping (address => bool) public seenCollateral;
    mapping (address => uint256) private _burnedSynth;

    modifier validRecipient(address to) {

        require(to != address(0x0));
        require(to != address(this));
        _;
    }

    modifier sync() {

        if (_totalSupply > 0) {
            updateOracles();

            if (now - _lastRefreshReserve >= _minimumRefreshTime) {
                TwapOracle(gaiaOracle).update();
                TwapOracle(synthOracle).update();
                if (getSynthOracle() > 1 * 10 ** 9) {
                    setReserveRatio(_reserveRatio.sub(5 * 10 ** 8));
                } else {
                    setReserveRatio(_reserveRatio.add(5 * 10 ** 8));
                }

                _lastRefreshReserve = now;
            }
        }
        
        _;
    }

    event NewReserveRate(uint256 reserveRatio);
    event Mint(address gaia, address receiver, address collateral, uint256 collateralAmount, uint256 gaiaAmount, uint256 synthAmount);
    event Withdraw(address gaia, address receiver, address collateral, uint256 collateralAmount, uint256 gaiaAmount, uint256 synthAmount);
    event NewMinimumRefreshTime(uint256 minimumRefreshTime);
    event MintFee(uint256 fee);
    event WithdrawFee(uint256 fee);

    function initialize(address gaia_, uint256 gaiaDecimals_, address usdcAddress_, address usdcOracleChainLink_) public initializer {

        OwnableUpgradeSafe.__Ownable_init();
        ReentrancyGuardUpgradeSafe.__ReentrancyGuard_init();

        ERC20UpgradeSafe.__ERC20_init('USDf', 'USDf');
        ERC20UpgradeSafe._setupDecimals(9);

        gaia = gaia_;
        _minimumRefreshTime = 3600 * 1;      // 1 hours by default
        _minimumDelay = _minimumRefreshTime;  // minimum delay must >= minimum refresh time
        gaiaDecimals = gaiaDecimals_;
        usdcPrice = AggregatorV3Interface(usdcOracleChainLink_);
        usdcAddress = usdcAddress_;
        _reserveRatio = 100 * 10 ** 9;   // 100% reserve at first
        _totalSupply = 0;
    }

    function getCollateralByIndex(uint256 index_) external view returns (address) {

        return collateralArray[index_];
    }

    function burnedSynth(address user_) external view returns (uint256) {

        return _burnedSynth[user_];
    }

    function lastAction(address user_) external view returns (uint256) {

        return _lastAction[user_];
    }

    function getCollateralUsd(address collateral_) public view returns (uint256) {

        ( , int price, , uint timeStamp, ) = usdcPrice.latestRoundData();
        require(timeStamp > 0, "Rounds not complete");

        if (address(collateral_) == address(usdcAddress)) {
            return uint256(price).mul(10);
        } else {
            return uint256(price).mul(10 ** 10).div((TwapOracle(collateralOracle[collateral_]).consult(usdcAddress, 10 ** 6)).mul(10 ** 9).div(10 ** collateralDecimals[collateral_]));
        }
    }

    function globalCollateralValue() public view returns (uint256) {

        uint256 totalCollateralUsd = 0; 

        for (uint i = 0; i < collateralArray.length; i++){ 
            if (collateralArray[i] != address(0)){
                totalCollateralUsd += IERC20(collateralArray[i]).balanceOf(address(this)).mul(10 ** 9).div(10 ** collateralDecimals[collateralArray[i]]).mul(getCollateralUsd(collateralArray[i])).div(10 ** 9); // add stablecoin balance
            }
        }
        return totalCollateralUsd;
    }

    function usdfInfo() public view returns (uint256, uint256, uint256, uint256, uint256, uint256, uint256, uint256, uint256, uint256) {

        return (
            _totalSupply,
            _reserveRatio,
            globalCollateralValue(),
            _mintFee,
            _withdrawFee,
            _minimumDelay,
            getGaiaOracle(),
            getSynthOracle(),
            _lastRefreshReserve,
            _minimumRefreshTime
        );
    }

    function totalSupply() public override view returns (uint256) {

        return _totalSupply;
    }

    function balanceOf(address who) public override view returns (uint256) {

        return _synthBalance[who];
    }

    function allowance(address owner_, address spender) public override view returns (uint256) {

        return _allowedSynth[owner_][spender];
    }

    function getGaiaOracle() public view returns (uint256) {

        uint256 gaiaTWAP = TwapOracle(gaiaOracle).consult(address(this), 1 * 10 ** 9);
        uint256 usdfOraclePrice = getSynthOracle();

        return uint256(usdfOraclePrice).mul(10 ** DECIMALS).div(gaiaTWAP);
    }

    function getSynthOracle() public view returns (uint256) {

        uint256 synthTWAP = TwapOracle(synthOracle).consult(usdcAddress, 1 * 10 ** 6);

        ( , int price, , uint timeStamp, ) = usdcPrice.latestRoundData();

        require(timeStamp > 0, "rounds not complete");

        return uint256(price).mul(10).mul(10 ** DECIMALS).div(synthTWAP);
    }

    function consultSynthRatio(uint256 synthAmount, address collateral) public view returns (uint256, uint256) {

        require(synthAmount != 0, "must use valid USDf amount");
        require(seenCollateral[collateral], "must be seen collateral");

        uint256 collateralAmount = synthAmount.mul(_reserveRatio).div(MAX_RESERVE_RATIO).mul(10 ** collateralDecimals[collateral]).div(10 ** DECIMALS);

        if (_totalSupply == 0) {
            return (collateralAmount, 0);
        } else {
            collateralAmount = collateralAmount.mul(10 ** 9).div(getCollateralUsd(collateral)); // get real time price
            uint256 gaiaUsd = getGaiaOracle();                         
            uint256 synthPrice = getSynthOracle();                      

            uint256 synthPart2 = synthAmount.mul(MAX_RESERVE_RATIO.sub(_reserveRatio)).div(MAX_RESERVE_RATIO);
            uint256 gaiaAmount = synthPart2.mul(synthPrice).div(gaiaUsd);

            return (collateralAmount, gaiaAmount);
        }
    }

    function updateOracles() public {

        for (uint i = 0; i < collateralArray.length; i++) {
            if (acceptedCollateral[collateralArray[i]]) TwapOracle(collateralOracle[collateralArray[i]]).update();
        } 
    }

    function transfer(address to, uint256 value) public override validRecipient(to) sync() returns (bool) {

        _synthBalance[msg.sender] = _synthBalance[msg.sender].sub(value);
        _synthBalance[to] = _synthBalance[to].add(value);
        emit Transfer(msg.sender, to, value);

        return true;
    }

    function transferFrom(address from, address to, uint256 value) public override validRecipient(to) sync() returns (bool) {

        _allowedSynth[from][msg.sender] = _allowedSynth[from][msg.sender].sub(value);

        _synthBalance[from] = _synthBalance[from].sub(value);
        _synthBalance[to] = _synthBalance[to].add(value);
        emit Transfer(from, to, value);

        return true;
    }

    function approve(address spender, uint256 value) public override sync() returns (bool) {

        _allowedSynth[msg.sender][spender] = value;
        emit Approval(msg.sender, spender, value);
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public override returns (bool) {

        _allowedSynth[msg.sender][spender] = _allowedSynth[msg.sender][spender].add(addedValue);
        emit Approval(msg.sender, spender, _allowedSynth[msg.sender][spender]);
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public override returns (bool) {

        uint256 oldValue = _allowedSynth[msg.sender][spender];
        if (subtractedValue >= oldValue) {
            _allowedSynth[msg.sender][spender] = 0;
        } else {
            _allowedSynth[msg.sender][spender] = oldValue.sub(subtractedValue);
        }
        emit Approval(msg.sender, spender, _allowedSynth[msg.sender][spender]);
        return true;
    }

    function mint(uint256 synthAmount, address collateral) public nonReentrant sync() {

        require(acceptedCollateral[collateral], "must be an accepted collateral");

        (uint256 collateralAmount, uint256 gaiaAmount) = consultSynthRatio(synthAmount, collateral);
        require(collateralAmount <= IERC20(collateral).balanceOf(msg.sender), "sender has insufficient collateral balance");
        require(gaiaAmount <= IERC20(gaia).balanceOf(msg.sender), "sender has insufficient gaia balance");

        SafeERC20.safeTransferFrom(IERC20(collateral), msg.sender, address(this), collateralAmount);

        if (gaiaAmount != 0) IGaia(gaia).burn(msg.sender, gaiaAmount);

        synthAmount = synthAmount.sub(synthAmount.mul(_mintFee).div(100 * 10 ** DECIMALS));

        _totalSupply = _totalSupply.add(synthAmount);
        _synthBalance[msg.sender] = _synthBalance[msg.sender].add(synthAmount);

        emit Transfer(address(0x0), msg.sender, synthAmount);
        emit Mint(gaia, msg.sender, collateral, collateralAmount, gaiaAmount, synthAmount);
    }

    function withdraw(uint256 synthAmount) public nonReentrant sync() {

        require(synthAmount == 0, "temporarily disabled");
        require(synthAmount <= _synthBalance[msg.sender], "insufficient balance");

        _totalSupply = _totalSupply.sub(synthAmount);
        _synthBalance[msg.sender] = _synthBalance[msg.sender].sub(synthAmount);

        _burnedSynth[msg.sender] = _burnedSynth[msg.sender].add(synthAmount);

        _lastAction[msg.sender] = now;

        emit Transfer(msg.sender, address(0x0), synthAmount);
    }

    function completeWithdrawal(address collateral, uint256 synthAmount) public nonReentrant sync() {

        require(now.sub(_lastAction[msg.sender]) > _minimumDelay, "action too soon");
        require(seenCollateral[collateral], "invalid collateral");
        require(synthAmount != 0);
        require(synthAmount <= _burnedSynth[msg.sender]);

        _burnedSynth[msg.sender] = _burnedSynth[msg.sender].sub(synthAmount);

        (uint256 collateralAmount, uint256 gaiaAmount) = consultSynthRatio(synthAmount, collateral);

        collateralAmount = collateralAmount.sub(collateralAmount.mul(_withdrawFee).div(100 * 10 ** DECIMALS));
        gaiaAmount = gaiaAmount.sub(gaiaAmount.mul(_withdrawFee).div(100 * 10 ** DECIMALS));

        require(collateralAmount <= IERC20(collateral).balanceOf(address(this)), "insufficient collateral");

        SafeERC20.safeTransfer(IERC20(collateral), msg.sender, collateralAmount);
        if (gaiaAmount != 0) IGaia(gaia).mint(msg.sender, gaiaAmount);

        _lastAction[msg.sender] = now;

        emit Withdraw(gaia, msg.sender, collateral, collateralAmount, gaiaAmount, synthAmount);
    }

    function burnGaia(uint256 amount) external onlyOwner {

        require(amount <= IERC20(gaia).balanceOf(msg.sender));
        IGaia(gaia).burn(msg.sender, amount);
    }

    function setDelay(uint256 val_) external onlyOwner {

        require(_minimumDelay >= _minimumRefreshTime);
        _minimumDelay = val_;
    }

    function addCollateral(address collateral_, uint256 collateralDecimal_, address oracleAddress_) external onlyOwner {

        collateralArray.push(collateral_);
        acceptedCollateral[collateral_] = true;
        seenCollateral[collateral_] = true;
        collateralDecimals[collateral_] = collateralDecimal_;
        collateralOracle[collateral_] = oracleAddress_;
    }

    function setCollateralOracle(address collateral_, address oracleAddress_) external onlyOwner {

        collateralOracle[collateral_] = oracleAddress_;
    }

    function removeCollateral(address collateral_) external onlyOwner {

        delete acceptedCollateral[collateral_];
        delete collateralOracle[collateral_];

        for (uint i = 0; i < collateralArray.length; i++){ 
            if (collateralArray[i] == collateral_) {
                collateralArray[i] = address(0); // This will leave a null in the array and keep the indices the same
                break;
            }
        }
    }

    function setSynthOracle(address oracle_) external onlyOwner returns (bool)  {

        synthOracle = oracle_;
        
        return true;
    }

    function setGaiaOracle(address oracle_) external onlyOwner returns (bool) {

        gaiaOracle = oracle_;

        return true;
    }

    function editMintFee(uint256 fee_) external onlyOwner {

        _mintFee = fee_;
        emit MintFee(fee_);
    }

    function editWithdrawFee(uint256 fee_) external onlyOwner {

        _withdrawFee = fee_;
        emit WithdrawFee(fee_);
    }

    function setSeenCollateral(address collateral_, bool val_) external onlyOwner {

        seenCollateral[collateral_] = val_;
    }

    function setMinReserveRate(uint256 rate_) external onlyOwner {

        require(rate_ != 0);
        require(rate_ <= 100 * 10 ** 9, "rate high");

        MIN_RESERVE_RATIO = rate_;
    }

    function setReserveRatioAdmin(uint256 newRatio_) external onlyOwner {

        require(newRatio_ != 0);

        if (newRatio_ >= MIN_RESERVE_RATIO && newRatio_ <= MAX_RESERVE_RATIO) {
            _reserveRatio = newRatio_;
            emit NewReserveRate(_reserveRatio);
        }
    }

    function setMinimumRefreshTime(uint256 val_) external onlyOwner returns (bool) {

        require(val_ != 0);

        _minimumRefreshTime = val_;

        for (uint i = 0; i < collateralArray.length; i++) {
            if (acceptedCollateral[collateralArray[i]]) TwapOracle(collateralOracle[collateralArray[i]]).changePeriod(val_);
        }

        emit NewMinimumRefreshTime(val_);
        return true;
    }

    function moveCollateral(address collateral, address location, uint256 amount) external onlyOwner {

        require(acceptedCollateral[collateral], "invalid collateral");
        SafeERC20.safeTransfer(IERC20(collateral), location, amount);
    }

    function executeTransaction(address target, uint value, string memory signature, bytes memory data) public payable onlyOwner returns (bytes memory) {

        bytes memory callData;

        if (bytes(signature).length == 0) {
            callData = data;
        } else {
            callData = abi.encodePacked(bytes4(keccak256(bytes(signature))), data);
        }

        (bool success, bytes memory returnData) = target.call.value(value)(callData);
        require(success);

        return returnData;
    }

    function setReserveRatio(uint256 newRatio_) private {

        require(newRatio_ != 0);

        if (newRatio_ >= MIN_RESERVE_RATIO && newRatio_ <= MAX_RESERVE_RATIO) {
            _reserveRatio = newRatio_;
            emit NewReserveRate(_reserveRatio);
        }
    }
}