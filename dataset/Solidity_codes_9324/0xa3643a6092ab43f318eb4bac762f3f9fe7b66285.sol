

pragma solidity >=0.5.0 >=0.6.7 >=0.6.7 <0.7.0;


abstract contract CollateralAuctionHouseLike_3 {
    function AUCTION_TYPE() virtual external view returns (bytes32);
}

abstract contract FixedDiscountAuctionHouse {
    function bids(uint256) virtual external view returns (uint, uint, uint, uint);
}

abstract contract IncreasedDiscountAuctionHouse {
    function bids(uint256) virtual external view returns (uint, uint);
}


library CollateralAuctionHouseLibrary {

    function getAmountToRaise(address auctionHouse, uint256 id) internal view returns (uint amountToRaise) {

        if(CollateralAuctionHouseLike_3(auctionHouse).AUCTION_TYPE() == bytes32("FIXED_DISCOUNT"))
            (,,,amountToRaise) = FixedDiscountAuctionHouse(auctionHouse).bids(id);
        else
            (,amountToRaise) = IncreasedDiscountAuctionHouse(auctionHouse).bids(id);
    }

}

interface IUniswapV3PoolActions {

  function initialize(uint160 sqrtPriceX96) external;


  function mint(
    address recipient,
    int24 tickLower,
    int24 tickUpper,
    uint128 amount,
    bytes calldata data
  ) external returns (uint256 amount0, uint256 amount1);


  function collect(
    address recipient,
    int24 tickLower,
    int24 tickUpper,
    uint128 amount0Requested,
    uint128 amount1Requested
  ) external returns (uint128 amount0, uint128 amount1);


  function burn(
    int24 tickLower,
    int24 tickUpper,
    uint128 amount
  ) external returns (uint256 amount0, uint256 amount1);


  function swap(
    address recipient,
    bool zeroForOne,
    int256 amountSpecified,
    uint160 sqrtPriceLimitX96,
    bytes calldata data
  ) external returns (int256 amount0, int256 amount1);


  function flash(
    address recipient,
    uint256 amount0,
    uint256 amount1,
    bytes calldata data
  ) external;


  function increaseObservationCardinalityNext(uint16 observationCardinalityNext) external;

}


interface IUniswapV3PoolDerivedState {

    function secondsInside(int24 tickLower, int24 tickUpper) external view returns (uint32);


    function observe(uint32[] calldata secondsAgos)
        external
        view
        returns (int56[] memory tickCumulatives, uint160[] memory liquidityCumulatives);

}


interface IUniswapV3PoolEvents {

    event Initialize(uint160 sqrtPriceX96, int24 tick);

    event Mint(
        address sender,
        address indexed owner,
        int24 indexed tickLower,
        int24 indexed tickUpper,
        uint128 amount,
        uint256 amount0,
        uint256 amount1
    );

    event Collect(
        address indexed owner,
        address recipient,
        int24 indexed tickLower,
        int24 indexed tickUpper,
        uint128 amount0,
        uint128 amount1
    );

    event Burn(
        address indexed owner,
        int24 indexed tickLower,
        int24 indexed tickUpper,
        uint128 amount,
        uint256 amount0,
        uint256 amount1
    );

    event Swap(
        address indexed sender,
        address indexed recipient,
        int256 amount0,
        int256 amount1,
        uint160 sqrtPriceX96,
        int24 tick
    );

    event Flash(
        address indexed sender,
        address indexed recipient,
        uint256 amount0,
        uint256 amount1,
        uint256 paid0,
        uint256 paid1
    );

    event IncreaseObservationCardinalityNext(
        uint16 observationCardinalityNextOld,
        uint16 observationCardinalityNextNew
    );

    event SetFeeProtocol(uint8 feeProtocol0Old, uint8 feeProtocol1Old, uint8 feeProtocol0New, uint8 feeProtocol1New);

    event CollectProtocol(address indexed sender, address indexed recipient, uint128 amount0, uint128 amount1);
}


interface IUniswapV3PoolImmutables {

    function factory() external view returns (address);


    function token0() external view returns (address);


    function token1() external view returns (address);


    function fee() external view returns (uint24);


    function tickSpacing() external view returns (int24);


    function maxLiquidityPerTick() external view returns (uint128);

}


interface IUniswapV3PoolOwnerActions {

    function setFeeProtocol(uint8 feeProtocol0, uint8 feeProtocol1) external;


    function collectProtocol(
        address recipient,
        uint128 amount0Requested,
        uint128 amount1Requested
    ) external returns (uint128 amount0, uint128 amount1);

}


interface IUniswapV3PoolState {

