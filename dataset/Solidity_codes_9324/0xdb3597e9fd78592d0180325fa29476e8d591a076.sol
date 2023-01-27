
pragma solidity ^0.8.0;

library Math {

    function max(uint256 a, uint256 b) internal pure returns (uint256) {

        return a >= b ? a : b;
    }

    function min(uint256 a, uint256 b) internal pure returns (uint256) {

        return a < b ? a : b;
    }

    function average(uint256 a, uint256 b) internal pure returns (uint256) {

        return (a & b) + (a ^ b) / 2;
    }

    function ceilDiv(uint256 a, uint256 b) internal pure returns (uint256) {

        return a / b + (a % b == 0 ? 0 : 1);
    }
}// MIT

pragma solidity ^0.8.0;


library Arrays {

    function findUpperBound(uint256[] storage array, uint256 element)
        internal
        view
        returns (uint256)
    {

        if (array.length == 0) {
            return 0;
        }

        uint256 low = 0;
        uint256 high = array.length;

        while (low < high) {
            uint256 mid = Math.average(low, high);

            if (array[mid] > element) {
                high = mid;
            } else {
                low = mid + 1;
            }
        }

        if (low > 0 && array[low - 1] == element) {
            return low - 1;
        } else {
            return low;
        }
    }
}// MIT

pragma solidity ^0.8.0;

library Counters {

    struct Counter {
        uint256 _value; // default: 0
    }

    function current(Counter storage counter) internal view returns (uint256) {

        return counter._value;
    }

    function increment(Counter storage counter) internal {

        unchecked {
            counter._value += 1;
        }
    }

    function decrement(Counter storage counter) internal {

        uint256 value = counter._value;
        require(value > 0, "Counter: decrement overflow");
        unchecked {
            counter._value = value - 1;
        }
    }

    function reset(Counter storage counter) internal {

        counter._value = 0;
    }
}// MIT
pragma solidity ^0.8.0;

interface IERC20 {

    function totalSupply() external view returns (uint256);


    function balanceOf(address account) external view returns (uint256);


    function transfer(address recipient, uint256 amount)
        external
        returns (bool);


    function allowance(address owner, address spender)
        external
        view
        returns (uint256);


    function approve(address spender, uint256 amount) external returns (bool);


    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);


    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
}// MIT

pragma solidity ^0.8.0;


interface IERC20Metadata is IERC20 {

    function name() external view returns (string memory);


    function symbol() external view returns (string memory);


    function decimals() external view returns (uint8);

}// MIT

pragma solidity ^0.8.0;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}// MIT

pragma solidity ^0.8.0;


contract ERC20 is Context, IERC20, IERC20Metadata {

    mapping(address => uint256) internal _balances;

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

    function transfer(address recipient, uint256 amount)
        public
        virtual
        override
        returns (bool)
    {

        _transfer(_msgSender(), recipient, amount);
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

        _approve(_msgSender(), spender, amount);
        return true;
    }

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public virtual override returns (bool) {

        _transfer(sender, recipient, amount);

        uint256 currentAllowance = _allowances[sender][_msgSender()];
        require(
            currentAllowance >= amount,
            "ERC20: transfer amount exceeds allowance"
        );
        unchecked {
            _approve(sender, _msgSender(), currentAllowance - amount);
        }

        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue)
        public
        virtual
        returns (bool)
    {

        _approve(
            _msgSender(),
            spender,
            _allowances[_msgSender()][spender] + addedValue
        );
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue)
        public
        virtual
        returns (bool)
    {

        uint256 currentAllowance = _allowances[_msgSender()][spender];
        require(
            currentAllowance >= subtractedValue,
            "ERC20: decreased allowance below zero"
        );
        unchecked {
            _approve(_msgSender(), spender, currentAllowance - subtractedValue);
        }

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

        uint256 senderBalance = _balances[sender];
        require(
            senderBalance >= amount,
            "ERC20: transfer amount exceeds balance"
        );
        unchecked {
            _balances[sender] = senderBalance - amount;
        }
        _balances[recipient] += amount;

        emit Transfer(sender, recipient, amount);

        _afterTokenTransfer(sender, recipient, amount);
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

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {} // solhint-disable-line


    function _afterTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {} // solhint-disable-line

}// MIT
pragma solidity ^0.8.0;

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

interface IUniswapV2Router is IUniswapV2Router01 {
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
}// MIT
pragma solidity ^0.8.0;

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
}// MIT
pragma solidity ^0.8.0;

