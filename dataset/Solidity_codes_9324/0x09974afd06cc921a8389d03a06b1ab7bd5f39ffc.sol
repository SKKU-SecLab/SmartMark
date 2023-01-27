

pragma solidity ^0.5.0;

contract Context {

    constructor () internal { }

    function _msgSender() internal view returns (address payable) {

        return msg.sender;
    }

    function _msgData() internal view returns (bytes memory) {

        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}


pragma solidity ^0.5.0;

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


pragma solidity ^0.5.0;

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


pragma solidity ^0.5.0;




contract ERC20 is Context, IERC20 {

    using SafeMath for uint256;

    mapping (address => uint256) private _balances;

    mapping (address => mapping (address => uint256)) private _allowances;

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

    function allowance(address owner, address spender) public view returns (uint256) {

        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public returns (bool) {

        _approve(_msgSender(), spender, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) public returns (bool) {

        _transfer(sender, recipient, amount);
        _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount, "ERC20: transfer amount exceeds allowance"));
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public returns (bool) {

        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].add(addedValue));
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public returns (bool) {

        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].sub(subtractedValue, "ERC20: decreased allowance below zero"));
        return true;
    }

    function _transfer(address sender, address recipient, uint256 amount) internal {

        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        _balances[sender] = _balances[sender].sub(amount, "ERC20: transfer amount exceeds balance");
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

        _balances[account] = _balances[account].sub(amount, "ERC20: burn amount exceeds balance");
        _totalSupply = _totalSupply.sub(amount);
        emit Transfer(account, address(0), amount);
    }

    function _approve(address owner, address spender, uint256 amount) internal {

        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _burnFrom(address account, uint256 amount) internal {

        _burn(account, amount);
        _approve(account, _msgSender(), _allowances[account][_msgSender()].sub(amount, "ERC20: burn amount exceeds allowance"));
    }
}


pragma solidity ^0.5.0;

contract CompoundOracleInterface {



    constructor() public {
    }

    function getPrice(address asset) public view returns (uint);

    function getUnderlyingPrice(ERC20 cToken) public view returns (uint);


}


pragma solidity 0.5.10;


contract UniswapExchangeInterface {

    function tokenAddress() external view returns (address token);

    function factoryAddress() external view returns (address factory);

    function addLiquidity(uint256 min_liquidity, uint256 max_tokens, uint256 deadline) external payable returns (uint256);

    function removeLiquidity(uint256 amount, uint256 min_eth, uint256 min_tokens, uint256 deadline) external returns (uint256, uint256);

    function getEthToTokenInputPrice(uint256 eth_sold) external view returns (uint256 tokens_bought);

    function getEthToTokenOutputPrice(uint256 tokens_bought) external view returns (uint256 eth_sold);

    function getTokenToEthInputPrice(uint256 tokens_sold) external view returns (uint256 eth_bought);

    function getTokenToEthOutputPrice(uint256 eth_bought) external view returns (uint256 tokens_sold);

    function ethToTokenSwapInput(uint256 min_tokens, uint256 deadline) external payable returns (uint256  tokens_bought);

    function ethToTokenTransferInput(uint256 min_tokens, uint256 deadline, address recipient) external payable returns (uint256  tokens_bought);

    function ethToTokenSwapOutput(uint256 tokens_bought, uint256 deadline) external payable returns (uint256  eth_sold);

    function ethToTokenTransferOutput(uint256 tokens_bought, uint256 deadline, address recipient) external payable returns (uint256  eth_sold);

    function tokenToEthSwapInput(uint256 tokens_sold, uint256 min_eth, uint256 deadline) external returns (uint256  eth_bought);

    function tokenToEthTransferInput(uint256 tokens_sold, uint256 min_eth, uint256 deadline, address recipient) external returns (uint256  eth_bought);

    function tokenToEthSwapOutput(uint256 eth_bought, uint256 max_tokens, uint256 deadline) external returns (uint256  tokens_sold);

    function tokenToEthTransferOutput(uint256 eth_bought, uint256 max_tokens, uint256 deadline, address recipient) external returns (uint256  tokens_sold);

    function tokenToTokenSwapInput(uint256 tokens_sold, uint256 min_tokens_bought, uint256 min_eth_bought, uint256 deadline, address token_addr) external returns (uint256  tokens_bought);

    function tokenToTokenTransferInput(uint256 tokens_sold, uint256 min_tokens_bought, uint256 min_eth_bought, uint256 deadline, address recipient, address token_addr) external returns (uint256  tokens_bought);

    function tokenToTokenSwapOutput(uint256 tokens_bought, uint256 max_tokens_sold, uint256 max_eth_sold, uint256 deadline, address token_addr) external returns (uint256  tokens_sold);

    function tokenToTokenTransferOutput(uint256 tokens_bought, uint256 max_tokens_sold, uint256 max_eth_sold, uint256 deadline, address recipient, address token_addr) external returns (uint256  tokens_sold);

    function tokenToExchangeSwapInput(uint256 tokens_sold, uint256 min_tokens_bought, uint256 min_eth_bought, uint256 deadline, address exchange_addr) external returns (uint256  tokens_bought);

    function tokenToExchangeTransferInput(uint256 tokens_sold, uint256 min_tokens_bought, uint256 min_eth_bought, uint256 deadline, address recipient, address exchange_addr) external returns (uint256  tokens_bought);

    function tokenToExchangeSwapOutput(uint256 tokens_bought, uint256 max_tokens_sold, uint256 max_eth_sold, uint256 deadline, address exchange_addr) external returns (uint256  tokens_sold);

    function tokenToExchangeTransferOutput(uint256 tokens_bought, uint256 max_tokens_sold, uint256 max_eth_sold, uint256 deadline, address recipient, address exchange_addr) external returns (uint256  tokens_sold);

    bytes32 public name;
    bytes32 public symbol;
    uint256 public decimals;
    function transfer(address _to, uint256 _value) external returns (bool);

    function transferFrom(address _from, address _to, uint256 value) external returns (bool);

    function approve(address _spender, uint256 _value) external returns (bool);

    function allowance(address _owner, address _spender) external view returns (uint256);

    function balanceOf(address _owner) external view returns (uint256);

    function totalSupply() external view returns (uint256);

    function setup(address token_addr) external;

}