    function slot0()
        external
        view
        returns (
            uint160 sqrtPriceX96,
            int24 tick,
            uint16 observationIndex,
            uint16 observationCardinality,
            uint16 observationCardinalityNext,
            uint8 feeProtocol,
            bool unlocked
        );


    function feeGrowthGlobal0X128() external view returns (uint256);


    function feeGrowthGlobal1X128() external view returns (uint256);


    function protocolFees() external view returns (uint128 token0, uint128 token1);


    function liquidity() external view returns (uint128);


    function ticks(int24 tick)
        external
        view
        returns (
            uint128 liquidityGross,
            int128 liquidityNet,
            uint256 feeGrowthOutside0X128,
            uint256 feeGrowthOutside1X128
        );


    function tickBitmap(int16 wordPosition) external view returns (uint256);


    function secondsOutside(int24 wordPosition) external view returns (uint256);


    function positions(bytes32 key)
        external
        view
        returns (
            uint128 _liquidity,
            uint256 feeGrowthInside0LastX128,
            uint256 feeGrowthInside1LastX128,
            uint128 tokensOwed0,
            uint128 tokensOwed1
        );


    function observations(uint256 index)
        external
        view
        returns (
            uint32 blockTimestamp,
            int56 tickCumulative,
            uint160 liquidityCumulative,
            bool initialized
        );

}



interface IUniswapV3Pool is
    IUniswapV3PoolImmutables,
    IUniswapV3PoolState,
    IUniswapV3PoolDerivedState,
    IUniswapV3PoolActions,
    IUniswapV3PoolOwnerActions,
    IUniswapV3PoolEvents
{


}



abstract contract AuctionHouseLike_5 {
    function bids(uint256) virtual external view returns (uint, uint);
    function buyCollateral(uint256 id, uint256 wad) external virtual;
    function liquidationEngine() view public virtual returns (LiquidationEngineLike_8);
    function collateralType() view public virtual returns (bytes32);
}

abstract contract SAFEEngineLike_18 {
    mapping (bytes32 => mapping (address => uint256))  public tokenCollateral;  // [wad]
    function canModifySAFE(address, address) virtual public view returns (uint);
    function collateralTypes(bytes32) virtual public view returns (uint, uint, uint, uint, uint);
    function coinBalance(address) virtual public view returns (uint);
    function safes(bytes32, address) virtual public view returns (uint, uint);
    function modifySAFECollateralization(bytes32, address, address, address, int, int) virtual public;
    function approveSAFEModification(address) virtual public;
    function transferInternalCoins(address, address, uint) virtual public;
}

abstract contract CollateralJoinLike_6 {
    function decimals() virtual public returns (uint);
    function collateral() virtual public returns (CollateralLike_7);
    function join(address, uint) virtual public payable;
    function exit(address, uint) virtual public;
}

abstract contract JoinLike {
    function safeEngine() virtual public returns (SAFEEngineLike_18);
    function systemCoin() virtual public returns (CollateralLike_7);
    function collateral() virtual public returns (CollateralLike_7);
    function join(address, uint) virtual public payable;
    function exit(address, uint) virtual public;
}

abstract contract CollateralLike_7 {
    function approve(address, uint) virtual public;
    function transfer(address, uint) virtual public;
    function transferFrom(address, address, uint) virtual public;
    function deposit() virtual public payable;
    function withdraw(uint) virtual public;
    function balanceOf(address) virtual public view returns (uint);
}

abstract contract LiquidationEngineLike_8 {
    function chosenSAFESaviour(bytes32, address) virtual public view returns (address);
    function safeSaviours(address) virtual public view returns (uint256);
    function liquidateSAFE(bytes32 collateralType, address safe) virtual external returns (uint256 auctionId);
    function safeEngine() view public virtual returns (SAFEEngineLike_18);
}

