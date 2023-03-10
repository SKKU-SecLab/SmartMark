


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

    uint public constant UNIT = 10 ** uint(decimals);

    uint public constant PRECISE_UNIT = 10 ** uint(highPrecisionDecimals);
    uint private constant UNIT_TO_HIGH_PRECISION_CONVERSION_FACTOR = 10 ** uint(highPrecisionDecimals - decimals);

    function unit()
        external
        pure
        returns (uint)
    {

        return UNIT;
    }

    function preciseUnit()
        external
        pure 
        returns (uint)
    {

        return PRECISE_UNIT;
    }

    function multiplyDecimal(uint x, uint y)
        internal
        pure
        returns (uint)
    {

        return x.mul(y) / UNIT;
    }

    function _multiplyDecimalRound(uint x, uint y, uint precisionUnit)
        private
        pure
        returns (uint)
    {

        uint quotientTimesTen = x.mul(y) / (precisionUnit / 10);

        if (quotientTimesTen % 10 >= 5) {
            quotientTimesTen += 10;
        }

        return quotientTimesTen / 10;
    }

    function multiplyDecimalRoundPrecise(uint x, uint y)
        internal
        pure
        returns (uint)
    {

        return _multiplyDecimalRound(x, y, PRECISE_UNIT);
    }

    function multiplyDecimalRound(uint x, uint y)
        internal
        pure
        returns (uint)
    {

        return _multiplyDecimalRound(x, y, UNIT);
    }

    function divideDecimal(uint x, uint y)
        internal
        pure
        returns (uint)
    {

        return x.mul(UNIT).div(y);
    }

    function _divideDecimalRound(uint x, uint y, uint precisionUnit)
        private
        pure
        returns (uint)
    {

        uint resultTimesTen = x.mul(precisionUnit * 10).div(y);

        if (resultTimesTen % 10 >= 5) {
            resultTimesTen += 10;
        }

        return resultTimesTen / 10;
    }

    function divideDecimalRound(uint x, uint y)
        internal
        pure
        returns (uint)
    {

        return _divideDecimalRound(x, y, UNIT);
    }

    function divideDecimalRoundPrecise(uint x, uint y)
        internal
        pure
        returns (uint)
    {

        return _divideDecimalRound(x, y, PRECISE_UNIT);
    }

    function decimalToPreciseDecimal(uint i)
        internal
        pure
        returns (uint)
    {

        return i.mul(UNIT_TO_HIGH_PRECISION_CONVERSION_FACTOR);
    }

    function preciseDecimalToDecimal(uint i)
        internal
        pure
        returns (uint)
    {

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

    constructor(address _owner)
        public
    {
        require(_owner != address(0), "Owner address cannot be 0");
        owner = _owner;
        emit OwnerChanged(address(0), _owner);
    }

    function nominateNewOwner(address _owner)
        external
        onlyOwner
    {

        nominatedOwner = _owner;
        emit OwnerNominated(_owner);
    }

    function acceptOwnership()
        external
    {

        require(msg.sender == nominatedOwner, "You must be nominated before you can accept ownership");
        emit OwnerChanged(owner, nominatedOwner);
        owner = nominatedOwner;
        nominatedOwner = address(0);
    }

    modifier onlyOwner
    {

        require(msg.sender == owner, "Only the contract owner may perform this action");
        _;
    }

    event OwnerNominated(address newOwner);
    event OwnerChanged(address oldOwner, address newOwner);
}


