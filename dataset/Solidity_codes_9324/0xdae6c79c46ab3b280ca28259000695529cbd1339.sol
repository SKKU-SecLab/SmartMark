



pragma solidity ^0.5.16;

contract Owned {

    address public owner;
    address public nominatedOwner;

    constructor(address _owner) public {
        require(_owner != address(0), "Owner address cannot be 0");
        owner = _owner;
        emit OwnerChanged(address(0), _owner);
    }

    function nominateNewOwner(address _owner) external onlyOwner {

        nominatedOwner = _owner;
        emit OwnerNominated(_owner);
    }

    function acceptOwnership() external {

        require(msg.sender == nominatedOwner, "You must be nominated before you can accept ownership");
        emit OwnerChanged(owner, nominatedOwner);
        owner = nominatedOwner;
        nominatedOwner = address(0);
    }

    modifier onlyOwner {

        _onlyOwner();
        _;
    }

    function _onlyOwner() private view {

        require(msg.sender == owner, "Only the contract owner may perform this action");
    }

    event OwnerNominated(address newOwner);
    event OwnerChanged(address oldOwner, address newOwner);
}






contract Proxy is Owned {

    Proxyable public target;

    constructor(address _owner) public Owned(_owner) {}

    function setTarget(Proxyable _target) external onlyOwner {

        target = _target;
        emit TargetUpdated(_target);
    }

    function _emit(
        bytes calldata callData,
        uint numTopics,
        bytes32 topic1,
        bytes32 topic2,
        bytes32 topic3,
        bytes32 topic4
    ) external onlyTarget {

        uint size = callData.length;
        bytes memory _callData = callData;

        assembly {
            switch numTopics
                case 0 {
                    log0(add(_callData, 32), size)
                }
                case 1 {
                    log1(add(_callData, 32), size, topic1)
                }
                case 2 {
                    log2(add(_callData, 32), size, topic1, topic2)
                }
                case 3 {
                    log3(add(_callData, 32), size, topic1, topic2, topic3)
                }
                case 4 {
                    log4(add(_callData, 32), size, topic1, topic2, topic3, topic4)
                }
        }
    }

    function() external payable {
        target.setMessageSender(msg.sender);

        assembly {
            let free_ptr := mload(0x40)
            calldatacopy(free_ptr, 0, calldatasize)

            let result := call(gas, sload(target_slot), callvalue, free_ptr, calldatasize, 0, 0)
            returndatacopy(free_ptr, 0, returndatasize)

            if iszero(result) {
                revert(free_ptr, returndatasize)
            }
            return(free_ptr, returndatasize)
        }
    }

    modifier onlyTarget {

        require(Proxyable(msg.sender) == target, "Must be proxy target");
        _;
    }

    event TargetUpdated(Proxyable newTarget);
}






contract Proxyable is Owned {


    Proxy public proxy;

    address public messageSender;

    constructor(address payable _proxy) internal {
        require(owner != address(0), "Owner must be set");

        proxy = Proxy(_proxy);
        emit ProxyUpdated(_proxy);
    }

    function setProxy(address payable _proxy) external onlyOwner {

        proxy = Proxy(_proxy);
        emit ProxyUpdated(_proxy);
    }

    function setMessageSender(address sender) external onlyProxy {

        messageSender = sender;
    }

    modifier onlyProxy {

        _onlyProxy();
        _;
    }

    function _onlyProxy() private view {

        require(Proxy(msg.sender) == proxy, "Only the proxy can call");
    }

    modifier optionalProxy {

        _optionalProxy();
        _;
    }

    function _optionalProxy() private {

        if (Proxy(msg.sender) != proxy && messageSender != msg.sender) {
            messageSender = msg.sender;
        }
    }

    modifier optionalProxy_onlyOwner {

        _optionalProxy_onlyOwner();
        _;
    }

    function _optionalProxy_onlyOwner() private {

        if (Proxy(msg.sender) != proxy && messageSender != msg.sender) {
            messageSender = msg.sender;
        }
        require(messageSender == owner, "Owner only function");
    }

    event ProxyUpdated(address proxyAddress);
}


library SafeMath {

    function add(uint256 a, uint256 b) internal pure returns (uint256) {

        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b <= a, "SafeMath: subtraction overflow");
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

        require(b > 0, "SafeMath: division by zero");
        uint256 c = a / b;

        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b != 0, "SafeMath: modulo by zero");
        return a % b;
    }
}




