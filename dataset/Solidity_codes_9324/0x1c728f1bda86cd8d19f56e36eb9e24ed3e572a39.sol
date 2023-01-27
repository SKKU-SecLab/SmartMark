
pragma solidity 0.8.0;


interface ISavingsManager {

    function distributeUnallocatedInterest(address _mAsset) external;


    function depositLiquidation(address _mAsset, uint256 _liquidation) external;


    function collectAndStreamInterest(address _mAsset) external;


    function collectAndDistributeInterest(address _mAsset) external;

}

interface ISavingsContractV2 {

    function redeem(uint256 _amount) external returns (uint256 massetReturned);


    function creditBalances(address) external view returns (uint256); // V1 & V2 (use balanceOf)



    function depositInterest(uint256 _amount) external; // V1 & V2


    function depositSavings(uint256 _amount) external returns (uint256 creditsIssued); // V1 & V2


    function depositSavings(uint256 _amount, address _beneficiary)
        external
        returns (uint256 creditsIssued); // V2


    function redeemCredits(uint256 _amount) external returns (uint256 underlyingReturned); // V2


    function redeemUnderlying(uint256 _amount) external returns (uint256 creditsBurned); // V2


    function exchangeRate() external view returns (uint256); // V1 & V2


    function balanceOfUnderlying(address _user) external view returns (uint256 balance); // V2


    function underlyingToCredits(uint256 _credits) external view returns (uint256 underlying); // V2


    function creditsToUnderlying(uint256 _underlying) external view returns (uint256 credits); // V2

}