pragma solidity 0.5.10;


contract UniswapFactoryInterface {

    address public exchangeTemplate;
    uint256 public tokenCount;
    function createExchange(address token) external returns (address exchange);

    function getExchange(address token) external view returns (address exchange);

    function getToken(address exchange) external view returns (address token);

    function getTokenWithId(uint256 tokenId) external view returns (address token);

    function initializeFactory(address template) external;

}


pragma solidity 0.5.10;





contract OptionsUtils {

    UniswapFactoryInterface public UNISWAP_FACTORY;

    CompoundOracleInterface public COMPOUND_ORACLE;

    constructor(address _uniswapFactory, address _compoundOracle) public {
        UNISWAP_FACTORY = UniswapFactoryInterface(_uniswapFactory);
        COMPOUND_ORACLE = CompoundOracleInterface(_compoundOracle);
    }

    function getExchange(address _token)
        public
        view
        returns (UniswapExchangeInterface)
    {

        if (address(UNISWAP_FACTORY.getExchange(_token)) == address(0)) {
            revert("No payout exchange");
        }

        UniswapExchangeInterface exchange = UniswapExchangeInterface(
            UNISWAP_FACTORY.getExchange(_token)
        );

        return exchange;
    }

    function isETH(IERC20 _ierc20) public pure returns (bool) {

        return _ierc20 == IERC20(0);
    }
}


pragma solidity 0.5.10;






