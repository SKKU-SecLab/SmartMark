

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



contract Ownable is Initializable, Context {

    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    function initialize(address sender) public initializer {

        _owner = sender;
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

    uint256[50] private ______gap;
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


pragma solidity >=0.4.24;


interface ISynth {

    function currencyKey() external view returns (bytes32);


    function transferableSynths(address account) external view returns (uint);


    function transferAndSettle(address to, uint value) external returns (bool);


    function transferFromAndSettle(
        address from,
        address to,
        uint value
    ) external returns (bool);


    function burn(address account, uint amount) external;


    function issue(address account, uint amount) external;

}


pragma solidity >=0.4.24;



interface IVirtualSynth {

    function balanceOfUnderlying(address account) external view returns (uint);


    function rate() external view returns (uint);


    function readyToSettle() external view returns (bool);


    function secsLeftInWaitingPeriod() external view returns (uint);


    function settled() external view returns (bool);


    function synth() external view returns (ISynth);


    function settle(address account) external;

}


pragma solidity >=0.4.24;




interface ISynthetix {

    function anySynthOrSNXRateIsInvalid() external view returns (bool anyRateInvalid);


    function availableCurrencyKeys() external view returns (bytes32[] memory);


    function availableSynthCount() external view returns (uint);


    function availableSynths(uint index) external view returns (ISynth);


    function collateral(address account) external view returns (uint);


    function collateralisationRatio(address issuer) external view returns (uint);


    function debtBalanceOf(address issuer, bytes32 currencyKey) external view returns (uint);


    function isWaitingPeriod(bytes32 currencyKey) external view returns (bool);


    function maxIssuableSynths(address issuer) external view returns (uint maxIssuable);


    function remainingIssuableSynths(address issuer)
        external
        view
        returns (
            uint maxIssuable,
            uint alreadyIssued,
            uint totalSystemDebt
        );


    function synths(bytes32 currencyKey) external view returns (ISynth);


    function synthsByAddress(address synthAddress) external view returns (bytes32);


    function totalIssuedSynths(bytes32 currencyKey) external view returns (uint);


    function totalIssuedSynthsExcludeEtherCollateral(bytes32 currencyKey) external view returns (uint);


    function transferableSynthetix(address account) external view returns (uint transferable);


    function burnSynths(uint amount) external;


    function burnSynthsOnBehalf(address burnForAddress, uint amount) external;


    function burnSynthsToTarget() external;


    function burnSynthsToTargetOnBehalf(address burnForAddress) external;


    function exchange(
        bytes32 sourceCurrencyKey,
        uint sourceAmount,
        bytes32 destinationCurrencyKey
    ) external returns (uint amountReceived);


    function exchangeOnBehalf(
        address exchangeForAddress,
        bytes32 sourceCurrencyKey,
        uint sourceAmount,
        bytes32 destinationCurrencyKey
    ) external returns (uint amountReceived);


    function exchangeWithTracking(
        bytes32 sourceCurrencyKey,
        uint sourceAmount,
        bytes32 destinationCurrencyKey,
        address originator,
        bytes32 trackingCode
    ) external returns (uint amountReceived);


    function exchangeOnBehalfWithTracking(
        address exchangeForAddress,
        bytes32 sourceCurrencyKey,
        uint sourceAmount,
        bytes32 destinationCurrencyKey,
        address originator,
        bytes32 trackingCode
    ) external returns (uint amountReceived);


    function exchangeWithVirtual(
        bytes32 sourceCurrencyKey,
        uint sourceAmount,
        bytes32 destinationCurrencyKey,
        bytes32 trackingCode
    ) external returns (uint amountReceived, IVirtualSynth vSynth);


    function issueMaxSynths() external;


    function issueMaxSynthsOnBehalf(address issueForAddress) external;


    function issueSynths(uint amount) external;


    function issueSynthsOnBehalf(address issueForAddress, uint amount) external;


    function mint() external returns (bool);


    function settle(bytes32 currencyKey)
        external
        returns (
            uint reclaimed,
            uint refunded,
            uint numEntries
        );


    function liquidateDelinquentAccount(address account, uint susdAmount) external returns (bool);



    function mintSecondary(address account, uint amount) external;


    function mintSecondaryRewards(uint amount) external;


    function burnSecondary(address account, uint amount) external;

}


pragma solidity >=0.4.24;
pragma experimental ABIEncoderV2;


library VestingEntries {

    struct VestingEntry {
        uint64 endTime;
        uint256 escrowAmount;
    }
    struct VestingEntryWithID {
        uint64 endTime;
        uint256 escrowAmount;
        uint256 entryID;
    }
}


interface IRewardEscrowV2 {

    function balanceOf(address account) external view returns (uint);


    function numVestingEntries(address account) external view returns (uint);


    function totalEscrowedAccountBalance(address account) external view returns (uint);


    function totalVestedAccountBalance(address account) external view returns (uint);


    function getVestingQuantity(address account, uint256[] calldata entryIDs) external view returns (uint);


    function getVestingSchedules(
        address account,
        uint256 index,
        uint256 pageSize
    ) external view returns (VestingEntries.VestingEntryWithID[] memory);


    function getAccountVestingEntryIDs(
        address account,
        uint256 index,
        uint256 pageSize
    ) external view returns (uint256[] memory);


    function getVestingEntryClaimable(address account, uint256 entryID) external view returns (uint);


    function getVestingEntry(address account, uint256 entryID) external view returns (uint64, uint256);


    function vest(uint256[] calldata entryIDs) external;


    function createEscrowEntry(
        address beneficiary,
        uint256 deposit,
        uint256 duration
    ) external;


    function appendVestingEntry(
        address account,
        uint256 quantity,
        uint256 duration
    ) external;


    function migrateVestingSchedule(address _addressToMigrate) external;


    function migrateAccountEscrowBalances(
        address[] calldata accounts,
        uint256[] calldata escrowBalances,
        uint256[] calldata vestedBalances
    ) external;


    function startMergingWindow() external;


    function mergeAccount(address accountToMerge, uint256[] calldata entryIDs) external;


    function nominateAccountToMerge(address account) external;


    function accountMergingIsOpen() external view returns (bool);


    function importVestingEntries(
        address account,
        uint256 escrowedAmount,
        VestingEntries.VestingEntry[] calldata vestingEntries
    ) external;


    function burnForMigration(address account, uint256[] calldata entryIDs)
        external
        returns (uint256 escrowedAccountBalance, VestingEntries.VestingEntry[] memory vestingEntries);

}


pragma solidity >=0.4.24;


interface IExchangeRates {

    struct RateAndUpdatedTime {
        uint216 rate;
        uint40 time;
    }

    struct InversePricing {
        uint entryPoint;
        uint upperLimit;
        uint lowerLimit;
        bool frozenAtUpperLimit;
        bool frozenAtLowerLimit;
    }

    function aggregators(bytes32 currencyKey) external view returns (address);


    function aggregatorWarningFlags() external view returns (address);


    function anyRateIsInvalid(bytes32[] calldata currencyKeys) external view returns (bool);


    function canFreezeRate(bytes32 currencyKey) external view returns (bool);


    function currentRoundForRate(bytes32 currencyKey) external view returns (uint);


    function currenciesUsingAggregator(address aggregator) external view returns (bytes32[] memory);


    function effectiveValue(
        bytes32 sourceCurrencyKey,
        uint sourceAmount,
        bytes32 destinationCurrencyKey
    ) external view returns (uint value);


    function effectiveValueAndRates(
        bytes32 sourceCurrencyKey,
        uint sourceAmount,
        bytes32 destinationCurrencyKey
    )
        external
        view
        returns (
            uint value,
            uint sourceRate,
            uint destinationRate
        );


    function effectiveValueAtRound(
        bytes32 sourceCurrencyKey,
        uint sourceAmount,
        bytes32 destinationCurrencyKey,
        uint roundIdForSrc,
        uint roundIdForDest
    ) external view returns (uint value);


    function getCurrentRoundId(bytes32 currencyKey) external view returns (uint);


    function getLastRoundIdBeforeElapsedSecs(
        bytes32 currencyKey,
        uint startingRoundId,
        uint startingTimestamp,
        uint timediff
    ) external view returns (uint);


    function inversePricing(bytes32 currencyKey)
        external
        view
        returns (
            uint entryPoint,
            uint upperLimit,
            uint lowerLimit,
            bool frozenAtUpperLimit,
            bool frozenAtLowerLimit
        );


    function lastRateUpdateTimes(bytes32 currencyKey) external view returns (uint256);


    function oracle() external view returns (address);


    function rateAndTimestampAtRound(bytes32 currencyKey, uint roundId) external view returns (uint rate, uint time);


    function rateAndUpdatedTime(bytes32 currencyKey) external view returns (uint rate, uint time);


    function rateAndInvalid(bytes32 currencyKey) external view returns (uint rate, bool isInvalid);


    function rateForCurrency(bytes32 currencyKey) external view returns (uint);


    function rateIsFlagged(bytes32 currencyKey) external view returns (bool);


    function rateIsFrozen(bytes32 currencyKey) external view returns (bool);


    function rateIsInvalid(bytes32 currencyKey) external view returns (bool);


    function rateIsStale(bytes32 currencyKey) external view returns (bool);


    function rateStalePeriod() external view returns (uint);


    function ratesAndUpdatedTimeForCurrencyLastNRounds(bytes32 currencyKey, uint numRounds)
        external
        view
        returns (uint[] memory rates, uint[] memory times);


    function ratesAndInvalidForCurrencies(bytes32[] calldata currencyKeys)
        external
        view
        returns (uint[] memory rates, bool anyRateInvalid);


    function ratesForCurrencies(bytes32[] calldata currencyKeys) external view returns (uint[] memory);


    function freezeRate(bytes32 currencyKey) external;

}


pragma solidity >=0.4.24;


interface ISynthetixState {

    function debtLedger(uint index) external view returns (uint);


    function issuanceData(address account) external view returns (uint initialDebtOwnership, uint debtEntryIndex);


    function debtLedgerLength() external view returns (uint);


    function hasIssued(address account) external view returns (bool);


    function lastDebtLedgerEntry() external view returns (uint);


    function incrementTotalIssuerCount() external;


    function decrementTotalIssuerCount() external;


    function setCurrentIssuanceData(address account, uint initialDebtOwnership) external;


    function appendDebtLedgerValue(uint value) external;


    function clearIssuanceData(address account) external;

}


pragma solidity >=0.4.24;


interface IAddressResolver {

    function getAddress(bytes32 name) external view returns (address);


    function getSynth(bytes32 key) external view returns (address);


    function requireAndGetAddress(bytes32 name, string calldata reason) external view returns (address);

}


pragma solidity 0.5.15;

interface ISystemSettings {

    function issuanceRatio() external view returns(uint);

}


pragma solidity 0.5.15;

interface ICurveFi {

  function exchange(
    int128 i,
    int128 j,
    uint256 dx,
    uint256 min_dy
  ) external;

  function exchange_underlying(
    int128 i,
    int128 j,
    uint256 dx,
    uint256 min_dy
  ) external;

  function get_dx_underlying(
    int128 i,
    int128 j,
    uint256 dy
  ) external view returns (uint256);

  function get_dy_underlying(
    int128 i,
    int128 j,
    uint256 dx
  ) external view returns (uint256);

  function get_dx(
    int128 i,
    int128 j,
    uint256 dy
  ) external view returns (uint256);

  function get_dy(
    int128 i,
    int128 j,
    uint256 dx
  ) external view returns (uint256);

  function get_virtual_price() external view returns (uint256);

}


pragma solidity 0.5.15;

interface ISetToken {

    function unitShares() external view returns(uint);

    function naturalUnit() external view returns(uint);

    function currentSet() external view returns(address);

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


pragma solidity 0.5.15;


contract IKyberNetworkProxy {

    function getExpectedRate(ERC20 src, ERC20 dest, uint srcQty) external view returns (uint expectedRate, uint slippageRate);

    function swapEtherToToken(ERC20 token, uint minConversionRate) external payable returns(uint);

    function swapTokenToEther(ERC20 token, uint tokenQty, uint minRate) external payable returns(uint);

    function swapTokenToToken(ERC20 src, uint srcAmount, ERC20 dest, uint minConversionRate) public returns(uint);

}


pragma solidity 0.5.15;

interface ISetAssetBaseCollateral {

    function getComponents() external view returns(address[] memory);

    function naturalUnit() external view returns(uint);

    function getUnits() external view returns (uint256[] memory);

}


pragma solidity 0.5.15;



















contract TradeAccounting is Ownable {

    using SafeMath for uint256;

    uint256 private constant TEN = 10;
    uint256 private constant DEC_18 = 1e18;
    uint256 private constant PERCENT = 100;
    uint256 private constant ETH_TARGET = 4; // targets 1/4th of hedge portfolio
    uint256 private constant SLIPPAGE_RATE = 99;
    uint256 private constant MAX_UINT = 2**256 - 1;
    uint256 private constant RATE_STALE_TIME = 28800; // 8 hours
    uint256 private constant REBALANCE_THRESHOLD = 105; // 5%
    uint256 private constant INITIAL_SUPPLY_MULTIPLIER = 10;

    int128 usdcIndex;
    int128 susdIndex;

    ICurveFi private curveFi;
    ISynthetixState private synthetixState;
    IAddressResolver private addressResolver;
    IKyberNetworkProxy private kyberNetworkProxy;

    address private xSNXAdminInstance;
    address private addressValidator;

    address private setAddress;
    address private susdAddress;
    address private usdcAddress;

    address private nextCurveAddress;

    bytes32 constant snx = "SNX";
    bytes32 constant susd = "sUSD";
    bytes32 constant seth = "sETH";

    bytes32[2] synthSymbols;

    address[2] setComponentAddresses;

    bytes32 constant rewardEscrowName = "RewardEscrow";
    bytes32 constant exchangeRatesName = "ExchangeRates";
    bytes32 constant synthetixName = "Synthetix";
    bytes32 constant systemSettingsName = "SystemSettings";
    bytes32 constant rewardEscrowV2Name = "RewardEscrowV2";

    function initialize(
        address _setAddress,
        address _kyberProxyAddress,
        address _addressResolver,
        address _susdAddress,
        address _usdcAddress,
        address _addressValidator,
        bytes32[2] memory _synthSymbols,
        address[2] memory _setComponentAddresses,
        address _ownerAddress
    ) public initializer {

        Ownable.initialize(_ownerAddress);

        setAddress = _setAddress;
        kyberNetworkProxy = IKyberNetworkProxy(_kyberProxyAddress);
        addressResolver = IAddressResolver(_addressResolver);
        susdAddress = _susdAddress;
        usdcAddress = _usdcAddress;
        addressValidator = _addressValidator;
        synthSymbols = _synthSymbols;
        setComponentAddresses = _setComponentAddresses;
    }

    modifier onlyXSNXAdmin {

        require(
            msg.sender == xSNXAdminInstance,
            "Only xSNXAdmin contract can call"
        );
        _;
    }


    function swapTokenToToken(
        address fromToken,
        uint256 amount,
        address toToken,
        uint256 minKyberRate,
        uint256 minCurveReturn
    ) public onlyXSNXAdmin {

        if (fromToken == susdAddress) {
            _exchangeUnderlying(susdIndex, usdcIndex, amount, minCurveReturn);

            if (toToken != usdcAddress) {
                uint256 usdcBal = getUsdcBalance();
                _swapTokenToToken(usdcAddress, usdcBal, toToken, minKyberRate);
            }
        } else if (toToken == susdAddress) {
            if (fromToken != usdcAddress) {
                _swapTokenToToken(fromToken, amount, usdcAddress, minKyberRate);
            }

            uint256 usdcBal = getUsdcBalance();
            _exchangeUnderlying(usdcIndex, susdIndex, usdcBal, minCurveReturn);
        } else {
            _swapTokenToToken(fromToken, amount, toToken, minKyberRate);
        }

        IERC20(toToken).transfer(
            xSNXAdminInstance,
            IERC20(toToken).balanceOf(address(this))
        );
    }

    function _swapTokenToToken(
        address _fromToken,
        uint256 _amount,
        address _toToken,
        uint256 _minKyberRate
    ) private {

        kyberNetworkProxy.swapTokenToToken(
            ERC20(_fromToken),
            _amount,
            ERC20(_toToken),
            _minKyberRate
        );
    }

    function swapTokenToEther(
        address fromToken,
        uint256 amount,
        uint256 minKyberRate,
        uint256 minCurveReturn
    ) public onlyXSNXAdmin {

        if (fromToken == susdAddress) {
            _exchangeUnderlying(susdIndex, usdcIndex, amount, minCurveReturn);

            uint256 usdcBal = getUsdcBalance();
            _swapTokenToEther(usdcAddress, usdcBal, minKyberRate);
        } else {
            _swapTokenToEther(fromToken, amount, minKyberRate);
        }

        uint256 ethBal = address(this).balance;
        (bool success, ) = msg.sender.call.value(ethBal)("");
        require(success, "Transfer failed");
    }

    function _swapTokenToEther(
        address _fromToken,
        uint256 _amount,
        uint256 _minKyberRate
    ) private {

        kyberNetworkProxy.swapTokenToEther(
            ERC20(_fromToken),
            _amount,
            _minKyberRate
        );
    }

    function _exchangeUnderlying(
        int128 _inputIndex,
        int128 _outputIndex,
        uint256 _amount,
        uint256 _minReturn
    ) private {

        curveFi.exchange_underlying(
            _inputIndex,
            _outputIndex,
            _amount,
            _minReturn
        );
    }

    function getUsdcBalance() internal view returns (uint256) {

        return IERC20(usdcAddress).balanceOf(address(this));
    }


    function getEthBalance() public view returns (uint256) {

        return address(xSNXAdminInstance).balance;
    }

    function calculateRedemptionValue(
        uint256 totalSupply,
        uint256 tokensToRedeem
    ) public view returns (uint256 valueToRedeem) {

        uint256 snxBalanceOwned = getSnxBalanceOwned();
        uint256 contractDebtValue = getContractDebtValue();

        uint256 pricePerToken = calculateRedeemTokenPrice(
            totalSupply,
            snxBalanceOwned,
            contractDebtValue
        );

        valueToRedeem = pricePerToken.mul(tokensToRedeem).div(DEC_18);
    }

    function getMintWithEthUtils(uint256 totalSupply)
        public
        view
        returns (bool allocateToEth, uint256 nonSnxAssetValue)
    {

        uint256 setHoldingsInWei = getSetHoldingsValueInWei();

        uint256 ethBalBefore = getEthBalance();

        allocateToEth = shouldAllocateEthToEthReserve(
            setHoldingsInWei,
            ethBalBefore,
            totalSupply
        );
        nonSnxAssetValue = setHoldingsInWei.add(ethBalBefore);
    }

    function shouldAllocateEthToEthReserve(
        uint256 setHoldingsInWei,
        uint256 ethBalBefore,
        uint256 totalSupply
    ) public pure returns (bool allocateToEth) {

        if (totalSupply == 0) return false;

        if (ethBalBefore.mul(ETH_TARGET) < ethBalBefore.add(setHoldingsInWei)) {
            return true;
        }

        return false;
    }

    function calculateNetAssetValueOnMint(
        uint256 weiPerOneSnx,
        uint256 snxBalanceBefore,
        uint256 nonSnxAssetValue
    ) internal view returns (uint256) {

        uint256 snxTokenValueInWei = snxBalanceBefore.mul(weiPerOneSnx).div(
            DEC_18
        );
        uint256 contractDebtValue = getContractDebtValue();
        uint256 contractDebtValueInWei = calculateDebtValueInWei(
            contractDebtValue
        );
        return
            snxTokenValueInWei.add(nonSnxAssetValue).sub(
                contractDebtValueInWei
            );
    }

    function calculateNetAssetValueOnRedeem(
        uint256 weiPerOneSnx,
        uint256 snxBalanceOwned,
        uint256 contractDebtValueInWei
    ) internal view returns (uint256) {

        uint256 snxTokenValueInWei = snxBalanceOwned.mul(weiPerOneSnx).div(
            DEC_18
        );
        uint256 nonSnxAssetValue = calculateNonSnxAssetValue();
        return
            snxTokenValueInWei.add(nonSnxAssetValue).sub(
                contractDebtValueInWei
            );
    }

    function calculateNonSnxAssetValue() internal view returns (uint256) {

        return getSetHoldingsValueInWei().add(getEthBalance());
    }

    function getWeiPerOneSnxOnRedeem()
        internal
        view
        returns (uint256 weiPerOneSnx)
    {

        uint256 snxUsdPrice = getSnxPrice();
        uint256 ethUsdPrice = getSynthPrice(seth);
        weiPerOneSnx = snxUsdPrice
            .mul(DEC_18)
            .div(ethUsdPrice)
            .mul(SLIPPAGE_RATE) // used to better represent liquidation price as volume scales
            .div(PERCENT);
    }

    function getActiveAssetSynthSymbol()
        internal
        view
        returns (bytes32 synthSymbol)
    {

        synthSymbol = getAssetCurrentlyActiveInSet() == setComponentAddresses[0]
            ? (synthSymbols[0])
            : (synthSymbols[1]);
    }

    function getWeiPerOneSnxOnMint() internal view returns (uint256) {

        uint256 snxUsd = getSynthPrice(snx);
        uint256 ethUsd = getSynthPrice(seth);
        return snxUsd.mul(DEC_18).div(ethUsd);
    }

    function getInitialSupply() internal view returns (uint256) {

        return
            IERC20(addressResolver.getAddress(synthetixName))
                .balanceOf(xSNXAdminInstance)
                .mul(INITIAL_SUPPLY_MULTIPLIER);
    }

    function calculateTokensToMintWithEth(
        uint256 snxBalanceBefore,
        uint256 ethContributed,
        uint256 nonSnxAssetValue,
        uint256 totalSupply,
        bool allocateToEth
    ) public view returns (uint256) {

        if (totalSupply == 0) {
            return getInitialSupply();
        }

        uint256 weiPerOneSnx;
        if (allocateToEth) {
            weiPerOneSnx = getWeiPerOneSnxOnMint();
        } else {
            uint256 snxBalanceAfter = getSnxBalance();
            uint256 snxContributed = snxBalanceAfter.sub(snxBalanceBefore);
            weiPerOneSnx = ethContributed.mul(DEC_18).div(snxContributed);
        }

        uint256 pricePerToken = calculateIssueTokenPrice(
            weiPerOneSnx,
            snxBalanceBefore,
            nonSnxAssetValue,
            totalSupply
        );

        return ethContributed.mul(DEC_18).div(pricePerToken);
    }

    function calculateTokensToMintWithSnx(
        uint256 snxBalanceBefore,
        uint256 snxAddedToBalance,
        uint256 totalSupply
    ) public view returns (uint256) {

        if (totalSupply == 0) {
            return getInitialSupply();
        }

        uint256 weiPerOneSnx = getWeiPerOneSnxOnMint();
        uint256 proxyEthContribution = weiPerOneSnx.mul(snxAddedToBalance).div(
            DEC_18
        );
        uint256 nonSnxAssetValue = calculateNonSnxAssetValue();
        uint256 pricePerToken = calculateIssueTokenPrice(
            weiPerOneSnx,
            snxBalanceBefore,
            nonSnxAssetValue,
            totalSupply
        );
        return proxyEthContribution.mul(DEC_18).div(pricePerToken);
    }

    function calculateIssueTokenPrice(
        uint256 weiPerOneSnx,
        uint256 snxBalanceBefore,
        uint256 nonSnxAssetValue,
        uint256 totalSupply
    ) public view returns (uint256 pricePerToken) {

        pricePerToken = calculateNetAssetValueOnMint(
            weiPerOneSnx,
            snxBalanceBefore,
            nonSnxAssetValue
        )
            .mul(DEC_18)
            .div(totalSupply);
    }

    function calculateRedeemTokenPrice(
        uint256 totalSupply,
        uint256 snxBalanceOwned,
        uint256 contractDebtValue
    ) public view returns (uint256 pricePerToken) {

        uint256 weiPerOneSnx = getWeiPerOneSnxOnRedeem();

        uint256 debtValueInWei = calculateDebtValueInWei(contractDebtValue);
        pricePerToken = calculateNetAssetValueOnRedeem(
            weiPerOneSnx,
            snxBalanceOwned,
            debtValueInWei
        )
            .mul(DEC_18)
            .div(totalSupply);
    }


    function getActiveSetAssetBalance() public view returns (uint256) {

        return
            IERC20(getAssetCurrentlyActiveInSet()).balanceOf(xSNXAdminInstance);
    }

    function calculateSetQuantity(uint256 componentQuantity)
        public
        view
        returns (uint256 rebalancingSetQuantity)
    {

        uint256 baseSetNaturalUnit = getBaseSetNaturalUnit();
        uint256 baseSetComponentUnits = getBaseSetComponentUnits();
        uint256 baseSetIssuable = componentQuantity.mul(baseSetNaturalUnit).div(
            baseSetComponentUnits
        );

        uint256 rebalancingSetNaturalUnit = getSetNaturalUnit();
        uint256 unitShares = getSetUnitShares();
        rebalancingSetQuantity = baseSetIssuable
            .mul(rebalancingSetNaturalUnit)
            .div(unitShares)
            .mul(99) // ensure sufficient balance in underlying asset
            .div(100)
            .div(rebalancingSetNaturalUnit)
            .mul(rebalancingSetNaturalUnit);
    }

    function calculateSetIssuanceQuantity()
        public
        view
        returns (uint256 rebalancingSetIssuable)
    {

        uint256 componentQuantity = getActiveSetAssetBalance();
        rebalancingSetIssuable = calculateSetQuantity(componentQuantity);
    }

    function calculateSetRedemptionQuantity(uint256 totalSusdToBurn)
        public
        view
        returns (uint256 rebalancingSetRedeemable)
    {

        address currentSetAsset = getAssetCurrentlyActiveInSet();

        bytes32 activeAssetSynthSymbol = getActiveAssetSynthSymbol();
        uint256 synthUsd = getSynthPrice(activeAssetSynthSymbol);

        uint256 expectedSetAssetRate = DEC_18.mul(DEC_18).div(synthUsd);

        uint256 setAssetCollateralToSell = expectedSetAssetRate
            .mul(totalSusdToBurn)
            .div(DEC_18)
            .mul(103) // err on the high side
            .div(PERCENT);

        uint256 decimals = (TEN**ERC20Detailed(currentSetAsset).decimals());
        setAssetCollateralToSell = setAssetCollateralToSell.mul(decimals).div(
            DEC_18
        );

        rebalancingSetRedeemable = calculateSetQuantity(
            setAssetCollateralToSell
        );
    }

    function calculateEthValueOfOneSetUnit()
        internal
        view
        returns (uint256 ethValue)
    {

        uint256 unitShares = getSetUnitShares();
        uint256 rebalancingSetNaturalUnit = getSetNaturalUnit();
        uint256 baseSetRequired = DEC_18.mul(unitShares).div(
            rebalancingSetNaturalUnit
        );

        uint256 unitsOfUnderlying = getBaseSetComponentUnits();
        uint256 baseSetNaturalUnit = getBaseSetNaturalUnit();
        uint256 componentRequired = baseSetRequired.mul(unitsOfUnderlying).div(
            baseSetNaturalUnit
        );

        address currentSetAsset = getAssetCurrentlyActiveInSet();
        uint256 decimals = (TEN**ERC20Detailed(currentSetAsset).decimals());
        componentRequired = componentRequired.mul(DEC_18).div(decimals);

        bytes32 activeAssetSynthSymbol = getActiveAssetSynthSymbol();

        uint256 synthUsd = getSynthPrice(activeAssetSynthSymbol);
        uint256 ethUsd = getSynthPrice(seth);
        ethValue = componentRequired.mul(synthUsd).div(ethUsd);
    }

    function getSetHoldingsValueInWei()
        public
        view
        returns (uint256 setValInWei)
    {

        uint256 setCollateralTokens = getSetCollateralTokens();
        bytes32 synthSymbol = getActiveAssetSynthSymbol();
        address currentSetAsset = getAssetCurrentlyActiveInSet();

        uint256 synthUsd = getSynthPrice(synthSymbol);
        uint256 ethUsd = getSynthPrice(seth);

        uint256 decimals = (TEN**ERC20Detailed(currentSetAsset).decimals());
        setCollateralTokens = setCollateralTokens.mul(DEC_18).div(decimals);
        setValInWei = setCollateralTokens.mul(synthUsd).div(ethUsd);
    }

    function getBaseSetNaturalUnit() internal view returns (uint256) {

        return getCurrentCollateralSet().naturalUnit();
    }

    function getAssetCurrentlyActiveInSet() public view returns (address) {

        address[] memory currentAllocation = getCurrentCollateralSet()
            .getComponents();
        return currentAllocation[0];
    }

    function getCurrentCollateralSet()
        internal
        view
        returns (ISetAssetBaseCollateral)
    {

        return ISetAssetBaseCollateral(getCurrentSet());
    }

    function getCurrentSet() internal view returns (address) {

        return ISetToken(setAddress).currentSet();
    }

    function getSetCollateralTokens() internal view returns (uint256) {

        return
            getSetBalanceCollateral().mul(getBaseSetComponentUnits()).div(
                getBaseSetNaturalUnit()
            );
    }

    function getSetBalanceCollateral() internal view returns (uint256) {

        uint256 unitShares = getSetUnitShares();
        uint256 naturalUnit = getSetNaturalUnit();
        return getContractSetBalance().mul(unitShares).div(naturalUnit);
    }

    function getSetUnitShares() internal view returns (uint256) {

        return ISetToken(setAddress).unitShares();
    }

    function getSetNaturalUnit() internal view returns (uint256) {

        return ISetToken(setAddress).naturalUnit();
    }

    function getContractSetBalance() internal view returns (uint256) {

        return IERC20(setAddress).balanceOf(xSNXAdminInstance);
    }

    function getBaseSetComponentUnits() internal view returns (uint256) {

        return ISetAssetBaseCollateral(getCurrentSet()).getUnits()[0];
    }


    function getSusdBalance() public view returns (uint256) {

        return IERC20(susdAddress).balanceOf(xSNXAdminInstance);
    }

    function getSnxBalance() public view returns (uint256) {

        return getSnxBalanceOwned().add(getSnxBalanceEscrowed());
    }

    function getSnxBalanceOwned() internal view returns (uint256) {

        return
            IERC20(addressResolver.getAddress(synthetixName)).balanceOf(
                xSNXAdminInstance
            );
    }

    function getSnxBalanceEscrowed() internal view returns (uint256) {

        return
            IRewardEscrowV2(addressResolver.getAddress(rewardEscrowV2Name))
                .balanceOf(xSNXAdminInstance);
    }

    function getContractEscrowedSnxValue() internal view returns (uint256) {

        return getSnxBalanceEscrowed().mul(getSnxPrice()).div(DEC_18);
    }

    function getContractOwnedSnxValue() internal view returns (uint256) {

        return getSnxBalanceOwned().mul(getSnxPrice()).div(DEC_18);
    }

    function getSnxPrice() internal view returns (uint256) {

        (uint256 rate, uint256 time) = IExchangeRates(
            addressResolver.getAddress(exchangeRatesName)
        )
            .rateAndUpdatedTime(snx);
        require(time.add(RATE_STALE_TIME) > block.timestamp, "Rate stale");
        return rate;
    }

    function getSynthPrice(bytes32 synth) internal view returns (uint256) {

        (uint256 rate, uint256 time) = IExchangeRates(
            addressResolver.getAddress(exchangeRatesName)
        )
            .rateAndUpdatedTime(synth);
        if (synth != susd) {
            require(time.add(RATE_STALE_TIME) > block.timestamp, "Rate stale");
        }
        return rate;
    }

    function calculateDebtValueInWei(uint256 debtValue)
        internal
        view
        returns (uint256 debtBalanceInWei)
    {

        uint256 ethUsd = getSynthPrice(seth);
        debtBalanceInWei = debtValue.mul(DEC_18).div(ethUsd);
    }

    function getContractDebtValue() internal view returns (uint256) {

        return
            ISynthetix(addressResolver.getAddress(synthetixName)).debtBalanceOf(
                xSNXAdminInstance,
                susd
            );
    }

    function getIssuanceRatio() internal view returns (uint256) {

        return
            ISystemSettings(addressResolver.getAddress(systemSettingsName))
                .issuanceRatio();
    }

    function getContractSnxValue() internal view returns (uint256) {

        return getSnxBalance().mul(getSnxPrice()).div(DEC_18);
    }


    function calculateSusdToBurnToFixRatio(
        uint256 snxValueHeld,
        uint256 contractDebtValue,
        uint256 issuanceRatio
    ) internal pure returns (uint256) {

        uint256 subtractor = issuanceRatio.mul(snxValueHeld).div(DEC_18);

        if (subtractor > contractDebtValue) return 0;
        return contractDebtValue.sub(subtractor);
    }

    function calculateSusdToBurnToFixRatioExternal()
        public
        view
        returns (uint256)
    {

        uint256 snxValueHeld = getContractSnxValue();
        uint256 debtValue = getContractDebtValue();
        uint256 issuanceRatio = getIssuanceRatio();
        return
            calculateSusdToBurnToFixRatio(
                snxValueHeld,
                debtValue,
                issuanceRatio
            );
    }

    function calculateSusdToBurnToEclipseEscrowed(uint256 issuanceRatio)
        public
        view
        returns (uint256)
    {

        uint256 escrowedSnxValue = getContractEscrowedSnxValue();
        if (escrowedSnxValue == 0) return 0;

        return escrowedSnxValue.mul(issuanceRatio).div(DEC_18);
    }

    function calculateSusdToBurnForRedemption(
        uint256 tokensToRedeem,
        uint256 totalSupply,
        uint256 contractDebtValue,
        uint256 issuanceRatio
    ) public view returns (uint256 susdToBurn) {

        uint256 nonEscrowedSnxValue = getContractOwnedSnxValue();
        uint256 lockedSnxValue = contractDebtValue.mul(DEC_18).div(
            issuanceRatio
        );
        uint256 valueOfSnxToSell = nonEscrowedSnxValue.mul(tokensToRedeem).div(
            totalSupply
        );
        susdToBurn = (
            lockedSnxValue.add(valueOfSnxToSell).sub(nonEscrowedSnxValue)
        )
            .mul(issuanceRatio)
            .div(DEC_18);
    }


    function calculateAssetChangesForRebalanceToHedge()
        internal
        view
        returns (uint256 totalSusdToBurn, uint256 snxToSell)
    {

        uint256 snxValueHeld = getContractSnxValue();
        uint256 debtValueInUsd = getContractDebtValue();
        uint256 issuanceRatio = getIssuanceRatio();

        uint256 susdToBurnToFixRatio = calculateSusdToBurnToFixRatio(
            snxValueHeld,
            debtValueInUsd,
            issuanceRatio
        );


            uint256 susdToBurnToEclipseEscrowed
         = calculateSusdToBurnToEclipseEscrowed(issuanceRatio);

        uint256 hedgeAssetsValueInUsd = calculateHedgeAssetsValueInUsd();
        uint256 valueToUnlockInUsd = debtValueInUsd.sub(hedgeAssetsValueInUsd);

        uint256 susdToBurnToUnlockTransfer = valueToUnlockInUsd
            .mul(issuanceRatio)
            .div(DEC_18);

        totalSusdToBurn = (
            susdToBurnToFixRatio.add(susdToBurnToEclipseEscrowed).add(
                susdToBurnToUnlockTransfer
            )
        );
        snxToSell = valueToUnlockInUsd.mul(DEC_18).div(getSnxPrice());
    }

    function calculateAssetChangesForRebalanceToSnx()
        public
        view
        returns (uint256 setToSell)
    {

        (
            uint256 debtValueInWei,
            uint256 hedgeAssetsBalance
        ) = getRebalanceUtils();
        uint256 setValueToSell = hedgeAssetsBalance.sub(debtValueInWei);
        uint256 ethValueOfOneSet = calculateEthValueOfOneSetUnit();
        setToSell = setValueToSell.mul(DEC_18).div(ethValueOfOneSet);

        uint256 naturalUnit = getSetNaturalUnit();
        setToSell = setToSell.div(naturalUnit).mul(naturalUnit);
    }

    function getRebalanceTowardsSnxUtils()
        public
        view
        returns (uint256 setToSell, address activeAsset)
    {

        setToSell = calculateAssetChangesForRebalanceToSnx();
        activeAsset = getAssetCurrentlyActiveInSet();
    }

    function getRebalanceUtils()
        public
        view
        returns (uint256 debtValueInWei, uint256 hedgeAssetsBalance)
    {

        uint256 setHoldingsInWei = getSetHoldingsValueInWei();
        uint256 ethBalance = getEthBalance();

        uint256 debtValue = getContractDebtValue();
        debtValueInWei = calculateDebtValueInWei(debtValue);
        hedgeAssetsBalance = setHoldingsInWei.add(ethBalance);
    }

    function calculateHedgeAssetsValueInUsd()
        internal
        view
        returns (uint256 hedgeAssetsValueInUsd)
    {

        address currentSetAsset = getAssetCurrentlyActiveInSet();
        uint256 decimals = (TEN**ERC20Detailed(currentSetAsset).decimals());
        uint256 setCollateralTokens = getSetCollateralTokens();
        setCollateralTokens = setCollateralTokens.mul(DEC_18).div(decimals);

        bytes32 activeAssetSynthSymbol = getActiveAssetSynthSymbol();

        uint256 synthUsd = getSynthPrice(activeAssetSynthSymbol);
        uint256 setValueUsd = setCollateralTokens.mul(synthUsd).div(DEC_18);

        uint256 ethBalance = getEthBalance();
        uint256 ethUsd = getSynthPrice(seth);
        uint256 ethValueUsd = ethBalance.mul(ethUsd).div(DEC_18);

        hedgeAssetsValueInUsd = setValueUsd.add(ethValueUsd);
    }

    function isRebalanceTowardsSnxRequired() public view returns (bool) {

        (
            uint256 debtValueInWei,
            uint256 hedgeAssetsBalance
        ) = getRebalanceUtils();

        if (
            debtValueInWei.mul(REBALANCE_THRESHOLD).div(PERCENT) <
            hedgeAssetsBalance
        ) {
            return true;
        }

        return false;
    }

    function isRebalanceTowardsHedgeRequired() public view returns (bool) {

        (
            uint256 debtValueInWei,
            uint256 hedgeAssetsBalance
        ) = getRebalanceUtils();

        if (
            hedgeAssetsBalance.mul(REBALANCE_THRESHOLD).div(PERCENT) <
            debtValueInWei
        ) {
            return true;
        }

        return false;
    }

    function getRebalanceTowardsHedgeUtils()
        public
        view
        returns (
            uint256,
            uint256,
            address
        )
    {

        (
            uint256 totalSusdToBurn,
            uint256 snxToSell
        ) = calculateAssetChangesForRebalanceToHedge();
        address activeAsset = getAssetCurrentlyActiveInSet();
        return (totalSusdToBurn, snxToSell, activeAsset);
    }

    function getEthAllocationOnHedge(uint256 susdBal)
        public
        view
        returns (uint256 ethAllocation)
    {

        uint256 ethUsd = getSynthPrice(seth);

        uint256 setHoldingsInUsd = getSetHoldingsValueInWei().mul(ethUsd).div(
            DEC_18
        );
        uint256 ethBalInUsd = getEthBalance().mul(ethUsd).div(DEC_18);
        uint256 hedgeAssets = setHoldingsInUsd.add(ethBalInUsd);

        if (ethBalInUsd.mul(ETH_TARGET) >= hedgeAssets.add(susdBal)) {
        } else if ((ethBalInUsd.add(susdBal)).mul(ETH_TARGET) < hedgeAssets) {
            ethAllocation = susdBal;
        } else {
            ethAllocation = ((hedgeAssets.add(susdBal)).div(ETH_TARGET)).sub(
                ethBalInUsd
            );
        }
    }

    function calculateSetToSellForRebalanceSetToEth()
        public
        view
        returns (uint256 setQuantityToSell)
    {

        uint256 setHoldingsInWei = getSetHoldingsValueInWei();
        uint256 ethBal = getEthBalance();
        uint256 hedgeAssets = setHoldingsInWei.add(ethBal);
        require(
            ethBal.mul(ETH_TARGET) < hedgeAssets,
            "Rebalance not necessary"
        );

        uint256 ethToAdd = ((hedgeAssets.div(ETH_TARGET)).sub(ethBal));
        setQuantityToSell = getContractSetBalance().mul(ethToAdd).div(
            setHoldingsInWei
        );

        uint256 naturalUnit = getSetNaturalUnit();
        setQuantityToSell = setQuantityToSell.div(naturalUnit).mul(naturalUnit);
    }


    function setAdminInstanceAddress(address _xSNXAdminInstance)
        public
        onlyOwner
    {

        if (xSNXAdminInstance == address(0)) {
            xSNXAdminInstance = _xSNXAdminInstance;
        }
    }

    function setCurve(
        address curvePoolAddress,
        int128 _usdcIndex,
        int128 _susdIndex
    ) public onlyOwner {

        if (address(curveFi) == address(0)) {
            curveFi = ICurveFi(curvePoolAddress);
            nextCurveAddress = curvePoolAddress;
        } else {
            nextCurveAddress = curvePoolAddress;
        }
        usdcIndex = _usdcIndex;
        susdIndex = _susdIndex;
    }


    function approveKyber(address tokenAddress) public onlyOwner {

        IERC20(tokenAddress).approve(address(kyberNetworkProxy), MAX_UINT);
    }

    function approveCurve(address tokenAddress) public onlyOwner {

        IERC20(tokenAddress).approve(address(curveFi), MAX_UINT);
    }

    function confirmCurveAddress(address _nextCurveAddress) public {

        require(msg.sender == addressValidator, "Incorrect caller");
        require(nextCurveAddress == _nextCurveAddress, "Addresses don't match");
        curveFi = ICurveFi(nextCurveAddress);
    }

    function() external payable {}
}