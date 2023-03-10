
    


pragma solidity ^0.4.24;

library SafeMath {


  function mul(uint256 a, uint256 b) internal pure returns (uint256) {

    if (a == 0) {
      return 0;
    }

    uint256 c = a * b;
    require(c / a == b, "SafeMath.mul Error");

    return c;
  }

  function div(uint256 a, uint256 b) internal pure returns (uint256) {

    require(b > 0, "SafeMath.div Error"); // Solidity only automatically asserts when dividing by 0
    uint256 c = a / b;

    return c;
  }

  function sub(uint256 a, uint256 b) internal pure returns (uint256) {

    require(b <= a, "SafeMath.sub Error");
    uint256 c = a - b;

    return c;
  }

  function add(uint256 a, uint256 b) internal pure returns (uint256) {

    uint256 c = a + b;
    require(c >= a, "SafeMath.add Error");

    return c;
  }

  function mod(uint256 a, uint256 b) internal pure returns (uint256) {

    require(b != 0, "SafeMath.mod Error");
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

    constructor(address _owner, address _resolver) public Owned(_owner) {
        resolver = AddressResolver(_resolver);
    }


    function setResolver(AddressResolver _resolver) public onlyOwner {

        resolver = _resolver;
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


interface IExchanger {

    function maxSecsLeftInWaitingPeriod(address account, bytes32 currencyKey) external view returns (uint);


    function feeRateForExchange(bytes32 sourceCurrencyKey, bytes32 destinationCurrencyKey) external view returns (uint);


    function settlementOwing(address account, bytes32 currencyKey)
        external
        view
        returns (uint reclaimAmount, uint rebateAmount);


    function settle(address from, bytes32 currencyKey) external returns (uint reclaimed, uint refunded);


    function exchange(
        address from,
        bytes32 sourceCurrencyKey,
        uint sourceAmount,
        bytes32 destinationCurrencyKey,
        address destinationAddress
    ) external returns (uint amountReceived);


    function calculateAmountAfterSettlement(address from, bytes32 currencyKey, uint amount, uint refunded)
        external
        view
        returns (uint amountAfterSettlement);

}


interface IIssuer {

    function issueSynths(address from, uint amount) external;


    function issueMaxSynths(address from) external;


    function burnSynths(address from, uint amount) external;

}


contract Synth is ExternStateToken, MixinResolver {


    bytes32 public currencyKey;

    uint8 public constant DECIMALS = 18;

    address public constant FEE_ADDRESS = 0xfeEFEEfeefEeFeefEEFEEfEeFeefEEFeeFEEFEeF;


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
        MixinResolver(_owner, _resolver)
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

        exchanger().settle(messageSender, currencyKey);

        uint balanceAfter = tokenState.balanceOf(messageSender);

        value = value > balanceAfter ? balanceAfter : value;

        return super._internalTransfer(messageSender, to, value);
    }

    function transferFrom(address from, address to, uint value) public optionalProxy returns (bool) {

        _ensureCanTransfer(from, value);

        return _internalTransferFrom(from, to, value);
    }

    function transferFromAndSettle(address from, address to, uint value) public optionalProxy returns (bool) {

        exchanger().settle(from, currencyKey);

        uint balanceAfter = tokenState.balanceOf(from);

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

    function synthetix() internal view returns (ISynthetix) {

        return ISynthetix(resolver.requireAndGetAddress("Synthetix", "Missing Synthetix address"));
    }

    function feePool() internal view returns (IFeePool) {

        return IFeePool(resolver.requireAndGetAddress("FeePool", "Missing FeePool address"));
    }

    function exchanger() internal view returns (IExchanger) {

        return IExchanger(resolver.requireAndGetAddress("Exchanger", "Missing Exchanger address"));
    }

    function issuer() internal view returns (IIssuer) {

        return IIssuer(resolver.requireAndGetAddress("Issuer", "Missing Issuer address"));
    }

    function _ensureCanTransfer(address from, uint value) internal view {

        require(exchanger().maxSecsLeftInWaitingPeriod(from, currencyKey) == 0, "Cannot transfer during waiting period");
        require(transferableSynths(from) >= value, "Transfer requires settle");
    }

    function transferableSynths(address account) public view returns (uint) {

        (uint reclaimAmount, ) = exchanger().settlementOwing(account, currencyKey);


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


    function settle(bytes32 currencyKey) external returns (uint reclaimed, uint refunded);


    function collateralisationRatio(address issuer) public view returns (uint);


    function totalIssuedSynths(bytes32 currencyKey) public view returns (uint);


    function totalIssuedSynthsExcludeEtherCollateral(bytes32 currencyKey) public view returns (uint);


    function debtBalanceOf(address issuer, bytes32 currencyKey) public view returns (uint);


    function remainingIssuableSynths(address issuer) public view returns (uint, uint);


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


contract Issuer is MixinResolver {

    using SafeMath for uint;
    using SafeDecimalMath for uint;

    bytes32 private constant sUSD = "sUSD";

    constructor(address _owner, address _resolver) public MixinResolver(_owner, _resolver) {}

    function synthetix() internal view returns (ISynthetix) {

        return ISynthetix(resolver.requireAndGetAddress("Synthetix", "Missing Synthetix address"));
    }

    function exchanger() internal view returns (IExchanger) {

        return IExchanger(resolver.requireAndGetAddress("Exchanger", "Missing Exchanger address"));
    }

    function synthetixState() internal view returns (ISynthetixState) {

        return ISynthetixState(resolver.requireAndGetAddress("SynthetixState", "Missing SynthetixState address"));
    }

    function feePool() internal view returns (IFeePool) {

        return IFeePool(resolver.requireAndGetAddress("FeePool", "Missing FeePool address"));
    }



    function issueSynths(address from, uint amount)
        external
        onlySynthetix
    {

        (uint maxIssuable, uint existingDebt) = synthetix().remainingIssuableSynths(from);
        require(amount <= maxIssuable, "Amount too large");

        _addToDebtRegister(from, amount, existingDebt);

        synthetix().synths(sUSD).issue(from, amount);

        _appendAccountIssuanceRecord(from);
    }

    function issueMaxSynths(address from) external onlySynthetix {

        (uint maxIssuable, uint existingDebt) = synthetix().remainingIssuableSynths(from);

        _addToDebtRegister(from, maxIssuable, existingDebt);

        synthetix().synths(sUSD).issue(from, maxIssuable);

        _appendAccountIssuanceRecord(from);
    }

    function burnSynths(address from, uint amount)
        external
        onlySynthetix
    {

        ISynthetix _synthetix = synthetix();
        IExchanger _exchanger = exchanger();

        (, uint refunded) = _exchanger.settle(from, sUSD);

        uint existingDebt = _synthetix.debtBalanceOf(from, sUSD);

        require(existingDebt > 0, "No debt to forgive");

        uint debtToRemoveAfterSettlement = _exchanger.calculateAmountAfterSettlement(from, sUSD, amount, refunded);

        uint amountToRemove = existingDebt < debtToRemoveAfterSettlement ? existingDebt : debtToRemoveAfterSettlement;

        _removeFromDebtRegister(from, amountToRemove, existingDebt);

        uint amountToBurn = amountToRemove;

        _synthetix.synths(sUSD).burn(from, amountToBurn);

        _appendAccountIssuanceRecord(from);
    }


    function _appendAccountIssuanceRecord(address from) internal {

        uint initialDebtOwnership;
        uint debtEntryIndex;
        (initialDebtOwnership, debtEntryIndex) = synthetixState().issuanceData(from);

        feePool().appendAccountIssuanceRecord(from, initialDebtOwnership, debtEntryIndex);
    }

    function _addToDebtRegister(address from, uint amount, uint existingDebt) internal {

        ISynthetixState state = synthetixState();

        uint totalDebtIssued = synthetix().totalIssuedSynthsExcludeEtherCollateral(sUSD);

        uint newTotalDebtIssued = amount.add(totalDebtIssued);

        uint debtPercentage = amount.divideDecimalRoundPrecise(newTotalDebtIssued);

        uint delta = SafeDecimalMath.preciseUnit().sub(debtPercentage);

        if (existingDebt > 0) {
            debtPercentage = amount.add(existingDebt).divideDecimalRoundPrecise(newTotalDebtIssued);
        }

        if (existingDebt == 0) {
            state.incrementTotalIssuerCount();
        }

        state.setCurrentIssuanceData(from, debtPercentage);

        if (state.debtLedgerLength() > 0) {
            state.appendDebtLedgerValue(state.lastDebtLedgerEntry().multiplyDecimalRoundPrecise(delta));
        } else {
            state.appendDebtLedgerValue(SafeDecimalMath.preciseUnit());
        }
    }

    function _removeFromDebtRegister(address from, uint amount, uint existingDebt) internal {

        ISynthetixState state = synthetixState();

        uint debtToRemove = amount;

        uint totalDebtIssued = synthetix().totalIssuedSynthsExcludeEtherCollateral(sUSD);

        uint newTotalDebtIssued = totalDebtIssued.sub(debtToRemove);

        uint delta = 0;

        if (newTotalDebtIssued > 0) {
            uint debtPercentage = debtToRemove.divideDecimalRoundPrecise(newTotalDebtIssued);

            delta = SafeDecimalMath.preciseUnit().add(debtPercentage);
        }

        if (debtToRemove == existingDebt) {
            state.setCurrentIssuanceData(from, 0);
            state.decrementTotalIssuerCount();
        } else {
            uint newDebt = existingDebt.sub(debtToRemove);
            uint newDebtPercentage = newDebt.divideDecimalRoundPrecise(newTotalDebtIssued);

            state.setCurrentIssuanceData(from, newDebtPercentage);
        }

        state.appendDebtLedgerValue(state.lastDebtLedgerEntry().multiplyDecimalRoundPrecise(delta));
    }


    modifier onlySynthetix() {

        require(msg.sender == address(synthetix()), "Issuer: Only the synthetix contract can perform this action");
        _;
    }
}