contract OptionsExchange {

    uint256 constant LARGE_BLOCK_SIZE = 1651753129000;
    uint256 constant LARGE_APPROVAL_NUMBER = 10**30;

    UniswapFactoryInterface public UNISWAP_FACTORY;

    constructor(address _uniswapFactory) public {
        UNISWAP_FACTORY = UniswapFactoryInterface(_uniswapFactory);
    }

    event SellOTokens(
        address seller,
        address payable receiver,
        address oTokenAddress,
        address payoutTokenAddress,
        uint256 oTokensToSell
    );
    event BuyOTokens(
        address buyer,
        address payable receiver,
        address oTokenAddress,
        address paymentTokenAddress,
        uint256 oTokensToBuy,
        uint256 premiumPaid
    );

    function sellOTokens(
        address payable receiver,
        address oTokenAddress,
        address payoutTokenAddress,
        uint256 oTokensToSell
    ) public {

        IERC20 oToken = IERC20(oTokenAddress);
        IERC20 payoutToken = IERC20(payoutTokenAddress);
        oToken.transferFrom(msg.sender, address(this), oTokensToSell);
        uniswapSellOToken(oToken, payoutToken, oTokensToSell, receiver);

        emit SellOTokens(
            msg.sender,
            receiver,
            oTokenAddress,
            payoutTokenAddress,
            oTokensToSell
        );
    }

    function buyOTokens(
        address payable receiver,
        address oTokenAddress,
        address paymentTokenAddress,
        uint256 oTokensToBuy
    ) public payable {

        IERC20 oToken = IERC20(oTokenAddress);
        IERC20 paymentToken = IERC20(paymentTokenAddress);
        uniswapBuyOToken(paymentToken, oToken, oTokensToBuy, receiver);
    }

    function premiumReceived(
        address oTokenAddress,
        address payoutTokenAddress,
        uint256 oTokensToSell
    ) public view returns (uint256) {

        UniswapExchangeInterface oTokenExchange = getExchange(oTokenAddress);
        uint256 ethReceived = oTokenExchange.getTokenToEthInputPrice(
            oTokensToSell
        );

        if (!isETH(IERC20(payoutTokenAddress))) {
            UniswapExchangeInterface payoutExchange = getExchange(
                payoutTokenAddress
            );
            return payoutExchange.getEthToTokenInputPrice(ethReceived);
        }
        return ethReceived;

    }

    function premiumToPay(
        address oTokenAddress,
        address paymentTokenAddress,
        uint256 oTokensToBuy
    ) public view returns (uint256) {

        UniswapExchangeInterface oTokenExchange = getExchange(oTokenAddress);
        uint256 ethToPay = oTokenExchange.getEthToTokenOutputPrice(
            oTokensToBuy
        );

        if (!isETH(IERC20(paymentTokenAddress))) {
            UniswapExchangeInterface paymentTokenExchange = getExchange(
                paymentTokenAddress
            );
            return paymentTokenExchange.getTokenToEthOutputPrice(ethToPay);
        }

        return ethToPay;
    }

    function uniswapSellOToken(
        IERC20 oToken,
        IERC20 payoutToken,
        uint256 _amt,
        address payable _transferTo
    ) internal returns (uint256) {

        require(!isETH(oToken), "Can only sell oTokens");
        UniswapExchangeInterface exchange = getExchange(address(oToken));

        if (isETH(payoutToken)) {
            oToken.approve(address(exchange), _amt);
            return
                exchange.tokenToEthTransferInput(
                    _amt,
                    1,
                    LARGE_BLOCK_SIZE,
                    _transferTo
                );
        } else {
            oToken.approve(address(exchange), _amt);
            return
                exchange.tokenToTokenTransferInput(
                    _amt,
                    1,
                    1,
                    LARGE_BLOCK_SIZE,
                    _transferTo,
                    address(payoutToken)
                );
        }
    }

    function uniswapBuyOToken(
        IERC20 paymentToken,
        IERC20 oToken,
        uint256 _amt,
        address payable _transferTo
    ) public returns (uint256) {

        require(!isETH(oToken), "Can only buy oTokens");

        if (!isETH(paymentToken)) {
            UniswapExchangeInterface exchange = getExchange(
                address(paymentToken)
            );

            uint256 paymentTokensToTransfer = premiumToPay(
                address(oToken),
                address(paymentToken),
                _amt
            );
            paymentToken.transferFrom(
                msg.sender,
                address(this),
                paymentTokensToTransfer
            );

            paymentToken.approve(address(exchange), LARGE_APPROVAL_NUMBER);

            emit BuyOTokens(
                msg.sender,
                _transferTo,
                address(oToken),
                address(paymentToken),
                _amt,
                paymentTokensToTransfer
            );

            return
                exchange.tokenToTokenTransferInput(
                    paymentTokensToTransfer,
                    1,
                    1,
                    LARGE_BLOCK_SIZE,
                    _transferTo,
                    address(oToken)
                );
        } else {
            UniswapExchangeInterface exchange = UniswapExchangeInterface(
                UNISWAP_FACTORY.getExchange(address(oToken))
            );

            uint256 ethToTransfer = exchange.getEthToTokenOutputPrice(_amt);

            emit BuyOTokens(
                msg.sender,
                _transferTo,
                address(oToken),
                address(paymentToken),
                _amt,
                ethToTransfer
            );

            return
                exchange.ethToTokenTransferOutput.value(ethToTransfer)(
                    _amt,
                    LARGE_BLOCK_SIZE,
                    _transferTo
                );
        }
    }

    function getExchange(address _token)
        internal
        view
        returns (UniswapExchangeInterface)
    {

        UniswapExchangeInterface exchange = UniswapExchangeInterface(
            UNISWAP_FACTORY.getExchange(_token)
        );

        if (address(exchange) == address(0)) {
            revert("No payout exchange");
        }

        return exchange;
    }

    function isETH(IERC20 _ierc20) internal pure returns (bool) {

        return _ierc20 == IERC20(0);
    }

    function() external payable {
    }

}


pragma solidity ^0.5.0;