abstract contract Context {

    function _msgSender() internal view returns (address payable) {
        return payable(msg.sender);
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

contract ERC205 is Context, IERC20 {

    mapping (address => uint256) private _balances;

    mapping (address => mapping (address => uint256)) private _allowances;

    uint256 private _totalSupply;

    function totalSupply() public override view returns (uint256) {

        return _totalSupply;
    }

    function balanceOf(address account) public override view returns (uint256) {

        return _balances[account];
    }

    function transfer(address recipient, uint256 amount) public override returns (bool) {

        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function allowance(address owner, address spender) public override view returns (uint256) {

        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public override returns (bool) {

        _approve(_msgSender(), spender, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) public override returns (bool) {

        _transfer(sender, recipient, amount);
        _approve(sender, _msgSender(), _allowances[sender][_msgSender()] - amount);
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public returns (bool) {

        _approve(_msgSender(), spender, _allowances[_msgSender()][spender] + addedValue);
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public returns (bool) {

        _approve(_msgSender(), spender, _allowances[_msgSender()][spender] - subtractedValue);
        return true;
    }

    function _transfer(address sender, address recipient, uint256 amount) internal {

        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        _balances[sender] -= amount;
        _balances[recipient] += amount;
        emit Transfer(sender, recipient, amount);
    }

    function _mint(address account, uint256 amount) internal {

        require(account != address(0), "ERC20: mint to the zero address");

        _totalSupply += amount;
        _balances[account] += amount;
        emit Transfer(address(0), account, amount);
    }

    function _burn(address account, uint256 amount) internal {

        require(account != address(0), "ERC20: burn from the zero address");

        _balances[account] -= amount;
        _totalSupply -= amount;
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
        _approve(account, _msgSender(), _allowances[account][_msgSender()] - amount);
    }
}

abstract contract InitializableERC20Detailed is IERC20 {
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

abstract contract InitializableToken is ERC205, InitializableERC20Detailed {
    function _initialize(string memory _nameArg, string memory _symbolArg) internal {
        InitializableERC20Detailed._initialize(_nameArg, _symbolArg, 18);
    }
}

contract ModuleKeys {

    bytes32 internal constant KEY_GOVERNANCE =
        0x9409903de1e6fd852dfc61c9dacb48196c48535b60e25abf92acc92dd689078d;
    bytes32 internal constant KEY_STAKING =
        0x1df41cd916959d1163dc8f0671a666ea8a3e434c13e40faef527133b5d167034;
    bytes32 internal constant KEY_PROXY_ADMIN =
        0x96ed0203eb7e975a4cbcaa23951943fa35c5d8288117d50c12b3d48b0fab48d1;

    bytes32 internal constant KEY_ORACLE_HUB =
        0x8ae3a082c61a7379e2280f3356a5131507d9829d222d853bfa7c9fe1200dd040;
    bytes32 internal constant KEY_MANAGER =
        0x6d439300980e333f0256d64be2c9f67e86f4493ce25f82498d6db7f4be3d9e6f;
    bytes32 internal constant KEY_RECOLLATERALISER =
        0x39e3ed1fc335ce346a8cbe3e64dd525cf22b37f1e2104a755e761c3c1eb4734f;
    bytes32 internal constant KEY_META_TOKEN =
        0xea7469b14936af748ee93c53b2fe510b9928edbdccac3963321efca7eb1a57a2;
    bytes32 internal constant KEY_SAVINGS_MANAGER =
        0x12fe936c77a1e196473c4314f3bed8eeac1d757b319abb85bdda70df35511bf1;
    bytes32 internal constant KEY_LIQUIDATOR =
        0x1e9cb14d7560734a61fa5ff9273953e971ff3cd9283c03d8346e3264617933d4;
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

abstract contract ImmutableModule is ModuleKeys {
    INexus public immutable nexus;

    constructor(address _nexus) {
        require(_nexus != address(0), "Nexus address is zero");
        nexus = INexus(_nexus);
    }

    modifier onlyGovernor() {
        _onlyGovernor();
        _;
    }

    function _onlyGovernor() internal view {
        require(msg.sender == _governor(), "Only governor can execute");
    }

    modifier onlyGovernance() {
        require(
            msg.sender == _governor() || msg.sender == _governance(),
            "Only governance can execute"
        );
        _;
    }

    modifier onlyProxyAdmin() {
        require(msg.sender == _proxyAdmin(), "Only ProxyAdmin can execute");
        _;
    }

    modifier onlyManager() {
        require(msg.sender == _manager(), "Only manager can execute");
        _;
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

interface IConnector {


  function deposit(uint256 _amount) external;


  function withdraw(uint256 _amount) external;


  function withdrawAll() external;


  function checkBalance() external view returns (uint256);

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

library StableMath {

    uint256 private constant FULL_SCALE = 1e18;

    uint256 private constant RATIO_SCALE = 1e8;

    function getFullScale() internal pure returns (uint256) {

        return FULL_SCALE;
    }

    function getRatioScale() internal pure returns (uint256) {

        return RATIO_SCALE;
    }

    function scaleInteger(uint256 x) internal pure returns (uint256) {

        return x * FULL_SCALE;
    }


    function mulTruncate(uint256 x, uint256 y) internal pure returns (uint256) {

        return mulTruncateScale(x, y, FULL_SCALE);
    }

    function mulTruncateScale(
        uint256 x,
        uint256 y,
        uint256 scale
    ) internal pure returns (uint256) {

        return (x * y) / scale;
    }

    function mulTruncateCeil(uint256 x, uint256 y) internal pure returns (uint256) {

        uint256 scaled = x * y;
        uint256 ceil = scaled + FULL_SCALE - 1;
        return ceil / FULL_SCALE;
    }

    function divPrecisely(uint256 x, uint256 y) internal pure returns (uint256) {

        return (x * FULL_SCALE) / y;
    }


    function mulRatioTruncate(uint256 x, uint256 ratio) internal pure returns (uint256 c) {

        return mulTruncateScale(x, ratio, RATIO_SCALE);
    }

    function mulRatioTruncateCeil(uint256 x, uint256 ratio) internal pure returns (uint256) {

        uint256 scaled = x * ratio;
        uint256 ceil = scaled + RATIO_SCALE - 1;
        return ceil / RATIO_SCALE;
    }

    function divRatioPrecisely(uint256 x, uint256 ratio) internal pure returns (uint256 c) {

        return (x * RATIO_SCALE) / ratio;
    }


    function min(uint256 x, uint256 y) internal pure returns (uint256) {

        return x > y ? y : x;
    }

    function max(uint256 x, uint256 y) internal pure returns (uint256) {

        return x > y ? x : y;
    }

    function clamp(uint256 x, uint256 upperBound) internal pure returns (uint256) {

        return x > upperBound ? upperBound : x;
    }
}

contract SavingsContract is ISavingsContractV2, Initializable, InitializableToken, ImmutableModule {

    using StableMath for uint256;

    event ExchangeRateUpdated(uint256 newExchangeRate, uint256 interestCollected);
    event SavingsDeposited(address indexed saver, uint256 savingsDeposited, uint256 creditsIssued);
    event CreditsRedeemed(
        address indexed redeemer,
        uint256 creditsRedeemed,
        uint256 savingsCredited
    );

    event AutomaticInterestCollectionSwitched(bool automationEnabled);

    event PokerUpdated(address poker);

    event FractionUpdated(uint256 fraction);
    event ConnectorUpdated(address connector);
    event EmergencyUpdate();

    event Poked(uint256 oldBalance, uint256 newBalance, uint256 interestDetected);
    event PokedRaw();

    uint256 private constant startingRate = 1e17;
    uint256 public override exchangeRate;

    IERC20 public immutable underlying;
    bool private automateInterestCollection;

    address public poker;
    uint256 public lastPoke;
    uint256 public lastBalance;
    uint256 public fraction;
    IConnector public connector;
    uint256 private constant POKE_CADENCE = 4 hours;
    uint256 private constant MAX_APY = 4e18;
    uint256 private constant SECONDS_IN_YEAR = 365 days;

    constructor(address _nexus, address _underlying) ImmutableModule(_nexus) {
        require(address(_underlying) != address(0), "mAsset address is zero");
        underlying = IERC20(_underlying);
    }

    function initialize(
        address _poker,
        string calldata _nameArg,
        string calldata _symbolArg
    ) external initializer {

        InitializableToken._initialize(_nameArg, _symbolArg);

        require(_poker != address(0), "Invalid poker address");
        poker = _poker;

        fraction = 2e17;
        automateInterestCollection = true;
        exchangeRate = startingRate;
    }

    modifier onlySavingsManager() {

        require(msg.sender == _savingsManager(), "Only savings manager can execute");
        _;
    }


    function balanceOfUnderlying(address _user) external view override returns (uint256 balance) {

        (balance, ) = _creditsToUnderlying(balanceOf(_user));
    }

    function underlyingToCredits(uint256 _underlying)
        external
        view
        override
        returns (uint256 credits)
    {

        (credits, ) = _underlyingToCredits(_underlying);
    }

    function creditsToUnderlying(uint256 _credits) external view override returns (uint256 amount) {

        (amount, ) = _creditsToUnderlying(_credits);
    }

    function creditBalances(address _user) external view override returns (uint256) {

        return balanceOf(_user);
    }


    function depositInterest(uint256 _amount) external override onlySavingsManager {

        require(_amount > 0, "Must deposit something");

        require(underlying.transferFrom(msg.sender, address(this), _amount), "Must receive tokens");

        uint256 totalCredits = totalSupply();
        if (totalCredits > 0) {
            (uint256 totalCollat, ) = _creditsToUnderlying(totalCredits);
            uint256 newExchangeRate = _calcExchangeRate(totalCollat + _amount, totalCredits);
            exchangeRate = newExchangeRate;

            emit ExchangeRateUpdated(newExchangeRate, _amount);
        }
    }

    function automateInterestCollectionFlag(bool _enabled) external onlyGovernor {

        automateInterestCollection = _enabled;
        emit AutomaticInterestCollectionSwitched(_enabled);
    }


    function preDeposit(uint256 _underlying, address _beneficiary)
        external
        returns (uint256 creditsIssued)
    {

        require(exchangeRate == startingRate, "Can only use this method before streaming begins");
        return _deposit(_underlying, _beneficiary, false);
    }

    function depositSavings(uint256 _underlying) external override returns (uint256 creditsIssued) {

        return _deposit(_underlying, msg.sender, true);
    }

    function depositSavings(uint256 _underlying, address _beneficiary)
        external
        override
        returns (uint256 creditsIssued)
    {

        return _deposit(_underlying, _beneficiary, true);
    }

    function _deposit(
        uint256 _underlying,
        address _beneficiary,
        bool _collectInterest
    ) internal returns (uint256 creditsIssued) {

        require(_underlying > 0, "Must deposit something");
        require(_beneficiary != address(0), "Invalid beneficiary address");

        IERC20 mAsset = underlying;
        if (_collectInterest) {
            ISavingsManager(_savingsManager()).collectAndDistributeInterest(address(mAsset));
        }

        require(mAsset.transferFrom(msg.sender, address(this), _underlying), "Must receive tokens");

        (creditsIssued, ) = _underlyingToCredits(_underlying);

        _mint(_beneficiary, creditsIssued);

        emit SavingsDeposited(_beneficiary, _underlying, creditsIssued);
    }


    function redeem(uint256 _credits) external override returns (uint256 massetReturned) {

        require(_credits > 0, "Must withdraw something");

        (, uint256 payout) = _redeem(_credits, true);

        if (automateInterestCollection) {
            ISavingsManager(_savingsManager()).collectAndDistributeInterest(address(underlying));
        }

        return payout;
    }

    function redeemCredits(uint256 _credits) external override returns (uint256 massetReturned) {

        require(_credits > 0, "Must withdraw something");

        if (automateInterestCollection) {
            ISavingsManager(_savingsManager()).collectAndDistributeInterest(address(underlying));
        }

        (, uint256 payout) = _redeem(_credits, true);

        return payout;
    }

    function redeemUnderlying(uint256 _underlying)
        external
        override
        returns (uint256 creditsBurned)
    {

        require(_underlying > 0, "Must withdraw something");

        if (automateInterestCollection) {
            ISavingsManager(_savingsManager()).collectAndDistributeInterest(address(underlying));
        }

        (uint256 credits, uint256 massetReturned) = _redeem(_underlying, false);
        require(massetReturned == _underlying, "Invalid output");

        return credits;
    }

    function _redeem(uint256 _amt, bool _isCreditAmt)
        internal
        returns (uint256 creditsBurned, uint256 massetReturned)
    {

        uint256 credits_;
        uint256 underlying_;
        uint256 exchangeRate_;
        if (_isCreditAmt) {
            credits_ = _amt;
            (underlying_, exchangeRate_) = _creditsToUnderlying(_amt);
        }
        else {
            underlying_ = _amt;
            (credits_, exchangeRate_) = _underlyingToCredits(_amt);
        }

        _burn(msg.sender, credits_);

        require(underlying.transfer(msg.sender, underlying_), "Must send tokens");

        CachedData memory cachedData = _cacheData();
        ConnectorStatus memory status = _getConnectorStatus(cachedData, exchangeRate_);
        if (status.inConnector > status.limit) {
            _poke(cachedData, false);
        }

        emit CreditsRedeemed(msg.sender, credits_, underlying_);

        return (credits_, underlying_);
    }

    struct ConnectorStatus {
        uint256 limit;
        uint256 inConnector;
    }

    function _getConnectorStatus(CachedData memory _data, uint256 _exchangeRate)
        internal
        pure
        returns (ConnectorStatus memory)
    {

        uint256 totalCollat = _data.totalCredits.mulTruncate(_exchangeRate);
        uint256 limit = totalCollat.mulTruncate(_data.fraction + 2e17);
        uint256 inConnector = _data.rawBalance >= totalCollat ? 0 : totalCollat - _data.rawBalance;

        return ConnectorStatus(limit, inConnector);
    }


    modifier onlyPoker() {

        require(msg.sender == poker, "Only poker can execute");
        _;
    }

    function poke() external onlyPoker {

        CachedData memory cachedData = _cacheData();
        _poke(cachedData, false);
    }

    function setPoker(address _newPoker) external onlyGovernor {

        require(_newPoker != address(0) && _newPoker != poker, "Invalid poker");

        poker = _newPoker;

        emit PokerUpdated(_newPoker);
    }

    function setFraction(uint256 _fraction) external onlyGovernor {

        require(_fraction <= 5e17, "Fraction must be <= 50%");

        fraction = _fraction;

        CachedData memory cachedData = _cacheData();
        _poke(cachedData, true);

        emit FractionUpdated(_fraction);
    }

    function setConnector(address _newConnector) external onlyGovernor {

        CachedData memory cachedData = _cacheData();
        cachedData.fraction = 0;
        _poke(cachedData, true);

        CachedData memory cachedDataNew = _cacheData();
        connector = IConnector(_newConnector);
        _poke(cachedDataNew, true);

        emit ConnectorUpdated(_newConnector);
    }

    function emergencyWithdraw(uint256 _withdrawAmount) external onlyGovernor {

        connector.withdraw(_withdrawAmount);

        connector = IConnector(address(0));
        emit ConnectorUpdated(address(0));

        fraction = 0;
        emit FractionUpdated(0);

        CachedData memory data = _cacheData();
        _refreshExchangeRate(data.rawBalance, data.totalCredits, true);

        emit EmergencyUpdate();
    }


    function _poke(CachedData memory _data, bool _ignoreCadence) internal {

        require(_data.totalCredits > 0, "Must have something to poke");

        uint256 currentTime = uint256(block.timestamp);
        uint256 timeSinceLastPoke = currentTime - lastPoke;
        require(_ignoreCadence || timeSinceLastPoke > POKE_CADENCE, "Not enough time elapsed");
        lastPoke = currentTime;

        IConnector connector_ = connector;
        if (address(connector_) != address(0)) {
            uint256 lastBalance_ = lastBalance;
            uint256 connectorBalance = connector_.checkBalance();
            require(connectorBalance >= lastBalance_, "Invalid yield");
            if (connectorBalance > 0) {
                _validateCollection(
                    connectorBalance,
                    connectorBalance - lastBalance_,
                    timeSinceLastPoke
                );
            }

            uint256 sum = _data.rawBalance + connectorBalance;
            uint256 ideal = sum.mulTruncate(_data.fraction);
            if (ideal > connectorBalance) {
                uint256 deposit = ideal - connectorBalance;
                underlying.approve(address(connector_), deposit);
                connector_.deposit(deposit);
            }
            else if (connectorBalance > ideal) {
                if (ideal == 0) {
                    connector_.withdrawAll();
                    sum = IERC20(underlying).balanceOf(address(this));
                } else {
                    connector_.withdraw(connectorBalance - ideal);
                }
            }
            require(connector_.checkBalance() >= ideal, "Enforce system invariant");

            lastBalance = ideal;
            _refreshExchangeRate(sum, _data.totalCredits, false);
            emit Poked(lastBalance_, ideal, connectorBalance - lastBalance_);
        } else {
            lastBalance = 0;
            _refreshExchangeRate(_data.rawBalance, _data.totalCredits, false);
            emit PokedRaw();
        }
    }

    function _refreshExchangeRate(
        uint256 _realSum,
        uint256 _totalCredits,
        bool _ignoreValidation
    ) internal {

        (uint256 totalCredited, ) = _creditsToUnderlying(_totalCredits);

        require(_ignoreValidation || _realSum >= totalCredited, "ExchangeRate must increase");
        uint256 newExchangeRate = _calcExchangeRate(_realSum, _totalCredits);
        exchangeRate = newExchangeRate;

        emit ExchangeRateUpdated(
            newExchangeRate,
            _realSum > totalCredited ? _realSum - totalCredited : 0
        );
    }

    function _validateCollection(
        uint256 _newBalance,
        uint256 _interest,
        uint256 _timeSinceLastCollection
    ) internal pure returns (uint256 extrapolatedAPY) {

        uint256 protectedTime = StableMath.max(1, _timeSinceLastCollection);

        uint256 oldSupply = _newBalance - _interest;
        uint256 percentageIncrease = _interest.divPrecisely(oldSupply);

        uint256 yearsSinceLastCollection = protectedTime.divPrecisely(SECONDS_IN_YEAR);

        extrapolatedAPY = percentageIncrease.divPrecisely(yearsSinceLastCollection);

        if (protectedTime > 30 minutes) {
            require(extrapolatedAPY < MAX_APY, "Interest protected from inflating past maxAPY");
        } else {
            require(percentageIncrease < 1e15, "Interest protected from inflating past 10 Bps");
        }
    }


    struct CachedData {
        uint256 fraction;
        uint256 rawBalance;
        uint256 totalCredits;
    }

    function _cacheData() internal view returns (CachedData memory) {

        uint256 balance = underlying.balanceOf(address(this));
        return CachedData(fraction, balance, totalSupply());
    }

    function _underlyingToCredits(uint256 _underlying)
        internal
        view
        returns (uint256 credits, uint256 exchangeRate_)
    {

        exchangeRate_ = exchangeRate;
        credits = _underlying.divPrecisely(exchangeRate_) + 1;
    }

    function _calcExchangeRate(uint256 _totalCollateral, uint256 _totalCredits)
        internal
        pure
        returns (uint256 _exchangeRate)
    {

        _exchangeRate = _totalCollateral.divPrecisely(_totalCredits - 1);
    }

    function _creditsToUnderlying(uint256 _credits)
        internal
        view
        returns (uint256 underlyingAmount, uint256 exchangeRate_)
    {

        exchangeRate_ = exchangeRate;
        underlyingAmount = _credits.mulTruncate(exchangeRate_);
    }
}