library MyobuLib {
    function percentageOf(uint256 number, uint256 percentage)
        internal
        pure
        returns (uint256)
    {
        return (number * percentage) / 100;
    }

    function swapForETH(
        IUniswapV2Router uniswapV2Router,
        uint256 amount,
        address to
    ) internal returns (uint256) {
        uint256 startingBalance = to.balance;
        address[] memory path = new address[](2);

        path[0] = address(this);
        path[1] = uniswapV2Router.WETH();

        uniswapV2Router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            amount,
            0,
            path,
            to,
            block.timestamp
        );

        return to.balance - startingBalance;
    }

    function addLiquidityETH(
        IUniswapV2Router uniswapV2Router,
        uint256 amountToken,
        uint256 amountETH,
        address to
    ) internal {
        uniswapV2Router.addLiquidityETH{value: amountETH}(
            address(this),
            amountToken,
            0,
            0,
            to,
            block.timestamp
        );
    }

    function transferTokens(
        address token,
        address from,
        address to,
        uint256 amount
    ) internal {
        IERC20(token).transferFrom(from, to, amount);
    }

    function tokenFor(address pair) internal view returns (address) {
        return IUniswapV2Pair(pair).token0();
    }
}// MIT

pragma solidity ^0.8.0;


abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

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

    function renounceOwnership() external virtual onlyOwner {
        _setOwner(address(0));
    }

    function transferOwnership(address newOwner) external virtual onlyOwner {
        require(
            newOwner != address(0),
            "Ownable: new owner is the zero address"
        );
        _setOwner(newOwner);
    }

    function _setOwner(address newOwner) private {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}// MIT
pragma solidity ^0.8.0;

interface IUniswapV2Factory {
    function createPair(address tokenA, address tokenB)
        external
        returns (address pair);

    function getPair(address tokenA, address tokenB)
        external
        view
        returns (address pair);
}// MIT
pragma solidity ^0.8.0;

interface IMyobu is IERC20 {
    event DAOChanged(address newDAOContract);
    event MyobuSwapChanged(address newMyobuSwap);

    function DAO() external view returns (address); // solhint-disable-line

    function myobuSwap() external view returns (address);

    event TaxAddressChanged(address newTaxAddress);
    event TaxedTransferAddedFor(address[] addresses);
    event TaxedTransferRemovedFor(address[] addresses);

    event FeesTaken(uint256 teamFee);
    event FeesChanged(Fees newFees);

    struct Fees {
        uint256 impact;
        uint256 buyFee;
        uint256 sellFee;
        uint256 transferFee;
    }

    function currentFees() external view returns (Fees memory);

    struct LiquidityETHParams {
        address pair;
        address to;
        uint256 amountTokenOrLP;
        uint256 amountTokenMin;
        uint256 amountETHMin;
        uint256 deadline;
    }

    event LiquidityAddedETH(
        address pair,
        uint256 amountToken,
        uint256 amountETH,
        uint256 liquidity
    );

    function noFeeAddLiquidityETH(LiquidityETHParams calldata params)
        external
        payable
        returns (
            uint256 amountToken,
            uint256 amountETH,
            uint256 liquidity
        );

    event LiquidityRemovedETH(
        address pair,
        uint256 amountToken,
        uint256 amountETH,
        uint256 amountRemoved
    );

    function noFeeRemoveLiquidityETH(LiquidityETHParams calldata params)
        external
        returns (uint256 amountToken, uint256 amountETH);

    struct AddLiquidityParams {
        address pair;
        address to;
        uint256 amountToken;
        uint256 amountTokenB;
        uint256 amountTokenMin;
        uint256 amountTokenBMin;
        uint256 deadline;
    }