contract ERC20Detailed is IERC20 {

    string private _name;
    string private _symbol;
    uint8 private _decimals;

    constructor (string memory name, string memory symbol, uint8 decimals) public {
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


pragma solidity ^0.5.0;

contract Ownable is Context {

    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor () internal {
        _owner = _msgSender();
        emit OwnershipTransferred(address(0), _owner);
    }

    function owner() public view returns (address) {

        return _owner;
    }

    modifier onlyOwner() {

        require(isOwner(), "Ownable: caller is not the owner");
        _;
    }

    function isOwner() public view returns (bool) {

        return _msgSender() == _owner;
    }

    function renounceOwnership() public onlyOwner {

        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    function transferOwnership(address newOwner) public onlyOwner {

        _transferOwnership(newOwner);
    }

    function _transferOwnership(address newOwner) internal {

        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}


pragma solidity 0.5.10;











contract OptionsContract is Ownable, ERC20 {

    using SafeMath for uint256;

    struct Number {
        uint256 value;
        int32 exponent;
    }

    struct Vault {
        uint256 collateral;
        uint256 oTokensIssued;
        uint256 underlying;
        bool owned;
    }

    OptionsExchange public optionsExchange;

    mapping(address => Vault) internal vaults;

    address payable[] internal vaultOwners;

    Number public liquidationIncentive = Number(10, -3);

    Number public transactionFee = Number(0, -3);

    Number public liquidationFactor = Number(500, -3);

    Number public minCollateralizationRatio = Number(16, -1);

    Number public strikePrice;

    Number public oTokenExchangeRate;

    uint256 internal windowSize;

    uint256 internal totalFee;

    uint256 public expiry;

    int32 public collateralExp = -18;

    int32 public underlyingExp = -18;

    IERC20 public collateral;

    IERC20 public underlying;

    IERC20 public strike;

    CompoundOracleInterface public COMPOUND_ORACLE;

    string public name;

    string public symbol;

    uint8 public decimals;

    constructor(
        IERC20 _collateral,
        int32 _collExp,
        IERC20 _underlying,
        int32 _underlyingExp,
        int32 _oTokenExchangeExp,
        uint256 _strikePrice,
        int32 _strikeExp,
        IERC20 _strike,
        uint256 _expiry,
        OptionsExchange _optionsExchange,
        address _oracleAddress,
        uint256 _windowSize
    ) public {
        require(block.timestamp < _expiry, "Can't deploy an expired contract");
        require(
            _windowSize <= _expiry,
            "Exercise window can't be longer than the contract's lifespan"
        );
        require(
            isWithinExponentRange(_collExp),
            "collateral exponent not within expected range"
        );
        require(
            isWithinExponentRange(_underlyingExp),
            "underlying exponent not within expected range"
        );
        require(
            isWithinExponentRange(_strikeExp),
            "strike price exponent not within expected range"
        );
        require(
            isWithinExponentRange(_oTokenExchangeExp),
            "oToken exchange rate exponent not within expected range"
        );

        collateral = _collateral;
        collateralExp = _collExp;

        underlying = _underlying;
        underlyingExp = _underlyingExp;
        oTokenExchangeRate = Number(1, _oTokenExchangeExp);

        strikePrice = Number(_strikePrice, _strikeExp);
        strike = _strike;

        expiry = _expiry;
        COMPOUND_ORACLE = CompoundOracleInterface(_oracleAddress);
        optionsExchange = _optionsExchange;
        windowSize = _windowSize;
    }

    event VaultOpened(address payable vaultOwner);
    event ETHCollateralAdded(
        address payable vaultOwner,
        uint256 amount,
        address payer
    );
    event ERC20CollateralAdded(
        address payable vaultOwner,
        uint256 amount,
        address payer
    );
    event IssuedOTokens(
        address issuedTo,
        uint256 oTokensIssued,
        address payable vaultOwner
    );
    event Liquidate(
        uint256 amtCollateralToPay,
        address payable vaultOwner,
        address payable liquidator
    );
    event Exercise(
        uint256 amtUnderlyingToPay,
        uint256 amtCollateralToPay,
        address payable exerciser,
        address payable vaultExercisedFrom
    );
    event RedeemVaultBalance(
        uint256 amtCollateralRedeemed,
        uint256 amtUnderlyingRedeemed,
        address payable vaultOwner
    );
    event BurnOTokens(address payable vaultOwner, uint256 oTokensBurned);
    event RemoveCollateral(uint256 amtRemoved, address payable vaultOwner);
    event UpdateParameters(
        uint256 liquidationIncentive,
        uint256 liquidationFactor,
        uint256 transactionFee,
        uint256 minCollateralizationRatio,
        address owner
    );
    event TransferFee(address payable to, uint256 fees);
    event RemoveUnderlying(
        uint256 amountUnderlying,
        address payable vaultOwner
    );

    modifier notExpired() {

        require(!hasExpired(), "Options contract expired");
        _;
    }

    function getVaultOwners() public view returns (address payable[] memory) {

        address payable[] memory owners;
        uint256 index = 0;
        for (uint256 i = 0; i < vaultOwners.length; i++) {
            if (hasVault(vaultOwners[i])) {
                owners[index] = vaultOwners[i];
                index++;
            }
        }

        return owners;
    }

    function updateParameters(
        uint256 _liquidationIncentive,
        uint256 _liquidationFactor,
        uint256 _transactionFee,
        uint256 _minCollateralizationRatio
    ) public onlyOwner {

        require(
            _liquidationIncentive <= 200,
            "Can't have >20% liquidation incentive"
        );
        require(
            _liquidationFactor <= 1000,
            "Can't liquidate more than 100% of the vault"
        );
        require(_transactionFee <= 100, "Can't have transaction fee > 10%");
        require(
            _minCollateralizationRatio >= 10,
            "Can't have minCollateralizationRatio < 1"
        );

        liquidationIncentive.value = _liquidationIncentive;
        liquidationFactor.value = _liquidationFactor;
        transactionFee.value = _transactionFee;
        minCollateralizationRatio.value = _minCollateralizationRatio;

        emit UpdateParameters(
            _liquidationIncentive,
            _liquidationFactor,
            _transactionFee,
            _minCollateralizationRatio,
            owner()
        );
    }

    function setDetails(string memory _name, string memory _symbol)
        public
        onlyOwner
    {

        name = _name;
        symbol = _symbol;
        decimals = uint8(-1 * oTokenExchangeRate.exponent);
        require(
            decimals >= 0,
            "1 oToken cannot protect less than the smallest unit of the asset"
        );
    }

    function transferFee(address payable _address) public onlyOwner {

        uint256 fees = totalFee;
        totalFee = 0;
        transferCollateral(_address, fees);

        emit TransferFee(_address, fees);
    }

    function hasVault(address payable owner) public view returns (bool) {

        return vaults[owner].owned;
    }

    function openVault() public notExpired returns (bool) {

        require(!hasVault(msg.sender), "Vault already created");

        vaults[msg.sender] = Vault(0, 0, 0, true);
        vaultOwners.push(msg.sender);

        emit VaultOpened(msg.sender);
        return true;
    }

    function addETHCollateral(address payable vaultOwner)
        public
        payable
        notExpired
        returns (uint256)
    {

        require(isETH(collateral), "ETH is not the specified collateral type");
        require(hasVault(vaultOwner), "Vault does not exist");

        emit ETHCollateralAdded(vaultOwner, msg.value, msg.sender);
        return _addCollateral(vaultOwner, msg.value);
    }

    function addERC20Collateral(address payable vaultOwner, uint256 amt)
        public
        notExpired
        returns (uint256)
    {

        require(
            collateral.transferFrom(msg.sender, address(this), amt),
            "Could not transfer in collateral tokens"
        );
        require(hasVault(vaultOwner), "Vault does not exist");

        emit ERC20CollateralAdded(vaultOwner, amt, msg.sender);
        return _addCollateral(vaultOwner, amt);
    }

    function underlyingRequiredToExercise(uint256 oTokensToExercise)
        public
        view
        returns (uint256)
    {

        uint64 underlyingPerOTokenExp = uint64(
            oTokenExchangeRate.exponent - underlyingExp
        );
        return oTokensToExercise.mul(10**underlyingPerOTokenExp);
    }

    function isExerciseWindow() public view returns (bool) {

        return ((block.timestamp >= expiry.sub(windowSize)) &&
            (block.timestamp < expiry));
    }

    function hasExpired() public view returns (bool) {

        return (block.timestamp >= expiry);
    }

    function exercise(
        uint256 oTokensToExercise,
        address payable[] memory vaultsToExerciseFrom
    ) public payable {

        for (uint256 i = 0; i < vaultsToExerciseFrom.length; i++) {
            address payable vaultOwner = vaultsToExerciseFrom[i];
            require(
                hasVault(vaultOwner),
                "Cannot exercise from a vault that doesn't exist"
            );
            Vault storage vault = vaults[vaultOwner];
            if (oTokensToExercise == 0) {
                return;
            } else if (vault.oTokensIssued >= oTokensToExercise) {
                _exercise(oTokensToExercise, vaultOwner);
                return;
            } else {
                oTokensToExercise = oTokensToExercise.sub(vault.oTokensIssued);
                _exercise(vault.oTokensIssued, vaultOwner);
            }
        }
        require(
            oTokensToExercise == 0,
            "Specified vaults have insufficient collateral"
        );
    }

    function removeUnderlying() public {

        require(hasVault(msg.sender), "Vault does not exist");
        Vault storage vault = vaults[msg.sender];

        require(vault.underlying > 0, "No underlying balance");

        uint256 underlyingToTransfer = vault.underlying;
        vault.underlying = 0;

        transferUnderlying(msg.sender, underlyingToTransfer);
        emit RemoveUnderlying(underlyingToTransfer, msg.sender);

    }

    function issueOTokens(uint256 oTokensToIssue, address receiver)
        public
        notExpired
    {

        require(hasVault(msg.sender), "Vault does not exist");

        Vault storage vault = vaults[msg.sender];

        uint256 newOTokensBalance = vault.oTokensIssued.add(oTokensToIssue);
        require(isSafe(vault.collateral, newOTokensBalance), "unsafe to mint");

        vault.oTokensIssued = newOTokensBalance;
        _mint(receiver, oTokensToIssue);

        emit IssuedOTokens(receiver, oTokensToIssue, msg.sender);
        return;
    }

    function getVault(address payable vaultOwner)
        public
        view
        returns (uint256, uint256, uint256, bool)
    {

        Vault storage vault = vaults[vaultOwner];
        return (
            vault.collateral,
            vault.oTokensIssued,
            vault.underlying,
            vault.owned
        );
    }

    function isETH(IERC20 _ierc20) public pure returns (bool) {

        return _ierc20 == IERC20(0);
    }

    function burnOTokens(uint256 amtToBurn) public notExpired {

        require(hasVault(msg.sender), "Vault does not exist");

        Vault storage vault = vaults[msg.sender];

        vault.oTokensIssued = vault.oTokensIssued.sub(amtToBurn);
        _burn(msg.sender, amtToBurn);

        emit BurnOTokens(msg.sender, amtToBurn);
    }

    function removeCollateral(uint256 amtToRemove) public notExpired {

        require(amtToRemove > 0, "Cannot remove 0 collateral");
        require(hasVault(msg.sender), "Vault does not exist");

        Vault storage vault = vaults[msg.sender];
        require(
            amtToRemove <= getCollateral(msg.sender),
            "Can't remove more collateral than owned"
        );

        uint256 newCollateralBalance = vault.collateral.sub(amtToRemove);

        require(
            isSafe(newCollateralBalance, vault.oTokensIssued),
            "Vault is unsafe"
        );

        vault.collateral = newCollateralBalance;
        transferCollateral(msg.sender, amtToRemove);

        emit RemoveCollateral(amtToRemove, msg.sender);
    }

    function redeemVaultBalance() public {

        require(hasExpired(), "Can't collect collateral until expiry");
        require(hasVault(msg.sender), "Vault does not exist");

        Vault storage vault = vaults[msg.sender];

        uint256 collateralToTransfer = vault.collateral;
        uint256 underlyingToTransfer = vault.underlying;

        vault.collateral = 0;
        vault.oTokensIssued = 0;
        vault.underlying = 0;

        transferCollateral(msg.sender, collateralToTransfer);
        transferUnderlying(msg.sender, underlyingToTransfer);

        emit RedeemVaultBalance(
            collateralToTransfer,
            underlyingToTransfer,
            msg.sender
        );
    }

    function maxOTokensLiquidatable(address payable vaultOwner)
        public
        view
        returns (uint256)
    {

        if (isUnsafe(vaultOwner)) {
            Vault storage vault = vaults[vaultOwner];
            uint256 maxCollateralLiquidatable = vault
                .collateral
                .mul(liquidationFactor.value)
                .div(10**uint256(-liquidationFactor.exponent));

            uint256 one = 10**uint256(-liquidationIncentive.exponent);
            Number memory liqIncentive = Number(
                liquidationIncentive.value.add(one),
                liquidationIncentive.exponent
            );
            return calculateOTokens(maxCollateralLiquidatable, liqIncentive);
        } else {
            return 0;
        }
    }

    function liquidate(address payable vaultOwner, uint256 oTokensToLiquidate)
        public
        notExpired
    {

        require(hasVault(vaultOwner), "Vault does not exist");

        Vault storage vault = vaults[vaultOwner];

        require(isUnsafe(vaultOwner), "Vault is safe");

        require(msg.sender != vaultOwner, "Owner can't liquidate themselves");

        uint256 amtCollateral = calculateCollateralToPay(
            oTokensToLiquidate,
            Number(1, 0)
        );
        uint256 amtIncentive = calculateCollateralToPay(
            oTokensToLiquidate,
            liquidationIncentive
        );
        uint256 amtCollateralToPay = amtCollateral.add(amtIncentive);

        uint256 maxCollateralLiquidatable = vault.collateral.mul(
            liquidationFactor.value
        );

        if (liquidationFactor.exponent > 0) {
            maxCollateralLiquidatable = maxCollateralLiquidatable.mul(
                10**uint256(liquidationFactor.exponent)
            );
        } else {
            maxCollateralLiquidatable = maxCollateralLiquidatable.div(
                10**uint256(-1 * liquidationFactor.exponent)
            );
        }

        require(
            amtCollateralToPay <= maxCollateralLiquidatable,
            "Can only liquidate liquidation factor at any given time"
        );

        vault.collateral = vault.collateral.sub(amtCollateralToPay);
        vault.oTokensIssued = vault.oTokensIssued.sub(oTokensToLiquidate);

        _burn(msg.sender, oTokensToLiquidate);
        transferCollateral(msg.sender, amtCollateralToPay);

        emit Liquidate(amtCollateralToPay, vaultOwner, msg.sender);
    }

    function isUnsafe(address payable vaultOwner) public view returns (bool) {

        bool stillUnsafe = !isSafe(
            getCollateral(vaultOwner),
            getOTokensIssued(vaultOwner)
        );
        return stillUnsafe;
    }

    function isWithinExponentRange(int32 val) internal pure returns (bool) {

        return ((val <= 30) && (val >= -30));
    }

    function getCollateral(address payable vaultOwner)
        internal
        view
        returns (uint256)
    {

        Vault storage vault = vaults[vaultOwner];
        return vault.collateral;
    }

    function getOTokensIssued(address payable vaultOwner)
        internal
        view
        returns (uint256)
    {

        Vault storage vault = vaults[vaultOwner];
        return vault.oTokensIssued;
    }

    function _exercise(
        uint256 oTokensToExercise,
        address payable vaultToExerciseFrom
    ) internal {

        require(
            isExerciseWindow(),
            "Can't exercise outside of the exercise window"
        );

        require(hasVault(vaultToExerciseFrom), "Vault does not exist");

        Vault storage vault = vaults[vaultToExerciseFrom];
        require(oTokensToExercise > 0, "Can't exercise 0 oTokens");
        require(
            oTokensToExercise <= vault.oTokensIssued,
            "Can't exercise more oTokens than the owner has"
        );
        require(
            balanceOf(msg.sender) >= oTokensToExercise,
            "Not enough oTokens"
        );

        uint256 amtUnderlyingToPay = underlyingRequiredToExercise(
            oTokensToExercise
        );
        vault.underlying = vault.underlying.add(amtUnderlyingToPay);

        uint256 amtCollateralToPay = calculateCollateralToPay(
            oTokensToExercise,
            Number(1, 0)
        );

        uint256 amtFee = calculateCollateralToPay(
            oTokensToExercise,
            transactionFee
        );
        totalFee = totalFee.add(amtFee);

        uint256 totalCollateralToPay = amtCollateralToPay.add(amtFee);
        require(
            totalCollateralToPay <= vault.collateral,
            "Vault underwater, can't exercise"
        );

        vault.collateral = vault.collateral.sub(totalCollateralToPay);
        vault.oTokensIssued = vault.oTokensIssued.sub(oTokensToExercise);

        if (isETH(underlying)) {
            require(msg.value == amtUnderlyingToPay, "Incorrect msg.value");
        } else {
            require(
                underlying.transferFrom(
                    msg.sender,
                    address(this),
                    amtUnderlyingToPay
                ),
                "Could not transfer in tokens"
            );
        }
        _burn(msg.sender, oTokensToExercise);

        transferCollateral(msg.sender, amtCollateralToPay);

        emit Exercise(
            amtUnderlyingToPay,
            amtCollateralToPay,
            msg.sender,
            vaultToExerciseFrom
        );

    }

    function _addCollateral(address payable vaultOwner, uint256 amt)
        internal
        notExpired
        returns (uint256)
    {

        Vault storage vault = vaults[vaultOwner];
        vault.collateral = vault.collateral.add(amt);

        return vault.collateral;
    }

    function isSafe(uint256 collateralAmt, uint256 oTokensIssued)
        internal
        view
        returns (bool)
    {

        uint256 collateralToEthPrice = getPrice(address(collateral));
        uint256 strikeToEthPrice = getPrice(address(strike));

        uint256 leftSideVal = oTokensIssued
            .mul(minCollateralizationRatio.value)
            .mul(strikePrice.value);
        int32 leftSideExp = minCollateralizationRatio.exponent +
            strikePrice.exponent;

        uint256 rightSideVal = (collateralAmt.mul(collateralToEthPrice)).div(
            strikeToEthPrice
        );
        int32 rightSideExp = collateralExp;

        uint256 exp = 0;
        bool stillSafe = false;

        if (rightSideExp < leftSideExp) {
            exp = uint256(leftSideExp - rightSideExp);
            stillSafe = leftSideVal.mul(10**exp) <= rightSideVal;
        } else {
            exp = uint256(rightSideExp - leftSideExp);
            stillSafe = leftSideVal <= rightSideVal.mul(10**exp);
        }

        return stillSafe;
    }

    function maxOTokensIssuable(uint256 collateralAmt)
        public
        view
        returns (uint256)
    {

        return calculateOTokens(collateralAmt, minCollateralizationRatio);

    }

    function calculateOTokens(uint256 collateralAmt, Number memory proportion)
        internal
        view
        returns (uint256)
    {

        uint256 collateralToEthPrice = getPrice(address(collateral));
        uint256 strikeToEthPrice = getPrice(address(strike));

        uint256 denomVal = proportion.value.mul(strikePrice.value);
        int32 denomExp = proportion.exponent + strikePrice.exponent;

        uint256 numeratorVal = (collateralAmt.mul(collateralToEthPrice)).div(
            strikeToEthPrice
        );
        int32 numeratorExp = collateralExp;

        uint256 exp = 0;
        uint256 numOptions = 0;

        if (numeratorExp < denomExp) {
            exp = uint256(denomExp - numeratorExp);
            numOptions = numeratorVal.div(denomVal.mul(10**exp));
        } else {
            exp = uint256(numeratorExp - denomExp);
            numOptions = numeratorVal.mul(10**exp).div(denomVal);
        }

        return numOptions;
    }

    function calculateCollateralToPay(
        uint256 _oTokens,
        Number memory proportion
    ) internal view returns (uint256) {

        uint256 collateralToEthPrice = getPrice(address(collateral));
        uint256 strikeToEthPrice = getPrice(address(strike));

        uint256 amtCollateralToPayInEthNum = _oTokens
            .mul(strikePrice.value)
            .mul(proportion.value)
            .mul(strikeToEthPrice);
        int32 amtCollateralToPayExp = strikePrice.exponent +
            proportion.exponent -
            collateralExp;
        uint256 amtCollateralToPay = 0;
        if (amtCollateralToPayExp > 0) {
            uint32 exp = uint32(amtCollateralToPayExp);
            amtCollateralToPay = amtCollateralToPayInEthNum.mul(10**exp).div(
                collateralToEthPrice
            );
        } else {
            uint32 exp = uint32(-1 * amtCollateralToPayExp);
            amtCollateralToPay = (amtCollateralToPayInEthNum.div(10**exp)).div(
                collateralToEthPrice
            );
        }

        return amtCollateralToPay;

    }

    function transferCollateral(address payable _addr, uint256 _amt) internal {

        if (isETH(collateral)) {
            _addr.transfer(_amt);
        } else {
            collateral.transfer(_addr, _amt);
        }
    }

    function transferUnderlying(address payable _addr, uint256 _amt) internal {

        if (isETH(underlying)) {
            _addr.transfer(_amt);
        } else {
            underlying.transfer(_addr, _amt);
        }
    }

    function getPrice(address asset) internal view returns (uint256) {

        if (asset == address(0)) {
            return (10**18);
        } else {
            return COMPOUND_ORACLE.getPrice(asset);
        }
    }
}


pragma solidity 0.5.10;



contract oToken is OptionsContract {

    constructor(
        IERC20 _collateral,
        int32 _collExp,
        IERC20 _underlying,
        int32 _underlyingExp,
        int32 _oTokenExchangeExp,
        uint256 _strikePrice,
        int32 _strikeExp,
        IERC20 _strike,
        uint256 _expiry,
        OptionsExchange _optionsExchange,
        address _oracleAddress,
        uint256 _windowSize
    )
        public
        OptionsContract(
            _collateral,
            _collExp,
            _underlying,
            _underlyingExp,
            _oTokenExchangeExp,
            _strikePrice,
            _strikeExp,
            _strike,
            _expiry,
            _optionsExchange,
            _oracleAddress,
            _windowSize
        )
    {}

    function createETHCollateralOption(uint256 amtToCreate, address receiver)
        external
        payable
    {

        openVault();
        addETHCollateralOption(amtToCreate, receiver);
    }

    function addETHCollateralOption(uint256 amtToCreate, address receiver)
        public
        payable
    {

        addETHCollateral(msg.sender);
        issueOTokens(amtToCreate, receiver);
    }

    function createAndSellETHCollateralOption(
        uint256 amtToCreate,
        address payable receiver
    ) external payable {

        openVault();
        addETHCollateralOption(amtToCreate, address(this));
        this.approve(address(optionsExchange), amtToCreate);
        optionsExchange.sellOTokens(
            receiver,
            address(this),
            address(0),
            amtToCreate
        );
    }

    function addAndSellETHCollateralOption(
        uint256 amtToCreate,
        address payable receiver
    ) public payable {

        addETHCollateral(msg.sender);
        issueOTokens(amtToCreate, address(this));
        this.approve(address(optionsExchange), amtToCreate);
        optionsExchange.sellOTokens(
            receiver,
            address(this),
            address(0),
            amtToCreate
        );
    }

    function createERC20CollateralOption(
        uint256 amtToCreate,
        uint256 amtCollateral,
        address receiver
    ) external {

        openVault();
        addERC20CollateralOption(amtToCreate, amtCollateral, receiver);
    }

    function addERC20CollateralOption(
        uint256 amtToCreate,
        uint256 amtCollateral,
        address receiver
    ) public {

        addERC20Collateral(msg.sender, amtCollateral);
        issueOTokens(amtToCreate, receiver);
    }

    function createAndSellERC20CollateralOption(
        uint256 amtToCreate,
        uint256 amtCollateral,
        address payable receiver
    ) external {

        openVault();
        addERC20CollateralOption(amtToCreate, amtCollateral, address(this));
        this.approve(address(optionsExchange), amtToCreate);
        optionsExchange.sellOTokens(
            receiver,
            address(this),
            address(0),
            amtToCreate
        );
    }

    function addAndSellERC20CollateralOption(
        uint256 amtToCreate,
        uint256 amtCollateral,
        address payable receiver
    ) public {

        addERC20Collateral(msg.sender, amtCollateral);
        issueOTokens(amtToCreate, address(this));
        this.approve(address(optionsExchange), amtToCreate);
        optionsExchange.sellOTokens(
            receiver,
            address(this),
            address(0),
            amtToCreate
        );
    }
}