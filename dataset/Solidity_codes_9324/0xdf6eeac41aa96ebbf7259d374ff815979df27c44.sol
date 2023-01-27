



pragma solidity >=0.6.0 <0.8.0;

library SafeMathUpgradeable {

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



pragma solidity =0.6.6;
library BasisPoints {

    using SafeMathUpgradeable for uint;

    uint constant private BASIS_POINTS = 10000;

    function mulBP(uint amt, uint bp) internal pure returns (uint) {

        if (amt == 0) return 0;
        return amt.mul(bp).div(BASIS_POINTS);
    }

    function divBP(uint amt, uint bp) internal pure returns (uint) {

        require(bp > 0, "Cannot divide by zero.");
        if (amt == 0) return 0;
        return amt.mul(BASIS_POINTS).div(bp);
    }

    function addBP(uint amt, uint bp) internal pure returns (uint) {

        if (amt == 0) return 0;
        if (bp == 0) return amt;
        return amt.add(mulBP(amt, bp));
    }

    function subBP(uint amt, uint bp) internal pure returns (uint) {

        if (amt == 0) return 0;
        if (bp == 0) return amt;
        return amt.sub(mulBP(amt, bp));
    }
}



pragma solidity =0.6.6;

interface ILiftoffEngine {

    function launchToken(
        uint256 _startTime,
        uint256 _endTime,
        uint256 _softCap,
        uint256 _hardCap,
        uint256 _totalSupply,
        string calldata _name,
        string calldata _symbol,
        address _projectDev
    ) external returns (uint256 tokenId);


    function igniteEth(uint256 _tokenSaleId) external payable;


    function ignite(
        uint256 _tokenSaleId,
        address _for,
        uint256 _amountXEth
    ) external;


    function undoIgnite(uint256 _tokenSaleId) external;


    function claimReward(uint256 _tokenSaleId, address _for) external;


    function spark(uint256 _tokenSaleId) external;


    function claimRefund(uint256 _tokenSaleId, address _for) external;


    function getTokenSale(uint256 _tokenSaleId)
        external
        view
        returns (
            uint256 startTime,
            uint256 endTime,
            uint256 softCap,
            uint256 hardCap,
            uint256 totalIgnited,
            uint256 totalSupply,
            uint256 rewardSupply,
            address projectDev,
            address deployed,
            bool isSparked
        );


    function getTokenSaleForInsurance(uint256 _tokenSaleId)
        external
        view
        returns (
            uint256 totalIgnited,
            uint256 rewardSupply,
            address projectDev,
            address pair,
            address deployed
        );


    function getTokenSaleProjectDev(uint256 _tokenSaleId)
        external
        view
        returns (address projectDev);


    function getTokenSaleStartTime(uint256 _tokenSaleId)
        external
        view
        returns (uint256 startTime);


    function isSparkReady(
        uint256 endTime,
        uint256 totalIgnited,
        uint256 hardCap,
        uint256 softCap,
        bool isSparked
    ) external view returns (bool);


    function isIgniting(
        uint256 startTime,
        uint256 endTime,
        uint256 totalIgnited,
        uint256 hardCap
    ) external view returns (bool);


    function isRefunding(
        uint256 endTime,
        uint256 softCap,
        uint256 totalIgnited
    ) external view returns (bool);


    function getReward(
        uint256 ignited,
        uint256 rewardSupply,
        uint256 totalIgnited
    ) external pure returns (uint256 reward);

}



pragma solidity =0.6.6;

interface ILiftoffSettings {

    function setAllUints(
        uint256 _ethXLockBP,
        uint256 _tokenUserBP,
        uint256 _insurancePeriod,
        uint256 _baseFeeBP,
        uint256 _ethBuyBP,
        uint256 _projectDevBP,
        uint256 _mainFeeBP,
        uint256 _lidPoolBP
    ) external;


    function setAllAddresses(
        address _liftoffInsurance,
        address _liftoffRegistration,
        address _liftoffEngine,
        address _liftoffPartnerships,
        address _xEth,
        address _xLocker,
        address _uniswapRouter,
        address _lidTreasury,
        address _lidPoolManager
    ) external;


    function setEthXLockBP(uint256 _val) external;


    function getEthXLockBP() external view returns (uint256);


    function setTokenUserBP(uint256 _val) external;


    function getTokenUserBP() external view returns (uint256);


    function setLiftoffInsurance(address _val) external;


    function getLiftoffInsurance() external view returns (address);


    function setLiftoffRegistration(address _val) external;


    function getLiftoffRegistration() external view returns (address);


    function setLiftoffEngine(address _val) external;


    function getLiftoffEngine() external view returns (address);


    function setLiftoffPartnerships(address _val) external;


    function getLiftoffPartnerships() external view returns (address);


    function setXEth(address _val) external;


    function getXEth() external view returns (address);


    function setXLocker(address _val) external;


    function getXLocker() external view returns (address);


    function setUniswapRouter(address _val) external;


    function getUniswapRouter() external view returns (address);


    function setInsurancePeriod(uint256 _val) external;


    function getInsurancePeriod() external view returns (uint256);


    function setLidTreasury(address _val) external;


    function getLidTreasury() external view returns (address);


    function setLidPoolManager(address _val) external;


    function getLidPoolManager() external view returns (address);


    function setXethBP(
        uint256 _baseFeeBP,
        uint256 _ethBuyBP,
        uint256 _projectDevBP,
        uint256 _mainFeeBP,
        uint256 _lidPoolBP
    ) external;


    function getBaseFeeBP() external view returns (uint256);


    function getEthBuyBP() external view returns (uint256);


    function getProjectDevBP() external view returns (uint256);


    function getMainFeeBP() external view returns (uint256);


    function getLidPoolBP() external view returns (uint256);

}



pragma solidity =0.6.6;

interface ILiftoffInsurance {

    function register(uint256 _tokenSaleId) external;


    function redeem(uint256 _tokenSaleId, uint256 _amount) external;


    function claim(uint256 _tokenSaleId) external;


    function createInsurance(uint256 _tokenSaleId) external;


    function canCreateInsurance(
        bool insuranceIsInitialized,
        bool tokenIsRegistered
    ) external pure returns (bool);


    function getTotalTokenClaimable(
        uint256 baseTokenLidPool,
        uint256 cycles,
        uint256 claimedTokenLidPool
    ) external pure returns (uint256);


    function getTotalXethClaimable(
        uint256 totalIgnited,
        uint256 redeemedXEth,
        uint256 claimedXEth,
        uint256 cycles
    ) external pure returns (uint256);


    function getRedeemValue(uint256 amount, uint256 tokensPerEthWad)
        external
        pure
        returns (uint256);


    function isInsuranceExhausted(
        uint256 currentTime,
        uint256 startTime,
        uint256 insurancePeriod,
        uint256 xEthValue,
        uint256 baseXEth,
        uint256 redeemedXEth,
        uint256 claimedXEth,
        bool isUnwound
    ) external pure returns (bool);


    function getTokenInsuranceUints(uint256 _tokenSaleId)
        external
        view
        returns (
            uint256 startTime,
            uint256 totalIgnited,
            uint256 tokensPerEthWad,
            uint256 baseXEth,
            uint256 baseTokenLidPool,
            uint256 redeemedXEth,
            uint256 claimedXEth,
            uint256 claimedTokenLidPool
        );


    function getTokenInsuranceOthers(uint256 _tokenSaleId)
        external
        view
        returns (
            address pair,
            address deployed,
            address projectDev,
            bool isUnwound,
            bool hasBaseFeeClaimed
        );

}



pragma solidity >=0.5.0;

interface IERC20 {

    event Approval(address indexed owner, address indexed spender, uint value);
    event Transfer(address indexed from, address indexed to, uint value);

    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);

    function totalSupply() external view returns (uint);

    function balanceOf(address owner) external view returns (uint);

    function allowance(address owner, address spender) external view returns (uint);


    function approve(address spender, uint value) external returns (bool);

    function transfer(address to, uint value) external returns (bool);

    function transferFrom(address from, address to, uint value) external returns (bool);

}



pragma solidity =0.6.6;
interface IXEth is IERC20 {

    function deposit() external payable;


    function xlockerMint(uint256 wad, address dst) external;


    function withdraw(uint256 wad) external;


    function permit(
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external;


    function nonces(address owner) external view returns (uint256);


    event Deposit(address indexed dst, uint256 wad);
    event Withdrawal(address indexed src, uint256 wad);
    event XlockerMint(uint256 wad, address dst);
}



pragma solidity =0.6.6;

interface IXLocker {