    event LiquidityAdded(
        address pair,
        uint256 amountMyobu,
        uint256 amountToken,
        uint256 liquidity
    );

    function noFeeAddLiquidity(AddLiquidityParams calldata params)
        external
        returns (
            uint256 amountMyobu,
            uint256 amountToken,
            uint256 liquidity
        );

    struct RemoveLiquidityParams {
        address pair;
        address to;
        uint256 amountLP;
        uint256 amountTokenMin;
        uint256 amountTokenBMin;
        uint256 deadline;
    }

    event LiquidityRemoved(
        address pair,
        uint256 amountMyobu,
        uint256 amountToken,
        uint256 liquidity
    );

    function noFeeRemoveLiquidity(RemoveLiquidityParams calldata params)
        external
        returns (uint256 amountMyobu, uint256 amountToken);

    function taxedPair(address pair) external view returns (bool);
}// MIT
pragma solidity ^0.8.0;


abstract contract MyobuBase is IMyobu, Ownable, ERC20 {
    uint256 internal constant MAX = type(uint256).max;

    uint256 private constant SUPPLY = 1000000000000 * 10**9;
    string internal constant NAME = unicode"Myōbu";
    string internal constant SYMBOL = "MYOBU";
    uint8 internal constant DECIMALS = 9;

    mapping(address => address) internal _routerFor;
    mapping(address => bool) private taxedTransfer;

    Fees private fees;

    address payable internal _taxAddress;

    IUniswapV2Router internal uniswapV2Router;
    address internal uniswapV2Pair;

    bool private tradingOpen;
    bool private liquidityAdded;
    bool private inSwap;
    bool private swapEnabled;

    modifier lockTheSwap() {
        inSwap = true;
        _;
        inSwap = false;
    }

    constructor(address payable addr1) ERC20(NAME, SYMBOL) {
        _taxAddress = addr1;
        _mint(_msgSender(), SUPPLY);
    }

    function decimals() public pure virtual override returns (uint8) {
        return DECIMALS;
    }

    function taxedPair(address pair)
        public
        view
        virtual
        override
        returns (bool)
    {
        return _routerFor[pair] != address(0);
    }

    function transferFee(address from, uint256 amount) internal {
        _balances[from] -= amount;
        _balances[address(this)] += amount;
    }

    function takeFee(
        address from,
        uint256 amount,
        uint256 teamFee
    ) internal returns (uint256) {
        if (teamFee == 0) return 0;
        uint256 tTeam = MyobuLib.percentageOf(amount, teamFee);
        transferFee(from, tTeam);
        emit FeesTaken(tTeam);
        return tTeam;
    }

    function _transfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual override {
        uint256 _teamFee;
        if (from != owner() && to != owner()) {
            if (swapEnabled && !inSwap) {
                if (taxedPair(from) && !taxedPair(to)) {
                    require(tradingOpen);
                    _teamFee = fees.buyFee;
                } else if (taxedTransfer[from] || taxedTransfer[to]) {
                    _teamFee = fees.transferFee;
                } else if (taxedPair(to)) {
                    require(tradingOpen);
                    require(amount <= (balanceOf(to) * fees.impact) / 100);
                    swapTokensForEth(balanceOf(address(this)));
                    sendETHToFee(address(this).balance);
                    _teamFee = fees.sellFee;
                }
            }
        }

        uint256 fee = takeFee(from, amount, _teamFee);
        super._transfer(from, to, amount - fee);
    }

    function swapTokensForEth(uint256 tokenAmount) internal lockTheSwap {
        MyobuLib.swapForETH(uniswapV2Router, tokenAmount, address(this));
    }

    function sendETHToFee(uint256 amount) internal {
        _taxAddress.transfer(amount);
    }

    function openTrading() external virtual onlyOwner {
        require(liquidityAdded);
        tradingOpen = true;
    }

    function addDEX(address pair, address router) public virtual onlyOwner {
        require(!taxedPair(pair), "DEX already exists");
        address tokenFor = MyobuLib.tokenFor(pair);
        _routerFor[pair] = router;
        _approve(address(this), router, MAX);
        IERC20(tokenFor).approve(router, MAX);
        IERC20(pair).approve(router, MAX);
    }

    function removeDEX(address pair) external virtual onlyOwner {
        require(taxedPair(pair), "DEX does not exist");
        address tokenFor = MyobuLib.tokenFor(pair);
        address router = _routerFor[pair];
        delete _routerFor[pair];
        _approve(address(this), router, 0);
        IERC20(tokenFor).approve(router, 0);
        IERC20(pair).approve(router, 0);
    }

    function addLiquidity() external virtual onlyOwner lockTheSwap {
        IUniswapV2Router _uniswapV2Router = IUniswapV2Router(
            0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D
        );
        uniswapV2Router = _uniswapV2Router;
        uniswapV2Pair = IUniswapV2Factory(_uniswapV2Router.factory())
            .createPair(address(this), _uniswapV2Router.WETH());
        addDEX(uniswapV2Pair, address(_uniswapV2Router));
        MyobuLib.addLiquidityETH(
            uniswapV2Router,
            balanceOf(address(this)),
            address(this).balance,
            owner()
        );
        liquidityAdded = true;
    }

    function setTaxAddress(address payable newTaxAddress) external onlyOwner {
        _taxAddress = newTaxAddress;
        emit TaxAddressChanged(newTaxAddress);
    }

    function setTaxedTransferFor(address[] calldata taxedTransfer_)
        external
        virtual
        onlyOwner
    {
        for (uint256 i; i < taxedTransfer_.length; i++) {
            taxedTransfer[taxedTransfer_[i]] = true;
        }
        emit TaxedTransferAddedFor(taxedTransfer_);
    }

    function removeTaxedTransferFor(address[] calldata notTaxed)
        external
        virtual
        onlyOwner
    {
        for (uint256 i; i < notTaxed.length; i++) {
            taxedTransfer[notTaxed[i]] = false;
        }
        emit TaxedTransferRemovedFor(notTaxed);
    }

    function manualswap() external onlyOwner {
        swapTokensForEth(balanceOf(address(this)));
    }

    function manualsend() external onlyOwner {
        sendETHToFee(address(this).balance);
    }

    function setSwapRouter(IUniswapV2Router newRouter) external onlyOwner {
        require(liquidityAdded, "Add liquidity before doing this");

        address weth = uniswapV2Router.WETH();
        address newPair = IUniswapV2Factory(newRouter.factory()).getPair(
            address(this),
            weth
        );
        require(
            newPair != address(0),
            "WETH Pair does not exist for that router"
        );
        require(taxedPair(newPair), "The pair must be a taxed pair");

        (uint256 reservesOld, , ) = IUniswapV2Pair(uniswapV2Pair).getReserves();
        (uint256 reservesNew, , ) = IUniswapV2Pair(newPair).getReserves();
        require(
            reservesNew > reservesOld,
            "New pair must have more WETH Reserves"
        );

        uniswapV2Router = newRouter;
        uniswapV2Pair = newPair;
    }

    function setFees(Fees memory newFees) public onlyOwner {
        require(
            newFees.impact != 0 && newFees.impact <= 100,
            "Impact must be greater than 0 and under or equal to 100"
        );
        require(
            newFees.buyFee < 15 &&
                newFees.sellFee < 15 &&
                newFees.transferFee <= newFees.sellFee,
            "Fees for a buy / sell must be under 15"
        );
        fees = newFees;

        if (newFees.buyFee + newFees.sellFee == 0) {
            swapEnabled = false;
        } else {
            swapEnabled = true;
        }

        emit FeesChanged(newFees);
    }

    function currentFees() external view override returns (Fees memory) {
        return fees;
    }

    receive() external payable virtual {}
}// MIT

