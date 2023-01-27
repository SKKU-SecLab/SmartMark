
pragma solidity >=0.6.0 <0.8.0;

interface IERC20 {

    function totalSupply() external view returns (uint256);


    function balanceOf(address account) external view returns (uint256);


    function transfer(address recipient, uint256 amount) external returns (bool);


    function allowance(address owner, address spender) external view returns (uint256);


    function approve(address spender, uint256 amount) external returns (bool);


    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);


    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}// MIT

pragma solidity >=0.6.0 <0.8.0;

abstract contract ReentrancyGuard {

    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor () internal {
        _status = _NOT_ENTERED;
    }

    modifier nonReentrant() {
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        _status = _ENTERED;

        _;

        _status = _NOT_ENTERED;
    }
}pragma solidity 0.6.6;


library Math {

    function min(uint256 x, uint256 y) internal pure returns (uint256 z) {

        z = x < y ? x : y;
    }

    function sqrt(uint256 y) internal pure returns (uint256 z) {

        if (y > 3) {
            z = y;
            uint256 x = y / 2 + 1;
            while (x < z) {
                z = x;
                x = (y / x + x) / 2;
            }
        } else if (y != 0) {
            z = 1;
        }
    }
}pragma solidity 0.6.6;


library SafeMathTetherswap {

    function add(uint256 x, uint256 y) internal pure returns (uint256 z) {

        require((z = x + y) >= x, "ds-math-add-overflow");
    }

    function sub(uint256 x, uint256 y) internal pure returns (uint256 z) {

        require((z = x - y) <= x, "ds-math-sub-underflow");
    }

    function mul(uint256 x, uint256 y) internal pure returns (uint256 z) {

        require(y == 0 || (z = x * y) / y == x, "ds-math-mul-overflow");
    }
}pragma solidity 0.6.6;



library UQ112x112 {

    uint224 constant Q112 = 2**112;

    function encode(uint112 y) internal pure returns (uint224 z) {

        z = uint224(y) * Q112; // never overflows
    }

    function uqdiv(uint224 x, uint112 y) internal pure returns (uint224 z) {

        z = x / uint224(y);
    }
}pragma solidity 0.6.6;

interface ITetherswapCallee {

    function TetherswapCall(
        address sender,
        uint256 amount0,
        uint256 amount1,
        bytes calldata data
    ) external;

}pragma solidity 0.6.6;

interface ITetherswapFactory {

    event PairCreated(
        address indexed token0,
        address indexed token1,
        address pair,
        uint256 pairNum
    );

    function USDT() external view returns (address);


    function WETH() external view returns (address);


    function YFTE() external view returns (address);


    function governance() external view returns (address);


    function treasury() external view returns (address);


    function priceOracle() external view returns (address);


    function usdtListingFeeInUsd() external view returns (uint256);


    function wethListingFeeInUsd() external view returns (uint256);


    function yfteListingFeeInUsd() external view returns (uint256);


    function treasuryListingFeeShare() external view returns (uint256);


    function minListingLockupAmountInUsd() external view returns (uint256);


    function targetListingLockupAmountInUsd() external view returns (uint256);


    function minListingLockupPeriod() external view returns (uint256);


    function targetListingLockupPeriod() external view returns (uint256);


    function lockupAmountListingFeeDiscountShare()
        external
        view
        returns (uint256);


    function defaultUsdtTradingFeePercent() external view returns (uint256);


    function defaultNonUsdtTradingFeePercent() external view returns (uint256);


    function treasuryProtocolFeeShare() external view returns (uint256);


    function protocolFeeFractionInverse() external view returns (uint256);


    function maxSlippagePercent() external view returns (uint256);


    function maxSlippageBlocks() external view returns (uint256);


    function getPair(address tokenA, address tokenB)
        external
        view
        returns (address pair);


    function approvedPair(address tokenA, address tokenB)
        external
        view
        returns (bool approved);


    function allPairs(uint256) external view returns (address pair);


    function allPairsLength() external view returns (uint256);