    function launchERC20(
        string calldata name,
        string calldata symbol,
        uint256 wadToken,
        uint256 wadXeth
    ) external returns (address token_, address pair_);


    function launchERC20TransferTax(
        string calldata name,
        string calldata symbol,
        uint256 wadToken,
        uint256 wadXeth,
        uint256 taxBips,
        address taxMan
    ) external returns (address token_, address pair_);


    function launchERC20Blacklist(
        string calldata name,
        string calldata symbol,
        uint256 wadToken,
        uint256 wadXeth,
        address blacklistManager
    ) external returns (address token_, address pair_);


    function setBlacklistUniswapBuys(
        address pair,
        address token,
        bool isBlacklisted
    ) external;

}



pragma solidity >=0.5.0;

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



pragma solidity =0.6.6;


library SafeMath {

    function add(uint x, uint y) internal pure returns (uint z) {

        require((z = x + y) >= x, 'ds-math-add-overflow');
    }

    function sub(uint x, uint y) internal pure returns (uint z) {

        require((z = x - y) <= x, 'ds-math-sub-underflow');
    }

    function mul(uint x, uint y) internal pure returns (uint z) {

        require(y == 0 || (z = x * y) / y == x, 'ds-math-mul-overflow');
    }
}



pragma solidity >=0.5.0;

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

    function getReserves(address factory, address tokenA, address tokenB) internal view returns (uint reserveA, uint reserveB) {

        (address token0,) = sortTokens(tokenA, tokenB);
        (uint reserve0, uint reserve1,) = IUniswapV2Pair(pairFor(factory, tokenA, tokenB)).getReserves();
        (reserveA, reserveB) = tokenA == token0 ? (reserve0, reserve1) : (reserve1, reserve0);
    }

    function quote(uint amountA, uint reserveA, uint reserveB) internal pure returns (uint amountB) {

        require(amountA > 0, 'UniswapV2Library: INSUFFICIENT_AMOUNT');
        require(reserveA > 0 && reserveB > 0, 'UniswapV2Library: INSUFFICIENT_LIQUIDITY');
        amountB = amountA.mul(reserveB) / reserveA;
    }

    function getAmountOut(uint amountIn, uint reserveIn, uint reserveOut) internal pure returns (uint amountOut) {

        require(amountIn > 0, 'UniswapV2Library: INSUFFICIENT_INPUT_AMOUNT');
        require(reserveIn > 0 && reserveOut > 0, 'UniswapV2Library: INSUFFICIENT_LIQUIDITY');
        uint amountInWithFee = amountIn.mul(997);
        uint numerator = amountInWithFee.mul(reserveOut);
        uint denominator = reserveIn.mul(1000).add(amountInWithFee);
        amountOut = numerator / denominator;
    }

    function getAmountIn(uint amountOut, uint reserveIn, uint reserveOut) internal pure returns (uint amountIn) {

        require(amountOut > 0, 'UniswapV2Library: INSUFFICIENT_OUTPUT_AMOUNT');
        require(reserveIn > 0 && reserveOut > 0, 'UniswapV2Library: INSUFFICIENT_LIQUIDITY');
        uint numerator = reserveIn.mul(amountOut).mul(1000);
        uint denominator = reserveOut.sub(amountOut).mul(997);
        amountIn = (numerator / denominator).add(1);
    }

    function getAmountsOut(address factory, uint amountIn, address[] memory path) internal view returns (uint[] memory amounts) {

        require(path.length >= 2, 'UniswapV2Library: INVALID_PATH');
        amounts = new uint[](path.length);
        amounts[0] = amountIn;
        for (uint i; i < path.length - 1; i++) {
            (uint reserveIn, uint reserveOut) = getReserves(factory, path[i], path[i + 1]);
            amounts[i + 1] = getAmountOut(amounts[i], reserveIn, reserveOut);
        }
    }

    function getAmountsIn(address factory, uint amountOut, address[] memory path) internal view returns (uint[] memory amounts) {

        require(path.length >= 2, 'UniswapV2Library: INVALID_PATH');
        amounts = new uint[](path.length);
        amounts[amounts.length - 1] = amountOut;
        for (uint i = path.length - 1; i > 0; i--) {
            (uint reserveIn, uint reserveOut) = getReserves(factory, path[i - 1], path[i]);
            amounts[i - 1] = getAmountIn(amounts[i], reserveIn, reserveOut);
        }
    }
}




pragma solidity >=0.6.0 <0.8.0;

interface IERC20Upgradeable {

    function totalSupply() external view returns (uint256);


    function balanceOf(address account) external view returns (uint256);


    function transfer(address recipient, uint256 amount) external returns (bool);


    function allowance(address owner, address spender) external view returns (uint256);


    function approve(address spender, uint256 amount) external returns (bool);


    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);


    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}




pragma solidity >=0.6.0 <0.8.0;

library MathUpgradeable {

    function max(uint256 a, uint256 b) internal pure returns (uint256) {

        return a >= b ? a : b;
    }

    function min(uint256 a, uint256 b) internal pure returns (uint256) {

        return a < b ? a : b;
    }

    function average(uint256 a, uint256 b) internal pure returns (uint256) {

        return (a / 2) + (b / 2) + ((a % 2 + b % 2) / 2);
    }
}




pragma solidity >=0.4.24 <0.8.0;