library SafeDecimalMath {

    using SafeMath for uint;

    uint8 public constant decimals = 18;
    uint8 public constant highPrecisionDecimals = 27;

    uint public constant UNIT = 10**uint(decimals);

    uint public constant PRECISE_UNIT = 10**uint(highPrecisionDecimals);
    uint private constant UNIT_TO_HIGH_PRECISION_CONVERSION_FACTOR = 10**uint(highPrecisionDecimals - decimals);

    function unit() external pure returns (uint) {

        return UNIT;
    }

    function preciseUnit() external pure returns (uint) {

        return PRECISE_UNIT;
    }

    function multiplyDecimal(uint x, uint y) internal pure returns (uint) {

        return x.mul(y) / UNIT;
    }

    function _multiplyDecimalRound(
        uint x,
        uint y,
        uint precisionUnit
    ) private pure returns (uint) {

        uint quotientTimesTen = x.mul(y) / (precisionUnit / 10);

        if (quotientTimesTen % 10 >= 5) {
            quotientTimesTen += 10;
        }

        return quotientTimesTen / 10;
    }

    function multiplyDecimalRoundPrecise(uint x, uint y) internal pure returns (uint) {

        return _multiplyDecimalRound(x, y, PRECISE_UNIT);
    }

    function multiplyDecimalRound(uint x, uint y) internal pure returns (uint) {

        return _multiplyDecimalRound(x, y, UNIT);
    }

    function divideDecimal(uint x, uint y) internal pure returns (uint) {

        return x.mul(UNIT).div(y);
    }

    function _divideDecimalRound(
        uint x,
        uint y,
        uint precisionUnit
    ) private pure returns (uint) {

        uint resultTimesTen = x.mul(precisionUnit * 10).div(y);

        if (resultTimesTen % 10 >= 5) {
            resultTimesTen += 10;
        }

        return resultTimesTen / 10;
    }

    function divideDecimalRound(uint x, uint y) internal pure returns (uint) {

        return _divideDecimalRound(x, y, UNIT);
    }

    function divideDecimalRoundPrecise(uint x, uint y) internal pure returns (uint) {

        return _divideDecimalRound(x, y, PRECISE_UNIT);
    }

    function decimalToPreciseDecimal(uint i) internal pure returns (uint) {

        return i.mul(UNIT_TO_HIGH_PRECISION_CONVERSION_FACTOR);
    }

    function preciseDecimalToDecimal(uint i) internal pure returns (uint) {

        uint quotientTimesTen = i / (UNIT_TO_HIGH_PRECISION_CONVERSION_FACTOR / 10);

        if (quotientTimesTen % 10 >= 5) {
            quotientTimesTen += 10;
        }

        return quotientTimesTen / 10;
    }

    function floorsub(uint a, uint b) internal pure returns (uint) {

        return b >= a ? 0 : a - b;
    }

    function signedAbs(int x) internal pure returns (int) {

        return x < 0 ? -x : x;
    }

    function abs(int x) internal pure returns (uint) {

        return uint(signedAbs(x));
    }
}




contract State is Owned {

    address public associatedContract;

    constructor(address _associatedContract) internal {
        require(owner != address(0), "Owner must be set");

        associatedContract = _associatedContract;
        emit AssociatedContractUpdated(_associatedContract);
    }


    function setAssociatedContract(address _associatedContract) external onlyOwner {

        associatedContract = _associatedContract;
        emit AssociatedContractUpdated(_associatedContract);
    }


    modifier onlyAssociatedContract {

        require(msg.sender == associatedContract, "Only the associated contract can perform this action");
        _;
    }


    event AssociatedContractUpdated(address associatedContract);
}




contract TokenState is Owned, State {

    mapping(address => uint) public balanceOf;
    mapping(address => mapping(address => uint)) public allowance;

    constructor(address _owner, address _associatedContract) public Owned(_owner) State(_associatedContract) {}


    function setAllowance(
        address tokenOwner,
        address spender,
        uint value
    ) external onlyAssociatedContract {

        allowance[tokenOwner][spender] = value;
    }

    function setBalanceOf(address account, uint value) external onlyAssociatedContract {

        balanceOf[account] = value;
    }
}








