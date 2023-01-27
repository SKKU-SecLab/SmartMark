



pragma solidity ^0.4.24;

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


interface IExchangeState {

    function appendExchangeEntry(
        address account,
        bytes32 src,
        uint amount,
        bytes32 dest,
        uint amountReceived,
        uint exchangeFeeRate,
        uint timestamp,
        uint roundIdForSrc,
        uint roundIdForDest
    ) external;


    function removeEntries(address account, bytes32 currencyKey) external;


    function getLengthOfEntries(address account, bytes32 currencyKey) external view returns (uint);


    function getEntryAt(address account, bytes32 currencyKey, uint index)
        external
        view
        returns (
            bytes32 src,
            uint amount,
            bytes32 dest,
            uint amountReceived,
            uint exchangeFeeRate,
            uint timestamp,
            uint roundIdForSrc,
            uint roundIdForDest
        );


    function getMaxTimestamp(address account, bytes32 currencyKey) external view returns (uint);

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


interface IDelegateApprovals {

    function canBurnFor(address authoriser, address delegate) external view returns (bool);


    function canIssueFor(address authoriser, address delegate) external view returns (bool);


    function canClaimFor(address authoriser, address delegate) external view returns (bool);


    function canExchangeFor(address authoriser, address delegate) external view returns (bool);

}


contract Exchanger is MixinResolver {

    using SafeMath for uint;
    using SafeDecimalMath for uint;

    bytes32 private constant sUSD = "sUSD";

    uint public waitingPeriodSecs;


    bytes32 private constant CONTRACT_SYSTEMSTATUS = "SystemStatus";
    bytes32 private constant CONTRACT_EXCHANGESTATE = "ExchangeState";
    bytes32 private constant CONTRACT_EXRATES = "ExchangeRates";
    bytes32 private constant CONTRACT_SYNTHETIX = "Synthetix";
    bytes32 private constant CONTRACT_FEEPOOL = "FeePool";
    bytes32 private constant CONTRACT_DELEGATEAPPROVALS = "DelegateApprovals";

    bytes32[24] private addressesToCache = [
        CONTRACT_SYSTEMSTATUS,
        CONTRACT_EXCHANGESTATE,
        CONTRACT_EXRATES,
        CONTRACT_SYNTHETIX,
        CONTRACT_FEEPOOL,
        CONTRACT_DELEGATEAPPROVALS
    ];

    constructor(address _owner, address _resolver) public MixinResolver(_owner, _resolver, addressesToCache) {
        waitingPeriodSecs = 3 minutes;
    }


    function systemStatus() internal view returns (ISystemStatus) {

        return ISystemStatus(requireAndGetAddress(CONTRACT_SYSTEMSTATUS, "Missing SystemStatus address"));
    }

    function exchangeState() internal view returns (IExchangeState) {

        return IExchangeState(requireAndGetAddress(CONTRACT_EXCHANGESTATE, "Missing ExchangeState address"));
    }

    function exchangeRates() internal view returns (IExchangeRates) {

        return IExchangeRates(requireAndGetAddress(CONTRACT_EXRATES, "Missing ExchangeRates address"));
    }

    function synthetix() internal view returns (ISynthetix) {

        return ISynthetix(requireAndGetAddress(CONTRACT_SYNTHETIX, "Missing Synthetix address"));
    }

    function feePool() internal view returns (IFeePool) {

        return IFeePool(requireAndGetAddress(CONTRACT_FEEPOOL, "Missing FeePool address"));
    }

    function delegateApprovals() internal view returns (IDelegateApprovals) {

        return IDelegateApprovals(requireAndGetAddress(CONTRACT_DELEGATEAPPROVALS, "Missing DelegateApprovals address"));
    }

    function maxSecsLeftInWaitingPeriod(address account, bytes32 currencyKey) public view returns (uint) {

        return secsLeftInWaitingPeriodForExchange(exchangeState().getMaxTimestamp(account, currencyKey));
    }

    function feeRateForExchange(bytes32 sourceCurrencyKey, bytes32 destinationCurrencyKey) public view returns (uint) {

        uint exchangeFeeRate = feePool().exchangeFeeRate();

        return exchangeFeeRate;
    }

    function settlementOwing(address account, bytes32 currencyKey)
        public
        view
        returns (uint reclaimAmount, uint rebateAmount, uint numEntries)
    {

        numEntries = exchangeState().getLengthOfEntries(account, currencyKey);

        for (uint i = 0; i < numEntries; i++) {
            (bytes32 src, uint amount, bytes32 dest, uint amountReceived, , , , ) = exchangeState().getEntryAt(
                account,
                currencyKey,
                i
            );

            (uint srcRoundIdAtPeriodEnd, uint destRoundIdAtPeriodEnd) = getRoundIdsAtPeriodEnd(account, currencyKey, i);

            uint destinationAmount = exchangeRates().effectiveValueAtRound(
                src,
                amount,
                dest,
                srcRoundIdAtPeriodEnd,
                destRoundIdAtPeriodEnd
            );

            (uint amountShouldHaveReceived, ) = calculateExchangeAmountMinusFees(src, dest, destinationAmount);

            if (amountReceived > amountShouldHaveReceived) {
                reclaimAmount = reclaimAmount.add(amountReceived.sub(amountShouldHaveReceived));
            } else if (amountShouldHaveReceived > amountReceived) {
                rebateAmount = rebateAmount.add(amountShouldHaveReceived.sub(amountReceived));
            }
        }

        return (reclaimAmount, rebateAmount, numEntries);
    }


    function setWaitingPeriodSecs(uint _waitingPeriodSecs) external onlyOwner {

        waitingPeriodSecs = _waitingPeriodSecs;
    }

    function calculateAmountAfterSettlement(address from, bytes32 currencyKey, uint amount, uint refunded)
        public
        view
        returns (uint amountAfterSettlement)
    {

        amountAfterSettlement = amount;

        uint balanceOfSourceAfterSettlement = synthetix().synths(currencyKey).balanceOf(from);

        if (amountAfterSettlement > balanceOfSourceAfterSettlement) {
            amountAfterSettlement = balanceOfSourceAfterSettlement;
        }

        if (refunded > 0) {
            amountAfterSettlement = amountAfterSettlement.add(refunded);
        }
    }

    function exchange(
        address from,
        bytes32 sourceCurrencyKey,
        uint sourceAmount,
        bytes32 destinationCurrencyKey,
        address destinationAddress
    ) external onlySynthetixorSynth returns (uint amountReceived) {

        amountReceived = _exchange(from, sourceCurrencyKey, sourceAmount, destinationCurrencyKey, destinationAddress);
    }

    function exchangeOnBehalf(
        address exchangeForAddress,
        address from,
        bytes32 sourceCurrencyKey,
        uint sourceAmount,
        bytes32 destinationCurrencyKey
    ) external onlySynthetixorSynth returns (uint amountReceived) {

        require(delegateApprovals().canExchangeFor(exchangeForAddress, from), "Not approved to act on behalf");
        amountReceived = _exchange(
            exchangeForAddress,
            sourceCurrencyKey,
            sourceAmount,
            destinationCurrencyKey,
            exchangeForAddress
        );
    }

    function _exchange(
        address from,
        bytes32 sourceCurrencyKey,
        uint sourceAmount,
        bytes32 destinationCurrencyKey,
        address destinationAddress
    )
        internal
        returns (
            uint amountReceived
        )
    {

        require(sourceCurrencyKey != destinationCurrencyKey, "Can't be same synth");
        require(sourceAmount > 0, "Zero amount");

        (, uint refunded, uint numEntriesSettled) = _internalSettle(from, sourceCurrencyKey);

        uint sourceAmountAfterSettlement = sourceAmount;

        if (numEntriesSettled > 0) {
            sourceAmountAfterSettlement = calculateAmountAfterSettlement(from, sourceCurrencyKey, sourceAmount, refunded);

            if (sourceAmountAfterSettlement == 0) {
                return 0;
            }
        }


        synthetix().synths(sourceCurrencyKey).burn(from, sourceAmountAfterSettlement);

        uint destinationAmount = exchangeRates().effectiveValue(
            sourceCurrencyKey,
            sourceAmountAfterSettlement,
            destinationCurrencyKey
        );

        uint fee;

        (amountReceived, fee) = calculateExchangeAmountMinusFees(
            sourceCurrencyKey,
            destinationCurrencyKey,
            destinationAmount
        );

        synthetix().synths(destinationCurrencyKey).issue(destinationAddress, amountReceived);

        if (fee > 0) {
            remitFee(exchangeRates(), synthetix(), fee, destinationCurrencyKey);
        }


        synthetix().emitSynthExchange(
            from,
            sourceCurrencyKey,
            sourceAmountAfterSettlement,
            destinationCurrencyKey,
            amountReceived,
            destinationAddress
        );

        appendExchange(
            destinationAddress,
            sourceCurrencyKey,
            sourceAmountAfterSettlement,
            destinationCurrencyKey,
            amountReceived
        );
    }

    function settle(address from, bytes32 currencyKey)
        external
        returns (uint reclaimed, uint refunded, uint numEntriesSettled)
    {


        systemStatus().requireExchangeActive();

        systemStatus().requireSynthActive(currencyKey);

        return _internalSettle(from, currencyKey);
    }


    function remitFee(IExchangeRates _exRates, ISynthetix _synthetix, uint fee, bytes32 currencyKey) internal {

        uint usdFeeAmount = _exRates.effectiveValue(currencyKey, fee, sUSD);
        _synthetix.synths(sUSD).issue(feePool().FEE_ADDRESS(), usdFeeAmount);
        feePool().recordFeePaid(usdFeeAmount);
    }

    function _internalSettle(address from, bytes32 currencyKey)
        internal
        returns (uint reclaimed, uint refunded, uint numEntriesSettled)
    {

        require(maxSecsLeftInWaitingPeriod(from, currencyKey) == 0, "Cannot settle during waiting period");

        (uint reclaimAmount, uint rebateAmount, uint entries) = settlementOwing(from, currencyKey);

        if (reclaimAmount > rebateAmount) {
            reclaimed = reclaimAmount.sub(rebateAmount);
            reclaim(from, currencyKey, reclaimed);
        } else if (rebateAmount > reclaimAmount) {
            refunded = rebateAmount.sub(reclaimAmount);
            refund(from, currencyKey, refunded);
        }

        numEntriesSettled = entries;

        exchangeState().removeEntries(from, currencyKey);
    }

    function reclaim(address from, bytes32 currencyKey, uint amount) internal {

        synthetix().synths(currencyKey).burn(from, amount);
        synthetix().emitExchangeReclaim(from, currencyKey, amount);
    }

    function refund(address from, bytes32 currencyKey, uint amount) internal {

        synthetix().synths(currencyKey).issue(from, amount);
        synthetix().emitExchangeRebate(from, currencyKey, amount);
    }

    function secsLeftInWaitingPeriodForExchange(uint timestamp) internal view returns (uint) {

        if (timestamp == 0 || now >= timestamp.add(waitingPeriodSecs)) {
            return 0;
        }

        return timestamp.add(waitingPeriodSecs).sub(now);
    }

    function calculateExchangeAmountMinusFees(
        bytes32 sourceCurrencyKey,
        bytes32 destinationCurrencyKey,
        uint destinationAmount
    ) internal view returns (uint amountReceived, uint fee) {

        amountReceived = destinationAmount;

        uint exchangeFeeRate = feeRateForExchange(sourceCurrencyKey, destinationCurrencyKey);

        amountReceived = destinationAmount.multiplyDecimal(SafeDecimalMath.unit().sub(exchangeFeeRate));

        fee = destinationAmount.sub(amountReceived);
    }

    function appendExchange(address account, bytes32 src, uint amount, bytes32 dest, uint amountReceived) internal {

        IExchangeRates exRates = exchangeRates();
        uint roundIdForSrc = exRates.getCurrentRoundId(src);
        uint roundIdForDest = exRates.getCurrentRoundId(dest);
        uint exchangeFeeRate = feePool().exchangeFeeRate();
        exchangeState().appendExchangeEntry(
            account,
            src,
            amount,
            dest,
            amountReceived,
            exchangeFeeRate,
            now,
            roundIdForSrc,
            roundIdForDest
        );
    }

    function getRoundIdsAtPeriodEnd(address account, bytes32 currencyKey, uint index)
        internal
        view
        returns (uint srcRoundIdAtPeriodEnd, uint destRoundIdAtPeriodEnd)
    {

        (bytes32 src, , bytes32 dest, , , uint timestamp, uint roundIdForSrc, uint roundIdForDest) = exchangeState()
            .getEntryAt(account, currencyKey, index);

        IExchangeRates exRates = exchangeRates();
        srcRoundIdAtPeriodEnd = exRates.getLastRoundIdBeforeElapsedSecs(src, roundIdForSrc, timestamp, waitingPeriodSecs);
        destRoundIdAtPeriodEnd = exRates.getLastRoundIdBeforeElapsedSecs(dest, roundIdForDest, timestamp, waitingPeriodSecs);
    }


    modifier onlySynthetixorSynth() {

        ISynthetix _synthetix = synthetix();
        require(
            msg.sender == address(_synthetix) || _synthetix.synthsByAddress(msg.sender) != bytes32(0),
            "Exchanger: Only synthetix or a synth contract can perform this action"
        );
        _;
    }
}