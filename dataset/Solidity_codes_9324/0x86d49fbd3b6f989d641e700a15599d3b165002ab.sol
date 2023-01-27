


pragma solidity 0.8.4;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor() {
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
}


library SafeMath {

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

interface IBEP20 {

    function name() external pure returns (string memory);


    function symbol() external pure returns (string memory);


    function decimals() external pure returns (uint8);


    function totalSupply() external view returns (uint256);


    function balanceOf(address account) external view returns (uint256);


    function transfer(address recipient, uint256 amount) external returns (bool);


    function allowance(address owner, address spender) external view returns (uint256);


    function approve(address spender, uint256 amount) external returns (bool);


    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);


    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}

interface IRewardDistributor {

    function addRewardHolderShare(address rewardRecipient, uint256 amount) external;

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

interface IUniswapV2Router01 {

    function factory() external pure returns (address);

    function WETH() external pure returns (address);


    function addLiquidity(
        address tokenA,
        address tokenB,
        uint amountADesired,
        uint amountBDesired,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB, uint liquidity);

    function addLiquidityETH(
        address token,
        uint amountTokenDesired,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external payable returns (uint amountToken, uint amountETH, uint liquidity);

    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB);

    function removeLiquidityETH(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external returns (uint amountToken, uint amountETH);

    function removeLiquidityWithPermit(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountA, uint amountB);

    function removeLiquidityETHWithPermit(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountToken, uint amountETH);

    function swapExactTokensForTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);

    function swapTokensForExactTokens(
        uint amountOut,
        uint amountInMax,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);

    function swapExactETHForTokens(uint amountOutMin, address[] calldata path, address to, uint deadline)
    external
    payable
    returns (uint[] memory amounts);

    function swapTokensForExactETH(uint amountOut, uint amountInMax, address[] calldata path, address to, uint deadline)
    external
    returns (uint[] memory amounts);

    function swapExactTokensForETH(uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline)
    external
    returns (uint[] memory amounts);

    function swapETHForExactTokens(uint amountOut, address[] calldata path, address to, uint deadline)
    external
    payable
    returns (uint[] memory amounts);


    function quote(uint amountA, uint reserveA, uint reserveB) external pure returns (uint amountB);

    function getAmountOut(uint amountIn, uint reserveIn, uint reserveOut) external pure returns (uint amountOut);

    function getAmountIn(uint amountOut, uint reserveIn, uint reserveOut) external pure returns (uint amountIn);

    function getAmountsOut(uint amountIn, address[] calldata path) external view returns (uint[] memory amounts);

    function getAmountsIn(uint amountOut, address[] calldata path) external view returns (uint[] memory amounts);

}

interface IUniswapV2Router02 is IUniswapV2Router01 {

    function removeLiquidityETHSupportingFeeOnTransferTokens(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external returns (uint amountETH);

    function removeLiquidityETHWithPermitSupportingFeeOnTransferTokens(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountETH);


    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;

    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external payable;

    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;

}

interface IUniswapV2Factory {

    event PairCreated(address indexed token0, address indexed token1, address pair, uint);

    function feeTo() external view returns (address);

    function feeToSetter() external view returns (address);


    function getPair(address tokenA, address tokenB) external view returns (address pair);

    function allPairs(uint) external view returns (address pair);

    function allPairsLength() external view returns (uint);


    function createPair(address tokenA, address tokenB) external returns (address pair);


    function setFeeTo(address) external;

