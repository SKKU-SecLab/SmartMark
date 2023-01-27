pragma solidity 0.4.24;




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
contract Context {

    function _msgSender() internal constant returns (address ) {

        return msg.sender;
    }

    function _msgData() internal constant returns (bytes memory) {

        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

contract Ownable is Context {

    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    
    constructor () public {
        address msgSender = _msgSender();
        _owner = msgSender;
        
        emit OwnershipTransferred(address(0), msgSender);
    }

    function owner() public constant returns (address) {

        return _owner;
    }

    modifier onlyOwner() {

        require(_owner == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public onlyOwner {

        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    function transferOwnership(address newOwner) public onlyOwner {

        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

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

interface IERC20 {

    function totalSupply() external view returns (uint256);


    function balanceOf(address who) external view returns (uint256);


    function allowance(address owner, address spender) external view returns (uint256);


    function transfer(address to, uint256 value) external returns (bool);


    function approve(address spender, uint256 value) external returns (bool);


    function transferFrom(address from, address to, uint256 value) external returns (bool);


    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}

contract ERC20 is IERC20 {

    using SafeMath for uint256;

    mapping (address => uint256) private _balances;

    mapping (address => mapping (address => uint256)) private _allowed;

    uint256 private _totalSupply;

    function totalSupply() public view returns (uint256) {

        return _totalSupply;
    }

    function balanceOf(address owner) public view returns (uint256) {

        return _balances[owner];
    }

    function allowance(address owner, address spender) public view returns (uint256) {

        return _allowed[owner][spender];
    }

    function transfer(address to, uint256 value) public returns (bool) {

        _transfer(msg.sender, to, value);
        return true;
    }

    function approve(address spender, uint256 value) public returns (bool) {

        require(spender != address(0));

        _allowed[msg.sender][spender] = value;
        emit Approval(msg.sender, spender, value);
        return true;
    }

    function transferFrom(address from, address to, uint256 value) public returns (bool) {

        require(from != address(0));
        require(to != address(0));
        _allowed[from][msg.sender] = _allowed[from][msg.sender].sub(value);
        _transfer(from, to, value);
        emit Approval(from, msg.sender, _allowed[from][msg.sender]);
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public returns (bool) {

        require(spender != address(0));

        _allowed[msg.sender][spender] = _allowed[msg.sender][spender].add(addedValue);
        emit Approval(msg.sender, spender, _allowed[msg.sender][spender]);
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public returns (bool) {

        require(spender != address(0));

        _allowed[msg.sender][spender] = _allowed[msg.sender][spender].sub(subtractedValue);
        emit Approval(msg.sender, spender, _allowed[msg.sender][spender]);
        return true;
    }

    function _transfer(address from, address to, uint256 value) internal {

        require(to != address(0), "invalid to address");
        require(from != address(0), "invalid from address");

        _balances[from] = _balances[from].sub(value);
        _balances[to] = _balances[to].add(value);
        emit Transfer(from, to, value);
    }

    function _mint(address account, uint256 value) internal {

        require(account != address(0));

        _totalSupply = _totalSupply.add(value);
        _balances[account] = _balances[account].add(value);
        emit Transfer(address(0), account, value);
    }

    function _burn(address account, uint256 value) internal {

        require(account != address(0));

        _totalSupply = _totalSupply.sub(value);
        _balances[account] = _balances[account].sub(value);
        emit Transfer(account, address(0), value);
    }

    function _burnFrom(address account, uint256 value) internal {

        require(account != address(0));
        _allowed[account][msg.sender] = _allowed[account][msg.sender].sub(value);
        _burn(account, value);
        emit Approval(account, msg.sender, _allowed[account][msg.sender]);
    }
}

contract ERC20Detailed is ERC20 {

    string private _name;
    string private _symbol;
    uint8 private _decimals;
    
    constructor(string name, string symbol, uint8 decimals) public {
        _name = name;
        _symbol = symbol;
        _decimals = decimals;
    }

    function name() public view returns (string) {

        return _name;
    }

    function symbol() public view returns (string) {

        return _symbol;
    }

    function decimals() public view returns (uint8) {

        return _decimals;
    }
}

contract GatorToken is ERC20Detailed {


    using SafeMath for uint256;
    using SafeMathInt for int256;
    address private _owner;

    event LogRebase(uint256 indexed epoch, uint256 totalSupply);
    event LogMonetaryPolicyUpdated(address monetaryPolicy);

    address public monetaryPolicy;

    modifier onlyMonetaryPolicy() {

        require(msg.sender == monetaryPolicy);
        _;
    }

    modifier validRecipient(address to) {

        require(to != address(0));
        require(to != address(this));
        _;
    }

    uint256 public constant DECIMALS = 18;
    uint256 private constant MAX_UINT256 = ~uint256(0);
    
    uint256 private constant INITIAL_FRAGMENTS_SUPPLY = 350000*10**DECIMALS;

    uint256 private constant TOTAL_GONS = MAX_UINT256 - (MAX_UINT256 % INITIAL_FRAGMENTS_SUPPLY);
    uint256 private _totalSupply;
    uint256 private _gonsPerFragment;
    mapping(address => uint256) private _balances;

    mapping (address => mapping (address => uint256)) private _allowedFragments;

    function owner() public constant returns (address) {

        return _owner;
    }

    modifier onlyOwner() {

        require(_owner == msg.sender, "Ownable: caller is not the owner");
        _;
    }
    function renounceOwnership() public onlyOwner {

        _owner = address(0);
    }

    function transferOwnership(address newOwner) public onlyOwner {

        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _owner = newOwner;
    }

    function setMonetaryPolicy(address monetaryPolicy_)
        external
        onlyOwner
    {

        require(monetaryPolicy_ != address(0), "empty monetaryPolicy address");
        
        monetaryPolicy = monetaryPolicy_;
        emit LogMonetaryPolicyUpdated(monetaryPolicy_);
    }

    function rebase(uint256 epoch, int256 supplyDelta)
        external
        onlyMonetaryPolicy
        returns (uint256)
    {   


        if (supplyDelta == 0) {
            emit LogRebase(epoch, _totalSupply);
            return _totalSupply;
        }
        uint256 _supplyDelta = uint256(supplyDelta);

        _totalSupply = _totalSupply.div(_gonsPerFragment);

        if (supplyDelta >= 0) {
            _totalSupply = _totalSupply.add(_supplyDelta);
        }
        _gonsPerFragment = TOTAL_GONS.div(_totalSupply);

        _totalSupply = _totalSupply.mul(_gonsPerFragment);

        emit LogRebase(epoch, _totalSupply);
        return _totalSupply;
    }

    constructor() ERC20Detailed("GATOR", "GATR", uint8(DECIMALS))
        public
    {
        _owner = msg.sender;
        
        _totalSupply = INITIAL_FRAGMENTS_SUPPLY;
        _gonsPerFragment = TOTAL_GONS.div(_totalSupply);
        _totalSupply = INITIAL_FRAGMENTS_SUPPLY.mul(_gonsPerFragment);
        _balances[_owner] = INITIAL_FRAGMENTS_SUPPLY.mul(_gonsPerFragment);

        emit Transfer(address(0), _owner, _totalSupply);
    }

    function totalSupply()
        public
        view
        returns (uint256)
    {

        return _totalSupply.div(_gonsPerFragment);
    }

    function balanceOf(address who)
        public
        view
        returns (uint256)
    {

        return _balances[who].div(_gonsPerFragment);
    }

    function transfer(address to, uint256 value)
        public
        validRecipient(to)
        returns (bool)
    {

        require(to != address(0));
        uint256 gonValue = value.mul(_gonsPerFragment);
        _balances[msg.sender] = _balances[msg.sender].sub(gonValue);
        _balances[to] = _balances[to].add(gonValue);
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
        public
        validRecipient(to)
        returns (bool)
    {

        require(from != address(0));
        _allowedFragments[from][msg.sender] = _allowedFragments[from][msg.sender].sub(value);

        uint256 gonValue = value.mul(_gonsPerFragment);
        _balances[from] = _balances[from].sub(gonValue);
        _balances[to] = _balances[to].add(gonValue);
        emit Transfer(from, to, value);

        return true;
    }

    function approve(address spender, uint256 value)
        public
        returns (bool)
    {

        require(spender != address(0));
        _allowedFragments[msg.sender][spender] = value;
        emit Approval(msg.sender, spender, value);
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue)
        public
        returns (bool)
    {

        require(spender != address(0));
        _allowedFragments[msg.sender][spender] =
            _allowedFragments[msg.sender][spender].add(addedValue);
        emit Approval(msg.sender, spender, _allowedFragments[msg.sender][spender]);
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue)
        public
        returns (bool)
    {

        require(spender != address(0));
        uint256 oldValue = _allowedFragments[msg.sender][spender];
        if (subtractedValue >= oldValue) {
            _allowedFragments[msg.sender][spender] = 0;
        } else {
            _allowedFragments[msg.sender][spender] = oldValue.sub(subtractedValue);
        }
        emit Approval(msg.sender, spender, _allowedFragments[msg.sender][spender]);
        return true;
    }
    
}pragma solidity 0.4.24;


library UInt256Lib {

    
    uint256 private constant MAX_INT256 = (2**255)-1;

    function toInt256Safe(uint256 a)
        internal
        pure
        returns (int256)
    {

        require(a <= MAX_INT256, "SafeCast: value doesn't fit in an int256");
        return int256(a);
    }
}

contract GatorPolicy is Ownable {

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

    GatorToken public uFrags;


    uint256 public deviationThreshold;

    uint256 public token_price;


    uint256 public minRebaseTimeIntervalSec;

    uint256 public lastRebaseTimestampSec;



    uint256 public epoch;

    uint256 private constant DECIMALS = 18;

    uint256 private constant MAX_RATE = 10**6*10**DECIMALS;
    uint256 private constant MAX_SUPPLY = ~(uint256(1) << 255) / MAX_RATE;

    address public orchestrator;

    modifier onlyOrchestrator() {

        require(msg.sender == orchestrator);
        _;
    }

    function rebase(uint256 wei_token_price) external
    onlyOrchestrator
    {

        epoch = epoch.add(1);
        
        int256 supplyDelta = computeSupplyDelta(wei_token_price);
        
        if(supplyDelta == 0) {
            require(lastRebaseTimestampSec + 24 hours < now, "24 hours has not passed since the last rebase");

            token_price = wei_token_price;
            
            lastRebaseTimestampSec = now;
        } else {
            
            require(lastRebaseTimestampSec.add(minRebaseTimeIntervalSec) < now , "30 minutes has not passed since last rebase");
            
            require(supplyDelta != 0,"not a 5% increase");
            
            if (supplyDelta > 0 && uFrags.totalSupply().add(uint256(supplyDelta)) > MAX_SUPPLY) {
                supplyDelta = (MAX_SUPPLY.sub(uFrags.totalSupply())).toInt256Safe();
            }
            
            uint old_token_price = token_price;
            require(wei_token_price > old_token_price, "new token price is not greater than old");
            
            uint actual_new_token_price = old_token_price + uint(wei_token_price - old_token_price).div(2);
            int256 actual_rebase_price_delta = computeSupplyDelta(actual_new_token_price);
            
            uFrags.rebase(epoch, actual_rebase_price_delta);
            
            lastRebaseTimestampSec = now;
            
            token_price = actual_new_token_price;
        }
            
    }
        
    function setOrchestrator(address orchestrator_)
        external
        onlyOwner
    {

        require(orchestrator_ != address(0));
        orchestrator = orchestrator_;
    }

    function setTokenPrice(uint256 _token_price)
        external
        onlyOwner
    {   

        token_price = _token_price;
    }

    function setDeviationThreshold(uint256 deviationThreshold_)
        external
        onlyOwner
    {

        deviationThreshold = deviationThreshold_;
    }

    function setRebaseTimingParameters(
        uint256 minRebaseTimeIntervalSec_,
        uint256 rebaseWindowOffsetSec_)
        external
        onlyOwner
    {

        require(minRebaseTimeIntervalSec_ > 0);
        require(rebaseWindowOffsetSec_ < minRebaseTimeIntervalSec_);

        minRebaseTimeIntervalSec = minRebaseTimeIntervalSec_;
    }

    constructor(GatorToken uFrags_, uint256 _token_price)
        public
    {
        
        token_price = _token_price;

        deviationThreshold = 5 * 10 ** (DECIMALS-2); // 5%

        minRebaseTimeIntervalSec = 30 minutes;
        lastRebaseTimestampSec = now;
        epoch = 0;

        uFrags = uFrags_;

    }

    function computeSupplyDelta(uint256 new_price)
        public
        view
        returns (int256)
    {

        if (withinDeviationThreshold(new_price, token_price)) {
            return 0;
        }
        if (new_price < token_price) {
            return 0;
        }

        int256 targetRateSigned = token_price.toInt256Safe();

        return uFrags.totalSupply().toInt256Safe()
            .mul(new_price.toInt256Safe().sub(targetRateSigned))
            .div(targetRateSigned);
    }


    function withinDeviationThreshold(uint256 new_price, uint256 old_price)
        public
        view
        returns (bool)
    {

        uint256 absoluteDeviationThreshold = old_price.mul(deviationThreshold).div(10**DECIMALS);
        
        return (new_price >= old_price && new_price.sub(old_price) < absoluteDeviationThreshold)
            || (new_price < old_price && old_price.sub(new_price) < absoluteDeviationThreshold);
    }
}
pragma solidity 0.4.24;


contract Orchestrator is Ownable {


    struct Transaction {
        bool enabled;
        address destination;
        bytes data;
    }

    event TransactionFailed(address indexed destination, uint index, bytes data);
    event TransactionSent(address indexed destination, uint index, bytes data);
    
    Transaction[] public transactions;

    GatorPolicy public policy;

    constructor(address policy_) public {
        require(policy_ != address(0), "policy is not set correctly");
        policy = GatorPolicy(policy_);
    }


    function rebase(uint256 wei_token_price)
    onlyOwner
    external
    {

        
        policy.rebase(wei_token_price);

        for (uint i = 0; i < transactions.length; i++) {
            Transaction storage t = transactions[i];
            if (t.enabled) {
                emit TransactionSent(t.destination, i, t.data);
                bool result =
                    externalCall(t.destination, t.data);
                if (!result) {
                    revert("Transaction Failed");
                }
            }
        }
    }

    function addTransaction(address destination, bytes data)
        external
        onlyOwner
    {

        require(destination != address(0));
        transactions.push(Transaction({
            enabled: true,
            destination: destination,
            data: data
        }));
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

        require(destination != address(0));
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