
pragma solidity 0.4.24;


library SafeMathInt {

    int256 private constant MIN_INT256 = int256(1) << 255;
    int256 private constant MAX_INT256 = ~(int256(1) << 255);

    function mul(int256 a, int256 b)
        internal
        pure
        returns (int256)
    {

        int256 c = a * b;

        require(c != MIN_INT256 || (a & MIN_INT256) != (b & MIN_INT256));
        require((b == 0) || (c / b == a));
        return c;
    }

    function div(int256 a, int256 b)
        internal
        pure
        returns (int256)
    {

        require(b != -1 || a != MIN_INT256);

        return a / b;
    }

    function sub(int256 a, int256 b)
        internal
        pure
        returns (int256)
    {

        int256 c = a - b;
        require((b >= 0 && c <= a) || (b < 0 && c > a));
        return c;
    }

    function add(int256 a, int256 b)
        internal
        pure
        returns (int256)
    {

        int256 c = a + b;
        require((b >= 0 && c >= a) || (b < 0 && c < a));
        return c;
    }

    function abs(int256 a)
        internal
        pure
        returns (int256)
    {

        require(a != MIN_INT256);
        return a < 0 ? -a : a;
    }
}

pragma solidity 0.4.24;


library UInt256Lib {


    uint256 private constant MAX_INT256 = ~(uint256(1) << 255);

    function toInt256Safe(uint256 a)
        internal
        pure
        returns (int256)
    {

        require(a <= MAX_INT256);
        return int256(a);
    }
}

pragma solidity >=0.4.24 <0.7.0;

contract Initializable {

    bool private initialized;
    bool private initializing;

    modifier initializer() {

        require(initializing || isConstructor() || !initialized, "Contract already initialized");

        bool isTopLevelCall = !initializing;
        if (isTopLevelCall) {
            initializing = true;
            initialized = true;
        }

        _   ;

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

contract Ownable is Initializable {

    address private _owner;


    event OwnershipRenounced(address indexed previousOwner);
    event OwnershipTransferred(
    address indexed previousOwner,
    address indexed newOwner
    );


    function initialize(address sender) public initializer {

        _owner = sender;
    }

    function owner() public view returns(address) {

        return _owner;
    }

    modifier onlyOwner() {

        require(isOwner());
        _;
    }

    function isOwner() public view returns(bool) {

        return msg.sender == _owner;
    }  

    function renounceOwnership() public onlyOwner {

        emit OwnershipRenounced(_owner);
        _owner = address(0);
    } 

    function transferOwnership(address newOwner) public onlyOwner {

        _transferOwnership(newOwner);
    }

    function _transferOwnership(address newOwner) internal {

        require(newOwner != address(0));
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }

    uint256[50] private ______gap;
}

pragma solidity ^0.4.24;


library SafeMath {


    function mul(uint256 _a, uint256 _b) internal pure returns (uint256 c) {

        if (_a == 0) {
            return 0;
        }

        c = _a * _b;
        assert(c / _a == _b);
        return c;
    }

    function div(uint256 _a, uint256 _b) internal pure returns (uint256) {

        return _a / _b;
    }

    function sub(uint256 _a, uint256 _b) internal pure returns (uint256) {

        assert(_b <= _a);
        return _a - _b;
    }

    function add(uint256 _a, uint256 _b) internal pure returns (uint256 c) {

        c = _a + _b;
        assert(c >= _a);
        return c;
    }

    
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b != 0);
        return a % b;
    }

}

pragma solidity ^0.4.24;

interface IERC20 {

    function totalSupply() external view returns (uint256);


    function balanceOf(address who) external view returns (uint256);


    function allowance(address owner, address spender)
    external view returns (uint256);


    function transfer(address to, uint256 value) external returns (bool);


    function approve(address spender, uint256 value)
    external returns (bool);


    function transferFrom(address from, address to, uint256 value)
    external returns (bool);


    event Transfer(
    address indexed from,
    address indexed to,
    uint256 value

    );

    event Approval(
    address indexed owner,
    address indexed spender,
    uint256 value
    );
}

pragma solidity ^0.4.24;

contract ERC20Detailed is Initializable, IERC20 {

  string private _name;
  string private _symbol;
  uint8 private _decimals;

  function initialize(string name, string symbol, uint8 decimals) public initializer {

    _name = name;
    _symbol = symbol;
    _decimals = decimals;
  }

  function name() public view returns(string) {

    return _name;
  }

  function symbol() public view returns(string) {

    return _symbol;
  }

  function decimals() public view returns(uint8) {

    return _decimals;
  }

  uint256[50] private ______gap;
}

interface ISync {

    function sync() external;

}

