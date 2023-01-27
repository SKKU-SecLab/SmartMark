
pragma solidity 0.5.16;
pragma experimental ABIEncoderV2;


interface MassetStructs {


    struct Basket {

        Basset[] bassets;

        uint8 maxBassets;

        bool undergoingRecol;

        bool failed;
        uint256 collateralisationRatio;

    }

    struct Basset {

        address addr;

        BassetStatus status; // takes uint8 datatype (1 byte) in storage

        bool isTransferFeeCharged; // takes a byte in storage

        uint256 ratio;

        uint256 maxWeight;

        uint256 vaultBalance;

    }

    enum BassetStatus {
        Default,
        Normal,
        BrokenBelowPeg,
        BrokenAbovePeg,
        Blacklisted,
        Liquidating,
        Liquidated,
        Failed
    }

    struct BassetDetails {
        Basset bAsset;
        address integrator;
        uint8 index;
    }

    struct ForgePropsMulti {
        bool isValid; // Flag to signify that forge bAssets have passed validity check
        Basset[] bAssets;
        address[] integrators;
        uint8[] indexes;
    }
    struct RedeemProps {
        bool isValid;
        Basset[] allBassets;
        Basset[] bAssets;
        address[] integrators;
        uint8[] indexes;
    }

    struct RedeemPropsMulti {
        uint256 colRatio;
        Basset[] bAssets;
        address[] integrators;
        uint8[] indexes;
    }
}

contract IForgeValidator is MassetStructs {

    function validateMint(uint256 _totalVault, Basset calldata _basset, uint256 _bAssetQuantity)
        external pure returns (bool, string memory);

    function validateMintMulti(uint256 _totalVault, Basset[] calldata _bassets, uint256[] calldata _bAssetQuantities)
        external pure returns (bool, string memory);

    function validateSwap(uint256 _totalVault, Basset calldata _inputBasset, Basset calldata _outputBasset, uint256 _quantity)
        external pure returns (bool, string memory, uint256, bool);

    function validateRedemption(
        bool basketIsFailed,
        uint256 _totalVault,
        Basset[] calldata _allBassets,
        uint8[] calldata _indices,
        uint256[] calldata _bassetQuantities) external pure returns (bool, string memory, bool);

    function calculateRedemptionMulti(
        uint256 _mAssetQuantity,
        Basset[] calldata _allBassets) external pure returns (bool, string memory, uint256[] memory);

}

interface IPlatformIntegration {


    function deposit(address _bAsset, uint256 _amount, bool isTokenFeeCharged)
        external returns (uint256 quantityDeposited);


    function withdraw(address _receiver, address _bAsset, uint256 _amount, bool _hasTxFee) external;


    function withdraw(address _receiver, address _bAsset, uint256 _amount, uint256 _totalAmount, bool _hasTxFee) external;


    function withdrawRaw(address _receiver, address _bAsset, uint256 _amount) external;


    function checkBalance(address _bAsset) external returns (uint256 balance);


    function bAssetToPToken(address _bAsset) external returns (address pToken);

}

contract IBasketManager is MassetStructs {


    function increaseVaultBalance(
        uint8 _bAsset,
        address _integrator,
        uint256 _increaseAmount) external;

    function increaseVaultBalances(
        uint8[] calldata _bAsset,
        address[] calldata _integrator,
        uint256[] calldata _increaseAmount) external;

    function decreaseVaultBalance(
        uint8 _bAsset,
        address _integrator,
        uint256 _decreaseAmount) external;

    function decreaseVaultBalances(
        uint8[] calldata _bAsset,
        address[] calldata _integrator,
        uint256[] calldata _decreaseAmount) external;

    function collectInterest() external
        returns (uint256 interestCollected, uint256[] memory gains);


    function addBasset(
        address _basset,
        address _integration,
        bool _isTransferFeeCharged) external returns (uint8 index);

    function setBasketWeights(address[] calldata _bassets, uint256[] calldata _weights) external;

    function setTransferFeesFlag(address _bAsset, bool _flag) external;


    function getBasket() external view returns (Basket memory b);

    function prepareForgeBasset(address _token, uint256 _amt, bool _mint) external
        returns (bool isValid, BassetDetails memory bInfo);

    function prepareSwapBassets(address _input, address _output, bool _isMint) external view
        returns (bool, string memory, BassetDetails memory, BassetDetails memory);

    function prepareForgeBassets(address[] calldata _bAssets, uint256[] calldata _amts, bool _mint) external
        returns (ForgePropsMulti memory props);

    function prepareRedeemBassets(address[] calldata _bAssets) external view
        returns (RedeemProps memory props);

    function prepareRedeemMulti() external view
        returns (RedeemPropsMulti memory props);

    function getBasset(address _token) external view
        returns (Basset memory bAsset);

    function getBassets() external view
        returns (Basset[] memory bAssets, uint256 len);

    function paused() external view returns (bool);


    function handlePegLoss(address _basset, bool _belowPeg) external returns (bool actioned);

    function negateIsolation(address _basset) external;

}

