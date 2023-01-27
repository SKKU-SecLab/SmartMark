
pragma solidity ^0.6.2;


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


contract Context {

    constructor () internal { }

    function _msgSender() internal view virtual returns (address payable) {

        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {

        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

contract Pausable is Context {

    event Paused(address account);

    event Unpaused(address account);

    bool private _paused;

    constructor () internal {
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
}


contract Ownable is Context {

    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor () internal {
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

library Address {

    function isContract(address account) internal view returns (bool) {

        bytes32 codehash;
        bytes32 accountHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;
        assembly { codehash := extcodehash(account) }
        return (codehash != accountHash && codehash != 0x0);
    }

    function sendValue(address payable recipient, uint256 amount) internal {

        require(address(this).balance >= amount, "Address: insufficient balance");

        (bool success, ) = recipient.call{ value: amount }("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }
}

contract ReentrancyGuard {

    bool private _notEntered;

    constructor () internal {
        _notEntered = true;
    }

    modifier nonReentrant() {

        require(_notEntered, "ReentrancyGuard: reentrant call");

        _notEntered = false;

        _;

        _notEntered = true;
    }
}


contract ERC20 is Context, IERC20 {

    using SafeMath for uint256;
    using Address for address;

    mapping (address => uint256) private _balances;

    mapping (address => mapping (address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;
    uint8 private _decimals;

    constructor (string memory name, string memory symbol) public {
        _name = name;
        _symbol = symbol;
        _decimals = 18;
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

    function totalSupply() public view override returns (uint256) {

        return _totalSupply;
    }

    function balanceOf(address account) public view override returns (uint256) {

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

    function transferFrom(address sender, address recipient, uint256 amount) public virtual override returns (bool) {

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

    function _transfer(address sender, address recipient, uint256 amount) internal virtual {

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

    function _approve(address owner, address spender, uint256 amount) internal virtual {

        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _setupDecimals(uint8 decimals_) internal {

        _decimals = decimals_;
    }

    function _beforeTokenTransfer(address from, address to, uint256 amount) internal virtual { }

}





interface IPrime {
    function balanceOf(address user) external view returns (uint);
    function transfer(address to, uint256 amount) external returns (bool);
    function transferFrom(address from, address to, uint256 amount) external returns (bool);

    function swap(address receiver) external returns (
        uint256 inTokenS,
        uint256 inTokenP,
        uint256 outTokenU
    );
    function mint(address receiver) external returns (
        uint256 inTokenU,
        uint256 outTokenR
    );
    function redeem(address receiver) external returns (
        uint256 inTokenR
    );
    function close(address receiver) external returns (
        uint256 inTokenR,
        uint256 inTokenP,
        uint256 outTokenU
    );

    function tokenR() external view returns (address);
    function tokenS() external view returns (address);
    function tokenU() external view returns (address);
    function base() external view returns (uint256);
    function price() external view returns (uint256);
    function expiry() external view returns (uint256);
    function cacheU() external view returns (uint256);
    function cacheS() external view returns (uint256);
    function factory() external view returns (address);
    function marketId() external view returns (uint256);
    function maxDraw() external view returns (uint256 draw);
    function getCaches() external view returns (uint256 _cacheU, uint256 _cacheS);
    function getTokens() external view returns (address _tokenU, address _tokenS, address _tokenR);
    function prime() external view returns (
            address _tokenS,
            address _tokenU,
            address _tokenR,
            uint256 _base,
            uint256 _price,
            uint256 _expiry
    );
}

interface IPrimeTrader {
    function safeRedeem(address tokenP, uint256 amount, address receiver) external returns (
        uint256 inTokenR
    );
    function safeSwap(address tokenP, uint256 amount, address receiver) external returns (
        uint256 inTokenS,
        uint256 inTokenP,
        uint256 outTokenU
    );
    function safeMint(address tokenP, uint256 amount, address receiver) external returns (
        uint256 inTokenU,
        uint256 outTokenR
    );
    function safeClose(address tokenP, uint256 amount, address receiver) external returns (
        uint256 inTokenR,
        uint256 inTokenP,
        uint256 outTokenU
    );
}

interface IPrimeRedeem {
    function balanceOf(address user) external view returns (uint);
    function mint(address user, uint256 amount) external payable returns (bool);
    function burn(address user, uint256 amount) external payable returns (bool);
    function approve(address spender, uint256 amount) external returns (bool);
    function transfer(address to, uint256 amount) external returns (bool);
    function transferFrom(address from, address to, uint256 amount) external returns (bool);
}





interface IWETH {
    function deposit() external payable;
    function withdraw(uint wad) external;
    function totalSupply() external view returns (uint);
    function approve(address guy, uint wad) external returns (bool);
    function transfer(address dst, uint wad) external returns (bool);
    function transferFrom(address src, address dst, uint wad) external returns (bool);
}

interface PriceOracleProxy {
    function getUnderlyingPrice(address cToken) external view returns (uint);
}

contract PrimePool is Ownable, Pausable, ReentrancyGuard, ERC20 {
    using SafeMath for uint256;

    address public COMPOUND_DAI = 0x5d3a536E4D6DbD6114cc1Ead35777bAB948E3643;
    uint256 public constant SECONDS_IN_DAY = 86400;
    uint256 public constant ONE_ETHER = 1 ether;

    uint256 public volatility;

    address public oracle;
    address payable public weth;
    
    mapping(uint256 => address) public primes;

    event Market(address tokenP);
    event Deposit(address indexed user, uint256 inTokenU, uint256 outTokenPULP);
    event Withdraw(address indexed user, uint256 outTokenU, uint256 inTokenR);
    event Buy(address indexed user, uint256 inTokenS, uint256 outTokenU, uint256 premium);

    constructor (
        address payable _weth,
        address _oracle,
        string memory name,
        string memory symbol
    ) 
        public
        ERC20(name, symbol)
    {
        weth = _weth;
        oracle = _oracle;
        volatility = 100;
    }

    function addMarket(address tokenP) public onlyOwner returns (address) {
        primes[IPrime(tokenP).marketId()] = tokenP;
        emit Market(tokenP);
        return tokenP;
    }

    function kill() public onlyOwner returns (bool) {
        if(paused()) {
            _unpause();
        } else {
            _pause();
        }
        return true;
    }

    modifier valid(address tokenP) {
        require(primes[IPrime(tokenP).marketId()] == tokenP, "ERR_PRIME");
        _;
    }


    receive() external payable {
        assert(msg.sender == weth);
    }



    function deposit(
        uint256 amount,
        address tokenP
    )
        external
        payable
        whenNotPaused
        nonReentrant
        returns (bool)
    {
        address tokenU = IPrime(tokenP).tokenU();
        if(tokenU == weth) {
            require(msg.value == amount && amount > 0, "ERR_BAL_ETH");
        } else {
            require(IERC20(tokenU).balanceOf(msg.sender) >= amount && amount > 0, "ERR_BAL_UNDERLYING");
        }

        uint256 outTokenPULP;
        uint256 balanceU = IERC20(tokenU).balanceOf(address(this));
        uint256 totalSupply = totalSupply();
         
        if(balanceU.mul(totalSupply) == 0) {
            outTokenPULP = amount;
        } else if(amount.mul(totalSupply) < balanceU) {
            require(amount.mul(totalSupply) >= balanceU, "ERR_ZERO");
        } else {
            outTokenPULP = amount.mul(totalSupply).div(balanceU);
        }

        _mint(msg.sender, outTokenPULP);
        emit Deposit(msg.sender, amount, outTokenPULP);

        if(tokenU == weth) {
            IWETH(weth).deposit.value(msg.value)();
            return true;
        } else {
            return IERC20(tokenU).transferFrom(msg.sender, address(this), amount);
        }
    }

    function withdraw(
        uint256 amount,
        address tokenP
    ) 
        external
        nonReentrant
        valid(tokenP)
        returns (bool)
    {
        require(balanceOf(msg.sender) >= amount && amount > 0, "ERR_BAL_PULP");
        
        uint256 totalSupply = totalSupply();

        _burn(msg.sender, amount);

        address tokenU = IPrime(tokenP).tokenU();
        address tokenR = IPrime(tokenP).tokenR();

        uint256 outTokenU = amount.mul(IERC20(tokenU).balanceOf(address(this))).div(totalSupply);

        uint256 outTokenR = amount.mul(IERC20(tokenR).balanceOf(address(this))).div(totalSupply);

        if(outTokenR > 0) {
            (uint256 maxDraw) = IPrime(tokenP).maxDraw();
            require(maxDraw >= outTokenR, "ERR_BAL_STRIKE");

            (bool success) = IERC20(tokenR).transfer(tokenP, outTokenR);

            (uint256 inTokenR) = IPrime(tokenP).redeem(msg.sender);
            assert(inTokenR == outTokenR && success);
        }

        emit Withdraw(msg.sender, outTokenU, outTokenR);
        if(tokenU == weth) {
            IWETH(weth).withdraw(outTokenU);
            return sendEther(msg.sender, outTokenU);
        } else {
            return IERC20(tokenU).transfer(msg.sender, outTokenU);
        }
    }




    function buy(
        uint256 amount,
        address tokenP
    )
        external 
        payable
        nonReentrant
        valid(tokenP)
        returns (bool)
    {
        (
            address _tokenU, // Assume DAI
            address _tokenS, // Assume ETH
            address _tokenR, // Assume Redeemable for DAI 1:1.
            uint256 _base,
            uint256 _price,
            uint256 _expiry
        ) = IPrime(tokenP).prime();

        volatility = calculateVolatilityProxy(_tokenU, _tokenR, _base, _price);
        (uint256 premium, ) = calculatePremium(_base, _price, _expiry);
        premium = amount.mul(premium).div(ONE_ETHER);

        if(_tokenS == weth) {
            require(msg.value >= premium && premium > 0, "ERR_BAL_ETH");
            IWETH(weth).deposit.value(premium)();
            sendEther(msg.sender, msg.value.sub(premium));
        } else {
            require(IERC20(_tokenS).balanceOf(msg.sender) >= amount && amount > 0, "ERR_BAL_STRIKE");
        }

        uint256 outTokenU = amount.mul(_base).div(_price); 

        (bool transferU) = IERC20(_tokenU).transfer(tokenP, outTokenU);

        (uint256 inTokenU,) = IPrime(tokenP).mint(address(this));

        emit Buy(msg.sender, amount, outTokenU, premium);
        return transferU && IPrime(tokenP).transfer(msg.sender, inTokenU);
    }

    function calculatePremium(uint256 base, uint256 price, uint256 expiry)
        public
        view
        returns (uint256 premium, uint256 timeRemainder)
    {
        uint256 market = PriceOracleProxy(oracle).getUnderlyingPrice(COMPOUND_DAI);
        uint256 strike = price.mul(ONE_ETHER).div(base);
        uint256 difference = base.mul(market).div(strike);
        uint256 intrinsic = difference >= base ? difference.sub(base) : 0;
        timeRemainder = (expiry.sub(block.timestamp));
        uint256 moneyness = strike.mul(ONE_ETHER).div(market);
        uint256 extrinsic = moneyness
                            .mul(ONE_ETHER)
                            .mul(volatility)
                            .mul(sqrt(timeRemainder))
                                .div(ONE_ETHER)
                                .div(SECONDS_IN_DAY);
        premium = (extrinsic.add(intrinsic)).mul(market).div(ONE_ETHER);
    }

    function calculateVolatilityProxy(address tokenU, address tokenR, uint256 base, uint256 price)
        public
        view
        returns (uint256 _volatility)
    {
        (uint256 utilized) = poolUtilized(tokenR, base, price);
        uint256 balanceU = IERC20(tokenU).balanceOf(address(this));
        _volatility = utilized > 0 ?
                        utilized
                        .mul(1000)
                        .div(balanceU.add(utilized)) :
                        100;

    }

    function poolUtilized(address tokenR, uint256 base, uint256 price) public view returns (uint256 utilized) {
        utilized = IERC20(tokenR).balanceOf(address(this))
                    .mul(price)
                    .mul(ONE_ETHER)
                    .div(base)
                    .div(ONE_ETHER);
    }

    function sendEther(address to, uint256 amount) private returns (bool) {
        (bool success, ) = to.call.value(amount)("");
        require(success, "ERR_SEND_ETHER");
        return success;
    }

    function sqrt(uint256 y) public pure returns (uint256 z) {
        if (y > 3) {
            uint256 x = (y + 1) / 2;
            z = y;
            while (x < z) {
                z = x;
                x = (y / x + x) / 2;
            }
        } else if (y != 0) {
            z = 1;
        }
    }
}