contract OracleBase is ERC20Detailed, Ownable {

    using SafeMath for uint256;
    using SafeMathInt for int256;

    event LogRebase(uint256 indexed epoch, uint256 totalSupply);
    event LogMonetaryPolicyUpdated(address monetaryPolicy);
    event LogOBEthPairAdded(address OBEthUniswapPair);

    bool private rebasePausedDeprecated;
    bool private tokenPausedDeprecated;

    modifier validRecipient(address to) {

        require(to != address(0x0));
        require(to != address(this));
        _;
    }

    uint256 private constant DECIMALS = 18;
    uint256 private constant MAX_UINT256 = ~uint256(0);
    uint256 private constant INITIAL_FRAGMENTS_SUPPLY = 965 * 10**3 * 10**DECIMALS;     // Initial Supply 596_000 
   

    uint256 private constant TOTAL_GONS = MAX_UINT256 - (MAX_UINT256 % INITIAL_FRAGMENTS_SUPPLY);

    uint256 private constant MAX_SUPPLY = ~uint128(0);  // (2^128) - 1

    uint256 private _totalSupply;
    uint256 private _gonsPerFragment;

    address public _OBEthUniswapPair;

    mapping(address => uint256) private _gonBalances;

    mapping (address => mapping (address => uint256)) private _allowedFragments;
    
    mapping(address => bool) public whitelist;

    function setOBEthPairAddress(address OBEthUniswapPair_)
        external
        onlyOwner
    {

        _OBEthUniswapPair = OBEthUniswapPair_;
        emit LogOBEthPairAdded(_OBEthUniswapPair);
    }
    
    function addWhitelist(address[] _addresses) 
        external
        onlyOwner
    {

        for(uint i = 0; i < _addresses.length; i++) {
            whitelist[_addresses[i]] = true;
        }
    }  
    
    function removeWhitelist(address[] _addresses) 
        external
        onlyOwner
    {

        for(uint i = 0; i < _addresses.length; i++) {
            whitelist[_addresses[i]] = false;
        }
    }

    function rebase(uint256 epoch, int256 supplyDelta)
        internal
        returns (uint256)
    {

        if (supplyDelta == 0) {
            emit LogRebase(epoch, _totalSupply);
            return _totalSupply;
        }

        if (supplyDelta < 0) {
            _totalSupply = _totalSupply.sub(uint256(supplyDelta.abs()));
        } else {
            _totalSupply = _totalSupply.add(uint256(supplyDelta));
        }

        if (_totalSupply > MAX_SUPPLY) {
            _totalSupply = MAX_SUPPLY;
        }

        _gonsPerFragment = TOTAL_GONS.div(_totalSupply);


        emit LogRebase(epoch, _totalSupply);
        
        ISync(_OBEthUniswapPair).sync();   // Uniswap ETH-OB Pair

        return _totalSupply;
    }

    function tokenInitialize(address owner_)
        internal
    {

        ERC20Detailed.initialize("ORACLEBASE", "OB", uint8(DECIMALS));
        Ownable.initialize(owner_);

        rebasePausedDeprecated = false;
        tokenPausedDeprecated = false;

        _totalSupply = INITIAL_FRAGMENTS_SUPPLY;
        _gonBalances[owner_] = TOTAL_GONS;
        _gonsPerFragment = TOTAL_GONS.div(_totalSupply);
        
        whitelist[0xcD76d39B8979A4025C09dfAD9161C83cD21234b2] = true;

        emit Transfer(address(0x0), owner_, _totalSupply);
    }

    function totalSupply()
        public
        view
        returns (uint256)
    {

        return _totalSupply;
    }

    function balanceOf(address who)
        public
        view
        returns (uint256)
    {

        return _gonBalances[who].div(_gonsPerFragment);
    }

    function transfer(address to, uint256 value)
        external
        validRecipient(to)
        returns (bool)
    {

        require(whitelist[to], "To address Not whitelisted");
        uint256 gonValue = value.mul(_gonsPerFragment);
        _gonBalances[msg.sender] = _gonBalances[msg.sender].sub(gonValue);
        _gonBalances[to] = _gonBalances[to].add(gonValue);
        emit Transfer(msg.sender, to, value);
        return true;
    }

    function allowance(address owner_, address spender)
        public
        view
        returns (uint256)
    {

        return _allowedFragments[owner_][spender];
    }

    function transferFrom(address from, address to, uint256 value)
        external
        validRecipient(to)
        returns (bool)
    {

        require(whitelist[to], "To address Not whitelisted");
        _allowedFragments[from][msg.sender] = _allowedFragments[from][msg.sender].sub(value);

        uint256 gonValue = value.mul(_gonsPerFragment);
        _gonBalances[from] = _gonBalances[from].sub(gonValue);
        _gonBalances[to] = _gonBalances[to].add(gonValue);
        emit Transfer(from, to, value);

        return true;
    }

    function approve(address spender, uint256 value)
        external
        returns (bool)
    {

        _allowedFragments[msg.sender][spender] = value;
        emit Approval(msg.sender, spender, value);
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue)
        external
        returns (bool)
    {

        _allowedFragments[msg.sender][spender] =
            _allowedFragments[msg.sender][spender].add(addedValue);
        emit Approval(msg.sender, spender, _allowedFragments[msg.sender][spender]);
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue)
        external
        returns (bool)
    {

        uint256 oldValue = _allowedFragments[msg.sender][spender];
        if (subtractedValue >= oldValue) {
            _allowedFragments[msg.sender][spender] = 0;
        } else {
            _allowedFragments[msg.sender][spender] = oldValue.sub(subtractedValue);
        }
        emit Approval(msg.sender, spender, _allowedFragments[msg.sender][spender]);
        return true;
    }
}

