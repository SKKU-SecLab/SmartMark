



pragma solidity ^0.8.0;


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



pragma solidity ^0.8.0;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}



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
}



pragma solidity ^0.8.7;




interface IDEXFactory {

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

interface IDEXRouter {

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


    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;


    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;

}

interface IPancakeswapV2Pair {

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

interface IERC20 {

    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address to, uint256 amount) external returns (bool);

    function allowance(address owner, address spender) external view returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);


    function decimals() external view returns (uint8);


    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);


    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}

interface IERC20Metadata is IERC20 {

    function name() external view returns (string memory);


    function symbol() external view returns (string memory);

}

contract DecentraWorld_Multichain is Context, IERC20, IERC20Metadata, Ownable {

    using SafeMath for uint256;
    uint256 _totalSupply;
    string private _name;
    string private _symbol;
    uint8 private _decimals;
    mapping (string => uint) txTaxes;
    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;
    mapping (address => bool) public excludeFromTax;
    mapping (address => bool) public exclueFromMaxTx;
    address public daoandfarmingAddress;
    address public marketingAddress;
    address public developmentAddress;
    address public coreteamAddress;
    address public MPC;
    struct TaxLevels {
        uint taxDiscount;
        uint amount;
    }

    struct DEWOTokenTax {
        uint forMarketing;
        uint forCoreTeam;
        uint forDevelopment;
        uint forDAOAndFarming;
    }

    struct TxLimit {
        uint buyMaxTx;
        uint sellMaxTx;
        uint txcooldown;
        mapping(address => uint) buys;
        mapping(address => uint) sells;
        mapping(address => uint) lastTx;
    }

    mapping (uint => TaxLevels) taxTiers;
    TxLimit txSettings;

    IDEXRouter public router;
    address public pair;

    constructor() {
        _name = "DecentraWorld";
        _symbol = "$DEWO";
        _decimals = 18;
        daoandfarmingAddress = msg.sender;
        marketingAddress = 0x5d5a0368b8C383c45c625a7241473A1a4F61eA4E;
        developmentAddress = 0xdA9f5e831b7D18c35CA7778eD271b4d4f3bE183E;
        coreteamAddress = 0x797BD28BaE691B21e235E953043337F4794Ff9DB;
         
        excludeFromTax[msg.sender] = true;
        excludeFromTax[daoandfarmingAddress] = true;
        excludeFromTax[marketingAddress] = true;
        excludeFromTax[developmentAddress] = true;
        excludeFromTax[coreteamAddress] = true;

        exclueFromMaxTx[msg.sender] = true;
        exclueFromMaxTx[daoandfarmingAddress] = true;
        exclueFromMaxTx[marketingAddress] = true;
        exclueFromMaxTx[developmentAddress] = true;
        exclueFromMaxTx[coreteamAddress] = true;

        MPC = msg.sender;

        txTaxes["marketingBuyTax"] = 3;      // [3%] DAO, Governance, Farming Pools
        txTaxes["developmentBuyTax"] = 1;    // [1%] Marketing Fee
        txTaxes["coreteamBuyTax"] = 1;       // [1%] Development Fee
        txTaxes["daoandfarmingBuyTax"] = 1;  // [1%] DecentraWorld's Core-Team
        txTaxes["marketingSellTax"] = 4;     // 4% DAO, Governance, Farming Pools 
        txTaxes["developmentSellTax"] = 3;   // 3% Marketing Fee
        txTaxes["coreteamSellTax"] = 1;      // 1% Development Fee
        txTaxes["daoandfarmingSellTax"] = 2; // 2% DecentraWorld's Core-Team
        taxTiers[0].taxDiscount = 50;
        taxTiers[0].amount = 100000 * (10 ** decimals()); 

        taxTiers[1].taxDiscount = 99;
        taxTiers[1].amount = 400000 * (10 ** decimals());

        taxTiers[2].taxDiscount = 20;
        taxTiers[2].amount = 150000 * (10 ** decimals());

        taxTiers[3].taxDiscount = 40;
        taxTiers[3].amount = 300000 * (10 ** decimals());

        txSettings.txcooldown = 30 minutes;

        txSettings.buyMaxTx = _totalSupply.div(80);

        txSettings.sellMaxTx = _totalSupply.div(800);


    }

    function balanceOf(address account) public view virtual override returns (uint256) {

        return _balances[account];
    }

    modifier onlyAuth() {

        require(msg.sender == mmpc(), "DecentraWorld: FORBIDDEN");
        _;
    }
  
      function mmpc() public view returns (address) {

        return MPC;
    }

    function setMPC(address _setmpc) external onlyAuth {

        MPC = _setmpc;
    }
    
    function mint(address to, uint256 amount) external onlyAuth returns (bool) {

        _mint(to, amount);
        return true;
    }

    function burn(address from, uint256 amount) external onlyAuth returns (bool) {

        require(from != address(0), "DecentraWorld: address(0x0)");
        _burn(from, amount);
        return true;
    }

    function Swapin(bytes32 txhash, address account, uint256 amount) public onlyAuth returns (bool) {

        _mint(account, amount);
        emit LogSwapin(txhash, account, amount);
        return true;
    }

    function Swapout(uint256 amount, address bindaddr) public returns (bool) {

        require(bindaddr != address(0), "DecentraWorld: address(0x0)");
        _burn(msg.sender, amount);
        emit LogSwapout(msg.sender, bindaddr, amount);
        return true;
    }
    
    event LogSwapin(bytes32 indexed txhash, address indexed account, uint amount);
    event LogSwapout(address indexed account, address indexed bindaddr, uint amount);
      

    function setDEXPAIR(address _nativetoken, address _nativerouter) external onlyOwner {

        router = IDEXRouter(_nativerouter);
        pair = IDEXFactory(router.factory()).createPair(_nativetoken, address(this));
        _allowances[address(this)][address(router)] = _totalSupply;
        approve(_nativerouter, _totalSupply);
    }

    event BuyTaxes(
        uint _daoandfarmingBuyTax,
        uint _coreteamBuyTax,
        uint _developmentBuyTax, 
        uint _marketingBuyTax
    );
    function setBuyTaxes(
        uint _daoandfarmingBuyTax,
        uint _coreteamBuyTax,
        uint _developmentBuyTax, 
        uint _marketingBuyTax
    ) external onlyOwner {

        require(_daoandfarmingBuyTax <= 6, "DAO & Farming tax is above 6%!");
        require(_coreteamBuyTax <= 6, "Core-Team Buy tax is above 6%!");
        require(_developmentBuyTax <= 6, "Development Fund tax is above 6%!");
        require(_marketingBuyTax <= 6, "Marketing tax is above 6%!");
        txTaxes["daoandfarmingBuyTax"] = _daoandfarmingBuyTax;
        txTaxes["coreteamBuyTax"] = _coreteamBuyTax; 
        txTaxes["developmentBuyTax"] = _developmentBuyTax; 
        txTaxes["marketingBuyTax"] = _marketingBuyTax; 
        emit BuyTaxes(
            _daoandfarmingBuyTax,
            _coreteamBuyTax, 
            _developmentBuyTax, 
            _marketingBuyTax
        );
    }

        event SellTaxes(
        uint _daoandfarmingSellTax,
        uint _coreteamSellTax, 
        uint _developmentSellTax,
        uint _marketingSellTax
    );
    function setSellTaxes(
        uint _daoandfarmingSellTax,
        uint _coreteamSellTax, 
        uint _developmentSellTax,
        uint _marketingSellTax
    ) external onlyOwner {

        require(_daoandfarmingSellTax <= 6, "DAO & Farming tax is above 6%!");
        require(_coreteamSellTax <= 6, "Core-team tax is above 6%!");
        require(_developmentSellTax <= 6, "Development tax is above 6%!");
        require(_marketingSellTax <= 6, "Marketing tax is above 6%!");
        txTaxes["daoandfarmingSellTax"] = _daoandfarmingSellTax;
        txTaxes["coreteamSellTax"] = _coreteamSellTax; 
        txTaxes["developmentSellTax"] = _developmentSellTax; 
        txTaxes["marketingSellTax"] = _marketingSellTax; 
        emit SellTaxes(
            _daoandfarmingSellTax,
            _coreteamSellTax, 
            _developmentSellTax, 
            _marketingSellTax
        );
    }


    function getSellTaxes() public view returns(
        uint marketingSellTax,
        uint developmentSellTax,
        uint coreteamSellTax,
        uint daoandfarmingSellTax
    ) {

        return (
            txTaxes["marketingSellTax"],
            txTaxes["developmentSellTax"],
            txTaxes["coreteamSellTax"],
            txTaxes["daoandfarmingSellTax"]
        );
    }

    function getBuyTaxes() public view returns(
        uint marketingBuyTax,
        uint developmentBuyTax,
        uint coreteamBuyTax,
        uint daoandfarmingBuyTax
    ) {

        return (
            txTaxes["marketingBuyTax"],
            txTaxes["developmentBuyTax"],
            txTaxes["coreteamBuyTax"],
            txTaxes["daoandfarmingBuyTax"]
        );
    }
    
    function setDAOandFarmingAddress(address _daoandfarmingAddress) external onlyOwner {

        daoandfarmingAddress = _daoandfarmingAddress;
    }

    function setMarketingAddress(address _marketingAddress) external onlyOwner {

        marketingAddress = _marketingAddress;
    }

    function setDevelopmentAddress(address _developmentAddress) external onlyOwner {

        developmentAddress = _developmentAddress;
    }

    function setCoreTeamAddress(address _coreteamAddress) external onlyOwner {

        coreteamAddress = _coreteamAddress;
    }

    function setExcludeFromTax(address _address, bool _value) external onlyOwner {

        excludeFromTax[_address] = _value;
    }

    function setExclueFromMaxTx(address _address, bool _value) external onlyOwner {

        exclueFromMaxTx[_address] = _value;
    }

    function setBuyTaxTiers(uint _discount1, uint _amount1, uint _discount2, uint _amount2) external onlyOwner {

        require(_discount1 > 0 && _discount1 < 100 && _discount2 > 0 && _discount2 < 100 && _amount1 > 0 && _amount2 > 0, "Values have to be bigger than zero!");
        taxTiers[0].taxDiscount = _discount1;
        taxTiers[0].amount = _amount1;
        taxTiers[1].taxDiscount = _discount2;
        taxTiers[1].amount = _amount2;
        
    }

        function setSellTaxTiers(uint _discount3, uint _amount3, uint _discount4, uint _amount4) external onlyOwner {

        require(_discount3 > 0 && _discount3 < 100 && _discount4 > 0 && _discount4 < 100 && _amount3 > 0 && _amount4 > 0, "Values have to be bigger than zero!");
        taxTiers[2].taxDiscount = _discount3;
        taxTiers[2].amount = _amount3;
        taxTiers[3].taxDiscount = _discount4;
        taxTiers[3].amount = _amount4;
        
    }

    function getBuyTaxTiers() public view returns(uint discount1, uint amount1, uint discount2, uint amount2) {

        return (taxTiers[0].taxDiscount, taxTiers[0].amount, taxTiers[1].taxDiscount, taxTiers[1].amount);
    }

    function getSellTaxTiers() public view returns(uint discount3, uint amount3, uint discount4, uint amount4) {

        return (taxTiers[2].taxDiscount, taxTiers[2].amount, taxTiers[3].taxDiscount, taxTiers[3].amount);
    }

    function setTxSettings(uint _buyMaxTx, uint _sellMaxTx, uint _txcooldown) external onlyOwner {

        require(_buyMaxTx >= _totalSupply.div(200), "Buy transaction limit is too low!"); // 0.5%
        require(_sellMaxTx >= _totalSupply.div(400), "Sell transaction limit is too low!"); // 0.25%
        require(_txcooldown <= 4 minutes, "Cooldown should be 4 minutes or less!");
        txSettings.buyMaxTx = _buyMaxTx;
        txSettings.sellMaxTx = _sellMaxTx;
        txSettings.txcooldown = _txcooldown;
    }

    function getTxSettings() public view returns(uint buyMaxTx, uint sellMaxTx, uint txcooldown) {

        return (txSettings.buyMaxTx, txSettings.sellMaxTx, txSettings.txcooldown);
    }

    function checkBuyTxLimit(address _sender, uint256 _amount) internal view {

        require(
            exclueFromMaxTx[_sender] == true ||
            txSettings.buys[_sender].add(_amount) < txSettings.buyMaxTx,
            "Buy transaction limit reached!"
        );
    }

    function checkSellTxLimit(address _sender, uint256 _amount) internal view {

        require(
            exclueFromMaxTx[_sender] == true ||
            txSettings.sells[_sender].add(_amount) < txSettings.sellMaxTx,
            "Sell transaction limit reached!"
        );
    }
    
    function setRecentTx(bool _isSell, address _sender, uint _amount) internal {

        if(txSettings.lastTx[_sender].add(txSettings.txcooldown) < block.timestamp) {
            _isSell ? txSettings.sells[_sender] = _amount : txSettings.buys[_sender] = _amount;
        } else {
            _isSell ? txSettings.sells[_sender] += _amount : txSettings.buys[_sender] += _amount;
        }

        txSettings.lastTx[_sender] = block.timestamp;
    }

    function getRecentTx(address _address) public view returns(uint buys, uint sells, uint lastTx) {

        return (txSettings.buys[_address], txSettings.sells[_address], txSettings.lastTx[_address]);
    }

    function getTokenPrice(uint _amount) public view returns(uint) {

        IPancakeswapV2Pair pcsPair = IPancakeswapV2Pair(pair);
        IERC20 token1 = IERC20(pcsPair.token1());
        (uint Res0, uint Res1,) = pcsPair.getReserves();
        uint res0 = Res0*(10**token1.decimals());
        return((_amount.mul(res0)).div(Res1)); 
    }

    function name() public view virtual override returns (string memory) {

        return _name;
    }

    function symbol() public view virtual override returns (string memory) {

        return _symbol;
    }

    function decimals() public view virtual override returns (uint8) {

        return _decimals;
    }
    
    function totalSupply() public view virtual override returns (uint256) {

        return _totalSupply;
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

    function _mint(address account, uint256 amount) internal {

        require(account != address(0), "ERC20: mint to the zero address");
        _totalSupply += amount;
        _balances[account] += amount;
        emit Transfer(address(0), account, amount);
    }

    function _burn(address account, uint256 amount) internal {

        require(account != address(0), "ERC20: burn from the zero address");
        _balances[account] -= amount;
        _totalSupply -= amount;
        emit Transfer(account, address(0), amount);
    }

    function _transfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {

        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");

        uint256 fromBalance = _balances[from];
        require(fromBalance >= amount, "ERC20: transfer amount exceeds balance");

        uint marketingFee;
        uint developmentFee;
        uint coreteamFee;
        uint daoandfarmingFee;

        uint taxDiscount;
        bool hasTaxes = true;


        if(from == pair) {
            checkBuyTxLimit(to, amount); 
            setRecentTx(false, to, amount);
            marketingFee = txTaxes["marketingBuyTax"];
            developmentFee = txTaxes["developmentBuyTax"];
            coreteamFee = txTaxes["coreteamBuyTax"];
            daoandfarmingFee = txTaxes["daoandfarmingBuyTax"];
            if(amount >= taxTiers[0].amount && amount < taxTiers[1].amount) {
                taxDiscount = taxTiers[0].taxDiscount;
            } else if(amount >= taxTiers[1].amount) {
                taxDiscount = taxTiers[1].taxDiscount;
            }
        }

        else if(to == pair) {
            checkSellTxLimit(from, amount);
            setRecentTx(true, from, amount);
            marketingFee = txTaxes["marketingSellTax"];
            developmentFee = txTaxes["developmentSellTax"];
            coreteamFee = txTaxes["coreteamSellTax"];
            daoandfarmingFee = txTaxes["daoandfarmingSellTax"];
            uint newBalanceAmount = fromBalance.sub(amount);
            if(newBalanceAmount >= taxTiers[2].amount && newBalanceAmount < taxTiers[3].amount) {
                taxDiscount = taxTiers[2].taxDiscount;
            } else if(newBalanceAmount >= taxTiers[3].amount) {
                taxDiscount = taxTiers[3].taxDiscount;
            }
        }
        


        unchecked {
            _balances[from] = fromBalance - amount;
        }
        if(excludeFromTax[to] || excludeFromTax[from]) {
            hasTaxes = false;
        }

        if(hasTaxes && (to == pair || from == pair)) {
            DEWOTokenTax memory DEWOTokenTaxes;
            DEWOTokenTaxes.forDAOAndFarming = amount.mul(daoandfarmingFee).mul(100 - taxDiscount).div(10000);
            DEWOTokenTaxes.forDevelopment = amount.mul(developmentFee).mul(100 - taxDiscount).div(10000);
            DEWOTokenTaxes.forCoreTeam = amount.mul(coreteamFee).mul(100 - taxDiscount).div(10000);
            DEWOTokenTaxes.forMarketing = amount.mul(marketingFee).mul(100 - taxDiscount).div(10000);
             

            uint totalTaxes =
                DEWOTokenTaxes.forDAOAndFarming
                .add(DEWOTokenTaxes.forDevelopment)
                .add(DEWOTokenTaxes.forCoreTeam)
                .add(DEWOTokenTaxes.forMarketing);
            amount = amount.sub(totalTaxes);

            _balances[daoandfarmingAddress] += DEWOTokenTaxes.forDAOAndFarming;
            emit Transfer(from, daoandfarmingAddress, DEWOTokenTaxes.forDAOAndFarming);

            _balances[developmentAddress] += DEWOTokenTaxes.forDevelopment;
            emit Transfer(from, developmentAddress, DEWOTokenTaxes.forDevelopment);

            _balances[coreteamAddress] += DEWOTokenTaxes.forCoreTeam;
            emit Transfer(from, coreteamAddress, DEWOTokenTaxes.forCoreTeam);

            _balances[marketingAddress] += DEWOTokenTaxes.forMarketing;
            emit Transfer(from, marketingAddress, DEWOTokenTaxes.forMarketing);

        }
        _balances[to] += amount;
        emit Transfer(from, to, amount);
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
}