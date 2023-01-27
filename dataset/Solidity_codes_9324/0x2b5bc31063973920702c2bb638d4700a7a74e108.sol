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
}pragma solidity ^0.6.0;

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
}pragma solidity ^0.6.0;

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
}pragma solidity ^0.6.0;

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
}pragma solidity ^0.6.0;


contract PausableUpgradeSafe is Initializable, ContextUpgradeSafe {

    event Paused(address account);

    event Unpaused(address account);

    bool private _paused;


    function __Pausable_init() internal initializer {

        __Context_init_unchained();
        __Pausable_init_unchained();
    }

    function __Pausable_init_unchained() internal initializer {



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

    function _pause() internal virtual whenNotPaused {

        _paused = true;
        emit Paused(_msgSender());
    }

    function _unpause() internal virtual whenPaused {

        _paused = false;
        emit Unpaused(_msgSender());
    }

    uint256[49] private __gap;
}pragma solidity ^0.6.2;

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
}pragma solidity ^0.6.0;

interface IERC20 {

    function totalSupply() external view returns (uint256);


    function balanceOf(address account) external view returns (uint256);


    function transfer(address recipient, uint256 amount) external returns (bool);


    function allowance(address owner, address spender) external view returns (uint256);


    function approve(address spender, uint256 amount) external returns (bool);


    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);


    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}pragma solidity ^0.6.0;

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
}pragma solidity ^0.6.0;


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
}pragma solidity ^0.6.0;


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


    uint256[44] private __gap;
}pragma solidity ^0.6.0;

library SignedSafeMath {

    int256 constant private _INT256_MIN = -2**255;

    function mul(int256 a, int256 b) internal pure returns (int256) {

        if (a == 0) {
            return 0;
        }

        require(!(a == -1 && b == _INT256_MIN), "SignedSafeMath: multiplication overflow");

        int256 c = a * b;
        require(c / a == b, "SignedSafeMath: multiplication overflow");

        return c;
    }

    function div(int256 a, int256 b) internal pure returns (int256) {

        require(b != 0, "SignedSafeMath: division by zero");
        require(!(b == -1 && a == _INT256_MIN), "SignedSafeMath: division overflow");

        int256 c = a / b;

        return c;
    }

    function sub(int256 a, int256 b) internal pure returns (int256) {

        int256 c = a - b;
        require((b >= 0 && c <= a) || (b < 0 && c > a), "SignedSafeMath: subtraction overflow");

        return c;
    }

    function add(int256 a, int256 b) internal pure returns (int256) {

        int256 c = a + b;
        require((b >= 0 && c >= a) || (b < 0 && c < a), "SignedSafeMath: addition overflow");

        return c;
    }
}pragma solidity >=0.6.0;

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


}// UNLICENSED
pragma solidity 0.6.11;

interface ILiquidityPoolV2 {

    event DepositedAPT(
        address indexed sender,
        IERC20 token,
        uint256 tokenAmount,
        uint256 aptMintAmount,
        uint256 tokenEthValue,
        uint256 totalEthValueLocked
    );
    event RedeemedAPT(
        address indexed sender,
        IERC20 token,
        uint256 redeemedTokenAmount,
        uint256 aptRedeemAmount,
        uint256 tokenEthValue,
        uint256 totalEthValueLocked
    );
    event AddLiquidityLocked();
    event AddLiquidityUnlocked();
    event RedeemLocked();
    event RedeemUnlocked();

    function addLiquidity(uint256 amount) external;


    function redeem(uint256 tokenAmount) external;

}// UNLICENSED
pragma solidity 0.6.11;


interface IDetailedERC20 is IERC20 {

    function name() external view returns (string memory);


    function symbol() external view returns (string memory);


    function decimals() external view returns (uint8);

}// UNLICENSED
pragma solidity 0.6.11;

interface IAddressRegistryV2 {

    function getIds() external view returns (bytes32[] memory);


    function getAddress(bytes32 id) external view returns (address);


    function poolManagerAddress() external view returns (address);


    function tvlManagerAddress() external view returns (address);


