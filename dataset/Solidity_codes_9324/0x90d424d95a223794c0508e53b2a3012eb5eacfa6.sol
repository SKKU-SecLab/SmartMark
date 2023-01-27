


pragma solidity ^0.6.2;

interface ISynthetix {

    function exchange(
        bytes32 sourceCurrencyKey,
        uint256 sourceAmount,
        bytes32 destinationCurrencyKey
    ) external returns (uint256 amountReceived);


    function exchangeWithTracking(
        bytes32 sourceCurrencyKey,
        uint256 sourceAmount,
        bytes32 destinationCurrencyKey,
        address originator,
        bytes32 trackingCode
    ) external returns (uint256 amountReceived);


    function synths(bytes32 key)
        external
        view
        returns (address synthTokenAddress);


    function settle(bytes32 currencyKey)
        external
        returns (
            uint256 reclaimed,
            uint256 refunded,
            uint256 numEntriesSettled
        );

}



pragma solidity ^0.6.2;

interface IExchanger {


    function settle(address from, bytes32 currencyKey)
        external
        returns (
            uint reclaimed,
            uint refunded,
            uint numEntries
        );


    function maxSecsLeftInWaitingPeriod(address account, bytes32 currencyKey) external view returns (uint);


    function settlementOwing(address account, bytes32 currencyKey)
        external
        view
        returns (
            uint reclaimAmount,
            uint rebateAmount,
            uint numEntries
        );


}



pragma solidity ^0.6.2;

interface ISynth {

    function proxy() external view returns (address);


    function transferAndSettle(address to, uint256 value)
        external
        returns (bool);


    function transferFromAndSettle(
        address from,
        address to,
        uint256 value
    ) external returns (bool);

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



pragma solidity >=0.4.24;
interface ISynthRedeemer {

    function redemptions(address synthProxy) external view returns (uint redeemRate);


    function balanceOf(IERC20 synthProxy, address account) external view returns (uint balanceOfInsUSD);


    function totalSupply(IERC20 synthProxy) external view returns (uint totalSupplyInsUSD);


    function redeem(IERC20 synthProxy) external;


    function redeemAll(IERC20[] calldata synthProxies) external;


    function redeemPartial(IERC20 synthProxy, uint amountOfSynth) external;


    function deprecate(IERC20 synthProxy, uint rateToRedeem) external;

}



pragma solidity ^0.6.2;

interface IExchangeRates {

    function effectiveValue(
        bytes32 sourceCurrencyKey,
        uint256 sourceAmount,
        bytes32 destinationCurrencyKey
    ) external view returns (uint256);


    function rateForCurrency(bytes32 currencyKey)
        external
        view
        returns (uint256);

}



pragma solidity ^0.6.2;

interface IAddressResolver {

    function getAddress(bytes32 name) external view returns (address);

}



pragma solidity ^0.6.2;

interface ISystemStatus {

    struct Status {
        bool canSuspend;
        bool canResume;
    }

    struct Suspension {
        bool suspended;
        uint248 reason;
    }


