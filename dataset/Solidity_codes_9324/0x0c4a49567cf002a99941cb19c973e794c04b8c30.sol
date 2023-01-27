
pragma solidity ^0.8.9;

interface LinkTokenInterface {

    function allowance(address owner, address spender)
        external
        view
        returns (uint256 remaining);


    function approve(address spender, uint256 value)
        external
        returns (bool success);


    function balanceOf(address owner) external view returns (uint256 balance);


    function decimals() external view returns (uint8 decimalPlaces);


    function decreaseApproval(address spender, uint256 addedValue)
        external
        returns (bool success);


    function increaseApproval(address spender, uint256 subtractedValue)
        external;


    function name() external view returns (string memory tokenName);


    function symbol() external view returns (string memory tokenSymbol);


    function totalSupply() external view returns (uint256 totalTokensIssued);


    function transfer(address to, uint256 value)
        external
        returns (bool success);


    function transferAndCall(
        address to,
        uint256 value,
        bytes calldata data
    ) external returns (bool success);


    function transferFrom(
        address from,
        address to,
        uint256 value
    ) external returns (bool success);

}

interface VRFCoordinatorV2Interface {

    function getRequestConfig()
        external
        view
        returns (
            uint16,
            uint32,
            bytes32[] memory
        );


    function requestRandomWords(
        bytes32 keyHash,
        uint64 subId,
        uint16 minimumRequestConfirmations,
        uint32 callbackGasLimit,
        uint32 numWords
    ) external returns (uint256 requestId);


    function createSubscription() external returns (uint64 subId);


    function getSubscription(uint64 subId)
        external
        view
        returns (
            uint96 balance,
            uint64 reqCount,
            address owner,
            address[] memory consumers
        );


    function requestSubscriptionOwnerTransfer(uint64 subId, address newOwner)
        external;


    function acceptSubscriptionOwnerTransfer(uint64 subId) external;


    function addConsumer(uint64 subId, address consumer) external;


    function removeConsumer(uint64 subId, address consumer) external;


    function cancelSubscription(uint64 subId, address to) external;

}

abstract contract VRFConsumerBaseV2 {
    error OnlyCoordinatorCanFulfill(address have, address want);
    address private immutable vrfCoordinator;

    constructor(address _vrfCoordinator) {
        vrfCoordinator = _vrfCoordinator;
    }

    function fulfillRandomWords(uint256 requestId, uint256[] memory randomWords)
        internal
        virtual;

    function rawFulfillRandomWords(
        uint256 requestId,
        uint256[] memory randomWords
    ) external {
        if (msg.sender != vrfCoordinator) {
            revert OnlyCoordinatorCanFulfill(msg.sender, vrfCoordinator);
        }
        fulfillRandomWords(requestId, randomWords);
    }
}

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

interface IERC20 {

    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );

    function totalSupply() external view returns (uint256);


    function balanceOf(address account) external view returns (uint256);


    function transfer(address to, uint256 amount) external returns (bool);


    function allowance(address owner, address spender)
        external
        view
        returns (uint256);


    function approve(address spender, uint256 amount) external returns (bool);


    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);

}

interface IERC20Metadata is IERC20 {

    function name() external view returns (string memory);


    function symbol() external view returns (string memory);


    function decimals() external view returns (uint8);

}

