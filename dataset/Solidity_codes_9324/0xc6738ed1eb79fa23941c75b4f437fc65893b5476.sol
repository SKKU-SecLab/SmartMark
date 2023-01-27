



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

        require(msg.sender == owner, "Only the contract owner may perform this action");
        _;
    }

    event OwnerNominated(address newOwner);
    event OwnerChanged(address oldOwner, address newOwner);
}




contract SelfDestructible is Owned {

    uint public constant SELFDESTRUCT_DELAY = 4 weeks;

    uint public initiationTime;
    bool public selfDestructInitiated;

    address public selfDestructBeneficiary;

    constructor() internal {
        require(owner != address(0), "Owner must be set");
        selfDestructBeneficiary = owner;
        emit SelfDestructBeneficiaryUpdated(owner);
    }

    function setSelfDestructBeneficiary(address payable _beneficiary) external onlyOwner {

        require(_beneficiary != address(0), "Beneficiary must not be zero");
        selfDestructBeneficiary = _beneficiary;
        emit SelfDestructBeneficiaryUpdated(_beneficiary);
    }

    function initiateSelfDestruct() external onlyOwner {

        initiationTime = now;
        selfDestructInitiated = true;
        emit SelfDestructInitiated(SELFDESTRUCT_DELAY);
    }

    function terminateSelfDestruct() external onlyOwner {

        initiationTime = 0;
        selfDestructInitiated = false;
        emit SelfDestructTerminated();
    }

    function selfDestruct() external onlyOwner {

        require(selfDestructInitiated, "Self Destruct not yet initiated");
        require(initiationTime + SELFDESTRUCT_DELAY < now, "Self destruct delay not met");
        emit SelfDestructed(selfDestructBeneficiary);
        selfdestruct(address(uint160(selfDestructBeneficiary)));
    }

    event SelfDestructTerminated();
    event SelfDestructed(address beneficiary);
    event SelfDestructInitiated(uint selfDestructDelay);
    event SelfDestructBeneficiaryUpdated(address newBeneficiary);
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
    Proxy public integrationProxy;

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

    function setIntegrationProxy(address payable _integrationProxy) external onlyOwner {

        integrationProxy = Proxy(_integrationProxy);
    }

    function setMessageSender(address sender) external onlyProxy {

        messageSender = sender;
    }

    modifier onlyProxy {

        require(Proxy(msg.sender) == proxy || Proxy(msg.sender) == integrationProxy, "Only the proxy can call");
        _;
    }

    modifier optionalProxy {

        if (Proxy(msg.sender) != proxy && Proxy(msg.sender) != integrationProxy && messageSender != msg.sender) {
            messageSender = msg.sender;
        }
        _;
    }

    modifier optionalProxy_onlyOwner {

        if (Proxy(msg.sender) != proxy && Proxy(msg.sender) != integrationProxy && messageSender != msg.sender) {
            messageSender = msg.sender;
        }
        require(messageSender == owner, "Owner only function");
        _;
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








contract ExternStateToken is Owned, SelfDestructible, Proxyable {

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
    ) public Owned(_owner) SelfDestructible() Proxyable(_proxy) {
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


interface ISynthetix {

    function availableCurrencyKeys() external view returns (bytes32[] memory);


    function availableSynthCount() external view returns (uint);


    function collateral(address account) external view returns (uint);


    function collateralisationRatio(address issuer) external view returns (uint);


    function debtBalanceOf(address issuer, bytes32 currencyKey) external view returns (uint);


    function debtBalanceOfAndTotalDebt(address issuer, bytes32 currencyKey)
        external
        view
        returns (uint debtBalance, uint totalSystemValue);


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


    function transferableSynthetix(address account) external view returns (uint);


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

}




contract AddressResolver is Owned, IAddressResolver {

    mapping(bytes32 => address) public repository;

    constructor(address _owner) public Owned(_owner) {}


    function importAddresses(bytes32[] calldata names, address[] calldata destinations) external onlyOwner {

        require(names.length == destinations.length, "Input lengths must match");

        for (uint i = 0; i < names.length; i++) {
            repository[names[i]] = destinations[i];
        }
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

        ISynthetix synthetix = ISynthetix(repository["Synthetix"]);
        require(address(synthetix) != address(0), "Cannot find Synthetix address");
        return address(synthetix.synths(key));
    }
}






contract MixinResolver is Owned {

    AddressResolver public resolver;

    mapping(bytes32 => address) private addressCache;

    bytes32[] public resolverAddressesRequired;

    uint public constant MAX_ADDRESSES_FROM_RESOLVER = 24;

    constructor(address _resolver, bytes32[MAX_ADDRESSES_FROM_RESOLVER] memory _addressesToCache) internal {
        require(owner != address(0), "Owner must be set");

        for (uint i = 0; i < _addressesToCache.length; i++) {
            if (_addressesToCache[i] != bytes32(0)) {
                resolverAddressesRequired.push(_addressesToCache[i]);
            } else {
                break;
            }
        }
        resolver = AddressResolver(_resolver);
    }

    function setResolverAndSyncCache(AddressResolver _resolver) external onlyOwner {

        resolver = _resolver;

        for (uint i = 0; i < resolverAddressesRequired.length; i++) {
            bytes32 name = resolverAddressesRequired[i];
            addressCache[name] = resolver.requireAndGetAddress(name, "Resolver missing target");
        }
    }


    function requireAndGetAddress(bytes32 name, string memory reason) internal view returns (address) {

        address _foundAddress = addressCache[name];
        require(_foundAddress != address(0), reason);
        return _foundAddress;
    }

    function isResolverCached(AddressResolver _resolver) external view returns (bool) {

        if (resolver != _resolver) {
            return false;
        }

        for (uint i = 0; i < resolverAddressesRequired.length; i++) {
            bytes32 name = resolverAddressesRequired[i];
            if (resolver.getAddress(name) != addressCache[name] || addressCache[name] == address(0)) {
                return false;
            }
        }

        return true;
    }

    function getResolverAddressesRequired()
        external
        view
        returns (bytes32[MAX_ADDRESSES_FROM_RESOLVER] memory addressesRequired)
    {

        for (uint i = 0; i < resolverAddressesRequired.length; i++) {
            addressesRequired[i] = resolverAddressesRequired[i];
        }
    }

    function appendToAddressCache(bytes32 name) internal {

        resolverAddressesRequired.push(name);
        require(resolverAddressesRequired.length < MAX_ADDRESSES_FROM_RESOLVER, "Max resolver cache size met");
        addressCache[name] = resolver.getAddress(name);
    }
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

    function requireSystemActive() external view;


    function requireIssuanceActive() external view;


    function requireExchangeActive() external view;


    function requireSynthActive(bytes32 currencyKey) external view;


    function requireSynthsActive(bytes32 sourceCurrencyKey, bytes32 destinationCurrencyKey) external view;

}


interface IExchanger {

    function calculateAmountAfterSettlement(
        address from,
        bytes32 currencyKey,
        uint amount,
        uint refunded
    ) external view returns (uint amountAfterSettlement);


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


    function feeRateForExchange(bytes32 sourceCurrencyKey, bytes32 destinationCurrencyKey)
        external
        view
        returns (uint exchangeFeeRate);


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


    function exchange(
        address from,
        bytes32 sourceCurrencyKey,
        uint sourceAmount,
        bytes32 destinationCurrencyKey,
        address destinationAddress
    ) external returns (uint amountReceived);


    function exchangeOnBehalf(
        address exchangeForAddress,
        address from,
        bytes32 sourceCurrencyKey,
        uint sourceAmount,
        bytes32 destinationCurrencyKey
    ) external returns (uint amountReceived);


    function settle(address from, bytes32 currencyKey)
        external
        returns (
            uint reclaimed,
            uint refunded,
            uint numEntries
        );

}


interface IEtherCollateral {

    function totalIssuedSynths() external view returns (uint256);


    function totalLoansCreated() external view returns (uint256);


    function totalOpenLoanCount() external view returns (uint256);


    function openLoan() external payable returns (uint256 loanID);


    function closeLoan(uint256 loanID) external;


    function liquidateUnclosedLoan(address _loanCreatorsAddress, uint256 _loanID) external;

}


interface IIssuer {

    function canBurnSynths(address account) external view returns (bool);


    function lastIssueEvent(address account) external view returns (uint);


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


    function liquidateDelinquentAccount(address account, uint susdAmount, address liquidator) external returns (uint totalRedeemed, uint amountToLiquidate);

}


interface ISynthetixState {

    function debtLedger(uint index) external view returns (uint);


    function issuanceRatio() external view returns (uint);


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


interface IExchangeRates {

    function aggregators(bytes32 currencyKey) external view returns (address);


    function anyRateIsStale(bytes32[] calldata currencyKeys) external view returns (bool);


    function currentRoundForRate(bytes32 currencyKey) external view returns (uint);


    function effectiveValue(
        bytes32 sourceCurrencyKey,
        uint sourceAmount,
        bytes32 destinationCurrencyKey
    ) external view returns (uint);


    function effectiveValueAtRound(
        bytes32 sourceCurrencyKey,
        uint sourceAmount,
        bytes32 destinationCurrencyKey,
        uint roundIdForSrc,
        uint roundIdForDest
    ) external view returns (uint);


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
            bool frozen
        );


    function lastRateUpdateTimes(bytes32 currencyKey) external view returns (uint256);


    function oracle() external view returns (address);


    function rateAndTimestampAtRound(bytes32 currencyKey, uint roundId) external view returns (uint rate, uint time);


    function rateForCurrency(bytes32 currencyKey) external view returns (uint);


    function rateIsFrozen(bytes32 currencyKey) external view returns (bool);


    function rateIsStale(bytes32 currencyKey) external view returns (bool);


    function ratesAndStaleForCurrencies(bytes32[] calldata currencyKeys) external view returns (uint[] memory, bool);


    function ratesForCurrencies(bytes32[] calldata currencyKeys) external view returns (uint[] memory);


    function rateStalePeriod() external view returns (uint);

}




library Math {

    using SafeMath for uint;
    using SafeDecimalMath for uint;

    function powDecimal(uint x, uint n) internal pure returns (uint) {


        uint result = SafeDecimalMath.unit();
        while (n > 0) {
            if (n % 2 != 0) {
                result = result.multiplyDecimal(x);
            }
            x = x.multiplyDecimal(x);
            n /= 2;
        }
        return result;
    }
}








contract SupplySchedule is Owned {

    using SafeMath for uint;
    using SafeDecimalMath for uint;
    using Math for uint;

    uint public lastMintEvent;

    uint public weekCounter;

    uint public minterReward = 200 * SafeDecimalMath.unit();

    uint public constant INITIAL_WEEKLY_SUPPLY = 1442307692307692307692307;

    address payable public synthetixProxy;

    uint public constant MAX_MINTER_REWARD = 200 * 1e18;

    uint public constant MINT_PERIOD_DURATION = 1 weeks;

    uint public constant INFLATION_START_DATE = 1551830400; // 2019-03-06T00:00:00+00:00
    uint public constant MINT_BUFFER = 1 days;
    uint8 public constant SUPPLY_DECAY_START = 40; // Week 40
    uint8 public constant SUPPLY_DECAY_END = 234; //  Supply Decay ends on Week 234 (inclusive of Week 234 for a total of 195 weeks of inflation decay)

    uint public constant DECAY_RATE = 12500000000000000; // 1.25% weekly

    uint public constant TERMINAL_SUPPLY_RATE_ANNUAL = 25000000000000000; // 2.5% pa

    constructor(
        address _owner,
        uint _lastMintEvent,
        uint _currentWeek
    ) public Owned(_owner) {
        lastMintEvent = _lastMintEvent;
        weekCounter = _currentWeek;
    }


    function mintableSupply() external view returns (uint) {

        uint totalAmount;

        if (!isMintable()) {
            return totalAmount;
        }

        uint remainingWeeksToMint = weeksSinceLastIssuance();

        uint currentWeek = weekCounter;

        while (remainingWeeksToMint > 0) {
            currentWeek++;

            if (currentWeek < SUPPLY_DECAY_START) {
                totalAmount = totalAmount.add(INITIAL_WEEKLY_SUPPLY);
                remainingWeeksToMint--;
            } else if (currentWeek <= SUPPLY_DECAY_END) {
                uint decayCount = currentWeek.sub(SUPPLY_DECAY_START - 1);

                totalAmount = totalAmount.add(tokenDecaySupplyForWeek(decayCount));
                remainingWeeksToMint--;
            } else {
                uint totalSupply = IERC20(synthetixProxy).totalSupply();
                uint currentTotalSupply = totalSupply.add(totalAmount);

                totalAmount = totalAmount.add(terminalInflationSupply(currentTotalSupply, remainingWeeksToMint));
                remainingWeeksToMint = 0;
            }
        }

        return totalAmount;
    }

    function tokenDecaySupplyForWeek(uint counter) public pure returns (uint) {

        uint effectiveDecay = (SafeDecimalMath.unit().sub(DECAY_RATE)).powDecimal(counter);
        uint supplyForWeek = INITIAL_WEEKLY_SUPPLY.multiplyDecimal(effectiveDecay);

        return supplyForWeek;
    }

    function terminalInflationSupply(uint totalSupply, uint numOfWeeks) public pure returns (uint) {

        uint effectiveCompoundRate = SafeDecimalMath.unit().add(TERMINAL_SUPPLY_RATE_ANNUAL.div(52)).powDecimal(numOfWeeks);

        return totalSupply.multiplyDecimal(effectiveCompoundRate.sub(SafeDecimalMath.unit()));
    }

    function weeksSinceLastIssuance() public view returns (uint) {

        uint timeDiff = lastMintEvent > 0 ? now.sub(lastMintEvent) : now.sub(INFLATION_START_DATE);
        return timeDiff.div(MINT_PERIOD_DURATION);
    }

    function isMintable() public view returns (bool) {

        if (now - lastMintEvent > MINT_PERIOD_DURATION) {
            return true;
        }
        return false;
    }


    function recordMintEvent(uint supplyMinted) external onlySynthetix returns (bool) {

        uint numberOfWeeksIssued = weeksSinceLastIssuance();

        weekCounter = weekCounter.add(numberOfWeeksIssued);

        lastMintEvent = INFLATION_START_DATE.add(weekCounter.mul(MINT_PERIOD_DURATION)).add(MINT_BUFFER);

        emit SupplyMinted(supplyMinted, numberOfWeeksIssued, lastMintEvent, now);
        return true;
    }

    function setMinterReward(uint amount) external onlyOwner {

        require(amount <= MAX_MINTER_REWARD, "Reward cannot exceed max minter reward");
        minterReward = amount;
        emit MinterRewardUpdated(minterReward);
    }


    function setSynthetixProxy(ISynthetix _synthetixProxy) external onlyOwner {

        require(address(_synthetixProxy) != address(0), "Address cannot be 0");
        synthetixProxy = address(uint160(address(_synthetixProxy)));
        emit SynthetixProxyUpdated(synthetixProxy);
    }


    modifier onlySynthetix() {

        require(
            msg.sender == address(Proxy(address(synthetixProxy)).target()),
            "Only the synthetix contract can perform this action"
        );
        _;
    }

    event SupplyMinted(uint supplyMinted, uint numberOfWeeksIssued, uint lastMintEvent, uint timestamp);

    event MinterRewardUpdated(uint newRewardAmount);

    event SynthetixProxyUpdated(address newAddress);
}


interface IRewardEscrow {

    function balanceOf(address account) external view returns (uint);


    function numVestingEntries(address account) external view returns (uint);


    function totalEscrowedAccountBalance(address account) external view returns (uint);


    function totalVestedAccountBalance(address account) external view returns (uint);


    function appendVestingEntry(address account, uint quantity) external;


    function vest() external;

}


interface IHasBalance {

    function balanceOf(address account) external view returns (uint);

}


interface IRewardsDistribution {

    function distributeRewards(uint amount) external returns (bool);

}






contract Synthetix is IERC20, ExternStateToken, MixinResolver, ISynthetix {


    ISynth[] public availableSynths;
    mapping(bytes32 => ISynth) public synths;
    mapping(address => bytes32) public synthsByAddress;

    string public constant TOKEN_NAME = "Synthetix Network Token";
    string public constant TOKEN_SYMBOL = "SNX";
    uint8 public constant DECIMALS = 18;
    bytes32 public constant sUSD = "sUSD";


    bytes32 private constant CONTRACT_SYSTEMSTATUS = "SystemStatus";
    bytes32 private constant CONTRACT_EXCHANGER = "Exchanger";
    bytes32 private constant CONTRACT_ETHERCOLLATERAL = "EtherCollateral";
    bytes32 private constant CONTRACT_ISSUER = "Issuer";
    bytes32 private constant CONTRACT_SYNTHETIXSTATE = "SynthetixState";
    bytes32 private constant CONTRACT_EXRATES = "ExchangeRates";
    bytes32 private constant CONTRACT_SUPPLYSCHEDULE = "SupplySchedule";
    bytes32 private constant CONTRACT_REWARDESCROW = "RewardEscrow";
    bytes32 private constant CONTRACT_SYNTHETIXESCROW = "SynthetixEscrow";
    bytes32 private constant CONTRACT_REWARDSDISTRIBUTION = "RewardsDistribution";

    bytes32[24] private addressesToCache = [
        CONTRACT_SYSTEMSTATUS,
        CONTRACT_EXCHANGER,
        CONTRACT_ETHERCOLLATERAL,
        CONTRACT_ISSUER,
        CONTRACT_SYNTHETIXSTATE,
        CONTRACT_EXRATES,
        CONTRACT_SUPPLYSCHEDULE,
        CONTRACT_REWARDESCROW,
        CONTRACT_SYNTHETIXESCROW,
        CONTRACT_REWARDSDISTRIBUTION
    ];


    constructor(
        address payable _proxy,
        TokenState _tokenState,
        address _owner,
        uint _totalSupply,
        address _resolver
    )
        public
        ExternStateToken(_proxy, _tokenState, TOKEN_NAME, TOKEN_SYMBOL, _totalSupply, DECIMALS, _owner)
        MixinResolver(_resolver, addressesToCache)
    {}


    function systemStatus() internal view returns (ISystemStatus) {

        return ISystemStatus(requireAndGetAddress(CONTRACT_SYSTEMSTATUS, "Missing SystemStatus address"));
    }

    function exchanger() internal view returns (IExchanger) {

        return IExchanger(requireAndGetAddress(CONTRACT_EXCHANGER, "Missing Exchanger address"));
    }

    function etherCollateral() internal view returns (IEtherCollateral) {

        return IEtherCollateral(requireAndGetAddress(CONTRACT_ETHERCOLLATERAL, "Missing EtherCollateral address"));
    }

    function issuer() internal view returns (IIssuer) {

        return IIssuer(requireAndGetAddress(CONTRACT_ISSUER, "Missing Issuer address"));
    }

    function synthetixState() internal view returns (ISynthetixState) {

        return ISynthetixState(requireAndGetAddress(CONTRACT_SYNTHETIXSTATE, "Missing SynthetixState address"));
    }

    function exchangeRates() internal view returns (IExchangeRates) {

        return IExchangeRates(requireAndGetAddress(CONTRACT_EXRATES, "Missing ExchangeRates address"));
    }

    function supplySchedule() internal view returns (SupplySchedule) {

        return SupplySchedule(requireAndGetAddress(CONTRACT_SUPPLYSCHEDULE, "Missing SupplySchedule address"));
    }

    function rewardEscrow() internal view returns (IRewardEscrow) {

        return IRewardEscrow(requireAndGetAddress(CONTRACT_REWARDESCROW, "Missing RewardEscrow address"));
    }

    function synthetixEscrow() internal view returns (IHasBalance) {

        return IHasBalance(requireAndGetAddress(CONTRACT_SYNTHETIXESCROW, "Missing SynthetixEscrow address"));
    }

    function rewardsDistribution() internal view returns (IRewardsDistribution) {

        return
            IRewardsDistribution(requireAndGetAddress(CONTRACT_REWARDSDISTRIBUTION, "Missing RewardsDistribution address"));
    }

    function _totalIssuedSynths(bytes32 currencyKey, bool excludeEtherCollateral) internal view returns (uint) {

        IExchangeRates exRates = exchangeRates();
        uint total = 0;
        uint currencyRate = exRates.rateForCurrency(currencyKey);

        (uint[] memory rates, bool anyRateStale) = exRates.ratesAndStaleForCurrencies(availableCurrencyKeys());
        require(!anyRateStale, "Rates are stale");

        for (uint i = 0; i < availableSynths.length; i++) {
            uint totalSynths = IERC20(address(availableSynths[i])).totalSupply();

            if (excludeEtherCollateral && availableSynths[i] == synths["sETH"]) {
                totalSynths = totalSynths.sub(etherCollateral().totalIssuedSynths());
            }

            uint synthValue = totalSynths.multiplyDecimalRound(rates[i]);
            total = total.add(synthValue);
        }

        return total.divideDecimalRound(currencyRate);
    }

    function totalIssuedSynths(bytes32 currencyKey) public view returns (uint) {

        return _totalIssuedSynths(currencyKey, false);
    }

    function totalIssuedSynthsExcludeEtherCollateral(bytes32 currencyKey) public view returns (uint) {

        return _totalIssuedSynths(currencyKey, true);
    }

    function availableCurrencyKeys() public view returns (bytes32[] memory) {

        bytes32[] memory currencyKeys = new bytes32[](availableSynths.length);

        for (uint i = 0; i < availableSynths.length; i++) {
            currencyKeys[i] = synthsByAddress[address(availableSynths[i])];
        }

        return currencyKeys;
    }

    function availableSynthCount() external view returns (uint) {

        return availableSynths.length;
    }

    function isWaitingPeriod(bytes32 currencyKey) external view returns (bool) {

        return exchanger().maxSecsLeftInWaitingPeriod(messageSender, currencyKey) > 0;
    }


    function addSynth(ISynth synth) external optionalProxy_onlyOwner {

        bytes32 currencyKey = synth.currencyKey();

        require(synths[currencyKey] == ISynth(0), "Synth already exists");
        require(synthsByAddress[address(synth)] == bytes32(0), "Synth address already exists");

        availableSynths.push(synth);
        synths[currencyKey] = synth;
        synthsByAddress[address(synth)] = currencyKey;
    }

    function removeSynth(bytes32 currencyKey) external optionalProxy_onlyOwner {

        require(address(synths[currencyKey]) != address(0), "Synth does not exist");
        require(IERC20(address(synths[currencyKey])).totalSupply() == 0, "Synth supply exists");
        require(currencyKey != sUSD, "Cannot remove synth");

        address synthToRemove = address(synths[currencyKey]);

        for (uint i = 0; i < availableSynths.length; i++) {
            if (address(availableSynths[i]) == synthToRemove) {
                delete availableSynths[i];

                availableSynths[i] = availableSynths[availableSynths.length - 1];

                availableSynths.length--;

                break;
            }
        }

        delete synthsByAddress[address(synths[currencyKey])];
        delete synths[currencyKey];

    }

    function transfer(address to, uint value) public optionalProxy returns (bool) {

        systemStatus().requireSystemActive();

        require(value <= transferableSynthetix(messageSender), "Cannot transfer staked or escrowed SNX");

        _transferByProxy(messageSender, to, value);

        return true;
    }

    function transferFrom(
        address from,
        address to,
        uint value
    ) public optionalProxy returns (bool) {

        systemStatus().requireSystemActive();

        require(value <= transferableSynthetix(from), "Cannot transfer staked or escrowed SNX");

        return _transferFromByProxy(messageSender, from, to, value);
    }

    function issueSynths(uint amount) external optionalProxy {

        systemStatus().requireIssuanceActive();

        return issuer().issueSynths(messageSender, amount);
    }

    function issueSynthsOnBehalf(address issueForAddress, uint amount) external optionalProxy {

        systemStatus().requireIssuanceActive();

        return issuer().issueSynthsOnBehalf(issueForAddress, messageSender, amount);
    }

    function issueMaxSynths() external optionalProxy {

        systemStatus().requireIssuanceActive();

        return issuer().issueMaxSynths(messageSender);
    }

    function issueMaxSynthsOnBehalf(address issueForAddress) external optionalProxy {

        systemStatus().requireIssuanceActive();

        return issuer().issueMaxSynthsOnBehalf(issueForAddress, messageSender);
    }

    function burnSynths(uint amount) external optionalProxy {

        systemStatus().requireIssuanceActive();

        return issuer().burnSynths(messageSender, amount);
    }

    function burnSynthsOnBehalf(address burnForAddress, uint amount) external optionalProxy {

        systemStatus().requireIssuanceActive();

        return issuer().burnSynthsOnBehalf(burnForAddress, messageSender, amount);
    }

    function burnSynthsToTarget() external optionalProxy {

        systemStatus().requireIssuanceActive();

        return issuer().burnSynthsToTarget(messageSender);
    }

    function burnSynthsToTargetOnBehalf(address burnForAddress) external optionalProxy {

        systemStatus().requireIssuanceActive();

        return issuer().burnSynthsToTargetOnBehalf(burnForAddress, messageSender);
    }

    function exchange(
        bytes32 sourceCurrencyKey,
        uint sourceAmount,
        bytes32 destinationCurrencyKey
    ) external optionalProxy returns (uint amountReceived) {

        systemStatus().requireExchangeActive();

        systemStatus().requireSynthsActive(sourceCurrencyKey, destinationCurrencyKey);

        return exchanger().exchange(messageSender, sourceCurrencyKey, sourceAmount, destinationCurrencyKey, messageSender);
    }

    function exchangeOnBehalf(
        address exchangeForAddress,
        bytes32 sourceCurrencyKey,
        uint sourceAmount,
        bytes32 destinationCurrencyKey
    ) external optionalProxy returns (uint amountReceived) {

        systemStatus().requireExchangeActive();

        systemStatus().requireSynthsActive(sourceCurrencyKey, destinationCurrencyKey);

        return
            exchanger().exchangeOnBehalf(
                exchangeForAddress,
                messageSender,
                sourceCurrencyKey,
                sourceAmount,
                destinationCurrencyKey
            );
    }

    function settle(bytes32 currencyKey)
        external
        optionalProxy
        returns (
            uint reclaimed,
            uint refunded,
            uint numEntriesSettled
        )
    {

        return exchanger().settle(messageSender, currencyKey);
    }


    function maxIssuableSynths(address _issuer)
        public
        view
        returns (
            uint
        )
    {

        uint destinationValue = exchangeRates().effectiveValue("SNX", collateral(_issuer), sUSD);

        return destinationValue.multiplyDecimal(synthetixState().issuanceRatio());
    }

    function collateralisationRatio(address _issuer) public view returns (uint) {

        uint totalOwnedSynthetix = collateral(_issuer);
        if (totalOwnedSynthetix == 0) return 0;

        uint debtBalance = debtBalanceOf(_issuer, "SNX");
        return debtBalance.divideDecimalRound(totalOwnedSynthetix);
    }

    function debtBalanceOf(address _issuer, bytes32 currencyKey)
        public
        view
        returns (
            uint
        )
    {

        ISynthetixState state = synthetixState();

        (uint initialDebtOwnership, ) = state.issuanceData(_issuer);

        if (initialDebtOwnership == 0) return 0;

        (uint debtBalance, ) = debtBalanceOfAndTotalDebt(_issuer, currencyKey);
        return debtBalance;
    }

    function debtBalanceOfAndTotalDebt(address _issuer, bytes32 currencyKey)
        public
        view
        returns (uint debtBalance, uint totalSystemValue)
    {

        ISynthetixState state = synthetixState();

        uint initialDebtOwnership;
        uint debtEntryIndex;
        (initialDebtOwnership, debtEntryIndex) = state.issuanceData(_issuer);

        totalSystemValue = totalIssuedSynthsExcludeEtherCollateral(currencyKey);

        if (initialDebtOwnership == 0) return (0, totalSystemValue);

        uint currentDebtOwnership = state
            .lastDebtLedgerEntry()
            .divideDecimalRoundPrecise(state.debtLedger(debtEntryIndex))
            .multiplyDecimalRoundPrecise(initialDebtOwnership);

        uint highPrecisionBalance = totalSystemValue.decimalToPreciseDecimal().multiplyDecimalRoundPrecise(
            currentDebtOwnership
        );

        debtBalance = highPrecisionBalance.preciseDecimalToDecimal();
    }

    function remainingIssuableSynths(address _issuer)
        public
        view
        returns (
            uint maxIssuable,
            uint alreadyIssued,
            uint totalSystemDebt
        )
    {

        (alreadyIssued, totalSystemDebt) = debtBalanceOfAndTotalDebt(_issuer, sUSD);
        maxIssuable = maxIssuableSynths(_issuer);

        if (alreadyIssued >= maxIssuable) {
            maxIssuable = 0;
        } else {
            maxIssuable = maxIssuable.sub(alreadyIssued);
        }
    }

    function collateral(address account) public view returns (uint) {

        uint balance = tokenState.balanceOf(account);

        if (address(synthetixEscrow()) != address(0)) {
            balance = balance.add(synthetixEscrow().balanceOf(account));
        }

        if (address(rewardEscrow()) != address(0)) {
            balance = balance.add(rewardEscrow().balanceOf(account));
        }

        return balance;
    }

    function transferableSynthetix(address account)
        public
        view
        rateNotStale("SNX") // SNX is not a synth so is not checked in totalIssuedSynths
        returns (uint)
    {

        uint balance = tokenState.balanceOf(account);

        uint lockedSynthetixValue = debtBalanceOf(account, "SNX").divideDecimalRound(synthetixState().issuanceRatio());

        if (lockedSynthetixValue >= balance) {
            return 0;
        } else {
            return balance.sub(lockedSynthetixValue);
        }
    }

    function mint() external returns (bool) {

        require(address(rewardsDistribution()) != address(0), "RewardsDistribution not set");

        systemStatus().requireIssuanceActive();

        SupplySchedule _supplySchedule = supplySchedule();
        IRewardsDistribution _rewardsDistribution = rewardsDistribution();

        uint supplyToMint = _supplySchedule.mintableSupply();
        require(supplyToMint > 0, "No supply is mintable");

        _supplySchedule.recordMintEvent(supplyToMint);

        uint minterReward = _supplySchedule.minterReward();
        uint amountToDistribute = supplyToMint.sub(minterReward);

        tokenState.setBalanceOf(
            address(_rewardsDistribution),
            tokenState.balanceOf(address(_rewardsDistribution)).add(amountToDistribute)
        );
        emitTransfer(address(this), address(_rewardsDistribution), amountToDistribute);

        _rewardsDistribution.distributeRewards(amountToDistribute);

        tokenState.setBalanceOf(msg.sender, tokenState.balanceOf(msg.sender).add(minterReward));
        emitTransfer(address(this), msg.sender, minterReward);

        totalSupply = totalSupply.add(supplyToMint);

        return true;
    }

    function liquidateDelinquentAccount(address account, uint susdAmount) external rateNotStale("SNX") optionalProxy returns (bool) {

        systemStatus().requireSystemActive();

        (uint totalRedeemed, uint amountLiquidated) = issuer().liquidateDelinquentAccount(account, susdAmount, messageSender);

        emitAccountLiquidated(account, totalRedeemed, amountLiquidated, messageSender);

        return _transferByProxy(account, messageSender, totalRedeemed);
    }


    modifier rateNotStale(bytes32 currencyKey) {

        require(!exchangeRates().rateIsStale(currencyKey), "Rate stale or not a synth");
        _;
    }

    modifier onlyExchanger() {

        require(msg.sender == address(exchanger()), "Only the exchanger contract can invoke this function");
        _;
    }


    event SynthExchange(
        address indexed account,
        bytes32 fromCurrencyKey,
        uint256 fromAmount,
        bytes32 toCurrencyKey,
        uint256 toAmount,
        address toAddress
    );
    bytes32 internal constant SYNTHEXCHANGE_SIG = keccak256(
        "SynthExchange(address,bytes32,uint256,bytes32,uint256,address)"
    );

    function emitSynthExchange(
        address account,
        bytes32 fromCurrencyKey,
        uint256 fromAmount,
        bytes32 toCurrencyKey,
        uint256 toAmount,
        address toAddress
    ) external onlyExchanger {

        proxy._emit(
            abi.encode(fromCurrencyKey, fromAmount, toCurrencyKey, toAmount, toAddress),
            2,
            SYNTHEXCHANGE_SIG,
            addressToBytes32(account),
            0,
            0
        );
    }

    event ExchangeReclaim(address indexed account, bytes32 currencyKey, uint amount);
    bytes32 internal constant EXCHANGERECLAIM_SIG = keccak256("ExchangeReclaim(address,bytes32,uint256)");

    function emitExchangeReclaim(
        address account,
        bytes32 currencyKey,
        uint256 amount
    ) external onlyExchanger {

        proxy._emit(abi.encode(currencyKey, amount), 2, EXCHANGERECLAIM_SIG, addressToBytes32(account), 0, 0);
    }

    event ExchangeRebate(address indexed account, bytes32 currencyKey, uint amount);
    bytes32 internal constant EXCHANGEREBATE_SIG = keccak256("ExchangeRebate(address,bytes32,uint256)");

    function emitExchangeRebate(
        address account,
        bytes32 currencyKey,
        uint256 amount
    ) external onlyExchanger {

        proxy._emit(abi.encode(currencyKey, amount), 2, EXCHANGEREBATE_SIG, addressToBytes32(account), 0, 0);
    }

    event AccountLiquidated(address indexed account, uint snxRedeemed, uint amountLiquidated, address liquidator);
    bytes32 internal constant ACCOUNTLIQUIDATED_SIG = keccak256("AccountLiquidated(address,uint256,uint256,address)");

    function emitAccountLiquidated(
        address account,
        uint256 snxRedeemed,
        uint256 amountLiquidated,
        address liquidator
    ) internal {

        proxy._emit(
            abi.encode(snxRedeemed, amountLiquidated, liquidator),
            2,
            ACCOUNTLIQUIDATED_SIG,
            addressToBytes32(account),
            0,
            0
        );
    }
}