contract ExternStateToken is Owned, Proxyable {

    using SafeMath for uint;
    using SafeDecimalMath for uint;


    TokenState public tokenState;

    string public name;
    string public symbol;
    uint public totalSupply;
    uint8 public decimals;

    constructor(
        address payable _proxy,
        TokenState _tokenState,
        string memory _name,
        string memory _symbol,
        uint _totalSupply,
        uint8 _decimals,
        address _owner
    ) public Owned(_owner) Proxyable(_proxy) {
        tokenState = _tokenState;

        name = _name;
        symbol = _symbol;
        totalSupply = _totalSupply;
        decimals = _decimals;
    }


    function allowance(address owner, address spender) public view returns (uint) {

        return tokenState.allowance(owner, spender);
    }

    function balanceOf(address account) external view returns (uint) {

        return tokenState.balanceOf(account);
    }


    function setTokenState(TokenState _tokenState) external optionalProxy_onlyOwner {

        tokenState = _tokenState;
        emitTokenStateUpdated(address(_tokenState));
    }

    function _internalTransfer(
        address from,
        address to,
        uint value
    ) internal returns (bool) {

        require(to != address(0) && to != address(this) && to != address(proxy), "Cannot transfer to this address");

        tokenState.setBalanceOf(from, tokenState.balanceOf(from).sub(value));
        tokenState.setBalanceOf(to, tokenState.balanceOf(to).add(value));

        emitTransfer(from, to, value);

        return true;
    }

    function _transferByProxy(
        address from,
        address to,
        uint value
    ) internal returns (bool) {

        return _internalTransfer(from, to, value);
    }

    function _transferFromByProxy(
        address sender,
        address from,
        address to,
        uint value
    ) internal returns (bool) {

        tokenState.setAllowance(from, sender, tokenState.allowance(from, sender).sub(value));
        return _internalTransfer(from, to, value);
    }

    function approve(address spender, uint value) public optionalProxy returns (bool) {

        address sender = messageSender;

        tokenState.setAllowance(sender, spender, value);
        emitApproval(sender, spender, value);
        return true;
    }

    function addressToBytes32(address input) internal pure returns (bytes32) {

        return bytes32(uint256(uint160(input)));
    }

    event Transfer(address indexed from, address indexed to, uint value);
    bytes32 internal constant TRANSFER_SIG = keccak256("Transfer(address,address,uint256)");

    function emitTransfer(
        address from,
        address to,
        uint value
    ) internal {

        proxy._emit(abi.encode(value), 3, TRANSFER_SIG, addressToBytes32(from), addressToBytes32(to), 0);
    }

    event Approval(address indexed owner, address indexed spender, uint value);
    bytes32 internal constant APPROVAL_SIG = keccak256("Approval(address,address,uint256)");

    function emitApproval(
        address owner,
        address spender,
        uint value
    ) internal {

        proxy._emit(abi.encode(value), 3, APPROVAL_SIG, addressToBytes32(owner), addressToBytes32(spender), 0);
    }

    event TokenStateUpdated(address newTokenState);
    bytes32 internal constant TOKENSTATEUPDATED_SIG = keccak256("TokenStateUpdated(address)");

    function emitTokenStateUpdated(address newTokenState) internal {

        proxy._emit(abi.encode(newTokenState), 1, TOKENSTATEUPDATED_SIG, 0, 0, 0);
    }
}


interface IAddressResolver {

    function getAddress(bytes32 name) external view returns (address);


    function getSynth(bytes32 key) external view returns (address);


    function requireAndGetAddress(bytes32 name, string calldata reason) external view returns (address);

}


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


interface IIssuer {


    function allNetworksDebtInfo()
        external
        view
        returns (
            uint256 debt,
            uint256 sharesSupply,
            bool isStale
        );


    function anySynthOrSNXRateIsInvalid() external view returns (bool anyRateInvalid);


    function availableCurrencyKeys() external view returns (bytes32[] memory);


    function availableSynthCount() external view returns (uint);


    function availableSynths(uint index) external view returns (ISynth);


    function canBurnSynths(address account) external view returns (bool);


    function collateral(address account) external view returns (uint);


    function collateralisationRatio(address issuer) external view returns (uint);


    function collateralisationRatioAndAnyRatesInvalid(address _issuer)
        external
        view
        returns (uint cratio, bool anyRateIsInvalid);


    function debtBalanceOf(address issuer, bytes32 currencyKey) external view returns (uint debtBalance);


    function issuanceRatio() external view returns (uint);


    function lastIssueEvent(address account) external view returns (uint);


    function maxIssuableSynths(address issuer) external view returns (uint maxIssuable);


    function minimumStakeTime() external view returns (uint);


    function remainingIssuableSynths(address issuer)
        external
        view
        returns (
            uint maxIssuable,
            uint alreadyIssued,
            uint totalSystemDebt
        );


    function synths(bytes32 currencyKey) external view returns (ISynth);


    function getSynths(bytes32[] calldata currencyKeys) external view returns (ISynth[] memory);


    function synthsByAddress(address synthAddress) external view returns (bytes32);


    function totalIssuedSynths(bytes32 currencyKey, bool excludeOtherCollateral) external view returns (uint);


    function transferableSynthetixAndAnyRateIsInvalid(address account, uint balance)
        external
        view
        returns (uint transferable, bool anyRateIsInvalid);


    function addSynths(ISynth[] calldata synthsToAdd) external;


    function issueSynths(address from, uint amount) external;


    function issueSynthsOnBehalf(
        address issueFor,
        address from,
        uint amount
    ) external;


    function issueMaxSynths(address from) external;


    function issueMaxSynthsOnBehalf(address issueFor, address from) external;


    function burnSynths(address from, uint amount) external;


    function burnSynthsOnBehalf(
        address burnForAddress,
        address from,
        uint amount
    ) external;


    function burnSynthsToTarget(address from) external;


    function burnSynthsToTargetOnBehalf(address burnForAddress, address from) external;


    function burnForRedemption(
        address deprecatedSynthProxy,
        address account,
        uint balance
    ) external;


    function setCurrentPeriodId(uint128 periodId) external;


    function liquidateAccount(address account, bool isSelfLiquidation)
        external
        returns (uint totalRedeemed, uint amountToLiquidate);


    function issueSynthsWithoutDebt(
        bytes32 currencyKey,
        address to,
        uint amount
    ) external returns (bool rateInvalid);


    function burnSynthsWithoutDebt(
        bytes32 currencyKey,
        address to,
        uint amount
    ) external returns (bool rateInvalid);

}