    function approvePairViaGovernance(address tokenA, address tokenB) external;


    function createPair(
        address newToken,
        uint256 newTokenAmount,
        address lockupToken, // USDT or WETH
        uint256 lockupTokenAmount,
        uint256 lockupPeriod,
        address listingFeeToken
    ) external returns (address pair);


    function setPriceOracle(address) external;


    function setTreasury(address) external;


    function setGovernance(address) external;


    function setTreasuryProtocolFeeShare(uint256) external;


    function setProtocolFeeFractionInverse(uint256) external;


    function setUsdtListingFeeInUsd(uint256) external;


    function setWethListingFeeInUsd(uint256) external;


    function setYfteListingFeeInUsd(uint256) external;


    function setTreasuryListingFeeShare(uint256) external;


    function setMinListingLockupAmountInUsd(uint256) external;


    function setTargetListingLockupAmountInUsd(uint256) external;


    function setMinListingLockupPeriod(uint256) external;


    function setTargetListingLockupPeriod(uint256) external;


    function setLockupAmountListingFeeDiscountShare(uint256) external;


    function setDefaultUsdtTradingFeePercent(uint256) external;


    function setDefaultNonUsdtTradingFeePercent(uint256) external;


    function setMaxSlippagePercent(uint256) external;


    function setMaxSlippageBlocks(uint256) external;

}pragma solidity 0.6.6;

interface ITetherswapERC20 {

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

}pragma solidity 0.6.6;


interface ITetherswapPair is ITetherswapERC20 {

    event Mint(address indexed sender, uint256 amount0, uint256 amount1);
    event Lock(
        address indexed sender,
        uint256 lockupPeriod,
        uint256 liquidityLockupAmount
    );
    event Unlock(address indexed sender, uint256 liquidityUnlocked);
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


    function addressToLockupExpiry(address) external view returns (uint256);


    function addressToLockupAmount(address) external view returns (uint256);


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


    function tradingFeePercent() external view returns (uint256);


    function lastSlippageBlocks() external view returns (uint256);


    function priceAtLastSlippageBlocks() external view returns (uint256);


    function lastSwapPrice() external view returns (uint256);


    function mint(address to) external returns (uint256 liquidity);


    function lock(uint256 lockupPeriod, uint256 liquidityLockupAmount) external;


    function unlock() external;


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


    function setTradingFeePercent(uint256 _tradingFeePercent) external;


    function initialize(
        address _token0,
        address _token1,
        uint256 _tradingFeePercent
    ) external;


    function listingLock(
        address lister,
        uint256 lockupPeriod,
        uint256 liquidityLockupAmount
    ) external;

}pragma solidity 0.6.6;