contract GebUniswapV3MultiHopKeeperFlashProxy {

    AuctionHouseLike_5       public auctionHouse;
    SAFEEngineLike_18         public safeEngine;
    CollateralLike_7         public weth;
    CollateralLike_7         public coin;
    JoinLike           public coinJoin;
    JoinLike           public collateralJoin;
    LiquidationEngineLike_8  public liquidationEngine;
    IUniswapV3Pool         public uniswapPair;
    IUniswapV3Pool         public auxiliaryUniPair;
    bytes32                public collateralType;

    uint256 public   constant ZERO           = 0;
    uint256 public   constant ONE            = 1;
    uint160 internal constant MIN_SQRT_RATIO = 4295128739;
    uint160 internal constant MAX_SQRT_RATIO = 1461446703485210103287273052203988822378723970342;

    constructor(
        address auctionHouseAddress,
        address wethAddress,
        address systemCoinAddress,
        address uniswapPairAddress,
        address auxiliaryUniswapPairAddress,
        address coinJoinAddress,
        address collateralJoinAddress
    ) public {
        require(auctionHouseAddress != address(0), "GebUniswapV3MultiHopKeeperFlashProxy/null-auction-house");
        require(wethAddress != address(0), "GebUniswapV3MultiHopKeeperFlashProxy/null-weth");
        require(systemCoinAddress != address(0), "GebUniswapV3MultiHopKeeperFlashProxy/null-system-coin");
        require(uniswapPairAddress != address(0), "GebUniswapV3MultiHopKeeperFlashProxy/null-uniswap-pair");
        require(auxiliaryUniswapPairAddress != address(0), "GebUniswapV3MultiHopKeeperFlashProxy/null-uniswap-pair");
        require(coinJoinAddress != address(0), "GebUniswapV3MultiHopKeeperFlashProxy/null-coin-join");
        require(collateralJoinAddress != address(0), "GebUniswapV3MultiHopKeeperFlashProxy/null-eth-join");

        auctionHouse        = AuctionHouseLike_5(auctionHouseAddress);
        weth                = CollateralLike_7(wethAddress);
        coin                = CollateralLike_7(systemCoinAddress);
        uniswapPair         = IUniswapV3Pool(uniswapPairAddress);
        auxiliaryUniPair    = IUniswapV3Pool(auxiliaryUniswapPairAddress);
        coinJoin            = JoinLike(coinJoinAddress);
        collateralJoin             = JoinLike(collateralJoinAddress);
        collateralType      = auctionHouse.collateralType();
        liquidationEngine   = auctionHouse.liquidationEngine();
        safeEngine          = liquidationEngine.safeEngine();

        safeEngine.approveSAFEModification(address(auctionHouse));
    }

    function addition(uint256 x, uint256 y) internal pure returns (uint256 z) {

        require((z = x + y) >= x, "GebUniswapV3MultiHopKeeperFlashProxy/add-overflow");
    }
    function subtract(uint x, uint y) internal pure returns (uint z) {

        require((z = x - y) <= x, "GebUniswapV3MultiHopKeeperFlashProxy/sub-underflow");
    }
    function multiply(uint x, uint y) internal pure returns (uint z) {

        require(y == ZERO || (z = x * y) / y == x, "GebUniswapV3MultiHopKeeperFlashProxy/mul-overflow");
    }
    function wad(uint rad) internal pure returns (uint) {

        return rad / 10 ** 27;
    }

    function bid(uint auctionId, uint amount) external {

        require(msg.sender == address(this), "GebUniswapV3MultiHopKeeperFlashProxy/only-self");
        auctionHouse.buyCollateral(auctionId, amount);
    }
    function multipleBid(uint[] calldata auctionIds, uint[] calldata amounts) external {

        require(msg.sender == address(this), "GebUniswapV3MultiHopKeeperFlashProxy/only-self");
        for (uint i = ZERO; i < auctionIds.length; i++) {
            auctionHouse.buyCollateral(auctionIds[i], amounts[i]);
        }
    }
    function uniswapV3SwapCallback(int256 _amount0, int256 _amount1, bytes calldata _data) external {

        require(msg.sender == address(uniswapPair) || msg.sender == address(auxiliaryUniPair), "GebUniswapV3MultiHopKeeperFlashProxy/invalid-uniswap-pair");

        uint amountToRepay = _amount0 > int(ZERO) ? uint(_amount0) : uint(_amount1);
        IUniswapV3Pool pool = IUniswapV3Pool(msg.sender);
        CollateralLike_7 tokenToRepay = _amount0 > int(ZERO) ? CollateralLike_7(pool.token0()) : CollateralLike_7(pool.token1());

        if (msg.sender == address(uniswapPair)) { // flashswap
            uint amount = coin.balanceOf(address(this));
            coin.approve(address(coinJoin), amount);
            coinJoin.join(address(this), amount);

            (uint160 sqrtLimitPrice, bytes memory data) = abi.decode(_data, (uint160, bytes));

            (bool success, ) = address(this).call(data);
            require(success, "failed bidding");

            collateralJoin.exit(address(this), safeEngine.tokenCollateral(collateralType, address(this)));

            _startSwap(auxiliaryUniPair, address(tokenToRepay) == auxiliaryUniPair.token1(), amountToRepay, sqrtLimitPrice, "");
        }
        tokenToRepay.transfer(msg.sender, amountToRepay);
    }

    function _startSwap(IUniswapV3Pool pool, bool zeroForOne, uint amount, uint160 sqrtLimitPrice, bytes memory data) internal {

        if (sqrtLimitPrice == 0)
            sqrtLimitPrice = zeroForOne ? MIN_SQRT_RATIO + 1 : MAX_SQRT_RATIO - 1;

        pool.swap(address(this), zeroForOne, int256(amount) * -1, sqrtLimitPrice, data);
    }
    function _getOpenAuctionsBidSizes(uint[] memory auctionIds) internal view returns (uint[] memory, uint[] memory, uint) {

        uint            amountToRaise;
        uint            totalAmount;
        uint            opportunityCount;

        uint[] memory   ids = new uint[](auctionIds.length);
        uint[] memory   bidAmounts = new uint[](auctionIds.length);

        for (uint i = ZERO; i < auctionIds.length; i++) {
            amountToRaise = CollateralAuctionHouseLibrary.getAmountToRaise(address(auctionHouse), auctionIds[i]);

            if (amountToRaise > ZERO) {
                totalAmount                  = addition(totalAmount, addition(wad(amountToRaise), ONE));
                ids[opportunityCount]        = auctionIds[i];
                bidAmounts[opportunityCount] = amountToRaise;
                opportunityCount++;
            }
        }

        assembly {
            mstore(ids, opportunityCount)
            mstore(bidAmounts, opportunityCount)
        }

        return(ids, bidAmounts, totalAmount);
    }
    function _payCaller() internal {

        CollateralLike_7 collateral = collateralJoin.collateral();
        uint profit = collateral.balanceOf(address(this));

        if (address(collateral) == address(weth)) {
            weth.withdraw(profit);
            msg.sender.call{value: profit}("");
        } else
            collateral.transfer(msg.sender, profit);
    }

    function liquidateAndSettleSAFE(address safe, uint160[2] memory sqrtLimitPrices) public returns (uint auction) {

        if (liquidationEngine.safeSaviours(liquidationEngine.chosenSAFESaviour(collateralType, safe)) == 1) {
            require (liquidationEngine.chosenSAFESaviour(collateralType, safe) == address(0),
            "safe-is-protected.");
        }

        auction = liquidationEngine.liquidateSAFE(collateralType, safe);
        settleAuction(auction, sqrtLimitPrices);
    }
    function liquidateAndSettleSAFE(address safe) public returns (uint auction) {

        if (liquidationEngine.safeSaviours(liquidationEngine.chosenSAFESaviour(collateralType, safe)) == 1) {
            require (liquidationEngine.chosenSAFESaviour(collateralType, safe) == address(0),
            "safe-is-protected.");
        }

        auction = liquidationEngine.liquidateSAFE(collateralType, safe);
        settleAuction(auction);
    }
    function settleAuction(uint auctionId, uint160[2] memory sqrtLimitPrices) public {

        uint amountToRaise = CollateralAuctionHouseLibrary.getAmountToRaise(address(auctionHouse), auctionId);
        require(amountToRaise > ZERO, "GebUniswapV3MultiHopKeeperFlashProxy/auction-already-settled");

        bytes memory callbackData = abi.encode(
            sqrtLimitPrices[1],
            abi.encodeWithSelector(this.bid.selector, auctionId, amountToRaise)
        );

        _startSwap(uniswapPair ,address(coin) == uniswapPair.token1(), addition(wad(amountToRaise), ONE), sqrtLimitPrices[0], callbackData);
        _payCaller();
    }
    function settleAuction(uint[] memory auctionIds, uint160[2] memory sqrtLimitPrices) public {

        (uint[] memory ids, uint[] memory bidAmounts, uint totalAmount) = _getOpenAuctionsBidSizes(auctionIds);
        require(totalAmount > ZERO, "GebUniswapV3MultiHopKeeperFlashProxy/all-auctions-already-settled");

        bytes memory callbackData = abi.encode(
            sqrtLimitPrices[1],
            abi.encodeWithSelector(this.multipleBid.selector, ids, bidAmounts)
        );

        _startSwap(uniswapPair, address(coin) == uniswapPair.token1() ,totalAmount, sqrtLimitPrices[0], callbackData);
        _payCaller();
    }
    function settleAuction(uint auctionId) public {

        uint160[2] memory sqrtLimitPrices;
        settleAuction(auctionId, sqrtLimitPrices);
    }
    function settleAuction(uint[] memory auctionIds) public {

        uint160[2] memory sqrtLimitPrices;
        settleAuction(auctionIds, sqrtLimitPrices);
    }

    receive() external payable {
        require(msg.sender == address(weth), "GebUniswapV3MultiHopKeeperFlashProxy/only-weth-withdrawals-allowed");
    }
}