    function chainlinkRegistryAddress() external view returns (address);


    function daiPoolAddress() external view returns (address);


    function usdcPoolAddress() external view returns (address);


    function usdtPoolAddress() external view returns (address);


    function mAptAddress() external view returns (address);


    function lpSafeAddress() external view returns (address);


    function oracleAdapterAddress() external view returns (address);

}// UNLICENSED
pragma solidity 0.6.11;

interface IMintable {

    function mint(address account, uint256 amount) external;


    function burn(address account, uint256 amount) external;

}// UNLICENSED
pragma solidity 0.6.11;

interface IOracleAdapter {

    struct Value {
        uint256 value;
        uint256 periodEnd;
    }

    function setTvl(uint256 value, uint256 period) external;


    function setAssetValue(
        address asset,
        uint256 value,
        uint256 period
    ) external;


    function lock() external;


    function defaultLockPeriod() external returns (uint256 period);


    function setDefaultLockPeriod(uint256 period) external;


    function lockFor(uint256 period) external;


    function unlock() external;


    function getAssetPrice(address asset) external view returns (uint256);


    function getTvl() external view returns (uint256);


    function isLocked() external view returns (bool);

}// UNLICENSED
pragma solidity 0.6.11;
pragma experimental ABIEncoderV2;


contract MetaPoolToken is
    Initializable,
    OwnableUpgradeSafe,
    ReentrancyGuardUpgradeSafe,
    PausableUpgradeSafe,
    ERC20UpgradeSafe,
    IMintable
{

    using SafeMath for uint256;
    uint256 public constant DEFAULT_MAPT_TO_UNDERLYER_FACTOR = 1000;

    address public proxyAdmin;
    IAddressRegistryV2 public addressRegistry;


    event Mint(address acccount, uint256 amount);
    event Burn(address acccount, uint256 amount);
    event AdminChanged(address);

    function initialize(address adminAddress, address _addressRegistry)
        external
        initializer
    {

        require(adminAddress != address(0), "INVALID_ADMIN");

        __Context_init_unchained();
        __Ownable_init_unchained();
        __ReentrancyGuard_init_unchained();
        __Pausable_init_unchained();
        __ERC20_init_unchained("APY MetaPool Token", "mAPT");

        setAdminAddress(adminAddress);
        setAddressRegistry(_addressRegistry);
    }

    function initializeUpgrade() external virtual onlyAdmin {}


    function setAdminAddress(address adminAddress) public onlyOwner {

        require(adminAddress != address(0), "INVALID_ADMIN");
        proxyAdmin = adminAddress;
        emit AdminChanged(adminAddress);
    }

    modifier onlyAdmin() {

        require(msg.sender == proxyAdmin, "ADMIN_ONLY");
        _;
    }

    modifier onlyManager() {

        require(
            msg.sender == addressRegistry.poolManagerAddress(),
            "MANAGER_ONLY"
        );
        _;
    }

    function mint(address account, uint256 amount)
        public
        override
        nonReentrant
        onlyManager
    {

        require(amount > 0, "INVALID_MINT_AMOUNT");
        IOracleAdapter oracleAdapter = _getOracleAdapter();
        oracleAdapter.lock();
        _mint(account, amount);
        emit Mint(account, amount);
    }

    function burn(address account, uint256 amount)
        public
        override
        nonReentrant
        onlyManager
    {

        require(amount > 0, "INVALID_BURN_AMOUNT");
        IOracleAdapter oracleAdapter = _getOracleAdapter();
        oracleAdapter.lock();
        _burn(account, amount);
        emit Burn(account, amount);
    }

    function getTvl() public view returns (uint256) {

        IOracleAdapter oracleAdapter = _getOracleAdapter();
        return oracleAdapter.getTvl();
    }

    function _getOracleAdapter() internal view returns (IOracleAdapter) {

        address oracleAdapterAddress = addressRegistry.oracleAdapterAddress();
        return IOracleAdapter(oracleAdapterAddress);
    }

    function calculateMintAmount(
        uint256 depositAmount,
        uint256 tokenPrice,
        uint256 decimals
    ) public view returns (uint256) {

        uint256 depositValue = depositAmount.mul(tokenPrice).div(10**decimals);
        uint256 totalValue = getTvl();
        return _calculateMintAmount(depositValue, totalValue);
    }

    function _calculateMintAmount(uint256 depositValue, uint256 totalValue)
        internal
        view
        returns (uint256)
    {

        uint256 totalSupply = totalSupply();

        if (totalValue == 0 || totalSupply == 0) {
            return depositValue.mul(DEFAULT_MAPT_TO_UNDERLYER_FACTOR);
        }

        return depositValue.mul(totalSupply).div(totalValue);
    }

    function calculatePoolAmount(
        uint256 mAptAmount,
        uint256 tokenPrice,
        uint256 decimals
    ) public view returns (uint256) {

        if (mAptAmount == 0) return 0;
        require(totalSupply() > 0, "INSUFFICIENT_TOTAL_SUPPLY");
        uint256 poolValue = mAptAmount.mul(getTvl()).div(totalSupply());
        uint256 poolAmount = poolValue.mul(10**decimals).div(tokenPrice);
        return poolAmount;
    }

    function getDeployedValue(address pool) public view returns (uint256) {

        uint256 balance = balanceOf(pool);
        uint256 totalSupply = totalSupply();
        if (totalSupply == 0 || balance == 0) return 0;

        return getTvl().mul(balance).div(totalSupply);
    }

    function setAddressRegistry(address _addressRegistry) public onlyOwner {

        require(Address.isContract(_addressRegistry), "INVALID_ADDRESS");
        addressRegistry = IAddressRegistryV2(_addressRegistry);
    }
}// UNLICENSED
pragma solidity 0.6.11;


