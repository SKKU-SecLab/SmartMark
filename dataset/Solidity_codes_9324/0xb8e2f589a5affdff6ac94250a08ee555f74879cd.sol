

pragma solidity 0.5.12;

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
}

contract Context {

    constructor() internal {}

    function _msgSender() internal view returns (address payable) {

        return msg.sender;
    }

    function _msgData() internal view returns (bytes memory) {

        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
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

        return mod(a, b, "SafeMath: modulo by zero");
    }

    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {

        require(b != 0, errorMessage);
        return a % b;
    }
}

contract ERC20 is Context, IERC20 {

    using SafeMath for uint256;

    mapping(address => uint256) private _balances;

    mapping(address => mapping(address => uint256)) private _allowances;

    uint256 private _totalSupply;

    function totalSupply() public view returns (uint256) {

        return _totalSupply;
    }

    function balanceOf(address account) public view returns (uint256) {

        return _balances[account];
    }

    function transfer(address recipient, uint256 amount) public returns (bool) {

        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function allowance(address owner, address spender)
        public
        view
        returns (uint256)
    {

        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public returns (bool) {

        _approve(_msgSender(), spender, amount);
        return true;
    }

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public returns (bool) {

        _transfer(sender, recipient, amount);
        _approve(
            sender,
            _msgSender(),
            _allowances[sender][_msgSender()].sub(
                amount,
                "ERC20: transfer amount exceeds allowance"
            )
        );
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue)
        public
        returns (bool)
    {

        _approve(
            _msgSender(),
            spender,
            _allowances[_msgSender()][spender].add(addedValue)
        );
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue)
        public
        returns (bool)
    {

        _approve(
            _msgSender(),
            spender,
            _allowances[_msgSender()][spender].sub(
                subtractedValue,
                "ERC20: decreased allowance below zero"
            )
        );
        return true;
    }

    function _transfer(
        address sender,
        address recipient,
        uint256 amount
    ) internal {

        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        _balances[sender] = _balances[sender].sub(
            amount,
            "ERC20: transfer amount exceeds balance"
        );
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
    }

    function _mint(address account, uint256 amount) internal {

        require(account != address(0), "ERC20: mint to the zero address");

        _totalSupply = _totalSupply.add(amount);
        _balances[account] = _balances[account].add(amount);
        emit Transfer(address(0), account, amount);
    }

    function _burn(address account, uint256 amount) internal {

        require(account != address(0), "ERC20: burn from the zero address");

        _balances[account] = _balances[account].sub(
            amount,
            "ERC20: burn amount exceeds balance"
        );
        _totalSupply = _totalSupply.sub(amount);
        emit Transfer(account, address(0), amount);
    }

    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) internal {

        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }
}

contract ERC20Detailed is IERC20 {

    string private _name;
    string private _symbol;
    uint8 private _decimals;

    constructor(
        string memory name,
        string memory symbol,
        uint8 decimals
    ) public {
        _name = name;
        _symbol = symbol;
        _decimals = decimals;
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

contract StockLiquiditator is ERC20, ERC20Detailed {

    using SafeMath for uint256;

    uint256 public cashDecimals;
    uint256 public stockTokenMultiplier;

    ERC20Detailed public cash;
    ERC20Detailed public stockToken;

    uint256 public stockToCashRate;
    uint256 public poolToCashRate;
    uint256 public cashValauationCap;

    string public url;

    event UrlUpdated(string _url);
    event ValuationCapUpdated(uint256 cashCap);
    event OwnerChanged(address indexed newOwner);
    event PoolRateUpdated(uint256 poolrate);
    event PoolTokensMinted(
        address indexed user,
        uint256 inputCashAmount,
        uint256 mintedPoolAmount
    );
    event PoolTokensBurnt(
        address indexed user,
        uint256 burntPoolAmount,
        uint256 outputStockAmount,
        uint256 outputCashAmount
    );
    event StockTokensRedeemed(
        address indexed user,
        uint256 redeemedStockToken,
        uint256 outputCashAmount
    );

    function() external {
    }

    address payable public owner;

    modifier onlyOwner() {

        require(msg.sender == owner, "Account not Owner");
        _;
    }

    constructor(
        address cashAddress,
        address stockTokenAddress,
        uint256 _stockToCashRate,
        uint256 cashCap,
        string memory name,
        string memory symbol,
        string memory _url
    ) public ERC20Detailed(name, symbol, 18) {
        require(
            msg.sender != address(0),
            "Zero address cannot be owner/contract deployer"
        );
        owner = msg.sender;
        require(
            stockTokenAddress != address(0),
            "stockToken is the zero address"
        );
        require(cashAddress != address(0), "cash is the zero address");
        require(_stockToCashRate != 0, "Stock to cash rate can't be zero");
        cash = ERC20Detailed(cashAddress);
        stockToken = ERC20Detailed(stockTokenAddress);
        cashDecimals = cash.decimals();
        stockTokenMultiplier = (10**uint256(stockToken.decimals()));
        stockToCashRate = (10**(cashDecimals)).mul(_stockToCashRate);
        updatePoolRate();
        updateCashValuationCap(cashCap);
        updateURL(_url);
    }

    function updateURL(string memory _url)
        public
        onlyOwner
        returns (string memory)
    {

        url = _url;
        emit UrlUpdated(_url);
        return url;
    }

    function updateCashValuationCap(uint256 cashCap)
        public
        onlyOwner
        returns (uint256)
    {

        cashValauationCap = cashCap;
        emit ValuationCapUpdated(cashCap);
        return cashValauationCap;
    }

    function changeOwner(address payable newOwner) external onlyOwner {

        owner = newOwner;
        emit OwnerChanged(newOwner);
    }

    function stockTokenAddress() public view returns (address) {

        return address(stockToken);
    }

    function _preValidateData(address beneficiary, uint256 amount)
        internal
        pure
    {

        require(beneficiary != address(0), "Beneficiary can't be zero address");
        require(amount != 0, "amount can't be 0");
    }

    function contractCashBalance() public view returns (uint256 cashBalance) {

        return cash.balanceOf(address(this));
    }

    function contractStockTokenBalance()
        public
        view
        returns (uint256 stockTokenBalance)
    {

        return stockToken.balanceOf(address(this));
    }

    function stockTokenCashValuation() internal view returns (uint256) {

        uint256 cashEquivalent = (
            contractStockTokenBalance().mul(stockToCashRate)
        )
            .div(stockTokenMultiplier);
        return cashEquivalent;
    }

    function contractCashValuation()
        public
        view
        returns (uint256 cashValauation)
    {

        uint256 cashEquivalent = (
            contractStockTokenBalance().mul(stockToCashRate)
        )
            .div(stockTokenMultiplier);
        return contractCashBalance().add(cashEquivalent);
    }

    function updatePoolRate() public returns (uint256 poolrate) {

        if (totalSupply() == 0) {
            poolToCashRate = (10**(cashDecimals)).mul(1);
        } else {
            poolToCashRate = (
                (contractCashValuation().mul(1e18)).div(totalSupply())
            );
        }
        emit PoolRateUpdated(poolrate);
        return poolToCashRate;
    }

    function mintPoolToken(uint256 inputCashAmount) external {

        if (cashValauationCap != 0) {
            require(
                inputCashAmount.add(contractCashValuation()) <=
                    cashValauationCap,
                "inputCashAmount exceeds cashValauationCap"
            );
        }
        address sender = msg.sender;
        _preValidateData(sender, inputCashAmount);
        updatePoolRate();
        uint256 balanceBeforeTransfer = cash.balanceOf(address(this));
        cash.transferFrom(sender, address(this), inputCashAmount);
        uint256 balanceAfterTransfer = cash.balanceOf(address(this));
        require(
            balanceAfterTransfer == balanceBeforeTransfer.add(inputCashAmount),
            "Sent & Received Amount mismatched"
        );
        uint256 poolTokens = ((inputCashAmount.mul(1e18)).div(poolToCashRate));
        _mint(sender, poolTokens); //Minting  Pool Token
        emit PoolTokensMinted(sender, inputCashAmount, poolTokens);
    }

    function burnPoolToken(uint256 poolTokenAmount) external {

        address sender = msg.sender;
        _preValidateData(sender, poolTokenAmount);

        updatePoolRate();
        uint256 cashToRedeem = (
            (poolTokenAmount.mul(poolToCashRate)).div(1e18)
        );
        _burn(sender, poolTokenAmount);

        uint256 outputStockToken = 0;
        uint256 outputCashAmount = 0;

        if (stockTokenCashValuation() >= cashToRedeem) {
            outputStockToken = (
                (cashToRedeem.mul(stockTokenMultiplier)).div(stockToCashRate)
            ); //calculate stock token amount to be return
            stockToken.transfer(sender, outputStockToken);
        } else if (cashToRedeem > stockTokenCashValuation()) {
            outputStockToken = contractStockTokenBalance();
            outputCashAmount = cashToRedeem.sub(stockTokenCashValuation()); // calculate cash amount to be return
            stockToken.transfer(sender, outputStockToken);

            uint256 balanceBeforeTransfer = cash.balanceOf(sender);
            cash.transfer(sender, outputCashAmount);
            uint256 balanceAfterTransfer = cash.balanceOf(sender);
            require(
                balanceAfterTransfer ==
                    balanceBeforeTransfer.add(outputCashAmount),
                "Sent & Received Amount mismatched"
            );
        }
        emit PoolTokensBurnt(
            sender,
            poolTokenAmount,
            outputStockToken,
            outputCashAmount
        );
    }

    function redeemStockToken(uint256 stockTokenAmount) external {

        address sender = msg.sender;
        _preValidateData(sender, stockTokenAmount);
        stockToken.transferFrom(sender, address(this), stockTokenAmount);

        uint256 outputCashAmount = (stockTokenAmount.mul(stockToCashRate)).div(
            stockTokenMultiplier
        );
        uint256 balanceBeforeTransfer = cash.balanceOf(sender);
        cash.transfer(sender, outputCashAmount);
        uint256 balanceAfterTransfer = cash.balanceOf(sender);
        require(
            balanceAfterTransfer == balanceBeforeTransfer.add(outputCashAmount),
            "Sent & Received Amount mismatched"
        );
        emit StockTokensRedeemed(sender, stockTokenAmount, outputCashAmount);
    }
}


pragma solidity 0.5.12;


contract DeployFactory {

    event CashBoxAdded(
        address indexed cashBoxAddress,
        address indexed cashBoxOwner,
        address indexed assetTokenAddress,
        address cashTokenAddress,
        string url
    );

    address[] public cashBoxes;

    function createCashBox(
        address cashTokenAddress,
        address assetTokenAddress,
        uint256 assetToCashRate,
        uint256 cashCap,
        string memory name,
        string memory symbol,
        string memory url
    ) public returns (address newCashBox) {

        StockLiquiditator cashBox = new StockLiquiditator(
            cashTokenAddress,
            assetTokenAddress,
            assetToCashRate,
            cashCap,
            name,
            symbol,
            url
        );
        cashBox.changeOwner(msg.sender);

        cashBoxes.push(address(cashBox));
        emit CashBoxAdded(
            address(cashBox),
            msg.sender,
            assetTokenAddress,
            cashTokenAddress,
            url
        );
        return address(cashBox);
    }

    function getAllCashBoxes() public view returns (address[] memory) {

        return cashBoxes;
    }

    function getCashBoxesByUser(address account)
        external
        view
        returns (address[] memory)
    {

        uint256 len = cashBoxes.length;
        address[] memory cashBoxesByUser = new address[](len);
        uint256 index = 0;

        for (uint256 i = 0; i < len; i++) {
            address payable cashBoxAddress = address(uint160(cashBoxes[i]));
            StockLiquiditator cashbox = StockLiquiditator(cashBoxAddress);

            if (cashbox.owner() == account) {
                cashBoxesByUser[index] = cashBoxes[i];
                index++;
            }
        }

        address[] memory result = new address[](index);
        for (uint256 i = 0; i < result.length; i++) {
            result[i] = cashBoxesByUser[i];
        }

        return result;
    }
}