    function synthExchangeSuspension(bytes32 currencyKey)
        external
        view
        returns (bool suspended, uint248 reason);


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




pragma solidity ^0.6.0;
contract Managed is Initializable {

    using SafeMath for uint256;

    event ManagerUpdated(address newManager, string newManagerName);

    address private _manager;
    string private _managerName;

    address[] private _memberList;
    mapping(address => uint256) private _memberPosition;

    address private _trader;

    function initialize(address manager, string memory managerName)
        internal
        initializer
    {

        _manager = manager;
        _managerName = managerName;
    }

    modifier onlyManager() {

        require(msg.sender == _manager, "only manager");
        _;
    }

    modifier onlyManagerOrTrader() {

        require(msg.sender == _manager || msg.sender == _trader, "only manager or trader");
        _;
    }

    function managerName() public view returns (string memory) {

        return _managerName;
    }

    function manager() public view returns (address) {

        return _manager;
    }

    function isMemberAllowed(address member) public view returns (bool) {

        return _memberPosition[member] != 0;
    }

    function getMembers() public view returns (address[] memory) {

        return _memberList;
    }

    function changeManager(address newManager, string memory newManagerName)
        public
        onlyManager
    {

        _manager = newManager;
        _managerName = newManagerName;
        emit ManagerUpdated(newManager, newManagerName);
    }

    function addMembers(address[] memory members) public onlyManager {

        for (uint256 i = 0; i < members.length; i++) {
            if (isMemberAllowed(members[i]))
                continue;

            _addMember(members[i]);
        }
    }

    function removeMembers(address[] memory members) public onlyManager {

        for (uint256 i = 0; i < members.length; i++) {
            if (!isMemberAllowed(members[i]))
                continue;

            _removeMember(members[i]);
        }
    }

    function addMember(address member) public onlyManager {

        if (isMemberAllowed(member))
            return;

        _addMember(member);
    }

    function removeMember(address member) public onlyManager {

        if (!isMemberAllowed(member))
            return;

        _removeMember(member);
    }

    function trader() public view returns (address) {

        return _trader;
    }

    function setTrader(address newTrader) public onlyManager {

        _trader = newTrader;
    }

    function removeTrader() public onlyManager {

        _trader = address(0);
    }

    function numberOfMembers() public view returns (uint256) {

        return _memberList.length;
    }

    function _addMember(address member) internal {

        _memberList.push(member);
        _memberPosition[member] = _memberList.length;
    }

    function _removeMember(address member) internal {

        uint256 length = _memberList.length;
        uint256 index = _memberPosition[member].sub(1);

        address lastMember = _memberList[length.sub(1)];

        _memberList[index] = lastMember;
        _memberPosition[lastMember] = index.add(1);
        _memberPosition[member] = 0;

        _memberList.pop();
    }

    uint256[49] private __gap;
}



pragma solidity ^0.6.2;

interface IHasDaoInfo {

    function getDaoFee() external view returns (uint256, uint256);


    function getDaoAddress() external view returns (address);


    function getAddressResolver() external view returns (IAddressResolver);

}



pragma solidity ^0.6.2;

interface IHasProtocolDaoInfo {

    function owner() external view returns (address);

}




pragma solidity ^0.6.2;

interface IHasFeeInfo {

    function getPoolManagerFee(address pool) external view returns (uint256, uint256);

    function setPoolManagerFeeNumerator(address pool, uint256 numerator) external;


    function getMaximumManagerFeeNumeratorChange() external view returns (uint256);

    function getManagerFeeNumeratorChangeDelay() external view returns (uint256);

   
    function getExitFee() external view returns (uint256, uint256);

    function getExitFeeCooldown() external view returns (uint256);


    function getTrackingCode() external view returns (bytes32);

}




pragma solidity ^0.6.2;

interface IHasAssetInfo {

    function getMaximumSupportedAssetCount() external view returns (uint256);

}




pragma solidity ^0.6.2;

interface IReceivesUpgrade {

    function receiveUpgrade(uint256 targetVersion) external;

}




pragma solidity ^0.6.2;

interface IHasDhptSwapInfo {