contract PoolTokenV2 is
    ILiquidityPoolV2,
    Initializable,
    OwnableUpgradeSafe,
    ReentrancyGuardUpgradeSafe,
    PausableUpgradeSafe,
    ERC20UpgradeSafe
{

    using Address for address;
    using SafeMath for uint256;
    using SignedSafeMath for int256;
    using SafeERC20 for IDetailedERC20;
    uint256 public constant DEFAULT_APT_TO_UNDERLYER_FACTOR = 1000;
    uint256 internal constant _MAX_INT256 = 2**255 - 1;

    event AdminChanged(address);


    address public proxyAdmin;
    bool public addLiquidityLock;
    bool public redeemLock;
    IDetailedERC20 public underlyer;

    IAddressRegistryV2 public addressRegistry;
    uint256 public feePeriod;
    uint256 public feePercentage;
    mapping(address => uint256) public lastDepositTime;
    uint256 public reservePercentage;


    function initialize(
        address adminAddress,
        IDetailedERC20 _underlyer,
        AggregatorV3Interface _priceAgg
    ) external initializer {

        require(adminAddress != address(0), "INVALID_ADMIN");
        require(address(_underlyer) != address(0), "INVALID_TOKEN");
        require(address(_priceAgg) != address(0), "INVALID_AGG");

        __Context_init_unchained();
        __Ownable_init_unchained();
        __ReentrancyGuard_init_unchained();
        __Pausable_init_unchained();
        __ERC20_init_unchained("APY Pool Token", "APT");

        setAdminAddress(adminAddress);
        addLiquidityLock = false;
        redeemLock = false;
        underlyer = _underlyer;
    }

    function initializeUpgrade(address _addressRegistry)
        external
        virtual
        onlyAdmin
    {

        require(_addressRegistry.isContract(), "INVALID_ADDRESS");
        addressRegistry = IAddressRegistryV2(_addressRegistry);
        feePeriod = 1 days;
        feePercentage = 5;
        reservePercentage = 5;
    }

    function setAdminAddress(address adminAddress) public onlyOwner {

        require(adminAddress != address(0), "INVALID_ADMIN");
        proxyAdmin = adminAddress;
        emit AdminChanged(adminAddress);
    }

    function setAddressRegistry(address payable _addressRegistry)
        public
        onlyOwner
    {

        require(Address.isContract(_addressRegistry), "INVALID_ADDRESS");
        addressRegistry = IAddressRegistryV2(_addressRegistry);
    }

    function setFeePeriod(uint256 _feePeriod) public onlyOwner {

        feePeriod = _feePeriod;
    }

    function setFeePercentage(uint256 _feePercentage) public onlyOwner {

        feePercentage = _feePercentage;
    }

    function setReservePercentage(uint256 _reservePercentage) public onlyOwner {

        reservePercentage = _reservePercentage;
    }

    modifier onlyAdmin() {

        require(msg.sender == proxyAdmin, "ADMIN_ONLY");
        _;
    }

    function lock() external onlyOwner {

        _pause();
    }

    function unlock() external onlyOwner {

        _unpause();
    }

    function addLiquidity(uint256 depositAmount)
        external
        virtual
        override
        nonReentrant
        whenNotPaused
    {

        require(!addLiquidityLock, "LOCKED");
        require(depositAmount > 0, "AMOUNT_INSUFFICIENT");
        require(
            underlyer.allowance(msg.sender, address(this)) >= depositAmount,
            "ALLOWANCE_INSUFFICIENT"
        );
        lastDepositTime[msg.sender] = block.timestamp;

        uint256 depositValue = getValueFromUnderlyerAmount(depositAmount);
        uint256 poolTotalValue = getPoolTotalValue();
        uint256 mintAmount = _calculateMintAmount(depositValue, poolTotalValue);

        _mint(msg.sender, mintAmount);
        underlyer.safeTransferFrom(msg.sender, address(this), depositAmount);

        emit DepositedAPT(
            msg.sender,
            underlyer,
            depositAmount,
            mintAmount,
            depositValue,
            getPoolTotalValue()
        );
    }

    function lockAddLiquidity() external onlyOwner {

        addLiquidityLock = true;
        emit AddLiquidityLocked();
    }

    function unlockAddLiquidity() external onlyOwner {

        addLiquidityLock = false;
        emit AddLiquidityUnlocked();
    }

    function redeem(uint256 aptAmount)
        external
        virtual
        override
        nonReentrant
        whenNotPaused
    {

        require(!redeemLock, "LOCKED");
        require(aptAmount > 0, "AMOUNT_INSUFFICIENT");
        require(aptAmount <= balanceOf(msg.sender), "BALANCE_INSUFFICIENT");

        uint256 redeemUnderlyerAmt = getUnderlyerAmountWithFee(aptAmount);
        require(
            redeemUnderlyerAmt <= underlyer.balanceOf(address(this)),
            "RESERVE_INSUFFICIENT"
        );

        _burn(msg.sender, aptAmount);
        underlyer.safeTransfer(msg.sender, redeemUnderlyerAmt);

        emit RedeemedAPT(
            msg.sender,
            underlyer,
            redeemUnderlyerAmt,
            aptAmount,
            getValueFromUnderlyerAmount(redeemUnderlyerAmt),
            getPoolTotalValue()
        );
    }

    function lockRedeem() external onlyOwner {

        redeemLock = true;
        emit RedeemLocked();
    }

    function unlockRedeem() external onlyOwner {

        redeemLock = false;
        emit RedeemUnlocked();
    }

    function calculateMintAmount(uint256 depositAmount)
        public
        view
        returns (uint256)
    {

        uint256 depositValue = getValueFromUnderlyerAmount(depositAmount);
        uint256 poolTotalValue = getPoolTotalValue();
        return _calculateMintAmount(depositValue, poolTotalValue);
    }

    function _calculateMintAmount(uint256 depositValue, uint256 poolTotalValue)
        internal
        view
        returns (uint256)
    {

        uint256 totalSupply = totalSupply();

        if (poolTotalValue == 0 || totalSupply == 0) {
            return depositValue.mul(DEFAULT_APT_TO_UNDERLYER_FACTOR);
        }

        return (depositValue.mul(totalSupply)).div(poolTotalValue);
    }

    function getUnderlyerAmountWithFee(uint256 aptAmount)
        public
        view
        returns (uint256)
    {

        uint256 redeemUnderlyerAmt = getUnderlyerAmount(aptAmount);
        if (isEarlyRedeem()) {
            uint256 fee = redeemUnderlyerAmt.mul(feePercentage).div(100);
            redeemUnderlyerAmt = redeemUnderlyerAmt.sub(fee);
        }
        return redeemUnderlyerAmt;
    }

    function getUnderlyerAmount(uint256 aptAmount)
        public
        view
        returns (uint256)
    {

        if (aptAmount == 0) {
            return 0;
        }
        require(totalSupply() > 0, "INSUFFICIENT_TOTAL_SUPPLY");
        uint256 underlyerPrice = getUnderlyerPrice();
        uint256 decimals = underlyer.decimals();
        return
            aptAmount
                .mul(getPoolTotalValue())
                .mul(10**decimals)
                .div(totalSupply())
                .div(underlyerPrice);
    }

    function isEarlyRedeem() public view returns (bool) {

        return block.timestamp.sub(lastDepositTime[msg.sender]) < feePeriod;
    }

    function getPoolTotalValue() public view virtual returns (uint256) {

        uint256 underlyerValue = getPoolUnderlyerValue();
        uint256 mAptValue = getDeployedValue();
        return underlyerValue.add(mAptValue);
    }

    function getPoolUnderlyerValue() public view virtual returns (uint256) {

        return getValueFromUnderlyerAmount(underlyer.balanceOf(address(this)));
    }

    function getDeployedValue() public view virtual returns (uint256) {

        MetaPoolToken mApt = MetaPoolToken(addressRegistry.mAptAddress());
        return mApt.getDeployedValue(address(this));
    }

    function getAPTValue(uint256 aptAmount) public view returns (uint256) {

        require(totalSupply() > 0, "INSUFFICIENT_TOTAL_SUPPLY");
        return aptAmount.mul(getPoolTotalValue()).div(totalSupply());
    }

    function getValueFromUnderlyerAmount(uint256 underlyerAmount)
        public
        view
        returns (uint256)
    {

        if (underlyerAmount == 0) {
            return 0;
        }
        uint256 decimals = underlyer.decimals();
        return getUnderlyerPrice().mul(underlyerAmount).div(10**decimals);
    }

    function getUnderlyerAmountFromValue(uint256 value)
        public
        view
        returns (uint256)
    {

        uint256 underlyerPrice = getUnderlyerPrice();
        uint256 decimals = underlyer.decimals();
        return (10**decimals).mul(value).div(underlyerPrice);
    }

    function getUnderlyerPrice() public view returns (uint256) {

        IOracleAdapter oracleAdapter =
            IOracleAdapter(addressRegistry.oracleAdapterAddress());
        return oracleAdapter.getAssetPrice(address(underlyer));
    }

    function getReserveTopUpValue() public view returns (int256) {

        uint256 unnormalizedTargetValue =
            getDeployedValue().mul(reservePercentage);
        uint256 unnormalizedUnderlyerValue = getPoolUnderlyerValue().mul(100);

        require(unnormalizedTargetValue <= _MAX_INT256, "SIGNED_INT_OVERFLOW");
        require(
            unnormalizedUnderlyerValue <= _MAX_INT256,
            "SIGNED_INT_OVERFLOW"
        );
        int256 topUpValue =
            int256(unnormalizedTargetValue)
                .sub(int256(unnormalizedUnderlyerValue))
                .div(int256(reservePercentage).add(100));
        return topUpValue;
    }

    function infiniteApprove(address delegate)
        external
        nonReentrant
        whenNotPaused
        onlyOwner
    {

        underlyer.safeApprove(delegate, type(uint256).max);
    }

    function revokeApprove(address delegate) external nonReentrant onlyOwner {

        underlyer.safeApprove(delegate, 0);
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual override {

        super._beforeTokenTransfer(from, to, amount);
        if (from == address(0) || to == address(0)) return;
        revert("INVALID_TRANSFER");
    }
}