interface ISavingsManager {


    function distributeUnallocatedInterest(address _mAsset) external;


    function depositLiquidation(address _mAsset, uint256 _liquidation) external;


    function collectAndStreamInterest(address _mAsset) external;


    function collectAndDistributeInterest(address _mAsset) external;

}

contract IMasset is MassetStructs {


    function collectInterest() external returns (uint256 swapFeesGained, uint256 newTotalSupply);

    function collectPlatformInterest() external returns (uint256 interestGained, uint256 newTotalSupply);


    function mint(address _basset, uint256 _bassetQuantity)
        external returns (uint256 massetMinted);

    function mintTo(address _basset, uint256 _bassetQuantity, address _recipient)
        external returns (uint256 massetMinted);

    function mintMulti(address[] calldata _bAssets, uint256[] calldata _bassetQuantity, address _recipient)
        external returns (uint256 massetMinted);


    function swap( address _input, address _output, uint256 _quantity, address _recipient)
        external returns (uint256 output);

    function getSwapOutput( address _input, address _output, uint256 _quantity)
        external view returns (bool, string memory, uint256 output);


    function redeem(address _basset, uint256 _bassetQuantity)
        external returns (uint256 massetRedeemed);

    function redeemTo(address _basset, uint256 _bassetQuantity, address _recipient)
        external returns (uint256 massetRedeemed);

    function redeemMulti(address[] calldata _bAssets, uint256[] calldata _bassetQuantities, address _recipient)
        external returns (uint256 massetRedeemed);

    function redeemMasset(uint256 _mAssetQuantity, address _recipient) external;


    function upgradeForgeValidator(address _newForgeValidator) external;


    function setSwapFee(uint256 _swapFee) external;


    function getBasketManager() external view returns(address);

    function forgeValidator() external view returns (address);

    function totalSupply() external view returns (uint256);

    function swapFee() external view returns (uint256);

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

contract InitializableERC20Detailed is IERC20 {

    string private _name;
    string private _symbol;
    uint8 private _decimals;

    function _initialize(string memory nameArg, string memory symbolArg, uint8 decimalsArg) internal {

        _name = nameArg;
        _symbol = symbolArg;
        _decimals = decimalsArg;
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

contract InitializableToken is ERC20, InitializableERC20Detailed {


    function _initialize(string memory _nameArg, string memory _symbolArg) internal {

        InitializableERC20Detailed._initialize(_nameArg, _symbolArg, 18);
    }
}

contract InitializableModuleKeys {


    bytes32 internal KEY_GOVERNANCE;          // 2.x
    bytes32 internal KEY_STAKING;             // 1.2
    bytes32 internal KEY_PROXY_ADMIN;         // 1.0

    bytes32 internal KEY_ORACLE_HUB;          // 1.2
    bytes32 internal KEY_MANAGER;             // 1.2
    bytes32 internal KEY_RECOLLATERALISER;    // 2.x
    bytes32 internal KEY_META_TOKEN;          // 1.1
    bytes32 internal KEY_SAVINGS_MANAGER;     // 1.0

    function _initialize() internal {

        KEY_GOVERNANCE = keccak256("Governance");
        KEY_STAKING = keccak256("Staking");
        KEY_PROXY_ADMIN = keccak256("ProxyAdmin");

        KEY_ORACLE_HUB = keccak256("OracleHub");
        KEY_MANAGER = keccak256("Manager");
        KEY_RECOLLATERALISER = keccak256("Recollateraliser");
        KEY_META_TOKEN = keccak256("MetaToken");
        KEY_SAVINGS_MANAGER = keccak256("SavingsManager");
    }
}

interface INexus {

    function governor() external view returns (address);

    function getModule(bytes32 key) external view returns (address);


    function proposeModule(bytes32 _key, address _addr) external;

    function cancelProposedModule(bytes32 _key) external;

    function acceptProposedModule(bytes32 _key) external;

    function acceptProposedModules(bytes32[] calldata _keys) external;


    function requestLockModule(bytes32 _key) external;

    function cancelLockModule(bytes32 _key) external;

    function lockModule(bytes32 _key) external;

}

contract InitializableModule is InitializableModuleKeys {


    INexus public nexus;

    modifier onlyGovernor() {

        require(msg.sender == _governor(), "Only governor can execute");
        _;
    }

    modifier onlyGovernance() {

        require(
            msg.sender == _governor() || msg.sender == _governance(),
            "Only governance can execute"
        );
        _;
    }

    modifier onlyProxyAdmin() {

        require(
            msg.sender == _proxyAdmin(), "Only ProxyAdmin can execute"
        );
        _;
    }

    modifier onlyManager() {

        require(msg.sender == _manager(), "Only manager can execute");
        _;
    }

    function _initialize(address _nexus) internal {

        require(_nexus != address(0), "Nexus address is zero");
        nexus = INexus(_nexus);
        InitializableModuleKeys._initialize();
    }

    function _governor() internal view returns (address) {

        return nexus.governor();
    }

    function _governance() internal view returns (address) {

        return nexus.getModule(KEY_GOVERNANCE);
    }

    function _staking() internal view returns (address) {

        return nexus.getModule(KEY_STAKING);
    }

    function _proxyAdmin() internal view returns (address) {

        return nexus.getModule(KEY_PROXY_ADMIN);
    }

    function _metaToken() internal view returns (address) {

        return nexus.getModule(KEY_META_TOKEN);
    }

    function _oracleHub() internal view returns (address) {

        return nexus.getModule(KEY_ORACLE_HUB);
    }

    function _manager() internal view returns (address) {

        return nexus.getModule(KEY_MANAGER);
    }

    function _savingsManager() internal view returns (address) {

        return nexus.getModule(KEY_SAVINGS_MANAGER);
    }

    function _recollateraliser() internal view returns (address) {

        return nexus.getModule(KEY_RECOLLATERALISER);
    }
}

contract InitializableReentrancyGuard {

    bool private _notEntered;

    function _initialize() internal {

        _notEntered = true;
    }

    modifier nonReentrant() {

        require(_notEntered, "ReentrancyGuard: reentrant call");

        _notEntered = false;

        _;

        _notEntered = true;
    }
}

library StableMath {


    using SafeMath for uint256;

    uint256 private constant FULL_SCALE = 1e18;

    uint256 private constant RATIO_SCALE = 1e8;

    function getFullScale() internal pure returns (uint256) {

        return FULL_SCALE;
    }

    function getRatioScale() internal pure returns (uint256) {

        return RATIO_SCALE;
    }

    function scaleInteger(uint256 x)
        internal
        pure
        returns (uint256)
    {

        return x.mul(FULL_SCALE);
    }


    function mulTruncate(uint256 x, uint256 y)
        internal
        pure
        returns (uint256)
    {

        return mulTruncateScale(x, y, FULL_SCALE);
    }

    function mulTruncateScale(uint256 x, uint256 y, uint256 scale)
        internal
        pure
        returns (uint256)
    {

        uint256 z = x.mul(y);
        return z.div(scale);
    }

    function mulTruncateCeil(uint256 x, uint256 y)
        internal
        pure
        returns (uint256)
    {

        uint256 scaled = x.mul(y);
        uint256 ceil = scaled.add(FULL_SCALE.sub(1));
        return ceil.div(FULL_SCALE);
    }

    function divPrecisely(uint256 x, uint256 y)
        internal
        pure
        returns (uint256)
    {

        uint256 z = x.mul(FULL_SCALE);
        return z.div(y);
    }



    function mulRatioTruncate(uint256 x, uint256 ratio)
        internal
        pure
        returns (uint256 c)
    {

        return mulTruncateScale(x, ratio, RATIO_SCALE);
    }

    function mulRatioTruncateCeil(uint256 x, uint256 ratio)
        internal
        pure
        returns (uint256)
    {

        uint256 scaled = x.mul(ratio);
        uint256 ceil = scaled.add(RATIO_SCALE.sub(1));
        return ceil.div(RATIO_SCALE);
    }


    function divRatioPrecisely(uint256 x, uint256 ratio)
        internal
        pure
        returns (uint256 c)
    {

        uint256 y = x.mul(RATIO_SCALE);
        return y.div(ratio);
    }


    function min(uint256 x, uint256 y)
        internal
        pure
        returns (uint256)
    {

        return x > y ? y : x;
    }

    function max(uint256 x, uint256 y)
        internal
        pure
        returns (uint256)
    {

        return x > y ? x : y;
    }

    function clamp(uint256 x, uint256 upperBound)
        internal
        pure
        returns (uint256)
    {

        return x > upperBound ? upperBound : x;
    }
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

library MassetHelpers {


    using StableMath for uint256;
    using SafeMath for uint256;
    using SafeERC20 for IERC20;


    function transferReturnBalance(
        address _sender,
        address _recipient,
        address _basset,
        uint256 _qty
    )
        internal
        returns (uint256 receivedQty, uint256 recipientBalance)
    {

        uint256 balBefore = IERC20(_basset).balanceOf(_recipient);
        IERC20(_basset).safeTransferFrom(_sender, _recipient, _qty);
        recipientBalance = IERC20(_basset).balanceOf(_recipient);
        receivedQty = StableMath.min(_qty, recipientBalance.sub(balBefore));
    }

    function safeInfiniteApprove(address _asset, address _spender)
        internal
    {

        IERC20(_asset).safeApprove(_spender, 0);
        IERC20(_asset).safeApprove(_spender, uint256(-1));
    }
}

contract Masset is
    Initializable,
    IMasset,
    InitializableToken,
    InitializableModule,
    InitializableReentrancyGuard
{

    using StableMath for uint256;

    event Minted(address indexed minter, address recipient, uint256 mAssetQuantity, address bAsset, uint256 bAssetQuantity);
    event MintedMulti(address indexed minter, address recipient, uint256 mAssetQuantity, address[] bAssets, uint256[] bAssetQuantities);
    event Swapped(address indexed swapper, address input, address output, uint256 outputAmount, address recipient);
    event Redeemed(address indexed redeemer, address recipient, uint256 mAssetQuantity, address[] bAssets, uint256[] bAssetQuantities);
    event RedeemedMasset(address indexed redeemer, address recipient, uint256 mAssetQuantity);
    event PaidFee(address indexed payer, address asset, uint256 feeQuantity);

    event CacheSizeChanged(uint256 cacheSize);
    event SwapFeeChanged(uint256 fee);
    event RedemptionFeeChanged(uint256 fee);
    event ForgeValidatorChanged(address forgeValidator);

    IForgeValidator public forgeValidator;
    bool private forgeValidatorLocked;
    IBasketManager private basketManager;

    uint256 public swapFee;
    uint256 private MAX_FEE;

    uint256 public redemptionFee;

    uint256 public cacheSize;
    uint256 public surplus;

    function initialize(
        string calldata _nameArg,
        string calldata _symbolArg,
        address _nexus,
        address _forgeValidator,
        address _basketManager
    )
        external
        initializer
    {

        InitializableToken._initialize(_nameArg, _symbolArg);
        InitializableModule._initialize(_nexus);
        InitializableReentrancyGuard._initialize();

        forgeValidator = IForgeValidator(_forgeValidator);

        basketManager = IBasketManager(_basketManager);

        MAX_FEE = 2e16;
        swapFee = 6e14;
        redemptionFee = 3e14;
        cacheSize = 1e17;
    }

    modifier onlySavingsManager() {

        require(_savingsManager() == msg.sender, "Must be savings manager");
        _;
    }



    function mint(
        address _bAsset,
        uint256 _bAssetQuantity
    )
        external
        nonReentrant
        returns (uint256 massetMinted)
    {

        return _mintTo(_bAsset, _bAssetQuantity, msg.sender);
    }

    function mintTo(
        address _bAsset,
        uint256 _bAssetQuantity,
        address _recipient
    )
        external
        nonReentrant
        returns (uint256 massetMinted)
    {

        return _mintTo(_bAsset, _bAssetQuantity, _recipient);
    }

    function mintMulti(
        address[] calldata _bAssets,
        uint256[] calldata _bAssetQuantity,
        address _recipient
    )
        external
        nonReentrant
        returns(uint256 massetMinted)
    {

        return _mintTo(_bAssets, _bAssetQuantity, _recipient);
    }


    function _mintTo(
        address _bAsset,
        uint256 _bAssetQuantity,
        address _recipient
    )
        internal
        returns (uint256 massetMinted)
    {

        require(_recipient != address(0), "Must be a valid recipient");
        require(_bAssetQuantity > 0, "Quantity must not be 0");

        (bool isValid, BassetDetails memory bInfo) = basketManager.prepareForgeBasset(_bAsset, _bAssetQuantity, true);
        if(!isValid) return 0;

        Cache memory cache = _getCacheDetails();

        address integrator = bInfo.integrator;
        (uint256 quantityDeposited, uint256 ratioedDeposit) =
            _depositTokens(_bAsset, bInfo.bAsset.ratio, integrator, bInfo.bAsset.isTransferFeeCharged, _bAssetQuantity, cache.maxCache);

        (bool mintValid, string memory reason) = forgeValidator.validateMint(cache.vaultBalanceSum, bInfo.bAsset, quantityDeposited);
        require(mintValid, reason);

        basketManager.increaseVaultBalance(bInfo.index, integrator, quantityDeposited);

        _mint(_recipient, ratioedDeposit);
        emit Minted(msg.sender, _recipient, ratioedDeposit, _bAsset, quantityDeposited);

        return ratioedDeposit;
    }

    function _mintTo(
        address[] memory _bAssets,
        uint256[] memory _bAssetQuantities,
        address _recipient
    )
        internal
        returns (uint256 massetMinted)
    {

        require(_recipient != address(0), "Must be a valid recipient");
        uint256 len = _bAssetQuantities.length;
        require(len > 0 && len == _bAssets.length, "Input array mismatch");

        ForgePropsMulti memory props
            = basketManager.prepareForgeBassets(_bAssets, _bAssetQuantities, true);
        if(!props.isValid) return 0;

        Cache memory cache = _getCacheDetails();

        uint256 mAssetQuantity = 0;
        uint256[] memory receivedQty = new uint256[](len);

        for(uint256 i = 0; i < len; i++){
            uint256 bAssetQuantity = _bAssetQuantities[i];
            if(bAssetQuantity > 0){
                Basset memory bAsset = props.bAssets[i];

                (uint256 quantityDeposited, uint256 ratioedDeposit) =
                    _depositTokens(bAsset.addr, bAsset.ratio, props.integrators[i], bAsset.isTransferFeeCharged, bAssetQuantity, cache.maxCache);

                receivedQty[i] = quantityDeposited;
                mAssetQuantity = mAssetQuantity.add(ratioedDeposit);
            }
        }
        require(mAssetQuantity > 0, "No masset quantity to mint");

        basketManager.increaseVaultBalances(props.indexes, props.integrators, receivedQty);

        (bool mintValid, string memory reason) = forgeValidator.validateMintMulti(cache.vaultBalanceSum, props.bAssets, receivedQty);
        require(mintValid, reason);

        _mint(_recipient, mAssetQuantity);
        emit MintedMulti(msg.sender, _recipient, mAssetQuantity, _bAssets, _bAssetQuantities);

        return mAssetQuantity;
    }

    function _depositTokens(
        address _bAsset,
        uint256 _bAssetRatio,
        address _integrator,
        bool _hasTxFee,
        uint256 _quantity,
        uint256 _maxCache
    )
        internal
        returns (uint256 quantityDeposited, uint256 ratioedDeposit)
    {

        (uint256 transferred, uint256 cacheBal) = MassetHelpers.transferReturnBalance(msg.sender, _integrator, _bAsset, _quantity);

        if(_hasTxFee){
            uint256 deposited = IPlatformIntegration(_integrator).deposit(_bAsset, transferred, true);
            quantityDeposited = StableMath.min(deposited, _quantity);
        }
        else {
            require(transferred == _quantity, "Asset not fully transferred");

            quantityDeposited = transferred;

            uint256 relativeMaxCache = _maxCache.divRatioPrecisely(_bAssetRatio);

            if(cacheBal > relativeMaxCache){
                uint256 delta = cacheBal.sub(relativeMaxCache.div(2));
                IPlatformIntegration(_integrator).deposit(_bAsset, delta, false);
            }
        }

        ratioedDeposit = quantityDeposited.mulRatioTruncate(_bAssetRatio);
    }


    struct SwapArgs {
        address input;
        address output;
        address recipient;
    }

    function swap(
        address _input,
        address _output,
        uint256 _quantity,
        address _recipient
    )
        external
        nonReentrant
        returns (uint256 output)
    {

        SwapArgs memory args = SwapArgs(_input, _output, _recipient);
        require(args.input != address(0) && args.output != address(0), "Invalid swap asset addresses");
        require(args.input != args.output, "Cannot swap the same asset");
        require(args.recipient != address(0), "Missing recipient address");
        require(_quantity > 0, "Invalid quantity");

        if(args.output == address(this)){
            return _mintTo(args.input, _quantity, args.recipient);
        }

        (bool isValid, string memory reason, BassetDetails memory inputDetails, BassetDetails memory outputDetails) =
            basketManager.prepareSwapBassets(args.input, args.output, false);
        require(isValid, reason);

        Cache memory cache = _getCacheDetails();

        (uint256 amnountIn, ) =
            _depositTokens(args.input, inputDetails.bAsset.ratio, inputDetails.integrator, inputDetails.bAsset.isTransferFeeCharged, _quantity, cache.maxCache);
        basketManager.increaseVaultBalance(inputDetails.index, inputDetails.integrator, amnountIn);

        (bool swapValid, string memory swapValidityReason, uint256 swapOutput, bool applySwapFee) =
            forgeValidator.validateSwap(cache.vaultBalanceSum, inputDetails.bAsset, outputDetails.bAsset, amnountIn);
        require(swapValid, swapValidityReason);
        require(swapOutput > 0, "Must withdraw something");

        address recipient = args.recipient;
        Amount memory amt = _withdrawTokens(
            WithdrawArgs({
                quantity: swapOutput,
                bAsset: args.output,
                integrator: outputDetails.integrator,
                feeRate: applySwapFee ? swapFee : 0,
                hasTxFee: outputDetails.bAsset.isTransferFeeCharged,
                recipient: recipient,
                ratio: outputDetails.bAsset.ratio,
                maxCache: cache.maxCache,
                vaultBalance: outputDetails.bAsset.vaultBalance
            })
        );

        basketManager.decreaseVaultBalance(outputDetails.index, outputDetails.integrator, amt.net);

        surplus = cache.surplus.add(amt.scaledFee);

        emit Swapped(msg.sender, args.input, args.output, amt.net, recipient);

        return amt.net;
    }

    function getSwapOutput(
        address _input,
        address _output,
        uint256 _quantity
    )
        external
        view
        returns (bool, string memory, uint256 output)
    {

        require(_input != address(0) && _output != address(0), "Invalid swap asset addresses");
        require(_input != _output, "Cannot swap the same asset");

        bool isMint = _output == address(this);
        uint256 quantity = _quantity;

        (bool isValid, string memory reason, BassetDetails memory inputDetails, BassetDetails memory outputDetails) =
            basketManager.prepareSwapBassets(_input, _output, isMint);
        if(!isValid){
            return (false, reason, 0);
        }

        Cache memory cache = _getCacheDetails();

        if(isMint){
            (isValid, reason) = forgeValidator.validateMint(cache.vaultBalanceSum, inputDetails.bAsset, quantity);
            if(!isValid) return (false, reason, 0);
            output = quantity.mulRatioTruncate(inputDetails.bAsset.ratio);
            return(true, "", output);
        }
        else {
            (bool swapValid, string memory swapValidityReason, uint256 swapOutput, bool applySwapFee) =
                forgeValidator.validateSwap(cache.vaultBalanceSum, inputDetails.bAsset, outputDetails.bAsset, quantity);
            if(!swapValid){
                return (false, swapValidityReason, 0);
            }

            if(applySwapFee){
                (, swapOutput) = _calcSwapFee(swapOutput, swapFee);
            }
            return (true, "", swapOutput);
        }
    }



    function redeem(
        address _bAsset,
        uint256 _bAssetQuantity
    )
        external
        nonReentrant
        returns (uint256 massetRedeemed)
    {

        return _redeemTo(_bAsset, _bAssetQuantity, msg.sender);
    }

    function redeemTo(
        address _bAsset,
        uint256 _bAssetQuantity,
        address _recipient
    )
        external
        nonReentrant
        returns (uint256 massetRedeemed)
    {

        return _redeemTo(_bAsset, _bAssetQuantity, _recipient);
    }

    function redeemMulti(
        address[] calldata _bAssets,
        uint256[] calldata _bAssetQuantities,
        address _recipient
    )
        external
        nonReentrant
        returns (uint256 massetRedeemed)
    {

        return _redeemTo(_bAssets, _bAssetQuantities, _recipient);
    }

    function redeemMasset(
        uint256 _mAssetQuantity,
        address _recipient
    )
        external
        nonReentrant
    {

        _redeemMasset(_mAssetQuantity, _recipient);
    }


    function _redeemTo(
        address _bAsset,
        uint256 _bAssetQuantity,
        address _recipient
    )
        internal
        returns (uint256 massetRedeemed)
    {

        address[] memory bAssets = new address[](1);
        uint256[] memory quantities = new uint256[](1);
        bAssets[0] = _bAsset;
        quantities[0] = _bAssetQuantity;
        return _redeemTo(bAssets, quantities, _recipient);
    }

    function _redeemTo(
        address[] memory _bAssets,
        uint256[] memory _bAssetQuantities,
        address _recipient
    )
        internal
        returns (uint256 massetRedeemed)
    {

        require(_recipient != address(0), "Must be a valid recipient");
        uint256 bAssetCount = _bAssetQuantities.length;
        require(bAssetCount > 0 && bAssetCount == _bAssets.length, "Input array mismatch");

        RedeemProps memory props = basketManager.prepareRedeemBassets(_bAssets);
        if(!props.isValid) return 0;

        Cache memory cache = _getCacheDetails();

        (bool redemptionValid, string memory reason, bool applyFee) =
            forgeValidator.validateRedemption(false, cache.vaultBalanceSum, props.allBassets, props.indexes, _bAssetQuantities);
        require(redemptionValid, reason);

        uint256 mAssetQuantity = 0;

        for(uint256 i = 0; i < bAssetCount; i++){
            uint256 bAssetQuantity = _bAssetQuantities[i];
            if(bAssetQuantity > 0){
                uint256 ratioedBasset = bAssetQuantity.mulRatioTruncateCeil(props.bAssets[i].ratio);
                mAssetQuantity = mAssetQuantity.add(ratioedBasset);
            }
        }
        require(mAssetQuantity > 0, "Must redeem some bAssets");

        uint256 fee = applyFee ? swapFee : 0;

        _settleRedemption(
            RedemptionSettlement({
                recipient: _recipient,
                mAssetQuantity: mAssetQuantity,
                bAssetQuantities: _bAssetQuantities,
                indices: props.indexes,
                integrators: props.integrators,
                feeRate: fee,
                bAssets: props.bAssets,
                cache: cache
            })
        );

        emit Redeemed(msg.sender, _recipient, mAssetQuantity, _bAssets, _bAssetQuantities);
        return mAssetQuantity;
    }


    function _redeemMasset(
        uint256 _mAssetQuantity,
        address _recipient
    )
        internal
    {

        require(_recipient != address(0), "Must be a valid recipient");
        require(_mAssetQuantity > 0, "Invalid redemption quantity");

        RedeemPropsMulti memory props = basketManager.prepareRedeemMulti();
        uint256 colRatio = StableMath.min(props.colRatio, StableMath.getFullScale());

        uint256 collateralisedMassetQuantity = _mAssetQuantity.mulTruncate(colRatio);

        (bool redemptionValid, string memory reason, uint256[] memory bAssetQuantities) =
            forgeValidator.calculateRedemptionMulti(collateralisedMassetQuantity, props.bAssets);
        require(redemptionValid, reason);

        _settleRedemption(
            RedemptionSettlement({
                recipient: _recipient,
                mAssetQuantity: _mAssetQuantity,
                bAssetQuantities: bAssetQuantities,
                indices: props.indexes,
                integrators: props.integrators,
                feeRate: redemptionFee,
                bAssets: props.bAssets,
                cache: _getCacheDetails()
            })
        );

        emit RedeemedMasset(msg.sender, _recipient, _mAssetQuantity);
    }

    struct RedemptionSettlement {
        address recipient;
        uint256 mAssetQuantity;
        uint256[] bAssetQuantities;
        uint8[] indices;
        address[] integrators;
        uint256 feeRate;
        Basset[] bAssets;
        Cache cache;
    }

    function _settleRedemption(
        RedemptionSettlement memory args
    ) internal {

        _burn(msg.sender, args.mAssetQuantity);

        uint256 bAssetCount = args.bAssets.length;
        uint256[] memory netAmounts = new uint256[](bAssetCount);
        uint256 fees = 0;
        for(uint256 i = 0; i < bAssetCount; i++){
            Amount memory amt = _withdrawTokens(
                WithdrawArgs({
                    quantity: args.bAssetQuantities[i],
                    bAsset: args.bAssets[i].addr,
                    integrator: args.integrators[i],
                    feeRate: args.feeRate,
                    hasTxFee: args.bAssets[i].isTransferFeeCharged,
                    recipient: args.recipient,
                    ratio: args.bAssets[i].ratio,
                    maxCache: args.cache.maxCache,
                    vaultBalance: args.bAssets[i].vaultBalance
                })
            );
            netAmounts[i] = amt.net;
            fees = fees.add(amt.scaledFee);
        }
        surplus = args.cache.surplus.add(fees);

        basketManager.decreaseVaultBalances(args.indices, args.integrators, netAmounts);
    }

    struct WithdrawArgs {
        uint256 quantity;
        address bAsset;
        address integrator;
        uint256 feeRate;
        bool hasTxFee;
        address recipient;
        uint256 ratio;
        uint256 maxCache;
        uint256 vaultBalance;
    }

    function _withdrawTokens(WithdrawArgs memory args) internal returns (Amount memory amount) {

        if(args.quantity > 0){

            amount = _deductSwapFee(args.bAsset, args.quantity, args.feeRate, args.ratio);

            if(args.hasTxFee){
                IPlatformIntegration(args.integrator).withdraw(args.recipient, args.bAsset, amount.net, amount.net, true);
            }
            else {
                uint256 cacheBal = IERC20(args.bAsset).balanceOf(args.integrator);
                if(cacheBal >= amount.net) {
                    IPlatformIntegration(args.integrator).withdrawRaw(args.recipient, args.bAsset, amount.net);
                }
                else {
                    uint256 relativeMidCache = args.maxCache.divRatioPrecisely(args.ratio).div(2);
                    uint256 totalWithdrawal = StableMath.min(relativeMidCache.add(amount.net).sub(cacheBal), args.vaultBalance.sub(cacheBal));

                    IPlatformIntegration(args.integrator).withdraw(
                        args.recipient,
                        args.bAsset,
                        amount.net,
                        totalWithdrawal,
                        false
                    );
                }
            }
        }
    }



    struct Amount {
        uint256 gross;
        uint256 net;
        uint256 scaledFee;
    }

    function _deductSwapFee(address _asset, uint256 _bAssetQuantity, uint256 _feeRate, uint256 _ratio)
        private
        returns (Amount memory)
    {

        if(_feeRate > 0){
            (uint256 fee, uint256 output) = _calcSwapFee(_bAssetQuantity, _feeRate);

            emit PaidFee(msg.sender, _asset, fee);

            return Amount(_bAssetQuantity, output, fee.mulRatioTruncate(_ratio));
        }
        return Amount(_bAssetQuantity, _bAssetQuantity, 0);
    }

    function _calcSwapFee(uint256 _bAssetQuantity, uint256 _feeRate)
        private
        pure
        returns (uint256 feeAmount, uint256 outputMinusFee)
    {

        feeAmount = _bAssetQuantity.mulTruncate(_feeRate);
        outputMinusFee = _bAssetQuantity.sub(feeAmount);
    }

    struct Cache {
        uint256 vaultBalanceSum;
        uint256 maxCache;
        uint256 surplus;
    }

    function _getCacheDetails() internal view returns (Cache memory) {

        uint256 _surplus = surplus;
        uint256 sum = totalSupply().add(_surplus);
        return Cache(sum, sum.mulTruncate(cacheSize), _surplus);
    }


    function setCacheSize(uint256 _cacheSize)
        external
        onlyGovernance
    {

        require(_cacheSize <= 2e17, "Must be <= 20%");

        cacheSize = _cacheSize;

        emit CacheSizeChanged(_cacheSize);
    }


    function upgradeForgeValidator(address _newForgeValidator)
        external
        onlyGovernor
    {

        require(!forgeValidatorLocked, "Must be allowed to upgrade");
        require(_newForgeValidator != address(0), "Must be non null address");
        forgeValidator = IForgeValidator(_newForgeValidator);
        emit ForgeValidatorChanged(_newForgeValidator);
    }

    function lockForgeValidator()
        external
        onlyGovernor
    {

        forgeValidatorLocked = true;
    }

    function setSwapFee(uint256 _swapFee)
        external
        onlyGovernor
    {

        require(_swapFee <= MAX_FEE, "Rate must be within bounds");
        swapFee = _swapFee;

        emit SwapFeeChanged(_swapFee);
    }

    function setRedemptionFee(uint256 _redemptionFee)
        external
        onlyGovernor
    {

        require(_redemptionFee <= MAX_FEE, "Rate must be within bounds");
        redemptionFee = _redemptionFee;

        emit RedemptionFeeChanged(_redemptionFee);
    }

    function getBasketManager()
        external
        view
        returns (address)
    {

        return address(basketManager);
    }


    function collectInterest()
        external
        onlySavingsManager
        nonReentrant
        returns (uint256 swapFeesGained, uint256 newSupply)
    {

        uint256 toMint = 0;
        if(surplus > 1){
            toMint = surplus.sub(1);
            surplus = 1;

            _mint(msg.sender, toMint);
            emit MintedMulti(address(this), address(this), toMint, new address[](0), new uint256[](0));
        }

        return (toMint, totalSupply());
    }

    function collectPlatformInterest()
        external
        onlySavingsManager
        nonReentrant
        returns (uint256 interestGained, uint256 newSupply)
    {

        (uint256 interestCollected, uint256[] memory gains) = basketManager.collectInterest();

        _mint(msg.sender, interestCollected);
        emit MintedMulti(address(this), address(this), interestCollected, new address[](0), gains);

        return (interestCollected, totalSupply());
    }
}