    function setFeeToSetter(address) external;

}


contract HuhToken is Context, IBEP20, Ownable {

    using SafeMath for uint256;

    string private constant _NAME = "HUH_Token";
    string private constant _SYMBOL = "HUH";
    uint8 private constant _DECIMALS = 9;

    uint256 private constant _MAX = ~uint256(0);
    uint256 private constant _tTotal = 888 * 10 ** 9 * ( 10** _DECIMALS); // 888 Billion HuhToken
    uint256 private _rTotal = (_MAX - (_MAX % _tTotal));
    uint256 private _tFeeTotal;

    uint8 public referralReward = 10;

    uint8 public liquidityFeeOnBuy = 5;
    uint8 public marketingFeeOnBuy = 5;
    uint8 public HuHdistributionFeeOnBuy = 5;

    uint8 public liquidityFeeOnWhiteListedBuy = 0;
    uint8 public marketingFeeOnBuyWhiteListed = 5;
    uint8 public HuHdistributionFeeOnBuyWhiteListed = 0;

    uint8 public liquidityFeeOnSell = 10;
    uint8 public marketingFeeOnSell = 5;
    uint8 public HuHdistributionFeeOnSell = 5;

    uint8 public liquidityFeeOnWhiteListedSell = 25; // In the power of 1000 => 2.5%
    uint8 public marketingFeeOnWhiteListedSell = 50; // In the power of 1000 => 5%
    uint8 public HuHdistributionFeeOnWhiteListedSell = 25; // In the power of 1000 => 2.5%

    uint256 public launchedAt;

    uint256 private referralCount;
    uint256 private totalReferralReward;
    mapping(address => uint256) private userReferralCount;
    mapping(address => uint256) private userReferralReward;

    address public referralCodeRegistrator;  // Address who allowed to register code for users (will be used later)
    address public marketingWallet;
    address private constant _DEAD_ADDRESS = 0x000000000000000000000000000000000000dEaD;

    mapping(address => uint256) private _rOwned;
    mapping(address => uint256) private _tOwned;
    mapping(address => mapping(address => uint256)) private _allowances;

    mapping(address => bool) private _isExcludedFromFee;
    mapping(address => bool) private _isExcluded;
    address[] private _excluded;

    mapping(address => bytes) public referCodeForUser;
    mapping(bytes => address) public referUserForCode;
    mapping(address => address) public referParent;
    mapping(address => address[]) public referralList;
    mapping(address => bool) public isWhitelisted;
    mapping(address => bool) public isFirstBuy;

    IUniswapV2Router02 public pcsV2Router;
    address public pcsV2Pair;

    IRewardDistributor public rewardDistributor;

    uint256 public maxTxAmount = _tTotal.mul(1).div(10**2); // 1% of total supply
    uint256 public amountOfTokensToAddToLiquidityThreshold = maxTxAmount.mul(10).div(10**2); // 10% of max transaction amount

    bool public swapAndLiquifyEnabled = true;
    bool private _inSwap;
    modifier swapping() {

        _inSwap = true;
        _;
        _inSwap = false;
    }

    event UserWhitelisted(address indexed account, address indexed referee);
    event RegisterCode(address indexed account, bytes indexed code);
    event SwapAndLiquify(uint256 indexed ethReceived, uint256 indexed tokensIntoLiqudity);
    event UpdatePancakeSwapRouter(address indexed pcsV2Router);
    event UpdateRewardDistributor(address indexed newRewardDistributor);
    event UpdateSwapAndLiquifyEnabled(bool indexed swapAndLiquifyEnabled);
    event ExcludeFromReflection(address indexed account);
    event IncludeInReflection(address indexed account);
    event SetIsExcludedFromFee(address indexed account, bool indexed flag);
    event ChangeFeesForNormalBuy(uint8 indexed liquidityFeeOnBuy, uint8 indexed marketingFeeOnBuy, uint8 indexed HuHdistributionFeeOnBuy);
    event ChangeFeesForWhiteListedBuy(uint8 indexed liquidityFeeOnBuy, uint8 indexed marketingFeeOnBuy, uint8 indexed HuHdistributionFeeOnBuy);
    event ChangeFeesForNormalSell(uint8 indexed liquidityFeeOnSell, uint8 indexed marketingFeeOnSell, uint8 indexed HuHdistributionFeeOnSell);
    event ChangeFeesForWhitelistedSell(uint8 indexed liquidityFeeOnSell, uint8 indexed marketingFeeOnSell, uint8 indexed HuHdistributionFeeOnSell);
    event ChangeReferralReward(uint8 indexed referralReward);
    event UpdateMarketingWallet(address indexed marketingWallet);
    event SetReferralCodeRegistrator(address indexed referralCodeRegistrator);
    event UpdateAmountOfTokensToAddToLiquidityThreshold(uint256 indexed amountOfTokensToAddToLiquidityThreshold);
    event SetMaxTxPercent(uint256 indexed maxTxPercent);

    constructor() {
        IUniswapV2Router02 _pancakeswapV2Router = IUniswapV2Router02(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);

        pcsV2Pair = IUniswapV2Factory(_pancakeswapV2Router.factory()).createPair(address(this), _pancakeswapV2Router.WETH());
        pcsV2Router = _pancakeswapV2Router;
        _allowances[address(this)][address(pcsV2Router)] = _MAX;

        rewardDistributor = IRewardDistributor(0xc15e89f2149bCC0cBd5FB204C9e77fe878f1e9b2);
        _allowances[address(this)][address(rewardDistributor)] = _MAX;
        _allowances[address(rewardDistributor)][address(pcsV2Router)] = _MAX;

        marketingWallet = 0x783f51eF9Ac932B323dDb26701aD7897315a2cD5;

        _rOwned[msg.sender] = _rTotal;
        _isExcludedFromFee[msg.sender] = true;
        _isExcludedFromFee[address(this)] = true;
        _isExcludedFromFee[address(rewardDistributor)] = true;
        _isExcludedFromFee[marketingWallet] = true;
        _excludeFromReflection(address(rewardDistributor));
        _excludeFromReflection(marketingWallet);

        emit Transfer(address(0), msg.sender, _tTotal);
    }

    receive() external payable {}

    fallback() external payable {}

    function withdrawEthInWei(address payable recipient, uint256 amount) external onlyOwner {

        require(recipient != address(0), 'Invalid Recipient!');
        require(amount > 0, 'Invalid Amount!');
        recipient.transfer(amount);
    }

    function withdrawTokens(address token, address recipient) external onlyOwner {

        require(token != address(0), 'Invalid Token!');
        require(recipient != address(0), 'Invalid Recipient!');

        uint256 balance = IBEP20(token).balanceOf(address(this));
        if (balance > 0) {
            require(IBEP20(token).transfer(recipient, balance), "Transfer Failed");
        }
    }

    function excludeFromReflection(address account) external onlyOwner {

        _excludeFromReflection(account);
        emit ExcludeFromReflection(account);
    }

    function includeInReflection(address account) external onlyOwner {

        _includeInReflection(account);
        emit IncludeInReflection(account);
    }

    function setIsExcludedFromFee(address account, bool flag) external onlyOwner {

        _setIsExcludedFromFee(account, flag);
        emit SetIsExcludedFromFee(account, flag);
    }

    function changeFeesForNormalBuy(uint8 _liquidityFeeOnBuy, uint8 _marketingFeeOnBuy, uint8 _HuHdistributionFeeOnBuy) external onlyOwner {

        require(_liquidityFeeOnBuy < 100, "Fee should be less than 100!");
        require(_marketingFeeOnBuy < 100, "Fee should be less than 100!");
        require(_HuHdistributionFeeOnBuy < 100, "Fee should be less than 100!");
        liquidityFeeOnBuy = _liquidityFeeOnBuy;
        marketingFeeOnBuy = _marketingFeeOnBuy;
        HuHdistributionFeeOnBuy = _HuHdistributionFeeOnBuy;
        emit ChangeFeesForNormalBuy(_liquidityFeeOnBuy, _marketingFeeOnBuy, _HuHdistributionFeeOnBuy);
    }

    function changeFeesForWhiteListedBuy(uint8 _liquidityFeeOnBuy, uint8 _marketingFeeOnBuy, uint8 _HuHdistributionFeeOnBuy) external onlyOwner {

        require(_liquidityFeeOnBuy < 100, "Fee should be less than 100!");
        require(_marketingFeeOnBuy < 100, "Fee should be less than 100!");
        require(_HuHdistributionFeeOnBuy < 100, "Fee should be less than 100!");
        liquidityFeeOnWhiteListedBuy = _liquidityFeeOnBuy;
        marketingFeeOnBuyWhiteListed = _marketingFeeOnBuy;
        HuHdistributionFeeOnBuyWhiteListed = _HuHdistributionFeeOnBuy;
        emit ChangeFeesForWhiteListedBuy(_liquidityFeeOnBuy, _marketingFeeOnBuy, _HuHdistributionFeeOnBuy);
    }

    function changeFeesForNormalSell(uint8 _liquidityFeeOnSell, uint8 _marketingFeeOnSell, uint8 _HuHdistributionFeeOnSell) external onlyOwner {

        require(_liquidityFeeOnSell < 100, "Fee should be less than 100!");
        require(_marketingFeeOnSell < 100, "Fee should be less than 100!");
        require(_HuHdistributionFeeOnSell < 100, "Fee should be less than 100!");
        liquidityFeeOnSell = _liquidityFeeOnSell;
        marketingFeeOnSell = _marketingFeeOnSell;
        HuHdistributionFeeOnSell = _HuHdistributionFeeOnSell;
        emit ChangeFeesForNormalSell(_liquidityFeeOnSell, _marketingFeeOnSell, _HuHdistributionFeeOnSell);
    }


    function changeFeesForWhitelistedSell(uint8 _liquidityFeeOnSell, uint8 _marketingFeeOnSell, uint8 _HuHdistributionFeeOnSell) external onlyOwner {

        require(_liquidityFeeOnSell < 1000, "Fee should be less than 100!");
        require(_marketingFeeOnSell < 1000, "Fee should be less than 100!");
        require(_HuHdistributionFeeOnSell < 1000, "Fee should be less than 100!");
        liquidityFeeOnWhiteListedSell = _liquidityFeeOnSell;
        marketingFeeOnWhiteListedSell = _marketingFeeOnSell;
        HuHdistributionFeeOnWhiteListedSell = _HuHdistributionFeeOnSell;
        emit ChangeFeesForWhitelistedSell(_liquidityFeeOnSell, _marketingFeeOnSell, _HuHdistributionFeeOnSell);
    }

    function changeReferralReward(uint8 _referralReward) external onlyOwner {

        referralReward = _referralReward;
        emit ChangeReferralReward(_referralReward);
    }

    function updateMarketingWallet(address _marketingWallet) external onlyOwner {

        require(_marketingWallet != address(0), "Zero address not allowed!");
        _isExcludedFromFee[marketingWallet] = false;
        marketingWallet = _marketingWallet;
        _isExcludedFromFee[marketingWallet] = true;
        _excludeFromReflection(marketingWallet);
        emit UpdateMarketingWallet(_marketingWallet);
    }

    function setReferralCodeRegistrator(address _referralCodeRegistrator) external onlyOwner {

        require(_referralCodeRegistrator != address(0), "setReferralCodeRegistrator: Zero address not allowed!");
        referralCodeRegistrator = _referralCodeRegistrator;
        emit SetReferralCodeRegistrator(_referralCodeRegistrator);
    }

    function updateAmountOfTokensToAddToLiquidityThreshold(uint256 _amountOfTokensToAddToLiquidityThreshold) external onlyOwner {

        amountOfTokensToAddToLiquidityThreshold = _amountOfTokensToAddToLiquidityThreshold * (10 ** _DECIMALS);
        emit UpdateAmountOfTokensToAddToLiquidityThreshold(_amountOfTokensToAddToLiquidityThreshold);
    }

    function updatePancakeSwapRouter(address _pcsV2Router) external onlyOwner {

        require(_pcsV2Router != address(0), 'PancakeSwap Router Invalid!');
        require(address(pcsV2Router) != _pcsV2Router, 'PancakeSwap Router already exists!');
        _allowances[address(this)][address(pcsV2Router)] = 0; // Set Allowance to 0
        _allowances[address(rewardDistributor)][address(pcsV2Router)] = 0; // Set Allowance to 0
        pcsV2Router = IUniswapV2Router02(_pcsV2Router);
        pcsV2Pair = IUniswapV2Factory(pcsV2Router.factory()).createPair(address(this), pcsV2Router.WETH());
        _allowances[address(this)][address(pcsV2Router)] = _MAX;
        _allowances[address(rewardDistributor)][address(pcsV2Router)] = _MAX;
        emit UpdatePancakeSwapRouter(_pcsV2Router);
    }

    function updateRewardDistributor(address _rewardDistributor) external onlyOwner {

        require(address(rewardDistributor) != _rewardDistributor, 'Reward Distributor already exists!');
        _isExcludedFromFee[address(rewardDistributor)] = false;
        _allowances[address(this)][address(rewardDistributor)] = 0; // Set Allowance to 0
        _allowances[address(rewardDistributor)][address(pcsV2Router)] = 0; // Set Allowance to 0
        rewardDistributor = IRewardDistributor(_rewardDistributor);
        _allowances[address(this)][address(rewardDistributor)] = _MAX;
        _allowances[address(rewardDistributor)][address(pcsV2Router)] = _MAX;
        _isExcludedFromFee[address(rewardDistributor)] = true;
        _excludeFromReflection(address(rewardDistributor));
        emit UpdateRewardDistributor(_rewardDistributor);
    }

    function updateSwapAndLiquifyEnabled(bool _swapAndLiquifyEnabled) external onlyOwner {

        require(swapAndLiquifyEnabled != _swapAndLiquifyEnabled, 'Value already exists!');
        swapAndLiquifyEnabled = _swapAndLiquifyEnabled;
        emit UpdateSwapAndLiquifyEnabled(_swapAndLiquifyEnabled);
    }

    function setMaxTxPercent(uint256 maxTxPercent) external onlyOwner {

        maxTxAmount = _tTotal.mul(maxTxPercent).div(10**2);
        emit SetMaxTxPercent(maxTxPercent);
    }

    function registerCodeForOwner(address account, string memory code) external {

        require(msg.sender == referralCodeRegistrator || msg.sender == owner(), "Not autorized!");

        bytes memory code_ = bytes(code);
        require(code_.length > 0, "Invalid code!");
        require(referUserForCode[code_] == address(0), "Code already used!");
        require(referCodeForUser[account].length == 0, "User already generated code!");

        _registerCode(account, code_);
    }

    function registerCode(string memory code) external {

        bytes memory code_ = bytes(code);
        require(code_.length > 0, "Invalid code!");
        require(referUserForCode[code_] == address(0), "Code already used!");
        require(referCodeForUser[msg.sender].length == 0, "User already generated code!");

        _registerCode(msg.sender, code_);
    }

    function whitelist(string memory refCode) external {

        bytes memory refCode_ = bytes(refCode);
        require(refCode_.length > 0, "Invalid code!");
        require(!isWhitelisted[msg.sender], "Already whitelisted!");
        require(referUserForCode[refCode_] != address(0), "Non used code!");
        require(referUserForCode[refCode_] != msg.sender, "Invalid code, A -> A refer!");
        require(referParent[referUserForCode[refCode_]] != msg.sender, "Invalid code, A -> B -> A refer!");

        _whitelistWithRef(msg.sender, referUserForCode[refCode_]);
        referralCount = referralCount.add(1);
    }

    function transfer(address recipient, uint256 amount) external override returns (bool) {

        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function approve(address spender, uint256 amount) external override returns (bool) {

        _approve(_msgSender(), spender, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) external override returns (bool) {

        _transfer(sender, recipient, amount);
        _approve(
            sender,
            _msgSender(),
            _allowances[sender][_msgSender()].sub(amount, "BEP20: transfer amount exceeds allowance"));
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) external virtual returns (bool) {

        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].add(addedValue));
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) external virtual returns (bool) {

        _approve(
            _msgSender(),
            spender,
            _allowances[_msgSender()][spender].sub(subtractedValue, "BEP20: decreased allowance below zero"));
        return true;
    }

    function name() external pure override returns (string memory) {

        return _NAME;
    }

    function symbol() external pure override returns (string memory) {

        return _SYMBOL;
    }

    function decimals() external pure override returns (uint8) {

        return _DECIMALS;
    }

    function totalSupply() external pure override returns (uint256) {

        return _tTotal;
    }

    function balanceOf(address account) public view override returns (uint256) {

        if (_isExcluded[account]) return _tOwned[account];
        return tokenFromReflection(_rOwned[account]);
    }

    function allowance(address owner, address spender) external view override returns (uint256) {

        return _allowances[owner][spender];
    }

    function isExcludedFromReflection(address account) external view returns (bool) {

        return _isExcluded[account];
    }

    function totalFees() external view returns (uint256) {

        return _tFeeTotal;
    }

    function reflectionFromToken(uint256 tAmount) public view returns (uint256) {

        uint256 rAmount = tAmount.mul(_getRate());
        return rAmount;
    }

    function tokenFromReflection(uint256 rAmount) public view returns (uint256) {

        require(rAmount <= _rTotal, "Amount must be less than total reflections");
        uint256 currentRate = _getRate();
        return rAmount.div(currentRate);
    }

    function getTotalCommunityReflection() external view returns (uint256) {

        return _tFeeTotal;
    }

    function getTotalNumberOfCommunityReferral() external view returns (uint256) {

        return referralCount;
    }

    function getTotalCommunityReferralReward() external view returns (uint256) {

        return totalReferralReward;
    }

    function getReferralList(address account) external view returns (address[] memory) {

        return referralList[account];
    }

    function getTotalNumberOfUserReferral(address account) external view returns (uint256) {

        return userReferralCount[account];
    }

    function getTotalUserReferralReward(address account) external view returns (uint256) {

        return userReferralReward[account];
    }


    function _getRate() private view returns (uint256) {

        (uint256 rSupply, uint256 tSupply) = _getCurrentSupply();
        return rSupply.div(tSupply);
    }

    function _getCurrentSupply() private view returns (uint256, uint256) {

        uint256 rSupply = _rTotal;
        uint256 tSupply = _tTotal;
        for (uint256 i = 0; i < _excluded.length; i++) {
            if (_rOwned[_excluded[i]] > rSupply || _tOwned[_excluded[i]] > tSupply)
                return (_rTotal, _tTotal);

            rSupply = rSupply.sub(_rOwned[_excluded[i]]);
            tSupply = tSupply.sub(_tOwned[_excluded[i]]);
        }

        if (rSupply < _rTotal.div(_tTotal)) {
            return (_rTotal, _tTotal);
        }

        return (rSupply, tSupply);
    }

    function _approve(address owner, address spender, uint256 amount) private {

        require(owner != address(0), "BEP20: approve from the zero address");
        require(spender != address(0), "BEP20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _transfer(address sender, address recipient, uint256 amount) private {

        require(sender != address(0), "BEP20: transfer from the zero address");
        require(recipient != address(0), "BEP20: transfer to the zero address");
        require(amount > 0, "BEP20: Transfer amount must be greater than zero");

        if(sender != owner() && recipient != owner())
            require(amount <= maxTxAmount, "Transfer amount exceeds the maxTxAmount");

        if (_inSwap) {
            _basicTransfer(sender, recipient, amount);
            return;
        }

        if (_shouldSwapBack())
            _swapAndAddToLiquidity();

        if (_isExcludedFromFee[sender] || _isExcludedFromFee[recipient]) {
            _basicTransfer(sender, recipient, amount);
        } else {
            if (recipient == pcsV2Pair) {
                if (isWhitelisted[sender]) {
                    _whitelistedSell(sender, recipient, amount);
                } else {
                    _normalSell(sender, recipient, amount);
                }
            } else if (sender == pcsV2Pair) {
                if (isWhitelisted[recipient] && isFirstBuy[recipient]) {
                    _whitelistedBuy(sender, recipient, amount);
                    isFirstBuy[recipient] = false;
                } else {
                    _normalBuy(sender, recipient, amount);
                }
            } else {
                _basicTransfer(sender, recipient, amount);
            }
        }

        if (launchedAt == 0 && recipient == pcsV2Pair) {
            launchedAt = block.number;
        }
    }

    function _basicTransfer(address sender, address recipient, uint256 amount) private {

        uint256 rAmount = reflectionFromToken(amount);
        _rOwned[sender] = _rOwned[sender].sub(rAmount);
        _rOwned[recipient] = _rOwned[recipient].add(rAmount);
        if (_isExcluded[sender]) _tOwned[sender] = _tOwned[sender].sub(amount);
        if (_isExcluded[recipient]) _tOwned[recipient] = _tOwned[recipient].add(amount);

        emit Transfer(sender, recipient, amount);
    }

    function _normalBuy(address sender, address recipient, uint256 amount) private {

        uint256 currentRate = _getRate();
        uint256 rAmount = amount.mul(currentRate);
        uint256 rLiquidityFee = amount.mul(liquidityFeeOnBuy).mul(currentRate).div(100);
        uint256 rHuhdistributionFee = amount.mul(HuHdistributionFeeOnBuy).mul(currentRate).div(100);
        uint256 rMarketingFee = amount.mul(marketingFeeOnBuy).mul(currentRate).div(100);
        uint256 rTransferAmount = rAmount.sub(rLiquidityFee).sub(rHuhdistributionFee).sub(rMarketingFee);
        _rOwned[sender] = _rOwned[sender].sub(rAmount);
        _rOwned[recipient] = _rOwned[recipient].add(rTransferAmount);
        _rOwned[address(this)] = _rOwned[address(this)].add(rLiquidityFee);
        if (_isExcluded[sender]) _tOwned[sender] = _tOwned[sender].sub(amount);
        if (_isExcluded[recipient]) _tOwned[recipient] = _tOwned[recipient].add(rTransferAmount.div(currentRate));
        if (_isExcluded[address(this)]) _tOwned[address(this)] = _tOwned[address(this)].add(rLiquidityFee.div(currentRate));

        emit Transfer(sender, recipient, rTransferAmount.div(currentRate));
        emit Transfer(sender, address(this), (rLiquidityFee).div(currentRate));

        _sendToMarketingWallet(sender, rMarketingFee.div(currentRate), rMarketingFee);
        _reflectFee(rHuhdistributionFee, rHuhdistributionFee.div(currentRate));
    }

    function _whitelistedBuy(address sender, address recipient, uint256 amount) private {

        uint256 currentRate = _getRate();
        uint256 rAmount = amount.mul(currentRate);
        uint256 tReferralRewardAmount = amount.mul(referralReward).div(100);
        uint256 rReferralRewardAmount = tReferralRewardAmount.mul(currentRate);
        uint256 rLiquidityFee = amount.mul(liquidityFeeOnWhiteListedBuy).mul(currentRate).div(100);
        uint256 rHuhdistributionFee = amount.mul(HuHdistributionFeeOnBuyWhiteListed).mul(currentRate).div(100);
        uint256 rMarketingFee = amount.mul(marketingFeeOnBuyWhiteListed).mul(currentRate).div(100);
        uint256 rTransferAmount = rAmount.sub(rReferralRewardAmount).sub(rLiquidityFee).sub(rHuhdistributionFee).sub(rMarketingFee);
        _rOwned[sender] = _rOwned[sender].sub(rAmount);
        _rOwned[recipient] = _rOwned[recipient].add(rTransferAmount);
        _rOwned[address(this)] = _rOwned[address(this)].add(rLiquidityFee);

        if (_isExcluded[sender]) _tOwned[sender] = _tOwned[sender].sub(amount);
        if (_isExcluded[recipient]) _tOwned[recipient] = _tOwned[recipient].add(rTransferAmount.div(currentRate));
        if (_isExcluded[address(this)]) _tOwned[address(this)] = _tOwned[address(this)].add(rLiquidityFee.div(currentRate));

        emit Transfer(sender, recipient, rTransferAmount.div(currentRate));
        emit Transfer(sender, address(this), rLiquidityFee.div(currentRate));
        
        _sendToRewardDistributor(sender, referParent[recipient], tReferralRewardAmount, rReferralRewardAmount);
        _sendToMarketingWallet(sender, rMarketingFee.div(currentRate), rMarketingFee);
        _reflectFee(rHuhdistributionFee, rHuhdistributionFee.div(currentRate));
    }

    function _normalSell(address sender, address recipient, uint256 amount) private {

        uint256 currentRate = _getRate();
        uint256 rAmount = amount.mul(currentRate);
        uint256 rLiquidityFee = amount.mul(liquidityFeeOnSell).mul(currentRate).div(100);
        uint256 rHuhdistributionFee = amount.mul(HuHdistributionFeeOnSell).mul(currentRate).div(100);
        uint256 rMarketingFee = amount.mul(marketingFeeOnSell).mul(currentRate).div(100);
        uint256 rTransferAmount = rAmount.sub(rLiquidityFee).sub(rHuhdistributionFee).sub(rMarketingFee);
        _rOwned[sender] = _rOwned[sender].sub(rAmount);
        _rOwned[recipient] = _rOwned[recipient].add(rTransferAmount);
        _rOwned[address(this)] = _rOwned[address(this)].add(rLiquidityFee);
        if (_isExcluded[sender]) _tOwned[sender] = _tOwned[sender].sub(amount);
        if (_isExcluded[recipient]) _tOwned[recipient] = _tOwned[recipient].add(rTransferAmount.div(currentRate));
        if (_isExcluded[address(this)]) _tOwned[address(this)] = _tOwned[address(this)].add(rLiquidityFee.div(currentRate));

        emit Transfer(sender, recipient, rTransferAmount.div(currentRate));
        emit Transfer(sender, address(this), rLiquidityFee.div(currentRate));

        _sendToMarketingWallet(sender, rMarketingFee.div(currentRate), rMarketingFee);
        _reflectFee(rHuhdistributionFee, rHuhdistributionFee.div(currentRate));
    }

    function _whitelistedSell(address sender, address recipient, uint256 amount) private {

        uint256 currentRate = _getRate();
        uint256 rAmount = amount.mul(currentRate);
        uint256 rLiquidityFee = amount.mul(liquidityFeeOnWhiteListedSell).mul(currentRate).div(1000);
        uint256 rHuhdistributionFee = amount.mul(HuHdistributionFeeOnWhiteListedSell).mul(currentRate).div(1000);
        uint256 rMarketingFee = amount.mul(marketingFeeOnWhiteListedSell).mul(currentRate).div(1000);
        uint256 rTransferAmount = rAmount.sub(rLiquidityFee).sub(rHuhdistributionFee).sub(rMarketingFee);
        _rOwned[sender] = _rOwned[sender].sub(rAmount);
        _rOwned[recipient] = _rOwned[recipient].add(rTransferAmount);
        _rOwned[address(this)] = _rOwned[address(this)].add(rLiquidityFee);
        if (_isExcluded[sender]) _tOwned[sender] = _tOwned[sender].sub(amount);
        if (_isExcluded[recipient]) _tOwned[recipient] = _tOwned[recipient].add(rTransferAmount.div(currentRate));
        if (_isExcluded[address(this)]) _tOwned[address(this)] = _tOwned[address(this)].add(rLiquidityFee.div(currentRate));

        emit Transfer(sender, recipient, rTransferAmount.div(currentRate));
        emit Transfer(sender, address(this), rLiquidityFee.div(currentRate));

        _sendToMarketingWallet(sender, rMarketingFee.div(currentRate), rMarketingFee);
        _reflectFee(rHuhdistributionFee, rHuhdistributionFee.div(currentRate));
    }

    function _sendToRewardDistributor(address sender, address rewardRecipient, uint256 tAmount, uint256 rAmount) private {

        _rOwned[address(rewardDistributor)] = _rOwned[address(rewardDistributor)].add(rAmount);
        if (_isExcluded[address(rewardDistributor)]) _tOwned[address(rewardDistributor)] = _tOwned[address(rewardDistributor)].add(tAmount);

        emit Transfer(sender, address(rewardDistributor), tAmount);
        rewardDistributor.addRewardHolderShare(rewardRecipient, tAmount);
        userReferralReward[rewardRecipient] = userReferralReward[rewardRecipient].add(tAmount);
        totalReferralReward = totalReferralReward.add(tAmount);
    }

    function _sendToMarketingWallet(address sender, uint256 tMarketingFee, uint256 rMarketingFee) private {

        _rOwned[marketingWallet] = _rOwned[marketingWallet].add(rMarketingFee);
        if (_isExcluded[marketingWallet]) _tOwned[marketingWallet] = _tOwned[marketingWallet].add(tMarketingFee);
        emit Transfer(sender, marketingWallet, tMarketingFee);
    }

    function _shouldSwapBack() private view returns (bool) {

        return msg.sender != pcsV2Pair
            && launchedAt > 0
            && !_inSwap
            && swapAndLiquifyEnabled
            && balanceOf(address(this)) >= amountOfTokensToAddToLiquidityThreshold;
    }

    function _swapAndAddToLiquidity() private swapping {

        uint256 tokenAmountForLiquidity = amountOfTokensToAddToLiquidityThreshold;
        uint256 amountToSwap = tokenAmountForLiquidity.div(2);
        uint256 amountAnotherHalf = tokenAmountForLiquidity.sub(amountToSwap);

        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = pcsV2Router.WETH();

        uint256 balanceBefore = address(this).balance;

        pcsV2Router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            amountToSwap,
            0,
            path,
            address(this),
            block.timestamp.add(30)
        );

        uint256 differenceBnb = address(this).balance.sub(balanceBefore);

        pcsV2Router.addLiquidityETH{value: differenceBnb} (
            address(this),
            amountAnotherHalf,
            0,
            0,
            _DEAD_ADDRESS,
            block.timestamp.add(30)
        );

        emit SwapAndLiquify(differenceBnb, amountToSwap);
    }

    function _reflectFee(uint256 rFee, uint256 tFee) private {

        _rTotal = _rTotal.sub(rFee);
        _tFeeTotal = _tFeeTotal.add(tFee);
    }

    function _excludeFromReflection(address account) private {

        require(!_isExcluded[account], "Account is already excluded");

        if (_rOwned[account] > 0) {
            _tOwned[account] = tokenFromReflection(_rOwned[account]);
        }
        _isExcluded[account] = true;
        _excluded.push(account);
    }

    function _includeInReflection(address account) private {

        require(_isExcluded[account], "Account is already included");
        for (uint256 i = 0; i < _excluded.length; i++) {
            if (_excluded[i] == account) {
                _excluded[i] = _excluded[_excluded.length - 1];
                _rOwned[account] = reflectionFromToken(_tOwned[account]);
                _isExcluded[account] = false;
                _excluded.pop();
                break;
            }
        }
    }

    function _setIsExcludedFromFee(address account, bool flag) private {

        _isExcludedFromFee[account] = flag;
    }

    function _whitelistWithRef(address account, address referee) private {

        isFirstBuy[account] = true;
        isWhitelisted[msg.sender] = true;
        referParent[msg.sender] = referee;
        referralList[referee].push(account);
        userReferralCount[referee] = userReferralCount[referee].add(1);
        emit UserWhitelisted(account, referee);
    }

    function _registerCode(address account, bytes memory code) private {

        referUserForCode[code] = account;
        referCodeForUser[account] = code;
        emit RegisterCode(account, code);
    }
}