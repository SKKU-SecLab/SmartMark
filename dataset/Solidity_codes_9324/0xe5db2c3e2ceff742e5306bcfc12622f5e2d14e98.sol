
pragma solidity ^0.8.4;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

contract Ownable is Context {

    address private _owner;
    address private _previousOwner;
    uint256 private _lockTime;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor() {
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

    function getUnlockTime() public view returns (uint256) {

        return _lockTime;
    }


    function getTime() public view returns (uint256) {

        return block.timestamp;
    }

    function lock(uint256 time) public virtual onlyOwner {

        _previousOwner = _owner;
        _owner = address(0);
        _lockTime = block.timestamp + time;
        emit OwnershipTransferred(_owner, address(0));
    }

    function unlock() public virtual {

        require(_previousOwner == msg.sender, "You don't have permission to unlock");
        require(block.timestamp > _lockTime, "Contract is locked until 7 days");
        emit OwnershipTransferred(_owner, _previousOwner);
        _owner = _previousOwner;
    }
}

abstract contract ReentrancyGuard {

    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor() internal {
        _status = _NOT_ENTERED;
    }

    modifier nonReentrant() {
        require(_status != _ENTERED, "nonReentrant:: reentrant call");

        _status = _ENTERED;

        _;

        _status = _NOT_ENTERED;
    }

    modifier isHuman() {
        require(tx.origin == msg.sender, "isHuman:: sorry humans only");
        _;
    }
}

interface IERC20 {

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

interface IERC20Metadata is IERC20 {

    function name() external view returns (string memory);


    function symbol() external view returns (string memory);


    function decimals() external view returns (uint8);

}

contract ERC20 is Context, IERC20, IERC20Metadata {

    using SafeMath for uint256;

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

        return 9;
    }

    function totalSupply() public view virtual override returns (uint256) {

        return _totalSupply;
    }

    function balanceOf(address account) public view virtual override returns (uint256) {

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

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public virtual override returns (bool) {

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

    function _transfer(
        address sender,
        address recipient,
        uint256 amount
    ) internal virtual {

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

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}

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
}

interface IUniswapV2Factory {
    event PairCreated(address indexed token0, address indexed token1, address pair, uint256);

    function feeTo() external view returns (address);

    function feeToSetter() external view returns (address);

    function getPair(address tokenA, address tokenB) external view returns (address pair);

    function allPairs(uint256) external view returns (address pair);

    function allPairsLength() external view returns (uint256);

    function createPair(address tokenA, address tokenB) external returns (address pair);

    function setFeeTo(address) external;

    function setFeeToSetter(address) external;
}

interface IUniswapV2Pair {
    event Approval(address indexed owner, address indexed spender, uint256 value);
    event Transfer(address indexed from, address indexed to, uint256 value);

    function name() external pure returns (string memory);

    function symbol() external pure returns (string memory);

    function decimals() external pure returns (uint8);

    function totalSupply() external view returns (uint256);

    function balanceOf(address owner) external view returns (uint256);

    function allowance(address owner, address spender) external view returns (uint256);

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
    event Burn(address indexed sender, uint256 amount0, uint256 amount1, address indexed to);
    event Swap(address indexed sender, uint256 amount0In, uint256 amount1In, uint256 amount0Out, uint256 amount1Out, address indexed to);
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

    function burn(address to) external returns (uint256 amount0, uint256 amount1);

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

    function getAmountsOut(uint256 amountIn, address[] calldata path) external view returns (uint256[] memory amounts);

    function getAmountsIn(uint256 amountOut, address[] calldata path) external view returns (uint256[] memory amounts);
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

contract ClienteleCoin is ERC20, Ownable, ReentrancyGuard {
    using SafeMath for uint256;

    IUniswapV2Router02 public uniswapV2Router;
    address public immutable uniswapV2Pair;
    uint256 public liquidateTokensAtAmount = 1000 * (10**9);

    uint256 public constant TOTAL_SUPPLY = 137000000000000 * (10**9);

    bool public TDEnabled = false;
    uint256 public TD = 30 minutes;
    mapping(address => uint256) private _holderLastTransferTimestamp; // to hold last Transfers temporarily during launch
    mapping(address => uint256) private _soldTimes;
    mapping(address => uint256) private _boughtTimes;

    bool _feesEnabled = true;
    uint256 public constant ETH_REWARDS_FEE = 25;
    uint256 public constant MARKETING_FEE = 25;
    uint256 public constant DEV_FEE = 25;
    uint256 public impactFee = 200;
    uint256 public constant TOTAL_FEES = ETH_REWARDS_FEE + MARKETING_FEE + DEV_FEE;
    address public devWallet = 0x395DA634618C39675b560Aa5d321966672D6DC71;
    address public marketingWallet = 0xD7F7e7C412824C6f4F107453068e7c8062B0B488;
    address private _airdropAddress = 0xAcfE101cA7E2bc9Ee6a76Deaa9Bc6C9DAb0b5481;

    mapping(address => bool) private _isExcludedFromFees;
    uint256 public impactThreshold = 50;
    bool public priceImpactFeeDisabled = true;

    mapping(address => uint256) public nextAvailableClaimDate;
    uint256 public rewardCycleBlock = 2 days;
    uint256 threshHoldTopUpRate = 2;

    bool private liquidating = false;

    event UpdatedUniswapV2Router(address indexed newAddress, address indexed oldAddress);
    event CycleBlockUpdated(uint256 indexed newBlock, uint256 indexed OldBlock);
    event ImpactFeeUpdated(uint256 indexed newFee, uint256 indexed oldFee);
    event ThresholdFeeUpdated(uint256 indexed newThreshold, uint256 indexed oldThreshold);
    event ImpactFeeDisableUpdated(bool indexed value);

    event LiquidationThresholdUpdated(uint256 indexed newValue, uint256 indexed oldValue);
    event TaxDistributed(uint256 tokensSwapped, uint256 ethReceived, uint256 rewardPoolGot, uint256 devGot, uint256 marketingGot);

    event ClaimSuccessfully(address recipient, uint256 ethReceived, uint256 nextAvailableClaimDate);

    constructor(address routerAddress) ERC20("ClienteleCoin", "CLT") {
        IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(routerAddress);
        address _uniswapV2Pair = IUniswapV2Factory(_uniswapV2Router.factory()).createPair(address(this), _uniswapV2Router.WETH());
        uniswapV2Router = _uniswapV2Router;
        uniswapV2Pair = _uniswapV2Pair;

        excludeFromFees(owner());
        excludeFromFees(address(this));

        _mint(owner(), TOTAL_SUPPLY);
    }

    receive() external payable {}

    function updateUniswapV2Router(address newAddress) public onlyOwner {
        require(newAddress != address(uniswapV2Router), "CLT: The router already has that address");
        emit UpdatedUniswapV2Router(newAddress, address(uniswapV2Router));
        uniswapV2Router = IUniswapV2Router02(newAddress);
    }

    function enableFees() public onlyOwner {
        _feesEnabled = true;
    }

    function disableFees() public onlyOwner {
        _feesEnabled = false;
    }

    function updateliquidateTokensAtAmount(uint256 newValue) public onlyOwner {
        liquidateTokensAtAmount = newValue;
    }

    function updateAirdropAddress(address airdropAddress) public onlyOwner {
        _airdropAddress = airdropAddress;
    }

    function updateRewardCycleBlock(uint256 newBlock) public onlyOwner {
        emit CycleBlockUpdated(newBlock, rewardCycleBlock);
        rewardCycleBlock = newBlock;
    }

    function updateImpactThreshold(uint256 newValue) public onlyOwner {
        emit ThresholdFeeUpdated(newValue, impactThreshold);
        impactThreshold = newValue;
    }

    function updateImpactFee(uint256 newValue) public onlyOwner {
        emit ImpactFeeUpdated(newValue, impactFee);
        impactFee = newValue;
    }

    function updateImpactFeeDisabled(bool newValue) public onlyOwner {
        emit ImpactFeeDisableUpdated(newValue);
        priceImpactFeeDisabled = newValue;
    }

    function excludeFromFees(address account) public onlyOwner {
        _isExcludedFromFees[account] = true;
    }

    function includeToFees(address account) public onlyOwner {
        _isExcludedFromFees[account] = false;
    }

    function updateLiquidationThreshold(uint256 newValue) external onlyOwner {
        emit LiquidationThresholdUpdated(newValue, liquidateTokensAtAmount);
        liquidateTokensAtAmount = newValue;
    }

    function activateTD() external onlyOwner {
        TDEnabled = true;
    }

    function DisableTD() external onlyOwner {
        TDEnabled = false;
    }

    function setTDTime(uint256 delay) public onlyOwner returns (bool) {
        TD = delay; // in seconds
        return true;
    }

    function getPriceImpactFee(uint256 amount) public view returns (uint256) {
        if (priceImpactFeeDisabled) return 0;

        IUniswapV2Pair pair = IUniswapV2Pair(uniswapV2Pair);
        address token0 = pair.token0();
        address token1 = pair.token1();
        uint256 reserve0;
        uint256 reserve1;

        if (token0 == address(this)) {
            (reserve1, reserve0, ) = pair.getReserves();
        } else if (token1 == address(this)) {
            (reserve0, reserve1, ) = pair.getReserves();
        }

        if (reserve0 == 0 && reserve1 == 0) {
            return 0;
        }

        uint256 amountB = uniswapV2Router.getAmountIn(amount, reserve0, reserve1);
        uint256 priceImpact = reserve0.sub(reserve0.sub(amountB)).mul(10000) / reserve0;

        if (priceImpact >= impactThreshold) {
            return impactFee;
        }

        return 0;
    }

    function _transfer(
        address from,
        address to,
        uint256 amount
    ) internal override {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");

        if (amount == 0) {
            super._transfer(from, to, 0);
            return;
        }

        if (TDEnabled && !liquidating) {
            if (from == address(uniswapV2Pair)) {
                uint256 multiplier = _boughtTimes[to] == 1 ? 2 : 1;
                require(
                    (_holderLastTransferTimestamp[to].add(TD.mul(multiplier)) <= block.timestamp) || _isExcludedFromFees[to],
                    "_transfer:: Transfer Delay enabled.  Please try again after the tx block passess"
                );
                _holderLastTransferTimestamp[to] = block.timestamp;
                _boughtTimes[to] = _boughtTimes[to] + 1;
            } else if (to == address(uniswapV2Pair)) {
                uint256 multiplier = _soldTimes[from] == 1 ? 2 : 1;
                require(
                    (_holderLastTransferTimestamp[from].add(TD.mul(multiplier)) <= block.timestamp) || _isExcludedFromFees[from],
                    "_transfer:: Transfer Delay enabled.  Please try again after the tx block passess"
                );
                _holderLastTransferTimestamp[from] = block.timestamp;
                _soldTimes[to] = _soldTimes[to] + 1;
            } else {
                require(
                    (_holderLastTransferTimestamp[from].add(TD.mul(2)) <= block.timestamp) || _isExcludedFromFees[from],
                    "_transfer:: Transfer Delay enabled.  Please try again after the tx block passess"
                );
                _holderLastTransferTimestamp[from] = block.timestamp;
            }
        }

        if (from == _airdropAddress) {
            _holderLastTransferTimestamp[to] = block.timestamp + 2 hours;
        }

        uint256 contractTokenBalance = balanceOf(address(this));
        bool canSwap = contractTokenBalance >= liquidateTokensAtAmount;
        if (canSwap && from != address(uniswapV2Pair)) swapAndDistributeRewards(contractTokenBalance);

        bool takeFee = false;
        if ((to == address(uniswapV2Pair) && !_isExcludedFromFees[from]) || (from == address(uniswapV2Pair) && !_isExcludedFromFees[to])) {
            takeFee = true;
        }

        if (liquidating) takeFee = false;

        if (takeFee && _feesEnabled) {
            uint256 rewardPoolAmount = amount.mul(ETH_REWARDS_FEE).div(1000);
            uint256 marketingAmount = amount.mul(MARKETING_FEE).div(1000);
            uint256 devAmount = amount.mul(DEV_FEE).div(1000);
            uint256 priceFee = getPriceImpactFee(amount.sub(rewardPoolAmount).sub(marketingAmount).sub(devAmount));
            uint256 impactFeeAmount = amount.mul(priceFee).div(1000);
            uint256 sendAmount = amount.sub(rewardPoolAmount).sub(marketingAmount).sub(devAmount);

            sendAmount = sendAmount.sub(impactFeeAmount);
            uint256 taxAmount = amount.sub(sendAmount);

            require(amount == sendAmount.add(taxAmount), "CLT::transfer: Tax value invalid");

            super._transfer(from, address(this), taxAmount);

            amount = sendAmount;
        }

        topUpClaimCycleAfterTransfer(to, amount);

        super._transfer(from, to, amount);
    }

    function swapAndDistributeRewards(uint256 tokens) private {

        uint256 initialBalance = address(this).balance;

        if (!liquidating) {
            liquidating = true;

            swapTokensForEth(tokens);

            uint256 newBalance = address(this).balance.sub(initialBalance);

            uint256 toRewardPool = newBalance.div(3);
            uint256 toDevWallet = toRewardPool;
            uint256 toMarketingWallet = newBalance.sub(toDevWallet).sub(toRewardPool);

            address(marketingWallet).call{value: toMarketingWallet}("");
            address(devWallet).call{value: toDevWallet}("");

            liquidating = false;
            emit TaxDistributed(tokens, newBalance, toRewardPool, toDevWallet, toMarketingWallet);
        }
    }

    function swapTokensForEth(uint256 tokenAmount) private {
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = uniswapV2Router.WETH();

        _approve(address(this), address(uniswapV2Router), tokenAmount);

        uniswapV2Router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount,
            0, // accept any amount of ETH
            path,
            address(this),
            block.timestamp
        );
    }


    function calculateReward(address ofAddress) public view returns (uint256) {
        uint256 totalSupply = totalSupply().sub(balanceOf(address(0))).sub(balanceOf(0x000000000000000000000000000000000000dEaD)).sub(balanceOf(address(uniswapV2Pair))); // exclude burned wallets //and uni pair

        uint256 poolValue = address(this).balance;
        uint256 currentBalance = balanceOf(address(ofAddress));
        uint256 reward = poolValue.mul(currentBalance).div(totalSupply);

        return reward;
    }

    function claimReward() public isHuman nonReentrant {
        require(nextAvailableClaimDate[msg.sender] <= block.timestamp, "Error: next available not reached");
        require(balanceOf(msg.sender) >= 0, "Error: must own token to claim reward");

        uint256 reward = calculateReward(msg.sender);

        nextAvailableClaimDate[msg.sender] = block.timestamp + rewardCycleBlock;
        emit ClaimSuccessfully(msg.sender, reward, nextAvailableClaimDate[msg.sender]);

        (bool sent, ) = address(msg.sender).call{value: reward}("");
        require(sent, "Error: Cannot withdraw reward");
    }

    function topUpClaimCycleAfterTransfer(address recipient, uint256 amount) private {
        uint256 currentRecipientBalance = balanceOf(recipient);
        uint256 additionalBlock = 0;
        if (nextAvailableClaimDate[recipient] + rewardCycleBlock < block.timestamp) nextAvailableClaimDate[recipient] = block.timestamp;

        if (currentRecipientBalance > 0) {
            uint256 rate = amount.mul(100).div(currentRecipientBalance);
            if (uint256(rate) >= threshHoldTopUpRate) {
                uint256 incurCycleBlock = rewardCycleBlock.mul(uint256(rate)).div(100);
                if (incurCycleBlock >= rewardCycleBlock) {
                    incurCycleBlock = rewardCycleBlock;
                }
                additionalBlock = incurCycleBlock;
            }
        } else {
            nextAvailableClaimDate[recipient] = nextAvailableClaimDate[recipient] + rewardCycleBlock;
        }
        nextAvailableClaimDate[recipient] = nextAvailableClaimDate[recipient] + additionalBlock;
    }
}