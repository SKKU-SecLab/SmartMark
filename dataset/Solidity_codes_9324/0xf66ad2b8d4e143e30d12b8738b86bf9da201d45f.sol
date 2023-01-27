
pragma solidity =0.6.6;

abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

contract Ownable is Context {

    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor () internal {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    function owner() public view returns (address) {

        return _owner;
    }

    modifier onlyOwner() {

        require(_owner == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {

        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {

        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

interface IERC20 {

    function totalSupply() external view returns (uint256);


    function balanceOf(address account) external view returns (uint256);


    function transfer(address recipient, uint256 amount) external returns (bool);


    function allowance(address owner, address spender) external view returns (uint256);


    function approve(address spender, uint256 amount) external returns (bool);


    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);


    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}

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

library Address {

    function isContract(address account) internal view returns (bool) {

        bytes32 codehash;
        bytes32 accountHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;
        assembly { codehash := extcodehash(account) }
        return (codehash != accountHash && codehash != 0x0);
    }

    function sendValue(address payable recipient, uint256 amount) internal {

        require(address(this).balance >= amount, "Address: insufficient balance");

        (bool success, ) = recipient.call{ value: amount }("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    function functionCall(address target, bytes memory data) internal returns (bytes memory) {

      return functionCall(target, data, "Address: low-level call failed");
    }

    function functionCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {

        return _functionCallWithValue(target, data, 0, errorMessage);
    }

    function functionCallWithValue(address target, bytes memory data, uint256 value) internal returns (bytes memory) {

        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    function functionCallWithValue(address target, bytes memory data, uint256 value, string memory errorMessage) internal returns (bytes memory) {

        require(address(this).balance >= value, "Address: insufficient balance for call");
        return _functionCallWithValue(target, data, value, errorMessage);
    }

    function _functionCallWithValue(address target, bytes memory data, uint256 weiValue, string memory errorMessage) private returns (bytes memory) {

        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{ value: weiValue }(data);
        if (success) {
            return returndata;
        } else {
            if (returndata.length > 0) {

                assembly {
                    let returndata_size := mload(returndata)
                    revert(add(32, returndata), returndata_size)
                }
            } else {
                revert(errorMessage);
            }
        }
    }
}

library SafeERC20 {

    using SafeMath for uint256;
    using Address for address;

    function safeTransfer(IERC20 token, address to, uint256 value) internal {

        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(IERC20 token, address from, address to, uint256 value) internal {

        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    function safeApprove(IERC20 token, address spender, uint256 value) internal {

        require((value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(IERC20 token, address spender, uint256 value) internal {

        uint256 newAllowance = token.allowance(address(this), spender).add(value);
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(IERC20 token, address spender, uint256 value) internal {

        uint256 newAllowance = token.allowance(address(this), spender).sub(value, "SafeERC20: decreased allowance below zero");
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function _callOptionalReturn(IERC20 token, bytes memory data) private {


        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) { // Return data is optional
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}

contract Pausable is Context {

    event Paused(address account);

    event Unpaused(address account);

    bool private _paused;

    constructor () internal {
        _paused = false;
    }

    function paused() public view returns (bool) {

        return _paused;
    }

    modifier whenNotPaused() {

        require(!_paused, "Pausable: paused");
        _;
    }

    modifier whenPaused() {

        require(_paused, "Pausable: not paused");
        _;
    }

    function _pause() internal virtual whenNotPaused {

        _paused = true;
        emit Paused(_msgSender());
    }

    function _unpause() internal virtual whenPaused {

        _paused = false;
        emit Unpaused(_msgSender());
    }
}

contract ERC20 is Context, IERC20 {

    using SafeMath for uint256;
    using Address for address;

    mapping (address => uint256) internal _balances;

    mapping (address => mapping (address => uint256)) private _allowances;

    uint256 internal _totalSupply;

    string private _name;
    string private _symbol;
    uint8 private _decimals;

    constructor (string memory name, string memory symbol) public {
        _name = name;
        _symbol = symbol;
        _decimals = 18;
    }

    function name() public view returns (string memory) {

        return _name;
    }

    function symbol() public view returns (string memory) {

        return _symbol;
    }

    function decimals() public view returns (uint8) {

        return _decimals;
    }

    function totalSupply() public view override returns (uint256) {

        return _totalSupply;
    }

    function balanceOf(address account) public view override returns (uint256) {

        return _balances[account];
    }

    function transfer(address recipient, uint256 amount) public virtual override returns (bool) {

        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function allowance(address owner, address spender) public view virtual override returns (uint256) {

        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public virtual override returns (bool) {

        _approve(_msgSender(), spender, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) public virtual override returns (bool) {

        _transfer(sender, recipient, amount);
        _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount, "ERC20: transfer amount exceeds allowance"));
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {

        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].add(addedValue));
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {

        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].sub(subtractedValue, "ERC20: decreased allowance below zero"));
        return true;
    }

    function _transfer(address sender, address recipient, uint256 amount) internal virtual {

        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(sender, recipient, amount);

        _balances[sender] = _balances[sender].sub(amount, "ERC20: transfer amount exceeds balance");
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
    }

    function _mint(address account, uint256 amount) internal virtual {

        require(account != address(0), "ERC20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply = _totalSupply.add(amount);
        _balances[account] = _balances[account].add(amount);
        emit Transfer(address(0), account, amount);
    }

    function _burn(address account, uint256 amount) internal virtual {

        require(account != address(0), "ERC20: burn from the zero address");

        _beforeTokenTransfer(account, address(0), amount);

        _balances[account] = _balances[account].sub(amount, "ERC20: burn amount exceeds balance");
        _totalSupply = _totalSupply.sub(amount);
        emit Transfer(account, address(0), amount);
    }

    function _approve(address owner, address spender, uint256 amount) internal virtual {

        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _setupDecimals(uint8 decimals_) internal {

        _decimals = decimals_;
    }

    function _beforeTokenTransfer(address from, address to, uint256 amount) internal virtual { }

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

library FixedPoint {
    struct uq112x112 {
        uint224 _x;
    }

    struct uq144x112 {
        uint _x;
    }

    uint8 private constant RESOLUTION = 112;

    function encode(uint112 x) internal pure returns (uq112x112 memory) {
        return uq112x112(uint224(x) << RESOLUTION);
    }

    function encode144(uint144 x) internal pure returns (uq144x112 memory) {
        return uq144x112(uint256(x) << RESOLUTION);
    }

    function div(uq112x112 memory self, uint112 x) internal pure returns (uq112x112 memory) {
        require(x != 0, 'FixedPoint: DIV_BY_ZERO');
        return uq112x112(self._x / uint224(x));
    }

    function mul(uq112x112 memory self, uint y) internal pure returns (uq144x112 memory) {
        uint z;
        require(y == 0 || (z = uint(self._x) * y) / y == uint(self._x), "FixedPoint: MULTIPLICATION_OVERFLOW");
        return uq144x112(z);
    }

    function fraction(uint112 numerator, uint112 denominator) internal pure returns (uq112x112 memory) {
        require(denominator > 0, "FixedPoint: DIV_BY_ZERO");
        return uq112x112((uint224(numerator) << RESOLUTION) / denominator);
    }

    function decode(uq112x112 memory self) internal pure returns (uint112) {
        return uint112(self._x >> RESOLUTION);
    }

    function decode144(uq144x112 memory self) internal pure returns (uint144) {
        return uint144(self._x >> RESOLUTION);
    }
}

library UniswapV2OracleLibrary {
    using FixedPoint for *;

    function currentBlockTimestamp() internal view returns (uint32) {
        return uint32(block.timestamp % 2 ** 32);
    }

    function currentCumulativePrices(
        address pair
    ) internal view returns (uint price0Cumulative, uint price1Cumulative, uint32 blockTimestamp) {
        blockTimestamp = currentBlockTimestamp();
        price0Cumulative = IUniswapV2Pair(pair).price0CumulativeLast();
        price1Cumulative = IUniswapV2Pair(pair).price1CumulativeLast();

        (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast) = IUniswapV2Pair(pair).getReserves();
        if (blockTimestampLast != blockTimestamp) {
            uint32 timeElapsed = blockTimestamp - blockTimestampLast;
            price0Cumulative += uint(FixedPoint.fraction(reserve1, reserve0)._x) * timeElapsed;
            price1Cumulative += uint(FixedPoint.fraction(reserve0, reserve1)._x) * timeElapsed;
        }
    }
}

library UniswapV2Library {
    using SafeMath for uint;

    function sortTokens(address tokenA, address tokenB) internal pure returns (address token0, address token1) {
        require(tokenA != tokenB, 'UniswapV2Library: IDENTICAL_ADDRESSES');
        (token0, token1) = tokenA < tokenB ? (tokenA, tokenB) : (tokenB, tokenA);
        require(token0 != address(0), 'UniswapV2Library: ZERO_ADDRESS');
    }

    function pairFor(address factory, address tokenA, address tokenB) internal pure returns (address pair) {
        (address token0, address token1) = sortTokens(tokenA, tokenB);
        pair = address(uint(keccak256(abi.encodePacked(
                hex'ff',
                factory,
                keccak256(abi.encodePacked(token0, token1)),
                hex'96e8ac4277198ff8b6f785478aa9a39f403cb768dd02cbee326c3e7da348845f' // init code hash
            ))));
    }
}

contract NitroProtocol {
    struct TimelockedBonus {
        uint256 bonusAmount;
        uint releaseBlock;
    }

    mapping (address => TimelockedBonus) private _timelockedBonuses;
    
    uint256 private _maxSellRemoval; //units are %

    uint256 private _maxBuyBonus; //units are %


    function maxSellRemoval() public view returns (uint256) {
        return _maxSellRemoval;
    }

    function maxBuyBonus() public view returns (uint256) {
        return _maxBuyBonus;
    }

    function getBonusUnlockTime(address bonusAddress) public view returns (uint) {
        return _timelockedBonuses[bonusAddress].releaseBlock; //Using memory, temporary
    }

    function getBonusAmount(address bonusAddress) public view returns (uint256) {
        return _timelockedBonuses[bonusAddress].bonusAmount;
    }


    function _changeMaxSellRemoval(uint256 new_maxSellRemoval) internal {
        _maxSellRemoval = new_maxSellRemoval;
    }

    function _setMaxBuyBonusPercentage(uint256 new_maxBuyBonus) internal {
        _maxBuyBonus = new_maxBuyBonus;
    }


    function _addToTimelockedBonus(address bonusAddress, uint256 tokens_to_add, uint releaseBlockNumber) internal {
        _timelockedBonuses[bonusAddress] = TimelockedBonus((_timelockedBonuses[bonusAddress].bonusAmount + tokens_to_add), releaseBlockNumber);
    }

    function _removeTimelockedBonus(address bonusAddress) internal {
        uint256 amount = 0;
        _timelockedBonuses[bonusAddress] = TimelockedBonus(amount, block.number);
    }
}




contract LamboToken is ERC20, NitroProtocol, Ownable, Pausable {
    using SafeMath for uint256;

    uint256 public constant scaleFactor = 1e18;

    uint256 public constant total_supply = 2049 ether;

    uint256 public constant INITIAL_TOKENS_PER_ETH = 2.27272727 * 1 ether;

    address public constant WETH = address(0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2);

    address public constant uniswapV2Factory = address(0x5C69bEe701ef814a2B6a3EDD4B1652CB9cc5aA6f);

    address public immutable initialDistributionAddress;    

    address public stakingContractAddress;

    address public presaleContractAddress;

    uint256 public presaleInitFunds; 

    mapping(address => bool) public whitelistedSenders;

    mapping(address => bool) public exchangeAddresses;

    address public uniswapPair;

    bool public isThisToken0;


    uint32 public blockTimestampLast;

    uint256 public priceCumulativeLast;

    uint256 public priceAverageLast;


    uint32 public blockTimestampLastLong;

    uint256 public priceCumulativeLastLong;

    uint256 public priceAverageLastLong;

    uint256 public minDeltaTwapLong;

    uint256 public minDeltaTwapShort;

    uint public bonusReleaseTime;

    uint256 public MECHANIC_PCT;

    address public uniswapv2RouterAddress; 


    event TwapUpdated(uint256 priceCumulativeLast, uint256 blockTimestampLast, uint256 priceAverageLast);

    event LongTwapUpdated(uint256 priceCumulativeLastLong, uint256 blockTimestampLastLong, uint256 priceAverageLastLong);

    event MechanicPercentUpdated(uint256 new_mechanic_PCT);

    event StakingContractAddressUpdated(address newStakingAddress);

    event MaxSellRemovalUpdated(uint256 new_MSR);

    event MaxBuyBonusUpdated(uint256 new_MBB);

    event ExchangeListUpdated(address exchangeAddress, bool isExchange);

    event BonusBalanceUpdated(address userAddress, uint256 newAmount);

    event BonusReleaseTimeUpdated(uint blockDelta);

    event BuyerBonusPaid(address receiver, uint256 bonusAmount);

    constructor(
        uint256 _minDeltaTwapLong,
        uint256 _minDeltaTwapShort,
        uint256 _MECHANIC_PCT
    ) 
    public
    Ownable()
    ERC20("LamboToken", "LAMBO")
    {
        bonusReleaseTime = 13041; 
        setMinDeltaTwap(_minDeltaTwapLong, _minDeltaTwapShort);
        _setMaxBuyBonusPercentage(25);
        _changeMaxSellRemoval(25);
        initialDistributionAddress = owner(); //The contract owner handles all initial distribution, except for presale
        setMechanicPercent(_MECHANIC_PCT);
        _distributeTokens(owner());
        _initializePair();
        _pause();
        setUniswapRouterAddress(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);
    }

    modifier whenNotPausedOrInitialDistribution(address tokensender) { //Only used on transfer function
        require(!paused() || msg.sender == initialDistributionAddress || _isWhitelistedSender(msg.sender) || (msg.sender == uniswapv2RouterAddress && tokensender == owner()), "!paused && !initialDistributionAddress !InitialLiquidityProvider");
        _;
    }

    modifier onlyInitialDistributionAddress() { //Only used to initialize twap
        require(msg.sender == initialDistributionAddress, "!initialDistributionAddress");
        _;
    }
    
    function _distributeTokens(
        address _initialDistributionAddress
    ) 
    internal
    {
        uint256 initDistributionFunds = 380 ether;
        presaleInitFunds = 535.6 ether;
        uint256 initContractFunds = total_supply.sub(initDistributionFunds);

        require((initContractFunds+initDistributionFunds)==total_supply, "Fund distribution doesn't match total supply.");

        _mint(address(_initialDistributionAddress), initDistributionFunds);
        setWhitelistedSender(_initialDistributionAddress, true);

        _mint(address(this), initContractFunds);
        setWhitelistedSender(address(this), true);
    }

    function _initializePair() internal {
        (address token0, address token1) = UniswapV2Library.sortTokens(address(this), address(WETH));
        isThisToken0 = (token0 == address(this));
        uniswapPair = UniswapV2Library.pairFor(uniswapV2Factory, token0, token1);
        setExchangeAddress(uniswapPair, true);
    }

    function setUniswapRouterAddress(address newUniRouterAddy) public onlyOwner {
        uniswapv2RouterAddress = newUniRouterAddy;
    }

    function unpause() external virtual onlyOwner {
        super._unpause();
    }


    function changeMaxSellRemoval(uint256 maxSellRemoval) public onlyOwner {
        require(maxSellRemoval < 100, "Max Sell Removal is too high!");
        require(maxSellRemoval > 0, "Max Sell Removal is too small!");
        _changeMaxSellRemoval(maxSellRemoval);

        emit MaxSellRemovalUpdated(maxSellRemoval);
    }

    function setStakingContractAddress(address stakingContract) public onlyOwner {
        stakingContractAddress = stakingContract;

        emit StakingContractAddressUpdated(stakingContract);
    }
    
    function setPresaleContractAddress(address presaleContract) public onlyOwner {
        if(presaleContractAddress==address(0)){
            presaleContractAddress = presaleContract;

            setWhitelistedSender(presaleContractAddress, true);

            super._transfer(address(this), presaleContractAddress, presaleInitFunds);
        }
    }

    function setMaxBuyBonusPercentage(uint256 _maxBuyBonus) public onlyOwner {
        require(_maxBuyBonus < 100, "Max Buy Bonus is too high!");
        require(_maxBuyBonus > 0, "Max Buy Bonus is too small!");
        _setMaxBuyBonusPercentage(_maxBuyBonus);

        emit MaxBuyBonusUpdated(_maxBuyBonus);
    }

    function setMechanicPercent(uint256 _MECHANIC_PCT) public onlyOwner {
        require(_MECHANIC_PCT < 100, "Percent going to mechanics is too high!");
        require(_MECHANIC_PCT > 0, "Percent going to mechanics is too small!");
        MECHANIC_PCT = _MECHANIC_PCT;

        emit MechanicPercentUpdated(MECHANIC_PCT);
    }

    function setBonusReleaseTime(uint releasetime) public onlyOwner {
        bonusReleaseTime = releasetime;
        
        emit BonusReleaseTimeUpdated(bonusReleaseTime);
    }

    function addBonusTokensBalance(address bonusAddress, uint256 bonus_tokens_amount) internal {
        uint releaseBlock = block.number + bonusReleaseTime;

        _addToTimelockedBonus(bonusAddress, bonus_tokens_amount, releaseBlock);
    }


    function setMinDeltaTwap(uint256 _minDeltaTwapLong, uint256 _minDeltaTwapShort) public onlyOwner {
        require(_minDeltaTwapLong > 1 seconds, "Minimum delTWAP (Long) is too small!");
        require(_minDeltaTwapShort > 1 seconds, "Minimum delTWAP (Short) is too small!");
        require(_minDeltaTwapLong > _minDeltaTwapShort, "Long delta is smaller than short delta!");
        minDeltaTwapLong = _minDeltaTwapLong;
        minDeltaTwapShort = _minDeltaTwapShort;
    }

    function setWhitelistedSender(address _address, bool _whitelisted) public onlyOwner {
        whitelistedSenders[_address] = _whitelisted;
    }

    function setExchangeAddress(address _address, bool _isexchange) public onlyOwner {
        exchangeAddresses[_address] = _isexchange;

        emit ExchangeListUpdated(_address, _isexchange);
    }


    function _isWhitelistedSender(address _sender) internal view returns (bool) {
        return whitelistedSenders[_sender];
    }    

    function isExchangeAddress(address _sender) public view returns (bool) {
        return exchangeAddresses[_sender];
    }


    function _transfer(address sender, address recipient, uint256 amount)
        internal
        virtual
        override
        whenNotPausedOrInitialDistribution(sender)
    {
        if(!_isWhitelistedSender(sender)){

            if(isExchangeAddress(sender)){
                _updateShortTwap();
                _updateLongTwap();

                uint256 currentNitro = calculateCurrentNitroRate(true);
                uint256 bonus_tokens_amount = currentNitro.mul(amount).div(scaleFactor);

                addBonusTokensBalance(recipient, bonus_tokens_amount);

                emit BonusBalanceUpdated(recipient, getBonusAmount(recipient));

            }else if(isExchangeAddress(recipient)) {
                _updateShortTwap();
                _updateLongTwap();

                uint256 currentNitro = calculateCurrentNitroRate(false);
                uint256 removed_tokens_amount = currentNitro.mul(amount).div(scaleFactor);
                amount = amount.sub(removed_tokens_amount);

                uint256 mechanics_tokens = MECHANIC_PCT.mul(removed_tokens_amount).div(100);
                uint256 nitro_tokens = removed_tokens_amount.sub(mechanics_tokens);

                super._transfer(sender, address(this), nitro_tokens);

                if(stakingContractAddress!=address(0)){
                    super._transfer(sender, address(stakingContractAddress), mechanics_tokens); //TEST address wrapper on stakingcontractaddress crashing transfer function
                }

            }
        }
        
        super._transfer(sender, recipient, amount);
    }


    function _updateLongTwap() internal virtual returns (uint256) {
        (uint price0Cumulative, uint price1Cumulative, uint32 blockTimestamp) = 
            UniswapV2OracleLibrary.currentCumulativePrices(uniswapPair);
        uint32 timeElapsed = blockTimestamp - blockTimestampLastLong; // overflow is desired

        if (timeElapsed > minDeltaTwapLong) {
            uint256 priceCumulative = isThisToken0 ? price1Cumulative : price0Cumulative;

            FixedPoint.uq112x112 memory priceAverage = FixedPoint.uq112x112(
                uint224((priceCumulative - priceCumulativeLastLong) / timeElapsed)
            );

            priceCumulativeLastLong = priceCumulative;
            blockTimestampLastLong = blockTimestamp;

            priceAverageLastLong = FixedPoint.decode144(FixedPoint.mul(priceAverage, 1 ether));

            emit LongTwapUpdated(priceCumulativeLastLong, blockTimestampLastLong, priceAverageLastLong);
        }

        return priceAverageLastLong;
    }

    function getCurrentShortTwap() public view returns (uint256) {
        (uint price0Cumulative, uint price1Cumulative, uint32 blockTimestamp) = 
            UniswapV2OracleLibrary.currentCumulativePrices(uniswapPair);
        uint32 timeElapsed = blockTimestamp - blockTimestampLast;

        uint256 priceCumulative = isThisToken0 ? price1Cumulative : price0Cumulative;

        FixedPoint.uq112x112 memory priceAverage = FixedPoint.uq112x112(
            uint224((priceCumulative - priceCumulativeLast) / timeElapsed)
        );

        return FixedPoint.decode144(FixedPoint.mul(priceAverage, 1 ether));
    }

    function getLastShortTwap() public view returns (uint256) {
        return priceAverageLast;
    }

    function getLastLongTwap() public view returns (uint256) {
        return priceAverageLastLong;
    }
    
    function _updateShortTwap() internal virtual returns (uint256) {
        (uint price0Cumulative, uint price1Cumulative, uint32 blockTimestamp) = 
            UniswapV2OracleLibrary.currentCumulativePrices(uniswapPair);
        uint32 timeElapsed = blockTimestamp - blockTimestampLast; // overflow is desired

        if (timeElapsed > minDeltaTwapShort) {
            uint256 priceCumulative = isThisToken0 ? price1Cumulative : price0Cumulative;

            FixedPoint.uq112x112 memory priceAverage = FixedPoint.uq112x112(
                uint224((priceCumulative - priceCumulativeLast) / timeElapsed)
            );

            priceCumulativeLast = priceCumulative;
            blockTimestampLast = blockTimestamp;

            priceAverageLast = FixedPoint.decode144(FixedPoint.mul(priceAverage, 1 ether));

            emit TwapUpdated(priceCumulativeLast, blockTimestampLast, priceAverageLast);
        }

        return priceAverageLast;
    }

    function initializeTwap() external onlyInitialDistributionAddress {
        require(blockTimestampLast == 0, "Both TWAPS already initialized");
        (uint256 price0Cumulative, uint256 price1Cumulative, uint32 blockTimestamp) = 
            UniswapV2OracleLibrary.currentCumulativePrices(uniswapPair);

        uint256 priceCumulative = isThisToken0 ? price1Cumulative : price0Cumulative;
        
        blockTimestampLast = blockTimestamp;
        priceCumulativeLast = priceCumulative;
        priceAverageLast = INITIAL_TOKENS_PER_ETH;

        blockTimestampLastLong = blockTimestamp;
        priceCumulativeLastLong = priceCumulative;
        priceAverageLastLong = INITIAL_TOKENS_PER_ETH;
    }

    function claimBonusTokens() public {

        uint256 bonusTokens = getBonusAmount(msg.sender);

        require(bonusTokens > 0, "There are no bonus tokens to be claimed");
        require(getBonusUnlockTime(msg.sender) <= block.number, "The token release time has not been reached yet.");
        require(balanceOf(address(this)) > bonusTokens, "The contract can't afford to pay this bonus.");


        _removeTimelockedBonus(msg.sender);

        emit BonusBalanceUpdated(msg.sender, getBonusAmount(msg.sender));

        _transfer(address(this), msg.sender, bonusTokens);

        emit BuyerBonusPaid(msg.sender, bonusTokens);
    }

    function setUniswapPair(address newUniswapPair) public onlyOwner {
        setExchangeAddress(uniswapPair, false);

        uniswapPair = newUniswapPair;

        setExchangeAddress(uniswapPair, true);
    }

    function calculateCurrentNitroRate(bool isBuy) public view returns (uint256) {
        uint256 currentRealTimePrice = getLastShortTwap(); 
        
        uint256 currentTwap = getLastLongTwap();
        uint256 nitro;

        if(currentRealTimePrice > currentTwap){
            nitro = (currentRealTimePrice.sub(currentTwap).mul(scaleFactor).div(currentTwap))*scaleFactor.div(scaleFactor);
        }
        else{
            nitro = (currentTwap.sub(currentRealTimePrice).mul(scaleFactor).div(currentTwap))*scaleFactor.div(scaleFactor);
        }

        uint256 refBuyBonus = (maxBuyBonus()*scaleFactor.div(100));
        uint256 refMaxSell  = (maxSellRemoval()*scaleFactor.div(100));
        if(isBuy && nitro > refBuyBonus){
            return refBuyBonus;
        }else if (!isBuy && nitro > refMaxSell){
            return refMaxSell;
        }
        return nitro;
    }
}