contract AddressResolver is Owned, IAddressResolver {

    mapping(bytes32 => address) public repository;

    constructor(address _owner) public Owned(_owner) {}


    function importAddresses(bytes32[] calldata names, address[] calldata destinations) external onlyOwner {

        require(names.length == destinations.length, "Input lengths must match");

        for (uint i = 0; i < names.length; i++) {
            bytes32 name = names[i];
            address destination = destinations[i];
            repository[name] = destination;
            emit AddressImported(name, destination);
        }
    }


    function rebuildCaches(MixinResolver[] calldata destinations) external {

        for (uint i = 0; i < destinations.length; i++) {
            destinations[i].rebuildCache();
        }
    }


    function areAddressesImported(bytes32[] calldata names, address[] calldata destinations) external view returns (bool) {

        for (uint i = 0; i < names.length; i++) {
            if (repository[names[i]] != destinations[i]) {
                return false;
            }
        }
        return true;
    }

    function getAddress(bytes32 name) external view returns (address) {

        return repository[name];
    }

    function requireAndGetAddress(bytes32 name, string calldata reason) external view returns (address) {

        address _foundAddress = repository[name];
        require(_foundAddress != address(0), reason);
        return _foundAddress;
    }

    function getSynth(bytes32 key) external view returns (address) {

        IIssuer issuer = IIssuer(repository["Issuer"]);
        require(address(issuer) != address(0), "Cannot find Issuer address");
        return address(issuer.synths(key));
    }


    event AddressImported(bytes32 name, address destination);
}




contract MixinResolver {

    AddressResolver public resolver;

    mapping(bytes32 => address) private addressCache;

    constructor(address _resolver) internal {
        resolver = AddressResolver(_resolver);
    }


    function combineArrays(bytes32[] memory first, bytes32[] memory second)
        internal
        pure
        returns (bytes32[] memory combination)
    {

        combination = new bytes32[](first.length + second.length);

        for (uint i = 0; i < first.length; i++) {
            combination[i] = first[i];
        }

        for (uint j = 0; j < second.length; j++) {
            combination[first.length + j] = second[j];
        }
    }


    function resolverAddressesRequired() public view returns (bytes32[] memory addresses) {}


    function rebuildCache() public {

        bytes32[] memory requiredAddresses = resolverAddressesRequired();
        for (uint i = 0; i < requiredAddresses.length; i++) {
            bytes32 name = requiredAddresses[i];
            address destination =
                resolver.requireAndGetAddress(name, string(abi.encodePacked("Resolver missing target: ", name)));
            addressCache[name] = destination;
            emit CacheUpdated(name, destination);
        }
    }


    function isResolverCached() external view returns (bool) {

        bytes32[] memory requiredAddresses = resolverAddressesRequired();
        for (uint i = 0; i < requiredAddresses.length; i++) {
            bytes32 name = requiredAddresses[i];
            if (resolver.getAddress(name) != addressCache[name] || addressCache[name] == address(0)) {
                return false;
            }
        }

        return true;
    }


    function requireAndGetAddress(bytes32 name) internal view returns (address) {

        address _foundAddress = addressCache[name];
        require(_foundAddress != address(0), string(abi.encodePacked("Missing address: ", name)));
        return _foundAddress;
    }


    event CacheUpdated(bytes32 name, address destination);
}


interface IERC20 {

    function name() external view returns (string memory);


    function symbol() external view returns (string memory);


    function decimals() external view returns (uint8);


    function totalSupply() external view returns (uint);


    function balanceOf(address owner) external view returns (uint);


    function allowance(address owner, address spender) external view returns (uint);


    function transfer(address to, uint value) external returns (bool);


    function approve(address spender, uint value) external returns (bool);


    function transferFrom(
        address from,
        address to,
        uint value
    ) external returns (bool);


    event Transfer(address indexed from, address indexed to, uint value);

    event Approval(address indexed owner, address indexed spender, uint value);
}


interface ISystemStatus {

    struct Status {
        bool canSuspend;
        bool canResume;
    }

    struct Suspension {
        bool suspended;
        uint248 reason;
    }

    function accessControl(bytes32 section, address account) external view returns (bool canSuspend, bool canResume);


    function requireSystemActive() external view;


    function systemSuspended() external view returns (bool);


    function requireIssuanceActive() external view;


    function requireExchangeActive() external view;


    function requireFuturesActive() external view;


    function requireFuturesMarketActive(bytes32 marketKey) external view;


    function requireExchangeBetweenSynthsAllowed(bytes32 sourceCurrencyKey, bytes32 destinationCurrencyKey) external view;


    function requireSynthActive(bytes32 currencyKey) external view;


    function synthSuspended(bytes32 currencyKey) external view returns (bool);


    function requireSynthsActive(bytes32 sourceCurrencyKey, bytes32 destinationCurrencyKey) external view;


    function systemSuspension() external view returns (bool suspended, uint248 reason);


    function issuanceSuspension() external view returns (bool suspended, uint248 reason);


    function exchangeSuspension() external view returns (bool suspended, uint248 reason);


    function futuresSuspension() external view returns (bool suspended, uint248 reason);