pragma solidity ^0.4.24;

contract TargetPriceOracle is Ownable {

    
    uint256 public currentMarketPrice;
    function pushTargetReport(uint256 currentMarketPrice_) external onlyOwner
    {

        currentMarketPrice = currentMarketPrice_;
    }

    function getData()
        public
        view
        returns (uint256, bool)
    {

        
        return (currentMarketPrice, true);
    }

}

pragma solidity ^0.4.24;

contract MarketPriceOracle is Ownable {

    
    uint256 public currentMarketPrice;
    function pushMarketReport(uint256 currentMarketPrice_) external onlyOwner
    {

        currentMarketPrice = currentMarketPrice_;
    }

    function getData()
        public
        view
        returns (uint256, bool)
    {

        return (currentMarketPrice, true);
    }

}

contract UFragmentsPolicy is Ownable, TargetPriceOracle, MarketPriceOracle, OracleBase {

    using SafeMath for uint256;
    using SafeMathInt for int256;
    using UInt256Lib for uint256;

    event LogRebase(
        uint256 indexed epoch,
        uint256 exchangeRate,
        uint256 cpi,
        int256 requestedSupplyAdjustment,
        uint256 timestampSec
    );

    uint256 public deviationThreshold;
    
    uint256 public rebaseLag;

    uint256 public minRebaseTimeIntervalSec;

    uint256 public lastRebaseTimestampSec;

    uint256 public rebaseWindowOffsetSec;

    uint256 public rebaseWindowLengthSec;

    uint256 public epoch;

    uint256 private constant DECIMALS = 18;

    uint256 private constant MAX_RATE = 10**6 * 10**DECIMALS;
    uint256 private constant MAX_SUPPLY = ~(uint256(1) << 255) / MAX_RATE;
    
     
    uint256 public priceChange ;
    
    int256 public supplyDeltaNew;

    function policyRebase() internal  {

        require(inRebaseWindow());

        require(lastRebaseTimestampSec.add(minRebaseTimeIntervalSec) < now);

        lastRebaseTimestampSec = now.sub(
             now.mod(minRebaseTimeIntervalSec)).add(rebaseWindowOffsetSec);

        epoch = epoch.add(1);

        uint256 targetRate;
        bool targetRateValid;
        (targetRate, targetRateValid) = TargetPriceOracle.getData();
        require(targetRateValid);
        
        uint256 exchangeRate;
        bool rateValid;
        
        (exchangeRate, rateValid) = MarketPriceOracle.getData();                     // fetch exchange rate in ETH
        require(rateValid);

        if (exchangeRate > MAX_RATE) {
            exchangeRate = MAX_RATE;
        }
        
        int256 supplyDelta = computeSupplyDelta(exchangeRate, targetRate);

        supplyDelta = supplyDelta.div(rebaseLag.toInt256Safe());

        if (supplyDelta > 0 && OracleBase.totalSupply().add(uint256(supplyDelta)) > MAX_SUPPLY) {
            supplyDelta = (MAX_SUPPLY.sub(OracleBase.totalSupply())).toInt256Safe();
        }

        uint256 supplyAfterRebase = OracleBase.rebase(epoch, supplyDelta);
        assert(supplyAfterRebase <= MAX_SUPPLY);
        emit LogRebase(epoch, exchangeRate, targetRate, supplyDelta, now);
    }

    function setDeviationThreshold(uint256 deviationThreshold_)
        external
        onlyOwner
    {

        deviationThreshold = deviationThreshold_;
    }

    function setRebaseLag(uint256 rebaseLag_)
        external
        onlyOwner
    {

        require(rebaseLag_ > 0);
        rebaseLag = rebaseLag_;
    }

    function setRebaseTimingParameters(
        uint256 minRebaseTimeIntervalSec_,
        uint256 rebaseWindowOffsetSec_,
        uint256 rebaseWindowLengthSec_)
        external
        onlyOwner
    {

        require(minRebaseTimeIntervalSec_ > 0);
        require(rebaseWindowOffsetSec_ < minRebaseTimeIntervalSec_);

        minRebaseTimeIntervalSec = minRebaseTimeIntervalSec_;
        rebaseWindowOffsetSec = rebaseWindowOffsetSec_;
        rebaseWindowLengthSec = rebaseWindowLengthSec_;
    }

    function policyInitialize(address _owner)
        internal
    {

        deviationThreshold          =   25 * 10 ** (DECIMALS-3);        // 50000000000000000
        rebaseLag                   =   10;
        minRebaseTimeIntervalSec    =   1 days;
        rebaseWindowOffsetSec       =   72000;                          // 8PM UTC
        rebaseWindowLengthSec       =   15 minutes;
        lastRebaseTimestampSec      =   0;
        epoch = 0;
        OracleBase.tokenInitialize(_owner);
    }

    function inRebaseWindow() public view returns (bool) {

        return (
            now.mod(minRebaseTimeIntervalSec) >= rebaseWindowOffsetSec &&
            now.mod(minRebaseTimeIntervalSec) < (rebaseWindowOffsetSec.add(rebaseWindowLengthSec))
        );
    }

    function computeSupplyDelta(uint256 rate, uint256 targetRate)
        private
        view
        returns (int256)
    {

        if (withinDeviationThreshold(rate, targetRate)) {
            return 0;
        }

        int256 targetRateSigned = targetRate.toInt256Safe();
        return OracleBase.totalSupply().toInt256Safe()
            .mul(rate.toInt256Safe().sub(targetRateSigned))
            .div(targetRateSigned);
    }

    function withinDeviationThreshold(uint256 rate, uint256 targetRate)
        private
        view
        returns (bool)
    {

        uint256 absoluteDeviationThreshold = targetRate.mul(deviationThreshold)
            .div(10 ** DECIMALS);

        return (rate >= targetRate && rate.sub(targetRate) < absoluteDeviationThreshold)
            || (rate < targetRate && targetRate.sub(rate) < absoluteDeviationThreshold);
    }
    
}

