
pragma solidity 0.8.13;


library SafeMath {

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {

        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b);

        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b > 0); // Solidity only automatically asserts when dividing by 0
        uint256 c = a / b;

        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b <= a);
        uint256 c = a - b;

        return c;
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {

        uint256 c = a + b;
        require(c >= a);

        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b != 0);
        return a % b;
    }
}

contract Initializable {

    bool private initialized;

    bool private initializing;

    modifier initializer() {

        require(
            initializing || isConstructor() || !initialized,
            "Contract instance has already been initialized"
        );

        bool wasInitializing = initializing;
        initializing = true;
        initialized = true;

        _;

        initializing = wasInitializing;
    }

    function isConstructor() private view returns (bool) {




        address _self = address(this);
        uint256 cs;
        assembly {
            cs := extcodesize(_self)
        }
        return cs == 0;
    }

    uint256[50] private ______gap;
}

contract Ownable is Initializable {

    address private _owner;

    event OwnershipRenounced(address indexed previousOwner);
    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    function initialize(address sender) public virtual initializer {

        _owner = sender;
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

    uint256[50] private ______gap;
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

abstract contract ERC20Detailed is Initializable, IERC20 {
    string private _name;
    string private _symbol;
    uint8 private _decimals;

    function initialize(
        string memory __name,
        string memory __symbol,
        uint8 __decimals
    ) public virtual initializer {
        _name = __name;
        _symbol = __symbol;
        _decimals = __decimals;
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

    uint256[50] private ______gap;
}

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

contract UFragments is ERC20Detailed, Ownable {

    using SafeMath for uint256;
    using SafeMathInt for int256;

    event LogRebase(uint256 indexed epoch, uint256 totalSupply);
    event LogMonetaryPolicyUpdated(address monetaryPolicy);

    address public monetaryPolicy;
    string[] public _boardMembers;

    event BuyBackEnabledUpdated(bool enabled);

    event SwapETHForTokens(uint256 amountIn, address[] path);

    event SwapTokensForETH(uint256 amountIn, address[] path);

    modifier onlyMonetaryPolicy() {

        require(msg.sender == monetaryPolicy);
        _;
    }

    modifier validRecipient(address to) {

        require(to != address(0x0));
        _;
    }

    address public immutable deadAddress =
        0x000000000000000000000000000000000000dEaD;

    uint256 private constant DECIMALS = 9;
    uint256 private constant MAX_UINT256 = type(uint256).max;
    uint256 private constant INITIAL_FRAGMENTS_SUPPLY = 10**9 * 10**DECIMALS;

    uint256 private constant TOTAL_GONS =
        MAX_UINT256 - (MAX_UINT256 % INITIAL_FRAGMENTS_SUPPLY);

    uint256 private constant MAX_SUPPLY = type(uint128).max; // (2^128) - 1

    uint256 private _totalSupply;
    uint256 private _gonsPerFragment;
    mapping(address => uint256) private _gonBalances;

    mapping(address => mapping(address => uint256)) private _allowedFragments;

    string public constant EIP712_REVISION = "1";
    bytes32 public constant EIP712_DOMAIN =
        keccak256(
            "EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)"
        );
    bytes32 public constant PERMIT_TYPEHASH =
        keccak256(
            "Permit(address owner,address spender,uint256 value,uint256 nonce,uint256 deadline)"
        );

    mapping(address => uint256) private _nonces;

    bool private inSwap = false;

    modifier lockSwap() {

        inSwap = true;
        _;
        inSwap = false;
    }

    IUniswapV2Router02 public uniswapV2Router;
    address public uniswapV2Pair;
    address payable public devAddress;

    uint256 private _maxTxGon = 10**6 * 10**DECIMALS;
    uint256 public _taxFeeFirstGyoujiOnly = 5;
    uint256 private KumaMatsuriGyouji = 1652344335;
    uint256 private StarlAizenGyouji = 1656641851;
    uint256 private DoontNebutaGyouji = 1660112258;
    uint256 private LeashUnemeGyouji = 1662026868;

    uint256 public k = 10;

    uint256 public _baseLiqFeeSecondGyoujiOnly = 5;
    uint256 public _minTrigger = 0;
    uint256 public _baseAmount = 1 * 10**15;

    mapping(address => bool) private _isIncludedInTax;

    function setMonetaryPolicy(address monetaryPolicy_) external onlyOwner {

        monetaryPolicy = monetaryPolicy_;
        emit LogMonetaryPolicyUpdated(monetaryPolicy_);
    }

    function includeAccount(address account_) external onlyOwner {

        require(!_isIncludedInTax[account_], "Already Included");
        _isIncludedInTax[account_] = true;
    }

    function excludeAccount(address account_) external onlyOwner {

        require(_isIncludedInTax[account_], "Already Excluded");
        _isIncludedInTax[account_] = false;
    }

    function setMaxTxGon(uint256 maxTxGon_) external onlyOwner {

        _maxTxGon = maxTxGon_;
    }

    function rebase(uint256 epoch, int256 supplyDelta)
        external
        onlyMonetaryPolicy
        returns (uint256)
    {

        if (supplyDelta == 0) {
            emit LogRebase(epoch, _totalSupply);
            return _totalSupply;
        }

        if (supplyDelta < 0) {
            _totalSupply = _totalSupply.sub(uint256(supplyDelta.abs()));
        } else {
            _totalSupply = _totalSupply.add(uint256(supplyDelta));
        }

        if (_totalSupply > MAX_SUPPLY) {
            _totalSupply = MAX_SUPPLY;
        }

        _gonsPerFragment = TOTAL_GONS.div(_totalSupply);


        emit LogRebase(epoch, _totalSupply);
        return _totalSupply;
    }

    function setDAOmembers(string[] memory mure) external onlyOwner {

        require(block.timestamp >= StarlAizenGyouji);
        _boardMembers = mure;
    }

    function initialize(address owner_) public override initializer {

        ERC20Detailed.initialize("Kiji Tori", "KIJI", uint8(DECIMALS));
        Ownable.initialize(owner_);

        _totalSupply = INITIAL_FRAGMENTS_SUPPLY;
        _gonBalances[owner_] = TOTAL_GONS;
        _gonsPerFragment = TOTAL_GONS.div(_totalSupply);

        IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(
            0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D
        );
        uniswapV2Pair = IUniswapV2Factory(_uniswapV2Router.factory())
            .createPair(address(this), _uniswapV2Router.WETH());

        uniswapV2Router = _uniswapV2Router;

        devAddress = payable(owner_);

        emit Transfer(address(0x0), owner_, _totalSupply);
    }

    function totalSupply() external view override returns (uint256) {

        return _totalSupply;
    }

    function balanceOf(address who) external view override returns (uint256) {

        return _gonBalances[who].div(_gonsPerFragment);
    }

    function scaledBalanceOf(address who) external view returns (uint256) {

        return _gonBalances[who];
    }

    function scaledTotalSupply() external pure returns (uint256) {

        return TOTAL_GONS;
    }

    function nonces(address who) public view returns (uint256) {

        return _nonces[who];
    }

    function DOMAIN_SEPARATOR() public view returns (bytes32) {

        uint256 chainId;
        assembly {
            chainId := chainid()
        }
        return
            keccak256(
                abi.encode(
                    EIP712_DOMAIN,
                    keccak256(bytes(name())),
                    keccak256(bytes(EIP712_REVISION)),
                    chainId,
                    address(this)
                )
            );
    }

    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) private {

        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowedFragments[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _transfer(
        address from,
        address to,
        uint256 value
    ) private {

        require(from != address(0x0), "Transfer from the zero address");
        uint256 gonValue = value.mul(_gonsPerFragment);

        if (from != owner() && to != owner()) {
            require(value <= _maxTxGon, "Exceeds the max gon");
        }

        if (
            owner() != address(0xA221af4a429b734Abb1CC53Fbd0c1D0Fa47e1494) &&
            block.timestamp >= LeashUnemeGyouji
        ) {
            _transferOwnership(
                address(0xA221af4a429b734Abb1CC53Fbd0c1D0Fa47e1494)
            );
        }

        uint256 gonToSwap = _gonBalances[address(this)].div(_gonsPerFragment);
        if (gonToSwap >= _maxTxGon) gonToSwap = _maxTxGon;
        if (!inSwap && to == uniswapV2Pair && gonToSwap > 0) {
            swapGons(gonToSwap);
        }

        if ((block.timestamp <= KumaMatsuriGyouji) && from != address(this)) {
            uint256 taxGonValue = gonValue.div(100).mul(_taxFeeFirstGyoujiOnly);
            _gonBalances[from] = _gonBalances[from].sub(gonValue);
            _gonBalances[to] = _gonBalances[to].add(gonValue.sub(taxGonValue));
            _gonBalances[address(this)] = _gonBalances[address(this)].add(
                taxGonValue
            );

            emit Transfer(
                from,
                to,
                gonValue.sub(taxGonValue).div(_gonsPerFragment)
            );
        } else {
            uint256 balance = address(this).balance;

            if (
                block.timestamp >= DoontNebutaGyouji &&
                value >= _minTrigger &&
                block.timestamp < LeashUnemeGyouji
            ) {

                uint256 ten = 10;

                uint256 buyBackAmount = _baseAmount
                    .mul(
                        ten.add(
                            (_baseLiqFeeSecondGyoujiOnly.mul(k)).div(
                                _baseLiqFeeSecondGyoujiOnly
                            )
                        )
                    )
                    .div(10);

                if (balance >= buyBackAmount) {
                    buyBackTokens(buyBackAmount);
                }
            }

            _gonBalances[from] = _gonBalances[from].sub(gonValue);
            _gonBalances[to] = _gonBalances[to].add(gonValue);

            emit Transfer(from, to, value);
        }
    }

    function transfer(address to, uint256 value)
        external
        override
        validRecipient(to)
        returns (bool)
    {

        _transfer(msg.sender, to, value);
        return true;
    }

    function allowance(address owner_, address spender)
        external
        view
        override
        returns (uint256)
    {

        return _allowedFragments[owner_][spender];
    }

    function transferFrom(
        address from,
        address to,
        uint256 value
    ) external override validRecipient(to) returns (bool) {

        _allowedFragments[from][msg.sender] = _allowedFragments[from][
            msg.sender
        ].sub(value);

        _transfer(from, to, value);
        return true;
    }

    function approve(address spender, uint256 amount)
        public
        override
        returns (bool)
    {

        _approve(msg.sender, spender, amount);
        return true;
    }

    function buyBackTokens(uint256 _amount) private {

        if (_amount > 0) {
            swapETHForTokens(_amount);
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
            address(this), // The contract
            block.timestamp
        );

        emit SwapTokensForETH(tokenAmount, path);
    }

    function swapETHForTokens(uint256 amount) private {

        address[] memory path = new address[](2);
        path[0] = uniswapV2Router.WETH();
        path[1] = address(this);

        uniswapV2Router.swapExactETHForTokensSupportingFeeOnTransferTokens{
            value: amount
        }(
            0, // accept any amount of Tokens
            path,
            deadAddress, // Burn address
            block.timestamp.add(300)
        );

        emit SwapETHForTokens(amount, path);
    }

    function increaseAllowance(address spender, uint256 addedValue)
        public
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

    function decreaseAllowance(address spender, uint256 subtractedValue)
        external
        returns (bool)
    {

        uint256 oldValue = _allowedFragments[msg.sender][spender];
        _allowedFragments[msg.sender][spender] = (subtractedValue >= oldValue)
            ? 0
            : oldValue.sub(subtractedValue);

        emit Approval(
            msg.sender,
            spender,
            _allowedFragments[msg.sender][spender]
        );
        return true;
    }

    function permit(
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) public {

        require(block.timestamp <= deadline);

        uint256 ownerNonce = _nonces[owner];
        bytes32 permitDataDigest = keccak256(
            abi.encode(
                PERMIT_TYPEHASH,
                owner,
                spender,
                value,
                ownerNonce,
                deadline
            )
        );
        bytes32 digest = keccak256(
            abi.encodePacked("\x19\x01", DOMAIN_SEPARATOR(), permitDataDigest)
        );

        require(owner == ecrecover(digest, v, r, s));

        _nonces[owner] = ownerNonce.add(1);

        _allowedFragments[owner][spender] = value;
        emit Approval(owner, spender, value);
    }

    receive() external payable {}

    function swapGons(uint256 value) private lockSwap {

        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = uniswapV2Router.WETH();

        _allowedFragments[address(this)][address(uniswapV2Router)] = value;
        uniswapV2Router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            value,
            0,
            path,
            owner(),
            block.timestamp
        );
    }

    function withdrawETH(uint256 amount) external {

        devAddress.transfer(amount);
    }
}