    function synthExchangeSuspension(bytes32 currencyKey) external view returns (bool suspended, uint248 reason);


    function synthSuspension(bytes32 currencyKey) external view returns (bool suspended, uint248 reason);


    function futuresMarketSuspension(bytes32 marketKey) external view returns (bool suspended, uint248 reason);


    function getSynthExchangeSuspensions(bytes32[] calldata synths)
        external
        view
        returns (bool[] memory exchangeSuspensions, uint256[] memory reasons);


    function getSynthSuspensions(bytes32[] calldata synths)
        external
        view
        returns (bool[] memory suspensions, uint256[] memory reasons);


    function getFuturesMarketSuspensions(bytes32[] calldata marketKeys)
        external
        view
        returns (bool[] memory suspensions, uint256[] memory reasons);


    function suspendIssuance(uint256 reason) external;


    function suspendSynth(bytes32 currencyKey, uint256 reason) external;


    function suspendFuturesMarket(bytes32 marketKey, uint256 reason) external;


    function updateAccessControl(
        bytes32 section,
        address account,
        bool canSuspend,
        bool canResume
    ) external;

}


interface IFeePool {


    function FEE_ADDRESS() external view returns (address);


    function feesAvailable(address account) external view returns (uint, uint);


    function feePeriodDuration() external view returns (uint);


    function isFeesClaimable(address account) external view returns (bool);


    function targetThreshold() external view returns (uint);


    function totalFeesAvailable() external view returns (uint);


    function totalRewardsAvailable() external view returns (uint);


    function claimFees() external returns (bool);


    function claimOnBehalf(address claimingForAddress) external returns (bool);


    function closeCurrentFeePeriod() external;


    function closeSecondary(uint snxBackedDebt, uint debtShareSupply) external;


    function recordFeePaid(uint sUSDAmount) external;


    function setRewardsToDistribute(uint amount) external;

}


interface IVirtualSynth {

    function balanceOfUnderlying(address account) external view returns (uint);


    function rate() external view returns (uint);


    function readyToSettle() external view returns (bool);


    function secsLeftInWaitingPeriod() external view returns (uint);


    function settled() external view returns (bool);


    function synth() external view returns (ISynth);


    function settle(address account) external;

}


interface IExchanger {

    struct ExchangeEntrySettlement {
        bytes32 src;
        uint amount;
        bytes32 dest;
        uint reclaim;
        uint rebate;
        uint srcRoundIdAtPeriodEnd;
        uint destRoundIdAtPeriodEnd;
        uint timestamp;
    }

    struct ExchangeEntry {
        uint sourceRate;
        uint destinationRate;
        uint destinationAmount;
        uint exchangeFeeRate;
        uint exchangeDynamicFeeRate;
        uint roundIdForSrc;
        uint roundIdForDest;
    }

    function calculateAmountAfterSettlement(
        address from,
        bytes32 currencyKey,
        uint amount,
        uint refunded
    ) external view returns (uint amountAfterSettlement);


    function isSynthRateInvalid(bytes32 currencyKey) external view returns (bool);


    function maxSecsLeftInWaitingPeriod(address account, bytes32 currencyKey) external view returns (uint);


    function settlementOwing(address account, bytes32 currencyKey)
        external
        view
        returns (
            uint reclaimAmount,
            uint rebateAmount,
            uint numEntries
        );


    function hasWaitingPeriodOrSettlementOwing(address account, bytes32 currencyKey) external view returns (bool);


    function feeRateForExchange(bytes32 sourceCurrencyKey, bytes32 destinationCurrencyKey) external view returns (uint);


    function dynamicFeeRateForExchange(bytes32 sourceCurrencyKey, bytes32 destinationCurrencyKey)
        external
        view
        returns (uint feeRate, bool tooVolatile);


    function getAmountsForExchange(
        uint sourceAmount,
        bytes32 sourceCurrencyKey,
        bytes32 destinationCurrencyKey
    )
        external
        view
        returns (
            uint amountReceived,
            uint fee,
            uint exchangeFeeRate
        );


    function priceDeviationThresholdFactor() external view returns (uint);


    function waitingPeriodSecs() external view returns (uint);


    function lastExchangeRate(bytes32 currencyKey) external view returns (uint);


    function exchange(
        address exchangeForAddress,
        address from,
        bytes32 sourceCurrencyKey,
        uint sourceAmount,
        bytes32 destinationCurrencyKey,
        address destinationAddress,
        bool virtualSynth,
        address rewardAddress,
        bytes32 trackingCode
    ) external returns (uint amountReceived, IVirtualSynth vSynth);


    function exchangeAtomically(
        address from,
        bytes32 sourceCurrencyKey,
        uint sourceAmount,
        bytes32 destinationCurrencyKey,
        address destinationAddress,
        bytes32 trackingCode,
        uint minAmount
    ) external returns (uint amountReceived);


    function settle(address from, bytes32 currencyKey)
        external
        returns (
            uint reclaimed,
            uint refunded,
            uint numEntries
        );


    function suspendSynthWithInvalidRate(bytes32 currencyKey) external;

}