    function getDhptSwapAddress() external view returns (address);

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
}




pragma solidity ^0.6.2;
contract DHedge is Initializable, ERC20UpgradeSafe, Managed, IReceivesUpgrade {

    using SafeMath for uint256;

    bytes32 constant private _EXCHANGE_RATES_KEY = "ExchangeRates";
    bytes32 constant private _SYNTHETIX_KEY = "Synthetix";
    bytes32 constant private _EXCHANGER_KEY = "Exchanger";
    bytes32 constant private _SYSTEM_STATUS_KEY = "SystemStatus";
    bytes32 constant private _SUSD_KEY = "sUSD";

    event Deposit(
        address fundAddress,
        address investor,
        uint256 valueDeposited,
        uint256 fundTokensReceived,
        uint256 totalInvestorFundTokens,
        uint256 fundValue,
        uint256 totalSupply,
        uint256 time
    );
    event Withdrawal(
        address fundAddress,
        address investor,
        uint256 valueWithdrawn,
        uint256 fundTokensWithdrawn,
        uint256 totalInvestorFundTokens,
        uint256 fundValue,
        uint256 totalSupply,
        uint256 time
    );
    event Exchange(
        address fundAddress,
        address manager,
        bytes32 sourceKey,
        uint256 sourceAmount,
        bytes32 destinationKey,
        uint256 destinationAmount,
        uint256 time
    );
    event AssetAdded(address fundAddress, address manager, bytes32 assetKey);
    event AssetRemoved(address fundAddress, address manager, bytes32 assetKey);

    event PoolPrivacyUpdated(bool isPoolPrivate);

    event ManagerFeeMinted(
        address pool,
        address manager,
        uint256 available,
        uint256 daoFee,
        uint256 managerFee,
        uint256 tokenPriceAtLastFeeMint
    );

    event ManagerFeeSet(
        address fundAddress,
        address manager,
        uint256 numerator,
        uint256 denominator
    );

    event ManagerFeeIncreaseAnnounced(
        uint256 newNumerator,
        uint256 announcedFeeActivationTime);

    event ManagerFeeIncreaseRenounced();

    bool public privatePool;
    address public creator;

    uint256 public creationTime;

    IAddressResolver public addressResolver;

    address public factory;

    bytes32[] public supportedAssets;
    mapping(bytes32 => uint256) public assetPosition; // maps the asset to its 1-based position

    mapping(bytes32 => bool) public persistentAsset;

    uint256 public tokenPriceAtLastFeeMint;

    mapping(address => uint256) public lastDeposit;

    uint256 public announcedFeeIncreaseNumerator;
    uint256 public announcedFeeIncreaseTimestamp;

    modifier onlyPrivate() {

        require(
            msg.sender == manager() ||
                !privatePool ||
                isMemberAllowed(msg.sender),
            "only members allowed"
        );
        _;
    }

    function initialize(
        address _factory,
        bool _privatePool,
        address _manager,
        string memory _managerName,
        string memory _fundName,
        string memory _fundSymbol,
        IAddressResolver _addressResolver,
        bytes32[] memory _supportedAssets
    ) public initializer {

        ERC20UpgradeSafe.__ERC20_init(_fundName, _fundSymbol);
        Managed.initialize(_manager, _managerName);

        factory = _factory;
        _setPoolPrivacy(_privatePool);
        creator = msg.sender;
        creationTime = block.timestamp;
        addressResolver = _addressResolver;

        _addToSupportedAssets(_SUSD_KEY);

        for(uint8 i = 0; i < _supportedAssets.length; i++) {
            _addToSupportedAssets(_supportedAssets[i]);
        }

        persistentAsset[_SUSD_KEY] = true;

        tokenPriceAtLastFeeMint = 10**18;
    }

    function _beforeTokenTransfer(address from, address to, uint256 amount)
        internal virtual override
    {

        super._beforeTokenTransfer(from, to, amount);

        require(getExitFeeRemainingCooldown(from) == 0, "cooldown active");
    }

    function setPoolPrivate(bool _privatePool) public onlyManager {

        require(privatePool != _privatePool, "flag must be different");

        _setPoolPrivacy(_privatePool);
    }

    function _setPoolPrivacy(bool _privacy) internal {

        privatePool = _privacy;

        emit PoolPrivacyUpdated(_privacy);
    }

    function getAssetProxy(bytes32 key) public view returns (address) {

        address synth = ISynthetix(addressResolver.getAddress(_SYNTHETIX_KEY))
            .synths(key);
        require(synth != address(0), "invalid key");
        address proxy = ISynth(synth).proxy();
        require(proxy != address(0), "invalid proxy");
        return proxy;
    }

    function isAssetSupported(bytes32 key) public view returns (bool) {

        return assetPosition[key] != 0;
    }

    function validateAsset(bytes32 key) public view returns (bool) {

        address synth = ISynthetix(addressResolver.getAddress(_SYNTHETIX_KEY))
            .synths(key);

        if (synth == address(0))
            return false;

        address proxy = ISynth(synth).proxy();

        if (proxy == address(0))
            return false;

        return true;
    }

    function addToSupportedAssets(bytes32 key) public onlyManagerOrTrader {

        _addToSupportedAssets(key);
    }

    function removeFromSupportedAssets(bytes32 key) public {

        require(msg.sender == IHasProtocolDaoInfo(factory).owner() ||
            msg.sender == manager() ||
            msg.sender == trader(), "only manager, trader or Protocol DAO");

        require(isAssetSupported(key), "asset not supported");

        require(!persistentAsset[key], "persistent assets can't be removed");
        
        if (validateAsset(key) == true) { // allow removal of depreciated synths
            require(
                IERC20(getAssetProxy(key)).balanceOf(address(this)) == 0,
                "non-empty asset cannot be removed"
            );
        }
        

        _removeFromSupportedAssets(key);
    }

    function numberOfSupportedAssets() public view returns (uint256) {

        return supportedAssets.length;
    }

    function _addToSupportedAssets(bytes32 key) internal {

        require(supportedAssets.length < IHasAssetInfo(factory).getMaximumSupportedAssetCount(), "maximum assets reached");
        require(!isAssetSupported(key), "asset already supported");
        require(validateAsset(key) == true, "not an asset");

        supportedAssets.push(key);
        assetPosition[key] = supportedAssets.length;

        emit AssetAdded(address(this), manager(), key);
    }

    function _removeFromSupportedAssets(bytes32 key) internal {

        uint256 length = supportedAssets.length;
        uint256 index = assetPosition[key].sub(1); // adjusting the index because the map stores 1-based

        bytes32 lastAsset = supportedAssets[length.sub(1)];

        supportedAssets[index] = lastAsset;
        assetPosition[lastAsset] = index.add(1); // adjusting the index to be 1-based
        assetPosition[key] = 0; // update the map

        supportedAssets.pop();

        emit AssetRemoved(address(this), manager(), key);
    }

    function exchange(
        bytes32 sourceKey,
        uint256 sourceAmount,
        bytes32 destinationKey
    ) public onlyManagerOrTrader {

        require(isAssetSupported(sourceKey), "unsupported source currency");
        require(
            isAssetSupported(destinationKey),
            "unsupported destination currency"
        );

        ISynthetix sx = ISynthetix(addressResolver.getAddress(_SYNTHETIX_KEY));

        uint256 destinationAmount = sx.exchangeWithTracking(
            sourceKey,
            sourceAmount,
            destinationKey,
            IHasDaoInfo(factory).getDaoAddress(),
            IHasFeeInfo(factory).getTrackingCode()
        );

        emit Exchange(
            address(this),
            msg.sender,
            sourceKey,
            sourceAmount,
            destinationKey,
            destinationAmount,
            block.timestamp
        );
    }

    function totalFundValue() public virtual view returns (uint256) {

        uint256 total = 0;
        uint256 assetCount = supportedAssets.length;

        for (uint256 i = 0; i < assetCount; i++) {
            total = total.add(assetValue(supportedAssets[i]));
        }
        return total;
    }

    function assetValue(bytes32 key) public view returns (uint256) {

        return
            IExchangeRates(addressResolver.getAddress(_EXCHANGE_RATES_KEY))
                .effectiveValue(
                key,
                IERC20(getAssetProxy(key)).balanceOf(address(this)),
                _SUSD_KEY
            );
    }

    function deposit(uint256 _susdAmount) public onlyPrivate returns (uint256) {

        lastDeposit[msg.sender] = block.timestamp;

        uint256 fundValue = mintManagerFee(true);

        uint256 totalSupplyBefore = totalSupply();

        IExchanger sx = IExchanger(addressResolver.getAddress(_EXCHANGER_KEY));

        require(
            IERC20(getAssetProxy(_SUSD_KEY)).transferFrom(
                msg.sender,
                address(this),
                _susdAmount
            ),
            "token transfer failed"
        );

        uint256 liquidityMinted;
        if (totalSupplyBefore > 0) {
            liquidityMinted = _susdAmount.mul(totalSupplyBefore).div(fundValue);
        } else {
            liquidityMinted = _susdAmount;
        }

        _mint(msg.sender, liquidityMinted);

        emit Deposit(
            address(this),
            msg.sender,
            _susdAmount,
            liquidityMinted,
            balanceOf(msg.sender),
            fundValue.add(_susdAmount),
            totalSupplyBefore.add(liquidityMinted),
            block.timestamp
        );

        return liquidityMinted;
    }

    function _settleAll(bool failOnSuspended) internal {

        ISynthetix sx = ISynthetix(addressResolver.getAddress(_SYNTHETIX_KEY));
        ISystemStatus status = ISystemStatus(addressResolver.getAddress(_SYSTEM_STATUS_KEY));

        uint256 assetCount = supportedAssets.length;

        for (uint256 i = 0; i < assetCount; i++) {

            address proxy = getAssetProxy(supportedAssets[i]);
            uint256 totalAssetBalance = IERC20(proxy).balanceOf(address(this));

            if (totalAssetBalance > 0) {
                sx.settle(supportedAssets[i]);
                if (failOnSuspended) {
                    (bool suspended, ) = status.synthExchangeSuspension(supportedAssets[i]);
                    require(!suspended , "required asset is suspended");
                }
            }

        }
    }

    function withdraw(uint256 _fundTokenAmount) public virtual {

        require(
            balanceOf(msg.sender) >= _fundTokenAmount,
            "insufficient balance of fund tokens"
        );

        require(
            getExitFeeRemainingCooldown(msg.sender) == 0,
            "cooldown active"
        );

        uint256 fundValue = mintManagerFee(false);
        uint256 valueWithdrawn = _fundTokenAmount.mul(fundValue).div(totalSupply());

        uint256 portion = _fundTokenAmount.mul(10**18).div(totalSupply());

        _burn(msg.sender, _fundTokenAmount);

        uint256 assetCount = supportedAssets.length;

        for (uint256 i = 0; i < assetCount; i++) {
            address proxy = getAssetProxy(supportedAssets[i]);
            uint256 totalAssetBalance = IERC20(proxy).balanceOf(address(this));
            uint256 portionOfAssetBalance = totalAssetBalance.mul(portion).div(10**18);

            if (portionOfAssetBalance > 0) {
                IERC20(proxy).transfer(msg.sender, portionOfAssetBalance);
            }
        }

        emit Withdrawal(
            address(this),
            msg.sender,
            valueWithdrawn,
            _fundTokenAmount,
            balanceOf(msg.sender),
            fundValue.sub(valueWithdrawn),
            totalSupply(),
            block.timestamp
        );
    }

    function getFundSummary()
        public
        view
        returns (
            string memory,
            uint256,
            uint256,
            address,
            string memory,
            uint256,
            bool,
            uint256,
            uint256,
            uint256,
            uint256
        )
    {


        uint256 managerFeeNumerator;
        uint256 managerFeeDenominator;
        (managerFeeNumerator, managerFeeDenominator) = IHasFeeInfo(factory).getPoolManagerFee(address(this));

        uint256 exitFeeNumerator = 0;
        uint256 exitFeeDenominator = 1;

        return (
            name(),
            totalSupply(),
            totalFundValue(),
            manager(),
            managerName(),
            creationTime,
            privatePool,
            managerFeeNumerator,
            managerFeeDenominator,
            exitFeeNumerator,
            exitFeeDenominator
        );
    }

    function getSupportedAssets() public view returns (bytes32[] memory) {

        return supportedAssets;
    }

    function getFundComposition()
        public
        view
        returns (
            bytes32[] memory,
            uint256[] memory,
            uint256[] memory
        )
    {

        uint256 assetCount = supportedAssets.length;

        bytes32[] memory assets = new bytes32[](assetCount);
        uint256[] memory balances = new uint256[](assetCount);
        uint256[] memory rates = new uint256[](assetCount);

        IExchangeRates exchangeRates = IExchangeRates(
            addressResolver.getAddress(_EXCHANGE_RATES_KEY)
        );
        for (uint256 i = 0; i < assetCount; i++) {
            bytes32 asset = supportedAssets[i];
            balances[i] = IERC20(getAssetProxy(asset)).balanceOf(address(this));
            assets[i] = asset;
            rates[i] = exchangeRates.rateForCurrency(asset);
        }
        return (assets, balances, rates);
    }

    function getWaitingPeriods()
        public
        view
        returns (
            bytes32[] memory,
            uint256[] memory
        )
    {

        uint256 assetCount = supportedAssets.length;

        bytes32[] memory assets = new bytes32[](assetCount);
        uint256[] memory periods = new uint256[](assetCount);

        IExchanger exchanger = IExchanger(addressResolver.getAddress(_EXCHANGER_KEY));

        for (uint256 i = 0; i < assetCount; i++) {
            bytes32 asset = supportedAssets[i];
            assets[i] = asset;
            periods[i] = exchanger.maxSecsLeftInWaitingPeriod(address(this), asset);
        }

        return (assets, periods);
    }


    function tokenPrice() public view returns (uint256) {

        uint256 fundValue = totalFundValue();
        uint256 tokenSupply = totalSupply();

        return _tokenPrice(fundValue, tokenSupply);
    }

    function _tokenPrice(uint256 _fundValue, uint256 _tokenSupply)
        internal
        pure
        returns (uint256)
    {

        if (_tokenSupply == 0 || _fundValue == 0) return 0;

        return _fundValue.mul(10**18).div(_tokenSupply);
    }

    function availableManagerFee() public view returns (uint256) {

        uint256 fundValue = totalFundValue();
        uint256 tokenSupply = totalSupply();

        uint256 managerFeeNumerator;
        uint256 managerFeeDenominator;
        (managerFeeNumerator, managerFeeDenominator) = IHasFeeInfo(factory).getPoolManagerFee(address(this));

        return
            _availableManagerFee(
                fundValue,
                tokenSupply,
                tokenPriceAtLastFeeMint,
                managerFeeNumerator,
                managerFeeDenominator
            );
    }

    function _availableManagerFee(
        uint256 _fundValue,
        uint256 _tokenSupply,
        uint256 _lastFeeMintPrice,
        uint256 _feeNumerator,
        uint256 _feeDenominator
    ) internal pure returns (uint256) {

        if (_tokenSupply == 0 || _fundValue == 0) return 0;

        uint256 currentTokenPrice = _fundValue.mul(10**18).div(_tokenSupply);

        if (currentTokenPrice <= _lastFeeMintPrice) return 0;

        uint256 available = currentTokenPrice
            .sub(_lastFeeMintPrice)
            .mul(_tokenSupply)
            .mul(_feeNumerator)
            .div(_feeDenominator)
            .div(currentTokenPrice);

        return available;
    }

    function mintManagerFee(bool failOnSuspended) public returns (uint256) {

        _settleAll(failOnSuspended);

        uint256 fundValue = totalFundValue();
        uint256 tokenSupply = totalSupply();

        uint256 managerFeeNumerator;
        uint256 managerFeeDenominator;
        (managerFeeNumerator, managerFeeDenominator) = IHasFeeInfo(factory).getPoolManagerFee(address(this));

        uint256 available = _availableManagerFee(
            fundValue,
            tokenSupply,
            tokenPriceAtLastFeeMint,
            managerFeeNumerator,
            managerFeeDenominator
        );

        if (available < 100)
            return fundValue;

        address daoAddress = IHasDaoInfo(factory).getDaoAddress();
        uint256 daoFeeNumerator;
        uint256 daoFeeDenominator;

        (daoFeeNumerator, daoFeeDenominator) = IHasDaoInfo(factory).getDaoFee();

        uint256 daoFee = available.mul(daoFeeNumerator).div(daoFeeDenominator);
        uint256 managerFee = available.sub(daoFee);

        if (daoFee > 0) _mint(daoAddress, daoFee);

        if (managerFee > 0) _mint(manager(), managerFee);

        tokenPriceAtLastFeeMint = _tokenPrice(fundValue, tokenSupply);

        emit ManagerFeeMinted(
            address(this),
            manager(),
            available,
            daoFee,
            managerFee,
            tokenPriceAtLastFeeMint
        );

        return fundValue;
    }

    function getManagerFee() public view returns (uint256, uint256) {

        return IHasFeeInfo(factory).getPoolManagerFee(address(this));
    }

    function setManagerFeeNumerator(uint256 numerator) public onlyManager {

        uint256 managerFeeNumerator;
        uint256 managerFeeDenominator;
        (managerFeeNumerator, managerFeeDenominator) = IHasFeeInfo(factory).getPoolManagerFee(address(this));

        require(numerator < managerFeeNumerator, "manager fee too high");

        IHasFeeInfo(factory).setPoolManagerFeeNumerator(address(this), numerator);

        emit ManagerFeeSet(
            address(this),
            manager(),
            numerator,
            managerFeeDenominator
        );
    }

    function _setManagerFeeNumerator(uint256 numerator) internal {

        IHasFeeInfo(factory).setPoolManagerFeeNumerator(address(this), numerator);
        
        uint256 managerFeeNumerator;
        uint256 managerFeeDenominator;
        (managerFeeNumerator, managerFeeDenominator) = IHasFeeInfo(factory).getPoolManagerFee(address(this));

        emit ManagerFeeSet(
            address(this),
            manager(),
            managerFeeNumerator,
            managerFeeDenominator
        );
    }

    function announceManagerFeeIncrease(uint256 numerator) public onlyManager {

        uint256 maximumAllowedChange = IHasFeeInfo(factory).getMaximumManagerFeeNumeratorChange();

        uint256 currentFeeNumerator;
        (currentFeeNumerator, ) = getManagerFee();

        require (numerator <= currentFeeNumerator.add(maximumAllowedChange), "exceeded allowed increase");

        uint256 feeChangeDelay = IHasFeeInfo(factory).getManagerFeeNumeratorChangeDelay(); 

        announcedFeeIncreaseNumerator = numerator;
        announcedFeeIncreaseTimestamp = block.timestamp + feeChangeDelay;
        emit ManagerFeeIncreaseAnnounced(numerator, announcedFeeIncreaseTimestamp);
    }

    function renounceManagerFeeIncrease() public onlyManager {

        announcedFeeIncreaseNumerator = 0;
        announcedFeeIncreaseTimestamp = 0;
        emit ManagerFeeIncreaseRenounced();
    }

    function commitManagerFeeIncrease() public onlyManager {

        require(block.timestamp >= announcedFeeIncreaseTimestamp, "fee increase delay active");

        _setManagerFeeNumerator(announcedFeeIncreaseNumerator);

        announcedFeeIncreaseNumerator = 0;
        announcedFeeIncreaseTimestamp = 0;
    }

    function getManagerFeeIncreaseInfo() public view returns (uint256, uint256) {

        return (announcedFeeIncreaseNumerator, announcedFeeIncreaseTimestamp);
    }


    function getExitFee() external view returns (uint256, uint256) {

        return (0, 1);
    }

    function getExitFeeCooldown() external view returns (uint256) {

        return IHasFeeInfo(factory).getExitFeeCooldown();
    }

    function getExitFeeRemainingCooldown(address sender) public view returns (uint256) {

        uint256 cooldown = IHasFeeInfo(factory).getExitFeeCooldown();
        uint256 cooldownFinished = lastDeposit[sender].add(cooldown);

        if (cooldownFinished < block.timestamp)
            return 0;

        return cooldownFinished.sub(block.timestamp);
    }
    

    function setLastDeposit(address investor) public onlyDhptSwap {

        lastDeposit[investor] = block.timestamp;
    }

    modifier onlyDhptSwap() {

        address dhptSwapAddress = IHasDhptSwapInfo(factory)
            .getDhptSwapAddress();
        require(msg.sender == dhptSwapAddress, "only swap contract");
        _;
    }


    function receiveUpgrade(uint256 targetVersion) external override{

        require(msg.sender == factory, "no permission");

        if (targetVersion == 1) {
            addressResolver = IAddressResolver(0x4E3b31eB0E5CB73641EE1E65E7dCEFe520bA3ef2);
            return;
        }

        require(false, "upgrade handler not found");
    }


    function redeemSynths(IERC20[] memory synthProxies, bytes32[] memory synthKeys) public {

        require(synthProxies.length == synthKeys.length, "invalid input");
        
        bytes32 synthRedeemerKey = "SynthRedeemer";
        address synthRedeemer = addressResolver.getAddress(synthRedeemerKey);

        for (uint256 i = 0; i < synthProxies.length; i++) {
            if (isAssetSupported(synthKeys[i])) {
                require(ISynthRedeemer(synthRedeemer).redemptions(address(synthProxies[i])) > 0, "synth is not deprecated");

                if (synthProxies[i].balanceOf(address(this)) > 0) {
                    ISynthRedeemer(synthRedeemer).redeem(synthProxies[i]);
                }

                if (synthProxies[i].balanceOf(address(this)) == 0 && !persistentAsset[synthKeys[i]]) {
                    _removeFromSupportedAssets(synthKeys[i]);
                }
            }
        }
    }

    uint256[50] private __gap;
}