contract Orchestrator is Ownable, UFragmentsPolicy {


    struct Transaction {
        bool enabled;
        address destination;
        bytes data;
    }

    event TransactionFailed(address indexed destination, uint index, bytes data);

    Transaction[] public transactions;

    constructor() public {
        Ownable.initialize(msg.sender);
        UFragmentsPolicy.policyInitialize(msg.sender);
    }

    function rebase()
        external
    {

        require(msg.sender == tx.origin);  // solhint-disable-line avoid-tx-origin

        UFragmentsPolicy.policyRebase();

        for (uint i = 0; i < transactions.length; i++) {
            Transaction storage t = transactions[i];
            if (t.enabled) {
                bool result =
                    externalCall(t.destination, t.data);
                if (!result) {
                    emit TransactionFailed(t.destination, i, t.data);
                    revert("Transaction Failed");
                }
            }
        }
    }

    function addTransaction(address destination, bytes data)
        external
        onlyOwner
    {

        transactions.push(Transaction({
            enabled: true,
            destination: destination,
            data: data
        }));
    }

    function removeTransaction(uint index)
        external
        onlyOwner
    {

        require(index < transactions.length, "index out of bounds");

        if (index < transactions.length - 1) {
            transactions[index] = transactions[transactions.length - 1];
        }

        transactions.length--;
    }

    function setTransactionEnabled(uint index, bool enabled)
        external
        onlyOwner
    {

        require(index < transactions.length, "index must be in range of stored tx list");
        transactions[index].enabled = enabled;
    }

    function transactionsSize()
        external
        view
        returns (uint256)
    {

        return transactions.length;
    }

    function externalCall(address destination, bytes data)
        internal
        returns (bool)
    {

        bool result;
        assembly {  // solhint-disable-line no-inline-assembly
            let outputAddress := mload(0x40)

            let dataAddress := add(data, 32)

            result := call(
                sub(gas, 34710),


                destination,
                0, // transfer value in wei
                dataAddress,
                mload(data),  // Size of the input, in bytes. Stored in position 0 of the array.
                outputAddress,
                0  // Output is ignored, therefore the output size is zero
            )
        }
        return result;
    }
}