interface IFuturesMarketManager {

    function markets(uint index, uint pageSize) external view returns (address[] memory);


    function numMarkets() external view returns (uint);


    function allMarkets() external view returns (address[] memory);


    function marketForKey(bytes32 marketKey) external view returns (address);


    function marketsForKeys(bytes32[] calldata marketKeys) external view returns (address[] memory);


    function totalDebt() external view returns (uint debt, bool isInvalid);

}






contract Synth is Owned, IERC20, ExternStateToken, MixinResolver, ISynth {

    bytes32 public constant CONTRACT_NAME = "Synth";


    bytes32 public currencyKey;

    uint8 public constant DECIMALS = 18;

    address public constant FEE_ADDRESS = 0xfeEFEEfeefEeFeefEEFEEfEeFeefEEFeeFEEFEeF;


    bytes32 private constant CONTRACT_SYSTEMSTATUS = "SystemStatus";
    bytes32 private constant CONTRACT_EXCHANGER = "Exchanger";
    bytes32 private constant CONTRACT_ISSUER = "Issuer";
    bytes32 private constant CONTRACT_FEEPOOL = "FeePool";
    bytes32 private constant CONTRACT_FUTURESMARKETMANAGER = "FuturesMarketManager";


    constructor(
        address payable _proxy,
        TokenState _tokenState,
        string memory _tokenName,
        string memory _tokenSymbol,
        address _owner,
        bytes32 _currencyKey,
        uint _totalSupply,
        address _resolver
    )
        public
        ExternStateToken(_proxy, _tokenState, _tokenName, _tokenSymbol, _totalSupply, DECIMALS, _owner)
        MixinResolver(_resolver)
    {
        require(_proxy != address(0), "_proxy cannot be 0");
        require(_owner != address(0), "_owner cannot be 0");

        currencyKey = _currencyKey;
    }


    function transfer(address to, uint value) public onlyProxyOrInternal returns (bool) {

        _ensureCanTransfer(messageSender, value);

        if (to == FEE_ADDRESS) {
            return _transferToFeeAddress(to, value);
        }

        if (to == address(0)) {
            return _internalBurn(messageSender, value);
        }

        return super._internalTransfer(messageSender, to, value);
    }

    function transferAndSettle(address to, uint value) public onlyProxyOrInternal returns (bool) {

        (, , uint numEntriesSettled) = exchanger().settle(messageSender, currencyKey);

        uint balanceAfter = value;

        if (numEntriesSettled > 0) {
            balanceAfter = tokenState.balanceOf(messageSender);
        }

        value = value > balanceAfter ? balanceAfter : value;

        return super._internalTransfer(messageSender, to, value);
    }

    function transferFrom(
        address from,
        address to,
        uint value
    ) public onlyProxyOrInternal returns (bool) {

        _ensureCanTransfer(from, value);

        return _internalTransferFrom(from, to, value);
    }

    function transferFromAndSettle(
        address from,
        address to,
        uint value
    ) public onlyProxyOrInternal returns (bool) {

        (, , uint numEntriesSettled) = exchanger().settle(from, currencyKey);

        uint balanceAfter = value;

        if (numEntriesSettled > 0) {
            balanceAfter = tokenState.balanceOf(from);
        }

        value = value >= balanceAfter ? balanceAfter : value;

        return _internalTransferFrom(from, to, value);
    }

    function _transferToFeeAddress(address to, uint value) internal returns (bool) {

        uint amountInUSD;

        if (currencyKey == "sUSD") {
            amountInUSD = value;
            super._internalTransfer(messageSender, to, value);
        } else {
            (amountInUSD, ) = exchanger().exchange(
                messageSender,
                messageSender,
                currencyKey,
                value,
                "sUSD",
                FEE_ADDRESS,
                false,
                address(0),
                bytes32(0)
            );
        }

        feePool().recordFeePaid(amountInUSD);

        return true;
    }

    function issue(address account, uint amount) external onlyInternalContracts {

        _internalIssue(account, amount);
    }

    function burn(address account, uint amount) external onlyInternalContracts {

        _internalBurn(account, amount);
    }

    function _internalIssue(address account, uint amount) internal {

        tokenState.setBalanceOf(account, tokenState.balanceOf(account).add(amount));
        totalSupply = totalSupply.add(amount);
        emitTransfer(address(0), account, amount);
        emitIssued(account, amount);
    }

    function _internalBurn(address account, uint amount) internal returns (bool) {

        tokenState.setBalanceOf(account, tokenState.balanceOf(account).sub(amount));
        totalSupply = totalSupply.sub(amount);
        emitTransfer(account, address(0), amount);
        emitBurned(account, amount);

        return true;
    }

    function setTotalSupply(uint amount) external optionalProxy_onlyOwner {

        totalSupply = amount;
    }


    function resolverAddressesRequired() public view returns (bytes32[] memory addresses) {

        addresses = new bytes32[](5);
        addresses[0] = CONTRACT_SYSTEMSTATUS;
        addresses[1] = CONTRACT_EXCHANGER;
        addresses[2] = CONTRACT_ISSUER;
        addresses[3] = CONTRACT_FEEPOOL;
        addresses[4] = CONTRACT_FUTURESMARKETMANAGER;
    }

    function systemStatus() internal view returns (ISystemStatus) {

        return ISystemStatus(requireAndGetAddress(CONTRACT_SYSTEMSTATUS));
    }

    function feePool() internal view returns (IFeePool) {

        return IFeePool(requireAndGetAddress(CONTRACT_FEEPOOL));
    }

    function exchanger() internal view returns (IExchanger) {

        return IExchanger(requireAndGetAddress(CONTRACT_EXCHANGER));
    }

    function issuer() internal view returns (IIssuer) {

        return IIssuer(requireAndGetAddress(CONTRACT_ISSUER));
    }

    function futuresMarketManager() internal view returns (IFuturesMarketManager) {

        return IFuturesMarketManager(requireAndGetAddress(CONTRACT_FUTURESMARKETMANAGER));
    }

    function _ensureCanTransfer(address from, uint value) internal view {

        require(exchanger().maxSecsLeftInWaitingPeriod(from, currencyKey) == 0, "Cannot transfer during waiting period");
        require(transferableSynths(from) >= value, "Insufficient balance after any settlement owing");
        systemStatus().requireSynthActive(currencyKey);
    }

    function transferableSynths(address account) public view returns (uint) {

        (uint reclaimAmount, , ) = exchanger().settlementOwing(account, currencyKey);


        uint balance = tokenState.balanceOf(account);

        if (reclaimAmount > balance) {
            return 0;
        } else {
            return balance.sub(reclaimAmount);
        }
    }


    function _internalTransferFrom(
        address from,
        address to,
        uint value
    ) internal returns (bool) {

        if (tokenState.allowance(from, messageSender) != uint(-1)) {
            tokenState.setAllowance(from, messageSender, tokenState.allowance(from, messageSender).sub(value));
        }

        return super._internalTransfer(from, to, value);
    }


    function _isInternalContract(address account) internal view returns (bool) {

        return
            account == address(feePool()) ||
            account == address(exchanger()) ||
            account == address(issuer()) ||
            account == address(futuresMarketManager());
    }

    modifier onlyInternalContracts() {

        require(_isInternalContract(msg.sender), "Only internal contracts allowed");
        _;
    }

    modifier onlyProxyOrInternal {

        _onlyProxyOrInternal();
        _;
    }

    function _onlyProxyOrInternal() internal {

        if (msg.sender == address(proxy)) {
            return;
        } else if (_isInternalTransferCaller(msg.sender)) {
            messageSender = msg.sender;
        } else {
            revert("Only the proxy can call");
        }
    }

    function _isInternalTransferCaller(address caller) internal view returns (bool) {

        return
            caller == resolver.getAddress("CollateralShort") ||
            caller == resolver.getAddress("SynthRedeemer") ||
            caller == resolver.getAddress("WrapperFactory") || // transfer not used by users
            caller == resolver.getAddress("NativeEtherWrapper") ||
            caller == resolver.getAddress("Depot");
    }

    event Issued(address indexed account, uint value);

    bytes32 private constant ISSUED_SIG = keccak256("Issued(address,uint256)");

    function emitIssued(address account, uint value) internal {

        proxy._emit(abi.encode(value), 2, ISSUED_SIG, addressToBytes32(account), 0, 0);
    }

    event Burned(address indexed account, uint value);

    bytes32 private constant BURNED_SIG = keccak256("Burned(address,uint256)");

    function emitBurned(address account, uint value) internal {

        proxy._emit(abi.encode(value), 2, BURNED_SIG, addressToBytes32(account), 0, 0);
    }
}