contract TetherswapPair is ITetherswapPair, ReentrancyGuard {

    using SafeMathTetherswap for uint256;
    using UQ112x112 for uint224;

    string public constant override name = "Tetherswap LP Token";
    string public constant override symbol = "TLP";
    uint8 public constant override decimals = 18;
    uint256 public override totalSupply;
    mapping(address => uint256) public override balanceOf;
    mapping(address => mapping(address => uint256)) public override allowance;

    bytes32 public override DOMAIN_SEPARATOR;
    bytes32 public constant override PERMIT_TYPEHASH =
        0x6e71edae12b1b97f4d1f60370fef10105fa2faae0126114a169c64845d6126c9;
    mapping(address => uint256) public override nonces;

    uint256 public constant override MINIMUM_LIQUIDITY = 10**3;
    bytes4 private constant SELECTOR =
        bytes4(keccak256(bytes("transfer(address,uint256)")));

    mapping(address => uint256) public override addressToLockupExpiry;
    mapping(address => uint256) public override addressToLockupAmount;

    address public override factory;
    address public override token0;
    address public override token1;

    uint112 private reserve0; // uses single storage slot, accessible via getReserves
    uint112 private reserve1; // uses single storage slot, accessible via getReserves
    uint32 private blockTimestampLast; // uses single storage slot, accessible via getReserves

    uint256 public override price0CumulativeLast;
    uint256 public override price1CumulativeLast;
    uint256 public override kLast; // reserve0 * reserve1, as of immediately after the most recent liquidity event

    uint256 public override tradingFeePercent; // need to divide by 1,000,000, e.g. 3000 = 0.3%
    uint256 public override lastSlippageBlocks;
    uint256 public override priceAtLastSlippageBlocks;
    uint256 public override lastSwapPrice;

    modifier onlyGovernance() {

        require(
            msg.sender == ITetherswapFactory(factory).governance(),
            "Pair: FORBIDDEN"
        );
        _;
    }

    constructor() public {
        factory = msg.sender;
        uint256 chainId;
        assembly {
            chainId := chainid()
        }
        DOMAIN_SEPARATOR = keccak256(
            abi.encode(
                keccak256(
                    "EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)"
                ),
                keccak256(bytes(name)),
                keccak256(bytes("1")),
                chainId,
                address(this)
            )
        );
    }

    function initialize(
        address _token0,
        address _token1,
        uint256 _tradingFeePercent
    ) external override {

        require(msg.sender == factory, "Pair: FORBIDDEN"); // sufficient check
        token0 = _token0;
        token1 = _token1;
        tradingFeePercent = _tradingFeePercent;
    }

    function _mint(address to, uint256 value) internal {

        totalSupply = totalSupply.add(value);
        balanceOf[to] = balanceOf[to].add(value);
        emit Transfer(address(0), to, value);
    }

    function _burn(address from, uint256 value) internal {

        balanceOf[from] = balanceOf[from].sub(value);
        totalSupply = totalSupply.sub(value);
        emit Transfer(from, address(0), value);
    }

    function _approve(
        address owner,
        address spender,
        uint256 value
    ) private {

        allowance[owner][spender] = value;
        emit Approval(owner, spender, value);
    }

    function _transfer(
        address from,
        address to,
        uint256 value
    ) private {

        balanceOf[from] = balanceOf[from].sub(value);
        balanceOf[to] = balanceOf[to].add(value);
        emit Transfer(from, to, value);
    }

    function approve(address spender, uint256 value)
        external
        override
        returns (bool)
    {

        _approve(msg.sender, spender, value);
        return true;
    }

    function transfer(address to, uint256 value)
        external
        override
        returns (bool)
    {

        _transfer(msg.sender, to, value);
        return true;
    }

    function transferFrom(
        address from,
        address to,
        uint256 value
    ) external override returns (bool) {

        if (allowance[from][msg.sender] != uint256(-1)) {
            allowance[from][msg.sender] = allowance[from][msg.sender].sub(
                value
            );
        }
        _transfer(from, to, value);
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
    ) external override {

        require(deadline >= block.timestamp, "Pair: EXPIRED");
        bytes32 digest =
            keccak256(
                abi.encodePacked(
                    "\x19\x01",
                    DOMAIN_SEPARATOR,
                    keccak256(
                        abi.encode(
                            PERMIT_TYPEHASH,
                            owner,
                            spender,
                            value,
                            nonces[owner]++,
                            deadline
                        )
                    )
                )
            );
        address recoveredAddress = ecrecover(digest, v, r, s);
        require(
            recoveredAddress != address(0) && recoveredAddress == owner,
            "Pair: INVALID_SIGNATURE"
        );
        _approve(owner, spender, value);
    }

    function getReserves()
        public
        view
        override
        returns (
            uint112 _reserve0,
            uint112 _reserve1,
            uint32 _blockTimestampLast
        )
    {

        _reserve0 = reserve0;
        _reserve1 = reserve1;
        _blockTimestampLast = blockTimestampLast;
    }

    function _safeTransfer(
        address token,
        address to,
        uint256 value
    ) private {

        (bool success, bytes memory data) =
            token.call(abi.encodeWithSelector(SELECTOR, to, value));
        require(
            success && (data.length == 0 || abi.decode(data, (bool))),
            "Pair: TRANSFER_FAILED"
        );
    }

    function _update(
        uint256 balance0,
        uint256 balance1,
        uint112 _reserve0,
        uint112 _reserve1
    ) private {

        require(
            balance0 <= uint112(-1) && balance1 <= uint112(-1),
            "Pair: OVERFLOW"
        );
        uint32 blockTimestamp = uint32(block.timestamp % 2**32);
        uint32 timeElapsed = blockTimestamp - blockTimestampLast; // overflow is desired
        if (timeElapsed > 0 && _reserve0 != 0 && _reserve1 != 0) {
            price0CumulativeLast +=
                uint256(UQ112x112.encode(_reserve1).uqdiv(_reserve0)) *
                timeElapsed;
            price1CumulativeLast +=
                uint256(UQ112x112.encode(_reserve0).uqdiv(_reserve1)) *
                timeElapsed;
        }
        reserve0 = uint112(balance0);
        reserve1 = uint112(balance1);
        blockTimestampLast = blockTimestamp;
        emit Sync(reserve0, reserve1);
    }

    function _mintFee(uint112 _reserve0, uint112 _reserve1)
        private
        returns (bool feeOn)
    {

        uint256 protocolFeeFractionInverse =
            ITetherswapFactory(factory).protocolFeeFractionInverse();
        feeOn = protocolFeeFractionInverse != 0;
        uint256 _kLast = kLast; // gas savings
        if (feeOn) {
            if (_kLast != 0) {
                uint256 rootK = Math.sqrt(uint256(_reserve0).mul(_reserve1));
                uint256 rootKLast = Math.sqrt(_kLast);
                if (rootK > rootKLast) {
                    uint256 liquidity =
                        totalSupply.mul(rootK.sub(rootKLast)).mul(1000) /
                            (
                                (
                                    rootK.mul(
                                        protocolFeeFractionInverse.sub(1000)
                                    )
                                )
                                    .add(rootKLast.mul(1000))
                            );
                    if (liquidity > 0) {
                        ITetherswapFactory TetherswapFactory =
                            ITetherswapFactory(factory);
                        uint256 treasuryProtocolFeeShare =
                            TetherswapFactory.treasuryProtocolFeeShare();
                        _mint(
                            TetherswapFactory.treasury(),
                            liquidity.mul(treasuryProtocolFeeShare) / 1000000
                        );
                        _mint(
                            TetherswapFactory.governance(),
                            liquidity.mul(
                                uint256(1000000).sub(treasuryProtocolFeeShare)
                            ) / 1000000
                        );
                    }
                }
            }
        } else if (_kLast != 0) {
            kLast = 0;
        }
    }

    function mint(address to)
        public
        override
        nonReentrant
        returns (uint256 liquidity)
    {

        (uint112 _reserve0, uint112 _reserve1, ) = getReserves(); // gas savings
        uint256 balance0 = IERC20(token0).balanceOf(address(this));
        uint256 balance1 = IERC20(token1).balanceOf(address(this));
        uint256 amount0 = balance0.sub(_reserve0);
        uint256 amount1 = balance1.sub(_reserve1);

        bool feeOn = _mintFee(_reserve0, _reserve1);
        uint256 _totalSupply = totalSupply; // gas savings, must be defined here since totalSupply can update in _mintFee
        if (_totalSupply == 0) {
            liquidity = Math.sqrt(amount0.mul(amount1)).sub(MINIMUM_LIQUIDITY);
            _mint(address(0), MINIMUM_LIQUIDITY); // permanently lock the first MINIMUM_LIQUIDITY tokens
        } else {
            liquidity = Math.min(
                amount0.mul(_totalSupply) / _reserve0,
                amount1.mul(_totalSupply) / _reserve1
            );
        }
        require(liquidity > 0, "Pair: INSUFFICIENT_LIQUIDITY_MINTED");
        _mint(to, liquidity);

        _update(balance0, balance1, _reserve0, _reserve1);
        if (feeOn) kLast = uint256(reserve0).mul(reserve1); // reserve0 and reserve1 are up-to-date
        emit Mint(msg.sender, amount0, amount1);
    }

    function _lock(
        address locker,
        uint256 lockupPeriod,
        uint256 liquidityLockupAmount
    ) private {

        if (lockupPeriod == 0 && liquidityLockupAmount == 0) return;
        if (addressToLockupExpiry[locker] == 0) {
            require(lockupPeriod > 0, "Pair: ZERO_LOCKUP_PERIOD");
            require(liquidityLockupAmount > 0, "Pair: ZERO_LOCKUP_AMOUNT");
            addressToLockupExpiry[locker] = block.timestamp.add(lockupPeriod);
        } else {
            addressToLockupExpiry[locker] = addressToLockupExpiry[locker].add(
                lockupPeriod
            );
        }
        addressToLockupAmount[locker] = addressToLockupAmount[locker].add(
            liquidityLockupAmount
        );
        _transfer(locker, address(this), liquidityLockupAmount);
        emit Lock(locker, lockupPeriod, liquidityLockupAmount);
    }

    function listingLock(
        address lister,
        uint256 lockupPeriod,
        uint256 liquidityLockupAmount
    ) external override {

        require(msg.sender == factory, "Pair: FORBIDDEN");
        _lock(lister, lockupPeriod, liquidityLockupAmount);
    }

    function lock(uint256 lockupPeriod, uint256 liquidityLockupAmount)
        external
        override
    {

        _lock(msg.sender, lockupPeriod, liquidityLockupAmount);
    }

    function unlock() external override {

        require(
            addressToLockupExpiry[msg.sender] <= block.timestamp,
            "Pair: BEFORE_EXPIRY"
        );
        _transfer(address(this), msg.sender, addressToLockupAmount[msg.sender]);
        emit Unlock(msg.sender, addressToLockupAmount[msg.sender]);
        addressToLockupAmount[msg.sender] = 0;
        addressToLockupExpiry[msg.sender] = 0;
    }

    function burn(address to)
        external
        override
        nonReentrant
        returns (uint256 amount0, uint256 amount1)
    {

        (uint112 _reserve0, uint112 _reserve1, ) = getReserves(); // gas savings
        address _token0 = token0; // gas savings
        address _token1 = token1; // gas savings
        uint256 balance0 = IERC20(_token0).balanceOf(address(this));
        uint256 balance1 = IERC20(_token1).balanceOf(address(this));
        uint256 liquidity = balanceOf[address(this)];

        bool feeOn = _mintFee(_reserve0, _reserve1);
        uint256 _totalSupply = totalSupply; // gas savings, must be defined here since totalSupply can update in _mintFee
        amount0 = liquidity.mul(balance0) / _totalSupply; // using balances ensures pro-rata distribution
        amount1 = liquidity.mul(balance1) / _totalSupply; // using balances ensures pro-rata distribution
        require(
            amount0 > 0 && amount1 > 0,
            "Pair: INSUFFICIENT_LIQUIDITY_BURNED"
        );
        _burn(address(this), liquidity);
        _safeTransfer(_token0, to, amount0);
        _safeTransfer(_token1, to, amount1);
        balance0 = IERC20(_token0).balanceOf(address(this));
        balance1 = IERC20(_token1).balanceOf(address(this));

        _update(balance0, balance1, _reserve0, _reserve1);
        if (feeOn) kLast = uint256(reserve0).mul(reserve1); // reserve0 and reserve1 are up-to-date
        emit Burn(msg.sender, amount0, amount1, to);
    }

    function swap(
        uint256 amount0Out,
        uint256 amount1Out,
        address to,
        bytes calldata data
    ) external override nonReentrant {

        require(
            amount0Out > 0 || amount1Out > 0,
            "Pair: INSUFFICIENT_OUTPUT_AMOUNT"
        );
        (uint112 _reserve0, uint112 _reserve1, ) = getReserves(); // gas savings
        require(
            amount0Out < _reserve0 && amount1Out < _reserve1,
            "Pair: INSUFFICIENT_LIQUIDITY"
        );

        uint256 balance0;
        uint256 balance1;
        {
            address _token0 = token0;
            address _token1 = token1;
            require(to != _token0 && to != _token1, "Pair: INVALID_TO");
            if (amount0Out > 0) _safeTransfer(_token0, to, amount0Out); // optimistically transfer tokens
            if (amount1Out > 0) _safeTransfer(_token1, to, amount1Out); // optimistically transfer tokens
            if (data.length > 0)
                ITetherswapCallee(to).TetherswapCall(
                    msg.sender,
                    amount0Out,
                    amount1Out,
                    data
                );
            balance0 = IERC20(_token0).balanceOf(address(this));
            balance1 = IERC20(_token1).balanceOf(address(this));
            if (ITetherswapFactory(factory).maxSlippagePercent() > 0) {
                uint256 currentPrice = balance0.mul(1e18) / balance1;
                if (priceAtLastSlippageBlocks == 0) {
                    priceAtLastSlippageBlocks = currentPrice;
                    lastSlippageBlocks = block.number;
                } else {
                    bool resetSlippage =
                        lastSlippageBlocks.add(
                            ITetherswapFactory(factory).maxSlippageBlocks()
                        ) < block.number;
                    uint256 lastPrice =
                        resetSlippage
                            ? lastSwapPrice
                            : priceAtLastSlippageBlocks;
                    require(
                        currentPrice >=
                            lastPrice.mul(
                                uint256(100).sub(
                                    ITetherswapFactory(factory)
                                        .maxSlippagePercent()
                                )
                            ) /
                                100 &&
                            currentPrice <=
                            lastPrice.mul(
                                uint256(100).add(
                                    ITetherswapFactory(factory)
                                        .maxSlippagePercent()
                                )
                            ) /
                                100,
                        "Pair: SlipLock"
                    );
                    if (resetSlippage) {
                        priceAtLastSlippageBlocks = currentPrice;
                        lastSlippageBlocks = block.number;
                    }
                }
                lastSwapPrice = currentPrice;
            }
        }
        uint256 amount0In =
            balance0 > _reserve0 - amount0Out
                ? balance0 - (_reserve0 - amount0Out)
                : 0;
        uint256 amount1In =
            balance1 > _reserve1 - amount1Out
                ? balance1 - (_reserve1 - amount1Out)
                : 0;
        require(
            amount0In > 0 || amount1In > 0,
            "Pair: INSUFFICIENT_INPUT_AMOUNT"
        );
        {
            uint256 balance0Adjusted =
                balance0.mul(1e6).sub(amount0In.mul(tradingFeePercent));
            uint256 balance1Adjusted =
                balance1.mul(1e6).sub(amount1In.mul(tradingFeePercent));
            require(
                balance0Adjusted.mul(balance1Adjusted) >=
                    uint256(_reserve0).mul(_reserve1).mul(1e6**2),
                "Pair: K"
            );
        }

        _update(balance0, balance1, _reserve0, _reserve1);
        emit Swap(msg.sender, amount0In, amount1In, amount0Out, amount1Out, to);
    }

    function skim(address to) external override nonReentrant {

        address _token0 = token0; // gas savings
        address _token1 = token1; // gas savings
        _safeTransfer(
            _token0,
            to,
            IERC20(_token0).balanceOf(address(this)).sub(reserve0)
        );
        _safeTransfer(
            _token1,
            to,
            IERC20(_token1).balanceOf(address(this)).sub(reserve1)
        );
    }

    function sync() external override nonReentrant {

        _update(
            IERC20(token0).balanceOf(address(this)),
            IERC20(token1).balanceOf(address(this)),
            reserve0,
            reserve1
        );
    }

    function _setTradingFeePercent(uint256 _tradingFeePercent) private {

        require(
            _tradingFeePercent <= 10000,
            "Pair: INVALID_TRADING_FEE_PERCENT"
        );
        tradingFeePercent = _tradingFeePercent;
    }

    function setTradingFeePercent(uint256 _tradingFeePercent)
        external
        override
        onlyGovernance
    {

        _setTradingFeePercent(_tradingFeePercent);
    }
}