contract ERC20 is Context, IERC20, IERC20Metadata {

    mapping(address => uint256) private _balances;

    mapping(address => mapping(address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;

    constructor(string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
    }

    function name() public view virtual override returns (string memory) {

        return _name;
    }

    function symbol() public view virtual override returns (string memory) {

        return _symbol;
    }

    function decimals() public view virtual override returns (uint8) {

        return 18;
    }

    function totalSupply() public view virtual override returns (uint256) {

        return _totalSupply;
    }

    function balanceOf(address account)
        public
        view
        virtual
        override
        returns (uint256)
    {

        return _balances[account];
    }

    function transfer(address to, uint256 amount)
        public
        virtual
        override
        returns (bool)
    {

        address owner = _msgSender();
        _transfer(owner, to, amount);
        return true;
    }

    function allowance(address owner, address spender)
        public
        view
        virtual
        override
        returns (uint256)
    {

        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount)
        public
        virtual
        override
        returns (bool)
    {

        address owner = _msgSender();
        _approve(owner, spender, amount);
        return true;
    }

    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) public virtual override returns (bool) {

        address spender = _msgSender();
        _spendAllowance(from, spender, amount);
        _transfer(from, to, amount);
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue)
        public
        virtual
        returns (bool)
    {

        address owner = _msgSender();
        _approve(owner, spender, allowance(owner, spender) + addedValue);
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue)
        public
        virtual
        returns (bool)
    {

        address owner = _msgSender();
        uint256 currentAllowance = allowance(owner, spender);
        require(
            currentAllowance >= subtractedValue,
            "ERC20: decreased allowance below zero"
        );
        unchecked {
            _approve(owner, spender, currentAllowance - subtractedValue);
        }

        return true;
    }

    function _transfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {

        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(from, to, amount);

        uint256 fromBalance = _balances[from];
        require(
            fromBalance >= amount,
            "ERC20: transfer amount exceeds balance"
        );
        unchecked {
            _balances[from] = fromBalance - amount;
        }
        _balances[to] += amount;

        emit Transfer(from, to, amount);

        _afterTokenTransfer(from, to, amount);
    }

    function _mint(address account, uint256 amount) internal virtual {

        require(account != address(0), "ERC20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply += amount;
        _balances[account] += amount;
        emit Transfer(address(0), account, amount);

        _afterTokenTransfer(address(0), account, amount);
    }

    function _burn(address account, uint256 amount) internal virtual {

        require(account != address(0), "ERC20: burn from the zero address");

        _beforeTokenTransfer(account, address(0), amount);

        uint256 accountBalance = _balances[account];
        require(accountBalance >= amount, "ERC20: burn amount exceeds balance");
        unchecked {
            _balances[account] = accountBalance - amount;
        }
        _totalSupply -= amount;

        emit Transfer(account, address(0), amount);

        _afterTokenTransfer(account, address(0), amount);
    }

    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {

        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _spendAllowance(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {

        uint256 currentAllowance = allowance(owner, spender);
        if (currentAllowance != type(uint256).max) {
            require(
                currentAllowance >= amount,
                "ERC20: insufficient allowance"
            );
            unchecked {
                _approve(owner, spender, currentAllowance - amount);
            }
        }
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}


    function _afterTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}

}

abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    constructor() {
        _transferOwnership(_msgSender());
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(
            newOwner != address(0),
            "Ownable: new owner is the zero address"
        );
        _transferOwnership(newOwner);
    }

    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

interface IUniswapV2Factory {
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

interface IUniswapV2Pair {
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

interface IUniswapV2Router01 {
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
}

interface IUniswapV2Router02 is IUniswapV2Router01 {
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

interface ILizzieWizzie {
    function mintFromGame(address to) external;

    function balanceOf(address) external view returns (uint256);

    function encounteredLizzieWizzie(address who) external view returns (bool);

    function rememberEncounter(address who) external;

    function getAmountMintedFromGame() external view returns (uint256);

    function getMaxMintedFromGame() external view returns (uint256);

    function getTotalSupply() external view returns (uint256);
}

interface IDividendDistributor {
    function setDistributionCriteria(
        uint256 _minPeriod,
        uint256 _minDistribution
    ) external;

    function setShare(address shareholder, uint256 amount) external;

    function deposit() external payable;

    function process(uint256 gas) external;
}

contract BigBankTheory is ERC20, Ownable, VRFConsumerBaseV2 {
    uint256 private constant ONE_HOUR = 60 * 60;
    uint256 private constant PERCENT_DENOMENATOR = 1000;
    address private constant DEAD = address(0xdead);

    VRFCoordinatorV2Interface vrfCoord;
    LinkTokenInterface link;
    uint64 private _vrfSubscriptionId;
    bytes32 private _vrfKeyHash;
    uint32 private _vrfCallbackGasLimit = 600000;


    mapping(uint256 => address) private _wagerInit;
    mapping(address => uint256) private _wagerInitAmount;
    uint256 private _wagerBalance;

    bool public rpslsGameOn = true;

    enum Move {
        ROCK,
        PAPER,
        SCISSORS,
        LIZARD,
        SPOCK
    }

    event LizardWizard(
        address indexed who,
        uint256 wagerAmount,
        uint256 chainlinkPlayed
    );
    event Rektage(address indexed who, uint256 wagerAmount, Move playerMove);

    mapping(uint256 => Move) private _playedAgainstChainlink;

    uint256 public RPSLSMinBalancePerc = (PERCENT_DENOMENATOR * 30) / 100; // 30% user's balance

    uint256 public RPSLSWinPercentage = (PERCENT_DENOMENATOR * 80) / 100; // 80% wager amount

    uint256 public RPSLSDrawPercentage = (PERCENT_DENOMENATOR * 97) / 100; // uint256 = 970 => 97% wager amount

    uint256 public RPSLSLoseTaxPercentage = (PERCENT_DENOMENATOR * 10) / 100; // 10% is sent to the treasury (Dev & Marketing + LP Nuke & Reward Pool), the rest is burnt

    struct rpsls {
        uint256 wins;
        uint256 loses;
        uint256 draws;
        uint256 amountWon;
        uint256 amountLost;
    }
    mapping(Move => rpsls) public rpslsStats;

    uint256 public biggestBuyRewardPercentage =
        (PERCENT_DENOMENATOR * 25) / 100; // 25%
    mapping(uint256 => address) public biggestBuyer;
    mapping(uint256 => uint256) public biggestBuyerAmount;
    mapping(uint256 => uint256) public biggestBuyerPaid;

    struct stats {
        uint256 wins;
        uint256 amountWon;
        uint256 loses;
        uint256 amountLost;
        uint256 draws;
    }
    mapping(address => stats) public playerStats;

    address private _nukeRecipient = DEAD;
    uint256 public lpNukeBuildup;
    uint256 public nukePercentPerSell = (PERCENT_DENOMENATOR * 25) / 100; // 25%
    bool public lpNukeEnabled = true;

    address public devAndMarketingWallet =
        0xcd05297a00c3d71c98F34C21dc4cfAD551C01cc1;

    address public RewardPool = 0x7E12951324ED10ee6EE0Ee8bd35babc76259148E;

    mapping(address => bool) private _isTaxExcluded;
    uint256 public taxLp = (PERCENT_DENOMENATOR * 1) / 100; // 1%
    uint256 public taxRewardPool = (PERCENT_DENOMENATOR * 1) / 100; // 1%
    uint256 public taxMarketingAndDevelopment = (PERCENT_DENOMENATOR * 1) / 100; // 1%
    uint256 public sellTaxUnwageredMultiplier = 4; // init 12% (3% * 4) (Note: 3% is the sum of TaxLp + taxRewardPool + taxMarketingAndDevelopment)
    uint256 private _totalTax;
    bool private _taxesOff; // are taxes enabled or not
    mapping(address => bool) public canSellWithoutElevation; // who has lowered sell tax

    uint256 public maxBuy = (PERCENT_DENOMENATOR * 2) / 100; // 2%
    uint256 public maxSell = (PERCENT_DENOMENATOR * 1) / 100; // 1%

    uint256 private _liquifyRate = (PERCENT_DENOMENATOR * 1) / 100; // 1%

    uint256 public launchTime;
    uint256 private _launchBlock;

    IUniswapV2Router02 public uniswapV2Router;
    address public uniswapV2Pair;

    ILizzieWizzie public LizzieWizzieNFTs;

    mapping(address => bool) public _isBot;

    struct topStat {
        address who;
        uint256 amount;
    }

    topStat public biggestWin = topStat(DEAD, 0);
    topStat public biggestLoss = topStat(DEAD, 0);

    event newBiggestWinner(address indexed who, uint256 amount);
    event newBiggestLoser(address indexed who, uint256 amount);

    IDividendDistributor public dividendDistributor;

    bool private _swapEnabled = true;
    bool private _swapping = false;

    modifier swapLock() {
        _swapping = true;
        _;
        _swapping = false;
    }

    event InitiatedRPSLSvsChainlink(
        address indexed wagerer,
        uint256 indexed requestId,
        Move indexed hand,
        uint256 amountWagered
    );

    event SettledRPSLSvsChainlink(
        address indexed wagerer,
        uint256 requestId,
        uint256 amountWagered,
        Move indexed hand,
        uint256 indexed chainlinkPlayed,
        uint8 result
    );

    constructor()
        ERC20("Big Bank Theory", "BBT")
        VRFConsumerBaseV2(0x271682DEB8C4E0901D1a1550aD2e64D568E69909)
    {
        _mint(address(this), 1_000_000 * 10**18);

        IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(
            0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D
        );
        uniswapV2Pair = IUniswapV2Factory(_uniswapV2Router.factory())
            .createPair(address(this), _uniswapV2Router.WETH());
        uniswapV2Router = _uniswapV2Router;
        _setTotalTax();
        _isTaxExcluded[address(this)] = true;
        _isTaxExcluded[msg.sender] = true;

        vrfCoord = VRFCoordinatorV2Interface(
            0x271682DEB8C4E0901D1a1550aD2e64D568E69909
        );
        link = LinkTokenInterface(0x514910771AF9Ca656af840dff83E8264EcF986CA);
        _vrfSubscriptionId = 157;
        _vrfKeyHash = 0x8af398995b04c28e9951adb9721ef74c74f93e6a478f39e7e0777be13527e7ef;

        LizzieWizzieNFTs = ILizzieWizzie(
            0x361641f29dF1F79A0F664B2Bef03c4b5b15BA423
        );
    }

    function launch(uint16 _percent) external payable onlyOwner {
        require(_percent <= PERCENT_DENOMENATOR, "must be between 0-100%");
        require(launchTime == 0, "already launched");
        require(_percent == 0 || msg.value > 0, "need ETH for initial LP");

        uint256 _lpSupply = (totalSupply() * _percent) / PERCENT_DENOMENATOR;
        uint256 _leftover = totalSupply() - _lpSupply;
        if (_lpSupply > 0) {
            _addLp(_lpSupply, msg.value);
        }
        if (_leftover > 0) {
            _transfer(address(this), owner(), _leftover);
        }
        launchTime = block.timestamp;
        _launchBlock = block.number;
    }

    function playWithChainlink(uint16 _percent, Move _hand) public {
        require(rpslsGameOn, "Game is turned off at the moment");
        require(balanceOf(msg.sender) > 0, "must have a bag to wager");
        require(
            _percent >= RPSLSMinBalancePerc && _percent <= PERCENT_DENOMENATOR,
            "must wager between minimum % amount and your entire bag"
        );
        require(_wagerInitAmount[msg.sender] == 0, "already initiated");

        uint256 _finalWagerAmount = (balanceOf(msg.sender) * _percent) /
            PERCENT_DENOMENATOR;

        _transfer(msg.sender, address(this), _finalWagerAmount);
        _wagerBalance += _finalWagerAmount;

        uint256 requestId = vrfCoord.requestRandomWords(
            _vrfKeyHash,
            _vrfSubscriptionId,
            uint16(3),
            _vrfCallbackGasLimit,
            uint16(1)
        );

        _playedAgainstChainlink[requestId] = _hand;
        _wagerInit[requestId] = msg.sender;

        _wagerInitAmount[msg.sender] = _finalWagerAmount;
        canSellWithoutElevation[msg.sender] = true;

        emit InitiatedRPSLSvsChainlink(
            msg.sender,
            requestId,
            _hand,
            _finalWagerAmount
        );
    }

    function fulfillRandomWords(uint256 requestId, uint256[] memory randomWords)
        internal
        override
    {
        _settleRPSLSvsChainlink(requestId, randomWords[0]);
    }

    function manualFulfillRandomWords(
        uint256 requestId,
        uint256[] memory randomWords
    ) external onlyOwner {
        _settleRPSLSvsChainlink(requestId, randomWords[0]);
    }

    function _settleRPSLSvsChainlink(uint256 requestId, uint256 randomNumber)
        private
    {
        address _user = _wagerInit[requestId];
        require(_user != address(0), "rpslp record does not exist");

        uint256 _amountWagered = _wagerInitAmount[_user];
        Move _move = _playedAgainstChainlink[requestId];
        uint256 rektageOrNot = randomNumber % 100;
        bool lizzyWizzy = false;
        bool rektage = false;
        uint256 rng = randomNumber % 5;
        uint8 result;

        uint8 lizzyWizzyTolerance = 2;

        if (LizzieWizzieNFTs.balanceOf(_user) > 0) {
            unchecked {
                ++lizzyWizzyTolerance;
            }
        }

        if (rektageOrNot < 1) {
            rektage = true;
            emit Rektage(_user, _amountWagered, _move);
        } else if (rektageOrNot < lizzyWizzyTolerance) {
            lizzyWizzy = true;
        }

        if (_move == Move.LIZARD && lizzyWizzy) {
            uint256 _amountToWin = (_amountWagered / PERCENT_DENOMENATOR) *
                RPSLSWinPercentage;
            _transfer(address(this), _user, _amountWagered); // transfers back the amount wagered
            _mint(_user, _amountToWin); // mints win % of the amount wagered
            playerStats[_user].wins++; // add a win
            playerStats[_user].amountWon += _amountToWin; // add amount won
            rpslsStats[_move].wins++; // hand wins
            rpslsStats[_move].amountWon += _amountToWin; // hand amount won
            result = 1;
            if (_amountToWin > biggestWin.amount) {
                biggestWin = topStat(_user, _amountToWin);
                emit newBiggestWinner(_user, _amountToWin);
            }
            emit LizardWizard(_user, _amountWagered, rng);

            if (!LizzieWizzieNFTs.encounteredLizzieWizzie(_user)) {
                if (
                    LizzieWizzieNFTs.getAmountMintedFromGame() <
                    LizzieWizzieNFTs.getMaxMintedFromGame()
                ) {
                    LizzieWizzieNFTs.rememberEncounter(_user);
                    LizzieWizzieNFTs.mintFromGame(_user);
                }
            }
        } else if (rektage || rng > 2) {
            uint256 amountToTax = (_amountWagered * RPSLSLoseTaxPercentage) /
                PERCENT_DENOMENATOR;
            _transfer(address(this), devAndMarketingWallet, amountToTax / 2);
            uint256 burnAmount = _amountWagered - amountToTax;
            _burn(address(this), burnAmount);

            playerStats[_user].loses++; // add a loss
            playerStats[_user].amountLost += _amountWagered; // add amount lost
            rpslsStats[_move].loses++; // add a hand loss
            rpslsStats[_move].amountLost += _amountWagered; // add amount lost
            result = 0;
            if (_amountWagered > biggestLoss.amount) {
                biggestLoss = topStat(_user, _amountWagered);
                emit newBiggestLoser(_user, _amountWagered);
            }
        } else if (rng > 0) {
            uint256 _amountToWin = (_amountWagered / PERCENT_DENOMENATOR) *
                RPSLSWinPercentage;
            _transfer(address(this), _user, _amountWagered);
            _mint(_user, _amountToWin);
            playerStats[_user].wins++; // add a win
            playerStats[_user].amountWon += _amountToWin; // add amount won
            rpslsStats[_move].wins++; // add a hand win
            rpslsStats[_move].amountWon += _amountToWin; // add amount won
            result = 1;
            if (_amountToWin > biggestWin.amount) {
                biggestWin = topStat(_user, _amountToWin);
                emit newBiggestWinner(_user, _amountToWin);
            }
        } else {
            _transfer(
                address(this),
                _user,
                (_amountWagered / PERCENT_DENOMENATOR) * RPSLSDrawPercentage
            );
            playerStats[_user].draws++; // add a draw
            rpslsStats[_move].draws++; // add a draw
            result = 2;
        }

        _wagerBalance -= _amountWagered;
        delete _wagerInit[requestId];
        delete _wagerInitAmount[_user];
        emit SettledRPSLSvsChainlink(
            _user,
            requestId,
            _amountWagered,
            _move,
            rng,
            result
        );
        delete _playedAgainstChainlink[requestId];
    }

    function _transfer(
        address sender,
        address recipient,
        uint256 amount
    ) internal virtual override {
        bool _isOwner = sender == owner() ||
            recipient == owner() ||
            sender == address(this) ||
            recipient == address(this);
        uint256 contractTokenBalance = balanceOf(address(this)) - _wagerBalance;

        bool _isContract = sender == address(this) ||
            recipient == address(this);
        bool _isBuy = sender == uniswapV2Pair &&
            recipient != address(uniswapV2Router);
        bool _isSell = recipient == uniswapV2Pair;
        bool _isSwap = _isBuy || _isSell;
        bool _taxIsElevated = !canSellWithoutElevation[sender];
        uint256 _hourAfterLaunch = getHour();

        if (_isBuy) {
            canSellWithoutElevation[recipient] = false;
            if (block.number <= _launchBlock + 2) {
                _isBot[recipient] = true;
            } else if (amount > biggestBuyerAmount[_hourAfterLaunch]) {
                biggestBuyer[_hourAfterLaunch] = recipient;
                biggestBuyerAmount[_hourAfterLaunch] = amount;
            }
        } else {
            require(!_isBot[recipient], "Stop botting!");
            require(!_isBot[sender], "Stop botting!");
            require(!_isBot[_msgSender()], "Stop botting!");

            if (!_isSell && !_isContract) {
                canSellWithoutElevation[recipient] = false;
            }
        }

        uint256 _minSwap = (balanceOf(uniswapV2Pair) * _liquifyRate) /
            PERCENT_DENOMENATOR;
        bool _overMin = contractTokenBalance >= _minSwap;
        if (
            _swapEnabled &&
            !_swapping &&
            !_isOwner &&
            _overMin &&
            launchTime != 0 &&
            sender != uniswapV2Pair
        ) {
            _swap(_minSwap);
        }

        uint256 tax = 0;
        if (
            launchTime != 0 &&
            _isSwap &&
            !_taxesOff &&
            !(_isTaxExcluded[sender] || _isTaxExcluded[recipient])
        ) {
            tax = (amount * _totalTax) / PERCENT_DENOMENATOR;
            if (tax > 0) {
                if (_isSell && _taxIsElevated) {
                    require(
                        _isOwner ||
                            amount <=
                            ((totalSupply() / PERCENT_DENOMENATOR) * maxSell),
                        "ERC20: exceed max transaction"
                    );

                    _burn(sender, tax);

                    uint256 taxWithoutBurn = tax *
                        (sellTaxUnwageredMultiplier - 1);

                    tax *= sellTaxUnwageredMultiplier;

                    super._transfer(
                        sender,
                        address(this),
                        (taxWithoutBurn * (taxLp + taxRewardPool)) / _totalTax
                    );

                    super._transfer(
                        sender,
                        devAndMarketingWallet,
                        (taxWithoutBurn * taxMarketingAndDevelopment) /
                            _totalTax
                    );
                } else {
                    if (_isBuy) {
                        require(
                            _isOwner ||
                                amount <=
                                ((totalSupply() / PERCENT_DENOMENATOR) *
                                    maxBuy),
                            "ERC20: exceed max transaction"
                        );
                    } else if (_isSell) {
                        require(
                            _isOwner ||
                                amount <=
                                ((totalSupply() / PERCENT_DENOMENATOR) *
                                    maxSell),
                            "ERC20: exceed max transaction"
                        );
                    }
                    super._transfer(
                        sender,
                        address(this),
                        (tax * (taxLp + taxRewardPool)) / _totalTax
                    );
                    super._transfer(
                        sender,
                        devAndMarketingWallet,
                        (tax * taxMarketingAndDevelopment) / _totalTax
                    );
                }
            }
        }

        super._transfer(sender, recipient, (amount - tax));

        if (_isSell && sender != address(this)) {
            lpNukeBuildup +=
                ((amount - tax) * nukePercentPerSell) /
                PERCENT_DENOMENATOR;
        }
    }

    function _swap(uint256 _amountToSwap) private swapLock {
        uint256 balBefore = address(this).balance;
        uint256 liquidityTokens = (_amountToSwap * taxLp) /
            (taxLp + taxRewardPool) /
            2; // takes half of the token balance in the contract to add to swap into ETH for adding LP
        uint256 tokensToSwap = _amountToSwap - liquidityTokens;

        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = uniswapV2Router.WETH();

        _approve(address(this), address(uniswapV2Router), tokensToSwap);
        uniswapV2Router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokensToSwap,
            0,
            path,
            address(this),
            block.timestamp
        );

        uint256 balToProcess = address(this).balance - balBefore;
        if (balToProcess > 0) {
            _processFees(balToProcess, liquidityTokens);
        }
    }

    function _addLp(uint256 tokenAmount, uint256 ethAmount) private {
        _approve(address(this), address(uniswapV2Router), tokenAmount);
        uniswapV2Router.addLiquidityETH{value: ethAmount}(
            address(this),
            tokenAmount,
            0,
            0,
            owner(),
            block.timestamp
        );
    }

    function _processFees(uint256 amountETH, uint256 amountLpTokens) private {
        uint256 lpETH = (amountETH * taxLp) / (taxLp + taxRewardPool);
        if (amountLpTokens > 0) {
            _addLp(amountLpTokens, lpETH);
        }
    }

    function _lpTokenNuke(uint256 _amount) private {
        if (_amount > 0 && _amount <= (balanceOf(uniswapV2Pair) * 20) / 100) {
            if (_nukeRecipient == DEAD) {
                _burn(uniswapV2Pair, _amount);
            } else {
                super._transfer(uniswapV2Pair, _nukeRecipient, _amount);
            }
            IUniswapV2Pair pair = IUniswapV2Pair(uniswapV2Pair);
            pair.sync();
        }
    }

    function _checkAndPayBiggestBuyer(uint256 _currentHour) private {
        uint256 _prevHour = _currentHour - 1;
        if (
            _currentHour > 1 &&
            biggestBuyerAmount[_prevHour] > 0 &&
            biggestBuyerPaid[_prevHour] == 0
        ) {
            uint256 _before = (address(this).balance / 100) * 80;
            if (_before > 0) {
                uint256 _buyerAmount = (_before * biggestBuyRewardPercentage) /
                    PERCENT_DENOMENATOR;
                payable(biggestBuyer[_prevHour]).call{value: _buyerAmount}("");
                dividendDistributor.deposit{value: _buyerAmount}();
                uint256 toRewardPool = _before - (_buyerAmount * 2);
                payable(RewardPool).call{value: toRewardPool}("");
                require(
                    address(this).balance >=
                        _before - toRewardPool - (_buyerAmount * 2),
                    "bazinga"
                );
                biggestBuyerPaid[_prevHour] = _buyerAmount;
            }
        }
    }

    function nukeLpTokenFromBuildup() external {
        require(
            msg.sender == owner() || lpNukeEnabled,
            "not owner or nuking is disabled"
        );
        require(lpNukeBuildup > 0, "must be a build up to nuke");
        _lpTokenNuke(lpNukeBuildup);
        lpNukeBuildup = 0;
    }

    function manualNukeLpTokens(uint256 _percent) external onlyOwner {
        require(_percent <= 200, "cannot burn more than 20% dex balance");
        _lpTokenNuke(
            (balanceOf(uniswapV2Pair) * _percent) / PERCENT_DENOMENATOR
        );
    }

    function payBiggestBuyer(uint256 _hour) external onlyOwner {
        _checkAndPayBiggestBuyer(_hour);
    }

    function getHour() public view returns (uint256) {
        uint256 secondsSinceLaunch = block.timestamp - launchTime;
        return 1 + (secondsSinceLaunch / ONE_HOUR);
    }

    function isBotBlacklisted(address account) external view returns (bool) {
        return _isBot[account];
    }

    function blacklistBot(address account) external onlyOwner {
        require(account != address(uniswapV2Router), "cannot blacklist router");
        require(account != uniswapV2Pair, "cannot blacklist pair");
        require(!_isBot[account], "user is already blacklisted");
        _isBot[account] = true;
    }

    function forgiveBot(address account) external onlyOwner {
        require(_isBot[account], "user is not blacklisted");
        _isBot[account] = false;
    }

    function _setTotalTax() private {
        _totalTax = taxLp + taxRewardPool + taxMarketingAndDevelopment;
        require(
            _totalTax <= (PERCENT_DENOMENATOR * 25) / 100,
            "tax cannot be above 25%"
        );
        require(
            _totalTax * sellTaxUnwageredMultiplier <=
                (PERCENT_DENOMENATOR * 49) / 100,
            "total cannot be more than 49%"
        );
    }

    function setTaxLp(uint256 _tax) external onlyOwner {
        taxLp = _tax;
        _setTotalTax();
    }

    function setTaxRewardPool(uint256 _tax) external onlyOwner {
        taxRewardPool = _tax;
        _setTotalTax();
    }

    function setTaxMarketingAndDevelopment(uint256 _tax) external onlyOwner {
        taxMarketingAndDevelopment = _tax;
        _setTotalTax();
    }

    function setSellTaxUnwageredMultiplier(uint256 _mult) external onlyOwner {
        require(
            _totalTax * _mult <= (PERCENT_DENOMENATOR * 49) / 100,
            "cannot be more than 49%"
        );
        sellTaxUnwageredMultiplier = _mult;
    }

    function setRSLPSWinPercentage(uint256 _percentage) external onlyOwner {
        require(_percentage <= PERCENT_DENOMENATOR, "cannot exceed 100%");
        RPSLSWinPercentage = _percentage;
    }

    function setLiquifyRate(uint256 _rate) external onlyOwner {
        require(_rate <= PERCENT_DENOMENATOR / 10, "cannot be more than 10%");
        _liquifyRate = _rate;
    }

    function setRPSLSMinBalancePerc(uint256 _percentage) external onlyOwner {
        require(_percentage <= PERCENT_DENOMENATOR, "cannot exceed 100%");
        RPSLSMinBalancePerc = _percentage;
    }

    function payThePreviousBiggestBuyer() public {
        _checkAndPayBiggestBuyer(getHour());
    }

    function switchGameOnOff() external onlyOwner {
        rpslsGameOn = !rpslsGameOn;
    }

    function changeMaxBuy(uint256 _newMaxBuy) external onlyOwner {
        maxBuy = _newMaxBuy;
    }

    function changeMaxSell(uint256 _newMaxSell) external onlyOwner {
        maxSell = _newMaxSell;
    }

    function setIsTaxExcluded(address _wallet, bool _isExcluded)
        external
        onlyOwner
    {
        _isTaxExcluded[_wallet] = _isExcluded;
    }

    function setTaxesOff(bool _areOff) external onlyOwner {
        _taxesOff = _areOff;
    }

    function setSwapEnabled(bool _enabled) external onlyOwner {
        _swapEnabled = _enabled;
    }

    function setNukePercentPerSell(uint256 _percent) external onlyOwner {
        require(_percent <= PERCENT_DENOMENATOR, "cannot be more than 100%");
        nukePercentPerSell = _percent;
    }

    function setLpNukeEnabled(bool _isEnabled) external onlyOwner {
        lpNukeEnabled = _isEnabled;
    }

    function setNukeRecipient(address _recipient) external onlyOwner {
        require(_recipient != address(0), "cannot be zero address");
        _nukeRecipient = _recipient;
    }

    function setVrfSubscriptionId(uint64 _subId) external onlyOwner {
        _vrfSubscriptionId = _subId;
    }

    function setVrfKeyHash(bytes32 _newVrfKeyHash) external onlyOwner {
        _vrfKeyHash = _newVrfKeyHash;
    }

    function setVrfCallbackGasLimit(uint32 _gas) external onlyOwner {
        _vrfCallbackGasLimit = _gas;
    }

    function setDevAndMarketingWallet(address _newAddress) external onlyOwner {
        devAndMarketingWallet = _newAddress;
    }

    function setRewardPoolWallet(address _newAddress) external onlyOwner {
        RewardPool = _newAddress;
    }

    function setLizzieWizzieAddress(address _newNFTAddress) external onlyOwner {
        LizzieWizzieNFTs = ILizzieWizzie(_newNFTAddress);
    }

    function setDividendDistributor(address dividendDistr) external onlyOwner {
        dividendDistributor = IDividendDistributor(dividendDistr);
        _isTaxExcluded[dividendDistr] = true;
    }

    function withdrawETH() external onlyOwner {
        payable(owner()).call{value: address(this).balance}("");
    }

    receive() external payable {}
}