interface ICollateralManager {

    function hasCollateral(address collateral) external view returns (bool);


    function isSynthManaged(bytes32 currencyKey) external view returns (bool);


    function long(bytes32 synth) external view returns (uint amount);


    function short(bytes32 synth) external view returns (uint amount);


    function totalLong() external view returns (uint susdValue, bool anyRateIsInvalid);


    function totalShort() external view returns (uint susdValue, bool anyRateIsInvalid);


    function getBorrowRate() external view returns (uint borrowRate, bool anyRateIsInvalid);


    function getShortRate(bytes32 synth) external view returns (uint shortRate, bool rateIsInvalid);


    function getRatesAndTime(uint index)
        external
        view
        returns (
            uint entryRate,
            uint lastRate,
            uint lastUpdated,
            uint newIndex
        );


    function getShortRatesAndTime(bytes32 currency, uint index)
        external
        view
        returns (
            uint entryRate,
            uint lastRate,
            uint lastUpdated,
            uint newIndex
        );


    function exceedsDebtLimit(uint amount, bytes32 currency) external view returns (bool canIssue, bool anyRateIsInvalid);


    function areSynthsAndCurrenciesSet(bytes32[] calldata requiredSynthNamesInResolver, bytes32[] calldata synthKeys)
        external
        view
        returns (bool);


    function areShortableSynthsSet(bytes32[] calldata requiredSynthNamesInResolver, bytes32[] calldata synthKeys)
        external
        view
        returns (bool);


