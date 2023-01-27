



pragma solidity 0.4.25;


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


contract Proxy is Owned {

    Proxyable public target;
    bool public useDELEGATECALL;

    constructor(address _owner) public Owned(_owner) {}

    function setTarget(Proxyable _target) external onlyOwner {

        target = _target;
        emit TargetUpdated(_target);
    }

    function setUseDELEGATECALL(bool value) external onlyOwner {

        useDELEGATECALL = value;
    }

    function _emit(bytes callData, uint numTopics, bytes32 topic1, bytes32 topic2, bytes32 topic3, bytes32 topic4)
        external
        onlyTarget
    {

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
        if (useDELEGATECALL) {
            assembly {
                let free_ptr := mload(0x40)
                calldatacopy(free_ptr, 0, calldatasize)

                let result := delegatecall(gas, sload(target_slot), free_ptr, calldatasize, 0, 0)
                returndatacopy(free_ptr, 0, returndatasize)

                if iszero(result) {
                    revert(free_ptr, returndatasize)
                }
                return(free_ptr, returndatasize)
            }
        } else {
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

    constructor(address _proxy, address _owner) public Owned(_owner) {
        proxy = Proxy(_proxy);
        emit ProxyUpdated(_proxy);
    }

    function setProxy(address _proxy) external onlyOwner {

        proxy = Proxy(_proxy);
        emit ProxyUpdated(_proxy);
    }

    function setIntegrationProxy(address _integrationProxy) external onlyOwner {

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


contract SelfDestructible is Owned {

    uint public initiationTime;
    bool public selfDestructInitiated;
    address public selfDestructBeneficiary;
    uint public constant SELFDESTRUCT_DELAY = 4 weeks;

    constructor(address _owner) public Owned(_owner) {
        require(_owner != address(0), "Owner must not be zero");
        selfDestructBeneficiary = _owner;
        emit SelfDestructBeneficiaryUpdated(_owner);
    }

    function setSelfDestructBeneficiary(address _beneficiary) external onlyOwner {

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
        address beneficiary = selfDestructBeneficiary;
        emit SelfDestructed(beneficiary);
        selfdestruct(beneficiary);
    }

    event SelfDestructTerminated();
    event SelfDestructed(address beneficiary);
    event SelfDestructInitiated(uint selfDestructDelay);
    event SelfDestructBeneficiaryUpdated(address newBeneficiary);
}


library SafeMath {


  function mul(uint256 a, uint256 b) internal pure returns (uint256) {

    if (a == 0) {
      return 0;
    }

    uint256 c = a * b;
    require(c / a == b);

    return c;
  }

  function div(uint256 a, uint256 b) internal pure returns (uint256) {

    require(b > 0); // Solidity only automatically asserts when dividing by 0
    uint256 c = a / b;

    return c;
  }

  function sub(uint256 a, uint256 b) internal pure returns (uint256) {

    require(b <= a);
    uint256 c = a - b;

    return c;
  }

  function add(uint256 a, uint256 b) internal pure returns (uint256) {

    uint256 c = a + b;
    require(c >= a);

    return c;
  }

  function mod(uint256 a, uint256 b) internal pure returns (uint256) {

    require(b != 0);
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

    function _multiplyDecimalRound(uint x, uint y, uint precisionUnit) private pure returns (uint) {

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

    function _divideDecimalRound(uint x, uint y, uint precisionUnit) private pure returns (uint) {

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


contract AddressResolver is Owned {

    mapping(bytes32 => address) public repository;

    constructor(address _owner) public Owned(_owner) {}


    function importAddresses(bytes32[] names, address[] destinations) public onlyOwner {

        require(names.length == destinations.length, "Input lengths must match");

        for (uint i = 0; i < names.length; i++) {
            repository[names[i]] = destinations[i];
        }
    }


    function getAddress(bytes32 name) public view returns (address) {

        return repository[name];
    }

    function requireAndGetAddress(bytes32 name, string reason) public view returns (address) {

        address _foundAddress = repository[name];
        require(_foundAddress != address(0), reason);
        return _foundAddress;
    }
}


contract MixinResolver is Owned {

    AddressResolver public resolver;

    mapping(bytes32 => address) private addressCache;

    bytes32[] public resolverAddressesRequired;

    uint public constant MAX_ADDRESSES_FROM_RESOLVER = 24;

    constructor(address _owner, address _resolver, bytes32[MAX_ADDRESSES_FROM_RESOLVER] _addressesToCache)
        public
        Owned(_owner)
    {
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


    function requireAndGetAddress(bytes32 name, string reason) internal view returns (address) {

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

    function getResolverAddressesRequired() external view returns (bytes32[MAX_ADDRESSES_FROM_RESOLVER] addressesRequired) {

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


contract State is Owned {

    address public associatedContract;

    constructor(address _owner, address _associatedContract) public Owned(_owner) {
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


contract TokenState is State {

    mapping(address => uint) public balanceOf;
    mapping(address => mapping(address => uint)) public allowance;

    constructor(address _owner, address _associatedContract) public State(_owner, _associatedContract) {}


    function setAllowance(address tokenOwner, address spender, uint value) external onlyAssociatedContract {

        allowance[tokenOwner][spender] = value;
    }

    function setBalanceOf(address account, uint value) external onlyAssociatedContract {

        balanceOf[account] = value;
    }
}


contract ExternStateToken is SelfDestructible, Proxyable {

    using SafeMath for uint;
    using SafeDecimalMath for uint;


    TokenState public tokenState;

    string public name;
    string public symbol;
    uint public totalSupply;
    uint8 public decimals;

    constructor(
        address _proxy,
        TokenState _tokenState,
        string _name,
        string _symbol,
        uint _totalSupply,
        uint8 _decimals,
        address _owner
    ) public SelfDestructible(_owner) Proxyable(_proxy, _owner) {
        tokenState = _tokenState;

        name = _name;
        symbol = _symbol;
        totalSupply = _totalSupply;
        decimals = _decimals;
    }


    function allowance(address owner, address spender) public view returns (uint) {

        return tokenState.allowance(owner, spender);
    }

    function balanceOf(address account) public view returns (uint) {

        return tokenState.balanceOf(account);
    }


    function setTokenState(TokenState _tokenState) external optionalProxy_onlyOwner {

        tokenState = _tokenState;
        emitTokenStateUpdated(_tokenState);
    }

    function _internalTransfer(address from, address to, uint value) internal returns (bool) {

        require(to != address(0) && to != address(this) && to != address(proxy), "Cannot transfer to this address");

        tokenState.setBalanceOf(from, tokenState.balanceOf(from).sub(value));
        tokenState.setBalanceOf(to, tokenState.balanceOf(to).add(value));

        emitTransfer(from, to, value);

        return true;
    }

    function _transfer_byProxy(address from, address to, uint value) internal returns (bool) {

        return _internalTransfer(from, to, value);
    }

    function _transferFrom_byProxy(address sender, address from, address to, uint value) internal returns (bool) {

        tokenState.setAllowance(from, sender, tokenState.allowance(from, sender).sub(value));
        return _internalTransfer(from, to, value);
    }

    function approve(address spender, uint value) public optionalProxy returns (bool) {

        address sender = messageSender;

        tokenState.setAllowance(sender, spender, value);
        emitApproval(sender, spender, value);
        return true;
    }


    event Transfer(address indexed from, address indexed to, uint value);
    bytes32 constant TRANSFER_SIG = keccak256("Transfer(address,address,uint256)");

    function emitTransfer(address from, address to, uint value) internal {

        proxy._emit(abi.encode(value), 3, TRANSFER_SIG, bytes32(from), bytes32(to), 0);
    }

    event Approval(address indexed owner, address indexed spender, uint value);
    bytes32 constant APPROVAL_SIG = keccak256("Approval(address,address,uint256)");

    function emitApproval(address owner, address spender, uint value) internal {

        proxy._emit(abi.encode(value), 3, APPROVAL_SIG, bytes32(owner), bytes32(spender), 0);
    }

    event TokenStateUpdated(address newTokenState);
    bytes32 constant TOKENSTATEUPDATED_SIG = keccak256("TokenStateUpdated(address)");

    function emitTokenStateUpdated(address newTokenState) internal {

        proxy._emit(abi.encode(newTokenState), 1, TOKENSTATEUPDATED_SIG, 0, 0, 0);
    }
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


contract ISynthetixState {

    struct IssuanceData {
        uint initialDebtOwnership;
        uint debtEntryIndex;
    }

    uint[] public debtLedger;
    uint public issuanceRatio;
    mapping(address => IssuanceData) public issuanceData;

    function debtLedgerLength() external view returns (uint);


    function hasIssued(address account) external view returns (bool);


    function incrementTotalIssuerCount() external;


    function decrementTotalIssuerCount() external;


    function setCurrentIssuanceData(address account, uint initialDebtOwnership) external;


    function lastDebtLedgerEntry() external view returns (uint);


    function appendDebtLedgerValue(uint value) external;


    function clearIssuanceData(address account) external;

}


interface ISynth {

    function burn(address account, uint amount) external;


    function issue(address account, uint amount) external;


    function transfer(address to, uint value) external returns (bool);


    function transferFrom(address from, address to, uint value) external returns (bool);


    function transferFromAndSettle(address from, address to, uint value) external returns (bool);


    function balanceOf(address owner) external view returns (uint);

}


interface ISynthetixEscrow {

    function balanceOf(address account) public view returns (uint);


    function appendVestingEntry(address account, uint quantity) public;

}


contract IFeePool {

    address public FEE_ADDRESS;
    uint public exchangeFeeRate;

    function amountReceivedFromExchange(uint value) external view returns (uint);


    function amountReceivedFromTransfer(uint value) external view returns (uint);


    function recordFeePaid(uint sUSDAmount) external;


    function appendAccountIssuanceRecord(address account, uint lockedAmount, uint debtEntryIndex) external;


    function setRewardsToDistribute(uint amount) external;

}


interface IExchangeRates {

    function effectiveValue(bytes32 sourceCurrencyKey, uint sourceAmount, bytes32 destinationCurrencyKey)
        external
        view
        returns (uint);


    function rateForCurrency(bytes32 currencyKey) external view returns (uint);


    function ratesForCurrencies(bytes32[] currencyKeys) external view returns (uint[] memory);


    function rateIsStale(bytes32 currencyKey) external view returns (bool);


    function rateIsFrozen(bytes32 currencyKey) external view returns (bool);


    function anyRateIsStale(bytes32[] currencyKeys) external view returns (bool);


    function getCurrentRoundId(bytes32 currencyKey) external view returns (uint);


    function effectiveValueAtRound(
        bytes32 sourceCurrencyKey,
        uint sourceAmount,
        bytes32 destinationCurrencyKey,
        uint roundIdForSrc,
        uint roundIdForDest
    ) external view returns (uint);


    function getLastRoundIdBeforeElapsedSecs(
        bytes32 currencyKey,
        uint startingRoundId,
        uint startingTimestamp,
        uint timediff
    ) external view returns (uint);


    function ratesAndStaleForCurrencies(bytes32[] currencyKeys) external view returns (uint[], bool);


    function rateAndTimestampAtRound(bytes32 currencyKey, uint roundId) external view returns (uint rate, uint time);

}


interface ISystemStatus {

    function requireSystemActive() external view;


    function requireIssuanceActive() external view;


    function requireExchangeActive() external view;


    function requireSynthActive(bytes32 currencyKey) external view;


    function requireSynthsActive(bytes32 sourceCurrencyKey, bytes32 destinationCurrencyKey) external view;

}


interface IExchanger {

    function maxSecsLeftInWaitingPeriod(address account, bytes32 currencyKey) external view returns (uint);


    function feeRateForExchange(bytes32 sourceCurrencyKey, bytes32 destinationCurrencyKey) external view returns (uint);


    function settlementOwing(address account, bytes32 currencyKey)
        external
        view
        returns (uint reclaimAmount, uint rebateAmount, uint numEntries);


    function settle(address from, bytes32 currencyKey) external returns (uint reclaimed, uint refunded, uint numEntries);


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


    function calculateAmountAfterSettlement(address from, bytes32 currencyKey, uint amount, uint refunded)
        external
        view
        returns (uint amountAfterSettlement);

}


interface IIssuer {

    function issueSynths(address from, uint amount) external;


    function issueSynthsOnBehalf(address issueFor, address from, uint amount) external;


    function issueMaxSynths(address from) external;


    function issueMaxSynthsOnBehalf(address issueFor, address from) external;


    function burnSynths(address from, uint amount) external;


    function burnSynthsOnBehalf(address burnForAddress, address from, uint amount) external;


    function burnSynthsToTarget(address from) external;


    function burnSynthsToTargetOnBehalf(address burnForAddress, address from) external;


    function canBurnSynths(address account) external view returns (bool);


    function lastIssueEvent(address account) external view returns (uint);

}


contract Synth is ExternStateToken, MixinResolver {


    bytes32 public currencyKey;

    uint8 public constant DECIMALS = 18;

    address public constant FEE_ADDRESS = 0xfeEFEEfeefEeFeefEEFEEfEeFeefEEFeeFEEFEeF;


    bytes32 private constant CONTRACT_SYSTEMSTATUS = "SystemStatus";
    bytes32 private constant CONTRACT_SYNTHETIX = "Synthetix";
    bytes32 private constant CONTRACT_EXCHANGER = "Exchanger";
    bytes32 private constant CONTRACT_ISSUER = "Issuer";
    bytes32 private constant CONTRACT_FEEPOOL = "FeePool";

    bytes32[24] internal addressesToCache = [
        CONTRACT_SYSTEMSTATUS,
        CONTRACT_SYNTHETIX,
        CONTRACT_EXCHANGER,
        CONTRACT_ISSUER,
        CONTRACT_FEEPOOL
    ];


    constructor(
        address _proxy,
        TokenState _tokenState,
        string _tokenName,
        string _tokenSymbol,
        address _owner,
        bytes32 _currencyKey,
        uint _totalSupply,
        address _resolver
    )
        public
        ExternStateToken(_proxy, _tokenState, _tokenName, _tokenSymbol, _totalSupply, DECIMALS, _owner)
        MixinResolver(_owner, _resolver, addressesToCache)
    {
        require(_proxy != address(0), "_proxy cannot be 0");
        require(_owner != 0, "_owner cannot be 0");

        currencyKey = _currencyKey;
    }


    function transfer(address to, uint value) public optionalProxy returns (bool) {

        _ensureCanTransfer(messageSender, value);

        if (to == FEE_ADDRESS) {
            return _transferToFeeAddress(to, value);
        }

        if (to == address(0)) {
            return _internalBurn(messageSender, value);
        }

        return super._internalTransfer(messageSender, to, value);
    }

    function transferAndSettle(address to, uint value) public optionalProxy returns (bool) {

        systemStatus().requireSynthActive(currencyKey);

        (, , uint numEntriesSettled) = exchanger().settle(messageSender, currencyKey);

        uint balanceAfter = value;

        if (numEntriesSettled > 0) {
            balanceAfter = tokenState.balanceOf(messageSender);
        }

        value = value > balanceAfter ? balanceAfter : value;

        return super._internalTransfer(messageSender, to, value);
    }

    function transferFrom(address from, address to, uint value) public optionalProxy returns (bool) {

        _ensureCanTransfer(from, value);

        return _internalTransferFrom(from, to, value);
    }

    function transferFromAndSettle(address from, address to, uint value) public optionalProxy returns (bool) {

        systemStatus().requireSynthActive(currencyKey);

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
            amountInUSD = exchanger().exchange(messageSender, currencyKey, value, "sUSD", FEE_ADDRESS);
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

    function systemStatus() internal view returns (ISystemStatus) {

        return ISystemStatus(requireAndGetAddress(CONTRACT_SYSTEMSTATUS, "Missing SystemStatus address"));
    }

    function synthetix() internal view returns (ISynthetix) {

        return ISynthetix(requireAndGetAddress(CONTRACT_SYNTHETIX, "Missing Synthetix address"));
    }

    function feePool() internal view returns (IFeePool) {

        return IFeePool(requireAndGetAddress(CONTRACT_FEEPOOL, "Missing FeePool address"));
    }

    function exchanger() internal view returns (IExchanger) {

        return IExchanger(requireAndGetAddress(CONTRACT_EXCHANGER, "Missing Exchanger address"));
    }

    function issuer() internal view returns (IIssuer) {

        return IIssuer(requireAndGetAddress(CONTRACT_ISSUER, "Missing Issuer address"));
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


    function _internalTransferFrom(address from, address to, uint value) internal returns (bool) {

        if (tokenState.allowance(from, messageSender) != uint(-1)) {
            tokenState.setAllowance(from, messageSender, tokenState.allowance(from, messageSender).sub(value));
        }

        return super._internalTransfer(from, to, value);
    }


    modifier onlyInternalContracts() {

        bool isSynthetix = msg.sender == address(synthetix());
        bool isFeePool = msg.sender == address(feePool());
        bool isExchanger = msg.sender == address(exchanger());
        bool isIssuer = msg.sender == address(issuer());

        require(
            isSynthetix || isFeePool || isExchanger || isIssuer,
            "Only Synthetix, FeePool, Exchanger or Issuer contracts allowed"
        );
        _;
    }

    event Issued(address indexed account, uint value);
    bytes32 private constant ISSUED_SIG = keccak256("Issued(address,uint256)");

    function emitIssued(address account, uint value) internal {

        proxy._emit(abi.encode(value), 2, ISSUED_SIG, bytes32(account), 0, 0);
    }

    event Burned(address indexed account, uint value);
    bytes32 private constant BURNED_SIG = keccak256("Burned(address,uint256)");

    function emitBurned(address account, uint value) internal {

        proxy._emit(abi.encode(value), 2, BURNED_SIG, bytes32(account), 0, 0);
    }
}




contract ISynthetix {


    uint public totalSupply;

    mapping(bytes32 => Synth) public synths;

    mapping(address => bytes32) public synthsByAddress;


    function balanceOf(address account) public view returns (uint);


    function transfer(address to, uint value) public returns (bool);


    function transferFrom(address from, address to, uint value) public returns (bool);


    function exchange(bytes32 sourceCurrencyKey, uint sourceAmount, bytes32 destinationCurrencyKey)
        external
        returns (uint amountReceived);


    function issueSynths(uint amount) external;


    function issueMaxSynths() external;


    function burnSynths(uint amount) external;


    function burnSynthsToTarget() external;


    function settle(bytes32 currencyKey) external returns (uint reclaimed, uint refunded, uint numEntries);


    function collateralisationRatio(address issuer) public view returns (uint);


    function totalIssuedSynths(bytes32 currencyKey) public view returns (uint);


    function totalIssuedSynthsExcludeEtherCollateral(bytes32 currencyKey) public view returns (uint);


    function debtBalanceOf(address issuer, bytes32 currencyKey) public view returns (uint);


    function debtBalanceOfAndTotalDebt(address issuer, bytes32 currencyKey)
        public
        view
        returns (uint debtBalance, uint totalSystemValue);


    function remainingIssuableSynths(address issuer)
        public
        view
        returns (uint maxIssuable, uint alreadyIssued, uint totalSystemDebt);


    function maxIssuableSynths(address issuer) public view returns (uint maxIssuable);


    function isWaitingPeriod(bytes32 currencyKey) external view returns (bool);


    function emitSynthExchange(
        address account,
        bytes32 fromCurrencyKey,
        uint fromAmount,
        bytes32 toCurrencyKey,
        uint toAmount,
        address toAddress
    ) external;


    function emitExchangeReclaim(address account, bytes32 currencyKey, uint amount) external;


    function emitExchangeRebate(address account, bytes32 currencyKey, uint amount) external;

}


contract SupplySchedule is Owned {

    using SafeMath for uint;
    using SafeDecimalMath for uint;
    using Math for uint;

    uint public lastMintEvent;

    uint public weekCounter;

    uint public minterReward = 200 * SafeDecimalMath.unit();

    uint public constant INITIAL_WEEKLY_SUPPLY = 1442307692307692307692307;

    address public synthetixProxy;

    uint public constant MAX_MINTER_REWARD = 200 * SafeDecimalMath.unit();

    uint public constant MINT_PERIOD_DURATION = 1 weeks;

    uint public constant INFLATION_START_DATE = 1551830400; // 2019-03-06T00:00:00+00:00
    uint public constant MINT_BUFFER = 1 days;
    uint8 public constant SUPPLY_DECAY_START = 40; // Week 40
    uint8 public constant SUPPLY_DECAY_END = 234; //  Supply Decay ends on Week 234 (inclusive of Week 234 for a total of 195 weeks of inflation decay)

    uint public constant DECAY_RATE = 12500000000000000; // 1.25% weekly

    uint public constant TERMINAL_SUPPLY_RATE_ANNUAL = 25000000000000000; // 2.5% pa

    constructor(address _owner, uint _lastMintEvent, uint _currentWeek) public Owned(_owner) {
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
                uint totalSupply = ISynthetix(synthetixProxy).totalSupply();
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

        require(_synthetixProxy != address(0), "Address cannot be 0");
        synthetixProxy = _synthetixProxy;
        emit SynthetixProxyUpdated(synthetixProxy);
    }


    modifier onlySynthetix() {

        require(
            msg.sender == address(Proxy(synthetixProxy).target()),
            "Only the synthetix contract can perform this action"
        );
        _;
    }

    event SupplyMinted(uint supplyMinted, uint numberOfWeeksIssued, uint lastMintEvent, uint timestamp);

    event MinterRewardUpdated(uint newRewardAmount);

    event SynthetixProxyUpdated(address newAddress);
}


interface IRewardsDistribution {

    function distributeRewards(uint amount) external;

}


contract IEtherCollateral {

    uint256 public totalIssuedSynths;
}


contract Synthetix is ExternStateToken, MixinResolver {


    Synth[] public availableSynths;
    mapping(bytes32 => Synth) public synths;
    mapping(address => bytes32) public synthsByAddress;

    string constant TOKEN_NAME = "Synthetix Network Token";
    string constant TOKEN_SYMBOL = "SNX";
    uint8 constant DECIMALS = 18;
    bytes32 constant sUSD = "sUSD";


    bytes32 private constant CONTRACT_SYSTEMSTATUS = "SystemStatus";
    bytes32 private constant CONTRACT_EXCHANGER = "Exchanger";
    bytes32 private constant CONTRACT_ETHERCOLLATERAL = "EtherCollateral";
    bytes32 private constant CONTRACT_ISSUER = "Issuer";
    bytes32 private constant CONTRACT_SYNTHETIXSTATE = "SynthetixState";
    bytes32 private constant CONTRACT_EXRATES = "ExchangeRates";
    bytes32 private constant CONTRACT_FEEPOOL = "FeePool";
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
        CONTRACT_FEEPOOL,
        CONTRACT_SUPPLYSCHEDULE,
        CONTRACT_REWARDESCROW,
        CONTRACT_SYNTHETIXESCROW,
        CONTRACT_REWARDSDISTRIBUTION
    ];


    constructor(address _proxy, TokenState _tokenState, address _owner, uint _totalSupply, address _resolver)
        public
        ExternStateToken(_proxy, _tokenState, TOKEN_NAME, TOKEN_SYMBOL, _totalSupply, DECIMALS, _owner)
        MixinResolver(_owner, _resolver, addressesToCache)
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

    function feePool() internal view returns (IFeePool) {

        return IFeePool(requireAndGetAddress(CONTRACT_FEEPOOL, "Missing FeePool address"));
    }

    function supplySchedule() internal view returns (SupplySchedule) {

        return SupplySchedule(requireAndGetAddress(CONTRACT_SUPPLYSCHEDULE, "Missing SupplySchedule address"));
    }

    function rewardEscrow() internal view returns (ISynthetixEscrow) {

        return ISynthetixEscrow(requireAndGetAddress(CONTRACT_REWARDESCROW, "Missing RewardEscrow address"));
    }

    function synthetixEscrow() internal view returns (ISynthetixEscrow) {

        return ISynthetixEscrow(requireAndGetAddress(CONTRACT_SYNTHETIXESCROW, "Missing SynthetixEscrow address"));
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
            uint totalSynths = availableSynths[i].totalSupply();

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

    function availableCurrencyKeys() public view returns (bytes32[]) {

        bytes32[] memory currencyKeys = new bytes32[](availableSynths.length);

        for (uint i = 0; i < availableSynths.length; i++) {
            currencyKeys[i] = synthsByAddress[availableSynths[i]];
        }

        return currencyKeys;
    }

    function availableSynthCount() public view returns (uint) {

        return availableSynths.length;
    }

    function isWaitingPeriod(bytes32 currencyKey) external view returns (bool) {

        return exchanger().maxSecsLeftInWaitingPeriod(messageSender, currencyKey) > 0;
    }


    function addSynth(Synth synth) external optionalProxy_onlyOwner {

        bytes32 currencyKey = synth.currencyKey();

        require(synths[currencyKey] == Synth(0), "Synth already exists");
        require(synthsByAddress[synth] == bytes32(0), "Synth address already exists");

        availableSynths.push(synth);
        synths[currencyKey] = synth;
        synthsByAddress[synth] = currencyKey;
    }

    function removeSynth(bytes32 currencyKey) external optionalProxy_onlyOwner {

        require(synths[currencyKey] != address(0), "Synth does not exist");
        require(synths[currencyKey].totalSupply() == 0, "Synth supply exists");
        require(currencyKey != sUSD, "Cannot remove synth");

        address synthToRemove = synths[currencyKey];

        for (uint i = 0; i < availableSynths.length; i++) {
            if (availableSynths[i] == synthToRemove) {
                delete availableSynths[i];

                availableSynths[i] = availableSynths[availableSynths.length - 1];

                availableSynths.length--;

                break;
            }
        }

        delete synthsByAddress[synths[currencyKey]];
        delete synths[currencyKey];


    }

    function transfer(address to, uint value) public optionalProxy returns (bool) {

        systemStatus().requireSystemActive();

        require(value <= transferableSynthetix(messageSender), "Cannot transfer staked or escrowed SNX");

        _transfer_byProxy(messageSender, to, value);

        return true;
    }

    function transferFrom(address from, address to, uint value) public optionalProxy returns (bool) {

        systemStatus().requireSystemActive();

        require(value <= transferableSynthetix(from), "Cannot transfer staked or escrowed SNX");

        return _transferFrom_byProxy(messageSender, from, to, value);
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

    function exchange(bytes32 sourceCurrencyKey, uint sourceAmount, bytes32 destinationCurrencyKey)
        external
        optionalProxy
        returns (uint amountReceived)
    {

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
        returns (uint reclaimed, uint refunded, uint numEntriesSettled)
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

        if (synthetixEscrow() != address(0)) {
            balance = balance.add(synthetixEscrow().balanceOf(account));
        }

        if (rewardEscrow() != address(0)) {
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

        require(rewardsDistribution() != address(0), "RewardsDistribution not set");

        systemStatus().requireIssuanceActive();

        SupplySchedule _supplySchedule = supplySchedule();
        IRewardsDistribution _rewardsDistribution = rewardsDistribution();

        uint supplyToMint = _supplySchedule.mintableSupply();
        require(supplyToMint > 0, "No supply is mintable");

        _supplySchedule.recordMintEvent(supplyToMint);

        uint minterReward = _supplySchedule.minterReward();
        uint amountToDistribute = supplyToMint.sub(minterReward);

        tokenState.setBalanceOf(_rewardsDistribution, tokenState.balanceOf(_rewardsDistribution).add(amountToDistribute));
        emitTransfer(this, _rewardsDistribution, amountToDistribute);

        _rewardsDistribution.distributeRewards(amountToDistribute);

        tokenState.setBalanceOf(msg.sender, tokenState.balanceOf(msg.sender).add(minterReward));
        emitTransfer(this, msg.sender, minterReward);

        totalSupply = totalSupply.add(supplyToMint);

        return true;
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
    bytes32 constant SYNTHEXCHANGE_SIG = keccak256("SynthExchange(address,bytes32,uint256,bytes32,uint256,address)");

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
            bytes32(account),
            0,
            0
        );
    }

    event ExchangeReclaim(address indexed account, bytes32 currencyKey, uint amount);
    bytes32 constant EXCHANGERECLAIM_SIG = keccak256("ExchangeReclaim(address,bytes32,uint256)");

    function emitExchangeReclaim(address account, bytes32 currencyKey, uint256 amount) external onlyExchanger {

        proxy._emit(abi.encode(currencyKey, amount), 2, EXCHANGERECLAIM_SIG, bytes32(account), 0, 0);
    }

    event ExchangeRebate(address indexed account, bytes32 currencyKey, uint amount);
    bytes32 constant EXCHANGEREBATE_SIG = keccak256("ExchangeRebate(address,bytes32,uint256)");

    function emitExchangeRebate(address account, bytes32 currencyKey, uint256 amount) external onlyExchanger {

        proxy._emit(abi.encode(currencyKey, amount), 2, EXCHANGEREBATE_SIG, bytes32(account), 0, 0);
    }
}


contract LimitedSetup {

    uint setupExpiryTime;

    constructor(uint setupDuration) public {
        setupExpiryTime = now + setupDuration;
    }

    modifier onlyDuringSetup {

        require(now < setupExpiryTime, "Can only perform this action during setup");
        _;
    }
}


contract FeePoolState is SelfDestructible, LimitedSetup {

    using SafeMath for uint;
    using SafeDecimalMath for uint;


    uint8 public constant FEE_PERIOD_LENGTH = 6;

    address public feePool;

    struct IssuanceData {
        uint debtPercentage;
        uint debtEntryIndex;
    }

    mapping(address => IssuanceData[FEE_PERIOD_LENGTH]) public accountIssuanceLedger;

    constructor(address _owner, IFeePool _feePool) public SelfDestructible(_owner) LimitedSetup(6 weeks) {
        feePool = _feePool;
    }


    function setFeePool(IFeePool _feePool) external onlyOwner {

        feePool = _feePool;
    }


    function getAccountsDebtEntry(address account, uint index)
        public
        view
        returns (uint debtPercentage, uint debtEntryIndex)
    {

        require(index < FEE_PERIOD_LENGTH, "index exceeds the FEE_PERIOD_LENGTH");

        debtPercentage = accountIssuanceLedger[account][index].debtPercentage;
        debtEntryIndex = accountIssuanceLedger[account][index].debtEntryIndex;
    }

    function applicableIssuanceData(address account, uint closingDebtIndex) external view returns (uint, uint) {

        IssuanceData[FEE_PERIOD_LENGTH] memory issuanceData = accountIssuanceLedger[account];

        for (uint i = 0; i < FEE_PERIOD_LENGTH; i++) {
            if (closingDebtIndex >= issuanceData[i].debtEntryIndex) {
                return (issuanceData[i].debtPercentage, issuanceData[i].debtEntryIndex);
            }
        }
    }


    function appendAccountIssuanceRecord(
        address account,
        uint debtRatio,
        uint debtEntryIndex,
        uint currentPeriodStartDebtIndex
    ) external onlyFeePool {

        if (accountIssuanceLedger[account][0].debtEntryIndex < currentPeriodStartDebtIndex) {
            issuanceDataIndexOrder(account);
        }

        accountIssuanceLedger[account][0].debtPercentage = debtRatio;
        accountIssuanceLedger[account][0].debtEntryIndex = debtEntryIndex;
    }

    function issuanceDataIndexOrder(address account) private {

        for (uint i = FEE_PERIOD_LENGTH - 2; i < FEE_PERIOD_LENGTH; i--) {
            uint next = i + 1;
            accountIssuanceLedger[account][next].debtPercentage = accountIssuanceLedger[account][i].debtPercentage;
            accountIssuanceLedger[account][next].debtEntryIndex = accountIssuanceLedger[account][i].debtEntryIndex;
        }
    }

    function importIssuerData(address[] accounts, uint[] ratios, uint periodToInsert, uint feePeriodCloseIndex)
        external
        onlyOwner
        onlyDuringSetup
    {

        require(accounts.length == ratios.length, "Length mismatch");

        for (uint i = 0; i < accounts.length; i++) {
            accountIssuanceLedger[accounts[i]][periodToInsert].debtPercentage = ratios[i];
            accountIssuanceLedger[accounts[i]][periodToInsert].debtEntryIndex = feePeriodCloseIndex;
            emit IssuanceDebtRatioEntry(accounts[i], ratios[i], feePeriodCloseIndex);
        }
    }


    modifier onlyFeePool {

        require(msg.sender == address(feePool), "Only the FeePool contract can perform this action");
        _;
    }

    event IssuanceDebtRatioEntry(address indexed account, uint debtRatio, uint feePeriodCloseIndex);
}


contract EternalStorage is State {

    constructor(address _owner, address _associatedContract) public State(_owner, _associatedContract) {}

    mapping(bytes32 => uint) UIntStorage;
    mapping(bytes32 => string) StringStorage;
    mapping(bytes32 => address) AddressStorage;
    mapping(bytes32 => bytes) BytesStorage;
    mapping(bytes32 => bytes32) Bytes32Storage;
    mapping(bytes32 => bool) BooleanStorage;
    mapping(bytes32 => int) IntStorage;

    function getUIntValue(bytes32 record) external view returns (uint) {

        return UIntStorage[record];
    }

    function setUIntValue(bytes32 record, uint value) external onlyAssociatedContract {

        UIntStorage[record] = value;
    }

    function deleteUIntValue(bytes32 record) external onlyAssociatedContract {

        delete UIntStorage[record];
    }

    function getStringValue(bytes32 record) external view returns (string memory) {

        return StringStorage[record];
    }

    function setStringValue(bytes32 record, string value) external onlyAssociatedContract {

        StringStorage[record] = value;
    }

    function deleteStringValue(bytes32 record) external onlyAssociatedContract {

        delete StringStorage[record];
    }

    function getAddressValue(bytes32 record) external view returns (address) {

        return AddressStorage[record];
    }

    function setAddressValue(bytes32 record, address value) external onlyAssociatedContract {

        AddressStorage[record] = value;
    }

    function deleteAddressValue(bytes32 record) external onlyAssociatedContract {

        delete AddressStorage[record];
    }

    function getBytesValue(bytes32 record) external view returns (bytes memory) {

        return BytesStorage[record];
    }

    function setBytesValue(bytes32 record, bytes value) external onlyAssociatedContract {

        BytesStorage[record] = value;
    }

    function deleteBytesValue(bytes32 record) external onlyAssociatedContract {

        delete BytesStorage[record];
    }

    function getBytes32Value(bytes32 record) external view returns (bytes32) {

        return Bytes32Storage[record];
    }

    function setBytes32Value(bytes32 record, bytes32 value) external onlyAssociatedContract {

        Bytes32Storage[record] = value;
    }

    function deleteBytes32Value(bytes32 record) external onlyAssociatedContract {

        delete Bytes32Storage[record];
    }

    function getBooleanValue(bytes32 record) external view returns (bool) {

        return BooleanStorage[record];
    }

    function setBooleanValue(bytes32 record, bool value) external onlyAssociatedContract {

        BooleanStorage[record] = value;
    }

    function deleteBooleanValue(bytes32 record) external onlyAssociatedContract {

        delete BooleanStorage[record];
    }

    function getIntValue(bytes32 record) external view returns (int) {

        return IntStorage[record];
    }

    function setIntValue(bytes32 record, int value) external onlyAssociatedContract {

        IntStorage[record] = value;
    }

    function deleteIntValue(bytes32 record) external onlyAssociatedContract {

        delete IntStorage[record];
    }
}




contract FeePoolEternalStorage is EternalStorage, LimitedSetup {

    bytes32 constant LAST_FEE_WITHDRAWAL = "last_fee_withdrawal";

    constructor(address _owner, address _feePool) public EternalStorage(_owner, _feePool) LimitedSetup(6 weeks) {}

    function importFeeWithdrawalData(address[] accounts, uint[] feePeriodIDs) external onlyOwner onlyDuringSetup {

        require(accounts.length == feePeriodIDs.length, "Length mismatch");

        for (uint8 i = 0; i < accounts.length; i++) {
            this.setUIntValue(keccak256(abi.encodePacked(LAST_FEE_WITHDRAWAL, accounts[i])), feePeriodIDs[i]);
        }
    }
}


contract DelegateApprovals is Owned {

    bytes32 public constant BURN_FOR_ADDRESS = "BurnForAddress";
    bytes32 public constant ISSUE_FOR_ADDRESS = "IssueForAddress";
    bytes32 public constant CLAIM_FOR_ADDRESS = "ClaimForAddress";
    bytes32 public constant EXCHANGE_FOR_ADDRESS = "ExchangeForAddress";
    bytes32 public constant APPROVE_ALL = "ApproveAll";

    bytes32[5] private _delegatableFunctions = [
        APPROVE_ALL,
        BURN_FOR_ADDRESS,
        ISSUE_FOR_ADDRESS,
        CLAIM_FOR_ADDRESS,
        EXCHANGE_FOR_ADDRESS
    ];

    EternalStorage public eternalStorage;

    constructor(address _owner, EternalStorage _eternalStorage) public Owned(_owner) {
        eternalStorage = _eternalStorage;
    }



    function _getKey(bytes32 _action, address _authoriser, address _delegate) internal pure returns (bytes32) {

        return keccak256(abi.encodePacked(_action, _authoriser, _delegate));
    }

    function canBurnFor(address authoriser, address delegate) external view returns (bool) {

        return _checkApproval(BURN_FOR_ADDRESS, authoriser, delegate);
    }

    function canIssueFor(address authoriser, address delegate) external view returns (bool) {

        return _checkApproval(ISSUE_FOR_ADDRESS, authoriser, delegate);
    }

    function canClaimFor(address authoriser, address delegate) external view returns (bool) {

        return _checkApproval(CLAIM_FOR_ADDRESS, authoriser, delegate);
    }

    function canExchangeFor(address authoriser, address delegate) external view returns (bool) {

        return _checkApproval(EXCHANGE_FOR_ADDRESS, authoriser, delegate);
    }

    function approvedAll(address authoriser, address delegate) public view returns (bool) {

        return eternalStorage.getBooleanValue(_getKey(APPROVE_ALL, authoriser, delegate));
    }

    function _checkApproval(bytes32 action, address authoriser, address delegate) internal view returns (bool) {

        if (approvedAll(authoriser, delegate)) return true;

        return eternalStorage.getBooleanValue(_getKey(action, authoriser, delegate));
    }


    function approveAllDelegatePowers(address delegate) external {

        _setApproval(APPROVE_ALL, msg.sender, delegate);
    }

    function removeAllDelegatePowers(address delegate) external {

        for (uint i = 0; i < _delegatableFunctions.length; i++) {
            _withdrawApproval(_delegatableFunctions[i], msg.sender, delegate);
        }
    }

    function approveBurnOnBehalf(address delegate) external {

        _setApproval(BURN_FOR_ADDRESS, msg.sender, delegate);
    }

    function removeBurnOnBehalf(address delegate) external {

        _withdrawApproval(BURN_FOR_ADDRESS, msg.sender, delegate);
    }

    function approveIssueOnBehalf(address delegate) external {

        _setApproval(ISSUE_FOR_ADDRESS, msg.sender, delegate);
    }

    function removeIssueOnBehalf(address delegate) external {

        _withdrawApproval(ISSUE_FOR_ADDRESS, msg.sender, delegate);
    }

    function approveClaimOnBehalf(address delegate) external {

        _setApproval(CLAIM_FOR_ADDRESS, msg.sender, delegate);
    }

    function removeClaimOnBehalf(address delegate) external {

        _withdrawApproval(CLAIM_FOR_ADDRESS, msg.sender, delegate);
    }

    function approveExchangeOnBehalf(address delegate) external {

        _setApproval(EXCHANGE_FOR_ADDRESS, msg.sender, delegate);
    }

    function removeExchangeOnBehalf(address delegate) external {

        _withdrawApproval(EXCHANGE_FOR_ADDRESS, msg.sender, delegate);
    }

    function _setApproval(bytes32 action, address authoriser, address delegate) internal {

        require(delegate != address(0), "Can't delegate to address(0)");
        eternalStorage.setBooleanValue(_getKey(action, authoriser, delegate), true);
        emit Approval(authoriser, delegate, action);
    }

    function _withdrawApproval(bytes32 action, address authoriser, address delegate) internal {

        if (eternalStorage.getBooleanValue(_getKey(action, authoriser, delegate))) {
            eternalStorage.deleteBooleanValue(_getKey(action, authoriser, delegate));
            emit WithdrawApproval(authoriser, delegate, action);
        }
    }

    function setEternalStorage(EternalStorage _eternalStorage) external onlyOwner {

        require(_eternalStorage != address(0), "Can't set eternalStorage to address(0)");
        eternalStorage = _eternalStorage;
        emit EternalStorageUpdated(eternalStorage);
    }

    event Approval(address indexed authoriser, address delegate, bytes32 action);
    event WithdrawApproval(address indexed authoriser, address delegate, bytes32 action);
    event EternalStorageUpdated(address newEternalStorage);
}


contract FeePool is Proxyable, SelfDestructible, LimitedSetup, MixinResolver {

    using SafeMath for uint;
    using SafeDecimalMath for uint;

    uint public exchangeFeeRate;

    uint public constant MAX_EXCHANGE_FEE_RATE = SafeDecimalMath.unit() / 10;

    address public constant FEE_ADDRESS = 0xfeEFEEfeefEeFeefEEFEEfEeFeefEEFeeFEEFEeF;

    bytes32 private sUSD = "sUSD";

    struct FeePeriod {
        uint64 feePeriodId;
        uint64 startingDebtIndex;
        uint64 startTime;
        uint feesToDistribute;
        uint feesClaimed;
        uint rewardsToDistribute;
        uint rewardsClaimed;
    }

    uint8 public constant FEE_PERIOD_LENGTH = 2;

    FeePeriod[FEE_PERIOD_LENGTH] private _recentFeePeriods;
    uint256 private _currentFeePeriod;

    uint public feePeriodDuration = 1 weeks;
    uint public constant MIN_FEE_PERIOD_DURATION = 1 days;
    uint public constant MAX_FEE_PERIOD_DURATION = 60 days;

    uint public targetThreshold = (1 * SafeDecimalMath.unit()) / 100;


    bytes32 private constant CONTRACT_SYSTEMSTATUS = "SystemStatus";
    bytes32 private constant CONTRACT_EXRATES = "ExchangeRates";
    bytes32 private constant CONTRACT_SYNTHETIX = "Synthetix";
    bytes32 private constant CONTRACT_FEEPOOLSTATE = "FeePoolState";
    bytes32 private constant CONTRACT_FEEPOOLETERNALSTORAGE = "FeePoolEternalStorage";
    bytes32 private constant CONTRACT_EXCHANGER = "Exchanger";
    bytes32 private constant CONTRACT_ISSUER = "Issuer";
    bytes32 private constant CONTRACT_SYNTHETIXSTATE = "SynthetixState";
    bytes32 private constant CONTRACT_REWARDESCROW = "RewardEscrow";
    bytes32 private constant CONTRACT_DELEGATEAPPROVALS = "DelegateApprovals";
    bytes32 private constant CONTRACT_REWARDSDISTRIBUTION = "RewardsDistribution";

    bytes32[24] private addressesToCache = [
        CONTRACT_SYSTEMSTATUS,
        CONTRACT_EXRATES,
        CONTRACT_SYNTHETIX,
        CONTRACT_FEEPOOLSTATE,
        CONTRACT_FEEPOOLETERNALSTORAGE,
        CONTRACT_EXCHANGER,
        CONTRACT_ISSUER,
        CONTRACT_SYNTHETIXSTATE,
        CONTRACT_REWARDESCROW,
        CONTRACT_DELEGATEAPPROVALS,
        CONTRACT_REWARDSDISTRIBUTION
    ];


    bytes32 private constant LAST_FEE_WITHDRAWAL = "last_fee_withdrawal";

    constructor(address _proxy, address _owner, uint _exchangeFeeRate, address _resolver)
        public
        SelfDestructible(_owner)
        Proxyable(_proxy, _owner)
        LimitedSetup(3 weeks)
        MixinResolver(_owner, _resolver, addressesToCache)
    {
        require(_exchangeFeeRate <= MAX_EXCHANGE_FEE_RATE, "Exchange fee rate max exceeded");

        exchangeFeeRate = _exchangeFeeRate;

        _recentFeePeriodsStorage(0).feePeriodId = 1;
        _recentFeePeriodsStorage(0).startTime = uint64(now);
    }


    function systemStatus() internal view returns (ISystemStatus) {

        return ISystemStatus(requireAndGetAddress(CONTRACT_SYSTEMSTATUS, "Missing SystemStatus address"));
    }

    function synthetix() internal view returns (ISynthetix) {

        return ISynthetix(requireAndGetAddress(CONTRACT_SYNTHETIX, "Missing Synthetix address"));
    }

    function feePoolState() internal view returns (FeePoolState) {

        return FeePoolState(requireAndGetAddress(CONTRACT_FEEPOOLSTATE, "Missing FeePoolState address"));
    }

    function feePoolEternalStorage() internal view returns (FeePoolEternalStorage) {

        return
            FeePoolEternalStorage(
                requireAndGetAddress(CONTRACT_FEEPOOLETERNALSTORAGE, "Missing FeePoolEternalStorage address")
            );
    }

    function exchanger() internal view returns (IExchanger) {

        return IExchanger(requireAndGetAddress(CONTRACT_EXCHANGER, "Missing Exchanger address"));
    }

    function issuer() internal view returns (IIssuer) {

        return IIssuer(requireAndGetAddress(CONTRACT_ISSUER, "Missing Issuer address"));
    }

    function synthetixState() internal view returns (ISynthetixState) {

        return ISynthetixState(requireAndGetAddress(CONTRACT_SYNTHETIXSTATE, "Missing SynthetixState address"));
    }

    function rewardEscrow() internal view returns (ISynthetixEscrow) {

        return ISynthetixEscrow(requireAndGetAddress(CONTRACT_REWARDESCROW, "Missing RewardEscrow address"));
    }

    function delegateApprovals() internal view returns (DelegateApprovals) {

        return DelegateApprovals(requireAndGetAddress(CONTRACT_DELEGATEAPPROVALS, "Missing DelegateApprovals address"));
    }

    function rewardsDistribution() internal view returns (IRewardsDistribution) {

        return
            IRewardsDistribution(requireAndGetAddress(CONTRACT_REWARDSDISTRIBUTION, "Missing RewardsDistribution address"));
    }

    function recentFeePeriods(uint index)
        external
        view
        returns (
            uint64 feePeriodId,
            uint64 startingDebtIndex,
            uint64 startTime,
            uint feesToDistribute,
            uint feesClaimed,
            uint rewardsToDistribute,
            uint rewardsClaimed
        )
    {

        FeePeriod memory feePeriod = _recentFeePeriodsStorage(index);
        return (
            feePeriod.feePeriodId,
            feePeriod.startingDebtIndex,
            feePeriod.startTime,
            feePeriod.feesToDistribute,
            feePeriod.feesClaimed,
            feePeriod.rewardsToDistribute,
            feePeriod.rewardsClaimed
        );
    }

    function _recentFeePeriodsStorage(uint index) internal view returns (FeePeriod storage) {

        return _recentFeePeriods[(_currentFeePeriod + index) % FEE_PERIOD_LENGTH];
    }


    function appendAccountIssuanceRecord(address account, uint debtRatio, uint debtEntryIndex) external onlyIssuer {

        feePoolState().appendAccountIssuanceRecord(
            account,
            debtRatio,
            debtEntryIndex,
            _recentFeePeriodsStorage(0).startingDebtIndex
        );

        emitIssuanceDebtRatioEntry(account, debtRatio, debtEntryIndex, _recentFeePeriodsStorage(0).startingDebtIndex);
    }

    function setExchangeFeeRate(uint _exchangeFeeRate) external optionalProxy_onlyOwner {

        require(_exchangeFeeRate < MAX_EXCHANGE_FEE_RATE, "rate < MAX_EXCHANGE_FEE_RATE");
        exchangeFeeRate = _exchangeFeeRate;
    }

    function setFeePeriodDuration(uint _feePeriodDuration) external optionalProxy_onlyOwner {

        require(_feePeriodDuration >= MIN_FEE_PERIOD_DURATION, "value < MIN_FEE_PERIOD_DURATION");
        require(_feePeriodDuration <= MAX_FEE_PERIOD_DURATION, "value > MAX_FEE_PERIOD_DURATION");

        feePeriodDuration = _feePeriodDuration;

        emitFeePeriodDurationUpdated(_feePeriodDuration);
    }

    function setTargetThreshold(uint _percent) external optionalProxy_onlyOwner {

        require(_percent >= 0, "Threshold should be positive");
        require(_percent <= 50, "Threshold too high");
        targetThreshold = _percent.mul(SafeDecimalMath.unit()).div(100);
    }

    function recordFeePaid(uint amount) external onlyExchangerOrSynth {

        _recentFeePeriodsStorage(0).feesToDistribute = _recentFeePeriodsStorage(0).feesToDistribute.add(amount);
    }

    function setRewardsToDistribute(uint amount) external {

        address rewardsAuthority = rewardsDistribution();
        require(messageSender == rewardsAuthority || msg.sender == rewardsAuthority, "Caller is not rewardsAuthority");
        _recentFeePeriodsStorage(0).rewardsToDistribute = _recentFeePeriodsStorage(0).rewardsToDistribute.add(amount);
    }

    function closeCurrentFeePeriod() external {

        require(_recentFeePeriodsStorage(0).startTime <= (now - feePeriodDuration), "Too early to close fee period");

        systemStatus().requireIssuanceActive();

        FeePeriod storage periodClosing = _recentFeePeriodsStorage(FEE_PERIOD_LENGTH - 2);
        FeePeriod storage periodToRollover = _recentFeePeriodsStorage(FEE_PERIOD_LENGTH - 1);

        _recentFeePeriodsStorage(FEE_PERIOD_LENGTH - 2).feesToDistribute = periodToRollover
            .feesToDistribute
            .sub(periodToRollover.feesClaimed)
            .add(periodClosing.feesToDistribute);
        _recentFeePeriodsStorage(FEE_PERIOD_LENGTH - 2).rewardsToDistribute = periodToRollover
            .rewardsToDistribute
            .sub(periodToRollover.rewardsClaimed)
            .add(periodClosing.rewardsToDistribute);

        _currentFeePeriod = _currentFeePeriod.add(FEE_PERIOD_LENGTH).sub(1).mod(FEE_PERIOD_LENGTH);

        delete _recentFeePeriods[_currentFeePeriod];

        _recentFeePeriodsStorage(0).feePeriodId = uint64(uint256(_recentFeePeriodsStorage(1).feePeriodId).add(1));
        _recentFeePeriodsStorage(0).startingDebtIndex = uint64(synthetixState().debtLedgerLength());
        _recentFeePeriodsStorage(0).startTime = uint64(now);

        emitFeePeriodClosed(_recentFeePeriodsStorage(1).feePeriodId);
    }

    function claimFees() external optionalProxy returns (bool) {

        return _claimFees(messageSender);
    }

    function claimOnBehalf(address claimingForAddress) external optionalProxy returns (bool) {

        require(delegateApprovals().canClaimFor(claimingForAddress, messageSender), "Not approved to claim on behalf");

        return _claimFees(claimingForAddress);
    }

    function _claimFees(address claimingAddress) internal returns (bool) {

        systemStatus().requireIssuanceActive();

        uint rewardsPaid = 0;
        uint feesPaid = 0;
        uint availableFees;
        uint availableRewards;

        require(isFeesClaimable(claimingAddress), "C-Ratio below penalty threshold");

        (availableFees, availableRewards) = feesAvailable(claimingAddress);

        require(
            availableFees > 0 || availableRewards > 0,
            "No fees or rewards available for period, or fees already claimed"
        );

        _setLastFeeWithdrawal(claimingAddress, _recentFeePeriodsStorage(1).feePeriodId);

        if (availableFees > 0) {
            feesPaid = _recordFeePayment(availableFees);

            _payFees(claimingAddress, feesPaid);
        }

        if (availableRewards > 0) {
            rewardsPaid = _recordRewardPayment(availableRewards);

            _payRewards(claimingAddress, rewardsPaid);
        }

        emitFeesClaimed(claimingAddress, feesPaid, rewardsPaid);

        return true;
    }

    function importFeePeriod(
        uint feePeriodIndex,
        uint feePeriodId,
        uint startingDebtIndex,
        uint startTime,
        uint feesToDistribute,
        uint feesClaimed,
        uint rewardsToDistribute,
        uint rewardsClaimed
    ) public optionalProxy_onlyOwner onlyDuringSetup {

        require(startingDebtIndex <= synthetixState().debtLedgerLength(), "Cannot import bad data");

        _recentFeePeriods[_currentFeePeriod.add(feePeriodIndex).mod(FEE_PERIOD_LENGTH)] = FeePeriod({
            feePeriodId: uint64(feePeriodId),
            startingDebtIndex: uint64(startingDebtIndex),
            startTime: uint64(startTime),
            feesToDistribute: feesToDistribute,
            feesClaimed: feesClaimed,
            rewardsToDistribute: rewardsToDistribute,
            rewardsClaimed: rewardsClaimed
        });
    }

    function appendVestingEntry(address account, uint quantity) public optionalProxy_onlyOwner {

        synthetix().transferFrom(messageSender, rewardEscrow(), quantity);

        rewardEscrow().appendVestingEntry(account, quantity);
    }

    function _recordFeePayment(uint sUSDAmount) internal returns (uint) {

        uint remainingToAllocate = sUSDAmount;

        uint feesPaid;
        for (uint i = FEE_PERIOD_LENGTH - 1; i < FEE_PERIOD_LENGTH; i--) {
            uint feesAlreadyClaimed = _recentFeePeriodsStorage(i).feesClaimed;
            uint delta = _recentFeePeriodsStorage(i).feesToDistribute.sub(feesAlreadyClaimed);

            if (delta > 0) {
                uint amountInPeriod = delta < remainingToAllocate ? delta : remainingToAllocate;

                _recentFeePeriodsStorage(i).feesClaimed = feesAlreadyClaimed.add(amountInPeriod);
                remainingToAllocate = remainingToAllocate.sub(amountInPeriod);
                feesPaid = feesPaid.add(amountInPeriod);

                if (remainingToAllocate == 0) return feesPaid;

                if (i == 0 && remainingToAllocate > 0) {
                    remainingToAllocate = 0;
                }
            }
        }

        return feesPaid;
    }

    function _recordRewardPayment(uint snxAmount) internal returns (uint) {

        uint remainingToAllocate = snxAmount;

        uint rewardPaid;

        for (uint i = FEE_PERIOD_LENGTH - 1; i < FEE_PERIOD_LENGTH; i--) {
            uint toDistribute = _recentFeePeriodsStorage(i).rewardsToDistribute.sub(
                _recentFeePeriodsStorage(i).rewardsClaimed
            );

            if (toDistribute > 0) {
                uint amountInPeriod = toDistribute < remainingToAllocate ? toDistribute : remainingToAllocate;

                _recentFeePeriodsStorage(i).rewardsClaimed = _recentFeePeriodsStorage(i).rewardsClaimed.add(amountInPeriod);
                remainingToAllocate = remainingToAllocate.sub(amountInPeriod);
                rewardPaid = rewardPaid.add(amountInPeriod);

                if (remainingToAllocate == 0) return rewardPaid;

                if (i == 0 && remainingToAllocate > 0) {
                    remainingToAllocate = 0;
                }
            }
        }
        return rewardPaid;
    }

    function _payFees(address account, uint sUSDAmount) internal notFeeAddress(account) {

        require(
            account != address(0) ||
                account != address(this) ||
                account != address(proxy) ||
                account != address(synthetix()),
            "Can't send fees to this address"
        );

        Synth sUSDSynth = synthetix().synths(sUSD);


        sUSDSynth.burn(FEE_ADDRESS, sUSDAmount);

        sUSDSynth.issue(account, sUSDAmount);
    }

    function _payRewards(address account, uint snxAmount) internal notFeeAddress(account) {

        require(account != address(0), "Account can't be 0");
        require(account != address(this), "Can't send rewards to fee pool");
        require(account != address(proxy), "Can't send rewards to proxy");
        require(account != address(synthetix()), "Can't send rewards to synthetix");

        rewardEscrow().appendVestingEntry(account, snxAmount);
    }

    function amountReceivedFromTransfer(uint value) external pure returns (uint) {

        return value;
    }

    function exchangeFeeIncurred(uint value) public view returns (uint) {

        return value.multiplyDecimal(exchangeFeeRate);

    }

    function amountReceivedFromExchange(uint value) external view returns (uint) {

        return value.multiplyDecimal(SafeDecimalMath.unit().sub(exchangeFeeRate));
    }

    function totalFeesAvailable() external view returns (uint) {

        uint totalFees = 0;

        for (uint i = 1; i < FEE_PERIOD_LENGTH; i++) {
            totalFees = totalFees.add(_recentFeePeriodsStorage(i).feesToDistribute);
            totalFees = totalFees.sub(_recentFeePeriodsStorage(i).feesClaimed);
        }

        return totalFees;
    }

    function totalRewardsAvailable() external view returns (uint) {

        uint totalRewards = 0;

        for (uint i = 1; i < FEE_PERIOD_LENGTH; i++) {
            totalRewards = totalRewards.add(_recentFeePeriodsStorage(i).rewardsToDistribute);
            totalRewards = totalRewards.sub(_recentFeePeriodsStorage(i).rewardsClaimed);
        }

        return totalRewards;
    }

    function feesAvailable(address account) public view returns (uint, uint) {

        uint[2][FEE_PERIOD_LENGTH] memory userFees = feesByPeriod(account);

        uint totalFees = 0;
        uint totalRewards = 0;

        for (uint i = 1; i < FEE_PERIOD_LENGTH; i++) {
            totalFees = totalFees.add(userFees[i][0]);
            totalRewards = totalRewards.add(userFees[i][1]);
        }

        return (totalFees, totalRewards);
    }

    function isFeesClaimable(address account) public view returns (bool) {

        uint ratio = synthetix().collateralisationRatio(account);
        uint targetRatio = synthetixState().issuanceRatio();

        if (ratio < targetRatio) {
            return true;
        }

        uint ratio_threshold = targetRatio.multiplyDecimal(SafeDecimalMath.unit().add(targetThreshold));

        if (ratio > ratio_threshold) {
            return false;
        }

        return true;
    }

    function feesByPeriod(address account) public view returns (uint[2][FEE_PERIOD_LENGTH] memory results) {

        uint userOwnershipPercentage;
        uint debtEntryIndex;
        FeePoolState _feePoolState = feePoolState();

        (userOwnershipPercentage, debtEntryIndex) = _feePoolState.getAccountsDebtEntry(account, 0);

        if (debtEntryIndex == 0 && userOwnershipPercentage == 0) return;

        uint feesFromPeriod;
        uint rewardsFromPeriod;
        (feesFromPeriod, rewardsFromPeriod) = _feesAndRewardsFromPeriod(0, userOwnershipPercentage, debtEntryIndex);

        results[0][0] = feesFromPeriod;
        results[0][1] = rewardsFromPeriod;

        uint lastFeeWithdrawal = getLastFeeWithdrawal(account);

        for (uint i = FEE_PERIOD_LENGTH - 1; i > 0; i--) {
            uint next = i - 1;
            uint nextPeriodStartingDebtIndex = _recentFeePeriodsStorage(next).startingDebtIndex;

            if (nextPeriodStartingDebtIndex > 0 && lastFeeWithdrawal < _recentFeePeriodsStorage(i).feePeriodId) {
                uint closingDebtIndex = uint256(nextPeriodStartingDebtIndex).sub(1);

                (userOwnershipPercentage, debtEntryIndex) = _feePoolState.applicableIssuanceData(account, closingDebtIndex);

                (feesFromPeriod, rewardsFromPeriod) = _feesAndRewardsFromPeriod(i, userOwnershipPercentage, debtEntryIndex);

                results[i][0] = feesFromPeriod;
                results[i][1] = rewardsFromPeriod;
            }
        }
    }

    function _feesAndRewardsFromPeriod(uint period, uint ownershipPercentage, uint debtEntryIndex)
        internal
        view
        returns (uint, uint)
    {

        if (ownershipPercentage == 0) return (0, 0);

        uint debtOwnershipForPeriod = ownershipPercentage;

        if (period > 0) {
            uint closingDebtIndex = uint256(_recentFeePeriodsStorage(period - 1).startingDebtIndex).sub(1);
            debtOwnershipForPeriod = _effectiveDebtRatioForPeriod(closingDebtIndex, ownershipPercentage, debtEntryIndex);
        }

        uint feesFromPeriod = _recentFeePeriodsStorage(period).feesToDistribute.multiplyDecimal(debtOwnershipForPeriod);

        uint rewardsFromPeriod = _recentFeePeriodsStorage(period).rewardsToDistribute.multiplyDecimal(
            debtOwnershipForPeriod
        );

        return (feesFromPeriod.preciseDecimalToDecimal(), rewardsFromPeriod.preciseDecimalToDecimal());
    }

    function _effectiveDebtRatioForPeriod(uint closingDebtIndex, uint ownershipPercentage, uint debtEntryIndex)
        internal
        view
        returns (uint)
    {

        ISynthetixState _synthetixState = synthetixState();
        uint feePeriodDebtOwnership = _synthetixState
            .debtLedger(closingDebtIndex)
            .divideDecimalRoundPrecise(_synthetixState.debtLedger(debtEntryIndex))
            .multiplyDecimalRoundPrecise(ownershipPercentage);

        return feePeriodDebtOwnership;
    }

    function effectiveDebtRatioForPeriod(address account, uint period) external view returns (uint) {

        require(period != 0, "Current period is not closed yet");
        require(period < FEE_PERIOD_LENGTH, "Exceeds the FEE_PERIOD_LENGTH");

        if (_recentFeePeriodsStorage(period - 1).startingDebtIndex == 0) return 0;

        uint closingDebtIndex = uint256(_recentFeePeriodsStorage(period - 1).startingDebtIndex).sub(1);

        uint ownershipPercentage;
        uint debtEntryIndex;
        (ownershipPercentage, debtEntryIndex) = feePoolState().applicableIssuanceData(account, closingDebtIndex);

        return _effectiveDebtRatioForPeriod(closingDebtIndex, ownershipPercentage, debtEntryIndex);
    }

    function getLastFeeWithdrawal(address _claimingAddress) public view returns (uint) {

        return feePoolEternalStorage().getUIntValue(keccak256(abi.encodePacked(LAST_FEE_WITHDRAWAL, _claimingAddress)));
    }

    function getPenaltyThresholdRatio() public view returns (uint) {

        uint targetRatio = synthetixState().issuanceRatio();

        return targetRatio.multiplyDecimal(SafeDecimalMath.unit().add(targetThreshold));
    }

    function _setLastFeeWithdrawal(address _claimingAddress, uint _feePeriodID) internal {

        feePoolEternalStorage().setUIntValue(
            keccak256(abi.encodePacked(LAST_FEE_WITHDRAWAL, _claimingAddress)),
            _feePeriodID
        );
    }

    modifier onlyExchangerOrSynth {

        bool isExchanger = msg.sender == address(exchanger());
        bool isSynth = synthetix().synthsByAddress(msg.sender) != bytes32(0);

        require(isExchanger || isSynth, "Only Exchanger, Synths Authorised");
        _;
    }

    modifier onlyIssuer {

        require(msg.sender == address(issuer()), "FeePool: Only Issuer Authorised");
        _;
    }

    modifier notFeeAddress(address account) {

        require(account != FEE_ADDRESS, "Fee address not allowed");
        _;
    }


    event IssuanceDebtRatioEntry(
        address indexed account,
        uint debtRatio,
        uint debtEntryIndex,
        uint feePeriodStartingDebtIndex
    );
    bytes32 private constant ISSUANCEDEBTRATIOENTRY_SIG = keccak256(
        "IssuanceDebtRatioEntry(address,uint256,uint256,uint256)"
    );

    function emitIssuanceDebtRatioEntry(
        address account,
        uint debtRatio,
        uint debtEntryIndex,
        uint feePeriodStartingDebtIndex
    ) internal {

        proxy._emit(
            abi.encode(debtRatio, debtEntryIndex, feePeriodStartingDebtIndex),
            2,
            ISSUANCEDEBTRATIOENTRY_SIG,
            bytes32(account),
            0,
            0
        );
    }

    event ExchangeFeeUpdated(uint newFeeRate);
    bytes32 private constant EXCHANGEFEEUPDATED_SIG = keccak256("ExchangeFeeUpdated(uint256)");

    function emitExchangeFeeUpdated(uint newFeeRate) internal {

        proxy._emit(abi.encode(newFeeRate), 1, EXCHANGEFEEUPDATED_SIG, 0, 0, 0);
    }

    event FeePeriodDurationUpdated(uint newFeePeriodDuration);
    bytes32 private constant FEEPERIODDURATIONUPDATED_SIG = keccak256("FeePeriodDurationUpdated(uint256)");

    function emitFeePeriodDurationUpdated(uint newFeePeriodDuration) internal {

        proxy._emit(abi.encode(newFeePeriodDuration), 1, FEEPERIODDURATIONUPDATED_SIG, 0, 0, 0);
    }

    event FeePeriodClosed(uint feePeriodId);
    bytes32 private constant FEEPERIODCLOSED_SIG = keccak256("FeePeriodClosed(uint256)");

    function emitFeePeriodClosed(uint feePeriodId) internal {

        proxy._emit(abi.encode(feePeriodId), 1, FEEPERIODCLOSED_SIG, 0, 0, 0);
    }

    event FeesClaimed(address account, uint sUSDAmount, uint snxRewards);
    bytes32 private constant FEESCLAIMED_SIG = keccak256("FeesClaimed(address,uint256,uint256)");

    function emitFeesClaimed(address account, uint sUSDAmount, uint snxRewards) internal {

        proxy._emit(abi.encode(account, sUSDAmount, snxRewards), 1, FEESCLAIMED_SIG, 0, 0, 0);
    }
}