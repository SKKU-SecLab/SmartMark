pragma solidity >=0.6.2;

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

}pragma solidity >=0.6.2;


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

}pragma solidity >=0.5.0;

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

}// MIT

pragma solidity ^0.8.0;

interface IERC20 {

    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);

    function totalSupply() external view returns (uint256);


    function balanceOf(address account) external view returns (uint256);


    function transfer(address to, uint256 amount) external returns (bool);


    function allowance(address owner, address spender) external view returns (uint256);


    function approve(address spender, uint256 amount) external returns (bool);


    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);

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

    function balanceOf(address account) public view virtual override returns (uint256) {

        return _balances[account];
    }

    function transfer(address to, uint256 amount) public virtual override returns (bool) {

        address owner = _msgSender();
        _transfer(owner, to, amount);
        return true;
    }

    function allowance(address owner, address spender) public view virtual override returns (uint256) {

        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public virtual override returns (bool) {

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

    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {

        address owner = _msgSender();
        _approve(owner, spender, allowance(owner, spender) + addedValue);
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {

        address owner = _msgSender();
        uint256 currentAllowance = allowance(owner, spender);
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
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
        require(fromBalance >= amount, "ERC20: transfer amount exceeds balance");
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
            require(currentAllowance >= amount, "ERC20: insufficient allowance");
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

}// MIT

pragma solidity ^0.8.0;


abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

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
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }

    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}// MIT
pragma solidity 0.8.13;


abstract contract SimpleAccess is Ownable {
    
    constructor() Ownable() {}
    
    mapping(address => bool) public authorized;

    modifier onlyAuthorized() {
        require(
            authorized[msg.sender] || msg.sender == owner(),
            "Sender is not authorized"
        );
        _;
    }

    function setAuthorized(address _auth, bool _isAuth) external virtual onlyOwner {
        authorized[_auth] = _isAuth;
    }
}// MIT
pragma solidity ^0.8.13;


contract IEcoSystem {
    function getTotalProductionOfUser(address user, uint256[] memory flowersWithBees) external view returns (uint256) {}
}

contract ITaxManager {
    function getSpendTax(address user, uint256 amount, bytes memory data) external returns (uint128) {}
    function getBuyTax(address user, uint256 amount) external returns (uint256) {}
    function getSellTax(address user, uint256 amount) external returns (uint256) {}
}

contract Honey is ERC20, SimpleAccess {
    IEcoSystem public ecoSystem;
    ITaxManager public taxManager;
    address public mintPass;
    address public uniswapPair;


    struct EcoSystemBalance {
        uint128 deposit;
        uint256 spent;
    }
    mapping(address => EcoSystemBalance) public userEcoSystemBalance;

    mapping(address => bool) public liquidityPair;
    mapping(address => bool) public blacklisted;
    mapping(address => bool) public noFee;

    bool public whitelistActive;
    mapping(address => bool) public isWhiteListed;

    bool public buyLimitActive;
    uint256 public buyLimitTimePeriod = 1 days;
    uint256 public buyLimitAmount = 4000 ether;
    struct BuyLimit {
        uint128 bought;
        uint128 lastBuy;
    }
    mapping(address => BuyLimit) public userToBuyLimit;

    event SendToEcoSystem(address indexed user, uint256 indexed amount);
    event TakeFromEcoSytem(address indexed user, uint256 indexed amount);
    event TransferEcoSystemBalance(address indexed user, address indexed recipient, uint256 indexed amount);
    event SpendEcoSystemBalance(address indexed user, uint256 indexed amount, uint256 indexed tax);

    constructor(        
        address _router
    ) ERC20("HONEY COIN", "HONEYCOIN") {
        _mint(msg.sender, 1000000 ether);

        IUniswapV2Router02 router = IUniswapV2Router02(_router);
        uniswapPair = IUniswapV2Factory(router.factory()).createPair(
            router.WETH(),
            address(this)
        );

        whitelistActive = true;
        buyLimitActive = true;

        noFee[msg.sender] = true;
        noFee[uniswapPair] = true;
        isWhiteListed[msg.sender] = true;
        isWhiteListed[uniswapPair] = true;

        liquidityPair[uniswapPair] = true;
    }

    function getEcoSystemBalance(address user, uint256[] memory flowersWithBees) public view returns (uint256) {
        EcoSystemBalance memory ecoSystemBalance = userEcoSystemBalance[user];
        
        uint256 plusBalance = ecoSystem.getTotalProductionOfUser(user, flowersWithBees) + ecoSystemBalance.deposit;
        uint256 minBalance = ecoSystemBalance.spent;

        if (minBalance > plusBalance)
            return 0;

        return plusBalance - minBalance;
    }

    function sendToEcoSystem(uint128 amount) external {
        require(balanceOf(msg.sender) >= amount, "Not enough balance");
        
        _burn(msg.sender, amount);
        EcoSystemBalance storage ecoSystemBalance = userEcoSystemBalance[msg.sender];
        ecoSystemBalance.deposit += amount;

        emit SendToEcoSystem(msg.sender, amount);
    }

    function takeFromEcoSystem(uint128 amount, uint256[] memory flowersWithBees) external {
        require(getEcoSystemBalance(msg.sender, flowersWithBees) >= amount, "Eco system balance too low");

        _mint(msg.sender, amount);
        EcoSystemBalance storage ecoSystemBalance = userEcoSystemBalance[msg.sender];
        ecoSystemBalance.spent += amount;

        emit TakeFromEcoSytem(msg.sender, amount);
    }

    function transferEcoSystemBalance(address _to, uint128 amount, uint256[] memory flowersWithBees) external {
        require(getEcoSystemBalance(msg.sender, flowersWithBees) >= amount, "Eco system balance too low");

        EcoSystemBalance storage ecoSystemBalanceUser = userEcoSystemBalance[msg.sender];
        EcoSystemBalance storage ecoSystemBalanceReceiver = userEcoSystemBalance[_to];

        ecoSystemBalanceUser.spent += amount;
        ecoSystemBalanceReceiver.deposit += amount;

        emit TransferEcoSystemBalance(msg.sender, _to, amount);
    }

    function spendEcoSystemBalance(address user, uint128 amount, uint256[] memory flowersWithBees, bytes memory data) external onlyAuthorized {
        require(getEcoSystemBalance(user, flowersWithBees) >= amount, "Eco system balance too low");

        uint256 taxAmount = taxManager.getSpendTax(user, amount, data);

        if (taxAmount > 0)
            super._transfer(user, address(taxManager), taxAmount);

        EcoSystemBalance storage ecoSystemBalance = userEcoSystemBalance[user];
        ecoSystemBalance.spent += amount;

        emit SpendEcoSystemBalance(user, amount, taxAmount);
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal view override {
        require(!blacklisted[from] && !blacklisted[to], "SENDER / RECIPIENT BANNED");
    }

    function _transfer(
        address from,
        address to,
        uint256 amount
    ) internal override {
        if (whitelistActive)
            require(isWhiteListed[from] && isWhiteListed[to], "Sender not whitelisted");

        if (buyLimitActive && liquidityPair[from]) {
            BuyLimit storage limit = userToBuyLimit[to];
            uint256 boughtToday;
            uint256 diffSinceLastBuy = block.timestamp - limit.lastBuy;

            if (diffSinceLastBuy >= buyLimitTimePeriod) {
                boughtToday = amount;
            } else {
                uint256 nowModule = block.timestamp % buyLimitTimePeriod; // how far we are in the day now
                uint256 lastModulo = limit.lastBuy % buyLimitTimePeriod; // how far the last buy was in the day

                if (nowModule <= lastModulo) {
                    boughtToday = amount;
                } else { // if how far we are in the day now is greater than how far we were in the day at last buy then its the same day
                    boughtToday = amount + limit.bought;
                }
            }

            require(boughtToday <= buyLimitAmount, "Buy exceeds buy limit");

            limit.lastBuy = uint128(block.timestamp);
            limit.bought = uint128(boughtToday);
        }

        uint256 transferAmount = amount;

        if (liquidityPair[from] && !noFee[to])
            transferAmount -= taxManager.getBuyTax(to, transferAmount);
        else if (liquidityPair[to] && !noFee[from])
            transferAmount -= taxManager.getSellTax(from, transferAmount);

        uint256 tax = amount - transferAmount;
        if (tax > 0) 
            super._transfer(from, address(taxManager), tax);
        
        super._transfer(from, to, transferAmount);
    }

    function burn(address user, uint256 amount) external {
        require(mintPass != address(0));
        require(msg.sender == mintPass, "Only mint pass can burn honey");
        _burn(user, amount);
    }

    function withdraw() external onlyOwner {
        payable(msg.sender).transfer(address(this).balance);
    }

    function setEcosystem(address eco) external onlyOwner {
        ecoSystem = IEcoSystem(eco);
    }

    function setTaxManager(address manager) external onlyOwner {
        taxManager = ITaxManager(manager);
    }

    function setMintPass(address _mintPass) external onlyOwner {
        mintPass = _mintPass;
    }

    function setLiqPair(address liqpair, bool isliq) external onlyOwner {
        liquidityPair[liqpair] = isliq;
    }

    function setBlackListed(address bl, bool isbl) external onlyOwner {
        blacklisted[bl] = isbl;
    }

    function setNoFee(address nf, bool isnf) external onlyOwner {
        noFee[nf] = isnf;
    }

    function setWhiteListed(address wl, bool iswl) external onlyOwner {
        isWhiteListed[wl] = iswl;
    }

    function setWlActive(bool _active) external onlyOwner {
        whitelistActive = _active;
    }

    function configureBuyLimit(bool _active, uint256 _period, uint256 _amount) external onlyOwner {
        buyLimitActive = _active;
        buyLimitTimePeriod = _period;
        buyLimitAmount = _amount;
    }

    receive() external payable {}
}