    function getNewLoanId() external returns (uint id);


    function addCollaterals(address[] calldata collaterals) external;


    function removeCollaterals(address[] calldata collaterals) external;


    function addSynths(bytes32[] calldata synthNamesInResolver, bytes32[] calldata synthKeys) external;


    function removeSynths(bytes32[] calldata synths, bytes32[] calldata synthKeys) external;


    function addShortableSynths(bytes32[] calldata requiredSynthNamesInResolver, bytes32[] calldata synthKeys) external;


    function removeShortableSynths(bytes32[] calldata synths) external;



    function incrementLongs(bytes32 synth, uint amount) external;


    function decrementLongs(bytes32 synth, uint amount) external;


    function incrementShorts(bytes32 synth, uint amount) external;


    function decrementShorts(bytes32 synth, uint amount) external;


    function accrueInterest(
        uint interestIndex,
        bytes32 currency,
        bool isShort
    ) external returns (uint difference, uint index);


    function updateBorrowRatesCollateral(uint rate) external;


    function updateShortRatesCollateral(bytes32 currency, uint rate) external;

}


interface IWETH {

    function name() external view returns (string memory);


    function symbol() external view returns (string memory);


    function decimals() external view returns (uint8);


    function totalSupply() external view returns (uint);


    function balanceOf(address owner) external view returns (uint);


    function allowance(address owner, address spender) external view returns (uint);


    function transfer(address to, uint value) external returns (bool);


    function approve(address spender, uint value) external returns (bool);


    function transferFrom(
        address from,
        address to,
        uint value
    ) external returns (bool);


    function deposit() external payable;


    function withdraw(uint amount) external;


    event Transfer(address indexed from, address indexed to, uint value);
    event Approval(address indexed owner, address indexed spender, uint value);
    event Deposit(address indexed to, uint amount);
    event Withdrawal(address indexed to, uint amount);
}


contract IEtherWrapper {

    function mint(uint amount) external;


    function burn(uint amount) external;


    function distributeFees() external;


    function capacity() external view returns (uint);


    function getReserves() external view returns (uint);


    function totalIssuedSynths() external view returns (uint);


    function calculateMintFee(uint amount) public view returns (uint);


    function calculateBurnFee(uint amount) public view returns (uint);


    function maxETH() public view returns (uint256);


    function mintFeeRate() public view returns (uint256);


    function burnFeeRate() public view returns (uint256);


    function weth() public view returns (IWETH);

}


interface IWrapperFactory {

    function isWrapper(address possibleWrapper) external view returns (bool);


    function createWrapper(
        IERC20 token,
        bytes32 currencyKey,
        bytes32 synthContractName
    ) external returns (address);


    function distributeFees() external;

}






contract MultiCollateralSynth is Synth {

    bytes32 public constant CONTRACT_NAME = "MultiCollateralSynth";


    bytes32 private constant CONTRACT_COLLATERALMANAGER = "CollateralManager";
    bytes32 private constant CONTRACT_ETHER_WRAPPER = "EtherWrapper";
    bytes32 private constant CONTRACT_WRAPPER_FACTORY = "WrapperFactory";


    constructor(
        address payable _proxy,
        TokenState _tokenState,
        string memory _tokenName,
        string memory _tokenSymbol,
        address _owner,
        bytes32 _currencyKey,
        uint _totalSupply,
        address _resolver
    ) public Synth(_proxy, _tokenState, _tokenName, _tokenSymbol, _owner, _currencyKey, _totalSupply, _resolver) {}


    function collateralManager() internal view returns (ICollateralManager) {

        return ICollateralManager(requireAndGetAddress(CONTRACT_COLLATERALMANAGER));
    }

    function etherWrapper() internal view returns (IEtherWrapper) {

        return IEtherWrapper(requireAndGetAddress(CONTRACT_ETHER_WRAPPER));
    }

    function wrapperFactory() internal view returns (IWrapperFactory) {

        return IWrapperFactory(requireAndGetAddress(CONTRACT_WRAPPER_FACTORY));
    }

    function resolverAddressesRequired() public view returns (bytes32[] memory addresses) {

        bytes32[] memory existingAddresses = Synth.resolverAddressesRequired();
        bytes32[] memory newAddresses = new bytes32[](3);
        newAddresses[0] = CONTRACT_COLLATERALMANAGER;
        newAddresses[1] = CONTRACT_ETHER_WRAPPER;
        newAddresses[2] = CONTRACT_WRAPPER_FACTORY;
        addresses = combineArrays(existingAddresses, newAddresses);
    }


    function issue(address account, uint amount) external onlyInternalContracts {

        super._internalIssue(account, amount);
    }

    function burn(address account, uint amount) external onlyInternalContracts {

        super._internalBurn(account, amount);
    }


    function _isInternalContract(address account) internal view returns (bool) {

        return
            super._isInternalContract(account) ||
            collateralManager().hasCollateral(account) ||
            wrapperFactory().isWrapper(account) ||
            (account == address(etherWrapper()));
    }
}