pragma solidity ^0.8.0;



abstract contract ERC20Snapshot is MyobuBase {

    using Arrays for uint256[];
    using Counters for Counters.Counter;

    struct Snapshots {
        uint256[] ids;
        uint256[] values;
    }

    mapping(address => Snapshots) private _accountBalanceSnapshots;
    Snapshots private _totalSupplySnapshots;

    Counters.Counter private _currentSnapshotId;

    event Snapshot(uint256 id);

    function _snapshot() internal virtual returns (uint256) {
        _currentSnapshotId.increment();

        uint256 currentId = getCurrentSnapshotId();
        emit Snapshot(currentId);
        return currentId;
    }

    function getCurrentSnapshotId() public view virtual returns (uint256) {
        return _currentSnapshotId.current();
    }

    function balanceOfAt(address account, uint256 snapshotId)
        public
        view
        virtual
        returns (uint256)
    {
        (bool snapshotted, uint256 value) = _valueAt(
            snapshotId,
            _accountBalanceSnapshots[account]
        );

        return snapshotted ? value : balanceOf(account);
    }

    function totalSupplyAt(uint256 snapshotId)
        public
        view
        virtual
        returns (uint256)
    {
        (bool snapshotted, uint256 value) = _valueAt(
            snapshotId,
            _totalSupplySnapshots
        );

        return snapshotted ? value : totalSupply();
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual override {
        super._beforeTokenTransfer(from, to, amount);
        if (from == address(0)) {
            _updateAccountSnapshot(to);
            _updateTotalSupplySnapshot();
        } else if (to == address(0)) {
            _updateAccountSnapshot(from);
            _updateTotalSupplySnapshot();
        } else {
            _updateAccountSnapshot(from);
            _updateAccountSnapshot(to);
        }
    }

    function _valueAt(uint256 snapshotId, Snapshots storage snapshots)
        private
        view
        returns (bool, uint256)
    {
        require(snapshotId > 0, "ERC20Snapshot: id is 0");
        require(
            snapshotId <= getCurrentSnapshotId(),
            "ERC20Snapshot: nonexistent id"
        );


        uint256 index = snapshots.ids.findUpperBound(snapshotId);

        if (index == snapshots.ids.length) {
            return (false, 0);
        } else {
            return (true, snapshots.values[index]);
        }
    }

    function _updateAccountSnapshot(address account) private {
        _updateSnapshot(_accountBalanceSnapshots[account], balanceOf(account));
    }

    function _updateTotalSupplySnapshot() private {
        _updateSnapshot(_totalSupplySnapshots, totalSupply());
    }

    function _updateSnapshot(Snapshots storage snapshots, uint256 currentValue)
        private
    {
        uint256 currentId = getCurrentSnapshotId();
        if (_lastSnapshotId(snapshots.ids) < currentId) {
            snapshots.ids.push(currentId);
            snapshots.values.push(currentValue);
        }
    }

    function _lastSnapshotId(uint256[] storage ids)
        private
        view
        returns (uint256)
    {
        if (ids.length == 0) {
            return 0;
        } else {
            return ids[ids.length - 1];
        }
    }
}// MIT
pragma solidity ^0.8.0;


contract Myobu is ERC20Snapshot {
    address public override DAO; // solhint-disable-line
    address public override myobuSwap;

    bool private antiLiqBot;

    constructor(address payable addr1) MyobuBase(addr1) {
        setFees(Fees(10, 10, 10, 10));
    }

    modifier onlySupportedPair(address pair) {
        require(taxedPair(pair), "Pair is not supported");
        _;
    }

    modifier onlyMyobuswapOnAntiLiq() {
        require(!antiLiqBot || _msgSender() == myobuSwap, "Use MyobuSwap");
        _;
    }

    modifier checkDeadline(uint256 deadline) {
        require(block.timestamp <= deadline, "Transaction expired");
        _;
    }

    function setDAO(address newDAO) external onlyOwner {
        DAO = newDAO;
        emit DAOChanged(newDAO);
    }

    function setMyobuSwap(address newMyobuSwap) external onlyOwner {
        myobuSwap = newMyobuSwap;
        emit MyobuSwapChanged(newMyobuSwap);
    }

    function snapshot() external returns (uint256) {
        require(_msgSender() == owner() || _msgSender() == DAO);
        return _snapshot();
    }

    function setAntiLiqBot(bool setTo) external virtual onlyOwner {
        antiLiqBot = setTo;
    }

    function noFeeAddLiquidityETH(LiquidityETHParams calldata params)
        external
        payable
        override
        onlySupportedPair(params.pair)
        checkDeadline(params.deadline)
        onlyMyobuswapOnAntiLiq
        lockTheSwap
        returns (
            uint256 amountToken,
            uint256 amountETH,
            uint256 liquidity
        )
    {
        _transfer(_msgSender(), address(this), params.amountTokenOrLP);
        uint256 beforeBalance = address(this).balance - msg.value;
        (amountToken, amountETH, liquidity) = IUniswapV2Router(
            _routerFor[params.pair]
        ).addLiquidityETH{value: msg.value}(
            address(this),
            params.amountTokenOrLP,
            params.amountTokenMin,
            params.amountETHMin,
            params.to,
            block.timestamp
        );
        if (address(this).balance > beforeBalance) {
            payable(_msgSender()).transfer(
                address(this).balance - beforeBalance
            );
        }
        emit LiquidityAddedETH(params.pair, amountToken, amountETH, liquidity);
    }

    function noFeeRemoveLiquidityETH(LiquidityETHParams calldata params)
        external
        override
        onlySupportedPair(params.pair)
        checkDeadline(params.deadline)
        lockTheSwap
        returns (uint256 amountToken, uint256 amountETH)
    {
        MyobuLib.transferTokens(
            params.pair,
            _msgSender(),
            address(this),
            params.amountTokenOrLP
        );
        (amountToken, amountETH) = IUniswapV2Router(_routerFor[params.pair])
            .removeLiquidityETH(
                address(this),
                params.amountTokenOrLP,
                params.amountTokenMin,
                params.amountETHMin,
                params.to,
                block.timestamp
            );
        emit LiquidityRemovedETH(
            params.pair,
            amountToken,
            amountETH,
            params.amountTokenOrLP
        );
    }

    function noFeeAddLiquidity(AddLiquidityParams calldata params)
        external
        override
        onlySupportedPair(params.pair)
        checkDeadline(params.deadline)
        onlyMyobuswapOnAntiLiq
        lockTheSwap
        returns (
            uint256 amountMyobu,
            uint256 amountToken,
            uint256 liquidity
        )
    {
        address token = MyobuLib.tokenFor(params.pair);
        uint256 beforeBalance = IERC20(token).balanceOf(address(this));
        _transfer(_msgSender(), address(this), params.amountToken);
        MyobuLib.transferTokens(
            token,
            _msgSender(),
            address(this),
            params.amountTokenB
        );
        (amountToken, amountMyobu, liquidity) = IUniswapV2Router(
            _routerFor[params.pair]
        ).addLiquidity(
                token,
                address(this),
                params.amountTokenB,
                params.amountToken,
                params.amountTokenBMin,
                params.amountTokenMin,
                params.to,
                block.timestamp
            );
        uint256 currentBalance = IERC20(token).balanceOf(address(this));
        if (currentBalance > beforeBalance) {
            IERC20(token).transfer(
                _msgSender(),
                currentBalance - beforeBalance
            );
        }
        emit LiquidityAdded(params.pair, amountMyobu, amountToken, liquidity);
    }

    function noFeeRemoveLiquidity(RemoveLiquidityParams calldata params)
        external
        override
        onlySupportedPair(params.pair)
        checkDeadline(params.deadline)
        lockTheSwap
        returns (uint256 amountMyobu, uint256 amountToken)
    {
        MyobuLib.transferTokens(
            params.pair,
            _msgSender(),
            address(this),
            params.amountLP
        );
        (amountToken, amountMyobu) = IUniswapV2Router(_routerFor[params.pair])
            .removeLiquidity(
                MyobuLib.tokenFor(params.pair),
                address(this),
                params.amountLP,
                params.amountTokenBMin,
                params.amountTokenMin,
                params.to,
                block.timestamp
            );
        emit LiquidityRemoved(
            params.pair,
            amountMyobu,
            amountToken,
            params.amountLP
        );
    }
}