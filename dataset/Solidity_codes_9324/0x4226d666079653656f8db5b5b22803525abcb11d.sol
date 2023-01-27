
pragma solidity ^0.8.0;

library SafeMathUpgradeable {

    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        unchecked {
            uint256 c = a + b;
            if (c < a) return (false, 0);
            return (true, c);
        }
    }

    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        unchecked {
            if (b > a) return (false, 0);
            return (true, a - b);
        }
    }

    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        unchecked {
            if (a == 0) return (true, 0);
            uint256 c = a * b;
            if (c / a != b) return (false, 0);
            return (true, c);
        }
    }

    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        unchecked {
            if (b == 0) return (false, 0);
            return (true, a / b);
        }
    }

    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        unchecked {
            if (b == 0) return (false, 0);
            return (true, a % b);
        }
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {

        return a + b;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {

        return a - b;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {

        return a * b;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {

        return a / b;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {

        return a % b;
    }

    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {

        unchecked {
            require(b <= a, errorMessage);
            return a - b;
        }
    }

    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {

        unchecked {
            require(b > 0, errorMessage);
            return a / b;
        }
    }

    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {

        unchecked {
            require(b > 0, errorMessage);
            return a % b;
        }
    }
}

interface IUniswapV2Pair {

    event Approval(address indexed owner, address indexed spender, uint value);
    event Transfer(address indexed from, address indexed to, uint value);

    function name() external pure returns (string memory);

    function symbol() external pure returns (string memory);

    function decimals() external pure returns (uint8);

    function totalSupply() external view returns (uint);

    function balanceOf(address owner) external view returns (uint);

    function allowance(address owner, address spender) external view returns (uint);


    function approve(address spender, uint value) external returns (bool);

    function transfer(address to, uint value) external returns (bool);

    function transferFrom(address from, address to, uint value) external returns (bool);


    function DOMAIN_SEPARATOR() external view returns (bytes32);

    function PERMIT_TYPEHASH() external pure returns (bytes32);

    function nonces(address owner) external view returns (uint);


    function permit(address owner, address spender, uint value, uint deadline, uint8 v, bytes32 r, bytes32 s) external;


    event Mint(address indexed sender, uint amount0, uint amount1);
    event Burn(address indexed sender, uint amount0, uint amount1, address indexed to);
    event Swap(
        address indexed sender,
        uint amount0In,
        uint amount1In,
        uint amount0Out,
        uint amount1Out,
        address indexed to
    );
    event Sync(uint112 reserve0, uint112 reserve1);

    function MINIMUM_LIQUIDITY() external pure returns (uint);

    function factory() external view returns (address);

    function token0() external view returns (address);

    function token1() external view returns (address);

    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);

    function price0CumulativeLast() external view returns (uint);

    function price1CumulativeLast() external view returns (uint);

    function kLast() external view returns (uint);


    function mint(address to) external returns (uint liquidity);

    function burn(address to) external returns (uint amount0, uint amount1);

    function swap(uint amount0Out, uint amount1Out, address to, bytes calldata data) external;

    function skim(address to) external;

    function sync() external;


    function initialize(address, address) external;

}

interface ISRC20 {


    event RestrictionsAndRulesUpdated(address restrictions, address rules);

    function transferToken(address to, uint256 value, uint256 nonce, uint256 expirationTime,
        bytes32 msgHash, bytes calldata signature) external returns (bool);

    function transferTokenFrom(address from, address to, uint256 value, uint256 nonce,
        uint256 expirationTime, bytes32 hash, bytes calldata signature) external returns (bool);

    function getTransferNonce() external view returns (uint256);

    function getTransferNonce(address account) external view returns (uint256);

    function executeTransfer(address from, address to, uint256 value) external returns (bool);

    function updateRestrictionsAndRules(address restrictions, address rules) external returns (bool);


    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);

    function totalSupply() external view returns (uint256);

    function balanceOf(address who) external view returns (uint256);

    function allowance(address owner, address spender) external view returns (uint256);

    function approve(address spender, uint256 value) external returns (bool);

    function transfer(address to, uint256 value) external returns (bool);

    function transferFrom(address from, address to, uint256 value) external returns (bool);


    function increaseAllowance(address spender, uint256 value) external returns (bool);

    function decreaseAllowance(address spender, uint256 value) external returns (bool);

}

abstract contract Initializable {
    bool private _initialized;

    bool private _initializing;

    modifier initializer() {
        require(_initializing || !_initialized, "Initializable: contract is already initialized");

        bool isTopLevelCall = !_initializing;
        if (isTopLevelCall) {
            _initializing = true;
            _initialized = true;
        }

        _;

        if (isTopLevelCall) {
            _initializing = false;
        }
    }
}

abstract contract ContextUpgradeable is Initializable {
    function __Context_init() internal initializer {
        __Context_init_unchained();
    }

    function __Context_init_unchained() internal initializer {
    }
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
    uint256[50] private __gap;
}

interface ITransferRules {

    function setSRC(address src20) external returns (bool);

    
    function doTransfer(address from, address to, uint256 value) external returns (bool);

}

abstract contract OwnableUpgradeable is Initializable, ContextUpgradeable {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    function __Ownable_init() internal initializer {
        __Context_init_unchained();
        __Ownable_init_unchained();
    }

    function __Ownable_init_unchained() internal initializer {
        _setOwner(_msgSender());
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        _setOwner(address(0));
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _setOwner(newOwner);
    }

    function _setOwner(address newOwner) private {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
    uint256[49] private __gap;
}
abstract contract BaseTransferRule is Initializable, OwnableUpgradeable, ITransferRules {
    address public chainRuleAddr;
    address public _src20;
    address public doTransferCaller;
    
    
    modifier onlyDoTransferCaller {
        require(msg.sender == address(doTransferCaller));
        _;
    }
    
    function cleanSRC() public onlyOwner() {
        _src20 = address(0);
        doTransferCaller = address(0);
    }
    
    function clearChain() public onlyOwner() {
        _setChain(address(0));
    }
    
    function setChain(address chainAddr) public onlyOwner() {
        _setChain(chainAddr);
        require(_tryExternalSetSRC(_src20), "can't call setSRC at chain contract");
        
    }
    
    
    function setSRC(address src20) override external returns (bool) {
        require(doTransferCaller == address(0), "external contract already set");
        require(address(_src20) == address(0), "external contract already set");
        require(src20 != address(0), "src20 can not be zero");
        doTransferCaller = _msgSender();
        _src20 = src20;
        return true;
    }
    function doTransfer(address from, address to, uint256 value) override external onlyDoTransferCaller returns (bool) {
        (from,to,value) = _doTransfer(from, to, value);
        if (isChainExists()) {
            require(ITransferRules(chainRuleAddr).doTransfer(msg.sender, to, value), "chain doTransfer failed");
        } else {
            require(ISRC20(_src20).executeTransfer(from, to, value), "SRC20 transfer failed");
        }
        return true;
    }
    function __BaseTransferRule_init() internal initializer {
        __Ownable_init();

    }
    function isChainExists() internal view returns(bool) {
        return (chainRuleAddr != address(0) ? true : false);
    }
    
    function _doTransfer(address from, address to, uint256 value) internal virtual returns(address _from, address _to, uint256 _value) ;
    

    function _tryExternalSetSRC(address chainAddr) private returns (bool) {
        try ITransferRules(chainAddr).setSRC(_src20) returns (bool) {
            return (true);
        } catch Error(string memory /*reason*/) {
            
            return (false);
        } catch (bytes memory /*lowLevelData*/) {
            
            return (false);
        }
        
    }
    
    function _setChain(address chainAddr) private {
        chainRuleAddr = chainAddr;
    }
    
}

contract SimpleTransferRule is BaseTransferRule {

    using SafeMathUpgradeable for uint256;
    
    address internal escrowAddr;
    
    mapping (address => uint256) _lastTransactionBlock;
    
    address[] uniswapV2Pairs;
    uint256 normalValueRatio;
    uint256 lockupPeriod;
    uint256 dayInSeconds;
    
    uint256 isTrading;
    uint256 isTransfers;
    
    struct Minimum {
        uint256 amount;
        uint256 startTime;
        uint256 endTime;
        bool gradual;
    }

    mapping(address => Minimum[]) _minimums;
         
    event Event(string topic, address origin);
    

    function init(
    ) 
        public 
        initializer 
    {

        __SimpleTransferRule_init();
        
    }
    
    
     
    function haltTrading() public onlyOwner(){

        isTrading = 0;
    }
    
    function resumeTrading() public onlyOwner() {

        isTrading = 1;
    }
    
    function haltTransfers() public onlyOwner(){

        isTransfers = 0;
    }
    
    function resumeTransfers() public onlyOwner() {

        isTransfers = 1;
    }
    
    function pairsAdd(address pair) public onlyOwner() {

        
        uniswapV2Pairs.push(pair);
    }
    
    function pairsList() public view returns(address[] memory) {

         return uniswapV2Pairs;
    }
    function minimumsView(
        address addr
    ) 
        public
        view
        returns (uint256)
    {

        return _minimumsGet(addr, block.timestamp);
    }
    function minimumsClear(
        address addr
    ) 
        public
        onlyOwner()
    {

        delete _minimums[addr];
    }
     
    
    
    function __SimpleTransferRule_init(
    ) 
        internal
        initializer 
    {

        __BaseTransferRule_init();
        uniswapV2Pairs.push(0x03B0da178FecA0b0BBD5D76c431f16261D0A76aa);
        
        _src20 = 0x6Ef5febbD2A56FAb23f18a69d3fB9F4E2A70440B;
        
        normalValueRatio = 10;
        
        dayInSeconds = 86400;
        lockupPeriod = dayInSeconds.mul(180);
        
        isTrading = 1;
        isTransfers = 1;
        
    }
  
    
    
    function _doTransfer(
        address from, 
        address to, 
        uint256 value
    ) 
        override
        internal
        returns (
            address _from, 
            address _to, 
            uint256 _value
        ) 
    {

        
        (_from,_to,_value) = (from,to,value);
        
        
        if (tx.origin == owner()) {
            return  (_from,_to,_value);
        }
            
        string memory errmsg;
        
        if (isTransfers == 0) {
            errmsg = "Transfers have been temporarily halted";
            emit Event(errmsg, tx.origin);
            revert(errmsg);
        }
            
        _preventTransactionsInSameBlock();
        
        _checkAllowanceMinimums(_from, _value);

        if ((indexOf(uniswapV2Pairs,_from) == -1) && (indexOf(uniswapV2Pairs,_to) == -1)) {
            return  (_from,_to,_value);
        }
            
        if (isTrading == 0) {
            errmsg = "Trading has been temporarily halted";
            emit Event(errmsg, tx.origin);
            revert(errmsg);
        }
        

        if (indexOf(uniswapV2Pairs,_from) != -1) {
            address uniswapV2Pair = _from;
        
            (uint reserveA, uint reserveB) = getReserves(uniswapV2Pair);
            uint256 outlierPrice = (reserveB).div(reserveA);
            
            uint256 obtainedTokenB = getAmountIn(_value,reserveA,reserveB);
            uint256 outlierPriceAfter = (reserveB.add(obtainedTokenB)).div(reserveA.sub(_value));
            
            if (outlierPriceAfter > outlierPrice.mul(normalValueRatio)) {
                _minimumsAdd(_to,value, lockupPeriod, true);
            }
        }
         
    }
    
    function indexOf(address[] memory arr, address item) internal view returns(int32) {

        
        for(uint32 i = 0; i < arr.length; i++) {
            if (arr[i] == item) {
                return int32(i);
            }
        }
        
        return -1;
    }
    function getAmountIn(uint256 token, uint256 reserve0, uint256 reserve1) internal pure returns (uint256 calcEth) {

        uint256 numerator = reserve1.mul(token).mul(1000);
        uint256 denominator = reserve0.sub(token).mul(997);
        calcEth = (numerator / denominator).add(1);
    }
    
    function getReserves(address uniswapV2Pair) internal returns (uint256 reserveA, uint256 reserveB) {

        (reserveA, reserveB,) = IUniswapV2Pair(uniswapV2Pair).getReserves();   
        (reserveA, reserveB) = (_src20 == IUniswapV2Pair(uniswapV2Pair).token0()) ? (reserveA, reserveB) : (reserveB, reserveA);
    }

    function _preventTransactionsInSameBlock() internal {

        if (_lastTransactionBlock[tx.origin] == block.number) {
            emit Event("SandwichAttack", tx.origin);
            revert("Cannot execute two transactions in same block.");
        }
        _lastTransactionBlock[tx.origin] = block.number; 
    }
    
    function _checkAllowanceMinimums(address addr, uint256 amount) internal view {

        uint256 minimum = _minimumsGet(addr, block.timestamp);
       
        uint256 canBeTransferring = ISRC20(_src20).balanceOf(addr).sub(minimum);
        require(canBeTransferring >= amount, "insufficient balance to maintain minimum lockup");
        
    }
    
    function _minimumsAdd(
        address addr,
        uint256 amount,
        uint256 duration,
        bool gradual
    ) 
        internal
    {

        
        
        Minimum memory minimum = Minimum({
              amount: amount,
              startTime: block.timestamp,
              endTime: block.timestamp.add(duration),
              gradual: gradual
        });
        _minimums[addr].push(minimum);
    }
      
    function _minimumsGet(
        address addr,
        uint256 currentTime
    ) 
        internal 
        view
        returns (uint256) 
    {

         
        uint256 minimum = 0;
        uint256 c = _minimums[addr].length;
        uint256 m;
        
        for (uint256 i=0; i<c; i++) {
            if (
                _minimums[addr][i].startTime > currentTime || 
                _minimums[addr][i].endTime < currentTime 
                ) {
                continue;
            }
            
            m = _minimums[addr][i].amount;
            if (_minimums[addr][i].gradual) {
                m = m.mul(_minimums[addr][i].endTime.sub(currentTime)).div(_minimums[addr][i].endTime.sub(_minimums[addr][i].startTime));
            }
            minimum = minimum.add(m);
        }
        return minimum;
    }
    
}