

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


pragma solidity 0.5.11;

interface IStrategy {

    function deposit(address _asset, uint256 _amount) external;


    function withdraw(
        address _recipient,
        address _asset,
        uint256 _amount
    ) external;


    function withdrawAll() external;


    function checkBalance(address _asset)
        external
        view
        returns (uint256 balance);


    function supportsAsset(address _asset) external view returns (bool);


    function collectRewardToken() external;


    function rewardTokenAddress() external pure returns (address);


    function rewardLiquidationThreshold() external pure returns (uint256);

}


pragma solidity 0.5.11;

contract Governable {

    bytes32
        private constant governorPosition = 0x7bea13895fa79d2831e0a9e28edede30099005a50d652d8957cf8a607ee6ca4a;

    bytes32
        private constant pendingGovernorPosition = 0x44c4d30b2eaad5130ad70c3ba6972730566f3e6359ab83e800d905c61b1c51db;

    bytes32
        private constant reentryStatusPosition = 0x53bf423e48ed90e97d02ab0ebab13b2a235a6bfbe9c321847d5c175333ac4535;

    uint256 constant _NOT_ENTERED = 1;
    uint256 constant _ENTERED = 2;

    event PendingGovernorshipTransfer(
        address indexed previousGovernor,
        address indexed newGovernor
    );

    event GovernorshipTransferred(
        address indexed previousGovernor,
        address indexed newGovernor
    );

    constructor() internal {
        _setGovernor(msg.sender);
        emit GovernorshipTransferred(address(0), _governor());
    }

    function governor() public view returns (address) {

        return _governor();
    }

    function _governor() internal view returns (address governorOut) {

        bytes32 position = governorPosition;
        assembly {
            governorOut := sload(position)
        }
    }

    function _pendingGovernor()
        internal
        view
        returns (address pendingGovernor)
    {

        bytes32 position = pendingGovernorPosition;
        assembly {
            pendingGovernor := sload(position)
        }
    }

    modifier onlyGovernor() {

        require(isGovernor(), "Caller is not the Governor");
        _;
    }

    function isGovernor() public view returns (bool) {

        return msg.sender == _governor();
    }

    function _setGovernor(address newGovernor) internal {

        bytes32 position = governorPosition;
        assembly {
            sstore(position, newGovernor)
        }
    }

    modifier nonReentrant() {

        bytes32 position = reentryStatusPosition;
        uint256 _reentry_status;
        assembly {
            _reentry_status := sload(position)
        }

        require(_reentry_status != _ENTERED, "Reentrant call");

        assembly {
            sstore(position, _ENTERED)
        }

        _;

        assembly {
            sstore(position, _NOT_ENTERED)
        }
    }

    function _setPendingGovernor(address newGovernor) internal {

        bytes32 position = pendingGovernorPosition;
        assembly {
            sstore(position, newGovernor)
        }
    }

    function transferGovernance(address _newGovernor) external onlyGovernor {

        _setPendingGovernor(_newGovernor);
        emit PendingGovernorshipTransfer(_governor(), _newGovernor);
    }

    function claimGovernance() external {

        require(
            msg.sender == _pendingGovernor(),
            "Only the pending Governor can complete the claim"
        );
        _changeGovernor(msg.sender);
    }

    function _changeGovernor(address _newGovernor) internal {

        require(_newGovernor != address(0), "New Governor is address(0)");
        emit GovernorshipTransferred(_governor(), _newGovernor);
        _setGovernor(_newGovernor);
    }
}


pragma solidity 0.5.11;