abstract contract Initializable {

    bool private _initialized;

    bool private _initializing;

    modifier initializer() {
        require(_initializing || _isConstructor() || !_initialized, "Initializable: contract is already initialized");

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

    function _isConstructor() private view returns (bool) {
        address self = address(this);
        uint256 cs;
        assembly { cs := extcodesize(self) }
        return cs == 0;
    }
}




pragma solidity >=0.6.0 <0.8.0;

abstract contract ContextUpgradeable is Initializable {
    function __Context_init() internal initializer {
        __Context_init_unchained();
    }

    function __Context_init_unchained() internal initializer {
    }
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
    uint256[50] private __gap;
}




pragma solidity >=0.6.0 <0.8.0;


abstract contract PausableUpgradeable is Initializable, ContextUpgradeable {
    event Paused(address account);

    event Unpaused(address account);

    bool private _paused;

    function __Pausable_init() internal initializer {
        __Context_init_unchained();
        __Pausable_init_unchained();
    }

    function __Pausable_init_unchained() internal initializer {
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
    uint256[49] private __gap;
}




pragma solidity >=0.6.0 <0.8.0;


abstract contract OwnableUpgradeable is Initializable, ContextUpgradeable {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    function __Ownable_init() internal initializer {
        __Context_init_unchained();
        __Ownable_init_unchained();
    }

    function __Ownable_init_unchained() internal initializer {
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
    uint256[49] private __gap;
}



pragma solidity =0.6.6;
contract LiftoffEngine is
    ILiftoffEngine,
    Initializable,
    OwnableUpgradeable,
    PausableUpgradeable
{

    using BasisPoints for uint256;
    using SafeMathUpgradeable for uint256;
    using MathUpgradeable for uint256;

    struct TokenSale {
        uint256 startTime;
        uint256 endTime;
        uint256 softCap;
        uint256 hardCap;
        uint256 totalIgnited;
        uint256 totalSupply;
        uint256 rewardSupply;
        address projectDev;
        address deployed;
        address pair;
        bool isSparked;
        string name;
        string symbol;
        mapping(address => Ignitor) ignitors;
    }

    struct Ignitor {
        uint256 ignited;
        bool hasClaimed;
        bool hasRefunded;
    }

    ILiftoffSettings public liftoffSettings;

    mapping(uint256 => TokenSale) public tokens;
    uint256 public totalTokenSales;

    event LaunchToken(
        uint256 tokenId,
        uint256 startTime,
        uint256 endTime,
        uint256 softCap,
        uint256 hardCap,
        uint256 totalSupply,
        string name,
        string symbol,
        address dev
    );
    event Spark(uint256 tokenId, address deployed, uint256 rewardSupply);
    event Ignite(uint256 tokenId, address igniter, uint256 toIgnite);
    event ClaimReward(uint256 tokenId, address igniter, uint256 reward);
    event ClaimRefund(uint256 tokenId, address igniter);
    event UpdateEndTime(uint256 tokenId, uint256 endTime);
    event UndoIgnite(
        uint256 _tokenSaleId,
        address igniter,
        uint256 wadUnIgnited
    );

    function initialize(ILiftoffSettings _liftoffSettings)
        external
        initializer
    {

        OwnableUpgradeable.__Ownable_init();
        PausableUpgradeable.__Pausable_init();
        liftoffSettings = _liftoffSettings;
    }

    function setLiftoffSettings(ILiftoffSettings _liftoffSettings)
        public
        onlyOwner
    {

        liftoffSettings = _liftoffSettings;
    }

    function updateEndTime(uint256 _delta, uint256 _tokenId)
        external
        onlyOwner
    {

        TokenSale storage tokenSale = tokens[_tokenId];
        uint256 endTime = tokenSale.startTime.add(_delta);
        tokenSale.endTime = endTime;
        emit UpdateEndTime(_tokenId, endTime);
    }

    function launchToken(
        uint256 _startTime,
        uint256 _endTime,
        uint256 _softCap,
        uint256 _hardCap,
        uint256 _totalSupply,
        string calldata _name,
        string calldata _symbol,
        address _projectDev
    ) external override whenNotPaused returns (uint256 tokenId) {

        require(
            msg.sender == liftoffSettings.getLiftoffRegistration(),
            "Sender must be LiftoffRegistration"
        );
        require(_endTime > _startTime, "Must end after start");
        require(_startTime > now, "Must start in the future");
        require(_hardCap >= _softCap, "Hardcap must be at least softCap");
        require(_softCap >= 10 ether, "Softcap must be at least 10 ether");
        require(
            _totalSupply >= 1000 * (10**18),
            "TotalSupply must be at least 1000 tokens"
        );
        require(
            _totalSupply < (10**12) * (10**18),
            "TotalSupply must be less than 1 trillion tokens"
        );

        tokenId = totalTokenSales;

        tokens[tokenId] = TokenSale({
            startTime: _startTime,
            endTime: _endTime,
            softCap: _softCap,
            hardCap: _hardCap,
            totalIgnited: 0,
            totalSupply: _totalSupply,
            rewardSupply: 0,
            projectDev: _projectDev,
            deployed: address(0),
            pair: address(0),
            name: _name,
            symbol: _symbol,
            isSparked: false
        });

        totalTokenSales++;

        emit LaunchToken(
            tokenId,
            _startTime,
            _endTime,
            _softCap,
            _hardCap,
            _totalSupply,
            _name,
            _symbol,
            _projectDev
        );
    }

    function igniteEth(uint256 _tokenSaleId)
        external
        payable
        override
        whenNotPaused
    {

        TokenSale storage tokenSale = tokens[_tokenSaleId];
        require(
            isIgniting(
                tokenSale.startTime,
                tokenSale.endTime,
                tokenSale.totalIgnited,
                tokenSale.hardCap
            ),
            "Not igniting."
        );
        uint256 toIgnite =
            getAmountToIgnite(
                msg.value,
                tokenSale.hardCap,
                tokenSale.totalIgnited
            );

        IXEth(liftoffSettings.getXEth()).deposit{value: toIgnite}();
        _addIgnite(tokenSale, msg.sender, toIgnite);

        msg.sender.transfer(msg.value.sub(toIgnite));

        emit Ignite(_tokenSaleId, msg.sender, toIgnite);
    }

    function ignite(
        uint256 _tokenSaleId,
        address _for,
        uint256 _amountXEth
    ) external override whenNotPaused {

        TokenSale storage tokenSale = tokens[_tokenSaleId];
        require(
            isIgniting(
                tokenSale.startTime,
                tokenSale.endTime,
                tokenSale.totalIgnited,
                tokenSale.hardCap
            ),
            "Not igniting."
        );
        uint256 toIgnite =
            getAmountToIgnite(
                _amountXEth,
                tokenSale.hardCap,
                tokenSale.totalIgnited
            );

        require(
            IXEth(liftoffSettings.getXEth()).transferFrom(
                msg.sender,
                address(this),
                toIgnite
            ),
            "Transfer Failed"
        );
        _addIgnite(tokenSale, _for, toIgnite);

        emit Ignite(_tokenSaleId, _for, toIgnite);
    }

    function undoIgnite(uint256 _tokenSaleId) external override whenNotPaused {

        TokenSale storage tokenSale = tokens[_tokenSaleId];
        require(
            isIgniting(
                tokenSale.startTime,
                tokenSale.endTime,
                tokenSale.totalIgnited,
                tokenSale.hardCap
            ),
            "Not igniting."
        );
        uint256 wadToUndo = tokenSale.ignitors[msg.sender].ignited;
        tokenSale.ignitors[msg.sender].ignited = 0;
        delete tokenSale.ignitors[msg.sender];
        tokenSale.totalIgnited = tokenSale.totalIgnited.sub(wadToUndo);
        require(
            IXEth(liftoffSettings.getXEth()).transfer(msg.sender, wadToUndo),
            "Transfer failed"
        );
        emit UndoIgnite(_tokenSaleId, msg.sender, wadToUndo);
    }

    function claimReward(uint256 _tokenSaleId, address _for)
        external
        override
        whenNotPaused
    {

        TokenSale storage tokenSale = tokens[_tokenSaleId];
        Ignitor storage ignitor = tokenSale.ignitors[_for];

        require(tokenSale.isSparked, "Token must have been sparked.");
        require(!ignitor.hasClaimed, "Ignitor has already claimed");

        uint256 reward =
            getReward(
                ignitor.ignited,
                tokenSale.rewardSupply,
                tokenSale.totalIgnited
            );
        require(reward > 0, "Must have some rewards to claim.");

        ignitor.hasClaimed = true;
        require(
            IERC20(tokenSale.deployed).transfer(_for, reward),
            "Transfer failed"
        );

        emit ClaimReward(_tokenSaleId, _for, reward);
    }

    function spark(uint256 _tokenSaleId) external override whenNotPaused {

        TokenSale storage tokenSale = tokens[_tokenSaleId];

        require(
            isSparkReady(
                tokenSale.endTime,
                tokenSale.totalIgnited,
                tokenSale.hardCap,
                tokenSale.softCap,
                tokenSale.isSparked
            ),
            "Not spark ready"
        );

        tokenSale.isSparked = true;

        uint256 xEthBuy = _deployViaXLock(tokenSale);
        _allocateTokensPostDeploy(tokenSale);
        _insuranceRegistration(tokenSale, _tokenSaleId, xEthBuy);

        emit Spark(_tokenSaleId, tokenSale.deployed, tokenSale.rewardSupply);
    }

    function claimRefund(uint256 _tokenSaleId, address _for)
        external
        override
        whenNotPaused
    {

        TokenSale storage tokenSale = tokens[_tokenSaleId];
        Ignitor storage ignitor = tokenSale.ignitors[_for];

        require(
            isRefunding(
                tokenSale.endTime,
                tokenSale.softCap,
                tokenSale.totalIgnited
            ),
            "Not refunding"
        );

        require(!ignitor.hasRefunded, "Ignitor has already refunded");
        ignitor.hasRefunded = true;

        require(
            IXEth(liftoffSettings.getXEth()).transfer(_for, ignitor.ignited),
            "Transfer failed"
        );

        emit ClaimRefund(_tokenSaleId, _for);
    }

    function getTokenSale(uint256 _tokenSaleId)
        external
        view
        override
        returns (
            uint256 startTime,
            uint256 endTime,
            uint256 softCap,
            uint256 hardCap,
            uint256 totalIgnited,
            uint256 totalSupply,
            uint256 rewardSupply,
            address projectDev,
            address deployed,
            bool isSparked
        )
    {

        TokenSale storage tokenSale = tokens[_tokenSaleId];

        startTime = tokenSale.startTime;
        endTime = tokenSale.endTime;
        softCap = tokenSale.softCap;
        hardCap = tokenSale.hardCap;
        totalIgnited = tokenSale.totalIgnited;
        totalSupply = tokenSale.totalSupply;
        rewardSupply = tokenSale.rewardSupply;
        projectDev = tokenSale.projectDev;
        deployed = tokenSale.deployed;
        isSparked = tokenSale.isSparked;
    }

    function getTokenSaleForInsurance(uint256 _tokenSaleId)
        external
        view
        override
        returns (
            uint256 totalIgnited,
            uint256 rewardSupply,
            address projectDev,
            address pair,
            address deployed
        )
    {

        TokenSale storage tokenSale = tokens[_tokenSaleId];
        totalIgnited = tokenSale.totalIgnited;
        rewardSupply = tokenSale.rewardSupply;
        projectDev = tokenSale.projectDev;
        pair = tokenSale.pair;
        deployed = tokenSale.deployed;
    }

    function getTokenSaleProjectDev(uint256 _tokenSaleId)
        external
        view
        override
        returns (address projectDev)
    {

        projectDev = tokens[_tokenSaleId].projectDev;
    }

    function getTokenSaleStartTime(uint256 _tokenSaleId)
        external
        view
        override
        returns (uint256 startTime)
    {

        startTime = tokens[_tokenSaleId].startTime;
    }

    function isSparkReady(
        uint256 endTime,
        uint256 totalIgnited,
        uint256 hardCap,
        uint256 softCap,
        bool isSparked
    ) public view override returns (bool) {

        if (
            (now <= endTime && totalIgnited < hardCap) ||
            totalIgnited < softCap ||
            isSparked
        ) {
            return false;
        } else {
            return true;
        }
    }

    function isIgniting(
        uint256 startTime,
        uint256 endTime,
        uint256 totalIgnited,
        uint256 hardCap
    ) public view override returns (bool) {

        if (now < startTime || now > endTime || totalIgnited >= hardCap) {
            return false;
        } else {
            return true;
        }
    }

    function isRefunding(
        uint256 endTime,
        uint256 softCap,
        uint256 totalIgnited
    ) public view override returns (bool) {

        if (totalIgnited >= softCap || now <= endTime) {
            return false;
        } else {
            return true;
        }
    }

    function getReward(
        uint256 ignited,
        uint256 rewardSupply,
        uint256 totalIgnited
    ) public pure override returns (uint256 reward) {

        return ignited.mul(rewardSupply).div(totalIgnited);
    }

    function getAmountToIgnite(
        uint256 amountXEth,
        uint256 hardCap,
        uint256 totalIgnited
    ) public pure returns (uint256 toIgnite) {

        uint256 maxIgnite = hardCap.sub(totalIgnited);

        if (maxIgnite < amountXEth) {
            toIgnite = maxIgnite;
        } else {
            toIgnite = amountXEth;
        }
    }

    function _deployViaXLock(TokenSale storage tokenSale)
        internal
        returns (uint256 xEthBuy)
    {

        uint256 xEthLocked =
            tokenSale.totalIgnited.mulBP(liftoffSettings.getEthXLockBP());
        xEthBuy = tokenSale.totalIgnited.mulBP(liftoffSettings.getEthBuyBP());

        (address deployed, address pair) =
            IXLocker(liftoffSettings.getXLocker()).launchERC20Blacklist(
                tokenSale.name,
                tokenSale.symbol,
                tokenSale.totalSupply,
                xEthLocked,
                liftoffSettings.getLiftoffInsurance()
            );

        _swapExactXEthForTokens(
            xEthBuy,
            IERC20(liftoffSettings.getXEth()),
            IUniswapV2Pair(pair)
        );

        tokenSale.pair = pair;
        tokenSale.deployed = deployed;

        return xEthBuy;
    }

    function _allocateTokensPostDeploy(TokenSale storage tokenSale) internal {

        IERC20 deployed = IERC20(tokenSale.deployed);
        uint256 balance = deployed.balanceOf(address(this));
        tokenSale.rewardSupply = balance.mulBP(
            liftoffSettings.getTokenUserBP()
        );
    }

    function _insuranceRegistration(
        TokenSale storage tokenSale,
        uint256 _tokenSaleId,
        uint256 _xEthBuy
    ) internal {

        IERC20 deployed = IERC20(tokenSale.deployed);
        uint256 toInsurance =
            deployed.balanceOf(address(this)).sub(tokenSale.rewardSupply);
        address liftoffInsurance = liftoffSettings.getLiftoffInsurance();
        deployed.transfer(liftoffInsurance, toInsurance);
        IXEth(liftoffSettings.getXEth()).transfer(
            liftoffInsurance,
            tokenSale.totalIgnited.sub(_xEthBuy)
        );

        ILiftoffInsurance(liftoffInsurance).register(_tokenSaleId);
    }

    function _addIgnite(
        TokenSale storage tokenSale,
        address _for,
        uint256 toIgnite
    ) internal {

        Ignitor storage ignitor = tokenSale.ignitors[_for];
        ignitor.ignited = ignitor.ignited.add(toIgnite);
        tokenSale.totalIgnited = tokenSale.totalIgnited.add(toIgnite);
    }

    function _swapExactXEthForTokens(
        uint256 amountIn,
        IERC20 xEth,
        IUniswapV2Pair pair
    ) internal {

        (uint256 reserve0, uint256 reserve1, ) = pair.getReserves();
        bool token0IsXEth = pair.token0() == address(xEth);
        (uint256 reserveIn, uint256 reserveOut) =
            token0IsXEth ? (reserve0, reserve1) : (reserve1, reserve0);
        uint256 amountOut =
            UniswapV2Library.getAmountOut(amountIn, reserveIn, reserveOut);
        require(xEth.transfer(address(pair), amountIn), "Transfer failed");
        (uint256 amount0Out, uint256 amount1Out) =
            token0IsXEth ? (uint256(0), amountOut) : (amountOut, uint256(0));
        pair.swap(amount0Out, amount1Out, address(this), new bytes(0));
    }
}



pragma solidity =0.6.6;

interface ILiftoffPartnerships {

    function setPartner(
        uint256 _ID,
        address _controller,
        string calldata _IPFSConfigHash
    ) external;


    function requestPartnership(
        uint256 _partnerId,
        uint256 _tokenSaleId,
        uint256 _feeBP
    ) external;


    function acceptPartnership(uint256 _tokenSaleId, uint8 _requestId) external;


    function cancelPartnership(uint256 _tokenSaleId, uint8 _requestId) external;


    function addFees(uint256 _tokenSaleId, uint256 _wad) external;


    function getTotalBP(uint256 _tokenSaleId)
        external
        view
        returns (uint256 totalBP);


    function getTokenSalePartnerships(uint256 _tokenSaleId)
        external
        view
        returns (uint8 totalPartnerships, uint256 totalBPForPartnerships);


    function getPartnership(uint256 _tokenSaleId, uint8 _partnershipId)
        external
        view
        returns (
            uint256 partnerId,
            uint256 tokenSaleId,
            uint256 feeBP,
            bool isApproved
        );

}



pragma solidity =0.6.6;
contract LiftoffInsurance is
    ILiftoffInsurance,
    Initializable,
    OwnableUpgradeable,
    PausableUpgradeable
{

    using BasisPoints for uint256;
    using SafeMathUpgradeable for uint256;
    using MathUpgradeable for uint256;

    struct TokenInsurance {
        uint256 startTime;
        uint256 totalIgnited;
        uint256 tokensPerEthWad;
        uint256 baseXEth;
        uint256 baseTokenLidPool;
        uint256 redeemedXEth;
        uint256 claimedXEth;
        uint256 claimedTokenLidPool;
        address pair;
        address deployed;
        address projectDev;
        bool isUnwound;
        bool hasBaseFeeClaimed;
    }

    ILiftoffSettings public liftoffSettings;

    mapping(uint256 => TokenInsurance) public tokenInsurances;
    mapping(uint256 => bool) public tokenIsRegistered;
    mapping(uint256 => bool) public insuranceIsInitialized;

    event Register(uint256 tokenId);
    event CreateInsurance(
        uint256 tokenId,
        uint256 startTime,
        uint256 tokensPerEthWad,
        uint256 baseXEth,
        uint256 baseTokenLidPool,
        uint256 totalIgnited,
        address deployed,
        address dev
    );
    event ClaimBaseFee(uint256 tokenId, uint256 baseFee);
    event Claim(uint256 tokenId, uint256 xEthClaimed, uint256 tokenClaimed);
    event Redeem(uint256 tokenId, uint256 redeemEth);

    function initialize(ILiftoffSettings _liftoffSettings)
        external
        initializer
    {

        OwnableUpgradeable.__Ownable_init();
        PausableUpgradeable.__Pausable_init();
        liftoffSettings = _liftoffSettings;
    }

    function setLiftoffSettings(ILiftoffSettings _liftoffSettings)
        public
        onlyOwner
    {

        liftoffSettings = _liftoffSettings;
    }

    function register(uint256 _tokenSaleId) external override {

        address liftoffEngine = liftoffSettings.getLiftoffEngine();
        require(msg.sender == liftoffEngine, "Sender must be Liftoff Engine");
        require(!tokenIsRegistered[_tokenSaleId], "Token already registered");
        tokenIsRegistered[_tokenSaleId] = true;

        emit Register(_tokenSaleId);
    }

    function redeem(uint256 _tokenSaleId, uint256 _amount) external override {

        TokenInsurance storage tokenInsurance = tokenInsurances[_tokenSaleId];
        require(
            insuranceIsInitialized[_tokenSaleId],
            "Insurance not initialized"
        );

        IERC20 token = IERC20(tokenInsurance.deployed);
        IERC20 xeth = IXEth(liftoffSettings.getXEth());

        uint256 xEthValue =
            _pullTokensForRedeem(tokenInsurance, token, _amount);

        require(
            !isInsuranceExhausted(
                now,
                tokenInsurance.startTime,
                liftoffSettings.getInsurancePeriod(),
                xEthValue,
                tokenInsurance.baseXEth,
                tokenInsurance.redeemedXEth.add(xEthValue),
                tokenInsurance.claimedXEth,
                tokenInsurance.isUnwound
            ),
            "Redeem request exceeds available insurance."
        );

        if (
            now <=
            tokenInsurance.startTime.add(
                liftoffSettings.getInsurancePeriod()
            ) &&
            tokenInsurance.baseXEth < tokenInsurance.redeemedXEth.add(xEthValue)
        ) {
            tokenInsurance.isUnwound = true;
            IXLocker(liftoffSettings.getXLocker()).setBlacklistUniswapBuys(
                tokenInsurance.pair,
                address(token),
                true
            );
        }

        if (tokenInsurance.isUnwound) {
            _swapExactTokensForXEth(
                token.balanceOf(address(this)),
                token,
                IUniswapV2Pair(tokenInsurance.pair)
            );
        }
        tokenInsurance.redeemedXEth = tokenInsurance.redeemedXEth.add(
            xEthValue
        );
        require(xeth.transfer(msg.sender, xEthValue), "Transfer failed.");

        emit Redeem(_tokenSaleId, xEthValue);
    }

    function claim(uint256 _tokenSaleId) external override {

        TokenInsurance storage tokenInsurance = tokenInsurances[_tokenSaleId];
        require(
            insuranceIsInitialized[_tokenSaleId],
            "Insurance not initialized"
        );

        uint256 cycles =
            now.sub(tokenInsurance.startTime).div(
                liftoffSettings.getInsurancePeriod()
            );

        IXEth xeth = IXEth(liftoffSettings.getXEth());

        bool didBaseFeeClaim =
            _baseFeeClaim(tokenInsurance, xeth, _tokenSaleId);
        if (didBaseFeeClaim) {
            return; //If claiming base fee, ONLY claim base fee.
        }
        require(!tokenInsurance.isUnwound, "Token insurance is unwound.");

        require(cycles > 0, "Cannot claim until after first cycle ends.");

        uint256 totalXethClaimed =
            _xEthClaimDistribution(tokenInsurance, _tokenSaleId, cycles, xeth);

        uint256 totalTokenClaimed =
            _tokenClaimDistribution(tokenInsurance, cycles);

        emit Claim(_tokenSaleId, totalXethClaimed, totalTokenClaimed);
    }

    function createInsurance(uint256 _tokenSaleId) external override {

        require(
            canCreateInsurance(
                insuranceIsInitialized[_tokenSaleId],
                tokenIsRegistered[_tokenSaleId]
            ),
            "Cannot create insurance"
        );

        insuranceIsInitialized[_tokenSaleId] = true;

        (
            uint256 totalIgnited,
            uint256 rewardSupply,
            address projectDev,
            address pair,
            address deployed
        ) =
            ILiftoffEngine(liftoffSettings.getLiftoffEngine())
                .getTokenSaleForInsurance(_tokenSaleId);

        require(
            rewardSupply.mul(1 ether).div(1000) > totalIgnited,
            "Must have at least 3 digits"
        );

        tokenInsurances[_tokenSaleId] = TokenInsurance({
            startTime: now,
            totalIgnited: totalIgnited,
            tokensPerEthWad: rewardSupply
                .mul(1 ether)
                .div(totalIgnited.subBP(liftoffSettings.getBaseFeeBP()))
                .add(1), //division error safety margin,
            baseXEth: totalIgnited.sub(
                totalIgnited.mulBP(liftoffSettings.getEthBuyBP())
            ),
            baseTokenLidPool: IERC20(deployed).balanceOf(address(this)),
            redeemedXEth: 0,
            claimedXEth: 0,
            claimedTokenLidPool: 0,
            pair: pair,
            deployed: deployed,
            projectDev: projectDev,
            isUnwound: false,
            hasBaseFeeClaimed: false
        });

        emit CreateInsurance(
            _tokenSaleId,
            tokenInsurances[_tokenSaleId].startTime,
            tokenInsurances[_tokenSaleId].tokensPerEthWad,
            tokenInsurances[_tokenSaleId].baseXEth,
            tokenInsurances[_tokenSaleId].baseTokenLidPool,
            totalIgnited,
            deployed,
            projectDev
        );
    }

    function getTokenInsuranceUints(uint256 _tokenSaleId)
        external
        view
        override
        returns (
            uint256 startTime,
            uint256 totalIgnited,
            uint256 tokensPerEthWad,
            uint256 baseXEth,
            uint256 baseTokenLidPool,
            uint256 redeemedXEth,
            uint256 claimedXEth,
            uint256 claimedTokenLidPool
        )
    {

        TokenInsurance storage t = tokenInsurances[_tokenSaleId];

        startTime = t.startTime;
        totalIgnited = t.totalIgnited;
        tokensPerEthWad = t.tokensPerEthWad;
        baseXEth = t.baseXEth;
        baseTokenLidPool = t.baseTokenLidPool;
        redeemedXEth = t.redeemedXEth;
        claimedXEth = t.claimedXEth;
        claimedTokenLidPool = t.claimedTokenLidPool;
    }

    function getTokenInsuranceOthers(uint256 _tokenSaleId)
        external
        view
        override
        returns (
            address pair,
            address deployed,
            address projectDev,
            bool isUnwound,
            bool hasBaseFeeClaimed
        )
    {

        TokenInsurance storage t = tokenInsurances[_tokenSaleId];

        pair = t.pair;
        deployed = t.deployed;
        projectDev = t.projectDev;
        isUnwound = t.isUnwound;
        hasBaseFeeClaimed = t.hasBaseFeeClaimed;
    }

    function isInsuranceExhausted(
        uint256 currentTime,
        uint256 startTime,
        uint256 insurancePeriod,
        uint256 xEthValue,
        uint256 baseXEth,
        uint256 redeemedXEth,
        uint256 claimedXEth,
        bool isUnwound
    ) public pure override returns (bool) {

        if (isUnwound) {
            return false;
        }
        if (
            currentTime > startTime.add(insurancePeriod) &&
            baseXEth < redeemedXEth.add(claimedXEth).add(xEthValue)
        ) {
            return true;
        } else {
            return false;
        }
    }

    function canCreateInsurance(
        bool _insuranceIsInitialized,
        bool _tokenIsRegistered
    ) public pure override returns (bool) {

        if (!_insuranceIsInitialized && _tokenIsRegistered) {
            return true;
        }
        return false;
    }

    function getRedeemValue(uint256 amount, uint256 tokensPerEthWad)
        public
        pure
        override
        returns (uint256)
    {

        return amount.mul(1 ether).div(tokensPerEthWad);
    }

    function getTotalTokenClaimable(
        uint256 baseTokenLidPool,
        uint256 cycles,
        uint256 claimedTokenLidPool
    ) public pure override returns (uint256) {

        uint256 totalMaxTokenClaim = baseTokenLidPool.mul(cycles).div(10);
        if (totalMaxTokenClaim > baseTokenLidPool)
            totalMaxTokenClaim = baseTokenLidPool;
        return totalMaxTokenClaim.sub(claimedTokenLidPool);
    }

    function getTotalXethClaimable(
        uint256 totalIgnited,
        uint256 redeemedXEth,
        uint256 claimedXEth,
        uint256 cycles
    ) public pure override returns (uint256) {

        if (cycles == 0) return 0;
        uint256 totalFinalClaim =
            totalIgnited.sub(redeemedXEth).sub(claimedXEth);
        uint256 totalMaxClaim = totalFinalClaim.mul(cycles).div(10); //10 periods hardcoded
        if (totalMaxClaim > totalFinalClaim) totalMaxClaim = totalFinalClaim;
        return totalMaxClaim;
    }

    function _pullTokensForRedeem(
        TokenInsurance storage tokenInsurance,
        IERC20 token,
        uint256 _amount
    ) internal returns (uint256 xEthValue) {

        uint256 initialBalance = token.balanceOf(address(this));
        require(
            token.transferFrom(msg.sender, address(this), _amount),
            "Transfer failed"
        );
        uint256 amountReceived =
            token.balanceOf(address(this)).sub(initialBalance);

        xEthValue = getRedeemValue(
            amountReceived,
            tokenInsurance.tokensPerEthWad
        );
        require(
            xEthValue >= 0.001 ether,
            "Amount must have value of at least 0.001 xETH"
        );
        return xEthValue;
    }

    function _xEthClaimDistribution(
        TokenInsurance storage tokenInsurance,
        uint256 tokenId,
        uint256 cycles,
        IERC20 xeth
    ) internal returns (uint256 totalClaimed) {

        uint256 totalClaimable =
            getTotalXethClaimable(
                tokenInsurance.totalIgnited,
                tokenInsurance.redeemedXEth,
                tokenInsurance.claimedXEth,
                cycles
            );

        tokenInsurance.claimedXEth = tokenInsurance.claimedXEth.add(
            totalClaimable
        );

        uint256 projectDevBP = liftoffSettings.getProjectDevBP();

        address liftoffPartnerships = liftoffSettings.getLiftoffPartnerships();
        (, uint256 totalBPForParnterships) =
            ILiftoffPartnerships(liftoffPartnerships).getTokenSalePartnerships(
                tokenId
            );

        if (totalBPForParnterships > 0) {
            projectDevBP = projectDevBP.sub(totalBPForParnterships);
            uint256 wad = totalClaimable.mulBP(totalBPForParnterships);
            require(
                xeth.transfer(liftoffPartnerships, wad),
                "Transfer xEth projectDev failed"
            );
            ILiftoffPartnerships(liftoffPartnerships).addFees(tokenId, wad);
        }

        require(
            xeth.transfer(
                tokenInsurance.projectDev,
                totalClaimable.mulBP(projectDevBP)
            ),
            "Transfer xEth projectDev failed"
        );
        require(
            xeth.transfer(
                liftoffSettings.getLidTreasury(),
                totalClaimable.mulBP(liftoffSettings.getMainFeeBP())
            ),
            "Transfer xEth lidTreasury failed"
        );
        require(
            xeth.transfer(
                liftoffSettings.getLidPoolManager(),
                totalClaimable.mulBP(liftoffSettings.getLidPoolBP())
            ),
            "Transfer xEth lidPoolManager failed"
        );
        return totalClaimable;
    }

    function _tokenClaimDistribution(
        TokenInsurance storage tokenInsurance,
        uint256 cycles
    ) internal returns (uint256 totalClaimed) {

        uint256 totalTokenClaimable =
            getTotalTokenClaimable(
                tokenInsurance.baseTokenLidPool,
                cycles,
                tokenInsurance.claimedTokenLidPool
            );
        tokenInsurance.claimedTokenLidPool = tokenInsurance
            .claimedTokenLidPool
            .add(totalTokenClaimable);

        require(
            IERC20(tokenInsurance.deployed).transfer(
                liftoffSettings.getLidPoolManager(),
                totalTokenClaimable
            ),
            "Transfer token to lidPoolManager failed"
        );
        return totalTokenClaimable;
    }

    function _baseFeeClaim(
        TokenInsurance storage tokenInsurance,
        IERC20 xeth,
        uint256 _tokenSaleId
    ) internal returns (bool didClaim) {

        if (!tokenInsurance.hasBaseFeeClaimed) {
            uint256 baseFee =
                tokenInsurance.totalIgnited.mulBP(
                    liftoffSettings.getBaseFeeBP() - 30 //30 BP is taken by uniswap during unwind
                );
            require(
                xeth.transfer(liftoffSettings.getLidTreasury(), baseFee),
                "Transfer failed"
            );
            tokenInsurance.hasBaseFeeClaimed = true;

            emit ClaimBaseFee(_tokenSaleId, baseFee);

            return true;
        } else {
            return false;
        }
    }

    function _swapExactTokensForXEth(
        uint256 amountIn,
        IERC20 token,
        IUniswapV2Pair pair
    ) internal {

        (uint256 reserve0, uint256 reserve1, ) = pair.getReserves();
        bool token0IsToken = pair.token0() == address(token);
        (uint256 reserveIn, uint256 reserveOut) =
            token0IsToken ? (reserve0, reserve1) : (reserve1, reserve0);
        uint256 amountOut =
            UniswapV2Library.getAmountOut(amountIn, reserveIn, reserveOut);
        require(token.transfer(address(pair), amountIn), "Transfer failed");
        (uint256 amount0Out, uint256 amount1Out) =
            token0IsToken ? (uint256(0), amountOut) : (amountOut, uint256(0));
        pair.swap(amount0Out, amount1Out, address(this), new bytes(0));
    }
}



pragma solidity =0.6.6;
contract LiftoffPartnerships is ILiftoffPartnerships, OwnableUpgradeable {

    using BasisPoints for uint256;
    using SafeMathUpgradeable for uint256;

    uint256 totalPartnerControllers;
    mapping(uint256 => address) public partnerController;
    mapping(uint256 => string) public partnerIPFSConfigHash;
    mapping(uint256 => TokenSalePartnerships) public tokenSalePartnerships;

    struct TokenSalePartnerships {
        uint8 totalPartnerships;
        uint256 totalBPForPartners;
        mapping(uint8 => Partnership) partnershipRequests;
    }

    struct Partnership {
        uint256 partnerId;
        uint256 tokenSaleId;
        uint256 feeBP;
        bool isApproved;
    }

    ILiftoffSettings public liftoffSettings;

    event SetPartner(uint256 ID, address controller, string IPFSConfigHash);
    event RequestPartnership(
        uint256 partnerId,
        uint256 tokenSaleId,
        uint256 feeBP
    );
    event AcceptPartnership(uint256 tokenSaleId, uint8 requestId);
    event CancelPartnership(uint256 tokenSaleId, uint8 requestId);
    event AddFees(uint256 tokenSaleId, uint256 wad);
    event ClaimFees(uint256 tokenSaleId, uint256 feeWad, uint8 requestId);
    event UpdatePartnershipFee(
        uint8 partnerId,
        uint256 tokenSaleId,
        uint256 feeBP
    );

    modifier onlyBeforeSaleStart(uint256 _tokenSaleId) {

        require(
            ILiftoffEngine(liftoffSettings.getLiftoffEngine())
                .getTokenSaleStartTime(_tokenSaleId) >= now,
            "Sale already started."
        );
        _;
    }

    modifier isLiftoffInsurance() {

        require(
            liftoffSettings.getLiftoffInsurance() == _msgSender(),
            "Sender must be LiftoffInsurance"
        );
        _;
    }

    modifier isOwnerOrTokenSaleDev(uint256 _tokenSaleId) {

        address projectDev =
            ILiftoffEngine(liftoffSettings.getLiftoffEngine())
                .getTokenSaleProjectDev(_tokenSaleId);
        require(
            _msgSender() == owner() || _msgSender() == projectDev,
            "Sender must be Owner or TokenSaleDev"
        );
        _;
    }

    modifier isOwnerOrPartnerController(
        uint256 _tokenSaleId,
        uint8 _requestId
    ) {

        address partner =
            partnerController[
                tokenSalePartnerships[_tokenSaleId].partnershipRequests[
                    _requestId
                ]
                    .partnerId
            ];
        require(
            _msgSender() == owner() || _msgSender() == partner,
            "Sender must be Owner or PartnerController"
        );
        _;
    }

    function initialize(ILiftoffSettings _liftoffSettings)
        external
        initializer
    {

        OwnableUpgradeable.__Ownable_init();
        liftoffSettings = _liftoffSettings;
    }

    function setLiftoffSettings(ILiftoffSettings _liftoffSettings)
        public
        onlyOwner
    {

        liftoffSettings = _liftoffSettings;
    }

    function updatePartnershipFee(
        uint8 _partnerId,
        uint256 _tokenSaleId,
        uint256 _feeBP
    ) external onlyOwner {

        TokenSalePartnerships storage partnerships =
            tokenSalePartnerships[_tokenSaleId];
        Partnership storage partnership =
            partnerships.partnershipRequests[_partnerId];
        require(partnership.isApproved, "Partnership not yet approved");
        uint256 originalFeeBP = partnership.feeBP;
        partnerships.totalBPForPartners = partnerships
            .totalBPForPartners
            .add(_feeBP)
            .sub(originalFeeBP);
        partnership.feeBP = _feeBP;
        emit UpdatePartnershipFee(_partnerId, _tokenSaleId, _feeBP);
    }

    function setPartner(
        uint256 _ID,
        address _controller,
        string calldata _IPFSConfigHash
    ) external override onlyOwner {

        require(_ID <= totalPartnerControllers, "Must increment partnerId.");
        if (_ID == totalPartnerControllers) totalPartnerControllers++;
        if (_controller == address(0x0)) {
            delete partnerController[_ID];
            delete partnerIPFSConfigHash[_ID];
        } else {
            partnerController[_ID] = _controller;
            partnerIPFSConfigHash[_ID] = _IPFSConfigHash;
        }
        emit SetPartner(_ID, _controller, _IPFSConfigHash);
    }

    function requestPartnership(
        uint256 _partnerId,
        uint256 _tokenSaleId,
        uint256 _feeBP
    )
        external
        override
        isOwnerOrTokenSaleDev(_tokenSaleId)
        onlyBeforeSaleStart(_tokenSaleId)
    {

        TokenSalePartnerships storage partnerships =
            tokenSalePartnerships[_tokenSaleId];
        partnerships.partnershipRequests[
            partnerships.totalPartnerships
        ] = Partnership({
            partnerId: _partnerId,
            tokenSaleId: _tokenSaleId,
            feeBP: _feeBP,
            isApproved: false
        });
        require(
            partnerships.totalPartnerships < 15,
            "Cannot have more than 16 total partnerships"
        );
        partnerships.totalPartnerships++;
        emit RequestPartnership(_partnerId, _tokenSaleId, _feeBP);
    }

    function acceptPartnership(uint256 _tokenSaleId, uint8 _requestId)
        external
        override
        isOwnerOrPartnerController(_tokenSaleId, _requestId)
        onlyBeforeSaleStart(_tokenSaleId)
    {

        TokenSalePartnerships storage partnerships =
            tokenSalePartnerships[_tokenSaleId];
        Partnership storage partnership =
            partnerships.partnershipRequests[_requestId];
        partnership.isApproved = true;
        partnerships.totalBPForPartners = partnerships.totalBPForPartners.add(
            partnership.feeBP
        );
        require(
            partnerships.totalBPForPartners <= liftoffSettings.getProjectDevBP()
        );
        emit AcceptPartnership(_tokenSaleId, _requestId);
    }

    function cancelPartnership(uint256 _tokenSaleId, uint8 _requestId)
        external
        override
        isOwnerOrPartnerController(_tokenSaleId, _requestId)
        onlyBeforeSaleStart(_tokenSaleId)
    {

        TokenSalePartnerships storage partnerships =
            tokenSalePartnerships[_tokenSaleId];
        Partnership storage partnership =
            partnerships.partnershipRequests[_requestId];
        partnership.isApproved = false;
        partnerships.totalBPForPartners = partnerships.totalBPForPartners.sub(
            partnership.feeBP
        );
        emit CancelPartnership(_tokenSaleId, _requestId);
    }

    function addFees(uint256 _tokenSaleId, uint256 _wad)
        external
        override
        isLiftoffInsurance
    {

        TokenSalePartnerships storage partnerships =
            tokenSalePartnerships[_tokenSaleId];
        for (uint8 i; i < partnerships.totalPartnerships; i++) {
            Partnership storage request = partnerships.partnershipRequests[i];
            if (request.isApproved) {
                uint256 fee =
                    request.feeBP.mul(_wad).div(
                        partnerships.totalBPForPartners
                    );
                IXEth(liftoffSettings.getXEth()).transfer(
                    partnerController[request.partnerId],
                    fee
                );
                emit ClaimFees(_tokenSaleId, fee, i);
            }
        }
        emit AddFees(_tokenSaleId, _wad);
    }

    function getTotalBP(uint256 _tokenSaleId)
        external
        view
        override
        returns (uint256 totalBP)
    {

        totalBP = tokenSalePartnerships[_tokenSaleId].totalBPForPartners;
    }

    function getTokenSalePartnerships(uint256 _tokenSaleId)
        external
        view
        override
        returns (uint8 totalPartnerships, uint256 totalBPForPartnerships)
    {

        TokenSalePartnerships storage partnerships =
            tokenSalePartnerships[_tokenSaleId];
        totalPartnerships = partnerships.totalPartnerships;
        totalBPForPartnerships = partnerships.totalBPForPartners;
    }

    function getPartnership(uint256 _tokenSaleId, uint8 _partnershipId)
        external
        view
        override
        returns (
            uint256 partnerId,
            uint256 tokenSaleId,
            uint256 feeBP,
            bool isApproved
        )
    {

        TokenSalePartnerships storage partnerships =
            tokenSalePartnerships[_tokenSaleId];
        Partnership storage partnership =
            partnerships.partnershipRequests[_partnershipId];
        partnerId = partnership.partnerId;
        tokenSaleId = partnership.tokenSaleId;
        feeBP = partnership.feeBP;
        isApproved = partnership.isApproved;
    }
}



pragma solidity =0.6.6;

interface ILiftoffRegistration {

    function registerProject(
        string calldata ipfsHash,
        uint256 launchTime,
        uint256 softCap,
        uint256 hardCap,
        uint256 totalSupplyWad,
        string calldata name,
        string calldata symbol
    ) external;

}



pragma solidity =0.6.6;
contract LiftoffRegistration is
    ILiftoffRegistration,
    Initializable,
    OwnableUpgradeable
{

    ILiftoffEngine public liftoffEngine;
    uint256 public minLaunchTime;
    uint256 public maxLaunchTime;
    uint256 public softCapTimer;

    mapping(uint256 => string) tokenIpfsHashes;

    event TokenIpfsHash(uint256 tokenId, string ipfsHash);

    function initialize(
        uint256 _minTimeToLaunch,
        uint256 _maxTimeToLaunch,
        uint256 _softCapTimer,
        ILiftoffEngine _liftoffEngine
    ) public initializer {

        OwnableUpgradeable.__Ownable_init();
        setLaunchTimeWindow(_minTimeToLaunch, _maxTimeToLaunch);
        setLiftoffEngine(_liftoffEngine);
        setSoftCapTimer(_softCapTimer);
    }

    function registerProject(
        string calldata ipfsHash,
        uint256 launchTime,
        uint256 softCap,
        uint256 hardCap,
        uint256 totalSupplyWad,
        string calldata name,
        string calldata symbol
    ) external override {

        require(
            launchTime >= block.timestamp + minLaunchTime,
            "Not allowed to launch before minLaunchTime"
        );
        require(
            launchTime <= block.timestamp + maxLaunchTime,
            "Not allowed to launch after maxLaunchTime"
        );
        require(
            totalSupplyWad < (10**12) * (10**18),
            "Cannot launch more than 1 trillion tokens"
        );
        require(
            totalSupplyWad >= 1000 * (10**18),
            "Cannot launch less than 1000 tokens"
        );
        require(
            softCap >= 10 ether,
            "Cannot launch if softcap is less than 10 ether"
        );

        uint256 tokenId =
            liftoffEngine.launchToken(
                launchTime,
                launchTime + softCapTimer,
                softCap,
                hardCap,
                totalSupplyWad,
                name,
                symbol,
                msg.sender
            );

        tokenIpfsHashes[tokenId] = ipfsHash;

        emit TokenIpfsHash(tokenId, ipfsHash);
    }

    function setSoftCapTimer(uint256 _seconds) public onlyOwner {

        softCapTimer = _seconds;
    }

    function setLaunchTimeWindow(uint256 _min, uint256 _max) public onlyOwner {

        minLaunchTime = _min;
        maxLaunchTime = _max;
    }

    function setLiftoffEngine(ILiftoffEngine _liftoffEngine) public onlyOwner {

        liftoffEngine = _liftoffEngine;
    }
}



pragma solidity =0.6.6;
contract LiftoffSettings is
    ILiftoffSettings,
    Initializable,
    OwnableUpgradeable
{

    using SafeMathUpgradeable for uint256;

    uint256 private ethXLockBP;
    uint256 private tokenUserBP;

    uint256 private insurancePeriod;

    uint256 private ethBuyBP;
    uint256 private baseFee;
    uint256 private projectDevBP;
    uint256 private mainFeeBP;
    uint256 private lidPoolBP;

    address private liftoffInsurance;
    address private liftoffRegistration;
    address private liftoffEngine;
    address private xEth;
    address private xLocker;
    address private uniswapRouter;

    address private lidTreasury;
    address private lidPoolManager;

    address private liftoffPartnerships;

    event LogEthXLockBP(uint256 ethXLockBP);
    event LogTokenUserBP(uint256 tokenUserBP);
    event LogInsurancePeriod(uint256 insurancePeriod);
    event LogXethBP(
        uint256 baseFee,
        uint256 ethBuyBP,
        uint256 projectDevBP,
        uint256 mainFeeBP,
        uint256 lidPoolBP
    );
    event LogLidTreasury(address lidTreasury);
    event LogLidPoolManager(address lidPoolManager);
    event LogLiftoffInsurance(address liftoffInsurance);
    event LogLiftoffLauncher(address liftoffLauncher);
    event LogLiftoffEngine(address liftoffEngine);
    event LogLiftoffPartnerships(address liftoffPartnerships);
    event LogXEth(address xEth);
    event LogXLocker(address xLocker);
    event LogUniswapRouter(address uniswapRouter);

    function initialize() external initializer {

        OwnableUpgradeable.__Ownable_init();
    }

    function setAllUints(
        uint256 _ethXLockBP,
        uint256 _tokenUserBP,
        uint256 _insurancePeriod,
        uint256 _baseFeeBP,
        uint256 _ethBuyBP,
        uint256 _projectDevBP,
        uint256 _mainFeeBP,
        uint256 _lidPoolBP
    ) external override onlyOwner {

        setEthXLockBP(_ethXLockBP);
        setTokenUserBP(_tokenUserBP);
        setInsurancePeriod(_insurancePeriod);
        setXethBP(_baseFeeBP, _ethBuyBP, _projectDevBP, _mainFeeBP, _lidPoolBP);
    }

    function setAllAddresses(
        address _liftoffInsurance,
        address _liftoffRegistration,
        address _liftoffEngine,
        address _liftoffPartnerships,
        address _xEth,
        address _xLocker,
        address _uniswapRouter,
        address _lidTreasury,
        address _lidPoolManager
    ) external override onlyOwner {

        setLiftoffInsurance(_liftoffInsurance);
        setLiftoffRegistration(_liftoffRegistration);
        setLiftoffEngine(_liftoffEngine);
        setLiftoffPartnerships(_liftoffPartnerships);
        setXEth(_xEth);
        setXLocker(_xLocker);
        setUniswapRouter(_uniswapRouter);
        setLidTreasury(_lidTreasury);
        setLidPoolManager(_lidPoolManager);
    }

    function setEthXLockBP(uint256 _val) public override onlyOwner {

        ethXLockBP = _val;

        emit LogEthXLockBP(ethXLockBP);
    }

    function getEthXLockBP() external view override returns (uint256) {

        return ethXLockBP;
    }

    function setTokenUserBP(uint256 _val) public override onlyOwner {

        tokenUserBP = _val;

        emit LogTokenUserBP(tokenUserBP);
    }

    function getTokenUserBP() external view override returns (uint256) {

        return tokenUserBP;
    }

    function setLiftoffInsurance(address _val) public override onlyOwner {

        liftoffInsurance = _val;

        emit LogLiftoffInsurance(liftoffInsurance);
    }

    function getLiftoffInsurance() external view override returns (address) {

        return liftoffInsurance;
    }

    function setLiftoffRegistration(address _val) public override onlyOwner {

        liftoffRegistration = _val;

        emit LogLiftoffLauncher(liftoffRegistration);
    }

    function getLiftoffRegistration() external view override returns (address) {

        return liftoffRegistration;
    }

    function setLiftoffEngine(address _val) public override onlyOwner {

        liftoffEngine = _val;

        emit LogLiftoffEngine(liftoffEngine);
    }

    function getLiftoffEngine() external view override returns (address) {

        return liftoffEngine;
    }

    function setLiftoffPartnerships(address _val) public override onlyOwner {

        liftoffPartnerships = _val;

        emit LogLiftoffPartnerships(liftoffPartnerships);
    }

    function getLiftoffPartnerships() external view override returns (address) {

        return liftoffPartnerships;
    }

    function setXEth(address _val) public override onlyOwner {

        xEth = _val;

        emit LogXEth(xEth);
    }

    function getXEth() external view override returns (address) {

        return xEth;
    }

    function setXLocker(address _val) public override onlyOwner {

        xLocker = _val;

        emit LogXLocker(xLocker);
    }

    function getXLocker() external view override returns (address) {

        return xLocker;
    }

    function setUniswapRouter(address _val) public override onlyOwner {

        uniswapRouter = _val;

        emit LogUniswapRouter(uniswapRouter);
    }

    function getUniswapRouter() external view override returns (address) {

        return uniswapRouter;
    }

    function setInsurancePeriod(uint256 _val) public override onlyOwner {

        insurancePeriod = _val;

        emit LogInsurancePeriod(insurancePeriod);
    }

    function getInsurancePeriod() external view override returns (uint256) {

        return insurancePeriod;
    }

    function setLidTreasury(address _val) public override onlyOwner {

        lidTreasury = _val;

        emit LogLidTreasury(lidTreasury);
    }

    function getLidTreasury() external view override returns (address) {

        return lidTreasury;
    }

    function setLidPoolManager(address _val) public override onlyOwner {

        lidPoolManager = _val;

        emit LogLidPoolManager(lidPoolManager);
    }

    function getLidPoolManager() external view override returns (address) {

        return lidPoolManager;
    }

    function setXethBP(
        uint256 _baseFeeBP,
        uint256 _ethBuyBP,
        uint256 _projectDevBP,
        uint256 _mainFeeBP,
        uint256 _lidPoolBP
    ) public override onlyOwner {

        require(
            _baseFeeBP.add(_ethBuyBP).add(_projectDevBP).add(_mainFeeBP).add(
                _lidPoolBP
            ) == 10000,
            "Must allocate 100% of eth raised"
        );
        baseFee = _baseFeeBP;
        ethBuyBP = _ethBuyBP;
        projectDevBP = _projectDevBP;
        mainFeeBP = _mainFeeBP;
        lidPoolBP = _lidPoolBP;

        emit LogXethBP(baseFee, ethBuyBP, projectDevBP, mainFeeBP, lidPoolBP);
    }

    function getBaseFeeBP() external view override returns (uint256) {

        return baseFee;
    }

    function getEthBuyBP() external view override returns (uint256) {

        return ethBuyBP;
    }

    function getProjectDevBP() external view override returns (uint256) {

        return projectDevBP;
    }

    function getMainFeeBP() external view override returns (uint256) {

        return mainFeeBP;
    }

    function getLidPoolBP() external view override returns (uint256) {

        return lidPoolBP;
    }
}



pragma solidity =0.6.6;

interface ILiftoffSwap {

    function acceptIgnite(address _token) external payable;


    function acceptSpark(address _token) external payable;

}








pragma solidity =0.6.6;

contract WETH9 {

    string public name     = "Wrapped Ether";
    string public symbol   = "WETH";
    uint8  public decimals = 18;

    event  Approval(address indexed src, address indexed guy, uint wad);
    event  Transfer(address indexed src, address indexed dst, uint wad);
    event  Deposit(address indexed dst, uint wad);
    event  Withdrawal(address indexed src, uint wad);

    mapping (address => uint)                       public  balanceOf;
    mapping (address => mapping (address => uint))  public  allowance;

    constructor() public payable {
        deposit();
    }
    function deposit() public payable {

        balanceOf[msg.sender] += msg.value;
        emit Deposit(msg.sender, msg.value);
    }
    function withdraw(uint wad) public {

        require(balanceOf[msg.sender] >= wad);
        balanceOf[msg.sender] -= wad;
        msg.sender.transfer(wad);
        emit Withdrawal(msg.sender, wad);
    }

    function totalSupply() public view returns (uint) {

        return address(this).balance;
    }

    function approve(address guy, uint wad) public returns (bool) {

        allowance[msg.sender][guy] = wad;
        emit Approval(msg.sender, guy, wad);
        return true;
    }

    function transfer(address dst, uint wad) public returns (bool) {

        return transferFrom(msg.sender, dst, wad);
    }

    function transferFrom(address src, address dst, uint wad)
        public
        returns (bool)
    {

        require(balanceOf[src] >= wad);

        if (src != msg.sender && allowance[src][msg.sender] != uint(-1)) {
            require(allowance[src][msg.sender] >= wad);
            allowance[src][msg.sender] -= wad;
        }

        balanceOf[src] -= wad;
        balanceOf[dst] += wad;

        emit Transfer(src, dst, wad);

        return true;
    }
}