library Math {


    using SafeMath for uint;
    using SafeDecimalMath for uint;

    function powDecimal(uint x, uint n)
        internal
        pure
        returns (uint)
    {


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

    function transfer(address to, uint value) public returns (bool);

    function triggerTokenFallbackIfNeeded(address sender, address recipient, uint amount) external;

    function transferFrom(address from, address to, uint value) public returns (bool);

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

    function recordFeePaid(uint xdrAmount) external;

    function appendAccountIssuanceRecord(address account, uint lockedAmount, uint debtEntryIndex) external;

    function setRewardsToDistribute(uint amount) external;

}


interface IExchangeRates {

    function effectiveValue(bytes32 sourceCurrencyKey, uint sourceAmount, bytes32 destinationCurrencyKey) external view returns (uint);


    function rateForCurrency(bytes32 currencyKey) external view returns (uint);

    function ratesForCurrencies(bytes32[] currencyKeys) external view returns (uint[] memory);


    function rateIsStale(bytes32 currencyKey) external view returns (bool);

    function anyRateIsStale(bytes32[] currencyKeys) external view returns (bool);

}




contract SelfDestructible is Owned {

    
    uint public initiationTime;
    bool public selfDestructInitiated;
    address public selfDestructBeneficiary;
    uint public constant SELFDESTRUCT_DELAY = 4 weeks;

    constructor(address _owner)
        Owned(_owner)
        public
    {
        require(_owner != address(0), "Owner must not be zero");
        selfDestructBeneficiary = _owner;
        emit SelfDestructBeneficiaryUpdated(_owner);
    }

    function setSelfDestructBeneficiary(address _beneficiary)
        external
        onlyOwner
    {

        require(_beneficiary != address(0), "Beneficiary must not be zero");
        selfDestructBeneficiary = _beneficiary;
        emit SelfDestructBeneficiaryUpdated(_beneficiary);
    }

    function initiateSelfDestruct()
        external
        onlyOwner
    {

        initiationTime = now;
        selfDestructInitiated = true;
        emit SelfDestructInitiated(SELFDESTRUCT_DELAY);
    }

    function terminateSelfDestruct()
        external
        onlyOwner
    {

        initiationTime = 0;
        selfDestructInitiated = false;
        emit SelfDestructTerminated();
    }

    function selfDestruct()
        external
        onlyOwner
    {

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


    constructor(address _owner, address _associatedContract)
        Owned(_owner)
        public
    {
        associatedContract = _associatedContract;
        emit AssociatedContractUpdated(_associatedContract);
    }


    function setAssociatedContract(address _associatedContract)
        external
        onlyOwner
    {

        associatedContract = _associatedContract;
        emit AssociatedContractUpdated(_associatedContract);
    }


    modifier onlyAssociatedContract
    {

        require(msg.sender == associatedContract, "Only the associated contract can perform this action");
        _;
    }


    event AssociatedContractUpdated(address associatedContract);
}




contract TokenState is State {


    mapping(address => uint) public balanceOf;
    mapping(address => mapping(address => uint)) public allowance;

    constructor(address _owner, address _associatedContract)
        State(_owner, _associatedContract)
        public
    {}


    function setAllowance(address tokenOwner, address spender, uint value)
        external
        onlyAssociatedContract
    {

        allowance[tokenOwner][spender] = value;
    }

    function setBalanceOf(address account, uint value)
        external
        onlyAssociatedContract
    {

        balanceOf[account] = value;
    }
}




contract Proxy is Owned {


    Proxyable public target;
    bool public useDELEGATECALL;

    constructor(address _owner)
        Owned(_owner)
        public
    {}

    function setTarget(Proxyable _target)
        external
        onlyOwner
    {

        target = _target;
        emit TargetUpdated(_target);
    }

    function setUseDELEGATECALL(bool value) 
        external
        onlyOwner
    {

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

    function()
        external
        payable
    {
        if (useDELEGATECALL) {
            assembly {
                let free_ptr := mload(0x40)
                calldatacopy(free_ptr, 0, calldatasize)

                let result := delegatecall(gas, sload(target_slot), free_ptr, calldatasize, 0, 0)
                returndatacopy(free_ptr, 0, returndatasize)

                if iszero(result) { revert(free_ptr, returndatasize) }
                return(free_ptr, returndatasize)
            }
        } else {
            target.setMessageSender(msg.sender);
            assembly {
                let free_ptr := mload(0x40)
                calldatacopy(free_ptr, 0, calldatasize)

                let result := call(gas, sload(target_slot), callvalue, free_ptr, calldatasize, 0, 0)
                returndatacopy(free_ptr, 0, returndatasize)

                if iszero(result) { revert(free_ptr, returndatasize) }
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

    constructor(address _proxy, address _owner)
        Owned(_owner)
        public
    {
        proxy = Proxy(_proxy);
        emit ProxyUpdated(_proxy);
    }

    function setProxy(address _proxy)
        external
        onlyOwner
    {

        proxy = Proxy(_proxy);
        emit ProxyUpdated(_proxy);
    }

    function setIntegrationProxy(address _integrationProxy)
        external
        onlyOwner
    {

        integrationProxy = Proxy(_integrationProxy);
    }

    function setMessageSender(address sender)
        external
        onlyProxy
    {

        messageSender = sender;
    }

    modifier onlyProxy {

        require(Proxy(msg.sender) == proxy || Proxy(msg.sender) == integrationProxy, "Only the proxy can call");
        _;
    }

    modifier optionalProxy
    {

        if (Proxy(msg.sender) != proxy && Proxy(msg.sender) != integrationProxy && messageSender != msg.sender) {
            messageSender = msg.sender;
        }
        _;
    }

    modifier optionalProxy_onlyOwner
    {

        if (Proxy(msg.sender) != proxy && Proxy(msg.sender) != integrationProxy && messageSender != msg.sender) {
            messageSender = msg.sender;
        }
        require(messageSender == owner, "Owner only function");
        _;
    }

    event ProxyUpdated(address proxyAddress);
}


contract ReentrancyGuard {


  uint256 private _guardCounter;

  constructor() internal {
    _guardCounter = 1;
  }

  modifier nonReentrant() {

    _guardCounter += 1;
    uint256 localCounter = _guardCounter;
    _;
    require(localCounter == _guardCounter);
  }

}




contract TokenFallbackCaller is ReentrancyGuard {

    uint constant MAX_GAS_SUB_CALL = 100000;
    function callTokenFallbackIfNeeded(address sender, address recipient, uint amount, bytes data)
        internal
        nonReentrant
    {


        uint length;

        assembly {
            length := extcodesize(recipient)
        }

        if (length > 0) {
            uint gasLimit = gasleft() < MAX_GAS_SUB_CALL ? gasleft() : MAX_GAS_SUB_CALL;
            recipient.call.gas(gasLimit)(abi.encodeWithSignature("tokenFallback(address,uint256,bytes)", sender, amount, data));

        }
    }
}




contract ExternStateToken is SelfDestructible, Proxyable, TokenFallbackCaller {


    using SafeMath for uint;
    using SafeDecimalMath for uint;


    TokenState public tokenState;

    string public name;
    string public symbol;
    uint public totalSupply;
    uint8 public decimals;

    constructor(address _proxy, TokenState _tokenState,
                string _name, string _symbol, uint _totalSupply,
                uint8 _decimals, address _owner)
        SelfDestructible(_owner)
        Proxyable(_proxy, _owner)
        public
    {
        tokenState = _tokenState;

        name = _name;
        symbol = _symbol;
        totalSupply = _totalSupply;
        decimals = _decimals;
    }


    function allowance(address owner, address spender)
        public
        view
        returns (uint)
    {

        return tokenState.allowance(owner, spender);
    }

    function balanceOf(address account)
        public
        view
        returns (uint)
    {

        return tokenState.balanceOf(account);
    }


    function setTokenState(TokenState _tokenState)
        external
        optionalProxy_onlyOwner
    {

        tokenState = _tokenState;
        emitTokenStateUpdated(_tokenState);
    }

    function _internalTransfer(address from, address to, uint value, bytes data)
        internal
        returns (bool)
    {

        require(to != address(0), "Cannot transfer to the 0 address");
        require(to != address(this), "Cannot transfer to the contract");
        require(to != address(proxy), "Cannot transfer to the proxy");

        tokenState.setBalanceOf(from, tokenState.balanceOf(from).sub(value));
        tokenState.setBalanceOf(to, tokenState.balanceOf(to).add(value));

        emitTransfer(from, to, value);

        callTokenFallbackIfNeeded(from, to, value, data);
        
        return true;
    }

    function _transfer_byProxy(address from, address to, uint value, bytes data)
        internal
        returns (bool)
    {

        return _internalTransfer(from, to, value, data);
    }

    function _transferFrom_byProxy(address sender, address from, address to, uint value, bytes data)
        internal
        returns (bool)
    {

        tokenState.setAllowance(from, sender, tokenState.allowance(from, sender).sub(value));
        return _internalTransfer(from, to, value, data);
    }

    function approve(address spender, uint value)
        public
        optionalProxy
        returns (bool)
    {

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




contract Synth is ExternStateToken {



    address public feePoolProxy;
    address public synthetixProxy;

    bytes32 public currencyKey;

    uint8 constant DECIMALS = 18;


    constructor(address _proxy, TokenState _tokenState, address _synthetixProxy, address _feePoolProxy,
        string _tokenName, string _tokenSymbol, address _owner, bytes32 _currencyKey, uint _totalSupply
    )
        ExternStateToken(_proxy, _tokenState, _tokenName, _tokenSymbol, _totalSupply, DECIMALS, _owner)
        public
    {
        require(_proxy != address(0), "_proxy cannot be 0");
        require(_synthetixProxy != address(0), "_synthetixProxy cannot be 0");
        require(_feePoolProxy != address(0), "_feePoolProxy cannot be 0");
        require(_owner != 0, "_owner cannot be 0");
        require(ISynthetix(_synthetixProxy).synths(_currencyKey) == Synth(0), "Currency key is already in use");

        feePoolProxy = _feePoolProxy;
        synthetixProxy = _synthetixProxy;
        currencyKey = _currencyKey;
    }


    function setSynthetixProxy(ISynthetix _synthetixProxy)
        external
        optionalProxy_onlyOwner
    {

        synthetixProxy = _synthetixProxy;
        emitSynthetixUpdated(_synthetixProxy);
    }

    function setFeePoolProxy(address _feePoolProxy)
        external
        optionalProxy_onlyOwner
    {

        feePoolProxy = _feePoolProxy;
        emitFeePoolUpdated(_feePoolProxy);
    }


    function transfer(address to, uint value)
        public
        optionalProxy
        returns (bool)
    {

        bytes memory empty;
        return super._internalTransfer(messageSender, to, value, empty);
    }

    function transfer(address to, uint value, bytes data)
        public
        optionalProxy
        returns (bool)
    {

        return super._internalTransfer(messageSender, to, value, data);
    }

    function transferFrom(address from, address to, uint value)
        public
        optionalProxy
        returns (bool)
    {

        require(from != 0xfeefeefeefeefeefeefeefeefeefeefeefeefeef, "The fee address is not allowed");
        if (tokenState.allowance(from, messageSender) != uint(-1)) {
            tokenState.setAllowance(from, messageSender, tokenState.allowance(from, messageSender).sub(value));
        }

        bytes memory empty;
        return super._internalTransfer(from, to, value, empty);
    }

    function transferFrom(address from, address to, uint value, bytes data)
        public
        optionalProxy
        returns (bool)
    {

        require(from != 0xfeefeefeefeefeefeefeefeefeefeefeefeefeef, "The fee address is not allowed");

        if (tokenState.allowance(from, messageSender) != uint(-1)) {
            tokenState.setAllowance(from, messageSender, tokenState.allowance(from, messageSender).sub(value));
        }

        return super._internalTransfer(from, to, value, data);
    }

    function issue(address account, uint amount)
        external
        onlySynthetixOrFeePool
    {

        tokenState.setBalanceOf(account, tokenState.balanceOf(account).add(amount));
        totalSupply = totalSupply.add(amount);
        emitTransfer(address(0), account, amount);
        emitIssued(account, amount);
    }

    function burn(address account, uint amount)
        external
        onlySynthetixOrFeePool
    {

        tokenState.setBalanceOf(account, tokenState.balanceOf(account).sub(amount));
        totalSupply = totalSupply.sub(amount);
        emitTransfer(account, address(0), amount);
        emitBurned(account, amount);
    }

    function setTotalSupply(uint amount)
        external
        optionalProxy_onlyOwner
    {

        totalSupply = amount;
    }

    function triggerTokenFallbackIfNeeded(address sender, address recipient, uint amount)
        external
        onlySynthetixOrFeePool
    {

        bytes memory empty;
        callTokenFallbackIfNeeded(sender, recipient, amount, empty);
    }


    modifier onlySynthetixOrFeePool() {

        bool isSynthetix = msg.sender == address(Proxy(synthetixProxy).target());
        bool isFeePool = msg.sender == address(Proxy(feePoolProxy).target());

        require(isSynthetix || isFeePool, "Only Synthetix, FeePool allowed");
        _;
    }


    event SynthetixUpdated(address newSynthetix);
    bytes32 constant SYNTHETIXUPDATED_SIG = keccak256("SynthetixUpdated(address)");
    function emitSynthetixUpdated(address newSynthetix) internal {

        proxy._emit(abi.encode(newSynthetix), 1, SYNTHETIXUPDATED_SIG, 0, 0, 0);
    }

    event FeePoolUpdated(address newFeePool);
    bytes32 constant FEEPOOLUPDATED_SIG = keccak256("FeePoolUpdated(address)");
    function emitFeePoolUpdated(address newFeePool) internal {

        proxy._emit(abi.encode(newFeePool), 1, FEEPOOLUPDATED_SIG, 0, 0, 0);
    }

    event Issued(address indexed account, uint value);
    bytes32 constant ISSUED_SIG = keccak256("Issued(address,uint256)");
    function emitIssued(address account, uint value) internal {

        proxy._emit(abi.encode(value), 2, ISSUED_SIG, bytes32(account), 0, 0);
    }

    event Burned(address indexed account, uint value);
    bytes32 constant BURNED_SIG = keccak256("Burned(address,uint256)");
    function emitBurned(address account, uint value) internal {

        proxy._emit(abi.encode(value), 2, BURNED_SIG, bytes32(account), 0, 0);
    }
}




contract ISynthetix {



    IFeePool public feePool;
    ISynthetixEscrow public escrow;
    ISynthetixEscrow public rewardEscrow;
    ISynthetixState public synthetixState;
    IExchangeRates public exchangeRates;

    uint public totalSupply;
        
    mapping(bytes32 => Synth) public synths;


    function balanceOf(address account) public view returns (uint);

    function transfer(address to, uint value) public returns (bool);

    function effectiveValue(bytes32 sourceCurrencyKey, uint sourceAmount, bytes32 destinationCurrencyKey) public view returns (uint);


    function synthInitiatedExchange(
        address from,
        bytes32 sourceCurrencyKey,
        uint sourceAmount,
        bytes32 destinationCurrencyKey,
        address destinationAddress) external returns (bool);

    function exchange(
        bytes32 sourceCurrencyKey,
        uint sourceAmount,
        bytes32 destinationCurrencyKey) external returns (bool);

    function collateralisationRatio(address issuer) public view returns (uint);

    function totalIssuedSynths(bytes32 currencyKey)
        public
        view
        returns (uint);

    function getSynth(bytes32 currencyKey) public view returns (ISynth);

    function debtBalanceOf(address issuer, bytes32 currencyKey) public view returns (uint);

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
    
    constructor(
        address _owner,
        uint _lastMintEvent,
        uint _currentWeek)
        Owned(_owner)
        public
    {
        lastMintEvent = _lastMintEvent;
        weekCounter = _currentWeek;
    }

    
    function mintableSupply()
        external
        view
        returns (uint)
    {

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
            }
            else if (currentWeek <= SUPPLY_DECAY_END) {
                
                uint decayCount = currentWeek.sub(SUPPLY_DECAY_START -1);
                
                totalAmount = totalAmount.add(tokenDecaySupplyForWeek(decayCount));
                remainingWeeksToMint--;
            } 
            else {
                uint totalSupply = ISynthetix(synthetixProxy).totalSupply();
                uint currentTotalSupply = totalSupply.add(totalAmount);

                totalAmount = totalAmount.add(terminalInflationSupply(currentTotalSupply, remainingWeeksToMint));
                remainingWeeksToMint = 0;
            }
        }
        
        return totalAmount;
    }

    function tokenDecaySupplyForWeek(uint counter)
        public 
        pure
        returns (uint)
    {   

        uint effectiveDecay = (SafeDecimalMath.unit().sub(DECAY_RATE)).powDecimal(counter);
        uint supplyForWeek = INITIAL_WEEKLY_SUPPLY.multiplyDecimal(effectiveDecay);

        return supplyForWeek;
    }    
    
    function terminalInflationSupply(uint totalSupply, uint numOfWeeks)
        public
        pure
        returns (uint)
    {   

        uint effectiveCompoundRate = SafeDecimalMath.unit().add(TERMINAL_SUPPLY_RATE_ANNUAL.div(52)).powDecimal(numOfWeeks);

        return totalSupply.multiplyDecimal(effectiveCompoundRate.sub(SafeDecimalMath.unit()));
    }

    function weeksSinceLastIssuance()
        public
        view
        returns (uint)
    {

        uint timeDiff = lastMintEvent > 0 ? now.sub(lastMintEvent) : now.sub(INFLATION_START_DATE);
        return timeDiff.div(MINT_PERIOD_DURATION);
    }

    function isMintable()
        public
        view
        returns (bool)
    {

        if (now - lastMintEvent > MINT_PERIOD_DURATION)
        {
            return true;
        }
        return false;
    }


    function recordMintEvent(uint supplyMinted)
        external
        onlySynthetix
        returns (bool)
    {

        uint numberOfWeeksIssued = weeksSinceLastIssuance();

        weekCounter = weekCounter.add(numberOfWeeksIssued);

        lastMintEvent = INFLATION_START_DATE.add(weekCounter.mul(MINT_PERIOD_DURATION)).add(MINT_BUFFER);

        emit SupplyMinted(supplyMinted, numberOfWeeksIssued, lastMintEvent, now);
        return true;
    }

    function setMinterReward(uint amount)
        external
        onlyOwner
    {

        require(amount <= MAX_MINTER_REWARD, "Reward cannot exceed max minter reward");
        minterReward = amount;
        emit MinterRewardUpdated(minterReward);
    }


    function setSynthetixProxy(ISynthetix _synthetixProxy)
        external
        onlyOwner
    {

        require(_synthetixProxy != address(0), "Address cannot be 0");
        synthetixProxy = _synthetixProxy;
        emit SynthetixProxyUpdated(synthetixProxy);
    }


    modifier onlySynthetix() {

        require(msg.sender == address(Proxy(synthetixProxy).target()), "Only the synthetix contract can perform this action");
        _;
    }

    event SupplyMinted(uint supplyMinted, uint numberOfWeeksIssued, uint lastMintEvent, uint timestamp);

    event MinterRewardUpdated(uint newRewardAmount);

    event SynthetixProxyUpdated(address newAddress);
}