contract InitializableERC20Detailed is IERC20 {

    uint256[100] private _____gap;

    string private _name;
    string private _symbol;
    uint8 private _decimals;

    function _initialize(
        string memory nameArg,
        string memory symbolArg,
        uint8 decimalsArg
    ) internal {

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


pragma solidity 0.5.11;


library StableMath {

    using SafeMath for uint256;

    uint256 private constant FULL_SCALE = 1e18;


    function scaleBy(uint256 x, int8 adjustment)
        internal
        pure
        returns (uint256)
    {

        if (adjustment > 0) {
            x = x.mul(10**uint256(adjustment));
        } else if (adjustment < 0) {
            x = x.div(10**uint256(adjustment * -1));
        }
        return x;
    }


    function mulTruncate(uint256 x, uint256 y) internal pure returns (uint256) {

        return mulTruncateScale(x, y, FULL_SCALE);
    }

    function mulTruncateScale(
        uint256 x,
        uint256 y,
        uint256 scale
    ) internal pure returns (uint256) {

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
}


pragma solidity 0.5.11;







contract OUSD is Initializable, InitializableERC20Detailed, Governable {

    using SafeMath for uint256;
    using StableMath for uint256;

    event TotalSupplyUpdated(
        uint256 totalSupply,
        uint256 rebasingCredits,
        uint256 rebasingCreditsPerToken
    );

    enum RebaseOptions { NotSet, OptOut, OptIn }

    uint256 private constant MAX_SUPPLY = ~uint128(0); // (2^128) - 1
    uint256 public _totalSupply;
    mapping(address => mapping(address => uint256)) private _allowances;
    address public vaultAddress = address(0);
    mapping(address => uint256) private _creditBalances;
    uint256 public rebasingCredits;
    uint256 public rebasingCreditsPerToken;
    uint256 public nonRebasingSupply;
    mapping(address => uint256) public nonRebasingCreditsPerToken;
    mapping(address => RebaseOptions) public rebaseState;

    function initialize(
        string calldata _nameArg,
        string calldata _symbolArg,
        address _vaultAddress
    ) external onlyGovernor initializer {

        InitializableERC20Detailed._initialize(_nameArg, _symbolArg, 18);
        rebasingCreditsPerToken = 1e18;
        vaultAddress = _vaultAddress;
    }

    modifier onlyVault() {

        require(vaultAddress == msg.sender, "Caller is not the Vault");
        _;
    }

    function totalSupply() public view returns (uint256) {

        return _totalSupply;
    }

    function balanceOf(address _account) public view returns (uint256) {

        if (_creditBalances[_account] == 0) return 0;
        return
            _creditBalances[_account].divPrecisely(_creditsPerToken(_account));
    }

    function creditsBalanceOf(address _account)
        public
        view
        returns (uint256, uint256)
    {

        return (_creditBalances[_account], _creditsPerToken(_account));
    }

    function transfer(address _to, uint256 _value) public returns (bool) {

        require(_to != address(0), "Transfer to zero address");
        require(
            _value <= balanceOf(msg.sender),
            "Transfer greater than balance"
        );

        _executeTransfer(msg.sender, _to, _value);

        emit Transfer(msg.sender, _to, _value);

        return true;
    }

    function transferFrom(
        address _from,
        address _to,
        uint256 _value
    ) public returns (bool) {

        require(_to != address(0), "Transfer to zero address");
        require(_value <= balanceOf(_from), "Transfer greater than balance");

        _allowances[_from][msg.sender] = _allowances[_from][msg.sender].sub(
            _value
        );

        _executeTransfer(_from, _to, _value);

        emit Transfer(_from, _to, _value);

        return true;
    }

    function _executeTransfer(
        address _from,
        address _to,
        uint256 _value
    ) internal {

        bool isNonRebasingTo = _isNonRebasingAccount(_to);
        bool isNonRebasingFrom = _isNonRebasingAccount(_from);

        uint256 creditsCredited = _value.mulTruncate(_creditsPerToken(_to));
        uint256 creditsDeducted = _value.mulTruncate(_creditsPerToken(_from));

        _creditBalances[_from] = _creditBalances[_from].sub(
            creditsDeducted,
            "Transfer amount exceeds balance"
        );
        _creditBalances[_to] = _creditBalances[_to].add(creditsCredited);

        if (isNonRebasingTo && !isNonRebasingFrom) {
            nonRebasingSupply = nonRebasingSupply.add(_value);
            rebasingCredits = rebasingCredits.sub(creditsDeducted);
        } else if (!isNonRebasingTo && isNonRebasingFrom) {
            nonRebasingSupply = nonRebasingSupply.sub(_value);
            rebasingCredits = rebasingCredits.add(creditsCredited);
        }
    }

    function allowance(address _owner, address _spender)
        public
        view
        returns (uint256)
    {

        return _allowances[_owner][_spender];
    }

    function approve(address _spender, uint256 _value) public returns (bool) {

        _allowances[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        return true;
    }

    function increaseAllowance(address _spender, uint256 _addedValue)
        public
        returns (bool)
    {

        _allowances[msg.sender][_spender] = _allowances[msg.sender][_spender]
            .add(_addedValue);
        emit Approval(msg.sender, _spender, _allowances[msg.sender][_spender]);
        return true;
    }

    function decreaseAllowance(address _spender, uint256 _subtractedValue)
        public
        returns (bool)
    {

        uint256 oldValue = _allowances[msg.sender][_spender];
        if (_subtractedValue >= oldValue) {
            _allowances[msg.sender][_spender] = 0;
        } else {
            _allowances[msg.sender][_spender] = oldValue.sub(_subtractedValue);
        }
        emit Approval(msg.sender, _spender, _allowances[msg.sender][_spender]);
        return true;
    }

    function mint(address _account, uint256 _amount) external onlyVault {

        _mint(_account, _amount);
    }

    function _mint(address _account, uint256 _amount) internal nonReentrant {

        require(_account != address(0), "Mint to the zero address");

        bool isNonRebasingAccount = _isNonRebasingAccount(_account);

        uint256 creditAmount = _amount.mulTruncate(_creditsPerToken(_account));
        _creditBalances[_account] = _creditBalances[_account].add(creditAmount);

        if (isNonRebasingAccount) {
            nonRebasingSupply = nonRebasingSupply.add(_amount);
        } else {
            rebasingCredits = rebasingCredits.add(creditAmount);
        }

        _totalSupply = _totalSupply.add(_amount);

        require(_totalSupply < MAX_SUPPLY, "Max supply");

        emit Transfer(address(0), _account, _amount);
    }

    function burn(address account, uint256 amount) external onlyVault {

        _burn(account, amount);
    }

    function _burn(address _account, uint256 _amount) internal nonReentrant {

        require(_account != address(0), "Burn from the zero address");
        if (_amount == 0) {
            return;
        }

        bool isNonRebasingAccount = _isNonRebasingAccount(_account);
        uint256 creditAmount = _amount.mulTruncate(_creditsPerToken(_account));
        uint256 currentCredits = _creditBalances[_account];

        if (
            currentCredits == creditAmount || currentCredits - 1 == creditAmount
        ) {
            _creditBalances[_account] = 0;
        } else if (currentCredits > creditAmount) {
            _creditBalances[_account] = _creditBalances[_account].sub(
                creditAmount
            );
        } else {
            revert("Remove exceeds balance");
        }

        if (isNonRebasingAccount) {
            nonRebasingSupply = nonRebasingSupply.sub(_amount);
        } else {
            rebasingCredits = rebasingCredits.sub(creditAmount);
        }

        _totalSupply = _totalSupply.sub(_amount);

        emit Transfer(_account, address(0), _amount);
    }

    function _creditsPerToken(address _account)
        internal
        view
        returns (uint256)
    {

        if (nonRebasingCreditsPerToken[_account] != 0) {
            return nonRebasingCreditsPerToken[_account];
        } else {
            return rebasingCreditsPerToken;
        }
    }

    function _isNonRebasingAccount(address _account) internal returns (bool) {

        bool isContract = Address.isContract(_account);
        if (isContract && rebaseState[_account] == RebaseOptions.NotSet) {
            _ensureRebasingMigration(_account);
        }
        return nonRebasingCreditsPerToken[_account] > 0;
    }

    function _ensureRebasingMigration(address _account) internal {

        if (nonRebasingCreditsPerToken[_account] == 0) {
            nonRebasingCreditsPerToken[_account] = rebasingCreditsPerToken;
            nonRebasingSupply = nonRebasingSupply.add(balanceOf(_account));
            rebasingCredits = rebasingCredits.sub(_creditBalances[_account]);
        }
    }

    function rebaseOptIn() public nonReentrant {

        require(_isNonRebasingAccount(msg.sender), "Account has not opted out");

        uint256 newCreditBalance = _creditBalances[msg.sender]
            .mul(rebasingCreditsPerToken)
            .div(_creditsPerToken(msg.sender));

        nonRebasingSupply = nonRebasingSupply.sub(balanceOf(msg.sender));

        _creditBalances[msg.sender] = newCreditBalance;

        rebasingCredits = rebasingCredits.add(_creditBalances[msg.sender]);

        rebaseState[msg.sender] = RebaseOptions.OptIn;

        delete nonRebasingCreditsPerToken[msg.sender];
    }

    function rebaseOptOut() public nonReentrant {

        require(!_isNonRebasingAccount(msg.sender), "Account has not opted in");

        nonRebasingSupply = nonRebasingSupply.add(balanceOf(msg.sender));
        nonRebasingCreditsPerToken[msg.sender] = rebasingCreditsPerToken;

        rebasingCredits = rebasingCredits.sub(_creditBalances[msg.sender]);

        rebaseState[msg.sender] = RebaseOptions.OptOut;
    }

    function changeSupply(uint256 _newTotalSupply)
        external
        onlyVault
        nonReentrant
    {

        require(_totalSupply > 0, "Cannot increase 0 supply");

        if (_totalSupply == _newTotalSupply) {
            emit TotalSupplyUpdated(
                _totalSupply,
                rebasingCredits,
                rebasingCreditsPerToken
            );
            return;
        }

        _totalSupply = _newTotalSupply > MAX_SUPPLY
            ? MAX_SUPPLY
            : _newTotalSupply;

        rebasingCreditsPerToken = rebasingCredits.divPrecisely(
            _totalSupply.sub(nonRebasingSupply)
        );

        require(rebasingCreditsPerToken > 0, "Invalid change in supply");

        _totalSupply = rebasingCredits
            .divPrecisely(rebasingCreditsPerToken)
            .add(nonRebasingSupply);

        emit TotalSupplyUpdated(
            _totalSupply,
            rebasingCredits,
            rebasingCreditsPerToken
        );
    }
}


pragma solidity 0.5.11;

interface IBasicToken {

    function symbol() external view returns (string memory);


    function decimals() external view returns (uint8);

}


pragma solidity 0.5.11;

library Helpers {

    function getSymbol(address _token) internal view returns (string memory) {

        string memory symbol = IBasicToken(_token).symbol();
        return symbol;
    }

    function getDecimals(address _token) internal view returns (uint256) {

        uint256 decimals = IBasicToken(_token).decimals();
        require(
            decimals >= 4 && decimals <= 18,
            "Token must have sufficient decimal places"
        );

        return decimals;
    }
}


pragma solidity 0.5.11;










contract VaultStorage is Initializable, Governable {

    using SafeMath for uint256;
    using StableMath for uint256;
    using SafeMath for int256;
    using SafeERC20 for IERC20;

    event AssetSupported(address _asset);
    event AssetDefaultStrategyUpdated(address _asset, address _strategy);
    event StrategyApproved(address _addr);
    event StrategyRemoved(address _addr);
    event Mint(address _addr, uint256 _value);
    event Redeem(address _addr, uint256 _value);
    event CapitalPaused();
    event CapitalUnpaused();
    event RebasePaused();
    event RebaseUnpaused();
    event VaultBufferUpdated(uint256 _vaultBuffer);
    event RedeemFeeUpdated(uint256 _redeemFeeBps);
    event PriceProviderUpdated(address _priceProvider);
    event AllocateThresholdUpdated(uint256 _threshold);
    event RebaseThresholdUpdated(uint256 _threshold);
    event UniswapUpdated(address _address);
    event StrategistUpdated(address _address);
    event MaxSupplyDiffChanged(uint256 maxSupplyDiff);
    event YieldDistribution(address _to, uint256 _yield, uint256 _fee);
    event TrusteeFeeBpsChanged(uint256 _basis);
    event TrusteeAddressChanged(address _address);

    struct Asset {
        bool isSupported;
    }
    mapping(address => Asset) assets;
    address[] allAssets;

    struct Strategy {
        bool isSupported;
        uint256 _deprecated; // Deprecated storage slot
    }
    mapping(address => Strategy) strategies;
    address[] allStrategies;

    address public priceProvider;
    bool public rebasePaused = false;
    bool public capitalPaused = true;
    uint256 public redeemFeeBps;
    uint256 public vaultBuffer;
    uint256 public autoAllocateThreshold;
    uint256 public rebaseThreshold;

    OUSD oUSD;

    bytes32 constant adminImplPosition = 0xa2bd3d3cf188a41358c8b401076eb59066b09dec5775650c0de4c55187d17bd9;

    address private _deprecated_rebaseHooksAddr = address(0);

    address public uniswapAddr = address(0);

    address public strategistAddr = address(0);

    mapping(address => address) public assetDefaultStrategies;

    uint256 public maxSupplyDiff;

    address public trusteeAddress;

    uint256 public trusteeFeeBps;

    function setAdminImpl(address newImpl) external onlyGovernor {

        require(
            Address.isContract(newImpl),
            "new implementation is not a contract"
        );
        bytes32 position = adminImplPosition;
        assembly {
            sstore(position, newImpl)
        }
    }
}


pragma solidity 0.5.11;

interface IMinMaxOracle {

    function priceMin(string calldata symbol) external view returns (uint256);


    function priceMax(string calldata symbol) external view returns (uint256);

}


pragma solidity 0.5.11;

interface IVault {

    event AssetSupported(address _asset);
    event StrategyApproved(address _addr);
    event StrategyRemoved(address _addr);
    event Mint(address _addr, uint256 _value);
    event Redeem(address _addr, uint256 _value);
    event DepositsPaused();
    event DepositsUnpaused();

    function transferGovernance(address _newGovernor) external;


    function claimGovernance() external;


    function governor() external view returns (address);


    function setPriceProvider(address _priceProvider) external;


    function priceProvider() external view returns (address);


    function setRedeemFeeBps(uint256 _redeemFeeBps) external;


    function redeemFeeBps() external view returns (uint256);


    function setVaultBuffer(uint256 _vaultBuffer) external;


    function vaultBuffer() external view returns (uint256);


    function setAutoAllocateThreshold(uint256 _threshold) external;


    function autoAllocateThreshold() external view returns (uint256);


    function setRebaseThreshold(uint256 _threshold) external;


    function rebaseThreshold() external view returns (uint256);


    function setStrategistAddr(address _address) external;


    function strategistAddr() external view returns (address);


    function setUniswapAddr(address _address) external;


    function uniswapAddr() external view returns (address);


    function setMaxSupplyDiff(uint256 _maxSupplyDiff) external;


    function maxSupplyDiff() external view returns (uint256);


    function setTrusteeAddress(address _address) external;


    function trusteeAddress() external view returns (address);


    function setTrusteeFeeBps(uint256 _basis) external;


    function trusteeFeeBps() external view returns (uint256);


    function supportAsset(address _asset) external;


    function approveStrategy(address _addr) external;


    function removeStrategy(address _addr) external;


    function setAssetDefaultStrategy(address _asset, address _strategy)
        external;


    function assetDefaultStrategies(address _asset)
        external
        view
        returns (address);


    function pauseRebase() external;


    function unpauseRebase() external;


    function rebasePaused() external view returns (bool);


    function pauseCapital() external;


    function unpauseCapital() external;


    function capitalPaused() external view returns (bool);


    function transferToken(address _asset, uint256 _amount) external;


    function harvest() external;


    function harvest(address _strategyAddr) external;


    function priceUSDMint(string calldata symbol)
        external
        view
        returns (uint256);


    function priceUSDRedeem(string calldata symbol)
        external
        view
        returns (uint256);


    function mint(
        address _asset,
        uint256 _amount,
        uint256 _minimumOusdAmount
    ) external;


    function mintMultiple(
        address[] calldata _assets,
        uint256[] calldata _amount,
        uint256 _minimumOusdAmount
    ) external;


    function redeem(uint256 _amount, uint256 _minimumUnitAmount) external;


    function redeemAll(uint256 _minimumUnitAmount) external;


    function allocate() external;


    function reallocate(
        address _strategyFromAddress,
        address _strategyToAddress,
        address[] calldata _assets,
        uint256[] calldata _amounts
    ) external;


    function rebase() external;


    function totalValue() external view returns (uint256 value);


    function checkBalance() external view returns (uint256);


    function checkBalance(address _asset) external view returns (uint256);


    function calculateRedeemOutputs(uint256 _amount)
        external
        view
        returns (uint256[] memory);


    function getAssetCount() external view returns (uint256);


    function getAllAssets() external view returns (address[] memory);


    function getStrategyCount() external view returns (uint256);


    function isSupportedAsset(address _asset) external view returns (bool);

}


pragma solidity 0.5.11;




contract VaultCore is VaultStorage {

    uint256 constant MAX_UINT = 0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff;

    modifier whenNotRebasePaused() {

        require(!rebasePaused, "Rebasing paused");
        _;
    }

    modifier whenNotCapitalPaused() {

        require(!capitalPaused, "Capital paused");
        _;
    }

    function mint(
        address _asset,
        uint256 _amount,
        uint256 _minimumOusdAmount
    ) external whenNotCapitalPaused nonReentrant {

        require(assets[_asset].isSupported, "Asset is not supported");
        require(_amount > 0, "Amount must be greater than 0");

        uint256 price = IMinMaxOracle(priceProvider).priceMin(
            Helpers.getSymbol(_asset)
        );
        if (price > 1e8) {
            price = 1e8;
        }
        uint256 assetDecimals = Helpers.getDecimals(_asset);
        uint256 unitAdjustedDeposit = _amount.scaleBy(int8(18 - assetDecimals));
        uint256 priceAdjustedDeposit = _amount.mulTruncateScale(
            price.scaleBy(int8(10)), // 18-8 because oracles have 8 decimals precision
            10**assetDecimals
        );

        if (_minimumOusdAmount > 0) {
            require(
                priceAdjustedDeposit >= _minimumOusdAmount,
                "Mint amount lower than minimum"
            );
        }

        emit Mint(msg.sender, priceAdjustedDeposit);

        if (unitAdjustedDeposit >= rebaseThreshold && !rebasePaused) {
            _rebase();
        }

        oUSD.mint(msg.sender, priceAdjustedDeposit);

        IERC20 asset = IERC20(_asset);
        asset.safeTransferFrom(msg.sender, address(this), _amount);

        if (unitAdjustedDeposit >= autoAllocateThreshold) {
            _allocate();
        }
    }

    function mintMultiple(
        address[] calldata _assets,
        uint256[] calldata _amounts,
        uint256 _minimumOusdAmount
    ) external whenNotCapitalPaused nonReentrant {

        require(_assets.length == _amounts.length, "Parameter length mismatch");

        uint256 unitAdjustedTotal = 0;
        uint256 priceAdjustedTotal = 0;
        uint256[] memory assetPrices = _getAssetPrices(false);
        for (uint256 j = 0; j < _assets.length; j++) {
            require(assets[_assets[j]].isSupported, "Asset is not supported");
            require(_amounts[j] > 0, "Amount must be greater than 0");
            for (uint256 i = 0; i < allAssets.length; i++) {
                if (_assets[j] == allAssets[i]) {
                    uint256 assetDecimals = Helpers.getDecimals(allAssets[i]);
                    uint256 price = assetPrices[i];
                    if (price > 1e18) {
                        price = 1e18;
                    }
                    unitAdjustedTotal = unitAdjustedTotal.add(
                        _amounts[j].scaleBy(int8(18 - assetDecimals))
                    );
                    priceAdjustedTotal = priceAdjustedTotal.add(
                        _amounts[j].mulTruncateScale(price, 10**assetDecimals)
                    );
                }
            }
        }

        if (_minimumOusdAmount > 0) {
            require(
                priceAdjustedTotal >= _minimumOusdAmount,
                "Mint amount lower than minimum"
            );
        }

        emit Mint(msg.sender, priceAdjustedTotal);

        if (unitAdjustedTotal >= rebaseThreshold && !rebasePaused) {
            _rebase();
        }

        oUSD.mint(msg.sender, priceAdjustedTotal);

        for (uint256 i = 0; i < _assets.length; i++) {
            IERC20 asset = IERC20(_assets[i]);
            asset.safeTransferFrom(msg.sender, address(this), _amounts[i]);
        }

        if (unitAdjustedTotal >= autoAllocateThreshold) {
            _allocate();
        }
    }

    function redeem(uint256 _amount, uint256 _minimumUnitAmount)
        public
        whenNotCapitalPaused
        nonReentrant
    {

        if (_amount > rebaseThreshold && !rebasePaused) {
            _rebase();
        }
        _redeem(_amount, _minimumUnitAmount);
    }

    function _redeem(uint256 _amount, uint256 _minimumUnitAmount) internal {

        require(_amount > 0, "Amount must be greater than 0");

        uint256 _totalSupply = oUSD.totalSupply();
        uint256 _backingValue = _totalValue();

        if (maxSupplyDiff > 0) {
            uint256 diff = _totalSupply.divPrecisely(_backingValue);

            require(
                (diff > 1e18 ? diff.sub(1e18) : uint256(1e18).sub(diff)) <=
                    maxSupplyDiff,
                "Backing supply liquidity error"
            );
        }

        emit Redeem(msg.sender, _amount);

        uint256[] memory outputs = _calculateRedeemOutputs(_amount);
        for (uint256 i = 0; i < allAssets.length; i++) {
            if (outputs[i] == 0) continue;

            IERC20 asset = IERC20(allAssets[i]);

            if (asset.balanceOf(address(this)) >= outputs[i]) {
                asset.safeTransfer(msg.sender, outputs[i]);
            } else {
                address strategyAddr = assetDefaultStrategies[allAssets[i]];
                if (strategyAddr != address(0)) {
                    IStrategy strategy = IStrategy(strategyAddr);
                    strategy.withdraw(msg.sender, allAssets[i], outputs[i]);
                } else {
                    revert("Liquidity error");
                }
            }
        }

        if (_minimumUnitAmount > 0) {
            uint256 unitTotal = 0;
            for (uint256 i = 0; i < outputs.length; i++) {
                uint256 assetDecimals = Helpers.getDecimals(allAssets[i]);
                unitTotal = unitTotal.add(
                    outputs[i].scaleBy(int8(18 - assetDecimals))
                );
            }
            require(
                unitTotal >= _minimumUnitAmount,
                "Redeem amount lower than minimum"
            );
        }

        oUSD.burn(msg.sender, _amount);

        if (_amount > rebaseThreshold && !rebasePaused) {
            _rebase();
        }
    }

    function redeemAll(uint256 _minimumUnitAmount)
        external
        whenNotCapitalPaused
        nonReentrant
    {

        if (oUSD.balanceOf(msg.sender) > rebaseThreshold && !rebasePaused) {
            _rebase();
        }
        _redeem(oUSD.balanceOf(msg.sender), _minimumUnitAmount);
    }

    function allocate() public whenNotCapitalPaused nonReentrant {

        _allocate();
    }

    function _allocate() internal {

        uint256 vaultValue = _totalValueInVault();
        if (vaultValue == 0) return;
        uint256 strategiesValue = _totalValueInStrategies();
        uint256 calculatedTotalValue = vaultValue.add(strategiesValue);

        uint256 vaultBufferModifier;
        if (strategiesValue == 0) {
            vaultBufferModifier = uint256(1e18).sub(vaultBuffer);
        } else {
            vaultBufferModifier = vaultBuffer.mul(calculatedTotalValue).div(
                vaultValue
            );
            if (1e18 > vaultBufferModifier) {
                vaultBufferModifier = uint256(1e18).sub(vaultBufferModifier);
            } else {
                return;
            }
        }
        if (vaultBufferModifier == 0) return;

        for (uint256 i = 0; i < allAssets.length; i++) {
            IERC20 asset = IERC20(allAssets[i]);
            uint256 assetBalance = asset.balanceOf(address(this));
            if (assetBalance == 0) continue;

            uint256 allocateAmount = assetBalance.mulTruncate(
                vaultBufferModifier
            );

            address depositStrategyAddr = assetDefaultStrategies[address(
                asset
            )];

            if (depositStrategyAddr != address(0) && allocateAmount > 0) {
                IStrategy strategy = IStrategy(depositStrategyAddr);
                asset.safeTransfer(address(strategy), allocateAmount);
                strategy.deposit(address(asset), allocateAmount);
            }
        }

        for (uint256 i = 0; i < allStrategies.length; i++) {
            IStrategy strategy = IStrategy(allStrategies[i]);
            address rewardTokenAddress = strategy.rewardTokenAddress();
            if (rewardTokenAddress != address(0)) {
                uint256 liquidationThreshold = strategy
                    .rewardLiquidationThreshold();
                if (liquidationThreshold == 0) {
                    IVault(address(this)).harvest(allStrategies[i]);
                } else {
                    IERC20 rewardToken = IERC20(rewardTokenAddress);
                    uint256 rewardTokenAmount = rewardToken.balanceOf(
                        allStrategies[i]
                    );
                    if (rewardTokenAmount >= liquidationThreshold) {
                        IVault(address(this)).harvest(allStrategies[i]);
                    }
                }
            }
        }
    }

    function rebase() public whenNotRebasePaused nonReentrant {

        _rebase();
    }

    function _rebase() internal whenNotRebasePaused {

        uint256 ousdSupply = oUSD.totalSupply();
        if (ousdSupply == 0) {
            return;
        }
        uint256 vaultValue = _totalValue();

        address _trusteeAddress = trusteeAddress; // gas savings
        if (_trusteeAddress != address(0) && (vaultValue > ousdSupply)) {
            uint256 yield = vaultValue.sub(ousdSupply);
            uint256 fee = yield.mul(trusteeFeeBps).div(10000);
            require(yield > fee, "Fee must not be greater than yield");
            if (fee > 0) {
                oUSD.mint(_trusteeAddress, fee);
            }
            emit YieldDistribution(_trusteeAddress, yield, fee);
        }

        ousdSupply = oUSD.totalSupply(); // Final check should use latest value
        if (vaultValue > ousdSupply) {
            oUSD.changeSupply(vaultValue);
        }
    }

    function totalValue() external view returns (uint256 value) {

        value = _totalValue();
    }

    function _totalValue() internal view returns (uint256 value) {

        return _totalValueInVault().add(_totalValueInStrategies());
    }

    function _totalValueInVault() internal view returns (uint256 value) {

        for (uint256 y = 0; y < allAssets.length; y++) {
            IERC20 asset = IERC20(allAssets[y]);
            uint256 assetDecimals = Helpers.getDecimals(allAssets[y]);
            uint256 balance = asset.balanceOf(address(this));
            if (balance > 0) {
                value = value.add(balance.scaleBy(int8(18 - assetDecimals)));
            }
        }
    }

    function _totalValueInStrategies() internal view returns (uint256 value) {

        for (uint256 i = 0; i < allStrategies.length; i++) {
            value = value.add(_totalValueInStrategy(allStrategies[i]));
        }
    }

    function _totalValueInStrategy(address _strategyAddr)
        internal
        view
        returns (uint256 value)
    {

        IStrategy strategy = IStrategy(_strategyAddr);
        for (uint256 y = 0; y < allAssets.length; y++) {
            uint256 assetDecimals = Helpers.getDecimals(allAssets[y]);
            if (strategy.supportsAsset(allAssets[y])) {
                uint256 balance = strategy.checkBalance(allAssets[y]);
                if (balance > 0) {
                    value = value.add(
                        balance.scaleBy(int8(18 - assetDecimals))
                    );
                }
            }
        }
    }

    function checkBalance(address _asset) external view returns (uint256) {

        return _checkBalance(_asset);
    }

    function _checkBalance(address _asset)
        internal
        view
        returns (uint256 balance)
    {

        IERC20 asset = IERC20(_asset);
        balance = asset.balanceOf(address(this));
        for (uint256 i = 0; i < allStrategies.length; i++) {
            IStrategy strategy = IStrategy(allStrategies[i]);
            if (strategy.supportsAsset(_asset)) {
                balance = balance.add(strategy.checkBalance(_asset));
            }
        }
    }

    function _checkBalance() internal view returns (uint256 balance) {

        for (uint256 i = 0; i < allAssets.length; i++) {
            uint256 assetDecimals = Helpers.getDecimals(allAssets[i]);
            balance = balance.add(
                _checkBalance(allAssets[i]).scaleBy(int8(18 - assetDecimals))
            );
        }
    }

    function calculateRedeemOutputs(uint256 _amount)
        external
        view
        returns (uint256[] memory)
    {

        return _calculateRedeemOutputs(_amount);
    }

    function _calculateRedeemOutputs(uint256 _amount)
        internal
        view
        returns (uint256[] memory outputs)
    {


        uint256 assetCount = getAssetCount();
        uint256[] memory assetPrices = _getAssetPrices(true);
        uint256[] memory assetBalances = new uint256[](assetCount);
        uint256[] memory assetDecimals = new uint256[](assetCount);
        uint256 totalBalance = 0;
        uint256 totalOutputRatio = 0;
        outputs = new uint256[](assetCount);

        if (redeemFeeBps > 0) {
            uint256 redeemFee = _amount.mul(redeemFeeBps).div(10000);
            _amount = _amount.sub(redeemFee);
        }

        for (uint256 i = 0; i < allAssets.length; i++) {
            uint256 balance = _checkBalance(allAssets[i]);
            uint256 decimals = Helpers.getDecimals(allAssets[i]);
            assetBalances[i] = balance;
            assetDecimals[i] = decimals;
            totalBalance = totalBalance.add(
                balance.scaleBy(int8(18 - decimals))
            );
        }
        for (uint256 i = 0; i < allAssets.length; i++) {
            uint256 price = assetPrices[i];
            if (price < 1e18) {
                price = 1e18;
            }
            uint256 ratio = assetBalances[i]
                .scaleBy(int8(18 - assetDecimals[i]))
                .mul(price)
                .div(totalBalance);
            totalOutputRatio = totalOutputRatio.add(ratio);
        }
        uint256 factor = _amount.divPrecisely(totalOutputRatio);
        for (uint256 i = 0; i < allAssets.length; i++) {
            outputs[i] = assetBalances[i].mul(factor).div(totalBalance);
        }
    }

    function _getAssetPrices(bool useMax)
        internal
        view
        returns (uint256[] memory assetPrices)
    {

        assetPrices = new uint256[](getAssetCount());

        IMinMaxOracle oracle = IMinMaxOracle(priceProvider);

        for (uint256 i = 0; i < allAssets.length; i++) {
            string memory symbol = Helpers.getSymbol(allAssets[i]);
            if (useMax) {
                assetPrices[i] = oracle.priceMax(symbol).scaleBy(int8(18 - 8));
            } else {
                assetPrices[i] = oracle.priceMin(symbol).scaleBy(int8(18 - 8));
            }
        }
    }


    function getAssetCount() public view returns (uint256) {

        return allAssets.length;
    }

    function getAllAssets() external view returns (address[] memory) {

        return allAssets;
    }

    function getStrategyCount() external view returns (uint256) {

        return allStrategies.length;
    }

    function isSupportedAsset(address _asset) external view returns (bool) {

        return assets[_asset].isSupported;
    }

    function() external payable {
        bytes32 slot = adminImplPosition;
        assembly {
            calldatacopy(0, 0, calldatasize)

            let result := delegatecall(gas, sload(slot), 0, calldatasize, 0, 0)

            returndatacopy(0, 0, returndatasize)

            switch result
                case 0 {
                    revert(0, returndatasize)
                }
                default {
                    return(0, returndatasize)
                }
        }
    }
}