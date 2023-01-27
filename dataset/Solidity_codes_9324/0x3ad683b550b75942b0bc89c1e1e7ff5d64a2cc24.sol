



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




contract Pausable is Owned {

    uint public lastPauseTime;
    bool public paused;

    constructor() internal {
        require(owner != address(0), "Owner must be set");
    }

    function setPaused(bool _paused) external onlyOwner {

        if (_paused == paused) {
            return;
        }

        paused = _paused;

        if (paused) {
            lastPauseTime = now;
        }

        emit PauseChanged(paused);
    }

    event PauseChanged(bool isPaused);

    modifier notPaused {

        require(!paused, "This action cannot be performed while the contract is paused");
        _;
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


    function totalIssuedSynths(bytes32 currencyKey, bool excludeEtherCollateral) external view returns (uint);


    function transferableSynthetixAndAnyRateIsInvalid(address account, uint balance)
        external
        view
        returns (uint transferable, bool anyRateIsInvalid);


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


    function liquidateDelinquentAccount(
        address account,
        uint susdAmount,
        address liquidator
    ) external returns (uint totalRedeemed, uint amountToLiquidate);

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



contract ReadProxy is Owned {

    address public target;

    constructor(address _owner) public Owned(_owner) {}

    function setTarget(address _target) external onlyOwner {

        target = _target;
        emit TargetUpdated(target);
    }

    function() external {
        assembly {
            calldatacopy(0, 0, calldatasize)

            let result := staticcall(gas, sload(target_slot), 0, calldatasize, 0, 0)
            returndatacopy(0, 0, returndatasize)

            if iszero(result) {
                revert(0, returndatasize)
            }
            return(0, returndatasize)
        }
    }

    event TargetUpdated(address newTarget);
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
            address destination = resolver.requireAndGetAddress(
                name,
                string(abi.encodePacked("Resolver missing target: ", name))
            );
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


    function addShortableSynths(bytes32[2][] calldata requiredSynthAndInverseNamesInResolver, bytes32[] calldata synthKeys)
        external;


    function removeShortableSynths(bytes32[] calldata synths) external;


    function updateBorrowRates(uint rate) external;


    function updateShortRates(bytes32 currency, uint rate) external;


    function incrementLongs(bytes32 synth, uint amount) external;


    function decrementLongs(bytes32 synth, uint amount) external;


    function incrementShorts(bytes32 synth, uint amount) external;


    function decrementShorts(bytes32 synth, uint amount) external;

}


library AddressSetLib {

    struct AddressSet {
        address[] elements;
        mapping(address => uint) indices;
    }

    function contains(AddressSet storage set, address candidate) internal view returns (bool) {

        if (set.elements.length == 0) {
            return false;
        }
        uint index = set.indices[candidate];
        return index != 0 || set.elements[0] == candidate;
    }

    function getPage(
        AddressSet storage set,
        uint index,
        uint pageSize
    ) internal view returns (address[] memory) {

        uint endIndex = index + pageSize; // The check below that endIndex <= index handles overflow.

        if (endIndex > set.elements.length) {
            endIndex = set.elements.length;
        }
        if (endIndex <= index) {
            return new address[](0);
        }

        uint n = endIndex - index; // We already checked for negative overflow.
        address[] memory page = new address[](n);
        for (uint i; i < n; i++) {
            page[i] = set.elements[i + index];
        }
        return page;
    }

    function add(AddressSet storage set, address element) internal {

        if (!contains(set, element)) {
            set.indices[element] = set.elements.length;
            set.elements.push(element);
        }
    }

    function remove(AddressSet storage set, address element) internal {

        require(contains(set, element), "Element not in set.");
        uint index = set.indices[element];
        uint lastIndex = set.elements.length - 1; // We required that element is in the list, so it is not empty.
        if (index != lastIndex) {
            address shiftedElement = set.elements[lastIndex];
            set.elements[index] = shiftedElement;
            set.indices[shiftedElement] = index;
        }
        set.elements.pop();
        delete set.indices[element];
    }
}


library Bytes32SetLib {

    struct Bytes32Set {
        bytes32[] elements;
        mapping(bytes32 => uint) indices;
    }

    function contains(Bytes32Set storage set, bytes32 candidate) internal view returns (bool) {

        if (set.elements.length == 0) {
            return false;
        }
        uint index = set.indices[candidate];
        return index != 0 || set.elements[0] == candidate;
    }

    function getPage(
        Bytes32Set storage set,
        uint index,
        uint pageSize
    ) internal view returns (bytes32[] memory) {

        uint endIndex = index + pageSize; // The check below that endIndex <= index handles overflow.

        if (endIndex > set.elements.length) {
            endIndex = set.elements.length;
        }
        if (endIndex <= index) {
            return new bytes32[](0);
        }

        uint n = endIndex - index; // We already checked for negative overflow.
        bytes32[] memory page = new bytes32[](n);
        for (uint i; i < n; i++) {
            page[i] = set.elements[i + index];
        }
        return page;
    }

    function add(Bytes32Set storage set, bytes32 element) internal {

        if (!contains(set, element)) {
            set.indices[element] = set.elements.length;
            set.elements.push(element);
        }
    }

    function remove(Bytes32Set storage set, bytes32 element) internal {

        require(contains(set, element), "Element not in set.");
        uint index = set.indices[element];
        uint lastIndex = set.elements.length - 1; // We required that element is in the list, so it is not empty.
        if (index != lastIndex) {
            bytes32 shiftedElement = set.elements[lastIndex];
            set.elements[index] = shiftedElement;
            set.indices[shiftedElement] = index;
        }
        set.elements.pop();
        delete set.indices[element];
    }
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


pragma experimental ABIEncoderV2;





contract CollateralManagerState is Owned, State {

    using SafeMath for uint;
    using SafeDecimalMath for uint;

    struct Balance {
        uint long;
        uint short;
    }

    uint public totalLoans;

    uint[] public borrowRates;
    uint public borrowRatesLastUpdated;

    mapping(bytes32 => uint[]) public shortRates;
    mapping(bytes32 => uint) public shortRatesLastUpdated;

    mapping(bytes32 => Balance) public totalIssuedSynths;

    constructor(address _owner, address _associatedContract) public Owned(_owner) State(_associatedContract) {
        borrowRates.push(0);
        borrowRatesLastUpdated = block.timestamp;
    }

    function incrementTotalLoans() external onlyAssociatedContract returns (uint) {

        totalLoans = totalLoans.add(1);
        return totalLoans;
    }

    function long(bytes32 synth) external view onlyAssociatedContract returns (uint) {

        return totalIssuedSynths[synth].long;
    }

    function short(bytes32 synth) external view onlyAssociatedContract returns (uint) {

        return totalIssuedSynths[synth].short;
    }

    function incrementLongs(bytes32 synth, uint256 amount) external onlyAssociatedContract {

        totalIssuedSynths[synth].long = totalIssuedSynths[synth].long.add(amount);
    }

    function decrementLongs(bytes32 synth, uint256 amount) external onlyAssociatedContract {

        totalIssuedSynths[synth].long = totalIssuedSynths[synth].long.sub(amount);
    }

    function incrementShorts(bytes32 synth, uint256 amount) external onlyAssociatedContract {

        totalIssuedSynths[synth].short = totalIssuedSynths[synth].short.add(amount);
    }

    function decrementShorts(bytes32 synth, uint256 amount) external onlyAssociatedContract {

        totalIssuedSynths[synth].short = totalIssuedSynths[synth].short.sub(amount);
    }


    function getRateAt(uint index) public view returns (uint) {

        return borrowRates[index];
    }

    function getRatesLength() public view returns (uint) {

        return borrowRates.length;
    }

    function updateBorrowRates(uint rate) external onlyAssociatedContract {

        borrowRates.push(rate);
        borrowRatesLastUpdated = block.timestamp;
    }

    function ratesLastUpdated() public view returns (uint) {

        return borrowRatesLastUpdated;
    }

    function getRatesAndTime(uint index)
        external
        view
        returns (
            uint entryRate,
            uint lastRate,
            uint lastUpdated,
            uint newIndex
        )
    {

        newIndex = getRatesLength();
        entryRate = getRateAt(index);
        lastRate = getRateAt(newIndex - 1);
        lastUpdated = ratesLastUpdated();
    }


    function addShortCurrency(bytes32 currency) external onlyAssociatedContract {

        if (shortRates[currency].length > 0) {} else {
            shortRates[currency].push(0);
            shortRatesLastUpdated[currency] = block.timestamp;
        }
    }

    function removeShortCurrency(bytes32 currency) external onlyAssociatedContract {
        delete shortRates[currency];
    }

    function getShortRateAt(bytes32 currency, uint index) internal view returns (uint) {
        return shortRates[currency][index];
    }

    function getShortRatesLength(bytes32 currency) public view returns (uint) {
        return shortRates[currency].length;
    }

    function updateShortRates(bytes32 currency, uint rate) external onlyAssociatedContract {
        shortRates[currency].push(rate);
        shortRatesLastUpdated[currency] = block.timestamp;
    }

    function shortRateLastUpdated(bytes32 currency) internal view returns (uint) {
        return shortRatesLastUpdated[currency];
    }

    function getShortRatesAndTime(bytes32 currency, uint index)
        external
        view
        returns (
            uint entryRate,
            uint lastRate,
            uint lastUpdated,
            uint newIndex
        )
    {
        newIndex = getShortRatesLength(currency);
        entryRate = getShortRateAt(currency, index);
        lastRate = getShortRateAt(currency, newIndex - 1);
        lastUpdated = shortRateLastUpdated(currency);
    }
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


    function requireIssuanceActive() external view;


    function requireExchangeActive() external view;


    function requireSynthActive(bytes32 currencyKey) external view;


    function requireSynthsActive(bytes32 sourceCurrencyKey, bytes32 destinationCurrencyKey) external view;


    function synthSuspension(bytes32 currencyKey) external view returns (bool suspended, uint248 reason);


    function suspendSynth(bytes32 currencyKey, uint256 reason) external;


    function updateAccessControl(
        bytes32 section,
        address account,
        bool canSuspend,
        bool canResume
    ) external;

}


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


interface IDebtCache {


    function cachedDebt() external view returns (uint);


    function cachedSynthDebt(bytes32 currencyKey) external view returns (uint);


    function cacheTimestamp() external view returns (uint);


    function cacheInvalid() external view returns (bool);


    function cacheStale() external view returns (bool);


    function currentSynthDebts(bytes32[] calldata currencyKeys)
        external
        view
        returns (uint[] memory debtValues, bool anyRateIsInvalid);


    function cachedSynthDebts(bytes32[] calldata currencyKeys) external view returns (uint[] memory debtValues);


    function currentDebt() external view returns (uint debt, bool anyRateIsInvalid);


    function cacheInfo()
        external
        view
        returns (
            uint debt,
            uint timestamp,
            bool isInvalid,
            bool isStale
        );



    function takeDebtSnapshot() external;


    function updateCachedSynthDebts(bytes32[] calldata currencyKeys) external;

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








contract CollateralManager is ICollateralManager, Owned, Pausable, MixinResolver {

    using SafeMath for uint;
    using SafeDecimalMath for uint;
    using AddressSetLib for AddressSetLib.AddressSet;
    using Bytes32SetLib for Bytes32SetLib.Bytes32Set;


    bytes32 private constant sUSD = "sUSD";

    uint private constant SECONDS_IN_A_YEAR = 31556926 * 1e18;

    bytes32 public constant CONTRACT_NAME = "CollateralManager";
    bytes32 internal constant COLLATERAL_SYNTHS = "collateralSynth";


    CollateralManagerState public state;

    AddressSetLib.AddressSet internal _collaterals;

    Bytes32SetLib.Bytes32Set internal _synths;

    mapping(bytes32 => bytes32) public synthsByKey;

    Bytes32SetLib.Bytes32Set internal _shortableSynths;

    mapping(bytes32 => bytes32) public synthToInverseSynth;

    uint public utilisationMultiplier = 1e18;

    uint public maxDebt;

    uint public baseBorrowRate;

    uint public baseShortRate;


    bytes32 private constant CONTRACT_SYSTEMSTATUS = "SystemStatus";
    bytes32 private constant CONTRACT_ISSUER = "Issuer";
    bytes32 private constant CONTRACT_EXRATES = "ExchangeRates";

    bytes32[24] private addressesToCache = [CONTRACT_SYSTEMSTATUS, CONTRACT_ISSUER, CONTRACT_EXRATES];

    constructor(
        CollateralManagerState _state,
        address _owner,
        address _resolver,
        uint _maxDebt,
        uint _baseBorrowRate,
        uint _baseShortRate
    ) public Owned(_owner) Pausable() MixinResolver(_resolver) {
        owner = msg.sender;
        state = _state;

        setMaxDebt(_maxDebt);
        setBaseBorrowRate(_baseBorrowRate);
        setBaseShortRate(_baseShortRate);

        owner = _owner;
    }


    function resolverAddressesRequired() public view returns (bytes32[] memory addresses) {

        bytes32[] memory staticAddresses = new bytes32[](3);
        staticAddresses[0] = CONTRACT_ISSUER;
        staticAddresses[1] = CONTRACT_EXRATES;
        staticAddresses[2] = CONTRACT_SYSTEMSTATUS;

        bytes32[] memory shortAddresses;
        uint length = _shortableSynths.elements.length;

        if (length > 0) {
            shortAddresses = new bytes32[](length * 2);

            for (uint i = 0; i < length; i++) {
                shortAddresses[i] = _shortableSynths.elements[i];
                shortAddresses[i + length] = synthToInverseSynth[_shortableSynths.elements[i]];
            }
        }

        bytes32[] memory synthAddresses = combineArrays(shortAddresses, _synths.elements);

        if (synthAddresses.length > 0) {
            addresses = combineArrays(synthAddresses, staticAddresses);
        } else {
            addresses = staticAddresses;
        }
    }

    function isSynthManaged(bytes32 currencyKey) external view returns (bool) {

        return synthsByKey[currencyKey] != bytes32(0);
    }


    function _systemStatus() internal view returns (ISystemStatus) {

        return ISystemStatus(requireAndGetAddress(CONTRACT_SYSTEMSTATUS));
    }

    function _issuer() internal view returns (IIssuer) {

        return IIssuer(requireAndGetAddress(CONTRACT_ISSUER));
    }

    function _exchangeRates() internal view returns (IExchangeRates) {

        return IExchangeRates(requireAndGetAddress(CONTRACT_EXRATES));
    }

    function _synth(bytes32 synthName) internal view returns (ISynth) {

        return ISynth(requireAndGetAddress(synthName));
    }


    function hasCollateral(address collateral) public view returns (bool) {

        return _collaterals.contains(collateral);
    }

    function hasAllCollaterals(address[] memory collaterals) public view returns (bool) {

        for (uint i = 0; i < collaterals.length; i++) {
            if (!hasCollateral(collaterals[i])) {
                return false;
            }
        }
        return true;
    }


    function long(bytes32 synth) external view returns (uint amount) {

        return state.long(synth);
    }

    function short(bytes32 synth) external view returns (uint amount) {

        return state.short(synth);
    }

    function totalLong() public view returns (uint susdValue, bool anyRateIsInvalid) {

        bytes32[] memory synths = _synths.elements;

        if (synths.length > 0) {
            for (uint i = 0; i < synths.length; i++) {
                bytes32 synth = _synth(synths[i]).currencyKey();
                if (synth == sUSD) {
                    susdValue = susdValue.add(state.long(synth));
                } else {
                    (uint rate, bool invalid) = _exchangeRates().rateAndInvalid(synth);
                    uint amount = state.long(synth).multiplyDecimal(rate);
                    susdValue = susdValue.add(amount);
                    if (invalid) {
                        anyRateIsInvalid = true;
                    }
                }
            }
        }
    }

    function totalShort() public view returns (uint susdValue, bool anyRateIsInvalid) {

        bytes32[] memory synths = _shortableSynths.elements;

        if (synths.length > 0) {
            for (uint i = 0; i < synths.length; i++) {
                bytes32 synth = _synth(synths[i]).currencyKey();
                (uint rate, bool invalid) = _exchangeRates().rateAndInvalid(synth);
                uint amount = state.short(synth).multiplyDecimal(rate);
                susdValue = susdValue.add(amount);
                if (invalid) {
                    anyRateIsInvalid = true;
                }
            }
        }
    }

    function getBorrowRate() external view returns (uint borrowRate, bool anyRateIsInvalid) {

        uint snxDebt = _issuer().totalIssuedSynths(sUSD, true);

        (uint nonSnxDebt, bool ratesInvalid) = totalLong();

        uint totalDebt = snxDebt.add(nonSnxDebt);

        uint utilisation = nonSnxDebt.divideDecimal(totalDebt).divideDecimal(SECONDS_IN_A_YEAR);

        uint scaledUtilisation = utilisation.multiplyDecimal(utilisationMultiplier);

        borrowRate = scaledUtilisation.add(baseBorrowRate);

        anyRateIsInvalid = ratesInvalid;
    }

    function getShortRate(bytes32 synth) external view returns (uint shortRate, bool rateIsInvalid) {

        bytes32 synthKey = _synth(synth).currencyKey();

        rateIsInvalid = _exchangeRates().rateIsInvalid(synthKey);

        uint longSupply = IERC20(address(_synth(synth))).totalSupply();
        uint inverseSupply = IERC20(address(_synth(synthToInverseSynth[synth]))).totalSupply();
        uint shortSupply = state.short(synthKey).add(inverseSupply);

        if (longSupply > shortSupply) {
            return (0, rateIsInvalid);
        }

        uint skew = shortSupply.sub(longSupply);

        uint proportionalSkew = skew.divideDecimal(longSupply.add(shortSupply)).divideDecimal(SECONDS_IN_A_YEAR);

        shortRate = proportionalSkew.add(baseShortRate);
    }

    function getRatesAndTime(uint index)
        external
        view
        returns (
            uint entryRate,
            uint lastRate,
            uint lastUpdated,
            uint newIndex
        )
    {

        (entryRate, lastRate, lastUpdated, newIndex) = state.getRatesAndTime(index);
    }

    function getShortRatesAndTime(bytes32 currency, uint index)
        external
        view
        returns (
            uint entryRate,
            uint lastRate,
            uint lastUpdated,
            uint newIndex
        )
    {

        (entryRate, lastRate, lastUpdated, newIndex) = state.getShortRatesAndTime(currency, index);
    }

    function exceedsDebtLimit(uint amount, bytes32 currency) external view returns (bool canIssue, bool anyRateIsInvalid) {

        uint usdAmount = _exchangeRates().effectiveValue(currency, amount, sUSD);

        (uint longValue, bool longInvalid) = totalLong();
        (uint shortValue, bool shortInvalid) = totalShort();

        anyRateIsInvalid = longInvalid || shortInvalid;

        return (longValue.add(shortValue).add(usdAmount) <= maxDebt, anyRateIsInvalid);
    }



    function setUtilisationMultiplier(uint _utilisationMultiplier) public onlyOwner {

        require(_utilisationMultiplier > 0, "Must be greater than 0");
        utilisationMultiplier = _utilisationMultiplier;
    }

    function setMaxDebt(uint _maxDebt) public onlyOwner {

        require(_maxDebt > 0, "Must be greater than 0");
        maxDebt = _maxDebt;
        emit MaxDebtUpdated(maxDebt);
    }

    function setBaseBorrowRate(uint _baseBorrowRate) public onlyOwner {

        baseBorrowRate = _baseBorrowRate;
        emit BaseBorrowRateUpdated(baseBorrowRate);
    }

    function setBaseShortRate(uint _baseShortRate) public onlyOwner {

        baseShortRate = _baseShortRate;
        emit BaseShortRateUpdated(baseShortRate);
    }


    function getNewLoanId() external onlyCollateral returns (uint id) {

        id = state.incrementTotalLoans();
    }


    function addCollaterals(address[] calldata collaterals) external onlyOwner {

        _systemStatus().requireSystemActive();

        for (uint i = 0; i < collaterals.length; i++) {
            if (!_collaterals.contains(collaterals[i])) {
                _collaterals.add(collaterals[i]);
                emit CollateralAdded(collaterals[i]);
            }
        }
    }

    function removeCollaterals(address[] calldata collaterals) external onlyOwner {

        _systemStatus().requireSystemActive();

        for (uint i = 0; i < collaterals.length; i++) {
            if (_collaterals.contains(collaterals[i])) {
                _collaterals.remove(collaterals[i]);
                emit CollateralRemoved(collaterals[i]);
            }
        }
    }

    function addSynths(bytes32[] calldata synthNamesInResolver, bytes32[] calldata synthKeys) external onlyOwner {

        _systemStatus().requireSystemActive();

        for (uint i = 0; i < synthNamesInResolver.length; i++) {
            if (!_synths.contains(synthNamesInResolver[i])) {
                bytes32 synthName = synthNamesInResolver[i];
                _synths.add(synthName);
                synthsByKey[synthKeys[i]] = synthName;
                emit SynthAdded(synthName);
            }
        }
    }

    function areSynthsAndCurrenciesSet(bytes32[] calldata requiredSynthNamesInResolver, bytes32[] calldata synthKeys)
        external
        view
        returns (bool)
    {

        if (_synths.elements.length != requiredSynthNamesInResolver.length) {
            return false;
        }

        for (uint i = 0; i < requiredSynthNamesInResolver.length; i++) {
            if (!_synths.contains(requiredSynthNamesInResolver[i])) {
                return false;
            }
            if (synthsByKey[synthKeys[i]] != requiredSynthNamesInResolver[i]) {
                return false;
            }
        }

        return true;
    }

    function removeSynths(bytes32[] calldata synths, bytes32[] calldata synthKeys) external onlyOwner {

        _systemStatus().requireSystemActive();

        for (uint i = 0; i < synths.length; i++) {
            if (_synths.contains(synths[i])) {
                _synths.remove(synths[i]);
                delete synthsByKey[synthKeys[i]];

                emit SynthRemoved(synths[i]);
            }
        }
    }

    function addShortableSynths(bytes32[2][] calldata requiredSynthAndInverseNamesInResolver, bytes32[] calldata synthKeys)
        external
        onlyOwner
    {

        _systemStatus().requireSystemActive();

        require(requiredSynthAndInverseNamesInResolver.length == synthKeys.length, "Input array length mismatch");

        for (uint i = 0; i < requiredSynthAndInverseNamesInResolver.length; i++) {
            bytes32 synth = requiredSynthAndInverseNamesInResolver[i][0];
            bytes32 iSynth = requiredSynthAndInverseNamesInResolver[i][1];

            if (!_shortableSynths.contains(synth)) {
                _shortableSynths.add(synth);

                synthToInverseSynth[synth] = iSynth;

                emit ShortableSynthAdded(synth);

                state.addShortCurrency(synthKeys[i]);
            }
        }

        rebuildCache();
    }

    function areShortableSynthsSet(bytes32[] calldata requiredSynthNamesInResolver, bytes32[] calldata synthKeys)
        external
        view
        returns (bool)
    {

        require(requiredSynthNamesInResolver.length == synthKeys.length, "Input array length mismatch");

        if (_shortableSynths.elements.length != requiredSynthNamesInResolver.length) {
            return false;
        }

        for (uint i = 0; i < requiredSynthNamesInResolver.length; i++) {
            bytes32 synthName = requiredSynthNamesInResolver[i];
            if (!_shortableSynths.contains(synthName) || synthToInverseSynth[synthName] == bytes32(0)) {
                return false;
            }
        }

        for (uint i = 0; i < synthKeys.length; i++) {
            if (state.getShortRatesLength(synthKeys[i]) == 0) {
                return false;
            }
        }

        return true;
    }

    function removeShortableSynths(bytes32[] calldata synths) external onlyOwner {

        _systemStatus().requireSystemActive();

        for (uint i = 0; i < synths.length; i++) {
            if (_shortableSynths.contains(synths[i])) {
                _shortableSynths.remove(synths[i]);

                bytes32 synthKey = _synth(synths[i]).currencyKey();

                state.removeShortCurrency(synthKey);

                delete synthToInverseSynth[synths[i]];

                emit ShortableSynthRemoved(synths[i]);
            }
        }
    }


    function updateBorrowRates(uint rate) external onlyCollateral {

        state.updateBorrowRates(rate);
    }

    function updateShortRates(bytes32 currency, uint rate) external onlyCollateral {

        state.updateShortRates(currency, rate);
    }

    function incrementLongs(bytes32 synth, uint amount) external onlyCollateral {

        state.incrementLongs(synth, amount);
    }

    function decrementLongs(bytes32 synth, uint amount) external onlyCollateral {

        state.decrementLongs(synth, amount);
    }

    function incrementShorts(bytes32 synth, uint amount) external onlyCollateral {

        state.incrementShorts(synth, amount);
    }

    function decrementShorts(bytes32 synth, uint amount) external onlyCollateral {

        state.decrementShorts(synth, amount);
    }


    modifier onlyCollateral {

        bool isMultiCollateral = hasCollateral(msg.sender);

        require(isMultiCollateral, "Only collateral contracts");
        _;
    }

    event MaxDebtUpdated(uint maxDebt);
    event LiquidationPenaltyUpdated(uint liquidationPenalty);
    event BaseBorrowRateUpdated(uint baseBorrowRate);
    event BaseShortRateUpdated(uint baseShortRate);

    event CollateralAdded(address collateral);
    event CollateralRemoved(address collateral);

    event SynthAdded(bytes32 synth);
    event SynthRemoved(bytes32 synth);

    event ShortableSynthAdded(bytes32 synth);
    event ShortableSynthRemoved(bytes32 synth);
}